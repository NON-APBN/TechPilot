const WEIGHTS = {
    // Bobot untuk Smartphone
    SMARTPHONE: {
        PRICE: 35,      // Bobot Harga (seberapa murah)
        CHIPSET_BENCHMARK: 40, // Bobot Performa (e.g., AnTuTu/GeekBench)
        CAMERA_SCORE: 25,     // Bobot Kamera (e.g., DxOMark atau skor internal)
    },
    // Bobot untuk Laptop
    LAPTOP: {
        PRICE: 30,
        CPU_BENCHMARK: 35,
        GPU_BENCHMARK: 35,
    },
    ID_FIELD: 'id_produk'
};


const normalize = (value, min, max, isInverted = false) => {
    if (min === max) return isInverted ? 100 : 0;
    const normalized = ((value - min) / (max - min)) * 100;
    return isInverted ? 100 - normalized : normalized;
};

module.exports = {
    WEIGHTS,
    normalize
};