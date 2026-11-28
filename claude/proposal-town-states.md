# Proposal: town states (run low, mending, thriving). Shops always open

Status: PROPOSAL ONLY, nothing wired in. Written 2026-11-28. Follows `proposal-stop-states.md` and replaces its rule "the 14 market towns are never ruined" (2.3, 5.1 row "Town scenes").
Owner's decision: towns get ruined / working / fixed states, shops are always open, stock may grow as the region repairs.
Numbers come from a fresh SQLite install of branch `ccr-45ffe12f-9cokuo`.

**Verdict.** "More stock as the region repairs" is good in one narrow form only: a **per-gnome back room**. The plain form (a fuller shelf, higher tiers, lower prices) does not fit the code:

| Fact today | Where | What it rules out |
|---|---|---|
| A shop has ONE shelf for all gnomes (`shop_stock.current_stock`), refilled every 30 min by chance | `shop_restock()` in `world.php` | A fuller shelf "for this gnome". Repair is per gnome, the shelf is not |
| A region town has one seed shop: 20 to 25 rows. Every staple, flower and uncommon seed of the region is already on it | `shop_stock` (307 rows, 14 shops) | "Higher tiers": only the 3 treasure seeds per region are unsold, and they are story rewards |
| Mossbottom's shops are reachable from anywhere | `shop_reachable()` | Moving hub wares into towns: worth nothing |
| Lasting marks give 1 to 2% off in shops, with caps per family | `stop_perks.txt` (F02) | A town price cut of 5% would be worth more than three latched bars |

So: state art + words for all 14 towns, and one stock rule (the back room). No price change. Nothing sold today is ever removed.

---

## 1. The region repair number

Per gnome, per region. Read from the Repairs bars of the region's villages (`locations.kind = 'village'`, by `region_id`, road and off-road alike).

| Symbol | Meaning | Read from |
|---|---|---|
| N | villages of the region (10 to 12) | `locations` |
| F | villages whose Repairs bar is latched for this gnome | `mark_latched()` |
| W | villages not latched with Repairs >= 34; the home village always counts here at least | `mark_bar_get()`, `users.home_village_id` |
| **R** | **floor(100 x (2F + W) / (2N))**, 0 to 100 | |

| Rule | How |
|---|---|
| Cheap | Two queries per region (latched rows, meter rows), cached per request. Once a town is Thriving nothing is computed: the stored state is read |
| Never goes down | Latches are for good. But N can grow (Cattailmere and Granitegate make the Maplewold 12) and Admin can set `mark_decay` above 0. So the **best state reached** is stored: `town_state_best (user_id, region_id, state, r_best)`, written only when it rises. Same idea as `region_standing_best` |
| Deterministic, no timers | Only latches and bar values. No clock, no chance |
| Town's own Repairs bar | Not in R. It is a floor: town Repairs >= 34 (or latched) = never below Mending. A gnome who works at the town sees it move |

Worked examples, the Maplewold (N = 10):

| # | Gnome | F | W | 2F + W | R | State |
|---|---|---|---|---|---|---|
| 1 | New. Home village Poppyburrow (floor) | 0 | 1 | 1 | 5 | Run low |
| 2 | Week one. Poppyburrow latched, Honeybrook Repairs 40 | 1 | 1 | 3 | 15 | Mending |
| 3 | Near the Seal. 4 latched, 3 under repair | 4 | 3 | 11 | 55 | Thriving |
| 3b | Same gnome after the Maplewold grows to N = 12 | 4 | 3 | 11 | 45 | Thriving (stored best) |

---

## 2. The town state ladder

| State | Key | Rule (best ever) | Shown name | Art |
|---|---|---|---|---|
| Ruined | `ruin` | R < 15 | Run low | Overcast, lighter than a village ruin. Most windows dark, half the stalls shuttered, awnings grey and patched, weeds in the cobbles, an empty cart. **The Shops spot stays lit: lamp on, door open** |
| Being worked on | `work` | R >= 15, or town Repairs >= 34 | Mending | Half the square back in colour (stepped mask). Scaffold on one or two buildings, a cart being unloaded, crates, more lamps lit |
| Fixed | `fixed` | R >= 50, or the region's Seal held (decision 5) | Thriving | Today's picture, untouched |

Constants `TOWN_WORK_AT = 15`, `TOWN_FIXED_AT = 50`. With N = 10: Mending = 3 points, Thriving = 10 points (5 villages mended, or 4 mended + 2 under repair).

Town ruin vs village ruin:

| | Village | Town |
|---|---|---|
| Roofs, walls | holes, fallen pieces, boarded door | whole. Shutters closed, patches, no holes |
| Lamps | all out | few lit, the shop lamp always |
| Recolour | full overcast | about 60% |
| Reads as | abandoned | hanging on, short of everything |

Pictures:

