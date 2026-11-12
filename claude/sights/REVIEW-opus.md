# Trail Sights: independent review (Opus)

Scope: `dd3f018f..HEAD`. **Note:** commit `adc62572` ("review fixes") landed *while this review was running*. All findings below are re-checked against HEAD (`adc62572`). Findings that commit already fixed are listed at the end so nobody redoes them. Line numbers are HEAD.

Ranking: BLOCKER = breaks a feature or corrupts state for everyone; HIGH = exploit or broken feature in normal play; MEDIUM = wrong result in a reachable edge case, or a real performance cost; LOW = latent, cosmetic or admin-only.

---

## BLOCKER

None remain at HEAD. The one blocker (a nested `beginTransaction` in `sightgift`) was fixed in `adc62572`. See "Already fixed".

---

## HIGH

### H1. Titles from Sights can never be chosen in the UI
- **Scenario:** a gnome earns `title=Stargazer` (it is stored in `user_sight_titles` and the journal says "🏅 Title: Stargazer"). On Almanac → Milestones the title `<select>` has no "Stargazer" option. The POST handler would accept it (book.php:25 merges `trail_sight_titles`), but the list that renders the options does not include it.
- **Where:** `game/book.php:244` (`$earnedTitles = … gourmand_titles($uid) …`). `trail_sight_titles($uid)` is missing. Line 25 has it.
- **Fix:** add `trail_sight_titles($uid)` to the merge on line 244 (`trail_sights.php` is already required at line 10). Better: one `earned_titles($uid)` helper that both places use, so this cannot drift again.

### H2. Stale beat indexes after a data edit leave quest lines stuck or finish them early
- **Scenario A (stuck):** a `seq` line has 5 beats and the gnome has done `[0,1,2,3]`. A data edit cuts it to 4 beats. Now `count($done)=4`, and `seq` opens beat `i` only when `i === count($done)`, but no `i` equals 4. The line can never finish, the Tasks page shows "4/4" and never moves to "finished", and `qd=` gates that wait on it never open.
- **Scenario B (wrong beat):** a beat is inserted in the middle of a line. Every stored index after it now points at a different Sight, so the gnome is credited for places they never visited, and `anylast` may open the last beat early.
- **Where:** `trail_sight_extras.php:195-206` (`trail_sight_quest_done` keeps any int), `:208-213` (`beat_open`), `:255` (completion is checked only when a new beat counts).
- **Fix:** store beats by a stable id (the Sight slug or `@kind`, plus an occurrence number), not by position. At the least, in `trail_sight_quest_done` drop indexes `>= count(beats)`. When `count(done) >= count(beats)` and `done_at` is NULL, finish the line (pay once) the next time the hook or the Tasks page reads it.

### H3. Quest completion can pay twice: no idempotent claim
- **Scenario:** the `@meal` event runs from `eat_item`. That path does not take the `UPDATE users SET id = id` lock that adventure.php takes, and it runs after `eat_item`'s commit. Eating a home-cooked meal in one tab while finishing the last Sight beat in another, or eating two meals at once in two tabs for an `@meal` last beat, lets both requests read `done_at IS NULL`, both reach `count($done) >= count(beats)`, and both pay `trail_sight_pay($q['reward'])`. The reward is coins, XP, items, titles and buffs. The same happens on the first beat: both requests insert. The second insert fails on the UNIQUE index and is skipped, but only *after* `give_item(-need)` has already taken the beat's item. That item is lost.
- **Where:** `trail_sight_extras.php:249-258`. The `UPDATE … SET done_at = ?` has no `AND done_at IS NULL`, and its `rowCount()` is not checked.
- **Fix:** `if (q('UPDATE user_sight_quests SET done_at = ? WHERE user_id = ? AND quest = ? AND done_at IS NULL', …)->rowCount() === 1) { pay }`. Run the beat's `give_item(-need)` *after* the insert/update succeeds, or put it inside the same try and give the item back on failure. In `trail_sight_quest_event`, take the user-row lock (`UPDATE users SET id = id`) in a short transaction, or make every write idempotent as above.

