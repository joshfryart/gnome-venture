/* v2.4.0: crafting scene popovers (craft_pop_html in includes/craft_map.php).
   A plain tap on a scene object opens its <dialog>: tabs Can craft / Missing / Unknown, craft right there. Without this script the hotspot is still
   a link (?o=) that filters the shelf list. Esc, the X and a tap outside close it; focus goes back to the object. No inline styles (CSP). */
(function () {
  'use strict';
  var back = null;
  document.addEventListener('click', function (ev) {
    var t = ev.target;
    if (!t.closest) return;
    var hs = t.closest('a.cmap-hs[data-pop]');
    if (hs && !ev.ctrlKey && !ev.metaKey && !ev.shiftKey && ev.button === 0) {
      var d = document.getElementById(hs.getAttribute('data-pop'));
      if (d && window.gvOpenDlg) { ev.preventDefault(); back = hs; gvOpenDlg(d); }
      return;
    }
    var dlg = t.closest('dialog.craftpop');
    if (!dlg) return;
    if (t.closest('[data-pop-close]') || t === dlg) { gvCloseDlg(dlg); return; }   // the X, or the dimmed area around the box
    var tab = t.closest('.cptab');
    if (tab) {
      var k = tab.getAttribute('data-ptab');
      dlg.querySelectorAll('.cptab').forEach(function (b) { b.setAttribute('aria-selected', b === tab ? 'true' : 'false'); });
      dlg.querySelectorAll('.cppanel').forEach(function (p) { p.hidden = p.getAttribute('data-ppanel') !== k; });
    }
  });
  // 'close' does not bubble, so listen in the capture phase
  document.addEventListener('close', function (ev) {
    if (ev.target.classList && ev.target.classList.contains('craftpop') && back) { try { back.focus(); } catch (e) {} back = null; }
  }, true);
})();
