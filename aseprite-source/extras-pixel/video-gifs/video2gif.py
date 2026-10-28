#!/usr/bin/env python3
"""video -> Stitched Toy pixel GIF via Aseprite (the one house flow).

usage: python3 video2gif.py VIDEO [--name N] [--start S] [--dur D] [--fps F] [--grid W] [--out DIR]
       python3 video2gif.py --setup        # one-time: pip deps + silueta model (checked by sha256)

Pipeline
  1. ffmpeg decodes the clip (1280 px wide). --loop auto looks for the start whose last frame matches its first
     (seamless loop); --loop pingpong plays forward then back; --loop none keeps --start as given.
  2. rembg (silueta) cuts the subject out of 768 px frames (all components >= 25% of the biggest are kept).
     If the subject is small the clip is auto-cropped (static crop) so it fills about 40% of the height.
  3. Background: TV-flattened in Lab, pushed back (lighter, softer), per-clip k-means palette snapped to Part A colours,
     temporal hysteresis (no shimmer), majority-filtered. No seams, no lines.
  4. Subject: drawn like a gvlib part. Two Lab clusters -> nearest preset ramp (judged on the lit half), flat tones,
     crescent shade + deep at the lower right, 1 px rim upper left, 1 px bounce lower right, gloss comma,
     1 px gold edge stitch 2 px inside on the lit half, 3-tone selective outline (2 px + 1 px lower right).
  5. Aseprite (headless) builds NAME.aseprite and the 2x nearest GIF; gifsicle -O3 runs if it is installed.
Every output pixel is a solid palette colour. Defaults = the approved look (grid 200, 10 fps, 2.4 s).
Flags: --no-subject (whole frame treated as background), --flat N (TV weight), --bg-colours N, --seg-model NAME,
--no-crop, --loop {auto,pingpong,none}, --loop-window S.
Aseprite: $ASEPRITE, --ase, else extracts ../../Aseprite_*.AppImage once into $GV_CACHE (default ~/.cache/gv-aseprite)."""
import argparse, colorsys, glob, hashlib, os, shutil, subprocess, sys, tempfile
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
MODELS = {"silueta": ("https://github.com/danielgatis/rembg/releases/download/v0.0.0/silueta.onnx",
                      "75da6c8d2f8096ec743d071951be73b4a8bc7b3e51d9a6625d63644f90ffeedb")}
SEG_W = 768   # width the segmenter sees

# ---------------------------------------------------------------- palette + gvlib ramps
FAM = {"soil": "3d2a1c 7a4a1f 9a6b3f c9a96e f1ece0", "moss": "2f5a2a 4f9a45 7ab55c a4b86a", "gold": "b07a10 e8a317 f5cf6a",
       "ember": "a8241f d6322b e0501f f08a24", "petal": "e46a9b f6b8cf", "water": "25637d 3f8fb0 a9d6ea",
       "dusk": "4e3a8a 7a5cc0 c3b2ea", "stone": "5b6470 8b8f96 c9c5bc", "extra": "f2e4c0 fff3c8 f5b860"}
H2 = lambda h: np.array([int(h[i:i + 2], 16) for i in (1, 3, 5)], float)

def _hsl(hx):
    r, g, b = H2(hx) / 255; h, l, s = colorsys.rgb_to_hls(r, g, b); return h * 360, s, l
def _hex(h, s, l):
    r, g, b = colorsys.hls_to_rgb((h % 360) / 360, min(1, max(0, l)), min(1, max(0, s)))
    return "#%02x%02x%02x" % tuple(round(v * 255) for v in (r, g, b))
def _toward(h, t, a):
    d = ((t - h + 540) % 360) - 180; return t if abs(d) <= a else h + (a if d > 0 else -a)
