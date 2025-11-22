import os
import pandas as pd
import numpy as np
import re
import joblib
from flask import Flask, request, jsonify

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')

CONFIG = {
    'CSV_FILES': {
        'LAPTOP': 'laptops_all_indonesia_fixed_v7.csv',
        'SMARTPHONE': 'ALL_SMARTPHONES_MERGED.csv',
        'CPU_BENCH': [
            'benchmark_prosesor_amd.csv',
            'benchmark_prosesor_Apple_M_series.csv',
            'benchmark_prosesor_intel.csv',
            'benchmark_prosesor_snapdragon.csv'
        ],
        'GPU_BENCH': [
            'benchmark_GPU_AMD.csv',
            'benchmark_GPU_Nvidia.csv'
        ],
        'CHIPSET_BENCH': [
            'benchmark_chipset_Apple.csv',
            'benchmark_chipset_exynos.csv',
            'benchmark_chipset_kirin.csv',
            'benchmark_chipset_mediatek.csv',
            'benchmark_chipset_snapdragon.csv',
            'benchmark_chipset_unisoc.csv'
        ]
    },
    'CSV_COLUMNS': {
        'CHIPSET_NAME': 'Chipset',
        'CHIPSET_SCORE': 'AnTuTu v10',
        'GPU_NAME': 'GPU',
        'GPU_SCORE': '3DMark Time Spy Graphics',
        'CPU_NAME': 'GPU',
        'CPU_SCORE': 'Cinebench R23 GPU',
        'LAPTOP_NAME': 'model',
        'LAPTOP_PRICE': 'price_idr',
        'LAPTOP_CPU': 'cpu',
        'LAPTOP_GPU': 'gpu',
        'HP_NAME': 'Device Name',
        'HP_PRICE': 'Estimated_Price',
        'HP_CHIPSET': 'Platform_Chipset'
    }
}

def clean_name(name):
    if not isinstance(name, str): return ""
    return re.sub(r'\s+', ' ', name.lower().strip())

def load_benchmark_to_map(files, name_col, score_col):
    all_data = []
    for f in files:
        try:
            df = pd.read_csv(os.path.join(DATA_DIR, f))
            if name_col in df.columns and score_col in df.columns:
                all_data.append(df[[name_col, score_col]])
            else:
                print(f"WARN: Melewatkan {f} (kolom {name_col} atau {score_col} tidak ditemukan)")
        except Exception as e:
            print(f"ERROR: Gagal memuat {f}: {e}")
    if not all_data: return {}
    bench_df = pd.concat(all_data).drop_duplicates()
    bench_df[score_col] = bench_df[score_col].astype(str).str.replace(',', '', regex=False)
    bench_df[score_col] = pd.to_numeric(bench_df[score_col], errors='coerce').fillna(0)
    return pd.Series(bench_df[score_col].values, index=bench_df[name_col].apply(clean_name)).to_dict()

cpu_scores_map = {}
gpu_scores_map = {}
chipset_scores_map = {}

def load_all_benchmarks():
    global cpu_scores_map, gpu_scores_map, chipset_scores_map
    cfg_cols = CONFIG['CSV_COLUMNS']
    cpu_scores_map = load_benchmark_to_map(CONFIG['CSV_FILES']['CPU_BENCH'], cfg_cols['CPU_NAME'], cfg_cols['CPU_SCORE'])
    print(f"--- [ML INFO] Berhasil memuat {len(cpu_scores_map)} benchmark CPU.")
    gpu_scores_map = load_benchmark_to_map(CONFIG['CSV_FILES']['GPU_BENCH'], cfg_cols['GPU_NAME'], cfg_cols['GPU_SCORE'])
    print(f"--- [ML INFO] Berhasil memuat {len(gpu_scores_map)} benchmark GPU.")
    chipset_scores_map = load_benchmark_to_map(CONFIG['CSV_FILES']['CHIPSET_BENCH'], cfg_cols['CHIPSET_NAME'], cfg_cols['CHIPSET_SCORE'])
    print(f"--- [ML INFO] Berhasil memuat {len(chipset_scores_map)} benchmark Chipset HP.")

