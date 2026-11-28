# Proposal: the seed ladder (14 seeds in Mossbottom, 5 in the Maplewold, more as things mend)

Status: PROPOSAL ONLY, nothing wired in. Written 2026-11-28. Numbers from a fresh SQLite install of branch `ccr-45ffe12f-9cokuo`.
Builds on `proposal-town-states.md` (region repair number R, town states, back room). Seeds only: tools, soil, mulch, the guide, florists and pet shops are not touched.

**Verdict.** Doable, and safe for the story, with three rules: (1) every seed the story names is on the shelf from the first visit, (2) a gate is per gnome and only hides a row, the shared shelf is not changed, (3) every gate has a garden way and a road way to open, and latches for good.

## 1. Category map

394 seed items = 394 `plants` rows. There are 11 kinds (`plants.kind`). No mushroom, vine or water-plant kind exists (mushrooms are forage).

| Group (`plant_regions.tier`) | Seeds | Sold today | Base price | Grow min | Soil 0 / 25 / 40 | All-season | Perennial |
|---|---|---|---|---|---|---|---|
| Everyday (`plants.common`) | 36 | Twigg's, Mossbottom (all 36) | 10-48 | 5-20 | 19 / 17 / 0 | 16 | 8 |
| Staple | 51 (3-4 a region) | own region town | 38-109 | 10-60 | 9 / 33 / 9 | 14 | 9 |
| Uncommon | 74 (4-8 a region) | own region town | 45-109 | 30-180 | 7 / 14 / 53 | 37 | 59 |
| Flower | 168 (12 a region) | own region town | 32-105 | 10-120 | 22 / 95 / 51 | 26 | 149 |
| Treasure | 42 (3 a region) | nowhere: rewards (errands, jobs, Village Show, landmarks) | 100-121 | 120-360 | 0 / 1 / 41 | 25 | 42 |
| Hybrids + Lanternroot | 23 | nowhere: breeding, treks | 29-182 | 7-230 | 1 / 10 / 12 | 9 | 15 |

| Kind | Everyday | Staple | Uncommon | Treasure | Flower | Hybrid | All |
|---|---|---|---|---|---|---|---|
| vegetable | 18 | 14 | 11 | | | 4 | 47 |
| herb | 10 | 3 | 5 | | | | 18 |
| legume | 2 | 11 | 1 | | | | 14 |
| grain | 1 | 11 | 3 | 1 | | 2 | 18 |
| tuber | 1 | 4 | | | | 1 | 6 |
| fruit | 1 | 2 | 14 | 5 | | 2 | 24 |
| cover | 3 | | | | | | 3 |
| tree | | 4 | 37 | 14 | | 8 | 63 |
| spice | | 2 | 3 | 11 | | | 16 |
| nut | | | | 11 | | 1 | 12 |
| flower | | | | | 168 | 5 | 173 |

Shops: Twigg's = 114 rows (36 seeds, 58 tools, 10 supplies, 6 soil, 3 mulch, 1 produce), restock every 20 min, seeds 90% / max 20. 14 region seed shops = 293 seed rows + 14 guides (19-24 seeds each), restock 30 min. One shelf for all gnomes. Shops never buy seeds (`sell_to_shop()`).

What the story needs (the "must always be obtainable" set):