def ramp(base, **ov):
    """port of GV.ramp: gloss toward yellow-orange +35%, shade toward red-violet -24%, deep -48%, bounce, rim."""
    h, s, l = _hsl(base); r = {"base": base}
    gh, gl = _toward(h, 45, 20), l + (1 - l) * .35
    r["gloss"] = _hex(gh, s * 1.1, gl); r["rim"] = _hex(gh, s, gl * .9)
    sh = _toward(h, 285, 10)
    r["shade"] = _hex(sh, s, l * .76); r["deep"] = _hex(_toward(h, 285, 25), s, l * .52); r["bounce"] = _hex(_toward(sh, 30, 12), s, l * .76 * 1.08)
    r.update(ov); return r
PRESETS = {  # gvlib presets (brief.md palette table); Part A bases run through ramp()
    "red": ramp("#dd3a2a", gloss="#ff9158", rim="#f2793a", bounce="#b8452f", shade="#ae2a2a", deep="#6b1b2c"),
    "moss": ramp("#7ab55c", gloss="#c8d77a", rim="#a4b86a", bounce="#6a9a3a", shade="#4a8a3e", deep="#2f5a2a"),
    "wood": ramp("#b07a45", gloss="#ecc58a", rim="#d9a660", bounce="#a8582f", shade="#8a4f2a", deep="#5e2f1e"),
    "soil": ramp("#9a6b3f", gloss="#e8a060", rim="#c98a4a", bounce="#b0623a", shade="#7a4a1f", deep="#4e2a16"),
    "gold": ramp("#e8a317", gloss="#fff1c8", rim="#f5cf6a", bounce="#d0862a", shade="#b8661a", deep="#7a3a14"),
    "skin": ramp("#e9b98a", gloss="#ffe2a8", rim="#f9d49c", bounce="#d9885a", shade="#c47a52", deep="#8a4234"),
    "water": ramp("#3f8fb0", gloss="#c8ecdc", rim="#8fcbd8", bounce="#5a86b8", shade="#2f6290", deep="#2a3c6c"),
    "flame": ramp("#e0501f", gloss="#ff9158", rim="#f08a24", bounce="#b8452f", shade="#ae2a2a", deep="#6b1b2c"),
    "dusk": ramp("#7b66b4", gloss="#a894dc", rim="#7b66b4", shade="#3e2f66", deep="#291d4a", bounce="#54447f"),
    "petal": ramp("#e46a9b"), "stone": ramp("#8b8f96"),
    "cream": ramp("#f1ece0", gloss="#fff3c8", rim="#f5b860", shade="#d8c49a", bounce="#e6d4ac", deep="#9a6b3f")}
OL1, OL2, OL3, GOLD, GOLDS = H2("#74462a"), H2("#4a2c1a"), H2("#2a1a10"), H2("#f5cf6a"), H2("#e8a317")

def _need():
    try:
        from scipy import ndimage as nd
        from skimage.color import rgb2lab
        from skimage.restoration import denoise_tv_chambolle
        from scipy.cluster.vq import kmeans2
    except ImportError: sys.exit("missing deps: run  python3 video2gif.py --setup")
    return nd, rgb2lab, denoise_tv_chambolle, kmeans2

def game_palette(rgb2lab):
    P = []
    for v in FAM.values():
        c = [H2("#" + h) for h in v.split()]; P += c + [(a + b) / 2 for a, b in zip(c, c[1:])]
    base = [H2("#" + h) for v in FAM.values() for h in v.split()]
    P += [(x + y) / 2 for i, x in enumerate(base) for y in base[i + 1:]]   # 50% blends: the k-means centres snap to these, so only ~16 survive
    pal = np.unique(np.array(P).round(), axis=0)
    return pal, rgb2lab(pal[None] / 255)[0]

# ---------------------------------------------------------------- setup / tools
def setup():
    """pip deps + the silueta segmentation model (verified by sha256). Needs pip + github.com."""
    subprocess.run([sys.executable, "-m", "pip", "install", "-q", "numpy", "pillow", "scipy", "scikit-image", "rembg", "onnxruntime"], check=True)
    d = os.path.expanduser("~/.u2net"); os.makedirs(d, exist_ok=True)
    for n, (url, sha) in MODELS.items():
        p = os.path.join(d, n + ".onnx")
        if not os.path.exists(p) or hashlib.sha256(open(p, "rb").read()).hexdigest() != sha:
            subprocess.run(["curl", "-fsSL", "-o", p, url], check=True)
        assert hashlib.sha256(open(p, "rb").read()).hexdigest() == sha, f"{n}.onnx checksum mismatch"
    print("setup ok")

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

