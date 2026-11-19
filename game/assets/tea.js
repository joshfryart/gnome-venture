/* The Hovel tea kettle (includes/tea_view.php draws the popover; includes/tea.php brews).
   gvTeaCup is the JS twin of tea_cup() in includes/tea.php: the same rules, the same words. tests/tea.sh runs both on the same cups.
   D (from the cup form's data-tea): { ing: { slug: [name, role, stat, power] } in the data file's order, named: [[name, [slugs]]], k: [K, main cap, side cap], stat: { key: Name }, max, house }
   2.7.21: the popover is B2 "Cup and drawer": four cup slots on top with the result and Brew, a drawer below with Recipes | Leaves | Extras,
   a stamp row that opens the journal, and an in-page sheet before a second cup pours out the first. Without script the plain form shows instead. */
(function (root) {
  'use strict';

  /* A tie for the side stat goes to the stat earlier in this list (TEA_SIDE_ORDER in tea.php), so a set always gives the same cup. */
  var SIDE_ORDER = ['charm', 'lore', 'sense', 'nimble', 'grit', 'hardiness', 'luck'];
  var ROLE_ORDER = ['steep', 'add', 'sweet', 'milk'];

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
    var K = D.k[0], capM = D.k[1], capS = D.k[2], steep = {}, main = D.ing[slugs[0]][2];
    for (i = 0; i < slugs.length; i++) {
      g = D.ing[slugs[i]];
      if (!g[2]) continue;
      steep[g[2]] = (steep[g[2]] || 0) + g[3] * (i === 0 ? 2 : 1);
    }
    var side = '';   // the most steep; a tie goes to the stat earlier in SIDE_ORDER (never to the one added first)
    for (i = 0; i < SIDE_ORDER.length; i++) { var st = SIDE_ORDER[i]; if (st !== main && (st in steep) && (side === '' || steep[st] > steep[side])) side = st; }
    var nm = '', key = teaKey(slugs);
    for (i = 0; i < D.named.length; i++) if (teaKey(D.named[i][1]) === key) { nm = D.named[i][0]; break; }
    if (sweet) { steep[main] += 1; if (side) steep[side] += 1; }
    if (milk) steep[main] += 2;
    if (nm) steep[main] += 1;
    var mp = Math.min(capM, Math.floor(steep[main] * K / 8));
    var sp = side ? Math.min(capS, Math.floor(steep[side] * K / 8)) : 0;
    return { name: nm || D.house, named: !!nm, main: main, mainPts: mp, side: side, sidePts: sp, mainSteep: steep[main], sideSteep: side ? steep[side] : 0, K: K, capMain: capM, capSide: capS };
  }

  /* The twin of tea_pick(): the base first, then the others by role, then the data file's order. No base: the first that steeps (file order). */
  function gvTeaPick(D, all, base) {
    var keys = Object.keys(D.ing), rest = [];
    if (!base || !D.ing[base]) base = keys.filter(function (k) { return all.indexOf(k) >= 0 && D.ing[k][1] === 'steep'; })[0] || '';
    ROLE_ORDER.forEach(function (r) { keys.forEach(function (k) { if (D.ing[k][1] === r && k !== base && all.indexOf(k) >= 0) rest.push(k); }); });
    return (base ? [base] : []).concat(rest);
  }

  if (typeof module !== 'undefined' && module.exports) { module.exports = { gvTeaCup: gvTeaCup, gvTeaPick: gvTeaPick, SIDE_ORDER: SIDE_ORDER }; return; }
  root.gvTeaCup = gvTeaCup;
  if (typeof document === 'undefined') return;

  /* ---------- the B2 popover ---------- */
  function el(tag, cls, text) { var n = document.createElement(tag); if (cls) n.className = cls; if (text) n.textContent = text; return n; }
  function all(box, sel) { return Array.prototype.slice.call(box.querySelectorAll(sel)); }

  function state(panel) {
    if (panel._tea !== undefined) return panel._tea;
    var form = panel.querySelector('form.tea-cupf'), D = null;
    if (!form) return (panel._tea = null);
    try { D = JSON.parse(form.getAttribute('data-tea')); } catch (e) { D = null; }
    if (!D) return (panel._tea = null);
    var sel = (form.getAttribute('data-tea-sel') || '').split(',').filter(function (s) { return s && D.ing[s]; });
    var st = { D: D, form: form, base: '', ex: [], recipe: '', note: '', tab: 0 };
    if (sel.length && D.ing[sel[0]][1] === 'steep') { st.base = sel[0]; st.ex = sel.slice(1); } else st.ex = sel;
    var jb = panel.querySelector('[data-tea-jbox]');
    if (jb) { jb.setAttribute('role', 'dialog'); jb.setAttribute('aria-modal', 'true'); jb.setAttribute('aria-labelledby', 'htea-jh'); }
    panel._tea = st;
    render(panel);
    return st;
  }
  function inCup(st) { return (st.base ? [st.base] : []).concat(st.ex); }
  function slugs(st) { return gvTeaPick(st.D, inCup(st), st.base); }
  function roleOf(st, s) { return st.D.ing[s][1]; }
  function tag(st, s) { var g = st.D.ing[s]; return g[1] === 'sweet' ? 'sweet, +1' : g[1] === 'milk' ? 'creamy, +2' : st.D.stat[g[2]] + ' ' + g[3]; }
  function result(st) {
    if (!inCup(st).length) return { hint: 'Pick a tea, or blend your own' };
    if (!st.base) return { bad: 'Add a leaf, herb or flower as the base.' };
    var r = gvTeaCup(st.D, slugs(st));
    return r.err ? { bad: r.err } : r;
  }
  function buffText(st, r) { var b = []; if (r.mainPts) b.push(st.D.stat[r.main] + ' +' + r.mainPts); if (r.sidePts) b.push(st.D.stat[r.side] + ' +' + r.sidePts); return b.join(' · '); }

  function remove(st, s) {
    st.recipe = '';
    if (st.base === s) {
      st.base = '';
      var i = -1; st.ex.some(function (x, k) { if (roleOf(st, x) === 'steep') { i = k; return true; } return false; });
      if (i >= 0) st.base = st.ex.splice(i, 1)[0];   // the next thing that can steep takes over as the base
    } else st.ex = st.ex.filter(function (x) { return x !== s; });
  }
  function tap(st, s) {
    st.note = '';
    if (inCup(st).indexOf(s) >= 0) { remove(st, s); return; }
    var role = roleOf(st, s);
    if (role === 'sweet' || role === 'milk') {
      var o = inCup(st).filter(function (x) { return roleOf(st, x) === role; })[0];
      if (o) { remove(st, o); st.note = 'Swapped ' + st.D.ing[o][0] + ' for ' + st.D.ing[s][0] + '. One ' + (role === 'sweet' ? 'sweetener' : 'milk') + ' a cup.'; }
    }
    if (inCup(st).length >= st.D.max) { st.note = 'A cup holds ' + st.D.max + '. Tap one in the cup to take it out.'; return; }
    st.recipe = '';
    if (!st.base && role === 'steep') st.base = s; else st.ex.push(s);
  }
  function makeBase(st, s) {
    var i = st.ex.indexOf(s); if (i < 0) return;
    st.ex.splice(i, 1); if (st.base) st.ex.unshift(st.base);
    st.base = s; st.recipe = ''; st.note = st.D.ing[s][0] + ' is the base now. It counts double.';
  }
  function fill(st, slug, parts) {
    st.note = '';
    if (st.recipe === slug) { st.base = ''; st.ex = []; st.recipe = ''; return; }   // a second tap empties the cup again
    parts = parts.filter(function (s) { return st.D.ing[s]; });
    st.base = parts[0] || ''; st.ex = parts.slice(1); st.recipe = slug;
  }

  function iconFor(panel, s) {
    var src = panel.querySelector('[data-tea-add="' + s + '"] .tea-ic'), sp = el('span', 'tea-ic');
    if (src) Array.prototype.forEach.call(src.childNodes, function (n) { sp.appendChild(n.cloneNode(true)); });
    return sp;
  }

  function render(panel) {
    var st = panel._tea; if (!st) return;
    var D = st.D, cup = slugs(st), r = result(st), ok = !(r.hint || r.bad);
    var box = panel.querySelector('[data-tea-slots]');
    if (box) {
      box.textContent = '';
      for (var i = 0; i < D.max; i++) {
        var s = cup[i], slot = el('div', 'tea-slot' + (i === 0 ? ' base' : ''));
        if (s) {
          var b = el('button', 'tea-sl full'); b.type = 'button'; b.setAttribute('data-tea-take', s);
          b.setAttribute('aria-label', D.ing[s][0] + (i === 0 ? ', the base' : '') + '. Tap to take it out');
          b.appendChild(iconFor(panel, s)); slot.appendChild(b);
        } else { var e = el('span', 'tea-sl empty', '+'); e.setAttribute('aria-hidden', 'true'); slot.appendChild(e); }
        if (i === 0) slot.appendChild(el('span', 'tea-cap', 'Base ×2'));
        else if (s && roleOf(st, s) === 'steep') { var mb = el('button', 'tea-mkb', 'Make base'); mb.type = 'button'; mb.setAttribute('data-tea-base', s); slot.appendChild(mb); }
        else slot.appendChild(el('span', 'tea-cap', s ? tag(st, s) : 'extra'));
        box.appendChild(slot);
      }
    }
    var pv = panel.querySelector('[data-tea-pv]');
    if (pv) {
      pv.textContent = ''; pv.className = 'tea-pv' + (r.bad ? ' bad' : '');
      var nm = el('span', 'nm', ok ? r.name : 'Your cup');
      if (ok && r.named) { nm.appendChild(document.createTextNode(' ')); var sp = el('span', 'tea-stamp', '+1'); sp.title = 'A named tea: +1 steep'; nm.appendChild(sp); }
      pv.appendChild(nm);
      pv.appendChild(el('span', 'sub' + (ok ? ' ok' : ''), ok ? (buffText(st, r) || 'Too weak for a boost') : (r.hint || r.bad)));
    }
    var go = st.form.querySelector('[data-tea-go]'); if (go) go.disabled = !ok;
    var hid = st.form.querySelector('[data-tea-hid]');
    if (hid) {
      hid.textContent = '';
      var add = function (n, v) { var x = document.createElement('input'); x.type = 'hidden'; x.name = n; x.value = v; hid.appendChild(x); };
      if (cup.length) { add('base', st.base); cup.forEach(function (s) { add('c[]', s); }); }
    }
    var on = inCup(st);
    all(panel, '[data-tea-add]').forEach(function (t) {
      var s = t.getAttribute('data-tea-add'), o = on.indexOf(s) >= 0;
      t.classList.toggle('on', o); t.classList.toggle('isbase', st.base === s); t.setAttribute('aria-pressed', String(o));
    });
    all(panel, '[data-tea-fill]').forEach(function (f) {
      var sel = st.recipe === f.getAttribute('data-tea-fill');
      f.textContent = sel ? 'In cup' : 'Fill'; f.setAttribute('aria-pressed', String(sel));
      var row = f.closest('.tea-rrow'); if (row) row.classList.toggle('sel', sel);
    });
    var note = panel.querySelector('[data-tea-note]'); if (note) note.textContent = st.note;
  }

  function setTab(panel, i, smooth) {
    var st = panel._tea; if (!st) return;
    st.tab = i;
    var pn = panel.querySelector('[data-tea-panes]');
    if (pn && pn.clientWidth) { if (pn.scrollTo) pn.scrollTo({ left: i * pn.clientWidth, behavior: smooth ? 'smooth' : 'auto' }); else pn.scrollLeft = i * pn.clientWidth; }
    all(panel, '[data-tea-tab]').forEach(function (b) { var on = +b.getAttribute('data-tea-tab') === i; b.setAttribute('aria-selected', String(on)); b.tabIndex = on ? 0 : -1; });
  }
  function journal(panel, open) {
    var jm = panel.querySelector('[data-tea-jm]'); if (!jm) return;
    jm.classList.toggle('on', open);
    var f = open ? jm.querySelector('.tea-x') : panel.querySelector('[data-tea-jopen]');
    if (f) f.focus();
  }
  function sheet(panel, open) {
    var sh = panel.querySelector('[data-tea-sheet]'); if (!sh) return;
    sh.hidden = !open;
    if (open) { var b = sh.querySelector('[data-tea-pourgo]'); if (b) b.focus(); }
  }
  function panelOf(t) { var p = t && t.closest ? t.closest('[data-tea-panel]') : null; return p && state(p) ? p : null; }

  document.addEventListener('click', function (ev) {
    var t = ev.target, panel = panelOf(t), x, st;
    if (!panel) return;
    st = panel._tea;
    if ((x = t.closest('[data-tea-jopen]'))) { ev.preventDefault(); journal(panel, true); return; }
    if ((x = t.closest('[data-tea-jclose]'))) { journal(panel, false); return; }
    if ((x = t.closest('[data-tea-keep]'))) { sheet(panel, false); var g0 = st.form.querySelector('[data-tea-go]'); if (g0) g0.focus(); return; }
    if ((x = t.closest('[data-tea-pourgo]'))) {
      var ck = st.form.querySelector('[data-tea-confirm]'), go = st.form.querySelector('[data-tea-go]');
      if (ck) ck.value = '1';
      sheet(panel, false);
      if (st.form.requestSubmit) st.form.requestSubmit(go || undefined); else st.form.submit();
      return;
    }
    if ((x = t.closest('[data-tea-tab]'))) { setTab(panel, +x.getAttribute('data-tea-tab'), true); return; }
    if ((x = t.closest('[data-tea-fill]'))) fill(st, x.getAttribute('data-tea-fill'), (x.getAttribute('data-tea-parts') || '').split(','));
    else if ((x = t.closest('[data-tea-add]'))) tap(st, x.getAttribute('data-tea-add'));
    else if ((x = t.closest('[data-tea-take]'))) { st.note = ''; remove(st, x.getAttribute('data-tea-take')); }
    else if ((x = t.closest('[data-tea-base]'))) makeBase(st, x.getAttribute('data-tea-base'));
    else return;
    render(panel);
  });

  /* Brew: a second cup the same day asks first, in a sheet inside the popover (the tick box does the same without script). */
  document.addEventListener('submit', function (ev) {
    var form = ev.target;
    if (!form || !form.matches || !form.matches('form.tea-cupf')) return;
    var panel = panelOf(form); if (!panel) return;
    var st = panel._tea, r = result(st);
    if (r.hint || r.bad) { ev.preventDefault(); return; }
    var ck = form.querySelector('[data-tea-confirm]');
    if (!ck || ck.value === '1') return;
    ev.preventDefault(); ev.stopImmediatePropagation();
    var q = panel.querySelector('[data-tea-sq]');
    if (q) q.textContent = (form.getAttribute('data-tea-pour') || 'This pours out your tea.') + ' Brew ' + r.name + ' instead?';
    sheet(panel, true);
  }, true);

  /* Esc closes the journal or the sheet first, not the whole popover. */
  function layerUp(panel) {
    var jm = panel.querySelector('[data-tea-jm].on'), sh = panel.querySelector('[data-tea-sheet]:not([hidden])');
    if (sh) { sheet(panel, false); return true; }
    if (jm) { journal(panel, false); return true; }
    return false;
  }
  document.addEventListener('keydown', function (ev) {
    var panel = panelOf(ev.target);
    if (!panel) return;
    if (ev.key === 'Escape') { if (layerUp(panel)) { ev.preventDefault(); ev.stopPropagation(); } return; }
    var tb = ev.target.closest('[data-tea-tab]');
    if (tb && (ev.key === 'ArrowRight' || ev.key === 'ArrowLeft')) {
      ev.preventDefault();
      var i = (panel._tea.tab + (ev.key === 'ArrowRight' ? 1 : 2)) % 3;
      setTab(panel, i, true);
      var nb = panel.querySelector('[data-tea-tab="' + i + '"]'); if (nb) nb.focus();
    }
  }, true);
  document.addEventListener('cancel', function (ev) {   // the dialog's own Esc
    var panel = ev.target && ev.target.querySelector ? ev.target.querySelector('[data-tea-panel]') : null;
    if (panel && panel._tea && layerUp(panel)) ev.preventDefault();
  }, true);

  /* A swipe across the drawer moves the panes (scroll snap); the tab follows. */
  var swT = null;
  document.addEventListener('scroll', function (ev) {
    var pn = ev.target;
    if (!pn || !pn.matches || !pn.matches('[data-tea-panes]')) return;
    clearTimeout(swT);
    swT = setTimeout(function () {
      var panel = panelOf(pn); if (!panel || !pn.clientWidth) return;
      var i = Math.round(pn.scrollLeft / pn.clientWidth);
      if (i !== panel._tea.tab) {
        panel._tea.tab = i;
        all(panel, '[data-tea-tab]').forEach(function (b) { var on = +b.getAttribute('data-tea-tab') === i; b.setAttribute('aria-selected', String(on)); b.tabIndex = on ? 0 : -1; });
      }
    }, 80);
  }, true);

  function initAll() { all(document, '[data-tea-panel]').forEach(function (p) { state(p); }); }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initAll); else initAll();
  document.addEventListener('gv:swapped', initAll);
})(typeof window !== 'undefined' ? window : this);
