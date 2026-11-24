# Gnome Venture item graph review

Repo: /home/user/gnome-venture/game (read-only). All citations were re-checked against the repo. Where a verifier corrected a finding, the corrected version is the one given here.

## 1 Summary

| Lens | Raw findings | Surviving | Refuted |
|---|---|---|---|
| Holes | 5 | 3 (H1, H4, H5) | 2 (H2, H3) |
| Edge cases / exploits | 12 | 12 | 0 |
| Redundancy | 20 | 20 | 0 |
| Useless items, a-m (uA) | 7 | 7 | 0 |
| Useless items, n-z (B) | 9 | 9 | 0 |
| Economy fit | 10 | 8 | 2 (E4, E10) |
| **Total** | **63** | **59** | **4** |

Severity of the 59 surviving findings: high 9 (H1, R1, R2, R3, uA-1, B1, B2, E1, E2), medium 21, low 29.
Section 5 lists 18 groups of useless items flagged for user review.

Refuted findings, dropped:
- **H2, H3**: treasure seeds are not luck-only. `give_local_seed` (adventure.php:420-430) draws from every tier of the region's crops. It runs on 35% of explore finds (adventure.php:462) and on seed drops (:1056). Harvests can also save seeds (garden_logic.php:1478-1487).
- **E4**: creature 'part' items have more sinks than shop sales. They are NPC gift items (friends.php:13, :197) and can be sold on the player market (market100.php:24). The "no recipe uses them" point is kept in uA-4/B1.
- **E10**: the conclusion was backwards. Twigg's sells rope at 4-5x base (trail_sights_5.php:575), so crafting rope is the cheaper route.

Corrections to the inventory itself (items.json/orphans.json):
- **H5**: the no_sources orphans are false positives, e.g. flour, maple-sap, toffee, shiny-quartz, and trek flags such as won_fight.
- **EC12**: the sold_at entries are wrong. Tomato, cabbage and onion are not sold at Twigg's (pal_jobs.php:185-188 is the Healing Potion shelf). Broken items cannot be sold, so the "~10% sell value" note is wrong.
- **R19**: 102 of the 122 dupes are name-variant artefacts. prospectors-pick and similar slugs do not exist. The real slugs are prospector-s-pick and so on.
- **uA-7, B9**: the no_uses false positives are recipe slugs, decor items, skins, items that bind to an existing item by name, and pools.

Fix these before reusing the graph.

## 2 Holes

| ID | Sev | Finding | Fix |
|---|---|---|---|
| H1 | high | Build plan stage 1 of Drum Circle Market needs `item:drum-skin:3` (build_plans.txt:176). The only grant is the Trek Ch II finish (trek_chapters_ch2b.txt:26), which gives 1 per run (trek.php:1428-1435). The item is tradable (trek_data.php:513), so 3 can be pooled through trades or an admin run reset (admin/treks.php). A solo player gets 1, and with `trek_open` defaulting to '0' (trek_data.php:30) a default install has no source at all. | Lower the need to 1, or add a repeatable source (a WCA drop, a drum-circle stop act, or a shop). Decouple the plan from the Trek. |
| H4 | low | `second-spoon` is granted only by the Gourmand finale (gourmand.php:336-338, 641-657), and gourmand_open defaults to 0 (functions.php:461). This is deliberate feature gating. The seed claims in the original finding were wrong. | No change if Gourmand is meant to be opt-in. Otherwise document the dependency. |
| H5 | low | The inventory's no_sources orphans are false positives. flour, maple-sap and toffee are in trail_sight_items.txt:4-7. shiny-quartz comes from stop_acts_waves.txt:234. won_fight and drumdoor_open are trek flags, not items. cistern-pearl comes from trek_fight.php:340. | Remove them from orphans.json. No code change. |

## 3 Edge cases / exploits

