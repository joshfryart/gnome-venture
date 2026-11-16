# Puzzle Pals c06, Opus second pass (art-2701-pals-all/c06/opus2)

Second pass over the Haiku first pass in `../haiku/`. Same 8 pals, keys, callings and concepts; siblings of
`art-2701-batch3/pals/opus3/` and `art-2701-opus/pals/`. Hearth Pop: hard pixels, 1px ink `#2b1c26`, 5-6 tone ramps,
rim light upper-left + cool bounce lower-right. Yard 64x64 uses `c:eyeLocked`; perch 36x36 is hand-built at its size
with `c:eyeSmall` pills and fewer, bolder parts. `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure
black/white). Not copied into game/.

Helper: `_opus.lua` (copy of opus3's helper, paths unchanged). Run:
`AppRun -b --script-param out=<dir>/ --script <key>-yard.lua` (same for `-perch`).

| key | name | rarity / calling | design | fixed vs Haiku | quirk |
|---|---|---|---|---|---|
| sp-chilli-chime | Chilli Chime | common / brewroot | round moss pal, wooden peg pole on its head, two chilli garlands from the peg top to gold bells | chillis are slim hooked pods with green caps (were red bars), garlands clear of the head, tent silhouette | the wind: all chillis swing right, wind curl, bells ring (ticks) |
| sp-stupa-snug | Stupa Snug | uncommon / rootwarden | violet pal under a warm-white stupa dome, gold rim band, harmika, ringed gold spire, prayer flags in 5 colours on two strings | dome is white (was pale blue), flags hang clear above the dome, triangle silhouette | one hand up straightening the last (crooked) flag |
| sp-teal-ferry | Teal Ferry | uncommon / thornblade | teal pal in a straw cone hat in a canoe with marigold and blossom cargo on a teal river patch | water is a bounded wavy patch with margin (was full-width band), real canoe, hat breaks the blob | waves at a leaping fish, which waves its fin back |
| sp-lofty-kite | Lofty Kite | rare / wayfinder | tilted diamond kite, sea-blue top panels over saffron face half, bamboo spars, S ribbon tail with bows | tilt, two-colour panels, face on one area, clean tail (was a tangle) | looks down on everything: half-lidded haughty eyes peering down at a tiny snowy ridge far below |
| br-petal-pinch | Petal Pinch | common / bloomcaller | berry-rose pal, round two-leaf sprout, moss cloth pocket full of pale sakura petals, pinching a notched petal up | body and petals no longer share one pink, pocket is stitched cloth (was a wood box), true notched petals | one petal slipped out of the full pocket, drifting down |
| br-koi-kin | Koi Kin | common / seedkeeper | orange koi at the surface of a stone-rimmed oval pond, head turned to us, cream patches, barbels, tail flicking up | bounded pond with rim (was full-width band), clear face, cousins are fish shapes (were blobs) | a cousin pops its head up blowing a bubble (6 more cousins under the water) |
| br-panda-puff | Panda Puff | common / brewroot | sitting cream-white panda, scalloped fluff, dark ears/arms/legs, drooping patches, bamboo stalk in its paw | fur is white with cool shade (was peach), reads as a panda, stalk held to the mouth | eats slowly: one bite out of the stalk and a leaf still sticking out of its mouth |
| br-pagoda-pin | Pagoda Pin | uncommon / rootwarden | three-tier pagoda pal (two in perch), ember roofs with swept eaves, wood walls, ringed gold spire, face on the ground floor, finger pointing up | spire joined to the roof (floated before), real upturned eaves and tile ribs, face on the biggest wall | its tiny pennant planted on the spire tip (it was up there first) |

Files per key: `<key>-yard.{lua,aseprite,png}` (64x64) and `<key>-perch.{lua,aseprite,png}` (36x36).

Weakest: chilli-chime perch chillis are 2-3 px pods (read as red drops at 1x); koi-kin under-water cousins are small
dashes at 1x (fish shape shows at 2x+); pagoda-pin pennant is tiny and the perch touches the top edge (pennant
outline at row 0); panda-puff bamboo nodes are faint.
