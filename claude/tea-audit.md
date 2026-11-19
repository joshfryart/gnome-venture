# Tea audit (read-only, 2026-11-19)

Scope: every tea, tea-like drink and tea-able ingredient now in the game, plus what a kettle system must replace.
No code or data was changed. No DB is in the repo, so prices marked (calc) are worked out from the formulas in `catalog.php`, not read from a live DB. Verify before balancing.

Line numbers: `R` = `game/includes/data/recipes.txt`. All other paths are under `game/includes/` unless they start with `claude/` or `tests/`.

## 0. How drinks work today (facts)

- No kettle, teapot, cup or tea station exists. Grep for kettle/teapot finds only flavour text, town names ("Campfire Kettle", "The Crooked Kettle" in `data/here_layouts.json`) and a trek event `kettle` (`trek_events.php:27,161,332`).
- The Hovel has no stations. `hovel.php` has tabs Sleep/Today/Tasks/Pals/Costs. `home_slim.php` + `data/hovel_decor.json` has 7 decor slots (Floor, Wall, Window, Shelf, Rug, Lamp, Pet corner), table `user_hovel_decor`. A kettle would be a new slot or a new tab.
- Crafting stations are pictures only (`data/craft_scenes.php`): stove, cheese, cordials, can, seeds, flasks. Recipes are routed to them by slug glob.
- Every recipe tea is a **cooking recipe**, tier `snack`, cook 3 min, 0 energy cost, batch up to `snack_batch_max`. Output is a stored `food` item (`catalog.php:561-614 import_recipes`).
- Price of a non-preserve dish = `max(20, round(sum(ingredient base_price) * 1.4))` (`catalog.php:604`).
- Eating/drinking: `gnome.php:440 eat_item`.
  - `effects.temp` = `{stat:n, minutes:m}` goes to `users.buff` / `buff_until` (JSON, real minutes). A second slot `buff2` / `buff2_until` is used only by the Brewroot calling perk `two_buffs` (`gnome.php:515-531`). A new meal replaces the old one.
  - Minutes are scaled by `buff_minutes()` (`gnome.php:405`): calling `buff_pct`, Foodie rank, `packed_lunch` perk, craft mastery, best Kitchen building `buff_pct`.
  - `effects.energy` is added to `users.energy`. Home-cooked dishes get x`cook_energy_percent` (115) and the `seasoned` / calling `meal_energy_pct` perks (`gnome.php:540-552`). Test: `tests/cook.sh:51` mint tea 4 x 1.15 = 5.
  - `effects.tea` (string `tbuff:stat:amt:min`) = take-away teahouse drink: writes `users.town_stat/town_amt/town_until` (`gnome.php:470`, `events.php:211`).
  - Full energy: a drink with only energy is refused. A drink with a buff is still drunk.
- Other buff stores read by `eff_stat()` (`gnome.php:206`) and listed by `active_effects()` (`gnome.php:140-160`):
  - `users.ev_stat/ev_amt/ev_until/ev_day/ev_scope` = "A lucky moment". Sight and event `buff=stat:amt[:minutes|sleep|delve|section]`. `:sleep` sets `ev_day = game_day`, so it ends on the next sleep (`events.php:156`, `gnome_ev_slept` `gnome.php:194`). Needs `gclock_on()`, else falls back to 60 min.
  - `users.ev2_*` = second lucky moment, Sight `buff2=` (`trail_sights_3a.php`).
  - `users.town_*` = town outing. No sleep scope, minutes only.
  - `claude/sights/GRAMMAR.md:13,59,64,65,77,86` documents `buff=` / `buff2=` incl. `:sleep`.
- Game day = 06:00-22:00 game clock, ends at Sleep (`almanac_pages.php:12`). `users.game_day` increments on sleep.
- Recipe unlock: `craft_recipes()` (`crafting.php:109-160`) inserts `user_recipes(user_id, recipe_id, learned_at, made)` once **every ingredient slug has been "seen"** (`collected_slugs`). `made` drives craft mastery (-10/-25/-50% materials at 10/50/200 makes).
- Recipes already imported are never changed: `import_recipes` skips any slug whose item exists (`catalog.php:579`). Edits to `recipes.txt` do NOT reach existing installs without an upgrade function (pattern: `upgrade_094_cooking`, `catalog.php:726`).
- Shops: **no shop sells any tea/drink**. The only food in `shop_stock` is soup at The Dewdrop Kitchen (`seed.php:95`). `ensure_shop_food()` makes `bought-*` copies only for food that is in `shop_stock`, so no `bought-mint-tea` etc. exist by default. Tests stock them by hand (`tests/cook.sh:121,161`).
- Orders (`market100.php:414-500`): kinds crop 38 / preserve 16 / arrangement 14 / dish 12 / feast 4 / dried 16. `dish` pool = recipes with `tier='meal'` and `category='cooking'`; `preserve` pool = `category='pantry'`. **Snack teas and hot cocoa are NOT in any order pool. Pantry drinks (kombucha, cordials, concentrates) ARE in the preserve pool.**
- Daily jobs (`jobs.php:126`): `deliver_dish` and `cook` pick from the player's known `cooking` recipes, so snack teas can be asked for.

## 1. Table: every tea and tea-like drink

Energy = value in recipes.txt column 6 (before x1.15). Buff = stat:+n, minutes. Sell = `items.base_price` (calc). All are stored `food` items, tradable.

### 1a. Recipe teas and hot drinks (cooking, snack)

| slug | name | R line | ingredients | station | current effect | sell (calc) | art |
|---|---|---|---|---|---|---|---|
| `mint-tea` | Mint Tea | R:11 | mint:2 | cooking (stove, snack 3 min) | sense +2, 120 min, energy 4 | 31 (mint 11 x2 x1.4) | ph/mint-tea.png+svg |
| `meadowsweet-tea` | Meadowsweet Tea | R:30 | meadowsweet:2 (gatherable, 10) | cooking | sense +1, hardiness +1, 120 min, energy 2 | 28 | ph/meadowsweet-tea |
| `desert-sage-tea` | Desert Sage Tea | R:31 | desert-sage:2 (gatherable, 10) | cooking | lore +2, 120 min, energy 2 | 28 | ph/desert-sage-tea |
| `hot-cocoa` | Hot Cocoa | R:23 | cacao:2, sugarcane:1 | cooking | charm +3, luck +1, 180 min, energy 6 | ~244 (cacao 59 x2 + sugarcane 56) | ph/hot-cocoa |
| `crowberry-cordial` | Crowberry Cordial | R:38 | crowberries:3, mint:1 | cooking (a SNACK, not a Pantry jar) | hardiness +2, luck +1, 180 min, energy 5 | ~57 | ph/crowberry-cordial |

