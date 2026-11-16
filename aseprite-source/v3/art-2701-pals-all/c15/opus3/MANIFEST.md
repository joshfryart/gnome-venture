# Puzzle Pals chunk c15, Opus richness pass (art-2701-pals-all/c15/opus3)

Richness pass on chunk 15 of `../../worklist.json` (the pl-jdf and pl-bjq picture families), built on `../opus2/`.
Same keys, names, callings and concepts. 8 pals, each a yard sprite (64x64, `c:eyeLocked`) and a perch sprite
(36x36, hand-drawn at its size, `c:eyeSmall` pills): 16 sprites as `.lua` + `.aseprite` + `.png`. Siblings of
`c00/opus3` and `art-2701-batch3/pals/opus3`: 5-6 tone hue-shifted ramps, upper-left light with one lower-right
shade, rim light and cool bounce, material texture, one quirk plus a smaller closer-look detail. `_opus.lua` is the
unchanged opus2 helper (tools only). `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white, 1px
ink `#2b1c26`). Not copied into game/. Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|---|
| pl-jdf-3 | Jade Shimmer | blue-teal to lime jade ramp, cloudy jade mottling, milky vein, glowing star facets on the shade side, gold flecks in the girdle, rim + bounce on gem and feet | lower facets were dark; now mid tones with only a thin dark girdle band lower-right | the sun through the gem throws a tiny rainbow on the ground (and a glitter fleck on its cheek) |
| pl-jdf-4 | Jadewing Quartet | hue-shifted jade, crown scale flecks, a lit shoulder on each tail segment, lilac-pink sheen bands and smoky roots on the glass wings, gold thorax band, gold antenna tips | (none listed) | a nick bitten out of the front wing's back edge from all the jostling |
| pl-jdf-5 | Lantern Eye Pair | curved bamboo ribs as well as hoops, paper fibre speckle, gold cap studs, gold tassel knot, lit bamboo nodes, a bamboo leaf on the crook, gold-ringed dragonfly | (none listed) | a mended paper patch with dark stitches, low left on the lantern |
| pl-jdf-6 | Lotus Perch | lilac bounce + rim on every petal, paler petal bases, waxy flecks and veins on the pad, wing glints | perch dragonfly was a few pixels; now a 17-px dragonfly (round head, shut eye, gold-ringed tail, folded wings) lying across the head, bigger "z" | a dewdrop on the left side petal (perch: on the pad) |
| pl-bjq-1 | Tentacle Wisp | plum-to-peach jelly ramp, lit shoulder after every ring groove, scalloped frill hem, rim + lilac bounce | stinger beads were 1-px marks; now 2x2 lilac sea-glass beads (glint, mid, violet shade) that stand out in hue | it keeps one seed tucked in its spiral curl (seedkeeper) |
| pl-bjq-2 | Clownfish Peek | plum-red to butter orange ramp, crown scale scallops, ink-trimmed fin tips, lit crests on the brain coral | perch fins hid behind the coral; now two clear orange fins with ink-trimmed tips hook over the coral rim | a tiny spiral sea snail creeping over the right coral head |
| pl-bjq-3 | Bell Bead | indigo-to-ice-mint sea glass, frosted speckle, trapped air bubbles, ribbon tails, clapper glint | (none listed) | the queen's mark: a tiny gold crown pressed into the lip band (also on the perch) |
| pl-bjq-4 | Gold Spike Tiara | umber-to-cream gold, bright ridge line and two engraved rings on each spike, lilac-pink thin-film sheen on the bubbles, gold band at the spike feet (perch) | spikes were slim and subtle; now broad blades with a hard lit-left / deep-right bevel in both sizes | a tiny bubble stuck on the tip of the right inner spike (yard) |

Family check: jdf = faceted gem / dragonfly chick / paper lantern / lotus; bjq = tentacle / fish / bell / tiara.
Each has its own species, material, props and pose; none is a recolour.

Weak spots left: pl-jdf-5 meridian ribs are faint against the glow and the paper speckle is a little grainy;
pl-bjq-2 yard brain coral texture is busy; pl-jdf-3 milky vein and pl-bjq-3 trapped bubbles are only a few pixels
(by design); the perch versions drop some closer-look details (lantern patch, spike-tip bubble, rainbow is 4 px).
