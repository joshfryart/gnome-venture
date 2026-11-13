/* v1 playable demo: plays the part of the SERVER. The game's own page scripts (pfparts.js, pfv1box.js, pfboardv1.js) and stylesheets (style.css, pfight.css, pfv1.css) run unchanged on markup
   built by views.js; this file holds the gnome and the fight in memory (tools/pfengine.js = the PHP engine, tools/pfdemo_v1/pfd.js = the deck model), answers the page's requests
   (preview, lit-spot numbers, flip, End turn, Pass, Run, End fight, Let's fight, box and starter posts) and swaps the page content in place, like the site does. */
(function () {
  'use strict';
  var PFE = window.PFE, PFD = window.PFD, PFV = window.PFV, D = window.__DATA, ART = window.__ART, SRC = window.__SRC, C = D.consts;
  document.body.classList.add('game'); document.body.setAttribute('data-area', 'world');
  var main = document.getElementById('main'), nav = document.getElementById('nav');
  function safe(f) { try { return f(); } catch (e) { return null; } }
  function esc(x) { return PFV.e(x); }

  // ---- storage: the page may not be allowed to use it (a sandboxed frame): keep the same calls working in memory
  function shim(name) {
    var ok = safe(function () { var s = window[name]; s.setItem('pfdemo', '1'); s.removeItem('pfdemo'); return true; });
    if (ok) return;
    var m = {}; var st = { getItem: function (k) { return Object.prototype.hasOwnProperty.call(m, k) ? m[k] : null; }, setItem: function (k, v) { m[k] = String(v); }, removeItem: function (k) { delete m[k]; }, clear: function () { m = {}; }, key: function (i) { return Object.keys(m)[i] || null; }, get length() { return Object.keys(m).length; } };
    try { Object.defineProperty(window, name, { configurable: true, get: function () { return st; } }); } catch (e) {}
  }
  shim('sessionStorage'); shim('localStorage');

  // ---- art: files come from the page itself (data: URIs), under the base the scripts were given ('art/')
  var isrc = Object.getOwnPropertyDescriptor(HTMLImageElement.prototype, 'src');
  Object.defineProperty(HTMLImageElement.prototype, 'src', { configurable: true, enumerable: true, get: function () { return isrc.get.call(this); }, set: function (v) { var k = String(v).replace(/^art\//, ''); isrc.set.call(this, (String(v).indexOf('art/') === 0 && ART[k]) ? ART[k] : v); } });

  // ---- the game in memory
  var TUNE0 = { foe_x: 1, bar_x: 1, env_x: 1, sun: 2, bramble: 0.10, rain: 0.15, thorn: 0.10, mud: 0.25, limit: 3, envn: 2, lvl: 0, belt: 1, anim: '1' };
  var S = { src: PFD.blank(), cr: null, screen: 'box', tab: 'kit', enc: null, flash: null, seed: ((Date.now() % 100000) | 0) * 7919 + 13, tune: Object.assign({}, TUNE0), res: null, fights: 0 };
  safe(function () { var a = localStorage.getItem('pfvspd'); if (a === '0' || a === '2') S.tune.anim = a; });
  var scrollMem = 0;

  function creature(slug) { return PFD.creature(slug || S.cr || D.creatures[0].slug); }
  function fightLevel(c) { return Math.max(1, c.level + (S.tune.lvl | 0)); }
  function ctx(c) { c = c || (S.cr ? creature(S.cr) : D.creatures[0]); return { src: S.src, g: PFD.gnome(fightLevel(c)), tune: v1tune(), hp: PFD.gnome(fightLevel(c)).max, locked: locked() }; }
  function locked() { return !!(S.enc && S.enc.pf && !S.enc.pf.over); }
  function v1tune() {
    var t = S.tune, x = t.env_x;
    return { foe_x: t.foe_x, bar_x: t.bar_x, sun: t.sun, bramble: t.bramble * x, rain: t.rain * x, thorn: t.thorn * x, mud: t.mud * x, limit: t.limit, envn: t.envn };
  }
  function setBelt() { var tier = S.tune.belt; S.src.beltTier = tier; S.src.slots = C.belts[tier][0]; }

  // ---------------------------------------------------------------- the fight (pfight_state / pfight_do)
  function newState() {
    var c = creature(S.enc.slug), g = PFD.gnome(fightLevel(c)), src = S.src;
    var me = { hp: g.max, max_hp: g.max, stats: g.stats, deck: PFD.tiles(PFD.fightEntries(src), g.stats, {}, src.calling, src.ctier), luck: 0 };
    var s = PFE.newFight(me, PFE.clone(c), (S.seed += 7919), { blank: true, v1: v1tune() });
    s.decksize = me.deck.length;
    S.enc.pf = s; S.enc.hist = []; S.enc.replay = []; S.enc.snaps = {}; S.enc.snapn = 0; S.enc.snaplast = null; S.enc.histnew = 0; S.enc.note = '';
    S.fights++;
  }
  function parseMoves(raw) {
    var p = String(raw || '').split(';').filter(function (x) { return x.length; });
    if (p.length !== 1) return null; p = p[0].split(',');
    var n = function (x) { return /^\d+$/.test(x); };
    if (p.length === 3 && n(p[0]) && n(p[1]) && n(p[2])) return [[+p[0], +p[1], +p[2]]];
    if (p.length === 3 && p[0] === 'c' && n(p[1]) && n(p[2])) return [['c', +p[1], +p[2]]];
    if (p.length === 4 && (p[0] === 'j' || p[0] === 'h') && n(p[1]) && n(p[2]) && 'LRTB'.indexOf(p[3]) >= 0) return [[p[0], +p[1], +p[2], p[3]]];
    return null;
  }
  function flash(msg, kind) { S.flash = { msg: msg, kind: kind || 'ok' }; }
  function round1(x) { return Math.round(x * 10) / 10; }
  /** One POST of the fight page (pfight_do). Returns true when the fight page should be shown again. */
  function fightDo(doo, f) {
    var enc = S.enc, s = enc && enc.pf, c = enc ? creature(enc.slug) : null; if (!s) return false;
    if (String(f.nonce) !== String(s.nonce)) { flash('That page is from another fight. Here is the current one.', 'err'); return true; }
    if (doo === 'pf_finish') {
      if (enc.lost && (s.over === 'defeat' || s.over === 'stall')) { flash(s.over === 'defeat' ? 'You are home and rested. (Demo: pick another creature.)' : 'It wandered off. (Demo: pick another creature.)', 'ok'); endEnc(); return true; }
      if (enc.won) { flash(s.over === 'charmed' ? 'The ' + c.name + ' is charmed. You collect a gift. (Demo: no loot is kept.)' : 'You collect the loot. (Demo: no loot is kept.)', 'ok'); endEnc(); return true; }
      return false;
    }
    var rp0 = { bar: round1(s.bar.now), fh: round1(s.fh.now), hp: s.me.hp, g: s.me.block };
    var prev = s.v1 ? { ter: s.ter || {}, envs: s.envs || [], aim: (s.foe && s.foe.plan) || null } : null; if (prev && s.v1.env) prev.env = PFE.view(s).env;
    var r = null;
    if (doo === 'pf_run') { if (s.over || !s.run_ok) { flash('You cannot run from this one.', 'err'); return true; } s.over = 'run'; }
    else if (doo === 'pfb_flip') { var err = PFE.flip(s, parseInt(f.hand, 10), parseInt(f.turn, 10)); if (err) { if (err !== 'stale') flash(err, 'err'); } return true; }
    else if (doo === 'pfb_play' && s.start) {
      var mv = parseMoves(f.moves), cx = Math.floor(s.w / 2), cy = Math.floor(s.h / 2), side = null;
      if (mv && typeof mv[0][0] === 'number') { var dx = mv[0][1] - cx, dy = mv[0][2] - cy; if (Math.abs(dx) + Math.abs(dy) === 1) side = dx < 0 ? 'L' : (dx > 0 ? 'R' : (dy < 0 ? 'T' : 'B')); }
      if (side === null) { flash('Pick a spot next to the blank.', 'err'); return true; }
      var mine = (s.me.hand[mv[0][0]] || {}).n || '', er = PFE.start(s, mv[0][0], side);
      if (er) { flash(er, 'err'); return true; }
      var nm = { L: 'left', R: 'right', T: 'top', B: 'bottom' }, sideOf = function (p) { return p.x < cx ? 'left' : (p.x > cx ? 'right' : (p.y < cy ? 'top' : 'bottom')); }, foe = [];
      Object.keys(s.pcs).forEach(function (id) { var p = s.pcs[id]; if (p.by === 'foe') foe.push('the ' + c.name + ' put ' + p.tile.n + ' (' + p.tile.t + ' ' + (p.tile.v | 0) + ') on the ' + sideOf(p)); });
      enc.note = 'You put ' + mine + ' on the ' + nm[side] + '; ' + foe.join(', ') + '. Turn 1: place a piece.'; enc.replay = []; enc.histnew = 0;
    } else if (doo === 'pfb_play' || doo === 'pfb_pass') {
      if (doo === 'pfb_pass') r = PFE.pass(s, parseInt(f.turn, 10));
      else { var moves = parseMoves(f.moves); r = moves === null ? { ev: [], err: 'Those moves are not valid.' } : PFE.play(s, moves, parseInt(f.turn, 10)); }
      if (r.err === 'stale') { flash('That turn has already passed.', 'err'); return true; }
      if (r.err) { flash(r.err, 'err'); return true; }
      enc.replay = []; enc.replay0 = rp0; if (prev) enc.prev = prev;
      var snaps = enc.snaps || {}, sn = enc.snapn | 0, cur = enc.snaplast === undefined ? null : enc.snaplast;
      r.ev.forEach(function (e) {
        if (e.snap) { snaps[++sn] = e.snap; cur = sn; }
        enc.hist.push(PFE.chipEvent(e, cur));
        var ln = PFE.line(e, c.name), rp = { id: (e.id !== undefined && e.id !== null) ? +e.id : null, by: String(e.by), ta: String(e.ta || e.by), ln: ln, bar: e.barnow !== undefined ? e.barnow : null, fh: e.fhnow !== undefined ? e.fhnow : null, hp: e.hpnow !== undefined ? e.hpnow : null, g: e.gnow !== undefined ? e.gnow : null, n: String(e.n || ''), t: String(e.t || '') };
        if (e.env !== undefined) { rp.env = String(e.env); rp.x = e.x !== undefined ? e.x : null; rp.y = e.y !== undefined ? e.y : null; rp.dir = e.dir !== undefined ? e.dir : null; rp.moved = e.moved !== undefined ? e.moved : null; rp.ids = e.ids !== undefined ? e.ids : null; rp.me = e.me || 0; rp.foe = e.foe || 0; if (e.kind !== undefined) rp.kind = String(e.kind); if (e['for'] !== undefined) rp['for'] = String(e['for']); if (e.guard !== undefined) rp.guard = e.guard | 0; }
        if (e.note !== undefined) rp.note = String(e.note); if (e.used && e.used.length) rp.used = e.used; if (e.tw) rp.tw = e.tw; if (e.sun) rp.sun = 1; if (e.mud) rp.mud = 1; if (e.full) rp.full = 1;
        enc.replay.push(rp);
      });
      var keys = Object.keys(snaps).map(Number).sort(function (a, b) { return a - b; }).slice(-14), ns = {}; keys.forEach(function (k) { ns[k] = snaps[k]; });
      enc.snaps = ns; enc.snapn = sn; enc.snaplast = cur; enc.histnew = r.ev.length; enc.hist = enc.hist.slice(-30);
    } else return false;
    if (s.over && s.wear && !enc.wearsaved) {   // the fight is over, however it ended: the wear of the fight tools is saved, once
      enc.wearsaved = 1; enc.broke = PFD.wearAdd(S.src, s.wear);
    }
    if (s.over === 'seen_off' || s.over === 'charmed') { enc.won = s.over; return true; }
    if (s.over === 'defeat' || s.over === 'stall') { enc.lost = s.over; return true; }
    if (s.over === 'run') { S.res = { how: 'run', slug: c.slug, name: c.name, size: c.size, hp: s.me.hp, max: s.me.max, turns: s.turn, wear: PFD.wearRows(S.src, s) }; endEnc(); S.screen = 'result'; return true; }
    return true;
  }
  function endEnc() { S.enc = null; S.screen = 'creatures'; }

  // ---- what the page asks for without a page load (pfight_preview_out, pfight_cells_out, pfight_flip_out)
  function json(o) { return Promise.resolve({ ok: true, status: 200, json: function () { return Promise.resolve(o); } }); }
  function ajax(fd) {
    var doo = fd.get('do'), enc = S.enc, s = enc && enc.pf, c = enc && creature(enc.slug);
    if (!s || s.mode !== 'board') return { ok: false, err: 'no fight' };
    if (String(fd.get('nonce')) !== String(s.nonce)) return { ok: false, err: 'stale' };
    if (doo === 'pfb_preview') {
      var mv = parseMoves(fd.get('moves')); if (!mv) return { ok: false, err: 'moves' };
      var w = PFE.clone(s), before = +w.bar.now, fh0 = +w.fh.now, r = PFE.play(w, mv, parseInt(fd.get('turn'), 10), true);
      if (r.err) return { ok: false, err: r.err };
      return { ok: true, lines: r.ev.map(function (e) { return e.pluck !== undefined ? 'Pluck: a small chance to lift something.' : PFE.line(e, c.name); }), bar: [before, r.bar, r.max], fh: [fh0, r.fh, r.fhmax], over: r.over || null };
    }
    if (doo === 'pfb_cells') {
      if (parseInt(fd.get('turn'), 10) !== s.turn) return { ok: false, err: 'stale' };
      var i = String(fd.get('i')); if (i !== 'c' && !/^\d+$/.test(i)) return { ok: false, err: 'moves' };
      var o = { ok: true, cells: PFE.cellPreview(s, i === 'c' ? 'c' : +i) };
      if (s.v1 && s.v1.flip && i !== 'c') o.flipped = PFE.cellPreview(s, +i, true);
      return o;
    }
    if (doo === 'pfb_flip') {
      var er = PFE.flip(s, parseInt(fd.get('hand'), 10), parseInt(fd.get('turn'), 10));
      if (er) return { ok: false, err: er === 'stale' ? 'That turn has already passed. Reload the page.' : er };
      var v = PFE.view(s);
      return { ok: true, hand: v.hand.map(function (t) { return { e: t.e, flip: !!t.flip, canflip: !!t.canflip }; }), flip: v.flip || { on: false, used: false } };
    }
    return { ok: false, err: 'unknown' };
  }
  var realFetch = window.fetch;
  window.fetch = function (url, init) {
    var body = init && init.body;
    if (body && typeof body.get === 'function' && /^pfb_(preview|cells|flip)$/.test(String(body.get('do')))) return json(ajax(body));
    var u = String(url);
    if (u.indexOf('atlas.json') >= 0) return json(window.__ATLAS); if (u.indexOf('rim.json') >= 0) return json(window.__RIM);
    return realFetch ? realFetch.apply(window, arguments) : Promise.reject(new Error('blocked'));
  };

  // ---------------------------------------------------------------- pages
  function pickerHtml() {
    var cur = S.cr, h = '<div class="box pfv pfv-pick" id="pfv-pick"><div class="hrow"><h2>🐾 Meet a creature</h2><span class="chip">' + (S.fights) + ' fight' + (S.fights === 1 ? '' : 's') + '</span></div>'
      + '<p class="hint">Pick a creature. You see its pieces first, then fight on a board of its size. Your gnome is the same level as the creature unless you change it in Tuning.</p><ul class="crgrid">';
    D.creatures.forEach(function (q) {
      h += '<li><button type="button" class="crb' + (cur === q.slug ? ' on' : '') + '" data-meet="' + esc(q.slug) + '"><img src="' + (ART['mini-' + q.slug + '.png'] || '') + '" alt=""><b>' + esc(q.name) + '</b><small><i class="szd ' + esc(q.size) + '"></i>' + esc(q.size) + ' · lv ' + q.level + '</small></button></li>';
    });
    h += '</ul><p class="hint">' + D.creatures.length + ' of the game’s 88 creatures: their pieces are the game’s own (class base 4, region, size or boss, 3 unique).</p>';
    h += '<details class="pfv-deckfold"><summary>About this demo <span>what is real</span></summary><p class="hint">The rules are the shipped engine (the same code the tests check against the server). The pages and scripts are the game’s own. Not here: loot, the map, the pal book, buying belts, upgrades. Your gnome is a sample one: level and health follow the creature.</p></details></div>';
    return h;
  }
  function resultPage() {
    return PFV.resultHtml(S.res, '<form method="post" class="grow"><input type="hidden" name="do" value="pfv_continue"><button class="btn primary" id="pf-end">Continue</button></form>');
  }
  function artData() { return '<i id="pfight" hidden></i><script type="application/json" id="pf-data">' + JSON.stringify({ art: 'art/', parts: 'art/parts/', mods: {} }) + '</script>'; }
  function page() {
    var starterOk = Array.isArray(S.src.starter), x = ctx(S.enc ? creature(S.enc.slug) : null);
    if (S.screen === 'result' && S.res) return { html: resultPage() + artData(), fight: false };
    if (S.screen === 'box') return { html: PFV.boxHtml(x, S.tab) + artData(), fight: false };
    if (S.screen === 'creatures' || !S.enc) return { html: pickerHtml(), fight: false, plain: true };
    var c = creature(S.enc.slug);
    if (!starterOk) return { html: PFV.starterHtml(x, true) + artData(), fight: false };
    if (!S.enc.pfgo) return { html: PFV.prefightHtml(x, c) + artData(), fight: false };
    if (!S.enc.pf) newState();
    var wear = S.enc.pf.over ? PFD.wearRows(S.src, S.enc.pf) : [];
    return { html: PFV.fightHtml({ c: c, s: S.enc.pf, enc: S.enc, src: S.src, g: x.g, wear: wear }), fight: true };
  }

  var injected = [];
  function runScripts(names) {
    injected.forEach(function (n) { if (n.parentNode) n.parentNode.removeChild(n); }); injected = [];
    names.forEach(function (nm) { var el = document.createElement('script'); el.textContent = SRC[nm]; document.body.appendChild(el); injected.push(el); });
  }
  function themeSync() { var t = document.documentElement.getAttribute('data-theme'); document.body.classList.toggle('dark', t === 'dark'); }
  function render(keepScroll) {
    if (window.__pfbOff) safe(window.__pfbOff); if (window.__pfvOff) safe(window.__pfvOff);
    var y = keepScroll ? window.scrollY : 0, p = page();
    var fl = S.flash ? '<p class="note' + (S.flash.kind === 'err' ? ' warn' : '') + '" role="status">' + esc(S.flash.msg) + '</p>' : ''; S.flash = null;
    main.innerHTML = (p.fight ? '' : fl) + p.html;
    if (p.fight && fl) { var f = main.querySelector('#pf-preview'); if (f) f.insertAdjacentHTML('beforebegin', fl.replace('class="note', 'class="pf-preview help note')); }
    document.documentElement.classList.remove('pfv-dopen');
    runScripts(p.fight ? ['pfx', 'pfparts', 'pfv1box', 'pfboardv1'] : (p.plain ? [] : ['pfparts', 'pfv1box']));
    if (!p.fight) { document.documentElement.style.removeProperty('--pfv-top'); window.scrollTo(0, y); }
    var onFight = !!(S.enc && !p.plain && S.screen !== 'box' && S.screen !== 'result');
    Array.prototype.forEach.call(nav.querySelectorAll('a'), function (a) { var k = a.getAttribute('data-go'); a.classList.toggle('on', k === (S.screen === 'box' ? 'box' : (S.screen === 'creatures' || S.screen === 'result' ? 'creatures' : 'adventure'))); if (k === 'adventure') a.classList.toggle('dim', !S.enc); a.removeAttribute('aria-current'); if (a.classList.contains('on')) a.setAttribute('aria-current', 'page'); });
    window.__demoState = { screen: S.screen, fight: !!p.fight };
  }
  function go(where, tab) {
    if (where === 'box') { S.screen = 'box'; if (tab) S.tab = tab; }
    else if (where === 'creatures') S.screen = 'creatures';
    else if (where === 'adventure') { if (S.enc) S.screen = 'adventure'; else S.screen = 'creatures'; }
    render();
  }
  function meet(slug) {
    if (S.enc && S.enc.pf && !S.enc.pf.over) { flash('A fight is under way. Finish it first.', 'err'); render(); return; }
    S.cr = slug; S.enc = { slug: slug, pfgo: 0 }; S.screen = 'adventure'; setBelt(); render();
  }

  // ---------------------------------------------------------------- the page's forms and links
  function formData(form) { var o = {}, fd = new FormData(form); fd.forEach(function (v, k) { if (k === 'pick[]') (o.pick = o.pick || []).push(v); else o[k] = v; }); return o; }
  document.addEventListener('submit', function (ev) {
    var form = ev.target; if (!form || ev.defaultPrevented || !main.contains(form)) return;
    ev.preventDefault();
    var f = formData(form), doo = f['do'];
    if (!doo) return;
    if (doo === 'pfv_continue') { S.res = null; S.screen = 'creatures'; render(); return; }
    if (doo === 'pfv_go') { if (!Array.isArray(S.src.starter)) flash('Pack your first Puzzle box before the fight.', 'err'); else if (S.enc) S.enc.pfgo = 1; render(); return; }
    if (/^pfd_/.test(doo)) {
      if (f.t) S.tab = f.t;
      var r = PFD.post(S.src, locked(), doo, f);
      if (!r[0] || doo === 'pfd_starter') flash(r[1], r[0] ? 'ok' : 'err');
      render(true); return;
    }
    if (/^pf(b_|_)/.test(doo)) { if (fightDo(doo, f) !== false) render(doo === 'pfb_flip'); return; }
  }, false);
  document.addEventListener('click', function (ev) {
    var t = ev.target; if (!t.closest) return;
    var meetB = t.closest('[data-meet]'); if (meetB) { meet(meetB.getAttribute('data-meet')); return; }
    var g = t.closest('#nav a[data-go]'); if (g) { ev.preventDefault(); go(g.getAttribute('data-go')); return; }
    var a = t.closest('#main a[href]'); if (!a) return;
    var href = a.getAttribute('href'); ev.preventDefault();
    if (/^puzzlebox\.php/.test(href)) { var m = /t=(\w+)/.exec(href); S.screen = 'box'; S.tab = m ? m[1] : 'kit'; render(); }
    else if (/^adventure\.php/.test(href)) go('adventure');
    else { flash('That part of the game is not in the demo.', 'ok'); render(true); }
  }, false);

  // ---------------------------------------------------------------- tuning drawer, theme
  var sheetEl = document.getElementById('sheet');
  function slider(k, lab, min, max, step, fmt, note) { return '<div class="tune"><label for="t-' + k + '">' + lab + '</label><output id="o-' + k + '">' + fmt(S.tune[k]) + '</output><input type="range" id="t-' + k + '" data-k="' + k + '" min="' + min + '" max="' + max + '" step="' + step + '" value="' + S.tune[k] + '">' + (note ? '<small>' + note + '</small>' : '') + '</div>'; }
  var fx = function (x) { return '×' + (Math.round(x * 100) / 100); }, fp = function (x) { return Math.round(x * 100) + '%'; };
  function tuning() {
    sheetEl.hidden = false;
    sheetEl.innerHTML = '<button type="button" class="sheetbg" data-close="1" aria-label="Close tuning"></button><div class="sheet" role="dialog" aria-label="Tuning"><div class="sheet-in"><div class="hrow"><h2>Tuning</h2><button type="button" class="btn small" id="t-reset">Reset</button><button type="button" class="btn small primary" data-close="1">Done</button></div>'
      + '<p class="hint">These change the rules numbers of the NEXT fight (a fight under way keeps its own).</p>'
      + slider('foe_x', 'Creature strength', 0.4, 1.6, 0.05, fx, 'Multiplies what its pieces play for.') + slider('bar_x', 'Charm bar size', 0.5, 1.6, 0.05, fx, 'Bigger = harder to charm.')
      + slider('env_x', 'Environment strength', 0.5, 2, 0.1, fx, 'Scales Bramble, Rain, Thornburst and Mud together.')
      + slider('sun', 'Sun', 1, 4, 0.5, function (x) { return '×' + x; }, 'How much a Sun multiplies the chain.') + slider('bramble', 'Bramble', 0, 0.3, 0.01, fp, 'Share of the other side’s health.')
      + slider('rain', 'Rain guard', 0, 0.4, 0.01, fp) + slider('thorn', 'Thornburst', 0, 0.3, 0.01, fp) + slider('mud', 'Mud teeth', 0, 0.5, 0.05, fp, 'A piece next to a Mud counts this much less.')
      + slider('limit', 'Use-up limit', 2, 6, 1, function (x) { return x + '+'; }, 'A chain this long uses its pieces up.') + slider('envn', 'Environment pieces a round', 1, 3, 1, function (x) { return x; })
      + slider('lvl', 'Your level vs the creature', -8, 4, 1, function (x) { return x > 0 ? '+' + x : x; }, 'Below 0 makes it harder.')
      + '<div class="tsel"><label for="t-belt">Fight belt (bought in the game)</label><select id="t-belt" data-k="belt"><option value="1">I · 2 slots</option><option value="2">II · 3 slots</option><option value="3">III · 4 slots</option></select></div>'
      + '<div class="tsel"><label for="t-anim">Animation</label><select id="t-anim" data-k="anim"><option value="1">Normal</option><option value="2">Fast</option><option value="0">Skip</option></select></div></div></div>';
    sheetEl.querySelector('#t-belt').value = String(S.tune.belt); sheetEl.querySelector('#t-anim').value = String(S.tune.anim);
  }
  sheetEl.addEventListener('input', function (ev) {
    var k = ev.target.getAttribute && ev.target.getAttribute('data-k'); if (!k || ev.target.tagName !== 'INPUT') return;
    S.tune[k] = +ev.target.value; var o = sheetEl.querySelector('#o-' + k); if (o) o.textContent = (k === 'bramble' || k === 'rain' || k === 'thorn' || k === 'mud') ? fp(S.tune[k]) : (k === 'lvl' ? (S.tune[k] > 0 ? '+' + S.tune[k] : S.tune[k]) : (k === 'sun' ? '×' + S.tune[k] : (k === 'limit' ? S.tune[k] + '+' : (k === 'envn' ? S.tune[k] : fx(S.tune[k])))));
  });
  sheetEl.addEventListener('change', function (ev) {
    var k = ev.target.getAttribute && ev.target.getAttribute('data-k'); if (!k || ev.target.tagName !== 'SELECT') return;
    if (k === 'belt') { S.tune.belt = +ev.target.value; if (!locked()) setBelt(); }
    else { S.tune.anim = ev.target.value; safe(function () { localStorage.setItem('pfvspd', S.tune.anim); }); }
  });
  sheetEl.addEventListener('click', function (ev) {
    if (ev.target.closest('[data-close]')) { sheetEl.hidden = true; sheetEl.innerHTML = ''; render(true); return; }
    if (ev.target.closest('#t-reset')) { S.tune = Object.assign({}, TUNE0); if (!locked()) setBelt(); tuning(); }
  });
  document.getElementById('b-tune').addEventListener('click', tuning);
  document.getElementById('b-theme').addEventListener('click', function () { var t = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark'; document.documentElement.setAttribute('data-theme', t); themeSync(); });
  safe(function () { document.documentElement.setAttribute('data-theme', window.matchMedia && matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'); }); themeSync();

  window.__demo = { S: S, PFE: PFE, PFD: PFD, go: go, meet: meet, render: render, fightDo: fightDo, tuning: tuning };
  setBelt(); render();
})();
