/* Gnome Venture v1.5.0: the six tool games (Spore Lure, Stem Trace, Log Split, Glint Strike, Bug Swoop, Drip Catch).
   Vanilla JS, no libraries. The server makes each round (fish and pattern, stem curve, log sway, glint spots, bug flight paths,
   drip times) and scores what the player DID; this file only draws the round and records inputs with their times. It uses
   the same rules the server does, so what you see is what gets scored. Touch, mouse and keyboard all work. With "reduce
   motion" on, the timing games become the still 'cue' round (tap when it says NOW); the lure and the trace play as they are.
   Also runs the Practice tab (data-practice): same rounds, nothing paid. Loaded on demand by site.js; gvGather() sets up
   any panel not yet ready. */
(function () {
  'use strict';
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var SVGNS = 'http://www.w3.org/2000/svg';

  function el(tag, cls, parent, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    if (parent) parent.appendChild(n);
    return n;
  }
  function pct(n) { return (Math.round(n * 100) / 100) + '%'; }
  function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }
  function ease(u) { u = clamp(u, 0, 1); return u < 0.5 ? 2 * u * u : 1 - Math.pow(-2 * u + 2, 2) / 2; }
  function easeOut(u) { u = clamp(u, 0, 1); return 1 - (1 - u) * (1 - u); }
  function segDist(px, py, ax, ay, bx, by) {
    var dx = bx - ax, dy = by - ay, l2 = dx * dx + dy * dy, u = l2 > 0 ? clamp(((px - ax) * dx + (py - ay) * dy) / l2, 0, 1) : 0;
    return Math.hypot(px - (ax + u * dx), py - (ay + u * dy));
  }
  function flitPos(b, t) {   // the same flight path the server uses
    var u = clamp((t - b.a) / b.life, 0, 1), dx = b.x1 - b.x0, dy = b.y1 - b.y0, len = Math.max(1, Math.hypot(dx, dy));
    var off = b.fa * Math.sin(b.ff * (t - b.a) + b.fp);
    return [b.x0 + dx * u - dy / len * off, b.y0 + dy * u + dx / len * off];
  }

  /* ---- the games: each gets ctx and returns {tick(t), act(), cancel()} ---- */
  var GAMES = {};

  /* ======== 🎣 Spore Lure ======== */
  var SYM = ['●', '▲', '■', '◆'], COLNAME = ['blue', 'gold', 'rose', 'violet'];
  GAMES.lure = function (c) {
    var r = c.r, ev = [], pos = 0, tries = 0, phase = r.showEnd, replayAt = null, lastTap = -1e9, mode = 'play', outT = 0, outcome = '', wiggle = -1e9, said = '', pips = [], btns = [], open = false;
    var RX = clamp(50 + r.size * 0.62 + 3, 56, 80), RY = 60, LY = 58;
    c.bg('rod-bg.svg');
    var svg = c.svg('svg', { 'class': 'gsvg', viewBox: '0 0 100 100', preserveAspectRatio: 'none' }, c.field);
    var glow = c.svg('path', { 'class': 'gthread glow', d: '' }, svg), thread = c.svg('path', { 'class': 'gthread', d: '' }, svg);
    var lure = c.piece('rod-lure.svg', 'gpiece glure'); lure.style.left = '50%'; lure.style.top = pct(LY);
    var ring = el('span', 'glring', c.field); ring.style.left = '50%'; ring.style.top = pct(LY);
    var fish = el('div', 'glfish', c.field); fish.style.width = pct(r.size);
    var fimg = c.img('rod-fish.svg', 'glfimg', fish); fimg.style.filter = 'hue-rotate(' + r.hue + 'deg)';
    var lamp = el('div', 'glamp', fish);
    function setLamp(col) { var k = col >= 0 ? 'glamp on c' + col : 'glamp'; if (lamp.className !== k) { lamp.className = k; lamp.textContent = col >= 0 ? SYM[col] : ''; } }
    function drawThread(t) {
      var sw = c.rm ? 0 : Math.sin(t / 650) * 1.4, d = 'M50 -2 C ' + (50 + sw) + ' 20, ' + (50 - sw) + ' 40, 50 ' + (LY - 5);
      thread.setAttribute('d', d); glow.setAttribute('d', d);
    }
    // the spore buttons and the pips (what you have pulsed so far)
    var pipRow = el('div', 'glpips', c.pad), row = el('div', 'glpad', c.pad);
    for (var i = 0; i < r.L; i++) pips.push(el('span', 'glpip', pipRow));
    for (var k = 0; k < r.nc; k++) (function (k) {
      var b = el('button', 'glbtn c' + k, row); b.type = 'button'; b.disabled = true;
      b.setAttribute('aria-label', 'Pulse ' + COLNAME[k] + ' (key ' + (k + 1) + ')');
      el('span', 'glsym', b, SYM[k]); el('small', 'glkey', b, String(k + 1));
      b.addEventListener('pointerdown', function (e) { e.preventDefault(); tap(k); });
      b.addEventListener('keydown', function (e) { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); e.stopPropagation(); tap(k); } });
      btns.push(b);
    })(k);
    c.noAct();
    c.key(function (e) { var n = +e.key; if (n >= 1 && n <= r.nc) { tap(n - 1); return true; } return false; });
    function say(t) { if (t !== said) { said = t; c.say(t); } }
    function enable(on) { if (on !== open) { open = on; btns.forEach(function (b) { b.disabled = !on; }); row.classList.toggle('ready', on); } }
    function resetPips() { pips.forEach(function (p) { p.className = 'glpip'; }); }
    function ripple(col) {
      ring.className = 'glring'; void ring.offsetWidth; ring.className = 'glring go c' + col;
      lure.classList.remove('flash'); void lure.offsetWidth; lure.classList.add('flash');
    }
    function finish(res, t) {
      mode = 'out'; outcome = res; outT = t; enable(false);
      if (res === 'miss') { setLamp(-1); say('It nibbled the glow and drifted off…'); c.done(ev, 1250); }
      else { c.burst(RX, RY, 'bubble', 10); say(res === 'perfect' ? 'Hooked! Up the thread it spirals!' : 'Got it, second time lucky!'); c.done(ev, 1500); }
    }
    function tap(col) {
      if (c.over() || mode !== 'play') return;
      var t = Math.round(c.now());
      if (t < phase || t < lastTap + 130) return;
      ev.push([col, t]); lastTap = t; ripple(col);
      if (col === r.pat[pos]) {
        pips[pos].className = 'glpip got c' + col; pos++;
        if (pos >= r.L) { finish(tries === 0 ? 'perfect' : 'good', t); return; }
        say(pos + ' of ' + r.L + '…');
      } else {
        pips[pos].className = 'glpip bad'; tries++; wiggle = t;
        if (tries >= r.lives) { finish('miss', t); return; }
        pos = 0; replayAt = t + r.rep; phase = t + r.rep + r.L * (r.bl + r.gap); enable(false);
        setTimeout(resetPips, 450);
        say('Nibble! Not that one. Watch again…');
      }
    }
    say('A fish is swimming up…');
    return {
      tick: function (t) {
        drawThread(t);
        // the fish: swims up, blinks, then is caught or lost
        var x = RX, y = RY, rot = 0, sc = 1, op = 1;
        if (t < r.a) { var u = easeOut(t / r.a); x = RX + (112 - RX) * (1 - u); y = RY + (88 - RY) * (1 - u); rot = (1 - u) * -8; }
        else if (!c.rm) { y += Math.sin(t / 420) * 0.9; rot = Math.sin(t / 700) * 2; }
        if (t - wiggle < 380 && !c.rm) { x += Math.sin((t - wiggle) / 22) * 1.8 * (1 - (t - wiggle) / 380); }
        if (mode === 'out') {
          var o = clamp((t - outT) / (outcome === 'miss' ? 1100 : 1350), 0, 1);
          if (outcome === 'miss') { x = RX + 26 * easeOut(o); y = RY + 14 * o; op = 1 - o; rot = 12 * o; }
          else if (c.rm) { op = 1 - o; }
          else {   // a spiral to the lure, then up the thread
            var e = ease(o), a = e * Math.PI * 5, rad = 15 * (1 - e * 0.75), f = clamp(e / 0.4, 0, 1);
            var cx = 50 + (RX - 50) * (1 - f), cy = e < 0.4 ? RY + (LY - RY) * f : LY + (8 - LY) * ((e - 0.4) / 0.6);
            x = cx + Math.sin(a) * rad; y = cy + Math.cos(a) * rad * 0.35; rot = (a * 57.3) % 360; sc = 1 - 0.6 * e; op = o > 0.88 ? (1 - o) / 0.12 : 1;
          }
        }
        fish.style.left = pct(x); fish.style.top = pct(y);
        fish.style.transform = 'translate(-50%,-50%) rotate(' + rot.toFixed(1) + 'deg) scale(' + sc.toFixed(3) + ')'; fish.style.opacity = String(op);
        if (mode !== 'play') { return; }
        // blinks: the first show, and the replay after a nibble
        var s0 = t < r.showEnd ? r.a : (replayAt !== null && t < phase ? replayAt : null), col = -1;
        if (s0 !== null && t >= s0) {
          var per = r.bl + r.gap, j = Math.floor((t - s0) / per);
          if (j < r.L && (t - s0) - j * per < r.bl) col = r.pat[j];
        }
        setLamp(col);
        if (t >= phase) {
          enable(true); say(tries ? 'Last chance! Pulse it back.' : 'Pulse it back in order!');
          if (t - Math.max(lastTap, phase) > r.idle) finish('miss', t);
        } else if (replayAt !== null) { if (t >= replayAt) say('Watch the pattern again…'); }
        else if (t >= r.a) say('Watch its side glow…');
      },
      act: function () {}, cancel: function () {}
    };
  };

  /* ======== 🔪 Stem Trace ======== */
  GAMES.trace = function (c) {
    var r = c.r, pts = r.pts, np = pts.length, tol = r.tol, ev = [], covered = [], down = false, lastT = -1e9, lastX = pts[0][0], lastY = pts[0][1], cur = [pts[0][0], pts[0][1]], fin = false, cum = [0], leaves = [], prog = 0, lastPt = null, sayAt = 0;
    for (var i = 1; i < np; i++) cum.push(cum[i - 1] + Math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1]));
    var total = cum[np - 1];
    c.bg('knife-bg.svg');
    var svg = c.svg('svg', { 'class': 'gsvg', viewBox: '0 0 100 100', preserveAspectRatio: 'none' }, c.field);
    var d = 'M' + pts.map(function (p) { return p[0] + ' ' + p[1]; }).join(' L');
    var g = c.svg('g', { 'class': 'gstemg' }, svg);
    c.svg('path', { 'class': 'gstem sh', d: d }, g);
    c.svg('path', { 'class': 'gstem base', d: d }, g);
    c.svg('path', { 'class': 'gstem mid', d: d }, g);
    c.svg('path', { 'class': 'gstem hi', d: d }, g);
    for (var q = 4; q < np - 3; q += 5) {   // leaves on alternate sides
      var a = pts[q - 1], b = pts[q + 1], ang = Math.atan2(b[1] - a[1], b[0] - a[0]) + (((q / 5) | 0) % 2 ? 1 : -1) * 1.05;
      var lf = c.svg('ellipse', { 'class': 'gleaf', cx: pts[q][0] + Math.cos(ang) * 4.6, cy: pts[q][1] + Math.sin(ang) * 4.6, rx: 4.6, ry: 2.1, transform: 'rotate(' + (ang * 57.3).toFixed(0) + ' ' + (pts[q][0] + Math.cos(ang) * 4.6).toFixed(1) + ' ' + (pts[q][1] + Math.sin(ang) * 4.6).toFixed(1) + ')' }, g);
      leaves.push({ el: lf, i: q, dx: Math.cos(ang) * 9, dy: Math.sin(ang) * 9 + 6 });
    }
    c.svg('path', { 'class': 'gcutline', d: d }, svg);
    var done = c.svg('path', { 'class': 'gcutdone', d: d, 'stroke-dasharray': '0 999' }, svg);
    var s0 = c.svg('circle', { 'class': 'gcutstart', cx: pts[0][0], cy: pts[0][1], r: 3.4 }, svg);
    c.svg('circle', { 'class': 'gcutend', cx: pts[np - 1][0], cy: pts[np - 1][1], r: 3.2 }, svg);
    var blade = c.piece('knife-blade.svg', 'gpiece gblade'); blade.style.left = pct(cur[0]); blade.style.top = pct(cur[1]);
    var bar = el('div', 'gtally', c.field, '0%');
    for (i = 0; i < np; i++) covered.push(false);
    function toField(e) {
      var rc = c.field.getBoundingClientRect();
      return [clamp(100 * (e.clientX - rc.left) / rc.width, 0, 100), clamp(100 * (e.clientY - rc.top) / rc.height, 0, 100)];
    }
    function off(x, y) { var m = 1e9; for (var i = 1; i < np; i++) m = Math.min(m, segDist(x, y, pts[i - 1][0], pts[i - 1][1], pts[i][0], pts[i][1])); return m; }
    function sample(x, y, force) {
      var t = Math.round(c.now());
      cur = [x, y]; blade.style.left = pct(x); blade.style.top = pct(y);
      var wander = off(x, y) > tol * 1.7; blade.classList.toggle('off', wander);
      if (wander && t > sayAt) { sayAt = t + 1500; c.say('Back to the glowing line!'); }
      if (t < 250 || fin) return;
      var dt = t - lastT;
      if (ev.length && (dt < 8 || (!force && dt < 60))) return;
      if (ev.length && dt < 350 && Math.hypot(x - lastX, y - lastY) > 0.12 * dt + 2) return;   // faster than a finger could (or a jump): wait
      ev.push([Math.round(x * 10), Math.round(y * 10), t]);
      for (var i = 0; i < np; i++) {
        if (covered[i]) continue;
        var dd = lastPt && dt < 400 ? segDist(pts[i][0], pts[i][1], lastPt[0], lastPt[1], x, y) : Math.hypot(pts[i][0] - x, pts[i][1] - y);
        if (dd <= tol * 1.15) covered[i] = true;
      }
      lastT = t; lastX = x; lastY = y; lastPt = [x, y];
      var k = 0; while (k < np && covered[k]) k++;
      if (k > prog) { prog = k; progress(); }
    }
    function progress() {
      var len = prog >= np ? total : cum[Math.max(0, prog - 1)];
      done.setAttribute('stroke-dasharray', len.toFixed(1) + ' 999');
      bar.textContent = Math.round(100 * len / total) + '%';
      leaves.forEach(function (l) { if (!l.gone && prog > l.i) { l.gone = true; l.el.style.transform = 'translate(' + l.dx + 'px,' + l.dy + 'px) rotate(40deg)'; l.el.classList.add('fall'); } });
      if (prog >= np) end(true);
    }
    function end(whole) {
      if (fin) return; fin = true;
      g.classList.add('split'); done.classList.add('flash');
      for (var i = 0; i < 7; i++) { var p = pts[Math.floor(i * (np - 1) / 6)]; c.burst(p[0], p[1], 'sap', 4); }
      c.say(whole ? 'Snick! A long, clean cut.' : 'Cut where you could…');
      c.done(ev, 1300);
    }
    c.field.addEventListener('pointerdown', function (e) {
      if (c.over() || fin) return; e.preventDefault(); down = true;
      try { c.field.setPointerCapture(e.pointerId); } catch (x) {}
      var p = toField(e); sample(p[0], p[1], true); blade.classList.add('on');
    });
    c.field.addEventListener('pointermove', function (e) {
      if (!down || c.over() || fin) return; var p = toField(e); sample(p[0], p[1], false);
    });
    function up() { if (!down) return; down = false; if (!fin) sample(cur[0], cur[1], true); }
    c.field.addEventListener('pointerup', up); c.field.addEventListener('pointercancel', up);
    c.key(function (e) {
      var s = 1.8, m = { ArrowLeft: [-s, 0], ArrowRight: [s, 0], ArrowUp: [0, -s], ArrowDown: [0, s] }[e.key];
      if (!m) return false;
      blade.classList.add('on'); sample(clamp(cur[0] + m[0], 0, 100), clamp(cur[1] + m[1], 0, 100), false); return true;
    });
    c.say('Drag along the glowing line, start to end.');
    return {
      tick: function (t) {
        s0.setAttribute('class', 'gcutstart' + (ev.length ? ' used' : ''));
        if (down && !fin && t - lastT > 1500 && ev.length) sample(cur[0], cur[1], true);   // keep the clock honest while holding still
        if (t > r.dur && !fin) end(false);
      },
      act: function () { if (!fin) end(false); },
      cancel: function () {}
    };
  };

  /* ======== 🪓 Log Split ======== */
  GAMES.chop = function (c) {
    var r = c.r, ev = [], i = 0, start = r.first, state = 'wait', tapT = 0, tally = [], resT = 0, lastRes = '', live = null, offNow = 0;
    c.bg('axe-bg.svg');
    var rsvg = c.svg('svg', { 'class': 'gsvg', viewBox: '0 0 100 100', preserveAspectRatio: 'none' }, c.field);
    var rope = c.svg('line', { 'class': 'gropeln', x1: 50, y1: 3, x2: 50, y2: 27 }, rsvg);
    c.svg('circle', { 'class': 'gropehook', cx: 50, cy: 3, r: 2 }, rsvg); rope.style.opacity = '0';
    var aim = el('div', 'gaim', c.field);
    var axe = c.piece('axe-head.svg', 'gpiece gaxe');
    var tl = el('div', 'gtallyrow', c.field);
    for (var k = 0; k < r.n; k++) tally.push(el('span', 'gtpip', tl));
    function newLog() {
      live = { box: el('div', 'glog', c.field) };
      live.img = c.img('axe-log.svg', 'glogimg', live.box);
      live.box.style.opacity = '0';
    }
    function place(box, off, drop) {
      box.style.left = pct(50 + off); box.style.top = pct(48 + (drop || 0));
      box.style.transform = 'translate(-50%,-50%) rotate(' + (off * 0.32).toFixed(1) + 'deg)';
      if (box === (live && live.box)) { rope.setAttribute('x2', (50 + off * 0.92).toFixed(1)); rope.setAttribute('y2', (27 + (drop || 0)).toFixed(1)); }
    }
    function offAt(t) { var o = r.amp * Math.sin(2 * Math.PI * (t - start) / r.per[i] + r.ph[i]); return o; }
    function strike(t) {
      var off = offAt(t), d = Math.abs(off), res = d <= r.p / 2 ? 'perfect' : (d <= r.g / 2 ? 'good' : 'miss');
      ev.push(t); tapT = t; state = 'hit'; lastRes = res; tally[i].className = 'gtpip ' + res;
      live.at = off; place(live.box, off, 0); live.box.classList.remove('near');
      axe.style.left = pct(50); axe.classList.remove('up'); axe.classList.add('drop'); axe.classList.toggle('miss', res === 'miss');
      setTimeout(function () { split(res, off); }, c.rm ? 0 : 150);
      return res;
    }
    function split(res, off) {
      var x = 50 + off, y = 48;
      if (res === 'miss') {
        live.box.classList.add('thunk'); c.burst(x, y - 6, 'chip', 3); c.say('Thunk! The axe glances off.');
      } else {
        live.box.style.visibility = 'hidden'; rope.style.opacity = '0';
        ['l', 'r'].forEach(function (s) {
          var h = el('div', 'glogh ' + s, c.field), inner = el('div', 'glogin', h); c.img('axe-log.svg', 'glogimg', inner);
          place(h, off, 0);
          void h.offsetWidth; h.classList.add(res === 'perfect' ? 'wide' : 'half'); live.halves = (live.halves || []).concat(h);
        });
        c.burst(x, y - 4, 'chip', res === 'perfect' ? 11 : 6); if (res === 'perfect') c.burst(x, y - 6, 'spark', 7);
        c.say(res === 'perfect' ? 'CRACK! Split clean down the grain.' : 'Split! A bit ragged.');
      }
      if (c.rm) axe.classList.remove('drop');
      setTimeout(function () { axe.classList.remove('drop'); axe.classList.add('up'); }, 300);
    }
    function next(newStart) {
      var old = live; i++;
      if (old) setTimeout(function () { [old.box].concat(old.halves || []).forEach(function (n) { if (n.parentNode) n.parentNode.removeChild(n); }); }, 700);
      live = null;
      if (i >= r.n) { state = 'over'; c.done(ev, 600); return; }
      start = newStart; state = 'wait';
    }
    c.say('Log 1 of ' + r.n + ': chop when the grain is under the axe.');
    return {
      tick: function (t) {
        if (state === 'wait' && t >= start) { newLog(); state = 'sway'; live.box.classList.add('in'); c.say('Log ' + (i + 1) + ' of ' + r.n + ': chop when the grain is under the axe.'); }
        if (state === 'sway') {
          var rel = t - start; offNow = offAt(t);
          live.box.style.opacity = '1'; place(live.box, offNow, 0); rope.style.opacity = '1';
          live.box.classList.toggle('near', Math.abs(offNow) <= r.g / 2);
          if (rel > r.wait) { ev.push(-1); tally[i].className = 'gtpip miss'; live.box.classList.add('away'); c.say('That log swung away.'); next(start + r.wait + r.arrive); }
        } else if (state === 'hit' && t - tapT > r.arrive - 100) { next(tapT + r.arrive); }
      },
      act: function () {
        if (c.over() || state !== 'sway') return;
        var t = Math.round(c.now());
        if (t < start + 350 || t > start + r.wait) return;
        strike(t);
      },
      cancel: function () {}
    };
  };

  /* ======== ⛏️ Glint Strike ======== */
  GAMES.glint = function (c) {
    var r = c.r, ev = [], res = {}, gl = [], hits = 0, lastTap = -1e9;
    c.bg('pick-bg.svg');
    var tallyEl = el('div', 'gtally', c.field, ' 0 / ' + r.n); tallyEl.insertBefore(gvIcoNode('ico-gem'), tallyEl.firstChild);
    var pick = c.piece('pick-pick.svg', 'gpiece gpickaxe'); pick.style.display = 'none';
    r.gl.forEach(function (gx, k) {
      var b = el('button', 'ggl k' + gx.k, c.field); b.type = 'button'; b.hidden = true; b.style.left = pct(gx.x); b.style.top = pct(gx.y);
      b.style.width = pct(r.rad * 2.3); b.style.height = pct(r.rad * 2.3);
      b.setAttribute('aria-label', 'Crystal glint ' + (k + 1));
      c.img('pick-glint.svg', 'gglimg', b);
      b.addEventListener('pointerdown', function (e) { e.preventDefault(); e.stopPropagation(); var p = toField(e); tapGlint(k, p[0], p[1]); });
      b.addEventListener('keydown', function (e) { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); e.stopPropagation(); tapGlint(k, gx.x, gx.y); } });
      gl.push({ b: b, state: 0 });
    });
    function toField(e) { var rc = c.field.getBoundingClientRect(); return [100 * (e.clientX - rc.left) / rc.width, 100 * (e.clientY - rc.top) / rc.height]; }
    function swing(x, y) {
      pick.style.display = ''; pick.style.left = pct(x); pick.style.top = pct(y);
      pick.classList.remove('hit'); void pick.offsetWidth; pick.classList.add('hit');
    }
    function liveNow(t) { for (var k = 0; k < r.n; k++) { var g = r.gl[k]; if (!res[k] && t >= g.a && t <= g.a + r.life) return k; } return -1; }
    function tapGlint(k, px, py) {
      if (c.over() || res[k]) return;
      var t = Math.round(c.now()), g = r.gl[k];
      if (t < g.a || t > g.a + r.life || t < lastTap + 60) return;
      if (Math.hypot(px - g.x, py - g.y) > r.rad) { px = g.x; py = g.y; }
      lastTap = t; res[k] = 1; hits++; ev.push([k, t, Math.round(px * 10), Math.round(py * 10)]);
      gl[k].state = 2; gl[k].b.classList.add('struck'); gl[k].b.disabled = true;
      swing(g.x, g.y); c.burst(g.x, g.y, 'shard k' + g.k, 9); c.burst(g.x, g.y, 'spark', 5);
      gvIcoLine(tallyEl, 'ico-gem', ' ' + hits + ' / ' + r.n); c.say(['Ting!', 'Sparkle!', 'Got one!', 'Lovely!'][hits % 4] + ' ' + hits + ' of ' + r.n + '.');
    }
    c.field.addEventListener('pointerdown', function (e) {   // a tap on bare rock: a tink and a spark, no penalty
      if (c.over()) return; var p = toField(e); swing(p[0], p[1]); c.burst(p[0], p[1], 'chip', 3);
    });
    c.say('Tap the glints before they fade!');
    return {
      tick: function (t) {
        r.gl.forEach(function (g, k) {
          var s = gl[k];
          if (s.state === 2) return;
          if (t < g.a) return;
          if (t <= g.a + r.life) {
            if (s.state === 0) { s.state = 1; s.b.hidden = false; s.b.classList.add('pop'); }
            var left = (g.a + r.life - t) / r.life; s.b.style.opacity = String(left < 0.4 ? 0.25 + 0.75 * left / 0.4 : 1);
          } else if (s.state === 1) { s.state = 3; s.b.classList.add('lost'); s.b.disabled = true; setTimeout(function () { s.b.hidden = true; }, 500); }
        });
        if (t > r.dur) c.done(ev, 700);
      },
      act: function () { var k = liveNow(c.now()); if (k >= 0) tapGlint(k, r.gl[k].x, r.gl[k].y); },
      cancel: function () {}
    };
  };

  /* ======== 🦋 Bug Swoop ======== */
  GAMES.flit = function (c) {
    var r = c.r, ev = [], got = {}, bugs = [], down = false, begun = false, ended = false, cur = [50, 80], lastT = -1e9, lastPt = null, nGot = 0, startT = 0, trail = [], len = 0;
    c.bg('net-bg.svg');
    var svg = c.svg('svg', { 'class': 'gsvg', viewBox: '0 0 100 100', preserveAspectRatio: 'none' }, c.field);
    var trailEl = c.svg('path', { 'class': 'gtrail', d: '' }, svg);
    r.bugs.forEach(function (b, i) {
      var im = c.img('net-bug.svg', 'gbug k' + b.k, c.field); im.hidden = true;
      im.style.width = pct(r.rad * 1.35);
      bugs.push({ im: im, lastX: b.x0, lastY: b.y0 });
    });
    var net = c.piece('net-net.svg', 'gpiece gnet'); net.style.left = pct(cur[0]); net.style.top = pct(cur[1]); net.style.width = pct(r.rad * 3.2);
    var tallyEl = el('div', 'gtally', c.field, ' 0 / ' + r.n); tallyEl.insertBefore(gvIcoNode('ico-butterfly'), tallyEl.firstChild);
    function toField(e) {
      var rc = c.field.getBoundingClientRect();
      return [clamp(100 * (e.clientX - rc.left) / rc.width, 0, 100), clamp(100 * (e.clientY - rc.top) / rc.height, 0, 100)];
    }
    function checkSeg(a, b) {   // the same 25 ms steps the server checks
      var t0 = a[2], t1 = b[2];
      for (var t = t0; t <= t1 + 0.001; t += 25) {
        var f = t1 > t0 ? (t - t0) / (t1 - t0) : 1, nx = a[0] + (b[0] - a[0]) * f, ny = a[1] + (b[1] - a[1]) * f;
        for (var k = 0; k < r.n; k++) {
          var bg = r.bugs[k];
          if (got[k] || t < bg.a || t > bg.a + bg.life) continue;
          var p = flitPos(bg, t);
          if (Math.hypot(p[0] - nx, p[1] - ny) <= r.rad) { got[k] = 1; nGot++; bugs[k].im.classList.add('caught'); bugs[k].im.style.left = pct(nx); bugs[k].im.style.top = pct(ny); c.burst(nx, ny, 'puff', 6); gvIcoLine(tallyEl, 'ico-butterfly', ' ' + nGot + ' / ' + r.n); c.say(['Got one!', 'Another!', 'Two at once!', 'Wings everywhere!'][nGot % 4] + ' ' + nGot + ' caught.'); }
        }
      }
    }
    function sample(x, y, force) {
      var t = Math.round(c.now());
      cur = [x, y]; net.style.left = pct(x); net.style.top = pct(y);
      if (!begun || ended) return;
      if (ev.length) { var dt = t - lastT; if (dt < 8 || (!force && dt < 40)) return; }
      var s = [Math.round(x * 10) / 10, Math.round(y * 10) / 10, t];
      ev.push([Math.round(x * 10), Math.round(y * 10), t]);
      checkSeg(lastPt || s, s);
      if (lastPt) { len += Math.hypot(s[0] - lastPt[0], s[1] - lastPt[1]); }
      trail.push(s[0].toFixed(1) + ' ' + s[1].toFixed(1)); trailEl.setAttribute('d', 'M' + trail.join(' L'));
      lastPt = s; lastT = t;
      if (t - startT > 6500) end();
    }
    function begin(x, y) {
      var t = Math.round(c.now());
      if (t < 400) { c.say('Wait for the bugs to show…'); return false; }
      begun = true; startT = t; net.classList.add('swing'); sample(x, y, true); return true;
    }
    function end() {
      if (ended) return;
      if (len < 15) { ev.length = 0; trail.length = 0; trailEl.setAttribute('d', ''); got = {}; nGot = 0; lastPt = null; begun = false; down = false; net.classList.remove('swing'); bugs.forEach(function (b) { b.im.classList.remove('caught'); }); gvIcoLine(tallyEl, 'ico-butterfly', ' 0 / ' + r.n); c.say('One long sweep! Try again.'); return; }
      ended = true; net.classList.remove('swing'); net.classList.add('lift');
      c.say(nGot ? 'Swoosh! ' + nGot + ' in the net.' : 'Swoosh… only air.');
      c.done(ev, 1300);
    }
    c.field.addEventListener('pointerdown', function (e) {
      if (c.over() || ended) return; e.preventDefault();
      try { c.field.setPointerCapture(e.pointerId); } catch (x) {}
      var p = toField(e); down = true; if (!begun) begin(p[0], p[1]); else sample(p[0], p[1], false);
    });
    c.field.addEventListener('pointermove', function (e) {
      var p = toField(e);
      if (down && begun && !ended) sample(p[0], p[1], false);
      else if (!down && !begun && e.pointerType === 'mouse') { cur = p; net.style.left = pct(p[0]); net.style.top = pct(p[1]); }
    });
    function up() { if (!down) return; down = false; if (begun && !ended) { sample(cur[0], cur[1], true); end(); } }
    c.field.addEventListener('pointerup', up); c.field.addEventListener('pointercancel', up);
    c.key(function (e) {
      var s = 2, m = { ArrowLeft: [-s, 0], ArrowRight: [s, 0], ArrowUp: [0, -s], ArrowDown: [0, s] }[e.key];
      if (!m) return false;
      var x = clamp(cur[0] + m[0], 0, 100), y = clamp(cur[1] + m[1], 0, 100);
      if (!begun) { if (!begin(cur[0], cur[1])) return true; }
      sample(x, y, false); return true;
    });
    c.say('One swipe through the wings. Plan your path!');
    return {
      tick: function (t) {
        bugs.forEach(function (g, i) {
          var b = r.bugs[i], on = t >= b.a && t <= b.a + b.life && !got[i];
          if (got[i]) return;
          g.im.hidden = !on;
          if (on) {
            var p = flitPos(b, t), q = flitPos(b, t + 40), ang = Math.atan2(q[1] - p[1], q[0] - p[0]) * 57.3 + 90;
            g.im.style.left = pct(p[0]); g.im.style.top = pct(p[1]); g.im.style.transform = 'translate(-50%,-50%) rotate(' + ang.toFixed(0) + 'deg)';
          }
        });
        if (down && begun && !ended && t - lastT > 1200) sample(cur[0], cur[1], true);
        if (t > r.dur && !ended) { if (!begun) { ended = true; c.done(ev, 500); } else end(); }
      },
      act: function () { if (begun && !ended) end(); },
      cancel: function () {}
    };
  };

  /* ======== 🪣 Drip Catch ======== */
  GAMES.drip = function (c) {
    var r = c.r, ev = [], bx = 50, target = 50, last = null, lastRec = -1e9, keyDir = 0, caught = 0, spills = 0, lastSpill = -1e9, evalI = 0, drops = [], water = 0, tprev = 0, speedShown = 0, down = false;
    var Y_TIP = 15, Y_RIM = 69;
    c.bg('calm-bg.svg');
    r.sx.forEach(function (x) { var st = c.img('calm-stalac.svg', 'gstalac', c.field); st.style.left = pct(x); });
    var tallyEl = el('div', 'gtally', c.field, ' 0'); tallyEl.insertBefore(gvIcoNode('ico-droplet'), tallyEl.firstChild);
    r.dr.forEach(function (d, i) {
      var im = c.img('calm-drop.svg', 'gdrop', c.field); im.hidden = true; im.style.left = pct(r.sx[d.s]);
      drops.push({ im: im, state: 0 });
    });
    var bk = el('div', 'gbk', c.field); bk.style.width = pct(r.bw * 2 + 8); bk.style.top = pct(Y_RIM);
    c.img('calm-bucket-back.svg', 'gbkimg back', bk);
    var wat = el('div', 'gbkwater', bk), surf = el('span', 'gbksurf', wat);
    c.img('calm-bucket-front.svg', 'gbkimg front', bk);
    function setBx(x) { bk.style.left = pct(x); }
    setBx(bx);
    function rec(t) {
      var rt = Math.round(t);
      if (last !== null && rt - last[1] < 8) return;
      last = [Math.round(bx * 10) / 10, rt]; ev.push([Math.round(bx * 10), rt]);
      if (ev.length > 1) {   // spills, by the segment's speed (same rule as the server)
        var a = ev[ev.length - 2], dt = rt - a[1];
        if (dt >= 30 && Math.abs(Math.round(bx * 10) - a[0]) / 10 / dt > r.vs && rt >= lastSpill + 500) { lastSpill = rt; spills++; water = Math.max(0, water - 1); splash(bx, Y_RIM - 3, 'spill'); c.say('Careful, it sloshed! Move gently.'); upd(); }
      }
      lastRec = rt;
      // drops that have landed: where was the bucket then?
      while (evalI < r.n && ev[ev.length - 1][1] >= r.dr[evalI].a + r.fd) {
        var tl = r.dr[evalI].a + r.fd, bxl = at(tl);
        if (Math.abs(bxl - r.sx[r.dr[evalI].s]) <= r.bw) { caught++; water++; drops[evalI].state = 2; splash(r.sx[r.dr[evalI].s], Y_RIM, 'catch'); c.say('Plink! ' + caught + ' caught.'); } else { drops[evalI].state = 3; splash(r.sx[r.dr[evalI].s], 88, 'miss'); }
        upd(); evalI++;
      }
    }
    function at(t) {
      for (var j = 1; j < ev.length; j++) if (ev[j][1] >= t) { var d = ev[j][1] - ev[j - 1][1]; return (ev[j - 1][0] + (ev[j][0] - ev[j - 1][0]) * (d > 0 ? (t - ev[j - 1][1]) / d : 1)) / 10; }
      return ev[ev.length - 1][0] / 10;
    }
    function upd() { gvIcoLine(tallyEl, 'ico-droplet', ' ' + Math.max(0, caught - spills)); wat.style.height = pct(clamp(12 + 6.5 * water, 12, 68)); }
    function splash(x, y, kind) {
      if (kind === 'catch') { bk.classList.remove('plink'); void bk.offsetWidth; bk.classList.add('plink'); c.burst(x, y - 2, 'drop', 5); }
      else if (kind === 'spill') c.burst(x + (Math.random() < .5 ? -1 : 1) * r.bw * 0.7, y - 2, 'drop big', 7);
      else c.burst(x, y, 'drop low', 3);
    }
    function toX(e) { var rc = c.field.getBoundingClientRect(); return clamp(100 * (e.clientX - rc.left) / rc.width, r.bw * 0.4, 100 - r.bw * 0.4); }
    c.field.addEventListener('pointerdown', function (e) { if (c.over()) return; e.preventDefault(); down = true; try { c.field.setPointerCapture(e.pointerId); } catch (x) {} target = toX(e); });
    c.field.addEventListener('pointermove', function (e) { if (c.over()) return; if (down || e.pointerType === 'mouse') target = toX(e); });
    function up() { down = false; }
    c.field.addEventListener('pointerup', up); c.field.addEventListener('pointercancel', up);
    document.addEventListener('keyup', kup, true);
    function kup(e) { if (e.key === 'ArrowLeft' && keyDir < 0) keyDir = 0; if (e.key === 'ArrowRight' && keyDir > 0) keyDir = 0; }
    c.key(function (e) { if (e.key === 'ArrowLeft') { keyDir = -1; return true; } if (e.key === 'ArrowRight') { keyDir = 1; return true; } return false; });
    c.noAct();
    c.say('Slide the bucket under the drips. Gently!');
    return {
      tick: function (t) {
        var dt = Math.min(50, Math.max(0, t - tprev)); tprev = t;
        if (keyDir) target = clamp(target + keyDir * 0.05 * dt, 0, 100);
        var want = clamp((target - bx) * Math.min(1, dt * 0.012), -r.vmax * 0.9 * dt, r.vmax * 0.9 * dt);
        if (!c.over()) bx = clamp(bx + want, 0, 100);
        setBx(bx);
        var spd = dt > 0 ? Math.abs(want) / dt : 0; speedShown += (spd - speedShown) * 0.2;
        bk.style.setProperty('--tilt', clamp((c.rm ? 0 : (want / Math.max(1, dt)) * 90), -9, 9).toFixed(1) + 'deg');
        bk.classList.toggle('slosh', speedShown > r.vs * 0.8);
        if (!c.over() && (last === null || t - lastRec >= 100) && t <= r.dur) rec(t);
        else if (!c.over() && evalI < r.n && t >= r.dr[evalI].a + r.fd && t - lastRec >= 12 && t <= r.dur) rec(t);
        // the drops
        r.dr.forEach(function (d, i) {
          var s = drops[i], u = (t - d.a) / r.fd;
          if (s.state >= 2) { if (u > 1.0 && s.state === 3 && u < 1.25) { s.im.style.top = pct(Y_RIM + (88 - Y_RIM) * ((u - 1) / 0.25)); } else s.im.hidden = true; return; }
          if (u < -0.5) return;
          s.im.hidden = false;
          if (u < 0) { s.im.style.top = pct(Y_TIP); s.im.style.transform = 'translate(-50%,-50%) scale(' + (0.4 + 0.6 * (1 + u * 2)).toFixed(2) + ')'; }
          else { s.im.style.top = pct(Y_TIP + (Y_RIM - Y_TIP) * u * u); s.im.style.transform = 'translate(-50%,-50%) scale(1,' + (1 + 0.35 * u).toFixed(2) + ')'; }
        });
        if (t > r.dur && !c.over()) { document.removeEventListener('keyup', kup, true); c.say(caught - spills >= 11 ? 'A full bucket! Not a slosh.' : 'The bucket is ' + Math.max(0, caught - spills) + ' drops full.'); c.done(ev, 800); }
      },
      act: function () {},
      cancel: function () { document.removeEventListener('keyup', kup, true); }
    };
  };

  /* ======== still round (reduced motion): tap when it says NOW ======== */
  GAMES.cue = function (c) {
    var r = c.r, ev = [], fin = false;
    c.bg('calm-pool.svg');
    var shell = c.piece('calm-shell.svg', 'gpiece gshell');
    var rings = [c.piece('calm-ripple.svg', 'gpiece gring'), c.piece('calm-ripple.svg', 'gpiece gring g2')];
    var big = el('div', 'gcue', c.field, '');
    c.field.addEventListener('pointerdown', function (e) { e.preventDefault(); GAMEACT(); });
    var lastTxt = '';
    function GAMEACT() {
      var now = c.now();
      if (fin || c.over()) return;
      if (now < 1200) { c.say('Too soon, wait…'); return; }
      fin = true; ev.push(Math.round(now)); c.done(ev, 650);
    }
    c.say('Wait for NOW…');
    return {
      tick: function (t) {
        var calm = t >= r.T && t <= r.T + r.W;
        rings.forEach(function (g) { g.style.opacity = calm ? '0' : '1'; });
        shell.style.opacity = calm ? '1' : '0.3';
        var txt = calm ? 'NOW!' : 'Wait…';
        if (txt !== lastTxt) { lastTxt = txt; big.textContent = txt; big.classList.toggle('now', calm); if (calm) c.say('NOW! Tap!'); }
        if (t > r.dur && !fin) { fin = true; c.done(ev, 650); }
      },
      act: GAMEACT, cancel: function () {}
    };
  };

  /* ---- panel ---- */
  function setup(fold) {
    if (fold.getAttribute('data-ready')) return;
    fold.setAttribute('data-ready', '1');
    var practice = fold.getAttribute('data-practice') === '1';
    var form = fold.querySelector('form'), stage = fold.querySelector('.gstage');
    if (!stage || (!form && !practice)) return;
    var intro = stage.querySelector('.gintro'), play = stage.querySelector('.gplay'), field = play.querySelector('.gfield'),
        timebar = play.querySelector('.gtime'), say = play.querySelector('.gsay'), actBtn = play.querySelector('.gact'), pad = play.querySelector('.gpad'),
        startBtn = intro.querySelector('.mgstart'), how = intro.querySelector('.mghow'), resBox = stage.querySelector('.gres');
    var base = fold.getAttribute('data-img') || '', roundUrl = fold.getAttribute('data-round'), csrf = fold.getAttribute('data-csrf');
    var chip = fold.querySelector('.mgtool.on') || fold.querySelector('.mgtool');
    var session = null;

    function choose(c2) {
      stop();
      chip = c2;
      fold.querySelectorAll('.mgtool').forEach(function (x) { x.classList.toggle('on', x === c2); x.setAttribute('aria-pressed', x === c2 ? 'true' : 'false'); });
      if (form) form.querySelector('input[name=tool]').value = c2.getAttribute('data-tool');
      how.textContent = c2.getAttribute('data-how');
      actBtn.textContent = c2.getAttribute('data-word');
      if (resBox) resBox.hidden = true;
      stage.classList.remove('hasres');
    }
    function stop() {
      if (session) {
        session.fin = true; cancelAnimationFrame(session.raf);
        document.removeEventListener('keydown', session.kd, true);
        if (session.g && session.g.cancel) session.g.cancel();
        session = null;
      }
      play.hidden = true; intro.hidden = false; field.textContent = ''; pad.textContent = ''; startBtn.disabled = false; actBtn.hidden = false;
    }
    function begin() {
      startBtn.disabled = true;
      var body = new URLSearchParams();
      body.set('csrf', csrf); body.set('do', 'round'); body.set('tool', chip.getAttribute('data-tool')); body.set('rm', rmq.matches ? '1' : '0');
      if (practice) body.set('practice', '1');
      if (resBox) resBox.hidden = true;
      fetch(roundUrl, { method: 'POST', body: body, credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } })
        .then(function (r) { return r.json(); })
        .then(function (round) {
          if (!round || round.error || !GAMES[round.type]) { startBtn.disabled = false; how.textContent = (round && round.error) || 'Couldn’t start.' + (practice ? '' : ' Quick gather still works.'); return; }
          run(round);
        })
        .catch(function () { startBtn.disabled = false; how.textContent = 'Couldn’t start.' + (practice ? '' : ' Quick gather still works.'); });
    }
    function showResult(round, events) {
      var body = new URLSearchParams();
      body.set('csrf', csrf); body.set('do', 'practice'); body.set('tool', round.tool); body.set('gtok', round.tok); body.set('gev', JSON.stringify(events));
      fetch(roundUrl, { method: 'POST', body: body, credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } })
        .then(function (r) { return r.json(); })
        .then(function (j) { paintResult(j.res || '', j.text || ''); })
        .catch(function () { paintResult('', 'Couldn’t check that round.'); });
    }
    function paintResult(res, text) {
      play.hidden = true; intro.hidden = true; resBox.hidden = false; resBox.textContent = '';
      var box = el('div', 'gresbox ' + (res || 'none'), resBox);
      el('b', 'grestitle', box, res === 'perfect' ? '🟩 Great play!' : res === 'good' ? '🟨 Good play' : res === 'miss' ? '⬜ A miss' : '❔ Not counted');
      el('p', '', box, text);
      var chips = el('div', 'gmchips', box); el('span', 'gmchip', chips, 'Practice — no finds');
      var again = el('button', 'btn mgagain', box, '▶ Play again'); again.type = 'button';
      again.addEventListener('click', function () { resBox.hidden = true; stop(); intro.hidden = false; begin(); });
      var back = el('button', 'btn ghost small', box, 'Pick another game'); back.type = 'button';
      back.addEventListener('click', function () { resBox.hidden = true; stop(); });
      try { again.focus({ preventScroll: true }); } catch (x) {}
    }
    function run(round) {
      var nf = document.createElement('div');   // a fresh field each round, so no old listeners stay behind
      play.replaceChild(nf, field); field = nf; field.className = 'gfield gt-' + round.type;
      pad.textContent = '';
      intro.hidden = true; play.hidden = false; timebar.style.width = '0%';
      actBtn.textContent = round.word; actBtn.hidden = false;
      var timed = !(round.type === 'lure' || round.type === 'trace' || round.type === 'chop');   // those end when you finish, not on a clock
      play.classList.toggle('notime', !timed);
      var s = session = { fin: false, raf: 0, t0: performance.now(), g: null, keys: [], finAt: 0, submitted: false };
      var ctx = {
        r: round, field: field, pad: pad, rm: rmq.matches,
        img: function (name, cls, parent) { var i = document.createElement('img'); i.src = base + name + (fold.getAttribute('data-v') ? '?v=' + fold.getAttribute('data-v') : '');   /* v1.5.1: fresh art after an update */ i.alt = ''; i.draggable = false; i.className = cls || ''; (parent || field).appendChild(i); return i; },
        bg: function (name) { ctx.img(name, 'gbg'); },
        piece: function (name, cls) { return ctx.img(name, cls); },
        svg: function (tag, attrs, parent) { var n = document.createElementNS(SVGNS, tag); for (var k in attrs) n.setAttribute(k, attrs[k]); (parent || field).appendChild(n); return n; },
        now: function () { return performance.now() - s.t0; },
        say: function (t) { say.textContent = t; },
        key: function (fn) { s.keys.push(fn); },
        over: function () { return s.fin; },
        noAct: function () { actBtn.hidden = true; },
        burst: function (x, y, cls, n) {
          if (rmq.matches) n = Math.min(n, 2);
          for (var i = 0; i < n; i++) {
            var p = el('span', 'gbit ' + cls, field), a = Math.random() * Math.PI * 2, d = 6 + Math.random() * 12;
            p.style.left = pct(x); p.style.top = pct(y);
            p.style.setProperty('--dx', (Math.cos(a) * d * 3).toFixed(0) + 'px'); p.style.setProperty('--dy', (Math.sin(a) * d * 3 - 14).toFixed(0) + 'px');
            p.style.setProperty('--sz', (5 + Math.random() * 6).toFixed(1) + 'px');
            setTimeout(function (q) { return function () { if (q.parentNode) q.parentNode.removeChild(q); }; }(p), 900);
          }
        },
        done: function (events, delay) {
          if (s.fin) return; s.fin = true;
          document.removeEventListener('keydown', s.kd, true);
          s.finAt = performance.now() + (delay == null ? 650 : delay); s.events = events;
        }
      };
      function submit() {
        if (s.submitted) return; s.submitted = true;
        cancelAnimationFrame(s.raf);
        say.textContent = practice ? 'Checking…' : 'Collecting…'; actBtn.disabled = true;
        if (practice) { showResult(round, s.events); return; }
        form.querySelector('input[name=gtok]').value = round.tok;
        form.querySelector('input[name=gev]').value = JSON.stringify(s.events);
        if (form.requestSubmit) form.requestSubmit(); else form.submit();
      }
      s.g = GAMES[round.type](ctx);
      s.kd = function (e) {
        if (s.fin) return;
        if (e.key === 'Escape') { e.preventDefault(); stop(); return; }
        for (var i = 0; i < s.keys.length; i++) if (s.keys[i](e)) { e.preventDefault(); return; }
        if (e.key === ' ' || e.key === 'Enter') {
          if (e.target && e.target.closest && e.target.closest('.gpt, .ggl, .glbtn, .mgtool, .mgstart')) return;   // those handle their own keys
          e.preventDefault(); if (e.repeat) return;
          s.g.act();
        }
      };
      document.addEventListener('keydown', s.kd, true);
      actBtn.disabled = false;
      actBtn.onpointerdown = function (e) { e.preventDefault(); if (!s.fin) s.g.act(); };
      actBtn.onclick = function (e) { e.preventDefault(); };
      s.t0 = performance.now();
      (function loop() {
        if (s.submitted || session !== s) return;
        var now = performance.now(), t = now - s.t0;
        s.g.tick(t);
        if (timed) timebar.style.width = pct(Math.min(100, 100 * t / round.dur));
        if (s.fin && now >= s.finAt) { submit(); return; }
        s.raf = requestAnimationFrame(loop);
      })();
      try { if (!actBtn.hidden) actBtn.focus({ preventScroll: true }); } catch (x) {}
    }

    fold.querySelectorAll('.mgtool').forEach(function (c2) { c2.addEventListener('click', function () { choose(c2); }); });
    startBtn.addEventListener('click', begin);
    if (fold.tagName === 'DETAILS') fold.addEventListener('toggle', function () { if (!fold.open) stop(); });
    if (form) form.addEventListener('submit', function (ev) { if (session && !session.submitted) ev.preventDefault(); });   // no Quick gather mid-game by accident
    if (chip) choose(chip);
  }

  window.gvGather = function () { document.querySelectorAll('.mgfold').forEach(setup); };
  window.gvGather();
})();
