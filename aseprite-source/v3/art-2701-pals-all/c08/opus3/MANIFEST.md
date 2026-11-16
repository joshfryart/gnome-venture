# Puzzle Pals chunk c08, Opus richness pass (art-2701-pals-all/c08/opus3)

This is a richness pass on chunk 8 of `../../worklist.json`, built on `../opus2/`. It covers 8 pals. Each pal has a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills). That makes 16 sprites, each saved as `.lua`, `.aseprite` and `.png`. Keys, names, callings and concepts are unchanged. The sprites are siblings of `art-2701-batch3/pals/opus3` and `c00/opus3`:
- 5-6 tone hue-shifted ramps
- light from the upper left, with one shade on the lower right
- rim light and a cool bounce
- material texture
- one quirk each, plus a smaller detail that rewards a closer look

`_opus.lua` is the opus2 helper, unchanged (tools only). `HP.assertClean` passes on all 16: 0 semi-transparent pixels, 0 pure black or white, 1px ink `#2b1c26`. Nothing was copied into game/.

Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|
| cs-snorkel-snip | violet-to-peach skin ramp with pores and wet glints, ribbed flippers with pale blade edges, mask glass reflection streak, snorkel bands and rim, scallop growth bands, whelk ridges | - | seaweed snagged on the snorkel; water drip on the chin |
| cs-octo-ogle | mottled chromatophore blotches and pale specks, pinker sucker-side underside, ringed suckers, rim-lit tentacles, faceted gem, shaded inner band on the ring | perch tentacles crowded at 36 px (now 4 splayed tentacles with clear gaps, the outer pair curling out, plus the ring arm) | a pearl stashed under its back curl |
| cs-anemone-nudge | tentacles with a translucent core stripe and a pale ring under each bulb, verrucae bumps on the column, pitted reef stone with algae and a barnacle, clownfish with ink-edged tail and rim light | - | a baby clownfish already tucked into the crown |
| cs-claw-sail | carapace granules and spots, brow ridge, dark claw tips, stalk joints, sail weave, lit spar edges, hull plank grain and lit end grain, boom lashings, twisted sheet line, sea foam | perch eyes low on short stalks (now 6 px splayed stalks with high bulbs) | a tan patch stitched onto the sail |
| cs-grotto-glim | inky-indigo-to-lilac ramp, crease at each segment, glow spots with a pale core and teal halo, teal glow spill from the lantern tail onto the shadow side, glowing antenna sockets | - (yard top margin stays 0 on purpose: threads hang from the cave roof) | two tiny glowing cave mushrooms |
| cs-keel-drift | growth rings inside every scute, moss stains, reticulated flipper scales with pale leading edges, hue-shifted shell and skin | plain plastron band (now hinged plates with dark seams, lit edges and a shaded underside, in yard and perch) | a striped remora riding under the plastron |
| pl-frt-1 (Rime Crumb) | inner cut-gem bevels on every facet, silhouette rim and lilac snow bounce, fracture streaks, frozen bubbles, branching crack with a lit lip, lit shard ridges, toe splits | - | a tiny fly frozen inside the ice |
| pl-frt-2 (Puddle Croak) | toad blotches, frost crust on the head top, belly speckle, splayed toes, the toad's reflection in the puddle, ice-crust crystal glints, lit note heads | - | a tadpole asleep in the puddle with a little "z" |

Weak spots left:
- The frozen fly (Rime Crumb) and the remora (Keel Drift) are only a few pixels, by design.
- The Grotto Glim perch mushroom is 3 px wide.
- The Snorkel Snip yard seaweed runs close to the tube, so it reads as a green stripe until you look closely.
