# Build plans review (2026-11-10)

File: `game/includes/data/build_plans.txt`. Reviewed by a mechanical pass (lint, item sources, region lands, totals) and a read of all 268 stage lines.

**Counts:** 67 plans (268 stage lines), not 94. All 67 havens / wonders / delves in `landmarks.txt` have a plan; the 14 lairs have none (they are never in ruins). The old todo number (94) was wrong. The file has no marker for which plans were the 36 old ones and which the 58 new ones (history was squashed), so the review covers all 67.

**Mechanical result:** 0 unknown item slugs, 0 bad verbs, 0 pipes in text, 0 straight apostrophes in text, all landmark names match, all clear stages are days-only (2 to 4 days, 2 to 4 energy a day, fine). 4 items have no normal source (below). 5 titles repeat. 4 wording slips fixed.

## Applied (unambiguous)
| Place | Stage | Fix |
|---|---|---|
| Thatchtop Tearoom | 4 | Title "Scones and tea for opening day" -> "Pancakes and jam for opening day" (the stage takes pancakes and raspberry jam) |
| Northern Lights Sauna | 4 | Title "Rye and soup after the steam" -> "Soup and trout after the steam" (no rye in the needs) |
| The Labyrinth Isle | 1 | Text "Buy silk, stay hopeful." -> "Find silk, stay hopeful." (silk is a drop / craft, never sold) |

## Needs your call (design / blockers first)
| # | Place | Issue | Suggested fix |
|---|---|---|---|
| 1 | Aurora Camp 1, The Oasis That Moves 1, The Great Migration 1 | `camp-kit` is a Trek-only reward (Trek chests / carts); no shop, recipe, drop or gather gives it. Stage 1 of three plans cannot be finished by a normal player. | Swap to `camping-gear` (made in the workshop since sleep-days, about 60 Petals) or add a camp-kit recipe. Edit the "camp kit" wording in the three stage texts to match. |
| 2 | Mud Mosque Library 1 | `overdue-book` is a Trek chapter II quest item (found once, then handed in). Not obtainable otherwise. | Swap for a gatherable (`river-clay` is already stage 2; maybe `cottongrass` x8 or `silk-thread`) and reword "overdue by about four hundred years". |
| 3 | Beaverdam Tunnels 2 (NA, level 1) | `cattail-root` and `bog-iron` are wetland finds. Maplewold (NA) has no wetland routes, so a level 1 gnome must travel to another region. | Use Maplewold forage (e.g. `pine-resin`, `birch-log`) or accept the trip. |
| 4 | Pink River Dolphin Pools 1+2 (SA) | `cattail-fluff` is a wetland find and `perch` forest / wetland; SA has no wetland or forest routes. | Use rainforest / island finds, or accept travel. |
| 5 | The Standing Stones 4 (NWE) | `edelweiss` is a mountain find; NWE routes are coast / forest / grassland / tundra. | Swap for a tundra or forest find (`frost-crystal`, `reindeer-lichen`). |
| 6 | Olive Press Piazza 1 (SE) | `oak-log` is a forest / grassland find; SE routes are coast / island / mountain. | Use `building-stone` or `driftwood`. |
| 7 | Pearl Diver Cove 1 (EA) | `coir-fibre` is an island find; EA has no island routes (also needed for Cenote of Echoes, Kava Circle, Starpath, where it fits). | Use `rope` or `driftwood`. |
| 8 | Flamingo Shallows 2 (ESA) | `sea-salt` comes from coast / island; ESA has neither (a creature drop, no shop). | Use `cattail-root` (wetland, which ESA has) or a salt-flat find. |
| 9 | The Sky City Ruins 2 (SA, level 12) | Two `masterwork-barrow` handed in. One barrow needs a wheelbarrow, 2 `bog-iron` (wetland) and 4 `coir-fibre` (island) plus 6 energy. Far above every other tool ask. | Drop to 1 barrow, or swap for `building-stone` x12. |
| 10 | Tools handed in and used up | `tin-lantern` (12 stages), `glowcap-lantern` (8), `miner-s-lantern` (2), `hatchet`, `harvest-trug` x2, `woven-basket` x3, `diver-s-creel`, `fine-mesh-net`. These are the player's tools, spent for good. Stage cards do not say so. | Confirm it is intended, or add a line on the card "uses up the tools". |
| 11 | All places | Cost does not scale with region level: average items per plan are 20.1 (levels 1-8), 22.7 (10-17), 20.3 (20-26), 21.1 (29-35); coins 0 to 300 flat. Rewards do scale (+10 Petals and more XP a level per stage). Level 1 is as costly as level 35. | Scale coin stage and item counts by region min level, or keep it flat on purpose. |
| 12 | Lemon Grove Monastery 1, 3, 4 | "The monks ...". No human villagers rule. | "The gnome brothers" / "the cloister gnomes". "Picked by Sunday" also names a real weekday while time is game days. |
| 13 | 5 repeated titles | "Clear the terraces" (Stepped Seed Temple, Tea Garden Slopes), "Clear the cave mouth" (Cenote of Echoes, Glowworm Grotto), "Feed the diggers" (Jaguar Root Caves, Amber Woods), "Build the lookout" (Anaconda Hollows, The Great Migration), "Feed the caravan" (The Oasis That Moves, Silk Road Caravanserai). | Retitle one of each pair. |
| 14 | 18 clear stages | The same phrase "a little each day" / "a bit each day" appears in 18 clear stage texts (12 times as "a little each day and the ..."). | Vary some. |
| 15 | Prayer-flag Pass 3 | "Gather the dye plants" also asks `silk-thread` (not a dye plant). | Retitle "Gather the dye plants and thread", or drop the thread. |
| 16 | Verb vs needs (OK, noted) | Pink River Dolphin Pools 2 and Kava Circle 3 use `feed` with raw fish / raw roots; Northern Lights Sauna 1 uses `light` with logs and ash. These read fine on the card. | None. |
| 17 | Titles | "Rest the lanterns" (Firefly Caves 3) is odd; "Collect the frost glitter" fine. | "Set the lanterns low". |

