import os
import pandas as pd
import numpy as np
import re
import joblib
from flask import Flask, request, jsonify
from flask_cors import CORS
import traceback

app = Flask(__name__)
CORS(app)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
ASSETS_DIR = os.path.join(BASE_DIR, '..', 'assets', 'images')

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
        'CPU_NAME': 'Prosesor',
        'CPU_SCORE': 'Cinebench R23 Multi',
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
    name = name.lower()
    name = re.sub(r'\d+gb', '', name)
    name = name.replace('nvidia', '').replace('geforce', '').replace('amd', '').replace('radeon', '')
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name.strip())
    return name

def find_best_match_score(component_name, score_map):
    if not isinstance(component_name, str) or not component_name:
        return 0, None
    
    cleaned_name = clean_name(component_name)
    
    if cleaned_name in score_map:
        return score_map[cleaned_name], cleaned_name

    best_match_score = 0
    best_match_name = None
    min_len_diff = float('inf')
    
    for bench_name, score in score_map.items():
        if cleaned_name in bench_name or bench_name in cleaned_name:
            diff = abs(len(cleaned_name) - len(bench_name))
            if diff < min_len_diff:
                min_len_diff = diff
                best_match_score = score
                best_match_name = bench_name
            elif diff == min_len_diff:
                if len(bench_name) > len(best_match_name if best_match_name else ""):
                     best_match_score = score
                     best_match_name = bench_name
    
    return best_match_score, best_match_name

def load_benchmark_to_map(files, primary_name_col, score_col, fallback_name_col='Chipset'):
    all_data = []
    for f in files:
        try:
            df = pd.read_csv(os.path.join(DATA_DIR, f))
            name_col_to_use = primary_name_col if primary_name_col in df.columns else fallback_name_col
            
            if name_col_to_use in df.columns and score_col in df.columns:
                all_data.append(df[[name_col_to_use, score_col]].rename(columns={name_col_to_use: 'name'}))
            else:
                print(f"WARN: Melewatkan {f} (kolom '{primary_name_col}', '{fallback_name_col}', atau '{score_col}' tidak ditemukan)")
        except Exception as e:
            print(f"ERROR: Gagal memuat {f}: {e}")
    if not all_data: return {}
    bench_df = pd.concat(all_data).drop_duplicates()
    bench_df[score_col] = bench_df[score_col].astype(str).str.replace(',', '', regex=False)
    bench_df[score_col] = pd.to_numeric(bench_df[score_col], errors='coerce').fillna(0)
    return pd.Series(bench_df[score_col].values, index=bench_df['name'].apply(clean_name)).to_dict()

cpu_scores_map = {}
gpu_scores_map = {}
chipset_scores_map = {}

def load_all_benchmarks():
    global cpu_scores_map, gpu_scores_map, chipset_scores_map
    cfg_cols = CONFIG['CSV_COLUMNS']
    cpu_scores_map = load_benchmark_to_map(CONFIG['CSV_FILES']['CPU_BENCH'], cfg_cols['CPU_NAME'], cfg_cols['CPU_SCORE'], fallback_name_col='Chipset')
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
        df['cpu_score'] = df[cpu_col].apply(lambda x: find_best_match_score(x, cpu_scores_map)[0])
        df['gpu_score'] = df[gpu_col].apply(lambda x: find_best_match_score(x, gpu_scores_map)[0])
    elif data_type == 'smartphone':
        df['chipset_score'] = df[chipset_col].apply(lambda x: find_best_match_score(x, chipset_scores_map)[0])
    return df

def find_image_path(product_name):
    if not product_name: return None
    
    clean_name = re.sub(r'[\\/*?:"<>|]', '', product_name)
    
    candidates = [
        f"{clean_name}.jpg",
        f"{clean_name}.png",
        f"{clean_name.title()}.jpg",
        f"{clean_name.lower()}.jpg",
        f"{clean_name.replace(' ', '_').lower()}.jpg",
        f"{clean_name.replace(' ', '_')}.jpg",
    ]
    
    try:
        title_case_dart = ' '.join([word[0].upper() + word[1:].lower() if word else '' for word in clean_name.split()])
        candidates.append(f"{title_case_dart}.jpg")
    except: pass

    for filename in candidates:
        if os.path.exists(os.path.join(ASSETS_DIR, filename)):
            return f"assets/images/{filename}"
            
    return None

laptop_model = None
smartphone_model = None

@app.route('/')
def home():
    return "ML Service (XGBoost Version) is Running!"

