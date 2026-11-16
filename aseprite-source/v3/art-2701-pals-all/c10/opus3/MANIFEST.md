# Puzzle Pals chunk c10, Opus richness pass (art-2701-pals-all/c10/opus3)

This is the richness pass on chunk 10 of `../../worklist.json`, built on `../opus2/`. It has 8 pals. Each one has a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, drawn by hand at that size, `c:eyeSmall` pills), so there are 16 sprites, each as `.lua`, `.aseprite` and `.png`.
Keys, callings and concepts are the same as opus2. The pals are siblings of `c00/opus3` and `art-2701-batch3/pals/opus3`: 5-6 tone hue-shifted ramps, light from the upper left with one lower-right shade, rim light and cool bounce, material texture through `O.tex`, and one quirk plus a smaller closer-look detail.
`_opus.lua` is the opus2 helper, unchanged (tools only).
`HP.assertClean` passes on all 16: 0 semi-transparent px, 0 pure black or white, 0 isolated px, and a 1px ink outline `#2b1c26`. Every sprite has a margin of at least 1 px. Nothing was copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|
| pl-cnd-5 | lit lip on the front rim, pale cut twig ends in the weave, forked stray twig, darker egg speckles, puff seams | cloud bumps were hidden by the nest. The cloud is now bigger on the left, with 3 clear puffs and seams | grey condor down caught on the rim (beside the pink bloom) |
| pl-cnd-6 | violet-teal oil sheen along the upper shaft, lit barb ridges, grey barb tips on the white patch, 3 frayed gaps | perch had a 1 px bottom margin (now 2 px) and a tiny trailing-edge notch (now wider, plus a second notch) | a curl of grey down riding the updraft swirl |
| pl-owl-1 | crisp dark chevron bars that bend toward the tip, saw-tooth barb fringe, 4 V splits, dark shaft streak, pale buff tip, new plum-brown ramp | read as bread or a pinecone at 25%. The bars are now high-contrast and the edges split and fringed, so it reads as a barred feather | waxy blue-grey pinfeather sheath flake on the quill |
| pl-owl-2 | rock strata on the broken slab, glow line along the snap, stronger craters (dark lip, lit lip, sunken floor), second maria field, moondust glints | (none listed) | ray splash round a young crater; the talon scratches are kept |
| pl-owl-3 | ply-twist slants on every strand, fibre fuzz on the silhouette, ribbed scarf hem, knit V columns | (none listed) | gold bead threaded on the loose thread end |
| pl-owl-4 | crossing lit straw stalks, scalloped downy belly, pale-tipped wing stubs, darker facial disc rim, claw tips | (none listed) | a curl of its own eggshell in the straw |
| pl-owl-5 | frost glints and wind-drift ripples in the snow, faceted crag with snow caps, shimmer streaks on the halo, scalloped owlet crowns, second sparkle | perch halo had a 1 px bump at the top (single-pixel rows are now trimmed) | right owlet's tiny wing tucked out over the lip |
| pl-owl-6 | barb lines with lit ridges, ragged wicking edge on the aurora dip, light flecks glinting in the dip, ivory shaft through the dip | (none listed) | one barb has wicked a thin mint streak far up the plume |

The six owl pals are still clearly different from each other: a barred brown feather, a moon chip, a yarn ball, a grey owlet, a snow hollow and a white aurora plume. Each has its own silhouette, ramp and props.

Weak spots left:
- pl-owl-3: the yarn ball is busier now that the twist texture is in. The face patch still reads at 36 px.
- pl-owl-6: the mint barb streak and pl-cnd-5's down wisp are only a few pixels, by design.
- pl-owl-2: it stays low-contrast overall (moonlight ramp).
