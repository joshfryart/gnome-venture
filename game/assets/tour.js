/* v2.4.97: Wren's tour as a speech bubble. The server prints #wrentour (the card, plus data-targets: [[CSS selector, hint], ...] most specific first).
   This turns the card into a bubble above the bottom bar and rings the first target that is on screen. Nothing is blocked: the player's own tap does the job,
   the page (or the in-place swap) reloads, the server has moved the step on, and the bubble aims at the next thing. No script: the card stays as a plain card. */
(function () {
  var lastKey = '', hl = null, busy = false;
  function visible(el) {
    if (!el || !el.getClientRects().length) return false;
    var r = el.getBoundingClientRect();
    return r.width > 0 && r.height > 0 && r.right > 0 && r.left < window.innerWidth;   // a closed side menu sits off to the side
  }
  function pick(list) {
    for (var i = 0; i < list.length; i++) {
      var el = null;
      try { el = document.querySelector(list[i][0]); } catch (e) { el = null; }   // :has() on an old browser: skip it
      if (!el) continue;
      if (el.closest && el.closest('#sidenav') && !visible(el)) {   // the tile is in the closed menu: point at More first
        var more = document.querySelector('.bottombar .menubtn.more');
        if (visible(more)) return [more, 'Tap More, then ' + (list[i][1] || 'the glowing tile').charAt(0).toLowerCase() + (list[i][1] || '').slice(1)];
        continue;
      }
      if (visible(el)) return [el, list[i][1] || ''];
    }
    return null;
  }
  function clear() { if (hl) { hl.classList.remove('tourhl'); hl = null; } }
  function aim() {
    if (busy) return; busy = true;
    try {
      clear();
      var box = document.getElementById('wrentour');
      document.body.classList.toggle('tourbub', !!box);
      if (!box) return;
      box.classList.add('tour-on');
      var arr = box.querySelector('.tourarr'), cur = box.querySelector('.tourcur'), hint = box.querySelector('.tourhint');
      if (arr && !arr.getAttribute('data-done')) {   // a visit step's words first, then the next step
        if (cur) cur.hidden = true;
        if (!arr.querySelector('.tourgot')) {
          var b = document.createElement('button'); b.type = 'button'; b.className = 'btn small tourgot'; b.textContent = 'Next ›';
          b.addEventListener('click', function () { arr.setAttribute('data-done', '1'); arr.hidden = true; if (cur) cur.hidden = false; aim(); });
          arr.lastElementChild.appendChild(b);
        }
        return;
      }
      if (arr) arr.hidden = true;
      if (cur) cur.hidden = false;
      var t = []; try { t = JSON.parse(box.getAttribute('data-targets') || '[]'); } catch (e) { t = []; }
      var m = pick(t);
      if (hint) hint.textContent = m ? m[1] : '';
      if (!m) return;
      hl = m[0]; hl.classList.add('tourhl');
      var key = (box.getAttribute('data-step') || '') + '|' + (hl.id || hl.className || hl.tagName) + '|' + location.pathname + location.search;
      if (key !== lastKey) {   // scroll once per target so the player's own scrolling is not fought
        lastKey = key;
        var r = hl.getBoundingClientRect(), bub = box.getBoundingClientRect();
        var top = 60, bottom = (bub.height ? window.innerHeight - bub.height - 70 : window.innerHeight - 120);
        if (r.top < top || r.bottom > bottom) {
          try { hl.scrollIntoView({ block: 'center', behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth' }); } catch (e) { hl.scrollIntoView(); }
        }
      }
    } finally { busy = false; }
  }
  function soon() { clearTimeout(soon.t); soon.t = setTimeout(aim, 60); }
  document.addEventListener('gv:swapped', soon);
  window.addEventListener('resize', soon);
  document.addEventListener('click', function (e) { if (e.target.closest && e.target.closest('.menubtn')) setTimeout(aim, 350); });   // the menu opened or closed
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', soon); else soon();
})();
