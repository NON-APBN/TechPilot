import os
import pandas as pd
import re
import joblib
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
from xgboost import XGBRegressor

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

# --- FUNGSI CLEAN_NAME FINAL ---
def clean_name(name):
    if not isinstance(name, str): return ""
    name = name.lower()
    # Hapus informasi VRAM (e.g., 6gb, 8gb)
    name = re.sub(r'\d+gb', '', name)
    # Hapus kata-kata umum yang tidak perlu
    name = name.replace('nvidia', '').replace('geforce', '').replace('amd', '').replace('radeon', '')
    # Hapus tanda baca
    name = re.sub(r'[^\w\s]', ' ', name)
    # Normalisasi spasi
    name = re.sub(r'\s+', ' ', name.strip())
    return name
# --------------------------------

# --- FUNGSI PENCOCOKAN FINAL ---
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
        # Cek apakah nama komponen ada di nama benchmark, atau sebaliknya
        if cleaned_name in bench_name or bench_name in cleaned_name:
            # Hitung selisih panjang string
            diff = abs(len(cleaned_name) - len(bench_name))
            
            # Pilih yang selisih panjangnya paling KECIL (paling mirip)
            if diff < min_len_diff:
                min_len_diff = diff
                best_match_score = score
                best_match_name = bench_name
            # Jika selisih sama, pilih yang lebih panjang (lebih spesifik)
            elif diff == min_len_diff:
                if len(bench_name) > len(best_match_name if best_match_name else ""):
                     best_match_score = score
                     best_match_name = bench_name
    
    return best_match_score, best_match_name
# ------------------------------------

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
    print(f"--- [TRAIN] Berhasil memuat {len(cpu_scores_map)} benchmark CPU.")
    gpu_scores_map = load_benchmark_to_map(CONFIG['CSV_FILES']['GPU_BENCH'], cfg_cols['GPU_NAME'], cfg_cols['GPU_SCORE'])
    print(f"--- [TRAIN] Berhasil memuat {len(gpu_scores_map)} benchmark GPU.")
    chipset_scores_map = load_benchmark_to_map(CONFIG['CSV_FILES']['CHIPSET_BENCH'], cfg_cols['CHIPSET_NAME'], cfg_cols['CHIPSET_SCORE'])
    print(f"--- [TRAIN] Berhasil memuat {len(chipset_scores_map)} benchmark Chipset HP.")

def clean_ram(val):
    try:
        val = str(val).upper()
        # Find number before GB
        match = re.search(r'(\d+)\s*GB', val)
        if match:
            return int(match.group(1))
        return 8 # Default
    except: return 8

def clean_storage(val):
    try:
        val = str(val).upper()
        # Handle TB
        if 'TB' in val:
            match = re.search(r'(\d+)\s*TB', val)
            if match:
                return int(match.group(1)) * 1024
        # Handle GB
        match = re.search(r'(\d+)\s*GB', val)
        if match:
            return int(match.group(1))
        return 512 # Default
    except: return 512

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
        # FUNGSI MEMBERSIHKAN HARGA YANG LEBIH AMAN
        def safe_clean_price(val):
            if pd.isna(val): return 0
            # Jika sudah angka (int/float), kembalikan langsung
            if isinstance(val, (int, float)):
                return val
            
            # Jika string, bersihkan format IDR (Rp, titik ribuan)
            val_str = str(val).lower()
            if 'rp' in val_str:
                val_str = val_str.replace('rp', '').replace('.', '').replace(',', '').strip()
            else:
                 # Hapus karakter non-digit kecuali titik desimal jika format international
                 # Tapi asumsi dataset dominan IDR atau float murni
                 val_str = re.sub(r'[^\d.]', '', val_str)
            
            try:
                return float(val_str)
            except:
                return 0

        df['clean_price'] = df[price_col].apply(safe_clean_price).fillna(0)
    else: return None
    
    if data_type == 'laptop':
        match_results_gpu = df[gpu_col].apply(lambda x: find_best_match_score(x, gpu_scores_map))
        df['gpu_score'] = [res[0] for res in match_results_gpu]
        df['gpu_benchmark_match'] = [res[1] for res in match_results_gpu]
        
        match_results_cpu = df[cpu_col].apply(lambda x: find_best_match_score(x, cpu_scores_map))
        df['cpu_score'] = [res[0] for res in match_results_cpu]

        # --- NEW: PARSE RAM & STORAGE ---
        if 'ram' in df.columns:
            df['ram_gb'] = df['ram'].apply(clean_ram)
        else:
             df['ram_gb'] = 8
             
        if 'storage' in df.columns:
            df['storage_gb'] = df['storage'].apply(clean_storage)
        else:
            df['storage_gb'] = 512

    elif data_type == 'smartphone':
        df['chipset_score'] = df[chipset_col].apply(lambda x: find_best_match_score(x, chipset_scores_map)[0])
            
    return df

