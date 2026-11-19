# Shared land Trail Sights: what still cannot be done (engine gaps)

Status: checked line by line 2026-11-19 (Sights fourth pass, `claude/trail-2.7.08-notes.md` "Fourth pass"). DONE = in the engine (and in the data where it says so); OPEN = still not possible, with what it needs. Data: `trail_sights_shared.txt` + the 5 example rows in `trail_sights.txt`, `trail_sight_folk_shared.txt`, `trail_sight_quests_shared.txt`, `trail_sight_items_shared.txt`, `trail_sight_pages_shared.txt`, `trail_sight_newfolk_shared.txt`. Ideas: `ideas-shared-land.md`. Art: `shared-art-todo.md`. Grammar: `GRAMMAR.md`.

## Test harness (tests/trail_sights.php)
- DONE (checked 2026-11-19): the all-routes walk passes the right `pick` for every `pick:` Sight.
- DONE (checked 2026-11-19): the quest walk hands over beat `needs` items (`trail_sight_beat_need`), follows `anylast` / `firstlast` through `trail_sight_beat_open`, fires @boss / @meal / @friend / @green events and takes board lines first; all lines run to the end.
- DONE (checked 2026-11-19): "one page per Sight" counts only `unlock_key LIKE 'sight:%'`, so the extra `page=` pages do not break it.
- DONE 2026-11-19: the all-routes walk took a stale scene after a Sight that saves the walk state itself (`nxt=`, `sec=`), so the next Sight was refused "You need to be next to it"; it reloads the scene now, and hands over an item for `take=any-<kind>`.
- OPEN (by choice): `grassland-the-clover-patch` is the tests' fixture row (no check, win line with "thorough"), so it keeps no luck check (design: luck 12). Needs: the tests moved to another fixture row first.

## Grammar gaps
- DONE 2.7.06: `@chance` on `fpto=`, `hint=`, `title=`, `page=`, `disc=`; `?cond` on `tally=` (2.7.01).
- DONE 2.7.01: `tn=key:N` = exactly N (a milestone that pays once).
- DONE (checked 2.7.08): `nocheck` settles a `pick:` Sight too.
- DONE (`qd=<quest slug>`, built before 2.7.08, documented in GRAMMAR.md "second pass"): a condition for "this quest line is done". In the data 2026-11-19: the meadow forecast after KITE (`grassland-the-wind-combed-meadow` `hint=weather?qd=runaway-kite`), Marrowby's weekly stall (`desert-the-trader-s-tent-poles`, a third Old Marrowby row `gd=7:0/qd=trader-went-home`). OPEN, each a row to write with `qd=` (writing, no engine work): stilt-house nap Sight, knoll feast buff, crows' trinket every 7 days, Pinchwell's weekly letter. OPEN: Lyra's Hollow Round buff "whenever she is on a green": needs a town-Green hook that pays a buff when Lyra is there (town.php), not a Sight token.
- DONE 2.7.06: either / or checks (`stat:dc+stat:dc`). OPEN: boardwalk "plank OR nimble 9" (an ITEM as the other way): needs a check alternative that is a take (`nimble:9+take=plank:1`), a new check kind.
- DONE 2026-11-19 (fourth pass): a season- (or weather-, time-) dependent DC: `stat:dc?cond:dc2`. In the data: `forest-the-bluebell-glade` `sense:11?se=spring:9`.
- DONE 2026-11-19 (fourth pass): penalty tokens `lose:time= / lose:nxt= / lose:sec=` (paid on a lost check). The wind notch has no check, so its headwind is a plain conditional cost: `mountain-the-wind-notch` `time=15?we=storm` with a storm line (the Nimble buff is now `we=wind` only).
- DONE 2.7.06 (`time=N`, 1-480 game minutes): "rest N game hours". In the data 2026-11-19: `mountain-the-stone-hut` `time=60`, `desert-the-shade-awning` `time=120`. Not changed: hammock and bones (the ideas give no hours). JOSH: the two rows pay the same energy as before and now cost game time.
- Folk rows:
  - DONE 2.7.01 (`check=stat:dc` in a villager row's rewards): a stat check for the villager's own ask. NOT in the data: all 14 shared rows with an ask (plank footbridge, sleepy windmill, root tangle, mushroom ring, willow curtain, frog choir, wind notch, eagle's rest, net rack, sea-stack gap, bones, mirage pool, mist pool, sand spit) have a line that tells a success, and a miss only says "They ask more of you than you can manage today". Needs: a miss line per row (a 7th folk column or `line // miss line`) and Josh's yes that these villagers pay less often.
  - DONE 2.7.06: `escort=Name` (needs an eye check); `lend=` / `repay=`.
  - DONE 2.7.00 (`disc=shop|rest:percent:minutes`): shop effects as a percent off every shop. OPEN: Tobias "20% off seeds only", Marrowby's price book "better prices at travellers", Lyra's free song: need a discount scoped to one shop / item kind / one NPC service (`shop_price` hook has no scope).
  - DONE 2026-11-19: Mabel's hay-ride (`grassland-the-hay-cart-ruts`, `nxt=quick:10`).
- Effects that are not tokens:
  - DONE 2026-11-19: rowboat short hop (`coast-the-stranded-rowboat` `nxt=skip?dp=dawn/ti=high`); Lantern Path no-fog night (`rainforest-the-lantern-fruit` `nxt=lit?dp=night`: one night pick lights the path; "3 picks in one night" is not possible with 1 use per cooldown). Fog itself: `nxt=fog`, and foggy weather behind the setting `trail_fog_weather` (default off).
  - DONE 2.7.08 third pass B (keepsakes): Squirrel's Spare Key (forage +1), Teeny Axe (axe +1, every axe find, not only the bramble gap).
  - OPEN: next fishing Sight +1 catch (Keeper Loamwick), next crossing +2 (lily-pad coach): need a "next Sight of kind X" flag and a kind on Sight rows (rows have no kind). Hatter's Thimble on gifts only, Parrot Phrasebook with travellers only: need item effects read by the gift / traveller code. Pocket Star-Wheel night markers: needs a map layer. Bridgewarden's Badge +2 on crossings, Feather Pillow +1 energy on naps: both are decor; need a carried-item effect by Sight kind (again a kind on rows).
- OPEN (owner decision): charms that cannot be buffs without changing `edible` (fern-drip-hat-charm, pocket-whistle, daisy-chain-crown stay keepsakes). Needs: Josh's yes to set `edible` 1 on them, or a "use" action for non-food items.
- DONE 2.7.08 (`fpall=N`, 1-9, every villager of the walk's START place): "+friendship with the whole town". Not in the PICNIC reward: the idea says +10 (over the token's 9) for "that town" (the token knows only the walk's start place). Needs: Josh's number. OPEN: "Wish Delivery" (a thank-you in the next town 3 days later): needs a delayed-delivery queue (no token).
- OPEN (P4, shared across players): cairn pass stone count and Cairn Token, other players' bottle-post notes, stargazer's chalk marks. Needs: a shared table per place and moderation rules; an owner decision.
- DONE 2.7.08 third pass B: quests that start from a Notice Board favour (`board` column, `quest=<slug>`). Only Wren's Woodland Census uses it; the shared lines still begin at their first beat (set `board` per line if wanted).
- DONE 2.7.08 third pass B: seeds that must grow (Tiny Thank-You Seed, Lantern Fruit Seed: `trail_sight_seeds.txt`).
