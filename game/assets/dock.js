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
  var D = null, slip = null, lastKey = '', stage = null, ghostTimer = 0, popTab = 'now';
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
      else main += actPiece(o.k === 'aL' ? 'L' : 'R', D.actions[o.k === 'aL' ? 'L' : 'R'], base);
      x += o.w;
    });
    return row1 + row0 + main;
  }
  function menuPiece(o, base, m) {
    if (!m) return '';
    var here = D.here === m.k, open = slip === m.k, b = menuBadge(m);
    base.pat = PAT[m.k]; base.cls = 'menu' + (here ? ' here' : '') + (open ? ' open' : '');
    base.attrs = 'data-m="' + m.k + '" aria-expanded="' + open + '" aria-haspopup="true" aria-label="' + esc(m.name) + ' menu"';
    base.inner = ic(m.k) + '<span class="lb">' + esc(m.name) + '</span>' + (b ? '<b class="badge">' + esc(b) + '</b>' : '');
    return pc(base);
  }
  function platePiece(base) {
    var p = D.plate, open = slip === 'status';
    base.pat = 'dk-dirt2'; base.cls = 'plate' + (open ? ' open' : '');
    base.attrs = 'id="dockplate" aria-label="Status, tap for more" aria-expanded="' + open + '"';
    base.after = '<span class="pip" aria-hidden="true">▴</span>';
    var ep = p.energy[1] ? Math.round(100 * p.energy[0] / p.energy[1]) : 0;
    base.inner = '<span>⚡<progress max="100" value="' + ep + '"></progress></span><span>🌱 <b>' + p.level + '</b><progress class="xp" max="100" value="' + p.xp + '"></progress></span>'
      + '<span>' + (p.time ? '🕐 ' + esc(p.time) + ' <span class="tag">' + (window.innerWidth < 720 ? 'd' + p.day : 'day ' + p.day) + '</span>' : '🪙 <span class="tag">' + p.coins + '</span>') + '</span><span>🪙 <span class="tag">' + p.coins + '</span></span>';
    return pc(base);
  }
  function actPiece(side, a, base) {
    if (!a) { base.cls = 'act empty'; base.attrs = 'disabled aria-label="No action"'; base.inner = '<span class="ic">·</span>'; return pc(base); }
    var open = slip === 'act' + side, label = a.label.length > 10 ? a.label.slice(0, 9) + '…' : a.label, link = !a.menu.length && a.href;
    base.cls = 'act' + (side === 'R' && !a.why ? ' go' : '') + (open ? ' open' : '');
    base.tag = link && !a.why ? 'a' : 'button';
    base.attrs = 'data-act="' + side + '" aria-label="' + esc(a.label) + '"' + (link && !a.why ? ' href="' + esc(a.href) + '"' : '') + (a.menu.length ? ' aria-haspopup="true" aria-expanded="' + open + '"' : '') + (a.why ? ' disabled' : '');
    base.inner = ic(a.icon) + '<span class="lb">' + esc(label) + '</span>' + (a.badge && !a.why ? '<b class="badge">' + esc(a.badge) + '</b>' : '') + (a.why ? '<span class="chip">' + esc(a.why) + '</span>' : '');
    if (a.menu.length) base.after = '<span class="pip" aria-hidden="true">▴</span>';
    return pc(base);
  }

  /* ---- strips and the popover ---- */
  function stripItems() {
    var m, a;
    if (slip === 'actL' || slip === 'actR') {
      a = D.actions[slip === 'actL' ? 'L' : 'R'];
      return a ? { items: a.menu.map(function (t) { return { href: t.href, label: t.label, icon: t.icon, badge: t.badge, why: t.why, on: false }; }), label: a.mlabel || a.label, flat: true, side: 'C' } : null;
    }
    D.menus.forEach(function (x) { if (x.k === slip) m = x; });
    return m ? { items: m.tiles, label: m.name, flat: false, side: (slip === 'you' || slip === 'hobby') ? 'L' : 'R' } : null;
  }
  function slipHTML(W, g) {
    if (!slip) return '';
    if (slip === 'status') return popHTML(W, g);
    var s = stripItems(); if (!s) return '';
    var n = s.items.length, th = 54, tw = Math.max(44, Math.min(58, Math.floor((W / 2 - 16) / Math.max(1, n)))), o = '', prev = 0, startX = s.flat ? W / 2 - n * tw / 2 : (s.side === 'L' ? 8 : W - 8 - n * tw);
    s.items.forEach(function (t, i) {
      var r = i < n - 1 ? (i % 2 ? -1 : 1) : 0, l = i > 0 ? -prev : 0, ps, fromRight = s.flat || s.side !== 'R', link = t.href && !t.why;
      prev = r; ps = place(g, startX + tw * (i + .5), -(th / 2 + 9));
      o += pc({ x: ps.x - tw / 2, y: ps.y - th / 2, w: tw, h: th, rot: ps.rot, tabs: [0, r, 0, l], tag: link ? 'a' : 'span', cls: 'tile' + (t.on ? ' on' : '') + (t.why ? ' dis' : ''),
        attrs: (link ? 'href="' + esc(t.href) + '"' : 'aria-disabled="true"') + (t.on ? ' aria-current="page"' : '') + ' aria-label="' + esc(t.label) + '"', o: fromRight ? i : n - 1 - i, fx: fromRight ? 22 : -22,
        inner: ic(t.icon) + '<span class="lb">' + esc(t.label) + '</span>' + (t.badge && !t.why ? '<b class="badge">' + esc(t.badge) + '</b>' : '') + (t.why ? '<span class="chip">' + esc(t.why) + '</span>' : '') });
    });
    var f = place(g, startX + tw / 2, -(th / 2 + 9));
    return o + '<div class="gname" data-pl="' + (s.flat ? W / 2 - n * tw / 2 : (s.side === 'L' ? 8 : W - 8 - n * tw)) + ',' + (f.y - th / 2 - 26) + '">' + esc(s.label) + '</div>';
  }
  function popHTML(W, g) {
    var w = Math.min(460, W - 24), h, x, y, body = '', tabs = [['now', 'Now'], ['rail', 'Pots, boosts, tasks'], ['more', 'More']];
    function rows(list, empty) {
      if (!list.length) return '<div class="row empty">' + esc(empty) + '</div>';
      return list.map(function (r) { return (r[2] ? '<a class="row" href="' + esc(r[2]) + '">' : '<div class="row">') + '<span>' + esc(r[0]) + '</span><b>' + esc(r[1]) + '</b>' + (r[2] ? '</a>' : '</div>'); }).join('');
    }
    if (popTab === 'rail') {
      body = '<div><h4>🍳 Pots</h4>' + rows(D.rail.pots, 'None cooking') + '</div><div><h4>✨ Boosts</h4>' + rows(D.rail.boosts, 'No boosts. Eat or cook something.') + '</div><div><h4>📋 Tasks</h4>' + rows(D.rail.tasks, 'No job yet') + '</div>';
      h = 96 + 28 * Math.max(1, D.rail.pots.length, D.rail.boosts.length, D.rail.tasks.length);
    } else if (popTab === 'more') {
      body = '<div><h4>The game</h4>' + D.more.map(function (r) { return '<a class="row" href="' + esc(r[1]) + '"><span>' + esc(r[0]) + '</span></a>'; }).join('') + '</div><div><h4>You</h4><div class="util"><!--dkTHEME--><!--dkLOGOUT--></div></div>';
      h = 96 + 28 * Math.max(3, D.more.length);
    } else {
      body = '<div><h4>Right now</h4>' + D.rows.map(function (r) { return '<div class="row"><span>' + esc(r[0]) + '</span>' + esc(r[1]) + '<b>' + esc(r[2]) + '</b></div>'; }).join('') + '</div>'
        + '<div><h4>Jump to</h4>' + D.links.map(function (r) { return '<a class="row" href="' + esc(r[2]) + '">' + esc(r[0]) + (r[1] ? '<b>' + esc(r[1]) + '</b>' : '') + '</a>'; }).join('') + '</div>';
      h = 96 + 28 * Math.max(D.rows.length, D.links.length);
    }
    h = Math.max(150, Math.min(Math.max(150, window.innerHeight - DH - 24), h)); x = W / 2 - w / 2; y = g.A + 3 - h;
    return '<div class="pop' + (popTab === 'rail' ? ' wide' : '') + '" data-pl="' + x + ',' + y + ',' + w + ',' + h + '" role="dialog" aria-label="Status">' + pieceSVG(w, h, 0, 0, 1, 0, 0)
      + '<div class="body"><div class="poptabs" role="tablist">' + tabs.map(function (t) { return '<button type="button" role="tab" data-poptab="' + t[0] + '" aria-selected="' + (popTab === t[0]) + '">' + esc(t[1]) + '</button>'; }).join('') + '</div>' + body + '</div></div>';
  }

  /* ---- render ---- */
  function render() {
    if (!D || !mq.matches) { if (stage) stage.innerHTML = ''; document.body.classList.remove('dock-ready'); return; }
    var W = root.clientWidth || window.innerWidth, g = geom(W), old = stage && stage.querySelector('.dockslip'), oldN = old ? old.querySelectorAll('.dk-pc').length : 0;
    if (old && old.parentNode) old.parentNode.removeChild(old);   // kept as an element (not as markup): inline style attributes cannot be re-parsed under the CSP
    var key = slip || '';
    if (!stage) { stage = document.createElement('div'); stage.className = 'dockstage'; root.appendChild(stage); }
    stage.style.height = DH + 'px';
    var same = key === lastKey;
    stage.innerHTML = pref(defs() + '<div class="dock">' + dockSVG(W, g) + chain(W, g) + '</div><div class="dockslip' + (same ? ' still' : '') + '">' + slipHTML(W, g) + '</div>').replace('<!--dkTHEME-->', D.themeForm).replace('<!--dkLOGOUT-->', D.logoutForm);
    position(stage);
    if (!same && old && oldN && !(window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches)) {   // the old strip comes apart (last piece first) while the new one snaps together
      old.className = 'dockslip dk-ghost'; old.style.setProperty('--n', String(oldN)); stage.appendChild(old);
      clearTimeout(ghostTimer); ghostTimer = setTimeout(function () { if (old.parentNode) old.parentNode.removeChild(old); }, 700);
    }
    lastKey = key;
    document.body.classList.add('dock-ready');
  }
  function open(k) { slip = slip === k ? null : k; render(); }

  root.addEventListener('click', function (e) {
    var m = e.target.closest('[data-m]'), a = e.target.closest('button[data-act]'), p = e.target.closest('#dockplate'), pt = e.target.closest('[data-poptab]');
    if (pt) { popTab = pt.getAttribute('data-poptab'); render(); return; }
    if (m) { open(m.getAttribute('data-m')); return; }
    if (p) { open('status'); return; }
    if (a && !a.disabled) {
      var side = a.getAttribute('data-act'), act = D.actions[side];
      if (act && act.menu.length) { open('act' + side); return; }
      if (act && !act.href && act.label === 'Back') {   // Back: one step back in the game, else home
        var ok = false; try { ok = history.length > 1 && document.referrer && new URL(document.referrer).origin === location.origin; } catch (x) { ok = false; }
        if (ok) history.back(); else location.href = D.home;
      }
    }
  });
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && slip) { slip = null; render(); } });
  document.addEventListener('click', function (e) { if (slip && e.target.isConnected && !root.contains(e.target)) { slip = null; render(); } });   // a click on a piece re-draws the dock, so its target is no longer in the page: that is a click inside
  document.addEventListener('gv:swapped', function () { slip = null; if (readData()) render(); });   // an in-place page load: new plate numbers and actions
  var rt = 0;
  function relayout() { clearTimeout(rt); rt = setTimeout(render, 80); }
  window.addEventListener('resize', relayout);
  window.addEventListener('orientationchange', relayout);
  if (mq.addEventListener) mq.addEventListener('change', render); else if (mq.addListener) mq.addListener(render);

  try { if (readData()) render(); } catch (err) { document.body.classList.remove('dock-ready'); if (window.console) console.warn('dock: ' + (err && err.message)); }
})();
