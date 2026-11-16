# Puzzle Pals c08, Haiku first pass (art-2701-pals-all/c08/haiku)

Eight pals from worklist.json index 8. Each has a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-built, `c:eyeSmall`). Built with the shared Hearth Pop lib (`v3/lib/hp.lua`) through the local `_h.lua` wrapper. `HP.assertClean` passes on all 16. Run: `AppRun -b --script-param out=<dir>/ --script <name>-yard.lua`.

| key | name | rarity | quirk |
|---|---|---|---|
| cs-snorkel-snip | Snorkel Snip | common | snorkel tube, a shell in each hand |
| cs-octo-ogle | Octo Ogle | common | gold trinket at a tentacle tip, sparkling |
| cs-anemone-nudge | Anemone Nudge | common | clownfish being nudged along by a tentacle |
| cs-claw-sail | Claw Sail | uncommon | sky-blue sail is a crab claw |
| cs-grotto-glim | Grotto Glim | uncommon | gold glow spots, "ooh" mouth |
| cs-keel-drift | Keel Drift | rare | gold-trimmed old shell, cream barnacles, a wink |
| pl-frt-1 | Rime Crumb | common | faceted frost crumb, open croaking mouth |
| pl-frt-2 | Puddle Croak | common | toad in a sea puddle, music notes drifting off |

Weakest: anemone perch fringe is faint at 36 px; Snorkel Snip perch shells are small. Opus passes to follow.
