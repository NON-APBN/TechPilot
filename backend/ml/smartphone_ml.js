// samrtphone_ml.js
const { WEIGHTS, normalize } = require('./shared_ml');

const calculateSmartphoneScore = (product, stats) => {
    // Pastikan kolom data sesuai dengan nama kolom di CSV Anda
    const price = parseFloat(product.price_idr);
    const benchmark = parseFloat(product.benchmark_score);
    const camera = parseFloat(product.camera_score);

    if (isNaN(price) || isNaN(benchmark) || isNaN(camera)) {
        return 0; // Kembalikan 0 jika data tidak valid
    }

    // 1. Normalisasi Harga (Skor rendah lebih baik, jadi Inverted = true)
    const priceScore = normalize(price, stats.price.min, stats.price.max, true);

    // 2. Normalisasi Benchmark (Skor tinggi lebih baik, jadi Inverted = false)
    const benchmarkScore = normalize(benchmark, stats.benchmark.min, stats.benchmark.max, false);

    // 3. Normalisasi Kamera (Skor tinggi lebih baik)
    const cameraScore = normalize(camera, stats.camera.min, stats.camera.max, false);

    // 4. Hitung Worthiness Score akhir dengan bobot
    const finalScore = (
        (priceScore * WEIGHTS.SMARTPHONE.PRICE) +
        (benchmarkScore * WEIGHTS.SMARTPHONE.CHIPSET_BENCHMARK) +
        (cameraScore * WEIGHTS.SMARTPHONE.CAMERA_SCORE)
    ) / 100; // Dibagi 100 karena total bobot 100

    return parseFloat(finalScore.toFixed(2)); // Bulatkan 2 angka desimal
};

module.exports = {
    calculateSmartphoneScore
};