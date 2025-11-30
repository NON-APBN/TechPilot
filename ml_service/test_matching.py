import pandas as pd
import re

# Mock data based on real benchmarks
cpu_benchmarks = {
    "intel core i5 1135g7": 10000,
    "intel core i5 13980hx": 30000,
    "intel core i5": 5000, # Hypothetical generic entry
    "amd ryzen 5 5500u": 12000,
    "amd ryzen 5": 6000
}

gpu_benchmarks = {
    "rtx 3050": 4000,
    "rtx 3050 ti": 5000,
    "rtx 4090": 20000,
    "rtx 4050": 8000
}

def clean_name(name):
    if not isinstance(name, str): return ""
    name = name.lower()
    name = re.sub(r'\d+gb', '', name)
    name = name.replace('nvidia', '').replace('geforce', '').replace('amd', '').replace('radeon', '')
    name = re.sub(r'[^\w\s]', ' ', name)
    name = re.sub(r'\s+', ' ', name.strip())
    return name

def find_best_match_score_original(component_name, score_map):
    if not isinstance(component_name, str) or not component_name:
        return 0, None
    
    cleaned_name = clean_name(component_name)
    
    if cleaned_name in score_map:
        return score_map[cleaned_name], cleaned_name

    best_match_score = 0
    best_match_name = None
    longest_match_len = 0
    
    for bench_name, score in score_map.items():
        if cleaned_name in bench_name or bench_name in cleaned_name:
            current_match_len = max(len(cleaned_name), len(bench_name))
            if current_match_len > longest_match_len:
                longest_match_len = current_match_len
                best_match_score = score
                best_match_name = bench_name
    
    return best_match_score, best_match_name

def find_best_match_score_improved(component_name, score_map):
    if not isinstance(component_name, str) or not component_name:
        return 0, None
    
    cleaned_name = clean_name(component_name)
    
    if cleaned_name in score_map:
        return score_map[cleaned_name], cleaned_name

    best_match_score = 0
    best_match_name = None
    # Initialize with a large number for difference
    min_len_diff = float('inf')
    
    for bench_name, score in score_map.items():
        if cleaned_name in bench_name or bench_name in cleaned_name:
            # Calculate length difference
            diff = abs(len(cleaned_name) - len(bench_name))
            
            # We want the SMALLEST difference (closest match)
            if diff < min_len_diff:
                min_len_diff = diff
                best_match_score = score
                best_match_name = bench_name
            # If differences are equal, maybe prefer the one that is longer (more specific)?
            elif diff == min_len_diff:
                if len(bench_name) > len(best_match_name):
                     best_match_score = score
                     best_match_name = bench_name
    
    return best_match_score, best_match_name

test_cases = [
    ("Intel Core i5", cpu_benchmarks),
    ("RTX 3050", gpu_benchmarks),
    ("AMD Ryzen 5", cpu_benchmarks)
]

print("--- ORIGINAL LOGIC ---")
for name, map_data in test_cases:
    score, match = find_best_match_score_original(name, map_data)
    print(f"Input: '{name}' -> Match: '{match}' (Score: {score})")

print("\n--- IMPROVED LOGIC ---")
for name, map_data in test_cases:
    score, match = find_best_match_score_improved(name, map_data)
    print(f"Input: '{name}' -> Match: '{match}' (Score: {score})")
