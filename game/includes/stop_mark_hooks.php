<?php
declare(strict_types=1);
/**
 * Lasting marks, hooks part 1 (claude/proposal-stop-perks.md section 4 and "Hook list"): the number families F01-F23 and the A4 coins,
 * called at the real game sites (shops, travel, walks, kitchen, garden, gathering, friends, stops, health, delves).
 * Behind stop_marks_open: while it is 0 every helper here returns 0 or the number unchanged, without loading the stop code, so the
 * game is exactly as before. Caps live in stop_marks.php (mark_pct). Rounding: a mark that fires moves its number by at least 1 unit.
 * Until perk_old_retired, a site takes the larger of the old 7-day perk and the mark, never both (mark_vs_old).
 */

function mark_hooks_on(): bool
{
    return setting('stop_marks_open') === '1';
}

/** mark_pct (world marks capped + place marks that fit $ctx), or 0 while lasting marks are off. */
function mark_fx(int $uid, string $family, array $ctx = []): int
{
    if ($uid < 1 || !mark_hooks_on()) return 0;
    require_once __DIR__ . '/stops.php';
    return mark_pct($uid, $family, $ctx);
}

/** What a "more" mark of $pct adds to $n: at least 1 when it fires. */
function mark_more(int $n, int $pct): int
{
    return $pct > 0 && $n > 0 ? max(1, (int)round($n * $pct / 100)) : 0;
}

/** $n after a "less" mark of $pct: at least 1 less when it fires, never under $floor. */
function mark_less(int $n, int $pct, int $floor = 0): int
{
    return $pct > 0 && $n > $floor ? max($floor, $n - max(1, (int)round($n * $pct / 100))) : $n;
}

/** A chance mark: true $pct times in 100. */
function mark_roll(int $pct): bool
{
    return $pct > 0 && random_int(1, 100) <= $pct;
}

/** [old 7-day perk %, mark %] for a site that has both: only the larger counts (proposal-stop-perks.md section 8, migration 2). */
function mark_vs_old(int $uid, string $family, array $ctx, string $oldKey, string $oldSetting): array
{
    require_once __DIR__ . '/player_perks.php';
    $old = player_perk_pct($uid, $oldKey, $oldSetting);
    $mark = mark_fx($uid, $family, $ctx);
    return $mark > $old ? [0, $mark] : [$old, 0];
}

// ---------------------------------------------------------------- context ($ctx keys, stop_marks.php MARK_SCOPE_KEYS)

function mark_region_code(int $regionId): string
{
    static $c = [];
    return $c[$regionId] ??= $regionId > 0 ? (string)q_val('SELECT code FROM regions WHERE id = ?', [$regionId]) : '';
}

function mark_loc_row(int $locId): ?array
{
    static $c = [];
    if ($locId < 1) return null;
    if (!array_key_exists($locId, $c)) $c[$locId] = q_one('SELECT id, kind, slug, region_id, landscape, stop_type FROM locations WHERE id = ?', [$locId]);
    return $c[$locId];
}

/** at / region / land of one place ([] while lasting marks are off: no query). */
function mark_ctx_loc(int $locId): array
{
    $l = mark_hooks_on() ? mark_loc_row($locId) : null;
    if (!$l) return [];
    return array_filter(['at' => (int)$l['id'], 'region' => mark_region_code((int)$l['region_id']), 'land' => (string)$l['landscape']], fn($v) => $v !== '' && $v !== 0);
}

/** Where the gnome stands now (empty while lasting marks are off: no query). */
function mark_ctx_here(int $uid): array
{
    if ($uid < 1 || !mark_hooks_on()) return [];
    return mark_ctx_loc((int)q_val('SELECT location_id FROM users WHERE id = ?', [$uid]));
}

/** A walk from $fromId to $toId: from / at = the start, to = the end, region = the start's, land = both ends' landscapes. */
function mark_ctx_walk(int $fromId, int $toId, int $routeId = 0): array
{
    $a = mark_ctx_loc($fromId);
    $b = mark_ctx_loc($toId);
    $ctx = $a + ['region' => $b['region'] ?? ''];
    if ($fromId > 0) $ctx['from'] = $fromId;
    if ($toId > 0) $ctx['to'] = $toId;
    if ($routeId > 0) $ctx['route'] = $routeId;
    $ctx['land'] = array_values(array_unique(array_filter([(string)($a['land'] ?? ''), (string)($b['land'] ?? '')])));
    return array_filter($ctx, fn($v) => $v !== '' && $v !== []);
}

