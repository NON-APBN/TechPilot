// server.js
const express = require('express');
const cors = require('cors');
const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 3000;
app.use(cors());

// Middleware untuk parsing JSON
app.use(express.json());

// Simple logging middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

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
