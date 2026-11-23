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
