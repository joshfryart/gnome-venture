/* 2.8.93 Map v2: the lit floor region map widget (includes/map_v2.php region_map_block). Loaded on world.php only while map_v2_open is on.
   Without this file the widget still works: every stop and place is a plain link (?near=, ?at=, world.php?go=).
   With it: the map pans (drag) and zooms (pinch, Ctrl/Alt + wheel, + − Fit) inside a tall viewport, a tap on a stop or a place selects that stop
   (the rest dims, the bottom sheet lists its places), the keyboard pans and zooms, reduced motion jumps instead of gliding.
   The view box always has the viewport's own aspect, so screen to map is linear. No timers; nothing pulses. */
(function () {
  'use strict';
  var MW = 480, MH = 270, SMAX = 3.4;
  var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function bind(box) {
    var vp = box.querySelector('.mv2-vp'), svg = box.querySelector('svg.mv2-svg'), ctl = box.querySelector('.mv2-ctl'), sheet = box.querySelector('.mv2-sheet');
    if (!vp || !svg || !sheet) return;
    box.classList.add('on');
    if (ctl) ctl.hidden = false;
    var hd = sheet.querySelector('.mv2-hd'), t1 = sheet.querySelector('.mv2-t1'), t2 = sheet.querySelector('.mv2-t2'), ch = sheet.querySelector('.mv2-ch');
    var key = 'gv-mapv2:' + (box.getAttribute('data-region') || '') + ':' + (box.getAttribute('data-lv') || '0');
    var focusMode = box.getAttribute('data-focus') === '1';
    var st = { s: 1, cx: MW / 2, cy: MH / 2 }, sel = parseInt(box.getAttribute('data-sel') || '0', 10) || 0, anim = 0;
    var hits = Array.prototype.slice.call(svg.querySelectorAll('.hit'));

    function vw() { return vp.clientWidth || MW; }
    function vh() { return vp.clientHeight || MH; }
    function sheetH() { return sheet.offsetHeight || 0; }
    function visH() { return Math.max(60, vh() - sheetH()); }
    function sFit() { return vw() / MW; }
    function sHome() { return Math.min(SMAX, Math.max(visH() / MH, 1.4, sFit())); }
    function clamp(v) {
      v.s = Math.max(sFit(), Math.min(SMAX, v.s));
      var w = vw() / v.s, hv = visH() / v.s;
      v.cx = MW * v.s <= vw() ? MW / 2 : Math.max(w / 2, Math.min(MW - w / 2, v.cx));
      v.cy = MH * v.s <= visH() ? MH / 2 : Math.max(hv / 2, Math.min(MH - hv / 2, v.cy));
      return v;
    }
    function render() {
      var zs = Math.max(0.8, Math.min(1.35, 1.95 / st.s));
      svg.style.setProperty('--zs', zs.toFixed(3));
      svg.classList.toggle('far', st.s < 1.25);
      var r = Math.max(24, 22 / (st.s * zs)).toFixed(1);
      for (var i = 0; i < hits.length; i++) hits[i].setAttribute('r', r);
    }
    function draw() {
      var w = vw() / st.s, h = vh() / st.s;
      svg.setAttribute('viewBox', [(st.cx - w / 2).toFixed(2), (st.cy - visH() / (2 * st.s)).toFixed(2), w.toFixed(2), h.toFixed(2)].join(' '));
      render();
    }
    function save() {
      try { sessionStorage.setItem(key, JSON.stringify({ s: st.s, cx: st.cx, cy: st.cy, sel: sel })); } catch (e) { /* private window: no memory, no harm */ }
    }
    function go(to, animate) {
      clamp(to);
      if (anim) { cancelAnimationFrame(anim); anim = 0; }
      if (!animate || reduce) { st = to; draw(); save(); return; }
      var from = { s: st.s, cx: st.cx, cy: st.cy }, t0 = null;
      function step(ts) {
        if (t0 === null) t0 = ts;
        var k = Math.min(1, (ts - t0) / 250), e = k < 0.5 ? 2 * k * k : 1 - Math.pow(-2 * k + 2, 2) / 2;
        st = { s: from.s + (to.s - from.s) * e, cx: from.cx + (to.cx - from.cx) * e, cy: from.cy + (to.cy - from.cy) * e };
        draw();
        if (k < 1) anim = requestAnimationFrame(step); else { anim = 0; st = to; draw(); save(); }
      }
      anim = requestAnimationFrame(step);
    }
    function centerOn(x, y, animate, s) { go({ s: s || st.s, cx: x, cy: y }, animate); }
    function zoomAt(s2, sx, sy, animate) {   // keep the map point under (sx, sy) (px from the viewport's top left) where it is
      s2 = Math.max(sFit(), Math.min(SMAX, s2));
      var px = st.cx - vw() / (2 * st.s) + sx / st.s, py = st.cy - visH() / (2 * st.s) + sy / st.s;
      go({ s: s2, cx: px + vw() / (2 * s2) - sx / s2, cy: py + visH() / (2 * s2) - sy / s2 }, animate);
    }
    function posOf(el) {
      var m = /translate\(\s*([-\d.]+)[ ,]+([-\d.]+)/.exec((el && el.getAttribute('transform')) || '');
      return m ? [parseFloat(m[1]), parseFloat(m[2])] : null;
    }
    function stopPos(id) { return posOf(svg.querySelector('.mv2-stop[data-stop="' + id + '"]')); }
    function setOpen(open) {
      sheet.classList.toggle('open', open);
      if (hd) hd.setAttribute('aria-expanded', open ? 'true' : 'false');
      if (ch) ch.textContent = open ? 'Hide' : 'List';
    }
    function select(stop, place, opts) {
      opts = opts || {};
      sel = stop || 0;
      var els = svg.querySelectorAll('[data-stop]');
      for (var i = 0; i < els.length; i++) els[i].classList.toggle('on', !!sel && els[i].getAttribute('data-stop') === String(sel));
      svg.classList.toggle('sel', !!sel);
      var grps = sheet.querySelectorAll('.mv2-grp'), g = null;
      for (var j = 0; j < grps.length; j++) { var on = grps[j].getAttribute('data-stop') === String(sel); grps[j].hidden = !on; if (on) g = grps[j]; }
      if (t1) t1.textContent = g ? g.getAttribute('data-t1') : 'Places off the road';
      if (t2) t2.textContent = g ? g.getAttribute('data-t2') : 'Tap a stop or a place';
      var links = box.querySelectorAll('.mv2-stopl');
      for (var k = 0; k < links.length; k++) { if (links[k].getAttribute('data-stop') === String(sel)) links[k].setAttribute('aria-current', 'true'); else links[k].removeAttribute('aria-current'); }
      var rows = sheet.querySelectorAll('.mv2-row.at, .mv2-p.at');
      for (var q = 0; q < rows.length; q++) rows[q].classList.remove('at');
      var marks = svg.querySelectorAll('.mv2-p.at');
      for (var q2 = 0; q2 < marks.length; q2++) marks[q2].classList.remove('at');
      setOpen(!!sel);
      if (place) {
        var row = document.getElementById('mv2-r-' + place), mk = svg.querySelector('.mv2-p[data-id="' + place + '"]');
        if (row) { row.classList.add('at'); if (row.scrollIntoView) row.scrollIntoView({ block: 'nearest' }); }
        if (mk) mk.classList.add('at');
      }
      if (sel && !opts.noMove) { var p = stopPos(sel); if (p) centerOn(p[0], p[1], true, Math.max(st.s, sHome())); }
      if (!opts.noUrl && window.history && history.replaceState) {
        try {
          var u = new URL(window.location.href);
          if (sel) u.searchParams.set('near', String(sel)); else u.searchParams.delete('near');
          if (place) u.searchParams.set('at', String(place)); else u.searchParams.delete('at');
          history.replaceState(history.state, '', u.toString());
        } catch (e) { /* old browser: the address just does not follow */ }
      }
      save();
    }

    // opening view
    var mem = null;
    try { mem = JSON.parse(sessionStorage.getItem(key) || 'null'); } catch (e) { mem = null; }
    var here = (box.getAttribute('data-here') || '').split(' ').map(Number);
    if (!sel && mem && mem.sel && !/[?&]near=/.test(window.location.search)) select(mem.sel, 0, { noMove: true, noUrl: true });
    else select(sel, (/[?&]at=(\d+)/.exec(window.location.search) || [])[1] | 0, { noMove: true, noUrl: true });
    if (focusMode && here.length === 2) centerOn(here[0], here[1], false, sHome());
    else if (mem && typeof mem.s === 'number' && !/[?&]near=/.test(window.location.search)) go({ s: mem.s, cx: mem.cx, cy: mem.cy }, false);
    else if (sel && stopPos(sel)) { var sp = stopPos(sel); centerOn(sp[0], sp[1], false, sHome()); }
    else if (here.length === 2) centerOn(here[0], here[1], false, sHome());
    else go({ s: sHome(), cx: MW / 2, cy: MH / 2 }, false);

    // controls
    if (ctl) ctl.addEventListener('click', function (ev) {
      var b = ev.target.closest('[data-z]');
      if (!b) return;
      var z = b.getAttribute('data-z');
      if (z === 'in') zoomAt(st.s + 0.45, vw() / 2, visH() / 2, true);
      else if (z === 'out') zoomAt(st.s - 0.45, vw() / 2, visH() / 2, true);
      else { select(0, 0, { noMove: true }); go({ s: sFit(), cx: MW / 2, cy: MH / 2 }, true); }
    });
    if (hd) hd.addEventListener('click', function () {
      setOpen(!sheet.classList.contains('open'));
      var p = sel && stopPos(sel);
      if (p) centerOn(p[0], p[1], true); else go({ s: st.s, cx: st.cx, cy: st.cy }, false);
    });

    // taps on stops and places (map and stop list) select instead of loading the page; Go links and exits navigate
    var dragged = false;
    box.addEventListener('click', function (ev) {
      if (dragged) { ev.preventDefault(); ev.stopPropagation(); dragged = false; return; }
      var a = ev.target.closest('a[href*="near="]');
      if (!a || !box.contains(a)) return;
      var href = a.getAttribute('href') || '', n = (/[?&]near=(\d+)/.exec(href) || [])[1] | 0, at = (/[?&]at=(\d+)/.exec(href) || [])[1] | 0;
      if (!n) return;
      ev.preventDefault();
      if (n === sel && !at && !a.classList.contains('mv2-stopl')) select(0, 0, { noMove: true });
      else select(n, at);
      if (a.classList.contains('mv2-stopl') && vp.scrollIntoView) vp.scrollIntoView({ block: 'nearest', behavior: reduce ? 'auto' : 'smooth' });
    }, true);

    // drag to pan, two fingers to pinch
    var pts = {}, start = null, pinch = null;
    function local(ev) { var r = vp.getBoundingClientRect(); return [ev.clientX - r.left, ev.clientY - r.top]; }
    function count() { return Object.keys(pts).length; }
    vp.addEventListener('pointerdown', function (ev) {
      if (ev.target.closest('.mv2-sheet, .mv2-ctl')) return;
      if (ev.pointerType === 'mouse' && ev.button !== 0) return;
      pts[ev.pointerId] = local(ev);
      dragged = false;
      if (count() === 1) start = { p: local(ev), cx: st.cx, cy: st.cy, moving: false, id: ev.pointerId };
      else if (count() === 2) {
        var k = Object.keys(pts), a = pts[k[0]], b = pts[k[1]];
        pinch = { d: Math.hypot(a[0] - b[0], a[1] - b[1]) || 1, s: st.s };
        start = null;
      }
    });
    vp.addEventListener('pointermove', function (ev) {
      if (!(ev.pointerId in pts)) return;
      pts[ev.pointerId] = local(ev);
      if (pinch && count() >= 2) {
        var k = Object.keys(pts), a = pts[k[0]], b = pts[k[1]], d = Math.hypot(a[0] - b[0], a[1] - b[1]) || 1;
        zoomAt(pinch.s * d / pinch.d, (a[0] + b[0]) / 2, (a[1] + b[1]) / 2, false);
        dragged = true;
        return;
      }
      if (!start) return;
      var p = pts[ev.pointerId], dx = p[0] - start.p[0], dy = p[1] - start.p[1];
      if (!start.moving && Math.hypot(dx, dy) < 6) return;
      if (!start.moving) { start.moving = true; vp.classList.add('drag'); try { vp.setPointerCapture(ev.pointerId); } catch (e) { /* fine */ } }
      dragged = true;
      st = clamp({ s: st.s, cx: start.cx - dx / st.s, cy: start.cy - dy / st.s });
      draw();
    });
    function up(ev) {
      if (!(ev.pointerId in pts)) return;
      delete pts[ev.pointerId];
      if (count() < 2) pinch = null;
      if (!count()) { vp.classList.remove('drag'); if (start && start.moving) save(); start = null; }
      if (ev.type === 'pointercancel') dragged = false;
    }
    vp.addEventListener('pointerup', up);
    vp.addEventListener('pointercancel', up);
    vp.addEventListener('wheel', function (ev) {
      if (!ev.ctrlKey && !ev.altKey) return;   // a plain wheel scrolls the page
      ev.preventDefault();
      var p = local(ev);
      zoomAt(st.s * (ev.deltaY < 0 ? 1.15 : 1 / 1.15), p[0], p[1], false);
    }, { passive: false });

    // keyboard: arrows pan, + − zoom, 0 fits, Escape clears
    vp.addEventListener('keydown', function (ev) {
      if (ev.target.closest('.mv2-sheet, .mv2-ctl')) return;
      var k = ev.key, step = 48 / st.s;
      if (k === 'ArrowLeft') centerOn(st.cx - step, st.cy, true);
      else if (k === 'ArrowRight') centerOn(st.cx + step, st.cy, true);
      else if (k === 'ArrowUp') centerOn(st.cx, st.cy - step, true);
      else if (k === 'ArrowDown') centerOn(st.cx, st.cy + step, true);
      else if (k === '+' || k === '=') zoomAt(st.s + 0.45, vw() / 2, visH() / 2, true);
      else if (k === '-' || k === '_') zoomAt(st.s - 0.45, vw() / 2, visH() / 2, true);
      else if (k === '0') go({ s: sFit(), cx: MW / 2, cy: MH / 2 }, true);
      else if (k === 'Escape') select(0, 0, { noMove: true });
      else return;
      ev.preventDefault();
    });
    svg.addEventListener('focusin', function (ev) {   // a marker reached with Tab is brought into view
      var g = ev.target.closest('.rmp'), p = posOf(g);
      if (!p) return;
      var w = vw() / st.s, x0 = st.cx - w / 2, y0 = st.cy - visH() / (2 * st.s);
      if (p[0] < x0 + 10 || p[0] > x0 + w - 10 || p[1] < y0 + 10 || p[1] > y0 + visH() / st.s - 10) centerOn(p[0], p[1], true);
    });
    if (window.ResizeObserver) new ResizeObserver(function () { st = clamp(st); draw(); }).observe(vp);
    else window.addEventListener('resize', function () { st = clamp(st); draw(); });
  }

  function init() { document.querySelectorAll('.mv2:not(.on)').forEach(bind); }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
