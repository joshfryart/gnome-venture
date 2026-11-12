#!/usr/bin/env python3
"""Builds the playable v1 DESIGN demo (one HTML file, art inlined): starter pick, Puzzle box, creature picker, a full fight with the v1 board rules, result.
Design only: nothing here is loaded by the game. The fight rules are tools/pfengine.js (the PHP-checked port) PATCHED here with the v1 bundle of
claude/design-board-strategy.md "Sim results 3" (the same patches tools/pfsim/v1bundle/mkengine.py makes to the PHP), plus per-piece life and creature-side tags.
Usage: python3 tools/build_pf_demo_v1.py [OUT.html] [ENGINE_OUT.js]   (run from anywhere; needs Pillow)"""
import base64, io, json, os, re, sys
from PIL import Image
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__))); os.chdir(R)
OUT = sys.argv[1] if len(sys.argv) > 1 else 'claude/mockups/pf-demo-v1.html'
ENG_OUT = sys.argv[2] if len(sys.argv) > 2 else None
G = 'game/assets/'; IMG = G + 'img/'; P = IMG + 'pfight/'; PT = P + 'parts/'; D = 'tools/pfdemo_v1/'
def uri(path, mime='image/png'): return 'data:%s;base64,%s' % (mime, base64.b64encode(open(path, 'rb').read()).decode())
def js(o): return json.dumps(o, ensure_ascii=False, separators=(',', ':')).replace('</', '<\\/').replace('<!--', '<\\!--')

# ------------------------------------------------------------------ the v1 engine (pfengine.js + patches)
# 2.6.74: tools/pfengine.js now carries the v1 rules itself (ported from here into the game, behind pfight_v1). The design demo keeps its own patched copy of the engine
# as it was before that port, so the approved demo does not move: commit 614072fc.
import subprocess
src = subprocess.check_output(['git', 'show', '614072fc:tools/pfengine.js']).decode()
def rep(old, new, count=1):
    global src
    assert src.count(old) == count, (src.count(old), old)
    src = src.replace(old, new)

# board size by creature size: every read of the two constants reads this fight's size
rep('var PFB_W = 7, PFB_H = 5,', 'var PFB_W0 = 7, PFB_H0 = 5,')
rep('W: PFB_W, H: PFB_H,', 'W: PFB_W0, H: PFB_H0, V1: V1_DEFAULTS, preview: preview, ter: ter,')
src = re.sub(r'\bPFB_W\b', 's.w', src); src = re.sub(r'\bPFB_H\b', 's.h', src)

