# Puzzle Pals c04, Opus second pass (art-2701-pals-all/c04/opus2)

Worklist index 4 (8 pals), redrawn from the Haiku pass in `../haiku/`. The names, keys, callings and concepts are the same, and the scripts are new. The style matches `art-2701-batch3/pals/opus3/` and `art-2701-opus/pals/`:
- per-pixel lit 5-6 tone ramps, with rim light and a cool bounce colour
- 1px ink outline
- `c:eyeLocked` on the yard sprite (64x64) and `c:eyeSmall` pills on the perch sprite (36x36)
- one quirk per pal, taken from its blurb

Each perch is hand-built at 36 px, with fewer and bolder details. `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white). The Haiku gold "knob" bumps were dropped, because they read as ears or buttons and the finished Opus pals do not draw knobs. Nothing was copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua` (`_opus.lua` = the opus3 helper, copied unchanged).

| key | read now | fixed from Haiku | quirk |
|---|---|---|---|
| dw-oasis-hoop | bound palm-straw hoop floating in a teal pool, face on the thick lower band, palm leaflets on top | the 2 dates in the hole read as a second pair of eyes; face half under water | a sprig of dates hanging in the hole (perch: 3 dates in a triangle) |
| dw-mirage-moon | honey-cream cradle moon with lavender shading, face on the belly, sparkles, heat shimmer | the thin crescent left no room for the face; a stray gold orb | a little camel on a dune, eye shut in a blink |
| gc-calabash-cup | open calabash bowl: pale cut rim, rainwater inside with a ripple, burnt triangle band, feet | plain orange pear read as a generic fruit | polite trickle over its lip into a seedling that bows |
| gc-drum-tap | goblet hand drum: skin head, rope rings, zigzag lacing, flared foot, one arm raised to tap | flat red box read as a toy chest or cake | a rain drop splashing on the skin |
| gc-yam-nub | knobbly mauve-brown tuber with eye-pits and root hairs, half out of cool soil, heart-leaf sprout, giggling open mouth | smooth brown blob read as a dumpling; soil merged with the body | garden trowel stuck in the soil beside it |
| gc-shellstep | tortoise mid-step: amber scuted dome, pale rim band, moss tufts, sage legs, a real head with the face | lid + log + gold disc was not one animal; the face was lost on a nub; speed lines said "fast" | gold pocket watch on a cord round its neck |
| gc-canopy-loop | scalloped leaf clump hanging by its vine, looped over a rope bridge; hibiscus; a waving leaf-hand; swing arcs | green ball + loose ring gave no "loop" or "swing" | small red parrot on the bridge plank, being greeted |
| gc-parrot-pennant | front-on scarlet macaw on a thorny branch, hooked beak open mid-shout, blue wings with a yellow band, striped swallow-tail pennant tail | side-on red gourd with a green patch read as a bowling pin; the flag was detached | sound arcs growing louder next to one small rain drop |

Weakest:
- parrot-pennant perch: the pennant tail shows only 4 rows below the twig.
- mirage-moon perch: the camel is a 9x10 hand-placed sprite that reads at 1x, but its blink is only a 2 px line.
- oasis-hoop perch: the dates fill most of the small hole.
- canopy-loop perch: the vine loop on the rope reads more as a knot than as a loop.
