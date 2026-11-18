# Coast stop looks: `coast_driftwood`

Rest-stop pictures in the coast landscape (temperate chalk-and-dune coast, NOT the tropical island look), driftwood style.
Each one is 480x270, native 1x, one layer, and passes `HP.assertClean` (no semi-transparent pixels, no #000000 or #ffffff).
Installed name: `game/assets/img/scenes/here-stop-<type>-coast_driftwood.png`. Layout key (not added yet): `stop-<type>-coast_driftwood`.

Drawn so far: **mill** (429 colours).

## Run
```
./_run.sh mill            # = /tmp/aseq/squashfs-root/AppRun -b --script-param out=<this dir>/ --script mill.lua
python3 _zoom.py mill.png /tmp/crop.png x0 y0 x1 y1 scale   # nearest-neighbour review crop
```
Set `APP=...` to use another Aseprite AppRun. The `--script-param` must come before `--script`. Use `xvfb-run -a` if Aseprite asks for an X server.

## Making another type
1. Copy the forest script (`../art-forest-stops/<type>.lua`) or the Maplewold one (`../art-2701-batch3|4/stops/opus3/<type>.lua`).
2. Set `DIR` to this folder and `dofile(DIR .. "_frame.lua")`. The `build{...}` options are the same.
3. Re-cast its materials for the coast (see `mill.lua`): whitewash (`plaster`) or tarred boards (`tar`) for walls, slate (`roof`, `shingle=true`) or pantile (`roof2` + `F.pantile`) roofs, `wall2` sea-blue doors and window frames, lichen instead of moss, marram / thrift / shells instead of ferns / mushrooms, gulls instead of small birds. Keep the composition so the layout hotspots still fit.

## Palette (`L`), same keys, coast meaning
| Key | Now means |
|---|---|
| `sky` | 5 breezy blues, dithered band edges, drawn down to the sea horizon (`F.SEA_Y` = 92) |
| `cloud` | `top / mid / shade / under`: cumulus, lit upper left, grey-blue undersides |
| `roof` / `roof2` | Blue-grey slate (use `shingle=true`) / red pantile (`F.pantile(roofM, L.roof2, y0)`). Thatch would look wrong. |
| `plaster` / `wall2` | Salt-bleached cool whitewash / sea-blue paint (doors, window frames, boats) |
| `timber` / `board` | Weathered grey driftwood / sun-bleached boards |
| `stone`, `road` | Cool granite / pale limestone slabs |
| `ground`, `groundFar` | Golden dune grass; the ground also has sand blowouts and green turf patches |
| `water` | Tide-pool blue. `sea` is the open-sea ramp. |
| `foliage` / `foliage2` / `leaf` | Silver sea-buckthorn / dark wind-pruned hawthorn / dune turf |
| `petal` | Sea-thrift pink. `accent` is fisherman navy. |
| New | `sand`, `wetSand`, `shingle`, `marram`, `chalk`, `sea`, `foam` (a hex), `kelp`, `tar`, `lichen`, `gull`, `gorse`, `cork`, `glass` |
| Kept forest keys | `moss` (sea-lichen grey-green), `needle` (dry wrack brown), `fern`, `mossGround` (turf), `duff`, `birch`, `birchLeaf`, `redbark` |

## What changed from the forest `_frame.lua`
The API is the same (same `build{}` options, `F.*` helpers and `L.*` keys); everything else is additive.

| Area | forest_pinewood | coast_driftwood |
|---|---|---|
| Sky | Overcast green-gold, misted sun | Breezy blue, bright sun at (92,52) (`noSun`, `sunX`, `sunY`), cumulus heaps (`clouds` = {{x, yBottom, w}}), low streaks over the sea |
| Back rows | Conifer ridges + mist | Sea from `SEA_Y` 92 to the surf at y≈105 (dark horizon line, whitecaps, sun glitter), a chalk headland left (x<150, `leftHeadEnd`) and right (x>368, `rightHeadStart`), a hazed far headland, two sea stacks (`stacks`), far luggers (`boats` = {{x,y,len}}, `{}` for none), pale beach, golden dunes (`fMid`) |
| Horizon | Conifer tree line | A dune line (marram hummocks, thrift, sand-fence stubs). Gap 220..260; `duneLineGap` / `treeLineGap`, `noDuneLine` / `noTreeLine` |
| Ground | Needle carpet | Dune grass with sand and turf patches; marram tufts, shingle, shells, sea thrift, driftwood sticks, wrack, sea campion, sand ripples |
| Road | Moss in the seams | Blown sand in the seams, orange lichen crusts |
| `F.tree` | Conifers | `seed%4`: 0,2 wind-bent hawthorn, 1 sea-buckthorn, 3 leaning pine; `far` = small hazed wind-bent shrub |
| Gate | Pine boughs, moss | Fishing-net swags with cork floats, glass floats in rope cages, hanks of kelp; lichen on the posts, salt bloom low down |
| Smoke / birds / rim light | Grey-green / brown / `#f2ecc0` | Blue-grey / gull grey / warm white `#f8f2dc` |
| New helpers | — | `F.windTree(x,yb,h,ramp,seed,{lean,far,bark})`, `F.marram(x,y,h)`, `F.thrift(x,y,big)`, `F.shell(x,y,big)`, `F.pebbles(x,y,n,seed)`, `F.driftwood(x0,y0,x1,y1,w)`, `F.wrack(x,y,w,seed)`, `F.lichen(mask,k,seed)`, `F.barnacles(mask,k,seed,yFrom)`, `F.cork(x,y)`, `F.boat(x,yb,len,{far,flip,sail,hull,band})`, `F.gull(x,y,size1..3)`, `F.netSwag(x0,x1,y0,sag,{col,col2,floatStep})`, `F.lobsterPot(x,yb,w)`, `F.pantile(mask,ramp,y0)`, `F.seaWater(mask)`, `F.cumulus`, `F.cliffFace`, `F.SEA_Y`, `F.SHORE_Y` |

## Quirks to know
- **Compass corner.** `F.finish()` repaints x≥380, y≥230 as plain ground after your drawing. Keep tree crowns clear of x=380 there.
- **The sea is open between x 150 and 368.** Anything tall at the road's end (y<112) stands against the sea and sky, so it reads strongly; the left headland's chalk is very pale, so pale smoke or white objects at x<150, y 60..100 vanish against it.
- **`F.fFar(x)`** returns the headland top (or `SEA_Y` over open sea); use it to sit things on a headland (the mill's lighthouse does).
- **Lichen, not moss.** `F.moss` still works but reads as forest. Use `F.lichen` (roofs, stone) and `F.barnacles` (anything at the tide line).
- **Tar outlines.** Dark coastal objects read best rimmed with `L.tar` instead of `L.timber`.
