#!/usr/bin/env python3
"""Builds claude/mockups/pf-real-pieces-demo.html: the themed small-creature animation engine (small-anim.template.html + small-creatures.json) with the
stand-in piece replaced by the REAL game piece renderer (game/assets/pfparts47.js + parts48 kit + the creature's own ico-*-s.png), for aphid-swarm.
Local use only: serve the repo root over http (python3 -m http.server) and open /claude/mockups/pf-real-pieces-demo.html#c=aphid-swarm&shape=single
(the renderer fetches atlas.json, so file:// will not do).  Options: #shape=single|r3  #bare=1 (canvas only)  #t=ms (frozen clock)  PFA.seek(ms).
Needs php (real piece value/edges come from pfd_foe_row + pfb_author_edges, as the game builds them)."""
import json, os, re, subprocess, zlib
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
SLUG = 'aphid-swarm'
php = r'''require "%s/tests/pf_creatures_load.php"; $c = pt_load_creatures()["%s"]; $o = [];
foreach (pfd_foe_row($c, "")["deck"] as $p) if ($p["layer"] === "uni") $o[$p["n"]] = ["t" => $p["t"], "v" => $p["v"], "tag" => $p["tag"], "ik" => $p["ik"], "e" => pfb_author_edges(["t" => $p["t"], "r" => $p["r"]], $p["col"])];
echo json_encode($o);''' % (ROOT, SLUG)
REAL = json.loads(subprocess.check_output(['php', '-r', php]))
TINT = zlib.crc32(SLUG.encode()) % 360   # as pfight_game.php: crc32(slug) % 360
tpl = open(os.path.join(HERE, 'small-anim.template.html')).read()
mini = json.load(open(os.path.join(HERE, 'small-creatures.json')))
# the data block exactly as build_small_anim.py embeds it: reuse the built page's data
built = open(os.path.join(ROOT, 'claude', 'mockups', 'pf-small-anim.html')).read()
m = re.search(r"var D = (\{.*?\});\nvar FAM", built, re.S)
html = tpl.replace('/*__DATA__*/null', m.group(1))

def sub(old, new, cnt=1):
    global html
    assert html.count(old) == cnt, (old[:60], html.count(old)); html = html.replace(old, new)

