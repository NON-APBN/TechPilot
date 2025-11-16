// backend/server.js
const express = require('express');
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json({ limit: '50mb' }));

const PORT = process.env.PORT || 3000;
const IDR_TO_EUR = parseInt(process.env.IDR_TO_EUR) || 17000;

// GLOBAL DATA & MAX VALUES
let smartphones = [];
let laptops = [];

let maxAntutu = 1, maxRam = 1, maxBattery = 1, maxDxomark = 1, minPrice = Infinity;
let maxCinebenchMulti = 1, max3DMarkGraphics = 1;

// CSV FILE LISTS
const CHIPSET_FILES = [
  'benchmark_chipset_apple.csv',
  'benchmark_chipset_exynos.csv',
  'benchmark_chipset_kirin.csv',
  'benchmark_chipset_mediatek.csv',
  'benchmark_chipset_snapdragon.csv',
  'benchmark_chipset_unisoc.csv'
];

const CPU_FILES = [
  'benchmark_prosesor_amd.csv',
  'benchmark_prosesor_Apple_M_series.csv',
  'benchmark_prosesor_intel.csv',
  'benchmark_prosesor_snapdragon.csv'
];

const GPU_FILES = [
  'benchmark_GPU_AMD.csv',
  'benchmark_GPU_Nvidia.csv'
];

const OTHER_FILES = {
  dxomark: 'benchmark_camera_dxomark.csv'
};

// HELPER: Load CSV
function loadCSV(filename, callback) {
  const filePath = path.join(__dirname, 'data', filename);
  const data = [];

  if (!fs.existsSync(filePath)) {
    console.warn(`File not found: ${filename}`);
    return callback(data);
  }

  fs.createReadStream(filePath)
    .pipe(csv())
    .on('data', (row) => {
      Object.keys(row).forEach(k => row[k] = (row[k] || '').trim());
      data.push(row);
    })
    .on('end', () => {
      console.log(`Loaded ${data.length} rows from ${filename}`);
      callback(data);
    })
    .on('error', (err) => {
      console.error(`Error reading ${filename}:`, err.message);
      callback(data);
    });
}

// LOAD & MERGE SMARTPHONES (ALL_SMARTPHONES_MERGED.csv)
function loadSmartphones() {
  loadCSV('ALL_SMARTPHONES_MERGED.csv', (data) => {
    smartphones = data.map(phone => ({
      brand: phone.Brand || 'Unknown',
      device_name: phone['Device Name'] || 'Unknown',
      chipset: phone['Platform_Chipset'] || '',
      ram_gb: parseFloat(phone.Memory_Internal?.match(/(\d+)GB RAM/)?.[1] || 0),
      battery_capacity: parseFloat(phone.Battery_Type?.match(/(\d+) mAh/)?.[1] || 0),
      main_camera_mp: parseFloat(phone.MainCamera_Single?.match(/(\d+) MP/)?.[1] || phone.MainCamera_Triple?.match(/(\d+) MP/)?.[1] || 12),
      price_eur: parseFloat(phone.Misc_Price?.replace(/[^0-9.]/g, '')) || 0,
      antutu_v10_y: 0,
      overall_camera_score: 0
    })).filter(p => p.price_eur > 0);

    mergeChipsetBenchmarks();
    mergeDxomark();
    updateMaxValues();
    console.log(`Total smartphones loaded: ${smartphones.length}`);
  });
}

// Merge chipset AnTuTu to smartphones
function mergeChipsetBenchmarks() {
  let totalMerged = 0;
  CHIPSET_FILES.forEach(file => {
    loadCSV(file, (chipData) => {
      chipData.forEach(chip => {
        const chipsetName = chip.Chipset || '';
        const antutu = parseFloat(chip['AnTuTu v10']) || 0;
        if (!chipsetName || antutu === 0) return;

        smartphones.forEach(phone => {
          if (phone.chipset.toLowerCase().includes(chipsetName.toLowerCase())) {
            phone.antutu_v10_y = Math.max(phone.antutu_v10_y, antutu);
            totalMerged++;
          }
        });
      });
    });
  });
  setTimeout(() => console.log(`Merged AnTuTu for smartphones: ${totalMerged}`), 2000);
}

// Merge DXOMARK to smartphones
function mergeDxomark() {
  loadCSV(OTHER_FILES.dxomark, (dxoData) => {
    let merged = 0;
    dxoData.forEach(dxo => {
      const name = dxo['Smartphone Name'] || '';
      const score = parseFloat(dxo['Overall Camera Score']) || 0;
      if (!name || score === 0) return;

      smartphones.forEach(phone => {
        if (phone.device_name.toLowerCase().includes(name.toLowerCase())) {
          phone.overall_camera_score = score;
          merged++;
        }
      });
    });
    console.log(`Merged DXOMARK: ${merged}`);
  });
}

