import pandas as pd

file_path = r'd:\Codingan ( Github )\NON APBN\TechPilot\backend\data\laptops_all_indonesia_fixed_v7.csv'

try:
    df = pd.read_csv(file_path)
    
    # Brand mapping for normalization
    brand_map = {
        'hp': 'HP', 'Hp': 'HP', 'HP': 'HP',
        'msi': 'MSI', 'Msi': 'MSI', 'MSI': 'MSI',
        'asus': 'Asus', 'ASUS': 'Asus', 'Asus': 'Asus',
        'lenovo': 'Lenovo', 'Lenovo': 'Lenovo',
        'acer': 'Acer', 'Acer': 'Acer',
        'axioo': 'Axioo', 'Axioo': 'Axioo',
        'advan': 'Advan', 'Advan': 'Advan',
        'dell': 'Dell', 'Dell': 'Dell',
        'xiaomi': 'Xiaomi', 'Xiaomi': 'Xiaomi',
        'huawei': 'Huawei', 'Huawei': 'Huawei',
        'zyrex': 'Zyrex', 'Zyrex': 'Zyrex',
        'polytron': 'Polytron', 'Polytron': 'Polytron',
        'chuwi': 'Chuwi', 'Chuwi': 'Chuwi',
        'infinix': 'Infinix', 'Infinix': 'Infinix',
        'apple': 'Apple', 'Apple': 'Apple',
        'macbook': 'Apple'
    }

    if 'brand' in df.columns:
        # Normalize existing brand column
        df['brand'] = df['brand'].map(lambda x: brand_map.get(str(x).strip(), str(x).strip().title()))
        print("Normalized 'brand' column.")
    else:
        # Create brand column from 'model' or 'name' if it didn't exist (fallback logic)
        print("Column 'brand' not found. Creating it...")
        def extract_brand(name):
            name_lower = str(name).lower()
            for key, value in brand_map.items():
                if key.lower() in name_lower:
                    return value
            return 'Unknown'
        
        # Assuming 'model' or 'product_name' exists
        target_col = 'model' if 'model' in df.columns else 'product_name'
        if target_col in df.columns:
             df['brand'] = df[target_col].apply(extract_brand)
             print(f"Created 'brand' column from '{target_col}'.")

    # Save back to CSV
    df.to_csv(file_path, index=False)
    print("CSV updated successfully.")
    print("\nNew Brand Counts:")
    print(df['brand'].value_counts())

except Exception as e:
    print(f"Error: {e}")
