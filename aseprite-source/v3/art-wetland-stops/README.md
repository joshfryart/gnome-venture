# Wetland stop looks: `wetland_reed`

Rest-stop pictures in the wetland (fen / marsh) landscape, reed style. Each one is 480x270, native 1x, one layer, and passes `HP.assertClean` (no semi-transparent pixels, no #000000 or #ffffff).
Installed name: `game/assets/img/scenes/here-stop-<type>-wetland_reed.png`. Layout key (not added yet): `stop-<type>-wetland_reed` in `game/includes/data/here_layouts.json`.

Drawn so far: **mill** (430 colours).

## Run
```
./_run.sh mill            # = /tmp/aseq/squashfs-root/AppRun -b --script-param out=<this dir>/ --script mill.lua
python3 _zoom.py mill.png /tmp/crop.png x0 y0 x1 y1 scale   # nearest-neighbour review crop
```
Set `APP=...` to use another Aseprite AppRun. The `--script-param` must come before `--script`. No X server is needed (use `xvfb-run -a` if Aseprite asks for one).

## Palette in one breath
A soft grey-gold overcast sky with a low misted sun (upper left), a flat alder/willow carr on the back rows with cream mist banks and bright lagoon strips, golden reed beds with mauve plumes, olive sedge, warm peat and mud, still dark grey-teal water that mirrors the sky's gold, silvery weeping willows and dark alders, silver-weathered boards, tarred weatherboard, golden water-reed thatch with a dark sedge ridge cap. Accents (bunting, gnome hats, lantern glow) are unchanged.

## Making another type
1. Copy the Maplewold script (`../art-2701-batch3/stops/opus3/<type>.lua` or `../art-2701-batch4/stops/opus3/<type>.lua`) or the forest one (`../art-forest-stops/<type>.lua`) to this folder.
2. Set `DIR` to this folder and `dofile(DIR .. "_frame.lua")`. The `build{...}` options are the same (plus the new ones below). Unedited Maplewold and forest scripts already render with this frame.
3. Re-cast the materials for the fen (see `mill.lua`): put buildings on stilts or decks over water, use reed thatch, boardwalks, punts, reeds, geese/herons/frogs. Keep the composition so the layout hotspots still fit.

## What changed from the forest `_frame.lua`
The API is the same: the same `build{}` options, the same `F.*` helpers (all forest helpers are kept) and the same `L.*` keys. Everything else is additive.

| Area | forest_pinewood | wetland_reed |
|---|---|---|
| Sky | 5 dusk green-gold bands, misted sun | 5 grey-gold bands, a bigger stepped gold halo round the sun at (92,52) (`noSun`, `sunX`, `sunY`) |
| Far hills | Conifer spire ridges | Flat: the far hill line is 5 px lower. `F.ridge` now draws rounded carr clumps (same signature). Mist banks on the far carr, bright lagoon strips at the foot of the mid carr (y 109..112). The mid hill is 2 px lower. |
| `farTrees` | Hazed conifers | Hazed rounded carr trees |
| Haze (`HAZE`) | `#d2dacb` | `#dad5bf`, warm grey-gold |
| Horizon | Conifer tree line | A reed-bed fringe along y≈113..118 with willows/alders every 22..52 px and mist drifting through. Same `treeLineGap` (default 220..260) and `noTreeLine`. |
| Ground | Needle carpet | Wet sedge (olive) with green sedge and dark peat patches, and **still pools** from a second noise: dark lip under the far bank, gold sky streaks, muddy margin. `poolK` (threshold, default .75; higher = fewer, mill uses .77), `noPools=true`. `F.poolAt(x,y)` says where they are. All painted by `groundAt`, so `eraseGround` restores pools exactly. Detail: sedge tufts, reed clumps with plumes, fallen straws, marsh marigold / cuckooflower / forget-me-not, peat clods, sphagnum, bulrushes, sunk stones, and lily pads on the pools. |
| Road | Mossy slabs | A raised causeway: the same slabs with peat silt and moss in the seams and a few puddles, a stone flank face 1..3 px each side, a wet peat line, a ditch of dark water 0..3 px (nearer = wider) and revetment stakes every 23 rows. The flank and ditch sit **outside** `F.roadM`. |
| `F.tree` | Conifers | `seed % 4`: 0, 2 = weeping willow (`F.willow`), 1 = alder (`F.alder`), 3 = pollard willow (`F.pollard`, drawn at 0.8×h). A willow is about as wide as a maple crown, so Maplewold gap-fillers still fit. |
| `F.water` | Rippled cool water | Still fen water: pale sky band at the far edge, gold `F.SKYREF` band, dark near water, long thin sky streaks, few glints. New option `{ dark = true }` for water in shade (under decks/stilts). |
| `F.building` thatch | Shingles were the default look | Reed thatch (no `shingle`) again looks right; the apex gets a dark sedge ridge cap (`ridge = ramp` to change it, `noRidge = true` to drop it). |
| Gate | Pine boughs | Willow clumps with long two-tone trailing fronds; reed sheaves bound on both braces. Stone moss, lanterns, bunting, compass corner unchanged. |
| Smoke | Grey-green | Warm grey peat smoke |

### Palette (`L`): same keys, fen meaning
| Key | Now means |
|---|---|
| `foliage` / `foliage2` | Dark alder green / silvery willow green |
| `farTree` | Hazed carr green-grey |
| `timber` | Wet grey-brown stilt / gate timber |
| `board` | Silver-weathered boardwalk planks |
| `roof` / `roof2` | Golden water-reed thatch / old dark sedge thatch (also the ridge cap) |
| `plaster` / `wall2` | Warm clay daub (also burlap sacks) / grey-green painted board |
| `water` | Still dark fen water; `hi` is the pale sky reflection |
| `ground`, `groundFar` | Sedge-and-straw olive tan |
| New: `reed`, `reedGreen`, `plume`, `cattail`, `peat`, `willow`, `willowBark`, `lily`, `heron`, `goose`, `marigold`, `sedgeGround` | |

### New helpers
`F.willow(x,yb,h,seed[,ramp])`, `F.alder(x,yb,h,seed[,ramp])`, `F.pollard(x,yb,h,seed[,ramp])`, `F.reeds(x0,x1,yb,h,seed,{cattails=n, green=true})`, `F.sedge(x,y,h[,ramp])`, `F.cattail(x,yb,h,big)`, `F.lily(x,y,big,flower)` (`"white"`/`"yellow"`), `F.dragonfly(x,y[,ramp,flip])`, `F.frog(x,y,flip)`, `F.heron(x,yb,flip)` (26 px, faces left), `F.goose(x,yb,flip,swim)` (greylag), `F.punt(x0,x1,yWater[,ramp,{pole={x0,y0,x1,y1}}])`, `F.stilts(xs,yTop,yb,waterline)`, `F.boardwalk(mask,vertical,seed)`, `F.mist(x0,x1,y0,y1,seed,k)`, `F.poolAt(x,y)`, `F.SKYREF`.

## Quirks to know
- **Compass corner.** `F.finish()` repaints x≥380, y≥230 as plain ground after your drawing. Anything you put there disappears.
- **Ground pools land anywhere.** They come from noise, so one can sit under a building, a target or a gnome. Raise `poolK` (.78...8) or set `noPools` if a scene needs dry ground, or paint your own pool with `F.water`.
- **Water under things.** `F.water` puts the bright sky band at the top of the mask's bounding box. For water under a deck or behind stilts, repaint that part with `F.water(subMask, L.water, { dark = true })` (see `mill.lua`).
- **Causeway flank.** The stone flank and ditch beside the road are outside `F.roadM`; things placed hard against the road edge cover them, which is fine.
- **Mist.** `F.mist` paints solid mist pixels over everything already drawn; skip x-ranges that cross a landmark (the mill splits it around the windpump).
