"""Writes assets/img/puzzles/<name>-still.png (the first frame of each puzzle GIF).
The jigsaw shows the still on every loose piece and animates only the solved part, so 150 pieces don't mean 150 running GIF decoders.
Run from the repo root after changing a puzzle GIF:  python3 tests/gen_puzzle_stills.py"""
import glob
from PIL import Image
for f in sorted(glob.glob('game/assets/img/puzzles/*.gif')):
    im = Image.open(f); im.seek(0)
    out = f[:-4] + '-still.png'
    im.convert('RGBA').save(out, optimize=True)
    print(out, im.size)
