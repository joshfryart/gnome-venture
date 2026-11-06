/* v2.4.96: welcome flow, step 2: show the basket of the picked village. Without script the server already shows the checked one. */
(function () {
  'use strict';
  var form = document.querySelector('.wbaskets');
  if (!form) return;
  document.addEventListener('change', function (ev) {
    var input = ev.target;
    if (!input || input.name !== 'village_id') return;
    form.querySelectorAll('.wbgroup').forEach(function (g) {
      g.hidden = g.getAttribute('data-village') !== input.value;   // un-hiding restarts the CSS pop-in
    });
  });
})();
