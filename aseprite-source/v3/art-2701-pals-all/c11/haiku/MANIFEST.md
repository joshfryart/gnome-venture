# Puzzle Pals chunk c11, Haiku first pass (art-2701-pals-all/c11/haiku)

Index 11 of `../../worklist.json`: 8 pals from the Dragonlizard Den and Forge of the Cinder Wyrm lairs.
Each pal = yard sprite (64x64, `c:eyeLocked`) + hand-drawn perch sprite (36x36, `c:eyeSmall`), as `.lua` + `.aseprite` + `.png`
(16 sprites). Built on `lib/hp.lua` directly. Single quick pass; Opus richness passes follow.
`HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white, 0 off-palette, ink `#2b1c26`).
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | calling / shape / knob | quirk drawn |
|---|---|---|---|
| pl-dlz-1 | Scalecrust Tot | rootwarden / corner-TB / hook | laughing grin, scale flake leaving the back |
| pl-dlz-2 | Tongue Flicker | bloomcaller / edge-TBT / tri | forked red tongue flicked at a fly it misses |
| pl-dlz-3 | Tail Tick | seedkeeper / inner-TBTB / double | tail up against a pebble with tick marks |
| pl-dlz-4 | Diamond Spur | thornblade / inner-TTTT / hook | four gold diamonds on the back, smug mouth |
| pl-dlz-5 | Karst Yawn | rootwarden / inner-TTBB / peg | stone chunk with the den mouth open in a yawn |
| pl-dlz-6 | Mossback Monitor (rare) | thornblade / whimsy-lizard / double | polish shine, gold stitched collar, moss tuft, gold horns |
| pl-cwy-1 | Ember Flake | thornblade / corner-BB / hook | cracked cinder with a gold warm core and sparks |
| pl-cwy-2 | Slag Drip | seedkeeper / edge-TBB / tri | stone crust on top, drip stretching from the base |
