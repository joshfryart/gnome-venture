/* Puzzle box page: keep the "N of CAP packed" count and stop ticking past the capacity. The server checks it all again. */
(function () {
  var root = document.getElementById('pbox'); if (!root) return;
  var cap = parseInt(root.dataset.cap || '8', 10), n = document.getElementById('pbox-n');
  var boxes = Array.prototype.slice.call(root.querySelectorAll('input[type=checkbox]'));
  function count() { var c = boxes.filter(function (b) { return b.checked; }).length; n.textContent = String(c); boxes.forEach(function (b) { b.disabled = !b.checked && c >= cap; }); }
  boxes.forEach(function (b) { b.addEventListener('change', count); });
  count();
})();

/* Offers are native <dialog open> elements (they show inline without JS); with JS they become a modal so the choice has the whole screen. */
(function () {
  var d = document.querySelector('dialog.pbox-offer');
  if (d && typeof d.showModal === 'function') { d.removeAttribute('open'); try { d.showModal(); } catch (e) { d.setAttribute('open', ''); } }
})();
