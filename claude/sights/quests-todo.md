# Trail Sight quest lines: what the data could not do yet

Status 2026-11-12. All 25 designed lines are in `game/includes/data/trail_sight_quests.txt` (8 Maplewold, 9 shared land, 8 end pieces; 140 beats). Lint: `php tests/trail_sights_lint.php <game dir>` shows no `BAD quest` lines.
NOTE for the lint script: `tests/trail_sights_lint.sh` rsyncs with `--exclude data`, which also skips `includes/data/`, and then copies only `trail_sights*.txt`, so a scratch install that already exists keeps an OLD `trail_sight_quests.txt` (and info / items / folk files). Copy them in by hand, or make the script copy `trail_sight_*.txt` too.

## Engine gaps (each line keeps the beat as "use that Sight")

- **"Any order, but this one last" (the design's `→`).** Every Maplewold line is "any order, the → beat last". The engine has only `seq` or `any`. Chosen: `any` for Bramble's Picnic List (it must start on whichever Market road a new player takes first; the picnic can now be done before the other six) and Wren's Woodland Census (the stump hand-in can come early); `seq` (in design order) for the six story lines. Wish: an order `last` (any order, final beat last). Same wish for end pieces Q4 Gate Rubbings and Q5 Book of Hushes (fixed first and last beat, any middle; made `any`), and Q1/Q2/Q6 (made `any`).
- **A Sight twice in one line cannot work** (`trail_sight_quest_hook` finds the first beat with that slug and skips a Sight already done). Shared lines HAT, PICNIC, LADDER start and end at the same Sight: the closing beat was dropped and folded into the outro (HAT 4 beats, PICNIC 5, LADDER 4).
- **Taking an item at a beat** (no `take=` on beats): picnic-list beat 5 (an item for the scarecrow: the Sight row already takes one) and beat 7 (eat a snack with Bramble), sap-to-stack (2 `wheat` -> flour, sap -> syrup), lost-lantern beat 4 (`sardine` or `mackerel` for the seal pup), owl-letter (the letter itself; any feather for the cairn), sled-derby, beaver-paperwork beat 3 (`birch-log`), HAT beat 2 (`hen-feather`), KITE beat 4 (`bright-feather`), BRIDGE beats 3-4 (`timber-plank`, `rope`), end Q1 beat 2 (`beeswax-candles`), end Q7 (`red-ochre`: a beat at `desert-the-red-rock-arch` stands in for "bring red ochre").
- **Errands to a villager**: picnic-list "carry the leftover `garden-honey` to Alder Pennywhistle in Honeybrook" (dropped); which-nettle "each Nettle sends the other a parcel once a season" (dropped).
- **A villager beside you at a beat**: Bramble at the picnic (sunny day, after beats 1-6), Pomeroy rating pancakes, Sorrel Rushworth at the oak arch, Wren at the dusk gate, Tobias at the tavern turn. Could come from `trail_sight_folk.txt` rows tied to an open quest.
- **Non-Sight beats**: end Q3 "defeat or befriend one of the three bosses" (replaced by `end-lair-2-mountain` Read the footprints); end Q6 finale "eat a home-cooked meal at a haven" (dropped, 5 beats left); end Q1 "all five lit inside one season" (no time limit).
- **"Best when" / "easier when" conditions** were not made hard rules: sap-to-stack windmill `we=wind`, hollow-round bluebells `se=spring`, star-wheel aurora `se=winter`. Star-wheel eagle beat "not fog" is written as every weather but fog.
- **Rewards the grammar cannot give**: titles (Flapjack Friend, Derby Marshal, Wind Reader, Bridgewarden, Lamplighter, Gate Gazer, Good Nose, Echo Reader), Almanac pages ("My first picnic", "Clover smiled", "Which Nettle?", lantern, owl, census), friendship with BOTH Wickerbys / both Nettles (only the giver gets `fp`), the Den boss hint card and +Charm in that lair only (owl-letter gives a plain `buff=charm:1:120`), half-price Beaverdam build stage and the "Beaver-approved" delve buff, the Wren's Journey Tansy clue, after-effects (seal pup gift, crows' trinket every 7 days, Pinchwell's weekly cowrie, Marrowby's autumn stall, knoll feast buff, stilt-house nap Sight, meadow weather forecast, Lyra's green song), "+10 friendship with every villager of that town" (PICNIC) and "+40 friendship" (HELLO: `fp=3`).
- **Givers who are not villagers yet** (their `fp` would go nowhere, so those lines have no `fp`): Keeper Marram (lost-lantern), Beaver Foreman (beaver-paperwork). Pomeroy Crumbworth has `fp=2` but is not an active row in `npcs` on a fresh install: check that it lands.
- **Givers named by personality in the shared-land design**, picked from the fresh-install villagers: KITE Dreamy -> Mabel Pennywhistle, HAT Fussy -> Moss Windlass, BRIDGE Proud -> Sorrel Rushworth, HELLO Shy -> Bunty Windlass, PICNIC Generous -> Yarrow Mossgrove, LADDER Sleepy -> Posy Thistledown. Which-nettle uses "Nettle Cobblefield" (two villagers share the name; `fp` goes to the first). sled-derby giver is Rue Wickerby (Elm is co-giver in the design).
- **How a line starts**: the designs start lines from a villager's request (Notice Board favour, road cards `na-owl-letter`, Journey chapter "The Sugar Shack" for Clover). The engine starts a line at its first beat Sight. Sap to Stack should wait for the Sugar Shack chapter.

## Wished-for items (stand-ins used now)

| Line | Wished (new) | Stand-in in the data |
|---|---|---|
| sap-to-stack | maple sap, flour (beats), title | `pancakes` x3 + `maple-syrup` (from trail_sight_items.txt) |
| lost-lantern | (none) | `stone-lantern`, `sea-glass` x2 as designed |
| owl-letter | Den hint card | `owl-feather` |
| woodland-census | old NA seed | `seed=1` (a seed of the start region) |
| sled-derby | (title only) | `birch-log` x3, `timber-plank` |
| runaway-kite | Kite-String Spool, the Runaway Kite (hovel decor) | `silk-bunting` |
| sunday-hat | Hatter's Thimble | `shiny-trinket` |
| bridgewarden | Bridgewarden's Badge | `stepping-stones` x2 |
| hello-letters | Seaside Stationery | `cowrie-shell` x3 |
| star-wheel | Pocket Star-Wheel | `sundial` + `seed=1` |
| picnic-for-everyone | Picnic Flour, Patchwork Picnic Blanket | `garden-honey` x2 |
| hollow-round | Song Sheet: The Hollow Round | `wind-chime` |
| trader-went-home | Marrowby's Old Price Book | `woven-basket` + more coins |
| walking-ladder | Feather Pillow | `hammock` |
| lamplighters-round | taper; design reward `glowcap-lantern` (exists, but price 2000 and a tier-30 tool: too rich) | `tin-lantern` |
| big-friends-lullaby | Snore Notes, Big Friends Lullaby song, Hushed Steps buff | `firefly-jar` + `buff=nimble:1:240` |
| scouts-field-notes | Scout's Spyglass | `pretty-feather` + `buff=sense:1:240` |
| gate-rubbings | Gate Rubbing tokens, old-world seed | `seed=1` |
| book-of-hushes | Hush Pages, Book of Hushes (decor) | `sages-draught` (as designed) |
| follow-your-nose | Spoons, sauna buns | `feast-berry-honey-cake` (as designed) |
| rest-here-repainted | (none) | `scute-wind-chime`, c=80 (design c=120) |
| echo-map | Echo Map (first room preview) | `hiking-staff` (as designed) |