@app.route('/search', methods=['POST'])
def search():
    try:
        data = request.json
        data_type = data.get('type', 'laptop')
        query = data.get('query', '').lower()

        if not query:
            return jsonify({"message": "Query pencarian tidak boleh kosong", "results": []})

        cfg_cols = CONFIG['CSV_COLUMNS']
        
        types_to_search = []
        if data_type in ['semua', 'all']:
            types_to_search = ['laptop', 'smartphone']
        else:
            types_to_search = [data_type]

        results = []
        
        for current_type in types_to_search:
            df = load_prep_data(current_type)
            if df is None:
                print(f"WARN: Gagal memuat data untuk {current_type} saat pencarian {data_type}")
                continue

            if current_type == 'laptop':
                name_col, cpu_col, gpu_col = cfg_cols['LAPTOP_NAME'], cfg_cols['LAPTOP_CPU'], cfg_cols['LAPTOP_GPU']
                condition = (
                    df[name_col].str.lower().fillna('').str.contains(query) |
                    df[cpu_col].str.lower().fillna('').str.contains(query) |
                    df[gpu_col].str.lower().fillna('').str.contains(query)
                )
                filtered_df = df[condition]
            elif current_type == 'smartphone':
                name_col, chipset_col = cfg_cols['HP_NAME'], cfg_cols['HP_CHIPSET']
                condition = (
                    df[name_col].str.lower().fillna('').str.contains(query) |
                    df[chipset_col].str.lower().fillna('').str.contains(query)
                )
                filtered_df = df[condition]
            else:
                filtered_df = pd.DataFrame()

            if filtered_df.empty:
                continue

            for _, row in filtered_df.iterrows():
                raw_data = row.to_dict()
                clean_raw_data = {}
                for k, v in raw_data.items():
                    if pd.isna(v):
                        clean_raw_data[k] = None
                    else:
                        clean_raw_data[k] = v

                name_col_key = 'LAPTOP_NAME' if current_type == 'laptop' else 'HP_NAME'
                product_name = row.get(cfg_cols.get(name_col_key), 'Unknown')
                product_data = {
                    "product_name": product_name,
                    "price": row.get('clean_price', 0),
                    "predicted_price": 0,
                    "value_score_rp": 0,
                    "raw_data": clean_raw_data,
                    "type": current_type,
                    "image": find_image_path(product_name)
                }
                if current_type == 'laptop':
                    product_data["cpu_score"] = row.get('cpu_score', 0)
                    product_data["gpu_score"] = row.get('gpu_score', 0)
                elif current_type == 'smartphone':
                    product_data["chipset_score"] = row.get('chipset_score', 0)
                results.append(product_data)
        
        if not results and not types_to_search:
             return jsonify({"error": f"Tipe data tidak valid: {data_type}"}), 400

        page = int(data.get('page', 1))
        limit = int(data.get('limit', 20))
        
        total_items = len(results)
        total_pages = (total_items + limit - 1) // limit
        
        start_idx = (page - 1) * limit
        end_idx = start_idx + limit
        
        paginated_results = results[start_idx:end_idx]
        
        if not paginated_results and page > 1:
             return jsonify({
                 "message": "Halaman tidak ditemukan", 
                 "results": [],
                 "page": page,
                 "total_pages": total_pages,
                 "total_items": total_items
             })
             
        if not results:
             return jsonify({
                 "message": "Tidak ada produk yang cocok", 
                 "results": [],
                 "page": 1,
                 "total_pages": 0,
                 "total_items": 0
             })
        
        return jsonify({
            "results": paginated_results,
            "page": page,
            "total_pages": total_pages,
            "total_items": total_items
        })

    except Exception as e:
        trace = traceback.format_exc()
        print(f"ERROR /search: {e}\n{trace}")
        return jsonify({"error": str(e), "trace": trace}), 500

