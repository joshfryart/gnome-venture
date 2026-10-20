/* v2.0.6: the delve and lair maps (includes/delve_map.php + tilemap.php). The server walks the token and draws the final map.
   This script adds two things and nothing else is needed to play (the tiles are real buttons in a form):
   1. a path preview on hover / keyboard focus (data-open: 1 = floor you can cross, 2 = a room where a walk can end), drawn in .tmpv;
   2. when the page also sent the path just walked (data-walk="x,y;x,y;..."), the token walks it again tile by tile with a little hop, the
      footprints appear behind it and a chip counts the steps. Tap, click or any key skips. Reduced motion or no script: the final map as it is.
   The size of a tile in the picture comes from data-tile (svg units, the css scales the whole map), never from a number in here. */
(function () {
  var cur = null;
  var reduce = function () { return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches); };
  var NS = 'http://www.w3.org/2000/svg';

  function num(el, name) { return parseInt(el.getAttribute(name), 10) || 0; }

  /* ---- the path preview ---- */
  function bfs(open, w, h, sx, sy, tx, ty) {
    var start = sy * w + sx, goal = ty * w + tx, prev = {}, q = [start], i, k, c, d, nx, ny, nk;
    prev[start] = -1;
    var dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
    for (i = 0; i < q.length; i++) {
      c = q[i];
      if (c === goal) break;
      for (d = 0; d < 4; d++) {
        nx = (c % w) + dirs[d][0]; ny = Math.floor(c / w) + dirs[d][1];
        if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
        nk = ny * w + nx;
        if (prev[nk] !== undefined) continue;
        if (open.charAt(nk) === '1' || nk === goal && open.charAt(nk) === '2') { prev[nk] = c; q.push(nk); }
      }
    }
    if (prev[goal] === undefined || goal === start) return [];
    var path = [];
    for (k = goal; k !== start; k = prev[k]) path.unshift([k % w, Math.floor(k / w)]);
    return path;
  }

  function clearPreview(box) {
    var pv = box.querySelector('.tmpv');
    if (pv) while (pv.firstChild) pv.removeChild(pv.firstChild);
  }

  function preview(box, btn) {
    var pv = box.querySelector('.tmpv');
    if (!pv || !btn || btn.disabled) { clearPreview(box); return; }
    var xy = (btn.value || '').split(',');
    var tx = parseInt(xy[0], 10), ty = parseInt(xy[1], 10);
    var T = num(box, 'data-tile') || 42, x0 = num(box, 'data-x0'), y0 = num(box, 'data-y0');
    var path = bfs(box.getAttribute('data-open') || '', num(box, 'data-mw'), num(box, 'data-mh'), num(box, 'data-px'), num(box, 'data-py'), tx, ty);
    clearPreview(box);
    for (var i = 0; i < path.length; i++) {
      var c = document.createElementNS(NS, 'circle');
      c.setAttribute('cx', ((path[i][0] - x0) * T + T / 2).toFixed(1));
      c.setAttribute('cy', ((path[i][1] - y0) * T + T / 2).toFixed(1));
      c.setAttribute('r', i === path.length - 1 ? (T * 0.36).toFixed(1) : (T * 0.17).toFixed(1));
      c.setAttribute('class', i === path.length - 1 ? 'tmpv-end' : 'tmpv-dot');
      pv.appendChild(c);
    }
  }

  function wirePreview(box) {
    if (box.getAttribute('data-pv')) return;
    box.setAttribute('data-pv', '1');
    var over = function (ev) { var b = ev.target.closest ? ev.target.closest('.tmt') : null; if (b) preview(box, b); };
    box.addEventListener('mouseover', over);
    box.addEventListener('focusin', over);
    box.addEventListener('mouseleave', function () { clearPreview(box); });
    box.addEventListener('focusout', function () { clearPreview(box); });
  }

  /* ---- the walk animation ---- */
  function Walk(box) {
    var self = this, i;
    this.box = box;
    this.svg = box.querySelector('.tmbg');
    this.me = this.svg ? this.svg.querySelector('.tmme') : null;
    this.chip = box.querySelector('.tmchip');
    this.feet = box.querySelectorAll('.tmft');
    var T = num(box, 'data-tile') || 42, x0 = num(box, 'data-x0'), y0 = num(box, 'data-y0');
    var raw = (box.getAttribute('data-walk') || '').split(';');
    this.pts = [];
    for (i = 0; i < raw.length; i++) {
      var xy = raw[i].split(',');
      this.pts.push([(parseInt(xy[0], 10) - x0) * T + T / 2, (parseInt(xy[1], 10) - y0) * T + T / 2]);
    }
    this.steps = this.pts.length - 1;
    this.n = 0;
    this.ms = Math.max(60, Math.min(130, 3200 / Math.max(1, this.steps)));
    this.t0 = 0;
    this.done = false;
    this.skip = function (ev) {
      if (ev && ev.type === 'click') { ev.preventDefault(); ev.stopPropagation(); }
      self.end();
    };
    this.tick = function (now) {
      if (self.done) return;
      if (!self.t0) self.t0 = now;
      var k = (now - self.t0) / self.ms, n = Math.floor(k);
      if (n >= self.steps) { self.end(); return; }
      if (n > self.n) self.reveal(n);
      var f = k - n, a = self.pts[n], b = self.pts[n + 1];
      self.put(a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f - Math.sin(Math.PI * f) * 6);
      self.raf = window.requestAnimationFrame(self.tick);
    };
    box.classList.add('tmplay');
    this.put(this.pts[0][0], this.pts[0][1]);
    this.reveal(0);
    document.addEventListener('keydown', this.skip, true);
    document.addEventListener('click', this.skip, true);
    document.addEventListener('touchstart', this.skip, true);
    this.raf = window.requestAnimationFrame(this.tick);
  }
  Walk.prototype.put = function (x, y) {
    if (this.me) this.me.setAttribute('transform', 'translate(' + x.toFixed(1) + ' ' + y.toFixed(1) + ')');
  };
  Walk.prototype.reveal = function (n) {
    this.n = n;
    for (var i = 0; i < this.feet.length; i++) {
      if (parseInt(this.feet[i].getAttribute('data-i'), 10) < n) this.feet[i].setAttribute('class', 'tmft on');
    }
    if (this.chip) {
      this.chip.hidden = false;
      this.chip.textContent = '🥾 ' + n + ' / ' + this.steps;
    }
  };
  Walk.prototype.end = function () {
    if (this.done) return;
    this.done = true;
    if (this.raf) window.cancelAnimationFrame(this.raf);
    document.removeEventListener('keydown', this.skip, true);
    document.removeEventListener('click', this.skip, true);
    document.removeEventListener('touchstart', this.skip, true);
    var last = this.pts[this.pts.length - 1];
    this.put(last[0], last[1]);
    this.box.classList.remove('tmplay');
    for (var i = 0; i < this.feet.length; i++) this.feet[i].setAttribute('class', 'tmft on');
    if (this.chip) this.chip.hidden = true;
    if (cur === this) cur = null;
  };

  function scan() {
    var boxes = document.querySelectorAll('.tilemap');
    for (var i = 0; i < boxes.length; i++) wirePreview(boxes[i]);
    var box = document.querySelector('.tilemap[data-walk]:not([data-played])');
    if (!box) return;
    box.setAttribute('data-played', '1');
    if (cur) cur.end();
    if (reduce() || !window.requestAnimationFrame) return;
    var w = new Walk(box);
    if (w.steps < 1 || !w.me) { w.end(); return; }
    cur = w;
  }
  function start() {
    scan();
    if (window.MutationObserver) new MutationObserver(scan).observe(document.querySelector('main') || document.body, { childList: true, subtree: true });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
