# Gnome Venture: to-do (updated 2026-10-28, 2.0.88 IN PROGRESS on main as source; latest built release is still 2.0.87)

## NOW (2.0.88 in progress): Puzzle Pals. Sources on main, version NOT bumped, no 2.0.88 zips yet. All behind `ppal_open` / `ppal_party` (off).
- **Built (code, steps 1 to 3):** `includes/puzzle_pals.php` (data, roster generator, art gate `ppal_art_ready`, release on Advanced solve via `ppal_on_solve`, Expert TROPHY + pal buff record, find lane `ppal_maybe_find`/`ppal_claim`, book queries, badges, `ppal_piece_html`), `puzzlepals.php` (Pal Book + hub card + Jigsaw pip + win-card text + profile shelf), find lane in `events.php` (`random_event_roll`, `ppal_lane`, box variant `ppalfind`), `PPAL_QUIET_PAGES` in layout.php, admin/tools.php "Test a pal find", schema `ppal_releases`/`ppal_found`/`ppal_trophies` + `users.ppal_*`, 7 settings "Puzzle Pals: ...". Tests `tests/puzzle_pals.sh` (in ci.yml DEFAULT_SUITES). Plans: `claude/plan-puzzle-pals.md`, `claude/plan-places-pals.md`.
- **NOT built:** step 4 (Take along / equip max 2 at gnome level 15+, passive perks `ppal_perks`, `gnome_avatar_pals` at the display sites, Expert-trophy buff maths, follower sticker stretch) and step 5 (admin/jigsaw.php Pals tab, `tests/jigsaw.sh`/`events.sh` extensions, news entry, version bump to 2.0.88, `tools/check_versions.sh`, zips). Weekly Jigsaw Schedule tab (also 2.0.88) is NOT started. Joshua checks the Pal Book / find card on his phone before step 4.
- **Pal art, 252 of 486 drawn (Opus, 64x64 stickers, `aseprite-source/pals/`):** 14 gallery pictures (84), 14 lairs (84), 14 delves (84). Contact sheets: `claude/pals-sheets/pals_all_{gallery,lair,delve}.png`. Scripts `pals_<set>.py` (gallery) and `pals_pl_<code>.py` (Places), helpers `palib.py`, lair parts `kit_lair.py`. Outputs `game/assets/img/puzzles/pals/<key>.png`. Re-run a set: `PAL_SHEET=<png> python3 -B aseprite-source/pals/pals_pl_<code>.py`. Checks: `tools/pal_unique_check.py`, `tools/lint_puzzle_pals.py`, `tools/dedupe_puzzle_pals.py`, `tools/pal_briefs.py --brief-kind <kind>`.
- **Rosters:** `includes/data/puzzle_pals.txt` = 252 authored pals (14 gallery + 14 lair + 14 delve pictures x 6 = 3 common/2 uncommon/1 rare). Places haven (18) and wonder (35) are NOT authored: they would get generated names (`ppal_place_roster`) and have NO art, so they release nothing. Per `claude/plan-places-pals.md`: author them with Haiku draft + Opus review (see `claude/drafts/places_*_review.md` for the model and lessons), Joshua approves names BEFORE art, then Opus art 9 to 20 agents at once (Joshua allowed up to 20), unique pals (distinct colour/accessory/silhouette/face), mirror-symmetric blanks on Ring/Plus/hook pals (NO swastika/pinwheel read, Joshua rule), kit parts are blocks not pals. Cost about 45k to 135k tokens per place.
- **Known art weak spots (Joshua may want polish passes):** gallery sets polished once (Opus low); lair and delve sets NOT polished yet (the delve run was killed by a container restart, 11 sets are draft-state). Per-set notes in the agent reports are summarised in `claude/handoff.md`.
- **Decisions (Joshua 2026-10-28):** Expert (216) gives a trophy and a buff to that picture's pals if found; 6 per roster 3/2/1; finds 1 in 60 views, 30 min cooldown, 4/day; roster-complete reward cosmetic only; no trading/gifting; Places rosters authored (not generated), names reviewed first; follower sticker = stretch; art path: Opus draws, Sonnet codes/scripts, Haiku drafts rosters; art approved ("looks good") for gallery sets; every pal unique; pals are puzzle pieces, Treks have NO pals.

## 2.0.87 (shipped, on main, zips in `releases/`): Jigsaw
- Shipped: Jigsaw section (3 fixed tiers 24 / 96 / 216, 3:2 pictures), 14 region pictures (3-pass method), Places (81 unique-location scenes unlock on first visit; admins see all, players only what they unlocked), free-play bests, save and resume, tournaments + three-tier cups, Admin > Jigsaw, new cast art and icons, README screenshots (`bash tests/readme_shots.sh`). Changelog is the top entry. Plans: `claude/plan-jigsaw.md`, art process `claude/jigsaw-art-process.md`. OFF for players until Joshua sets `puzzles_open`, `jigsaw_open` (and `jigsaw_tournaments`) in Admin > Settings; admins see it now. Joshua playtested 2.0.87: looks OK.
- Known gaps: Tidy button (rows) not built; `ico-piece` is a blob at 16 px and `jeff-piece` reads as a card at 38 px; `ico-piece`, `ico-cup`, `ico-jigsaw-box` exist but are not used anywhere yet; style-guide PDF not rebuilt (needs Chromium); `tests/emoji_icons.php` 1 failure and `landing` suite (stale 2.0.73 screenshots) fail on main too; upload hosts may need `uploads/jigsaw/` allowed and PHP `upload_max_filesize` above 3 MB; full CI list, upgrade check and MySQL not run for 2.0.87.
- Earlier decisions: tier sizes 24 / 96 / 216; weekly Schedule tab is 2.0.88; Treks are standalone stories and get NO pals; party = 2 equipped pals, passive perks, shown wherever the gnome shows (gnome level 15+), no fighting pals; gallery pictures use the 3-pass method.

