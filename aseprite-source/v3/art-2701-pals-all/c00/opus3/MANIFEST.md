# Puzzle Pals chunk c00, Opus richness pass (art-2701-pals-all/c00/opus3)

Richness pass on chunk 0 of `../../worklist.json`, built on `../opus2/`. 8 pals, each a yard sprite (64x64,
`c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills): 16 sprites as `.lua` +
`.aseprite` + `.png`. Same keys, callings and concepts. Siblings of `art-2701-batch3/pals/opus3`: 5-6 tone
hue-shifted ramps, upper-left light with one lower-right shade, rim light and cool bounce, material texture via
`O.tex`, one quirk plus a smaller closer-look detail. `_opus.lua` is the unchanged opus2 helper (tools only).
`HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white, 1px ink `#2b1c26`). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|
| mw-leaf-tuck | two teeth per lobe edge, branching veins, waxy flecks, toothed + veined fold with a curled red tip, heap-leaf midribs | lobes read as a starfish; plain fold | stem curling out of the heap like a tail; a maple key (samara) on the heap |
| mh-cob-scout | husk leaves with pale midribs and veins, darker kernel bases, bark grain on the stick | husk read as a cradle (now peeled leaves flopping out, tips hanging); faint tally slash (now bold, pale fresh notches) | one kernel missing (dark socket): the row it lost count at |
| mh-kernel-knock | pericarp streaks on the flanks, crinkle creases in each popcorn bloom, curled hull flakes with pale inner faces | heart-shaped outline and round perch (now a kernel wedge, softer split) | a butter drip running down the hull |
| mh-stitch-crow | two-part beak (lit upper, dark lower, nostril), violet-teal sheen on the nape, breast scallops, brim shadow on the brow, ticks every 3 px on the tape | thin beak, tiny tape ticks; opus2 painted lids over the locked eyes (now left whole) | ember cloth patch sewn on the wing with gold stitches (scarecrow mend) |
| mh-golden-ring | 13 broad plaited strands (seam, lit shoulder, shaded back) fading to smooth straw on the face band; chevron grain rows on the ears | busy rope texture; yard ears merged into a crown (now 5 fanned, gapped ears); crowded inked perch sheaf (now one bow-tie bundle with grooves) | ladybird on the braid; one ripe grain dropped by its base |
| mh-popcorn-moon | soft maria patches and more craters, crinkled popcorn with rim light | lower horn flat (now tapered to an upturned point); tiny pop ticks (now 3 px) | one unpopped orange kernel left in the burst |
| ss-palm-fidget | leaflet ribs, dry brown frond tips, cool bounce on fronds, curled breeze swooshes | lifted foot only 2 px up (now 6 px on a little leg); low-contrast mouth (now open grin with pale coconut-flesh teeth) | the coconut's three pores on its crown |
| ss-tide-tuck | cockle-shell dome with radiating ribs and growth line, paws holding the sand blanket, wind ripples, wet dark sand and foam wash | wave outweighed the pal (pal now the big central mass, wave a slimmer curl behind) | a pink starfish tucked into the sand too |

Weak spots left: mw-leaf-tuck perch top is a little spiky at 36 px; mh-popcorn-moon lower horn still sits in
deep shade; mh-golden-ring perch ears touch at the base; the samara (leaf-tuck) and unpopped kernel (popcorn-moon)
are only a few pixels, by design.
