import pandas as pd
import os
import re

CSV_PATH = 'backend/data/laptops_all_indonesia_fixed_v7.csv'
IMAGE_DIR = 'assets/images'

def update_csv_images():
    if not os.path.exists(CSV_PATH):
        print(f"CSV not found: {CSV_PATH}")
        return

    df = pd.read_csv(CSV_PATH)
    
    # Create 'image' column if not exists
    if 'image' not in df.columns:
        df['image'] = None

    updated_count = 0
    
    for index, row in df.iterrows():
        model_name = str(row['model']).strip()
        
        # Generate expected filename (Title Case)
        # 1. Remove special chars
        clean_name = re.sub(r'[\\/*?:"<>|]', '', model_name)
        
        # 2. Title Case
        title_case_name = ' '.join([word.capitalize() for word in clean_name.split()])
        
        filename = f"{title_case_name}.jpg"
        file_path = os.path.join(IMAGE_DIR, filename)
        
        # Check if file exists
        if os.path.exists(file_path):
            # Use forward slashes for compatibility
            relative_path = f"assets/images/{filename}"
            df.at[index, 'image'] = relative_path
            updated_count += 1
        else:
            # Try finding case-insensitive match
            found = False
            for existing_file in os.listdir(IMAGE_DIR):
                if existing_file.lower() == filename.lower():
                    relative_path = f"assets/images/{existing_file}"
                    df.at[index, 'image'] = relative_path
                    updated_count += 1
                    found = True
                    break
            
            if not found:
                print(f"Image not found for: {model_name} (Expected: {filename})")

    df.to_csv(CSV_PATH, index=False)
    print(f"\nUpdated {updated_count} rows with image paths.")

if __name__ == "__main__":
    update_csv_images()
