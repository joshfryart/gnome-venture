/* Garden status quip: after a harvest, garden.php leaves a hidden .gardenstat block (counts of ready, thirsty, weedy, empty, growing beds).
   This shows one small silly pill at the bottom: a hopping 🧺, a one-line quip and the counts as chips. Tap or ~4.5 s closes it.
   No JS: block stays hidden. Reduced motion: no hop or slide. Works after in-place swaps. */
(function () {
  function el(tag, cls, text) { var n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; return n; }
  function pick(a) { return a[Math.floor(Math.random() * a.length)]; }

  function quip(c) {
    if (c.thirsty) return pick(['' + c.thirsty + ' thirsty. They stare.', 'Dry beds. Dramatic sighs.', c.thirsty + ' parched. Rude.']);
    if (c.weedy) return pick([c.weedy + ' weedy. Weeds throw party.', 'Weeds got ideas.']);
    if (c.ready) return pick([c.ready + ' still ripe. Greedy gnome!', 'More! More veg!']);
    if (c.empty) return pick([c.empty + ' bare. Plant moar!', 'Empty beds echo.']);
    if (c.grow) return pick(['All growing. Gnome smug.', 'Sprouts doing sprout things.']);
    return 'Garden quiet. Suspicious.';
  }

  function show(d) {
    var c = {};
    ['ready', 'thirsty', 'weedy', 'empty', 'grow'].forEach(function (k) { c[k] = parseInt(d.getAttribute('data-' + k), 10) || 0; });
    d.remove();
    var old = document.querySelector('.gstat'); if (old) old.remove();
    var box = el('div', 'gstat'); box.setAttribute('role', 'status');
    box.appendChild(el('span', 'gs-hop', '🧺'));
    box.appendChild(el('span', 'gs-q', quip(c)));
    [['💧', 'thirsty', 'thirsty'], ['🧺', 'ready', 'ready'], ['🌿', 'weedy', 'weedy'], ['🟫', 'empty', 'empty'], ['🌱', 'grow', 'growing']].forEach(function (r, i) {
      if (!c[r[1]]) return;
      var chip = el('span', 'gs-c', r[0] + ' ' + c[r[1]]);
      chip.title = c[r[1]] + ' ' + r[2];
      chip.style.setProperty('--gi', i);
      box.appendChild(chip);
    });
    var gone = function () { if (box.parentNode) box.remove(); };
    box.addEventListener('click', gone);
    document.body.appendChild(box);
    setTimeout(function () { box.classList.add('gs-out'); setTimeout(gone, 350); }, 4500);
  }

  function scan() { var d = document.querySelector('.gardenstat'); if (d) show(d); }
  function start() {
    scan();
    if (window.MutationObserver) new MutationObserver(function () { if (document.querySelector('.gardenstat')) scan(); }).observe(document.body, { childList: true, subtree: true });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start); else start();
})();
