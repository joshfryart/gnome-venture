/* v0.9.6: marks the page as script-capable before it is drawn, so the wide-screen layout can settle without a jump. */
document.documentElement.className += ' js';
/* v1.6.5: dark/light. The server writes data-theme (what to show) and data-pref (dark, light or auto). 'auto' follows the phone; this runs before the first paint.
   The switch buttons (form.themeform) flip the page at once and save in the background; without JS they post to theme.php and reload. */
(function () {
  var d = document.documentElement;
  var mq = window.matchMedia ? window.matchMedia('(prefers-color-scheme: light)') : null;
  function show() {
    var p = d.getAttribute('data-pref');
    var t = p === 'auto' ? (mq && mq.matches ? 'light' : 'dark') : (p === 'light' ? 'light' : 'dark');
    d.setAttribute('data-theme', t);
    var m = document.querySelector('meta[name="color-scheme"]');
    if (m) m.setAttribute('content', t);
  }
  show();
  if (mq) { if (mq.addEventListener) mq.addEventListener('change', show); else if (mq.addListener) mq.addListener(show); }
  document.addEventListener('submit', function (ev) {
    var f = ev.target, s = ev.submitter;
    if (!f || !f.classList || !f.classList.contains('themeform') || !s || s.name !== 'theme' || !window.fetch || !window.FormData || !window.URLSearchParams) return;
    ev.preventDefault();
    d.setAttribute('data-pref', s.value);
    show();
    document.querySelectorAll('.themechoice button[name="theme"]').forEach(function (b) { b.setAttribute('aria-pressed', b.value === s.value ? 'true' : 'false'); });
    var fd = new FormData(f);
    fd.set('theme', s.value);
    fd.set('ajax', '1');
    fetch(f.action, { method: 'POST', body: new URLSearchParams(fd), credentials: 'same-origin' })
      .then(function (r) { if (!r.ok) location.reload(); })
      .catch(function () {});
  });
})();

/* v2.3.94: a form that was just sent cannot be sent again for 2 seconds (double taps on Buy, Sell, Harvest...).
   v2.3.96: it is only counted as "sent" once nothing cancelled the submit. The confirm dialog (site.js) stops its first submit and re-submits on OK,
   which the first version of this guard swallowed (Back up and install did nothing). */
document.addEventListener('submit', function (ev) {
  var f = ev.target;
  if (!f || !f.tagName) return;
  if (f.getAttribute('data-sent') && Date.now() - Number(f.getAttribute('data-sent')) < 2000) { ev.preventDefault(); ev.stopImmediatePropagation(); }
}, true);
window.addEventListener('submit', function (ev) {
  var f = ev.target;
  if (!f || !f.tagName || ev.defaultPrevented) return;
  f.setAttribute('data-sent', String(Date.now()));
});

/* Helpers the small game scripts share (memory, mushroom, worms, marrow, race). Non-deferred, so window.gvFx exists before any of them run. */
window.gvFx = {
  rmq: window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false },
  centre: function (el) { var r = el.getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; },
  seenGet: function (key) { try { return window.localStorage.getItem(key); } catch (e) { return null; } },
  seenSet: function (key, v) { try { window.localStorage.setItem(key, v); } catch (e) { /* private mode: replay next time */ } }
};