| ID | Sev | Finding | Fix |
|---|---|---|---|
| EC1 | med | **Seed to packet arbitrage.** A packet's base is max(30, seed×3×1.8) with rarity 35 (flowers.php:526), and sell_price returns early for packets (world.php:436-438). Seeds themselves cannot be sold (world.php:518). At 60% sell the packet returns 3.24× one seed's base, against a cost of 2.4× plus a 20-Petal fee. That is profitable for seeds with a base above about 24, and up to 2.16× the seeds' value with 80% drift and Charm 1.5×. Capped at 5 packets/day. | Price packets from the seed's flat sell value, or cap at seed sell price × packet_seeds. |
| EC2 | med | **Drying bumps rarity.** The dried item has base = cut×1.25 with the same numeric rarity (flowers.php:430-431). It falls through to the numeric rule, so it becomes R (180%), while the cut flower is U via L['produce'] (items.php:41-51). It has no buy-back cap. Example: base 41 gives a dried sale of about 56, against a florist buy of 46 or more (flowers.php:759). | Inherit the cut flower's tier, and cap at dried_price_pct of the cut flower's buy floor. |
| EC3 | med | `shop_buy_floor` (world.php:468-495) leaves out Silver Tongue and the trail-sight discounts that shop_price applies (world.php:392-403). Cut flowers can be bought and resold at a small profit (about 0.752 against 0.714 of pmin with Charm 10, 80% drift and in season). | Build the floor from the same discount helper. |
| EC4 | med | The festival tables are keyed only by (festival, user) (social.php:128-148; festival.php:159, 192, 215, 235-238), so a re-run blocks stall limits and rewards. Dates are set once at install (social.php:212-215). `opening-day-bunting` is tradable=0 (festival.php:44) and has no other source, which contradicts the header at festival.php:12. The 7-flag reward needs a flag every day of a 7-day window. | Add a run key, give the bunting a second source, and schedule the festival yearly. |
| EC5 | low | Mending a Broken copy sets wear=0 on the working tool's stack too (tools.php:443). One fee, or one free shed mend, therefore also repairs the tool in use. | Only reset wear when the stack had no working copy. |
| EC6 | low | Broken copies are tradable=1 (tools.php:375), and tool_trade_block checks only category 'tool' (tools.php:451-455). send_gift therefore allows them, and friends can farm free Tool Shed mends (tools.php:405-410). Other gift paths already exclude 'broken' (residential.php:99, stop_folk.php:174/186). | Make Broken copies tradable=0, or block category 'broken'. |
| EC7 | low | The Glowcap repair kit is removed (tools.php:432) before the free-mend check, so the kit is spent even when a free mend was available. Its only source is a 5% drop (trail_sights_maplewold.txt:91). The Tool Repair Kit (pfdeck.php:42) only fixes fight belts, which is easy to confuse. | Use the free mend first, and clarify the item text. |
| EC8 | low | `items.max_stack` (schema.php:113) is never enforced, and give_item (inventory.php:11-43) does not cap. Fight belts (max_stack 1, pfdeck.php:566) pile up across restocks (max_stock 1, :568). | Clamp in give_item, or drop the column. |
| EC9 | low | A bulk sell is priced once (world.php:525), and market_volume_add runs after it (:529), so the volume price drop never hits the batch that causes it. | Price in chunks of price_vol_units. |
| EC10 | low | markup_percent applies only to current_price (world.php:119, min -90 at admin_resources.php:234). The floor uses the raw price_min (world.php:460-495), so a negative markup makes buy-and-sell profitable. Needs an admin setting. | Clamp the markup at 0 or above, or include it in the floor. |
| EC11 | low | 7 hovel decor items have own:false and a 'where' label but no source (hovel_decor.json:9-39; home_slim.php ~83-88). This is a known v1 placeholder. | Wire the sources, or mark them 'coming soon'. |
| EC12 | low | Inventory errors. The tomato, cabbage and onion sold_at entries are wrong (pal_jobs.php:185-188 is the potion shelf; Twigg's stock is at seed.php:58-65). The Kitchen soup is swapped to bought-* (world.php:182-195), so the order loop is impossible (market100.php:421-423). Broken items cannot be sold. | Fix items.json. |

## 4 Redundant items (merge / cut)

| ID | Sev | Slugs | Issue (evidence) | Action |
|---|---|---|---|---|
| R1 | high | sunflower/-seed, sesame/-seed, cumin/-seed | Produce and seed share a display name (catalog.php:119,126 vs 201-202). Only the slug is unique (schema.php:104). | Rename the produce, e.g. "Sunflower Kernels". |
| R2 | high | lotus-root-seed, sacred-lotus-seed | Both seeds are named "Lotus Rhizome" (catalog.php:105,112). It is one species (crops.txt:47, flowers.txt:50). | Rename the sacred-lotus seed to "Sacred Lotus Tuber". |
| R3 | high | edelweiss, cut-edelweiss | A gatherable (gatherables.txt:19) and a flower (flowers.txt:71) exist, but crafts.txt:74,99 and the Sights accept only `edelweiss`. | Merge into edelweiss, or accept both. |
| R4 | med | egusi-soup, buckwheat-kasha, hibiscus-cordial | Stop acts output generic items instead (stop_acts_regional.txt:312, 237, 313). | Point the acts at the dedicated items. |
| R5 | med | mint-tea, plum-jam, goat-cheese, grilled-sardines, silk-thread, ... | 62/76 stop-craft outputs duplicate kitchen or craft outputs. Some are exact copies (e.g. regional:277 = recipes:11), and some are cheaper (plum:3 vs 5, regional:238 vs recipes:65). | Cut the exact copies, and raise the cheaper inputs or give them regional outputs. |
| R6 | med | hatchling-egg-shell, hatchling-eggshell, wyrmling-egg-shell | Spelling split (pf_creatures.txt:64, 191, 246). None is referenced elsewhere. | Unify on hatchling-eggshell. |
| R7 | med | rock-, mud-, land-, ghost-, palm-crab-claw | Single-creature variants of crab-claw (pf_creatures.txt:184, 58, 124, 123, 163) with no references. | Rename the drops to "Crab Claw" and cut the 5 variants. |
| R8 | med | skink-scale, glass-wyrm-scale, giant-otter-pelt | Same-animal splits (pf_creatures.txt:164, 330, 317) with no references. | Merge into lizard-scale, wyrm-scale and otter-pelt. |
| R9 | med | ~340 creature parts (pelts, feathers, scales, shells, claws, fangs) | Template bloat from auto-created parts (adventure_data.php:552-556). Feathers have one sink, any-feather (trail_sights.php:565). | Collapse into tiered generic parts, or add a sink. User decision. |
| R10 | med | hot-sauce, fermented-hot-sauce, pickled-peppers | recipes.txt:140 and :172 have identical inputs. pickled-peppers (:153) has no use. | Cut pickled-peppers and differentiate the hot-sauce pair. |
| R11 | low | natto, tempeh | Both are soybean:4 (recipes.txt:177-178). natto has no use. | Cut natto or give it a distinct input. |
| R12 | low | cranberry, apricot, tomato and cherry preserve pairs | Same inputs, no buff, no use (recipes.txt:104/215, 108/209, 148/217, 107/193). The date, fig and lingonberry pairs have uses or differ. | Cut dried-cranberries and sun-dried-tomatoes first. |
| R13 | low | aged-goat-cheese, cheese-wheel, yogurt, goat-cheese | Yogurt beats goat-cheese (recipes.txt:184 vs :91). The top two tiers (:186-187) have no use. | Merge aged-goat-cheese into cheese-wheel. |
| R14 | low | mint-tea, meadowsweet-tea, desert-sage-tea | Kettle journal keys reuse kitchen item slugs (teas.txt:8-10; recipes.txt:11,30,31; tea.php:8). The kettle is admin-gated. | Rename the kettle keys, or route tea through one system. |
| R15 | low | kelp-frond, shale-chip, sawdust-heap | Drop-only parallels: kelp-frond to kelp-meal (waves:8 vs crafts.txt:36), shale-chip to rock-dust (waves:248 vs crafts.txt:44). sawdust-heap has no references. leaf-mould-clump and coconut-husk are not duplicates. | Remap the three drops to bladderwrack, slate-shard and wood-chips. |
| R16 | low | timber-plank, rope | 7 plank and 4+3 rope variants with uneven yields. The stop acts (waves:13, regional:9, regional:489) are worse than the crafts, not copies of them. | Normalise yields and consider cutting the weaker acts. |
| R17 | low | calabash-carrier, bamboo-frame-pack, thatch-rain-cape, kapok-puffer variants | 4 names reused across regions (wear_items.txt:70/250, 73/233/272, 79/120, 118/217). This gives 12 shared names after the rank suffix (wearables.php:142). | Add region adjectives. |
| R18 | low | 224 wear rows | 112 pairs, always n=1/2 and n=3/4, are identical except for fx (wear_items.txt; wearables.php:133). | Design call: cut, or differentiate the materials. |
| R19 | low | prospectors-pick, river-perch, ... | Inventory dupes are false positives (tools.php:84,113; gatherables.txt). | Remove them from the dupes list. |
| R20 | low | Tools and potions at Twigg's | Intentional overlap. Potions are sold at 1.2-1.5× (pal_jobs.php:191), tools at 0.9-1.2× base (tools.php:246-250). | No merge. |

## 5 USELESS ITEMS FLAGGED FOR USER REVIEW

"No use" means nothing consumes the item. Most of these can still be sold, traded or gifted as their category allows.

| # | Slug / group | Why (evidence) | Recommend |
|---|---|---|---|
| 1 | Flower-named drop twins: cornflower, foxglove, goldenrod, heliconia, marsh-marigold, desert-rose, beach-naupaka, cattleya-orchid, moth-orchid, mount-atlas-daisy, heather, passionflower, rock-rose, sea-thrift, steppe-peony, sweet-pea, tibetan-gentian (uA-1) | pfc_item_for_drop misses `cut-<slug>` (adventure_data.php:476-496, 554), so the drop becomes a new 'part'. It cannot be arranged (arrange_view.php:41, flower_art.php:285-293). This contradicts the comment at adventure_data.php:471. | **Repurpose**: fix the lookup and merge the twins into cut-*. |
| 2 | date-palm, prickly-pear-cactus, water-spinach crop twins (uA-2) | The drop names match the crop's name, not the produce's (crops.txt:100, catalog.php:115; pf_creatures.txt:155,216,324). | **Repurpose**: rename the drops to the produce names. |
| 3 | Misc curios: brass-button, dew-pearl, echo-pebble, frost-window-pane, lagoon-glass-bead, lost-sock, mirage-marble, mirror-pebble (uA-3) | Category misc cannot be sold (world.php:518). Nothing consumes them, yet they drop widely. Their descriptions promise effects that do not exist. | **Repurpose**: decor JSON or keepsake bonuses. |
| 4 | Sight trinkets: wishing-coin, raindrop-bead, squeaky-ice-chip, seaside-stationery, taper, old-river-pebble, rivers-postcard, root-race-ribbon, visitors-book-page (B4) | misc, no effects. Their only sink is a +4 polite NPC gift (friends.php:200). | **Repurpose**: trail_sight_keepsakes.txt, or a take= use (taper could light lanterns). |
| 5 | ~147 a-m creature parts, e.g. aardvark-ear, adder-scale, fox-pelt, golden-silk-thread, luna-silk, kraken-ink, mother-of-pearl, bactrian-wool (uA-4; list in partsAM.txt) | Referenced only in creature tables. They are sell, trade and NPC-gift fodder (friends.php:13). | **Repurpose** the craft-sounding ones as tailor or alchemy inputs, and **cut** the rest by folding them into generic tiers (see R9). |
| 6 | 92 n-z creature parts, e.g. qiviut-wool, paladin-gorget, tyrant-fang, winter-fat, termite-clay, natterjack-skin, warthog-tusk (B1) | Referenced only in pf_creatures.txt. oily-, pied- and vulture-feather each fill any-feather (B8). | **Repurpose**: add a shared sink, or fold into generic parts. |
| 7 | 26 legacy creature parts: rat-pelt, snake-skin, spider-fang, slug-slime, venom-fang, stolen-trinket, ... (B2) | Referenced only at their drop and PF_GIFT sources. These are common early drops. | **Repurpose**: one recipe use each for the early ones. |
| 8 | Trek parts: newt-tail, pale-scale, quartz-shell, silverfish-scales (B3) | Referenced only in trek drop lists (trek_creatures_ch2/ch2b/ch3.txt). | **Repurpose** as trek gate items, or **cut**. |
| 9 | black-truffle (uA-5) | A 3% drop (pf_creatures.txt:80,251) with no recipe. | **Repurpose**: high-tier recipe ingredient. |
| 10 | hatchling-egg-shell / hatchling-eggshell / wyrmling-egg-shell (uA-6, R6) | Spelling split, no use. | **Cut** to one slug. |
| 11 | rock-, mud-, land-, ghost-, palm-crab-claw; skink-scale; glass-wyrm-scale; giant-otter-pelt (R7, R8) | Single-creature variants with no references. | **Cut**, merging into the generic part. |
| 12 | kelp-frond, shale-chip, sawdust-heap (R15) | Parallel drop-only materials. sawdust-heap has no references. | **Cut**, remapping to existing materials. |
| 13 | Hybrids: triticale, tritordeum, pomato, raphanobrassica, tangor, orangelo, sunrise-lime, nessberry (B5; 17 of 22 hybrids) | No recipe or act use (hybrids.txt; breeding110.php:274-279). triticale and tritordeum are not edible. Only any-produce Sights accept them. | **Repurpose**: let a hybrid stand in for its parent in recipes. |
| 14 | perilla, tamarillo, naranjilla, noni (B6) | No recipe, act or quest use. | **Keep** as flavour crops, or add one stop act each. |
| 15 | ~19 buff-less n-z preserves: strawberry-jam, tomato-passata, pickled-onions, rhubarb-jam, ... (B7) | Sale premium and gift role only (recipes.txt:61-63), which is intentional. raspberry-jam, peanut-butter and pickled-samphire do have uses. | **Keep**. Optionally add small buffs or use them as ingredients. |
| 16 | pickled-peppers, natto (R10, R11) | Near-identical recipes with no references. | **Cut**. |
| 17 | dried-cranberries, sun-dried-tomatoes, apricot and cherry twin preserves (R12) | Same inputs as a sibling, no buff, no use. | **Cut**, or differentiate. |
| 18 | aged-goat-cheese, cheese-wheel (R13) | No references outside recipes.txt:186-187. | **Cut** one, or **merge** them. |

## 6 Economy fit

| ID | Sev | Finding | Fix |
|---|---|---|---|
| E1 | high | **Camping gear.** Crafting it uses about 216 Petals of base-value inputs, including 2 rare bog-iron (crafts.txt:110-114, gatherables.txt:36), against 100 to buy (game_clock.php:277). The "~60" comment at game_clock.php:257-263 adds up the parts' own prices instead. | Rebalance the part inputs or raise camping_gear_price, and fix the comment. |
| E2 | high | **Tool prices.** Twigg's sells tier 2-4 tools at 4-8× the craft input value (tools.php:51-108, 246-251 vs crafts.txt:6-29, 51-55), e.g. Garden Hoe 250 against about 49 and masterworks 6000 against about 1300. This is partly deliberate premium scarcity (tools.php:49). Recipe coverage within a tier is uneven. | Raise the craft costs to 50-70% of the shop price, or cut the shop prices. |
| E3 | med | **Decor crafts.** Firefly Jar uses 173 of inputs for a nominal value of 45 (crafts.txt:65, yard.php:72). Toadstool Ring uses 102 for 50 (crafts.txt:66, yard.php:80). Decor cannot be sold (world.php:518), so the value is appeal only. | Use cheaper inputs or give more appeal. |
| E5 | med | **Dish pricing.** Dishes are priced at max(20, 1.4×Σ ingredient base) with rarity Common (catalog.php:676-679). They earn about 8% over raw uncommon crops and lose value against raw legendary crops at 250% (world.php:440-442). | Price dishes the way preserve_price does, from flat_sell_value × a tier factor. |
| E6 | med | **Kitchen soup.** The Dewdrop Kitchen stocks Garden Vegetable Soup at 40-55 against a base of 90 (seed.php:94-96). This caps resale at the shop minimum × sell% (world.php:445-446), and it is the shop's only item. | Restock at 0.9-1.2× base, or add more dishes. |
| E7 | med | **Festival stalls.** Opening Day stalls sell compost, castings and loam at about 3.3× base (festival.php:32,34), while Twigg's charges 0.9-1.2× (seed.php:58-64). Rope at 60 is only about 1.3× Twigg's. | Sell festival-only goods or bundles. |
| E8 | med | **Buff slot.** eat_item overwrites buff and buff2 with no strength check (gnome.php:546-560), so a raw mushroom wipes out an 8-hour feast. Draughts share the slot, though they are stronger per stat. They are 'supply' items and cannot be sold. | Confirm before downgrading a buff, or give potions their own slot. |
| E9 | low | **Weak dishes.** Some dishes buff less than one raw ingredient (catalog.php:219), e.g. Grilled Sardines (recipes.txt:40) +2/120 against raw lemon +3/240, and Toffee Apple (:256). Dishes do give more energy (4-8 against 1-2). | Raise these dishes' buffs or durations. |
