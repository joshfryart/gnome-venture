// node render_short.js : puzzle-combat-quick-rules.html -> puzzle-combat-quick-rules.pdf (A4, page numbers in the footer)
// build_short.py runs this twice (the second pass fills the page numbers of the contents list).
const { chromium } = require('playwright'); const path = require('path');
(async () => {
  const b = await chromium.launch(); const p = await b.newPage();
  await p.goto('file://' + path.join(__dirname, 'puzzle-combat-quick-rules.html'));
  await p.pdf({ path: path.join(__dirname, 'puzzle-combat-quick-rules.pdf'), format: 'A4', printBackground: true, displayHeaderFooter: true, preferCSSPageSize: true,
    headerTemplate: '<div></div>',
    footerTemplate: '<div style="font-family:Inter,DejaVu Sans,sans-serif;font-size:7pt;color:#666;width:100%;padding:0 13mm;display:flex;justify-content:space-between"><span>Puzzle Combat quick rules · Gnome Venture 2.7.00</span><span>page <span class="pageNumber"></span> of <span class="totalPages"></span></span></div>',
    margin: { top: '12mm', bottom: '14mm', left: '13mm', right: '13mm' } });
  await b.close();
})();
