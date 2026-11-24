<?php
declare(strict_types=1);

/**
 * 2.7.58 item review, group A: the data changes that touch rows an existing world already has (new recipes and keepsakes arrive by themselves:
 * ensure_crafts and trail_sight_b_ensure only add). Run once by the boot step item_review_data_2758; anything an admin edited is left alone.
 */
function upgrade_2758_data(): void
{
    if (setting('item_review_data_2758') !== '') return;
    // E9: the dishes that buffed less than one raw ingredient (old temp => new temp; only a dish still at the old numbers changes)
    $dishes = [
        'grilled-sardines' => [['grit' => 2, 'minutes' => 120], ['grit' => 3, 'hardiness' => 1, 'minutes' => 240]],
        'toffee-apple' => [['charm' => 2, 'minutes' => 120], ['charm' => 3, 'nimble' => 1, 'minutes' => 240]],
        'sunflower-snack' => [['nimble' => 1, 'sense' => 1, 'minutes' => 120], ['nimble' => 2, 'sense' => 1, 'minutes' => 150]],
        'goat-cheese-salad' => [['charm' => 1, 'sense' => 1, 'minutes' => 120], ['charm' => 2, 'sense' => 1, 'minutes' => 180]],
    ];
    foreach ($dishes as $slug => [$oldTemp, $newTemp]) {
        $it = q_one('SELECT id, effects FROM items WHERE slug = ?', [$slug]);
        $fx = $it ? json_decode((string)$it['effects'], true) : null;
        if (!is_array($fx) || ($fx['temp'] ?? null) != $oldTemp) continue;
        $fx['temp'] = $newTemp;
        q('UPDATE items SET effects = ? WHERE id = ?', [json_encode($fx), (int)$it['id']]);
    }
    // E6: the Dewdrop Kitchen's soup at 1.0x the home dish's base (was 40-55 against 90); the shop-bought copy's own base is half the stock price (ensure_shop_food)
    $home = (int)q_val("SELECT base_price FROM items WHERE slug = 'garden-vegetable-soup'");
    foreach (q("SELECT st.id, st.price_min, st.price_max, i.id AS item_id, i.slug FROM shop_stock st JOIN items i ON i.id = st.item_id
                WHERE i.slug IN ('garden-vegetable-soup', 'bought-garden-vegetable-soup')")->fetchAll() as $st) {
        if ($home < 1 || (int)$st['price_min'] !== 40 || (int)$st['price_max'] !== 55) continue;   // moved by an admin: left alone
        q('UPDATE shop_stock SET price_min = ?, price_max = ?, current_price = ? WHERE id = ?', [$home, $home, $home, (int)$st['id']]);
        if ($st['slug'] === 'bought-garden-vegetable-soup') q('UPDATE items SET base_price = ? WHERE id = ? AND base_price = 20', [(int)floor($home * 0.5), (int)$st['item_id']]);
    }
    set_setting('item_review_data_2758', '1');
}

/** 2.7.58 EC6: Broken tool copies made before this release are tradable=1; they cannot be gifted or traded now (idempotent). */
function upgrade_2758_broken(): void
{
    q("UPDATE items SET tradable = 0 WHERE category = 'broken' AND tradable <> 0");
}

/** 2.7.58 EC7: the Glowcap kit's text says what it mends (only while it still reads the old text, so an admin edit is kept). */
function upgrade_2758_kit_text(): void
{
    q("UPDATE items SET description = ? WHERE slug = 'glowcap-repair-kit' AND description = ?", [
        'A tin of wicks, a spare glass and a very small screwdriver for a tired glowcap lantern. It mends a lantern only (the Tool Repair Kit is for fight belts), and a free Tool Shed mend is used first.',
        'A tin of wicks, a spare glass and a very small screwdriver for a tired glowcap lantern.']);
    // the Tool Repair Kit also mends garden and gathering tools (free Tool Shed mend first, then kits, then Petals); same rule: only the old text is replaced
    q("UPDATE items SET description = ? WHERE slug = 'tool-repair-kit' AND description = ?", [
        'Flint, resin and a twist of fibre. Fixes one fight tool on your Puzzle box belt: its piece is worn out by fights (2 each time it is played) and comes back at full strength. It also mends garden and gathering tools: a Tool Shed mend is free and used first, then kits, then Petals.',
        'Flint, resin and a twist of fibre. Fixes one fight tool on your Puzzle box belt: its piece is worn out by fights (2 each time it is played) and comes back at full strength.']);
}

/**
 * 2.7.58 uA-1 / uA-2: a creature drop named like a flower or a crop (Cornflower, Date Palm, Prickly Pear Cactus) used to become its own 'part' item, which cannot be arranged or planted.
 * pfc_item_for_drop now finds the real item (cut flower, produce); this moves the old twins' drop rows and satchel stock onto it. The twin item row stays (nothing else is changed). Once.
 */
function upgrade_2758_drop_twins(): void
{
    if (setting('drop_twins_2758') !== '') return;
    require_once __DIR__ . '/adventure_data.php';
    $n = 0;
    foreach (q("SELECT t.id AS twin, p.produce_item_id AS real_id FROM items t JOIN plants p ON LOWER(p.name) = LOWER(t.name)
                JOIN items r ON r.id = p.produce_item_id WHERE t.category = 'part' AND r.category <> 'part' AND p.produce_item_id <> t.id")->fetchAll() as $r) {
        $t = (int)$r['twin']; $real = (int)$r['real_id'];
        if (in_array((string)q_val('SELECT slug FROM items WHERE id = ?', [$t]), PFC_KEEP_PART_TWINS, true)) continue;   // the teas use it
        foreach (q('SELECT id, creature_id FROM creature_drops WHERE item_id = ?', [$t])->fetchAll() as $d) {
            if (q_val('SELECT 1 FROM creature_drops WHERE creature_id = ? AND item_id = ?', [(int)$d['creature_id'], $real])) q('DELETE FROM creature_drops WHERE id = ?', [(int)$d['id']]);
            else q('UPDATE creature_drops SET item_id = ? WHERE id = ?', [$real, (int)$d['id']]);
            $n++;
        }
        foreach (q('SELECT user_id, qty FROM user_items WHERE item_id = ? AND qty > 0', [$t])->fetchAll() as $h) {
            give_item((int)$h['user_id'], $real, (int)$h['qty']);
            q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$h['user_id'], $t]);
            $n++;
        }
    }
    set_setting('drop_twins_2758', '1');
}

