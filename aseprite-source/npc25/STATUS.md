# npc25 verification status

| species | PASS/FAIL | visual concern |
|---|---|---|
| field-mouse | PASS | none; straw hat and tool read clearly in all three views |
| wood-mouse | PASS | acorn-cap hat is small at 1x; reads as a mouse but the cap detail may blur |
| shrew | PASS | long snout is subtle in the front view |
| mole | PASS | side-view paws and arms are small; the tiny claws may not read at 1x |
| dormouse | PASS | none |
| gecko | PASS | none |
| cricket | PASS | none; legs are busy but silhouette holds |
| frog | PASS | none |
| grasshopper | PASS | none |
| hare | PASS | none |
| toad | PASS | none |
| beetle | PASS | none |
| ladybird | PASS | round 2 (Opus): back view now reads head / neck stub / cream-cornered pronotum / shell as separate parts (smaller round head, narrow neck pinches the outline, shaded sphere with one highlight cluster, no mouth-like nape line); head pale rim band replaced by one compact upper-left highlight plus a brim cast-shadow row in all views; front/side body unchanged |
| stag-beetle | PASS | shield is hidden in back view by design (QUIRK_HIDDEN) |
| stick-insect | PASS | round 2 (Opus): akimbo forelegs keep the thorax clear; A stance (middle tibiae splay out, rear feet tuck in) replaces the boxed legs; side knees peak with dome knobs; 2 px deep dashed stripe reads at 1x. Still weak: side rear legs and abdomen stack into one mass; front tibiae read thin at 1x (before copies in `stick-insect/before-r2/`) |
| snail | PASS | redrawn round 2 (Opus): bigger front face (muzzle glint, plum nose, open smile, cheeks spaced apart), front/back body is one smooth bell into the foot (no stepped mound, no dark right wall), wider hat brims with a plum contour that separates the straw from the shell; side face still small |
| bumblebee | PASS | none |
| butterfly | PASS | none |
| dragonfly | PASS | none |
| firefly | PASS | none |
| moth | PASS | none |
| wren | PASS | none |
| bat | PASS | none |

## Full pathway check (2026-11-17)
Stage 1 (spec): 25 of 25 species have `specs/<species>.md`. Stage 2 (scaffold): 25 of 25 have `lib/species_<species>.lua` (no draft-helper calls left). Stage 3 (art): all drawn; snail, stick-insect and ladybird redrawn by Opus this session (before copies in `<species>/before/`). Stage 4 (check): `python3 check.py <species>` run on all 25: RESULT PASS 25 of 25.
