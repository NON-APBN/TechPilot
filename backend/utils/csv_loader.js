// backend/utils/csv_loader.js
const fs = require('fs');
const csv = require('csv-parse/sync');

function loadCSV(filePath) {
  const content = fs.readFileSync(filePath, 'utf-8');
  return csv.parse(content, { columns: true, skip_empty_lines: true });
}

module.exports = { loadCSV };