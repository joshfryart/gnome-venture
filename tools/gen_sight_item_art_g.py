#!/usr/bin/env python3
"""Four missing item pictures: well-water, firefly-light, lantern-fruit-seed, tiny-thank-you-seed.
Same method as gen_sight_item_art_f.py (helpers from _e): 64 x 64 RGBA, hard pixels, 5-tone ramps, ink outline.
Run:  python3 tools/gen_sight_item_art_g.py [slug ...]   -> game/assets/img/ph/<slug>.png
Sheet: python3 tools/gen_sight_item_art_g.py --sheet OUT.png"""
import os, sys
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import gen_sight_item_art_e as E  # noqa: E402
from gen_sight_item_art_e import (S, OUT, CREAM, ramp, Mpoly, Mell, Mrect, Mrr, Mline, union, minus, inter,  # noqa: E402
                                  pix, shade, px, sparkle, bezier, WOOD, GOLD, LEAF, MOSS, DEW, BLUE, STONE, PETAL, SAND, WOOL)

LANT = ramp("#fff6c0", "#ffe070", "#f2b830", "#c07a1e", "#7a4418")
GLASS = ramp("#f2fdff", "#d4f0fa", "#a8dcf0", "#78b4d8", "#4c80a8")
FLY = ramp("#ffffd8", "#f4ff8a", "#c8f04a", "#8cc030", "#527a24")
SEEDB = ramp("#f6e2b0", "#e2bc78", "#b88a4c", "#845a30", "#52361e")
FORGET = ramp("#e4f0ff", "#b8d4fa", "#86aff0", "#5a82cc", "#3a5694")


# ------------------------------------------------------------------ well-water: a stoppered glass flask of cold water on a rope sling
def well_water(cv, rnd):
    # rope sling loop
    px(cv, pix(Mline(bezier((22, 22), (32, 2), (42, 22), 12), 1)), WOOD[2])
    # neck + stopper
    shade(cv, Mrr(27, 16, 38, 24, 2), GLASS, "cyl", rnd)
    shade(cv, Mrr(26, 11, 39, 17, 2), WOOD, "cyl", rnd)
    px(cv, [(28, 13), (29, 13)], WOOD[0])
    # body
    body = union(Mell(32, 38, 15, 15), Mrr(25, 22, 40, 34, 3))
    shade(cv, body, GLASS, "ball", rnd, box=(17, 22, 48, 54))
    # water fills the lower body: a bright surface line and deeper blue
    water = inter(body, Mrect(0, 33, S, S))
    shade(cv, water, DEW, "ball", rnd, box=(17, 22, 48, 54))
    px(cv, [(x, 33) for x in range(19, 46) if body.getpixel((x, 33))], CREAM)
    # glass glints
    px(cv, pix(Mline([(22, 38), (22, 46)], 1)), CREAM)
    px(cv, [(24, 28), (24, 29)], CREAM)
    # label: little blue drop tag
    shade(cv, Mrr(27, 40, 38, 48, 2), WOOL, "flat", rnd)
    px(cv, [(32, 42), (31, 43), (32, 43), (33, 43), (31, 44), (32, 44), (33, 44), (32, 45)], BLUE[2])

    def post(c):
        sparkle(c, 12, 20, CREAM, True); sparkle(c, 52, 30, CREAM)
    return post


# ------------------------------------------------------------------ firefly-light: a glowing firefly cupped in a twist of reed
def firefly_light(cv, rnd):
    # reed cup (back), glow (middle), firefly (front)
    cup = Mpoly([(14, 34), (50, 34), (44, 54), (20, 54)])
    glow = Mell(32, 30, 17, 17)
    for x, y in pix(glow):
        d = ((x - 32) ** 2 + (y - 30) ** 2) ** .5
        cv.put(x, y, FLY[1] if d < 8 else FLY[2] if (x + y) % 2 else FLY[1]) if d < 14 else None
    shade(cv, cup, SAND, "cyl", rnd, .05)
    # reed weave: diagonal strands
    for k in range(0, 40, 6):
        px(cv, pix(inter(Mline([(14 + k, 36), (22 + k, 54)], 1), cup)), SAND[3])
    px(cv, [(x, 34) for x in range(14, 51)], SAND[0])
    # firefly: body, wings, glowing tail
    shade(cv, Mell(31, 28, 6, 4), LANT, "ball", rnd, rim=False)
    shade(cv, Mell(37, 29, 5, 4), FLY, "ball", rnd, rim=False)
    shade(cv, Mell(29, 23, 3, 2), GLASS, "ball", rnd, rim=False)
    shade(cv, Mell(34, 22, 3, 2), GLASS, "ball", rnd, rim=False)
    px(cv, [(26, 28), (26, 29)], E.INK); cv.put(27, 27, E.INK)

    def post(c):
        sparkle(c, 12, 16, FLY[0], True); sparkle(c, 52, 20, FLY[0]); sparkle(c, 46, 8, FLY[1])
    return post


