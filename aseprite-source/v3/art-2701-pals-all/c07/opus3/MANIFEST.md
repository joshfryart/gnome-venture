# Puzzle Pals chunk c07, Opus richness pass (art-2701-pals-all/c07/opus3)

Richness pass on chunk 7 of `../../worklist.json` (index 7), built on `../opus2/`. 8 pals, each a yard sprite (64x64,
`c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills): 16 sprites as `.lua` +
`.aseprite` + `.png`. Same keys, names, callings and concepts. Siblings of `art-2701-batch3/pals/opus3` and
`c00/opus3`: 5-6 tone hue-shifted ramps, upper-left light with one lower-right shade, rim light and cool bounce,
material texture via `O.tex`, one quirk plus a smaller closer-look detail. `_opus.lua` is the unchanged opus2 helper
(tools only). `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white, 1px ink `#2b1c26`).
Not copied into game/. Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|
| br-torii-loop | fur tufts with lit tips, cheek/hip fluff on the silhouette, fur strands on the tail curl, lacquer grain on the gate, gold kasagi end caps, nuki wedges, fluffy belly edge | perch gate sat 1 px from the top edge (whole perch now 1 px lower, 2 px clear) | holds a sprouting seed in its fore paws (seedkeeper); cherry petal on its crown; a petal riding the hop loop |
| br-dragon-dart | washi fibre flecks and a dark pterostigma cell near each wing tip, moss fuzz on the head, gold thorax stripes, pale dorsal spots per segment, tucked legs, thorn gloss | - | the paper-maker's red hanko seal stamped on the lower hind wing |
| mt-stilt-stoop | peach-fuzz freckles, red hat band and frayed straw ends, two-board plank with seam, end grain and pegs, lit bamboo streaks and a leaf from a node, stilt reflections | - | a clay pot with a seedling on the stoop; an orange minnow in the canal |
| mt-seedling-plod | grass tufts breaking the moss silhouette, lit grass strokes on the crown, midribs on the rice blades, mud splashes and a wet line on the legs, ripple rings, a second note | - | a dewdrop on the tall crown blade; a paddy snail climbing a leg |
| mt-lotus-lump | fine veins fanning up the bud and petals, rim on the back petals, rain beads on the pad, curled back pad edge, splash crowns | - | a raindrop balanced on the bud tip; a baby bud poking out of the canal |
| mt-sky-lantern | washi fibres and glued panel seams, cool dusk rim on the upper-left paper, bamboo nodes and twine wraps on the hoop, second flame tongue, wet dark cloud belly with lit puff tops | yard eye discs were soft against the glow (now each sits in a 1 px ember ring) | a glued paper patch on the dome; a wish slip tied to the hoop |
| mt-fig-knot | head rebuilt as a knot: knobbly lumpy silhouette, two grained root coils framing a paler heartwood face, twisted root bands, a root lock over the brow, aerial roots dangling; stone lichen, crack and creeping moss; leaf side veins; fig speckles | head was a plain ball | a tiny fig wasp on the fig; a knot whorl on the cheek |
| mt-bill-brolly | scalloped feathers, separated primaries with pale tips, crown sheen, horn streaks, serrated bill edge and nostril, casque band, rain beads and a wet edge on the leaf, spotted frog with pale throat | perch frog eyes were 1x2 px (now 2x2 ink + cream glint on bigger bulges, wider grin) | a brass wayfinder compass with a red needle on a cord at its neck |

Weak spots left: torii-loop yard seed sits partly behind the paws and in the belly shade (reads as a small acorn,
not at a glance); dragon-dart legs are only a few dark pixels; fig-knot face patch is still a round shape inside the
root frame (now framed and paler, but not carved); lotus-lump bud veins are faint at 36 px; sky-lantern eye rings
read a little like spectacles up close.