Energy values were rescaled in 0.9.4: `OLD_DISH_ENERGY` `catalog.php:667-690` lists `mint-tea` 1, `meadowsweet-tea` 1, `desert-sage-tea` 1, `hot-cocoa` 2, `crowberry-cordial` 2 (old value, only used to detect admin edits).

### 1b. Pantry drinks that use tea/coffee/rooibos/herbs (tier preserve, category pantry, real-time jar)

All: stored, never spoil, liked as gifts by every townsfolk (`fx.preserve=1`), price from `preserve_price()` (`catalog.php:549`, >= 20, jar-days multiplier), 3 jars per batch. Jar time = recipes.txt col 9 minutes.

| slug | name | R line | ingredients | buff, minutes | jar |
|---|---|---|---|---|---|
| `kombucha` | Kombucha | R:180 | tea:2, sugarcane:1 | sense +1, 1080 | 7 d |
| `iced-tea-concentrate` | Iced Tea Concentrate | R:203 | tea:3 | sense +1, 1080 | 7 d |
| `chai-blend` | Chai Blend | R:234 | cardamom:1, cinnamon:1, ginger:1, tea:2 | sense +1, 720 | 3 d |
| `rooibos-concentrate` | Rooibos Concentrate | R:201 | rooibos:3 | hardiness +1, 1080 | 7 d |
| `cold-brew-coffee` | Cold Brew Coffee | R:202 | coffee:3 | nimble +2, 1080 | 7 d |
| `hibiscus-cordial` | Hibiscus Cordial | R:196 | hibiscus:4 | charm +1, 1440 | 14 d |
| `elderberry-cordial` | Elderberry Cordial | R:75 | elderberry:5, mint:1 | hardiness +2, sense +1, 1440 | 14 d |
| `mixed-berry-cordial` | Mixed Berry Cordial | R:76 | blueberry:3, raspberry:3, mint:1 | charm +2, luck +1, 1440 | 14 d |
| `ginger-apple-cordial` | Ginger and Apple Cordial | R:77 | ginger:3, apple:2 | nimble +2, grit +1, 1440 | 14 d |
| `lemon-cordial` | Lemon Cordial | R:191 | lemon:4, mint:1 | sense +1, 1440 | 14 d |
| `lime-cordial` | Lime Cordial | R:192 | lime:4 | sense +1, 1440 | 14 d |
| `lemongrass-cordial` | Lemongrass Cordial | R:198 | lemongrass:3, ginger:1 | nimble +1, 1440 | 14 d |
| `rhubarb-cordial` | Rhubarb Cordial | R:189 | rhubarb:4, ginger:1 | nimble +1, 1440 | 14 d |
| `blackcurrant-cordial` | Blackcurrant Cordial | R:190 | blackcurrant:5 | hardiness +2, 1440 | 14 d |
| `cherry-cordial` | Cherry Cordial | R:193 | cherry:5 | charm +1, 1440 | 14 d |
| `cranberry-cordial` | Cranberry Cordial | R:194 | cranberry:5, orange:1 | hardiness +1, 1440 | 14 d |
| `lingonberry-cordial` | Lingonberry Cordial | R:195 | lingonberry:5 | hardiness +1, 1440 | 14 d |
| `sea-buckthorn-juice` | Sea Buckthorn Juice | R:197 | sea-buckthorn:5 | hardiness +2, 1440 | 14 d |
| `ginger-beer` | Ginger Beer | R:199 | ginger:3, sugarcane:1 | grit +1, 1080 | 7 d |
| `tamarind-drink` | Tamarind Drink | R:200 | tamarind:3 | sense +1, 1080 | 7 d |
| `apple-cider` | Apple Cider | R:207 | apple:6 | hardiness +1, 1440 | 14 d |
| `kvass` / `tepache` / `chicha` | Kvass / Tepache / Chicha | R:179 / 181 / 252 | rye+beet / pineapple+sugarcane / corn+quinoa | hardiness+1 / nimble+1 / grit+1 luck+1, 1080 | 5-7 d |

Not teas, listed for completeness: `pomegranate-molasses` R:204, `date-syrup` R:205, `cane-syrup` R:206 (syrups, no buff or lore +1).
Pantry drinks all sit on the "cordials" bottle shelf (`craft_scenes.php:16`, globs `*-cordial *-syrup *-juice *-drink *-concentrate *-cider`, `ginger-beer`, `kombucha`, `kvass`, `chicha`, `tepache`, `cold-brew-coffee`).
Energy in the Pantry rows is 4-6. `chai-blend` sits on the "Hanging cheese" shelf (`craft_scenes.php:15`) and is described "ready for the pot".

### 1c. Take-away teahouse drinks (runtime items, not in any data file)

- `town.php:12-28 TOWN_FLAVOUR`: 15 towns, each a teahouse spot `<town>-tea` and one drink.
- Spot action `<key>-drink` (`town.php:146-149`): 12 Petals, `daily` 2, effect `tbuff:<stat>:2:60`. Writes `users.town_*`. +2 one stat, 60 min.
- Item `teahouse-<town_key>` created on demand (`town.php:314-324 town_tea_item`): name "<Drink> (to go)", category food, rarity 5, base_price **4**, edible, tradable, `effects {"tea":"tbuff:<stat>:2:60"}`. Shelf button says "Drink" (`shelves.php:101`).

