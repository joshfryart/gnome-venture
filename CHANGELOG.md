# Changelog

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
- **Cat Fish** (Games, off for players until Admin > Settings `catfish_open` is On; admins see it now). An idle game: adopt a cat, a toy rod sways on its own, the cat catches fish and drops Kibble, Kibble buys 16 upgrades in four branches (Fish, Rod, Room, Cat). Kibble is earned on the server clock only: full speed while the page is open, half speed away (up to 8 hours).
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
