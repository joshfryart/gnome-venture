#!/usr/bin/env python3
"""python3 check.py <species> : verify the acceptance checklist, write <species>/sheet.png."""
import os, re, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUTLINE = (0x2b, 0x1c, 0x26)
VIEWS = ("front", "back", "side")
# per-species (head_top_idle1, max_width) from specs; feet line 71, head top checks include outline row
SPEC = {"hedgehog": (9, 40), "tortoise": (10, 44)}
fails = 0

def rep(ok, msg):
    global fails
    print(("PASS " if ok else "FAIL ") + msg)
    if not ok:
        fails += 1

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
                rep(tops[0] == top1 and tops[1] == top1 - 1 and min(tops) >= top1 - 1 - (3 if sp == "tortoise" else 0),
                    f"{v}: head tops f1={tops[0]} f2={tops[1]} (want {top1}/{top1-1}) all={tops}")
                wd = boxes[0][2] - boxes[0][0]
                rep(wd <= maxw, f"{v}: idle1 width {wd} <= {maxw}")
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