| town | teahouse | drink | stat |
|---|---|---|---|
| Mossbottom | The Mossy Mug | acorn coffee | charm |
| The Maplewold | The Lumberjack's Kettle | maple tea | hardiness |
| Maizehollow | Abuela Bee's Cafe | spiced hot chocolate | charm |
| The Sunsprinkle Isles | The Breezy Hut | coconut water | nimble |
| The Rainroot Reaches | The Yerba Gourd | mate | grit |
| Mistmoor | The Drizzle & Crumpet | pot of tea | lore |
| Olivewhistle Shore | Cafe Cicada | tiny espresso | nimble |
| Birchbramble Steppe | The Samovar | black tea with jam | hardiness |
| The Dunewhisper | The Mint Tent | sweet mint tea | charm |
| The Greatcanopy | The Baobab Bar | hibiscus tea | grit |
| Thornacre Savanna | The Rooibos Rest | rooibos tea | luck |
| Spicepeak | The Chai Stall | masala chai | sense |
| Blossomreach | The Bamboo Teahouse | bowl of matcha | lore |
| The Monsoon Tangle | The Kopi Corner | iced coffee | nimble |
| The Coralscatter | The Flat White | flat white | luck |

Other teahouse text: `npc_life.php:75-97` (shopkeepers visit the teahouse), `npc_life.php:272 teahouse_rumours`, `spot_card.php:57`, `here_view.php:421` (verb "Eat"), `data/gourmand.txt:7-15` (Pomeroy camps at 7 teahouses: `ca-tea`, `sa-tea`, `nwe-tea`, `ee-tea`, `wca-tea`, `esa-tea`), `tests/gourmand.php:202`.

### 1d. Other drink-like things (NOT food teas)

| slug | what | where | note |
|---|---|---|---|
| `sages-draught` | Alchemy potion, "A bitter blue tea" | `alchemy.php:21-22`; `data/crafts.txt:101` (chanterelle:1, bilberries:2, sphagnum:1); reward `data/trail_sight_quests_end.txt:37` | category supply, price 70, lore +4 sense +2, 120 min. Text says tea. Keep as a potion. |
| `lucky-draught`, `stoneskin-brew`, `swiftfoot-elixir` | potions | `alchemy.php:17-27` | 65-70 Petals, 90-120 min. Not teas. |
| `worm-tea`, `fern-tea` | soil amendments | `data/crafts.txt:41-42`; `nutrients.php:66,69,115,134-135`; `upgrade140.php:54`; `garden.php:595` | NOT drinks. Slugs end `-tea`: see risk R3. |
| `moss-tea` | random event, +10 energy | `data/events.txt:19` | Not an item. Old Moss. |
| `garden-honey` | honey, food | `seed.php:29`: temp luck+1 charm+1 180 min, energy 2 | sweetener candidate. Beehive makes it (`gardens.php:30`). |
| `wild-honeycomb` | pressed to honey | `data/stop_acts_waves.txt:149` | |
| Pal boons named after teas | text only | `data/puzzle_pal_boons.txt:30,42,58,152,318,177` (Peat Smoke Tea, Unasked-For Tea, Early Roast, Cocoa Dunk, Slow Steep, Wink and a Cup) | separate Puzzle Fight system, no item. |
| Decor / gear | `tea_tray` `data/catfish_pets.php:228`; `chai_stall_sign` `:233`; `tea-shrine` `yard.php:104` (art ph/tea-shrine); `ea-tea-chest` `data/wear_items.txt:172` | no tea effect. |

## 2. Table: tea-able ingredients that exist

Source `data/crops.txt` (crop, produce item = same slug unless noted), `data/flowers.txt`, `data/gatherables.txt`. Price (calc) from `catalog.php:179-184`.

| slug | name | type, file:line | grows / found | edible raw | price (calc) | used in tea/drink now |
|---|---|---|---|---|---|---|
| `tea` | Tea Leaves (item name from `catalog.php:104`) | crop, tree, tier 5, perennial. `crops.txt:150` | CSA (Spicepeak) **treasure** (`region_crops.txt:34`). Not in any shop. Seeds only from road swap `road_events.txt:712` (2 ginger) | **No** (`catalog.php:117 $notRaw`) | 56 | kombucha, iced-tea-conc., chai-blend; build plans `Tea Garden Slopes` (`build_plans.txt:223`, item:tea:9), `Cherry Blossom Teahouse` (:237, item:tea:6). Leaves via road events `road_events.txt:700` (20%), `:711` (swap 2 rice). One plant, no green/black/oolong split. |
| `mint` | Mint | herb, tier 2, perennial. `crops.txt:181` | **COMMON_CROPS** (`catalog.php:13`), sold as seed at hub | yes (sense +1, 120 min) | 11 | mint-tea, crowberry/elderberry/mixed-berry/lemon cordial, sea-grape sorbet (R:37). `ph/mint.png` |
| `rooibos` | Rooibos | herb, tier 4, perennial. `crops.txt:197` | ESA uncommon (`region_crops.txt:30`), seed in ESA shop; road swap `road_events.txt:1233-1234` | yes (not in notRaw) | ~41 | rooibos-concentrate only |
| `hibiscus` | Roselle (item "Roselle Calyces") | vegetable, tier 3. `crops.txt:78` | WCA uncommon | **No** (notRaw) | ~36 | hibiscus-cordial; stop act `r_wca_roselle_cordial` (`stop_acts_regional.txt:313`) |
| `ginger` | Ginger | spice, tier 4. `crops.txt:171` | CSA staple | yes | ~41 | chai-blend, ginger cordials/beer, many chutneys, pickled ginger, candied ginger. Road swap gives tea seeds for 2 ginger. |
| `cardamom` | Cardamom | spice, tier 5, perennial. `crops.txt:170` | CA treasure | No | high | chai-blend |
| `cinnamon` | Cinnamon | spice, tier 6. `crops.txt:167` | CSA treasure | No | high | chai-blend |
| `clove`, `nutmeg`, `black-pepper`, `vanilla`, `saffron`, `turmeric` | spices. `crops.txt:165-173` | treasures (turmeric CSA uncommon) | No | high | none in a drink |
| `lemongrass` | Lemongrass | herb, tier 3. `crops.txt:187` | SEA staple | yes | | lemongrass-cordial, curry paste |
| `yerba-mate` | Yerba Mate (leaves) | tree, tier 6. `crops.txt:151` | SA uncommon | No | | **nothing** (only a teahouse drink name) |
| `coffee` | Coffee (Cherries) | tree, tier 6. `crops.txt:149` | ESA treasure | No | | cold-brew-coffee |
| `cacao` | Cacao (Pods) | tree, tier 6. `crops.txt:148` | CA treasure | No | 59 | hot-cocoa, hazelnut spread, mole feast |
| `kola`, `kava`, `moringa`, `hops`, `ginseng` | tree/spice. `crops.txt` | various | | | | nothing |
| `sugarcane` | Sugarcane Stalks | grain, tier 5, perennial. `crops.txt:153` | CB treasure | yes | 56 | hot-cocoa, kombucha, ginger-beer, tepache, candied ginger |
| `thyme`, `rosemary`, `oregano`, `basil`, `dill`, `fennel`, `coriander`, `fenugreek`, `sorrel` | herbs. `crops.txt` | thyme, rosemary, basil, dill, fennel, coriander COMMON | yes | | | none in a drink |
| `lemon`, `orange`, `lime`, `finger-lime` | citrus trees | SE / CB staple | yes | | | cordials |
| `elderberry` | fruit, `crops.txt:195` | EE uncommon | yes | | | elderberry-cordial |
| `meadowsweet` | gatherable, forage grassland/wetland, common, 10, stat sense. `gatherables.txt:13` | edible | 10 | meadowsweet-tea; build plan `Thatchtop Tearoom` (`build_plans.txt:97` item:meadowsweet:5 + mint:5). Sights reward `trail_sights_maplewold.txt:10,12`. |
| `desert-sage` | gatherable, forage desert, common, 10, sense. `gatherables.txt:24` | edible | 10 | desert-sage-tea; stop act `r_mena_ember_sage` |
| `fiddleheads` | gatherable fern | | | fern-tea (soil only) |
| `garden-honey` | item. `seed.php:29`; beehive `gardens.php:30` | | 40 | recipes R:49,51,249; stop act `r_wca_roselle_cordial` takes it; road events give it |
| `goat-milk` | item (Clementine the goat, `animals120.php`) | | | cheese, porridge, `w5_watchers_cocoa` |

