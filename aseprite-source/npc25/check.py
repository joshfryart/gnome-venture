#!/usr/bin/env python3
"""python3 check.py <species> : verify the acceptance checklist, write <species>/sheet.png."""
import os, re, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUTLINE = (0x2b, 0x1c, 0x26)
VIEWS = ("front", "back", "side")
# per-species (head_top_idle1, max_width) from specs; feet line 71, head top checks include outline row
SPEC = {
 "hedgehog": (
  9,
  40
 ),
 "tortoise": (
  10,
  44
 ),
 "bat": (
  7,
  44
 ),
 "beetle": (
  8,
  36
 ),
 "bumblebee": (
  8,
  40
 ),
 "butterfly": (
  8,
  42
 ),
 "cricket": (
  7,
  40
 ),
 "dormouse": (
  9,
  38
 ),
 "dragonfly": (
  8,
  46
 ),
 "field-mouse": (
  9,
  40
 ),
 "firefly": (
  8,
  36
 ),
 "frog": (
  9,
  36
 ),
 "gecko": (
  9,
  40
 ),
 "grasshopper": (
  7,
  38
 ),
 "hare": (
  7,
  36
 ),
 "ladybird": (
  9,
  40
 ),
 "mole": (
  9,
  40
 ),
 "moth": (
  8,
  42
 ),
 "shrew": (
  9,
  42
 ),
 "snail": (
  8,
  44
 ),
 "stag-beetle": (
  8,
  40
 ),
 "stick-insect": (
  7,
  34
 ),
 "toad": (
  9,
  38
 ),
 "wood-mouse": (
  9,
  40
 ),
 "wren": (
  9,
  40
 )
}
# hopper and flyer may rise to T-3 on walk frames 4-6 (apex = frame 5; the hopper tables already use -2 on frame 4); others never above T-1
APEX = ["bat", "bumblebee", "butterfly", "cricket", "dragonfly", "firefly", "frog", "grasshopper", "hare", "moth", "toad", "wren"]
# first quirk colour per species (must appear in every view); stag-beetle's shield is hidden in the back view
QUIRK = {
 "bat": "#d98322",
 "beetle": "#b07c44",
 "bumblebee": "#f5b83a",
 "butterfly": "#f5809f",
 "cricket": "#a9824c",
 "dormouse": "#c94f84",
 "dragonfly": "#e2b552",
 "field-mouse": "#b48a4c",
 "firefly": "#f4c24a",
 "frog": "#b6d861",
 "gecko": "#b8604c",
 "grasshopper": "#c08a4a",
 "hare": "#ae8044",
 "ladybird": "#d93a30",
 "mole": "#e9bf5c",
 "moth": "#ece6bc",
 "shrew": "#dbb65c",
 "snail": "#9e5c3c",
 "stag-beetle": "#e8493b",
 "stick-insect": "#6e4a44",
 "toad": "#566e44",
 "wood-mouse": "#b08848",
 "wren": "#e2b97e"
}
QUIRK_HIDDEN = {("stag-beetle", "back")}
# hedgehog and tortoise predate the palette / edge rules below
LEGACY = {"hedgehog", "tortoise"}
SHADOW = {"#aaa9b8", "#74758c"}
fails = 0

def rep(ok, msg):
    global fails
    print(("PASS " if ok else "FAIL ") + msg)
    if not ok:
        fails += 1

def palette(sp):
    """palette_list from lib/species_<sp>.lua (look 1) plus the shadow tones."""
    p = os.path.join(HERE, "lib", f"species_{sp}.lua")
    if not os.path.exists(p):
        return None
    m = re.search(r"palette_list\s*=\s*\{(.*?)\}", open(p).read(), re.S)
    return {h.lower() for h in re.findall(r"#[0-9a-fA-F]{6}", m.group(1))} | SHADOW if m else None

