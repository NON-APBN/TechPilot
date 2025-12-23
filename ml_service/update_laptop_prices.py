
import pandas as pd
import os

# Config
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
CSV_PATH = os.path.join(DATA_DIR, 'laptops_all_indonesia_fixed_v7.csv')

# Manual Price Map (Trust Anchors) - Prices in IDR
PRICE_MAP = {
    # --- FLAGSHIP / HIGH END ---
    "macbook pro 14 m3": 28000000,
    "macbook pro 16 m3": 40000000,
    "macbook air m2": 16000000,
    "macbook air m3": 19000000,
    
    "rog strix scar 18": 65000000,
    "rog zephyrus g14": 30000000,
    "rog flow z13": 25000000,
    "rog strix g16": 28000000,
    
    "msi raider ge78": 45000000,
    "msi titan gt77": 60000000,
    
    "lenovo legion 9i": 50000000,
    "lenovo legion 7i": 35000000,
    "lenovo legion 5i": 20000000,
    "lenovo loq": 12000000,

    # --- MID RANGE ---
    "acer nitro v 15": 11000000,
    "acer predator helios neo 16": 20000000,
    "asus tuf gaming a15": 12000000,
    "asus tuf dash f15": 14000000,
    "hp victus 15": 10000000,
    "hp victus 16": 15000000,
    "lenovo ideapad gaming 3": 10000000,
    
    "asus vivobook pro 15": 15000000,
    "asus vivobook 14": 8000000,
    "acer swift go 14": 12000000,

    # --- BUDGET / LOW END (Crucial for Imputation) ---
    "advan workplus": 7000000, # Ryze 5 6600H
    "advan soulmate": 2500000, # N4020 variant
    "advan soulmate n100": 3500000, 
    "axioo hype 3": 3500000,
    "axioo hype 5": 5000000,
    "axioo mybook": 3000000,
    
    "infinix inbook x2": 5000000,
    "infinix inbook x3": 6000000,
    
    "acer aspire 3": 5500000,
    "acer aspire 5": 7000000,
    "lenovo ideapad slim 1": 4500000,
    "lenovo ideapad slim 3": 6000000,
    "hp 14s": 5000000,
}

def update_prices():
    if not os.path.exists(CSV_PATH):
        print(f"Error: {CSV_PATH} not found.")
        return

    df = pd.read_csv(CSV_PATH)
    updated_count = 0
    
    # Normalize clean function
    def normalize(s):
        return str(s).lower().strip()

    for idx, row in df.iterrows():
        name = normalize(row['model'])
        
        # Check manual map
        matched = False
        for key, price in PRICE_MAP.items():
            if key in name:
                df.at[idx, 'price_idr'] = price
                print(f"Updated Anchor: {row['model']} -> {price}")
                matched = True
                updated_count += 1
                break
        
        if not matched:
            pass 
            
    print(f"\nSuccessfully updated {updated_count} laptop anchors in {CSV_PATH}")
    df.to_csv(CSV_PATH, index=False)

if __name__ == "__main__":
    update_prices()
