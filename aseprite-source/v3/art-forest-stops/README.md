# Forest stop looks: `forest_pinewood`

Rest-stop pictures in the forest landscape, pinewood style. Each one is 480x270, native 1x, one layer, and passes `HP.assertClean` (no semi-transparent pixels, no #000000 or #ffffff).
Installed name: `game/assets/img/scenes/here-stop-<type>-forest_pinewood.png`. Layout key: `stop-<type>-forest_pinewood` in `game/includes/data/here_layouts.json`.

Drawn so far: **mill** (331 colours).

## Run
```
./_run.sh mill            # = /tmp/aseq/squashfs-root/AppRun -b --script-param out=<this dir>/ --script mill.lua
python3 _zoom.py mill.png /tmp/crop.png x0 y0 x1 y1 scale   # nearest-neighbour review crop
```
Set `APP=...` to use another Aseprite AppRun. The `--script-param` must come before `--script`. No X server is needed (use `xvfb-run -a` if Aseprite asks for one).

## Making another type
1. Copy the Maplewold script (`../art-2701-batch3/stops/opus3/<type>.lua` or `../art-2701-batch4/stops/opus3/<type>.lua`) to this folder.
2. Set `DIR` to this folder and `dofile(DIR .. "_frame.lua")`. The `build{...}` options are the same.
3. Re-cast its materials for the forest (see `mill.lua`). Keep the composition so the layout hotspots still fit.

## What changed from the Maplewold `_frame.lua`
The API is the same: the same `build{}` options, the same `F.*` helpers and the same `L.*` keys. Everything else is additive.

| Area | Maplewold | forest_pinewood |
|---|---|---|
| Sky | 4 warm apricot bands, puffy cream clouds | 5 dusk green-gold bands. Long, flat overcast banks. A pale misted sun at (92,52), upper left. Turn it off with `noSun`, or move it with `sunX`/`sunY`. |
| Far hills | Maple crowns on the hill | A conifer spire ridge on the far hill and on the mid hill (`F.ridge`). Mist streaks above the far ridge and along the foot of the mid hills. |
| Haze (`HAZE`) | `#ecdcd8`, warm | `#d2dacb`, cool green-grey mist |
| Horizon | Open | **New.** A misted conifer tree line along y≈115 (plane 1). It leaves a gap at x 220..260 for the road's end. Use `treeLineGap={x0,x1}` to move the gap and `noTreeLine=true` to remove the line. |
| Ground | Flat stripes, grass tufts, maple leaves, pebbles | A needle carpet in browns and olive. Moss and dark-duff patches come from value noise. Detail: fallen needles, fern and grass tufts, pine cones, red and brown mushrooms, moss tufts, mossy pebbles. Ground pixels are painted by `groundAt`, so `eraseGround` matches exactly. |
| Road | Plain slabs | The same slabs, with moss in the seams and on some slab faces |
| `F.tree` | Maple crown | A conifer, chosen by `seed % 4`: 0 and 2 are blue-green spruce (`foliage2`), 1 is fir (`foliage`), 3 is red-bark pine. `far=true` gives a slim hazed conifer. |
| `F.maple`, `F.crown`, `F.bush` | — | Unchanged. They draw broadleaf clumps. |
| Gate | Flat maple crowns, clean stone | Clumped pine boughs with hanging needle fringes and cones. Moss cushions on the stone courses and plinths. |
| Smoke, birds, rim light | Warm | Cool grey-green smoke, grey-brown birds, a softer gold rim light (`#f2ecc0`) |
| Gnome belt buckle, hen beak | `L.roof` gold | `L.gold`, because `roof` is now olive moss shingle |
| New helpers | — | `F.conifer(x,yb,h,ramp,seed,{far,w,slim,bark})`, `F.pine`, `F.birch(x,yb,h,seed)`, `F.fern(x,y,size,ramp)`, `F.mushroom(x,y,ramp,big)`, `F.logs(mask,ramp,y0,step,{ends})`, `F.logEnd(x,y,r,bark)`, `F.moss(mask,k,seed)`, `F.ridge` |

### Palette (`L`): same keys, forest meaning
| Key | Now means |
|---|---|
| `foliage` / `foliage2` | Fir green / blue-green spruce |
| `farTree` | Hazed conifer blue-green |
| `timber` | Grey-brown weathered wood. Also log walls. |
| `board` | Pale fresh-sawn pine. Also planks and end grain. |
| `roof` / `roof2` | Mossy olive cedar shingle / red-brown bark shingle. Use `shingle=true` in `F.building`. Thatch would look wrong here. |
| `plaster` / `wall2` | Pale limewash / grey-green paint |
| `stone`, `road` | Cool mossy greys |
| `ground`, `groundFar` | Needle-carpet brown, olive in the distance |
| `water` | Cool blue-green |
| New: `moss`, `mossGround`, `duff`, `birch`, `birchLeaf`, `redbark`, `needle`, `fern`, `petal`, `gold`, `ridgeFar`, `ridgeMid`, `mist`, `mist2` | |

## Quirks to know
- **Compass corner.** `F.finish()` repaints x≥380, y≥230 as plain ground after your drawing. Anything you put there disappears.
- **`F.tree` is narrower.** A conifer of the same `h` is about 0.7× the width of a maple crown. Scenes that used one maple to fill a gap need two trees or a larger `h`. Seed 3 (and 7, 11, …) gives a pine, whose crown sits high on a bare trunk. Do not put a pine behind a gate post (x<16 or x>464), or only its crown will show.
- **Horizon tree line.** It is drawn before your script runs, so anything at plane 1 or 2 sits in front of it. If the road's end landmark is wider than 220..260, widen `treeLineGap`.
- **Log walls.** For a log cabin, use `F.building{..., shingle=true, noFrame=true}`, then `F.logs(wallMask, L.timber, top, 3)`. `building` returns `top, cx, wallM, roofM`.
