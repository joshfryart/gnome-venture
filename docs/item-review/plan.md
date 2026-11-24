# Gnome Venture: plan to reuse existing items

Repo `/home/user/gnome-venture/game`, read-only. Paths are under `includes/` unless shown. "Verified" means re-checked by grep against the repo in this pass; everything else is a proposal.

## 1 Principles

1. **No new items.** Every proposal outputs an item that already exists; dead-end items become inputs.
2. **Add rows, do not edit rows.** `ensure_crafts()` (crafting.php:23-58) and `import_recipes()` (catalog.php:634-691) only insert missing recipes. A new alternative row in `crafts.txt` ships with no migration; changing an existing row needs an upgrade step (precedent: catalog.php:821).
3. **Reuse existing sinks**: `crafts.txt` categories with no building, stop-act `craft` rows (`in:qty>out:qty`), Sight `take=any-<suffix>` (trail_sights.php:400, 561), build-plan `item:` needs, the tea `items` alias column.
4. **Generated files are edited at source**: `build_plans.txt` from `claude/build-plans-base.txt`, `wear_items.txt` from `tools/build_wear_items.py`.
5. Close exploits before adding sinks that raise an item's value.

## 2 Quick wins (data-only unless marked)

| Change | Items | File | Effort |
|---|---|---|---|
| Alt recipe so the Glowcap kit is craftable: `glowcap-repair-kit:1` from `chanterelle:2,beeswax:1,rock-crystal:1` (only source today is a 5% drop) | glowcap-repair-kit | crafts.txt (new row, category garden); source trail_sights_maplewold.txt:91 | S |
| Cheaper camping parts (E1) as alt rows: `metal-pins:4` from `slate-shard:2,flint:2`; `camping-pot:1` from `river-clay:3,red-ochre:1`. Gear drops from about 216 to about 110 Petals of inputs; fix the "~60" comment | metal-pins, camping-pot | crafts.txt:108-110; game_clock.php:257-263 | S |
| `flour:2` from `mesquite-pods:3`, `triticale:3` or `tritordeum:3` (flour is Sights-only today; the mesquite description already says "ground into a nutty flour") | flour, mesquite-pods, 2 hybrids | crafts.txt (3 rows, garden); gatherables.txt:23 | S |
| Tallow Wax source (new hole, see 5): `tallow-wax:2` from `winter-fat:1` or `marmot-fat:1` | tallow-wax | crafts.txt (2 rows, building) | S, verify item exists at install |
| Tea aliases so jars steep: ginger +`candied-ginger,pickled-ginger`; lemon +`preserved-lemons`; orange +`candied-citrus-peel,orange-marmalade`; vanilla +`vanilla-extract`; rooibos +`rooibos-concentrate`; tea +`iced-tea-concentrate`; elderberry +`elderberry-cordial` | 9 preserves | tea_ingredients.txt (items column) | S; kettle is `tea_open=admin` by default (functions.php:496) |
| Remap parallel drops (R15): kelp-frond to bladderwrack, shale-chip to slate-shard; drop sawdust-heap | 3 parts | stop_acts_waves.txt:8, 248; stop_acts_regional.txt:205; pf_creatures.txt | S |
| Point stop acts at dedicated dishes (R4) | egusi-soup, buckwheat-kasha, hibiscus-cordial | stop_acts_regional.txt:312, 237, 313 | S |
| Drum Circle stage 1: `item:drum-skin:3` to `:1` (H1) | drum-skin | claude/build-plans-base.txt, regenerate build_plans.txt:176 | S |
| Firefly Jar and Toadstool Ring alt rows with cheap inputs (E3), see section 3 | cricket-chirp, pink-sand | crafts.txt:71-72 | S |
| Display-name clashes (R1, R2) | sunflower/sesame/cumin produce, sacred-lotus-seed | catalog.php:105-126, 201-202 + upgrade step | M (migration) |
| Dried flower inherits the cut flower's tier and a price cap (EC2); packet priced from seed sell value (EC1) | dried-*, packets | flowers.php:430-431, 526 | M (code) |
| Broken copies `tradable=0`, or block category `broken` in `tool_trade_block` (EC6) | 56 broken-* | tools.php:375, 454-458 | S (code) |

## 3 New uses for dead-end items

Verified counts: 71 of 156 preserves have no consumer anywhere (22 of those also have no buff); 23 of 77 gatherables have no craft or recipe use; 8 forage tea plants are used only by the admin-gated kettle.

