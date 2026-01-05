
import pandas as pd
import numpy as np
import os
import re
from sklearn.ensemble import RandomForestRegressor
from ml_utils import (
    BASE_DIR, DATA_DIR, CSV_PATH_LAPTOPS as CSV_PATH,
    load_benchmark_to_map, find_score, clean_name
)

CONFIG = {
    'CPU_FILES': [
        'benchmark_prosesor_intel.csv',
        'benchmark_prosesor_amd.csv',
        'benchmark_prosesor_Apple_M_series.csv',
        'benchmark_prosesor_snapdragon.csv'
    ],
    'GPU_FILES': [
        'benchmark_GPU_Nvidia.csv',
        'benchmark_GPU_AMD.csv'
    ],
}

def clean_ram(val):
    try:
        val = str(val).upper()
        match = re.search(r'(\d+)\s*GB', val)
        return int(match.group(1)) if match else 8
    except: return 8

def clean_storage(val):
    try:
        val = str(val).upper()
        if 'TB' in val:
            match = re.search(r'(\d+)\s*TB', val)
            if match:
                return int(match.group(1)) * 1024
        match = re.search(r'(\d+)\s*GB', val)
        return int(match.group(1)) if match else 512
    except: return 512

def main():
    print("--- 1. Loading Data ---")
    df = pd.read_csv(CSV_PATH)
    cpu_scores = load_benchmark_to_map(CONFIG['CPU_FILES'])
    gpu_scores = load_benchmark_to_map(CONFIG['GPU_FILES'])

    print("--- 2. Calculating Scores ---")
    df['cpu_score'] = df['cpu'].apply(lambda x: find_score(x, cpu_scores))
    df['gpu_score'] = df['gpu'].apply(lambda x: find_score(x, gpu_scores))

    
    # NEW: Feature Engineering for Imputation
    df['ram_gb'] = df['ram'].apply(clean_ram)
    df['storage_gb'] = df['storage'].apply(clean_storage)
    
    # Current clean price
    df['clean_price'] = pd.to_numeric(df['price_idr'], errors='coerce').fillna(0)
    
    # TRAIN SET: Trust ONLY Manual Anchors
    if 'is_anchor' not in df.columns:
        print("Column 'is_anchor' missing! Run update_laptop_prices.py first.")
        return

    train_df = df[(df['is_anchor'] == 1) & (df['cpu_score'] > 0)]
    
    if len(train_df) < 10:
        print(f"Not enough trusted anchors! (Found {len(train_df)})")
        return

    print(f"--- 3. Training Imputation Model (on {len(train_df)} Trusted Anchors) ---")
    # UPDATED: Use RAM/Storage for smarter imputation
    X = train_df[['cpu_score', 'gpu_score', 'ram_gb', 'storage_gb']]
    y = train_df['clean_price']
    
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X, y)
    
    print("--- 4. Predicting Corrections ---")
    # Predict for ALL non-anchor rows (Resetting potentially bad previous fixes)
    target_idx = df[(df['is_anchor'] == 0) & (df['cpu_score'] > 0)].index
    
    preview = []
    
    for idx in target_idx:
        row = df.loc[idx]
        features = [[row['cpu_score'], row['gpu_score'], row['ram_gb'], row['storage_gb']]]
        pred_price = model.predict(features)[0]
        
        current_price = row['clean_price']
        
        df.at[idx, 'price_idr'] = int(pred_price)
        
        if len(preview) < 20:
            preview.append({
                "Model": row['model'],
                "Old Price": int(current_price),
                "New Price": int(pred_price)
            })
            
    print("\n--- PREVIEW OF CORRECTIONS ---")
    print(f"{'Model':<30} | {'Old Price':<15} | {'New Price':<15}")
    print("-" * 80)
    for p in preview:
        print(f"{p['Model'][:30]:<30} | {p['Old Price']:<15} | {p['New Price']:<15}")
        
    print("\n--- SAVING ---")
    df.to_csv(CSV_PATH, index=False)
    print("Corrections applied to laptops_all_indonesia_fixed_v7.csv")

if __name__ == "__main__":
    main()
