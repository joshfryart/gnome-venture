/* The Hovel tea kettle: the live preview of the cup (includes/tea_view.php draws the form; includes/tea.php brews).
   gvTeaCup is the JS twin of tea_cup() in includes/tea.php: the same rules, the same words. tests/tea.sh runs both on the same cups.
   D (from the form's data-tea): { ing: { slug: [name, role, stat, power] }, named: [[name, [slugs]]], k: [K, main cap, side cap], stat: { key: Name }, max, house } */
(function (root) {
  'use strict';

  function teaKey(slugs) { return slugs.slice().sort().join('+'); }

  /* slugs: the base first, then the extras. Returns { err } or { name, named, main, mainPts, side, sidePts, mainSteep, sideSteep, K, capMain, capSide }. */
  function gvTeaCup(D, slugs) {
    slugs = (slugs || []).filter(function (s) { return s; });
    if (!slugs.length) return { err: 'Pick a base to steep.' };
    if (slugs.length > D.max) return { err: 'A cup holds ' + D.max + ' components at most.' };
    var seen = {}, sweet = 0, milk = 0, i, g;
    for (i = 0; i < slugs.length; i++) {
      g = D.ing[slugs[i]];
      if (!g) return { err: 'Unknown ingredient.' };
      if (seen[slugs[i]]) return { err: g[0] + ' is in the cup twice. Each ingredient goes in once.' };
      seen[slugs[i]] = 1;
      if (g[1] === 'sweet') sweet++;
      if (g[1] === 'milk') milk++;
    }
    if (D.ing[slugs[0]][1] !== 'steep') return { err: 'The base must be a leaf, herb, flower or root.' };
    if (sweet > 1) return { err: 'One sweetener per cup.' };
    if (milk > 1) return { err: 'One milk per cup.' };
    var K = D.k[0], capM = D.k[1], capS = D.k[2], steep = {}, order = [], main = D.ing[slugs[0]][2];
    for (i = 0; i < slugs.length; i++) {
      g = D.ing[slugs[i]];
      if (!g[2]) continue;
      if (!(g[2] in steep)) { steep[g[2]] = 0; order.push(g[2]); }
      steep[g[2]] += g[3] * (i === 0 ? 2 : 1);
    }
    var side = '';
    for (i = 0; i < order.length; i++) if (order[i] !== main && (side === '' || steep[order[i]] > steep[side])) side = order[i];
    var nm = '', key = teaKey(slugs);
    for (i = 0; i < D.named.length; i++) if (teaKey(D.named[i][1]) === key) { nm = D.named[i][0]; break; }
    if (sweet) { steep[main] += 1; if (side) steep[side] += 1; }
    if (milk) steep[main] += 2;
    if (nm) steep[main] += 1;
    var mp = Math.min(capM, Math.floor(steep[main] * K / 8));
    var sp = side ? Math.min(capS, Math.floor(steep[side] * K / 8)) : 0;
    return { name: nm || D.house, named: !!nm, main: main, mainPts: mp, side: side, sidePts: sp, mainSteep: steep[main], sideSteep: side ? steep[side] : 0, K: K, capMain: capM, capSide: capS };
  }

  if (typeof module !== 'undefined' && module.exports) { module.exports = { gvTeaCup: gvTeaCup }; return; }
  root.gvTeaCup = gvTeaCup;
  if (typeof document === 'undefined') return;

  function dataOf(form) {
    if (!form._tea) { try { form._tea = JSON.parse(form.getAttribute('data-tea')); } catch (e) { form._tea = null; } }
    return form._tea;
  }
  function el(tag, cls, text) { var n = document.createElement(tag); if (cls) n.className = cls; if (text) n.textContent = text; return n; }
  function cards(form) { return Array.prototype.slice.call(form.querySelectorAll('[data-tea-ing]')); }
  function box(card) { return card.querySelector('input[type="checkbox"]'); }
  function radio(card) { return card.querySelector('input[type="radio"]'); }

  /* The cup as the server would read it: the base first, then the other ticked cards in page order. */
  function cup(form) {
    var base = '', rest = [];
    cards(form).forEach(function (c) {
      var r = radio(c), s = c.getAttribute('data-tea-ing');
      if (r && r.checked) base = s; else if (box(c).checked) rest.push(s);
    });
    return (base ? [base] : []).concat(rest);
  }

  function render(form) {
    var D = dataOf(form), out = form.querySelector('[data-tea-out]');
    if (!D || !out) return;
    var slugs = cup(form), r = slugs.length ? gvTeaCup(D, slugs) : { err: 'Pick a base to steep, then up to three extras.' };
    if (!r.err && !slugs.length) r = { err: 'Pick a base to steep.' };
    cards(form).forEach(function (c) {
      var rr = radio(c);
      c.classList.toggle('on', box(c).checked);
      c.classList.toggle('base', !!(rr && rr.checked));
    });
    out.textContent = '';
    out.className = 'tea-out' + (r.err ? ' bad' : '');
    var go = form.querySelector('[data-tea-brew]');
    if (go) go.disabled = !!r.err;
    if (r.err) { out.appendChild(el('p', 'tea-name', r.err)); return; }
    var h = el('p', 'tea-name');
    h.appendChild(el('b', '', r.name));
    if (r.named) { h.appendChild(document.createTextNode(' ')); h.appendChild(el('span', 'tea-stamp', 'named tea · +1 steep')); }
    out.appendChild(h);
    var b = el('p', 'tea-buffs');
    if (r.mainPts + r.sidePts === 0) b.appendChild(el('span', 'tea-buff none', 'Too weak for a boost'));
    if (r.mainPts) b.appendChild(el('span', 'tea-buff', D.stat[r.main] + ' +' + r.mainPts));
    if (r.sidePts) b.appendChild(el('span', 'tea-buff', D.stat[r.side] + ' +' + r.sidePts));
    b.appendChild(el('span', 'tea-buff none', form.getAttribute('data-tea-ends') || 'until you sleep'));
    out.appendChild(b);
    var m = el('p', 'tea-math');
    m.appendChild(document.createTextNode(D.stat[r.main] + ': steep ' + r.mainSteep + ' × ' + r.K + ' ÷ 8 = ' + Math.floor(r.mainSteep * r.K / 8) + ', cap ' + r.capMain));
    if (r.side) { m.appendChild(el('br')); m.appendChild(document.createTextNode(D.stat[r.side] + ': steep ' + r.sideSteep + ' × ' + r.K + ' ÷ 8 = ' + Math.floor(r.sideSteep * r.K / 8) + ', cap ' + r.capSide)); }
    out.appendChild(m);
  }

  document.addEventListener('change', function (ev) {
    var t = ev.target, form = t && t.closest ? t.closest('form[data-tea]') : null;
    if (!form) return;
    var card = t.closest('[data-tea-ing]');
    if (!card) return;
    var D = dataOf(form), all = cards(form), note = form.querySelector('[data-tea-note]');
    if (note) note.textContent = '';
    if (t.type === 'radio') {
      box(card).checked = true;   // the base is in the cup
    } else if (t.checked) {
      var r = radio(card);
      if (r && !all.some(function (c) { var x = radio(c); return x && x.checked; })) r.checked = true;   // the first thing that can steep is the base
    } else {
      var mine = radio(card);
      if (mine && mine.checked) {   // the base came out: the next ticked thing that can steep takes over
        mine.checked = false;
        all.some(function (c) { var x = radio(c); if (x && box(c).checked) { x.checked = true; return true; } return false; });
      }
    }
    var n = all.filter(function (c) { return box(c).checked; }).length, max = D ? D.max : 4;
    if (n > max) {   // one too many: the last tick does not go in
      box(card).checked = false;
      var rr = radio(card); if (rr && rr.checked) { rr.checked = false; all.some(function (c) { var x = radio(c); if (x && box(c).checked) { x.checked = true; return true; } return false; }); }
      if (note) note.textContent = 'A cup holds ' + max + ' components at most. Take one out first.';
    }
    render(form);
  });

  /* A second cup the same day: ask before the first one is poured out (the tick box does the same without script). */
  document.addEventListener('submit', function (ev) {
    var form = ev.target;
    if (!form || !form.matches || !form.matches('form[data-tea]')) return;
    var sub = ev.submitter;
    if (sub && !sub.hasAttribute('data-tea-brew')) return;
    var ck = form.querySelector('input[name="confirm"]');
    if (!ck || ck.checked) return;
    var msg = form.getAttribute('data-tea-pour') || 'This pours out your tea. Brew again?';
    if (typeof root.gvAsk !== 'function') { if (window.confirm(msg)) ck.checked = true; else ev.preventDefault(); return; }
    ev.preventDefault(); ev.stopImmediatePropagation();   // the game's own in-page dialog (site.js), then the same button again
    root.gvAsk(msg, function () {
      ck.checked = true;
      if (form.requestSubmit) { try { form.requestSubmit(sub || undefined); } catch (e) { form.requestSubmit(); } } else form.submit();
    });
  }, true);
})(typeof window !== 'undefined' ? window : this);
