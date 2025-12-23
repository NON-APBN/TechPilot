// D:\Codingan\TechPilot\backend\csv_loader.js

const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const { calculateSmartphoneScore } = require('./ml/smartphone_ml');
const { calculateLaptopScore } = require('./ml/laptop_ml');

// Variabel Cache Data
let smartphones = [];
let laptops = [];

// Lokasi Data
const DATA_DIR = path.join(__dirname, 'data');
const SMARTPHONE_FILE = path.join(DATA_DIR, 'ALL_SMARTPHONES_MERGED.csv');
const LAPTOP_FILE = path.join(DATA_DIR, 'laptops_all_indonesia_fixed_v7.csv');

// DAFTAR LENGKAP FILE BENCHMARK YANG PERLU DIMUAT
const CHIPSET_BENCHMARKS = [
    'benchmark_chipset_mediatek.csv',
    'benchmark_chipset_exynos.csv',  
    'benchmark_chipset_kirin.csv',
    'benchmark_chipset_snapdragon.csv',
    'benchmark_chipset_unisoc.csv',
    'benchmark_chipset_Apple.csv'
];

const CPU_BENCHMARKS = [
    'benchmark_prosesor_amd.csv',
    'benchmark_prosesor_snapdragon.csv',
    'benchmark_prosesor_intel.csv',
    'benchmark_prosesor_Apple_M_series.csv'
];

const GPU_BENCHMARKS = [
    'benchmark_GPU_AMD.csv',
    'benchmark_GPU_Nvidia.csv'
];

// --- FUNGSI UTILITY (Tidak Berubah) ---

const cleanNumericValue = (str) => {
    if (!str) return NaN;
    const cleaned = str.toString().replace(/[^0-9.]/g, '');
    return parseFloat(cleaned) || NaN;
};

const cleanBenchmarkScore = (text) => {
    if (!text || typeof text !== 'string') return NaN;
    const match = text.match(/\d+/g);
    return match ? parseFloat(match[0]) : NaN;
};

const getMinMaxStats = (data, fields) => {
    const stats = {};
    fields.forEach(field => {
        const values = data.map(item => item[field]).filter(v => !isNaN(v));
        if (values.length > 0) {
            stats[field] = {
                min: Math.min(...values),
                max: Math.max(...values)
            };
        } else {
            stats[field] = { min: 0, max: 1 };
        }
    });
    return stats;
};

function loadCSV(filePath) {
    return new Promise((resolve, reject) => {
        const results = [];
        fs.createReadStream(filePath)
          .pipe(csv())
          .on('data', (data) => results.push(data))
          .on('end', () => {
              console.log(`[CSV Loader] ${path.basename(filePath)} dimuat, total baris: ${results.length}`);
              resolve(results);
          })
          .on('error', reject);
    });
}

// --- FUNGSI MERGE BENCHMARK ---

const mergeBenchmarkData = (mainData, benchmarkMap, keyColumnMain, keyColumnBenchmark, scoreColumn, prefix) => {
    const lookupMap = new Map();
    benchmarkMap.forEach(item => {
        const key = item[keyColumnBenchmark].toLowerCase().trim();
        // Asumsi kolom skor adalah 'score' di semua file benchmark
        lookupMap.set(key, cleanNumericValue(item[scoreColumn]));
    });

    return mainData.map(item => {
        const mainKey = item[keyColumnMain] ? item[keyColumnMain].toLowerCase().trim() : '';
        const score = lookupMap.get(mainKey);

        // Gunakan prefix untuk menghindari konflik nama (misal: Benchmark_Chipset_score)
        item[`Benchmark_${prefix}_score`] = score;
        return item;
    });
};

// --- FUNGSI UTAMA LOAD DATA ---

