import os

IMAGE_DIR = 'assets/images'

def rename_images():
    if not os.path.exists(IMAGE_DIR):
        print(f"Directory not found: {IMAGE_DIR}")
        return

    count = 0
    for filename in os.listdir(IMAGE_DIR):
        if not filename.lower().endswith(('.jpg', '.jpeg', '.png')):
            continue

        # Logic: replace underscores with spaces, capitalize words
        name_part, ext = os.path.splitext(filename)
        
        # Replace underscores with spaces
        new_name_part = name_part.replace('_', ' ')
        
        # Capitalize each word (Title Case)
        new_name_part = new_name_part.title()
        
        # Reassemble filename
        new_filename = f"{new_name_part}{ext}"
        
        # Rename if different
        if new_filename != filename:
            old_path = os.path.join(IMAGE_DIR, filename)
            new_path = os.path.join(IMAGE_DIR, new_filename)
            
            try:
                os.rename(old_path, new_path)
                print(f"Renamed: {filename} -> {new_filename}")
                count += 1
            except Exception as e:
                print(f"Error renaming {filename}: {e}")

    print(f"\nTotal renamed: {count}")

if __name__ == "__main__":
    rename_images()