@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.json
        user_message = data.get('message', '').lower()
        
        if not user_message:
            return jsonify({"response": "Halo! Ada yang bisa saya bantu? Saya bisa merekomendasikan laptop atau smartphone.", "products": []})

        target_type = 'laptop'
        if 'hp' in user_message or 'smartphone' in user_message or 'ponsel' in user_message:
            target_type = 'smartphone'
        
        budget_match = re.search(r'(\d+)(?:\.|,)?(\d+)?\s*(?:jt|juta|ribu|rb)?', user_message)
        target_price = 0
        
        if 'juta' in user_message or 'jt' in user_message:
             numbers = re.findall(r'\d+', user_message)
             if numbers:
                 target_price = int(numbers[0]) * 1000000
        elif 'ribu' in user_message or 'rb' in user_message:
             numbers = re.findall(r'\d+', user_message)
             if numbers:
                 target_price = int(numbers[0]) * 1000
        
        min_price = 0
        max_price = 100000000
        
        if target_price > 0:
            min_price = target_price - 2000000
            max_price = target_price + 2000000
            if min_price < 0: min_price = 0
        elif 'murah' in user_message:
            max_price = 5000000
        elif 'mahal' in user_message or 'flagship' in user_message:
            min_price = 10000000
            
        df = load_prep_data(target_type)
        if df is None:
             return jsonify({"response": "Maaf, saya sedang mengalami gangguan mengakses data produk.", "products": []})
             
        filtered_df = df[(df['clean_price'] >= min_price) & (df['clean_price'] <= max_price)].copy()
        
        keywords = user_message.split()
        brand_keywords = [k for k in keywords if k not in ['cari', 'rekomendasi', 'laptop', 'hp', 'smartphone', 'murah', 'mahal', 'juta', 'jt', 'gaming']]
        
        is_gaming = 'gaming' in user_message
        
        if is_gaming and target_type == 'laptop':
             filtered_df = filtered_df[filtered_df['gpu_score'] > 3000]
             
        for brand in brand_keywords:
            if len(brand) > 2:
                name_col = CONFIG['CSV_COLUMNS']['LAPTOP_NAME'] if target_type == 'laptop' else CONFIG['CSV_COLUMNS']['HP_NAME']
                matches = filtered_df[filtered_df[name_col].str.lower().str.contains(brand, na=False)]
                if not matches.empty:
                    filtered_df = matches
                    break
        
        if filtered_df.empty:
            return jsonify({
                "response": f"Maaf, saya tidak menemukan {target_type} dengan kriteria tersebut di rentang harga ini. Coba naikkan budget atau ubah kata kunci.", 
                "products": []
            })
            
        if target_type == 'laptop':
             if is_gaming:
                 ranked_df = filtered_df.sort_values(by='gpu_score', ascending=False)
             else:
                 ranked_df = filtered_df.sort_values(by='cpu_score', ascending=False)
        else:
             ranked_df = filtered_df.sort_values(by='chipset_score', ascending=False)
             
        top_results = ranked_df.head(5)
        
        products = []
        cfg_cols = CONFIG['CSV_COLUMNS']
        
        for _, row in top_results.iterrows():
            raw_data = row.to_dict()
            clean_raw_data = {}
            for k, v in raw_data.items():
                if pd.isna(v):
                    clean_raw_data[k] = None
                else:
                    clean_raw_data[k] = v

            product_name = row.get(cfg_cols['LAPTOP_NAME'] if target_type == 'laptop' else cfg_cols['HP_NAME'], 'Unknown')
            p_data = {
                "product_name": product_name,
                "price": int(row['clean_price']),
                "type": target_type,
                "raw_data": clean_raw_data,
                "image": find_image_path(product_name)
            }
            if target_type == 'laptop':
                p_data['cpu_score'] = row.get('cpu_score', 0)
                p_data['gpu_score'] = row.get('gpu_score', 0)
            else:
                p_data['chipset_score'] = row.get('chipset_score', 0)
                
            products.append(p_data)
            
        response_text = f"Berikut adalah beberapa rekomendasi {target_type} "
        if target_price > 0:
            response_text += f"di sekitar {target_price // 1000000} jutaan "
        if is_gaming:
            response_text += "untuk gaming "
        response_text += "yang menurut saya worth it:"
        
        return jsonify({"response": response_text, "products": products})

    except Exception as e:
        print(f"ERROR /chat: {e}")
        return jsonify({"response": "Maaf, terjadi kesalahan saat memproses permintaan Anda.", "products": []}), 500 

