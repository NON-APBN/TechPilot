# Panduan Lengkap Deployment TechPilot (Full Stack)

Dokumen ini adalah panduan langkah demi langkah yang sangat detail untuk men-deploy aplikasi TechPilot (Python, Node.js, dan Flutter) menggunakan layanan gratis **Render** dan **Vercel**.

---

## 📋 Prasyarat (Wajib Ada)

Sebelum memulai, pastikan Anda memiliki hal-hal berikut:
1.  **Akun GitHub**: Kode Anda harus ada di GitHub.
2.  **Akun Render**: Daftar di [render.com](https://render.com) (Login with GitHub).
3.  **Akun Vercel**: Daftar di [vercel.com](https://vercel.com) (Login with GitHub).
4.  **Git & Flutter**: Terinstall di komputer Anda.
5.  **Koneksi Internet Stabil**: Untuk upload dan download data.

---

## 🏗️ Arsitektur Sistem (Status: LIVE)

Saat ini backend Anda sudah online:
*   **Python ML**: `https://techpilot-ml.onrender.com`
*   **Node.js Backend**: `https://techpilot-backend.onrender.com`

Kita tinggal men-deploy **Frontend (Flutter)**.

---

## 🚀 Langkah 1: Update Kode Flutter (Sudah Dilakukan)

Saya sudah mengupdate kode Flutter Anda untuk menggunakan URL backend yang baru.
*   `api_service.dart` -> Mengarah ke `https://techpilot-backend.onrender.com/api`
*   `recommendation_service.dart` -> Mengarah ke `https://techpilot-backend.onrender.com/api`
*   `ai_assistant_cubit.dart` -> Mengarah ke `https://techpilot-backend.onrender.com/api`

**Tugas Anda:**
Push perubahan ini ke GitHub agar Vercel bisa mengambil kode terbaru.
```bash
git add .
git commit -m "Update API URL for production"
git push origin main
```

---

## 🌐 Langkah 2: Deploy Flutter Web (di Vercel)

Kita akan menggunakan Vercel untuk hosting karena gratis, cepat, dan mudah.

### Cara 1: Menggunakan Vercel CLI (Paling Cepat & Direkomendasikan)
Jika Anda sudah menginstall Node.js, cara ini paling praktis.

1.  **Build Aplikasi Web**:
    Buka terminal di folder proyek TechPilot, jalankan:
    ```bash
    flutter build web --release
    ```
    *Tunggu sampai selesai. Hasilnya ada di folder `build/web`.*

2.  **Install Vercel CLI** (jika belum):
    ```bash
    npm install -g vercel
    ```

3.  **Deploy**:
    Jalankan perintah ini di terminal:
    ```bash
    vercel deploy build/web --prod
    ```

4.  **Jawab Pertanyaan**:
    *   Set up and deploy? `y`
    *   Which scope? (Enter saja)
    *   Link to existing project? `n`
    *   Project name? `techpilot-web` (atau nama lain yang Anda suka)
    *   In which directory? (Enter saja, karena kita sudah menunjuk folder `build/web` di perintah awal)

5.  **Selesai!**
    Vercel akan memberikan URL website Anda (contoh: `https://techpilot-web.vercel.app`). Buka URL tersebut di browser.

### Cara 2: Menggunakan Dashboard Vercel (Alternatif)
Jika Cara 1 gagal atau Anda tidak mau pakai terminal.

Menggunakan layanan gratis (Free Tier) memiliki konsekuensi. Berikut detailnya agar Anda paham ekspektasinya.

### ✅ Kelebihan (Pros)
1.  **Biaya Nol Rupiah (Rp 0)**: Sangat ideal untuk tahap pengembangan, belajar, tugas kuliah, atau portofolio.
2.  **Infrastruktur Kelas Dunia**: Render dan Vercel menggunakan teknologi cloud modern yang stabil.
3.  **Keamanan Terjamin (SSL/HTTPS)**: Website otomatis aman.
4.  **Otomatisasi (CI/CD)**: Integrasi Git memudahkan update.

### ❌ Kekurangan & Risiko (Cons)
1.  **Masalah "Cold Start" (Paling Terasa)**: Server tidur jika tidak dipakai 15 menit. Loading awal bisa 30-60 detik.
2.  **Performa Terbatas**: CPU/RAM kecil, rawan crash jika banyak user.
3.  **Batasan Penggunaan Bulanan**: Ada kuota jam/bandwidth.
4.  **Domain Kurang Profesional**: Menggunakan subdomain `.onrender.com`.

---

## 💡 Alternatif Hosting Gratis Lainnya (Rekomendasi Spesial)

### 1. Hugging Face Spaces (Sangat Direkomendasikan untuk ML & Node.js) 🏆
Ini adalah "surga" untuk hosting model AI/ML secara gratis.
*   **Kelebihan**: Gratis **16 GB RAM** & 2 vCPU! (Jauh lebih besar dari Render yang cuma 512 MB).
*   **Kekurangan**: Setup sedikit berbeda (harus buat repo di Hugging Face), dan akan "tidur" setelah 48 jam tidak aktif (tapi bangunnya cepat).
*   **Cocok untuk**: Service Python ML Anda (`ml_service`) DAN Node.js Backend.
*   **Cara**: Anda cukup daftar di [huggingface.co](https://huggingface.co), buat "New Space", pilih SDK "Docker", lalu upload kode Python Anda di sana.

#### Apakah bisa untuk Node.js?
**BISA!** Hugging Face Spaces mendukung Docker. Jadi kita bisa membuat `Dockerfile` untuk Node.js dan mendeploynya di sana.

#### Ketentuan & Cara Pindah ke Hugging Face:
1.  **Buat Akun**: Daftar di [huggingface.co](https://huggingface.co).
2.  **Buat Space Baru**:
    *   Klik **New Space**.
    *   Beri nama (misal: `techpilot-backend`).
    *   Pilih SDK: **Docker**.
    *   Pilih License: **MIT** (atau sesuai keinginan).
    *   Visibility: **Public** (Gratis) atau Private (Berbayar). *Catatan: Jika Public, kode Anda bisa dilihat orang lain.*
3.  **Upload Kode**:
    *   Hugging Face bekerja seperti Git. Anda akan diberi perintah git untuk clone space tersebut.
    *   Copy file `backend/` Anda ke folder space tersebut.
    *   Buat file `Dockerfile` di root space tersebut (Isinya instruksi install Node.js).
    *   Push ke Hugging Face.

### 2. Fly.io
*   **Kelebihan**: Server sangat cepat, lokasi bisa di Singapore.
*   **Kekurangan**: Free tier-nya sekarang butuh kartu kredit (walaupun tidak ditagih jika di bawah batas). RAM standar kecil (256MB), tapi bisa burst.

### 3. Oracle Cloud "Always Free" (The Holy Grail) 💎
*   **Kelebihan**: Gratis **24 GB RAM** dan **4 ARM CPU**. Ini spesifikasi "monster" yang gratis selamanya.
*   **Kekurangan**: **Sangat sulit mendaftar**. Sering menolak kartu kredit Indonesia tanpa alasan jelas. Setup server manual (VPS Linux).

---

## 💎 Rekomendasi Deployment Berbayar (Production Grade)

Jika Anda ingin serius menjalankan TechPilot sebagai bisnis atau startup, berikut adalah saran infrastruktur yang **kuat, stabil, dan profesional**.

### 1. Spesifikasi Server yang Disarankan (Minimum)
Aplikasi TechPilot menggunakan Machine Learning (Python Pandas & Scikit-Learn) yang **rakus memori (RAM)**.
*   **RAM**: Wajib **minimal 2 GB**. (1 GB mungkin cukup tapi berisiko *Out of Memory* saat load model berat).
*   **CPU**: **2 vCPU** (Agar proses search & rekomendasi tidak antre lama).
*   **Storage**: 25 GB SSD/NVMe (Cukup untuk kode & data CSV).

### 2. Opsi Provider Terbaik

#### A. Opsi Paling Mudah (PaaS) - Upgrade Render
Jika Anda tidak mau pusing setting server (Linux/Docker), cukup upgrade akun Render Anda.
*   **Layanan**: Render "Team" / "Individual Paid".
*   **Paket**:
    *   **Python Service**: Instance Type **"Starter"** ($7/bulan) atau **"Standard"** ($25/bulan). *Starter sudah menghilangkan Cold Start, tapi RAM hanya 512MB (agak riskan). Standard (2GB RAM) sangat direkomendasikan.*
    *   **Node.js Service**: Instance Type **"Starter"** ($7/bulan).
*   **Total Biaya**: ~$14 - $32 / bulan.
*   **Kelebihan**: Tidak perlu migrasi, tinggal klik upgrade. Maintenance 0%.

#### B. Opsi Performa Tinggi & Hemat (VPS) - DigitalOcean / IDCloudHost
Jika Anda bisa sedikit teknis (setup Linux), ini opsi paling *worth it*.
*   **Provider**: **DigitalOcean** (Global) atau **IDCloudHost** (Lokal Indonesia - Latency sangat rendah).
*   **Spesifikasi (Droplet/VM)**: 2 vCPU / 2GB RAM.
*   **Biaya**: ~$12 - $15 / bulan.
*   **Kelebihan**: Anda dapat resource dedicated. Jauh lebih kencang daripada PaaS dengan harga sama.
*   **Cara Deploy**: Install Docker & Docker Compose di VPS, lalu jalankan semua service (Python, Node, Nginx) dalam satu server.

#### C. Opsi Alternatif (Railway.app)
Mirip Render tapi sistem bayarnya "Pay as you go" (Bayar yang dipakai saja).
*   **Kelebihan**: Seringkali lebih murah untuk traffic kecil-menengah karena hitungannya per menit & resource usage.
*   **Fitur**: UI sangat bagus, deploy mudah.

### Kesimpulan Saran
*   **Untuk Coba-coba/Portofolio**: Gunakan **Render Free Tier** (seperti panduan di atas).
*   **Untuk Production (User < 100/hari)**: Upgrade ke **Render Starter** ($7) atau **Railway**.
*   **Untuk Bisnis Serius (User > 1000/hari)**: Sewa **VPS (DigitalOcean/IDCloudHost)** dengan spek 2GB RAM ke atas.
