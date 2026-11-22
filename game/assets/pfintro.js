/* 2.7.57 Puzzle combat intro (includes/pfintro.php, CSS .pfi in assets/pfv1.css). One step at a time with Back / Next; Skip, Got it, Esc or a tap outside closes it
   and tells the server (the same form the page posts without script). The page under it is never blocked: closing only hides the card.
   [data-pfintro] anywhere (the fight's help sheet) opens it again. Runs again when the page content is swapped in place (data-rerun). */
(function () {
  var root = document.getElementById('pfi');
  if (!root || root.getAttribute('data-pfi-on') === '1') return;
  root.setAttribute('data-pfi-on', '1');
  root.classList.add('pfi-js');
  var card = root.querySelector('.pfi-card'), steps = root.querySelectorAll('.pfi-steps > .pfi-step'), dots = root.querySelectorAll('.pfi-dots i');
  var prev = root.querySelector('.pfi-prev'), next = root.querySelector('.pfi-next'), done = root.querySelector('.pfi-done'), form = root.querySelector('form');
  var at = 0, last = null, sent = root.getAttribute('data-seen') === '1';
  function show(i) {
    at = Math.max(0, Math.min(steps.length - 1, i));
    for (var k = 0; k < steps.length; k++) { steps[k].hidden = k !== at; if (dots[k]) dots[k].className = k === at ? 'on' : ''; }
    prev.hidden = at === 0; next.hidden = at === steps.length - 1; done.hidden = at !== steps.length - 1;
  }
  function open() {
    last = document.activeElement; root.hidden = false; show(0);
    try { card.focus({ preventScroll: true }); } catch (e) { card.focus(); }
  }
  function close() {
    root.hidden = true;
    if (!sent && form) {   // the seen flag: once, quietly (a failed send only means the card comes back next time)
      sent = true; root.setAttribute('data-seen', '1');
      try { var fd = new FormData(form); fetch(form.action, { method: 'POST', body: fd, credentials: 'same-origin', headers: { 'X-Requested-With': 'pfintro' } }).catch(function () {}); } catch (e) {}
    }
    if (last && last.focus && document.contains(last)) { try { last.focus({ preventScroll: true }); } catch (e) {} }
  }
  form.addEventListener('submit', function (ev) { ev.preventDefault(); close(); });
  prev.addEventListener('click', function () { show(at - 1); });
  next.addEventListener('click', function () { show(at + 1); next.hidden ? done.focus() : next.focus(); });
  root.addEventListener('click', function (ev) { if (ev.target.closest('[data-pfi-x]')) close(); });
  document.addEventListener('keydown', function (ev) {
    if (root.hidden || !document.contains(root)) return;
    if (ev.key === 'Escape') { ev.preventDefault(); close(); }
    else if (ev.key === 'ArrowRight' && !next.hidden) show(at + 1);
    else if (ev.key === 'ArrowLeft' && !prev.hidden) show(at - 1);
  });
  document.addEventListener('click', function (ev) {
    var t = ev.target.closest && ev.target.closest('[data-pfintro]');
    if (!t || !document.contains(root)) return;
    ev.preventDefault(); open();
  });
  if (root.hidden) show(0); else open();
})();
