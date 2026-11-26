#!/usr/bin/env python3
"""Stitched Toy redraw of game/assets/img/scenes/here-shops-street-ea.png (480x300 RGBA, opaque scene card).
Staging only: writes art-review/stopart/out/scenes/here-shops-street-ea.png and _cmp/shops-street-ea.png."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from shops_street_kit import save

if __name__ == '__main__':
    print(save('ea'))
