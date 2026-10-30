<?php
declare(strict_types=1);
/**
 * Crafting: one system for cooking, tool-making and garden supplies.
 * A recipe is discovered once you've collected every ingredient (grown it, gathered it, or held it),
 * and stays discovered after the ingredients are used up.
 */
require_once __DIR__ . '/gardens.php';
require_once __DIR__ . '/gnome.php';

/** category => [label, icon, building needed (or null), blurb] */
const CRAFT_CATEGORIES = [
    'cooking' => ['Cooking', '🍳', 'kitchen', 'Meals from your harvests and the wild. One meal buff at a time; meals also restore energy.'],
    'pantry' => ['Pantry', '🫙', 'kitchen', 'Jam, pickles, sauerkraut and cordials from your harvests, kept in the jars of a Pantry (a Kitchen add-on). They take real days, never spoil, and sell for more than the crops.'],
    'tools'   => ['Tools', '🔨', 'tool_shed', 'Upgrade your tools with things you gather on adventures. Masterwork tools can only be made here.'],
    'garden'  => ['Garden supplies', '🪴', null, 'Compost, loam and mulch from gathered materials. No building needed.'],
    'building' => ['Building', '🧱', null, 'Dressed stone, timber and rope for repairing the Hollow’s ruined landmarks (take on a repair at the place itself). No building needed.'],
    'decor' => ['Yard & decor', '🏡', null, 'Paths, fences and ornaments for your yard, from things you gather. No building needed. Place them with ✏️ Design yard.'],
];

