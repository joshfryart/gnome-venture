# Rainforest stop looks: `rainforest_canopy`

Rest-stop pictures in the rainforest landscape, canopy style. Each one is 480x270, native 1x, one layer, and passes `HP.assertClean` (no semi-transparent pixels, no #000000 or #ffffff).
Installed name: `game/assets/img/scenes/here-stop-<type>-rainforest_canopy.png`. Layout key (not added yet): `stop-<type>-rainforest_canopy` in `game/includes/data/here_layouts.json`.

Drawn so far: **mill** (1825 colours).

## Run
```
./_run.sh mill            # = /tmp/aseq/squashfs-root/AppRun -b --script-param out=<this dir>/ --script mill.lua
python3 _zoom.py mill.png /tmp/crop.png x0 y0 x1 y1 scale   # nearest-neighbour review crop
```
Set `APP=...` to use another Aseprite AppRun. The `--script-param` must come before `--script`. No X server is needed (use `xvfb-run -a` if Aseprite asks for one). A render takes under a second.

## Making another type
1. Copy the forest script (`../art-forest-stops/<type>.lua`) or the Maplewold one (`../art-2701-batch3/stops/opus3/<type>.lua`, `../art-2701-batch4/...`) to this folder.
2. Set `DIR` to this folder and `dofile(DIR .. "_frame.lua")`. The `build{...}` options are the same, plus `noShafts` / `shafts`.
3. It will already render: `F.tree`, `F.conifer`, `F.pine`, `F.birch`, `F.building{shingle=true}` and `F.fence` all draw rainforest versions. Then re-cast its materials for the jungle (see `mill.lua`): bamboo and woven mat instead of logs and planks, palm thatch, rice sacks, coconuts, heliconia, orchids, giant leaves, parrots, monkeys, frogs. Keep the composition so the layout hotspots still fit.

## What changed from the forest `_frame.lua`
The API is the same: the same `build{}` options, the same `F.*` helpers and the same `L.*` keys. Everything else is additive.

| Area | forest_pinewood | rainforest_canopy |
|---|---|---|
| Sky | Dusk green-gold overcast | 5 humid golden-green bands, piled cloud banks with a rounded tower, a larger hazy golden sun at (92,52) (`noSun`, `sunX`/`sunY`) |
| Far hills | Conifer spire ridges | Rounded canopy-crown ridges (`F.ridge`, same signature plus an optional `skip(x)`), with the odd emergent palm silhouette. Mist streaks on both rows. |
| Haze (`HAZE`) | `#d2dacb` | `#d4e2bc`, humid golden-green |
| Horizon | Misted conifer line | A continuous canopy wall, umbrella-crowned trees and palms in front, mist at their feet. Gap 220..260 for the road's end (`treeLineGap`, `noTreeLine`). |
| Ground | Needle carpet | Wet red-brown leaf litter in big patches of green understorey, dark humus and orange fresh leaf-fall. Detail: fallen leaves, seedlings, ferns, roots, orange/red fungi, moss, fallen heliconia/orchid petals, tiny sky-reflecting puddles, wet-shine pebbles. `groundAt` still paints it, so `eraseGround` matches. |
| Road | Mossy slabs | Same slabs: moss in the seams, rain puddles on some slabs, wet shine on the lit lips |
| `F.tree` | Conifers | `seed % 4`: 0 teal canopy tree, 1 emerald canopy tree, 2 coconut palm, 3 pale fig with lime crown. Even seeds of the canopy tree get pale bark, odd seeds dark bark. `far=true` gives a hazed umbrella tree. Canopy trees have buttress-root fins (h ≥ 30), two limbs, a 3-lobe crown, hanging vines (h ≥ 24) and a bromeliad (h ≥ 36). |
| Gate | Pine boughs, cones | Broadleaf drapes with giant leaves behind, hanging vines, hanging heliconia chains and orchid sprays; vines with orchids climbing the inner face of both posts; moss and wet shine on the stone courses |
| Roofs | Shingle / thatch | Palm-leaf thatch on every `F.building` (5 px frond rows, golden with patches of fresh green palm), a ragged leaf edge over the gable, a ragged fringe under the eave, a bamboo ridge pole. `shingle=true` is accepted and also gives palm thatch. The timber frame (`noFrame=false`) is bamboo. `wall = L.plaster` gets a woven palm-mat texture. |
| Fences | Timber | Bamboo (`F.fence`, `F.fenceP`) |
| Light | Rim light `#f2ecc0` | Rim light `#f6eeb6`, plus golden light shafts slanting down-right from the upper left (applied in `finish()` before the gate, one opaque mix per pixel). `noShafts=true` turns them off; `shafts={{u,width},...}` moves them (u = x − 0.62·y at the shaft centre). |
| Smoke, birds | Cool grey | Humid green-grey smoke. Pass a colour as the 4th bird field for parrots (`{x,y,w,"#2e7a46"}`). |
| Compass corner | Plain `ground.base` | Plain `groundAt` ground with no detail, so it blends with the patchy floor |

### New helpers
`F.canopy(x,yb,h,ramp,seed,{w,far,bark,small,noVines})`, `F.palm(x,yb,h,seed,{ramp,lean,far})`, `F.treeFern(x,yb,h,seed[,ramp])`, `F.fronds(tx,ty,n,len,ramp,seed,"palm"|"fern")`, `F.bigLeaf(x,y,len,angle,ramp,seed[,halfWidth],{droop,torn,heart,stem={sx,sy}})` (angle in radians, 0 = right, π/2 = down), `F.vine(x,y,len,seed[,ramp,flowerRamp])`, `F.vines(mask,chance,seed[,maxLen])`, `F.heliconia(x,yb,h,seed)`, `F.orchid(x,y[,ramp,n,flip])`, `F.bamboo(x,yb,h,nCulms,seed)`, `F.bambooWall(mask,ramp,w[,horizontal,seed])`, `F.palmThatch(mask,ramp,y0,cx[,seed])` (also `F.thatch`; the old straw thatch is `F.strawThatch`), `F.shine(mask,k,seed)` (wet glints on the upper-left of a mask), `F.puddle(x,y,w,seed)`. Kept: `F.conifer` (narrow canopy tree), `F.pine` (palm), `F.birch` (pale fig), `F.fern`, `F.mushroom`, `F.logs`, `F.logEnd`, `F.moss`.

### Palette (`L`): same keys, rainforest meaning
| Key | Now means |
|---|---|
| `foliage` / `foliage2` / `leaf` | Deep emerald broadleaf / teal canopy / lime young leaves |
| `farTree` | Hazed teal canopy |
| `timber` | Wet dark red-brown hardwood (posts, wheel rims, sills, dark bark) |
| `board` | Seasoned golden split bamboo / pale wood |
| `roof` / `roof2` | Golden dried palm thatch / fresh green palm thatch |
| `plaster` / `wall2` | Woven palm mat or pale clay / teal paint |
| `stone`, `road` | Green-grey wet stone |
| `ground`, `groundFar` | Wet red-brown litter, green distant understorey |
| `water` | Jade jungle water |
| `soil` | Wet red-brown earth, coconut husk |
| `moss`, `mossGround`, `fern`, `birch`, `birchLeaf`, `redbark`, `needle`, `duff` | Kept from forest: green moss, understorey, ferns, pale fig bark, young canopy, mahogany, dry fallen leaf / palm fibre, dark humus |
| New: `vine`, `bamboo` (living green), `palmTrunk`, `litter`, `orchid`, `helic` (red→yellow heliconia), `teal`, `wet` / `shine` (specular glints), `shaft` | |

## Quirks to know
- **Compass corner.** `F.finish()` repaints x≥380, y≥230 as plain ground after your drawing. Anything you put there disappears.
- **Trees are wider.** A canopy tree's crown half width is 0.4·h (`F.tree`) or 0.34·h (`F.conifer`); a conifer was 0.32·h. Canopy crowns sit low (centre at 0.68·h), so a tree at plane 2 covers more of what is behind it. Seed parity picks pale or dark bark; a pale-barked tree at plane 1 hazes to a white pillar, so use an odd seed there.
- **Bunting covers y≈15..38 at the centre.** Keep a road's-end roof apex at y ≥ 46 and anything perched on it below y ≈ 38, or the bunting hides it.
- **Light shafts** brighten everything below them except the gate, including your scene. Keep small dark details (eyes, ink) out of the shaft centres, or pass `shafts` / `noShafts`.
- **Sugarcane / cane bundles** in `mill.lua` are local helpers (`caneBundle`, `cane` ramp), as are `sack` (hessian rice sack), `bambooEnd`, `coconut` and `banana`. Copy them if another type needs them.
