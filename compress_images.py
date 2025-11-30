import os
from PIL import Image

def compress_images(directory, max_width=1000, quality=75):
    print(f"Starting compression in {directory}...")
    total_saved = 0
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.lower().endswith(('.png', '.jpg', '.jpeg', '.webp')):
                file_path = os.path.join(root, file)
                try:
                    original_size = os.path.getsize(file_path)
                    
                    # Skip small files (< 500KB)
                    if original_size < 500 * 1024:
                        continue

                    img = Image.open(file_path)
                    
                    # Resize if too big
                    if img.width > max_width:
                        ratio = max_width / img.width
                        new_height = int(img.height * ratio)
                        img = img.resize((max_width, new_height), Image.Resampling.LANCZOS)
                    
                    # Save back
                    # Convert to RGB if necessary (for JPG)
                    if img.mode in ("RGBA", "P") and file.lower().endswith(('.jpg', '.jpeg')):
                        img = img.convert("RGB")
                        
                    img.save(file_path, optimize=True, quality=quality)
                    
                    new_size = os.path.getsize(file_path)
                    saved = original_size - new_size
                    if saved > 0:
                        total_saved += saved
                        print(f"Compressed {file}: {original_size/1024:.1f}KB -> {new_size/1024:.1f}KB (Saved {saved/1024:.1f}KB)")
                    
                except Exception as e:
                    print(f"Error processing {file}: {e}")

    print(f"\nTotal space saved: {total_saved / (1024*1024):.2f} MB")

if __name__ == "__main__":
    # Install Pillow if missing: pip install Pillow
    compress_images("assets/images")
