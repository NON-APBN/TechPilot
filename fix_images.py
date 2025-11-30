import pandas as pd
import os
import shutil
import re

# Paths
BASE_DIR = os.getcwd()
ASSETS_DIR = os.path.join(BASE_DIR, 'assets', 'images')
DATA_DIR = os.path.join(BASE_DIR, 'backend', 'data')
LAPTOP_CSV = os.path.join(DATA_DIR, 'laptops_all_indonesia_fixed_v7.csv')
SMARTPHONE_CSV = os.path.join(DATA_DIR, 'ALL_SMARTPHONES_MERGED.csv')

def sanitize_filename(name):
    """Sanitize product name to be a valid filename."""
    # Replace invalid characters with underscore or remove them
    s = str(name).strip()
    s = re.sub(r'[\\/*?:"<>|]', '_', s)
    return s

def load_product_names():
    """Load all product names from CSVs."""
    products = []
    
    # Laptops
    if os.path.exists(LAPTOP_CSV):
        df = pd.read_csv(LAPTOP_CSV)
        if 'model' in df.columns:
            products.extend(df['model'].dropna().tolist())
            
    # Smartphones
    if os.path.exists(SMARTPHONE_CSV):
        df = pd.read_csv(SMARTPHONE_CSV)
        if 'Device Name' in df.columns:
            products.extend(df['Device Name'].dropna().tolist())
            
    return products

def normalize_string(s):
    """Normalize string for fuzzy matching (lowercase, remove spaces)."""
    return re.sub(r'[^a-z0-9]', '', str(s).lower())

def fix_images():
    print("Loading product names...")
    product_names = load_product_names()
    print(f"Found {len(product_names)} products.")
    
    if not os.path.exists(ASSETS_DIR):
        print(f"Assets directory not found: {ASSETS_DIR}")
        return

    # Create a map of normalized product names to original product names
    product_map = {normalize_string(p): p for p in product_names}
    
    # List existing images
    existing_images = os.listdir(ASSETS_DIR)
    print(f"Found {len(existing_images)} existing images.")
    
    renamed_count = 0
    
    for img_file in existing_images:
        if not img_file.lower().endswith(('.jpg', '.jpeg', '.png', '.webp')):
            continue
            
        name_part = os.path.splitext(img_file)[0]
        normalized_img_name = normalize_string(name_part)
        
        # Try to find a match
        matched_product = None
        
        # 1. Exact match (normalized)
        if normalized_img_name in product_map:
            matched_product = product_map[normalized_img_name]
        
        # 2. Try removing brand prefix from image name (e.g. "Acer Predator" -> "Predator")
        # This is tricky because we don't know the brand for sure, but we can try substring matching
        if not matched_product:
             for p_norm, p_real in product_map.items():
                 if p_norm in normalized_img_name:
                     # If the product name is contained in the image name, it's a likely match
                     # But we should be careful. Let's prioritize longer matches.
                     if matched_product:
                         if len(p_norm) > len(normalize_string(matched_product)):
                             matched_product = p_real
                     else:
                         matched_product = p_real

        if matched_product:
            new_filename = f"{sanitize_filename(matched_product)}.jpg"
            old_path = os.path.join(ASSETS_DIR, img_file)
            new_path = os.path.join(ASSETS_DIR, new_filename)
            
            if old_path != new_path:
                try:
                    # If target exists, don't overwrite unless it's a placeholder? 
                    # For now, let's just rename.
                    if os.path.exists(new_path):
                        print(f"Skipping {img_file} -> {new_filename} (Target exists)")
                    else:
                        os.rename(old_path, new_path)
                        print(f"Renamed: {img_file} -> {new_filename}")
                        renamed_count += 1
                except Exception as e:
                    print(f"Error renaming {img_file}: {e}")
        else:
            # print(f"No match found for image: {img_file}")
            pass

    print(f"Finished. Renamed {renamed_count} images.")

if __name__ == "__main__":
    fix_images()
