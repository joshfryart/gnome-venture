<?php
declare(strict_types=1);
/**
 * NPK soil (v0.7.6). Every square keeps Fertility (overall richness) plus three nutrients:
 *   N nitrogen   – leaves and grains       (leafy greens, grains, herbs)
 *   P phosphorus – roots and blooms        (roots, tubers, legumes, spices, flowers)
 *   K potassium  – fruit                   (fruiting vegetables, fruit, trees, nuts)
 * Each crop feeds on one of them. Its nutrient nudges growth speed (0 = -15%, 50 = normal, 100 = +15%),
 * and each harvest uses some up. Legumes put nitrogen back; cover crops feed all three.
 * Nutrients start at 50 (balanced), so older gardens carry on exactly as before.
 */

const NUTRIENTS = [
    'n' => ['Nitrogen', 'N', '🍃', 'leaves and grains'],
    'p' => ['Phosphorus', 'P', '🥕', 'roots and blooms'],
    'k' => ['Potassium', 'K', '🍅', 'fruit'],
];

/** Vegetables that are really roots or fruit, for the default nutrient. Everything else is read from the crop kind. */
const ROOT_VEG = ['carrot', 'beet', 'radish', 'turnip', 'onion', 'garlic', 'leek', 'shallot', 'parsnip', 'rutabaga',
    'daikon', 'celeriac', 'horseradish', 'kohlrabi', 'jicama', 'burdock', 'salsify', 'sweet-potato', 'yam', 'taro'];
const FRUIT_VEG = ['tomato', 'bell-pepper', 'chili-pepper', 'eggplant', 'cucumber', 'pumpkin', 'squash', 'zucchini',
    'melon', 'watermelon', 'okra', 'tomatillo', 'bitter-melon', 'chayote', 'winter-melon', 'luffa', 'butternut-squash'];

/** The nutrient a crop feeds on: 'n', 'p', 'k', or '' (cover crops feed the soil instead). */
function default_nutrient(string $slug, string $kind): string
{
    if ($kind === 'cover') return '';
    if ($kind === 'vegetable') return in_array($slug, ROOT_VEG, true) ? 'p' : (in_array($slug, FRUIT_VEG, true) ? 'k' : 'n');
    return match ($kind) {
        'tuber', 'legume', 'spice', 'flower' => 'p',
        'fruit', 'tree', 'nut' => 'k',
        default => 'n',   // grain, herb
    };
}

function nutrient_word(int $v): string
{
    return $v < 15 ? 'starved' : ($v < 35 ? 'low' : ($v < 65 ? 'balanced' : ($v < 85 ? 'high' : 'abundant')));
}

/** Growth multiplier from the crop's nutrient. */
function nutrient_speed(array $t): float
{
    $need = (string)($t['_need'] ?? '');
    if (!isset(NUTRIENTS[$need])) return 1.0;
    return 0.85 + 0.30 * clamp100((int)($t[$need] ?? 50)) / 100;
}

/** Nutrient changes for a harvest: [n, p, k] deltas. */
function harvest_nutrients(array $p, bool $perennial): array
{
    $d = ['n' => 0, 'p' => 0, 'k' => 0];
    if ($p['kind'] === 'cover') return ['n' => 12, 'p' => 4, 'k' => 4];   // dug in: green manure
    $need = (string)($p['nutrient'] ?? '');
    if (isset($d[$need])) $d[$need] -= (int)$p['soil_effect'] < -10 ? 10 : 6;   // heavy feeders use more
    if ($p['kind'] === 'legume') $d['n'] += 8;                                   // beans fix nitrogen
    if ($perennial) foreach ($d as $k => $v) $d[$k] = intdiv($v, 2);
    return $d;
}

