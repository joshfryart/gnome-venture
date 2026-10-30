<?php
declare(strict_types=1);
/**
 * v0.9.8 part A: the Pantry. A Kitchen add-on (garden_buildings.pantry = 1 on the Kitchen's row, not a new building) with jars that
 * preserve crops over real days: jam 1 day, chutney 2, pickles 3, kimchi 5, sauerkraut 7, cordials 14. Modelled on cook pots
 * (cook_pots -> pantry_jars) and just as lazy: no cron, a jar is ready when ready_at has passed and its Collect is pressed.
 * Recipes live in recipes.txt (tier "preserve", recipes.category "pantry"). One jar holds ONE batch; a batch gives output_qty
 * items (3 or 4 jars of jam). Preserves never spoil, sell for more than their crops, are liked by every townsfolk, and the
 * best of the month can go in the Harvest Fair's Preserves class.
 */
require_once __DIR__ . '/gardens.php';

/** "slug:qty,slug:qty" -> [slug => qty] */
function pantry_parse_mats(string $s): array
{
    $mats = [];
    foreach (explode(',', $s) as $pair) {
        [$slug, $n] = array_map('trim', explode(':', $pair) + [1 => 0]);
        if ($slug !== '' && (int)$n > 0) $mats[$slug] = (int)$n;
    }
    return $mats;
}

/** What the add-on costs: [petals, [slug => qty]] */
function pantry_cost(): array
{
    return [max(0, (int)setting('pantry_cost')), pantry_parse_mats((string)setting('pantry_materials'))];
}

/** Jars this gnome has in total: 0 without a Pantry. Stacked in user_building_bonus('kitchen')['jars'] (gardens.php). */
function pantry_jar_limit(int $uid): int
{
    return (int)user_building_bonus($uid, 'kitchen')['jars'];
}

/** Jars in use: preserving, or done and waiting to be collected. */
function pantry_busy(int $uid): int
{
    return (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL', [$uid]);
}

/** Jars whose timer has run out and that are waiting to be collected (the nav badge). */
function pantry_ready_count(int $uid): int
{
    return (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL AND ready_at <= ?', [$uid, now()]);
}

/** Jars in use, soonest first, with the preserve's name and seconds left (0 = ready). */
function pantry_jars_list(int $uid): array
{
    $rows = q('SELECT j.id, j.qty, j.score, j.ready_at, i.name, i.id AS item_id FROM pantry_jars j
               LEFT JOIN recipes r ON r.id = j.recipe_id LEFT JOIN items i ON i.id = r.output_item_id
               WHERE j.user_id = ? AND j.collected_at IS NULL ORDER BY j.ready_at, j.id', [$uid])->fetchAll();
    foreach ($rows as &$r) {
        $r['left'] = max(0, (int)strtotime($r['ready_at'] . ' UTC') - time());
        $r['name'] = (string)($r['name'] ?? 'Preserve');
    }
    return $rows;
}

/** Seconds one batch of this recipe takes (its cook_minutes; the Brewroot cook-time perk does not apply to real-day timers). */
function pantry_seconds(array $r): int
{
    return max(0, (int)$r['cook_minutes']) * 60;
}

/** "1 day", "3 days", "14 days", or hours/minutes for anything shorter. */
function pantry_time_text(int $secs): string
{
    if ($secs >= 86400) {
        $d = round($secs / 86400, 1);
        return (floor($d) == $d ? (int)$d : $d) . ' day' . ($d == 1 ? '' : 's');
    }
    if ($secs >= 3600) return round($secs / 3600) . ' h';
    return max(1, (int)round($secs / 60)) . ' min';
}

/** Add the Pantry to the Kitchen in this garden. Petals + materials, taken in one transaction. */
function pantry_buy(array $u, int $plotId): array
{
    $uid = (int)$u['id'];
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]);
    if (!$plot) return [false, 'That isn’t your garden.'];
    $row = q_one("SELECT * FROM garden_buildings WHERE plot_id = ? AND building = 'kitchen'", [$plotId]);
    if (!$row) return [false, 'A Pantry is an add-on for a Kitchen. Build a Kitchen in this garden first.'];
    if ((int)$row['pantry'] === 1) return [false, 'This Kitchen already has a Pantry.'];
    [$coins, $mats] = pantry_cost();
    db()->beginTransaction();
    if (q('UPDATE garden_buildings SET pantry = 1 WHERE id = ? AND pantry = 0', [$row['id']])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'This Kitchen already has a Pantry.'];
    }
    if ($coins > 0 && !take_petals((int)$uid, (int)$coins)) {
        db()->rollBack();
        return [false, 'A Pantry costs ' . money($coins) . ($mats ? ' and ' . upgrade_mats_text($mats) : '') . '.'];
    }
    foreach ($mats as $slug => $qty) {
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if (!$id || !give_item($uid, $id, -$qty)) {
            db()->rollBack();
            return [false, 'You need ' . upgrade_mats_text($mats) . ' for a Pantry (Satchel → Crafting → Building makes Timber Planks).'];
        }
    }
    $page = unlock_entries($uid, 'pantry');
    db()->commit();
    return [true, '🫙 You fit a Pantry to your Kitchen: ' . pantry_jar_limit($uid) . ' jars for jam, pickles and cordials. Find it in Satchel → Crafting → Pantry.' . ($page ? ' 📖 New Almanac page!' : '')];
}