def load_prep_data(data_type='laptop'):
    cfg_cols = CONFIG['CSV_COLUMNS']
    if data_type == 'laptop':
        csv_file = CONFIG['CSV_FILES']['LAPTOP']
        price_col = cfg_cols['LAPTOP_PRICE']
        cpu_col = cfg_cols['LAPTOP_CPU']
        gpu_col = cfg_cols['LAPTOP_GPU']
    elif data_type == 'smartphone':
        csv_file = CONFIG['CSV_FILES']['SMARTPHONE']
        price_col = cfg_cols['HP_PRICE']
        chipset_col = cfg_cols['HP_CHIPSET']
    else: return None
    csv_path = os.path.join(DATA_DIR, csv_file)
    if not os.path.exists(csv_path): return None
    df = pd.read_csv(csv_path)
    if price_col in df.columns:
        df['clean_price'] = df[price_col].astype(str).str.replace(r'[Rp,.]', '', regex=True)
        df['clean_price'] = pd.to_numeric(df['clean_price'], errors='coerce').fillna(0)
    else: return None
    if data_type == 'laptop':
        df['cpu_score'] = df[cpu_col].apply(clean_name).map(cpu_scores_map).fillna(0) if cpu_col in df.columns else 0
        df['gpu_score'] = df[gpu_col].apply(clean_name).map(gpu_scores_map).fillna(0) if gpu_col in df.columns else 0
    elif data_type == 'smartphone':
        df['chipset_score'] = df[chipset_col].apply(clean_name).map(chipset_scores_map).fillna(0) if chipset_col in df.columns else 0
    return df

app = Flask(__name__)

laptop_model = None
smartphone_model = None

@app.route('/')
def home():
    return "ML Service (XGBoost Version) is Running!"

