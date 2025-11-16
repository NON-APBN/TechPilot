// server.js
const express = require('express');
const apiRoutes = require('./routes/api'); // Import rute dari folder routes

const app = express();
const PORT = 3000;

// Middleware untuk parsing JSON
app.use(express.json());

// Gunakan rute API dengan prefix /api
// Semua rute di api.js akan diawali dengan /api
app.use('/api', apiRoutes);

// Rute dasar
app.get('/', (req, res) => {
    res.send('✅ Server API berjalan. Akses /api/datasets untuk melihat data.');
});

// Jalankan server
app.listen(PORT, () => {
    console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
    console.log('--- Memulai pemuatan data CSV dari backend/data... ---');
    // Proses loading akan dimulai oleh file api.js
});