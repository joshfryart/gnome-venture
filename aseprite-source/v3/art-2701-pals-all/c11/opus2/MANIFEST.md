# Puzzle Pals chunk c11, Opus second pass (art-2701-pals-all/c11/opus2)

Second pass on chunk 11 of `../../worklist.json` (Dragonlizard Den + Forge of the Cinder Wyrm), built on `../haiku/`.
8 pals. Each has a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-drawn at that size, `c:eyeSmall`
pills), so 16 sprites, each as `.lua` + `.aseprite` + `.png`. Keys, names, callings and concepts are the same as the
first pass. The style matches `c00/opus3` and `art-2701-batch3/pals/opus3`: 5-6 tone hue-shifted ramps, light from the
upper left, one lower-right shade band, rim light, cool bounce light, and texture via `O.tex`. Each pal has one quirk
from its blurb. `_opus.lua` is an unchanged copy of the c00/opus3 helper and only holds tools.
`HP.assertClean` passes on all 16: 0 semi-transparent pixels, 0 pure black/white, 1px ink `#2b1c26`, and a margin of
at least 1 px on every sprite. Nothing was copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

The six den pals were all lizard-ish beans in the first pass. Now they are six different species, poses and colour families:

| key | name | now | haiku weakness fixed | quirk |
|---|---|---|---|---|
| pl-dlz-1 | Scalecrust Tot | brick-red baby lizard sitting up, big head with an ochre crust cap of plates, peach belly, tail curled out | green bean with a stalk, no lizard read | laughing open mouth; a crust flake pops off the crown (pale bare spot, motion ticks) |
| pl-dlz-2 | Tongue Flicker | teal chameleon on a blossoming twig: helmet casque, spiral tail, cream stripe, pink freckles | yellow bean with a duck-like snout | forked red tongue flung in a long arc, well clear of the fly |
| pl-dlz-3 | Tail Tick | golden leopard gecko, low on a flat stone, brown spots, round toe pads, fat banded tail | blue blob with a hose tail | tail arched up and over, tip knocking a pebble with tick marks |
| pl-dlz-4 | Diamond Spur | dusty-rose horned lizard, crown of three horns, chin up and smug, side spines | brown bean with gold blobs | four gold-rimmed jade diamonds standing along its back, each with a lit facet |
| pl-dlz-5 | Karst Yawn | lilac limestone boulder (strata, ochre streaks, moss, fern, dangling root) on stubby feet | flat grey bottle with a hole | the den mouth yawning wide with stalactite/stalagmite teeth; a tiny sleeping bat inside |
| pl-dlz-6 | Mossback Monitor (rare) | slate-blue monitor lying on its jungle nap-leaf, neck raised, cream rosettes, moss cushion with two red toadstools, gold claw band, gold leaf midrib | recolour-like green lizard | polish shine streaks on back, neck and head plus sparkles |
| pl-cwy-1 | Ember Flake | cinder scale: ash crust on top, charcoal plates cracked apart by ember seams that get hotter toward the pointed tip | flat red hexagon, no glow | it stayed warm: glowing cracks, red-hot lower edge, heat ripples and drifting sparks |
| pl-cwy-2 | Slag Drip | molten slag poured over a riveted iron forge beam, stretching into a heavy glowing bulb with a white-hot core | red potion flask under a grey cap | takes its time: one molten hand still holds the beam; one droplet has just let go over a glowing puddle |

Perches use the same design simplified by hand at 36 px, with 2x3 pill eyes on a lighter ground. The cwy-1 perch's
face plate is pale ash so the eyes read, and the dlz-4 perch's gems are hand-placed 3x6 pixel diamonds, 5 px apart.

Weak spots left: the dlz-6 yard head is smallish next to the moss cushion; the dlz-3 gecko body is a bit flat in tone; the
dlz-5 fern frond is a little scratchy; the toadstools (dlz-6) and the bat (dlz-5) are only a few pixels at perch size,
by design.
