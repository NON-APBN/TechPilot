import os
import pandas as pd
import re

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
SMARTPHONE_CSV = os.path.join(DATA_DIR, 'ALL_SMARTPHONES_MERGED.csv')
PRICE_COLUMN = 'Estimated_Price'

def clean_price(price_str):
    try:
        # Coba konversi langsung ke float/int
        return float(price_str)
    except (ValueError, TypeError):
        # Jika gagal, bersihkan string dan coba lagi
        if isinstance(price_str, str):
            cleaned = re.sub(r'[^\d]', '', price_str)
            if cleaned:
                return float(cleaned)
    return 0.0

def main():
    print("--- Memulai Skrip Pengisian Harga Smartphone ---")
    
    try:
        df = pd.read_csv(SMARTPHONE_CSV)
    except FileNotFoundError:
        print(f"ERROR: File tidak ditemukan di {SMARTPHONE_CSV}")
        return

    if PRICE_COLUMN not in df.columns:
        print(f"ERROR: Kolom '{PRICE_COLUMN}' tidak ditemukan di dalam file CSV.")
        return

    # Buat salinan kolom harga untuk diisi
    new_prices = df[PRICE_COLUMN].copy()
    updated_count = 0

    print("\nKetik harga dalam format angka (misal: 3500000). Ketik 'skip' untuk melewati, atau 'stop' untuk berhenti dan simpan.")
    print("-" * 50)

    for index, row in df.iterrows():
        current_price = clean_price(row[PRICE_COLUMN])
        
        # Hanya tanyakan jika harga kosong atau nol
        if pd.isna(current_price) or current_price == 0:
            device_name = row.get('Device Name', f"Baris ke-{index+1}")
            
            while True:
                try:
                    user_input = input(f"Masukkan harga untuk '{device_name}': ")
                    
                    if user_input.lower() == 'stop':
                        print("\nProses dihentikan oleh pengguna.")
                        break
                    
                    if user_input.lower() == 'skip':
                        print("Dilewati.")
                        break

                    new_price = float(user_input)
                    new_prices.at[index] = new_price
                    updated_count += 1
                    break
                except ValueError:
                    print("Input tidak valid. Harap masukkan angka saja (misal: 3500000).")
                except Exception as e:
                    print(f"Terjadi error: {e}")
                    break
            
            if user_input.lower() == 'stop':
                break

    if updated_count > 0:
        print(f"\nMenyimpan {updated_count} harga baru ke dalam file...")
        df[PRICE_COLUMN] = new_prices
        df.to_csv(SMARTPHONE_CSV, index=False)
        print(f"BERHASIL: File '{SMARTPHONE_CSV}' telah diperbarui.")
    else:
        print("\nTidak ada harga yang diperbarui.")

    print("--- Skrip Selesai ---")

if __name__ == "__main__":
    main()
