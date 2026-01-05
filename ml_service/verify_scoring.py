
import pandas as pd
import joblib
import os
from ml_utils import (
    BASE_DIR, DATA_DIR, CSV_PATH_PHONES as CSV_PATH,
    load_benchmark_to_map, find_score as find_best_match_score
)

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

def main():
    print("--- Loading Data and Model ---")
    chipset_scores = load_benchmark_to_map(
        CONFIG['CHIPSET_BENCH'], 
        primary_name_col=CONFIG['CHIPSET_NAME'], 
        score_col=CONFIG['CHIPSET_SCORE']
    )
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
