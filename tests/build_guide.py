#!/usr/bin/env python3
"""Gnome Venture Style Sheet & Art Guide -> game/assets/guides/Gnome-Venture-Style-Guide.pdf
usage: python3 tests/build_guide.py [--html-only] [--keep-tmp]
Reads the real files at run time (icons, ico_map.php, style.css tokens, palette.json, hearth.py constants), renders component
screenshots from the real style.css with Playwright chromium, builds ONE self-contained HTML (tests/guide_src: guide.css, text.py,
components.html) and prints it to A4 PDF. Needs: python3, playwright + chromium; optional: Pillow (smaller PNGs), pdftotext (TOC page numbers)."""
import os, re, sys, json, html, base64, io, shutil, subprocess, tempfile, datetime, pathlib
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.dirname(HERE)
SRC = os.path.join(HERE, 'guide_src'); GAME = os.path.join(ROOT, 'game')
ICO = os.path.join(GAME, 'assets/img/ico'); PH = os.path.join(GAME, 'assets/img/ph')
STYLE = os.path.join(GAME, 'assets/style.css'); MAPF = os.path.join(GAME, 'includes/data/ico_map.php')
OUTDIR = os.path.join(GAME, 'assets/guides'); PDF = os.path.join(OUTDIR, 'Gnome-Venture-Style-Guide.pdf')
sys.path.insert(0, HERE); sys.path.insert(0, SRC)
import hearth, text   # constants stay in sync with the real restyle

E = lambda s: html.escape(str(s), quote=True)
FURL = lambda p: pathlib.Path(p).resolve().as_uri()   # file URL that works on Windows and POSIX
def rd(p): return open(p, encoding='utf-8').read()
def log(*a): print('[guide]', *a, flush=True)

# ---------- tiny markup -> html ----------
def inline(s):
    s = E(s)
    s = re.sub(r'`([^`]+)`', lambda m: '<code>' + m.group(1) + '</code>', s)
    s = re.sub(r'\*\*([^*]+)\*\*', r'<b>\1</b>', s)
    return s

def md(src, fill):
    out = []; lines = src.strip('\n').split('\n'); i = 0; para = []
    def flush():
        if para: out.append('<p>' + inline(' '.join(para)) + '</p>'); para.clear()
    while i < len(lines):
        ln = lines[i]; st = ln.strip()
        if st.startswith('```'):
            flush(); i += 1; buf = []
            while i < len(lines) and not lines[i].strip().startswith('```'): buf.append(lines[i]); i += 1
            out.append('<pre>' + E('\n'.join(buf)) + '</pre>'); i += 1; continue
        m = re.fullmatch(r'\{\{(\w+)(?::(\w+))?\}\}', st)
        if m: flush(); out.append(fill(m.group(1), m.group(2))); i += 1; continue
        if st.startswith('### '): flush(); out.append('<h3>' + inline(st[4:]) + '</h3>')
        elif st.startswith('## '): flush(); out.append('<h2>' + inline(st[3:]) + '</h2>')
        elif st.startswith('> '): flush(); out.append('<div class="note">' + inline(st[2:]) + '</div>')
        elif st.startswith('- '):
            flush(); items = []
            while i < len(lines) and lines[i].strip().startswith('- '): items.append(lines[i].strip()[2:]); i += 1
            out.append('<ul>' + ''.join('<li>' + inline(x) + '</li>' for x in items) + '</ul>'); continue
        elif re.match(r'\d+\. ', st):
            flush(); items = []
            while i < len(lines):
                s2 = lines[i].strip()
                if re.match(r'\d+\. ', s2): items.append(re.sub(r'^\d+\. ', '', s2)); i += 1
                elif lines[i].startswith('   ') and items and s2: items[-1] += ' ' + s2; i += 1   # continuation line
                elif s2.startswith('```') and items:   # fenced block inside a step
                    i += 1; buf = []
                    while i < len(lines) and not lines[i].strip().startswith('```'): buf.append(lines[i]); i += 1
                    i += 1; items[-1] += '\0' + '<pre>' + E('\n'.join(buf)) + '</pre>'
                else: break
            out.append('<ol>' + ''.join('<li>' + '\0'.join([inline(x.split('\0')[0])] + x.split('\0')[1:]).replace('\0', '') + '</li>' for x in items) + '</ol>'); continue
        elif st.startswith('|'):
            flush(); rows = []
            while i < len(lines) and lines[i].strip().startswith('|'): rows.append([c.strip() for c in lines[i].strip().strip('|').split('|')]); i += 1
            rows = [r for r in rows if not all(re.fullmatch(r':?-+:?', c) for c in r)]
            out.append('<table><tr>' + ''.join('<th>' + inline(c) + '</th>' for c in rows[0]) + '</tr>' + ''.join('<tr>' + ''.join('<td>' + inline(c) + '</td>' for c in r) + '</tr>' for r in rows[1:]) + '</table>'); continue
        elif st == '': flush()
        else: para.append(st)
        i += 1
    flush(); return '\n'.join(out)

# ---------- data readers ----------
def app_version():
    m = re.search(r"define\('APP_VERSION', '([0-9.]+)'\)", rd(os.path.join(GAME, 'includes/bootstrap.php'))); return m.group(1) if m else '?'

def css_block(css, head):
    i = css.find(head)
    if i < 0: return ''
    j = css.find('{', i); k = css.find('\n}', j); return css[j + 1:k]

