// node render.js : puzzle-combat-rulebook.html -> puzzle-combat-rulebook.pdf (A4, page numbers in the footer)
const { chromium } = require('playwright'); const path = require('path');
(async () => {
  const b = await chromium.launch(); const p = await b.newPage();
  await p.goto('file://' + path.join(__dirname, 'puzzle-combat-rulebook.html'));
  await p.pdf({ path: path.join(__dirname, 'puzzle-combat-rulebook.pdf'), format: 'A4', printBackground: true, displayHeaderFooter: true, preferCSSPageSize: true,
    headerTemplate: '<div></div>',
    footerTemplate: '<div style="font-family:Inter,DejaVu Sans,sans-serif;font-size:7.5pt;color:#666;width:100%;padding:0 16mm;display:flex;justify-content:space-between"><span>Puzzle Combat v1 rule book · Gnome Venture 2.7.00</span><span>page <span class="pageNumber"></span> of <span class="totalPages"></span></span></div>',
    margin: { top: '17mm', bottom: '19mm', left: '16mm', right: '16mm' } });
  await b.close();
})();