# ------------------------------------------------------------------ lantern-fruit-seed: a plump warm pip with a glowing core and a tiny sprout
def lantern_fruit_seed(cv, rnd):
    pip = Mpoly(E.axis_poly((32, 52), -1.5708, [(0, 1), (6, 10), (22, 12), (32, 6), (36, 1)]))
    shade(cv, pip, SEEDB, "ball", rnd, .03)
    # warm glowing core, brighter than the husk
    core = Mell(32, 38, 5, 8)
    for x, y in pix(core):
        d = abs(x - 32) / 5 + abs(y - 38) / 8
        cv.put(x, y, LANT[0] if d < .45 else LANT[1] if d < .8 else LANT[2])
    # husk ridges
    px(cv, pix(Mline([(24, 44), (26, 34), (29, 28)], 1)), SEEDB[3])
    px(cv, pix(Mline([(40, 44), (38, 34), (35, 28)], 1)), SEEDB[3])
    # tiny sprout
    px(cv, pix(Mline(bezier((32, 22), (33, 14), (38, 12), 6), 1)), LEAF[2])
    shade(cv, Mell(38, 11, 3, 2), LEAF, "ball", rnd, rim=False)

    def post(c):
        sparkle(c, 14, 30, LANT[0], True); sparkle(c, 50, 36, LANT[0]); sparkle(c, 46, 14, LANT[1])
    return post


# ------------------------------------------------------------------ tiny-thank-you-seed: the smallest seed, in a folded paper twist with a bow and a forget-me-not
def tiny_thank_you_seed(cv, rnd):
    # paper twist
    paper = Mpoly([(14, 54), (50, 54), (44, 30), (20, 30)])
    shade(cv, paper, WOOL, "flat", rnd, .04)
    px(cv, [(x, 30) for x in range(20, 45)], WOOL[0])
    px(cv, pix(Mline([(24, 33), (22, 52)], 1)), WOOL[3]); px(cv, pix(Mline([(40, 33), (42, 52)], 1)), WOOL[3])
    # twisted top
    shade(cv, Mpoly([(22, 30), (42, 30), (36, 20), (28, 20)]), WOOL, "flat", rnd)
    # bow
    shade(cv, Mell(25, 20, 5, 3), PETAL, "ball", rnd, rim=False)
    shade(cv, Mell(39, 20, 5, 3), PETAL, "ball", rnd, rim=False)
    shade(cv, Mell(32, 20, 2, 2), PETAL, "ball", rnd, rim=False)
    px(cv, [(30, 23), (30, 24), (34, 23), (34, 24)], PETAL[3])
    # the tiny seed (a few pixels), and a forget-me-not stuck to the paper
    shade(cv, Mell(32, 44, 4, 3), SEEDB, "ball", rnd, rim=True)
    px(cv, [(29, 42), (30, 41)], CREAM)
    for dx, dy in ((0, -2), (2, 0), (0, 2), (-2, 0)):
        shade(cv, Mell(46 + dx, 18 + dy, 1.5, 1.5), FORGET, "ball", rnd, rim=False)
    cv.put(46, 18, LANT[1])

    def post(c):
        sparkle(c, 14, 40, CREAM, True)
    return post


ITEMS = {"well-water": well_water, "firefly-light": firefly_light,
         "lantern-fruit-seed": lantern_fruit_seed, "tiny-thank-you-seed": tiny_thank_you_seed}


def render(slug):
    E.ITEMS = ITEMS
    return E.render(slug)


def sheet(path):
    Z = 4
    out = Image.new("RGBA", (len(ITEMS) * (64 * Z + 8), 64 * Z + 16), (232, 232, 238, 255)); d = ImageDraw.Draw(out)
    for i, slug in enumerate(ITEMS):
        x = i * (64 * Z + 8)
        out.alpha_composite(render(slug).resize((64 * Z, 64 * Z), Image.NEAREST), (x, 16)); d.text((x + 4, 2), slug, fill=(0, 0, 0, 255))
    out.save(path)


def main():
    args = sys.argv[1:]
    if args and args[0] == "--sheet":
        sheet(args[1]); return
    os.makedirs(OUT, exist_ok=True)
    slugs = args or list(ITEMS)
    for slug in slugs:
        render(slug).save(os.path.join(OUT, slug + ".png"))
    print(f"wrote {len(slugs)} item pictures to {OUT}")


if __name__ == "__main__":
    main()
