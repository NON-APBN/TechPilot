# train_models.py
# (Salin kode lengkap 'train_models.py' dari respons saya sebelumnya)
# ... (kode lengkap dari respons sebelumnya ada di sini) ...
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
    print(f"--- [TRAIN] Berhasil memuat {len(cpu_scores_map)} benchmark CPU.")
    gpu_scores_map = load_benchmark_to_map(CONFIG['CSV_FILES']['GPU_BENCH'], cfg_cols['GPU_NAME'], cfg_cols['GPU_SCORE'])
    print(f"--- [TRAIN] Berhasil memuat {len(gpu_scores_map)} benchmark GPU.")
    chipset_scores_map = load_benchmark_to_map(CONFIG['CSV_FILES']['CHIPSET_BENCH'], cfg_cols['CHIPSET_NAME'], cfg_cols['CHIPSET_SCORE'])
    print(f"--- [TRAIN] Berhasil memuat {len(chipset_scores_map)} benchmark Chipset HP.")

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

def train_laptop_model():
    print("\n--- [TRAIN] Memulai Pelatihan Model Laptop ---")
    df = load_prep_data('laptop')
    df_train = df[(df['cpu_score'] > 0) & (df['gpu_score'] > 0) & (df['clean_price'] > 1000000)].copy()
    if df_train.empty:
        print("[TRAIN ERROR] Tidak ada data laptop valid untuk dilatih.")
        return
    print(f"[TRAIN INFO] Menggunakan {len(df_train)} data laptop untuk pelatihan.")
    X = df_train[['cpu_score', 'gpu_score']]
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
        print("[TRAIN ERROR] Tidak ada data HP valid untuk dilatih.")
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
    print("\n--- [TRAIN] Semua model telah dilatih dan disimpan. ---")fl