rep("  // ------------------------------------------------------------------ tiles\n", r"""  // ------------------------------------------------------------------ v1 bundle (design demo; numbers = "Sim results 3" final table). A value may be a map by creature size.
  var V1_DEFAULTS = {
    dims: { small: [5, 4], medium: [5, 5], large: [7, 5], boss: [7, 6] },
    ground: 1, nsun: { small: 2, medium: 3, large: 3, boss: 4 }, nbr: { small: 2, medium: 2, large: 3, boss: 3 }, nmud: 1, gmin: 1, gmax: 2,
    sun: 2.0, bramble: 0.10, br_foe: 1.0,
    events: 1, nev: { small: 1, medium: 2, large: 2, boss: 2 }, evk: ['sunbeam', 'creep', 'gust', 'thorn', 'puddle'], ev_unit: 0.10, ev_foe: 0.5, gextra: 0,
    limit: 3, spend_foe: 1, aim: 1,
    foe: { small: 0.72, medium: 0.53, large: 0.41, boss: 0.46 }, /* sim 4 retune for authored edges + flip (sim 3: 0.65 / 0.56 / 0.53 / 0.64) */ bar: { small: 1.12, medium: 1.12, large: 1.12, boss: 0.88 }, foe_x: 1, bar_x: 1,
    team2: 1.3, team: 1.6
  };
  function v1cfg(size, over) {
    var o = {};
    for (var k in V1_DEFAULTS) {
      var v = over && has(over, k) && over[k] !== null && over[k] !== undefined ? over[k] : V1_DEFAULTS[k];
      if (v && typeof v === 'object' && !Array.isArray(v) && has(v, 'small')) v = has(v, size) ? v[size] : v.medium;
      o[k] = clone(v);
    }
    return o;
  }
  function ter(s, x, y) { return (s.ter && s.ter[x + ',' + y]) || ''; }
  function st(s, k, n) { s.st[k] = (s.st[k] || 0) + (n === undefined ? 1 : n); }
  function inb(s, x, y) { return x >= 0 && y >= 0 && x < s.w && y < s.h; }
  /** Ground: nsun sunny, nbr bramble, nmud mud cells, gmin-gmax steps from the centre. */
  function seedGround(s) {
    s.ter = {}; if (!s.v1.ground) return;
    var cx = intdiv(s.w, 2), cy = intdiv(s.h, 2), cand = [];
    for (var y = 0; y < s.h; y++) for (var x = 0; x < s.w; x++) { var d = Math.abs(x - cx) + Math.abs(y - cy); if (d >= s.v1.gmin && d <= s.v1.gmax) cand.push(x + ',' + y); }
    cand = shuffle(s, cand);
    [['sun', s.v1.nsun], ['br', s.v1.nbr], ['mud', s.v1.nmud]].forEach(function (g) { for (var i = 0; i < g[1] && cand.length; i++) s.ter[cand.pop()] = g[0]; });
  }
  /** An event puts ground on a cell. There are never more cells of a kind than at the start (+ gextra): the oldest one goes. */
  function groundSet(s, x, y, kind) {
    delete s.ter[x + ',' + y]; s.ter[x + ',' + y] = kind;
    var cap = Math.max(1, toInt(s.v1[{ sun: 'nsun', br: 'nbr', mud: 'nmud' }[kind]]) + toInt(s.v1.gextra));
    var have = Object.keys(s.ter).filter(function (k) { return s.ter[k] === kind; });
    while (have.length > cap) delete s.ter[have.shift()];
  }
  /** The environment hurts the owner of a piece (a share of the maximum). Returns what it cost: health points for you, bar points for the creature. */
  function envHurt(s, who, frac, tag) {
    if (frac <= 0) return 0;
    if (who === 'me') { var d = Math.max(1, iround(frac * s.me.max)); s.me.hp = Math.max(0, s.me.hp - d); st(s, tag + '_me', d); return d; }
    if (who === 'foe') { frac *= Number(tag === 'thorn' ? s.v1.ev_foe : s.v1.br_foe); var a = frac * s.fh.max; s.fh.now += a; st(s, tag + '_foe', a); return a; }
    return 0;
  }
  function zone(e) { var z = [[e.x, e.y]]; for (var sd in PFB_SIDE) z.push([e.x + PFB_SIDE[sd][0], e.y + PFB_SIDE[sd][1]]); return z; }
  /** The environment turn (after the creature): the announced events land (they move ground, push a piece or burst), then bramble pricks. */
  function envTurn(s) {
    var log = s.envlog = [];
    if (s.v1.events) (s.envs || []).forEach(function (e) {
      var on = pieceAt(s, e.x, e.y), ob = on && on.by !== 'none' ? on.by : null, L = { k: e.kind, x: e.x, y: e.y };
      if (e.kind === 'gust') {
        var id = s.cell[e.x + ',' + e.y], d = PFB_SIDE[e.dir], nx = e.x + d[0], ny = e.y + d[1];
        if (id !== undefined && ob && inb(s, nx, ny) && !has(s.cell, nx + ',' + ny)) {
          delete s.cell[e.x + ',' + e.y]; s.cell[nx + ',' + ny] = id; s.pcs[id].x = nx; s.pcs[id].y = ny; L.moved = { by: ob, n: on.tile.n, dir: e.dir };
        }
      } else if (e.kind === 'thorn') {
        L.me = 0; L.foe = 0;
        zone(e).forEach(function (z) { var p = pieceAt(s, z[0], z[1]); if (p && p.by !== 'none') L[p.by] += envHurt(s, p.by, Number(s.v1.ev_unit), 'thorn'); });
      } else { groundSet(s, e.x, e.y, { sunbeam: 'sun', creep: 'br', puddle: 'mud' }[e.kind]); if (ob) L.on = { by: ob, n: on.tile.n }; }
      log.push(L);
    });
    if (s.v1.ground) {
      var B = { k: 'bramble', me: 0, foe: 0 };
      for (var id in s.pcs) { var p = s.pcs[id]; if (p.by !== 'none' && ter(s, p.x, p.y) === 'br') B[p.by] += envHurt(s, p.by, Number(s.v1.bramble), 'br'); }
      if (B.me || B.foe) log.push(B);
    }
    checkEnd(s);
  }
  /** What the announced events will do to a piece of who put on (x,y), in the creature's score units. */
  function envBias(s, who, x, y, tile) {
    var b = 0.0, m = who === 'foe' ? 0.8 * s.fh.max : 0.7 * s.me.max;
    if (s.v1.events) (s.envs || []).forEach(function (e) {
      if (e.kind === 'thorn') { zone(e).forEach(function (z) { if (z[0] === x && z[1] === y) b -= Number(s.v1.ev_unit) * (who === 'foe' ? Number(s.v1.ev_foe) : 1.0) * m; }); }
      else if (e.x === x && e.y === y) {
        if (e.kind === 'creep') b -= Number(s.v1.bramble) * (who === 'foe' ? Number(s.v1.br_foe) : 1.0) * m;
        else if (e.kind === 'sunbeam' && tile && (tile.t === 'hurt' || tile.t === 'charm')) b += 0.3 * tile.v;
      }
    });
    return b;
  }
  /** Announce the next events (shown before you move, they land after the creature's move): each on a cell on or next to a piece. */
  function forecast(s) {
    s.envs = []; if (!s.v1.events) return;
    var cand = {}, pcs = [], id, sd;
    for (id in s.pcs) {
      var p = s.pcs[id]; if (p.by !== 'none') pcs.push(p.x + ',' + p.y); cand[p.x + ',' + p.y] = 1;
      for (sd in PFB_SIDE) { var x = p.x + PFB_SIDE[sd][0], y = p.y + PFB_SIDE[sd][1]; if (inb(s, x, y)) cand[x + ',' + y] = 1; }
    }
    var keys = Object.keys(cand), kinds = s.v1.evk;
    for (var i = 0; i < toInt(s.v1.nev) && keys.length; i++) {
      var kind = kinds[rand(s, kinds.length)], dir = 'L', key;
      if (kind === 'gust') {   // a piece, and a direction that is free now
        if (!pcs.length) continue;
        key = pcs[rand(s, pcs.length)]; var xy = key.split(',').map(Number), dirs = [];
        for (sd in PFB_SIDE) { var nx = xy[0] + PFB_SIDE[sd][0], ny = xy[1] + PFB_SIDE[sd][1]; if (inb(s, nx, ny) && !has(s.cell, nx + ',' + ny)) dirs.push(sd); }
        if (!dirs.length) dirs = Object.keys(PFB_SIDE);
        dir = dirs[rand(s, dirs.length)];
      } else {
        var gk = { sunbeam: 'sun', creep: 'br', puddle: 'mud' }[kind] || null;
        var ok = keys.filter(function (k) { return gk === null || (s.ter[k] || '') !== gk; }); if (!ok.length) continue;
        key = ok[rand(s, ok.length)];
      }
      keys = keys.filter(function (k) { return k !== key; });
      var c = key.split(',').map(Number);
      s.envs.push({ kind: kind, x: c[0], y: c[1], dir: dir });
    }
  }
  /** Your own chain only, for the number on a lit cell (no creature answer, no reply number). */
  function preview(s, handIdx, x, y) {
    var w = clone(s); w.spent = []; begin(w, 'me');
    var ev = place(w, 'me', handIdx, x, y); if (ev === null) return null;
    var n = 0, tw = 1, sun = 0;
    ev.forEach(function (e) { if (e.id !== undefined && e.id !== null) n++; if (e.tw) tw = e.tw; if (e.sun && e.by === 'me') sun++; });
    return { fh: w.fh.now - s.fh.now, bar: w.bar.now - s.bar.now, hp: w.me.hp - s.me.hp, block: w.me.block - s.me.block, foeblock: w.foe.block - s.foe.block,
      n: n, used: w.uselog.length > 0, tw: tw, sun: sun, over: w.over, ev: ev };
  }

  // ------------------------------------------------------------------ tiles
""")