/** 2.7.58 R4: three regional rest-stop crafts made a generic dish; they make the dedicated item now (only while the row still reads the old spec, so an admin edit is kept). */
function upgrade_2758_stop_acts(): void
{
    if (setting('stop_acts_2758') !== '') return;
    foreach ([
        'r_wca_egusi_soup' => ['egusi:2,okra:2>garden-vegetable-soup:1', 'egusi:2,okra:2>egusi-soup:1'],
        'r_ee_buckwheat_kasha' => ['buckwheat:2,goat-milk:1>goat-milk-porridge:1', 'buckwheat:2,goat-milk:1>buckwheat-kasha:1'],
        'r_wca_roselle_cordial' => ['hibiscus:3,garden-honey:1>mixed-berry-cordial:1', 'hibiscus:3,garden-honey:1>hibiscus-cordial:1'],
    ] as $slug => [$was, $now]) q('UPDATE stop_acts SET spec = ? WHERE slug = ? AND spec = ?', [$now, $slug, $was]);
    set_setting('stop_acts_2758', '1');
    if (function_exists('stop_acts')) stop_acts(true);
}

/** 2.7.58 E2: the tier 2-4 garden and gathering tools at Twigg's were 4-8x their craft inputs; the new prices are in TOOL_ITEMS (tier 2 and 3 x0.6, masterworks x0.75). Only a row still at the old numbers moves. */
const TOOL_OLD_PRICES_2758 = [
    'garden-hoe' => 250, 'steel-spade' => 1200, 'masterwork-wheel-hoe' => 6000, 'copper-watering-can' => 300, 'sprinkler-can' => 1400,
    'masterwork-rain-wand' => 6500, 'seed-scoop' => 280, 'seed-drill' => 1300, 'masterwork-gnome-seeder' => 6000, 'garden-fork' => 300,
    'wheelbarrow' => 1500, 'masterwork-barrow' => 7000, 'hori-hori' => 260, 'stirrup-hoe' => 1200, 'masterwork-stirrup-hoe' => 5500,
    'harvest-trug' => 280, 'harvest-sack' => 1200, 'masterwork-harvest-cart' => 6000, 'pruning-shears' => 350, 'fine-secateurs' => 1500,
    'masterwork-secateurs' => 7000, 'hooked-forager-s-knife' => 420, 'fine-foraging-knife' => 1600, 'prospector-s-pick' => 450,
    'fine-rock-hammer' => 1700, 'fine-mesh-net' => 380, 'silk-net' => 1500, 'tide-pail-and-scoop' => 350, 'diver-s-creel' => 1500,
    'woodcutter-s-axe' => 450, 'fine-felling-axe' => 1700, 'cane-fishing-rod' => 420, 'fine-fly-rod' => 1600, 'gathering-basket' => 500,
    'forager-s-pack' => 2000, 'hiking-staff' => 520, 'wayfarer-s-staff' => 1800, 'miner-s-lantern' => 600, 'glowcap-lantern' => 2000,
    'soil-probe' => 900,
];
function upgrade_2758_tool_prices(): void
{
    if (setting('tool_prices_2758') !== '') return;
    require_once __DIR__ . '/tools.php';
    foreach (TOOL_ITEMS as [$type, $tier, $name, $price]) {
        $slug = tool_slug($name); $old = TOOL_OLD_PRICES_2758[$slug] ?? 0;
        if ($old < 1 || $old === (int)$price) continue;
        q("UPDATE items SET base_price = ? WHERE slug IN (?, ?) AND base_price = ?", [(int)$price, $slug, 'broken-' . $slug, $old]);
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if ($id) q('UPDATE shop_stock SET price_min = ?, price_max = ?, current_price = ? WHERE item_id = ? AND price_min = ? AND price_max = ?',
            [(int)floor($price * 0.9), (int)ceil($price * 1.2), (int)$price, $id, (int)floor($old * 0.9), (int)ceil($old * 1.2)]);
    }
    set_setting('tool_prices_2758', '1');
}

