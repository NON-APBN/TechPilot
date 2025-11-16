// backend/ml/smartphone_ml.js
const { normalize, calculateWorthScore } = require('./shared_ml');

const WEIGHTS = {
  antutu: 0.35,
  ram: 0.15,
  storage: 0.10,
  battery: 0.12,
  camera: 0.18,
  price: 0.10,
};

function extractSmartphoneFeatures(device) {
  const antutu = parseInt(device['OurTests_Performance']?.match(/AnTuTu: (\d+)/)?.[1] || '0') || 0;
  const ram = parseInt(device['Memory_Internal']?.match(/(\d+)GB/)?.[1] || '0');
  const storage = parseInt(device['Memory_Internal']?.match(/(\d+)GB/)?.[1] || '0');
  const battery = parseInt(device['Battery_Type']?.match(/(\d+) mAh/)?.[1] || '0');
  const camera = parseInt(device['MainCamera_Single']?.match(/(\d+) MP/)?.[1] || '0');
  const price = parseFloat(device['Misc_Price']?.replace(/[^\d.]/g, '') || '0');

  return {
    antutu: normalize(antutu, 0, 1500000),
    ram: normalize(ram, 0, 24),
    storage: normalize(storage, 0, 2000),
    battery: normalize(battery, 0, 7000),
    camera: normalize(camera, 0, 200),
    price: 1 - normalize(price, 1000000, 30000000), // lebih murah = lebih baik
  };
}

function calculateSmartphoneWorth(device) {
  const features = extractSmartphoneFeatures(device);
  return calculateWorthScore(features, WEIGHTS);
}

module.exports = { calculateSmartphoneWorth };