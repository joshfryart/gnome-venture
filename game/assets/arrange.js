/* v0.9.9: the arranging screen. Tap a flower to add it, tap a spot to choose where it goes, tap a placed stem to take it out.
   The picture is drawn here with the same maths as includes/flower_art.php (arrangement_inner), so what you see is what you get.
   The score comes from the server (?t=preview), so there is only one set of rules. Without JavaScript the form's <noscript> selects still work. */
(function () {
  'use strict';
  var dataEl = document.getElementById('arrdata');
  var form = document.getElementById('arrform');
  var canvas = document.getElementById('arrcanvas');
  if (!dataEl || !form || !canvas) return;
  var D = JSON.parse(dataEl.textContent);
  var NS = 'http://www.w3.org/2000/svg';
  var state = { v: D.v, slots: {}, pickSlot: null };
  var tiles = Array.prototype.slice.call(document.querySelectorAll('.arrtile'));
  var scoreBox = document.getElementById('arrscore');
  var hidden = document.getElementById('arrhidden');
  var makeBtn = document.getElementById('arrmake');
  var hint = document.getElementById('arrhint');
  var timer = null, ctl = null;

  var CRC = (function () {
    var t = [], c, n, k;
    for (n = 0; n < 256; n++) { c = n; for (k = 0; k < 8; k++) c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1); t[n] = c >>> 0; }
    return t;
  })();
  function crc32(s) {
    var c = 0xFFFFFFFF;
    for (var i = 0; i < s.length; i++) c = CRC[(c ^ s.charCodeAt(i)) & 0xFF] ^ (c >>> 8);
    return (c ^ 0xFFFFFFFF) >>> 0;
  }
  function r(x, d) { var m = Math.pow(10, d); return Math.round(x * m) / m; }
  function bit(seed, k) { return Math.floor(seed / Math.pow(2, k)) % 2; }

  function headG(shape, tint, x, y, s, rot) {
    return '<g transform="translate(' + r(x, 2) + ' ' + r(y, 2) + ') rotate(' + r(rot, 1) + ') scale(' + r(s, 3) + ') translate(-32 -32)" color="' + tint + '">' + (D.shapes[shape] || '') + '</g>';
  }

  /* Mirrors arrangement_inner() in includes/flower_art.php */
  function compInner(v, slots) {
    var V = D.vessels[v], my = D.mouth, out = '', heads = '', keys = [];
    var order = Object.keys(slots).map(Number).sort(function (a, b) { return a - b; });
    order.forEach(function (s) { var f = D.flowers[slots[s]]; keys.push(s + ':' + f.slug + ':' + (f.dried ? 1 : 0)); });
    var seed = crc32(keys.join('|'));
    out += '<g transform="translate(0 ' + (my - 16) + ')">' + V.back + '</g>';
    [[-1, 36, 1.0], [1, 36, 0.95], [0, 0, 1.12]].forEach(function (p, k) {
      var name = D.sprigs[Math.floor(seed / Math.pow(2, k * 3)) % D.sprigs.length];
      out += '<g transform="translate(' + (100 + p[0] * V.mouthW * 0.6) + ' ' + (my + 4) + ') rotate(' + (p[0] * p[1]) + ') scale(' + p[2] + ') translate(-32 -96)">' + D.sprigInner[name] + '</g>';
    });
    order.forEach(function (s) {
      var f = D.flowers[slots[s]], P = D.slots[s], cx = P[0], cy = P[1], sc = P[2];
      var bx = 100 + (cx - 100) * 0.2;
      out += '<path d="M' + r(bx, 1) + ' ' + (my + 6) + ' Q' + r(bx + (cx - bx) * 0.15, 1) + ' ' + r((my + cy) / 2, 1) + ' ' + cx + ' ' + (cy + 6) + '" fill="none" stroke="' + (f.dried ? '#a98b5e' : '#3f8f4f') + '" stroke-width="3" stroke-linecap="round"/>';
      if (!f.dried && s % 2 === 1) {
        var lx = bx + (cx - bx) * 0.5, ly = (my + cy) / 2 + 8, dir = cx < 100 ? -1 : 1;
        out += '<path d="M' + r(lx, 1) + ' ' + r(ly, 1) + ' q' + (7 * dir) + ' -9 ' + (15 * dir) + ' -6 q' + (-4 * dir) + ' 9 ' + (-15 * dir) + ' 6 Z" fill="#4f9d5d"/>';
      }
      heads += headG(f.shape, f.dried ? f.dtint : f.tint, cx, cy, sc * 0.98, (bit(seed, s) ? 6 : -6) * (s ? 1 : 0.5));
    });
    return out + heads + '<g transform="translate(0 ' + (my - 16) + ')">' + V.front + '</g>';
  }

  function count() { return Object.keys(state.slots).length; }
  function used(id) { var n = 0; for (var s in state.slots) if (String(state.slots[s]) === String(id)) n++; return n; }
  function allowed() { return D.vessels[state.v].slots; }
  function firstEmpty() { var a = allowed(); for (var i = 0; i < a.length; i++) if (state.slots[a[i]] === undefined) return a[i]; return null; }

  function place(slot, id) {
    var f = D.flowers[id];
    if (!f || used(id) >= f.qty) return;
    state.slots[slot] = id;
    state.pickSlot = null;
  }

  function draw() {
    var inner = compInner(state.v, state.slots), rings = '', a = allowed();
    a.forEach(function (s) {
      var P = D.slots[s], on = state.slots[s] !== undefined, f = on ? D.flowers[state.slots[s]] : null;
      var label = on ? 'Spot ' + (s + 1) + ': ' + f.name + '. Tap to take it out.' : 'Spot ' + (s + 1) + ': empty. Tap to choose it.';
      rings += '<circle class="arrslot' + (on ? ' on' : '') + (state.pickSlot === s ? ' pick' : '') + '" data-slot="' + s + '" cx="' + P[0] + '" cy="' + (P[1] + 2) + '" r="' + r(25 * P[2], 1) + '" tabindex="0" role="button" aria-label="' + label + '"/>';
      if (!on) rings += '<text class="arrnum" x="' + P[0] + '" y="' + (P[1] + 7) + '" text-anchor="middle">' + (s + 1) + '</text>';
    });
    canvas.innerHTML = inner + rings;
    tiles.forEach(function (t) {
      var id = t.getAttribute('data-id'), left = D.flowers[id].qty - used(id);
      t.querySelector('.arrq').textContent = left;
      t.classList.toggle('out', left < 1);
      t.disabled = left < 1 || (firstEmpty() === null && state.pickSlot === null);
    });
    var min = D.min, n = count();
    makeBtn.disabled = n < min;
    document.getElementById('arrcount').textContent = n + ' / ' + D.vessels[state.v].cap + ' stems';
    hint.textContent = n === 0 ? 'Tap a flower to add it. Tap a numbered spot first to choose where it goes.'
      : (n < min ? 'Add ' + (min - n) + ' more stem' + (min - n === 1 ? '' : 's') + ' to make an arrangement.' : 'Tap a stem to take it out, or press Make it.');
    hidden.innerHTML = '';
    var add = function (name, val) { var i = document.createElement('input'); i.type = 'hidden'; i.name = name; i.value = val; hidden.appendChild(i); };
    add('v', state.v);
    for (var s in state.slots) add('slot[' + s + ']', state.slots[s]);
    document.querySelectorAll('.arrvessel').forEach(function (b) { b.setAttribute('aria-pressed', b.getAttribute('data-v') === state.v ? 'true' : 'false'); });
    schedule();
  }

  function schedule() {
    clearTimeout(timer);
    if (count() < D.min) { renderScore(null); return; }
    timer = setTimeout(fetchScore, 140);
  }
  function fetchScore() {
    if (ctl && ctl.abort) ctl.abort();
    ctl = window.AbortController ? new AbortController() : null;
    var s = [];
    for (var k in state.slots) s.push(k + ':' + state.slots[k]);
    fetch(D.preview + '&v=' + encodeURIComponent(state.v) + '&s=' + encodeURIComponent(s.join(',')), { credentials: 'same-origin', signal: ctl ? ctl.signal : undefined })
      .then(function (res) { return res.json(); }).then(renderScore).catch(function () {});
  }
  function renderScore(j) {
    scoreBox.innerHTML = '';
    if (!j || !j.ok) {
      var p = document.createElement('p'); p.className = 'muted'; p.textContent = j && j.err ? j.err : 'Your score shows here once you have ' + D.min + ' stems.'; scoreBox.appendChild(p); return;
    }
    var head = document.createElement('div'); head.className = 'arrtotal';
    var big = document.createElement('b'); big.textContent = j.total; head.appendChild(big);
    var sm = document.createElement('span'); sm.textContent = '/100 · ' + j.word; head.appendChild(sm);
    scoreBox.appendChild(head);
    var nm = document.createElement('p'); nm.className = 'arrname'; nm.textContent = '“' + j.name + '”'; scoreBox.appendChild(nm);
    var ul = document.createElement('ul'); ul.className = 'arrparts';
    j.parts.forEach(function (p) {
      var li = document.createElement('li');
      var lab = document.createElement('span'); lab.textContent = p[0]; li.appendChild(lab);
      var bar = document.createElement('i'); bar.className = 'arrbar'; var fill = document.createElement('u'); fill.className = 'arrfill'; fill.setAttribute('data-w', String(Math.round(100 * p[1] / p[2])));
      bar.appendChild(fill); li.appendChild(bar);
      var pt = document.createElement('small'); pt.textContent = p[1] + '/' + p[2] + ' · ' + p[3]; li.appendChild(pt);
      ul.appendChild(li);
    });
    scoreBox.appendChild(ul);
    scoreBox.querySelectorAll('.arrfill').forEach(function (f) { f.className = 'arrfill w' + Math.round(f.getAttribute('data-w') / 5) * 5; });
  }

  function setVessel(v) {
    if (!D.vessels[v]) return;
    state.v = v;
    var a = allowed(), keep = {}, extra = [];
    for (var s in state.slots) { if (a.indexOf(Number(s)) >= 0) keep[s] = state.slots[s]; else extra.push(state.slots[s]); }
    state.slots = keep;
    extra.forEach(function (id) { var e = firstEmpty(); if (e !== null) state.slots[e] = id; });
    state.pickSlot = null;
    draw();
  }

  canvas.addEventListener('click', function (ev) {
    var c = ev.target.closest ? ev.target.closest('.arrslot') : null;
    if (!c) return;
    var s = Number(c.getAttribute('data-slot'));
    if (state.slots[s] !== undefined) { delete state.slots[s]; state.pickSlot = null; }
    else state.pickSlot = state.pickSlot === s ? null : s;
    draw();
  });
  canvas.addEventListener('keydown', function (ev) {
    if ((ev.key === 'Enter' || ev.key === ' ') && ev.target.classList && ev.target.classList.contains('arrslot')) {
      ev.preventDefault(); var s = Number(ev.target.getAttribute('data-slot')); ev.target.dispatchEvent(new MouseEvent('click', { bubbles: true }));
      setTimeout(function () { var again = canvas.querySelector('.arrslot[data-slot="' + s + '"]'); if (again) again.focus(); }, 0);
    }
  });
  tiles.forEach(function (t) {
    t.addEventListener('click', function () {
      var id = t.getAttribute('data-id');
      var s = state.pickSlot !== null ? state.pickSlot : firstEmpty();
      if (s === null) return;
      if (state.slots[s] !== undefined && state.pickSlot === null) return;
      place(s, id);
      draw();
    });
  });
  document.querySelectorAll('.arrvessel').forEach(function (b) { b.addEventListener('click', function () { setVessel(b.getAttribute('data-v')); }); });
  var clr = document.getElementById('arrclear');
  if (clr) clr.addEventListener('click', function () { state.slots = {}; state.pickSlot = null; draw(); });
  form.addEventListener('submit', function (ev) { if (count() < D.min) ev.preventDefault(); });
  document.documentElement.classList.add('arrjs');
  draw();
})();
