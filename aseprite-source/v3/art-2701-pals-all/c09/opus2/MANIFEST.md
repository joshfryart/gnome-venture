# Puzzle Pals chunk c09, Opus second pass (art-2701-pals-all/c09/opus2)

Second pass on chunk 9 of `../../worklist.json`, built on the concepts in `../haiku/`. 8 pals, each a yard sprite
(64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills): 16 sprites as
`.lua` + `.aseprite` + `.png`. Style matches `c00/opus3` and `art-2701-batch3/pals/opus3`: 5-6 tone hue-shifted
ramps, upper-left light with lower-right shade, rim light and cool bounce, material texture via `O.tex`, one quirk
per pal from its blurb. `_opus.lua` is the unchanged c00/opus3 helper (tools only).
`HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white, 1px ink `#2b1c26`). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | pal | haiku weakness fixed | quirk (closer look) |
|---|---|---|---|
| pl-frt-3 | Thawdrop Pip | flat two-tone drop, blob mouth | glassy water ramp with window highlight + caustic; mid-yawn mouth with tongue, sleepy bead off the tip (frost fleck, wet gleam in the shadow) |
| pl-frt-4 | Frostwart Bumps | blue bush with purple warts | sage toad skin with spots and pale belly, four frost-capped warts; one wart has bumped up with bump ticks (tiny icicle) |
| pl-frt-5 | Barrow Peephole | flat rectangle with a target | arched plank door in barrow stones, snow on the arch, iron strap; two yellow eyes peek out of the frost-rimmed peephole (ring pull) |
| pl-frt-6 | Barrow Icecrown | zig-zag crown on a black stand | glassy ice crown, five icicle points, violet gems; croaking toad mouth with a green throat sac and croak ripples (bubble frozen in the tall point) |
| pl-cnd-1 | Crag Quill | lozenge on a pole (lantern read) | asymmetric bronze feather with rachis and barbs; flint spearhead lashed on with twine, fierce V brows (afterfeather wisps) |
| pl-cnd-2 | Ledge Feather | brown wedge, dirt-like dots | curved condor-violet feather with rachis and barbs over a crag ledge slab; dotted path loops from the ledge back to its quill (ragged split tip) |
| pl-cnd-3 | Updraft Fluff | peach lumpy blob | cream downy puff with combed tufts and strand texture, lookout tuft; "wow" mouth riding rising wind curls (a seed caught in the fluff) |
| pl-cnd-4 | Talon Clutch | purple ball on gold sticks | scaly mauve foot pad with ringed toes and pale horn talons hooked into a violet crag rock with gold seams; cracks under each talon (chip breaking off) |

Weak spots left: Crag Quill's afterfeather wisps read a little like legs; Talon Clutch's pad can read as a round
creature on a rock; Ledge Feather perch ledge is only a few pixels tall; Thawdrop Pip's yawn reads close to a "wow";
Barrow Icecrown perch gems are tiny at 36 px.