**Preserves** (Kitchen and stop acts)
- Alt Kitchen rows in `crafts.txt` with category `cooking` and existing dish outputs: `herb-flatbread:2` from `sourdough-starter:1,wheat:2,basil-pesto:1`; `peanut-toast:2` from `peanut-butter:1,wheat:1`; `berry-tart:2` from `strawberry-jam:1,wheat:2`; `garden-vegetable-soup:2` from `tomato-passata:1,carrot:2,pickled-onions:1`; `coconut-curry:2` from `coconut:1,rice:2,curry-paste:1`; `grilled-sardines:2` from `sardine:3,preserved-lemons:1`. Needs one check: rows from `crafts.txt` get no tier or cook minutes (crafting.php:55), so copy them from the dish's first recipe.
- Build-plan `feed` stages: replace some of the 10 generic `meal:N` needs with regional jars (`item:cloudberry-jam`, `item:radish-kimchi`, `item:tamarind-chutney`) in `claude/build-plans-base.txt`.
- Cheese ladder (R13): `goat-cheese-tart` and `stuffed-peppers-goat` alt rows taking `aged-goat-cheese:1` or `cheese-wheel:1` for double output.

**Potions** (crafts.txt, category potions; alt rows that also absorb dead gatherables)
- `lucky-draught:1` from `scarab-shell:1,wild-strawberries:2,elderflower:1`.
- `sages-draught:1` from `oak-gall:1,nettle:2,raspberry-leaf:1`; `swiftfoot-elixir:1` from `snow-moth-dust:1,spruce-tips:2,rose-hips:1`; `stoneskin-brew:1` from `dandelion-root:1,licorice-root:1,cork-bark:1`.
- `grand-healing-elixir:1` from `strong-healing-potion:1,black-truffle:1`; `healing-potion:2` from `linden-blossom:1,elderflower:2`; `garden-tonic:2` from `minnow:3,bladderwrack:1`.
- Potions as inputs: add `item:healing-potion:2` to a few build-plan `feed` stages.

**Creature parts** (about 379 `part` items, 465 drop names; suffix families: pelt 23, shell 19, feather 18, scale 13, claw 11, skin 11, hide about 25)
- Data-only: add `take=any-pelt:1`, `any-shell:2`, `any-scale:1`, `any-claw:1`, `any-hide:1` to existing Sight and folk rows. The suffix match already works for any slug ending.
- Small code: accept `any-<suffix>` in craft ingredients (`craft_stock`, crafting.php:163, reusing `trail_sight_any_items`). Then: `shell-meal:2` from `any-shell:3`; `rope:1` from `any-hair:3` (also wool, fur); `canvas-sheet:1` from `any-down:3,cottongrass:1`; `silk-thread:1` from `any-silk:2`; `tool-repair-kit:1` from `any-claw:1,any-hide:1,pine-resin:1`; `garden-tonic:2` from `any-slime:2,meadowsweet:1`.
- Tailor: give the n=3/4 and n=5 rows a part material (pelt, wool, plume) so the 112 identical pairs differ (R18). User decision.

**Cut flowers** (173 `cut-*`; only 7 feed the kettle)
- `rock-garden:1` from `building-stone:1,cut-edelweiss:1,flint:2`; `toadstool-ring:1` from `chanterelle:2,cut-foxglove:1`; `beeswax-candles:2` from `beeswax:2,rope:1,cut-lavender:1`.
- With `any-` support: `plain-compost:2` from `any-flower:6` (wilted stems), `leaf-mould:1` from `any-flower:4,straw-mulch:1`.
- More `item:cut-<regional flower>` needs in build-plan `light`/`gather` stages (2 exist, both cut-marigold).

**Gatherables with no craft or recipe use** (verified)
- Fish: `smoked-trout:1` from `arctic-char:2`; `grilled-sardines:1` from `reef-fish:3,lime:1`; `mackerel-rice:1` from `rainbow-fish:1,rice:2`; `golden-carp-feast:1` from `moonfish:1,carrot:2,onion:2`.
- Wood: `wayfarer-s-staff:1` from `hiking-staff:1,heartwood:1,pine-resin:2`; `timber-plank:3` from `mangrove-root:1`; `bird-box:1` from `cork-bark:1,pine-resin:1`.
- Shiny finds: `firefly-jar:1` from `cricket-chirp:3,firefly-glow:1,river-clay:1`; `wing-scale-lantern:1` from `morpho-scales:1,silk-thread:1`; `glazed-garden-pot:1` from `pink-sand:2,river-clay:2`; `rock-garden:1` from `building-stone:1,coral-fragment:1,pink-sand:1`; `log-pile:1` from `timber-plank:1,scarab-shell:1`; `leaf-mould:2` from `bromeliad-seeds:2,straw-mulch:1`.

**Produce with no use**
- Stop-act `craft` rows (stop_acts_regional.txt): `perilla:3>kimchi:1`, `tamarillo:3>tomato-chutney:1`, `naranjilla:3>tepache:1`, `noni:4>garden-tonic:1`.
- Hybrids: a hybrid counts as either parent in Kitchen and Pantry recipes (alias map from hybrids.txt in `craft_stock`). User decision.
- Twins: fix `pfc_item_for_drop` to try `cut-<slug>` and the produce name (adventure_data.php:476-496), then merge the 17 flower twins and 3 crop twins.