# authored edges (sim 4): a piece that carries `ed` uses it instead of the hashed top / bottom; `flip` swaps its top and bottom
rep("  function edges(t) {\n", "  function edges(t) {\n    if (t.ed) return t.flip ? { L: t.ed.L, R: t.ed.R, T: t.ed.B, B: t.ed.T } : t.ed;\n")
rep("return { k: key, n: d.n, t: d.t, v: Math.max(1, toInt(d.v) + stat + lvl + bonus), r: nn(d.r), tag: String(d.tag), m: '' };", "var mt = { k: key, n: d.n, t: d.t, v: Math.max(1, toInt(d.v) + stat + lvl + bonus), r: nn(d.r), tag: String(d.tag), m: '' }; if (d.ed) mt.ed = d.ed; return mt;")
rep("var mk = function (k, n, t, val, r, tag) { return", "var mk = function (k, n, t, val, r, tag) { return", 1)
# a creature deck built by layers (class base 4 + region + size / boss + 3 unique) comes ready-made
rep("  function foeDeck(c) {\n", "  function foeDeck(c) {\n    if (c.deck) return clone(c.deck);\n")

# mud blocks links
rep("joints.push([side, toInt(n.id), j[1]]);", "joints.push([side, toInt(n.id), j[1] && ter(s, x, y) !== 'mud' && ter(s, x + sd[0], y + sd[1]) !== 'mud']);")
rep("if (n && n.by !== 'none' && joint(e[side], edges(n.tile)[sd[2]])[1]) o.push(n);", "if (n && n.by !== 'none' && joint(e[side], edges(n.tile)[sd[2]])[1] && ter(s, p.x, p.y) !== 'mud' && ter(s, n.x, n.y) !== 'mud') o.push(n);")
rep("touch = true; if (jt[1]) linked = true;", "touch = true; if (jt[1] && ter(s, cx, cy) !== 'mud' && ter(s, nx, ny) !== 'mud') linked = true;")

