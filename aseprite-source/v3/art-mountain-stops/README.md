# Mountain stop looks: `mountain_granite`

Rest-stop pictures in the high-mountain landscape, granite style. Each one is 480x270, native 1x, one layer, and passes `HP.assertClean` (no semi-transparent pixels, no #000000 or #ffffff).
Installed name: `game/assets/img/scenes/here-stop-<type>-mountain_granite.png`. Layout key (not added yet): `stop-<type>-mountain_granite` in `game/includes/data/here_layouts.json`.

Drawn so far: **mill** (427 colours).

## Run
```
./_run.sh mill            # = /tmp/aseq/squashfs-root/AppRun -b --script-param out=<this dir>/ --script mill.lua
python3 _zoom.py mill.png /tmp/crop.png x0 y0 x1 y1 scale   # nearest-neighbour review crop
```
Set `APP=...` to use another Aseprite AppRun. The `--script-param` must come before `--script`. No X server is needed (use `xvfb-run -a` if Aseprite asks for one).

## Making another type
1. Copy the forest script (`../art-forest-stops/<type>.lua`) or the Maplewold one (`../art-2701-batch3/stops/opus3/<type>.lua`, `../art-2701-batch4/...`) to this folder.
2. Set `DIR` to this folder and `dofile(DIR .. "_frame.lua")`. The `build{...}` options are the same, plus the new ones below.
3. Re-cast its materials for the mountains (see `mill.lua`): whitewashed granite ground storeys (`L.plaster` + courses), larch boards above (`L.timber` + `F.planks`), slab roofs (`L.roof`, `shingle=true`) with weighting stones and `F.lichen`, goats, boulders, edelweiss and gentian. Keep the composition so the layout hotspots still fit.

## Palette (`L`): same keys, mountain meaning
| Key | Now means |
|---|---|
| `sky` | 5 pale cold blue bands (`#8eaccb` .. `#d8e2ea`) |
| `foliage` / `foliage2` | Larch light yellow-green / blue-green spruce |
| `farTree` | Hazed spruce blue-grey |
| `timber` | Sun-browned larch (chalet wood, dark on top) |
| `board` | Pale fresh-sawn wood |
| `roof` / `roof2` | Granite slab / slate roof, blue-grey / red-brown larch shingle. Use `shingle=true` in `F.building`. |
| `plaster` / `wall2` | Whitewashed stone / pale blue paint |
| `stone`, `road` | Cool granite greys |
| `accent` | Gentian blue (default gnome coat) |
| `ground`, `groundFar` | Short alpine turf, blue-green / olive |
| `mossGround`, `duff` | Lush turf patch / scree gravel |
| `moss` | Grey-green lichen (and turf moss) |
| `needle`, `fern` | Dry alpine straw / grass blades |
| `water` | Milky glacial turquoise |
| New: `peakFar`, `peak`, `snow`, `gentian`, `edel`, `juniper`, `goat`, `chamois`, `cheese`, `lichenOrange` | |
`HAZE` is `#d6e0e8` (thin cold air). Rim light is `#f2f0dc`. Smoke is cold blue-grey; `F.birds` default to dark alpine choughs.

## What changed from the forest `_frame.lua`
The API is the same: the same `build{}` options, the same `F.*` helpers and `L.*` keys. Everything else is additive.

| Area | forest_pinewood | mountain_granite |
|---|---|---|
| Sky | Dusk green-gold overcast, misted sun | Pale cold blue, thin flat cloud banks, a small crisp sun at (86,48). `noSun`, `sunX`/`sunY`, `clouds={{x,y,w},...}` as before. |
| Back rows | Conifer spire ridges | **New.** Two ranges of snow-capped granite peaks (`F.range`): a hazed slate-blue far range with deep caps, a cloud wisp at y 64..67, a nearer grey granite range with snow patches and couloirs. Left flanks lit, right in shade. Override with `peaksFar={{x,topY,slope,snowDepth},...}` / `peaksNear=...`, or `noPeaks=true`. Then slate foothills with talus streaks and a sparse spruce ridge, the green mid hills, valley haze. |
| Horizon | Dense misted conifer line | Sparse stands of spruce and larch with granite boulders between. `treeLineGap={x0,x1}` (default 220..260) / `noTreeLine=true` as before. |
| Ground | Needle carpet | Alpine turf painted per pixel by `groundAt` (lush patches, scree patches with pebbles, far snow patches), so `eraseGround` still matches. Detail: grass blades, edelweiss, gentian, arnica / alpine-rose dots, lichened pebbles, juniper cushions, straw tufts. |
| Road | Moss in seams | Grass in some seams, lichen blotches, odd orange lichen dot |
| `F.tree` | spruce / fir / red pine | seed%4: 0,2 spruce, 1 larch, 3 arolla pine (dark crown on a red trunk). `far=true` as before. |
| Gate | Pine boughs, moss | Arolla / larch / juniper boughs with upturned needle brushes and purple cones; lichen rosettes on the granite posts; bunting red / cream / gentian / gold |
| New helpers | — | `F.larch(x,yb,h,seed,{r,far})`, `F.snow(mask,k,seed)` (snow on upper faces), `F.lichen(mask,k,seed)`, `F.boulder(x,yb,w,h,seed[,ramp])`, `F.juniper(x,yb,w,h,seed)`, `F.edelweiss(x,y,big)`, `F.gentian(x,y,big)`, `F.goat(x,yb,{flip,k,r,graze,hat,noShadow})`, `F.marmot(x,yb,{flip})`, `F.range(peaks,ramp,snowRamp,{seed,yb,haze})`, `F.vnoise` |
All forest helpers stay (`F.conifer`, `F.pine`, `F.birch`, `F.fern`, `F.mushroom`, `F.logs`, `F.logEnd`, `F.moss`, `F.ridge` (now with an optional 7th `gap` arg)), so forest scripts run unchanged; they just look forest-y until re-cast.

## Quirks to know
- **Compass corner.** `F.finish()` repaints x>=380, y>=230 as plain ground after your drawing. Anything you put there disappears.
- **`F.building` gables.** With `shingle=true` the roof is only a band along the eaves; most of the front is the gable wall. Put weighting stones on the band (see `mill.lua`), not on the gable.
- **`F.goat` size.** `k=1` is about 30 px to the horn tips (taller than a gnome); use `k=.4..5` on the far terraces, `.6..8` for kids or mid ground. `hat=<ramp>` swaps the horns for a gnome hat. Draw it after the thing it stands on, with `noShadow=true` when it stands on a wheel or boulder.
- **Things behind the tree line.** Draw a background feature (e.g. the mill's cascade) right after `build`, with `F.depth(0)`, and widen `treeLineGap` so no horizon tree sits in front of it.
