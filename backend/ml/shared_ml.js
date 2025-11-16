// backend/ml/shared_ml.js
function normalize(value, min, max) {
  return (value - min) / (max - min);
}

function sigmoid(x) {
  return 1 / (1 + Math.exp(-x));
}

function calculateWorthScore(features, weights) {
  let score = 0;
  for (const [key, value] of Object.entries(features)) {
    const weight = weights[key] || 0;
    score += value * weight;
  }
  return Math.round(sigmoid(score) * 1000) / 10; // 0-100
}

module.exports = { normalize, sigmoid, calculateWorthScore };