/** A route row seen from where the gnome stands. */
function mark_ctx_route(array $u, array $route): array
{
    if (!mark_hooks_on()) return [];
    $here = (int)($u['location_id'] ?? 0);
    $a = (int)($route['a_id'] ?? 0);
    $b = (int)($route['b_id'] ?? 0);
    $to = (int)($route['to']['id'] ?? ($here === $a ? $b : ($here === $b ? $a : $b)));
    $from = $to === $a ? $b : $a;
    return mark_ctx_walk($from, $to, (int)($route['id'] ?? 0));
}

const MARK_NAME_GROUPS = [   // whole words in an item's slug (plural s allowed) => item groups the perks name (group=)
    'bread' => 'bread|loaf|bun|roll|scone|muffin|bagel|flatbread|pita|naan|tortilla|bannock|cracker|focaccia|injera|arepa',
    'tea' => 'tea|chai|tisane|infusion',
    'drink' => 'tea|chai|tisane|juice|cider|lemonade|milk|cocoa|coffee|smoothie|drink|punch|kvass|lassi|cordial|nectar|horchata|mate|cordial|chocolate',
    'syrup' => 'syrup|molasses|honey|treacle',
    'sweet' => 'sweet|candy|fudge|toffee|cake|tart|pie|cookie|biscuit|jam|pudding|honey|custard|brittle|halva|mochi|baklava|syrup|treat|cobbler|crumble',
    'egg' => 'egg|omelette|omelet|frittata|quiche',
    'dried' => 'dried|smoked|jerky|cured|salted',
    'grain' => 'porridge|oat|oatcake|bread|loaf|bun|scone|muffin|cake|biscuit|cracker|rice|noodle|pasta|barley|wheat|millet|maize|corn|bannock|flatbread',
    'preserve' => 'jam|pickle|pickled|preserve|chutney|jelly|marmalade|relish|kimchi|sauerkraut',
    'fish' => 'fish|trout|carp|perch|minnow|salmon|eel|cod|herring|sardine|tuna|catfish|pike|mackerel',
];

/** items (crop slugs) and group (item group words) of one item: its category, crop kind, recipe ingredients and name. Cached. */
function mark_ctx_item(int $itemId): array
{
    static $c = [];
    if ($itemId < 1 || !mark_hooks_on()) return [];
    if (isset($c[$itemId])) return $c[$itemId];
    $it = q_one('SELECT id, slug, category, effects FROM items WHERE id = ?', [$itemId]);
    if (!$it) return $c[$itemId] = [];
    $slug = (string)$it['slug'];
    $cat = (string)$it['category'];
    $items = [$slug];
    $group = [$cat];
    if ($cat === 'food') array_push($group, 'dish', 'food');
    if ($cat === 'forage') array_push($group, 'find', 'food');
    if ($cat === 'produce') $group[] = 'food';
    foreach (q('SELECT slug, kind, perennial FROM plants WHERE produce_item_id = ?', [$itemId])->fetchAll() as $p) $items = array_merge($items, mark_crop_words($p, $group));
    $recipes = q('SELECT ingredients FROM recipes WHERE output_item_id = ?', [$itemId])->fetchAll(PDO::FETCH_COLUMN);
    if ($recipes && strncmp($slug, 'bought-', 7) !== 0) $group[] = 'homecooked';   // made in the gnome's own kitchen (eat_item's home-cooked)
    foreach ($recipes as $ing) {
        $crops = json_decode((string)$ing, true);   // {"crop": qty}, or the data file's "crop:qty,crop:qty"
        if (!is_array($crops)) $crops = array_fill_keys(array_map(fn($x) => trim(explode(':', $x)[0]), explode(',', (string)$ing)), 1);
        foreach (array_keys($crops) as $crop) {
            $crop = trim((string)$crop);
            if ($crop === '') continue;
            $items[] = $crop;
            if ($p = q_one('SELECT slug, kind, perennial FROM plants WHERE slug = ?', [$crop])) { $g = []; mark_crop_words($p, $g); if (in_array('grain', $g, true)) $group[] = 'grain'; }
        }
    }
    if (q_val("SELECT 1 FROM gatherables WHERE item_id = ? AND tool = 'rod'", [$itemId])) $group[] = 'fish';
    foreach (MARK_NAME_GROUPS as $g => $words) if (preg_match('/(^|-)(' . $words . ')s?(-|$)/', $slug)) $group[] = $g;
    $fx = json_decode((string)($it['effects'] ?? ''), true);
    if (is_array($fx) && !empty($fx['preserve'])) $group[] = 'preserve';
    return $c[$itemId] = ['items' => array_values(array_unique($items)), 'group' => array_values(array_unique($group))];
}

