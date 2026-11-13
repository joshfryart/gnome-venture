/* Puzzle combat piece renderer for the v1 fight and the Puzzle box (2.6.89): the jigsaw kit (assets/img/pfight/parts47/, drawn in Aseprite, built by tools/build_parts47.py) when its atlas.json says version 47,
   otherwise exactly the old renderer of assets/pfparts.js (a copy of it, so the old board keeps its own untouched file). Exposes window.PFParts.
   Old kit: base + one stamp per non-flat side (index colours) -> recolour by type -> icon -> number. Jigsaw kit: tile -> frame -> socks -> glyph -> plate and number. If any file is missing, ok stays false and the page keeps its CSS tiles. */
(function () {
  var root = document.getElementById('pfight');
  var data = {}; try { data = JSON.parse(document.getElementById('pf-data').textContent); } catch (e) { return; }
  if (!root || !data.parts) return;
  var base = data.parts;
  if (window.PFParts && window.PFParts.ok) { setTimeout(function () { document.dispatchEvent(new Event('pfparts-ready')); }, 0); return; }   // already loaded (the page was swapped in place)
  var P = window.PFParts = { ok: false, atlas: null, rim: null, imgs: {}, sheets: {}, cache: {} };
  var ROLE = { INK: 1, RIM_ME: 2, STITCH_ME: 3, RIM_FOE: 4, BAND_FOE: 5, STITCH_FOE: 6, THORN_TIP: 7, THORN_BODY: 8, PLATE: 9, PLATE_SHADE: 10 };
  var FONT = { '0': '111101101101111', '1': '010110010010111', '2': '111001111100111', '3': '111001111001111', '4': '101101111001001', '5': '111100111001111', '6': '111100111101111', '7': '111001001001001', '8': '111101111101111', '9': '111101111001111' };

  function loadImg(file) {
    return new Promise(function (ok, bad) { var i = new Image(); i.onload = function () { ok(i); }; i.onerror = function () { bad(new Error(file)); }; i.src = base + file; });
  }
  function pixels(img) {
    var c = document.createElement('canvas'); c.width = img.width; c.height = img.height;
    var x = c.getContext('2d', { willReadFrequently: true }); x.drawImage(img, 0, 0);
    return { w: img.width, h: img.height, d: x.getImageData(0, 0, img.width, img.height).data };
  }
  function getJson(file) { return fetch(base + file).then(function (r) { if (!r.ok) throw new Error(file); return r.json(); }); }

  var TAGICON = { quick: 'jab', heavy: 'smash', pierce: 'pierce', poison: 'sting', trip: 'trip', bash: 'bash', hold: 'brace', evade: 'roll', thorns: 'thornhide', mend: 'mending', hum: 'hum', lull: 'lull', bond: 'bond', pluck: 'pluck' };
  P.marks = {};   // 'tag-pierce', 'mod-sticky', 'rarity-1' -> image (parts/marks/), when the file exists
  var MARKAT = { strip: { tag: [13, 32], mod: [49, 32], rarity: [51, 7] }, hand: { tag: [24, 64], mod: [96, 64], rarity: [98, 18] } };
  P.tagIcon = {};   // 'tag|size' -> image, when the file exists (a tag without one keeps its type icon)
  function loadTagIcons() {
    var jobs = [];
    Object.keys(TAGICON).forEach(function (tag) {
      [['strip', '-s'], ['hand', '']].forEach(function (z) {
        jobs.push(new Promise(function (ok) { var i = new Image(); i.onload = function () { P.tagIcon[tag + '|' + z[0]] = i; ok(); }; i.onerror = ok; i.src = data.art + 'ico-' + TAGICON[tag] + z[1] + '.png'; }));
      });
    });
    return Promise.all(jobs);
  }
  function loadMarks() {
    var names = ['rarity-0', 'rarity-1', 'rarity-2'];
    Object.keys(TAGICON).forEach(function (t) { names.push('tag-' + t); });
    Object.keys(data.mods || {}).forEach(function (m) { names.push('mod-' + m); });
    return Promise.all(names.map(function (n) { return new Promise(function (ok) { var i = new Image(); i.onload = function () { P.marks[n] = i; ok(); }; i.onerror = ok; i.src = base + 'marks/' + n + '.png'; }); }));
  }
  P.load = function () {
    var A, R;
    return getJson('atlas.json').then(function (a0) {
      A = P.atlas = a0;
      if (A.version === 47) return load47(A).then(function () { return null; });   // 2.6.89: the jigsaw kit (final-colour sheets, no role indices)
      return getJson('rim.json').then(function (r0) { R = P.rim = r0; return loadOld(A); });
    }).then(function () { return data.art ? loadTagIcons() : null; }).then(loadMarks).then(function () { P.ok = true; if (P.atlas && P.atlas.version === 47 && root) root.classList.add('pf-jig'); });   // pf-jig: the CSS of the jigsaw proportions
  };
  function load47(A) {
    var files = [];
    ['strip', 'hand'].forEach(function (z) { Object.keys(A.sheets[z]).forEach(function (k) { files.push([z + '-' + k, A.sheets[z][k]]); }); });
    ['joint-h.png', 'joint-v.png', 'chain-glow-h.png', 'chain-glow-v.png', 'combo-stamp-small.png', 'combo-stamp-big.png'].forEach(function (f) { files.push([f, f]); });
    return Promise.all(files.map(function (f) { return loadImg(f[1]).then(function (img) { P.imgs[f[0]] = img; P.sheets[f[0]] = pixels(img); }); }));
  }
  function loadOld(A) {
    {
      var files = [];
      Object.keys(A.sheets).forEach(function (k) { files.push([k, A.sheets[k].file]); });
      Object.keys(A.patterns).forEach(function (k) { files.push(['pat-' + k, A.patterns[k].file]); });
      Object.keys(A.icons).forEach(function (k) { files.push(['ico-' + k, A.icons[k].file]); });
      ['joint-h.png', 'joint-v.png', 'chain-glow-h.png', 'chain-glow-v.png', 'combo-stamp-small.png', 'combo-stamp-big.png'].forEach(function (f) { files.push([f, f]); });
      return Promise.all(files.map(function (f) { return loadImg(f[1]).then(function (img) { P.imgs[f[0]] = img; P.sheets[f[0]] = pixels(img); }); }));
    }
  }

  function hsl(h, s, l) {
    var a = s * Math.min(l, 1 - l), f = function (n) { var k = (n + h / 30) % 12; return Math.round(255 * (l - a * Math.max(-1, Math.min(k - 3, 9 - k, 1)))); };
    return [f(0), f(8), f(4)];
  }
  function palette(old, tint) {
    var def = P.rim.palettes['default'], o = old ? P.rim.palettes.old : {}, p = {};
    Object.keys(ROLE).forEach(function (k) { p[ROLE[k]] = o[k] || def[k]; });
    if (tint !== undefined && tint !== null) {   // a creature's own colour on its rim (roles 4-8); an old piece is dimmed
      var d = old ? .72 : 1;
      p[4] = hsl(tint, .5, .42 * d); p[5] = hsl(tint, .55, .2 * d); p[6] = hsl(tint, .5, .6 * d); p[8] = hsl(tint, .5, .36 * d);
    }
    return p;
  }

  /* o = {size:'strip'|'hand', owner:'me'|'foe', type, edges:{L:[kind,fam],..}, old, num}. Returns a new canvas (the composed piece). */
  P.piece = function (o) {
    var key = [o.size, o.owner, o.type, o.tag || '', o.m || '', o.old ? 1 : 0, o.num, o.owner === 'foe' && o.tint != null ? o.tint : '', ['L', 'R', 'T', 'B'].map(function (s) { return o.edges[s][0] + ':' + (o.edges[s][1] || ''); }).join('/')].join('|');
    var hit = P.cache[key];
    if (!hit) hit = P.cache[key] = build(o);
    var c = document.createElement('canvas'); c.width = hit.width; c.height = hit.height; c.getContext('2d').drawImage(hit, 0, 0);
    return c;
  };

  function build(o) {
    if (P.atlas.version === 47) return build47(o);
    var A = P.atlas, sz = A.sizes[o.size], W = sz.piece[0], H = sz.piece[1], sh = P.sheets[o.size + '-' + o.owner], meta = A.sheets[o.size + '-' + o.owner];
    var role = new Uint8Array(W * H);
    var b = meta.base;
    for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) { var q = ((b.y + y) * sh.w + b.x + x) * 4; if (sh.d[q + 3] > 0) role[y * W + x] = sh.d[q]; }
    ['L', 'R', 'T', 'B'].forEach(function (s) {
      var e = o.edges[s]; if (!e || e[0] === 'flat') return;
      var st = meta.stamps[s + ':' + e[0] + ':' + e[1]]; if (!st) return;
      var bb = st.bbox;
      for (var y = bb[1]; y < bb[3]; y++) for (var x = bb[0]; x < bb[2]; x++) {
        var q = ((st.y + y) * sh.w + st.x + x) * 4;
        if (sh.d[q + 3] > 0) role[y * W + x] = sh.d[q] === A.erase ? 0 : sh.d[q];
      }
    });
    var pal = palette(o.old, o.owner === 'foe' ? o.tint : null), ty = A.types[o.type], pat = P.sheets['pat-' + o.size], pm = A.patterns[o.size];
    var pc = pm.order.indexOf(o.type) * pm.cell[0];
    var cv = document.createElement('canvas'); cv.width = W; cv.height = H;
    var cx = cv.getContext('2d'), img = cx.createImageData(W, H);
    for (var i = 0; i < W * H; i++) {
      var r = role[i]; if (!r) continue;
      var c;
      if (r === 11) { var py = Math.floor(i / W), px = i % W, pq = (py * pat.w + pc + px) * 4; c = pat.d[pq + 3] > 0 && pat.d[pq] === 255 ? ty.mark : ty.base; }
      else if (r === 12) c = ty.shade; else if (r === 13) c = ty.light; else if (r === 14) c = ty.base; else c = pal[r] || [255, 0, 255];
      img.data[i * 4] = c[0]; img.data[i * 4 + 1] = c[1]; img.data[i * 4 + 2] = c[2]; img.data[i * 4 + 3] = 255;
    }
    cx.putImageData(img, 0, 0);
    var ic = P.imgs['ico-' + o.size], im = A.icons[o.size], ii = im.order.indexOf(o.type);
    var ti = o.tag ? P.tagIcon[o.tag + '|' + o.size] : null;   // a tag with its own icon replaces the type icon
    if (ti) cx.drawImage(ti, sz.icon.at[0], sz.icon.at[1], im.cell[0], im.cell[1]);
    else cx.drawImage(ic, ii * im.cell[0], 0, im.cell[0], im.cell[1], sz.icon.at[0], sz.icon.at[1], im.cell[0], im.cell[1]);
    number(cx, sz.plate, String(o.num), o.size === 'hand' ? 2 : 1);
    var at = MARKAT[o.size], mk = function (name, a) { var im = P.marks[name]; if (im) cx.drawImage(im, a[0], a[1]); };
    if (o.tag) mk('tag-' + o.tag, at.tag);
    if (o.m) { mk('mod-' + o.m, at.mod); if (o.rar !== undefined && o.rar !== null) mk('rarity-' + o.rar, at.rarity); }   // the upgrade's hexagon and its rarity gem with 1-3 pips
    return cv;
  }


  /* ---------------- the jigsaw kit (version 47): tile (no glyph) -> frame (foe / env) -> one sock per non-flat side -> glyph or tag icon -> plate and number -> badge.
     The same stamping as aseprite-source/pfight/v47/scripts/pv47.py piece(). An environment piece is a foe-owner piece with a tint: its tile takes the tint's hue and it gets the env frame. */
  var SIDEN = { L: 'left', R: 'right', T: 'top', B: 'bottom' };
  function rgb2hsl(r, g, b) {
    r /= 255; g /= 255; b /= 255; var mx = Math.max(r, g, b), mn = Math.min(r, g, b), l = (mx + mn) / 2, h = 0, s = 0, d = mx - mn;
    if (d) { s = l > .5 ? d / (2 - mx - mn) : d / (mx + mn); h = mx === r ? ((g - b) / d + (g < b ? 6 : 0)) : mx === g ? (b - r) / d + 2 : (r - g) / d + 4; h *= 60; }
    return [h, s, l];
  }
  function cell(sheet, i, W, H) {   // the pixels of one full-size cell of a sheet
    var sh = P.sheets[sheet], out = new Uint8ClampedArray(W * H * 4), y;
    for (y = 0; y < H; y++) out.set(sh.d.subarray((y * sh.w + i * W) * 4, (y * sh.w + i * W + W) * 4), y * W * 4);
    return out;
  }
  function build47(o) {
    var A = P.atlas, sz = A.sizes[o.size], W = sz.piece[0], H = sz.piece[1], ord = A.order, ti = ord.types.indexOf(o.type), env = o.owner === 'foe' && o.tint != null, i, x, y, q;
    var d = cell(o.size + '-tiles', ti, W, H);
    if (env) {   // the tint's hue on every saturated (type colour) pixel, the lightness kept
      for (i = 0; i < W * H; i++) { q = i * 4; if (!d[q + 3]) continue; var mx = Math.max(d[q], d[q + 1], d[q + 2]), mn = Math.min(d[q], d[q + 1], d[q + 2]); if (mx - mn < 40) continue;
        var hs = rgb2hsl(d[q], d[q + 1], d[q + 2]), c2 = hsl(o.tint, Math.min(.62, hs[1] * .8), hs[2]); d[q] = c2[0]; d[q + 1] = c2[1]; d[q + 2] = c2[2]; }
    }
    if (o.old) for (i = 0; i < W * H; i++) { q = i * 4; if (d[q + 3]) { d[q] = d[q] * .78; d[q + 1] = d[q + 1] * .78; d[q + 2] = d[q + 2] * .78; } }   // its last round: the felt is dimmer
    var put = function (src) { for (var k = 0; k < W * H; k++) { var p = k * 4; if (src[p + 3]) { d[p] = src[p]; d[p + 1] = src[p + 1]; d[p + 2] = src[p + 2]; d[p + 3] = 255; } } };
    if (env || o.owner === 'foe') put(cell(o.size + '-frames', ord.frames.indexOf(env ? 'env' : 'foe'), W, H));
    var E = A.erase;
    ['L', 'R', 'T', 'B'].forEach(function (s) {
      var e = o.edges[s]; if (!e || e[0] === 'flat') return;
      var k = ord.socks.indexOf(e[1] + '-' + e[0]); if (k < 0) return;
      var sk = cell(o.size + '-socks', k, W, H), r = sz.socks[SIDEN[s]];
      for (y = r[1]; y < r[3]; y++) for (x = r[0]; x < r[2]; x++) {
        var p = (y * W + x) * 4; if (!sk[p + 3]) continue;
        if (sk[p] === E[0] && sk[p + 1] === E[1] && sk[p + 2] === E[2]) d[p + 3] = 0;   // the hole: a real cut-out
        else { d[p] = sk[p]; d[p + 1] = sk[p + 1]; d[p + 2] = sk[p + 2]; d[p + 3] = 255; }
      }
    });
    var cv = document.createElement('canvas'); cv.width = W; cv.height = H;
    var cx = cv.getContext('2d'), img = cx.createImageData(W, H); img.data.set(d); cx.putImageData(img, 0, 0);
    var ti2 = o.tag ? P.tagIcon[o.tag + '|' + o.size] : null;
    if (!env) {
      if (ti2) cx.drawImage(ti2, sz.icon.at[0], sz.icon.at[1], sz.icon.size[0], sz.icon.size[1]);   // a tag with its own icon replaces the type's glyph
      else cx.drawImage(P.imgs[o.size + '-glyphs'], ti * W, 0, W, H, 0, 0, W, H);
    }
    if (String(o.num) !== '') number47(cx, sz.plate, String(o.num));
    var bi = ord.badges.indexOf('eye'), bw = sz.badge[0];
    if (!env && o.owner === 'foe') cx.drawImage(P.imgs[o.size + '-badges'], bi * bw, 0, bw, sz.badge[1], sz.owner[0], sz.owner[1], bw, sz.badge[1]);
    var mk = function (name, a) { var im = P.marks[name]; if (im) cx.drawImage(im, a[0], a[1]); };
    if (o.m && !env) { mk('mod-' + o.m, sz.extra); if (o.rar !== undefined && o.rar !== null) mk('rarity-' + o.rar, sz.owner); }   // the upgrade's hexagon (bottom right) and its rarity gem (top right)
    return cv;
  }
  function number47(cx, plate, text) {   // the number on its dark plate: 3 x 5 digits, 2 x (strip) or 3 x (hand) size, cream on dark
    var k = plate.k, gw = 3 * k, gh = 5 * k, w = text.length * gw + (text.length - 1) * k, x0 = plate.at[0] + Math.floor((plate.size[0] - w) / 2), y0 = plate.at[1] + Math.floor((plate.size[1] - gh) / 2);
    cx.fillStyle = '#150d07'; cx.fillRect(plate.at[0], plate.at[1], plate.size[0], plate.size[1]);
    cx.fillStyle = '#fff4d6';
    for (var n = 0; n < text.length; n++) {
      var g = FONT[text.charAt(n)]; if (!g) continue;
      for (var j = 0; j < 15; j++) if (g.charAt(j) === '1') cx.fillRect(x0 + n * (gw + k) + (j % 3) * k, y0 + Math.floor(j / 3) * k, k, k);
    }
  }

  function number(cx, plate, text, k) {
    var gw = 3 * k, gh = 5 * k, w = text.length * gw + (text.length - 1) * k, x0 = plate.at[0] + Math.floor((plate.size[0] - w) / 2), y0 = plate.at[1] + Math.floor((plate.size[1] - gh) / 2);
    cx.fillStyle = '#2a1a10';
    for (var n = 0; n < text.length; n++) {
      var g = FONT[text.charAt(n)]; if (!g) continue;
      for (var j = 0; j < 15; j++) if (g.charAt(j) === '1') cx.fillRect(x0 + n * (gw + k) + (j % 3) * k, y0 + Math.floor(j / 3) * k, k, k);
    }
  }

  /* a combo stamp for a chain of n pieces: small for 2-3, big for 4+, the number printed on its plate */
  P.stamp = function (n) {
    var big = n >= 4, img = P.imgs[big ? 'combo-stamp-big.png' : 'combo-stamp-small.png'];
    var c = document.createElement('canvas'); c.width = 32; c.height = 32; var cx = c.getContext('2d'); cx.drawImage(img, 0, 0);
    number(cx, { at: [10, 11], size: [12, 10] }, String(n), 1);
    return c;
  };

  /* the lit-spot ghost: the piece's silhouette as a gold/cream dashed outline (rule in the parts README) */
  P.ghost = function (o) {
    var key = 'g|' + [o.size, o.owner, ['L', 'R', 'T', 'B'].map(function (s) { return o.edges[s][0] + ':' + (o.edges[s][1] || ''); }).join('/')].join('|');
    if (!P.cache[key]) {
      var src = build({ size: o.size, owner: o.owner, type: 'hurt', edges: o.edges, num: '' }), W = src.width, H = src.height;
      var sx = src.getContext('2d').getImageData(0, 0, W, H).data, cv = document.createElement('canvas'); cv.width = W; cv.height = H;
      var cx = cv.getContext('2d'), out = cx.createImageData(W, H);
      var op = function (x, y) { return x >= 0 && y >= 0 && x < W && y < H && sx[(y * W + x) * 4 + 3] > 0; };
      for (var y = 0; y < H; y++) for (var x = 0; x < W; x++) {
        if (!op(x, y) || (op(x - 1, y) && op(x + 1, y) && op(x, y - 1) && op(x, y + 1))) continue;
        var g = (x + y) % 4 < 2, q = (y * W + x) * 4;
        out.data[q] = g ? 232 : 242; out.data[q + 1] = g ? 163 : 228; out.data[q + 2] = g ? 23 : 192; out.data[q + 3] = 255;
      }
      cx.putImageData(out, 0, 0); P.cache[key] = cv;
    }
    var c = document.createElement('canvas'); c.width = P.cache[key].width; c.height = P.cache[key].height; c.getContext('2d').drawImage(P.cache[key], 0, 0);
    return c;
  };

  P.load().then(function () { document.dispatchEvent(new Event('pfparts-ready')); }, function () { P.ok = false; });
})();
