# Trail and Sights 2.7.08: work log (2026-11-17, not committed by me; the lead commits)

Branch `ccr-e36c0d29-46t8la`. Owner of these files this pass: `game/includes/trail_sights.php`, `trail_sight_extras.php`, `region_layout.php`, the Sights data files, `game/assets/site.js` (toast dodge), end of `game/assets/style.css`, `tools/map_layout.php`, `tools/map_layout.lua`, `tools/gen_bendy_trail_proto.py`.

## 1. Sights engine gaps
BUILT (grammar in `claude/sights/GRAMMAR.md`, "2.7.08 additions"; test `tests/trail_sights_278.sh`):
- `to=<place slug|kind|land>`: where the walk leads (destination-dependent rewards and lines). The lint checks values against the world.
- `{cond}` line variants in win / lose lines: a matching one wins over the plain ones (destination text, weather text such as the Dragonlizard sun line). The walk log and the popup show the same chosen line (before, the popup drew its own random variant).
- `mk=yes|no`: the town market day (`market_day_on()`).
- `hint=tide`, `hint=moon`: true tide now, tonight's moon.
- `take=...?cond`: a conditional cost (crab-sitter at low tide, etc.).
- Checked, already worked (todo lists were stale, now marked DONE): `fpto=Name@village` lint, `tally=` with `?cond`, `nocheck` on a pick, every-7th-day (`gd=`), festivals (`fd=`), streaks, loans, quest time limits, delve / sleep / section buffs, escorts, any-kind takes, tool-tier odds, villager stat checks, shop / inn discounts (`disc=`, wired in `shop_price` and `gclock_inn_fee`).
STILL NOT POSSIBLE (need design or other systems): snore-count / web-hum / first-room-of-a-delve / Labyrinth-turn hints (no game state to read); next-section or map outputs (show the next section's finds, mark a hidden find, name a section); walk-time effects beyond `time=` (arrive sooner, skip a stretch, free steps); two buffs in one row / +1 to every stat / Charm only in the Den; choice of reward inside a pick; hidden buttons; birthday; real other-player notes (bottle post); +friendship with a whole town; letters handed by a Sight (letters.php hook); quest beats that give items, a fixed first + last beat order, an "at a village green" beat; quest starts from a Notice Board favour; seeds that must grow first; per-tool effects of keepsake items (Teeny Axe, Bridgewarden's Badge, Feather Pillow ...).

## 5. Weak Sights data
All 9 rows checked. Several were already upgraded in the reward tune (tally / title / c=7); each now also has `{cond}` win lines and what it lacked:
- forest-the-glow-moss-grotto: streak `moss-reading` (3 days: +XP), moon hint at night, night / rain lines.
- mountain-the-echo-wall: streak `echo-shouts` (3 days: echo pebble 50%), weather hint 20%, fog / night lines, one more lose line.
- desert-the-mirage-pool: streak `mirage-days` (3 days: +1 energy), weather hint 20%, heat / night lines.
- end-wonder-2-forest: a line for each of its 5 destinations (Fairy-ring Clearing, Tea Garden Slopes, Thousand Gates, Panda Bamboo Grove, Stone Head Watchers), moon hint at night 20%.
- end-haven-2-grassland: a line for each of its 5 havens, streak `sign-reader` (3 days: `c=6:1`), moon hint at dusk / night 25%.
- end-lair-1-mountain: a line for both lairs (Smokecap Caldera, Grey Wolf King) + a fog line, weather hint 30%.
- 311-taprow: frost bonus sap 40%, weather hint 25%, frost / dawn lines.
- 236-beanpoles: streak `bean-days` (3 days: `c=6:1`), rain / night lines.
- 316-starstones: its streak `star-chart` had no payoff: now title "Pole Star" at 3 days; moon hint at night; night / snow lines.
Lint: 219 rows, 0 problems. Josh: the new Petals are small (c=6:1 once per 3-day streak); watch with the week-1 Petals check.

