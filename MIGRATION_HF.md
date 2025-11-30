# Panduan Migrasi ke Hugging Face Spaces 🚀

Panduan ini akan membantu Anda memindahkan backend (Node.js) dan ML Service (Python) dari Render ke **Hugging Face Spaces** untuk mendapatkan performa lebih tinggi (16GB RAM Gratis).

---

## 📋 Persiapan Awal

Saya sudah menyiapkan 2 file penting di dalam folder project Anda:
1.  `Dockerfile.ml` (Untuk Python ML Service)
2.  `Dockerfile.backend` (Untuk Node.js Backend)

Anda tidak perlu mengedit file ini lagi.

---

## 🐍 Langkah 1: Deploy Python ML Service

Kita mulai dari yang paling berat, yaitu Python ML.

1.  **Login & Buat Space**:
    *   Buka [huggingface.co/new-space](https://huggingface.co/new-space).
    *   **Space Name**: `techpilot-ml` (atau nama lain).
    *   **License**: `MIT`.
    *   **SDK**: Pilih **Docker** (Penting!).
    *   **Template**: Pilih **Blank**.
    *   **Visibility**: **Public**.
    *   Klik **Create Space**.

2.  **Upload Kode**:
    *   Setelah Space jadi, Anda akan melihat halaman instruksi.
    *   Scroll ke bawah cari bagian **"Clone this space"** atau gunakan cara upload manual via browser (Tab **Files**).
    *   **Cara Paling Mudah (Via Browser)**:
        1.  Klik tab **Files** di halaman Space Anda.
        2.  Klik **Add file** -> **Upload files**.
        3.  Drag & Drop **SEMUA** file dari folder project `TechPilot` Anda di komputer ke sana.
            *   *Tips: Upload folder `backend`, `ml_service`, `assets`, dan file-file di root.*
        4.  Tunggu proses upload selesai.
        5.  Di bagian "Commit changes", ketik pesan "Initial commit" lalu klik **Commit changes to main**.

3.  **Aktifkan Dockerfile**:
    *   Saat ini Hugging Face mencari file bernama `Dockerfile`, tapi file kita bernama `Dockerfile.ml`.
    *   Di tab **Files**, cari file `Dockerfile.ml`.
    *   Klik titik tiga (⋮) di sebelah kanan file -> **Rename**.
    *   Ubah namanya menjadi `Dockerfile` (tanpa ekstensi .ml).
    *   Klik **Commit changes**.

4.  **Tunggu Build**:
    *   Klik tab **App**. Anda akan melihat status "Building".
    *   Proses ini agak lama (3-5 menit) karena mendownload library ML yang besar.
    *   Jika sukses, status berubah jadi **Running**.

5.  **Dapatkan URL**:
    *   Di bagian atas Space, klik tombol menu (titik tiga) -> **Embed this space**.
    *   Salin **Direct URL**. Linknya biasanya seperti: `https://username-techpilot-ml.hf.space`.
    *   **Simpan URL ini!**

### Cara Alternatif: Push via Terminal (Git) - Lebih Cepat & Stabil
Jika upload via browser gagal atau macet, gunakan cara ini (mirip push ke GitHub).

1.  **Siapkan Access Token**:
    *   Buka [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens).
    *   Klik **Create new token**.
    *   Type: **Write** (Penting!).
    *   Name: `techpilot-deploy`.
    *   Copy token-nya (dimulai dengan `hf_...`).

2.  **Tambah Remote Hugging Face**:
    Buka terminal VS Code Anda, ketik:
    ```bash
    # Ganti URL di bawah dengan URL git Space Anda (ada di tombol "Clone this space")
    git remote add hf-ml https://huggingface.co/spaces/USERNAME/techpilot-ml
    ```

3.  **Push Kode**:
    ```bash
    git push hf-ml main --force
    ```
    *Saat diminta password, paste token `hf_...` yang tadi dicopy.*

---

## 🟢 Langkah 2: Deploy Node.js Backend

Sekarang kita deploy backend yang menjadi jembatan.

1.  **Buat Space Baru Lagi**:
    *   Buka [huggingface.co/new-space](https://huggingface.co/new-space).
    *   **Space Name**: `techpilot-backend`.
    *   **SDK**: **Docker**.
    *   **Visibility**: **Public**.
    *   Klik **Create Space**.

2.  **Upload Kode**:
    *   Sama seperti langkah 1, upload **SEMUA** file project `TechPilot` ke Space ini.

3.  **Aktifkan Dockerfile**:
    *   Cari file `Dockerfile.backend`.
    *   Rename menjadi `Dockerfile`.
    *   Commit changes.

4.  **Setting Environment Variable (PENTING)**:
    *   Backend Node.js perlu tahu alamat Python ML Service tadi.
    *   Klik tab **Settings** di Space `techpilot-backend`.
    *   Scroll ke bagian **Variables and secrets**.
    *   Klik **New variable**.
    *   **Name**: `PYTHON_API_URL`
    *   **Value**: Masukkan URL Python ML Service dari Langkah 1 (contoh: `https://username-techpilot-ml.hf.space`). **Hapus tanda slash (/) di akhir**.
    *   Klik **Save**.
    *   Space akan restart otomatis.

5.  **Dapatkan URL Backend**:
    *   Sama seperti tadi, ambil **Direct URL** dari menu Embed.
    *   Contoh: `https://username-techpilot-backend.hf.space`.
    *   **Simpan URL ini!**

---

## 📱 Langkah 3: Update Flutter

Terakhir, arahkan aplikasi Flutter ke backend baru.

1.  Buka VS Code di komputer Anda.
2.  Edit 3 file ini:
    *   `lib/services/api_service.dart`
    *   `lib/services/recommendation_service.dart`
    *   `lib/cubit/ai_assistant_cubit.dart`
3.  Ganti URL lama (`https://techpilot-backend.onrender.com/api`) menjadi URL baru (`https://username-techpilot-backend.hf.space/api`).
4.  **Deploy Ulang ke Vercel**:
    ```bash
    flutter build web --release
    vercel deploy build/web --prod
    ```

**SELESAI!** 🎉
Sekarang aplikasi Anda berjalan di server "monster" 16GB RAM. Selamat tinggal error 502!
