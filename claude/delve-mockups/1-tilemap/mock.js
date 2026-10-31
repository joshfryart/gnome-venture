/* Delve mockup 1: top-down tile map. Demo only: fog, torch light with line of sight, tap to walk (BFS), finds, keys, traps, shrine, chest.
   CSP-safe: no inline styles, no style properties; everything is classes. */
(() => {
  'use strict';
  const IMG = '../../../game/assets/img/';
  const MAP = [
    '###############',
    '#S...#.....#M.#',
    '#.,..#.##..#..#',
    '#....T..#.....#',
    '##.####.#.###.#',
    '#...M#..#C#...#',
    '#.#..#.##.#.#.#',
    '#.#H.....E..#.#',
    '#.##.###.####.#',
    '#P...,.~~#.TK.#',
    '#.###.#..#.####',
    '#..G#.#.,#.####',
    '##.##.#.##.D..#',
    '#X....T....#.B#',
    '###############',
  ];
  const W = 15, H = 15;
  // what lives on a tile
  const THING = {
    M: { name: 'Glowcap', img: 'ico/ico-mushroom.png', kind: 'pick', note: 'into your bag' },
    G: { name: 'Cave gem', img: 'ico/ico-gem.png', kind: 'pick', note: 'rare find' },
    P: { name: 'Potion', img: 'ico/ico-test-tube.png', kind: 'pick', note: '+1 potion' },
    K: { name: 'Rusty key', img: 'ico/ico-key.png', kind: 'pick', note: 'opens a door on this floor' },
    C: { name: 'Old chest', img: 'chest.png', kind: 'block', verb: 'Open', note: 'Something rattles inside' },
    B: { name: 'The hoard', img: 'chest.png', kind: 'block', verb: 'Open', note: 'The big one', big: true },
    H: { name: 'Moss shrine', img: 'ico/ico-shrine.png', kind: 'block', verb: 'Rest', note: 'Heal and relight' },
    E: { name: 'Cave spider · Lv 6', img: 'ico/ico-spider.png', kind: 'block', verb: 'Fight', note: 'Guarding the nook', foe: true },
    D: { name: 'Locked door', img: 'ico/ico-lock.png', kind: 'block', verb: 'Unlock', note: 'Needs a key' },
    T: { name: 'Tripwire', img: 'trek/trek-bang.png', kind: 'trap', verb: 'Disarm', note: 'Nimble check' },
    X: { name: 'Way down', img: 'ico/ico-hole.png', kind: 'block', verb: 'Go deeper', note: 'Floor 2' },
    S: { name: 'Ladder up', img: 'ico/ico-ladder.png', kind: 'stand', note: 'The way out' },
  };
  const FINDS = ['M', 'G', 'P', 'K', 'C', 'B', 'M'];   // seven things to find on this floor (pips)
  const TORCH_MAX = 40;

  const st = {
    x: 1, y: 1, hp: 14, hpMax: 20, torch: 34, potions: 2, key: false,
    seen: new Set(), lit: new Set(), gone: new Set(), spotted: new Set(), opened: new Set(), found: 0,
    bag: new Map(), walking: false, used: new Set(),
  };
  const $ = (id) => document.getElementById(id);
  const mapEl = $('map'), miniEl = $('mini');
  const k = (x, y) => y * W + x;
  const tile = (x, y) => (x < 0 || y < 0 || x >= W || y >= H) ? '#' : MAP[y][x];
  const thing = (x, y) => { const t = tile(x, y); return (THING[t] && !st.gone.has(k(x, y))) ? t : ''; };

  /* ---- light ---- */
  const radius = () => 2 + 1 /* Lantern Lark */ - (st.torch <= TORCH_MAX * .25 ? 1 : 0);
  function los(x0, y0, x1, y1) {   // Bresenham; walls stop light (the far wall itself is seen)
    let dx = Math.abs(x1 - x0), dy = -Math.abs(y1 - y0), sx = x0 < x1 ? 1 : -1, sy = y0 < y1 ? 1 : -1, e = dx + dy, x = x0, y = y0;
    while (!(x === x1 && y === y1)) {
      if (!(x === x0 && y === y0) && tile(x, y) === '#') return false;
      const e2 = 2 * e;
      if (e2 >= dy) { e += dy; x += sx; }
      if (e2 <= dx) { e += dx; y += sy; }
    }
    return true;
  }
  function relight() {
    const r = radius(), fresh = [];
    st.lit = new Map();
    for (let y = st.y - r; y <= st.y + r; y++) for (let x = st.x - r; x <= st.x + r; x++) {
      if (x < 0 || y < 0 || x >= W || y >= H) continue;
      const d = Math.hypot(x - st.x, y - st.y);
      if (d > r + .3 || !los(st.x, st.y, x, y)) continue;
      st.lit.set(k(x, y), d <= r - 1.5 ? 1 : d <= r - .5 ? 2 : 3);
      if (!st.seen.has(k(x, y))) { st.seen.add(k(x, y)); fresh.push(k(x, y)); }
      if (tile(x, y) === 'T' && d <= 2.3 && !st.spotted.has(k(x, y))) { st.spotted.add(k(x, y)); fresh.push('trap'); }   // Grotto Glim spots traps 2 tiles out
    }
    return fresh;
  }

  /* ---- walking ---- */
  const blocks = (x, y) => { const t = tile(x, y); if (t === '#') return true; const th = thing(x, y); return th && (THING[th].kind === 'block' || (THING[th].kind === 'trap' && st.spotted.has(k(x, y)))); };
  function path(tx, ty) {   // to the tile, or to the nearest side of a thing that blocks
    const goals = new Set();
    if (blocks(tx, ty)) [[1, 0], [-1, 0], [0, 1], [0, -1]].forEach(([dx, dy]) => { if (!blocks(tx + dx, ty + dy) && st.seen.has(k(tx + dx, ty + dy))) goals.add(k(tx + dx, ty + dy)); });
    else goals.add(k(tx, ty));
    const prev = new Map([[k(st.x, st.y), -1]]), q = [[st.x, st.y]];
    while (q.length) {
      const [x, y] = q.shift();
      if (goals.has(k(x, y))) { const p = []; let c = k(x, y); while (c !== -1) { p.unshift([c % W, Math.floor(c / W)]); c = prev.get(c); } return p.slice(1); }
      for (const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
        const nx = x + dx, ny = y + dy, nk = k(nx, ny);
        if (prev.has(nk) || !st.seen.has(nk) || blocks(nx, ny)) continue;
        prev.set(nk, k(x, y)); q.push([nx, ny]);
      }
    }
    return null;
  }
  function walk(p, done) {
    st.walking = true;
    mapEl.classList.add('walking');
    const stepNext = () => {
      if (!p.length) { st.walking = false; mapEl.classList.remove('walking'); draw(); done && done(); return; }
      const [x, y] = p.shift();
      st.x = x; st.y = y;
      st.torch = Math.max(0, st.torch - 1);
      const fresh = relight();
      const th = thing(x, y);
      if (th && THING[th].kind === 'pick') pick(x, y, th);
      if (fresh.includes('trap')) { p.length = 0; say('Wait. A tripwire, just ahead.'); }
      else if (fresh.length > 4 && Math.random() < .35) say(['Cold air from the dark.', 'Roots creak overhead.', 'Something skitters away.'][Math.floor(Math.random() * 3)]);
      draw(fresh);
      setTimeout(stepNext, 120);
    };
    stepNext();
  }

  /* ---- finds ---- */
  let findTimer = 0;
  function moment(name, img, note) {
    const f = $('find');
    $('findName').textContent = name; $('findNote').textContent = note;
    $('findImg').src = IMG + img;
    f.hidden = false; f.classList.remove('go'); void f.offsetWidth; f.classList.add('go');
    clearTimeout(findTimer); findTimer = setTimeout(() => { f.hidden = true; }, 2600);
    const bag = $('bagBtn'); bag.classList.remove('bump'); void bag.offsetWidth; bag.classList.add('bump');
  }
  function addBag(name, img, n = 1) { const b = st.bag.get(name) || { img, n: 0 }; b.n += n; st.bag.set(name, b); }
  function pick(x, y, t) {
    st.gone.add(k(x, y)); st.found++;
    const T = THING[t];
    if (t === 'K') { st.key = true; }
    else if (t === 'P') { st.potions++; }
    else addBag(T.name, T.img);
    moment(T.name, T.img, T.note);
    say('Found: ' + T.name + '.');
  }

  /* ---- verbs ---- */
  function act(x, y) {
    const t = thing(x, y); if (!t) return;
    const T = THING[t];
    if (t === 'C' || t === 'B') return openChest(x, y, t);
    if (t === 'H') {
      if (st.used.has(k(x, y))) return;
      st.used.add(k(x, y)); st.hp = Math.min(st.hpMax, st.hp + 6); st.torch = TORCH_MAX;
      relight(); moment('Torch relit', 'ico/ico-fire.png', 'and +6 health'); say('The moss glows. You feel better.'); return draw();
    }
    if (t === 'D') {
      if (!st.key) { say('Locked. The key is somewhere on this floor.'); return; }
      st.key = false; st.gone.add(k(x, y)); relight(); say('The door swings open.'); return draw(relight());
    }
    if (t === 'T') {
      st.gone.add(k(x, y));
      if (Math.random() < .7) { addBag('Brass spring', 'ico/ico-toolbox.png'); moment('Brass spring', 'ico/ico-toolbox.png', 'tripwire disarmed'); say('Click. Safe.'); }
      else { st.hp = Math.max(1, st.hp - 3); hurt(); say('Snap! −3 health.'); }
      return draw();
    }
    if (t === 'E') { fightAt = k(x, y); return $('fightDlg').showModal(); }
    if (t === 'X') { say('Floor 2 is the next mockup.'); return; }
  }
  let fightAt = -1;
  $('fightDlg').addEventListener('close', () => {
    if ($('fightDlg').returnValue !== 'win') return;
    st.gone.add(fightAt); st.hp = Math.max(1, st.hp - 4); hurt();
    addBag('Spider silk', 'ico/ico-feather.png'); moment('Spider silk', 'ico/ico-feather.png', 'the spider scuttles off');
    $('p2Fill').className = 'dvfill w25 low';
    draw();
  });
  function hurt() { mapEl.classList.remove('hurt'); void mapEl.offsetWidth; mapEl.classList.add('hurt'); }

  const LOOT_C = [['Glowcap', 'ico/ico-mushroom.png', 2, ''], ['Old coin', 'ico/ico-coin.png', 14, ''], ['Spider silk', 'ico/ico-feather.png', 1, 'r']];
  const LOOT_B = [['Petals', 'ico/ico-money-bag.png', 180, ''], ['Cave gem', 'ico/ico-gem.png', 2, 'r'], ['Old scroll', 'ico/ico-scroll.png', 1, 'r'], ['Star stone', 'ico/ico-star.png', 1, 'l']];
  function openChest(x, y, t) {
    const d = $('chestDlg'), ul = $('chestLoot');
    $('chestTitle').textContent = t === 'B' ? 'The hoard!' : 'Old chest';
    d.classList.toggle('big', t === 'B');
    ul.textContent = '';
    (t === 'B' ? LOOT_B : LOOT_C).forEach(([n, img, c, r], i) => {
      const li = document.createElement('li');
      li.className = 'd' + i + (r ? ' r-' + r : '');
      li.innerHTML = '<img src="' + IMG + img + '" alt="" width="48" height="48"><b></b><span></span>';
      li.querySelector('b').textContent = n; li.querySelector('span').textContent = '×' + c;
      ul.appendChild(li);
      addBag(n, img, c);
    });
    st.gone.add(k(x, y)); st.found++;
    d.classList.remove('open'); d.showModal(); requestAnimationFrame(() => d.classList.add('open'));
    say(t === 'B' ? 'Floor cleared. +22 XP' : 'The lid creaks up.');
    draw();
  }

  /* ---- drawing ---- */
  function viewSize() {
    const cs = getComputedStyle(mapEl);
    return [parseInt(cs.getPropertyValue('--cols'), 10) || 9, parseInt(cs.getPropertyValue('--rows'), 10) || 9];
  }
  const FLOOR = (x, y) => ({ ',': 'roots', '~': 'mud', '.': 'f' + (1 + ((x * 7 + y * 13) % 3)) })[tile(x, y)] || 'f' + (1 + ((x * 7 + y * 13) % 3));
  function draw(fresh = []) {
    const [cols, rows] = viewSize();
    const x0 = Math.max(0, Math.min(W - cols, st.x - (cols >> 1)));
    const y0 = Math.max(0, Math.min(H - rows, st.y - (rows >> 1)));
    const freshSet = new Set(fresh);
    const frag = document.createDocumentFragment();
    for (let y = y0; y < y0 + rows; y++) for (let x = x0; x < x0 + cols; x++) {
      const key = k(x, y), b = document.createElement('button');
      b.type = 'button';
      b.dataset.x = x; b.dataset.y = y;
      const seen = st.seen.has(key), lit = st.lit.get(key), t = tile(x, y);
      let cls = 't';
      if (!seen) { cls += ' fog'; b.tabIndex = -1; b.disabled = true; b.setAttribute('aria-hidden', 'true'); }
      else {
        cls += t === '#' ? ' wall' : ' ' + FLOOR(x, y);
        cls += lit ? ' l' + lit : ' dim';
        if (freshSet.has(key)) cls += ' new n' + Math.min(4, Math.round(Math.hypot(x - st.x, y - st.y)));
        const th = thing(x, y);
        const show = th && (th !== 'T' || st.spotted.has(key)) && !(th === 'E' && !lit);
        if (show) {
          const T = THING[th];
          cls += ' has ' + (T.foe ? 'foe' : T.kind);
          const im = document.createElement('img');
          im.src = IMG + T.img; im.alt = ''; im.className = 'obj o-' + th;
          b.appendChild(im);
          b.setAttribute('aria-label', T.name);
        } else if (t !== '#') b.setAttribute('aria-label', 'Floor');
        if (t === '#') wallQuarters(b, x, y);
        if (t === '#') { b.disabled = true; b.tabIndex = -1; b.setAttribute('aria-hidden', 'true'); }
        if (Math.abs(x - st.x) + Math.abs(y - st.y) === 1 && show && THING[th].verb) cls += ' near';
      }
      if (x === st.x && y === st.y) {
        cls += ' me';
        const me = document.createElement('img');
        me.src = IMG + 'trek/trek-me.png'; me.alt = 'You'; me.className = 'meimg';
        b.appendChild(me);
      }
      b.className = cls;
      frag.appendChild(b);
    }
    mapEl.textContent = '';
    mapEl.appendChild(frag);
    hud(); mini(); ctx();
  }
  // A2 auto-join: for each quadrant, the two side neighbours and the diagonal pick one quarter of the sheet (col, row in 21 px units)
  const mass = (x, y) => tile(x, y) === '#';
  const QUAD = {
    tl: [[0, -1], [-1, 0], { both: '24', v: '04', h: '22', none: '02', inner: '20' }],
    tr: [[0, -1], [1, 0], { both: '14', v: '34', h: '12', none: '32', inner: '30' }],
    bl: [[0, 1], [-1, 0], { both: '23', v: '03', h: '25', none: '05', inner: '21' }],
    br: [[0, 1], [1, 0], { both: '13', v: '33', h: '15', none: '35', inner: '31' }],
  };
  function wallQuarters(b, x, y) {
    for (const [q, [[vx, vy], [hx, hy], m]] of Object.entries(QUAD)) {
      const v = mass(x + vx, y + vy), h = mass(x + hx, y + hy), d = mass(x + hx, y + vy);
      const s = v && h ? (d ? m.both : m.inner) : v ? m.v : h ? m.h : m.none;
      const sp = document.createElement('span');
      sp.className = 'q ' + q + ' s' + s;
      b.appendChild(sp);
    }
  }
  const pct = (a, b) => 'w' + Math.round(a / b * 20) * 5;
  function hud() {
    $('hpFill').className = 'dvfill ' + pct(st.hp, st.hpMax) + (st.hp / st.hpMax < .35 ? ' low' : '');
    $('meFill').className = $('hpFill').className;
    $('hpNum').textContent = $('meHp').textContent = st.hp + '/' + st.hpMax;
    const segs = $('torchSegs'); segs.textContent = '';
    const on = Math.ceil(st.torch / (TORCH_MAX / 10));
    for (let i = 0; i < 10; i++) { const s = document.createElement('i'); if (i < on) s.className = on <= 3 ? 'on low' : 'on'; segs.appendChild(s); }
    $('torchNum').textContent = 'R' + radius();
    $('potionCt').textContent = st.potions; $('potionBtn').disabled = !st.potions || st.hp >= st.hpMax;
    $('potionBtn').setAttribute('aria-label', 'Drink a potion (' + st.potions + ' left)');
    $('keySlot').classList.toggle('got', st.key);
    $('keySlot').setAttribute('aria-label', st.key ? 'You have a key' : 'No key yet');
    let n = 0; st.bag.forEach((v) => { n += v.n > 9 ? 1 : v.n; });
    $('bagCt').textContent = st.bag.size;
    const f = $('finds'); f.textContent = '';
    FINDS.forEach((_, i) => { const p = document.createElement('i'); if (i < st.found) p.className = 'on'; f.appendChild(p); });
    f.setAttribute('aria-label', 'Found ' + st.found + ' of ' + FINDS.length + ' on this floor');
  }
  function mini() {
    const frag = document.createDocumentFragment();
    for (let y = 0; y < H; y++) for (let x = 0; x < W; x++) {
      const s = document.createElement('i'), key = k(x, y);
      let c = '';
      if (x === st.x && y === st.y) c = 'me';
      else if (st.seen.has(key)) {
        const th = thing(x, y);
        c = tile(x, y) === '#' ? 'w' : 'f';
        if (th === 'C' || th === 'B') c += ' gold'; else if (th === 'E' || (th === 'T' && st.spotted.has(key))) c += ' ember';
        else if (th === 'D' || th === 'X' || th === 'H' || th === 'S') c += ' poi';
        else if (th && THING[th].kind === 'pick') c += ' item';
      }
      if (c) s.className = c;
      frag.appendChild(s);
    }
    miniEl.textContent = ''; miniEl.appendChild(frag);
  }
  let ctxAt = -1;
  function ctx() {
    let best = null;
    for (const [dx, dy] of [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]]) {
      const x = st.x + dx, y = st.y + dy, t = thing(x, y);
      if (!t || (t === 'T' && !st.spotted.has(k(x, y)))) continue;
      if (THING[t].verb || t === 'S') { best = [x, y, t]; break; }
    }
    const box = $('ctx'), btn = $('ctxBtn');
    if (!best) {
      box.classList.add('idle');
      $('ctxImg').src = IMG + 'trek/trek-foot-h.png';
      $('ctxName').textContent = 'Tap a lit tile'; $('ctxNote').textContent = 'Your torch shows the way';
      btn.hidden = true; ctxAt = -1; return;
    }
    const [x, y, t] = best, T = THING[t];
    box.classList.remove('idle');
    $('ctxImg').src = IMG + T.img; $('ctxName').textContent = T.name;
    let note = T.note, verb = T.verb, ok = true;
    if (t === 'D' && !st.key) { note = 'Find the key on this floor'; ok = false; }
    if (t === 'D' && st.key) note = 'Your key fits';
    if (t === 'H' && st.used.has(k(x, y))) { note = 'Rested here already'; ok = false; }
    if (t === 'S') { verb = 'Climb out'; }
    btn.hidden = !ok || !verb; btn.textContent = verb || '';
    btn.className = 'btn' + (T.foe ? ' red' : t === 'S' ? ' ghost' : '');
    $('ctxNote').textContent = note;
    ctxAt = k(x, y);
  }
  let logT = 0;
  function say(s) { const l = $('log'); l.textContent = s; l.classList.remove('say'); void l.offsetWidth; l.classList.add('say'); clearTimeout(logT); }

  /* ---- input ---- */
  mapEl.addEventListener('click', (e) => {
    const b = e.target.closest('button.t'); if (!b || st.walking) return;
    const x = +b.dataset.x, y = +b.dataset.y;
    if (x === st.x && y === st.y) return;
    const adj = Math.abs(x - st.x) + Math.abs(y - st.y) === 1;
    if (adj && thing(x, y) && blocks(x, y)) return act(x, y);
    const p = path(x, y);
    if (!p) { say('No way there yet.'); b.classList.add('nope'); setTimeout(() => b.classList.remove('nope'), 300); return; }
    walk(p);
  });
  $('ctxBtn').addEventListener('click', () => {
    if (ctxAt < 0) return;
    const x = ctxAt % W, y = Math.floor(ctxAt / W);
    if (tile(x, y) === 'S' && x === st.x && y === st.y) return $('leaveDlg').showModal();
    act(x, y);
  });
  $('potionBtn').addEventListener('click', () => { if (!st.potions) return; st.potions--; st.hp = Math.min(st.hpMax, st.hp + 6); say('Gulp. +6 health.'); draw(); });
  $('bagBtn').addEventListener('click', () => {
    const ul = $('bagList'); ul.textContent = '';
    st.bag.forEach((v, n) => { const li = document.createElement('li'); li.innerHTML = '<img src="' + IMG + v.img + '" alt="" width="32" height="32"><b></b><span></span>'; li.querySelector('b').textContent = n; li.querySelector('span').textContent = '×' + v.n; ul.appendChild(li); });
    $('bagEmpty').hidden = st.bag.size > 0;
    $('bagDlg').showModal();
  });
  $('leaveBtn').addEventListener('click', () => $('leaveDlg').showModal());
  $('leaveDlg').addEventListener('close', () => { if ($('leaveDlg').returnValue === 'yes') say('(Back to the World map.)'); });
  document.querySelectorAll('dialog').forEach((d) => d.addEventListener('click', (e) => { if (e.target === d) d.close(); }));   // tap outside closes
  $('dvTheme').addEventListener('click', () => { const r = document.documentElement; r.dataset.theme = r.dataset.theme === 'dark' ? 'light' : 'dark'; });
  addEventListener('resize', () => draw());

  /* ---- demo start: a few steps already walked, one find in the bag ---- */
  relight();
  [[2, 1], [3, 1], [3, 2], [3, 3], [2, 3], [2, 4], [2, 5], [3, 5], [4, 5], [4, 6], [4, 7]].forEach(([x, y]) => {
    st.x = x; st.y = y; st.torch--; relight();
    const th = thing(x, y); if (th && THING[th].kind === 'pick') { st.gone.add(k(x, y)); st.found++; addBag(THING[th].name, THING[th].img); }
  });
  const q = new URLSearchParams(location.search);
  if (q.get('theme')) document.documentElement.dataset.theme = q.get('theme');
  draw();
  if (q.has('find')) moment('Glowcap', 'ico/ico-mushroom.png', 'into your bag');
  if (q.has('chest')) { st.x = 9; st.y = 6; relight(); draw(); openChest(9, 5, 'C'); }
  if (q.has('hoard')) { st.seen = new Set([...Array(W * H).keys()]); st.x = 13; st.y = 12; relight(); draw(); openChest(13, 13, 'B'); }
})();
