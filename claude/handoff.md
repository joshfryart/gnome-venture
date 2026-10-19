# Gnome Venture: handoff (current as of v2.0.0.1, 2026-10-19)
Latest: 2.0.0.1 = Puzzles (puzzles.php, standalone page; see changelog). Versions after 2.0.0 are four-part (2.0.0.1, 2.0.0.2 ...) until Joshua says otherwise.

Read first in a new session: this file, `claude/todo.md` (now/next/watch/art), `claude/changelog.md` (full history to 1.9.5), `claude/plan-consolidation.md` (structure decisions). Treks: `claude/plan-treks.md`, `claude/trek-chapter1.md`, `claude/trek-chapter2.md`, `claude/trek-text-spec.md`, `claude/plan-trek-levels.md`.
Owner: Joshua Fry (admin). Neopets-style cosy garden browser game. Live: gnomeventure.ca. No monetization.
Project rules: Opus = final say/review only; Opus/Sonnet = planning/general; Sonnet/Haiku = coding/grunt work; always check agents' work (look at their screenshots, run suites vs pristine). Replies to Joshua: terse, short sentences, critical (not a yes man). Joshua is poor, on Pro plan: keep cost low.
Joshua uploads each release himself (Admin -> Update, or FTP). He play-tests on his phone (Firefox Android, dark) and desktop, sends screenshots with circles: keep doing polish passes (centering, folding, few words).
Joshua sometimes runs TWO sessions at once (e.g. one on Treks, one on polish/balance). If he says "hold, another agent is working": don't build/send; keep changes as commits/patch, then port onto his next source zip (git apply --reject, fix .rej by hand), bump version past his, re-test, build.
Mockups go in scratchpad only (not in project).

## State
- Built + sent: 1.9.5 (slim needs 1.4.1+). 1.9.5: Treks balance ignores gnome level (trek_base_level 15; only trek levels scale the party). 1.9.4 = road choices/meetings/wonder text + Treks Ch II-b (see changelog). 1.9.3 = road life (includes/road_life.php: road_pick anti-repeat ring, `cond` tags with `!` hard prefix, data/road_lines.txt ambient lines; see changelog). Explore plan: claude/explore-review.md. Live: whatever Joshua last uploaded (1.9.1 MySQL migration verified live). Next: see todo.md.
- 1.9.x: Treks chapter engine (per-chapter runs, interlude hub "The Shard Hollow"), Chapter II-a "The Weeping Clay", trek text editor upgrades (chapter tabs, drafts, ✏️ in-game pencil), Today page merged (no tabs).
- 1.8.x: Treks Ch I + fight redesign, tactics, Auto playback, trail events, trek levels + milestone XP, map art + walk animation; 1.8.2 `<dialog>` pickers + gvAsk/gvSay + tighter layout; 1.8.1 game Petals 60%, food quality off on orders.
- Done by Joshua: reminder-email postal address (CASL); opcache on. Waiting: CanSpace SPF/DKIM. Skipped: test site /testvault/.
- Testing tip: Playwright needs `bypassCSP: true` to inject trial CSS (site CSP is style-src 'self').

## Stack, hosting, layout
- Plain PHP 8.1+ and PDO. MySQL live (CanSpace Starter shared cPanel, Canada), SQLite for local tests. No framework, no build step. Vanilla JS (`assets/site.js`, `early.js`, `arrange.js`, `gather-games.js`, `trekfight.js`, `trekmap.js`, game JS files). One CSS file `assets/style.css` (tokens at top; dark via `:root[data-theme="dark"]`; versioned blocks at the end).
- Folders: `game/` (web root: pages, `includes/`, `admin/`, `assets/`, `uploads/`, `data/`) and `tests/`. Newest source zip holds the latest code; Joshua re-uploads it at the start of a new session. `git init` the unpacked source first.
- `includes/data/*.txt` = shipped content (importers add missing rows only). `includes/schema.php` = tables + `$c` column list (new columns added on db_version change) + `$i` indexes. Feature files may add their own tables via a `*_schema()` merged at the end of schema.php (e.g. `trek_schema()`).
- Host security layer blocked file names `npc.php` and `mod.php`: renamed `folk.php`, `modtools.php`. Be careful with risky file names.
- Hollow time = America/Halifax (`game_timezone`). Every day/week/month turnover is local midnight (`hollow_date`, `job_period_key`, `job_period_span`). Seasons 14 days. Weather/daypart computed on view, no cron.
- data/ is denied to the web by data/.htaccess. Error log rotates to .1 at 1 MB (includes/logrotate.php).

