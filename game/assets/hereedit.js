/* Admin picture layout editor: drag a dot to move its slot. The x / y boxes are the real form fields; this only keeps dots and boxes in step.
   Pointer events, 1 unit snap. No inline styles (CSP): positions are SVG attributes. */
(function () {
  'use strict';
  var svg = document.getElementById('hereedit');
  if (!svg) return;
  var W = +svg.getAttribute('data-w'), H = +svg.getAttribute('data-h'), drag = null;
  function box(g, i, axis) { return document.querySelector('input[name="' + axis + '[' + g + '][' + i + ']"]'); }
  function place(dot, x, y) {
    var c = dot.querySelector('circle'), t = dot.querySelector('text');
    c.setAttribute('cx', x); c.setAttribute('cy', y); t.setAttribute('x', x + 9); t.setAttribute('y', y + 4);
  }
  function pt(ev) {
    var r = svg.getBoundingClientRect();
    return [Math.max(0, Math.min(W, Math.round((ev.clientX - r.left) * W / r.width))), Math.max(0, Math.min(H, Math.round((ev.clientY - r.top) * H / r.height)))];
  }
  svg.addEventListener('pointerdown', function (ev) {
    var d = ev.target.closest && ev.target.closest('.hdot');
    if (!d) return;
    drag = d; try { svg.setPointerCapture(ev.pointerId); } catch (e) {}
    ev.preventDefault();
  });
  svg.addEventListener('pointermove', function (ev) {
    if (!drag) return;
    var p = pt(ev), g = drag.getAttribute('data-g'), i = drag.getAttribute('data-i');
    place(drag, p[0], p[1]);
    box(g, i, 'x').value = p[0]; box(g, i, 'y').value = p[1];
  });
  function end() { drag = null; }
  svg.addEventListener('pointerup', end); svg.addEventListener('pointercancel', end);
  // keyboard: arrows nudge the focused dot by 1 (shift = 10)
  svg.addEventListener('keydown', function (ev) {
    var d = ev.target.closest && ev.target.closest('.hdot');
    if (!d) return;
    var k = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] }[ev.key];
    if (!k) return;
    ev.preventDefault();
    var g = d.getAttribute('data-g'), i = d.getAttribute('data-i'), bx = box(g, i, 'x'), by = box(g, i, 'y'), s = ev.shiftKey ? 10 : 1;
    var x = Math.max(0, Math.min(W, (+bx.value) + k[0] * s)), y = Math.max(0, Math.min(H, (+by.value) + k[1] * s));
    bx.value = x; by.value = y; place(d, x, y);
  });
  // typing in a box moves the dot
  document.addEventListener('input', function (ev) {
    var m = /^([xy])\[(\w+)\]\[(\d+)\]$/.exec(ev.target.name || '');
    if (!m) return;
    var d = svg.querySelector('.hdot[data-g="' + m[2] + '"][data-i="' + m[3] + '"]');
    if (d) place(d, +box(m[2], m[3], 'x').value || 0, +box(m[2], m[3], 'y').value || 0);
  });
})();
