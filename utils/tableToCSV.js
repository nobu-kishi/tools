const rows = document.querySelectorAll('tr');
const csvLines = [];
const selectedColumns = [1, 4]; // 選択したい列のインデックス（0始まり）

rows.forEach(row => {
  const cells = row.querySelectorAll('td');
  const selected = selectedColumns.map(idx => {
    const td = cells[idx];
    return td ? `"${td.textContent.trim().replace(/"/g, '""')}"` : '""';
  });
  csvLines.push(selected.join(','));
});

const csvContent = csvLines.join('\n');
console.log(csvContent);