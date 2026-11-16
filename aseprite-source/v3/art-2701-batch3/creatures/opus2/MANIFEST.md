# creatures/opus2: Opus second pass, 9 creature pictures

These replace the Haiku first pass in `../haiku/`. Each `<name>.png` has the same size and file name as the game picture.
`<name>.before.png` is the current game version, copied from `game/assets/img/` and left unchanged.
Nothing under `game/` was touched. Every `.lua` runs `HP.assertClean`, so there are no semi-transparent pixels and no pure black or white.
Run: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<dir>/ --script <name>.lua`. Each script needs only `v3/lib/hp.lua`.

Approach: each picture keeps the design of `.before.png` (colours, pose, props, quirk), not the Haiku version. Haiku had drifted for the minis: the borer turned grey, the blight mother turned into a spiked slug and the clam was a different animal. The named defect was fixed first.

| # | File | Size | Named defect: fix | Also changed | Compared with Haiku |
|---|---|---|---|---|---|
| 1 | `mini-paper-wasp` | 75x56 | Legs were a dark brown tangle. Now 3 near and 2 far legs, each with a 2 px femur, a lit knee, a 1 px shin and a foot. | Real wasp waist (petiole) between the thorax and the abdomen. Elbowed antennae. Lit rim along the top of the abdomen, thorax and head. Small brown mandibles for the mouth. | Haiku lost the tan paper wing, the red bow and the face, and drew stick legs in dusk violet. Opus keeps the original wasp and its quirks. |
| 2 | `mini-bog-leech` | 61x31 | It read as a worm or caterpillar. Now it has the classic leech loop: arched tapered body, a big rear sucker disc on the ground and a small front sucker. | Annulation rings on the shaded half, a pale belly on the inside of the arch, the medicinal-leech orange side stripe, and the eye on the narrow head. Sprout quirk kept and enlarged. | Haiku's version was still a flat segmented caterpillar. |
| 3 | `mini-dew-leech` | 61x23 | New in this pass (Haiku skipped it). It is a sibling of the bog leech, built the same way but flatter. | Sea-blue gloss and a teal rear sucker kept from the game picture. A pale dew-bead stripe. Quirk kept: a dew drop hanging from the front sucker. | Not drawn by Haiku. |
| 4 | `mini-basalt-borer` | 81x49 | Segments were muddy and the head was unclear. Now each body segment is its own faceted basalt plate (lit top facet, crease, dark lower third, deep gap between plates, crystal stud), and the head is a separate darker capsule. | Violet body, two swept horns (now ringed), two eyes and the ember crack quirk kept. Pale boring jaws and stubby clawed legs added. | Haiku recoloured it grey, removed the horns and gave it a drill cone. |
| 5 | `mini-clam-lurker` | 61x45 | The grey head read as a bird or cat. Now there is no head: the lurker is the clam's own soft body, a dark mouth gap between ribbed valves with a frilly peach mantle, a row of cream teeth and two eye stalks. | Round pink clam kept. The foot lolls out like a tongue. Quirk: a pearl on the tongue. Growth ring and dark lip on each valve. | Haiku's open clam had one eye on blue flesh and read as a dish. |
| 6 | `mini-blight-mother` | 101x81 | It was a purple blob with a black smear and a gear-shaped eyespot. Now the smear is a clean pair of feathered antennae, the eyespot is round (cream ring, violet iris, green blight pupil), and a pale fur ruff separates the head, thorax and abdomen. | Wings have veins and a dotted border. Abdomen has curved segment seams and green blight blotches. Six jointed legs with lit knees. One locked eye. The curled orange proboscis is kept, now with a blight drip. | Haiku drew a spiked slug with glass wings, which was no longer the same creature. |
| 7 | `folk-butterfly-1` | 80x100 | The face was a brown blob. A pale muzzle patch now carries a designed button nose (lit tip, warm base, dark underside), a philtrum, a smile and a small tongue. There is a lit lid line above each eye. | Nothing else changed (Haiku's script, path fix only). Locked eyes untouched. | Haiku only swapped the coil for a 2x2 fur-coloured dot, which still read as a blob. |
| 8 | `folk-moth-1` | 80x100 | The nose was a muddy dot. Now there is a pale ruff-tone muzzle, a 4x4 designed button nose, and a smile with a philtrum and a tongue. | Locked eyes and sockets untouched. | Haiku's 2x3 nose was too small to read at 50%. |
| 9 | `folk-tortoise-1` | 80x100 | The shell was a smudge behind the torso. Now it is a tall dome (centre y 101, radius 40x41) that rises to the jaw line on both sides. It has a pale marginal rim with dark ticks, and large costal scutes split by dark seams, each with a growth ring and a lit top-left. | Procedural `shellDeco` removed. Neck, head, hat, bib and trowel unchanged. | Haiku only raised the old ring pattern by 6 px. |

## Weaknesses (honest)
- **mini-basalt-borer:** still the plainest of the set. The plates are clean but similar in value, and the horns are thinner than in the game picture.
- **folk-butterfly-1:** the muzzle patch gives a slightly teddy-bear look. The brown fuzzy head comes from the original design.
- **folk-tortoise-1:** the neck is still long. The shell now frames it, but the head was not moved because that would have meant redoing the hat.
- **mini-bog-leech:** the annulation rings and the pale belly mix into a slightly busy pattern at 400% (it is fine at 100%). The sprout's top outline touches the canvas edge (y 0).
- **mini-dew-leech:** the dew drop is small, 3 to 4 px.
- **Off-palette colours:** all pictures use hand-set ramps outside Hearth Pop 50, which is allowed (not capped). `HP.report` lists them.

## Not rebuilt
- **Fight rig sheets:** `game/assets/img/fight/rig-*.png` were not rebuilt (blight-mother, paper-wasp, bog-leech, dew-leech, basalt-borer, clam-lurker). They come from `aseprite-source/v3/creature25/gen.lua`. Until they are redrawn, the fight art will not match these stills.
- **Folk walking strips:** `game/assets/img/folk/sprite/folk-*-1.png` were not changed.
- **Other variants:** variants 2 and 3 of the butterfly, moth and tortoise were not touched.
- **Game files:** nothing was copied into `game/`.