/**
 * 2.7.58 item review group C, R8 + R15: same-animal part splits and drop-only parallel materials are merged into the existing item.
 * [old slug, new slug, new name]. The new item is the one the data files drop now; if an old world has no row of it yet, the old row is renamed (same id, so every stack stays).
 */
const MERGE_ITEMS_2758 = [
    ['skink-scale', 'lizard-scale', 'Lizard Scale'], ['glass-wyrm-scale', 'wyrm-scale', 'Wyrm Scale'], ['giant-otter-pelt', 'otter-pelt', 'Otter Pelt'],   // R8
    ['kelp-frond', 'bladderwrack', 'Bladderwrack'], ['shale-chip', 'slate-shard', 'Slate Shard'], ['sawdust-heap', 'wood-chips', 'Wood Chips'],            // R15
];

/** Merge item $old into $new: creature drops (one row per creature; the higher chance wins, an ungated old row ungates it), satchel stacks, trophy pins. Returns the rows touched. */
function merge_item_2758(string $old, string $new, string $newName): int
{
    $o = (int)q_val('SELECT id FROM items WHERE slug = ?', [$old]);
    if (!$o) return 0;
    $n = (int)q_val('SELECT id FROM items WHERE slug = ?', [$new]);
    if (!$n) {   // nothing to merge into yet: the old row becomes the new item
        q('UPDATE items SET slug = ?, name = ? WHERE id = ?', [$new, $newName, $o]);
        return 1;
    }
    $t = 0;
    foreach (q('SELECT * FROM creature_drops WHERE item_id = ?', [$o])->fetchAll() as $d) {
        $have = q_one('SELECT * FROM creature_drops WHERE creature_id = ? AND item_id = ? ORDER BY id LIMIT 1', [(int)$d['creature_id'], $n]);
        if ($have) {
            $ungate = $d['reg'] === null && $d['lvmin'] === null && $d['lvmax'] === null;
            q('UPDATE creature_drops SET chance = ?' . ($ungate ? ', reg = NULL, lvmin = NULL, lvmax = NULL' : '') . ' WHERE id = ?', [max((int)$have['chance'], (int)$d['chance']), (int)$have['id']]);
            q('DELETE FROM creature_drops WHERE id = ?', [(int)$d['id']]);
        } else q('UPDATE creature_drops SET item_id = ? WHERE id = ?', [$n, (int)$d['id']]);
        $t++;
    }
    foreach (q('SELECT user_id, qty FROM user_items WHERE item_id = ? AND qty > 0', [$o])->fetchAll() as $h) {
        give_item((int)$h['user_id'], $n, (int)$h['qty']);
        $t++;
    }
    q('DELETE FROM user_items WHERE item_id = ?', [$o]);
    q('DELETE FROM item_quality WHERE item_id = ?', [$o]);
    try { q('UPDATE user_trophies SET item_id = ? WHERE item_id = ?', [$n, $o]); } catch (Throwable $e) { /* the trophy table is made on first use */ }
    try { q('UPDATE stall_listings SET item_id = ? WHERE item_id = ?', [$n, $o]); } catch (Throwable $e) { /* no stall table: nothing listed */ }   // open stall listings keep selling, as the merged item
    return $t;
}

