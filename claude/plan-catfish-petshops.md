# Cat Fish: pet shops, slots and long-cooldown scene events (design, not built)

Status 2026-10-30: sections 1-5 BUILT on branch ccr-d4955a91-j50rxx (server `includes/catfish_pets.php`, UI, tests; art drawn in `aseprite-source/catfish/art22/out/` but not installed, so placeholders show); section 6 (scene events) NOT built. Built differently from the sketch: meta `slotn` is the list of Yarn spots opened (not a count); buying is `shop.php` `do=pet_buy` only; the scene key also holds which active things are ready, so the stage swaps when a cooldown ends. Designed with an Opus agent and a Fable agent, approved in outline by Joshua. Facts below came from the agents' reading of the code; re-check file:line before building.
Owner decisions: **no cap on the summed passive Kibble %** (see Guardrails). Placeholder art = red border + THIS IS PLACEHOLDER (`tools/gen_placeholder_art.py`).

## 1. Shops: 11 (regions 4 and up, one pet shop in each region's market town)
Region order is `REGION_LEVELS` (`includes/progression.php:10-11`); 14 regions in all (`includes/data/regions.txt`). If the order should follow `sort_order` (file order) instead, Mistmoor (NWE) gets a shop and Sunsprinkle Isles (CB) does not. Shops are created beside each seed market (`includes/catalog.php:408-414`, staff row like `:448`); buying needs `shop_reachable` (`world.php:310`). Currency: Petals (`take_petals`, `includes/rewards.php:29`). No item ever gives Petals.

| Region (code) | Shop | Shopkeeper |
|---|---|---|
| Sunsprinkle Isles (CB) | Driftwood & Whisker | Coral Pennyfeather |
| Olivewhistle Shore (SE) | The Olive Pantry Pets | Nonna Briscola |
| Rainroot Reaches (SA) | Canopy Critter Co. | Abuela Quilla |
| Birchbramble Steppe (EE) | Birch Hut Pets | Babka Wren |
| Dunewhisper (MENA) | Lantern & Lounge | Auntie Saffira |
| Blossomreach (EA) | Blossom Lantern Cattery | Grandmother Hoshi |
| Spicepeak (CSA) | Spice Bazaar Pets | Didi Marigold |
| Monsoon Tangle (SEA) | Monsoon Mew Market | Pak Lontar |
| Greatcanopy (WCA) | Drum & Den | Auntie Mossbead |
| Thornacre Savanna (ESA) | Thornacre Trading Den | Old Baobab Kito |
| Coralscatter (OC) | Reef & Purr | Captain Pipi Shellback |

## 2. Slots (8) on the scene
Coordinates from `aseprite-source/catfish/room-layout.json`; they avoid the play zone (70-250 x 120-190), the hook (66,12) and the fish strings (x 118/170/222).

| # | Type | Where (room px) |
|---|---|---|
| 1 | shelf-a | shelf `[280,12,319,39]`, left half |
| 2 | shelf-b | same shelf, right half |
| 3 | sill | under the window `[0,10,37,77]`, about y 64-77 |
| 4 | frame | replaces the picture `[282,42,317,73]` |
| 5 | ceiling | garland strip y 0-10, x 80-276 |
| 6 | floor-left | corner behind the cushion, x 0-38, y 140-166 |
| 7 | floor-right | between rug end (241) and bowl, x 244-280, y ~176 |
| 8 | rod charm | a class on `.cfstage` (like `CATFISH_ROD_CLASSES`) |

Fit rule: each item lists `fit=[types]`. Shelf items fit shelf-a, shelf-b or sill; everything else only its own type. An item sits in one slot at a time; swapping is free.
Unlocking: slots 1, 3, 7 free from the start; 2, 4, 6 open after buying from 1, 3, 5 different regional shops; 5 and 8 cost Yarn (5 and 15).

