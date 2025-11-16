import os
import pandas as pd
import numpy as np
from flask import Flask, request, jsonify
from sklearn.preprocessing import MinMaxScaler
import re # Untuk membersihkan nama

app = Flask(__name__)

# --- KONFIGURASI PATH ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')

# ==============================================================================
# --- KONFIGURASI UTAMA (SESUAI DENGAN HEADER CSV ANDA) ---
# ==============================================================================
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
        # --- Kolom di file Benchmark ---
        # (Dari 'Chipset,Cores/Threads,Clocks...,AnTuTu v10...')
        'CHIPSET_NAME': 'Chipset',
        'CHIPSET_SCORE': 'AnTuTu v10', # Kita pilih AnTuTu v10 sebagai skor acuan

        # (Dari 'GPU,Shaders Boost MHz,Cinebench R23 GPU,3DMark Time Spy Graphics...')
        'GPU_NAME': 'GPU',
        'GPU_SCORE': '3DMark Time Spy Graphics', # Kita pilih Time Spy sebagai skor acuan

        # (Dari 'Prosesor' - Anda salah salin header, tapi saya asumsikan dari contoh)
        # Asumsi header prosesor SAMA dengan GPU: 'GPU, ... Cinebench R23 GPU, ...'
        # dan 'GPU' adalah kolom nama, 'Cinebench R23 GPU' adalah skornya.
        'CPU_NAME': 'GPU', # Aneh, tapi ini sesuai data header Anda
        'CPU_SCORE': 'Cinebench R23 GPU', # Skor acuan untuk CPU

        # --- Kolom di file Data Utama ---
        # (Dari 'laptops_all_indonesia_fixed_v7.csv')
        'LAPTOP_NAME': 'model',
        'LAPTOP_PRICE': 'price_idr',
        'LAPTOP_CPU': 'cpu',
        'LAPTOP_GPU': 'gpu',

        # (Dari 'ALL_SMARTPHONES_MERGED.CSV')
        'HP_NAME': 'Device Name',
        'HP_PRICE': 'Estimated_Price',
        'HP_CHIPSET': 'Platform_Chipset'
    }
}
# ==============================================================================

# Global map untuk menyimpan skor benchmark
cpu_scores_map = {}
gpu_scores_map = {}
chipset_scores_map = {}

def clean_name(name):
    """Membersihkan nama string untuk matching yang lebih baik."""
    if not isinstance(name, str):
        return ""
    # Menghapus spasi berlebih dan mengubah ke huruf kecil
    return re.sub(r'\s+', ' ', name.lower().strip())

def load_benchmark_to_map(files, name_col, score_col):
    """Fungsi helper untuk memuat list file benchmark ke dalam satu map."""
    all_data = []
    for f in files:
        try:
            df = pd.read_csv(os.path.join(DATA_DIR, f))
            # Cek apakah kolom yang diperlukan ada
            if name_col in df.columns and score_col in df.columns:
                all_data.append(df[[name_col, score_col]])
            else:
                print(f"WARN: Melewatkan {f} (kolom {name_col} atau {score_col} tidak ditemukan)")
        except Exception as e:
            print(f"ERROR: Gagal memuat {f}: {e}")

    if not all_data:
        return {}

    bench_df = pd.concat(all_data).drop_duplicates()
    # Bersihkan kolom skor (hapus koma, ubah ke angka)
    bench_df[score_col] = bench_df[score_col].astype(str).str.replace(',', '', regex=False)
    bench_df[score_col] = pd.to_numeric(bench_df[score_col], errors='coerce').fillna(0)

    # Buat Map: { 'nama_bersih': 15000, ... }
    return pd.Series(
        bench_df[score_col].values,
        index=bench_df[name_col].apply(clean_name)
    ).to_dict()

def load_all_benchmarks():
    """
    Memuat semua file benchmark (CPU, GPU, Chipset) ke global map.
    """
    global cpu_scores_map, gpu_scores_map, chipset_scores_map

    cfg_cols = CONFIG['CSV_COLUMNS']

    # --- Load CPU ---
    cpu_scores_map = load_benchmark_to_map(
        CONFIG['CSV_FILES']['CPU_BENCH'],
        cfg_cols['CPU_NAME'],
        cfg_cols['CPU_SCORE']
    )
    print(f"--- [ML INFO] Berhasil memuat {len(cpu_scores_map)} benchmark CPU.")

    # --- Load GPU ---
    gpu_scores_map = load_benchmark_to_map(
        CONFIG['CSV_FILES']['GPU_BENCH'],
        cfg_cols['GPU_NAME'],
        cfg_cols['GPU_SCORE']
    )
    print(f"--- [ML INFO] Berhasil memuat {len(gpu_scores_map)} benchmark GPU.")

    # --- Load Chipset ---
    chipset_scores_map = load_benchmark_to_map(
        CONFIG['CSV_FILES']['CHIPSET_BENCH'],
        cfg_cols['CHIPSET_NAME'],
        cfg_cols['CHIPSET_SCORE']
    )
    print(f"--- [ML INFO] Berhasil memuat {len(chipset_scores_map)} benchmark Chipset HP.")


