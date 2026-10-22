# Builds gnome-parts/preview-tinted.html: the 7 layers stacked with CSS, beard + hat tinted by
# a masked colour layer with mix-blend-mode: multiply. PNGs are embedded as data URIs so masks work from file://.
import base64, os
D = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
uri = lambda n: "data:image/png;base64," + base64.b64encode(open(os.path.join(D, "png", n + ".png"), "rb").read()).decode()
U = {n: uri("gnome-" + n) for n in ["shadow", "body", "face", "beard", "hat", "band", "star"]}
HATS = [("#c0392b", "Poppy red"), ("#2e7d4f", "Moss green"), ("#2f5d9e", "Bluebell"), ("#e0a526", "Buttercup")]
BEARDS = [("#f4f1ea", "Snowy"), ("#d8c9a8", "Wheat"), ("#3b2f2f", "Dark loam")]
def stack(hat, beard, tier=3, cls="g"):
    h = [f'<img src="{U["shadow"]}" alt="">', f'<img src="{U["body"]}" alt="">', f'<img src="{U["face"]}" alt="">',
         f'<img src="{U["beard"]}" alt="">', f'<i class="t tb" style="background:{beard}"></i>',
         f'<img src="{U["hat"]}" alt="">', f'<i class="t th" style="background:{hat}"></i>']
    if tier >= 2: h.append(f'<img src="{U["band"]}" alt="">')
    if tier >= 3: h.append(f'<img src="{U["star"]}" alt="">')
    return f'<div class="{cls}">' + "".join(h) + "</div>"
rows = []
for bc, bn in BEARDS:
    cells = "".join(f'<figure>{stack(hc, bc)}{stack(hc, bc, 3, "g n")}<figcaption>{hn} hat<br>{bn} beard</figcaption></figure>' for hc, hn in HATS)
    rows.append(f'<section><h2>Beard: {bn} <code>{bc}</code></h2><div class="row">{cells}</div></section>')
tiers = "".join(f'<figure>{stack("#2e7d4f", "#d8c9a8", t)}{stack("#2e7d4f", "#d8c9a8", t, "g n")}<figcaption>Tier {"I" * t if t < 3 else "III"}</figcaption></figure>' for t in (1, 2, 3))
html = f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Gnome Tint Preview</title><style>
:root{{--bg:#f2e4c0;--fg:#2a1a10;--card:#fbf4e2}}
@media (prefers-color-scheme:dark){{:root:not([data-theme="light"]){{--bg:#2a1a10;--fg:#f2e4c0;--card:#3d2a1c}}}}
:root[data-theme="dark"]{{--bg:#2a1a10;--fg:#f2e4c0;--card:#3d2a1c}}
body{{margin:0;padding:16px;background:var(--bg);color:var(--fg);font:14px/1.4 system-ui,sans-serif}}
h1{{font-size:20px;margin:0 0 4px}} h2{{font-size:15px;margin:20px 0 8px}} p{{margin:0 0 12px;max-width:60ch}}
.row{{display:flex;flex-wrap:wrap;gap:12px}}
figure{{margin:0;background:var(--card);padding:10px;border-radius:8px;display:flex;align-items:flex-end;gap:10px}}
figcaption{{font-size:12px;align-self:center;width:84px}}
.g{{position:relative;width:160px;height:200px;isolation:isolate;flex:none}} .g.n{{width:80px;height:100px}}
.g>*{{position:absolute;inset:0;width:100%;height:100%;image-rendering:pixelated;display:block}}
.t{{mix-blend-mode:multiply;-webkit-mask-size:100% 100%;mask-size:100% 100%;-webkit-mask-repeat:no-repeat;mask-repeat:no-repeat}}
.tb{{-webkit-mask-image:url({U["beard"]});mask-image:url({U["beard"]})}}
.th{{-webkit-mask-image:url({U["hat"]});mask-image:url({U["hat"]})}}
@media (max-width:480px){{.g{{width:120px;height:150px}}}}
</style></head><body>
<h1>Player gnome: layered parts, tint check</h1>
<p>Each card: 2x (CSS, pixelated) and native 80x100. Beard and hat are neutral grey PNGs multiplied by the swatch; shadow, body, face, band and star are fixed colour. Tier III shown.</p>
{"".join(rows)}
<section><h2>Tiers (Moss green hat, Wheat beard)</h2><div class="row">{tiers}</div></section>
</body></html>'''
open(os.path.join(D, "preview-tinted.html"), "w", encoding="utf-8").write(html)
print("ok", len(html))