/** Soil items added in v0.7.6: [slug, name, price, rarity, effects, description, sold at Twigg's]. */
const NPK_ITEMS = [
    ['kelp-meal', 'Kelp Meal', 35, 6, ['k' => 20, 'n' => 4, 'hours' => 24], 'Dried, ground seaweed. Works in over a day: potassium +20, nitrogen +4. Fruit loves it.', true],
    ['shell-meal', 'Shell Meal', 35, 6, ['p' => 20, 'hours' => 48], 'Crushed empty shells. Works in over two days: phosphorus +20. For roots and flowers.', true],
    ['worm-tea', 'Worm Tea', 25, 5, ['n' => 15, 'life' => 3, 'hours' => 6], 'Worm castings steeped in rainwater. Soaks in within hours: nitrogen +15, soil life +3. For leafy greens.', false],
    ['wood-ash', 'Wood Ash', 15, 3, ['k' => 15, 'hours' => 12], 'Soft grey ash from a garden fire. Works in over half a day: potassium +15.', false],
    ['rock-dust', 'Rock Dust', 40, 8, ['p' => 10, 'k' => 10, 'life' => 2, 'hours' => 72], 'Finely ground stone. Slow, over three days: phosphorus +10, potassium +10, soil life +2.', false],
    ['fern-tea', 'Fern Tea', 20, 4, ['n' => 12, 'hours' => 12], 'Young fern tips soaked until they smell green. Nitrogen +12 over half a day.', false],
];

/** NPK added to the older amendments, only if they don't have any yet (so admin edits stand). */
const NPK_BACKFILL = [
    'plain-compost' => ['n' => 3, 'p' => 3, 'k' => 3],
    'rich-loam' => ['n' => 5, 'p' => 5, 'k' => 5],
    'worm-castings' => ['n' => 8, 'p' => 3, 'k' => 3],
    'leaf-mould' => ['k' => 3],
];

/** Add the NPK items, stock some at Twigg's, give crops their nutrient and the old amendments their NPK. Adds only. */
function ensure_nutrients(): int
{
    $added = 0;
    $shop = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
    foreach (NPK_ITEMS as [$slug, $name, $price, $rarity, $fx, $desc, $sold]) {
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if (!$id) {
            $id = db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => 'soil', 'base_price' => $price,
                'rarity' => $rarity, 'description' => $desc, 'effects' => json_encode($fx)]);
            $added++;
        }
        if ($sold && $shop && !q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, $id])) {
            db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => $id, 'price_min' => (int)floor($price * 0.9),
                'price_max' => (int)ceil($price * 1.2), 'max_stock' => 15, 'restock_chance' => 70, 'current_stock' => 0, 'current_price' => $price]);
        }
    }
    foreach (NPK_BACKFILL as $slug => $npk) {
        $row = q_one('SELECT id, effects, description FROM items WHERE slug = ?', [$slug]);
        if (!$row) continue;
        $fx = json_decode((string)$row['effects'], true) ?: [];
        if (isset($fx['n']) || isset($fx['p']) || isset($fx['k'])) continue;
        $fx += $npk;
        $extra = ' ' . implode(', ', array_map(fn($k, $v) => NUTRIENTS[$k][1] . ' +' . $v, array_keys($npk), $npk)) . '.';
        q('UPDATE items SET effects = ?, description = ? WHERE id = ?', [json_encode($fx), rtrim((string)$row['description']) . $extra, $row['id']]);
    }
    // Almanac page in Getting started; players who already have the opening pages get it too
    if (!q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'Soil nutrients: N, P and K' AND chapter = 'General'")) {
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'Soil nutrients: N, P and K',
            'body' => "Besides fertility, every square holds three nutrients. Each crop feeds on one:\n"
                . "🍃 [b]Nitrogen (N)[/b] for leaves and grains: lettuce, cabbage, wheat, rice, herbs.\n"
                . "🥕 [b]Phosphorus (P)[/b] for roots and blooms: carrots, onions, potatoes, beans, spices, flowers.\n"
                . "🍅 [b]Potassium (K)[/b] for fruit: tomatoes, peppers, squash, fruit trees, nuts.\n\n"
                . "A well-fed crop grows up to 15% faster; a starved one up to 15% slower. Each harvest uses some of its nutrient, so "
                . "[b]rotate[/b]: follow tomatoes (K) with lettuce (N), then carrots (P). Beans give nitrogen back, and cover crops feed all three when dug in.\n\n"
                . "[b]Top-ups:[/b] worm tea or fern tea (N), shell meal (P), kelp meal or wood ash (K), rock dust (P and K). "
                . "Compost adds a little of everything. Craft them from things you gather, or buy kelp and shell meal at Twigg's.",
            'unlock_key' => 'start', 'hint' => '', 'sort_order' => 2]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
        }
    }
    foreach (q("SELECT id, slug, kind FROM plants WHERE nutrient IS NULL")->fetchAll() as $p) {
        q('UPDATE plants SET nutrient = ? WHERE id = ?', [default_nutrient((string)$p['slug'], (string)$p['kind']), $p['id']]);
    }
    return $added;
}


