# ART TODO (single list). Updated 2026-11-11.
Replaces `todo-art-variety.md` and `todo-art-catfish.md` (now stubs). `todo-art-acts.md` stays as the generated per-activity checklist (810/810 drawn).
Source, scripts, state: `aseprite-source/v3/` (read `HANDOFF.md`, then `ROLLOUT-STATE.md`). Style: `aseprite-source/art-style-guide-v3.md`.

## RULES
- No human villagers (Josh 2026-11-04): every NPC portrait and sprite is a creature, or a gnome clearly unlike the player. Player gnome needs front/back/side + 6-frame walk (test: `aseprite-source/v3/gnome-dir/`).
- Scene and picture art = ONE pass by Opus medium. No draft-then-rich pass.
- Ask Josh before drawing at scale: cost estimate, first batch, one contact sheet.
- No text, circles, people or animals painted into scenes. Placeholders (red border, THIS IS PLACEHOLDER) never ship as final.
- Real art replaces a placeholder by the SAME file name and size.
- Weak images get a pink 2 px border in the live copy: list `aseprite-source/v3/rollout/weak.txt`, re-run `rollout/export_game.py`, then bump version and run `tests/build_update.sh`.

## HOW TO RUN (cheapest measured)
- Seeds: `rollout/items-seed.js` (hybrid, ~10k tokens each, groups of 12).
- Other 64x64 items: `rollout/items-lean.js` (cheat sheet `lib/CHEATSHEET.md`, ~22-25k each, Sonnet medium, groups of 6). Not `items-run.js` with a draft step.
- Gate-view scenes: single Opus-medium pass, ~110-150k each, read only CHEATSHEET + scenes part of README + 1-2 reference PNGs.
- Per scene output: `.lua/.png/.aseprite` + `.layout.json` {w,h,horizon,view,spots[{k,name,x,y,box}],stand[],compass_clear}.
- Look: gate view, one-point perspective to ~(240,112), 480x270, hero scale (props 80-140 px near, 56+ far, 12+ px gaps), 1 px dark edge in own tone, warm light upper left, cool-violet shade, road 150+ px wide at bottom, bottom-right 100x40 plain, 4-6 visible quirks.
- Stops are parametric: one script per stop type, look via `--script-param pal=<landscape_region>` from a PALETTES table. Pilot `v3/here-gate/pilot-market.lua`. New look = one new table entry.

## DONE (do not redo)
- Creatures and minis: 117 creatures + 7 Trek crew redrawn and rigged (CHANGELOG 70; `mini/` and `folk/` files dated 2026-11-07/11); animal homes pixel art in the yard (CHANGELOG 492). Species/folk portraits and sprites done (CHANGELOG 526). Josh confirmed 2026-11-11.
- Gather: `scene3-<land>` x 9 landscapes x day/dusk/night, satchel back/front x 3 skins, slots, vignettes, flourishes, badges, felt, ribbons, weather (checked 2026-11-11). Old `scene-<land>.png` (9) + `scene.png` are fallbacks only.
- Acts (Josh: close enough) and big pictures (regions, banners, wonders, landing, map, journal) done 2026-11-11.
- 1,662 items/icons 64x64 (v3 rollout); 35 batch1/2 pictures exported (2.5.48).
- 179 weak items redrawn (2.4.98+, art pass 2.5); hedgehogs redrawn; gnome 1px eye rim for dark skin.
- All NPC art done (portraits, `ph/npc-*`, 81 `sprite/npc-*.png`; Josh 2026-11-11).
- Flower heads done (Josh 2026-11-11). Home/house art done (Josh 2026-11-11).
- Treehouse checked 2026-11-11: layout has 8 room spots (parlour, loft, cellar, puzzles, catfish, contests, books, yard), 24 pal perches, 4 dress layers, 5 trophies; Pal Yard 6 job sites.
- Here scenes: 46 `scenes/here-*` (15 regional towns + hub, village, haven, delve, lair, wonder, 11 stop types in default + `desert_adobe`).
- Workshop picture + 13 `craft-anim-*` layers; treehouse (`tree-house`, 4 dress layers, trophies); `yard-pals.png`; `resid-4/6/8`; 6 shared doors.
- Acts: 810/810 scenes + animated strips; 4 kind cards (act-craft/collect/tend/contest) drawn.
- Stage verb icons (5), stop tier pictures (12x4), folk species (11), road kind icons (5), journal pictures (14), Jeff poses.
- Cat Fish lanes A-D (scarf, collars, seasons, yarn, yarn-panel icons).

