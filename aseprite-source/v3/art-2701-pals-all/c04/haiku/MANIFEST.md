# Puzzle Pals, c04 Haiku first pass (art-2701-pals-all)

Eight pals from worklist.json index 4. Each pal has a yard sprite (64x64) and a separately hand-placed perch sprite (36x36), each with .lua, .aseprite and .png (16 pairs of files total). Run: `AppRun -b --script-param out=<dir>/ --script <name>.lua`.

| key | name | rarity | calling | knob | quirk |
|---|---|---|---|---|---|
| dw-oasis-hoop | Oasis Hoop | uncommon | seedkeeper | double | two dates hang in the hoop hole |
| dw-mirage-moon | Mirage Moon | rare | wayfinder | keyhole | sparkles, moon crescent |
| gc-calabash-cup | Calabash Cup | common | seedkeeper | round | a drop of rain sits by the gourd |
| gc-drum-tap | Drum Tap | common | bloomcaller | double | rain drops around the drum |
| gc-yam-nub | Yam Nub | common | brewroot | peg | sprout leaves on the peg, giggle sparkles |
| gc-shellstep | Shellstep | uncommon | rootwarden | double | cream speed lines (slow walk) |
| gc-canopy-loop | Canopy Loop | uncommon | bloomcaller | keyhole | vine loop tail and a flower |
| gc-parrot-pennant | Parrot Pennant | rare | thornblade | hook | pennant tail, sound sparkles |

Checks: HP.assertClean passes on all 16 (0 semi-transparent, 0 pure black or white). Eyes are locked on yard (eyeLocked) and small on perch (eyeSmall). Not wired into game/.
