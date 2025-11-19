// routes/api.js
const express = require('express');
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const axios = require('axios'); // Pastikan sudah: npm install axios

const router = express.Router();

// =========================================================================
// === INI ADALAH LOGIKA DEPLOYMENT ===
// Ia akan otomatis menggunakan URL Render (jika ada) atau localhost (jika tidak ada)
const PYTHON_URL = process.env.PYTHON_API_URL || 'http://localhost:5000';
// =========================================================================

// Objek ini akan menampung SEMUA data dari SEMUA file CSV
let loadedDatasets = {};

// Path ke direktori data - Menggunakan versi Anda yang sudah terbukti benar
// (Karena Anda menjalankan 'node server.js' dari dalam folder 'backend')
const DATA_DIR = path.join(process.cwd(), 'data');

/**
 * Fungsi Asynchronous untuk memuat semua file CSV dari direktori data
 */
async function loadAllCsvData() {
    console.log(`--- [INFO] Memulai pemindaian direktori: ${DATA_DIR}`);
    try {
        if (!fs.existsSync(DATA_DIR)) {
            console.error(`!!! [ERROR] Direktori data tidak ditemukan di: ${DATA_DIR}`);
            return;
        }
        const files = await fs.promises.readdir(DATA_DIR);
        const csvFiles = files.filter(file => file.endsWith('.csv'));
        if (csvFiles.length === 0) {
            console.warn(`!!! [WARN] Tidak ada file .csv yang ditemukan di ${DATA_DIR}`);
            return;
        }
        console.log(`--- [INFO] Menemukan ${csvFiles.length} file CSV. Memulai pemuatan...`);
        for (const fileName of csvFiles) {
            const filePath = path.join(DATA_DIR, fileName);
            const data = [];
            await new Promise((resolve, reject) => {
                fs.createReadStream(filePath)
                    .pipe(csv())
                    .on('data', (row) => data.push(row))
                    .on('end', () => {
                        const datasetKey = path.basename(fileName, '.csv');
                        loadedDatasets[datasetKey] = data;
                        console.log(`--- [SUCCESS] ${fileName} dimuat (${data.length} baris). Disimpan ke key: '${datasetKey}'`);
                        resolve();
                    })
                    .on('error', (err) => {
                        console.error(`--- [ERROR] Gagal memuat ${fileName}: ${err.message}`);
                        reject(err);
                    });
            });
        }
        console.log("--- [SUCCESS] Semua dataset CSV telah berhasil dimuat ke memori.");
    } catch (err) {
        console.error(`!!! [ERROR] Gagal memuat data: ${err.message}`);
    }
}

// Jalankan fungsi pemuat data saat server dimulai
loadAllCsvData();

// --- ENDPOINTS API (Data Mentah) ---
router.get('/datasets', (req, res) => {
    const datasetKeys = Object.keys(loadedDatasets);
    res.status(200).json({
        message: `Berhasil menemukan ${datasetKeys.length} dataset.`,
        datasets: datasetKeys
    });
});

router.get('/data/:datasetName', (req, res) => {
    const datasetName = req.params.datasetName;
    const data = loadedDatasets[datasetName];
    if (data) {
        res.status(200).json({ source: `${datasetName}.csv`, count: data.length, data: data });
    } else {
        res.status(404).json({
            message: `Dataset tidak ditemukan.`,
            error: `Key '${datasetName}' tidak ada di memori.`,
            available_datasets: Object.keys(loadedDatasets)
        });
    }
});


// --- ENDPOINTS REKOMENDASI (Memanggil Python) ---
// Ini adalah versi dinamis yang menangani laptops DAN smartphones

/**
 * Endpoint Dinamis untuk Rekomendasi
 * GET /api/recommend/laptops?min=5000000&max=10000000
 * GET /api/recommend/smartphones?min=3000000&max=5000000
 */
router.get('/recommend/:type', async (req, res) => {
    const { type } = req.params; // 'laptops' or 'smartphones'

    // Validasi tipe
    if (type !== 'laptops' && type !== 'smartphones') {
        return res.status(400).json({ message: "Tipe tidak valid. Gunakan 'laptops' atau 'smartphones'." });
    }

    try {
        const minPrice = parseInt(req.query.min) || 0;
        const maxPrice = parseInt(req.query.max) || 100000000;

        const payload = {
            min_price: minPrice,
            max_price: maxPrice,
            type: type === 'laptops' ? 'laptop' : 'smartphone' // Sesuaikan dengan API Python
        };

        // Memanggil server Python (baik localhost ATAU Render)
        console.log(`[Node.js] Meneruskan permintaan ke: ${PYTHON_URL}/recommend`);

        const pythonResponse = await axios.post(
            `${PYTHON_URL}/recommend`,
            payload
        );

        console.log('[Node.js] Menerima jawaban dari Python.');
        res.status(200).json(pythonResponse.data);

    } catch (error) {
        console.error("[Node.js] Error saat memanggil Python Service:", error.message);
        res.status(500).json({
            message: "Gagal memproses rekomendasi. Pastikan ML service (Python) berjalan.",
            error: error.message
        });
    }
});

// Endpoint /items lama Anda (jika masih diperlukan)
router.get('/items', (req, res) => {
    const data = loadedDatasets['ALL_SMARTPHONES_MERGED'];
    if (data) {
        res.status(200).json({
            source: 'ALL_SMARTPHONES_MERGED.csv',
            count: data.length,
            data: data
        });
    } else {
        res.status(404).json({
            message: 'Dataset ALL_SMARTPHONES_MERGED tidak (atau belum) dimuat.'
        });
    }
});

module.exports = router;