---

## MEDIUM

### M1. Trail map render does many repeated queries per page
- **Scenario:** every Trail page with 3 to 5 landmarks of a section runs:
  - `trail_sights_marks` 3 times (trail_view_html, the adventure.php footer, and again inside `trail_sight_folk_entry` on POST).
  - `trail_sight_state` 2 to 3 times per mark. Each call re-reads `users` (trail_sights.php:179) even though `$u` is in hand.
  - `trail_sights_folk_on_map` twice (trail_tiles.php:516 and adventure.php dialogs). Each call runs `trail_sight_now`, which does `stop_now` + tallies + `qd` query + `trail_pal_urls`.
  - `trail_sights_cards_html`, which per mark runs `trail_sight_now` again, `trail_sight_quest_notes` (2 to 3 queries per quest that names the Sight), `folk_here` → `folk_available` → `folk_id` (+ npcs lookups), and a `locations` query.

  This adds up to roughly 100 to 300 queries per step on a busy section, and every step re-renders.
- **Where:** `trail_sights.php:171-187`, `trail_sight_extras.php:609-670, 695-717`, `game/includes/trail_tiles.php:513-516`, `game/adventure.php` (footer + dialogs).
- **Fix:** compute `marks` and `folk_on_map` once per request (a static memo keyed by `exp id + x,y + tick`, or pass them from trail_view_html to the footer). Pass `$u` into `trail_sight_state` instead of re-selecting `users`. Read all `trail_sight_uses` rows for `(user, route, sec)` with one query. Build `$now` once per request.

### M2. `trail_sight_folk_id` still scans every village for names it cannot find
- **Scenario:** `adc62572` added a per-request memo and a short-circuit for town-NPC names. A name that is neither a town NPC nor an existing stop villager still loops over **every** village on every request. That covers a typo, and a generated name (`Ulric Tumblethorn`, `Tilly Wickerby` …) whose village has not had its folk made yet. Each village costs `stop_folk_ensure` (a COUNT, and the first time, inserts) plus a SELECT. As a side effect it creates stop_folk for the whole world. It runs on every map render through `folk_available` / `folk_pic`. `trail_sight_folk_available` also returns `true` for unknown names, so the scan repeats on every page.
- Also: `trail_sights_ensure_newfolk()` is static per request only, so it costs about 34 queries (17 newfolk × locations + stop_folk lookups) on every request that calls `folk_id`. That is every Trail render with a Sight.
- **Where:** `trail_sight_extras.php:386-410`, `:590-605`.
- **Fix:** pin every data villager with `@village` and have the lint reject unpinned names that are not npcs. Or keep a persistent name→id cache (settings/JSON keyed by the data signature). Give `ensure_newfolk` a settings signature like the one `trail_sights_ensure_items` now has.

### M3. Pick answers are fixed per gnome, Sight slug and day, so a second try or a second section is a sure win
- **Scenario:** `coast-the-shell-heap` is `pick:2` with `uses=2`. Lose once, then pick the other button: a certain win. The rows `310-driftpass`, `312-woodpecker`, `313-stickgate`, `314-driftwood` and `314-gullparliament` are `pick:3` with `uses=2`: after a loss there is a 50% chance instead of 33%. Shared-set Sights (e.g. `coast-*`) appear on many routes, and cooldowns are per `(route, sec)` while the answer is per *slug*. A gnome who loses at one coast route can play the same Sight on the next coast route that day with a known answer. Also, `hollow_unit` is a plain md5 of `'sgp|uid|slug|date'`, so anyone who knows the seed format can compute the answer.
- **Where:** `trail_sights.php:197-201`, `:254`.
- **Fix:** add `route|physSec` and the use number (`n` of the cooldown row) to the seed, so every try is a fresh draw. Or end the window after a wrong pick. Add a server secret to the seed (`setting('secret')`, or hmac).

