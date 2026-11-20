/* The Garden Yard picture (includes/gyard.php): a tap on a building (or a "ready" chip) opens its card as a <dialog>. Without this script the building
   is still a link (garden.php?t=pic&o=<key>) and the card shows open under the picture. Esc, the X and a tap outside close the card; the building
   keeps a gold dashed outline while its card is open. No inline styles or scripts (CSP). */
(function () {
  'use strict';
  var lit = null;
  function plain(ev) { return !ev.ctrlKey && !ev.metaKey && !ev.shiftKey && ev.button === 0; }
  function open(d) {
    if (!d) return;
    document.querySelectorAll('dialog.gycard[open]').forEach(function (o) { if (o !== d) { if (o.close) o.close(); else o.removeAttribute('open'); } });
    if (d.hasAttribute('open') && d.matches && !d.matches(':modal')) d.removeAttribute('open');   // a no-script card shown inline: reopen it as a real modal
    if (window.gvOpenDlg) window.gvOpenDlg(d); else if (d.showModal) d.showModal(); else d.setAttribute('open', '');
  }
  function close(d) {
    if (window.gvCloseDlg) window.gvCloseDlg(d); else if (d.close) d.close(); else d.removeAttribute('open');
    if (lit) { lit.classList.remove('on'); lit = null; }
  }
  document.addEventListener('click', function (ev) {
    var t = ev.target;
    if (!t.closest) return;
    var hs = t.closest('.gyard [data-pop]');
    if (hs && plain(ev)) {
      var d = document.getElementById(hs.getAttribute('data-pop'));
      if (!d) return;
      ev.preventDefault();
      if (lit) lit.classList.remove('on');
      lit = hs.classList.contains('gy-hit') ? hs : document.querySelector('.gy-hit[data-pop="' + hs.getAttribute('data-pop') + '"]');
      if (lit) lit.classList.add('on');
      open(d);
      return;
    }
    var dlg = t.closest('dialog.gycard');
    if (!dlg) return;
    if (t.closest('[data-pop-close]')) { ev.preventDefault(); close(dlg); return; }
    if (t === dlg) close(dlg);
  });
  document.addEventListener('close', function (ev) {
    if (ev.target && ev.target.classList && ev.target.classList.contains('gycard') && lit) { lit.classList.remove('on'); lit = null; }
  }, true);
})();
