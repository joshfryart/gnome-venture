/* Gnome Venture v1.4.8: Pest Patrol. Vanilla JS, no libraries.
   The server makes the round (plant design, which pest lands on which leaf and when, the butterfly) and re-scores the taps this file
   sends back. The Machine below plays the SAME rules as pest_sim() in includes/pest.php (rules come from the page's data-rules),
   so what you see on screen is what is scored. Plants are drawn from a small parametric generator: a stem path, a leaf shape,
   and flower / fruit accents per design (25 designs, same order as PEST_PLANTS in PHP). */
(function () {
  'use strict';
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var RAF = window.requestAnimationFrame || function (f) { return setTimeout(function () { f(Date.now()); }, 16); };
  var NOW = (window.performance && performance.now) ? function () { return performance.now(); } : function () { return Date.now(); };

  /*SIM-BEGIN*/
  /* The rules machine. Whole numbers only; every step has a twin in pest_sim() (PHP). `log` collects what the page should show. */
  function makeMachine(round, R) {
    var K = R.kinds, n = round.n, dur = round.dur, alive = [], bru = [], i;
    for (i = 0; i < n; i++) { alive.push(true); bru.push(0); }
    var P = round.pests.map(function (p) {
      return { k: p.k, l: p.l == null ? -1 : p.l, t: p.t || 0, h: p.h || [], hp: K[p.k].hp, alive: true };
    });
    var ev = [];
    P.forEach(function (p, pi) {
      if (p.k === 'g') {
        p.h.forEach(function (hh, j) { ev.push([hh[0], pi, 0, j]); });
        ev.push([p.h[p.h.length - 1][0] + K.g.dwell, pi, 1, 0]);
      } else ev.push([p.t + K[p.k].chew, pi, 2, 0]);
    });
    ev.sort(function (a, b) { return (a[0] - b[0]) || (a[1] - b[1]) || (a[2] - b[2]); });
    var S = { score: 0, combo: 0, best: 0, flicked: 0, lost: 0, bruises: 0, escaped: 0, caught: 0, nonet: 0 };
    var ei = 0, bf = round.bf, bfUsed = false, net = !!round.net, last = -1000000, log = [];
    function curLeaf(p, t) {
      if (!p.h.length || t < p.h[0][0]) return -1;
      var j = Math.floor((t - p.h[0][0]) / K.g.dwell);
      return j < p.h.length ? p.h[j][1] : -1;
    }
    function drop(l, t, why) {
      alive[l] = false; S.lost++; S.score -= R.fall; S.combo = 0;
      log.push({ e: 'drop', leaf: l, why: why });
      P.forEach(function (q, qi) {
        if (!q.alive) return;
        if (q.k === 'g' ? curLeaf(q, t) === l : q.l === l) { q.alive = false; log.push({ e: 'gone', pi: qi, leaf: l }); }
      });
    }
    function advance(t) {
      while (ei < ev.length && ev[ei][0] <= t) {
        var x = ev[ei++], p = P[x[1]];
        if (x[2] === 0) { if (p.alive && !alive[p.h[x[3]][1]]) { p.alive = false; log.push({ e: 'gone', pi: x[1], leaf: -1 }); } }
        else if (x[2] === 1) { if (p.alive) { p.alive = false; S.escaped++; log.push({ e: 'escape', pi: x[1] }); } }
        else if (p.alive && alive[p.l]) drop(p.l, x[0], 'chew');
      }
    }
    function tap(t, target) {
      if (t - last < R.gap) return;
      advance(t);
      last = t;
      if (target === -1) {
        if (bf && !bfUsed && t >= bf[0] + R.bfReact && t <= bf[0] + bf[1]) {
          bfUsed = true;
          if (net) { S.caught = 1; S.score += R.bf; log.push({ e: 'bfcatch' }); } else { S.nonet = 1; log.push({ e: 'bfnonet' }); }
        }
        return;
      }
      if (target < 0 || target >= n || !alive[target]) return;
      var hit = -1, start = 0, pi, p;
      for (pi = 0; pi < P.length; pi++) {
        p = P[pi];
        if (!p.alive) continue;
        if (p.k === 'g') {
          if (curLeaf(p, t) !== target) continue;
          start = p.h[0][0] + Math.floor((t - p.h[0][0]) / K.g.dwell) * K.g.dwell;
        } else {
          if (p.l !== target || t < p.t) continue;
          start = p.t;
        }
        hit = pi; break;
      }
      if (hit >= 0) {
        if (t < start + R.react) return;
        p = P[hit]; p.hp--;
        if (p.hp > 0) { log.push({ e: 'hit', pi: hit, leaf: target }); return; }
        p.alive = false; S.flicked++;
        var fast = (t - start) <= R.quick + R.quickHp * (K[p.k].hp - 1), bonus = 0;
        if (fast) { S.combo++; bonus = Math.min(S.combo - 1, R.cap) * R.step; S.best = Math.max(S.best, S.combo); } else S.combo = 0;
        S.score += K[p.k].pts + bonus;
        log.push({ e: 'flick', pi: hit, leaf: target, pts: K[p.k].pts + bonus, bonus: bonus, combo: S.combo });
      } else {
        S.bruises++; S.combo = 0;
        bru[target]++;
        log.push({ e: 'bruise', leaf: target, n: bru[target] });
        if (bru[target] >= R.bruise) drop(target, t, 'bruise');
      }
    }
    function finish() {
      advance(dur);
      var left = 0, unresolved = 0;
      alive.forEach(function (a) { if (a) left++; });
      P.forEach(function (p) { if (p.alive && (p.k === 'g' ? p.h[0][0] : p.t) <= dur) unresolved++; });
      var o = {};
      for (var k in S) o[k] = S[k];
      o.leaves = left; o.unresolved = unresolved;
      o.score = Math.max(0, S.score + left * R.leaf);
      o.perfect = S.lost === 0 && unresolved === 0 && S.escaped === 0 && S.bruises <= 2 && S.flicked >= 15;
      return o;
    }
    return { P: P, S: S, alive: alive, bru: bru, log: log, advance: advance, tap: tap, finish: finish, curLeaf: curLeaf };
  }
  /*SIM-END*/

  /* ================= plant drawing ================= */
  var TAU = Math.PI * 2, BY = 298, CX = 160;
  function r1(v) { return Math.round(v * 10) / 10; }
  function rad(d) { return d * Math.PI / 180; }
  function ptsPath(pts) { var s = 'M'; for (var i = 0; i < pts.length; i++) s += (i ? 'L' : '') + r1(pts[i][0]) + ' ' + r1(pts[i][1]); return s + 'Z'; }
  function xf(pts, x, y, ang, sx, sy) {
    var c = Math.cos(rad(ang)), s = Math.sin(rad(ang)), o = [];
    for (var i = 0; i < pts.length; i++) {
      var px = pts[i][0] * (sx || 1), py = pts[i][1] * (sy || sx || 1);
      o.push([x + px * c - py * s, y + px * s + py * c]);
    }
    return o;
  }
  var PROF = {
    oval: function (u) { return Math.pow(Math.sin(Math.PI * Math.pow(u, 0.85)), 0.7); },
    egg: function (u) { return Math.pow(Math.sin(Math.PI * Math.pow(u, 0.72)), 0.75); },
    lance: function (u) { return Math.pow(Math.sin(Math.PI * Math.pow(u, 0.9)), 1.05) * (1 - 0.2 * u); },
    round: function (u) { return Math.pow(Math.sin(Math.PI * Math.min(1, u * 0.96 + 0.02)), 0.5); },
    strap: function (u) { return Math.min(1, u * 9) * Math.pow(Math.max(0, 1 - Math.pow(u, 3)), 0.55); },
    fat: function (u) { return Math.min(1, u * 6) * Math.pow(Math.max(0, 1 - Math.pow(u, 4)), 0.5); },
    spoon: function (u) { return Math.pow(Math.sin(Math.PI * Math.pow(u, 0.6)), 0.85); }
  };
  var MOD = {
    teeth: function (k, a) { return function (u) { return 1 + a * ((u * k) % 1 * 2 - 1); }; },
    wave: function (k, a) { return function (u) { return 1 + a * Math.sin(u * k * TAU); }; },
    slit: function (k) { return function (u) { return (u > 0.18 && u < 0.93 && (u * k) % 1 < 0.24) ? 0.4 : 1; }; }
  };
  /* A leaf outline pointing along +x from (0,0). Returns {top, bot} point lists. */
  function outline(L, W, prof, mod, bend, N) {
    N = N || (mod ? 44 : 22);
    var top = [], bot = [];
    for (var i = 0; i <= N; i++) {
      var u = i / N, w = W * PROF[prof](u) * (mod ? mod(u) : 1), cy = (bend || 0) * u * u * L;
      top.push([u * L, cy - w]); bot.push([u * L, cy + w]);
    }
    return { top: top, bot: bot };
  }
  function closed(o) { return o.top.concat(o.bot.slice().reverse()); }
  function heartPts(L, W, mod) {
    var pts = [];
    for (var i = 0; i < 40; i++) {
      var t = i / 40 * TAU, x = 16 * Math.pow(Math.sin(t), 3), y = 13 * Math.cos(t) - 5 * Math.cos(2 * t) - 2 * Math.cos(3 * t) - Math.cos(4 * t), u = (5 - y) / 22;
      pts.push([u * L, x / 16 * W * (mod ? mod(Math.max(0, Math.min(1, u))) : 1)]);
    }
    return pts;
  }
  /* The art for one leaf, in its own frame (attach point at 0,0, pointing +x). Returns {d, hi, rib, holes, reach, shade}. */
  function leafArt(lf) {
    var L = lf.L, W = lf.W, d = '', rib = '', hi = '', holes = '', shade = '', reach = L, o, i, k;
    var sh = lf.shape;
    function lens() { return 'M' + r1(L * 0.12) + ' 0Q' + r1(L * 0.5) + ' ' + r1(-W * 0.62) + ' ' + r1(L * 0.9) + ' ' + r1(-W * 0.04) + 'Q' + r1(L * 0.5) + ' ' + r1(-W * 0.14) + ' ' + r1(L * 0.12) + ' 0Z'; }
    if (sh === 'oval' || sh === 'egg' || sh === 'lance' || sh === 'round' || sh === 'strap' || sh === 'fat' || sh === 'spoon') {
      var mod = lf.mod ? MOD[lf.mod[0]].apply(null, lf.mod.slice(1)) : null;
      o = outline(L, W, sh, mod, lf.bend, mod ? 48 : 24);
      d = ptsPath(closed(o));
      shade = ptsPath(o.bot.concat([[L, (lf.bend || 0) * L], [0, 0]]));
      rib = 'M0 0Q' + r1(L * 0.5) + ' ' + r1((lf.bend || 0) * L * 0.25) + ' ' + r1(L * 0.95) + ' ' + r1((lf.bend || 0) * L * 0.9);
      for (i = 1; i <= 3 && W > 10; i++) {
        var u = i * 0.2 + 0.08, vy = (lf.bend || 0) * u * u * L, wv = W * PROF[sh](u) * 0.7;
        rib += 'M' + r1(L * u) + ' ' + r1(vy) + 'L' + r1(L * (u + 0.14)) + ' ' + r1(vy - wv) + 'M' + r1(L * u) + ' ' + r1(vy) + 'L' + r1(L * (u + 0.14)) + ' ' + r1(vy + wv);
      }
      hi = lens();
    } else if (sh === 'heart') {
      var hm = lf.mod ? MOD[lf.mod[0]].apply(null, lf.mod.slice(1)) : null;
      var hp = heartPts(L, W, hm);
      d = ptsPath(hp);
      rib = 'M0 0L' + r1(L * 0.9) + ' 0M' + r1(L * 0.3) + ' 0L' + r1(L * 0.5) + ' ' + r1(-W * 0.6) + 'M' + r1(L * 0.3) + ' 0L' + r1(L * 0.5) + ' ' + r1(W * 0.6) + 'M' + r1(L * 0.55) + ' 0L' + r1(L * 0.72) + ' ' + r1(-W * 0.38) + 'M' + r1(L * 0.55) + ' 0L' + r1(L * 0.72) + ' ' + r1(W * 0.38);
      hi = lens();
      shade = ptsPath(hp.filter(function (p) { return p[1] >= 0; }).concat([[L * 0.3, 0]]));
    } else if (sh === 'split') {
      var sm = MOD.slit(4);
      var spts = heartPts(L, W, sm);
      d = ptsPath(spts);
      for (i = 0; i < 4; i++) {
        var hu = 0.3 + i * 0.16;
        holes += ptsPath(xf(circlePts(L * 0.035, W * 0.08, 8), L * hu, -W * 0.22, 0)) + ptsPath(xf(circlePts(L * 0.035, W * 0.08, 8), L * hu, W * 0.22, 0));
      }
      rib = 'M0 0L' + r1(L * 0.9) + ' 0M' + r1(L * 0.25) + ' 0L' + r1(L * 0.42) + ' ' + r1(-W * 0.7) + 'M' + r1(L * 0.25) + ' 0L' + r1(L * 0.42) + ' ' + r1(W * 0.7) + 'M' + r1(L * 0.5) + ' 0L' + r1(L * 0.62) + ' ' + r1(-W * 0.55) + 'M' + r1(L * 0.5) + ' 0L' + r1(L * 0.62) + ' ' + r1(W * 0.55);
      hi = lens();
    } else if (sh === 'tri') {
      var ts = lf.sub || 'egg', tm = lf.mod ? MOD[lf.mod[0]].apply(null, lf.mod.slice(1)) : null, sl = L * 0.62, base = L * 0.34;
      var tc = outline(sl, W, ts, tm, 0, 26), t1 = closed(tc);
      d = ptsPath(xf(t1, base, 0, 0)) + ptsPath(xf(t1, base * 0.9, 0, -42, 0.88)) + ptsPath(xf(t1, base * 0.9, 0, 42, 0.88));
      rib = 'M0 0L' + r1(base) + ' 0M0 0L' + r1(base * 0.9) + ' 0M' + r1(base) + ' 0L' + r1(base + sl * 0.9) + ' 0M' + r1(base * 0.9) + ' 0L' + r1(base * 0.9 + Math.cos(rad(-42)) * sl * 0.8) + ' ' + r1(Math.sin(rad(-42)) * sl * 0.8) + 'M' + r1(base * 0.9) + ' 0L' + r1(base * 0.9 + Math.cos(rad(42)) * sl * 0.8) + ' ' + r1(Math.sin(rad(42)) * sl * 0.8);
      reach = L * 0.9;
    } else if (sh === 'compound') {
      var cs = lf.sub || 'egg', cm = lf.mod ? MOD[lf.mod[0]].apply(null, lf.mod.slice(1)) : null, pairs = lf.pairs || 3;
      var lw = W * 0.9, ll = L * 0.34, lt = closed(outline(ll, lw, cs, cm, 0, 28));
      rib = 'M0 0L' + r1(L * 0.95) + ' 0';
      d = ptsPath(xf(lt, L * 0.7, 0, 0, 1.15));
      for (i = 0; i < pairs; i++) {
        var pu = 0.22 + i * (0.5 / pairs), sc = 1 - i * 0.12;
        d += ptsPath(xf(lt, L * pu, 0, -52, sc)) + ptsPath(xf(lt, L * pu, 0, 52, sc));
        rib += 'M' + r1(L * pu) + ' 0L' + r1(L * pu + Math.cos(rad(-52)) * ll * sc * 0.9) + ' ' + r1(Math.sin(rad(-52)) * ll * sc * 0.9) + 'M' + r1(L * pu) + ' 0L' + r1(L * pu + Math.cos(rad(52)) * ll * sc * 0.9) + ' ' + r1(Math.sin(rad(52)) * ll * sc * 0.9);
      }
      reach = L * 0.95;
    } else if (sh === 'frond') {
      var np = 9, ft = closed(outline(L * 0.26, W * 0.5, 'lance', null, 0, 10));
      var bend = lf.bend || 0;
      rib = 'M0 0Q' + r1(L * 0.5) + ' ' + r1(bend * L * 0.25) + ' ' + r1(L) + ' ' + r1(bend * L);
      for (i = 0; i < np; i++) {
        var fu = 0.1 + i * 0.09, fx = L * fu, fy = bend * fu * fu * L, fs = Math.sin(Math.PI * Math.min(1, fu * 1.05)) * 0.8 + 0.25;
        d += ptsPath(xf(ft, fx, fy, -68 + bend * 40, fs)) + ptsPath(xf(ft, fx, fy, 68 + bend * 40, fs));
      }
      d += ptsPath(xf(ft, L * 0.97, bend * L * 0.94, bend * 60, 0.4));
    } else if (sh === 'palm') {   // lobes: a fan of lance leaves (fig, ivy)
      var lobes = lf.lobes || [[0, 1], [-50, 0.72], [50, 0.72]], lb = closed(outline(L * 0.8, W * (lf.lw || 0.36), lf.sub || 'lance', null, 0, 20));
      rib = '';
      lobes.forEach(function (lo) {
        d += ptsPath(xf(lb, L * 0.12, 0, lo[0], lo[1]));
        rib += 'M' + r1(L * 0.12) + ' 0L' + r1(L * 0.12 + Math.cos(rad(lo[0])) * L * 0.7 * lo[1]) + ' ' + r1(Math.sin(rad(lo[0])) * L * 0.7 * lo[1]);
      });
      d += ptsPath(xf(circlePts(L * 0.2, L * 0.2, 12), L * 0.2, 0, 0));
      rib = 'M0 0L' + r1(L * 0.14) + ' 0' + rib;
    }
    return { d: d, hi: hi, rib: rib, holes: holes, shade: shade, reach: reach };
  }
  function circlePts(rx, ry, n) { var p = []; for (var i = 0; i < n; i++) p.push([Math.cos(i / n * TAU) * rx, Math.sin(i / n * TAU) * ry]); return p; }

  /* stems: functions t -> [x, y] */
  function straight(bx, H, bend, ph, by) { by = by || BY; return function (t) { return [bx + bend * Math.sin(t * 3 + ph), by - H * t]; }; }
  function wavy(bx, H, amp, k, by) { by = by || BY; return function (t) { return [bx + amp * Math.sin(t * k * TAU), by - H * t]; }; }
  function arc(x0, y0, x1, y1, bulge) { return function (t) { return [x0 + (x1 - x0) * t + bulge * Math.sin(t * Math.PI), y0 + (y1 - y0) * t - Math.abs(bulge) * 0.4 * Math.sin(t * Math.PI)]; }; }
  function stemPath(f, t0, t1) { var s = ''; for (var i = 0; i <= 24; i++) { var t = t0 + (t1 - t0) * i / 24, p = f(t); s += (i ? 'L' : 'M') + r1(p[0]) + ' ' + r1(p[1]); } return s; }

  /* ----- flowers, fruit ----- */
  function el(tag, a) { var s = '<' + tag; for (var k in a) s += ' ' + k + '="' + a[k] + '"'; return s + '/>'; }
  function circ(x, y, r, f, ex) { return '<circle cx="' + r1(x) + '" cy="' + r1(y) + '" r="' + r1(r) + '" fill="' + f + '"' + (ex || '') + '/>'; }
  function ellp(x, y, rx, ry, f, rot, ex) { return '<ellipse cx="' + r1(x) + '" cy="' + r1(y) + '" rx="' + r1(rx) + '" ry="' + r1(ry) + '" fill="' + f + '"' + (rot ? ' transform="rotate(' + rot + ' ' + r1(x) + ' ' + r1(y) + ')"' : '') + (ex || '') + '/>'; }
  function pth(d, f, ex) { return '<path d="' + d + '" fill="' + f + '"' + (ex || '') + '/>'; }
  function line(d, c, w, ex) { return '<path d="' + d + '" fill="none" stroke="' + c + '" stroke-width="' + w + '" stroke-linecap="round"' + (ex || '') + '/>'; }
  function petalRing(x, y, n, r, pl, pw, fill, rot0, ex) { var s = ''; for (var i = 0; i < n; i++) { var a = rot0 + i * 360 / n; s += ellp(x + Math.cos(rad(a)) * r, y + Math.sin(rad(a)) * r, pl, pw, fill, a, ex); } return s; }
  var ACC = {
    sun: function (x, y, R) {
      var s = petalRing(x, y, 16, R * 0.74, R * 0.34, R * 0.15, '#e5a406', 5) + petalRing(x, y, 16, R * 0.7, R * 0.34, R * 0.16, '#f7c820', 16) + circ(x, y, R * 0.5, '#5a3418') + circ(x, y, R * 0.42, '#7a4a22');
      for (var i = 0; i < 34; i++) { var a = i * 2.39996, rr = R * 0.4 * Math.sqrt((i + 0.5) / 34); s += circ(x + Math.cos(a) * rr, y + Math.sin(a) * rr, R * 0.035, i % 3 ? '#3b2210' : '#a8743a'); }
      return s + ellp(x - R * 0.12, y - R * 0.16, R * 0.18, R * 0.07, '#fff', -30, ' opacity=".18"');
    },
    rose: function (x, y, R, c1, c2) {
      c1 = c1 || '#e8537b'; c2 = c2 || '#b9305a';
      return petalRing(x, y, 5, R * 0.52, R * 0.5, R * 0.46, c1, -90) + circ(x, y, R * 0.62, c2) + petalRing(x, y, 5, R * 0.3, R * 0.34, R * 0.3, c1, -60) + circ(x, y, R * 0.3, c2) +
        line('M' + r1(x - R * 0.2) + ' ' + r1(y) + 'Q' + r1(x) + ' ' + r1(y - R * 0.3) + ' ' + r1(x + R * 0.2) + ' ' + r1(y) + 'Q' + r1(x) + ' ' + r1(y + R * 0.18) + ' ' + r1(x - R * 0.1) + ' ' + r1(y), '#f6a3bb', 1.2) +
        ellp(x - R * 0.3, y - R * 0.45, R * 0.22, R * 0.09, '#fff', -35, ' opacity=".25"');
    },
    tulip: function (x, y, R, c1, c2) {
      var w = R * 0.62, h = R * 1.1;
      return pth('M' + r1(x - w) + ' ' + r1(y - h * 0.55) + 'Q' + r1(x - w * 1.1) + ' ' + r1(y + h * 0.35) + ' ' + r1(x) + ' ' + r1(y + h * 0.45) + 'Q' + r1(x + w * 1.1) + ' ' + r1(y + h * 0.35) + ' ' + r1(x + w) + ' ' + r1(y - h * 0.55) + 'Q' + r1(x + w * 0.5) + ' ' + r1(y - h * 0.2) + ' ' + r1(x) + ' ' + r1(y - h * 0.7) + 'Q' + r1(x - w * 0.5) + ' ' + r1(y - h * 0.2) + ' ' + r1(x - w) + ' ' + r1(y - h * 0.55) + 'Z', c1) +
        pth('M' + r1(x - w * 0.6) + ' ' + r1(y - h * 0.5) + 'Q' + r1(x) + ' ' + r1(y + h * 0.5) + ' ' + r1(x + w * 0.6) + ' ' + r1(y - h * 0.5) + 'Q' + r1(x) + ' ' + r1(y - h * 0.15) + ' ' + r1(x - w * 0.6) + ' ' + r1(y - h * 0.5) + 'Z', c2) +
        ellp(x - w * 0.5, y - h * 0.05, w * 0.1, h * 0.28, '#fff', 12, ' opacity=".28"');
    },
    poppy: function (x, y, R, c) {
      c = c || '#e5392d';
      return circ(x - R * 0.35, y, R * 0.62, '#c92a22') + circ(x + R * 0.35, y, R * 0.62, '#c92a22') + circ(x, y - R * 0.3, R * 0.62, c) + circ(x - R * 0.3, y + R * 0.15, R * 0.6, c) + circ(x + R * 0.3, y + R * 0.15, R * 0.6, '#ee4a3a') +
        circ(x, y, R * 0.2, '#2a1a1c') + petalRing(x, y, 9, R * 0.3, R * 0.07, R * 0.04, '#2a1a1c', 0) + ellp(x - R * 0.3, y - R * 0.45, R * 0.25, R * 0.09, '#fff', -30, ' opacity=".22"');
    },
    daisy: function (x, y, R) {
      return petalRing(x, y, 14, R * 0.58, R * 0.46, R * 0.13, '#f4f1e6', 0) + petalRing(x, y, 14, R * 0.55, R * 0.44, R * 0.12, '#ffffff', 12) + circ(x, y, R * 0.3, '#f2b81d') + circ(x - R * 0.06, y - R * 0.06, R * 0.14, '#ffd75a');
    },
    blossom: function (x, y, R, c) { return petalRing(x, y, 5, R * 0.5, R * 0.5, R * 0.3, c || '#ffffff', -90, ' stroke="#e5e2d4" stroke-width=".6"') + circ(x, y, R * 0.24, '#f0c230'); },
    bflower: function (x, y, R, c) { return petalRing(x, y, 5, R * 0.5, R * 0.46, R * 0.26, c, -90) + circ(x, y, R * 0.2, '#fff3b0'); },
    lavspike: function (x, y, h) {
      var s = '';
      for (var i = 0; i < 9; i++) { var yy = y - i * h / 9, sc = 1 - i * 0.06; s += ellp(x - 2.2 * sc, yy, 2.6 * sc, 3.2 * sc, '#8a63cc', -20) + ellp(x + 2.2 * sc, yy - 1.5, 2.6 * sc, 3.2 * sc, '#a98be0', 20); }
      return s + ellp(x, y - h - 2, 2, 3.2, '#8a63cc');
    },
    minspike: function (x, y, h) { var s = ''; for (var i = 0; i < 4; i++) { var yy = y - i * h / 4; s += circ(x - 3, yy, 2.6, '#b79ad8') + circ(x + 3, yy, 2.6, '#c9b3e6') + circ(x, yy - 1.5, 2.2, '#a98cd0'); } return s + circ(x, y - h - 3, 2.6, '#b79ad8'); },
    basspike: function (x, y, h) { var s = ''; for (var i = 0; i < 4; i++) { var yy = y - i * h / 4; s += ellp(x - 3.4, yy, 2.8, 1.8, '#fff6f0', -20) + ellp(x + 3.4, yy, 2.8, 1.8, '#fff6f0', 20) + circ(x, yy - 1.6, 1.4, '#c46a8a'); } return s; },
    tassel: function (x, y) {
      var s = '';
      for (var i = -3; i <= 3; i++) s += line('M' + x + ' ' + (y + 6) + 'Q' + (x + i * 5) + ' ' + (y - 12) + ' ' + (x + i * 10) + ' ' + (y - 2 + Math.abs(i) * 3), '#d8c26a', 1.6);
      return s + circ(x, y + 6, 3, '#c9b24f');
    },
    tomato: function (x, y, r) { return line('M' + r1(x) + ' ' + r1(y - r - 6) + 'L' + r1(x) + ' ' + r1(y - r), '#4b7a2a', 1.8) + circ(x, y, r, '#dc3b2c') + ellp(x - r * 0.35, y - r * 0.35, r * 0.28, r * 0.16, '#ffb3a3', -35, ' opacity=".8"') + pth('M' + r1(x) + ' ' + r1(y - r * 0.85) + 'l-' + r1(r * 0.55) + ' -' + r1(r * 0.1) + 'l' + r1(r * 0.35) + ' ' + r1(r * 0.3) + 'l-' + r1(r * 0.1) + ' ' + r1(r * 0.5) + 'l' + r1(r * 0.35) + ' -' + r1(r * 0.35) + 'l' + r1(r * 0.4) + ' ' + r1(r * 0.3) + 'l-' + r1(r * 0.12) + ' -' + r1(r * 0.5) + 'l' + r1(r * 0.35) + ' -' + r1(r * 0.15) + 'z', '#3f8a3a'); },
    pepper: function (x, y, r, c, c2) {
      c = c || '#d8352a'; c2 = c2 || '#ff8a74';
      return line('M' + x + ' ' + (y - r * 1.5) + 'L' + x + ' ' + (y - r), '#4b7a2a', 2) + pth('M' + r1(x - r * 0.75) + ' ' + r1(y - r) + 'Q' + r1(x - r * 0.95) + ' ' + r1(y + r * 0.9) + ' ' + r1(x + r * 0.1) + ' ' + r1(y + r * 1.9) + 'Q' + r1(x + r * 0.75) + ' ' + r1(y + r * 0.4) + ' ' + r1(x + r * 0.75) + ' ' + r1(y - r) + 'Q' + r1(x) + ' ' + r1(y - r * 1.2) + ' ' + r1(x - r * 0.75) + ' ' + r1(y - r) + 'Z', c) +
        ellp(x - r * 0.35, y, r * 0.12, r * 0.6, c2, 8, ' opacity=".7"') + pth('M' + r1(x - r * 0.8) + ' ' + r1(y - r) + 'Q' + r1(x) + ' ' + r1(y - r * 1.5) + ' ' + r1(x + r * 0.8) + ' ' + r1(y - r) + 'Q' + r1(x) + ' ' + r1(y - r * 0.8) + ' ' + r1(x - r * 0.8) + ' ' + r1(y - r) + 'Z', '#3f8a3a');
    },
    berry: function (x, y, r) {
      var s = pth('M' + r1(x - r) + ' ' + r1(y - r * 0.6) + 'Q' + r1(x - r * 1.1) + ' ' + r1(y + r * 0.7) + ' ' + r1(x) + ' ' + r1(y + r * 1.25) + 'Q' + r1(x + r * 1.1) + ' ' + r1(y + r * 0.7) + ' ' + r1(x + r) + ' ' + r1(y - r * 0.6) + 'Q' + r1(x) + ' ' + r1(y - r * 1.05) + ' ' + r1(x - r) + ' ' + r1(y - r * 0.6) + 'Z', '#d92d3a');
      for (var i = 0; i < 9; i++) s += ellp(x + ((i % 3) - 1) * r * 0.48 + (i > 5 ? r * 0.2 : 0), y - r * 0.2 + Math.floor(i / 3) * r * 0.5, 0.9, 1.3, '#ffe28a');
      return s + ellp(x - r * 0.45, y - r * 0.25, r * 0.14, r * 0.34, '#ff9aa4', 12, ' opacity=".6"') + pth('M' + r1(x) + ' ' + r1(y - r * 0.8) + 'l-' + r1(r * 0.9) + ' -' + r1(r * 0.15) + 'l' + r1(r * 0.55) + ' ' + r1(r * 0.4) + 'l' + r1(r * 0.1) + ' -' + r1(r * 0.7) + 'l' + r1(r * 0.3) + ' ' + r1(r * 0.7) + 'l' + r1(r * 0.6) + ' -' + r1(r * 0.4) + 'l-' + r1(r * 0.2) + ' ' + r1(r * 0.6) + 'z', '#3f9a3a');
    },
    pumpkin: function (x, y, r) {
      return ellp(x - r * 0.6, y, r * 0.58, r * 0.88, '#d9741c') + ellp(x + r * 0.6, y, r * 0.58, r * 0.88, '#d9741c') + ellp(x - r * 0.28, y, r * 0.5, r * 0.95, '#ee8a2a') + ellp(x + r * 0.28, y, r * 0.5, r * 0.95, '#ee8a2a') + ellp(x, y, r * 0.42, r, '#f59a38') +
        ellp(x - r * 0.35, y - r * 0.3, r * 0.14, r * 0.35, '#ffd08a', 20, ' opacity=".5"') + pth('M' + r1(x - 3) + ' ' + r1(y - r * 0.95) + 'q' + 1 + ' -' + r1(r * 0.5) + ' ' + 6 + ' -' + r1(r * 0.55) + 'l2 5q-3 2 -3 ' + r1(r * 0.55) + 'z', '#5a7a2a');
    },
    cuke: function (x, y, len) {
      return line('M' + x + ' ' + (y - len / 2 - 6) + 'L' + x + ' ' + (y - len / 2), '#4b7a2a', 1.8) + '<rect x="' + r1(x - 5.5) + '" y="' + r1(y - len / 2) + '" width="11" height="' + r1(len) + '" rx="5.5" fill="#3f8c3a"/>' + '<rect x="' + r1(x - 2) + '" y="' + r1(y - len / 2 + 2) + '" width="2.4" height="' + r1(len - 4) + '" rx="1.2" fill="#8bd070" opacity=".7"/>' + line('M' + r1(x + 2) + ' ' + r1(y - len / 2 + 5) + 'L' + r1(x + 2) + ' ' + r1(y + len / 2 - 5), '#2a6a2a', 1.2, ' opacity=".6"') + circ(x, y + len / 2 - 1, 1.3, '#e8d86a');
    },
    fig: function (x, y, r) {
      return line('M' + x + ' ' + (y - r * 1.5) + 'L' + x + ' ' + (y - r), '#6a5a3a', 2) + pth('M' + r1(x - r * 0.3) + ' ' + r1(y - r * 1.1) + 'Q' + r1(x - r * 1.2) + ' ' + r1(y + r * 0.2) + ' ' + r1(x) + ' ' + r1(y + r * 1.1) + 'Q' + r1(x + r * 1.2) + ' ' + r1(y + r * 0.2) + ' ' + r1(x + r * 0.3) + ' ' + r1(y - r * 1.1) + 'Z', '#6b3a7c') +
        ellp(x - r * 0.4, y, r * 0.14, r * 0.5, '#a46bb8', 10, ' opacity=".7"') + ellp(x + r * 0.25, y + r * 0.3, r * 0.1, r * 0.45, '#8b9a3a', -8, ' opacity=".5"');
    },
    orange: function (x, y, r) {
      return line('M' + x + ' ' + (y - r - 5) + 'L' + x + ' ' + (y - r), '#5a7a2a', 2) + circ(x, y, r, '#f59a1c') + circ(x, y, r * 0.8, '#fbb23c', ' opacity=".5"') + ellp(x - r * 0.38, y - r * 0.38, r * 0.3, r * 0.17, '#ffe0a0', -35, ' opacity=".8"') + circ(x, y - r * 0.9, r * 0.14, '#3f8a2a');
    },
    cob: function (x, y, s, flip) {
      var f = flip || 1;
      return '<g transform="translate(' + r1(x) + ' ' + r1(y) + ') scale(' + f * s + ' ' + s + ')">' + pth('M-4 -2Q-12 -18 -2 -34Q8 -42 10 -30Q12 -12 4 0Z', '#5fa63a') + pth('M-1 0Q-8 -16 0 -32Q6 -40 6 -26Q6 -10 2 0Z', '#f4c734') +
        '<path d="M-2 -8l7 2M-3 -14l9 2M-2 -20l9 1M0 -26l7 1" stroke="#c9961a" stroke-width="1" fill="none"/><path d="M0 -4Q-3 -20 2 -30" stroke="#fff3b0" stroke-width="1.6" fill="none" opacity=".7"/>' + pth('M-4 0Q-14 -6 -12 -26Q-6 -14 0 -6Z', '#4a8a2e') + pth('M4 0Q14 -8 12 -26Q6 -14 0 -6Z', '#6bb844') + '</g>';
    },
    pod: function (x, y, len) {
      return line('M' + x + ' ' + (y - 4) + 'Q' + (x + 4) + ' ' + (y + len * 0.5) + ' ' + (x - 2) + ' ' + (y + len), '#2f7a2f', 6.5) + line('M' + x + ' ' + (y - 4) + 'Q' + (x + 4) + ' ' + (y + len * 0.5) + ' ' + (x - 2) + ' ' + (y + len), '#6bbd52', 4) + line('M' + (x + 1) + ' ' + (y + 2) + 'Q' + (x + 4.5) + ' ' + (y + len * 0.5) + ' ' + (x - 1) + ' ' + (y + len - 3), '#a6e08a', 1.2, ' opacity=".8"');
    },
    pumpkinflower: function (x, y, R) { return pth('M' + r1(x - R * 0.2) + ' ' + r1(y + R * 0.5) + 'L' + r1(x - R) + ' ' + r1(y - R * 0.6) + 'L' + r1(x - R * 0.4) + ' ' + r1(y - R * 0.2) + 'L' + r1(x) + ' ' + r1(y - R * 0.9) + 'L' + r1(x + R * 0.4) + ' ' + r1(y - R * 0.2) + 'L' + r1(x + R) + ' ' + r1(y - R * 0.6) + 'L' + r1(x + R * 0.2) + ' ' + r1(y + R * 0.5) + 'Z', '#f6b61e') + circ(x, y - R * 0.1, R * 0.2, '#d98a12'); },
    tendril: function (x, y, dir) { return line('M' + x + ' ' + y + 'q' + (dir * 8) + ' -8 ' + (dir * 14) + ' 0q' + (dir * 4) + ' 10 ' + (dir * -6) + ' 8q' + (dir * -6) + ' -6 ' + (dir * 0) + ' -10', '#6aa84a', 1.5); },
    orchidbloom: function (x, y, R, c1, c2) {
      return ellp(x - R * 0.55, y, R * 0.62, R * 0.4, c1, -20) + ellp(x + R * 0.55, y, R * 0.62, R * 0.4, c1, 20) + ellp(x, y - R * 0.55, R * 0.4, R * 0.62, c1) + ellp(x - R * 0.35, y + R * 0.45, R * 0.34, R * 0.38, '#f6ecff', 28) + ellp(x + R * 0.35, y + R * 0.45, R * 0.34, R * 0.38, '#f6ecff', -28) + ellp(x, y + R * 0.4, R * 0.26, R * 0.34, c2) + circ(x, y, R * 0.16, '#fff3b0') + ellp(x - R * 0.3, y - R * 0.7, R * 0.12, R * 0.3, '#fff', 20, ' opacity=".3"');
    }
  };

  /* pots and backdrop */
  function potMarkup(kind) {
    var C = { terra: ['#c8703f', '#de8a52', '#a85a30'], blue: ['#4f7fb5', '#6c9ad0', '#3a6494'], white: ['#e6e2d6', '#fbf9f1', '#c9c4b4'], stone: ['#8d8e88', '#a9aaa3', '#6f706a'], wood: ['#9a6a3a', '#b98450', '#7a5028'] }[kind] || ['#c8703f', '#de8a52', '#a85a30'];
    var s = ellp(CX, 345, 66, 8, '#000', 0, ' opacity=".18"');
    s += pth('M104 304L112 344Q113 349 120 349L200 349Q207 349 208 344L216 304Z', C[0]);
    s += pth('M104 304L216 304L214 318L106 318Z', C[2], ' opacity=".35"');
    s += '<rect x="98" y="296" width="124" height="14" rx="5" fill="' + C[1] + '"/>' + '<rect x="102" y="298" width="116" height="3.5" rx="1.7" fill="#fff" opacity=".28"/>';
    if (kind === 'wood') s += '<rect x="104" y="318" width="112" height="3" fill="#5e3e1c" opacity=".6"/><rect x="108" y="334" width="104" height="3" fill="#5e3e1c" opacity=".6"/>';
    s += ellp(CX, 301, 56, 5.5, '#4a3322') + ellp(CX, 300, 50, 3.4, '#5e4430');
    s += ellp(126, 330, 5, 14, '#fff', 8, ' opacity=".14"');
    return s;
  }
  var uid = 0;
  function bgMarkup(id) {
    var s = '<defs><linearGradient id="pskg' + id + '" x1="0" y1="0" x2="0" y2="1"><stop class="pst-s0" offset="0"/><stop class="pst-s1" offset="1"/></linearGradient></defs>';
    s += '<rect width="320" height="360" fill="url(#pskg' + id + ')"/>';
    s += '<ellipse class="pst-hill2" cx="70" cy="330" rx="170" ry="70"/><ellipse class="pst-hill1" cx="270" cy="338" rx="150" ry="66"/>';
    s += '<g class="pst-fence">';
    for (var i = 0; i < 9; i++) s += '<path d="M' + (8 + i * 38) + ' 330L' + (8 + i * 38) + ' 262L' + (17 + i * 38) + ' 254L' + (26 + i * 38) + ' 262L' + (26 + i * 38) + ' 330Z"/>';
    s += '<rect x="0" y="276" width="320" height="7"/><rect x="0" y="304" width="320" height="7"/></g>';
    s += '<rect class="pst-shelf" x="0" y="347" width="320" height="13"/><rect class="pst-shelf2" x="0" y="347" width="320" height="3"/>';
    return s;
  }

  /* ----- the 25 designs, in PEST_PLANTS order ----- */
  var D = [
    { n: 10, pot: 'terra', sup: 'stake',   // Tomato
      st: [{ f: straight(160, 232, 9, 0.4), w: 4.6, c: '#5f8d3a', m: 10, t0: 0.1, t1: 0.95, a0: 80, a1: 48 }],
      lf: { shape: 'compound', L: 56, W: 21, sub: 'egg', mod: ['teeth', 9, 0.16], c: '#4a973a', d: '#2f7330', hi: '#79c05c', s0: 1, s1: 0.72, bend: 0.12 },
      ac: [['tomato', 0, 0.3, 1, 10], ['tomato', 0, 0.5, -1, 9], ['tomato', 0, 0.66, 1, 8.5], ['tomato', 0, 0.4, -1, 7], ['bflower', 0, 0.98, 0, 7, '#f7d23a']] },
    { n: 12, pot: 'wood', sup: 'tepee',   // Bean
      st: [{ f: wavy(160, 236, 17, 2.4), w: 3.4, c: '#5c9a3c', m: 12, t0: 0.08, t1: 0.97, a0: 86, a1: 56 }],
      lf: { shape: 'tri', L: 44, W: 14, sub: 'egg', c: '#58a63c', d: '#3a7d28', hi: '#8fd070', s0: 1, s1: 0.8, bend: 0.1 },
      ac: [['pod', 0, 0.35, 1, 40], ['pod', 0, 0.52, -1, 46], ['pod', 0, 0.68, 1, 38], ['bean', 0, 0.8, -1, 6], ['bean', 0, 0.92, 1, 6]] },
    { n: 9, pot: 'blue', sup: null,   // Sunflower
      st: [{ f: straight(160, 232, 4, 0.2), w: 8, c: '#5c9631', m: 9, t0: 0.1, t1: 0.86, a0: 96, a1: 58 }],
      lf: { shape: 'heart', L: 62, W: 33, mod: ['teeth', 8, 0.06], c: '#4a9a2e', d: '#2f6f1f', hi: '#7cc25a', s0: 1, s1: 0.78, bend: 0.18 },
      ac: [['sun', 0, 1, 0, 36]] },
    { n: 11, pot: 'white', sup: null,   // Rose
      st: [{ f: straight(146, 196, -16, 0.5), w: 3.6, c: '#587f33', m: 4, t0: 0.2, t1: 0.9, a0: 60, a1: 30 }, { f: straight(176, 176, 14, 1.3), w: 3.6, c: '#587f33', m: 4, t0: 0.2, t1: 0.9, a0: 62, a1: 32 }, { f: straight(162, 118, -4, 2), w: 3.2, c: '#5f8a38', m: 3, t0: 0.25, t1: 0.9, a0: 58, a1: 30 }],
      lf: { shape: 'compound', L: 42, W: 17, pairs: 2, sub: 'egg', mod: ['teeth', 10, 0.12], c: '#3d8c45', d: '#256a30', hi: '#6fbf72', s0: 1, s1: 0.85, bend: 0.1 },
      ac: [['rose', 0, 1, 0, 17], ['rose', 1, 1, 0, 14], ['rosebud', 2, 1, 0, 8], ['thorns']] },
    { n: 12, pot: 'terra', sup: null,   // Lettuce
      ro: [{ c: 5, A0: -74, A1: 74, pet: 4, s: 1, lift: 0 }, { c: 4, A0: -44, A1: 44, pet: 2, s: 0.88, lift: 10 }, { c: 3, A0: -18, A1: 18, pet: 0, s: 0.74, lift: 0 }],
      lf: { shape: 'spoon', L: 82, W: 36, mod: ['wave', 7, 0.2], c: '#7fc956', d: '#559c36', hi: '#bfe88c', s0: 1, s1: 1, bend: 0.1 }, tint: ['#6fbd4a', '#8fd460', '#b4e583'],
      ac: [] },
    { n: 10, pot: 'stone', sup: null,   // Kale
      st: [{ f: straight(160, 150, 3, 0.8), w: 9, c: '#6b8f6a', m: 10, t0: 0.2, t1: 1, a0: 96, a1: 34 }],
      lf: { shape: 'lance', L: 64, W: 24, mod: ['wave', 7, 0.2], c: '#3c7c66', d: '#7a4f8a', hi: '#6aa890', s0: 1, s1: 0.85, bend: 0.2 }, tint: ['#3c7c66', '#46876f', '#34705c'],
      ac: [] },
    { n: 10, pot: 'terra', sup: null,   // Pepper
      st: [{ f: straight(160, 205, 8, 0.2), w: 4.4, c: '#5a8a3c', m: 6, t0: 0.15, t1: 0.97, a0: 62, a1: 24 }, { f: arc(160, 215, 218, 150, 12), w: 3.6, c: '#5a8a3c', m: 4, t0: 0.15, t1: 0.97, a0: 62, a1: 24 }],
      lf: { shape: 'egg', L: 44, W: 20, c: '#3f9a45', d: '#2b7233', hi: '#7ed07e', s0: 1, s1: 0.78, bend: 0.12 },
      ac: [['pepper', 0, 0.4, 1, 8], ['pepper', 0, 0.55, -1, 7, '#f0b81c', '#ffe27a'], ['pepper', 0, 0.72, 1, 7], ['pepper', 1, 0.5, 1, 6, '#3f9a3a', '#8bd070'], ['blossom', 0, 0.95, 0, 8, '#ffffff']] },
    { n: 9, pot: 'wood', sup: null,   // Strawberry
      ro: [{ c: 5, A0: -76, A1: 76, pet: 54, s: 1, lift: 14 }, { c: 4, A0: -44, A1: 44, pet: 80, s: 0.9, lift: 8 }],
      lf: { shape: 'tri', L: 40, W: 15, sub: 'egg', mod: ['teeth', 7, 0.2], c: '#4ea443', d: '#33782f', hi: '#86cf6f', s0: 1, s1: 1, bend: 0.06 }, pet: ['#7aa04a', 2.4],
      ac: [['berryhang', 118, 322, 0, 8], ['berryhang', 202, 324, 0, 7.5], ['berryhang', 134, 330, 0, 6.5], ['blossomAt', 104, 244, 0, 9, '#fff'], ['blossomAt', 224, 238, 0, 8, '#fff']] },
    { n: 8, pot: 'stone', sup: null,   // Pumpkin vine
      st: [{ f: function (t) { return [160 + 70 * Math.sin(t * 5.2) * (0.3 + t * 0.7), BY - 235 * t - 14 * Math.sin(t * 9)]; }, w: 6, c: '#5d8a34', m: 8, t0: 0.1, t1: 0.96, a0: 72, a1: 46 }],
      lf: { shape: 'heart', L: 60, W: 47, mod: ['wave', 2.6, 0.2], c: '#5a9a38', d: '#3c7425', hi: '#8cc866', s0: 1, s1: 0.78, bend: 0.2 },
      ac: [['pumpkin', 138, 296, 0, 24], ['pumpkinflower', 0, 0.55, -1, 11], ['pumpkinflower', 0, 0.82, 1, 9], ['tendril', 0, 0.4, 1], ['tendril', 0, 0.7, -1]] },
    { n: 9, pot: 'blue', sup: 'trellis',   // Cucumber
      st: [{ f: wavy(160, 240, 22, 1.6), w: 3.6, c: '#4f8c3a', m: 9, t0: 0.1, t1: 0.95, a0: 70, a1: 40 }],
      lf: { shape: 'heart', L: 48, W: 38, mod: ['teeth', 6, 0.12], c: '#3f9442', d: '#2a6e30', hi: '#73c474', s0: 1, s1: 0.78, bend: 0.14 },
      ac: [['cuke', 0, 0.4, 1, 30], ['cuke', 0, 0.56, -1, 36], ['cuke', 0, 0.7, 1, 26], ['bflower', 0, 0.85, -1, 9, '#f4d03a'], ['bflower', 0, 0.93, 1, 8, '#f4d03a']] },
    { n: 12, pot: 'terra', sup: null,   // Basil
      st: [{ f: straight(160, 205, 4, 0.6), w: 4.6, c: '#6aa84a', m: 12, t0: 0.1, t1: 0.86, a0: 88, a1: 60, pair: true }],
      lf: { shape: 'egg', L: 42, W: 23, c: '#4fae4d', d: '#2f7f3a', hi: '#9ae07c', s0: 1, s1: 0.62, bend: 0.2 },
      ac: [['basspike', 0, 1, 0, 26]] },
    { n: 12, pot: 'blue', sup: null,   // Mint
      st: [{ f: straight(160, 196, 5, 1.1), w: 4.2, c: '#8a5f8c', m: 12, t0: 0.1, t1: 0.88, a0: 90, a1: 62, pair: true }],
      lf: { shape: 'round', L: 36, W: 21, mod: ['teeth', 14, 0.18], c: '#38a867', d: '#237c4d', hi: '#7edba0', s0: 1, s1: 0.66, bend: 0.1 },
      ac: [['minspike', 0, 1, 0, 24]] },
    { n: 8, pot: 'terra', sup: null,   // Fern
      ro: [{ c: 5, A0: -80, A1: 80, pet: 0, s: 1, lift: 0 }, { c: 3, A0: -34, A1: 34, pet: 0, s: 0.82, lift: 0 }],
      lf: { shape: 'frond', L: 112, W: 22, c: '#3da24e', d: '#26763a', hi: '#6fc87a', s0: 1, s1: 1, bend: 0.3 }, tint: ['#3da24e', '#4db85c', '#35913f'],
      ac: [['fiddle']] },
    { n: 8, pot: 'blue', sup: null,   // Monstera
      ro: [{ c: 5, A0: -66, A1: 66, pet: 96, s: 1, lift: 18 }, { c: 3, A0: -30, A1: 30, pet: 138, s: 0.9, lift: 8 }],
      lf: { shape: 'split', L: 70, W: 54, c: '#2a7a4a', d: '#1d5a37', hi: '#52ad78', s0: 1, s1: 1, bend: 0.14 }, pet: ['#4f8f4a', 3.2], tint: ['#2a7a4a', '#318a54', '#236a3f'],
      ac: [['root']] },
    { n: 8, pot: 'white', sup: 'clip',   // Orchid
      ro: [{ c: 4, A0: -86, A1: -30, pet: 0, s: 1, lift: 0 }, { c: 4, A0: 30, A1: 86, pet: 0, s: 1, lift: 0 }],
      lf: { shape: 'fat', L: 76, W: 19, c: '#4d9a54', d: '#2f6b36', hi: '#9ad89c', s0: 1, s1: 1, bend: 0.32 }, tint: ['#4d9a54', '#5aa860', '#43904a'],
      ac: [['orchidspike']] },
    { n: 8, pot: 'wood', sup: null,   // Tulip
      st: [{ f: straight(132, 175, -6, 0.4), w: 4, c: '#58a05a', m: 0 }, { f: straight(160, 205, 4, 1), w: 4, c: '#58a05a', m: 0 }, { f: straight(188, 160, 6, 2), w: 4, c: '#58a05a', m: 0 }],
      ro: [{ c: 4, A0: -84, A1: -32, pet: 0, s: 1, lift: 0 }, { c: 4, A0: 32, A1: 84, pet: 0, s: 1, lift: 0 }],
      lf: { shape: 'strap', L: 94, W: 20, c: '#5aa461', d: '#3b7a46', hi: '#a4dba4', s0: 1, s1: 1, bend: 0.3 },
      ac: [['tulip', 0, 1, 0, 15, '#e23d4b', '#f2707b'], ['tulip', 1, 1, 0, 17, '#f3c326', '#fbe27a'], ['tulip', 2, 1, 0, 14, '#ee7aa8', '#f8b4d0']] },
    { n: 12, pot: 'terra', sup: null,   // Lavender
      st: [{ f: straight(134, 150, -8, 0.3), w: 2.6, c: '#7f9a74', m: 3, t0: 0.1, t1: 0.7, a0: 40, a1: 25 }, { f: straight(152, 190, -4, 1), w: 2.6, c: '#7f9a74', m: 3, t0: 0.1, t1: 0.7, a0: 40, a1: 25 }, { f: straight(170, 178, 5, 2), w: 2.6, c: '#7f9a74', m: 3, t0: 0.1, t1: 0.7, a0: 40, a1: 25 }, { f: straight(188, 142, 8, 0.8), w: 2.6, c: '#7f9a74', m: 3, t0: 0.1, t1: 0.7, a0: 40, a1: 25 }],
      lf: { shape: 'lance', L: 46, W: 6.5, c: '#8ba98a', d: '#62816a', hi: '#c2d8bf', s0: 1, s1: 0.9, bend: 0.1 },
      ac: [['lavspike', 0, 1, 0, 34], ['lavspike', 1, 1, 0, 34], ['lavspike', 2, 1, 0, 32], ['lavspike', 3, 1, 0, 30]] },
    { n: 9, pot: 'stone', sup: null,   // Corn
      st: [{ f: straight(160, 240, 3, 0.5), w: 9, c: '#7fae45', m: 9, t0: 0.1, t1: 0.88, a0: 70, a1: 48 }],
      lf: { shape: 'strap', L: 92, W: 15, c: '#68ae3d', d: '#47852a', hi: '#a0dc72', s0: 1, s1: 0.8, bend: 0.3 },
      ac: [['cob', 0, 0.5, 1, 1], ['cob', 0, 0.38, -1, 0.85], ['tassel', 0, 1]] },
    { n: 10, pot: 'terra', sup: null,   // Cabbage
      ro: [{ c: 6, A0: -80, A1: 80, pet: 4, s: 1, lift: 0 }, { c: 4, A0: -40, A1: 40, pet: 2, s: 0.86, lift: 6 }],
      lf: { shape: 'round', L: 64, W: 42, mod: ['wave', 3, 0.1], c: '#6ea683', d: '#d8efd9', hi: '#a9d4b4', s0: 1, s1: 1, bend: 0.1 }, tint: ['#6ea683', '#84b896'],
      ac: [['head']], midAfter: 0 },
    { n: 9, pot: 'wood', sup: null,   // Chard
      ro: [{ c: 5, A0: -66, A1: 66, pet: 74, s: 1, lift: 0 }, { c: 4, A0: -34, A1: 34, pet: 100, s: 0.92, lift: 0 }],
      lf: { shape: 'oval', L: 66, W: 32, mod: ['wave', 6, 0.14], c: '#2f7d3a', d: '#d8344a', hi: '#5eae5e', s0: 1, s1: 1, bend: 0.1 }, ribs: ['#d8344a', '#f0b92b', '#ee7aa6', '#f3efe0', '#f08a2b'], petw: 4.2,
      ac: [] },
    { n: 9, pot: 'terra', sup: null,   // Poppy
      st: [{ f: straight(134, 190, -8, 0.4), w: 2.8, c: '#6d9a6a', m: 3, t0: 0.12, t1: 0.7, a0: 60, a1: 36 }, { f: straight(160, 224, 5, 1.2), w: 2.8, c: '#6d9a6a', m: 3, t0: 0.12, t1: 0.7, a0: 60, a1: 36 }, { f: arc(186, 296, 206, 190, -10), w: 2.8, c: '#6d9a6a', m: 3, t0: 0.12, t1: 0.7, a0: 60, a1: 36 }],
      lf: { shape: 'lance', L: 46, W: 17, mod: ['slit', 5], c: '#79a597', d: '#4c7a6c', hi: '#b2d4c8', s0: 1, s1: 0.8, bend: 0.14 },
      ac: [['poppy', 0, 1, 0, 18], ['poppy', 1, 1, 0, 20], ['seedpod', 2, 1, 0, 9]] },
    { n: 10, pot: 'blue', sup: null,   // Daisy
      st: [{ f: straight(136, 158, -6, 0.2), w: 2.8, c: '#5fa04a', m: 3, t0: 0.15, t1: 0.7, a0: 66, a1: 44 }, { f: straight(160, 212, 3, 1), w: 2.8, c: '#5fa04a', m: 4, t0: 0.12, t1: 0.7, a0: 66, a1: 44 }, { f: straight(186, 176, 6, 2), w: 2.8, c: '#5fa04a', m: 3, t0: 0.15, t1: 0.7, a0: 66, a1: 44 }],
      lf: { shape: 'spoon', L: 40, W: 14, mod: ['teeth', 6, 0.1], c: '#5bb04c', d: '#3b8a3a', hi: '#9ee08a', s0: 1, s1: 0.9, bend: 0.1 },
      ac: [['daisy', 0, 1, 0, 19], ['daisy', 1, 1, 0, 22], ['daisy', 2, 1, 0, 17], ['daisy', 1, 0.55, 1, 12]] },
    { n: 12, pot: 'stone', sup: 'arch',   // Ivy
      st: [{ f: function (t) { return [160 + 38 * Math.sin(t * 7) * (1 - t * 0.5), BY - 236 * t]; }, w: 3.2, c: '#3d6a3a', m: 12, t0: 0.06, t1: 0.97, a0: 80, a1: 44 }],
      lf: { shape: 'palm', L: 36, W: 30, lw: 0.34, sub: 'lance', lobes: [[0, 1], [-52, 0.7], [52, 0.7]], c: '#2f7a4a', d: '#bfe0b8', hi: '#5fb07a', s0: 1, s1: 0.76, bend: 0.1 },
      ac: [['berries', 0, 0.98]] },
    { n: 8, pot: 'terra', sup: null,   // Fig
      st: [{ f: straight(160, 120, 3, 0.4), w: 11, c: '#7a6a58', m: 0 }, { f: arc(160, 190, 100, 118, -8), w: 5.5, c: '#7a6a58', m: 3, t0: 0.4, t1: 0.98, a0: 66, a1: 40 }, { f: arc(160, 180, 226, 112, 8), w: 5.5, c: '#7a6a58', m: 3, t0: 0.4, t1: 0.98, a0: 66, a1: 40 }, { f: arc(160, 176, 164, 74, 6), w: 5, c: '#7a6a58', m: 2, t0: 0.4, t1: 0.98, a0: 60, a1: 30 }],
      lf: { shape: 'palm', L: 56, W: 50, lw: 0.4, sub: 'oval', lobes: [[0, 1], [-48, 0.78], [48, 0.78], [-92, 0.5], [92, 0.5]], c: '#4f9a3a', d: '#2f6a22', hi: '#85c764', s0: 1, s1: 0.82, bend: 0.14 },
      ac: [['fig', 1, 0.5, 1, 9], ['fig', 2, 0.6, -1, 8], ['fig', 3, 0.55, 1, 8]] },
    { n: 11, pot: 'white', sup: null,   // Citrus sapling
      st: [{ f: straight(160, 110, 3, 0.4), w: 8, c: '#7a5e3c', m: 0 }, { f: arc(160, 190, 104, 128, -6), w: 4.5, c: '#7a5e3c', m: 4, t0: 0.3, t1: 0.99, a0: 66, a1: 38 }, { f: arc(160, 184, 220, 124, 6), w: 4.5, c: '#7a5e3c', m: 4, t0: 0.3, t1: 0.99, a0: 66, a1: 38 }, { f: arc(160, 178, 162, 78, 4), w: 4, c: '#7a5e3c', m: 3, t0: 0.3, t1: 0.99, a0: 60, a1: 28 }],
      lf: { shape: 'oval', L: 38, W: 18, c: '#2f9a45', d: '#1f7233', hi: '#8fdc7a', s0: 1, s1: 0.9, bend: 0.1 },
      ac: [['orange', 1, 0.5, 1, 11], ['orange', 2, 0.55, -1, 10], ['orange', 3, 0.62, 1, 9], ['blossom', 2, 0.95, 1, 8, '#fff'], ['blossom', 1, 0.85, -1, 7, '#fff']] }
  ];
  var NAMES = ['Tomato', 'Bean', 'Sunflower', 'Rose', 'Lettuce', 'Kale', 'Pepper', 'Strawberry', 'Pumpkin vine', 'Cucumber', 'Basil', 'Mint', 'Fern', 'Monstera', 'Orchid', 'Tulip', 'Lavender', 'Corn', 'Cabbage', 'Chard', 'Poppy', 'Daisy', 'Ivy', 'Fig', 'Citrus sapling'];

  function supportMarkup(kind) {
    var wood = '#a07848', wood2 = '#7a5a30';
    if (kind === 'stake') return '<rect x="186" y="104" width="6" height="196" rx="2" fill="' + wood + '"/><rect x="187" y="104" width="1.8" height="196" fill="#d4ad78" opacity=".6"/>';
    if (kind === 'tepee') return line('M118 300L172 74', wood, 5) + line('M202 300L148 74', wood, 5) + line('M160 300L160 70', wood2, 4) + line('M164 98L156 98', '#d8c27a', 3);
    if (kind === 'trellis') {
      var s = '<rect x="96" y="100" width="5" height="200" fill="' + wood + '"/><rect x="219" y="100" width="5" height="200" fill="' + wood + '"/>';
      for (var i = 0; i < 6; i++) s += line('M98 ' + (118 + i * 32) + 'L222 ' + (118 + i * 32), wood2, 2, ' opacity=".7"');
      for (var j = 0; j < 5; j++) s += line('M' + (114 + j * 23) + ' 104L' + (114 + j * 23) + ' 298', wood2, 1.6, ' opacity=".5"');
      return s;
    }
    if (kind === 'arch') return line('M104 300L104 130Q104 70 160 70Q216 70 216 130L216 300', '#6e6a5e', 5) + line('M104 300L104 130Q104 70 160 70Q216 70 216 130L216 300', '#a9a597', 1.6, ' opacity=".7"');
    if (kind === 'clip') return '<rect x="180" y="150" width="3.4" height="150" rx="1.4" fill="#8a7248"/>';
    return '';
  }

  /* One plant: returns {back, stems:[{d,w,c,delay}], leaves:[{i,x,y,th,flip,s,art,c,d,hi,reach,cx,cy,tint,rib,petD}], front, accents} */
  function buildPlant(di) {
    var P = D[di], lf = P.lf, anchors = [], stems = [], front = '', back = '', mid = '';
    var hasRos = !!P.ro;
    var rosBase = [CX, BY];
    back += supportMarkup(P.sup);
    if (P.st) P.st.forEach(function (st, si) {
      stems.push({ d: stemPath(st.f, 0, 1), w: st.w, c: st.c, delay: si * 0.12 });
      if (!st.m) return;
      var count = st.m, total = st.pair ? Math.ceil(count / 2) : count;
      for (var k = 0; k < count; k++) {
        var idx = st.pair ? Math.floor(k / 2) : k, tr = total > 1 ? idx / (total - 1) : 0.5, t = st.t0 + (st.t1 - st.t0) * tr;
        var sd = st.pair ? (k % 2 ? -1 : 1) : (k % 2 ? -1 : 1) * (si % 2 ? -1 : 1);
        var p = st.f(t), A = st.a0 + (st.a1 - st.a0) * tr, sc = (lf.s0 || 1) + ((lf.s1 || 1) - (lf.s0 || 1)) * tr;
        anchors.push({ x: p[0] + sd * 2, y: p[1], A: A, sd: sd, s: sc, t: t, si: si });
      }
    });
    if (hasRos) {
      var k0 = 0, tot = 0;
      P.ro.forEach(function (ring) { tot += ring.c; });
      P.ro.forEach(function (ring, ri) {
        for (var k = 0; k < ring.c; k++) {
          var A = ring.c > 1 ? ring.A0 + (ring.A1 - ring.A0) * k / (ring.c - 1) : (ring.A0 + ring.A1) / 2;
          var dir = [Math.sin(rad(A)), -Math.cos(rad(A))], pet = ring.pet, ax = rosBase[0] + dir[0] * pet + (A === 0 ? 0 : 0), ay = rosBase[1] + dir[1] * pet - ring.lift * 0;
          var ang = Math.abs(A);
          if (pet > 0) {
            var mx = rosBase[0] + dir[0] * pet * 0.5 + Math.sign(A || 1) * pet * 0.1, my = rosBase[1] + dir[1] * pet * 0.5 - ring.lift;
            var rc = (P.ribs ? P.ribs[(k + ri * 2) % P.ribs.length] : (P.pet ? P.pet[0] : '#5a8f3a'));
            stems.push({ d: 'M' + rosBase[0] + ' ' + rosBase[1] + 'Q' + r1(mx) + ' ' + r1(my) + ' ' + r1(ax) + ' ' + r1(ay), w: P.petw || (P.pet ? P.pet[1] : 3), c: rc, delay: 0.1 + ri * 0.1 });
            ay -= ring.lift * 0.4;
          }
          anchors.push({ x: ax, y: ay, A: Math.min(180, ang < 8 ? 8 : ang), sd: A < 0 ? -1 : 1, s: ring.s, t: 0, ring: ri, rib: P.ribs ? P.ribs[(k + ri * 2) % P.ribs.length] : null, ros: true, ang: A });
        }
      });
      // draw fans back to front: outer (wider) first
      anchors.sort(function (a, b) { return (a.si === undefined ? 1 : 0) - (b.si === undefined ? 1 : 0) || b.ring - a.ring || Math.abs(b.ang || 0) - Math.abs(a.ang || 0); });
      if (!P.st) anchors.sort(function (a, b) { return (P.midAfter !== undefined ? a.ring - b.ring : b.ring - a.ring) || Math.abs(b.ang) - Math.abs(a.ang); });
    }
    // number the leaves: the order they unfurl (bottom of the plant first)
    var order = anchors.map(function (a, i) { return i; }).sort(function (a, b) { return (anchors[b].y - anchors[a].y) || (a - b); });
    var rank = []; order.forEach(function (idx, r) { rank[idx] = r; });
    var art = leafArt(lf), leaves = [];
    anchors.forEach(function (a, i) {
      var th, flip = a.sd < 0;
      if (a.ros) {
        // leaf direction follows its fan angle (from vertical); outer leaves lean over a bit more
        th = Math.abs(a.ang) - 90; if (th > 0) th = 0;
        th = Math.max(-90, th + (a.ring === 0 ? 0 : -6));
        if (Math.abs(a.ang) < 8) th = -90;
      } else th = a.A - 90;
      var reach = art.reach * a.s, rr = rad(th);
      var cx = a.x + (flip ? -1 : 1) * Math.cos(rr) * reach * 0.55, cy = a.y + Math.sin(rr) * reach * 0.55 + (lf.bend || 0) * reach * 0.18;
      var col = lf.c, tint = P.tint;
      if (tint) col = tint[a.ring != null ? Math.min(tint.length - 1, a.ring + (i % 2)) : 0];
      else if (i % 3 === 1) col = shade(lf.c, -10);
      leaves.push({ ring: a.ring || 0, i: rank[i], x: r1(a.x), y: r1(a.y), th: r1(th), flip: flip, s: a.s, art: art, col: col, d: a.rib || lf.d, hi: lf.hi, reach: reach, cx: r1(cx), cy: r1(cy), W: lf.W * a.s, delay: 0.55 + rank[i] * 0.06, stemT: a.t });
    });
    leaves.sort(function (a, b) { return 0; });
    // accents: [kind, stem, t, side, size, colour1, colour2] (or [kind, x, y, 0, size, ...] for the ones placed by hand)
    var acc = [];
    P.ac.forEach(function (a, ai) {
      var k = a[0], sd = a[3] || 1, r = a[4], m = '', c = 'front', sp = null, x, y;
      if (P.st && typeof a[1] === 'number' && a[1] < 8 && a[2] !== undefined && a[2] <= 1) { sp = P.st[a[1]].f(a[2]); x = sp[0]; y = sp[1]; }
      switch (k) {
        case 'sun': m = ACC.sun(x, y - 8, r); c = 'top'; break;
        case 'rose': m = ACC.rose(x, y - 6, r); c = 'top'; break;
        case 'rosebud': m = pth('M' + r1(x) + ' ' + r1(y - 20) + 'Q' + r1(x - 10) + ' ' + r1(y - 6) + ' ' + r1(x) + ' ' + r1(y + 2) + 'Q' + r1(x + 10) + ' ' + r1(y - 6) + ' ' + r1(x) + ' ' + r1(y - 20) + 'Z', '#d8456e') + pth('M' + r1(x - 8) + ' ' + r1(y - 2) + 'L' + r1(x) + ' ' + r1(y - 14) + 'L' + r1(x + 8) + ' ' + r1(y - 2) + 'Q' + r1(x) + ' ' + r1(y + 6) + ' ' + r1(x - 8) + ' ' + r1(y - 2) + 'Z', '#4f8a3a'); c = 'top'; break;
        case 'tulip': m = ACC.tulip(x, y - 8, r, a[5], a[6]); c = 'top'; break;
        case 'poppy': m = ACC.poppy(x, y - 4, r); c = 'top'; break;
        case 'daisy': m = (a[2] < 1 ? line('M' + r1(x) + ' ' + r1(y) + 'L' + r1(x + sd * 12) + ' ' + r1(y - 10), '#5fa04a', 2.4) : '') + ACC.daisy(x + (a[2] < 1 ? sd * 12 : 0), y - (a[2] < 1 ? 12 : 4), r); c = 'top'; break;
        case 'lavspike': m = ACC.lavspike(x, y - 4, r); c = 'top'; break;
        case 'seedpod': m = pth('M' + r1(x - 7) + ' ' + r1(y - 18) + 'Q' + r1(x - 9) + ' ' + r1(y + 2) + ' ' + r1(x) + ' ' + r1(y + 2) + 'Q' + r1(x + 9) + ' ' + r1(y + 2) + ' ' + r1(x + 7) + ' ' + r1(y - 18) + 'Z', '#8aa88a') + '<rect x="' + r1(x - 9) + '" y="' + r1(y - 22) + '" width="18" height="5" rx="2.4" fill="#6f8f72"/>' + ellp(x - 2.5, y - 8, 1.6, 6, '#c6dcc6', 6, ' opacity=".6"'); c = 'top'; break;
        case 'tomato': m = line('M' + r1(x) + ' ' + r1(y) + 'Q' + r1(x + sd * 8) + ' ' + r1(y - 2) + ' ' + r1(x + sd * 17) + ' ' + r1(y + 14 - r - 5), '#4b7a2a', 1.8) + ACC.tomato(x + sd * 17, y + 14, r); break;
        case 'pepper': m = line('M' + r1(x) + ' ' + r1(y) + 'L' + r1(x + sd * 12) + ' ' + r1(y + 8), '#4b7a2a', 2) + ACC.pepper(x + sd * 12, y + 16, r, a[5], a[6]); break;
        case 'fig': m = line('M' + r1(x) + ' ' + r1(y) + 'L' + r1(x + sd * 8) + ' ' + r1(y + 8), '#6a5a3a', 2) + ACC.fig(x + sd * 8, y + 20, r); break;
        case 'orange': m = line('M' + r1(x) + ' ' + r1(y) + 'L' + r1(x + sd * 8) + ' ' + r1(y + 6), '#5a7a2a', 2) + ACC.orange(x + sd * 9, y + 6 + r, r); break;
        case 'cuke': m = ACC.cuke(x + sd * 12, y + 14 + r / 2, r); c = 'back'; break;
        case 'pod': m = ACC.pod(x + sd * 6, y + 4, r); c = 'back'; break;
        case 'bean': m = ACC.bflower(x + sd * 8, y, r, '#d8b4f0'); break;
        case 'bflower': m = ACC.bflower(x + (a[3] ? sd * 12 : 0), y - (a[3] ? -4 : 4), r, a[5]); break;
        case 'blossom': m = ACC.blossom(x + sd * 10, y - 4, r, a[5]); break;
        case 'blossomAt': m = ACC.blossom(a[1], a[2], a[4], a[5]); break;
        case 'pumpkinflower': m = ACC.pumpkinflower(x + sd * 14, y - 2, r); break;
        case 'tendril': m = ACC.tendril(x, y, sd); break;
        case 'basspike': m = ACC.basspike(x, y - 2, r); c = 'top'; break;
        case 'minspike': m = ACC.minspike(x, y - 2, r); c = 'top'; break;
        case 'berryhang': m = line('M' + CX + ' ' + (BY - 6) + 'Q' + r1((CX + a[1]) / 2) + ' ' + (BY - 30) + ' ' + a[1] + ' ' + (a[2] - r - 6), '#6b8a3a', 1.8) + ACC.berry(a[1], a[2], r); break;
        case 'pumpkin': m = ACC.pumpkin(a[1], a[2] - r * 0.5, r); c = 'back'; break;
        case 'cob': m = line('M' + r1(x) + ' ' + r1(y) + 'L' + r1(x + sd * 8) + ' ' + r1(y + 2), '#6aa040', 3) + ACC.cob(x + sd * 10, y + 16 * r, 1.15 * r, sd); break;
        case 'tassel': sp = P.st[0].f(1); m = ACC.tassel(sp[0], sp[1] - 4); c = 'top'; break;
        case 'fiddle': m = line('M154 296Q150 262 160 252Q172 246 172 258Q170 268 162 264Q158 258 164 256', '#6fbf4a', 5) + line('M154 296Q150 262 160 252Q172 246 172 258Q170 268 162 264', '#a0e070', 1.6, ' opacity=".7"'); break;
        case 'root': m = line('M172 300Q184 270 176 244Q170 226 182 206', '#8a6a46', 3.2) + line('M178 262Q192 258 196 240', '#8a6a46', 2); c = 'back'; break;
        case 'head': m = ellp(160, 250, 50, 46, '#8fc79a') + ellp(160, 252, 44, 40, '#b9e0a0') + line('M160 212L160 290M136 224Q148 250 148 286M184 224Q172 250 172 286', '#e8f6dc', 2, ' opacity=".8"') + ellp(144, 228, 15, 5, '#fff', -30, ' opacity=".28"'); c = 'mid'; break;
        case 'orchidspike':
          m = line('M160 294Q172 220 196 168Q212 132 234 120', '#6a9a50', 3.4);
          [[188, 176, 11, '#c85ad6', '#8f2a9e'], [206, 148, 11, '#d77be0', '#9b2fa8'], [224, 128, 10, '#c85ad6', '#8f2a9e'], [180, 200, 10, '#e393ea', '#a640b0']].forEach(function (b) { m += ACC.orchidbloom(b[0], b[1], b[2], b[3], b[4]); });
          m += circ(238, 118, 3.6, '#d77be0') + circ(241, 114, 2.4, '#e9a8ee'); break;
        case 'berries': m = ''; [[-8, 4], [0, -2], [8, 4], [0, 10]].forEach(function (o) { m += line('M' + r1(x) + ' ' + r1(y) + 'L' + r1(x + o[0]) + ' ' + r1(y + o[1] - 4), '#3d6a3a', 1.4) + circ(x + o[0], y + o[1] - 5, 3.6, '#2a2438') + circ(x + o[0] - 1, y + o[1] - 6.4, 1, '#8a8aa8', ' opacity=".7"'); }); break;
        case 'thorns': m = ''; for (var cn = 0; cn < 3; cn++) for (var q = 1; q < 6; q++) { var pp = P.st[cn].f(q * 0.14); m += pth('M' + r1(pp[0] + 1) + ' ' + r1(pp[1]) + 'l' + (q % 2 ? 5 : -5) + ' -2.5l-4 4z', '#8a5a3a'); } c = 'back'; break;
      }
      if (m) acc.push({ m: m, delay: (c === 'mid' ? 0.5 : c === 'back' ? 1.0 : 1.2 + (ai % 4) * 0.06), c: c });
    });
    return { back: back, stems: stems, leaves: leaves, acc: acc, pot: P.pot, ribW: P.petw, di: di };
  }
  function shade(hex, amt) {
    var m = /^#([0-9a-f]{6})$/i.exec(hex); if (!m) return hex;
    var n = parseInt(m[1], 16), r = Math.max(0, Math.min(255, (n >> 16) + amt)), g = Math.max(0, Math.min(255, ((n >> 8) & 255) + amt)), b = Math.max(0, Math.min(255, (n & 255) + amt));
    return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
  }
  function leafMarkup(l, lf) {
    var a = l.art, tr = 'translate(' + l.x + ' ' + l.y + ')' + (l.flip ? ' scale(-1 1)' : '') + ' rotate(' + l.th + ')' + (l.s !== 1 ? ' scale(' + r1(l.s) + ')' : '');
    var fr = a.holes ? ' fill-rule="evenodd"' : '';
    var rw = lf.shape === 'frond' ? 1.4 : (lf.shape === 'fat' || lf.shape === 'strap' ? 1.8 : 1.2);
    var m = '<g class="lfo" data-ox="' + l.x + '" data-oy="' + l.y + '"><g class="lf" data-leaf="' + l.i + '" tabindex="0" role="button" aria-label="Leaf ' + (l.i + 1) + '" transform="' + tr + '"><g class="lfin" data-d="' + r1(l.delay) + '">';
    m += '<path d="' + a.d + (a.holes || '') + '" fill="' + l.col + '"' + fr + '/>';
    if (a.shade) m += '<path d="' + a.shade + '" fill="#000" opacity=".1"/>';
    if (a.hi) m += '<path d="' + a.hi + '" fill="' + l.hi + '" opacity=".38"/>';
    m += '<path d="' + a.rib + '" fill="none" stroke="' + l.d + '" stroke-width="' + rw + '" stroke-linecap="round" opacity="' + (lf.shape === 'round' && lf.d === '#d8efd9' ? '.9' : '.55') + '"/>';
    m += '<path class="dmg" d="' + a.d + (a.holes || '') + '" fill="#7a5214"' + fr + '/>';
    m += '<circle class="bru b1" cx="' + r1(a.reach * 0.34) + '" cy="' + r1(-lf.W * 0.22) + '" r="3.4"/><circle class="bru b2" cx="' + r1(a.reach * 0.6) + '" cy="' + r1(lf.W * 0.2) + '" r="3"/><circle class="bru b3" cx="' + r1(a.reach * 0.46) + '" cy="0" r="3.6"/>';
    m += '<ellipse class="hit" cx="' + r1(a.reach * 0.5) + '" cy="0" rx="' + r1(Math.max(a.reach * 0.55, 26 / l.s)) + '" ry="' + r1(Math.max(lf.W * 0.9, 24 / l.s)) + '"/>';
    return m + '</g></g></g>';
  }
  /* The whole stage for one plant, as SVG markup. $grow adds the grow-in classes' delays (set later from data-d). */
  function plantSvg(di, n, withLeaves) {
    var pl = buildPlant(di), P = D[di], id = ++uid, s = '';
    s += bgMarkup(id) + '<g class="pst-back">' + pl.back + '</g>' + potMarkup(pl.pot);
    s += '<g class="pst-mid">' + pl.acc.filter(function (a) { return a.c === 'back'; }).map(function (a) { return '<g class="acc" data-d="' + r1(a.delay) + '">' + a.m + '</g>'; }).join('') + '</g>';
    s += '<g class="pst-stems">' + pl.stems.map(function (st) { return '<path class="pstem" pathLength="1" data-d="' + r1(st.delay) + '" d="' + st.d + '" stroke="' + st.c + '" stroke-width="' + st.w + '"/>'; }).join('') + '</g>';
    var midG = '<g class="pst-mid2">' + pl.acc.filter(function (a) { return a.c === 'mid'; }).map(function (a) { return '<g class="acc" data-d="' + r1(a.delay) + '">' + a.m + '</g>'; }).join('') + '</g>';
    var lvs = pl.leaves, split = P.midAfter !== undefined;
    if (split) {   // cabbage: outer leaves, then the head, then the leaves wrapped round it
      s += '<g class="pst-leaves">' + lvs.filter(function (l) { return l.ring <= P.midAfter; }).map(function (l) { return leafMarkup(l, P.lf); }).join('') + '</g>' + midG;
      s += '<g class="pst-leaves">' + lvs.filter(function (l) { return l.ring > P.midAfter; }).map(function (l) { return leafMarkup(l, P.lf); }).join('') + '</g>';
    } else s += midG + '<g class="pst-leaves">' + lvs.map(function (l) { return leafMarkup(l, P.lf); }).join('') + '</g>';
    s += '<g class="pst-front">' + pl.acc.filter(function (a) { return a.c === 'front' || a.c === 'top'; }).map(function (a) { return '<g class="acc" data-d="' + r1(a.delay) + '">' + a.m + '</g>'; }).join('') + '</g>';
    return { svg: s, plant: pl };
  }

  /* ================= pests ================= */
  function aphidMk(hp) {
    var pos = hp >= 3 ? [[-10, 3, 20], [0, -5, -10], [10, 3, 160], [-3, 8, 200], [4, -1, 90]] : (hp === 2 ? [[-8, 2, 15], [4, -4, -20], [7, 6, 170]] : [[-3, 1, 10], [5, 4, 180]]), s = '';
    pos.forEach(function (p, i) {
      var c = i % 2 ? '#d8ee6e' : '#f2b2a8', c2 = i % 2 ? '#b6d44a' : '#e08a82';
      s += '<g transform="translate(' + p[0] + ' ' + p[1] + ') rotate(' + p[2] + ')"><path d="M-3 3.2l-2 2.6M0 3.6l0 3M3 3l2 2.6M-3 -3.2l-2 -2.6M0 -3.6l0 -3M3 -3l2 -2.6" stroke="#4c5a1a" stroke-width=".9" fill="none"/><ellipse rx="5.6" ry="4.3" fill="' + c + '" stroke="#4c5a1a" stroke-width="1"/><ellipse cx="-1" cy="-1.4" rx="3" ry="1.3" fill="#fff" opacity=".45"/><circle cx="4.6" cy="0" r="2.4" fill="' + c2 + '" stroke="#4c5a1a" stroke-width=".8"/><circle cx="5.7" cy="-.9" r=".75" fill="#1f1f1f"/><path d="M6 -2l3 -3M6.5 -.5l3.6 -1" stroke="#4c5a1a" stroke-width=".7" fill="none"/></g>';
    });
    return s;
  }
  function gnatMk() {
    return '<circle r="12" fill="#fff" opacity=".22"/><g class="gw"><ellipse cx="-3" cy="-6" rx="8" ry="3.6" fill="#fff" stroke="#7a8794" stroke-width=".7" opacity=".85" transform="rotate(-24 -3 -6)"/><ellipse cx="2" cy="-6.5" rx="8" ry="3.6" fill="#fff" stroke="#7a8794" stroke-width=".7" opacity=".85" transform="rotate(14 2 -6.5)"/></g>' +
      '<path d="M-2 3l-4 6M0 3l-1 7M2 3l3 6M3 1l6 4" stroke="#2b2830" stroke-width=".9" fill="none"/><ellipse rx="6.2" ry="3.6" fill="#38343e"/><ellipse cx="-1" cy="-1.2" rx="3.4" ry="1.1" fill="#fff" opacity=".28"/><circle cx="6.4" cy="-.4" r="3" fill="#4a4552"/><circle cx="7.6" cy="-1.4" r="1.2" fill="#e8584a"/><path d="M8 -3l4 -4M9 -2l5 -2" stroke="#2b2830" stroke-width=".8" fill="none"/>';
  }
  function cateMk() {
    var s = '', segs = [[-17, 1, '#7bd24f'], [-10, -3, '#5cb53a'], [-3, -4, '#7bd24f'], [4, -2, '#5cb53a'], [10.5, 1.2, '#7bd24f']];
    s += '<path d="M-14 6l0 4M-7 4l0 4M0 3l0 4M7 5l0 4" stroke="#3a6a22" stroke-width="1.6" stroke-linecap="round"/>';
    segs.forEach(function (g, i) { s += '<circle cx="' + g[0] + '" cy="' + g[1] + '" r="' + (i === 4 ? 5.4 : 5.8 - i * 0.1) + '" fill="' + g[2] + '" stroke="#3d7a26" stroke-width=".9"/>' + (i % 2 === 0 && i < 4 ? '<circle cx="' + g[0] + '" cy="' + (g[1] - 2.4) + '" r="1.4" fill="#ffe66a"/>' : ''); });
    s += '<ellipse cx="-4" cy="-6.6" rx="4.4" ry="1.3" fill="#fff" opacity=".35"/>';
    s += '<circle cx="15.5" cy="-.4" r="5.4" fill="#e9c545" stroke="#9a7a1a" stroke-width=".9"/><circle cx="17.4" cy="-2" r="1.2" fill="#222"/><circle cx="17.6" cy="1.6" r="1.1" fill="#222"/><path d="M17 -5l3 -4M14 -5l0 -5" stroke="#6a4a10" stroke-width=".9" fill="none"/><path d="M19.6 1.6q1.4 .8 0 1.8" stroke="#8a3a20" stroke-width=".8" fill="none"/>';
    return s;
  }
  function slugMk(hp) {
    return '<path d="M-22 6q4 -3 8 -1" stroke="#fff" stroke-width="4" fill="none" opacity=".28" stroke-linecap="round"/><path d="M-18 5C-18 -4 -5 -7 4 -5C10 -4 15 -1 16 3C16 7 10 7 4 7L-14 7C-16 7 -18 6 -18 5Z" fill="' + (hp > 1 ? '#8b6b4e' : '#7a5a40') + '" stroke="#4a3322" stroke-width="1"/><path d="M-16 6L15 6C14 8 8 8 3 8L-13 8Z" fill="#c9a77e"/><ellipse cx="-4" cy="-3" rx="8" ry="3.6" fill="#a5835f"/><ellipse cx="-5" cy="-4" rx="5" ry="1.4" fill="#fff" opacity=".35"/><path d="M-14 0q4 -3 8 0M-10 -4q3 -1.6 7 0" stroke="#5a4028" stroke-width=".8" fill="none" opacity=".6"/><path d="M12 -3l4 -8M9 -4l1 -9" stroke="#4a3322" stroke-width="1.4" fill="none"/><circle cx="16.4" cy="-11.6" r="1.8" fill="#222"/><circle cx="10" cy="-13.4" r="1.8" fill="#222"/>';
  }
  function pestMk(k, hp) {
    var sh = '<ellipse cy="8" rx="14" ry="3" fill="#000" opacity=".2"/>';
    if (k === 'g') return gnatMk();
    return sh + (k === 'a' ? aphidMk(hp) : k === 'c' ? cateMk() : slugMk(hp));
  }

  /* butterfly */
  function butterflyMk(c1, c2) {
    return '<g class="bfbody"><g class="bfw bfl"><path d="M0 0C-6 -14 -20 -16 -22 -6C-23 2 -10 4 0 2Z" fill="' + c1 + '" stroke="#3a2a1a" stroke-width=".8"/><path d="M0 2C-6 4 -16 8 -14 14C-12 19 -4 12 0 6Z" fill="' + c2 + '" stroke="#3a2a1a" stroke-width=".8"/><circle cx="-14" cy="-6" r="3" fill="#fff" opacity=".75"/></g>' +
      '<g class="bfw bfr"><path d="M0 0C6 -14 20 -16 22 -6C23 2 10 4 0 2Z" fill="' + c1 + '" stroke="#3a2a1a" stroke-width=".8"/><path d="M0 2C6 4 16 8 14 14C12 19 4 12 0 6Z" fill="' + c2 + '" stroke="#3a2a1a" stroke-width=".8"/><circle cx="14" cy="-6" r="3" fill="#fff" opacity=".75"/></g>' +
      '<ellipse cx="0" cy="2" rx="1.8" ry="7" fill="#3a2a1a"/><circle cx="0" cy="-6" r="2.2" fill="#3a2a1a"/><path d="M-1 -8q-3 -5 -6 -5M1 -8q3 -5 6 -5" stroke="#3a2a1a" stroke-width=".8" fill="none"/></g>';
  }

  /* ================= the game ================= */
  var NS = 'http://www.w3.org/2000/svg';
  function init(game) {
    game.classList.add('on');
    var round, R;
    try { round = JSON.parse(game.getAttribute('data-round')); R = JSON.parse(game.getAttribute('data-rules')); } catch (e) { return; }
    var stageEl = game.querySelector('.pststage'), chips = game.querySelector('.pstchips'), form = game.querySelector('form.pestform'), how = game.querySelector('.psthow');
    if (!stageEl || !form || !round || !R) return;
    var reduce = rmq.matches;
    var pl = plantSvg(round.design, round.n);
    var svg = document.createElementNS(NS, 'svg');
    svg.setAttribute('viewBox', '0 0 320 360'); svg.setAttribute('class', 'pstsvg'); svg.setAttribute('role', 'group');
    svg.setAttribute('aria-label', NAMES[round.design] + ' plant with pests on its leaves. Tap a pest to flick it off.');
    svg.innerHTML = pl.svg + '<g class="pst-pests"></g><g class="pst-pops"></g><g class="pst-bf"></g>';
    stageEl.appendChild(svg);
    var say = document.createElement('div'); say.className = 'pstsay'; say.setAttribute('role', 'status'); say.setAttribute('aria-live', 'polite'); stageEl.appendChild(say);
    var barWrap = document.createElement('div'); barWrap.className = 'pstbar'; barWrap.innerHTML = '<i></i>'; stageEl.parentNode.insertBefore(barWrap, stageEl.nextSibling);
    var bar = barWrap.firstChild;
    var nameTag = document.createElement('div'); nameTag.className = 'pstname'; nameTag.textContent = NAMES[round.design]; stageEl.appendChild(nameTag);
    if (how) how.textContent = 'Tap a pest to flick it off. Tapping a bare leaf bruises it: three bruises and it falls.';
    // chips
    chips.innerHTML = '<span class="gmchip">' + gvIco('ico-clock') + ' <b class="ct">–</b></span><span class="gmchip">' + gvIco('ico-star', 'Star') + ' <b class="cs">0</b></span><span class="gmchip cc">' + gvIco('ico-fire') + ' <b>–</b></span><span class="gmchip">' + gvIco('ico-leaf') + ' <b class="cl">' + round.n + '</b></span>' + (round.net ? '<span class="gmchip" title="Bug net in your satchel">' + gvIco('ico-butterfly') + ' net <small class="muted">in satchel</small></span>' : '');
    var cT = chips.querySelector('.ct'), cS = chips.querySelector('.cs'), cC = chips.querySelector('.cc b'), cCc = chips.querySelector('.cc'), cL = chips.querySelector('.cl');

    var leafEl = [], leafGeo = [];
    svg.querySelectorAll('.lfo').forEach(function (o) {
      var lf = o.querySelector('.lf'), i = +lf.getAttribute('data-leaf');
      leafEl[i] = { o: o, lf: lf, inn: o.querySelector('.lfin'), dmg: o.querySelector('.dmg') };
      o.style.setProperty('--ox', o.getAttribute('data-ox') + 'px'); o.style.setProperty('--oy', o.getAttribute('data-oy') + 'px');
    });
    pl.plant.leaves.forEach(function (l) { leafGeo[l.i] = l; });
    // grow-in: delays come from data-d
    svg.querySelectorAll('[data-d]').forEach(function (e) { e.style.setProperty('--d', e.getAttribute('data-d') + 's'); });
    var pestsG = svg.querySelector('.pst-pests'), popsG = svg.querySelector('.pst-pops'), bfG = svg.querySelector('.pst-bf');
    var M = makeMachine(round, R), taps = [], view = [], state = 'grow', t0 = 0, done = false, bfv = null, lastHud = 0;
    var seedN = round.seed || 1;
    if (reduce) { game.classList.add('still'); } else { game.classList.add('grow'); }
    function say_(txt, ms) { say.textContent = txt; say.classList.add('on'); clearTimeout(say._t); say._t = setTimeout(function () { say.classList.remove('on'); }, ms || 2600); }

    function svgPt(ev) {
      var r = svg.getBoundingClientRect();
      return [(ev.clientX - r.left) / r.width * 320, (ev.clientY - r.top) / r.height * 360];
    }
    function pop(x, y, txt, cls) {
      var tx = document.createElementNS(NS, 'text');
      tx.setAttribute('x', r1(x)); tx.setAttribute('y', r1(y)); tx.setAttribute('class', 'pstpop ' + (cls || '')); tx.setAttribute('text-anchor', 'middle');
      tx.textContent = txt; popsG.appendChild(tx);
      setTimeout(function () { if (tx.parentNode) tx.parentNode.removeChild(tx); }, 1100);
    }
    function ripple(x, y, cls) {
      var c = document.createElementNS(NS, 'circle');
      c.setAttribute('cx', r1(x)); c.setAttribute('cy', r1(y)); c.setAttribute('r', '4'); c.setAttribute('class', 'pstrip ' + (cls || ''));
      popsG.appendChild(c); setTimeout(function () { if (c.parentNode) c.parentNode.removeChild(c); }, 500);
    }
    function pestEl(pi) {
      var p = M.P[pi], g = document.createElementNS(NS, 'g');
      g.setAttribute('class', 'pst pk-' + p.k);
      var inner = document.createElementNS(NS, 'g'); inner.setAttribute('class', 'pin'); g.appendChild(inner);
      var hc = document.createElementNS(NS, 'circle'); hc.setAttribute('class', 'phit'); hc.setAttribute('r', '20'); g.appendChild(hc);   // a tap on the pest counts as a tap on its leaf
      pestsG.appendChild(g);
      return { g: g, inner: inner, hp: -1, leaf: -2, died: false };
    }
    function placePest(v, leaf, soft) {
      var geo = leafGeo[leaf]; if (!geo) return;
      var jx = ((leaf * 7) % 5 - 2) * 2, jy = ((leaf * 3) % 3 - 1) * 2;
      if (v.leaf !== leaf) { v.g.setAttribute('data-leaf', leaf); v.g.style.setProperty('transform', 'translate(' + r1(geo.cx + jx) + 'px,' + r1(geo.cy + jy) + 'px)'); v.leaf = leaf; }
    }
    function killView(pi, how) {
      var v = view[pi]; if (!v || v.died) return;
      v.died = true;
      if (how === 'flick') { v.g.classList.add('flick'); v.g.style.setProperty('--fx', ((pi % 2 ? 1 : -1) * (40 + (pi * 13) % 30)) + 'px'); v.g.style.setProperty('--fy', (-50 - (pi * 7) % 30) + 'px'); }
      else if (how === 'escape') v.g.classList.add('away');
      else v.g.classList.add('gone');
      setTimeout(function () { if (v.g.parentNode) v.g.parentNode.removeChild(v.g); }, reduce ? 50 : 700);
    }
    function netSwoosh(x, y) {   // a bug net sweeping over the butterfly
      var n = document.createElementNS(NS, 'g'); n.setAttribute('class', 'pstnet');
      n.innerHTML = '<g transform="translate(' + r1(x) + ' ' + r1(y) + ')"><path d="M-10 -4A16 16 0 1 1 6 12" fill="#fff" fill-opacity=".25" stroke="#7a5a30" stroke-width="2.4"/><path d="M-6 4L8 -6M-2 10L12 0M-8 -2L2 -10" stroke="#7a5a30" stroke-width=".8" opacity=".6"/><path d="M6 12L24 30" stroke="#a07848" stroke-width="3.4" stroke-linecap="round"/></g>';
      popsG.appendChild(n); setTimeout(function () { if (n.parentNode) n.parentNode.removeChild(n); }, 700);
    }
    function leafAt(i) { var g = leafGeo[i]; return g ? [g.cx, g.cy] : [160, 160]; }

    function drain() {
      var L = M.log; if (!L.length) return;
      for (var i = 0; i < L.length; i++) {
        var e = L[i], pos;
        if (e.e === 'flick') {
          pos = leafAt(e.leaf); killView(e.pi, 'flick');
          pop(pos[0], pos[1] - 12, '+' + e.pts, e.bonus ? 'combo' : '');
          if (e.combo >= 3) pop(pos[0], pos[1] - 30, e.combo + ' in a row!', 'streak');
          cCc.classList.remove('bump'); void cCc.offsetWidth; cCc.classList.add('bump');
          ripple(pos[0], pos[1], 'good');
        } else if (e.e === 'hit') {
          var hv = view[e.pi]; pos = leafAt(e.leaf);
          if (hv) { hv.g.classList.remove('hurt'); void hv.g.getBoundingClientRect(); hv.g.classList.add('hurt'); }
          ripple(pos[0], pos[1], 'good');
        } else if (e.e === 'bruise') {
          var lv = leafEl[e.leaf]; pos = leafAt(e.leaf);
          if (lv) { lv.lf.classList.remove('b1', 'b2', 'b3'); for (var b = 1; b <= Math.min(3, e.n); b++) lv.lf.classList.add('b' + b); lv.inn.classList.remove('shake'); void lv.inn.getBoundingClientRect(); lv.inn.classList.add('shake'); }
          pop(pos[0], pos[1] - 6, e.n >= R.bruise ? 'ouch!' : 'bruised', 'bad');
          ripple(pos[0], pos[1], 'bad');
        } else if (e.e === 'drop') {
          var dv = leafEl[e.leaf]; pos = leafAt(e.leaf);
          if (dv) { dv.o.classList.add('fall'); dv.o.style.setProperty('--sw', (e.leaf % 2 ? 1 : -1)); if (reduce) dv.o.classList.add('gone'); else setTimeout(function (o) { return function () { o.classList.add('gone'); }; }(dv.o), 1500); }
          pop(pos[0], pos[1] - 16, '−' + R.fall, 'bad');
          say_(e.why === 'chew' ? 'A leaf was eaten off!' : 'That leaf fell off!', 1800);
        } else if (e.e === 'gone') { killView(e.pi, 'gone'); }
        else if (e.e === 'escape') { killView(e.pi, 'escape'); }
        else if (e.e === 'bfcatch') {
          if (bfv) { bfv.g.classList.add('caught'); pop(bfv.x, bfv.y - 14, '+' + R.bf + ' 🦋', 'combo'); ripple(bfv.x, bfv.y, 'good'); netSwoosh(bfv.x, bfv.y); bfv.dead = true; setTimeout(function (v) { return function () { if (v.g.parentNode) v.g.parentNode.removeChild(v.g); }; }(bfv), 700); }
          say_('Caught a butterfly! A Wing Scale is yours.', 3000);
        } else if (e.e === 'bfnonet') {
          if (bfv) { bfv.g.classList.add('flee'); bfv.dead = true; setTimeout(function (v) { return function () { if (v.g.parentNode) v.g.parentNode.removeChild(v.g); }; }(bfv), 1000); }
          say_('Oh shoot, you need a bug net!', 3200);
        }
      }
      L.length = 0;
    }

    /* butterfly path (the server only knows when it is on screen; the page flies it) */
    var bfBase = 70 + (seedN % 120), bfDir = (seedN % 2) ? 1 : -1, bfPhase = (seedN % 7);
    function bfPos(u) {
      var x = bfDir > 0 ? -24 + u * 368 : 344 - u * 368;
      return [x, bfBase + Math.sin(u * 9 + bfPhase) * 22 + Math.sin(u * 3.3 + bfPhase) * 32];
    }
    function bfMake() {
      var g = document.createElementNS(NS, 'g'); g.setAttribute('class', 'pstbf'); g.setAttribute('data-bf', '1');
      var cols = [['#f08a2a', '#f7c66a'], ['#4a8fd8', '#9cc6f0'], ['#f2c82a', '#fbe68a'], ['#c25ad6', '#e8a8f0']][seedN % 4];
      g.innerHTML = '<g class="bfin">' + butterflyMk(cols[0], cols[1]) + '</g><circle class="bfhit" r="27"/>';
      bfG.appendChild(g);
      return { g: g, x: -50, y: 0, dead: false };
    }

    function hud(t) {
      var left = Math.max(0, Math.ceil((round.dur - t) / 1000));
      cT.textContent = left + 's'; cS.textContent = String(Math.max(0, M.S.score));
      cC.textContent = M.S.combo >= 2 ? '×' + M.S.combo : '–';
      var n = 0; M.alive.forEach(function (a) { if (a) n++; }); cL.textContent = String(n);
      bar.style.setProperty('transform', 'scaleX(' + Math.max(0, Math.min(1, 1 - t / round.dur)).toFixed(3) + ')');
      cCc.classList.toggle('hot', M.S.combo >= 3);
    }

    function frame() {
      if (state !== 'play') return;
      var now = NOW(), t = Math.floor(now - t0);
      if (t >= round.dur) { end(); return; }
      M.advance(t);
      drain();
      // pests: show those that have arrived, keep gnats hopping, chew damage on leaves
      var dmg = [];
      for (var pi = 0; pi < M.P.length; pi++) {
        var p = M.P[pi], v = view[pi];
        if (!p.alive) continue;
        var leaf, start;
        if (p.k === 'g') { leaf = M.curLeaf(p, t); start = p.h[0][0]; } else { leaf = p.l; start = p.t; }
        if (leaf < 0 || t < start) continue;
        if (!v) { v = view[pi] = pestEl(pi); }
        if (v.died) continue;
        if (v.hp !== p.hp) { v.inner.innerHTML = '<g transform="scale(' + (p.k === 'g' ? 1.45 : 1.3) + ')"><g class="idle">' + pestMk(p.k, p.hp) + '</g></g>'; v.hp = p.hp; }
        placePest(v, leaf);
        if (p.k !== 'g') {
          var prog = (t - p.t) / R.kinds[p.k].chew;
          dmg[leaf] = Math.max(dmg[leaf] || 0, prog);
          v.g.classList.toggle('warn', prog > 0.65);
        }
      }
      for (var li = 0; li < round.n; li++) {
        var lv = leafEl[li]; if (!lv || !M.alive[li]) continue;
        var o = dmg[li] ? Math.min(0.78, dmg[li] * 0.85) : 0;
        if (lv.dv !== o) { lv.dmg.style.setProperty('opacity', o.toFixed(2)); lv.dv = o; }
        var chewing = dmg[li] > 0.65;
        if (lv.ch !== chewing) { lv.inn.classList.toggle('chew', chewing); lv.ch = chewing; }
      }
      // butterfly
      if (round.bf && !bfv && t >= round.bf[0] && t <= round.bf[0] + round.bf[1] && !M.S.caught && !M.S.nonet) bfv = bfMake();
      if (bfv && !bfv.dead) {
        var u = (t - round.bf[0]) / round.bf[1];
        if (u > 1) { bfv.dead = true; if (bfv.g.parentNode) bfv.g.parentNode.removeChild(bfv.g); }
        else { var bp = bfPos(u); bfv.x = bp[0]; bfv.y = bp[1]; bfv.g.style.setProperty('transform', 'translate(' + r1(bp[0]) + 'px,' + r1(bp[1]) + 'px)'); }
      }
      if (now - lastHud > 90) { hud(t); lastHud = now; }
      RAF(frame);
    }

    function tapAt(target, ev) {
      if (state !== 'play' || done) return;
      var t = Math.floor(NOW() - t0);
      if (t < 0 || t >= round.dur || taps.length >= 250) return;
      taps.push([t, target]);
      M.tap(t, target);
      drain();
      hud(t);
    }
    svg.addEventListener('pointerdown', function (ev) {
      if (ev.button !== undefined && ev.button > 0) return;
      var tg = ev.target.closest ? ev.target.closest('[data-leaf],[data-bf]') : null;
      if (!tg) return;
      ev.preventDefault();
      if (tg.hasAttribute('data-bf')) { tapAt(-1, ev); return; }
      tapAt(+tg.getAttribute('data-leaf'), ev);
    });
    svg.addEventListener('keydown', function (ev) {
      if (ev.key !== 'Enter' && ev.key !== ' ') return;
      var tg = ev.target.closest ? ev.target.closest('[data-leaf]') : null;
      if (!tg) return;
      ev.preventDefault(); tapAt(+tg.getAttribute('data-leaf'), ev);
    });
    svg.addEventListener('contextmenu', function (ev) { ev.preventDefault(); });

    function end() {
      if (state === 'over') return;
      state = 'over';
      M.advance(round.dur); drain(); hud(round.dur);
      game.classList.add('over');
      say_('Time! Counting up…', 4000);
      game.querySelectorAll('.pst').forEach(function (g) { g.classList.add('gone'); });
      form.querySelector('input[name=taps]').value = JSON.stringify(taps);
      setTimeout(send, reduce ? 300 : 900);
    }
    function send() {
      if (done) return;
      done = true;
      form.setAttribute('data-fired', '1');
      var b = form.querySelector('button');
      try { if (form.requestSubmit) form.requestSubmit(b || undefined); else form.submit(); } catch (e) { form.submit(); }
    }
    form.addEventListener('submit', function (ev) {
      if (form.getAttribute('data-fired') === '1') return;   // the real one
      ev.preventDefault();
    });
    function begin() {
      if (state !== 'grow') return;
      state = 'play'; game.classList.remove('grow'); t0 = NOW();
      lastHud = 0;
      RAF(frame);
      // a stalled tab still hands the round in (frames pause while hidden, so check by the clock too)
      var guard = setInterval(function () {
        if (state === 'over' || done) { clearInterval(guard); return; }
        if (NOW() - t0 >= round.dur + 400) { clearInterval(guard); end(); }
      }, 500);
    }
    hud(0);
    setTimeout(begin, reduce ? 350 : 1650);
  }

  function scan() { document.querySelectorAll('.pestgame:not(.on)').forEach(init); }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
  /* a small hook for the contact sheet and the tests */
  window.gvPest = { count: D.length, names: NAMES, sheet: function (i) { return plantSvg(i, D[i].n).svg; }, leaves: function (i) { return D[i].n; }, makeMachine: makeMachine };
})();