### M4. Admin "Save" silently cuts long data rows (win lines up to 566 characters, schema VARCHAR(400))
- **Scenario:** an admin opens `312-greatstump` (win = 566 characters, several ` // ` variants) to change its energy and saves. `$f('win')` is `mb_substr(…, 0, 400)` and the textarea has `maxlength=400`. The win line is cut mid-variant, and the cut is permanent because the DB row now overrides the file. The rewards column is 255 and the data already reaches 247 (`end-wonder-2-forest`). One more token and the row cannot be saved (strict MySQL: "Data too long", uncaught → 500; non-strict: silent truncation that breaks a token).
- **Where:** `game/admin/trailsights.php:30`, `:56-58`; `game/includes/action_log.php` (`trail_sight_rows.win/lose VARCHAR(400)`, `rewards VARCHAR(255)`).
- **Fix:** make `win`, `lose` and `rewards` `TEXT` (or VARCHAR(2000)), raise the admin caps to match, and have the lint flag file rows longer than the schema.

### M5. The lint script passes when it never ran
- **Scenario:** observed during this review. `/tmp/sights-lint/game/data/game.sqlite` was an empty 4 KB file. `bash tests/trail_sights_lint.sh` printed **nothing** and exited **0**. `data/error-log.txt` shows `PDOException: no such table: settings` from `tests/trail_sights_lint.php(5)`. The bootstrap's exception handler swallows the fatal error and exits 0, so CI reports "lint ok" while checking nothing.
- **Where:** `tests/trail_sights_lint.sh:10`, `tests/trail_sights_lint.php:5`.
- **Fix:** in the .sh, capture the output and fail unless it matches `/^\d+ rows, 0 problems$/`. Or in the .php, `set_exception_handler(fn($e) => (fwrite(STDERR, $e) && exit(2)))` before the bootstrap. Also rebuild the scratch install when `SELECT 1 FROM settings` fails, not only when config.php is missing.

### M6. Pre-upgrade worlds: a quest beat's item is used up with nothing in return
- **Scenario:** before "Upgrade database" the `user_sight_quests` table does not exist. On a successful Sight use that is a beat with `take=` (e.g. `which-nettle` at `306-mosslog`, `take=mixed-up-letter:1`), `give_item($uid, need, -1)` runs (extras.php:249), then `db_insert` throws and is caught by `continue`. The letter is gone on every use and no progress is saved. Everything else degrades quietly, as the brief requires. This path does not.
- **Where:** `trail_sight_extras.php:249-254`.
- **Fix:** if `trail_sight_quest_row` failed because the table is missing, return early (probe once per request). Or move the `give_item` after the successful write (see H3).

### M7. The Almanac seeding lock does not lock
- **Scenario:** `trail_sight_claim` reads `setting($name)`, but `setting()` loads **all** settings once per request into a static cache (functions.php:768), usually during bootstrap. Two `book.php` loads that start together both read the old (empty) lock, both "claim", and both insert every Sight page (`encyclopedia_entries.unlock_key` is not unique, so the pages are duplicated). Duplicated pages are then unlocked twice and show twice. Also `set_setting` is check-then-insert: if `settings.name` is unique, the second request's insert throws, uncaught in book.php → 500 on first deploy.
- **Where:** `trail_sight_extras.php:96-102`, `:118-140`, `:559-573`.
- **Fix:** take the claim atomically. Use `INSERT` of a lock row and treat a duplicate key as "busy", or `UPDATE settings SET value = ? WHERE name = ? AND (value = '' OR value < ?)` and check `rowCount() === 1`. Wrap it in try/catch. Even better, add a UNIQUE index on `encyclopedia_entries.unlock_key` for `sight:%` / `sightpage:%` keys, or use `INSERT … WHERE NOT EXISTS`.

---

## LOW