/** Add any missing recipes from recipes.txt and crafts.txt. Never changes ones that exist. */
function ensure_crafts(): int
{
    require_once __DIR__ . '/catalog.php';
    require_once __DIR__ . '/rebuild.php';
    ensure_building_items();   // v0.7.29: stone, timber and rope must exist before their recipes
    ensure_food_scrap();       // v0.9.4: the Food Scrap item must exist before the scrap compost recipe
    require_once __DIR__ . '/yard.php';
    ensure_decor_items();      // v0.7.33: yard decor, some of it crafted
    $stats = ['items' => 0];
    $added = import_recipes($stats);
    // Recipes made before v0.7.5 have no slug: give them their dish's slug
    q("UPDATE recipes SET slug = (SELECT slug FROM items WHERE items.id = recipes.output_item_id) WHERE slug IS NULL");
    foreach (catalog_lines('crafts.txt') as $r) {
        if (count($r) < 6) continue;
        [$slug, $name, $cat, $makes, $ingr, $energy] = $r;
        if (!isset(CRAFT_CATEGORIES[$cat]) || q_val('SELECT 1 FROM recipes WHERE slug = ?', [$slug])) continue;
        [$outSlug, $outQty] = array_map('trim', explode(':', $makes) + [1 => 1]);
        $outId = (int)q_val('SELECT id FROM items WHERE slug = ?', [$outSlug]);
        if (!$outId) continue;   // output item missing (e.g. deleted in admin): skip quietly
        $ing = [];
        foreach (explode(',', $ingr) as $pair) {
            [$s, $n] = array_map('trim', explode(':', $pair) + [1 => 1]);
            if ($s !== '') $ing[$s] = max(1, (int)$n);
        }
        if ($slug === 'food-scrap-compost') $ing = ['food-scrap' => max(1, (int)setting('scrap_compost_cost'))];   // v0.9.4
        db_insert('recipes', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'output_item_id' => $outId,
            'output_qty' => max(1, (int)$outQty), 'ingredients' => json_encode($ing), 'energy' => energy_cost_scale(max(0, (int)$energy)),
            'cook_minutes' => 0]);
        $added++;
    }
    // Almanac pages, one per recipe (chapter "Recipes"), unlocked the first time you make it
    foreach (q('SELECT r.slug, r.name, r.category, r.ingredients, r.output_qty, i.name AS out_name, i.description
                FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.slug IS NOT NULL')->fetchAll() as $r) {
        $key = 'recipe:' . $r['slug'];
        if (q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', [$key])) continue;
        $cat = CRAFT_CATEGORIES[$r['category']] ?? CRAFT_CATEGORIES['cooking'];
        db_insert('encyclopedia_entries', ['chapter' => 'Recipes', 'category' => $r['category'] === 'pantry' ? 'Preserves' : $cat[0], 'title' => $r['name'],
            'body' => $r['description'] . "\n\n[b]Makes:[/b] " . (int)$r['output_qty'] . ' × ' . $r['out_name']
                . "\n[b]Needs:[/b] " . recipe_ingredient_text((string)$r['ingredients']),
            'unlock_key' => $key, 'hint' => 'Collect every ingredient, then make it.', 'sort_order' => 0]);
    }
    return $added;
}

function recipe_ingredient_text(string $json): string
{
    $parts = [];
    foreach (json_decode($json, true) ?: [] as $slug => $n) {
        $name = q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug;
        $parts[] = (int)$n . ' × ' . $name;
    }
    return implode(', ', $parts);
}

/** Item slugs this player has ever collected: crops grown, things gathered, or anything in the satchel now. */
function collected_slugs(int $uid): array
{
    $s = [];
    foreach (q('SELECT p.slug FROM user_plant_knowledge k JOIN plants p ON p.id = k.plant_id WHERE k.user_id = ? AND k.knowledge > 0', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $x) $s[$x] = true;
    foreach (q("SELECT SUBSTR(e.unlock_key, 8) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id
                WHERE ue.user_id = ? AND e.unlock_key LIKE 'gather:%'", [$uid])->fetchAll(PDO::FETCH_COLUMN) as $x) $s[$x] = true;
    foreach (q('SELECT i.slug FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $x) $s[$x] = true;
    // v1.1.0: items you have ever received that have an Almanac page (give_item opens "item:<slug>"), e.g. a Hen Egg from Biddy: eggs are never grown, and used-up eggs still count
    foreach (q("SELECT SUBSTR(e.unlock_key, 6) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id
                WHERE ue.user_id = ? AND e.unlock_key LIKE 'item:%'", [$uid])->fetchAll(PDO::FETCH_COLUMN) as $x) $s[$x] = true;
    return $s;
}

/** Which building (if any) the player has for each category: category => plot id (0 = none needed / missing). */
function craft_stations(int $uid): array
{
    $out = [];
    foreach (CRAFT_CATEGORIES as $cat => [, , $b]) {
        $out[$cat] = $b === null ? -1 : (int)q_val('SELECT gb.plot_id FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id
                     WHERE p.user_id = ? AND gb.building = ? ORDER BY gb.plot_id LIMIT 1', [$uid, $b]);
    }
    return $out;   // -1 = no building needed, 0 = missing, >0 = the garden that has it
}

/** All recipes with ingredient status. Newly discovered ones are saved to user_recipes. */
function craft_recipes(int $uid, ?string $category = null): array
{
    $have = [];
    foreach (q('SELECT i.slug, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ?', [$uid])->fetchAll() as $r) $have[$r['slug']] = (int)$r['qty'];
    $seen = collected_slugs($uid);
    $learned = array_fill_keys(q('SELECT recipe_id FROM user_recipes WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN), true);
    $names = [];
    $sql = 'SELECT r.*, i.name AS out_name, i.description, i.effects, i.category AS out_cat FROM recipes r JOIN items i ON i.id = r.output_item_id';
    $rows = $category ? q($sql . ' WHERE r.category = ? ORDER BY r.name', [$category])->fetchAll() : q($sql . ' ORDER BY r.name')->fetchAll();
    $out = [];
    foreach ($rows as $r) {
        $ings = [];
        $all = true;
        $can = true;
        foreach (json_decode((string)$r['ingredients'], true) ?: [] as $slug => $qty) {
            $names[$slug] ??= (string)(q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug);
            $h = $have[$slug] ?? 0;
            $all = $all && isset($seen[$slug]);
            $can = $can && $h >= $qty;
            $ings[] = ['slug' => $slug, 'name' => $names[$slug], 'qty' => (int)$qty, 'have' => $h, 'seen' => isset($seen[$slug])];
        }
        $known = isset($learned[$r['id']]);
        if (!$known && $all && $ings) {
            try {
                db_insert('user_recipes', ['user_id' => $uid, 'recipe_id' => $r['id'], 'learned_at' => now()]);
            } catch (PDOException $e) {
                // two tabs at once: already saved
            }
            $known = true;
            $r['new'] = true;
        }
        $out[] = $r + ['ings' => $ings, 'known' => $known, 'can' => $can && $ings];
    }
    return $out;
}

/**
 * v0.7.88: the stock a recipe's ingredients need, read fresh for one gnome:
 * [slug => ['id', 'name', 'qty' (per make), 'have']]. Ingredients the gnome has never seen have have = 0.
 */
function craft_stock(int $uid, string $json): array
{
    $need = json_decode($json, true) ?: [];
    if (!$need) return [];
    $slugs = array_map('strval', array_keys($need));
    $in = implode(',', array_fill(0, count($slugs), '?'));
    $by = [];
    foreach (q("SELECT i.id, i.slug, i.name, COALESCE(ui.qty, 0) AS have FROM items i
                LEFT JOIN user_items ui ON ui.item_id = i.id AND ui.user_id = ?
                WHERE i.slug IN ($in)", array_merge([$uid], $slugs))->fetchAll() as $row) {
        $by[(string)$row['slug']] = $row;
    }
    $stock = [];
    foreach ($need as $slug => $qty) {
        $row = $by[(string)$slug] ?? null;
        $stock[(string)$slug] = ['id' => (int)($row['id'] ?? 0), 'name' => (string)($row['name'] ?? $slug),
            'qty' => max(1, (int)$qty), 'have' => (int)($row['have'] ?? 0)];
    }
    return $stock;
}

/** v0.9.1: the energy one make costs this gnome. Used by craft(), craft_fit and the card. v0.9.4: by dish tier (setting cook_energy_tiers); Brewroot no longer cooks free. */
function craft_energy_cost(array $u, string $cat, int $energy, string $tier = ''): int
{
    if ($cat === 'cooking' && $tier !== '') {   // v0.9.4: cooking energy by tier: snack 0, meal 1, feast 2 (setting cook_energy_tiers)
        require_once __DIR__ . '/catalog.php';
        $energy = tier_setting('cook_energy_tiers', [0, 1, 2])[$tier] ?? $energy;
    }
    return $energy;
}

/** v0.7.88: how many makes the stock and the energy allow: the smallest of stock ÷ need and energy ÷ cost (0 = no limit on energy). */
function craft_fit(array $stock, int $energyCost, int $energy): int
{
    if (!$stock) return 0;
    $fit = PHP_INT_MAX;
    foreach ($stock as $s) $fit = min($fit, intdiv((int)$s['have'], max(1, (int)$s['qty'])));
    if ($energyCost > 0) $fit = min($fit, intdiv(max(0, $energy), $energyCost));
    return $fit === PHP_INT_MAX ? 0 : max(0, $fit);
}

/** v0.7.88: what stops $qty makes, in words ('' when nothing does). */
function craft_short_text(array $stock, int $energyCost, int $energy, int $qty): string
{
    $bits = [];
    foreach ($stock as $s) {
        $more = $s['qty'] * $qty - $s['have'];
        if ($more > 0) $bits[] = $more . ' more ' . $s['name'];
    }
    if ($bits) return 'You’re missing ' . implode(', ', $bits) . '.';
    if ($energyCost > 0 && $energy < $energyCost * $qty) {
        return 'You’re too tired. This takes ⚡' . ($energyCost * $qty) . ', you have ⚡' . $energy . '.';
    }
    return '';
}

/**
 * Make a recipe: once, or several times. $want is a number, or 'all' for as many as the stock and energy allow.
 * v0.7.88: the whole batch is one transaction. Ingredients and energy are taken with conditional UPDATEs; if anything
 * runs short, everything is rolled back and the message says what is missing.
 * v0.9.4: cooking goes to cook_start() (a pot with a timer) and is collected later; with kitchen_pots = 0 it is collected at once.
 * Tools, garden supplies and the rest stay instant. Returns [ok, message].
 */
function craft(array &$u, int $recipeId, int|string $want = 1): array
{
    $uid = (int)$u['id'];
    $r = q_one('SELECT * FROM recipes WHERE id = ?', [$recipeId]);
    if (!$r || !q_val('SELECT 1 FROM user_recipes WHERE user_id = ? AND recipe_id = ?', [$uid, $recipeId])) {
        return [false, 'You don’t know that recipe yet.'];
    }
    $cat = isset(CRAFT_CATEGORIES[$r['category']]) ? $r['category'] : 'cooking';
    $station = craft_stations($uid)[$cat];
    if ($station === 0) {
        $b = BUILDINGS[CRAFT_CATEGORIES[$cat][2]];
        return [false, 'You need a ' . $b[0] . ' in one of your gardens for that (garden level ' . $b[2] . ').'];
    }
    require_once __DIR__ . '/gardens.php';
    if (str_starts_with((string)$r['slug'], 'feast-') && !user_building_bonus($uid, 'kitchen')['feasts']) {   // v0.7.96: feasts need a level 3 Kitchen
        return [false, 'Feasts need a level 3 Kitchen (🍳 Kitchen III). Upgrade one in 🏠 Garden buildings.'];
    }
    if ($cat === 'pantry') return pantry_start($u, $r, $want);   // v0.9.8: jars with real-day timers (collected later, like pots)
    if ($cat === 'cooking') {
        [$ok, $msg, $info] = cook_start($u, $r, $want, (int)$station);
        if (!$ok || cook_pots_on()) return [$ok, $msg];
        // kitchen_pots = 0: no waiting, the dishes come out at once
        $done = [];
        foreach ($info['ids'] as $potId) {
            $res = cook_collect_one($u, $potId);
            if ($res[0]) $done[] = $res[2];
        }
        $cost = ($info['cost'] ? '−' . $info['cost'] . ' ⚡' : '') . ($info['fee'] ? ($info['cost'] ? ', ' : '') . '−' . money($info['fee']) : '');
        return [true, cook_collect_msg($done, 'Made', $cost) . ($info['clamped'] ? ' Only ' . $info['qty'] . ' fit your stock, energy and pots.' : '')];
    }
    $energy = craft_energy_cost($u, $cat, (int)$r['energy']);
    $stock = craft_stock($uid, (string)$r['ingredients']);
    $now = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
    $fit = craft_fit($stock, $energy, $now);
    if ($fit < 1) return [false, craft_short_text($stock, $energy, $now, 1) ?: 'You’re missing some ingredients.'];
    $qty = $want === 'all' ? $fit : min($fit, max(1, (int)$want));
    $clamped = $want !== 'all' && (int)$want > $fit;
    $cost = $energy * $qty;
    // After a rollback: say what is missing now, so the gnome knows what to gather
    $short = function () use ($uid, $r, $energy, $qty): string {
        $stock = craft_stock($uid, (string)$r['ingredients']);
        $now = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
        return (craft_short_text($stock, $energy, $now, $qty) ?: 'Something changed while you were making it.') . ' Nothing was used.';
    };
    db()->beginTransaction();
    if ($energy > 0 && !spend_energy($uid, $cost)) {
        db()->rollBack();
        return [false, $short()];
    }
    foreach ($stock as $s) {
        if ($s['id'] < 1 || !give_item($uid, $s['id'], -($s['qty'] * $qty))) {
            db()->rollBack();
            return [false, $short()];
        }
    }
    $made = (int)$r['output_qty'] * $qty;
    give_item($uid, (int)$r['output_item_id'], $made);
    q('UPDATE user_recipes SET made = made + ? WHERE user_id = ? AND recipe_id = ?', [$qty, $uid, $recipeId]);
    require_once __DIR__ . '/jobs.php';
    job_event($uid, 'craft', (string)$r['slug'], $qty, ['cat' => $cat]);   // v0.9.4 N10: craft carries recipe slug + category (cooking's cook event fires at pot collect)
    $xp = ($cat === 'tools' ? 15 : 5) * $qty;
    [$xp] = add_action_xp($uid, $xp, 'Crafting', (int)$u['level']);   // v0.9.7: action XP grows with the gnome's level
    if ($station > 0) add_garden_xp($station, 3 * $qty);
    $page = unlock_entries($uid, 'recipe:' . $r['slug']);
    db()->commit();
    $out = q_val('SELECT name FROM items WHERE id = ?', [$r['output_item_id']]);
    $msg = 'Made ' . $made . ' × ' . $out . ' (' . ($energy ? '−' . $cost . ' ⚡, ' : '') . '+' . $xp . ' XP).';
    if ($clamped) $msg .= ' Only ' . $qty . ' fit your stock and energy.';
    return [true, $msg . ($page ? ' 📖 New Almanac page!' : '')];
}

// ---------- v0.9.4 cooking part 2: pots and timers ----------

/** Pots are on unless the setting kitchen_pots is 0 (then cooking is instant, as before 0.9.4). */
function cook_pots_on(): bool
{
    return trim((string)setting('kitchen_pots')) !== '0';
}

/** How many pots this gnome has: by the best Kitchen level (kitchen_pots, "2,3,4"), +1 for a Brewroot master. 0 without a Kitchen. */
function cook_pot_limit(array $u): int
{
    require_once __DIR__ . '/gardens.php';
    $kb = user_building_bonus((int)$u['id'], 'kitchen');   // v0.9.5: best kitchen, plus 1 per extra Kitchen III (max 2)
    $kl = $kb['best'];
    if ($kl < 1) return 0;
    $v = array_values(array_filter(array_map('trim', explode(',', (string)setting('kitchen_pots'))), fn($x) => $x !== ''));
    $v = $v ? array_map('intval', $v) : [2, 3, 4];
    return max(1, $v[min($kl, count($v)) - 1]) + $kb['pots'] + max(0, calling_perk($u, 'extra_pot'));
}

/** Pots in use: cooking, or done and waiting to be collected. */
function cook_pots_busy(int $uid): int
{
    return (int)q_val('SELECT COUNT(*) FROM cook_pots WHERE user_id = ? AND collected_at IS NULL', [$uid]);
}

/** Pots whose timer has run out and that are still waiting to be collected (the nav badge). */
function cook_ready_count(int $uid): int
{
    return (int)q_val('SELECT COUNT(*) FROM cook_pots WHERE user_id = ? AND collected_at IS NULL AND ready_at <= ?', [$uid, now()]);
}

/** Pots in use, oldest first, with the dish name and seconds left (0 = ready). */
function cook_pots_list(int $uid): array
{
    $rows = q('SELECT p.id, p.makes, p.dishes, p.ready_at, i.name, i.id AS item_id FROM cook_pots p
               LEFT JOIN recipes r ON r.id = p.recipe_id LEFT JOIN items i ON i.id = r.output_item_id
               WHERE p.user_id = ? AND p.collected_at IS NULL ORDER BY p.id', [$uid])->fetchAll();
    foreach ($rows as &$r) {
        $r['left'] = max(0, (int)strtotime($r['ready_at'] . ' UTC') - time());
        $r['name'] = (string)($r['name'] ?? 'Dish');
    }
    return $rows;
}

/** Seconds one pot of this recipe takes this gnome: the recipe's minutes (else the tier's), less Brewroot III's cook_time_pct. */
function cook_seconds(array $u, array $r): int
{
    require_once __DIR__ . '/catalog.php';
    $min = (int)$r['cook_minutes'];
    if ($min <= 0) $min = tier_setting('cook_minutes_tiers', [3, 15, 45])[(string)($r['tier'] ?: 'meal')] ?? 0;
    $pct = min(100, max(0, calling_perk($u, 'cook_time_pct')));
    return (int)round($min * 60 * (100 - $pct) / 100);
}

/** "8 minutes", "45 seconds". */
function cook_time_text(int $secs): string
{
    if ($secs < 60) return $secs . ' second' . ($secs === 1 ? '' : 's');
    $m = (int)round($secs / 60);
    return $m >= 120 ? nice_minutes($m) : $m . ' minute' . ($m === 1 ? '' : 's');
}

/**
 * v0.9.4: start cooking: checks the recipe, a free pot, ingredients, energy and the feast fee, then in one transaction takes them and puts
 * the dish(es) in pots with a timer. A pot holds up to batch_max makes (snacks 5); more makes fill more pots. The Brewroot extra-dish roll
 * is made here, once per pot, and stored in cook_pots.dishes. Returns [ok, message, info]; info: ids (new pot ids), qty, cost (energy),
 * fee (Petals), clamped.
 */
function cook_start(array $u, array $r, int|string $want, int $station): array
{
    $uid = (int)$u['id'];
    $tier = (string)($r['tier'] ?: 'meal');
    $pots = cook_pots_on();
    $chunk = max(1, (int)$r['batch_max']);
    $free = $pots ? cook_pot_limit($u) - cook_pots_busy($uid) : 0;
    $none = ['ids' => [], 'qty' => 0, 'cost' => 0, 'fee' => 0, 'clamped' => false];
    if ($pots && $free < 1) return [false, 'All your pots are busy. Collect a finished one, or wait for a timer.', $none];
    $energy = craft_energy_cost($u, 'cooking', (int)$r['energy'], $tier);
    $feeEach = $tier === 'feast' ? max(0, (int)setting('feast_petal_fee')) : 0;
    $stock = craft_stock($uid, (string)$r['ingredients']);
    $haveE = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
    $coins = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
    $fit = craft_fit($stock, $energy, $haveE);
    if ($feeEach > 0) $fit = min($fit, intdiv($coins, $feeEach));
    if ($pots) $fit = min($fit, $free * $chunk);
    $feeText = 'The firewood and spices for a feast cost ' . money($feeEach) . ' (you have ' . money($coins) . ').';
    if ($fit < 1) return [false, craft_short_text($stock, $energy, $haveE, 1) ?: ($feeEach > 0 && $coins < $feeEach ? $feeText : 'You’re missing some ingredients.'), $none];
    $qty = $want === 'all' ? $fit : min($fit, max(1, (int)$want));
    $clamped = $want !== 'all' && (int)$want > $fit;
    $cost = $energy * $qty;
    $fee = $feeEach * $qty;
    $short = function () use ($uid, $r, $energy, $qty, $feeEach, $feeText): string {
        $stock = craft_stock($uid, (string)$r['ingredients']);
        $haveE = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
        return (craft_short_text($stock, $energy, $haveE, $qty) ?: ($feeEach > 0 ? $feeText : 'Something changed while you were cooking.')) . ' Nothing was used.';
    };
    require_once __DIR__ . '/gourmand.php';
    $score = gourmand_dish_score($u, $stock);   // next version: the dish's quality, read before the ingredients leave the satchel
    db()->beginTransaction();
    if ($energy > 0 && !spend_energy($uid, $cost)) {
        db()->rollBack();
        return [false, $short(), $none];
    }
    if ($fee > 0 && !take_petals((int)$uid, (int)$fee)) {
        db()->rollBack();
        return [false, $short(), $none];
    }
    foreach ($stock as $s) {
        if ($s['id'] < 1 || !give_item($uid, $s['id'], -($s['qty'] * $qty))) {
            db()->rollBack();
            return [false, $short(), $none];
        }
    }
    $secs = $pots ? cook_seconds($u, $r) : 0;   // pots off: ready at once
    $luck = calling_perk($u, 'extra_dish_pct');
    $ids = [];
    $extra = 0;
    for ($left = $qty; $left > 0; $left -= $chunk) {
        $makes = min($chunk, $left);
        $dishes = (int)$r['output_qty'] * $makes;
        if ($luck > 0 && random_int(1, 100) <= $luck) {   // v0.9.1/0.9.4: one roll per pot; a hit is +1 dish per make in that pot
            $dishes += $makes;
            $extra += $makes;
        }
        $ids[] = db_insert('cook_pots', ['user_id' => $uid, 'recipe_id' => (int)$r['id'], 'makes' => $makes, 'dishes' => $dishes,
            'started_at' => now(), 'ready_at' => gmdate('Y-m-d H:i:s', time() + $secs), 'score' => $score]);
    }
    db()->commit();
    $info = ['ids' => $ids, 'qty' => $qty, 'cost' => $cost, 'fee' => $fee, 'clamped' => $clamped];
    $name = (string)q_val('SELECT name FROM items WHERE id = ?', [$r['output_item_id']]);
    $spent = ($cost ? '−' . $cost . ' ⚡' : '') . ($fee ? ($cost ? ', ' : '') . '−' . money($fee) : '');
    $msg = '🍳 Cooking ' . $qty . ' × ' . $name . ($pots ? ' in ' . count($ids) . ' pot' . (count($ids) === 1 ? '' : 's') : '') . ($spent ? ' (' . $spent . ')' : '')
        . '. ' . ($secs > 0 ? 'Ready in ' . cook_time_text($secs) . ': come back and collect.' : 'Ready now.');
    if ($clamped) $msg .= ' Only ' . $qty . ' fit your stock, energy and free pots.';
    return [true, $msg, $info];
}

/**
 * Collect one finished pot: dishes, XP (cook_xp_tiers per pot, x1.5 in a Kitchen III), garden XP, the last-cooked dish, the Almanac
 * recipe page, Food Scraps (1 per cook_scraps_per ingredient items) and one 'cook' job event per pot. Returns [ok, message, info];
 * info: name, dishes, xp, scraps, extra, page.
 */
function cook_collect_one(array $u, int $potId): array
{
    $uid = (int)$u['id'];
    $pot = q_one('SELECT * FROM cook_pots WHERE id = ? AND user_id = ? AND collected_at IS NULL', [$potId, $uid]);
    if (!$pot) return [false, 'That pot is already empty.', []];
    if ($pot['ready_at'] > now()) return [false, 'That pot isn’t ready yet.', []];
    $r = q_one('SELECT r.*, i.name AS out_name FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.id = ?', [$pot['recipe_id']]);
    db()->beginTransaction();
    if (q('UPDATE cook_pots SET collected_at = ? WHERE id = ? AND user_id = ? AND collected_at IS NULL', [now(), $potId, $uid])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That pot is already empty.', []];   // two tabs at once
    }
    if (!$r) {   // the recipe was deleted in the admin while it cooked
        db()->commit();
        return [false, 'That pot was empty: the recipe is gone.', []];
    }
    require_once __DIR__ . '/gardens.php';
    require_once __DIR__ . '/catalog.php';
    $makes = max(1, (int)$pot['makes']);
    $dishes = max(1, (int)$pot['dishes']);
    $tier = (string)($r['tier'] ?: 'meal');
    give_item($uid, (int)$r['output_item_id'], $dishes);
    if ((int)$pot['score'] > 0) market_note_quality($uid, (int)$r['output_item_id'], $dishes, (int)$pot['score']);   // next version: the dish keeps its score as quality (0 = a pot started before this existed)
    q('UPDATE user_recipes SET made = made + ? WHERE user_id = ? AND recipe_id = ?', [$makes, $uid, (int)$r['id']]);
    $xp = max(0, tier_setting('cook_xp_tiers', [1, 5, 15])[$tier] ?? 5);
    if (($xpPct = user_building_bonus($uid, 'kitchen')['xp_pct']) > 0) $xp = (int)round($xp * (100 + $xpPct) / 100);   // v0.7.96: level 3 kitchen +50%; v0.9.5: other gardens' kitchens add a little
    if ($xp > 0) [$xp] = add_action_xp($uid, $xp, 'Cooking', (int)$u['level']);   // v0.9.7: action XP grows with the gnome's level
    $station = craft_stations($uid)['cooking'];
    if ($station > 0) add_garden_xp($station, 3 * $makes);
    q('UPDATE users SET last_cooked_id = ? WHERE id = ?', [(int)$r['output_item_id'], $uid]);
    $items = 0;
    foreach (json_decode((string)$r['ingredients'], true) ?: [] as $n) $items += (int)$n;
    $scraps = intdiv($items * $makes, max(1, (int)setting('cook_scraps_per')));
    if ($scraps > 0 && ($scrapId = (int)q_val("SELECT id FROM items WHERE slug = 'food-scrap'"))) give_item($uid, $scrapId, $scraps); else $scraps = 0;
    $page = unlock_entries($uid, 'recipe:' . $r['slug']) > 0;
    db()->commit();
    require_once __DIR__ . '/jobs.php';
    job_event($uid, 'cook', (string)$r['slug'], $makes, ['tier' => $tier]);   // v0.9.4: once per pot; the calling questline and the Job Board read it
    $extra = $dishes - (int)$r['output_qty'] * $makes;
    $info = ['name' => (string)$r['out_name'], 'dishes' => $dishes, 'xp' => $xp, 'scraps' => $scraps, 'extra' => max(0, $extra), 'page' => $page];
    return [true, cook_collect_msg([$info], 'Collected'), $info];
}

/** Collect every finished pot. Returns [ok, message]. */
function cook_collect_all(array $u): array
{
    $done = [];
    foreach (cook_pots_list((int)$u['id']) as $p) {
        if ($p['left'] > 0) continue;
        $res = cook_collect_one($u, (int)$p['id']);
        if ($res[0]) $done[] = $res[2];
    }
    return $done ? [true, cook_collect_msg($done, 'Collected')] : [false, 'No pot is ready yet.'];
}

/** One message for any number of collected pots: "Collected 3 × Mint Tea, 1 × Soup (+6 XP, ♻️ +2 Food Scraps)." $spent (instant cooking) goes first inside the brackets. */
function cook_collect_msg(array $infos, string $verb, string $spent = ''): string
{
    $dishes = [];
    $xp = $scraps = $extra = 0;
    $page = false;
    foreach ($infos as $i) {
        $dishes[$i['name']] = ($dishes[$i['name']] ?? 0) + $i['dishes'];
        $xp += $i['xp'];
        $scraps += $i['scraps'];
        $extra += $i['extra'];
        $page = $page || $i['page'];
    }
    $parts = array_map(fn($n, $c) => $c . ' × ' . $n, array_keys($dishes), $dishes);
    $bits = array_filter([$spent, '+' . $xp . ' XP', $scraps ? '♻️ +' . $scraps . ' Food Scrap' . ($scraps === 1 ? '' : 's') : '']);
    return $verb . ' ' . implode(', ', $parts) . ' (' . implode(', ', $bits) . ').'
        . ($extra ? ' 🍳 Brewroot luck: ' . $extra . ' extra!' : '') . ($page ? ' 📖 New Almanac page!' : '');
}

/** Short text for a food's energy and buff: "⚡+4 (🛡️ Hardiness +3 for 6 h)". v0.9.1a: buff in brackets, time adjusted for $u when given. */
function buff_text(?string $effects, ?array $u = null, bool $homeCooked = false): string
{
    $fx = json_decode((string)$effects, true) ?: [];
    $parts = [];
    foreach ($fx['temp'] ?? [] as $k => $v) {
        if (isset(GNOME_STATS[$k])) $parts[] = GNOME_STATS[$k][1] . ' ' . GNOME_STATS[$k][0] . ' +' . $v;
    }
    $t = implode(', ', $parts);
    if ($t !== '' && isset($fx['temp']['minutes'])) {
        $m = (int)$fx['temp']['minutes'];
        $t .= ' for ' . nice_minutes($u ? buff_minutes($u, $m) : $m);
    }
    if ($t !== '') $t = '(' . $t . ')';
    if (!empty($fx['energy'])) $t = '⚡+' . ($homeCooked ? dish_energy((int)$fx['energy']) : (int)$fx['energy']) . ($t !== '' ? ' ' . $t : '');   // v0.9.4: dishes show what you get at cook_energy_percent
    return $t;
}
