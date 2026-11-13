# Cat Fish art rework + fixes: handoff (2026-11-13)

Branch `ccr-10c12896-5587vr`. Nothing installed into `game/`; `game/` and `tools/` untouched. Style: Hearth Pop (`aseprite-source/art-style-guide-v3.md`). Old Stitched Toy art still live in `game/assets/img/catfish/`.

## Where the art is (all under `aseprite-source/catfish-rework/`, .aseprite + PNG + Lua scripts)
| Folder | What |
|---|---|
| `cf-new/` | first PIL pass (superseded; polish/, rich/) |
| `cf-ase/` | first Aseprite pass (superseded) |
| `cf-ase2/final2/` | **use this**: 19 cat frames (cf-cat-grey-*), cf-fish-1..5, cf-rod, cf-ico-kibble, cf-ico-yarn, `overlays/` (5 patterns, folded ears, bobtail, masks for all 19 frames; shifted eyes for jump/stalk/stretch). `p1-polish`, `p2-texture`, `p3-texture` are history. Mockups `mockup-final.png`, `mockup-final2.png`, `mockup-rollout.png` |
| `cf-ase3/fix/out/` | **use over `cf-ase3/out/`**: cf-room + 8 overlays, 16 cf-up-*, 9 cf-badge-*, 5 cf-ribbon-*. Sheets `sheet-*.png` |
| `cf-ase4/pets/out/` | 55 cf-pet-* sprites (slot sizes match) |
| `cf-ase4/small/out/` | 15 cf-yi-*, cf-collar (4 grey + 24 recolours), 8 cf-season-*, cf-yarn-1..4 (+16 recolours), cf-bird-1..3, cf-tile, cf-banner, cf-bookhead (grey + 8 coats) |
| `cf-ase4/banners/out/` | 11 banner-<CODE>-pets (480x120), 11 npc-<keeper> busts (80x100) |
| `sims/` | `away.php`, `away4.php`: check-in player Yarn sim used by the gameplay review |

Scripts in each folder: `cflib.lua`, `cats.lua`, `fish.lua`, `items.lua`, `room.lua`, `icons.lua`, `badges.lua`, `pp.lua`, `mock_ase.py`, `chk.py`. Aseprite: extract `aseprite-source/Aseprite_1.3.18.6-x64.AppImage` to /tmp/aseq, run `/tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script f.lua`.

