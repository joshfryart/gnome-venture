# Art audit (2026-11-10): todo section 5 vs the real files

Method: counts under `game/assets/img`, sha256 duplicates (none in `scenes/`), `tools/gen_*placeholder*`, `here_layouts.json` keys vs files, stand-in markers in `claude/tile-art-v3-proposal/`, git log / CHANGELOG, and 12 sample pictures looked at (here-town-ca, here-stop-inn, here-delve, home-cottage, door-cottage, resid-4, tree-house, yard-pals, two set pieces). Status: DONE = final art in the game; PLACEHOLDER = a file exists but it is a stand-in; MISSING = no art (the game falls back or draws without).

| Item (todo wording) | Status | Evidence | What is actually missing |
|---|---|---|---|
| Here scenes (~45 templates) | DONE | 46 `scenes/here-*.png` (town x15 regions, village, haven, wonder, delve, lair, 12 stop types + desert_adobe looks); 480x270, hand-drawn detail (viewed town-ca, stop-inn, delve); no duplicate hashes. `gen_here_placeholders.py` output is overwritten by real art | nothing. 8 layout keys have no `here-*` file but are covered: `generic` (falls back), `resid-4/6/8` (`resid-*.png`), `door` (`door-*.png`), `workshop` (`craft-workshop.png`), `treehouse` (`tree-house.png`), `yard` (`yard-pals.png`) |
| Residential street styles + houses | DONE | `resid-4/6/8.png` (4, 6, 8 house slots, dusk, final art), `home-*.png` x6 (cottage, burrow, treehouse, hut, stone, boat interiors) | optional: more than 3 street styles |
| Doors | DONE (shared) | `door-{boat,burrow,cottage,hut,stone,treehouse}.png`, final art | optional per-villager doors (`door-<slug>`): none. Lit/dark variants: one picture each |
| Villager 2.5D sprites | DONE | `sprite/npc-*` x81 = every villager (the game has 81 NPCs; "up to 151" in the old plan is obsolete); 69 minis redrawn 2.6.42; 82 portraits `ph/npc-*.png` | nothing. Rule: no human villagers |
| Treehouse cutaway + dressing | DONE | `scenes/tree-house.png` (final, viewed), `tree-dress-{banner,lights,rug,telescope}`, `tree-trophy-*` x6 | optional: 4 dressing layers exist, plan said 5/10/20/40 pals |
| Pal sprites (perch / yard size) | MISSING | no `assets/img/pals/`; `hub_pages.php:129` looks for `pals/<key>.png` and falls back to the puzzle GIF still | perch + yard sprites per Puzzle Pal. Pal Yard picture itself is DONE (`yard-pals.png`, viewed) |
| Trail event icons 32x32 | MISSING | `roadkinds/` has 5 icons, `trail/find-*` 8; no event icon set | 32x32 event/hotspot icons |
| Stop looks for 11 more types | PARTIAL | default look for 12 stop types and `_desert_adobe` for 11 types + market; `stop_looks.php` maps only 2 styles (maplewold NA/NWE/EE, adobe MENA/CA/ESA/CSA); only `market` has `grassland_maplewold` | maplewold-style looks for the other 11 types; styles for the other regions (EA, SA, SEA, WCA, CB, SE, OC). Fallback to the default look works today |
| Animal homes pre-v3, procedural yard pieces | MISSING / unverified | `animals/` 72 files, no v3 rollout note; hand-polish list in `tools/bake_*_art.py` | decide if wanted; not looked at in the game |
| Variety before/after pictures (9 pilot places), progress picture, header per adopt tier | MISSING | no files; `claude/todo-art-variety.md` is the only trace. `stoptiers/` (48) + `stops/camp-1..4` tier pictures exist | the 9 before/after pairs |
| Cat Fish lane E (pet shops) | DONE | 55 `cf-pet-*`, 11 `banner-*-pets`, busts + `pet_slots` installed 2026-10-30 (`claude/todo-archive.md`); `catfish_pets.php` | stale in todo |
| Cat Fish lane F (animation polish) | MISSING (optional) | `claude/todo-art-catfish.md` lane F unchecked | moving side-cat nap/bored, eye pixels on catch/nap frames |
| Weak items (46 left) | DONE (4 left) | `aseprite-source/v3/rollout/weak.txt` now 4 lines: ginseng, stone-wall-end, tomato, stuffed-peppers-goat | those 4 |
| Towns: coralscatter dome + tea house, monsoontangle, thornacre arch, blossomreach parasol | OPTIONAL | listed as "repaint if Josh dislikes" | Josh's call after a look |
| Route landmarks Maplewold (82 sprites) | DONE | `trail/obj/lm-2xx-*` (76 numbered) drawn in 2.5.66, rebaked 2.6.38 | the 2.5.66 nits (overdrawn edges, faint feathers, muddy syrup) |
| Ground art for desert / island / mountain / rainforest / wetland | DONE (island borrows coast) | 2.6.39 `ground_own()` painter art for mountain, wetland, desert, rainforest baked into 624 pictures; island stays on coast art by Josh's decision | island ground, only if Josh wants |
| 137 shared set pieces | PLACEHOLDER | all 137 are lump-and-post stand-ins from `landmarks_setpieces.py` (viewed `lm-desert-the-waystone-cluster`, `lm-forest-the-glow-moss-grotto`: a lump and a flag); no `landmarks_*.py` overrides any of them | real drawings, brief in `claude/trail-setpiece-art-notes.md` |
| P7: homes, tiers | DONE | `home-*` x6; `stoptiers/` 48 + `camp-1..4` tiers | - |
| P7: village pictures | MISSING (optional) | `villages/` holds 2 files (honeybrook, poppyburrow); villages use `here-village.png` | per-village pictures, only if wanted |
| P7: craftmap 14 | DONE | `craftmap/` 14 files; replaced by the workshop picture (2.6.41) | - |
| P7: acts 1,667 | DONE (stills + anim) | `acts/` 1,667 files, 829 are `*-anim*` | "redraw after models are final" is a later polish |
| P7: landing `shot-*` | DONE | `landing/` 26 files incl. 12 `shot-*` (light/dark pairs) | - |
| P7: `map/` 16px tiles | MISSING / unverified | `map/` holds 11 felt/hoop/pin pieces, `ph/tile-*` 24 path tiles | check what the plan meant |
| Animation layers (`<art>-anim-*`, workshop/street/door, seasons) | PARTIAL | `craft-anim-*` x13 live; acts have 829 anim files; no `wander-step-back.png`; no season variants of scenes | `wander-step-back`, street/door animation, scene season variants |

Counts: DONE 17 (incl. 2 nearly), PLACEHOLDER 1, PARTIAL 2, MISSING / optional / unverified 10.
