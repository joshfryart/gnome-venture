#!/usr/bin/env python3
"""Builds the three pages of the demo ARTIFACT (https://claude.ai/artifact/KLYTtavrpBhpTNje2E1kfe, 2026-11-16, built at PFDEMO_GAME_REF=df0577d5 = 2.7.00 + the committed 2.7.01 learner rules; the old one, SCVTp8FLRTbibtA7vNWC2S, was not updated) into one folder:
  index.html  the playable demo at the current rules (tools/build_pf_demo_v1.py, game files from PFDEMO_GAME_REF, default HEAD) + notes (tools/pfdemo_v1/notes.html)
  rules.html  the quick rules (claude/reviews-2026-11-13/rulebook/puzzle-combat-quick-rules.html, built by its build_short.py) as a screen page
  old.html    the 2.6.78 demo, taken as it is from OLD_HTML (the current tools cannot build it any more: read it from a published artifact: SCVTp8FLRTbibtA7vNWC2S index.html,
              or old.html of the new one); only its tab row is replaced
Each page gets the same tab row (tools/pfdemo_v1/tabs.css).
Usage: PFDEMO_GAME_REF=HEAD python3 tools/build_pf_demo_artifact.py OUT_DIR OLD_HTML      then publish OUT_DIR/index.html with files rules.html and old.html"""
import os, re, subprocess, sys
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__))); os.chdir(R)
OUT, OLD = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
D = 'tools/pfdemo_v1/'
def rd(p): return open(p, encoding='utf-8').read()
TABS = [('index.html', 'Play', 'rules now, 2.7.01'), ('rules.html', 'Quick rules', 'the player rule book'), ('old.html', 'Old demo', '2.6.78 rules')]
def nav(cur): return '<nav id="gvtabs" aria-label="Demo pages">' + ''.join('<a href="%s"%s>%s<small>%s</small></a>' % (h, ' aria-current="page"' if h == cur else '', t, s) for h, t, s in TABS) + '</nav>'
tabcss = '<style>\n' + rd(D + 'tabs.css') + '</style>'

# ---- index.html: the demo at the current rules, with the tab row and the notes before the game page
env = dict(os.environ); env.setdefault('PFDEMO_GAME_REF', 'HEAD')
subprocess.check_call([sys.executable, 'tools/build_pf_demo_v1.py', os.path.join(OUT, 'index.html')], env=env)
p = rd(os.path.join(OUT, 'index.html')); assert p.count('<div id="gv">') == 1
p = p.replace('<div id="gv">', tabcss + nav('index.html') + rd(D + 'notes.html') + '<div id="gv">')
open(os.path.join(OUT, 'index.html'), 'w', encoding='utf-8').write(p)

# ---- old.html: the published 2.6.78 page, its tab row and one-line note replaced
o = rd(OLD)
o = re.sub(r'<nav id="gvtabs".*?</nav>(<div class="gvnotes">.*?</div>)?', lambda m: nav('old.html') + '<div class="gvnotes"><p class="lede">The demo as it was at 2.6.78, kept to compare. The rules have changed a lot since: play the current ones in the first tab.</p></div>', o, count=1, flags=re.S)
assert 'aria-current="page">Old demo' in o, 'no tab row found in ' + OLD
o = re.sub(r'<style>\s*#gvtabs.*?</style>', lambda m: tabcss, o, count=1, flags=re.S)
open(os.path.join(OUT, 'old.html'), 'w', encoding='utf-8').write(o)

# ---- rules.html: the quick rules as a screen page. The book is laid out for A4 in pt; here 1pt = 1.6px, columns wrap, no page numbers. The sheet keeps the book's paper colours in both themes.
q = rd('claude/reviews-2026-11-13/rulebook/puzzle-combat-quick-rules.html')
css = q[q.index('<style>') + 7:q.index('</style>')]
body = q[q.index('<body>') + 6:q.rindex('</body>')]
css = re.sub(r'@page\s*\{[^}]*\}', '', css)
css = re.sub(r'(\d+(?:\.\d+)?)pt', lambda m: '%gpx' % round(float(m.group(1)) * 1.6, 1), css)
css = re.sub(r'(\d+(?:\.\d+)?)mm', lambda m: '%gpx' % round(float(m.group(1)) * 3.8, 1), css)
css = css.replace('html { font-size: 14.4px; }', '')
body = re.sub(r'<span class="dots"></span><span class="pg">\d*</span>', '', body)
since = ('<div class="box new2701"><h4>Since this book (2.7.01)</h4><ul>'
         '<li><b>Your first 3 fights are gentler:</b> creature pieces hit ×0.8, carry no tags, and the environment has no Thornburst. The 4th fight opens with a short <b>New today</b> line.</li>'
         '<li><b>Costly spots:</b> a lit spot whose chain costs you health has a red edge and says why. In your first 5 fights, End turn asks once before such a move.</li>'
         '<li>Evade also stops the round\'s poison tick after it made a Hurt miss. Every Guard wearable carries the Spiky knack.</li></ul></div>')