# fire: Teamwork, sunny, record what fired
rep("    var ev = [], ch = chain(s, root);\n", r"""    var ev = [], ch = chain(s, root);
    var rb = s.pcs[root].by, tw = 1.0; s.fired = []; s.firedby = rb;
    if (s.v1.team > 1) {
      var srcs = {};
      ch.forEach(function (c) { var cp = s.pcs[c[0]], sr = cp.tile.src; if (cp.by === rb && (sr === 'pal' || sr === 'tool' || sr === 'crop')) srcs[sr] = 1; });
      var ns = Object.keys(srcs).length;
      if (ns >= 3) { tw = Number(s.v1.team); st(s, 'team3'); } else if (ns === 2 && s.v1.team2 > 1) { tw = Number(s.v1.team2); st(s, 'team2'); }
    }
""")
rep("      var val = iround(vv[0] * Number(nn(p.cm, 1.0)));\n", r"""      var val = iround(vv[0] * Number(nn(p.cm, 1.0)));
      var sunny = (tile.t === 'hurt' || tile.t === 'charm') && ter(s, p.x, p.y) === 'sun';
      if (sunny) val = iround(val * Number(s.v1.sun));
      if (tw > 1 && who === rb) val = iround(val * tw);
      s.fired.push(id);
""")
rep("      apply(s, who, tile, val, isRoot && links(s, id).length !== 0,", "      if (sunny) e.sun = 1; if (tw > 1 && who === rb) e.tw = tw;\n      apply(s, who, tile, val, isRoot && links(s, id).length !== 0,")

