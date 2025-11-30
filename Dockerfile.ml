# Gunakan Python 3.9 Slim (Ringan)
FROM python:3.9-slim

# Set working directory di dalam container
WORKDIR /app

# Install dependencies sistem yang mungkin dibutuhkan (opsional tapi aman)
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements.txt dari folder ml_service
COPY ml_service/requirements.txt ml_service/requirements.txt

# Install library Python
RUN pip install --no-cache-dir -r ml_service/requirements.txt

# Copy seluruh kode project (termasuk backend/data dan assets)
# Ini PENTING karena kode Python Anda mengakses ../backend/data
COPY . .

# Expose port 7860 (Port default Hugging Face Spaces)
EXPOSE 7860

# Set environment variable agar Flask/Gunicorn tahu portnya
ENV PORT=7860

# Jalankan aplikasi menggunakan Gunicorn
# Perhatikan path-nya: ml_service.app2:app
CMD ["gunicorn", "ml_service.app2:app", "--bind", "0.0.0.0:7860", "--timeout", "120"]