@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        data = request.json
        min_price = data.get('min_price', 0)
        max_price = data.get('max_price', 100000000)
        data_type = data.get('type', 'laptop')

        cfg_cols = CONFIG['CSV_COLUMNS']

        df = load_prep_data(data_type)
        if df is None:
            return jsonify({"error": f"Gagal memuat data CSV untuk {data_type}"}), 500

        filtered_df = df[(df['clean_price'] >= min_price) & (df['clean_price'] <= max_price)].copy()
        if filtered_df.empty:
            return jsonify({"message": "Tidak ada produk di rentang harga tersebut", "results": []})

        results = []

        if data_type == 'laptop':
            if laptop_model is None:
                return jsonify({"error": "Model laptop (XGBoost) belum dimuat."}), 500
            name_col, cpu_col, gpu_col = cfg_cols['LAPTOP_NAME'], cfg_cols['LAPTOP_CPU'], cfg_cols['LAPTOP_GPU']
            valid_rows = filtered_df[(filtered_df['cpu_score'] > 0) & (filtered_df['gpu_score'] > 0)]
            if not valid_rows.empty:
                X_predict = valid_rows[['cpu_score', 'gpu_score']]
                predicted_prices = laptop_model.predict(X_predict)
                valid_rows['predicted_price'] = predicted_prices
                valid_rows['value_score'] = valid_rows['predicted_price'] - valid_rows['clean_price']
                ranked_df = valid_rows.sort_values(by='value_score', ascending=False)
                top_10 = ranked_df.head(10)
                for _, row in top_10.iterrows():
                    results.append({
                        "product_name": row.get(name_col, 'Unknown Device'),
                        "price": row['clean_price'],
                        "predicted_price": round(row['predicted_price']),
                        "value_score_rp": round(row['value_score']),
                        "cpu_score": row['cpu_score'],
                        "gpu_score": row['gpu_score'],
                        "cpu": row.get(cpu_col), # Tambahkan nama CPU mentah
                        "gpu": row.get(gpu_col), # Tambahkan nama GPU mentah
                    })

        elif data_type == 'smartphone':
            if smartphone_model is None:
                return jsonify({"error": "Model smartphone (XGBoost) belum dimuat."}), 500
            name_col, chipset_col = cfg_cols['HP_NAME'], cfg_cols['HP_CHIPSET']
            valid_rows = filtered_df[filtered_df['chipset_score'] > 0]
            if not valid_rows.empty:
                X_predict = valid_rows[['chipset_score']]
                predicted_prices = smartphone_model.predict(X_predict)
                valid_rows['predicted_price'] = predicted_prices
                valid_rows['value_score'] = valid_rows['predicted_price'] - valid_rows['clean_price']
                ranked_df = valid_rows.sort_values(by='value_score', ascending=False)
                top_10 = ranked_df.head(10)
                for _, row in top_10.iterrows():
                    results.append({
                        "product_name": row.get(name_col, 'Unknown Device'),
                        "price": row['clean_price'],
                        "predicted_price": round(row['predicted_price']),
                        "value_score_rp": round(row['value_score']),
                        "chipset_score": row['chipset_score'],
                        "chipset": row.get(chipset_col), # Tambahkan nama Chipset mentah
                    })

        return jsonify({
            "count": len(results),
            "range_price": f"{min_price} - {max_price}",
            "results": results
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/compare', methods=['POST'])
def compare():
    try:
        data = request.json
        products = data.get('products', [])
        if not products or len(products) < 2:
            return jsonify({"error": "Minimal 2 produk diperlukan untuk perbandingan."}), 400

        # Tambahkan skor benchmark ke setiap produk
        for p in products:
            if p.get('type') == 'laptop':
                p['cpu_score'] = cpu_scores_map.get(clean_name(p.get('cpu')), 0)
                p['gpu_score'] = gpu_scores_map.get(clean_name(p.get('gpu')), 0)
            elif p.get('type') == 'smartphone':
                p['chipset_score'] = chipset_scores_map.get(clean_name(p.get('chipset')), 0)

        # Fungsi untuk membandingkan dan memberi anotasi
        def annotate_comparison(products, key, name, is_higher_better=True):
            scores = [p.get(key, 0) for p in products]
            if not any(scores): return

            max_score = max(scores)
            min_score = min(scores)

            if max_score == min_score: # Jika semua skor sama
                for p in products:
                    p[key] = {'value': p.get(key, 0), 'status': 'neutral', 'reason': f'Sama dengan produk lain.'}
                return

            for p in products:
                score = p.get(key, 0)
                status = 'neutral'
                reason = ''
                if (is_higher_better and score == max_score) or (not is_higher_better and score == min_score):
                    status = 'best'
                    reason = f'Terbaik di kategori {name}.'
                elif (is_higher_better and score == min_score) or (not is_higher_better and score == max_score):
                    status = 'worst'
                    reason = f'Paling rendah di kategori {name}.'
                
                p[key] = {'value': score, 'status': status, 'reason': reason}

        # Lakukan perbandingan untuk setiap metrik
        annotate_comparison(products, 'price', 'Harga', is_higher_better=False)
        if products[0].get('type') == 'laptop':
            annotate_comparison(products, 'cpu_score', 'Performa CPU')
            annotate_comparison(products, 'gpu_score', 'Performa Grafis')
        elif products[0].get('type') == 'smartphone':
            annotate_comparison(products, 'chipset_score', 'Performa Chipset')

        return jsonify({"results": products})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("--- [ML INFO] Memuat semua data benchmark...")
    load_all_benchmarks()
    try:
        laptop_model = joblib.load('laptop_model.pkl')
        print("--- [ML INFO] Model 'laptop_model.pkl' berhasil dimuat.")
    except FileNotFoundError:
        print("--- [ML WARN] 'laptop_model.pkl' tidak ditemukan. Jalankan 'python train_models.py' dulu.")
    try:
        smartphone_model = joblib.load('smartphone_model.pkl')
        print("--- [ML INFO] Model 'smartphone_model.pkl' berhasil dimuat.")
    except FileNotFoundError:
        print("--- [ML WARN] 'smartphone_model.pkl' tidak ditemukan. Jalankan 'python train_models.py' dulu.")

    # Gunicorn akan menggunakan variabel 'app' ini
    # Port akan diatur oleh Render, bukan oleh app.run()
    app.run(debug=False, host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))