def tokens(css):
    light = {}; dark = {}
    for m in re.finditer(r'^:root \{([^}]*)\}', css, re.M | re.S):
        for n, v in re.findall(r'(--[\w-]+):\s*([^;]+);', m.group(1)): light.setdefault(n, v.strip())
    dk = re.search(r'^:root\[data-theme="dark"\] \{([^}]*)\}', css, re.M | re.S)
    if dk:
        for n, v in re.findall(r'(--[\w-]+):\s*([^;]+);', dk.group(1)): dark[n] = v.strip()
    return light, dark

def php_str(s):
    s = s.replace("\\'", "'").replace('\\\\', '\\')
    return re.sub(r'\\u\{([0-9a-fA-F]+)\}', lambda m: chr(int(m.group(1), 16)), s)

def ico_map():
    """slug -> {'emoji': [..], 'dec': bool, 'name': str}"""
    res = {}
    if not os.path.isfile(MAPF): return res
    t = rd(MAPF)
    for m in re.finditer(r"""(?:'((?:[^'\\]|\\.)+)'|"((?:[^"\\]|\\.)+)")\s*=>\s*\[\s*'([A-Za-z0-9_-]+)'\s*(?:,\s*(true|false))?\s*(?:,\s*'((?:[^'\\]|\\.)*)')?""", t):
        emo = php_str(m.group(1) or m.group(2)).replace('\ufe0f', ''); slug = m.group(3)
        d = res.setdefault(slug, {'emoji': [], 'dec': m.group(4) != 'false', 'name': php_str(m.group(5) or '')})
        if emo not in d['emoji']: d['emoji'].append(emo)
    return res

BREAK = {'about', 'a1', 'b1', 'b4', 'c1', 'c3'}   # sections that start a new page; the rest flow on
VEC = {'gnome-hat', 'bee', 'watering-can', 'carrot', 'mushroom', 'coffee'}
FORBID = ['<script', '<style', 'style=', 'filter', 'xlink', 'href', '<image', '<foreignObject', '<use', 'gradient', '<text']
def load_icons():
    mp = ico_map(); icons = []
    for f in sorted(os.listdir(ICO)) if os.path.isdir(ICO) else []:
        if not f.endswith('.svg'): continue
        stem = f[:-4]; s = rd(os.path.join(ICO, f))
        short = stem[4:] if stem.startswith('ico-') else stem
        row = mp.get(stem) or mp.get(short)
        bad = [x for x in FORBID if x in s] + (['on*='] if re.search(r'\son[a-z]+\s*=', s, re.I) else [])
        vb = re.search(r'viewBox="([^"]*)"', s)
        icons.append({'stem': stem, 'name': short, 'svg': s, 'bytes': len(s.encode()), 'map': row, 'bad': bad, 'vb': vb.group(1) if vb else '', 'ids': re.findall(r'\bid="([^"]+)"', s)})
    return icons, mp

def sym(ic):
    s = ic['svg']
    inner = re.sub(r'^\s*<svg[^>]*>', '', s.strip(), count=1); inner = re.sub(r'</svg>\s*$', '', inner)
    return '<symbol id="s-%s" viewBox="0 0 64 64">%s</symbol>' % (ic['stem'], inner)
def use(stem, cls, px=None):
    sz = ' width="%d" height="%d"' % (px, px) if px else ''
    return '<svg class="i %s"%s viewBox="0 0 64 64" aria-hidden="true"><use href="#s-%s"/></svg>' % (cls, sz, stem)

RAS = {}
SC = 1.5   # raster scale for catalogue cards
def raster_icons(icons):
    """One PNG per icon holding the dark strip and the light strip (48, 24, 16 px each). Vector copies cost ~20 KB each in a
    Chromium PDF and separate small PNGs cost an object each; one opaque PNG per icon is ~5 KB."""
    from playwright.sync_api import sync_playwright
    from PIL import Image
    L, D = tokens(rd(STYLE)); dark_bg = D.get('--surface', '#1c2a22'); line = L.get('--line', '#dcd8c8')
    js = """async ([items, sizes]) => { const out = []; for (const [n, svg] of items) { const img = new Image(); img.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
      try { await img.decode(); } catch (e) { continue; } for (const z of sizes) { const c = document.createElement('canvas'); c.width = c.height = z; c.getContext('2d').drawImage(img, 0, 0, z, z); out.push([n, z, c.toDataURL('image/png')]); } } return out; }"""
    jse = """async (items) => { const out = []; for (const [n, t, w, h] of items) { const c = document.createElement('canvas'); c.width = w; c.height = h; const x = c.getContext('2d'); x.fillStyle = '#fffaf0'; x.fillRect(0, 0, w, h);
      x.font = Math.round(h * .72) + 'px "Noto Color Emoji", sans-serif'; x.textBaseline = 'middle'; x.fillStyle = '#5a4332'; x.fillText(t, 2, h / 2 + 1); out.push([n, c.toDataURL('image/png')]); } return out; }"""
    EH = 20
    W, H, GAP = 150, 56, 4
    with sync_playwright() as p:
        b = p.chromium.launch(); pg = b.new_page(); pg.set_content('<html><body></body></html>')
        for k in range(0, len(icons), 60):
            got = {}
            for n, z, u in pg.evaluate(js, [[[i['stem'], i['svg']] for i in icons[k:k + 60]], [int(48 * SC), int(24 * SC), int(16 * SC)]]):
                got[(n, round(z / SC))] = Image.open(io.BytesIO(base64.b64decode(u.split(',', 1)[1]))).convert('RGBA')
            emo = {n: Image.open(io.BytesIO(base64.b64decode(u.split(',', 1)[1]))).convert('RGB') for n, u in pg.evaluate(jse, [[i['stem'], ' '.join(i['map']['emoji'][:2]) + (' +%d' % (len(i['map']['emoji']) - 2) if len(i['map']['emoji']) > 2 else ''), int(W * SC), int(EH * SC)] for i in icons[k:k + 60] if i['map']])}
            for i in icons[k:k + 60]:
                n = i['stem']
                if (n, 48) not in got: continue
                top = int(EH * SC) if n in emo else 0
                im = Image.new('RGB', (int(W * SC), int((2 * H + GAP) * SC) + top), '#fffaf0')
                if top: im.paste(emo[n], (0, 0))
                for row, bg in ((0, dark_bg), (1, '#ffffff')):
                    y0 = int(row * (H + GAP) * SC) + top
                    im.paste(Image.new('RGB', (int(W * SC), int(H * SC)), bg), (0, y0))
                    x = (W - (48 + 14 + 24 + 14 + 16)) // 2
                    for sz in (48, 24, 16):
                        ic = got[(n, sz)]; im.paste(ic, (int(x * SC), y0 + int((H - sz) * SC / 2)), ic); x += sz + 14
                    if row == 1:   # hairline round the light chip
                        from PIL import ImageDraw
                        ImageDraw.Draw(im).rectangle([0, y0, int(W * SC) - 1, y0 + int(H * SC) - 1], outline='#cdb98a', width=2)
                bio = io.BytesIO(); im.save(bio, 'JPEG', quality=74, subsampling=2, optimize=True)   # JPEG passes into the PDF as is (PNG gets re-encoded raw)
                RAS[n] = 'data:image/jpeg;base64,' + base64.b64encode(bio.getvalue()).decode()
        b.close()

