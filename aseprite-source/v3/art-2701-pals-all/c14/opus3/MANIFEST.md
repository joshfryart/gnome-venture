# Puzzle Pals chunk c14, Opus richness pass (art-2701-pals-all/c14/opus3)

Third pass on chunk 14 of `../../worklist.json` (Lair of the Hurricane Crab, Lair of the Jade Dragon-fly), built on `../opus2/`.
There are 8 pals, and each has a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, drawn at that size, `c:eyeSmall` pills). That makes 16 sprites, each saved as `.lua`, `.aseprite` and `.png`.
The keys, callings, concepts and silhouettes are the same as opus2. This pass adds material texture, hue-shifted 5-6 tone ramps, light from the upper left with one cel shade to the lower right, rim light and a cool bounce line, and a small closer-look detail. It also fixes every weak spot listed in the opus2 manifest. The pals stay siblings of c00/opus3 and batch3/pals/opus3.
`_opus.lua` is the c00/opus3 helper, copied unchanged. `_c14.lua` adds a few tools on top of it: `nudge` (tone shift), `bump` (tubercle), `pit`, `rows` (small pixel grids) and `radial` (a dome shade with curved tone steps).
`HP.assertClean` passes on all 16: 0 semi-transparent pixels, 0 pure black or white, and a 1px ink outline in `#2b1c26`. Nothing was copied into game/.
To run one: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | richness added (yard / perch) | opus2 weak spot fixed | closer look |
|---|---|---|---|---|
| pl-hcr-1 | Lightning Pinch | Segmented carapace bands and burnt dark tips on both fingers, tubercles on the palm, a blue-white electric core down the bolt, a cool electric bounce / burnt tips, a band on each finger, a bolt core | The sneeze puff is now 12x9 with 3 tones, sits clear of the claw tip, and has spray droplets | A static curl standing up on its crown |
| pl-hcr-2 | Shell Splinter | Glossy dome shading whose tone steps curve (`O.radial`), a jittered field of granular carapace bumps, a gastric groove across the brow, growth lines in the pale fracture slab / bold bumps, groove, barnacle dot | The shading no longer steps diagonally across the dome | A barnacle riding on the rim, plus the old scratch |
| pl-hcr-3 | Gust Ribbon | A serrated outer edge along the ribbon, chevron side veins along its full length, a dew bead / midrib and vein ticks along the loop, cool bounce | (none listed) | A ladybird riding the ribbon |
| pl-hcr-4 | Whirl Pincer | Thorn spines on the outer edge of every arm (thornblade), tubercles on the arms and palms, a pebbled sandy hub with a rim groove / joint bands, one spine per arm | The perch pincers are bigger: fatter palms, longer fingers, a wide open gap and dark tips | Belly-plate seams and a chipped fingertip |
| pl-hcr-5 | Eye of the Storm | A billowing cumulus rim made of lobes with creases under each billow, puffy crest bands along the spiral arms, a yellow lightning flicker in the dark cloud / lobed rim, one crest crease per arm | It no longer reads as a smooth tyre | A green leaf whipped round in the loud wind |
| pl-hcr-6 | Gale Islander | Dark-tipped claws with tubercles, pebbled shell bumps, a seam under the shell edge, rim light on the legs, a grass tuft on the dune / claws with dark tips, foam flecks | On the perch, the claws are moved out and up, with air between them and the shell | A message bottle washed up on the beach, plus the starfish |
| pl-jdf-1 | Wing Jot | The veins are laid out in wing coordinates: a thick dark costa with a lit glass edge, long veins that run parallel from root to tip and converge there, regular ladder cross-veins (tighter in the costal field), clean two-tone glass, a pale margin, a rainbow sheen, a nodus notch and a dark-rimmed pterostigma / the same scheme, simplified | It no longer reads as crackle glass. The perch wing is broader, so the face has room | An amber pterostigma near the tip |
| pl-jdf-2 | Reedleg Cling | Pond-camouflage mottling, side spines on each abdomen segment, veined wing pads, fibre streaks along the reeds, a sage reed leaf peeling off the left reed / reed nodes, side spines, bounce | (none listed) | Pond ripples where the reeds stand, plus the dewdrop |

How the pals in each picture differ (unchanged from opus2):
- Hurricane Crab: a yellow lightning claw on a bolt; a domed orange shell fragment; a green leaf ring; a red four-arm pinwheel; a grey storm cloud; a coral crab carrying an island.
- Jade Dragon-fly: a glass wing fragment, and a whole nymph on reeds.

Weak spots that remain:
- Wing Jot reads much more like a wing, but the yard sprite is still a dense green lattice. From far away it can read as a long leaf.
- The Whirl Pincer yard claws are busy, and the thorn spines are only 1 px nubs.
- The Gale Islander message bottle and the Gust Ribbon ladybird are tiny (3-4 px). That is intended for a closer look, but they are easy to miss.
- The Shell Splinter bumps give the dome a slightly biscuit-like grain.
