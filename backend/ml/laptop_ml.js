// backend/ml/laptop_ml.js
const { normalize, calculateWorthScore } = require('./shared_ml');

const CPU_SCORES = {
  'i9': 95, 'i7': 85, 'i5': 70, 'i3': 50,
  'ryzen 9': 92, 'ryzen 7': 82, 'ryzen 5': 68,
  'ultra 9': 98, 'ultra 7': 88, 'ultra 5': 75,
};

const GPU_SCORES = {
  'rtx 4090': 100, 'rtx 4080': 95, 'rtx 4070': 88, 'rtx 4060': 80,
  'rtx 3050': 60, 'radeon 780m': 55, 'iris xe': 40, 'arc': 50,
};

const WEIGHTS = {
  cpu: 0.30,
  gpu: 0.25,
  ram: 0.15,
  storage: 0.10,
  display: 0.10,
  battery: 0.05,
  weight: 0.05,
  price: 0.10,
};

function extractLaptopFeatures(device) {
  const cpu = (device.cpu || '').toLowerCase();
  const gpu = (device.gpu || '').toLowerCase();
  const ram = parseInt(device.ram || '0');
  const storage = parseInt(device.storage?.match(/(\d+)TB/)?.[1] || '0') * 1000 || parseInt(device.storage?.match(/(\d+)GB/)?.[1] || '0');
  const display = (device.display || '').toLowerCase();
  const price = parseFloat(device.price_idr || '0');
  const weight = parseFloat(device.weight_kg || '0');

  const cpuScore = CPU_SCORES[cpu.match(/(i\d|ryzen \d|ultra \d)/)?.[0] || ''] || 30;
  const gpuScore = GPU_SCORES[gpu.match(/(rtx \d+|radeon|iris|arc)/)?.[0] || ''] || 20;
  const displayScore = display.includes('oled') ? 100 : display.includes('qhd') ? 80 : display.includes('fhd') ? 60 : 40;

  return {
    cpu: normalize(cpuScore, 0, 100),
    gpu: normalize(gpuScore, 0, 100),
    ram: normalize(ram, 0, 64),
    storage: normalize(storage, 0, 4000),
    display: normalize(displayScore, 0, 100),
    battery: 0.7, // asumsi
    weight: 1 - normalize(weight, 0.8, 3.0),
    price: 1 - normalize(price, 5000000, 50000000),
  };
}

function calculateLaptopWorth(device) {
  const features = extractLaptopFeatures(device);
  return calculateWorthScore(features, WEIGHTS);
}

module.exports = { calculateLaptopWorth };