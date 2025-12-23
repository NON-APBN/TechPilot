
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
                cols = df.columns
                # Flexible column finding due to inconsistent naming in csvs
                n_col = next((c for c in cols if primary_name_col in c), cols[0]) 
                s_col = next((c for c in cols if score_col in c), cols[-1])
                
                all_data.append(df[[n_col, s_col]].rename(columns={n_col: 'name', s_col: 'score'}))
        except: pass
    
    if not all_data: return {}
    bench_df = pd.concat(all_data).drop_duplicates()
    bench_df['score'] = bench_df['score'].astype(str).str.replace(',', '', regex=False)
    bench_df['score'] = pd.to_numeric(bench_df['score'], errors='coerce').fillna(0)
    return pd.Series(bench_df['score'].values, index=bench_df['name'].apply(clean_name)).to_dict()

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
    return best_score

def format_idr(val):
    return f"Rp {int(val):,}"

def main():
    print("--- Loading Data ---")
    chipset_scores = load_benchmark_to_map(CONFIG['CHIPSET_BENCH'], CONFIG['CHIPSET_NAME'], CONFIG['CHIPSET_SCORE'])
    model = joblib.load(MODEL_PATH)
    df = pd.read_csv(CSV_PATH)
    
    # Ensure trusted price column
    df['clean_price'] = pd.to_numeric(df['Estimated_Price'], errors='coerce').fillna(0)
    
    ranges = [
        (1000000, 2000000, "1 - 2 Juta"),
        (2000000, 3000000, "2 - 3 Juta"),
        (3000000, 4000000, "3 - 4 Juta"),
        (4000000, 5000000, "4 - 5 Juta"),
        (5000000, 8000000, "5 - 8 Juta"),
        (10000000, 50000000, "Flagship (> 10 Juta)")
    ]
    
    for min_p, max_p, label in ranges:
        print(f"\n=== RANGE: {label} ===")
        print(f"{'Device Name':<35} | {'Chipset':<25} | {'Price':<12} | {'Pred':<12} | {'Score/10'}")
        print("-" * 110)
        
        subset = df[(df['clean_price'] >= min_p) & (df['clean_price'] < max_p)].copy()
        
        if subset.empty:
            print("  (No devices found in this range)")
            continue
            
        # Calc scores
        results = []
        for _, row in subset.iterrows():
            chipset = row['Platform_Chipset']
            score = find_best_match_score(chipset, chipset_scores)
            if score == 0: continue
            
            try:
                pred_price = model.predict(pd.DataFrame([{'chipset_score': score}]))[0]
                price = row['clean_price']
                
                # Formula: (Predicted / Actual) * 5, capped at 10
                val_score = (pred_price / price) * 5.0
                val_score = min(val_score, 10.0)
                
                results.append({
                    'name': row['Device Name'],
                    'chipset': str(chipset)[:25],
                    'price': price,
                    'pred': pred_price,
                    'score': val_score
                })
            except: pass
            
        # Sort by Score descending
        results.sort(key=lambda x: x['score'], reverse=True)
        
        # Show top 5 and bottom 3
        display_list = results[:5]
        if len(results) > 8:
            display_list.extend(results[-3:])
            
        for r in display_list:
            print(f"{r['name']:<35} | {r['chipset']:<25} | {format_idr(r['price']):<12} | {format_idr(r['pred']):<12} | {r['score']:.1f}")

if __name__ == "__main__":
    main()