## Earlier: what is done and approved
- **Variety project, content (Joshua approved the road cards and the art, 2026-10-28):** build plans for 2 regions (2.0.76), themed stop upgrades + regional materials (2.0.77), villager overlay (2.0.77), stop activity kinds + 810 activities (2.0.78), road card kinds + Road Journal + 25 cards in every region (2.0.79 to 2.0.80), first-pass art for every variety placeholder (stage icons, 48 stop tiers, 11 folk, 810 activity scenes, road icons, 14 journal pictures). Plan: `claude/plan-variety.md`; art list and what is drawn: `claude/todo-art-variety.md`, `claude/todo-art-acts.md`.
- **2.0.80/2.0.81 small fixes:** villager faces/names open the chat pop-over (Who's here, Orders, passport known list) with a "See full details" link; craft button text shows no raw tags; rest-stop daily cap 8 (migration `stopcap8` in `upgrade140.php`); stall above the activity cards, cards three across; shop card ink dark in both themes.
- **2.0.82 / 2.0.84: popover art is animated (done, Joshua confirmed it plays).** Only inside the open activity popover (`dialog.isheet.dosheet[open]`), never on the page cards or shop-tile popovers. CSS motion (`gv-pop-bob/breathe/hop/wiggle/blink`, steps(), transform-only, inside `prefers-reduced-motion: no-preference`) covers every activity and the option icons incl. emoji in buttons. Real frame strips: `game/assets/img/acts/act-<slug>-anim.png` (6 frames of 144x108, 6fps) for all 829 scenes and `img/ico/ico-<name>-anim.png` (6 frames of 64x64) for 7 stat icons; `gvAnimArt()` in site.js plays them, `stop_act_anim()`/`anim_strip_attrs()` in PHP add `data-anim` (popover only, only when the file exists). Optional sidecar `<file>.png.json` `{frames,fps}`. Test: `tests/popart.sh` (in ci.yml DEFAULT_SUITES).
- **Strip sources:** 15 hand-made in Aseprite (`aseprite-source/anim/*.aseprite`, scripts `animlib.lua`/`scenes.lua`/`icons.lua`, run `Aseprite.exe -b --script X`); the other 814 generated by `aseprite-source/anim/scripts/bulk.py` (Pillow+numpy, ~1 min, skips slugs with a pilot .aseprite; `bulk_verify.py` checks frame 1 == still, palette, 2px grid; `bulk_zoom.py` crops; README there). Never overwrite the 15 pilot strips.
- Joshua still has to check on his phone: Road Journal pages in a few regions, a fork/riddle/trade/chain card, the 3-across activity cards, shop cards in dark mode.

## NEXT (Joshua picks; suggested order)
1. **Build plans for the other 12 regions** (`game/includes/data/build_plans.txt`, 4 stages per landmark, never the same 4 verbs twice in a region; tests in `tests/buildplans.sh`). 2 regions per release, Opus writers, review artifact for Joshua.
2. **Leftover build verbs:** `befriend` (landmarks need stop folk first), `carry`, `trial`, `vigil`, `wait`, `decorate`; Admin > Build plans page (read-only list first); before/after pictures per place.
3. **Stop acts:** `cookalong` / `tune` / `teach` / festival kinds; regional acts already done (35 per region). Review notes for the 691 acts on the review artifact are still to apply.
4. **Road:** toll/beat/weather kinds (not built), a picture per sketch page (6 per region), "Birds of the Maplewold" style collection pages.
5a. **Popover animation polish:** 11 scenes are glint-only (gnome hat not detected: night_fishing, r_sa_frost_potatoes, r_ea_snow_monkeys, r_na_toboggan, w2_ice_paddles, w3_politest_bow, w5_bathers_hats +4; list via `bulk.py --report`); generator does NOT animate flags/bunting/cloth, foliage/grass, water, sun/moon (best next effects); pilot eyes-icon blink is rough; closer look at multi-gnome scenes (r_csa_courtyard_ragas, r_na_stump_rings, r_na_toboggan); animate more icons than the 7 stats (wits etc.); full `ci_suites.sh` not run on 2.0.82-2.0.84 (only popart); hand-draw the most-seen scenes (kind fallbacks, w5) over the generated ones.
5. **Art polish:** weakest drawn icons are listed in `claude/todo-art-variety.md` (trade, chain road icons). Stop header picture per adopt tier (not wired).
6. **Puzzles etc. (older, see archive):** Snail Trail 3rd puzzle game, Jeff `tada` redo, guest-friendly treks, open Puzzles to players once checked.

## Working notes
- Waves: a writer subagent per region drafts into the scratchpad, lint (`tools/lint_road_events.py DRAFT claude/drafts/item_slugs.txt --region X --prefix x-`, `tools/lint_stop_acts.py`), then merge into the data file and fix the pack-count tests (`tests/roadlife.php`, `tests/roadkinds.php`).
- Releases on Windows: `build_update.sh` breaks on a space in the repo path, a relative/unix output dir (MiKTeX zip) and CRLF in its file list. Run a patched copy (strip CR in the `while read` loop) with a space-free Windows-style out dir (e.g. `C:/Users/hello/gvzips`), then move the zips into `releases/`. Upstream may drop/redo a version number: `git fetch` first.
- Releases: `bash tests/build_update.sh <ver> 2.0.47 /home/user/gnome-venture/releases`, keep latest 4 versions in `releases/`, older to `releases/archive/`. The web updater skips a zip whose version is already installed: never rebuild a zip under the same version, bump instead (2.0.80 to 2.0.81 lesson).
- Push main = `git push origin HEAD:main`, only on Joshua's word. Do not push `git status` clean-ups of old branches without asking (see `claude/branches.md`).
- `choice_row()` escapes its text: pass plain text, never HTML.
- Anchors with `color: inherit` inside felt cards pick up the light page text on dark: use `--gx-felt-ink`.

## Explore: next (from `claude/explore-review.md`; 1-5, 7, 10 done)
- Region packs for the other 11 regions. 6 traces of other players, 9 festival/goal chips, 11 calling/animal lines, 12 delve room text, 8 Tales.
- Also: road_lines admin editor (draft status like trek text); 146 villages share 9 descriptions; 4 stop personalities lack chat lines; Haven text promises shops that don't exist; tundra thin.

## Treks: next
- Scenes next: Gloomtooth intro, Sorrel's door, signpost riddle as pop-overs (need speaker-tagged text); gnome reply lines are drafts.
- II-b watch: only 2 new crew moments. Road data files have no admin editor (road roll % settings done 2.0.16).
- Not built: Ch III-b to VI, Thorny/Bramble, respec, Lanternroot real crop, hats/stamp/trophy, trailmates 8 (4-7 built).


## Next (ideas, Joshua picks)
- No-typing social: preset postcards; follow a friend's trail; seed lineage.
- How-to-play "Folk & friendship" title still says Folk (title is DB key in ensure_almanac_howto; needs guarded migration).
- Satchel split stacks by quality; then turn `orders_food_quality` back on.
- Crops lose money on bought seed (radish sells ~4, seed 8-13). Look at seed price / yield / sell %. Quick option: `price_base_pct` 60 → 70.
- Later: cPanel cron for reminder emails; test site /testvault/ (code ready, skipped).

## Small / watch
- `walk_scene` row is deleted when a delve ends, so delve completion is not recorded anywhere; the plan's gate after the maps has no data source until a count is added (Usage has no map line).
- Trek map: open-zone walls flat grey; long walks enter from phone-window edge.
- "Community garden" tab wraps on phone. Sign/skin Buy buttons small.
- Friend watering duplicates garden water logic. Nudge crops-ready approximate; SMTP untested live.
- Seasons + hammer nav icons roughest.
- Travel card "via X" truncates at 390px with long names.
- Test noise: social100 2 FAIL on pristine (mid-tour); cook.sh map checks stale; games2.sh doesn't test payouts; walk.sh "INSTALL FAILED" flake under parallel runs.
- Balance (audit 2026-10-17): week 1 ~8.5k earned vs ~7k sinks (mild). Days 1-3 flush. Cosmetics no level check. Harvests ~73% of XP.
- MySQL watch: trek_ms table (1.8.9, untested on MySQL), trek_flag_set duplicate-insert catch on InnoDB.

## Parked (Joshua said not now)
- Combat intent/Guard, KO cost on road fights. Inbox. Test environment.
- Growing villages · caravans · more festivals · Duck Pond animal.

## Art
- Placeholders game/assets/img/ph/*.svg, palette ph/palette.json, guide = "Gnome Venture Art Guide" artifact.
- Names: `{item-slug}`, `creature-{slug}`, `npc-{slug}` (400×500), `{building}-{1..3}`, `{building}-{mossy|painted|lantern}`, `{fence}-{end|straight|corner|tee|cross|gate}`, `tile-{...}`, `stage-{kind}-{1..4}`, `land-{...}`, `banner-{code}`, `hat-{calling}`, `lm-{haven|wonder|delve|lair}`, `logo`, `nav-{gnome|almanac|satchel|crafting|garden|arranging|world|town|villagers|seasons|passport|games|trading|together|tasks|friends|account|today|festival|start|feedback|treks}`.
- Trek art needed: creature-{slug} for trek creatures (Ch I + Ch II incl. Silverfin), npc for Sorrel Inkcap + innkeeper (name TBD).

