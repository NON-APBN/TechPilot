import pandas as pd

try:
    df = pd.read_csv(r'd:\Codingan ( Github )\NON APBN\TechPilot\backend\data\laptops_all_indonesia_fixed_v7.csv')
    
    if 'brand' not in df.columns:
        print("Column 'brand' NOT found!")
    else:
        missing_brands = df['brand'].isnull().sum()
        empty_brands = (df['brand'] == '').sum()
        print(f"Column 'brand' found.")
        print(f"Missing values: {missing_brands}")
        print(f"Empty strings: {empty_brands}")
        
        print("\nExisting Brands:")
        print(df['brand'].value_counts())
        
        # Check if there are rows where brand is missing/empty
        if missing_brands > 0 or empty_brands > 0:
            print("\nRows with missing brands:")
            print(df[df['brand'].isnull() | (df['brand'] == '')].head())

except Exception as e:
    print(f"Error: {e}")