LUA = '''local S, OUT, N, W, H, CS = os.getenv("GV_S"), os.getenv("GV_OUT"), tonumber(os.getenv("GV_N")), tonumber(os.getenv("GV_W")), tonumber(os.getenv("GV_H")), tonumber(os.getenv("GV_CS"))
local spr = Sprite(W, H, ColorMode.RGB)
app.transaction(function()
  for i = 1, N do
    local fr = (i == 1) and spr.frames[1] or spr:newEmptyFrame()
    fr.duration = CS / 100
    spr:newCel(spr.layers[1], fr, Image{ fromFile = string.format("%s/f%03d.png", S, i) }, Point(0, 0))
  end
end)
spr:saveAs(OUT .. ".aseprite")
app.command.SaveFileCopyAs{ ui = false, filename = OUT .. ".gif", resizeScale = 2, scale = 2 }
'''

# ---------------------------------------------------------------- loop search
def find_loop_start(video, start, dur, fps, window, tmp):
    """start offset (s) within [start, start+window] whose frame at +dur best matches the frame at start."""
    d = os.path.join(tmp, "scan"); os.makedirs(d)
    subprocess.run(["ffmpeg", "-v", "error", "-ss", str(start), "-t", str(window + dur + 1 / fps), "-i", video, "-vf",
                    f"fps={fps},scale=96:-2:flags=area", os.path.join(d, "s%04d.png")], check=True)
    fr = [np.asarray(Image.open(f).convert("L"), float) for f in sorted(glob.glob(d + "/*.png"))]
    L = int(round(dur * fps)); best, bs = 0, 1e9
    for s in range(0, max(1, len(fr) - L)):
        e = np.abs(fr[s] - fr[s + L]).mean()
        if e < bs: best, bs = s, e
    print(f"loop: start {start + best / fps:.2f}s  end-to-start diff {bs:.1f} (at given start {np.abs(fr[0] - fr[min(L, len(fr) - 1)]).mean():.1f})")
    return start + best / fps

# ---------------------------------------------------------------- segmentation
_SESS = {}
def seg_masks(frames, model, nd):
    """per-frame subject masks at SEG_W px (bool). None if rembg is missing."""
    try: from rembg import new_session, remove
    except ImportError: return None
    if model not in _SESS: _SESS[model] = new_session(model)
    out = []
    for im in frames:
        s = im.resize((SEG_W, round(im.height * SEG_W / im.width)), Image.LANCZOS)
        m = np.asarray(remove(s, session=_SESS[model], only_mask=True)) > 127
        lab, n = nd.label(m)
        if n:
            sz = np.array(nd.sum(m, lab, range(1, n + 1))); keep = 1 + np.nonzero(sz >= 0.25 * sz.max())[0]
            m = np.isin(lab, keep)
        out.append(nd.binary_fill_holes(nd.binary_closing(m, iterations=2)))
    return out

def plan_crop(masks, sw, sh, aspect, a):
    """static crop box (in source px) so the subject fills ~40% of the height; None = keep the whole frame."""
    union = np.zeros_like(masks[0])
    for m in masks: union |= m
    ys, xs = np.nonzero(union)
    if len(ys) < 30: return None
    k = sw / union.shape[1]
    x0, x1, y0, y1 = xs.min() * k, (xs.max() + 1) * k, ys.min() * k, (ys.max() + 1) * k
    ch = max(sh / 3, (y1 - y0) / 0.40); cw = ch * aspect
    if cw < (x1 - x0) * 1.25: cw = (x1 - x0) * 1.25; ch = cw / aspect
    if ch >= 0.8 * sh or cw >= 0.8 * sw: return None
    cx = min(max((x0 + x1) / 2, cw / 2), sw - cw / 2); cy = min(max((y0 + y1) / 2, ch / 2), sh - ch / 2)
    return (cx - cw / 2, cy - ch / 2, cx + cw / 2, cy + ch / 2)

