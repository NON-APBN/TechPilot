
import pandas as pd
import numpy as np
import os
import re
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor

# Config
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
CSV_PATH = os.path.join(DATA_DIR, 'ALL_SMARTPHONES_MERGED.csv')
CHIPSET_FILES = [
    'benchmark_chipset_Apple.csv', 'benchmark_chipset_snapdragon.csv',
    'benchmark_chipset_mediatek.csv', 'benchmark_chipset_exynos.csv',
    'benchmark_chipset_kirin.csv', 'benchmark_chipset_unisoc.csv'
]

def clean_name(name):
    if not isinstance(name, str): return ""
    name = name.lower()
    name = re.sub(r'\d+gb', '', name)
    name = name.replace('nvidia', '').replace('geforce', '').replace('amd', '').replace('radeon', '')
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name.strip())
    return name

def load_chipset_scores():
    all_data = []
    for f in CHIPSET_FILES:
        try:
            p = os.path.join(DATA_DIR, f)
            if os.path.exists(p):
                df = pd.read_csv(p)
                # Auto detect columns
                cols = df.columns
                name_col = next((c for c in cols if 'Chipset' in c), cols[0])
                score_col = next((c for c in cols if 'AnTuTu v10' in c), cols[-1])
                
                temp = df[[name_col, score_col]].rename(columns={name_col: 'name', score_col: 'score'})
                all_data.append(temp)
        except: pass
        
    if not all_data: return {}
    bench = pd.concat(all_data).drop_duplicates()
    bench['score'] = pd.to_numeric(bench['score'].astype(str).str.replace(',', ''), errors='coerce').fillna(0)
    return pd.Series(bench['score'].values, index=bench['name'].apply(clean_name)).to_dict()

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
    scores_map = load_chipset_scores()
    
    print("--- 2. Calculating Chipset Scores ---")
    df['chipset_score'] = df['Platform_Chipset'].apply(lambda x: find_score(x, scores_map))
    
    # Clean Price
    def clean_p(x):
        try:
            s = str(x).lower().replace('rp', '').replace(',', '').replace('.', '')
            return float(s) # This is WRONG if we stripped valid dots. 
            # But wait, original data is float string "253300.0".
            # str(253300.0) -> "253300.0" -> replace '.' -> "2533000".
            # This replicates the "bug" that accidentally scaled things x10? 
            # NO, we want to fix it properly now.
        except: return 0

    # Current price in CSV is mostly clean float "253300.0"
    df['clean_price'] = pd.to_numeric(df['Estimated_Price'], errors='coerce').fillna(0)
    
    # TRAIN SET: Trust only prices > 3,000,000 (The ones we manually fixed or are expensive)
    # AND must have a valid chipset score
    train_df = df[(df['clean_price'] > 3000000) & (df['chipset_score'] > 0)]
    
    if len(train_df) < 10:
        print("Not enough trusted data points! (Found < 10)")
        return

    print(f"--- 3. Training Imputation Model (on {len(train_df)} trusted devices) ---")
    X = train_df[['chipset_score']]
    y = train_df['clean_price']
    
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X, y)
    
    print("--- 4. Predicting Corrections ---")
    # Predict for ALL phones with price < 2,000,000 (Suspected bad data)
    target_idx = df[(df['clean_price'] < 2000000) & (df['chipset_score'] > 0)].index
    
    preview = []
    
    for idx in target_idx:
        row = df.loc[idx]
        score = row['chipset_score']
        current_price = row['clean_price']
        
        pred_price = model.predict([[score]])[0]
        
        # Heuristic: Don't allow price to be suspiciously low if score is high
        # Imputation gives us the 'fair market value' based on specs
        
        df.at[idx, 'Estimated_Price'] = int(pred_price)
        
        if len(preview) < 15:
            preview.append({
                "Device": row['Device Name'],
                "Score": int(score),
                "Old Price": int(current_price),
                "New Price": int(pred_price)
            })
            
    print("\n--- PREVIEW OF CORRECTIONS ---")
    print(f"{'Device':<30} | {'Score':<10} | {'Old Price':<15} | {'New Price':<15}")
    print("-" * 80)
    for p in preview:
        print(f"{p['Device']:<30} | {p['Score']:<10} | {p['Old Price']:<15} | {p['New Price']:<15}")
        
    print("\n--- SAVING ---")
    df.to_csv(CSV_PATH, index=False)
    print("Corrections applied to ALL_SMARTPHONES_MERGED.csv")

if __name__ == "__main__":
    main()
