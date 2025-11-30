import pandas as pd
import os
import requests
import time
import random
from ddgs import DDGS

# Configuration
CSV_PATH = 'backend/data/laptops_all_indonesia_fixed_v7.csv'
IMAGE_DIR = 'assets/images'
DELAY_SECONDS = 15.0  # Increased delay to 15s
MAX_RETRIES = 5

# Simple User-Agent rotation
USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
]

def download_image(url, save_path):
    try:
        headers = {'User-Agent': random.choice(USER_AGENTS)}
        response = requests.get(url, headers=headers, timeout=15)
        if response.status_code == 200:
            with open(save_path, 'wb') as f:
                f.write(response.content)
            return True
    except Exception as e:
        print(f"  Error downloading {url}: {e}")
    return False

def main():
    if not os.path.exists(CSV_PATH):
        print(f"Error: CSV file not found at {CSV_PATH}")
        return

    if not os.path.exists(IMAGE_DIR):
        os.makedirs(IMAGE_DIR)
        print(f"Created directory: {IMAGE_DIR}")

    df = pd.read_csv(CSV_PATH)
    
    if 'model' not in df.columns:
        print("Error: 'model' column missing in CSV.")
        return

    print(f"Found {len(df)} products. Starting download...")
    print(f"Using delay of {DELAY_SECONDS} seconds to avoid rate limits.")
    
    for index, row in df.iterrows():
        model_name = str(row['model']).strip()
        safe_name = "".join([c for c in model_name if c.isalpha() or c.isdigit() or c==' ']).rstrip()
        filename = safe_name.replace(" ", "_").lower() + ".jpg"
        save_path = os.path.join(IMAGE_DIR, filename)

        # Skip if already exists
        if os.path.exists(save_path):
            print(f"[{index+1}/{len(df)}] Skipped (Exists): {model_name}")
            continue

        print(f"[{index+1}/{len(df)}] Searching: {model_name}...")
        
        success = False
        retries = 0
        
        while not success and retries < MAX_RETRIES:
            try:
                # Randomize headers for DDGS if possible, but DDGS manages its own.
                # We just rely on the delay.
                with DDGS() as ddgs:
                    query = f"Laptop {model_name} official render"
                    # Use a random timeout to vary the request pattern
                    # Fetch 3 results to have backups if the first one fails
                    results = list(ddgs.images(query, max_results=3))
                    
                    if results:
                        # Try up to 3 images from the results
                        for img_data in results:
                            image_url = img_data['image']
                            print(f"  Attempting download: {image_url[:50]}...")
                            if download_image(image_url, save_path):
                                print(f"  Saved: {filename}")
                                success = True
                                break # Break inner loop (images)
                        
                        if not success:
                            print(f"  Failed to download any images for {model_name}. Retrying search...")
                            retries += 1
                            time.sleep(random.uniform(5, 10))
                    else:
                        print(f"  No images found for {model_name}")
                        success = True # No images found, stop retrying search
                
            except Exception as e:
                error_str = str(e)
                # Catch generic errors that might be rate limits
                if "Ratelimit" in error_str or "403" in error_str or "Too Many Requests" in error_str:
                    wait_time = 45 + (retries * 30) # Aggressive backoff: 45s, 75s, 105s...
                    print(f"  Rate limit hit. Waiting {wait_time} seconds... (Retry {retries+1}/{MAX_RETRIES})")
                    time.sleep(wait_time)
                    retries += 1
                else:
                    print(f"  Error searching for {model_name}: {e}")
                    # If it's not a rate limit, maybe just skip to next item to avoid getting stuck
                    retries += 1 # Count as a retry
                    time.sleep(5)
            
            if not success and retries < MAX_RETRIES:
                 print(f"  Retrying product... ({retries}/{MAX_RETRIES})")
                 time.sleep(DELAY_SECONDS + random.uniform(2, 5))
        
        # Base delay
        time.sleep(DELAY_SECONDS + random.uniform(1, 3))

    print("\nDownload process completed!")

if __name__ == "__main__":
    main()