# ---------------------------------------------------------------- rendering
def render(grid, masks, a, nd, rgb2lab, tv, kmeans2):
    """grid: list of HxWx3 float RGB; masks: list of HxW bool (or all-False). -> list of uint8 frames."""
    N = len(grid); h, w, _ = grid[0].shape; has_sub = any(m.sum() >= 20 for m in masks)
    PAL, PAL_L = game_palette(rgb2lab)
    labs = [tv(rgb2lab(g / 255), weight=a.flat, channel_axis=-1) for g in grid]
    push = has_sub
    def bgpush(l):
        l = l.copy()
        if push: l[..., 0] = 30 + .70 * l[..., 0]; l[..., 1:] *= 1.2
        return l
    blabs = [bgpush(l) for l in labs]
    px = np.concatenate([l[~m] if (~m).sum() else l.reshape(-1, 3) for l, m in zip(blabs, masks)])[::5]
    cent, _ = kmeans2(px, a.bg_colours if push else a.bg_colours + 8, seed=1, minit="++")
    idx = np.unique(((cent[:, None] - PAL_L[None]) ** 2).sum(2).argmin(1))
    BG, BG_L = PAL[idx], PAL_L[idx]
    print("bg palette:", len(BG), "colours")

    def mode(i, n, it=2):
        for _ in range(it):
            i = np.stack([nd.uniform_filter((i == k).astype(np.float32), 3) for k in range(n)], -1).argmax(-1)
        return i
    prev, bgi = None, []
    for l in blabs:   # hysteresis: keep last frame's colour unless the new one is clearly (>7.7 dE) better
        d = ((l[:, :, None] - BG_L[None, None]) ** 2).sum(-1); i = d.argmin(-1)
        if prev is not None:
            dp = np.take_along_axis(d, prev[..., None], -1)[..., 0]; bst = np.take_along_axis(d, i[..., None], -1)[..., 0]
            i = np.where(dp < bst + 60, prev, i)
        i = mode(i, len(BG)); prev = i; bgi.append(i)
    if not has_sub: return [BG[i].astype(np.uint8) for i in bgi]

    # subject ramps: two Lab clusters; preset chosen from the lit half (chroma-boosted), not the median
    subL = np.concatenate([l[m] for l, m in zip(labs, masks) if m.any()])
    sc, _ = kmeans2(subL[::3], 2, seed=2, minit="++")
    asg = ((subL[:, None] - sc[None]) ** 2).sum(2).argmin(1)
    PB = {k: rgb2lab(H2(v["base"])[None, None] / 255)[0, 0] for k, v in PRESETS.items()}
    names = []
    for j in range(2):
        pj = subL[asg == j]
        if len(pj) == 0: pj = subL
        lit = pj[pj[:, 0] >= np.median(pj[:, 0])].mean(0)
        names.append(min(PB, key=lambda k: ((PB[k][1:] - lit[1:] * 1.3) ** 2).sum() * 2 + (PB[k][0] - (lit[0] + 6)) ** 2))
    RPS = [{k: H2(v) for k, v in PRESETS[n].items()} for n in names]; print("subject ramps:", names)
    QS = np.array([[np.quantile(subL[asg == j, 0], q) if (asg == j).any() else 0 for q in (.12, .38)] for j in range(2)])  # deep / shade cut per cluster
    YY, XX = np.mgrid[:h, :w]
    TT = np.array([[r["base"], r["shade"], r["deep"]] for r in RPS]); RIM = np.array([r["rim"] for r in RPS])
    BNC = np.array([r["bounce"] for r in RPS]); GLS = np.array([r["gloss"] for r in RPS])

    frames = []
    for k in range(N):
        m, l = masks[k], labs[k]; o = BG[bgi[k]].copy()
        if m.sum() < 20: frames.append(o.astype(np.uint8)); continue
        lab_, n = nd.label(m)
        cms = np.array(nd.center_of_mass(m, lab_, range(1, n + 1))).reshape(-1, 2)
        near = lab_[tuple(nd.distance_transform_edt(lab_ == 0, return_indices=True)[1])]   # nearest component of every pixel
        CY, CX = cms[near - 1, 0], cms[near - 1, 1]
        sizes = np.array([max(np.ptp(np.nonzero(lab_ == q)[1]), np.ptp(np.nonzero(lab_ == q)[0])) + 1 for q in range(1, n + 1)])
        size = sizes.max(); kk = size / 64; cres = max(2, round(4 * kk)); deep = max(1, round(1.5 * kk))
        big = size >= 24                                   # tiny subjects: thin outline, no stitch / gloss
        cl = ((l[:, :, None] - sc[None, None]) ** 2).sum(-1).argmin(-1); cl[~m] = 0; cl = mode(cl, 2, 1)
        L0 = l[..., 0]; t = (L0 < QS[cl][..., 1]).astype(int) + (L0 < QS[cl][..., 0]); t[~m] = 0; t = mode(t, 3, 1); t[~m] = 0   # photo shading -> base/shade/deep
        sh = lambda dy, dx: np.roll(np.roll(m, -dy, 0), -dx, 1)
        t = np.maximum(t, (m & ~sh(cres, cres)) * 1); t = np.maximum(t, (m & ~sh(deep + cres, deep + cres)) * 2)   # crescent, lower right
        tone = TT[cl, t]
        lit = m & (~sh(-1, 0) | ~sh(0, -1)) & (t == 0)                                    # 1 px rim, upper left
        s = (XX - CX) + (YY - CY)
        bounce = m & ~sh(1, 1) & (s > 0)                                                  # 1 px bounce, lower right
        tone[lit] = RIM[cl][lit]; tone[bounce] = BNC[cl][bounce]
        o[m] = tone[m]
        g = np.zeros_like(m)
        if big:
            ring3 = nd.binary_erosion(m, iterations=2) & ~nd.binary_erosion(m, iterations=3) & (t == 0)
            if ring3.any():                                                               # gloss comma at the upper-left of each part
                yy, xx = np.nonzero(ring3); b = np.argmin(xx + yy + yy * .01); L = max(2, round(size / 14))
                g = ring3 & ((YY - yy[b]) ** 2 + (XX - xx[b]) ** 2 <= L * L); o[g] = GLS[cl][g]
            ring2 = nd.binary_erosion(m, iterations=1) & ~nd.binary_erosion(m, iterations=2)       # 1 px gold edge stitch, 2 px in
            st = ring2 & ((XX + YY) % 3 == 0) & (s <= 0) & ~g
            o[st] = np.where((t[st] > 0)[:, None], GOLDS, GOLD)
        ow = 2 if big else 1                                                              # selective 3-tone outline
        ring = (nd.binary_dilation(m, iterations=ow) | (nd.binary_dilation(m, iterations=ow + 1) & (s > 12 * kk))) & ~m
        tn = np.where(s < -28 * kk, 0, np.where(s < -2 * kk, 1, 2))
        o[ring] = np.array([OL1, OL2, OL3])[tn[ring]]
        frames.append(o.astype(np.uint8))
    return frames

