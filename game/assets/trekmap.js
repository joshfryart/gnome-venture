/* v1.8.10: the walk animation on the Treks map. The server has already walked the party and drawn the final map (token, lantern, footprints).
   When it also sent the path (data-walk="x,y;x,y;..." on .trekmap), the token walks it again tile by tile with a little hop, the footprints
   appear behind it, a chip counts the steps and the lantern light follows. Tap, click or any key skips. Reduced motion or no script: the final map as is. */
(function () {
  var TILE = 42, cur = null;
  var reduce = function () { return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches); };

  function Walk(box) {
    var self = this, i;
    this.box = box;
    this.svg = box.querySelector('.tkbg');
    this.me = box.querySelector('.tkme');
    this.lan = this.svg ? this.svg.querySelector('#tklan') : null;
    this.chip = box.querySelector('.tkchip');
    this.feet = box.querySelectorAll('.tkft');
    var x0 = parseInt(box.getAttribute('data-x0'), 10), y0 = parseInt(box.getAttribute('data-y0'), 10);
    var raw = (box.getAttribute('data-walk') || '').split(';');
    this.pts = [];
    for (i = 0; i < raw.length; i++) {
      var xy = raw[i].split(',');
      this.pts.push([(parseInt(xy[0], 10) - x0) * TILE + TILE / 2, (parseInt(xy[1], 10) - y0) * TILE + TILE / 2]);
    }
    this.steps = this.pts.length - 1;
    this.n = 0;
    this.ms = Math.max(60, Math.min(120, 3500 / Math.max(1, this.steps)));   /* ~120 ms a tile, never more than ~3.5 s in all */
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
    box.classList.add('tkplay');
    this.put(this.pts[0][0], this.pts[0][1]);
    this.reveal(0);
    document.addEventListener('keydown', this.skip, true);
    document.addEventListener('click', this.skip, true);
    document.addEventListener('touchstart', this.skip, true);
    this.raf = window.requestAnimationFrame(this.tick);
  }
  Walk.prototype.put = function (x, y) {
    if (this.me) this.me.setAttribute('transform', 'translate(' + x.toFixed(1) + ' ' + y.toFixed(1) + ')');
    if (this.lan) { this.lan.setAttribute('cx', x.toFixed(1)); this.lan.setAttribute('cy', (y).toFixed(1)); }
  };
  Walk.prototype.reveal = function (n) {   /* n = tiles walked so far: show the footprints left on tiles 0 .. n-1 (data-i) and the count */
    this.n = n;
    var i;
    for (i = 0; i < this.feet.length; i++) {
      if (parseInt(this.feet[i].getAttribute('data-i'), 10) < n) this.feet[i].setAttribute('class', 'tkft on');
    }
    if (this.chip) {
      this.chip.hidden = false;
      this.chip.textContent = '\uD83E\uDD7E walking\u2026 ' + n + ' / ' + this.steps;
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
    this.box.classList.remove('tkplay');   /* every footprint shows, the flag goes */
    if (this.chip) this.chip.hidden = true;
    if (cur === this) cur = null;
  };

  function scan() {
    var box = document.querySelector('.trekmap[data-walk]:not([data-played])');
    if (!box) return;
    box.setAttribute('data-played', '1');
    if (cur) cur.end();
    if (reduce() || !window.requestAnimationFrame) return;
    var w = new Walk(box);
    if (w.steps < 2 || !w.me) { w.end(); return; }
    cur = w;
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.querySelector('main') || document.body, { childList: true, subtree: true });
})();