### L1. A villager's tile takes over tap-to-walk, and two villagers can share a tile
- **Scenarios:**
  - When the only free tile beside a landmark is the villager's spot, tapping that tile opens their card instead of walking there. Players have to know to tap a farther tile and walk through.
  - Two landmarks next to each other can pick the same spot. Only the last villager gets the `data-pop` (trail_tiles.php:518 overwrites `$folkTiles`), and the first one's card can never be opened.
  - When no candidate tile is free, the villager falls back to the landmark's own tile (extras.php:709). The candidate offsets also ignore the sprite's width, so a villager can be drawn on top of a wide landmark.
- **Where:** `trail_sight_extras.php:705-709`, `game/includes/trail_tiles.php:518`, `:580-581`.
- **Fix:** skip spots already taken by another villager. Skip tiles covered by any `objs` sprite footprint. Only make a tile a `data-pop` when it is not the gnome's only walkable neighbour, or put a separate small button over the sprite.

### L2. Road chat and gifts need no proximity, and failures are logged as if they happened
- `trail_sight_folk_entry` checks that the villager is drawn anywhere in the section, not that the gnome is near them, so you can chat or gift from across the map. That may be intended, but the card text says "out and about by <Sight>".
- `trail_sight_folk_talk` returns `[$ok, '']`, so a refusal ("already had a present today", "You don't have one of those") is written to the journal as a normal line with no error flash.
- The town-NPC gift path calls `friend_claim('last_gift')` *before* `give_item`. If the item is gone (a stale card), the day's gift is used up with nothing given. It also ignores `npc_tastes` (loved, liked, disliked), so a disliked item still gives +2/+4.
- **Where:** `trail_sight_extras.php:776-815`.
- **Fix:** return `[$ok, $ok ? '' : $msg]` and only `exp_log` on success. Check the item quantity before `friend_claim`, or reuse `npc_gift(..., $door=false)` without its transaction, as `trail_sight_stop_gift` does.

### L3. `take=` ignores its own condition and chance, and the result of using the item up is not checked
- **Scenario:** `take=x:1?se=winter` is required and used up in every season. `first:take=` is used up every time. Two `take=` tokens for the same item are each checked against the full quantity, and then the second `give_item(-q)` fails silently (the reward is paid anyway). There are no such rows today, but the lint allows them.
- **Where:** `trail_sights.php:245-249`, `:278`.
- **Fix:** add the quantities per item, check them, and refuse `?`, `first:` and `@` on `take=` in the lint. Check the `give_item` return value. If it fails, treat the use as a failure.

### L4. Villager names without `@village` resolve to the lowest-id villager of that name
- **Scenario:** the `which-nettle` quest reward has `fpto=Nettle Cobblefield:2` with no `@village`. The quest is about two Nettles, and its giver is `Nettle Cobblefield@v-na-2-3`. Without a village, `folk_id` takes `ORDER BY id LIMIT 1`, which may be the same Mossgate Nettle (both friendship rewards go to one of them), depending on which village's folk were made first. Many generated names in the folk files are unpinned and can collide across villages in the same way.
- **Where:** `trail_sight_extras.php:400`. Data: `trail_sight_quests_maplewold.txt` (which-nettle Q row).
- **Fix:** pin it to `@<cloverholt slug>`. Have the lint reject an unpinned name that matches more than one stop villager.

### L5. Conditions inside `trail_sight_pay` see `st=normal` and no scene
- `adc62572` now passes `$u`, so `tl/tn/qd/pal` work. `st=` (sneak or hunt) is still always `normal` for villager and quest rewards because `$sc` is null.
- **Where:** `trail_sight_extras.php:419`.
- **Fix:** let `trail_sight_do` and `trail_sight_give` pass their `$now` into `trail_sight_pay(..., $now)`.

### L6. Undefined-index warning in tally lines when the table is missing
- `$now['tl'][key]` at trail_sights.php:260 when `trail_sight_tally` does not exist: `trail_sight_tallies` returns `[]`, which raises E_WARNING "Undefined array key" on every use of a tally Sight on a pre-upgrade world.
- **Fix:** `($now['tl'][$k] ?? 0)`, or skip the line when the add returned 0.