## FIXED 2026-11-10 (Josh approved calls 1 to 9, 11, 12)
Edit `claude/build-plans-base.txt`, then run `python3 tools/scale_build_plans.py`: it writes `game/includes/data/build_plans.txt` (do not hand-edit that file).
| Call | What changed |
|---|---|
| 1 camp-kit | Aurora Camp 1, The Oasis That Moves 1, The Great Migration 1 now hand in `camping-gear` x2 (craftable); stage texts say "camping gear". |
| 2 overdue-book | Mud Mosque Library 1 is "Bind the old scrolls": `silk-thread` x2 + `cottongrass` x4; text reworded (crumbling, not overdue). |
| 3 Beaverdam Tunnels 2 | `river-clay` x5 + `birch-log` x3 (Maplewold has both). |
| 4 Pink River Dolphin Pools | 1: `fiddleheads` x3 (rainforest) instead of cattail-fluff; 2: `rainbow-fish` x4 (rainforest river) instead of perch. |
| 5 Standing Stones 4 | `meadowsweet` x3 + `cottongrass` x4 (no edelweiss). |
| 6 Olive Press Piazza 1 | `pine-log` x3 (SE mountain) instead of oak-log. |
| 7 Pearl Diver Cove 1 | `rope` x3 (craftable) instead of coir-fibre. |
| 8 Flamingo Shallows 2 | `cattail-root` x3 (ESA wetland); text now says cattail root from the reeds. |
| 9 Sky City Ruins 2 | `building-stone` x12 + `rope` x4 (was 2 masterwork barrows). |
| 11 scaling | Costs scale with region level: item / meal / fine counts x (1 + (L-1)/40), rounded, min 1; coins + 5 per level above 1; tools handed in (lanterns, trugs, baskets, creel, net, camping gear) and clear stages untouched. Maplewold (L1) unchanged. Example: 4 Rope + 250 Petals at L1 = 7 Rope + 420 Petals at L35. Average items per plan after scaling: 22 at L1, about 30 at L12 to L17, about 38 at L32 to L35. Largest single ask: 15 Dressed Stone (Sky City Ruins 2). |
| 12 monastery | Lemon Grove Monastery 1, 3, 4: "the cloister gnomes"; "picked by Sunday" is now "before the next full moon". |
Still open (not asked): 10 (tools used up, no line on the card), 13 repeated titles, 14 repeated phrase, 15, 17.
Notes: a repair already in progress keeps its stage number but hands in the new needs for its current stage. `tests/buildplans.sh` passes; `tests/rebuild.sh` cannot run here (no ruins in the test DB).

## Not found
No `real days` / `hired helper` wording, no `|` inside text, no straight apostrophes in text, no doubled words, no missing end punctuation, no plan with fewer than four stages. Tone is consistent across places.
