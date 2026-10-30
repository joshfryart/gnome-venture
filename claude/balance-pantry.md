# Pantry balance test: 156 preserves, the Gourmand jars and the 16 Pomeroy recipes

Run 2026-10-30 on a fresh SQLite install (made by `tests/walk.sh`, branch `ccr-b73ceb76-4mtdt1`). Nothing in the game code or `recipes.txt` was changed.
Scripts (scratchpad, not committed): `pantry_balance.php` loads the installed world through `includes/bootstrap.php` the way `tests/pantry.php` does, then dumps every recipe, its ingredients' `sell_price()`, rarity, region tier, shop and market-stall prices. `analyze.py` does the maths.

**Prices in this report are "canonical".** Drift is off (`price_drift_on = 0`), so shops pay 60% of base price, times the rarity multiplier (Uncommon 130%, Legendary 250%). A preserve's price is worked out the way `import_recipes()` does it: `max(20, ceil(V × (1.3 + 0.5√days) / qty / 0.6))`, where V is the sell value of the crops that go in. The installed world does not match these numbers, for two reasons covered in finding 1.

The task brief says 154 preserves. `recipes.txt` has **156** rows with the `preserve` tier: the original 17, the 137 added in the expansion, plus chicha and poi from Gourmand P2. All 156 imported.

---

## Summary verdict

**The design mostly holds up. Two bugs need fixing, and one curve needs Josh's call.**

