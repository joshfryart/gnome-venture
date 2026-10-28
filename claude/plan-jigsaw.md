# Jigsaw plan: classic picture jigsaws, fixed tiers, tournaments, admin (Opus high 5.5, 2026-10-28)
Target release: **2.0.87** (one number, everything behind flags, off for players). Status: plan only, nothing built.
Git check (2026-10-28): main tip is 2.0.84 (`9c13cd26`). No 2.0.85 or 2.0.86 branch/tag is visible; 2.0.86 is building elsewhere. So: do not touch `bootstrap.php` APP_VERSION / `CHANGELOG.md` / `handoff.md` / `todo.md` until 2.0.86 lands; then `git fetch`, merge main, bump to 2.0.87 last (`tools/check_versions.sh`). Never rebuild a zip under an installed number.

## 1. What and why
GIFsaw (`gifsaw.php`) = animated GIF jigsaws, free piece count (24/54/96/150), tournaments exist. Add **Jigsaw** = normal still-picture jigsaws from our own generated art, in the Puzzles hub as its own card. Same engine, same tournament machinery, different library.
Differences from GIFsaw: still JPEG, no Motion button, **no free piece choice**: three fixed tiers, tournaments per tier, own admin area.

## 2. Tiers (fixed, server-owned)
All pictures are exactly **4:3**, so the grid is exact (no rounding like `puzzle_grid_total`).
| Tier | Grid | Pieces | Tries/day in tournaments | Min believable time (400 ms/piece) |
|---|---|---|---|---|
| Easy | 6 x 4 | 24 | 10 | 9.6 s |
| Advanced | 12 x 8 | 96 | 10 | 38 s |
| Expert | 18 x 12 | 216 | 5 | 86 s |
- One constant `JIGSAW_TIERS` in new `includes/jigsaw.php` (`slug => [label, cols, rows, tries, icon]`). Server derives pieces from the tier. Never trust a posted piece count. The JS reads the tiers from a JSON block.
- Joshua's call (default above): 24/96/216, scale 1:2:3 so grids stay tidy. Fallback if Expert lags on a mid phone: 150 (15 x 10); one-line change.
- Expert risk: ~20 px pieces on a 360 px phone. Phone gets a non-blocking "best on a tablet or computer" note + existing zoom + tray (edge pieces first). Gate: Playwright perf pass (see tests) before opening Expert.

## 3. Design decision: extend, don't fork
Reuse `puzzle_pics`, `puzzle_tournaments`, `puzzle_attempts`, `puzzle_board()`, `settle_puzzle_tournaments()`, `puzzle_badges_html()`, `puzzles_api.php`, `puzzles.js`, `puzzles.css`. Add a `kind` ('gif' | 'still'). Gains: leaderboard, settle, badges, notify, void, flags, rate limit, tests all free. Cost: every existing query must filter by kind (list below). Rejected: separate `jigsaw_*` tables (duplicate settle/badge code, two profile shelves).

### Schema (additive, via the `db.php` column migrator; also in `puzzles_schema()` for fresh installs)
- `puzzle_pics`: `kind VARCHAR(8) NOT NULL DEFAULT 'gif'`, `cat VARCHAR(24) NULL`, `thumb VARCHAR(120) NULL`, `reserved INT NOT NULL DEFAULT 0` (hidden from free play until its tournament settles).
- `puzzle_tournaments`: `kind VARCHAR(8) NOT NULL DEFAULT 'gif'`, `tier VARCHAR(8) NULL`, `cup_id INT NULL` (links the three tiers of one cup).
- `puzzle_runs` (already exists, built for practice runs): add `pic_id INT NULL`. Jigsaw free play = `game='jigsaw'`, `mode='practice'`, `size`=pieces. Gives "my best per picture + tier" and "solved" stamps without a new table. Pays nothing.
- Index `puzzle_tournaments (kind, status, ends_at)`.
- Existing rows default to 'gif': nothing changes for GIFsaw.