def data_uri(path, mime):
    return 'data:%s;base64,%s' % (mime, base64.b64encode(open(path, 'rb').read()).decode())

# ---------- screenshots ----------
def shots():
    from playwright.sync_api import sync_playwright
    css_url = FURL(STYLE); tpl = rd(os.path.join(SRC, 'components.html'))
    def icoimg(m):
        n = m.group(1); p = os.path.join(ICO, 'ico-%s.svg' % n)
        return '<img class="ico pix" src="%s" alt="" width="16" height="16">' % FURL(p) if os.path.isfile(p) else ''
    tpl = re.sub(r'\[\[ico:([\w-]+)\]\]', icoimg, tpl)
    out = {}; tmp = tempfile.mkdtemp(prefix='gvguide-')
    phone = ['type', 'buttons', 'tabs', 'choice', 'fold', 'flash', 'stitch', 'picker', 'form']
    try:
        with sync_playwright() as p:
            b = p.chromium.launch()
            for theme in ('dark', 'light'):
                for width, names in ((390, phone), (1200, ['deskgrid'])):
                    f = os.path.join(tmp, 'c-%s-%d.html' % (theme, width))
                    open(f, 'w', encoding='utf-8').write(tpl.replace('{{THEME}}', theme).replace('{{CSS}}', css_url).replace('{{W}}', str(width)))
                    ctx = b.new_context(viewport={'width': width, 'height': 900}, device_scale_factor=2, bypass_csp=True)
                    pg = ctx.new_page(); pg.goto(FURL(f)); pg.wait_for_timeout(250)
                    for n in names:
                        png = pg.locator('[data-shot="%s"]' % n).first.screenshot(type='png')
                        out[(n, theme)] = pack_png(png)
                    ctx.close()
            b.close()
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return out

def pack_png(png):
    """JPEG goes into the PDF as is; PNG would be re-encoded raw (3x the size)."""
    try:
        from PIL import Image
        im = Image.open(io.BytesIO(png)).convert('RGB'); bio = io.BytesIO(); im.save(bio, 'JPEG', quality=78, subsampling=0, optimize=True)
        return 'data:image/jpeg;base64,' + base64.b64encode(bio.getvalue()).decode()
    except Exception:
        return 'data:image/png;base64,' + base64.b64encode(png).decode()

# ---------- fillers ----------
class Ctx: pass
C = Ctx()

def sw(c): return '<span class="sw" style="background:%s"></span>' % E(c)
def swatch(name, c): return '<div class="swatch"><i style="background:%s"></i><b>%s</b><span>%s</span></div>' % (E(c), E(name), E(c))

