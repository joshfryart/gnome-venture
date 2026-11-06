# Art plan for 2.5.63 (one after the other)

Rules: Sonnet medium for items, Opus medium single pass for scenes (no rich pass, no fix rounds). Same filenames and sizes, drop-in. Pink 2px border for weak ones. Source `aseprite-source/v3/`. After each step: `export_game.py`, lint (`php tools/lint_here.php`), commit. Bump to 2.5.63 and CHANGELOG once at the end, then `tests/build_update.sh`. No PR unless asked.

## Order

| # | Step | Count | Method | Cost est. |
|---|---|---|---|---|
| 1 | Test one picture, one portrait, one 2.5D model (Sonnet medium vs existing) | 3 | `rollout/items-misc.js` | small |
| 2 | Ginseng Seed v3 fix, export | 1 | seedgen | ~10k |
| 3 | Weak seeds redo (tiny seeds, look-alikes) | part of 179 | `items-seed.js`, groups of 12 | ~10k each |
| 4 | Weak non-seed items redo (stage-*, stone-wall-*, muddy) | rest of 179 | `items-lean.js`, groups of 6 | ~25k each |
| 5 | Scene weak spots: camp flames, ferry dock, wild-trail trees, lair-snowcrown-peak, turtle scutes (2), banner-desert, trek-me, vig-pick, map-world props, 4 town spots | ~14 | Opus medium, one scene each | 110-150k each |
| 6 | 4 kind cards `act-craft/collect/tend/contest` | 4 | single pass | small |
| 7 | Stop looks: mill, ferry, inn, jetty, herb, orchard, shrine, spring, tower, workshop, camp | 11 | parametric (copy `pilot-market.lua`, new PALETTES entries) | ~130k per type |
| 8 | Village + haven hero scenes, delve scenes, Maplewold Beaver Pond | ~4+ | gate view, hero scale | 110-150k each |
| 9 | Villager rule check: 82 portraits + `ph/npc-*` no humans, redesign as creatures | 82+ | after step 1 test | big |
| 10 | Gnome walk set: front/back/side + 6-frame walk; fix hedgehog, eye contrast | 1 rig | `v3/gnome-dir/` | medium |
| 11 | Homes (6), tiers, village pictures | ~12+ | single pass | medium |
| 12 | Cat Fish: 55 pet sprites, 11 banners, 11 busts, nap frames, props | 77+ | `todo-art-catfish.md` | big |
| 13 | Variety: 9 before/after place pictures, stage progress | ~19 | `todo-art-variety.md` | medium |
| 14 | Flower heads (19, tintable), 41 odd-size UI, animal homes | ~60 | needs tint rig first | medium |
| 15 | Animation layers, `wander-step-back`, treehouse trophies, pal perches | many | with anim plan | big |
| 16 | Craftmap 14, 1,667 acts, landing `shot-*`, `map/` tiles | huge | NEEDS DECISION | defer |

## Ship line for 2.5.63
Realistic in one release: steps 1-8 (plus 10 if the walk cycle works). Steps 9, 11-16 roll to 2.5.64+. Cut the line earlier if usage runs low; every step is a drop-in so partial ship is safe.

## Decisions needed before step 16 / 7
- 480x270 canvas final?
- Redo all 1,667 acts or only used ones? Skip craftmap 14?
- Approve new stage art (montages) then install `aseprite-source/v3/p7/out/derived-<land>/` into `assets/img/scenes/`.

## Checks each step
- Same filename and size; transparent where needed; no text, circles, people painted in scenes.
- Remove fixed lines from `rollout/weak.txt`.
- Phone check by Josh still owed for 2.5.43-2.5.62 art.
