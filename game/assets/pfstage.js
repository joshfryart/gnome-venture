/* pfight_stage (setting, default Off): the Trail's puzzle fight takes over the map's place.
   What this script does, and only when the dialog has the class .pfst (includes/adventure.php adds it when the setting is on):
   - puts the fight dialog on the map column's box (assets/pfstage.css reads --pfx --pfy --pfw --pfh set here),
   - plays a jigsaw cover over the swap when a fight starts and when it ends (End match, Run), then lets the fight show (.pfst-on),
   - never blocks the game: any failure, reduced motion, or no Popover API means the fight is just shown.
   It does not touch the fight's own script (pfboardv1.js), the server or the in-place swap; site.js only keeps .pfst-on across turns (keepTrailPop). */
(function () {
  'use strict';
  var me = document.currentScript, ART = '';
  try { ART = new URL('img/pfight/', me && me.src ? me.src : location.href).href; } catch (e) {}
  var reduce = window.matchMedia ? matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var canCover = typeof HTMLElement !== 'undefined' && 'showPopover' in HTMLElement.prototype && !!Element.prototype.animate;
  var NS = 'http://www.w3.org/2000/svg';
  var seenNoFight = false;   // the page had no fight before: only then does a fight that shows up get the cover (a reload with a fight open just shows it)
  var wasFight = false, closing = false, entering = false, coverUp = false, cover = null, pieces = null, token = 0;

  function dlg() { return document.querySelector('dialog.trailpop.pfst'); }
  var lastBox = null;   // the map column's box from when the page showed the map: during a fight the column can be restyled (the fight's own stylesheet may not be loaded yet), this is the place the fight takes over
  function curBox() {
    var m = document.querySelector('.advgrid .mapcol'); if (!m) return null;
    var r = m.getBoundingClientRect(); if (r.width < 40 || r.height < 40) return null;
    var w = Math.min(r.width, 760);
    return { x: r.left + window.pageXOffset + (r.width - w) / 2, y: r.top + window.pageYOffset, w: w, h: r.height };
  }
  function box() { return curBox() || lastBox; }
  function setBox(el, b) {
    el.style.setProperty('--pfx', b.x + 'px'); el.style.setProperty('--pfy', b.y + 'px'); el.style.setProperty('--pfw', b.w + 'px'); el.style.setProperty('--pfh', b.h + 'px');
  }
  function place(d) { var b = box(); if (b) setBox(d, b); return b; }
  function sleep(ms) { return new Promise(function (r) { setTimeout(r, ms); }); }

  /* ---- the jigsaw cover (same pieces as the approved mockup A) ---- */
  function jig(W, H, cols, rows) {
    var w = W / cols, h = H / rows, m = Math.round(0.3 * Math.max(w, h)), R = [], B = [], i, r, c;
    var r2 = function () { return Math.random() < 0.5 ? 1 : -1; };
    for (r = 0; r < rows; r++) for (c = 0; c < cols; c++) { R[r * cols + c] = c < cols - 1 ? r2() : 0; B[r * cols + c] = r < rows - 1 ? r2() : 0; }
    var seg = [[0.38, 0], [[0.38, 0.06], [0.30, 0.07], [0.30, 0.14]], [[0.30, 0.24], [0.40, 0.27], [0.5, 0.27]], [[0.6, 0.27], [0.7, 0.24], [0.7, 0.14]], [[0.7, 0.07], [0.62, 0.06], [0.62, 0]], [1, 0]];
    function edge(p0, p1, s) {
      if (!s) return 'L' + p1[0] + ' ' + p1[1] + ' ';
      var dx = p1[0] - p0[0], dy = p1[1] - p0[1], L = Math.hypot(dx, dy), d = [dx / L, dy / L], n = [d[1], -d[0]];
      var P = function (u, v) { return (p0[0] + d[0] * L * u + n[0] * L * v * s).toFixed(1) + ' ' + (p0[1] + d[1] * L * u + n[1] * L * v * s).toFixed(1); };
      var o = 'L' + P(0.38, 0) + ' ';
      for (var k = 1; k < 5; k++) { var q = seg[k]; o += 'C' + P(q[0][0], q[0][1]) + ' ' + P(q[1][0], q[1][1]) + ' ' + P(q[2][0], q[2][1]) + ' '; }
      return o + 'L' + P(1, 0) + ' ';
    }
    var tones = ['#4a3322', '#553b29', '#5d4330'], icons = ['hurt', 'guard', 'heal', 'charm', 'trick'], out = [];
    for (r = 0; r < rows; r++) for (c = 0; c < cols; c++) {
      var top = r > 0 ? -B[(r - 1) * cols + c] : 0, right = R[r * cols + c], bottom = B[r * cols + c], left = c > 0 ? -R[r * cols + c - 1] : 0;
      var a = [m, m], b = [m + w, m], cc = [m + w, m + h], d = [m, m + h];
      var path = 'M' + a[0] + ' ' + a[1] + ' ' + edge(a, b, top) + edge(b, cc, right) + edge(cc, d, bottom) + edge(d, a, left) + 'Z';
      var svg = document.createElementNS(NS, 'svg'), cx = m + w / 2, cy = m + h / 2;
      svg.setAttribute('width', w + 2 * m); svg.setAttribute('height', h + 2 * m); svg.setAttribute('viewBox', '0 0 ' + (w + 2 * m) + ' ' + (h + 2 * m));
      svg.style.left = (c * w - m) + 'px'; svg.style.top = (r * h - m) + 'px';
      svg.innerHTML = '<path d="' + path + '" fill="' + tones[(c + r * 2) % 3] + '" stroke="#2a1a10" stroke-width="2.5" stroke-linejoin="round"/>'
        + '<path d="' + path + '" fill="none" stroke="#e8a317" stroke-width="1.5" stroke-dasharray="4 3" opacity=".75" transform="translate(' + cx + ' ' + cy + ') scale(.82) translate(' + (-cx) + ' ' + (-cy) + ')"/>'
        + (ART ? '<image href="' + ART + 'ico-' + icons[(c * 3 + r) % 5] + '.png" x="' + (cx - 14) + '" y="' + (cy - 14) + '" width="28" height="28" opacity=".55" image-rendering="pixelated"/>' : '');
      var vx = (c + 0.5) / cols - 0.5, vy = (r + 0.5) / rows - 0.5, n = Math.hypot(vx, vy) || 1;
      out.push({ svg: svg, c: c, r: r, vx: vx / n, vy: vy / n });
    }
    return out;
  }
  function mkCover(b) {
    dropCover();
    cover = document.createElement('div'); cover.className = 'pfst-cover'; cover.setAttribute('popover', 'manual'); cover.setAttribute('aria-hidden', 'true');
    setBox(cover, b);
    var cols = Math.max(3, Math.round(b.w / 72)), rows = Math.max(3, Math.round(b.h / 72));
    pieces = jig(b.w, b.h, cols, rows);
    pieces.forEach(function (p) { cover.appendChild(p.svg); });
    document.body.appendChild(cover);
    cover.showPopover();   // after the modal dialog: above it in the top layer
  }
  function dropCover() { if (cover) { try { cover.hidePopover(); } catch (e) {} if (cover.parentNode) cover.parentNode.removeChild(cover); } cover = null; pieces = null; coverUp = false; }
  function fly(inward, b) {
    var far = (b.w + b.h) * 0.5;
    var anims = pieces.map(function (p) {
      var dist = far * 0.5 + Math.random() * 120, off = 'translate(' + (p.vx * dist) + 'px,' + (p.vy * dist) + 'px) rotate(' + (Math.random() * 100 - 50) + 'deg) scale(.7)';
      var kf = inward ? [{ transform: off, opacity: 0 }, { opacity: 1, offset: 0.3 }, { transform: 'none', opacity: 1 }] : [{ transform: 'none', opacity: 1 }, { transform: off, opacity: 0 }];
      return p.svg.animate(kf, { duration: inward ? 430 : 420, delay: (p.c + p.r) * (inward ? 42 : 38), easing: inward ? 'cubic-bezier(.3,1.3,.5,1)' : 'cubic-bezier(.6,0,.9,.5)', fill: 'both' });
    });
    return Promise.all(anims.map(function (a) { return a.finished; }));
  }
  function coverIn(b) { mkCover(b); return fly(true, b).then(function () { coverUp = true; }); }
  function coverOut(b) { return fly(false, b).then(dropCover, dropCover); }
  function usable() { return canCover && !reduce.matches && !!box(); }

  /* ---- reveal: the fight shows (always), with or without the cover ---- */
  function reveal(d) { d.classList.add('pfst-on'); }
  function enter(d) {
    var t = ++token, b = place(d);
    if (!seenNoFight || !usable() || !b) { reveal(d); return; }
    entering = true;
    coverIn(b).then(function () {
      if (t !== token) return;   // a newer change took over
      var d2 = dlg(); if (d2) { place(d2); reveal(d2); }
      entering = false;
      return sleep(120).then(function () { return coverOut(b); });
    }).catch(function () { entering = false; dropCover(); var d3 = dlg(); if (d3) reveal(d3); });
  }

  /* ---- what changed? (called synchronously from a MutationObserver, so a replaced dialog never paints un-revealed) ---- */
  function check() {
    var d = dlg();
    if (d) {
      if (!d.classList.contains('pfst-on')) {
        if (entering) { /* the cover is still coming in: enter() reveals it */ }
        else if (wasFight || closing) { place(d); reveal(d); }   // a pre-fight screen turning into the board, or a turn that replaced the dialog: no cover
        else enter(d);
      } else if (!coverUp) place(d);
    } else {
      seenNoFight = true; var nb = curBox(); if (nb) lastBox = nb;
      if (wasFight && closing) {   // the swap removed the fight: when the cover is already whole it leaves now, else the click handler's coverIn finishes this
        if (coverUp && cover) { var b = box(); closing = false; if (b) { setBox(cover, b); coverOut(b); } else dropCover(); }
      } else if (wasFight) { entering = false; dropCover(); }
    }
    wasFight = !!d;
  }
  if (window.MutationObserver) {
    var mo = new MutationObserver(function () { try { check(); } catch (e) { var d = dlg(); if (d) reveal(d); } });
    mo.observe(document.body, { childList: true, subtree: true });
  }
  document.addEventListener('gv:swapped', function () { try { check(); } catch (e) {} });
  window.addEventListener('resize', function () { var d = dlg(); if (d) place(d); else { var nb = curBox(); if (nb) lastBox = nb; } });
  window.addEventListener('pageshow', function () { var d = dlg(); if (d) { place(d); reveal(d); } });

  /* ---- the way out: End match / Run post a form; cover the fight at once, the swap that follows removes the dialog, then the cover leaves ---- */
  document.addEventListener('click', function (ev) {
    var btn = ev.target && ev.target.closest ? ev.target.closest('button, input[type=submit]') : null;
    if (!btn || !btn.form || !dlg() || !usable() || closing) return;
    var doo = btn.form.querySelector('input[name=do]'), v = doo ? doo.value : '';
    if (v !== 'pf_finish' && v !== 'pf_run') return;
    var b = box(); if (!b) return;
    closing = true; var t = ++token;
    coverIn(b).then(function () { if (t === token && !dlg() && closing) { closing = false; coverOut(b); } }, function () { closing = false; dropCover(); });
    setTimeout(function () { if (closing && t === token) { closing = false; dropCover(); } }, 6000);   // the swap never came (an error shows its own message)
  }, true);

  seenNoFight = !dlg(); if (seenNoFight) lastBox = curBox();
  wasFight = !!dlg();
  var d0 = dlg(); if (d0) { place(d0); reveal(d0); }
})();
