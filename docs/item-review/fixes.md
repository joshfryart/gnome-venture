# Proposed fixes for Opus findings (proposal only, nothing applied)

Order: A data-only (no migration), B small code, C needs your decision. Finding ids refer to flags.json.

## A. Data-only
| Fix | Ids | Change |
|---|---|---|
| Drum skin gate | H1 | build_plans source (claude/build-plans-base.txt): drum-skin 3 -> 1 |
| Rename twin display names | R1, R2 | produce side renamed; sacred-lotus seed -> "Sacred Lotus Tuber" |
| Eggshell unify | R6, uA-6 | all drops/recipes use hatchling-eggshell |
| Cut dead near-dupes | R10, R11, R12 | cut pickled-peppers, natto, dried-cranberries, sun-dried-tomatoes; differentiate hot-sauce pair |
| Goat ladder | R13 | merge aged-goat-cheese into cheese-wheel |
| Crab claw | R7 | rename 5 drop variants to Crab Claw, cut variants |
| Regional name clash | R17 | add region adjective to 4 reused wearable names |
| Add sinks, reuse dead items | uA-5, B2, B3, B5, B7 | add alt rows in crafts.txt (insert-only, no migration); hybrids accepted for parent in recipes |
| Camping gear cost | E1 | cheaper metal-pins/camping-pot alt rows; fix game_clock.php comment |
| Decor inputs | E3 | cheaper alt decor rows |
| Soup restock, dish buffs | E6, E9 | restock 0.9-1.2x base; raise weak dish buffs |
| Keepsake effects | uA-3, B4 | decor JSON effect for curios and trinkets |
| Inventory clean-up | H5, R19, uA-7, B9, EC12 | drop false positives from orphans/dupes; regenerate map |

## B. Small code
| Fix | Ids | Change |
|---|---|---|
| Seed packet / dried flower arbitrage | EC1, EC2 | price packets and dried flowers from sell floor; inherit cut rarity |
| Shared discount helper | EC3 | one helper used by shop_price and shop_buy_floor |
| Broken-tool mending | EC5, EC6, EC7 | reset wear only if no working copy; broken tradable=0; use free shed mend before kit |
| Stack clamp | EC8 | clamp in give_item |
| Bulk sell | EC9 | price in price_vol_units chunks |
| Markup clamp | EC10 | markup >= 0 |
| Flower drop twins | uA-1, uA-2 | pfc_item_for_drop tries cut-<slug> / produce slug first; merge twins |
| Edelweiss | R3 | recipes accept both edelweiss and cut-edelweiss |
| Stop-act outputs | R4 | point acts at dedicated items |
| Tool prices | E2 | raise craft cost or cut Twigg's tier 2-4 prices |
| Dish pricing | E5 | flat_sell_value x tier factor |
| Buff overwrite | E8 | confirm before replacing stronger buff |
| Festival | EC4, E7 | run key, second bunting source, bundle stall goods |
| Hovel decor sources | EC11 | wire sources or mark coming soon |

## C. Your decision
R5 (cut or raise 62 stop-craft dupes), R8, R9, B1, uA-4 (~340 creature parts: collapse into tiered parts vs add sinks), R15, R16, R18 (112 wearable pairs), R14 (kettle tea keys), H4 (gourmand opt-in), B6.
