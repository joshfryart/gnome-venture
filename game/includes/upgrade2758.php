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