ROLES = {'--bg': 'Page background', '--surface': 'Cards, inputs, popups', '--surface-2': 'Quiet fills: tabs, hover, strips', '--ink': 'Main text', '--ink-2': 'Second text', '--muted': 'Hints, help lines',
 '--line': 'Light frame edge, rules', '--line-2': 'Input borders, dark frame edge', '--brand': 'Moss: links, good accents', '--brand-ink': 'Green text', '--brand-soft': 'Green wash (good, selected)', '--brand-line': 'Green border',
 '--accent': 'Gold: energy, notices, highlights', '--accent-soft': 'Gold wash', '--accent-ink': 'Gold text', '--accent-line': 'Gold border', '--danger': 'Red: errors, destructive', '--danger-soft': 'Red wash',
 '--danger-ink': 'Red text', '--danger-line': 'Red border', '--info-soft': 'Blue wash', '--info-ink': 'Blue text', '--info-line': 'Blue border', '--purple': 'Purple: Book, magic', '--purple-soft': 'Purple wash', '--purple-ink': 'Purple text',
 '--focus': 'Keyboard focus ring', '--brand-fill': 'Solid moss behind cream text', '--badge-bg': 'Solid umber behind cream text',
 '--edge-lt': 'Frame: lit upper-left edge', '--edge-dk': 'Frame: dark lower-right edge', '--drop': 'Frame: 2 px stepped drop', '--ol': 'Umber outline (buttons, felt bars)',
 '--thread': 'Stitch thread on cards', '--thread-bright': 'Hem stitch on felt', '--felt': 'Umber felt: header, bottom bar, footer', '--felt-2': 'Felt patches (header pills)', '--felt-ink': 'Text on felt', '--felt-muted': 'Quiet text on felt', '--on-fill': 'Text on solid fills', '--box-bg': 'Card fill', '--plot': 'Garden soil', '--sel': 'Selected tile',
 '--chip-energy-bg': 'Energy chip', '--chip-gold-bg': 'Petals chip', '--chip-lvl-bg': 'Level chip', '--r-c': 'Rarity: common', '--r-u': 'Rarity: uncommon', '--r-r': 'Rarity: rare', '--r-l': 'Rarity: legendary', '--map-sea': 'Region map sea', '--map-road': 'Region map road'}

def f_tokens():
    css = rd(STYLE); L, D = tokens(css)
    groups = [('Surfaces and text', ['--bg', '--surface', '--surface-2', '--box-bg', '--ink', '--ink-2', '--muted', '--line', '--line-2']),
              ('Moss (brand)', ['--brand', '--brand-ink', '--brand-soft', '--brand-line', '--brand-fill', '--badge-bg']),
              ('Gold, red, blue, purple', ['--accent', '--accent-soft', '--accent-ink', '--accent-line', '--danger', '--danger-soft', '--danger-ink', '--danger-line', '--info-soft', '--info-ink', '--info-line', '--purple', '--purple-soft', '--purple-ink', '--focus']),
              ('Stitched Toy chrome', ['--edge-lt', '--edge-dk', '--drop', '--ol', '--thread', '--thread-bright', '--felt', '--felt-2', '--felt-ink', '--felt-muted', '--on-fill']),
              ('Chips and rarity', ['--chip-energy-bg', '--chip-gold-bg', '--chip-lvl-bg', '--r-c', '--r-u', '--r-r', '--r-l']),
              ('Game art', ['--plot', '--sel', '--map-sea', '--map-road'])]
    h = []
    for title, names in groups:
        rows = ''
        for n in names:
            lv = L.get(n); dv = D.get(n, lv)
            if not lv or not lv.startswith('#'): continue
            rows += '<tr><td>%s</td><td>%s</td><td><code>%s</code></td><td>%s</td><td><code>%s</code></td><td>%s</td></tr>' % (sw(lv), sw(dv), E(n), E(lv), E(dv), E(ROLES.get(n, '')))
        h.append('<h3>%s</h3><table><tr><th>Light</th><th>Dark</th><th>Token</th><th>Light hex</th><th>Dark hex</th><th>Use</th></tr>%s</table>' % (E(title), rows))
    C.ntokens = len(L)
    return '\n'.join(h)

def f_areas():
    css = rd(STYLE); rows = ''
    for a in ('garden', 'world', 'kitchen', 'book', 'market', 'community'):
        m = re.search(r'^body\[data-area="%s"\] \{([^}]*)\}' % a, css, re.M); d = re.search(r'^:root\[data-theme="dark"\] body\[data-area="%s"\] \{([^}]*)\}' % a, css, re.M)
        lv = dict(re.findall(r'(--[\w-]+):\s*([^;]+);', m.group(1))) if m else {}; dv = dict(re.findall(r'(--[\w-]+):\s*([^;]+);', d.group(1))) if d else {}
        rows += '<tr><td><b>%s</b></td><td>%s %s</td><td>%s %s</td><td>%s %s</td><td>%s %s</td></tr>' % (a, sw(lv.get('--area', '#fff')), E(lv.get('--area', '')), sw(lv.get('--area-soft', '#fff')), E(lv.get('--area-soft', '')), sw(dv.get('--area', '#000')), E(dv.get('--area', '')), sw(dv.get('--area-soft', '#000')), E(dv.get('--area-soft', '')))
    return '<table><tr><th>Area</th><th>Light hue</th><th>Light wash</th><th>Dark hue</th><th>Dark wash</th></tr>%s</table>' % rows

def f_palette():
    try: pal = json.load(open(os.path.join(PH, 'palette.json')))
    except Exception: pal = {}
    h = '<div class="swrow keep">' + swatch('umber line', hearth.UMBER) + swatch('cream halo', hearth.HALO) + swatch('rim light', hearth.RIM) + swatch('rim tone', hearth.RIMTONE) + '</div>'
    rows = ''
    for fam, v in pal.items():
        if isinstance(v, dict): rows += '<tr><td><b>%s</b></td><td>%s</td></tr>' % (E(fam), ' '.join('<span style="white-space:nowrap">%s <code>%s</code></span>' % (sw(c), E(k)) for k, c in v.items()))
        elif isinstance(v, str) and v.startswith('#'): rows += '<tr><td><b>%s</b></td><td>%s <code>%s</code></td></tr>' % (E(fam), sw(v), E(v))
    return h + '<table class="keep"><tr><th>Family</th><th>Steps (step number, then colour)</th></tr>%s</table>' % rows

