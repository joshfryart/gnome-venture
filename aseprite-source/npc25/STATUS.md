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
| ladybird | PASS | redrawn: grey highlight ramp on head, belly and legs, light feet, neck gap and cream pronotum marks now separate the body from the ground shadow; back-view head is still a fairly flat dark disc |
| stag-beetle | PASS | shield is hidden in back view by design (QUIRK_HIDDEN) |
| stick-insect | PASS | stage-3 redraw: 2 px limbs with knee knobs, brighter lilac body (+#c9b6f2 highlight) with dashed centre stripe and rings; front thorax still busy where forelegs cross middle femurs |
| snail | PASS | redrawn (stage 3 rework): soft glossy body on a frilled foot, big spiral shell in all views, long eyestalks; front face is small and the front body mound is still a bit lumpy |
| bumblebee | PASS | none |
| butterfly | PASS | none |
| dragonfly | PASS | none |
| firefly | PASS | none |
| moth | PASS | none |
| wren | PASS | none |
| bat | PASS | none |

## Full pathway check (2026-11-17)
Stage 1 (spec): 25 of 25 species have `specs/<species>.md`. Stage 2 (scaffold): 25 of 25 have `lib/species_<species>.lua` (no draft-helper calls left). Stage 3 (art): all drawn; snail, stick-insect and ladybird redrawn by Opus this session (before copies in `<species>/before/`). Stage 4 (check): `python3 check.py <species>` run on all 25: RESULT PASS 25 of 25.