| Need | Where asked | Seeds | Kept safe by |
|---|---|---|---|
| Any 1 harvest | First Week day 1 | radish (6 in the starter kit) | Start 14 |
| Any 1 cooked dish | First Week day 4; Repair stages `meal:N` | mint (mint tea), tomato + carrot + onion (soup), sunflower, pea, radish + dill | Start 14: 5 dishes cookable from it alone |
| Decor, a Journey stage | First Week day 7 | none (flint, planks, rope are forage and crafts) | not seeds |
| 2 staples of the area | `grow staple 2`, first step in all 14 areas (v1 and v2) | NA oats, lentil. Others: the 2-3 the step names | Wren's five (section 2) |
| Signature crop, 3 then Seed Bed x3 | `plant crop:` / `bed:1-3`, all areas, and `the-last-page` | wild-rice, amaranth, barley, breadfruit, olive, yerba-mate, buckwheat or plum, date, turmeric or ginger, fonio, teff, persimmon, rice, taro | Wren's five |
| M2 bake day | `maplewold-m2` `plant crop:apple/hops:3` | apple (or hops) | Wren's five (apple) |
| Native flower | `plant flower:` all areas; 6 errands (cut flowers) | goldenrod, marigold, heather, frangipani, lavender, passionflower, chamomile, damask-rose, sacred-lotus, wild-gardenia, king-protea, sakura, sampaguita, tiare | Wren's five |
| Errand crops | `ca-s05`, `ca-s08` (side errands) | corn, black-bean, tomatillo (in the five), **chayote** (not) | Step tie (section 4) |
| Treasure seeds | 7 errand extras `seed=` | blueberry, cranberry, vanilla, hazelnut, nutmeg, quince, coffee | Given, never bought |
| Job Board crop | `job_context()` | only crops whose seed or crop the gnome holds | Already safe |
| Village Show crop of the week | First Week day 6 (one of two ways) | 10 everyday crops, 7 in the start 14; cabbage, green-bean, beet are not | This week's show seed is always open |

## 2. Start state

A new gnome also holds: radish 6, lettuce 4, carrot 4, tomato 2 (`starter_items`), 2 each of oats, lentil, kidney-bean, soybean, and 1 coneflower, 1 black-eyed-susan (`home_seed_list()`). Unchanged.

**Mossbottom, Twigg's: 14 of 36.**

| # | Seed | Kind | Min | Soil | Season | Why |
|---|---|---|---|---|---|---|
| 1 | radish | vegetable | 5 | 0 | all | First Week day 1. Quickest crop. In the kit |
| 2 | lettuce | vegetable | 5 | 0 | spring, autumn | In the kit. Second quick one |
| 3 | carrot | vegetable | 7 | 0 | all | In the kit. Soup. 9 recipes |
| 4 | tomato | vegetable | 12 | 25 | spring, summer | In the kit. Soup. 11 recipes. First "needs decent soil" crop |
| 5 | onion | vegetable | 12 | 25 | all | Third soup part (not in the kit). 30 recipes, the most used crop |
| 6 | potato | tuber | 12 | 25 | all | Only everyday tuber. 11 recipes |
| 7 | pea | legume | 7 | 0 | spring, autumn | A legume. Pea soup with onion |
| 8 | mint | herb, perennial | 7 | 0 | all | Mint tea = one-crop dish: First Week day 4 can never stall. First perennial |
| 9 | basil | herb | 7 | 0 | summer, autumn | Summer herb |
| 10 | dill | herb | 7 | 0 | spring to autumn | 11 recipes. Pickled radishes |
| 11 | strawberry | fruit, perennial | 12 | 25 | spring, summer | Only everyday fruit |
| 12 | sunflower | grain | 12 | 25 | summer, autumn | Only everyday grain. One-crop snack |
| 13 | white-clover | cover | 7 | 0 | all | Soil care from day 1 |
| 14 | pumpkin | vegetable | 20 | 25 | summer, autumn | The long one. Show crop. Carving |

Spread: 7 kinds, 5 to 20 min, 8 on any soil, 6 never off season, 2 perennials, 9 to 45 Petals. Off season never blocks planting (slower only).

**The Maplewold, Maple & Furrow: 5 of 20 = "Wren's five".** All seven Maplewold chapters can be played with these five and no unlock.

| # | Seed | Kind | Min | Soil | Why |
|---|---|---|---|---|---|
| 1 | oats | grain, staple | 30 | 25 | M1 and old chapter 1 `grow staple 2`. Apple crumble |
| 2 | lentil | legume, staple | 15 | 25 | Same step, the quick one |
| 3 | wild-rice | grain, uncommon | 45 | 25 | Signature crop: M4, M5, M6 Seed Bed, M7 supper |
| 4 | apple | tree, uncommon | 180 | 40 | M2 bake day, M7 apple dish, Standing "grown" row. The long goal |
| 5 | goldenrod | flower | 15 | 25 | M3, errand `na-s09` |

