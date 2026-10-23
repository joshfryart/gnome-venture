/* v2.0.38: the shell helper for one-screen pages. GVShell.post(url, fields) sends a form post with the CSRF token and
   returns the parsed JSON (never reloads). GVShell.html(el, str) swaps a panel's content from the server's own HTML.
   <meta name="csrf"> is not used: the token comes from data-csrf on the shell element. */
(function () {
  'use strict';
  var shell = {
    csrf: function () {
      var el = document.querySelector('[data-csrf]');
      return el ? el.getAttribute('data-csrf') : '';
    },
    post: function (url, fields) {
      var fd = new FormData();
      fd.append('csrf', shell.csrf());
      Object.keys(fields || {}).forEach(function (k) { fd.append(k, fields[k]); });
      return fetch(url, { method: 'POST', body: fd, credentials: 'same-origin', headers: { 'Accept': 'application/json', 'X-Requested-With': 'fetch' } })
        .then(function (r) { return r.json().catch(function () { return { ok: false, msg: 'The server sent something unexpected. Refresh and try again.' }; }); })
        .catch(function () { return { ok: false, msg: 'Could not reach the server. Check your connection and try again.' }; });
    },
    html: function (el, str) { el.innerHTML = str; }   // only ever pass HTML the server built with e()
  };
  window.GVShell = shell;
})();
