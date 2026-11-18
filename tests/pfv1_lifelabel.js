// 2.7.08 puzzle clarity (docs/puzzle-board-proposals.md P7, expiry label): a piece on the v1 board says how many rounds it still stays,
// as a number beside its pips, a tooltip and the cell's spoken label. Runs the real functions from game/assets/pfboardv1.js on a tiny fake DOM.
// node tests/pfv1_lifelabel.js   (prints "ok ..." / "FAIL ..." lines and "pfv1_lifelabel ok")
const fs = require('fs'), path = require('path');
const js = fs.readFileSync(path.join(__dirname, '../game/assets/pfboardv1.js'), 'utf8');
let fails = 0; const ck = (what, got, want) => { const g = JSON.stringify(got), w = JSON.stringify(want); if (g === w) console.log('ok   ' + what); else { fails++; console.log('FAIL ' + what + ' (got ' + g + ', want ' + w + ')'); } };
function grab(name) { const m = js.match(new RegExp('\\n  function ' + name + '\\([^)]*\\) \\{[\\s\\S]*?\\n  \\}|\\n  function ' + name + '\\([^)]*\\) \\{[^\\n]*\\}\\n')); return m ? m[0] : ''; }
function El(tag) { this.tag = tag; this.kids = []; this.attrs = {}; this.dataset = {}; this.className = ''; this.title = ''; this.textContent = ''; }
El.prototype.appendChild = function (k) { this.kids.push(k); return k; };
El.prototype.setAttribute = function (k, v) { this.attrs[k] = String(v); };
El.prototype.getAttribute = function (k) { return k in this.attrs ? this.attrs[k] : null; };
const document = { createElement: (t) => new El(t) };
const src = grab('pipsEl') + grab('lifeWords') + grab('lifeEl');
ck('pfboardv1.js has pipsEl, lifeWords and lifeEl', [!!grab('pipsEl'), !!grab('lifeWords'), !!grab('lifeEl')], [true, true, true]);
ck('the board draws a placed piece\'s life with lifeEl (the number and label, not bare pips)', js.includes('cell.appendChild(lifeEl(p.left, p.life, cell))'), true);
ck('the help lists how long a piece stays', js.includes("n: 'How long a piece stays'"), true);
if (fails) { console.log(fails + ' FAILED'); process.exit(1); }
const f = new Function('document', src + '; return { pipsEl: pipsEl, lifeWords: lifeWords, lifeEl: lifeEl };')(document);
// a piece with 3 rounds of life and 2 left
let cell = new El('div'); cell.setAttribute('aria-label', 'Your Jab, hurt 7. Press for details.');
let s = f.lifeEl(2, 3, cell), num = s.kids.find((k) => k.className === 'xpn');
ck('2 rounds left: two full pips of three, then the number 2', [s.kids.filter((k) => k.tag === 'i' && k.className !== 'e').length, s.kids.filter((k) => k.tag === 'i').length, num && num.textContent], [2, 3, '2']);
ck('2 rounds left: the tooltip says it fades in 2 rounds', cell.title, 'Fades in 2 rounds');
ck('2 rounds left: the spoken label says it too', cell.getAttribute('aria-label'), 'Your Jab, hurt 7. Press for details. It fades in 2 rounds.');
ck('2 rounds left: not marked as the last round', s.className, 'xp');
// its last round
cell = new El('div'); cell.setAttribute('aria-label', 'The creature’s Bite, hurt 5. Press for details.');
s = f.lifeEl(1, 3, cell); num = s.kids.find((k) => k.className === 'xpn');
ck('last round: number 1, the strip marked last (red)', [num && num.textContent, s.className], ['1', 'xp last']);
ck('last round: the tooltip and label say it fades at the end of this round', [cell.title, cell.getAttribute('aria-label').endsWith('It fades at the end of this round.')], ['Fades at the end of this round', true]);
// a cell that already has a tooltip (a piece the creature just spawned) keeps it
cell = new El('div'); cell.title = 'Bramble: grown by the creature.'; f.lifeEl(3, 3, cell);
ck('a cell with its own tooltip keeps it', cell.title, 'Bramble: grown by the creature.');
console.log(fails ? fails + ' FAILED' : 'pfv1_lifelabel ok'); process.exit(fails ? 1 : 0);