**The other 13 towns: same rule, 5 each** (named staples + signature crop + native flower, filled with the cheapest staple left, else the cheapest uncommon):

| Town | Wren's five |
|---|---|
| Maizehollow | corn, black-bean, tomatillo, amaranth, marigold |
| Mistmoor | rye, leek, barley, brussels-sprouts, heather |
| Sunsprinkle | sweet-potato, plantain, pigeon-pea, breadfruit, frangipani |
| Rainroot | cassava, peanut, quinoa, yerba-mate, passionflower |
| Olivewhistle | artichoke, fava-bean, oregano, olive, lavender |
| Birchbramble | buckwheat, plum, bell-pepper, sorrel, chamomile |
| Dunewhisper | chickpea, eggplant, cumin, date, damask-rose |
| Spicepeak | wheat, mung-bean, ginger, turmeric, sacred-lotus |
| Greatcanopy | yam, okra, millet, fonio, wild-gardenia |
| Thornacre | teff, sorghum, collard, banana, king-protea |
| Blossomreach | bok-choy, daikon, adzuki, persimmon, sakura |
| Monsoon Tangle | rice, kangkong, lemongrass, bitter-melon, sampaguita |
| Coralscatter | taro, coconut, pandanus, warrigal-greens, tiare |

The rest (22 at Twigg's, 223 in the towns) is not deleted and not moved: each row gets a gate key and sits behind section 3.

## 3. The ladder

Each gate opens when EITHER way is true. Checked when the shop page or the buy runs, then stored: never closes.

**Mossbottom (per gnome, whole Hollow).** "Different crops" = rows of `user_plant_knowledge` with knowledge > 0.

| Gate | Name | Road way | Garden way | Adds | Total |
|---|---|---|---|---|---|
| start | | | | 14 | 14 |
| `m1` | Kitchen row | any bar at any stop reaches 34 | 5 different crops harvested | beet, cucumber, spinach, turnip, green-bean, garlic (5 vegetable, 1 legume) | 20 |
| `m2` | Herb shelf | first bar latched anywhere | 10 different | coriander, parsley, thyme, lemon-balm, peppermint (5 herb), kale | 26 |
| `m3` | Field sacks | Maplewold town Mending (R >= 15), or 3 bars latched | 16 different | cabbage, broccoli, cauliflower, celery, fennel (5 vegetable), crimson-clover (cover) | 32 |
| `m4` | Full Emporium | Maplewold Thriving (R >= 50), or any Seal, or 8 bars latched | 24 different | winter-rye (cover), garden-sage, rosemary (herb), horseradish | 36 = today |

**Region town (per gnome, per region).** Categories follow the bars: Larder = food, Cheer = flowers, Repairs = the dearer stock that needs carts.

| Gate | Name | Road way | Garden way | Adds |
|---|---|---|---|---|
| start | Wren's five | first visit | | 5 |
| `r1` | Sown | any bar at the town reaches 34 | 2 of the area's staples harvested (the chapter's own first step) | staples left (0-2) + the 3 cheapest flowers |
| `r2` | Mending | town state Mending (R >= 15, or town Repairs >= 34) | 6 different plants of the area harvested | cheaper half of the uncommons left |
| `r3` | Merry | Cheer latched at the town, or at 2 villages of the area | 3 different flowers of the area harvested | the last 8 flowers |
| `r4` | Thriving | town state Thriving (R >= 50), or the area's Seal | 12 different plants of the area harvested | dearer half of the uncommons (mostly trees) |

Cumulative seed lines per town (the guide row is always there, as today):

