# Puzzle Pals chunk c07, Opus second pass (art-2701-pals-all/c07/opus2)

Second pass on chunk 7 of `../../worklist.json` (index 7), from the Haiku first pass in `../haiku/`. Same 8 keys,
names, callings, rarities and concepts; fixes the read, silhouette and small-size faces. Yard 64x64 uses
`c:eyeLocked`; perch 36x36 is hand-drawn at its size with `c:eyeSmall` pills and fewer, bolder parts. Built on
`lib/hp.lua` + `lib/hpx.lua` through `_opus.lua` (a copy of `art-2701-batch3/pals/opus3/_opus.lua`: per-pixel
lighting, rim light, bounce, texture). Hearth Pop: 1px ink `#2b1c26` outline, 4-6 tone ramps, hard pixels.
`HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | design | quirk | Haiku weakness fixed |
|---|---|---|---|
| br-torii-loop | gold hopper (long feet, cream belly) wearing a red torii gate (black kasagi, nuki, posts set on the crown); open tail curl with an ember tip | dashed hop trail that loops the loop | gate posts merged with the head; ring tail read as a mug handle |
| br-dragon-dart | diagonal darting dragonfly: moss head, sea-blue segmented abdomen with a violet thorn tip, four slim fan-folded paper wings (petal + sky washi) | the wink: one locked eye, one closed arc with lifted brow (rare sparkle off the wing) | big flat wings; wink read as a sparkle |
| mt-stilt-stoop | amber round body on jointed bamboo stilts, straw cone roof-hat, a plank stoop under the belly, canal strip | waving open mitten with motion ticks | stilts too thin at 36 px; "stoop" unreadable |
| mt-seedling-plod | pear-shaped moss body with grass flecks and pale belly, three rice blades on the crown, mud legs in paddy water, one seedling held out | singing to the seedling (round open mouth, a note) | gold sprout did not read as rice; flat ball body |
| mt-lotus-lump | lotus bud (pale to deep-pink tip, cupped front petals, back petals) on a notched veined lily pad, rain falling | sleep bubble from its nose; heavy drooping lids | spiky crown; lids read cross, not asleep |
| mt-sky-lantern | rice-paper sky lantern glowing from inside, curved ribs, bamboo hoop, hanging flame | shooing a small grey rain cloud off (speed lines, drips) | ribbons read as legs; no light source |
| mt-fig-knot | strangler fig: twisted root-knot head with roots knotted over the crown, lobed fig leaves, a hanging dusk fig; two roots wrap and cross over a carved mossy temple stone | red-sealed secret scroll pinned where the roots cross | read as a walnut |
| mt-bill-brolly | charcoal-plum hornbill, cream belly and tail band, big gold bill with ember casque, lashes; holds an arched leaf brolly reaching out over the frog | the frog sitting dry under the leaf edge (bulging eyes, grin); rare sparkle | purple bird; frog too small, no face |

Weakest: mt-fig-knot head is still a fairly plain ball under the root X; bill-brolly perch frog eyes are only
1x2 px; sky-lantern yard cream eye discs are soft against the brightest paper (paper held one tone down there);
torii-loop perch gate sits 1 px from the top edge.
