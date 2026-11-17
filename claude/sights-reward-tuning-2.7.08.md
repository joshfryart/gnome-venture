# Sights reward tuning (2.7.08): measured, with a proposal (nothing changed yet; Josh approves)

**Short answer.** Today a Sight pays about **1/3 of a Gather per energy** (mean 2.9 XP + 4.9 Petal-value of goods at level 1). Target: **about one Gather per energy** = ~15 Petal-value, with 1 XP counted as 1 Petal. Do it with one knob (XP and Petals x1.5) plus one data rule (`c=7` on the thin rows). A few rows also change on their own: 8 free rows get an energy cost, 3 rows are trimmed and 1 row stops giving back more energy than it costs.

## How it was measured
- All 219 rows of `trail_sights*.txt`, plus 39 quest lines (214 beats) and 223 villager rows. Item prices come from a scratch install's `items` table (1,812 items) and from `trail_sight_items*.txt`. Method: `rewards` parsed as `trail_sight_do` reads them.
- Petal-value of an item = `floor(base x 62.5%) x rarity` (C 1.0, U 1.3, R 1.8, L 2.5). That is `sell_price()` at the middle of the 45-80% price drift.
- Expected value per use = success chance x sum of (chance% x condition odds x value). Checks assume a stat mod of 0: success = (21-dc) x 5%, and a `pick:N` succeeds 1 time in N. Cost = energy + miss chance x `fail_en` - `en=` paid back.
- `first:` tokens and `tn=` milestones are counted once, apart from the per-use value. `tl=` milestones are counted as always met.
- Level: L1 = NA / Maplewold. L10 = SE. `xp=a:b` pays a + b x level. Flat `xp=` / `c=` grow 3% a level (`sights_flat_pct_per_level` = 3, default since 2.7.00).

## Baselines (per 1 energy)
| Activity | XP | Petal-value | Source |
|---|---|---|---|
| Gather, Worn tool (tier 1) | 0 | min 7.5 / **median 15.0** / max 17.5 (29 land x tool pairs) | `gather_here`: 2.5 items a find with the sleep-days clock (`random_int(2,3)`) |
| Gather, Sturdy (tier 2) / Fine (tier 3) | 0 | median 20.8 / 36.5 | same; does NOT grow with region level |
| Rest-stop check acts (161, same reward code) | median 6 (L1), 15 (L10) | median 14 (L1), 41 (L10) | `stop_acts*.txt` |

## Sights today (L1 unless marked)
| Kind | n | XP / use (min / med / max) | goods / use | per net energy |
|---|---|---|---|---|
| energy 1 | 132 | 0 / 3.0 / 10 | 0.1 / 3.0 / 37.3 | mean **2.9 XP + 4.9 goods**; goods p25 1.1, p75 5.9; 31 rows under 1 |
| energy 1, L10 | 132 | 0 / 9.5 / 17 | 0.1 / 3.1 / 37.3 | mean 9.2 XP + 5.3 goods |
| energy 0 (free; 10 game min) | 87 | 0 / 3.0 / 7 | -43.6 / 2.3 / 40.7 | no energy at all: limited only by the cooldown |
| tally / streak rows | 97 | 1 / 2.8 / 5 | median 2.9 | the same as plain rows; the milestones are titles and pages |
| first-time gifts | 80 rows | `first:xp=10` mostly; 655 XP over all rows | 234 in total | one-off |
| quest reward per beat | 39 lines | 8.6 / 12.0 / 20 | 8 / 21 / 94 | one-off, on top of each beat's own Sight use |
| villager auto-pay (189) / give (34) | | median 0 | median 0 / 25 | mostly friendship |

Rewards with no Petal price (not counted above): 132 tally, 103 title, 74 buff, 24 page, 22 hint, 9 reveal, 8 fp/fpto, 2 streak.

**Rows far from the rest:**
- **Too rich (more than 2 Gathers):** `232-berrypatch` 37.3 (`blueberry`, a treasure crop, @30; 2 uses), `312-bramble` 36.6 (`raspberry:1` every time), `apple` 27.8, `315-feather` 21.2.
- **Free and rich:** `scarecrow` 40.7 at **0 energy** (`pretty-feather` @20 is worth 178).
- **More than 10 goods at 0 energy:** `end-haven-2-grassland` 23.2, `end-lair-2-forest` 14.7, `end-haven-2-island` 12.3, `desert-the-sand-ripple-lane` 11.6, `end-delve-1-mountain` 10.2, `309-snowmen` 10.1, `end-lair-2-coast` 10.1.
- **Gives back more energy than it costs:** `311-sugarshack` (energy 1, `en=2`, plus `xp=10`).
- **Pays 0 to 1 a use:** 31 energy-1 rows (they pay in titles, buffs and hints).