1. **Bug: preserve prices are fixed at install time from that week's drifted prices and a stale cache.** 147 of the 156 preserves get a different `base_price` from the canonical one: drift makes them 0.78× to 1.33×. Six of them come out **about 2.6× too high**: jostaberry-jam, pluot-jam, nectaplum-jam, meyer-lemon-marmalade, tangelo-marmalade and pickled-fiddleheads. The cause is `sell_price()`'s `static $L = item_lookups()` cache. It is built before the hybrid plants and the fiddleheads gatherable exist, so their raw `items.rarity` of 85 to 95 reads as Legendary (×2.5). On a fresh world, **jostaberry-jam earns +756 Petals per jar per day**, more than double the next-best preserve. This is the real top outlier.
2. **Bug: market stalls undercut sell prices for Legendary and Rare items.** A stall charges base × 115% × 90–110%, with no rarity multiplier. Shops then buy back at base × 60% × 250%. **26 treasure crops, plus golden-carp and morel, can be bought at a stall and sold straight back for a profit.** Example: blueberry costs 58 at the stall and sells for 83 (110 when wanted). Routed through a 1-day jam, 5 stall blueberries cost 290 and the batch sells for 748, so **+458 per jar-day**. 154 of 155 stall-buyable preserves turn a profit when every ingredient is bought at a stall. This breaks the v1.0.0 rule in `sell_price()`, "buying and selling again can never make money": that cap only checks `shop_stock`, never the stalls. It is held back only by the weekly market day, the 3-per-stall limit and random stock.
3. **Curve (Josh's call): long timers are poor per jar-day.** Gain over selling the crops raw, per jar-day, falls from 0.80·V for 1-day jams to 0.155·V for 14-day cordials. That is **19% of a jam's rate**, and the medians are 144 against 23 Petals per jar-day. Cordials only win for a gnome who checks in about once a week. Their compensations are bigger buffs, 3-spoon quality and the Fair. A gentler curve, `1 + 0.8·d^0.6`, would keep jams the same and raise 14-day preserves to 35% of a jam's rate.
4. **Treasure-crop 1-day preserves are rich, but in proportion.** blueberry-jam, gooseberry-jam, cranberry-sauce, cloudberry-jam and quince-paste each make 281 to 333 per jar-day. That is 2.1× the best uncommon jams and 10× strawberry jam. The jar markup is the same 1.8× for every jam, so the gap is only the crop's value. That value comes from treasure crops selling at 250%. With the stall bug fixed, this is acceptable. An optional 2-day timer is listed below.
5. **The 20-coin floor never applies** at canonical prices: the lowest raw price is pickled-kale at 21.7. Under install-time drift at its low (45%), it would apply by less than 4 coins to bilberry-jam, pickled-kale and pickled-mushrooms. That is not worth changing.
6. **Buffs are in line.** No preserve beats a meal's strength at any one moment: preserves give at most +3 stats, meals +4, feasts +7. Cordials and cheese-wheel do give the most stat-hours of anything: 3 stats × 24 h = 72, or 108 at Kitchen III, against 56 for a median feast. They are a weak, all-day buff that takes a feast's place in the single buff slot. That is reasonable.
7. **The quality bars are reachable by design, with one wrinkle.** Four Pomeroy jar asks can **never** reach 3 spoons. They are plum-jam (EE/1), raspberry-jam (NA/1), lingonberry-jam (NWE/1) and guava-jam (CB/1), and each tops out at 59 against a bar of 62. Eight more reach 3 spoons only on a lucky roll at Kitchen III with Luck +4. Every region still has another variant that can reach 3 spoons (`tests/gourmand.php` asserts this), and the ledger keeps the lifetime best, so a Golden table is never blocked. The wrinkle is that those months cap at 2 spoons.
8. **There are near-duplicates.** In 16 groups, two or more preserves share the exact same ingredient set. Two of them are strictly dominated: goat-cheese by yogurt, and fermented-carrots by pickled-carrots.
9. **The 16 Pomeroy recipes are in line.** The 14 dishes match the existing meal and snack profiles: meals give 4 stats for 240–300 min and 10–11 energy, snacks 3 stats for 180 min and 7–8 energy, and both sell for 1.43× their ingredients. Chicha (5 days) and poi (7 days) match the other 5- and 7-day ferments and reach 3 spoons comfortably: 63/64 before the roll at Kitchen III.

---

## 1. Pricing at install (bug)

`import_recipes()` prices each preserve from `sell_price($ingredient)`. On an install that call has two problems:

* **Drift is on** (`price_drift_on` defaults to 1). That week's noise, season, "wanted" bonus and sales volume all get fixed into `base_price` for good, because import never changes an item that already exists. Measured stored/canonical ratios run from 0.78 to 1.33, and only 9 of the 156 match exactly. Every world prices its jams differently. `tests/pantry.php` turns drift off before it compares prices, which hides this.
* **The `item_lookups()` cache is stale.** `sell_price()` keeps `static $L` for the whole request. The cache is filled before the hybrids (breeding110) and fiddleheads get their plant or gatherable rows, so `item_rarity()` falls back to `items.rarity`. For those items that is 85 to 95, which reads as Legendary (×2.5).

| preserve | stored base | canonical base | × | live batch | crops V | live gain per jar-day |
|---|---:|---:|---:|---:|---:|---:|
| jostaberry-jam (1 d) | 399 | 150 | 2.66 | 956 | 200 | **756** |
| pluot-jam (1 d) | 354 | 138 | 2.57 | 848 | 184 | 664 |
| nectaplum-jam (1 d) | 339 | 138 | 2.46 | 812 | 184 | 628 |
| meyer-lemon-marmalade (2 d) | 419 | 154 | 2.72 | 753 | 138 | 308 |
| tangelo-marmalade (2 d) | 412 | 154 | 2.68 | 741 | 138 | 302 |
| pickled-fiddleheads (3 d) | 650 | 246 | 2.64 | 1170 | 204 | 322 |

The live server may differ, depending on the order the upgrade ran in. **Check these six items' `base_price` there.**

## 2. Top and bottom 15 by gain per jar-day (canonical)

Gain = batch sell − crops' sell (V). Every batch sells for more than its crops: the ratio is 1.79–3.19, exactly the formula. "T" counts the treasure (Legendary) crops among the ingredients.

**Top 15**

| # | slug | days | qty | ingredients | V | batch | gain/jar-day | T | regions |
|---:|---|---:|---:|---|---:|---:|---:|---:|---|
| 1 | blueberry-jam | 1 | 4 | blueberry:5 | 415 | 748 | 333.0 | 1 | Maplewold |
| 2 | gooseberry-jam | 1 | 4 | gooseberry:5 | 415 | 748 | 333.0 | 1 | Mistmoor |
| 3 | cranberry-sauce | 1 | 4 | cranberry:5 | 415 | 748 | 333.0 | 1 | Maplewold |
| 4 | cloudberry-jam | 1 | 3 | cloudberry:5 | 415 | 747 | 332.0 | 1 | Mistmoor |
| 5 | quince-paste | 1 | 3 | quince:4 | 352 | 633 | 281.0 | 1 | Birchbramble |
| 6 | pear-butter | 1 | 4 | pear:4, cinnamon:1 | 244 | 436 | 192.0 | 1 | Birchbramble, Spicepeak |
| 7 | almond-butter | 3 | 4 | almond:5 | 440 | 952 | 170.7 | 1 | Dunewhisper |
| 8 | hazelnut-spread | 3 | 4 | hazelnut:4, cacao:1 | 440 | 952 | 170.7 | 2 | Mistmoor, Maizehollow |
| 9 | dried-cranberries | 3 | 4 | cranberry:5 | 415 | 900 | 161.7 | 1 | Maplewold |
| 10 | jostaberry-jam | 1 | 4 | jostaberry:4 | 200 | 360 | 160.0 (live: 756) | 0 | hybrid |
| 11 | cherry-jam | 1 | 4 | cherry:5 | 195 | 352 | 157.0 | 0 | Birchbramble |
| 12 | apricot-jam | 1 | 4 | apricot:5 | 195 | 352 | 157.0 | 0 | Spicepeak |
| 13 | peach-jam | 1 | 4 | peach:5 | 195 | 352 | 157.0 | 0 | Blossomreach |
| 14 | fig-jam | 1 | 4 | fig:5 | 195 | 352 | 157.0 | 0 | Olivewhistle |
| 15 | mulberry-jam | 1 | 4 | mulberry:5 | 195 | 352 | 157.0 | 0 | Spicepeak |

**Bottom 15**

| # | slug | days | qty | ingredients | V | batch | gain/jar-day |
|---:|---|---:|---:|---|---:|---:|---:|
| 142 | dill-pickles | 3 | 3 | cucumber:4, dill:1, garlic:1 | 40 | 87 | 15.7 |
| 143 | pickled-samphire | 3 | 3 | samphire:4 | 40 | 87 | 15.7 |
| 144 | cucumber-kimchi | 5 | 3 | cucumber:4, chili:1, garlic:1 | 55 | 132 | 15.4 |
| 145 | cheese-wheel | 14 | 3 | goat-milk:8 | 96 | 306 | 15.0 |
| 146 | lemongrass-cordial | 14 | 3 | lemongrass:3, ginger:1 | 87 | 276 | 13.5 |
| 147 | pickled-beets | 3 | 3 | beet:4, onion:1 | 32 | 69 | 12.3 |
| 148 | pickled-onions | 3 | 3 | onion:4 | 32 | 69 | 12.3 |
| 149 | salted-eggs | 3 | 3 | hen-egg:4 | 32 | 69 | 12.3 |
| 150 | pickled-carrots | 3 | 3 | carrot:4, dill:1 | 30 | 66 | 12.0 |
| 151 | pickled-turnips | 3 | 3 | turnip:4, beet:1 | 30 | 66 | 12.0 |
| 152 | pickled-fennel | 3 | 3 | fennel:3, dill:1 | 30 | 66 | 12.0 |
| 153 | fermented-carrots | 5 | 3 | carrot:4, dill:1 | 30 | 72 | 8.4 |
| 154 | pickled-mushrooms | 3 | 3 | chanterelle:3 | 21 | 45 | 8.0 |
| 155 | sauerkraut | 7 | 4 | cabbage:4 | 32 | 84 | 7.4 |
| 156 | pickled-kale | 3 | 3 | kale:3 | 18 | 39 | 7.0 |

The bottom of the list is all cheap staple crops, which is expected. Their reason to exist is buffs, gifts, the Fair and Pomeroy, so only the worst ones are worth a nudge (proposals below).

## 3. Time gate: 1-day jams against 14-day cordials

| days | recipes | median V | median ratio | median gain/jar-day | min–max | gain rate vs jam (now) | with `1+0.8·d^0.6` |
|---:|---:|---:|---:|---:|---|---:|---:|
| 1 | 27 | 184 | 1.80 | 144.0 | 29–333 | 1.00 | 1.00 |
| 2 | 31 | 117 | 2.00 | 58.5 | 24–134 | 0.63 | 0.76 |
| 3 | 50 | 105 | 2.17 | 41.0 | 7–171 | 0.49 | 0.64 |
| 5 | 14 | 109 | 2.42 | 31.0 | 8–125 | 0.35 | 0.53 |
| 7 | 15 | 156 | 2.62 | 36.0 | 7–77 | 0.29 | 0.46 |
| 14 | 19 | 150 | 3.17 | 23.4 | 14–70 | 0.19 | 0.35 |

* **A gnome who checks in daily** should never start a cordial for the money. A cordial earns a fifth of what a jam earns per jar-day.
* **A gnome who checks in weekly** earns, per jar per week: jam 0.80·V (the jar sits idle six days), 7-day ferment 1.62·V, cordial 1.08·V. With the proposed curve: 0.80, 2.57 and 1.95·V. That gives weekly players a clear reason to use long timers.
* What long timers already have going for them: a better jar score (+2 per day, up to 10 days), bigger and longer buffs (cordials 2–3 stats for 24 h), and most of the Pomeroy jar asks that reach 3 spoons.
* Under the proposed curve, sample batch sales rise: elderberry-cordial 573 → 885, cheese-wheel 306 → 471, kimchi 264 → 336, sauerkraut 84 → 112. Jams are unchanged. `tests/pantry.php`'s "median ratio rises with the timer" check still passes.

## 4. Arbitrage

**Shops** sell no preserve ingredient except mulberry-leaf, which is not used, and no preserve. `sell_price()` already caps at the cheapest `shop_stock` price, so a shop cannot be flipped.

**Market stalls** (`market_stalls()`, every Saturday, 4 stalls × 4 goods, at most 3 of each per gnome) charge `base × 1.15 × (0.90…1.10)`. They have no rarity multiplier and no sell cap.

Items you can flip straight back to a shop, buying at the cheapest stall price:

| item(s) | stall price | sells for (60%) | sells for (80%, wanted / market day) |
|---|---:|---:|---:|
| ackee, almond, black-pepper, cacao, chestnut, cinnamon, clove, coffee, hazelnut, nutmeg, pecan, pistachio, quince, vanilla, walnut, yuzu (base 59, Legendary) | 61–75 | 88 | 118 |
| blueberry, caper, cardamom, cloudberry, cranberry, gooseberry, sea-buckthorn, sugarcane, tea (base 56, Legendary) | 58–71 | 83 | 110 |
| saffron (base 52, Legendary) | 54–66 | 78 | 103 |
| golden-carp (Rare) | 83–101 | 86 | 115 |
| morel (Rare) | 62–76 | 65 | 86 |

The same flip, through the Pantry, buying every ingredient at the cheapest stall price:

| preserve | stall cost | batch (60%) | batch (80%) | margin | per jar-day |
|---|---:|---:|---:|---:|---:|
| blueberry-jam / gooseberry-jam / cranberry-sauce | 290 | 748 | 996 | +458 | 458 |
| cloudberry-jam | 290 | 747 | 996 | +457 | 457 |
| quince-paste | 244 | 633 | 846 | +389 | 389 |
| almond-butter / hazelnut-spread | 305 | 952 | 1272 | +647 | 216 |
| dried-cranberries | 290 | 900 | 1200 | +610 | 203 |
| yuzu-marmalade | 183 | 531 | 708 | +348 | 174 |
| chai-blend | 277 | 783 | 1044 | +506 | 169 |
| candied-chestnuts | 305 | 1065 | 1419 | +760 | 152 |
| marzipan | 302 | 1053 | 1404 | +751 | 150 |
| cherry/apricot/peach/fig/mulberry-jam (Uncommon) | 265 | 352 | 468 | +87 | 87 |

154 of the 155 preserves whose ingredients can all be bought at a stall make money this way. Even common jams make a little: on Uncommon fruit, the 1.8× markup covers the 1.15× stall price. That part is intended, because "the Pantry adds value" is the design. The Legendary and Rare flip is the bug.

Buying preserves at a stall and selling them is safe: preserves are Common, so they sell for at most 80% of base and the stall charges at least 103.5%.

Pantry energy is not an exploit. A batch costs 1 energy and gives 12–18 back when eaten (yogurt is the best at 18 per jar-day). A meal gives 11 energy per 15-minute pot.

## 5. Ingredient availability: region-locked and treasure crops

* **32 preserves use at least one treasure crop.** Of the 1-day ones, the five in the top 5 above use a treasure fruit for the whole batch. pear-butter and pumpkin-butter use one cinnamon each. Treasure crops are perennials that take 180–360 minutes to grow, yield 1–3 or 2–5 per harvest, and have no seed shop. With the stall bug fixed, the only way to make these jams is a far-off garden or a lucky find. That is a reasonable reward for running one.
* **Fiddleheads** (a `part`, base 85) and the **hybrid fruits** (jostaberry, pluot, nectaplum, meyer-lemon and tangelo, base 77–84, Common) are the priciest non-treasure inputs. They are fine at canonical prices and badly over-priced on install (finding 1).
* **Forage items** (bilberries, chanterelle, samphire) are cheap (7–10), so their preserves sit near the bottom. morel is Rare at 65, so dried-mushrooms makes a solid 101 per jar-day.

## 6. Duplicates and near-duplicates (same ingredient set)

| group | recipes (days, qty, buff) | verdict |
|---|---|---|
| goat-milk | yogurt (1 d, 4 milk, no buff, 36/day); goat-cheese (2 d, 4 milk, no buff, 24/day); aged-goat-cheese (7 d, 6 milk, charm 2); cheese-wheel (14 d, 8 milk, charm 2 + hardiness 1) | **goat-cheese is strictly dominated by yogurt.** It is still needed as a cooking ingredient. Make yogurt smaller (below). |
| carrot + dill | pickled-carrots (3 d, nimble 1 for 12 h, 12.0/day); fermented-carrots (5 d, nimble 1 for 18 h, 8.4/day) | **Dominated duplicate.** Give fermented-carrots its own ingredients (below). |
| chili-pepper + garlic | hot-sauce (2 d, 6+1); pickled-peppers (3 d, 4+1); fermented-hot-sauce (7 d, 6+1, grit 2 for 18 h) | fermented-hot-sauce is CA's 3-spoon jar and has a better buff. Acceptable as a fresh and fermented pair. |
| tomato | tomato-passata (2 d, 3 out); sun-dried-tomatoes (3 d, 4 out) | Low value. Fine. |
| plum, fig, apricot, cranberry, date, apple | jam (1 d) against dried-* or prunes (3 d), same fruit, dried has no buff (prunes has one) | The dried versions earn half as much per jar-day as the jam. Their niche is gifts and the ESA banana-chips ask. Acceptable. **Note:** the `slug NOT LIKE 'dried-%'` filter in `market100.php` (lines 273, 425, 682) was written for dried flowers. It also hides the 7 dried-* preserves from the market "wanted" list and from the stalls. Probably accidental. |
| blackcurrant, lingonberry, cherry, lime | jam or marmalade against a cordial of the same fruit | Different timers and buffs. Fine. |
| soybean | natto (2 d), tempeh (3 d), doenjang (14 d) | Different timers. Fine. |
| ginger + sugarcane | candied-ginger (5 d), ginger-beer (7 d) | Fine. |
| eggs | pickled-eggs, pickled-quail-eggs, salted-eggs (all 3 d, gain 12–20 a day) | Fine. |

## 7. Buffs against meals and feasts

| | stats (median) | minutes (median) | stat-hours (median) | energy |
|---|---:|---:|---:|---:|
| snack (30) | 3 | 180 | 9 | 6 |
| meal (40) | 4 | 240 | 16 | 11 |
| feast (15) | 7 | 480 | 56 | 22 |
| preserve (156) | 1 (0 for 47 with no buff) | 720–1440 | 12 (max 72) | 3–6 per item |

The biggest preserve buffs are elderberry-, mixed-berry- and ginger-apple-cordial and cheese-wheel, each 3 stats for 24 h; then kimchi, 3 stats for 18 h; then gochujang, miso, soy-sauce, doenjang, blackcurrant-cordial and sea-buckthorn-juice, each 2 stats for 24 h.

The Kitchen's buff bonus applies to preserves too, so at Kitchen III a cordial lasts 36 h. No preserve gets close to a meal's strength at any moment, and eating one replaces the meal buff in the single slot (two slots for a Brewroot master). **Nothing to change.**

Per jar-day, the 1-day jams with a +1 buff give the most buff time: 4 jars × 12 h = 48 stat-hours per jar-day. A cordial gives 15 and kimchi 32. Jams win on buffs per jar-day as well, which strengthens the case for the time curve in section 3.

## 8. Jar capacity

Jars: 5 with a Pantry at Kitchen I or II, 7 at Kitchen III, plus 1 for each Pantry in another garden, up to 10 in all. One batch fills one jar.

* A daily jam player with 5 jars uses about 25 fruit a day (35 at Kitchen III). For treasure fruit, crop supply is the real limit, not jars.
* One 14-day cordial ties up 20% of a Kitchen I pantry for two weeks and yields 3 items. A Pomeroy tour asks for 14 different jars a month, and the jar ask rotates monthly. Preserves never spoil, so stockpiling works and the jars are not a hard block. Still, a Kitchen I player chasing a 14-day cordial ask loses noticeable income. That is another point for the gentler curve.
* There is no bottleneck bug. The Pantry costs 600 Petals and 4 planks; at the median jam rate of about 144 a day that pays back in a day.

## 9. Quality bars (`pantry_quality` against `GOURMAND_BARS['jar'] = [45, 52, 62]`)

The score is `38 + min(20, 2·days) + 3·Kitchen level + 3·min(4, kinds) + Luck (0–4) ± 3`. The Kitchen only goes to level III, so the best possible is 83 ± 3.

| Pomeroy jar ask | days | kinds | K I | K III | K III + Luck 4 | 3 spoons (62)? |
|---|---:|---:|---:|---:|---:|---|
| plum-jam EE/1, raspberry-jam NA/1, lingonberry-jam NWE/1, guava-jam CB/1 | 1 | 1 | 46 | 52 | 56 (max 59) | **never** |
| passion-fruit-curd SA/2 | 1 | 2 | 49 | 55 | 59 (max 62) | only on a +3 roll |
| pickled-daikon EA/2, tempeh SEA/2, banana-chips ESA/1, peanut-butter SA/1, pickled-samphire OC/1 | 3 | 1 | 50 | 56 | 60 (max 63) | only on a roll of +2 or more |
| mango-chutney CSA/1, salsa-verde CA/1 | 2 | 3 | 54 | 60 | 64 | needs some Luck |
| pickled-okra WCA/1, hummus-jar MENA/1 | 3 | 3 | 56 | 62 | 66 | exactly on the bar (hard by design, tested) |
| chicha, sauerkraut, rooibos, pomegranate-molasses, cured-olives, poi, curry-paste, fermented-hot-sauce, kimchi, every cordial, apple-cider | 3–14 | 1–4 | 57–67 | 63–73 | 67–77 | always at K III |

Across all 156 preserves at Kitchen III with Luck +4: 57 always reach 3 spoons, 66 need a roll, and 33 never do. Every recipe can reach 1 spoon at Kitchen I.

The jar score ignores ingredient quality, so stall-bought crops make jars as good as home-grown ones. Pots do use ingredient quality (`gourmand_dish_score`), and Pomeroy refuses "shop counter" plates. That inconsistency is worth a decision.

**Pomeroy pots (P2):** a dish needs ingredient quality of about 66 or more to reach 3 spoons at Kitchen III without Luck (0.8·q + 12 ≥ 65). Harvest quality can reach the 80s on good soil. Two dishes carry a fixed-quality ingredient: chanterelle is fixed at 50 (wild-rice-hotdish, buckwheat-kasha), and garden-honey at 35 because it is untracked (red-bean-buns). Each raises the crop quality needed to about 70–74. That is still reachable.

---

## Proposed changes

### A. `recipes.txt` data (safe; affects new installs, and live worlds only through an admin edit, because import never changes an item that exists)

```
fermented-carrots: ingredients  carrot:4,dill:1 -> carrot:4,ginger:1,garlic:1   (V 30 -> 58, gain 8.4 -> 16.0 per jar-day, kinds 2 -> 3 (+3 quality); no longer a copy of pickled-carrots)
yogurt:            ingredients  goat-milk:4 -> goat-milk:3                     (gain 36 -> 27 per jar-day; goat-cheese, at 24, is no longer strictly beaten)
pickled-kale:      ingredients  kale:3 -> kale:4,garlic:1                      (V 18 -> 34, gain 7.0 -> 12.7, raw price 21.7 -> 40.9, well clear of the 20 floor under drift)
pickled-mushrooms: ingredients  chanterelle:3 -> chanterelle:4,garlic:1        (V 21 -> 38, gain 8.0 -> 14.3, clear of the floor)
sauerkraut:        ingredients  cabbage:4 -> cabbage:6                         (V 32 -> 48, batch 84 -> 124, gain 7.4 -> 10.9; stays 1 kind, so the EE/2 ask still reaches 3 spoons at 64)
```

### B. Optional data change (Josh's call)

```
blueberry-jam:     cook minutes 1440 -> 2880   (gain 333 -> 208.5 per jar-day)
gooseberry-jam:    cook minutes 1440 -> 2880   (333 -> 208.5)
cranberry-sauce:   cook minutes 1440 -> 2880   (333 -> 208.5)
cloudberry-jam:    cook minutes 1440 -> 2880   (332 -> 208)
quince-paste:      cook minutes 1440 -> 2880   (281 -> 176.5)
```

This breaks the "jam = 1 day" rule. It is only worth doing if treasure jams still look too strong once the stall bug is fixed. My recommendation is to leave them.

### C. Code fixes (need Josh's call; I did not touch the code)

```
catalog.php import_recipes(): preserve value -> sum(floor(base_price * price_base_pct/100) * rarity_mult) using a FRESH item_lookups(), not sell_price()
                              (removes install-week drift and the static-cache Legendary mispricing)
upgrade (one-off):            re-price every pantry item from the line above. On a fresh install that means:
                              jostaberry-jam base 399 -> 150, pluot-jam 354 -> 138, nectaplum-jam 339 -> 138,
                              meyer-lemon-marmalade 419 -> 154, tangelo-marmalade 412 -> 154, pickled-fiddleheads 650 -> 246
                              (and 141 smaller drift corrections). Check the live values first.
market100.php market_stalls(): price = base * markup * wobble * rarity_mult (U 1.3 / R 1.8 / L 2.5),
                              or cap sell_price() at the stall price; either restores "buy then sell never profits"
catalog.php preserve mult:    1.3 + 0.5*sqrt(days) -> 1.0 + 0.8*days^0.6   (jams unchanged; 14-day cordials go from 19% to 35% of a jam's rate per jar-day)
market100.php 'dried-%' filter: only exclude category 'flower' (or dried flower slugs), so the 7 dried-* preserves can be wanted or on stalls (if that is wanted)
```

### D. Design questions for Josh

1. Should the 4 single-fruit jam asks (EE/1 plum, NA/1 raspberry, NWE/1 lingonberry, CB/1 guava) stay capped at 2 spoons in their months? The alternative is a two-ingredient, 2-day variant for those months, such as lemon-curd or apple-chutney. They don't block the Golden table, because the other variant can reach 3 spoons.
2. Should jar quality take ingredient quality into account, the way pots do, so stall-bought fruit gives a worse Fair or Pomeroy jar?
3. Should the time curve change at all (section 3)? The current one is fine for weekly players and harsh for daily ones.