// LOAD & MERGE LAPTOPS (laptop_all_indonesia_fixed_v7.csv)
function loadLaptops() {
  loadCSV('laptop_all_indonesia_fixed_v7.csv', (data) => {
    laptops = data.map(lap => ({
      brand: lap.brand || 'Unknown',
      device_name: lap.model || 'Unknown',
      cpu: lap.cpu || '',
      gpu: lap.gpu || '',
      ram_gb: parseFloat(lap.ram?.replace('GB', '') || 0),
      storage_gb: parseFloat(lap.storage?.match(/(\d+)TB/)?.[1] * 1000 || lap.storage?.match(/(\d+)GB/)?.[1] || 0),
      display: lap.display || '',
      refresh_rate_hz: parseFloat(lap.refresh_rate_hz || 60),
      panel_type: lap.panel_type || '',
      weight_kg: parseFloat(lap.weight_kg || 0),
      price_eur: lap.price_idr / IDR_TO_EUR || 0,
      cinebench_r23_multi: 0,
      three_d_mark_time_spy_graphics: 0
    })).filter(p => p.price_eur > 0);

    mergeCPUBenchmarks();
    mergeGPUBenchmarks();
    updateMaxValues();
    console.log(`Total laptops loaded: ${laptops.length}`);
  });
}

// Merge CPU benchmarks to laptops
function mergeCPUBenchmarks() {
  let merged = 0;
  CPU_FILES.forEach(file => {
    loadCSV(file, (cpuData) => {
      cpuData.forEach(cpu => {
        const cpuName = cpu.Prosesor || cpu.Chipset || '';
        const cinebench = parseFloat(cpu['Cinebench R23 Multi']) || 0;
        if (!cpuName || cinebench === 0) return;

        laptops.forEach(lap => {
          if (lap.cpu.toLowerCase().includes(cpuName.toLowerCase())) {
            lap.cinebench_r23_multi = Math.max(lap.cinebench_r23_multi, cinebench);
            merged++;
          }
        });
      });
    });
  });
  setTimeout(() => console.log(`Merged CPU benchmarks for laptops: ${merged}`), 2000);
}

// Merge GPU benchmarks to laptops
function mergeGPUBenchmarks() {
  let merged = 0;
  GPU_FILES.forEach(file => {
    loadCSV(file, (gpuData) => {
      gpuData.forEach(gpu => {
        const gpuName = gpu.GPU || '';
        const score = parseFloat(gpu['3DMark Time Spy Graphics']) || 0;
        if (!gpuName || score === 0) return;

        laptops.forEach(lap => {
          if (lap.gpu.toLowerCase().includes(gpuName.toLowerCase())) {
            lap.three_d_mark_time_spy_graphics = Math.max(lap.three_d_mark_time_spy_graphics, score);
            merged++;
          }
        });
      });
    });
  });
  setTimeout(() => console.log(`Merged GPU benchmarks for laptops: ${merged}`), 2000);
}

// UPDATE MAX VALUES FOR NORMALIZATION
function updateMaxValues() {
  // Smartphone
  maxAntutu = Math.max(1, ...smartphones.map(p => p.antutu_v10_y));
  maxRam = Math.max(1, ...smartphones.map(p => p.ram_gb), ...laptops.map(l => l.ram_gb));
  maxBattery = Math.max(1, ...smartphones.map(p => p.battery_capacity));
  maxDxomark = Math.max(1, ...smartphones.map(p => p.overall_camera_score));

  // Laptop
  maxCinebenchMulti = Math.max(1, ...laptops.map(l => l.cinebench_r23_multi));
  max3DMarkGraphics = Math.max(1, ...laptops.map(l => l.three_d_mark_time_spy_graphics));

  minPrice = Math.min(Infinity, ...smartphones.map(p => p.price_eur).filter(v => v > 0), ...laptops.map(l => l.price_eur).filter(v => v > 0)) || 1;

  console.log('Max values updated for ML normalization');
}

// ML: WORTH SCORE
function calculateSmartphoneWorth(phone) {
  const antutu = phone.antutu_v10_y / maxAntutu;
  const ram = phone.ram_gb / maxRam;
  const battery = phone.battery_capacity / maxBattery;
  const camera = phone.overall_camera_score / maxDxomark;
  const price = 1 / (phone.price_eur / minPrice || 1);

  return (0.40 * antutu + 0.20 * ram + 0.15 * battery + 0.15 * camera + 0.10 * price) * 100;
}

function calculateLaptopWorth(laptop) {
  const cpu = laptop.cinebench_r23_multi / maxCinebenchMulti;
  const gpu = laptop.three_d_mark_time_spy_graphics / max3DMarkGraphics;
  const ram = laptop.ram_gb / maxRam;
  const price = 1 / (laptop.price_eur / minPrice || 1);

  return (0.35 * cpu + 0.35 * gpu + 0.20 * ram + 0.10 * price) * 100;
}