# use-up: a chain of `limit` or more fired pieces uses those pieces up, both sides
rep("    if (s.over) return;\n    var ids = Object.keys(s.pcs);\n", r"""    if (s.over) return;
    var lim3 = toInt(s.v1.limit), fired = s.fired || []; s.fired = [];
    if (lim3 > 0 && fired.length >= lim3 && (nn(s.firedby, 'me') === 'me' || s.v1.spend_foe)) {
      var used = [];
      fired.forEach(function (fid) {
        if (!has(s.pcs, fid)) return; var q = s.pcs[fid];
        s[q.by].discard.push(q.tile); if (!Array.isArray(s.spent)) s.spent = []; s.spent.push(q); used.push({ by: q.by, n: q.tile.n });
        delete s.cell[q.x + ',' + q.y]; delete s.pcs[fid];
      });
      if (!Array.isArray(s.uselog)) s.uselog = [];
      s.uselog.push({ by: s.firedby, used: used }); st(s, 'spend_' + s.firedby);
    }
    var ids = Object.keys(s.pcs);
""")
rep("w.spent = [];", "w.spent = []; w.uselog = [];", 3)

# place: a committed aim plays on its cell even when its link has gone; tool wear counts plays of a tool piece
rep("if (jt === null || (!hasLink(jt) && mustLink(s, who))) return null;   // it has to connect unless nothing can\n    s[who].hand.splice(handIdx, 1);",
    "if (jt === null || (!hasLink(jt) && !s.aimforce && mustLink(s, who))) return null;   // it has to connect unless nothing can (v1: a committed aim plays anyway)\n    s[who].hand.splice(handIdx, 1);\n    if (who === 'me' && tile.tool) { if (!s.wear) s.wear = {}; s.wear[tile.tool] = (s.wear[tile.tool] || 0) + 1; }")

# creature search: knows what bramble and the announced events do to a piece that stays out
rep("        var sc = score(s, w, who);\n", r"""        var sc = score(s, w, who);
        if (ter(s, x, y) === 'br' && has(w.cell, x + ',' + y)) sc -= 2 * Number(s.v1.bramble) * (who === 'foe' ? Number(s.v1.br_foe) * 0.8 * s.fh.max : 0.7 * s.me.max);
        if (has(w.cell, x + ',' + y)) sc += envBias(s, who, x, y, tile);
""")

# aim: shown and committed, no fumble. Creature Quick: one more piece this turn.
rep("""    var n = foeLen(s); s.lastfoe = [];
    for (var k = 0; k < n && !s.over; k++) {
      var m = search(s, 'foe');
      if (m === null) break;
      var r = place(s, 'foe', m[0], m[1], m[2]);
      if (r) { ev = ev.concat(r); s.lastfoe.push(s.pid); }
    }""", r"""    var n = foeLen(s); s.lastfoe = []; s.reaim = 0; s.foe.again = 0; var again = false;
    for (var k = 0; k < n && !s.over; k++) {
      var r = null, plan = (s.v1.aim && k === 0) ? nn(s.foe.plan, null) : null;
      if (plan) for (var hi = 0; hi < s.foe.hand.length; hi++) if (s.foe.hand[hi].k === plan.k) { s.aimforce = true; r = place(s, 'foe', hi, plan.x, plan.y); delete s.aimforce; break; }
      if (r === null) {   // no fumble: when its cell is taken (or its piece is gone) it picks again at full value
        if (plan) s.reaim = 1;
        var m = search(s, 'foe');
        if (m === null) break;
        r = place(s, 'foe', m[0], m[1], m[2]);
      }
      if (r) { ev = ev.concat(r); s.lastfoe.push(s.pid); }
      if (s.foe.again && !again) { again = true; n++; }
      s.foe.again = 0;
    }""")
