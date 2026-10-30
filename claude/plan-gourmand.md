# Plan: The Gourmand (Pomeroy Crumbworth), the build plan (2026-10-30)

This is the only document an implementing agent needs. It replaces `proposal-gourmand.md`, `review-gourmand.md` and `review-gourmand-rewards.md`, and it applies `decisions-gourmand.md` (Josh's final word). Line numbers were checked at commit `87204c40`. Re-check them before you edit, because they drift. Do not bump or name a version. Wherever this plan says **next version**, Josh picks the number at release time.

---

## 1. Concept

1. **Pomeroy Crumbworth** (`pomeroy-crumbworth`) is a dormouse food writer. Personality: Fussy (🐭 comes from `npc_icon`). He wears a mustard waistcoat with eleven labelled pockets ("emergency biscuit", "other emergency biscuit") and keeps a napkin tucked under his chin. He carries a silver tasting spoon on a watch chain and a jam-thumbprinted journal.
2. He is the dormouse from the `round-door` road card (`data/road_events.txt:53-54`: "A dormouse invites you in for a snack."), and he remembers everyone he has fed.
3. His story: "I sneezed at Aurora Camp and my sense of taste blew away in fourteen pieces, one to every region." The truth comes out in Juniper Kettleby's letter: he stopped cooking for anyone, so food stopped tasting of anything.
4. Every region has three courses. **Plate** is a raw crop judged by harvest quality. **Pot** is a cooked dish judged by the new `cook_pots.score`. **Jar** is a Pantry preserve judged by its jar score. The optional **Grand** course (P2) is the region's feast. He judges in spoons, from 🥄 to 🥄🥄🥄.
5. When a gnome has served a region's Plate, Pot and Jar at 1 spoon or better, that region is a **Taste**. Fourteen Tastes complete the story.
6. Arc:
   - `hello`: first visit to gourmand.php.
   - `first`: 1 Taste.
   - `four`: 4 Tastes.
   - `mid`: 7 Tastes. Juniper's letter arrives, and from then on a second spoon is laid at his table.
   - `home`: 10 Tastes. The Home Plate (P2).
   - `finale`: 14 Tastes. He cooks for you.
   - Coda: **Golden Palate**, for all 42 courses at 3 spoons.
7. The beats in order of play: napkin, spoon, verdict. On a 3-spoon verdict he dozes mid-compliment, then: "…as I was saying: splendid."
8. Voice: grand, then suddenly plain. Short lines. Use ’ (never a straight apostrophe).
   - "Honest. I’d have seconds."
   - "That is a jar that has been *thought about*."
   - "I can taste the shop counter." (said when he refuses a bought or plain stack)
   - Juniper's letter: "He was never ill, you know. He just stopped cooking for anyone, and then stopped tasting. Keep feeding him. And sit down while he eats. It matters."
   - Finale: "It tastes of company. I think it always did."
   - Mossbottom line: "Sit, sit. There’s always a second spoon at this table."
9. Variants rotate every month: `(Y*12+m) % n`. One tour is one Hollow month (`hollow_date('Y-m')`).
10. The feature is off by default (`gourmand_open` = 0). Admins see everything at all times.

### 1.1 Regions (data for `gourmand.txt`; `v2` and **NEW** slugs arrive in P2)

| Code | Camp slug (festival day) | Plate | Pot v1 / v2 | Jar variants (3-spoon-capable in **bold**) | Grand (P2) | Taste | Golden seed |
|---|---|---|---|---|---|---|---|
| NA | `na-sugarshack` (3) | 3 `wild-rice` | `apple-crumble` / `wild-rice-hotdish` | `raspberry-jam`, **`apple-cider`** | `feast-maplewold-table` | sweet smoke | `pecan-seed` |
| CA | `ca-tea` (5) | 3 `tomatillo` | `three-sisters-stew` / `bean-tamales` | `salsa-verde`, **`fermented-hot-sauce`** | `feast-maizehollow-mole` | slow heat | `cacao-seed` |
| CB | `ss-brewhouse` (7) | 2 `plantain` | `sea-grape-sorbet` / `rice-and-peas` | `guava-jam`, **`lime-cordial`** | `feast-isles-ackee-pot` | lime on the breeze | `nutmeg-seed` |
| SA | `sa-tea` (9) | 3 `quinoa` | `fiddlehead-fry` / `quinoa-soup` | `peanut-butter`, `passion-fruit-curd`, **`chicha`** (P2) | none | high green | `brazil-nut-seed` |
| NWE | `nwe-tea` (11) | 3 `rhubarb` | `potato-leek-soup` / `colcannon` | `lingonberry-jam`, **`blackcurrant-cordial`** | `feast-mistmoor-supper` | rainy-day comfort | `cloudberry-seed` |
| SE | `ow-press` (13) | 2 `artichoke` | `grilled-sardines` / `artichoke-fava-stew` | **`cured-olives`**, **`lemon-cordial`** | `feast-olivewhistle-supper` | sunshine | `caper-seed` |
| EE | `ee-tea` (15) | 4 `sorrel` | `mushroom-toast` / `buckwheat-kasha` | `plum-jam`, **`sauerkraut`**, **`elderberry-cordial`** | `feast-steppe-table` | the good sour | `sea-buckthorn-seed` |
| MENA | `dw-bazaar` (17) | 3 `date` | `shakshuka` / `falafel` | **`hummus-jar`**\*, **`pomegranate-molasses`** | `feast-dunewhisper-pilaf` | warm spice | `saffron-seed` |
| WCA | `wca-tea` (19) | 4 `fonio` | `rice-and-beans` / `egusi-soup` | **`pickled-okra`**\*, **`hibiscus-cordial`** | none | deep red earth | `grains-of-paradise-seed` |
| ESA | `esa-tea` (21) | 1 `watermelon` | `chickpea-stew` / `sukuma-wiki` | `banana-chips`, **`rooibos-concentrate`** | none | first light | `coffee-seed` |
| CSA | `sp-grind` (23) | 3 `apricot` | `lentil-dal` / `khichdi` | `mango-chutney`, **`curry-paste`** | `feast-spicepeak-thali` | fire | `black-pepper-seed` |
| EA | `br-blossom` (25) | 2 `persimmon` | `mackerel-rice` / `red-bean-buns` | **`kimchi`**, `pickled-daikon` | none | the quiet savoury | `yuzu-seed` |
| SEA | `mt-float` (27) | 3 `rambutan` | `coconut-curry` / `kangkong-stir-fry` | **`lemongrass-cordial`**, `tempeh` | none | bright | `mangosteen-seed` |
| OC | `cs-pools` (28) | 1 `coconut` | `mussel-broth` / `palusami` | `pickled-samphire`, **`poi`** (P2) | none | salt of the sea | `macadamia-seed` |
| Mossbottom | `hub-green` (1, Long Table) | none | | | | | |

- All the existing slugs, camp spots, tiers and treasure seeds were verified in a fresh DB.
- `ss-brewhouse` comes from `ensure_calling_mentors` (calling_quests.php:85,92). Teahouse slugs follow the pattern `<code>-tea`.
- \* Hummus-jar and pickled-okra land exactly on 62 at Kitchen III, so a −3 wobble drops them to 59. They reach 3 spoons only with luck.
- SA and OC jars cap at 2 spoons until P2 ships.

Ask lines (M rows, variant 1). Keep them in this exact voice:
- NA: "Wild rice, raw, if you please. I want to hear it crunch before I hear it cooked."
- CA: "Tomatillos! Little lanterns of sour. Three, and I’ll forgive the café for the chocolate I haven’t had yet."
- CB: "Juniper says I’m not to be fussy. So: two plantains, ripe, and I shan’t mention the colour."
- SA: "Quinoa, three handfuls. The Rainroot has a hundred potatoes, and I am pacing myself."
- NWE: "Rhubarb. Raw. Don’t look at me like that. A gnome must face the sour to deserve the crumble."
- SE: "Two artichokes. I eat them petal by petal, so we’ll be here a while. Pull up a crate."
- EE: "Four leaves of sorrel, please. Not you, Sorrel Inkcap. You’re a snail and a scholar. The leaves."
- MENA: "Three dates, and sit. In the bazaar the first date is a joke and the second is a story."
- WCA: "Fonio! The smallest grain in the Hollow. Four handfuls, and I shall admire every one."
- ESA: "One watermelon. Whole. I have a spoon, and I have the afternoon."
- CSA: "Three apricots from the roof of the world. My eyes are watering already, and that’s just the grinders."
- EA: "Two persimmons, soft as a promise. Under the blossom, if you don’t mind. I like to eat with a view."
- SEA: "Rambutan! They look like they’re shouting. Three, please, and I’ll shout back."
- OC: "One coconut, opened with ceremony. Island time, gnome: there is no hurry, only lunch."
- Pot, Jar and Grand asks plus margin notes are written to match. Examples:
  - NA pot: "Something warm with apples in it. A crumble. I won’t say please twice." Note: "The crust gave way like a good argument."
  - NA jar 2: "Cider, two weeks in the jar. Patience is an ingredient." Note: "Sharp, cloudy, cold. Autumn talking."

## 2. The final mechanic

### 2.1 The questline is always open
- A gnome can serve region R's courses **at any time**, from **anywhere in region R**: `player_location($u) === R's gnomish_name`, which is what `can_reach($u, R)` checks (world.php:260). There is no visit window.
- Mossbottom has no courses.
- Folk and villager pages treat him as present everywhere: `npc_here()` returns true for him, so chat and gifts work like other NPCs, with their existing daily caps.
- Serving rules:
  - one serve per (gnome, tour, region, course)
  - level 3 or above
  - not a guest (`is_guest_uid`)
  - the gnome holds at least the M row's qty
- Quality is `market_stack_q($uid, $itemId, $have)`, the average of the stack held. A result of 0 spoons is refused, and nothing is taken.
- Course gating: the Plate needs nothing. The Pot needs a Kitchen and the Jar needs a Pantry; both are naturally gated by owning the item. The Grand course (P2) needs `user_building_bonus($uid,'kitchen')['best'] >= 3` and that region's first Taste.

### 2.2 Events at a fixed town spot (the camp)
- `gourmand_stop($ts)` is a pure function of `hollow_date('j'/'t')` and `TOWN_FESTIVALS` (town.php:36-52). It only decides **where he is shown**: the camp spot tile, the folk "now" line, the town fold, rumours and road meets. It never gates serving.
  - Day 1: Mossbottom, `hub-green` (the Long Table).
  - For each festival town with festival day F (3…27): the window runs from the day after the previous festival through F.
  - OC: from day 28 to the end of the month.
  - Windows run from midnight to midnight in `hollow_tz()`. A window that spans a DST change lasts 47 or 49 h.
- **Festival day.** A serve for region R on R's festival day (`town_festival(R, gourmand_now())` is non-null) **doubles friendship only**: +5 becomes +10, and the 3-spoon +10 becomes +20. Petals and XP stay the same.
- **Long Table (day 1, Mossbottom).** This is a simple event with no board:
  - A gnome who served 7 or more courses in the previous tour claims a seat: 50 Petals and `apply_event_effect($u,'tbuff:charm:2:240')`.
  - The claim key is `<prev Y-m>|LT|seat`.
  - Every gnome can reach it (`can_reach` covers `HUB_REGION`).
  - There are no late plates (always-open serving makes them redundant).
- **Finale.** It plays at the **next meeting**: the first load of `gourmand.php` or of his folk page after the serve that earned the 14th Taste. The serve's prize card ends with "Come back and sit down. I have something for you." It is not tied to a date.
- **Dropped:**
  - Wayside Bite
  - Long Table board
  - Almanac chapter and Taste pages
  - `gourmand_teach`
  - `gourmand_plates`
  - `travellers_active()`
  - festival Petal doubling
  - 10 of the 12 settings
  - R-row arrival and leaving lines

### 2.3 Spoons, quality, rewards
- Bars are consts in gourmand.php:
  - Plate, Pot and Grand: 🥄 40, 🥄🥄 50, 🥄🥄🥄 65.
  - Jar: 45, 52, 62. Quick jars (recipe `cook_minutes` <= 1440, i.e. the 1-day jams and curd) use 42, 49, 55 instead (`gourmand_bars('jar', $slug)`, the one place bars are chosen; `pantry_quality` is unchanged). The quick 55 bar is reachable only at Kitchen III with a decent roll.
- Spoon words come from a const of their own, **not** `fair_word` (`fair_word(62)` = "Fine", because Splendid starts at 65): 1 = "Honest", 2 = "Seconds, please", 3 = "Splendid".
- Before you press Serve, the panel shows: "Your Wild Rice: 3 held, quality 52 → 🥄🥄 (Seconds, please)". If untracked units drag the average down, it adds: "Older or bought ones are dragging this down. A fresh harvest scores higher."
- Dish score (P1), set in `cook_start` and written to `cook_pots.score`:
  ```
  ing   = qty-weighted mean over the recipe's ingredients of q(item):
          market_stack_q if the gnome holds tracked units; else 50 for wild or animal goods
          (category forage/part, or hen-egg/quail-egg/goat-milk); else 35 (MARKET_PLAIN_Q)
  score = clamp(round(0.8*ing + 4*user_building_bonus($uid,'kitchen')['best']
                + min(4, max(0, eff_mod($u,'luck'))) + random_int(-3,3)), 1, 100)
  ```
  The clamp starts at 1, so 0 always means "not scored" (a pot started before the upgrade).

| Reward | Once per | Pays (through `give_petals`/`give_xp`/`give_item`/`friend_add`) |
|---|---|---|
| First 🥄 / 🥄🥄 / 🥄🥄🥄 on a course | lifetime per region+course | 60 / +60 / +120 Petals, 20 / +20 / +40 XP. Skipped levels all pay. |
| Repeat serve | per tour per region+course | 25 Petals, 8 XP. **Never doubled.** |
| Full table (a Taste) | lifetime per region | 150 Petals, 2 × `<plate crop>-seed`, Journal card unlocked |
| Golden table (3 × 🥄🥄🥄) | lifetime per region | 300 Petals, **1** region treasure seed (table above) |
| Grand at 🥄+ (P2) | lifetime per region (8) | 200 Petals, 40 XP, a gold spoon on the Journal card |
| Long Table seat | per tour | 50 Petals, `tbuff:charm:2:240` |
| Finale | once | 1,000 Petals, title **Second Spoon**, item `second-spoon` |
| Friendship | per serve | +5 (+10 at 🥄🥄🥄), doubled on that region's festival day |

- Lifetime total is about 18,000 Petals and 14 treasure seeds. The monthly repeat ceiling is about 50 × 25 = 1,250 Petals.
- Titles:
  - Guest of the Gourmand (1 Taste)
  - Well Fed (7)
  - Second Spoon (finale)
  - Golden Palate (42 × 🥄🥄🥄)
  - Grand Diner (all 8 Grand, P2)

## 3. Corrections applied (all were verified against the code)

| # | Wrong in the proposal | Do this |
|---|---|---|
| 1 | `kitchen_best` | `user_building_bonus($uid,'kitchen')['best']` (gardens.php:89) |
| 2 | Jar words via `fair_word` | Use the spoon words const (fair.php:44-47: 62 = "Fine") |
| 3 | `town.php?spot=<slug>` | `spot` takes the **numeric** `town_spots.id` (town.php:80). Resolve it with `SELECT id FROM town_spots WHERE slug = ?` |
| 4 | Hollow goals "hear `serve` for free" | Emit `job_event($uid,'serve',$code,1,[...])` (jobs.php:311). It feeds callings, jobs and goals (P3) |
| 5 | Off switch by filtering listings | Create him with `npcs.active` = the setting, and resync on change (§5 P1). This covers jobs.php:113, townsfolk.php:39, book.php:111,114,216, gnome.php:255, place_ui.php:198, villagers.php:14 and folk_list.php:23 |
| 6 | Deal button only in folk.php | folk.php:81-84 **and** includes/villagers.php:144-148: when `$offer['kind']==='link'`, print `<a class="btn small" href=…>` and skip `traveller_dealt` |
| 7 | "on the Green" wording | Add gourmand branches at npc_life.php:162 (`npc_now`), :225 (`npc_routine`), :268 (`teahouse_rumours` "Over on the Green") and town.php:305 ("here, on the Green!"). Also town.php:248 (`$travHere` row: "is visiting" → "is at <camp>", linked to gourmand.php) and road_life.php:628 ("Travelling gourmand" → "Travelling food writer") |
| 8 | `npcs_at_spot` shows him for free | npc_life.php:122-137: skip `traveller==='gourmand'` in the `kind==='green'` loop, and add a branch outside that `if`: when `$spot['slug'] === gourmand_stop()['camp']` and he is active, add him |
| 9 | roadlife lint | tests/roadlife.php:380: add `'gourmand'` to `$allWho` |
| 10 | Feasts are free to add | tests/sinks097.sh:163,170 hard-code 15 `feast-%` recipes. Any new feast must update both checks. (This plan adds none.) |
| 11 | "Add to ci_suites.sh" | gourmand.sh installs itself, so add `gourmand` to `SELF_INSTALLING` (tests/ci_suites.sh:7) **and** to `DEFAULT_SUITES` (.github/workflows/ci.yml:60) |
| 12 | Schema | Use `$ID` for `user_id`, and put `UNIQUE (user_id, region, course)` **inline** in CREATE TABLE (like `traveller_deals`, schema.php:697), so tests/schema_compare.php (through upgrade_check.sh) matches fresh and upgraded installs |
| 13 | Pre-upgrade pots get quality 0 | In `cook_collect_one`, call `market_note_quality` **only if `(int)$pot['score'] > 0`** |
| 14 | "Bought goods never pass" | False: `item_quality.n` never shrinks. Fix `give_item` (§5 P0) and add its own test |
| 15 | "Serving leaves the average unchanged" | True only after fix 14 |
| 16 | **New:** `FRESH_USER_TABLES` (fresh_start.php:42) has no `item_quality` | Add `'item_quality' => 'user_id'`. Otherwise a fresh start keeps old quality rows: the same leak as #14 |
| 17 | **New:** "second-spoon via the decor list" | `DECOR` is stocked into Hedge & Hearth (yard.php:1051,1077) and `CURIO_DECOR` feeds the Curio Cabinet (sinks.php:66). Either list would make it buyable. Use the reward-decor pattern instead: insert-if-missing with `tradable 0`, like `festival_ensure_items()` (festival.php:40-46) and `hollowheart-tree` (journey.php:146) |
| 18 | `road_meet_candidates` start time | road_life.php:566: `$started = $s['starts'] ?? ($s['ends'] - TRAVEL_STOP_HOURS * 3600);`. Line 572 ("in") then works with `gourmand_stop` |
| 19 | `gourmand_force_date` like `hollow_season_forced` | The setting is `season_force`. `gourmand_force_date` is global (it moves him for everyone): use it for tests and admin preview only |
| 20 | Hook needs a `require` | market100.php is already loaded (bootstrap.php:56). crafting.php needs no require for it |
| 21 | Three race patterns | Pattern (c) only: transaction, `UPDATE users SET id = id WHERE id = ?`, then re-read. The UNIQUE claim insert is the backstop, as in `traveller_deal` (npc_life.php:310-354), which pays inside the transaction |
| 22 | Settings land in "Gardens & economy" | admin/settings.php:77 `$sectionOf`: add `'gourmand_' => 'World'` |
| 23 | OC and Mossbottom festival | OC's festival (day 28) is day 1 of its stay, and Mossbottom's stay is 1 day long. Festival friendship applies on the day itself, so nothing changes |

## 4. Data model and files

**Tables:**
```sql
-- in gourmand_schema($PK, $ID, $END), which returns [$t, $i, $c]; merged at the end of schema.php next to ppal_schema (schema.php:1476)
CREATE TABLE IF NOT EXISTS gourmand_ledger (
    id $PK,
    user_id $ID NOT NULL,
    region VARCHAR(4) NOT NULL,      -- region code, or 'ALL' for the finale row
    course VARCHAR(8) NOT NULL,      -- plate|pot|jar|grand, and claim rows table|gold|grandpay|finale (home in P2)
    best_q INT NOT NULL DEFAULT 0,
    spoons INT NOT NULL DEFAULT 0,
    paid INT NOT NULL DEFAULT 0,     -- highest spoon level paid (claim rows: 1)
    served INT NOT NULL DEFAULT 0,
    first_at DATETIME NULL,
    last_at DATETIME NULL,
    UNIQUE (user_id, region, course)
)$END
```
- `$c` gets `['cook_pots', 'score', 'INT NOT NULL DEFAULT 0']`. It is applied when `db_version` changes (bootstrap.php:86).
- **Per-tour claim:** existing `traveller_deals` (UNIQUE `user_id, npc_id, stop`; `stop` is VARCHAR(20)). Keys:
  - `Y-m|CODE|course`: the longest is `2026-10|MENA|grand`, 18 characters.
  - `Y-m|LT|seat`
- **NPC:** `npcs.traveller = 'gourmand'`, with `active` kept equal to `gourmand_open`. No new columns.
- **Settings:** two only, inline in the functions.php settings list next to `catfish_open` (functions.php:355):
  - `gourmand_open` (select, default `'0'`)
  - `gourmand_force_date` (text, default `''`)
  - Bars, pay, tips and the level (3) are consts in includes/gourmand.php.

**Data file `game/includes/data/gourmand.txt`.** Read with `stops_file_rows()` and a static cache. No pipes inside fields. Use ’.
```
# R|code|camp spot slug|taste name|camp line (Now tab)
# M|code|course plate|pot|jar|grand|variant 1..3|item slug|qty|ask line|margin note (journal, first spoon)
# B|beat key|tastes needed (0 = first visit)|title|text ({gnome} = gnome name)
```
Road arrival and departure use about 10 `road_meet.txt` rows with who=`gourmand`, plus the existing `@trav-in`/`@trav-out` lines. Example: `-|gourmand|“{name}! Have you eaten? You have the look of someone who hasn’t eaten properly.”`

**New `game/includes/gourmand.php`** (prefix `gourmand_`):

| Function | Does |
|---|---|
| `gourmand_open()` | `is_admin() \|\| setting('gourmand_open') === '1'` (like `catfish_open`, catfish.php:419) |
| `gourmand_now()` | `time()`, or noon (Hollow tz) of `gourmand_force_date` |
| `gourmand_stop(?int $ts)` | Returns `town, code, stop ("Y-m\|CODE"), tour, starts, ends, next, festival, long_table, camp`. Pure, as in §2.2 |
| `gourmand_rows()`, `gourmand_menu($code,$tour)` | The parsed file, and course => M row for this tour's variant |
| `gourmand_itinerary($tour)` | Camp dates (Menu tab). Next month's menu shows from day 20 |
| `gourmand_spoons($course,$q)`, `gourmand_word($n)` | Bars and words |
| `gourmand_dish_score($u,$stock)` | §2.3. Called from `cook_start` |
| `gourmand_serve($u,$course)` | `[ok,msg]`. The flow is in P1 |
| `gourmand_seat($u)` | Long Table seat claim |
| `gourmand_progress($uid)`, `gourmand_tastes($uid)` | Journal: Tastes x/14 · Spoons x/126 · Grand x/8 |
| `gourmand_beats($u)` | Which beats show. Plays the finale once (ledger `ALL/finale` claim) |
| `gourmand_titles($uid)` | Titles |
| `gourmand_sync_active()` | `UPDATE npcs SET active = ? WHERE traveller = 'gourmand'` |
| `gourmand_spoon_item()` | `second-spoon`, insert-if-missing (decor, `tradable 0`, ornament 1×1, 🥄) |
| `gourmand_schema($PK,$ID,$END)` | The table above |

**New page `game/gourmand.php`.**
- Tabs `?t=now|journal|menu|rules`.
- POST `do=serve&course=…` and `do=seat`, with CSRF. Each returns to its tab.
- Players get it only when `gourmand_open()` is true. Admins always do.
- Journal: 14 region cards (the Taste name is a silhouette until earned, 3 course slots with 🥄 marks and the best quality, a gold spoon for Grand), plus the beat texts unlocked so far, and the second spoon after `mid`.

**Edited files:**
- npc_life.php
- road_life.php
- data/road_meet.txt
- crafting.php
- schema.php
- functions.php
- admin/settings.php
- folk.php
- villagers.php
- friends.php
- town.php
- book.php
- inventory.php
- fresh_start.php
- layout.php
- tests/roadlife.php
- tests/market100.php
- tests/cook.sh
- tests/ci_suites.sh
- .github/workflows/ci.yml

**New files:**
- includes/gourmand.php
- gourmand.php
- data/gourmand.txt
- tests/gourmand.php
- tests/gourmand.sh

## 5. Phases

Run every suite one at a time, each on its own port (parallel runs give spurious INSTALL FAILED). Run `php -l` on every touched PHP file.

### P0: data, clock, the give_item fix (S, nothing visible)
**Tasks**
1. Write `data/gourmand.txt`: an R row for each of the 14 regions plus Mossbottom, M rows for v1 (existing slugs only), and B rows `hello first four mid home finale`.
2. Write includes/gourmand.php, pure parts only: `gourmand_now`, `gourmand_stop`, `gourmand_rows`, `gourmand_menu`, `gourmand_itinerary`, `gourmand_spoons`, `gourmand_word`.
3. **give_item quality fix** (inventory.php:11-17, the `$qty < 0` branch):
   - After a successful removal, if an `item_quality` row exists with `n > 0`, set `n = intdiv(min(n, before) * after, before)`, where `after` is the new qty (0 if the row was deleted) and `before = after - $qty`.
   - Cost: one SELECT, plus one UPDATE only when a row exists.
   - This is the only qty write path; no other `UPDATE user_items SET qty` exists.
4. Add `'item_quality' => 'user_id'` to `FRESH_USER_TABLES` (fresh_start.php:42).
5. Add `'gourmand'` to `$allWho` (tests/roadlife.php:380).

**Tests**
- New `tests/gourmand.php` (`php tests/gourmand.php GAME`). Schedule:
  - Every Hollow day of 2026–2028 maps to exactly one stop: day 1 is Mossbottom, days 2–27 follow `TOWN_FESTIVALS`, and day 28 to the end is OC.
  - Each stop's `ends` equals the next stop's `starts`.
  - A window that spans DST lasts 47 or 49 h.
  - February 2027 gives OC 1 day; February 2028 gives 2.
  - `festival` is true only on F.
  - Moving a festival day in a copy of the const moves the windows.
- Lint:
  - Every regions.txt code has one R row, a plate, a pot and a jar.
  - Every camp slug exists in `town_spots`.
  - Plates are the region's staple or uncommon produce.
  - Pots are snack or meal, jars are preserves, and grand rows are `feast-` slugs that exist.
  - Each region has a jar with `min(20,2·days)+3·min(4,kinds) ≥ 15` (SA and OC are exempt until the P2 rows exist).
  - Lines are 140 characters or fewer, with no straight apostrophes.
- Bars: 39/40/50/65 give 0/1/2/3 (plate), and 44/45/52/62 give 0/1/2/3 (jar; quick jars 41/42/49/55).
- **give_item test** (its own block in tests/market100.php after the "quality tracking" section, line 165):
  1. Harvest-note 3 at q70, remove 3, buy 3: `market_stack_q` = 35.
  2. 4 at q80 plus 4 plain, remove 4: n = 2, average unchanged at 58 (±1).
  3. Fresh start clears `item_quality`.
- **Re-run:** `market100 roadlife cook pantry craft trade rewards fresh_hold jobs eggs110 villagers`. Then run the full `tests/ci_suites.sh`, because give_item is the hot path.

### P1: Pomeroy, off by default (M)
**Tasks**
1. **NPC.**
   - Add `TRAVELLERS['gourmand'] = ['Pomeroy Crumbworth','Dormouse','Fussy','A travelling food writer with a napkin always tucked in. Tours the Hollow’s festivals and asks gnomes to share their cooking. Rates in spoons.',0]` (npc_life.php:19).
   - In `ensure_npc_lives` (npc_life.php:58-70), insert him with `active = setting('gourmand_open')==='1' ? 1 : 0`. It already runs on upgrade (bootstrap.php:166) and in seed.php:178.
   - Add the sync line at admin/settings.php:64: `if (isset($changes['gourmand_open'])) { require_once __DIR__ . '/../includes/gourmand.php'; gourmand_sync_active(); }`.
2. **Dispatch.**
   - `traveller_stop()` (npc_life.php:146): first line `if (($npc['traveller'] ?? '') === 'gourmand') { require_once __DIR__.'/gourmand.php'; return gourmand_stop($at); }`.
   - `npc_here()` (friends.php:85-91): return true for the gourmand.
   - `traveller_offer()` (:286): return `['kind'=>'link','url'=>'gourmand.php','label'=>'🍽️ Serve a course','stop'=>'']`.
   - `traveller_deal()` (:310): refuse him.
   - Make the wording and spot fixes from §3 rows 6–8 and 18.
   - Add a menu rumour to `teahouse_rumours`, e.g. "Pomeroy’s asking for jars of Kimchi in Blossomreach. Five days in the jar, mind."
3. **Settings and admin.**
   - Add 2 settings in functions.php (next to line 355).
   - Add `$sectionOf` `'gourmand_' => 'World'`.
   - Add `gourmand.php` to `AJAX_PAGES` (layout.php:10) and a nav tile under Out & about (layout.php:653).
4. **Dish score.**
   - Add the `cook_pots.score` column through `$c`.
   - `cook_start` (crafting.php:345): compute `gourmand_dish_score($u,$stock)` after `craft_stock` (line 356) and before the `give_item` loop (line 382). Add `'score'` to the `cook_pots` insert (line 399).
   - `cook_collect_one` (:417): right after `give_item($uid, output, $dishes)` (line 438), `if ((int)$pot['score'] > 0) market_note_quality($uid, (int)$r['output_item_id'], $dishes, (int)$pot['score']);`.
   - Check the path with `kitchen_pots = 0` (instant cooking, crafting.php:226).
5. **Serve** (`gourmand_serve`):
   1. Check `gourmand_open`, guest, level 3, region (not hub), today's M row, held qty and the spoons.
   2. Begin a transaction and lock the user row.
   3. Insert the `traveller_deals` claim; a duplicate means rollback and "Already served this month."
   4. `give_item(-qty)`; false means rollback.
   5. Upsert the ledger, then pay the spoon levels or the tip.
   6. Insert the table and gold claim rows when they first qualify, and pay them.
   7. `friend_add(+5/+10, ×2 on the festival day)`.
   8. Commit.
   9. Show the `prize()` card: "Pomeroy tucks in his napkin, lifts his spoon…", the verdict, and the nap line at 3 spoons.
6. **Seat and finale.**
   - `gourmand_seat` on day 1 counts the previous tour's claims.
   - `gourmand_beats` on the gourmand.php / folk page load: finale scene plus rewards.
   - Create `second-spoon` with `gourmand_spoon_item()`.
7. **Titles.** `gourmand_titles($uid)` merged at book.php:22 and :248, next to `stop_titles`.
8. **Fresh start.** `FRESH_USER_TABLES += 'gourmand_ledger' => 'user_id'`. `traveller_deals` is already there.
9. **Schema.** Merge `gourmand_schema` at the end of schema.php. Only one agent edits schema.php.
10. **Release prep.** Write the news entry under a "next version" heading. Do not touch `APP_VERSION` until Josh names the version. Then run `tools/check_versions.sh`, the full zips and `tests/manifests/<next version>.txt`.

**Tests**
- New **`tests/gourmand.sh`** (self-installing, modelled on tests/calling.sh):
  - Pages: `gourmand.php` (every tab), `town.php?spot=<numeric camp id>`, `folk.php?id=<pomeroy>` and `villagers.php` all return 200, with no new PHP log lines.
  - The off switch hides him from folk and villagers lists for players, but not for admin. Toggling the setting flips `npcs.active`.
  - Serving works from anywhere in region R on a **non-window** day. Serving R from another region is refused.
  - The same course twice in one tour is refused, and nothing is taken. Next month (force date) pays the tip only. 0 → 3 spoons pays 240 Petals.
  - Full and Golden tables pay once.
  - On a festival day, friendship is +10 and Petals are unchanged.
  - The alt guard: a bought stack scores 35 and is refused.
  - **Race:** two concurrent curl POSTs serve once.
  - Guests are refused.
  - The seat works on day 1 only with 7 or more serves.
  - The finale fires on the next page load after the 14th Taste, and only once.
  - Fresh start clears the `gourmand_ledger` rows and his `traveller_deals` rows.
  - A road meet shows on the road into the camp town at `starts + 1h`, and not at `+3h`.
- **tests/gourmand.php additions:**
  - A dish from all-plain ingredients at Kitchen III scores 50 or less.
  - `cook_start` writes a score of at least 1, and `cook_collect_one` writes `item_quality`.
  - A pot with score 0 writes no quality.
  - All of this also with `kitchen_pots = 0`.
- **tests/cook.sh:** one check that the `cook_pots.score` column exists and is above 0 after a cook.
- **CI lists:** add `gourmand` to `SELF_INSTALLING` (tests/ci_suites.sh:7) and to `DEFAULT_SUITES` (ci.yml:60).
- **Re-run:** `gourmand roadlife roadtext roads town villagers folkoverlay friends cook pantry craft market100 calling jobs contest yard fresh_hold rewards help`, plus `tests/upgrade_check.sh` (schema_compare, fresh vs upgrade) and the CI MySQL job.

### P2: his own cooking (M, mostly data)
**Tasks**
- Add 14 Pot recipes and 2 jars to `recipes.txt`. `ensure_crafts` → `import_recipes` adds the missing slugs, and recipes are learned automatically once the ingredients are seen (crafting.php:122):
  ```
  wild-rice-hotdish|Wild Rice Hotdish|wild-rice:2,chanterelle:1,onion:1,celery:1|hardiness:3,lore:1|300|11|Wild rice and chanterelles baked under a lid until the kitchen smells of the woods.|meal|15
  bean-tamales|Bean Tamales|corn:3,black-bean:2,chili-pepper:1|grit:3,charm:1|300|11|Little parcels of corn dough and beans, steamed in their husks. Unwrap with ceremony.|meal|15
  rice-and-peas|Rice and Peas|rice:2,pigeon-pea:2,coconut:1|grit:2,nimble:2|240|10|Rice simmered in coconut milk with pigeon peas. The Isles call beans peas and nobody argues.|meal|15
  quinoa-soup|Quinoa Soup|quinoa:2,potato:2,carrot:1|hardiness:3,sense:1|240|10|A highland soup for thin air and cold evenings. Potato number one of a hundred.|meal|15
  colcannon|Colcannon|potato:3,kale:1,leek:1|hardiness:3,luck:1|240|11|Buttery mash with greens folded through. Hide a coin in it for luck.|meal|15
  artichoke-fava-stew|Artichoke and Fava Stew|artichoke:2,fava-bean:2,lemon:1|sense:3,charm:1|240|10|Spring artichokes and broad beans with lemon. Eat it slowly, in the sun.|meal|15
  buckwheat-kasha|Buckwheat Kasha|buckwheat:3,chanterelle:1,onion:1|hardiness:2,lore:2|240|10|Toasted buckwheat with mushrooms and onion. Steppe grandmothers will tell you it’s wrong.|meal|15
  falafel|Falafel|chickpea:3,parsley:1,cumin:1|grit:2,sense:1|180|7|Crisp green-hearted chickpea balls. Best eaten standing up in a bazaar.|snack|3
  egusi-soup|Egusi Soup|egusi:2,okra:2,spinach:1|grit:3,hardiness:1|300|11|Ground melon seeds thicken a rich green soup. A Greatcanopy Sunday.|meal|15
  sukuma-wiki|Sukuma Wiki|collard:3,onion:1,tomato:1|hardiness:2,nimble:2|240|10|Collards cooked with tomato and onion. The name means “push the week”, and it does.|meal|15
  khichdi|Khichdi|mung-bean:2,rice:2,turmeric:1|hardiness:2,lore:2|240|10|Rice and yellow lentils cooked soft. The dish for a tired gnome.|meal|15
  red-bean-buns|Red Bean Buns|adzuki:2,wheat:2,garden-honey:1|charm:2,luck:1|180|8|Soft white buns with sweet adzuki paste inside. Picnic rules: one each, then another.|snack|3
  kangkong-stir-fry|Kangkong Stir-fry|kangkong:3,garlic:1,chili-pepper:1|nimble:2,sense:1|180|7|Water spinach flashed in a hot pan with garlic. Done before you’ve found a plate.|snack|3
  palusami|Palusami|taro:2,coconut:2,onion:1|hardiness:3,charm:1|300|11|Taro and coconut cream baked in a parcel. The Coralscatter’s Sunday lunch.|meal|15
  chicha|Chicha|corn:3,quinoa:1|grit:1,luck:1|1080|5|A cloudy, gently fizzing highland drink of corn and quinoa. Five days in the jar.|preserve|7200|3
  poi|Poi|taro:5|hardiness:2|1080|5|Pounded taro left to sour for a week. Purple, smooth and an acquired taste worth acquiring.|preserve|10080|3
  ```
- Add the v2 Pot M rows, plus chicha and poi as SA and OC jar variants. Remove the SA/OC lint exemption.
- Grand course for the 8 feast regions (pot bars, Kitchen III, after that region's first Taste), with the `grandpay` claim and the Grand Diner title.
- Home Plate (`home` beat, at 10 Tastes): a one-off. Any Pot dish that uses a crop from your home region, at 2 spoons, from anywhere. Ledger row `HOME/home`.
- **No new feasts.** If any are added later, update tests/sinks097.sh:163,170.

**Tests**
- tests/gourmand.php: every new recipe ingredient slug exists after install, and the 3-spoon jar lint passes for all 14 regions.
- gourmand.sh: a Grand serve is refused below Kitchen III.
- **Re-run:** `gourmand craft cook pantry eggs110 sinks097 jobs`, plus upgrade_check.sh.

### P3: hooks (S, optional)
**Tasks**
- In `gourmand_serve`, call `job_event($uid,'serve',$code,1,['course'=>…,'spoons'=>…,'region'=>…])` (jobs.php:311).
- Add `'serve'` to `CALLING_EVENT_KINDS` (calling_quests.php:24) and the optional Brewroot row: `T|brewroot-2|event|serve|spoons>=2|5|Serve Pomeroy 5 courses at two spoons or better`.
- Add `serve` to the Hollow goal pool only if wanted (`hollow_goal_adds` counts only pool kinds; hollow_goals.php:134-141).
- Admin read-only preview: the camp schedule and menus for a chosen date.

**Tests**
- calling.sh: a `serve` event advances the task.
- jobs.sh is unchanged.
- **Re-run:** `gourmand calling jobs mentors120`.

## 6. Art (placeholders first: red border plus "THIS IS PLACEHOLDER". Cost estimate before any art at scale)

Write the specs in `aseprite-source/img-redraw-full/specs/ph/`, in the existing spec format (`# ph/<slug>`, then canvas, subject, must-read-at-16px, distinct, parts, joins, face, notes).

| Phase | Spec file | Canvas / mode | Notes |
|---|---|---|---|
| P1 | `npc-pomeroy-crumbworth.md` | 80×100 bust (halo 3, outline 1px, bleed off bottom), like `npc-wren-thimblewick.md` | Round dormouse, mustard waistcoat, napkin tucked at the chin, silver spoon on a chain. The napkin is the silhouette |
| P1 | `second-spoon.md` | 64×64 sticker | A silver spoon planted upright in a small terracotta flowerpot. Must not read as `flower-pot.md` |
| P1 | `nav-gourmand.md` | 64×64 icon | Nav tile under Out & about: a crossed spoon and napkin |
| P2 | `wild-rice-hotdish.md`, `bean-tamales.md`, `rice-and-peas.md`, `quinoa-soup.md`, `colcannon.md`, `artichoke-fava-stew.md`, `buckwheat-kasha.md`, `falafel.md`, `egusi-soup.md`, `sukuma-wiki.md`, `khichdi.md`, `red-bean-buns.md`, `kangkong-stir-fry.md`, `palusami.md`, `chicha.md`, `poi.md` | 64×64 sticker, like `apple-crumble.md` | 16 item icons. None exist yet |

**Not needed:**
- a camp sprite (he shows through the `npcs_at_spot` portrait)
- 14 Taste banners (the Almanac chapter was dropped; Journal cards reuse the existing `banner-<code>`, with an emoji fallback for CB, SA, MENA and OC)
- a spoon icon (🥄)

## 7. Still undecided

1. **Festival bonus place:** should the festival-day friendship double need the gnome to be at the camp spot, or anywhere in the region? This plan says anywhere, following decision 4.
2. **Tip XP on festival day:** Josh marked doubling it (8 → 16) as optional. This plan leaves it off.
3. **Long Table content:** this plan keeps the seat only and drops late plates (redundant now). Confirm, or cut the Long Table entirely.
4. **give_item fix sign-off:** item #14 still touches the hot path. Josh said yes; confirm that proportional `n` scaling (not "clear at 0") is the version he wants.
5. **second-spoon:** this plan uses the reward-decor pattern (§3 #17), not the shop decor list that decision 13 named. Confirm.
6. **One "The Gourmand" How-to page:** the review offered it. This plan uses the Rules tab only, because a page raises everyone's page total even while the feature is off.
7. **The 62 jar bar:** hummus-jar and pickled-okra need lucky rolls to reach 62. Keep 62, or lower the jar 3-spoon bar to 60?
8. **Version number:** held until Josh names it.