| Set | Exists | New | Note |
|---|---|---|---|
| Town scenes `here-town-<code>.png` (480 x 270) | 14 + hub + `here-town.png` | **28** (14 x `-ruin`, `-work`) + 2 fallbacks (`here-town-ruin.png`, `-work.png`) | Hub: none (decision 1) |
| Town header (`town.php` line 230 uses `stop-market.png` for every town) | 1 | 0 | `stop-market-ruin.png` / `-work.png` are already in the stop-states count |
| Shop Street `here-shops-street-<code>.png` (480 x 300) | 14 + 1 | 0 | Unchanged in v1: the street is where "always open" must read true |
| Map badges | | 0 | The 4 badges of stop-states 5.4 |
| **Total** | | **30** | |

How they are made: `tools/stop_states/make_states.py` gets a `town` recipe (it has mill, shrine, ferry today).

| Step | Tool function | Input |
|---|---|---|
| Source | | `aseprite-source/v3/here-gate/towns/here-town-<name>.png` + `.layout.json` (8 spots each, every spot has a `box`); name to code as in `tools/import_gate_layouts.py` |
| Recolour | `overcast(strength=0.6, keep=<shops box>)` | the `shops` spot box keeps its colour |
| Dim | `darken_lights()` on every spot box but `shops`; `glow()` + `lantern_on()` at `shops` | spot boxes |
| Wear | `overgrow(moss, weeds, cracks; rubble=0)`; new `shutter` and `patch` sprites stamped on boxes | 2 new sprites |
| Mending | `stepped_mask()` over the square, `scaffold()` on the two widest boxes, crate sprites at `shops` | ruin + fixed |
| Check | `contact()` sheet of 14 x 3; lint: every `town-<code>` layout has both twins | |

No hand placement: all positions come from the layout boxes. Expect touch-up on about 4 of 28.

---

## 3. Shop stock rules

Today (all states keep this, unchanged):

| Thing | Today |
|---|---|
| Per town | 1 seed shop (20 to 25 rows). 11 towns: a pet shop (own system, not touched). Blossomreach: a florist (12 rows) |
| Shelf | Shared by all gnomes. Not daily, not per gnome |
| Restock | Every 30 min, each row by chance: staples 90% (max 20), flower seeds 45 to 74% (max 6 to 10), uncommon 40 to 56% (max 5 to 8), the region guide 6% (max 1) |
| Price | Random between the row's `price_min` and `price_max` at each restock; then Charm, staff friendship, marks, season |
| Closed? | Only by game-clock hours or nobody on shift (`shop_state()`). Town state adds no closing, ever |

New: the **back room**. A per-gnome allowance, per gnome game day, used only when the shared shelf cannot fill the order. It never touches the shared shelf.

| | Run low | Mending | Thriving |
|---|---|---|---|
| Shared shelf, all rows | as today | as today | as today |
| Back room: staple seeds | none | 5 a row a game day | 10 a row a game day |
| Back room: flower and uncommon seeds, florist flowers | none | none | 2 a row a game day |
| Back room: the region guide | none | none | 1 copy, once, if not read |
| Back-room price | | the row's `price_max` (+ markup), then the gnome's usual discounts | same |
| Far shelf (rows with `shop_stock.min_town_state`) | none | none in v1 | none in v1. The slot for later wares (the 11 stall lines, decision 6) |
| Shelf prices | as today | as today | as today |
| What the shop pays | as today | as today | as today |

Why it cannot hurt a new player:

| Worry | Answer |
|---|---|
| A ruined town sells less | No. Run low = today's shop, row for row. Every rule above only adds |
| Rich gnomes empty the shelf | The back room is separate stock. A Thriving gnome buying from it leaves the shared shelf alone |
| A shop reads as shut | The Shops spot is lit in every picture; the words say "open" first (below) |

Why it cannot be exploited:

| Check | Result |
|---|---|
| Buy low, sell high | No price goes down, so `shop_buy_floor()` and the `sell_price()` cap are unchanged |
| Seeds, guides | Not sellable to shops at all (`sell_to_shop()` takes produce, flower, food, part, forage, arrangement, packet) |
| Florist flowers (sellable) | Back room charges `price_max`; the sell cap is the cheapest buy price (`price_min` based). Always a loss or zero |
| Farming the allowance | Capped per row per game day; the counter is the gnome's own day (`gclock_my_date()`), as every daily charge |
| If a price cut is ever wanted | It must go inside `shop_discount_pct()`, so the buy-back floor follows it. Not recommended (decision 3) |

Words on the town page and in the shop (one chip "Run low" / "Mending" / "Thriving" + 3 lines):

| State | Line 1 (town page) | Line 2 (town page) | Line 3 (shop page) |
|---|---|---|---|
| Run low | "The shelves are thin but the door is open." | "No cart has come up the road in a long while. Mend a village and one might." | "What you see is what there is. Nothing in the back." |
| Mending | "Carts are getting through again." | "{F} of {N} villages mended. The square is waking up." | "Shelf bare? Ask. The keeper holds a few staples back for you. ({n} left today)" |
| Thriving | "Every stall is up and the lamps are all lit." | "The roads of {region} carry goods again. You did that." | "The back room is full. Staples, rarer seeds, and a guide kept under the counter for you." |

---

## 4. Interplay