# 1) the real piece drawer replaces the stand-in drawPiece
a = html.index('function drawPiece('); b = html.index('/* ---------- layers 2 and 3')
html = html[:a] + r'''function realEdges(n, up) { var R = window.RP && RP.real[n]; if (!R) return { L: 'h', R: 'k', T: up ? 'k' : 'h', B: up ? 'h' : 'k' };
  var o = {}; ['L', 'R', 'T', 'B'].forEach(function (s) { o[s] = R.e[s][0] === 'knob' ? 'k' : R.e[s][0] === 'hole' ? 'h' : 'f'; }); return o; }
function drawPiece(c, p, ps, cx, cy, col, acc) {   /* the REAL piece (PFParts.piece, strip size 82x73: 56x47 body + 13 px tabs), same raise/click/wiggle transform as before */
  var R = window.RP && RP.pc[p.n]; if (!R) return; var pw = R.cv.width, ph = R.cv.height;
  c.save(); c.globalAlpha = ps.a; c.translate(Math.round(cx + ps.x), Math.floor(cy + ps.y)); c.rotate(ps.r); c.scale(ps.s * (1 + (ps.q || 0)), ps.s * (1 - (ps.q || 0)));
  if (ps.sh > 0) c.drawImage(R.sh, Math.round(-pw / 2 + 2 + 3 * ps.sh), Math.round(-36 + 3 + 5 * ps.sh));
  c.drawImage(R.cv, -41, -36);
  if (ps.hit) { c.strokeStyle = '#fff'; c.lineWidth = 2; c.strokeRect(-BW / 2 - 1, -24, BW + 2, BH + 2); }
  c.restore();
}

''' + html[b:]
# 2) real edges / real value on the scene cells, a "Real L" shape (Swarm -> Honeydew -> Cloud Up fit knob-into-hole by family)
sub("e: { L: 'h', R: 'k', T: up ? 'k' : 'h', B: up ? 'h' : 'k' }, d: e, n: e.name, t: e.type, v: e.v }", "e: realEdges(e.name, up), d: e, n: e.name, t: e.type, v: (window.RP && RP.real[e.name] ? RP.real[e.name].v : e.v) }")
sub("l3: [[0, 0], [0, 1], [1, 1]],", "l3: [[0, 0], [0, 1], [1, 1]], r3: [[0, 0], [1, 0], [1, 1]],")
sub('<option value="l3">L of 3</option>', '<option value="l3">L of 3</option><option value="r3">Real L of 3 (right, down)</option>')
# 3) real renderer boot, bare mode, prose
real = json.dumps(REAL, separators=(',', ':'))
boot = '''<i id="pfight" hidden></i><script type="application/json" id="pf-data">{"parts":"../../game/assets/img/pfight/parts48/","art":"../../game/assets/img/pfight/","mods":{}}</script>
<script>
/* real renderer boot: pfparts47.js builds window.PFParts; its pieces are drawn once per piece (strip size) with the creature's own icon (ico-<ik>-s.png) and the creature tint */
window.RP = { real: %s, pc: {}, ready: false, tint: %d, pico: '../../game/assets/img/pfight/pieces/' };
document.addEventListener('pfparts-ready', function () {
  var P = window.PFParts; if (!P || !P.ok) return; var iks = Object.keys(RP.real).map(function (k) { return RP.real[k].ik; });
  function mk() { var all = true;
    Object.keys(RP.real).forEach(function (n) { var r = RP.real[n]; if (!P.cico[r.ik + '|strip']) { all = false; return; }
      var cv = P.piece({ size: 'strip', owner: 'foe', ik: r.ik, type: r.t, tag: r.tag, edges: r.e, old: false, num: r.v, tint: RP.tint });
      var sh = document.createElement('canvas'); sh.width = cv.width; sh.height = cv.height; var g = sh.getContext('2d'); g.drawImage(cv, 0, 0); g.globalCompositeOperation = 'source-in'; g.fillStyle = 'rgba(0,0,0,.35)'; g.fillRect(0, 0, sh.width, sh.height);
      RP.pc[n] = { cv: cv, sh: sh }; });
    RP.ready = all; }
  P.cicoLoad(RP.pico, iks, 'strip', mk); mk();
});
</script><script src="../../game/assets/pfparts47.js"></script>
<script>''' % (real, TINT)
sub('</div>\n<script>\n(function () {', '</div>\n' + boot + '\n(function () {')
sub('window.PFA = { seek: function (ms) { FIX = ms === null ? null : +ms; }, end: function () { return S.end; } };', 'window.PFA = { seek: function (ms) { FIX = ms === null ? null : +ms; }, end: function () { return S.end; }, ready: function () { return !!(window.RP && RP.ready); } };')
sub("fillPos(); if (hv('pos'))", "if (hv('bare')) document.body.classList.add('bare'); fillPos(); if (hv('pos'))")
sub('</style>', 'body.bare{padding:0;background:#4a3322}body.bare>*:not(.stage){display:none}body.bare .stage{display:block;margin:0}body.bare .stage .card+.card{display:none}body.bare .card{padding:0;border:0;background:none}body.bare .card h2,body.bare .card .ph,body.bare .card .bar{display:none}body.bare canvas{width:424px;height:370px}\n</style>')
sub('<title>Small creature piece animations</title>', '<title>Real pieces demo (aphid swarm)</title>')
sub('Stand-in pieces; the gold ring and number is the resolve stand-in.', 'REAL pieces (game renderer pfparts47.js, parts48 kit, the creature\'s own icons); the gold ring and number is still the resolve stand-in. Local test page: serve the repo over http.')
open(os.path.join(ROOT, 'claude', 'mockups', 'pf-real-pieces-demo.html'), 'w').write(html)
print('ok', len(html), REAL.keys(), TINT)