| Town | Start | r1 | r2 | r3 | r4 = today |
|---|---|---|---|---|---|
| Maplewold | 5 | 10 (+kidney-bean, soybean, black-eyed-susan, california-poppy, blue-violet) | 11 (+raspberry) | 19 | 20 (+hops) |
| Maizehollow | 5 | 9 | 12 (+chayote, nopal, papaya) | 20 | 22 |
| Mistmoor | 5 | 8 | 11 | 19 | 21 |
| Sunsprinkle | 5 | 9 | 11 | 19 | 21 |
| Rainroot | 5 | 8 | 11 | 19 | 22 |
| Olivewhistle | 5 | 8 | 11 | 19 | 22 |
| Birchbramble | 5 | 8 | 10 | 18 | 19 |
| Dunewhisper | 5 | 8 | 10 | 18 | 19 |
| Greatcanopy | 5 | 9 | 11 | 19 | 20 |
| Thornacre | 5 | 8 | 10 | 18 | 20 |
| Spicepeak | 5 | 9 | 12 | 20 | 23 |
| Blossomreach | 5 | 9 | 13 | 21 | 24 |
| Monsoon Tangle | 5 | 8 | 11 | 19 | 21 |
| Coralscatter | 5 | 8 | 10 | 18 | 19 |
| **All 14** | **70** | **119** | **154** | **266** | **293** |

Single-row doors (any gate, any shop): the gnome has harvested that crop once; an open chapter or errand step names it; it is this week's Village Show crop; a special order (section 4).

How the per-gnome filter works:

| Part | How |
|---|---|
| Gate key | New column `shop_stock.ladder_gate` (text, default '' = always). Filled once from `data/seed_ladder.txt` by an idempotent `seed_ladder_ensure()`; Admin can edit it. No other column of the row changes |
| Latches | `seed_ladder_gates (user_id, shop_id, gate, opened_at)` and `seed_ladder_items (user_id, item_id, how, at)`. Written only when something opens |
| One function | `seed_ladder_open($u, $row)`: setting off = true; gate '' = true; then item latch, harvested, story step, show crop, gate latch, live check (then latch). Cached per request |
| Read in 2 places | `buy_from_shop()` (after the wearables check; returns the hint as the refusal) and the stock list in `shop.php` (splits rows into "on the shelf" and "not yet") |
| Shared restock | `shop_restock()` is not changed. Hidden rows restock and take a price like any row; a gnome with the gate open buys them. For a gnome without it the row is not shown, whatever its stock |
| R and town state | `town_region_repair()` / `town_state()` from town-states slice 0. If that is not built, the road ways that need R are simply false and the garden ways carry the ladder |
| Cost | Gates all open for a shop = 1 query. Else up to 4 small counts, cached |

## 4. Safety: the story never blocks

| Rule | Mechanism |
|---|---|
| S1. Story seeds are on the shelf from the first visit | Wren's five: every `grow` / `plant` / `bed` / flower step of all 28 v2 chapters and the old ones, in every area. No unlock code is in the path |
| S2. Step tie for anything else | A crop, flower or `-seed` slug named in a step of a chapter or errand the gnome has open is latched into `seed_ladder_items` (today: chayote, for `ca-s05` and `ca-s08`). A lint (`tools_lint_seed_ladder.py`) fails if a story slug is neither in a five nor step-tied |
| S3. Grown once = stocked | One harvest of a crop opens its row for good. So a gift, a find, a trade or a saved seed is a real door |
| S4. Never bare (bottom drawer) | A start-shelf row with 0 stock still sells to this gnome: 10 a row a game day at `price_max`. Same table as the town-states back room |
| S5. Escape hatch (special order) | Any locked seed: one order a game day, 3 seeds, at 2 x `price_max`. Dear and slow, never a wall. Harvest it and S3 opens the row |
| S6. Gifts, finds, trades, seed saving | Not touched. A locked seed can be held, planted, gifted, sold at the Trading Post |

Edge cases:

