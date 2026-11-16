# Puzzle Pals chunk c14, Haiku first pass (art-2701-pals-all/c14/haiku)

Single-pass drawings of worklist.json index 14: 8 pals, each a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, `c:eyeSmall`, hand-drawn, not a downscale) as `.lua` + `.aseprite` + `.png`. 16 sprites total. Built directly on `v3/lib/hp.lua` (own scripts, no copies of other pal folders). `HP.assertClean` passes on all 16. Not copied into game/.
Run: `AppImage -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | rarity | calling | shape / knob | yard design | quirk |
|---|---|---|---|---|---|---|
| pl-hcr-1 | Lightning Pinch | common | thornblade | corner-BB / hook | gold round body, two sky-blue claws, open sneeze mouth | sneeze puff with sparks at the top right |
| pl-hcr-2 | Shell Splinter | common | rootwarden | edge-TBB / peg | ember fan shell with a wood peg on top, two ridge lines | wind ticks on both sides |
| pl-hcr-3 | Gust Ribbon | common | seedkeeper | inner-TBTB / double | moss leaf ring (open loop) around a sky face plate | sky sparks around the loop |
| pl-hcr-4 | Whirl Pincer | uncommon | thornblade | inner-TTTT / tri | four ember pincer arms spun round a gold hub | corner motion ticks |
| pl-hcr-5 | Eye of the Storm | uncommon | bloomcaller | inner-BBBB / hook | stone-grey swirl ring around a calm sky hole | single moss leaf floating, wind streaks |
| pl-hcr-6 | Gale Islander | rare | wayfinder | whimsy-crab / peg | ember crab with a gold and moss island and two palms on its back | sea-breeze sparkles |
| pl-jdf-1 | Wing Jot | common | thornblade | corner-TT / tri | sea-blue faceted jade flake, vein lines, hum ticks | falling sparkle below, hum wave to the right |
| pl-jdf-2 | Reedleg Cling | common | seedkeeper | edge-TBT / hook | wood-brown pod gripping two moss reeds with three legs each | cream toe pads at the leg tips |

Distinctness: the two rings (Gust Ribbon, Eye of the Storm) differ in body (green leaf loop vs grey storm ring) and face plate colour. The two crabs-and-shells (Shell Splinter, Whirl Pincer) differ in species (fan shell vs four-arm spinner). Gale Islander is the only crab with an island. The jade flake and the reed-clinger are the only pals in this chunk built from a faceted gem and a two-reed grip.

Known weak spots (first pass, for the Opus passes): Whirl Pincer perch arms are 3 px and thin at 25%; Reedleg legs are 1 px and faint at 36 px; Eye of the Storm perch hole is small, so its eyes crowd; the Gale Islander palms are 1 px trunks and read as sticks at 50%.
