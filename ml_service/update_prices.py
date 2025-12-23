
import pandas as pd
import os

# Define paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
CSV_PATH = os.path.join(DATA_DIR, 'ALL_SMARTPHONES_MERGED.csv')

# Price dictionary (Name substring -> Price IDR)
# Lowercase keys for easier matching
PRICE_MAP = {
    "iphone 13 pro max": 24000000,
    "iphone 13 pro": 20000000,
    "iphone 13": 11000000,
    "iphone 13 mini": 10000000,
    
    "iphone 14 pro max": 26000000,
    "iphone 14 pro": 23000000,
    "iphone 14 plus": 15000000,
    "iphone 14": 13500000,
    
    "iphone 15 pro max": 29000000, # 256GB base usually
    "iphone 15 pro": 25000000,
    "iphone 15 plus": 17000000,
    "iphone 15": 14500000,

    "iphone 16 pro max": 32000000, # Estimate
    "iphone 16 pro": 28000000,
    "iphone 16 plus": 19000000,
    "iphone 16": 17000000,

    "galaxy s24 ultra": 19000000,
    "galaxy s24+": 16000000,
    "galaxy s24": 14000000,

    "galaxy s23 ultra": 17000000,
    "galaxy s23+": 13000000,
    "galaxy s23": 11000000,

    "pixel 7 pro": 13500000,
    "pixel 7": 9000000,
    
    "pixel 8 pro": 15500000,
    "pixel 8": 11000000,
    
    "pixel 9 pro xl": 26000000,
    "pixel 9 pro": 24000000,
    "pixel 9": 19000000,

    # --- MID/BUDGET RANGE ANCHORS (Crucial for Imputation) ---
    "galaxy a55": 6000000,
    "galaxy a54": 5000000,
    "galaxy a35": 4500000,
    "galaxy a34": 4000000,
    "galaxy a15": 2500000,
    "galaxy a05": 1500000,
    
    "redmi note 13 pro+": 5500000,
    "redmi note 13 pro": 4000000,
    "redmi note 13": 2500000,
    "redmi 13c": 1500000,
    "redmi 12": 1800000,
    
    "infinix gt 20 pro": 4500000,
    "infinix note 40": 2500000,
    "infinix hot 40": 1500000,
    
    "poco f6": 6000000,
    "poco x6 pro": 4500000,
    "poco m6": 2000000,

    "iphone 11": 5000000, # Market price 2024 (new/stock/refurb) is around 4-6M
    "iphone xr": 3500000,
}



def update_prices():
    if not os.path.exists(CSV_PATH):
        print(f"Error: CSV not found at {CSV_PATH}")
        return

    df = pd.read_csv(CSV_PATH)
    updated_count = 0
    
    print("\n--- Updating Prices ---")
    
    for index, row in df.iterrows():
        device_name = str(row['Device Name']).lower()
        
        # Check if any key in PRICE_MAP matches the device name
        # We search specifically for the exact model name being contained
        original_price = row.get('Estimated_Price', 0)
        
        # Exact match logic (or close enough)
        matched_key = None
        # Sort keys by length desc to match "iphone 13 pro max" before "iphone 13"
        for key in sorted(PRICE_MAP.keys(), key=len, reverse=True):
            # Use word boundaries or specific checks to avoid "iphone 13" matching "iphone 13 pro" improperly if we didn't sort
            # But sorting by length handles specificity.
            if key in device_name:
                # Ensure we don't match "iphone 13" inside "iphone 13 pro" if we iterate simply
                # With sorted keys (longest first), "iphone 13 pro" comes before "iphone 13"
                matched_key = key
                break
        
        if matched_key:
            new_price = PRICE_MAP[matched_key]
            # Verify if update is needed (approx checking to avoid redundant noise)
            # Only update if current price is wacky (e.g. < 1/2 of new price or > 2x)
            # OR just overwrite to be safe since we know current data is bad scaling
            df.at[index, 'Estimated_Price'] = new_price
            updated_count += 1
            print(f"Updated: {row['Device Name']} | Old: {original_price} -> New: {new_price}")

    if updated_count > 0:
        df.to_csv(CSV_PATH, index=False)
        print(f"\nSuccessfully updated {updated_count} devices in {CSV_PATH}")
    else:
        print("\nNo devices matched or updated.")

if __name__ == "__main__":
    update_prices()