## 7. Per-walk cap
Setting `sights_walk_cap` (Admin settings, next to `sights_reward_pct`): default 6, 0 = off. Counts every Sight use (win or lose) on one Trail walk (expedition id), across its sections; kept as two private tallies (`walk#id`, `walk#n`). Refusal: "You have used 6 Sights on this walk, the most for one walk. The next walk starts afresh." The Sights card shows the button off with "6 Sights this walk: the most". Gifts to villagers (`give=`) do not count. `tests/trail_sights.php` and `tests/trail_sights_270.php` set the cap to 0 (they use many Sights on one walk).

## 8. Docblock
`trail_sight_flat_scale`: now says default 3 (approved 2026-11-15), 0 = off.

## 2. Milestone box / Almanac toast over the end scene
- `site.js` `gvToastDodge`: after the toast box is placed, if it overlaps a fight's end scene (`#fightscene`, also on the plain adventure page and in a delve), it moves to the top right under the header (`.toasts-top`); if it still overlaps it goes compact (`.toasts-tiny`: one line each, no prize lists).
- `style.css` (end): pages with a fight scene but no Trail map get the same small corner box as a Trail map.
- Test `tests/toast_cover.sh` (Chromium, 1280x720 and 390x844, a stand-in end scene). JOSH (phone): look at a real fight end on a phone with a Milestone landing at the same time; the compact box at the top may still sit over the top of a full-screen scene (it is one line per message).