## A. REDO (weak)
1. `rollout/weak.txt`: `ph/ginseng`, `ph/stone-wall-end`, `ph/tomato`, `ph/stuffed-peppers-goat`.
2. Ginseng Seed: new leaf reads as cannabis; still on the old picture. Fix, then export.
3. Repaint if Josh dislikes: coralscatter wave dome + small tea house; monsoontangle bland deck + small boats; thornacre Wild Trail arch squeezed; blossomreach parasol outside box.

## B. NEXT: graphical navigation (`claude/plan-graphical-nav.md`, brief `claude/art-brief-here.md`)
1. Stop looks for the other 14 landscapes per type (only default + `desert_adobe` exist for the 11 types; market also has grassland_maplewold).
2. Village/haven at hero scale per region; folk wiring.
4. Doors: unique door per villager (up to 151, `door-<slug>.png`), optional. Shared 6 exist.
5. 2.5D villager sprites: 81 of up to 151 done. Feet bottom-centre, 96 px max, transparent, 1 px outline. Prioritise villagers on the most scenes.
6. Treehouse: nothing open (done). Optional: `scenes/wander-step-back.png`.
7. Pal sprites (perch + yard size) per Puzzle Pal: no `assets/img/pals/` folder yet, code falls back to the sticker/crop/silhouette. Found-pal sparkle. Pal Yard job-site picture is done.
8. Trail tile sets per landscape (code-generated today, art optional); event/hotspot icons 32x32; nav icons.
9. Canvas 480x270 treated as settled (code reads size from layout JSON).

## C. LEFT OUT OF v3 (counts = files in `game/assets/img` on 2026-11-11)
| Group | Count / note |
|---|---|
| `-anim` strips | with the animation plan |
| Odd-size UI | `items/` 21, `fx/` 6, `steps/` 5, `roadkinds/` 5, `ui/` 4 |
| Craftmap | `craftmap/` 14: unused leftovers (workshop picture replaced it); delete or ignore |
| Puzzles | `puzzles/` 26 files (GIFs), jigsaw sets |
| Catfish | `catfish/` (1,414 files mostly part frames), plan `claude/plan-catfish.md` |

## D. FROM OLD VARIETY LIST (not made)
- Build-stage verb icons `steps/stage-<verb>.png`: carry, befriend, trial, vigil, wait, decorate, craft_on_site, fetch_lore. Add a placeholder when each verb ships.
- Stop header picture that changes per tier (`<kind>-<tier>.png` exist, header not wired).
- Per-activity closer pictures for regional acts; "Birds of the Maplewold" journal page picture per collection.
- Road Journal: a picture per sketch page (6 per region).
- Before/after pictures for 9 pilot places: Market of a Thousand Chilies, Stepped Seed Temple, Cenote of Echoes, Jaguar Root Caves, Driftwood Tavern, Sunken Gnome Galleon, Singing Waterfall, Mangrove Root Maze, Turtle Nesting Beach. Not wired.
- Progress picture for clear stages (1/3, 2/3, 3/3).

## E. CAT FISH (open lanes)
- Lane E, only after Josh picks pet shops (`claude/plan-catfish-petshops.md` s7): 55 item sprites `cf-pet-<key>.png` 32-48 px (start Steel-pan Chime); 11 shop banners `banner-<code>-pets` 480x120; 11 shopkeeper busts 400x500; 8 `pet_slots` in `room-layout.json`; event props (golden fish, feather, stranger cat, yarn crumb).
- Lane F, optional: side-cat nap/bored frames that move; 'watch' head turn; catch and nap frames have no eye pixels (odd-eyed shows nothing).
- Tools: `tools/catfish_recolor.py`, `tools/catfish_build_art.py`, `tools/gen_placeholder_art.py`; sources `aseprite-source/catfish/`.

## F. ORDER
1. Section A (4 items + ginseng).
2. B1-B2 (stop looks, village/haven), B5 (sprites).
3. B7 (pal sprites).
4. C by Josh's priority. D and E only when asked.
