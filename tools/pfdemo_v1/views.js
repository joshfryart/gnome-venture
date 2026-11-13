/* v1 playable demo: the page markup. A JS port of game/includes/pfdeck_view.php (starter, Puzzle box, pre-fight, result) and pfight_board_html() (the fight page) in game/includes/pfight_game.php.
   The game's own scripts (pfparts.js, pfv1box.js, pfboardv1.js) run on this markup unchanged; glue.js plays the server. */
(function (root, factory) { root.PFV = factory(root.PFE, root.PFD, root.__DATA, root.__ART); })(typeof globalThis !== 'undefined' ? globalThis : this, function (PFE, PFD, D, ART) {
  'use strict';
  var C = D.consts, TAGS = D.tags;
  var TYPE = { hurt: 'Hurt', guard: 'Guard', heal: 'Heal', charm: 'Charm', soothe: 'Soothe', trick: 'Trick', item: 'Item' };
  var CLASS_ICON = { 'Critter': '🐛', 'Bird': '🐦', 'Beast': '🐾', 'Reptile/Amphibian': '🦎', 'Water': '🐟', 'Plant/Fungus': '🍄' };
  var SRC_ICON = { basic: '🧩', knack: '🧩', calling: '🎩', crop: '🌾', craft: '🛠️', region: '🗺️', tool: '🔧', pal: '🐾' };
  var FOE_TAG = { quick: 'Quick: it plays one more piece this turn', evade: 'Evade: your next hit on it misses', bash: 'Bash: adds its guard to its next hit', poison: 'Poison: 2 ticks on your health',
    trip: 'Trip: you draw 1 fewer next round', heal: 'Recovers a little', thorns: 'Thorns: hitting its guard pricks you', hold: 'Hold: this guard lasts a turn longer', pierce: 'Pierce: ignores your guard' };
  var BOSS_MULT = 1.2, FIRE_MULT = 1.15;
  function e(x) { return String(x === undefined || x === null ? '' : x).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); }
  function jsonAttr(o) { return e(JSON.stringify(o)); }
  function art(f) { return ART[f] || ''; }
  function ucfirst(s) { s = String(s); return s.charAt(0).toUpperCase() + s.slice(1); }
  function tg(tag) { return TAGS[tag] || null; }

  /** pfv_entries: the values the gnome's pieces play for (the fight's gnome) and their four edges. */
  function entries(list, g, calling, ctier) {
    return list.map(function (en) {
      var t = PFD.tiles([en], g.stats, {}, calling, ctier)[0], o = Object.assign({}, en); o.v = t ? t.v : en.v; o.e = PFD.edges(en); return o;
    });
  }
  var lastExtra = '';
  function desc(p, extra) {
    lastExtra = extra || ''; var t = tg(p.tag);
    return (TYPE[p.t] || ucfirst(p.t)) + ' ' + (p.v | 0) + (p.rank ? ' · ' + C.rankName[p.rank] : '') + ' · stays ' + (p.life | 0) + ' rounds'
      + (['pal', 'tool', 'crop'].indexOf(p.src) >= 0 ? ' · Teamwork: ' + p.src : '') + (extra ? ' · ' + extra : '') + (t ? '. ' + t[1] : '') + (p.blurb ? '. ' + String(p.blurb).replace(/\.+$/, '') : '') + '.';
  }
  /** One piece cell (.pc): art (drawn by pfv1box.js from data-p), value, tag icon, name, expiry pips. o: cls, a, arg, owner, name (false = none), d, x, g, dur. */
  function pc(p, o) {
    o = o || {}; var life = Math.max(1, p.life || 3), px = ''; for (var i = 0; i < life; i++) px += '<i></i>';
    var t = tg(p.tag), own = o.owner || 'me';
    var artj = { t: p.t, e: p.e, tag: t ? String(p.tag) : '', o: own };
    var label = p.n + ', ' + (TYPE[p.t] || p.t) + ' ' + (p.v | 0) + (p.tag && p.tag !== 'pal' ? ', ' + p.tag : '') + (p.rank ? ', ' + C.rankName[p.rank] : '') + ', stays ' + life + ' rounds';
    var pcd = { n: String(p.n), t: String(p.t), ty: TYPE[p.t] || ucfirst(p.t), v: p.v | 0, rk: p.rank | 0, rn: p.rank ? C.rankName[p.rank] : '', src: String(p.src || ''), life: life,
      tag: t ? String(p.tag) : '', ti: t ? t[0] : '', tt: t ? t[1] : '', e: p.e, bl: String(p.blurb || ''), note: o.d !== undefined ? lastExtra : '', own: own };
    if (o.dur) pcd.dur = o.dur;
    var srcIco = (!t && ['pal', 'tool', 'crop'].indexOf(p.src) >= 0 && SRC_ICON[p.src]) ? '<span class="pc-t" aria-hidden="true">' + SRC_ICON[p.src] + '</span>' : '';
    return '<li' + (o.g !== undefined ? ' data-g="' + e(o.g) + '"' : '') + '><button type="button" class="pc' + (p.rank ? ' r' + p.rank : '') + (p.gear ? ' gear' : '') + (o.cls ? ' ' + e(o.cls) : '') + '"'
      + (o.a ? ' data-a="' + e(o.a) + '" data-arg="' + e(o.arg !== undefined ? o.arg : (p.key || '')) + '"' : '') + ' data-n="' + e(p.n) + '" data-d="' + e(o.d || '') + '" data-t="' + e(p.t) + '" data-pc="' + jsonAttr(pcd) + '"' + (o.x || '')
      + ' aria-label="' + e(label) + '"><i class="cvh" data-p="' + jsonAttr(artj) + '"></i><span class="pc-v" aria-hidden="true">' + (p.v | 0) + '</span>'
      + (t ? '<span class="pc-t" aria-hidden="true">' + t[0] + '</span>' : srcIco) + (o.name === false ? '' : '<span class="pc-n">' + e(p.n) + '</span>') + '<span class="pc-x' + (life < 3 ? ' few' : '') + '" aria-hidden="true">' + px + '</span></button></li>';
  }
  function slot(txt) { return '<li><div class="slot">' + txt + '</div></li>'; }
  function capPips2(n, max, cls, lab) { var h = ''; for (var i = 0; i < max; i++) h += '<i' + (i < n ? ' class="on"' : '') + '></i>'; return '<span class="capp ' + cls + '" role="img" aria-label="' + lab + ' ' + n + ' of ' + max + '" title="' + lab + ' ' + n + ' of ' + max + '">' + h + '</span>'; }
  function durbar(left, max) { var f = max > 0 ? left / max : 0; return '<span class="dur' + (left <= 0 ? ' zero' : (f <= .25 ? ' crit' : (f <= .5 ? ' low' : ''))) + '" role="img" aria-label="Durability ' + left + ' of ' + max + '"><i data-w="' + Math.round(f * 100) + '"></i></span>'; }

  function deckbar(d, slim) {
    var c = d.counts, kit = c.kit;
    var h = '<div class="meter" role="img" aria-label="Deck ' + c.n + ': kit ' + kit + ', belt ' + c.belt + ', pals ' + c.pals + '"><b>' + c.n + '</b><span class="stack"><span class="k" data-f="' + Math.max(1, kit) + '">🧩 ' + kit + '</span>'
      + (c.belt ? '<span class="b" data-f="' + c.belt + '">🔧 ' + c.belt + '</span>' : '') + (c.pals ? '<span class="p" data-f="' + c.pals + '">🐾 ' + c.pals + '</span>' : '') + '</span></div>';
    h += '<div class="teamrow"><b>Teamwork</b>';
    [['pal', '🐾'], ['tool', '🔧'], ['crop', '🌾']].forEach(function (x) { h += '<span class="chip' + (c.src[x[0]] ? '' : ' off') + '">' + x[1] + ' ' + x[0] + ' ' + c.src[x[0]] + '</span>'; });
    h += '<span>' + (c.team >= 3 ? '2 in a chain +30%, all 3 +60%' : (c.team === 2 ? 'both in one chain: +30%' : 'needs 2 of 3 sources')) + '</span></div>';
    if (slim) return h;
    var hm = d.harmony, f = hm.fam, tot = Math.max(1, f.body + f.mind + f.craft), top = Math.max(f.body, f.mind, f.craft) / tot, lk = Math.round(hm.link * 100), hd = Math.round(hm.hand * 100), seg = '';
    ['body', 'mind', 'craft'].forEach(function (k) { if (f[k]) seg += '<span class="' + k + '" data-f="' + f[k] + '">' + k + ' ' + Math.round(100 * f[k] / tot) + '%</span>'; });
    h += '<div class="harm" role="img" aria-label="Deck harmony: link rate ' + lk + ' percent, a hand links ' + hd + ' percent of the time"><b>Link rate</b><span class="hmeter' + (lk >= 30 ? ' good' : (lk >= 22 ? '' : ' low')) + '"><i data-w="' + Math.min(100, lk * 2) + '"></i><span>' + lk + '%</span></span><span class="chip" title="Chance that a hand of 5 has a piece that links">hand links ' + hd + '%</span></div>'
      + '<div class="harm"><b>Knobs</b><span class="stack fam">' + seg + '</span></div>'
      + '<p class="hint harmhint">' + (top >= 0.5 ? 'One family leads: easy chains, less Teamwork.' : 'Mixed families: more Teamwork, fewer links.') + ' Pals are body, tools craft, crops mind.</p>';
    return h;
  }
  function form(back) { return '<form method="post" id="pfv-f" hidden><input type="hidden" name="do" value=""><input type="hidden" name="key" value=""><input type="hidden" name="on" value=""><input type="hidden" name="tool" value="">' + (back || '') + '</form>'; }
  function autoHtml(on, back) {
    return '<form method="post" class="pfv-autof"><input type="hidden" name="do" value="pfd_auto"><input type="hidden" name="on" value="' + (on ? '0' : '1') + '">' + (back || '')
      + '<label class="sw"><input type="checkbox" id="pfv-auto"' + (on ? ' checked' : '') + '>Auto-use my current deck<span class="chip">' + (on ? 'on' : 'off') + '</span></label><noscript><button class="btn small">' + (on ? 'Turn off' : 'Turn on') + '</button></noscript></form>';
  }

  // ---------------------------------------------------------------- 1. the starter pick
  function starterHtml(ctx, inFight) {
    var src = ctx.src, d = PFD.deck(src), g = ctx.g;
    var mk = function (key) {
      var p = PFD.piece(key); if (!p) return null; var rank = p.rar === 'src' ? 1 : +p.rar;
      return { key: key, k: p.k, n: p.n, t: p.t, v: +p.v, r: p.r, tag: p.tag || '', src: p.src, ref: p.ref || '', rank: rank, life: (p.life | 0) || (p.tag === 'quick' ? 2 : (p.tag === 'hold' ? 4 : 3)), blurb: p.blurb || '', gear: false, tool: '', col: p.col, up: p.up };
    };
    var core = entries(C.core.map(mk).filter(Boolean), g, src.calling, src.ctier), off = entries(d.offer.map(mk).filter(Boolean), g, src.calling, src.ctier), tray = '', grid = '', kits = '';
    core.forEach(function (p) { tray += pc(p, { cls: 'lock', name: false, a: 'info', d: desc(p, 'core, always in') }); });
    for (var i = 0; i < C.picks; i++) tray += '<li class="pfv-ps" data-i="' + i + '"><div class="slot">' + (i + 5) + '</div></li>';
    off.forEach(function (p) { grid += pc(p, { a: 'spick', d: desc(p) }); });
    [['bold', '⚔️ Bold'], ['steady', '🛡️ Steady'], ['kind', '💗 Kind']].forEach(function (k) { kits += '<button class="btn" name="kit" value="' + k[0] + '" data-kit="' + e(d.kits[k[0]].join(',')) + '">' + k[1] + '</button>'; });
    var pp = ''; for (i = 0; i < C.picks; i++) pp += '<i></i>';
    return '<div class="box pbox pfv" id="pfv-starter" data-picks="' + C.picks + '">'
      + '<div class="hrow"><h2>🧩 Pack your box</h2><span class="chip warn" id="pfv-hurt" title="Hurt pieces (at least 2)">⚔️ <b>1</b></span><span class="chip"><b id="pfv-n">4</b>/10</span></div>'
      + (inFight ? '<p class="note">A creature is waiting. Pack your first Puzzle box, then you meet it.</p>' : '')
      + '<form method="post" id="pfv-sform"><input type="hidden" name="do" value="pfd_starter">'
      + '<ul class="pcg c5" id="pfv-tray" aria-label="Your box: 10 slots">' + tray + '</ul>'
      + '<div class="kits" role="group" aria-label="Quick kits">' + kits + '</div>'
      + '<div class="sl">Pick 6 <span class="pips" id="pfv-pips" role="img" aria-label="0 of 6">' + pp + '</span></div><ul class="pcg" id="pfv-offer">' + grid + '</ul>'
      + '<div class="pinfo" id="pfv-info" aria-live="polite"><span>Tap a piece to pick it, or take a kit.</span></div>'
      + '<span id="pfv-picks"></span><div class="actrow"><button class="btn primary grow" id="pfv-sgo" disabled>🧩 Pack the box</button></div></form></div>';
  }

  // ---------------------------------------------------------------- 2. the Puzzle box page
  function boxHtml(ctx, tab) {
    var src = ctx.src, d = PFD.deck(src), g = ctx.g, locked = !!ctx.locked;
    if (!d.starter) return starterHtml(ctx, false);
    if (['kit', 'belt', 'pals'].indexOf(tab) < 0) tab = 'kit';
    var c = d.counts, P = entries(d.pieces, g, src.calling, src.ctier), back = '<input type="hidden" name="t" value="' + tab + '">';
    var h = '<div class="box pbox pfv" id="pfv-box"' + (locked ? ' data-locked="1"' : '') + '><div class="hrow"><h2>🧩 Puzzle box</h2>' + capPips2(c.rare, C.rareCap, '', 'Rare') + capPips2(c.mw, C.mwCap, 'mw', 'Masterwork') + '</div>';
    h += '<nav class="tabs" aria-label="Puzzle box">';
    [['kit', 'Kit'], ['belt', 'Belt'], ['pals', 'Pals']].forEach(function (k) { h += '<a href="puzzlebox.php' + (k[0] === 'kit' ? '' : '?t=' + k[0]) + '"' + (k[0] === tab ? ' class="on" aria-current="page"' : '') + '>' + k[1] + '</a>'; });
    h += '</nav>' + deckbar(d, false);
    if (locked) h += '<p class="note">🔒 You are in a fight. The deck is locked until it is over. <a href="adventure.php">Back to the fight</a></p>';
    var hint = 'Tap a piece to read it.';
    if (tab === 'kit') {
      var grp = function (p) { return p.src === 'knack' || p.src === 'calling' ? 'basic' : p.src; };
      h += '<nav class="chips fbar" id="pfv-filt" aria-label="Filter by source">';
      [['all', 'All'], ['basic', '🧩'], ['crop', '🌾'], ['craft', '🛠️'], ['region', '🗺️']].forEach(function (k) { h += '<button type="button" data-g="' + k[0] + '"' + (k[0] === 'all' ? ' class="on"' : '') + ' aria-label="' + (k[0] === 'all' ? 'All pieces' : ucfirst(k[0]) + ' pieces') + '" aria-pressed="' + (k[0] === 'all' ? 'true' : 'false') + '">' + k[1] + '</button>'; });
      h += '</nav>';
      var inn = '', col = '';
      P.forEach(function (p) {
        if (p.gear) return;
        if (p.on) inn += pc(p, { cls: 'sel' + (p.out !== '' ? ' out' : ''), a: locked ? 'info' : 'tog', g: grp(p), d: desc(p, (p.out !== '' ? 'left out: over the rarity cap' : (p.core ? 'core' : ''))), x: ' data-on="1"' });
        else col += pc(p, { a: locked ? 'info' : 'tog', g: grp(p), d: desc(p, ''), x: ' data-on="0"' });
      });
      h += '<div class="sl">In the kit <span>' + (c.kit < C.kitMin ? c.kit + ' · need ' + C.kitMin : c.kit + ' · no maximum') + '</span></div><ul class="pcg pfv-g">' + (inn || slot('none')) + '</ul>'
        + '<div class="sl">Collection <span>' + (locked ? 'locked' : 'tap to pack') + '</span></div><ul class="pcg pfv-g">' + (col || slot('none')) + '</ul>';
      hint = locked ? 'Tap a piece to read it.' : 'Tap a piece, then pack it or take it out.';
    } else if (tab === 'belt') {
      var wear = PFD.wearAll(src), tier = src.beltTier || 1, slots = d.slots, onBelt = {}, kits = src.repair || 0;
      h += '<div class="chips seg pfv-tier" role="img" aria-label="Fight belt tier ' + tier + ': ' + slots + ' tool slots">';
      [1, 2, 3].forEach(function (t) { h += '<span' + (t === tier ? ' class="on"' : '') + '>Belt ' + ['', 'I', 'II', 'III'][t] + ' · ' + C.belts[t][0] + '</span>'; });
      h += '</div>';
      var bs = '';
      d.belt.forEach(function (b, i) {
        if (i >= 4) return; onBelt[b.type] = b.state;
        var p = null; P.forEach(function (q) { if (q.tool === b.type) p = q; });
        if (p && b.state === 'ok') bs += pc(p, { a: 'info', dur: [b.left, b.max], d: desc(p, 'durability ' + b.left + '/' + b.max + ', −' + C.toolWear + ' a play') }).replace('<li>', '<li class="bslot">').replace('</li>', durbar(b.left, b.max) + '<small>' + b.left + '/' + b.max + '</small></li>');
        else bs += slot(b.state === 'broken' ? 'broken' : (b.state === 'over' ? 'no slot' : 'gone'));
      });
      for (var i2 = d.belt.length; i2 < 4; i2++) bs += slot(i2 >= slots ? 'locked<br>Belt ' + (i2 === 2 ? 'II' : 'III') : '＋');
      h += '<div class="sl">On the belt <span>each adds its piece · −' + C.toolWear + ' durability a play</span></div><ul class="pcg">' + bs + '</ul>';
      h += '<div class="sl">Tools <span>🧰 repair kits: ' + kits + '</span></div><ul class="toolg" id="pfv-tools">';
      var full = Object.keys(onBelt).filter(function (k) { return onBelt[k] === 'ok'; }).length >= slots, any = false;
      Object.keys(wear).forEach(function (type) {
        var w = wear[type]; if (w.tier < 1 || !D.catalog['t:' + type]) return; any = true;
        var pn = D.catalog['t:' + type].n, tt = D.toolTypes[type] || [ucfirst(type), '🔧'], on = onBelt[type] === 'ok', bk = !!w.broken, acts = [];
        if (!locked && (bk || w.wear > 0)) acts.push('pfd_fix|🔧 Fix|gold|' + (kits < 1 ? '1' : '0'));
        if (!locked && !bk) acts.push(on ? 'pfd_unequip|Take off|ghost|0' : 'pfd_equip|' + (full ? 'Belt full' : 'Put on') + '|primary|' + (full ? '1' : '0'));
        var td = tt[0] + ' tool · ' + C.rankName[w.tier] + ' · durability ' + w.left + '/' + w.max + (bk ? ' · worn out: fix it with a Tool Repair Kit' + (kits < 1 ? ' (you have none)' : '') : (on ? ' · on the belt' : '')) + '.';
        h += '<li><button type="button" class="tb t' + w.tier + (bk ? ' broken' : '') + (on ? ' on' : '') + '" data-a="tool" data-arg="' + e(type) + '" data-n="' + e(pn) + '" data-d="' + e(td) + '" data-acts="' + e(acts.join(';')) + '" data-dur="' + w.left + '/' + w.max + '" data-rk="' + w.tier + '" data-ico="' + e(tt[1]) + '" aria-pressed="' + (on ? 'true' : 'false') + '" aria-label="' + e(pn + ', ' + td) + '">'
          + '<span class="ti" aria-hidden="true">' + tt[1] + '</span><span class="tn">' + e(pn) + '</span>' + durbar(w.left, w.max) + '</button></li>';
      });
      h += (any ? '' : '<li class="hint">No tools yet. A garden or gathering tool in your satchel can go on the belt.</li>') + '</ul>';
      h += '<p class="hint">' + (tier < 3 ? 'A bigger belt holds more tools: <a href="shop.php">buy one at Twigg’s</a> (Belt II from level ' + C.belts[2][2] + ', Belt III from level ' + C.belts[3][2] + ').' : 'Your belt holds the most tools a belt can.')
        + ' A worn-out tool leaves the deck until you fix it with a Tool Repair Kit (crafted: flint, pine resin, coir fibre).</p>';
      hint = locked ? 'Tap a tool to read it.' : 'Tap a tool, then put it on, take it off or fix it.';
    } else {
      var pl = ''; P.forEach(function (p) { if (p.src === 'pal') pl += pc(p, { cls: 'sel' + (p.out !== '' ? ' out' : ''), a: 'info', d: desc(p, 'in your party') }); });
      h += '<div class="sl">Puzzle Pals <span>your party: ' + c.pals + ' · 1 piece each</span></div><ul class="pcg">' + (pl || slot('none')) + '</ul>';
      h += '<p class="hint">The pals you take along each add one piece. <a href="puzzlepals.php">Change your party in the Pal Book</a>' + (locked ? ' (after the fight).' : '.') + '</p>';
      hint = 'Tap a pal piece to read it.';
    }
    h += '<div class="pinfo" id="pfv-info" aria-live="polite" data-hint="' + e(hint) + '">' + (d.err !== null ? '<span><b>' + e(d.err) + '</b> Until then a fight uses the standard kit.</span>' : '<span>' + e(hint) + '</span>') + '</div>';
    h += autoHtml(!!d.auto, back) + '<p class="hint">' + (d.auto ? 'Auto deck is on: this deck goes into every fight as it is. You still see the creature first.' : 'Before each fight you can swap pieces. Nothing changes once the fight starts.') + '</p>';
    return h + form(back) + '</div>';
  }

  // ---------------------------------------------------------------- 3. the pre-fight screen
  function foeV(c, v, tune) { var cfg = PFE.v1Cfg(c.size, tune || {}, c.level); /* the level curve (after 2.6.94) */ return Math.max(1, Math.round(v * cfg.foe * (c.size === 'boss' ? BOSS_MULT : 1) * (C.foeFires > 0 ? FIRE_MULT : 1))); }
  function foeCard(ctx, c) {
    var size = c.size || 'small', dims = PFE.v1Cfg(size, ctx.tune), cl = c.class, rn = D.regions[c.region] || '', by = {}, cells = '', lean = c.lean, order = { base: 0, reg: 1, rar: 2, uni: 3 };
    var pieces = c.deck.map(function (p, i) { return [p, i]; }).sort(function (a, b) { return (order[a[0].layer] - order[b[0].layer]) || (a[1] - b[1]); }).map(function (x) { return x[0]; });
    pieces.forEach(function (p) {
      by[p.layer] = (by[p.layer] || 0) + 1; var v = foeV(c, p.v, ctx.tune);
      var q = { n: p.n, t: p.t, v: v, tag: p.tag, life: p.life, src: 'creature', e: PFE.edges ? foeEdges(p) : null };
      var d = (TYPE[p.t] || p.t) + ' ' + v + ' · ' + C.layers[p.layer] + ' · stays ' + p.life + ' rounds · plays ×' + C.foeFires + (FOE_TAG[p.tag] ? '. ' + FOE_TAG[p.tag] : '') + '.';
      cells += pc(q, { owner: 'foe', cls: 'L-' + p.layer, a: 'info', d: d, x: ' data-info="pfv-cinfo"' });
    });
    var tally = '', total = 0; Object.keys(C.layers).forEach(function (L) { if (by[L]) { total += by[L]; tally += '<span class="L-' + L + '" data-f="' + by[L] + '" title="' + e(C.layers[L]) + ' ' + by[L] + '">' + (by[L] < 2 ? '+' + by[L] : e(C.layers[L].split(' ')[0]) + ' ' + by[L]) + '</span>'; } });
    var charm = size === 'boss' ? 'cannot be charmed' : (c.temper === 'gentle' ? 'gentle' : 'wary');
    return '<div class="foecard"><div class="pic">' + creatureImg(c, 'lg') + '</div><div class="fx"><h3>' + e(c.name) + ' <small>lv ' + c.level + '</small></h3>'
      + '<div class="chips small"><span class="chip">' + (CLASS_ICON[cl] || '🐾') + ' ' + e(cl) + '</span>' + (rn ? '<span class="chip">' + e(rn) + '</span>' : '') + '<span class="chip"><i class="szd ' + e(size) + '"></i>' + e(size) + ' · ' + dims.w + '×' + dims.h + '</span><span class="chip">' + charm + '</span><span class="chip">leans ' + e(lean) + '</span></div></div></div>'
      + '<div class="tally" role="img" aria-label="' + total + ' pieces in layers">' + tally + '</div><ul class="pcg c5">' + cells + '</ul>'
      + '<div class="pinfo" id="pfv-cinfo" aria-live="polite"><span>Tap one of its pieces. Each plays up to ' + C.foeFires + ' times.</span></div>';
  }
  function foeEdges(p) { return { L: ['hole', PFE.HOLE[p.t] || 'body'], R: ['knob', p.r || PFE.HOLE[p.t] || 'body'], T: [PFE_UP[p.t] ? 'knob' : 'hole', p.col], B: [PFE_UP[p.t] ? 'hole' : 'knob', p.col] }; }
  var PFE_UP = { hurt: 1, charm: 1, trick: 1 };
  function creatureImg(c, size) { var px = size === 'lg' ? 64 : 40, f = 'mini-' + c.slug + '.png'; return art(f) ? '<img class="aimg aimg-' + size + ' pix" src="' + art(f) + '" width="' + px + '" height="' + px + '" alt="' + e(c.name) + '">' : '<span aria-hidden="true">🐾</span>'; }

  function prefightHtml(ctx, c) {
    var src = ctx.src, d = PFD.deck(src), g = ctx.g, P = entries(d.pieces, g, src.calling, src.ctier), auto = !!d.auto, deck = '', bench = '', n = 0;
    P.forEach(function (p) {
      if (p.on && p.out === '') { n++; deck += pc(p, auto ? { cls: 'fixed lock', a: 'info', d: desc(p, 'locked (Auto deck)') } : { a: p.gear ? 'info' : 'tog', d: desc(p, p.gear ? 'gear: change it in the box' : ''), x: ' data-on="1"' }); }
      else if (!p.gear && !auto) bench += pc(p, { a: 'tog', d: desc(p, p.out !== '' ? 'over the rarity cap' : ''), x: ' data-on="' + (p.on ? '1' : '0') + '"', cls: p.out !== '' ? 'out' : '' });
    });
    var hp = Math.max(1, ctx.hp), mx = g.max;
    var h = '<div class="box pfv" id="pfv-pre"><div class="pfv-scroll">' + foeCard(ctx, c);
    var go = '<div class="actrow pfv-act"><a class="btn ghost" href="puzzlebox.php">🧩 Box</a><form method="post" class="grow pfv-gof"><input type="hidden" name="do" value="pfv_go"><button class="btn primary" id="pfv-go">⚔️ Let’s fight</button></form></div>';
    if (auto) {
      h += '<div class="pinfo pfv-autostrip" id="pfv-info" aria-live="polite" data-hint="Auto deck is active."><span><b>Auto deck is active:</b> ' + n + ' pieces · ❤️ ' + hp + '/' + mx + '</span>'
        + '<form method="post" class="inline"><input type="hidden" name="do" value="pfd_auto"><input type="hidden" name="on" value="0"><button class="btn ghost">Turn off and edit</button></form></div>'
        + '</div>' + go
        + '<details class="pfv-deckfold" id="pfv-deckfold"><summary>Show deck <span>' + n + ' pieces, read-only</span></summary>' + deckbar(d, true) + '<ul class="pcg c5">' + deck + '</ul></details>';
    } else {
      h += '<div class="sl">Your deck <span>' + n + ' pieces · ❤️ ' + hp + '/' + mx + '</span></div>' + deckbar(d, true) + '<ul class="pcg c5">' + deck + '</ul>'
        + '<div class="sl">Bench <span>tap to add</span></div><ul class="pcg c5">' + (bench || slot('none')) + '</ul>'
        + '<div class="pinfo" id="pfv-info" aria-live="polite" data-hint="Tap a deck piece to take it out, a bench piece to add it.">' + (d.err !== null ? '<span><b>' + e(d.err) + '</b> Until then the standard kit plays.</span>' : '<span>Tap a deck piece to take it out, a bench piece to add it. Nothing changes once the fight starts.</span>') + '</div>'
        + autoHtml(false) + '</div>' + go;
    }
    return h + form('') + '</div>';
  }

  // ---------------------------------------------------------------- 5. the result card
  function resultHtml(r, actions) {
    var name = e(r.name);
    var T = { seen_off: ['win', 'You won', 'The ' + name + ' backs off.'], charmed: ['charm', 'Charmed', 'You won the ' + name + ' over: a better reward.'], defeat: ['lose', 'Worn out', 'The ' + name + ' sends you home to rest.'],
      stall: ['lose', 'It slipped away', 'The fight ran out of turns.'], run: ['lose', 'You walked away', 'No reward this time.'] }[r.how] || ['lose', 'Over', ''];
    var w = ''; (r.wear || []).forEach(function (x) {
      var tt = D.toolTypes[x.type] || [ucfirst(x.type), '🔧'];
      w += '<li class="toolrow t' + x.tier + (x.broke ? ' broken' : '') + '"><span class="ti" aria-hidden="true">' + tt[1] + '</span><span class="tx"><b>' + e(x.n) + ' <small>' + Math.min(x.max, x.left + x.cost) + ' → ' + x.left + '/' + x.max + '</small></b>' + durbar(x.left, x.max)
        + '</span><span class="chip' + (x.broke ? ' warn' : '') + '">' + (x.broke ? 'broke · off the belt' : x.plays + ' × −' + C.toolWear) + '</span></li>';
    });
    var broke = (r.wear || []).some(function (x) { return x.broke; }), hp = Math.max(0, r.hp), max = Math.max(1, r.max);
    return '<div class="box res pfv" id="pfv-res"><span class="resbadge badge-' + T[0] + '">' + (T[0] === 'lose' ? 'lost' : T[0]) + '</span><h2>' + T[1] + '</h2><div class="pic">' + creatureImg(r, 'lg') + '</div><p class="big">' + T[2] + '</p>'
      + '<div class="rows"><div class="row"><b>You</b><span class="gvbar"><i data-w="' + Math.round(100 * hp / max) + '"></i><span>' + hp + '/' + max + '</span></span></div>'
      + '<div class="row"><b>Fight</b><span>' + r.turns + ' turn' + (r.turns === 1 ? '' : 's') + '</span></div></div>'
      + '<div class="sl">Tool wear <span>' + C.toolWear + ' durability each time its piece is played</span></div>' + (w !== '' ? '<ul class="tools">' + w + '</ul>' : '<p class="hint">No tool piece was played.</p>')
      + '<div class="actrow"><a class="btn' + (broke ? ' gold' : ' ghost') + '" href="puzzlebox.php?t=belt">' + (broke ? '🔧 Fix in the box' : '🧩 Puzzle box') + '</a>' + (actions || '') + '</div></div>';
  }

  // ---------------------------------------------------------------- 4. the fight page (pfight_board_html)
  function guardHtml(g) { return '<span class="pf-guard' + (g > 0 ? '' : ' pf-guard-0') + '" role="img" aria-label="Guard ' + g + ': blocks the creature\'s hits until your next turn" title="Guard: blocks the creature\'s hits until your next turn"><span class="pfx-fill gfill" data-w="' + Math.min(100, Math.round(g * 100 / 16)) + '"></span><b>' + g + '</b></span>'; }
  function barHtml(v) {
    var b = v.bar, max = Math.max(0.1, +b.max), now = +b.now, fm = Math.max(0.1, +v.fh.max), left = Math.max(0, fm - +v.fh.now), charmable = !!v.charmable;
    var hpLabel = 'Creature health: ' + Math.ceil(left) + ' of ' + Math.ceil(fm) + ' left. Hurt pieces take it down; at 0 it backs off.';
    var h = '<div class="pf-bars"><span class="pf-fhp" role="img" aria-label="' + e(hpLabel) + '" title="Creature health. Hurt pieces take it down; at 0 it backs off."><span class="pfx-fill fhfill" data-w="' + (Math.round(1000 * left / fm) / 10) + '"></span><b>' + Math.ceil(left) + '</b></span>';
    if (charmable) {   // 2.6.78: the engine's own number (one decimal), never drawn full before the fight is won
      var nowS = Math.round(now * 10) / 10, pct = nowS >= max ? 100 : Math.min(96, Math.floor(1000 * nowS / max) / 10), label = 'Charm bar: fill it to win the creature over for a better reward. Only Charm pieces fill it. ' + nowS + ' of ' + (Math.round(max * 10) / 10);
      h += '<div class="pf-bar pfx-bar" role="img" aria-label="' + e(label) + '"><span class="pfx-fill charm" data-w="' + pct + '"></span><img class="pfx-frame" src="' + art('parts/resolve-frame.png') + '" alt=""></div>';
    }
    return h + '</div>';
  }
  var TAG_ICON = { quick: 'jab', heavy: 'smash', pierce: 'pierce', poison: 'sting', trip: 'trip', bash: 'bash', hold: 'brace', evade: 'roll', thorns: 'thornhide', mend: 'mending', hum: 'hum', lull: 'lull', bond: 'bond', pluck: 'pluck' };
  var ICON = { hurt: '⚔️', guard: '🛡️', heal: '💚', charm: '🌸', soothe: '😌', trick: '🎭', item: '🎒' };
  function sm(t) { var f = art('ico-' + t + '-s.png'); return f ? '<img class="pfh-ico" src="' + f + '" alt="">' : '<span class="pfh-emo" aria-hidden="true">' + e(ICON[t] || '❔') + '</span>'; }
  function edgeSpan(edge, side) { var fam = { body: 'B', mind: 'M', craft: 'C' }; return '<span class="pfe s' + side + ' ' + (edge[0] === 'flat' ? 'flat f-flat' : edge[0] + ' f-' + edge[1]) + '" aria-hidden="true">' + (fam[edge[1]] || '·') + '</span>'; }
  function boardPieceHtml(t, i) {
    var tgg = tg(t.tag), ed = ''; ['L', 'R', 'T', 'B'].forEach(function (sd) { ed += edgeSpan(t.e[sd], sd); });
    var label = t.n + ', ' + ucfirst(t.t) + ' ' + t.v + '; edges: ' + ['L', 'R', 'T', 'B'].map(function (sd) { return sd + ' ' + (t.e[sd][0] === 'flat' ? 'flat' : t.e[sd][0] + ' ' + t.e[sd][1]); }).join(', ') + (tgg ? '; ' + tgg[1] : '');
    var dsc = ucfirst(t.t) + ' ' + (t.v | 0) + (tgg ? '. ' + tgg[1] : '');
    return '<button type="button" class="pf-tile pf-h pf-bp pf-' + e(t.t) + '" data-i="' + i + '" data-t="' + e(t.t) + '" data-tag="' + e(t.tag) + '" data-mod="' + e(t.m) + '" data-v="' + (t.v | 0) + '" data-name="' + e(t.n) + '" data-desc="' + e(dsc) + '" aria-label="' + e(label) + '" aria-pressed="false" draggable="true">'
      + ed + '<span class="pf-ico" aria-hidden="true">' + (ICON[t.t] || '❔') + '</span><span class="pf-nm">' + e(t.n) + (tgg ? ' <span class="pf-tg" aria-hidden="true">' + tgg[0] + '</span>' : '') + '</span><span class="pf-val">' + (t.v | 0) + '</span></button>';
  }
  /** The fight page. ctx: {c (creature row), s (state), enc, g}. */
  function fightHtml(ctx) {
    var c = ctx.c, s = ctx.s, enc = ctx.enc, v = PFE.view(s), nonce = e(s.nonce);
    var v1 = !!v.v1, won = !!enc.won && (s.over === 'seen_off' || s.over === 'charmed'), lost = v1 && !!enc.lost && (s.over === 'defeat' || s.over === 'stall');
    var mini = function (cls, name, n) { return '<span class="pfc-pile ' + cls + '" role="img" aria-label="' + name + ': ' + n + ' pieces"><img src="' + art('parts/' + (cls === 'deck' ? 'deck-book.png' : 'discard-bin.png')) + '" alt=""><b>' + n + '</b></span>'; };
    var h = '<div class="pfight pf-screen pf-boardmode pfx-art' + (s.start ? ' pf-opening' : '') + (v1 ? ' pf-v1' : '') + (v1 && (enc.won || enc.lost) && enc.replay && enc.replay.length ? ' pfv-endwait' : '') + '" id="pfight" data-turn="' + (v.turn | 0) + '" data-mode="board" data-redraws="' + (v.redraws | 0) + '">';
    var who = function (by) { return by === 'env' ? '<span class="pfh-emo" aria-hidden="true">🌿</span>' : (by === 'me' ? '<img class="pfh-gn" src="' + art('chip-gnome.png') + '" alt="">' : '<img class="pfh-cr" src="' + art('mini-' + c.slug + '.png') + '" alt="">'); };
    var hist = (enc.hist || []).slice(), nNew = enc.histnew | 0, total = hist.length, pending = !!(enc.replay && enc.replay.length), snapsAll = enc.snaps || {}, usedSn = {};
    var top = '', hh = '<div class="pfc-histrow"><ol class="pf-hist" aria-label="What has been played" aria-live="polite">';
    for (var hi = total - 1; hi >= 0; hi--) {
      var chip = hist[hi], evIdx = hi - (total - nNew), isNew = nNew > 0 && evIdx >= 0, sn = chip.sn !== null && chip.sn !== undefined && snapsAll[chip.sn] ? chip.sn : null;
      if (sn !== null) usedSn[sn] = snapsAll[sn];
      var nm = 'the ' + c.name, tgw = chip.tg === 'me' ? 'you' : nm;
      var label = (chip.by === 'me' ? 'You' : (chip.by === 'env' ? (v.v1 && v.v1.env ? 'Environment' : 'Terrain') : ucfirst(nm))) + ': ' + chip.types.join(', ') + ', ' + chip.txt + (chip.tg ? ', on ' + tgw : '') + (sn !== null ? '. Press to see the board then.' : '');
      hh += '<li class="pf-chip ' + (chip.by === 'me' ? 'you' : (chip.by === 'env' ? 'env' : 'foe')) + (isNew ? ' pf-chip-new' : '') + (sn !== null ? ' pf-chip-rw' : '') + '"' + (isNew ? ' data-ev="' + evIdx + '"' + (pending ? ' hidden' : '') : '')
        + (sn !== null ? ' data-sn="' + sn + '" data-id="' + (chip.id | 0) + '" data-bar="' + e(chip.bar === null || chip.bar === undefined ? '' : chip.bar) + '" data-fh="' + e(chip.fh === null || chip.fh === undefined ? '' : chip.fh) + '" data-g="' + e(chip.g === null || chip.g === undefined ? '' : chip.g) + '" data-hp="' + e(chip.hp === null || chip.hp === undefined ? '' : chip.hp) + '" role="button" tabindex="0"' : '') + ' aria-label="' + e(label) + '">' + who(chip.by);
      chip.types.forEach(function (t, ci) {
        if (chip.by === 'env' || t === 'note') return;
        var tgn = String((chip.tags || [])[ci] || ''), ti = TAG_ICON[tgn] ? art('ico-' + TAG_ICON[tgn] + '-s.png') : null;
        hh += ti ? '<img class="pfh-ico" src="' + ti + '" alt="" title="' + e(ucfirst(tgn)) + '">' : sm(t);
      });
      hh += ' <span class="pfh-txt">' + e(chip.txt) + '</span>' + (chip.tg ? who(chip.tg) : '') + '</li>';
    }
    if (!(enc.hist || []).length) hh += '<li class="pf-chip empty">' + (s.start ? 'Opening: the blank ✦ is in the middle. The creature picks its side too, hidden.' : e(enc.note || 'Pieces are on the board. Place one next to them.')) + '</li>';
    hh += '</ol><button type="button" class="btn" id="pf-skip" hidden>Skip</button><span class="pfc-piles">' + mini('deck', 'Puzzle book', v.piles.draw) + mini('disc', 'Discard', v.piles.discard) + '</span></div>';
    top = '<div class="pfc-top"><div class="pfc-me"><span class="pfc-meav"><span class="pfc-av"><img src="' + art('gnome.png') + '" alt="Gnome"></span>' + guardHtml(v.block | 0) + '</span><span class="pf-hp" role="img" aria-label="Your health ' + v.hp + ' of ' + v.max + '">❤️ <progress max="' + v.max + '" value="' + v.hp + '"></progress> ' + v.hp + '</span></div>'
      + barHtml(v)
      + '<div class="pfc-foe"><span class="pfc-fname"><b>' + e(c.name) + '</b><small>lv ' + c.level + ' · ' + (s.temper === 'gentle' ? 'gentle' : 'wary') + ' · 🃏 ' + v.foe.hand + (v.foe.calm ? ' · 😌 ' + v.foe.calm : '') + '</small></span><span class="pfc-av">' + creatureImg(c, 'lg')
      + '<span class="pf-intent-bubble" title="Likely next move" aria-label="Likely next move: ' + e(v.foe.intent) + '">' + sm(String(v.foe.intent || 'hurt')) + '</span></span></div></div>';
    h += top + hh;
    h += '<div class="pf-rewind" id="pf-rewind" role="status" hidden><span id="pf-rw-t"></span><button type="button" class="btn" id="pf-rw-back">Back to now</button></div>';
    if (v1) h += '<div class="pfv-row" id="pfv-row"></div>';
    h += '<div class="pfb-board" id="pfb-board" role="group" aria-label="The play area: pick a piece from your hand, then a lit spot. Scroll, pinch or use the zoom buttons to zoom"></div>';
    if (v1) h += '<div class="pfv-legend" id="pfv-legend" role="group" aria-label="' + (v.v1.env ? 'The environment: its next pieces' : 'Terrain legend') + '"></div>';
    h += '<div class="pf-opts" id="pf-opts" hidden></div>';
    h += '<p class="pf-preview help" id="pf-preview" aria-live="polite">Pick a piece, then a lit spot. Up to 4 a turn; the newest plays first.</p><ol class="pf-plan" id="pf-plan" aria-live="polite" hidden></ol>';
    h += '<form method="post" class="pf-form" id="pf-form"><input type="hidden" name="do" value="pfb_play"><input type="hidden" name="nonce" value="' + nonce + '"><input type="hidden" name="turn" value="' + (v.turn | 0) + '"><input type="hidden" name="moves" id="pf-moves" value=""></form>';
    if (lost) {
      h += resultHtml({ how: s.over, name: c.name, slug: c.slug, size: c.size, hp: s.over === 'defeat' ? 0 : v.hp, max: v.max, turns: v.turn, wear: ctx.wear },
        '<form method="post" class="grow pf-endform"><input type="hidden" name="do" value="pf_finish"><input type="hidden" name="nonce" value="' + nonce + '"><button class="btn primary" id="pf-end">' + (s.over === 'defeat' ? '🏠 Go home to rest' : 'Continue') + '</button></form>');
      h += '<button type="button" class="btn" id="pf-undo" hidden></button><button class="btn" id="pf-go" form="pf-form" hidden></button>';
    } else if (won && v1) {
      h += resultHtml({ how: s.over, name: c.name, slug: c.slug, size: c.size, hp: v.hp, max: v.max, turns: v.turn, wear: ctx.wear },
        '<form method="post" class="grow pf-endform"><input type="hidden" name="do" value="pf_finish"><input type="hidden" name="nonce" value="' + nonce + '"><button class="btn primary" id="pf-end">🎁 Collect the reward</button></form>');
      h += '<button type="button" class="btn" id="pf-undo" hidden></button><button class="btn" id="pf-go" form="pf-form" hidden></button>';
    } else {
      h += '<div class="pf-buttons"><a class="btn pf-box" href="puzzlebox.php" title="Your puzzle box" aria-label="Puzzle box">🧩</a><button type="button" class="btn" id="pf-undo" disabled>Undo</button><button class="btn primary" id="pf-go" form="pf-form" disabled>' + (s.start ? 'Confirm start' : 'End turn') + '</button>'
        + (v1 && v.flip && v.flip.on ? '<button type="button" class="btn pfv-flipb" id="pf-flip" disabled aria-label="Flip: swap the top and bottom edges of the piece you picked (once a turn, free)">⇅ Flip</button>' : '')
        + (v.can_run && !s.over ? '<form method="post" class="inline pf-runf"><input type="hidden" name="do" value="pf_run"><input type="hidden" name="nonce" value="' + nonce + '"><button class="btn" title="Run away" aria-label="Run away">🏃</button></form>' : '') + '</div>';
    }
    h += '<div class="pf-tray"><div class="pf-hand" id="pf-hand" role="group" aria-label="Your hand">'; v.hand.forEach(function (t, i) { h += boardPieceHtml(t, i); }); h += '</div></div>';
    h += '<div class="pf-inspect" id="pf-inspect" aria-live="polite" hidden><span class="pfi-art" id="pfi-art" aria-hidden="true"></span><span class="pf-itext"><b id="pfi-name"></b><br><span id="pfi-desc"></span></span><button type="button" class="pfi-x" id="pfi-x" aria-label="Close">✕</button></div>';
    h += '<div class="pf-extra"><form method="post" class="inline" id="pf-pform" hidden><input type="hidden" name="do" value="pfb_pass"><input type="hidden" name="nonce" value="' + nonce + '"><input type="hidden" name="turn" value="' + (v.turn | 0) + '"><button class="btn" id="pf-pass">Pass (nothing fits)</button></form>';
    h += '<form method="post" class="inline" id="pf-rform" hidden><input type="hidden" name="do" value="pf_redraw"><input type="hidden" name="nonce" value="' + nonce + '"><input type="hidden" name="turn" value="' + (v.turn | 0) + '"><input type="hidden" name="card" id="pf-card" value=""></form>';
    if (v1) h += '<form method="post" class="inline" id="pf-fform" hidden><input type="hidden" name="do" value="pfb_flip"><input type="hidden" name="nonce" value="' + nonce + '"><input type="hidden" name="turn" value="' + (v.turn | 0) + '"><input type="hidden" name="hand" id="pf-fhand" value=""></form>';
    h += '</div>';
    var data = { start: !!s.start, foe: c.name, won: (won || lost) ? s.over : null, life: 3, tags: TAGS, held: v.held || null, gone: v.gone || [], snaps: usedSn, bar: v.bar.now, barmax: v.bar.max, fh: v.fh.now, fhmax: v.fh.max, charmable: !!v.charmable, hp: v.hp, guard: v.block | 0,
      replay: enc.replay || [], replay0: enc.replay0 || null, mods: [], art: 'art/', fx: v.fx || [], tint: PFE.crc32(String(c.slug || c.name)) % 360, parts: 'art/parts/', w: v.w, h: v.h, pcs: v.pcs,
      hand: v.hand.map(function (t) { return { e: t.e, t: t.t, tag: t.tag, m: t.m }; }), combos: v.combos, icons: { hurt: '⚔️', guard: '🛡️', heal: '💚', charm: '🌸', soothe: '😌', trick: '🎭', item: '🎒' } };
    if (v1) {
      ['v1', 'round', 'ter', 'envs', 'envlog', 'aim', 'reaim', 'flip'].forEach(function (k) { data[k] = v[k]; });
      ['status', 'wear', 'env'].forEach(function (k) { if (v[k] !== undefined) data[k] = v[k]; });
      v.hand.forEach(function (t, i) { data.hand[i].life = t.life; data.hand[i].src = t.src; data.hand[i].flip = t.flip; data.hand[i].canflip = t.canflip; data.hand[i].tool = String(t.tool || ''); data.hand[i].rank = t.rank | 0; });
      data.prev = enc.replay && enc.replay.length ? (enc.prev || null) : null;
      data.tripped = (s.me.tripped | 0);
      if (s.turn === 1 && !s.start) { var n = 0; for (var id in s.pcs) if (s.pcs[id].by === 'foe') n++; data.opened = n; }
      data.box = 'puzzlebox.php'; data.turncap = PFE.TURN_CAP; data.toolwear = C.toolWear; data.fires = C.foeFires; data.tools = {};
      var tw = PFD.wearAll(ctx.src), have = Object.keys(v.wear || {}).length || v.hand.some(function (t) { return t.tool; });
      if (have) Object.keys(tw).forEach(function (type) { var w = tw[type]; if (w.tier > 0 && D.catalog['t:' + type]) data.tools[type] = { n: D.catalog['t:' + type].n, left: w.left + (enc.wearsaved ? ((v.wear || {})[type] | 0) : 0), max: w.max }; });
    }
    h += '<script type="application/json" id="pf-data">' + JSON.stringify(data).replace(/</g, '\\u003c').replace(/&/g, '\\u0026') + '</script>';
    return h + '</div>';
  }
  return { e: e, entries: entries, pc: pc, desc: desc, starterHtml: starterHtml, boxHtml: boxHtml, prefightHtml: prefightHtml, resultHtml: resultHtml, fightHtml: fightHtml, foeCard: foeCard, creatureImg: creatureImg, deckbar: deckbar, foeV: foeV };
});
