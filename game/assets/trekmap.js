/* v1.8.10: the walk animation on the Treks map. The server has already walked the party and drawn the final map (token, lantern, footprints).
   When it also sent the path (data-walk="x,y;x,y;..." on .trekmap), the token walks it again tile by tile with a little hop, the footprints
   appear behind it, a chip counts the steps and the lantern light follows. Tap, click or any key skips. Reduced motion or no script: the final map as is. */
(function () {
  var TILE = 42, cur = null;
  var reduce = function () { return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches); };

  function Walk(box) {
    var self = this, i;
    this.box = box;
    var ext = box.querySelector('.tkbg.tkx');
    this.cam = !!ext && !!box.getAttribute('data-mw');   /* v2.0.10: a wider picture came with the walk: the camera follows the token */
    this.svg = this.cam ? ext : box.querySelector('.tkbg');
    this.me = this.svg ? this.svg.querySelector('.tkme') : null;
    this.lan = this.svg ? this.svg.querySelector(this.cam ? '#tklanx' : '#tklan') : null;
    this.chip = box.querySelector('.tkchip');
    this.feet = this.svg ? this.svg.querySelectorAll('.tkft') : [];
    var gx = parseInt(box.getAttribute(this.cam ? 'data-ex0' : 'data-x0'), 10), gy = parseInt(box.getAttribute(this.cam ? 'data-ey0' : 'data-y0'), 10);
    this.gx = gx; this.gy = gy;
    var raw = (box.getAttribute('data-walk') || '').split(';');
    this.pts = [];
    for (i = 0; i < raw.length; i++) {
      var xy = raw[i].split(',');
      this.pts.push([(parseInt(xy[0], 10) - gx) * TILE + TILE / 2, (parseInt(xy[1], 10) - gy) * TILE + TILE / 2]);
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
      var x = a[0] + (b[0] - a[0]) * f, y = a[1] + (b[1] - a[1]) * f;
      self.put(x, y - Math.sin(Math.PI * f) * 6);
      self.look(x, y);
      self.raf = window.requestAnimationFrame(self.tick);
    };
    box.classList.add('tkplay');
    if (this.cam) { box.classList.add('tkcam'); this.look(this.pts[0][0], this.pts[0][1]); }
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
  /* The camera: the wide picture slides so the token stays in the middle of the window; at the edges of the map it stops (the same
     window the server draws when the walk is over, so there is no jump at the end). x, y in picture units of the wide picture. */
  Walk.prototype.look = function (x, y) {
    if (!this.cam) return;
    var b = this.box, phone = !!(window.matchMedia && window.matchMedia('(max-width: 899px)').matches);
    var vc = phone ? 9 : 15, vr = phone ? 9 : 11, ts = b.clientWidth / vc;
    var mw = parseInt(b.getAttribute('data-mw'), 10), mh = parseInt(b.getAttribute('data-mh'), 10);
    var ew = parseInt(b.getAttribute('data-ew'), 10), eh = parseInt(b.getAttribute('data-eh'), 10);
    var tx = x / TILE + this.gx, ty = y / TILE + this.gy;   /* the token in map tiles (centre of a tile = .5) */
    var ox = Math.max(0, Math.min(mw - vc, tx - vc / 2)), oy = Math.max(0, Math.min(mh - vr, ty - vr / 2));
    var st = this.svg.style;
    st.width = (ew * ts).toFixed(1) + 'px';
    st.height = (eh * ts).toFixed(1) + 'px';
    st.left = ((this.gx - ox) * ts).toFixed(1) + 'px';
    st.top = ((this.gy - oy) * ts).toFixed(1) + 'px';
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
    if (this.cam) { this.box.classList.remove('tkcam'); this.svg.removeAttribute('style'); }   /* back to the plain final picture */
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
