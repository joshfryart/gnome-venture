#!/usr/bin/env python3
"""video -> Stitched Toy pixel GIF via Aseprite (the one house flow).
usage: python3 video2gif.py VIDEO [--name N] [--start S] [--dur D] [--fps F] [--grid W] [--out DIR]
       python3 video2gif.py --setup            # one-time: pip rembg/onnxruntime/scipy + u2netp model
Pipeline: ffmpeg (trim, fps, area-downscale to W-wide grid) -> median smooth (flat felt) -> Lab-nearest to the game
palette (Part A + blends, no dither) -> 3x3 majority despeckle -> umber seams on region borders -> subject cut-out
(rembg u2netp, majority-smoothed over 3 frames): 1px umber outline + bright 2px dashed stitch on the subject only
-> Aseprite headless builds the layered .aseprite and the 2x nearest GIF.
Defaults = the approved v5 look (grid 200, 10 fps, 2.4 s). Flags: --no-subject --no-outline --no-rich --dither N
--smooth N --despeckle N --no-stitch (background seam stitches, only used when there is no subject).
Outputs DIR/NAME.gif + DIR/NAME.aseprite (DIR default: this folder).
Aseprite: $ASEPRITE, --ase, else extracts ../../Aseprite_*.AppImage once into $GV_CACHE (default ~/.cache/gv-aseprite)."""
import argparse, glob, os, shutil, subprocess, sys, tempfile
import numpy as np
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
FAM = {"soil": "3d2a1c 7a4a1f 9a6b3f c9a96e f1ece0", "moss": "2f5a2a 4f9a45 7ab55c a4b86a",
       "gold": "b07a10 e8a317 f5cf6a", "ember": "a8241f d6322b e0501f f08a24", "petal": "e46a9b f6b8cf",
       "water": "25637d 3f8fb0 a9d6ea", "dusk": "4e3a8a 7a5cc0 c3b2ea", "stone": "5b6470 8b8f96 c9c5bc",
       "extra": "f2e4c0 fff3c8 f5b860"}
UMBER = np.array([0x3d, 0x2a, 0x1c], np.uint8)
rgb = lambda h: np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], float)

def palette(rich=True):
    """Part A colours + in-family midpoints; rich = also every 50% blend of two base colours (pruned per clip)."""
    F = {k: [rgb(h) for h in v.split()] for k, v in FAM.items()}
    P = [c for v in F.values() for c in v]
    for v in F.values():
        P += [(a + b) / 2 for a, b in zip(v, v[1:])]
    if rich:
        base = [c for v in F.values() for c in v]
        P += [(x + y) / 2 for i, x in enumerate(base) for y in base[i + 1:]]
    return np.unique(np.array(P).round(), axis=0)

def lab(c):
    c = c / 255; c = np.where(c > .04045, ((c + .055) / 1.055) ** 2.4, c / 12.92)
    M = np.array([[.4124, .3576, .1805], [.2126, .7152, .0722], [.0193, .1192, .9505]])
    x = c @ M.T / np.array([.9505, 1, 1.089]); f = np.where(x > .008856, np.cbrt(x), 7.787 * x + 16 / 116)
    return np.stack([116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])], -1)

_SESS = []
def subject_mask(im):
    """subject cut-out with rembg (u2netp, ~4 MB model, CPU). None if rembg/scipy are missing."""
    try:
        from rembg import new_session, remove
        from scipy import ndimage as nd
    except ImportError: return None
    if not _SESS: _SESS.append(new_session("u2netp"))
    big = im.resize((im.width * 2, im.height * 2), Image.BILINEAR)
    m = np.asarray(remove(big, session=_SESS[0], only_mask=True).resize(im.size, Image.NEAREST)) > 110
    return nd.binary_fill_holes(nd.binary_dilation(nd.binary_closing(m, iterations=2), iterations=1))

def setup():
    """install subject-cut-out deps and fetch the 4 MB u2netp model (needs pip + github reachable)."""
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", "numpy", "pillow", "scipy", "rembg", "onnxruntime"], check=True)
    d = os.path.expanduser("~/.u2net"); os.makedirs(d, exist_ok=True)
    subprocess.run(["curl", "-fsSL", "-o", os.path.join(d, "u2netp.onnx"),
                    "https://github.com/danielgatis/rembg/releases/download/v0.0.0/u2netp.onnx"], check=True)
    print("setup ok")