/**
 * v0.7.54: how long each amendment takes to work in, in minutes (Joshua: 15 at most). Stronger = slower.
 * Replaces the old "hours" in item effects (0.7.51 read those as minutes by mistake). slug => [minutes, description or ''].
 */
const AMEND_TIMES = [
    'worm-tea'      => [3, 'Worm castings steeped in rainwater. Soaks in within 3 minutes: nitrogen +15, soil life +3. For leafy greens.'],
    'fern-tea'      => [3, 'Young fern tips soaked until they smell green. Nitrogen +12, worked in within 3 minutes.'],
    'earthworm'     => [3, 'A wriggly friend from the old mine. Let it go in a garden square: soil life +8 within 3 minutes. Or keep a few for a worm bin.'],
    'wood-ash'      => [5, 'Soft grey ash from a garden fire. Works in over 5 minutes: potassium +15.'],
    'plain-compost' => [10, 'Works into the soil over 10 minutes: fertility +15, soil life +3, and a little nitrogen, phosphorus and potassium (+3 each).'],
    'worm-castings' => [10, 'Works into the soil over 10 minutes: fertility +10, soil life +12, nitrogen +8, phosphorus +3, potassium +3. Pure worm magic.'],
    'kelp-meal'     => [10, 'Dried, ground seaweed. Works in over 10 minutes: potassium +20, nitrogen +4. Fruit loves it.'],
    'rich-loam'     => [15, 'Works into the soil over 15 minutes: fertility +30, soil life +5, and nitrogen, phosphorus and potassium +5 each.'],
    'shell-meal'    => [15, 'Crushed empty shells. Works in over 15 minutes: phosphorus +20. For roots and flowers.'],
    'rock-dust'     => [15, 'Finely ground stone. The slowest, 15 minutes: phosphorus +10, potassium +10, soil life +2.'],
    'leaf-mould'    => [10, ''],
    'straw-mulch'   => [10, ''],
    'wood-chips'    => [10, ''],
];

/** Puts the amendment times on the items (safe to repeat) and shortens any square still working in an old, long one. */
function ensure_amend_minutes(): void
{
    foreach (AMEND_TIMES as $slug => [$min, $desc]) {
        $row = q_one('SELECT id, effects, description FROM items WHERE slug = ?', [$slug]);
        if (!$row) continue;
        $fx = json_decode((string)$row['effects'], true) ?: [];
        if (($fx['minutes'] ?? null) === $min && !isset($fx['hours'])) continue;
        unset($fx['hours']);
        $fx['minutes'] = $min;
        q('UPDATE items SET effects = ?, description = ? WHERE id = ?', [json_encode($fx), $desc !== '' ? $desc : (string)$row['description'], $row['id']]);
    }
    $cap = max(1, (int)setting('amend_max_minutes'));
    q('UPDATE plot_tiles SET feed_hours = ' . $cap . ' WHERE feed_hours > ' . $cap);
}
