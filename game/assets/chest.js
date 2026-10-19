/* v1.4.6: the delve chest treat. The server has already paid out the loot; includes/chest.php leaves a hidden .chestdata
   block (Petals, XP, a card per item) in the page. This shows it: a chest wobbles, pops open with a burst of light, the
   loot pops out one by one and the numbers count up. Button, backdrop tap, Escape or Android back closes (native <dialog>). No JS: the block stays hidden
   and the usual messages tell the story. Reduced motion: the finished picture at once. Works after in-place swaps. */
(function () {
  var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var active = null;
  var NS = 'http://www.w3.org/2000/svg';

  function el(tag, cls, text) { var n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; return n; }

  var CHEST = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" class="cs-svg" aria-hidden="true" focusable="false"><ellipse cx="32" cy="56" rx="24" ry="3.500" fill="#000" opacity=".15"/><g class="cs-bodyg"><rect x="10" y="30" width="44" height="25" rx="4" fill="#9a6a3a"/><path d="M10 46h44v5a4 4 0 0 1-4 4H14a4 4 0 0 1-4-4z" fill="#7e5430"/><rect x="12" y="32" width="40" height="4" rx="2" fill="#b98450" opacity=".7"/><path d="M11 42h42" stroke="#6e4726" stroke-width="1.600" stroke-linecap="round" opacity=".5"/><rect x="16" y="30" width="5" height="25" fill="#e2b13c"/><rect x="43" y="30" width="5" height="25" fill="#e2b13c"/><rect x="17" y="30" width="1.600" height="25" fill="#f6d77a" opacity=".8"/><rect x="44" y="30" width="1.600" height="25" fill="#f6d77a" opacity=".8"/><ellipse class="cs-inside" cx="32" cy="31" rx="21" ry="3.500" fill="#3a2410"/></g><ellipse class="cs-glow" cx="32" cy="30" rx="20" ry="5" fill="#fff1b0"/><g class="cs-lid"><path d="M10 33v-7c0-8 10-12 22-12s22 4 22 12v7z" fill="#a97640"/><path d="M14 24c3-5 10-7 18-7s13 2 16 6c-4-2-10-3-16-3s-13 1-18 4z" fill="#c48e55" opacity=".7"/><rect x="16" y="14" width="5" height="19" fill="#e2b13c"/><rect x="43" y="14" width="5" height="19" fill="#e2b13c"/><rect x="10" y="30" width="44" height="4.500" rx="2" fill="#e2b13c"/><rect x="12" y="31" width="40" height="1.400" rx=".7" fill="#f6d77a"/><rect x="27.500" y="30" width="9" height="10" rx="2.500" fill="#f3c94f"/><circle cx="32" cy="34.500" r="1.600" fill="#5e3b1c"/></g></svg>';

  function open(data) {
    if (active) active.close(true);
    var coins = parseInt(data.getAttribute('data-coins'), 10) || 0, xp = parseInt(data.getAttribute('data-xp'), 10) || 0;
    var cur = data.getAttribute('data-cur') || 'Petals', summary = data.getAttribute('data-summary') || '';
    var cards = Array.prototype.slice.call(data.querySelectorAll('li'));
    var prevFocus = document.activeElement;

    /* v1.8.2: a native <dialog> (showModal): focus trap, top layer, inert page; role and aria-modal come with it */
    var root = el('dialog', 'chestov');
    root.setAttribute('aria-label', 'The chest');
    var back = el('div', 'cs-back');
    var box = el('div', 'cs-box');
    var stage = el('div', 'cs-stage'); stage.innerHTML = CHEST;
    var sparks = el('div', 'cs-sparks'); sparks.setAttribute('aria-hidden', 'true'); stage.appendChild(sparks);
    var title = el('h2', 'cs-title', 'The chest creaks open!');
    var loot = el('ul', 'cs-loot');
    var tally = el('p', 'cs-tally');
    var tc = el('span', 'cs-t cs-t-coins'), tx = el('span', 'cs-t cs-t-xp');
    tc.setAttribute('aria-hidden', 'true'); tx.setAttribute('aria-hidden', 'true');
    tally.appendChild(tc); tally.appendChild(tx);
    var live = el('p', 'cs-live'); live.setAttribute('aria-live', 'polite'); live.setAttribute('role', 'status');
    var ok = el('button', 'btn cs-ok', 'Lovely!'); ok.type = 'button';
    box.appendChild(stage); box.appendChild(title); box.appendChild(loot); box.appendChild(tally); box.appendChild(live); box.appendChild(ok);
    root.appendChild(back); root.appendChild(box);
    data.remove();
    document.body.appendChild(root);
    if (root.showModal) root.showModal(); else root.setAttribute('open', '');

    var timers = [], raf = [], done = false, closed = false;
    function later(fn, ms) { timers.push(setTimeout(fn, ms)); }
    function setCoins(v) { tc.textContent = '🪙 +' + v.toLocaleString() + ' ' + cur; }
    function setXp(v) { tx.textContent = '⭐ +' + v + ' XP'; }
    function count(set, to, ms) {
      var t0 = null;
      function tick(t) {
        if (t0 === null) t0 = t;
        var p = Math.min(1, (t - t0) / ms);
        set(Math.round(to * (1 - Math.pow(1 - p, 3))));
        if (p < 1) raf.push(requestAnimationFrame(tick));
      }
      raf.push(requestAnimationFrame(tick));
    }
    function burst() {
      for (var i = 0; i < 18; i++) {
        var s = el('i', 'cs-spark'), a = (Math.PI * 2 * i) / 18 + Math.random() * 0.3, d = 70 + Math.random() * 70;
        s.style.setProperty('--dx', Math.round(Math.cos(a) * d) + 'px');
        s.style.setProperty('--dy', Math.round(Math.sin(a) * d * 0.8 - 30) + 'px');
        s.style.setProperty('--dl', Math.round(Math.random() * 120) + 'ms');
        sparks.appendChild(s);
      }
    }
    function finish() {          // everything in its final place
      if (done) return;
      done = true;
      timers.forEach(clearTimeout); raf.forEach(cancelAnimationFrame);
      root.classList.add('cs-opened', 'cs-done');
      cards.forEach(function (c) { c.classList.add('in'); });
      setCoins(coins); setXp(xp);
      title.textContent = 'The chest holds…';
      live.textContent = summary;
    }
    function close(quiet) {
      if (closed) return;
      closed = true;
      timers.forEach(clearTimeout); raf.forEach(cancelAnimationFrame);
      if (root.close && root.open) root.close();
      root.remove();
      if (active === api) active = null;
      if (!quiet) {
        var f = prevFocus && document.body.contains(prevFocus) ? prevFocus : document.getElementById('main');
        if (f && f.focus) f.focus({ preventScroll: true });
      }
    }
    /* v1.8.2: Esc and Android back fire "cancel": run our own close so the timers and the focus restore run */
    root.addEventListener('cancel', function (ev) { ev.preventDefault(); close(); });
    root.addEventListener('keydown', function (ev) { if (ev.key === 'Tab') { ev.preventDefault(); ok.focus(); } });
    var api = { close: close };
    active = api;
    cards.forEach(function (c) { loot.appendChild(c); });
    ok.addEventListener('click', function () { close(); });
    back.addEventListener('click', function () { close(); });
    ok.focus({ preventScroll: true });
    setCoins(0); setXp(0);

    if (reduce) { finish(); return; }
    root.classList.add('cs-wobble');
    later(function () {
      root.classList.remove('cs-wobble'); root.classList.add('cs-opened'); burst();
      title.textContent = 'The chest creaks open!';
      count(setCoins, coins, 1100); count(setXp, xp, 1100);
    }, 1000);
    cards.forEach(function (c, i) { later(function () { c.classList.add('in'); }, 1500 + i * 420); });
    later(function () { done = false; finish(); }, 1500 + cards.length * 420 + 900);
  }

  function scan() {
    var d = document.querySelector('.chestdata');
    if (d) open(d);
  }
  function start() {
    scan();
    if (window.MutationObserver) new MutationObserver(function () { if (document.querySelector('.chestdata')) scan(); }).observe(document.body, { childList: true, subtree: true });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
