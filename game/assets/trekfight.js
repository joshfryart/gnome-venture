/* v1.8.4: Treks fight screen. The plan sheet (a <dialog> inside the fight form, its radios post with the round), the one-line plan, and the
   "Plan each turn" stage. Everything only sets the same radios the server reads (a[slot], t[slot], item); text goes in with textContent. */
(function () {
  /* site.js swaps <main> in place after a round, so the screen is set up again whenever a new .trekfight shows up. */
  function init(box) {
  box.setAttribute('data-tk', '1');
  var form = box.querySelector('form.trekactform');
  var dlg = form ? form.querySelector('dialog.trekplan') : null;
  if (!form || !dlg) return;
  var turn;
  var mems = [].slice.call(dlg.querySelectorAll('fieldset.planmem'));
  var tabs = [].slice.call(dlg.querySelectorAll('.plantab'));
  var planList = form.querySelector('.planlist');
  var planLabel = form.querySelector('.planlabel');
  var goBtn = form.querySelector('.trekgo');
  var KEY = 'gvTrekTurn';

  function memFor(slot) {
    for (var i = 0; i < mems.length; i++) if (mems[i].getAttribute('data-slot') === String(slot)) return mems[i];
    return null;
  }
  function moveOf(mem) { return mem.querySelector('input[name^="a["]:checked'); }
  function targetOf(mem) { return mem.querySelector('input[name^="t["]:checked'); }

  /* Show only the targets that fit the move (foes, friends, or none) and the snack list for Snack. A changed move re-aims at the weakest. */
  function syncMem(mem, reset) {
    var mv = moveOf(mem);
    var need = mv ? mv.getAttribute('data-need') : 'f';
    var grps = mem.querySelectorAll('.tg');
    for (var i = 0; i < grps.length; i++) grps[i].hidden = need === 'n' || grps[i].getAttribute('data-grp') !== need;
    var lab = mem.querySelector('.plantgt');
    if (lab) lab.hidden = need === 'n';
    var isSnack = mv && mv.value === 'snack';
    var sl = mem.querySelector('.plansnack'), sg = mem.querySelector('.snacks');
    if (sl) sl.hidden = !isSnack;
    if (sg) sg.hidden = !isSnack;
    if (reset && need !== 'n') {
      var cur = targetOf(mem);
      if (!cur || cur.closest('.tg').getAttribute('data-grp') !== need) {
        var def = mem.querySelector('.tg[data-grp="' + need + '"] input[data-def="1"]') || mem.querySelector('.tg[data-grp="' + need + '"] input');
        if (def) def.checked = true;
      }
    }
  }

  function choiceText(mem) {
    var mv = moveOf(mem);
    if (!mv) return '';
    var s = mv.getAttribute('data-ico') + ' ' + mv.getAttribute('data-title');
    if (mv.getAttribute('data-need') !== 'n') { var t = targetOf(mem); if (t) s += ' → ' + t.getAttribute('data-short'); }
    return s;
  }

  function updateLine() {
    var parts = [];
    mems.forEach(function (mem) {
      var mv = moveOf(mem);
      if (!mv) return;
      var s = mv.getAttribute('data-ico');
      if (mv.getAttribute('data-need') !== 'n') { var t = targetOf(mem); if (t) s += '→' + t.getAttribute('data-short'); }
      parts.push(s);
    });
    if (parts.length > 1 && parts.every(function (x) { return x === parts[0]; })) parts = ['all ' + parts[0]];   /* v1.8.4: same move for everyone reads as one item */
    if (planList) planList.textContent = parts.join(' · ');
    if (planLabel) planLabel.textContent = 'Plan:';
  }

  function showTab(slot) {
    mems.forEach(function (m) { m.hidden = m.getAttribute('data-slot') !== String(slot); });
    tabs.forEach(function (t) { t.setAttribute('aria-pressed', t.getAttribute('data-slot') === String(slot) ? 'true' : 'false'); });
  }

  mems.forEach(function (mem) { syncMem(mem, false); });
  if (mems.length) showTab(mems[0].getAttribute('data-slot'));
  tabs.forEach(function (t) { t.addEventListener('click', function () { showTab(t.getAttribute('data-slot')); }); });

  dlg.addEventListener('change', function (ev) {
    var inp = ev.target;
    if (!inp || inp.type !== 'radio') return;
    var mem = inp.closest('fieldset.planmem');
    if (mem && inp.name.indexOf('a[') === 0) syncMem(mem, true);
    updateLine();
    if (turn.on) renderTurn();
  });

  /* open, close, backdrop tap */
  var chg = form.querySelector('.planchg');
  if (chg) chg.addEventListener('click', function () { openSheet(); });
  function openSheet() { gvOpenDlg(dlg); }
  var done = dlg.querySelector('.plandone');
  if (done) done.addEventListener('click', function () { gvCloseDlg(dlg); updateLine(); });
  dlg.addEventListener('click', function (ev) {
    if (ev.target !== dlg) return;
    var r = dlg.getBoundingClientRect();
    if (ev.clientX < r.left || ev.clientX > r.right || ev.clientY < r.top || ev.clientY > r.bottom) gvCloseDlg(dlg);
  });

  /* ---- Plan each turn: the stage ---- */
  turn = { on: false, order: [], cur: 0, picked: {}, wait: false, items: false, stage: null, toks: {}, panel: null, hint: null, chk: null };
  var health = box.querySelector('.trekhealth');

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text !== undefined) n.textContent = text;
    return n;
  }

  function buildStage() {
    if (turn.stage || !health) return;
    var st = el('div', 'trekstage');
    var rows = health.querySelectorAll('.hprow');
    var foeRow = el('div', 'stgrow foes'), partyRow = el('div', 'stgrow party');
    [].forEach.call(rows, function (r) {
      var ref = r.getAttribute('data-ref');
      var isFoe = ref.charAt(0) === 'f';
      var b = el('button', 'stok ' + (isFoe ? 'foe' : 'you'));
      b.type = 'button';
      b.setAttribute('data-ref', ref);
      var ico = r.querySelector('.hpico');
      if (ico) b.appendChild(ico.cloneNode(true)).className = 'sico';
      if (r.getAttribute('data-g')) b.setAttribute('data-g', r.getAttribute('data-g'));
      b.appendChild(el('b', 'sname', r.getAttribute('data-name')));
      var cnt = parseInt(r.getAttribute('data-n') || '1', 10);
      if (cnt > 1) b.appendChild(el('i', 'stcount', '×' + cnt));   /* v1.8.6: foes of one kind are one token */
      var bar = r.querySelector('progress');
      if (bar) b.appendChild(bar.cloneNode(true));
      b.appendChild(el('small', 'shp', r.getAttribute('data-hp') + '/' + r.getAttribute('data-max')));
      b.appendChild(el('small', 'schoice', ''));
      var down = !isFoe && parseInt(r.getAttribute('data-hp'), 10) <= 0;
      if (down) { b.classList.add('down'); b.disabled = true; }
      if (isFoe && r.getAttribute('data-tgt') !== '1') { b.classList.add('under'); }
      b.addEventListener('click', function () { onToken(ref); });
      turn.toks[ref] = b;
      (isFoe ? foeRow : partyRow).appendChild(b);
    });
    turn.hint = el('p', 'sthint', '');
    turn.hint.setAttribute('aria-live', 'polite');
    turn.panel = el('div', 'stpanel');
    var off = el('button', 'stoff', 'Plan in one go');
    off.type = 'button';
    off.addEventListener('click', function () { setTurn(false); });
    st.appendChild(foeRow); st.appendChild(partyRow); st.appendChild(turn.panel); st.appendChild(turn.hint); st.appendChild(off);
    health.parentNode.insertBefore(st, health.nextSibling);
    turn.stage = st;
  }

  function livingSlots() {
    return mems.map(function (m) { return parseInt(m.getAttribute('data-slot'), 10); });
  }

  function nextOpen(from) {
    var n = turn.order.length;
    for (var k = 1; k <= n; k++) {
      var i = (from + k) % n;
      if (!turn.picked[turn.order[i]]) return i;
    }
    return -1;
  }

  function allDone() { return turn.order.every(function (s) { return turn.picked[s]; }); }

  function curMem() { return memFor(turn.order[turn.cur]); }

  function renderTurn() {
    if (!turn.on || !turn.stage) return;
    var fin = allDone();
    var mem = fin ? null : curMem();
    var need = mem && moveOf(mem) ? moveOf(mem).getAttribute('data-need') : 'n';
    var tgt = mem ? targetOf(mem) : null;
    var ref;
    for (ref in turn.toks) {
      var tk = turn.toks[ref];
      var slot = ref.charAt(0) === 'a' ? parseInt(ref.slice(2), 10) : -1;
      var isMe = !!mem && slot === turn.order[turn.cur];
      tk.classList.toggle('turn', isMe);
      tk.classList.toggle('picked', slot >= 0 && !!turn.picked[slot]);
      var aim = !!mem && turn.wait && !!tgt && need !== 'n' && (tgt.value === ref || (ref.charAt(0) === 'f' && !!tk.getAttribute('data-g') && tgt.getAttribute('data-g') === tk.getAttribute('data-g')));
      tk.classList.toggle('aim', aim);
      var can = false;
      if (mem && turn.wait) can = need === 'f' ? (ref.charAt(0) === 'f' && !tk.classList.contains('under')) : (need === 'a' && ref.charAt(0) === 'a' && !tk.classList.contains('down'));
      tk.classList.toggle('canaim', can);
      var badge = tk.querySelector('.stbadge');
      if (isMe && !badge) { badge = el('i', 'stbadge', 'YOUR TURN'); tk.appendChild(badge); }
      if (!isMe && badge) tk.removeChild(badge);
      var ch = tk.querySelector('.schoice');
      if (ch) { var m2 = slot >= 0 && turn.picked[slot] ? memFor(slot) : null; ch.textContent = m2 ? '✓ ' + choiceText(m2) : ''; }
    }
    /* move tiles for whoever's turn it is */
    var p = turn.panel;
    while (p.firstChild) p.removeChild(p.firstChild);
    if (fin) {
      turn.hint.textContent = 'All set. Tap a hero to change.';
    } else if (turn.items) {
      mem.querySelectorAll('input[name="item"]').forEach(function (r) {
        var b = el('button', 'stmove' + (r.checked ? ' on' : ''));
        b.type = 'button';
        b.appendChild(el('b', '', r.getAttribute('data-short')));
        b.addEventListener('click', function () { r.checked = true; commit(); });
        p.appendChild(b);
      });
      turn.hint.textContent = 'Which snack?';
    } else {
      mem.querySelectorAll('input[name^="a["]').forEach(function (r) {
        var b = el('button', 'stmove' + (r.checked ? ' on' : ''));
        b.type = 'button';
        b.disabled = r.disabled;
        b.appendChild(el('b', '', r.getAttribute('data-ico') + ' ' + r.getAttribute('data-title')));
        b.appendChild(el('small', '', r.getAttribute('data-sub')));
        b.addEventListener('click', function () { pickMove(r); });
        p.appendChild(b);
      });
      var verb = need === 'a' ? 'Tap who gets it' : 'Tap who to hit';
      if (turn.wait) gvIcoLine(turn.hint, 'ico-pointing', ' ' + verb); else turn.hint.textContent = 'Pick a move';
    }
  }

  function pickMove(r) {
    var mem = curMem();
    r.checked = true;
    syncMem(mem, true);
    updateLine();
    var need = r.getAttribute('data-need');
    if (need !== 'n') { turn.wait = true; renderTurn(); return; }
    turn.wait = false;
    if (r.value === 'snack' && mem.querySelectorAll('input[name="item"]').length > 1) { turn.items = true; renderTurn(); return; }
    commit();
  }

  function commit() {
    var slot = turn.order[turn.cur];
    turn.picked[slot] = true;
    turn.wait = false;
    turn.items = false;
    var n = nextOpen(turn.cur);
    if (n >= 0) turn.cur = n;
    updateLine();
    renderTurn();
    if (allDone() && goBtn) { goBtn.classList.add('glow'); goBtn.focus(); }
  }

  function onToken(ref) {
    if (!turn.on) return;
    var kind = ref.charAt(0);
    if (!allDone() && turn.wait) {
      var mem = curMem();
      var need = moveOf(mem).getAttribute('data-need');
      var tk = turn.toks[ref];
      var ok = need === 'f' ? (kind === 'f' && !tk.classList.contains('under')) : (need === 'a' && kind === 'a' && !tk.classList.contains('down'));
      if (ok) {
        var gk = kind === 'f' ? tk.getAttribute('data-g') : null;   /* a foe token stands for a whole kind: its tile carries the same data-g */
        var r = (gk && mem.querySelector('input[name^="t["][data-g="' + gk + '"]')) || mem.querySelector('input[name^="t["][value="' + ref + '"]');
        if (r) { r.checked = true; commit(); }
        return;
      }
    }
    if (kind === 'a') {   /* tap a hero: take their turn again */
      var slot = parseInt(ref.slice(2), 10);
      var i = turn.order.indexOf(slot);
      if (i >= 0) { turn.cur = i; turn.picked[slot] = false; turn.wait = false; turn.items = false; if (goBtn) goBtn.classList.remove('glow'); renderTurn(); }
    }
  }

  function setTurn(on) {
    try { window.localStorage.setItem(KEY, on ? '1' : '0'); } catch (e) { /* private mode */ }
    if (turn.chk) turn.chk.checked = on;
    turn.on = on;
    box.classList.toggle('turnmode', on);
    if (goBtn) goBtn.classList.remove('glow');
    if (!on) return;
    buildStage();
    turn.order = livingSlots();
    turn.cur = 0;
    turn.picked = {};
    turn.wait = false;
    turn.items = false;
    renderTurn();
  }

  /* the switch lives in the sheet */
  var tail = dlg.querySelector('.plantail');
  if (tail && done) {
    var lab = el('label', 'planturn');
    turn.chk = document.createElement('input');
    turn.chk.type = 'checkbox';
    lab.appendChild(turn.chk);
    lab.appendChild(document.createTextNode(' Plan each turn'));
    tail.insertBefore(lab, done);
    turn.chk.addEventListener('change', function () {
      if (turn.chk.checked) gvCloseDlg(dlg);
      setTurn(turn.chk.checked);
    });
  }
  var saved = '0';
  try { saved = window.localStorage.getItem(KEY) || '0'; } catch (e) { saved = '0'; }
  if (saved === '1') setTurn(true);
  }
  function scan() {
    var b = document.querySelector('.trekfight');
    if (b && !b.hasAttribute('data-tk')) init(b);
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.querySelector('main') || document.body, { childList: true, subtree: true });
})();

