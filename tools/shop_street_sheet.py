#!/usr/bin/env python3
"""Contact sheet for the Shop Street art: 4 pass stages, final in light + dark tint, all 14 regional looks.
Run: python3 tools/shop_street_sheet.py   -> aseprite-source/v3/shop-street/stages/contact-sheet.png"""
from PIL import Image, ImageDraw, ImageFont
import os
D = os.path.join(os.path.dirname(__file__), '..', 'aseprite-source', 'v3', 'shop-street')
ST = os.path.join(D, 'stages')
REG = ['NA','NWE','EE','MENA','CA','ESA','CSA','CB','OC','SEA','EA','SA','SE','WCA']
BG, INK, GOLD = (58, 40, 38), (248, 234, 204), (240, 200, 90)
F = ImageFont.load_default(size=20); FS = ImageFont.load_default(size=14)
def ld(p): return Image.open(p).convert('RGB')
def up(im, s): return im.resize((int(im.width * s), int(im.height * s)), Image.NEAREST)
stages = [('1  HAIKU  base', 'NA-1-p1-base.png'), ('2  SONNET  polish', 'NA-2-p2-polish.png'),
          ('3  OPUS  richness', 'NA-3-p3-rich.png'), ('4  HAIKU  tidy', 'NA-4-p4-tidy.png')]
W = 2020; pad = 20; lab = 30
cells = []
y = pad
sheet = Image.new('RGB', (W, 3600), BG); d = ImageDraw.Draw(sheet)
d.text((pad, y), 'SHOP STREET  -  pass-by-pass (480x300, shown 2x, region NA)', font=F, fill=GOLD); y += 40
x = pad
for i, (t, f) in enumerate(stages):
    im = up(ld(os.path.join(ST, f)), 2)
    if i == 2: x, y = pad, y + 600 + lab + pad
    d.text((x, y), t, font=F, fill=INK)
    sheet.paste(im, (x, y + lab)); x += im.width + pad
y += 600 + lab + pad * 2
fin = ld(os.path.join(D, 'final', 'NA.png'))
dark = Image.blend(fin, Image.new('RGB', fin.size, (34, 26, 70)), 0.45)
d.text((pad, y), 'FINAL  light  /  dark tint (hub-tint)', font=F, fill=GOLD); y += lab
sheet.paste(up(fin, 2), (pad, y)); sheet.paste(up(dark, 2), (pad * 2 + 960, y)); y += 600 + pad * 2
d.text((pad, y), 'REGIONAL LOOKS  (local side changes, Mossbottom terrace stays)', font=F, fill=GOLD); y += lab
cw, ch = 480, 300; cols = 4
for i, r in enumerate(REG):
    cx = pad + (i % cols) * (cw + pad); cy = y + (i // cols) * (ch + lab + pad)
    d.text((cx, cy), r, font=FS, fill=INK)
    sheet.paste(ld(os.path.join(D, 'final', r + '.png')), (cx, cy + 20))
y += ((len(REG) + cols - 1) // cols) * (ch + lab + pad) + pad
sheet = sheet.crop((0, 0, W, y))
out = os.path.join(ST, 'contact-sheet.png'); sheet.save(out); print(out, sheet.size)
