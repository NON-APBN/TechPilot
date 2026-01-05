
import pandas as pd
import joblib
import os
from ml_utils import (
    BASE_DIR, DATA_DIR, CSV_PATH_PHONES as CSV_PATH,
    load_benchmark_to_map, find_score as find_best_match_score, clean_name
)

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

def format_idr(val):
    return f"Rp {int(val):,}"

def main():
    print("--- Loading Data ---")
    chipset_scores = load_benchmark_to_map(
        CONFIG['CHIPSET_BENCH'], 
        primary_name_col=CONFIG['CHIPSET_NAME'], 
        score_col=CONFIG['CHIPSET_SCORE']
    )
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