| System | Effect |
|---|---|
| Lasting marks (`stop_marks.php`) | Unchanged. The town keeps its 3 bars and perks. Town Repairs = the Mending floor only. Mark discounts (F02) apply to back-room prices as to any price. "Known at the Stalls" leaf shows on back-room rows too |
| Stop-states overlays | Town keeps `stocked` (Larder latch: crates by the door) and `merry` (Cheer latch) layers over any state |
| Standing and Seals (`seals.php`) | Town state is not a Standing row and gates nothing. It only reads. A held Seal floors the town at Thriving (covers gnomes kept by `seal_grandfathered()`) |
| First Week (`first_week.php`) | No goal needs stock. Day 4 "Do something in a town square" works in every state. A test asserts it |
| Wren's tour (`tour.php`) | Sends the gnome to Twigg's in Mossbottom. Hub is not in this system, so no change |
| Fast travel (`travel_to()`) | Still lands at the region's town, in any state. The first sight of a new region is its Run low town: one arrival line (below) |
| Story | "The roads went dark, not the towns" becomes: **"The towns kept one lamp lit and the door open. Then the carts stopped coming."** |
| Flash, from `mark_after()` when a village Repairs add lifts the town | "A cart got through to {town}. The square is mending." / "{town} is thriving again." Wren's arrival line at a Run low town: "They never shut. They just ran out. Mend the villages and the carts come back." |
| Wren's area page | One more count for looks: "Town: Mending (R 30 of 50)" |

---

## 5. Setting and build slices

Setting: `town_states_open`, default `0`, Hollow group. Needs `stop_marks_open` = 1. Off = towns as today, no back room. Does not need `stop_art_states_open` (without the twins the scene falls back to a CSS filter class).

| # | Slice | Contents | Test | Size |
|---|---|---|---|---|
| 0 | Number and state | `includes/town_states.php`: `town_region_repair($uid, $rid)`, `town_state($uid, $rid)`, table `town_state_best`, the setting | `tests/town_states.php`: off = `fixed`; the 3 examples of section 1; N grows = state kept; town Repairs 34 = `work`; Seal = `fixed`; second gnome has own state; hub = `fixed` | S |
| 1 | Words and filter | Chip + lines on `town.php` and the Here caption; CSS class on the town scene; flash lines in `mark_after()` | Page has the right line per state; off = no chip; First Week day 4 goal still completes in a Run low town | S |
| 2 | Art | `town` recipe, 30 pictures, contact sheet, lint; scene pick in `here_view()` via `stop_art_scene()` | Lint: all twins exist, 480 x 270; missing twin falls back without error | M |
| 3 | Back room | Table `town_backroom (user_id, stock_id, day, n)`; `buy_from_shop()` fills from the shelf first, then the back room; `shop.php` shows what is left | Run low: order above shelf fails as today. Mending: 5 staples at `price_max`, 6th refused, shared shelf count unchanged. Thriving caps. New game day resets. `sell_price()` same before and after. Setting off = none | M |
| 4 | Far shelf gate | Column `shop_stock.min_town_state` (default 0); filter in the shop list and in `buy_from_shop()`; no rows shipped | A row with state 2 is hidden and unbuyable below Thriving; `shop_buy_floor()` still counts it (the cap only gets stricter) | S |
| 5 | Wren | Arrival line, the area page count | Lines present per state | S |

Slices 0 to 2 answer "working and ruined states for towns". Slice 3 is "more stock". Each ships dark behind the setting.

---

## 6. Risks and decisions

| Risk | Guard |
|---|---|
| A new gnome lands in a grey town and thinks the shop is shut | Lit shop in every picture; "the door is open" is the first line; Run low sells all of today's stock |
| Off-road villages are hard to find, Thriving feels far | Thriving needs half the points, not all; 3 road villages mended + 2 found is enough in most regions |
| Back room makes the scarce region guide (6% a restock) easy | Only at Thriving, once, at the top price |
| Two rules for one picture (R and the town's own bar) | The town bar is a floor only, one line of code, one test |

| # | Decision | Recommended |
|---|---|---|
| 1 | Is the hub, Mossbottom Market, in this? | **No.** No region, no bars, the tour and First Week start there, its shops serve every gnome. Later, for looks only: one caravan in the hub picture per Thriving town |
| 2 | N = all villages of the region, or road villages only? | **All.** Road-only gives N = 3 in the Maplewold (too coarse) and ignores 89 of 146 villages |
| 3 | Any price change with state? | **None.** Marks give 1 to 2%; a town cut would swamp them, and every cut widens the buy-sell check. If wanted later: at most 2% at Thriving, inside `shop_discount_pct()` |
| 4 | Back room caps: 5 staples (Mending), 10 staples + 2 rarer (Thriving)? | **Yes**, as constants. Staples restock at 90% already, so this is comfort, not income |
| 5 | Does a held Seal make the town Thriving at once? | **Yes.** Stops a Seal holder (or an old gnome kept by grandfathering) from finding a grey town the day the setting goes on |
| 6 | Rarer wares at Thriving: the guide copy, treasure seeds, the 11 stall lines? | **Guide copy: yes. Treasure seeds: no** (they are chapter rewards). **Stall lines: keep them chapter rewards**, but show them on the Far shelf (slice 4) so both use one gate |