| # | Case | Ruling |
|---|---|---|
| 1 | Gnome already playing when the setting goes on | Nothing is taken. One snapshot at first read: every seed held or planted is latched; every crop ever harvested is open by S3; gates are checked from the live record (bars, Seals, harvest counts). Most veterans land on the full shelf |
| 2 | Hub reachable from anywhere, region shops far | Hub gates read the whole Hollow, region gates read their own area. Nothing a region town sells is needed before the gnome stands in it |
| 3 | Gnome skips an area | Its town stays at 5 for them. Hub and other areas are not held back |
| 4 | Fast travel into a new area | Lands at the town. First visit = Wren's five at once |
| 5 | Level 1 gnome in a high area | Sees the five like anyone. The ladder adds no level gate; soil and the Warden doors gate as today |
| 6 | Treasure seeds, pal gifts, sight gifts, landmark finds, job and Show prizes | Not in shops, not in the ladder. Still given. Harvesting one changes nothing (no row) |
| 7 | A recipe in a cooking step needs a locked crop | Steps ask for "a home-cooked meal", never a named dish. 5 dishes cook from the start 14. A named dish in a future step falls under S2 (its ingredients are step-tied; the lint reads recipes too) |
| 8 | Florists (Petalpin's, Blossom & Bough), Hedge & Hearth, pet shops | Sell no seeds. Not in the ladder |
| 9 | Out of stock vs locked | Out of stock: as today (row hidden; start rows show the bottom drawer). Locked: listed under "Not on the shelf yet" with its hint. Never the same words |
| 10 | A friend gifts a locked seed | Allowed. Plant it, harvest it, the row opens (S3) |
| 11 | Selling back | Shops never buy seeds. `shop_buy_floor()` reads all rows as today. No buy-sell gap is made |
| 12 | Tests and Admin | Admin sees every row with a small gate tag, and "view as a new gnome" on the shop page. Tests set latches directly |
| 13 | Second garden in another area | Gates are per gnome, not per garden. Owning a garden in an area opens `r1` there |
| 14 | Fresh start (Admin reset of one gnome) | Both latch tables are cleared for that gnome with the rest of the progress |
| 15 | Season-locked crops | None are locked: off season is slower, not refused. 6 of the 14 and wild-rice are all-season |
| 16 | New area or new seed added after a gnome's gates opened | A new row gets a gate key from the rule; latched gates cover it at once. A new area starts at 5 |
| 17 | Setting switched off | The filter is not read: full stock for all. Latches stay in the tables for the next time |
| 18 | Decay | None. Gates and item latches only ever get written. `mark_decay` or a bigger N cannot close one |
| 19 | Many accounts | An alt cannot sell seeds to a shop. It can gift a locked seed, which is door S3 and costs the alt its Petals. No gain |
| 20 | Shared shelf, price | No price band changes. Every new gnome now buys from the same 14 rows: S4 keeps them from running dry. Locked rows sit fuller for those who opened them |

## 5. Wording

Shop, locked rows (one folded list under the stock, no price, no button except "Special order"):

| Gate | Line |
|---|---|
| `m1` | "Kitchen row: beet, garlic and four more. Twigg: 'Grow five different things, or start mending a stop, and I'll put it out.' ({n} of 5)" |
| `m2` | "Herb shelf. 'Finish one bar at any stop, or grow ten different things.' ({n} of 10)" |
| `m3` | "Field sacks. 'When carts reach the Maplewold again, or you've grown sixteen.' ({n} of 16)" |
| `m4` | "The top shelf. 'When the Maplewold thrives, or you've grown twenty-four.' ({n} of 24)" |
| `r1` | "Not unpacked yet. Harvest two {area} staples, or lend a hand in town." |
| `r2` | "Waiting on a cart. Mend the villages of {area}, or grow six of its plants. ({n} of 6)" |
| `r3` | "Flower crates. They come when {town} is merry, or when you've grown three of its flowers. ({n} of 3)" |
| `r4` | "The orchard order. It comes when {area} thrives, or when you've grown twelve of its plants. ({n} of 12)" |
| Sold out | "Sold out. More within the half hour." Start rows add: "Or from the bottom drawer: {price}, {n} left today." |
| Refused buy | "That one is not on your shelf yet. {the gate line}" |

Town page, one sentence under the town state chip:

| Tier | Sentence |
|---|---|
| start | "{shop} has Wren's five on the counter and empty hooks behind." |
| r1 | "{shop} has unpacked the staples and a few flowers." |
| r2 | "A cart got through. {shop} has rarer seed again." |
| r3 | "Flower crates by the door of {shop}." |
| r4 | "{shop} is full to the rafters." |

Wren:

| When | Line |
|---|---|
| Tour, at Twigg's | "Fourteen jars. It was a hundred once. Grow what's here and Twigg will find the rest." |
| First visit to a town | "I asked them to keep five things back for you. They're what this place needs first." |
| A gate opens (flash) | "New on your shelf at {shop}: {names}." |
| Full shop | "Every hook has a packet on it again. That was you." |

## 6. Setting, slices, tests, size

Setting: `seed_ladder_open`, default `0`, Hollow group. Needs nothing. Uses `stop_marks_open`, `seals_open`, `town_states_open` when they are on (road ways); with all three off the garden ways still open every gate.

| # | Slice | Contents | Test | Size |
|---|---|---|---|---|
| 0 | Data | `data/seed_ladder.txt` (the 14, the 14 fives, the gate rule), column `ladder_gate`, `seed_ladder_ensure()`, the setting, the lint | Fresh install: 14 + 70 rows with gate '', 22 + 223 gated, sums as section 3; run twice = no change; lint passes | S |
| 1 | Engine | `includes/seed_ladder.php`: `seed_ladder_open()`, both tables, garden ways, snapshot for old gnomes | Off = all open. New gnome: 14 and 5. 5 harvests = `m1`. S3. Snapshot keeps held seeds. Latch stays after the count drops | M |
| 2 | Shop | Filter in `buy_from_shop()` and `shop.php`, the locked list, lines of section 5 | Locked row: not in the list, buy refused with the hint, shelf count unchanged. Second gnome with the gate buys it. `shop_buy_floor()` same before and after | M |
| 3 | Story ties | Step tie (S2), show crop, lint over chapters, errands, recipes | With only the fives: every `grow` / `plant` step of every chapter is buyable. `ca-s05` open = chayote open | S |
| 4 | Road ways | Bars, latches, R, Seals into the gates; flash on open | The four examples of town-states section 1 give the right gates; the systems off = no error | S |
| 5 | Drawer and order | S4 and S5, `town_backroom` table | 0 stock start row: 10 at `price_max`, 11th refused, new game day resets. Order: 3 seeds, once a day | M |
| 6 | Words and Admin | Town sentence, Wren's lines, Almanac note, Admin tag and preview, `ladder_gate` in CRUD | Lines present per tier; Admin sees all rows | S |

Tests: `tests/seed_ladder.php` + `.sh` (above), plus a walk: a new gnome with the setting on finishes First Week days 1 and 4 and the M1 `grow` step buying only from the start shelves.
Size: L in all (3 M + 4 S). Slices 0 to 3 are the feature; 4 to 6 can follow. Each ships dark.

## 7. Decisions

| # | Decision | Recommended |
|---|---|---|
| 1 | The Maplewold 5: the story five (oats, lentil, wild-rice, apple, goldenrod), or a "first garden" five (oats, lentil, kidney-bean, black-eyed-susan, blue-violet)? | **Story five.** No Maplewold chapter then depends on unlock code. Twigg's 14 is the first garden; the gnome already holds kidney-bean, soybean and two flowers from sign-up |
| 2 | Do the other 13 towns also start at 5? | **Yes**, same rule. Else the ladder ends at the Maplewold border |
| 3 | Does one harvest of a locked crop open its row (S3)? | **Yes.** It makes gifts and finds matter and removes most edge cases. Cost: a keen gnome can skip gates |
| 4 | Special order (S5): one a game day, 3 seeds, 2 x top price? | **Yes.** Without it "never a dead end" rests on the lint alone |
| 5 | Should the rest state be reached by normal play, and in how many game days? | **Yes.** Estimate, not simulated: Twigg's full in 12-20 game days by gardening, 20-35 by road work. Maple & Furrow full in 15-35 (at the latest with the Seal). Hub + Maplewold: **N about 25**. Each later town about as long as its Seal (18-48). All 14: 270-440 |
| 6 | Old gnomes: gates from their record (edge case 1), or everything open for anyone made before the switch? | **From the record.** Nothing they have is lost, and it is one code path. If any complaint: the blanket pass is one line |
