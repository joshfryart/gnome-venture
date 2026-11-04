/* Graphical navigation: the picture pages (includes/hub_scene.php). A tap on a hotspot opens its card as a <dialog>; without this script
   the hotspot is still a link (?o=<id>) and the card shows under the picture. Hover or focus on a hotspot lights its legend chip and back.
   Esc, the X and a tap outside close the card; focus goes back to the hotspot. No inline styles or scripts (CSP), no body scroll lock. */
(function () {
  'use strict';
  var back = null;
  function plain(ev) { return !ev.ctrlKey && !ev.metaKey && !ev.shiftKey && ev.button === 0; }
  document.addEventListener('click', function (ev) {
    var t = ev.target;
    if (!t.closest) return;
    var hs = t.closest('[data-pop]');
    if (hs && hs.closest('.hubscene, .gnavtools, .trailui') && plain(ev)) {
      var d = document.getElementById(hs.getAttribute('data-pop'));
      if (d && window.gvOpenDlg) {
        ev.preventDefault();
        document.querySelectorAll('dialog.hubpop[open]').forEach(function (o) { if (o !== d) { if (o.close) o.close(); else o.removeAttribute('open'); } });   // one card at a time
        if (d.hasAttribute('open') && !d.matches(':modal')) d.removeAttribute('open');   // a no-JS card shown inline: reopen it as a real modal
        back = hs; gvOpenDlg(d);
      }
      return;
    }
    var dlg = t.closest('dialog.hubpop');
    if (!dlg) return;
    if (t.closest('[data-pop-close]')) { ev.preventDefault(); gvCloseDlg(dlg); return; }
    if (t === dlg) gvCloseDlg(dlg);   // the dimmed area around the box
  });
  function link(ev, on) {
    var t = ev.target;
    if (!t.closest) return;
    var a = t.closest('a.hs, a.hubchip');
    if (!a) return;
    var id = a.classList.contains('hs') ? a.id : a.getAttribute('data-for');
    var other = a.classList.contains('hs') ? document.querySelector('a.hubchip[data-for="' + id + '"]') : document.getElementById(id);
    if (other && other.classList) other.classList.toggle('lit', on);
  }
  document.addEventListener('mouseover', function (ev) { link(ev, true); });
  document.addEventListener('mouseout', function (ev) { link(ev, false); });
  document.addEventListener('focusin', function (ev) { link(ev, true); });
  document.addEventListener('focusout', function (ev) { link(ev, false); });
  document.addEventListener('close', function (ev) {   // 'close' does not bubble: capture phase
    if (ev.target.classList && ev.target.classList.contains('hubpop') && back) { try { back.focus(); } catch (e) {} back = null; }
  }, true);
  /* The encounter on a Trail walk is a popover that cannot be dismissed until it is settled: open it as a real modal on load and after an in-place page swap. */
  function trailPops() {
    document.querySelectorAll('dialog.trailpop').forEach(function (d) {
      if (d.getAttribute('data-up')) return;
      d.setAttribute('data-up', '1');
      d.addEventListener('cancel', function (ev) { ev.preventDefault(); });   // Esc does nothing
      if (d.showModal && !d.matches(':modal')) { try { d.close(); d.showModal(); } catch (e) {} }
    });
  }
  document.addEventListener('DOMContentLoaded', trailPops);
  document.addEventListener('gv:swapped', trailPops);
  trailPops();
})();
