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
    var lvl = 0;   // a level-up line becomes a small "LEVEL UP!" pop (the fight's pop, smaller) and a chip instead of text
    var notes = Array.prototype.map.call(data.querySelectorAll('ol li'), function (li) { return li.textContent; }).filter(function (m) {
      var x = /^\s*(?:🎉\s*)?You reached gnome level (\d+)/.exec(m);
      if (x) { lvl = parseInt(x[1], 10); return false; }
      return true;
    });
    var st = document.querySelector('.gardenstat'), stat = null;   // garden status counts (garden page): they ride in this popover instead of their own pill
    if (st) { stat = {}; ['ready', 'thirsty', 'weedy', 'empty', 'grow'].forEach(function (k) { stat[k] = num(st, k); }); st.remove(); }
    var prevFocus = document.activeElement, art = data.getAttribute('data-art') || '', icoBase = data.getAttribute('data-ico') || '';   // art: base url of the harvest-*.png pictures ('' = emoji and CSS shapes)
    var heading = pal ? who + ' is picking…' : 'Picking time!';
    var doneHeading = total >= 12 ? pick(['Basket overflowing!', 'Veg everywhere!']) : pal ? pick([who + ' did the picking!', 'Picked while you slept!']) : pick(['Harvest in!', 'Basket full!', 'Veg secured.']);

    /* the site's own pixel icons (assets/img/ico) instead of emoji; with no icon base the emoji stay */
    function ico(slug, emoji) {
      if (!icoBase) return document.createTextNode(emoji + ' ');
      var i = el('img', 'ico pix'); i.alt = ''; i.width = 16; i.height = 16; i.src = icoBase + 'ico-' + slug + '.png';
      return i;
    }
    var NOTE_ICO = { '🍀': 'four-leaf-clover', '🐝': 'bee', '🪱': 'worm', '🏅': 'medal-gold', '🌽': 'corn', '🐦': 'bird', '🍄': 'mushroom', '✨': 'sparkle', '⭐': 'star', '🏡': 'home', '🎩': 'gnome-hat', '📈': 'chart', '💪': 'strength', '✂️': 'shears', '🌱': 'sprout' };
    function png(name, cls) {   // one of the pixel pictures; a failed load turns the whole show back to emoji and CSS shapes
      var i = el('img', cls); i.alt = ''; i.draggable = false;
      if (art) { i.addEventListener('error', function () { root.classList.remove('hv-px'); }); i.src = art + name + '.png'; }
      return i;
    }
    var root = el('dialog', 'hvov' + (art ? ' hv-px' : ''));
    root.setAttribute('aria-label', 'The harvest');
    var back = el('div', 'hv-back'), box = el('div', 'hv-box');
    var title = el('h2', 'hv-title', heading);
    var field = el('div', 'hv-field'); field.setAttribute('aria-hidden', 'true');
    var basket = el('div', 'hv-basket'); basket.setAttribute('aria-hidden', 'true');
    var bico = el('span', 'hv-bico'), bcount = el('b', 'hv-bcount', '0');
    var bpx = el('span', 'hv-bpx'), heap = png('basket-heap', 'hv-heap');
    bpx.appendChild(png('basket-back', 'hv-bback')); bpx.appendChild(heap); bpx.appendChild(png('basket-front', 'hv-bfront'));
    if (icoBase) { var bi = ico('basket', '🧺'); bi.width = bi.height = 40; bico.appendChild(bi); } else bico.textContent = '🧺';
    basket.appendChild(bico); basket.appendChild(bpx); basket.appendChild(bcount);
    function strip(name, cls) { var w = el('span', 'hv-fx ' + cls); w.appendChild(png(name, '')); return w; }
    function tuftFor(kind) { return /^(flower|grain|herb|cover)$/.test(kind) ? 'stalk' : /^(fruit|legume|tree|nut)$/.test(kind) ? 'vine' : 'leafy'; }
    var sum = el('ul', 'hv-sum'), tally = el('p', 'hv-tally'), nl = el('ul', 'hv-notes');
    var live = el('p', 'hv-live'); live.setAttribute('aria-live', 'polite'); live.setAttribute('role', 'status');
    var ok = el('button', 'btn hv-ok', 'Yum!'); ok.type = 'button';

    var cells = cards.map(function (c, i) {
      var cell = el('div', 'hv-plant'), ico = el('span', 'hv-ico'), soil = el('i', 'hv-soil'), plus = el('b', 'hv-plus', '+' + c.getAttribute('data-qty'));
      Array.prototype.forEach.call(c.querySelector('.hv-ico').childNodes, function (n) { ico.appendChild(n.cloneNode(true)); });
      ico.appendChild(png('tuft-' + tuftFor(c.getAttribute('data-kind') || ''), 'hv-tuft'));
      var sp = el('span', 'hv-soilpx'); sp.appendChild(png('soil-planted', 'hv-sp1')); sp.appendChild(png('soil-pulled', 'hv-sp2'));
      cell.style.setProperty('--i', i);
      cell.appendChild(plus); cell.appendChild(ico); cell.appendChild(soil); cell.appendChild(sp); cell.appendChild(strip('puff', 'hv-puff'));
      field.appendChild(cell);
      return cell;
    });
    box.appendChild(title); box.appendChild(field); if (more) box.appendChild(el('p', 'hv-more2', '+' + more + ' more')); box.appendChild(basket); box.appendChild(sum); box.appendChild(tally); box.appendChild(nl); box.appendChild(live); box.appendChild(ok);
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
      var chips = [['basket', '🧺', total + ' crop' + (total === 1 ? '' : 's')]];
      if (xp) chips.push(['star', '⭐', '+' + xp + ' XP']);
      if (lvl) chips.push(['party', '🎉', 'Level ' + lvl]);
      if (seeds) chips.push(['sprout', '🌱', seeds]);
      if (stat) [['droplet', '💧', 'thirsty', 'thirsty'], ['basket', '🧺', 'ready', 'still ripe'], ['herb-sprig', '🌿', 'weedy', 'weedy'], ['hole', '🟫', 'empty', 'bare'], ['leaf', '🌱', 'grow', 'growing']].forEach(function (r) { if (stat[r[2]]) chips.push([r[0], r[1], String(stat[r[2]]), stat[r[2]] + ' ' + r[3], 1]); });
      chips.forEach(function (c, i) { var s = el('span', 'hv-t' + (c[4] ? ' hv-st' : '')); s.appendChild(ico(c[0], c[1])); s.appendChild(document.createTextNode(c[2])); if (c[3]) s.title = c[3]; s.style.setProperty('--gi', i); tally.appendChild(s); });
      notes.forEach(function (m) {
        var li = el('li'), lead = Object.keys(NOTE_ICO).filter(function (k) { return m.indexOf(k) === 0; })[0];
        if (lead && icoBase) { li.appendChild(ico(NOTE_ICO[lead])); li.appendChild(document.createTextNode(m.slice(lead.length).replace(/^\s+/, ''))); } else li.textContent = m;
        nl.appendChild(li);
      });
    }
    function count(to, ms) {
      var t = null;
      (function tick(now) { if (t === null) t = now; var p = Math.min(1, (now - t) / ms); bcount.textContent = Math.round(to * (1 - Math.pow(1 - p, 3))); if (p < 1 && !closed && !done) requestAnimationFrame(tick); })(performance.now());
    }
    function levelPop() {   // same motion as the fight's LEVEL UP! pop (scale up, rise, fade), smaller, over the basket
      if (closed || !box.animate) return;
      var d = el('div', 'hv-lvl', 'LEVEL UP!');
      d.setAttribute('aria-hidden', 'true');
      d.style.top = (basket.offsetTop - 6) + 'px';
      box.appendChild(d);
      d.animate([{ transform: 'translate(-50%, 6px) scale(.6)', opacity: 0 }, { transform: 'translate(-50%, -3px) scale(1.25)', opacity: 1, offset: .2 }, { transform: 'translate(-50%, -26px) scale(1)', opacity: 0 }], { duration: 950 }).finished.then(function () { d.remove(); }, function () { d.remove(); });
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
    /* Auto-close: about 3 s after the picture is finished, about 6 s when it shows a level-up or mastery line, a little longer for a lot of text.
       Touching, hovering or focusing inside the box stops the clock for good (the button, backdrop tap or Escape still close); a hidden tab waits. */
    var autoT = null, autoOn = false, held = false;
    function autoMs() {
      var big = lvl > 0 || notes.some(function (m) { return /mastery|mastered|master of/i.test(m); });
      var chars = notes.join('').length + (seeds || '').length;
      return Math.min(12000, (big ? 6000 : 3000) + Math.max(0, chars - 80) * 25);
    }
    function autoArm(ms) {
      clearTimeout(autoT);
      if (closed || held || !autoOn) return;
      autoT = setTimeout(function () { if (document.hidden) autoArm(1000); else close(); }, ms);
    }
    function hold() { held = true; clearTimeout(autoT); }
    box.addEventListener('pointerdown', hold);
    box.addEventListener('focusin', function (ev) { if (ev.target !== ok) hold(); });
    box.addEventListener('pointerenter', function (ev) { if (ev.pointerType === 'mouse' && autoOn) clearTimeout(autoT); });
    box.addEventListener('pointerleave', function (ev) { if (ev.pointerType === 'mouse' && autoOn && !held) autoArm(Math.max(1500, autoMs() / 2)); });
    function finish() {
      if (done) return;
      done = true;
      timers.forEach(clearTimeout);
      timers = [];
      cells.forEach(function (c) { c.classList.add('in', 'gone', 'pick'); });
      heap.classList.add('on');
      root.classList.add('hv-done');
      bcount.textContent = total;
      if (!sum.firstChild) buildSummary();
      title.textContent = doneHeading;
      live.textContent = summary;
      if (!autoOn) { autoOn = true; autoArm(autoMs()); }
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
        var a = c.querySelector('.hv-ico').getBoundingClientRect(), b = (root.classList.contains('hv-px') ? bpx : bico).getBoundingClientRect();
        c.style.setProperty('--fx', Math.round(b.left + b.width / 2 - a.left - a.width / 2) + 'px');
        c.style.setProperty('--fy', Math.round(b.top + b.height * 0.3 - a.top - a.height / 2) + 'px');
        c.classList.add('pick');
      }, t0 + i * 25);
    });
    later(function () {
      cells.forEach(function (c) { c.classList.add('gone'); });
      count(total, 450);
      bico.classList.add('bump'); bpx.classList.add('bump'); heap.classList.add('on');
      if (lvl) later(levelPop, 350);
      for (var k = 0; k < 3; k++) { var f = strip('spark', 'hv-spark'); f.style.setProperty('--sx', (10 + k * 22) + 'px'); f.style.setProperty('--sd', k * 110 + 'ms'); basket.appendChild(f); }
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
