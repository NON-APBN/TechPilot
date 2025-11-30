import pandas as pd
import os

data_dir = r'd:\Codingan ( Github )\NON APBN\TechPilot\backend\data'
laptop_csv = os.path.join(data_dir, 'laptops_all_indonesia_fixed_v7.csv')
phone_csv = os.path.join(data_dir, 'ALL_SMARTPHONES_MERGED.csv')

print("--- LAPTOPS ---")
try:
    df_laptop = pd.read_csv(laptop_csv)
    print("Columns:")
    print(df_laptop.columns.tolist())
    if 'imagetype' in df_laptop.columns:
        print("First 3 'imagetype' values:")
        print(df_laptop['imagetype'].head(3).tolist())
except Exception as e:
    print(f"Error reading laptop CSV: {e}")

print("\n--- SMARTPHONES ---")
try:
    df_phone = pd.read_csv(phone_csv)
    print("Columns:")
    print(df_phone.columns.tolist())
    possible_cols = [c for c in df_phone.columns if 'img' in c.lower() or 'image' in c.lower() or 'url' in c.lower()]
    print("Possible image columns:", possible_cols)
    for col in possible_cols:
        print(f"First 3 values in '{col}':")
        print(df_phone[col].head(3).tolist())
except Exception as e:
    print(f"Error reading phone CSV: {e}")