/* v2.0.10: small touches on Trek fights.
   (1) ONE foe pop-over (non-modal <dialog class="tkfoe">) with a card for every foe not yet shown in this fight (same name = one card, "×N"); the boss card carries the
       next-round hint. About 2.2 s or a tap closes all. Muted by the story pop-up flag (gvSceneOff). It waits for an open Auto replay, a story scene and, after a walk
       into a fight, for the "!" over the token (assets/trekmap.js); it never takes focus, so the plan sheet and the Auto replay still work. A foe that joins later pops alone.
   (2) After a round: hit shake, a floating number, a stronger flash on a crit, a fade for a foe kind that is gone, bars that ease. On the fight screen and on the
       "Plan each turn" stage. (The Auto replay has its own below; a fight that ends goes to the map, so its last KO is only seen in the replay.)
   Reduced motion: no movement (CSS) and no floating numbers; the pop-over still shows, still. Art is built by the server (escaped there); everything else is textContent. */
(function () {
  var SEEN = 'gvTkFoeSeen', SNAP = 'gvTkSnap', HOLD = 2200;
  var reduce = function () { return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches); };
  function el(tag, cls, text) { var n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; return n; }
  function get(k) { try { return JSON.parse(window.sessionStorage.getItem(k) || 'null'); } catch (e) { return null; } }
  function put(k, v) { try { if (v == null) window.sessionStorage.removeItem(k); else window.sessionStorage.setItem(k, JSON.stringify(v)); } catch (e) { /* private mode */ } }
  function muted() { try { return window.localStorage.getItem('gvSceneOff') === '1'; } catch (e) { return false; } }
  function runId() { var b = document.querySelector('.trekfight'); return b ? b.getAttribute('data-run') : ''; }   /* SEEN belongs to the run the page shows, so another run never inherits */
  function seenList() { var s = get(SEEN); return s && s.n && s.run === runId() ? s.n : []; }
  function markSeen(names) {
    var n = seenList();
    names.forEach(function (x) { if (n.indexOf(x) < 0) n.push(x); });
    put(SEEN, { run: runId(), n: n });
  }

  var timer = 0, pop = null;
  function closePop() {
    clearTimeout(timer);
    if (!pop) return;
    var d = pop, cb = d.tkAfter; pop = null;
    d.classList.add('out');
    setTimeout(function () { try { d.close(); } catch (e) { d.removeAttribute('open'); } if (d.parentNode) d.parentNode.removeChild(d); }, reduce() ? 0 : 200);
    if (cb) cb();
  }
  /* cards = [{a: art html, n, l, t, x, b}]; host = where the dialog lives (the open replay dialog, so a tap still reaches it, else the page); after = called when it closes */
  function showPop(cards, host, after) {
    if (pop) closePop();
    var d = el('dialog', 'tkfoe c' + Math.min(cards.length, 3));
    d.setAttribute('role', 'status');
    d.setAttribute('aria-label', cards.length > 1 ? 'Foes appear' : 'A foe appears');
    var row = el('div', 'tkfoerow');
    cards.forEach(function (c) {
      var card = el('div', 'tkfoecard');
      var art = el('div', 'tkfoeart');
      art.setAttribute('aria-hidden', 'true');
      if (c.a) art.innerHTML = c.a;   /* server-built art, escaped by the server (picture lookup: art, placeholder, emoji) */
      card.appendChild(art);
      card.appendChild(el('b', 'tkfoenm', (c.n || '') + (c.x > 1 ? ' ×' + c.x : '')));
      if (c.t) card.appendChild(el('span', 'tkfoeline', c.t));
      if (c.b) card.appendChild(el('span', 'tkfoehint', c.b));
      row.appendChild(card);
    });
    d.appendChild(row);
    d.tkAfter = after || null;
    d.addEventListener('click', function (ev) { ev.stopPropagation(); closePop(); });
    var keep = document.activeElement;
    (host || document.body).appendChild(d);
    if (d.show) d.show(); else d.setAttribute('open', '');
    try { if (keep && keep !== document.body && keep.focus) keep.focus({ preventScroll: true }); } catch (e) { /* old browser */ }
    pop = d;
    timer = setTimeout(closePop, HOLD);
  }
  /* the Auto replay uses these: a foe that joins mid-fight pops alone; foes it already shows need no pop-over afterwards */
  window.gvFoePop = function (card, host) {
    markSeen([card.n]);
    if (!muted()) showPop([card], host, null);
  };
  window.gvFoeSeen = function (names) { markSeen(names); };

  /* ---- first sight of the foes ---- */
  function foldMap(box) {   /* after a walk into a fight: the map folds away once the pop-over is done (the summary reopens it) */
    var d = document.querySelector('details.tkfmap');
    if (d && box.isConnected && !(window.matchMedia && window.matchMedia('(min-width: 1000px)').matches)) d.removeAttribute('open');   /* v2.0.13: on desktop the map stays open in column 1 */
  }
  function unhold() {   /* v2.0.14: round 1: the fight panel stays faded until the foe pop-over is done (CSS lets go by itself after 8 s) */
    var c = document.querySelector('.trekfightcol.tkhold');
    if (c) c.classList.remove('tkhold');
  }
  function waitThenPop(box) {
    var tries = 0;
    (function go() {
      if (!box.isConnected) return;
      /* any open dialog (plan sheet, Auto replay, story scene, camp) or a pending replay/scene/"!" holds the pop-over back; a non-modal card under a modal would go unseen */
      var modal = document.querySelector('dialog[open]:not(.tkfoe)');
      var busy = modal || document.querySelector('.trekreplay:not([data-seen]), .trekscene:not([data-seen]), details.tkfmap[data-bang]');
      if (busy && (modal || tries++ < 70)) { setTimeout(go, 250); return; }
      var holder = box.querySelector('.trekfoes'), cards = [];
      try { cards = JSON.parse((holder && holder.getAttribute('data-foes')) || '[]'); } catch (e) { cards = []; }
      var seen = seenList(), fresh = cards.filter(function (c) { return seen.indexOf(c.n) < 0; });
      if (!fresh.length || muted()) { unhold(); markSeen(cards.map(function (c) { return c.n; })); setTimeout(function () { foldMap(box); }, 400); return; }
      fresh.sort(function (a, b) { return (b.b ? 1 : 0) - (a.b ? 1 : 0); });   /* the boss first */
      showPop(fresh, null, function () { unhold(); foldMap(box); });
      markSeen(cards.map(function (c) { return c.n; }));   /* only now that it is on screen */
    })();
  }

  /* ---- the round's touches ---- */
  function rowsOf(box) {
    var out = { f: {}, a: {} };
    [].forEach.call(box.querySelectorAll('.trekhealth .hprow'), function (r) {
      var ref = r.getAttribute('data-ref') || '', foe = ref.charAt(0) === 'f';
      var ico = r.querySelector('.hpico');
      var o = { hp: parseInt(r.getAttribute('data-hp'), 10) || 0, max: parseInt(r.getAttribute('data-max'), 10) || 1, n: parseInt(r.getAttribute('data-n') || '1', 10) || 1,
        name: r.getAttribute('data-name') || '', g: r.getAttribute('data-g'), ico: ico ? ico.innerHTML : '' };   /* server-built art, escaped by the server */
      /* a boss or duel foe has its own row (keyed by its index); other foes of one name share one row (keyed by the name) */
      (foe ? out.f : out.a)[foe ? (r.getAttribute('data-own') === '1' ? 'o' + o.g : 'n' + o.name) : ref] = o;
    });
    return out;
  }
  /* the row on the fight screen and, in "Plan each turn", the token on the stage: both get the touches */
  function shown(box, foe, key) {
    var out = [], i;
    var rows = box.querySelectorAll('.trekhealth .hprow');
    for (i = 0; i < rows.length; i++) if (foe ? rows[i].getAttribute('data-ref').charAt(0) === 'f' && rows[i].getAttribute('data-g') === key : rows[i].getAttribute('data-ref') === key) out.push(rows[i]);
    var toks = box.querySelectorAll('.trekstage .stok');
    for (i = 0; i < toks.length; i++) if (foe ? toks[i].classList.contains('foe') && toks[i].getAttribute('data-g') === key : toks[i].getAttribute('data-ref') === key) out.push(toks[i]);
    return out;
  }
  function floatNum(li, txt, cls) {
    var n = el('span', 'tkfloat ' + cls, txt);
    n.setAttribute('aria-hidden', 'true');
    li.appendChild(n);
    n.addEventListener('animationend', function () { if (n.parentNode) n.parentNode.removeChild(n); });
    setTimeout(function () { if (n.parentNode) n.parentNode.removeChild(n); }, 1600);
  }
  function ease(li, from, to, max) {
    var bar = li.querySelector('progress'), num = li.querySelector('.hpnum, .shp'), t0 = null;
    if (!bar) return;
    function paint(v) { bar.value = v; if (num) num.textContent = v + '/' + max; }
    paint(from);
    function tick(t) {
      if (t0 === null) t0 = t;
      var k = Math.min(1, (t - t0) / 420);
      paint(Math.round(from + (to - from) * (1 - Math.pow(1 - k, 3))));
      if (k < 1 && li.isConnected) requestAnimationFrame(tick); else paint(to);
    }
    requestAnimationFrame(tick);
  }
  function critOn(name, lines) { return lines.some(function (t) { return /critical/i.test(t) && t.indexOf('hits ' + name + ' for ') >= 0; }); }
  function hit(items, txt, crit) {
    items.forEach(function (li) {
      li.classList.add('tkx-hit');
      if (crit) li.classList.add('tkx-crit');
      floatNum(li, txt, crit ? 'crit' : 'hurt');
      setTimeout(function () { li.classList.remove('tkx-hit', 'tkx-crit'); }, 900);
    });
  }
  function touches(box, prev) {
    var now = rowsOf(box);
    var lines = [].map.call(box.querySelectorAll('.trekwhat .trekrounds > li'), function (li) { return li.textContent; });
    Object.keys(now.f).forEach(function (key) {
      var was = prev.f[key], cur = now.f[key];
      if (!was) return;
      var items = shown(box, true, cur.g);
      if (cur.n < was.n) { hit(items, '−' + was.hp, critOn(cur.name, lines)); return; }   /* one of the kind fell: the row now shows the next one */
      if (cur.hp === was.hp) return;
      if (cur.hp < was.hp) hit(items, '−' + (was.hp - cur.hp), critOn(cur.name, lines)); else items.forEach(function (li) { floatNum(li, '+' + (cur.hp - was.hp), 'heal'); });
      items.forEach(function (li) { ease(li, was.hp, cur.hp, cur.max); });
    });
    Object.keys(now.a).forEach(function (key) {
      var was = prev.a[key], cur = now.a[key];
      if (!was || cur.hp === was.hp) return;
      var items = shown(box, false, key);
      if (cur.hp < was.hp) hit(items, '−' + (was.hp - cur.hp), false); else items.forEach(function (li) { floatNum(li, '+' + (cur.hp - was.hp), 'heal'); });   /* foes never crit */
      items.forEach(function (li) { ease(li, was.hp, cur.hp, cur.max); });
    });
    /* a kind of foe that is gone: a ghost where it stood fades out */
    var stage = box.classList.contains('turnmode') ? box.querySelector('.trekstage .stgrow.foes') : null;
    var list = stage || box.querySelector('.trekhealth .hprows');
    if (list) Object.keys(prev.f).forEach(function (key) {
      var o = prev.f[key];
      if (now.f[key] || o.hp <= 0) return;
      var g = stage ? el('div', 'stok foe down tkx-ghost tkx-ko') : el('li', 'hprow foe down tkx-ghost tkx-ko');
      g.setAttribute('aria-hidden', 'true');
      var ic = el('span', stage ? 'sico' : 'hpico'); ic.innerHTML = o.ico;   /* copied from the server-built row (escaped by the server) */
      g.appendChild(ic); g.appendChild(el('span', stage ? 'sname' : 'hpname', o.name));
      if (!stage) {
        var bar = document.createElement('progress'); bar.className = 'foebar'; bar.max = Math.max(1, o.max); bar.value = 0;
        g.appendChild(bar); g.appendChild(el('span', 'hpnum', '0/' + o.max));
      }
      list.insertBefore(g, list.firstChild);
      floatNum(g, '−' + o.hp, critOn(o.name, lines) ? 'crit' : 'hurt');
      setTimeout(function () { if (g.parentNode) g.parentNode.removeChild(g); }, 1100);
    });
  }

  function init(box) {
    box.setAttribute('data-tkx', '1');
    var run = box.getAttribute('data-run'), round = parseInt(box.getAttribute('data-round'), 10) || 1;
    var snap = get(SNAP);
    if (round === 1 && snap && snap.round > 1) { put(SEEN, null); snap = null; }   /* round 1 after later rounds: a new fight, nothing inherited */
    var rows = rowsOf(box);
    if (!reduce() && snap && snap.run === run && snap.round === round - 1 && snap.rows) touches(box, snap.rows);
    put(SNAP, { run: run, round: round, rows: rows });
    waitThenPop(box);
  }
  function scan() {
    var b = document.querySelector('.trekfight');
    /* .trekfight only exists on the Map tab, so the Party/Pack/Log tabs must not end the fight: only a Map render with no fight does (the map form) */
    if (!b) { if (document.querySelector('.trekmapcol') && !document.querySelector('.trekreplay')) { put(SEEN, null); put(SNAP, null); } return; }
    if (!b.hasAttribute('data-tkx')) init(b);
  }
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.querySelector('main') || document.body, { childList: true, subtree: true });
})();

