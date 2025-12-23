
import pandas as pd
import joblib
import os
import re

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
CSV_PATH = os.path.join(DATA_DIR, 'laptops_all_indonesia_fixed_v7.csv')
MODEL_PATH = os.path.join(BASE_DIR, 'laptop_model.pkl')

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
    cpu_scores = load_benchmark_to_map(CONFIG['CPU_FILES'])
    gpu_scores = load_benchmark_to_map(CONFIG['GPU_FILES'])
    model = joblib.load(MODEL_PATH)

def main():
    print("--- Loading Data ---")
    cpu_scores = load_benchmark_to_map(CONFIG['CPU_FILES'])
    gpu_scores = load_benchmark_to_map(CONFIG['GPU_FILES'])
    model = joblib.load(MODEL_PATH)
    
    df = pd.read_csv(CSV_PATH)
    
    # Ensure trusted price column
    df['clean_price'] = pd.to_numeric(df['price_idr'], errors='coerce').fillna(0)
    
    print(f"\n{'Model':<35} | {'CPU':<20} | {'Price':<12} | {'Pred':<12} | {'Score/10'}")
    print("-" * 110)
    
    # Check top 50
    for _, row in df.head(50).iterrows():
        n = row['model']
        cpu = row['cpu']
        gpu = row['gpu']
        p = row['clean_price']
        
        if p < 500000: continue # Skip likely broken data
        
        c_score = find_best_match_score(cpu, cpu_scores)
        g_score = find_best_match_score(gpu, gpu_scores)
        
        try:
            pred = model.predict(pd.DataFrame([{'cpu_score': c_score, 'gpu_score': g_score}]))[0]
            
            # Value Calculation
            # 5.0 is fair.
            score = (pred / p) * 5.0
            score = min(score, 10.0)
            
            print(f"{n[:35]:<35} | {str(cpu)[:20]:<20} | {format_idr(p):<12} | {format_idr(pred):<12} | {score:.1f}")
        except: pass


if __name__ == "__main__":
    main()
