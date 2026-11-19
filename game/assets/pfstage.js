/* pfight_stage (setting, default Off): the Trail's puzzle fight takes over the map's place.
   Only acts on a dialog with the class .pfst (adventure.php adds it when the setting is on). What it does:
   - puts the dialog on the map column's box (assets/pfstage.css reads --pfx --pfy --pfw --pfh set here),
   - a fight that starts: jigsaw pieces fly in over the map FIRST, then the pre-fight card (creature, deck) shows on top of them; the pieces STAY until the player
     taps Let's fight; then a second set of pieces flies in over the card, the combat section is swapped in underneath, and they leave to show it,
   - a result card (a fight that was run from) is shown over the map in the same place, and its button sends the pieces away,
   - End match covers the swap that removes the fight with the pieces and they leave over the map.
   It never blocks the game: any failure, reduced motion, or no Element.animate means the card is just shown. It does not touch the fight's own script (pfboardv1.js),
   the server or the in-place swap; site.js only keeps .pfst-on across turns (keepTrailPop). */
(function () {
  'use strict';
  var me = document.currentScript, ART = '';
  try { ART = new URL('img/pfight/', me && me.src ? me.src : location.href).href; } catch (e) {}
  var reduce = window.matchMedia ? matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var canAnim = typeof Element !== 'undefined' && !!Element.prototype.animate;
  var canPop = canAnim && typeof HTMLElement !== 'undefined' && 'showPopover' in HTMLElement.prototype;
  var NS = 'http://www.w3.org/2000/svg', KEY = 'pfstSeen';
  var seenNoFight = false;   // the page had no fight before: only then does a fight that shows up get the jigsaw
  var wasD = false, entering = false, held = false, dismissing = false, closing = false, coverUp = false, token = 0;
  var layer = null, pieces = null, ghost = null, ghostTimer = 0, cover = null, cpieces = null, lastBox = null;
  var top = null, tpieces = null, topIn = null, topReady = false, accepting = false, closeBox = null;   // Let's fight: the second set of pieces, over the card

  function dlg() { return document.querySelector('dialog.trailpop.pfst'); }
  function kindOf(d) {
    if (d.querySelector('#pfv-pre')) return 'pre';
    if (d.querySelector('.pfst-res')) return 'res';
    return d.querySelector('#pfight') ? 'fight' : 'other';
  }
  function seen(v) { try { if (v === undefined) return sessionStorage.getItem(KEY) === '1'; if (v) sessionStorage.setItem(KEY, '1'); else sessionStorage.removeItem(KEY); } catch (e) {} return false; }
  /* the tile map's box (the map column's, when there is no tile map). A column can be display: contents (a phone): then it is the box of its children. */
  function curBox() {
    var m = document.querySelector('.advgrid .tmwrap') || document.querySelector('.wanderbehind .tmwrap') || document.querySelector('.advgrid .mapcol'); if (!m) return null;   // a fight met off the Trail: the map is the wander page's one behind the card (.wanderbehind), the .mapcol of the hidden old page is only a sliver   // the tile map itself: what the fight takes over
    var r = m.getBoundingClientRect(), l, t, w, h;
    if (r.width >= 40 && r.height >= 40) { l = r.left; t = r.top; w = r.width; h = r.height; }
    else {
      var x0 = 1e9, y0 = 1e9, x1 = -1e9, y1 = -1e9, n = 0;
      Array.prototype.forEach.call(m.children, function (k) { if (k.tagName === 'DIALOG') return; var q = k.getBoundingClientRect(); if (q.width < 20 || q.height < 8) return; x0 = Math.min(x0, q.left); y0 = Math.min(y0, q.top); x1 = Math.max(x1, q.right); y1 = Math.max(y1, q.bottom); n++; });
      if (!n) return null; l = x0; t = y0; w = x1 - x0; h = y1 - y0;
      if (w < 40 || h < 40) return null;
    }
    var cw = Math.min(w, 760);
    return { x: l + window.pageXOffset + (w - cw) / 2, y: t + window.pageYOffset, w: cw, h: h };
  }
  function box() { var b = curBox(); if (b) lastBox = b; return b || lastBox; }   // where the tile map is NOW (the page lays out differently while a fight is on); the last box seen only when it cannot be measured
  /* the combat needs the visible window, not just the map's height: the same room the game gives it (pfv1box.js): the whole window on a phone, between the header and the bottom bar on a wide screen. Fixed to the window, so it cannot scroll away. */
  function visBox() {
    var iw = window.innerWidth, ih = window.innerHeight, top = 0, bot = 0;
    if (iw >= 700) {
      var hd = document.querySelector('.bannerin'), bb = document.querySelector('.bottombar');
      if (hd) top = Math.max(0, Math.round(hd.getBoundingClientRect().bottom));
      if (bb && getComputedStyle(bb).display !== 'none' && getComputedStyle(bb).position === 'fixed') bot = Math.max(0, Math.round(ih - bb.getBoundingClientRect().top));
      if (top > ih * 0.4) top = 0;
    }
    var w = Math.min(iw, 560), x = (iw - w) / 2;
    if (iw >= 700) {   // wide screen: stay in line with the map (its column), not centred on the window; height is still the visible window
      var mb = curBox();
      if (mb) { var mw = Math.min(iw, Math.max(mb.w, 480)), mc = mb.x - window.pageXOffset + mb.w / 2; w = mw; x = Math.max(0, Math.min(iw - w, mc - w / 2)); }
    }
    return { x: x, y: top, w: w, h: Math.max(320, ih - top - bot), fixed: true };
  }
  function fixedKind(d) { return !!d && (accepting || kindOf(d) === 'fight'); }
  function boxFor(d) { return fixedKind(d) ? visBox() : box(); }
  function docBox(b) { return b && b.fixed ? { x: b.x + window.pageXOffset, y: b.y + window.pageYOffset, w: b.w, h: b.h } : b; }
  function setBox(el, b) { el.style.setProperty('--pfx', b.x + 'px'); el.style.setProperty('--pfy', b.y + 'px'); el.style.setProperty('--pfw', b.w + 'px'); el.style.setProperty('--pfh', b.h + 'px'); }
  function place(d) { var b = boxFor(d); if (b) { setBox(d, b); d.classList.toggle('pfst-fixed', !!b.fixed); } return b; }
  /* follow the map for as long as a dialog exists: late stylesheets, images, the route box fade or a toast above the map all move it after the first measurement */
  var follow = 0;
  function startFollow() {
    if (follow) return; var last = '';
    (function tick() {
      var d = dlg(); if (!d) { follow = 0; return; }
      var m = curBox(); if (m) lastBox = m;
      var b = boxFor(d); if (b) { var k = [b.x, b.y, b.w, b.h, b.fixed ? 1 : 0].map(Math.round).join(); if (k !== last) { last = k; setBox(d, b); d.classList.toggle('pfst-fixed', !!b.fixed); } }
      follow = requestAnimationFrame(tick);
    })();
  }
  function sleep(ms) { return new Promise(function (r) { setTimeout(r, ms); }); }
  function usable() { return canAnim && !reduce.matches && !!box(); }

  /* ---- jigsaw pieces ---- */
  function jig(W, H, cols, rows) {
    var w = W / cols, h = H / rows, m = Math.round(0.3 * Math.max(w, h)), R = [], B = [], r, c;
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
  function grid(b) { return [Math.max(3, Math.round(b.w / 72)), Math.max(3, Math.round(b.h / 72))]; }
  function fly(pcs, inward, b) {
    var far = (b.w + b.h) * 0.5;
    var anims = pcs.map(function (p) {
      var dist = far * 0.5 + Math.random() * 120, off = 'translate(' + (p.vx * dist) + 'px,' + (p.vy * dist) + 'px) rotate(' + (Math.random() * 100 - 50) + 'deg) scale(.7)';
      var kf = inward ? [{ transform: off, opacity: 0 }, { opacity: 1, offset: 0.3 }, { transform: 'none', opacity: 1 }] : [{ transform: 'none', opacity: 1 }, { transform: off, opacity: 0 }];
      return p.svg.animate(kf, { duration: inward ? 430 : 420, delay: (p.c + p.r) * (inward ? 42 : 38), easing: inward ? 'cubic-bezier(.3,1.3,.5,1)' : 'cubic-bezier(.6,0,.9,.5)', fill: 'both' });
    });
    return Promise.all(anims.map(function (a) { return a.finished; }));
  }

  /* ---- the layer behind the card (start, held pre-fight, release) ---- */
  function mkLayer(d, b) {
    dropLayer();
    layer = document.createElement('div'); layer.className = 'pfst-layer'; layer.setAttribute('aria-hidden', 'true');
    var g = grid(b); pieces = jig(b.w, b.h, g[0], g[1]);
    pieces.forEach(function (p) { layer.appendChild(p.svg); });
    d.insertBefore(layer, d.firstChild);
  }
  function dropLayer() { if (layer && layer.parentNode) layer.parentNode.removeChild(layer); layer = null; pieces = null; held = false; dropGhost(); var d = dlg(); if (d) d.classList.remove('pfst-held'); }
  function dropTop() { if (top && top.parentNode) top.parentNode.removeChild(top); top = null; tpieces = null; topIn = null; topReady = false; accepting = false; var d = dlg(); if (d) d.classList.remove('pfst-wait'); dropGhost(); }
  function dropGhost() { clearTimeout(ghostTimer); if (ghost && ghost.parentNode) ghost.parentNode.removeChild(ghost); ghost = null; }
  function reveal(d, fade) {
    d.classList.add('pfst-on'); seen(true);
    if (fade) { d.classList.add('pfst-fade'); setTimeout(function () { d.classList.remove('pfst-fade'); }, 480); }
    startFollow(); scrollIn(d); focusMain(d);
  }
  /* the card or board can be taller than what is left of the screen below the map: bring its bottom (the buttons) into view without losing its top */
  function scrollIn(d) {
    if (d.classList.contains('pfst-fixed')) return;
    try { var r = d.getBoundingClientRect(), dy = Math.min(r.bottom - window.innerHeight + 8, r.top - 8); if (dy > 1) window.scrollBy({ top: dy, left: 0, behavior: reduce.matches ? 'auto' : 'smooth' }); } catch (e) {}
  }
  /* the dialog is a modal whose card was hidden: put keyboard and screen-reader focus on its main button once it shows */
  function focusMain(d) {
    try { var b = d.querySelector('#pfv-pre .pfv-gof button, #pf-end, [data-pfst-dismiss], #pf-go'); if (b && !b.disabled) b.focus({ preventScroll: true }); } catch (e) {}
  }

  /* a dialog showed up on a page that had none */
  function waitFor(cond, ms) { return new Promise(function (res) { var t0 = Date.now(); (function poll() { var ok = false; try { ok = cond(); } catch (e) {} if (ok || Date.now() - t0 > ms) res(); else setTimeout(poll, 50); })(); }); }
  function begin(d, force) {
    var t = ++token, b = place(d);
    if (!(seenNoFight || force) || !usable() || !b) { reveal(d, false); return; }
    entering = true; startFollow();
    // hubscene.js opens the dialog as a modal a moment after the swap (a modal's box is measured from the document, a plain one's from its parent), and a Trail walk may still be playing on the map: the pieces wait for both
    waitFor(function () { var q = dlg(); return q && q.matches(':modal') && !document.querySelector('.tilemap.tmplay'); }, 3500).then(function () {
      if (t !== token) return;
      var d1 = dlg(); if (!d1) { entering = false; return; }
      d = d1; b = place(d1) || b; mkLayer(d1, b); go();
    });
    function go() {
    fly(pieces, true, b).then(function () {
      if (t !== token) return;
      entering = false;
      var d2 = dlg(); if (!d2) { dropLayer(); return; }
      b = place(d2) || b; if (layer && !d2.contains(layer)) d2.insertBefore(layer, d2.firstChild);
      var k = kindOf(d2);
      if (k === 'fight') { reveal(d2, true); return sleep(150).then(function () { var P = pieces; return P ? fly(P, false, b).then(dropLayer) : null; }); }
      held = true; if (k === 'pre') d2.classList.add('pfst-held');   // the pieces stay under the card until Let's fight
      reveal(d2, true);
    }).catch(function () { entering = false; dropLayer(); var d3 = dlg(); if (d3) reveal(d3, false); });
    }
  }
  /* a new dialog node (or new content) while the pieces are held */
  function adopt(d) {
    var b = place(d) || lastBox, k = kindOf(d);
    if (layer && !d.contains(layer)) d.insertBefore(layer, d.firstChild);
    if (ghost && !d.contains(ghost)) d.appendChild(ghost);
    if (top && !d.contains(top)) d.appendChild(top);
    if (k === 'pre') { d.classList.add('pfst-held'); reveal(d, false); return; }
    if (accepting) { d.classList.add('pfst-wait'); d.classList.add('pfst-on'); finishAccept(d); return; }   // Let's fight: the board is here; it shows once the new pieces cover the card
    held = false; reveal(d, true);   // (a page that brought the board some other way: the pieces just leave)
    var P = pieces; if (P && b) fly(P, false, b).then(dropLayer, dropLayer); else dropLayer();
  }
  /* Let's fight: the new pieces are over the card and the board has arrived: swap, then they leave */
  function finishAccept(d) {
    if (!topReady || !accepting) { if (topIn) topIn.then(function () { var d2 = dlg(); if (d2 && accepting && kindOf(d2) !== 'pre') finishAccept(d2); }); return; }
    var b = place(d) || lastBox, T = tpieces;
    accepting = false; held = false;
    d.classList.remove('pfst-wait'); d.classList.remove('pfst-held'); dropGhost(); dropLayer();   // the held pieces and the old card's ghost are under the new ones: drop them now
    reveal(d, false);
    if (T && b) fly(T, false, b).then(dropTop, dropTop); else dropTop();
  }

  /* ---- the way out of a won/lost fight: a popover cover above the dialog, the swap removes the fight, the pieces leave ---- */
  function mkCover(b) {
    dropCover();
    cover = document.createElement('div'); cover.className = 'pfst-cover'; cover.setAttribute('popover', 'manual'); cover.setAttribute('aria-hidden', 'true'); setBox(cover, b);
    var g = grid(b); cpieces = jig(b.w, b.h, g[0], g[1]); cpieces.forEach(function (p) { cover.appendChild(p.svg); });
    document.body.appendChild(cover); cover.showPopover();
  }
  function dropCover() { if (cover) { try { cover.hidePopover(); } catch (e) {} if (cover.parentNode) cover.parentNode.removeChild(cover); } cover = null; cpieces = null; coverUp = false; }

  /* ---- what changed? (called synchronously from a MutationObserver, so a replaced dialog never paints un-revealed) ---- */
  function check() {
    var d = dlg();
    if (d) {
      startFollow();
      if (!d.classList.contains('pfst-on')) {
        if (entering) { /* the pieces are still coming in: begin() reveals it */ }
        else if (layer && held) adopt(d);
        else if (!wasD) begin(d);
        else if (kindOf(d) === 'res') begin(d, true);   // the fight was run from: its result card gets the pieces too
        else reveal(d, false);   // a turn that replaced the dialog node: no pieces
      } else if (!entering && !dismissing) { place(d); if (layer && held && kindOf(d) !== 'pre') adopt(d); }   // keepTrailPop kept the dialog node: Let's fight turned its content into the board
    } else {
      seenNoFight = true; seen(false); var nb = curBox(); if (nb) lastBox = nb;
      if (wasD) {
        if (closing) {   // the swap removed the fight: when the cover is already whole it leaves now, else the click handler's cover-in finishes this
          if (coverUp && cover) { var b = closeBox || box(); closing = false; if (b) { setBox(cover, b); fly(cpieces, false, b).then(dropCover, dropCover); } else dropCover(); }
        } else if (!dismissing) { entering = false; dropLayer(); dropCover(); }
      }
    }
    wasD = !!d;
  }
  if (window.MutationObserver) {
    var mo = new MutationObserver(function () { try { check(); } catch (e) { var d = dlg(); if (d) d.classList.add('pfst-on'); } });
    mo.observe(document.body, { childList: true, subtree: true });
  }
  document.addEventListener('gv:swapped', function () { try { check(); } catch (e) {} });
  window.addEventListener('resize', function () { var d = dlg(); if (d) place(d); else { var nb = curBox(); if (nb) lastBox = nb; } });
  window.addEventListener('pageshow', function (ev) { if (!ev.persisted) return; var d = dlg(); if (d) { dropLayer(); dropTop(); place(d); d.classList.add('pfst-on'); } });   // a page restored from the back-forward cache only (pageshow also fires after every normal load)

  /* ---- clicks: Let's fight (keep a ghost of the card for the crossfade), End match (cover), the result card's button (pieces leave) ---- */
  document.addEventListener('click', function (ev) {
    var t = ev.target; if (!t || !t.closest) return;
    var dis = t.closest('[data-pfst-dismiss]');
    if (dis) {
      var d = dlg(); if (!d) return; ev.preventDefault(); dismissing = true;
      var done = function () { dismissing = false; try { d.close(); } catch (e) {} if (d.parentNode) d.parentNode.removeChild(d); dropLayer(); };
      var pb = d.querySelector('.pickbox'), b = box();
      if (layer && pieces && b && canAnim) { if (pb) pb.animate([{ opacity: 1 }, { opacity: 0 }], { duration: 260, fill: 'forwards' }); fly(pieces, false, b).then(done, done); } else done();
      return;
    }
    var btn = t.closest('button, input[type=submit]'); if (!btn || !btn.form) return;
    var doo = btn.form.querySelector('input[name=do]'), v = doo ? doo.value : '';
    if (v === 'pfv_go' && layer && held && canAnim) {   // the player accepts the deck: new pieces come in over the card (a ghost of it stays under them), then the board shows
      var d1 = dlg(), pre = d1 && d1.querySelector('#pfv-pre'), bx = visBox(); if (!pre || !bx) return;
      setBox(d1, bx); d1.classList.add('pfst-fixed');   // the combat will fill the window: the new pieces cover that
      dropGhost(); ghost = document.createElement('div'); ghost.className = 'pfst-ghost'; ghost.setAttribute('aria-hidden', 'true');
      var cl = pre.cloneNode(true); cl.removeAttribute('id'); Array.prototype.forEach.call(cl.querySelectorAll('[id]'), function (e) { e.removeAttribute('id'); }); Array.prototype.forEach.call(cl.querySelectorAll('form, script'), function (e) { e.parentNode.removeChild(e); });
      ghost.appendChild(cl); d1.appendChild(ghost);
      top = document.createElement('div'); top.className = 'pfst-top'; top.setAttribute('aria-hidden', 'true');
      var g = grid(bx); tpieces = jig(bx.w, bx.h, g[0], g[1]); tpieces.forEach(function (q) { top.appendChild(q.svg); }); d1.appendChild(top);
      d1.classList.add('pfst-wait'); accepting = true; topReady = false;
      topIn = fly(tpieces, true, bx).then(function () { topReady = true; });
      ghostTimer = setTimeout(function () { dropTop(); dropLayer(); var d9 = dlg(); if (d9) { d9.classList.remove('pfst-wait'); d9.classList.add('pfst-on'); } }, 9000);   // the board never came (an error shows its own message)
      return;
    }
    if (v === 'pf_finish' && dlg() && canPop && usable() && !closing) {
      var b2 = boxFor(dlg()); if (!b2) return;
      closing = true; var tk = ++token; closeBox = docBox(b2);
      mkCover(closeBox); b2 = closeBox; fly(cpieces, true, b2).then(function () { coverUp = true; if (tk === token && !dlg() && closing) { closing = false; fly(cpieces, false, b2).then(dropCover, dropCover); } }, function () { closing = false; dropCover(); });
      setTimeout(function () { if (closing && tk === token) { closing = false; dropCover(); } }, 6000);   // the swap never came (an error shows its own message)
    }
  }, true);

  var d0 = dlg();
  seenNoFight = !d0 || !seen(); lastBox = curBox();
  if (d0) check();   // (a fight already on the page: it gets the pieces too, once hubscene.js has made the dialog a modal)
})();
