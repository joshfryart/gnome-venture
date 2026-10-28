"""Shared bits for the Jigsaw pictures (v2.0.87): a 300 x 200 hard-pixel grid exported at 6x nearest-neighbour = 1800 x 1200 (3:2), so a piece of the
18 x 12 Expert tier is 16.7 source pixels wide. Same kit and rules as the other scenes (pixlib.py): hard pixels, three-tone umber outline on raised objects,
light from the upper left. Unlike the UI scenes these fill the WHOLE frame with detail (no calm corners): flat areas make a jigsaw unsolvable.
Usage from a picture script:  from jigsaw_common import *   then build on cv = new_canvas() and call save_pic(cv, 'maplewold').
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixlib as P  # noqa: E402

P.W, P.H = 300, 200   # the kit reads these module globals at call time
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, dil4  # noqa: E402,F401
import numpy as np  # noqa: E402,F401

W, H = 300, 200
SCALE = 6
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'game', 'assets', 'img', 'jigsaw')


def rnd(seed):
    """Small deterministic generator: r(a, b) -> int in [a, b]."""
    st = [seed * 2654435761 % 4294967296 or 1]

    def r(a, b):
        st[0] = (st[0] * 1103515245 + 12345) % 2147483648
        return a + (st[0] >> 8) % (b - a + 1)
    return r


def new_canvas(bg='#000000'):
    return Canvas(bg)


def save_pic(cv, slug, outdir=None):
    """Writes <slug>.jpg (1800 x 1200, q90: hard pixels survive) and <slug>-thumb.jpg (450 x 300)."""
    from PIL import Image
    outdir = outdir or OUT
    os.makedirs(outdir, exist_ok=True)
    im = Image.fromarray(cv.px, 'RGB').resize((W * SCALE, H * SCALE), Image.NEAREST)
    assert im.size == (1800, 1200)
    im.save(os.path.join(outdir, slug + '.jpg'), quality=90, subsampling=0, optimize=True)
    im.resize((450, 300), Image.NEAREST).save(os.path.join(outdir, slug + '-thumb.jpg'), quality=88, subsampling=0, optimize=True)
    return len({tuple(p) for p in cv.px.reshape(-1, 3)})
