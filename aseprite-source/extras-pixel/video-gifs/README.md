# video -> Stitched Toy GIF (one flow)

Give Claude a video ("make this a GIF"). It runs `video2gif.py` and sends back the GIF + a layered `.aseprite`.

```bash
python3 aseprite-source/extras-pixel/video-gifs/video2gif.py --setup     # once per machine
python3 aseprite-source/extras-pixel/video-gifs/video2gif.py VIDEO --name NAME --start S --dur D
```
Defaults: 200-wide grid (GIF is 2x nearest = 400 wide), 10 fps, 2.4 s, `--loop auto`.

## Method
1. **Clip + loop:** ffmpeg decodes 1280 px frames. `--loop auto` searches the 4 s after `--start` (`--loop-window`) for the start whose last frame best matches its first; `pingpong` plays forward then back; `none` keeps `--start`. Frame delays are whole centiseconds (no timing drift).
2. **Subject:** rembg `silueta` on 768 px frames; all components >= 25% of the biggest are kept; a small subject triggers a static auto-crop to ~40% of the frame height (`--no-crop`, `--no-subject`).
3. **Background:** TV-flattened in Lab, pushed back (lighter, softer), per-clip k-means palette (`--bg-colours`, default 16) snapped to Part A colours and their 50% blends, hysteresis against shimmer, majority filter. No seams.
4. **Subject as a gvlib part:** two Lab clusters -> nearest preset ramp (judged on the lit half); photo shading -> base/shade/deep; crescent shade + deep lower right; 1 px rim upper left; 1 px bounce lower right; gloss comma; 1 px gold edge stitch 2 px in on the lit half (every 3rd diagonal); 3-tone selective outline (`#74462a` / `#4a2c1a` / `#2a1a10`, 2 px + 1 px lower right). Subjects under 24 px get a 1 px outline and no stitch/gloss.
5. **Export:** Aseprite headless (AppImage from the repo, auto-extracted to `~/.cache/gv-aseprite`) writes `NAME.aseprite` and the 2x GIF; `gifsicle -O3` runs if installed.
Every output pixel is a solid palette colour: typically 15-35 colours per GIF.

## Setup
`--setup` pip-installs numpy/pillow/scipy/scikit-image/rembg/onnxruntime and downloads `silueta.onnx` (44 MB, github.com) to `~/.u2net/`, verifying its sha256. Needs pip and github.com. The script needs scipy + scikit-image to run at all; rembg only for the subject. Run it as plain `python3 video2gif.py` (not `-I`, which hides user-site installs).

## How Claude should run it
- Look first: `ffmpeg -i V -vf "fps=2,scale=320:-1,tile=7x3" -frames:v 1 t.png`; pick a 2-3 s segment with clear motion.
- Verify: `convert NAME.gif -coalesce f_%02d.png`, montage first/mid/last, look. Check size and the printed colours/crop/loop lines.
- Commit/push only when asked.

## Knobs
`--grid W`, `--fps`, `--dur`, `--start`, `--loop {auto,pingpong,none}`, `--loop-window S`, `--flat N` (TV weight, higher = flatter), `--bg-colours N`, `--seg-model NAME`, `--no-crop`, `--no-subject` (whole frame as background, for scenery like flowers), `--out DIR`.

## Known limits
Not hand-drawn art: no hand-placed eyes (the brief's locked 5x5 eyes need a face detector or manual placement), so animals read as plush blobs with photo shading. Small or far subjects (beach clip) stay small. Foam/sky can be picked up as "subject" when it is the most salient thing. Reference runs: `pomeranian-stream`, `flowers-sway`, `beach-ball`.
