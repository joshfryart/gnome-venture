# Puzzle Pals chunk c05, Opus richness pass (art-2701-pals-all/c05/opus3)

Richness pass on chunk 5 of `../../worklist.json`, built on `../opus2/`. 8 pals, each a yard sprite (64x64,
`c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills): 16 sprites as `.lua` +
`.aseprite` + `.png`. Same keys, callings and concepts. Siblings of `art-2701-batch3/pals/opus3` and
`c00/opus3`: 5-6 tone hue-shifted ramps, upper-left light with one lower-right shade, rim light and cool bounce,
material texture via `O.tex`, one quirk plus a smaller closer-look detail. `_opus.lua` is the unchanged opus2
helper (tools only). `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white, 1px ink
`#2b1c26`). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua` (same for `-perch`).

| key | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|
| th-coffee-crumb | plum-to-amber roast ramp, curved roast streaks, 3 px oily gloss spec, silverskin fleck in the crease; felt nap, woven band, darker brim underside; paddle grain + scorch; dark soles | (none listed) | two red coffee cherries and a leaf tucked in the hat band |
| th-flamingo-flick | U-shaped scalloped feather rows with lit tips, barred neck, pale covert tips, lit primary edges, scaly knee bands, broken pink reflection and glints in the waterhole | (none listed) | a tiny curled brine shrimp in the water |
| th-termite-tower | grain courses with lit knobs, rain runnels, hue-shifted laterite, grey pebble at the foot | crown read: right chimney is now a rounded buttress (yard); perch has a leaning spire, one low rounded knob and a smooth buttress, so the top is one lopsided point | a second termite peeking out of a vent, antennae up |
| th-acacia-antler | leaflet chevrons with blue-green shade, bark grain on the antlers, paired thorns, offset woven nest rows with loose straw ends | perch nests pulled in (3 px margin) and the perch keeps one nest per antler (inner nests dropped: cleaner at 36 px) | two yellow acacia puffball blossoms in the leaves |
| th-kopje-keeper | violet-to-cream granite lit as spheres, feldspar and mica flecks, orange + sage lichen, crack under the top boulder, fanned grass tufts | lizard small: agama now bigger and doing its push-up (yard), perch agama 2 px thick, 14 px long with a 3x3 orange head | a tiny succulent rosette growing from the crack |
| th-tall-tiptoe | patches darken toward their edges, fur ticks on the cream net, two-tone mane, lit hooves, leaflet pairs and a thorn on the sprig | (none listed) | a red-billed oxpecker riding on its back (also on the perch) |
| sp-saffron-snip | hue-shifted gold, petal veins, scissor bevel and loop glints | crown read: cap is now a tilted goblet crocus (rounded petals, green receptacle, two slim leaves, drooping stigma threads); perch scissors enlarged (6-7 px blades, holed brass loops, lit rivet) | a tiny woven basket of picked threads at its foot |
| sp-yak-yonder | plum-to-umber fur, wavy flank strands and lit fringe tips, gold diamond motifs in the blanket, horn growth rings, sack seams, flag fold | (none listed) | a brass bell under the chin (also on the perch) |

Weak spots left: termite-tower perch still a little plain at 1x (texture kept sparse to hold the face);
flamingo yard beak reads chunky; saffron-snip yard stigma threads arc like antennae; the shrimp, succulent and
termite-in-vent are only a few pixels, by design.