/** R8 + R15 for an existing world (once, marker merge_items_2758), and the three rest-stop crafts that took kelp-frond / shale-chip now take the material (only a row still at the old spec). */
function upgrade_2758_merge_items(): void
{
    if (setting('merge_items_2758') !== '') return;
    foreach (MERGE_ITEMS_2758 as [$old, $new, $name]) merge_item_2758($old, $new, $name);
    foreach ([
        'w1_dry_kelp' => ['kelp-frond:3>kelp-meal:1', 'bladderwrack:3>kelp-meal:1'],
        'w5_mineral_silt' => ['river-clay:2,shale-chip:1>rock-dust:1', 'river-clay:2,slate-shard:1>rock-dust:1'],
        'r_se_cinder_grit' => ['shale-chip:3>rock-dust:2', 'slate-shard:3>rock-dust:2'],
    ] as $slug => [$was, $now]) q('UPDATE stop_acts SET spec = ? WHERE slug = ? AND spec = ?', [$now, $slug, $was]);
    set_setting('merge_items_2758', '1');
    if (function_exists('stop_acts')) stop_acts(true);
}

/** R14: the kettle's journal keys no longer reuse the kitchen recipes' slugs (data/teas.txt). Rows move to the new key; a gnome who somehow has both keeps the sum of times and the earlier day. Once. */
const KETTLE_KEYS_2758 = ['mint-tea' => 'kettle-mint-tea', 'meadowsweet-tea' => 'kettle-meadowsweet-tea', 'desert-sage-tea' => 'kettle-desert-sage-tea'];
function upgrade_2758_kettle_keys(): void
{
    if (setting('kettle_keys_2758') !== '') return;
    try {
        foreach (KETTLE_KEYS_2758 as $old => $new) {
            foreach (q('SELECT user_id, first_day, times FROM user_tea_journal WHERE tea_slug = ?', [$old])->fetchAll() as $r) {
                $has = q_one('SELECT first_day, times FROM user_tea_journal WHERE user_id = ? AND tea_slug = ?', [(int)$r['user_id'], $new]);
                if ($has) {
                    q('UPDATE user_tea_journal SET times = ?, first_day = ? WHERE user_id = ? AND tea_slug = ?', [(int)$has['times'] + (int)$r['times'], min((string)$has['first_day'], (string)$r['first_day']), (int)$r['user_id'], $new]);
                    q('DELETE FROM user_tea_journal WHERE user_id = ? AND tea_slug = ?', [(int)$r['user_id'], $old]);
                } else q('UPDATE user_tea_journal SET tea_slug = ? WHERE user_id = ? AND tea_slug = ?', [$new, (int)$r['user_id'], $old]);
            }
        }
    } catch (Throwable $e) { /* no journal table yet: no old keys either */ }
    set_setting('kettle_keys_2758', '1');
}

/**
 * 2.7.58 item review group C, R5: rest-stop crafts that made a kitchen dish or craft output for less than 90% of that recipe's inputs (base value) take more of their main
 * (first) ingredient, at most +3; plus R16 (the enset rope). [old spec, new spec]. Exact copies of a recipe were cut from the data files (new worlds only).
 */
