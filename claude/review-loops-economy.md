# Economy review: sinks and faucets (tweaks only)

Verified in code: pal_jobs.php, sinks.php, hired_help.php, market100.php, explore.php:299-317, functions.php:356-474. Crop base prices and daily energy needs were not read, so rows marked (est) are estimates.

## Petals per energy

| Activity | Petals | Energy | P/energy |
|---|---|---|---|
| Pal delve re-run (L15 delve) | ~85 (+5+lvl per Mole node) | 0 | infinite, 6/day |
| Pal station shift | crafted goods + free XP | 0 | infinite, 4/day |
| Market-day basket | 30/90/200/400 | 0 | infinite, weekly |
| Gnome delve chest (L15) | 95-190, avg 142 | ~6 | ~24 |
| Gnome delve chest (L5) | 45-90 | ~6 | ~11 |
| Orders (3 crops) | ~90-180 (est) | ~9 (est) | ~10-20 |
| Daily job | 50-90 | 10-20 (est) | ~3.5-7 |
| Explore long trip, depth 5 / 9 | 10 / 50 | ~5 / ~9 | 2.0 / 5.6 |
| Crop sold to shop | 60-80% of base | 3-6 | low (est) |

Dominant: pal jobs, since they cost no energy and nothing else caps them. Among energy activities, delves win by a wide margin.

## Findings, ranked

1. **Pal delve re-runs out-earn the gnome.**
   - Evidence: pal_jobs.php:611 and 696 pay 0.6x of the chest. Runs are capped at 6/day (:48), but one run per delve per day (:718). Mole nodes add 5+lvl each (:683).
   - Faucet: a 15-level gnome with 6 cleared delves earns ~510 Petals a day, which is more than the three dailies combined. Cost: no energy and a Healing Potion at most.
   - Tweak: coin factor 0.6 to 0.4 (L15 delve: 85 to 57). Mole coins 5+lvl to 3+lvl/2. Runs 3 to 6 get half pay.
   - Risk: pals feel weak. Item drops are untouched, so the loop stays fun.

2. **Every Petal sink is finite, and the pal faucet outruns it.**
   - Evidence: sinks.php:147, 244 and 330. Skins total 44,000 (6x1500, 6x2500, 5x4000). Dyes total 65,100. Signs total 13,000 per garden. That is ~122k plus deeds, all one-time.
   - Faucet: at ~500 Petals a day from pals alone, the catalog is exhausted in about 8 months. Sink question: open.
   - Tweak:
     - Add a recurring sink: hired-help wage x (1 + 0.05 x max(0, L-10)), the same formula as action XP. At L28 Old Burrow costs 342/day, up from 180.
     - Raise stall_tax_percent from 5 to 8 (functions.php:474).
     - Make Curio prices a % that rises with the number of curios already owned.
   - Risk: wage scaling needs a level-keyed read in hire_helper (hired_help.php:87). Existing contracts are unaffected.

3. **Pal garden duty makes hired help obsolete after L10.**
   - Evidence: pal garden wage is 0 (pal_jobs.php:322). It does all three skills from Gardening 1 (:256). It gives up to 36% extra crops (:280) and visits faster (:294). Hired help costs 40-180 a day and keeps a harvest cut.
   - Tweak: extra-crop chance 4% to 2% a level (cap 18). Leave hired help as the L1-9 option.
   - Risk: low. Existing pals just lose some bonus.

4. **Station shifts give free crafting and free XP.**
   - Evidence: 24 min per make at Crafting 10 (pal_jobs.php:449). A shift holds ~20 makes. Tools give 15 XP per make (:537), and half goes to the gnome (:767). That can reach ~600 XP a day.
   - Tweak: floor at max(40, 60-2(c-1)) minutes, giving ~11 makes per 8h shift. Gnome XP share from half to a quarter. Stations per day from 4 to 3.
   - Risk: pal crafting already doesn't count for quests (todo.md:35), so it stays a side loop.

5. **The basket is a free 400 Petals a week.**
   - Evidence: market100.php:793 sets rivals at 44-81. Feasts score 85 (:763). Items are shown, not handed over (:813). The reward costs no energy and no items.
   - Tweak: basket_rewards from 30,90,200,400 to 30,80,160,300. Raise the top rival band to 78-90.
   - Risk: low.

6. **Explore pays too little to bother with.**
   - Evidence: explore.php:308 gives 10 x (depth-4), once per stop per day. That is 2-5.6 P/energy against 24 for delves.
   - Tweak: 10 to 14 per step at depth 5 or deeper, so depth 9 pays 70.
   - Risk: low, because the claim is once per stop per day.

7. **The orders feast has a flat price.**
   - Evidence: market100.php:489 sets unit 200 for any feast, which pays ~480 at diff 3 (:507). A feast needs rare far-region crops, so this may be underpaid or overpaid.
   - Tweak: unit = max(200, 1.2 x the cheapest feast's base_price).
   - Risk: low.

8. **Daily-cap gaps.**
   - Evidence: the 100-things halving (functions.php:357) only covers rest stops. Pal delve coins, station output and garden duty sit outside it. The daily streak bonus is +300 per 7 dailies (functions.php:375), ~+43 a day.
   - Tweak: lower stop_daily_total to 80. Apply the same halving to pal delve coins after the first 3 runs of the day.
   - Risk: the halving needs one counter per day.

## Arbitrage checks (safe)

- Stall buys cost 115% x a 90-110% wobble x the rarity multiplier (market100.php:685), which is at least 103%. Sells top out at 80% (functions.php:516), so buying and reselling never profits.
- Shop buys can drop 6% in season. Sells cap at 80%, and volume pressure takes off up to 12 points (market100.php:311).
- Hired-help refunds only cover whole unused days (hired_help.php:116), so there is no loop.
