#!/usr/bin/env python3
"""Jigsaw picture QA (v2.0.87): flags cells that would be hard to place. Usage: python3 tools/jigsaw_cell_check.py PICTURE.jpg|png [--grid 12x8]
Cuts the picture into the Advanced grid (default 12x8; try 18x12 for Expert), and for each cell counts distinct colours and looks for near-duplicate cells.
FLAT = fewer than 6 colours in the cell (a piece of sky or lawn); DUP = two cells that differ by under 4% (mean abs diff). Exit 1 (Advanced 12x8 only; other grids just report) if more than 6% of cells are FLAT or there are more than 2 DUP pairs. Sky cells at the top edge are the usual DUPs: give them a cloud, a bird or a kite."""
import sys
from PIL import Image
import numpy as np

def main():
    f = sys.argv[1]
    cols, rows = (12, 8)
    if '--grid' in sys.argv:
        cols, rows = map(int, sys.argv[sys.argv.index('--grid') + 1].split('x'))
    im = Image.open(f).convert('RGB')
    w, h = im.size
    a = np.asarray(im, dtype=np.int16)
    cw, ch = w // cols, h // rows
    cells, flat = {}, []
    for r in range(rows):
        for c in range(cols):
            cell = a[r * ch:(r + 1) * ch, c * cw:(c + 1) * cw]
            q = (cell // 24).reshape(-1, 3)   # JPEG noise: bucket the colours
            n = len({tuple(p) for p in q})
            cells[(c, r)] = cell
            if n < 6:
                flat.append((c, r, n))
    dups = []
    keys = list(cells)
    small = {k: np.asarray(Image.fromarray(cells[k].astype('uint8')).resize((16, 16)), dtype=np.int16) for k in keys}
    for i in range(len(keys)):
        for j in range(i + 1, len(keys)):
            if np.abs(small[keys[i]] - small[keys[j]]).mean() < 10:   # ~4% of 255
                dups.append((keys[i], keys[j]))
    print(f'{f}: {cols}x{rows} cells of {cw}x{ch}px; FLAT {len(flat)} ({100 * len(flat) / len(cells):.0f}%): {flat[:12]}; DUP pairs {len(dups)}: {dups[:8]}')
    sys.exit(1 if (cols, rows) == (12, 8) and (len(flat) > 0.06 * len(cells) or len(dups) > 2) else 0)

main()
