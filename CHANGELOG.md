# Changelog

## 2.8.79
- **Puzzle fight speed: new 1.25x.** The speed button now goes 1x, 1.25x, 2x, Skip (and the help sheet lists all four). 1.25x is a quarter faster than 1x (measured: a medium-board turn replays in about 9.2 s at 1x, 7.4 s at 1.25x, 4.7 s at 2x). Saved per device like before (`pfvspd`). Source: `tools/pfboardv1_part.js`.

## 2.8.78
- **Puzzle fight, before and after:** the pre-fight screen is a "Face-off": you and the creature side by side with your bars, then tabs (Your deck / Its pieces / Rules), Let's fight pinned at the foot. A phone held sideways puts you and the creature on the left and the tabs on the right; a desktop shows all three at once. The result card is a coloured outcome hero with three number tiles, the tool wear and pinned buttons (two columns when wide). Tests follow the new markup (`tests/pbox_v1.sh`, `tests/pbox_v1_shots.js`).
- **Sideways phone combat (thumb rails):** hand down the left edge, board in the middle, bars and buttons down the right edge, all grouped in the middle of a wider window. The right edge is two lists under one status line: the history (scrolls, newest at the top) beside the environment (its chip, what it has coming, help, speed, the piles). Desktop windows get the same two-list right edge. The tapped piece's card shows only when a piece is tapped. New `tests/pbox_v1_shots.js` switches: `PFVP='[[780,360]]'` (windows), `PFRULES=new` (fights with the rules a new fight has), `PFSKIPBOX=1`.
- **Buttons are jigsaw pieces:** Undo, End turn and Flip, and a smaller row of Box, Hint and Run, each its own colour; a round knob on each piece sits in the round pocket of the next (sideways phone and desktop).
- **Half-speed replay:** the old 1x is now 2x, the new 1x is half the old speed (replay cap 16.9 s at 1x). `SLOW` in the fight script.
- **Piece jigsaw veil:** the pieces that cover the fight in and out now cover the whole window at any size, fade, refit on resize or rotation.
- **History chips say more:** a chip tapped for a rewind shows the full line the replay gave, the move, the numbers at that step and what the piece does (new `ln` / `nm` on a history chip).
- **Private test site:** `bash tools/build_test_site.sh <outdir>` builds the packages for a separate test copy (e.g. test.gnomeventure.ca): the site zip (with `install.php`, a `robots.txt` that blocks search engines, a noindex header and `TEST-SITE-README.txt`) and the trail ground art in parts. Later updates go on through the test site's Admin > Update.
- **Build sources:** `game/assets/pfboardv1.js` is generated; the changes above live in `tools/pfboardv1_part.js` and `tools/build_pfboardv1.py`.

## 2.8.77
- **On by default:** Shared Sights (`sights_shared_on`), picture navigation (`gnav_on`: Here page, `gnav_tree`: Treehouse, `gnav_tiles`: tile walks), the slim Home (`home_slim`) and the Crafting workshop picture (`gnav_craft`). One boot step turns all six on once for an existing site; an admin can set any back to 0 and it is kept.
- **Slim Today:** Wren's Journey card is back (current chapter, progress, next hint). The "Your pals" bar no longer uses an inline style (CSP): it is a `<progress>`.
- **Visitor smell:** the kitchen peek says "bubbling away and it smells of" the last-cooked dish.
- **Tests:** suites that assumed the old pages are pinned or adapted (marked 2.8.77).

## 2.8.76
- **Hotfix:** a live `first_week.php` called `craft_link_fix()`, which this repo never had, so Home (`gnome.php`) died with a fatal error. `first_week.php` is shipped again (it replaces the live copy) and `craft_link_fix()` exists as a harmless stand-in in `here_schema.php`.

## 2.8.75
- **Villager art:** moth villager 1 reads as a moth (no bear snout, ringed eyes, comb antennae); butterfly villagers 1, 2 and 3 redrawn with clean round faces and visible wings; tortoise villager shells 1-3 clearly show their scutes.
- **Stop and trail art:** lair sleeper muted from bright purple to taupe (7 sprites), taprow sap buckets with syrup and drips, a quay at the coast market, wetland animals about 2x, tundra camp / ferry animals bigger, new rainforest tower roof, stuffed-peppers-goat redrawn.
- **Wearables:** 7 front cloak / pack avatar layers redrawn; 42 outfitter-staff portraits (`ph/npc-<slug>.png`, placeholders from the folk portraits).

## 2.8.74
- **Garden badge counts crops that finished overnight:** the dock, the menu sheet and `dockstate.php` counted ripe crops from the stored growth only, so after a sleep (sleep-days clock) the Garden count lagged until the garden page was opened. New `garden_ready_count()` (`includes/garden_logic.php`) settles growth in memory (nothing saved) and is used by `dock_garden_ready()` and `nav_groups()`. Dock tiles now carry a `slug`, and `dock.js` patches the Garden badge by slug, not by the label. `tests/dock_badges.php` covers it.
- **Route ids (W4 bug):** a fresh install numbered routes one lower from 239 up, so 234 routes picked up the neighbouring route's trail map, camp and road kind. `lay_roads` now burns the dead-end leg's id again. New suite `tests/route_ids.sh`. Worlds installed after commit e21c8d65 and before this fix keep shifted ids (needs a manual renumber).
- **Very short landscape (640x260):** the hovel tabs stay on one row above the dock, and the tour "Show me now / Later" card no longer clips its top (`dock.css`).
- **Dock labels on very short windows (under 340px high):** 12px instead of 11px in the 75% dock, so they render at 9px, not 8.25px (`dk-small` class, `dock.css`, `dock.js`).
- **`tools/renumber_routes_239.php`:** one-off repair for a live world laid with the route-id bug (ids one low from 239 up). Dry run by default; `--apply` backs up, shifts routes and every `route_id` table in one transaction, verifies, rolls back on any mismatch.

## 2.8.73
- **Fight rigs:** the last 10 rigs redrawn in Stitched Toy and swapped in (bramble-wolf, badger, giant-anteater, dust-sidewinder, gnat-cloud, dune-scorpion, ashen-ant, bellcap-beetle, ember-beetle, grub-beetle; cistern-newt unchanged). Crew text now "They work every morning at 06:00."
- **Stop art redrawn (owner marks):** 12 type icons, 12 passport stamps, 12 town place cards, 7 route cards, 14 shops-street scenes, 42 of 48 stoptier stickers (mill-1, workshop-1 to 4 and spring-3 kept as before). Route cards (no gnome, no baked-in animals) now also stand in as the picture of a haven / wonder / delve / lair popover that has no scene of its own (`landmark_scene`, `.lmscene-card`).
- Removed unused `scenes/banner-market.png` and `banner-village.png`.

## 2.8.72
- Workflows W1b, W2, W3, W4, W1, W1a plus owner asks (a workflow of agents; none seen on a real phone, all checks headless Chromium / SQLite):
- **Dock left/right actions audited on every page (W1b):** about 29 pages got fitting L/R pieces (tend, mentor, profile, report, customise, puzzles hub and games, race, worms, letters, carve, gotm, feedback, workshop, residential, door, back, festival, palyard, market, firstweek and more). New: trek L Map / R Go (Fight, Go: one tap per page load, Go aims at the page's own objective tile), pals Find tab R Find (focuses the name box). Dock Take / Deliver pick the first offer / order that can be taken / filled; dock List opens the stall fold; dock Rest posts in place on the classic home.
- **Mobile / landscape dock (W2) and new game in landscape (W3):** many image-size and text-placement fixes in `assets/dock.css`; tour card gets a "tour-away" chip so it never covers Wander buttons.
- **Tutorial: the radish now needs one sleep in your hovel.** New tour step 10 "Sleep in your hovel" (button to the hovel, highlights Sleep in the page, dock and clock pill); one sleep ripens any watered crop of 20 minutes or less; the step skips itself when the clock is off. **Days are game days everywhere (Day 1 first):** pill, header, hovel, rest summary, dock plate.
- **Shop: the Wanted chip is now a "W" in the bottom-left of the tile, with "W = Wanted" at the top of the Sell tab** (market day tiles too).
- **Fewer clicks (W1a, owner-ticked):** harvest dialog closes by itself (3 s, 6 s with a level-up); default seed is the bed's last seed, batch picker pre-picks it ("Plant N"); Kitchen card Cook link; **Replant all / Till & replant** (same energy and seed cost as by hand); Cook again; "visitor can smell it" names a dish still cooking; Tasks opens on the tab that has something ready; First Week reward from the Home Today card; fast travel lands on Here; Hovel link on the home village Here page; run-away result card gets Go deeper / To the road on explore walks; **Quick turns** (off by default, Puzzle box page): End turn fires 0.7 s after a piece is placed, Undo cancels; trail **Walk to the way on**; shop Sell defaults to the whole stack plus **Sell all crops** (confirm line).
- **Purple random-event banners go to the bell with the dock (landscape phone and desktop).** A finished "Something has happened!" banner (and the Puzzle Pal hello, and any other `.eventbox` that is not waiting for a choice) now lights the bottom-right bell and shows its title, text and lines for a few seconds; portrait phones keep the banner in the page, banners that wait for a choice (rock-paper-trowel, quiz, duel) stay, prize banners stay (`gvEvToBell`, `assets/site.js`). Checked in headless Chromium at 844x390, 1280x800 (bell) and 390x844 (banner).
- **Garden crew works the new morning, not the night that ended (owner: "it still tells me I have stuff to do in my garden, feels like I'm getting twice the reward").** At each sleep the beds' growth is now brought up to date first, so the Harvest pal picks everything that is ripe that morning (nothing turns ripe later the same day for you to pick by hand at the full player rate), and the Water pal waters for the new day instead of the day that ended (beds are no longer thirsty all day, Water all has nothing to do). No double pay: a bed the crew picked cannot be harvested again. Also fixed: a bed with pests AND weeds kept its weeds after the Pests pal cleared the pests (the save was skipped). Unchanged: crew order, share, XP, tiredness, rain skipping the water step, Plant timing, and everything with no pal on a slot. `includes/pal_crew.php`, `tests/pal_crew.php`.
- **Garden crew: staying up past 06:00 counts as the morning too (owner: "should pick in the morning for that day, so you don't need to do anything").** The crew now works once at every 06:00 the game clock reaches, slept or not: past 06:00 without a sleep, the next page load runs that morning's pass (beds of a crewed garden settled through the day just played, ripe crops picked, beds watered for the coming day, report and notice as after a sleep). The sleep that follows lands on the same 06:00 and does not work it again: no second harvest, no growth counted twice, and 1/3/7 jobs count mornings worked, not sleeps. New column `users.crew_morning` (added by Upgrade database or the crew's own check); a look at the garden before that sleep keeps the crew's day (`gclock_tile_grow` keeps a one-day lead), and other waterings never lower the crew's `water_day` (`GCLOCK_WATER_DAY_SQL`). No crew: unchanged. `includes/pal_crew.php`, `includes/game_clock.php`, `includes/bootstrap.php`, `tests/pal_crew.php`.
- **Cat Fish: the four Rod upgrades now show in the new room.** Longer string, Springy rod, Rod motor and Double rod only changed the old page's picture; the canvas room never read them. Now: Longer string hangs the fish 8 px lower, Springy rod bobs each fish 3 px, Rod motor turns the wand a little, Double rod adds a second wand at the ceiling (still under reduced motion). All 15 other visual upgrades were checked one by one and already painted. The scene key now includes the owned upgrades. Note: the Sunbeam is only drawn 08:00 to 18:00 local time (by design). `assets/catfish_room.js`, `includes/catfish.php`, `tests/catfish.sh`, new `tests/catfish_room2.js`.
- Garden crew Plant step: a bed the crew plants now starts growing on the new day (`grow_day = D`), the same as a bed you plant by hand that morning (it was one day early, so crew-planted beds could grow one share faster). `includes/pal_crew.php`, `tests/pal_crew.php`.
- Code review (W1): stale comments, dead guards and unused functions removed in about 100 files (no include path changed). Wording changes: `nettle` herb emoji, haven rest label +6 when rebuilt, curio count as a digit, "Nothing to buy here today.", pantry help in sleeps, town square note, guide "Eight" daily games.
- Routes (W4): see claude/todo.md for the open route-id offset bug in `roads.php` `lay_roads`.
- **Art:** 116 more fight rigs redrawn in Stitched Toy and swapped in (8 pilots already in). 6 still old art: bramble-wolf, badger, giant-anteater, dust-sidewinder, gnat-cloud, dune-scorpion. Mini sprites (`mini-<slug>.png`) unchanged. Fight smoke + fight_scene pass.
- Known test state: pbox_v1, puzzle_pals, gourmand (nav tile 2 vs 1), tea and guest fail on the pre-2.8.72 code too.

## 2.8.71
- **Dock: no count badge over the Games tile; the Garden badge shows how many crops are ready (workflow W5).** The Games tile ("N to play" / contest mark) no longer carries a badge in the dock, and the Hobbies menu button no longer adds the games count. The Garden tile badge is the ready-crop count, computed fresh in `dock_menus()` (`dock_garden_ready()`, same rule as `nav_groups()`), returned by `dockstate.php` as `garden` and updated by `refreshPlate()` in `assets/dock.js`, so a harvest lowers it without a reload; empty at 0. The classic chrome and menu sheet are unchanged. The Quick button's number ("Wild Berr... 4") is your satchel count of that item and stays. Suite `dock_badges` (in CI). Checked in headless Chromium at 844x390 and 1280x800 (not a real phone; the portrait phone draws no dock).

## 2.8.70
- **Landscape phone Trail: the family box (Echo chain on mountain stretches) was very large** (owner: "Very large text box?"). With the dock on and at most 520 px high, the family pictures (`.tfm-svg`, `.tfc-svg`, `.tfg-svg`, `.tfi-svg`) are 52 px high instead of about 98 px, and the Echo chain notes and chips are 12 px with tighter spacing. CSS only, tail of `assets/dock.css`. Not seen in a browser; if the other Trail boxes (forest, desert, wetland...) are also too big, tell me which.

## 2.8.69
- Bugs and small fixes (a workflow of agents, each area checked by its own tests; none seen on a real phone):
- Landscape phone Here page: the picture now fits above the dock at the top of the page (slimmer title, 54 px reserve; 844x390 bottom 293 -> 280 px, dock top 284). At 640x260 the picture still needs a scroll. `assets/dock.css`.
- Almanac and Trek at 640x260 (landscape, up to 300 px high): tighter heading, search and intro spacing; one full Almanac row and the Trek Begin button now clear the dock. `assets/dock.css`.
- Puzzle fight: stat pieces keep their stat badge in the turn replay (`pfb_snap`, `includes/pfboard.php`), and a fight begun before 2.8.61 gets stat piece icons (`pfight_backfill_ik()`, `includes/pfight_game.php`). Tests in `tests/pf_stat_art.php` (230 ok).
- Cat Fish: the zoomies start from the cat's own row, and a reload no longer leaves a zoomies cat hidden (`assets/catfish_room.js`; not reproduced in a browser).
- Tools: `build_parts47.py` / `build_parts48.py` no longer delete `marks/tag-*` or rewrite `marks.json`.
- Tests: `here_bang` was date-flaky (orders expire late in a cycle; test now sets `orders_min_days` 28), `itemsq` was stale (undiscovered recipes read "found / not found yet" since 2.7.06). `pf_play_decks`, `pfdeck_v1`, `pfboard_tune_v1_metrics`, `pf_yield_text`, `pfboard_v1_abil` and `pf_creatures_import.sh` pass now (6 runs each); nothing changed for them.

## 2.8.68
- **Pop-up messages go to the bell with the dock (landscape phone and desktop).** Owner: "Move all notifs to the new stories are bottom right. Have it glow and show the most recent for a few seconds before disappearing." `gvShowToasts()` (`assets/site.js`) hands the messages to `gvDockNote()` (`assets/dock.js`): the bell glows (gold pulse, 6 s), the newest message shows in a small bubble beside it for 5 s then fades, tapping the bubble or the bell opens Messages, where the recent ones are listed on top as "just now" (dropped from that list once the page's own message list has them), and the bell badge counts the unseen ones. Errors and prize boxes still pop up as before (they must not vanish). Portrait keeps the old pop-ups (the bell is landscape only). CSS in `assets/dock.css` after the bell rules; reduced motion: no pulse, no fade. NOT seen in a browser: check on the phone and desktop.

## 2.8.67
- **Fix: the game-clock cost pop-up still showed with the dock ("-1 energy · +10 min (now 10:45)").** 2.8.66's filter matched the text without the emoji the server adds ("⚡ −1 energy · 🕐 +10 min (now 10:45)") and without the "N h of it waits for tomorrow" bit. `gvShowToasts()` (`assets/site.js`) now drops a pop-up whose every part is an energy cost, a time cost, the "now hh:mm" or the "waits for tomorrow" note, emoji or not; any other text keeps its pop-up. Not seen in a browser (regex tried on five texts in node).

## 2.8.66
- **Fix: portrait phone world map (with the dock on) was 48 px wide.** The side-by-side layout (map + 300 px column, `body.dock-on main:has(> #worldmap)` and the `.youpill` / `.letter-reminder` cells) sat outside a media query in `assets/dock.css`; it is now landscape only. Portrait keeps the normal stacked page. Not seen in a browser.
- **Fix (owner: old notifications on horizontal and desktop): the pop-up "-1 energy · +10 min (now 10:45)" no longer shows with the dock.** `gvShowToasts()` (`assets/site.js`) already dropped a bare "-1 energy"; with the game clock on the message carries the time too, so it slipped through. The dock shows both. Other pop-ups unchanged.

## 2.8.65
- **Fix (owner: pink pixels inside the holes of puzzle pieces, on most pieces, most visible on desktop): the hole cut-outs no longer have a coloured rim.** Cause: the hole socks (`socks-hand.png`, `socks-strip.png`) drew a 1 px rim in the edge family's colour (body salmon, mind lavender, craft yellow) round the cut-out; at desktop sizes it read as stray pink pixels. Now that rim is the dark outline. Fixed at the source: ring 2 in `aseprite-source/pfight/v47/scripts/socks.lua` is `L.INK`, the six hole `.aseprite` / `.png` files in v47 `strip/` and `hand/` redrawn, and the kits rebuilt with `tools/build_parts48.py` and `tools/build_parts47.py` (their `marks/` folders restored from git: the builders drop the tag marks). Knobs unchanged. Art only, no code.

## 2.8.64
- **Rest stop activities are once a game day again (owner: "Rest stop activities should be limited to once per game day.").** Each activity can be done once a game day at each stop: the same activity again at the same stop that day is refused with "You’ve done that here today. Come back tomorrow!"; a different activity is fine, the same activity at another stop is fine, and the gnome's next game day (a sleep with the game clock on; the next real Hollow day with it off) makes them all available again. Rests, stall buys and snacks are activities too.
- How: `stop_done_today()` in `includes/stops.php` reads `stop_log` by user, stop and day (`stop_log.day` is already the gnome's game date, `gclock_my_date()`, index `user_id, day`); `stop_do()` checks it before the act and again under the gnome's row lock (a double click). No schema change: `stop_log` keeps its UNIQUE key and the `<visit>#n` suffix from 2.8.60 (the same act on a later game day within one visit). Town actions are unchanged (unlimited). 2.8.60's other removals stay: no per-visit slots, no daily cap per stop, no rest cap and no "tired" halving.
- Stop page (`includes/local.php`): an activity done today is a greyed card with a tick and "Done today" (stall tiles "Done"), the Do tab has a badge with the number still to do today, the heading says "N left today · each once a day" (or "all done today: come back tomorrow"), and the Today card says how many things are left today. Here picture (`includes/here_view.php`, `includes/hub_scene.php` classes): a Do spot done today is dimmed with the chip "Done" and its popover says "Done today. Come back tomorrow!"; the dock's Do here strip leaves done ones out, and one done in place shows as done (`assets/hubscene.js`, `assets/dock.js`). The Rest stop popover's Extras tab and the Perks card mark done ones too.
- Text: glossary "Rest stop", How to play line, the stop page and player news post (key 2.8.64).
- Tests: `tests/stops100.php` asserts the second go the same day is refused (also after walking out and in), a different act works, another stop works, the next day works again, with the game clock off (real day) and on (game day 40 -> 41, later the same game day still refused); rests are once a day each; `tests/stops100.sh` checks the greyed card, the badge count and the refusal on the page.

## 2.8.63
- **Fix (owner: "Played pieces sometimes revert to default icons and then back to their own icon. Seems to be stat pieces. When played or selecting in hand."): a stat piece you place keeps its own icon and stat badge on the board until the turn is sent; a piece drawn next turn has its icon from its first frame.**
- Cause (reproduced in headless Chromium on a scratch SQLite world, all 24 stat pieces packed, phone 390x844, landscape 844x390, desktop 1280x800, sampling every piece canvas each animation frame): `working()` in `assets/pfboardv1.js` builds the planned piece (the one you just placed, before End turn) as a new object from the hand piece and copied `t`, `e`, `tag`, `m` but not `ik` or `st`; `render()` then drew it with `P.piece()` without an icon key, so `build48()` drew the type glyph (or the tag icon) and no stat badge. It stayed so from about 3 frames after the tap until End turn (49 to 76 frames in the test, longer for a player who waits), the frozen copy shown while the turn is sent kept it, and the board from the server's answer had the icon again. The same copy for a set-aside group dropped `ik` too, and the page data for the held group carried no `ik`/`st` at all. A second, shorter one: icons were loaded only for pieces already in the hand or on the board, so a stat piece drawn into the hand next turn was drawn for 1-2 frames with its type glyph until its icon arrived (hidden behind the frozen copy in the test, but a slow first download can outlast it).
- Change (art and page data only, no rule changes; `tools/pfengine.js` and the PHP engine untouched): `working()` copies `ik` and `st` for the planned piece and for each piece of a planned group (`assets/pfboardv1.js`; the old board `assets/pfboard.js` copies `ik` and passes it in its hand, group and inspect pictures); the fight page data (`includes/pfight_game.php`) gives a held group's stat pieces their `ik` and `st`, and `dik`, the sorted icon keys of my draw pile, discard and hand (sorted, so the draw order is not given away); the board loads those icons at both sizes when the fight opens.
- Seen: before (2.8.62), 12 of 12 select / place / End turn plays (4 per window) showed the placed stat piece with its type glyph (Weather Lore a potion bottle) from 3 to 6 frames after the tap until End turn, 49 to 76 frames each, and the new hand's freshly drawn stat pieces had 1-2 frames without their icon behind the frozen copy. After, 12 of 12 plays (plus 18 more in an earlier run): no frame with a stat piece of mine drawn without its icon or stat badge. Selecting in the hand never showed one, before or after. Phone and desktop screenshots otherwise unchanged.
- Test: `tests/pf_piece_ik_unit.js` (in `tests/pf_stat_pieces.sh`) runs `working()` of both board scripts with stubs and checks the planned piece and group keep `ik` (and `st`), that every `P.piece` call passes `ik` and that the held group and draw pile icons are loaded (10 of 19 fail on 2.8.62); `tests/pf_stat_art.php` checks the page data for the held group and the draw pile icons.

## 2.8.62
- **Landscape phone Here page (owner: "Mobile here page should have a slightly larger image and smaller villager section"): the town picture is about a fifth larger and the villagers are a compact list beside it.** CSS only, `assets/dock.css` (new block after the dock Here rules), scoped to `@media (orientation: landscape) and (max-height: 500px) and (pointer: coarse)` with the dock on, so desktop windows and portrait phones are unchanged.
- Picture: `.hubscene:has(> .hubstreet) > .hubstage` height is now the room above the dock less 48 px (was less 92 px), at least 175 px on a short phone (`--hereimg`). Sizes (w x h, CSS px): 844x390 340x193 -> 417x237; 800x360 287x163 -> 364x207; 736x340 265x151 -> 329x187; 640x260 265x151 -> 304x173; 932x430 410x233 -> 488x276. Scrolled to the picture it sits fully above the dock at every size (640x260: 4 px left).
- Villagers (`.hubscene > .hubstreet`, `.hubstreet .hubst`): two fixed columns of at most 164 px that take only the width they need (one column when only you are there), 44 px rows, 28 x 35 px portraits, 4 px padding, names 14 px (were 12 px), square corners and a 1 px umber outline. Panel with 2 cards at 844x390: 446x60 -> 344x56 (4 cards: 446x108 -> 344x104); at 640x260: 333x60 -> 294x56.
- Unchanged (headless Chromium, before / after pixel-identical): 390x844 portrait and 1280x800 desktop Here; the Heading to / Set off / Route strip has the same size and place at every size.

## 2.8.61
- **Fix (owner: "im not seeing some pieces drawn, the newer stat pieces, when they are in my picked pieces"): the 24 stat pieces (Nimble, Lore, Luck, Sense) now draw their own icon in a fight, in the hand and on the board (and in the replay), as they already did in the Puzzle box kit, shelf and pre-fight deck.**
- What was wrong (reproduced in headless Chromium on a scratch SQLite world, all 24 packed, phone 390x844, landscape 844x390, desktop 1280x800): in the Puzzle box and on the pre-fight screen every stat piece drew right; in the fight they showed the plain type glyph or their tag's icon (Sharp Eye a brace, Sidestep a jab, Lantern Chain a sparkle) and no stat corner badge. Four causes:
  - `pf_make_tile()` keeps no `ik`, so a stat piece's fight tile had no icon key: board, gone and replay pieces said `ik: ''`. `pfd_tiles()` (`includes/pfdeck.php`) now puts the entry's `ik` on the tile (art only, no rule changes; the JS twin reads the same tile).
  - The fight page data (`includes/pfight_game.php`) rebuilt each hand piece from a few fields and dropped the `st` and `ik` that `pfb_view()` gives a stat piece; they are passed on now.
  - `assets/pfparts47.js` crisp cache: the hand-size bitmap was keyed by whether the STRIP icon had arrived, so one built while only the strip icon was in had no icon but was kept under the icon's key. `P.keyOf(o, size)` now keys by the icon at the size being built (creature piece icons were hit by this too).
  - `assets/pfboardv1.js`: a hand piece is drawn once; when its icon arrived later only the board was redrawn. The icon loader's callback now redraws the hand pieces that have an icon.
- Seen after the fix (same three windows, six turns each over three fights): all 24 stat pieces drawn with their icon and stat badge in the hand or on the board; kit, shelf and pre-fight deck unchanged.
- Test: `tests/pf_stat_art.php` (in `tests/pf_stat_pieces.sh`) checks that every stat piece's fight tile carries its icon key and stat, that both icon files exist, that `pfb_view()` gives `ik` and `st` for all 24 in the hand and on the board, and the page data, crisp key and hand redraw (99 of these fail on 2.8.60).

## 2.8.60
- **No more daily limits on town and rest stop actions (owner decision, hard removed in code, no setting).** Energy, Petals, item costs, chances and rewards are unchanged.
- Towns (`includes/town.php`): `town_act()` no longer refuses with "You've done that once / N times today already. Come back tomorrow!"; `town_claim_use()` is replaced by `town_note_use()`, which only counts the use in `town_uses` (still read by First Week and admin tidy-up). `town_actions.daily` (and the "uses a day" column of `data/towns.txt`) is kept as data but read by nothing; the field is gone from Admin > Town things to do.
- Festival stall treat (`festival_treat()`): no longer once a day; as often as you like on a festival day (it is a free treat: XP 10, 20-40 Petals, a food and a seed, so see the balance list in `claude/todo.md`).
- Town UI: no "N left today" / "done for today" under buttons and no greyed buttons for used-up actions (`action_buttons()`, `includes/place_ui.php`); place cards no longer go to the "all done today" state, their chip counts the place's things to do (`town_place_card()`); the square's summary says "N things to do" (open places), not "left to do today" (`town.php`); the Today card says "N things to do" (`includes/today_view.php`); the festival stall says "a free treat" (`includes/spot_card.php`, `town.php`).
- Rest stops (`stop_do()`, `includes/stops.php`): removed the once-per-visit rule ("You've done that already on this visit"), the per-visit slots (`stop_slots()` deleted; "You've done all you can on this visit"), the per-stop daily cap `stop_daily_cap` ("The villagers have seen plenty of you today"), the rest cap `stop_rest_daily` ("You've rested plenty today") and the "tired" rule (`$GLOBALS['gv_stop_tired']`, past `stop_daily_total` acts a day Petals and XP were halved in `stop_rewards()`). Every act still writes its `stop_log` row; `stop_log` keeps its UNIQUE (user, stop, visit_key, act), so a repeat in the same visit is logged with visit key `<visit>#2`, `#3`, ... (no schema change).
- Rest stop UI (`includes/local.php`, `includes/here_view.php`): no slot pips, no "x of y things left this visit", no "That's enough here for today" banner, no "tired" note, no Do tab count badge, no "Done this visit" cards or popovers; the heading says "as often as you like". The Today card for a stop says "things to do, as often as you like".
- Settings: `stop_slots`, `stop_daily_cap`, `stop_daily_total` and `stop_rest_daily` are removed from `settings_schema()` (Admin > Settings); rows an old install stored are ignored (`upgrade140.php` still touches them harmlessly).
- Text: the tier-4 stop hall no longer says "(+6 energy, once a day) and one more thing to do on every visit" (`data/stop_tiers.txt`, `data/stop_tier_themes.txt`, boot step `stop_tier_text_2860` for existing worlds); glossary entries for Festival and Rest stop, How to play line about rest stops.
- Kept on purpose (not town actions or stop acts, or not limits on doing things): the stop adopter's once-a-day welcome (`stop_adopter_perk()`), the once-a-day chat / gift per stop villager (friendship), one story-thread beat a day (`stop_thread_do()`), the once-a-day wave / bench / snack with another gnome (`includes/town_social.php`), and the other daily caps outside towns and stops (florist shifts, seed packets, landmarks, games, letters). Listed for the owner in `claude/todo.md`.
- Tests: `tests/stops100.php` now asserts no slot, daily, rest or tired limit (with the retired settings stored at tight values) and the same act 12 times on one visit; `tests/town.sh` sits on the bench 12 times in a row; `tests/game_time.php` checks `town_note_use()` per game day; `tests/stops100.sh` checks the retired settings are gone from Admin.
- Player news post (key 2.8.60).

## 2.8.59
- **Town Library quiz shows in its popover.** What was wrong: on the Here / town picture, tapping "Answer the librarian’s question" in the Library popover used the day's go and came back with the button greyed ("done for today") and no question: the question was stored in the session (`$_SESSION['town_quiz']`) but only `town.php`'s full page drew it; the popover card (`spot_card_html()` in `includes/spot_card.php`) never did. What changed: the quiz card markup moved into `town_quiz_box_html()` (`includes/town.php`), used by `town.php` (the page looks the same, pixel-identical in a before/after screenshot) and by the Library's popover card (question at the top, the forms post in place). After an answer the popover shows the result in the card (`.vmsg`, e.g. “Quite right!” · A: … · +25 Petals · +4 XP, or the clue on a wrong answer; `town.php` takes the prize off the toast queue and logs it in Messages directly so it is not shown twice). `assets/hubscene.js` scrolls the question / result into view after the swap. CSS: `.hubpop .quizbox` (slim card, 28 px icon, 1 rem question, full-width 44 px answer buttons, `assets/style.css`) and, landscape with the dock, a wide popover that stops above the dock with the three answers side by side and no icon (`assets/dock.css`). Seen in headless Chromium, light and dark: 390x844 question at the top, three 265x44 buttons; 844x390 and 1280x800 692 px card, three 217x44 buttons in a row; 640x260 588x115 card fully above the dock (before: nothing shown; with only the markup added it was clipped by the head and the dock).
- Puzzle combat "purple/pink leftover pixels on pieces on desktop": NOT reproduced in headless Chromium (1280x800 and 1920x1080, scale 1 and 2, Full / Light / Off, a placed piece and a full replay); see `claude/todo.md` (2.8.59). No change made.

## 2.8.58
- **Cat Fish: the napping cat sits on the cushion, not under it.** The cushion is drawn at depth 240 and the lazy cat naps at y 226, so the cushion was painted over it and only the ears showed. A cat napping on the cushion now draws at depth 241 (`assets/catfish_room.js`, `render` order via `c.zo`). Checked in headless Chromium (844x390): before, only ears above the cushion; after, the whole curled cat on top. The cat's shadow still falls on the cushion front as a faint grey strip.

## 2.8.57
- **Desktop shop popover: wide, with compact item squares.** What was wrong: a shop opened in its popover (Here / town picture shop fronts, `here_shop_card()` in `includes/here_view.php`) was a 420 px column (`.hubpop .pickbox { max-width: 420px }`) and the desktop page rule for shop tiles (`body.dock-on .shopwrap .itms`, 130 px+ columns in `assets/dock.css`) gave two 191 px squares per row, so you scrolled a lot (4 of 17 seeds fully in view at 1280x800, 6 at 1920x1080). Now, on windows at least 900 px wide and 521 px high (`@media (min-width: 900px) and (min-height: 521px)` in `assets/style.css`, after the `.hubpop .shpage` rules), a popover holding a shop page is `min(900px, 92vw)` wide and its squares are an auto-fill grid of 104 to 112 px (7 per row at 900 px) with a 52 px picture and a 14 px name and price; the want / basket badge sits beside the picture instead of over the name, the "Wanted" word is screen-reader only (the star shows it) and the ribbon ends are thinner so names like Meadowsweet fit on one line (Chrysanthemum and Bridgewarden's still break mid-word). The shop-list card (rows of shops) keeps its narrow width. What I saw (headless Chromium, scale 1, light and dark, Buy and Sell, Maple & Furrow at the Maplewold Market): 1280x800 and 1920x1080 show all 17 seeds and all 7 sell items with no scrolling; 390x844 portrait and 844x390 landscape (dock) are pixel-identical to 2.8.56. CSS only.
- **Desktop world map fills its column.** What was wrong: with the dock on (everyone), `assets/dock.css` caps the world map at 300 px high (`body.dock-on main > #worldmap .mapwrap / .mapzoom / svg { max-height: 300px }`) and the region map (Map tab) and Fast travel map at 250 px (`body.dock-on .regionmapbox .rzoom .regionmap`, `body.dock-on .gomap .rzoom .regionmap`, plus `.rzoom { max-width: 760px }` in `style.css`), so on a desktop window the 16:9 world map drew about 535 x 300 in a 914 px (1280 wide) or 1194 px (1920 wide) column and the region map 443 x 250 in a 1042 to 1322 px box. Now, in `@media (min-width: 900px) and (min-height: 521px)` (`assets/dock.css`, after those rules), they fill the column up to 1100 px wide, keep their shape, and stop at the window height above the dock. What I saw (headless Chromium, scale 1, light and dark): world map 914 x 512 at 1280x800 and 1100 x 616 at 1920x1080; region map 1042 x 586 / 1100 x 619; Fast travel map 990 x 557 / 1100 x 619. A region tap still opens its map, the region zoom buttons still work (viewBox changes), pins are bigger tap targets. 390x844 and 844x390 screenshots are unchanged (pixel-identical apart from the ticking status strip).
- Not fixed, found while checking: on a portrait phone with the dock on, the world map on world.php is 48 px wide (the same unscoped `body.dock-on main:has(> #worldmap)` two-column grid with a 300 px side column squeezes it); see `claude/todo.md`.
- Cat Fish: the "cut-off cat on a sideways (back-row) run" report was investigated and not reproduced in headless Chromium; see `claude/todo.md` (2.8.57) for the open notes.

## 2.8.56
- **Trail dock: Sneak and Hunt show when they are on.** In the Trail strip the active stance tile (the page button with `aria-pressed="true"`) is lit and ringed like the current page. `resolveOne()` / `finalItem()` in `assets/dock.js` (any dock piece that works a page button with `aria-pressed` now gets this). Not seen in a browser; `node --check` only.

## 2.8.55
- **New dock art, live for everyone (no setting).** The landscape dock is the approved stone arch (`claude/mockups/dock-lantern-all.html`): carved stone tablets tilted along the curve with enamel inlays in the area colours (cream helper action, gold main verb), coping stones with moss and grass, a mortar bed, a keystone with a sun / setting sun / moon window, a slate status plate, and ONE iron lantern on a crook over the menu the current page belongs to. Pressed (open menu, held piece), greyed (a bare recess, worn label), badges and why-tags redrawn; the open strip's current tile has a gold rim. Drawn by `tabletSVG` / `bandSVG` / `overSVG` in `assets/dock.js`; colours are CSS custom properties in `assets/dock.css` (no inline styles, no blur, no gradients). Behaviour unchanged: strips, Select / Pick / Then, remote pieces, Quick slot, play rail, 75% scale, `.dockfb` fallback, tour ring, `?dock=off`. The status popover keeps its old look.
- **Time of day.** The dock JSON and `dockstate.php` carry `tod` (`dock_tod()` in `includes/dock.php`), set as `data-tod` on `.dockroot`: the player's game clock 06:00 to 16:59 = day, 17:00 to 19:59 = golden hour (lantern lit), 20:00 on (tired and past midnight) and before 06:00 = night (brightest, glow ring, fireflies). With the game clock off the Hollow's real hour (game_timezone) uses the same bands. New suite `dock_tod`.
- Player news post (key 2.8.55). Seen in headless Chromium only (844x390 and 640x260), not on a real phone. Seven page actions still use emoji (Arrange, Items, Contests, Play, Satchel on Trading, Re-roll, Take): no dock art for them yet.

## 2.8.54
- **Fix: Trail maps with exits on the top or bottom row could not be left on a short landscape phone.** The short-screen layout (under 439 px high) showed the Trail map as 9 columns x 5 rows. The Trail keeps a 7 x 7 window inside the map, so the first and last map rows were never on screen and an exit there could not be seen or tapped. It now shows 9 x 7 like the taller layout, so every row is visible again (the map is a little larger and the text column a little narrower; at 640x260 the map is 239 px wide, 185 px high).

## 2.8.53
- **Landscape dock folds.** Puzzle box: the spare-piece shelf folds (stays open when you filter, search, pack or take out; reopens when you leave short landscape); Tailor pages its card lists 3 at a time (`assets/tailorpage.js`); Trek: Sneak / Camp / Leave sit in the left column beside the map; Jobs post: slimmer empty board and forms; Almanac search pages 6 hits at a time (no script).
- **Garden Yard picture.** Level 3 art no longer overlaps neighbours (level 3 shrunk, tap rectangles fitted); frog pond, worm farm and silkworm spool redrawn (`tools/redraw_gyard_weak.py`, `tools/build_gyard_assets.py`). Player news post for the Yard.
- **Settings.** The `nav_dock` label no longer says admin preview.
- **Hollow jar sizing.** The weekly jar is sized by the larger of last week's helpers and the average of the last two weeks, so one niche week (Pomeroy courses, creatures) no longer shrinks the next jar. New suite `hollow_sizing`.
- **Map.** The walking hat follows the road curve; the card compass uses `rl_heading8()` and agrees with the region map; stops clamped to a region edge spread along the road. New suite `map_fixes`.
- Built by Sonnet agents in separate worktrees, each reviewed by Opus and fixed once. Not seen on a real phone: the folds, Trek layout and Yard art were checked in headless Chromium only.

## 2.8.52
- **Hotfix: `craft_path()` alias.** A live site's Today card (`welcome_back.php:92`) called `craft_path()`, which is not defined in this code, and the home page showed "Oops, something went wrong". `craft_path($c)` now returns `craft_url($c)`. Open: that call is not in any file in the repo; the live `welcome_back.php` differs from the repo's.

## 2.8.51
- **Fixes from the Fable review of 2.8.48 to 2.8.50** (this release carries 2.8.49 and 2.8.50 too).
- **Hollow jar bonus** is now its own one-off claim (tier 5, half of the 100% tier's Petals), paid when a gnome's share reaches half a fair share, even after tier 4 was claimed or the jar was already full (weekly jars, until two days after they end). The Hollow page shows the number needed for the jar on screen and no bonus text on festival jars. Last week's helper count skips guests, banned and deleted gnomes. Festival jars also get the new tier pay and the helper sizing (only the bonus skips them). The smaller pools and helper sizing apply from next week's jar; jars already made keep their size but pay the new tiers.
- **Boot step `hollow_jar_2850`** only runs when upgrading from before 2.8.50. New installs now default `tea_open` to Everyone and `gnav_garden` to on (still needs `gnav_on`).
- **Dock under 340 px high:** the CSS starts at the 80 px height (no 26 px jump on first paint), and once small it stays small until the window passes 380 px.
- **Player news post** for tea, the jar and the small dock.

## 2.8.50
- **Hollow jar, nicer and fairer.** Petals per tier 150 / 300 / 450 / 700 (was 100 / 200 / 300 / 500; changed on upgrade only where the old default was still set), XP 20 / 40 / 60 / 100 (was 5 / 10 / 15 / 25). Pumpkin, watering and Pomeroy-course jars are smaller (6, 50 and 2 per gnome, were 12, 80 and 3). The jar is sized by how many gnomes helped fill LAST week's jar (falls back to gnomes seen when there was none). A gnome who puts in at least half a fair share gets 50% more Petals on the 100% tier of a weekly jar (festival jars unchanged).

## 2.8.49
- **Tea kettle open for everyone** (`tea_open` set to Everyone once on upgrade; an admin can change it back).
- **Garden Yard picture flag on** (`gnav_garden` set to 1 once on upgrade; it still needs `gnav_on`, the Here page setting, to show for players).

## 2.8.48
- **Dock: smaller on very short views (landscape).** Under 340 px of window height the dock draws at 75% (about 80 px instead of 106), so a 640x260 phone keeps about 26 px more page. Taller windows are unchanged.
- **Garden (landscape dock): the N/P/K row and the upkeep chips show again** in the square info panel (they were hidden in 2.8.20).

## 2.8.47
- **Treehouse (and yard) picture: centred and bigger on a landscape phone.** A picture page with no list beside it now centres its picture and makes it large: its height is the space above the dock plus 30 px, so the page scrolls the last bit (about 65% wider than before on a 412 px-tall phone). Pages with a villager list beside the picture are unchanged.

## 2.8.46
- **Fix: Satchel Quick button could not pick an item (landscape).** The shelves now open a full-screen picker, which sits above the dock, so the dock's Confirm piece could not be tapped and never saw the open item. While you are choosing a Quick item, the open item's panel now has a "Set as Quick" button (only for items the Quick slot can hold). The dock's Confirm piece also finds the item in the new panel.

## 2.8.45
- **Cat Fish: the new room (setting `catfish_room2`, on by default).** A 480x270 room with depth: cats run into the distance (smaller) and back, zoom off one side of the screen and in from the other, and the other cats wander, nap, tag each other and climb the cat tree. Tap the floor to throw the lure; the cat chases it and the catch pays Kibble (x1.25 when the throw was far). Tap a dangling fish: x1.5. Idle cats now yawn, stretch, wash, flick their tails, twitch their ears and swat at nothing. Room things show on the stage, and active ones can be tapped there.
- **Cat Fish page layout.** The room loads first. The shop is a drawer with Shop, Shelter and More tabs: it slides in from the right on phones and tablets, and is a permanent 360 px rail from 1000 px wide. Short landscape phones show the whole room. A one-time "turn your phone sideways" chip shows in portrait.
- **Server.** `catfish_play` takes `rod` and `far` counts with a batch (clamped to the number of taps, best multipliers first). New setting `catfish_room2` (Off, Admins only, On for everyone). New art in `assets/img/catfish/room2/`, packed by `tools/catfish_room2_pack.py`. Notes: `claude/catfish-room2.md`.
- **Admin > Tools: reset a player's Puzzle Pals and/or jigsaw progress** (blank name = yourself; needs the confirm box).

## 2.8.44
- **Shop Buy / Sell: bigger tiles on desktop.** The compact phone-landscape tiles (66 px) applied to every dock screen; they now apply only to short landscape screens (height 520 px or less). Desktop gets tiles at least 130 px wide.
- **Shop filters are back:** under the category chips, Sort (name, price, rarity), Rarity, and Can afford (Buy) or Wanted (Sell). Client side only.
- Not checked: the real shop with live data (tested on a mock page in headless Chromium).

## 2.8.43
Two parts: the desktop puzzle combat rework, and the dock clock.

### Desktop puzzle combat
- **Puzzle combat on a desktop window: the whole screen, steady placement, a calmer jigsaw.** On a window at least 1000 x 600 (phones, phone landscape and the dock's short landscape layout are unchanged) the fight on the adventure page (Trail, wander off with or without a map, delve, lair; pfight_stage on or off) is one wide panel, the window less a small gutter (up to 1640 px), instead of a 560 px column (or the 680 px map column with pfight_stage on). The board is on the left with the hand under it and grows with the room (up to 4.5x the art's size; it was 329 x 283 px at every desktop size), the bars, tips, last plays and buttons are a column on the right, and the end card covers that column with the last board in sight. The pre-fight card is two columns (the creature, your deck) up to 1240 px wide. With pfight_stage on, the pre-fight card, the combat and the result card share one box centred on the window (they used to sit on the map's box, then jump to a different box, left-aligned on a wander with no map, at Let's fight and again for the result). The jigsaw scales with that box: about 70 pieces instead of one per 72 px (700 on a 2560 window), one 340 ms wave instead of 42 ms per diagonal step (2.5 s on a big window), a travel distance and a flight time that follow the box's size. The page around is dimmed (.45, as without the stage) and does not scroll. The geometry no longer waits for the script (the pre-fight card painted as a narrow column first and then jumped). On a 1800 x 1100 window and up the right column and the pre-fight card are drawn 1.2x larger. Files: assets/pfv1.css, assets/pfstage.css, assets/pfstage.js, assets/pfboardv1.js (board sizing only; no engine change). Tests tests/pfstage.js and tests/pfv1_layout.js now expect the desktop panel.
- **Not checked:** a real desktop browser or a real phone (headless Chromium only), Safari and Firefox (the layout uses :has(), :is(), complex :not() and CSS zoom), a tablet in landscape (it gets the desktop layout), boards larger than 3 x 3, the first-fight intro card, MySQL. Unchanged: with pfight_stage off, the card of a fight you ran from still shows in the page above the map (not over it). tests/pfv1_layout (not in CI) still fails its desktop header checks, as on 2.8.42 (this world has no header with the dock on).

### Dock clock
- **The dock clock updates after every action, with a ticking clock.** Forms sent in the background (the Gather box, village scenes, the Trek, fights) did not reload the page, so the plate kept the old time, energy and coins. The dock now asks `dockstate.php` (one small JSON call) after any such POST and redraws. When the time moves, a small clock face ticks in over the time ("+10 min", the hand turning in steps) and fades away, like the energy effect; reduced motion: a plain fade. The plate also reads the user row fresh, so it shows the numbers after the action, not before.
- Not checked: a real phone, the effect on every background form (tested: the Gather box).

## 2.8.42
- **No full screen on desktop.** The first tap in a fight no longer takes a desktop browser into full screen, and the full screen button on the play rail is hidden there. Phones and tablets (touch screens) keep both.

## 2.8.41
- **Fix: the Trail map jumped when you picked a spot (landscape).** The walking camera centred the token as if the window showed as many rows as columns, but the landscape layout crops the top and bottom rows, so the walking layer sat one tile too low and snapped back when the walk ended. The camera now uses the rows actually shown (7 on tall screens, 5 on short phones).

## 2.8.40
- **Fix: Trail page in landscape broke the fight dialog test (pfstage).** The map's wrapper is a normal box again (the fight dialog and the Trail scripts measure it), so the caption and legend stay small under the map instead of in the right column. The button row is hidden only on a phone's height (up to 520 px); a wide landscape screen keeps it.

## 2.8.39
- **Trail Gather popover, after a gather (landscape).** The "Into your satchel" banner is one slim row, so the tool belt stays in view, and the toasts (new Almanac page, energy used) are small and sit at the bottom left over the picture instead of over the belt.

## 2.8.38
- **Gather popover on the Trail: finds under a fold, fits above the dock.** "What's here" is a fold with the count of known finds ("0 of 16 known"); open it for a compact grid of finds. In landscape the popover starts at the top and ends above the dock, the belt is smaller and the picture's chips are hidden. Other gather screens are unchanged.

## 2.8.37
- **Gather popover on the Trail, landscape: no big tool cards, full width.** The five large tool cards are hidden (the tool belt buttons gather with the same form). The popover takes the screen's width: the picture on the left, the belt and the finds list on the right.

## 2.8.36
- **Trail page in landscape: the right column holds the text.** Beside the map: the section strip, the weather and ledger, what just happened (the hint or event text), the Route fold, the legend and the place caption. They used to sit under the map, behind the dock. The map wrapper no longer needs a container query here, so tall phones get the 9 x 7 view from plain CSS.

## 2.8.35
- **Trail page in landscape: the button row is gone.** Gather, Sights, Wander off, Sneak, Hunt and Turn back are in the dock's Trail menu, so the copies beside the map are hidden (the menu still presses them). The column beside the map is for the strip, weather, ledger and sight text.

## 2.8.34
- **Trail page, short landscape phone: map left, text right, half and half.** The map shows 9 x 5 tiles (about 310 x 175 px, tiles about 35 px). The text column (strip, ledger, buttons) is the right half. Route, the caption and the legend sit under both (scroll to them) instead of behind the dock.

## 2.8.33
- **Trail page on a short landscape phone: wider map, shorter text column.** The map shows 7 x 5 tiles (it was 7 x 7), so it is wider with bigger tiles. The strip is one line, the buttons one row, and the boxes are tighter.

## 2.8.32
- **Trail page in landscape: bigger map, smaller print.** The map takes the whole height down to the dock and sits closer to the left edge. The info column beside it (strip, weather, ledger, buttons, Route) uses smaller text and tighter boxes. The rules also win over the Wander-off layout.

## 2.8.31
- **Trail page in landscape: map on the left, the rest on the right.** The section strip, weather, ledger and the Gather / Sights / Wander / Turn back buttons now sit in a column beside the map instead of under it, so the map gets the whole height above the dock (9 x 7 tiles when the phone is tall enough, 7 x 7 when short).

## 2.8.30
- **Trail and delve map larger in landscape.** On a phone held sideways the map drops its top and bottom tile rows (7 rows by 9 columns), so it is wider and bigger above the dock.

## 2.8.29
- **Trail and delve map smaller in landscape.** On a phone held sideways the square map is capped to the height left above the dock, so the bottom no longer hides behind it.

## 2.8.28
Creature parts (augments, mending, compost, Tailor, Codex, Fair, trophy wall, villagers), item review group C, and the balance, news and docs pass.

### Creature parts
- **Creature parts, phase 0.** New `includes/parts.php`: six part families by slug ending (Hide, Plate, Wing, Ooze, Silk, Gem; lists extended: whisker, fleece, bristle, ear, tail to Hide; talon, tine, chitin, leg to Plate), `part_family`, `part_family_items`, `part_is_rare` (rarity 45+). Recipes can ask `any-<family>` (cheapest part first, a rare one last) or `rare-<family>`, in tools, garden, potions, building and decor only; new `craft_take()`. Only `part` items count (forage shells and wings do not). New row `shell-meal-plate` (2 Plate parts make 1 Shell Meal). No change to existing recipes. Test: `tests/parts.php`.
- **Creature parts, phase 1: tool augments and kit mending** (`includes/augments.php`). New columns `user_items.aug` / `aug_left` (schema.php, no boot step). One augment slot per tool item (copies in a stack share it), fitted from the Satchel tool panel (`tool_fit_aug`); a Fine or Masterwork tool also takes one rare part of the augment's family. Seven potions-table items and recipes (insert-only): Hide Binding (+25% wear limit), Hide Binding II (+50%), Plate Edge (25% of finds one rarity higher, may pass the tool's gate by one step, 40 uses, a use only on a swap), Wing Fletch (35% +1 item, 25 uses), Gem Charm (Luck +4 in the pick, 30 uses), Ooze Salve (next 3 Petal mends free), Silk Lashing (a kit mend takes 1 fewer kit, min 1, 40 mends). Item prices about 60% of ingredient value; they show an emoji until art is drawn.
  - **Survival:** a broken tool's last copy hands its augment to the Broken row, the mend hands it back; a spare copy keeps it on the working stack. A tool upgrade that uses up a tool (e.g. Steel Spade to Masterwork Wheel Hoe) carries the augment to the new tool. A tool with an augment cannot be traded or gifted.
  - **Kit mending:** mend order is free Tool Shed mend, Glowcap kit (lantern), Tool Repair Kits, Ooze Salve, Petals. Setting `tool_mend_kits` (default 1,2,4,8 by tier; 0 turns a tier off); tier 3 also takes 1 creature part of any family, tier 4 one rare part. If kits or the part are short, nothing is spent and the mend costs Petals. The mend button names what it will use. New row `tool-repair-kit-silk` (2 kits from 2 silk and a flint).
  - **Crafting map:** `tool-repair-kit*` is on the garden shed's watering can, `aug-*` on the mortar and the still (fixes the `tool-repair-kit` craft_tags FAIL). New `tests/augments.php` (from `tests/tools.sh`); `tests/alchemy.php` and `craft.sh` count 21 potion recipes.
  - **Defaults chosen:** Ooze Salve spends after kits (it only covers mends that would cost Petals); Gem Charm spends a use per find by that tool; Wing Fletch and Plate Edge only when they act.
- **Creature parts on the compost heap (plan phase 2).** New column `garden_buildings.scrap_bank` (db_migrate). "Add parts" in the Compost Bin panel (`add_parts_to_heap()` beside `add_food_scraps`): Hide, Wing and Silk parts are 3 heap scraps each, Ooze 4 (settings `part_scraps_hide/wing/silk/ooze`). The heap takes what fits; the rest banks and moves in as you collect, so nothing is refused. Plate parts are crushed 2:1 into Shell Meal (`part_shell_meal_parts`, default 2: Shell Meal sells for 15-35, 1:1 would be a sell loop; a leftover odd part stays in the satchel). Gem parts are not compostable. Test: `tests/compost_parts.php` (suite `compost_parts`).
- **Creature parts as Tailor materials (plan phase 3, sink 1).** `wear_qty()` and `wear_take()` understand `any-<family>` / `rare-<family>` (cheapest first, all or nothing; named "any Hide part" in the materials text). Lining a wearable has a second way: 2 any Silk parts instead of the old materials (`wear_line_mat_options()`; the first affordable way is used). The generator `tools/build_wear_items.py` now adds `any-hide:1` to the 56 Rare Tailor wearables (`wear_items.txt` regenerated; read at run time, so existing worlds get it too).
- **Creature parts: Codex donation (plan phase 3, sink 2).** Table `pf_codex_parts (user_id, slug, given, done_at)` is created on first use like `pf_codex` (`pfcx_parts_ensure`). A met creature's sheet has a Parts block and a "Give parts" button (`do=cx_donate` in `puzzlebox.php`, `pfcx_donate()`): it takes the part items that creature (or its family) drops in `creature_drops`. The 3rd part pays once: 40 Petals x level band (1 + (level-1)/10) and 20 XP. New settings `codex_part_need` 3, `codex_part_petals` 40, `codex_part_xp` 20.
- **Creature parts: Fair diorama class (plan phase 3, sink 3).** `FAIR_CATS` gains `diorama` (🦔 Creature diorama, no plant kinds). Pressing Enter builds it from the satchel (`fair_diorama_pick`): one of each distinct part held (rare and one-per-family first, at most 12), used up. Score = distinct families x 10 + rare parts x 5, capped at 100 so it stays on the crop scale (`fair_diorama_score`); kept through `fair_keep_best`. A diorama that would not beat the month's best is refused and keeps the parts. Townsfolk enter it too. No schema change.
- **Creature parts: Hovel trophy wall (plan phase 3, sink 4).** New Furnish slot `trophy` (Bare wall, A trophy, Trophy row; box 214,100 64x36) in `hovel_decor.json`, items flagged `new` show a "New" label. New table `user_trophies (user_id, creature_slug, item_id, pinned_at)` in `home_slim_schema` (created on upgrade, lazily by `hovel_decor_ensure`). "Pin it" on the Furnish tab (`do=trophy_pin`, `hovel_trophy_add()`) uses up one part of a creature, one trophy per creature; 1 trophy owns A trophy, 3 own Trophy row (`hovel_decor_owned`). Placeholder art only (the picker draws its dashed box); no PNGs were drawn. New suite `trophies`.
- **Creature parts: villagers who ask for parts (plan phase 3, sink 5).** New data file `data/trail_sight_folk_parts.txt` (loaded by the existing `trail_sight_folk_*.txt` glob), five Sight folk rows with `give=any-<suffix>+<suffix>:2` (the family words): Perrin Cobblefield (Hide), Thimble Hollowell (Plate), Plume Rosewader (Wing), Orla Cobblefield (Silk), Pomeroy Crumbworth at the Kelp Line (Ooze; he is only about while the Gourmand is open, so it is invisible on a default install, by choice). Each pays 2 friendship, XP and 20 Petals (Pomeroy 40), once a day. The folk mechanism takes the family as `give=`; `take=` belongs to Sights themselves. Job Board rows were not added: `deliver_gather` in `jobs.php` picks one concrete gatherable from the player's context and takes no family token. New suite `sight_parts`.

### Balance, news, docs (creature parts phase 4)
- **Augment balance check.** `tests/balance_sim.php` (crops; needs an installed site) and `tests/balance_pace.py` (needs `/home/claude/bal/crops.json`) do not run here and do not model tools, so the numbers are by hand from the code. Tier 2 gather tool: 150 uses (`gather_tool_uses`), rarity weights common 60 / uncommon 30, sell x1.0 / 1.3 / 1.8. Per find, compared with no augment, over the whole tool life: Plate Edge +8% value (25% of finds one rarity up, 40 swaps is about 160 finds); Gem Charm +2% value while it lasts (30 uses, +0.4% over the life); Wing Fletch +35% items while it lasts, 25 extra items over 150 finds = +16.7% at 1 item a find, about +12% with a tier 1 basket, +7% in sleep-days (2-3 items a find); Hide Binding I/II: no change in finds per energy (longer life only); Ooze Salve and Silk Lashing: save mend cost, not finds. Only Wing Fletch at the worst case (1 item a find, no basket) is above 15%; not clearly off, so left as it is (tune `AUG_DEFS` uses 25 to 20 if play shows otherwise). Augments are consumed with their parts, which is the price of the bonus.
- **Almanac:** the Exploring & fighting page says how mending works (free Tool Shed mend, then Tool Repair Kits, then Petals; augments). Boot step `almanac_mending_2758`; glossary "Tool wear" updated.
- **Player news** for 2.7.58 in `update_news.php`.
- **Guide:** `tests/build_guide.py` builds the visual style guide (needs Playwright and Chromium), not game rules, so it was not rebuilt.
- **CI:** every new suite is in `DEFAULT_SUITES` (`item_review_a`, `item_review_b`, `item_review_b2`, `compost_parts`, `trophies`, `sight_parts`, `pf_stat_pieces`); the augment and part checks run inside `tools` and `craft`.
- **Stat pieces, animation:** the 24 stat pieces (Nimble, Lore, Luck, Sense) have their own edge and chain effects: motif modules `claude/pf-anim/motifs/stat_*.js`, `lore_pieces.js`, `luck_pieces.js`, `sense_pieces.js` (ported from the design mock-ups; Snare Field's twine glyph renamed `gv-snareloop` because Knot of Twine already owned `gv-loop`), the piece-to-motif table `claude/pf-anim/stat-pieces.json`, `pfanim-data.json` key `sp`. The gnome's own piece of that name uses it; a creature piece of the same name does not. Same Full/Light/Off setting; with `pfight_statpieces` Off nobody owns the pieces, so nothing changes. `tests/pfanim_unit.js` draws every motif.
- **Stat pieces, art:** the 24 `ico-stat-*` icons show on stat pieces (the piece carries `ik` = its key; `pfparts47.js` draws the icon of a piece of yours, as it did for the creature's), and the kit art in `img/pfight/stat/` is wired: stat badges in the owner corner, Knot of Twine's `any` sockets (knob right and bottom, hole left and top), the Spring tile and blossom, the stolen hook, the snare ring on the board. Each falls back to the old look if its file is missing. Test `tests/pf_stat_art.php`. Not redrawn (weak): Knot of Twine, Lucky Streak, Nimble 20 px icons.
- **Item review leftovers:** (EC4) a festival comes round again every year on the admin-set dates (same month and day, same length; setting `fest_<slug>_yearly`, on by default); the next year is a new run key, so flags, rewards and stall limits start fresh. The Tool Repair Kit text says it also mends garden and gathering tools (free Tool Shed mend, then kits, then Petals), and an existing world's old text is updated unless an admin edited it. The Job Board can ask for a creature part family: new kind `deliver_part` with an optional 11th `jobs.txt` column (`any-hide`, `rare-wing`, ...; `job_templates.part_token`), three rows added insert-only, handed in cheapest first with the rare part kept to last. Recipe cards show the family icon (🐾 🐚 🪶 💧 🕸️ 🦪) for `any-`/`rare-` ingredients instead of ❔. No art exists yet for augments or the trophy wall: augment items show their family icon instead of the generic box, the trophy wall keeps its `scenes/hovel-trophy-*.png` path (placeholder until drawn). Suite `item_review_c`.
- Stat pieces: Snare Field's rings now show during the replay of the turn (the board's `prev` carries `snares`), so they no longer vanish until the replay ends; a stat piece that left the board keeps its stat badge (`st` in the gone view, PHP and JS twin). Only with `pfight_statpieces` on.
- `tests/pf_stat_balance.php`: balance tool for the 24 stat pieces (same gnome and seeds with and without one piece packed). No data row changed: outliers Knot of Twine (weak), Eyes of the Wood (strong) need a rule change, see `claude/todo.md`.
- Tests (final verification): `tests/pfengine_js.sh` now runs its fights in 4 parts side by side (the stat piece modes made the single run longer than the 600 s CI limit; 1628 fights in all, same checks); `tests/social100.sh` sets `fest_opening_day_yearly` to 0 for its "ended festival" step (EC4 makes a festival recur).
- **Item review, group C (owner decisions; each follows the option `docs/item-review/review.md` recommends).** Boot steps `merge_items_2758` and `kettle_keys_2758`, code in `includes/upgrade2758.php`, tests in `item_review_c`.
  - **R8:** Skink Scale, Glass Wyrm Scale and Giant Otter Pelt are Lizard Scale, Wyrm Scale and Otter Pelt in every drop table (`pf_creatures.txt`; the sandfish skink shoal's two scale entries became one Lizard Scale at 55%, the higher chance). Existing worlds: drops and satchel stacks move onto the generic item, a creature that had both keeps one row at the higher chance; if the generic item has no row yet the old row is renamed in place. The old item rows stay, unused.
  - **R15:** Kelp Frond, Shale Chip and Sawdust Heap are Bladderwrack, Slate Shard and Wood Chips everywhere (creature drops incl. the Shale Slater, the coast landscape find, road event, Maplewold Sight, the three rest-stop crafts). Existing worlds: same merge as R8; a drop row that had a gated Bladderwrack twin (Sea Slug Drift) is one ungated row at the higher chance; the three stop crafts are re-pointed only while they still hold the old spec. The coast landscape find Kelp Frond became Sea Salt (Bladderwrack was already a find; Sea Salt is a coast gatherable; assumption). `new_items` of four creature rows set to `-`.
  - **R14:** the kettle journal keys `mint-tea`, `meadowsweet-tea`, `desert-sage-tea` are `kettle-mint-tea`, `kettle-meadowsweet-tea`, `kettle-desert-sage-tea` (`teas.txt`; the Kitchen recipes keep their slugs). Journal rows move; a gnome with both keys gets the summed times and the earlier day. `tests/tea.php` uses the new keys.
  - **H4:** no behaviour change. The dependency is stated in the Game settings label of `gourmand_open` and on the admin Gourmand page: the Second Spoon decoration and title come only from his finale.
  - **B6:** one rest-stop craft each (`stop_acts_regional.txt`, insert-only, regional): Perilla x3 to Kimchi (EA), Tamarillo x3 to Tomato Chutney (SA), Naranjilla x3 to Lime Cordial (SA), Noni x2 to Sea Buckthorn Juice (OC). Regions are the ones where each crop is an uncommon one.
  - **B7 skipped:** review.md says keep (the gift role is intended) and gives no concrete buff rule.
  - **Assumptions:** the generic item (not the rare one) survives each merge; a merged drop keeps the higher chance; old item rows are not deleted (nothing else references them, and deleting would orphan art and Almanac rows); `kettle-` prefix for the renamed keys; the B6 outputs and amounts are my choice (existing dishes, 2-3 crops per jar).
  - **Group C, second pass** (boot steps `stop_tune_2758` and `plank_rope_2758`, `includes/upgrade2758.php`; each only moves a row that still holds the old numbers; tests in `item_review_d`).
    - **R5 (stop-craft dupes):** I compared every rest-stop craft with the kitchen or craft recipe of the same output (ingredient base value per unit). 8 were exact copies (same inputs, same yield) and are cut from `stop_acts_regional.txt` / `stop_acts_waves.txt`: `ca_tortilla_press`, `r_mena_ember_sage`, `r_mena_high_pour`, `r_ee_sunflower_toast`, `w1_meadowsweet_tea`, `w1_griddle_cakes`, `w4_smoke_trout`, `w4_snail_glaze` (new worlds only: existing worlds keep their rows, nothing deactivates them; their art files stay). 40 crafts cost under 90% of the recipe (e.g. Three Sisters at the rest stop 94 vs 171, Plum Butter 3 plums vs 5, Fiddlehead Fry 3 vs 2 plus garlic): each takes more of its first ingredient, at most +3 (`STOP_TUNE_2758`: Three Sisters 3 corn, Plum Butter 5 plums, Naranjilla Cordial 4, Noni Juice 5, Perilla Kimchi 6). Existing worlds: the same new spec through `stop_tune_2758`, only for a row still at the old spec. The other 44 acts that share an output with a recipe (rope, planks, shell meal and clay pot aside) already cost at least 90% and stay (they use regional inputs, so they are not copies). Regional counts: 490 regional acts (was 494), 261 plain wave acts (was 265).
    - **R16 (planks and ropes):** rule: input value per plank or rope between 0.4x and 4x of the item's base value, and equal-priced inputs give equal yield. Wood-chip planks 2 to 3, palm planks 1 to 2, driftwood planks 1 to 2, oak planks 4 to 3, cottongrass and cattail rope 3 to 2 fibres (as coir), goat-hair rope 3 hair to 1 hair for 2 rope; `rope-shed-skin` is left (it pays in creature parts, whose price is a drop rarity). Rest-stop acts: Enset Fibre 2 ensete now gives 3 rope (was 1, at 102 a rope); the plank and rope acts that take 2 to 3 inputs for 1 stay worse than the crafts on purpose (they also pay Petals and XP), so I did not cut them. Existing worlds: the recipe rows move through `plank_rope_2758` (only while they still read the old ingredients and yield).
    - **R18 (wearable pairs):** clear rule found, so done: in each pair (n=1/2, n=3/4) the second item swaps the two local material amounts (Common 2+1 becomes 1+2, Uncommon 3+2 becomes 2+3), 112 rows, Rare unchanged. The two locals are worth 7 to 12 each, so a pair's costs differ by at most about 16%. Source `tools/build_wear_items.py`, `wear_items.txt` regenerated; materials are read from the data file, so existing worlds follow at once and pieces already made are untouched.
    - **R9 / uA-4 / B1 (creature parts):** after phases 0 to 3 every creature part already has sinks (Codex donation, Fair diorama, trophy wall, NPC gift, market). What was missing was a *recipe* sink for the 58 parts whose name ends in no family word. `PART_FAMILIES` now knows 52 more words (Hide: ruff, velvet, beard, foot, patch, brush, strip, pad, frill, fringe; Plate: shard, jaw, crown, crest, carapace, beak, tusk, spike, spur, tip, case, crust, proboscis, needle, tube, ring, eggshell, sucker, fin, gorget, spade; Wing: pinion, tailfeather; Ooze: fat, chunk, wart, pellet; Silk: sash, knot; Gem: gem, jewel, eye, pebble, trinket, bauble, spark, mote, light, lamp, lantern). Nothing is deleted, merged or renamed, no migration (families are worked out from the slug each time), so these parts now count for any-/rare- recipes (augments, compost, shell meal, Tailor lining). Left out on purpose: 23 plant, nest and material 'parts' (beeswax, black-truffle, lavender, pika-haypile, ...), which are not animal parts or have a recipe of their own.
    - **Assumptions:** (1) "exact copy" means the same inputs and the same yield; (2) "cheaper" means under 90% of the cheapest same-output recipe by base price, and the fix raises the first-listed ingredient (the act's main one) rather than adding a new one or giving a new regional output; (3) the cap of +3 is mine; (4) existing worlds keep exact-copy acts (the lead said cuts only affect new worlds); (5) plank and rope bands (0.4x to 4x of base value) and the 2-fibres rule are mine; the tied rows are listed above; (6) the pair rule swaps amounts rather than adding a second material or a part; (7) family words were picked by reading the 58 slugs, not from a list in the review; gems took the light and spark items ('glowworm-lantern', 'ember-spark') because no other family fits them.
    - **Not done:** R5 for acts whose output has several recipes (rope, planks, shell meal, clay pot) beyond R16; B7 (above); deleting or folding any creature part (destructive for held stacks and drop tables; the review's own alternative, a shared sink, is what the families give); MySQL; a real browser.
- **Stat pieces, new animations** (`pfight_statpieces`; visual only, Full mode; Light keeps the place motion, Off and reduced motion draw nothing; the engine's own state is untouched). No mock-up exists, so each is built from `claude/stat-pieces-design/stat24.json` and the art brief:
    - **Loaded Die:** a hatch opens on the piece, a cell-shaded die pops out in an arc, tumbles and lands on the piece it links to (else the next cell toward the middle of the board) with a bounce, dust and a shake of the piece under it; a hit settles on a 5 or 6 with a gold ring, a miss on a 1 or 2 with a grey puff; the hatch shuts behind it. The tumbling pip-cubes (edge and chain carrier) are gone; the edge keeps gold glints.
    - **Trapdoor (Snare Field):** when a creature piece comes down on a snare the cell gets a plank frame, its lid stands open as the piece drops in, a leaf noose cinches and the lid slams shut with a thump. The creature's fire event now carries `snr` (set only for a piece placed on a snare; the same in `pfboard.php` and `tools/pfengine.js`, so fights are unchanged with the setting Off) and the board replay calls `PFAnim.trap`.
    - **Landing shake:** a stat piece landing on the board shakes (about 240 ms, x / y / tilt, decaying) with a few specks of dust off its base (dust in Full only).
    - **Empowered overlay:** the piece a stat piece boosts (Old Saying, Knot of Twine, Copybook; every later piece of yours for Lantern Chain) wears a 32% overlay in the stat piece's light colour from its booster's step until it fires (then 0.3 s fade). The target is read from the booster's chain order and `wfx`; Turn of the Tale's steal and Weather Lore are not marked.
    - Source: `claude/pf-anim/motifs/stat_fx.js` (new, `PFA.stat`), `tools/pfanim_part.js`, `tools/pfboardv1_part.js`; rebuilt with `tools/build_pfanim.py` and `tools/build_pfboardv1.py` (`pfanim-data.json` 225 KB). Tests: `tests/pfanim_unit.js`, `tests/pfanim.js`.

## 2.8.27
Item review A and B (data and small code fixes) and the stat pieces (puzzle fights, setting `pfight_statpieces`, default Off).

### Item review A (data)
- **Item review, group A (data), part 1.** Drum Circle Market stage 1 needs 1 Drum Skin (was 3, scaled up by region; the only source gives 1 per Trek run). `tools/scale_build_plans.py` never scales `drum-skin`; base edited in `claude/build-plans-base.txt`, `build_plans.txt` regenerated (H1).
- **Names.** Produce no longer shares a name with its seed: Sunflower Kernels, Sesame Grains, Cumin Spice; the Sacred Lotus seed is "Sacred Lotus Tuber" (R1, R2). `catalog.php` for new worlds, boot step `item_review_names_2758` for existing ones (names only).
- **Eggshell.** Creature drops use one slug, `hatchling-eggshell` (R6, uA-6).
- **Cut near-duplicates (new worlds; existing worlds keep their rows, insert-only):** pickled-peppers, natto, dried-cranberries, sun-dried-tomatoes, aged-goat-cheese removed from `recipes.txt`; Fermented Hot Sauce now takes 8 chili + 2 garlic so it differs from Hot Sauce (R10-R13). `craft_scenes.php` globs updated.
- **Crab Claw (R7):** the five single-creature variants (rock, mud, land, ghost, palm) are now plain `Crab Claw` drops. Slugs already dropped stay in satchels.
- **Wearable name clashes (R17):** 5 reused names got a region word (Rift Calabash Carrier, Congo and Reef Bamboo Frame Pack, Savanna Thatch Rain Cape, Jungle Kapok Puffer). Edited in `claude/wear-pieces/pieces.json`, `wear_items*.txt` regenerated by `tools/build_wear_items.py`.
- **Item review, group A (data), part 4.** All insert-only rows (existing recipes are never edited), so no migration for them: `ensure_crafts` and `trail_sight_b_ensure` add them to existing worlds on boot.
  - **E1 camping gear:** alt rows `metal-pins-flint` (1 flint, 4 pins), `camping-pot-clay` (2 river clay), `canvas-sheet-coir` (4 coir). The whole kit is about 125 Petals of base value (was about 216). The 100-Petal shop price is not raised (owner). The misleading "about 60 Petals" comment in `game_clock.php` is rewritten. Their craft-map globs fix the camping line of `tests/craft_tags.php` (4 FAIL lines are now 3).
  - **E3 decor:** `firefly-jar-small` (1 glow + 1 clay, 67 base, was 177), `toadstool-ring-small` (4 chanterelle, 48, was 102).
  - **uA-5:** `feast-truffle-risotto` (Black Truffle Risotto, a feast, so a level 3 Kitchen) uses the Black Truffle.
  - **B2:** 25 early legacy creature parts got one use each, as alt rows of existing outputs (compost, castings, shell meal, leaf mould, potions, rope, candles, wind chime, lantern). Not covered: wasp-stinger, scorpion-stinger and the other legacy parts nothing small fits; the ~340 other parts stay with the creature-parts plan (group C).
  - **B3:** newt-tail (Grand Healing Elixir), pale-scale and quartz-shell (Scute Wind Chime), silverfish-scales (Wing Scale Lantern) have alt recipes outside the Trek.
  - **B5 (done as data, not as code):** hybrids cannot stand in for their parent without touching `craft_stock`, `craft_recipes`, `craft()`, pantry and cooking, so instead each of the 8 dead hybrids has its own dish or preserve: Triticale Loaf, Tritordeum Porridge, Pomato Soup, Radish-Cabbage Slaw, Orangelo Sorbet, Tangor Marmalade, Sunrise Lime Cordial, Nessberry Jam.
  - **uA-3 / B4:** the 8 curios and 9 Sight trinkets are keepsakes now (`trail_sight_keepsakes.txt`, +1 find with one tool each; at most 2 keepsakes count at once).
  - **Craft-map tags:** `craft_scenes.php` globs widened (`firefly-jar*`, `toadstool-ring*`, potion `*` suffixes, `bug-castings`, `paper-comb-candles`, camping parts) so every new row opens from an object.
- **E6 / E9 (changed rows, boot step `item_review_data_2758`, marker setting of the same name, `includes/upgrade2758.php`).** Dewdrop Kitchen soup is stocked at 1.0x the home dish base (90 Petals, was 40-55; `seed.php` for new worlds; the stock row only moves if it still reads 40/55; the shop-bought copy's base 20 becomes 45). Weak dishes raised (only where the item still has the old numbers, an admin edit is kept; `recipes.txt` for new worlds): Grilled Sardines grit 3 + hardiness 1 for 240 min (was grit 2 / 120), Toffee Apple charm 3 + nimble 1 / 240 (was charm 2 / 120), Toasted Sunflower Seeds nimble 2 + sense 1 / 150 (was 1+1 / 120), Goat Cheese Salad charm 2 + sense 1 / 180 (was 1+1 / 120). These four were the only dishes whose buff was below their best raw ingredient.
- **Inventory clean-up (docs only):** H5, R19, uA-7, B9, EC12 applied to `docs/item-review/items.json` and `nodemap/items.json`: false orphans given their sources, 102 name-variant dupes dropped, 11 trek-flag phantom nodes removed, Twigg's no longer lists produce it does not sell (it sells seeds), broken-tool sell notes fixed, false "useless" items annotated. The graph does not know the 2.7.58 recipes.
- **Fix to R17:** the five renamed wearables' catalog blurbs (`claude/wear-pieces/wear_pieces.txt`, `wear_items_pieces.txt` regenerated) still began with the old names, which failed the `wearables` suite's lint; they use the new names now.
- **Skipped on purpose:** B7 (buffs on buff-less preserves: the review says keep, the gift role is intended). B5 stand-in code (above). Group C items untouched.
- **Tests:** new `tests/item_review_a.sh` / `.php` (in `DEFAULT_SUITES`); `tests/sinks097.sh` feast counts 15 to 16.
- **Not checked:** MySQL; a real browser; the full CI list (ran `item_review_a`, `buildplans`, `pantry`, `cook`, `sights_items`, `flowers`, `sinks097`, `gather099`, `tools`, `yard` plus a wider craft/trail set); the upgrade-from-old-release job.

### Item review B (small code)
- **Item review, group B (small code), part 1** (boot step `broken_untradable_2758`, `includes/upgrade2758.php`).
  - **EC1:** a Seed Packet sells for at most its seeds' value (seed base x packet seeds x the sell share), so packing seeds is no longer profit (`packet_sell_cap` in `world.php`, also in `flat_sell_value`).
  - **EC2:** a Dried flower keeps its cut flower's rarity tier (`dried_cut_item`, `item_rarity`) and sells for at most `dried_price_pct` of the cut flower's buy floor.
  - **EC3:** one `shop_discount_pct()` for `shop_price` and `shop_buy_floor`, so the floor counts Silver Tongue and Trail Sight discounts too.
  - **EC5 / EC6 / EC7:** mending a Broken copy resets wear only if no working copy is carried; Broken items are tradable=0 (existing ones by the boot step) and `tool_trade_block` refuses category `broken`; the day's free Tool Shed mend is used before a Glowcap kit. The Glowcap kit text now says it mends a lantern only and is not the fight-belt Tool Repair Kit (`pfdeck.php` is off limits this release, so its text is unchanged).
  - **EC8:** `give_item` clamps to `items.max_stack` (extra is dropped, returns true). **EC9:** a bulk sell is priced in `price_vol_units` chunks. **EC10:** a shop markup below 0 counts as 0.
  - **Tests:** new `tests/item_review_b.sh` / `.php` (in `DEFAULT_SUITES`); `tests/market100.php` dried-preserve count 7 to 6 (group A removed dried-cranberries, so this was already failing).
- **Item review, group B (small code), part 2** (boot steps `drop_twins_2758`, `stop_acts_2758`, `tool_prices_2758`, `includes/upgrade2758.php`; each one only touches a row that still has the old numbers).
  - **uA-1 / uA-2:** `pfc_item_for_drop` finds the real item first (the cut flower, or the crop's produce, by the plant's name), so Cornflower, Foxglove, Heather, Date Palm, Prickly Pear Cactus and the rest are no longer new 'part' twins that cannot be arranged. A real non-part item of the name (Edelweiss the gatherable, Sight items) still wins. Existing worlds: the boot step moves the twins' drop rows and satchel stock onto the real item (the twin item row stays; nothing else references it). Water Spinach already matched. Lavender is left alone on purpose: the part Lavender is a tea ingredient (`teas.txt`).
  - **R3:** alt rows `rock-garden-cut` and `grand-healing-elixir-cut` take Cut Edelweiss (insert-only). The Sights only give edelweiss (none asks for it), so nothing to change there.
  - **R4:** the three rest-stop crafts make Egusi Soup, Buckwheat Kasha and Hibiscus Cordial (`stop_acts_regional.txt`; boot step for existing worlds).
  - **E2 (tool prices):** chose to cut Twigg's tier 2-4 prices, not raise craft costs (40 numbers in `TOOL_ITEMS` against editing about 25 existing recipes, which ensure_crafts never updates): tier 2 and 3 x0.6, masterworks x0.75 (Garden Hoe 250 to 150, Steel Spade 1200 to 720, Masterwork Wheel Hoe 6000 to 4500). Item base price, the Broken copy and the shop row move together. The gap to the craft route is smaller but stays (the premium for skipping the hunt is deliberate); crafted tools are unchanged.
  - **E5:** a new dish is priced from its ingredients' flat shop value (rarity counted, as `preserve_price`) x a tier factor (`DISH_PRICE_FACTOR`: snack 1.4, meal 1.6, feast 2.0), so no dish sells for less than its raw ingredients. New worlds only (insert-only); a dish whose ingredient does not exist yet (the hybrids) is made on a later run at its right price instead of 20 Petals.
  - **E8:** `eat_item` asks before a meal buff replaces a stronger one (stat points x minutes left; with the Brewroot perk only the slot it would take). The refusal keeps the item and says "Eat it again to swap"; the same item again within a few minutes confirms (session), or call `eat_item($u, $id, true)`.
  - **EC4:** the festival tables are keyed by a run key (`festival_run_key`, setting `fest_<slug>_run`): the first run keeps the plain slug (rows stay valid), a later run is `slug@start`, so a re-run has fresh flags, rewards and stall limits. Dates moved by up to a month stay the same run. Not done: scheduling the festival yearly (dates are still the admin's settings).
  - **EC4 / E7:** the Opening Day Bunting can also be made (`opening-day-bunting`: 2 rope, 3 silk thread, 2 red ochre; insert-only, on the picket fence). Stalls sell bundles (4th number of a `sells` entry): 6 compost 50 Petals (limit 4), 3 castings 110 (3), 3 loam 150 (3), 6 rope 45 (4); each piece is now at most 1.25x base. Defaults chosen by me, no owner value.
  - **EC11:** hovel decor with no source says "Coming soon" instead of promising a Market price or a Journey step (`hovel_decor.json` still holds the planned source).
  - **Tests:** new `tests/item_review_b2.sh` / `.php` (in `DEFAULT_SUITES`). Updated for the new rules: `social100` (stall 50 Petals, limit 4), `craft` / `alchemy` (14 potion recipes, 5 stepping-stone recipes, drinks start with no buff), `cook` (eating starts with no buff, plus a confirm check), `creature_windows` (the Prickly Pear drop is the produce item).
  - **Not checked:** MySQL; a real browser; the full CI list.

### Stat pieces (puzzle fights)
- **Stat pieces: overview.** Each gnome owns unique pieces by its Nimble, Lore, Luck and Sense points (not Grit, Hardiness, Charm): tiers 0 (everyone), 10, 15, 20, 25, 30, 24 pieces in all (`data/pf_stat_pieces.txt`, one row each; mirrored in `tools/pfengine.js` as `PFB_STAT_ROWS`). They are packed like counter knacks (off until switched on). Numbers: a = 1 + points / 5, b = ceil(a / 2). The shared Luck roll is min(90, 50 + 2 x Luck) %, rolled once per firing and cached. All behind admin setting `pfight_statpieces` (Off / Admins only / Everyone, default Off); Off = byte-for-byte the old fights (md5 tests in `tests/pfdeck_v1.php`). Full write-up: `claude/stat-pieces-spec.md`.
- **Nimble (6):** Sidestep, Skitter, Wrong Turn, Pinning Stance, Shadow Step, Phantom Footing (move or skip the creature's aim, evade, a once-a-fight jump). Test `tests/pf_stat_nimble.php`.
- **Luck (6):** Loaded Die, Hedge Rummage, Long Shot, Magpie's Pinch, Turn of the Coin, Lucky Streak (the shared roll: refire, pluck, take or send back a creature piece). Test `tests/pf_stat_luck.php`.
- **Lore (6):** Old Saying, Knot of Twine (`any` edges), Lantern Chain, Weather Lore, Copybook, Turn of the Tale (boosts, a Sun or Spring, tag teaching, take over a creature piece). Test `tests/pf_stat_lore.php`.
- **Six Sense pieces** (`pf_stat_pieces.txt`, PHP `pfboard.php` and JS twin `pfengine.js`; behind `pfight_statpieces`, default Off): Sharp Eye (see the creature's piece after its aim; played: its next piece loses a), Eyes of the Wood (see its hand and draw top; each piece it places loses a), Not Fooled (no combos for its next turn), Snare Field (free neighbours get a snare mark for 2 rounds; a creature piece on one is half value), Soft Spot and Saw It Coming (existing clauses, now live). Tests `tests/pf_stat_sense.php` (run by suite `pf_stat_pieces`).
- **Stat pieces, UI** (only with `pfight_statpieces` on for the gnome). Puzzle box shelf: owned stat pieces carry a small tier plate (the points they came with; tier 0 has none); the pieces a gnome has not reached yet sit on the shelf greyed with "Locked: Lore 15" and, in the sheet, how many points to go (tap to read, cannot be packed; `pfd_toggle` still refuses a key the gnome does not own). Stat filter and legend count them. Board (`pfboardv1.js`, hand edit; `build_pfboardv1.py` not run): Snare Field cells drawn as a dashed ring with a spoken label and rounds left, Sharp Eye and Eyes of the Wood chips (the creature's next piece; its hand and next draw) from `data.sight` / `data.eyes`, a creature piece stolen by Turn of the Tale or Magpie's Pinch marked on the cell and in its tap text, a Copybook-taught tag noted. Test `tests/pf_stat_ui.php` (in `pf_stat_pieces.sh`). Art (snare PNG, stat badges, stolen hook) is wired in a later pass; these marks use CSS and emoji until then.

## 2.8.26
- **Jigsaw / GIFsaw on a phone held sideways: a slim top bar.** On short landscape screens the title and help line go, the buttons shrink to one 30 px row (Library, pieces, Guide, Scatter, zoom, Copy link, count), and the empty site-header strip above the table is hidden, so the table gets about 40% more height. Portrait and big screens are unchanged.
- **No second full screen button.** Where the play rail already has its own (fights, puzzles), the corner button from 2.8.25 stays hidden.

## 2.8.25
- **Landscape full screen on phones and tablets.** A small ⛶ button in the top-right corner (landscape, touch screens, browsers that allow it) enters full screen and asks for landscape; ✕ leaves. Browsers drop full screen on every page load and allow it again only after a tap, so the choice is remembered on the device and the first tap on each new page puts it back. Portrait leaves full screen. iPhone Safari has no full-screen API, so no button there. The web manifest now asks for full screen when the game is added to the home screen.

## 2.8.24
- **Release notes for the new landscape layout.** A player news post ("a new layout for your phone held sideways") is published the first time 2.8.24 loads. No layout changes.

## 2.8.23
- **Launch: the landscape dock is on for every player.** Phones and tablets held sideways get the bottom dock (menus, status plate, two page actions); portrait screens and big screens keep the classic layout, as before. The upgrade sets the setting nav_dock to 1 once; an admin can set it back to 0 (off) or admin (preview) in Admin → Settings and that choice is kept. Anyone can add ?dock=off to an address to use the classic layout on their own device (?dock=on switches back).

## 2.8.22
- **Garden, landscape layout: the garden and its info panel are centred together** instead of hugging the left edge.

## 2.8.21
- **Garden, landscape layout: the garden slides to the left edge and the info panel sits right next to it, wider (290 px).** Squares resize to fit both.

## 2.8.20
- **Garden square / crop info, landscape layout, reworked.** The panel stays beside the garden as you scroll (sticky) and scrolls inside itself, so it never runs under the dock. Order: heading, status, chips, the Next line, then the action buttons (Till, Plant, Work in, Add mulch…, full-width and readable), then the soil numbers. The nutrient row and the upkeep chips are hidden there to shorten it (the low-nutrient warning still shows in the chips and the Next line). The "⬆ yard" link is gone.

## 2.8.19
- **Garden, landscape layout: the "Pick a square" panel is a readable 250 px column** (left-aligned, smaller buttons), and the squares shrink to leave it room, so the garden and the panel sit side by side without sideways scrolling. 2.8.18 made the panel too thin.

## 2.8.18
- **Garden, landscape layout: the garden and the "Pick a square" panel sit side by side with no sideways scrolling** on a narrow phone view (the panel is a slim 176 px column with smaller text).

## 2.8.17
- **Garden, landscape layout: the garden name and the five tabs are on one line** even on a narrow phone view (smaller tabs and heading). The "about this spot" line no longer wraps.

## 2.8.16
- **Garden, landscape layout: the cat line is hidden** so the tabs move up into the heading row beside the garden name.

## 2.8.15
- **Garden, landscape layout: your garden comes first.** The heading, tabs, location line and weather line now share two short rows, so the garden starts about 70 px higher (172→104 px at 844×390). The "Cat Fish" link is gone from the cat line (the cat line is also smaller and sits in the heading row).

## 2.8.14
- Puzzle Pals region folds: smaller region headings so long names fit their column in the landscape layout.

## 2.8.13
- **Pre-fight screen with Auto deck off: the creature's pieces show first again.** Your deck and bench were drawn on top of the creature's pieces in the two-column layout. Now the creature and its pieces stay at the top, and your deck and bench follow below them (scroll for those).

## 2.8.12
- **Pre-fight screen on a very short phone view: you see all of the creature's pieces again.** When the browser's own bars leave little height, the pieces shrink so both rows show above Let's fight (before, the button covered the second row). The creature card is trimmed to its name and first two tags, the rule text to two lines, and the read-only deck fold is hidden there.

## 2.8.11
- **Pre-fight screen on a phone in landscape: no more scrolling.** Two columns: the creature, its rule and the Auto deck line on the left, the pieces (5 across, smaller) on the right, then Box and Let's fight. The tap-a-piece hint line is hidden there. Portrait is unchanged.

## 2.8.10
- **Last folds and filters (landscape dock layout; the search boxes show everywhere).** Jobs, Post tab: the explaining lines fold into "How posting works" and small "Details" folds. Market day: a search box above the basket items (ticked ones stay). Pal jobs, At home: a "Find a pal" box when you have more than 12. Town Square: Where the travellers are and Festivals coming up sit side by side.

## 2.8.09
- **More folds (landscape dock layout only).** Almanac Glossary: one fold per letter, A open, the letter links open theirs (3606→1213 px). Almanac search: "Not found yet" folds. Creature Codex: undiscovered tiles become one "N not met yet. Show them" line (2025→519 px). Shop Sell: starts on the first category (Crops) instead of all items, All is one tap away (2883→1294 px).

## 2.8.08
- **Fix: the old "−1 energy" pop-up still showed in the landscape layout** (wander steps). Energy-only messages are now dropped there (the dock bar animation shows it); "(−N energy)" is also stripped from other pop-ups.

## 2.8.07
- **Folds for the tall pages (landscape dock layout only; other layouts unchanged).** Almanac chapters: one fold per category, the one with the open page (or the first) open (Creatures 2016→919 px, Plants 2707→901). Puzzle Pals: one fold per region (3133→1154). World map: roads and places fold under the region banner (→1026). Villagers: the not-met placeholders become one "N more not met yet. Show them" line (→422). How to play: the first two sections start closed (→434).
- **Fix: The Gourmand page had no footer, so no dock at all in the landscape layout.** Added the missing page footer.

## 2.8.06
- **Energy use is now a small animation on the dock energy bar** instead of "(−1 energy)" in the message. Spending: the bar glows, then drains by the amount while a "−x ⚡" ghost floats up from its edge and fades. Gaining (eat, rest): the bar fills with a green glow and "+x ⚡" rises. The words "(−N energy)" are dropped from page messages in the dock layout. Reduced-motion: no movement, the ghost just fades. In play-mode rail the ghost floats over the ⚡ count.

## 2.8.05
- **Landscape dock: tall pages shortened.** Tested CSS from a page-by-page survey: Almanac chapters (Creatures 5611→2016 px, Plants 4781→2707, Flowers 4183→2173, Pals 3644→1923, Glossary 4931→3606), Puzzle Pals, Puzzle box, Codex, Jigsaw, Pal jobs, Shop sell/buy, Villagers, World map, Town, Passport, Account, Guide, Market day, Tailor, Yard, Festival, Jobs, Belt, Gourmand, Trek, Community garden.

## 2.8.04
- **Random-event and prize banners are sleeker and have an ✕.** Smaller icon, title and text; tap ✕ to fade the banner out in place (no reload). Banners that still wait for your choice keep no ✕.

## 2.8.03
- **Wander: the "Past here it gets dangerous" warning is one slim line right under the picture, rings and choices** (12 px text, full width), instead of a tall red box far down below Gather and the journal. Seen on a fake step-4 wander at 844 x 390.

## 2.8.02
- **Puzzle fight, landscape: the Redraw option no longer hides the creature's yield bar.** The right column was centred and too tall (the "Redraw a piece" button was a full 44 px row), so it was cut off at both ends, hiding the top bar. The column now starts at the top, the redraw note and its button are a small chip over the lower right corner, the hand is 12% smaller and the last-plays box is capped at 46 px (scrolls). Seen on a fight with a first-fight tip and a forced redraw chip at 844 x 390; the bottom of the hand's tabs still dips under the rail.

## 2.8.01
- **Shops page (world.php?tab=markets): the market picture is big** (640 px wide, about 400 px tall at 844 x 390, was 340 x 214), since tapping a shop in it is the way in; the shop list is under it.

## 2.8.00
- **Dock: a Shops piece in the Out & about menu** (after Villagers), opening the world page's Shops tab. It is greyed "on the road" while walking, like World. The old menu sheet is unchanged. Seen in the strip at 844 x 390.

## 2.7.100
- **Shop basket (Sell all / Buy all) is a slim bar pinned at the top** in the dock layout: the picked items scroll sideways on one line, "You get n", Empty and Sell all / Buy all sit on the same row (50 px tall, was a big card that sat in the middle of the screen over the items). It stays at the top while the items scroll under it. Seen on a shop sell page at 844 x 390 with two chips; the error line ("not enough...") now sits under the bar, not checked.

## 2.7.99
- **Shop pages: the picture banner sits beside the Buy / Sell tabs** (in the empty space to their right, with "What sells here" under the tabs), instead of above them. The category chips and the items start about 100 px higher (`dock.css`; shop pages only, dock layout, landscape). Seen at 844 x 390 on a shop; pet shops, dye shops and florists have a different page structure and are unchanged.

## 2.7.98
- **Satchel item card scrolls to its buttons** (Sell, Gift, Eat, Cook in Crafting). The card is pinned beside the item list (2.7.93) but was taller than the sheet's scroll area, so its lower part could never be reached. It is now limited to the visible height and scrolls inside itself (finger drag moves it; Sell and Gift show after the drag). `dock.css`.
- **Crafting pop-ups: every quantity button is reachable.** The Cook x1 / x2 / x3 / x4 / x5 / All n buttons were squeezed into a narrow corner of each recipe row (since 2.7.93/2.7.96) and some were clipped. They now have a full-width row under each recipe, with Cook x1 the widest. Checked in the Bread oven pop-up (x1, x2, All 3 on one row; x1 to x5 on another). Not pressed for real.

## 2.7.97
- **The three long catalogue pages, denser** (`dock.css`). Puzzle Pals 4804 to 3105 px (each region is one slim box: title and count on one line, six small pals, no rarity or date lines), Villagers 2813 to 1982 px (smaller cards), Shop sell 3627 to 2977 px. These are real catalogues (15 regions, 122 villagers, 226 sellable items in the test world), so they stay long; going much further needs a change to the pages themselves (a region or category folded by default, or paging), which I did not make. Shop sell barely moved because its tiles are already close to their minimum size; the category chips (Crops, Flowers, Food...) are the quick way down.

## 2.7.96
- **Second page survey, on a seeded test world** (four agents; every fix was tested by injection at 844 x 390; `dock.css`, 41 rule blocks). Reached this time: crafting with real recipes, flowers and broken tools; an active job, the Post board, Trading tabs; Puzzle Pals, Pal jobs, mini-games played; Gourmand, Trek, Landmark and message-bottle pop-ups. Highlights: the craft pop-ups' head and tabs were squashed (title and X clipped) and are fixed; the Fast travel pop-up is two columns; the shop item sheets and the Market buy sheet fit without scrolling; the Tool-mend cards no longer overlap their text; the shop basket text is readable (dark on light; was cream on cream); World travel map 569 to 274 px and the region panel 762 to 522; Trek run page 1912 to 1130; the Arrange page (1345 to 962), Tailor (1931 to 1406), Workshop (1050 to 752), Gourmand, Puzzle Pals (6368 to 4804), Jigsaw (2759 to 1837), Mushroom, Worms, Marrow and Spit boards visible on the first screen; Satchel/Crafting/Tasks headers slimmer.
- **Not checked** (about 30 states; the lists are in the survey notes): touch drag scrolling inside the craft pop-ups, real Cook / Make / Mend presses, fight and reward overlays in Trek, race and spit result cards, puzzle play, pals out on jobs, mentor states, the cat home after adoption.

## 2.7.95
- **Garden building cards no longer cut off at the dock.** When a card is opened as a plain page element (the address `garden.php?t=pic&o=...`, as in your screenshot) it is not a modal, so it sat in the page under the fixed dock and its lower part was hidden. In the dock layout on short landscape screens it is now fixed above the page, ends at the dock's top edge and scrolls inside (`gyard.css`). Checked with the worm farm card opened that way (box ends 6 px above the dock, buttons reachable by scrolling the card). Modal cards (opened by a tap) were already fine.

## 2.7.94
- **Garden Buildings cards scroll on a phone on its side (second pass, with built buildings).** The 2.7.92 version kept the head fixed and scrolled only the body, which left a 186 to 236 px strip to scroll in and was easy to miss. Now the whole card (head and body) scrolls as one (up to 94 px more than the screen on the longest ones), and the head no longer takes a fixed block (`gyard.css`). Checked all 17 cards with built buildings in the test garden with a finger drag in a mobile-emulated browser: the cards that are taller than the screen moved 31 to 94 px; the others fit whole. Not checked: a building with an open Upgrade/Collect result.

## 2.7.93
- **Page survey, dock layout, landscape (five agents, each fix tested by injection at 844 x 390; `dock.css`).** Satchel Items (1034 to 724 px: the eight category tiles in one row; an opened item card sits beside the pills instead of below), Crafting area index (965 to 667) and area pages (1302 to 873: the scene beside the text), the crafting popovers (taller scroll area), Tool belt (1301 to 1075). Tasks Jobs (1103 to 904), Community garden (1138 to 918), Hollow jar (953 to 752), Market day (953 to 765). World travel list and the Seasons tables (two across). Fair (1415 to 727), Yard editor (sticky toolbar one row), the mini-game pages (boards start higher), Snail Race cards. Almanac chapters (Plants 12934 to 4781, Creatures 20481 to 5611, Gathering 9143 to 1866), Contents (six cards in a row), Letters.
- Fixed a stray closing brace in `dock.css` (left from 2.7.87) that could swallow the rule after it.
- **Not checked** (the test account cannot reach them): crafting Craft buttons, Pantry, Kitchen and Tool Shed areas, the flower arranger, drying rack and show, Daily/Gourmand/Workshop/Landmark/Sights pages, Puzzle Pals and Pal jobs, Jigsaw and GIFsaw, the Post board and Trading (locked by level). Some pages still scroll a lot (the Almanac's longest chapters, Villagers, the world map tab).

## 2.7.92
- **Garden Buildings pop-ups (the yard picture's building cards) scroll and fit on a phone on its side.** The card body had fixed minimum heights (176 px, 262 px for the home card) that, with the header, were taller than a 390 px screen, so the card (clipped, no inner room to scroll) lost its Build / Upgrade / Collect buttons. On short landscape screens the minimums are gone, the card is wider (up to 520 px) and the body scrolls (`gyard.css`). Checked all 17 building cards in my test garden (all locked ones: each fits, none clipped) and a touch drag scrolls the fence card. Not checked: a card of a building you have built (its Upgrade and Collect buttons).
- The Garden tab pages need the picture-garden flag (`gnav_garden`) for these cards; in my test it was on.

## 2.7.91
- **Garden tabs, dock layout, landscape, one by one** (`dock.css`; 844 x 390). All tabs: the garden name and the tab bar share a row. **Beds** (1284 to 1072 px): the plot on the left, the square's card and the legend beside it; the weather line and the spot note share a row. **Buildings** (688 to 680), **Animals** (734 to 726) and **Grow** (697 to 703) were already short and only gained the shared header. **Crew** (975 to 812): the three jobs are side by side. Popovers: the Plant, Work in and Mulch choosers open inside the screen with a 199 px scrolling list (they were fixed in 2.7.59 and 2.7.61); the Animals tab has only Rename and Send buttons, no popovers. **Not checked:** the Buildings popovers (my test garden has no buildings), the animal trade card with a real trade, and the Crew job pickers (Crew needs gnome level 10 and a pal).

## 2.7.90
- **Dock, Garden (Beds tab):** the left piece is now a strip: Select, then the Water, Harvest and Till tools (one bed at a time). The right piece is "All": Water all, Weed all, Harvest all, Pick pests and Collect, and it lists only the ones that have something to do (the others used to show greyed "none"); greyed "nothing to do" when none do. The "Collect all" label that was cut off is now "Collect". Checked in a headless 844 x 390 browser on a garden with nothing thirsty or ready (the left strip works, Select turns the Done piece on; the right strip showed nothing to do, so its tiles were not seen).

## 2.7.89
- **Hovel: all tabs checked** (Today, Furnish, Gnome, Closet, Stats, Calling, Foods, Villagers, Gardens at 844 x 390). Fixed: the Villagers tab (5639 px tall) is now a dense wall of small photos, many across (1398 px); the unmet "?" cards are short. The other tabs are as in 2.7.88; Calling (locked below level 5 in my test), Foods and Gardens were already short and are unchanged. Pals and Tea tabs are not on my test account (they fall back to Today); not checked.

## 2.7.88
- **Hovel (My Gnome) in two columns, dock layout, landscape** (`dock.css` only). Today: the room on the left, the tabs and the Needs you / news cards on the right (923 to 714 px tall at 844 x 390). Furnish: the room crop is gone; the slots on the left, the big room and the cosiness on the right (831 to 761 px). Stats: the back link and Puzzle box note are hidden, the stat description sits beside the list (1245 to 1027 px). Closet: the gnome on the left, the slots in two columns on the right (1021 to 748 px). The Gnome tab was already compact. Checked in screenshots at 844 x 390; Calling, the sleep and nap buttons (the Rest piece) and a hovel with a pet were not checked.

## 2.7.87
- **Fight start: the jigsaw cover is back** (Trail Wander fight with `pfight_stage` on). The cover pieces fly in over the map before the pre-fight card shows. My 2.7.83 rule that forced the stage pop-up always visible (my guess at the End turn flash) also showed the pre-fight card at once, over the pieces, so the cover never showed. That rule is removed. Seen in frame captures of a creature appearing during Wander: pieces cover the map, then the card fades in. The pieces cover the map's part of the screen (about two thirds), not the full width.

## 2.7.86
- **Puzzle fight, End turn flash: fixed (from the phone recording).** At End turn the fight script lays a frozen copy of the old screen (`.pfv-ghost`) over the new one, placed by inline left/top/width/height. The dock layout centres the live screen with `left: 50%` and `translateX(-50%)`, and the copy inherited that transform, so it slid half its width to the left for the turn's replay and the new screen showed beside it. The copy now has no transform in the dock layout (`dock.css`). No script was changed. Frame-by-frame captures at End turn (stage pop-up on and off) now show the same two columns throughout. Not checked on a phone.

## 2.7.85
- **Puzzle fight, End turn flash: found.** At End turn the game keeps the old fight screen as an id-less copy (`.pfight`, the "ghost" the turn is replayed over) while the new one loads. The dock layout's rules were written for `#pfight`, so the copy kept the old tall portrait layout (bars across the top, a small board in the middle, no hand) for the replay, then the two-column screen came back: that was the flash. The rules now apply to `.pfight` as well as `#pfight` (25 rules in `dock.css`), so the old copy is the same two-column screen. Frame-by-frame screenshots after the change show the same columns throughout the turn. (Everything in 2.7.79 to 2.7.84 about the flash was looking in the wrong place; the full screen button in 2.7.84 is still useful for the browser bar.)
- **History bar is back** in the right column (one scrolling line of what each side played). It was hidden to save height; the fight still fits at 844 x 390 (first-fight coaching tip shown).

## 2.7.84
- **Full screen in fights (the browser's top bar).** A web page cannot hide the address bar by itself, but it can ask for full screen on a tap. On a puzzle fight (and its pre-fight screen) the first tap enters full screen with the bar hidden, and the rail has a ⛶ button to enter or leave it by hand (it shows ✕ while in full screen). Leaving by the browser's own gesture, or with the button, stops the automatic entry for the rest of the page. It leaves full screen by itself when you are no longer in a fight. Where the browser has no full-screen support (iPhone Safari) the button is not shown. Tested in headless Chromium (a tap enters it, the button leaves it); not on a phone.
- **End turn flash, a better theory:** with the address bar showing and hiding, the visible height changes, and the fight screen resized with it. The stage pop-up was sized in `dvh`; it is now anchored to the top and the rail instead, so the bar cannot resize it, and full screen keeps the bar from moving at all.

## 2.7.83
- **Petal symbol:** the dock plate and its popover show the Petal icon instead of the gold coin emoji. The plate's health bar is red.
- **Fight stage (Trail Wander fight, `pfight_stage` on), dock layout:** the stage pop-up now uses the same two-column screen as the plain fight (the stage's own geometry cut your hand off at the right edge), and its content is never hidden or faded at a turn's swap (`dock.css`: `dialog.trailpop.pfst .pickbox` forced visible, no animation). This targets "the pop-up goes away and comes back at End turn". In my headless runs the pop-up was never closed or replaced during a turn (same dialog node, `open` and modal all the time), so I could not see it go away; the only visible changes were the board's pieces blank for about 55 ms and, in the stage, a stacked layout in the screencast that the DOM did not show. Not confirmed on a phone.

## 2.7.82
- **Dock status plate:** energy shows its numbers (x/y) beside its bar, and a health bar with its x/y sits just below it (red bar, from the same numbers as the popover's Health row; it follows the adventure's health during a walk). The time is shorter ("07:25 d0") so the coins fit. Seen in a headless capture.
- **End-of-fight card (win, loss, charmed) fits without scrolling** in the dock layout on a short landscape screen: picture left, title and words right, the detail lines small, the buttons always on screen. Seen after a real lost fight in a fake walk (the Puzzle box / Try again / Go home buttons are all visible); a win card with loot was not checked.
- **Wander, after a fight:** the small round thing under the heading was the end-of-fight stage (the chest and loot coming in, `#fightscene`) collapsed to a few dozen pixels by the new Wander grid. It now takes the picture's place at full size. Not seen with a real win here (my test fights were losses), so it is a best fix from the markup.

## 2.7.81
- **World and region maps full size in the dock layout.** The 2.7.65 rule that fitted the maps to the height above the dock is removed (the maps are tapped and zoomed, so small was wrong): both are the full page width again, about 796 x 446 (world) and 796 x 476 (region) at 844 x 390, and they match.
- **Puzzle fight, End turn flash (second attempt).** Frame-by-frame captures showed what you see: after each End turn the swapped-in fight screen sat for a moment in the old tall layout (bars, tip and a small board stacked) until its script had run and added its fitted class; headless about 55 ms, longer on a phone. The two-column layout and the fixed position now apply to `#pfight.pf-v1` from the first frame (`dock.css`), without touching the scripts (the 2.7.79 route broke the board). The screen now keeps its columns through the swap. Still happening in a headless sample: the board's pieces are blank for the same moment, and the coaching tip appears a moment later. Not confirmed on a phone.

## 2.7.80
- **Fixes 2.7.79, which broke the puzzle fight board.** 2.7.79 marked the swapped-in fight screen as fitted before its scripts ran, and on a pre-fight or turn swap the board never drew (no board, unstyled hand). That change is removed (`site.js` is back to its 2.7.78 content). Do not use 2.7.79. The End turn flash notes under 2.7.79 stand as findings only.
- **Pre-fight popover reaches its button.** The pre-fight screen was drawn under the dock (the full dock was on screen), so its Let's fight button could not be reached; since 2.7.78 it stops above the rail, and I checked that a finger drag scrolls it (large 5 x 5 creature, headless touch drag) and that Let's fight is on screen at the bottom.
- **Wander:** the heading and the status chip ("Tundra · 7 steps out ...") share one row.
- **Board sizes:** 3 x 3, 4 x 4 and 5 x 5 boards all fit the board column (about 370 x 316 at 844 x 390); the cells shrink with the grid. After four turns on a 5 x 5 board the pieces were still readable in a headless capture; not checked on a phone.

## 2.7.79
- **Puzzle fight, End turn flash.** I could not make a full page reload happen in a headless test (the turn posts and swaps in place), but sampling every frame showed what looks like it: at each swap the new fight screen was one frame un-fitted (height jumps, e.g. 356 to 367 px) and its board canvases were empty for about 60 ms. The un-fitted frame is fixed: `site.js` now marks the swapped-in `#pfight` / `#pfv-pre` as fitted when the old one was, so it keeps its place and does not scroll the page to the top. The empty board for a moment is not fixed (the board is redrawn by script after each swap). Not confirmed on a phone.
- **Not checked:** the old (non-v1) fight screen under the dock layout.

## 2.7.78
- **Puzzle fight on a phone on its side (dock layout).** The fight and the pre-fight screen used the whole height and ran under the dock, and in a short window the board got no height at all. Now a puzzle fight uses the thin rail instead of the full dock (Menu on the rail still opens it), stops above it, and is two columns: the board on the left; the bars, the coaching tip, the chips, a short last-plays line, the buttons and your hand on the right (the long last-plays list, the legend and the preview line are hidden in this layout). The pre-fight screen is wider (up to 820 px) and its Let's fight button is on screen. Checked in a headless 844 x 390 browser on a fake Wander, road, delve and lair fight (opening move, board and pre-fight). Not checked: the later turns and end-of-fight screens (win, loss recap, Pluck), a fight over the Trail's tile map, or a real phone.
- **Wander result card:** the result card ("An abandoned camp", "Call back ...") sits under the picture like the Latest line, not at the bottom right.
- **Message bell** sits above the rail during a fight.

## 2.7.77
- **Wander folds start closed in the dock layout.** The More and Gather folds were opened on any screen wider than 720 px, so a phone on its side saw the long notes under the picture. In the dock layout on a short landscape screen they now start closed (`site.js` `gvWanderFolds`); a fold you open stays open, and Gather still opens itself after a find.
- **Gather result card (landscape):** the "Into your satchel" card sits beside the picture instead of overlapping it; the spot cards are four across with a 92 px picture, and the list of what you can find is a multi-column grid under them (`dock.css`). Checked after a real gather in a fake walk in a headless 844 x 390 browser.

## 2.7.76
- **Dock layout, Gather here:** the picture is smaller (about 340 x 190 at 844 x 390, was 560 x 315) with your tool belt and the gather spots beside it instead of under it (page 1176 to 900 px). Checked with a fake off-the-path walk in a headless browser; a gather that has just paid out (the result card) was not checked.

## 2.7.75
- **Dock layout, Wander event or check:** the story text ("A beaver dam backs up a pond...") and its choices stay together in one box in the right column (the text used to land far below the choices). Checked with a fake off-the-path event in a headless 844 x 390 browser; the left column has no scene picture during an event, so it is empty there.

## 2.7.74
- **Dock layout, Wander:** what just happened (the "Latest:" result of the last step) sits under the picture, above the More fold. The right piece is now "Wander": Go deeper, Keep exploring, Step back, Gather (opens the page's Gather fold and scrolls to it) and To the road, each working the page's own control. Checked with a fake off-the-path walk in a headless 844 x 390 browser: the strip lists the five tiles, Gather opens the fold, To the road posts `do=return`.

## 2.7.73
- **Dock layout, landscape: the message bar is a bell.** The bar across the top (latest message, ▾) is hidden; a round bell sits at the far right of the dock, beside Together, with a red count when there is something you have not opened. It opens the message list as a popover above the dock that scrolls and closes on a tap outside, Esc or the ✕ (`dock.js` reads the page's own list, so links in messages still work and the list follows in-place page changes). Seen in a headless 844 x 390 browser; an in-place new message while the popover is open was not checked.

## 2.7.72
- **Dock layout, Wander:** the choices on the right no longer scroll (the panel is split into the grid: choices right, the notes ("Deeper is ...", "If you're knocked out ...") under the picture on the left, Gather along the bottom). Checked with a fake off-the-path walk at step 0 in a headless 844 x 390 browser: Go deeper and Head to the road show whole; the notes run under the dock edge and scroll with the page.

## 2.7.71
- **Dock layout, landscape: the Wander page is one screen.** The scene picture, the rings and the choices (Go deeper, Keep exploring, Step back, Head to the road) sit side by side, with a slimmer heading and status line; the long notes and Gather stay in their folds under the choices. (The flavour line above the choices is hidden in the dock layout.) At 844 x 390 the three parts end above the dock; before, the page was 2840 px tall. Checked with a fake off-the-path walk in a headless browser; a real Wander fight, find or Gather fold open was not checked.

## 2.7.70
- **Perks popover (Here), compact.** On short landscape screens the banner is slim (40 px), the stop perks and your account perks are small cards in a row (three across), and the meters with the acts that raise them sit under them, so the whole popover shows without scrolling (with three running perks it is about 380 px tall at 390). Replaces the 2.7.69 two-column version, which split the perk cards from the meters.
- **Activity cards (the picture's Do spots, a town's actions):** picture and name on the left, words and choices on the right on short landscape screens, so three choices fit without scrolling.
- **Popover crawl:** 70 pages were loaded at 844 x 390 and up to 8 popover triggers on each were clicked (102 clicks; 89 opened a popover or sheet), each measured for being inside the screen, having a usable scroll area and having its buttons on screen. One failed (the activity card above) and is fixed. Not covered: triggers past the first 8 per page, popups that need a live walk or fight, and popups that only appear after a game action.

## 2.7.69
- **Here: the Perks popover fits a landscape phone.** On short landscape screens it is wide (up to 780 px) with a slim banner and two columns (your perks left, the meters and the acts that raise them right). It was one column about 560 px tall; it now fits in the screen height (about 380 px at 390). Seen in a headless browser at 844 x 390.

## 2.7.68
- **Dock layout, landscape: page survey.** About 90 pages were loaded at 844 x 390 in a headless browser (heights, anything wider than the screen, oversized pictures, a screenshot each). No page scrolls sideways. One fix: on the My Gnome tabs other than Today and Furnish (Gnome, Closet, Stats, Calling) the hovel room banner is hidden, so each tab starts at its own content (about 100 px less scrolling). Still tall and unchanged: Villagers (122 cards), the Season page, World travel and map, the Almanac, the guide, the Passport, the garden tabs and the Crafting areas picture. Many mini-game pages sent the test player to Games (they are gated in the test world), so their own screens were not surveyed.

## 2.7.67
- **Dock layout, landscape: wide instead of tall** (`dock.css`; nothing changes without the dock or in portrait). Here: the villagers stand to the right of the picture as a condensed, tappable list (a 32 px sprite and the name, two across, scrolling inside if there are many). Villagers page: small cards (portrait left, words right, 4 across; 4352 to 2850 px tall in the test world). Place headers (towns, shops): picture and words side by side. Pages of narrow boxes (Account) go two across (2626 to 1779 px). Puzzle box: wide, kit on the left, belt and pals on the right (1888 to 1623 px). Tool belt: two cards across.
- **Still tall, not changed:** the world map tab, the Almanac, the guide, the Passport, My Gnome Stats, the garden bed grid and the shop lists. Page heights measured in a headless browser at 844 x 390 on the test world.

## 2.7.66
- **Dock layout, landscape: bigger pictures, hovel room centred.** The picture height allowance grew (about 12 px more for the Here, place and map pictures); the hovel room has its own, larger allowance, is centred in its banner, and the banner's greeting and Sleep / Nap column is hidden (they are the Rest piece). At 844 x 390 the room is about 400 x 227 (was 319 x 181).
- **More popovers checked** (short landscape, headless): the Puzzle box tabs (Codex, Belt, Pals, How it works) and an adventure on the road have no dialogs that fail. Still not covered: the trail's popups and a fight's own cards (they need a live walk).

## 2.7.65
- **Dock layout, landscape: pictures fit the screen.** The Here picture, the hovel room, the place pictures (towns, shops) and the world map are sized to the height left above the dock (`--imgh`, each keeps its own proportion and is centred), so they are seen whole instead of scrolled past. The Here page hides its crumbs and info line (the place name stays). The garden bed grid is left full size (smaller squares would be too small to tap). Seen in a headless browser at 844 x 390 and 1280 x 720.
- **Dock, Here page: the right piece is "Menu".** The row of round buttons under the picture (Routes, World, Perks, Fast travel, GPS, Wander) moved into the right piece as a strip; the row itself is hidden in the dock layout. Each tile opens its own popover.
- **Popover audit, short landscape screens.** Every dialog on 29 pages was opened in a headless browser at 844 x 390, 740 x 360 and 667 x 375 and measured (inside the screen, a scroll area of at least 130 px, not tiny): none failed after the 2.7.59 and 2.7.61 fixes. Added: Here popovers never grow past the screen. Not covered: popovers that only exist after a play action (an adventure's popups, trek camp, a fight's own cards) and non-dialog sheets other than the Puzzle box one.

## 2.7.64
- **Dock, Here page: "Do here" lists the other things.** It used to repeat the "Do" spots already on the picture. Now it lists up to three more doable things at the stop that the picture has no room for (chosen per visit, done ones left out; stalls are not included), and each opens its own card and runs in place. Greyed "nothing more" when the picture already shows them all. New `here_extra_do()` in `includes/here_view.php` (hidden cards, only when the dock is on); `dock.js` `hereDo`.

## 2.7.63
- **Puzzle box piece panel keeps the page in place.** Opening the side panel (2.7.61, short landscape screens) narrowed the page and the old "keep the piece above the sheet" scroll then jumped the page to the bottom. Now the tapped piece stays where it was on the screen (`pfv1box.js`: `sideSheet`, `anchorY`); stepping to the next or previous piece only scrolls if that piece is off screen. Checked in a headless 844 x 390 browser: scroll position and piece position unchanged after opening.

## 2.7.62
- **Dock, Here page:** the left piece "Do here" no longer links to the town list page. It opens a strip of the first three doable things on the stop's picture (its "Do" spots); each tile opens that spot's own card in place. Greyed "nothing to do" when the stop has none. (`dock.js`: remote `hereDo`, and a remote can now click an SVG link.)

## 2.7.61
- **Popovers on short landscape screens (a phone on its side).** The Puzzle box piece sheet (`.pfv-dsheet`, Pack it / Take out) was 45% of the height, which left about 70 px for the piece and its facts; it is now a panel on the right (about half the width, full height) so the piece, its facts and the button all show, and the page keeps scrolling beside it. The seed, soil and mulch choosers (`dialog.picker`) put the search, chips and "in season" on one row and have slim head and foot (this was dock-only in 2.7.59; now it applies everywhere). Other sheets (item sheets, codex, intro, plan) are 86 to 90% high and scroll, so they were left.
- **Dock layout, landscape:** the garden's own selected-squares panel is hidden (the dock's Pick and Then strips do the same); Wren's tour bubble sits top right so it no longer covers the strips.
- **Not checked:** a real phone; screenshots are a headless browser at 844 x 390.

## 2.7.60
- **Dock: garden page.** In the dock layout only (landscape, `nav_dock` on), the page's own "Select squares" button, the bulk buttons (Water all, Harvest all, Collect all, Pick pests, Weed all) and their energy note are hidden: the dock's Select piece and Tools strip do the same. Portrait and the old layout are unchanged. New classes `selopen`, `bulkf`, `bulkhelp` in `garden.php`.

## 2.7.59
- **Dock: garden pickers on landscape phones.** The seed (Plant…), Work in and Mulch popovers showed only a sliver of the list because the search, chips and "in season" rows took most of a 390 px screen. In dock mode on short landscape screens they now share one row and the head and foot are slim (`dock.css`). Seen in a headless capture at 844 x 390 only.

## 2.7.58
- **Nav dock (admin preview, off by default).** A landscape bottom dock (four jigsaw menu pieces, two page actions, a status plate, a play-mode rail) replaces the header, status strip, bottom bar and menu sheet in landscape. Setting `nav_dock`: `0` off (default, nothing changes), `admin` admins only, `1` everyone; admins can add `?dock=on` or `?dock=off`. Portrait keeps today's chrome. Design: `nav_dock_mockups.html`; plan and status per page: `claude/plan-nav-dock.md`. New: `includes/dock.php`, `assets/dock.js`, `assets/dock.css`, 72 icons in `assets/img/nav/` (source `art-nav-dock/`).
- **Page actions.** Left and right pieces work the page's own controls (the page's CSRF, confirms and in-place update apply): Garden (Select with Pick and Then strips; Tools Water, Harvest, Till on one bed; bulk buttons), Tasks, Shop (basket button, Buy | Sell), Crafting, Hovel and Gnome (Rest, Heal), Town, World, Trading, Market day, Community garden (Select mode), Pal jobs, Yard editor, mini-game rail.
- **Quick item.** New `quick.php`, `includes/quick_slot.php` and column `users.quick_item_id` (added on demand and by Upgrade database). Satchel: assign (pick an item, Confirm), use, clear (x, or hold). Adventure: use. Fights: a fight snack is eaten (old fight: the page's `snack`; puzzle fight: new `pf_quick`, free of the turn, counts against the snack limit).
- **Community garden.** `do=tend` also takes `acts[]` (verb:bed) for several beds; one job and one energy each, stops when tired or at the shift cap. Beds carry `data-bed`, `data-state`, `data-weedy`.
- **Tour** points at dock pieces too; the tour hint is written only when it changed (it caused a dock redraw loop).
- **Not checked:** a real phone, real MySQL, the dark theme with the real stylesheet, an old (non-puzzle) fight, Hovel rest buttons on a normal account. Checked on a fresh SQLite install (`tests/walk.sh`, headless Chromium at 844 x 390).

## 2.7.57
- **Puzzle combat is live for everyone.** One-time boot step `pfight_live_2757` (marker setting `pfight_live_2757`, only on a world upgraded from before 2.7.57) sets `pfight_open` = 1 and `pfight_v1` = 1 and makes the fight belts, the Tool Repair Kit and its recipe (`pfd_content_once`); an admin Off afterwards is kept on later upgrades. New installs: both default to on (`pfight_v1` gets an Everyone option in the settings). Fights already under way keep their own mode and rules (the state carries them). Treks still use the old fight. Other settings checked and left as they are: `pfight_mode` (unused by v1 fights), `pfight_stage` (Off: the Trail fight is the pop-up), `pfight_learner_n` 3, `pfight_staged` / `pfight_thorn_level`, `pfight_first_fixed` / `pfight_first_seed`, `pfight_guide_n`, `pfight_hint_n`, `pfight_costwarn_n`, `pfight_stall_turn`, `pfight_retry_n`, `pfight_blank` (unset = on), `pfight_jigsaw` (parts48 kit), `pfight_board_test` (unset). New test `tests/pf_golive.sh` (fresh install, a normal player, no puzzle setting written: road fight played to its end in a 390 px browser; the boot step on an upgraded world).
- **Puzzle combat intro.** A 4-step card (your Puzzle box; how a fight works; the Creature Codex; changing your deck) the first time a gnome opens the Puzzle box or starts a puzzle fight. Skip, Got it, Esc or a tap outside closes it and the page goes on; the seen flag is per player on the server (table `pf_intro`, made on first use). The same text is on a new **How it works** tab of the Puzzle box, and the fight's help sheet has a button that opens the card again in place. `includes/pfintro.php`, `assets/pfintro.js`, CSS `.pfi` in `assets/pfv1.css`; setting `pfight_intro` (default on) stops it opening by itself.
- **Creature Codex polish.** Seen pieces are drawn with the game's piece renderer (`PFParts.piece` from `pfparts47.js`, parts48 kit, the creature's own icons): number as on the pre-fight card, type, family colour, knobs and holes, name under it; unseen pieces are dashed blanks in deck order. `pf_codex` gets a `pd` column (compact JSON of type, value, tag, icon key and edges, kept at first sight; added to an existing table with ALTER on first use), so a region piece outside the standard deck draws too; rows from 2.7.55 / 2.7.56 get their look the next time the piece is seen. After a win the sheet also says what the creature does (its class rule or variant and abilities, the fight's own texts). The sheet has the creature's picture (its own, its family's or the drawn one), takes the focus, keeps Tab inside, Esc closes it, and closing goes back to the tile. Without script it is plain links and text cards (`assets/pfcodex.js` only adds the drawing). Fits 390 px with no sideways scroll.
- **Tests:** `tests/pfcodex.sh` / `pfcodex.php` / new `pfcodex.js` updated. Suites that cover the old fights or click the v1 board now set `pfight_open` / `pfight_v1` / `pfight_intro` explicitly (`pfight`, `pfboard`, `fight_scene`, `fight_scene_trail`, `pfstage`, `pfv1_costly`, `pfv1_guide`, `pfv1_charm`, `pbox_v1`, `pfanim`).
- **Player news** for 2.7.57.
- **Not checked:** a real browser or phone (headless Chromium only, 390 px); MySQL (the `ALTER TABLE pf_codex ADD COLUMN pd TEXT NULL` and `pf_intro` table); the light theme.

## 2.7.56
- **Weather piece effects (all 8 environment kinds).** Each environment piece now has its own place effect (about 0.6 s) and fire effect (about 1.2 s) on the piece-effects overlay, under the resolve animations and never delaying the replay. Sun: ray clusters, then turning rays, a glint sweeping to the chain piece and gold shimmer on it. Rain: drops and splash, then thick streaks through the 3x3 cells around it and a big pixel shield rising (guard ring on the chain piece). Wind: leans back, then one clear gust in its arrow's direction with a few leaves; a pushed piece leaves an afterimage trail and a dashed outline where it lands. Mud: heavy squash and splat; when a piece next to it fires, a pool spreads, big drips fall and that piece gets a dark ring with a bright tan rim (counts a quarter less). Bramble: shoots sprout, then prickly vines creep round its edge and prick the chain piece (gold for your chain, red when the creature fires it). Thornburst: thorns poke out, then a radial thorn burst with a red flash and red drops. Tremor: drops heavy with cracks, then crack lines run out, it shakes, and the other side's touching pieces shake, slip as an afterimage and puff dust. Spring: water wells up, then rising green and white ripples, sparkles, and a heal glow with plus signs. Light keeps only the place motion (environment pieces now wiggle like the others); Off shows nothing. Purely visual: no rule, engine or board change (`claude/pf-anim/motifs/weather_env.js`, engine hook `PFA.env` in `tools/pfanim_part.js`, rebuilt `assets/pfanim.js`).
- **Not checked:** not seen in a real browser or phone; headless captures only. The full CI list was not run; MySQL; light theme.

## 2.7.55
- **Creature Codex (Puzzle box, new Codex tab; v1 only).** A grid of all 319 creatures as picture tiles. A creature shows once you meet it in a fight; tap it for a sheet with the pieces of its you have seen played, where to look (landscapes, regions), and, after you beat or charm it once, its description, class, size and level. Table `pf_codex` (made on first use), written by `pfight_do` (`pfcx_note`), page code `includes/pfcodex.php`, styles at the end of `pfv1.css`. Sheets are plain links (no script). Only pieces the creature puts on the board are logged; pieces of a fight played before this build are not.
- **Piece animations (all 319 creatures).** New pieces rise from the table with a small wiggle and sound lines; a played chain gets an effect along its outer edge, drawn under the resolve animations and running during them (`assets/pfanim.js`, `pfanim-data.json`, built by `tools/build_pfanim.py`). Creature pieces use rougher, heavier themed motions; setting Piece effects Full / Light / Off in the fight help sheet (per device; reduced motion = Off unless chosen). On by default. 
- **Board sizes by creature size.** Small 3x3 (one environment piece at a time, a new one when it goes), medium 4x4 (two a round, max 3), large and boss 5x5 (two a round, max 5, new Tremor and Spring kinds), and a telegraphed AOE unique to each of the 11 bosses (`claude/proposal-board-sizes-2.7.55.md`).
- **Desktop layout:** after a puzzle fight ends, the Trail stays one centred column on wide screens (`.advgrid.pfres`).
- **No player news for this release (asked for).**
- **Not checked:** any of it in a real browser or on a phone (headless captures only); `pfanim.js` is 1.28 MB, load time on a slow phone untested; the full CI list was not run; MySQL; light theme. 239 medium / large / boss pieces use a best-guess animation family (lists in `claude/pf-anim/coverage-*.txt`). Tests that already failed before: `pfdeck_v1`, `pfboard_v1_abil`, `pfboard_tune_v1_metrics`, `pf_yield_text`, `pf_creatures_import.sh`, `pf_play_decks`, `pfv1_charm`, `pfv1_enemy`, `pf_boon_tag`, `pf_learner`, `pfparts48`.

## 2.7.54
- **Fight board: the creature's guard meter.** You have a blue guard bar under your head; the creature now has the same bar beside its Yield / charm bars, showing the guard it has built (`foe.block`: it soaks your Hurt pieces and clears when its next turn begins). Dimmed at 0, like yours. It is drawn by `pfight_foeguard_html` inside `pfight_bar_html`, so the board card and stage mode both get it, and it follows the replay step by step like health does: new `fgnow` on engine events (`game/includes/pfboard.php`, mirrored in `tools/pfengine.js`), `fg` on replay steps, rewind chips and `replay0`, `fguard` in the page data, `setFoeGuard` in `pfboard.js` and its fork `pfboardv1.js` (patched by hand: `tools/build_pfboardv1.py` was already out of sync). New test `tests/pf_foeguard_meter.php`.
- **Puzzle combat v1: small and medium creature fights are longer.** Chain-bot refit (`tests/pfboard_tune_v1.php`): the bar ease for small and medium is now a list of [level, factor] points (small `[[5,0.95],[12,0.85],[22,1.1]]`, medium `[[9,1.1],[14,0.97],[21,0.75],[26,1.0]]`), small `PFB_V1_BAR_MULT` 1.378 to 1.6, and `foe_x` refit in `data/pf_creature_tune.txt` for all 67 small, medium level 1 to 20 and the 5 large creatures at level 11 to 14 (PHP and `tools/pfengine.js` agree). Balanced profile, chain bot, level against level: small 2.04 to 4.42 turns (win 94% to 80%), medium level 1 to 15 2.49 to 7.12 turns (95% to 89%); the level 11 to 14 band four levels under 0.56 to 0.71. Four levels under, low-level wins drop (small 83% to 57%). Medium level 21+, large level 15+ and bosses are unchanged. Left out of range: lemming-kit-scurry, shore-earwig, jumping-spider, dune-snail, sandfly-cloud, carrion-beetle-crew, glow-grub-cluster, hermit-crab-hoarder, sea-otter-bandit (see `claude/playtest-fable-review.md`).
- **Not checked:** the guard meter and the longer fights in a browser or on a phone; MySQL, light theme. Tests that already failed (`pfdeck_v1`, `pfboard_v1_abil`, `pfboard_tune_v1_metrics`, `pf_yield_text`, `pf_creatures_import.sh`) fail the same.

## 2.7.52
- **Workshop popover on phones:** smaller squares, four to a row (icons 48px, smaller names and chips; `style.css`, `max-width: 720px`). Ready squares now fit their content, so there is no empty strip under the name (`.shqf` / `.shquick`). Desktop and the Satchel list page are unchanged.
- **Not checked:** only Garden at phone width; other areas, MySQL, light theme.

## 2.7.51
- **Workshop popover is a grid:** the area popover on the workshop picture has no folds any more. "Can craft now" shows full-colour item squares (tap one to make one; a x5 chip makes five when five fit; a small (i) opens the usual panel with ingredients, mastery and the Cook/Make buttons). Under a dashed line, "One trip away" and "Need more" squares are faded; tap one to see what is missing. "To discover" stays one closed fold. Pantry is untouched; the Satchel list page looks and works as before (`craft_shelves()` / `sh_shelves()` take a `$pop` option, set when `craft_in_popover` is on; `shqf`, `shquick`, `shx5`, `shinfo` styles at the end of `style.css`; `site.js` skips `data-nofold` shelves).
- **Craft links go to the workshop:** the Satchel's Crafting tab and the other craft links (ready-pot and jar badges, jobs, rebuild, gnome, garden, pal jobs, guide) use the new `craft_url($area)` (`includes/here_schema.php`): the workshop picture (`workshop.php?o=<area>`) when `gnav_craft` is open for the viewer, the old `inventory.php?tab=craft` page otherwise.
- **Not checked:** MySQL, light theme, the full test list. Cooking, Tools, Garden and Building were driven in headless Chromium at phone width (Tools and Building quick make was not clicked; faded squares seen in Cooking only).

## 2.7.47
- **Creature icons that only half loaded:** the icon loader (`P.cicoLoad` in `pfparts.js`/`pfparts47.js`) called back only the caller that first asked for an icon, so a piece drawn by a second `mount()` while the first icons were still arriving (the pre-fight card, mounted again when a sheet opens) could stay on the type glyph (Orb Spider showed 2 of its 4 unique icons). Every caller now redraws after each icon arrives (one shared redraw function on the boards).

## 2.7.46
- **Fight board (v1):** a creature piece placed and used up in the same turn no longer shows from the first frame of your resolution (its `fnew` mark was dropped from the gone list); health lands at the step that causes it: the poison tick that ends a fight carries its bar values, each environment step keeps its own bars (new `now` field, mirrored in `tools/pfengine.js`), the page draws a waiting replay with the pre-turn bars, and the site header health pill steps with the replay. Pieces used up in a chain keep their icon (no snap back to the type glyph), and the info window shows the creature icon.
- **Creature pre-fight card:** the creature's unique pieces show their own icons there too, and in the detail sheet.
- **Region maps:** Honeythorpe and Clovercove now appear on the Blossomreach region map (they sat on a road that starts in the Maplewold, so the layout skipped them); placed in free spots so the painted map does not move. The dead-end road ends at the near edge of Clovercove's region, side places beside it get trails, places of neighbouring regions no longer overlap, and the order of the map queries is fixed. "Fast travel to Blossomreach" is only offered when it makes the walk shorter. `tools/map_layout.lua` regenerated.

## 2.7.45
- **Every creature piece has its own hand-drawn icon on the fight board** (drawn on the jigsaw art by the canvas renderer, both the small and the big art sizes, as well as the plain fallback): 1,012 more icons (32px and 20px) join the first 264, so all 1,276 unique creature pieces of all 319 creatures show a drawing instead of the type emoji. Files are in `assets/img/pfight/pieces/` (`ico-<creature>-<piece>.png`, `-s.png`); `pfd_piece_icon_key()` still hides the key when a file is missing, so a lair guardian borrowing a boss's pieces keeps the emoji. Sources: `aseprite-source/pfight/piece-icons/mockup-opus/b34` to `b97` (grids, `make.py`, sheets), overview `aseprite-source/pfight/piece-icons/all_icons_2_7_45.png`. `tests/pf_piece_icons.php` now expects 2,552 files and 0 pieces without an icon. Known weak spots are in the batch reports (a few animals read like a similar one at 20px).
- **Map:** every place and road stop sits inside its own region (0 of 241 outside; Cloverholt, Honeythorpe and the rest were drawn along the road curve, so Cloverholt of The Maplewold sat beside Mistmoor). Crowded regions are spread out (at least 11 units apart).
- **Dead-end road name:** the road that stops at Clovercove is now "The Maplewold – Clovercove", not "The Maplewold – Blossomreach" (`name_dead_end_roads()` renames it once per world).

## 2.7.44
- **Harvest show:** a popover after the Harvest buttons (and on waking when a garden pal picked overnight): up to 8 plants are pulled up in a row and fly into a basket, then crops, XP, saved seeds, bonus lines and garden status chips show. A level-up is a small gold "LEVEL UP!" pop (the harvest.js filter now also matches the line after the site's emoji-to-icon swap). Pixel art (`assets/img/harvest-*.png`) when all 12 exist, else emoji and CSS shapes. New: `includes/harvest_show.php`, `assets/harvest.js`, `assets/gardenstat.js`, `docs/harvest-art-spec.md`; small hooks in `garden_logic.php`, `garden.php`, `events.php`, `layout.php`, `style.css`.
- **Harvest level-up is the small pop only:** a level-up that comes from a harvest no longer also plays 2.7.43's big level-up card (`hv_note_info()` clears the `lvlup` session flag).
- **Pal pictures:** `assets/img/pals/perch/` now has 570 plain 36px creature sprites (142 old ones kept; 356 from `aseprite-source/v3/perch/perch_gen.lua`, 72 whimsy downscaled with `whimsy_downscale.py`). `assets/img/pals/<key>.png` (64px, all 570) is the creature cut into its own jigsaw piece (`piece_cut.py`); plain originals are in `aseprite-source/v3/pals-creature/` (regenerate from there, never from `pals/`). Pals travelling with the player (gnome avatar, fights, trail, delve) show the perch picture via `ppal_travel_url()` (perch, else sticker); stickers in `assets/img/puzzles/pals/` still serve the Pal Book, markers and spawns. Skipped on purpose: 5 weak whimsy perches (pl-dlz-6, pl-wgor-6, mt-bill-brolly, pl-wcof-6, pl-flfm-6). Generated pals (uploaded pictures) still have no art.
- **Creature piece icons on the fight board:** the 264 hand-drawn piece icons (`aseprite-source/pfight/piece-icons/mockup-opus/`) are in `assets/img/pfight/pieces/` (32px and 20px). A creature's own 3 pieces carry `ik` (`pfd_piece_icon_key()` in `pfdeck.php`, empty when no icon exists); `pfboard.php` passes it in the piece lists, `pfight_game.php` adds `pico` to `pf-data`, `pfboard.js` and `pfboardv1.js` swap the type emoji for the icon once it loads, `tools/pfengine.js` mirrors `ik` so PHP and JS views match. Creatures without icons (newer ones, variants, lair guardians) keep the type emoji. New test `tests/pf_piece_icons.php`.
- **Cat Fish:** the tap counter mirrors the server's tap bucket (cap 15, +1 per 2 s) and flushes taps 2 to 10 s after a tap, so Kibble matches after a reload. Toy-Shop Shelf restyle (no banner, a hidden `<h1 class="cfsr">`, stage and Kibble counter in a pinned `.cfdock`, cream upgrade tiles, drawer-style More hub) with dark mode. `tests/catfish.sh` banner and card assertions follow the new layout.
- **Known:** `tests/pf_play_decks.sh` check "(a) Reptile creature holds a Bite or Venom Spit piece" already failed before this release. The Cat Fish pinned dock takes about 250 px of a phone screen and was not judged on a real device. Nothing here was run against MySQL.

## 2.7.43
- **Level-up lettering, garden style:** the level-up card now spells "LEVEL UP!" in bold pixel letters (new `includes/levelup.php`, drawn as SVG rects, no font file, strict CSP safe). The green letters sprout one after another, little seedlings and a growing vine appear on the word, then the new level pops in gold with a pink flower blooming each side. Sparks are now petals in pink, gold and leaf green. Reduced motion shows the finished card without the growth. Still pure CSS, plays once and never blocks taps.

## 2.7.42
- **Level-up animation:** when the gnome levels up, the next page shows a short burst: a "Level up!" card with the new level popping in and 12 sparks flying out, gone after about 4 seconds. Pure CSS (`.lvlup` in `style.css`), never blocks taps, and with reduced motion it is a plain card that fades. `add_xp()` leaves the new level in `$_SESSION['lvlup']`; `layout.php` plays it once (also when the message log replaces flashes). Fights still pop their own "LEVEL UP!".

## 2.7.41
- **Starter kit pieces raised:** Jab, Pierce and Brace 3 to 6; Garden Greens (vegetable crop piece) 3 to 5; Soothe 2 to 4 (shows 5 with the Charm bonus). Changed in `data/pf_pieces.txt`, `PF_TILES_BUILTIN` (the lint needs them equal) and `tools/pfengine.js`. `tests/pfdeck_v1.php`: the recorded old-fight transcript is re-recorded again.

## 2.7.40
- **Player base combat pieces +2:** Swing (Hurt 4 to 6), Dodge (Guard 4 to 6), Rest (Heal 3 to 5), Charm (4 to 6) and Hide (Trick 3 to 5). Snack and Breather are unchanged. Changed in `data/pf_pieces.txt`, the built-in fallback `PF_TILES_BUILTIN` (the lint needs them equal) and `tools/pfengine.js`. `tests/pfdeck_v1.php`: the recorded old-fight transcript is re-recorded.

## 2.7.39
- **Jobs page redesign (focus + detail):** one period at a time. The switcher shows Daily, Weekly, Monthly and the Community board, each with its state (dot plus words) and a countdown. The chosen period shows one large job card (title, progress, reward chips, the 4-step stepper for rebuild jobs) with a card beside it for what to hand in (rebuild needs with "Short by", deliver, or the tending link). Give up sits in a fold. With no job taken, the offers are a list where one opens at a time (hint, reward, Take this job); re-roll and the other gnomes' posts sit beside it. **Post a job** is now the Community board (`?p=post`): open jobs from other gnomes (Take disabled when your slot is full), two compact post forms, and Your posted jobs with Take down. All actions and forms are unchanged. CSS is scoped to `.jb` in `style.css` and adapts to the column width. `tests/jobs.sh` now looks for the new nav class.

## 2.7.38
- **Thornblade Journeyman quest (`thornblade-2`, Thorn Master):** "Weed 40 squares in your own beds" is replaced by "Craft Wattle Fences 6 times". Thornblade tiers slow weeds (tier 2 half speed) and a hedge slows them again, so the weeding task could be impossible to finish. The Captain's intro now says "fence your own beds well". Data file only (`includes/data/calling_quests.txt`); sites that already imported the chapter keep the old task until it is edited in Admin.

## 2.7.37
- **Yard cards scroll on phones:** the card is at most the screen height (`100dvh - 24px`); the header stays put and the body scrolls (`overscroll-behavior:contain`). The fence card (long visitor lists) was cut off with no way to scroll. The fence card is also tighter: shorter intro line, smaller text and gaps. CSS only (`tools/build_gyard_assets.py`, regenerated `gyard.css`) plus one text change in `gyard.php`.

## 2.7.36
- **Yard replaces the Buildings tab (flag `gnav_garden` on):** there is no separate Yard tab any more. The Buildings tab itself shows the Yard picture. The old building list is still there: the picture's "List version" button (`garden.php?t=bld&list=1`), the card's "More" button and every `?bld=<building>` link open it. Flag OFF: nothing changes (Buildings is the list). `tests/gyard.sh` updated (33 checks).
- 2.7.35 was only the release news post; folded in here for anyone who skipped it.

## 2.7.35
- **Release news:** `UPDATE_NEWS` had no entry after 2.7.31, so 2.7.32 to 2.7.34 never posted to players. Added the 2.7.35 player post (Trail transaction fix from 2.7.32, and a no-spoiler line about the hidden Yard groundwork; the Yard itself stays OFF behind `gnav_garden`, so it is not announced). The post is created once, the first time 2.7.35 loads, for sites on 2.7.31 or later.
- No other code change.

## 2.7.34
- **Garden Yard picture (new, setting `gnav_garden`, default OFF; admins can always preview; needs `gnav_on`):** a **Yard** tab on the garden page shows the whole garden as one picture. Every building is its own sprite on it: an empty plot with its own small BUILD sign for what is not built yet (greyed with a lock when the garden level is too low), level 1, 2 and 3 art for what is, and a looping animation with a gold "!" in the corner when it has something to collect (the same loop exists for every level). The Buildings tab is unchanged and is the "List version"; "More" on a card goes to that building there. (2.7.33 was built on the branch but never merged or released; its notes are folded into this entry.)
- **Cards:** a tap on a building (or a "ready" chip) opens a centred card with the building's own art cropped into a fixed square, its name and chips (level pips, "Level 3 · max", Ready), a short "Now" line, one info strip (what is waiting, or what the next level adds and any materials it needs) and one row of buttons. Every non-animal card is the same size. Build, Upgrade and Collect work from the card and return to the Yard with the card open. Animal homes get a resident row (one tile per home: the animal with its mood, or an open "+" home), Feed, Hatch (frog pond), Upgrade and a compact Welcome form with the name field; the fence shows the neighbour visitors. Without script the card still opens (`garden.php?t=pic&o=<building>`).
- **Taps:** each tap area covers the lower 70% of the sprite (tall chimneys and crowns do not catch taps) and grows evenly on all sides for a comfortable target; nearer rows sit on top of farther ones. Checked live: every tap centre opens its own building.
- **How it is built:** `includes/gyard.php` (picture, sprite state, cards), `assets/gardenyard.js` (opens the cards), `assets/gyard.css` (GENERATED by `tools/build_gyard_assets.py`: every position, sprite and card art tile is a class, no inline styles, CSP stays strict), `assets/img/gyard/` (115 PNGs, about 490 KB: the patchwork ground, then per building the empty strip, level 1 to 3 stills and level 1 to 3 ready strips; the fence has idle and ready). Spots follow the Buildings tab filter, so animals-off and Tailor-off gardens show no plot for them. Garden action posts from the Yard carry `t=pic` and `garden.php` routes the redirect back to it.
- **Art (Aseprite, Hearth Pop v3):** source scripts and outputs are in `aseprite-source/v3/states2/` (per building) and `aseprite-source/v3/scenes/` (`garden-ground.lua` and `garden-ground.png`; `garden-patch2` to `garden-patch6.lua` are the full scene with buildings baked in, kept for reference).
- **Known:** the level 3 art is wider than the gaps between spots in the 17-spot layout, so neighbours overlap a little and two "!" badges can touch when many buildings are ready. Plan: spread the layout or shrink level 3 in a later release. The flag stays OFF until that is settled.
- **Tests:** `tests/gyard.sh` (flag off and on, tab, build / upgrade / collect and animal-home Welcome return to the Yard, ready animation on and off, card art tile and header, the card opens without script, Buildings tab and `?bld=` links unchanged, every class and image the page uses exists, no inline styles).

## 2.7.32
- **Fix:** `adventure.php` (and the region pick in `world.php`) no longer throw "There is no active transaction" when something inside the request ends the transaction early (MySQL commits on CREATE / ALTER); the closing commit is now guarded like the rollback. Seen in the live error log on a POST to `adventure.php`; the action that triggered it is not known.

## 2.7.31
- **Trail Sights, fifth and sixth pass:** an item can stand in for a failed check (`nimble:9+item:plank`); 14 villager ask rows have a check with a miss line; `take=` / `give=` / `hv=` accept `any-seed`, `any-bread`, `any-tea` and other word lists (`data/trail_sight_words.txt`); shop discounts can be scoped to a category or one item (`disc=shop:20:60:seed`, `disc=shop:50:120:rope`); Sight kinds + `nextkind=`; a season limit on a quest line; `choose=` on villager rows (Ulric at the haven sleeper); `fpall` cap 10 (picnic quest pays 10). Rope is stocked at Twigg's (boot step `rope_stock_ensure`).
- **Sight items with uses:** fern-drip-hat-charm keeps the rain off, map-scrap pins a find (shows in fog), star-chart files an Almanac page per season, stargazers-chalk, message-bottle; maple-syrup and flour swaps (`hv=<item>:N`). Engine `trail_sights_5.php`.
- **Shared Sights (setting `sights_shared_on`, default OFF; `sights_shared_text` on):** shared cairn count, anonymous bottle notes between players, chalk marks; reports, per-day limits, Admin page `admin/sights_shared.php`; code `trail_sights_6.php`, endpoint `sights_shared.php`, three new tables from `schema.php`.
- **Tea crops:** lemon balm, peppermint, lemon verbena, garden sage, tulsi, star anise (crops, seeds, Almanac, tea ingredients: 46); boot step `tea_crops_ensure` adds them to existing worlds. Placeholder art.
- **Puzzle combat:** 7 creatures refit (aphid-swarm, garden-snail, barn-rat, storm-eagle, hermit-crab-hoarder, bog-pike, desert-camel); new fight rule `firex` (boss pieces and creature Guard / Hold fire 3 times; new fights only); `oc-red-dust-poncho` trigger now full health; `pf_bots` seed step fixed.
- **Pal Jobs page:** shows game time with the sleep-days clock on.
- **Tests:** `trail_sights_283`, `trail_sights_284`, `trail_sights_shared`, `sights_items`, `herb_crops`; `pfstage` layout cases; `delvemap.sh` port and server guards.

## 2.7.30
- **Delves:** the delve column (picture, floor map, chips) is centred on wide screens, with the empty encounter panel hidden (`.advgrid.dv2`, also on the delve end page and old-style delves); the puzzle-fight stage popover now sits over the 480 px column with no sideways scroll (`.advgrid.dv2.fighting.pfover`). Trail and wander pages unchanged.

## 2.7.29
- **Puzzle combat stage (`pfight_stage`):** a wander started from the world / Here page (no Trail map) now puts its fight in the stage popover, so the jigsaw entry, Let's fight and End match covers play like Trail fights (`adventure.php` `$trailPop`, `pfstage.js` `curBox()` falls back to the visible window); a wander's Run result card shows inside the dialog; `pfstSeen` is cleared at load when no dialog is on the page. New wander cases in `tests/pfstage.js`.
- `tests/eggs110.sh`: 15 egg recipes (Maple Flapjacks), meal:10.

## 2.7.28
- **Trail Sights items:** boot step `sight_item_effects_2719` fills empty decor `effects` on existing worlds (Admin edits kept); Glowcap Repair Kit mends a worn lantern free (`mend_tool`); recipes windmill-loaf, maple-flapjacks, toffee-apple, maple-sap-tea (no pictures yet); `import_recipes` ensures Sight items first.
- **Art:** ginseng, ginseng-seed, stone-wall-end, stuffed-peppers-goat redrawn (tomato kept).
- **Puzzle combat stage (`pfight_stage`):** `pfstage.js` `curBox()` also finds the map in `.wanderbehind`, so the jigsaw cover plays on a fight off the Trail (it was a sliver on desktop and skipped on a phone).
- Docs: balance sim report `claude/balance-2.7.27-sims.md`; todo lists audited.

## 2.7.27
- **Hollow jar:** weekly jar 4 times the size (`HOLLOW_GOAL_SCALE`, from the next week's jar; festival jars unchanged). Tier items 10 Plain Compost / 20 Plain Compost / 30 Worm Castings / 40 Rich Loam (were none / 3 / 2 / 2). Petals and XP unchanged.
- **Hovel room:** z's only at dusk and night; the bed's pulse and a "Tap things in the room" hint show once a game day; the bed's and the window's cards open next to their thing.
- **Pal cooking:** with the sleep-days clock on, pal pots run on the pal work clock and a pot a pal lets go of cooks on the gnome's clock; Kitchen texts say game time. Clock off: unchanged.
- **Wearables:** Closet picker is an in-page dialog (link path kept without script); Flax Wading Wraps trigger is now "the creature has guard up"; Closet help text says a worn item offers its piece; demo and sims feed `worn`.
- **Tea (still hidden, `tea_open`):** 9 more ingredients (40); 8 new forage items with placeholder pictures (nettle, raspberry leaf, spruce tips, elderflower, rose hips, linden blossom, dandelion root, licorice root); the `*-tea` globs in `craft_scenes.php` are explicit slug lists.
- **Trail Sights, fourth pass** (`trail_sights_4.php`): `nxt=fog`, `nxt=lit`, `sec=<route>.<stretch>:<effect>`, `lose:` penalties, `stat:dc?cond:dc2`; setting `trail_fog_weather` (default off); `nxt=skip` is refused while a fight waits; data rows use the new tokens; three rest Sights cost game time.
- **Puzzle combat (behind `pfight_v1`):** five weak creature decks refit (house-centipede-skitter, midge-cloud, bullfrog, hermit-crab-convoy, shore-earwig).
- **Creature drops:** four regional drops moved into their creature's region window (boot step `creature_window_drops_1119` for live worlds).
- **Road:** `chain-beat-tune-3` has a second option (the lint wanted two).
- Player news: yes (`UPDATE_NEWS['2.7.27']`). DB: boot step only, no manual step.
## 2.7.26
- **Puzzle combat stage mode (`pfight_stage`, still Off by default), wide screens only:** the combat stays in line with the map's column (it was centred on the whole window and covered the side menu). It still gets the visible height and at least 480 px of width. Phones unchanged.
- No player news (setting is Off). No DB step.
## 2.7.25
- **Puzzle combat stage mode (`pfight_stage`, still Off by default): the play board was cut off on phones.** The combat took the map's height plus extra, so on a short phone screen the board and the hand fell below the fold. It now gets the visible window like the game's own fight panel (the whole window on a phone, between the header and the bottom bar on a wide screen), fixed to it, and the pieces cover that same area. The pre-fight card and the result card still sit on the map.
- No player news (setting is Off). No DB step.
## 2.7.24
- **Puzzle combat stage mode (`pfight_stage`, still Off by default) fixes:** a fight that is already on the page when it loads no longer shows its card while the pieces are still coming in; the fight follows the map when the page moves; the pieces wait for a Trail walk to end and for the pop-up to open; the card's buttons are scrolled into view and focused. Script and stylesheet get a new version number so a phone that kept the 2.7.23 copies fetches these.
- No player news (setting is Off). No DB step.
## 2.7.23
- **Puzzle combat on the Trail can take over the map's place (setting `pfight_stage`, Off by default):** the fight sits on the tile map's box with no dimming. Jigsaw pieces fly in over the map first, the pre-fight card (creature and deck) shows on top of them and they stay until Let's fight, then new pieces cover the card and leave to show the combat. A fight that was run from shows its result card over the map instead of above it. End match covers the swap with the pieces. With the setting Off nothing of it loads.
- **Sugar-shack ledger starts collapsed again:** the Trail family panel collapse skipped any panel containing a `<details>`, so the ledger (which holds the quilt fold) showed fully open. It now only skips a panel that is its own pill. Test `trail_fam_collapse` covers it.
- No player news. No DB step.
## 2.7.22
- **Tea recipes show what they need (tea is still hidden behind `tea_open`):** every row in the Recipes tab has a "Needs ..." line with the ingredients by name, the ones you lack marked. Teas not found yet stay "???" but now list their ingredients too, with the hint. Ingredient tiles in the Leaves and Extras tabs are four to a row.
- No player news (tea is hidden). No DB step.
## 2.7.21
- **Tea popover redesigned (B2 "Cup and drawer"; tea is still hidden behind `tea_open`):** the cup is on top as four slots (the base slot bigger), with the live result and the Brew button beside it; a drawer below has Recipes, Leaves and Extras tabs (tap or swipe), ingredient tiles four to a row, one-tap Fill on a named tea you can make, "Need 1 X" for ones you cannot, a hint for teas not found yet, a stamp row for the journal that opens a list with the kettle progress, and the second-brew replace sheet. Works without script as before.
- **Same ingredients, same cup:** when two stats tie for the side stat the one earlier in Charm, Lore, Sense, Nimble, Grit, Hardiness, Luck wins (PHP `tea_cup` and JS `gvTeaCup`). Masala Chai and Milk Chai now give Charm +1 as their side stat.
- Test `tea_page` waits for the cup line after the pour-out reload.
- No player news (tea is hidden). No DB step.
## 2.7.20
- **Hovel room art:** a bigger home gnome (48x72, hat and beard still take your colours), night versions of the three windows (shown at dusk and night), real steam and z sprites, and Copper, Cast-Iron and Silver Samovar kettle overlays (shown for the tea kettle, when tea is open). Small kettle and cup icons in the tea popover. 18 new pictures (`game/assets/img/sprite`, `scenes`, `fx`, `ico`), also in `upload-zips/gnome-venture-images-v3-2.7.20.zip`. Every picture falls back to the old drawing when missing. Suite `hovel_art_2720`; generator `aseprite-source/extras-pixel/scripts/hovel-room-2720.py`.
- **Fresh start** now classifies all 33 older users columns it never covered (kept: theme, start page, session, guest, email and verify state; reset: the rest), and resets only columns that exist on the database. `reset` test fixed (welcome page check).
- **MySQL installer:** `mentors120_upgrade()` no longer runs CREATE TABLE / INDEX when the tables exist (on MySQL that silently committed the installer's transaction and the install failed with "There is no active transaction").
## 2.7.19
- **Interactive hovel (Today tab):** the full room picture replaces the cropped banner, and things in it are tappable: the bed (card with Go to sleep, Nap, the inn and other beds, with prices and reasons), the door (out to Here), the kettle (tea, when open), the window (today's and tomorrow's weather, link to Seasons), the lamp (light on or off, lit by itself at dusk) and the gnome (hops and says a mood line). Things are data in `data/hovel_things.php`; each has a plain link without script. Small steam, z's and gnome bob, off with reduced motion. A one-line greeting and a small row of Sleep, Nap, Inn and Other beds buttons replace the big buttons on Today only. Furnish, Gnome and Closet are unchanged. New `hovelroom.js`, suite `hovel_room`.
## 2.7.18
- **Needs you as tiles (Today tab):** things you collect (crops ripe, pots done, jars ready, pal trips ready) are small tiles three across with a gold edge; empty beds are merged into one row ("5 beds empty", with the reasons); the daily job, "say hello" and the rest are wide cards under them. Tired pals no longer clutter this list.
- **Your pals pills:** each garden pal chip shows its working percent as a pill: green 70%+, yellow 50-69%, red 5-49%, black under 5% with a red "!". A finished job shows "done". Fixes a clash that turned the banner's date label orange (`.hs-tag`).
- **Tea kettle (hidden, admins only):** the Hovel kettle opens a brew popover: a base leaf (counts double) plus up to three extras, a day-long buff in its own slot (`users.tea`, `tea_day`, `tea_name`), kettle tiers (Dented Tin, Copper 150 Petals, Cast-Iron at 8 named teas, Silver Samovar at 16), a Tea Journal with 20 named teas. Setting `tea_open` (off / admin / everyone, default admin), caps `tea_cap_main` 3 and `tea_cap_side` 2. New table `user_tea_journal`, new columns `users.tea`, `tea_day`, `tea_name`, `kettle` (added by themselves on first load). Data: `data/teas.txt`, `data/tea_ingredients.txt`. Suite `tea` added to CI. Audit and plan: `claude/tea-audit.md`.
- No DB step.
## 2.7.17
- **Your pals box on the Today tab:** every pal job in one place, in three groups: the garden crew (one summary of last night, then a chip per pal, two to a row, with "tired · 50%" or "job done"), pals at a station (Kitchen, Pantry and others: made so far, time left or full time) and pals out on a trip or delve (back in, with a progress bar). It replaces the one-line "Overnight the crew" paragraph.
- **Daily "say hello" card** opens the Here page when graphical navigation is on (it opened the old town page).
- Tests fixed: `pf_piece_text` (Pal and Boon texts shortened), `trail_bendy` (two mini-boss levels follow the 2.7.08 creature levels), `market100`, `npc25_wire`, `pbox_v1`, `catfish`.
## 2.7.16
- **Closet tab** in the slim Hovel (after Gnome; `gnome.php?tab=closet`): the gnome in its worn items walks and turns (four stacked sprite strips faded in turn with CSS, no script), seven slot pills, and the open slot's picker under its pill row (plain links + POST forms, works without script). The Wearing panel leaves the Gnome tab when the Closet tab is there (non-slim My Gnome keeps it). Gold badge = empty spots you own something for. Wear/Take off from the Closet return to the Closet; the Puzzle box strip links to it. Player news added.

## 2.7.15
- **Wearables are live for every player** (admin setting `wear_open`, default On; Off hides outfitters, wearables and equip again). No longer tied to `pfight_v1`; Puzzle box and its pieces still are.
- **Equip on My Gnome:** a Wearing panel with 7 slots (footwear, backpack, coat, cloak, hat, hands, neck), one item each, new table `user_wear_slots`. A wearable's puzzle piece is offered only while it is worn; Keepsake slots in the Puzzle box are unchanged (1/2/3/4). Equip refused in a fight, for unowned items, or if it would break the deck (4th Rare). Boot step `wear_slots_2714` turns existing switched-on pieces into worn items. Puzzle box shows a read-only Wearing strip.
- **Avatar shows worn items:** 280 art sets (front/back/side) in `game/assets/img/gnome25/wear/<slug>/`; sprite URL carries `x=slug.slug`; `GNOME25_ART_REV` 2714a. Player news added (`update_news.php`).

## 2.7.14
- **Wearable piece pictures** now show the piece's name in the name ribbon (small pixel capitals). 103 of the 280 piece names were too long for it and are shortened (for example "Saddle-Bag Rummage" is now "Saddle Dig"); values, effects and prices are unchanged. The 280 pictures in `game/assets/img/wearpiece/` are regenerated and the stored item descriptions ("Piece: name") are refreshed by the `wearables_2700` boot step. Hidden with the wearables (`pfight_v1`). No player news.

## 2.7.13
- **Wearable rarity:** the 840 regional wearable items now carry their design's rarity (Common 10, Uncommon 25, Rare 50, +10 Lined, +20 Fine) instead of one value from the rank, so shelves and the satchel show Uncommon and Rare. Items already created are corrected by the `wearables_2700` boot step (a rarity changed in the Admin is left alone). Hidden with the wearables (`pfight_v1`). No player news.

## 2.7.12
- **Shop item sheet:** the "About it" fold is now always there and always open for every shop item (it used to appear only for long descriptions). A wearable's puzzle piece picture sits inside it at 1x (132x92, much smaller than in 2.7.11). No player news.

## 2.7.11
- **Shop sheet shows the puzzle piece** a wearable gives (132x92 picture at 2x, with the item's art on it, its number and rarity mark). 280 pictures in `game/assets/img/wearpiece/<item slug>.png` (made by `claude/wear-pieces/render2.py`). Hidden with the rest of the wearables (`pfight_v1`). No player news.

## 2.7.10
- **Regional outfitters** (hidden behind `pfight_v1`, like the wearables): one shop per region at its market place, three shifts of staff, selling that region's 20 wearables at Common rank for the Tailor's Petal fee x 1.25 (no Tailor, materials or energy needed; Lined and Fine still come from the Tailor). Stock: Common 3, Uncommon 2, Rare 1 on the shelf. A gnome needs the level of the item's region. Shops and stock are created by the existing `wearables_2700` boot step (`wear_ensure_shops` in `wearables.php`); the shop and its items stay out of sight for normal gnomes while `pfight_v1` is Admins only.
- No player news this version.

## 2.7.09
- **Pals work at 06:00.** All pal work (trips, delves, garden stays, pots, the Pantry) is credited once per game morning at 06:00, a whole day ahead, counted from the game clock. Sleeping at 05:59 gives exactly one morning, staying up past 06:00 gives it without a sleep, and sleeping after it does not give it twice. New column `users.pal_morning`.
- **Pantry pal** collects ready jars and refills free ones every morning it missed (up to 40), not only on the Jobs page; it also checks when you open the Pantry, the craft map or the Kitchen card.
- **Here page:** the popover of a wonder, haven, delve or lair is now the same panel as on the World page (picture, intro, mood, ways in with their chances); its buttons return to the Here page.
- **Fights:** the piece info card scrolls on a phone (the text used to cut itself off).
- **Trail:** landmarks draw over the trees next to them (wall-trees overdraw).
- **84 new rest-stop pictures** (7 landscapes x 12 stop types), five new villager species (squirrel, scarecrow, hermit crab, crab, beaver), Keeper Marram, back and side Flood Boots, new Sights landmark pictures.
- **Hidden behind `pfight_v1` (Admins only):** 280 regional wearables (item art, Tailor crafting with a Petal fee, one Keepsake piece each with its own unique effect; engine, JS mirror and tests in `tests/pf_wear_fx.php`; balance notes in `claude/wear-pieces/balance.md`). New data files `wear_items.txt`, `wear_items_pieces.txt`, `wear_fx.txt`.
- **Database:** `users.pal_morning` is added on first load of this version (safe to run twice); the 840 wearable items are created on the upgrade step `wearables_2700`.

## 2.7.08
- **Trail Sights pay better.** A Sight now pays about one Gather's worth per energy (it was about a third). New admin setting `sights_reward_pct` (default 125; rest stops are not touched). 100 thin Sights gained a small Petal reward, 8 rich free Sights now cost 1 energy, and a few over-rich ones (berry patch, bramble, scarecrow, sugar shack) were trimmed.
- **At most 6 Sights on one walk** (admin setting `sights_walk_cap`, 0 = off).
- **New Sights features:** a second lucky moment at once (`buff2=`); hints about a lair's nights and a delve's first rooms; effects on the next stretch of the walk; villager **birthdays**; **letters** from villagers; **bottle post** on coast and island walks; the **Village Green** and **Notice Board** start quest lines (Wren's Woodland Census now starts from the Notice Board); seeds that grow in the garden (Lantern Fruit, Tiny Thank-You); keepsakes that help a tool find a little more. Details: `claude/sights/GRAMMAR.md`.
- **Trail:** side trails leave a stop leaning along the road; the toast box no longer covers a fight's end scene; the 9 thinnest Sights got lines per destination, streaks, titles or bonuses.
- **Region maps repainted** from the new layout (all 14; some roads and places moved). Needs an art look: CSA market village, CA trails.
- **Fights (behind `pfight_v1`, Admins only):** Charm counts 0.8 (was 0.6) on hostile creatures and a Charm win pays +25% XP and Petals; Wind and Mud are back in the environment from the start; creatures no longer put out a free piece in old-rules fights; Soothe text rewritten; pal pieces knock off the creature's strongest piece they can (new fights); six counter knacks (Pest Ring, Scarecrow Flap, Honey Pot, Sandbag, Billhook, Antivenom) count +2 against their own class; six tier III second calling pieces; 22 legendary pieces flattened; the board shows rounds left on each piece; the guard readout says how much its guard blocked.
- **Creatures:** all 319 re-fitted to the win-rate targets; 76 shared ability strings made distinct; 8 base creatures moved into a region window (boot step `creature_windows_2708`: mischief-monkey, leafcutter-column, arctic-fox, desert-tortoise, reef-turtle, glacier-bear, lichen-reindeer, snow-owl-monarch).
- **Hidden until `pfight_v1` is on for everyone:** the fight belts on Twigg's shelf and the Tool Repair Kit recipe show only to admins.
- **Database:** five new `users.ev2_*` columns, added on first load of this version (safe to run twice).
- **Tests:** `trail_sights_278`, `_279`, `_280`, `_281`, `region_trails_gates`, `toast_cover`, `creature_windows`, `pfboard_v1_paltgt`, `pfboard_v1_counter`, `pfv1_lifelabel` added; the six `trail_fam_*` suites repaired (pinned clock, new moon-pill wording); the `pfv1_finalturn` fixture saves its seeded fight again; `pfv1_replay` limits loosened 2x.

## 2.7.07
- **Mentor button fixed.** Every town with a calling mentor (Birchbramble Steppe, Maizehollow, Mistmoor, Olivewhistle, Rainroot Reaches, Sunsprinkle Isles) shows the Mentor button again; it had been hidden in all towns since 2.7.03. Rest stops and villages still show none.
- **Pals in the Kitchen.** A pal on the whole Kitchen now keeps every free pot cooking (new dishes first, from anything in the satchel), not just one. New **Full time** option for the whole Kitchen and the Pantry: the pal keeps working on game time until you call it home. "Pots to leave free" keeps some pots for you. Checks run every 10 game minutes (sleeps move the pal clocks).
- **Recipes you have not found yet now show their name and what they need** ("2 × Carrot, found / not found yet"): crafting list, scene popovers, Pantry, the Almanac hint for an undiscovered recipe, and an ingredient's "used in" line.
- **Hazard road kind.** Three roads (ids 242, 245, 249) are hazardous: +10 game minutes a stretch, +5 with any walking staff. Draws the hazard marker. New worlds get a Hazard line on the Almanac road-kinds page.
- **Trail toasts** (Milestone box, new Almanac pages, prizes) sit small in the bottom-right corner on a Trail map, so they no longer cover the scene.
- **Boon tag.** A pal's puzzle piece shaped by a Boon carries a "Boon" tag with its own text.
- **Admin:** every data editor in the menu has its own icon.
- **Art (separate image zips).** 9 new icons: build verbs carry, decorate, wait, vigil, befriend, trial and road kinds toll, beat, weather (Aseprite + Lua; Sonnet scaffold, Opus polish). Three NPC sprites redrawn: snail, stick-insect, ladybird. The build verbs use their own pictures now.
- **Tests:** `mentor_nav`, `unk_recipes`, `admin_icons`, `pf_boon_tag` added; `paljobs`, `trail_marks`, `road_kinds`, `build_verbs` extended.

## 2.7.06
- **Puzzle fights (new fights only; a fight already under way keeps its old rules).**
  - **Board is 4x4 always.** Two environment pieces per turn; environment events matter a bit more (rain 0.20, creature events 0.7).
  - **Set combos:** a combo is two pieces of the same owner anywhere in the same chain, not played order. The chain resolves in a fixed order (environment, Guard/Soothe, Trick, Hurt/Charm, Heal/Item); Quick fires first, Heavy last. Explained in the Almanac and the "?" sheet.
  - **Creature tactics and piece abilities:** Bramble halved on creatures, starter Jab on the curve, 7 creature tune rows fitted, creature Barge planning, Stagger in learner fights, luck redraw, boss double roll, Sticky and slow-draw fixes.
  - **Teamwork reachable** (+30% / +60%), creature healing now acts on the yield bar (damage first, then charm).
  - **Turn banner** holds input until it ends; the Quick second piece shows its aim.
  - Lair drops gated, Pluck gated, broken belt pieces clear their wear.
- **Camps:** resting or sleeping at a Trail camp now heals.
- **Trail pills:** all Trail family pills start collapsed, with a line showing, like the moon pill.
- **Pal jobs:** one pal tends a whole station (kitchen, pantry, ...). It auto-picks new recipes first, uses anything in the satchel, outputs to the satchel or jar. Recipe picking stays as an option. Pantry jars supported. All crafting timers run on game days.
- **Sights:** many new tokens and conditions (streaks, lend/repay, time, escorts, take any item, buffs, quest limits), more varied rewards, a second line each; escorts walk beside the gnome on the map. Wander finds show a popup for any item or Petals.
- **Roads and building:** road kinds toll / beat / weather; new build verbs; Lantern Relay per game day; moon line and hazard marker fixes.
- **Cleanup:** 4 dead mentor folk rows deleted; Treks and Pal targeting dropped from the roadmap.
- **Art:** none in this release (build-verb pictures, combo chips and others follow in a separate image zip).

## 2.7.05
- **Puzzle box finish (behind `pfight_v1`; players see none of it until it is on).**
  - **Waiting upgrade offers on the v1 box.** `pfv_offer_html()`: when a puzzle upgrade offer is waiting (`user_poffer`), the v1 box shows a "Choose an upgrade" card above the box with the three choices (post `do=pick`, the same handler as the old page), the count waiting and how many were earned today. Offers are no longer only reachable on the old page.
  - **Belt level check in the shop.** `buy_from_shop()` refuses a fight belt the gnome is too young for (`pfd_belt_level_need()`: Stitched 8, Masterwork 18) with a message; Twigg's tile is dimmed with "Level N" and a note. The Belt tab's Twigg's link goes to the shop itself (`shop.php?id=`), the Pals tab link to the Pal Book's party section (`puzzlepals.php#party`).
  - **Swap is one request.** New `do=pfd_swap` (`out`, `in`; `pfd_swap()`): the server tries the order that keeps the deck legal and puts everything back if it cannot. The sheet's swap button no longer posts twice.
  - **No script.** A piece in the box has a small Pack / Take out form inside `<noscript>`, and a type icon stands in for the art the script paints.
  - **Old (pre-2.6.74) box carry-over (decided: stays off).** The fixed starter is the same box for everyone, so an old `user_pbox` is not carried into it (only the starter PICK post, which no longer shows, still carries it; `pfd_carry_old_box()`). `pbox_205` checks it.
  - **Lair guardians have a Unique layer.** `pfd_unique_of()`: a `boss-...` guardian (no row in the unique-pieces data) takes the unique 3 of a boss of its landscape, picked by its slug so it is always the same.
  - **Reset leaves the belt "never set" (decided):** that is what a new gnome has, so a reset gnome is the same as a new one. `pfv_starter_html` stays as the fallback for a failed packing (not dead code: `pfd_ensure_starter` can fail when the tables are not ready).
- **Fight fixes.**
  - **Light theme, old board (`pfight_v1` Off):** the encounter overlay, piece card, held chip and plays list sit on dark panels and now carry their own light ink (`pfight.css`, appended rules only; `pbox_v1` now checks the file differs from 2.6.73 by added lines only).
  - **Replay:** the piece card is one small line while a turn plays, so it no longer covers the hand. "The oldest patch fades" shows at its own step (`pfb_ground_set()` returns the cell that faded, the replay event carries `drop`), not at the end.
  - **In-place "Let's fight":** `pfparts47.js` now adds `pf-jig` to a fight swapped in without a reload. Without it the board was drawn larger and the dock went compact, hiding "Next in the environment".
  - **Hide "Or set aside with":** already hidden in every new fight (rules `aside` 0 since 2.6.95); only a fight started under the 2.6.94 rules still offers it, as it must.
- **Tests.** New `pbox_205` and `emoji_icons` suites (both in CI). `emoji_icons` expected `.svg` where the swap writes `.png` (test fixed). `trail_marks`, `animals140` and `pfv1_guide` pass on a clean run (the old failures did not come back); `pbox_v1` and `pfmap` flakes are in the todo.
- **Player post (`update_news.php`):** none. Everything above is behind `pfight_v1` (Off) or admin-side.

## 2.7.04
- **Admin look: "Stitched Toy, grown up" (mockup A, `admin_mockups_A_felt.html`).** Drawn SVG icons (`admin_icon()`, 2 px square-cap strokes; one per section, and admin pages such as Update, Messages, Admin log, Give / take items, Code and Usage get their own via `admin_entry_icon()`) replace the emoji in the Admin menu, the side menu / menu sheet, the breadcrumbs and the status messages. Admin > Dashboard opens with a "Needs a look" panel (`admin_triage_render()`): site_url, maintenance, failed upgrade steps, install.php, error log and new messages are rows with a Problem / Check / Note chip (icon and word, never colour alone) and an action button; the red and green banners are gone.
- **Workshop "!" marks only when you can really make something.** `craft_map_ready()` counted any recipe you held the ingredients for, so the "!" and "N ready" sat on the workshop picture and the crafting map while you were too tired, the pots were full, the feast fee was out of reach or a feast needed a bigger Kitchen. It now uses the same test as the shelf's Ready tab (ingredients, energy, free pot, cooking fee, Kitchen level). `workshop.php` refreshes energy before drawing. A jar that is done in the Pantry still shows "!" (that is a real job to collect). Checked: with every ingredient held, energy 100 gave 6 areas ready, energy 0 gave 1 (a free recipe).
- **Player post (Release notes tab, `update_news.php`):** the workshop fix only; the Admin changes get no post.
- **Recent and Pinned (admin.js).** The last pages you opened and the pages you pinned (pin button in the breadcrumb bar) show on the Dashboard. Stored in this browser only (`gv-admin-recent`, `gv-admin-pins`); nothing on the server.
- **Game settings and data editors.** Settings you have changed since the page loaded get a "Changed" mark and the Save bar sticks to the bottom with a count; list tables get a sticky header, calmer hover and a 44 px pager (`admin.css`).

## 2.7.03
- **Moon text is a collapsed pill.** New `moon_pill()` / `moon_pill_section()` (`includes/moon.php`, style `.moonpill`): the Trail strips for haven, delve, lair and desert night are one collapsed pill each; the moon label in the mountain, rainforest, tundra, wetland and wonder headers is a pill with its explanation inside. (The coast strip keeps its own folded design from 2.7.01.)
- **Hint is a small bulb.** The fight Hint button is 💡 with the hints-left count, a 32 px round button at the end of the button row.
- **Mentor button only in towns.** `here_mentor_of()` returns a mentor only for a `town` node, so rest stops (village/stop) no longer show it.
- **More dishes count as Meals.** Smoked Trout, Grilled Sardines, Falafel, Kangkong Stir-fry, Fiddlehead Fry, Goat Milk Porridge, the three salads, the three toasts, Pancakes, Tropical Fruit Bowl, Devilled Eggs and Scrambled Eggs moved from Snack to Meal (15 min, one per pot, 1 cook energy), so they count for rest stop upkeep (`meal:N`), job boards and calling chapters. One-time upgrade `meal_tiers_boot()` (flag `upg_meal_tiers2`); recipes whose cook minutes an admin changed are left alone. They no longer heal on adventures (snacks only).

## 2.7.02
- **Puzzle box page reworked (R3 mockup, behind `pfight_v1`).** `pfv_box_html` now draws the box as a wooden chest with a lid of four labelled gauges (Rare, Masterwork, Larder, Keepsakes), a Ready / Weak / Not ready / Locked pill with a Kit / Hurt / Limits strip and fix rows, felt trays for Kit (tally by type, Add slot), Belt (wear bar, Fix / Take off) and Pals (perch sprites), a spares shelf with search and six source buttons (icon, colour, count, legend), and a bottom sheet for pieces, tools and swaps (side panel from 900px). New scoped `.pbx` / `.pbx-sheet` in `pfv1.css`, sheet logic in `pfv1box.js`. All form posts, tabs, the locked state and `?pfd=json` are unchanged; no inline script or style.
- **Same starter box for everyone.** `PFD_STARTER_FIXED` (jab, swing#2, pierce, snack, brace, soothe) with the 4 core pieces; `pfd_ensure_starter()` packs it on the first Puzzle box visit and before the pre-fight screen, so the pick screen is no longer reached (`pfv_starter_html` stays as a fallback). The unchosen-deck default and `pfd_set_starter($u, 'fixed')` use it; the fixed first fight still names the Bold kit with Taunt (`pfd_first_tiles`). The old-box (pre-2.6.74) carry-over no longer runs.
- **Admin > Players > Reset Puzzle box (`admin/puzzlebox.php`, `pfd_admin_reset()`).** Back to the fixed starter box: pieces switched on are switched off, the belt is back to "never set" (best usable tools), auto-use off. Kept: every unlock (pieces come from crops, crafts, regions, wearables, tools, pals), earned puzzle upgrades, tool wear, repair kits. Refused while the gnome is in a fight; unknown ids refused; logged as `pbox_reset`.
- **Trail buttons wrap to a second row** (`.trailfoot`, 88px minimum) instead of six crushed into one.
- **Trail tide strip folds** into a one-line moon button (`<details class="tfcoast">`); the Trail family blocks (`trail_fam_html`) now sit below the map.
- **Gather scene:** `weather-fog.png` redrawn as a soft translucent mist (the old one was an opaque dithered overlay).
- **First-fight hint card:** dark text at full opacity on the cream card (`.pfv-guide`).
- **Tests.** New suite `pfdeck_reset` (in CI); `pfdeck_v1`, `pbox_v1` (+ seed and shots), `pfboard_v1_page` follow the fixed starter. Mockups and the art contact sheet for 2.7.01 were made in this session (not shipped).

## 2.7.01
- **NPC Clockwork, moon and tides, Trail map families, 2.5D villagers (branch `ccr-b949e7ad-nuu8lw`).** Every villager has a computed week of 2 to 3 doings (stroll, sit, tend a patch, walk to the next stop, market, visit a Trail Sight; setting `npc_clockwork`, `npc_clockwork.php`, `data/npc_clockwork.txt`); Sight appointments with a forecast (`npc_cw_forecast`), shop cover for an absent keeper (`npc_cw_shop_cover`), a stop Villagers "Right now" list. `moon.php`: a 28 game day month, 8 phases, tides, Sight conditions `mo=` and `ti=`. 14 Trail map families (`trail_fam_<name>.php`, a picture layer, Sight rows and a quest line each). `npc25.php`: 25 species and 11 gnome NPCs as 8-frame 2.5D strips in the Here scene, spot faces and the Trail map, walkers on road errands (`trail_walkers.php`). Tests: `npc_clockwork`, `npc25_wire`, `trail_walkers`, 14 `trail_fam_*`. Known gaps: `claude/HANDOFF-clockwork-families-npc25.md` (Open list).
- **Creature pass (puzzle combat).** 319 creature rows (88 base + 231 variants, each a separate named creature with its own deck, ability, AI style, regions and drops; `data/pf_creatures.txt`, loaded by boot step `creatures_2701`). 8 new engine effects in 41 abilities and 10 AI styles (`PFB_ABIL`, JS twin in `tools/pfengine.js`). `pick_creature` filters variants by region (`scene_region_code`); drops carry `@reg` and `@lv` gates (`creature_drops.reg/lvmin/lvmax`). Balance option D: about 80% chain-bot win at level for every size; a low-level bar ease for small and medium creatures (`PFB_V1_BAR_EASE_SMALL/MEDIUM`) so a gnome 4 levels under is not lost; per-creature multipliers in `data/pf_creature_tune.txt`. Tests: `pf_creatures_import` (in CI), `pfboard_v1_abil`, `pfboard_v1_ai`; `pfdeck_v1` now fights a large creature (the bar ease shortened the old medium fight). Notes in `claude/creature-pass/` (`balance-report.md`, `content-fixes.md`). Known gaps: 23 creatures (level 35-40) have no region window; medium -8 and 13 creatures stay more than 12 points from their size median; no human playtest, no variant art.
- **Shop Street.** The Shops view (`town.php?view=shops`) and the World page's Shops tab show a street picture (14 regional pictures `scenes/here-shops-street-<code>.png`, default `here-shops-street.png`, layout `shops-street` with `view: street`; picture navigation on) with Mossbottom's shops on the `hub-<type>` fronts and the town's own on `loc-1..4` (free fronts are shuttered "To let"), then one text list in two sections (📍 Here in the town, 🍄 Mossbottom, open from anywhere) with an open / closed / away state on every card. New `shop_state()`, `shop_is_hub()`, `shop_street_html()`; the folded Mossbottom list on World is gone. Import with `python3 tools/import_gate_layouts.py --shops-street`; `tools/lint_here.php` checks the regional picture sizes. APP_VERSION is 2.7.01.
- **Shop Street fixes.** `shop_state()` follows each shop's real buy rules (pet shops: only the admin switch; Dye Pot and Curio Cabinet: staff only; others clock then staff); label pills no longer take taps, are truncated to the box width and drop "The " before the emoji; no Mossbottom pet shop means no hub-pets front; "To let" fronts are not keyboard stops; close minute 1440 shows 24:00.
- **Shop Street names always visible.** The Shop Street pills show the full shop name (no truncation to the box width): `hub_street_pill_layout()` staggers them into label rows per group (local shops below the buildings with a dashed leader to the door, Mossbottom front row, Mossbottom upper row), clear of the compass corner and the stand points, each with an open / closed / away square inside the pill; the pill is part of its shop's link. Other scenes' pills are unchanged.
- **Art: the approved Opus look installed (Josh chose 'Opus rich').** `tools/install_art_2701.py` (105 files, source -> game path table): 14 puzzle-fight tag icons (`pfight/ico-<tag>.png` 32 px and `-s` 20 px, downscaled from the 64 px masters: jab pierce sting trip bash smash brace roll hum lull bond pluck mending thornhide); wearable icons (Opus Travel Cloak, Flood Boots / Work Gloves / Trail Pack / Travel Cloak / Wayfarer's Hat cut b, all 8 Lined and Fine); avatar strips front-wboots, front-pack, back-gloves, and the front Flood Boots now draw OVER the tunic (`GNOME25_WEAR_AFTER`, they read tall; cached strips get a new name via `GNOME25_ART_REV`); 14 pals (yard 64 px in `pals/`, new perch 36 px in `pals/perch/`, used on the treehouse perches, other pals unchanged); 6 creature minis and 3 folk portraits; 15 Trail markers in `trail/mark/` (wired on the map, see below); 8 Maplewold stop looks (mill shrine jetty herb workshop orchard tower camp) with their own layouts `stop-<type>-grassland_maplewold` (inn, ferry, spring keep their plain look).
- **The Trail map draws the drawn markers.** Fight and camp as before, and now: a road kind's marker on a floor tile beside the way in (ferry, tunnel, pass and toll on the first stretch walked, overgrown and flooded on every stretch; `trail_road_mark()`, `rk_on_stretch()`; the tile says "Ferry · 20 Petals"); the way on of a walk's last stretch shows the place it leads into (haven, wonder, delve, lair, market; the tile says "The way on to <place>"); a Sight is the spyglass over its landmark with a small gold ! while ready, faded once used up (it had no mark then); a villager at a Sight who has no sprite of their own stands as the villager marker (was left off the map). A missing picture draws the token's emoji on a small disc (`tmmarkx`, same 42-unit box); the no-picture map draws them as emoji tokens. Tokens name their marker in a 7th field, so 🏕️ haven and 🏕️ camp do not clash; a wonder's fallback emoji is 🌟 (✨ is a find). Still emoji: the way on to a village (rest / signpost / hazard markers are being drawn).
- **Tests.** New suite `trail_marks` (in CI): marker names, which stretch, the spot beside the way in, the tile label, fixed box, the emoji disc without the picture, the no-picture map, the place ahead for all five kinds, the Sight ready / used up / without its picture, the villager marker.
- **`derive_icons.py` keeps hand-drawn icons** (PROTECTED list); the cut-b Lined/Fine icons are re-derived from the drawn patch. Admin > Images zip `upload-zips/gnome-venture-images-v3-2.7.01.zip` (upload it, uploads beat `assets/img/ph`; 33 icons since step 2, below).
- **Tests.** New suite `art_2701` (files, sizes, `art_path`, perch/yard pals, boots over the tunic, Trail markers, stop layouts, derive protected list); `art_2701` and `gnome_wear` added to CI.
- **Art install, step 2 (the art finished after the first install; `tools/install_art_2701.py` now 386 rows).** 128 more Puzzle Pals (art-2701-pals-all c00..c15, opus3: yard `pals/<key>.png` 64 px and perch `pals/perch/<key>.png` 36 px, named by the `puzzle_pals.txt` key `treehouse_pal_pic()` looks up; 142 pals drawn in all). The rest of the wearable icons: base Flood Boots / Work Gloves / Trail Pack / Yarn Scarf / Wayfarer's Hat, Wayfarer's Hat and Yarn Scarf Lined/Fine, every cut b Lined/Fine (batch4, batch4b), and a redrawn cut b Travel Cloak with its Lined/Fine (batch5, replacing the earlier ones): all 33 are hand-drawn and in `derive_icons.py` PROTECTED (a run now derives nothing). Trail markers rest, signpost, hazard (`trail/mark/`). Maplewold inn, ferry and spring stop looks with their own layouts (`stop-<type>-grassland_maplewold`; all 12 stop types now have a Maplewold look).
- **Trail map: rest stop and side path markers.** The way on of the last stretch into a rest stop (a village) shows the rest marker (🛖 disc without the picture; `trail_dest_mark_name()`); a side path with no road kind shows the signpost beside the way in on its first stretch ("A side path, off the road"; `trail_road_mark()` kind `side`, `trail_road_mark_name()`). The hazard marker is installed but not drawn: no Trail data has a hazard yet.
- **Admin > Images zip rebuilt:** `upload-zips/gnome-venture-images-v3-2.7.01.zip` now has all 33 wearable icons (every one changed since 2.7.00). Pals, Trail markers and stop looks are not Admin > Images files: they ship in the game update.
- **Tests (step 2).** `art_2701`: 386 rows, the 128 pals by key (yard + perch via `treehouse_pal_pic`, opus3 bytes, `art_path`), 142 perch pictures, rest/signpost/hazard, inn/ferry/spring layouts (lint clean, own spots), all 33 icons PROTECTED and kept byte for byte. `trail_marks`: the rest marker into a village (and its emoji disc), the door into other places, the signpost on a side path's first stretch only.
- **Learner rules for the first fights (new fights, behind `pfight_v1`).** A gnome's first 3 finished fights (setting `pfight_learner_n`, 0 = off) have no Thornburst in the environment deck, creature tags off and creature pieces x0.8 (sim: a careless level 1-2 player goes from 76% to 98% wins). New table `pf_learn`; new rule key `nothorn` (PHP `pfb_v1_cfg`, JS `tools/pfengine.js`).
- **Wearables as Trail Sight rewards.** Five Sights can now drop a Rank 1 wearable at a low chance (scarecrow: Wayfarer's Hat 3%, mudslide: Flood Boots 4%, icicle curtain: Travel Cloak 3%, woodcutter's stump: Work Gloves 4%, mossy stair: Trail Pack 3%); they drop only while `pfight_v1` is on for the gnome.
- **Fixes.** Tailor level 3 text now says the first *craft* each day is free (it never freed lining). `pf_round()` replaces `round()` in the puzzle engine so PHP 8.4 matches the JS port. `pfdeck_v1` tool-piece check is deterministic.
- **Wearable retune (Tailor sims, `claude/sims-tailor-2.7.01.md` section 11).** Evade now stops the round's poison tick even after it made the creature's Hurt miss (the Hurt used it up first, so Puddle Hop never cut poison; new `me.evd` for the round, PHP and JS port): Puddle Hop takes 8-20% less poison than Sure Foot against Reptiles. Every Guard wearable cut (Puddle Hop, Sure Foot, Brim Down, Wrap Up, Hood Up) carries the Spiky knack (2 on the creature when played); a higher base value changed nothing. They are now played as often as the Hurt cuts; no single wearable moves the careless bot's wins by more than 1.1 points.
- **Tailor sims follow-up (`claude/sims-tailor-2.7.01.md` section 12).** The Flood Boots' +4.0 win points against Reptiles was sample size: at n = 2520 both cuts give +1.2 (paired SE 0.65), within the 3-point rule, and Puddle Hop still takes less poison than Sure Foot; no game value changed. Sim 10 now tests Hold then Bash with a Lined Guard (the Rare cap fits only one Fine wearable next to two Rare belt tools; the driver stops if a wearable is out): Hold adds under 1 guard a fight to Bash hits, no runaway. The level 40 "one Fine wearable costs 2-6.5 points" (n = 46) is gone at n = 790 (97.6-98.6% vs 98.2%).
- **CI.** Playwright + Chromium for the browser suites; the upgrade job builds the old release from git history (the source zips are not in git).
- **Costly cell (new fights).** A lit spot whose chain costs your health has a red edge and says why ("Costs you 4 health: it fires the Garden Snail's Snap"); once placed, the line above End turn says it; in a gnome's first 5 fights (setting `pfight_costwarn_n`, 0 = never) End turn asks once when a free spot was open. Engine: the lit-cell preview carries `hw` (name, side, health per piece), PHP and JS port.
- **"New today" card.** The first fight after the learner fights opens with one line: Thornburst, creature tags, creature pieces at full strength.
- **Help sheet.** New rows: how a fight ends (win, lose, the turn cap), the numbers on a lit spot, combos; set aside only in fights that have it; Chains, Guard and Flip have their own marks (they shared one arrow).
- **The rest of the learner review (`claude/reviews-2026-11-13/learn.md`), new fights behind `pfight_v1`.**
  - **Fixed first fight** (`pfight_first_fixed`, `pfight_first_seed`): a new gnome's first fight is always a Garden Snail (learn.md: 97% careless wins, no class rule; the Aphid Swarm grows), the Bold kit with Taunt and no gear, the blank opening and deal 4 (harness: a two-piece link on turn 1, a costly spot on turn 2, the careful bot wins in 4 turns, the careless one in 9). No box or pre-fight screen before it: the box is offered from the next fight.
  - **Learner fights** (the first `pfight_learner_n`): random creatures above the gnome's level are re-picked at its level; the fight starts at full health; a defeat is no knock-out (the creature wanders off, the walk goes on at full health).
  - **Guided first turns** (`pfight_guide_n`, default 2 fights): one line above the board on the opening and turns 1-2 (pick a piece, a side of the blank, Confirm start, what the lit-spot numbers mean, "fire it in your chain", End turn). Never blocks; its close button switches it off for the gnome (new column `pf_learn.guide_off`).
  - **Hint button** (`pfight_hint_n`, default 3 free a fight): lights the spot the learner bot picks (`pfb_search` for your side, on a copy with the creature's hand and both piles emptied) and says why in one line. Asking again in the same turn is free.
  - **Stall nudge** (`pfight_stall_turn`, default 8): "Stuck? Link to a Bramble ..., or tap Hint" while the bar is under half.
  - **Defeat recap** on the result card ("You lost 6 health to the Garden Snail's pieces and 4 to your own chains ...") and **Try again** after a defeat in the first `pfight_retry_n` fights (same creature, new deal, your health as it was).
- **Small fixes.** Bramble's text in `pf_env.txt` (and the JS copy) says what the engine does: your chain fills the Yield bar a tenth, its chain costs you a tenth of your health. The play harness `tests/pf_play.php` prints the creature's class rule.
- **Tests.** New: `pfv1_guide` (browser: first fight, coaching, hint, nudge, recap, retry), `pf_learner` sections for the first fight, learner creature, guide, hint (public information), recap, retry and no knock-out; `pbox_v1_seed.php fight SIZE [auto] [SLUG]`. Also new: `pfv1_costly` (browser), `pfboard_v1` section 30, `pf_learner` UI checks, `pf_play_decks` class-rule line (both added to CI). Stale since the learner commit or 2.7.00, fixed: `pfboard_v1` PRE key count, `pfboard_v1_page` T12 regex (`nothorn`), `pfv1_enemy` spawn case (pins `spawn` 1).
- **Sims and notes (claude/).** `sims-tailor-2.7.01.md` (9 of the 10 Tailor sims; Bond has no built piece), `realchoice-2.7.01.md` (why 16%, no lever reaches 25%), `release-notes-2.7.00-2.7.01.md` (player draft). Drivers in `tools/sims/`.

## 2.7.00
- **Road kinds (owner-approved list, `data/road_kinds.txt`).** Some Trail routes are no longer plain roads: ferries (20 Petals a crossing), tunnels (lantern tier needed), passes (staff tier needed), toll roads (10 Petals: safer and quicker, or the old road), overgrown roads (slow; an axe clears them) and flooded roads (slow; Flood Boots halve it). Route cards and the Almanac say which. Boot step `road_kind_items_2700` (Toll Receipt).
- **Camp spots.** Each Trail route has one camp tile (`data/trail_camps.json`): Sleep and Nap are free and safe; Wait 10 to 60 minutes gives 1 energy per 2 minutes, with a chance a fight finds you (halved on a paid toll road).
- **Sights reward pass.** Sights check conditions, scale with region level (setting `sights_flat_pct_per_level`, default 3), can give discounts (`users.ev_disc`) and have the new grammar in `claude/sights/GRAMMAR.md`.
- **Admin > Trail decor.** Edit the decor of a stretch (looks, rough, floor, props, tree) with a saved override and Back to the data (`trail_decor_edits`).
- **Ruin pictures.** The nine pilot places show their own ruin picture while ruined (`landmark_scene()`); other ruined places keep the greyed live picture. Fixed a missing `slug` in the Lair victory path.
- **Puzzle combat (v1 rules, new fights only).** Chain order is now environment, defence, augments, hurt and charm, then heal (`pfb_rank`); a creature piece no longer appears just before your resolution ends (`spawn`); old fights keep their rules. Garden crew panel on the Pal jobs page is grouped by garden.
- **Wearables and the Tailor (behind the `pfight_v1` admin setting: Off / Admins only).** A Tailor garden building (garden level 6, 1800 Petals, levels 2 and 3) and a Tailor page. Six wearables (Flood Boots, Wayfarer's Hat, Work Gloves, Travel Cloak, Trail Pack, Yarn Scarf) with 11 cuts, three ranks (Common, Lined, Fine) and 33 items. They are Keepsake pieces in the Puzzle box (Fine counts as Rare). Lining takes 30% + 8% per Tailor power point (cap 78%); a failed lining gives a Tailor's Thread and 5 Threads make the next one sure. Re-cut costs 1 Thread, nothing with a level 2 Tailor. A level 3 Tailor makes the first craft of each game day free; Tailor power over 6 pays commission Petals; a Fine wearable can be worn as Lined (`wear_lined`). Worn wearables show on the 2.5D gnome (15 new layer strips; `w=` in the sprite URL). New Almanac page. Boot step `wearables_2700`.
- **Art.** 33 wearable icons, Tailor building levels 1 to 3, 15 avatar layer strips, 9 ruin pictures.
- **Tests.** New suites: road_kinds, trail_camps, trail_sights_270, trail_decor_edit, trail_decor_page, wearables, tailor, tailor_page, ruin_scene, gnome_wear, pfboard_v1_order. 13 older suites that had gone stale are fixed. CI lint skips `fight_events.php`. Known flake: `pfdeck_v1` "tool pieces were played in the fight".
- Not in this version yet: Trail icons, Pal sprites, the 77 stop looks and the ground-picture re-bake.

## 2.6.990
- **Three new piece effects and the 42 legendary crop pieces (Josh's decisions 2026-11-15: build the three effects, harvest a crop 3 times to unlock its piece).** Needs 2.6.97+, no DB change. Skip 2.6.981 to 2.6.989. Draft and the full table: `claude/reviews-2026-11-13/legendary-crop-pieces.md`.
- **Keeper** (`keep`): a piece you did not play stays in your hand through the end-of-round redraw (the hand is filled back up to 5). **Plenty** (`plenty`): played, next round you pick from 6 pieces (a flag; it does not stack). **Simmer** (`simmer`): played, it heals you 2 as each of your next 2 turns starts (a note line "Simmer: you heal 2 as your turn starts"). PHP (`pf_apply`, `pfb_end_round`, `pfb_guard_notes`), JS twin, parity decks carry the three tags, tests in `tests/pfboard_v1_kinds.php`. The tags are in `PF_TAGS_V1` only (the old strip pages and their icon loader are unchanged, `PF_TAGS` stays as it was); three new 12x12 tag marks in `parts48/marks/` (drawn as PNGs; add them to the Aseprite sources before the next `build_parts48.py` run).
- **42 legendary crop pieces** (`g:SLUG`, source `legend`, `data/pf_pieces.txt`): one per treasure crop of `region_crops.txt`, matching the crop's stat (luck, lore, charm, grit). Yours after you harvest that crop 3 times (`PFD_LEGEND_HARVESTS`); rank follows your mastery of it; they arrive off with a NEW mark and share the Larder with crop pieces. A piece can carry a built-in knack (a 12th column: tender, leech, spiky, soft, warm, finisher, hardy). A crown filter in the Puzzle box. Tests: one piece per treasure crop, no two the same, the unlock at the third harvest, the Larder shared.
- **Not done:** the bots (`pfb_score`) do not yet value a kept piece, a sixth piece or a heal over time, so their win rates with these in the deck read low; no balance sim with the 42 yet; the hand layout with 6 pieces is scaled by the existing fit code but was not looked at on a phone.
- **Tests:** the Puzzle box browser suite now names the URL of a failed load (found the missing tag marks).

## 2.6.989
- **A creature's heal now acts on the Yield bar (owner: "Creature healing needs to act on the yield bar. It doesn't").** In the one-bar rules a heal only touched the Hurt part, so a bar filled by Charm never went down. Now a heal takes the Yield bar down, the Hurt part first, then the Charm part (`pf_foe_heal`, JS `foeHeal`; the creature's heal trick pieces too). A 2.6.94 fight (two bars) keeps the old rule. Tests in `tests/pfboard_v1_kinds.php`; parity run.
- **Piece slots, step 1 (Josh's decision 2026-11-14).** New pieces arrive switched OFF with a NEW mark (crop, craft and region pieces used to arrive on, so a gnome who had done everything carried 44 pieces). The Larder holds crop pieces: 3 slots, 4 from level 10, 5 from level 20; more crop pieces switched on than slots stay out of the deck ("your Larder is full") and a new one is refused with "Take one out first". The Keepsake slots (2, 3 from level 15) are built for the friend, Gourmand and lair-trophy pieces, which do not exist yet. Regions and crafts are not slotted. The Puzzle box shows the Larder pips and a NEW badge. `pfd_slots()`, `PFD_LARDER_SRC`, `PFD_KEEP_SRC` in `pfdeck.php`; tests in `tests/pfdeck_v1.php`. Existing gnomes' crop, craft and region pieces will show as New and off until packed. Not built yet: one piece per crop and per dish, the Gourmand and mentor pieces, lair trophies.
- **Fix: venom could take poison above its cap of 3** (found by the whole-fight deck test, which had silently stopped running since 2.6.987 because of a stray apostrophe in a test string; fixed, and the stale 7x5 board check too).
- **Tests:** the opening helpers in `pbox_v1_seed.php` and `pf_play.php` read where the Blank is. Needs 2.6.97+, no DB change. Skip 2.6.981 to 2.6.988.

## 2.6.988
- **Swarm is different now: it grows (owner: keep Quick, make Swarm unique another way).** A Critter plays ONE piece a turn again (its pieces are no longer x0.6), and its Hurt hits +1 for every 2 of its other pieces on the board, up to +2. Use up or outlast its pieces to shrink it. A first try with +1 per piece cost the chain bot 13 points on small creatures (45% against 58%); +1 per 2 is neutral (57% / 71% against 58% / 72% with the rules off). Needs 2.6.97+, no DB change. Skip 2.6.981 to 2.6.987.
- **Poison ticks are flat and Evade stops them (owner).** A poison piece's tick is its own value over 2 or 3, as printed, not the value after Sun and combos (v1 board fights only). On your side, Evade up at the end of the round makes the poison tick do nothing (it still counts down). The Evade text says so.
- **Trip and Lull still skip a whole creature turn** (owner: keep).
- **Tests:** `tests/pfboard_v1_kinds.php` (Swarm grows, Quick, flat poison, Evade), the parity run, and `pfv1_finalturn.php` now plays until the creature has put pieces down and one has left instead of a fixed 3 turns.

## 2.6.987
- **Rule book fixes (from the playthrough in `claude/reviews-2026-11-13/rulebook/`).** Needs 2.6.97+, no DB change. Skip 2.6.981 to 2.6.986.
- **The aim total covers the whole creature turn.** A Swarm's second piece (and a Quick piece) were left out of "hits you for N": in 350 aims the number was wrong in 83 Critter turns. `pfb_aim_total` now plays the whole turn on a copy when the creature is a Critter or has Quick, and says so in the reasons. Property test in `tests/pfboard_v1_kinds.php`; JS twin and parity updated.
- **"Stays N rounds" is right.** In a new fight every piece stays 3 rounds; the NEXT strip and the creature card said 2 to 4. They now say 3.
- **The help sheet only describes the aim strike when it is on** (it is off by default).
- **Quick's text for your pieces says it has no extra effect** (the whole hand is redrawn each round, so the old "draws you a piece" did nothing).
- **Flag-off pages are the pages of 2.6.73 again.** 2.6.981 changed "in the middle" to "on the board" and 2.6.986 added `fnew` to gone pieces on pages that do not use the v1 rules; both now only in v1 fights (`tests/pbox_v1.sh`, which now prints what differs).
- **Not changed (design questions, listed in the rule book):** poison ticks scale with Sun and combos and land through Evade; Trip and Lull skip a whole creature turn.

## 2.6.986
- **Fix: a creature's piece that was put down and used up in the same turn showed from the first frame of the replay, while your turn was still resolving (owner: check how Swarm turns are processed).** A Swarm creature (two pieces a turn) and any creature whose chain reaches 3 pieces use its own pieces up, and a used-up piece is drawn from the start as "gone" until everything has scored. The creature's new pieces were in that list, so they showed early. The gone entry now carries `fnew` (PHP, JS twin) and the page keeps it hidden until its own step (`pfboardv1_part.js`). In 30 seeded Swarm fights 134 such pieces were found, all now marked. Needs 2.6.97+, no DB change. Skip 2.6.981 to 2.6.985.

## 2.6.985
- **Fix: a creature's class-rule effects played before its turn, while your turn was resolving (owner: "the enemy's turn play is happening slightly before when it should").** The replay hid a Plant's new Bramble and showed a Water-pushed piece already moved from the first frame. Now the Bramble stays off the board and the pushed piece stays where it stood until the creature's own step (`pfboardv1_part.js`: `envPre`, `envStepE`; the replay entry of a `current` note carries `moved`). Needs 2.6.97+, no DB change. Skip 2.6.981 to 2.6.984.

## 2.6.984
- **Aim strike is OFF in new fights (owner: "If I play a piece on their planned spot it shouldn't remove my piece, that's rude. It should pick somewhere else").** `aimhit` defaults to 0 again: a piece of yours on the creature's aimed cell makes it pick again, as before 2.6.98. The strike code, its chip, mark and tests stay (switch `aimhit` 1, or the Tuning sheet in the demo). Needs 2.6.97+, no DB change. Skip 2.6.981 to 2.6.983.

## 2.6.983
- **Fix: the first piece could not be placed (owner: "Live won't let me place my first piece. It resets when I press start").** Since the Blank starts on a random inner cell (2.6.981), the opening handler in `pfight_game.php` still worked out the side from the CENTRE of the board, so a piece placed next to the real Blank was refused ("Pick a spot next to the blank") and the page reset. It now reads where the Blank is (`pfb_start_side`). The demo had the same bug and was fixed in 2.6.982's rebuild. Needs 2.6.97+, no DB change. Skip 2.6.981 and 2.6.982.

## 2.6.982
- **Fix: the class rule chip, venom cells and the strike crack were not reaching the page in 2.6.98 / 2.6.981.** The page data builder (`pfight_game.php`) only copies a list of keys from the board view; `kind`, `grudge` and `ven` (and the replay's `strike` / `broke`) were not on it, so the Swarm / Two aims / Grudge chip, the second-aim and venom marks, and the crack on a struck piece never showed (the text lines did). Now carried; `tests/pfboard_v1_page.sh` checks the page data. Found while rebuilding the demo artifact. Needs 2.6.97+, no DB change. Skip the 2.6.981 zip: this one has everything in it.
- **Demo (`tools/pfdemo_v1`):** works with the 2.6.98+ rules (the glue read the Blank in the centre, the page data lacked the class keys, a removed `harmony` export); the Tuning sheet has switches for class rules, aim strike and keep-my-pieces; environment 1 a round.

## 2.6.981
- **Puzzle combat v1: the inert Blank starts on a random inner cell, and long piece text scrolls.** Branch `claude/todo-md-jbud4h`, not merged, no zip yet (version number 2.6.981 by owner's request). Needs 2.6.98+, no DB change. Puzzle combat v1 is still admin-gated.
- **The Blank starts anywhere (owner, for playtesting).** New rule key `blankrand` (new fights 1, fights saved before it 0): the Blank is put on a random one of the inner cells (all four sides on the board: 4 of the 16 on the 4x4 board), both start pieces go beside it wherever it is. PHP, JS twin, tests in `tests/pfboard_v1_lasting.php`.
- **No free piece after a strike (owner: "its pieces automatically pop in before my turn").** A strike spends the creature's turn without putting a piece down, which made the board put out its free piece (`pfb_spawn`) nearly every time. A strike now skips it that round (`nospawn`). Tests: section 17.
- **Piece info is no longer cut off (owner: "info on tapped pieces is truncated").** The docked piece card and the fitted card scroll instead of clipping (`pfv1.css`). Not checked on a phone.

## 2.6.98
- **Puzzle combat v1, week 2: the aim can strike your pieces, every creature class has one rule, the environment places 1 piece a round.** Slim zip `releases/GnomeVenture-2.6.98-web-update.zip`.
- **Needs 2.6.96+, no DB change. Puzzle combat v1 is still admin-gated (`pfight_v1`). Only NEW fights get the changes; fights under way keep their rules.**
- **Environment: 1 piece a round (was 2; Josh's call).** `PFB_ENV_N` in `pfboard.php` and `tools/pfengine.js`. A fight saved earlier keeps its own `envn`.
- **Aim strike (`aimhit`, on in new fights).** If the creature's aimed piece is a Hurt and YOUR piece stands on its cell, it strikes that piece instead of picking again: the piece breaks (a Guard at least as strong as the hit holds), you take no damage, its piece is spent. The aim chip says "will strike your Swing (it breaks)", the board mark turns red, the help sheet says it, the piece cracks in the replay. Events carry `strike`.
- **Bake-off for a board that lasts (`claude/reviews-2026-11-13/t15-bakeoff.md`).** `keepmine` (your pieces are never used up) and `useroot` (only the placed piece is used up) are built as switches but stay OFF: keepmine makes fights 4-5 turns and chain wins 95-99% at the current bar, and only reads fair at bar x3 (10-12 turns). `aimhit` alone was picked by the plan's decision rule; it barely moves real choice (15-19%) and lowers the health the careful bot loses.
- **Class rules (switch `kinds`, on in new fights).** Critter **Swarm** (2 small pieces a turn, x0.6), Bird **Two aims** (a second aim on another cell; it plays it when you take the first), Beast **Grudge** (+25% Hurt per block, max 3, a landed hit clears it), Water **Current** (one of your touching pieces slides away), Plant **Grows** (a Bramble beside its piece, one of its own at a time), Reptile **Venom trail** (a cell where its piece left is venom for 2 turns; your piece there poisons you 2 x 2), Boss **Two turns** (it also shows the piece it plays next round, forced). Rule chip on the status row, rule line on the creature card, second-aim mark, venom cells, help text.
- **Sims (chain/look/smart, `claude/reviews-2026-11-13/`):** the class rules move win rates by 0-7 points (inside noise at this n) and keep fights at the same length; real choice stays 14-20%, the plan's 50% target is NOT met.
- **Tests:** `tests/pfboard_v1_lasting.php` (section 17), `tests/pfboard_v1_kinds.php` (section 19), parity runs the new switches, `pfv1_enemy_seed.php` is pinned to `kinds` 0 (its scenarios are single-piece turns), `pfdeck_v1.sh` allows 3 creature pieces a turn.

## 2.6.97
- **Puzzle combat v1: the enemy's turn says what it does.** The creature's free board piece is a named replay step, older pieces its chain fires read "fires" (not "plays"), the aim chip names the environment pieces and Quick it uses, and the pieces its chain would fire light up on the board (rings and badges) before you move. The bullets below are the changes, newest first.
- **Needs 2.6.95+, no DB change. Puzzle combat v1 is still admin-gated (`pfight_v1`).**
- **The aim lights the pieces its chain would fire, so nothing is a surprise (owner decision, after "Enemy is getting random plays": its chain fired an environment piece in 43% of rounds).** While the creature's aim shows on your turn, each environment piece (Sun, Rain, Bramble, Thornburst) its chain would fire gets a pulsing solid ring in the creature's colour and a small badge with what it gives ("Sun x2 for it", "Rain +6 guard for it", "Bramble -6 you", "Thornburst -4 it": Thornburst hurts whoever's chain fires it); a piece of yours it would fire (bait) gets a dotted amber ring, "it fires this". The shapes differ (solid and pulsing / dotted), not only the colours. The rings sit on the piece body (never on the number or glyph), take no room, are gone when the aim is broken, while you have a piece placed until the preview's new aim arrives (then they follow it), and during the replay. Help sheet and aim chip tooltip: "Lit rings: pieces its chain would fire". Engine: `pfb_aim_total` / `aimTotal` also return `ids` (the fired pieces except the placed one, in firing order: `id`, `by` me/foe/env, and for an environment piece `kind` and `v`); stored in `plan.tot`, so a fight saved before this (no ids) shows no rings. PHP and JS port in parity (`tests/pfengine_js.sh` now counts dry aims with ids), `tests/pfboard_v1.php` section 22b, `tests/pfv1_enemy.sh` cases `rings`, `ringsbreak`. Screenshots: `claude/reviews-2026-11-13/enemy-plays/rings-*.png`.
- **The creature's turn says what each arriving piece is (owner: "Enemy is getting random plays it seems. Sometimes it shows and wiggles ... it makes a piece show up and then the enemy plays it and gets a free activate").** Measured on 40 seeded fights (223 creature rounds, `claude/reviews-2026-11-13/enemy-plays/`): nothing is random. What the owner saw: (1) the board puts a free piece out for the creature when it has fewer than 2 out (47% of rounds); it wiggled in after the replay with no words; (2) its chain fires environment pieces (43% of rounds), which work for whoever fires them; (3) the replay said "The Orb Spider plays Silk Wrap" for older pieces its chain fired, so one placement read as several plays (116 firings); also re-picks (17%) and Quick second pieces (6%). Fixes, text and page only (the rules are untouched): a chained older piece now reads "The Orb Spider's chain fires its Silk Wrap" / "Your chain fires your Oat Cake" (`pfight_line` and `tools/pfengine.js`, parity green); the board's free piece is the replay's last step with a line ("The board puts out Chitin Shell for the Orb Spider (it had under 2 pieces out). Its chain can use it next turn."), grows in without the wiggle and keeps a dashed ring, a "+1" tag and a "Last plays" line until your move; the aim chip names the environment pieces its chain fires and a Quick second piece ("Chitin Shell: guard 2 · fires Sun", "Venom Fang: hits you for 2 · 2 pieces"); the creature's step says whether it plays its aim, picks again (its cell was taken) or showed none; an environment piece that fires says whose chain it was; the shaking NEXT piece says it could not be placed and waits. The replay stays inside 8.46 s (the new step is counted). Tests: `tests/pfv1_enemy.sh` (browser, 5 cases, new), `tests/pfboard_v1_notes.php` (lines); `tests/pbox_v1_shots.js` accepts the chip without its leading "Aims" (its label still starts with it).

## 2.6.96
- **Puzzle combat v1, after the week-1 review: the replay is up to 8.46 s, the fight shows the site behind it, pieces look better on desktop, a new fight no longer shows the old one, broken belt tools can be removed.** The bullets below are the changes, newest first.
- **Needs 2.6.94+, no DB change. Puzzle combat v1 is still admin-gated (`pfight_v1`).**
- **The replay takes up to 8.46 s at 1x (4.23 s at 2x), was 4.6 s (Josh: the non-player moves went too fast to follow).** `REPLAY_MS` 4600 -> 8460 in `tools/pfboardv1_part.js`; an 11-event turn now gets about 0.69 s a step (was 0.34 s). `tests/pfv1_replay.js` thresholds: control back in <= 9.3 s at 1x, <= 5.2 s at 2x. Also: `envCv` uses the v48 kit's `P.env` so the board draws environment pieces with the kit (the old tint-and-disc overpaint is no longer reached).
- **Puzzle box belt: Remove a broken tool (owner: "I need to be able to remove pieces which are broken").** A tool worn out by fights (or one gone from the satchel) kept its belt slot, so the next tool could not take it ("Your belt is full"). The Belt tab now has a **Remove** button on every broken or gone entry, and in a broken tool's detail line next to Fix. It only takes the tool off the belt: the item stays in your satchel with its wear, so a Tool Repair Kit can still fix it and it can go back on (Put on). Nothing is discarded, so there is no confirm. Only your own broken or gone entries can be removed (server-checked); a working tool still uses Take off. Works without script. New action `pfd_remove` (`pfd_remove_broken`); tests `tests/pfdeck_belt_remove.sh` and `tests/pfv1_belt.sh`.
- **The fight no longer hides the website (owner: "Whole game covers over the website, we still want to see it behind it!").** What covered it: the v1 fight is a fixed screen 760px wide that drew a .78 dim over everything beside it, and on the Trail it sits in the modal dialog `#trailpop`, whose background was solid `#0d0704` (2.6.85) over the whole window, header included. Now (option A, in place, no new page): the fight is a centred **560px column** (`#pfight.pf-v1.pfv-fit`, `game/assets/pfv1.css`) dimmed at **.45** around it; in the Trail dialog the dialog is see-through, its `::backdrop` is the one steady dim (rgba(12,7,4,.45)) and the fight draws no dim of its own, so the margins still never change brightness while a turn is swapped in; on a window 700px or wider the Trail fight also sits below the header and above the bottom bar like the page fight (`frame()` in `game/assets/pfv1box.js`, which no longer scrolls the page behind a modal). Phones are unchanged: the fight is the full width and height, no scrolling at 390x844 / 360x640, nor at 1280x720 / 1440x900. Also fixed: Chrome closed the Trail dialog on a second Esc (or Android back) without a tap in between even though `cancel` is refused, and the fight vanished until a reload; the dialog now opens again at once when it holds a fight or the pre-fight screen (`game/assets/hubscene.js`). New test `tests/pfv1_layout.sh` (+ `.js`): both ways in (plain adventure page, Trail dialog) at 390x844, 360x640, 1280x720, 1440x900: no scroll, fills the height, End turn in view, the desktop column no wider than 600px and centred, the site keeps at least 40% of its contrast left and right of the fight and in the header (was 0 on the Trail, about 22% on the page; now 55%), Escape x3 keeps the fight, a reload lands on it, End turn on desktop. Screenshots before/after in `claude/reviews-2026-11-13/layout/`.
- **A creature's bar is its Yield (no more creature "HP" in the new fights).** The one shared bar that Hurt and Charm both fill is now called **Yield**: the creature yields when it is full (backed off by hurting, won over by charm). New-rule fights read `Yield 23/40` (label and `title`: "Yield 23/40: hurt 15, charm 8"), "Yield bar" in every sentence (bar tip, first-turn hint, help sheet row, Bramble and Thornburst text, plan line "Yield 12 → 23 of 40 (hurt +11)", history chips "+15 hurt" and "Yield +3" for an environment piece, lit-spot aria "N hurt"); never "health", "HP" or "damage bar" for the creature. Fights that started under the 2.6.94 rules (`V1.onebar` 0) and old non-v1 fights keep their old words ("Creature health", the Charm bar, "-7 hp"). The almanac's creature line no longer shows the old HP: with puzzle fights v1 on it shows "Yield bar N", the bar a new fight against that creature starts with (size and level only: `pfb_yield_max`, the same number `pfb_new` makes), else the old "health N". The old legacy fight card and stage (non-puzzle fights) still show creature HP, because those fights still use it. The word is one constant, `PF_YIELD` (`game/includes/pfboard.php`), sent to the board script as `yieldw` and read as `YIELD` in `tools/pfboardv1_part.js` (`game/assets/pfboardv1.js` rebuilt); your own health stays "HP". Tests: new `tests/pf_yield_text.php`; `pfboard_v1_page.sh` and `pbox_v1_shots.js` expectations changed from "Bar N of M: damage D, charm C" to "Yield N of M: hurt D, charm C" and "The bar" to "The Yield bar".
- **Every piece type says what it does, in one short sentence (notation pass).** Soothe said nothing: it now reads "Its next hits do 4 less damage in all" (the creature's next Hurt pieces are cut by its number, whatever it plays that turn). New `PF_TYPE_TEXT` / `pf_type_text()` in `pfight.php` give every type its line (Hurt and Charm fill the Yield bar, Guard blocks, Heal and Item heal you, Trick boosts the Hurt or Guard fired right after it), shown on the v1 piece detail sheet (Puzzle box), the fight's piece card and the hand. Tag texts are rewritten in a new table `PF_TAGS_V1` (`PF_TAGS` keeps the old words for strip fights and for the pages with the v1 setting off, which stay byte for byte as they were): **Heavy** has no rule on the board (it only exists in old strip fights), so the card says "a big hit, nothing extra" and the old table keeps the rule for strip fights; **Trip** and **Lull** say "the creature skips its next turn" (it plays one piece a turn, so one fewer is none); Hold, Thorns, Bash, Evade, Hum, Bond, Pluck and Poison say exactly what the engine does; `PF_SPECIAL` explains Snack and pal pieces; `PF_MODS_V1` fixes four upgrade lines; the creature's Heal tag says it empties part of its Yield bar. The Puzzle box no longer shows "stays 4 rounds" for Hold or Teamwork on a piece (every piece stays 3 rounds and Teamwork is off in a new fight). New `tests/pf_piece_text.php`: every type, tag, special and upgrade has a text under 70 characters, none says "health" for a creature bar, Soothe names its effect, and the box script mirrors the PHP table.
- **A new fight no longer shows the old, finished one (owner: "I started a new combat after winning an old one. This always happens when encountering a new combat, resolves on refresh").** Cause: the frozen copy of the fight that 2.6.79 lays over the page while a turn is swapped in (`ghostSnap` in `tools/pfboardv1_part.js`, built into `game/assets/pfboardv1.js`) was taken on EVERY form sent from the fight, the result card's Collect the reward / Continue and Run too, and then waited 15 s for any new `#pfight` to appear. The page after Collect has none, so it kept waiting; the next encounter's pre-fight screen carries the placeholder `<i id="pfight" hidden>` (`pfv_assets()`), so the frozen finished fight (its board, R7 · over, "It is over", the result card) was laid over it, `position: fixed`, and never taken away (only a board script removes it, and none runs there); a reload drew the page afresh. Now only a turn's forms (play, pass, flip, redraw) take the copy, only a new BOARD fight gets it, the wait ends with the in-place swap that answers the form (`gv:swapped`), and a copy is never left up for more than 8 s. Plain adventure page and the Trail dialog alike. **Not new in 2.6.95:** the same test fails the same way on 2.6.94 (the copy dates from 2.6.79). New test `tests/pfv1_newfight.sh` (+ `.js`): fight A won (a charm win played in the page, a hurt win replayed on load) and collected, fight B met and started, all in one document, plain page and Trail modal: no copy of A, no "It is over", no result card, B's creature, bar at 0, turn 1, a hand of 5, no console error, and the fight area reads as after a reload (failed 8 checks before the fix, passes after).
- **The puzzle pieces got a beauty pass, and the creature's pieces have symbols now (owner: "On desktop pieces look bad still. Give a beauty pass, Aseprite pipeline, for all pieces and symbols", "Need symbols on enemy pieces").** What looked bad on a desktop: the 82 x 73 piece picture was stretched by 1.2 (1280 x 720) or 1.7 (1440 x 900) without smoothing, so pixel rows and columns came out uneven and the digits broke; a phone shows it at exactly 3. The felt grain read as dirt, the number sat on a black rectangle in doubled 3 x 5 figures, a creature's piece was a hue-shifted blank with only a number (its tint made the renderer treat it as an environment piece: no glyph, no eye), and an environment piece was a tinted tile with a black disc and a vector icon painted by the page. Now: a new kit drawn in Aseprite, `aseprite-source/pfight/v48/` (Lua sources, sheets, check script, README), built by `tools/build_parts48.py` into `assets/img/pfight/parts48/` (40 KB of sheets). **My pieces:** clean face with a bevel and a glint, redrawn glyphs (sword, shield, cross, heart, leaf, sparkle, flask). **The creature's pieces:** their own dark red body with teeth and the eye, and a glyph per type in other shapes, so the owner reads without colour (claw marks, spiked shell, drop, paw print, moon, bolt, bone). **The environment's pieces:** parchment with a dashed stitch in the kind's colour and a drawn glyph (sun, bramble, rain, wind, mud, thornburst; Wind and Mud still draw for old fights). **The number:** figures drawn at 6 x 10 on a drawn plate. **Crisp at every size:** `assets/pfparts47.js` redraws each piece picture for the exact number of screen pixels it is shown at (whole scales keep the pixel art; other scales use the nearer of the two drawn sizes, 82 x 73 or 140 x 124, enlarged by a whole number and then brought to size), without moving the layout. The piece edge is v47's, unchanged (knobs, holes, sizes, hit areas; the atlas keeps `"version": 47` and adds `"art": 48`). `pfight_jigsaw = 47` goes back to the first jigsaw art, `0` to the old pieces. New test `tests/pfparts48.sh`; before / after sheets in `claude/reviews-2026-11-13/art-pass/`. **Not done:** the 14 icons of named pieces (Jab, Smash, Pierce...) are the old drawings; a creature's named piece shows the creature glyph of its type; the creature's own colour is no longer on its pieces; the blank centre piece and the lit-spot outline are still painted by the page; between 1.05 x and 1.4 x the pieces are clean but have soft pixel borders. No DB change.

## 2.6.95
- **Puzzle combat v1, week 1 of the review plan: fewer rules, honest numbers, a shorter wait.** Built from 30 haiku playtests, three Opus reviews (balance levels 1-10, creature difficulty, creature strategy) and four Fable reviews (rules, turn flow, deck and pieces, a no-holds critique). Reports and the plan are in `claude/reviews-2026-11-13/`. New v1 fights get the new rules; a fight already under way keeps the rules it started with (every cut is a key in the fight's config, read through `pfb_v1r`). The bullets below are the tasks T1-T13, newest first, plus the earlier small items.
- **Needs 2.6.93+, no DB change. Puzzle combat v1 is still admin-gated (`pfight_v1`).**
- **Week-1 retune of the size numbers (T13 of the puzzle-combat plan).** Only the size factors move: `PFB_V1_FOE_MULT` small / medium / large / boss 0.95 / 0.60 / 0.42 / 0.585 -> 0.855 / 0.48 / 0.378 / 0.585 and `PFB_V1_BAR_MULT` 0.828 / 0.994 / 1.15 / 0.611 -> 1.325 / 1.491 / 1.495 / 0.825 (PHP and `tools/pfengine.js`); `PFB_V1_LEVEL`, `PFB_V1_ONEBAR_BAR` (1.15) and boss Charm (0.6) unchanged. Why: the week-1 rules (one bar, redraw, aim total, free pass) had made the chain bot 95 / 92 / 90 / 91% at level and fights 4.1 / 5.3 / 6.4 / 6.5 turns; creatures now hit softer but last longer. Chain bot (about 210 fights per size, se 3 pp), at level / 4 under / 8 under, small / medium / large / boss: 79 / 80 / 82 / 78% at level (was 95 / 92 / 90 / 91), 68 / 37 / 60 / 50% at 4 under (was 94 / 43 / 70 / 73), 8 under 68 / 15 / 21 / 21%; turns 6.4 / 7.4 / 7.8 / 7.9 (was 4.1 / 5.3 / 6.4 / 6.5); small fights of 1-2 turns 4% (was 25%); dead turns 0.6-1.6% (was 1.2-3.3). Look bot 100 / 100 / 100 / 100% at level, health lost 15 / 17 / 17 / 20%, turns 6.3 / 6.9 / 7.0 / 7.6; smart 100% in every size, health lost 19 / 16 / 15 / 21%; look real choice 16 / 21 / 22 / 22% (was 26 / 23 / 19 / 21), own piece at start 54 / 53 / 51 / 47% (was 60 / 62 / 54 / 55). The kind gnome (`KIT=charm`, chain bot, at level) charms 90 / 54 / 23 / 0% of its wins in small / medium / large / boss (a boss never ends charmed). Trade-off, not fixed: medium 4 under is 37 (floor 36, met) but large 4 under is 60, under the 67 floor, because every size has a steep climb between 4 under and level and 70-80% at level needs the creature about 10 pp tougher; at 8 under medium, large and boss are 15-21%. Large at level is 82% (target 70-80, within noise), medium 80%.
- **The page for the week-1 rules (T12 of the puzzle-combat plan).** The fight page now follows the rules the fight carries (the resolved `V1.*` keys), so a 2.6.94 fight under way looks and plays as before. New fights: one bar for the creature, a red damage segment then a pink charm segment, the number is how full it is (`23/40`) and the label reads "Bar 23 of 40: damage 15, charm 8" (the page and the replay move both segments; "health" is gone from the creature's texts: bar tip, first-turn hint, plan line "Bar 12 -> 23 of 40 (damage +11)", Bramble and Thornburst help, history chips "+15 damage" / "bar +12"); no set-aside row (`#pf-opts` stays only for a group already held); lit spots without must-link (the "nothing can connect" notice is off too); no Teamwork chip, hand source icon or help sentence; the End turn button says Pass when nothing is placed or picked and posts the pass form (no `id="pf-pass"` button); Flip is free any number of times (no "Flip used", no "once a turn"; the auto take-back stays for 2.6.94 fights); the help sheet lists only the environment kinds in the fight's deck (no Wind or Mud), explains the bar, and adds "A piece of the creature linked into your chain fires for the creature; Thornburst hurts whoever fires it" and "If its aim fires one of your pieces, your piece works for you"; the aim chip reads "Aims Snap: hits you for 9" with the reasons ("Sun x2, fires your Jab: 6 to it") behind a tap; after you place a piece the plan line shows the dry aim ("Its aim is broken: it will pick again" or "Its aim now hits you for 3"); the creature's guard is a chip on the status row. Also fixed: a reload after the replay had played showed the bar as it stood before the turn, and the first letters of the plan line were cut off in the fitted layout. Tests: `pfboard_v1_page.sh` (page data keys, the one bar, no Pass button, preview holds the aim), `pfv1_flip.js` (a new fight: flip A, pick B, flip B, both stay flipped; the 2.6.94 take-back is still tested on a 2.6.94 seed), `pbox_v1_shots.js` (a new-rules fight and its help sheet); `pbox_v1_seed.php` takes `PBOX_RULES=new`. The demo's fight view has the same bar, pass and flip changes.
- **The aim shows its total (T10 of the puzzle-combat plan).** New v1 fights get `aimtot` = 1: `pfb_aim_total($s)` dry-runs the creature's committed move on a copy (`aimforce`, its first piece, exactly as `pfb_foe_turn` plays it) and returns `hp` (health you lose through your guard), `g` (your guard it eats), `bait` (damage to the creature from YOUR pieces its chain fires), `heal`, `n` (pieces fired) and `why` ("Sun x2", "combo Ambush", "fires your Jab", "fires Bramble", "Quick: plays again", "Mud -25%"); it is stored as `plan.tot` at intent time (`pfb_intent`) and rides in the view's `aim`. `pfb_play(..., dry, withAim)` adds `aim` to a dry result: the total after your placement, or `{broken: 'cell'|'edge'|'slow'}` (your piece on its cell; its edges no longer fit, e.g. use-up took what the cell touched; it loses its turn); `pfight_preview_out` returns it. `status.foe_block` shows the creature's guard. Not computed inside `pfb_cell_preview` (the lit cells keep no reply number). The `tests/pf_play.php` CREATURE AIM line now says "hits you for H (why: ...); your pieces it fires deal B to it". PHP `pfboard.php` and `tools/pfengine.js` together (parity runs the dry total); fights saved under 2.6.94 keep `aimtot` 0 and show none. The page does not show it yet. Tuner: new `aimgap` line (mean |shown total - actual| on unbroken aims) is 0.00-0.11 health in every size and bot (558 to 998 aims per cell for chain; look and smart 0.00-0.11), against 1.0 allowed; the piece value it showed before the total was 0.0-2.5 off in the mean there. No balance change, chain bot at level 95 / 92 / 90 / 91 (small / medium / large / boss; 4 under 94 / 43 / 70 / 73), turns 4.1 / 5.3 / 6.4 / 6.5, look and smart 100% at level: the same as after T9
- **The replay is at most 5 s, a tap skips it, reduced motion skips it (T11 of the puzzle-combat plan).** After End turn the wait with no control was 14.6 s at the median (turn-flow review; 16.3 s at 1x, 8.4 s at 2x on the 11-event test seed). Now `maybeReplay` (`tools/pfboardv1_part.js`, `tools/build_pfboardv1.py`) fits the whole replay into 4.6 s at 1x (half of it at 2x): the steps, the use-up steps and the leaving step shrink by one factor (`replayScale`, 0.1 to 1) so a long replay is faster per event instead of longer; the creature's banner is 0.7 s (was 1.5 s); there is no "Your turn" banner before your own chain (it still shows when control comes back) and no separate Environment banner (the chip still names the step; the environment places in the creature's step). Measured on the 11-event seed (Playwright, `tests/pfv1_replay.js`): control back after 4.8 s at 1x (was 16.3 s), 2.6 s at 2x (was 8.4 s), 0.14 s at skip (unchanged); a tap on the board 0.5 s in returns control in 0.02 s (was ignored: only the 48 x 34 px Skip button worked); with `prefers-reduced-motion` and no speed chosen the replay is skipped (0.13 s; the 2.6.78 note said it was, it was not), and a speed the player chose still wins. The last turn of a fight still plays in full before the result card (now 1.1 s of replay for 5 events, was 2.7 s); the 2.6.88 health numbers still walk with the replay (asserted). `tests/pfv1_charm.js`: the three checks that wanted a "Your turn" banner before the creature's now want none.
- **Full hand redraw (T9 of the puzzle-combat plan).** New v1 fights get `redraw` = 1: at the end of the round every unplayed hand piece goes to the discard (flip and `ft` cleared) and you draw a fresh hand of `PF_HAND_CAP - slow` (5, or 4 when a trip landed); Quick still draws one now. `pfb_end_round` and `endRound` in `tools/pfengine.js` change together; fights saved under 2.6.94 keep topping up the old hand. `tests/pf_play.php` prints "Your hand is redrawn every round". Tests: `tests/pfboard_v1.php` section 21 (failed before: no redraw); pinned to the 2.6.94 top-up: the trip checks in `pfboard_v1_notes.php` (line 15) and `pfdeck_v1.php` (TRIP, line 185), and the PRE-defaults list in section 16 now names `redraw`. Sims (clean worktree, T9 against T8; chain at level 95 / 92 / 90 / 91 small / medium / large / boss against 94 / 89 / 87 / 86, 4 under 94 / 43 / 70 / 73 against 89 / 46 / 67 / 77; turns 4.1 / 5.3 / 6.4 / 6.5 against 4.7 / 5.9 / 7.0 / 7.2; health lost 37 / 54 / 57 / 65% against 43 / 55 / 59 / 67%; look 100% and smart 100% everywhere, look turns 3.6 / 4.7 / 5.6 / 5.8 against 4.0 / 4.9 / 6.2 / 6.2; look health lost 12 / 17 / 16 / 19%; dead turns of the chain bot fell from 3.2 / 2.0 / 0.9 / 1.1% to 1.3 / 0.8 / 0.4 / 0.7%; own-piece-at-start of the chain bot is 49 / 40 / 33 / 29% against 45 / 38 / 32 / 29% (look bot 70 / 60 / 54 / 52%); real choice with `CHOICE=1` look 19.5 / 23.9 / 21.6 / 22.3%). Chain is up 1-4 pp and fights are about 0.6 turns shorter; nothing is retuned here (medium sits at 92%, the retune T13 comes after T10).
- **One shared bar (T8 of the puzzle-combat plan).** New v1 fights get `onebar` = 1: the bar is today's length x 1.15 (`PFB_V1_ONEBAR_BAR`), Hurt adds to `fh.now` and Charm to `bar.now` (both counters stay), the fight ends when `round(fh.now + bar.now, 1) >= fh.max` (the 2.6.78 one-decimal rule holds for the sum), and the ending is `charmed` when Charm is the larger share and the creature is charmable (cm > 0, not a boss), else `seen_off`. A boss takes Charm at x0.6 (`PF_HOSTILE_CM`) but is always seen off. Heal and guard already touched only `fh.now`, so Charm stays immune to them. `pf_check_end`, `pfb_new`, `pfb_view` (`onebar`, `charmable` false for a boss) and `tools/pfengine.js` together; a fight saved under 2.6.94 keeps two bars. Page (minimum): the creature bar shows the shared bar (Hurt + Charm) and the separate charm bar is not drawn; full UI polish is left for T12. Harness `tests/pf_play.php` prints a BAR line. Tuner: `KIT=charm` (one Hurt, seven Charm) and an `endings: charmed N% of wins` line. Sims: Sims (clean worktree, chain bot, small / medium / large / boss): at level win 94 / 89 / 87 / 86 % (T6: 87 / 86 / 87 / 87), turns 4.7 / 5.9 / 7.0 / 7.2; 4 under 89 / 46 / 67 / 77 % (T6: 73 / 38 / 67 / 77). Look and smart 100 % (look 4 under medium 95 %). Look charmed share of wins at level 24 / 9 / 2 / 0 %. Deck of 1 Hurt + 7 Charm (look): 100 % wins, charmed share 82 / 65 / 35 / 0 %, large turns 15.1 -> 9.9. Chain at level small 94 % is over the plan's 92 % line: retune in T13.
- **Flip without a limit (T6 of the puzzle-combat plan).** New v1 fights get `flip1` = 0: any hand piece with edges may be flipped, any number of times, and flipping stops setting `flipt` / `ft` (the view's `flip.used` stays false). PHP `pfb_can_flip` / `pfb_flip` and `tools/pfengine.js` together; fights saved under 2.6.94 keep one flip a turn. The page's take-back-the-flip on picking another piece (`unflipPrev`) does not run when the server says `flip1` is 0. Sims (clean worktrees, T7 against T6): identical to the decimal, because the bots flip only the piece they place (chain at level 87 / 86 / 87 / 87 small / medium / large / boss, 4 under 73 / 38 / 67 / 77; look and smart 100%; flips per fight 1.3 / 1.6 / 1.8 / 2.1), so the rule only widens what a person can do.
- **Set-aside, must-link (you) and the refused pass are off in a new fight (T5 of the puzzle-combat plan).** New v1 fights get `aside` = 0, `must` = 0, `freepass` = 1 (PHP `pfb_play` / `pfb_must_link` / `pfb_pass` and `tools/pfengine.js` together). A new fight refuses `j`, `h` and `c` with "Those moves are not valid." (a saved fight that already holds a group can still add to it and play it); you may put a piece on any cell where it fits (the creature still has to link); you may pass whatever fits, and a pass now clears `lastfoe` and `gone` like a play does (2.6.88). Fights saved under 2.6.94 keep all three. `tests/pf_play.php` join / add / group answer "Not in this fight."; the parity run (`tests/pfengine_js.php`) offers set-aside only where it is on, passes now and then, and has a new 2.6.94 builder mode (`v1preb`). Pinned to `V1_294`: the flipped-pass check and the two Mud "spots that only touch Mud" checks (`must` 1). Sims against T4 (same seeds): chain at level 86 / 82 / 85 / 86 (small / medium / large / boss) and 4 under 73 / 37 / 65 / 71, all identical to T4; look and smart unchanged (100%, health lost smart 12 / 15 / 14 / 18% against 10 / 13 / 12 / 17%); the careless bot's environment health loss is the same (12 / 19 / 28 / 28%); placements per turn 14.1 before and after (the 4x4 board almost never hides a fitting cell behind a link); tuner speed: smart is about 1.8x faster (no join candidates, 5.7 s against 10.4 s a shard).
- **Puzzle box: the harmony meter is out, Bold is the default kit, every kit holds 4 Hurt (T7 of the puzzle-combat plan).** `pfd_harmony` and the `harmony` key of `pfd_deck` are gone; the deck bar shows one line "Hurt pieces: N of M" (hint "Few Hurt pieces: fights will be long" under 3 in 10) instead of the Teamwork row and the Link rate / Knobs meters. `PFD_KIT_DEFAULT` is `bold` (a gnome with no starter plays Bold). Steady is now CALLING, Jab, Swing#2, Pierce, Brace, home region piece; Kind is CALLING, Jab, Swing#2, Pierce, Hum, Soothe (with the core Swing that is 4 Hurt each; the offer has exactly 4, so the custom minimum goes from 2 to 3: "Bring at least three Hurt pieces."). Saved starters are untouched. The starter pick (`pfv1box.js`), the demo (`pfd.js`, `views.js`, rebuilt `pf-demo-v1.html`) follow. Sim, creature levels 1-10 (small and medium only), tuner kits rotating bold/steady/kind by level, against base0: chain win at level 84 / 72 -> 86 / 78 (small / medium), 4 under 68 / 20 -> 73 / 22, turns 6.0 / 6.9 -> 5.1 / 6.3 (at level) and 5.2 / 6.8 -> 4.4 / 6.1; look 100% everywhere, health lost at level small 12 -> 16%, turns 5.5 -> 4.6; smart 100%, turns 4.3 -> 3.8. T13 retunes.
- **Teamwork, per-piece life, Wind and Mud are off in a new fight (T4 of the puzzle-combat plan).** New v1 fights get `team2` = `team3` = 1.0, `life` = 0 (every piece stays 3 rounds) and `nowm` = 1 (`pfb_env_deck($size, $region, $nowm)` / `envDeck` drop Wind and Mud after the region leans, so NA and SEA no longer lean toward them; small deck 8 -> 6 pieces). A fight saved under 2.6.94 keeps its saved cfg, so it still has Teamwork 1.3 / 1.6, life 2-4 and its old deck; all the Wind, Mud and Teamwork code stays for those fights. PHP and `tools/pfengine.js` change together (parity 704 fights, now with the 2.6.94 set too). Tests pinned to `V1_294`: Teamwork (section 6), piece life (section 9), the whole-fight run (section 11, which needs Wind and Teamwork to occur), the environment section (decks and the Teamwork and life checks), the two life checks of `pfdeck_v1.php` (layered deck, hold/quick life) and the seeded fights of `tests/pbox_v1_seed.php` (the page does not know the new rules until T12). New section 17 of `tests/pfboard_v1.php`. Sim, engine change alone against base0 (chain, 24 seeds a creature, at level / 4 under, win %): small 84 -> 86 / 68 -> 73, medium 76 -> 82 / 32 -> 37, large 83 -> 85 / 70 -> 65, boss 90 -> 86 / 75 -> 71; turns about the same (6.0-7.4 at level). Medium (+6) and boss (-4) are over the plan's 3 pp. Look 100% and smart 100% at level; look 4 under medium 95 -> 97, smart health lost 9-13 -> 10-17 %. Environment pieces placed per fight (chain, at level) small 10.0 (as before), medium 11.4 -> 11.1, large 13.5 -> 12.7, boss 12.7 -> 12.6; the tuner's env cost to the chain bot's health 9 / 18 / 23 / 23 % -> 12 / 19 / 28 / 28 % (large and boss +5 pp: for T13).
- **Compat framework for the coming board rules (no behaviour change).** `PFB_V1_PRE` (aside, must, freepass, flip1, nowm, redraw, onebar, aimtot, keepmine, aimhit, useroot, kinds) is the 2.6.94 rule set; `pfb_v1r($s, $key)` (PHP) and `v1r` (`tools/pfengine.js`) read a key and fall back to it when a saved fight has none, so old saves keep playing as they did. `pfb_v1_cfg` / `v1Cfg` carry the keys with new-fight defaults equal to PRE for now (each later task flips its own), and the view emits them resolved. Sim: `chain 0 MULT 0.25` is byte-identical to HEAD, and all 252 rows are in `base0`. Tests: `tests/pfboard_v1.php` section 16 (failed before: no `PFB_V1_PRE`), `V1_294`, and a `v1pre` mode in `tests/pfengine_js.php` so parity covers both rule sets.
- **Tuner: per-row identity and three new metrics (`tests/pfboard_tune_v1.php`).** Rows carry `slug`, `class`, `clv`. The table adds, per size (`CLASS=1` groups by creature class): `dead %` (turns where no legal action moves the creature's health or bar, adds guard or heals), `own-piece-at-start %` and, with `CHOICE=1` and the look bot, `real choice %` (top 6 actions by 1-ply value, each scored with the smart bot's two-turn formula; real = the best action beats the best one with a different hand piece by at most 10% of the span, span >= 0.02) and `ply-flip %`. Sims and win numbers are unchanged (chain at level is identical to before). The tuner also reads the coming `onebar` and `aside` rules when the engine has them. New test `tests/pfboard_tune_v1_metrics.php` (failed before: no `tv_real`). Baseline `base0` (HEAD 3e76b2f4), look at level, 24 seeds a creature/2: real choice small 26 / medium 23 / large 19 / boss 21%, ply-flip 28 / 30 / 33 / 25%, dead 4.2 / 1.4 / 0.8 / 3.0%, own piece at turn start 60 / 62 / 54 / 55%. The sim runner is `scratchpad/plan/sim.sh`.
- **The playtest harness `tests/pf_play.php` deals the real decks.** Before, `new` gave the creature the archetype deck (Lunge, Snap, Brace, Feint, Recover for all 88 creatures, no class piece or tag) and the player the old stage A deck (no kit, tool, pal or crop piece), so the haiku playtests never met poison, trip, evade, bash, thorns, quick, Teamwork or a kit. Now the creature is `pfd_foe_row` in a region that follows the seed (or the REGION arg) and the player deck is the deck model's, as the live game and `tests/pfboard_tune_v1.php` deal them. Arg 8 `old` keeps the old decks. The piece lines show `layer:` (base, reg, rar, uni). New test `tests/pf_play_decks.sh`. Earlier playtests must not be cited for creature identity, Teamwork or kits. The sims were not affected.
- **Pick a different piece after flipping and the flip is taken back by itself (Josh).** The flip you used this turn goes back on its own when you pick another hand piece, so the flip is free again for the piece you picked. Deselecting the flipped piece keeps its flip. Source `tools/pfboardv1_part.js` (`unflipPrev`) and one replacement in `tools/build_pfboardv1.py`; `game/assets/pfboardv1.js` rebuilt. New browser test `tests/pfv1_flip.sh` (fails without the change).
- **The creature's shown aim now holds (AIMSTICK).** Before, the shown aim did not happen on 44-51% of creature turns: usually a use-up chain had removed every neighbour of the aimed cell, and a piece must touch something. Now the aim lands on its cell anyway. Only two things make the creature pick again: you put a piece on that cell, or you put a piece next to it whose edge does not fit. Broken aims (chain bot at level) fell to 6-8% for medium, large and boss creatures and 11% for small ones. `pfb_check` and `check` in `tools/pfengine.js`. Regression check in `tests/pfboard_v1.php` section 5; it failed before the fix. The parity test fails if only the PHP side has the fix.
- **One level curve for creature strength, plus a boss retune (v1 fights).** `PFB_V1_LEVEL` uses f = clamp(1 + slope x (level - ref), lo, hi). The creature's piece values are multiplied by f and its bar by min(1, f), so a weak creature also has a shorter bar, and a strong one only hits harder.
  - Medium: [0.05, 12, 0.85, 1.35]. Large: [0.025, 22, 0.85, 1.10]. Small and boss: flat.
  - Boss: piece values x1.3 (0.45 -> 0.585) and bar x0.8 (0.764 -> 0.611). This makes up for AIMSTICK, which on its own took the chain bot to 94% against bosses.
  - This one curve replaces two earlier proposals: balance "r4" (medium levels 5-9 only) and difficulty "Proposal A" (medium, large and boss by level).
  - A fight already under way keeps its numbers, because they are stored in its state.
  - Changed in PHP and the JS port together; `tools/pfdemo_v1/views.js` now passes the creature level.
  - Results: chain bot at level, win %, 24 seeds per creature, 4 shards:

    | | small | medium | large | boss |
    |---|---|---|---|---|
    | before, at level | 84 | 77 | 82 | 88 |
    | after, at level | 83 | 79 | 85 | 88-92 |
    | before, 4 under | 72 | 37 | 62 | 76 |
    | after, 4 under | 69 | 36 | 67 | 73-78 |
    | before, 8 under | 72 | 13 | 34 | 50 |
    | after, 8 under | 69 | 11 | 31 | 50 |

  - By 5-level creature band, chain bot at level:
    - Medium: was 58 / 60 / 89 / 94 / 96 / 96, now 62 / 77 / 84 / 76 / 83 / 79. The 1-5 band is orb-spider alone, n=24.
    - Large: was 57 / 77 / 87 / 87 / 86 / 83, now 83 / 87 / 85 / 83 / 84 / 85.
    - Boss: lv 26-30 was 90, now 92 (driven by individual bosses, not level); lv 31-35 was 81, now 76.
  - Boss fights are shorter: 8.7 -> 7.6 turns at level.
  - Look and smart bots: still 99-100% wins, health lost unchanged (look 12-15%, smart 10-14% at level).
  - Test expectations changed for this retune, in `tests/pfboard_v1.php` section 10: the bar and piece-value checks per size now include the level factor, and the foe_x / bar_x knob check applies the curve. New checks for the curve itself.
  - Not verified: real players, the live MySQL game and phone play. Bot sims only.
- **Playtest harness (`tests/pf_play.php`) output is clearer** (no engine change): notice lines are readable, refusals say why, each event shows its real change, no stale cells after the fight.

## 2.6.94
- **4x4 is the board for every creature size (Josh: "make 4x4 the board size going forward").** `PFB_SIZE` is 4x4 for small, medium, large and boss (engine, JS port, parity test). `?pfboard=WxH` and the `pfight_board_test` setting still override. Tests moved to 4x4 seeds. Foe/bar multipliers were tuned per size: re-check balance.
- **Needs 2.6.88+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.93
- **A test board for the puzzle fight (Josh: "give me a version with a 4x4 board to test").** `adventure.php?pfboard=4x4` (any size from 3x3 to 9x9; `?pfboard=off` clears it) makes every puzzle fight you START afterwards use that board, whatever the creature's size; a fight already under way keeps its board. It lives in your session; the setting `pfight_board_test` (for example `4x4`) does the same for everyone. With nothing set the boards are as before (small 5x4, medium 5x5, large 7x5, boss 7x6). Checked in the real game: the four creature sizes on a 4x4 board play to the end with no errors, and the board fills the screen with larger pieces. `pfb_v1_cfg` in `includes/pfboard.php`, the toggle at the top of `adventure.php`.
- **Needs 2.6.88+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.92
- **The set-aside choices are in two rows, no scrolling, on desktop and mobile (Josh).** The choices beside the piece card are a grid of two rows that gains a column for every second choice (1 or 2 choices: one column; 3 or 4: two; 5 or 6: three). The two rows share the card's height, so the row is still exactly as tall as the card and the board never changes size; a single choice is one centred button. Nothing scrolls, nothing is clipped, nothing overlaps (checked with 1, 2, 3, 4 and 6 choices at 390 x 844, 360 x 640 and 787 wide: always two rows, every button inside its box, no overlap, board height unchanged). The "Or set aside with:" label is gone (each button starts with "+" and the hint line under the card says it). When the card is narrow beside three or more choices on a phone, its chips go and its picture is smaller, so the name and number stay readable.
- **Needs 2.6.88+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.91
- **A pal's delve re-run runs on Game Time (Josh: "the delve option runs in real time and should run on Game Time").** Pal work already waited for sleeps (real seconds are pushed back onto every running job, a sleep brings them closer by `pal_hours_per_sleep`), but `gclock_shift_pal_clocks` left delve re-runs out, so they kept counting real seconds. They are in now, like trips, shifts and garden stays: real time does not bring the pal home, a sleep does (8 game hours by default; a one-hour delve is home after one sleep). Delves already running when this goes live join the same clock from the next page load. Two new checks in `tests/game_clock.php` (a sleep moves a delve 8 h closer; 2 real hours are pushed back onto it); `tests/paljobs.sh` and the whole game-clock suite pass.
- **The set-aside choices are tidy and never overlap (Josh).** Each choice is one short line, the piece's name and an arrow for the side (for example "+ Rest →"); the long words ("to its right") are in the button's title and aria-label. They sit in one column in their own box beside the piece card, each 32 px high and aligned; the row is exactly as tall as the card, so the board never changes size when choices appear, and if there are more choices than fit they scroll inside their box (a swipe). Checked with 1, 3 and 5 choices at 390 x 844, 360 x 640 and 787 wide: no overlap between the buttons, none with the card or the rows below, no sideways scroll. The text for the new board is set in `tools/build_pfboardv1.py` (the old board's `pfboard.js` is untouched).
- **Needs 2.6.88+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.90
- **The piece card was too large (Josh).** The picture of the picked piece in the card under the board was the hand-size art (140 x 124 now) forced into the old 1.43 box at 140 px wide: big and squashed. It is now a small picture, 62 px wide, in its own proportion (`pfv1.css`, jigsaw only). The Puzzle box detail sheet already kept its proportion.
- **The piece card and "Or set aside with" are one row, side by side (Josh).** The card (picture, name, chips) takes the left, the set-aside choice sits to its right (the label over the button); with no set-aside choice the card has the whole row. The choice never grows taller than the card's row. `tests/pbox_v1_shots.js` no longer counts it as its own row.
- **The top of the fight is less busy (Josh: "very busy").** The chip row above the board is one line instead of two: the chain is just its dots (the word stays in its title), Teamwork shows only when the planned chain has it (the rule stays in the help sheet), the two tool-durability chips are one chip with the number of tools (the durabilities are in its title), and the status words are shorter ("dodges next hit", "tripped −1 draw", "you dodge next"). The environment chips of the last-plays strip are icon-only (their words stay in the title and aria-label), so the creature's chips are in view. The test now expects no Teamwork chip until a chain has it.
- **Needs 2.6.88+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.89
- **The pieces are jigsaw puzzle pieces now (Josh: "make them resemble puzzle pieces", "a bit more square", "centered").** New pixel art drawn in Aseprite (`aseprite-source/pfight/v47/`, with its sheet, history of the three art passes and a check script) is live in the new (v1) fight and in the Puzzle box: body 56 x 47 instead of 56 x 40, tabs 13 px deep on every side (real jigsaw tabs: Body = round head on a neck, Mind = keyhole, Craft = blunt wedge), softly rounded corners, holes that are real cut-outs so a neighbour's knob sits inside, one flat colour ramp per type with rim light and a sparse felt grain, a bigger drawn glyph exactly in the centre of the body, the number on a dark plate in the top-left corner, the life pips in the bottom-left corner (the middle of each edge is a tab), creature pieces with a red rim, thorns and an eye, environment pieces in their own hue with a dashed rim. The lit-spot ghost is a jigsaw outline too.
- **How it is wired:** `tools/build_parts47.py` turns the Aseprite files into the runtime kit `assets/img/pfight/parts47/` (sprite sheets + `atlas.json`, needs the Aseprite CLI once). The new renderer is `assets/pfparts47.js` (a copy of `pfparts.js` that uses the new kit when its atlas says version 47, the old kit otherwise); `includes/pfparts_url.php` picks the folder. The old board and `pfparts.js` are untouched. Setting `pfight_jigsaw = 0` goes back to the old pieces without a deploy.
- **The hand was stretched:** the hand shows the strip-size piece in a box made for 74 x 52; the box now follows the piece (82 x 73). Because the hand piece is taller, a tall phone has a little less spare height for it (the old test "hand pieces larger" now says "not smaller").
- **Not done yet:** the foe thorns on left/right edges, the stitch line around holes, the picked ring following the knobs, redrawn hand tabs (the hand art is not used on the board yet), the C2 layout (fewer words, one button per screen).
- **Needs 2.6.88+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.88
- **Health went up as soon as the turn was sent, not when the heal piece lit up (Josh).** The page the server sends already has the NEW health in it, and the number beside the health bar was never walked by the replay (only the bar was), so a Heal or Snack showed its effect at once. The number now follows the replay like the bar, and your health, guard and the creature's health show what they were before the turn until the replay reaches the piece that changes them. Checked frame by frame in the real game: 20 stays on screen until the Rest piece lights up, then 25.
- **The last turn of a fight replayed the turn before it (Josh).** A turn that ends the fight has no creature turn and no end of round, so the pieces the creature put down and the pieces that left in the round BEFORE stayed in the saved state and the page played them again (hidden, then revealed; shown, then leaving). They are now cleared at the start of every turn (`pfboard.php`). New `tests/pfv1_finalturn.php` (run by `pfv1_charm`) fails without the fix.
- **Needs 2.6.79+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.87
- **Debug log: the fight's numbers (`?pfdebug=1`), to chase "healing doesn't heal me" (Josh).** After every turn the log now has a `FIGHT` line (turn, your health out of its maximum, guard, the charm bar, the creature's health, and your health before the turn), the `HAND` types, and one `REPLAY` line per piece that fired with your health at that point. Checked in the real game first: Rest (+5), Breather (+4) and Steep (+8) heal on the server (20 to 25, 24 and 28), are saved to the expedition, and show on the page; a Snack piece needs a snack in the satchel and does nothing when you are at full health (by design). No game rules changed.
- **Needs 2.6.79+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.86
- **The background behind the fight pop-up blinked on End turn (Josh).** Two causes, both fixed. (1) Each turn the page around the pop-up (the Trail map) was thrown away and rebuilt from the server's copy and its map scripts started again; now nothing behind a fight is touched during its turns (`site.js` `keepTrailPop`; the status bar, user bar and message list are also left alone when their new copy is identical). (2) The margins around the fight are the fight's own dim over the pop-up window, so while the old fight was out of the way for a moment they showed the window's raw colour, about 19 brightness levels lighter; the pop-up window now has exactly the dimmed colour (`pfv1.css`, 2 levels of difference left, not visible). Measured frame by frame in the real game.
- **Needs 2.6.79+, no DB change. Puzzle combat v1 is still admin-gated. The debug log (`?pfdebug=1`) stays in.**

## 2.6.85
- **Charm bar too large on a wide window (Josh).** The bar is 8:1 and took the whole header width, so at about 790px wide it was 60px tall and dominated the header. It is now at most 320px wide (40px tall) and centred. Phones are unchanged (they were already narrower than that). The red health bar above it is unchanged.
- **Needs 2.6.79+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.84
- **End turn "reloads" the fight: found and fixed (Josh).** Recorded frame by frame in the real game: after End turn the fight panel shrank to a thin 8px bar for about a fifth of a second, the Trail map showed through behind it, then the fight jumped back to full size. Cause: every turn the swapped-in fight panel (`.encounter`) replayed a 0.25s fade-in (`pf-in`, opacity + a transform). While a transform animates, that panel becomes the box the fight is sized against (the fight is `position: fixed`), so the fight collapsed to the panel's height until the animation ended. Now the fight panel never animates in (`pfv1.css`). Also: the Trail pop-up window is solid in the fight's colour (class `pfdlg`, set by `adventure.php`), so the map can never show through while a turn is swapped in, and the frozen old fight that covers the swap is solid and sits above the new one until it is drawn.
- **A tap during a loading step no longer reloads the page (`site.js`).** From the debug log: a Trail step tapped while the last one was still loading (1 to 3 seconds each) went out as a plain post, a real page load. Now any in-place form tapped while another one is loading is dropped, as the fight's forms already were in 2.6.79.
- **Needs 2.6.79+, no DB change. Puzzle combat v1 is still admin-gated. The debug log (`?pfdebug=1`) stays in.**

## 2.6.83
- **Debug panel buttons (2.6.82) gave no sign they worked.** Copy, Clear and Off are bigger (44px) and a status line says what happened ("copied N lines", "cleared", "turning off..."). The log is a text box you can select and copy by hand if the Copy button is blocked, and Off goes back to the page without the debug address. Only loaded with `?pfdebug=1`.
- **Needs 2.6.79+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.82
- **The `bug` debug button was hidden behind the Trail fight (2.6.81).** The fight is a modal pop-up, which sits above everything else on the page and makes the rest of it unclickable, so the button could not be seen or tapped. It now lives inside the open pop-up (and on the page when there is none), and there is never more than one panel. Only loaded with `?pfdebug=1`; nothing changes for players.
- **Needs 2.6.79+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.81
- **Debug log for "End turn still reloads" (Josh).** Open the Trail fight at `adventure.php?pfdebug=1` (a cookie keeps it on for a day; `?pfdebug=0` or the panel's Off turns it off). A `bug N` button shows a log that survives a real reload: page loads (`LOAD nav=...`), `BEFOREUNLOAD`, every form send and whether it went in place or as a plain post, every fetch with its status and any redirect, the swap of the page area, `#pfight` / `#trailpop` being rebuilt, and script errors. Copy it and send it. Nothing changes for players: the file is only loaded with that cookie or address.
- **Needs 2.6.79+, no DB change. Puzzle combat v1 is still admin-gated.**

## 2.6.80
- **End turn no longer flickers the fight on the Trail (Josh: "still reloads the popover").** On the Trail the fight is shown in a pop-up window (a modal dialog) over the map. Every End turn, Pass, Undo, Flip and the final turn replaced the whole page area, which threw that pop-up away and built a new one: it closed and opened again, its dimmed backdrop redrew and the focus reset, on every turn. Seen in an emulated phone (tests/pfv1_trail.js): a close event and a brand new dialog element on every turn. Now the pop-up stays the same open window the whole fight and only what is inside it changes, so nothing closes or reopens, and the result card shows in the same window. Fights on other pages, other pop-ups and villager cards work as before.
- **A number on the Charm meter.** The meter now reads "N/100" (starting at 0/100) so you can see how close the creature is to being won over. It follows the replay as the bar fills, and reads 100/100 only when the creature is won (never before).
- **Needs 2.6.79+, no DB change. Puzzle combat v1 is still admin-gated.**
- **Tests:** new `tests/pfv1_trail.js` (run by `pfv1_charm`): on the Trail, 390x844 light and 360x640 dark, every turn type keeps the same open modal dialog (no close or cancel event, no new element, never out of the modal state), no navigation, no empty-board frame, the page scroll unchanged, and the result card shows in the same dialog. It fails on 2.6.79 (24 failures). `pfv1_charm.js` checks the Charm number (0/100 at the start, up after a charm piece, 100/100 exactly on the win).

## 2.6.79
- **"Reload still occurring when End turn" (Josh, 2.6.78 on his phone).** Cause, proved on the served v1 page in an emulated Pixel 7 with touch taps (tests/pfv1_endturn.js): nothing reloads. For every End turn sequence (a pink piece, Offer, Hum, Lull, Bond, two turns in a row, Undo, Flip, a double tap, End turn during the replay, Pass, a charm win) there was no navigation, no beforeunload, no plain form post and no console error; End turn is the fight form, sent by fetch and swapped in place. What he sees: the turn is swapped in place and for 2 frames (more on a phone: the new script has to load and draw) the board and hand are EMPTY, which looks exactly like a quick reload. It happens on every turn; pink pieces make it noticeable because the creature's answer follows. Fixed: when a fight form is sent the old fight is snapshotted (canvases copied) and shown frozen over the new fight the moment it is swapped in, and taken away when the new board is drawn (0 empty frames, was 2 per turn). Hardening in site.js: a fight form sent while another in-place load is running is dropped instead of being sent the plain way (a full page load), and an error after the swap can no longer fall back to sending the form again. Flag-off pages are untouched.
- **Environment pieces land away from the action, always two (Josh: "Environment pieces land near and sometimes just one"; he meant empty spaces with NOTHING connecting).** 2.6.78 only avoided links, so its pieces still touched the action, and a piece that fitted nowhere made it place one (1.2-2 passes a fight). Now each piece goes on an ISOLATED empty cell (no piece on any side), one of the 3 farthest from every piece on the board (the first environment piece of the turn counts), drawn by the seed so replays match; if no isolated cell exists: a fitting cell that links to nothing, then any fitting cell; it passes only when nothing fits or the board is 70% full ("The board is full: the environment keeps N."). Passes are now 0.00-0.07 a fight. Anyone can link to such a piece later by placing next to it. Help text: "The environment drops its pieces on empty spots away from the action". Because the creature now reaches them as often as you do, the sims fell (chain 51%): retuned the creature's piece values (x0.95 / 0.60 / 0.42 / 0.45 by size, was 1.0 / 0.67 / 0.53 / 0.66) and its bars x0.92. Sims at level (210 fights per size): chain 74 / 70 / 68 / 71%, look 100%, smart 100%, fights 4.3-8.5 turns; you fire 2-6.5 environment pieces a fight and the creature 1.7-5.8 (1-2 before).
- **Needs 2.6.78+, no DB change. Puzzle combat v1 is still admin-gated.**
- **Tests:** new `tests/pfv1_endturn.js` (run by `pfv1_charm`): emulated Pixel 7, touch taps, 12 sequences; asserts the same document, no navigation / beforeunload / plain submit / failed request / console error and no empty-board frame. It fails on 2.6.78 (2 empty frames per turn).

## 2.6.78
- **The "quick page reload after a pink piece" and the end of a fight (Josh).** Cause (reproduced in a real browser, tests/pfv1_charm.sh): nothing reloads the page; the fight page is swapped in place. But a charm piece that fills the bar ends the fight, and the page then (1) laid the result card over the board at once, so the replay of your last turn ran invisibly underneath, and (2) on every fight turn after the first it did not even run the replay: the replay was remembered by "fight + turn number", and the turn number does not move on the turn that ends the fight, so the page thought it had been played. To the player that is a board that vanishes and a result that appears: "a quick weird reload". Fixed for every ending: the last turn is replayed IN FULL (your chain, the creature's answer, the environment, the bar filling or your health falling, the banners), and only then the result card fades in. A lost fight (and one that runs out of turns) now waits like a won one: it shows the lost card with a Go home / Continue button after its replay (before, the result was only a card on the next page, without a replay). Skip (tap), animation speed 2x and skip, and reduced motion still shorten or skip it; a page reload after the end lands on the result at once. Flag-off pages are untouched.
- **The charm bar fills, the fight does not end (Josh).** Cause: the bar and the engine disagreed at the edge. The engine compared the exact number (20.66 of 20.7 is not full) but the replay, the page and the tip showed it rounded to one decimal (20.7 = full) and drew the pink fill up to 99.9%, which looks full; the fight then ended on the next charm piece. Now the engine compares the numbers as they are shown (one decimal, for the creature's health too), the page draws the fill at most 96% until the fight is won (full only when it is), and the tip shows the real numbers. Engine PHP and JS identical (tests: a full bar with the fight still on is a failure in every whole fight, PHP and JS).
- **The environment puts its pieces on spaces that connect to nothing (Josh: "Environment should try playing on two spaces that don't have anything connecting. To help keep things varied").** Each of its 2 pieces a round is placed on a free cell where it fits but forms no link (no knob in a matching hole); only when no such cell exists for that piece does it take any fitting cell, as before. Replaces "a linking cell is preferred". Everything else is unchanged (pass when nothing fits, the 70% board cap, the seeded draw so replays match). Sims at level (200 fights a size): chain bot 68.5% to 66.3%, look 97/93/96/100 to 98/94/98/100, smart 100%, fights 5.1-8.0 turns; you still fire 5-9 environment pieces a fight, the creature 1-2 (was 0.8-1.2): later pieces link to them. The Environment help text says it. Not retuned.
- **Needs 2.6.77+, no DB change. Puzzle combat v1 is still admin-gated; flag-off pages are byte for byte those of 2.6.73.**
- **Tests:** new `pfv1_charm` (Playwright on the served v1 page: charm pieces over several turns, a charm win on turn 1 and on a later turn, a defeat, speed skip, Skip, reload after the end; asserts no navigation, no plain POST, no failed request, no console error, banners and the bar reach full BEFORE the result card; FUZZ=1 plays real seeded fights), `pfboard_v1` (11b: the shown bar and the engine agree, a charm-first player in 60 fights; env placement unlinked first and the fallback), `pfengine_js` (the same invariant in JS, 660 fights parity).

## 2.6.77
- **Fight screen: nothing is stretched any more (Josh: "squash look shit").** Cause: 2.6.76 let the board's ROWS grow up to 2.6x taller than the piece art on a tall phone, so the cells were tall rectangles and the pieces looked stretched. Reverted: the board keeps the art's own proportion (a cell is the piece body, 56 x 40) and is scaled up or down uniformly, as large as the width and its share of the height allow. The spare height of a tall phone now goes to things that are correctly proportioned: the hand pieces are larger (scaled as pictures, up to 1.5x, all still in view), buttons are 44 to 48px, the rows get even gaps, and what is left is split over and under the whole block (no one dead band).
- **The piece card never covers the board.** It is a docked card in the flow between the board and the hand (at least one line high even on a small phone; the extra height of a tall phone makes it roomier). A picked hand piece or a tapped board piece shows its info there; a second tap on the same piece, or the X, clears it. It is cleared when a turn replay starts and does not open during one; during a replay the card shows the current step ("Creature's turn: ..."). With nothing picked it shows the last plays and what the environment places next.
- **Your guard fades when your turn starts, unless Hold keeps it (Josh: "my block should drain at the start of my turn").** Engine (PHP `pfb_end_round`, JS `tools/pfengine.js`): a Hold guard no longer comes back at full size when the creature's hits already used it up (it keeps what is left, once); a plain guard, Rain's guard and the set-aside bonus fade as before. New notices 'guard fades (-N)' and 'Hold kept N' (events `note` fade / hold, shield shows the value from there on), the shield's tooltip and the help say the rule. Fights over 2.6.74 terrain too; flag-off fights untouched.
- **Needs 2.6.76+, no DB change. Puzzle combat v1 is still admin-gated; flag-off pages are byte for byte those of 2.6.73 (checked).**
- **Tests:** `pbox_v1` browser pass (every cell has the art's proportion within 2%, every piece picture its own aspect ratio, at 412x915, 390x844, 360x640, 1280x720, light and dark, 5x4 / 5x5 / 7x5 / 7x6; the card never meets the board's box, replay shows no card; buttons 44px+; no scrolling), `pfboard_v1` section 15 (guard rules, notices) and a whole-fight invariant (guard at the start of each of your turns is only what Hold keeps), `pfengine_js` parity.

## 2.6.76
- **Puzzle combat v1 (admin setting `pfight_v1`, flag-off pages byte for byte the pages of 2.6.73, checked): the fight screen uses the full height (Josh's phone test of 2.6.75).** Cause of the empty bands above and under the board: a wide board (7x5, 7x6, 5x5) on a tall phone is limited by the WIDTH, and `fitBoard()` kept the pieces' own proportion, so the rest of the height was dead space (the board centred in its room). Now the board takes ALL the room: its rows grow taller than the pieces' proportion (up to 2.6x, the pixel art takes it), a board limited by the height gets narrower instead. Measured at 390x844, 360x640, 412x915 and 1280x720, every board size, light and dark: no gap over 24px between the header, chips, board, Next strip, hint, buttons and hand, the board is at least 45% of a tall phone, the page never scrolls. `assets/pfboardv1.js` (built from `tools/pfboardv1_part.js`), tests in `tests/pbox_v1_shots.js`.
- **The piece card in a fight is an overlay on the top of the board room** (it no longer covers the hand), closes with a tap outside, and shows the same chips (type, value, rank, source) and life as the Puzzle box sheet (`PFSheet`).
- **The fight says when the creature acts more than normal or you lose a play (Josh: "why does the creature sometimes get a play and I don't?").** New notice events (`k` 'note': `quick`, `slow`, `trip`) in `pfboard.php` and `tools/pfengine.js` (parity tested): "Skitter: Quick. The creature plays a second piece." (creature banner subtitle, message line, history chip, log), "The creature loses its turn.", "Tripped: you draw 1 fewer piece next turn." (also a chip in the chips row for the turn it applies, and the banner of your next turn), "The creature opened with N pieces" (message line and banner on turn 1), chains through the other side's piece read "Your chain fires the creature's Bash" / "The creature's chain fires your Dodge", "No piece fits: tap End turn to pass" / "No piece fits this way up. Pick one and Flip it." The environment's banner now says "the environment places 2 pieces, not the creature".
- **Puzzle box: the piece detail is a SHEET (Josh: the detail was at the bottom of a long page).** Tap a piece and a bottom sheet opens at once above the bottom bar (max 45% high; a side panel on a wide screen): the real jigsaw art, name, type and value, rank and source chips, life pips, the tag in words, the four edges as a small diagram with a "links best with" line, the flavour line, a durability bar for tools, big action buttons (Pack in deck / Take out of deck, Put on / Take off / Fix), previous / next arrows (also swipe and the arrow keys), close with X, a tap outside, swipe down or Escape; the tapped piece stays marked and in sight. Works for the kit, pals, belt, tools and the pre-fight deck. Reduced motion safe, light and dark.
- **No in-game Release notes post (admin-gated). Needs 2.6.75+, no DB change.**
- **Tests:** `pbox_v1` browser pass (layout gaps, 45%, piece card overlay, tap-outside, the detail sheet at 4 viewport sizes, notices Quick / lost turn / trip / opening), `pfboard_v1` section 14 (notice events and lines), `pfengine_js` (JS = PHP, notes included).

## 2.6.75
- **Puzzle combat v1: the environment is a set of PIECES (admin setting `pfight_v1`, Off by default; flag-off pages are byte for byte the pages of 2.6.73, checked).** Josh's decision after testing 2.6.74: the fixed ground cells, the terrain legend and the forecast marks are gone from new fights. The environment is a third player (you, the creature, the environment). On its turn it puts TWO face-up pieces on the board (the two NEXT pieces are shown a round ahead in a slim "Environment" strip above the hand: tap one for its name, what it does in plain words and who gets it: whoever fires it). Environment pieces have edges, life pips and link / fire in chains started by you or the creature; the effect goes to the side whose chain fires it: Sun x2 for every piece of that side in the chain, Bramble -10% on the other side (guard does not help), Rain guard 15%, Wind pushes the piece its arrow points at one cell, Mud (flat: nothing links to it; a piece next to it counts 25% less), Thornburst -10% to you / -5% to the creature. A chain of 3 or more uses them up like any piece; the environment places nothing while 70% of the board is taken. Numbers are read live from the fight's own rule values. Engine: `includes/pfboard.php` + `tools/pfengine.js` (`includes/data/pf_env.txt`: 6 pieces, deck by creature size, one more copy by region); creature values retuned (x1.0 / 0.67 / 0.53 / 0.66, bars x0.90 / 1.08 / 1.25 / 0.83). A fight started under 2.6.74 keeps its ground and forecast to the end.
- **Environment UI (`assets/pfboardv1.js` built from `pfboard.js` + `tools/pfboardv1_part.js`, `assets/pfv1.css`).** Environment pieces are drawn with the parts kit (real knobs and holes) in their own colour with a dashed cream frame, a dark disc with the kind's icon (sun, bramble, rain, wind, mud, thornburst: simple inline vector icons), an effect badge, Wind's arrow and life pips. Pieces your picked piece's chain would fire glow; player pieces next to a Mud carry a mud mark; lit-spot numbers show the Sun doubling and Mud. The replay has an ENVIRONMENT TURN banner, the two pieces growing into place (the NEXT strip deals them off), a small effect label when a piece fires in a chain (x2 for you, -10, guard, push), Wind sliding the pushed piece, pieces that fade or are used up, and the strip turning its new pieces face up. "?" help covers the environment turn and the six pieces. History chips say Environment.
- **UI fixes (after Josh's test of 2.6.74).** The fight never scrolls the page (fixed frame between the header and the bottom bar; the board takes the room that is left; 390x844, 360x640 and 1280x720, every board size); smaller Flip and action buttons; the Puzzle box menu link sits under Hobbies; the belt's tools are a grid of buttons; the pre-fight screen with Auto deck on shows one strip and a closed deck fold with Let's fight always on screen.
- **Flip fix (root cause NOT confirmed).** "Flip reloads the page and does nothing" could not be reproduced in Chromium. Flip is now one request with no page load (the piece turns over in place, lit spots asked again; the old form post is the fallback); the "?" help opens inside the Trail popover; Pass waits while a piece still fits flipped. Regression test in `tests/pbox_v1_shots.js`.
- **Den of the Great White Owl route Lv 28-32 -> 8-12.** One-time upgrade step `den_owl_route_level_2675` (`includes/bootstrap.php`, only changes a side route of the Den still above Lv 12, so it can be repeated), and `data/zones.txt` makes the Maplewold tundra a medium zone for new worlds.
- **No in-game Release notes post for this version (admin-gated).** Slim zip needs 2.6.74+. No new tables.
- **Tests:** `pfboard_v1` (194 checks, 85 in `pfboard_v1_env.php`), `pfboard_v1_page`, `pfdeck_v1`, `pbox_v1` (rewritten for the new fight screens; browser pass 390x844 light and dark plus 360x640 / 1280x720 fit passes), `pfengine_js` (JS = PHP over 660 fights); old pf suites unchanged.
- **Known gaps:** Mud's teeth weaken the creature's pieces far more often than yours, the environment keeps a piece back 1-2 times a fight, the creature uses environment pieces only through its one-move search, Boss fights and Thornburst are flagged for a human play session (red flags in `claude/design-board-strategy.md`, Sim 5b); in the box, pals and belt buying are still links; a waiting upgrade offer is not shown on the v1 box; the "Or set aside with" chips are still offered; the OLD board's text is dark on dark in the light theme; Wind slide is shown but was checked by eye only; MySQL, a real phone and a human play session were not done.

## 2.6.74
- **Puzzle combat v1 (in testing, admin setting `pfight_v1`: Off / Admins only; default Off).** With the setting Off nothing changes for players: the old pages are byte for byte the same (tested against the commit before each stage), no new code is loaded, no new item, shop shelf or recipe is made. No in-game Release notes post for this version (admin-gated; same as 2.6.66 / 2.6.67). To try it: Admin > Settings, `pfight_open` = Admins only (or Everyone) and `pfight_v1` = Admins only, then Hovel > Gnome tab > Puzzle box (or the menu under You), pack a starter, and meet a creature on a road, in a lair or a delve.
- **Board rules (stage A, `includes/pfboard.php`, `pfight.php`, `tools/pfengine.js`).** Board size by creature size (small 5x4, medium 5x5, large 7x5, boss 7x6); ground cells (sunny x2, bramble pricks, mud cuts links); a terrain turn after the creature's with forecast events announced a round ahead (sunbeam, bramble creep, puddle, gust, thorn burst); a chain of 3 or more uses its pieces up; the creature shows its aim (next piece and cell); Teamwork (2 of pal / tool / crop sources in a chain +30%, all 3 +60%); authored edges with a free flip once a turn; per-piece life. A v1 fight is always a board fight; fights under way keep their rules.
- **Deck model (stage B, `includes/pfdeck.php`, data in `includes/data/pf_*.txt`).** Your deck is built from sources: 4 core pieces, a starter pick of 6 (three one-tap kits), knacks, calling, tools on the fight belt (18 tool pieces), crops (9), crafts (7), home region (14) and the party's pals. Rare and Masterwork caps, a harmony meter (how often a hand links). **Tool wear:** a tool piece costs 2 durability each time it is played (20, +4 per rank); a worn-out tool leaves the deck until it is fixed with a Tool Repair Kit (new craft: flint, pine resin, coir fibre; no building). **Fight belts:** 2 tool slots free, 3 with the Stitched Fight Belt (600 Petals, level 8), 4 with the Masterwork Fight Belt (2500, level 18), sold at Twigg's. The belts, the kit and its recipe are made the first time the Puzzle box is used with the setting on, not before (`pfd_content_once`; the stage B build made them at the upgrade, which put two belts on Twigg's shelf and one more Almanac recipe page in front of every player). Once the setting is on, even for Admins only, the shelf, the recipe and its Almanac page are there for everyone and stay.
- **Creature classes and layers (stage B).** All 88 creatures have a class (Critter, Bird, Beast, Reptile/Amphibian, Water, Plant/Fungus) and a layered deck: 4 class base pieces + region pieces + size extras (large 1, boss 2) + 3 unique pieces each (264, names unique). Creature-side tags: pierce, poison, quick, trip, bash, evade, thorns. Values retuned on the real engine (x0.76 / 0.56 / 0.42 / 0.53 by size, bars x1.0 / 1.3 / 1.6 / 1.0).
- **Pages (stage C, `includes/pfdeck_view.php`, `assets/pfv1.css`, `pfv1box.js`, `pfboardv1.js`).** Puzzle box (kit, belt, pals tabs, deck bar, harmony, "Auto-use my current deck"), starter pick, pre-fight screen (creature card with its layers, your deck, Let's fight), the fight board (ground, forecast marks and chips, aim, flip, life pips, faded hand with reasons, Teamwork and chain dots, terrain turn in the replay, help, speed 1x / 2x / skip) and a result card with tool wear. `pfboardv1.js` is built from `pfboard.js` by `python3 tools/build_pfboardv1.py` (do not edit the output).
- **Database:** 4 new tables (`pf_decks`, `pf_deck_pieces`, `pf_belts`, `pf_tool_wear`), made by the normal upgrade on the first request after the upload (or Admin > Upgrade database; also on first use). `CREATE TABLE IF NOT EXISTS`, safe to repeat. New settings `pfight_v1` and the marker `pfd_content`.
- **Tests:** `pfboard_v1`, `pfboard_v1_page`, `pfdeck_v1`, `pbox_v1` (curl + a browser pass at 390px, light and dark), `pfengine_js` (JS engine = PHP over 616 fights); the old puzzle-fight suites pass unchanged.
- **Known gaps:** in the box, pals are added / removed in the Pal Book and a bigger belt is bought at Twigg's (links only); a waiting upgrade offer (`user_pmod`) is not shown on the v1 box; the "Or set aside with" chips are still offered in a v1 fight; the OLD board's text is dark on dark in the light theme (not new); the inspect card covers the hand during a replay; lair guardians and other creatures outside the 88 have no unique layer. Balance: medium creatures 4 or more levels above the gnome are very hard for a simple player (31% at 4 above, 12% at 8), and a well-kitted level 12 gnome beats a level 14 large creature in 3-4 turns; the creature re-aims 1.7-4.2 times a fight (reads as a wrong forecast); Teamwork needs tuning in play. 18 tool types, not 19. Treks still use the old fight. Four sim questions are open for Josh (`claude/design-board-strategy.md`, "Sim results 3", Questions). NOT checked: MySQL, a real phone, a human play session.

## 2.6.73
- **Wander from havens, dens, delves and wonders.** Wander used to need a road stop, so a gnome standing at a haven or a den (lair) had no Wander button and the server refused it. New `can_wander_from()` (`includes/roads.php`): a road stop, or a haven / lair / delve / wonder place. Used by the Wander start (`explore_start`), the round Wander button and the wild hotspot on the Here page, and the World page. "Back to the road" from such a wander returns you to that haven or den. The Trail-section Wander is unchanged (road stretches only). NOT checked in a browser, on a phone, or by a test run.

## 2.6.72
- **Fix: stuck at a place found while wandering.** A place you push through to while wandering off the path (for example the Den of the Great White Owl) showed its Back to exploring / Back to the road buttons only on the old Town page, so on the Here page you had no way back except a saved route. The Here page now shows the same box under the route strip (shared helper `explore_comeback_html`, also used by `town.php`). Both buttons are free.
- **Wander button on the Here page.** On a road stop, Wander (leaf icon, 1 energy, same rule as the World page) is now a round button under the picture next to Routes, World, Fast travel and GPS. Not shown while on a community garden shift. Version bumped to 2.6.72, release notes added. NOT checked in a browser or on a phone.

## 2.6.70
- **Villagers on the Trail, tidied up (Trail Sights follow-ups).** The villager card has a `👣 Walk over` button (tapping a villager's tile opens their card, so there is always a way to walk there); a villager is never drawn behind or over a landmark sprite (the sprite's real width is checked, 705 of 706 landmarks have a free spot) nor on a find, a gate or the way on; chatting with a villager who has just left writes a journal line.
- **Lighter Trail pages:** one `trail_sight_uses` query per stretch for the request (was one per Sight, repeated), the villager list asked once per request; give-an-item keeps one row per villager row (the day it was last given) instead of one per day, old use rows are pruned after 120 days; the lint refuses `take=` with a condition / `first:` / a chance and a cooldown of 0.
- **Tests:** `tests/trail_sights.php` had silently stopped at its villager-on-map block (a helper was defined after use; the bootstrap swallows the fatal and exits 0), so the later blocks had not run since 2.6.68. Fixed; they run (405 checks, all ok) and `trail_sights.sh` / `here_bang.sh` now fail if the test does not reach its last line or prints PHP warnings. No game code was wrong. Release notes (in-game News > Release notes) added for 2.6.68, 2.6.69, 2.6.70. No DB change.

## 2.6.69
- **Fix: a ! over a villager with nothing to hand in.** The ! over a villager (Here page) still came from the retired weekly "bring me N crops" favours. With the town Orders board on (the default) those favours are not shown anywhere, so a villager such as Juniper Kettleby got a ! whenever you carried enough of the old favour crop, and neither chatting nor gifting cleared it. With Orders on, a ! now means a real order on the current board that you have not delivered and can fill now; with Orders off the old favour rule is unchanged. Test: `tests/here_bang.php` (fails on 2.6.68, passes now). No DB change.

## 2.6.68
- **Trail Sights: the big landmarks on the Trail maps can be used.** All 219 landmark pictures (82 Maplewold, 94 shared land pieces, 43 end pieces) are now places you can DO something. Stand on or next to a landmark: a gold ! shows over it while its Sight is ready, a `🔎 Sights` button opens cards (picture, caption, cost, tool, check, time, quest step) and a Use button sits under the map. A Sight costs 0-2 energy and 10 game minutes (setting `time_sight`), has a cooldown per stretch (5.5 game days by default) and never ends in a fight or KO. Rewards come from the rest-stop reward rules: xp, coins, items, gathering, hints, titles, Almanac pages, private counters, friendship.
- **Many kinds of Sight:** forage, tool-gated gathering (bucket, rod ...), stat checks and crossings (a slip costs a little energy), pick-one-of-three minigames, sneak / hunt / Puzzle Pal bonuses, true hints (tomorrow's weather, who is away, what lives ahead), win lines with variants, private counters with milestone titles, first-time bonuses.
- **Villagers out and about:** a named villager can turn up at a Sight (their time of day, season and weather, not away visiting family, not a hidden NPC, a daily roll). They stand on the map beside the landmark and walk in once; tap them for their card (Chat, Give a present, same once-a-day rules as a rest stop). Some give you a job: hand over the item they ask for (a Give button) or make a check a sure thing.
- **25 quest lines made of Sight uses** (Bramble's Picnic List, Sap to Stack, Which Nettle?, the lantern, the owl letter, Wren's census ... and 17 more across the shared lands and the end pieces): any / in order / any-order-last-beat-last, gates between lines, item hand-ins, boss won and home-cooked meal beats, titles and Almanac pages as rewards. A 📜 Sight quests box on the Tasks page lists them.
- **Almanac:** a new chapter "Sights" (219 pages, one opens the first time you use each Sight) and 47 extra pages the quests open. These pages do NOT count toward the page counts and percentages of the Almanac (`almanac_counts` leaves them out).
- **104 new items** (keepsakes, parcels, tokens, decor you can place, short-buff charms) with new 64 x 64 pixel pictures, 17 new villagers, all 137 shared and end-piece landmark sprites drawn for real in the game's style (they were stand-in lumps), and villagers who share a name now say which village they mean.
- **Admin > Trail sights** (Content & text): every Sight row with problem checks, edit, add, switch off, back to the file. Tests: `trail_sights` (all 219 Sights on 246 routes, all 25 quest lines end to end, villagers, give, pick, hints, titles, pages, almanac counts), `tests/trail_sights_lint.sh`.
- **Needs an Upgrade database run?** The 6 new tables (`trail_sight_uses`, `trail_sight_first`, `trail_sight_rows`, `trail_sight_tally`, `user_sight_quests`, `user_sight_titles`) are made by the normal upgrade on the first request; the Sights also work (without cooldowns) before that. NOT checked: MySQL, a real phone, balance in play, the new item decor in a real yard. Plan and data grammar: `claude/plan-trail-sights.md`, `claude/sights/GRAMMAR.md`.

## 2.6.67
- **Puzzle fight: the picture banner is gone.** On the Trail and other map pages the fight pop-up still drew the battle backdrop (gnome and creature on a landscape) above the puzzle board; puzzle fights no longer draw it. Other encounters keep it. NOT checked in a browser (the page test does not reach the pop-up path).

## 2.6.66
- **Puzzle board: the blank-centre opening is live** (new default for board fights; admin setting `pfight_blank` = 0 turns it off). A blank wild piece sits in the middle. You pick a hand piece and a side of it (the board's four lit spots, button "Confirm start"); the creature has already put its own start piece on a side, hidden. Nothing fires in the opening; the blank is gone at the end of turn 1. New fights only; a fight already under way keeps its own opening.
- **Puzzle board: numbers on the lit spots.** Pick a piece and every lit spot shows what it would do: damage to the creature, charm gained, health you would lose in your own chain (red), and the health the creature's reply would take next. New read-only action `pfb_cells` (`pfb_cell_preview`); the CLI harness prints the same numbers instead of `!`.
- Puzzle board rules: setting a piece aside (join / add) now gives guard equal to that piece's value; a placed 3-piece group plays x2.0 (was x1.5); the creature's pieces in the blank opening are x1.0 (was x1.2). JS demo engine follows. Tests: `pfboard_fixes` (join guard, group x2.0, cell numbers), `pfboard.sh` (blank opening over HTTP, `pfb_cells`).

## 2.6.65
- **Village Show**: three tabs (the week's crop, Arrangements, Hall of fame). The crop tab has a hero card, a podium for the top three and a compact list for the rest; past champions and last week's arrangement winners moved to Hall of fame. `#arrangements` still opens its tab.
- **Trading Post**: My stall is a grid of item cards (price, left, sold, Take down) with the "Put something on the stall" form folded away; Gifts is an inbox of cards instead of a table.
- **Satchel > Tools**: each tool is a card (icon, what you use, what it does, a wear bar that turns red when low) instead of wide tables; the Worn and What-to-make-next lists too.
- **Almanac**: the front page leads with big section tiles (progress and ✨ new count), then the new-pages box (5 pages, not 12). The two dropdowns on chapter pages are now a row of chapter chips with a Contents link.
- **Grand Harvest Fair**: a square per class (your score, entered or ready, current leader); tap one for your entry, the Enter button and the top three. Last month's winners folded away.
- Release notes posts for 2.6.64 and 2.6.65 added to `includes/update_news.php` (posted to players on first load after the update).
- Tabs and pop-up buttons are generic now (`[data-ptabs]`, `[data-opendlg]`) for later pages.

## 2.6.64
- **Contest hall** (treehouse): a pop-up with two tabs. **Contests** opens first, with one square per contest (Village Show, Grand Harvest Fair, Garden of the Month, Pumpkin Carving): picture, name, when it closes, "Entered" or "Not yet", and a link in. **Leaderboards** sits behind the second tab: compact two-column score cards, top three per game with medals and your own best, plus your trophy tags. It used to be one long list of eight five-name tables.
- **Shop menus fix**: the gift picker no longer closes when you pick a different sort (They'll like it / By kind / A-Z). The in-place page-swap handler was catching the sort chips; it now ignores `#` links and anything inside a pop-up.
- Shop menus: the basket survives an in-place page swap (items that are gone drop out, amounts are capped to the shelf, a bought basket starts empty); an item's sheet opens at the amount already in the basket instead of 1; the gift picker opens fresh (nothing picked, no "Give it?" bar); one fresh coin reader serves the sheet and basket "Too much" checks.

## 2.6.63
- **Puzzle board fire budget**: a creature piece falls away once it has fired twice (its placement is the first), after the chain that fired it. Your pieces are not limited. Creature piece values x1.15 to keep it about as hard for good players. Page: "x1" badge on a creature piece's last firing, info card text, fell-away pieces leave like expired ones. See `claude/plan-puzzle-board.md`.
- Puzzle board fixes from the 2.6.60 playtest: the creature's start piece is never Hurt (swapped for a non-Hurt from its draw pile); hostile creatures take Charm at x0.6 (was x0.4); bosses' pieces x1.2; a 3-piece group plays x1.5 (was x1.25); a puzzle Charm win also rolls seed and Gardening Guide drops. Engine notes `reshuf` and `cut`; `pfb_pass` refuses before the start piece in the blank-centre variant. JS demo engine follows. Tests: `pfboard_fixes`, `pfboard_tune`. See `claude/plan-puzzle-board.md`.
- Puzzle board playtest tooling: `tests/pf_play.php` (CLI harness), `tests/pfboard_tune.php` (win / turns / HP-lost table), `tests/pfboard_fixes.php`; opt-in blank-centre opening in the engine, JS demo engine and the demo page; design notes in `docs/puzzle-board-*.md`.

## 2.6.62

- Pal jobs: delve re-runs now run on real time. Trips, stations and garden stays stay on game time (they only move when your gnome's game clock does).

## 2.6.61

- Wren's tour: the "Water it" step can no longer get stuck on a rainy day. Rain already waters the plant, so Water used to be refused ("Watered for today") and the step never finished; while the tour waits on Water, watering now always works.

## 2.6.60

- Puzzle fight: the picture banner (gnome and creature on a landscape) above the panel and the "About the creature" fold under it are gone, and the info pop-up's piece picture is smaller.

## 2.6.59

- Puzzle fight: a turn resolves completely before the other side's begins. A chain that runs through the other side's pieces no longer flips the banner back and forth (events now carry the turn they belong to).

- Puzzle fight: the set-aside group sits in its own row under the board (with the buttons) instead of over the pieces.

- Puzzle fight: clearer turns. The turn banner (Your turn / the creature's turn) shows, holds about a second, fades, and only then that side's pieces play.

- Puzzle fight: the creature starts with one piece (only bosses start with two).

- Puzzle fight: your guard resets when YOUR turn starts (it stays up through the creature's turn; a Hold guard carries once). The creature's starting piece no longer vanishes when you only connect two pieces and end the turn (the page now holds back only the pieces it places that turn, flagged `fnew`).

## 2.6.58

- Fixes: the hovel gate accepts `on`/`true`/`yes` and, when it bounces you home, says what the setting reads; the creature's starting piece no longer vanishes during your first turn's replay.

- Puzzle combat, two ways to win: Hurt takes the creature's HEALTH down (red bar, 0 = it backs off); the pink bar is now CHARM only (full = won over). Great creatures have no charm bar. History chips say `-N hp` (creature) and `+N charm`. Hover text, hint and demo updated.
- **Puzzle combat, board mode: a piece has to connect.** A piece (or a set-aside group) must make at least one linked joint (a knob in a matching hole) with a piece already on the board, yours or the creature's, so the two sides' pieces really meet and chains run across them. Only when nothing in your hand or set-aside group can connect anywhere may you place a piece somewhere else that fits (the hint says so); the creature follows the same rule. The server checks it (a non-connecting placement is refused when something can connect) and the page only lights spots that connect.
- **The creature's turn plays after yours.** Its new pieces stay off the board until the replay reaches them (your piece resolves, then its piece drops in and scores), instead of being on the board at once.
- Tests: the rule on 1,415 side-turns with 1,391 refused placements and the relaxed case (`pfboard_sim`); strict spot parity PHP vs the page (`pfboard_js`); the JS engine copy follows (`pfengine_js`).

## 2.6.57
- **Puzzle combat, board mode: history chips read as a sentence.** Each chip shows who acted (your gnome or the creature's picture), what it did (piece or tag icon), how much, and who it landed on (a second icon), e.g. creature, hurt, -6 hp, you. Setting pieces aside shows no target.
- **Tap a history chip to rewind**: the board, the resolve bar and your health show how they stood after that piece scored, with that piece lit; nothing can be played until you tap the chip again, the newest chip, or **Back to now**. The server keeps a board snapshot for the last 14 placements (about 20 KB in the fight record); older chips still read but do not rewind.
- Tests: snapshot kept by a placement and a connect (`pfboard_sim`); chips carry snapshots and icons (`pfboard.sh`); in a real browser a chip rewinds the board, disables play, and Back to now returns (`pfmap`).

## 2.6.56
- **Puzzle combat, board mode: End fight.** Playing the winning piece no longer closes the fight and drops the loot at once. The last turn plays back, the board shows that the creature is beaten (or charmed), and an **End fight** button collects the reward and plays the chest scene again (the foe falls, the chest opens, the loot is drawn in). Fights lost still end at once. The end scene is also kept for the strip mode and for a knock-out.
- **The history bar is the log.** One chip per scored piece (icon, what it did, combos), newest on the left, scrolls sideways; the text log is gone. After a turn the chips drop in one at a time as each piece scores.
- **Pieces that expire leave after they have scored**: during the replay you still see them (and they are lit if they scored), then they fade away.
- **The creature always has at least two pieces on the board**: if it has fewer after its turn, the board puts out one (nothing fires for it); it grows into place and shakes.
- **Your health is never covered**: the status bar (you, resolve bar, creature) no longer overlaps at 360 px; checked in the tests.
- Tests: spawn and expiry rules in `pfboard_sim`; a won fight waits for End fight, no more plays after the win, and the end scene plays (`pfboard.sh`); the browser test checks the status bar at 412 and 360 px.

## 2.6.55
- **Puzzle combat, board mode: the creature puts down exactly one piece a turn**, so only the chain that piece makes fires (before, a boss or a large creature could put down two pieces and two unconnected groups scored). New test: no side ever fires two separate chains in one turn.
- **Phone: the whole fight fits one screen.** One-line history with the book and discard counts beside it, a smaller play area, a one-line hint, the buttons in one row, and the hand at its real size without overlap (5 pieces across, easy to tap). The piece card is now a sheet over the bottom (close it with the cross); a tapped hand piece shows its short text in the hint line. Tips and the last turn's log are under one "More" fold.
- **Setting pieces aside is no longer a mode.** Pick a piece: if it can join another piece in your hand (or your set-aside group) you get "set aside with" choices under the board. Tap one and the set-aside group appears on the board at once (dashed until you end the turn); End turn confirms. The Connect button is gone. The group's lit spots are one marker each so they no longer overlap.
- Balance retune for one piece a turn each side: small 3.2, medium 4.1, large 4.5, boss 6.1 turns (sim).

## 2.6.54
- **Puzzle combat, board mode: one action a turn.** Place one piece; or **Connect** two pieces in your hand (joined by a knob in a matching hole) and set them aside for a later turn, add one more piece to that group (up to 3), then play the group (a group of three plays for 25% more). A group of three takes no more. The creature now puts down one piece a turn (a boss two), so the resolve bar and creature strength were retuned (`tests/pfboard_sim.php`); pieces stay on the board 3 rounds.
- **Replay**: after a turn the board plays it back one piece at a time: the piece being scored is lit and its card opens, its line is listed, and the resolve bar and your health move step by step. Skip ends it.
- **Tap any piece on the board** to read about it: name, whose it is, value, tag and upgrade, rounds left.
- Tests: set-aside group rules in `pfboard_sim`; Connect, group play and refusals over HTTP in `pfboard.sh`; `pfmap` taps a piece, connects and plays a group through the real page and checks the replay lights a piece (the old `pfboardshot.js` is gone; `pfmap` covers it).
- **Puzzle combat: the board and piece art did not appear after an in-place page update** (a fight that starts, or a turn you end, swaps the page without reloading, and the fight's scripts did not run: blank board, plain hand). `site.js` now re-runs scripts marked `data-rerun` after an in-place swap; the puzzle fight's scripts are marked. Test: `pfmap` ends a turn in a real browser and checks the board and hand art are back (it fails without the fix).
- **Puzzle combat**: upgrade marks (hexagon), rarity gems with 1-3 pips and tag marks are drawn on pieces from `assets/img/pfight/parts/marks/` (the glyph badge stays when a mark file is missing). The zoom buttons no longer lose their first tap after you pan the board.
- Tests: `pfmap` clicks hand pieces on their visible edge (the hand fans out), uses creatures up to level 12.

## 2.6.53
- **Puzzle combat (hidden until switched on)**: road, lair and delve fights can be played with jigsaw pieces instead of the d20 menu. Admin > Settings: **Puzzle combat** = Off / Admins only / Everyone, and **mode** = Strip (chain) or Board (a new fight uses the mode; fights under way keep theirs). Treks still use the old fight.
  - Strip: hand of pieces, build a chain of 1-4, the creature answers. Board: one open play area; place up to 4 pieces a turn next to pieces already out (knob into a hole of the same family, or a flat edge); a placed piece fires its chain newest first through linked joints; pieces leave after 2 rounds. Live preview of what your planned pieces would do. Pinch, wheel and buttons zoom the board.
  - The fight is drawn over the route map. Piece art, joint marks, chain glow, chain-length stamps, tag and upgrade icons, creature rim tint come from `assets/img/pfight/` (missing files fall back to CSS).
  - Puzzle box (`puzzlebox.php`): pack your pieces (capacity grows with level). Finishing a jigsaw or puzzle earns a pick of 1 of 3 piece upgrades (3 a day). Pluck can lift an item a creature drops. New Almanac pages unlock as you use new pieces.
  - Balance: gentle creatures count Hurt at 0.8 (Charm 1.0). Tests: `pfight`, `pfight_sim`, `pfight_js`, `pfboard`, `pfboard_sim`, `pfboard_js`, `pfmap`, `pfight_reward`.
## 2.6.52
- **Pal perches**: five weak whimsy pals redrawn (lizard, gorilla, bill-brolly, wcof, flfm); sources in `aseprite-source/v3/perch/whimsy/`.
- **Art for Slim Home**: room, gnome and 21 decor layers drawn in the v3 style (`aseprite-source/v3/hovel/`, `hovel-decor/`).
- **Slim Home** (new setting `home_slim`, Admin > Settings, off by default; admins always see it): Today, My Gnome and the Hovel become one Home page. A slim hovel banner (a 480x120 crop of `scenes/hovel-room.png` with the gnome, time · season · weather on its tag) carries **Go to sleep** and **Nap**; under it three tabs: **Today** (one "Needs you" list from the home cards, the Hovel's Today and the overnight crew report, plus the latest news with a gold "!" until it is opened), **Furnish** (seven decor slots: floor, wall, window, shelf, rug, lamp, pet corner; a picker per slot, locked items say where to get them, a Cosiness meter out of 12) and **Gnome** (level, health, boosts, pals along, the six sub-page tiles). Energy stays in the header chip, level on the Gnome tab. `hovel.php` still does the sleeping and sends old links home; the menu's Hovel tile goes. Off = the old pages exactly. New: `includes/home_slim.php`, `includes/data/hovel_decor.json`, table `user_hovel_decor`, test `tests/home_slim.sh`. Art is optional: a drawn room and boxes stand in.

## 2.6.51
- **Wattle fence**: all pieces (end, straight, corner, tee, cross, gate, icon) redrawn as one woven top-down set (`tools/gen_wattle_art.py`). The yard now shows the pixel PNG placeholder set when it exists (was always the old SVG), scaled crisp.
- **Pal Jobs**: collecting one pal's trip or delve plays the chest animation, like Collect all.

## 2.6.50
- **Pal Jobs page** (phone): Garden crew rows no longer overlap; each is a name and role line over a garden and mode line, with one "About the crew" link.
- **Trail**: a gate you can already open shows a green 🔓 on its middle tile (legend "Open gate" only when one is drawn).
- **Tests**: `animals140` passes with sleep-days on, `games2` has payout checks, `walk` waits for its server, `folkoverlay` no longer skips.

## 2.6.49
- **Hovel > Pals** list fits on a phone (cards no longer run off the right edge; text wraps).
- **Pal Jobs > Tend a garden** (sleep-days on): pick a job (Water, Weed, Pests, Harvest, Plant) and 1, 3, 7 sleeps or **Full time**; the pal goes onto the garden crew slot.
- **Garden crew bed picker** (Plant pal, Seeds and beds): a tab per garden, each bed has a check (work) and an x (avoid). Any check means only checked beds are planted; x beds are never planted. Other crew jobs still do every bed. Sleep-days popover scenes from 2.6.48 unchanged.

## 2.6.48
- **Popover scenes**: 9 activity pictures redrawn in the 2.5D Hearth Pop style with new 6-frame loops: night fishing, snow monkeys, rift cichlids, toboggan, ice paddles, politest bow (the two gnomes now bow), snowy lanterns, frost pots, bathers' hats. Drawn at 1x, so sharper than the other acts. Art only, no code or DB change.

## 2.6.47
- **Build plans**: six clear-stage texts reworded so "a little each day" is not everywhere; review items closed (`claude/build-plans-review.md`).
- **Fight end scene**: messages (Milestone box, Almanac pages, level-ups) also wait while the end scene is about to start, not only while it plays (`gvShowToasts` in `site.js`; 25 s cap).
- **Tests**: `game_clock.php` pal-hours check no longer flaky (real seconds between two sleeps were added to the job).

## 2.6.46
- **Craft mastery** (`includes/craft_mastery.php`): per recipe, 10 / 50 / 200 makes cut the materials by 10 / 25 / 50% (each ingredient at least 1); per category, 100 / 500 / 2000 makes give +5% yield and -5% energy a tier, and +5% buff time on food, jars and potions. Applies to crafting, cooking pots, pantry jars, camp meals and pal jobs (pal makes count too). Recipe cards show the cut quantities and "Made N times". Settings `mastery_*` in Admin. Not built: nothing for tools' wear or the NPC shop bucket.
- **Sleep-days leftovers (Josh)**: the festival page counts game days left; a repair whose last day runs past 22:00 pays after the next sleep (`landmark_repairs.settle_day`); a tend job pays per owner day tended; a deliver job's deadline is the taker's sleeps (1 or 7). An uncaught `UserError` (for example "still busy with a long job") is shown as a message instead of the 500 page.
- **Festival page** makes its own jar on a first visit.
- **Almanac**: pages for flowers, yard size and Garden of the Month rules (unlocked on first use); fixes for Pickled Onions, Coir Chips, soil improver times (game hours), the Silverfin cause and lair pages (keeper and level).
- **Trail**: a shut tool gate draws a lock, says what it needs, and has a legend entry.
- **Yard**: cover squares redraw live when a bed moves; a planted no-till bed shows no-till soil; Gather tab has a satchel picker (`users.satchel_skin`, run Upgrade database once).
- **Build plans**: the four stages that needed Trek-only items, six wrong-land finds, Sky City Ruins and the Lemon Grove wording are fixed; item and coin needs now scale with region level (data file is generated from `claude/build-plans-base.txt` by `tools/scale_build_plans.py`); stage cards say that handed-in tools are used up; repeated titles retitled.
- **Tests**: `cook`, `paljobs`, `pantry`, `gourmand`, `catfish`, `social100` pass with the game clock on; `garden100` is pinned to real time on purpose.

## 2.6.45
- **Seed Spitting: new animation** (`assets/spit.js`): the player's own 2.5D gnome (same rig sheet and bones as the fight engine, in the player's colours) replaces the emoji. It leans back, squashes and puffs its head as you pull, snaps its head forward on release (the seed leaves the mouth 110 ms later with a puff), hops and swings its arms for a spit of 30 cm or more, slumps for a dribble, breathes and blinks when idle. Beard, scarf, hat and hat tip are springs driven by the bones and leaned by the wind. Pixel look at 2x: stepped parallax hills, clouds blown by the wind, grass that leans, dust at each bounce, a landing flag, prize pennants that light up with twinkling stars, a follow camera that pans only when the seed nears the right edge. Reduced motion jumps to the landed pose. Physics, scoring and the server are unchanged.
- **Seed Spitting hangups fixed**: the JS now gets the real `spit_min_ms` (it always assumed 1000 ms, so a higher setting made the shot fire early and fail with "Too quick!"); on a phone only the left 60% of the field grabs a touch, so the rest of it scrolls the page again; if the page never updates after a shot (dropped connection) the form unfreezes after 9 s and the shot can be sent again; the no-`requestAnimationFrame` fallback used the wrong clock. `spit.php`, `assets/style.css`.
- **Guess the Weight**: the rules tab listed the Energy rule twice.
- **Area colours**: Seed Spitting, Worm Hunting, Guess the Weight, Pumpkin Carving, Pest Patrol and Memory now use the community hue like the Games hub (they were garden, book, world or default); Market day uses the market hue (`page_area` in `includes/layout.php`).
- **Confirm email page**: the success link goes to Log in when you are logged out.

## 2.6.44
- **Almanac: 7 new pages** (`includes/almanac_pages.php`, added once when anyone opens the Almanac, unlocked for everyone who has the starter pages): Sleeping and the game day, Resting away from home (inn, bench, villager, camping gear), Garden crew and the Hovel, Messages from the game keeper, The workshop and its badges, Walking the Trail both ways, Puzzle Pals.
- **Almanac: stale pages fixed** (source and existing worlds, once): Hired help (retired), Pests & companions (no hired helper), Pantry (timers count sleeps), Pots (3/4/5 pots, game minutes), Energy & food (sleep, inns, camp; jam is a 1-energy snack), Dried flowers (one sleep), The florists (game time), Town squares (game clock), The Job Board (after each sleep), Seasons & weather and Seasons in the garden (game days, per gnome), Roads and the wilds (wild country from step 7), Garden crew work order, Puzzle Pals party size, birds eat caterpillars not slugs.
- **Almanac: text errors fixed** from a full entry review: "butterflys" (27 plants), doubled parentheses in Native-to lines, "A island" (10 villages), empty "Can drop: ." on 7 legendary creatures, the pilaf's almonds. Open design items are in `claude/todo.md`.
- **Almanac: dead unlock calls removed** (`npc:`, `flowers`, `yard`, `gotm`: no page had those keys).
- **Trail**: on an easy road an extra mini-boss spot gave a find but was drawn as a fight (⚔️, "A fight waits"). It is now drawn as a find and no longer says a fight waits (`trail_view_html`, `trail_go`).
- **Jam**: a snack-tier jam (Wild Berry Jam) costs 1 energy to cook (`craft_energy_cost`).
- **Florist shop page**: "real minutes" is now "game minutes". Admin season-length label now says game days.

## 2.6.43
- **Trade**: a negative Petal amount in an offer is clamped before the "offer something / ask for something" checks, so `want_coins=-1` can no longer make a free transfer (`includes/trade.php`).
- **Garden of the Month and carving settle**: an entry settled late (its gnome was in a time-out) ranks after the ones already placed instead of #1 (`includes/yard.php`, `includes/contests.php`). A 0-vote carving outside the top three gets no thanks Petals.
- **Carving vote**: the same guards as Garden of the Month voting (level, account age, fresh-gnome hold, same sign-up address).
- **Delves**: running from the chest's guardian ends the delve; the chest only opens after a win (`includes/adventure.php`).
- **Tile walks**: the old `continue` / `arrive` step buttons are refused on a tile walk (`adventure.php`).
- **Lairs**: a win is read from a flag set by `win_fight()`, not only from the last 8 log lines.
- **Adventure page**: a `UserError` (for example "still busy with a long job") shows as a message instead of the error page.
- **Community garden**: hanging up a shift early no longer resets the per-shift job count, and the cap is checked in the UPDATE (`includes/community.php`).
- **Puzzle Pals**: collecting a waiting pal removes the spawn row first, in one transaction, so two requests cannot both train the pal.
- **Daily Rain Barrel / Gnome Beds**: the board and the rank use each gnome's first solve of the day (`puzzle_wins`), not the fastest replay.
- **Double-tap guard**: every drawn form carries its own `_n` value, so the 2-second "sent twice" check only catches the very same form; pressing the same button again on the reloaded page goes through.
- **Gather form (site.js)**: once the server has answered, the form is never sent a second time; a failed swap reloads the page.
- **Rain Barrel / Gnome Beds (JS)**: an error inside the reply handler no longer calls it twice.
- **Auto-upgrade**: after an upgrade that could not finish, the chain waits a minute before the next try instead of running on every page load (`boot_retry_after`).
- **Security**: `gnome_sprite.php` / `gnome_parts.php` limit new colour sets per address (120 in 10 minutes) and stop keeping files past 4000 entries; update backups get a random suffix in their names; login adds a cap of 20 wrong tries per account across all addresses; deleting an account blanks its feedback notes and replies.
- Not changed, on purpose: guests may still play Rain Barrel / Gnome Beds (tested in `tests/guest.sh`); Jigsaw / GIFsaw finishes stay client-reported (the solution is the picture itself, so a server check cannot prove a solve); a put-away walk still lives in the session; the different "once a day" clocks.

## 2.6.42
- **Every creature redrawn and animated in the fight**: all 117 creatures and the 7 Trek crew are drawn in the gnome's 2.5D style (Hearth Pop palette, one 1 px outline, a ground shadow, no pedestal) and each is built from parts that move: legs, tails, wings, heads, feelers, claws, tentacles. They breathe, blink and fidget while waiting, and each body type has its own attack, hit, dodge, run and knock-out. Many now read as the animal they are (turtles, lizards, fish, the scorpion, the bat). Each has one small quirk.
  - Art: `aseprite-source/v3/creature25/gen.lua` draws each creature from the spec tables (`opus-test-run/scripts/minis/enemies.lua`, `villagers.lua`): one file per body type in `types/` (quad, bird, frog, bug, worm, snake, snail, crab, spider, golem, wisp, octo, folk), quirks per creature in `quirks/`, shared painters in `c25lib.lua`. Output: `assets/img/fight/rig-<slug>.png` (one column per part, row 0 paint, row 1 ink), `assets/img/mini/mini-<slug>.png` (the same parts put together) and `assets/fightrigs.js` (one skeleton per creature). `tools/fight/rig_minis.lua` is superseded.
  - Engine (`assets/fightengine.js`, `assets/fightarch.js`): one sheet per actor, a bone tree, springs (tails, feelers, eye stalks, tentacles, worm segments, the gnome's beard and scarf), blink and fidget timers, moves `peck`, `swoop`, `strike`, `smash`, a ResizeObserver so the stage follows its own width. A rig row names its motion set separately from its skeleton. Creatures are at the gnome's pixel scale (`PXC` = 1/32). `FE_ARCH.extra` = springs for quirk parts, `FE_ARCH.hide` = parts hidden until a pose shows them (the boar's snort).
- **The gnome moves better in a fight**: new bones (head, beard, scarf, eyelid, elbows); beard and scarf swing by themselves; he blinks, has five fidgets, hops back after Pluck and Attack, and has a new guard and snack (`includes/gnome_rig.php`, `gnome_parts.php?p=sheet`, `tools/gnome_rig_parts.php`).
- **Villager and creature pictures replaced everywhere**: the 69 villager minis (`mini-npc-*`), the 7 crew minis and the 117 creature minis are the new drawings (lists, the Trek stage, village streets, the home stage). Pictures now have their own sizes instead of 56x64 / 80x80 / 112x112 / 64x80; pages read the size from the file.
  - Not changed: the Trek stage still shows still pictures (its fights are not on the animated engine). The aphid swarm is still one picture.
  - Tests: `node tools/fight/smoke.js` (all 124 rigs), `tests/fight_scene.sh`.

## 2.6.41
- **New logged-out front page: a landing card and How to play** (`includes/landing_view.php`, `assets/landing.js`, the `lh-` block of `assets/landing.css`). Landing card: felt card with the grassland stage, the 2.5D gnome strolling across it (pals behind while Puzzle Pals are open, Wren by the path), site name, headline, one line (`home.sub`), sign-up, guest (only while guests are on), log in, a link down to How to play. How to play: a loop bar and cards, each a small living scene made of art the game already uses: **Grow** (bed tiles and crop stages worked square by square), **Cook** (Apple Crumble recipe), **Explore** (three real 30 x 18 Maplewold sections, routes 232 / 312 / 309: baked ground, raised sprites sorted by feet row, a 7-tile camera on the walking gnome, finds picked up, tabs to switch), **Meet** (village picture with three villager strips), **Collect** (four item squares by rarity), **Puzzle** (the Maplewold jigsaw's Easy cut assembling; only while Jigsaw is open), **Puzzle Pals** (the Maplewold roster and garden jobs; only while Puzzle Pals are open). Jeff's screenshot tour is retired (his closing card, the puzzle demo and the bottom buttons stay); `home.jeff`, `home.tourbtn` and `home.tour.1-6` are no longer shown. New page texts: `home.sub`, `home.htp.lede`, `home.htp.grow|cook|explore|meet|collect|puzzle|pals` (Admin > Page text, "Title, new line, text").
  - Rules kept: no inline styles (positions are SVG attributes, the rest classes), scenes start when scrolled to and stay still under reduced motion, a Trail section without its ground picture is left out (none at all = a banner), no gated section is used. A Trail ground picture is read from `uploads/trail/ground/` first, as in the game. The gnome strips come from `gnome_sprite.php` (needs GD; without it the scenes show no gnome).
  - Tests: `tests/landing.sh` rewritten for the new page, new `tests/landing_home.php` / `.sh` (data, walks, pictures on disk; in CI). Known and not from this change: `tests/css_lint.sh` already fails on the breakpoint ratchet (18, ratchet 17) on 2.6.40.
- **The Trail starts at the end you walk in from**: a route's maps are drawn from its a end to its b end. A walk that starts at the b end now goes through the same stretches in the opposite order and enters each one where the a-to-b walk leaves it (the way on is where that walk enters). Before, both directions started on stretch 1 at its entry. Section numbers on screen still count 1, 2, 3 as walked. Finds you took stay gone both ways (`trail_pickups.sec` is the stretch as drawn). A walk already under way keeps its old maps until it ends. Fixed fights (E, M) stay on their tiles, so on the way back from a delve or lair the boss stretch comes first.
  - Code: scene state `rev`, `trail_seed()`, `trail_phys_sec()`, `trail_map_flip()`, a 5th seed part `|r` in `trail_map_make()`, `trail_authored_count()`; `trail_scene_make()` takes `$rev` from `start_expedition()` (start = `routes.b_id`). Test: `tests/trail_reverse.php` / `.sh` (in CI).
- **Workshop picture redrawn** (Hearth Pop v3, Aseprite; Josh picked mockup A of three): the same room and the same station places, at hero scale with a light story (sun shaft from the window, hearth glow, violet shade), stone hearth, jar hutch, tool bench, potting bench, iron cauldron, building pile, upright loom. The cat is gone (no animals painted into pictures). `assets/img/scenes/craft-workshop.png`; source `aseprite-source/v3/workshop/a/` (`workshop.lua`, `.aseprite`, `layout.json`, `notes.md`); mockups B and C stay in `aseprite-source/v3/workshop/b|c/` unused. The old source `aseprite-source/v3/finish/a/workshop.lua` is superseded.
- **Workshop sections move when something is ready**: 13 small layers (`scenes/craft-anim-<k>.png`: taller flames and steam, jar glints, sparks and sawdust, a nodding flower, bubbles and a glow, dust on the pile, a sliding shuttle) play only while that section has its "!" badge. Layout `anim` entries may now carry `for` (a hotspot id): `hub_scene()` draws such a layer only while that hotspot has a mark. Layers without `for` play always, as before. Shipped `workshop` layout: new spot centres, a `box` per spot, the `anim` list. **If the live site has an admin-edited `workshop` layout (table `here_layouts`), it wins over the shipped one: delete that row or re-save it, or the new spots and layers will not show.** Tests: `tests/here.php` (layer `for`, shipped workshop layout).
- **The "!" badge sits on the corner of the thing**: a picture spot that has a painted `box` wears its badge at the box's top right corner instead of near the spot centre, so it no longer covers the station (`hub_hotspot()`). Spots without a box are unchanged.

## 2.6.40
- **Extra mini-bosses are read by the engine**: a section's `extra_minibosses` entry becomes an `M` token (⚔️ on the map); walking onto it starts that fight (creature by slug, raised to its level; an easy road gets a find instead). If a fight sits in the only way, tapping beyond it says so (`⚔️ A fight waits in the way`). `trail_extra_mini()`, `trail_extra_mini_creature()`.
- **Gates and extra mini-bosses in the other 13 regions** (`tools/add_trail_extras.py`, data in `claude/bend-prototype-v2`): a tool lock before the fight on the last section of 24 delve / lair routes (327 and 448 got none), one short-cut gate per region (the short way needs the tool, the long way round is open) and about 52 extra mini-bosses (a large creature of the route's land). Gate tier = region rank + 1, capped at **3 (Fine)**: the gathering tools have no tier 4, so a tier 4 gate could never open (Maplewold 2, every later region 3). 38 routes got new ground pictures (a gate wall changes the picture); data-only changes for the rest.
- **315 pine slope gate needs a Walking Stick (tier 1)** instead of the Hiking Staff (Josh).
- The 665 old 22 x 7 ground pictures (`assets/img/trail/ground/<route>-<section>.png`) are deleted: no route uses them. `trail_maps.json` stays as the reference for the old tests.
- Tests: new `tests/trail_mini.php` / `.sh` (in CI), the other-region block of `tests/trail_bendy.php` checks gates and mini-bosses.
- **Garden crew fixes**: a Harvest or Plant pal now works without the other jobs being manned. (1) A crop that ripens with the day you watered it by hand (or rain) is picked the same night; before it waited a whole extra night, so a Harvest-only crew often found nothing. (2) A harvested bed goes back to bare ground: the Plant pal now tills it again (no tool, no energy) before planting, but only beds that grew something before; before, it skipped every bed the Harvest pal had just cleared. (3) With no seed remembered and none ticked, the report now says "tick seeds in Seeds and beds".
- **Garden crew phase 4**: **tiredness**: a pal on the same full-time job works at 100% for 7 nights, slowing to 60% on night 14 and 50% after (a tired pal skips some beds, the same ones each time). From night 14 a ! shows on the slot, the Hovel Pals tab, the Pal Jobs page and Today, with a note; call the pal home (rest day) and give them another job to reset. **Hovel Today tab** (first tab; opens after a sleep): Needs you (!): ripe crops, tired pals, Plant problems, jobs / Journey / requests to hand in, a new daily job, a reply from the game keeper, pal trips to collect; Overnight: today's weather and tomorrow's, the crew report, pots and jars done; In the village: birthdays, who is away and back (only people you know: Acquaintance and up) and market day. The last 3 reports are kept ("Earlier reports"). Code: `includes/today.php`, `pcrew_eff()`, `pcrew_tired()`. Test: `tests/pal_crew.sh`.
- **Garden crew: the Plant slot (phase 3)**: a pal on Plant puts a seed into every empty, prepared bed while you sleep (after harvest, before water). A bed gets the **same seed it last had** (remembered when you or a pal plant it); if that seed has run out or is off season or the soil is too poor, the pal uses one of the **seeds you ticked** in a grid of seeds you hold. Never treasure seeds, saplings or cover crops. Mark beds **hands off** to leave them alone. Beds left empty are explained in the Pals report ("2 beds left empty: out of carrot seeds"). The pal plants and waters in the same night, so the seed starts growing for the day that just ended. New table `garden_pal_memory`, new column `garden_pal_slots.seeds`. Test: `tests/pal_crew.sh` (planting section).
- **Garden crew (phase 2 of the pal garden plan)**: every garden has pal slots **Water, Weed, Pests, Harvest** (and Plant, below). Garden > **Crew** tab (replaces Help) assigns a pal for 1, 3 or 7 sleeps or full time; pals work **while you sleep**, in the order pests, weeds, harvest, water, and the growth tick counts their watering for the day that just ended. A pal's harvest keeps no cut, counts for jobs, and earns the pal reduced Gardening XP (40%, max 12 a night). A pal called home or finished rests until your next sleep. Hovel gets a **Pals** tab (what they did last night, who is working); after a sleep the Hovel opens on Pals when a crew is working. **Hired helpers retired**: contracts end, unused wages refunded, the player is told once. The old "send a pal to the garden for N days" is refused while the sleep clock is on. New tables `garden_pal_slots`, `garden_pal_rest`, `sleep_report` (last 3 sleeps kept; self-create on first use or press Upgrade database). Code: `includes/pal_crew.php`. Test: `tests/pal_crew.sh`.
- **Hovel page**: slimmer, with tabs: **Sleep** (clock, season, weather and energy in one row; Sleep and Nap side by side), **Tasks** (today's daily / weekly / monthly job with progress, plus Journey and Requests with counts, and a link to the full Tasks page) and **Costs** (the cost table, no longer a fold). The Tasks tab shows a count badge when something is ready. After a night's sleep (not a nap) the page opens on Tasks, since the jobs have changed. Files: `hovel.php`, `style.css`, `tests/game_clock.sh` (tab checks).

## 2.6.39
- **Delve route menu**: prettier panel (framed, stage numbers, dotted links between rows, raised pick buttons). The whole route now stays on screen after each floor: the rooms you took are lit with a ✓, the rooms you passed by are greyed out and can't be picked. Files: `includes/delve_v2.php`, `style.css`. `tests/delve2.sh` passes.
- **Workshop popover actions**: Make ×2 / ×5 / All and Collect buttons now send which button was pressed (before, the amount was lost). After any action the picture behind updates too: the **!** badges, the chips, the card's recipe count and the energy / header strip. File: `workshop.js`.
- **Workshop picture**: a green **!** now sits on each crafting section with something to do (recipes ready to make, pantry jars done). Section popovers no longer repeat the page's area strip and big picture; they are a wide, left-aligned, scrolling sheet (the old 420 px cap squeezed them). Files: `hub_scene.php`, `hub_pages.php`, `craft_map.php`, `workshop.php`, `style.css`.

## 2.6.39.1 (Trail maps, built on the Trail branch: ships inside 2.6.40)
- **Bendy 30 x 18 Trail maps for the other 230 routes (624 sections)**, same rich look as the Maplewold in 2.6.38: winding road, entry and exit on any edge, painted ground with water and decor, raised sprites. All 246 routes now use them. Own ground art for mountain, wetland, desert and rainforest (island still uses the coast art).
  - Data: one file per region in `includes/data/trail_maps/<region>_30x18.json` (`ca cb csa ea ee esa mena na nwe oc sa se sea wca`; `na` = the 3 routes of region NA outside the hand-tuned Maplewold 16). Made by `tools/bake_trail_rich.py --all` (route files: `claude/bend-prototype-v2`, linted). `tools/bendy_to_trail_maps.py` `ART` knows all nine lands (art field: desert, island -> coast, mountain -> tundra, rainforest, wetland -> forest).
  - Sprites: 60 new files in `assets/img/trail/obj/` (in the update zip). **Ground pictures are NOT in the update zip** (about 240 MB): upload the zips `upload-zips/gnome-venture-trail-ground-r2-partNofM.zip` through **Admin > Images** (files `<route>-<section>-r.png`). A section without its picture shows the plain tile look until then.
  - Fishing by the water, gates and the Maplewold maps are unchanged. Fixed fights (E) and boss/miniboss kinds are as in the old maps. Extra mini-bosses and gates outside the Maplewold are not built yet.

## 2.6.38
- **Bendy Trail maps for the 16 Maplewold routes (41 sections)**: the Trail sections of routes 228, 232, 236 and 304 to 316 are now 30 x 18 tiles with a winding road, entry and exit on any edge, and the new rich look (painted ground with water, fields and decor; trees, rocks, fences and landmarks as raised sprites the gnome walks behind). All other routes keep their 22 x 7 maps.
  - Data: `includes/data/trail_maps/maplewold_30x18.json` (overrides those routes in `trail_maps.json`). Sprites: 348 files in `assets/img/trail/obj/` (`x-*.png`, in the update zip).
  - **Ground pictures are NOT in the update zip** (16 MB). Upload the 3 zips `upload-zips/gnome-venture-trail-ground-r-partNof3.zip` through **Admin > Images** (files `<route>-<section>-r.png`, saved to `uploads/trail/ground/`). Until then these 41 sections show the plain tile look. The old 22 x 7 pictures keep their names and are not used by these routes any more.
- **Tool gates** on four Maplewold sections: a gate tile on the road stays shut until the gnome carries a tool of the right type and tier 2 or better: 313 section 3 tunnel mouth (lantern), 315 section 2 pine slope (walking staff), 315 section 3 icicle bridge (pick); 314 section 2 causeway (staff) is a shortcut, the long way round is open.
- **Fishing by the water**: standing on or beside a water tile (stream, ford, pond, sea, ice) a **🎣 Fish ⚡1** button appears in the row under the Trail map; it goes away when the gnome walks off. Needs a fishing rod, same catch as Gather here. Gather here itself is unchanged.
- Engine: raised sprites may carry a 5th value (shift down in pixels); `trail_water_near()`, `trail_fish_here()`, `trail_art_sfx()`; Admin > Images accepts `<route>-<section>-r.png`; Admin > Tools "Trail maps check" counts the right picture per section.
- Not in this release: extra mini-boss spots (in the data, not read yet). A walk already under way on one of these routes keeps its old map until it ends.
- Tests: `tests/trail_bendy.php`, `tests/trail_authored.php`. Tools: `tools/render_bendy_rich.py`, `tools/bake_trail_rich.py`.

## 2.6.37
- **Messages (player and admin)**: Admin > Feedback is now **Admin > Messages**. Each player note is a conversation: reply under it, mark "No reply needed", delete it, or **Write to a player** first (by username). Tabs: Waiting for you / All messages. A reply marks the note dealt with; if the player answers it comes back as new.
- **Together > Messages tab (first tab)**: the player sees their notes and your replies as bubbles and can answer. A yellow **!** in a circle shows on the Together menu tile, the phone More / Menu button and the Messages tab while a reply is unread; opening the tab clears it (asked fresh on every page). Together opens on Messages when a reply is waiting, otherwise on the Community garden. "Send feedback" lands in Messages after sending. The player also gets a notice line.
  - New table `feedback_replies`, new columns `feedback.user_unread`, `feedback.last_at`. The pages add them by themselves on first use (or press Upgrade database). New setting `feedback_replies_per_day` (20). Code: `includes/messages.php`.
- **Tools & backups badge**: no longer always a green "ok". It shows "⚠ N errors" in red while `data/error-log.txt` has entries (plus failed upgrade steps as before). The Dashboard shows a red line linking to the log, and the admin side menu has a Tools tile with the count. Clear the log on Tools to go back to "ok".
- **Page code (Admin > Content & text)**: pick any game file (pages, admin pages, includes, data files, CSS/JS) to read its code, or edit it. Saving needs the admin password, refuses PHP with a syntax error or broken JSON, refuses if the file changed since it was opened, and keeps the last 10 old versions in `data/code-backups/` with a "Put back" button. `config.php`, `data/` and `uploads/` can never be opened. A game update overwrites edited files. Code: `admin/code.php`, `includes/code_edit.php`.
- **Dashboard**: the Shop staffing table is gone (it is still on each shop's edit page).
- Test: `tests/messages.php`.

## 2.6.36
- **Town daily limits follow your game day**: "Join the dance" at the Plaza of the Bells, every other place action with a daily limit, and the festival treat used the real day, so they came back at real midnight while the Plaza's hours already ran on game time. They now come back after you sleep into a new game day (real day if the game clock is off). The audit of what is still real-time is in `docs/game-time-audit.md`.
- **Stop perks are yours now**: filling a stop meter (Repairs, Larder, Cheer) gives the player a perk that works everywhere for 7 game days (admin `perk_days`), not "one more thing" at that stop (that bonus is retired). Same perk again refreshes it; at most 3 run (`perk_max`), a 4th drops the one ending soonest. Which perk is picked from the meter's pool by player, stop and game day, preferring one not already running (choosing from two is not built yet).
  - Repairs: 🥾 Light Feet (road walks cost 1 less energy), 🦴 Good Bones (healing +25%).
  - Larder: 🧂 Seasoned (home-cooked dishes +20% energy), 🌱 Green Thumb (10% chance of one extra per harvest), 🥪 Packed Lunch (meal boosts +25% longer), 🍲 Slow Simmer (pots 20% faster).
  - Cheer: 👟 Spring in Step (walking 15% faster), 😊 Bright Mood (+10% XP), 🗣️ Silver Tongue (shops 5% cheaper).
  - Shown in the header effects list and the stop Perks card ("Your perks"). Every number is an admin setting (`perk_*`). Run Upgrade database once for the `player_perks` table. Test: `tests/player_perks.php`. Not built from the notes: Steady Hands, Mender's Luck, Sharp Tools, Full Pockets, Good Company, Sound Sleep, pick-one-of-two, Well Travelled combo.

## 2.6.35
- **Fix: "Work here today" (repairs) and Gather gave an error page or no message when you were busy**: after a long job (hours carried past 22:00, waiting for sleep) any energy spend throws "You are still busy with a long job". `landmark.php` and `gather.php` now catch it and show the message; `repair_work()` checks the busy state before it writes anything.
- **No foraging in a ruin**: Gather at a haven, wonder or delve you have not made safe is refused ("in ruins, make it safe before you gather here"), as the place panel already says.
## 2.6.34
- **Calling mentor button on town maps**: the new town pictures have no slot for the mentor's lodge (Marigold Stall, Root Cellar, Old Watchtower and so on), so each town's picture page now has a round **Mentor** button in the nav that opens the mentor's lodge page in that town, where you talk to them and take chapters.
- **Take a chapter from the calling page**: when the mentor is in another town, My Gnome > Calling now has **Travel and take on this chapter** (free trip, then the chapter starts) beside the plain free trip.
- **Mentors never go away**: calling mentors no longer take the "visiting family" days other villagers do. On those days the mentor was missing from the street and the chapter could not be taken.
- **Mentors on the street**: a town's calling mentor now takes the first street slot on the picture, instead of landing in "+N more villagers".

## 2.6.33
- **Player tend jobs run on the garden owner's sleeps (sleep-days)**: a "Tend my garden" job lasts N of the owner's sleeps (1, 3 or 7), not real days, so it no longer runs out while the owner is away. The Tending page says "N sleeps". The real-time deadline stays only as a 7-day backstop.
- **The taker tends on every owner day**: each time the owner sleeps, the person tending waters every thirsty bed for that day, like a hired helper. Each watering counts as one job done and pays its share of the wage (pro rata, from escrow); the taker gets a notice. Days are also caught up when the taker opens the Tending page and when the job ends. Weeding and harvesting still need the taker's own hands (those still cost energy and time).
- Deliver jobs, listing expiry and "one job per poster per week" stay on real time.
- Run Upgrade database once (new columns `player_jobs.ends_day` and `tend_day`). Tests: `tests/game_clock.php` (tend job sections).

## 2.6.32
- **"!" on the Calling tile**: on My Gnome, the Calling tile shows a yellow ! once you reach the calling level and have not chosen one. It opens the Calling tab.
- **Foodie rank**: every 10 different foods tasted (admin `food_unique_every`) is one rank: +1 max energy and meal buffs last 2% longer, per rank. Shown on the Foods tab.
- **Food mastery**: every food or crop is counted per gnome (times eaten plus harvested). At 500, 1000, 1650 and 2000 (admin `food_mastery_marks`) it gains a mastery step: Familiar, Favourite, Beloved, Signature. Each step makes that food's meal boosts 10% stronger (at least +1), last 15% longer, and give 10% more energy. The Foods tab shows stars and the count; harvest and eat messages announce a new step. Run Upgrade database once for the `user_food_mastery` table. Test: `tests/food_mastery.php`.
- **Clovercove ends the Maplewold to Blossomreach road**: the road stops at Clovercove and no longer reaches Blossomreach Market (route 239 is removed on the first load, `ROAD_DEAD_ENDS` in `roads.php`; new worlds are laid that way). The Maplewold map's only exits are now Windburrow (to Mistmoor) and Poppynook (to Maizehollow). Honeythorpe's and Clovercove's side places still show on the Maplewold map. The world map no longer draws a Maplewold to Blossomreach line.
- Design notes for account-wide stop perks that last 7 game days: `docs/stop-perk-ideas.md` (not built yet).

## 2.6.31
- **Energy trickles back by itself again (sleep-days)**: +1 energy every 5 minutes, while you are away or online, up to 50% of your max. Sleep and naps still give the rest, so the Hovel stays useful. The header and status strip show "+1 every 5 minutes, next in m:ss" until the cap. Admin settings (Sleep-days): `trickle_energy_cap_pct` (50; 0 = off) and `trickle_energy_seconds` (300). Never lowers energy that is already above the cap. No database upgrade needed. First load after the update may add up to the cap at once, from the time since your last energy update.
- **Fix: energy refresh cap**: the SQL that adds regen ticks compared text to a number in SQLite, so the maximum was not applied. Params are now cast to integers.
- Guide, welcome text and Almanac energy lines mention the trickle. Test: `tests/game_clock.php` (trickle section).

## 2.6.30
- **Finds on the Trail take time to come back**: after you walk onto a find (✨) on a stretch of a route, that stretch's finds stay gone for 5.5 game days (real days with the game clock off), also on a new walk of the same route. Admin setting `trail_pickup_tenths` (55 = 5.5 days, 0 = back on the next walk). Run Upgrade database once for the `trail_pickups` table.

## 2.6.29
- **"!" only when you can hand in now**: shown over a villager only if you hold the goods for their errand or town favour, or carry a parcel / escort meant for them. Rest-stop villagers now get it too (their record was looked up in the wrong table). Away villagers never show one.

## 2.6.28
- **Away villagers are really away**: a villager who is away today (visiting family) is no longer drawn on the Here pictures, no longer listed on a rest stop's Villagers tab, and offers no chat, gift, errand or town favour. They are back after you sleep.
- **"!" fixed and widened**: it now shows over a villager who has a request open to you today (rest-stop errand not yet taken, town favour not yet done), not only when you already hold the goods. Rest-stop villagers never got a "!" before (their record was looked up in the wrong table).

## 2.6.27
- **Admin > Game clocks**: every player's game day, date, time and tired state (sort by day), plus the last 100 actions of each player (page, fields, real time, game time). Admin only; passwords, tokens, emails and message text are never stored. Run Upgrade database for the new `player_actions` table.

## 2.6.26
- **A "!" over villagers with a request you can hand in**: on the Here pictures, a villager who has a rest-stop fetch errand or a town favour that you already hold the goods for gets a bobbing yellow ! over their head (and ❗ in the plain picture). Not shown for errands you can't finish yet, or ones already done. Journey and order hand-ins are not marked yet.

## 2.6.25
- **Perks card updates live on the Here page**: doing something at the stop (Do here, stall) now refreshes the 🏅 Perks card in place (meters, perks, days left), keeping the meter tab you had open. Reply JSON has a new `perks` field.

## 2.6.24
- **Shops in the World popover**: the World button on the Here page now offers 🏪 Shops (the Shops tab) beside Open the World page and Villagers.

## 2.6.23
- **Shops tab is shorter on phones**: compact shop cards (name, a one or two line description, one line for who is at the counter, a walk link if you are elsewhere), one column on phones, and the Mossbottom hub shops fold away until opened.

## 2.6.22
- **All earlier posts moved to Release notes**: one-time at upgrade, every existing news post goes to the 📝 Release notes tab. The News tab starts empty for new hand-written posts.

## 2.6.21
- **Today news card is tabbed**: 📰 News and 📝 Release notes, each showing its latest post with a Read fold and an All → link. Pure CSS tabs.

## 2.6.20
- **News has two tabs**: 📰 News (hand-written posts) and 📝 Release notes (the per-version update posts). New `news.kind` column; existing version posts are moved to Release notes once at upgrade, and new ones post there. Admin → News has a Tab choice. The Today card links to both.

## 2.6.19
- **Fix: Hovel page crashed** (`FRIEND_LEVELS` undefined in the rest options); the page now loads friends.php first, so "stay with a villager" works too.
- **Fix: villagers "away today" still shown in town**: away villagers no longer appear at their town spot, and their panel says they are visiting family.

## 2.6.18
- **Gathering pays more for the time (sleep-days)**: a gather now takes 10 game minutes (was 15) and finds 2 or 3 items at base tool level (was 1). Baskets, Sense and rainbows still add on top. Admin `time_gather` still overrides the time. With the flag off a find is still 1.

## 2.6.17
- **Fix: "Already well watered" on a thirsty bed**: the real-time 5 minute watering guard blocked watering after a sleep if you had watered less than 5 real minutes before. With sleep-days on, the game day alone decides (the Water all thirsty button no longer fails). Test in `game_clock.sh`.

## 2.6.16
- **Slimmer, centred Hovel page**: a big centred clock with day, season, weather and an energy bar; Sleep and Nap as full-width buttons with one line of effect under each; the "What costs what" table is folded away until opened.

## 2.6.15
- **Hovel is in the menu** (You group, first tile, 🛏️ Hovel): sleep, nap and rest places. Shown while sleep-days is on.

## 2.6.14
- **Game clock in the header bar** (the gap between the title and energy on a phone): time and day, tap to rest, amber when tired. The clock line under it stays.

## 2.6.13
- **How to play, the Almanac and the welcome text match sleep-days**: a new "Sleep, the clock and days" fold (clock, 06:00 to 22:00, sleeping, naps, game-time costs, what follows your days), energy now says it refills by sleeping, watering says crops grow on days, shops close at 22:00, helpers follow your days. `energy_rate_text()` says "full energy back each time you sleep" while the flag is on. With the flag off the old text shows.

## 2.6.12
- **New gnome art on the account-creation page**: the Welcome "Who are you?" step showed the old flat gnome; it now shows the 2.5D gnome like the rest of the game. The hat and beard swatches (here and on Customise) recolour it live.

## 2.6.11
- **Game clock sits right after energy** at the top of the bar (was far left).
- **Crafting shows the total time** on the ×2, ×5 and All buttons (e.g. "×5 · 🕐 1 h 15 min total"), for non-cooking recipes while sleep-days is on.

## 2.6.10
- **Game clock is the far-left item of the top bar** (and first on the phone line), before energy, health and gnome level: bigger, in a ring, shows the time and day, turns amber when tired, taps through to the Rest page.

## 2.6.09
- **Sleep-days is on** (`game_clock_on` now defaults to 1): each gnome has a game clock; energy comes back by sleeping; garden, jars, pots, pal jobs, NPCs and festivals follow game time. The upgrade starts every gnome on today's game day once (`gclock_started`). Set `game_clock_on` to 0 in Admin to turn it off.
- **Pal jobs run on game time only**: real time no longer moves a pal's trip, delve, garden stay or pot; sleeping and game minutes do (`gclock_freeze_pals`).
- Tests: `game_clock.sh` checks the freeze. With the flag on, `cook`, `paljobs`, `garden100` and `catfish` fail on their real-time assumptions (pots x4, growth by sleeps); `catfish` also fails with it off.

## 2.6.08
- **Image upload no longer dies with "MySQL server has gone away"**: a long upload (a big zip) outlived the MySQL idle timeout, so the next query failed. `q()` now opens one fresh connection and repeats the query when MySQL reports 2006 / 2013 (not inside a transaction).

## 2.6.07
- **Events and skill checks stand on the fight stage**: on pages without a map (the list), an event, riddle or skill check shows your gnome and pals on the animated stage with the event's icon standing opposite (no health bars) instead of the popover picture. The choice rows are unchanged. Engine: `FightEngine.add` takes `emoji`.
- Tests: `adventure.sh` checks the stage on a choice event.

## 2.6.06
- **Crafted satchels**: a Canvas Satchel and a Patchwork Satchel can be made in the Tool Shed (Tools tab) from gathered coir, cottongrass, pine resin, red ochre and desert glass. The Gather tab shows the best satchel you own (patchwork, then canvas, then the leather one everyone starts with).
- **More living stops**: 13 new daily happenings (fog, frost, storm aftermath, bake day, berries, spring clean, snow day, lamplit stalls, late ferry, pilgrims, busy mill, fiddler, bee swarm), 8 new stories (the lantern that went out, the wobbly plank, the runaway cheese, the stranger with no name, the apple that would not drop, the singing well, the boat nobody owns, the kite in the tower) and 8 new calendar days (Slow Sunday, Swap day, May Day, Equinox supper, Hearth week, Long days, New Year, Blossom week).
- **Fallen hat in Trail fights**: (1) the fight menu now has a one-tap 🎩 Hat button while the hat is down, because on a phone the hat can lie under the menu and could not be tapped; (2) after a turn the hat stays on the ground instead of being worn through your attack and then falling off again.
- Tests: `satchel` suite; `fight_scene_trail` checks the Hat button; `stops100` no longer depends on today's date (calendar days are switched off for the daily-roll checks, the answer act is whichever of the four is offered).

## 2.6.05
- **Trail camera stays inside the map**: the picture no longer shows empty ground past the edges of a stretch (the start and the way on used to sit in a band of nothing). The walking camera follows the same rule, so there is no jump when a walk ends.
- **Delve maps get the same notification as the Trail**: what just happened is one toast and a pop-up over the map, not a card in the page. The wander card keeps its own result line.
- **Your delve and lair runs**: a "Your runs" fold (cleared, knocked out or left early, how deep, level, date) on the World page panel and on the Here picture's delve and lair card.
- **Messages wait for a fight's end scene**: toasts no longer cover the scene while it plays; they show when it finishes (they are in Messages meanwhile).
- Tests: camera clamp, delve map notification, runs list, held messages; the `delvemap` test now expects the removed on-the-road bar to be gone.

## 2.6.04
- **A find is announced once**: the Trail pop-up and toast repeated the last journal line (for example "You find Four-leaf Clover.") on every step. A line is now announced only when the journal gains a new one, and a reload does not announce it again.
- Tests: the same line is not announced twice (browser).

## 2.6.03
- **Walking onto an item shows its notification again**: 2.6.02 showed the "what just happened" message only when a page loaded from scratch, not after a step on the map, which swaps the page in place. It now shows in the toast box and floats over the gnome after every step.
- Tests: the browser test now walks a tile.

## 2.6.02
- **One notification box on the Trail**: "Latest: ..." was a second box fixed over the message bar and the status strip. It now joins the one toast box with the other messages, and also floats up over the gnome on the map, so what you find shows where it happens.
- Tests: Trail page toast carrier and map pop-up (browser).

## 2.6.01
- **Popover results show their messages at once**: the Library, other Town spots, the Rest stop card and the Do here card showed only their own result line; anything else the action queued (a new Almanac page, a prize, a notice) waited for the next page load. Those messages now pop up as toasts straight away, and are in Messages too.
- Tests: queued messages come back with the popover reply.

## 2.6.00
- **Rest stop popover buttons work**: checks, picks and powers inside the popover (for example the Extras tab's "Trust the bees (Luck check)") did nothing and just said "Pick how to go about it." The in-place form now sends the button you pressed along with it, and the buttons are switched off while it sends so a double tap cannot post twice.
- Tests: Extras tab Rest, Buy and a Luck check in a headless browser.

## 2.5.99
- **Rest stop popover: new ✨ Extras tab**: the activities that come with a stop being built up (the upgrade activities), with their buttons, which the Here pictures have no room for. They stay open while the stop is built, even when it only needs its monthly upkeep; a line at the top says whether the stop is cared for, needs upkeep, is built to some tier, or is not built up yet. Activities for other times of day and the ones still to build are listed under them. The card now has four tabs.
- **Map links open on your region first**: the Map tab and GPS "Pick a place on the map" open the region map of the region you are in (the world map is still plain World, and "All regions" / "World map" links). The Trail's "World map →" link is now "Region map →".
- **The Here page updates in place**: resting at a haven, wonders, GPS, Wander and Set off post without a page reload and show their messages as toasts. The fight end scene after running away and closing a villager card also refresh in place instead of reloading.
- Tests: Extras tab states and the map links.

## 2.5.98
- **Smaller fight menu**: the Fight list holds only Attack, your calling's ability and your pals' skills (Fight on and Auto-win are gone from the menu; they stay in the plain button list when the fight scene is switched off), and its hint line is shorter ("Tap to read, tap again to do.").

## 2.5.97
- **The fight scene is on by default** (setting `fight_scene`; a site that saved it as off stays off). Tapping the stage to speed it up is now 2x (it was 40x). Players with reduced motion still get the fast version.
- **Fights on delve floors (both kinds, lairs too) and in a wander off the Trail now play on the map**, like the Trail: the stage over the map, the Fight / Item / Flee menu, and the end scene. The simple list view (no map) keeps the stage with the menu under it. This also fixes a wander off the Trail showing no fight at all with the fight scene on.
- **End scenes for running away and being knocked out**: running plays the gnome running off, then the map draws them back; a knock-out plays on the stage above the "Knocked out!" result.
- **Pal skills are acted by the pal**: Strike and Sap hop at the foe, the other skills do a cheer first and then the effect lands; Patch heals with no gnome pose, Shield shows "shielded". A pal not drawn on the stage keeps the old gnome animation.
- **Reduced-motion reward display** (the loot sits still with its name, a tap skips) and **seed and Gardening Guide drops show their pictures** in the end scene instead of the gift icon.
- **Walking back on the Trail**: you land on the exit with Continue offered; a new "Not yet" button on the confirm card lets you look around; tapping the exit tile you stand on opens the confirm again (also the way back from the last section's door).
- **Admin → World & places: "Delve and lair runs"** lists every delve and lair run (outcome, depth, stages).
- Fixed a PHP warning in `stop_derive_type` (`stops.php`, undefined key `slug`).
- Tests: stop upkeep (month roll, hand-in); pal skill events; flee and knock-out end scenes; fights on delve floors and in a wander; the suites that assumed the old default (`here`, `delve2`, `trail_back`, `fight_scene`) follow the new one.

## 2.5.96
- **New fight menu on route maps ("Design C")**: a small command column over the map corner with **Fight**, **Item** and **Flee** (it sits on the side away from your gnome). Fight opens a list beside it (Attack, your ability, your pals' actives, Fight on, Auto-win); Item lists your snacks, one row each (dimmed when you have none); Flee shows your chance to get away. Tap an option once to read what it does in the list's top line, tap it again to do it. After any action the menu closes straight away and the page comes back with it closed, so the whole attack plays out in full view. With no script the lists stay open and every option is still a normal form.
- The fight stage no longer re-enables a button that was disabled on purpose (a used ability) after an animation.
- Tests: `fight_scene.js` and `fight_finale.js` drive the new menu (open Fight, read, confirm); `fight_scene_trail.sh` checks the new markup.

## 2.5.95
- **The fight menu on route maps shows every option**: Attack (double width), your calling's ability, Run, Fight on, each equipped pal's active and Auto-win are all buttons in the menu, in rows of four with the names wrapping, and the Snack (with its picker) has its own row. Nothing is hidden behind "⋯" any more; the new ⓘ button only explains the odds and what each option does. The menu now sits under the map instead of over it, so it never covers your gnome.

## 2.5.94
- **The "on the road" bar is removed from every page.** Walks, their encounters and fights are all on the Adventure page now (and the Trail tile map), so the duplicate bar under the banner is gone, along with its code (`adventure_topbar`).

## 2.5.93
- **No fight bar on the rest of the site**: the "on the road" bar under the banner no longer shows when a creature is in your way (the face-off, health bars and fight buttons). Fights are played on the Adventure page's graphical stage. The bar still shows for walks, problems, choices, meets, delves and lairs.
- **Puzzle Pals beside your gnome on Trail maps and in fights**: the pals you have taken along (up to 3) stand beside the gnome on the route map and move with it, and stand behind the gnome in the graphical fight. Nothing is added when take-along is off, for guests, or for a pal with no art. Fight stage: `fightengine.js` add() takes an optional `size`; `fightscene.js` adds the pals.
- Tests: pals on the Trail map in `tests/trail_authored.php`.

## 2.5.92
- **Trail ground pictures upload through Admin → Images**: a file named `<route id>-<section>.png` (for example `256-1.png`) is matched to that Trail section and saved as `uploads/trail/ground/256-1.png`. The game uses an uploaded picture before the one shipped in `assets/img/trail/ground/`. Zips of these pictures are in `upload-zips/gnome-venture-trail-ground-partNofM.zip`.
- Test: ground picture lookup in `tests/trail_authored.php`.

## 2.5.91
- **Admin → Tools: "Trail maps check"** shows the version, the tile-walk flags, whether `trail_maps.json` reads, how many authored routes and ground pictures this site has, and whether four sample routes (228, 256, 238, 444) are authored with their pictures. For finding out why a route still shows a random map.

## 2.5.90
- **Authored Trail maps for every route**: the 230 routes outside the Maplewold's own region (624 sections) now each have a hand-shaped 22 x 7 map instead of a random corridor, with the section count the route had before. Each section has a named set piece, a short caption, finds off the walk line and a worn path; routes ending at a delve or lair have the fixed miniboss/boss spot on their last section.
- **Set-piece landmarks are wired in** with stand-in sprites (137 shared set pieces). Real art is listed in `claude/trail-setpiece-art-notes.md`. Desert, island, mountain, rainforest and wetland still use the coast, tundra and forest ground art.
- Tools: `tools/gen_trail_maps.py` makes the maps and landmark slots (deterministic), `tools/bake_trail_art.py` also reads `claude/trail-landmarks/*_landmarks.json`. Test `tests/trail_authored.php` expects fixed fights on the last section of every delve/lair route.
- Needs the tile walks flag (`gnav_tiles`) on to be seen.

## 2.5.89
- **Sneak/Hunt now last the whole walk**: the stance was lost at every Continue and every "Back to section N"; it now carries over. The two buttons are hidden during a fight (they only gave an error there).
- **Reward row fits narrow phones**: it is clamped to the part of the stage on screen, closes up when there are many drops, and long names wrap and stagger instead of overlapping.
- **A dead creature's health pill fades out** instead of sitting at 0 during the end scene.
- Tests: stance carry-over in `tests/trail_back.php`; `fight_scene_trail` no longer flakes when a random event at the next section's door starts a fight.

## 2.5.88
- **Fight rewards float over the gnome's head**: after the last blow the XP and loot hop out of the creature and arc up into a row centred over the gnome, names above each icon. The gnome jumps for joy underneath, never covering them, then they sink into him one by one.
- **Random fights are a flat chance, not a fixed count**: no more cap of 2 a section and no climbing "pity" chance. Every tile walked rolls the same base chance, new setting `trail_enc_pct` (default 3%, 0 turns random fights off); rough ground is 2.5x it. 🤫 Sneak is 40% of the base, 🏹 Hunt 250%, with no limit per section. Tests in `tests/trail_authored.php`.

## 2.5.87
- **Walk back along the Trail**: from where a stretch begins (sections 2 and on) a new button, "Back to section N" (free), takes you to the exit of the stretch before it, so you can walk back the way you came. The start tile is labelled "The way back". Fights and finds you already did stay done, and going on again to a stretch you have walked adds no new surprise at its door. Turn back (end the walk) works as before.

## 2.5.86
- **Fight scene fix**: tapping to skip the end scene (or the fight) no longer makes the hat flop about on your head. The hat's spring physics ran with a step as big as the skip speed and blew up; the step is now capped, so the hat just settles. A browser test taps to skip and checks the hat stays still.

## 2.5.85
- **Fight scene fix**: no more "fallen hat" lying by the gnome after a fight on the Trail. It was the map's own default gnome marker (red hat) peeking out from behind the smaller fight gnome. The marker is now hidden while the fight stage is up.

## 2.5.84
- **Fight scene end scene**: when you win (or befriend), the creature falls, its XP and loot drop on the ground with their names, rest a moment, then are slowly drawn into your gnome one by one. The map stays locked until the last one is in; tap the stage to skip. A level-up says so. Still off by default (setting `fight_scene`).
- **Fixes**: a fight no longer starts "already over" or pops your hat at full health: the events of an earlier fight could be left over and play onto the next one. Events now only play on the very fight they belong to.

## 2.5.83
- **Fight scene, on the map**: the fight buttons are now a glass bar along the bottom of the Trail map (Attack, your calling's ability, Run, Fight on, and a ⋯ button for the odds, pal skills, Snack and Auto-win). Characters are drawn small (about one tile) and each has a thin health bar with its number right under its feet. Still off by default (setting `fight_scene`).

## 2.5.82
- **Fight scene sits on the real map**: on the Trail the fight now plays over the tile map where your gnome stands (gnome on its own tile, the creature two tiles right), the buttons sit under the map, and the health bubbles are readable. Still off by default (setting `fight_scene`); other maps (delve, wander) keep the tilted stage for now.

## 2.5.81
- **Fight scene (off by default)**: new setting `fight_scene` (Admin > settings). On, a creature fight plays on the animated tilted stage under the map instead of the popover picture: your gnome in your own hat, beard and scarf colours, the creature as a rig (boar, wolf, bear, ram, scorpion, bullfrog, shore crab) or its picture, damage numbers, misses, guard, run, snacks. Buttons sit under the stage and wait while it plays; tap the stage to skip. Fight on and Auto-win play the whole fight (sped up). Off = the fights exactly as before.
- **Hat**: when a hit takes you under 25% health your hat flies off once. Tap it on the ground to put it on: +5 health (never above your max), once a fight, no turn used. If the fight ends first it just goes back on.
- **Server fight events**: each fight action now records what happened (hits, misses, heals, run, snack, charm...) for the stage. No change to the fight rules: a seeded test checks 120 fights end exactly as before.
- New gnome Attack and Snack moves; new tests `fight_events` and `fight_scene`.

## 2.5.80
- **Puzzle Pals on the Here page**: a pal waiting at the place you stand in now appears among the villagers (first slot, so a crowd never pushes it out). Tap it for the Say hello card.

## 2.5.79
- **Fight engine preview (not in the game yet)**: new page `fight_demo.html` on the site root plays the fight animation engine on the tilted tile board. Gnome on a limb rig (arms, legs, hat that lags, pops off below 25% HP and can be tapped to put back on for +5), and all six wild creatures (boar, wolf, bear, ram, scorpion, frog) on part rigs with their own attack, hit, dodge and KO. Nothing in adventures uses it yet and there is no player news. Files: `assets/fightengine.js`, `assets/fightengine.css`, `assets/fightdemo.js`, `assets/img/fight/`, `gnome_parts.php` (gnome parts in a player's hat, beard and scarf colours, cached), `includes/gnome_rig.php`. Dev notes and tools: `claude/animating-2-5d-sprites.md`, `tools/fight/`.

## 2.5.78
- **Perks button at every stop**: it no longer waits for a meter to move; before that every plant is a seed at 0% and the card says what fills each bar.
- **Every act moves a meter**: 182 acts had no tag word and moved nothing (for example Bring the bell-goats home), so doing them never showed the Perks button. They now have a row in `stop_act_state.txt`: 39 raise Repairs (mending, boats, sails, shutters, labour), 47 raise Larder (food, crops, fishing, animals), 96 raise Cheer (games, sights, stories, rest), +10 each. New test asserts no active act is left without a meter.

## 2.5.77
- **Perks card meters are plants**: each meter (Repairs, Larder, Cheer) is a pot that grows with the bar (seed, sprout, leafy, bud, and in bloom while its perk runs) on a wooden stake sign with the percent in pixel digits. Tap one to see the acts that fill it. New v3 art `ico-pkplant0` to `ico-pkplant4`, `pk-sign`, `pk-digits` (sources in `aseprite-source/v3/items/perks/`); Larder now uses the v3 jar icon.

## 2.5.76
- **Perks popover is now graphical**: a scene banner for the stop with medal slots, perk tickets (meter badge, what it gives, an hourglass with day pips for the days left), pixel-icon meter rings (hammer, basket, party), and a thumbnail picture for each act that fills the picked meter. Falls back to emoji where an icon is missing.

## 2.5.75
- **Perks card redone**: the three meters are now ring tiles (Repairs, Larder, Cheer) with their percent; tap one to see the acts on offer here that raise it and by how much. Works without script.
- **Slower meters**: meters fade 3 a day instead of 6 (about a month to empty on a full bar), and a perk lasts 7 days instead of 3, so a big map is playable without revisiting every stop.

## 2.5.74
- **Perks button**: a round medal button next to World in the row under the Here picture once acts at a stop have moved a meter or a perk runs; it opens a card listing the perks (with end dates) and the three meters. The plain stop page has a small circle by the 🌍 in its trail that opens the same list.

## 2.5.73
- **Living stops fixes**: the perk end date is now worked out in UTC (it could be a day off on a non-UTC server); the two meter-answer acts offered rotate daily instead of always being the first two in the file; perks now stack (each full meter gives one more thing per visit and one more turn a day).

## 2.5.72
- **Living stops**: every stop now has a happening of the day (8 kinds, same for everyone there) with a headline strip, matching acts offered first and villager lines that react to it.
- **Meters and perk**: per player per stop, Repairs, Larder and Cheer fill as you do things and drain 6 a day. A full meter gives 3 days of one more thing to do at that stop. Five new answer acts appear when a meter is low or your standing is high (Stranger, Regular, Local, Pillar).
- **Calendar**: 8 real-date days (Saturday market, Mend-up Sunday, spring fair, midsummer, harvest week, lantern night, midwinter, carnival) replace the daily happening and double meter gain.
- **Stories**: 3 multi-day stories (hen, roof, hat), one part a day for Regulars and up; the last part pays.
- **Notice board** on the Stop tab; meter bars on the Do tab. Admin > Rest stops > Living stops (read-only preview). Upgrade step `living_stops_2572` adds the new acts.
- **Trail**: the yellow square around your avatar on route walks is gone.

## 2.5.71
- **Delve and lair run records**: a new table `landmark_runs` keeps one permanent row per delve or lair run (cleared, ko or left; level, depth, stages, route seed and picked nodes, start and end). `landmark_run_record()` writes it from `save_exp` before the map row is dropped. Test in `tests/delve2.sh`. No page shows it yet.
- **Every village reads differently**: each generated village shows a blurb plus a new second line (`data/village_quirks.txt`, 90 lines), handed out in a fixed order from `zones.txt` so all 146 are distinct (`tests/village_desc.php`). Stored text unchanged.
- **Haven text** no longer promises specific goods (10 havens reworded); upgrade step `haven_text_2571` refreshes the rows on existing sites.
- **Stop upkeep**: any gnome can chip in, no stamp needed.
- **Stop chat**: 22 more lines for the thinner personalities.
- **News post** for players covering 2.5.69 to 2.5.71.

## 2.5.70
- **Sneak and Hunt on tile walks**: two buttons on the trail footer set how you walk. 🤫 Sneak cuts the random fight chance to 40% of normal; 🏹 Hunt raises it to 250% and allows up to 3 random fights a section (normal is 2). Tap the button again to walk as usual. Free, lasts for the rest of the walk. The safe tiles near the entry and exit are unchanged. Tests in `tests/trail_authored.php`.

## 2.5.69
- **Workshop picture has no round icons**: the seven crafting spots (oven, shelf, bench, plant stand, cauldron, bricks, house) are now invisible tap areas, so the round icon circles no longer sit on the artwork. Tapping a spot still opens its card; the chips under the picture are unchanged.

## 2.5.68
- **Build plans for every ruined place**: the other 12 regions now have their own four-stage repair plans (58 more places, 232 stages: haul, gather, feed, light, clear, with a line of story each), so no haven, wonder or delve falls back to the generic stones-and-rope stages. Plans are in `build_plans.txt`; the `buildplans` test checks them all and now hides one plan to test the old-stages fallback.
- **Energy bar updates live too**: after a Do here activity the status strip's energy bar, number and regen note change in place, as the header pills already did.

## 2.5.67
- **Do here popovers show what happened**: on the Here picture, doing an activity (or buying at a stall) no longer reloads the page and drops the result in a banner behind the popover. The popover stays open and its card comes back with the result at the top (what you found, XP, coins) and "Done this visit", and the header energy and coin pills update live (the drawn petal icon stays; only the number changes). Without script the forms post as before. New suite `tests/heredo.sh`.

## 2.5.66
- **Trail maps: a worn path and large landmarks on all 16 Maplewold routes**: each section now has a dirt path from the entry to the exit (forest paths are pale, tundra paths icy so they show on the dark/white floor), and each of the 82 named features is a large raised landmark, 2 to 4 tiles wide and up to 4 tall, so the walker reads as a small gnome (scarecrow, beehives, waterwheel mill, owl den and so on). Landmarks may be any size: `trail_art_obj_size()` reads the PNG, centred on its tile, bottom edge = feet. Placements are in `claude/maplewold-trail-maps/maplewold_landmarks.json`; the sprites are drawn in `claude/tile-art-v3-proposal/gen2.py` and `landmarks_*.py`; `tools/bake_trail_art.py --route=N` re-bakes a route and `tools/preview_trail_landmarks.py` previews without baking. Hand-detail pass: 29 big smooth landmarks (domes, slabs, walls, trunks) redrawn with form-following shading, dithering, cracks, strata, bark and props. Painterly pass: every landmark gets blotchy tone mottling, a rough edge and lit/shade rims (`_painterly` in gen2) so it matches the tree and ground tiles. Polish pass: 23 weak or flat landmarks redrawn bigger and richer, a soft contact shadow baked under every landmark, coast and tundra paths coloured so they show. Note: the bake only redraws a landmark PNG if it is missing, so delete `obj/lm-*.png` before re-baking after editing a sprite.
- **GPS stops at every stop**: the GPS no longer walks on by itself. It stops at every stop on a remembered route (towns, rest stops and pass-through places) and you tap Set off to go on. The keep-walking and pause-at-towns options are replaced by a note.
- **Trail map**: the tiny dots that showed when tapping to move (reachable-tile dots, path-preview dots, footprints) are hidden.

## 2.5.65
- **Art**: all 387 seed pictures are now seed packets; the 11 hedgehog portraits are drawn head-on. Same sizes, drop-in.
## 2.5.64
- **Art**: hedgehogs redrawn as real hedgehogs (8 NPC portraits and sprites, 3 folk portraits and sprites); gnome player layers get a 1px skin rim around the eyes so they stay readable on dark skin. Same sizes, drop-in.

## 2.5.63
- **Art pass 2.5**: 133 weak items redrawn (64x64); 46 seed pictures now seed packets; 4 kind cards (craft, collect, tend, contest) drawn; scene fixes (camp flames, ferry dock, wild-trail trees, Snowcrown Peak, turtle scutes, kava circle, banner-desert, trek-me, vig-pick); world map and all 14 region maps richer; 11 desert/adobe looks for rest stops; village, haven, delve and lair redrawn at hero scale; Maplewold market gets its Beaver Pond front (special2); jigsaw place crops regenerated. Same sizes, drop-in. Pink border stays on the few items still weak.

## 2.5.62
- **Art polish pass**: 37 wonder pictures redrawn richer (pink river dolphins, animals, havens, delves), 7 banners, journal sea/nwe/oc, world map, trek me + ripples, vig-rod/pick, slot-forage. **Fix**: rarity flourishes are 4-frame 96px sparkle sheets again (2.5.60 had drawn them as bands).

## 2.5.61
- **More new art**: 14 journal emblems, 7 landing pictures, 14 region maps (same layout, repainted) plus world map, 46 trek tiles. Same sizes, drop-in.

## 2.5.60
- **New art**: 81 wonder/delve/haven/lair pictures, 29 banners, 27 gather pieces (slots, vignettes, flourishes, badges, felt, ribbons) redrawn in v3 style. Same sizes, drop-in. Pilot pictures kept.

## 2.5.59
- **Rest stop card as tabs**: Hold, Upkeep (only on a fully built stop) and Garden, one section at a time, no script needed (radio tabs). Opens on Upkeep when it is due, else Hold, else Garden; after a hand-in or buy it comes back on the same tab.

## 2.5.58
- **Rest stop card slimmed**: one-line notes, a title with its button on the same row, hand-in rows on one line each (name, count, box, button), shorter wording, tighter boxes (about half the height).

## 2.5.57
- **Fully built stops cannot be adopted; they need monthly upkeep instead.** A stop at the top tier says so and offers upkeep: a quarter (rounded up) of its top tier's needs each calendar month (UTC), handed in by any gnome who has the stop's stamp (Rest stop card on Here, and the old stop page). If a month passes unpaid, the stop loses one tier ("falls into disrepair"; two unpaid months, two tiers), then it can be adopted and rebuilt like any stop. The first time a stop is looked at after this update only starts its clock, no penalty. Stops that are not fully built are unchanged. New columns `stop_adoptions.upkeep_month`, `upkeep_pool` (added by the usual column check). Tuning: `STOP_UPKEEP_PCT` in `includes/stop_adopt.php`.

## 2.5.56
- **Rest stop card wording**: a stop that earlier gnomes already built to the top tier says so ("Fully built already, tier 4 of 4, raised by gnomes who looked after it before you") instead of a bare "Every upgrade is built" right after you adopt it.

## 2.5.55
- **Hand in materials inside the Rest stop popover**: when you look after the stop, its next upgrade's needs (stone, planks, logs, Petals...) each have a Hand in box right in the card. No trip to the passport page.

## 2.5.54
- **The stamp comes with being at a rest stop**: opening the Here picture (or its Rest stop card) at a village stamps your passport, like the old local page did. Before, the stamp only came from the old page, so Take hold here said to collect the stamp first.

## 2.5.53
- **Rest stop popover slimmed**: your stamp count, **Take hold here** (adopt this stop; or collect the welcome when it is yours) and **Garden here** (buy the land deed, or open your garden in this region). Both post in place and the card comes back with the result. The full passport, sets and seasons stay on the full page.

## 2.5.52
- **Rest stop on the Here picture opens a popover**: the stamp passport slimmed down (progress, next sets, Orders note) with Open full page; no Seasons, Land or Road Journal folds. Loads in place from `town.php?view=passport&frag=1`.

## 2.5.51
- **Fewer finds on Trail maps**: random sections hold 0 to 1 finds (was 1 to 3) and authored sections keep about a third of their finds.
- **Trail tiles camera**: a walk on a Trail map now slides the picture with the gnome (wide picture like the delve maps), the gnome stays centred, and the final map no longer flashes before the walk.
- **Garden select bar on a phone**: the quick picks wrap into rows again (a scrolling row showed one pick at a time) and the action bar stays at the bottom, so both menus show.
- **Art v3 installed**: crafting workshop, six villager doors, the street of 4/6/8 houses, five treehouse trophies, the step-off strip (`wander-step.png`).
- **Tests**: `paljobs` no longer depends on the clock (its thirsty crop could be ready inside the replay); `here` copes with real trophy and step-off pictures.

## 2.5.50
- **Numbering note:** the gather layers below first went live in a slim zip that was called 2.5.49 (built before the merge). The 2.5.49 code work listed under the next heading (yard, Here, pal jobs, Trek and so on) was NOT in that zip: it arrives with 2.5.50, together with everything else.
- **Gather scene redrawn for all nine landscapes** (coast, mountain, forest, desert, rainforest, grassland, wetland, tundra, island) on a new organic pixel engine (`aseprite-source/v3/gather/gx.lua`): noisy shapes, per-pixel light, bark and leaf texture, one small quirk each. The satchel is no longer painted into the scene: it is two layers (back behind the find, front over it) with three skins, **leather** (default), **canvas** and **patchwork**. There is no satchel item yet; a later `satchel_skin` on the gnome picks the skin.
- **Time of day**: the scene and satchel come in day, dusk (and dawn) and night versions by the Hollow hour (7-16 day, 5-6 and 17-19 dusk, otherwise night), made by `grade.py` from the day art.
- **Weather**: rain, storm, frost, wind, fog and cloud overlays on the scene by the Hollow weather (sun and heat draw nothing). Made by `weather_overlays.py`.
- Files: `assets/img/gather/scene3-<land>[-dusk|-night].png`, `satchel-back|front-<skin>[-dusk|-night].png`, `weather-*.png`; code `gather_scene_layers()` in `includes/gathering.php`, CSS `.gx-back` `.gx-wx`. A landscape without `scene3-` art keeps the old picture and fixed satchel. Rebuild: `python3 aseprite-source/v3/gather/build_gather.py`.
## 2.5.49
- **Corner pieces**: up to four small pieces share a yard square. A flower pot, stepping stone, log seat or toadstool ring set to "one piece" in a corner (Shape) takes only that corner; whole-square things still block all four. Dragging or tapping a corner piece puts it in the corner nearest the pointer. No schema change (the corner is already kept in `garden_objects.shape`); old saves behave as before. `yard_fits`/`yard_mark` take a quadrant mask; designer, save, undo and bed-adding use it.
- **Paths and coverings meet the beds**: path squares and untilled coverings now run flush into tilled, planted and no-till squares (and each other) instead of fading into turf with a grass gap. The designer joins them live too.
- **Wet tilled soil**: bare tilled squares use `tile-tilled-wet.png` while it rains or storms (same rain rule as crop watering).
- **Thirsty squares for visitors**: when friend watering is on, a visited yard shows which beds are thirsty (before, the "Water for them" button counted them but the picture hid them). Otherwise thirst stays the owner's.
- **Touch**: the yard designer was checked with real touch events in a phone-sized browser (drag from the tray, drag into a corner, refuse a whole piece onto a shared square).
- **Here pages**: Shops popover on rest stops (stall) and havens (pantry); verb chips on workshop, treehouse, Pal Yard and street lists; icon row (Routes, World, Fast travel) on workshop, street and door, Fast travel popover on Treehouse and Pal Yard; Lost Letters and the place panel on the World map; optional step-off / step-back strip (needs `scenes/wander-step.png`, nothing shows without it). Flags `gnav_on`, `gnav_tree`, `gnav_tiles` still default 0.
- **Treehouse**: optional trophy layers in the Contest hall (`tree-trophy-<k>.png`) and optional CSS-only animation layers in any picture layout; lint covers both. Nothing is drawn without the files.
- **Trail**: authored sections use the 2.5D gnome rig (heading and walk frames); the ground fades into shade at the bottom and left edge; maps can be added for any region (`includes/data/trail_maps/*.json`, `tools/bake_trail_art.py` merges and `--check`s; desert, island, rainforest, mountain and wetland use stand-in art). `tests/balance_sim.php` models walks: a tile walk costs the same 1 energy, with about 40% more fights than a timer walk.
- **Treks**: Lanternroot is a real crop (seed from the Worm Choir plants and grows; old saves repaired on upgrade).
- **Pals**: trips and delves pack Strong and Grand healing potions (5 in all, weakest first, unused come back); Twigg's stocks the 7 newer potions; Pal Jobs has a "Select all free pals" button; "Show all N pals" no longer folds the form.
- **Garden**: the select-squares bar is much smaller on a phone. **Welcome**: village cards without a picture use a tested landscape fallback (all 146 villages walked, island colour added).
- **Docs/news**: Here/door/treehouse catalogue in the art guide, README Key systems, DESIGN.md, plan status line; player news for 2.3.91, 2.3.93 and 2.5.49.
- **Tests**: beds, stops100, roads097, redirects and catfish were stale tests (3,4,5 pots, removed chip row, 9% action XP, Wren's tour question, 2.5D scarf, date-dependent rest-stop specials) and now match the game; gather150, help and folkoverlay pass alone (earlier failures were port clashes). New `welcome_villages`. Not run: MySQL, full CI.
## 2.5.48
- **35 pictures finally on the new art**: the v3 drawings from batches 1 and 2 had never been put into the game, which still showed older pictures: Butterfly House, Carrot, Corn, Pumpkin, Watermelon, Pineapple, Coconut, Cacao, Blueberry, Mint, Cassava, Turnip, Rambutan, Fiery Pickled Cabbage, Morel Risotto, Yuzu Marmalade, Bug Net, Tide Pail and Scoop, Fine Foraging Knife, Broken Wheelbarrow, Fossil Shell, Wisp Light, Spotted Pelt, Badger Claw, and the seeds of Banana, Blueberry, Cacao, Carrot, Chili Pepper, Coconut, Corn, Mint, Pineapple, Pumpkin and Watermelon. Ripe beds show the crop pictures, so Carrot, Corn, Pumpkin and the rest look better in the yard. (Ginseng Seed keeps its old picture: the new leaf reads as the wrong plant.)
- **Butterfly House** is the new v3 picture (a slatted butterfly box on a post), replacing the 2.5.47 redraw. The Tortoise Run keeps the 2.5.47 pen (it has no v3 picture); `tools/draw_fix_art.py` now only draws that.
## 2.5.47
- **Animal homes show their pixel art in the yard**: the yard was still drawing the old line drawings for the eight animal homes (worm farm, ladybird lodge, frog pond, quail coop, silkworm shelf, tortoise run, snail jar, butterfly bush); it now uses their pixel pictures.
- **Tortoise Run redrawn**: it was a boxed scene with no outline; now a wooden pen with a dirt floor, a tortoise and a lettuce leaf, outlined like the others.
- **Butterfly House redrawn**: it was a copy of the bird box; now a glass pavilion with a green roof, flower beds and butterflies. New `tools/draw_fix_art.py`.
## 2.5.46
- **Stepping stones, log seats, toadstool rings and flower pots line up**: like fences, they join their own kind by themselves: end, straight, curve (a corner as an arc), tee and cross, with the pieces of neighbouring squares lining up across the edges. In the yard designer, **🔀 Shape** cycles automatic, end, straight, angle (a sharp corner), curve, T, cross, a cluster, or **one piece**, centred or in any corner of the square; **⚖️ Size** picks big, small or mixed (for one piece: large or small). Drawn by the new `tools/bake_fam_art.py` (360 pictures in `assets/img/fam/`, upright from every side). The old pictures stay for the tray and as a fallback. Needs 2.5.40.
## 2.5.45
- **Soil states have their own art**: a planted bed shows damp, dark soil; a thirsty bed shows pale, dusty, cracked soil; a ripe bed shows warm golden soil with a few sparkles. They replace the flat brown squares behind the crops. New `tools/bake_soil_art.py` (`ph/tile-soil-planted.png`, `-thirsty.png`, `-ready.png`).
## 2.5.44
- **Untilled ground has many coverings**: each untilled square is lawn, clover, wildflowers, weeds, dry grass, leaf litter, moss or bare dirt, picked from where the bed is (so it never changes). Squares with the same covering next to each other join into a patch with a ragged lit-and-shaded edge, like the paths and the Trail ground. Replaces the six look-alike tiles of 2.5.43. New `tools/bake_cover_art.py` (335 pictures in `assets/img/cover/`).
- **A bigger, calmer yard turf**: the grass behind everything is one 256 px picture (four squares wide) instead of a 64 px one, so it no longer repeats square after square.
## 2.5.43
- **Blended paths**: flagstone, brick, gravel and bark paths are now ground, not little objects. Each square blends into its neighbours (straight runs, corners, T-junctions, crossings) and into the grass with a ragged, lit-and-shaded edge, the way the Trail ground does. Paths of different kinds next to each other meet with a straight edge. Stepping stones are loose stones with the ground showing round them. New `tools/bake_path_art.py` makes the 188 pictures (`assets/img/paths/`); the designer joins them live too. Needs 2.5.40.
- **Untilled ground, six looks**: untilled squares are flat turf (a meadow, tall weeds, stones, clover, bare patches) instead of the grass cube. All six share one ground with the yard's own turf, so they fade into each other and into the yard. A square keeps its look. New `tools/bake_wild_art.py`.
- **Bigger crops in the beds**: growing crops are drawn about a quarter larger in their square.
- **Ripe crops look like themselves**: a ripe bed shows the crop's own harvest picture (a cabbage looks like a cabbage, not the shared melon). Trees and cover crops keep their stage picture.
- **Fix: Adventure page error**: already in 2.5.42.

## 2.5.42
- **Treehouse and Pal Yard buttons**: Routes, World and the new Fast travel are round buttons under the picture (like the Here pictures) instead of sitting on top of it, and the rooms / job sites are one folded list in an even grid.
- **Fix: Adventure page crash**: `adventure_stage_html()` always returned the fight backdrop and passed a null key to `scene_path()`, so /adventure.php threw a TypeError. The fight backdrop is now used only for the encounter popover.

## 2.5.41
- **Richer pictures**: all 17 Here pictures (11 rest stops, village, haven, wonder, delve, lair, generic), the Treehouse, its four dressing layers and the Pal Yard got a polish pass: livelier fires, more story props, textured materials, warmer light and more plants. Same layout, same spots.
- **Name pills in the Treehouse and Pal Yard**: rooms and job sites now carry the same named pill as the towns and places. Needs 2.5.39.

## 2.5.40
- **Homes popover**: the Homes spot on a picture opens a popover with the neighbours' faces and a link to the street of doors.
- **Verb chips**: the list of places shows what each spot is for (Shop, Talk, Rest, Do, Explore, Enter, Tend, Visit, Eat, Read).
- **The walking gnome**: on the Trail the 2.5D gnome now faces the way it walks (front, back, side, flipped for west) and steps through its walk frames. Needs 2.5.39.

## 2.5.39
- **Villagers pill lights up the villagers**: on a rest stop picture, tapping Villagers scrolls to the villagers standing under it and highlights them (if no one is there it opens the Folk tab as before). Needs 2.5.38.

## 2.5.38
- **Rest stop folk have their new pixel art**: the villagers of rest stops (20 kinds of animal, 3 looks each) now use the new standing sprites on the Here picture and the new portraits in their panel. Needs 2.5.37.

## 2.5.37
- **Trail tiles, Hearth Pop v3 look, first test region (The Maplewold)**: the 16 Maplewold routes (41 sections, 22 tiles wide) now have hand-made maps (`includes/data/trail_maps.json`) drawn with new pixel art: blended ground, raised trees, rocks, hedges and pines that the gnome walks behind or in front of, per-land find spots with a searched state, the v3 gnome sprite, and a short caption under each map. Routes without a map, or sections without their baked picture, keep the old drawn look. Placeholders: the way-on tile and the fixed fight are red-outlined squares until their art is drawn.
- **Fights are random encounters**: no more fight markers on the map. Each tile walked rolls (2% on floor, 8% on rough floor, +1% per quiet tile, never in the first 3 tiles or within 2 of the exit, at most 2 a section) and a hit stops the walk there; random fights never bring a boss. Only a delve's miniboss or a lair's boss is a fixed spot, on the last section. Between-section events are unchanged.
- New: `tools/bake_trail_art.py` (bakes the art and the map data), `includes/trail_art.php`, `tests/trail_authored.php`, search icon `ico-search.png`. Still behind `gnav_tiles`.

## 2.5.36
- **Rest stop folk on the Here picture**: the villagers of a rest stop (Honeybrook and the like) now stand in the line under the picture. Tap one to chat, give a gift or take an errand right there. Needs 2.5.35.

## 2.5.35
- **Named things to do at rest stops**: each "Do here" spot on a stop's picture is now one activity, named and with its icon (what the weather, season or hour allows comes first, then the day's picks). Its popover has the buttons, and doing it brings you back to the picture. Needs 2.5.34.

## 2.5.34
- **Pictures for every kind of place**: Here pictures with named, tappable spots for the 11 rest-stop types (camp, ferry, herb garden, inn, jetty, mill, orchard, shrine, spring, tower, workshop), village, haven, wonder, delve and lair, plus a plain-place picture for any stop type without its own. Three fight backdrops (open, wood, dark) cover every land, three wander banners (generic, wild, deep) and ten wander icons are in. Importer `tools/import_gate_layouts.py` gained the place list and trims hit boxes off the compass corner. News post for everything since 2.4.92. Needs 2.5.33.

## 2.5.33
- **The 2.5D gnome on My Gnome, Today and everywhere your gnome is shown**: the old pixel gnome is replaced by the new standing gnome (your hat, beard and scarf colours) on My Gnome, the Today page, the menu header, the Customise preview, profiles and fights. Pals still stand at its feet. The old picture is the fallback if the art is missing. The World page map opens centred on you at the standard zoom (the whole-world start in 2.5.31 is dropped). Needs 2.5.32.

## 2.5.32
- The World page icon row no longer has a GPS button (Map, Fast travel, Gather, Shops, Wander). Needs 2.5.31.

## 2.5.31
- **World map opens on you**: the World page map no longer reopens on a remembered zoom (it was reusing the last zoom from the old folded map); it always opens centred on you at the standard zoom. Needs 2.5.30.

## 2.5.30
- **World page is the world map** (graphical navigation on): the top banner and the place-switcher row are gone and the page opens on the world map itself, full width. Tap a region to open its map below. Under the map: "You are here" and one centred row of round icons (Map, Fast travel, GPS, Gather, Shops, Wander) that also sits on top of the Gather and Shops pages. The old Go stack of cards stays on the Here page. Needs 2.5.29.

## 2.5.29
- **Shops open as the shop, in the popover**: tapping a shop on a town picture shows the shop itself (who is at the counter, Buy / Sell, volunteer) right in the popover, with no "Step in" tap. Buying, selling and Sell/Buy tabs work in place. The Mossbottom Shops popover lists the hub shops; tapping one opens it in the same card, with ‹ All shops to go back. Open full page stays at the bottom. Needs 2.5.28.

## 2.5.28
- **Each shop has its own name on the town picture**: the pills that all said "Shops" now carry the shop names (Here town pictures). Tapping one opens that shop's card (picture, a line about it, who is at the counter, Step in). The last front is **Mossbottom Shops** (open from anywhere), which lists the hub shops as rows. More shops than fronts: the last town front lists the rest; a picture with one front lists everything. Needs 2.5.27.

## 2.5.27
- **Smoother Trail walk**: the picture now slides with a GPU transform snapped to whole device pixels instead of re-laying-out every frame, your 2.5D gnome glides with no hop so it stays dead centre, and each step is a little slower (90 ms at the quickest). Needs 2.5.26.

## 2.5.26
- **No ring behind your gnome on the Trail**: the round marker behind your 2.5D gnome is gone on the Trail and delve tile maps too, leaving the gnome and its shadow on the tile. Needs 2.5.25.

## 2.5.25
- **Gnome stands on the tile**: on the Trail, delve and trek maps your 2.5D gnome is bigger, has a shadow and no ring around it, so it no longer looks like an event token. The old round icon remains as the fallback. Also fixes a place card that could error when a villager was listed. Needs 2.5.24.

## 2.5.24
- **Your 2.5D gnome appears**: the gnome rig is in the game. Your gnome stands in the street line under the Here picture ("You", tap = Home) and is the walker on the Trail / delve / trek tile maps, in your own hat, beard and scarf colours (tunic, boots and skin as drawn). Built once per colour set by `gnome_sprite.php` and cached. Leaving the Trail (the way on, or Turn back) and coming back from a Wander now land on the Here page of the place. Needs 2.5.23.

## 2.5.23
- **Routes card has a map**: the Routes popover now opens with a small picture of the region (its own map art), cropped to where you stand and where the ways out lead, with the roads, a pin for each route (? for places you have not visited) and "You are here". Tapping a pin picks that route's row, and tapping a row moves the ring to its pin. The Trail walk lights the Here tab, and opening Here during a walk goes straight back to it with no "You're still on the road" message. Needs 2.5.22.

## 2.5.22
- **Here: everything resolves in a popover**: tapping a place in a town picture (Green, Café, Notice Board, Library, special places) opens a slim card that loads in place: one line about it, the things to do as compact rows, who is here as little faces (tap = their popover), favours / gossip, and Open full page last. Its buttons act without leaving the picture. Villager popovers show the portrait first. Under the picture there is one centred row of round icons with captions (Routes, World, Fast travel, GPS); the big place buttons, the List view and the Town square / World map / Villagers buttons are gone (a small "List of places" fold remains). Titles, clock, popover heads and actions are centred. Needs 2.5.21.

## 2.5.21
- **Here pictures: named pills and a street line**: each tappable thing in a gate-view picture carries a small named pill (no overlaps), the compass and world globe are round icons in a row under the picture, and the villagers stand in a line under the picture in their 2.5D sprites with name pills (tap opens the villager popover: chat, gift, trade). Needs 2.5.20.

## 2.5.20
- **Here pictures, clearer**: each tappable thing in a gate-view picture has a numbered pin (no tiny words on the art), and the list under the picture carries the same numbers, with the villagers listed as rows too. The compass (Routes) and globe (World map) are now a bar under the picture. Tapping a villager opens a popover with the full villager panel (Chat, Give a gift with the item picker, trade) that works in place, with "Open villager page" at the bottom. Needs 2.5.19.

## 2.5.19
- **Villager sprites no longer show four copies**: the Here picture drew a villager's whole 4-frame sheet (four bees in a row); it now draws one frame. Tap areas and name tags in the picture scenes are always visible (dashed outline, gold corners, names on small phones too). Needs 2.5.18.

## 2.5.18
- **Picture-first Here scenes for every main town**: Mossbottom and the 14 regional towns (plus the Maplewold market and the desert market stop look) show a gate-view picture with whole-building tap areas, a compass that opens the Routes list (named by destination, one tap to set off) and a globe that opens the World map popover with Open region map. Lookup picks the picture by town region, stop type, landscape and style. Wander cards read optional banner and icon art when present. Needs 2.5.17.

## 2.5.17
- **Wander redesigned for the Trail**: when nothing is in front of you, Wander off shows one small purpose-built card over the Trail section: a header (land, step, tier, danger), what just happened, the moves as small cards (Go deeper, Keep exploring, Step back, Back to the Trail, Visit a found place) and a Gather here fold. Fights, choices and meetings out there use the same popover as on the Trail. The old explore page is no longer shown behind a Trail wander. Needs 2.5.16.

## 2.5.16
- **Wander popover, more tidy**: buttons come right after what just happened; Gather here stays folded; the long map caption and World map link are gone; folds and Journal sit last. Needs 2.5.15.

## 2.5.15
- **Wander popover tidied**: the big heading and the duplicate status box are gone (the info line next to the map says it once); smaller type, tighter buttons and folds. Needs 2.5.14.

## 2.5.14
- **Wander off is one popover, no page change**: the confirm card still shows first; after Wander off, the whole wander (the existing explore screen) plays in a popover over the Trail section, which stays visible but untappable behind it. When the wander ends, the Trail walk is picked up again by itself (no Resume tap). Needs 2.5.13.

## 2.5.13
- **Wander off is a popover**: tapping it opens a small card (what it does, ⚡1, Wander off or Stay on the Trail). Works without script via `?w=1`. Needs 2.5.12.

## 2.5.12
- **Fight popover, smaller and tidier**: 380 px wide, shorter picture and buttons; the odds line ("You hit 90% ...") sits between the picture and the buttons; the green and red stat cards at the bottom are gone (the picture shows both health bars). Needs 2.5.11.

## 2.5.11
- **Fight popover is smaller**: sized to its content (up to 440 px wide, 88% of the screen tall) instead of the whole screen. Needs 2.5.10.

## 2.5.10
- **Trail "way on" popover is a small card** over the map, not the full-screen sheet (the fight popover stays full size). Needs 2.5.09.

## 2.5.09
- **Trail "The way on lies ahead" is a popover over the map** (with Continue or Head into, and a free Turn back). The Section text card above the buttons is now one line. Needs 2.5.08.

## 2.5.08
- **Trail page scroll fix**: the old adventure scroll helper no longer drags the Trail tile page to the bottom (e.g. after tapping Here while on the road). Needs 2.5.07.

## 2.5.07
- **Trail page opens on the map**: the strip and tile map are scrolled into view on every load and move (it could open at the bottom). Needs 2.5.06.
- **Trail buttons under the map**: Gather here, Wander off and Turn back sit in one small row right under the tile map.

## 2.5.06
- **Trail page tidy**: no scene picture or route ribbon over the tile map (the strip says it); "Latest" is now a brief pop-up that fades; the map is centred on screen after each move. Needs 2.5.05.

## 2.5.05
- **Workshop popover loads the real crafting section** (`workshop.php?frag=<key>` JSON fragment + `assets/workshop.js`): Make, Collect and filters work inside the card; "All areas" closes it.
- **Trail strip**: a slim centered strip over the tile map: Trail to the place, Section X of Y, energy chip, HP bar.
- **GPS hand-off** (picture navigation on): after a leg ends at a pass-through stop on a remembered route, you land on Here with that next leg's "Continue to" card open. Each leg still charges its own start energy. Towns still pause as before.
- Needs 2.5.04. No new tables.

## 2.5.04
- **Real Here pictures for town, village and haven** (test). `game/assets/img/scenes/here-town.png`, `here-village.png` and `here-haven.png` replace the placeholders. Same size (480x270), drawn to the existing layout slots in `here_layouts.json` (8 exit stubs, spots, stand points), so no code or layout changes. The other Here pictures stay placeholders. Admin > Picture layouts shows the slot dots over them.
- Images uploaded in Admin > Images or scene uploads still win over these files.
- No code, schema or setting changes. Only `bootstrap.php` (version) and 3 image files.

## 2.5.03
- **Picture navigation (all off by default; this release carries release A, the Here page, and the rest).** New setting `gnav_on` (Admin → Settings): a Here picture page (`here.php`), login lands on Here (`gnav_login_here`, Account → Start on), bottom bar and menu Here, Fast travel and GPS buttons on World and Here. Further settings: Settings: `gnav_tiles` (Trail tiles), `gnav_craft` (Crafting workshop picture), `gnav_tree` (Treehouse and Pal Yard pictures); all need `gnav_on`. Admins can open every new page while the setting is off.
- **The Trail as tile sections** (`gnav_tiles`): 1 energy to step onto a Trail, then walk tile sections (fights and finds on tiles), a free Continue with an event rolled once between sections, Turn back is free, and the last step heads into the place. Also on the page: Gather here (popover), Wander off the Trail (the walk waits and Resume brings the same section back), centered text. A walk that began as a timer walk stays one.
- **Fights and other encounters on tile maps are a popover** (Trail, delve and lair maps): a battle picture on top (placeholder `fight-generic.png`, real art `fight-<land>.png`), small stylized buttons under it, odds and log, the stat cards last. It cannot be closed until settled.
- **Residential and Door** (`residential.php`, `door.php`, a Homes spot on Here): a street of houses with lit windows, a door with Knock (only when they are home), Leave gift (any time, once a day, half friendship) and Back.
- **Crafting workshop, Treehouse, Pal Yard** (`workshop.php`, `treehouse.php`, `palyard.php`): picture pages with popovers that link into the existing pages, found pals on perches, pals at their job sites. The old pages stay.
- **Admin → Images & art → Picture layouts**: drag the slots of every picture, lint, save, reset, copy. `tools/lint_here.php` and `tools/gen_here_placeholders.py` (red-border placeholder pictures, included: `scenes/here-*`, `resid-*`, `door-*`, `craft-workshop`, `tree-house`, `yard-pals`, `fight-generic`).
- Fix: none to existing features; `npc_gift()` gets an optional door mode (default off). Needs 2.5.02 or newer. New column `users.start_page`, new table `here_layouts`. Tests: `tests/here.php`, `tests/here.sh`; plan `claude/plan-graphical-nav.md`.

## 2.5.02
- **Creature villagers.** All 81 NPC portraits in `game/assets/img/ph/npc-<slug>.png` are redrawn in v3 Hearth Pop (80x100). Every villager is now a creature (hedgehog, field mouse, frog, snail, tortoise, moth, beetle, otter, elephant and more; old human-looking art was redesigned to fit the name and mood). Same file names, so nothing in the code changes.
- **New 2.5D villager sprites** in `game/assets/img/sprite/npc-<slug>.png`: 64x96 cells, 4-frame idle strip (256x96), feet at bottom-centre. Not used by any page yet (they are for the graphical-navigation build).
- Images uploaded in Admin > Images win over these files: upload `gnome-venture-images-v3-npc-portraits.zip` to replace old portraits.
- No code, schema or setting changes. Only `bootstrap.php` (version) and image files.

## 2.5.01
- **Redone art for 179 items.** The 179 weak images from 2.4.98 (tiny seeds, look-alikes, muddy materials) are redrawn in v3 Hearth Pop, same file names, so nothing in the code changes: 55 seed icons and 124 other item, stage, fence, wall, shed, pelt and food images in `game/assets/img/ph/`. The pink 2 px review border is removed; `aseprite-source/v3/rollout/weak.txt` is now empty and `export_game.py` re-adds the border to any name put back in it.
- Images you uploaded in Admin > Images still win over these files; re-upload the `gnome-venture-images-v3-*` zips to replace them.
- No code, schema or setting changes. Only `bootstrap.php` (version) and image files.

## 2.5.00
- **Satchel and Crafting items are now big square tiles.** Every item in the Satchel shelves (Seeds, Crops, Food, Soil, Tools and the rest) and in all Crafting menus is a tile: 72 px picture on top (was 28 to 32 px), name under it, 3 per row on a phone and as many as fit on a computer.
- **Count is a badge on the picture** (`×13`). Extra notes (in use, broken, untasted) sit under the name. Crafting tiles keep their line under the name (time and energy, "short 2", "N/M found"). The status stripe moved from the left edge to the top edge.
- Code: `sh_shelves()` in `includes/shelves.php` (picture now `lg` art, `.shic` / `.shqty` wrappers, bag `small` no longer starts with the count); `.shelves .shpill*` rules in `assets/style.css`. Picture size is one variable, `--shic` (72 px). The art is 64 px, so 64 px is the crisp size if 72 looks uneven.
- No schema or setting changes.

## 2.4.98
- **New "Hearth Pop" art for 1,662 items and icons.** Same file names, so nothing in the code changes: `game/assets/img/ph/` (item, seed, food, tool, building and pelt art, including the 14 `nav-*` and stage art), `game/assets/img/games/` and `game/assets/img/ico/` now hold the v3 pixel art (64x64, slim shapes, 5-6 tone ramps, one small quirk each, 1px ink outline). The game already prefers `<name>.png` over the old `.svg`, so the new art shows straight away; the old SVGs stay as the fallback. Flower heads are not included (they need a tintable rig).
- **Review aid: 179 images wear a bright pink 2 px border.** These are the ones the artists or Josh marked weak (tiny seeds, look-alikes, muddy materials). The border is only in the game copy; the source art is untouched, and `aseprite-source/v3/rollout/weak.txt` plus `rollout/export_game.py` regenerate it (remove a line from `weak.txt` and re-run to clear one).
- No code, schema or setting changes. Only `bootstrap.php` (version) and image files.

## 2.4.97
- **Fix: a second tab or visitor can no longer overwrite your garden with an old copy.** `load_plot()` and `helper_water_tile()` lock the square and check it is unchanged before saving (`tile_write_guarded()` in `includes/garden_logic.php`); if it changed, nothing is written and the fresh square is shown. Closes a perennial re-harvest and weeding, mulch or compost being undone by a stale page load.
- **Fix: energy refresh no longer refunds spent energy or credits ticks twice.** `refresh_energy()` adds the ticks (capped at the maximum) and only when `energy_updated_at` is still the value it read.
- **Tests.** `tests/garden100.php` has a "v2.4.97 stale writes" block: stale square rejected, fresh row handed back, unchanged square written, no open transaction, spend kept across a refresh, no double credit.
- Not changed: helper visit totals can still double-count when two tabs load at once (cosmetic; harvests are still claimed).
- **Wren's tour is now a guided speech bubble.** The tour card becomes a bubble above the bottom bar (bottom right on a computer) with a pulsing ring and a pointing finger on exactly what to tap: a wild square, then **Till**; the tilled square, then **Work in** / **Plant**; the planted square, then **Water**; the satchel's Eat button; the Almanac, level and World links (the **More** button first when the link is in the menu); the ready square, then **Harvest**. Nothing is blocked or dimmed: the player's own tap does the job and the bubble moves on to the next thing. A wrong page or garden tab rings the Garden link or the Beds tab. "Skip the tour" is on every bubble. Without script the card stays a plain card. `assets/tour.js` (new), `TOUR_TARGETS` in `includes/tour.php`, `gv:swapped` event after an in-place page swap in `assets/site.js`.
- **Tour text is short, with petal bullets.** Each step is one sentence, then one point per petal-bullet line (`tour_text_html()` in `includes/tour.php`; the energy note is a bullet too). The live "Tap …" hint sits under it.
- **Wren asks "now or later?" once the garden is named.** New `users.tour_ask` (1 asking, 2 said later, 0 answered). **Show me now** starts the tour at Till; **Later** leaves a one-line "Wren's tour is waiting" chip and Wren asks again on the next login. Nothing on the tour counts, and no garden action is free, until the question is answered. Accounts already mid-tour are untouched (answered). `tour.php` `do=start` / `later`.
- **Visit steps show their words.** Opening the Almanac, My Gnome, World or a shop finishes the step before the page is drawn, so the bubble now shows what that step was about first (**Next ›**), then the next step.
- **Compost step can be skipped.** Rich soil has no Work in button, so that step has "Can't see it? Skip this step" (`do=nextstep`, only for steps marked skippable).
- **Tests.** New `tests/tour.sh` (question, later and re-ask, start, free till, skip step, arrival card, paused visit, skip), added to CI; `tests/cook.sh` sets `tour_ask=0` where it moves the tour by hand.

## 2.4.96
- **New-player Welcome flow redesigned for phones (`welcome.php`).** Progress tiles with pixel icons (done tiles link back), Wren's portrait bubble with the long copy behind a **More** toggle, a sticky bottom bar with one big button and Back. **Step 1:** meadow stage with the live gnome, name box, 44 px hat and beard colour tiles (checkmark on the chosen one, name on title and label). **Step 2:** village cards with scene art (Poppyburrow, Honeybrook; other villages get a landscape-colour card with its emoji until they get art at `assets/img/villages/<name>.png`), and the village's welcome basket drawn top-down with item slots (picture, ×N badge, name). Every village's basket is on the page and the picked one shows (`assets/welcome.js`); without script the checked one is shown. Items pop in with a short stagger, none with reduced motion. **Step 3:** name, Petals / plot / energy tiles, and three pack cards (seeds, village basket, everyday kit) with five slots each; tap a card for the full list.
- **Same fields and rules.** `do=gnome` / `place` / `finish` and every field name are unchanged; the live gnome preview still works; no inline styles (CSP). New art in `assets/img/welcome/` and `assets/img/villages/` (11 PNGs). New `pack_slots()`, `pack_icon()`, `swatch_tile()` in `includes/onboard.php`; the old `.wsteps`, `.zonecard`, `.villagepick` styles are gone.
- Open for Josh: long Wren copy now sits behind "More"; baskets of more than 6 items scroll inside the basket.

## 2.4.95
- **Fresh start also clears feature tables made on first use** (Cat Fish, Puzzle Pals and their jobs, hybrids, Treks, rest stop progress, puzzle runs and wins, Jigsaw unlocks); a table that does not exist yet is skipped. (Built outside this repo; notes reconstructed from the diff.)

## 2.4.94
- **Admin: "Start counting again" on XP sources, Usage and Retention.** Usage and Retention count only from the reset date (Retention only players who signed up after it); XP sources clears its log (gnome XP and levels are untouched). Nothing else in the game is deleted. `stats_baseline()`, `stats_reset_handle()`, `stats_reset_box()` in `includes/admin_helpers.php`. (Built outside this repo; notes reconstructed from the diff.)

## 2.4.93
- **Home header no longer overflows on phones.** The place, weather and Calling lines wrap inside the box; the boosts line shows two boosts and a count (full list with times on Stats).
- **Calling card wording trimmed:** one legend line instead of a note on every task; tile says "Not started" / "Active".
- **Fix: "Reach N steps off the road" now counts when you slip back into the wilds.** Coming back from a place found off the path put you at your old depth without telling the Calling, so a gnome already 7 steps out only counted after the next step. (Event tasks, like this one, still count only from the moment the chapter is taken.)
- **Calling chapters say when you have not started them.** A chapter on offer but not taken now has a **⏳ Not started** badge and a box at the top of its card: "Visit Tumble Waymarsh in The Rainroot Reaches to start", plus two short lines: harvest, depth, wonder… tasks count only after you start; region, place, road… tasks show your progress now. Its event tasks say "Counts after you start". A chapter on the go has a **▶ Active** badge. The same box is on My Gnome → Calling, the Calling tile says "Chapter not started" / "Chapter active", and the Today header and Tasks → Journey line is now just "📜 Visit <mentor> in <region> to start" (or "📜 <chapter>: N of M", with "finish!" / "hand in").
- **Free trip to your calling mentor.** The not-started box has a **🧭 Travel to <mentor> (free)** button (no Petals, no energy) that puts you at the mentor's town market, where the Take-on button waits. Only for a chapter you have not taken; only to a town you could fast-travel to anyway (been there, home, or a garden there: an unvisited town shows the hint, no button); not on a walk, in the wilds, a delve, a lair, a trek or a tending shift (the same checks as fast travel, now `travel_blocked()` in `includes/world.php`); not for guests. It sets your place and arrival time, the region visit and the place's Almanac page like an arrival, but sends no travel / arrive / walk event, so it never counts for a task or the Hollow jar. `mentor.php` `do=trip`; `calling_mentor_trip_check()` / `calling_mentor_trip()` in `includes/calling_quests.php`.
- **Tests.** `tests/calling.sh` checks the not-started text and badges, no trip button for an unvisited town, on a walk or once started, the trip moving you free (energy and Petals unchanged), and the Take-on button after it.

## 2.4.92
- **Today and My Gnome are one home page (`gnome.php`).** A shared header (avatar, "Good morning, Name!", place, weather, tomorrow, boosts, trip and calling lines) and two tabs under it: **TODAY** (default; news, the six cards, a one-line Hollow box: jar % · festival % · who is about · Open, Wren's tip; the prize pop-up still pays before the page starts) and **MY GNOME** (`?tab=gnome`: rank and title, level and XP, gardens, energy, health bar with Heal, "See your profile as others do", Pals along with the picker and Pal Book, and a "Your gnome" tile row to Stats (stat-point badge), Calling, Pals, Foods, Villagers and Gardens). The sub-pages keep their `?tab=` addresses and get a "← My Gnome" back link. Tabs are plain links (work without script) and load in place. Phone first; the open tab has a gold top bar; light and dark.
- **Moved / cut.** Hat and beard dyes and a "Your record" line (ribbons, community help, lairs, delves) move to Stats. The Overview tab's stats chart, fact row and stat-point flash, the "Your gnome" filler card and the "📅 Today →" link are gone. `?tab=overview` opens MY GNOME; `?dye=1` with no tab opens Stats.
- **Today's code** lives in `includes/today_view.php` (`today_prepare()` before `page_header`, `today_head_html()`, `today_html()`); `today_social_html($u, 'line')` is the one-line Hollow box.
- **Old links.** `index.php`, `index.php?today=1` -> `gnome.php`; `?t=out` / `?t=hollow` -> `gnome.php#todaycards` / `#hollowtoday`; `index.php?news=all` is unchanged. `daily.php` and First Week's "Back to Today" go to `gnome.php`; the Dye Pot links to `gnome.php?tab=stats&dye=1#dyes`. `gnome.php?id=<another gnome>` goes to their profile, so other players only ever see the profile, never your Today.
- **Menu and rail.** The menu has one home entry, **🏠 Home** (the My Gnome tile is gone; the avatar at the top opens MY GNOME). The desktop rail's "Go to Today" box is gone. The status strip's health and level open MY GNOME, the ✨ stat badge opens Stats. The full festival banner and the trimmed rail follow the TODAY tab. Wren's tour step 7 links to `gnome.php?tab=gnome` and ticks only on MY GNOME, not on landing.
- **Tests.** New `tests/redirects.sh` (old addresses, POST redirects, menu, tour step 7; in CI). `social100.sh`, `paljobs.sh` (the pals-home notice is drawn once), `sinks097.sh` (dyes on Stats), `health.sh`, `calling.sh`, `polish_audit.js` follow; `market100.sh`'s Today check was a no-op (302 without `-L`) and now reads `gnome.php`.

## 2.4.91
- **Petals show once on desktop.** From 721 px the menu's status line no longer repeats the Petals count (the header pill shows it); the destination line stays. Phones are unchanged: the menu sheet still shows Petals.
- **Petals have a petal icon.** New `ico-petal` (pixel PNG drawn with gvlib, `aseprite-source/final/scripts/ico/ico-petal.lua`; SVG fallback from `tests/gen_ico_petal.py`) replaces the coin for 🪙 everywhere (header pill, prizes, treks, games, the chest reveal), read as "Petals" by screen readers. `💱` (admin Trade) keeps the coin. `users.coins` is unchanged.
- **Crisper Satchel tiles.** Tile icons were 26-28 px (0.41-0.44x of the 64 px art, nearest-neighbour), which dropped and doubled outline pixels. They are now 32 px on phones (1:1 on 2x screens, smooth halving on 1x) and 64 px from 900 px; labels 14/13 px on phones, 16/14 px on desktop.
- **Tasks: the Quests tab is now Journey.** Tab key `?t=journey` (old `?t=quests` and `?s=quests` links redirect there, like Orders and Errands go to Requests). Repair links, the nav badge count and the tests follow. Help text that pointed at "the town square's Quests tab" now says Tasks → Journey, and "Satchel → Arranging" now says Satchel → Arrange.
- **Docs.** README, PRODUCT and the to-do header no longer say Treks stop at Chapter II-b (Chapter III is built, `trek_chapters_open` defaults to 3) or that `crafting.php` is a redirect stub. The 2.3.7 update note no longer mentions the removed My Gnome Potions box.
- **My Gnome: the Potions box is gone.** Boost potions and Garden Tonic are used from the Satchel (Garden Tonic: pour it from the Garden). `alchemy_card_html()` and the `do=drink` handler on `gnome.php` are removed.

## 2.4.90
- **Patch note: a full garden is now within reach, and the shows stop paying for being alone.** Adding beds costs far less (all 144 beds about 31,600 Petals, not 170 million), and a quiet show week thanks every entrant instead of crowning the only one.
- **Beds are priced by beds owned (T1.1).** `bed_add_cost()` uses `k = (beds - start²) / 4`, multiplier `min(6, (1 + growth)^k)`, Petals `round(200 x mult x n/4)`, planks `ceil(2 x mult x n/4)` (12 at most). A partial buy (fewer than 4 beds of room) pays per bed and no longer jumps the curve. `bed_add_growth_pct` default 50 -> 20. `bed_adds` is still written, for history only.
- **No prizes for being alone (T1.2).** Village Show and Arrangements show: with fewer than `fair_min_entries` (3) gnomes entered, nobody is placed (`placed` 0), every entrant gets 100 Petals and 10 XP, no ribbon ("a quiet week"). Guess the Weight: the closest-guess consolation needs 2 or more guessers; `marrow_jackpot_max` 25,000 -> 10,000, `marrow_jackpot_grow` 1,000 -> 500 (a pot already above the new cap is not cut, it waits to be won).
- **Faster first week (T1.3).** Wren's tour now gives 100 XP (gnome level 2 at the end). First Week XP 10/10/15/15/20/20/40 -> 40/40/50/50/30/30/60.
- **Honest streak copy (T1.4).** Daily jobs settings say "a lifetime count, never resets". Rain Barrel and Gnome Beds show "Solved N times" instead of "Streak: N days" (`pz_streak()` replaced by `pz_solved()`).
- **First Week day 5 (T1.5).** The friend-request and guestbook tasks are gone (a world may have no other open garden to sign); the card asks for a chat with a second townsperson (`talk2`). Pay unchanged.
- **Calmer Tasks (T2.2).** Orders and Errands are one **Requests** tab (Tasks is now Jobs / Quests / Requests): town orders and rest-stop errands, soonest deadline first, each errand with its days left. Old `jobs.php?t=orders` and `?t=errands` links redirect to `?t=requests` (hub kept); orders and errands already taken are untouched (same tables). The job board shows 3 daily, 3 weekly and 2 monthly offers (`JOB_PERIODS` 5/5/3 -> 3/3/2); the 7-dailies bonus is unchanged.
- **One show page (T2.1).** The weekly Arrangements show is now the second class on the Village Show page (`show.php#arrangements`, form `do=enter_arr`). The arranging workshop (arrange, drying rack, seed packets, florists) is the Satchel's **Arrange** tab (`inventory.php?tab=arrange`, `includes/arrange_view.php`; live score `&t=preview`). The Arranging menu tile is gone. `arrange.php` is a redirect stub: GET 302 to the new place (sub-tab and preview query kept, `?t=show` to the show), POST 307 so an open old form still works. The Contests card for the Village Show counts an arrangement entry and says so.
- **Grand Harvest Fair: 3 classes (T2.1).** Vegetables, Fruit, Grains and Herbs & spices merge into **Produce** (same plant kinds); Flowers and Preserves stay. Prizes, half prizes below `fair_min_entries` and Best in Show are unchanged. Old keys live on in `FAIR_CATS_OLD` (labels only), so old ribbons still read "Grains, 2025-08" and an unjudged old month is judged in its old classes. Switchover: upgrade step `upg249_faircats` turns this month's open old-class `fair_best` and unjudged `fair_entries` rows into one Produce row per gnome, keeping their best (`fair_merge_old_classes()`); chosen over a month-boundary switch so no date-gated code is needed.
- **Upgrade steps** in `includes/upgrade249.php` (`upg249_bedgrowth`, `upg249_marrowmax`, `upg249_marrowgrow`) rewrite a stored setting only while it still holds the old default; `upg249_faircats` merges this month's fair rows (T2.1).

## 2.4.89
- **Seed picker: search, type filter, in-season toggle (restored).** "Choose seeds" (Plant…) has a search box, a type filter (chips for 5 types or fewer, a drop-down for more) with live counts, and an "In season only" checkbox (off by default: off-season seeds can still be planted). Shown from 5 seeds up. Re-applied on top of 2.4.88 after the 2.4.87 build was not carried into main.

## 2.4.88
- **Fix: Jigsaw best times and tier badges could vanish.** Starting a Rain Barrel or Gnome Beds run had a 1 in 50 chance of purging every `puzzle_runs` row older than 14 days, including finished Jigsaw runs (which hold personal bests). The purge now leaves Jigsaw rows alone.
- **Expert before Advanced now frees the pals.** Finishing a picture at Expert first used to give only the trophy and no pals. Whichever of Advanced or Expert you finish first frees the picture's pals (once); Expert also still earns the trophy, and the win card shows both lines when both are new.
- **Fix: delve map ghost buttons.** Cells outside the map (near a left or right edge) could alias into the next row and show as invisible "Walk here" buttons. They are now disabled, and the path preview ignores out-of-range targets.
- **Fix: Jigsaw saves.** Changing tier on a picture that was still loading, then leaving, could make the next picture skip its saved go and delete it. A pending save also no longer rewrites the old tier's save after a tier change.

## 2.4.86
- **Fix: Today / Home crashed (`Unknown column 'pal_uid'`).** The Welcome back and daily card checks filtered Pantry jars and drying racks on a column only the cooking pots have.
- **Admin Tools and update backups now report real failures.** SQL and SQLite backups are built first and checked (a failure shows a red error and downloads nothing; a good SQL file ends with an `END OF BACKUP` line). Delete image, clear logs, and the test pal button no longer say OK when they failed. Update backups check every write.

## 2.4.85
- **Square panel: slimmer action buttons, settle time in the status line.** Action buttons are thinner (40 px). A tool with a row / ×3 reach now shows its two buttons side by side on one row ("Water bed" + "Whole row ⚡1 each"; the repeated name is gone). A settling bed's status line now says "Settling · ready to plant in 15 min" (the separate Settling note is gone).
## 2.4.84
- **Square panel: no-till tidy.** The soil grade (with its bar) and the N-P-K chips share one line; the mulch / weeds / moisture / fertility / roots checks are a 2-column grid of small boxes; Water bed, Till, Work in and Add mulch sit in an aligned grid (Water bed and Till side by side, each picker row the same width).
## 2.4.83
- **Square panel: soil info up top, everything centred.** Fertility, soil life and water, the N-P-K chips and the soil care (or no-till grade) checks now sit right under the heading in one box instead of behind "Soil details". The fold is now "More soil details" (tips, how care works, the Soil Probe). The soil / care chips row is gone (the box says it), and the big grade letter is hidden. Text, chips, icons and buttons in the panel are centred.
## 2.4.82
- **Square panel, tidier.** The heading is now one line plus a status line (no more "Tilled" twice). The plant card is: name and tags, season / weather chips, the progress bar, ONE status line ("Growing · about 22 min left · water lasts 11h"), then Water / Dig up side by side; the long text (unstudied note, life, what it feeds on) is behind **About this plant**.
- **Soil details, consolidated.** Fertility, soil life and water holds sit on one row; N-P-K has a one-line legend; the big care star box is gone (the stars are in the title) and the three care checks are small chips ("✔ Improver added", "✖ Soil life too low").
## 2.4.81
- **No-till grade letter hidden on the yard.** The grade (F, D+, A ...) is no longer drawn on each no-till square, the same as the soil-care stars on tilled beds. It is still in the square's label and in the bed panel; the ⚠️ marker for a bed that needs care stays.
## 2.4.80
- **Garden seed picker: a popover for the details.** Seed squares are clean now (picture, name, how many you have, a green "N planting" chip once picked). Tapping one opens a popover with what the seed needs (season, regrows, unstudied, soil) and a − / number / + / All box for how many to plant; Done closes it. The Seedling / Cutting / Seeds chips are no longer drawn on tiles (screen readers still hear them).
- **Fix: Sheet mulch in Select squares closed every menu.** The Sheet mulch… button was also wired as an instant action, so it submitted at once with no mulch chosen and reloaded the page. It now opens the mulch picker like Mulch… does.
- **Select squares stays on after an action.** After Mulch, Sheet mulch, Work in, Water and the rest, the same squares stay selected so you can chain the next step without re-picking. **Done** clears it.
## 2.4.79
- **Item tiles: chips and count share one line.** The Wanted / in basket / short chips sit on the left and the ×# count on the right, on one line right above the name ribbon (they no longer stack and push the count up).
## 2.4.78
- **Item tiles: count always on the ribbon, quieter chips.** The ×# count now sits right on the name ribbon even when chips are shown (they stack above it; they had been pushing the count up). The "Seeds" chip is no longer drawn (the picture says it; screen readers still hear it) and the Wanted chip is faded.
## 2.4.77
- **Item tiles: 3 across on phones.** Phone squares are larger (3 per row, was 4) with bigger names, price chips, counts and pictures. Desktop is unchanged (4 to 6 across).
## 2.4.76
- **Item tiles are bigger on desktop.** Wide screens now show 4 to 6 squares across (was up to 8), with larger names, price chips, counts and pictures, so they read like the phone version.
## 2.4.75
- **Item tiles: the count always sits on top of the name ribbon.** The ×# count (and the chips above the ribbon) now ride the ribbon's top edge, so a two- or three-line name no longer covers the count.
## 2.4.74
- **Square item tiles everywhere.** Shop, Satchel, crafting, pickers and market tiles are now squares, 4 across on phones (3 in the garden seed picker). Rarity shield top left, price chip (arrow + Petal) top right, count bottom right, name on a slightly faded ribbon along the bottom. Other chips (in basket, have / need, notes, kind) stack bottom left; state badges moved to the bottom left corner. The rarity word is for screen readers only. `tests/itemsq_check.js` expects 3 or 4 columns.
## 2.4.73
- **Pal Jobs: Collect all opens the chest.** Petals, XP and finds from every ready pal are totalled and shown with the chest animation. The long list of lines is replaced by a short row of chips (Petals, finds, XP, potions, dishes served).
- **Shops on phones.** The basket bar is slimmer: its item list is capped at about two rows and scrolls inside itself, so a full basket no longer scrolls the page. Shop squares are 4 across on screens up to 520px.
## 2.4.72
- **Fix: expired guest gardens now get deleted.** They were only swept when a guest loaded a page or a new guest was made, so with no guest traffic they stayed forever. Any page load now sweeps them (at most once every 10 minutes).
## 2.4.71
- **Fix: road traveller chat crashed.** Stopping to chat with a travelling villager on an expedition threw "undefined function npc_icon()" (a white error page) unless another page had loaded the NPC file first. The chat now loads it itself.
## 2.4.70
- **Pal pot pop-up.** Tap a pal's pot in the Kitchen to open a pop-up: what it is cooking now (dish, time left), a **Cooks next** picker (kept until changed or the shift ends) and **Send home early**.
- **Call any pal home early.** Every active job (gathering, delve, garden, pot, old shifts) has **Call home** on the Pal Jobs page, with a confirm box that says the cost. Trips and delves keep half of what the time so far earned (needs 10% of the time done). A pot pal keeps the dishes already served; a dish still cooking loses half (rounded down) and the pot is yours again. Gardeners lose nothing.
## 2.4.69
- **Pals cook passively, one pot each.** A pal sent to the Stove now holds one pot for the whole shift (no ingredients taken up front) and checks it every 10 minutes: it serves a finished dish into your satchel and starts one batch of its chosen recipe. Send as many pals as you have free pots; you can't use a pal's pot while it works. A dish still cooking at shift end becomes your own pot to collect. Checks run when you next load a page (no timer), up to 60 caught up per load.
- **Pal shown on its pot.** A pot a pal tends says "🧩 {pal} is tending this pot" on the Kitchen shelf and in the right rail, instead of "Empty". Each of those pots has a **Cooks next** picker that sticks until you change it or the shift ends.
- Cooking shifts no longer count toward the daily station-shift cap. New column `cook_pots.pal_uid`.
## 2.4.68
- **Cooking pots tidy.** Pots are small squares, centred, and wrap to a second row when there are more. Cook again and Collect all sit centred under the pots.
## 2.4.67
- **Cooking: less waiting, less tapping.** Pots are now 3 / 4 / 5 for Kitchen I / II / III (was 2 / 3 / 4). A pot now holds 1 / 3 / 5 meals and 1 / 1 / 2 feasts by Kitchen level (snacks still 5). New **Cook again** button on the pots row repeats the last dish into the free pots. Settings: `kitchen_pots`, `meal_batch_kitchen`, `feast_batch_kitchen`. Energy regen and max energy are unchanged.
- **Blossom Cherry is now 2 × 2** like the oak and willow (was one square). Cherries already placed stay 1 × 1 until you place them again.
- **Fixes.** XP awards at the same moment no longer overwrite each other (XP is added in the database; the level-up is claimed once). A double tap or second tab on a garden square now sees what the first one did, so it can't spend items or energy twice. Pal delve Petals are 40% of a player chest (was 60%; setting `ppal_delve_coin_pct`).
- **Gentler late levels.** Steepness past level 10 is 15% (was 20%) and action XP grows 9% per level past 10 (was 5%). Gnomes already above the new thresholds level up on their next XP.
- **Satchel: using an item keeps your place.** Eating, reading or mending from a Satchel sheet no longer closes the sheet. It stays open with the item's panel (or the sheet, if you used the last one). Pills and panels keep working after the in-place update.

## 2.4.66
- **Studio review follow-up (no gameplay changes).** Phone header: the duplicate menu button is hidden (More in the bottom bar opens the same menu). Status-line links get 44 px tap areas. Satchel loses the repeated heading and the Belt link, and its tile labels and badges are larger. 182 unused CSS rules are removed (about 14 KB). `item_id_by_slug()` replaces 51 identical slug lookups. The zoom and pan blocks in `site.js` share one factory, and petals and burst are shared in `window.gvFx`.
## 2.4.65
- **Studio review cleanup (no gameplay changes).** Contrast fixes: the selected recipe tab and filter chip, the puzzle chip, and the warn, low and effect chips now reach at least 4.5:1. Five undefined CSS tokens (`--bg-2`, `--good`, `--bad`, `--card`, `--panel`) are now defined, 8 duplicate CSS rules are gone, and 15 hex literals use tokens. Shared JS helpers (reduced-motion probe, centre, seen) now live in `window.gvFx` in `early.js`. 21 unused PHP functions are removed, and `trek_item_id`, `tk_h` and `tk_n` now delegate. Reports: `docs/studio-review/`.
## 2.4.64
- **Trek on phones: the map stays put.** Map view: the map sticks under the header (at most half the screen tall); the latest line and Sneak / Camp / Leave follow it, then the cards that need a tap (event, crew, milestone, spot), the party chips, the scene and the map key. New cards no longer push the map down.
- Fight view: the "Where it began" map is no longer a fold that opens and closes; a small map is always shown under What happened, so the page height stays the same all fight.
- Party, Pack and Log open as a bottom sheet over the lower half (was a tall panel), so the map stays visible above it.
- Moving between map and fight scrolls to the map (map view) or the scene (fight). Desktop unchanged.

## 2.4.63
- **Trek fight on phones is shorter.** The health rows under the scene are hidden (the figures already show the HP bars), and the Round heading and the action buttons (Fight, Auto 1, Auto, Run, Change plan) now sit right under the scene. What happened, the boss hint and the party chips come after.

## 2.4.62
- **Trek on phones keeps the stage in view.** When a walk turns into a fight (or the fight ends), and when the fight map folds away, the page now scrolls the stage to just under the header instead of leaving you down the page with nothing to look at.

## 2.4.61
- **Pals can man crafting stations.** New Pal Jobs card "Man a station": pick a station (an object of a crafting area, e.g. Cooking · Stove), tick the pal(s), choose Everything it can make or up to 5 chosen recipes (a closed picker with a filter and a scrolling list, so long recipe lists stay short), and 1, 3 or 8 hours. No energy is spent. Slower than you: one make per 60 minutes at Crafting level 1 (24 at level 10), plus a chance of an extra output as the pal's new Crafting skill grows. Ingredients are taken at send; the dishes arrive when you collect. One pal per station; cooking holds one of your pots; own daily cap (`pj_stations_per_day`, default 4). Pantry jars come later.
- XP from a shift is split: half to you (Crafting XP), half to the pal's Crafting skill.
- Crafting popovers get a "🧩 Let a pal work here" link that opens Pal Jobs on that station.
- Satchel: the Kitchen tile is now called Food.

## 2.4.6
- **Satchel is 8 square tiles** (about 920 px tall page, was about 1500): Seeds, Crops, Flowers, Food, Soil, Tools, Materials, More. Tap a tile and a sheet opens with that group's things: search, chips (for example Soil / Mulch, Tools / Broken, Untasted), sort, and the same item panels and buttons. Typing in the page search counts matches on each tile; Enter or any other filter shows the plain list as before. Quick actions stay under the tiles.
- **One home per thing:** mulch, Food Scrap, Cardboard Sheet and Garden Tonic sit with Soil; broken tools with Tools; parts and decor are Materials; supplies, guides and the rest are More; crops and finds share Crops; flowers and arrangements share Flowers.
- Crafting pages drop the shopping list (a popover's Missing tab already says what you lack).
- Tests: `itemsq.sh` covers tiles, sheets and the plain list. Plan: `claude/plan-satchel-layout.md`.

## 2.4.5
- **Pantry jars are square slots on shelves:** one shelf per kind that has jars (Jam, Chutney, Pickle, Ferment, Cordial), with its count (3/5), each jar a small square (dish and time, "Ready!" with Collect, or an empty jar), standing on a wooden plank. Smaller than the old chips. Cooking pots stand on a plank the same way and are a little smaller.

## 2.4.4
- **Cooking page:** the energy and Petals chips are gone (the top bar already shows them). Each pot is now a square tile: the dish and time left, "Ready!" with a Collect button, or an "Empty" pot (one tile per free pot instead of "+N free pots"). "Collect all" still appears when two or more are ready.

## 2.4.3
- **My Gnome is slimmer on phones** (Overview with pals: about 1700 px down to about 1085 px): Health is one slim line inside the gnome card (heart, bar, hp/max; the potion and snack buttons sit in a closed "Heal" drawer when you are hurt), tabs fit in two rows, fact tiles are two columns, pal slots are smaller, "How to meet your first pals" is a closed fold.
- **Link to Today** (📅 Today →) beside "See your profile as others do" on My Gnome.
- **Crafting area strip never scrolls:** all seven areas share one row on a phone, thumbnails shrink to fit.

## 2.4.2
- **Trip strip ("Heading to ...") is one slim line:** about 28 px tall (was about 95 px on a phone): destination on the left, stops left or leg on the right, hairline progress bar underneath. Style only.

## 2.4.1
- **Crafting pages are shorter:** the recipe list under the scene is a closed fold ("All recipes · N ready · N missing · N to discover") that opens by itself for a tapped object, a search, a List pick or an open recipe. Pantry keeps its jar strip visible. Smaller area thumbnails on phones.
- **Tiny green ! on scene objects** you can make something with right now (also in the object's accessible label).
- **Potions area gets popovers** like the others (Potion shelf, Mortar, Cauldron, Spellbook, Copper still).
- Tests: `craft.sh` and `alchemy.php` updated for the potions objects.

## 2.4.0
- **Crafting scene popovers:** tap an object in a crafting scene (Stove, Bread oven, Jam cupboard, Workbench...) and a sheet slides up with what you can make there, in three tabs: **Can craft** (craft right in the sheet), **Missing** (what is lacking, in red) and **Unknown** (a hint). Works in every area except Potions. Without JS the object still filters the shelf list as before.
- **"Ready" is now honest:** a recipe that needed a building or more energy than you have used to sit in Ready. Ready now means you can make it right now; the rest moves to Missing.
- **Food shows what it gives:** energy and buff on the shop sheet for every edible item, on craft cards and in the popover (satchel, cooking cards and pantry jars already did).
- **Garden square panel is much shorter** (planted square on a phone: about 1090 px down to about 600 px, plus the closed fold). Status chips and ONE "Next:" line replace the repeated advice; "Soil details" is closed by default; one fertility word everywhere (also in yard tile titles); N, P and K are small colour badges (low = ▼, high = ▲, the crop's nutrient gets a ring).
- Also rolled in since 2.3.97: Pal Jobs send/collect several pals, per-pal Where/Tool, Send always visible, tools offered only where they work.
- Tests: `craft.sh` (popovers), `beds.sh` (square panel). Notes: `claude/plan-craft-popover.md`, `claude/soil-display-assessment.md`.
- **Garden square panel is much shorter** (planted square on a phone: about 1090 px down to about 600 px, plus the closed fold).
- Status chips (soil word, low nutrient, care stars or no-till grade, improver working) and ONE "Next:" line (water or harvest now, low nutrient fix, add compost, no-till fix, till it first) replace the repeated advice.
- "Soil details" is closed by default, one fertility word scale everywhere (also in the yard tile titles), N, P and K are three small colour badges (green, orange, purple; low = ▼, high = ▲; the crop's nutrient gets a ring), the Watered row and repeated compost help are gone, and care details sit behind "How care works".
- Test: `beds.sh` covers the panel. Assessment: `claude/soil-display-assessment.md`.

## 2.3.99
- **Pal Jobs, gathering trips:** the Tool pickers only offer tools that can gather in the chosen land (greyed out and hidden otherwise), and the land list only shows lands where one of your tools works. Applies to the job default and to each pal's own pick. Changing the land switches an unusable tool to one that works.

## 2.3.98
- **Pal Jobs:** the job options and the Send button are always shown. Send is greyed and says "Tick a pal to send" until you tick one (before, they were hidden until a pal was ticked, so a card looked like it had no Send).

## 2.3.97
- Test release: version bump only, to check Back up and install from 2.3.96.

## 2.3.96
- **Fix:** "Back up and install" (and every other button that asks "Are you sure?") did nothing in 2.3.94 and 2.3.95. The new double-tap guard counted the first, cancelled submit as sent and then swallowed the OK. The guard now only counts a form once the submit really goes through. Checked in a browser: confirm then OK submits, Cancel then retry submits, a double tap posts once.

## 2.3.95
- **Pal Jobs fix:** in 2.3.94 the job options and the Send button never appeared after ticking pals (the page styles still looked for the old single-pal picker). Fixed.
- **Per-pal choices:** each ticked pal can have its own Where and Tool (trips), Garden (gardens) or Delve, or "As above" to use the job's default. Length and potions stay shared.
- Test checks the styles match the checkboxes.

## 2.3.94
- **Playtest fixes:** batch plant tries the next picked seed when one needs richer soil; harvest says the square is bare and needs tilling; plant list and shop seeds show XP per harvest; Crafting refuses quantity 0, negative or text; garden names cannot use `<` or `>`; Adventure shows fresh energy; Jobs show when each period ends and that progress does not carry over; repeated flash messages no longer stack (log capped at 20).
- **Double taps:** a form sent twice within 2 seconds is done once (browser and server). The server sends you back to the same page and says "Already done: that was sent twice."
- **Races:** two walks started at once keep only the first (energy refunded); two hires cannot take the last helper slot.
- **Pal Jobs:** tick several pals and send them on the same job in one go (each keeps its own limits; "N of M pals sent"). "Collect all" when 2 or more jobs are ready, with one receipt.
- **Animals:** the feeder card shows its cap and the per-gift need ("6/6 · 4 scraps per gift") instead of "6/4".
- **Tests:** `paljobs` covers multi-send and Collect all; `walk` listed as self-installing in `ci_suites.sh`. Report: `claude/playtest-report.md`.

## 2.3.93
- **Polish pass** (audit and notes in `claude/polish-audit.md`, plan in `claude/plan-polish.md`). Look and navigation only; no database change, no new settings.
- **Status strip** no longer scrolls sideways on tablet and desktop: the chips wrap to a second row. **World header** image stacks above the title between 721 and 999 px (it covered the title at 768 px). **Menu labels** wrap instead of being cut ("Whisker Po...", "Gnome frie..."). **My Gnome / Mentor tabs** wrap onto rows on phones (7 tabs, 299 px of them were out of sight).
- **Menu:** the duplicate "Whisker Pond" tile is gone (Cat Fish is a tile on Games; its page name is Cat Fish); Games lights up on Cat Fish, Puzzles, Jigsaw, GIFsaw, Rain Barrel, Gnome Beds, Fair, Village Show and Garden of the Month; Pal Jobs lights up Puzzle Pals. "Gnome friends" is now "Friends".
- **Pals:** Pal Book and Pal Jobs share one tab row.
- **Villagers:** every villager link goes to `villagers.php`; `folk.php` is a redirect stub (POST kept); the dead "Villagers you know" list in Town and the unused `folk.php` page template are removed.
- **Tap targets and focus:** logo, footer links and the status badge have 44 px hit areas; keyboard focus draws a dashed ring on the world, region and mycelium map links (it only changed fill opacity before).
- **CSS:** width breakpoints 24 down to 17 (430 px phones now get the compact header and tab labels of 412 px phones; Almanac spread at 721-760 px has more padding); three min/max pairs that both applied at one exact width fixed. New `tests/css_lint.sh` in CI.
- **Tests:** `gather150` assertions updated for per-landscape scene art and the gather form id; `tests/polish_audit.js` added; landing shots regenerated.
- **Docs:** `PRODUCT.md`, `DESIGN.md` (drafts, marked where inferred), `claude/css-map.md`, `claude/ci-2.3.92.md`.
- No player news entry. Not run: MySQL, phone check (Joshua).
## 2.3.92
- **Cat Fish, fewer queries:** `catfish_extra_mult()` takes the caller's `catfish_state()` row for the Buddy check instead of reading it again, and loads the pictures behind a gnome's found Puzzle Pals with one `IN (...)` query instead of one per picture. No change to what players see or earn.
- **Tests:** `tests/catfish.sh` passes again (0 failed): the Puzzle Pals bonus checks use the 2.2.3 values (+4% a common pal, best 10 count), the hub check counts the Games tile, not the menu's own link, and the bunting checks measure the jar's change, not its total.
- No player news entry (nothing visible changed). No database change.
## 2.3.91
- **Merge:** brings the 2.3.9 branch (Boons, health bars, Pantry rooms) together with `main`'s 2.3.8 (shorter Stamp passport).
- **Here page:** a Puzzle Pal waiting at your spot now also shows its "Say hello" card on the Here page (rest stop and town square), not only on World > Go.
- **Pal actives stack:** pals with the same active skill give one fight button at double (or more) strength, not a second button.

## 2.3.9
- **Puzzle Pal Boons** (from 2.3.8, still OFF: `ppal_boons`, needs `ppal_party`): all 570 pals have a Boon, rares have an active skill. Included here again so one zip carries everything since 2.3.4.
- **Health bars:** the My Gnome bar is a `<progress>` that shows the live value (the old inline `style="width"` was blocked by the CSP, and the stored value was stale while out on a trip, `hp_display()`); new health bar beside the level bar in the top bar (`status_strip`, desktop pill and phone line, `hp_bar_html()`).
- **Pantry rooms:** every kind (jam, chutney, pickle, ferment, cordial; `PANTRY_KINDS`, `pantry_kind()`) has its own set of jars, each with the same count the Pantry gave in total (`pantry_free()`, `pantry_busy_by_kind()`). Per-room counts on the Pantry tab and Kitchen tile. Tests updated in `tests/pantry.sh` (a full jam room does not stop chutney).
- Player news entry added.

## 2.3.8
- **Stamp passport, shorter.** Town > Stop tab, about 75% shorter on a phone (390px: 5800px to about 1400px) and on desktop (1366px: 4492px to about 1040px). One summary bar, a "Next up" list of the three closest sets, and closed folds for Titles earned, All sets and rewards, Stops by kind and the Road Journal. Regions are rows with a count and a bar; only your current region opens, with small stamp thumbnails. Regions with no stamps share a "Not started yet" fold. Desktop: sets and regions in columns that follow the tab width (container query `stoptab`), Road Journal beside Seasons & weather.
- Built from the site's own parts: `h2.gx-h` / `.gx-note` headings, `.box` panels with `details.fold` rows. The Seasons & weather summary now reads "Seasons & weather" with Summer and the weather beside it, so it no longer wraps (shared `season_fold_html`; rest-stop Stop tab checked).
- Files: `includes/stop_pass.php`, `includes/place_ui.php`, `includes/road_life.php` (journal is a closed fold), passport block of `style.css`. No schema change, no new settings. Tests: `stops100`, `roadkinds`, `roadlife`, `roadtext`, `villagers`. Not run: MySQL, phone check.

## 2.3.8 (Boons build, folded into 2.3.9)
- **Puzzle Pal Boons (OFF: setting `ppal_boons`, needs `ppal_party`).** Every one of the 570 pals has its own combat Boon instead of its calling skill: 16 effects (ward, edge, foot, mend, sip, petal, guard, bulwark, slip, feast, rally, first, kindle, spoils, lesson, tonic) in `includes/data/puzzle_pal_boons.txt`, sizes by rarity in `PPAL_EFFECTS`. Rosters are unique (no two share 4+ effect/rarity pairs). Pals of uploaded pictures get a seeded Boon (`ppal_seeded_boon`).
- **Rare actives:** each rare has one once-per-fight skill (strike, shield, patch, snare, sap, daze, rouse, gust) as a fight button (`palskill:KEY`, three fight renders), uses the turn, no dice.
- **Tools and tests:** `tools/lint_pal_boons.py` (`--require-boons` in `tests/puzzle_pals.sh`), `tools/pal_boons_draft.py`, `claude/pal-boons-sim.php`, Boon sections in `tests/puzzle_pals_party.php`. Design: `claude/brainstorm-pal-rosters.md`. No schema change, no player news (feature hidden).
- Also: the Pal Book test no longer fails when a pal happens to wait on the map.

## 2.3.7
- **Merge release.** Alchemy: 7 new potions (`includes/alchemy.php`; Strong Healing, Grand Healing Elixir, Lucky, Sage's, Stoneskin, Swiftfoot, Garden Tonic), each usable by the gnome (Satchel Drink, My Gnome Potions box, Garden Tonic on a plot) and some by pals; B icon set. Crafting map: per-object recipe tags (`?o=`), one recipe pass for the landing badges. Pantry: 11 new icons (B), hidden Brewroot Pomeroy task (needs `gourmand_open`), tests honour TMPDIR.
- **Puzzle Pals: page mode removed** (map mode only; settings `ppal_find_mode`, `ppal_chance`, `ppal_cooldown_minutes`, `ppal_daily_max` gone), "pal arrived" notice on the daily top-up.
- **Pal Jobs:** no level gates (every pal does every task from level 1; level scales yield), Risky tag for delve jobs below Adventuring 5, pals work after hired garden help instead of being refused, "N pals home with loot" notice on Today and My Gnome, clearer Collect receipt.
- **Delve v2 (still OFF):** each delve has its own hazard with a real effect (health or torch), wandering creatures (`dv_enc_steps`, `dv_enc_chance`, `dv_enc_cap`), torch fuel 30/45/50, pal re-runs walk the gnome's route, 26 authored floors (Beaverdam, Salt Mine, Firefly Caves; names DRAFT).

## 2.3.6
- **Crafting area map.** The Crafting tab opens on a picture map: seven cards (Cooking, Pantry, Tools, Garden supplies, Potions, Building, Yard & decor), each a new Stitched Toy scene with a progress bar ("8 of 85 known") and a badge (needs the building (Locked), N ready, N jars done). Inside an area, an "All areas" button, a scrolling picture strip to switch area, and the area's scene with five tappable objects (oven, stove, anvil, cauldron...) that open that area's list filtered by what they make. All plain links, so it works without JS; labels show on hover, focus and on touch screens.
- The Make dropdown is gone from Cooking, Pantry and every other area (the List dropdown stays).
- Files: new `includes/craft_map.php`, `includes/data/craft_scenes.php` (hotspot boxes), 14 pictures in `assets/img/craftmap/`; `craft_view.php`, `craft_shelves.php`, `pantry_view.php`, `inventory.php`, a 2.3.3 block at the end of `style.css`. Art sources: `aseprite-source/scenes-pil/craft_*.py`, `aseprite-source/craftmap/`. Test: `tests/craft.sh` (area map section).

## 2.3.5
- **Health stays with the gnome.** Before, every adventure (road walk, off-road explore, delve, lair) started at full health. Now `users.hp` (NULL = full) is carried into the next adventure. It comes back at 1 a minute while the gnome stands in a village, market, hub or haven and is not adventuring (a clock in `users.hp_at`), by resting at a haven fire (half) or staying the night (full), by a rest-stop inn or table (half) or bath/soak (full), by a Healing Potion (half) or a home-cooked snack from My Gnome, and fully on a level up. A knock-out wakes at half. Treks keep their own party health. My Gnome has a Health box. Settings: `hp_persist` (off = the old full-health starts), `hp_regen_per_minute`, `hp_ko_percent`, `hp_rest_percent`, `hp_potion_percent`. New columns `users.hp`, `users.hp_at` (additive). Code: `includes/health.php`. Test: `tests/health.sh`. News entry added.
## 2.3.4
- **Delve finds use the chest animation** (`delve_v2` only). Picking up a find, a floor chest or Mo's gift now pops the delve chest over the page (a short version for small finds, the full one for a floor chest) with what you got, instead of a notice under the map you had to scroll to. Petals and XP show only when there are any. The guardian's chest is unchanged.
## 2.3.3
- **Delve redo (first playable cut, OFF by default).** New setting `delve_v2` (Admin > Settings, "Delves: route menu and tile floors"). Off: delves play exactly as before and a delve already running finishes on the rules it started with. On: a delve is 3 or 4 stages. You pick the next stage from a small route menu (creature, treasure, mystery, puzzle, shrine, Mo the mole, then the guardian), each floor is a tile map with fog and a torch (each step burns it; at 0 your light shrinks, nothing else happens), with finds, creatures, traps, chests, keys and doors, shrines and the way down on it. Your gnome and the pals taken along show in a strip under the map. One expedition per delve, one energy to go in (no per-room energy), the same guardian chest and clear count. The route is the same for a gnome and delve all day.
- Each of the 14 delves has its own chamber library (25 hand-made terrain chambers each, `includes/data/delve_chambers.txt`); floors are 4 chambers stamped in a 2x2 grid with doorways and objects. Authored floors can be added to `includes/data/delve_floors.txt` (empty for now) and are used first. Lint tools: `tools/lint_delve_floors.php`, `tools/lint_delve_chambers.php`, `tools/check_chamber_dups.php`.
- Tests: `delve2`, `delvefloors`, `delveroute`, `delvestamp` (new), `delvemap` unchanged. Plan and checklist: `claude/plan-delves.md`, `claude/checklist-delves.md`.
## 2.3.2
- **Pal jobs: an equipped pal is not sent by accident.** A pal on your party shows an "On party" tag in the pickers. Picking one shows a "Take it off my party to send it out" box that must be ticked; without it the send is refused with a message. Works without JS (the server checks). Tests added in `tests/paljobs.php`.
## 2.3.1
- **Pal Jobs page redesigned.** Three tabs: **Out** (a ledger of pals on jobs with live countdowns, bars and a Collect button that appears when a pal is due), **At home** (HP, skills, Give a potion) and **Jobs** (garden, gathering trip, delve re-run). Each job has a **Send a pal** button that unfolds a ranked pal list and its options; one is open at a time. One-line counts row (runs left, Potions linking to Crafting, Pal Book). Works without JS (the sections stack and the forms stay open).
- Back/Forward and reload: forms do not keep old picks, Send is re-enabled on Back, and a failed send returns to the tab you posted from.
- Pal Book and Pal Jobs use the community area colour.
- Files: `paljobs.php`, new `assets/paljobs.js`, pal jobs block of `assets/puzzles.css`, `layout.php`. Logic in `includes/pal_jobs.php` unchanged. `tests/paljobs.sh` updated (pal rows are `pjrow`).
- No player news (Puzzle Pals is still off for players). Not run on MySQL.
## 2.3.0
- **Pal jobs** (Puzzle Pals, gnome level 10+, setting `pj_open` / `pj_min_level`; Puzzle Pals itself still gates who sees it). A found pal can tend a garden (beside hired helpers, no Tool Shed slot: waters, weeds from Gardening 3, harvests at 9), go on a gathering trip (tool, place, 1/3/8 h, packed Healing Potions) or re-run a delve you have already cleared (about 60% of a real clear, once a day per delve). New `includes/pal_jobs.php`, page `paljobs.php`, table `ppal_jobs`.
- Every found pal has its own 16-hex id and two levels (Gardening, Adventuring, 1 to 10) plus HP. A duplicate find gives +15 XP of each kind; a pal taken along earns 1 XP of each kind an hour. A pal at 0 HP goes home early; HP regrows at home. Trips and delve runs are rolled once at the start from a stored seed; Collect pays once.
- **Healing Potion**: new item, crafted (Crafting > Potions: 2 Meadowsweet + 1 Sphagnum Moss) and sold at Twigg's Seed Emporium.
- Limits: 3 pals out at once and 6 trips/delve runs a day (settings `pj_max_away`, `pj_runs_per_day`).
- Tests: `tests/paljobs.sh`.
## 2.2.61
- **Satchel and Crafting redesigned (Shelves).** The Satchel is a Quick bar (one-tap Eat, Open, Read, Mend) above foldable type shelves of compact pills; tap a pill to open its details in place. Every Crafting tab except the Pantry shows the station strip (pots, energy, Petals, or the Tool Shed), a Shopping list of what to gather for recipes one trip away, a search box (also matches ingredient names) and shelves: Ready, One trip away, Need more, To discover. The picked recipe opens inline with "You have / Still need" and the Make buttons. Phone page heights: Satchel 5,859 to 3,284 px, Cooking 6,319 to 1,731 px. New `shelves.php`, `satchel_view.php`, `craft_shelves.php`; `.shelves` block in `style.css`, a Shelves block in `site.js`; the big item squares are gone from the Satchel and from known recipes. Sell and Gift link to the market tabs.
- **Making something keeps its recipe open.** After Make, you come back to the same recipe (`?r=`), scrolled to its row, instead of every panel closing.
- Tests: cook, craft, eggs110, animals120, animals140, itemsq, images, flowers, sinks097, pantry, yard, tools, guest and security190 pass as on the base; assertions updated in `itemsq.sh`, `images.sh`, `craft.sh`, `cook.sh` for the new markup. Known failing on the base commit too: `gather150`, `folkoverlay`. Full CI not run.

## 2.2.6
- **Pantry phone sheet slimmer.** The selected-recipe sheet shows one slim line per ingredient (icon, name, have/need) instead of the big squares, with a smaller title and tighter buttons. It starts closed; tap its header to open or close it (chevron shows the state); picking a recipe from the list opens it. Desktop unchanged.
- Known failing on the base commit too: `gather150`, `folkoverlay`. Only `tests/pantry.sh` was re-run (2.2.5).

## 2.2.5
- **Pantry redesigned (master-detail).** The Pantry tab is now one row of jar chips (Collect on each ready jar), a search box, Ready / Missing / To discover chips plus kind chips (Jam, Chutney, Pickle, Ferment, Cordial), a compact recipe list and a detail panel for the selected recipe with its ingredients and the Make buttons. On a phone the detail is a sticky sheet above the bottom bar, folded until a recipe is picked; the page is about 3,700 px tall instead of about 15,000. New `game/includes/pantry_view.php`, `.pantry2` block in `style.css`, a few lines in `site.js`; `tests/pantry.sh` updated for the new markup. Forms still post to `crafting.php`.
- **Menu:** Garden, Arranging, Games, Whisker Pond (Cat Fish) and Puzzle Pals sit in a new **Hobbies** group (Whisker Pond and Puzzle Pals only while open). Games moved there from Out & about. On phones the menu sheet skips Garden, World, Satchel, Here and Tasks (already in the bottom bar); desktop keeps them.
- Added the impeccable design skill under `.github/` and the Pantry mockups under `docs/pantry-mockups/`.
- Known failing on the base commit too: `gather150`, `folkoverlay`. Only `tests/pantry.sh` was re-run for this release.

## 2.2.4
- **Puzzle Pals: finds reworked for map mode.** The Advanced-solve win card and notification say the pals wait at places on the map; the finder perk reads "+N% chance of an extra Puzzle Pal on your map each day"; a line on the World Go tab counts the pals waiting (and flags a rare one) with links to the map and the Pal Book; the Pal Book explains when nothing is waiting. Admin: Tools > "Test a pal find" puts one pal on your map now in map mode (the old find card in page mode); the chance, cooldown and daily-max settings are labelled page mode only. `ppal_on_solve` returns an extra `mode` field. No schema change. Features stay off for players (`ppal_open` 0), so no player news.
- Known failing on the base commit too: `gather150`, `folkoverlay`.

## 2.2.3
- **My Gnome shows pal combat skills.** Each pal row on My Gnome lists its skill ("... · ⚔️ Thorn Ward 2"), and the Pals tab's "What your pals do now" lists the party's combined skills. Before, skills showed only in the Pal Book.
- **Cat Fish: Puzzle Pals found now pay Kibble by rarity** (common +4%, uncommon +8%, rare +16% each; the best 10 pals count; total capped at +50%). It was a flat +2% per pal, max +20%, so it had not moved with the 2.2.2 perk scale. Applies to pals found, equipped or not.
- Known failing on the base commit too: `gather150`, `folkoverlay`.

## 2.2.2
- **Puzzle Pals: bigger perks.** A perk unit is now one percent: common 8%, uncommon 15%, rare 30% (gather, finder, tinker, bloom); road is +1 / +2 / +4 points. The Expert trophy adds +4 (+1 road). Caps 50% (road +5). A single common road pal no longer gives 0, and the road perk uses `PPAL_PARTY_LEVEL` instead of a hard-coded 15.
- **Puzzle Pals: pals wait on the map** (setting `ppal_find_mode`, default `map`; `page` = the old random page find; `ppal_spawn_count`, default 3). New table `ppal_spawns` and column `users.ppal_spawn_day` (additive, made by `ppal_ensure()` / `db_migrate`). Each Hollow day a gnome's map is topped up to 3 waiting pals from released rosters, kept until collected (never rerolled). Level bands round the gnome's level: common g-2..g, uncommon g-1..g+2, rare g+1..g+3. A Places picture's pals wait at their own place when it is within a level of the band. The finder perk is the chance of one extra pal. The pal's sticker with a rarity ring replaces the place icon on both region maps (a corner badge keeps the kind), a 🧩 badge marks regions on both world maps, "Say hello" collects it on the World Go tab, and the Pal Book lists the waiting pals. Everything stays behind `ppal_open`.
- **Puzzle Pals: passive combat skills** from the pals taken along (road, lair and delve fights only; Treks and contests untouched): Thorn Ward, Keen Edge, Fleet Foot, Mend, Sip, Lucky Petal by calling, scaled by rarity; a rare also carries a second calling's skill. Flat numbers, no extra dice; `combat_math_golden.php` is unchanged. Tests: `puzzle_pals_map.php` (new), `puzzle_pals_party.php` (skills, whole combat rounds).
- Known failing on the base commit too: `gather150`, `folkoverlay`. Puzzle Pals stay off for players (`ppal_open` 0), so no player news.

## 2.2.1
- **Pantry: 137 new preserves (17 to 154).** Jams, curds and marmalades, chutneys, sauces and pastes, pickles, ferments (kimchi, miso, soy sauce, tempeh, cheeses, kombucha), cordials and syrups, dried goods, spreads and spice blends, all in `recipes.txt` (imported by the existing `ensure_crafts()` boot step). No alcohol. Each has its own 16 px item icon (155+ new icons in all, with a jar-and-label look); specs in `aseprite-source/img-redraw-full/specs/ph/`, plan and numbers in `claude/balance-pantry.md`, art cost in `claude/art-pantry-estimate.md`. Quick one-day jars show spoon bars 42/49/55.
- **Pomeroy Crumbworth recipes: 16 more preserves (156 in all)** for the Gourmand feature (below).
- **Gourmand (Pomeroy Crumbworth), OFF by default.** Admin setting `gourmand_open` (0 = nobody sees anything; 1 = on after a player has played through a region). Table `gourmand_ledger` and column `cook_pots.score` (schema change, additive, made by `db_migrate` on the first request after upload). Design: `claude/plan-gourmand.md`, `decisions-gourmand.md`, reviews `review-gourmand.md`, `review-gourmand-rewards.md`. Tests: `tests/gourmand.sh`.
- **Fixed: `give_item()` / `item_quality`** (quality of a given item was lost or mis-recorded on some paths).
- **Market / Pantry balance fixes:** preserve prices came from a stale cache (fixed) and six jars were repriced once (one-time step); stall rarity multiplier (a stall could be used to arbitrage); a preserve time curve (longer timers pay more); five recipes retuned; the `dried-*` filter no longer lists non-recipes.
- Tests: `pantry.sh`/`pantry.php` count preserves from `recipes.txt`; `eggs110.sh` expects 14 egg recipes; new `gourmand.sh`. Known failing on the base commit too: `gather150`, `social100`, `catfish`, `folkoverlay`; the reset-install check fails on base as well.

## 2.2.0
- **Cat Fish page layout.** Upgrades are four branch tabs with buy buttons that show only the cost. The Shelter is a fold whose closed header shows the day's three cats. The folds below the cats became a six-tile hub (Nap, Yarn, Milestones, Cat Show, Your cats, Cat Book) with a status line on each tile; "Home" is now "Yarn". Cat rows are slim (Play, and Rename, bio and collar behind a pencil). The Cat Book has pattern tabs with named colour tiles. Everything still works without JavaScript (all panels stack).
- **New ways to spend Yarn:** Buy x10, Longer naps away, titles "Cat Person" and "Napmaster", Hold a cat, Stakeout, a second Cat Show entry, a Buddy cat, Keepsake, yarn ball colours, a Yarn scarf for your gnome, Yarn bunting for the festival jar, Rod Tune-up, Catnip Hour, Mood Treat, cat bio lines, collar tints and a seasonal room. The Yarn panel is grouped into three folds. Profiles show a ribbon shelf with a count per tier.
- **Adventure fights:** your panel is now on the left under your gnome and the creature's is on the right (fight card, the open-bar duel box and the Fight on replay).
- **Wandering and exploring** (not treks) now shows the Puzzle Pals you took along beside your gnome on the scene.
- **Art for the Yarn sinks is in** (1348 PNGs now in `game/assets/img/catfish/`, plus `gnome/gnome-scarf.png`; no PNG still falls back to the old emoji / CSS): the Yarn scarf is a tinted pixel layer on the gnome (red dashed placeholder only without the PNG); collars are a neck-band layer on the cat in 6 colours (idleA, pounce, catch, nap and the idleA blink/tailflick/eartwitch; the CSS ring stays as the fallback); seasonal room bits are petal, firefly, leaf and flake sprites (the CSS dots stay as the fallback); coloured yarn balls are real recoloured sprites (the CSS colour filter is gone); the window bird and the rolling yarn were redrawn; the Yarn panel rows have their own 64 px icons instead of emoji.
- **Phone:** the four upgrade tabs (Fish, Rod, Room, Cat) now share the width at 390 px; the fourth used to be cut off at the right.
- **Cat Fish pet shops (server, UI and art).** Eleven pet shops, one beside the market of each region from the Sunsprinkle Isles on (Maplewold, Maizehollow and Mistmoor have none), each with its keeper (round the clock, Petals only). 55 room things (22 just for looks, 23 small passive bonuses, 10 you tap) go in 8 spots in the Cat Fish scene: shelf left and right, window sill, picture frame, ceiling, two floor spots and a rod charm. Swapping is free; the shelf right opens after buying in 1 shop, the frame after 3, the floor corner after 5, and the ceiling (5 Yarn) and rod charm (15 Yarn) with Yarn. Passive things add Kibble % (summed, no cap), away time, rare fish, Catnip time, Cat Show points or the first taps of the day; things you tap give minutes of Kibble, a Yarn chance (at most 1 a week), a free shelter reroll or a text hint (Cat Book hints write nothing). They must sit in their spot for an hour before use, have their own cooldown (kept when swapped), and all together give at most 4 taps and 60 minutes of Kibble a Hollow day. New Room things panel in the Cat Fish hub (seventh tile), a shop page per pet shop (banner, keeper line, the five things, buy button), `do=petslot`, `do=petuse` and `do=petunlock` in `catfish_api.php`, `do=pet_buy` in `shop.php`. Table `catfish_items` (made on demand), meta keys `slots slotn pa py phint rain`, ten admin settings `catfish_pet_*`. Without the PNGs everything shows a red-outlined placeholder; the real sprites, banners and busts sit in `aseprite-source/catfish/art22/out/` for the install step. Code: `includes/catfish_pets.php`, data in `includes/data/catfish_pets.php`, rectangles in `aseprite-source/catfish/room-layout.json` `pet_slots`.
- **Pet shop art is in:** 55 room things (`cf-pet-<key>.png`) and 11 shop banners (`banner-<CODE>-pets.png`) in `game/assets/img/catfish/`, and the 11 shopkeeper busts in `game/assets/img/ph/npc-<name-with-hyphens>.png`, where the NPC portrait loader finds them without an admin upload. No file still falls back to the red-outlined placeholder. `tools/catfish_build_art.py` installs and checks all three (1414 PNGs in the Cat Fish folder + 11 busts); `tests/catfish.sh` fails on a missing or wrong-sized item, banner or bust.
- Tests: `tests/catfish_build_art.sh` and `tools/catfish_build_art.py` now know the 2.2.x files (collars via `tools/catfish_recolor.py`, season bits, coloured yarn, Yarn icons); many new checks in `tests/catfish.sh` (pet shops: slots, fit, cooldown, caps, Yarn odds and weekly cap, hints, buying, scene, `pet_slots` against the CSS) and `tests/catfish_pets.js` (the room things in a browser); `tests/catfish_anim.js` clicks the upgrade tab before buying. `tests/social100.sh` fails on the base commit as well.

## 2.1.14
- **Phone: the "Visit <place> now" button is full width and centred.** After you find a hidden place while wandering, its lone button sat in half of the 2-column action grid, pushed to the left. A button that is alone in its list now spans the whole row with centred text.

## 2.1.13
- **Phone: the d20 problem card ("Pick an approach") uses the compact layout too.** It was the one event still on the old tall layout. The question now sits beside the ring map with the "Pick an approach" line under it, and the answers are a 2-column grid. The "Latest:" line is no longer repeated above a problem card (it said the same thing as the question).
- Tests: `tests/advforce.php problem` and a `problem` shot in `tests/adventure.sh`.

## 2.1.12
- **Phone: event cards use the compact wander layout too.** A road event (a choice, someone met on the road, a problem) used to fall back to the tall layout (banner, big map, then the card), so the answers sat below the first screen. They now get the same layout as the wander screen: ring map left, place line and the event text on its right, the answers as a 2-column grid below. A problem card keeps its full-width answers. Fights are unchanged.
- Tests: `tests/advforce.php choice` and a `choice` shot in `tests/adventure.sh`.

## 2.1.11
- **Phone: the wander screen fits on one screen.** Off the path, up to 720 px wide: no stage banner on top; one row with the ring map (112 px, centred in its space) on the left and, on its right, the place and tier line, the latest result and the story line; the four actions below as a 2 by 2 grid (energy cost as a corner badge); then two folds, closed by default: **Gather here** (the scene picture at 82% width, the tool belt right under it on one line with no heading, felt cards, What's here; it opens by itself when a find has just come in) and **More** (the country notes and the knocked-out reminder). The heading, status line and the "swipe to see the whole map" hint are hidden there. Fights, other adventure cards and desktop are unchanged (the folds start open on a larger screen).
- Action labels shortened everywhere: Go deeper, Keep exploring, Step back, Head to the road (the cost is already in the badge).
- After a fight ends on the wander layout the action buttons are centred (`gvFightScroll` falls back to `.choicelist` when there is no card box).
- Code: `.advgrid.wander` (adventure.php), `.wfold` folds (`gvWanderFolds` in site.js), `.gx-h--belt` class on the belt heading, `.hoopcap-tip` span in the map caption. Tests: `tests/adventure.sh` has a wander step (`advforce.php wander`, shots `wander` and `wanderopen`).

## 2.1.10
- **Phone: after a fight ends the action card is centred.** When a fight finished (win, lose, flee, Fight on, Auto-win) the tall fight card vanished and the old scroll position left the page mid-way. `gvFightScroll(ended)` now notices that the page had `.advgrid.fighting` and no longer does, and centres the `.encounter` card between the header (and the adventure bar) and the bottom bar; a card taller than that is put at the top. Re-placed at 60 ms and 350 ms like the banner, unless the gnome scrolls. Desktop and other pages are unchanged.
- **Phone: smaller hoop map.** Up to 720 px wide the ring map is 170 px (was 250 px) and it is hidden, with its caption, while a fight is on, so the stage banner and the fight card get the room.

## 2.1.09
- **Phone: the fight / wander scroll now keeps the whole stage banner in view.** The scroll ran before the message log, folds and banner image finished changing the layout, so it could land with only a sliver of the banner showing. `gvFightScroll` now places the banner again at 60 ms, 350 ms and when the banner image loads (skipped if the gnome has started scrolling).

## 2.1.08
- **Cat Fish: what you buy now shows in the room.** The four Cat upgrades had no picture in the scene; they do now, each drawn over the room (`cf-room-bowl|toybox|cattree|catflap.png`, 320 x 200, made by `aseprite-source/catfish/cf_room_cat.py`): Fancy bowl (a gold-rimmed bowl on a felt mat, in place of the plain one), Toy box (a crate with a teddy and balls, on the end of the rug), Cat tree (a two-level tree beside the fish) and Cat flap (a hatch in the wainscot). Stack order back to front: window, sunbeam, rug, cat flap, cat tree, scratch post, toy box, bowl. No PNG = nothing drawn, as before.
- **Rod upgrades show too** (classes on `.cfstage` from `catfish_rod_classes`, in the scene key so a buy redraws): Longer string lowers the fish on longer strings, Springy rod makes the fish bob, Rod motor turns the wand, Double rod hangs a second wand at the end of the line. `steps()` only; none under reduced motion.
- **A quick flash on a buy that changes the room** (`.is-new`, 0.6 s, none under reduced motion), so the new piece is noticed.
- **Phone:** the fight / wander scroll now brings the whole stage banner (`#advstage`, where the fight animations play) into view, with the fight card right under it; before it lined up the card and the banner scrolled off the top.
- Art: `tools/catfish_build_art.py` knows the four new overlays; `claude/catfish-art-brief.md` updated.
- Tests: `tests/catfish.sh` (each Cat buy answers with its overlay, stack order, Rod classes, second wand).

## 2.1.07
- **Cat Fish buy flow fixed** ("pressing buy doesn't update the Kibble, I have to reload"). Root cause: the server buy was right, but the page only changed the Kibble number when the reply arrived, counted unconfirmed fish-tap Kibble as spendable although the buy request did not carry those taps (so the server could refuse and the number jumped back), and never redrew the scene, so new room overlays, fish kinds and the bird or dust only showed after a reload.
- **Optimistic buy** (`catfish.js`): the cost leaves the counter at once, the pressed button stays off until the reply, a small `-N` rises by the counter (class `cfspend`, reduced motion = fade only). The request carries the pending taps (`play`, `seq`, as in the 30 s tick; one request at a time so the same batch is never in two), the reply replaces the guess with the server view (Kibble, rate, rows, run). A refused buy puts the number right and says why; a lost reply gives the cost back and keeps the taps and `seq` for the next tick.
- **Server** (`catfish_api.php`): `do=buy` accepts optional `play` and `seq` and runs `catfish_play` (unchanged: a replayed `seq` pays 0, the bucket and the daily cap hold) before `catfish_buy` inside one lock, so the cost check sees the paid taps. Both `do=buy` and `do=tick` answer with `scene` (a short key from `catfish_scene_key`) and, when the page's `scene` differs, `stage_html`, the stage markup `catfish.php` prints (`catfish_scene`). A tick without a `scene` gets none; a buy without one always gets it.
- **Live scene**: `catfish.js` parses `stage_html` with `DOMParser`, swaps the `.cfstagewrap` in place and fires `cfscene`; the animation machine is now `init()`/`stop()` (all its timers check a `dead` flag) and re-binds to the new nodes, keeping the cat's frame, nap state and facing; pending taps and combo stay; fish taps use one delegated listener. No page reload, no inline script or style. The plain form post still works without JS. Nap, adopt and cat switch stay plain posts.
- **Phone:** the fight and wander card scrolls back into view after a page load or an in-place update (no smooth scroll, so no animation is missed).
- **News:** one post for 2.1.05, 2.1.06 and 2.1.07 ("Cat Fish comes alive", key `2.1.07`); the separate 2.1.05 and 2.1.06 entries are gone, 2.1.04 is untouched.
- Tests: `tests/catfish.sh` (buy with play, replayed seq, caps, refusals, scene key and `stage_html` per upgrade), `tests/catfish_anim.js` (instant cost, `-N`, overlay and new fish without reload, cat keeps animating, taps still work, play rides the buy, refused and failed buys restore, reduced motion, no JS).

## 2.1.06
- **Cat Fish: a livelier room.** The active cat now has idle variety: every 15 to 30 s a yawn (900 ms), a stretch (900 ms) or a paw wash (washA, washB, washA, washB, 600 ms each), only from idleA and never during a play loop, a nap or boredom (a tap cancels it). The four frames are full frames, lazy-built from the manifest like the 2.1.05 ones (`CATFISH_FRAMES_LAZY` is 11 frames now).
- **Window bird:** with the owned Room upgrade `window` the bird perches on the sill (`cf-bird-1`, 12 x 10 drawn at 2x at `room-layout.json` bird {-2, 44}), hops (`cf-bird-2`, 150 ms) or spreads its wings (`cf-bird-3`, 200 ms) every 6 to 14 s. catfish.js swaps the window overlay's robin for the sprite (`.is-bird`); without JS or with reduced motion the static `cf-room-window.png` stays. Art note: the sprite carries a 1 px dark outline the overlay robin lacks (104 px at 2x); every robin pixel is identical.
- **Yarn roll:** when the cat swats (swatB) or pounces the ball at the left of the floor rolls 8 px right and back in 1.2 s (the patch `cf-room-yarnpatch.png` clears the ball, `cf-yarn-1..4` roll in 150 ms steps) and the base ball is back afterwards. `CATFISH_YARN_ROLL` in catfish.js turns it off.
- **Code-only ambience** (CSS `steps()`, no blur): six dust motes drift in the sunbeam (only with `sunbeam`), the rug overlay wobbles 1 px twice when the cat swats or pounces (only with `rug`). Reduced motion: all static, no motes. New layer classes `cfl-<upgrade>` on room overlays.
- Test hook: `?cffast=1` on the page URL shortens the idle variety and bird waits tenfold (nothing else reads it).
- Tests: `tests/catfish.sh` (markup with and without the upgrades, bird/yarn art checks against `room-layout.json`, css/js), `tests/catfish_anim.js` (variety frames over time, wash order, bird frames, perch pixel compare, yarn roll, rug wobble, reduced motion).

## 2.1.05
- **Cat Fish: more moves.** The stage cat now swats the fish you tap (swatA 120 ms, swatB 200 ms, catch 600 ms, happy 500 ms), hops for joy (a 5 step jump arc) on a combo of 5 or when the top fish is tapped twice within 1.5 s, blinks every 3 to 6 s, flicks its tail and twitches its ears at random 5 to 12 s intervals while idle, shows a floating z while it naps (also on a napping cat on the cushion), and sparkles over a glitter fish and at combo 10. The cats around the room alternate idleA and idleB on their own seeded timers and the nearest awake one stalks when the active cat swats. Reduced motion: static idleA, nothing extra.
- **Alias frames:** blink, tailflick and eartwitch are idleA with only a few layers swapped; `catfish_cat_html` composes them from `CATFISH_FRAME_BASE` and `CATFISH_FRAME_OWN` (which `tests/catfish.sh` checks against `frames-alias-s2/s3.json`). Layers are listed by `catfish_cat_layers`; the other 7 frames of the cat are built by `catfish.js` from a small JSON manifest block (`#cf-frames`) and preloaded after the first interaction or 2 s, so the page markup stays at 8 frame groups.
- **Art:** 1281 PNGs now (667 new): swatA, swatB, jump, happy, yawn, stretch, washA, washB (full overlays), blink, tailflick, eartwitch (alias layers), `cf-z`, `cf-sparkle-1..3`, and the 2.1.06 room pieces (`cf-bird-1..3`, `cf-room-window-nobird`, `cf-yarn-1..4`, `cf-room-yarnpatch`). yawn, stretch, washA, washB and the room pieces are installed but not animated yet. `tools/catfish_build_art.py` installs all of it; `EYE_SPLIT` has the new frames.
- Tests: `tests/catfish.sh` (alias layer stacks, PHP/JSON mirror, manifest, css, and a Playwright pass in `tests/catfish_anim.js`), `tests/catfish_build_art.sh` (1281 files), `tests/catfish_recolor.sh`.

## 2.1.04
- **Cat Fish active play.** Tap a fish to bounce it and your cat plays; each tap earns a little extra Kibble (5 s of income, up to 360 taps a day, tapering after 120 and 240); keyboard and touch friendly; reduced-motion respected; no new tables.
- Server (`catfish_play`, inside the lock, no new columns): `do=tick` takes `play=n` and `seq`. A tap pays `max(1, floor(kph x 5 / 3600 x tier))`, tiers 1 / 0.5 / 0.25 by Hollow day and 0 after 360; token bucket 15 tokens, +1 per 2 s; a batch needs an integer 0..40 (more pays 0) and a higher `seq` than the last (replays pay nothing). New `catfish_state.meta` keys `pb pt pd pc pq pe`; `view.play = {v, left, got, paid, ever}`.
- Page: each fish is a `<button>` (44 px or more, focus ring), the stage is `role="group"`, `+N` pops, a "Tap a fish to play!" hint until the first tap, a cosmetic combo and a polite "+N Kibble from play" line. The cat stalks, pounces and catches, and faces the fish. Batches ride the 30 s tick and `pagehide` uses `sendBeacon`.
- Tests: `tests/catfish.sh` (play economy and markup), `claude/catfish-sim.php` third argument (taps a day; play is 1.2% of a day's idle at 360 taps).

## 2.1.03
- **Cat Fish: the fishing lines now reach their fish; the string length follows each fish picture.** Every fish PNG has transparent rows above its body, so the strings stopped short of the fish. Each drop now carries its fish kind (`cfk-N`, from `catfish_fish_kinds`) and `catfish.css` adds `--cfn` per kind (8, 7, 4, 11, 11 px: the first opaque row in the string columns) to the string height. `room-layout.json` nose of fish 2 corrected to 7. Test: `tests/catfish.sh` recomputes `--cfn` from the PNGs.

## 2.1.02
- **Cat Fish room is one play scene** (`catfish_stage_html`): a centred 320 x 200 stage holds the room (base and owned overlays), the toy rod hung from the ceiling hook, a line to three swaying fish, your cat in the centre play zone and up to three other cats at the side spots (nap, idle, bored). Coordinates come from `aseprite-source/catfish/room-layout.json`; positions are CSS classes (`.cfpos-x128-y120`, `.cfsdrop.sd1`), no inline style. Without `cf-room.png` the old rod box, cat card and room stay as before.
- **Animated active cat** (`assets/catfish.js`, decorative only): all 8 frame groups are in the page and one class (`fr-<frame>`, mirrored in `data-frame`) shows one. idleA/idleB blink, every 6-9 s a play loop (wiggle, stalk, pounce, catch), sometimes bored, nap after a Nap. `prefers-reduced-motion`: idleA only, no sway. The Kibble tick and sync are unchanged.
- **Art:** idleB, wiggle and bored now have patterns, folded ears, bobtails and masks (`CATFISH_PATTERN_FRAMES` is all 8 frames, `KEY_FRAMES` in `tools/catfish_build_art.py` too): 614 PNGs. New room art (`cf-room*.png`, layout in `room-layout.json`).
- **Centred layout:** banner, stage, cat card text, headings and shelter notes are centred; upgrade rows and lists unchanged.
- Tests: `tests/catfish.sh` (stage markup, frame list, coordinates against the layout JSON), `tests/catfish_build_art.sh` (614 files).
- Merges main up to 2.1.01 (Journey next-chapter notice).

## 2.1.01
- **Journey:** the chapter-complete notice now names the next chapter in story order (what Wren's letter says), not the first chapter you had not started yet.

## 2.1.00
- **Cat Fish art** (ON by default now: `catfish_open` default is On; existing sites flip on once at upgrade; admins can turn it Off in Admin > Settings). Hand-drawn Stitched Toy art, 440 PNGs under `assets/img/catfish` (emoji fallback stays for anything missing): 8 coats x 5 patterns, eyes, folded ears, bobtails, the room and its overlays, fish, rod, upgrade icons, badges, ribbons, banner, shelter tile and Cat Book heads.
- **Layered cat renderer** (`catfish_cat_html`): body, pattern, ears, tail and eyes are stacked layers, so any seeded cat is drawn from the art set. Lilac coat art added; odd-eye cats split their eyes.
- **Tools:** `tools/catfish_recolor.py` (palette swaps), `tools/catfish_build_art.py` (build and `--install` the art set).
- Known art gaps (idleB, wiggle and bored frames lack ear, tail and pattern art): `claude/catfish-art-brief.md`.
- Tests: `tests/catfish.sh` (art held aside for its no-art checks), `tests/catfish_recolor.sh`, `tests/catfish_build_art.sh`.
- Merges main up to 2.0.99 (stat tab, drying rack icons, regional seed staples).

## 2.0.99
- **Drying rack icons fixed:** each bundle now shows its own flower icon (it was using the rack row id, so it showed random items like a shovel).
- **Staple seeds in regional markets:** every regional seed market now stocks its region's staple crops (up to 20, restocks about 90% of the time). Existing markets are filled in on update.

## 2.0.98
- **Stats tab on phones:** stats show three per row (Luck on its own row below) so the list is much shorter. Desktop unchanged.

## 2.0.97
- **Stats tab:** tapping a stat name loads in place (no page reload).

## 2.0.96
- **My Gnome Overview shows the stat web.** The Stats box on Overview now draws the web (tap a label to open that stat) instead of the line of numbers. The full list stays on the Stats tab. The web is built by one shared helper in `gnome.php`.

## 2.0.95
- **My Gnome fits phones better.** Phones only (720px and under), desktop unchanged: smaller avatar and header, slimmer pal slots, smaller tabs, three facts per row, a smaller skill web with larger labels, and all seven stats listed full width.

## 2.0.94
- **My Gnome is the home page.** Logged-in, onboarded players going to `index.php` (or logging in) land on `gnome.php`. Today moved to `index.php?today=1`; the Today nav link, the rail link, "Back to Today" and the old `?t=out` / `?t=hollow` links use it.
- **My Gnome tabs load in place.** `nav.gvtabs` links are now handled by the in-place loader in `site.js` (no full reload).

## 2.0.93
- **Cat Fish uses the game's clock.** The daily shelter, swaps, the weekly Cat Show and the weekly Petal cap now turn over at midnight in the Hollow's time zone (`game_timezone`, America/Halifax), like Jobs and everything else in the game. They were on UTC, so the show used to end on Sunday evening. The page shows the time left until new cats and until the show is judged. Away-time Kibble still runs on plain elapsed seconds.
- Tests: `tests/catfish.sh` gains week and day boundary checks in Halifax time, a DST and year-end check for "yesterday", and a guard that no UTC date maths comes back.
- Cat Fish art questions answered (see `claude/catfish-art-brief.md`): ring-tinted cat eyes, palette-swap colours, layered cat PNGs.

## 2.0.92
- **Cat Fish** (Games; open for everyone since 2.1.00, see above; before that off for players). An idle game: adopt a cat, a toy rod sways on its own, the cat catches fish and drops Kibble, Kibble buys 16 upgrades in four branches (Fish, Rod, Room, Cat). Kibble is earned on the server clock only: full speed while the page is open, half speed away (up to 8 hours).
- **Adoptable cats:** each cat is one seed, so pattern, coat colour, eyes, ears, tail, personality and quirk are generated, never stored. The shelter shows three new cats a day per gnome; the first cat is free. Rarity bands: common, uncommon, rare, legendary. Personalities: Lazy (longer away time), Hyper (faster while you watch), Sneaky (rare fish), Greedy (more Kibble), Dreamy (more Yarn).
- **Nap and Yarn:** a Nap resets the run for Yarn (cube root of the run, Yarn^0.6 bonus). Yarn also buys shelter extras: swap a cat (3 a day per spot), a bigger home (up to 4 cats), Rare Shelter (best of 2 or 3 cats). Spending Yarn never lowers the Kibble bonus.
- **Cat Book and badges:** every coat seen at the shelter or adopted; badges are worked out from what you have (nothing stored) and show on the profile.
- **Weekly Cat Show:** a themed show each ISO week (for example "Best tabby coat"). Enter one cat; three seeded judges plus theme and rarity bonuses give a ribbon when the week ends (Best in Show, blue, red, white, took part). Kibble and Yarn do not count. Ribbons show on the profile.
- **Petal milestones:** six one-time rewards through `game_petals()`, at most `catfish_petal_cap` Petals per gnome per week (default 100, 0 = none).
- **Tie-ins:** the active cat naps on the My Garden page (read only); +2% Kibble per Puzzle Pal found (up to 10 pals); a Nap gives double Yarn during a festival.
- Art is placeholder (emoji and CSS tint); `catfish_img()` swaps in `assets/img/catfish/cf-*.png` as it is drawn. Art todo: `claude/catfish-art-brief.md`. Plan: `claude/plan-catfish.md`.
- Tests: `tests/catfish.sh` (new, about 180 checks), in CI. Balance sim: `claude/catfish-sim.php`.
## 2.0.91
- **Pals along: no gnome level needed** (`PPAL_PARTY_LEVEL` is 1). Still behind `ppal_open` + `ppal_party`. Tests updated.
- **How to get pals:** a short "How to meet your first pals" box for gnomes with none (My Gnome strip, picker and Pals tab; the Pal Book page).
- **Almanac:** a Pal Book chapter under Wild (shown while Puzzle Pals are open); the front-page card opens it.

## 2.0.90
- My Gnome content is centred. (2.0.89 was rebuilt under the same number; this release carries the change under a new one.)

## 2.0.89
- **My Gnome tabs** (`gnome.php?tab=`): Overview, Pals (when `ppal_open` is on), Stats, Calling, Foods eaten, Villagers, Gardens. Plain links, no script. Old `#calling` / `#effects` links now go to the right tab.
- **Stats:** a chart beside the list; click a stat for its detail; +1 per stat while points are unspent.
- **Foods eaten:** a tasting menu card by food category; "Show not tasted yet" fades in the rest. **Villagers:** a polaroid wall with a card per villager.
- **Pals along on My Gnome** (still behind `ppal_open` + `ppal_party`): a two-slot strip under the header with a picker (Take along / Send home).
- **Easy roads** moved from My Gnome to Account (`account.php#easyroads`).
- **Right rail:** a "Go to Today" box, first in the rail.
- **Build:** `tests/build_update.sh` makes the FULL and source zips only on milestone versions (x.y.0); pass `all` or `slim` as the 4th argument to force.

## 2.0.88
- **Puzzle Pals** (off for players until Admin > Settings `ppal_open` is set to On; admins see it now). 570 pals: six for each of the 95 Jigsaw pictures (84 gallery pals, 486 Places pals), every one drawn by hand as a 64 x 64 sticker. 3 common, 2 uncommon, 1 rare per picture.
- **Release and find lane:** solving a picture at Advanced (free play or tournament) releases its pals once. Released pals turn up as a find card on ordinary pages (1 in 60 views, 30 minutes apart, 4 a day; never on puzzle, Trek or admin pages). Settings `ppal_chance`, `ppal_cooldown_minutes`, `ppal_daily_max`, `ppal_roster_size`.
- **Pal Book** (`puzzlepals.php`): every picture, silhouettes for pals not found yet, counts, hub card, Jigsaw pips, win-card text, profile shelf. Pals cannot be traded or gifted.
- **Take along** (`ppal_party`, off): two pals at gnome level 15 and up (`ppal_party_max`), shown beside the gnome; each gives a small perk (gather, road fights, finder, tinker, bloom, shine). Treks have no pals.
- **Expert trophy:** solving a picture at Expert earns a trophy; it adds one perk unit per equipped pal of that picture.
- **Admin > Jigsaw > Pals tab:** roster and art-ready status for all 95 pictures, found and released counts, the `ppal_*` settings, and a link to Tools > Test a pal find.
- **Not in 2.0.88:** the weekly Jigsaw Schedule tab (moved to a later release) and the follower sticker.
- Fix: one pal sticker had too little clear space at the top edge (3 px now).
- Tests: `tests/puzzle_pals.sh` (new), `jigsaw.sh` (Pals tab) and `events.sh` (lane off while `ppal_open` is 0) extended. Plans: `claude/plan-puzzle-pals.md`, `claude/plan-places-pals.md`.

## 2.0.87
- **Jigsaw: classic picture jigsaws beside GIFsaw** (Games > Puzzles > Jigsaw, `jigsaw.php`; off for players until Admin > Settings `jigsaw_open`, admins see it now). Three **fixed sizes, no free piece count**: Easy 24 (6x4), Advanced 96 (12x8), Expert 216 (18x12). Every picture is 3:2 (1800 x 1200) so the pieces are square. Same engine as GIFsaw (`puzzles.js` "still" mode), same tables (`puzzle_pics.kind`, `puzzle_tournaments.kind / tier / cup_id`, `puzzle_runs.pic_id`; columns are added on upgrade).
- **14 region pictures**, one per region, drawn as 300 x 200 pixel scenes with the 3-pass method (draft, then two art-director passes, then `tools/jigsaw_cell_check.py`): `aseprite-source/scenes-pil/jigsaw_<slug>.py`, process in `claude/jigsaw-art-process.md`.
- **Places: the unique locations are jigsaws too.** The 81 haven / wonder / delve / lair scenes (2.0.86 art) join a gnome's puzzle room the first time they stand at that place ("New jigsaw!" on the place page, a notification; places cleared or repaired before 2.0.87 unlock the first time Jigsaw opens; admins see all). Each scene is cut to an exact 360 x 240 window (180 x 120 art pixels) so every tier cuts on whole pixels (`tools/gen_place_crops.py`, `assets/img/jigsaw/places/`, offsets in `includes/data/place_crops.txt`). A locked place cannot be played.
- **Free play is timed on the server** for personal bests (best per picture and tier shows on its card); it pays nothing. Guests can play, nothing is saved.
- **Save and resume:** a Jigsaw in progress is kept in the browser (`jiggy.save.*`); the card's tier button says Continue with progress and there is a Start over. A resumed go does not set a best. Tournaments and GIFsaw are not saved.
- **Jigsaw tournaments** (`jigsaw_tournaments`): one picture and one tier each, or a three-tier **cup**; mystery card before it opens; a picture reserved for a tournament stays out of free play until it settles; Places pictures never used; timed goes per day per tier (10 / 10 / 5, settings `jigsaw_tries_*`); same server-clock rules as GIFsaw; cosmetic trophies and badges with a tier pip. A run now reports its tier and kind (Puzzle Pals, 2.0.88, will use that).
- **Admin > Jigsaw** (`admin/jigsaw.php`): Library, Upload (3:2 check, GD re-encode to 1800 x 1200 + thumb, 25 files at a time), Tournaments (make all three tiers, duplicate, cancel, settle now, void, CSV). The shared tournament markup moved to `includes/admin_puzzle_ui.php` (GIFsaw unchanged).
- **Fix:** a GIFsaw tournament could start when only Jigsaw tournaments were on (and the reverse); the API now checks the tournament's own kind.
- **Art:** new cast stickers `jeff-piece`, `jeff-headband`, `ffej-pocket`, `wizard-lid`, `tile-jigsaw`, `jigsaw-banner`, `win-scene-jigsaw` and a dark `tourney-banner`; icons `ico-piece`, `ico-tier-easy / advanced / expert`, `ico-cup`, `ico-jigsaw-box`.
- **Also in this release:** World: Wander moved from the Go panel to the top tab row (from the scene-art branch).
- Tests: new `tests/jigsaw.sh` (tiers, kind isolation, free play, places, columns on an old database, browser passes), `tests/jigsaw_tourney.sh`, `tests/jigsaw_resume_check.js`; `puzzles*` suites still pass. Plans: `claude/plan-jigsaw.md`, `claude/plan-puzzle-pals.md` (2.0.88: Puzzle Pals; weekly Jigsaw schedule).

## 2.0.84
- **Every activity popover scene is animated.** All 829 act scenes now have a 6-frame looping strip (`act-<slug>-anim.png`) that plays only inside the open popover: gnome breath, cloud drift, flame flicker, rain and snow, steam, glints. 15 were drawn by hand in Aseprite; the other 814 come from `aseprite-source/anim/scripts/bulk.py` (re-runnable).

## 2.0.83
- **Gather no longer reloads the page.** Clicking a gather card or a belt icon sends the try in the background and swaps only the Gather box plus the energy and message bars; the scroll stays put, and any failure falls back to a normal post (`site.js`, capture-phase handler on `form.gx-form`).
- **Gather: click a tool on the belt to gather with it.** A belt icon whose tool finds something in this land is now a button (same post and ⚡1 as its card below). Locked slots and tools with nothing to find here stay inert.
- **Gather: one scene per land.** The satchel scene is now drawn for all nine lands (coast, mountain, forest, desert, rainforest, grassland, wetland, tundra, island): `assets/img/gather/scene-<land>.png`, falling back to `scene.png`. The satchel and its front wall are identical in every scene, so the find still pops out of the bag. Sources: `aseprite-source/scenes-pil/gather_<land>.py` (shared satchel in `gather_common.py`) and `aseprite-source/gather/*.aseprite`.

## 2.0.82
- **Moving art inside the activity-card pop-over (never on the page cards).** Open a Do card and its picture and option icons now move: the scene gets a slow, pixel-stepped bob and breathe; the option icons (choice rows and the pick / power / collect / contest buttons) hop, wiggle and blink, staggered row by row. CSS only (`transform`, `steps()`), inside `prefers-reduced-motion: no-preference` and scoped to `dialog.isheet.dosheet[open]`; shop-tile pop-overs do not move. The pop-over picture has its own class `doart-img` (the card's picture is unchanged).
- **Hook for hand-drawn frames.** Drop a horizontal strip of equal-width frames next to the still: `assets/img/acts/act-<name>-anim.png` (frames 144 x 108; same fallback chain as the still, `stop_act_anim()`) or `assets/img/ico/<name>-anim.png` (square frames). 6 fps unless a sidecar `<file>.png.json` says `{"frames":N,"fps":F}`. The pop-over writes `data-anim` / `data-frames` / `data-fps` on its own picture only; `gvAnimArt()` in site.js plays the strip while the pop-over is open, skips it under reduced motion, falls back to the still on a load error and stops on close. The CSS bob is off for a picture that plays a strip.
- Tests: new `tests/popart.sh` + `tests/popart_check.js`.

## 2.0.81
- Re-release of the late 2.0.80 fixes under a new number, because the web updater skips a zip whose version is already installed: craft button text without raw tags, rest-stop daily cap 8, stall above the activities with smaller cards, dark text on the shop cards.

## 2.0.80
- **Road cards for all 14 regions.** 25 new cards for each of the other 12 regions (Dunewhisper, Blossomreach, Sunsprinkle Isles, Rainroot Reaches, Mistmoor, Olivewhistle Shore, Birchbramble Steppe, Greatcanopy, Thornacre Savanna, Spicepeak, Monsoon Tangle, Coralscatter): 6 sketches (every region's Road Journal now has 6 pages), 2 forks, 2 riddles, 2 trades, 2 chain stories (3 and 4 cards) and 6 plain choice cards each. Linted with `tools/lint_road_events.py`.
- **First-pass drawn art replaces every variety placeholder:** build-stage verb icons, 48 themed stop-upgrade pictures, 11 villager species, the 4 stop-activity kind cards, one picture for each of the 810 stop activities, the 5 road card kind icons and 14 Road Journal pictures. Not yet approved by Joshua.
- **Villager chat fix:** tapping a villager's face or name at a place in town (Who's here), on the Orders tab and in your passport's known list now opens the chat pop-over instead of jumping to the full page; the pop-over ends with "See full details →" (the villager's full page). The pop-over is now on every town view that shows villagers.
- **Craft stop activity text fix:** the "Uses 3 × Fiddlehead Ferns (you have 0)" line showed raw `<small>` tags; it is plain text now (and no double-escaped names on craft and tend buttons).
- **Rest stops:** most things per day at one stop is now 8 (was 6; a visit is 4 things, so one visit and a half). A stop still on the old 6 moves to 8 on upgrade (an admin-set value is kept). The stall (For sale) now sits above the Things to do cards, and the activity cards are a little smaller: three across (two on very narrow phones).
- **Shop cards (town Shops tab) readable on dark:** the description and counter line were light text on tan felt; they use the felt's dark ink now in both themes.
- Tests: `roadlife` region-pack counts and `roadkinds` journal check cover all regions.

## 2.0.79
- **New kinds of road card**, so a walk is more than "pick a stat": **fork** (two or three ways on: a short way that saves a space but costs a roll or goods, a long safe way, sometimes a hidden way), **riddle** (three answers shown in a shuffled order, one is right, the wrong ones cost a little and are funny), **trade** (a traveller offers goods for goods, the price is shown and the option is greyed out if you can not pay), **chain** (a story over two or three spaces: the card you answer decides the next one) and **sketch** (a page of your Road Journal). Card shapes are labelled on the card and the same shape rarely shows twice running (the road's recent-picks memory now remembers shapes too). Weather cards use the existing `!we=` conditions.
- **Road Journal.** Sketch a sight and it is stamped on your region's page (6 pages in each region so far). A full page pays Petals (80 + 10 a level) and 2 beeswax once. The journal shows under the Stamp passport (Town > Stop). New table `road_journal`, new column `expeditions.chain`.
- **New effects** for road cards: `take:slug:N` (hand over goods), `next:ID` (the next space is that card), `skip:N` (short way, walks only), `journal:ID`; option stat `!` (always the wrong side). Format and rules are in the header of `road_events.txt` (two optional columns on an E row: kind and journal name). Lint a draft with `tools/lint_road_events.py`.
- **Pilot content:** 24 cards each for the Maplewold and Maizehollow (2 forks, 5 chain cards, 2 riddles, 2 trades, 2 weather cards, 6 sketches, 5 other regional cards), written then checked for repeats. The other 12 regions follow in 50-card waves.
- ART IS PLACEHOLDER: red-bordered "THIS IS PLACEHOLDER" squares for the five card-kind icons (`assets/img/roadkinds/<kind>.png`, 24px on the card label) and one Road Journal picture per region (`assets/img/journal/<code>.png`, 48px). List in `claude/todo-art-variety.md`.
- Tests: new `tests/roadkinds.sh` (data, sketches and the full-page prize, riddles, trades, forks, chains, the kind memory, and the pages render); `tests/roadlife.php` knows the new effects and columns.

## 2.0.78
- **Four new kinds of rest-stop activity**, so a stop is more than "pick a stat and roll": **craft** (make something from what you carry, no dice: split birch into planks, grind cocoa), **collect** (spot one local thing a visit toward a checklist for the whole region, with a prize for the full set: Maplewold birds, the quetzal trail), **tend** (a chore that takes a few visits: each visit is a step and the last one pays: the beaver dam, the milpa row) and **contest** (a friendly contest with a villager: three moves, each beats one and loses to one, luck can save you from a loss; a draw pays a little). They are small checks inside the stop, not the Games section. Admin > Stop activities has the new kinds and their spec formats.
- **Regional activities.** Stop activities can now belong to a region (new `region` column, Admin field, last column of `stop_acts_regional.txt`): they only happen at stops in that region and are picked before the plain ones. First 14, for the pilot: seven for the Maplewold (split the birch, pitch candles, Maplewold birds, patch the beaver dam, pumpkin roll, which bucket is full, watch the aurora) and seven for Maizehollow (press tortillas, grind the cocoa, the quetzal trail, tend the milpa, hip-ball, which chili is hottest, dip in the cenote).
- **More variety at one stop.** The activities picked for a stop (the fixed ones and each day's extras) now prefer different kinds of thing, so you are not offered three stat checks in a row when a craft or a contest is available.
- **Wave 1 of the content waves: 50 plain activities** for the 12 stop kinds (jetty, workshop and spring 6 each; market, mill, shrine, herb and tower 4; inn, orchard, ferry and camp 3), reviewed and approved by Joshua. They live in `stop_acts_waves.txt` (future waves go there too); the lint is `tools/lint_stop_acts.py`. An activity's own picture is now `assets/img/acts/act-<slug>.png` when it exists (else its kind card); `tools/missing_act_art.py` lists the ones still to draw.
- **Waves 2 to 5 and the regional waves: 691 more activities.** Every kind of rest stop now has at least 35 plain activities of its own (waves 2 to 5, 215 new: market, mill, inn; shrine, jetty, herb; workshop, orchard, ferry; tower, spring, camp), and each of the 14 regions has exactly 35 that only happen there (476 new, 490 in all). They were written by separate Opus passes, then checked together with `tools/dedupe_stop_acts.py`: 42 repeated ideas (terrace walls, spinning tops, kite duels, red-clay pots, track and spice collections, plum jam and more) were found across the files and rewritten, so no two activities share a name, a craft, a collection or a set of contest moves. Data: `stop_acts_waves.txt`, `stop_acts_regional.txt`. Tests: `tests/stopkinds.sh` runs every offered activity in every region at every stop kind (about 10,000 attempts) and checks the 35 and 35.
- New table `stop_prog` (tended chores per stop; collections per region), new column `stop_acts.region`; both are added on upgrade and the new activities are imported on the first request after it.
- ART IS PLACEHOLDER: four red-bordered "THIS IS PLACEHOLDER" cards at `assets/img/acts/act-craft.png`, `act-collect.png`, `act-tend.png` and `act-contest.png` (one for each new kind). Replace them with the real card art (144x108, same names). Checklist in `claude/todo-art-variety.md`.
- Suite `tests/stopkinds.sh` (data lint, all four kinds played through, regions kept apart, the variety rule), added to CI; `tests/stops100.php` still passes.

## 2.0.77
- **Themed upgrades for adopted stops.** Every kind of rest stop now builds its own four upgrades instead of the same bench, stall, well and hall: market (striped awning, weighing house, fountain square, market hall), mill (sack hoist, mill sluice, flour loft, bakehouse hall), inn, shrine, jetty, herb croft, workshop, orchard, ferry, tower, hot spring and camp: 48 upgrades. The unlocks keep the same shape (tier 1 a rest, 2 a stall, 3 a luck or charm moment, 4 a hall and one more slot), so balance is unchanged; the names, activities, words and needs are new. The 48 new activities (`tt_<kind>_<tier>` in `stop_acts.txt`) replace the plain bench, stall, well and long table, which are switched off once on upgrade (an admin can switch them back on). The lantern-post walk stays.
- **Regional materials.** Each upgrade asks for two things from the stop's own land (`{a}` and `{b}` in the needs, resolved per region from `data/region_locals.txt`): ochre and clay in Maizehollow, driftwood and coir in the Sunsprinkle Isles, sphagnum and cottongrass in Mistmoor, and so on for all 14 regions. They are gatherable items already in the game.
- Data and admin: new table `stop_tier_themes` (imported from `stop_tier_themes.txt`; edit in Admin > Themed upgrades by kind of stop). The plain Stop upgrades stay as the fallback for a kind with no theme. A stop that was part-way through a plain tier when you upgrade keeps what it has handed in, but only things that the new tier also asks for count toward it.
- ART IS PLACEHOLDER: 48 red-bordered "THIS IS PLACEHOLDER" squares at `assets/img/stoptiers/<kind>-<tier>.png` show beside each upgrade on the adopt panel and the plaque. Replace each with the real picture (same name). List in `claude/todo-art-variety.md`.
- **Villagers open in an overlay.** On a main stop's Villagers tab, "Chat" and a villager's name open an overlay (chat, gift, traveller deal, all in place, with a "Full villager page →" link) instead of going to a new page. On a rest stop's Villagers tab, "Say hello" opens an overlay with chat, **a gift** (new for stop villagers: once a day each, a little friendship, more for food, flowers and produce) and the errand. Close with ✕, Esc or a tap outside; the page refreshes behind it if anything changed. Knock still goes to their home. Without JavaScript every button and form works as before. New `stopfolk.php` (JSON for the overlay), `assets/folkoverlay.js`, `stop_friend.last_gift` column, `stop_gift()`; the errand parts moved to `local_folk_errands()` so the page and the overlay share them. Suite `tests/folkoverlay.sh` (JSON, limits, hooks and a real browser pass with Playwright). The overlay shows the villager's picture: townsfolk their portrait (smaller, 96x120), rest-stop villagers their species (our drawn icon for 9 species; 11 species show a red PLACEHOLDER square at `assets/img/folk/<species>.png` until drawn: see `claude/todo-art-variety.md`).
- Tests: new `tests/stopthemes.sh` (data lint across all 14 regions, upgrade from 2.0.75, a mill built to tier 1 with its Maizehollow materials), added to CI; `tests/stops100.php` now reads the themed needs.

## 2.0.76
- **Build plans**: a ruined haven, wonder or delve can now have its own four stages instead of the one fixed list (stone, timber and rope, four meals, fine finds). Plans are written by hand, one place at a time, in `includes/data/build_plans.txt` (`P|Landmark name|stage|verb|title|needs|story line`). Stages now do different things: **haul** (building materials), **gather** (things found on the road or in the wild), **feed** (cooked dishes, including a region's own feast), **light** (wax for lanterns and candles) and **clear** (work at the place on different days: it costs energy, counts once per Hollow day, and the stage finishes by itself on the last day: new button "Work here today"). Each stage shows a small picture for its verb and a line of story.
- First plans (the pilot): Maizehollow (Market of a Thousand Chilies, The Stepped Seed Temple, Cenote of Echoes, Jaguar Root Caves) and the Sunsprinkle Isles (Driftwood Tavern, Sunken Gnome Galleon, The Singing Waterfall, Mangrove Root Maze, Turtle Nesting Beach). Every other place keeps the old four stages, and a repair begun before its place had a plan keeps the old stages too (`landmark_repairs.plan` is `v1` only for repairs begun on a plan). Rewards per stage are unchanged. The Maplewold (start region) has no ruins, so it has no plans yet.
- ART IS PLACEHOLDER: the five verb pictures (`assets/img/steps/stage-*.png`) are a red-bordered "THIS IS PLACEHOLDER" square. Replace each PNG with the real icon (same name). The list of art wanted is in `claude/todo-art-variety.md`; `tools/gen_placeholder_art.py` makes placeholders.
- New columns on `landmark_repairs`: `plan`, `prog`, `prog_day` (added on upgrade). Suite `tests/buildplans.sh` (data lint of every plan + a whole planned repair + old-stage fallback), added to CI. Plan for the whole variety project: `claude/plan-variety.md`.

## 2.0.75
- **Guest gardens** (off by default: Admin > Game settings > "Guests: visitors can play a guest garden", `guest_open`). The front page and the tour offer "Play as a guest" (`guest.php`): a ready-made gnome and garden in one tap, no email, no password. A guest can plant, cook, shop, walk the roads, play the games and puzzles. A slim strip under the header (Jeff holding a key) says it is a guest garden and links to sign-up.
- What guests cannot do (Jeff's "needs an account" card, 403): account, community, feedback, market and trading, pals, reports, mentors, treks, fair, show, gotm, tending other gardens, posting or taking player jobs, tournaments. Visits, profile edits and the market-day basket are turned back on POST. Guests never appear on a board or in a draw (`gnome_in_play_sql()` now adds `guest = 0`), don't enter contests at harvest, get no public profile or visitable garden, and can't send gifts or trades (`fresh_hold()`). No mail is ever sent to a guest address.
- Limits (settings): 3 new guest gardens per connection per day (`guest_max_per_ip_day`), 200 alive at once (`guest_max_total`), a guest garden is deleted after 24 hours idle with every row it owns (`guest_ttl_hours`; `guest_purge()` finds the tables from the live schema, so tables added later are covered). An idle guest who comes back is sent to the front page with a note.
- Keep the garden: registering while playing as a guest turns the same row into a real account (plants, satchel and all), then a "make your gnome" step (`customise.php`) picks the name, hat and beard. Counters on Admin > Usage (alive, made, turned into accounts); guests are left out of every other number there.
- Code: new `includes/guest.php`, `includes/onboard.php` (`onboard_create`, `village_welcome_pack`, `swatch` moved out of `welcome.php` and shared), `guest.php`, `customise.php`; `users.guest` and `users.guest_ip` columns (added on upgrade, index `idx_users_guest`). Suite `tests/guest.sh`.

## 2.0.74
- Eight new Jeff the Puzzler poses (64x64 stickers with `-dark` pairs, drawn in Aseprite: `aseprite-source/extras-pixel/scripts/cast-jeff-<slug>.lua`, shared helpers `K.jeffBody/jeffFace` in `cast-common.lua`) and where they show: **point** guides the front-page tour stops 1 to 4; **key** holds the closing front-page card ("Ready to make your own gnome?"); **water** hosts Rain Barrel; **gnomehat** hosts Gnome Beds; **sleep** sits beside "Today: done ✓" in both games; **oops** appears next to an error or retry message (still leaking, not quite, could not start); **trophy** celebrates a tournament winner on the GIFsaw tournament page; **snail** is on the Snail Trail coming-soon card. `tada` (weak at small sizes) and `bye` are drawn but not shipped. No schema change.

## 2.0.73
- Logged-out front page reworked: **Jeff the Puzzler** welcomes visitors (speech bubble, light/dark art via `puzzle_cast`) and takes them on a 6-stop tour: Garden, Satchel, World, Town, Games, Almanac. Each stop shows a real phone screenshot of the current game with one line from Jeff; the old illustrated tiles and hero scene are no longer used. Then the GIFsaw demo (Jeff cheers you on) and a closing Jeff card before the sign-up button. All words are editable in Admin > Page text (`home.jeff`, `home.tourbtn`, `home.tour.1..6`, `home.try`, `home.gate`).
- Screenshots come from a repeatable pipeline: `bash tests/shots.sh` installs a throwaway copy, seeds the demo gnome (`tests/shot_seed.php`), captures 6 pages in dark and light at 412 px (`tests/shots.js`, Playwright), quantises them (about 35 KB each) into `game/assets/img/landing/shot-<stop>[-dark].png` and writes `tests/manifests/shots.txt`. `tests/shots_stale.sh` fails if a shot is missing, the wrong size, too big, or more than 12 releases old. Re-run `tests/shots.sh` whenever a tour page changes look.
- No guest accounts yet (next release); the "Play as a guest" button is not shown. No schema change.

## 2.0.72
- **Gnome Beds**, the second Puzzles game (`gnomebeds.php`): an 8x8 garden of coloured flower beds; put one gnome in every row, column and bed, with no two gnomes touching (corners too). Tap = mark ✕, tap again = gnome, again = clear; broken rules turn red; every bed also has its own corner mark so colour is never the only clue. One daily garden (same for everyone, best time counts, reward once a day) plus practice (6x6 to 9x9, no reward). The Old Wizard's hint plants one correct gnome (+20 s, 3 at most).
- Every garden has exactly one answer: beds grow from a legal placement, then any other solution is broken by moving a border cell into a neighbouring bed (`gb_make`, solver `gb_solutions`). Built gardens are cached as small files in `data/pzcache` (swept after 3 days) because a 9x9 can take about a second to build.
- Shared run code refactored into `pz_run_start/open/hint/finish` (Rain Barrel uses it too); `puzzle_game_api.php` dispatches by game; the hub cards come from `PUZZLE_GAMES`. New setting `pz_beds_open` (default off, admins always see it; needs Puzzles open). No schema change. Suite `tests/puzzles_daily.sh` covers Gnome Beds (+ `tests/pz_beds.php`: 240 gardens, exactly one answer each).

## 2.0.71
- **Rain Barrel**, the first new Puzzles game (`rainbarrel.php`): turn the gutter tiles until water from the barrel reaches every sprout with no leaks. One daily barrel (6x6, same for every gnome, best time counts) plus practice (5x5, 6x6, 8x8, no reward). The Old Wizard's hint turns one wrong tile (+20 s, 3 at most). Daily reward: `pz_daily_petals` (default 15, through `game_petals`) + the usual game energy, paid once per game per day (`puzzle_wins` UNIQUE insert). Top-10 board for today and a day streak.
- Shared puzzle-game parts in `includes/puzzle_games.php` (registry `PUZZLE_GAMES`, seeded PRNG that matches the JS mulberry32, run start/hint/finish, daily board, streak) and `puzzle_game_api.php` (POST, CSRF, rate limit). The server deals the puzzle from the seed and never sends the answer; it re-checks the hand-in, times the run on its own clock and refuses impossibly fast solves.
- New tables `puzzle_runs`, `puzzle_wins` (added on upgrade; `pzgames_ensure()` creates them if missing). New settings `pz_barrel_open` (default off, admins always see it; needs `puzzles_open`), `pz_daily_petals`. The Puzzles hub shows the card when open. No news entry (closed to players). Suite `tests/puzzles_daily.sh` (+ `tests/pz_barrel.php` generator checks over 1095 puzzles).

## 2.0.70
- Front page (logged out): a **Try a puzzle** section lets visitors play a GIFsaw right on the page (3 pictures, same play table as GIFsaw, no login, no rewards, no server calls). The win card offers "Join the Hollow". Switch: Admin > Game settings > "Front page: logged-out visitors can play a GIFsaw demo" (default on; independent of `puzzles_open`). The play table markup moved to `includes/gifsaw_play.php`, shared by `gifsaw.php` and `index.php`. Layout loads `puzzles.css`/`puzzles.js` on the front page when the demo is on. New setting `puzzles_front`. No schema change. Rain Barrel moves to 2.0.71.

## 2.0.69
- Puzzles is now a hub (`puzzles.php`). The animated jigsaw moved to its own page, **GIFsaw** (`gifsaw.php`), with its library, tournaments and `?seed=` links. Old `puzzles.php?t=` and `?seed=` links redirect to GIFsaw; hash-only share links (`puzzles.php#slug-n`) are sent on by `assets/puzzlehub.js`. The hub shows GIFsaw plus three "coming soon" cards (Rain Barrel, Gnome Beds, Snail Trail). Games tile and admin menu say GIFsaw; `puzzles_api.php`, `puzzles.js`, `puzzles.css` and `admin/puzzles.php` keep their names. No schema change. Plan for the three games: `claude/plan-puzzle-games.md`.

## 2.0.68
- Puzzles cast: Jeff hosts the Puzzles page (banner, his own welcome and in-game lines, cheering on the win panel); his twin Ffej makes mischief on Scatter and the Old Wizard speaks up on the Guide. New Games hub tile art. Cast art lives in `assets/img/puzzles/cast/` (light and `-dark` pairs switched by CSS; a missing picture simply doesn't show).
- Puzzle pictures are in a new `puzzle_pics` table (seeded from the built-in seven; the page falls back to the built-in list if the table is missing). Admin > Images & art > Puzzles: Library (title, default pieces, order, on/off), Upload (admins only: GIF up to 1.5 MB, real GIF by file type and image check, each side 64-640 px, 1:2 to 2:1, up to 150 frames and width × height × frames under 40 million; saved to `uploads/puzzles/` with a first-frame still made by GD; refused without GD; new uploads start switched off; admin log) and Tournaments.
- Seeded scramble: tab shapes, jitter and shuffles come from a seeded random (`?seed=N` repeats a layout; default random).
- Puzzle tournaments (setting `puzzles_tournaments`, off by default, and only while `puzzles_open` is on): one picture, fixed pieces and the same scramble for everyone, best time counts, up to 10 goes a day. Times are taken on the server (`puzzles_api.php`, single-use run token, finish accepted until 10 minutes after the end); runs faster than 0.4 s a piece or with fewer drops than pieces − 1 are rejected. `puzzles.php?t=ID` shows the card, Start, top 20 and your best. Admins create and edit tournaments, watch the live leaderboard (top-3 times under a third of the median are flagged) and void a run with a reason. Settling (`settle_puzzle_tournaments`) gives places with a cosmetic gold trophy, silver or bronze badge or an "entered" badge, shown on the results and the profile Awards tab. No coins or items.
- Puzzles: pieces no longer use `content-visibility`, which skipped painting and froze animated pieces.
- New tables `puzzle_pics`, `puzzle_tournaments`, `puzzle_attempts` (added on upgrade). New suites `tests/puzzles_upload.sh`, `tests/puzzles_tourney.sh`; `tests/puzzles.sh` checks the cast art.

## 2.0.67
- Gather: the World Gather tab is a picture panel. A satchel scene holds what you just found (rarity banner, sparkle), a tool belt with tier pips, felt tool cards and a "What's here" grid with ??? for finds you haven't made. The skill mini-game is gone (rounds, practice, the Practice tab on Games, `gather_games_on`); a gather is one energy, one item, and the tool always wears. Rare finds are no longer doubled-weighted. The old mini-game files stay unused on live servers (the updater never deletes).
- Do tab (rest stops): each activity is a felt picture card; tap opens the same forms in a sheet.
- Town page (main stops): 5-tab strip that never wraps, gold summary box, felt place cards with their own art, felt villager rows, shop cards and pinned order notes. Shops and Orders have their own views.
- Stage art: all 9 landscapes redrawn (3 variants each) and 9 weathers per land. The adventure stage follows today's weather and the time of day, with a light dusk/night tint (none on art that is already dawn or dusk).
- Dye Pot has its own shop interior.
- Upgrade drops the `gather_games_on` setting. No schema change.
- Item squares (wave 1): the Satchel (one grid per type when sorted by type), the trek pack, every shop Buy / Sell grid (shops, Trading Post, market day, festival and village stalls, landmark pantries) and the Curio Cabinet / Dye Pot show felt item squares: framed 64 px picture, rarity felt + gem + letter + word, sparkle on rare and legendary (still with reduced motion), name ribbon on up to two lines (Seeds, Seed packet, Cutting, Seedling, Broken, Gardening Guide move to a chip), count corner up to ×9,999, price chip with ↑ / ↓, ★ Wanted, In use, Broken, Rare taste and New flags, "Short N" when too dear, sold out / done on stone felt, a basket badge and "N in basket" on tiles in the basket, and a leather basket bar. 3 to 6 columns by the grid's width. One renderer for all of them (`item_square()` in `includes/item_square.php`); new art in `assets/img/items/`. New suite `tests/itemsq.sh` (with a 390 px light/dark browser check). No schema change.
- Item squares (wave 2): crafting ingredients are item squares (corner count = what you have, "✔ uses N" / "✖ short N"; recipe cards one to a row on a phone); the gift picker of item squares (tastes found as Loved / Liked / Disliked chips, the chosen one pressed) is back on the Villagers panel in place of the drop-down (the drop-down stays for no-JS; folk.php shares it via `gift_picker_html()`); the garden seed / soil / mulch / root cellar pickers (counter and − / all steps kept), the town bird-seed and picnic pickers and the market-day basket picks are item squares too. Old `.pcard`, `.pickgrid`, `.ccchip`, `.mkopt` CSS removed. `tests/itemsq.sh` covers these pages.
- Shop basket is back: in a shop's Buy or Sell sheet, "🧺 Add to basket" stores that many; a sticky basket bar lists them (tap one to remove), shows the total and buys or sells everything in one go. Buy/Sell on the sheet still works for a single item. No schema change.
- Puzzles: pieces and picture animate by default (loose pieces no longer show a still; nothing starts still when the browser asks for reduced motion); the Motion button still turns it off and remembers.
- Knock: opens a visit page for that villager's home (the home interior, chat and gift, with Back to town) instead of the Villagers list; the interior now draws there (the page loaded no stage script, so the scene stayed blank).


## 2.0.66
- GPS route card (World > Go, "Head to"): destination as the title with region and start on one line, a row of totals (stops, steps, ⚡, time), the route as a vertical thread with steps and ⚡ on each leg, the next stop and destination marked, Keep walking / Pause at towns as two big toggles, Fast travel as a button, ✕ to forget, and a full-width Set off pinned above the phone bar.
- Trip strip: while a route is remembered, a one-line strip under the header on every page (not World or the walk page) shows the destination, leg k of n, what comes next and a progress bar; tap it for the route card.
- New suite `tests/tripstrip.sh`. No schema change.

## 2.0.65
- Villagers: one shared row (face, name, details, one action) on main stops (Out and about, At home) and rest stops (Who's about); rest-stop errands fold under the row.
- Place art: rest-stop headers have 12 unique scenes (new: workshop, tower; a stop type with no picture falls back to the market one). Shop pictures redrawn (bakery, craft, herbs, seeds, general) and shown at the right shape on the shop page; the red review outline is gone.
- Headers: the place name sits on a centred felt sign; main stops show just the town name; rest stops show the road as a chip and no longer repeat the stop line.
- Seed shops: each of the 14 regional seed shops has its own name (region and market names unchanged; renamed once on upgrade, names an admin changed stay).
- No schema change.

## 2.0.64
- Maps: the world and all 14 region maps are now underground pixel-art pictures (`assets/img/scenes/map-world.png`, `map-<CODE>.png`), and they replace the old maps for everyone whenever the picture is there. The mycelium / classic drawings are only the fallback when a picture is missing (admin setting `map_style` now only picks that fallback).
- Region maps use a fixed 480 × 270 layout (`includes/region_layout.php`, dumped by `tools/map_layout.php`): every stop, town and exit has one slot that never moves, drawn on the picture's path junctions; what you've found only shows, hides or restyles a slot.
- Region map zoom (＋ − ⤢, wheel, pinch, drag): the controls sit above the map instead of over it, markers and names stay a readable size as you zoom (a little bigger on phones), names with no room show once zoomed in. Not-yet-visited stops are dark wells so the ❔ reads on the picture.
- Tests: `tests/cook.sh` route-highlight check accepts the picture map's classes. No schema change.

## 2.0.63
- Treks: Chapter III (The Knock Below) is open to all players by default (`trek_chapters_open` now defaults to 3; a value already saved in Admin > Settings stays as it is).
- Hush Bell: after the second wrong answer the bell now fails open and a Bell Clapper rolls to the party, so the Strongbox can no longer be missed. The Bellcap Beetle clapper drop stays as a second route.
- No schema change.

## 2.0.62
- World > Go: the route panel (GPS) and seek chip sit in a right column on very wide screens (1600px+) and above the content on narrower ones.
- Place header on World and main stops now shows daypart, weather and season chips.
- Place switcher: three equal buttons on phones, so names are no longer cut.
- Main-stop tabs (Square, Villagers, Shops, Orders, Stop) wrap three per row on phones.
- Main-stop Villagers view shows only who is in town now (out and about, at home); the long list is one link to the Villagers page.
- The art outline on place headers is still a temporary review marker.

## 2.0.61
- World / Town / Stops consolidation (review build): World tabs are now Go, Map, Gather, Shops (Fast travel is a fold on Go; Seasons and Land moved to each stop's Stop tab; old `?tab=travel`, `?tab=seasons` and `?tab=here` links still land).
- Main stops: tabs Square, Villagers, Shops, Orders, Stop. The Stop view (`town.php?view=stop`, `view=passport` still works) holds Passport, Orders link, Seasons and Land (land deeds stay village-only).
- Rest stops: tabs Do, Villagers, Stop; Seasons and Land for sale on the Stop tab.
- New place switcher (World / Here / Mossbottom) and place header with stop and map art on World, main stop and rest stop pages. The art has a TEMPORARY RED OUTLINE for review (class `newart`, remove after Joshua's review).
- Phone bottom bar and menu: Town is now Here.
- Code: World and town helpers moved to `includes/place_ui.php` (no change in behaviour).
- Puzzles: loose pieces now show a still first frame and only one animated copy of the picture runs, clipped to the solved pieces (whole picture on win). Before, every piece ran its own GIF (150 at the top size).
- Puzzles: new **Motion** button (remembered; off by default with reduced-motion) switches the animation off. Pixel art stays crisp (`image-rendering: pixelated` on pieces, guide and final picture).
- New `-still.png` next to each puzzle GIF (generator `tests/gen_puzzle_stills.py`; add one with every new GIF). New suite `tests/puzzles.sh` (locked/open, files exist), added to CI.
- Puzzles phone bar: Back, Copy link and the new Motion button now sit in their intended grid rows (the generic row-3 rule was winning on specificity, pushing buttons into overlap and sideways overflow). Scatter and zoom share the last two rows.
- Removed leftover blob-URL code. No schema change.


## 2.0.60
- Updater: switches maintenance mode on by itself while installing, keeps a safety copy of every file it replaces, rolls back automatically if a write fails or a file's hash is wrong afterwards, and releases the lock either way. The old "switch on Maintenance first" help text is gone.
- Database upgrade: only "index already exists" is ignored; any other index failure is logged and keeps the upgrade coming back (so a failed unique index can no longer pass silently).
- `give_item()` now rethrows anything that is not a duplicate-key race, and reports false if its fallback update changes no row. The inventory functions moved to `includes/inventory.php`.
- Trek map: the inline `image-rendering` style (blocked by the page's CSP) is now a CSS class.
- Install: `install.php` reads the version from `bootstrap.php` (single source).
- Repo: MIT license, real SECURITY.md, GitHub Actions CI (lint, SQLite suites, upgrade check, MySQL), 21 stale test suites repaired and added to CI.

## 2.0.59
- Phone fights: "Show all" under the round log is a small right-aligned tag instead of a full button row.

## 2.0.58
- Phone fights: the round log under the odds line shows only the last round (2 lines) instead of three rounds. "Show all" still opens the whole fight.

## 2.0.57
- Phone fights: the route info fades out once when the fight starts and then stays out for every round, instead of re-fading on each button press. It comes back when the fight ends.

## 2.0.56
- Phone fights: a much tighter fight card so the buttons fit without scrolling: smaller foe and gnome cards, buttons two to a row (Attack stays full width) showing just the name and odds, and the long how-it-works lines under the buttons are hidden on phones (Attack keeps its damage line). Desktop is unchanged.

## 2.0.55
- Phone: the route ribbon is much slimmer (about a third of the height): smaller felt strip and pieces, smaller heading, and the goal, stops left and danger on one line.

## 2.0.54
- Phone: during a fight the route ribbon and Route fold fade away (about 1 s) so the fight options get the room. Desktop keeps them. Reduced-motion users get no fade, they just go.

## 2.0.53
- Adventure: the latest result (card or "Latest" strip) now sits at the top of the action card, and is hidden during a fight, which already shows the rounds.
- Adventure: the world-map fold at the bottom is replaced by a "World map →" link to the Map tab.
- Tests: scene_smoke's banner check assumed the forest banner had no art; it now tests a key with no art and the drawn-picture case separately.

## 2.0.52
- Road walks: the heading, status line, route strip and both route maps are replaced by one route ribbon under the scene: a stitched felt strip with a pin per space, your gnome token, the goal, stops left and danger pips (a thorn pin marks the space where a fight waits). New pixel art in assets/img/route/.
- New closed Route fold: every stop on the road (visited, next, goal) plus the Travel options (Save still works mid-walk).
- Phone: the closed Journal shows only the newest line; tap to open the rest.
- Removed the swipe-strip road map and its scroll script. Wanders (explore) and delves keep their own maps.
- No schema change.

## 2.0.51
- Adventure page CSS cleanup (no markup change): removed duplicate phone map rules and the unused road-ends styles; a fight on a phone now keeps the vertical route map instead of the clipped swipe strip; the "swipe to see the whole map" hint no longer shows under the vertical map.

## 2.0.50
- Mobile adventure layout reworked: gnome scene, action, latest activity, then a compact vertical route map; Travel options collapse under the route strip. Desktop keeps the horizontal map. No schema change.

## 2.0.49
- Mobile adventure layout: travel controls appear below the gnome scene banner, latest activity follows the action, and the route map switches to a compact vertical layout on phones.
- Destination travel options now start collapsed in a compact summary row and expand on demand.

## 2.0.48
- Admin → Routes: add one bulk control to set the travel wait time (minutes) for every route at once. Individual routes remain editable afterwards.

Newest first. Condensed. Dates 2026-10-17 to 2026-10-18.

## 2.0.47
- New art for the scene overhaul, all drawn in Aseprite in the Stitched Toy style and set underground (cavern ceilings and glow light, no sky): 9 stage backdrops, 16 Trek backdrops (chapters I to III-b: path, fight, camp, boss), 29 banners, 6 home and 5 shop interiors, 10 rest stop scenes, the underground world map with its click mask and 14 region maps, 201 toy miniatures (creatures, bosses, the 7 Trek crew, 69 villagers, the layered gnome parts), the hoop kit (hoop, pin, 4 landmarks, 5 felt tiles) and 6 fight effects.
- The code from 2.0.38 to 2.0.46 (scene plumbing, stage, banners, home and shop scenes) ships in this release's update zip. Every picture is optional: a missing file still falls back to the old look.
- No schema change.

## 2.0.46
- New: scene banners on place pages. A rest stop or landmark, the Town Square and each shop show a wide picture when one is drawn (kind first, then the region, then the landscape; shops by type). Nothing drawn means nothing shown, so pages look the same until the art arrives.
- New: visiting a villager at home on the Villagers page shows you and them inside their home (six house interiors, one per villager) when the picture is drawn.
- Changed: Adventure figures (a villager you meet, a road event, a puzzle) stand opposite you on the stage, and the encounter cards fade in with softer shadows.
- No schema change.

## 2.0.45
- Changed: the hoop map's thread now follows your **real steps**: deeper, roaming in place and stepping back are all stitched in order (the last 60), so a wander that doubled back shows it. Walks started before this update draw one stitch per ring as before.
- Schema: new column `expeditions.trail` (added automatically).

## 2.0.44
- Changed: the wild-mycelium ring map is now an **embroidery hoop**: a wooden hoop with felt rings in tier colours, thread-gold stitched seams, a gold button for you, and a landmark on the first ring of each tier (signpost, cairn, skull flag, glow mushroom). A stitched thread trails from the road to you, one stitch per step. The long key is gone: tap a ring and the line under the map says what that tier is. Delve and lair maps stay as explorable room maps.
- No schema change.

## 2.0.43
- New: **Adventure stage**. Your gnome stands on the land's scene (grassland, forest, mountain... colour bands until the pictures are drawn), and a creature stands opposite in a fight with HP bars, hit flashes and floating damage. On a phone the stage sits above the fight.
- Changed: on a computer the Adventure page uses two columns (stage and map left, what you can do right) and the right rail steps aside. The Journal folds away while you are out (open while you are not).
- No schema change. The world and region maps are not restyled yet; they wait for the new map art.

## 2.0.42
- Changed: Trek pop-overs (story scenes, foe cards, camp, Auto replay, fight plan) are gentler. They fade and rise in and fade out, the dimming behind them is light and no longer blurred, the bright focus outline is gone, and the card shadow is softer. Story and foe cards now appear over the Trek stage (the foe card just under the figures, the story card over the map) instead of the middle of the screen; if the stage is off screen they stay centred. Reduced-motion players get a plain short fade.
- No schema change.

## 2.0.41
- Changed: **Trek fits on one screen** on a computer. The right-hand rail steps aside and the stage, map and info panel sit side by side. A fight shows the stage, then the map under it, with the fight controls on the right. On a phone the stage shows just the strip the characters stand in, to save height.
- No schema change.

## 2.0.40
- New: **Trek stage**. A picture of your party standing on the chapter's scene, with the foes opposite in a fight. HP bars, a hit flash and floating damage or healing numbers show after every round, all in place. Until the scene pictures are drawn it shows colour bands; foes show their creature art.
- New: **Party, Pack and Log open in a side drawer** over the Trek instead of replacing the map. Saving tactics or changing the party works inside the drawer and the map behind refreshes. Escape or the Map tab closes it. Without script the tabs are plain links as before.
- Changed: the Trek page is more compact (no big heading).
- No schema change.

## 2.0.39
- New: **Villagers** page and menu tile (Out & about). Every villager in one place: the ones you haven't met are shadows (names stay hidden), filters for met / not met / here now / region, search, sort by friendship, and an "Around you now" strip. Click a card and the villager opens above the grid with no reload: chat, give a gift (a dropdown with your discovered likes marked), a traveller's deal, about, likes, daily routine.
- Changed: `folk.php` and Town's Villagers tab now go to the new page. The menu highlights Villagers on a villager's page.
- No schema change.

## 2.0.38
- New (groundwork for the Adventure, Trek and Villagers overhaul; nothing visible yet): `includes/scene.php` (`scene_path`, `mini_path`, `scene_banner`, `scene_stage`), `assets/stage.js` (480x270 stage with party left, foes right, lunge/hit/KO/heal and floating numbers), `assets/shell.js` (no-reload JSON posts with CSRF) and stage/banner styles. Every picture is optional and falls back to colour bands or the old sticker on a drawn base.
- No schema change.

## 2.0.37
- Fixed: fence, wall and hedge pieces (end, straight, corner, tee, cross) did not meet. Arms were off centre, differed in width and several stopped short of the tile edge with their own outline, leaving gaps and steps. All six families (wattle fence, picket fence, stone wall, box hedge, holly hedge, lavender border) are rebuilt from their straight piece: arms centred, same width, open at every joined edge, patterns repeat evenly across tiles, corners/tees/crosses meet on a diagonal seam. Posts and knots kept. Gates untouched. Upload `upload-zips/gnome-venture-fence-pieces.zip` (the three image part zips hold the same files).
- Fixed: the garden yard no longer draws the soil care star badge on bed squares (it covered the plant picture). Soil care stars stay in the tooltip and the square panel.
- Changed: the Soil details section opens by default when a planted square is selected.
- New: Admin > Images has a Browse pictures box. Search by file name, filter by source, flag uploads that hide built-in art, delete an uploaded picture so the built-in one shows again.
- No schema change.

## 2.0.36
- Fixed: on phones the pixel gnome showed untinted (white hat and beard). The phone nav drawer holds a hidden copy of the gnome, and both copies shared tint filter ids, so the visible gnome used the hidden filter. Each gnome now has its own filter ids (`data-tint`); the Gnome creator recolour follows it.
- Fixed: the trek Auto replay showed raw emoji for foe rows, party rows and log lines (rows are built in JS, so the page's emoji swap never saw them). The server now sends icon markup; foes show their creature art when drawn.
- New pixel art (Stitched Toy, drawn with gvlib through the headless shim `aseprite-source/tools/aseshim.py`): 26 creatures (12 trek foes, 14 lair bosses) and 29 items (parts and misc), in `assets/img/ph`. Sources in `aseprite-source/final`. Upload `upload-zips/gnome-venture-images-missing-2.0.36.zip` in Admin > Images to count them. Still undrawn: Overdue Book, Lanternroot Seed.
- Housekeeping: superseded overlay zips removed from `upload-zips`; release zips older than 2.0.22 moved to `releases/archive`.
- No schema change.

## 2.0.35
- Fixed (broke in 2.0.31): garden bed icons were printed as escaped `<img` text; `tile_icon_html` in `includes/yard.php` now checks the `'<img class="phtile'` prefix.
- Fixed: `install.php` now requires `includes/pixel_art.php`, so a fresh install no longer dies on undefined `pixel_has()` while seeding items.
- No schema change.

## 2.0.34
- Trek map drawn from 46 Stitched Toy pixel tiles in `assets/img/trek` (`TK_PIXEL_TILES` switch; the player keeps their own gnome, `TK_PIXEL_ME` false).
- All sticker, icon and bust art now has no cream halo and a 1 px black border (map tiles and scenes unchanged).
- Style guide PDF rebuilt with an Aseprite / Stitched Toy section.
- No schema change.

## 2.0.33
- Stitched Toy carried across the rest of the site: garden, satchel, shops, kitchen/crafting, jobs, town/folk, rest stops, treks (party, plan, camp, scene pop-overs), maps chrome, games pages (race, guess, letters, practice results), festival/today, Almanac, puzzles (library + play mode), admin.
- style.css chrome sections snapped to the art palette in place (off-palette hex/rgba to nearest palette colour in CIELAB, white text to cream, black to umber), literal radii squared, blurred shadows made hard 2 px offsets, chrome gradients made stepped bands; trek pop-over frosted-glass blur removed. Game art (tool games, dig/memory/mushroom boards, yard + fences, pests, race track, mycelium maps, trek tiles, tilemap, mini-map, chest) left as drawn.
- New v2.0.33 block: panels get a crisp 2 px edge + hard drop (borders kept so selected states still recolour them); rest-stop types mapped to palette families (gold, ember, soil, moss, water, dusk, petal; admin-made hues keep the old formula) with a stitched banner and stepped dawn/dusk bands; garden plot framed; rarity tokens and dark-theme area defaults on the palette.
- puzzles.css: square board/tray, 2 px dot table, hard drag shadow, stitched win card; admin.css: framed sections and toolbar. `theme-color` / manifest colours now umber felt + cream. admin/hybrids.php inline `style=` (blocked by the CSP) replaced by class `qty`.
- No logic, class or ID changes. No schema change.

## 2.0.32
- Site layout restyled in the Stitched Toy look to match the pixel art: colour tokens (light + dark + area hues) now come only from the art palette (cream / umber felt, moss, gold thread); square pixel frames (box-shadow, notched corners, lit upper-left, 2 px lower-right drop) on boxes, tiles, tabs, chips, inputs, menu tiles, rail boxes and puzzle cards; felt-toy buttons that press down; umber felt header, phone bottom bar and footer with a gold hem stitch; area-colour title ribbon with a gold seam; stitched prize/event/hero cards; stitched `hr` with a button knot. No soft shadows or rounded corners left in the shared chrome.
- New UI art `assets/img/ui/` (button, felt-light/dark/umber tiles; Aseprite source `tests/gen_ui_chrome.lua`). Logged-out front page and How to play: square felt cards, scene and card pictures shown at whole-number scales only (1x/2x; phone cards side-by-side at 1/2).
- CSS only (style.css section 1 tokens + new block at the end, landing.css); no class or ID renamed, no PHP markup change. Player news entry added. No schema change.
- Fixed: the status strip (desktop) snapped its first chip half out of view when the chips overflowed (~900 px): `scroll-padding-inline`.
- Style guide PDF rebuilt (Part C tokens, type/space tables, component shots incl. a new stitched-card demo). `tests/build_guide.py` now also runs on Windows (file URLs, date format, pdftotext encoding).

## 2.0.31
- Pixel art (Stitched Toy) wired in: PNG-first art loading with SVG fallback (ph, ico, animals, landing, stops, gather), pixel flowers/bouquets (tinted), layered pixel gnome avatar, pixel chest, new puzzle GIFs, icons and share card. Puzzles page now uses the site layout. Art guide: Part D addenda. No schema change.

## 2.0.29
- Logged-out homepage and How to play page reworked in the Hearthlight look (warm hero card, one primary button, picture tiles, centred on desktop, real headings in guide folds); 7 landing scenes restyled. Review: claude/landing-review.md. No schema change.

## 2.0.28
- Art only: six weak icons redrawn (clap, party popper, watering can, flatbread, sailboat, grain); guide PDF rebuilt. No code or schema change.

## 2.0.24
- Emoji second pass: JS now shows our own icons (`gvIco()`, `gvIcoLine()`, `gvIcoNode()`, `gvLeads()` in `site.js`; no icon = emoji stays). Done in chest, fighton, gather-games, pest, tilemap, trekfight, trekscene, site.js toasts / crop select / energy lines, spit.js canvas gnome. CSS pin + leaf `content:` emoji are background icons.
- Fixed (broke in 2.0.23): Mushroom win celebration (checked for a leading 🏆 that PHP had swapped to an image), "New Almanac pages" toast folding, 🧺/🐦 toast ranking. `gvLeads()` handles both forms.
- `creature_pic()` (layout.php): duel box and lair boss use the creature's art when it exists, else the emoji icon. NPC portraits NOT used for `npc_icon()` (portraits are 400x500, per NPC; icon sites are species text).
- No schema change.

## 2.0.23
- Emoji are replaced by our own hand-drawn icons at render time (`includes/emoji_icons.php`, `ico_start()` output buffer): map of 480 emoji -> 269 `ico-*` icons (`includes/data/ico_map.php`, built from `tests/ico_map_source.json`). Admin setting `ico_swap` (default on; off = plain emoji). Player-typed text goes through `eu()` so it stays emoji.
- Small-icon pen mode in the Hearthlight restyle (ICO_HALO 6.0 u / ICO_OUT 3.4 u; large stickers keep 3.2 / 1.9).
- NEW Admin > Art & style guide: 36-page PDF (`tests/build_guide.py`, text in `tests/guide_src/`), download from the page. Art-rules text reconstructed from `tests/hearth.py`.
- world.php: 1 px sideways scroll fixed.
- JS-built and CSS `content:` emoji stay emoji for now (second pass, see todo "Emoji leftovers"). Test: `php tests/emoji_icons.php game`.

## 2.0.22
- Art only: all 1428 placeholder SVGs restyled in the Hearthlight look (warm palette, same names and viewBoxes, no code or schema change). No player news.

## 2.0.2
- Puzzles locked to admins for now (setting "Games: Puzzles open to every player", off by default). The Games tile is hidden for players.

## 2.0.1
- Treks: trailmates rebalanced so any party can win Chapter II bosses (all 20 parties 76–95% vs Pinch and Thrum). Riddles give 2 tries. Old campsites (2 in Chapter I, 3 in Chapter II): free rest, small ambush chance, optional KO checkpoint. Daily trek item cap setting (off by default). Unused text slots hooked up.
- Road: the "in sight" timer counts down live; clearer "then on to" wording.

## 2.0.0.1
- Puzzles: animated jigsaw game (puzzles.php, Games hub tile). No prizes, nothing saved on the server.
- New picture: Swaying Sunflower (generator: tests/gen_puzzle_sunflower.py). Also 6 pictures from the Jiggy Jigsaws source.
- Fitted to the site CSP: own CSS/JS files, pictures as files (no blob:, no web fonts).

## 2.0.0
- Treks Chapter I: story text bodies written as drafts for the 89 slots that had none (status draft, editable in Admin > Trek text).
- Upgrade step fills any empty trek body from its draft. Never overwrites a body Joshua wrote.
- Version numbering: 1.9.99 is followed by 2.0.0.

## 1.9.9
- Treks audit fixes across Chapters I and II; corrupt-state safety; new audit tests.
- Admin trek text: bad-input guards. Security pass (~45 bad-input POSTs, XSS, concurrency).

## 1.9.8
- Shop Buy/Sell as picture tiles with a quantity sheet and live total.

## 1.9.7
- Yard: tapping a glowing building collects and returns to the garden.

## 1.9.6
- Today page centring fixes.

## 1.9.5
- Treks no longer use gnome level for balance (`trek_base_level` 15). Chapter I/II retuned.

## 1.9.4
- Road choice cards, villagers and travellers met on roads, per-wonder text.
- Treks Chapter II-b: 15 new spots, riddle signposts, camp-to-camp travel, Slide, cold rest.

## 1.9.3
- Road life: anti-repeat for creatures, problems, finds; weather/season conditions; ambient road lines.

## 1.9.2
- Treks Chapter II-a "The Weeping Clay". Trek text editor upgrades (chapter tabs, drafts, in-game pencil).
- Today page merged into one page.

## 1.9.1
- Treks chapter engine: per-chapter runs, interlude hub "The Shard Hollow", data-driven chapters. MySQL migration verified live.

## 1.9.0
- Player's own gnome in Treks. Leave / Climb-out confirmations. Security fixes for Treks POSTs.

## 1.8.x
- 1.8.0 Treks Chapter I "The Wilting Rows" (party campaign). 1.8.4–1.8.8 fight redesign, tactics, auto playback, trail events, trek levels with milestone XP, map art.

## 1.7.x
- 1.7.0 Reactions merged into guestbook stamps. 1.7.2 Jobs → "Tasks" tabs; Together page. 1.7.3 menu regroup, desktop A4 side menu. 1.7.5 Tasks badge, Today greeting.

## 1.6.x
- 1.6.0 Mycelium cross-section world map and 14 region maps. 1.6.5 Dark mode default. 1.6.8 Email verification at sign-up, opt-in reminder emails, error log rotation.

## 1.5.x – 1.0.x
- 1.5 gathering mini-games; rest-stop cap. 1.4 garden animals, Seed Spitting physics. 1.1 crop breeding. 1.2 quail/silkworm/tortoise, player mentors. 1.0.0 "The Hollow Wakes Up": clock, seasons, weather, rest stops rewrite, orders, market day, social.

## 0.x
- Pre-1.0 history (regions, landmarks, gathering, crafting, trading, Job Board, admin updater, security pass). See git history.