async function loadAllData() {
    try {
        // 1. MUAT SEMUA DATA BENCHMARK (Disatukan)
        let allChipsetData = [];
        for (const file of CHIPSET_BENCHMARKS) {
            allChipsetData = allChipsetData.concat(await loadCSV(path.join(DATA_DIR, file)));
        }

        let allCPUData = [];
        for (const file of CPU_BENCHMARKS) {
            allCPUData = allCPUData.concat(await loadCSV(path.join(DATA_DIR, file)));
        }

        let allGPUData = [];
        for (const file of GPU_BENCHMARKS) {
            allGPUData = allGPUData.concat(await loadCSV(path.join(DATA_DIR, file)));
        }

        // 2. MUAT DATA UTAMA
        let rawSmartphones = await loadCSV(SMARTPHONE_FILE);
        let rawLaptops = await loadCSV(LAPTOP_FILE);

        // 3. CLEANING & PRE-PROSES DATA UTAMA
        let cleanedSmartphones = rawSmartphones.map(p => ({
            ...p,
            Cleaned_Price: cleanNumericValue(p.Final_Price_IDR || p.Estimated_Price),
            Cleaned_Camera: cleanNumericValue(p.DxOMark_Score || p.MainCamera_Video),
            // Ambil nama Chipset untuk kunci merge
            ChipsetName: p.Platform_Chipset ? p.Platform_Chipset.split(',')[0].trim() : ''
        })).filter(p => !isNaN(p.Cleaned_Price));

        let cleanedLaptops = rawLaptops.map(p => ({
            ...p,
            Cleaned_Price: cleanNumericValue(p.price_idr),
            CPUName: p.Platform_CPU ? p.Platform_CPU.split(',')[0].trim() : '',
            GPUName: p.Platform_GPU ? p.Platform_GPU.split(',')[0].trim() : ''
        })).filter(p => !isNaN(p.Cleaned_Price));

        // 4. LAKUKAN MERGE DATA BENCHMARK

        // Merge Chipset ke Smartphone
        cleanedSmartphones = mergeBenchmarkData(
            cleanedSmartphones, allChipsetData, 'ChipsetName', 'ChipsetName', 'score', 'Chipset'
        );

        // Merge CPU ke Laptop
        cleanedLaptops = mergeBenchmarkData(
            cleanedLaptops, allCPUData, 'CPUName', 'ProcessorName', 'score', 'CPU'
        );

        // Merge GPU ke Laptop
        cleanedLaptops = mergeBenchmarkData(
            cleanedLaptops, allGPUData, 'GPUName', 'GPUName', 'score', 'GPU'
        );


        // 5. DAPATKAN STATISTIK MIN/MAX
        const phoneStats = getMinMaxStats(cleanedSmartphones, ['Cleaned_Price', 'Benchmark_Chipset_score', 'Cleaned_Camera']);
        const laptopStats = getMinMaxStats(cleanedLaptops, ['Cleaned_Price', 'Benchmark_CPU_score', 'Benchmark_GPU_score']);

        // 6. HITUNG WORTHINESS SCORE DAN CACHE
        smartphones = cleanedSmartphones.map(p => ({
            ...p,
            worthiness_score: calculateSmartphoneScore(p, {
                price: phoneStats.Cleaned_Price,
                benchmark: phoneStats.Benchmark_Chipset_score,
                camera: phoneStats.Cleaned_Camera
            })
        }));

        laptops = cleanedLaptops.map(p => ({
            ...p,
            worthiness_score: calculateLaptopScore(p, {
                price: laptopStats.Cleaned_Price,
                cpu: laptopStats.Benchmark_CPU_score,
                gpu: laptopStats.Benchmark_GPU_score
            })
        }));

        console.log(`[CSV Loader] Data Smartphone yang Valid: ${smartphones.length}. Data Laptop yang Valid: ${laptops.length}.`);

    } catch (error) {
        console.error('Gagal memuat atau memproses data CSV:', error);
        throw error;
    }
}

// Ekspor fungsi pemuatan dan Getter data
module.exports = {
    loadAllData,
    getSmartphones: () => smartphones,
    getLaptops: () => laptops,
    cleanNumericValue // Diekspor untuk digunakan di routes/api.js
};