### Queries that MUST gain `kind` (a missed one leaks stills into GIFsaw or the reverse)
`puzzle_pics()` (add `$kind` arg, default 'gif'); `gifsaw.php` live list; `puzzles.php` `$live` check; `games.php` tile badge (show 🏆 if either kind is live); `admin/puzzles.php` lists + `tour_save` (force kind 'gif'); `puzzle_tourney()` callers: `gifsaw.php?t=` of a 'still' tournament redirects to `jigsaw.php?t=`, and the reverse. Test both.

## 4. Player side
Files: `jigsaw.php` (library + tournament page, copy of `gifsaw.php` shape), `includes/jigsaw.php` (tiers, builtin list `JIGSAWS`, helpers), `includes/gifsaw_play.php` reused (table markup) with `$pzMode`, `assets/puzzles.js` gets a `still` mode. Hub (`puzzles.php`): Jigsaw card first, GIFsaw second (hardcoded cards like GIFsaw, NOT in `PUZZLE_GAMES`, which is daily-game shaped). `games.php` Puzzles tile unchanged.
- **Library page**: category chips (admin tags), picture cards (thumb, title, 3 tier chips; chip filled = you solved it, shows your best). Tapping a tier chip starts that tier at once. No piece-count picker anywhere.
- **Play table**: `#count` select becomes a read-only tier label in still mode; Motion button hidden; Guide, Scatter (Ffej), zoom, Copy link (`jigsaw.php?p=slug&k=easy&seed=N`) stay. Tournament: no link, tier locked, as GIFsaw.
- **Free-play timing**: logged-in non-guest runs call `puzzles_api.php` `do=pstart` / `do=pfinish` (new, practice only, same CSRF/rate limit/min-time rules, no tournament gate, needs `jigsaw_open`). Guests: client-only, nothing saved (mirrors GIFsaw).
- **Win card**: time, tier, personal-best line, "Next tier" button (Easy -> Advanced -> Expert), "Another picture".
- **Save and resume (IN 2.0.87, Joshua said yes)** (Expert takes 30+ min): `localStorage` per pic+tier+seed with group positions; "Continue" chip on the card. Try/catch every access (site rule). Not in tournaments (clock is server-side).
- **Tournaments (player)**: reuse GIFsaw tournament page copy: phase line (soon/open/closing/settled), start button, daily tries left, leaderboard, your best, place + cast badge. A cup (3 tiers) shows three tabs. Before start the picture is a "mystery" card (no thumb printed). Reserved pictures stay out of free play until settled, then release into the library (fairness: no pre-practice). File names are random hex.
- **Rewards**: cosmetic only, same as GIFsaw: trophy/badge on the profile shelf (`puzzle_badges_html`, add a small tier pip next to each badge, CSS-composed from the tier icons, so no per-tier trophy art). Notify on place. News item when a tournament opens, only once players can see Jigsaw.
- **Trust** (as GIFsaw): server clock, single-use token, `PUZZLE_MIN_MS_PER_PIECE`, `drops >= total-1`, grace 10 min, top-3-under-a-third-of-median flag, admin void. Known limit: a solver bot is not stoppable by design, same as GIFsaw (picture is public to the player).

## 5. Settings (Admin > Settings, off by default)
`jigsaw_open` (needs `puzzles_open`), `jigsaw_tournaments` (needs `jigsaw_open`), `jigsaw_tries_easy|advanced|expert` (10/10/5), `jigsaw_reserve_days` (days a settled tournament picture waits before it joins free play; default 0). Admins always see Jigsaw (`puzzle_game_open` pattern). Add `jigsaw_tournaments_on()` beside `puzzle_tournaments_on()`; `puzzles_api.php` picks the check from the tournament's kind.

