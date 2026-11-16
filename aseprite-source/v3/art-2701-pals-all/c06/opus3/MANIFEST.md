# Puzzle Pals chunk c06, Opus richness pass (art-2701-pals-all/c06/opus3)

Richness pass on chunk 6 of `../../worklist.json`, built on `../opus2/`. 8 pals, each a yard sprite (64x64,
`c:eyeLocked`) and a perch sprite (36x36, drawn at that size, `c:eyeSmall` pills). That makes 16 sprites, each saved as
`.lua`, `.aseprite` and `.png`. Keys, callings and concepts are unchanged. Siblings of `art-2701-batch3/pals/opus3` and `c00/opus3`:
5-6 tone hue-shifted ramps, light from the upper-left with one lower-right shade, rim light and a cool bounce,
material texture via `O.tex`, one quirk plus a smaller detail for a closer look. `_opus.lua` is the opus2 helper with two
tool additions: `O.pat` (pixel-pattern part) and `O.inkAround` (1px ink edge where a small part crosses a
body). `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white, 1px ink `#2b1c26`). Not
copied into game/. Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua` (same for `-perch`).

| key | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|
| sp-chilli-chime | moss tufts all over (lit crowns, crevices), bark grain and a knot on the peg, twisted twine, chilli ridge and waxy streak, bells with a lit lip and dark mouth | perch chillis were 2-3 px red drops; now bold 3x7 hooked pods with a green calyx and stalk, inked over the body | one chilli on the right garland is still green |
| sp-stupa-snug | lotus-petal moulding ring and rain streaks on the limewash dome, studded gold band, fur strokes, twisted flag strings, printed block and frayed notch on each flag | - | a little butter lamp burning at its feet |
| sp-teal-ferry | woven straw hat (ring rows, cross-weave), plank seams, grain and pegs on the hull, hull reflection and lit wave crests, ripple ring under the fish, fish scales and tail rays, wet sheen on the skin | - | a marigold fallen overboard, floating behind the stern |
| sp-lofty-kite | diagonal cloth weave, hem band with gold stitches, bamboo node rings, twisted two-tone ribbon tail, strata and two pines on the ridge | - | a sewn saffron patch mending a blue panel; a tiny bird flying below (also looked down on) |
| br-petal-pinch | velvet berry skin (pinpricks, dimples), veined sprout leaves, ribbed weave and a dark opening lip on the pocket, blush base and vein on the petals | - | a dewdrop on the pinched petal |
| br-koi-kin | rim made of separate stones (seams, varied tones), caustic dashes on the water, lit scale crescents, fin rays | cousins were dashes at 1x; now 4 bold 7x3 fish (lit back, eye, tail fork, floor shadow, one with a cream patch), 2 bold 6x3 fish in the perch | a lily pad with a pink lotus bud |
| br-panda-puff | fur in 2 px strokes, paler muzzle, sheen on the dark fur, leaf midribs | faint bamboo nodes; now dark rings with a lit lip and a bulge, and pale sheath streaks | a new bamboo shoot beside its foot |
| br-pagoda-pin | tile courses and round tile-end caps on every eave, plank grain and knots (off the face), lattice window, cut stone blocks on the step; swallow-tail pennant with a cream dot | perch pennant touched the top edge; now the spire is shorter and the 4x2 pennant starts on row 3 (2 px margin) | a sparrow on the lowest eave tip, unbothered |

Weak spots left: the lofty-kite blue panels' weave is a little speckly at 2x and up; the stupa butter lamp and koi lotus bud are
only a few pixels by design; the perch sprites for chilli-chime and lofty-kite keep the opus2 wind/ridge
ticks at the canvas edge (margin 0 on one side).
