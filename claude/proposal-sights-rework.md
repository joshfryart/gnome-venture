# PROPOSAL: Sights rework ("one tap, one gift, one stamp")

Status: PROPOSAL ONLY (2026-11-28). No game code changed. Read on build 2.8.92, phone width 412 px, route 236 (Market to Cloverholt), a new gnome.
Sources: `plan-trail-sights.md`, `sights/GRAMMAR.md`, `trail_sights*.php`, `trail_sight_extras.php`, `adventure.php:361-384`, `PROPOSAL-HOLLOW-MASTER.md`, `stop_marks.php`, `journey_v2.php`, `seals.php`, `pfboard.php`.

---

## 1. Sights today

### 1.1 In six lines a new player could say
1. Big pictures on the Trail map (a windmill, a dandelion patch) are "Sights".
2. A gold ! floats over one I can use. I have to walk off the road and stand next to it.
3. Then a button with a verb appears under the map ("Blow", "Sniff", "Bow"), or I open "Sights 2" and read a card.
4. I press it. It costs 0 or 1 energy. Sometimes it rolls a stat, sometimes I pick one of three, sometimes it wants a tool or an item.
5. I get a popup with a line of story and some things. Sometimes I slip and lose energy instead.
6. Then it is greyed out for about 5 days, and I am not sure why or what I was collecting.

### 1.2 The five reasons it confuses
| # | Problem | Where |
|---|---|---|
| 1 | **Three ways in, no single "tap here".** The gold ! on the map, a "Sights 2" button, and one extra verb button per Sight in the same row as Gather, Fish, Wander, Walk on, Sneak, Hunt, Turn back (up to 10 buttons). The verb button shows only "Blow" with no noun: blow what? | `adventure.php:364-372`; screenshot: the row is under the fold and behind Wren's tour card |
| 2 | **The card reads like a timetable, not an invitation.** One Sight card showed 7 lines: caption, "Blow · 1 · 10 min", "The Opening Day Parade · step 5 of 5 · not yet", "Bramble's Picnic List · step 6 of 7 · starts here", two villager schedules with day bars ("Sat, in 2 game days 6 pm - 8 pm"), then the button. Nothing says what I get. | `trail_sights_cards_html()` `trail_sight_extras.php:912-964` |
| 3 | **Four kinds of gate, each with its own symbol.** Stat roll (44 Sights, 6 stats), pick-one-of-three with a hidden right answer (47), tool and tier (11), time / season / weather (11), plus item swaps. A roll can fail and a slip costs energy (`fail_en`), and a wrong pick pays nothing. That is a fail state in a game that promises none. | check column in `data/trail_sights_*.txt`; `trail_sight_do()` `trail_sights.php:483-486` |
| 4 | **Hidden rules.** Cooldown is in tenths of a game day (55 = 5.5 days) and shows only as "again soon". A cap of 6 Sights per walk (`sights_walk_cap`) appears only when hit. Private tallies (132 tokens), streaks, titles (104) and pages unlock at counts the player never sees (4, 5, 8, 10). Rewards use 24 token kinds under 12 condition kinds; the card names none of them. | `GRAMMAR.md` (seven passes); `trail_sight_state()`; `trail_sight_walk_cap()` |
| 5 | **Vocabulary clashes.** "Sights" is also the word for road events in code and journal (`road_sight_icons()`), the cards say "the big landmarks" while "Landmarks" are the off-road places (`landmarks.php`), "Sight quests" is a fourth quest list beside Wren's Journey, errands and stop threads, the Almanac has a "Sights" chapter whose 219 pages do not count, and the first thing on the Trail page is "Wren's tour". A new player cannot tell which of these is the main thing. | `quests_view.php` (Sight quests box), `almanac_counts`, `trail_sight_category()` |

What players like and we keep: the pictures, the unique verb per Sight, the two funny lines, villagers who turn up, the first-visit Almanac page, the gold !.

