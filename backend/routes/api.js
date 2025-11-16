// routes/api.js
const express = require('express');
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser'); // Pastikan sudah: npm install csv-parser

const router = express.Router();

// Objek ini akan menampung SEMUA data dari SEMUA file CSV
// Contoh: { "ALL_SMARTPHONES_MERGED": [ ...data ], "laptops_all_indonesia_fixed_v7": [ ...data ] }
let loadedDatasets = {};

// Path ke direktori data, diasumsikan server.js ada di root
const DATA_DIR = path.join(process.cwd(), 'data');

/**
 * Fungsi Asynchronous untuk memuat semua file CSV dari direktori data
 */
async function loadAllCsvData() {
    console.log(`--- [INFO] Memulai pemindaian direktori: ${DATA_DIR}`);

    try {
        // 1. Cek apakah direktori ada
        if (!fs.existsSync(DATA_DIR)) {
            console.error(`!!! [ERROR] Direktori data tidak ditemukan di: ${DATA_DIR}`);
            console.error("!!! [ERROR] Pastikan folder 'backend/data' ada di root proyek Anda.");
            return;
        }

        // 2. Baca semua file di dalam DATA_DIR
        const files = await fs.promises.readdir(DATA_DIR);

        // 3. Filter hanya file yang berakhiran .csv
        const csvFiles = files.filter(file => file.endsWith('.csv'));

        if (csvFiles.length === 0) {
            console.warn(`!!! [WARN] Tidak ada file .csv yang ditemukan di ${DATA_DIR}`);
            return;
        }

        console.log(`--- [INFO] Menemukan ${csvFiles.length} file CSV. Memulai pemuatan...`);

        // 4. Loop setiap file CSV dan muat datanya
        for (const fileName of csvFiles) {
            const filePath = path.join(DATA_DIR, fileName);
            const data = [];

            // Bungkus stream dalam Promise agar bisa ditunggu (await)
            await new Promise((resolve, reject) => {
                fs.createReadStream(filePath)
                    .pipe(csv())
                    .on('data', (row) => {
                        data.push(row);
                    })
                    .on('end', () => {
                        // Buat key dari nama file, hilangkan .csv
                        const datasetKey = path.basename(fileName, '.csv');

                        // Simpan data ke objek utama
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

// --- ENDPOINTS API ---

/**
 * Endpoint [GET] /api/datasets
 * Mengembalikan daftar semua dataset (nama file) yang berhasil dimuat.
 */
router.get('/datasets', (req, res) => {
    const datasetKeys = Object.keys(loadedDatasets);
    res.status(200).json({
        message: `Berhasil menemukan ${datasetKeys.length} dataset.`,
        datasets: datasetKeys
    });
});

/**
 * Endpoint Dinamis [GET] /api/data/:datasetName
 * Mengembalikan data spesifik berdasarkan nama dataset (key).
 * Contoh: /api/data/laptops_all_indonesia_fixed_v7
 */
router.get('/data/:datasetName', (req, res) => {
    const datasetName = req.params.datasetName;
    const data = loadedDatasets[datasetName];

    if (data) {
        res.status(200).json({
            source: `${datasetName}.csv`,
            count: data.length,
            data: data
        });
    } else {
        res.status(404).json({
            message: `Dataset tidak ditemukan.`,
            error: `Key '${datasetName}' tidak ada di memori.`,
            available_datasets: Object.keys(loadedDatasets)
        });
    }
});

/**
 * Endpoint [GET] /api/items
 * Alias untuk dataset 'ALL_SMARTPHONES_MERGED'
 */
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