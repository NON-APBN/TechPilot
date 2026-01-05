import os
import re
import pandas as pd
import json

# --- CONFIG & PATHS ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, '..', 'backend', 'data')
CSV_PATH_LAPTOPS = os.path.join(DATA_DIR, 'laptops_all_indonesia_fixed_v7.csv')
CSV_PATH_PHONES = os.path.join(DATA_DIR, 'ALL_SMARTPHONES_MERGED.csv')

# --- SHARED FUNCTIONS ---

def clean_name(name):
    """
    Standardizes device/component names for matching.
    Lowercases, removes capacity (e.g. 8gb), removes brand prefixes, removes special chars.
    """
    if not isinstance(name, str): return ""
    name = name.lower()
    # Remove capacity info like "8gb", "12gb"
    name = re.sub(r'\d+gb', '', name)
    # Remove common irrelevant words
    name = name.replace('nvidia', '').replace('geforce', '').replace('amd', '').replace('radeon', '').replace('graphics', '')
    # Remove special chars
    name = re.sub(r'[^\w\s]', ' ', name)
    # Collapse multiple spaces
    name = re.sub(r'\s+', ' ', name.strip())
    return name

def load_benchmark_to_map(files, primary_name_col=None, score_col=None):
    """
    Loads multiple CSV benchmark files into a single dictionary (Name -> Score).
    
    args:
        files: list of filenames in DATA_DIR
        primary_name_col: (Optional) exact name of the column containing the item name
        score_col: (Optional) exact name of the column containing the score
        
    If col names are not provided/found, attempts to find them automatically.
    """
    all_data = []
    
    for f in files:
        try:
            path = os.path.join(DATA_DIR, f)
            if not os.path.exists(path):
                continue
                
            df = pd.read_csv(path)
            cols = df.columns
            
            # Determine Name Column
            n_col = primary_name_col
            if not n_col or n_col not in cols:
                # Try to auto-detect
                n_col = next((c for c in cols if 'model' in c.lower() or 'name' in c.lower()), None)
                if not n_col: n_col = cols[0] # Fallback to first column
            
            # Determine Score Column
            s_col = score_col
            if not s_col or s_col not in cols:
                # Try to auto-detect
                s_col = next((c for c in cols if 'score' in c.lower() or 'bench' in c.lower() or 'antutu' in c.lower()), None)
                if not s_col: s_col = cols[-1] # Fallback to last column
            
            temp = df[[n_col, s_col]].rename(columns={n_col: 'name', s_col: 'score'})
            all_data.append(temp)
                
        except Exception as e:
            print(f"Error reading {f}: {e}")
            pass
        
    if not all_data: return {}
    
    bench_df = pd.concat(all_data).drop_duplicates()
    
    # Clean Score data (remove commas, handle non-numeric)
    bench_df['score'] = bench_df['score'].astype(str).str.replace(',', '', regex=False)
    bench_df['score'] = pd.to_numeric(bench_df['score'], errors='coerce').fillna(0)
    
    # Return dictionary: CleanedName -> Score
    return pd.Series(bench_df['score'].values, index=bench_df['name'].apply(clean_name)).to_dict()

def find_score(name, score_map):
    """
    Finds the score for a given name in the score_map using exact match or partial/fuzzy match.
    """
    if not isinstance(name, str) or not name: return 0
    clean = clean_name(name)
    
    # Exact match (after cleaning)
    if clean in score_map: return score_map[clean]
    
    # Fuzzy/Substring match
    best_score = 0
    shortest_diff = 999
    
    for bench_name, score in score_map.items():
        if clean in bench_name or bench_name in clean:
            diff = abs(len(clean) - len(bench_name))
            if diff < shortest_diff:
                shortest_diff = diff
                best_score = score
            elif diff == shortest_diff:
                # Tie-breaker: prefer longer match length (more specific) if needed
                pass
                
    return best_score