/* v1.8.5: Auto replay. The server has already played every round and drawn the final page; this shows the rounds one by one in a card
   on top (bars, hit flashes, log lines). Tap, Esc or any key skips. Reduced motion or no script: the page just shows the result.
   Round lines come from the server already escaped (trek_line_html), so they are the only thing inserted as HTML. */
(function () {
  var TWEEN = 240, cur = null;
  var reduce = function () { return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches); };
  function el(tag, cls, text) { var n = document.createElement(tag); if (cls) n.className = cls; if (text != null) n.textContent = text; return n; }

  function Play(data) {
    var self = this;
    this.d = data;
    this.timers = [];
    this.raf = [];
    this.i = 0;
    this.rows = { f: [], p: [] };
    var n = data.r.length;
    this.step = Math.max(140, Math.min(550, Math.round(7000 / n)));
    var dlg = this.dlg = el('dialog', 'tkr');
    dlg.setAttribute('aria-label', 'Auto fight replay');
    var card = el('div', 'tkrcard');
    this.title = el('h3', 'tkrtitle', ' Auto'); this.title.insertBefore(gvIcoNode('ico-sword'), this.title.firstChild);
    var health = el('div', 'box trekhealth');
    this.fl = el('ul', 'hprows');
    this.pl = el('ul', 'hprows');
    var vs = el('div', 'hpvs', 'vs'); vs.setAttribute('aria-hidden', 'true');
    health.appendChild(this.fl); health.appendChild(vs); health.appendChild(this.pl);
    var what = el('div', 'box trekwhat');
    what.appendChild(el('b', 'tklabel', 'What happened'));
    this.list = el('ul', 'trekrounds tkrlines');
    this.list.setAttribute('aria-hidden', 'true');
    what.appendChild(this.list);
    this.hint = el('p', 'tkrhint', 'Tap to skip');
    this.btn = el('button', 'btn tkrdone', 'Done ✓');   /* v1.8.8: the replay stays open at the end so the whole fight can be read */
    this.btn.type = 'button';
    this.btn.hidden = true;
    this.btn.addEventListener('click', function (ev) { ev.stopPropagation(); self.close(); });
    card.appendChild(this.title); card.appendChild(health); card.appendChild(what); card.appendChild(this.hint); card.appendChild(this.btn);
    dlg.appendChild(card);
    this.groups = [];
    data.s.f.forEach(function (x) { self.addRow('f', x); });
    if (window.gvFoeSeen) window.gvFoeSeen(data.s.f.map(function (x) { return x[5] || x[0]; }));   /* v2.0.10: foes shown here need no pop-over afterwards */
    data.s.p.forEach(function (x) { self.addRow('p', x); });
    /* v1.8.8: while it plays, any key or tap skips to the end; once it is over only the Done button (or Esc) closes it, and keys scroll the list */
    this.onKey = function (ev) {
      if (ev.key === 'Shift' || ev.key === 'Control' || ev.key === 'Alt' || ev.key === 'Meta') return;
      if (self.done) { if (ev.key === 'Escape') { ev.preventDefault(); self.close(); } return; }
      ev.preventDefault(); self.skip();
    };
    dlg.addEventListener('click', function () { if (!self.done) self.skip(); });
    dlg.addEventListener('cancel', function (ev) { ev.preventDefault(); if (self.done) self.close(); else self.skip(); });
    dlg.addEventListener('close', function () { self.end(); });
    document.addEventListener('keydown', this.onKey, true);
    document.body.appendChild(dlg);
    gvOpenDlg(dlg);
    this.later(function () { self.round(); }, 400);
  }
  Play.prototype.later = function (fn, ms) { this.timers.push(setTimeout(fn, ms)); };
  /* v1.8.6: foes of one kind share one row (the lowest one's bar, "×N" alive); a boss keeps its own. x[4] = own row, x[5] = plain name. */
  Play.prototype.addFoe = function (x) {
    var own = !!x[4], base = x[5] || x[0], g = null;
    if (!own) for (var i = 0; i < this.groups.length; i++) if (!this.groups[i].own && this.groups[i].name === base) g = this.groups[i];
    if (!g) {
      var li = el('li', 'hprow foe'), bar = document.createElement('progress'), num = el('span', 'hpnum'), nm = el('span', 'hpname', base), cnt = el('b', 'hpx');
      bar.className = 'foebar';
      nm.appendChild(cnt);
      var fi = el('span', 'hpico', x[7] ? null : x[1]); if (x[7]) fi.innerHTML = x[7]; li.appendChild(fi); li.appendChild(nm);   /* x[7]: server-built icon markup (escaped by the server) */ li.appendChild(bar); li.appendChild(num);
      this.fl.appendChild(li);
      g = { li: li, bar: bar, num: num, cnt: cnt, name: base, own: own, members: [] };
      this.groups.push(g);
    }
    var row = { g: g, li: g.li, v: x[2], shown: x[2], max: x[3] };
    g.members.push(row);
    this.rows.f.push(row);
    this.paintGroup(g);
  };
  Play.prototype.paintGroup = function (g) {
    var alive = g.members.filter(function (m) { return m.shown > 0; });
    var low = alive.length ? alive.reduce(function (a, b) { return b.shown < a.shown ? b : a; }) : g.members[0];
    var v = Math.max(0, low.shown);
    g.bar.max = Math.max(1, low.max);
    g.bar.value = v;
    g.num.textContent = v + '/' + low.max;
    g.cnt.textContent = alive.length > 1 ? ' ×' + alive.length : '';
    g.li.classList.toggle('down', !alive.length);
  };
  Play.prototype.addRow = function (side, x) {
    if (side === 'f') { this.addFoe(x); return; }
    var li = el('li', 'hprow ' + (side === 'f' ? 'foe' : 'you'));
    var bar = document.createElement('progress');
    if (side === 'f') bar.className = 'foebar';
    var num = el('span', 'hpnum');
    var ic = el('span', 'hpico', x[4] && this.d.me ? null : (x[5] ? null : x[1]));
    if (!(x[4] && this.d.me) && x[5]) ic.innerHTML = x[5];   /* x[5]: server-built icon markup (escaped by the server) */
    if (x[4] && this.d.me) ic.appendChild(this.d.me.cloneNode(true));   /* v1.9.0: the player's gnome, from the server-drawn template */
    li.appendChild(ic); li.appendChild(el('span', 'hpname', x[0])); li.appendChild(bar); li.appendChild(num);
    (side === 'f' ? this.fl : this.pl).appendChild(li);
    var row = { li: li, bar: bar, num: num, v: x[2], max: x[3], name: x[0] };
    this.rows[side].push(row);
    this.paint(row, x[2]);
  };
  Play.prototype.paint = function (row, v) {
    if (row.g) { row.shown = v; this.paintGroup(row.g); return; }
    row.bar.max = Math.max(1, row.max);
    row.bar.value = v;
    row.num.textContent = v + '/' + row.max;
    row.li.classList.toggle('down', v <= 0);
  };
  Play.prototype.tween = function (row, to, hit, crit) {
    var from = row.v, t0 = null, self = this;
    row.v = to;
    if (hit) {
      row.li.classList.remove('tkr-hit', 'tkr-crit');
      void row.li.offsetWidth;
      row.li.classList.add('tkr-hit');
      if (crit) row.li.classList.add('tkr-crit');
    }
    if (from === to) return;
    if (hit && from > to) {   /* v2.0.10: a floating number */
      var fl = el('span', 'tkfloat ' + (crit ? 'crit' : 'hurt'), '−' + (from - to));
      fl.setAttribute('aria-hidden', 'true');
      row.li.appendChild(fl);
      setTimeout(function () { if (fl.parentNode) fl.parentNode.removeChild(fl); }, 1000);
    }
    function tick(t) {
      if (t0 === null) t0 = t;
      var k = Math.min(1, (t - t0) / TWEEN);
      self.paint(row, Math.round(from + (to - from) * k));
      if (k < 1) self.raf.push(requestAnimationFrame(tick));
      else if (to <= 0 && from > 0 && row.li.classList.contains('down')) { row.li.classList.remove('tkx-ko'); void row.li.offsetWidth; row.li.classList.add('tkx-ko'); }   /* v2.0.10: it fell */
    }
    this.raf.push(requestAnimationFrame(tick));
  };
  Play.prototype.lines = function (r) {
    var list = this.list;
    r.l.forEach(function (h) {
      var li = document.createElement('li');
      li.innerHTML = h;   /* escaped by the server (trek_line_html) */
      if (/critical/i.test(li.textContent)) li.className = 'tkr-pop';
      list.appendChild(li);
    });
    list.scrollTop = list.scrollHeight;   /* v1.8.8: every line is kept; the list follows the newest */
  };
  Play.prototype.apply = function (r, instant) {
    var self = this, txt = r.l.map(function (h) { var d = document.createElement('div'); d.innerHTML = h; return d.textContent; });   /* escaped by the server */
    var crit = function (name) { return txt.some(function (t) { return /critical/i.test(t) && t.indexOf('hits ' + name + ' for ') >= 0; }); };   /* a crit flashes the row it landed on */
    (r.nf || []).forEach(function (x) {
      self.addRow('f', x);
      if (!instant && x[6] && window.gvFoePop) window.gvFoePop(x[6], self.dlg);   /* v2.0.10: a new foe or boss joins mid-fight */
      else if (window.gvFoeSeen) window.gvFoeSeen([x[5] || x[0]]);
    });
    this.rows.f.forEach(function (row, k) {
      var v = r.f[k]; if (v == null) return;
      if (instant) { row.v = v; self.paint(row, v); } else self.tween(row, v, v < row.v, crit(row.g ? row.g.name : row.name));
    });
    var mine = function () {
      self.rows.p.forEach(function (row, k) {
        var v = r.p[k]; if (v == null) return;
        if (instant) { row.v = v; self.paint(row, v); } else self.tween(row, v, v < row.v, false);   /* foes never crit */
      });
    };
    if (instant) mine(); else this.later(mine, 260);
  };
  Play.prototype.label = function (i) { gvIcoLine(this.title, 'ico-sword', ' Round ' + (this.d.s.n + i - 1)); };
  Play.prototype.round = function () {
    var r = this.d.r[this.i++];
    if (!r) { this.finish(); return; }
    this.label(this.i);
    this.lines(r);
    this.apply(r, false);
    if (this.i >= this.d.r.length) this.later(function (s) { return function () { s.finish(); }; }(this), this.step + 250);
    else this.later(function (s) { return function () { s.round(); }; }(this), this.step);
  };
  /* all rounds shown: it stays open (v1.8.8) so the whole fight can be read; the Done button closes it */
  Play.prototype.over_ = function () {
    this.done = true;
    this.hint.textContent = 'Scroll to read the whole fight';
    this.list.removeAttribute('aria-hidden');
    this.list.setAttribute('tabindex', '0');
    this.list.scrollTop = this.list.scrollHeight;
    this.btn.hidden = false;
    this.dlg.classList.add('ended');
    try { this.btn.focus({ preventScroll: true }); } catch (e) { /* old browser */ }
  };
  Play.prototype.finish = function () {
    if (this.done) return;
    this.over_();
  };
  Play.prototype.skip = function () {
    if (this.done) return;
    this.timers.forEach(clearTimeout); this.timers = [];
    this.raf.forEach(cancelAnimationFrame); this.raf = [];
    while (this.i < this.d.r.length) { var r = this.d.r[this.i++]; this.lines(r); this.apply(r, true); }
    this.label(this.d.r.length);
    this.over_();
  };
  Play.prototype.close = function () {
    var self = this;
    if (this.fading) return;
    this.fading = true;
    this.timers.forEach(clearTimeout); this.timers = [];
    this.dlg.classList.add('out');
    setTimeout(function () { gvCloseDlg(self.dlg); self.end(); }, 300);
  };
  Play.prototype.end = function () {
    if (this.over) return;
    this.over = true;
    this.timers.forEach(clearTimeout);
    this.raf.forEach(cancelAnimationFrame);
    document.removeEventListener('keydown', this.onKey, true);
    if (this.dlg.parentNode) this.dlg.parentNode.removeChild(this.dlg);
    if (cur === this) cur = null;
  };

  function scan() {
    var s = document.querySelector('.trekreplay:not([data-seen])');
    if (!s) return;
    s.setAttribute('data-seen', '1');
    var data = null;
    try { data = JSON.parse(s.getAttribute('data-replay') || ''); } catch (e) { data = null; }
    var tpl = s.querySelector('template.meico-tpl');
    if (data && tpl && tpl.content) data.me = tpl.content;
    s.parentNode.removeChild(s);
    if (!data || !data.r || !data.r.length || !data.s || reduce() || typeof gvOpenDlg !== 'function') return;
    if (cur) cur.end();
    cur = new Play(data);
  }
  scan();
  if (window.MutationObserver) new MutationObserver(function () { if (document.querySelector('.trekreplay:not([data-seen])')) scan(); }).observe(document.querySelector('main') || document.body, { childList: true, subtree: true });
})();

/* v1.8.8: the fight log boxes ("Show all" on the fight screen, "Last fight" on the Log tab) show the newest line: scroll them to the bottom when opened or shown. */
(function () {
  function down(box) { if (box) box.scrollTop = box.scrollHeight; }
  document.addEventListener('toggle', function (ev) {
    var d = ev.target;
    if (d && d.classList && d.classList.contains('trekall') && d.open) down(d.querySelector('.tkall'));
  }, true);
  function scan() { [].forEach.call(document.querySelectorAll('.tklastfight .tkall, .trekwhat > ul.trekrounds'), down); }   /* v2.0.18: the fight screen's short feed shows the newest line too */
  scan();
  if (window.MutationObserver) new MutationObserver(scan).observe(document.querySelector('main') || document.body, { childList: true, subtree: true });
})();
