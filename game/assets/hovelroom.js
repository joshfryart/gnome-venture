/* The interactive hovel room on the slim home's Today tab (includes/home_slim.php: hovel_room_svg() with 'things').
   Every thing in the picture is a real link, so the room works without this file: the bed, the window and the kettle open their
   dialogs through site.js (data-hdlg), the door is a plain link. This file only adds two looks, nothing is saved:
   the lamp (a[data-hlamp]) switches the light, the gnome (a[data-hsay]) hops and says a line.
   Listeners sit on the document, so they survive the in-place page swaps (AJAX_PAGES). */
(function () {
  'use strict';
  var sayTimer = 0, sayAt = 0;

  function closest(el, sel) { return el && el.closest ? el.closest(sel) : null; }

  function lamp(a) {
    var svg = closest(a, 'svg.hroom');
    if (!svg) return;
    var on = !svg.classList.contains('lamp-on');
    svg.classList.toggle('lamp-on', on);
    a.setAttribute('aria-pressed', on ? 'true' : 'false');
  }

  function say(a) {
    var pic = closest(a, '.hs-pic'), box = pic && pic.querySelector('.hs-say'), lines = [];
    try { lines = JSON.parse(a.getAttribute('data-hsay') || '[]'); } catch (e) { lines = []; }
    var g = pic && pic.querySelector('.hr-gnome');
    if (g) {   // restart the hop
      g.classList.remove('hop');
      void g.getBoundingClientRect();
      g.classList.add('hop');
    }
    if (!box || !lines.length) return;
    box.textContent = String(lines[sayAt % lines.length]);   // text only: the line is never markup
    sayAt++;
    box.hidden = false;
    clearTimeout(sayTimer);
    sayTimer = setTimeout(function () { box.hidden = true; }, 2800);
  }

  document.addEventListener('click', function (ev) {
    if (ev.defaultPrevented || ev.button !== 0 || ev.ctrlKey || ev.metaKey || ev.shiftKey || ev.altKey) return;
    var a = closest(ev.target, 'a[data-hlamp]');
    if (a) { ev.preventDefault(); lamp(a); return; }
    a = closest(ev.target, 'a[data-hsay]');
    if (a) { ev.preventDefault(); say(a); }
  });
  document.addEventListener('keydown', function (ev) {   // role="button": Space presses it too
    if (ev.key !== ' ' && ev.key !== 'Spacebar') return;
    var a = closest(ev.target, 'a[data-hlamp]');
    if (a) { ev.preventDefault(); lamp(a); }
  });
})();