// API ENDPOINTS (FULLY FUNCTIONAL)

// Health Check
app.get('/', (req, res) => {
  res.json({
    status: 'TechPilot Backend Aktif!',
    smartphones: smartphones.length,
    laptops: laptops.length,
    time: new Date().toLocaleString('id-ID')
  });
});

// 1. RANKING TOP 10
app.get('/rank', (req, res) => {
  const minIdr = parseInt(req.query.min) || 1_000_000;
  const maxIdr = parseInt(req.query.max) || 50_000_000;
  const type = req.query.type || 'smartphone';

  const minEur = minIdr / IDR_TO_EUR;
  const maxEur = maxIdr / IDR_TO_EUR;

  const db = type === 'laptop' ? laptops : smartphones;
  const calc = type === 'laptop' ? calculateLaptopWorth : calculateSmartphoneWorth;

  const result = db
    .filter(p => p.price_eur >= minEur && p.price_eur <= maxEur)
    .map(p => ({ ...p, worth_score: calc(p) }))
    .sort((a, b) => b.worth_score - a.worth_score)
    .slice(0, 10)
    .map((p, i) => ({
      rank: i + 1,
      brand: p.brand,
      device_name: p.device_name,
      harga_rp: Math.round(p.price_eur * IDR_TO_EUR),
      worth_score: p.worth_score.toFixed(2),
      winner: i === 0
    }));

  res.json(result);
});

// 2. COMPARE 1-4 DEVICES
app.post('/compare', (req, res) => {
  const { devices, type = 'smartphone' } = req.body;
  if (!devices || devices.length < 1 || devices.length > 4) {
    return res.status(400).json({ error: 'Pilih 1-4 perangkat' });
  }

  const db = type === 'laptop' ? laptops : smartphones;
  const calc = type === 'laptop' ? calculateLaptopWorth : calculateSmartphoneWorth;

  const selected = db.filter(p =>
    devices.some(d =>
      p.brand.toLowerCase() === d.brand.toLowerCase() &&
      p.device_name.toLowerCase().includes(d.device_name.toLowerCase())
    )
  );

  if (selected.length === 0) return res.status(404).json({ error: 'Tidak ditemukan' });

  selected.forEach(p => p.worth_score = calc(p));

  const result = selected
    .sort((a, b) => b.worth_score - a.worth_score)
    .map((p, i) => ({
      rank: i + 1,
      brand: p.brand,
      device_name: p.device_name,
      harga_rp: Math.round(p.price_eur * IDR_TO_EUR),
      worth_score: p.worth_score.toFixed(2),
      winner: i === 0
    }));

  res.json(result);
});

// 3. CHATBOT AI
app.post('/chat', (req, res) => {
  const { message, type = 'smartphone' } = req.body;
  if (!message) return res.status(400).json({ error: 'Pesan kosong' });

  const lower = message.toLowerCase();
  const db = type === 'laptop' ? laptops : smartphones;
  const calc = type === 'laptop' ? calculateLaptopWorth : calculateSmartphoneWorth;

  let minPrice = 0, maxPrice = Infinity, ramMin = 0;

  const priceMatch = lower.match(/(\d+)\s?(juta|jutaan)/);
  if (priceMatch) {
    const juta = parseInt(priceMatch[1]);
    minPrice = juta * 1_000_000;
    maxPrice = (juta + 1) * 1_000_000 - 1;
  }

  const ramMatch = lower.match(/ram\s+(\d+)/);
  if (ramMatch) ramMin = parseInt(ramMatch[1]);

  const candidates = db.filter(p => {
    const inPrice = p.price_eur * IDR_TO_EUR >= minPrice && p.price_eur * IDR_TO_EUR <= maxPrice;
    const inRam = p.ram_gb >= ramMin;
    return inPrice && inRam;
  });

  if (candidates.length === 0) {
    return res.json({ reply: 'Maaf, tidak ada perangkat yang cocok.' });
  }

  candidates.forEach(p => p.worth_score = calc(p));
  const best = candidates.sort((a, b) => b.worth_score - a.worth_score)[0];

  const reply = `**Rekomendasi AI:**\n` +
                `${best.brand} ${best.device_name}\n` +
                `Harga: **Rp${(best.price_eur * IDR_TO_EUR).toLocaleString('id-ID')}**\n` +
                `Worth It Score: **${best.worth_score.toFixed(1)} / 100**`;

  res.json({ reply });
});

// START SERVER
loadSmartphones();
loadLaptops();

app.listen(PORT, () => {
  console.log(`TechPilot Backend berjalan di http://localhost:${PORT}`);
  console.log(`Waktu: ${new Date().toLocaleString('id-ID')}`);
});