/* v1.4.0: replay of "Fight on". The server has already played every round and rendered the final state; this only shows
   the rounds one by one (health bars, hit flashes, log lines) on top of it. Tap anywhere to skip. No JS or reduced motion: final state only. */
(function () {
  var STEP = 550, TWEEN = 240, active = null;
  var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function num(el, v, max) { if (el) gvIcoLine(el, 'ico-heart-red', ' ' + v + '/' + max, 'Heart'); }
  function flash(el, cls) {
    if (!el) return;
    el.classList.remove('fo-hit', 'fo-crit');
    void el.offsetWidth;
    el.classList.add('fo-hit');
    if (cls) el.classList.add(cls);
  }

  function Play(stage) {
    var self = this, data;
    try { data = JSON.parse(stage.getAttribute('data-replay') || ''); } catch (e) { data = null; }
    this.root = stage.parentElement;
    this.stage = stage;
    if (!data || !data.rounds || !data.rounds.length || reduce) { stage.remove(); return; }
    this.data = data;
    this.timers = [];
    this.raf = [];
    this.i = 0;
    this.step = Math.max(300, Math.min(STEP, Math.round(7000 / data.rounds.length)));   // long fights speed up so they take about 7 s at most
    this.foe = { box: stage.querySelector('.fo-side.foe'), v: data.f0, max: data.fmax };
    this.me = { box: stage.querySelector('.fo-side.me'), v: data.m0, max: data.mmax };
    [this.foe, this.me].forEach(function (s) { s.m = s.box.querySelector('meter'); s.n = s.box.querySelector('.fo-n'); });
    this.list = stage.querySelector('.fo-lines');
    // lock the card: buttons stay put but can't be used while it plays
    this.locked = Array.prototype.slice.call(this.root.querySelectorAll('button'));
    this.locked.forEach(function (b) { b.setAttribute('aria-disabled', 'true'); });
    this.root.classList.add('fo-lock');
    document.body.classList.add('fo-playing');
    this.fold = this.root.closest ? this.root.closest('details') : null;
    this.foldWas = this.fold ? this.fold.open : false;
    if (this.fold) this.fold.open = true;
    this.hp = document.querySelector('.advbar .advhp');
    this.hpText = this.hp ? this.hp.textContent : '';
    if (this.hp) gvIcoLine(this.hp, 'ico-heart-red', ' ' + data.m0 + '/' + data.mmax, 'Heart');
    stage.hidden = false;
    stage.classList.add('on');
    stage.setAttribute('data-playing', '1');
    this.onClick = function (ev) {
      if (ev.target.closest && ev.target.closest('a[href]') && !ev.target.closest('.fostage')) return;
      ev.preventDefault();      // a tap on a locked button must not send its form
      self.finish();
    };
    this.onSubmit = function (ev) { ev.preventDefault(); ev.stopImmediatePropagation(); self.finish(); };
    this.root.addEventListener('click', this.onClick, true);
    this.root.addEventListener('submit', this.onSubmit, true);
    this.later(function () { self.round(); }, 350);
  }
  Play.prototype.later = function (fn, ms) { this.timers.push(setTimeout(fn, ms)); };
  Play.prototype.tween = function (side, to) {
    var from = side.v, t0 = null, self = this;
    if (from === to) return;
    side.v = to;
    function tick(t) {
      if (t0 === null) t0 = t;
      var k = Math.min(1, (t - t0) / TWEEN), v = Math.round(from + (to - from) * k);
      side.m.value = v; num(side.n, v, side.max);
      side.box.classList.toggle('low', v * 3 <= side.max);
      if (k < 1) self.raf.push(requestAnimationFrame(tick));
    }
    this.raf.push(requestAnimationFrame(tick));
  };
  Play.prototype.round = function () {
    var self = this, r = this.data.rounds[this.i++];
    if (!r) { this.finish(); return; }
    var foeHit = r.f < this.foe.v, meHit = r.m < this.me.v;
    r.l.forEach(function (t) {
      var li = document.createElement('li');
      li.textContent = t;
      if (/critical/.test(t)) li.className = 'fo-pop';
      self.list.appendChild(li);
    });
    this.list.scrollTop = this.list.scrollHeight;   /* v1.9.0: keep every line (the box scrolls) instead of trimming to the last four */
    if (foeHit) { this.tween(this.foe, r.f); flash(this.foe.box, r.c ? 'fo-crit' : ''); } else this.tween(this.foe, r.f);
    if (meHit || r.m !== this.me.v) {
      this.later(function () {
        self.tween(self.me, r.m);
        if (self.hp) gvIcoLine(self.hp, 'ico-heart-red', ' ' + r.m + '/' + self.data.mmax, 'Heart');
        if (meHit) flash(self.me.box);
      }, 260);
    }
    this.later(function () { self.round(); }, this.i >= this.data.rounds.length ? this.step + 250 : this.step);
  };
  Play.prototype.finish = function () {
    if (this.done) return;
    this.done = true;
    this.timers.forEach(clearTimeout);
    this.raf.forEach(cancelAnimationFrame);
    this.root.removeEventListener('click', this.onClick, true);
    this.root.removeEventListener('submit', this.onSubmit, true);
    this.locked.forEach(function (b) { b.removeAttribute('aria-disabled'); });
    this.root.classList.remove('fo-lock');
    document.body.classList.remove('fo-playing');
    if (this.hp) this.hp.textContent = this.hpText;
    if (this.fold && !this.foldWas && !this.fold.hasAttribute('data-busy')) this.fold.open = false;
    this.stage.remove();
    if (active === this) active = null;
  };

  /* v1.9.0: "Show all" on a road fight: scroll the box to the newest line when it is opened */
  document.addEventListener('toggle', function (ev) {
    var d = ev.target;
    if (d && d.classList && d.classList.contains('fightall') && d.open) { var b = d.querySelector('.tkall'); if (b) b.scrollTop = b.scrollHeight; }
  }, true);

  function scan() {
    var s = document.querySelector('.fostage[data-replay]:not([data-playing])');
    if (!s) return;
    if (active) active.finish();
    s.setAttribute('data-playing', '1');
    active = new Play(s);
    if (!active.done && !active.timers) active = null;   // dropped (no data / reduced motion)
  }
  function start() {
    scan();
    if (window.MutationObserver) new MutationObserver(function () { if (document.querySelector('.fostage[data-replay]:not([data-playing])')) scan(); }).observe(document.body, { childList: true, subtree: true });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
