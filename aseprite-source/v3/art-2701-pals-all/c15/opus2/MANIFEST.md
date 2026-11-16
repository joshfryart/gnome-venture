# Puzzle Pals chunk c15, Opus second pass (art-2701-pals-all/c15/opus2)

Second pass on chunk 15 of `../../worklist.json` (the pl-jdf and pl-bjq picture families), built on the Haiku
pass in `../haiku/`. Same keys, names, callings and concepts. 8 pals, each a yard sprite (64x64, `c:eyeLocked`)
and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills, no ledge, ground shadow like the c00/opus3
pals): 16 sprites as `.lua` + `.aseprite` + `.png`. `_opus.lua` is the unchanged helper from `c00/opus3`
(tools only). Every sprite passes `HP.assertClean` (0 semi-transparent, 0 pure black/white, 1px ink `#2b1c26`).
Not copied into game/. Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | design | Haiku weakness fixed | quirk |
|---|---|---|---|---|
| pl-jdf-3 | Jade Shimmer | brilliant-cut jade octagon, face on the flat table facet, facets toned by light, bright seams, stubby feet | half-teal / half-green split blob | sheds glitter: a fleck trail on the ground and one fleck stuck on its cheek |
| pl-jdf-4 | Jadewing Quartet | round jade dragonfly chick, ringed tail with a gold thorn tip, four veined glass wings with gold pterostigma | four plain sky blades in a static X on a stick | all four wings crowd to the front at once (hurry ticks behind) |
| pl-jdf-5 | Lantern Eye Pair | round orange paper lantern lit from inside (bright core, hoop lines), jade caps, ember tassel, hanging from a bamboo crook | purple box, no halo | glow rays and a warm light pool; a tiny jade dragonfly zips past and that side flares |
| pl-jdf-6 | Lotus Perch | pointed lotus petals in three layers (deeper back petals), veined, deeper pink tips, gold stamen fringe, notched lily pad, ripples | round paw-print petals | the jade dragonfly naps on its head, "z" above |
| pl-bjq-1 | Tentacle Wisp | glassy pink jelly bulb with the face, one ringed tentacle rising in an S-sway into a spiral curl, pale stinger beads | worm with a sharp elbow | sways to a music note only it hears (sway arcs) |
| pl-bjq-2 | Clownfish Peek | round clownfish facing us, cream cheek stripes with ink borders, ink-tipped dorsal, fins hooked over three lavender brain-coral heads, teal staghorn behind | huge blobby pink coral mound, fish small | only face and fins over the edge, ready to duck (a bubble rising) |
| pl-bjq-3 | Bell Bead | blue sea-glass bell (crown, waist, rolled lip, pale streak, dark core), gold ring with a pink bow, gold bead clapper | flat cone with an aerial spike | mid-ding: clapper swung to one side, ring arcs on that side only |
| pl-bjq-4 | Gold Spike Tiara | circlet of sea-glass bubbles (dim back row, bright front row), exactly four bevelled gold spikes, face on the big centre bubble | five spikes on a cloud, no ring read | one bubble has come loose and drifts up off the top |

Family check: jdf = gem / dragonfly chick / lantern / lotus; bjq = tentacle / fish / bell / tiara (different
species, props and poses, no recolours).

Weak spots left: pl-jdf-3 lower facets sit fairly dark; pl-jdf-6 napping dragonfly is small at 36 px; pl-bjq-2
perch hides the pectoral fins behind the coral; pl-bjq-1 stinger beads are subtle; pl-bjq-4 yard spikes are slim.