## Targets per kind (L1, per net energy; 1 XP = 1 Petal)
1. **Plain act (energy 1):** 10-12 goods + 4-5 XP, about 15 in all, which is about 1 Gather. At L10, XP should match rest-stop acts (~15 a energy). No row over 30 goods (2 Gathers).
2. **Tally / streak:** each use as for a plain act. Milestones stay titles and pages, with no extra Petals: they are one-offs and are already unpriced.
3. **Quest:** at most ~2 Gathers of goods and 10-20 XP a beat, paid once. The median today is 21 + 12, so **no change**. 4 lines go over 50 a beat: `echo-map` (hiking-staff 520), `follow-your-nose` (feast cake 678), `rest-here-repainted` (c=120 + wind chime), `mabels-sky-letters`. Their value is designed reward items, paid once in a line, so I left them. Josh decides.
4. **First-time gift:** about 1 Gather once (~15 XP). The knob below turns `first:xp=10` into 15 by itself, so there is no data edit.
5. **Free (energy 0) rows:** at most 5 goods a use, and XP as for a plain act. A free row worth more than 10 a use gets energy 1.

## The proposal (exact)
- **Knob:** the constant `1.0` in `game/includes/trail_sights.php:417`, `stop_rewards($u, $loc, implode(',', $plain), 1.0)`, scales only the Sight row's own `c=` / `xp=` tokens (including `choose=` and `first:`).
  - Villagers and quests pay through `trail_sight_extras.php:576` and are not touched.
  - Set it to **1.5**. Better: make it a new setting `sights_reward_pct`, default 100, set to 150.
  - Do **not** use `stop_reward_percent`: rest stops share it.
- **Data rule:** add **`,c=7`** to every row that meets all three conditions:
  - energy at least 1;
  - no `c=` token yet;
  - its L1 goods are under 10.
  That is 100 rows: 46 Maplewold, 49 shared, 2 end, 3 base. With the knob, c=7 pays 11 Petals at L1 and 14 at L10.
  These 19 rows are already at 10 or more and stay as they are: island-the-reef-shallows, end-delve-2-forest, apple, 232-berrypatch, 236-dandelions, 236-haywagon, 304-acorndrop, 304-owloak, 306-mosslog, 306-mossgate, 307-sandcastle, 312-bramble, 313-glowtunnel, 315-stream, 315-feather, grassland-the-dandelion-drift, wetland-the-willow-curtain, mountain-the-goat-ledge, coast-the-tide-pool-steps.
- **Energy 0 -> 1:** scarecrow, end-haven-2-grassland, end-haven-2-island, end-delve-1-mountain, end-lair-2-coast, end-lair-2-forest, 309-snowmen, desert-the-sand-ripple-lane.
- **Trims:**
  - `232-berrypatch`: `item=blueberry:1@30` -> `@8` (37 -> ~18).
  - `312-bramble`: `item=raspberry:1` -> `item=raspberry:1@40` (37 -> ~17).
  - `scarecrow`: `pretty-feather` @20 -> @5, `shiny-trinket` @10 -> @5.
  - `311-sugarshack`: `en=2` -> `en=1` (the row then costs nothing, as a rest).
- **Optional villager trim:** `end-wonder-2-mountain` Mabel Burrowby `cold-brew-coffee` (base 524) @40 -> @15. It pays automatically after a win.

**Simulated result (the same script on an edited copy of the data):**

| | XP / energy | goods / energy |
|---|---|---|
| Energy-1 rows, L1, mean | 4.4 (was 2.9) | 10.3 (was 4.9) |
| Energy-1 rows, L10, mean | 14.2 (was 9.2; rest stops 15) | 12.5 (was 5.3) |

So a Sight now pays about 1 Gather per energy at L1. No row is over 2 Gathers: the highest is `apple` at 27.8.
Free rows: 79, mean 4.2 XP and 2.5 goods a use. First-time XP over all rows: 655 -> 982.

## Not measured (flags)
- **Petal budget.** I could not find how many Sights a player uses a day. If it is 5 a day, the change adds ~+385 Petals in week 1, about +4.5% of the ~8.5k earned. Days 1-3 are already flush. If that is too much, start the knob at 125.
- **Assumptions in the model:**
  - weather is 1 in 9 per value;
  - `st=` is 1 in 3, `pal=` is 1 in 2;
  - stat mod 0, with no Luck reroll and no Charm;
  - no shop-price cap in `sell_price`;
  - Gather with no basket, Sense or rainbow;
  - `take=any-*` is worth 5 an item.
  - The 5 wearable slugs (travel-cloak, flood-boots, wayfarers-hat, trail-pack, work-gloves) count as 0, because they drop only with `pfight_v1` on.
- **No anchor I could use:** Gather gives no XP, so XP was compared with rest-stop acts. The XP a harvest earns per energy over a whole crop cycle (planting and watering included) was not measured.
- **No price at all:** buffs, titles, pages, hints and friendship.
- **Missing in code:**
  - There is no per-walk cap on Sight uses. The plan said 6; only the per-section cooldown limits them.
  - The docblock of `trail_sight_flat_scale` still says "default 0 = off ... 2.5", but the setting has been 3 since 2.7.00.
- **Not verified in play:** check odds for real gnome stats, and real weather frequencies.
