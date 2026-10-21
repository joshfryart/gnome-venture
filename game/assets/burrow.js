/* Gnome Venture v2.1: Burrow Sorting. Vanilla JS, no libraries.
   The server decides every knock and keeps the answer; this file only helps you place the five neighbours.
   Tap a neighbour (it gets the selected state), then tap a door to put them there. Tapping a door that holds someone
   swaps them; tapping a placed neighbour with nothing selected picks them up again. Without JS the <select> boxes work. */
(function () {
  'use strict';

  function init(form) {
    form.classList.add('on');
    var doors = [].slice.call(form.querySelectorAll('.bslot'));
    var chips = [].slice.call(form.querySelectorAll('.bchip'));
    var selects = [].slice.call(form.querySelectorAll('select'));
    var knock = form.querySelector('.bknock');
    var clear = form.querySelector('.bclear');
    var help = form.querySelector('.burrowhelp');
    var n = doors.length;
    var place = [], sel = -1, i;

    for (i = 0; i < n; i++) {
      var v = selects[i] ? parseInt(selects[i].value, 10) : NaN;
      place.push(isNaN(v) ? -1 : v);
    }
    var chipOf = function (c) { for (var k = 0; k < chips.length; k++) if (parseInt(chips[k].getAttribute('data-c'), 10) === c) return chips[k]; return null; };

    function render() {
      var full = true;
      for (var d = 0; d < n; d++) {
        var c = place[d], slot = doors[d], inner = slot.querySelector('.bslotin');
        var label = slot.getAttribute('data-label') || ('Door ' + (d + 1));
        if (selects[d]) selects[d].value = c < 0 ? '' : String(c);
        if (c < 0) {
          full = false;
          inner.textContent = '?';
          slot.classList.remove('filled');
          slot.setAttribute('aria-label', label + ', empty' + (sel >= 0 ? '. Tap to put the chosen neighbour here' : ''));
        } else {
          var chip = chipOf(c);
          inner.textContent = '';
          if (chip) [].forEach.call(chip.childNodes, function (nd) { inner.appendChild(nd.cloneNode(true)); });   // copy the server's icon + name
          slot.classList.add('filled');
          slot.setAttribute('aria-label', label + ', ' + (chip ? chip.getAttribute('data-name') : '') + (sel >= 0 ? '. Tap to swap' : '. Tap to pick up'));
        }
        slot.setAttribute('aria-pressed', 'false');
      }
      chips.forEach(function (ch) {
        var c = parseInt(ch.getAttribute('data-c'), 10);
        var at = place.indexOf(c);
        ch.setAttribute('aria-pressed', c === sel ? 'true' : 'false');
        ch.classList.toggle('placed', at > -1);
        ch.classList.toggle('picked', c === sel);
        ch.setAttribute('aria-label', ch.getAttribute('data-name') + (at > -1 ? ', at door ' + (at + 1) : ', not placed') + (c === sel ? ', chosen' : ''));
      });
      if (knock) knock.disabled = !full || form.getAttribute('data-done') === '1';
      if (help) help.textContent = sel >= 0 ? 'Now tap a door.' : (full ? 'Everyone is placed. Knock when you are ready.' : 'Tap a neighbour, then tap a door to put them there.');
    }

    chips.forEach(function (ch) {
      ch.addEventListener('click', function () {
        var c = parseInt(ch.getAttribute('data-c'), 10);
        sel = sel === c ? -1 : c;
        render();
      });
    });
    doors.forEach(function (slot, d) {
      slot.addEventListener('click', function () {
        if (sel >= 0) {
          var from = place.indexOf(sel), other = place[d];
          place[d] = sel;
          if (from > -1 && from !== d) place[from] = other;   // swap with whoever was there
          sel = -1;
        } else if (place[d] >= 0) {
          sel = place[d];   // pick them up again
          place[d] = -1;
        }
        render();
      });
    });
    if (clear) clear.addEventListener('click', function () {
      for (var d = 0; d < n; d++) place[d] = -1;
      sel = -1;
      render();
    });
    form.addEventListener('submit', function (ev) {
      if (place.indexOf(-1) > -1) { ev.preventDefault(); return; }
      if (form.getAttribute('data-done') === '1') { ev.preventDefault(); return; }   // a fast second tap must not knock twice
      form.setAttribute('data-done', '1');
      if (knock) knock.disabled = true;
    });
    render();
  }

  function scan() {
    document.querySelectorAll('.burrowform:not(.on)').forEach(init);
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
})();