def load_prep_data(data_type='laptop'):
    """
    Memuat dan menyiapkan data utama (laptop atau smartphone).
    """
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
    else:
        return None

    csv_path = os.path.join(DATA_DIR, csv_file)
    if not os.path.exists(csv_path):
        print(f"ERROR: File tidak ditemukan di {csv_path}")
        return None

    df = pd.read_csv(csv_path)

    # 1. Bersihkan Harga
    if price_col in df.columns:
        df['clean_price'] = df[price_col].astype(str).str.replace(r'[Rp,.]', '', regex=True)
        df['clean_price'] = pd.to_numeric(df['clean_price'], errors='coerce').fillna(0)
    else:
        print(f"ERROR: Kolom harga '{price_col}' tidak ditemukan di {csv_file}.")
        return None

    # 2. Map Skor
    if data_type == 'laptop':
        if cpu_col in df.columns:
            df['cpu_score'] = df[cpu_col].apply(clean_name).map(cpu_scores_map).fillna(0)
        else: df['cpu_score'] = 0

        if gpu_col in df.columns:
            df['gpu_score'] = df[gpu_col].apply(clean_name).map(gpu_scores_map).fillna(0)
        else: df['gpu_score'] = 0

    elif data_type == 'smartphone':
        if chipset_col in df.columns:
            df['chipset_score'] = df[chipset_col].apply(clean_name).map(chipset_scores_map).fillna(0)
        else: df['chipset_score'] = 0

    return df

def calculate_worth_it_score(df, weights):
    """
    Menghitung skor 'Worth It' menggunakan Normalisasi MinMax.
    """
    if df.empty:
        return df

    scaler = MinMaxScaler()

    # Normalisasi Harga (0-1).
    df['price_norm'] = scaler.fit_transform(df[['clean_price']])
    df['worth_it_score'] = weights['price'] * (1 - df['price_norm']) # (1 - norm) -> harga murah = skor tinggi

    # Normalisasi fitur lain
    if 'cpu' in weights and 'cpu_score' in df.columns:
        if df['cpu_score'].max() > 0:
            df['cpu_norm'] = scaler.fit_transform(df[['cpu_score']])
            df['worth_it_score'] += weights['cpu'] * df['cpu_norm']

    if 'gpu' in weights and 'gpu_score' in df.columns:
        if df['gpu_score'].max() > 0:
            df['gpu_norm'] = scaler.fit_transform(df[['gpu_score']])
            df['worth_it_score'] += weights['gpu'] * df['gpu_norm']

    if 'chipset' in weights and 'chipset_score' in df.columns:
        if df['chipset_score'].max() > 0:
            df['chipset_norm'] = scaler.fit_transform(df[['chipset_score']])
            df['worth_it_score'] += weights['chipset'] * df['chipset_norm']

    df['final_rank_score'] = df['worth_it_score'] * 10
    return df

@app.route('/')
def home():
    return "Machine Learning Service is Running! All Benchmarks (CPU, GPU, Chipset) Loaded."

@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        data = request.json
        min_price = data.get('min_price', 0)
        max_price = data.get('max_price', 100000000)
        data_type = data.get('type', 'laptop')

        cfg_cols = CONFIG['CSV_COLUMNS']

        if data_type == 'laptop':
            df = load_prep_data('laptop')
            weights = {'price': 0.4, 'cpu': 0.3, 'gpu': 0.3} # Bobot untuk laptop
            name_col = cfg_cols['LAPTOP_NAME']
            features = ['cpu_score', 'gpu_score']

        elif data_type == 'smartphone':
            df = load_prep_data('smartphone')
            weights = {'price': 0.5, 'chipset': 0.5} # Bobot untuk HP
            name_col = cfg_cols['HP_NAME']
            features = ['chipset_score']

        else:
            return jsonify({"error": "Tipe tidak valid. Gunakan 'laptop' atau 'smartphone'."}), 400

        if df is None:
            return jsonify({"error": f"Gagal memuat data CSV untuk {data_type}"}), 500

        # Filter Berdasarkan Harga
        filtered_df = df[
            (df['clean_price'] >= min_price) &
            (df['clean_price'] <= max_price)
        ].copy()

        if filtered_df.empty:
            return jsonify({"message": "Tidak ada produk di rentang harga tersebut", "results": []})

        # Hitung Skor Worth It
        ranked_df = calculate_worth_it_score(filtered_df, weights)
        ranked_df = ranked_df.sort_values(by='final_rank_score', ascending=False)
        top_10 = ranked_df.head(10)

        # Format Output JSON
        results = []
        for _, row in top_10.iterrows():
            item = {
                "product_name": row.get(name_col, 'Unknown Device'),
                "price": row['clean_price'],
                "worth_it_score": round(row['final_rank_score'], 2)
            }
            # Tambahkan skor fitur
            for f in features:
                item[f] = row.get(f, 0)
            results.append(item)

        return jsonify({
            "count": len(results),
            "range_price": f"{min_price} - {max_price}",
            "results": results
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("--- [ML INFO] Memuat semua data benchmark saat server dimulai...")
    load_all_benchmarks()
    print("--- [ML INFO] Server ML siap di port 5000.")
    app.run(debug=True, port=5000)