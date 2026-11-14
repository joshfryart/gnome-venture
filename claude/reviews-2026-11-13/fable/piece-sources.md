# Piece sources for puzzle combat: what exists, what to add

Research and proposal only (2026-11-14). No game code, data or tests were changed. Read from `game/includes/pfdeck.php`, `data/pf_pieces.txt`, `claude/design-deckbuilder-combat.md`, `claude/handover-v1-stageB.md`, `tests/pfboard_tune_v1.php`.

## 1. Sources today (v1 deck model, behind `pfight_v1`)

78 authored player pieces in `pf_pieces.txt` (30 old + 18 tool + 9 crop + 7 craft + 14 region); pal pieces are generated.

| Source | Pieces | Owned when | Rank from | On by default | Code |
|---|---|---|---|---|---|
| Basic | 6 (+ Breather stand-in) | always | none | starter only | `pfd_build` `$owned` |
| Knack | 17 | gnome level 4 to 16 (`ref`) | none | **off** | same |
| Calling | 1 of 6 | your calling; +2 value per calling tier | none | via starter offer | `PF_CALLING_TILE`, `pfd_tiles` |
| Tool (belt) | 1 per tool TYPE, 18 types | tool in satchel and on the fight belt (2 / 3 / 4 slots: belts bought at Twigg's, level 8 and 18) | tool tier 1-4 | gear, always on; wears 2 per play | `pfd_belt`, `PFD_BELTS` |
| Pal | 1 per active party pal | pal taken along (`ppal_equipped`) | rarity 1-3 | gear, always on | `pfd_pal_pieces` |
| Crop | **9: one per crop KIND** | grew any crop of that kind (`user_food_mastery.grown > 0`) | best food mastery tier in the kind | **on** | `pfd_sources`, `pfd_crop_kinds` |
| Craft | 7: one per recipe CATEGORY | made anything in it (`user_recipes.made > 0`) | 1 + category mastery | **on** | `pfd_sources` |
| Region | 14: one per region | read its Gardening Guide (`user_guides`) | guides held 1 / 3 / 7 / 12 | **on** | `pfd_sources` |

Starter: 4 core + 6 picked of 12 (`PFD_OFFER`) or a one-tap kit (`PFD_KITS`). Limits: kit at least 8, at least 1 Hurt, at most 3 Rare and 1 Masterwork. **No maximum size.** The player sees all of it on the Puzzle box page (`puzzlebox.php`, `pfdeck_view.php` `pfv_box_html`) and the pre-fight screen.

Honest answers to the owner's two checks:

- **Crops are per kind, not per crop.** `crops.txt` has 194 real crops (plus 3 cover crops) in 9 kinds: tree 55, vegetable 43, fruit 22, grain 16, spice 15, legume 14, herb 13, nut 11, tuber 5. Growing a tomato and growing an onion give the same piece (Garden Greens). The design doc (2.2, "harvest a crop kind") asked for exactly this, so it is a design gap, not a bug.
- **Food gives almost nothing.** All 241 dishes in `recipes.txt` share ONE piece, Hot Soup (`k:cooking`); all preserves share Pickle Splash (`k:pantry`). The Snack piece only eats a snack from the satchel. The data to do better is already kept: `user_recipes.made` per recipe, `user_food_mastery.eaten` per item.

Bloat that is already there: crop, craft and region pieces switch themselves on. A gnome who has done everything carries 10 starter + 9 + 7 + 14 + 4 tools + pals = 44 or more. The sims do not see this: `tv_sources` models about 14 pieces at level 1 and 22 at level 30.

## 2. Candidate new sources

Value scale today: basics 3-5, knacks 2-6, calling 5-8, sourced pieces 2-5 base, plus rank +0 / +2 / +4 / +5. Column family: crops mind, tools and crafts craft, pals body (`PFB_SRC_FAM`).

| # | Source (file) | Trigger that already exists | Piece idea | Adds | Risk |
|---|---|---|---|---|---|
| A | **One piece per crop** (`crops.txt`, `food_mastery.php`) | `grown > 0` for that crop | Generated like pal pieces, key `c:SLUG`: type and tag from the kind (today's 9 rows become the templates), value 2-5 from crop tier 1-6, right knob from the crop's own row. "Tomato: a crunchy bite. Heal." Rank = that crop's own mastery. | up to 194 owned | Biggest bloat risk: needs the Larder rule (section 3). 194 pieces cannot all feel different; about 20 hand-written ones (Village Show crops, treasure seeds) carry the flavour. |
| B | **One piece per dish** (`recipes.txt`, `user_recipes`) | `made > 0` for that recipe | Generated, key `f:SLUG`: type from the dish's biggest buff stat (grit Hurt, hardiness Guard, charm Charm, nimble Guard evade, lore Trick, sense Soothe, luck Item); value by tier: snack 3, meal 4, feast 6, preserve 3 with life 4. Mind column. "Three Sisters Stew: filling. Hurt 4." | up to 241 owned | Same as A. Feast at 6 + rank is knack-Smash level: count feasts as Rare. Decide whether a food piece uses up a dish (recommend no: Snack already does that). |
| C | **NPC friendship** (`friends.php` `FRIEND_LEVELS`, table `npc_friends`) | Best friend (500 points) with a townsfolk NPC | One piece per NPC, key `n:SLUG`, Charm or Guard family, body column, value 4, fixed Uncommon. "Burdock's Word: a friend spoke up for you. Charm, and it calms." Start with the 6 calling mentors (`CALLING_MENTORS`). | 6 first; more as written | Hand-written, so slow to bloat. The number of NPCs in the table was not counted. |
| D | **The Gourmand** (`gourmand.php`) | Tastes (`gourmand_tastes`): beats exist at set counts; Home Plate at 10, finale at 14; Golden table per region | 3 pieces: first Taste "Napkin Flick" (Trick 3); 10 Tastes "Second Helping" (Heal 5, life 2); 14 Tastes "Pomeroy's Table" (Charm 6, Rare). | 3 | Small and safe. Long to earn, so the Rare is fair. |
| E | **Lair bosses** (`landmarks.php` `lair_victory`, `landmark_clears`) | first win over a legendary boss (ribbon today) | One trophy piece per boss, built from that boss's own unique piece in `pf_creature_pieces.txt` at player scale: Hurt 5-6, tagged, Rare. "Bramblehorn's Charge." | 9 boss creatures | Power creep: Rare cap of 3 already limits it. Only Hurt source here that is earned by fighting. |
| F | **Fair and Village Show ribbons** (`fair.php` `fair_ribbons`, `contests.php`) | any ribbon; a blue ribbon | 2 pieces: "Show Ribbon" (Charm 4, bond) for a first ribbon, "Best in Show" (Charm 6, Rare). | 2 | Multiplayer and monthly: a new gnome waits weeks. Keep it to bragging, not power. |
| G | **Almanac milestones** (`almanac.php`, `almanac_milestones`) | milestone rows already pay rewards | 3 pieces at page-count milestones: "Field Note" (Trick 3), "Pressed Leaf" (Guard 4, hold), "Whole Shelf" (Trick 5, Rare). Mind family. | 3 | Low. Overlaps region pieces (guides are Almanac pages too). |
| H | **Delves** (`delve_v2.php`, `landmark_clears`) | first clear of a delve | "Torch Glare" (Charm 3, lull) at 1 clear, "Deep Breath" (Heal 4) at 10. | 2 | Delves are behind `delve_v2`. Lantern tool piece already covers the theme. |
| I | **Wonders and Havens** (`landmarks.php` `wonder_try`, `haven_act`) | daily visits; no lifetime tally found | none yet | 0 | No lasting progress to hang a piece on. Leave out. |
| J | **Trail Sights** (`trail_sights.php`, `trail_sight_tally`, `user_sight_titles`) | tallies and sight quests | One piece per finished sight quest line. | few | P0 spike, per-map content still moving. Later. |
| K | **Mini-games and Puzzles** (`games.php` 8 games, `puzzle_games.php` 2, Jigsaw) | weekly high scores, daily wins | none | 0 | Scores are weekly and competitive; skill at Seed Spitting should not buy combat power. Jigsaw already feeds the deck through Puzzle Pals. Leave out. |
| L | **Cat Fish** (`catfish.php`) | titles at 15 and 30 (`CATFISH_TITLES`) | "Cat Nap" (Heal 3, life 2) with the Napmaster title. | 1 | Idle game behind `catfish_open`; one joke piece at most. |
| M | **Festivals** (`festival.php` `flag_rewards`) | 7 flags gives a title | One keepsake piece per festival. | 1 each | Time-limited pieces lock out late joiners. Only if it stays Common. |
| N | **Perks, seasons, Hollow Goals, First Week, Lost Letters, mentors (player)** | temporary or shared | none | 0 | Perks last 7 days; goals are shared. Not a fit for an owned piece. |

Already covered, no new source needed: regions (14 pieces), crafting mastery (ranks the 7 craft pieces), Puzzle Pals (gear), tools.

## 3. The rule that stops bloat

The owner decided "no max deck size" (design doc, decisions list). Keep that, and limit by **slots per source**, the way the belt limits tools:

| Slot group | Holds | Slots | Grows by |
|---|---|---|---|
| Belt (exists) | tool pieces | 2 / 3 / 4 | belts at Twigg's |
| **Larder** (new) | crop and food pieces | 3, then 4 at level 10, 5 at level 20 | level, or a Pantry upgrade |
| **Keepsakes** (new) | friend, Gourmand, trophy, ribbon, Almanac, delve pieces | 2, then 3 at level 15 | level |

Plus one change to today's rule: **a newly owned piece arrives switched off** with a "New" mark in the Puzzle box (today crop, craft and region pieces arrive on). Region and craft pieces stay un-slotted but off by default. Swapping is free outside a fight (the deck already locks during one, `pfd_locked`). Result: the deck a fight sees stays near 14 to 24 however much the gnome owns, and owning 194 crops becomes a collection to choose from, not a pile in the hand.

## 4. Ranked recommendation

| Rank | Build | Why first | Work | 
|---|---|---|---|
| 1 | Larder slots + "new pieces arrive off" | Fixes bloat that exists today and is the gate for everything else | `pfdeck.php` (`pfd_build` default `on`, new counts and `pfd_validate` messages, `pfd_sources_blank` gets `larder`, `keeps`), `pfdeck_view.php` (slot row like the belt), `tests/pfdeck_v1.php` |
| 2 | A: one piece per crop | The owner's stated rule; data and trigger exist | `pfd_sources` keeps crop slug and its own tier; generator beside `pfd_pal_pieces`; optional override column in `crops.txt` for the 20 hand-written ones; lint in `tests/pfdeck_v1.php`. The JS board takes tiles as data, so no engine change is expected (to confirm in `tools/pfengine.js`) |
| 3 | B: one piece per dish | Same rule for food; makes cooking matter in fights | generator from `recipes.txt` + `user_recipes.made`; retire or keep Hot Soup and Pickle Splash as the "never cooked" fallback |
| 4 | D + C(6 mentors): Gourmand 3, mentor friends 6 | Nine hand-written pieces, strong story hooks, tiny risk | 9 rows in `pf_pieces.txt` with new sources `friend`, `gourmand` (add to `PFD_PLAYER_SRC`, `$owned`, `PFB_SRC_FAM`); `pfd_sources` reads `npc_friends`, `gourmand_ledger` |
| 5 | E: lair trophies | The one reward for fighting well; Rare cap keeps it in check | rows keyed `b:SLUG`; `pfd_sources` reads `landmark_clears` |

Leave out for now: mini-games, Puzzles, wonders, havens, perks, seasons, Hollow Goals, festivals, Cat Fish, Trail Sights (reasons in the table). Fair ribbons, Almanac and delves are fine as a later batch of 7.

## 5. Sim plan

1. Baseline: `php tests/pfboard_tune_v1.php BOT=chain` and `BOT=smart`, `OFFSETS=0,-4`, save the table (targets: chain about 70% at level, smart 90%+, 6-8 turns).
2. Add an env switch to `tv_sources` (for example `SRCS=now|larder|all`): `now` = today; `larder` = 3-5 Larder pieces by level and 2-3 Keepsakes at the proposed values; `all` = everything on, no slots (the bloat case).
3. Compare win %, health lost and turns per size. Pass: `larder` within 3 points of baseline win % and no more than half a turn longer; `all` is expected to fail (shows why the slots exist).
4. Worst-case deck: 3 Rare (feast, lair trophy, Pomeroy's Table) + 1 Masterwork tool at level 30 against bosses. If smart goes above 97%, drop feast and trophy base values by 1.
5. Rerun the harmony check in `tests/pfdeck_v1.php` (every one-tap starter links on 90%+ of hands) with generated crop and food pieces, since their knobs come from data and could cluster in one family.

Not verified in this pass: how many townsfolk NPCs exist, the exact Gourmand beat thresholds between 1 and 10 Tastes, and whether each of the 9 boss creatures maps to one lair. Check those before writing rows.
