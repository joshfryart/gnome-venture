/* v2.0.77: villagers in an overlay. A Chat button or a villager's name (data-folk-npc = a townsfolk id, data-folk-stop = a rest-stop villager id)
   opens a dialog with the villager panel: chat, gift, errand, post in place. Without JS the same buttons are links and forms that still work.
   NPC panels come from villagers.php (fetch), stop villagers from stopfolk.php; their forms carry data-vform / data-sform. */
(function () {
  'use strict';
  var root = document.getElementById('folkov');
  if (!root) return;
  var csrf = root.getAttribute('data-csrf');
  var urls = { page: root.getAttribute('data-page'), npc: root.getAttribute('data-npc'), stop: root.getAttribute('data-stop') };
  var dlg, body, foot, kind = 'npc', changed = false;

  function build() {
    if (dlg) return;
    dlg = document.createElement('dialog');
    dlg.className = 'folkdlg';
    dlg.setAttribute('aria-label', 'Villager');
    dlg.innerHTML = '<button type="button" class="sheetx" aria-label="Close">✕</button><div class="folkbody" aria-live="polite"></div><p class="folkfoot"></p>';
    body = dlg.querySelector('.folkbody');
    foot = dlg.querySelector('.folkfoot');
    dlg.querySelector('.sheetx').addEventListener('click', function () { dlg.close(); });
    dlg.addEventListener('click', function (e) { if (e.target === dlg) dlg.close(); });   // a tap on the backdrop
    dlg.addEventListener('close', function () { if (changed) { changed = false; window.location.reload(); } });   // hearts and buttons on the page are stale now
    dlg.addEventListener('submit', function (e) {
      var f = e.target.closest('[data-vform],[data-sform]');
      if (!f) return;
      e.preventDefault();
      var fd = new FormData(f);
      fd.set('csrf', csrf);
      var b = f.querySelector('button'); if (b) b.disabled = true;
      ask(kind === 'stop' ? urls.stop : urls.npc, { method: 'POST', body: fd }).then(function (res) { show(res, true); });
    });
    document.body.appendChild(dlg);
  }
  function ask(url, init) {
    init = init || {};
    init.credentials = 'same-origin';
    init.headers = { 'X-Requested-With': 'fetch' };
    return fetch(url, init).then(function (r) { return r.json(); })
      .catch(function () { return { ok: false, msg: 'Could not reach the server. Check your connection and try again.', html: '' }; });
  }
  function show(res, posted) {
    body.innerHTML = res.html || '';
    if (!res.html) {
      var p = document.createElement('p'); p.className = 'vmsg err'; p.textContent = res.msg || 'They are not here.'; body.appendChild(p);
    }
    if (posted && res.ok) changed = true;
  }
  function open(k, id) {
    build();
    kind = k;
    changed = false;
    body.innerHTML = '<p class="muted">…</p>';
    foot.innerHTML = '';
    if (k === 'npc') {
      var a = document.createElement('a');
      a.href = urls.page + '?id=' + encodeURIComponent(id);
      a.textContent = 'See full details →';
      foot.appendChild(a);
    }
    if (!dlg.open) dlg.showModal();
    ask(urls[k] + '?' + (k === 'npc' ? 'id=' : 'folk=') + encodeURIComponent(id)).then(function (res) { show(res, false); });
  }
  document.addEventListener('click', function (e) {
    if (e.defaultPrevented || e.button || e.metaKey || e.ctrlKey || e.shiftKey) return;
    var n = e.target.closest ? e.target.closest('[data-folk-npc]') : null;
    var s = e.target.closest ? e.target.closest('[data-folk-stop]') : null;
    if (n && !(dlg && dlg.contains(n))) { e.preventDefault(); open('npc', n.getAttribute('data-folk-npc')); }
    else if (s) { e.preventDefault(); open('stop', s.getAttribute('data-folk-stop')); }
  });
})();