rep("""    var m = search(s, 'foe');
    s.foe.intent = m ? s.foe.hand[m[0]].t : null;""", """    forecast(s);
    var m = search(s, 'foe'), h = m ? s.foe.hand[m[0]] : null;
    s.foe.intent = h ? h.t : null;
    s.foe.plan = h && foeLen(s) > 0 ? { k: h.k, n: h.n, t: h.t, v: h.v, tag: h.tag, x: m[1], y: m[2] } : null;   // v1: the aim (piece and cell), shown to the player""")

# new fight: board size, per-size creature factors, ground
rep("    var s = pfNew(me, c, seed, opt);\n    ['hand', 'draw', 'discard']", "    var s = pfNew(me, c, seed, opt);\n    s.v1 = v1cfg(s.size, opt && opt.v1); s.w = s.v1.dims[0]; s.h = s.v1.dims[1];\n    ['hand', 'draw', 'discard']")
rep("iround(t.v * PFB_FOE_MULT * ", "iround(t.v * (s.v1.foe * s.v1.foe_x) * ")
rep("s.bar.max = round(s.bar.max * PFB_BAR_MULT, 1);", "s.bar.max = round(s.bar.max * (s.v1.bar * s.v1.bar_x), 1);")
rep("s.pid = 0; s.seq = 0; s.round = 1;\n", "s.pid = 0; s.seq = 0; s.round = 1; s.st = {}; s.wear = {}; s.envlog = []; s.envs = []; s.uselog = []; seedGround(s);\n")

# end of round: environment turn, poison on you, per-piece life, a tripped draw
rep("    var gone = expire(s);\n    draw(s, 'foe', s.foe.hsize);", r"""    envTurn(s); if (s.over) return;
    if (s.me.poison > 0) {
      var pv = Math.max(1, toInt(s.me.poison_v)); s.me.hp = Math.max(0, s.me.hp - pv); s.me.poison--; s.envlog.push({ k: 'poison', me: pv });
      if (s.me.poison === 0) s.me.poison_v = 0;
      if (checkEnd(s)) return;
    }
    var gone = expire(s);
    draw(s, 'foe', s.foe.hsize);""")
rep("draw(s, 'me', Math.min(PF_HAND_CAP, s.me.hand.length + PF_DRAW));\n    s.gone", "draw(s, 'me', Math.min(PF_HAND_CAP, s.me.hand.length + PF_DRAW - (s.me.slowdraw ? 1 : 0))); s.me.slowdraw = 0;\n    s.gone")
rep("if (p.born <= s.round - (p.by === 'none' ? 1 : PFB_LIFE) + 1) {", "if (p.born <= s.round - (p.by === 'none' ? 1 : toInt(p.tile.life || PFB_LIFE)) + 1) {")

# creature-side tags (design doc section 3: pierce, poison, quick, trip, bash; evade and thorns against your hits; class trick pieces)
rep("        if (who === 'foe') { var cut = Math.min(s.foe.agg, dmg);", "        if (who === 'foe' && (tile.tag === 'bash' || mine.bashnext)) { dmg += mine.block; e.bashed = mine.block; if (tile.tag === 'bash') mine.block = 0; mine.bashnext = 0; }\n        if (who === 'foe') { var cut = Math.min(s.foe.agg, dmg);")
rep("          abs = Math.min(theirs.block, dmg); theirs.block -= abs; dmg -= abs;\n", "          abs = tile.tag === 'pierce' ? 0 : Math.min(theirs.block, dmg); theirs.block -= abs; dmg -= abs;\n")
rep("          theirs.hp = Math.max(0, theirs.hp - dmg);\n          e.dmg = dmg; e.blocked = abs;\n", r"""          theirs.hp = Math.max(0, theirs.hp - dmg);
          e.dmg = dmg; e.blocked = abs;
          if (tile.tag === 'poison') { theirs.poison = 2; theirs.poison_v = Math.max(toInt(theirs.poison_v), Math.max(1, toInt(Math.ceil(val / 3)))); }
          if (tile.tag === 'trip') theirs.slowdraw = 1;
          if (root && tile.tag === 'quick') s.foe.again = 1;
""")
rep("          abs = tile.tag === 'pierce' ? 0 : Math.min(theirs.block, dmg); theirs.block -= abs; dmg -= abs;\n          add = dmg * s.hm;", r"""          if (theirs.evade > 0) { theirs.evade--; e.evaded = dmg; dmg = 0; }
          abs = tile.tag === 'pierce' ? 0 : Math.min(theirs.block, dmg); theirs.block -= abs; dmg -= abs;
          if (abs > 0 && theirs.thorns) { pr = Math.max(2, iround(0.04 * mine.max)); mine.hp = Math.max(0, mine.hp - pr); e.pricked = pr; }
          add = dmg * s.hm;""", 1)
