/* v2.0.39: Villagers page. Click a card: the detail panel opens above the grid without a reload. Chat/gift/deal forms post in place. Without JS every link and form still works. */
(function () {
  'use strict';
  var shell = document.getElementById('vshell');
  if (!shell) return;
  var panel = document.getElementById('vpanel');
  var url = shell.getAttribute('data-url');
  var csrf = shell.getAttribute('data-csrf');

  function show(res) {
    panel.innerHTML = res.html || '';
    if (!res.html && res.msg) { var p = document.createElement('p'); p.className = 'vmsg err'; p.textContent = res.msg; panel.appendChild(p); }
    panel.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
  }
  function ask(opts) {
    return fetch(opts.url, opts.init).then(function (r) { return r.json(); })
      .catch(function () { return { ok: false, msg: 'Could not reach the server. Check your connection and try again.', html: '' }; });
  }
  shell.addEventListener('click', function (e) {
    var a = e.target.closest('[data-vopen]');
    if (!a) return;
    e.preventDefault();
    var id = a.getAttribute('data-vopen');
    ask({ url: url + '?id=' + encodeURIComponent(id), init: { credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } } }).then(function (res) {
      show(res);
      if (res.ok && window.history && history.replaceState) history.replaceState(null, '', url + '?id=' + encodeURIComponent(id));
    });
  });
  shell.addEventListener('submit', function (e) {
    var f = e.target.closest('[data-vform]');
    if (!f) return;
    e.preventDefault();
    var fd = new FormData(f);
    fd.set('csrf', csrf);
    var b = f.querySelector('button'); if (b) b.disabled = true;
    ask({ url: url, init: { method: 'POST', body: fd, credentials: 'same-origin', headers: { 'X-Requested-With': 'fetch' } } }).then(show);
  });
})();
