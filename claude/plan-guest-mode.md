# Guest mode + Jeff tour plan (Fable low, 2026-10-28, planned on 2.0.70)
Not built. Owner ask: logged-out experience = Jeff the Puzzler shows them around, real current-build screenshots replace old landing images; guests can explore most features but need an account to create their own gnome.

## Findings
- Logged-out branch `game/index.php` (hero 360x170 + 6 tiles 240x160 from `assets/img/landing/`, GIFsaw demo `#pz`, `includes/gifsaw_play.php`). Copy via `stext('home.*')` (`home.f1..f5`, `home.lede` exist but index.php hard-codes tile lines).
- `require_login()` (functions.php ~691) sends `onboarded=0` to welcome.php. A guest must own a gnome+plot: gate = "customise", not "have".
- `users.username`/`email` NOT NULL UNIQUE: guest rows get synthetic values (`guest_<hex>`, `<hex>@guest.invalid`).
- Reuse: `fresh_hold()`, `gate_can_interact()`, `rate_limited()` + `record_attempt` 1-in-50 self-purge, `puzzle_cast()` light/dark pairs, `tests/advshot.js`, `tests/security190.sh`.

## Decision: real `users` row, `guest=1` (not a shared read-only demo gnome)
A shared demo would need a write-block layer under garden.php, inventory, world, trek_tx and dozens of POST handlers; one leak corrupts the shared demo. Per-user row reuses the existing sandbox; cost = DB rows, bounded by caps + purge. Pre-made gnome "Sprout" via the same transaction as welcome.php `do=finish` (extract `includes/onboard.php: onboard_create($uid,$wf)`). Guest helpers live in `includes/guest.php`.

## Guest rules
- Create: `guest.php` (GET = Jeff + "Play as a guest"; POST + CSRF inserts row: role player, guest=1, guest_ip, onboarded=1, email_nudges=0, verified=0, random unloginable hash, normal session cookie). Caps: `rate_limited('guest',2,60)` per IP/hr, `guest_max_per_ip_day` 3, `guest_max_total` 200, `guest_ttl_hours` 24, `guest_open` default 0.
- Blocked (`guest_block()` Jeff card + Join button, and in shared POST handlers): market.php stall/trade/gift, pals, community posts/jar, feedback, report, letters composer, profile edit/uploads, account, visit.php actions, contest entries, puzzles_api start/finish + tournaments, treks (v1), mentors, any give_petals with a counterparty. `fresh_hold()` returns a guest reason first (global net). Add `AND guest = 0` to `$PLAYERS` (admin/usage.php), leaderboards, `gnome_in_play_sql()`, mail nudges, sitemap/public profiles.
- Allowed: garden, satchel, cooking, crafting, shops, town, world/map/gather/roads, almanac, games (payouts stay in the row), GIFsaw practice.
- Purge: 1-in-50 requests, delete guests idle > TTL plus dependent rows via one explicit `guest_purge()` table list (~40 per-user tables) + test that touches each feature then asserts zero orphans.
- Convert: register.php lets guests through ("Keep this garden?"); carry over = UPDATE same row (username, email, hash, guest=0, created_at=now so fresh_hold restarts), `mentors120_note_signup`, then slim customise-only welcome path (name/hat/beard). Fallback: logout + fresh register.
- Privacy/CASL: no email to guests; guest_ip kept until purge; one privacy-page line; rules checkbox at conversion.
- Analytics: counters `guest_made_total`, `guest_converted_total`; Admin > Usage row.
- Schema (additive): users.guest INT NOT NULL DEFAULT 0, users.guest_ip VARCHAR(45) NULL, index idx_users_guest (guest, last_seen).

## Front page: Jeff's tour
- Replace 6 tiles with 5-6 stops: real phone screenshot (412px, clipped, 2x file 412x320, shown at whole-number scale), Jeff pose + one 8-12 word line each (`home.tour.1..6`). Stops: Garden, Satchel/cook, World map, Town, Games, Almanac. Hero = garden shot with Jeff. Dark+light pairs (`.lt/.dk`, extend `puzzle_cast` or add `shot_pair()`). Keep "Try a puzzle"; add "Play as a guest" ghost button; Jeff line: "Make your own gnome? That needs an account."
- New poses: point, wave (Aseprite cast-*.lua + darken.py); fallback host/think/cheer.
- Pipeline: `tests/shots.sh` (walk.sh install, `tests/shot_seed.php` seed: grown plants, items, jobs, a road trip), `tests/shots.js` (Playwright 412x900, dark then light, deviceScaleFactor 2, animations disabled, bypassCSP hide chrome), output `game/assets/img/landing/shot-<stop>[-dark].png` quantised <= 60 KB. `tests/shots_stale.sh` fails on missing, > 80 KB, wrong size, or `tests/manifests/shots.txt` version != APP_VERSION.

## Releases
- 2.0.71 Rain Barrel (claude/plan-puzzle-games.md).
- 2.0.72 mockup of tour page (scratchpad, phone dark+light) for Joshua; then pipeline + stale test + front page + stext rows + `tests/landing.sh`.
- 2.0.73 guest core, `guest_open` 0: schema, guest.php, guest_block, fresh_hold hook, leaderboard filters, purge, convert; `tests/guest.sh` (cap per IP, blocked POSTs, no rows in trades/gifts/contest/puzzle_attempts/community, $PLAYERS excludes guests, purge leaves 0 orphans, convert keeps plot, CSRF, guest row not loginable).
- 2.0.74 in-game Jeff nudge strip for guests, customise-only welcome, Usage counters, open `guest_open`, news entry.
- Later: treks for guests, more Jeff poses.

## Risks
1 Pollution via a missed POST (62 pages): fresh_hold global + grep audit + suite. 2 DB growth on shared MySQL: caps + purge, orphan risk if list misses a table. 3 Guests skip tour/First Week/verify banners: Playwright crawl as guest for 500s. 4 Free second accounts: convert resets fresh_hold. 5 Edits in huge files: keep helpers in includes/guest.php.

## Joshua decides (defaults)
1 Keep progress on sign-up? Yes. 2 TTL? 24 h idle. 3 Caps per IP/day / total? 3 / 200. 4 Treks for guests? No in v1. 5 Six stops? Garden, Satchel, World map, Town, Games, Almanac. 6 New Jeff poses? Draw 2 (point, wave).
