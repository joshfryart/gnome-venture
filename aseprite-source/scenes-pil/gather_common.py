"""Shared bits for the Gather tab scenes (one scene per land): the open satchel and its front wall, identical in every scene.

Usage from a land script:  from gather_common import draw_satchel, save_scene, LEATHER, DLEATH, ...
The page stacks: scene-<land>.png (back) < flourish < found item < satchel-front.png (front wall, shared).
So the satchel MUST be drawn by draw_satchel() at its fixed place (grid x 146..214, y 34..104) or the front wall will not line up.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pixlib as P  # noqa: E402
from pixlib import Canvas, ramp, rect, rrect, ell, poly, line  # noqa: E402

LEATHER = ramp('#b07a3a', '#7a4a1f', '#d9a35a', '#8a5a30')
DLEATH = ramp('#7a4a1f', '#5c3420', '#9a6b3f')
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'game', 'assets', 'img', 'gather')


def draw_satchel(cv):
    """The open satchel, flap thrown back, strap trailing up-left. Call AFTER the background and props."""
    o = cv.obj()
    o.part(rrect(150, 50, 206, 64, 3), DLEATH, d=2)
    o.part(rrect(146, 60, 210, 104, 4), LEATHER, d=3)
    o.part(poly([(150, 52), (206, 52), (214, 34), (146, 36)]), LEATHER, d=2, contour=True)
    o.part(rect(173, 64, 183, 76), DLEATH, d=1, contour=True)
    o.draw()
    cv.fill(rrect(152, 54, 204, 62, 2), '#2a1a10')
    cv.fill(rect(175, 68, 181, 73) & ~rect(177, 70, 179, 71), '#e8a317')
    for x in range(150, 207, 3):
        cv.dots([(x, 99)], '#f5cf6a')
    o = cv.obj()
    o.part(line([(146, 64), (128, 30), (100, 22)], 3), DLEATH, d=1)
    o.draw()


def save_scene(cv, land):
    cv.save(os.path.join(OUT, 'scene-%s.png' % land))
