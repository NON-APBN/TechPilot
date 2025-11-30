import pandas as pd
import os

def fix_smartphones():
    file_path = 'ALL_SMARTPHONES_MERGED.csv'
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return

    print(f"Processing {file_path}...")
    try:
        df = pd.read_csv(file_path)
        if 'Estimated_Price' in df.columns:
            # Check if it's numeric, if not try to convert
            df['Estimated_Price'] = pd.to_numeric(df['Estimated_Price'], errors='coerce')
            
            # Divide by 10
            df['Estimated_Price'] = df['Estimated_Price'] / 10
            
            df.to_csv(file_path, index=False)
            print(f"Successfully updated {file_path}")
        else:
            print(f"Column 'Estimated_Price' not found in {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

def fix_laptops():
    file_path = 'laptops_all_indonesia_fixed_v7.csv'
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        return

    print(f"Processing {file_path}...")
    try:
        df = pd.read_csv(file_path)
        updated = False
        
        if 'price_idr' in df.columns:
            df['price_idr'] = pd.to_numeric(df['price_idr'], errors='coerce')
            df['price_idr'] = df['price_idr'] / 10
            updated = True
            
        if 'price_usd' in df.columns:
            df['price_usd'] = pd.to_numeric(df['price_usd'], errors='coerce')
            df['price_usd'] = df['price_usd'] / 10
            updated = True
            
        if updated:
            df.to_csv(file_path, index=False)
            print(f"Successfully updated {file_path}")
        else:
            print(f"Columns 'price_idr' or 'price_usd' not found in {file_path}")
            
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

if __name__ == "__main__":
    fix_smartphones()
    fix_laptops()
