#!/usr/bin/env python3
"""Check and contact-sheet the gnome-wear set: 33 item icons + 3 Tailor levels.

usage: python3 contact_sheet.py icons_sheet.png tailor_sheet.png [ph_dir]
Checks every PNG is 64x64 RGBA with only fully opaque / fully transparent pixels.
Sheets are 4x nearest-neighbour; the icon sheet shows each base family on a row (grey), the tailor
sheet shows the three levels on grey and on dark, plus a 1x strip.
"""
import os
import sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
PH = sys.argv[3] if len(sys.argv) > 3 else os.path.normpath(os.path.join(HERE, "../../../game/assets/img/ph"))
B5 = ["flood-boots", "wayfarers-hat", "work-gloves", "travel-cloak", "trail-pack"]
SUF5 = ["", "-b", "-lined", "-b-lined", "-fine", "-b-fine"]
ICONS = [[b + s for s in SUF5] for b in B5] + [["yarn-scarf", "yarn-scarf-lined", "yarn-scarf-fine"]]
TAILOR = ["tailor-1", "tailor-2", "tailor-3"]
SC = 4
GREY, DARK = (120, 120, 128, 255), (40, 34, 44, 255)


def load(slug):
    im = Image.open(os.path.join(PH, slug + ".png")).convert("RGBA")
    assert im.size == (64, 64), slug + " size %s" % (im.size,)
    data = im.get_flattened_data() if hasattr(im, "get_flattened_data") else im.getdata()
    bad = sum(1 for p in data if p[3] not in (0, 255))
    assert bad == 0, "%s: %d semi-transparent pixels" % (slug, bad)
    return im


def main():
    icons_out, tailor_out = sys.argv[1], sys.argv[2]
    n = 0
    cell = 64 * SC + 8
    sheet = Image.new("RGBA", (cell * 6, cell * len(ICONS)), GREY)
    for r, row in enumerate(ICONS):
        for col, slug in enumerate(row):
            im = load(slug).resize((64 * SC, 64 * SC), Image.NEAREST)
            sheet.alpha_composite(im, (col * cell + 4, r * cell + 4))
            n += 1
    sheet.save(icons_out)
    t = Image.new("RGBA", (cell * 3, cell * 2 + 80), GREY)
    for i, slug in enumerate(TAILOR):
        im = load(slug)
        big = im.resize((64 * SC, 64 * SC), Image.NEAREST)
        t.alpha_composite(big, (i * cell + 4, 4))
        dark = Image.new("RGBA", (cell, cell), DARK)
        dark.alpha_composite(big, (4, 4))
        t.paste(dark, (i * cell, cell))
        t.alpha_composite(im, (i * 80 + 8, cell * 2 + 8))
        n += 1
    t.save(tailor_out)
    print("ok: %d PNGs checked (64x64, hard alpha)" % n)


if __name__ == "__main__":
    main()