# ---------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("video", nargs="?"); ap.add_argument("--setup", action="store_true")
    ap.add_argument("--name"); ap.add_argument("--start", type=float, default=0); ap.add_argument("--dur", type=float, default=2.4)
    ap.add_argument("--fps", type=float, default=10); ap.add_argument("--grid", type=int, default=200, help="grid width; GIF is 2x")
    ap.add_argument("--out", default=HERE)
    ap.add_argument("--subject", action=argparse.BooleanOptionalAction, default=True)
    ap.add_argument("--crop", action=argparse.BooleanOptionalAction, default=True, help="auto-crop to a small subject")
    ap.add_argument("--loop", choices=["auto", "pingpong", "none"], default="auto")
    ap.add_argument("--loop-window", type=float, default=4.0, help="seconds after --start to search for a loop point")
    ap.add_argument("--seg-model", default="silueta"); ap.add_argument("--flat", type=float, default=6, help="TV flatten weight")
    ap.add_argument("--bg-colours", type=int, default=16); ap.add_argument("--ase"); a = ap.parse_args()
    if a.setup: return setup()
    if not a.video: ap.error("give a VIDEO (or --setup)")
    nd, rgb2lab, tv, kmeans2 = _need()
    name = a.name or os.path.splitext(os.path.basename(a.video))[0]
    cs = max(2, round(100 / a.fps)); fps = 100 / cs        # GIF delays are whole centiseconds: no timing drift
    os.makedirs(a.out, exist_ok=True); ase = find_ase(a.ase)
    with tempfile.TemporaryDirectory() as t:
        start = find_loop_start(a.video, a.start, a.dur, fps, a.loop_window, t) if a.loop == "auto" else a.start
        src = os.path.join(t, "src"); px = os.path.join(t, "px"); os.makedirs(src); os.makedirs(px)
        subprocess.run(["ffmpeg", "-v", "error", "-ss", f"{start:.3f}", "-t", str(a.dur), "-i", a.video, "-vf",
                        f"fps={fps},scale=1280:-2:flags=area", os.path.join(src, "f%03d.png")], check=True)
        big = [Image.open(f).convert("RGB") for f in sorted(glob.glob(src + "/*.png"))]; assert big, "no frames (check --start/--dur)"
        sw, sh = big[0].size
        masks = seg_masks(big, a.seg_model, nd) if a.subject else None
        if a.subject and masks is None: print("note: rembg missing -> no subject treatment (run --setup)", file=sys.stderr)
        elif masks is not None and not any(m.any() for m in masks): print("note: no subject found", file=sys.stderr)
        box = plan_crop(masks, sw, sh, sw / sh, a) if (masks and a.crop) else None
        if box: print("crop: %.0f,%.0f %.0fx%.0f of %dx%d" % (box[0], box[1], box[2] - box[0], box[3] - box[1], sw, sh))
        gw = a.grid; gh = round(gw * ((box[3] - box[1]) / (box[2] - box[0]) if box else sh / sw))
        grid, gm = [], []
        for i, im in enumerate(big):
            c = im.crop(tuple(round(v) for v in box)) if box else im
            grid.append(np.asarray(c.resize((gw, gh), Image.BOX), float))
            if masks is not None:
                mm = Image.fromarray((masks[i] * 255).astype(np.uint8)).resize((sw, sh), Image.BILINEAR)
                if box: mm = mm.crop(tuple(round(v) for v in box))
                gm.append(np.asarray(mm.resize((gw, gh), Image.BOX)) > 127)
            else: gm.append(np.zeros((gh, gw), bool))
        if a.subject and masks is not None and len(gm) > 2:   # 3-frame majority: no edge jitter
            gm = [(gm[max(k - 1, 0)].astype(int) + gm[k] + gm[min(k + 1, len(gm) - 1)]) >= 2 for k in range(len(gm))]
        frames = render(grid, gm, a, nd, rgb2lab, tv, kmeans2)
        if a.loop == "pingpong": frames = frames + frames[-2:0:-1]
        for i, f in enumerate(frames, 1): Image.fromarray(f).save(os.path.join(px, "f%03d.png" % i))
        lua = os.path.join(t, "mk.lua"); open(lua, "w").write(LUA)
        env = dict(os.environ, GV_S=px, GV_OUT=os.path.join(a.out, name), GV_N=str(len(frames)), GV_W=str(gw), GV_H=str(gh), GV_CS=str(cs))
        subprocess.run([ase, "-b", "--script", lua], env=env, check=True, stdout=subprocess.DEVNULL)
    g = os.path.join(a.out, name + ".gif")
    if shutil.which("gifsicle"): subprocess.run(["gifsicle", "-O3", "--no-warnings", "-b", g], check=True)
    cols = len({tuple(c) for f in frames for c in f.reshape(-1, 3)})
    print(f"{g}  {len(frames)} frames  {cols} colours  {os.path.getsize(g) // 1024} KB")

if __name__ == "__main__": main()
