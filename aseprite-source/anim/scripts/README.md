# anim scripts

- `scenes.lua`, `icons.lua`, `animlib.lua`: hand-made pilot strips (Aseprite batch: `Aseprite.exe -b --script scenes.lua`).
- `bulk.py`: generic generator for every other `act-<slug>.png` (skips slugs that have a pilot `.aseprite` in this folder's parent).
  Run: `python aseprite-source/anim/scripts/bulk.py [--only slug,slug] [--report]` (needs Pillow + numpy; about a minute for all).
  Rules: gnome breath, cloud drift, flame tip flicker, rain/snow fall, drifting glints, twinkling plus-sparkles, steam rise, accent glint fallback.
  Anything that is not on a uniform background stays still (tear guard).
- `bulk_verify.py [--sheets DIR] [--stats]`: checks widths are multiples of 144, frame 1 == static, frame border untouched, no off-palette colours.
- `bulk_zoom.py OUT.png slug...`: 2x crops of the changed area (frames 1/3/4) for eyeballing.
