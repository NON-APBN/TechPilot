
import pandas as pd
import joblib
import os
import re

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
CSV_PATH = os.path.join(DATA_DIR, 'ALL_SMARTPHONES_MERGED.csv')
MODEL_PATH = os.path.join(BASE_DIR, 'smartphone_model.pkl')

CONFIG = {
    'CSV_COLUMNS': {
        'HP_PRICE': 'Estimated_Price',
        'HP_CHIPSET': 'Platform_Chipset'
    },
    'CHIPSET_BENCH': [
        'benchmark_chipset_Apple.csv',
        'benchmark_chipset_exynos.csv',
        'benchmark_chipset_kirin.csv',
        'benchmark_chipset_mediatek.csv',
        'benchmark_chipset_snapdragon.csv',
        'benchmark_chipset_unisoc.csv'
    ],
    'CHIPSET_NAME': 'Chipset',
    'CHIPSET_SCORE': 'AnTuTu v10'
}

def clean_name(name):
    if not isinstance(name, str): return ""
    name = name.lower()
    name = re.sub(r'\d+gb', '', name)
    name = name.replace('nvidia', '').replace('geforce', '').replace('amd', '').replace('radeon', '')
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name.strip())
    return name

def load_benchmark_to_map(files, primary_name_col, score_col):
    all_data = []
    for f in files:
        try:
            path = os.path.join(DATA_DIR, f)
            if os.path.exists(path):
                df = pd.read_csv(path)
                if primary_name_col in df.columns and score_col in df.columns:
                    all_data.append(df[[primary_name_col, score_col]].rename(columns={primary_name_col: 'name'}))
        except: pass
    
    if not all_data: return {}
    bench_df = pd.concat(all_data).drop_duplicates()
    bench_df[score_col] = bench_df[score_col].astype(str).str.replace(',', '', regex=False)
    bench_df[score_col] = pd.to_numeric(bench_df[score_col], errors='coerce').fillna(0)
    return pd.Series(bench_df[score_col].values, index=bench_df['name'].apply(clean_name)).to_dict()

def find_best_match_score(component_name, score_map):
    if not isinstance(component_name, str) or not component_name:
        return 0
    cleaned_name = clean_name(component_name)
    if cleaned_name in score_map:
        return score_map[cleaned_name]
    
    best_score = 0
    best_match_name = None
    min_len_diff = float('inf')
    
    for bench_name, score in score_map.items():
        if cleaned_name in bench_name or bench_name in cleaned_name:
            diff = abs(len(cleaned_name) - len(bench_name))
            if diff < min_len_diff:
                min_len_diff = diff
                best_score = score
                best_match_name = bench_name
            elif diff == min_len_diff:
                 if len(bench_name) > len(best_match_name if best_match_name else ""):
                     best_score = score
                     best_match_name = bench_name
    return best_score

def main():
    print("--- Loading Data and Model ---")
    chipset_scores = load_benchmark_to_map(CONFIG['CHIPSET_BENCH'], CONFIG['CHIPSET_NAME'], CONFIG['CHIPSET_SCORE'])
    model = joblib.load(MODEL_PATH)
    df = pd.read_csv(CSV_PATH)
    
    print(f"Loaded {len(df)} phones.")
    
    # Filter for updated flagships to verify
    targets = [
        "iPhone 15 Pro Max", "iPhone 13", "Samsung Galaxy S24 Ultra", 
        "Samsung Galaxy S23", "Google Pixel 9 Pro", "Google Pixel 7"
    ]
    
    print("\n--- Verifying Value Scores (0-10 Scale) ---")
    print(f"{'Device Name':<30} | {'Actual Price':<15} | {'Pred. Price':<15} | {'Score (0-10)':<10} | {'Verdict'}")
    print("-" * 100)
    
    for _, row in df.iterrows():
        name = str(row['Device Name'])
        is_target = any(t.lower() in name.lower() for t in targets)
        
        # Only check targets or expensive phones to avoid noise
        if not is_target: continue
            
        img_price = row['Estimated_Price']
        
        # Clean price (simple)
        try:
            price = float(img_price)
        except:
            continue
            
        if price < 1000000: continue # Skip not-updated ones
        
        chipset = row['Platform_Chipset']
        chip_score = find_best_match_score(chipset, chipset_scores)
        
        if chip_score == 0:
            continue
            
        # Predict
        pred_price = model.predict(pd.DataFrame([{'chipset_score': chip_score}]))[0]
        
        # Calculate Value Score: (Predicted / Actual) * 5
        # Fair = 5.0. Above 5 = Good Value. Below 5 = Bad Value.
        # Cap at 10.
        
        score = (pred_price / price) * 5.0
        score = min(score, 10.0)
        
        verdict = "Fair"
        if score > 6: verdict = "GOOD DEAL"
        if score > 8: verdict = "EXCELLENT"
        if score < 4: verdict = "Overpriced"
        
        # Format IDR
        act_s = f"{int(price):,}"
        pred_s = f"{int(pred_price):,}"
        
        print(f"{name:<30} | Rp {act_s:<12} | Rp {pred_s:<12} | {score:.1f}/10     | {verdict}")

if __name__ == "__main__":
    main()
