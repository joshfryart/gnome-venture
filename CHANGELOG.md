# Changelog

## Unreleased
- **Delve route menu**: prettier panel (framed, stage numbers, dotted links between rows, raised pick buttons). The whole route now stays on screen after each floor: the rooms you took are lit with a ✓, the rooms you passed by are greyed out and can't be picked. Files: `includes/delve_v2.php`, `style.css`. `tests/delve2.sh` passes.
- **Workshop popover actions**: Make ×2 / ×5 / All and Collect buttons now send which button was pressed (before, the amount was lost). After any action the picture behind updates too: the **!** badges, the chips, the card's recipe count and the energy / header strip. File: `workshop.js`.
- **Workshop picture**: a green **!** now sits on each crafting section with something to do (recipes ready to make, pantry jars done). Section popovers no longer repeat the page's area strip and big picture; they are a wide, left-aligned, scrolling sheet (the old 420 px cap squeezed them). Files: `hub_scene.php`, `hub_pages.php`, `craft_map.php`, `workshop.php`, `style.css`.

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