Flowers (item = `cut-<slug>`, category flower, **edible 0**; dried form `dried-<slug>` from the drying rack, `flowers.php:424-433`, **edible 0**):

| slug | name | line | note |
|---|---|---|---|
| `chamomile` | Chamomile | `flowers.txt:59` EE, tier 2 | blurb "make a calming tea". Seeds `ph/chamomile-seed`. Inedible item, so unusable in a recipe as food. |
| `lavender` | Lavender | `flowers.txt:66` SE | "dried lavender" is an order kind (`market100.php:112`); `data/companions.txt:10` |
| `bee-balm` | Bee Balm | `flowers.txt:94` NA | "once brewed as Oswego tea" |
| `dog-rose` | Dog Rose | `flowers.txt:134` EE | "gives rosehips"; no rosehip item |
| `osmanthus` / `camellia` / `chrysanthemum` | `flowers.txt:164` / `:158` / `:43` | EA | "used in tea" / "cousin of the tea plant" |
| `red-hibiscus`, `beach-hibiscus`, `torch-ginger`, `teuila`, `white-ginger-lily` | flowers | ornamental only | |

## 3. Where each tea appears in text/data (references that must keep working)

Slug references (grep over `game/`, `claude/`, `tests/`):

| slug | gives it / needs it | file:line |
|---|---|---|
| `mint-tea` | Sight reward 20% `forest-the-hollow-oak` "Pour tea" | `data/trail_sights_shared.txt:28` |
| `mint-tea` | Sight reward 15% `end-haven-1-coast` | `data/trail_sights_end.txt:11` |
| `mint-tea` | villager gift 50% Alder Barleycorn | `data/trail_sight_folk_end.txt:8` |
| `mint-tea` | **Build plan feeds (need N in satchel)**: Spice Souk x6 | `data/build_plans.txt:157` |
| | Floating Flower Market x5 | `:216` |
| | Tea Garden Slopes step 4 x5 | `:225` |
| | Cherry Blossom Teahouse step 4 x4 | `:238` |
| `mint-tea` | stop act buy (8 Petals each, +2 en) `herb_tea` | `data/stop_acts.txt:36` |
| `mint-tea` | stop act craft mint:2 > mint-tea `r_mena_high_pour` | `data/stop_acts_regional.txt:277` |
| `mint-tea` | test | `tests/cook.sh:48,51,121,161-164`; `tests/pantry.php:178` (cook event) |
| `meadowsweet-tea` | stop act craft `w1_meadowsweet_tea` | `data/stop_acts_waves.txt:35` |
| `meadowsweet-tea` | idea only `316-kettletree` swap | `claude/sights/ideas-maplewold.md:406` |
| `desert-sage-tea` | **Build plan feed x4** The Oasis That Moves | `data/build_plans.txt:169` (older copy `claude/build-plans-base.txt:166` has x3) |
| `desert-sage-tea` | stop act craft `r_mena_ember_sage` | `data/stop_acts_regional.txt:274` |
| `hot-cocoa` | **Build plan feeds**: Market of a Thousand Chilies x3 | `data/build_plans.txt:17` |
| | Thousand Rings Stump x2 | `:61` |
| `hot-cocoa` | Sight rewards: `mountain-the-stone-hut` 15% winter | `data/trail_sights_shared.txt:54` |
| | `309-snowmen` 5% winter | `data/trail_sights_maplewold.txt:62` |
| | folk Rook Dewdrop | `data/trail_sight_folk_shared.txt:45` |
| | folk Ferrin Pennywhistle | `data/trail_sight_folk_end.txt:10` |
| | `tundra-the-snow-fort` Dilly Lanternby (text asks for cocoa) | `data/trail_sight_folk_shared.txt:86` |
| `hot-cocoa` | road event reward 20% | `data/road_events.txt:461` |
| `hot-cocoa` | stop acts `ca_cocoa_grind` (cacao:2 > cocoa) / `w5_watchers_cocoa` (cacao:2 + goat-milk:1) | `data/stop_acts_regional.txt:18`; `data/stop_acts_waves.txt:228` |
| `crowberry-cordial` | Sight reward 5% `316-kettletree` "Brew" | `data/trail_sights_maplewold.txt:118` |
| | stop act `r_na_crowberry_cordial` | `data/stop_acts_regional.txt:35` |
| `elderberry-cordial` | stop act `r_ee_elder_cordial` | `data/stop_acts_regional.txt:239` |
| | Gourmand jar ask | `data/gourmand.txt:69` |
| `mixed-berry-cordial` | stop act `r_wca_roselle_cordial` (hibiscus:3 + garden-honey:1, wrong recipe but real output) | `data/stop_acts_regional.txt:313` |
| `ginger-apple-cordial` | stop act `w4_ginger_cordial` | `data/stop_acts_waves.txt:192` |
| `cold-brew-coffee` | folk Mabel Burrowby gift | `data/trail_sight_folk_end.txt:31` |
| `rooibos-concentrate`, `hibiscus-cordial`, `lime-cordial`, `blackcurrant-cordial`, `lemon-cordial`, `lemongrass-cordial` | **Gourmand "jar" asks** (Pomeroy) | `data/gourmand.txt:60,64,66,69,73,75,80`; `tests/gourmand.php:151` |
| `sages-draught` | quest reward Book of Hushes; `pal_jobs.php:193`; `tests/alchemy.php:130` | `data/trail_sight_quests_end.txt:37` |
| `tea` (leaf) / `tea-seed` | build plans, road events | `build_plans.txt:223,237`; `road_events.txt:700,711,712` |
| `rooibos` / `rooibos-seed` | road swaps | `road_events.txt:1233,1234` |

