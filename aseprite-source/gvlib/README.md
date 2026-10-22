# gvlib: Stitched Toy helper for Aseprite (1.3.x Lua)
You write shapes and colours. The library does the 3-tone outline, crescent, rim, bounce, gloss comma, inner contour and contact shadow. Rules: `brief.md`.
Run: `"C:\Program Files\Aseprite\Aseprite.exe" -b --script my.lua`. Load: `local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")`.

## Coordinates
Pixel indices on the grid, 0-based, y down. `rect`/`rrect` corners are inclusive. `ellipse(cx,cy,rx,ry)` spans cx-rx..cx+rx (use .5 centres for even widths). `poly` excludes the right and bottom edges. `line` stamps an exact w x w pen. Light comes from the upper left: `s=(x-cx)+(y-cy)` from the canvas centre.

## Worked example (23 lines, runs as-is)
```lua
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }      -- "icon" | "bust" | "scene"
local cap  = c:ellipse(31.5, 27, 20, 13):cut(c:rect(0, 32, 63, 63))
cap:add(c:rrect(12, 26, 51, 33, 3))
local p = c:build{                                             -- back to front
  { "stem", c:rrect(23, 30, 40, 50, 5), "skin" },              -- preset name, "#hex", or ramp table
  { "cap",  cap, "red", { stitch = { side = "lit" } } },       -- edge stitch on the lit half
}
c:spot(c:ellipse(24, 20, 2, 1.5)); c:spot(c:ellipse(37, 17, 2.5, 2))
c:seam({ {16, 31}, {48, 31} })                                 -- 2 on / 1 off, only on parts
c:button(29, 29)                                               -- 4x4, top-left corner
c:eye(25, 38); c:eye(34, 38)                                   -- locked 5x5 eye, top-left corner
c:paint({ "u...u", ".uuu." }, 29, 45, { u = "umber" })         -- ascii detail, "#hex" or GV.C name
c:px(30, 40, GV.R.skin.shade)                                  -- single pixel
c:ground(31.5, 52, 13, 1.5)                                    -- only if it stands on the ground
local t = c:save(D .. "out/toad.aseprite", D .. "out/toad.png")-- either path may be nil
print(GV.report(t))  -- 64x64 bbox=5,7..59,58 margin=4 semi=0 colours=22 pureBW=0 opaque=2201
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
-- p.cap.m is the cap mask (e.g. c:stitch(p.cap.m) later). Part order = paint order.
-- Draw details AFTER the parts: a later c:part repaints its whole area.
-- Outline/ground/black border are built at save(); anything you paint stays.
-- Full runnable version: example.lua.  Pilot remake: test/apple-chutney.lua (38 lines).
```

## Canvas
`GV.canvas{w,h,mode,out,bleed,halo,close,ol,olx,cres,deep,margin,cx,cy}`. `out=2` writes a half-size grid at 2x nearest (use for scenes and large art: draw ~100 px on the short side). Pens scale by `k=min(w,h)/64` with floors (outline never above 2).
| mode | default size | (halo pens, now unused) | outline | crescent | notes |
|---|---|---|---|---|---|
| sticker | 64x64 | 5 / 6, nubs cleaned, 3 px from frame | 2 +1 lower-right | 4 | default |
| icon | 64x64 | 6 / 6 | 2 +1 | 5 | `ico-*`: chunky shapes (min 3 px parts), gloss 1 px longer |
| bust | 80x100 | 3 / 4, 2 px from frame | 1 +1 lower-right | 5 | `npc-*`, bleeds off bottom; `c:eye(x,y,true)` if head < 20 px |
| scene | any | none | 2 +1 per part, drawn as each part is added | 4k | bleeds all edges; `c:bands` for skies |

## Masks (shapes return a mask; chainable)
`c:rect(x0,y0,x1,y1)` `c:rrect(x0,y0,x1,y1,r)` `c:ellipse(cx,cy,rx[,ry])` `c:poly({{x,y},...})` `c:line({{x,y},...}, w)` `c:ascii(rows,x0,y0[,chars])` (fills chars other than `.` and space) `c:mask()` (empty).
Modify in place: `m:add(m2)` `m:cut(m2)` `m:clip(m2)` (intersect) `m:set(x,y)` `m:del(x,y)`. New mask: `m:copy()` `m:grow(r)` `m:shrink(r)` `m:closed(r)` `m:shift(dx,dy)` `m:edge()`. Query: `m:has(x,y)` `m:bbox()` `m:count()` `m:each(f(x,y))`.

