# Puzzle Pals chunk c00, Opus second pass (art-2701-pals-all/c00/opus2)

Second pass on chunk 0 of `../../worklist.json`, built from the Haiku first pass in `../haiku/`. 8 pals, each a
yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills), 16
sprites as `.lua` + `.aseprite` + `.png`. Same keys, callings and concepts as the first pass. The style now matches
`art-2701-batch3/pals/opus3` and `art-2701-opus/pals`: 5-6 tone ramps lit from the upper left (pillow/sphere
normals), rim light, cool bounce, material texture through `O.tex`, one quirk taken from the blurb.
`_opus.lua` is a copy of the opus3 helper (tools only). `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure
black/white). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | changes from the first pass | quirk (blurb) | weak spots left |
|---|---|---|---|
| mw-leaf-tuck | lens blob became a real maple leaf: toothed lobes, midrib and side veins, sunk in a heap of shaded fallen leaves (red, crimson, orange, brown) | the right lobe folds forward over the heap, pale underside up, tucking itself in | at 1x the lobes read a little starfish; the fold is a plain pale flap |
| mh-cob-scout | kernel grid is now clean rows of lit kernels with dark gaps, softened round the face (no noise); corn-silk tuft; husk peeled down front and back with lengthwise veins; husk arms | notched tally stick (four and a slash) held in a husk hand | the husk reads as a cradle more than peeled leaves; the slash on the tally is faint |
| mh-kernel-knock | glossy kernel with a pale tip cap and a split hull; the puff is cream popcorn with warm butter shadows (no blue), hull flakes curling off | raised nub fist with two knock ticks | the kernel outline is slightly heart-shaped; the perch body is rounder than a kernel |
| mh-stitch-crow | crow-black slate ramp with a violet sheen (no longer purple); woven straw hat with ember band set level; folded wing with primaries; straw out of the wing cuff; half-lidded serious eyes. Perch: smaller hat, pale eye rings so the pills read on black | cream measuring tape round its neck, end hanging | yard beak is thin; tape ticks are small |
| mh-golden-ring | twisted-straw hoop with torus lighting; the hole is much larger, face on a smooth lower band | a wheat sheaf with an ember tie fills the hole, ears poking over the top | the rope twist is busy at 4x; yard ears merge into a crown more than five separate ears; perch stalks carry heavy ink |
| mh-popcorn-moon | fatter crescent with the inner cut moved right so the face sits on a wide belly away from the edge; soft craters, gloss streak, three sparkles (rare) | cream popcorn bursting off the upper horn, two pieces flying with pop ticks | the lower horn has a flat underside; the pop ticks are tiny |
| ss-palm-fidget | coir hair strokes on the coconut; fronds are broad blades slit into leaflets (no longer thin sticks), bold at 36 px too | one foot lifted mid-tap with tap ticks, breeze swooshes behind (replaces the frond loop, which did not read) | the lifted foot is only 2 px higher than the planted one; the mouth is low-contrast on the dark husk |
| ss-tide-tuck | the blue block is now a breaking wave: a hook-shaped curl with an open barrel, lit inner face, dark back, cream crest foam and a spray tip; ribbed sand-gold dome dug into a grainy sand mound up to its chin | the wave about to break over it (why it tucks) | the wave takes more of the frame than the creature; the sand mound is a flat wedge on the left |

Weakest overall: mh-golden-ring (busy rope texture and crowded sheaf on the perch), then ss-tide-tuck (wave
outweighs the pal).
