# art-2701-rest / haiku: first pass (Haiku 5.5), 8 icons

Not exported to game/. Shared helpers: `_trail.lua` (32x32 trail helper, loads `../../lib/hp.lua`) and `_p.lua` (sewn-patch painter for the 64x64 hat, copied from `art-2701-next8/opus3`). Rebuild: `AppRun -b --script-param out=<this dir>/ --script <name>.lua`. Every file passes `HP.assertClean` (no semi-transparent, no pure black or white).

## Wearable

| name | base | design | quirk |
|---|---|---|---|
| wayfarers-hat-b | `game/assets/img/ph/wayfarers-hat-b.png` (pixels unchanged) | sewn moss-green and cream 3 px check patch on the brown crown above the red band, dark hem, gold whip stitches | gold star embroidered in the centre of the patch |

## Trail map markers (32x32, green map)

The seven kinds were chosen from landmark kinds (`game/includes/landmarks.php`), road kinds (`game/includes/data/road_kinds.txt`) and the list in the brief. Not yet drawn in `art-2701-opus/trail/` (camp, ferry, tunnel, pass, toll, sight, villager, fight).

| name | kind | what it means in the game | design | quirk |
|---|---|---|---|---|
| trail-haven | landmark: haven | a safe stop where a gnome rests by the fire, stays the night, buys from a little pantry | cottage with red gable roof, stone chimney, gold walls, lit window, wood door | cat asleep on the windowsill |
| trail-wonder | landmark: wonder | a once-a-day thing to investigate with stat checks; good finds | two standing stones with a lintel and a violet glow in the arch | moss tuft grown along the lintel |
| trail-delve | landmark: delve | a once-a-day five-room loot run ending in a chest; the way down | stone-rimmed square hatch in a grassy mound, ladder into violet dark, warm glow at the bottom, pickaxe leaning on the left | gold coin rolled up over the rim |
| trail-lair | landmark: lair | the landscape's legendary boss; a first win gives a ribbon and a big reward | rocky mound with claw scratches, dark cave mouth, horned bone skull with empty eye sockets | red ribbon knotted round the left horn (first win) |
| trail-overgrown | road kind: overgrown | the road is swallowed by bramble; a tool or a path may be needed to get through | old signpost with a faded board, foot buried in a three-tone moss bramble with thorn ticks | bird's nest with two pale blue eggs |
| trail-flooded | road kind: flooded | the road dips under a pool; crossing needs a fitting tool (boots) | blue pool over a road dip, two fence posts standing out of the water, ripple lines | lily pad with a pink flower |
| trail-market | market / shop | a stall where the gnome can trade | red and cream striped awning on two posts, wood counter with an apple, a loaf and a cabbage | cream price tag hanging on a string off the awning |

Rest stop, signpost and hazard were left out on purpose; `gate` is not a road kind in `road_kinds.txt` (only ferry, tunnel, pass, toll, overgrown, flooded exist there), so it was not used.

## Weak spots (for the Opus pass)
- trail-wonder: the two stones are blocky; the rune reads weakly at 32x32.
- trail-overgrown: the bramble reads as a moss mound at 1x; thorns are faint.
- trail-lair: the skull is clear but the ribbon is only 3 px.
- wayfarers-hat-b: the patch is a little small against the crown; the star is 5 px.
