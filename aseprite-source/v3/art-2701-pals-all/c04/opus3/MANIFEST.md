# Puzzle Pals chunk c04, Opus richness pass (art-2701-pals-all/c04/opus3)

This is the richness pass on chunk 4 of `../../worklist.json`, built on `../opus2/`. It covers 8 pals. Each has a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills), so there are 16 sprites, each saved as `.lua`, `.aseprite` and `.png`. Keys, callings and concepts are unchanged.

The sprites are siblings of `art-2701-batch3/pals/opus3` and `c00/opus3`:
- 5-6 tone hue-shifted ramps
- light from the upper left, with one lower-right shade
- rim light and a cool bounce colour
- material texture through `O.tex`
- one quirk per pal, plus a smaller detail that rewards a closer look

`_opus.lua` is the opus2 helper with one tool added, `O.tex2`, which re-tones part of a lit shape from a second ramp (used for cord bindings). `HP.assertClean` passes on all 16: 0 semi-transparent pixels, 0 pure black or white, 1px ink `#2b1c26`. Nothing was copied into game/.

Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|
| dw-oasis-hoop | plaited strand grooves twisting round the tube, dyed palm-fibre cord bindings (own ramp), wrinkled dates, leaflet veins, hoop reflection and ripple rings in the pool | perch: the dates filled the hole (now 2 small dates on a forked stalk, high, with the hole open below) | a date that floated off into the pool with its own ripple; a tiny dragonfly on a leaflet tip |
| dw-mirage-moon | ringed craters (dark wall, lit lip), soft maria, dune wind ripples, woven saddle blanket with fringe, hump fuzz; moon moved up-left so the camel stands clear | camel blink was a 2px line (now a bigger head, curved shut eye with a lash, 3 cream blink ticks; perch: shut lid with a flicked lash and 3 ticks) | a wayfinder star hanging on a thread from the right horn |
| gc-calabash-cup | lengthwise rind ribs, mottled flecks, richer pyrographed band (double line, triangles, dot row), fibrous cut rim, pool glint, seedling midribs | none listed; the band was simplified so it stays readable | an old crack mended with twine stitches; a drop resting on the seedling's leaf |
| gc-drum-tap | long carving grain and a knot off the face, mottled goatskin with a hairline edge, tension knots on the rope ring, painted leaf row on the foot; perch: open shout with a red tongue | none listed | a darker worn patch on the skin where its hand always taps; two smaller drops keep the beat |
| gc-yam-nub | hue-shifted skin, curved growth rings, eye-pits with lit lips, papery flecks, heart-leaf veins, lit soil clods and grey pebbles, a riveted trowel with handle grain and soil on its tip | none listed | the trowel's nick showing pale flesh; an earthworm poking out to see what is funny |
| gc-shellstep | concentric keratin growth rings in every scute, rim wear scuffs, head scales, neck folds, watch bezel ticks, a tiny mushroom in the moss | none listed | a little snail (lavender foot, swirl shell) riding up the back of the shell |
| gc-canopy-loop | layered overlapping leaves (lit lip, dark lower edge), teal-shifted shade, twisted rope fibres, plank grain and nail heads, vine bark ticks, leaves on the vine, dew on the hibiscus | the vine loop read as a knot (now a bigger open ring with the rope running through its hole, plus a tendril curl, in yard and perch) | the parrot raises a blue wing to wave back; a bite taken out of one rim leaf |
| gc-parrot-pennant | head-feather scallops, layered breast scallops, a green covert band between the yellow shoulder and the blue wing, covert edges and primary separations, pennant cloth folds and stripe seams, bark grain, lit thorns, a lit beak ridge | perch: the pennant tail showed 4 rows below the twig (bird raised 2px, tail is now a longer notched swallow-tail with red, yellow and blue bands) | one rain drop sitting on its crest feather |

Weak spots left:
- mirage-moon perch: the camel's head outline touches the moon's outline.
- canopy-loop perch: the leaf rows and the tendril curl are faint at 36px.
- calabash-cup: the rib lines are subtle.
- shellstep perch: the snail is only a few pixels and reads as a bump on the shell.
- drum-tap yard: the wood grain shows mainly on the flanks, because the face and lacing cover most of the bowl.
