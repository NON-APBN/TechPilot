
import pandas as pd
import numpy as np
import os
import re
from sklearn.ensemble import RandomForestRegressor

# Config
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
CSV_PATH = os.path.join(DATA_DIR, 'laptops_all_indonesia_fixed_v7.csv')
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

def clean_name(name):
    if not isinstance(name, str): return ""
    name = name.lower()
    name = re.sub(r'\d+gb', '', name)
    name = name.replace('nvidia', '').replace('geforce', '').replace('amd', '').replace('radeon', '').replace('graphics', '')
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name.strip())
    return name

def load_benchmark_to_map(files, primary_name_col='name', score_col='score'):
    all_data = []
    for f in files:
        try:
            path = os.path.join(DATA_DIR, f)
            if os.path.exists(path):
                df = pd.read_csv(path)
                cols = df.columns
                # Flexible column finding
                n_col = next((c for c in cols if 'model' in c.lower() or 'name' in c.lower()), cols[0]) 
                # Score column often "Multicores Score" or "Graphics Score"
                s_col = next((c for c in cols if 'score' in c.lower() or 'bench' in c.lower()), cols[-1])
                
                temp = df[[n_col, s_col]].rename(columns={n_col: 'name', s_col: 'score'})
                all_data.append(temp)
        except: pass
        
    if not all_data: return {}
    bench_df = pd.concat(all_data).drop_duplicates()
    bench_df['score'] = pd.to_numeric(bench_df['score'].astype(str).str.replace(',', ''), errors='coerce').fillna(0)
    return pd.Series(bench_df['score'].values, index=bench_df['name'].apply(clean_name)).to_dict()


def find_score(name, score_map):
    if not isinstance(name, str): return 0
    clean = clean_name(name)
    if clean in score_map: return score_map[clean]
    
    # Fuzzy match
    best = 0
    shortest_diff = 999
    for k, v in score_map.items():
        if k in clean or clean in k:
            diff = abs(len(k) - len(clean))
            if diff < shortest_diff:
                shortest_diff = diff
                best = v
    return best

def main():
    print("--- 1. Loading Data ---")
    df = pd.read_csv(CSV_PATH)
    cpu_scores = load_benchmark_to_map(CONFIG['CPU_FILES'])
    gpu_scores = load_benchmark_to_map(CONFIG['GPU_FILES'])

    
    print("--- 2. Calculating Scores ---")
    df['cpu_score'] = df['cpu'].apply(lambda x: find_score(x, cpu_scores))
    df['gpu_score'] = df['gpu'].apply(lambda x: find_score(x, gpu_scores))
    
    # Current clean price (may be wrong scale)
    df['clean_price'] = pd.to_numeric(df['price_idr'], errors='coerce').fillna(0)
    
    # TRAIN SET: Trust only prices > 2,300,000 
    # (Because manually set anchors for low end like Soulmate N100 is 2.5jt. 
    # Anything below that is suspiciously scaled like 1.4jt for Aspire 7)
    train_df = df[(df['clean_price'] > 2300000) & (df['cpu_score'] > 0)]
    
    if len(train_df) < 10:
        print("Not enough trusted data points! (Found < 10)")
        return

    print(f"--- 3. Training Imputation Model (on {len(train_df)} trusted devices) ---")
    X = train_df[['cpu_score', 'gpu_score']]
    y = train_df['clean_price']
    
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X, y)
    
    print("--- 4. Predicting Corrections ---")
    # Predict for ALL laptops with price < 2,300,000 (Suspected bad data)
    target_idx = df[(df['clean_price'] < 2300000) & (df['cpu_score'] > 0)].index
    
    preview = []
    
    for idx in target_idx:
        row = df.loc[idx]
        features = [[row['cpu_score'], row['gpu_score']]]
        pred_price = model.predict(features)[0]
        
        current_price = row['clean_price']
        
        # Apply update
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