## 6. Admin areas (new `admin/jigsaw.php`, menu line next to GIFsaw in `admin_menu.php`)
Shared tournament form/leaderboard/runs markup moves from `admin/puzzles.php` into `includes/admin_puzzle_ui.php` and both pages call it (refactor, behaviour identical for GIFsaw, covered by `tests/puzzles_tourney.sh`).
Tabs:
1. **Library**: thumb, title, category, on/off, reserved, order, soft-delete, plus counts (free-play solves per tier, tournaments used). Edit title/category/order/active/reserved.
2. **Upload**: multi-file (up to 25). Accept JPEG/PNG/WEBP up to 3 MB. Require 4:3 within 1%, min 1200 x 900, max 2400 x 1800 (else refuse with the numbers; no silent crop). GD re-encodes to 1600 x 1200 JPEG q85 (strips EXIF) + 400 x 300 thumb into `uploads/jigsaw/{hex}.jpg` / `-thumb.jpg`. Category + "reserve for a tournament" at upload. No GD = clear message, like GIFsaw.
3. **Tournaments**: list with kind/tier/status filters. Form: title, picture, **tier radio showing piece count**, start/end in Hollow time (`puzzle_to_utc`), status draft/live. Buttons: "Make all three tiers" (creates a cup: 3 rows sharing `cup_id`, times and title suffix), Duplicate, Cancel (void all, no places, no notify), Settle now. Detail: live leaderboard, flagged top-3, recent runs with Void + reason (`admin_log`), CSV of results.
4. **Schedule (MOVED TO 2.0.88, Joshua said yes; not built in 2.0.87)**: weekly cup template (weekday, hour, tier set, pick next unreserved picture in a category). Created lazily by `settle_puzzle_tournaments()` so no cron needed.
5. **Settings** link card to the four settings above.
Each save: `csrf_check()`, `admin_log()`, validate tier against `JIGSAW_TIERS`, pieces from tier.

## 7. Art needed (new). Rule: placeholder = red border + "THIS IS PLACEHOLDER" (`tools/gen_placeholder_art.py`); real art replaces by same name. Sticker poses follow `claude/jeff-poses.md` (64x64 v2 body, semi==0, bw==0, margin>=3, readable at 38 px, all with `-dark` via `darken.py`).
**Cast, in `assets/img/puzzles/cast/`**
| File | What | Where used |
|---|---|---|
| `jeff-piece` (+dark) | JEFF holds up one jigsaw piece, grinning | Jigsaw library host, hub card, win card |
| `jeff-headband` (+dark) | JEFF in a focus headband, squinting (Expert) | Expert tier tournament host, Expert win |
| `ffej-pocket` (+dark) | FFEJ with a piece poking from his pocket, sly | Scatter line, "one piece missing" joke, reserved/mystery card |
| `wizard-lid` (+dark) | The Old Wizard holds the box lid (the picture) | Guide button tip, Guide help |
| `jeff-think`, `jeff-trophy`, `jeff-cheer`, `jeff-host`, `wizard-hourglass`, `wizard-hint`, `empty-box`, `win-scene` | exist | reuse (Advanced host = `jeff-think`) |
**Banners and tiles**
| File | Spec | Where |
|---|---|---|
| `jigsaw-banner` (+dark) | like `puzzles-banner` | Jigsaw library top |
| `tourney-banner-dark` | `tourney-banner` has no dark twin today | both tournament pages |
| `tile-jigsaw` (+dark) | like `tile-puzzles` | hub card icon |
| `win-scene-jigsaw` (+dark), optional | finished-picture celebration | win card |
**Icons** (inline `ico-*` system, Part B of the style guide, heavier pens; add via the documented steps and rebuild the guide PDF)
| Name | Use |
|---|---|
| `ico-piece` | admin menu line, nav, replaces the bare 🧩 on the Jigsaw card |
| `ico-tier-easy`, `ico-tier-advanced`, `ico-tier-expert` | tier chips, tournament lists, badge pips (e.g. 1, 2, 3 interlocked pieces or sprout/bud/bloom) |
| `ico-cup` | multi-tier cup in lists |
| `ico-box` | Library / "put back in box" |
**Pictures (our own generated images, not Aseprite)**
- Master 1600 x 1200 (4:3), shipped JPEG q85 + 400 x 300 thumb, no text, no logo, no frame. Name `<slug>.jpg`, `<slug>-thumb.jpg`, folder `assets/img/jigsaw/`.
- Content rules: detail across the whole frame (flat sky/water kills a 216-piece puzzle); varied colour regions so pieces can be told apart; no repeating wallpaper patterns; avoid a symmetric centre; no tiny text.
- Launch set: **14**, one per region (Maplewold, Maizehollow, Dunewhisper, Blossomreach, Sunsprinkle Isles, Rainroot Reaches, Mistmoor, Olivewhistle Shore, Birchbramble Steppe, Greatcanopy, Thornacre Savanna, Spicepeak, Monsoon Tangle, Coralscatter) + 3 placeholders to build against. Later drops: seasons, the cast, kitchen/garden scenes, tournament-reserved pictures (about 1 per tournament).
- Categories (admin tags): Regions, Seasons, Critters, Cosy rooms.
**Existing art touched**: none changed. `puzzle_cast()` returns '' for missing art, so every new file can land late without breaking a page.

