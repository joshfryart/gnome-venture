# Puzzle Pals chunk 2, Haiku first pass (art-2701-pals-all/c02/haiku)

Chunk 2 of `../../worklist.json` (0-based, like `c00`), which is the `olivewhistle` / `birchbramble` set. Eight pals, one quick Haiku pass in the Hearth Pop style.
Sizes: yard 64x64 (`c:eyeLocked`), perch 36x36 (hand-built at that size, `c:eyeSmall`). Each pal has `<file>-yard` and `<file>-perch`, each with `.lua`, `.aseprite` and `.png` (48 files).
Helper `_haiku.lua` is a copy of the batch3 Haiku helper; its lib path resolves to `aseprite-source/v3/lib`. Every sprite passed `HP.assertClean` (0 semi-transparent, 0 pure black or white). Not copied into `game/`.
Run: `AppRun -b --script-param out=<dir>/ --script <name>-yard.lua`.

| file prefix | game key | name | calling | rarity | shape / knob | design | quirk |
|---|---|---|---|---|---|---|---|
| net-nudge | ow-net-nudge | Net Nudge | wayfinder | common | corner-TB / round | round sea-teal body with a diamond net lattice | small ember fish tucked at its feet |
| olive-pip | ow-olive-pip | Olive Pip | bloomcaller | common | edge-TBT / double | olive-green fruit with two leaf knobs | a little olive tree planted beside it |
| jar-hum | ow-jar-hum | Jar Hum | brewroot | common | inner-TBTB / peg | terracotta oil jar with a cork peg stopper | hum waves ripple from both sides |
| sun-glint | ow-sun-glint | Sun Glint | rootwarden | uncommon | inner-TTTT / tri | gold sun disc with three rays on top | a sparkle wink in place of one eye |
| press-ring | ow-press-ring | Press Ring | seedkeeper | uncommon | inner-BBBB / double | thick stone hoop with two knobs and a wooden press lever | a drop of golden oil drips from its lower lip |
| harbour-leap | ow-harbour-leap | Harbour Leap | wayfinder | **rare** | whimsy-dolphin / hook | sea-blue dolphin leaping a stone breakwater, gold hook and fin dots, sparkles | splash ripples land in the bay |
| slushbelly | bb-slushbelly | Slushbelly | seedkeeper | common | corner-BB / round | pale-blue slush blob slumping into a puddle, seed on the snowball knob | one drip runs from the left eye |
| gander-gait | bb-gander-gait | Gander Gait | wayfinder | common | edge-TTB / keyhole | white goose with gold beak and feet, keyhole crest, marching | three gold chicks march behind it |

No two pals share shape+knob. Harbour Leap is the rare pal: gold hook, gold fin dots and sparkles (rare touch).

Weakest spots (quick pass, no fix round):
- net-nudge: the net lattice is strong at 50% and turns the body into a checked ball; the perch net is almost noise.
- olive-pip: the perch tree is cut close to the body and touches its edge.
- jar-hum: the hum waves are two-px dots, so at 50% they read as sparkle, not sound.
- sun-glint: only 7 distinct colours in the yard, and the perch rays are thin; the sparkle wink is the only face variation.
- press-ring: the perch lever is faint against the stone and the drip is one pixel.
- harbour-leap: the dolphin's eye is small and the head end is thin, so the face is weak at 36 px; the splash is dots only.
- slushbelly: the drip from the eye is nearly lost at 25%.
- gander-gait: the neck is thin in the yard; the perch chicks are 2x2 dots, and the perch head is small. The yard has 157 off-palette pixels (cream and gold tones), which is fine for this style but worth checking.
