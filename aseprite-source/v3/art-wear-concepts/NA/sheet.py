#!/usr/bin/env python3
"""Maplewold (NA) wear concepts: checks + contact sheet.
  python3 sheet.py                 -> checks all 20 PNGs, writes sheet.png here
  python3 sheet.py review <cat> <out.png>  -> one category row enlarged 4x (for review)
"""
import os, sys, re
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
CATS = ["footwear", "backpack", "coat", "cloak"]
BG = (226, 220, 206, 255)
INK = (0x2b, 0x1c, 0x26)


def files(cat):
    fs = sorted(f for f in os.listdir(HERE) if re.match(rf"{cat}-[1-5]-.*\.png$", f))
    return [os.path.join(HERE, f) for f in fs]


def check(path):
    im = Image.open(path).convert("RGBA")
    errs = []
    if im.size != (64, 64):
        errs.append(f"size {im.size}")
    for (r, g, b, a) in im.getdata():
        if a not in (0, 255):
            errs.append("semi-alpha"); break
    cols = {p[:3] for p in im.getdata() if p[3] == 255}
    if (0, 0, 0) in cols: errs.append("#000000")
    if (255, 255, 255) in cols: errs.append("#ffffff")
    if INK not in cols: errs.append("no ink")
    return errs


def label(path):
    m = re.match(r"[a-z]+-\d-(.*)\.png", os.path.basename(path))
    return m.group(1).replace("-", " ").title()


def font(sz):
    for f in ["/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", "/usr/share/fonts/dejavu/DejaVuSans.ttf"]:
        if os.path.exists(f):
            return ImageFont.truetype(f, sz)
    return ImageFont.load_default()


def sheet(out, cats, scale=3):
    cw, ch, pad, lab = 64 * scale, 64 * scale, 12, 22
    S = Image.new("RGBA", (pad + 5 * (cw + pad), pad + len(cats) * (ch + lab + pad)), BG)
    d, ft = ImageDraw.Draw(S), font(13)
    for r, cat in enumerate(cats):
        for i, p in enumerate(files(cat)):
            im = Image.open(p).convert("RGBA").resize((cw, ch), Image.NEAREST)
            x, y = pad + i * (cw + pad), pad + r * (ch + lab + pad)
            S.paste(im, (x, y), im)
            t = f"{i + 1}. {label(p)}"
            w = d.textlength(t, font=ft)
            d.text((x + (cw - w) / 2, y + ch + 3), t, fill=(60, 44, 52, 255), font=ft)
    S.save(out)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "review":
        sheet(sys.argv[3], [sys.argv[2]], scale=4)
    else:
        bad = 0
        for cat in CATS:
            for p in files(cat):
                e = check(p)
                if e:
                    bad += 1
                    print(os.path.basename(p), e)
        print("checked", sum(len(files(c)) for c in CATS), "files,", bad, "with problems")
        sheet(os.path.join(HERE, "sheet.png"), CATS)