## 8. Tests (new `tests/jigsaw.sh`, added to CI; extend `tests/puzzles.sh` only for the kind filter)
Tiers: posted piece count ignored/rejected; grid = 24/96/216 exactly for 4:3. Upload: 4:3 ok, 16:9 refused, tiny refused, EXIF stripped, thumb made, no-GD message. Kind isolation: GIFsaw library never lists stills and the reverse; cross-kind `?t=` redirect; hub/games badge. Free play: `pstart/pfinish` records best, pays nothing, too-fast and too-few-drops rejected, guest blocked, flag off = 403. Tournament per tier: lifecycle soon/open/closing/settled, tries 10/10/5, void, cup of 3, reserved picture hidden then released, settle places + tier pip on profile, cancel gives no places. Admin: CSRF, non-admin 403, bad tier refused, `admin_log` rows. Browser (Playwright, `bypassCSP`): 24/96/216 piece DOM counts, Easy solvable by scripted drag, Expert on a 360 px viewport (no horizontal scroll, tray works) and a frame-time budget; dark theme cast art swap. Run all existing puzzle suites against pristine first.

## 9. Build order (all in 2.0.87; each step shippable behind flags)
| Step | Work | Size |
|---|---|---|
| A | Schema + `includes/jigsaw.php` + kind filters + 3 placeholder pics + `jigsaw.php` library + still mode in `puzzles.js` + `pstart/pfinish` + hub card + settings | M |
| B | Tournaments on `jigsaw.php` (tier, cup tabs, mystery card, reserve) + profile tier pip + settle/notify | M |
| C | `admin/jigsaw.php` (Library, Upload, Tournaments) + shared UI refactor + menu | M |
| D | `tests/jigsaw.sh` + Playwright Expert perf pass + CHANGELOG/handoff/todo + `tools/check_versions.sh` + zips/manifest | S/M |
| E | Save and resume (in 2.0.87); Tidy button (rows, optional). Schedule tab = 2.0.88 | M |
Who: Sonnet agents code A to D; Haiku for placeholder art + bulk checks; Opus reviews once at the end (look at the screenshots, run suites vs pristine). Plan then pause for Joshua before B if A looks wrong.

## 10. Joshua's calls (decided 2026-10-28)
1. Tier sizes **24 / 96 / 216**: OK.
2. Save and resume in 2.0.87: **yes**.
3. Weekly Schedule tab: **2.0.88**.
Still on defaults (shout if wrong): Expert 5 tries/day (others 10); launch 14 region pictures + 3 placeholders; reserved tournament pictures hidden until settled; one shared trophy shelf with tier pip; cups (3 tiers) in 2.0.87; players see Jigsaw only when `jigsaw_open` is flipped.

## 11. Not now
Daily jigsaw (the `puzzle_daily` plan in `plan-puzzle-games.md` covers other games), seasonal champion points, portrait/other aspect ratios, player-uploaded pictures, rotating pieces, co-op/shared tables.