## Releases (how to package)
- Versions stay NUMERIC (PHP `version_compare`). Four-part like 1.6.9.1 is OK for hotfixes. Always go UP past whatever Joshua last got (another session may have shipped).
- Bump `APP_VERSION` in BOTH `includes/bootstrap.php` and `install.php` (also cache-busts CSS/JS/images via `?v=`). Player news in `includes/update_news.php` (newest entry first; skip for tiny fixes; don't announce hidden features).
- Lint: `for f in game/*.php game/includes/*.php game/admin/*.php; do php -l $f; done`. An apostrophe inside a single-quoted PHP string breaks the install: use ’.
- Commit, then from the folder holding `game/` and `tests/`: `bash tests/build_update.sh <new> 1.4.1 <ABSOLUTE outdir>` (relative outdir fails for the FULL zip) → manifest, slim zip, FULL zip, source zip. Commit the new tests/manifests/<ver>.txt after. Slim must contain bootstrap.php + index.php (script does it). Never hand-build. build_update.sh refuses merge-conflict markers.
- Send Joshua: slim web-update zip + source zip. FULL zip has no install.php (fresh installs use the source zip's game/ folder).
- Updater (`includes/updater.php`): needs admin password; DB dump + program zip first (keeps 5 DB, 2 program zips); never touches `config.php`, `install.php`, `data/`, `uploads/`; never deletes files; resets opcache.
- Parallel agents: give each a disjoint FILE list on one tree, private test copy + private walk.sh paths + own port; only one agent edits schema.php; agents never bump version or edit update_news; Opus wires menus (layout.php), settings_schema lines, bootstrap/seed upgrade calls. Tell agents CSS goes in a marked block at the end of style.css. Check after: `git diff` style.css has no lost lines.

## Upgrade-step pattern
- Bootstrap runs on db_version != APP_VERSION under `data/upgrade.lock`: `db_migrate` (schema), then ensure_*/upgrade steps in `boot_step(name, fn)` (logs failures to setting `boot_failed_steps`), plus `upgradeNNN.php` + `upgrade_NNN_run()` (flagged, idempotent). Latest: upgrade163, upgrade170, upgrade193 (`upg193_road_cond`), boot_step `ensure_treks` (trek_import), `market176_almanac`. Call new ones from bootstrap AND seed.php (seed only if fresh installs need it).
- Changing a default or shipped text: guarded step "only if the row still holds the old value". Avoid MySQL 8 reserved words. No TEXT defaults. MySQL rowCount = CHANGED rows only.

## Page map
- Menu (layout.php `nav_sheet()`): You (gnome.php, book.php, inventory.php, inventory.php?tab=craft), Grow (garden.php, arrange.php), Out & about (world.php, town.php, folk.php "Villagers", seasons.php, passport.php, games.php, 🥾 trek.php when allowed), Together (market.php "Trading", community.php "Together", jobs.php "Tasks", pals.php "Gnome friends"), Account at the bottom. Desktop >=1200px groups always open (`.navfixed`), 2-col tiles; 721–1199px same A4 look. Icons via `nav_icon($slug, $emoji, $px)`. Phone bottom bar: Garden, World, Satchel, Town, Tasks, More.
- jobs.php "📋 Tasks": ?t=jobs (sub ?p=daily|weekly|monthly|post) | quests | orders | errands. community.php "🌻 Together": ?t=garden | jar | about. games.php?tab=contests = contest hub.
- world.php: tabs here | map | gather | markets | travel; "Where to next?" box (`.gocard`, `.gotile`, `.nextup`).
- trek.php: ?t=map | party | pack | log. Admin: admin/treks.php (runs, reset), admin/trek_text.php (story text: chapter tabs, status filter, Claude's suggestion, Restore).
- Today (index.php, 1.9.2): one page, no tabs. Phone: greeting, news, 6 cards, Hollow, tip. Desktop: greeting, 3x2 cards (4-wide with Treks), Hollow | news+tip; rail hides weather/boosts/tasks on Today. `helper_slot()` shows one of welcome back > First Week > daily card > festival banner, none during Wren's tour.

## Treks (1.8.0+)
- NeoQuest-style party campaign. Files: includes/trek.php (state, map, walk, fatigue, camp, KO, bank, spots), trek_fight.php (party combat; copies adventure.php maths, keep-in-sync comments both sides; TREK_TUNE; trek_fight_ai), trek_data.php (schema, importers, `trek_text()`, `trek_inside()`, settings "Treks: …"), trek_levels.php, trek_events.php, trek_art.php (one SVG per map). JS assets/trekfight.js, trekmap.js.
- Chapters are data-driven: includes/data/trek_chapters*.txt (chapter/zone/ms/check/tune/finish rows; lift rows ignored since 1.9.5), maps trek_map_ch1.txt / trek_map_ch2.txt, spots, crew, creatures (landscape 'trek'), trek_texts*.txt + trek_drafts.txt (importer never overwrites body/status; draft used only when slot is new). Boss scripts via trek_scripts()/trek_script_register().
- Tables trek_runs (one row per user,trek,mode,chapter; state JSON incl. st.tl levels, st.tac tactics, st.plan), trek_party, trek_recruits, trek_pack, trek_flags, trek_texts, trek_ms (milestones paid; survives admin reset). users.trek_ch, users.trek_pet_day/today. State changes in `trek_tx` (users-row lock + re-read). Once-only payouts via flags.
- After a chapter: interlude hub "The Shard Hollow" (no replay; old run read-only). trek_godown carries recruits, levels, tactics, kits.
- XP: crew trek levels from fights (uncapped). Gnome XP ONLY from milestones (trek_ms_* settings, × 0.5–1.0 by checks; Ch II: ch2_sorrel 400, ch2_silverfin 1000, ch2a_end 800). `trek_xp_daily` retired.
- Gate: L15 + setting `trek_open` (default 0 = admins only). `trek_inside()` blocks road walks/explore/landmarks only.
- Caps: `trek_petals_daily` 150 per user/day; fights cost no energy; entry 10 energy. Carried Petals/loot bank at camp; KO loses 45% carried. Admin reset re-pays chapter rewards (UI warns).
- Ch II-a built (Seep Steps → Drowned Library/Silverfin → Potter's Row → closed Crossroads gate). II-b next (plan in trek-chapter2.md).

## Key conventions
- XP: `add_xp()`; `add_action_xp()` scales past `xp_steep_from`. Events: `job_event()` feeds Job Board, Callings, Hollow Goals.
- Mini-game Petals: wrap every game payout AND its Rules-text amount in `game_petals($n)` (setting `games_petals_percent`). Snail Race and Guess the Weight not scaled.
- Orders quality: `orders_food_quality` (default 0) → crop/preserve orders minq 0, diff 1. item_quality still recorded.
- Race safety: (a) conditional UPDATE/DELETE as claim + rowCount; (b) UNIQUE insert; (c) transaction + `UPDATE users SET id = id WHERE id = ?` then RE-READ. Any new repeatable Petal source needs a daily cap or energy cost.
- Anti-alt: `fresh_hold($u)`, `gnome_in_play_sql()`, `mentors120_same_origin()`.
- Visitor actions on gardens (visit.php): `gate_can_interact()`; guestbook = garden_stamps; watering = social169.php; one roll-up owner notice per garden/day.
- Email: `send_mail()` (mail() or SMTP via config smtp_*). Reminder emails only for verified + opted-in players (`users.email_nudges` default 0), unsubscribe link (unsub.php HMAC).
- In-place updates: page must be in `AJAX_PAGES` (layout.php). Links load in place if they match `a[data-inplace], main nav.tabs a, main nav.chips a, main nav.ccfilter a`.
- Tabs pattern `?t=`; POSTs return to their tab. Game pages: 🎮 Play / 📖 Rules (?t=rules).
- Popups: `<dialog>` + `gvOpenDlg`/`gvCloseDlg`; confirmations via `data-confirm` or `gvAsk`; never alert()/confirm(), never body overflow lock. Trek POST input via trek_post_str/int.
- UI rules (Joshua): CENTRE THINGS (text, headings, cards, buttons, result lines) — check every screenshot for it before shipping, and tell build agents; NO sideways scrolling; phone first (~412px, dark); fold explanations; few words; centred content in small cards on phones. `.choice` rows via `choice_row()`. Solid buttons only for primary verbs; no full-width lone buttons in wide desktop cards. Many-option filters = `<select>` GET form (`data-autosubmit`). Equal tile grids for action buttons. Keep the top bar slim.
- Theme: dark default; dark styles MUST use `:root[data-theme="dark"] X` (never @media prefers-color-scheme; `python3 tests/theme_css.py` converts).
- Art: real art → flower art → placeholder `assets/img/ph/{name}.svg` → emoji (`item_icon`, `ph_img`, `ph_or_emoji`, `nav_icon`). Generators tests/gen_ph_*.{php,py}. Names in todo.md.
- Maps: includes/maps_myc.php (MYC_VER bump when scenery/layout changes; currently 160b).
- Admin settings: labels "Feature: text". Per-feature `*_settings()` merged in `settings_schema()`.
- Security norms: CSRF on every POST, `require_login`/`require_admin`, ownership checks, `e()` escaping, rate limits, word filter, image upload checks, `uploads/.htaccess`, data/ denied. CSP style-src 'self' (no inline styles).

## Testing
- Suite: copy game/ to a scratchpad dir, remove data/ + config.php, `mkdir -p data`, `bash tests/walk.sh COPY PORT tests/router.php` (sprout / TestPass123!, admin / TestPassword123; sprout ends on tour step 10), then `bash tests/<suite>.sh COPY PORT2 tests/router.php`. One suite per FRESH copy. Compare against pristine (`git archive HEAD game | tar -x -C dir`).
- Key suites: walk.sh, treks.sh (+ tests/trek.php, trek_ch2.php, trek_levels.php, trek_tactics.php, trek_events.php), security190.sh, market100.sh, games2.sh (no payouts), explore.sh, landmarks.sh.
- Known noise: social100 "daily card: no [htdaily]" (mid-tour); animals120/pantry random flakes; worms/pjobs/reset fatals on pristine too; cook.sh 2 map checks stale; comm.sh PDOException on pristine too; walk.sh "INSTALL FAILED" under parallel runs. Game pages as admin redirect to welcome.php (mid-tour): use sprout in Playwright.
- Browser: Playwright + Chromium (`NODE_PATH=$(npm root -g) node script.js`), 390/412px phone, 900 + 1400px desktop. No rsync (use tar pipe).
- Upgrade test: install previous release via walk.sh, copy new game/ over, load pages, check db_version, new tables, boot_failed_steps empty, empty error log.
- MySQL can't be tested here; Joshua's live site is the check.
- Use `"${VAR:?}"` guards in rm. Never `pkill -f` with a pattern matching your own command line.

## Systems and numbers in force (admin settings unless noted)
**Energy/cooking**: Max energy 10 at L1, +5/level, +1 per Hardiness point; regen 1/min. Garden actions 1 (sheet mulch 2); tool tiers 20/30/50% free. Harvest 1/2/3 by tier. Games +1/+2 energy, no daily cap. Raw crops 1 energy (filling 2); dishes × `cook_energy_percent` 115. Pantry 600 Petals + 4 planks.
**Economy/XP**: Start 500 Petals, tour 250, First Week 700 total. Sell price `price_base_pct` 60 (drift 45–80). Sell mult Uncommon 130, Rare 180, Legendary 250. Perennial regrow 75% yield / 60% XP. Region medals 200/500/1,500. Fair 600/300/150, Best in Show 1000. GotM 1,500/800/400. Fresh hold 3 days / L3. Helping water: 1 energy, 5 XP, 5 Petals, 3 gardens/day. Mini-games 60%. Orders 150% base (×1/1.25/1.6), board 3, food quality off. Treks: Petals 150/day, gnome XP from milestones only.
**World**: 14 regions, start in The Maplewold. Callings L5, tier II L15, III L28. Hybrids L10+. Player mentors L20+. Rest stops 12 types, 55 activities. Treks L15+.
**Games**: Worm Hunting, Seed Memory, Snail Race, Seed Spitting, Guess the Weight, Mushroom Sweeper, Lost Letters, Pest Patrol, Fair, Village Show, Pumpkin Carving, gathering practice.

## Joshua-only tasks (off-site)
- Delete `install.php` on host. CanSpace backups; long admin password; cPanel 2FA; try Admin -> Update -> Restore once. Privacy text read by someone qualified.
- Reminder emails: SPF/DKIM (waiting on CanSpace); optional SMTP.
- Treks: edit/approve Ch I + Ch II-a text (Admin → Trek text), play-test, then turn on "Treks: open".
- SEO: Search Console + Bing, submit sitemap.php; get linked (Reddit r/WebGames, r/cozygames, itch.io, AlternativeTo).

## Open issues (current list in todo.md)
- Live/MySQL watch: hybrid neighbour CAST, mentor tables, users-row lock on InnoDB, garden_waterings/reacts, trek_* tables, trek_ms, trek_flag_set duplicate-insert catch.
- Treks before opening: no rate limit on trek POSTs (low). Cold rest weakened 1.9.4, fast travel blocked in treks 1.9.4, gnome level decoupled 1.9.5.
- Balance watch: crops lose money on bought seed; cooking 115%, order board 3, price drift, stop rewards, hybrid odds, mentor XP share, animal gifts. Stall prices uncapped. Cosmetic sinks no level gate.
- Tooltips still hover-only (minor, left): games.php tile blurb, race.php, weather label, ability buttons, yard edit tiles, community bed %, inventory tool purpose, adventure odds, region climate, guestbook.
- Ideas not built: growing villages; caravans; more festivals; mines; Hall of Fame; public region pages (SEO); inbox (parked); player search; trade price history; admin view-as-player / time-skip; admin 2FA; CAPTCHA; equipment slots; postcards / follow-a-trail / seed lineage; Satchel split by quality.
