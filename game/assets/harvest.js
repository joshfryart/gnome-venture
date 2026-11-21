/* Harvest show: after the Harvest buttons, or on waking when a garden pal picked overnight, includes/harvest_show.php leaves a hidden .hvdata block
   (a card per plant picked, notes, XP, seeds). This shows it in a native <dialog> like the chest: a row of plants sits in the soil, each is
   pulled up in turn and flies into the basket (the count ticks), then the numbers and any garden status chips appear.
   Button, backdrop tap, Escape or Android back closes. No JS: the block stays hidden. Reduced motion: the finished picture at once. Works after in-place swaps. */
(function () {
  var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var active = null;

  function el(tag, cls, text) { var n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; return n; }
  function pick(a) { return a[Math.floor(Math.random() * a.length)]; }
  function num(d, k) { return parseInt(d.getAttribute('data-' + k), 10) || 0; }

  function open(data) {
    if (active) active.close(true);
    var pal = data.getAttribute('data-src') === 'pal', who = data.getAttribute('data-who') || 'Your pal';
    var total = num(data, 'total'), xp = num(data, 'xp'), more = num(data, 'more');
    var seeds = data.getAttribute('data-seeds') || '', summary = data.getAttribute('data-summary') || '';
    var cards = Array.prototype.slice.call(data.querySelectorAll('li.hv-card'));
    var notes = Array.prototype.map.call(data.querySelectorAll('ol li'), function (li) { return li.textContent; });
    var st = document.querySelector('.gardenstat'), stat = null;   // garden status counts (garden page): they ride in this popover instead of their own pill
    if (st) { stat = {}; ['ready', 'thirsty', 'weedy', 'empty', 'grow'].forEach(function (k) { stat[k] = num(st, k); }); st.remove(); }
    var prevFocus = document.activeElement;
    var heading = pal ? who + ' is picking…' : 'Picking time!';
    var doneHeading = total >= 12 ? pick(['Basket overflowing!', 'Veg everywhere!']) : pal ? pick([who + ' did the picking!', 'Picked while you slept!']) : pick(['Harvest in!', 'Basket full!', 'Veg secured.']);

    var root = el('dialog', 'hvov');
    root.setAttribute('aria-label', 'The harvest');
    var back = el('div', 'hv-back'), box = el('div', 'hv-box');
    var title = el('h2', 'hv-title', heading);
    var field = el('div', 'hv-field'); field.setAttribute('aria-hidden', 'true');
    var basket = el('div', 'hv-basket'); basket.setAttribute('aria-hidden', 'true');
    var bico = el('span', 'hv-bico', '🧺'), bcount = el('b', 'hv-bcount', '0');
    basket.appendChild(bico); basket.appendChild(bcount);
    var sum = el('ul', 'hv-sum'), tally = el('p', 'hv-tally'), nl = el('ul', 'hv-notes');
    var live = el('p', 'hv-live'); live.setAttribute('aria-live', 'polite'); live.setAttribute('role', 'status');
    var ok = el('button', 'btn hv-ok', 'Yum!'); ok.type = 'button';

    var cells = cards.map(function (c, i) {
      var cell = el('div', 'hv-plant'), ico = el('span', 'hv-ico'), soil = el('i', 'hv-soil'), plus = el('b', 'hv-plus', '+' + c.getAttribute('data-qty'));
      Array.prototype.forEach.call(c.querySelector('.hv-ico').childNodes, function (n) { ico.appendChild(n.cloneNode(true)); });
      cell.style.setProperty('--i', i);
      cell.appendChild(plus); cell.appendChild(ico); cell.appendChild(soil);
      field.appendChild(cell);
      return cell;
    });
    if (more) field.appendChild(el('span', 'hv-more', '+' + more + ' more'));
    box.appendChild(title); box.appendChild(field); box.appendChild(basket); box.appendChild(sum); box.appendChild(tally); box.appendChild(nl); box.appendChild(live); box.appendChild(ok);
    root.appendChild(back); root.appendChild(box);
    data.remove();
    document.body.appendChild(root);
    if (root.showModal) root.showModal(); else root.setAttribute('open', '');

    var timers = [], closed = false, done = false;
    function later(fn, ms) { timers.push(setTimeout(fn, ms)); }

    // grouped totals per plant name, in order of first pick
    var groups = [], idx = {};
    cards.forEach(function (c) {
      var nm = c.querySelector('.hv-name').textContent, q = parseInt(c.getAttribute('data-qty'), 10) || 0;
      if (idx[nm] == null) { idx[nm] = groups.length; groups.push({ name: nm, qty: 0, icon: c.querySelector('.hv-ico') }); }
      groups[idx[nm]].qty += q;
    });
    function buildSummary() {
      groups.forEach(function (g) {
        var li = el('li', 'hv-card'), i = el('span', 'hv-ico'); Array.prototype.forEach.call(g.icon.childNodes, function (n) { i.appendChild(n.cloneNode(true)); });
        li.appendChild(i); li.appendChild(el('span', 'hv-name', g.name)); li.appendChild(el('b', 'hv-qty', '×' + g.qty));
        sum.appendChild(li);
      });
      var chips = [['🧺 ' + total + ' crop' + (total === 1 ? '' : 's')]];
      if (xp) chips.push(['⭐ +' + xp + ' XP']);
      if (seeds) chips.push(['🌱 ' + seeds]);
      if (stat) [['💧', 'thirsty', 'thirsty'], ['🧺', 'ready', 'still ripe'], ['🌿', 'weedy', 'weedy'], ['🟫', 'empty', 'bare'], ['🌱', 'grow', 'growing']].forEach(function (r) { if (stat[r[1]]) chips.push([r[0] + ' ' + stat[r[1]], stat[r[1]] + ' ' + r[2], 1]); });
      chips.forEach(function (c, i) { var s = el('span', 'hv-t' + (c[2] ? ' hv-st' : ''), c[0]); if (c[1]) s.title = c[1]; s.style.setProperty('--gi', i); tally.appendChild(s); });
      notes.forEach(function (m) { nl.appendChild(el('li', null, m)); });
    }
    function count(to, ms) {
      var t = null;
      (function tick(now) { if (t === null) t = now; var p = Math.min(1, (now - t) / ms); bcount.textContent = Math.round(to * (1 - Math.pow(1 - p, 3))); if (p < 1 && !closed && !done) requestAnimationFrame(tick); })(performance.now());
    }
    function close(quiet) {
      if (closed) return;
      closed = true;
      timers.forEach(clearTimeout);
      if (root.close && root.open) root.close();
      root.remove();
      if (active === api) active = null;
      if (!quiet) {
        var f = prevFocus && document.body.contains(prevFocus) ? prevFocus : document.getElementById('main');
        if (f && f.focus) f.focus({ preventScroll: true });
      }
    }
    function finish() {
      if (done) return;
      done = true;
      timers.forEach(clearTimeout);
      cells.forEach(function (c) { c.classList.add('in', 'gone'); });
      root.classList.add('hv-done');
      bcount.textContent = total;
      if (!sum.firstChild) buildSummary();
      title.textContent = doneHeading;
      live.textContent = summary;
    }
    root.addEventListener('cancel', function (ev) { ev.preventDefault(); close(); });
    root.addEventListener('keydown', function (ev) { if (ev.key === 'Tab') { ev.preventDefault(); ok.focus(); } });
    var api = { close: close };
    active = api;
    ok.addEventListener('click', function () { close(); });
    back.addEventListener('click', function () { close(); });
    ok.focus({ preventScroll: true });

    if (reduce) { finish(); return; }
    /* all plants are pulled together (a short stagger keeps it lively), then the basket count jumps once */
    var t0 = 150 + cells.length * 30 + 300;
    cells.forEach(function (c, i) { later(function () { c.classList.add('in'); }, 120 + i * 30); });
    cells.forEach(function (c, i) {
      later(function () {
        var a = c.querySelector('.hv-ico').getBoundingClientRect(), b = bico.getBoundingClientRect();
        c.style.setProperty('--fx', Math.round(b.left + b.width / 2 - a.left - a.width / 2) + 'px');
        c.style.setProperty('--fy', Math.round(b.top + b.height / 2 - a.top - a.height / 2) + 'px');
        c.classList.add('pick');
      }, t0 + i * 25);
    });
    later(function () {
      cells.forEach(function (c) { c.classList.add('gone'); });
      count(total, 450);
      bico.classList.add('bump');
    }, t0 + cells.length * 25 + 600);
    later(function () { done = false; finish(); }, t0 + cells.length * 25 + 1300);
  }

  function scan() { var d = document.querySelector('.hvdata'); if (d) open(d); }
  function start() {
    scan();
    if (window.MutationObserver) new MutationObserver(function () { if (document.querySelector('.hvdata')) scan(); }).observe(document.body, { childList: true, subtree: true });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
