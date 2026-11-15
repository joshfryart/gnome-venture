# Puzzle Pals chunk c07, Haiku first pass (art-2701-pals-all/c07/haiku)

First pass for chunk 7 of `../../worklist.json` (index 7): 8 pals, each a yard sprite (64x64, `c:eyeLocked`)
and a perch sprite (36x36, hand-built at its size, `c:eyeSmall`), 16 files total. Built only on `lib/hp.lua`
(`_haiku.lua` is a 15-line helper: canvas, finish, report, assertClean, save). `HP.assertClean` passes on all 16
(0 semi-transparent, 0 pure black/white). Shape and knob (jigsaw geometry) are not drawn; the art is the creature.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`. Not copied into game/.

| key | name | calling | rarity | design | quirk | weak spots |
|---|---|---|---|---|---|---|
| br-torii-loop | Torii Loop | seedkeeper | uncommon | gold hopper with a red torii gate on its head, ember looped tail | sky motion dots behind the gate | gate posts merge with the head at 36 px |
| br-dragon-dart | Dragon Dart | thornblade | rare | sea-blue dragonfly, petal and sky paper wings, moss head | cream wink sparkle beside one eye (rare: sparkles) | wings are big and flat; the wink reads as a sparkle, not a wink |
| mt-stilt-stoop | Stilt Stoop | seedkeeper | common | gold round body on two wood stilts, moss hat | one skinA arm raised in a wave; sea canal ripple at the feet | stilts thin on the perch |
| mt-seedling-plod | Seedling Plod | wayfinder | common | squat moss blob with wood clog-feet and a gold seedling on its head | sea music note beside it (singing) | sprout leaves small on the perch |
| mt-lotus-lump | Lotus Lump | bloomcaller | common | petal-pink lump on a notched moss lotus pad | lids drawn over the top rows of the locked eyes (asleep); sea rain dots | lids read a bit cross, not sleepy |
| mt-sky-lantern | Sky Lantern | rootwarden | uncommon | ember paper lantern with ribs, gold core, wood caps and tri top | two sky ribbons trailing down; sky rain-hurry dashes | ribbons read as legs at 36 px |
| mt-fig-knot | Fig Knot | thornblade | uncommon | wood rope-coil knot with moss leaves and a dusk fig | cream folded note wedged in the knot | reads as a walnut more than a knot |
| mt-bill-brolly | Bill Brolly | wayfinder | rare | dusk hornbill with gold beak, ember casque, giant moss leaf umbrella | moss frog tucked at the leaf edge (no face); a sparkle (rare) | frog too small to read; hornbill is purple, not black-and-white |

Weakest overall: mt-fig-knot (reads as a nut), mt-bill-brolly frog (no face, too small), mt-lotus-lump lids.
Perch sprites are simpler than yards on purpose (fewer parts, pill eyes); thin lines (stilts, ribbons, stems)
are the first to blur at 36 px.