## Recolour facts
- Cat grey ramp: deep #3d3654, shade #57516f, rim #646691, bounce #6e6684, base #8a859b, lift #aca7b9, light #cdc9d3, gloss #f1ebe3; ink #2b1c26.
- New vs old tones: bounce, lift, rim, patch_white_deep (#8d829a) are new. `tones_overlays.ase.json` (in cf-ase2) has the map; `ramp()` in `tools/catfish_recolor.py` needs `lift` (avg base/light) and `rim` (shade hue to 265, L x1.12, S x0.9). `mock_ase.py` / `chk.py` patch these at runtime.
- Eye boxes locked: left (16,21), right (34,21); pounce x+16, nap y+18. Jump/stalk/stretch heads moved: use `overlays/cf-eyes-*-{jump,stalk,stretch}.png` (+2,0 / +5,+1 / +4,+9).

## TODO, in order
A. **Sunbeam**: `cf-room-sunbeam` (cf-ase3/fix) uses semi-transparent alpha (40/80/120). `tools/catfish_build_art.py` requires alpha 0/255. Redo as hard-pixel bands.
B. **Recolour tooling** (`tools/catfish_recolor.py`, `aseprite-source/catfish/tones_overlays.json`): add roles above; unmapped colour = FAIL not WARN; add ink to FIXED.
C. **Eye clip**: update `eye_split` in `aseprite-source/catfish/frames-alias-s4.json` (stretch 40->44, jump probably 34, stalk missing; verify) and the 17 `.cfclip-*` rules in `game/assets/catfish.css`; missing ring PNG must FAIL in `tests/catfish.sh`.
D. **Code review fixes** (Opus):
   - catfish.css `.cfstage.is-bird .cfl-window{display:none}` hides the whole window overlay; make the robin a separate layer.
   - Hard-coded CSS anchors (z .cfz-a/.cfz-s, sparkles .at1-3, pops, --cfn per fish, bird, yarn patch, rain, lantern glow, floor line, pet slots): move to room-layout.json and test all.
   - Canvas sizes hard-coded (64/48/320x200/rod 48x64) in catfish.php, catfish.js, catfish.css, build_art: one shared spec.
   - Cache: images use `?v=APP_VERSION`, CSS `url()` masks/season sprites have none; bump version, version them.
   - `--install` copies file by file, never deletes stale files, `catfish_art_has()` is just is_file: install into fresh dir and swap atomically.
   - Missing pattern/eyes/ears/tail layers drop silently (`catfish_cat_layers`); flag in dev, add coverage mode to `--verify`.
   - Fallback detection by searching HTML for `class="cfcat ` (catfish.php ~304, 315): test `catfish_cat_layers()===null`.
   - Frame names listed by hand in 5 places (CATFISH_FRAMES, css show rules, masks, JS FB map, build FRAMES): generate from one list.
   - Race: `catfish_set_bio` (~1308) and `catfish_collar` (~1327) check ownership outside the lock; re-check inside `catfish_yarn_spend`.
   - Perf: `catfish_scene` rebuilds stage HTML every 30 s tick; `catfish_ball_key` uncached SELECT; ~200 img tags per page (consider baked composites).
   - `.cfsav .cfart{zoom:.5}` mangles 64px art; `catfish_ball_key`/`catfish_season_html` read `current_user()` not `$uid`; dead code CATFISH_PATTERN_FRAMES, CATFISH_PLAY_UP, .cfbrow; build file list parsed from the brief by regex; test hard-codes 1414 files.
E. **Gameplay fixes** (Opus):
   - Full home hides shelter (catfish.php ~123) and freezes Cat Book coats; always show shelter with Adopt disabled; hide Stakeout/Rare Shelter/Hold and shelter pet items when no place open.
   - `CATFISH_NAP_ROOT` 3 -> 4 (check-in sim 28 days, 3 visits x 10 min, nap every 3 days: 4,327 -> 536 Yarn).
   - Nap: show "Kibble x1.42 -> x1.61" via `catfish_yarn_mult`; badge only when gain >=1 and >=25% of Yarn; confirm only when < 10%; festival +25% Yarn (or only runs started in festival) instead of x2.
   - Mood Treat lasts 24 h from purchase; Hold/Stakeout apply to next shelter seen; 24 h room cooldowns -> 20 h; Keepsake 3/6/12 Yarn; auto re-enter last week's Cat Show cats.
   - Tapping: cap 180, Catnip doubles first 60 only.
   - Day-scoped buys expire silently; mixed real/game clocks; badges that never go out; clutter at 390px (7 hub tiles, ~22 Yarn rows, 8 spots with dropdowns).
F. **Art weak spots**: Coral bust (bill reads as snout); `cf-yi-hold` (hands = loaves); pounce/jump limbs, tuxedo belly on jump, stalk/stretch bib hidden; robin frames; yarn rolling frames; kente bunting; banners CB/SA/MENA/ESA/CSA; weak pets (calabash_bowl, matryoshka_mice, maneki_neko, shadow_puppet_screen, terracotta_catgrass, rod charms); edge-clipped pets (bromeliad, floating_lantern, rain_stick, weaver_bird_nest); 16 px readability of rug, catnip, cattree, nap1/nap5, book12/half/full; collar fit on pounce/nap; banner colour counts 87-128 (no cap decided); room base 48 colours; fish 1 etc fine.
G. **Install**: build into a fresh dir with `tools/catfish_build_art.py`, run `tests/catfish_build_art.sh` (update expected count 1414) and `tests/catfish.sh`, bump version, check page at 390 px light and dark.

## Decisions pending (Josh)
- Whether room/banner art may exceed the 24-colour cap.
- Whether to keep old overlays for non-redrawn frames (not possible: new silhouettes; use all new).
- Pet items "rod" slot charms distinguishable at 16 px?

## Cost notes
Measured: pose frame 3-10k tokens, icon ~8k, pet sprite ~6-8k, room base heaviest (~500 lines). Whole rework so far ~2M subagent tokens across ~20 agents.