body = body.replace('<div class="two">', since + '<div class="two">', 1)
page = '''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>Puzzle Combat Quick Rules</title>
<meta name="claude:viewport-fit-sides" content="cover">
<style>
/* The rule book is a paper sheet (its own colours, like the PDF) on the game's page ground; the tab row uses the game's tokens. */
:root { --bg: #f1ece0; --surface-2: #f2e4c0; --ink: #2a1a10; --muted: #74462a; --line: #c9a96e; --brand-fill: #2f5a2a; --on-fill: #f2e4c0; --edge-dk: #2a1a10; --focus: #25637d;
  --paper: #fffdf6; --paper-ink: #1d1d1b; --shadow: #c9a96e; --font: system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; --mono: ui-monospace, Menlo, Consolas, monospace; }
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { --bg: #2a1a10; --surface-2: #4a2c1a; --ink: #f2e4c0; --muted: #c9a96e; --line: #74462a; --edge-dk: #74462a; --focus: #a9d6ea; --shadow: #120b06; color-scheme: dark; } }
:root[data-theme="dark"] { --bg: #2a1a10; --surface-2: #4a2c1a; --ink: #f2e4c0; --muted: #c9a96e; --line: #74462a; --edge-dk: #74462a; --focus: #a9d6ea; --shadow: #120b06; color-scheme: dark; }
html { padding-top: env(safe-area-inset-top, 0px); padding-bottom: env(safe-area-inset-bottom, 0px); }
body { margin: 0; background: var(--bg); color: var(--ink); font: 14px var(--font); }
*, *::before, *::after { box-sizing: border-box; }
.sheetwrap { padding: 12px max(16px, env(safe-area-inset-right, 0px)) 32px max(16px, env(safe-area-inset-left, 0px)); }
.book { max-width: 980px; margin: 0 auto; background: var(--paper); color: var(--paper-ink); padding: 22px clamp(14px, 3vw, 32px); box-shadow: 4px 4px 0 0 var(--shadow); font-size: 15px; line-height: 1.45; overflow-wrap: break-word; }
.book a { color: #56692f; }
.book .two { display: flex; flex-wrap: wrap; gap: 12px 20px; }
.book .two > div { min-width: min(100%, 300px); }
.book .toc .cols { columns: 2 220px; }
.book .toc .e a { display: flex; gap: 6px; text-decoration: underline; text-underline-offset: 3px; }
.book .cheat .cols { columns: 3 260px; }
.book table { display: block; overflow-x: auto; }
.book svg { max-width: 100%; height: auto; }
.book h2 { scroll-margin-top: 12px; }
.book .mc { columns: 2 280px; }
.book h2 .n { white-space: nowrap; }
@media (max-width: 600px) { .book .rank { flex-wrap: wrap; } .book .rank > div { flex: 1 1 40%; } .book .rank > div + div::before { display: none; } .book h2 { flex-wrap: wrap; } .book h2 .s { margin-left: 0; } }
.book .new2701 { border: 2px solid #34406b; background: #eef0fa; padding: 10px 14px; margin: 0 0 14px; }
.book .new2701 h4 { color: #34406b; }
''' + css + '''
.book .mc { columns: 2 280px; } .book .cheat .cols { columns: 3 260px; } .book .toc .cols { columns: 2 220px; }
@media (max-width: 600px) { .book .rank { flex-wrap: wrap; } .book .rank > div { flex: 1 1 40%; } .book .rank > div + div::before { display: none; } .book h2 { flex-wrap: wrap; } .book h2 .s { margin-left: 0; } }
</style>
''' + tabcss + '</head><body>' + nav('rules.html') + '<div class="sheetwrap"><main class="book">' + body + '</main></div></body></html>'
open(os.path.join(OUT, 'rules.html'), 'w', encoding='utf-8').write(page)
for f in ['index.html', 'rules.html', 'old.html']: print(f, os.path.getsize(os.path.join(OUT, f)) // 1024, 'KB')
