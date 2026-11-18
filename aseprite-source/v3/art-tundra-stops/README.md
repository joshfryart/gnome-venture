# Tundra stop looks: `tundra_frost`

Rest-stop pictures in the arctic tundra landscape, frost style. Each one is 480x270, native 1x, one layer, and passes `HP.assertClean` (no semi-transparent pixels, no #000000 or #ffffff).
Installed name: `game/assets/img/scenes/here-stop-<type>-tundra_frost.png`. Layout key (not yet added): `stop-<type>-tundra_frost` in `game/includes/data/here_layouts.json`.

Drawn so far: **mill** (401 colours).

## Run
```
./_run.sh mill            # = /tmp/aseq/squashfs-root/AppRun -b --script-param out=<this dir>/ --script mill.lua
python3 _zoom.py mill.png /tmp/crop.png x0 y0 x1 y1 scale   # nearest-neighbour review crop
```
Set `APP=...` to use another Aseprite AppRun. The `--script-param` must come before `--script`. No X server is needed (use `xvfb-run -a` if Aseprite asks for one).

## Making another type
1. Copy the forest script (`../art-forest-stops/<type>.lua`) or the Maplewold one (`../art-2701-batch3/stops/opus3/<type>.lua`, `../art-2701-batch4/stops/opus3/<type>.lua`) to this folder.
2. Set `DIR` to this folder and `dofile(DIR .. "_frame.lua")`. The `build{...}` options are the same.
3. Re-cast its materials for the tundra (see `mill.lua`). Keep the composition so the layout hotspots still fit.

## Palette summary
Cool snow whites with lilac and blue shadows. Wind-bared ground in muted ochre lichen, grey-green moss and rusty bearberry. Rust-red dwarf willow and birch twigs. Dark and frosted blue spruces. Ice blue water. A pale sky tinted with aurora green and lilac, and a peach low sun. Warm lamp windows and falu-red paint give the warm accents. Wood is silver driftwood and stone is cool granite.

### `L` keys: same keys as Maplewold and forest, tundra meaning
| Key | Now means |
|---|---|
| `ground`, `groundFar` | **Snow**, cool white. Its `shade`/`deep` are lilac-blue. |
| `roof` / `roof2` | Straw-olive **sod** turf, which wears a snow cap / blue-grey slate |
| `timber` | Silver driftwood. It is also the ink `edge` used for every outline. |
| `board` | Pale planks, cream to tan |
| `plaster` / `wall2` | Lime render, or white Nordic trim / **falu-red** paint |
| `stone`, `road` | Cool granite / frosted flagstones |
| `foliage` / `foliage2` | Dark stunted spruce / frosted blue spruce |
| `leaf` | Rusty dwarf willow scrub (used by `F.bush` and `F.willow`) |
| `needle` | Rust lichen and bearberry (forest key, kept) |
| `fern` | Dry sedge and grass straw. `F.fern` now draws a sedge clump. |
| `moss`, `mossGround` | Grey-green tundra moss |
| `water` | Ice blue open water |
| New: `snow`, `ice`, `lichen`, `rust`, `greyMoss`, `fur` (white animals), `deer` (reindeer brown), `peak`, `rock`, `aurora` (4 colours), `tLichen`/`tMoss`/`tRust` (4-step lists for the bare ground) | |
| `shadow` / `shadowRoad` | Lilac `#b0b4d4` / `#8e92b0` |

## What changed from the forest `_frame.lua`
The API is the same: the same `build{}` options, the same `F.*` helpers and the same `L.*` keys. The horizon (y=112), slab road, gate, bunting, lanterns and compass corner are in the same places. Everything else is re-skinned or added.

| Area | forest_pinewood | tundra_frost |
|---|---|---|
| Sky | Dusk green-gold overcast | 5 pale bands, from lilac-blue down to peach. A faint daylight aurora hangs in two curtains (`noAurora`). Thin stratus streaks. |
| Sun | Misted sun at (92,52) | A **low** sun at (72,80), just above the fells, with a short sun pillar and two sun dogs. `sunX`/`sunY`/`noSun` still work. |
| Back rows | Conifer ridges, mist | Snowy fells with rock gullies (`o.peaks = {{cx,h,halfW},...}`, `noPeaks`). Snowy far hills with sparse spruce clusters. Mid rises with lit crests and lilac lee hollows. Spindrift streaks. |
| Horizon line | Continuous conifer line | A sparse line of stunted spruce clumps and willow scrub. `treeLineGap`/`noTreeLine` work as before. |
| Ground | Needle carpet | Snow, painted per pixel by `groundAt` (so `eraseGround` matches exactly). Wind-bared patches in muted lichen, moss and rust, wind ripples (sastrugi), and bright wind-packed crests. Detail: sedge tufts, lichen clumps, willow sprigs, snow-capped stones, crowberries, frozen puddles, snow lips and cotton grass. |
| Road | Moss in the seams | Snow in the seams, rime frost, a few slabs glazed with ice, and ploughed snow banked along both verges |
| Shadows | `F.shadow(dx,dy)` as given | **Long and soft.** The cast length is 2x `dx` and 1.3x `dy`: a core tone out to `dx,dy` and a paler fringe beyond it. Leave room to the lower right. |
| `F.tree` | Spruce, fir or red pine | `seed % 4`: 0 and 2 are frosted blue spruce, 1 is dark spruce, 3 is a **bare dwarf birch**. All spruces are narrower and snow-loaded. `far=true` gives a hazed snowy spruce. |
| `F.birch` | Leafy birch | A bare birch: forked limbs, rust twig fan, a few dry leaves, snow on the limbs |
| `F.building` | Thatch by default, `shingle=true` | **Sod roof by default**, with a snow cap (`snow=` depth, default 3; `noSnow=true` to skip) and icicles along the eave (`icicles=` max length, default 4). `thatch=true` and `shingle=true` still work. |
| Gate | Pine boughs, moss | Snow-laden spruce boughs, icicles under the beam, snow on the course ledges, plinths and brackets, rime speckle |
| Smoke, birds, rim light | Grey-green, brown, gold | Lilac-grey peat smoke, raven-grey birds, a warm low-sun rim (`#f8e2c2`) |

### New helpers
- `F.snowCap(mask, depth, seed, {cx, lip})` puts snow on the top `depth` px of any mask. It is lit left of `cx`, and `lip` adds a 1 px overhang. It returns the snow mask. Use it on roofs, sacks, rocks, sills and bridges.
- `F.icicles(x0, x1, y, maxLen, seed, density)` hangs icicles from a line.
- `F.drift(x, yb, halfW, h, seed)` draws a wind-sculpted drift: windward slope on the left, a cornice and lee shadow on the right.
- `F.rubble(mask, ramp, y0, rowH, seed)` gives an irregular stone wall with lichen- and moss-tinted stones and frost on the course tops.
- `F.sod(mask, ramp, y0, cx)` is the sod turf texture.
- `F.willow(x, yb, halfW, h, seed[, ramp])` draws dwarf willow scrub with snow at its foot.
- `F.steam(x, y, n, drift, seed)` draws pale steam wisps, not smoke.
- `F.tracks(points, "hare"|"deer"|"bird"|"boot", step)` presses tracks into the snow.
- `F.cairn(x, yb, h, seed)` builds a snow-capped stone cairn.
- `F.fells(list)` draws the mountain backdrop. `F.vnoise` is the smooth noise.
- Forest helpers kept: `F.conifer` (new option `snow=false`), `F.pine`, `F.fern`, `F.mushroom`, `F.logs`, `F.logEnd`, `F.moss`, `F.ridge` (new args `keep(x)` and `gapMin`).

## Reuse notes and quirks
- **Compass corner.** `F.finish()` repaints x≥380, y≥230 as plain snow after your drawing. Anything you put there disappears.
- **White on white.** Cream (`L.awnB`) and white things vanish against the snow. Grain sacks need a burlap ramp (see `SACK` in `mill.lua`). White animals (`L.fur`) need their ink rim and a dark feature (eyes, ear tips, a black tail). Put light objects against something dark (a wall, water or a spruce) where you can.
- **Long shadows.** Because `F.shadow` now doubles `dx`, a shadow from an object on the left can reach the road or the next object. Shrink `dx` if it does.
- **The ink rim fills narrow gaps.** `rimOf` on a union fills gaps of 1-2 px with ink. For open structures (fan blades, rails), draw the parts unrimmed and rim only the solid outer parts, as the wind-pump wheel in `mill.lua` does.
- **Spruces are narrow.** A spruce of the same `h` is about 0.85x the width of a forest conifer. Seed 3 (and 7, 11, …) gives a bare birch, which fills almost nothing, so do not use it as a screen.
- **Roofs.** Thin roof bands are almost all snow cap. If you want the sod to show, use a larger `rh` or a smaller `snow`.
- **Forest scripts run unchanged** against this frame (same keys), but they will look forest-like. Re-cast logs as driftwood, ferns as sedge and mushrooms as lichen or crowberries.
