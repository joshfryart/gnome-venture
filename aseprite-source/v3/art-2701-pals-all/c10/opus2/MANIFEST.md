# Puzzle Pals chunk c10, Opus second pass (art-2701-pals-all/c10/opus2)

Second pass on chunk 10 of `../../worklist.json`, built on `../haiku/`. 8 pals. Each has a yard sprite (64x64, `c:eyeLocked`) and a perch sprite
(36x36, drawn by hand at that size, `c:eyeSmall` pills, readable face), so 16 sprites, each as `.lua`, `.aseprite` and `.png`. The concepts are kept.
They match the finished Opus pals (`c00/opus3`, `art-2701-batch3/pals/opus3`): 5-6 tone hue-shifted ramps, light from the upper left,
rim light and cool bounce, material texture, and one quirk from the blurb. `_opus.lua` is an unchanged copy of the c00/opus3 helper (tools only).
`HP.assertClean` passes on all 16 (0 semi-transparent px, 0 pure black or white, 0 isolated px, 1px ink `#2b1c26`). Margins are at least 1 px
everywhere, so nothing touches the canvas edge. Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | design | haiku weakness fixed | quirk |
|---|---|---|---|---|
| pl-cnd-5 | Nest Wobble | deep woven twig bowl on a puffy cloud, tipped right past the cloud edge, speckled egg inside, face on the woven front | face was on the egg; nest read as a ufo/hat brim | the wobble: tilted nest, sway arcs either side (closer look: pink bloom in the twigs) |
| pl-cnd-6 | Grand Condor Plume | slate-black condor flight feather lying diagonally on the air, narrow leading edge, white base patch, ivory shaft, gold-banded quill nib | read as a brown corn husk, ran off the top-left edge, cut-off wind dashes | it still floats: pale updraft swirls under it |
| pl-owl-1 | Pinfeather Hush | plump tawny barred feather standing on its quill, grey down puff (afterfeather) at the base | was a plain brown ghost blob | the hush: a grey down wisp held up across its pursed lips, hush ticks |
| pl-owl-2 | Nightglow Fleck | round chip of moon in cool moonlight tones, zigzag snap with the slab showing, craters, glow streak | was a grey-blue planet ball | crumbs trailing behind as it falls home (closer look: three talon scratches) |
| pl-owl-3 | Aurora Thread | ball of yarn wound two ways, green and violet strands with grooves | banded purple ball on stick legs (beetle/planet) | wears its own thread as a knitted scarf with fringed tails (closer look: loose curl of thread on top) |
| pl-owl-4 | Owlet Peep | great white owl chick: grey down ball, cowlick, heart face, one wing flopped out, on den straw | read as a brown cat (pointed ears, lids over eyes) | the peep: beak wide open, peep ticks and a little note |
| pl-owl-5 | Snowcrag Halo | snow mound on grey crag with a scooped blue hollow, aurora ring floating over it as a halo | pale blue slime with an arc; no hollow or crag | two owlets asleep in the hollow (shut eyes, "z") |
| pl-owl-6 | Great White Plumelet | long white plume arching over and drooping, fluffy wisps, tip dipped in aurora (mint, teal, violet), eyes in lavender sockets | white dome on a stick (jellyfish/lamp), low-contrast eyes | a drop of aurora dripping off the tip |

The six owl pals are all clearly different: brown feather, moon chip, yarn ball, grey owlet, snow hollow and white plume. They have different shapes, ramps and props, and none is a recolour of another.

Weak spots left: at 25%, pl-owl-1 yard can still look a little like a pinecone or bread loaf (the barring is soft). The pl-owl-5 perch halo has a 1 px bump at its top. The pl-cnd-5 cloud is mostly hidden by the nest, so its puff bumps barely show. pl-cnd-6 perch has 1 px bottom margin and its trailing-edge notch is tiny.
