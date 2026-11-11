/* Puzzle combat: sets the widths of the resolve bar fills (data-w is a percentage). No inline styles in the markup (CSP). */
(function () {
  Array.prototype.forEach.call(document.querySelectorAll('.pfx-fill[data-w]'), function (el) { el.style.width = el.getAttribute('data-w') + '%'; });
})();
