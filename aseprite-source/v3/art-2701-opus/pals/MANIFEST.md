# Pal sprites, Opus pass (art-2701-opus), one pass, eyeballed and refined while drawing
Same 6 Maplewold-roster pals as the Sonnet pass (`../../art-2701/pals/`), redrawn as fresh designs.
Sizes: perch 36x36 (treehouse, `treehouse_pal_pic` in `hub_pages.php`), yard 64x64 (size of `game/assets/img/pals/`).
Each perch is its own hand-built script at 36x36 (own coordinates, pill eyes `c:eyeSmall`, fewer details), not a downscale of the yard (`c:eyeLocked`).

| file prefix | game key | calling | rarity | design | quirk |
|---|---|---|---|---|---|
| acorn-nip | mw-acorn-nip | seedkeeper | common | acorn-bodied squirrel kit, latticed cap, tufted ears, bushy rust tail, buck tooth | baby acorn forgotten in its cap |
| husk-hopper | mh-husk-hopper | bloomcaller | common | grasshopper popping out of a 3-leaf corn husk, knees up, antennae, mouth shut | husk leaf worn as a floppy hat |
| bark-badger | mw-bark-badger | rootwarden | uncommon | stocky grey badger, cream face with ear-to-nose stripes, fissured bark coat | two bracket mushrooms on its back |
| fourwind-finch | mw-fourwind-finch | wayfinder | uncommon | plump chaffinch: slate cap, rosy breast, chestnut wings with cream bars | four compass tail feathers, north one red-tipped |
| samara-spin | mw-samara-spin | thornblade | rare | ribbed nutlet with a brave brow, curved red-amber maple-key wing, hovering (detached shadow, spin arcs, glint) | thorn hooks on the wing edge |
| sap-drip | mw-sap-drip | brewroot | common | glassy amber dollop with curled tip, in its own puddle, mid-yawn (always late) | tiny fly stuck in the amber dome |

Files: `<name>-perch|yard.{lua,aseprite,png}` at native size; `_opus.lua` = shared tools only (pillow/sphere lighting to 6-tone ramps via hpx, bezier tubes, part separation, shift, save). HP.assertClean passes on all 12. Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <name>-yard.lua`.
Weakest: husk-hopper perch (husk leaves blend a bit at 36 px); bark-badger perch (stripes thinned around the eyes so the pill eyes read).
