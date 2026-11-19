/* The interactive hovel room on the slim home's Today tab (includes/home_slim.php: hovel_room_svg() with 'things').
   Every thing in the picture is a real link, so the room works without this file: the bed, the window and the kettle open their
   dialogs through site.js (data-hdlg), the door is a plain link. This file only adds looks, nothing is saved:
   a card opened from the picture sits next to its thing, the first-look hint goes away on a tap,
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

  /* The bed's and the window's cards open next to their thing (site.js opens the dialog; this only moves it).
     Below the thing when it fits, else above, else it stays centred. Closing or resizing puts it back to centred. */
  function unanchor(d) { d.classList.remove('hpop-at'); d.style.left = ''; d.style.top = ''; }
  function anchor(a, d) {
    if (!d.open || !d.matches || !d.matches(':modal')) return;
    var hit = a.querySelector('.ht-out') || a, t = hit.getBoundingClientRect(), vw = window.innerWidth, vh = window.innerHeight, gap = 8, pad = 12;
    d.classList.add('hpop-at');
    var b = d.getBoundingClientRect(), top;
    if (t.bottom + gap + b.height <= vh - pad) top = t.bottom + gap;
    else if (t.top - gap - b.height >= pad) top = t.top - gap - b.height;
    else { unanchor(d); return; }
    d.style.left = Math.round(Math.max(pad, Math.min(t.left + t.width / 2 - b.width / 2, vw - b.width - pad))) + 'px';
    d.style.top = Math.round(top) + 'px';
    if (!d.hrBound) { d.hrBound = 1; d.addEventListener('close', function () { unanchor(d); }); }
  }
  window.addEventListener('resize', function () {
    var l = document.querySelectorAll('dialog.hpop-at'); for (var i = 0; i < l.length; i++) unanchor(l[i]);
  });
  document.addEventListener('click', function (ev) {   // any thing tapped: the hint has done its job; a card opened from the picture is moved to its thing
    var a = closest(ev.target, '.hs-room a.ht, .hs-room a.hd');
    if (!a) return;
    var hint = closest(a, '.hs-pic'); hint = hint && hint.querySelector('.hs-hint');
    if (hint) hint.hidden = true;
    var id = a.getAttribute('data-hdlg'), d = id && document.getElementById(id);
    if (d && d.classList.contains('hpop')) setTimeout(function () { anchor(a, d); }, 0);
  });

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
