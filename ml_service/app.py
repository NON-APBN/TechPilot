import os
import pandas as pd
import numpy as np
from flask import Flask, request, jsonify
from sklearn.preprocessing import MinMaxScaler
import re

app = Flask(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')

# --- Konfigurasi terpusat untuk nama file dan kolom ---
CONFIG = {
    'LAPTOP_FILE': 'laptops_all_indonesia_fixed_v7.csv',
    'SMARTPHONE_FILE': 'ALL_SMARTPHONES_MERGED.csv',
    'LAPTOP_PRICE_COL': 'price_idr',
    'HP_PRICE_COL': 'Estimated_Price',
    'LAPTOP_NAME_COL': 'model',
    'HP_NAME_COL': 'Device Name',
    'LAPTOP_CPU_COL': 'cpu',
    'LAPTOP_GPU_COL': 'gpu',
    'HP_CHIPSET_COL': 'Platform_Chipset'
}

# --- Cache untuk data yang sudah diproses ---
processed_data_cache = {}

def robust_price_cleaner(series):
    """
    Fungsi pembersihan harga yang tangguh untuk menangani berbagai format.
    Handles: 15000000.0 (float), 15000000 (int), "15.000.000" (IDR str), "15000000" (str)
    """
    def clean_single(val):
        if pd.isna(val) or val == '':
            return 0
        
        # 1. Jika sudah numerik, return langsung
        if isinstance(val, (int, float, np.number)):
            return int(val)
            
        val_str = str(val).strip()
        
        # 2. Cek format IDR dengan 'Rp' atau titik sebagai pemisah ribuan
        # Asumsi: jika ada titik lebih dari satu, atau pola 'xxx.xxx', itu ribuan IDR
        if 'rp' in val_str.lower() or val_str.count('.') > 1:
             cleaned = re.sub(r'[^\d]', '', val_str) # Hapus semua kecuali angka
             return int(cleaned) if cleaned else 0
        
        # 3. Handle float string "25000.0" -> pastikan tidak menghapus titik decimal
        try:
            return int(float(val_str))
        except ValueError:
            # Fallback terakhir, ambil digit saja
            cleaned = re.sub(r'[^\d]', '', val_str)
            return int(cleaned) if cleaned else 0

    return series.apply(clean_single)

def get_processed_data(data_type='laptop'):
    """
    Memuat, membersihkan, dan men-cache data utama (laptop/smartphone).
    Fungsi ini dipanggil oleh endpoint, bukan saat startup.
    """
    if data_type in processed_data_cache:
        return processed_data_cache[data_type]

    if data_type == 'laptop':
        file_name = CONFIG['LAPTOP_FILE']
        price_col = CONFIG['LAPTOP_PRICE_COL']
    elif data_type == 'smartphone':
        file_name = CONFIG['SMARTPHONE_FILE']
        price_col = CONFIG['HP_PRICE_COL']
    else:
        return None

    csv_path = os.path.join(DATA_DIR, file_name)
    if not os.path.exists(csv_path):
        print(f"FATAL: File data tidak ditemukan di {csv_path}")
        return None

    try:
        df = pd.read_csv(csv_path)
        # Simpan data asli untuk pencarian
        original_df = df.copy()
        
        # Bersihkan harga
        df['clean_price'] = robust_price_cleaner(df[price_col])
        
        # Simpan data yang telah diproses ke cache
        processed_data_cache[data_type] = df
        return df
    except Exception as e:
        print(f"FATAL: Gagal memproses file {file_name}. Error: {e}")
        return None

@app.route('/')
def home():
    return "ML Service is running. Data akan diproses on-demand."

@app.route('/recommend', methods=['GET'])
def recommend():
    try:
        min_price = int(request.args.get('min_price', 0))
        max_price = int(request.args.get('max_price', 100000000))
        data_type = request.args.get('type', 'laptop')
        page = int(request.args.get('page', 1))
        per_page = 20

        df = get_processed_data(data_type)
        if df is None:
            return jsonify({"error": f"Gagal memuat data untuk tipe '{data_type}'."}), 500

        # Filter berdasarkan harga yang sudah bersih
        filtered_df = df[(df['clean_price'] >= min_price) & (df['clean_price'] <= max_price)].copy()
        
        if filtered_df.empty:
            return jsonify({"message": "Tidak ada produk di rentang harga ini.", "results": [], "page": 1, "total_pages": 0})

        # --- Logika Skor Worth-It Sederhana ---
        # Untuk sementara, kita urutkan berdasarkan harga termurah untuk memastikan data muncul
        ranked_df = filtered_df.sort_values(by='clean_price', ascending=True)
        
        total_items = len(ranked_df)
        total_pages = (total_items + per_page - 1) // per_page
        paginated_df = ranked_df.iloc[(page - 1) * per_page:page * per_page]
        
        # Tentukan kolom nama berdasarkan tipe
        name_col = CONFIG['LAPTOP_NAME_COL'] if data_type == 'laptop' else CONFIG['HP_NAME_COL']

        # Replace NaN with None globally in the dataframe for valid JSON
        paginated_df = paginated_df.replace({np.nan: None})

        results = []
        for _, row in paginated_df.iterrows():
            # Ensure raw_data is clean
            raw_data = row.to_dict()
            for k, v in raw_data.items():
                if pd.isna(v):
                    raw_data[k] = None
            
            results.append({
                "product_name": row.get(name_col, "N/A"),
                "price": int(row['clean_price']) if pd.notna(row['clean_price']) else 0,
                "worth_it_score": 5.0, # Skor dummy
                "raw_data": raw_data
            })
            
        return jsonify({
            "page": page,
            "total_pages": total_pages,
            "total_results": total_items,
            "results": results
        })
    except Exception as e:
        print(f"ERROR in /recommend: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("--- [ML INFO] Server ML siap di port 5000.")
    print("--- [ML INFO] Data akan dimuat dan diproses saat ada permintaan.")
    app.run(debug=False, port=5000)
