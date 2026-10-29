/* Cat Fish: keeps the Kibble counter ticking and syncs with the server every 30 s. The server is the only authority; this only draws. */
(function () {
  var el = document.getElementById('cf-data'); if (!el) return;
  var d = JSON.parse(el.textContent); if (!d.has) return;
  var kibble = document.getElementById('cf-kibble'), kph = document.getElementById('cf-kph');
  var shown = d.kibble, rate = d.kph, frac = 0;
  function draw() { kibble.textContent = Math.floor(shown).toLocaleString(); kph.textContent = rate; refreshButtons(); }
  function refreshButtons() {
    document.querySelectorAll('button[data-cost]').forEach(function (b) { b.disabled = Math.floor(shown) < +b.getAttribute('data-cost'); });
  }
  function post(data, done) {
    var fd = new FormData(); fd.append('csrf', d.csrf); Object.keys(data).forEach(function (k) { fd.append(k, data[k]); });
    fetch(d.api, { method: 'POST', body: fd, credentials: 'same-origin' }).then(function (r) { return r.json(); }).then(done).catch(function () {});
  }
  function apply(view) {
    shown = view.kibble; rate = view.kph; draw();
    view.ups.forEach(function (u) {
      var f = document.querySelector('#cf-ups form[data-key="' + u.key + '"]'); if (!f) return;
      f.querySelector('small.muted').textContent = '×' + u.owned;
      f.querySelector('.cfgives').textContent = u.gives + (u.mult > 1 ? ' · ×' + u.mult + ' bonus' : '');
      var b = f.querySelector('button'); b.setAttribute('data-cost', u.cost); b.textContent = 'Buy · ' + u.cost.toLocaleString();
    });
    var run = document.getElementById('cf-run'); if (run) {
      run.textContent = view.run.toLocaleString(); document.getElementById('cf-napyarn').textContent = view.nap_yarn;
      document.getElementById('cf-napform').hidden = view.nap_yarn < 1; document.getElementById('cf-napneed').hidden = view.nap_yarn >= 1;
    }
    refreshButtons();
  }
  function say(text, bad) { var m = document.getElementById('cf-msg'); if (!m) return; m.textContent = text || ''; m.className = bad ? 'flash err' : 'flash ok'; }
  setInterval(function () { shown += rate / 3600; draw(); }, 1000);
  function sync() { if (document.hidden) return; post({ do: 'tick' }, function (r) { if (r.ok) apply(r.view); else say(r.error, true); }); }
  setInterval(sync, 30000);
  document.addEventListener('visibilitychange', function () { if (!document.hidden) sync(); });
  document.getElementById('cf-ups').addEventListener('submit', function (ev) {
    var f = ev.target; if (!f.matches('form.cfup')) return;
    ev.preventDefault();
    post({ do: 'buy', key: f.getAttribute('data-key') }, function (r) { if (r.view) apply(r.view); say(r.message || r.error, !r.ok); });
  });
})();

/* Play scene (decorative only): the active cat in the stage (.cfactive, see catfish_stage_html) swaps its frame group by moving one class (fr-<frame>)
   and mirrors it in data-frame. It never touches Kibble: the counter above and the server tick stay the only authority.
   Idle: idleA <-> idleB every 1.2-2.4 s. Every 6-9 s of idling: a play loop wiggle .6 s, stalk .8 s, pounce .4 s, catch 1.2 s (the fish toy), back to idleA;
   after the first one, one time in four it sits bored for 3 s instead. A freshly napped cat (data-nap, until the first Kibble of the new run) and the Nap button show nap.
   prefers-reduced-motion: idleA only, nothing moves. The random numbers come from the cat's seed, so a page load plays the same sequence every time. */
(function () {
  var cat = document.querySelector('.cfactive'); if (!cat) return;
  var have = {}; [].forEach.call(cat.querySelectorAll('.cfframe'), function (f) { have[f.getAttribute('data-f')] = true; });
  var cur = cat.getAttribute('data-frame'), timer = 0, napping = cat.getAttribute('data-nap') === '1';
  var a = (parseInt(cat.getAttribute('data-seed'), 10) || 1) >>> 0;
  function rnd() { a = (a + 0x6D2B79F5) >>> 0; var t = a; t = Math.imul(t ^ (t >>> 15), t | 1); t ^= t + Math.imul(t ^ (t >>> 7), t | 61); return ((t ^ (t >>> 14)) >>> 0) / 4294967296; }
  function between(lo, hi) { return lo + rnd() * (hi - lo); }
  function show(f) {
    if (!have[f]) f = have.idleA ? 'idleA' : cur;
    if (f === cur) return;
    cat.classList.remove('fr-' + cur); cat.classList.add('fr-' + f); cat.setAttribute('data-frame', f); cur = f;
  }
  function later(ms, fn) { timer = setTimeout(fn, ms); }
  var idled = 0, plays = 0, nextPlay = between(6000, 9000);
  var PLAY = [['wiggle', 600], ['stalk', 800], ['pounce', 400], ['catch', 1200]];
  function play(i) {
    if (i >= PLAY.length) { show('idleA'); return later(between(1200, 2400), idle); }
    show(PLAY[i][0]); later(PLAY[i][1], function () { play(i + 1); });
  }
  function idle() {
    if (napping) { show('nap'); return later(1000, idle); }
    if (idled >= nextPlay) {
      idled = 0; nextPlay = between(6000, 9000);
      if (plays++ > 0 && rnd() < 0.25) { show('bored'); return later(3000, function () { show('idleA'); later(between(1200, 2400), idle); }); }
      return play(0);
    }
    var ms = between(1200, 2400);
    show(cur === 'idleA' ? 'idleB' : 'idleA');
    idled += ms; later(ms, idle);
  }
  var mq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : null;
  function start() {
    clearTimeout(timer);
    if (mq && mq.matches) { show(napping ? 'nap' : 'idleA'); return; }
    show(napping ? 'nap' : 'idleA'); later(between(1200, 2400), idle);
  }
  start();
  if (mq && mq.addEventListener) mq.addEventListener('change', start);
  var nf = document.getElementById('cf-napform');
  if (nf) nf.addEventListener('submit', function () { napping = true; show('nap'); });
  var run = document.getElementById('cf-run');
  if (run && window.MutationObserver) new MutationObserver(function () {
    if (napping && parseInt(run.textContent.replace(/\D/g, ''), 10) > 0) { napping = false; idled = 0; start(); }
  }).observe(run, { childList: true, characterData: true, subtree: true });
})();
