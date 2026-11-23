/* Nav dock, phase 1 (plan: claude/plan-nav-dock.md; includes/dock.php).
   Draws the landscape bottom dock from the JSON data block #dockjson: four menu pieces with strips of tile pieces, the status plate with its popover,
   and two page actions (a link, or a strip of links). Pieces are jigsaw SVGs locked along a curve; strips snap in one piece after another and come
   apart in reverse. CSP: no inline styles, so positions are set through the style object. If anything here fails, assets/dock.css leaves the plain list of
   links (.dockfb) visible, so the menu never disappears. Shown in landscape (the same media query as dock.css): phones, tablets and desktops. */
(function () {
  'use strict';
  var root = document.getElementById('dockroot');
  if (!root || !window.matchMedia || !document.querySelector) return;
  try { if (!(window.CSS && CSS.supports('translate', '0 0') && CSS.supports('rotate', '0deg'))) return; } catch (e) { return; }
  var mq = window.matchMedia('(orientation: landscape)');
  var DH = 106, AMP = 40, uid = 0;
  var D = null, slip = null, lastKey = '', stage = null, ghostTimer = 0, popTab = 'now', K = 1, LW = 844;   // K = how much the whole dock is scaled up on a big screen, LW = the screen width in dock units
  var DOME = [[-4, 0], [-4, -3], [-6, -4], [-8, -6], [-8, -10], [-6, -12], [-4, -13], [4, -13], [6, -12], [8, -10], [8, -6], [6, -4], [4, -3], [4, 0]];
  var KEY = [[-8, 0], [-6, -2], [-3, -4], [-3, -7], [-6, -8], [-7, -10], [-6, -13], [-3, -14], [3, -14], [6, -13], [7, -10], [6, -8], [3, -7], [3, -4], [6, -2], [8, 0]];
  var PAT = { you: 'dk-diamond', hobby: 'dk-leaf', out: 'dk-wave', tog: 'dk-flower' };

  /* every class the dock draws is prefixed dk- so nothing in the game's own stylesheet (tag, chip, badge, tile, row...) can reach it */
  function pref(h) {
    return h.replace(/class="([^"]*)"/g, function (m, c) {
      return 'class="' + c.split(/\s+/).filter(Boolean).map(function (t) { return /^(dock|dk)/.test(t) ? t : 'dk-' + t; }).join(' ') + '"';
    });
  }
  function esc(s) { return String(s == null ? '' : s).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }
  function readData() {
    var el = document.getElementById('dockjson');
    try { D = el ? JSON.parse(el.textContent) : null; } catch (e) { D = null; }
    return !!D;
  }

  /* ---- jigsaw geometry: knob shapes 1 = dome, 2 = keyhole; sign = out (+) or in (-) ---- */
  function edgePts(len, s, cc) {
    if (!s) return [[len, 0]];
    var c = cc === undefined ? len / 2 : cc, sg = s > 0 ? 1 : -1, P = Math.abs(s) === 2 ? KEY : DOME;
    return P.map(function (q) { return [c + q[0], q[1] * sg]; }).concat([[len, 0]]);
  }
  function pathD(w, h, t, r, b, l, ox, oy) {
    var d = 'M' + ox + ',' + oy;
    function add(pts, f) { pts.forEach(function (p) { var q = f(p[0], p[1]); d += ' L' + (q[0] + ox).toFixed(1) + ',' + (q[1] + oy).toFixed(1); }); }
    add(edgePts(w, t), function (a, y) { return [a, y]; });
    add(edgePts(h, r, 18), function (a, y) { return [w - y, a]; });
    add(edgePts(w, b), function (a, y) { return [w - a, h - y]; });
    add(edgePts(h, l, h - 18), function (a, y) { return [y, h - a]; });
    return d + ' Z';
  }
  /* 2.5D piece: side face (4 px, always straight down on screen), face, light top-left and shaded bottom-right strips, grain, stitch */
  function pieceSVG(w, h, t, r, b, l, rot, pat, ghost) {
    var id = 'dkp' + (uid++), P = pathD(w, h, t, r, b, l, 0, 0), rad = (rot || 0) * Math.PI / 180;
    var open = '<svg class="ps" width="' + (w + 32) + '" height="' + (h + 36) + '" viewBox="-16 -16 ' + (w + 32) + ' ' + (h + 36) + '" aria-hidden="true" focusable="false"><defs><path id="' + id + '" d="' + P + '"/><clipPath id="c' + id + '"><use href="#' + id + '"/></clipPath></defs>';
    if (ghost) return open + '<use href="#' + id + '" class="gf"/></svg>';
    var dx = (4 * Math.sin(rad)).toFixed(1), dy = (4 * Math.cos(rad)).toFixed(1);
    var hi = P + ' ' + pathD(w, h, t, r, b, l, 2, 2), lo = P + ' ' + pathD(w, h, t, r, b, l, -2, -2);
    var st = 'M7,5H' + (w - 7) + 'M7,' + (h - 5) + 'H' + (w - 7);
    return open + '<use href="#' + id + '" class="sd" transform="translate(' + dx + ' ' + dy + ')"/><use href="#' + id + '" class="fc"/>'
      + '<g clip-path="url(#c' + id + ')">' + (pat ? '<rect fill="url(#' + pat + ')" x="-16" y="-16" width="' + (w + 32) + '" height="' + (h + 32) + '"/>' : '')
      + '<path class="hi" fill-rule="evenodd" d="' + hi + '"/><path class="lo" fill-rule="evenodd" d="' + lo + '"/><rect class="gr" x="-16" y="-16" width="' + (w + 32) + '" height="' + (h + 32) + '"/></g><path class="st" d="' + st + '"/></svg>';
  }
  /* one piece: the element carries data-* for its place; position() sets the style after the markup is in the page */
  function pc(o) {
    var tg = o.tag || 'button', t = o.tabs || [0, 0, 0, 0];
    var attrs = (o.attrs || '') + (tg === 'button' && o.attrs !== undefined && !/type=/.test(o.attrs) ? ' type="button"' : '');
    return '<' + tg + ' class="pc ' + (o.cls || '') + '" data-x="' + o.x.toFixed(1) + '" data-y="' + o.y.toFixed(1) + '" data-w="' + o.w + '" data-h="' + o.h + '" data-rot="' + (o.rot || 0).toFixed(1) + '"'
      + (o.op !== undefined ? ' data-op="' + o.op + '"' : '') + (o.o !== undefined ? ' data-o="' + o.o + '" data-fx="' + o.fx + '"' : '') + ' ' + attrs + '>'
      + pieceSVG(o.w, o.h, t[0], t[1], t[2], t[3], o.rot, o.pat, o.ghost) + '<span class="in">' + (o.inner || '') + '</span>' + (o.after || '') + '</' + tg + '>';
  }
  function position(c) {
    Array.prototype.forEach.call(c.querySelectorAll('[data-x]'), function (el) {
      var s = el.style;
      s.left = el.getAttribute('data-x') + 'px'; s.top = el.getAttribute('data-y') + 'px';
      s.width = el.getAttribute('data-w') + 'px'; s.height = el.getAttribute('data-h') + 'px';
      s.setProperty('--rot', el.getAttribute('data-rot') + 'deg');
      if (el.hasAttribute('data-op')) s.opacity = el.getAttribute('data-op');
      if (el.hasAttribute('data-o')) { s.setProperty('--o', el.getAttribute('data-o')); s.setProperty('--fx', el.getAttribute('data-fx') + 'px'); }
    });
    Array.prototype.forEach.call(c.querySelectorAll('[data-pl]'), function (el) {   // a plain box (the popover, a label): left/top/width/height only
      var p = el.getAttribute('data-pl').split(',');
      el.style.left = p[0] + 'px'; el.style.top = p[1] + 'px'; if (p[2]) el.style.width = p[2] + 'px'; if (p[3]) el.style.height = p[3] + 'px';
    });
  }
  /* bigger screens get a bigger dock: the dock is drawn at one size (about 106 px high at 844 wide) and scaled in steps of a quarter, never taller than about 28% of the screen */
  function scaleFor(vw, vh) {
    var k = Math.max(1, Math.min(2, Math.round(vw / 860 * 4) / 4));
    k = Math.min(k, Math.max(1, 0.28 * vh / DH));
    return Math.max(1, Math.round(k * 4) / 4);
  }
  function geom(W) {
    var A = AMP, pw = W < 720 ? 170 : W < 900 ? 244 : 300, cw = pw + 136, half = (W - cw) / 2;
    function ay(x) { var d = x < half ? half - x : (x > W - half ? x - (W - half) : 0); return A * (1 - (d / half) * (d / half)); }
    function sl(x) { return x < half ? 2 * A * (half - x) / (half * half) : (x > W - half ? -2 * A * (x - (W - half)) / (half * half) : 0); }
    return { dh: DH, A: A, pw: pw, half: half, ay: ay, sl: sl };
  }
  function place(g, cx, off) {   // a point on the curve moved along the inward normal (negative = above the line)
    var s = g.sl(cx), n = Math.sqrt(1 + s * s);
    return { x: cx - s / n * off, y: g.ay(cx) + off / n, rot: Math.atan(s) * 180 / Math.PI };
  }

  /* ---- content helpers ---- */
  function icon(name, big) {
    if (!name) return '';
    if (D.iconNames.indexOf(name) >= 0) return '<img class="px" src="' + esc(D.iconBase + name + '.png') + '" width="32" height="32" alt="">';
    return esc(name);
  }
  function ic(name) { var img = D.iconNames.indexOf(name) >= 0; return '<span class="ic' + (img ? ' pi' : '') + '">' + icon(name) + '</span>'; }
  function menuBadge(m) {
    if (m.k === 'tog' && D.unread) return '!';
    var n = 0; m.tiles.forEach(function (t) { if (/^\d+$/.test(t.badge)) n += parseInt(t.badge, 10); });
    return n > 0 ? String(n) : '';
  }
  function dockSVG(W, g) {
    var pts = [], x, y, h, k, f = 0, cls;
    for (x = 0; x <= W; x += 6) pts.push(x + ',' + g.ay(x).toFixed(1));
    h = '<svg class="arc" viewBox="0 0 ' + W + ' ' + g.dh + '" preserveAspectRatio="none" aria-hidden="true" focusable="false"><path class="soil" d="M' + pts.join(' L') + ' L' + W + ',' + g.dh + ' L0,' + g.dh + ' Z"/>';
    for (x = 0; x < W; x += 9) {
      y = g.ay(x); k = (x * 7 + 3) % 5; var hh = 5 + k * 2;
      h += '<rect class="' + (k % 2 ? 'g1' : 'g2') + '" x="' + x + '" y="' + (y - hh + 2).toFixed(0) + '" width="3" height="' + hh + '"/><rect class="g3" x="' + (x + 4) + '" y="' + (y - hh / 2 + 2).toFixed(0) + '" width="3" height="' + Math.round(hh / 2) + '"/>';
    }
    for (x = 26; x < W; x += 61) {
      y = g.ay(x); cls = ['fl1', 'fl2', 'fl3'][f++ % 3];
      h += '<rect class="stem" x="' + x + '" y="' + (y - 11).toFixed(0) + '" width="2" height="11"/><rect class="' + cls + '" x="' + (x - 2) + '" y="' + (y - 17).toFixed(0) + '" width="6" height="6"/><rect class="fl2" x="' + x + '" y="' + (y - 15).toFixed(0) + '" width="2" height="2"/>';
    }
    return h + '</svg>';
  }
  function defs() {
    function r(c, x, y, w, h) { return '<rect class="' + c + '" x="' + x + '" y="' + y + '" width="' + w + '" height="' + h + '"/>'; }
    return '<svg class="dkdefs" width="0" height="0" aria-hidden="true" focusable="false"><defs>'
      + '<pattern id="dk-grain" width="8" height="8" patternUnits="userSpaceOnUse">' + r('g-d', 1, 2, 2, 2) + r('g-l', 5, 6, 2, 2) + '</pattern>'
      + '<pattern id="dk-dirt" width="64" height="48" patternUnits="userSpaceOnUse">' + r('db', 0, 0, 64, 48) + r('dd', 4, 6, 10, 4) + r('dd', 30, 2, 6, 4) + r('dd', 46, 20, 12, 4) + r('dd', 10, 30, 8, 6) + r('dd', 36, 38, 10, 4)
      + r('dl', 18, 14, 6, 4) + r('dl', 40, 10, 8, 4) + r('dl', 2, 22, 6, 4) + r('dl', 24, 26, 10, 4) + r('dl', 52, 34, 6, 4) + r('pb', 20, 36, 6, 4) + r('ph', 21, 36, 2, 2) + r('pb', 48, 4, 6, 4) + r('ph', 49, 4, 2, 2)
      + r('rt', 0, 18, 6, 2) + r('rt', 6, 16, 6, 2) + r('rt', 12, 18, 4, 2) + r('rt', 38, 30, 6, 2) + r('rt', 44, 32, 6, 2) + '</pattern>'
      + '<pattern id="dk-dirt2" width="64" height="48" patternUnits="userSpaceOnUse">' + r('db2', 0, 0, 64, 48) + r('dd half', 8, 10, 8, 4) + r('dd half', 40, 6, 6, 4) + r('dd half', 26, 30, 10, 4)
      + r('dl', 20, 4, 6, 4) + r('dl', 50, 26, 8, 4) + r('pb', 4, 36, 6, 4) + r('ph', 5, 36, 2, 2) + r('rt', 34, 18, 6, 2) + '</pattern>'
      + '<pattern id="dk-diamond" width="8" height="8" patternUnits="userSpaceOnUse">' + r('pw', 3, 0, 2, 2) + r('pw', 1, 2, 2, 2) + r('pw', 5, 2, 2, 2) + r('pw', 3, 4, 2, 2) + '</pattern>'
      + '<pattern id="dk-leaf" width="10" height="8" patternUnits="userSpaceOnUse">' + r('pw', 1, 1, 2, 2) + r('pw', 3, 3, 2, 2) + r('pw', 5, 1, 2, 2) + r('pw', 3, 5, 2, 2) + '</pattern>'
      + '<pattern id="dk-wave" width="12" height="8" patternUnits="userSpaceOnUse">' + r('pw', 0, 4, 4, 2) + r('pw', 6, 4, 2, 2) + r('pw', 9, 1, 2, 2) + '</pattern>'
      + '<pattern id="dk-flower" width="10" height="10" patternUnits="userSpaceOnUse">' + r('pw', 4, 1, 2, 6) + r('pw', 2, 3, 6, 2) + '</pattern>'
      + '</defs></svg>';
  }

  /* ---- phase 2: pieces that work the page's own controls (includes/dock.php, dock_remote()) ----
     The dock never posts anything itself: it clicks a button the page already has, so the page's CSRF token, confirm dialog and in-place update all apply. */
  var G_TOOL = { water: '.selacts [data-act="water"]', harvest: '.selacts [data-act="harvest"]', till: '.selacts [data-act="till"]' }, tool = null;   /* garden tool mode: a tapped bed is picked alone, then the page's own action button is clicked */
  /* community garden Select mode: beds are picked on the page (.cbed[data-bed][data-state][data-weedy]); one POST does a job for each (community.php, acts[]) */
  var tendOn = false, tSel = {};
  function tBeds() { return [].slice.call(document.querySelectorAll('.cbed[data-bed]')); }
  function tPicked(test) { return tBeds().filter(function (e) { return tSel[e.getAttribute('data-bed')] && test(e); }); }
  var T_PICK = [['thirsty', '💧', 'Thirsty', function (e) { return e.getAttribute('data-state') === 'thirsty'; }], ['weedy', '🌿', 'Weedy', function (e) { return e.getAttribute('data-weedy') === '1'; }],
    ['ripe', '🧺', 'Ripe', function (e) { return e.getAttribute('data-state') === 'ripe'; }], ['empty', '🟫', 'Empty', function (e) { return e.getAttribute('data-state') === 'empty'; }]];
  var T_THEN = [['water', '💧', 'Water', function (e) { return e.getAttribute('data-state') === 'thirsty'; }], ['weed', '🌿', 'Weed', function (e) { return e.getAttribute('data-weedy') === '1'; }],
    ['harvest', '🧺', 'Harvest', function (e) { return e.getAttribute('data-state') === 'ripe'; }], ['plant', '🌱', 'Plant', function (e) { return e.getAttribute('data-state') === 'empty' && !!q1('.tendform select[name="seed"]'); }]];
  function tPaint() { tBeds().forEach(function (e) { e.classList.toggle('dkpick', !!tSel[e.getAttribute('data-bed')]); }); }
  function tCount() { return Object.keys(tSel).length; }
  function tendStrips() {
    var pick = T_PICK.map(function (p) { var n = tBeds().filter(p[3]).length; return { label: p[2], icon: p[1], badge: n ? String(n) : '', rem: remKey({ tendpick: p[0] }), why: n ? '' : 'none' }; }), then = [];
    pick.push({ label: 'None', icon: '✕', rem: remKey({ tendpick: 'none' }), why: '' });
    T_THEN.forEach(function (t) { var n = tPicked(t[3]).length; then.push({ label: t[2], icon: t[1], badge: n ? String(n) : '', rem: remKey({ tendgo: t[0] }), why: n ? '' : 'pick', cls: 'do' }); });
    return [{ items: pick, label: 'Pick beds', side: 'L', flat: false, small: true }, { items: then, label: 'Then do this to the picked ones', side: 'R', flat: false, small: true }];
  }
  var REM = [], ACT = { L: null, R: null }, selOn = false, qMode = false, lp = false, lpT = 0;
  function q1(sel) { try { return document.querySelector(sel); } catch (e) { return null; } }
  function formBtn(doVal) {
    var fs = document.querySelectorAll('main form'), i, f, inp, b;
    for (i = 0; i < fs.length; i++) {
      f = fs[i]; inp = f.querySelector('input[name="do"]');
      if (inp && inp.value === doVal) { b = f.querySelector('button, input[type="submit"]'); return { btn: b, dis: !b || b.disabled }; }
    }
    return null;
  }
  function attrCount(c) { var el = c && q1(c[0]), v = el ? parseInt(el.getAttribute(c[1]), 10) : 0; return v > 0 ? String(v) : ''; }
  function resolveOne(a) {   // -> { why, badge } for a piece or tile that works a control on the page
    var r = a.remote || {}, t, e;
    if (r.doForm) { t = formBtn(r.doForm); if (!t || t.dis) return { why: 'none' }; return { badge: attrCount(r.count) }; }
    if (r.sel) { e = q1(r.sel); if (!e) return { why: 'n/a' }; if (e.disabled) return { why: 'none' }; return {}; }
    return {};
  }
  function remoteGo(spec) {   // looked up again at the moment of the tap: the page may have been swapped since the dock was drawn
    var t, e;
    if (!spec) return;
    if (spec.dlg) { if (spec.dlg.isConnected) { if (window.gvOpenDlg) window.gvOpenDlg(spec.dlg); else if (spec.dlg.showModal) spec.dlg.showModal(); } return; }
    if (spec.node) { if (spec.node.isConnected) spec.node.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true })); return; }   // may be an SVG link (no click())
    if (spec.tend) { tendOn = spec.tend === 'on'; tSel = {}; tPaint(); return; }
    if (spec.tendpick) { tSel = {}; if (spec.tendpick !== 'none') { var tp = T_PICK.filter(function (p) { return p[0] === spec.tendpick; })[0]; tBeds().filter(tp[3]).forEach(function (e) { tSel[e.getAttribute('data-bed')] = 1; }); } tPaint(); return 'keep'; }
    if (spec.tendgo) {
      var tt = T_THEN.filter(function (p) { return p[0] === spec.tendgo; })[0], acts = tPicked(tt[3]).map(function (e) { return spec.tendgo + ':' + e.getAttribute('data-bed'); }), sd = q1('.tendform select[name="seed"]'), fl = { do: 'tend', acts: acts };
      if (!acts.length) return 'keep';
      if (sd) fl.seed = sd.value;
      tSel = {}; tPaint(); postTo(location.pathname + '?t=garden', fl); return 'keep';
    }
    if (spec.foe) { slip = 'status'; popTab = 'foe'; return 'keep'; }
    if (spec.tool) { tool = tool === spec.tool ? null : spec.tool; e = q1('.selbar [data-sel="' + (tool ? 'on' : 'off') + '"]'); if (tool === null) { e = q1('.selbar [data-sel="off"]'); } if (e && !e.hidden && (tool || gSelOn())) e.click(); return; }
    if (spec.doForm) { t = formBtn(spec.doForm); if (t && !t.dis) t.btn.click(); return; }
    if (spec.sel) { e = q1(spec.sel); if (e && !e.disabled) { if (!(e.tagName === 'SUMMARY' && e.parentNode && e.parentNode.open)) e.click(); if (e.tagName === 'SUMMARY') { try { e.scrollIntoView({ block: 'start', behavior: 'smooth' }); } catch (x) { e.scrollIntoView(); } } } }
  }
  function remKey(spec) { REM.push(spec); return REM.length - 1; }
  /* the garden's own select panel: .selbar (data-tiles: a flag letter string per square), .selon while it is on, .selcount, the Pick buttons [data-q], the action buttons in .selacts */
  var G_PICK = [['P', '🟫', 'Empty'], ['A', '🌿', 'Improver'], ['T', '⛏️', 'Tilling'], ['W', '💧', 'Thirsty'], ['H', '🧺', 'Ready'], ['none', '✕', 'None']];
  var G_THEN = [['🌱', 'Plant…', '.selacts [data-open="seed"]'], ['🪱', 'Work in…', '.selacts [data-open="soil"]'], ['🍂', 'Mulch…', '.selacts [data-open="mulch"]:not([data-act])'],
    ['📰', 'Sheet mulch…', '.selacts [data-open="mulch"][data-act="sheet"]'], ['⛏️', 'Till', '.selacts [data-act="till"]'], ['💧', 'Water', '.selacts [data-act="water"]'],
    ['🧺', 'Harvest', '.selacts [data-act="harvest"]'], ['🕳️', 'Dig up', '.selacts [data-act="dig"]']];
  function gSelOn() { var e = q1('.selbar .selon'); return !!(e && !e.hidden); }
  function gCount() { var e = q1('.selbar .selcount'); return e ? parseInt(e.textContent, 10) || 0 : 0; }
  function gFlagCount(letter) {
    var bar = q1('.selbar'), raw = bar ? bar.getAttribute('data-tiles') : '', n = 0;
    if (!raw) return '';
    raw.split(',').forEach(function (s) { var p = s.split(':'); if (p[1] && p[1].indexOf(letter) >= 0) n++; });
    return n ? String(n) : '';
  }
  function postTo(url, fields) {   // a form the page's own submit handler loads in place (assets/site.js allows .dockroot forms): the token is the page's
    var f = document.createElement('form'), k, i;
    f.method = 'post'; f.action = url; f.hidden = true; f.className = 'dockpost';
    fields.csrf = D.csrf; fields._n = Math.random().toString(16).slice(2, 10);
    for (k in fields) {
      if (Array.isArray(fields[k])) { fields[k].forEach(function (v) { var x = document.createElement('input'); x.type = 'hidden'; x.name = k + '[]'; x.value = v; f.appendChild(x); }); continue; }
      i = document.createElement('input'); i.type = 'hidden'; i.name = k; i.value = fields[k]; f.appendChild(i);
    }
    root.appendChild(f);
    if (f.requestSubmit) f.requestSubmit(); else f.submit();
    setTimeout(function () { if (f.parentNode) f.parentNode.removeChild(f); }, 8000);
  }
  function satchelPick() {   // the item popup open in the Satchel: its Eat or Drink form names the item and shows it can go on the Quick button
    var d = q1('main details.itile[open]'), forms, i, dd, it;
    if (!d) return null;
    forms = d.querySelectorAll('form');
    for (i = 0; i < forms.length; i++) {
      dd = forms[i].querySelector('input[name="do"]'); it = forms[i].querySelector('input[name="item_id"]');
      if (dd && it && (dd.value === 'eat' || dd.value === 'drink_heal')) return { id: it.value };
    }
    return { id: '', no: true };
  }
  function copy(o) { var r = {}, k; for (k in o) r[k] = o[k]; return r; }
  function finalItem(t) {
    var o = copy(t), r;
    if (t.remote && (t.remote.tendpick || t.remote.tendgo)) { o.rem = remKey(t.remote); return o; }
    if (t.remote && t.remote.select === 'garden') { o.rem = remKey({ sel: '.selbar [data-sel="on"]' }); o.why = q1('.selbar') ? '' : 'n/a'; return o; }
    if (t.remote && t.remote.foe) { o.rem = remKey(t.remote); o.why = D.foe ? '' : 'none'; return o; }
    if (t.remote && t.remote.tool) { o.why = q1('.selbar') ? '' : 'n/a'; o.rem = remKey(t.remote); o.badge = tool === t.remote.tool ? '\u25cf' : ''; return o; }
    if (t.remote && (t.remote.doForm || t.remote.sel)) { r = resolveOne(t); o.why = r.why || t.why; o.badge = r.badge || t.badge; o.rem = remKey(t.remote); }
    return o;
  }
  function finalAct(a) {
    var o, pick = null, r;
    if (!a) return null;
    if (a.cands && a.cands.length) {   // the first candidate whose control is on the page
      a.cands.some(function (c) { var rr = resolveOne(c); if (!rr.why) { pick = { c: c, r: rr }; return true; } return false; });
      if (pick) { o = copy(pick.c); o.badge = pick.r.badge || ''; o.rem = remKey(pick.c.remote); }
      else { o = copy(a.cands[0]); o.why = 'nothing here'; }
      o.menu = []; return o;
    }
    o = copy(a);
    if (a.remote && a.remote.quick === 'slot') {   // the Quick slot: empty (＋ Quick), assigning (open an item in the Satchel, then Confirm), or holding an item (tap to use, x or hold to clear)
      var qk = D.quick, pk;
      if (qMode) { o.label = 'Confirm'; o.icon = '✔'; o.qk = 'confirm'; o.qx = 'cancel'; pk = satchelPick(); if (!pk) o.chip = 'open an item'; else if (pk.no) o.chip = 'can\u2019t use'; return o; }
      if (qk) { o.label = qk.name; o.icon = qk.kind === 'heal' ? '🧪' : '🍽️'; o.badge = qk.qty > 0 ? String(qk.qty) : ''; o.qk = 'use'; o.qx = 'clear'; if (qk.qty <= 0) o.chip = '0 left'; return o; }
      o.label = 'Quick'; o.icon = '＋'; o.qk = 'empty'; return o;
    }
    if (a.remote && a.remote.quick === 'use') {   // use only (adventure): the Quick item, no assign, no x, no hold; empty = set it in the Satchel
      if (D.foe) {   // in a fight: a home-cooked snack works in the old fight (the page's own Snack action); a puzzle fight's Snack is a tile on its board
        o.label = D.quick ? D.quick.name : 'Quick'; o.icon = D.quick && D.quick.kind === 'heal' ? '🧪' : '🍽️';
        if (!D.quick) o.why = 'set in Satchel'; else if (!D.foe.snack) o.why = 'not a snack'; else { o.qk = 'fightsnack'; o.badge = D.quick.qty > 0 ? String(D.quick.qty) : ''; }
      }
      else if (D.quick) { o.label = D.quick.name; o.icon = D.quick.kind === 'heal' ? '🧪' : '🍽️'; o.badge = D.quick.qty > 0 ? String(D.quick.qty) : ''; o.qk = 'useonly'; if (D.quick.qty <= 0) o.chip = '0 left'; }
      else { o.label = 'Quick'; o.icon = '＋'; o.why = 'set in Satchel'; }
      return o;
    }
    if (a.remote && a.remote.hereMenu) {   // the Here picture's round buttons (Routes, World, Perks, Fast travel, GPS, Wander) move into this piece; the page's own row is hidden in the dock layout
      var HM = { 'hs-routes': 'explore', 'hs-world': 'globe', 'hs-perks': 'sights', 'hs-ft': 'trail', 'hs-gps': 'tag' };
      var bs = [].slice.call(document.querySelectorAll('ul.hubnavbar li a, ul.hubnavbar li button'));
      o.menu = bs.map(function (e) {
        var li = e.closest('li'), nm = (li && li.textContent || e.getAttribute('aria-label') || '').replace(/\s+/g, ' ').trim();
        return { label: nm, icon: HM[e.id] || 'wander', href: '', menu: [], why: '', badge: '', mlabel: '', remote: {}, cands: [], rem: remKey({ node: e }) };
      });
      if (!o.menu.length) o.why = 'none';
      return o;
    }
    if (a.remote && a.remote.hereDo) {   // the Here picture: a few more doable things that the picture has no room for (hidden cards from the server); each tile opens its card
      var ds = [].slice.call(document.querySelectorAll('dialog[data-xname]')).slice(0, a.remote.hereDo);
      o.menu = ds.map(function (e) { return { label: e.getAttribute('data-xname'), icon: 'dohere', href: '', menu: [], why: '', badge: '', mlabel: '', remote: {}, cands: [], rem: remKey({ dlg: e }) }; });
      if (!o.menu.length) o.why = 'nothing more';
      return o;
    }
    if (a.remote && a.remote.select === 'tend') {
      if (!q1('.tendform')) { o.why = 'on shift'; return o; }
      if (tendOn) { o.label = 'Done'; o.icon = '✓'; o.rem = remKey({ tend: 'off' }); } else o.rem = remKey({ tend: 'on' });
      return o;
    }
    if (a.remote && a.remote.select === 'garden') {
      if (!q1('.selbar')) { o.why = 'Beds'; return o; }
      if (tool) { o.label = 'Done'; o.icon = '✓'; o.chip = 'tap a bed'; o.menu = []; o.rem = remKey({ tool: tool }); }
      else if (selOn) { o.label = 'Done'; o.icon = '✓'; o.menu = []; o.rem = remKey({ sel: '.selbar [data-sel="off"]' }); }
      else if (a.menu && a.menu.length) o.menu = a.menu.map(finalItem);   // Select and the tools are a strip
      else o.rem = remKey({ sel: '.selbar [data-sel="on"]' });
      return o;
    }
    if (a.remote && a.remote.selectInfo === 'tend' && tendOn) return { label: 'Picked', icon: '🔲', href: '', menu: [], why: '', badge: String(tCount()), info: true, remote: {}, cands: [], mlabel: '' };
    if (a.remote && a.remote.selectInfo === 'garden' && selOn) return { label: 'Picked', icon: '🔲', href: '', menu: [], why: '', badge: String(gCount()), info: true, remote: {}, cands: [], mlabel: '' };
    if (a.remote && (a.remote.doForm || a.remote.sel)) { r = resolveOne(a); o.why = r.why || a.why; o.badge = r.badge || a.badge; o.rem = remKey(a.remote); }
    if (a.menu && a.menu.length) o.menu = a.menu.map(finalItem);
    if (a.remote && a.remote.hideNone && o.menu) { o.menu = o.menu.filter(function (m) { return !m.why; }); if (!o.menu.length) o.why = 'nothing to do'; }
    return o;
  }
  function selStrips() {   // the garden's select mode: Pick on the left, Then on the right (the page's own buttons)
    var cnt = gCount(), pick = G_PICK.map(function (p) { return { label: p[2], icon: p[1], badge: p[0] === 'none' ? '' : gFlagCount(p[0]), rem: remKey({ sel: '.selon [data-q="' + p[0] + '"]' }), why: '' }; }), then = [];
    G_THEN.forEach(function (t) { if (q1(t[2])) then.push({ label: t[1], icon: t[0], rem: remKey({ sel: t[2] }), why: cnt ? '' : 'pick', cls: 'do' }); });
    return [{ items: pick, label: 'Pick squares', side: 'L', flat: false, small: true }, { items: then, label: 'Then do this to the picked ones', side: 'R', flat: false, small: true }];
  }
  var mo = null;
  function watch() {   // pages that set "watch": redraw when the page's own buttons change (select mode on or off, a button disabled)
    var main, t = 0;
    if (mo || !window.MutationObserver) return;
    main = document.querySelector('main'); if (!main) return;
    mo = new MutationObserver(function () { if (D && D.actions.watch) { clearTimeout(t); t = setTimeout(render, 120); } });
    mo.observe(main, { subtree: true, attributes: true, attributeFilter: ['hidden', 'disabled', 'open'], childList: true, characterData: true });
  }

  /* ---- the chain of pieces along the curve ---- */
  function chain(W, g) {
    var pw = g.pw, mw = Math.max(58, Math.min(72, (W - pw - 2 * 64 - 8) / 4)), menus = {}, i;
    D.menus.forEach(function (m) { menus[m.k] = m; });
    var core = [{ k: 'm', m: 'you', w: mw }, { k: 'm', m: 'hobby', w: mw }, { k: 'aL', w: 64 }, { k: 'plate', w: pw }, { k: 'aR', w: 64 }, { k: 'm', m: 'out', w: mw }, { k: 'm', m: 'tog', w: mw }];
    var coreW = core.reduce(function (a, o) { return a + o.w; }, 0), gn = Math.max(1, Math.ceil(((W - coreW) / 2) / 58) + 1), it, n, total, tabs, has1, x, row0 = '', row1 = '', main = '';
    if (gn % 2 === 0) gn++;
    var ghL = [], ghR = [];
    for (i = 0; i < gn; i++) { ghL.push({ k: 'ghost', w: 58, d: gn - i }); ghR.push({ k: 'ghost', w: 58, d: i + 1 }); }
    it = ghL.concat(core, ghR); n = it.length;
    total = it.reduce(function (a, o) { return a + o.w; }, 0);
    tabs = it.map(function () { return [0, 0, 0, 0]; });
    for (i = 0; i < n - 1; i++) { var k = i % 3 === 0 ? 2 : 1, sg = i % 2 ? -1 : 1; tabs[i][1] = sg * k; tabs[i + 1][3] = -sg * k; }
    tabs[gn + 3][0] = -1;   // the plate has a socket on top for the popover
    has1 = it.map(function (o) { return o.k === 'm' || o.k === 'ghost'; });
    it.forEach(function (o, j) { if (has1[j]) tabs[j][2] = (o.k === 'm' || j % 2 === 0) ? 1 : 2; });
    x = (W - total) / 2;
    it.forEach(function (o, j) {
      var ps = place(g, x + o.w / 2, 30), base = { x: ps.x - o.w / 2, y: ps.y - 29, w: o.w, h: 58, rot: ps.rot, tabs: tabs[j] };
      if (has1[j]) {
        var p1 = place(g, x + o.w / 2, 88), t1 = [-tabs[j][2], has1[j + 1] ? (j % 2 ? 1 : -1) : 0, 0, has1[j - 1] ? (j % 2 ? -1 : 1) : 0];
        row1 += pc({ x: p1.x - o.w / 2, y: p1.y - 29, w: o.w, h: 58, rot: p1.rot, tabs: t1, tag: 'div', cls: 'ghost', ghost: true, op: Math.max(.1, .62 - .14 * ((o.d || 1) - 1)).toFixed(2) });
      }
      if (o.k === 'ghost') row0 += pc({ x: base.x, y: base.y, w: base.w, h: base.h, rot: base.rot, tabs: base.tabs, tag: 'div', cls: 'ghost', ghost: true, op: Math.max(.25, .8 - .16 * (o.d - 1)).toFixed(2) });
      else if (o.k === 'm') main += menuPiece(o, base, menus[o.m]);
      else if (o.k === 'plate') main += platePiece(base);
      else main += actPiece(o.k === 'aL' ? 'L' : 'R', ACT[o.k === 'aL' ? 'L' : 'R'], base);
      x += o.w;
    });
    return row1 + row0 + main;
  }
  function menuPiece(o, base, m) {
    if (!m) return '';
    var here = D.here === m.k, open = slip === m.k, b = menuBadge(m);
    base.pat = PAT[m.k]; base.cls = 'menu' + (here ? ' here' : '') + (open ? ' open' : '');
    base.attrs = 'data-m="' + m.k + '" aria-expanded="' + open + '" aria-haspopup="true" aria-label="' + esc(m.name) + ' menu"' + (selOn ? ' disabled' : '');   // the menus wait while squares are being picked
    base.inner = ic(m.k) + '<span class="lb">' + esc(m.name) + '</span>' + (b ? '<b class="badge">' + esc(b) + '</b>' : '');
    return pc(base);
  }
  function petal() { return '<img class="pt" src="' + esc(D.iconBase.replace('img/nav/dock-', 'img/ico/ico-petal.png')) + '" width="14" height="14" alt="Petals">'; }
  function platePiece(base) {
    var p = D.plate, open = slip === 'status';
    base.pat = 'dk-dirt2'; base.cls = 'plate' + (open ? ' open' : '');
    base.attrs = 'id="dockplate" aria-label="Status, tap for more" aria-expanded="' + open + '"';
    base.after = '<span class="pip" aria-hidden="true">▴</span>';
    var ep = p.energy[1] ? Math.round(100 * p.energy[0] / p.energy[1]) : 0, hp = p.hp, hpp = hp && hp[1] ? Math.round(100 * hp[0] / hp[1]) : 0;
    base.inner = '<span>\u26a1<progress max="100" value="' + ep + '"></progress><b class="bn">' + p.energy[0] + '/' + p.energy[1] + '</b></span>'
      + '<span>\ud83c\udf31 <b>' + p.level + '</b><progress class="xp" max="100" value="' + p.xp + '"></progress></span>'
      + (hp ? '<span>\u2764\ufe0f<progress class="hp" max="100" value="' + hpp + '"></progress><b class="bn">' + hp[0] + '/' + hp[1] + '</b></span>' : '<span></span>')
      + '<span>' + (p.time ? esc(p.time) + ' <span class="tag">' + 'd' + p.day + '</span> ' : '') + petal() + ' <span class="tag">' + p.coins + '</span></span>';
    return pc(base);
  }
  function actPiece(side, a, base) {
    if (!a) { base.cls = 'act empty'; base.attrs = 'disabled aria-label="No action"'; base.inner = '<span class="ic">·</span>'; return pc(base); }
    var open = slip === 'act' + side, label = a.label.length > 10 ? a.label.slice(0, 9) + '…' : a.label, link = !a.menu.length && a.href && a.rem === undefined;
    base.cls = 'act' + (side === 'R' && !a.why && !a.info ? ' go' : '') + (a.info ? ' info' : '') + (a.chip && !a.why ? ' soft' : '') + (a.qk === 'confirm' ? ' open' : '') + (open ? ' open' : '');
    base.tag = link && !a.why ? 'a' : 'button';
    base.attrs = 'data-act="' + side + '" aria-label="' + esc(a.label) + '"' + (link && !a.why ? ' href="' + esc(a.href) + '"' : '') + (a.rem !== undefined && !a.why ? ' data-rem="' + a.rem + '"' : '') + (a.qk ? ' data-quick="' + a.qk + '"' : '') + (a.menu.length ? ' aria-haspopup="true" aria-expanded="' + open + '"' : '') + (a.why ? ' disabled' : '') + (a.info ? ' aria-disabled="true"' : '');
    base.inner = ic(a.icon) + '<span class="lb">' + esc(label) + '</span>' + (a.badge && !a.why ? '<b class="badge">' + esc(a.badge) + '</b>' : '') + ((a.why || a.chip) ? '<span class="chip">' + esc(a.why || a.chip) + '</span>' : '');
    base.after = (a.menu.length ? '<span class="pip" aria-hidden="true">▴</span>' : '') + (a.qx ? '<span class="qx" role="button" data-qx="' + a.qx + '" aria-label="' + (a.qx === 'cancel' ? 'Cancel' : 'Clear the Quick button') + '">✕</span>' : '');
    return pc(base);
  }

  /* ---- strips and the popover ---- */
  function stripList() {
    var m, a;
    if (slip === 'sel') return tendOn ? tendStrips() : selStrips();
    if (slip === 'actL' || slip === 'actR') {
      a = ACT[slip === 'actL' ? 'L' : 'R'];
      return a ? [{ items: a.menu.map(function (t) { return { href: t.href, label: t.label, icon: t.icon, badge: t.badge, why: t.why, on: false, rem: t.rem }; }), label: a.mlabel || a.label, flat: true, side: 'C' }] : [];
    }
    D.menus.forEach(function (x) { if (x.k === slip) m = x; });
    return m ? [{ items: m.tiles, label: m.name, flat: false, side: (slip === 'you' || slip === 'hobby') ? 'L' : 'R' }] : [];
  }
  function stripHTML(s, W, g) {
    var n = s.items.length, th = 54, per = Math.floor((W / 2 - 16) / Math.max(1, n)), tw = s.small ? Math.max(44, Math.min(50, per)) : Math.max(44, Math.min(58, per)), o = '', prev = 0;
    var startX = s.flat ? W / 2 - n * tw / 2 : (s.side === 'L' ? 8 : W - 8 - n * tw);
    s.items.forEach(function (t, i) {
      var r = i < n - 1 ? (i % 2 ? -1 : 1) : 0, l = i > 0 ? -prev : 0, ps, fromRight = s.flat || s.side !== 'R', rem = t.rem !== undefined && !t.why, link = t.href && !t.why && !rem;
      prev = r; ps = place(g, startX + tw * (i + .5), -(th / 2 + 9));
      o += pc({ x: ps.x - tw / 2, y: ps.y - th / 2, w: tw, h: th, rot: ps.rot, tabs: [0, r, 0, l], tag: rem ? 'button' : link ? 'a' : 'span', cls: 'tile' + (t.on ? ' on' : '') + (t.why ? ' dis' : '') + (t.cls ? ' ' + t.cls : ''),
        attrs: (rem ? 'data-rem="' + t.rem + '"' : link ? 'href="' + esc(t.href) + '"' : 'aria-disabled="true"') + (t.on ? ' aria-current="page"' : '') + ' aria-label="' + esc(t.label) + '"', o: fromRight ? i : n - 1 - i, fx: fromRight ? 22 : -22,
        inner: ic(t.icon) + '<span class="lb">' + esc(t.label) + '</span>' + (t.badge && !t.why ? '<b class="badge">' + esc(t.badge) + '</b>' : '') + (t.why ? '<span class="chip">' + esc(t.why) + '</span>' : '') });
    });
    var f = place(g, startX + tw / 2, -(th / 2 + 9));
    return o + '<div class="gname" data-pl="' + startX + ',' + (f.y - th / 2 - 26) + '">' + esc(s.label) + '</div>';
  }
  function slipHTML(W, g) {
    if (!slip) return '';
    if (slip === 'status') return popHTML(W, g);
    return stripList().map(function (s) { return stripHTML(s, W, g); }).join('');
  }

  function popHTML(W, g) {
    var w = Math.min(460, W - 24), h, x, y, body = '', tabs = [['now', 'Now'], ['rail', 'Pots, boosts, tasks'], ['more', 'More']];
    if (D.foe) tabs.unshift(['foe', 'Creature']);
    function rows(list, empty) {
      if (!list.length) return '<div class="row empty">' + esc(empty) + '</div>';
      return list.map(function (r) { return (r[2] ? '<a class="row" href="' + esc(r[2]) + '">' : '<div class="row">') + '<span>' + esc(r[0]) + '</span><b>' + esc(r[1]) + '</b>' + (r[2] ? '</a>' : '</div>'); }).join('');
    }
    if (popTab === 'foe' && D.foe) {
      body = '<div><h4>' + esc(D.foe.name) + '</h4><div class="row"><span>Level</span><b>' + D.foe.level + '</b></div><div class="row"><span>Health</span><b>' + D.foe.hp + '/' + D.foe.max + '</b></div><div class="row"><span>Size</span><b>' + esc(D.foe.size) + '</b></div></div><div><h4>About</h4><div class="row"><span>' + esc(D.foe.text) + '</span></div></div>';
      h = 150;
    } else if (popTab === 'rail') {
      body = '<div><h4>🍳 Pots</h4>' + rows(D.rail.pots, 'None cooking') + '</div><div><h4>✨ Boosts</h4>' + rows(D.rail.boosts, 'No boosts. Eat or cook something.') + '</div><div><h4>📋 Tasks</h4>' + rows(D.rail.tasks, 'No job yet') + '</div>';
      h = 96 + 28 * Math.max(1, D.rail.pots.length, D.rail.boosts.length, D.rail.tasks.length);
    } else if (popTab === 'more') {
      body = '<div><h4>The game</h4>' + D.more.map(function (r) { return '<a class="row" href="' + esc(r[1]) + '"><span>' + esc(r[0]) + '</span></a>'; }).join('') + '</div><div><h4>You</h4><div class="util"><!--dkTHEME--><!--dkLOGOUT--></div></div>';
      h = 96 + 28 * Math.max(3, D.more.length);
    } else {
      body = '<div><h4>Right now</h4>' + D.rows.map(function (r) { return '<div class="row"><span>' + (r[0] === '\ud83e\ude99' ? petal() : esc(r[0])) + '</span>' + esc(r[1]) + '<b>' + esc(r[2]) + '</b></div>'; }).join('') + '</div>'
        + '<div><h4>Jump to</h4>' + D.links.map(function (r) { return '<a class="row" href="' + esc(r[2]) + '">' + esc(r[0]) + (r[1] ? '<b>' + esc(r[1]) + '</b>' : '') + '</a>'; }).join('') + '</div>';
      h = 96 + 28 * Math.max(D.rows.length, D.links.length);
    }
    h = Math.max(150, Math.min(Math.max(150, window.innerHeight / K - DH - 24), h)); x = W / 2 - w / 2; y = g.A + 3 - h;
    return '<div class="pop' + (popTab === 'rail' ? ' wide' : '') + '" data-pl="' + x + ',' + y + ',' + w + ',' + h + '" role="dialog" aria-label="Status">' + pieceSVG(w, h, 0, 0, 1, 0, 0)
      + '<div class="body"><div class="poptabs" role="tablist">' + tabs.map(function (t) { return '<button type="button" role="tab" data-poptab="' + t[0] + '" aria-selected="' + (popTab === t[0]) + '">' + esc(t[1]) + '</button>'; }).join('') + '</div>' + body + '</div></div>';
  }

  /* ---- render ---- */
  var lastDockH = '';
  function dockH(v) {   // the page clears the dock; screens that fit themselves to the window (the puzzle fight) are told when it changes
    document.body.style.setProperty('--dock-h', v);
    if (v !== lastDockH) { lastDockH = v; setTimeout(function () { try { window.dispatchEvent(new Event('resize')); } catch (e) {} }, 60); }
  }
  /* play mode: a thin rail (back, the game's name, energy and time, and a button that opens the full dock) */
  /* full screen: the browser's address bar hides and shows as the page changes and resizes a fight screen (the End turn flash); full screen keeps it away. It needs a tap, so the first tap on a fight enters it, and the rail has a button to leave or enter it. */
  function fsEl() { return document.documentElement; }
  function fsOk() { var el = fsEl(); return !!(el.requestFullscreen || el.webkitRequestFullscreen); }
  function isFs() { return !!(document.fullscreenElement || document.webkitFullscreenElement); }
  function fsEnter() { var el = fsEl(); try { var r = el.requestFullscreen ? el.requestFullscreen({ navigationUI: 'hide' }) : el.webkitRequestFullscreen(); if (r && r.catch) r.catch(function () {}); } catch (x) {} }
  function fsLeave() { try { var r = document.exitFullscreen ? document.exitFullscreen() : document.webkitExitFullscreen(); if (r && r.catch) r.catch(function () {}); } catch (x) {} }
  var fsAuto = true;   // the first tap on a fight enters full screen once; leaving it by hand stops that for the rest of the page
  function inFight() { return !!document.querySelector('#pfight.pf-v1, #pfv-pre'); }
  document.addEventListener('pointerup', function (e) {
    if (!fsAuto || isFs() || !fsOk() || !inFight() || !mq.matches) return;
    if (e.target.closest && e.target.closest('#dockroot')) return;
    fsEnter();
  }, true);
  var fsSelf = false;
  document.addEventListener('fullscreenchange', function () { if (!isFs()) { if (!fsSelf) fsAuto = false; fsSelf = false; } if (D && D.play) render(); });   // left by the browser's own gesture: do not pull the player back in
  document.addEventListener('gv:swapped', function () { if (isFs() && !inFight()) { fsSelf = true; fsLeave(); } });
  var rail = null, playOpen = false;
  function renderRail() {
    var p = D.plate, e = p.energy || [0, 1];
    if (stage) stage.innerHTML = '';
    if (!rail) { rail = document.createElement('div'); rail.className = 'dk-rail'; rail.id = 'dockrail'; root.appendChild(rail); }
    rail.hidden = false;
    rail.innerHTML = (D.play.back ? '<a class="dk-rb" href="' + esc(D.play.back) + '">\u21a9 ' + esc(D.play.backLabel) + '</a>' : '<span class="dk-rb"></span>') + '<b class="dk-rn">' + esc(D.play.name) + '</b>'
      + '<span class="dk-rs">\u26a1 ' + e[0] + '/' + e[1] + (p.time ? ' \u00b7 ' + esc(String(p.time)) : '') + '</span>' + (fsOk() ? '<button type="button" class="dk-rb dk-fs" data-rail="fs" aria-label="Full screen">' + (isFs() ? '\u2715' : '\u26f6') + '</button>' : '') + '<button type="button" class="dk-rb" data-rail="open" aria-label="Open the menu">\u2630 Menu</button>';
    dockH('34px'); document.body.classList.add('dock-rail');
    document.body.classList.add('dock-ready');
  }
  function render() {
    if (!D || !mq.matches) { if (stage) stage.innerHTML = ''; document.body.classList.remove('dock-ready'); return; }
    if (D.play && !playOpen) { renderRail(); return; }
    if (rail) rail.hidden = true;
    document.body.classList.remove('dock-rail');
    var VW = root.clientWidth || window.innerWidth, W, g, old = stage && stage.querySelector('.dockslip'), oldN = old ? old.querySelectorAll('.dk-pc').length : 0;
    if (old && old.parentNode) old.parentNode.removeChild(old);   // kept as an element (not as markup): inline style attributes cannot be re-parsed under the CSP
    REM = [];
    if (tendOn && !q1('.tendform')) { tendOn = false; tSel = {}; }
    selOn = !!(D.actions.watch && ((gSelOn() && !tool) || tendOn));
    tPaint();
    if (selOn) { if (slip !== 'status') slip = 'sel'; } else if (slip === 'sel') slip = null;   // select mode shows its two strips by itself
    ACT = { L: finalAct(D.actions.L), R: finalAct(D.actions.R) };
    var key = slip || '';
    K = scaleFor(VW, window.innerHeight); W = Math.round(VW / K); LW = W; g = geom(W);
    if (!stage) { stage = document.createElement('div'); stage.className = 'dockstage'; root.appendChild(stage); }
    stage.style.height = DH + 'px'; stage.style.width = W + 'px'; stage.style.transform = K > 1 ? 'scale(' + K + ')' : '';   // origin is the bottom left (dock.css)
    dockH(Math.round(DH * K) + 'px');   // the page clears the scaled dock
    var same = key === lastKey;
    stage.innerHTML = pref(defs() + '<div class="dock">' + dockSVG(W, g) + chain(W, g) + '</div><div class="dockslip' + (same ? ' still' : '') + '">' + slipHTML(W, g) + '</div>').replace('<!--dkTHEME-->', D.themeForm).replace('<!--dkLOGOUT-->', D.logoutForm);
    position(stage);
    if (!same && old && oldN && !(window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches)) {   // the old strip comes apart (last piece first) while the new one snaps together
      old.className = 'dockslip dk-ghost'; old.style.setProperty('--n', String(oldN)); stage.appendChild(old);
      clearTimeout(ghostTimer); ghostTimer = setTimeout(function () { if (old.parentNode) old.parentNode.removeChild(old); }, 700);
    }
    lastKey = key;
    document.body.classList.add('dock-ready');
    document.dispatchEvent(new Event('gv:dockdrawn'));   // the tour points at dock pieces; they are new elements after every draw
  }
  function open(k) { slip = slip === k ? null : k; render(); }

  root.addEventListener('click', function (e) {
    var m = e.target.closest('[data-m]'), a = e.target.closest('button[data-act]'), p = e.target.closest('#dockplate'), pt = e.target.closest('[data-poptab]');
    if (pt) { popTab = pt.getAttribute('data-poptab'); render(); return; }
    if (e.target.closest('[data-rail="fs"]')) { if (isFs()) { fsAuto = false; fsLeave(); } else fsEnter(); return; }
    if (e.target.closest('[data-rail="open"]')) { playOpen = true; render(); return; }
    var qx = e.target.closest('[data-qx]'), qb = e.target.closest('[data-quick]'), pk;
    if (qx) { if (qx.getAttribute('data-qx') === 'cancel') { qMode = false; render(); } else postTo(D.quickUrl, { do: 'clear', back: D.back }); return; }
    if (qb && !qb.disabled) {
      var qk = qb.getAttribute('data-quick');
      if (lp) { lp = false; return; }
      if (qk === 'empty') { qMode = true; render(); }
      else if (qk === 'confirm') { pk = satchelPick(); if (pk && !pk.no) { qMode = false; postTo(D.quickUrl, { do: 'set', item_id: pk.id, back: D.back }); render(); } }
      else if (qk === 'fightsnack') {
        var nn = q1('input[name="nonce"]');   // a puzzle fight: its own page carries the fight's nonce; an old fight takes the snack by item
        if (D.foe.pf) { if (nn) postTo(D.quickUrl.replace('quick.php', 'adventure.php'), { do: 'pf_quick', nonce: nn.value }); }
        else postTo(D.quickUrl.replace('quick.php', 'adventure.php'), { do: 'snack', item: D.quick.id });
      }
      else if (qk === 'use' || qk === 'useonly') postTo(D.quickUrl, { do: 'use', back: D.back });
      return;
    }
    var rm = e.target.closest('[data-rem]');
    if (rm && !rm.disabled) { if (remoteGo(REM[parseInt(rm.getAttribute('data-rem'), 10)]) !== 'keep' && !selOn) slip = null; render(); return; }   // a piece that works a control on the page
    if (m) { open(m.getAttribute('data-m')); return; }
    if (p) { open('status'); return; }
    if (a && !a.disabled) {
      var side = a.getAttribute('data-act'), act = ACT[side];
      if (act && act.menu.length) { open('act' + side); return; }
      if (act && !act.href && act.label === 'Back') {   // Back: one step back in the game, else home
        var ok = false; try { ok = history.length > 1 && document.referrer && new URL(document.referrer).origin === location.origin; } catch (x) { ok = false; }
        if (ok) history.back(); else location.href = D.home;
      }
    }
  });
  root.addEventListener('pointerdown', function (e) {   // hold the Quick piece to clear it (the x does the same; a held press never also counts as a tap)
    var b = e.target.closest('[data-quick="use"]');
    lp = false; clearTimeout(lpT);
    if (b && !e.target.closest('[data-qx]')) { b.classList.add('dk-holding'); lpT = setTimeout(function () { lp = true; b.classList.remove('dk-holding'); postTo(D.quickUrl, { do: 'clear', back: D.back }); }, 650); }
  });
  ['pointerup', 'pointercancel', 'pointerleave'].forEach(function (ev) { root.addEventListener(ev, function () { clearTimeout(lpT); Array.prototype.forEach.call(root.querySelectorAll('.dk-holding'), function (x) { x.classList.remove('dk-holding'); }); }); });
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && slip) { slip = null; render(); } });
  document.addEventListener('click', function (e) {   /* community Select mode: a tap on a bed picks or drops it */
    var b = tendOn && e.target.closest && e.target.closest('.cbed[data-bed]'), k;
    if (!b || e.target.closest('button')) return;
    k = b.getAttribute('data-bed'); if (tSel[k]) delete tSel[k]; else tSel[k] = 1;
    e.preventDefault(); render();
  }, true);
  document.addEventListener('click', function (e) {   /* tool mode: a bed tap picks that bed alone (None first, then the page's own pick), then the armed action runs */
    var a, act;
    if (!tool || !gSelOn()) return;
    a = e.target.closest && e.target.closest('#yard a.tile'); if (!a) return;
    q1('.selbar [data-q="none"]') && q1('.selbar [data-q="none"]').click();
    setTimeout(function () { var b = q1(G_TOOL[tool]); if (b && gCount() === 1) b.click(); }, 40);
  }, true);
  document.addEventListener('click', function (e) { if (D && D.play && playOpen && !slip && e.target.isConnected && !root.contains(e.target)) { playOpen = false; render(); return; } if (slip && e.target.isConnected && !root.contains(e.target)) { slip = null; render(); } });   // a click on a piece re-draws the dock, so its target is no longer in the page: that is a click inside

  /* v2.8.06: energy feedback. Spend: the bar glows, then drains while a "-x" ghost floats up from its edge. Gain: it fills, glows, "+x" rises. Replaces the "(-1 energy)" words in messages. */
  var lastEn = null, enAnim = null;
  var RM = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  function enStore(v, m) { try { sessionStorage.setItem('gv_en', v + '/' + m); } catch (x) {} }
  function enRead() { try { var t = (sessionStorage.getItem('gv_en') || '').split('/'); return t.length === 2 ? [+t[0], +t[1]] : null; } catch (x) { return null; } }
  function stripEnergyWords() {
    document.querySelectorAll('.flash, .notice, .box.report').forEach(function (el) {
      var w = document.createTreeWalker(el, NodeFilter.SHOW_TEXT), n;
      while ((n = w.nextNode())) if (/\((?:\u2212|-)\d+ energy\)/.test(n.nodeValue)) n.nodeValue = n.nodeValue.replace(/\s*\((?:\u2212|-)\d+ energy\)/g, '');
    });
  }
  function enGhost(txt, up, anchor, pct) {
    var r = anchor.getBoundingClientRect(), g = document.createElement('span');
    g.className = 'dockghost' + (up ? ' up' : ''); g.setAttribute('aria-hidden', 'true'); g.textContent = txt;
    g.style.fontSize = Math.round(12 * K) + 'px';
    document.body.appendChild(g);
    var gw = g.offsetWidth, gh = g.offsetHeight, x = r.left + r.width * (pct === null ? .5 : pct / 100) - gw / 2;
    x = Math.max(r.left - 8, Math.min(r.right + 8 - gw, x));
    g.style.left = Math.round(x) + 'px'; g.style.top = Math.round(r.top - 2 - gh) + 'px';
    var done = function () { if (g.parentNode) g.parentNode.removeChild(g); };
    if (!g.animate) { setTimeout(done, 1100); return; }
    var kf = RM.matches ? [{ opacity: 1 }, { opacity: 1, offset: .8 }, { opacity: 0 }]
      : [{ opacity: 0, transform: 'translateY(3px)' }, { opacity: 1, transform: 'translateY(0)', offset: .15 }, { opacity: 1, transform: 'translateY(-14px)', offset: .6 }, { opacity: 0, transform: 'translateY(-22px)' }];
    g.animate(kf, { duration: 1100, easing: 'cubic-bezier(.2,.6,.3,1)' }).onfinish = done;
  }
  function curBar() { return root.querySelector('#dockplate progress'); }
  function energyFx() {
    if (!D || !D.plate || !D.plate.energy) return;
    var cur = D.plate.energy[0], max = D.plate.energy[1], prev = enRead();
    enStore(cur, max);
    if (!prev || prev[1] !== max || prev[0] === cur || !mq.matches) return;
    var d = cur - prev[0], up = d > 0, txt = (up ? '+' : '\u2212') + Math.abs(d) + '\u00a0\u26a1';
    if (enAnim) { cancelAnimationFrame(enAnim); enAnim = null; }
    var bar = root.querySelector('#dockplate progress');
    if (!bar) { var rs = root.querySelector('.dk-rs'); if (rs) enGhost(txt, up, rs, null); return; }
    var from = max ? 100 * prev[0] / max : 0, to = max ? 100 * cur / max : 0;
    if (RM.matches) { enGhost(txt, up, bar, to); return; }
    bar.value = from;
    if (bar.animate) bar.animate([{ filter: 'brightness(1)' }, { filter: up ? 'brightness(1.5) saturate(1.5)' : 'brightness(1.6)', offset: up ? .6 : .17 }, { filter: 'brightness(1)' }], { duration: up ? 1000 : 820 });
    var delay = up ? 0 : 220, dur = up ? 550 : 650, t0 = null;
    setTimeout(function () { if (up) setTimeout(function () { var b2 = curBar(); if (b2) enGhost(txt, true, b2, to); }, 400); else var b2 = curBar(); if (b2) enGhost(txt, false, b2, to); }, up ? 0 : delay);
    function step(t) {
      if (t0 === null) t0 = t + delay;
      var k = Math.max(0, Math.min(1, (t - t0) / dur)), e = 1 - Math.pow(1 - k, 3);
      var b3 = curBar(); if (b3) b3.value = from + (to - from) * e;
      enAnim = k < 1 ? requestAnimationFrame(step) : null;
    }
    enAnim = requestAnimationFrame(step);
  }
  document.addEventListener('gv:swapped', function () { tSel = {}; if (!q1('.selbar')) tool = null; qMode = false; playOpen = false; if (!selOn) slip = null; if (readData()) { watch(); render(); energyFx(); } stripEnergyWords(); });   // an in-place page load: new plate numbers and actions
  var rt = 0;
  function relayout() { clearTimeout(rt); rt = setTimeout(render, 80); }
  window.addEventListener('resize', relayout);
  window.addEventListener('orientationchange', relayout);
  if (mq.addEventListener) mq.addEventListener('change', render); else if (mq.addListener) mq.addListener(render);

  /* the message bell: the page's own top message list (.msglog.top, hidden in this layout) opens as a scrollable popover from a bell at the far right of the dock */
  var mBtn = null, mPop = null;
  function msgLi() { return [].slice.call(document.querySelectorAll('.msglog.top .mllist li')).filter(function (l) { return !l.classList.contains('mlempty'); }); }
  function msgSeenKey() { var l = msgLi()[0]; return l ? l.textContent.trim().slice(0, 80) : ''; }
  function msgUpdate() {
    var n = msgLi().length, seen = '';
    if (!D) return;
    if (!mBtn) {
      mBtn = document.createElement('button'); mBtn.type = 'button'; mBtn.className = 'dk-msg'; mBtn.setAttribute('aria-label', 'Messages'); mBtn.setAttribute('aria-haspopup', 'dialog');
      mBtn.innerHTML = '<img src="' + esc(D.iconBase.replace('img/nav/dock-', 'img/ico/ico-bell.png')) + '" alt=""><span class="dk-msgn" hidden></span>';
      mPop = document.createElement('div'); mPop.className = 'dk-msgpop'; mPop.setAttribute('role', 'dialog'); mPop.setAttribute('aria-label', 'Messages');
      root.appendChild(mBtn); root.appendChild(mPop);
      mBtn.addEventListener('click', function (e) { e.stopPropagation(); if (mPop.classList.contains('dk-on')) { mPop.classList.remove('dk-on'); return; } msgFill(); mPop.classList.add('dk-on'); try { sessionStorage.setItem('dkmsg', msgSeenKey()); } catch (x) {} msgUpdate(); });
      document.addEventListener('click', function (e) { if (mPop.classList.contains('dk-on') && !mPop.contains(e.target) && !mBtn.contains(e.target)) mPop.classList.remove('dk-on'); });
      document.addEventListener('keydown', function (e) { if (e.key === 'Escape') mPop.classList.remove('dk-on'); });
      mPop.addEventListener('click', function (e) { if (e.target.closest('[data-msgx]')) mPop.classList.remove('dk-on'); });
    }
    root.classList.toggle('dk-has', n > 0);
    try { seen = sessionStorage.getItem('dkmsg') || ''; } catch (x) {}
    var dot = mBtn.querySelector('.dk-msgn'), fresh = n > 0 && msgSeenKey() !== seen;
    dot.hidden = !fresh; dot.textContent = fresh ? String(Math.min(n, 99)) : '';
    if (mPop.classList.contains('dk-on')) msgFill();
  }
  function msgFill() {
    var src = document.querySelector('.msglog.top .mllist');
    mPop.innerHTML = '<header><span>Messages</span><button type="button" data-msgx aria-label="Close">\u2715</button></header>';
    if (src) { var ul = src.cloneNode(true); mPop.appendChild(ul); }
  }
  document.addEventListener('gv:swapped', function () { setTimeout(msgUpdate, 0); });
  var dockMo = window.MutationObserver ? new MutationObserver(function () { clearTimeout(msgUpdate.t); msgUpdate.t = setTimeout(msgUpdate, 150); }) : null;
  if (dockMo) { var cw = document.querySelector('.chrome2'); if (cw) dockMo.observe(cw, { subtree: true, childList: true, characterData: true }); }
  try { if (readData()) { watch(); render(); msgUpdate(); energyFx(); } stripEnergyWords(); } catch (err) { document.body.classList.remove('dock-ready'); if (window.console) console.warn('dock: ' + (err && err.message)); }
})();