const STOP_TUNE_2758 = [
    'ca_cocoa_grind' => ['cacao:2>hot-cocoa:1', 'cacao:3>hot-cocoa:1'],
    'r_ca_fruit_bowl' => ['papaya:1,mamey:1>tropical-fruit-bowl:1', 'papaya:2,mamey:1>tropical-fruit-bowl:1'],
    'r_ca_three_sisters' => ['corn:1,black-bean:1,pumpkin:1>three-sisters-stew:1', 'corn:3,black-bean:1,pumpkin:1>three-sisters-stew:1'],
    'r_csa_mango_chutney' => ['mango:2,ginger:1>mango-chutney:1', 'mango:3,ginger:1>mango-chutney:1'],
    'r_csa_mung_dal' => ['mung-bean:2,turmeric:1>lentil-dal:1', 'mung-bean:4,turmeric:1>lentil-dal:1'],
    'r_ea_bokchoy_rice' => ['bok-choy:1,rice:1,hen-egg:1>egg-fried-rice:1', 'bok-choy:3,rice:1,hen-egg:1>egg-fried-rice:1'],
    'r_ea_kimchi' => ['napa-cabbage:2,ginger:1>kimchi:1', 'napa-cabbage:5,ginger:1>kimchi:1'],
    'r_ea_perilla_pickled_leaves' => ['perilla:3>kimchi:1', 'perilla:6>kimchi:1'],
    'r_ee_buckwheat_kasha' => ['buckwheat:2,goat-milk:1>buckwheat-kasha:1', 'buckwheat:3,goat-milk:1>buckwheat-kasha:1'],
    'r_ee_elder_cordial' => ['elderberry:2,sea-buckthorn:1>elderberry-cordial:1', 'elderberry:4,sea-buckthorn:1>elderberry-cordial:1'],
    'r_ee_plum_butter' => ['plum:3>plum-jam:1', 'plum:5>plum-jam:1'],
    'r_ee_stuffed_peppers' => ['bell-pepper:2,goat-cheese:1>stuffed-peppers-goat:1', 'bell-pepper:4,goat-cheese:1>stuffed-peppers-goat:1'],
    'r_esa_enset_fibre' => ['ensete:2>rope:1', 'ensete:2>rope:3'],
    'r_esa_sorghum_porridge' => ['sorghum:2,goat-milk:1>goat-milk-porridge:1', 'sorghum:3,goat-milk:1>goat-milk-porridge:1'],
    'r_mena_chickpea_cumin' => ['chickpea:2,cumin:1>chickpea-stew:1', 'chickpea:3,cumin:1>chickpea-stew:1'],
    'r_na_crowberry_cordial' => ['crowberries:3>crowberry-cordial:1', 'crowberries:4>crowberry-cordial:1'],
    'r_na_fiddlehead_fry' => ['fiddleheads:3>fiddlehead-fry:1', 'fiddleheads:4>fiddlehead-fry:1'],
    'r_nwe_dill_beets' => ['beet:2,dill:1>pickled-beets:1', 'beet:4,dill:1>pickled-beets:1'],
    'r_nwe_peat_trout' => ['trout:1,bog-peat:1>smoked-trout:1', 'trout:2,bog-peat:1>smoked-trout:1'],
    'r_oc_earth_oven' => ['taro:2,coconut:1>coconut-curry:1', 'taro:3,coconut:1>coconut-curry:1'],
    'r_oc_noni_juice' => ['noni:2>sea-buckthorn-juice:1', 'noni:5>sea-buckthorn-juice:1'],
    'r_sa_naranjilla_cordial' => ['naranjilla:3>lime-cordial:1', 'naranjilla:4>lime-cordial:1'],
    'r_se_fig_tart' => ['goat-cheese:1,fig:2>goat-cheese-tart:1', 'goat-cheese:2,fig:2>goat-cheese-tart:1'],
    'r_se_hill_cheese' => ['goat-milk:2,sea-salt:1>goat-cheese:1', 'goat-milk:3,sea-salt:1>goat-cheese:1'],
    'r_sea_lemongrass_curry' => ['coconut:1,lemongrass:1,rice:1>coconut-curry:1', 'coconut:2,lemongrass:1,rice:1>coconut-curry:1'],
    'w1_leek_soup' => ['potato:2,leek:1>potato-leek-soup:1', 'potato:4,leek:1>potato-leek-soup:1'],
    'w1_spring_pickle' => ['hen-egg:2,sea-salt:1>pickled-eggs:1', 'hen-egg:5,sea-salt:1>pickled-eggs:1'],
    'w2_apple_crumble' => ['apple:3,wheat:1>apple-crumble:1', 'apple:4,wheat:1>apple-crumble:1'],
    'w2_carrot_cake' => ['carrot:2,wheat:1,hen-egg:1>carrot-cake:1', 'carrot:5,wheat:1,hen-egg:1>carrot-cake:1'],
    'w2_chutney_pot' => ['tomato:3,onion:1>tomato-chutney:1', 'tomato:6,onion:1>tomato-chutney:1'],
    'w2_kraut_crock' => ['cabbage:3,sea-salt:1>sauerkraut:1', 'cabbage:5,sea-salt:1>sauerkraut:1'],
    'w2_oat_porridge' => ['oats:2,goat-milk:1>goat-milk-porridge:1', 'oats:3,goat-milk:1>goat-milk-porridge:1'],
    'w3_dill_jars' => ['cucumber:3,dill:1>dill-pickles:1', 'cucumber:5,dill:1>dill-pickles:1'],
    'w3_ramson_pesto' => ['ramsons:3,basil:1>ramson-pesto:1', 'ramsons:4,basil:1>ramson-pesto:1'],
    'w4_apple_chutney' => ['apple:3,onion:1>apple-chutney:1', 'apple:4,onion:1>apple-chutney:1'],
    'w4_ginger_cordial' => ['apple:2,ginger:1>ginger-apple-cordial:1', 'apple:4,ginger:1>ginger-apple-cordial:1'],
    'w4_mussel_broth' => ['blue-mussels:3>mussel-broth:1', 'blue-mussels:5>mussel-broth:1'],
    'w5_buried_cornbread' => ['corn:2,hen-egg:1>cornbread:1', 'corn:3,hen-egg:1>cornbread:1'],
    'w5_three_sisters' => ['corn:1,green-bean:1,pumpkin:1>three-sisters-stew:1', 'corn:4,green-bean:1,pumpkin:1>three-sisters-stew:1'],
    'w5_warm_curds' => ['goat-milk:3>goat-cheese:1', 'goat-milk:4>goat-cheese:1'],
    'w5_watchers_cocoa' => ['cacao:2,goat-milk:1>hot-cocoa:1', 'cacao:3,goat-milk:1>hot-cocoa:1'],
];