### L7. Lint gaps
- `cd=0` is accepted, which with `energy=0` means unlimited free uses. Require `cd >= 1`.
- Villager names in the folk files are never checked to exist. `trail_sight_folk_available` treats unknown names as present, so a typo pays silently and never shows on the map.
- `tool`/`check` rows saved with **Force** in admin reach `[$tt, $tier] = explode(':', …)` (trail_sights.php:241, extras.php:634) and give undefined-index warnings.
- `trail_sight_pick_answer` does not clamp N to 5 while `pick_info` does, so a forced `pick:7` row can have an answer (5 or 6) with no button: unwinnable.
- **Fix:** add these checks, and make the Force save still refuse rows that do not parse.

### L8. Sight-only quest items are seeded `tradable=1`
- `owl-letter`, `mixed-up-letter`, `lost-mitten` and the parcels can be sold, listed on the market, or given away as a "present" from the folk card's gift select (`stop_giftable`). A player can lose a quest key item by accident.
- **Where:** `trail_sight_extras.php:87`.
- **Fix:** add a `tradable` column (or a flag) in the items data, and set `tradable=0` for quest letters and parcels.

### L9. Unbounded growth and repeated parsing
- `trail_sight_uses` gets one row per `(user, route, sec, slug)` forever.
- `trail_sight_first` now also gets one `give:<md5>` row per give per day (trail_sights.php:333-336).
- `trail_sights_all` calls `trail_sights_file()` (a full re-parse of 4 files) once **per DB row** to compute `src` (trail_sights.php:70).
- **Fix:** periodically delete `give:%` rows older than today and expired cooldown rows. Hoist `$file = trail_sights_file()` out of the loop.

### L10. A beat whose `needs` item is missing is skipped silently
- Using `315-den` without the owl letter does not count the last beat, and nothing tells the gnome why.
- **Where:** `trail_sight_extras.php:249`.
- **Fix:** add a journal line: "📜 <quest>: you need 1 × Letter for the Owl for this step."

---

## Already fixed in `adc62572` (verified at HEAD)
- **(was BLOCKER)** `sightgift` to a stop villager called `stop_gift()`, which calls `db()->beginTransaction()` inside adventure.php's transaction. That threw a PDOException "There is already an active transaction", which only `UserError` is caught for, so every road gift to a stop villager was a 500. It now uses `trail_sight_stop_gift` (extras.php:818). Note that `tests/trail_sights.php` still has no test for the `gift` path through `trail_sight_folk_talk`. Add one.
- **(was HIGH)** `sightgive` could be repeated without limit (e.g. `232-berrypatch` Alder: 3 raspberries → 110 coins, `coast-the-kelp-line` Pomeroy: +40 XP, friendship each time). It is now once a day per row, using a `give:` key in `trail_sight_first`.
- `trail_sights_ensure_items` ran about 117 SELECTs on every Sight use. It now has a settings signature.
- `folk_id` now has a per-request memo and an npcs short-circuit. What remains is M2.
- The quest event hooks in `lair_victory` and `eat_item` are wrapped in try/catch inside `trail_sight_quest_event`.
- POST `slug`, `pick`, `idx` and `fk` are scalar-checked, and `pick` and `idx` are digit-checked.
- `hint=away` outside a village. Villager spots now avoid `S`, token tiles and gate tiles. Gate loops are caught by the lint.

## Checked and fine
- Double-submit in adventure.php: the `UPDATE users SET id = id` lock serialises Sight use, give, chat and gift (`uses`, cooldown, `first`, tally, `take=`).
- `trail_phys_sec` keys cooldowns by the physical stretch on reverse walks.
- Escaping of data and names in HTML and SVG (`e()` everywhere, the journal is rendered with `e()`). `data-pop` ids are ints.
- MySQL and SQLite: no reserved column names (`cond`, `chk`, `tkey` are used), CASE in UPDATE, NULL `got_tick`.
- The UNIQUE-index duplicate inserts are all in try/catch and do not abort the MySQL transaction.