rep("      case 'trick':\n", r"""      case 'trick':
        if (who === 'foe') {
          if (root && tile.tag === 'quick') s.foe.again = 1;
          if (tile.tag === 'evade') mine.evade = 1;
          if (tile.tag === 'bash') mine.bashnext = 1;
          if (tile.tag === 'thorns') mine.thorns = true;
          if (tile.tag === 'poison') { theirs.poison = 2; theirs.poison_v = Math.max(toInt(theirs.poison_v), Math.max(1, toInt(Math.ceil(val / 2)))); }
          if (tile.tag === 'trip') theirs.slowdraw = 1;
          if (tile.tag === 'heal') s.fh.now = Math.max(0.0, s.fh.now - val);
        }
""")

# view: what the v1 page needs on top
rep("    delete v.strip; delete v.open;", r"""    v.round = s.round; v.ter = clone(s.ter || {}); v.envs = clone(s.envs || []); v.plan = clone(nn(s.foe.plan, null)); v.envlog = clone(s.envlog || []); v.uselog = clone(s.uselog || []);
    v.reaim = truthy(s.reaim); v.limit = toInt(s.v1.limit); v.wear = clone(s.wear || {}); v.st = clone(s.st || {});
    v.status = { poison: toInt(s.me.poison), slowdraw: toInt(s.me.slowdraw), evade: toInt(s.me.evade), foe_evade: toInt(s.foe.evade), foe_thorns: truthy(s.foe.thorns), foe_slow: toInt(s.foe.slow), foe_poison: toInt(s.foe.poison) };
    v.pcs.forEach(function (q) { var p = s.pcs[q.id], life = p.by === 'none' ? 1 : toInt(p.tile.life || PFB_LIFE); q.life = life; q.left = p.born + life - s.round; q.src = p.tile.src || ''; q.k = p.tile.k; q.rank = p.tile.rank || 0; q.layer = p.tile.layer || ''; });
    for (i = 0; i < v.hand.length; i++) { var ht = s.me.hand[i]; v.hand[i].life = toInt(ht.life || PFB_LIFE); v.hand[i].src = ht.src || ''; v.hand[i].k = ht.k; v.hand[i].rank = ht.rank || 0; v.hand[i].tool = ht.tool || ''; }
    delete v.strip; delete v.open;""")
ENGINE = src
if ENG_OUT: open(ENG_OUT, 'w').write(ENGINE)

# ------------------------------------------------------------------ the game's piece renderer (pfparts.js), art from the inlined map
pp = open(G + 'pfparts.js').read()
def prep(old, new):
    global pp
    assert pp.count(old) == 1, (pp.count(old), old); pp = pp.replace(old, new)
prep("var root = document.getElementById('pfight');\n  var data = {}; try { data = JSON.parse(document.getElementById('pf-data').textContent); } catch (e) { return; }\n  if (!root || !data.parts) return;",
     "var data = { parts: '', art: '', mods: {} };")
