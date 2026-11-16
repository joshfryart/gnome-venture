# Puzzle Pals chunk c13, Opus richness pass (art-2701-pals-all/c13/opus3)

Richness pass on chunk 13 of `../../worklist.json`, built on `../opus2/`. 8 pals, each a yard sprite (64x64,
`c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills): 16 sprites as `.lua` +
`.aseprite` + `.png`. Same keys, names, callings and concepts. Siblings of `c00/opus3` and
`art-2701-batch3/pals/opus3`: 5-6 tone hue-shifted ramps, upper-left light with one lower-right shade, rim light and
cool bounce, material texture via `O.tex`, one quirk plus a smaller closer-look detail. `_opus.lua` is the unchanged
opus2 helper (tools only). `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white, 1px ink
`#2b1c26`). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | richness added | opus2 weakness fixed | closer-look |
|---|---|---|---|---|
| pl-sbs-5 | Dewweb Eye | silk ramp from dusk violet to a warm morning-pearl top; outer edge sags into scallops between the spokes; dew seeds where spokes cross rings; warm caustic on each bead's shaded side | read a little like a donut; now a web with a sagging edge | a fat drop hanging off the bottom; a silver spiderling on the right anchor thread |
| pl-sbs-6 | Silverback Spool | warmer wood with end grain and nail heads, an odd brighter strand in the silk wind, bristly hairs on the legs | notes were plain ink at 1x: now silver eighth notes with ink edges (stem on the head) | a paper tag tied to the peg with red thread, marked "8" |
| pl-gwk-1 | Fang Chip | plum-to-pearl enamel ramp, amber root with cementum flecks and a long groove, craze cracks off the chip, crater flecks on the moon | root read as a cap: the tooth is now one continuous spindle (root tapers to a blunt apex, no step), root only a shade warmer, tilted neck line | the enamel shine is a tiny crescent moon |
| pl-gwk-2 | Pawprint Cuff | violet-to-cream snow ramp, fine speckle grain, frost glints, ice-blue print dents | the open middle read as a dark band: now a taller well with a lit far wall falling into dark under a bright near lip | claw pricks above the four toes (a wolf print) |
| pl-gwk-3 | Moonpale Mantle | fur clumps instead of stripes, twill weave, moon-cyan sheen on the lit folds, chain across the collar | read like a sheet ghost: the fur collar is now the widest part (shoulder cape), cloth swings right in diagonal folds, front edge turned back to an indigo lining strip with gold trim, embroidered hem border, frayed threads at the torn corner | gold crescent badge; one grey wolf hair caught on the hem |
| pl-gwk-4 | Crown Points | plum-brown to lemon gold, engraved chevrons up each point, bezel-set faceted gems with table and glint, crimson velvet frays at both snapped ends | perch eyes were small against busy gold: the perch face now sits on a smooth polished oval plate framed by an engraved line; yard face zone kept smooth | two tooth dents chewed into the top edge (a wolf pup); empty gem socket |
| pl-gwk-5 | Howl Echo | twilight ramps (indigo, teal-cyan, violet bounce), sound-pulse grooves across the ring, deeper rim on the head | echo was a dotted blob: now has eyes and its own little "o" howl | tiny stars twinkling in the wisp's shaded side |
| pl-gwk-6 | Grey Wolf Whistle | blue-slate to warm pewter ramp, engraved fur lines and dark tips on the ears, solder seam round the chamber, engraved mouthpiece bands, braided cord with a lit twist, brow ridges | still a little cat-like: cast-fur cheek ruffs jut from both sides (wolf), ring and cord moved down | the cork pea peeking up through the sound slot; tiny crown stamp |

Set variety (pl-gwk six): ivory spindle tooth, wide snow well, fur-collared cloth cape, gold crown band with
spikes, blue wisp with a pulsing ring tail, pewter whistle with ears and ruffs. Different materials, colours and
silhouettes; none a recolour.

Weak spots left: Fang Chip perch chip notch is small at 36 px; Pawprint Cuff claw pricks are single pixels by
design; Moonpale Mantle collar's right side sits in deep shade; Grey Wolf Whistle brow ridges are subtle at 1x.