## 3. Stock (55 items). Slot . P = passive, A = active (cooldown) . effect . Petals
"Pop N" = Kibble worth N minutes of the current Kibble/h (counts toward the daily active cap).
**CB Driftwood & Whisker:** Conch Shell (shelf, P, cosmetic, cats "listen") 400 . Hammock Net (floor-left, P, away cap +10 min) 1800 . Flying-fish Charm (rod, P, cosmetic leap) 900 . Steel-pan Chime (ceiling, A 12h, Pop 10) 2200 . Parrot Perch (sill, A 24h, reveals one of tomorrow's shelter coats) 3000
**SE The Olive Pantry Pets:** Terracotta Catgrass (sill, P, +2% Kibble) 3500 . Mosaic Mat (floor-right, P, cosmetic) 600 . Lemon on a String (rod, P, +1% Kibble, lemon fish skin) 2400 . Amphora (shelf, A 20h, Pop 15) 2800 . Siesta Fan (ceiling, P, away cap +15 min) 2600
**SA Canopy Critter Co.:** Bromeliad (shelf, P, cosmetic, frog peeks) 500 . Capybara Plush (floor-left, P, Cat Show +1 if the entered cat is lazy) 2000 . Toucan Feather Lure (rod, P, first 10 taps each day x1.5) 2200 . Rain Stick (sill, A 16h, Pop 10 + an hour of rain on the window) 2000 . Panpipe Chime (ceiling, P, cosmetic) 700
**EE Birch Hut Pets:** Matryoshka Mice (shelf, A 24h, Pop 5, 1-in-50 chance of 1 Yarn) 3200 . Rug Runner (floor-right, P, cosmetic) 600 . Felt Boot Bed (floor-left, P, away +10 min) 1800 . Sunflower Head (sill, P, +1% Kibble, birds peck) 2400 . Painted Egg Charm (rod, P, cosmetic tassel) 900
**MENA Lantern & Lounge:** Brass Lantern (ceiling, P, warm glow) 900 . Kilim Cushion (floor-left, P, Cat Show +1) 2800 . Bell Lure (rod, P, cosmetic jingle, gold combo pop) 800 . Sand Timer (shelf, A 24h, Pop 20) 3500 . Mirage Mirror (frame, A 18h, says if tomorrow's shelter has an uncommon-or-better cat) 3000
**EA Blossom Lantern Cattery:** Maneki-neko (shelf, A 24h, Pop 15, 1-in-40 chance of 1 Yarn) 4500 . Paper Lantern String (ceiling, P, cosmetic) 800 . Bonsai (sill, P, +2% Kibble) 4000 . Koi Kite Lure (rod, P, koi skin, rare fish +5%) 3000 . Tea Tray (floor-right, A 12h, all cats play happy frames, Pop 5) 2200
**CSA Spice Bazaar Pets:** Singing Bowl (shelf, A 12h, previews your cat's score for this week's show theme) 1500 . Marigold Garland (ceiling, P, cosmetic) 700 . Tiger-stripe Rug (floor-left, P, cosmetic) 900 . Kite Tail Lure (rod, P, Catnip Hour +10 min) 2400 . Chai Stall Sign (frame, P, +2% Kibble) 3800
**SEA Monsoon Mew Market:** Paddy-hat Bed (floor-left, P, away +15 min) 2600 . Gecko Friend (frame, P, cosmetic, animated) 800 . Shadow-puppet Screen (sill, A 16h, names one coat you have never seen, text hint only) 2500 . Banana-leaf Fan (ceiling, P, cosmetic) 600 . Floating Lantern (shelf, A 24h, Pop 20) 4000
**WCA Drum & Den:** Talking Drum (floor-left, A 24h, one free shelter reroll, still counts toward `CATFISH_REROLL_MAX`) 5000 . Kente Bunting (ceiling, P, cosmetic) 800 . Calabash Bowl (floor-right, P, +2% Kibble) 4500 . Weaver-bird Nest (sill, P, window bird visits twice as often, rare fish +5%) 3500 . Mask Frame (frame, P, cosmetic) 1000
**ESA Thornacre Trading Den:** Acacia Perch (sill, P, Cat Show +1) 3500 . Beaded Rack (shelf, P, cosmetic) 900 . Grass Tuft (floor-left, P, away +10 min) 2400 . Rain-cloud Mobile (ceiling, A 24h, Pop 15) 3500 . Coffee-bean Rattle (rod, P, first 30 taps each day +25%) 3000
**OC Reef & Purr:** Tide-pool Jar (shelf, A 24h, Pop 10, 1-in-30 chance of 1 Yarn) 5500 . Driftwood Board (frame, P, cosmetic) 1000 . Southern Cross Mobile (ceiling, P, +2% Kibble) 5000 . Kiwi Plush (floor-left, P, Cat Show +1) 3500 . Seashell Lure (rod, P, rare fish +5%) 4000
Mix: 22 cosmetic or info-only, 23 small passive, 10 real active. No duplicates of the Yarn sinks (Rod Tune-up, Mood Treat, Keepsake have no item twin).

## 4. Guardrails
- **Kibble %: NOT capped (Joshua, 2026-10-29).** The bound is the 8 slots and `CATFISH_MAX_KPH` (`includes/catfish.php`); keep each item at +1% or +2%. Because it is uncapped, reprice the +% items upward if the sim shows them paying back too fast, and re-run `php claude/catfish-sim.php` with all Kibble slots filled before shipping.
- Other caps are proposals Joshua has not changed: away cap +30 min total, Cat Show +2 total, rare fish +10% total, Catnip +10 min total, tap bonuses only on the first 30 taps a day.
- Active items: at most 4 uses a Hollow day across all slots; pops total at most 60 min of Kibble a day; at most 1 Yarn per ISO week from all items.
- Cooldown belongs to the owned item (not the slot): swapping out and back never resets it. An active item must have been slotted for 1 hour before use.
- Items live in their own table, not `user_items`, so they cannot be sold, traded or gifted.
- Cat Book hints (Shadow-puppet Screen, Mirage Mirror) never write `cat_book` rows: `book12` and `book_half` pay Petals from those rows (`catfish_milestones_reached`), so a written row would be a hidden Petal source.
- Buying needs the gnome to have reached the region (`shop_reachable`). A Nap does not reset items. All numbers should be admin settings.

## 5. Implementation sketch
- Table `catfish_items (user_id, item_key, got_at, last_used, slotted_at, PRIMARY KEY (user_id, item_key))` in `catfish_ensure`. Meta keys: `slots` (slot no => item key), `slotn` (unlocked count), `pa` {day, n, kmin} (daily active cap), `py` {week, n} (weekly Yarn cap).
- New `includes/catfish_pets.php`: `CATFISH_PET_SLOTS`, `CATFISH_PET_ITEMS`, `petshop_buy()` (reachable, `take_petals` + insert in one transaction, like `festival_buy`), `catfish_pet_slot()`, `catfish_pet_use()` (inside `catfish_locked`, applies caps), `catfish_pet_bonus()`.
- `shop.php`: `pets` shop type, `pet_` actions routed like `sink_`.
- Hooks: Kibble `catfish_extra_mult`, away cap `catfish_offline_cap`, rare fish `catfish_rare_fish`, Catnip length `catfish_catnip`, show score `catfish_show_enter`, taps `catfish_play`.
- Scene: `catfish_pets_html($slots)` called in `catfish_stage_html` after `catfish_room_extras_html`; floor items join `$spots` for depth sorting; active items are `<button class="cfpet cfpet-sN" data-slot>`. `catfish_scene_key` must include the slot map (new argument; `catfish_scene` then needs `$uid`). `$withScene` in `catfish_api.php` must send `stage_html` for `petslot` / `petuse`.
- Swap UI works without JS: a "Room things" panel with one `<form>` and `<select>` per slot (`do=petslot`, `do=petuse`); `catfish.js` only enhances.
- Tests (`tests/catfish.sh`): wrong-fit refused, one item one slot, locked slots refused, cooldown survives a swap, 1-hour slotted rule, 5th active use refused, pops stop at 60 min, seeded Yarn odds and weekly cap, no `give_petals` path, buying away from the region fails, regions 1-3 have no pet shop, scene key changes with a slot, `pet_slots` in room-layout.json matches `.cfpet` CSS, a hint never inserts a `cat_book` row.
- Build first: the Steel-pan Chime (CB). It runs the whole pipeline with a bounded Kibble-only reward.
- Agent's top six: Talking Drum, Parrot Perch, Maneki-neko, Shadow-puppet Screen, Terracotta Catgrass, Paddy-hat Bed.

## 6. Long-cooldown scene events (Joshua asked for more; none built)
Server-owned cooldown per event (one timestamp each in `catfish_state.meta`), claimed with a new `do=scene` action; availability is a deterministic window per user and period, so being away stores nothing. Rewards are minutes of the player's own Kibble/h (they scale), plus information or cosmetics. All events share one daily budget of about 60 minutes of income. Reduced motion: static markers.

| # | Event (tap target) | Cooldown | Reward |
|---|---|---|---|
| 1 | Toy box rummage (toy box) | 20 h | Pop 10, 1-in-20 cosmetic toy |
| 2 | Warm patch (sunbeam) | window every 4 h, 3 a day | cat naps in the sun; join: Pop 15 |
| 3 | Bird gift (window bird) | visits about every 6 h, stays 30 min | a feather for a cosmetic collection, Pop 10 |
| 4 | Flap visitor (cat flap) | 8 h | pet a stranger: one unseen coat is shown as "seen" in the Cat Book (text hint, see guardrail: no `cat_book` row) |
| 5 | Full bowl (bowl) | 12 h | 12 h buff of +3% Kibble/h, no stacking |
| 6 | Tree lookout (cat tree) | 24 h | tells you tomorrow's best shelter cat (information only) |
| 7 | Golden fish (the rod) | 6 h | a golden fish for 20 s: Pop 30, capped |
| 8 | Yarn unravel (yarn ball) | 7 days | a crumb; 8 crumbs make 1 Yarn (the only Yarn source, riskiest) |
Pick first: 2, 4, 6. Pet-shop active items can BE these events (the Chime is event 7's shop twin) while passive items modify them (Weaver-bird Nest doubles event 3).

Short-cooldown scene taps from the Fable low agent (cosmetic, client-only unless noted): yarn ball tap (`is-roll`, stalk then pounce), bird shoo, combo x10 burst, scratch post stretch, bowl refill walk; sunny taps (server, x1.5 on 20 taps a day, `CATFISH_PLAY_UP` hook); toy box rummage; cat flap visitor (L).

## 7. Art needed (placeholders first, red border + THIS IS PLACEHOLDER, `tools/gen_placeholder_art.py --many OUTDIR name...`)
55 item sprites `assets/img/catfish/cf-pet-<key>.png` (about 32-48 px, per slot type size in the table), 8 slot-sized positions in `room-layout.json` (`pet_slots`), a pet shop banner per region (480x120, `banner-<code>-pets`) and shopkeeper bust per region (`npc-<slug>`, 400x500). Event props: golden fish, feather, stranger cat (reuse cat renderer), crumb of yarn.