## 4 Mending and repair overhaul

Today (verified): mending costs Petals only, 15% of base price (`tool_mend_percent`, functions.php:724; tools.php:380-383), so 38 for a Garden Hoe and 900 for a masterwork. `tool-repair-kit` (crafts.txt:113) fixes only fight belts (pfdeck.php:41). `glowcap-repair-kit` mends a lantern but the Glowcap Lantern never wears (tools.php:285), so the kit only helps Tin and Miner's lanterns.

Rules for `mend_tool()` (tools.php:417-450):
1. Payment order: free Tool Shed mend, then materials, then Petals. This fixes EC7 (kit spent before the free check, tools.php:431).
2. Materials path: `tool-repair-kit` × tier (1 to 4), plus one family material at tier 3 and one rare at tier 4.

| Tool types | Tier 3 extra | Tier 4 extra |
|---|---|---|
| till, weed, prune, spread, forage, pick, axe, soiltest | oak-log:1 | bog-iron:1 |
| water, plant | rubber-sap:1 | rock-crystal:1 |
| harvest, basket | mangrove-root:1 | coir-fibre:4 |
| net, rod | silk-thread:1 | (no tier 4) |
| bucket | cork-bark:1 | (no tier 4) |
| staff | heartwood:1 | (no tier 4) |
| lantern | glowcap-repair-kit:1 alone, any tier | n/a |

3. Petals stay as the fallback at the current 15%.
4. Reset wear only when the stack had no working copy (EC5, tools.php:446).
5. Salvage: a button on a Broken copy returns `tool-repair-kit` × (tier − 1, minimum 1) instead of mending.
6. Rename the kit text so one kit clearly serves fight belts and tools; rename the lantern kit description to "Lantern Repair Kit".

Reforge recipes (crafts.txt, category tools, data-only; `broken-*` items already exist from tools.php:242-245):
- `prospector-s-pick:1` from `broken-rock-pick:1,flint:4,slate-shard:2`
- `fine-mesh-net:1` from `broken-bug-net:1,cottongrass:4`
- `hiking-staff:1` from `broken-walking-stick:1,timber-plank:1,rope:2`
- `miner-s-lantern:1` from `broken-tin-lantern:1,rock-crystal:1,flint:3`
- `glowcap-lantern:1` from `broken-miner-s-lantern:1,firefly-glow:1,chanterelle:4`
- Seven `masterwork-*` rows taking the Broken tier-3 tool plus the existing inputs and one extra of the rare (crafts.txt:6-12).

## 5 Crafting and recipe graph fixes

- **Unreachable or single-source**: `drum-skin` (H1). New, verified: `tallow-wax` is needed by 10 build stages in 9 regions (e.g. build_plans.txt:57) but its only sources are one WCA stop act (stop_acts_regional.txt:309, needs shea) and a Trek Ch3b grub (trek_creatures_ch3b.txt:7). Add the section 2 recipe or let those stages accept `beeswax`.
- **Merges**: `edelweiss`/`cut-edelweiss` (R3): accept both through alt rows now, merge later. Eggshell spellings to `hatchling-eggshell` (R6); 5 crab claws to `crab-claw` (R7); skink/glass-wyrm/giant-otter to the generic part (R8).
- **Tier overlaps**: hot-sauce vs fermented-hot-sauce (recipes.txt:140, 172) and tempeh vs natto (:177-178) share inputs; differentiate by one ingredient or cut. Yogurt outclasses goat-cheese (:184 vs :91).
- **Station balance** (crafts.txt, 82 rows): tools 19, garden 21, building 18, decor 16, potions 8. Kitchen and Pantry hold 245. The alt rows above add about 8 potions, 10 decor, 6 building.
- **Rope and plank yields** (R16): normalise to 3 common inputs per rope and 2 logs per 2 planks; needs migration.
- **Tool cost gap** (E2): raise the tier 2 craft inputs through the reforge rows rather than editing existing ones.

**Node-map artifact (art/index.html, art/items.json): what misleads**
- 38 categories mix real `items.category` values with invented ones: `ingredient` (168, really produce), `pantry` (156, really food), `gatherable` vs `forage`, `tool-broken` (game: `broken`), `potion` (game: `supply`/`soil`); camping-gear shows as `building` (game: `part`).
- Missing edge types: stop-act crafts, Tailor materials (280 rows), build-plan needs, Sight take/give, mending (broken to tool), drying, packets, creature drops, Gourmand. Preserves show station "Kitchen", not Pantry.
- "Orphans only" means no recipe and no shop, so drops, seeds and Sight items look orphaned (848).
- Phantom nodes: 102 name-variant dupes (`prospectors-pick`), trek flags as items, wrong Twigg's stock (EC12), one recipe with a null output, only 15 of 173 `dried-*`.
Regenerate the graph from the repo before using it to pick further sinks.