@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        data = request.json
        data_type = data.get('type', 'laptop')
        min_price = float(data.get('min_price', 0))
        max_price = float(data.get('max_price', 1000000000))
        
        df = load_prep_data(data_type)
        if df is None:
            return jsonify({"error": "Gagal memuat data"}), 500
            
        if data_type == 'laptop':
            max_cpu = df['cpu_score'].max() if df['cpu_score'].max() > 0 else 1
            max_gpu = df['gpu_score'].max() if df['gpu_score'].max() > 0 else 1
            
            df['norm_cpu'] = df['cpu_score'] / max_cpu
            df['norm_gpu'] = df['gpu_score'] / max_gpu
            
            df['perf_score'] = (df['norm_cpu'] * 0.4) + (df['norm_gpu'] * 0.6)
            
        else:
            max_chipset = df['chipset_score'].max() if df['chipset_score'].max() > 0 else 1
            df['perf_score'] = df['chipset_score'] / max_chipset
            
        # Filter by price range
        df = df[(df['clean_price'] >= min_price) & (df['clean_price'] <= max_price)].copy()
        
        if df.empty:
             return jsonify({"results": []})

        df['value_score'] = (df['perf_score'] / df['clean_price']) * 100000000
        
        top_value = df.sort_values(by='value_score', ascending=False).head(10)
        
        results = []
        cfg_cols = CONFIG['CSV_COLUMNS']
        
        for _, row in top_value.iterrows():
            raw_data = row.to_dict()
            clean_raw_data = {}
            for k, v in raw_data.items():
                if pd.isna(v):
                    clean_raw_data[k] = None
                else:
                    clean_raw_data[k] = v

            product_name = row.get(cfg_cols['LAPTOP_NAME'] if data_type == 'laptop' else cfg_cols['HP_NAME'], 'Unknown')
            
            predicted_price = 0
            if data_type == 'laptop' and laptop_model:
                 try:
                     features = pd.DataFrame([{
                         'cpu_score': row['cpu_score'],
                         'gpu_score': row['gpu_score']
                     }])
                     predicted_price = int(laptop_model.predict(features)[0])
                 except: pass
            elif data_type == 'smartphone' and smartphone_model:
                 try:
                     features = pd.DataFrame([{
                         'chipset_score': row['chipset_score']
                     }])
                     predicted_price = int(smartphone_model.predict(features)[0])
                 except: pass

            p_data = {
                "product_name": product_name,
                "price": int(row['clean_price']),
                "predicted_price": predicted_price,
                "value_score_rp": float(row['value_score']),
                "raw_data": clean_raw_data,
                "type": data_type,
                "image": find_image_path(product_name)
            }
            if data_type == 'laptop':
                p_data['cpu_score'] = row.get('cpu_score', 0)
                p_data['gpu_score'] = row.get('gpu_score', 0)
            else:
                p_data['chipset_score'] = row.get('chipset_score', 0)
                
            results.append(p_data)
            
        return jsonify({"results": results})

    except Exception as e:
        trace = traceback.format_exc()
        print(f"ERROR /recommend: {e}\n{trace}")
        return jsonify({"error": str(e), "trace": trace}), 500

@app.route('/compare', methods=['POST'])
def compare():
    try:
        data = request.json
        product_names = data.get('products', [])
        data_type = data.get('type', 'laptop')
        
        if not product_names:
             return jsonify({"error": "Daftar produk kosong"}), 400
             
        df = load_prep_data(data_type)
        if df is None:
             return jsonify({"error": "Gagal memuat data"}), 500
             
        cfg_cols = CONFIG['CSV_COLUMNS']
        name_col = cfg_cols['LAPTOP_NAME'] if data_type == 'laptop' else cfg_cols['HP_NAME']
        
        results = []
        for name in product_names:
            match = df[df[name_col].str.lower() == name.lower()]
            if match.empty:
                match = df[df[name_col].str.lower().str.contains(name.lower(), regex=False)]
                
            if not match.empty:
                row = match.iloc[0]
                
                raw_data = row.to_dict()
                clean_raw_data = {}
                for k, v in raw_data.items():
                    if pd.isna(v):
                        clean_raw_data[k] = None
                    else:
                        clean_raw_data[k] = v

                product_name = row.get(name_col, 'Unknown')
                p_data = {
                    "product_name": product_name,
                    "price": int(row['clean_price']),
                    "raw_data": clean_raw_data,
                    "type": data_type,
                    "image": find_image_path(product_name)
                }
                if data_type == 'laptop':
                    p_data['cpu_score'] = row.get('cpu_score', 0)
                    p_data['gpu_score'] = row.get('gpu_score', 0)
                else:
                    p_data['chipset_score'] = row.get('chipset_score', 0)
                results.append(p_data)
                
        return jsonify({"results": results})

    except Exception as e:
        trace = traceback.format_exc()
        print(f"ERROR /compare: {e}\n{trace}")
        return jsonify({"error": str(e), "trace": trace}), 500

if __name__ == '__main__':
    print("--- [ML INFO] Memuat benchmark saat startup... ---")
    load_all_benchmarks()
    
    try:
        laptop_model = joblib.load(os.path.join(BASE_DIR, 'laptop_model.pkl'))
        print("--- [ML INFO] Model Laptop dimuat.")
    except: print("--- [ML WARN] Model Laptop tidak ditemukan.")
    
    try:
        smartphone_model = joblib.load(os.path.join(BASE_DIR, 'smartphone_model.pkl'))
        print("--- [ML INFO] Model Smartphone dimuat.")
    except: print("--- [ML WARN] Model Smartphone tidak ditemukan.")

    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)