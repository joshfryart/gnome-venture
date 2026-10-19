/* Gnome Venture v1.4.7: Lost Letters polish. Vanilla JS, no libraries.
   The server still decides every postmark read and every find. This file only adds feel: when you find the letter its flap
   opens, the paper slides out and petals fall; reading the postmark stamps it; and a fast second tap on a button can't
   turn into a full page reload. */
(function () {
  'use strict';
  var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  var prev = null;   // what the last letter looked like: { found, hint }

  function petals() {
    if (rmq.matches) return;
    for (var i = 0; i < 30; i++) {
      var p = document.createElement('span');
      p.className = 'petal p' + (i % 4);
      p.style.setProperty('--x', Math.round(Math.random() * 100) + 'vw');
      p.style.setProperty('--dx', Math.round(Math.random() * 120 - 60) + 'px');
      p.style.setProperty('--r', Math.round(240 + Math.random() * 420) + 'deg');
      p.style.setProperty('--t', (2.2 + Math.random() * 1.4).toFixed(2) + 's');
      p.style.setProperty('--dl', (Math.random() * 0.6).toFixed(2) + 's');
      document.body.appendChild(p);
      setTimeout(function (q) { return function () { if (q.parentNode) q.parentNode.removeChild(q); }; }(p), 4400);
    }
  }

  function initDesk(desk) {
    desk.classList.add('on');
    var found = desk.getAttribute('data-found') === '1', hint = desk.getAttribute('data-hint') === '1';
    var stage = desk.querySelector('.envstage');
    if (prev && !rmq.matches) {
      if (!prev.found && found && stage) {   // the stone was lifted: the envelope opens now
        stage.classList.remove('open');
        void stage.getBoundingClientRect();
        setTimeout(function () { if (stage.isConnected) { stage.classList.add('open'); } }, 60);
        setTimeout(petals, 750);
        desk.classList.add('justfound');
      } else if (!prev.hint && hint) {   // the postmark was read: stamp it
        desk.classList.add('stamping');
      }
    }
    prev = { found: found, hint: hint };
  }

  function initForm(form) {
    form.classList.add('on');
    var guard = 0;
    form.addEventListener('submit', function (ev) {
      if (form.getAttribute('data-wait') === '1' && Date.now() - guard < 8000) { ev.preventDefault(); return; }   // still sending the first tap
      form.setAttribute('data-wait', '1'); guard = Date.now();
      var b = form.querySelector('button');
      if (b) b.classList.add('pressed');
    });
  }

  function scan() {
    if (!document.querySelector('.letterdesk') && !document.querySelector('.letterform')) prev = null;
    document.querySelectorAll('.letterdesk:not(.on)').forEach(initDesk);
    document.querySelectorAll('.letterform:not(.on)').forEach(initForm);
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
})();