/** R5 / R16 for an existing world: a stop craft moves only while it still holds the old spec (an admin edit stays). Once, marker stop_tune_2758. */
function upgrade_2758_stop_tune(): void
{
    if (setting('stop_tune_2758') !== '') return;
    foreach (STOP_TUNE_2758 as $slug => [$was, $now]) q('UPDATE stop_acts SET spec = ? WHERE slug = ? AND spec = ?', [$now, $slug, $was]);
    set_setting('stop_tune_2758', '1');
    if (function_exists('stop_acts')) stop_acts(true);
}

/**
 * R16: plank and rope recipes yield by what goes in. [recipe slug, old ingredients, old yield, new ingredients, new yield]. Wood-chip and palm planks (30 Petals of chips each) give more,
 * driftwood gives as many planks as logs do, oak 3 not 4, every fibre rope takes 2 fibres, goat hair 1 for 2 rope. A row moves only while it has the old numbers.
 */
const PLANK_ROPE_2758 = [
    ['timber-plank', ['wood-chips' => 3, 'pine-resin' => 1], 2, ['wood-chips' => 3, 'pine-resin' => 1], 3],
    ['timber-plank-palm', ['coir-fibre' => 2, 'wood-chips' => 2], 1, ['coir-fibre' => 2, 'wood-chips' => 2], 2],
    ['timber-plank-drift', ['driftwood' => 2], 1, ['driftwood' => 2], 2],
    ['timber-plank-oak', ['oak-log' => 1], 4, ['oak-log' => 1], 3],
    ['rope-cottongrass', ['cottongrass' => 3], 1, ['cottongrass' => 2], 1],
    ['rope-cattail', ['cattail-root' => 3], 1, ['cattail-root' => 2], 1],
    ['rope-goat-hair', ['goat-hair' => 3], 2, ['goat-hair' => 1], 2],
];
function upgrade_2758_plank_rope(): void
{
    if (setting('plank_rope_2758') !== '') return;
    foreach (PLANK_ROPE_2758 as [$slug, $oldIng, $oldQty, $newIng, $newQty])
        q('UPDATE recipes SET ingredients = ?, output_qty = ? WHERE slug = ? AND ingredients = ? AND output_qty = ?', [json_encode($newIng), $newQty, $slug, json_encode($oldIng), $oldQty]);
    set_setting('plank_rope_2758', '1');
}
