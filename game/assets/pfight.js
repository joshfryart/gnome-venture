/* Puzzle combat: build a chain by tapping tiles, preview the totals, post once. The server decides everything; this only sums what it sent. */
(function () {
  var root = document.getElementById('pfight');
  if (!root) return;
  var hand = document.getElementById('pf-hand'), form = document.getElementById('pf-form');
  var chainIn = document.getElementById('pf-chain'), go = document.getElementById('pf-go'), undo = document.getElementById('pf-undo');
  var prev = document.getElementById('pf-preview'), rbtn = document.getElementById('pf-redraw');
  var data = {}; try { data = JSON.parse(document.getElementById('pf-data').textContent); } catch (e) {}
  var combos = data.combos || {}, hole = data.hole || {};
  var chain = [], redrawMode = false;
  var openKnob = root.dataset.open || null, openType = root.dataset.opent || null, openV = parseInt(root.dataset.openv || '0', 10), openMine = root.dataset.openby === 'me';
  var submitted = false;
  var tiles = Array.prototype.slice.call(hand.querySelectorAll('.pf-tile'));
  if (rbtn && parseInt(root.dataset.redraws || '0', 10) > 0) rbtn.hidden = false;

  function info(btn) { return { t: btn.dataset.t, v: parseInt(btn.dataset.v, 10), knob: btn.dataset.knob || null, hole: hole[btn.dataset.t] }; }
  function fits(knob, wild, t) { return wild || knob === hole[t]; }

  function render() {
    tiles.forEach(function (b) {
      var k = chain.indexOf(parseInt(b.dataset.i, 10));
      b.classList.toggle('pf-picked', k >= 0);
      b.setAttribute('aria-pressed', k >= 0 ? 'true' : 'false');
      if (!b.dataset.lab) b.dataset.lab = b.getAttribute('aria-label');
      b.setAttribute('aria-label', b.dataset.lab + (k >= 0 ? ', chain position ' + (k + 1) : ''));
      var badge = b.querySelector('.pf-ord');
      if (k >= 0) { if (!badge) { badge = document.createElement('span'); badge.className = 'pf-ord'; b.appendChild(badge); } badge.textContent = String(k + 1); }
      else if (badge) badge.remove();
    });
    chainIn.value = chain.join(',');
    go.disabled = chain.length === 0; undo.disabled = chain.length === 0;
    if (!chain.length) { prev.textContent = redrawMode ? 'Tap the tile to swap for a fresh one.' : 'Tap tiles in the order you want them (1 to 4).'; return; }
    var pt = openType, pk = openKnob, pv = openV, havePrev = !!openType, comboOk = openMine, tot = { hurt: 0, guard: 0, heal: 0, charm: 0, soothe: 0, trick: 0, item: 0 }, notes = [];
    chain.forEach(function (i) {
      var t = info(tiles[i]), v = t.v, fit = havePrev && (pk === null || pk === t.hole);
      if (fit) { v += Math.max(1, Math.round(t.v * 0.25)); }
      var c = havePrev && comboOk ? combos[pt + '>' + t.t] : null;   // your combos chain off your own tiles only (the server does the same)
      if (c) { v = Math.round(v * c.mul / 100 + (c.flat === 'prev' ? pv : c.flat)); notes.push(c.name); }
      tot[t.t] += v; pt = t.t; pk = t.knob; pv = t.v; havePrev = true; comboOk = true;
    });
    var parts = [];
    [['hurt', '⚔️'], ['guard', '🛡️'], ['heal', '💚'], ['charm', '🌸'], ['soothe', '😌'], ['item', '🎒']].forEach(function (p) { if (tot[p[0]]) parts.push(p[1] + ' ' + tot[p[0]]); });
    prev.textContent = (parts.join(' · ') || 'Setup only') + (notes.length ? ' · ✨ ' + notes.join(', ') : '') + (chain.some(function (i) { return tiles[i].dataset.tag === 'bash'; }) ? ' · Bash adds your guard' : '') + (chain.length === 4 ? ' · a full chain gives the foe an extra move' : '');
  }

  hand.addEventListener('click', function (ev) {
    var b = ev.target.closest('.pf-tile'); if (!b) return;
    var i = parseInt(b.dataset.i, 10);
    if (redrawMode) { if (submitted) return; submitted = true; tiles.forEach(function (t) { t.disabled = true; }); document.getElementById('pf-card').value = String(i); document.getElementById('pf-rform').submit(); return; }
    var k = chain.indexOf(i);
    var lastHeavy = chain.length && tiles[chain[chain.length - 1]].dataset.tag === 'heavy';   // a heavy tile has to be last
    if (k >= 0) chain.splice(k, 1); else if (chain.length < 4 && !lastHeavy) chain.push(i);
    render();
  });
  undo.addEventListener('click', function () { chain.pop(); render(); if (undo.disabled && tiles[0]) tiles[0].focus(); });
  if (rbtn) rbtn.addEventListener('click', function () { redrawMode = !redrawMode; chain = []; rbtn.setAttribute('aria-pressed', redrawMode ? 'true' : 'false'); rbtn.classList.toggle('pf-on', redrawMode); render(); });
  form.addEventListener('submit', function (e) { if (!chain.length) { e.preventDefault(); return; } if (submitted) { e.preventDefault(); return; } submitted = true; go.disabled = true; undo.disabled = true; });   // one POST per chain
  var strip = root.querySelector('.pf-strip'); if (strip) strip.scrollLeft = strip.scrollWidth;   // newest tile in view
  window.addEventListener('pageshow', function (e) { if (e.persisted) location.reload(); });   // back button: never show a stale hand
  render();
})();