def f_remap():
    rows = ''.join('<tr><td>%s <code>%s</code></td><td>%s <code>%s</code></td><td class="muted">%s</td></tr>' % (sw(a), a, sw(b), b, 'characters only' if False else '') for a, b in hearth.REMAP.items())
    rows2 = ''.join('<tr><td>%s <code>%s</code></td><td>%s <code>%s</code></td></tr>' % (sw(a), a, sw(b), b) for a, b in hearth.CHAR_REMAP.items())
    return ('<div class="cols2"><div><table><tr><th>Picture colour</th><th>Becomes</th><th></th></tr>%s</table></div>' % rows +
            '<div><table><tr><th>Creature / folk colour</th><th>Becomes</th></tr>%s</table></div></div>' % rows2)

def f_tint():
    names = {'g': 'greens', 'r': 'reds', 'b': 'blues', 'p': 'purples', 'y': 'golds, yellows', 'w': 'browns, oranges', 's': 'greys'}
    return '<div class="swrow">' + ''.join(swatch(names[k], v) for k, v in hearth.TINT.items()) + '</div>'

def f_layers():
    s = '<div class="cols3">'
    for lab, col in (('Halo: icons 6.0 u, stickers 3.2 u', hearth.HALO), ('Outline: icons 3.4 u, stickers 1.9 u', hearth.UMBER), ('Shade crescent', hearth.TINT['g'])):
        s += '<div class="card"><b>%s</b><br>%s</div>' % (lab, sw(col) + ' <code>%s</code>' % col)
    hat = [i for i in C.icons if i['name'] == 'gnome-hat']
    if hat: s = s.replace('</div><div class="card"><b>Outline', '</div><div class="card"><b>Outline', 1)
    return s + '</div>'

def f_caps():
    return ('<table><tr><th>Kind</th><th class="num">Hard cap</th><th>Notes</th></tr>'
            '<tr><td>Most pictures, icons, items</td><td class="num">4096 B</td><td>Ladder aims at 3500 B</td></tr>'
            '<tr><td><code>creature-*</code>, <code>npc-*</code></td><td class="num">4096 B</td><td>Lean mode (1 decimal, no rim). Over 3900 B: swarm mode</td></tr>'
            '<tr><td><code>banner-*</code>, <code>land-*</code>, <code>guide-*</code></td><td class="num">8192 B</td><td>Scenes: full-bleed allowed</td></tr></table>')

SPEC = ['tomato', 'sunflower', 'acai', 'creature-giant-bumblebee', 'creature-giant-anteater', 'npc-wren-thimblewick', 'nav-garden', 'sunflower-snack']
def f_specimen():
    figs = ''
    for n in SPEC:
        p = os.path.join(PH, n + '.svg')
        if os.path.isfile(p): figs += '<figure><img src="%s" alt=""><br>%s</figure>' % (data_uri(p, 'image/svg+xml'), E(n.replace('creature-giant-', 'c-').replace('npc-wren-thimblewick', 'npc-wren')))
    return '<div class="tiny-spec">%s</div>' % figs

def f_icocss():
    css = rd(STYLE); i = css.find('/* v2.0.23 icons */'); blk = css[i:] if i >= 0 else ''
    rows = ''
    for sel, size in re.findall(r'([^{}\n]+)\{height:([\d.]+em);', blk):
        sel = sel.strip()
        rows += '<tr><td><code>%s</code></td><td class="num">%s</td></tr>' % (E(sel), E(size))
    return '<table><tr><th>Where the icon sits</th><th class="num">Size</th></tr>%s</table>' % rows if rows else ''

def f_icosizes():
    pick = [i for i in C.icons if i['name'] in ('bee', 'watering-can', 'carrot', 'mushroom', 'coffee')] or C.icons[:5]
    for i in pick: VEC.add(i['name'])
    s = '<div class="demo">'
    for px in (16, 20, 24, 48):
        s += '<div>%s<br>%d px</div>' % (''.join(use(i['stem'], 'i', px) for i in pick), px)
    s += '</div><p></p><div class="cols2 keep">'
    for cls, lab in (('dk', 'Dark chip'), ('lt', 'Light chip')):
        ic = lambda: use(pick[0]['stem'], '')
        s += '<div class="chipbox %s"><b>%s %s Watering</b> <span style="opacity:.75">&middot; %s</span></div>' % (cls, ic(), '', lab)
    return s + '</div>'

def f_dodont(key):
    do, dont = text.DODONT[key]
    return '<div class="cols2"><div class="do"><h3>Do</h3><ul>%s</ul></div><div class="dont"><h3>Don’t</h3><ul>%s</ul></div></div>' % (''.join('<li>%s</li>' % x for x in do), ''.join('<li>%s</li>' % x for x in dont))

