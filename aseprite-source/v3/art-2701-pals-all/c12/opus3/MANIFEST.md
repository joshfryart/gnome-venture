# Puzzle Pals chunk c12, Opus richness pass (art-2701-pals-all/c12/opus3)

Richness pass on worklist.json index 12, built on `../opus2/` (same keys, names, callings, concepts, silhouettes).
8 pals, each a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall`
pills): 16 sprites as `.lua` + `.aseprite` + `.png`. Siblings of `c00/opus3` and `art-2701-batch3/pals/opus3`:
5-6 tone hue-shifted ramps (cool/plum darks, warm lights), upper-left light with one lower-right cel shade, rim
light + cool bounce, material texture via `O.tex`, 1px ink `#2b1c26`. `_opus.lua` is an unchanged copy of the
c00/opus3 helper. `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white). Eyes are untouched
locked eyes (opus2's cwy-6 painted lids over them; removed). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | richness added (texture, ramp, light) | quirk / closer look |
|---|---|---|---|
| pl-cwy-3 | Scorch Sliver | plum-to-peach ramp, scale striations + hot glints on the front, conchoidal ripples on the flank, heat-tempered orange band above the soot, chip notch in the left edge | smoke curl off the point / glowing crack in the char, two drifting embers |
| pl-cwy-4 | Spine Spark | indigo-to-ice steel, mottled forge scale low right, polish streaks, raised forged ridge and dark collar on every spike, split toes | sparkler burst on the stepped spike / six hammer dimples and a tiny flame maker's stamp on the belly |
| pl-cwy-5 | Ash Wreath | indigo-to-parchment ash, warm char deep in the lower twist grooves, fine crackle on lit strands, three twig knots breaking the ring silhouette, bark grain on charred ends, striped match head | unlit match held up like a candle / last ember with a warm halo, ash flakes drifting |
| pl-cwy-6 | Last Forge Flame | plum-to-butter flame, curling inner tongues, hot lick tips, rising sparks, hammered iron dish catching warm glow on its lip, ash crust on coals | dream bubble now ~2x size with a readable violet dragon (wing up, horn, fire puff) and a "z" / hot coal cracks |
| pl-sbs-1 | Silkthread Tuft | plum-to-pearl silk, finer spun fibres between the spiral strands, stray wisps, glossy sticky beads in the fluff | worry-cowlick: one open thread curling like a question mark (perch: open spiral) / leaf stuck to its flank, sticky bead thread below |
| pl-sbs-2 | Web Snag | lilac-to-ice silk with glossy wound-thread sheen and a cross-winding, two-tone glinting web threads, bark ridges + knot hole on the twig | red felt gnome hat (now soft and floppy, tip draped over the hook, felt flecks, stitched hem) / dew bead, gold-stitched patch on the hat |
| pl-sbs-3 | Buttress Tangle | plum-to-tan bark, hollow deepening at the back with root hairs, lichen flecks, scaly acorn caps with shine, strand sheen on the silk ball | acorn stash (perch: one bold 7x9 shaded acorn) / red mushroom with cream spots, loose thread end with a sticky bead |
| pl-sbs-4 | Eightlegs Clasp | navy-to-pearl silver with sheen streak and fine hairs, two-tone chevron saddle, bristle ticks on legs, head fuzz, bark ridges | raised wiggling leg / six tiny extra eyes, silk safety line down to the twig |

Opus2 weak spots fixed: sbs-1 thread loop (bag handle) is now an open question-mark curl; sbs-3 perch acorn is
one bold shaded acorn instead of a few pixels; sbs-4 perch legs are redrawn as a clean star of bent strokes that
never cross (three left, two right + the raised one, two short front legs clasping the twig); cwy-6 yard dragon
is about twice as big; sbs-2 hat no longer reads as a traffic cone.

Family check: cwy-3..6 stay a red shard, a blue steel spike-ball, a grey twig wreath and an orange flame in a dish;
sbs-1..4 stay a lilac fluff tuft, a pale blue hanging knot with a red hat, a cream ball in a root arch and a
plum/silver spider. No two share species, palette or pose.

Weak spots left: cwy-4 maker's stamp and sbs-4 safety line are subtle (closer-look only); sbs-4 yard legs still
read slightly cage-like (composition kept from opus2); cwy-5 perch twist grooves are lighter than opus2's.