## 3. Side-trail heading rule
`region_layout.php` `rl_trail_heading`: every side trail (stop -> off-road place) now has `bow` (L / R: the side of the road the place lies on), `heading` (8-compass, the first leg) and `ctrl` (a control point: the chord's middle pushed 0.25 of its length along the road), so the trail leaves the stop leaning the way the road runs. The line drawn on the region map stays straight (the painted art has straight trails). `tools/map_layout.php` exports `trail_bends`; `tools/gen_bendy_trail_proto.py` bends side trails through `ctrl` (the old rid-parity bow stays only for routes with no line in the layout). Game Trail maps are NOT regenerated (that is a re-bake under a new version).

## 4. Region map art sync (code side)
- FOUND: the committed `tools/map_layout.lua` (what the Aseprite region art is painted from) was far out of date: the world gained 4 to 23 places per region since (CSA +23, NWE +21, CA +20 ...), and slots moved (median drift per region: 0 px OC, 2 to 13 px most, 24 to 29 px SEA / MENA, 143 px EA). So the painted roads and spots on `map-<CODE>.png` do not line up with the markers and lines the game draws over them in most regions.
- DONE: `php tools/map_layout.php --check [GAME_DIR]` exits 1 when the dump differs from the game's layout; `tools/map_layout.lua` regenerated from the current world (plus `trail_bends`); test `tests/region_trails_gates.sh` runs the check, so a world change that moves the layout now fails CI until the dump is refreshed.
- JOSH / ART: all region pictures except OC need a repaint from the new `tools/map_layout.lua` (the scripts in `opus-test-run/scripts/upgrade/map-*-fit.lua` read it). Until then the game's own lines (with their dark casing) are drawn over the old painted roads.

## 6. Gates outside the Maplewold
The first pass is already in the data: all 14 non-Maplewold region files have gates (a lock on the lair and delve routes where one fits, 1 short cut each; 38 gates; NA has only its short cut), with Josh's 2026-11-14 tiers (NA CA NWE CB SE SA EE = 2 Sturdy, the rest 3 Fine). There is no `@lv` gate grammar for Sights (the `@lv>=N` gates were dropped, todo section 3). Added a regression test (`tests/region_trails_gates.sh`): tiers by region, each gate shuts without the tool and opens with it, every gated route valid. JOSH: routes 327 (CA, Smokecap Caldera) and 448 (EA, Jade Dragon-fly) are lair roads with no lock (the generator found no wall line); say if they need one (a hand edit of the section).

## Tests
New: `trail_sights_278`, `region_trails_gates`, `toast_cover` (added to `.github/workflows/ci.yml` after `trail_sights_270`). Results: see the lead's report.
Run 2026-11-17 (SQLite, `tests/ci_suites.sh`): pass = trail_sights, trail_sights_270, trail_sights_278, trail_sights_lint, trail_marks, road_kinds, stops100, folkoverlay, region_trails_gates, toast_cover, almanac_pages, delvemap, delveroute, fight_scene_trail, pfmap, trail_back, trail_camps, trail_decor_edit, trail_decor_page, trail_mini, trail_reverse, trail_walkers, trail_fam_coast / collapse / delve / desert / grassland / haven / island / lair / wonder.
Fail, the SAME failures on a clean HEAD copy (not from this work; moon / clock dependent): trail_fam_forest, trail_fam_mountain (known), and today also trail_fam_maplewold ("fair chance" odds check), trail_fam_rainforest, trail_fam_tundra, trail_fam_wetland (the moon-line checks). trail_fam_* tests that use many Sights now set `sights_walk_cap` 0 (rainforest's 12 pool visits hit the cap of 6 before).

## Second pass (2026-11-18)
### Sights engine gaps
BUILT (GRAMMAR.md "2.7.08 additions, second pass"; test `tests/trail_sights_279.sh`, in CI): `buff=all:N` (+1 to every stat, 312-toadring), `fpall=N` (+friendship with every villager of the start place, PICNIC), a free pick (`pick:N` + `choose=` with N options: a reward choice inside a pick, 314-driftwood / 309-snowmen "no wrong answer"), quest order `firstlast` (a fixed first + last beat, Q4 / Q5), a beat's gift (7th `B|` column: quest beats that give items, the owl letter), `qd=` documented (it already worked). The lint checks every `buff=` now (stat or `all`, length) and `fpall=`; 219 rows still clean.
STILL NOT POSSIBLE, and why:
- snore-count / web-hum / glow-pulse / rut-width hints: no such game state exists (a lair has no snore or web value to read). First-room-of-a-delve / Labyrinth-turn hints: the delve map is made when the run starts, so there is nothing true to tell before it (it would need the delve to be seeded ahead, a delve change).
- next-section / map effects (+1 find on the next section, show its finds, mark a hidden find, name a section) and walk-time effects (arrive sooner, skip a stretch, free steps): they write into the Trail walk / section generator (`trail_tiles.php`, walk scene state), not the Sights engine; each needs a design of what the map shows and a re-bake rule.
- two buffs in one row / Charm only in the Den: one lucky-moment slot (`users.ev_stat`, VARCHAR(10)); a second needs a schema column plus every reset site (fresh_start, sleep) and the effects list. `buff=all` covers the "+1 to everything" case.
- hidden buttons, birthday (a gnome has no birthday; only NPCs do), bottle post (other players' notes), letters handed by a Sight (`letters.php` has one daily letter per gnome and no way to hand a specific one), a quest beat "at a village green" (no arrival event hook), quests started from a Notice Board favour, seeds that must grow first, per-tool effects of keepsake items: each is another system's design, not a token.
### Region map art (item 4 above)
Aseprite runs here: `aseprite-source/Aseprite_1.3.18.6-x64.AppImage --appimage-extract` then `squashfs-root/AppRun -b` (no FUSE needed). Found the chain that made the live region maps: `opus-test-run/scripts/upgrade/map-<R>-fit.lua` (reads `tools/map_layout.lua`) -> `aseprite-source/v3/finish3/maps/batch.lua` -> `aseprite-source/v3/finish5/maps-a/maps.lua` (NA CA CB SA NWE SE EE) or `maps-b/maps-b.lua` (the rest). Proof: run with the OLD (2026-11-13) `map_layout.lua` it rebuilds all 14 live maps bit for bit (0 pixels differ). Run with the regenerated layout it repaints them; installed 13 (`game/assets/img/scenes/map-<R>.png`, all but OC, whose layout barely moved); the chain's intermediate files are updated too, so it stays reproducible. Script: `bash aseprite-source/extras-pixel/maps-2708/repaint.sh <AppRun> R ...`; old pictures in `maps-2708/before/`, before | after sheet `maps-2708/contact-2708.png`. Checks: 480x270, no semi-transparent pixels, no #000000 / #ffffff. JOSH / ART look: CSA's market village keeps 1 of its 4 houses (the denser roads round the plaza leave no room; the fit script drops a house that would sit on a road or a stop's clear ring), CA has some trails that run out over the cave rock to the region exits, and a few landmarks moved (they are only placed on floor away from every marker). Not done: a hand art pass on those, and the art zip (`upload-zips/`).