def f_catstats():
    ic = C.icons; mapped = [i for i in ic if i['map']]; bad = [i for i in ic if i['bad'] or i['vb'] != '0 0 64 64']
    dup = {}; [dup.setdefault(x, []).append(i['stem']) for i in ic for x in i['ids']]; dup = {k: v for k, v in dup.items() if len(v) > 1}
    tot = sum(i['bytes'] for i in ic); mx = max(ic, key=lambda i: i['bytes']) if ic else None
    over = [i for i in ic if i['bytes'] > 4096]
    C.stats = dict(icons=len(ic), mapped=len(mapped), bad=len(bad), dup=len(dup), over=len(over))
    rows = [('Icons in the folder', str(len(ic))), ('With an emoji map row', '%d (the rest still show their emoji until mapped)' % len(mapped)),
            ('Total size / largest', '%.0f KB / %s (%d B)' % (tot / 1024, mx['name'] if mx else '-', mx['bytes'] if mx else 0)),
            ('Over the 4096 B cap', '<span class="badge %s">%d</span>' % ('b-ok' if not over else 'b-bad', len(over)) + (' ' + ', '.join(i['name'] for i in over[:6]) if over else '')),
            ('Banned content or odd viewBox', '<span class="badge %s">%d</span>' % ('b-ok' if not bad else 'b-bad', len(bad)) + (' ' + ', '.join('%s (%s)' % (i['name'], ' '.join(i['bad']) or 'viewBox') for i in bad[:6]) if bad else '')),
            ('Duplicate internal ids', '<span class="badge %s">%d</span>' % ('b-ok' if not dup else 'b-bad', len(dup)) + (' ' + ', '.join(list(dup)[:4]) if dup else ''))]
    return '<table><tr><th>Check</th><th>Result</th></tr>%s</table>' % ''.join('<tr><td>%s</td><td>%s</td></tr>' % (a, b) for a, b in rows)

def f_catalog():
    cards = ''
    for i in C.icons:
        m = i['map']; e = '' if m else '<div class="e"><span class="muted">no map row yet</span></div>'
        if i['stem'] in RAS: pic = '<img class="cardimg" src="%s" alt="">' % RAS[i['stem']]
        else:
            row = lambda cls: '<div class="strip %s">%s%s%s</div>' % (cls, use(i['stem'], 'ico48', 48), use(i['stem'], 'ico24', 24), use(i['stem'], 'ico16', 16)); VEC.add(i['name']); pic = row('dk') + row('lt')
        cards += '<div class="ic"><div class="n">%s</div>%s%s</div>' % (E(i['name']), e, pic)
    return '<div class="cat">%s</div>' % cards

def f_unmapped():
    have = {i['stem'] for i in C.icons} | {i['name'] for i in C.icons}
    orphans = [(s, d) for s, d in C.map.items() if s not in have]
    s = ''
    if orphans:
        s += '<h2>Map rows without a file yet</h2><p>These emoji still show as emoji until the icon is drawn (step 1 of “Adding an icon”).</p><p>%d to draw: %s</p>' % (len(orphans), ' '.join('<code>%s</code>' % E(a) for a, d in orphans))
    return s

def f_shots():
    def fig(name, cap, wide=False):
        d, l = C.shots.get((name, 'dark')), C.shots.get((name, 'light'))
        if wide: return '<figure class="fig"><div class="shot-wide shots"><div><div class="lab">Dark</div><img src="%s" alt=""></div></div><div class="shots"><div><div class="lab">Light</div><img src="%s" alt=""></div></div><figcaption>%s</figcaption></figure>' % (d, l, cap)
        return '<figure class="fig"><div class="shots"><div><div class="lab">Dark</div><img src="%s" alt=""></div><div><div class="lab">Light</div><img src="%s" alt=""></div></div><figcaption>%s</figcaption></figure>' % (d, l, cap)
    parts = [('type', '<code>.box</code> felt patch (<code>--frame</code>), centred: h1 24 (26 desktop) on an area ribbon with a gold seam, h2 19, h3 16, all 800; body 16, small 13, <code>.help</code> 13 muted.'),
             ('buttons', '<code>.btn</code> felt toy: lit top, shaded bottom, umber outline, presses 2 px. Solid moss = main verb. <code>.ghost</code> for the rest. <code>.gold</code> buys, <code>.red</code> destroys. <code>.small</code> 36 px, <code>.act</code> 48 px. Tap target 44 px.'),
             ('tabs', '<code>nav.tabs</code> felt tags (on = solid area colour, outlined) and <code>.chip</code> status chips (<code>chip-in</code>, <code>chip-off</code>, <code>chip-pest</code>, <code>chip-rain</code>).'),
             ('choice', '<code>choice_row()</code> rows: icon, title, small sub-line, badge (<code>good</code>, <code>cost</code>, <code>poor</code>, <code>free</code>). <code>primary</code> / <code>is-selected</code> = moss edge and inner band.'),
             ('fold', '<code>details.fold</code>: closed by default. Explanations live here.'),
             ('flash', '<code>.flash</code> messages (ok, <code>err</code>) and <code>.box.notice</code> / <code>.box.danger</code>.'),
             ('stitch', 'Special cards only: <code>.prizebox</code> / <code>.eventbox</code> get the gold edge stitch (<code>--st-h</code>, <code>--st-v</code>); <code>hr</code> is a stitched seam with a button knot.'),
             ('picker', '<code>dialog.picker</code> &gt; <code>.pickbox</code>: head, grid of <code>.pcard</code>, foot with one solid button.'),
             ('form', '<code>.form</code> labels above inputs, 44 px fields, 16 px text so phones do not zoom.')]
    h = ''.join('<div class="keep"><h3>%s</h3>%s</div>' % (n.capitalize(), fig(n, c)) for n, c in parts if (n, 'dark') in C.shots)
    if ('deskgrid', 'dark') in C.shots:
        h += '<div class="keep"><h3>Desktop, 1200 px</h3>' + fig('deskgrid', 'Equal cards, centred, small buttons. Shown scaled down; same rules from 721 px up.', True) + '</div>'
    return h

