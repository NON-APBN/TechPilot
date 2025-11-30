// laptop_ml.js
const { WEIGHTS, normalize } = require('./shared_ml');

const calculateLaptopScore = (product, stats) => {
    // Pastikan kolom data sesuai dengan nama kolom di CSV Anda
    const price = parseFloat(product.price_idr);
    const cpu = parseFloat(product.cpu_benchmark);
    const gpu = parseFloat(product.gpu_benchmark);

    if (isNaN(price) || isNaN(cpu) || isNaN(gpu)) {
        return 0;
    }

    // Normalisasi Harga (Inverted = true)
    const priceScore = normalize(price, stats.price.min, stats.price.max, true);

    // Normalisasi CPU dan GPU (Inverted = false)
    const cpuScore = normalize(cpu, stats.cpu.min, stats.cpu.max, false);
    const gpuScore = normalize(gpu, stats.gpu.min, stats.gpu.max, false);

    // Hitung Worthiness Score akhir
    const finalScore = (
        (priceScore * WEIGHTS.LAPTOP.PRICE) +
        (cpuScore * WEIGHTS.LAPTOP.CPU_BENCHMARK) +
        (gpuScore * WEIGHTS.LAPTOP.GPU_BENCHMARK)
    ) / 100;

    return parseFloat(finalScore.toFixed(2));
};

module.exports = {
    calculateLaptopScore
};