Quests that only mention tea in prose (no slug): `data/trail_sight_quests_shared.txt:38` (`picnic-for-everyone` beat "Pour tea and borrow six acorn teacups"), `data/trail_sight_quests_maplewold.txt:37` (`owl-letter` beat "Brew tea for the raven's directions", `316-kettletree`), `data/stop_threads.txt:9`, `journey.php:510-577` (Spicepeak "Tea Terraces" building, tea-leaf letter), `data/road_events.txt:710`.
`claude/sights/ideas-shared-land.md:154` and `ideas-maplewold.md:406-407` are design ideas that mention "Oak Tea" and a swap `meadowsweet` -> `meadowsweet-tea`. No item `oak-tea` exists.

Almanac / glossary / site text that mention teas (these state the snack rules and would become wrong):
- `almanac_pages.php:33` "Snacks (teas, jams, toasts, salads) cook in minutes and cost no energy."
- `almanac_notes.php:196` "Snacks (teas, toasts, salads) cook in minutes and cost no energy."
- `glossary.php:17` "Snacks (teas, jams, toasts) are quick and cost no energy to cook."
- `site_text.php:51` guide.cooking (check wording).
- `update_news.php:29,320,515` (history, leave alone).
Almanac recipe pages for every tea are generated by `ensure_crafts` / `pantry.php:282` from `recipes.txt` (no hand-written tea pages).
NPC dialogue "kettle/tea" lines (flavour only): `letters.php:61,67`, `friends.php:121`, `data/stop_chat.txt:67`, `catfish_pets.php:57,83-86,98-103,126-132`, `data/village_blurbs.txt:39`, `data/village_quirks.txt:13`.

Art that exists: `assets/img/ph/` mint-tea, meadowsweet-tea, desert-sage-tea, hot-cocoa, crowberry-cordial, kombucha, iced-tea-concentrate, chai-blend, rooibos-concentrate, cold-brew-coffee, ginger-beer, worm-tea, fern-tea, tea, tea-seed, mint, chamomile-seed, lavender-seed, plus `ico/ico-tea` and `ico/ico-cup`. **No art for kettle, teapot, teacup, tea tin.** Icon routing by name word: `items.php:274` (`tea`, `cordial`, `cocoa`, `coffee`), `data/ico_map.php:875-878` (tea cup and teapot emoji -> `ico-tea`).

## 4. What is MISSING for a real tea system

Nothing in the repo is a kettle, cup, tea tin or brew action.

Hardware / UI:
1. Kettle item(s) with tiers. Closest pattern: tool tiers Worn/Sturdy/Fine (`tool_tier()`, `tools.php`), or Kitchen building `buff_pct` (`gardens.php user_building_bonus`).
2. A place in the Hovel for it: new decor slot in `hovel_decor.json` (`user_hovel_decor`) or a Hovel tab. `hovel.php` is only a redirect shell when slim home is on (`hovel.php:31`), so the real UI is `gnome.php`.
3. A brew action and UI (pick up to 4 components, preview strength).
4. Cup / teapot / tin icons and art. Only `ico-tea` and `ico-cup` exist.
5. Storage for the day buff (see section 6). None of the 4 buff stores supports multi-stat + "ends at sleep" + not clobbered.

Ingredients a real recipe needs and the game lacks:

| real tea / blend | needs | status |
|---|---|---|
| green / black / oolong / white | tea leaf in processed grades | **only one `tea` item**, inedible, treasure-only in CSA, no shop. No withering/oxidising, no grades. |
| English breakfast | black tea, milk, sugar | tea, `goat-milk`, `sugarcane`: exist. Tea access is the blocker. |
| Masala chai | tea, cardamom, cinnamon, ginger (+ clove, black pepper, milk) | all exist, 4 = cap. `chai-blend` R:234 is exactly this. Cardamom/cinnamon are treasures (rare). |
| Moroccan mint | gunpowder green tea, mint, sugar | exist. |
| Peppermint / spearmint | mint | one `mint` only. No peppermint vs spearmint. |
| Chamomile | chamomile flowers | plant exists, but item is inedible `cut-chamomile`/`dried-chamomile`. No edible herb item. |
| Lavender, bee balm, chrysanthemum, osmanthus | flowers | same: inedible cut/dried items. |
| Rosehip | dog rose hips | `dog-rose` flower only, no hip item. |
| Elderflower | elder blossom | **missing** (only `elderberry` fruit). |
| Lemon balm | herb | **missing**. |
| Nettle | herb | **missing** (only names). |
| Licorice root | root | **missing**. |
| Jasmine | flower | **missing** (not in `flowers.txt`). |
| Star anise, fennel seed | spice | `fennel` is a vegetable crop only; no star anise. |
| Garden sage | herb | only `desert-sage` gatherable. |
| Tulsi / holy basil | basil | `basil` description mentions it, one item. |
| Hibiscus (sorrel/bissap) | calyces | exist but inedible (`$notRaw`), only used in a cordial. Needs ginger, clove, sugar: exist. |
| Rooibos (+ vanilla, orange, cinnamon) | all exist | rooibos only in ESA shop. |
| Yerba mate, kava, moringa, kola | leaves/root | crops exist, used nowhere. |
| Coffee, cocoa | beans | exist (treasures), not tea. |
| Honey / sugar | sweeteners | `garden-honey`, `wild-honeycomb`, `sugarcane`, `cane-syrup`, `date-syrup` exist. |
| Dried herbs | herb drying | drying rack is flowers only (`flowers.php:424`, `dry_racks`). No dried herb items. |

