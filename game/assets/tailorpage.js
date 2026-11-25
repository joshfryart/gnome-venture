/* v2.8.53: Tailor lists in the landscape dock: a few cards per page with Back / More. Everywhere else (and without script) the whole list shows. */
(function () {
  'use strict';
  var mq;
  try { mq = matchMedia('(orientation: landscape) and (max-height: 500px)'); } catch (e) { return; }
  var lists = [].slice.call(document.querySelectorAll('body.dock-on ul.rcards.tlr[data-tpage]'));
  if (!lists.length) return;
  lists.forEach(function (ul) {
    var size = parseInt(ul.getAttribute('data-tpage'), 10) || 3, page = 0, items = [].slice.call(ul.children);
    if (items.length <= size) return;
    var bar = document.createElement('div');
    bar.className = 'tlrpager';
    bar.innerHTML = '<button type="button" class="btn small alt" data-d="-1">Back</button><span></span><button type="button" class="btn small alt" data-d="1">More</button>';
    ul.parentNode.insertBefore(bar, ul.nextSibling);
    var pages = Math.ceil(items.length / size);
    function draw() {
      var on = mq.matches;
      bar.hidden = !on;
      items.forEach(function (li, i) { li.hidden = on && Math.floor(i / size) !== page; });
      bar.children[1].textContent = (page + 1) + ' / ' + pages;
      bar.children[0].disabled = page === 0;
      bar.children[2].disabled = page === pages - 1;
    }
    bar.addEventListener('click', function (ev) {
      var b = ev.target.closest('button[data-d]');
      if (!b) return;
      page = Math.max(0, Math.min(pages - 1, page + parseInt(b.getAttribute('data-d'), 10)));
      draw();
    });
    if (mq.addEventListener) mq.addEventListener('change', draw);
    draw();
  });
})();