---

## 2. The reworked design

**One sentence for the player:** "A Sight is a spot on the Trail. Tap it, do the thing, get a gift and a page for the Almanac."

### 2.1 The loop
| Step | Player sees | Player taps | Result |
|---|---|---|---|
| See | Gold ! over the picture (as now). Grey leaf when resting | The picture | The gnome walks there by itself (the existing `trail_go`), then the card opens. No "stand next to it" rule to learn |
| Read | One small card: name, one line, what it gives, one button | The verb button | - |
| Do | The story line | - | Always works. A lucky moment adds a bonus |
| Get | Up to 3 gift chips, the stamp count, one "also" line | Lovely | Back on the map; the ! becomes a leaf with the sleeps left |

### 2.2 Plain names
| Old | New |
|---|---|
| Sight, set piece, landmark (in Sight text) | **Sight** (kept; one word only) |
| road-event "sights" | "road moments" in UI text (code names stay) |
| stat check, pick, tool gate | **a lucky moment** (bonus only, never a fail) |
| cooldown, uses, "again soon" | **resting: back in N sleeps** |
| tally, streak, title thresholds | **stamps** ("3 of 10") |
| Sight quests | **errands** (shown in the one errand list) |
| Almanac chapter "Sights" | **Wren's Almanac: Sights of <area>** ("14 of 82") |

### 2.3 What is cut or hidden
- **No fail.** A check never blocks and never costs. A pass pays the row in full plus the line "Lucky: ..."; a miss shows the old "lose" line (they are charming) and pays the same row at half (the rule the stop bars already use: lose = 0.5, master 7.3). `fail_en` and `lose:` penalties are not applied.
- **Pick one of three** stays as three buttons, but every choice pays; the "right" one is the lucky one. (Later a small puzzle, 3.7.)
- **Tools** do not lock. With the tool: full. Without: half and "A bucket would get more here."
- **Time / season / weather gates** (11 rows) stay, as one plain line and no button: "Comes out at dusk."
- **One way in:** tap the picture. The foot row keeps one Sights button only; next to a ready Sight it becomes that Sight's button with verb and noun ("Blow the dandelions 1"). The per-Sight verb buttons go.
- **On the card, at most:** 1 gives line, 1 errand line (only when it is your next step), 1 villager line (only when one is there now), 1 stamp line. Villager schedules move to the villager's own card. "10 min" goes (the clock shows it).
- **Walk cap** goes when the new card is on (open decision 3). The rest time already limits.
- **Rest time** is shown in whole sleeps (55 tenths reads "6 sleeps").

### 2.4 Phone mock (412 px)

Map, then the row under it:
```
+--------------------------------------+
|        [map]     ! (dandelions)      |
|   gnome                              |
+--------------------------------------+
| [Gather] [Sights 2] [Wander] [Back]  |
+--------------------------------------+
```
Tap the dandelions (the gnome walks over, the card opens):
```
+--------------------------------------+
| [picture]  The dandelion clocks   x  |
|            Make a hundred wishes     |
|            at once.                  |
|                                      |
|  Gives: seeds, a find, know-how      |
|  Errand: Bramble's Picnic List       |
|          (your next step)            |
|  Stamps: Wishes 3 of 10              |
|                                      |
|  [  Blow the dandelions    1 energy ]|
+--------------------------------------+
```
After the tap:
```
+--------------------------------------+
|  Blow the dandelions                 |
|  Phoo! The seeds sail off in every   |
|  direction, each with a small wish.  |
|                                      |
|  [1 Clover seed] [+3 know-how]       |
|  Lucky: the wind was up. [1 find]    |
|                                      |
|  New page for Wren's Almanac         |
|  Sights of the Maplewold  15 of 82   |
|  Also: Cloverholt Cheer +3           |
|                                      |
|  Resting now. Back in 6 sleeps.      |
|              [ Lovely ]              |
+--------------------------------------+
```
Resting Sight, tapped:
```
| The dandelion clocks                 |
| Resting. Back in 4 sleeps.           |
| Stamps: Wishes 4 of 10               |
```
Gated Sight: `Comes out at dusk.` (no button). Villager there: one line `Basil is here. [Say hello]` opening the villager card that exists.