Access gaps: `tea`, `cinnamon`, `cardamom`, `coffee`, `cacao` are treasures with no shop seed; a tea system that needs them daily will starve most players. Common herbs (mint, thyme, rosemary, basil, fennel, lemongrass, ginger) are the realistic daily base.
`mint` is edible raw and COMMON, so the entry tier of "herbal" teas is already free.

## 5. MIGRATION plan

Principles
- Keep every existing slug alive as an **item**. Items hold satchel copies, `user_tasted`, food mastery (`food_mastery.php`), Gourmand asks, build plans, Sight rewards, tests and art. Deleting a slug breaks `trail_sights_lint` (unknown item), `build_plans.txt`, `tests/*`.
- Keep recipe **rows** (do not delete) so `user_recipes` (learned_at, `made` mastery) and `pal_jobs.php:796/938` stay valid. Hide or re-route them, do not drop them.
- Ship through one idempotent upgrade function (pattern `upgrade_094_cooking`), not by editing `recipes.txt` alone (existing installs never re-import).
- The new system needs a rule for items handed in (build plans, orders, jobs). A cup "cannot be saved", so those need an item that can be held. See decision D1.

Decisions for the owner (flag, not guessed)
- **D1.** Build plans `feed` steps ask for `item:mint-tea:N` / `desert-sage-tea:N` / `hot-cocoa:N` (5 plans, 9 lines). If brewed cups cannot be held, either (a) change those steps to herbs (`item:mint:N`, `item:desert-sage:N`) and keep cocoa as a cooked snack, or (b) keep the three slugs as non-buff "tea tin" trade goods. Recommend (a) for mint/sage, hot-cocoa stays.
- **D2.** Hot cocoa and coffee are not tea. Recommend: `hot-cocoa` stays a cooking snack (it is a Maizehollow/Stove dish with 6 refs and `cacao` is a treasure). Cacao/coffee can still be kettle components later.
- **D3.** Do Pantry drinks (kombucha, cordials, concentrates) stay stored? They are the "bottled for later" fit. Recommend yes: leave all 25 Pantry drinks as they are (they are jars with real-time days, gifts, orders, Gourmand), except the 3 tea-leaf ones below.

Per-item plan

| existing | action | blend / components (cap 4) | existing owned copies | recipe unlock |
|---|---|---|---|---|
| `mint-tea` | **Keep as named recipe-tea "Mint Tea"** | mint, mint (herbal base). Real: peppermint infusion. Variant "Moroccan Mint" = tea, mint, mint, sugarcane (new, needs leaf) | slug stays a legacy item. Drinking a held copy gives the new day buff at the tea tier-1 strength (sense +1). Optional upgrade step: leave them be. | keep `recipes` row (R:11); new kettle recipe reuses ingredients `mint`, so anyone who "saw" mint already knows it. Set old cooking recipe hidden (`craft_recipes` filter pattern like `pfd_gear_slug`, `crafting.php:119`). |
| `meadowsweet-tea` | **Keep as named recipe-tea** "Meadowsweet Infusion" | meadowsweet, meadowsweet, (optional garden-honey). Real: meadowsweet for aches, hardiness | as above | same |
| `desert-sage-tea` | **Keep as named recipe-tea** "Sage Tea" | desert-sage, desert-sage, (optional garden-honey). Real: sage tea for memory, lore | as above. Build plan x4 needs a change (D1) | same |
| `chai-blend` (Pantry, R:234) | **Becomes named recipe-tea "Masala Chai"** | tea, cardamom, cinnamon, ginger. Matches Spicepeak teahouse "masala chai". | Held jars stay as a premixed item: let it count as ONE component slot "chai spice" so nothing is wasted, or stay a stored drink. Stop new Pantry crafting only after D3 is decided. | `user_recipes` row stays (pantry). Cardamom/cinnamon are treasures: rare. |
| `kombucha` | **Keep in Pantry** (it is a ferment, takes 7 real days) | not a kettle blend | untouched | untouched |
| `iced-tea-concentrate` | **Merge into kettle "Black Tea"** (strong tea, no extras). Hide Pantry recipe once D3 chosen | tea, tea | stay drinkable as legacy | keep row |
| `rooibos-concentrate` | **Merge into kettle "Rooibos"** (herbal, caffeine-free) | rooibos, rooibos (+ vanilla/orange optional) | stay. **Gourmand `esa` jar ask uses it** (`gourmand.txt:75`): keep slug valid | keep row |
| `hibiscus-cordial` | Keep in Pantry. Add kettle tea "Roselle/Sorrel" later | hibiscus, ginger, clove, sugarcane (all exist; hibiscus inedible flag must be lifted for kettle use) | untouched. Gourmand ask `:73` stays | untouched |
| `hot-cocoa` | **Keep** as cooking snack (D2) | cacao, sugarcane (unchanged) | untouched | untouched |
| `cold-brew-coffee` + coffee | Keep in Pantry. Coffee a possible kettle component later | | untouched | untouched |
| `crowberry-cordial` (snack, R:38) | **Retire from cooking, keep slug** or move to Pantry. It is a "cordial" cooked in 3 minutes, off pattern. Merge idea: kettle "Crowberry Mint" = crowberries, mint | crowberries, mint | stay as drinkable legacy. Sight `316-kettletree` 5% reward and stop act `r_na_crowberry_cordial` keep working | keep row |
| 20 other cordials/juices/beers | Keep in Pantry untouched | | | |
| `sages-draught` | Keep as alchemy potion. Change description wording "tea" if desired | | | |
| `worm-tea`, `fern-tea` | Untouched (soil). Keep names; see R3 | | | |
| 15 `teahouse-<town>` flasks | **Convert**: the teahouse sells one cup "drink here", no take-away item. Each town drink = named blend using that town's local ingredients | table below | existing flasks stay drinkable (legacy `effects.tea`) until spent. Stop creating new ones (`town_tea_item`) | n/a |
| `moss-tea` event | Leave. Not an item. | | | |

