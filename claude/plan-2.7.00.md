# Plan: 2.7.00 (decided with Josh, 2026-11-15, 99 questions)

Status: PLAN ONLY. Nothing built. Start work after the Fable rulebook is done. Combat work = main 2.6.990 (Josh pasted its handoff 2026-11-15); merge origin/main into this branch with the handoff branch. Push main only on "Merge push main".

## Base and rules
- Base: merge `origin/main` (2.6.990) and `ccr-fb812cec-kj1m4j` (non-puzzle handoff, `claude/handoff-non-puzzle-2026-11-15.md`) into this branch. Puzzle combat stays admin-only (`pfight_v1`), no player note for it.
- Theme: two equal headlines, combat puzzle + trail/world.
- Claude does it all for this release: bump `APP_VERSION` to `2.7.00` (check `tools/check_versions.sh` accepts the format), CHANGELOG top entry, FULL zip (not slim), art zips for Admin > Images, in-game player Release notes (trail, camps, road kinds).
- Gate: full CI + MySQL + browser run first. Fix the 13 known failures (stops100 stopkinds here pantry css_lint here_bang animals120 calling contest market100 delvemap flowers sinks097) before release. Browser: Playwright at 412x915, 390x844, 360x640, 1280x720. Josh checks a real phone.
- Subagents: many, in parallel. Claude reviews output.
- Order: data/code, then art, then re-bake last (one full re-bake of all ground pictures, `bake_trail_rich.py --all`, ~45 min on 4 cores, run here; new Admin > Images zips ~250 MB). NOTE handoff said bake is not bit-for-bit repeatable: Josh chose re-bake all anyway.
- Boot steps run once on release, no admin switch.

## Data / code
1. Lair levels: extend boot step 1115 (`LAIR_LEVEL_1115`, `medium_lair_levels_1115`). Hard-zone lairs (CA NWE CB SE EE MENA EA) = region level + 4, route -2..+2. Every lair changes, including fought/charmed ones (check records and rewards first). Den of the Great White Owl (NA) stays Lv 10. OC keeper capped at Lv 37.
2. Sights rewards: full pass, scale by region level, same ratio as today. Claude proposes numbers; Josh approves before ship.
3. Sights engine gaps: timing (every 7th day, by the player's game day), rewards (choose-your-reward, shop discounts, tool-tier odds), villager stat checks. NOT in: buffs, destination lines, market-day, quest limits.
4. Admin decor editing: edit section fields (looks/kinds/zones/props) only, saved to data. No preview.
5. New road kinds (hand list; Claude drafts ~1 route per kind per region with a TIER column, Josh vetoes):
   - Ferry/ford: pay 20 Petals per crossing. No ferry token.
   - Tunnel/pass: tool gate, tunnel = lantern, pass = staff; tier set per route.
   - Toll/market road: pay 10 Petals once per route, prompt at section 1 (pay or take normal road). Safer (random fight chance halved) and faster (fewer game minutes per section).
   - Overgrown: +10 game min per section; axe = no slowdown.
   - Flooded: +10 game min per section, nothing clears it; flood boots halve it (+5).
6. Camp spots: one per route, all routes (~246), added to map data (needs re-bake). Camp button on the camp tile on the Trail map opens a card with a dropdown: Sleep, Nap 2h, Wait 10-60 min. Sleep free and safe. Wait energy +1 per 2 min. No daily cap. Fight chance: wait over 30 min 25%, 30 min or less 5%, halved on toll roads.
7. Rest of "rest spots on tall N/S routes" is covered by camp spots.
8. Items (short Almanac pages like Sights items): toll receipt (flavour), camp kit, flood boots, scarf (existing, Cat Fish). Ferry token dropped. Last 4 weak items redrawn (ginseng, stone-wall-end, tomato, stuffed-peppers-goat) + landmark nits, vine twine redraw.
9. Wearables = Keepsakes: boots, hat, gloves, cloak, pack, scarf. Share the Keepsake slots. DECIDED slot count: 1 at level 1, 2 at level 15, 3 at level 25, 4 at level 40 (code today is 2, 3 from level 15: change `pfd_slots()` / `PFD_KEEP_SRC` in `pfdeck.php`, Puzzle box pips, tests). Sources: craft at a new Tailor spot (a section of the workshop picture), buy, found. Combat effects proposed by Fable from the rulebook rules (after the book is done). Flood boots take a Keepsake slot. 
10. Trail event/hotspot icons 32x32: current kinds plus ferry, tunnel, toll, camp, overgrown/flooded.

## Art (Aseprite 1.3.18.6 works in this container: run `Aseprite_1.3.18.6-x64.AppImage` with `--appimage-extract-and-run` or `sh`; do not chmod the repo copy)
- Puzzle Pal sprites: all pals, perch + yard size, redraw in gnome 2.5D style, stills.
- Stop looks: all 11 types x 7 region styles (EA SA SEA WCA CB SE OC), drawn by region.
- Camp spot art, road kind art, icons, items above.

## Puzzle combat
- Rulebook updated to 2.6.990 by Fable (`claude/reviews-2026-11-13/rulebook/`), committed on this branch.
- Demo artifact https://claude.ai/artifact/SCVTp8FLRTbibtA7vNWC2S: add the full rulebook as a new tab with links into the playable tabs; after the rulebook rebuild the "new system" tab at 2.6.990 rules; fix the artifact's slow load between moves and missing animation (live is fine).
- Still open there: bots do not value Keeper/Plenty/Simmer, no sim with the 42 legendary pieces, 6-piece hand on a phone, per-dish / Gourmand / mentor / trophy pieces, first-fight teaching, real-choice 14-20% vs 50%.

## Open items for Josh
- Handoff gaps: sights engine "buffs" and "destination lines" left out; Trek content out.
- Flooded roads have no clearing rule except flood boots halving the slowdown.