def f_sources():
    return ('<ul><li>Art rules: written from <code>tests/hearth.py</code> and <code>hearth_all.py</code> (constants and docstrings), <code>claude/handoff.md</code> and <code>assets/img/ph/palette.json</code>. '
            'This text also builds <code>claude/art-style-guide.md</code> (<code>tests/build_guide_md.py</code>); no older hand-written guide was found. Change <code>guide_src/text.py</code> to change both.</li>'
            '<li>Icons: <code>assets/img/ico/</code> and <code>includes/data/ico_map.php</code>, read at build time.</li>'
            '<li>UI: <code>assets/style.css</code> (%d tokens read), plus real screenshots of the component classes.</li></ul>' % C.ntokens)

FILL = {'SOURCES': lambda a: f_sources(), 'LAYERS': lambda a: f_layers(), 'PALETTE': lambda a: f_palette(), 'REMAP': lambda a: f_remap(), 'TINT': lambda a: f_tint(), 'SPECIMEN': lambda a: f_specimen(),
        'CAPS': lambda a: f_caps(), 'ICOCSS': lambda a: f_icocss(), 'ICOSIZES': lambda a: f_icosizes(), 'DODONT': f_dodont, 'CATSTATS': lambda a: f_catstats(), 'CATALOG': lambda a: f_catalog(),
        'UNMAPPED': lambda a: f_unmapped(), 'TOKENS': lambda a: f_tokens(), 'AREAS': lambda a: f_areas(), 'SHOTS': lambda a: f_shots(),
        'TYPE': lambda a: TYPE_TABLE, 'SPACING': lambda a: SPACE_TABLE}

TYPE_TABLE = ('<table><tr><th>Style</th><th class="num">Size</th><th>Weight</th><th>Sample</th></tr>'
 '<tr><td>h1</td><td class="num">24 px (26 from 721)</td><td>800</td><td style="font-size:18pt;font-weight:800">Fernhollow Patch</td></tr>'
 '<tr><td>h2</td><td class="num">19 px</td><td>800</td><td style="font-size:14pt;font-weight:800">Section heading</td></tr>'
 '<tr><td>h3, <code>.subhead</code> 15</td><td class="num">16 px</td><td>800</td><td style="font-size:12pt;font-weight:800">Sub heading</td></tr>'
 '<tr><td>body</td><td class="num">16 px (15 on desktop)</td><td>400</td><td>Short lines, plain words.</td></tr>'
 '<tr><td>choice title / sub</td><td class="num">15 / 12.5 px</td><td>600 / 400</td><td>Plant carrots <span class="muted">Ready in 3 days</span></td></tr>'
 '<tr><td>small, help, chip</td><td class="num">13 px</td><td>400</td><td class="muted">One short muted line</td></tr>'
 '<tr><td>tabs, small button</td><td class="num">14 px</td><td>500</td><td>Garden &middot; Beds</td></tr>'
 '<tr><td>code</td><td class="num">13 px</td><td>mono</td><td><code>choice_row()</code></td></tr></table>')
SPACE_TABLE = ('<table><tr><th>Token</th><th class="num">Value</th><th>Use</th></tr>'
 '<tr><td><code>--tap</code></td><td class="num">44 px</td><td>Minimum touch target (buttons, inputs, summary rows)</td></tr>'
 '<tr><td><code>--radius</code> / <code>-sm</code> / <code>--pill</code></td><td class="num">0</td><td>Hard pixel corners everywhere (v2.0.32). Frames notch the corners instead.</td></tr>'
 '<tr><td><code>--px</code></td><td class="num">2 px</td><td>One art pixel: frame edges, stitches, drops</td></tr>'
 '<tr><td><code>--frame</code> / <code>--frame-lite</code></td><td class="num">2 px + 2 px drop</td><td>Box-shadow frame for panels / one-tone frame for rows inside them. No layout space: leave ~4 px room</td></tr>'
 '<tr><td><code>--hem</code>, <code>--st-h</code>, <code>--st-v</code></td><td class="num">4 on / 2 off</td><td>Stitch lines (hard-stop stripes): felt hems / edge stitch</td></tr>'
 '<tr><td><code>--gut</code></td><td class="num">16 px (24 from 721 px)</td><td>Side gutter of the page</td></tr>'
 '<tr><td><code>--hdr</code>, <code>--bar</code></td><td class="num">52 (60) / 56 px</td><td>Slim top bar / phone bottom bar</td></tr>'
 '<tr><td><code>--maxw</code></td><td class="num">1392 px</td><td>Widest content</td></tr>'
 '<tr><td><code>.box</code> padding</td><td class="num">14 x 16 px</td><td>Card inner space, 16 px below</td></tr>'
 '<tr><td>gaps</td><td class="num">10, 12, 14 px</td><td>Choice list and tabs 10, tiles 12, stat cards 14 (room for the frames)</td></tr>'
 '<tr><td><code>--shadow</code></td><td class="num">2 2 0, no blur</td><td>Hard pixel drop. Popups use <code>--shadow-2</code> (outline + 6 px drop)</td></tr></table>')

# ---------- assemble ----------
def toc_html(entries, pages):
    out = '<ul class="toc">'
    for kind, title, sid in entries:
        pg = pages.get(sid, '')
        out += '<li class="%s"><span class="t">%s</span><span class="p">%s</span></li>' % (kind, E(title), pg if kind != 'part' else '')
    return out + '</ul>'

