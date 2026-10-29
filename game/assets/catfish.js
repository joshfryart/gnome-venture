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