def main(sp):
    imgs = {}
    for v in VIEWS:
        p = os.path.join(HERE, sp, f"{sp}-{v}.png")
        if not os.path.exists(p):
            rep(False, f"{v}: file missing {p}")
            continue
        imgs[v] = Image.open(p).convert("RGBA")
    top1, maxw = SPEC.get(sp, (None, None))
    frames = {}
    for v, im in imgs.items():
        rep(im.size == (512, 80), f"{v}: size {im.size} == 512x80")
        px = im.load()
        w, h = im.size
        alphas = {px[x, y][3] for y in range(h) for x in range(w)}
        rep(alphas <= {0, 255}, f"{v}: alpha only 0/255 (found {sorted(alphas)})")
        cols = {px[x, y][:3] for y in range(h) for x in range(w) if px[x, y][3]}
        rep((0, 0, 0) not in cols and (255, 255, 255) not in cols, f"{v}: no pure black/white")
        rep(OUTLINE in cols, f"{v}: outline #2b1c26 present")
        fr = [im.crop((i * 64, 0, i * 64 + 64, 80)) for i in range(8)]
        frames[v] = fr
        boxes = [f.getchannel("A").point(lambda a: 255 if a else 0).getbbox() for f in fr]
        rep(all(boxes), f"{v}: non-empty in all 8 frames")
        if all(boxes):
            bottoms = [b[3] - 1 for b in boxes]
            rep(all(b == 71 for b in bottoms), f"{v}: lowest opaque row == 71 per frame {bottoms}")
            tops = [b[1] for b in boxes]
            if top1 is not None:
                floor = [top1 - 1] * 8
                if sp in APEX: floor[3:6] = [top1 - 3] * 3  # frames 4-6: launch, apex (5), descend
                if sp == "tortoise": floor = [top1 - 4] * 8
                rep(tops[0] == top1 and tops[1] == top1 - 1 and all(t >= fl for t, fl in zip(tops, floor)),
                    f"{v}: head tops f1={tops[0]} f2={tops[1]} (want {top1}/{top1-1}; f4-6 may reach {top1-3} for hopper/flyer) all={tops}")
                wd = boxes[0][2] - boxes[0][0]
                rep(wd <= maxw, f"{v}: idle1 width {wd} <= {maxw}")
        if sp not in LEGACY:
            pal = palette(sp)
            if pal:
                extra = sorted("#%02x%02x%02x" % c for c in cols if "#%02x%02x%02x" % c not in pal)
                rep(not extra, f"{v}: only palette_list colours (extra: {extra})")
            gaps = 0
            for i, f in enumerate(fr):
                p = f.load()
                for y in range(80):
                    for x in range(64):
                        if p[x, y][3] and p[x, y][:3] != OUTLINE:
                            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                                nx, ny = x + dx, y + dy
                                if not (0 <= nx < 64 and 0 <= ny < 80) or p[nx, ny][3] == 0:
                                    gaps += 1
            rep(gaps == 0, f"{v}: outline on every silhouette edge ({gaps} bare edge pixels)")
            qc = QUIRK.get(sp)
            if qc and (sp, v) not in QUIRK_HIDDEN:
                rgb = tuple(int(qc[i:i + 2], 16) for i in (1, 3, 5))
                miss = [i + 1 for i, f in enumerate(fr) if rgb not in {px[:3] for px in f.getdata() if px[3]}]
                rep(not miss, f"{v}: quirk colour {qc} visible in every frame (missing frames {miss})")
        by = [f.tobytes() for f in fr]
        rep(by[0] != by[1], f"{v}: idle frames 1,2 differ")
        bad = [(a + 3, b + 3) for a in range(6) for b in range(a + 1, 6) if by[2 + a] == by[2 + b]]
        rep(not bad, f"{v}: walk frames 3-8 pairwise differ (identical pairs: {bad})")
    if len(imgs) == 3:
        b = {v: imgs[v].tobytes() for v in VIEWS}
        rep(len({*b.values()}) == 3, "front/back/side differ")
        sheet = Image.new("RGBA", (512, 240), (200, 200, 210, 255))
        for i, v in enumerate(VIEWS):
            sheet.alpha_composite(imgs[v], (0, i * 80))
        sheet = sheet.resize((2048, 960), Image.NEAREST)
        sheet.save(os.path.join(HERE, sp, "sheet.png"))
    print("RESULT", "FAIL" if fails else "PASS")
    sys.exit(1 if fails else 0)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: check.py <species>")
    main(sys.argv[1])
