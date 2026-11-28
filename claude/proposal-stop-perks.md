# PROPOSAL: Lasting marks (rest-stop perks rework)

Status: proposal only, no game code changed. 2026-11-27.
Audit 2026-11-27: all 540 perks (this file + regions A, B, C) checked and fixed by `python3 claude/tools_audit_stop_perks.py` (corrections in `claude/tools_audit_stop_perks_fixes.py`); rules P2 to P4 added to 4.1; section "Hook list" before section 9.
Impact pass 2026-11-27: every perk has an estimated boost per game day (`proposal-perk-impact.md`, `.csv`); 312 of the 540 were below a meaningful amount and have a wider trigger or a bigger size (`RAISES` in the corrections table; 27 of them in this file); rule P5 added to 4.1.
Updated 2026-11-27 for Josh's decisions (master section 14): the Maplewold has 12 villages (Cattailmere in the Fens, Granitegate on the Ridge), so the set is **18 stops, 54 perks**; sections 4, 4.1, 5 and 7 carry the new numbers. Older text below that says 16 / 48 (the pass 2 notes and review log) is history.
Superseded in part by `PROPOSAL-HOLLOW-MASTER.md`: section 3 and 7.3 (pace 6 to 10 visit-days per bar, counted in game days), section 7.7 and 12 (rulings 8, 9: no weeks or months; old perks end on each gnome's game date).
Read for this: `docs/stop-perk-ideas.md`, `includes/player_perks.php`, `stop_living.php`, `stops.php`, `stop_adopt.php`, `data/stops.txt`, `stop_tiers.txt`, `stop_act_state.txt`, the four `stop_acts*.txt` files (860 acts), `claude/proposal-story-1-base.md`, `claude/proposal-maplewold-bands-and-seals.md`, `claude/route-list.md`.

Pass 2 (same day): the full act-to-bar table is generated (`claude/tools_gen_stop_act_bars.py` writes `claude/proposal-stop-act-bars.txt`), the numbers below are from that run, and the doc was checked against the code. See the review log at the end.

Three things found while reading, which change the plan:
- **The Maplewold roads have 18 stops** (16 before the two new villages; master section 14): 15 in the Maplewold itself (1 town, 3 road villages, 9 off-road villages, 2 havens; `zones.txt` NA = 10 villages today, + Cattailmere and Granitegate when the two new zones are built) and 3 border villages at the far end of the roads out, which belong to the next region (Larkbrook = Maizehollow, Windbottom = Mistmoor, Honeythorpe = Blossomreach; `claude/route-list.md` lists their own routes under those regions). All 18 are done below: 54 perks (45 in the Maplewold, 9 at the border villages, which count toward their own region).
- **The town and the two havens are not stops in code today.** `stop_do` (`stops.php:813`), `stop_perk_data` and `stop_perk_body` (`stop_living.php:339, 360`) and `stop_adopt` (`stop_adopt.php:236`) all require `kind = 'village'`, and `stop_assign_all` (`stops.php:386`) gives a stop type to villages only. The town is `market`, the havens are `haven` (and the Sugar Shack is closed until its Journey chapter). They need a gate change and a stop type (section 8) before they can have bars.
- **Acts can already be done only once a game day per stop** (2.8.64). So "repeats small" is defined per bar per day, not per act (section 2).

## 1. The rule

| | Now | Proposed |
|---|---|---|
| Full bar | Perk for 7 game days, random from a pool, max 3, bar restarts at 30 | **Lasting mark**: the bar stays full and its perk is on for good |
| Whose | Player, works everywhere | Player, per stop, per bar. Works everywhere unless the perk text names a place |
| Which perk | Seeded pick from 9 | Fixed: that stop's own perk for that bar. Every stop has 3 perks no other stop has: hand-written (section 5) or its type's template made for that stop (section 6) |
| Limit | 3 at once | None. Balance comes from scope and family caps (section 4), set up so every mark adds something (4.1) |
| Decay | 3 a day | **None (recommended).** See below |

**Bars while filling: remove decay.** A bar is a high-water mark, like Standing in the story proposal. Reasons: the game is at leisure with no fail states; a bar now takes days of visits, so losing 3 a day at 18 stops punishes travelling; and "latched" plus "decays" is two rules where one will do. Kept as a setting (`mark_decay`, default 0) so it can be switched on for unfilled bars only. A filled bar never moves.

After a bar is full: its acts still pay their normal rewards. Each one adds 1 to a "kept up" count shown on the plaque (flavour only). The notice board's "Needs help" lists unfilled bars only.

## 2. Acts feed bars: the rules

Every act feeds one bar. Some feed a second at half. The generator script reads the act files and writes `data/stop_act_bars.txt` (`slug | stop type | bar | second`). Steps, in order, first match wins.

**Done (pass 2):** `python3 claude/tools_gen_stop_act_bars.py` implements steps 0 to 4 exactly and writes `claude/proposal-stop-act-bars.txt` (860 acts, 1511 rows, `slug | stop type | first bar | second bar or - | base points`; an `any` act is one `*` row when all 12 types agree, else 12 rows). It is deterministic; the game does not read it yet.

**Step 0. Override.** A row in `stop_act_state.txt` "moves" names the bar(s), first listed = first bar, second listed = second bar (only `host_table` names two). Its numbers are ignored; points come from the formula. 186 acts have such a row today.

**Step 1. Tags.** As `stop_act_tags` (`stops.php:501`, words in `STOP_TAG_WORDS`), with two fixes. (a) A tag word matches at the start of a whole word: the word itself, the word plus a plain ending (s, es, ed, ing, er, y, ies), or a compound that goes on with 4 or more letters ("bakehouse"). So "pie" and "pies" count, "pier" does not (today `str_contains` counts "pier", "spiel" and "copied" as pie). (b) Tags from the name rank before tags from the blurb. Inside each, this order: `fix > craft > cook > gather > tend > trade > play > lore > rest`. Add `fry, broth, cordial, porridge, pickle` to the cook words. Bars: fix, craft = Repairs. cook, gather, tend = Larder. trade, play, lore, rest = Cheer. "Makes food" (step 2, craft) = the output slug is a dish in `recipes.txt`, or `garden-honey`.

**Step 2. First bar, by act kind.**

| Kind | First bar |
|---|---|
| craft | Larder if it has a cook tag or makes food, else Repairs |
| tend | Bar of its first tag if that is fix, craft, cook, gather or tend. Else the type's lean |
| rest | Larder if the NAME has a cook tag (a table, a supper). Else Cheer |
| lore, gossip | Cheer |
| buy, snack, swap, seedswap | Larder |
| contest, pick, power, collect | Cheer, unless step 3 moves it |
| check | Bar of its first tag. No tag: the type's lean |
| thread | The type's signature bar |
| anything else (default) | The type's lean |

**Step 3. Stop type.** Signature = the bar the type is proud of. Lean = where untagged work goes. Moves apply to game kinds only. Share = how the acts that can appear at each type split by first bar (full script run; an act listed for several types counts at each, `any` acts count at all 12: 1621 act-type pairs). "Fixed" = the same with the 60 suggested overrides applied (below). "2nd" = acts with a second bar.

| Type | Signature | Lean | Moves | Acts | Share R/L/C | Fixed R/L/C | 2nd |
|---|---|---|---|---|---|---|---|
| market | Larder | Larder | pick > Larder, power > Repairs | 160 | 12/45/42 | 14/47/39 | 52% |
| mill | Larder | Repairs | power > Repairs | 106 | 28/45/26 | 31/43/25 | 29% |
| inn | Cheer | Larder | power > Repairs, collect > Larder | 156 | 13/41/46 | 15/40/46 | 37% |
| shrine | Cheer | Repairs | pick > Larder | 103 | 25/17/57 | 23/16/61 | 25% |
| jetty | Larder | Repairs | power > Larder, pick > Larder | 137 | 28/27/45 | 25/27/48 | 34% |
| herb | Larder | Larder | collect > Larder | 134 | 7/62/31 | 6/64/30 | 32% |
| workshop | Repairs | Repairs | power > Repairs, pick > Repairs | 110 | 51/15/35 | 55/13/32 | 41% |
| orchard | Larder | Larder | power > Larder | 153 | 8/55/37 | 7/54/39 | 37% |
| ferry | Repairs | Repairs | power > Repairs, pick > Larder | 128 | 32/21/47 | 30/19/51 | 34% |
| tower | Repairs | Larder | power > Repairs, pick > Larder | 141 | 16/20/65 | 16/20/65 | 30% |
| spring | Cheer | Repairs | pick > Larder | 107 | 14/31/55 | 11/32/57 | 40% |
| camp | Cheer | Larder | power > Repairs, pick > Larder | 186 | 15/33/52 | 13/34/53 | 35% |
| all | | | | 1621 | 20/35/45 | 19/35/46 | 36% |

Pass 1 had market 20/37/43, herb 16/55/29, orchard 15/47/38: the real Repairs share there is 7 to 12%, so those three types lean even harder on the answer acts. Tower stays the most Cheer-heavy (65%).

The thin bar at each type is covered by the four "answer" acts at every stop (`mend_board`, `tidy_yard` Repairs; `fill_shelf` Larder; `hang_lanterns` Cheer). Change their needs from `meter<60` to "bar not full", so every unfilled bar has a feeder every day.

**Step 4. Second bar (half points).** First that applies:
1. buy, snack, swap, seedswap: Cheer.
2. Moved in step 3: the bar it was moved from (Cheer).
3. Its next tag (not `rest`) whose bar differs from the first bar.
4. contest, pick, power, collect: the type's lean, if different.
5. lore, gossip, thread: never. Otherwise none.

Rule 5 is checked first in practice: lore, gossip and thread never get a second bar. Result (script run): 25% (shrine) to 52% (market) of acts per type have a second bar, 36% overall.

**Points.** `pts = max(1, floor(B x D x W x F)) + V`

| Part | Value |
|---|---|
| B, by energy cost | 0 energy = 6, 1 = 9, 2 = 12, 3 or more = 15 |
| D, nth act today at this stop with this first bar | 1st = 1, 2nd = 0.5, 3rd and later = 0 (so 1 point) |
| W | win or no dice = 1, lose = 0.5 |
| F | festival day x2, answer act x1.5 |
| V, variety | +2 if this act KIND has not been done at this stop today |
| Full round | The first time all three bars are fed in a day at a stop: +5 to the lowest unfilled bar |
| Second bar | floor(pts / 2), least 1. Does not count for D |
| Same act again the same day | Not possible now. If that rule is ever lifted: 1 point |

A bar is 100 points. One day at a workshop: Mend something 11 R, Plane the boards 6 R + 3 C, Strike the anvil bell 3 R + 1 C, Tales by the forge 8 C, Forge stall 8 L + 4 C, full round +5 L. Day total R 20, L 13, C 16. So **about 5 to 8 visit-days per bar** (100 / 20, 13, 16), and all three bars at one stop in about the same days if you spread your acts. First mark in the first week; all 54 on the Maplewold roads is 34 to 51 game days (master section 3).

**Worked examples** (real acts; points = first of that bar that day, before variety).

| Type | Act | Kind, energy | Why | First bar | Second |
|---|---|---|---|---|---|
| market | Haggle at the stalls | check 0 | tag trade | Cheer 6 | |
| market | Weighing house stall | buy 0 | kind | Larder 6 | Cheer 3 |
| market | Patch the awnings | tend 1 | tag fix | Repairs 9 | Larder 4 |
| market | Sniff the jars | pick 0 | type move | Larder 6 | Cheer 3 |
| market | Heave the hay bale | power 1 | type move | Repairs 9 | Cheer 4 |
| mill | Turn the millstone | check 2 | tag cook | Larder 12 | |
| mill | Fly the sails | check 1 | override row | Repairs 9 | |
| mill | Compost swap | swap 0 | kind | Larder 6 | Cheer 3 |
| mill | Bakehouse table | rest 0 | cook in name | Larder 6 | |
| inn | Tall tales by the hearth | lore 0 | kind | Cheer 6 | |
| inn | Late supper by lamplight | buy 0 | kind | Larder 6 | Cheer 3 |
| inn | Snail cards | pick 0 | kind, tag gather ("Pick your card") | Cheer 6 | Larder 3 |
| inn | Stock the root cellar | tend 1 | override row | Larder 9 | |
| shrine | Sit in silence | rest 0 | kind | Cheer 6 | |
| shrine | Rake the gravel | tend 1 | no tag, lean | Repairs 9 | |
| shrine | Tend the moss | check 1 | tag tend | Larder 9 | |
| shrine | The politest bow | contest 0 | kind, lean second | Cheer 6 | Repairs 3 |
| jetty | Twist rope | check 1 | tag fix | Repairs 9 | |
| jetty | Skim stones | power 0 | type move | Larder 6 | Cheer 3 |
| jetty | Cattail fritters | craft 1 | tag cook | Larder 9 | |
| jetty | Loon-call contest | contest 0 | kind, lean second | Cheer 6 | Repairs 3 |
| herb | Herbal tea tasting | buy 0 | kind | Larder 6 | Cheer 3 |
| herb | Leaf shapes | collect 0 | type move | Larder 6 | Cheer 3 |
| herb | Train the hop bines | tend 1 | override row | Larder 9 | |
| herb | Sit by the drying rack | rest 0 | kind | Cheer 6 | |
| workshop | Mend something | check 1 | tag fix | Repairs 9 | |
| workshop | Plane the pine boards | craft 1 | kind, tag play | Repairs 9 | Cheer 4 |
| workshop | Strike the anvil bell | power 0 | type move | Repairs 6 | Cheer 3 |
| workshop | Tales by the banked forge | lore 0 | kind | Cheer 6 | |
| orchard | Gather herbs | check 1 | tag gather | Larder 9 | |
| orchard | Rebuild the zigzag fence | tend 1 | tag fix | Repairs 9 | |
| orchard | Windfall toss | power 0 | type move | Larder 6 | Cheer 3 |
| orchard | Which hole pops? | pick 0 | kind, lean second | Cheer 6 | Larder 3 |
| ferry | Skim stones | power 0 | type move | Repairs 6 | Cheer 3 |
| ferry | Toll-house stall | buy 0 | kind | Larder 6 | Cheer 3 |
| ferry | Legends of the Lost Lantern | lore 0 | kind | Cheer 6 | |
| ferry | Stare down the gull | contest 0 | kind, tag fix | Cheer 6 | Repairs 3 |
| tower | Dress stone | check 2 | tag craft | Repairs 12 | |
| tower | Haul the beacon basket | power 1 | type move | Repairs 9 | Cheer 4 |
| tower | Spyglass stall | buy 0 | kind | Larder 6 | Cheer 3 |
| tower | Toboggan race | contest 0 | kind, lean second | Cheer 6 | Larder 3 |
| spring | Scrub the bath stones | tend 1 | no strong tag, lean | Repairs 9 | |
| spring | Boil the perfect egg | check 0 | tag cook | Larder 6 | |
| spring | Which egg is done? | pick 0 | type move | Larder 6 | Cheer 3 |
| spring | Skim stones | power 0 | kind, tag craft | Cheer 6 | Repairs 3 |
| camp | Campfire story | lore 0 | kind | Cheer 6 | |
| camp | Rebuild the zigzag fence | tend 1 | tag fix | Repairs 9 | |
| camp | Boil an egg | buy 0 | kind | Larder 6 | Cheer 3 |
| camp | Toboggan race | contest 0 | kind, lean second | Cheer 6 | Larder 3 |

Skim stones shows the stop type at work: Larder at a jetty, Repairs at a ferry, Cheer at a spring.

All 49 worked examples above match the script's output (checked in pass 2). "Bakehouse table" only reaches Larder because of the compound rule in step 1.

Known noise: word tags misfire. With `fry` added, "Fry the fiddleheads" is Larder; "Make an offering" still reads as craft (Repairs). The script prints the share table and runs a name check that flags 41 acts whose first bar came from a word tag but whose name reads as another bar. A read of all 349 tag-driven rows gives **60 suggested overrides (7% of the 860 acts)**, appended to `proposal-stop-act-bars.txt` in `stop_act_state.txt` format (`slug|-|meter:<bar>+10`). Typical ones: Make an offering, Make a wish at the pool, Wish in the flour loft (Repairs or Larder, should be Cheer); Cast a line, Listen at the hives, Grade the rock salt (Cheer, should be Larder); Grease the great cogs, Clear weed from the millrace, Sweep the leaves, Rebuild the drystone gap (Larder, should be Repairs); Count the gecko's calls, Fold paper birds, Wassail the trees (Repairs, should be Cheer). They are not applied in the rows; Josh accepts them by pasting them into `stop_act_state.txt`.

## 3. Perk rules

- Size: +1% or +2%, or +1 of a small unit, or one small convenience. Nothing else.
- A perk row is `family | size | scope`. Scope narrows where it counts and reuses the act "when" grammar: `dp=` day part, `we=` weather, `se=` season, plus `land=`, `region=`, `type=` (stop type), `from=` (at this stop, or a walk that starts here), `to=` (a walk that ends here, NEW), `items=` (item group, or `local:<stop>` = that stop's local crops from `stop_local_crops()`).
- Two classes (4.1): **world perks** (no `from=`/`to=`/`region=`/`items=local:`) add up across the world and the family cap cuts the total; **place perks** (those four scopes) count only at their place and are never cut by another stop's mark.
- Info and looks perks (flags) are only for hand-written stops. Type templates (section 6) are place perks made unique to each stop, so a second inn is never a blank and never a copy.

## 4. Effect catalogue and caps

29 families. "Cap" = the most all **world** perks of the family can add together. "NA world" = world perks in the 54 Maplewold-road perks (count, summed size) = how much of the cap the Maplewold set uses. "NA place" = Maplewold place perks (count). "Tmpl" = type templates (section 6) feeding the family; they are all place perks. World today: 178 stops (146 villages, 14 towns, 18 havens; checked against `zones.txt`, `towns.txt`, `landmarks.txt`) = 534 marks; with the two new Maplewold villages 180 stops (148 villages) = 540 marks; 162 stops outside the Maplewold roads either way, about 13 per type. Hooks were checked against the code in pass 2 (file:line = the line the bonus goes on; **NEW** = no such hook yet).

| # | Family | Effect | Hook | Per perk | **Cap** | NA world | NA place | Tmpl |
|---|---|---|---|---|---|---|---|---|
| F01 | sell | Shop sell price | `world.php:519` `sell_price_with_bonus` (from `sell_to_shop`, `:536`) | +1% or +2% | **+5%** | 2 (3) | 0 | 1 |
| F02 | buy | Shop prices | `world.php:415` in `shop_price` (`:392`) | -1% (-2% place) | **-5%** | 1 (1) | 0 | 2 |
| F03 | xp | Gnome XP | `gnome.php:308` in `add_xp` (`:303`) | +1% or +2% scoped | **+5%** | 2 (3) | 0 | 3 |
| F04 | gxp | Garden XP | `gnome.php:355` `add_garden_xp` | +1% (+2% place) | **+5%** | 1 (1) | 0 | 1 |
| F05 | walk | Walk time | `adventure.php:192` in `route_walk_minutes` | -1% or -2% | **-6%** | 2 (3) | 1 | 2 |
| F06 | cook | Pot time | `crafting.php:465` in `cook_seconds` | -1% or -2% scoped | **-6%** | 2 (4) | 0 | 2 |
| F07 | meal | Energy from dishes | `gnome.php:625` in `eat_item` | +1% or +2% scoped | **+5%** | 1 (2) | 0 | 1 |
| F08 | buff | Boost length | `gnome.php:439` in `buff_minutes` | +2% | **+8%** | 2 (4) | 0 | 1 |
| F09 | heal | Healing | `health.php:130` in `hp_heal_points`; `adventure.php:1280` `rest_heal`; stop rest acts `stops.php:969` | +2% | **+8%** | 2 (4) | 0 | 3 |
| F10 | harvest | Chance of one extra | `garden_logic.php:1598` in `do_harvest` | +1% or +2% | **+4%** | 2 (4) | 0 | 1 |
| F11 | gather | Chance of one extra find | `gathering.php:78` `gather_on_walk`, `:181` `gather_here` | +1% or +2% | **+4%** | 1 (2) | 1 | 1 |
| F12 | water | Watering lasts | `garden_logic.php:865` `water_seconds` | +2% | **+8%** | 1 (2) | 0 | 1 |
| F13 | seed | Chance of a seed back | `garden_logic.php:1634` in `do_harvest` | +1% (+2% place) | **+4%** | 1 (1) | 0 | 1 |
| F14 | friend | Chance of +1 friendship | `friends.php:56` `friend_add` (the extra roll is NEW inside it) | +2% | **+8%** | 1 (2) | 0 | 3 |
| F15 | stopcoin | Coins from stop acts | `stops.php:670` `stop_rewards` | +2% | **+8%** | 1 (2) | 0 | 2 |
| F16 | check | Stop check chance | `stops.php:742` `stop_check` (roll at `:748`) | +1% (+2% place) | **+4%** | 1 (1) | 0 | 1 |
| F17 | pest | Pest chance | `garden_fx.php:281` `pest_chances` | -2% | **-8%** | 1 (2) | 0 | 1 |
| F18 | travel | Fast travel cost | `world.php:282` in `travel_to` | -1% (-2% place) | **-5%** | 1 (1) | 0 | 0 |
| F19 | spot | Spot hidden things | `explore.php:222` in `explore_deeper` | +1% (+2% place) | **+4%** | 1 (1) | 0 | 1 |
| F20 | hp | Max health | `adventure.php:81` in `gnome_combat` (read by `health.php:46` `hp_max`) | +1 point | **+3** | 0 | 1 | 0 |
| F21 | torch | Delve torch steps | `delve_v2.php:37` `dv2_fuel` | +1 step | **+3** | 0 | 1 | 0 |
| F22 | restenergy | Energy from rest acts | `stops.php:969` `stop_do`, case `rest` | +1 | **+2** | 2 (2) | 0 | 1 |
| F23 | trailseed | Seed found on fast travel | `world.php:292` in `travel_to` | +1% (+2% place) | **+4%** | 1 (1) | 0 | 0 |
| A1 | dayfree | A first action of the day is free or 1 cheaper | `garden_logic.php:554` `garden_claim_free_water`; `:1317` weed in `garden_action`; `adventure.php:208` in `route_energy`; `world.php:283` in `travel_to` | 1 a day | one charge per perk | 3 | 0 | 1 |
| A2 | dayback | Something lost comes back once a day | planting: **NEW** in `garden_action` (plant); check re-roll: `stops.php:748`; staff wear: `adventure.php:237` in `start_expedition`; tool wear at a stop: **NEW** in `stop_random_find` (`stops.php:637`); craft input back: **NEW** in `stop_do` case `craft` | 1 a day | one charge per perk | 3 | 0 | 1 |
| A3 | daygift | One common item a day | first visit: `stop_stamp` (`stop_pass.php:119`, called from `place_ui.php:306` and `here_view.php:639`); first food buy: `world.php:356` `buy_from_shop` | 1 item | one charge per perk | 1 | 2 | 3 |
| A4 | daycoin | A few flat coins | `adventure.php:447` `give_find`, `world.php:536` `sell_to_shop` | up to 2 coins | **10 coins a day** in all | 1 | 0 | 1 |
| A5 | info | Shows something you could not see | UI only | flag | no power. 1 per stop at most | 7 | 0 | 0 |
| A6 | looks | Cosmetic | UI only | flag | no power. 1 per stop at most | 4 | 0 | 0 |

Cap changes in pass 2: hp +4 to **+3** (max health is 20 + 3 x level + ..., so +4 was up to 17% at level 1), torch +5 to **+3** (a floor starts with 30 to 50 steps), rest energy +3 to **+2** (rest acts give 3 or 5 energy). A1 to A3: no shared daily cap; each perk is its own once-a-day charge with its own trigger (two world perks may not share a trigger), so the old "3 a day" cap never cut a different perk.

### 4.1 Every mark counts (fix for open question 2)

Pass 1 used one stackable default perk per type and bar for the other 162 stops. That broke two of the fixed requirements: those stops shared perks (13 inns, one perk), and a family fed by k defaults hit its cap after 3 to 5 marks, so most later marks added nothing. The fix:

1. **World perks are a budget, not a pile.** The cap of a family is also the most the whole world may ever hand out in world perks of that family. The Maplewold set uses the "NA world" column; what is left (cap minus that) is all any later hand-written region may use, and Admin refuses a world perk that would go over. So the sum of all world perks equals the cap at most, and every world mark adds its full size.
2. **Everything else is a place perk.** Type templates (section 6) are always scoped to their own stop (`from=`, `to=`, `items=local:`). A place perk never shares a total with another stop's mark: one perk per family per stop by construction, and for `items=local:` the family cap applies per crop (two herb stops with the same local crop add up to the cap at most). Each new mark makes one more place better, so it always adds something.
3. **Daily charges do not share a cap** (A1 to A3: one charge per perk, own trigger). A4 keeps a 10-coins-a-day ceiling.
4. **Flags never cap** (A5, A6).
5. **Rule P2, the place-stack ceiling** (audit 2026-11-27). For one event (one walk, one dish, one harvest, one act), the place and crop perks of a family that match add up to at most **+4%** (XP: **+2%**, one place perk; max health, torch steps, rest energy: **+1**) on top of the world total. So the most at one event is the cap + that ceiling: walk -10%, pots -10%, XP +7%, sell +9%, max health +4, torch +4, rest energy +3. `stop_mark_fx` applies it.
6. **Rule P3, crop perks** (audit 2026-11-27). `stop_local_crops()` (`stops.php:628`) returns the whole region's crops, and a crop is grown, cooked and eaten in the gnome's own garden and kitchen, not at the stop. So a perk that names crops (`items=` named crop slugs; `items=local:<stop>` is retired) acts wherever those crops are, like a small world perk narrowed to a few crops. It is not counted in the world cap; instead: **at most one crop perk per crop per family across all sets** (a harvest-extra daily charge counts as F10), only crops native to its own region (`region_crops.txt`), and P2 above. Region-wide perks (`region=`) are one per family per region.
7. **Rule P4, daily triggers.** No two world daily charges share a trigger, and a place daily charge never repeats a world one's trigger (rod wear, staff wear, weeding, watering, planting, fast travel, the first shop food, a failed stop check are each one perk's).
8. **Rule P5, sizes after the impact pass** (2026-11-27, `proposal-perk-impact.md`). Every % family may be 2% a perk (harvest extra, gather extra, seed back, fast travel cost and seed on fast travel were 1%). A narrow place perk that is still below a meaningful amount at 2% may be 3%: only the perks on the veto list of the impact doc (`VETO3` in the corrections table, 36 perks), never a world perk, and still under P2 (the place perks of a family add at most +4% at one event). Region-wide place perks name the landscapes they work in (half of the region or more). World use after the pass: sell 3 of 5, walk 3 of 6, harvest 4 of 4 (full), gather 2 of 4; every other family as before.

**The maths (recomputed in pass 2; again for 18 stops / 54 perks on 2026-11-27).**
- Maplewold world use per family (of cap): sell 3 of 5, buy 1 of 5, XP 3 of 5, garden XP 1 of 5, walk 3 of 6, pots 4 of 6, meal 2 of 5, buff 4 of 8, heal 4 of 8, harvest 4 of 4, gather 2 of 4, water 2 of 8, seed 1 of 4, friend 2 of 8, stop coins 2 of 8, check 1 of 4, pest 2 of 8, travel 1 of 5, spot 1 of 4, hp 0 of 3, torch 0 of 3, seed on fast travel 1 of 4 (new: Cattailmere), rest energy 2 of 2 (full: later rest-energy perks must be place perks). No family over its cap. Of the 54: 33 have a number (29 world; 4 place: the Straightened Signpost, the Beacon Basket, This Year's Stone, Goat-Track Pickings), 10 are daily charges (8 world, 2 place: the Cloverholt oatcake and the Snowcombe egg), 11 are flags.
- The 6 perks of the two new villages, by budget. The world budget left is now shared with 13 hand-written regions (master section 14, decision 7), so they spend as little of it as they can: **one** world number, in a family the first 48 never touched. Cleared Channels: A1 daily charge, trigger = weeding (no other perk uses it; daily charges share no cap). Rice in the Turn-Ups: F23 world, +1%, budget 0 to 1 of 4. Frog on the Gatepost: A6 flag. This Year's Stone: F20 **place** (`region=NA` + `land=mountain`, like the Beacon Basket's `region=NA`), world hp budget stays 0 of 3. Goat-Track Pickings: F11 **place** (same scope), world gather stays 1 of 4. Counted From the Top: A5 flag. Every other family's budget is as it was.
- World budget left for the other 13 regions: sell 2, buy 4, XP 2, garden XP 4, walk 3, pots 2, meal 3, buff 4, heal 4, harvest 0, gather 2, water 6, seed 3, friend 6, stop coins 6, check 3, pest 6, travel 4, spot 3, hp 3, torch 3, rest energy 0, seed on fast travel 3.
- Templates add 0 to any world total. The 162 other stops carry 486 template perks, all place perks.
- So the most a gnome can ever hold **everywhere at once** is each family's cap, once (sell +5%, buy -5%, XP +5%, walk -6%, pots -6%, ...). **At one place** it is that plus the matching place perks: walk -6% world, -2% for a walk that starts at a marked stop, -2% more if it ends at another (ferry/camp `to=`) = -10% at most; XP +5% + 2% (acts at a marked inn, or walks from a marked tower, or harvests of one orchard stop's local crop; one XP gain matches one of these at most) = +7%; pots -6% + -2% (one mill's local crop) + -2% (a marked camp's pot) = -10%; max health +3 world + 1 (Granitegate, only on the Maplewold's mountain trails) = +4.
- Compare today: one 7-day perk is XP +10% (Bright Mood), pots -20% (Slow Simmer), walk -15% (Spring in Step), all at once with three. **Per family, the forever maximum is about half or less of today's temporary one** (walk -10 vs -15, pots -10 vs -20, XP +7 vs +10). Across families it is wider (all 23 at once), which is the point of a forever reward; every single piece stays at 1 to 2%.
- A capped world family can only happen if Josh raises a size by hand; the perk row then reads "as good as it gets".

Caps and budgets are rows in `data/stop_perk_fx.txt` (`family | unit | cap | label`), editable in Admin; Admin shows "world budget left" per family.

## 5. The Maplewold roads: 18 stops, 54 perks

15 stops in the Maplewold (NA) and the 3 border villages at the ends of its roads out, which are in their neighbours' regions (all names checked against `claude/route-list.md`; NA zones hold the 10 villages listed there today, and the two new zones add one each: Cattailmere and Granitegate, names not used anywhere in the route list). The town and the two havens need `stop_is_place` and a stop type (section 8) before their bars can open. Stop types to set in Admin > Places:

| Stop | Type | Why |
|---|---|---|
| The Maplewold Market | market | The town |
| Poppyburrow | inn | The crossroads: six roads leave it today, seven with the Cairnback Climb |
| Honeybrook | herb | Bees and a beekeeper |
| Cloverholt | mill | Oats and lentils to grind |
| Acornby | camp | A clearing in the forest |
| Birchhollow | workshop | Birch planks |
| Mossgate | shrine | "Moss shrine" |
| Shellhollow | jetty | Coast, shells, anglers |
| Pebblestead | ferry | Coast crossing |
| Iciclecrest | tower | A crest in the tundra, a beacon |
| Snowcombe | spring | Hot pools in the snow |
| Cattailmere (NEW) | herb | Beaverdam Fens, wetland, off-road, first stop on the Fen Path from Honeybrook. The causeway croft that keeps the wild-rice paddy: the Maplewold's Seed Bed is here |
| Granitegate (NEW) | tower | Cairnback Ridge, mountain, off-road, first stop on the Cairnback Climb from Poppyburrow. The watchtower at the door to the high road; Warden Hobb's post |
| Larkbrook | inn | Border inn on the Maizehollow road (region CA) |
| Windbottom | tower | Gate beacon on the Mistmoor road (Warden Hobb's wish; region NWE) |
| Honeythorpe | orchard | Hop yard and fruit, toward Blossomreach (region EA) |
| The Sugar Shack | orchard | A maple sugar bush |
| Aurora Camp | camp | By name |

| Stop | Bar | Perk | Effect | Size | Family |
|---|---|---|---|---|---|
| Maplewold Market | Repairs | ⚖️ Level Scales | Everything you sell in a shop sells for 1% more | +1% | F01 |
| | Larder | 🥯 Baker's Thirteenth | Once a day, the first food you buy in a shop comes with one extra | 1 a day | A3 |
| | Cheer | 🧺 Known at the Stalls | Shop shelves put a small leaf on anything you have never owned | flag | A5 |
| Poppyburrow | Repairs | 🪧 The Straightened Signpost | Walks on the Maplewold's forest, grassland and wetland roads take 2% less time | -2% | F05 |
| | Larder | 🥞 Second Breakfast | Home-cooked dishes eaten at dawn or by day give 2% more energy | +2% | F07 |
| | Cheer | 🛏️ A Bed With Your Name On | Rest acts at any inn give 1 more energy | +1 | F22 |
| Honeybrook | Repairs | 🐝 Tidy Skeps | Pests are 2% less likely on flowers, herbs and fruit crops | -2% | F17 |
| | Larder | 🍯 Honey in the Tea | Boosts from teas, other drinks and sweets last 2% longer | +2% | F08 |
| | Cheer | 🌼 The Bees Know You | A Honeybrook bee visits your garden now and then (looks only) | flag | A6 |
| Cloverholt | Repairs | ⚙️ Greased Wheel | Breads, bakes, porridges and anything else with grain in it cook 2% faster | -2% | F06 |
| | Larder | 🌾 Miller's Pinch | Oat, lentil, soybean and kidney bean harvests: 2% chance of one extra | +2% | F10 |
| | Cheer | 🍪 Oatcake for the Road | First visit to Cloverholt each day: one handful of oats (`oats`) | 1 a day | A3 |
| Acornby | Repairs | 🪵 Dry Woodpile | Resting on any trail heals 2% more | +2% | F09 |
| | Larder | 🐿️ Squirrel's Arithmetic | Gathering in forest and grassland: 2% chance of one extra | +2% | F11 |
| | Cheer | 🔥 Fireside Regular | Stop checks are 1% kinder | +1% | F16 |
| Birchhollow | Repairs | 🩹 Birch-Bark Patch | Once a day, the first wear on your walking staff is skipped | 1 a day | A2 |
| | Larder | 🍂 Sawdust Mulch | Watering lasts 2% longer in dry weather (sun, cloud, heat or wind) | +2% | F12 |
| | Cheer | 📏 Measured Twice | Stop checks show your exact odds as a number | flag | A5 |
| Mossgate | Repairs | 🧹 Swept Steps | 1% better chance to spot hidden things | +1% | F19 |
| | Larder | 🥣 What You Leave Comes Back | Every crop: 1% more chance of a seed back | +1% | F13 |
| | Cheer | ✨ Glow-Moss in the Pocket | When your torch runs out in a delve, your one lit tile glows soft green (looks only) | flag | A6 |
| Shellhollow | Repairs | 🕸️ Sound Nets | Stop acts that cost energy pay 2% more coins | +2% | F15 |
| | Larder | 🐟 Catch of the Day | Fish, gathered finds and dishes sell for 2% more | +2% | F01 |
| | Cheer | 🎣 An Opinion on Every Fish | The Today page shows tomorrow's weather | flag | A5 |
| Pebblestead | Repairs | 🦫 Beaver-Tight Hull | Fast travel costs 1% less | -1% | F18 |
| | Larder | 📦 Porter's Crate | Shops charge 1% less | -1% | F02 |
| | Cheer | 🪨 Pebble in the Boot | 1 in 20 chance a road walk turns up a coin | 1 coin | A4 |
| Iciclecrest | Repairs | 🧯 Beacon Basket, Refilled | +1 torch step in Maplewold delves | +1 step | F21 |
| | Larder | 🫖 Watcher's Flask | Walking in rain, storm, snow, frost, fog or wind takes 2% less time | -2% | F05 |
| | Cheer | 🔭 Three Roads and a Long Way | The route menu shows if something is on at the far stop today | flag | A5 |
| Snowcombe | Repairs | ♨️ Scrubbed Pools | Rest acts at any hot spring give 1 more energy | +1 | F22 |
| | Larder | 🥚 Spring-Boiled Egg | First visit to Snowcombe each day: one hen's egg (`hen-egg`) | 1 a day | A3 |
| | Cheer | 🧣 Warm to the Bones | Healing is 2% stronger in rain, storm, snow, frost, fog or wind | +2% | F09 |
| Cattailmere | Repairs | 🪷 Cleared Channels | The first weeding each day costs no energy | 1 a day | A1 |
| | Larder | 🥾 Rice in the Turn-Ups | Fast travel has 1% more chance to turn up a seed | +1% | F23 |
| | Cheer | 🐸 Frog on the Gatepost | On rainy days a small frog sits on your garden gate (looks only) | flag | A6 |
| Granitegate | Repairs | ⛰️ This Year's Stone | +1 max health on the Maplewold's mountain and tundra trails | +1 point | F20 (place) |
| | Larder | 🐐 Goat-Track Pickings | Gathering on the Maplewold's mountain, tundra, coast and wetland trails: 2% chance of one extra | +2% | F11 (place) |
| | Cheer | 🧮 Counted From the Top | The Maplewold map shows, zone by zone, how many places you have not found yet | flag | A5 |
| Larkbrook | Repairs | 🏮 Border Lamp | Walking takes 1% less time | -1% | F05 |
| | Larder | 🥪 Packed by the Cook | Boosts from dishes you cooked yourself last 2% longer | +2% | F08 |
| | Cheer | 🐦 Up With the Lark | 1% more XP | +1% | F03 |
| Windbottom | Repairs | 🗼 Answered Beacon | The world map shows your three bars for every stop | flag | A5 |
| | Larder | 🎒 Signaller's Ration | The first fast travel each day costs 1 less energy | 1 a day | A1 |
| | Cheer | 🍃 Tailwind | 2% more XP in wind, storm, rain, snow, frost or fog | +2% | F03 |
| Honeythorpe | Repairs | 🪜 Propped Boughs | 1% more garden XP | +1% | F04 |
| | Larder | 🏷️ Grafter's Label | Your satchel shows seed ages | flag | A5 |
| | Cheer | 🍻 Hop-Yard Hum | Gifts of food or drink: 2% chance of +1 friendship | +2% | F14 |
| The Sugar Shack | Repairs | 🪓 Stacked Birch | Syrups, sweets, preserves and drinks cook 2% faster | -2% | F06 |
| | Larder | 🪣 Brim-Full Bucket | Harvests from trees, bushes and vines (anything that regrows): 2% chance of one extra | +2% | F10 |
| | Cheer | 🍁 Sticky Fingers | Once a day, the first seed you plant is not used up | 1 a day | A2 |
| Aurora Camp | Repairs | ⛺ Pegged Tents | Once a day, a failed stop check is rolled again | 1 a day | A2 |
| | Larder | 💧 Meltwater Can | The first watering each day costs no energy | 1 a day | A1 |
| | Cheer | 🌌 Sky-Dazzled | On clear nights a faint aurora shows over your garden (looks only) | flag | A6 |

Gifts name real item slugs (audit 2026-11-27: `oats`, `hen-egg`); item groups (fish, sweets, bakes, tree crops) map to item categories or recipe tags at build time. Pass 2: Sticky Fingers said "the first seed you drop", but the game has no seed drop; it now uses planting (hook NEW in `garden_action`). The Straightened Signpost (`from=`/`to=` Poppyburrow; pass 1's text was the same as the jetty template), the Beacon Basket (`region=NA`), This Year's Stone and Goat-Track Pickings (`region=NA` + `land=mountain`) are place perks; the other numeric ones are world perks and fit their budgets (4.1). Impact pass 2026-11-27: the Signpost is now region-wide on three landscapes (`region=NA` + `land=forest,grassland,wetland`), This Year's Stone covers mountain and tundra, Goat-Track Pickings mountain, tundra, coast and wetland at 2%, and 24 world perks have a wider trigger (five of them also go from 1% to 2%: Miller's Pinch, Squirrel's Arithmetic, Catch of the Day, Watcher's Flask, Brim-Full Bucket). New villages, build notes: Cleared Channels uses the weed hook already listed for A1 (`garden_logic.php:1317`); Rice in the Turn-Ups is the first use of F23 (`world.php:292`); Counted From the Top is UI only and counts places, it does not say where they are (check at build that the map does not already show this count).

## 6. Type templates (every other stop)

Pass 1 gave every other stop its type's shared default. Pass 2 (Josh's rule: every stop has its own 3 perks) replaces that with **templates**: each type has 3, and each is made for one stop by its scope (`from=` / `to=` that stop, or `items=local:` its local crops) and its name ("Honest Weights of Haynook"). No two stops get the same effect, and since every template is a place perk (4.1) a new mark always adds a new place where the gnome is better. Admin can replace any of a stop's three with a hand-written perk (Maplewold style); a hand-written world perk must fit the family's budget.

| Type | Repairs | Larder | Cheer |
|---|---|---|---|
| market | 🪙 Honest Weights: {stop}'s stall pays 2% more for what you sell (F01) | 🥬 Heaped Stall: food at {stop}'s stall costs 2% less (F02) | 🗣️ Good Banter: trade and haggle acts at {stop} pay 2% more coins (F15) |
| mill | 🛢️ Oiled Cogs: dishes with {stop}'s local crops cook 2% faster (F06) | 🧺 Full Sacks: {stop}'s local crops have a 1% chance of one extra at harvest (F10) | 🥖 Flour on the Nose: first visit to {stop} each day: one loaf (A3) |
| inn | 🪟 Fixed Shutters: rest acts at {stop} give 1 more energy (F22) | 🍲 Stew That Remembers You: boosts from meals bought at {stop} last 2% longer (F08) | 📖 Told at the Hearth: 2% more XP from acts at {stop} (F03) |
| shrine | 🪨 Raked Gravel: healing from rest acts at {stop} is 2% stronger (F09) | 🌱 Left a Little, Got a Little: {stop}'s local crops have 1% more chance of a seed back (F13) | 🔔 Bell-Calm: checks at {stop} are 2% kinder (F16) |
| jetty | 🛶 Sound Planks: walks that start at {stop} take 2% less time (F05) | 🦀 A Bucket at Every Post: gathering on walks from {stop} has a 1% chance of one extra (F11) | 🐠 The One That Got Away: chats with {stop}'s folk have a 2% chance of +1 friendship (F14) |
| herb | 🧵 Mended Drying Racks: pests are 2% less likely on {stop}'s local crops (F17) | 🌿 More Herbs Than Names: watering lasts 2% longer on {stop}'s local crops (F12) | 🐞 Bee-Loud: 2% more garden XP from {stop}'s local crops (F04) |
| workshop | 🔩 Spare Nail: the first tool use at {stop} each day takes no wear (A2) | 🫙 Glue Pot: once a day, a craft act at {stop} gives one ingredient back (A2) | 🛠️ Contraption Approved: craft acts at {stop} pay 2% more coins (F15) |
| orchard | 🧤 Sound Ladders: the first walk each day that starts at {stop} costs 1 less energy (A1) | 🍎 Windfall: first visit to {stop} each day: one windfall fruit (A3) | 🍐 Picker's Whistle: 2% more XP from harvesting {stop}'s local crops (F03) |
| ferry | ⚓ Tight Ropes: walks that end at {stop} take 2% less time (F05) | 🧾 Toll Paid in Kind: tools and gear at {stop}'s stall cost 2% less (F02) | 🛎️ Rung the Bell: the first sale each day at {stop}'s stall pays 2 coins more (A4) |
| tower | 🧱 Sound Rungs: walks that start at {stop} have a 2% better chance to spot hidden places (F19) | 🥠 Watcher's Biscuit Tin: first visit to {stop} each day: one biscuit (A3) | 🧭 Seen It Coming: 2% more XP from walks that start at {stop} (F03) |
| spring | 🛁 Mended Pools: resting on walks that start at {stop} heals 2% more (F09) | 🧪 Egg Basket: dishes eaten at {stop} give 2% more energy (F07) | 🧖 Steam in the Whiskers: gifts to {stop}'s folk have a 2% chance of +1 friendship (F14) |
| camp | 🏕️ Ring of Stones: resting on walks that end at {stop} heals 2% more (F09) | 🍳 Shared Pot: pots cooked at {stop}'s campfire cook 2% faster (F06) | 🎶 Harmonica Somewhere: lore acts at {stop} have a 2% chance of +1 friendship (F14) |

Sizes: every template is 1% or 2%, +1 energy, or one daily charge. Where a stop has no stall or no local crops, Admin picks another template of the same bar (the generator warns). The hooks are the family hooks in section 4 with the scope test added; `to=` and `items=local:` are new scope keys.

Since master decision 7 every stop has a hand-written set (this file section 5 and `proposal-stop-perks-regions-A.md`, `-B.md`, `-C.md`); the templates are only a fallback for a stop added later, and a template's `items=local:` becomes named crops under rule P3. All 54 hand-written names and effects (section 5) and the 36 template names and effects are different from each other (84 checked by script in pass 2, the 6 new ones checked against those 84 by name and by effect on 2026-11-27; templates differ from each other in effect text even before `{stop}` is filled in).

## 7. UI

**Perks page: "Lasting marks" card** (replaces "Your perks (work everywhere)").
```
🏅 Lasting marks   7 of 54 on the Maplewold roads · 9 in all
 🪧 The Straightened Signpost   Poppyburrow · Repairs    Walks to or from Poppyburrow 2% faster
 🍯 Honey in the Tea            Honeybrook · Larder      Tea boosts last 2% longer
 ...
 Adds up to:  walk -2% everywhere (most -6%) · sell +2% (most +5%) · 3 daily charges · 4 places
```
One row per mark, grouped by region, newest first. The last line is the world-perk totals against their caps, the daily charges, and how many place perks (each named in its row). A capped row says "as good as it gets" (only possible if a size is raised by hand, 4.1).

**Stop page.**
- Full bar: the meter turns gold with a stamp in the stop's hue (`stops.txt` hue): `🔨 Repairs  [ MENDED ✔ ]`. Words: Mended, Stocked, Merry. The plant tile stays in bloom (stage 4).
- Unfilled bar: shows its perk greyed, so you know what you are working for: `🧺 Larder 62% · 🥞 Second Breakfast`.
- Plaque line under the stop name, one per mark, beside the adopter's plaque: *"The signpost stands straight. {gnome} saw to it. Kept up 12 times."*
- Three marks at one stop: the three medals in the banner go gold, and the passport stamp for that stop gets a gold rim.
- On filling: `🌟 Repairs is mended at Poppyburrow, for good. 🪧 The Straightened Signpost: walks to and from here take 2% less time.`

## 8. Build notes

**Schema**
```
stop_marks      user_id INT, location_id INT, bar VARCHAR(8), perk_key VARCHAR(40),
                filled_on DATE, kept INT DEFAULT 0
                PRIMARY KEY (user_id, location_id, bar), KEY (user_id, perk_key)
stop_mark_use   user_id INT, day DATE, perk_key VARCHAR(40), used INT
                PRIMARY KEY (user_id, day, perk_key)          -- daily charges, one per perk (A1 to A4)
locations       + perk_repairs, perk_larder, perk_cheer VARCHAR(40) NULL   -- NULL = the type's template, made for this stop
```
Bars stay in `stop_prog` (`meter:<name>`, 0 to 100). Today `stop_meter_get` (`stop_living.php:35`) clamps to 99 and `stop_meter_add` (`:44`) resets a full bar to `STOP_METER_AFTER` (30) and writes a `perk:<meter>` row: both change (a latched bar reads 100 and stays). The constants `STOP_METER_DECAY`, `STOP_METER_AFTER`, `STOP_PERK_DAYS` (`stop_living.php:20-22`) become the `mark_*` settings or go. The per-day counts for D and V come from `stop_log` (it has act, kind, day). `perk_key` is stored at fill time: what you earned stays what you earned.

**Data files**
- `data/stop_perks.txt`: `key | owner (type:inn or stop:<slug>) | bar | icon | name | family | size | scope | text`
- `data/stop_perk_fx.txt`: `family | unit | cap | label`
- `data/stop_act_bars.txt` (generated): `slug | type | bar | second`. `stop_act_state.txt` keeps its needs column.

**Hooks** (new `includes/stop_marks.php`)
- `stop_mark_fx(int $uid, string $family, array $ctx = []): int` the player's world marks in the family (capped) plus the place marks whose scope fits `$ctx` (4.1). One cached query per request. Replaces every `player_perk_pct()` call site (9 today: `gnome.php:308, 439, 625`, `garden_logic.php:1598`, `health.php:130`, `world.php:415`, `adventure.php:192, 208`, `crafting.php:465`) and goes in at the hook column of section 4.
- `stop_mark_flag(int $uid, string $perkKey): bool` for A5 and A6.
- `stop_mark_charge(int $uid, string $perkKey): bool` takes that perk's daily charge if it is still unused today.
- `stop_mark_latch(int $uid, array $loc, string $bar): array` called from `stop_meter_add` at 100, in place of `player_perk_grant` (called today from `stop_living_after`, `stop_living.php:153`).
- `stop_is_place(array $loc): bool` = village, or a market or haven with a stop type set. Replaces the `kind === 'village'` tests in `stops.php:813` (`stop_do`), `stop_living.php:339, 360`, `here_view.php:322, 372, 389, 562, 639, 682`, `place_ui.php:306` (the visit stamp). `stop_assign_all` (`stops.php:386`) and `stop_type_of` stay village-only; a market or haven gets its type from Admin. Adoption (`stop_adopt.php:236`) stays village-only. A haven's bars open when the haven is open to that player.

**Admin settings**

| Setting | Default |
|---|---|
| `mark_on` | 1 |
| `mark_bar_size` | 100 |
| `mark_pts_0`, `_1`, `_2`, `_3` | 6, 9, 12, 15 |
| `mark_repeat_pct` (2nd act of a bar that day) | 50 |
| `mark_lose_pct` | 50 |
| `mark_answer_pct` | 150 |
| `mark_variety` | 2 |
| `mark_round` | 5 |
| `mark_fest_mult` | 2 |
| `mark_decay` (a day, unfilled bars only) | 0 |

Plus: Admin > Stop perks (the perk rows), Admin > Stop perk effects (the caps), and three perk pickers beside Stop type in Admin > Places. Retire `perk_days`, `perk_max` and the nine `perk_*` numbers.

**Migration**
1. Bars: work out each bar's value one last time with the old decay, store it, stop decaying. **Every bar keeps what it has; a bar at 30 or more stays as it is.** No bar is raised and no mark is given for a past fill.
2. Running 7-day perks: left to run out on their own date (7 days at most). No new ones are granted. They do not turn into marks. Until the last one ends, a call site reads the old perk or the new family, whichever is larger, never both.
3. `stop_prog` rows `perk:<meter>`: stop writing them at once (`stop_living.php:53`); they are still shown today ("was full here", `stop_living.php:300`), so delete them when the last 7-day perk ends, with the old display.
4. After 7 days: remove `player_perks.php` reads and the old settings; keep the table one release for safety.
5. Update news: say plainly that the big 7-day perks are gone and what replaces them.

Checked in pass 2: nothing in steps 1 to 5 gives a mark or a perk for free. A stored meter is at most 99 (`stop_meter_get` clamps), so no bar latches on migration; the next real act is needed. Running perks end on their date and are never turned into marks.

## Hook list (all 540 perks, deduplicated; audit 2026-11-27)

Generated by `python3 claude/tools_audit_stop_perks.py --fix` from the perk rows of this file and the three region files (540 perks). One resolver does the work: `stop_mark_fx($uid, $family, $ctx)` (NEW, `includes/stop_marks.php`, section 8) adds the world marks of the family (capped) and the place marks whose scope fits `$ctx`, then applies the place-stack ceiling (4.1 rule P2). So the per-family work is: call it at the existing hook and pass the context keys below. Everything marked NEW is new code; the rest exists today.

**Families (number perks).** Count = perks that use the scope key.

| Family | Hook point (exists) | Context keys the perks need (count) |
|---|---|---|
| F01 sell | `world.php:519` `sell_price_with_bonus` (from `sell_to_shop` `:536`) | `region` 12, `at` 5, `group` 4, `none` 2 |
| F02 buy | `world.php:415` in `shop_price` (`:392`) | `region` 10, `none` 3 |
| F03 xp | `gnome.php:308` in `add_xp` (`:303`) | `region` 7, `none` 1, `we` 1 |
| F04 garden xp | `gnome.php:355` `add_garden_xp` | `items` 11, `none` 1, `we` 1 |
| F05 walk time | `adventure.php:192` in `route_walk_minutes` (`:187`) | `land` 13, `region` 13, `we` 7, `from` 5, `at` 2, `none` 1, `to` 1, `dp` 1 |
| F06 pot time | `crafting.php:465` in `cook_seconds` (`:459`) | `items` 13, `region` 4, `group` 2 |
| F07 dish energy | `gnome.php:625` in `eat_item` (`:509`) | `region` 9, `items` 8, `dp` 2, `group` 1 |
| F08 boost length | `gnome.php:439` in `buff_minutes` (`:434`) | `region` 8, `items` 5, `group` 2, `none` 1 |
| F09 healing | `health.php:130` `hp_heal_points`; `adventure.php:1280` `rest_heal`; `stops.php:969` rest acts | `land` 14, `region` 13, `we` 2, `dp` 2, `none` 1, `from` 1, `to` 1, `at` 1 |
| F10 harvest extra | `garden_logic.php:1598` in `do_harvest` (`:1474`) | `items` 20, `none` 1 |
| F11 gather extra | `gathering.php:78` `gather_on_walk`, `:181` `gather_here` | `land` 13, `region` 11, `at` 1, `to` 1 |
| F12 watering lasts | `garden_logic.php:865` `water_seconds` | `items` 14, `we` 1 |
| F13 seed back | `garden_logic.php:1634` in `do_harvest` | `items` 12, `none` 1 |
| F14 friendship chance | `friends.php:56` `friend_add` (extra roll NEW inside it) | `region` 8, `none` 1, `items` 1, `dp` 1, `at` 1 |
| F15 stop coins | `stops.php:670` `stop_rewards` | `region` 7, `none` 1, `fest` 1, `kind` 1, `at` 1 |
| F16 stop check | `stops.php:742` `stop_check` (roll `:748`) | `region` 9, `kind` 2, `none` 1 |
| F17 pest | `garden_fx.php:281` `pest_chances` | `items` 14 |
| F18 fast travel cost | `world.php:282` in `travel_to` (`:267`) | `region` 11, `from` 11, `none` 1 |
| F19 spot hidden | `explore.php:222` in `explore_deeper` (`:187`) | `land` 6, `region` 6, `to` 6, `none` 1 |
| F20 max health | `adventure.php:81` in `gnome_combat` (`:71`) | `route` 5, `from` 4, `land` 2, `region` 2, `at` 1 |
| F21 torch steps | `delve_v2.php:37` `dv2_fuel` | `delve` 9, `region` 4 |
| F22 rest energy | `stops.php:969` `stop_do` case rest | `at` 7, `we` 5, `se` 3, `dp` 3, `none` 1 |
| F23 seed on fast travel | `world.php:292` in `travel_to` | `region` 2, `from` 2, `none` 1 |

Context keys, where each comes from (all NEW as `$ctx` entries; the data exists):

- `from`: stop the walk / act / fast travel starts at (`$route` from, `users.location_id`)
- `to`: stop the walk ends at (`$route` to); fast travel ends only at a region town
- `at`: the stop the gnome stands at (`users.location_id`)
- `region`: region of the place (and `land=` where named)
- `items`: named crops (crop slug list), resolved per event: dish ingredients, harvested or watered crop
- `dp`: `gclock_my_hour()` day part
- `we`: `gclock_my_weather()`
- `se`: season of the gnome's date
- `kind`: act kind of the stop act (`stop_do` `$kind`)
- `fest`: stop festival day (`stop_calendar`)
- `land`: landscape of the route / place
- `delve`: delve landmark id
- `route`: route id (lair road)
- `group`: item group (category or recipe tag: fish, tea, soup, bread...)

**Daily charges (A1 to A4): trigger -> hook point.** One `stop_mark_charge($uid, $perkKey)` (NEW) call at each.

| Trigger | Perks | Hook point |
|---|---|---|
| first visit to the stop | 35 | `stop_stamp` (`stop_pass.php:119`), exists |
| first act (of a kind) at the stop | 10 | `stop_do` (`stops.php:810`) energy / reward step, NEW charge test |
| first walk from / to the stop | 10 | `route_energy` (`adventure.php:202`) / `start_expedition`; arrival: NEW in the walk-end step |
| first rest act at the stop | 7 | `stop_do` case rest (`stops.php:969`) |
| first sale at the stop's stall | 3 | `sell_to_shop` (`world.php:536`) + stall stop id, NEW test |
| first harvest of a named crop | 2 | `do_harvest` (`garden_logic.php:1474`), NEW charge test |
| first dish eaten / cooked at the stop | 2 | `eat_item` (`gnome.php:509`) / `cook_seconds` stop ctx, NEW charge test |
| lost contest replay | 2 | NEW in `stop_do` case contest (`stops.php:953`) |
| torch step in a named delve | 2 | NEW in the delve step cost (`delve_v2.php`, beside `dv2_fuel`) |
| first food bought in a shop | 1 | `buy_from_shop` (`world.php:356`), exists |
| staff wear | 1 | `start_expedition` (`adventure.php:237`), exists |
| coin on a road walk | 1 | `give_find` (`adventure.php:447`) |
| weeding | 1 | `garden_action` weed (`garden_logic.php:1317`), exists |
| fast travel | 1 | `travel_to` (`world.php:283`), exists |
| planting | 1 | NEW in `garden_action` plant (`garden_logic.php:1197`) |
| failed stop check re-roll | 1 | `stop_check` roll (`stops.php:748`), exists |
| watering | 1 | `garden_claim_free_water` (`garden_logic.php:554`), exists |
| rock-pick wear | 1 | NEW in the tool-wear step of `gather_on_walk` (`gathering.php`) |
| first dish cooked with a named crop | 1 | `crafting.php:529` extra-dish roll, NEW charge test |
| rod wear | 1 | NEW in the tool-wear step of `gather_on_walk` / `gather_here` (`gathering.php`; limits `tools.php:285`) |
| failed check at a wonder | 1 | NEW in `wonder_try` (`landmarks.php:228`) |
| first buy at the stop's stall | 1 | `buy_from_shop` (`world.php:356`) + stall stop id, NEW test |
| first gift to the stop's folk | 1 | NEW in `stop_gift` (`stop_folk.php:181`) |
| craft ingredients back | 1 | NEW in `stop_do` case craft |
| bug-net wear | 1 | NEW in the tool-wear step of `gather_on_walk` (`gathering.php`) |
| first tea brewed | 1 | NEW in the Hovel kettle (`tea.php`) |
| an empty walk find | 1 | NEW in `give_find` (`adventure.php:447`) |

**Flags (A5 info, A6 looks): page -> file.** One `stop_mark_flag($uid, $perkKey)` (NEW) test in each view; no game rule changes.

| Page | Flags | File |
|---|---|---|
| garden | 30 | `garden.php` / `garden_logic.php` view |
| Today page | 21 | `today_view.php` |
| gnome / home | 16 | `profile.php`, `hovel.php`, `gnome.php` |
| stop page | 13 | `here_view.php` stop card / `stop_living.php` |
| route menu | 11 | `here_view.php` routes block |
| satchel | 10 | `inventory.php` |
| walk view (route maps) | 10 | `adventure.php` walk view, trail maps |
| world map | 6 | `maps.php` |
| shops | 5 | `shop.php`, `world.php` |
| kitchen / recipes / tea | 5 | `kitchen.php`, `tea_view.php` |
| delve | 4 | `delve_v2.php` view |
| passport | 4 | `passport.php`, `stop_pass.php` |
| friends | 2 | `friends.php`, `villagers.php` |
| seed packets | 1 | `inventory.php` |

**NEW, deduplicated** (everything the 540 perks need that is not in the code today):

1. `includes/stop_marks.php`: `stop_mark_fx`, `stop_mark_flag`, `stop_mark_charge`, `stop_mark_latch`, `stop_is_place` (section 8), tables `stop_marks`, `stop_mark_use`.
2. `$ctx` at the 23 family hooks: pass `stop` / `from` / `to` / `region` / `land` / `items` / `kind` / `group` where the call site knows them (route, location, dish ingredients, harvested crop, act kind, item category). Day part, weather, season and festival are read inside the resolver from the gnome's clock.
3. Named-crop scope (`items=crop1,crop2`), replacing `items=local:<stop>`: `stop_local_crops()` returns the whole region, so a crop perk is one per crop per family (4.1 rule P3).
4. F14 friendship: the extra +1 roll inside `friend_add` (`friends.php:56`), with the gift or chat context from `stop_gift` (`stop_folk.php:181`) and the stop chat.
5. F18 / F23 fast travel: `from` = the stop the gnome stands at when `travel_to` runs, `to` = the target region's town only.
6. F20 max health on a named lair road or a region's land: route id and landscape passed into `gnome_combat` (`adventure.php:71`) from the expedition.
7. F21 torch: delve landmark id passed into `dv2_fuel` (`delve_v2.php:37`).
8. A1 energy: a charge test in `stop_do` (first act of a kind at a stop) and in the walk-end step (first walk that ends at a stop).
9. A2 things back: planting in `garden_action`; tool wear in `gathering.php`; craft ingredients in `stop_do` case craft; contest replay in `stop_do` case contest (`stops.php:953`); wonder check re-roll in `wonder_try` (`landmarks.php:228`); an empty walk find in `give_find`; a delve torch step beside `dv2_fuel`; a gift kept in `stop_gift`; tea ingredient back in `tea.php`.
10. A3 gifts at a stall buy or sale (`buy_from_shop`, `sell_to_shop`) and at a first rest, lore or craft act (`stop_do`); every gift is a real item slug (crop, gatherable, snack or preserve).
11. A4 coins: the 10-coins-a-game-day ceiling as one `stop_mark_use` row (`perk_key` = `a4`).
12. Flags: one `stop_mark_flag` test per view (table above). Info flags read data the game keeps (weather, moon, tool wear, recipes, `stop_log`, `region_visits`, landmark runs); none adds a new game rule.

**Cut as unrealistic in the audit** (rewritten in place, see the audit log in `PROPOSAL-HOLLOW-MASTER.md`): fast travel "to" a village (`travel_to` only lands at a region's town, `world.php:283`); fast travel inside one region (refused as "already here"); wonder states the game does not keep (where the Oasis That Moves is, whether the Great Migration passes, panda shoots today); a walk "ridden" for no energy (a free walk, not a 1-energy convenience).

## 9. Open questions for Josh

All answered by Josh on 2026-11-27 (`PROPOSAL-HOLLOW-MASTER.md` section 14): town and havens are stops; a hand-written set per region (done: the three region files, 540 perks in all); pace 6 to 10 visit-days a bar; marks never count for Standing; news post only. Kept below as asked.


1. **16 stops (18 since master section 14), and three are not stops yet.** 13 (now 15) are in the Maplewold, 3 are border villages of CA, NWE and EA (their 9 perks count toward those regions). The town and both havens need the `stop_is_place` change and a stop type. OK to do that, or should havens fill their bars through their build plans instead?
2. **Caps make later marks add nothing: fixed in pass 2** (4.1, section 6). World perks are a budget equal to the cap, templates are place perks unique to each stop, daily charges are per perk. Left for Josh: are templates enough for the other 13 regions, or should each region get a hand-written set like the Maplewold (within the world budget left)?
3. **Pace.** About 5 to 8 visit-days per bar (the sample workshop day gives R 20, L 13, C 16), two months for all 48 on the Maplewold roads. Right, or faster?
4. **Standing.** Should marks count toward a region's Standing and Seal ("12 lasting marks in the Maplewold"), or stay a separate layer?
5. **The step down.** Players lose XP +10%, pots -20% and walk -15% and get 1% to 2% pieces back. Pass 1 offered "one free mark" as a softener; that breaks the no-free-perks rule and is withdrawn. Fine with only the news post, or soften another way (for example a festival week where bar points are doubled)?

## Pass 2 review log

Checked against the code and Josh's fixed rules (marks latch for good, no expiry, no max-3, no decay of a full bar; 3 unique perks per stop; each perk 1 to 2% or a small extra; caps hold; no free perks).

**What was wrong, and what was fixed in place**
1. **The per-act table did not exist.** Now generated: `claude/tools_gen_stop_act_bars.py` -> `claude/proposal-stop-act-bars.txt` (860 acts, 1511 rows, deterministic). All 49 worked examples match it. Section 2 share table replaced with the real run (pass 1 overstated Repairs at market, herb and orchard by 7 to 8 points); second-bar range is 25 to 52%, not 28 to 56%. Step 1's "start of a whole word" would still count "pier" as "pie": made precise (word + plain ending, or a 4+ letter compound). 60 hand overrides suggested (7%, not 5%), in the txt.
2. **Type defaults broke "every stop has its own 3 perks"** (13 inns shared one perk) **and made later marks useless** (open question 2). Replaced by stop-scoped templates (section 6) and the world-budget / place-perk rule (4.1). Daily charges are per perk now, not a shared 3-a-day cap. Cap maths redone: no family over its cap; worst case at one place is walk -10%, pots -10%, XP +7%, against today's -15%, -20%, +10%.
3. **"16 Maplewold stops" is 13 + 3.** Larkbrook (CA), Windbottom (NWE) and Honeythorpe (EA) are their regions' border villages (route list). The town (`market`) and havens (`haven`) are not stops in code; the list of `kind === 'village'` gates was incomplete (added `here_view.php` x6, `place_ui.php:306`, `stop_adopt.php:236`, `stops.php:386`).
4. **Hooks.** Most file:line refs were right. Fixed: hp is `adventure.php:81` `gnome_combat` (not `hp_max`); rest energy is `stops.php:969`; first-visit gift is `stop_stamp` (`stop_pass.php:119`); `crafting.php:529` is the extra-dish roll, so "ingredient back" is NEW; there is no seed drop in the game, so Sticky Fingers now works on planting (NEW in `garden_action`). Every NEW hook is marked.
5. **Sizes and duplicates.** Caps cut where a +1 was more than about 2%: hp +4 to +3, torch +5 to +3, rest energy +3 to +2. Script check of all 84 names and effects: no duplicate names; one duplicate effect (the Straightened Signpost had the jetty template's text) rewritten.
6. **Migration.** `perk:<meter>` rows are still written and shown today (not "unused"); now retired with the last 7-day perk. Pass 1's "one free mark" softener broke the no-free-perks rule and is withdrawn. No step gives a mark: stored meters are at most 99.

**Left for Josh (max 6)**
1. Accept the 60 suggested act overrides (paste from the end of `proposal-stop-act-bars.txt` into `stop_act_state.txt`), or edit them.
2. Templates for the other 13 regions, or hand-written sets within the world budget left?
3. Town and havens as stops (`stop_is_place`), and their stop types.
4. Pace: 5 to 8 visit-days a bar, about two months for the Maplewold roads.
5. Marks toward Standing and Seals, or a separate layer?
6. Market, herb and orchard stops have only 7 to 14% Repairs acts: is the answer-act cover enough, or should their lean move to Repairs?

## Implementation status (stop marks foundation, behind `stop_marks_open`, default 0)
- Code: `game/includes/stop_marks.php` (hook API in its header comment: `stop_marks_active`, `mark_pct`, `mark_place`, `mark_daily_available`, `mark_daily_use`, `mark_daycoin`, `mark_flag`; caps of 4 and P2 as constants), tables `stop_marks`, `stop_mark_use` (in `stops100_schema`), 13 settings (`stop_marks_open`, `perk_old_retired`, `mark_*`). Test `tests/stop_marks.sh`.
- Data: `data/stop_perks.txt` (540 rows, `claude/tools_export_stop_perks.py [--db game.sqlite]`; unmatched today: Cattailmere, Granitegate, matched by name once they exist) and `data/stop_act_bars.txt` (`claude/tools_export_stop_act_bars.py`, the 60 suggested overrides applied).
- `stop_is_place()` replaces `kind === 'village'` at: `stops.php` `stop_do`, `stop_living.php` `stop_perk_data` / `stop_perk_body`, `stop_pass.php` `stop_stamp`, `local.php` `local_do`, `place_ui.php` `stop_slim_card_html` (stamp), `here_view.php` `here_do_fronts`, `here_do_reply`, `here_stall_fronts`, `here_view` (stamp), `here_extra_do`, `town.php` (haven page header and panel). Kept village-only: adoption, land, stop folk sprites, `stop_assign_all`. The town's stop page is `town.php?view=reststop` (link on its Stop tab).
- Not yet wired: the 23 family hooks and 28 daily triggers (call sites still read `player_perk_pct`), Admin perk pickers, the world-map / flag views. Stop types: the world's own (`stop_assign_all`) differ from the catalogue for most villages (Maplewold: 9 of 10); only the town and havens take the catalogue / 7.5 type.