def page_html(pages, pagecount, shots_ok=True):
    css = rd(os.path.join(SRC, 'guide.css'))
    _d = datetime.date.today(); when = '%d %s' % (_d.day, _d.strftime('%B %Y'));   # portable (no %-d on Windows)
    ver = app_version()
    hat = next((i for i in C.icons if i['name'] == 'gnome-hat'), None) or (C.icons[0] if C.icons else None)
    if hat: VEC.add(hat['name'])
    cover = '<section class="cover">%s<h1>Gnome Venture<br>Style Sheet &amp; Art Guide</h1><p class="sub">Hearthlight art, inline icons and the UI rules</p><div class="meta">Game version %s<br>Built %s<br>%d inline icons &middot; %d colour tokens%s</div><div class="band">Cosy garden game &middot; gnomeventure.ca</div></section>' % (
        use(hat['stem'], 'hat') if hat else '', E(ver), E(when), len(C.icons), C.ntokens, (' &middot; %d pages' % pagecount) if pagecount else '')
    entries = []; body = ''; last = None
    fill = lambda n, a: FILL[n](a) if n in FILL else '<!-- %s? -->' % n
    for sid, part, title, src in text.SECTIONS:
        if part != last and text.PARTS.get(part): entries.append(('part', text.PARTS[part], 'p-' + part))
        last = part
        entries.append(('sub', title, sid))
    toc = '<section class="page pfront"><h1>Contents</h1>' + toc_html(entries, pages) + '</section>'
    for sid, part, title, src in text.SECTIONS:
        body += '<section class="%s p%s" id="%s"><h1>%s</h1>%s</section>\n' % ('page' if sid in BREAK else 'flow', '' if part == 'front' else part, sid, E(title), md(src, fill))
    body = body.replace('class="page pa"', 'class="page pa"')
    sprite = '<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>%s</defs></svg>' % ''.join(sym(i) for i in C.icons if i['name'] in VEC)
    return '<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Gnome Venture Style Sheet and Art Guide</title><style>%s</style></head><body>%s%s%s%s</body></html>' % (css, sprite, cover, toc, body), entries

def to_pdf(htmlsrc, out):
    from playwright.sync_api import sync_playwright
    with sync_playwright() as p:
        b = p.chromium.launch(); pg = b.new_page(); pg.set_content(htmlsrc, wait_until='load'); pg.wait_for_timeout(300)
        pg.pdf(path=out, format='A4', print_background=True, prefer_css_page_size=True)
        b.close()

def pdf_pages(path):
    try: return int(re.search(r'Pages:\s+(\d+)', subprocess.run(['pdfinfo', path], capture_output=True, text=True).stdout).group(1))
    except Exception:
        n = len(re.findall(rb'/Type\s*/Page[^s]', open(path, 'rb').read())); return n

def find_pages(path, entries, n):
    if not shutil.which('pdftotext'): return {}
    texts = []
    for pg in range(1, n + 1):
        texts.append(subprocess.run(['pdftotext', '-enc', 'UTF-8', '-f', str(pg), '-l', str(pg), '-layout', path, '-'], capture_output=True, encoding='utf-8', errors='replace').stdout or '')
    res = {}; norm = lambda s: re.sub(r'\s+', ' ', s).strip().lower()
    toc_pg = next((i for i, t in enumerate(texts) if 'contents' in t.lower()[:200] and 'About this guide' in t), 1)
    for kind, title, sid in entries:
        if kind == 'part': continue
        for i in range(toc_pg + 1, n):
            if any(norm(l) == norm(title) for l in texts[i].split('\n') if l.strip()): res[sid] = i + 1; break
    return res

def main():
    html_only = '--html-only' in sys.argv
    C.icons, C.map = load_icons(); C.shots = {}
    log('icons', len(C.icons), 'map rows', len(C.map))
    C.ntokens = len(tokens(rd(STYLE))[0])
    try: C.shots = shots()
    except Exception as ex: log('WARNING: no component screenshots:', repr(ex))
    log('screenshots', len(C.shots))
    raster_icons(C.icons); log('rasters', len(RAS))
    os.makedirs(OUTDIR, exist_ok=True)
    tmp = PDF + '.tmp.pdf'
    h1, entries = page_html({}, 0); to_pdf(h1, tmp); n = pdf_pages(tmp)
    pages = find_pages(tmp, entries, n); log('pass 1 pages', n, 'toc found', len(pages), '/', len([e for e in entries if e[0] != 'part']))
    h2, _ = page_html(pages, n); 
    if html_only: open(os.path.join(OUTDIR, '..', '..', '..', 'guide-preview.html'), 'w', encoding='utf-8').write(h2); return
    to_pdf(h2, tmp); n2 = pdf_pages(tmp)
    if n2 != n:   # cover/TOC text changed the page count: one more pass
        pages = find_pages(tmp, entries, n2); h3, _ = page_html(pages, n2); to_pdf(h3, tmp); n2 = pdf_pages(tmp); h2 = h3
    os.replace(tmp, PDF)
    open(PDF[:-4] + '.html.tmp', 'w').close(); os.remove(PDF[:-4] + '.html.tmp')
    meta = {'version': app_version(), 'built': datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%d %H:%M'), 'pages': n2, 'icons': len(C.icons), 'tokens': C.ntokens}
    json.dump(meta, open(os.path.join(OUTDIR, 'Gnome-Venture-Style-Guide.json'), 'w'))
    if '--keep-html' in sys.argv: open(os.path.join(tempfile.gettempdir(), 'gv-guide.html'), 'w', encoding='utf-8').write(h2)
    sz = os.path.getsize(PDF); log('wrote', PDF, '%.2f MB' % (sz / 1048576), n2, 'pages', C.stats if hasattr(C, 'stats') else '')
    if sz > 4 * 1048576: log('WARNING: over 4 MB')

if __name__ == '__main__': main()