prep("i.src = base + file;", "i.src = window.__ART[file];")
prep("function getJson(file) { return fetch(base + file).then(function (r) { if (!r.ok) throw new Error(file); return r.json(); }); }",
     "function getJson(file) { return Promise.resolve(file === 'atlas.json' ? window.__ATLAS : window.__RIM); }")
prep("i.src = data.art + 'ico-' + TAGICON[tag] + z[1] + '.png';", "var u = window.__ART['ico-' + TAGICON[tag] + z[1] + '.png']; if (!u) { ok(); return; } i.src = u;")
prep("i.src = base + 'marks/' + n + '.png';", "var u = window.__ART['marks/' + n + '.png']; if (!u) { ok(); return; } i.src = u;")
prep("}).then(function () { return data.art ? loadTagIcons() : null; })", "}).then(function () { return loadTagIcons(); })")

# ------------------------------------------------------------------ art
art = {}
atlas = json.load(open(PT + 'atlas.json')); rim = json.load(open(PT + 'rim.json'))
for k in ['hand-me', 'hand-foe']: del atlas['sheets'][k]   # the demo draws every piece at board ("strip") size
del atlas['patterns']['hand']; del atlas['icons']['hand']
for f in ['parts-strip-me.png', 'parts-strip-foe.png', 'patterns-strip.png', 'icons-strip.png', 'joint-h.png', 'joint-v.png', 'chain-glow-h.png', 'chain-glow-v.png', 'combo-stamp-small.png', 'combo-stamp-big.png']:
    art[f] = uri(PT + f)
for f in sorted(os.listdir(PT + 'marks')):
    if f.endswith('.png') and f.startswith('tag-'): art['marks/' + f] = uri(PT + 'marks/' + f)
for f in sorted(os.listdir(P)):
    if re.match(r'ico-[a-z]+-s\.png$', f): art[f] = uri(P + f)
# the gnome's head and shoulders for the status bar (as tools/build_pf_artifact.py does)
L = [Image.open(IMG + 'gnome/gnome-%s.png' % n).convert('RGBA') for n in ['body', 'face', 'beard', 'hat']]
im = Image.new('RGBA', L[0].size)
for l in L: im = Image.alpha_composite(im, l)
full = im.crop(im.getbbox()); fs = max(full.size); fq = Image.new('RGBA', (fs, fs)); fq.paste(full, ((fs - full.size[0]) // 2, 0))
b = io.BytesIO(); fq.resize((60, 60), Image.LANCZOS).save(b, 'PNG'); art['gnome.png'] = 'data:image/png;base64,' + base64.b64encode(b.getvalue()).decode()
data_js = open(D + 'data.js').read()
for slug in re.findall(r"slug: '([a-z-]+)'", data_js): art['mini-%s.png' % slug] = uri(IMG + 'mini/mini-%s.png' % slug)

# ------------------------------------------------------------------ the approved in-game-look mockup: its CSS (the game's style.css + pfight.css + the piece cells) and its emoji icons
mock = open('claude/mockups/deckbuilder-ingame.html').read()
css = mock[mock.index('<style>') + 7:mock.index('</style>')]
m = re.search(r'^window\.__D=(\{.*\});?$', mock, re.M); MD = json.loads(m.group(1))

page = open(D + 'page.html').read()
def put(mark, text):
    global page
    assert page.count(mark) == 1, mark; page = page.replace(mark, text)
put('/*MOCKCSS*/', css)
put('/*ART*/{}', js(art)); put('/*ATLAS*/{}', js(atlas)); put('/*RIM*/{}', js(rim)); put('/*EMO*/{}', js(MD['EMO'])); put('/*TAGS*/{}', js(MD['TAGS']))
esc = lambda t: t.replace('</script', '<\\/script')
put('/*ENGINE*/', esc(ENGINE)); put('/*PFPARTS*/', esc(pp)); put('/*DATA*/', esc(data_js)); put('/*APP*/', esc(open(D + 'app.js').read()))
open(OUT, 'w').write(page); print(OUT, len(page) // 1024, 'KB')
