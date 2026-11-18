# Island stop looks: `island_palm`

Rest-stop pictures in the island landscape (volcanic / coral island, reef, lagoon, palms), palm style. Each one is 480x270, native 1x, one layer, and passes `HP.assertClean` (no semi-transparent pixels, no #000000 or #ffffff).
Installed name: `game/assets/img/scenes/here-stop-<type>-island_palm.png`. Layout key: `stop-<type>-island_palm` in `game/includes/data/here_layouts.json` (not added yet).

Drawn so far: **mill** (463 colours).

## Run
```
./_run.sh mill            # = /tmp/aseq/squashfs-root/AppRun -b --script-param out=<this dir>/ --script mill.lua
python3 _zoom.py mill.png /tmp/crop.png x0 y0 x1 y1 scale   # nearest-neighbour review crop
```
Set `APP=...` to use another Aseprite AppRun. The `--script-param` must come before `--script`. No X server is needed (use `xvfb-run -a` if Aseprite asks for one).

## Making another type
1. Copy the Maplewold script (`../art-2701-batch3/stops/opus3/<type>.lua` or `../art-2701-batch4/stops/opus3/<type>.lua`), or the forest one in `../art-forest-stops/`, to this folder.
2. Set `DIR` to this folder and `dofile(DIR .. "_frame.lua")`. The `build{...}` options are the same.
3. Re-cast its materials for the island (see `mill.lua`). Keep the composition so the layout hotspots still fit.

## Palette summary
Hot clear tropical light from the upper left. Sky: five blues, deep `#4f9ed8` at the top to pale aqua `#bce2ea` at the horizon, a white sun with a stepped halo, big white cumulus (lit `#f6f6ee`, blue-grey undersides). Deep-blue sea (`sea`) on the horizon, a far violet-blue volcano with a steam wisp, a white reef surf line, and a turquoise lagoon (`lagoon`). Bright coral-sand ground with beach-grass patches. Black volcanic rock (`lava`) for footings, plinths and boulders. Hibiscus red/orange (`awnA`, `hibiscus`) and plumeria pink (`petal`) as the flower accents. Dried palm thatch (`roof`), bamboo (`board`) and silver driftwood (`timber`). Turquoise paint (`wall2`, `accent`) for shutters and coats.

## What changed from the forest `_frame.lua`
The API is the same: the same `build{}` options, the same `F.*` helpers and the same `L.*` keys. Everything else is additive.

| Area | forest_pinewood | island_palm |
|---|---|---|
| Sky | Dusk green-gold overcast, misted sun | 5 clear blues, a hot white sun at (92,52) with a halo (`noSun`, `sunX`, `sunY`), big round cumulus. `clouds` still takes `{x, y, w}` (y = flat base). |
| Far plane | Conifer ridges, mist | **Sea** from y=95 (`F.SEA`) to the reef at y=104 (`F.REEF`), sun glitter, a far volcano (`volcanoX`=376, `volcanoTop`=58, `noVolcano`), a far islet on the left (`noIslet`). Lagoon from y=106 to the horizon. |
| Mid plane | Conifer ridge on mid hills | Low palm-scrub **motu** (islets) on the reef, with a channel gap at x 168..312 (`motuGap={x0,x1}`, `noMotu`). `farTrees` are small hazed palms, drawn only where they stand on a motu (`F.onMotu(x)`). |
| Horizon line | Dense misted conifer tree line | A sparse **palm fringe** along the shore (y≈115, plane 1), with naupaka scrub at the feet. Same `treeLineGap` (default 220..260) and `noTreeLine`. A foam line along y=112 and wet sand at y=113. |
| Haze (`HAZE`) | `#d2dacb` | `#d4ecee`, bright salt-air aqua |
| Ground | Needle carpet, moss, duff | Coral sand. Beach-grass / sea-grape patches and bright sand drifts from value noise. Detail: grass tufts, shells (conch, scallop, cowrie), coral bits, black lava pebbles, fallen hibiscus / plumeria, morning-glory runners, crab holes, driftwood twigs. `groundAt` still paints every ground pixel, so `eraseGround` matches. |
| Road | Moss in seams | Coral-stone slabs, sand in the seams, a few pink pores |
| `F.tree` | Conifers | `seed % 4`: 0 and 2 are coconut palms (`foliage` / `foliage2`, leaning opposite ways), 1 is a banana plant (drawn at 0.75 h), 3 is a plumeria (0.8 h). `far=true` gives a hazed palm. |
| Gate | Pine boughs, mossy posts | Palm fronds hanging off the beam with hibiscus and plumeria. Coral-stone posts with the odd black lava block, lava plinths. Bunting uses `hibiscus` orange in place of the moss shingle. |
| Smoke, birds, rim light | Grey-green, grey-brown, `#f2ecc0` | Pale warm smoke, slate seabirds, hot `#fff4cc` rim light |
| New helpers | — | `F.palm(x,yb,h,ramp,seed,{lean,far,fronds,nuts,dead,frondLen})` returns crown, topX, topY. `F.banana(x,yb,h,seed,{noBunch,leaves})`, `F.plumeria(x,yb,h,seed)`, `F.hibiscus(x,yb,w,h,seed,kind)`, `F.flower(x,y,kind,small)` with kind `hibiscus`/`orange`/`plumeria`/`white`. `F.frond(x,y,ang,len,droop,ramp,seed,{wide,noRim})`. `F.shell(x,y,kind,big)`, `F.coral(x,y,h,ramp)`, `F.lavaRock(x,yb,w,h,seed)`, `F.coconut(x,y,r,green)`, `F.crab(x,y,ramp,flip)`, `F.parrot(x,y,"macaw"|"lory",flip)`, `F.outrigger(x0,x1,y,{side,hull,stripe})`. Textures: `F.bamboo(mask,ramp,step,{horizontal})`, `F.net(mask,ramp,{floats})`. |
| Kept | — | `F.conifer` (reads as a casuarina), `F.pine`, `F.birch`, `F.fern`, `F.mushroom`, `F.logs`, `F.logEnd`, `F.moss`, `F.ridge`, all re-coloured |

### Palette (`L`): same keys, island meaning
| Key | Now means |
|---|---|
| `foliage` / `foliage2` | Coconut-frond green / deep jungle teal-green |
| `leaf` | Banana and cane-leaf yellow-green |
| `farTree` | Hazed palm teal |
| `timber` (= `driftwood`) | Silver-brown driftwood: frames, wheels, posts |
| `board` (= `bamboo`) | Bamboo and cane gold. Use with `F.bamboo`. |
| `roof` (= `thatch`) / `roof2` | Dried palm thatch (the default, so `F.building` thatches) / sun-faded rust |
| `plaster` / `wall2` | Coral-lime whitewash / turquoise paint (shutters) |
| `stone`, `road` | Cream coral stone |
| `ground`, `groundFar` | Coral sand. `duff` is wet sand. `mossGround` is beach grass. |
| `water` | Lagoon turquoise. `lagoon` is a brighter version for pools. |
| New: `sea`, `lagoon`, `surf`, `lava`, `coral`, `hibiscus`, `palmTrunk`, `coconut`, `rope`, `shell`, `seagrass`, `pinkwash` (pastel coral-pink limewash for hero walls) | |

## Reuse notes
- **Compass corner.** `F.finish()` repaints x≥380, y≥230 as plain ground after your drawing. Anything you put there disappears.
- **The horizon is open water.** Anything at plane 1 or 2 above y≈95 stands against the sea and the sky, not a tree line, so its silhouette shows. The palm fringe is sparse; widen `treeLineGap` if the road's end landmark is wider than 220..260. Keep big landmarks away from x≈330..470 above y 95, or set `volcanoX` / `noVolcano`.
- **Palms are wide, not tall.** A palm of height `h` spreads its fronds about ±0.5 h around a top that leans by up to 0.32 h, so it fills more width than a conifer and leaves the ground clear under it. Pass `lean` to control which way it bends. Seed 1 (5, 9, …) gives a banana and seed 3 (7, 11, …) a plumeria, both shorter than `h`.
- **Bright, high-key ground.** The sand is light, so pale walls (`plaster`) and thatch can merge with it. Give hero buildings a darker footing (`lava`), coloured shutters (`wall2`), or the `pinkwash` ramp so they read at 50%.