## 6 Economy

- **Sinks for surplus**: tool mending by materials (flint, pine-resin, coir-fibre through the kit); `any-` part recipes; preserves into double-yield dishes; flowers into compost.
- **Exploit closures first**: EC1 packets, EC2 dried rarity, EC3 buy floor (world.php:468-495), EC5/EC6/EC7 mending, EC9 bulk-sell chunks (world.php:525-529), EC10 markup clamp.
- **New-sink guard**: every alt row's input value must be at least 60% of the output's base price; run `tests/balance_sim.php` after each batch. Flour and tallow-wax rows need this check most.
- **Pricing**: dishes priced like `preserve_price` (E5, catalog.php:676-679) so jar-based dishes are not a loss; Kitchen soup restock at 0.9-1.2× base (E6, seed.php:94-96).
- **Buff slot** (E8, gnome.php:546-560): confirm before a weaker buff overwrites a stronger one, so potions and jars are worth making.

## 7 Sequencing

| Phase | Content | Depends on | Risk |
|---|---|---|---|
| 0 | Regenerate the item graph; fix H5, EC12, R19 errors | none | low |
| 1 | Exploit closures (EC1-3, EC5-7, EC9-10) | none | medium: pricing code |
| 2 | Data-only alt rows: potions, decor, building, flour, tallow-wax, kit, camping, reforge; stop-act rows; tea aliases; build-plan base edits | phase 1 for flowers | low; add-only |
| 3 | Mending by materials and Salvage | phase 2 kit rows | medium: tools.php transaction |
| 4 | `any-<suffix>` craft ingredients, hybrid aliases, Kitchen alt rows (tier copy) | phase 2 | medium: craft_stock, mastery cuts |
| 5 | Merges and renames (R1-R8, twins), yield normalising | user decisions | high: live inventories need a migration |
| 6 | Tailor material variation, part collapse (R9) | user decisions | high: generated data, 840 items |

Tests (in `/home/user/gnome-venture/tests`, run with `tests/ci_suites.sh <name>`):
- Phase 1: `flowers`, `market100`, `trade`, `sinks097`, `tools`.
- Phase 2: `craft`, `php tests/craft_tags.php` (every new row must match a scene glob in craft_scenes.php), `php tests/alchemy.php`, `tea`, `buildplans`, `stopkinds`, `stops100`, `trail_sights_lint`, `gear`.
- Phase 3: `tools`, `satchel`, `pfdeck_v1` (kit shared with fight belts).
- Phase 4: `craft`, `cook`, `pantry`, `pal_pantry`, `php tests/food_mastery.php`, `breeding110`.
- Phase 5-6: `pf_creatures_import`, `tailor`, `wearables`, `updrollback`, `walk`, `php tests/balance_sim.php`.

## 8 Items needing a user decision (cut vs repurpose)

1. About 340 creature parts (R9): keep with `any-` sinks, or collapse into tiered generics.
2. 112 identical Tailor pairs (R18): cut, or differentiate with part materials.
3. Crab claws ×5, skink-scale, glass-wyrm-scale, giant-otter-pelt, three eggshell slugs: merge (recommended) or keep.
4. pickled-peppers, natto, dried-cranberries, sun-dried-tomatoes, apricot and cherry twins: cut or give a distinct input.
5. aged-goat-cheese vs cheese-wheel: merge or keep as a ladder with the alt rows.
6. `edelweiss` vs `cut-edelweiss`: one slug or two.
7. Hybrids (17 unused): alias to parents, or leave as sale-only.
8. perilla, tamarillo, naranjilla, noni: stop-act rows or flavour only.
9. Misc curios (brass-button, dew-pearl, echo-pebble, lost-sock and 4 more) and 9 Sight trinkets: hovel decor sources (7 slots have none, hovel_decor.json) or keepsake bonuses.
10. Trek parts (newt-tail, pale-scale, quartz-shell, silverfish-scales): gate items or cut.
11. kelp-frond, shale-chip, sawdust-heap: remap and cut.
12. Build-plan tool hand-ins (tin-lantern ×12 stages, woven-basket, harvest-trug): accept Broken copies or not.
13. Mending: is the materials path an alternative to Petals (proposed) or a replacement.
14. Existing-row changes (rope/plank yields, R1/R2 renames, hot-sauce pair): approve a migration, or stay add-only.
15. Tea kettle: stay admin-gated (then the 8 tea plants rely on the potion rows) or open to all.
