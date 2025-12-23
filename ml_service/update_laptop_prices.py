
import pandas as pd
import os
import json

# Config
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
CSV_PATH = os.path.join(DATA_DIR, 'laptops_all_indonesia_fixed_v7.csv')
PRICES_JSON_PATH = os.path.join(BASE_DIR, 'trusted_prices.json')

def load_trusted_prices():
    if not os.path.exists(PRICES_JSON_PATH):
        print(f"Warning: {PRICES_JSON_PATH} not found. Returning empty map.")
        return {}
    
    try:
        with open(PRICES_JSON_PATH, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {PRICES_JSON_PATH}: {e}")
        return {}

def update_prices():
    if not os.path.exists(CSV_PATH):
        print(f"Error: {CSV_PATH} not found.")
        return

    price_map = load_trusted_prices()
    if not price_map:
        print("No trusted prices loaded. Aborting update.")
        return

    df = pd.read_csv(CSV_PATH)
    # Reset or Initialize anchor column
    df['is_anchor'] = 0
    updated_count = 0
    
    # Normalize clean function
    def normalize(s):
        return str(s).lower().strip()

    for idx, row in df.iterrows():
        name = normalize(row['model'])
        
        # Check manual map
        matched = False
        for key, price in price_map.items():
            if key in name:
                df.at[idx, 'price_idr'] = price
                df.at[idx, 'is_anchor'] = 1 # MARK AS TRUSTED
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
