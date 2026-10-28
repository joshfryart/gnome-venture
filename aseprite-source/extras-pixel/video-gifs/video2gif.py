#!/usr/bin/env python3
"""video -> Stitched Toy pixel GIF via Aseprite.
usage: python3 video2gif.py VIDEO [--name N] [--start S] [--dur D] [--fps F] [--grid W] [--out DIR]
         [--outline | --no-outline] [--smooth N] [--ase PATH]
Pipeline: ffmpeg (trim, fps, area-downscale to W-wide grid) -> game palette (Lab nearest + 4x4 ordered
dither, same every frame) -> flat-felt smoothing + umber edge line -> Aseprite headless builds the
layered .aseprite and the 2x nearest GIF. Outputs: DIR/NAME.gif and DIR/NAME.aseprite (DIR default: this folder).
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

def palette():
    F = {k: [rgb(h) for h in v.split()] for k, v in FAM.items()}
    P = [c for v in F.values() for c in v]
    for v in F.values():
        P += [(a + b) / 2 for a, b in zip(v, v[1:])]
    for a, b in [("soil", "gold"), ("soil", "stone"), ("moss", "soil"), ("water", "stone"), ("gold", "moss"), ("soil", "ember")]:
        P += [(x + y) / 2 for x in F[a] for y in F[b]]
    return np.unique(np.array(P).round(), axis=0)

def lab(c):
    c = c / 255; c = np.where(c > .04045, ((c + .055) / 1.055) ** 2.4, c / 12.92)
    M = np.array([[.4124, .3576, .1805], [.2126, .7152, .0722], [.0193, .1192, .9505]])
    x = c @ M.T / np.array([.9505, 1, 1.089]); f = np.where(x > .008856, np.cbrt(x), 7.787 * x + 16 / 116)
    return np.stack([116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])], -1)

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
    ap.add_argument("video"); ap.add_argument("--name"); ap.add_argument("--start", type=float, default=0)
    ap.add_argument("--dur", type=float, default=2.4); ap.add_argument("--fps", type=float, default=10)
    ap.add_argument("--grid", type=int, default=240, help="grid width; GIF is 2x"); ap.add_argument("--out", default=HERE)
    ap.add_argument("--outline", action=argparse.BooleanOptionalAction, default=True)
    ap.add_argument("--smooth", type=int, default=1, help="median passes for flat felt look (0=off)")
    ap.add_argument("--ase"); a = ap.parse_args()
    name = a.name or os.path.splitext(os.path.basename(a.video))[0]
    os.makedirs(a.out, exist_ok=True); ase = find_ase(a.ase)
    with tempfile.TemporaryDirectory() as t:
        raw, px = os.path.join(t, "raw"), os.path.join(t, "px"); os.makedirs(raw); os.makedirs(px)
        subprocess.run(["ffmpeg", "-v", "error", "-ss", str(a.start), "-t", str(a.dur), "-i", a.video, "-vf",
                        f"fps={a.fps},scale={a.grid}:-2:flags=area", os.path.join(raw, "f%03d.png")], check=True)
        files = sorted(glob.glob(raw + "/*.png")); assert files, "no frames (check --start/--dur)"
        pal = palette(); pl = lab(pal)
        B = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16 - .5
        for f in files:
            im = Image.open(f).convert("RGB")
            for _ in range(a.smooth): im = im.filter(ImageFilter.MedianFilter(3))
            x = 255 * (np.asarray(im, float) / 255) ** 0.8
            h, w, _ = x.shape; d = np.tile(B, (h // 4 + 1, w // 4 + 1))[:h, :w, None] * 14
            i = ((lab(np.clip(x + d, 0, 255))[:, :, None, :] - pl[None, None]) ** 2).sum(3).argmin(2)
            o = pal[i].astype(np.uint8)
            if a.outline:  # umber line where neighbouring cells jump a lot in luma (flat 1px toy edge)
                L = lab(o.astype(float))[..., 0]; e = np.zeros(L.shape, bool)
                e[:-1] |= np.abs(L[:-1] - L[1:]) > 38; e[:, :-1] |= np.abs(L[:, :-1] - L[:, 1:]) > 38
                o[e] = UMBER
            Image.fromarray(o).save(os.path.join(px, os.path.basename(f)))
        lua = os.path.join(t, "mk.lua"); open(lua, "w").write(LUA)
        env = dict(os.environ, GV_S=px, GV_OUT=os.path.join(a.out, name), GV_N=str(len(files)), GV_W=str(w), GV_H=str(h), GV_MS=str(round(1000 / a.fps)))
        subprocess.run([ase, "-b", "--script", lua], env=env, check=True, stdout=subprocess.DEVNULL)
    g = os.path.join(a.out, name + ".gif"); print(f"{g}  {len(files)} frames  {os.path.getsize(g)//1024} KB")

if __name__ == "__main__": main()