/**
 * The quality of one batch, 0-100, judged at the Harvest Fair's Preserves class: longer ferments, a better Kitchen, more kinds of
 * ingredient and a little Luck score higher; a few points of wobble. Rolled when the jar is started and kept on its row.
 */
function pantry_quality(array $u, array $r): int
{
    $days = max(1, (int)round((int)$r['cook_minutes'] / 1440));
    $kl = user_building_bonus((int)$u['id'], 'kitchen')['best'];
    $kinds = count(json_decode((string)$r['ingredients'], true) ?: []);
    $luck = function_exists('eff_mod') ? min(4, max(0, eff_mod($u, 'luck'))) : 0;
    return (int)max(0, min(100, 38 + min(20, $days * 2) + 3 * $kl + 3 * min(4, $kinds) + $luck + random_int(-3, 3)));
}

/**
 * Start preserving: checks the Pantry, a free jar, ingredients and energy, then in one transaction takes them and fills one jar per
 * batch. $want is a number or 'all'. Returns [ok, message].
 */
function pantry_start(array $u, array $r, int|string $want): array
{
    $uid = (int)$u['id'];
    $limit = pantry_jar_limit($uid);
    if ($limit < 1) return [false, 'You need a 🫙 Pantry on a Kitchen first (🏠 Garden buildings → Kitchen).'];
    $free = $limit - pantry_busy($uid);
    if ($free < 1) return [false, 'All your jars are full. Collect a finished one, or wait for a timer.'];
    $energy = max(0, (int)$r['energy']);
    $stock = craft_stock($uid, (string)$r['ingredients']);
    $haveE = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
    $fit = min(craft_fit($stock, $energy, $haveE), $free);
    if ($fit < 1) return [false, craft_short_text($stock, $energy, $haveE, 1) ?: 'You’re missing some ingredients.'];
    $qty = $want === 'all' ? $fit : min($fit, max(1, (int)$want));
    $clamped = $want !== 'all' && (int)$want > $fit;
    $cost = $energy * $qty;
    $short = function () use ($uid, $energy, $qty, $r): string {
        $stock = craft_stock($uid, (string)$r['ingredients']);
        $haveE = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
        return (craft_short_text($stock, $energy, $haveE, $qty) ?: 'Something changed while you were preserving.') . ' Nothing was used.';
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
    $secs = pantry_seconds($r);
    for ($i = 0; $i < $qty; $i++) {
        db_insert('pantry_jars', ['user_id' => $uid, 'recipe_id' => (int)$r['id'], 'makes' => 1, 'qty' => max(1, (int)$r['output_qty']),
            'score' => pantry_quality($u, $r), 'started_at' => now(), 'ready_at' => gmdate('Y-m-d H:i:s', time() + $secs)]);
    }
    db()->commit();
    $name = (string)q_val('SELECT name FROM items WHERE id = ?', [$r['output_item_id']]);
    $msg = '🫙 Preserving ' . $qty . ' batch' . ($qty === 1 ? '' : 'es') . ' of ' . $name . ' (' . ($cost ? '−' . $cost . ' ⚡, ' : '') . $qty . ' jar' . ($qty === 1 ? '' : 's')
        . '). Ready in ' . pantry_time_text($secs) . ': come back and collect.';
    if ($clamped) $msg .= ' Only ' . $qty . ' fit your stock, energy and free jars.';
    return [true, $msg];
}

/**
 * Collect one finished jar: the preserves, cooking XP (2 + a point per day, at most 15, with the Kitchen's XP bonus), a little garden
 * XP, Food Scraps, the Almanac recipe page, an entry in this month's Harvest Fair Preserves class, and one 'cook' job event with
 * tier "preserve" (the Job Board and calling questlines count meal and feast only, so it counts as a craft and nothing more).
 * Returns [ok, message, info]; info: name, dishes, xp, scraps, page.
 */
function pantry_collect_one(array $u, int $jarId): array
{
    $uid = (int)$u['id'];
    $jar = q_one('SELECT * FROM pantry_jars WHERE id = ? AND user_id = ? AND collected_at IS NULL', [$jarId, $uid]);
    if (!$jar) return [false, 'That jar is already empty.', []];
    if ($jar['ready_at'] > now()) return [false, 'That jar isn’t ready yet.', []];
    $r = q_one('SELECT r.*, i.name AS out_name FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.id = ?', [$jar['recipe_id']]);
    db()->beginTransaction();
    if (q('UPDATE pantry_jars SET collected_at = ? WHERE id = ? AND user_id = ? AND collected_at IS NULL', [now(), $jarId, $uid])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That jar is already empty.', []];   // two tabs at once
    }
    if (!$r) {   // the recipe was deleted in the admin while it sat
        db()->commit();
        return [false, 'That jar was empty: the recipe is gone.', []];
    }
    require_once __DIR__ . '/catalog.php';
    $dishes = max(1, (int)$jar['qty']);
    give_item($uid, (int)$r['output_item_id'], $dishes);
    market_note_quality($uid, (int)$r['output_item_id'], $dishes, (int)$jar['score']);   // v1.0.0 wave 2b: the jar's score is the preserve's quality
    q('UPDATE user_recipes SET made = made + 1 WHERE user_id = ? AND recipe_id = ?', [$uid, (int)$r['id']]);
    $days = max(1, (int)round((int)$r['cook_minutes'] / 1440));
    $xp = min(15, 2 + $days);
    if (($xpPct = user_building_bonus($uid, 'kitchen')['xp_pct']) > 0) $xp = (int)round($xp * (100 + $xpPct) / 100);
    [$xp] = add_action_xp($uid, $xp, 'Cooking', (int)$u['level']);
    $station = craft_stations($uid)['pantry'];
    if ($station > 0) add_garden_xp($station, 3);
    $items = 0;
    foreach (json_decode((string)$r['ingredients'], true) ?: [] as $n) $items += (int)$n;
    $scraps = intdiv($items, max(1, (int)setting('cook_scraps_per')));
    if ($scraps > 0 && ($scrapId = (int)q_val("SELECT id FROM items WHERE slug = 'food-scrap'"))) give_item($uid, $scrapId, $scraps); else $scraps = 0;
    $page = unlock_entries($uid, 'recipe:' . $r['slug']) > 0;
    db()->commit();
    require_once __DIR__ . '/jobs.php';
    require_once __DIR__ . '/fair.php';
    fair_keep_best($uid, 'preserve', 0, (int)$jar['score'], (string)$r['out_name']);
    job_event($uid, 'cook', (string)$r['slug'], 1, ['tier' => 'preserve']);
    $info = ['name' => (string)$r['out_name'], 'dishes' => $dishes, 'xp' => $xp, 'scraps' => $scraps, 'page' => $page, 'score' => (int)$jar['score']];
    return [true, pantry_collect_msg([$info]), $info];
}

/** Collect every finished jar. Returns [ok, message]. */
function pantry_collect_all(array $u): array
{
    $done = [];
    foreach (pantry_jars_list((int)$u['id']) as $j) {
        if ($j['left'] > 0) continue;
        $res = pantry_collect_one($u, (int)$j['id']);
        if ($res[0]) $done[] = $res[2];
    }
    return $done ? [true, pantry_collect_msg($done)] : [false, 'No jar is ready yet.'];
}

/** "Collected 4 × Strawberry Jam, 3 × Dill Pickles (+8 XP, ♻️ +2 Food Scraps)." */
function pantry_collect_msg(array $infos): string
{
    $by = [];
    $xp = $scraps = 0;
    $page = false;
    foreach ($infos as $i) {
        $by[$i['name']] = ($by[$i['name']] ?? 0) + $i['dishes'];
        $xp += $i['xp'];
        $scraps += $i['scraps'];
        $page = $page || $i['page'];
    }
    $parts = array_map(fn($n, $c) => $c . ' × ' . $n, array_keys($by), $by);
    $bits = array_filter(['+' . $xp . ' XP', $scraps ? '♻️ +' . $scraps . ' Food Scrap' . ($scraps === 1 ? '' : 's') : '']);
    return '🫙 Collected ' . implode(', ', $parts) . ' (' . implode(', ', $bits) . ').' . ($page ? ' 📖 New Almanac page!' : '');
}

/**
 * v0.9.8 part A upgrade. The table (pantry_jars) and columns (garden_buildings.pantry, fair_best/fair_entries.label) come from
 * schema.php (db_migrate). This adds the preserve items and recipes (and their Almanac recipe pages) from recipes.txt and the
 * Pantry / Preserves how-to pages. Idempotent: nothing that exists is changed. Returns how many recipes were added.
 */
function upgrade_098_pantry(): int
{
    require_once __DIR__ . '/crafting.php';
    require_once __DIR__ . '/almanac_notes.php';
    $n = ensure_crafts();
    ensure_almanac_howto(false);
    return $n;
}

/**
 * Re-price the preserves that were priced from a stale rarity cache. Until 2.2.x import_recipes() priced a jar from sell_price(),
 * whose per-request item_lookups() cache was built before the hybrid plants and the fiddleheads gatherable existed, so those crops
 * read as Legendary (x2.5 at the shop) and six jars (jostaberry-jam, pluot-jam, nectaplum-jam, meyer-lemon-marmalade,
 * tangelo-marmalade, pickled-fiddleheads) were stored about 2.6x too high. This sets those, and only those, to what a fresh install
 * now prices them at. A jar is touched only when ALL of these hold: it is a pantry preserve; one of its crops reads Legendary
 * from the raw items.rarity but is not Legendary in the regions or gathering tables; and its stored price is still more than
 * 1.8x the correct one (so a price an admin set near or below the right number is never changed). Runs once (flag
 * upg_pantry_reprice), safe to run again. Returns how many items changed.
 */
function pantry_reprice_run(): int
{
    if (setting('upg_pantry_reprice') === '1') return 0;
    if (!q_val("SELECT 1 FROM recipes WHERE category = 'pantry' AND tier = 'preserve' LIMIT 1")) return 0;   // nothing imported yet: import prices it right
    require_once __DIR__ . '/upgrade100.php';
    require_once __DIR__ . '/catalog.php';
    require_once __DIR__ . '/items.php';
    require_once __DIR__ . '/world.php';
    $n = upgrade_tx(function (): int {
        $L = item_lookups();
        $raw = fn(array $i): string => ($r = (int)($i['rarity'] ?? 1)) >= 80 ? 'L' : ($r >= 45 ? 'R' : ($r >= 20 ? 'U' : 'C'));
        $n = 0;
        foreach (q("SELECT r.ingredients, r.cook_minutes, r.output_qty, r.output_item_id FROM recipes r WHERE r.category = 'pantry' AND r.tier = 'preserve'")->fetchAll() as $r) {
            $ing = json_decode((string)$r['ingredients'], true) ?: [];
            $stale = false;
            foreach (array_keys($ing) as $slug) {
                $it = q_one('SELECT * FROM items WHERE slug = ?', [$slug]);
                if ($it && $raw($it) === 'L' && item_rarity($it, $L)[0] !== 'L') $stale = true;
            }
            if (!$stale) continue;
            $good = preserve_price($ing, (int)$r['cook_minutes'], (int)$r['output_qty'], $L);
            $have = (int)q_val('SELECT base_price FROM items WHERE id = ?', [$r['output_item_id']]);
            if ($good === null || $have <= $good * 1.8) continue;
            q('UPDATE items SET base_price = ? WHERE id = ?', [$good, $r['output_item_id']]);
            $n++;
        }
        return $n;
    });
    set_setting('upg_pantry_reprice', '1');
    setting('__reload__');
    return $n;
}

/** Run pantry_reprice_run() once per request on any world that has not had it (it also runs inside the version upgrade chain). Never takes a page down. */
function pantry_reprice_boot(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    if (setting('upg_pantry_reprice') !== '1') {
        try { require_once __DIR__ . '/pantry.php'; pantry_reprice_run(); } catch (Throwable $e) { error_log('pantry_reprice_boot: ' . $e->getMessage()); }
    }
}
