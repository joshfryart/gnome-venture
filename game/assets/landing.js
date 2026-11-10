/* 2.6.41: the logged-out front page (includes/landing_view.php). Small living scenes made of the game's own pictures:
   the stroll on the landing card, the garden bed, the Trail walk (camera on the gnome, sprites sorted by feet row), the village folk, the jigsaw.
   Data: the JSON block #lh-data. Each scene starts when it scrolls into view and stays still under prefers-reduced-motion. No inline styles in markup;
   positions are SVG attributes, the rest is classes (CSP). */
(function () {
  'use strict';
  var dataEl = document.getElementById('lh-data');
  if (!dataEl) return;
  var D;
  try { D = JSON.parse(dataEl.textContent || '{}'); } catch (e) { return; }
  var NS = 'http://www.w3.org/2000/svg', XL = 'http://www.w3.org/1999/xlink';
  var still = !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
  var raf = window.requestAnimationFrame ? window.requestAnimationFrame.bind(window) : function (f) { return setTimeout(function () { f(Date.now()); }, 33); };

  function el(tag, at, parent) {
    var n = document.createElementNS(NS, tag);
    for (var k in at) { n.setAttribute(k, at[k]); if (k === 'href') n.setAttributeNS(XL, 'xlink:href', at[k]); }
    if (parent) parent.appendChild(n);
    return n;
  }
  function setHref(n, u) { n.setAttribute('href', u); n.setAttributeNS(XL, 'xlink:href', u); }
  /* a sprite strip shown one frame at a time: a nested <svg> window, the <image> slides (as assets/tilemap.js does) */
  function strip(src, fw, fh, n, x, y, parent) {
    var g = el('svg', { x: x, y: y, width: fw, height: fh, viewBox: '0 0 ' + fw + ' ' + fh, overflow: 'hidden' }, parent);
    var im = el('image', { href: src, x: 0, y: 0, width: fw * n, height: fh, 'image-rendering': 'pixelated' }, g);
    return { box: g, frame: function (f) { im.setAttribute('x', String(-fw * f)); }, show: function (v) { g.setAttribute('class', v ? '' : 'lh-off'); } };
  }
  /* run fn the first time node is on screen (at once where IntersectionObserver is missing) */
  function whenSeen(node, fn) {
    if (!node) return;
    if (!('IntersectionObserver' in window)) { fn(); return; }
    var io = new IntersectionObserver(function (es) { for (var i = 0; i < es.length; i++) if (es[i].isIntersecting) { io.disconnect(); fn(); return; } }, { rootMargin: '200px' });
    io.observe(node);
  }

  /* ---- landing card: in from the left, a stop to look at you, off to the right; pals trot behind, a villager waits by the path ---- */
  (function () {
    var svg = document.getElementById('lh-hero');
    if (!svg || !D.gnome) return;
    var wren = D.folk && D.folk[0] ? strip(D.folk[0], 64, 96, 4, 372, 146, svg) : null;
    var g = el('g', {}, svg), pals = [];
    (D.pals || []).slice(0, 2).forEach(function (u, i) { pals.unshift(el('image', { href: u, x: [-44, -78][i], y: [46, 50][i], width: 30, height: 30, 'image-rendering': 'pixelated' }, g)); });
    var side = strip(D.gnome.side, 64, 80, 8, -32, 0, g), front = strip(D.gnome.front, 64, 80, 8, -32, 0, g);
    function pose(walk, f) { side.show(walk); front.show(!walk); (walk ? side : front).frame(f); }
    function at(x) { g.setAttribute('transform', 'translate(' + x.toFixed(1) + ' 168)'); }
    function hop(v) { for (var i = 0; i < pals.length; i++) pals[i].setAttribute('y', String([50, 46][i] + (v ? (i ? v : -3 - v) : 0))); }
    pose(false, 0); at(214);
    if (still) return;
    var SP = 64 / 510, X0 = -40, MID = 214, X1 = 600, HOLD = 2600, t0 = 0, seq = [0, 1, 2, 1, 0, 1, 2, 3];
    function tick(now) {
      if (!t0) t0 = now;
      var t = now - t0, a = (MID - X0) / SP, b = a + HOLD, c = b + (X1 - MID) / SP, h = Math.floor(now / 170) % 2 ? -3 : 0;
      if (wren) wren.frame(seq[Math.floor(now / 320) % 8]);
      if (t < a) { pose(true, 2 + Math.floor(t / 170 * 3) % 6); at(X0 + t * SP); hop(h); }
      else if (t < b) { pose(false, Math.floor(t / 420) % 2); at(MID); hop(0); }
      else if (t < c) { pose(true, 2 + Math.floor(t / 170 * 3) % 6); at(MID + (t - b) * SP); hop(h); }
      else t0 = now;
      raf(tick);
    }
    raf(tick);
  })();

  /* ---- Grow: a cursor works the bed square by square; watered plants grow by themselves ---- */
  (function () {
    var bed = document.getElementById('lh-bed'), vb = document.getElementById('lh-verbs');
    if (!bed || !vb) return;
    var tiles = bed.children, verbs = vb.children, st = [5, 4, 3, 2, 1, 0, 2, 3], cur = -1, tick = 0;
    function draw() { for (var i = 0; i < tiles.length; i++) tiles[i].className = 'lh-tile s' + st[i] + (i === cur ? ' cur' : ''); }
    function verb(v) { for (var i = 0; i < verbs.length; i++) verbs[i].className = i === v ? 'on' : ''; }
    draw();
    if (still) return;
    whenSeen(bed, function () {
      setInterval(function () {
        tick++;
        var i, n, N = tiles.length;
        if (tick % 2 === 0) for (i = 0; i < N; i++) if (st[i] === 3 || st[i] === 4) st[i]++;
        for (n = 1; n <= N; n++) { i = (cur + n + N) % N; if (st[i] !== 3 && st[i] !== 4) break; }
        if (n > N) { cur = -1; verb(-1); draw(); return; }
        cur = i;
        if (st[i] === 5) {
          st[i] = 0; verb(3);
          var b = document.createElement('b'); tiles[i].appendChild(b);
          setTimeout(function () { if (b.parentNode) b.parentNode.removeChild(b); }, 950);
        } else { verb(st[i]); st[i]++; }
        draw();
      }, 700);
    });
  })();

  /* ---- Meet: figures standing in the village, idling ---- */
  (function () {
    var svg = document.getElementById('lh-meet');
    if (!svg) return;
    var spots = [[112, 150], [262, 158], [318, 146]];
    var folk = (D.folk || []).slice(0, 3).map(function (u, i) { return strip(u, 64, 96, 4, spots[i][0], spots[i][1], svg); });
    var me = D.gnome ? strip(D.gnome.front, 64, 80, 8, 186, 172, svg) : null;
    if (still || (!folk.length && !me)) return;
    var seq = [0, 1, 2, 1, 0, 1, 2, 3], k = 0;
    whenSeen(svg, function () {
      setInterval(function () { k++; folk.forEach(function (f, i) { f.frame(seq[(k + i * 3) % seq.length]); }); if (me) me.frame(k % 4 < 2 ? 0 : 1); }, 320);
    });
  })();

  /* ---- Explore: a 30 x 18 Trail section: baked ground, raised things sorted by feet row, a 7-tile camera on the walker ---- */
  (function () {
    var box = document.getElementById('lh-trail'), svg = document.getElementById('lh-tsvg'), chip = document.getElementById('lh-tsteps'), tabs = document.getElementById('lh-ttabs');
    var MAPS = D.trails || [];
    if (!box || !svg || !MAPS.length) return;
    var PAD = 40, VH = 448, vw = 448, run = 0, relook = null, q = '?v=' + encodeURIComponent(D.ver || '');
    function fit() { var w = box.clientWidth - 8, s = Math.min(1, w / 448); if (w <= 0) return; vw = w / s; svg.style.height = Math.round(VH * s) + 'px'; }
    if (tabs && MAPS.length > 1) MAPS.forEach(function (m, i) {
      var b = document.createElement('button'); b.type = 'button'; b.id = 'lh-ttab' + i; b.textContent = m.name;
      b.addEventListener('click', function () { load(i); }); tabs.appendChild(b);
    });
    function load(idx) {
      var T = MAPS[idx], my = ++run, i;
      if (tabs) for (i = 0; i < tabs.children.length; i++) tabs.children[i].setAttribute('aria-pressed', i === idx ? 'true' : 'false');
      box.classList.remove('lh-fade');
      while (svg.firstChild) svg.removeChild(svg.firstChild);
      var W = T.w * 64, H = T.h * 64;
      el('image', { href: T.ground, x: 0, y: -PAD, width: W, height: H + PAD, 'image-rendering': 'pixelated' }, svg);
      var layer = el('g', {}, svg), nodes = [];
      T.objs.forEach(function (o) {
        var sz = T.sizes[o[2]] || [64, 96], jy = o[4] || 0, x, y;
        if (sz[0] === 64 && sz[1] === 96) { x = o[0] * 64 + o[3]; y = o[1] * 64 - 29 + jy; } else { x = o[0] * 64 + 32 - sz[0] / 2 + o[3]; y = o[1] * 64 + 62 - sz[1]; }
        nodes.push({ key: (o[1] + .5 + jy / 64) * 1000 + o[0], n: el('image', { href: D.objBase + o[2] + '.png' + q, x: x, y: y, width: sz[0], height: sz[1], 'image-rendering': 'pixelated' }) });
      });
      var finds = T.finds.map(function (f) {
        var n = el('image', { href: T.find, x: f[0] * 64, y: f[1] * 64, width: 64, height: 64, 'image-rendering': 'pixelated' });
        nodes.push({ key: (f[1] + .45) * 1000 + f[0], n: n });
        return n;
      });
      nodes.sort(function (a, b) { return a.key - b.key; });
      nodes.forEach(function (o) { layer.appendChild(o.n); });
      var pts = T.path.map(function (p) { return [p[0] * 64 + 32, p[1] * 64 + 32]; }), steps = pts.length - 1;
      var lx = pts[0][0], ly = pts[0][1], me = null, views = null, view = 'side', slot = null;
      if (D.gnome) {
        me = el('g', {}, layer);
        if (D.pals && D.pals[0]) el('image', { href: D.pals[0], x: -50, y: -6, width: 30, height: 30, 'image-rendering': 'pixelated' }, me);   /* a Puzzle Pal taken along stands beside the gnome */
        views = { side: strip(D.gnome.side, 64, 80, 8, -32, -56, me), front: strip(D.gnome.front, 64, 80, 8, -32, -56, me), back: strip(D.gnome.back, 64, 80, 8, -32, -56, me) };
      }
      var fl = el('g', { 'class': 'lh-tfloat' }, svg), tw = T.item.length * 7.4 + 62;
      el('rect', { x: -tw / 2, y: -92, width: tw, height: 26, 'class': 'lh-tplate' }, fl);
      el('image', { href: T.itemSrc, x: -tw / 2 + 4, y: -91, width: 24, height: 24, 'image-rendering': 'pixelated' }, fl);
      el('text', { x: 14, y: -74, 'text-anchor': 'middle', 'font-size': 13, 'class': 'lh-ttext' }, fl).textContent = '+1 ' + T.item;
      var stops = {};
      T.finds.forEach(function (f, i) { T.path.forEach(function (p, n) { if (p[0] === f[0] && p[1] === f[1] && stops[n] === undefined) stops[n] = i; }); });

      function show(v, flip, f) {
        if (!views) return;
        for (var n in views) views[n].show(n === v);
        views[v].frame(f);
        if (flip) views[v].box.setAttribute('transform', 'scale(-1 1)'); else views[v].box.removeAttribute('transform');
        view = v;
      }
      function put(x, y) {
        lx = x; ly = y;
        if (me) {
          me.setAttribute('transform', 'translate(' + x.toFixed(1) + ' ' + y.toFixed(1) + ')');
          var key = (y / 64) * 1000 + x / 64, i = 0;   /* the feet row decides who is in front */
          while (i < nodes.length && nodes[i].key <= key) i++;
          var before = i < nodes.length ? nodes[i].n : null;
          if (before !== slot) { layer.insertBefore(me, before); slot = before; }
        }
        var cx = Math.round(Math.max(0, Math.min(x - vw / 2, W - vw))), cy = Math.round(Math.max(-PAD, Math.min(y - VH / 2, H - VH)));
        svg.setAttribute('viewBox', cx + ' ' + cy + ' ' + vw.toFixed(1) + ' ' + VH);
      }
      relook = function () { put(lx, ly); };
      var rest = Math.floor(steps * .45);
      show('side', false, 0); put(pts[0][0], pts[0][1]); if (chip) chip.textContent = '0 / ' + steps;
      if (still || !me) { put(pts[rest][0], pts[rest][1]); if (chip) chip.textContent = rest + ' / ' + steps; return; }

      var MS = 170, t0 = 0, held = 0, wait = 0, waitFrom = 0, done = {}, lastN = -1;
      function frame(now) {
        if (my !== run) return;
        if (!t0) t0 = now;
        if (wait) {
          if (now < wait) { views[view].frame(Math.floor(now / 420) % 2); raf(frame); return; }
          held += now - waitFrom; wait = 0;
        }
        var k = (now - t0 - held) / MS, n = Math.floor(k);
        if (n >= steps) {
          put(pts[steps][0], pts[steps][1]); views[view].frame(0); if (chip) chip.textContent = steps + ' / ' + steps;
          setTimeout(function () { if (my === run) box.classList.add('lh-fade'); }, 1100);
          setTimeout(function () { if (my === run) load((idx + 1) % MAPS.length); }, 1500);   /* on to the next trail */
          return;
        }
        if (n !== lastN) {
          lastN = n; if (chip) chip.textContent = n + ' / ' + steps;
          if (stops[n] !== undefined && !done[n]) {   /* a find: stop and pick it up */
            done[n] = true;
            setHref(finds[stops[n]], T.findDone);
            put(pts[n][0], pts[n][1]);
            fl.setAttribute('transform', 'translate(' + pts[n][0] + ' ' + pts[n][1] + ')');
            fl.setAttribute('class', 'lh-tfloat'); void fl.getBoundingClientRect(); fl.setAttribute('class', 'lh-tfloat go');
            waitFrom = now; wait = now + 1100;
            raf(frame); return;
          }
        }
        var f = k - n, a = pts[n], b = pts[n + 1], dx = b[0] - a[0], dy = b[1] - a[1];
        var v = Math.abs(dx) >= Math.abs(dy) ? 'side' : (dy < 0 ? 'back' : 'front');
        show(v, v === 'side' && dx < 0, 2 + (Math.floor(k * 3) % 6));
        put(a[0] + dx * f, a[1] + dy * f);
        raf(frame);
      }
      raf(frame);
    }
    fit();
    window.addEventListener('resize', function () { fit(); if (relook) relook(); });
    whenSeen(box, function () { fit(); load(0); });
  })();

  /* ---- Puzzle: the Easy cut (6 x 4) of the Maplewold picture, pieces gliding home ---- */
  (function () {
    var cv = document.getElementById('lh-jig'), out = document.getElementById('lh-jn');
    if (!cv || !cv.getContext || !D.jigsaw) return;
    var ctx = cv.getContext('2d'), C = 6, R = 4, W = 960, H = 640, pw = W / C, ph = H / R, img = new Image(), seed = 7, r, c;
    function rnd() { seed = (seed * 16807) % 2147483647; return seed / 2147483647; }
    var hT = [], vT = [];
    for (r = 0; r < R; r++) { hT.push([]); vT.push([]); for (c = 0; c < C; c++) { hT[r].push(rnd() < .5 ? 1 : -1); vT[r].push(rnd() < .5 ? 1 : -1); } }
    function edge(ax, ay, bx, by, s) {
      if (!s) { ctx.lineTo(bx, by); return; }
      var dx = bx - ax, dy = by - ay, nx = dy * s, ny = -dx * s;
      function P(t, n) { return [ax + dx * t + nx * n, ay + dy * t + ny * n]; }
      var a = P(.38, 0), b = P(.44, .1), d = P(.28, .24), e = P(.5, .25), f = P(.72, .24), g = P(.56, .1), h = P(.62, 0);
      ctx.lineTo(a[0], a[1]); ctx.bezierCurveTo(b[0], b[1], d[0], d[1], e[0], e[1]); ctx.bezierCurveTo(f[0], f[1], g[0], g[1], h[0], h[1]); ctx.lineTo(bx, by);
    }
    function path(r, c) {
      var x = c * pw, y = r * ph;
      ctx.beginPath(); ctx.moveTo(x, y);
      edge(x, y, x + pw, y, r ? -hT[r - 1][c] : 0);
      edge(x + pw, y, x + pw, y + ph, c < C - 1 ? vT[r][c] : 0);
      edge(x + pw, y + ph, x, y + ph, r < R - 1 ? hT[r][c] : 0);
      edge(x, y + ph, x, y, c ? -vT[r][c - 1] : 0);
      ctx.closePath();
    }
    var ps = [], order = [];
    function deal() {
      ps = []; order = [];
      for (var r = 0; r < R; r++) for (var c = 0; c < C; c++) {
        ps.push({ r: r, c: c, ox: (rnd() * (W - pw) - c * pw) * .92, oy: (rnd() * (H - ph) - r * ph) * .92, t: -1 });
        order.push(ps.length - 1);
      }
      for (var i = order.length - 1; i > 0; i--) { var j = Math.floor(rnd() * (i + 1)), t = order[i]; order[i] = order[j]; order[j] = t; }
    }
    function draw(now, all) {
      ctx.clearRect(0, 0, W, H);
      ctx.fillStyle = '#3d2a1c'; ctx.fillRect(0, 0, W, H);
      ctx.globalAlpha = .16; ctx.drawImage(img, 0, 0, W, H); ctx.globalAlpha = 1;
      var placed = 0;
      for (var pass = 0; pass < 2; pass++) ps.forEach(function (p) {
        var k = all ? 1 : (p.t < 0 ? 0 : Math.min(1, (now - p.t) / 380)), home = k >= 1;
        if ((pass === 0) !== home) return;
        if (pass === 0) placed++;
        var e = 1 - Math.pow(1 - k, 3);
        ctx.save(); ctx.translate(p.ox * (1 - e), p.oy * (1 - e)); path(p.r, p.c);
        if (!home) { ctx.shadowColor = 'rgba(42,26,16,.55)'; ctx.shadowOffsetX = 5; ctx.shadowOffsetY = 7; ctx.fillStyle = '#2a1a10'; ctx.fill(); ctx.shadowColor = 'transparent'; }
        ctx.save(); ctx.clip(); ctx.drawImage(img, 0, 0, W, H); ctx.restore();
        ctx.lineWidth = home ? 1.5 : 3; ctx.strokeStyle = home ? 'rgba(42,26,16,.45)' : '#2a1a10'; ctx.stroke();
        ctx.restore();
      });
      return placed;
    }
    var t0 = 0, next = 0, solvedAt = 0;
    function tick(now) {
      if (!t0) { t0 = now; next = 0; solvedAt = 0; deal(); }
      var due = Math.floor((now - t0 - 700) / 270);
      while (next < order.length && next <= due) { ps[order[next]].t = now; next++; }
      var placed = draw(now, false);
      if (out) out.textContent = placed < 24 ? placed + ' / 24' : 'Solved!';
      if (placed === 24) { if (!solvedAt) solvedAt = now; if (now - solvedAt > 2600) t0 = 0; }
      raf(tick);
    }
    img.onload = function () { deal(); if (still) { draw(0, true); if (out) out.textContent = 'Solved!'; } else raf(tick); };
    whenSeen(cv, function () { img.src = D.jigsaw; });
  })();
})();
