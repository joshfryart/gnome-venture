# v3 lib: Hearth Pop (hp.lua)
Run: `/tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script x.lua`
```lua
local HP = dofile("<path>/v3/lib/hp.lua")   -- resolves palette.lua next to itself
local c = HP.canvas{w=64,h=64,scale=4,name="acorn"}
```
Coordinates: 0-based pixels, inclusive rect corners. Hard pixels only (no blending).

## Files
`palette.lua` (P.ink, P.cream, P.<ramp>.{hi,base,shade,deep}), `hearth-pop-50.gpl`, `hp.lua`, `contact.py`, `example.lua`, `out/`.

## Masks (return mask; make them with c: or HP.)
`c:rect(x0,y0,x1,y1)` `c:rrect(x0,y0,x1,y1,r)` `c:ellipse(cx,cy,rx,ry)` (centre may be .5; spans cx-rx..cx+rx) `c:poly{{x,y},..}` `c:line({{x,y},..}, w)`.
Mask methods: `:add(m) :cut(m) :clip(m)` (mutate, return self), `:copy() :shift(dx,dy) :grow(n) :shrink(n) :edge()` (new masks), `:has(x,y) :count() :bbox()`.
`c:fillMask(mask, hex)` flat fill.

## Painting
- `c:part(mask, ramp|"name", opts)` base, then ONE shade band lower-right (`band` default 2, 3 if mask >=600 px; auto-reduced if it would cover >45%; `noshade`), then the single pop (2x1 `hi`, upper-left interior; `pop={x=,y=,horizontal=true}`, `nopop`), then 1px `deep` line on pixels touching an earlier part of a different ramp (`inner=false` disables; `sep=true` also separates from earlier parts of the SAME ramp, e.g. a heap of berries). Ground shadow never triggers the inner line. Later parts paint over earlier ones.
- `c:px(x,y,hex)`, `c:paint(rows,x,y,map)` (map char -> "#hex" | "ramp.tone"; `.`/space = skip), `c:sparkle(x,y)` (cream plus, centre x,y)
- `c:eyeSmall(x,y)` top-left of 2x3 ink pill + cream glint upper-left; `c:eyeLocked(x,y)` top-left of 5x5 cream disc (cut corners), 3x3 ink pupil, glint on pupil upper-left
- `c:cheek(x,y)` 2x1 petal base (top-left); `c:stitch(points)` gold dashes 2 on 1 off along polyline; `c:button(x,y)` 3x3 gold centred
- `c:groundShadow(cx,cy,rx,ry)` 2-tone stone ellipse; draw FIRST. Not outlined itself, but the object's outline overwrites it where they meet.
- Scenes: `c:bands(y0,y1,rampName,n)` n<=4 flat bands, darkest on top; `c:hem(y[,x0,x1])` gold 2-on-1-off.
- Opaque scenes (finish can't outline there): `c:rim(mask, hex[, clip])` 1px ring just outside the mask (ink edge for near-plane objects, `<ramp>.deep` edge for the hero; paint the rim first, then the object); `c:edgeIn(mask, hex)` same on the mask's own border.
- `c:stripes(y0,y1,{hex,..}[,{w,..}])` flat full-width bands from any ramps (sunrise skies), optional weights. `c:terrain(f, hex[, ybot, x0, x1])` fills each column from `f(x)` down (hills, ridges); returns the mask. `c:cloud(x, y, w[, top, under])` 3-bump flat-bottom puff, (x,y) = bottom-left, top of the cloud is about `y - 0.6w`.
- `HP.cells(c, cols, rows)` prints/returns distinct colours per grid cell (jigsaw check, regions use 6x4).
- `c:finish{outline=true}` one 1px ink outline on every transparent (or shadow) pixel 4-adjacent to a painted object pixel, inside the canvas only. `outline=false` skips (scenes). Call once, last.

## Output
- `c:save{aseprite=path, png=path, scale=n}`: .aseprite always native size; PNG nearest-neighbour scaled (default `scale` from HP.canvas; fractional allowed, e.g. `scale=1.5` for region thumbs). Folders are created.
- `HP.sheet{cellw=,cellh=,frames={c1,c2..},tags={{name="idle",from=1,to=2}}}:save{aseprite=,png=,scale=}` horizontal strip PNG + multi-frame .aseprite with tags.
- `HP.report(c|Image)` prints and returns {w,h,bbox,margin,distinct,offPalette,semi,blackWhite,isolated}; `HP.assertClean(c)` errors on semi-transparent / pure black or white; off-palette colours are only reported (relaxed 2026-11-03).

## Layer split / recolour rigs (2026-11-03, no hp.lua change)
`v3/models/rig/gnome-rig.lua` shows the pattern. It loads an unchanged model script with `load(src, "@"..path, "t", env)`. A patched `dofile` wraps `HP.canvas` so that `c.put` records a per-pixel layer: the innermost `frame()` line is found with `debug.getinfo` and mapped to a section through anchor strings. `HP.sheet` is stubbed so that it captures the frames without saving. Each pixel goes to the layer that painted it last (disjoint layers, exact restack). Tint layers are written in marker greys `#f0f0f0/#b4b4b4/#787878/#3c3c3c` (hi/base/shade/deep) and recoloured by palette mapping (`rig/recolor.py`, `rig/recolor.js`).

## contact.py
`python3 contact.py out.html a.png b.png ...`; `python3 contact.py --compare out.html orig.png new.png [o2 n2 ...]`; `--compare --p1 out.html orig p1 final [...]` for triples. Standalone HTML, pixelated, 100% / x2-x4 / 50% on grey and dark.
