# video -> Stitched Toy GIF (one flow)

Give Claude a video ("make this a GIF"). It runs `video2gif.py` and sends back the GIF + a layered `.aseprite`.

```bash
python3 -I aseprite-source/extras-pixel/video-gifs/video2gif.py VIDEO --name NAME --start S --dur D
```
Defaults are the approved look: 200-wide grid (GIF is 2x nearest = 400 wide), 10 fps, 2.4 s, flat cel, no dither. Palette: Part A + all 50% blends, pruned to the 72 most-used colours per clip (`--colours N`), saturation x1.3 (`--sat`).

## What it does
1. ffmpeg trims, resamples fps, area-downscales to the grid.
2. Median smooth (flat felt) -> Lab-nearest to the Part A palette + blends (`--no-rich` = base palette only) -> 3x3 majority despeckle.
3. 1 px umber seams on colour-region borders.
4. Subject cut-out (rembg u2netp, 3-frame majority so the edge doesn't jitter): 1 px umber outline outside it + bright 2 px dashed stitch inside it. The background gets seams only.
5. Aseprite (headless, AppImage in the repo, auto-extracted to `~/.cache/gv-aseprite`) builds `NAME.aseprite` and `NAME.gif`.

## One-time setup (subject stitching)
`python3 video2gif.py --setup` installs rembg/onnxruntime/scipy and downloads `u2netp.onnx` (4 MB, github.com) to `~/.u2net/`. Without them the script still works, just without the subject stitch (it says so).

## How Claude should run it
- Look first: `ffmpeg -i V -vf "fps=2,scale=320:-1,tile=7x3" -frames:v 1 t.png`; pick a 2-3 s segment with clear motion (a loop point if possible).
- Verify: `convert NAME.gif -coalesce f_%02d.png`, montage first/mid/last, look. Check size (puzzle GIFs are small; `--grid 160` or shorter `--dur`/lower `--fps` if over ~600 KB).
- Commit/push only when asked.

## Knobs
`--grid W` chunkier/finer pixels, `--smooth N` flatter felt (0 = raw), `--despeckle N`, `--dither N` (0 = off), `--no-subject`, `--no-outline`, `--no-stitch` (bg seam stitches when there is no subject), `--fps`, `--out DIR`.

## Known limits
Not hand-drawn Stitched Toy art (no crescent shade, no hand-placed stitches). u2netp can clip thin tails/whiskers. The loop jumps at the cut unless the segment is chosen to match at both ends. Reference run: `pomeranian-stream.gif`.