/** A crop's slugs for items=, and its kind words added to $group (regrow = perennial; tree crops count as fruit). */
function mark_crop_words(array $p, array &$group): array
{
    $kind = (string)($p['kind'] ?? '');
    if ($kind !== '') $group[] = $kind;
    if ($kind === 'tree') $group[] = 'fruit';
    if ((int)($p['perennial'] ?? 0)) $group[] = 'regrow';
    return array_values(array_filter([(string)($p['slug'] ?? '')]));
}

/** items / group of a garden crop (a plants row): its own slug and its produce's. */
function mark_ctx_crop(array $p): array
{
    if (!mark_hooks_on()) return [];
    $group = [];
    $items = mark_crop_words($p, $group);
    if (!empty($p['produce_item_id']) && ($ps = (string)q_val('SELECT slug FROM items WHERE id = ?', [(int)$p['produce_item_id']])) !== '') $items[] = $ps;
    return ['items' => array_values(array_unique($items)), 'group' => array_values(array_unique($group))];
}

/** A shop's place (at / region / land) and the item's items / group. */
function mark_ctx_shop(int $shopId, int $itemId): array
{
    static $loc = [];
    if (!mark_hooks_on()) return [];
    $loc[$shopId] ??= $shopId > 0 ? (int)q_val('SELECT location_id FROM shops WHERE id = ?', [$shopId]) : 0;
    return mark_ctx_loc($loc[$shopId]) + mark_ctx_item($itemId);
}

/** F02: a shop price after the buy marks (only when they beat the old Silver Tongue perk, which shop_discount_pct then leaves out). */
function mark_buy_price(array $u, int $p, int $shopId, int $itemId): int
{
    return mark_less($p, mark_vs_old((int)($u['id'] ?? 0), 'buy', mark_ctx_shop($shopId, $itemId), 'silver_tongue', 'perk_silver_tongue')[1], 1);
}

/** The owner of a garden plot (garden hooks only get the tile); 0 while lasting marks are off (no query). */
function mark_plot_owner(int $plotId): int
{
    static $c = [];
    if ($plotId < 1 || !mark_hooks_on()) return 0;
    return $c[$plotId] ??= (int)q_val('SELECT user_id FROM plots WHERE id = ?', [$plotId]);
}

/** The stop act being done now (set by stop_do, read by stop_rewards for F15 stop coins); null clears it. */
function mark_act_ctx(?array $set = null, bool $clear = false): array
{
    static $now = [];
    if ($clear) $now = [];
    elseif ($set !== null) $now = $set;
    return $now;
}

// ---------------------------------------------------------------- one-line hooks used by several sites

/** F14: a chat or gift with folk: 1 more friendship point when the mark's chance comes up. */
function mark_friend_extra(int $uid, array $ctx): int
{
    return mark_roll(mark_fx($uid, 'friend', $ctx)) ? 1 : 0;
}

/** F09: healing points $n with the heal marks that fit $ctx added. */
function mark_heal(int $uid, int $n, array $ctx): int
{
    return $n + mark_more($n, mark_fx($uid, 'heal', $ctx));
}

/**
 * A4: the few-coins perks whose trigger is $trig ('coin_on_a_road_walk', 'first_sale_at_the_stops_stall', 'first_act_of_a_kind_at_the_stop',
 * 'first_rest_act_at_the_stop'). A road walk find: 1 in 20; a "first" trigger: once a game day per perk (mark_daily_use). A perk tied to a
 * stop's own act or stall and naming no place counts at its own stop. All A4 perks share MARK_A4_CEILING coins a game day. Pays and returns the coins.
 */
function mark_coins_on(int $uid, string $trig, array $ctx): int
{
    if ($uid < 1 || !mark_hooks_on()) return 0;
    require_once __DIR__ . '/stops.php';
    $coins = 0;
    foreach (mark_held($uid) as $p) {
        if ($p['family'] !== 'A4' || !in_array($trig, $p['scope']['trig'] ?? [], true) || !mark_scope_fits($p, $ctx)) continue;
        $own = !array_intersect(['at', 'from', 'region'], array_keys($p['scope'])) && $trig !== 'coin_on_a_road_walk';
        if ($own && (int)($ctx['at'] ?? 0) !== (int)$p['loc_id']) continue;
        $fires = $trig === 'coin_on_a_road_walk' ? random_int(1, 20) === 1 : mark_daily_use($uid, (string)$p['key']);
        if ($fires) $coins += mark_daycoin($uid, (string)$p['key'], max(1, (int)$p['size']));
    }
    if ($coins > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    return $coins;
}

/** The line for A4 coins ('' for none). */
function mark_coins_line(int $coins): string
{
    return $coins > 0 ? '🏅 +' . $coins . ' ' . setting('currency_name') . ' (a lasting mark)' : '';
}

require_once __DIR__ . '/stop_mark_charges.php';   // part 2: daily charges A1-A3 and flags
