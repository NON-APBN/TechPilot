// server.js
const express = require('express');
const cors = require('cors'); // <-- PERBAIKAN: Impor library CORS
const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 3000;

// ==================================================================
// === PERBAIKAN FINAL: AKTIFKAN CORS UNTUK SEMUA PERMINTAAN ===
// Ini akan mengizinkan aplikasi Flutter (dari origin/port berbeda)
// untuk berkomunikasi dengan server Node.js ini.
app.use(cors());
// ==================================================================

// Middleware untuk parsing JSON
app.use(express.json());

// Gunakan rute API dengan prefix /api
app.use('/api', apiRoutes);

// Rute dasar
app.get('/', (req, res) => {
    res.send('✅ Server API berjalan. Akses /api/datasets untuk melihat data.');
});

// Jalankan server
app.listen(PORT, () => {
    console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
    console.log('--- Memulai pemuatan data CSV dari backend/data... ---');
});
