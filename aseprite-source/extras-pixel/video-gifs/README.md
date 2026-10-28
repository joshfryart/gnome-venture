# video to Stitched Toy GIF
Give Claude a video; it runs this flow.

1. Video path = user attachment (e.g. `/root/.claude/uploads/<id>/*.mp4`). Look at it first: `ffmpeg -i V -vf "fps=2,scale=320:-1,tile=7x3" -frames:v 1 t.png`, pick a ~2-3 s segment with clear motion (ideally a loop point).
2. Run (from repo root):
   `python3 -I aseprite-source/extras-pixel/video-gifs/video2gif.py VIDEO --name NAME --start S --dur D [--fps 10] [--grid 240] [--smooth 1] [--no-outline]`
   Output: `aseprite-source/extras-pixel/video-gifs/NAME.gif` (2x nearest, grid-wide x2) + layered `NAME.aseprite`. Aseprite is auto-extracted from the repo AppImage.
3. Verify: `convert NAME.gif -coalesce f_%02d.png`, montage first/mid/last frames, view. Check size (puzzle GIFs are small; shrink with `--grid 160` or fewer `--dur`/`--fps` if >~600 KB).
4. Style knobs: `--smooth 2` = flatter felt, `--smooth 0` = raw; `--grid` smaller = chunkier pixels. Palette = Part A families + midpoints (`art-style-guide.md`).
5. Report: path, frames, KB, caveats (not a hand-drawn scene; loop jump). Commit/push only if asked (branch rules in session prompt).
