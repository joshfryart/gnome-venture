# Puzzle Pals chunk c13, Opus second pass (art-2701-pals-all/c13/opus2)

Second pass on chunk 13 of `../../worklist.json`, built on `../haiku/`. 8 pals, each a yard sprite (64x64,
`c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills): 16 sprites as `.lua` +
`.aseprite` + `.png`. Same keys, names, callings and concepts as the Haiku pass. Style matches `c00/opus3` and
`art-2701-batch3/pals/opus3`: 5-6 tone hue-shifted ramps, upper-left light, rim light and cool bounce, material
texture via `O.tex`, one quirk per pal from its blurb (plus a small closer-look detail on the yard). `_opus.lua` is
the unchanged c00/opus3 helper (tools only). `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure
black/white, 1px ink `#2b1c26`). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | design now | Haiku weakness fixed | quirk (blurb) | closer-look |
|---|---|---|---|---|---|
| pl-sbs-5 | Dewweb Eye | silk web wreath hanging on two anchor threads, a see-through gap set high, bright spokes and rings over dusky gaps, dense silk pad holding the face | face sat on a purple blob in the hole (gap did not read as a gap; disc read as a porthole); square 2x2 beads | eight round dew beads ring the gap, one flashes a big star glint | pink petal snagged in the silk |
| pl-sbs-6 | Silverback Spool | upright spool of wound silver silk between dark wood flanges (end grain, top peg), eight jointed charcoal spider legs splaying from behind | sideways log with 1px stick legs, face squashed in a thin band | humming "o" mouth, notes drifting off the top left | loose silk end curling at the foot |
| pl-gwk-1 | Fang Chip | curved ivory wolf canine balanced on its point, narrower dusky root above a wavy enamel line, enamel streaks | flat beige triangle (read as pizza slice/carrot) | crescent moon out, cross brows, wavy growl with a tiny fang, growl ticks | the chip notched out near the tip (dark break, lit lip) |
| pl-gwk-2 | Pawprint Cuff | short wide ring of packed snow seen from above: dark open middle, lumpy fluffed rims, cool shading, snow grain | marshmallow pillow; print read as a grey blob | one perfect pawprint pressed in (heel pad and four toes as real dents) | tiny snowflake on the rim |
| pl-gwk-3 | Moonpale Mantle | scrap of the king's mantle: shaggy grey wolf-fur collar with gold moonstone clasp, pale lilac cloth in folds, hem torn on a slant, indigo lining at the ripped corner | saturated purple banner (not pale), porthole moon on the belly | full moon top right, one-pixel moon-glow halo on the moon-facing side, glow motes | gold crescent badge stitched on the cloth |
| pl-gwk-4 | Crown Points | snapped-off crown segment: curved worn-gold band with jagged ends, exactly four ball-tipped faceted points, ruby and sapphire, engraved dot rows | a whole five-point crown | old: the fourth point is bent over sideways | one empty gem socket |
| pl-gwk-5 | Howl Echo | twilight-blue sound wisp with a flame tip and a big "O" howl, its tail ringing once right round behind it | plain teal ball with two arcs; "comes back smaller" missing | the ring's end comes back as a small echo wisp with its own tiny howl | two sound ripples off the howl inside the ring |
| pl-gwk-6 | Grey Wolf Whistle | old pewter pea whistle: round chamber with pale wolf muzzle and nose, tapered mouthpiece with sound slot, two tall pricked wolf ears, red braided cord and gold tassel on a ring | cat-like grey head with a box on its chin (no whistle read) | blow marks on the left, pale answering howl arcs coming back from the right | tiny crown stamped on the mouthpiece |

Set variety (pl-gwk six): fang (tooth, ivory, tall and pointed), cuff (snow ring, wide and low), mantle (draped
cloth with fur collar), crown segment (gold band with spikes), howl (blue wisp with a ring tail), whistle (pewter
pea whistle with ears). Different species, materials, colours and silhouettes; none a recolour.

Weak spots left: Moonpale Mantle can still read a little like a sheet ghost at 50%; Fang Chip's dusky root can read
as a cap; Pawprint Cuff's open middle reads as a dark band more than a deep hole; Crown Points perch eyes are small
against the busy gold; Silverback Spool notes are plain ink at 1x.
