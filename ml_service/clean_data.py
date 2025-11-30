import os
import pandas as pd
import re

# Konfigurasi file dan kolom yang akan dibersihkan
# Format: 'nama_file.csv': ['kolom1_untuk_dibersihkan', 'kolom2_untuk_dibersihkan']
CLEANING_CONFIG = {
    'laptops_all_indonesia_fixed_v7.csv': ['cpu', 'gpu'],
    'ALL_SMARTPHONES_MERGED.csv': ['Platform_Chipset'],
    'benchmark_prosesor_amd.csv': ['Prosesor'],
    'benchmark_prosesor_Apple_M_series.csv': ['Chipset'],
    'benchmark_prosesor_intel.csv': ['Prosesor'],
    'benchmark_prosesor_snapdragon.csv': ['Prosesor'],
    'benchmark_GPU_AMD.csv': ['GPU'],
    'benchmark_GPU_Nvidia.csv': ['GPU'],
    'benchmark_chipset_Apple.csv': ['Chipset'],
    'benchmark_chipset_exynos.csv': ['Chipset'],
    'benchmark_chipset_kirin.csv': ['Chipset'],
    'benchmark_chipset_mediatek.csv': ['Chipset'],
    'benchmark_chipset_snapdragon.csv': ['Chipset'],
    'benchmark_chipset_unisoc.csv': ['Chipset'],
}

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')

def clean_name_for_file(name):
    """Fungsi pembersihan nama yang akan diterapkan ke file."""
    if not isinstance(name, str):
        return ""
    name = name.lower()
    # Hapus informasi VRAM (e.g., 6gb, 8gb, 4gb)
    name = re.sub(r'\d+gb', '', name)
    # Hapus kata-kata umum yang tidak perlu untuk standarisasi
    name = name.replace('nvidia', '').replace('geforce', '').replace('amd', '').replace('radeon', '')
    # Hapus semua karakter non-alfanumerik kecuali spasi
    name = re.sub(r'[^\w\s]', ' ', name)
    # Ganti beberapa spasi dengan satu spasi
    name = re.sub(r'\s+', ' ', name.strip())
    return name

def main():
    print("--- Memulai Proses Pembersihan dan Standarisasi Data CSV ---")
    
    for filename, columns_to_clean in CLEANING_CONFIG.items():
        filepath = os.path.join(DATA_DIR, filename)
        
        if not os.path.exists(filepath):
            print(f"WARN: Melewatkan file karena tidak ditemukan: {filename}")
            continue
            
        try:
            print(f"\nProcessing: {filename}...")
            df = pd.read_csv(filepath)
            
            for col in columns_to_clean:
                if col in df.columns:
                    print(f"  -> Membersihkan kolom '{col}'...")
                    # Terapkan fungsi pembersihan ke seluruh kolom
                    df[col] = df[col].apply(clean_name_for_file)
                else:
                    print(f"  WARN: Kolom '{col}' tidak ditemukan di {filename}.")
            
            # Simpan kembali file CSV yang sudah bersih, menimpa yang lama
            df.to_csv(filepath, index=False)
            print(f"SUCCESS: {filename} telah dibersihkan dan disimpan.")
            
        except Exception as e:
            print(f"ERROR: Gagal memproses file {filename}. Error: {e}")
            
    print("\n--- Proses Pembersihan Selesai ---")
    print("Semua file data Anda sekarang sudah distandarkan.")
    print("Silakan jalankan 'python train_models.py' lagi untuk melatih model dengan data bersih.")

if __name__ == "__main__":
    main()