Teahouse mapping (suggested components, all exist unless marked): pot of tea / mate / maple tea need a stand-in (no maple item).
- pot of tea (Mistmoor): tea, goat-milk, sugarcane. mate (Rainroot): yerba-mate. black tea with jam (Steppe): tea + jam item.
- sweet mint tea (Dunewhisper): tea, mint, mint, sugarcane. hibiscus tea (Greatcanopy): hibiscus, ginger, sugarcane.
- rooibos tea (Thornacre): rooibos, vanilla or orange. masala chai (Spicepeak): tea, cardamom, cinnamon, ginger.
- matcha (Blossomreach): tea (needs a green-tea grade, MISSING). Coffee drinks (Mossbottom, Olivewhistle, Monsoon Tangle, Coralscatter): coffee, goat-milk. These are not tea; leave as teahouse coffee, no kettle.
- spiced hot chocolate (Maizehollow): cacao, chili-pepper, cinnamon, sugarcane. coconut water (Isles): coconut.

Existing owned items (satchel): no deletion. Add a legacy handler: any `food` item with a drinkable tea slug keeps `eat_item` behaviour but its `temp` is rewritten once, in an upgrade, to the day-buff form (section 6). Alternative (cleaner, recommended for the 3 herb teas): on upgrade swap each held `mint-tea`/`meadowsweet-tea`/`desert-sage-tea` into its ingredients (x2) via `give_item`, so players brew them fresh in the kettle. Do NOT do this for items listed in D1 if a build plan is mid-way.
Recipe unlocks: leave all `user_recipes` rows. If a recipe is hidden from Cooking, move its `made` count into the new tea recipe on upgrade (`UPDATE user_recipes` by slug mapping) so mastery is not lost.
New kettle recipes unlock by the same rule: all ingredient slugs "seen" (`crafting.php:146`), so a player who has ever seen mint, tea, ginger etc. knows them at once.
Orders: `orders_pools()` takes only `tier in (meal, preserve)`; snack teas are already absent. Preserve pool: if a Pantry drink is hidden, filter it out of `orders_pools()` (line 421-423) or a "jar of kombucha" order could ask for something a player can no longer make.
Jobs: `jobs.php:126` `deliver_dish`/`cook` use `category = 'cooking'` known recipes. Hide retired tea rows there too, or snack cook jobs ask for "Mint Tea" that is gone.
Sights: reward `item=mint-tea:1@N` still resolves while the slug exists. If teas become un-holdable, change the 3 mint-tea rewards (`trail_sights_shared.txt:28`, `trail_sights_end.txt:11`, `trail_sight_folk_end.txt:8`) to `item=mint:1` or to `buff=sense:1:sleep` (token exists, `GRAMMAR.md:59`). Same for `hot-cocoa` only if D2 changes. Re-run `tests/trail_sights_lint.sh`.
Quests: tea-only quest beats have no item requirements (`picnic-for-everyone`, `owl-letter`), so prose stays valid. `316-kettletree` "Brew" and `forest-the-hollow-oak` "Pour tea" are natural hooks to the new system.
Gourmand: jar asks for `rooibos-concentrate`, `hibiscus-cordial`, `lime-cordial`, etc. keep working only if the slugs and Pantry recipes stay. Do not retire those (D3).

## 6. Adjustments so each tea fits "small buff, whole day, cannot be saved"

Today vs target

| thing | today | needed |
|---|---|---|
| duration | meal buff: real minutes (120-1440). Teahouse: 60 min | until next sleep = `game_day` rule. Only `ev_*` has it (`ev_day`, `gnome_ev_slept`, `gnome.php:194`). Without `gclock_on()` falls back to 60 min. |
| storage | all teas are stored satchel items, tradable, sellable, giftable | brewed cup is consumed on brew. No item created. |
| stats | meal buff JSON supports several stats; `ev_*` and `town_*` hold ONE stat | blends up to 4 components need >1 stat. Recommend a new column pair (`users.tea` JSON + `users.tea_day` INT) read in `eff_stat()`, `active_effects()`, `active_buff()`, with the same slept check. Avoids clobbering by Sight `buff=` (slot 1) and `buff2=` (slot 2). |
| strength | mint +2, sage +2, cocoa +3/+1, concentrates +1; teahouse +2 | "small": +1 or +2 total. Day-long is 8-16x longer than 120 min, so use the low end. Kettle tier scales it. |
| multipliers | `buff_minutes()` scales by perks, Foodie rank, kitchen | decide whether day-long ignores them (recommend yes: duration is fixed, only strength scales). |
| energy | mint-tea 4 (x1.15), sage/meadowsweet 2, cocoa 6, Pantry drinks 4-6, teahouse 0 | decide: kettle gives no energy (recommended: "buff only"), or 0-1. This is a nerf for the three herb teas that now give 2-5 energy for 0 energy cost: flag to the owner. |
| sell value | mint-tea ~31, meadowsweet ~28, sage ~28, cocoa ~244, teahouse flask 4, Pantry drinks 20+ (kombucha etc.) | brewed cups have no sell value (not an item). Legacy copies keep their price. |
| energy full | a pure-energy drink is refused at full (`gnome.php:445`) | n/a for kettle |
| cooking cost | snack: 0 energy, 3 min | kettle: define energy/time cost. Game clock actions spend game minutes (`almanac_pages.php:12`). |

Text that says otherwise and must change (word "teas" under snacks, "cook", "stored", "an hour"):
- `almanac_pages.php:33`, `almanac_notes.php:196`, `glossary.php:17`, `site_text.php:51`: remove "teas" from the snack list.
- `town.php:322` item description "+2 for an hour"; `town.php:146-148` action label/effect; `spot_card.php:57`.
- `data/stop_acts.txt:36` `herb_tea` ("Herbal tea tasting", buys a stored `mint-tea` for 8 Petals, +2 energy): retarget to a day buff or an ingredient.
- `data/recipes.txt:5` header comment: "A recipe is discovered once you've harvested all its ingredients" still true; add a note that tea rows moved.
- `data/craft_scenes.php:9,28,31` globs `*-tea` (stove / watering can / seed trays): new tea recipe slugs must not end in `-tea` unless these are updated (R3).
- `alchemy.php:22` Sage's Draught "A bitter blue tea" (optional rewording).
- `claude/sights/GRAMMAR.md` if a `tea=` token is added; else no change (`buff=...:sleep` already documented).

