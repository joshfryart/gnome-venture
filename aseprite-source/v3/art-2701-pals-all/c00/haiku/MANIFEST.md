# Puzzle Pals chunk c00, Haiku first pass (art-2701-pals-all/c00/haiku)

First pass for chunk 0 of `../../worklist.json`: 8 pals, each a yard sprite (64x64, `c:eyeLocked`) and a
perch sprite (36x36, hand-built at its size, `c:eyeSmall`), 16 files total. Built only on `lib/hp.lua`
(`_haiku.lua` is a 15-line helper: canvas, finish, report, assertClean, save). `HP.assertClean` passes on all 16
(0 semi-transparent, 0 pure black/white). Shape and knob (jigsaw geometry) are not drawn; the art is the creature.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`. Not copied into game/.

| key | name | calling | rarity | design | quirk | weak spots |
|---|---|---|---|---|---|---|
| mw-leaf-tuck | Leaf Tuck | bloomcaller | common | red maple-leaf creature, pointed top, midrib | right flap tucked over, moss-green underside; leaf stalk on top | flap reads as a separate piece at 16 px |
| mh-cob-scout | Cob Scout | wayfinder | common | gold corn cob with kernel rows, green husk arms | notched tally stick held in one husk | kernel texture is noisy on the perch |
| mh-kernel-knock | Kernel Knock | seedkeeper | common | fat gold kernel, pointed tip, mouth open | half-popped puff on top; two knock ticks beside the head | puff comes out sky-blue, not popcorn-white |
| mh-stitch-crow | Stitch Crow | thornblade | uncommon | dusk-violet crow in a too-big straw hat, ember band, gold beak | cream measuring tape round its neck | body reads purple more than crow-black; hat dominates the perch |
| mh-golden-ring | Golden Ring | rootwarden | uncommon | thick gold hoop, lower band is the face | wheat sheaf inside the hole; cream glint on the hoop | hole is small on the perch, sheaf barely readable |
| mh-popcorn-moon | Popcorn Moon | brewroot | rare | gold crescent with craters, sparkles (fancier) | popcorn puffs bursting off the top-left rim | puffs read blue; crescent eyes sit close to the inner cut |
| ss-palm-fidget | Palm Fidget | bloomcaller | common | wood-brown coconut head, three moss fronds | one frond curled into a fidget loop; sky breeze ticks | fronds thin at 36 px |
| ss-tide-tuck | Tide Tuck | brewroot | common | sand-gold dome tucked into the beach | cream foam curl on a sea-blue wave behind | wave reads as a blue block or hill, not a curl (weakest of the set) |

Weakest overall: ss-tide-tuck (wave), mh-kernel-knock and mh-popcorn-moon (blue puffs where popcorn should be white).
Perch sprites are simpler than yards on purpose (fewer parts, pill eyes); stalk and tick details are the first to
blur at 36 px.
