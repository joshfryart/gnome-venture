# Review: Gourmand rewards vs the real economy (2026-10-30)

Scope: section 6 of `claude/proposal-gourmand.md` (lines 245–277), read against the live economy in `game/`. Numbers below come from a fresh SQLite install of the current tree (temp copy, `install.php`, then `tests/balance_sim.php` and direct item queries). No game code was changed. Decisions in `claude/decisions-gourmand.md` (item 2: no visit window, he is reachable in every region at all times) are taken as given, and they matter for question 2.

Two questions from Joshua (proposal 8.6 #6):
1. Are 14 treasure seeds over a lifetime too generous?
2. Should the repeat tip (25 Petals) double on festival day?

**Short answer: (1) No. Keep 14, one per region, exactly as proposed. (2) No. Keep the tip flat at 25 and give festival day a non-Petal bonus instead.**

---

## 1. Treasure seeds: what one is worth today

### 1.1 Where treasure seeds already come from

| Source | Rate | Evidence |
|---|---|---|
| Weekly job "Feast day" (deliver 3–5 dishes) | 600 Petals + **1 treasure seed**. 5 of ~8 weekly templates are offered each week (`JOB_PERIODS`), so it is on the board most weeks. | `game/includes/data/jobs.txt:21`; `game/includes/jobs.php:5,16` |
| Monthly job "Harvest Festival order" | 4,000 Petals + **2 treasure seeds** | `game/includes/data/jobs.txt:27` |
| Monthly job "Village kitchen" (cook 30–45 meals) | 3,000 Petals + **1 treasure seed** | `game/includes/data/jobs.txt:31` |
| Village Show, 1st place (weekly) | 1,000 Petals + **1 treasure seed** | `game/includes/contests.php:24` |
| Lair boss: first win | **100%** chance of a treasure seed, 14 lairs in the world | `game/includes/landmarks.php:476-479`; `game/includes/data/landmarks.txt` (14 `lair` rows) |
| Lair boss: every later win | **25%** chance, once a day per lair | `game/includes/landmarks.php:476` (`$first ? 100 : 25`), `landmarks.php:8,43-61` (once a day) |
| Seed saving on harvest | `seed_save_chance` default **60%** (+ soil life/4 + 2×grade + 3×sense), divided by 3 for perennials; all 42 treasure crops are perennial, so about 20–25% per harvest, and a perennial regrows for its whole life | `game/includes/functions.php:469`; `game/includes/garden_logic.php:1352-1360`; DB: `SUM(perennial)` over treasure plants = 42/42 |
| Seed shops | **Never.** Shops stock a region's uncommons and flowers only | `game/includes/catalog.php:421-434` |

So an ordinary active gnome already sees roughly 3–4 treasure seeds a month from the Job Board alone (Feast day about 0.6 × 4.3 weeks, plus the two monthlies at about 3/7 odds each), and an end-game gnome who clears lairs daily sees several a day (14 lairs × 25%). Every one of those is a *random* treasure seed from the pool of 42 (`game/includes/jobs.php:270`).

### 1.2 What a treasure seed is worth

- Base price 100–121 Petals, rarity 93–95 (all 14 proposal seeds checked in the DB). Sell price with the Legendary multiplier (`sell_mult_legendary` 250%, `game/includes/functions.php:475`) is **158–218 Petals** (pecan-seed 218, saffron-seed 158). So the whole Golden-table seed grant is worth about **14 × 190 ≈ 2,700 Petals** if sold, less than the 4,200 Petals of Golden-table cash that comes with it.
- The real value is not Petals. Each treasure crop gives a permanent +1 to a stat the first time it is eaten, capped at `food_perm_cap` = 5 per stat (`game/includes/gnome.php:413-425`; DB effects e.g. `pecan`, `yuzu` → `perm luck +1`). 42 treasures against a 7 × 5 = 35 cap, so a player who already has a few seeds from jobs and lairs is mostly at cap by the time they can win a Golden table.
- Planting a treasure crop needs the region studied (home, a garden there, a guide or a Journey chapter: `game/includes/trade.php:339-349`, `garden_logic.php:631-648` unstudied slowdown). A Golden-table seed is for the region the player has just mastered food from, which is exactly the region they can plant it in. That is the one thing the random job/lair seeds do not give: a **targeted** seed.

### 1.3 How hard a Golden table is

Golden needs all three courses at 3 spoons (proposal 5.3):
- Plate 65+: `fair_quality` = 0.35·fertility + 0.25·nutrient + 0.20·soil life + grade + native 5 + luck ≤4 ± 3 (`game/includes/fair.php:65-79`). Tops out at 80 from perfect soil before grade, so 65 needs a well-fed, high-grade bed.
- Pot 65+: the new dish score 0.8·ingredients + 4·kitchen + luck (proposal 5.2) needs ingredient quality around 66 even at Kitchen III: the same high-grade beds.
- Jar 62+: `pantry_quality` = 38 + min(20, 2·days) + 3·kitchen + 3·min(4, kinds) + luck ± 3 (`game/includes/pantry.php:113-120`): a 7-day ferment or a 14-day cordial at Kitchen III.

So one Golden table is a Kitchen III, a Pantry (600 Petals, `functions.php:517`), a far-region garden or fast travel there, and a month's planning. Fourteen of them are many months of play. By then the player is farming lairs for seeds at 25% a day.

### 1.4 Verdict on question 1

**14 treasure seeds over a lifetime is not too generous. Keep it.** It is a trophy with a use, not an economy lever:
- Cash value about 2,700 Petals total, under the medal cash it travels with.
- Supply from existing sources is far higher (a single lair-farming week beats it).
- It is the only *targeted* treasure seed source in the game, which is the right flavour for "I tasted your region's food, here is its treasure".

Two small notes, not changes to the count:
- The Full-table "2 × plate-crop seed" (proposal 4, line 138) is flavour only: wild-rice-seed 59, tomatillo-seed 52, coconut-seed 109 Petals, and uncommons are already on sale at seed shops. Fine as-is; do not make it bigger.
- Do not raise Golden to 2 seeds "to make it feel special": seed saving on a perennial (about 20–25% a harvest for its whole life) already turns one seed into a grove.

---

## 2. Petal sizes, for context

| Gourmand (proposal 6.1) | Existing comparable | Evidence |
|---|---|---|
| Lifetime cash about 18,000 | Region medals 14 × (200 + 500 + 1,500) = **30,800**; calling questlines 6 × (800 + 1,600) = **14,400**; "The complete Almanac" **25,000** | `game/includes/catalog.php:350-358`; `game/includes/data/calling_quests.txt` (C rows, fields 7–8) |
| Monthly repeat ceiling about 1,050–1,125 (42 courses × 25) | One daily job 50–90 (about 2,100/month); one weekly 450–600 (about 2,200/month); one monthly 3,000–4,500; Harvest Fair 1st 600 per class × 6 classes + 1,000 Best in Show; Catfish capped at **100/week** | `jobs.txt:9-30`; `functions.php:396-402,356` |
| Late-game garden pace | **5,022 Petals/hour** energy-limited on treasure perennials at L10+ (sim) | `tests/balance_sim.php` "Pace per hour" output |
| Sinks | Land deed 5,000, guide 6,000, skins 1,500–4,000, signposts 1,200–6,000, dyes 800–6,000 | `functions.php:465,555,512,514,515` |

18k lifetime is about one land deed plus a building skin, spread over many months, and the monthly repeat income is under one week of weekly jobs. The game has nerfed side activities that out-earned the garden before (`games_petals_percent` 60%, "games out-earned the garden", `functions.php:379`); the Gourmand is nowhere near that line. The Petal sizes in 6.1 are fine.

Anti-pump check (proposal 6.4 #4): the tip of 25 is well under what a served item sells for: apple-crumble sells 177, apple-cider 259, kimchi 91, hummus-jar 52, raspberry-jam 66 (fresh-install `sell_price`). Only the raw Plates are cheap (3 × wild-rice sells 81, 4 × sorrel 92), still over 25. The claim holds.

---

## 3. Should the repeat tip double on festival day?

**No. Keep the tip at 25 flat; make festival day a non-Petal bonus.**

Why:
1. **The decision removed the thing that made it harmless.** In the proposal, he was only in a region for 48 h, one of which was festival day, so "double on festival day" was a coin flip that rewarded showing up. `decisions-gourmand.md` item 2 makes him reachable in every region at all times, and `TOWN_FESTIVALS` (`game/includes/town.php:36-52`) gives every region a known festival day each month. A doubling tip then just says: serve each region on its festival day. Optimisers get 50 every time (42 × 50 = 2,100/month), everyone else gets 25, and the 14 festival dates become a chore calendar for a feature whose stated rule is "no daily-chore pressure" (proposal 6.4 #5).
2. **It is the wrong mirror.** The existing "festival day pays twice" rule (`town.php:393-396`) doubles the *event effect* of a town-square action, small things you only do standing in that square on that day. The tip is a repeatable, plannable, item-backed payout; doubling it is a different kind of rule wearing the same name.
3. **It buys nothing.** 2,100 vs 1,050 a month is noise next to a 5,000 Petal/hour garden, so it will not break the economy, but it will not motivate anything either; a player who wants Petals sells the jar (259) rather than serving it (50).

What to do instead on festival day (keeps the proposal's beat 7, "he wears the festival hat"):
- Double **friendship** with Pomeroy on a festival-day serve (+5 → +10, +10 → +20 at 3 spoons), through `friend_add()` as proposed. Friendship is not sellable, and it is the thing his story is about.
- Optionally double the tip's **XP** (8 → 16) and leave the Petals alone. XP is level-gated and does not touch the market.
- Keep the Long Table seat buff (`tbuff:charm:2:240`) as the only calendar-timed Petal event (50, per tour).

If Joshua still wants a Petal doubling anywhere, confine it to the **Long Table on day 1** (one date, hub region, everyone can reach it: `can_reach()` and `HUB_REGION`), which is a party, not a schedule.

---

## 4. Recommendation (one line each)

1. **Treasure seeds:** keep 14, one per region, Golden table only. Worth about 2,700 Petals in total; targeted by region; slower and rarer than jobs (1–4/month) and lairs (25%/day/lair, `landmarks.php:476`).
2. **Repeat tip:** keep 25 Petals and 8 XP, never doubled. Festival day doubles friendship (and, if wanted, XP), not Petals.
3. **All other sizes in 6.1 stay** (60/60/120 spoons, 150 Full, 300 Golden, 200 Grand, 1,000 finale). Lifetime about 18k sits between calling lines (14.4k) and medals (30.8k).
4. Update proposal 6.1 (line 254) and beat 7 (line 42) when this is accepted, and drop the "or about 2,250" clause at line 270.