## Parts
`c:part(mask, ramp, opts)` returns `{m,r,o}`. `c:build{{name,mask,ramp,opts},...}` returns `{name=part}`. Each part gets: base, lower-right crescent (shade at `cres`, deep at `deep` px), 1 px bounce on the lower-right edge, 1 px rim on the upper-left edge, an enamel gloss comma and dot (2 px in, 3 px in on parts of 16 px or more), an inner contour where it overlaps an earlier part (`#4a2c1a` lit side, `#2a1a10` elsewhere), and a 1 px contact shadow (the lower part's shade) under its bottom edge.
opts: `cres` `deep` `light=mask` (measure the crescent on a bigger mask, e.g. the whole object) `rim=false` `bounce=false` `gloss=false|{x,y}` `contour=false|"#hex"` `contact=false` `stitch=true|{side="lit"}` `flat=true` (base + rim only, for small bits) `solid=false` (left out of the halo and outline silhouette) `outline=false` (scene) `pale=true|false`.
`c:limb(pts[,w=2])` lavender limb with a lit top, no shading. `c:spot(mask[,hex,glint])` marking with a glaze glint.

## Ramps
`GV.ramp("#hex"[,overrides])` gives `{gloss,dot,rim,base,shade,deep,bounce,pale}` from the addenda recipe. Gloss: hue toward 45 deg, L+35% of headroom; rim: gloss x0.9; shade: hue 10 deg toward violet, L x0.76; deep: 25 deg, L x0.52; bounce: shade warmed 12 deg, x1.08. A base with L>0.78 is pale (cream-safe gloss `#fff3c8`, dot `#ffffff`, rim `#f5b860`, and the outline next to it is never the lightest tone).
Presets `GV.R.`: red dusk moss leaf wood soil gold skin water glass cream flame petal stone leg. Pass a preset name as a string (`"red"`), or `GV.ramp("red",{shade="#..."})`. Constants `GV.C`: halo ol1 ol2 ol3 umber gold goldS hole leg legTop spot spotGlint ground.

## Stitching, eyes, details
`c:seam(pts,{on=2,off=1,gap="#hex",free=true})` is a dashed thread-gold polyline. It is `#e8a317` on shaded pixels, skips gloss, and only lands on parts unless `free` is set. `c:stitch(mask,{side="lit"})` is the edge-stitch ring, 2 px in, every third diagonal. `c:button(x,y)` `c:eye(x,y[,small])` `c:px(x,y,hex)` `c:get(x,y)` `c:fill(mask,hex)` `c:paint(rows,x0,y0,legend)` `c:gloss(mask,ramp[,{x,y}])` `c:outline(mask)` (draws now; use it in scenes for non-part pixels). `c:bands(mask|nil,{hex...},{dir="v"|"h"|"radial",cx,cy,r})` gives hard stepped bands, about 5 for a sky. `c:ground(cx,cy,rx,ry[,hex])`.

## Save and check
`c:save(ase, png)` builds the outline, then the ground, then (non-scene) a 1 px `#000000` border on every transparent px 4-adjacent to art (clipped at the frame, so leave 3 px of room; no cream halo). It then creates folders, saves both files and returns `GV.check(img)`: `{w,h,bbox={x0,y0,x1,y1},margin,semi,colours,bw,opaque}`. `margin` is the gap from the frame to the halo (outermost px), `semi` counts 0<alpha<255 px (must be 0), `bw` counts pure #000/#fff px (must be 0 unless it is a pale dot). `c:check()` runs the same check without saving. `GV.report(t)` gives a one-line string.
Gotchas: draw a part only once (overlaps are what make contours). Keep parts at least 2 px wide. For thin bits use `flat=true`. Put the gloss by hand with `gloss={x,y}` if the auto comma lands badly. Check at 32 and 16 px.