def prep(im, sat):
    x = 255 * (np.asarray(im, float) / 255) ** 0.7
    g = x.mean(2, keepdims=True)
    return np.clip(g + (x - g) * sat, 0, 255)

def find_ase(a):
    p = a or os.environ.get("ASEPRITE")
    if p: return p
    if shutil.which("aseprite"): return "aseprite"
    cache = os.environ.get("GV_CACHE", os.path.expanduser("~/.cache/gv-aseprite"))
    run = os.path.join(cache, "squashfs-root", "AppRun")
    if not os.path.exists(run):
        img = (glob.glob(os.path.join(HERE, "../../Aseprite_*.AppImage")) or sys.exit("no Aseprite found (set ASEPRITE)"))[0]
        os.makedirs(cache, exist_ok=True); tmp = os.path.join(cache, "a.AppImage"); shutil.copy(img, tmp); os.chmod(tmp, 0o755)
        subprocess.run([tmp, "--appimage-extract"], cwd=cache, check=True, stdout=subprocess.DEVNULL)
    return run

LUA = '''local S, OUT, N, W, H, MS = os.getenv("GV_S"), os.getenv("GV_OUT"), tonumber(os.getenv("GV_N")), tonumber(os.getenv("GV_W")), tonumber(os.getenv("GV_H")), tonumber(os.getenv("GV_MS"))
local spr = Sprite(W, H, ColorMode.RGB)
app.transaction(function()
  for i = 1, N do
    local fr = (i == 1) and spr.frames[1] or spr:newEmptyFrame()
    fr.duration = MS / 1000
    spr:newCel(spr.layers[1], fr, Image{ fromFile = string.format("%s/f%03d.png", S, i) }, Point(0, 0))
  end
end)
spr:saveAs(OUT .. ".aseprite")
app.command.SaveFileCopyAs{ ui = false, filename = OUT .. ".gif", resizeScale = 2, scale = 2 }
'''

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("video", nargs="?"); ap.add_argument("--setup", action="store_true"); ap.add_argument("--name"); ap.add_argument("--start", type=float, default=0)
    ap.add_argument("--dur", type=float, default=2.4); ap.add_argument("--fps", type=float, default=10)
    ap.add_argument("--grid", type=int, default=200, help="grid width; GIF is 2x"); ap.add_argument("--out", default=HERE)
    ap.add_argument("--outline", action=argparse.BooleanOptionalAction, default=True)
    ap.add_argument("--smooth", type=int, default=1, help="median passes for flat felt look (0=off)")
    ap.add_argument("--dither", type=float, default=0, help="ordered-dither strength (0=flat cel)")
    ap.add_argument("--rich", action=argparse.BooleanOptionalAction, default=True, help="cross-family blend colours in the palette")
    ap.add_argument("--despeckle", type=int, default=2, help="majority-filter passes on colour regions")
    ap.add_argument("--stitch", action=argparse.BooleanOptionalAction, default=True, help="dashed stitch beside seams")
    ap.add_argument("--subject", action=argparse.BooleanOptionalAction, default=True, help="heavy outline + bright stitches on the warm-fur subject only (needs rembg + scipy: pip install rembg onnxruntime scipy; u2netp.onnx into ~/.u2net)")
    ap.add_argument("--colours", type=int, default=72, help="keep the N most-used palette colours per clip (rich palette)")
    ap.add_argument("--sat", type=float, default=1.3, help="saturation boost before palette match")
    ap.add_argument("--ase"); a = ap.parse_args()
    if a.setup: return setup()
    if not a.video: ap.error("give a VIDEO (or --setup)")
    name = a.name or os.path.splitext(os.path.basename(a.video))[0]
    os.makedirs(a.out, exist_ok=True); ase = find_ase(a.ase)
    with tempfile.TemporaryDirectory() as t:
        raw, px = os.path.join(t, "raw"), os.path.join(t, "px"); os.makedirs(raw); os.makedirs(px)
        subprocess.run(["ffmpeg", "-v", "error", "-ss", str(a.start), "-t", str(a.dur), "-i", a.video, "-vf",
                        f"fps={a.fps},scale={a.grid}:-2:flags=area", os.path.join(raw, "f%03d.png")], check=True)
        files = sorted(glob.glob(raw + "/*.png")); assert files, "no frames (check --start/--dur)"
        pal = palette(a.rich); pl = lab(pal)
        B = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16 - .5
        ims = []
        for f in files:
            im = Image.open(f).convert("RGB")
            for _ in range(a.smooth): im = im.filter(ImageFilter.MedianFilter(3))
            ims.append(im)
        masks = [subject_mask(im) if a.subject else None for im in ims]
        if a.subject and masks[0] is None: print("note: rembg/scipy missing -> no subject stitching (run --setup)", file=sys.stderr)
        elif a.subject and len(masks) > 2:  # 3-frame majority: kills edge jitter
            masks = [(masks[max(k - 1, 0)].astype(int) + masks[k] + masks[min(k + 1, len(masks) - 1)]) >= 2 for k in range(len(masks))]
        if a.rich and a.colours:  # per-clip palette: the N game-palette colours this footage actually lands on
            use = np.zeros(len(pal))
            for im in ims:
                x = prep(im, a.sat)
                use += np.bincount(((lab(x)[:, :, None, :] - pl[None, None]) ** 2).sum(3).argmin(2).ravel(), minlength=len(pal))
            keep = np.argsort(-use)[:a.colours]; pal, pl = pal[keep], pl[keep]
        for f, im, sm in zip(files, ims, masks):
            x = prep(im, a.sat)
            h, w, _ = x.shape; d = np.tile(B, (h // 4 + 1, w // 4 + 1))[:h, :w, None] * a.dither
            i = ((lab(np.clip(x + d, 0, 255))[:, :, None, :] - pl[None, None]) ** 2).sum(3).argmin(2)
            for _ in range(a.despeckle):  # 3x3 majority vote -> flat felt patches, no salt-and-pepper
                n = len(pal); cnt = np.zeros((h, w, n), np.int16); P = np.pad(i, 1, mode="edge")
                for dy in range(3):
                    for dx in range(3): np.add.at(cnt, (np.arange(h)[:, None], np.arange(w)[None, :], P[dy:dy + h, dx:dx + w]), 1)
                i = cnt.argmax(2)
            o = pal[i].astype(np.uint8)
            if a.outline:  # 1px umber line on region borders, drawn inside the darker patch (toy seam)
                L = lab(o.astype(float))[..., 0]; e = np.zeros(L.shape, bool)
                dv = (i[:-1] != i[1:]) & (np.abs(L[:-1] - L[1:]) > 14); e[:-1] |= dv & (L[:-1] <= L[1:]); e[1:] |= dv & (L[1:] < L[:-1])
                dh = (i[:, :-1] != i[:, 1:]) & (np.abs(L[:, :-1] - L[:, 1:]) > 14); e[:, :-1] |= dh & (L[:, :-1] <= L[:, 1:]); e[:, 1:] |= dh & (L[:, 1:] < L[:, :-1])
                if a.stitch and sm is None:  # dashed stitch 1px inside the lit side of each seam: 2 on / 2 off
                    nb = np.zeros_like(e); nb[1:] |= e[:-1]; nb[:-1] |= e[1:]; nb[:, 1:] |= e[:, :-1]; nb[:, :-1] |= e[:, 1:]
                    yy, xx = np.mgrid[:h, :w]; st = nb & ~e & (((xx + yy) // 2) % 2 == 0)
                    o[st] = (o[st] * .45 + np.array([0xf2, 0xe4, 0xc0]) * .55).astype(np.uint8)
                o[e] = UMBER
            if sm is not None:
                from scipy import ndimage as nd
                inn1, inn2 = nd.binary_erosion(sm), nd.binary_erosion(sm, iterations=3)
                ring_out = nd.binary_dilation(sm) & ~sm            # 1px umber outline, outside the fur
                yy, xx = np.mgrid[:h, :w]
                st = inn1 & ~inn2 & (((xx + yy) % 6) < 4)   # bright 2px dashed stitch just inside the edge (4 on / 2 off)
                o[st] = (o[st] * .2 + np.array([0xff, 0xf3, 0xc8]) * .8).astype(np.uint8)
                o[ring_out] = UMBER
            Image.fromarray(o).save(os.path.join(px, os.path.basename(f)))
        lua = os.path.join(t, "mk.lua"); open(lua, "w").write(LUA)
        env = dict(os.environ, GV_S=px, GV_OUT=os.path.join(a.out, name), GV_N=str(len(files)), GV_W=str(w), GV_H=str(h), GV_MS=str(round(1000 / a.fps)))
        subprocess.run([ase, "-b", "--script", lua], env=env, check=True, stdout=subprocess.DEVNULL)
    g = os.path.join(a.out, name + ".gif"); print(f"{g}  {len(files)} frames  {os.path.getsize(g)//1024} KB")

if __name__ == "__main__": main()