## 7. Risks and the exact file list

Risks
- **R1. Build plans can deadlock.** 9 plan steps need a held `mint-tea` / `desert-sage-tea` / `hot-cocoa` (`build_plans.txt:17,61,157,169,216,225,238`). Un-holdable cups would block Spice Souk, The Oasis That Moves, Floating Flower Market, Tea Garden Slopes, Cherry Blossom Teahouse. Fix first (D1). `claude/build-plans-base.txt` and `claude/build-plans-review.md` are older copies with different counts.
- **R2. Tea access.** `tea` (and cinnamon, cardamom, coffee) are CSA/CA/ESA treasures with no shop seed. A day-buff system that depends on them gives most players one herb or nothing. Decide which items need a shop or a common source before launch.
- **R3. `-tea` slug collisions.** `worm-tea` / `fern-tea` are soil items, and `craft_scenes.php` already maps `*-tea` to three different stations. `nutrients.php:134-135` and `garden.php:595` match on those names.
- **R4. Edits to `recipes.txt` do not reach live installs.** `catalog.php:579` skips existing slugs. Needs an upgrade function, run once, guarded by a setting.
- **R5. Mastery and Foodie.** `user_recipes.made`, `user_tasted`, `food_mastery_add` (`gnome.php:458`) count eating; calling quests count `job_event('eat'|'cook')` (`tests/calling.php:172`, `jobs.php`). A kettle brew that bypasses `eat_item` silently stops feeding Foodie rank, mastery and "cook N snacks" tasks. Decide whether brewing fires `job_event('cook','tea')`.
- **R6. Slots.** A new buff column is safest; reusing `ev_*` means any Sight `buff=` or random event replaces your tea.
- **R7. Sleep clock off.** `:sleep` scope needs `gclock_on()`; without it durations fall back to 60 min.
- **R8. Gourmand and orders.** `gourmand.txt` jar asks and the preserve order pool depend on Pantry drink slugs. Do not retire those without editing both.
- **R9. Flowers/herbs are inedible items.** Chamomile, lavender, hibiscus, hips need an "edible/brewable" flag or new items. `catalog.php:117` `$notRaw` and flower `edible=0` (`catalog.php:197`, `flowers.php:431`) are the gate.
- **R10. Art.** No art for kettle, cup, tin, new herbs (lemon balm, nettle, elderflower, rosehip, licorice, jasmine). New slugs need 64x64 art under `assets/img/ph/` (art is made by someone else, list slugs in `claude/todo` per `GRAMMAR.md:37`).
- **R11. Drift between data copies:** `claude/drafts/item_slugs.txt:304,344` list tea slugs.

Files a migration would touch (all paths under `game/` unless noted)

Core logic
- `includes/gnome.php` (`eat_item`, `buff_minutes`, `eff_stat`, `active_effects`, `active_buff`, new brew function; `gnome_ev_slept`)
- `includes/schema.php` (new `users` columns near 1475-1482 and 1541; kettle tier storage)
- `includes/events.php` (`apply_event_effect`: only if a new effect token is added; `tbuff` at 211)
- `includes/town.php` (`TOWN_FLAVOUR` 12-28, drink action 146-149, `town_tea_item` 314-324)
- `includes/shelves.php:101` (Drink verb), `includes/spot_card.php:57`
- `includes/catalog.php` (`import_recipes` 561, `OLD_DISH_ENERGY` 667, `$notRaw` 117, `$produceNames` 103; new `upgrade_*` function)
- `includes/crafting.php` (recipe listing filter, discovery 109-160, a kettle category)
- `includes/pantry.php`, `includes/pantry_view.php` (only if Pantry teas are hidden)
- `includes/jobs.php:126`, `includes/market100.php:414-430` (pools)
- `includes/bootstrap.php` (register upgrade)
- `includes/gardens.php` (kettle tier if modelled as a building bonus) or `includes/tools.php` (if modelled as a tool)
- `includes/home_slim.php`, `includes/data/hovel_decor.json` (kettle slot), `includes/today.php` (show the day buff)
- `gnome.php` page / `hovel.php` (UI)
- Crop and herb data: `includes/data/crops.txt`, `includes/data/region_crops.txt`, `includes/data/crop_seasons.txt`, `includes/data/gatherables.txt`, `includes/data/flowers.txt`, `includes/data/flower_looks.txt` (new herbs / edible flags)

Data and text
- `includes/data/recipes.txt` (R:11,23,30,31,38,75-77,180,196-203,234 and new tea rows or a new `teas.txt`)
- `includes/data/build_plans.txt` (17, 61, 157, 169, 216, 225, 238) and `claude/build-plans-base.txt:166`
- `includes/data/craft_scenes.php` (9, 15, 16, 28, 31 globs)
- `includes/data/stop_acts.txt:36`; `stop_acts_regional.txt:18,35,239,274,277,313`; `stop_acts_waves.txt:35,192,228`
- `includes/data/trail_sights_shared.txt:28,54`; `trail_sights_end.txt:11`; `trail_sights_maplewold.txt:62,118`; `trail_sight_folk_end.txt:8,10,31`; `trail_sight_folk_shared.txt:24,45,86`
- `includes/data/road_events.txt:461,700,711,712,1233,1234`
- `includes/data/gourmand.txt:60,64,66,69,73,75,80` (only if a jar drink slug changes)
- `includes/data/events.txt:19` (`moss-tea`, optional)
- `includes/almanac_pages.php:33`, `includes/almanac_notes.php:196`, `includes/glossary.php:17`, `includes/site_text.php:51`
- `includes/data/ico_map.php`, `includes/items.php:274` (icons)
- `assets/img/ph/*` new art; `claude/sights/GRAMMAR.md` (if a token is added); `claude/drafts/item_slugs.txt` (optional)

Tests to update or add
- `tests/cook.sh` (48, 51, 121, 161-164), `tests/pantry.php:178`, `tests/pantry.sh:43`, `tests/calling.php:172`, `tests/alchemy.php:130`, `tests/gourmand.php:151`, `tests/market100.php:248`, `tests/trail_sights_lint.sh`, `tests/craft_tags.php` (reads `craft_scenes.php` + `recipes.txt`)