def train_laptop_model():
    print("\n--- [TRAIN] Memulai Pelatihan Model Laptop ---")
    df = load_prep_data('laptop')

    debug_df = df[['gpu', 'gpu_benchmark_match', 'gpu_score']]
    debug_df.to_csv('gpu_matching_debug.csv', index=False)
    print("[DEBUG] Laporan pencocokan GPU telah disimpan ke 'gpu_matching_debug.csv'")

    df_train = df[(df['cpu_score'] > 0) & (df['gpu_score'] > 0) & (df['clean_price'] > 1000000)].copy()
    if df_train.empty:
        print("[TRAIN ERROR] Tidak ada data laptop valid untuk dilatih. Periksa 'gpu_matching_debug.csv' untuk detail.")
        return
    print(f"[TRAIN INFO] Menggunakan {len(df_train)} data laptop untuk pelatihan.")
    # UPDATED: Include RAM and Storage
    X = df_train[['cpu_score', 'gpu_score', 'ram_gb', 'storage_gb']]
    y = df_train['clean_price']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    model = XGBRegressor(n_estimators=100, learning_rate=0.1, max_depth=5, random_state=42)
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    score = r2_score(y_test, y_pred)
    print(f"[TRAIN INFO] Model Laptop Selesai. Akurasi (R^2 Score): {score:.2f}")
    joblib.dump(model, 'laptop_model.pkl')
    print("[TRAIN SUCCESS] Model 'laptop_model.pkl' telah disimpan.")

def train_smartphone_model():
    print("\n--- [TRAIN] Memulai Pelatihan Model Smartphone ---")
    df = load_prep_data('smartphone')
    df_train = df[(df['chipset_score'] > 0) & (df['clean_price'] > 500000)].copy()
    if df_train.empty:
        print("[TRAIN ERROR] Tidak ada data HP valid (dengan skor chipset DAN harga > 500rb) untuk dilatih.")
        print("[TRAIN SARAN] Pastikan kolom 'Estimated_Price' di file 'ALL_SMARTPHONES_MERGED.csv' sudah terisi dengan benar.")
        return
    print(f"[TRAIN INFO] Menggunakan {len(df_train)} data HP untuk pelatihan.")
    X = df_train[['chipset_score']]
    y = df_train['clean_price']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    model = XGBRegressor(n_estimators=100, learning_rate=0.1, max_depth=5, random_state=42)
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    score = r2_score(y_test, y_pred)
    print(f"[TRAIN INFO] Model HP Selesai. Akurasi (R^2 Score): {score:.2f}")
    joblib.dump(model, 'smartphone_model.pkl')
    print("[TRAIN SUCCESS] Model 'smartphone_model.pkl' telah disimpan.")

if __name__ == "__main__":
    print("--- [TRAIN] Memuat semua data benchmark...")
    load_all_benchmarks()
    train_laptop_model()
    train_smartphone_model()
    print("\n--- [TRAIN] Semua model telah dilatih dan disimpan. ---")