Rules for the "Gives" line: at most three words from a fixed list of seven (things, seeds, food, know-how, Petals, a boost, a tip), built from the row's tokens by the existing `trail_sight_reward_label()`. Never chances, never conditions.

---

## 3. Melding with the new systems

All rules below: once per game day means `gclock_my_date()`; nothing is timed, nothing expires, nothing is lost by not doing it, nothing can be bought past.

| System | What a Sight does | How (existing hook) |
|---|---|---|
| **Rest-stop bars** (Repairs, Larder, Cheer; `stop_marks_open`) | Each Sight use adds **3 points** to one bar of the nearer stop of its road (first half of the sections = the start stop, the rest = the end stop). Bar by kind: crossings, mills, wagons, walls = Repairs; picking, fishing, feeding, anything that gives food or seeds = Larder; resting, wishing, folk, wonders = Cheer. Shown as the "Also:" line. Miss = 1 point. Only at a stop the gnome has visited | `mark_bar_add()`; kind from `trail_sight_kinds.txt` plus one new column-free file `trail_sight_bars.txt` (`slug|bar`), default by the word tags of 7.2 |
| **Lasting marks** | Marks act on Sights with no new family: `gather extra` and `stop check` perks scoped `route` or `from`/`to` apply to that road's Sights (stop check = lucky chance). A full bar never changes a Sight's rest time | `mark_pct($uid, family, ['route' => ...])` |
| **Standing: Places** | No new weight. The 9 Sights with `reveal=` and the map scrap already make an off-road place known, which the Places row counts. The card says "Tip: a place off the road" | `place_known()` |
| **Standing: Delve and Lair** | No score from a Sight. The 9 delve-door and 10 lair-mouth end Sights keep their true hints and boosts, and the card says "Helps in the delve below" | existing `hint=`, `buff=` |
| **Standing: Folk** | A villager met at a Sight gives friendship as now (the Friend row). A finished Sight errand whose giver lives in the area counts as **one errand** for "Folk: errands" (at most 2 of the 5) | `user_sight_quests.done_at`; one line in `seals.php` |
| **Standing: Almanac pages** | Sight pages of the area join the pages row, numerator and denominator, still full at 60% (open decision 2; needs the Standing sim rerun) | `unlock_key sight:<slug>`; `STANDING_PAGES_FULL` |
| **Wren's Almanac** | First use = "New page for Wren's Almanac" with the area count on the result card and on the Almanac chapter head. Stamps (the old tallies) show as "3 of 10" and the page they open is named: "At 10: the page A Hundred Wishes" | `trail_sight_first`, `trail_sight_tally`; new table `trail_sight_seen` (section 4) |
| **Journey v2** | New step kind **`sight`**: `sight slug` (that Sight used, ever), `sight zone:N` / `sight area:N` (N different Sights there), `sight kind:crossing:N`. Latches like every step, counts earlier uses, no `alt` needed because it cannot fail. Errand rows in `journey_errands.txt` may use it. The 39 Sight quest lines are listed with the errands (same card, tag "on the Trail"), not in a box of their own | `journey_v2_eval()` case, `journey_v2_event($uid, 'sight', $slug, 1)` from `trail_sight_do()` |
| **Gardening** | One **garden Sight** per area (Maplewold: the nodding wildflowers) gives 1 seed of the area's native flower on the first visit, for sure, once. Seed and cut-flower Sights say "seeds" in Gives. Sights that take garden produce (scarecrow, hay wagon) say "Likes: something from your garden". No Seed Bed hand-in at a Sight | `first:` token; master section 8 table |
| **Puzzle Pals** | The 17 `pal=1` bonuses show as a chip: "Pal along: +1". A new tip kind `hint=pal` names the stop where one of the gnome's waiting pals is. Pals never spawn at a Sight (spawn rules unchanged) | `ppal` spawn rows, existing hint code |
| **Puzzle board** | The 47 pick-of-three Sights can show as a **one-move puzzle**: a 3x3 board with one gap and three pieces in hand; the piece whose knobs fit is the lucky one. A piece that does not fit just says so, and the gnome tries another: no cost, no lock. For the 44 stat Sights, a gnome who owns that stat's piece (`pfight_statpieces`) gets the lucky line for sure: "Your Nimble piece fits." Needs `pfight_open`; otherwise the three buttons | `pfboard.php` edge-fit test only (no fight state), `pfdeck` stat tiers |
| **Shared Sights** (`sights_shared_on`) | Unchanged. The cairn count and chalk words become the "Also:" line of that Sight's card instead of extra foot-row items | `sights6_trailfoot_html()` moved into the card |
| **Game day** | Rest time counts sleeps. A lucky pick is fixed per gnome and game day (as now). Nothing about a Sight uses real time | `got_tick`, `gclock_my_date()` |

