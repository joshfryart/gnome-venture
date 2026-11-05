#!/usr/bin/env python3
"""Preview large trail landmarks without baking. Run: python3 -I tools/preview_trail_landmarks.py OUT.png [--sheet GROUP_PREFIX] [--section ROUTE SECTION FRAGMENT.json]
  --sheet P     a contact sheet of every landmark whose name starts with P (e.g. 232-), each with the 64 x 80 gnome beside it for scale
  --section R S F   composite route R section S (0-based) as the game draws it: the baked ground, the wall objects, and the landmarks listed for it in
                F ({route: [[ [x, y, name, jitter] ... ] per section]}); a red dot marks every cell of the walk from S to the exit (a landmark should
                stand off those cells), a blue line the top of the map (a landmark's top must stay below it).
Reads game/assets/img/trail/ground/R-(S+1).png and game/includes/data/trail_maps.json. Writes nothing else."""
import json, os, sys, importlib.util
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(REPO, "claude", "tile-art-v3-proposal"))
import gen2
gen2.ROOT = REPO
from PIL import Image, ImageDraw
spec = importlib.util.spec_from_file_location("bake", os.path.join(REPO, "tools", "bake_trail_art.py")); bake = importlib.util.module_from_spec(spec)
sys.argv_saved = sys.argv; sys.argv = [sys.argv[0], "--check"]; spec.loader.exec_module(bake); sys.argv = sys.argv_saved
a = sys.argv[1:]; out = a[0]
if "--sheet" in a:
    pre = a[a.index("--sheet") + 1]; names = [n for n in gen2.LANDMARKS if n.startswith(pre)]
    ims = [gen2.landmark(n) for n in names]; g = gen2.sprite("gnome-player.png", 0)
    cols = 3; cw = max(i.width for i in ims) + 90; rows = [ims[i:i + cols] for i in range(0, len(ims), cols)]
    rh = [max(i.height for i in r) + 28 for r in rows]
    sh = Image.new("RGBA", (cols * cw, sum(rh)), (96, 152, 72, 255)); y = 0
    for r, h in zip(rows, rh):
        for c, im in enumerate(r):
            sh.alpha_composite(im, (c * cw + 8, y + h - 8 - im.height)); sh.alpha_composite(g, (c * cw + 8 + im.width + 6, y + h - 8 - g.height))
        y += h
    # names under each
    d = ImageDraw.Draw(sh); y = 0; k = 0
    for r, h in zip(rows, rh):
        for c, im in enumerate(r): d.text((c * cw + 8, y + h - 7), f"{names[k]}  {im.width}x{im.height}", fill=(255, 255, 255, 255)); k += 1
        y += h
    sh.convert("RGB").save(out); print(out, sh.size)
if "--section" in a:
    i = a.index("--section"); rid, si, frag = int(a[i + 1]), int(a[i + 2]), a[i + 3]
    data = json.load(open(os.path.join(REPO, "game/includes/data/trail_maps.json")))["routes"][str(rid)]["sections"][si]
    lms = json.load(open(frag))[str(rid)][si]; rows = data["rows"]
    g = Image.open(os.path.join(REPO, f"game/assets/img/trail/ground/{rid}-{si + 1}.png")).convert("RGBA").crop((0, 40, 1408, 40 + 64 * len(rows)))
    items = []
    for ox, oy, key, jit in data["objs"]:
        if key.startswith("lm-"): continue
        items.append((oy + .5, ox, Image.open(os.path.join(REPO, f"game/assets/img/trail/obj/{key}.png")).convert("RGBA"), (ox * 64 + jit, oy * 64 - 29)))
    for ox, oy, name, jit in lms:
        im = gen2.landmark(name); items.append((oy + .5, ox, im, (ox * 64 + 32 - im.width // 2 + jit, oy * 64 + 62 - im.height)))
        if oy * 64 + 62 - im.height < 0: print(f"WARNING {name} at ({ox},{oy}): top is {oy * 64 + 62 - im.height} px, above the map: move it down a row or draw it shorter")
    path = bake.path_cells([r.replace("S", "S") for r in rows])
    for _, _, im, (x, y) in sorted(items, key=lambda t: (t[0], t[1])):
        c = Image.new("RGBA", g.size, (0, 0, 0, 0)); c.paste(im, (x, y)); g.alpha_composite(c)
    d = ImageDraw.Draw(g)
    for x, y in path: d.ellipse((x * 64 + 28, y * 64 + 28, x * 64 + 36, y * 64 + 36), fill=(255, 0, 0, 255))
    for ox, oy, name, jit in lms: d.rectangle((ox * 64 + 24, oy * 64 + 56, ox * 64 + 40, oy * 64 + 62), outline=(255, 255, 0, 255))
    d.line((0, 0, g.width, 0), fill=(0, 120, 255, 255), width=2)
    g.convert("RGB").resize((g.width * 2 // 3, g.height * 2 // 3), Image.LANCZOS).save(out); print(out, g.size)
