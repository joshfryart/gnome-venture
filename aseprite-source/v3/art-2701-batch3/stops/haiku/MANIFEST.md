# Stop looks, Maplewold style: Haiku first pass (art-2701 batch 3)

## What one stop look is
- The picture shown for a rest stop. Chosen by stop TYPE + LANDSCAPE + regional STYLE:
  `scenes/here-stop-<type>-<landscape>_<style>.png` (see `game/includes/data/stop_looks.php`).
- Size: **480 x 270 px**, RGBA, native scale (no upscaling in the .png).
- Layout (gate view, same for every look): timber beam across the top with bunting and two
  lanterns, stone posts at both edges, a horizon of trees and hills at y=112, a road running from
  the centre-bottom into the middle distance, and the type's buildings and props on both sides and
  around the road's end. Compass corner (bottom-right, 380-480 x 230-270) is kept plain.
- The type decides the props (a mill has a wheel, a shrine a torii, a tower a shaft). The look
  (landscape + style) decides the palette and flora (here: grassland_maplewold = maple trees,
  plaster and timber, thatch and gable roofs, warm autumn sky).

## Reference looks viewed
- `game/assets/img/scenes/here-stop-market-grassland_maplewold.png` (the shipped Maplewold look)
- `aseprite-source/v3/here-gate/here-market-maplewold-v6.png` (a later Maplewold market variant)
- `aseprite-source/v3/here-gate/pilot-market-grassland_maplewold.png` (the parametric pilot the frame is copied from)
- For contrast: `game/assets/img/scenes/here-stop-camp-desert_adobe.png` (the adobe look)

## Types
`stop_types` has 12 kinds: market, mill, inn, shrine, jetty, herb, workshop, orchard, ferry, tower,
spring, camp. Only **market** has a Maplewold look today, so 11 are open.

Drawn in this pass (8, grassland_maplewold):

| type     | picture                                              | file                  |
|----------|------------------------------------------------------|-----------------------|
| mill     | plaster mill house, great wheel, flour sacks, stream | `mill.{lua,aseprite,png}` |
| shrine   | moss shrine hall, red torii on the steps, stone toro | `shrine.{lua,aseprite,png}` |
| jetty    | lakeside jetty on piles, buckets, net frame, hut     | `jetty.{lua,aseprite,png}` |
| herb     | thatch cottage, raised herb beds, drying racks       | `herb.{lua,aseprite,png}` |
| workshop | timber barn, forge with chimney, bench, plank stack  | `workshop.{lua,aseprite,png}` |
| orchard  | fruit trees laden with apples, tents, cider press    | `orchard.{lua,aseprite,png}` |
| tower    | stone watchtower with beacon and flag, cabin         | `tower.{lua,aseprite,png}` |
| camp     | campfire ring with log seats, tents, woodpile        | `camp.{lua,aseprite,png}` |

Not drawn yet (for a later pass): **inn, ferry, spring**.

## Files
- `_frame.lua`: shared frame (palette = grassland_maplewold, sky, hills, ground, road, gate beam,
  posts, bunting, lanterns, plus helpers: building, tree, pond, sign, awning, barrel). Copied from
  `aseprite-source/v3/here-gate/pilot-market.lua` so every look shares one frame. Each type script
  draws its own objects between `build{}` and `F.finish()`.
- `<type>.lua`: the drawing script for that type. Run with
  `aseprite -b --script <type>.lua` (writes `<type>.aseprite` and `<type>.png` in this folder).
- `<type>.aseprite`: native 480x270, one layer, 1x.
- All eight pass `HP.assertClean` (no semi-transparent pixels, no pure black or white).

## Notes and gaps for the Opus passes
- Outlines use each ramp's `edge` colour, as in the Maplewold market look. The 1px ink `#2b1c26`
  is not used on opaque scenes (lib README: `finish` cannot outline there).
- Density is lighter than the market look (fewer stalls and props). Opus should add the second
  row of props and the figures.
- No layout json yet. Each look also needs a `here_layouts.json` key (spots and stand points) like
  `pilot-market.layout.json`. Not made here.
- Nothing is wired into `game/`. Copying to `game/assets/img/scenes/` and adding a line to
  `stop_looks.php` are for a later step, once Josh has judged the art.