---

## 4. Migration

**Data: no file is rewritten.** The 219 rows, 230 villager rows, 39 lines and every token of the seven grammar passes stay as they are and stay valid. The rework is a new outcome rule and a new view over the same rows:
- New file `game/includes/trail_sights_v2.php`: `sights_v2_on()`, the card, the result card, the Gives words, the bar feed, the `sight` step. `trail_sight_do()` gets one branch: with v2 on, a failed check is "miss" (half scale through the `stop_rewards()` scale argument, no `fail_en`, no `lose:` tokens).
- Lint additions (`tests/trail_sights_lint.sh`): every row yields 1 to 3 Gives words; every row has a bar; every tally with a `tn=` goal has a named prize.
- Admin > Trail sights and `trail_sight_rows` (admin edits) keep working: same columns.

**Player progress: nothing lost.**
| Table | Holds | Under v2 |
|---|---|---|
| `trail_sight_uses` | rest time per road, section, Sight | read as before; shown in sleeps |
| `trail_sight_first` | first use per Sight | the stamp and page counts start from it, so old visits count at once |
| `trail_sight_tally` | counts and streaks | shown as stamps |
| `user_sight_titles` | titles won | unchanged |
| `user_sight_quests` | lines begun and done | listed as errands; done ones count for Folk |
| `trail_sight_rows` | admin rows | unchanged |
| `sights_shared_items`, `_reports`, `_tally` | shared notes, marks, cairn | unchanged |
| new `trail_sight_seen` (`user_id`, `region_id`, `slug`; insert only) | which Sights seen in which area | needed because shared pieces stand in many areas and `trail_sight_first` has no area. Backfill on first read: Maplewold slugs from `trail_sight_first`; the rest from `trail_sight_uses.route_id` where rows still exist. Shared-piece visits older than that count for the collection total but for no area: say so in the news post |

**Setting:** `sights_v2_open` (default 0), in the Hollow group beside `seals_open`, `journey_v2_open`, `stop_marks_open`. Off = today's Sights, byte for byte. On = card, no-fail rule, stamps, errands merge. The melds switch on only with their own setting too: bars need `stop_marks_open`, the step and errands need `journey_v2_open`, Standing needs `seals_open`, the puzzle needs `pfight_open`. Kept: `sights_reward_pct`, `sights_flat_pct_per_level`, `sights_shared_on`. `sights_walk_cap` is ignored while v2 is on (decision 3).

