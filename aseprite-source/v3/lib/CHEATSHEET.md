# Hearth Pop cheat sheet (read this, do NOT read the full style guide or other examples)

Run: `/tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script f.lua` (0-based px, hard pixels only).

## Look (10 rules, short)
1. Silhouette first, readable at 16 px. Objects SLIM (stems/handles 3-4 px, air between parts). Fill 40-52 px, >=5 px margin, centred.
2. ONE 1px ink outline `#2b1c26` outside the object (c:finish does it). No black/white, no semi-transparency, no dither.
3. Items use 5-6 tone ramps per material (dark->light). Light from upper-left, shade lower-right, deepest tone under/where parts meet.
4. Material cues: waxy bloom/spec on fruit, midrib+veins on leaves, grain on wood, bevel+streak on metal, weave on cloth, twist on rope, bright rim+pale core on glass. Add AO (dark row) and a contact shadow where parts meet.
5. One bright spec/glint per object (glossy things may have more). Colour: saturated base, cool-violet shadow, warm-yellow light; no colour cap.
6. One small QUIRK per item (odd charming tell), not a repeated gag. Every item structurally unique (no recolour templates).
7. `-seed`: 2-5 real seeds of THAT plant (true shape, size, colour, markings) on a torn leaf scrap in that plant's leaf shape/colour, with ONE seed split and a tiny sprout showing the plant's first leaves (true leaf shape: grass blades, bean pair, lobed, compound, needle...). Same polish as a crop.
8. Food: warm, glossy, one bite/steam/drip as quirk. Jars/pots: ground shadow (2-tone, 3px). Icons `ico-`: bolder, 3px min parts.

## Lib (v3/lib/hp.lua + hpx.lua), via batch2/_bbg.lua
```lua
local G = dofile("<aseprite-source>/v3/items/batch2/_bbg.lua")   -- sets G.out from --script-param out
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w=64, h=64, scale=1, name=NAME }
```
Masks: `c:rect(x0,y0,x1,y1) c:rrect(..,r) c:ellipse(cx,cy,rx,ry) c:poly{{x,y}..} c:line({{x,y}..}, w)`; `HP.mask()`; methods `:add :cut :clip :copy :shift(dx,dy) :grow(n) :shrink(n) :edge() :has(x,y) :each(fn(x,y)) :count()`.
Paint: `c:put(x,y,"#hex",tok)`, `c:fillMask(m,"#hex")`, `c:px`. tok = `{ r = { name = "part" } }` (any table).
Lighting (hpx X.*): `X.pillow(mask, R)` -> normal field; `X.light(n,{amb=,wrap=})` -> brightness; `X.tone(c, mask, v, ramp6, {cuts={.22,.4,.56,.72,.86}, tok=tok})` -> paints, returns idx map; `X.spec(n, power)`; `X.ao(bias, m, other, r, amt)`; `X.hash(x,y,seed)` deterministic noise 0..1.
Bbg: `G.blade(ax,ay,cx,cy,bx,by, widthFn(t), {fold=})` -> mask,normals,T,S,len (leaf along a bezier; S<0 = lit side); `G.tube(pts4, widthFn)` -> mask,normals,T (stem/rope); `G.oval(cx,cy,rx,ry,ang,flat)`; `G.toneN(c,m,n,ramp,{bias=,tok=,cuts=,amb=,wrap=})`; `G.cast(bias,target,caster,dx,dy,amt)` shadow bias; `G.specAt(m,n,power)` -> x,y of best highlight; `G.save(c, NAME)` (finish outline + centre + assertClean + save to G.out). Call G.save once, last.
Flat painters: `c:part(mask, ramp|"name")` = base + one shade band + pop (+ inner lines); `c:groundShadow(cx,cy,rx,ry)` draw FIRST; `c:sparkle(x,y)`.

## Exemplar to copy structure from (read this ONE file): v3/items/batch2/blueberry-seed.lua  (Opus seed: teardrop seeds with pits+hilum, V-fold veined leaf scrap, split seed + radicle + stem + elliptic leaf pair + bud, quirk hat). Change shapes, counts, leaf type, colours, sprout and quirk so YOUR plant is clearly different.

## Workflow (keep tool calls minimal)
1. View the old art `game/assets/img/<folder>/<name>.png` upscaled (one Read of a 6x PNG) only if you do not know the item.
2. Write each item as ONE self-contained .lua, run it, fix only errors.
3. ONE 6x contact PNG of all your items (PIL: nearest resize, grey bg), Read it once, fix only outright failures (unrecognisable, wrong size, assertClean). Then stop. No second review.
