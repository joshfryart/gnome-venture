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