**Balance:** always-pays raises the payout of the 91 checked Sights (est., unsimulated). Before release run a sim over the 219 rows, off against on, and set `sights_reward_pct` so a Sight still pays about one Gather per energy (today's target, `sights-reward-tuning-2.7.08.md`).

**Test plan**
1. Off: the ten suites `trail_sights*.sh`, `sights_items.sh`, `sight_parts.sh`, `trail_sights_shared.sh` pass unchanged.
2. New `tests/sights_v2.sh`, setting on: all 219 rows give a card of at most 4 info lines and a non-empty Gives; no use lowers energy by more than the cost; a miss pays half and never 0; a tool-less use pays; the 11 gated rows show their line and no button.
3. Progress: seed a gnome with old `trail_sight_first`, tally and quest rows; turn on; counts, stamps and errands show them; turn off; nothing changed in those tables.
4. Melds, each with its setting on and off: bar +3 / +1 once per use; `sight` step latches and counts old uses; a done line adds one errand, capped at 2; pages row moves; garden seed given once.
5. Clock: sleep twice in one real day, the rest time drops by 2; with `game_clock_on` 0 it follows the Halifax day.
6. Screens: 412 px shots of card, result, resting, gated, and with Wren's tour open (the card must not sit under it); landscape dock menu still opens the Sights button.
7. Lint and the balance sim in CI.

---

## 5. Build plan and decisions

### 5.1 Slices (each ships dark behind `sights_v2_open`, each with its own test)
| # | Slice | Size | Test |
|---|---|---|---|
| 1 | Setting, `trail_sights_v2.php`, the new card (view only), tap the picture walks and opens it, one foot button | S | plan 2 (card), 6 |
| 2 | No-fail rule: miss = half, no energy slip, tools do not lock; result card with chips and "Resting: N sleeps" | S | plan 2, 5 |
| 3 | Balance sim, then `sights_reward_pct` | S | plan 7 |
| 4 | Stamps: tallies shown as "3 of 10" with the named prize; `trail_sight_seen` and backfill; "Sights of <area> 15 of 82" on result and Almanac | M | plan 3 |
| 5 | Errands merge: Sight lines in the errand list, card shows only the next step; Journey step kind `sight` | M | plan 4 |
| 6 | Bars: `trail_sight_bars.txt`, +3 / +1, the "Also:" line; marks' `gather extra` and `stop check` on Sights | S | plan 4 |
| 7 | Standing: errands from Sight lines (cap 2); pages row (after the Standing sim) | S | plan 4, `seals_standing.sh` |
| 8 | Garden Sight per area, Pal chip, `hint=pal`, shared Sights line in the card | S | plan 4 |
| 9 | One-move puzzle for pick Sights; stat piece = sure luck | M | board fit unit test, plan 6 |
| 10 | Wording sweep (road moments, "Sight" only, How to play page), news post, default stays 0 until Josh says | S | text grep test |

Slices 1 to 3 alone fix "I do not understand it". 4 and 5 give the collecting feeling. 6 to 9 are the melds and can wait for their own features.

### 5.2 Open decisions for Josh
| # | Question | Recommendation |
|---|---|---|
| 1 | A miss pays half, or full with luck as an extra on top? | **Half.** Same rule as stop bars, keeps the stats worth having, and the payout stays near today's |
| 2 | Do Sight pages count for Standing (Almanac pages row)? | **Yes, inside the existing row** (weight stays 5), after a sim rerun. If the non-fighter slack drops under 2 points, leave them out |
| 3 | Drop the 6-per-walk cap under v2? | **Yes.** It is a hidden rule; the rest time and energy already limit. Check it in the slice 3 sim |
| 4 | Rest time: keep about 6 sleeps, or once per sleep with smaller gifts? | **Keep 6 sleeps**, shown as sleeps. Daily Sights would turn a walk into a chore list |
| 5 | Tool Sights (11): open to all at half, or still need the tool? | **Open at half**, with the "a bucket would get more" line. No locked buttons on a first walk |
| 6 | The one-move puzzle (slice 9): build it, or keep three buttons? | **Build last, and only if puzzle combat is open to all.** Three buttons are already clear |
