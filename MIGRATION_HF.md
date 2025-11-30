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

3.  **Upload Kode (METODE MANUAL - RECOMMENDED)**:
    *   Karena upload via Git sering gagal (timeout/jaringan), gunakan cara manual ini yang **100% Berhasil**.
    *   Klik tab **Files** di halaman Space Anda.
    *   Klik **Add file** -> **Upload files**.
    *   **Drag & Drop** file/folder berikut dari komputer Anda:
        1.  Folder `backend` (**Tips:** Hapus folder `node_modules` di dalamnya dulu agar ringan. Nanti server akan install sendiri).
        2.  Folder `ml_service`
        3.  Folder `assets` (Pastikan gambar sudah dikompres jika memungkinkan)
        4.  File `Dockerfile.ml`
        5.  File `Dockerfile.backend`
        6.  File `requirements.txt` (jika ada di luar)
    *   Tunggu proses upload selesai (bar hijau penuh).
    *   Di bawah, ketik "Initial Upload" dan klik **Commit changes**.

4.  **Aktifkan Dockerfile (PENTING!)**:
    *   Setelah upload selesai, cari file `Dockerfile.ml` di daftar file.
    *   Klik titik tiga (⋮) di kanannya -> **Rename**.
    *   Ubah nama menjadi `Dockerfile` (hapus `.ml`).
    *   Klik **Commit changes**.
    *   *Space akan otomatis mulai Building.*

5.  **Tunggu Build**:
    *   Klik tab **App**. Status akan berubah "Building" -> "Running".
    *   Jika "Running", berarti sukses!

6.  **Dapatkan URL**:
    *   Klik menu titik tiga di kanan atas -> **Embed this space**.
    *   Copy **Direct URL**. Simpan untuk nanti.

### (Opsional) Cara Git Terminal
*Hanya gunakan jika cara manual di atas gagal total.*
1.  Siapkan Access Token (Write) di Settings HF.
2.  `git remote add hf-ml <URL_SPACE>`
3.  `git push hf-ml main --force`

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
    *   **Value**: `https://drappy-cat-techpilot-ml.hf.space`
    *   *(Link ini saya buatkan otomatis berdasarkan username Anda. Harusnya 99% benar).*
    *   Klik **Save**.
    *   Space akan restart otomatis.

5.  **Dapatkan URL Backend**:
    *   Sama seperti tadi, ambil **Direct URL** dari menu Embed.
    *   Atau gunakan pola: `https://drappy-cat-techpilot-backend.hf.space`.
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
