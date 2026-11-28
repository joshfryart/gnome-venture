<?php
declare(strict_types=1);

/** Home regions, known plants, guides, travel and shops. */

require_once __DIR__ . '/gnome.php';   // v0.9.1: calling_perk() for travel and selling perks
require_once __DIR__ . '/stop_mark_hooks.php';   // lasting marks (behind stop_marks_open)

const HUB_REGION = 'Mossbottom';   // the hub market every player can reach from anywhere

/** All region rows (ordered by sort_order). Cached per request. */
function all_regions(): array
{
    static $cache = null;
    return $cache ??= q('SELECT * FROM regions ORDER BY sort_order, gnomish_name')->fetchAll();
}

/** Look a region up by its Gnomish name (e.g. "Mistmoor" from the user's location string). */
function region_by_name(string $name): ?array
{
    foreach (all_regions() as $r) {
        if ($r['gnomish_name'] === $name) return $r;
    }
    return null;
}

function region_by_slug(string $slug): ?array
{
    foreach (all_regions() as $r) {
        if (strtolower($r['code']) === strtolower($slug)) return $r;
    }
    return null;
}

function home_region(array $u): ?array
{
    return !empty($u['region_id']) ? q_one('SELECT * FROM regions WHERE id = ?', [$u['region_id']]) : null;
}

/** Region codes the player has read a guide for. */
function guide_regions(int $uid): array
{
    $out = [];
    foreach (q('SELECT guide_key FROM user_guides WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $k) {
        if (str_starts_with($k, 'region:')) {
            $code = strtoupper(substr($k, 7));
            if ($r = region_by_slug($code)) $out[] = (int)$r['id'];
        }
    }
    return $out;
}

/**
 * Plants this player knows how to grow: everyday crops, the staples of their home region,
 * every tier where they own a garden, and everything from any guide they've read.
 * Returns [plant_id => true].
 */
function known_plants(array $u, bool $mastery = true): array
{
    // v0.7.86: $mastery false leaves out mastered crops: only regions studied (home, a garden there, a guide)
    static $cache = [];
    $uid = (int)$u['id'];
    $key = $uid . ($mastery ? '' : 'r');
    if (isset($cache[$key])) return $cache[$key];
    $ids = q('SELECT id FROM plants WHERE common = 1')->fetchAll(PDO::FETCH_COLUMN);
    // Home region: staples + flowers
    if (!empty($u['region_id'])) {
        $rid = (int)$u['region_id'];
        $ids = array_merge($ids,
            q("SELECT plant_id FROM plant_regions WHERE region_id = ? AND tier IN ('staple','flower')", [$rid])->fetchAll(PDO::FETCH_COLUMN));
    }
    // Owning a garden in a region: all tiers (staple/uncommon/treasure/flower)
    foreach (q('SELECT DISTINCT region_id FROM plots WHERE user_id = ? AND region_id IS NOT NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $prid) {
        $ids = array_merge($ids, q('SELECT plant_id FROM plant_regions WHERE region_id = ?', [$prid])->fetchAll(PDO::FETCH_COLUMN));
    }
    // v0.7.65: mastering a crop (full knowledge) teaches it, guide or not
    if ($mastery) $ids = array_merge($ids, q('SELECT k.plant_id FROM user_plant_knowledge k JOIN plants p ON p.id = k.plant_id WHERE k.user_id = ? AND k.knowledge >= p.knowledge_max', [$uid])->fetchAll(PDO::FETCH_COLUMN));
    // Guides: a region's full set
    foreach (guide_regions($uid) as $rid) {
        $ids = array_merge($ids, q('SELECT plant_id FROM plant_regions WHERE region_id = ?', [$rid])->fetchAll(PDO::FETCH_COLUMN));
    }
    return $cache[$key] = array_fill_keys(array_map('intval', $ids), true);
}

function read_guide(array $u, int $itemId): array
{
    $item = q_one("SELECT * FROM items WHERE id = ? AND category = 'guide'", [$itemId]);
    $key = $item ? (string)(json_decode((string)$item['effects'], true)['guide'] ?? '') : '';
    if ($key === '') return [false, 'That isn’t a guide.'];
    if (q_val('SELECT 1 FROM user_guides WHERE user_id = ? AND guide_key = ?', [$u['id'], $key])) {
        return [false, 'You already know everything in this guide. Maybe sell it or give it to a friend.'];
    }
    db()->beginTransaction();
    if (!give_item((int)$u['id'], $itemId, -1)) {
        db()->rollBack();
        return [false, 'You don’t have that guide.'];
    }
    db_insert('user_guides', ['user_id' => $u['id'], 'guide_key' => $key, 'read_at' => now()]);
    db()->commit();
    $region = region_by_slug(strtoupper(substr($key, 7)));
    $count = $region ? (int)q_val('SELECT COUNT(*) FROM plant_regions WHERE region_id = ?', [$region['id']]) : 0;
    return [true, '📗 You study the ' . $item['name'] . '. Its plants are now in your Almanac as studied, and you can grow them. (' . $count . ' plants covered)'];
}

// ----------------------------------------------------------------- Shops

/** Neopets-style restock: when the timer runs out, each item has a chance to come back at a new price. */
function shop_restock(int $shopId): void
{
    $shop = q_one('SELECT * FROM shops WHERE id = ?', [$shopId]);
    $cut = gmdate('Y-m-d H:i:s', time() - (int)$shop['restock_minutes'] * 60);
    $claimed = q('UPDATE shops SET last_restock = ? WHERE id = ? AND (last_restock IS NULL OR last_restock < ?)',
        [now(), $shopId, $cut])->rowCount();
    if (!$claimed) return;
    foreach (q('SELECT * FROM shop_stock WHERE shop_id = ?', [$shopId])->fetchAll() as $s) {
        if (random_int(1, 100) > (int)$s['restock_chance']) continue;
        $max = max(1, (int)$s['max_stock']);
        $qty = random_int(max(1, intdiv($max, 2)), $max);
        $price = random_int((int)$s['price_min'], max((int)$s['price_min'], (int)$s['price_max']));
        $price = max(1, (int)round($price * (100 + max(0, (int)$shop['markup_percent'])) / 100));
        q('UPDATE shop_stock SET current_stock = ?, current_price = ? WHERE id = ?', [max($qty, (int)$s['current_stock']), $price, $s['id']]);
    }
}

/**
 * Grow times (v0.7.27, Joshua): everyday crops in minutes, rarer ones longer.
 *   common 5–20 min · regional staples 10–60 min · flowers 10 min–2 h · uncommon 30 min–3 h · treasure 2–6 h.
 * Each plant is rescaled once (plants.timing_v), so later admin edits stay as they are.
 */
function grow_time_class(array $p): string
{
    if ((int)$p['common']) return 'common';
    $tiers = q('SELECT DISTINCT tier FROM plant_regions WHERE plant_id = ?', [$p['id']])->fetchAll(PDO::FETCH_COLUMN);
    foreach (['staple', 'flower', 'uncommon', 'treasure'] as $t) if (in_array($t, $tiers, true)) return $t;
    return 'staple';
}

function scaled_grow_minutes(int $old, string $class): int
{
    $c = fn(float $v, int $lo, int $hi) => max($lo, min($hi, (int)round($v)));
    return match ($class) {
        'common' => $c(5 + ($old - 15) * 15 / 165, 5, 20),
        'flower' => $c($old / 6, 10, 120),
        'uncommon' => $c($old / 4, 30, 180),
        'treasure' => $c($old / 2, 120, 360),
        default => $c($old / 6, 10, 60),
    };
}

function ensure_grow_times(): void
{
    foreach (q('SELECT * FROM plants WHERE timing_v = 0')->fetchAll() as $p) {
        $old = max(1, (int)$p['grow_minutes']);
        $new = scaled_grow_minutes($old, grow_time_class($p));
        $regrow = (int)$p['regrow_minutes'] > 0 ? max(3, (int)round((int)$p['regrow_minutes'] * $new / $old)) : 0;
        q('UPDATE plants SET grow_minutes = ?, regrow_minutes = ?, timing_v = 1 WHERE id = ?', [$new, $regrow, $p['id']]);
    }
}

/**
 * v0.9.4: a shop-bought dish gives shop_food_energy_pct % of the home-cooked energy, at least 1, at most 4 (it is a weak, Petal-paid top-up).
 * $homeEnergy is the dish's own `energy`.
 */
function shop_food_energy(int $homeEnergy): int
{
    $pct = max(0, (int)setting('shop_food_energy_pct'));
    return max(1, min(4, (int)round($homeEnergy * $pct / 100)));
}

/** v0.7.86: the effects a shop-bought copy gets: the same buffs as the dish, but only a little energy (v0.9.4: a percent of the dish's). */
function shop_food_effects(?string $effects): ?string
{
    $fx = json_decode((string)$effects, true);
    if (!is_array($fx)) return $effects;
    $fx['energy'] = shop_food_energy((int)($fx['energy'] ?? 0));
    return json_encode($fx);
}

/**
 * Shop-bought food (v0.7.27): shops sell their own "shop-bought" version of a dish, worth less than home cooking,
 * so buying and selling straight back never makes a profit and player-made food stays the valuable kind.
 */
function ensure_shop_food(): void
{
    foreach (q("SELECT i.*, st.id AS stock_id, st.price_min FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE i.category = 'food' AND i.slug NOT LIKE 'bought-%'")->fetchAll() as $row) {
        $slug = mb_substr('bought-' . $row['slug'], 0, 80);
        $vid = item_id_by_slug($slug);
        if (!$vid) {
            $vid = db_insert('items', ['name' => mb_substr($row['name'] . ' (shop-bought)', 0, 80), 'slug' => $slug, 'category' => 'food',
                'description' => trim((string)$row['description']) . ' Bought at a shop: less filling than home cooking, and worth less.',
                'rarity' => (int)$row['rarity'], 'base_price' => max(1, (int)floor(max(1, (int)$row['price_min']) * 0.5)),
                // v0.9.1a: shop-bought copies give shop_food_energy_pct of the dish, 1-4 energy (home cooking gives more)
                'edible' => (int)$row['edible'], 'effects' => shop_food_effects($row['effects']), 'tradable' => (int)$row['tradable'], 'max_stack' => (int)$row['max_stack']]);
        }
        q('UPDATE shop_stock SET item_id = ? WHERE id = ?', [$vid, $row['stock_id']]);
    }
}

/**
 * v0.9.1a: existing shop-bought copies get their small energy (v0.9.4: shop_food_energy_pct of the dish's) and the new description.
 * Safe to run more than once.
 */
function upgrade_shop_food_energy(): void
{
    $old = 'just as filling, but worth less than home cooking.';
    $new = 'less filling than home cooking, and worth less.';
    foreach (q("SELECT id, slug, effects, description FROM items WHERE slug LIKE 'bought-%'")->fetchAll() as $it) {
        $src = q('SELECT effects FROM items WHERE slug = ?', [substr((string)$it['slug'], 7)])->fetch();
        $sfx = $src ? json_decode((string)$src['effects'], true) : null;
        $fx = json_decode((string)$it['effects'], true);
        if (!is_array($fx)) $fx = [];
        $fx['energy'] = shop_food_energy((int)(is_array($sfx) ? ($sfx['energy'] ?? 0) : 0));   // v0.9.4: percent rule
        q('UPDATE items SET effects = ?, description = ? WHERE id = ?', [json_encode($fx), str_replace($old, $new, (string)$it['description']), $it['id']]);
    }
}

/** NPCs working at this shop right now (server time). */
function staff_on_duty(int $shopId): array
{
    $hour = hollow_hour();
    $day = hollow_dow();
    if (gclock_on() && ($cu = current_user())) { $gs = gclock_state($cu); $hour = $gs['hour']; $day = $gs['dow']; }   // sleep-days: the shop keeps the gnome's own hours
    $out = [];
    foreach (q("SELECT n.id, n.name, n.slug, n.species, n.personality, s.days, s.start_hour, s.end_hour
                FROM npc_schedules s JOIN npcs n ON n.id = s.npc_id
                WHERE s.shop_id = ? AND s.activity = 'working' AND n.active = 1", [$shopId])->fetchAll() as $r) {
        if (in_array($day, schedule_days($r['days']), true) && in_array($hour, schedule_hours((int)$r['start_hour'], (int)$r['end_hour']), true)) {
            $out[$r['id']] = $r;
        }
    }
    // 2.7.01 clockwork: a keeper who is out on one of their doings (or away today) is spelled by a free neighbour from the same town
    require_once __DIR__ . '/npc_clockwork.php';
    foreach ($out as $id => $r) {
        if (!npc_cw_on() || (!npc_cw_out('n' . $id) && !gclock_npc_away('n' . $id))) continue;
        unset($out[$id]);
        if (($c = npc_cw_shop_cover($shopId, $day, (float)$hour)) && !isset($out[$c['id']])) $out[$c['id']] = ['id' => $c['id'], 'name' => $c['name'], 'slug' => $c['slug'], 'species' => $c['species'], 'personality' => $c['personality'],
            'days' => 'all', 'start_hour' => 0, 'end_hour' => 0, 'covering' => $r['name']];
    }
    return array_values($out);
}

/** The Gnomish name of the region the player is currently in (or HUB_REGION). */
function player_location(array $u): string
{
    if (!empty($u['location'])) return (string)$u['location'];
    $home = home_region($u);
    return $home ? $home['gnomish_name'] : HUB_REGION;
}

function can_reach(array $u, ?string $regionName): bool
{
    return $regionName === HUB_REGION || $regionName === player_location($u);
}

/**
 * Why this gnome can't fast-travel right now, or '' if they can. A road walk, a trip into the wilds, a delve and a lair are all
 * active expeditions; a trek and a community tending shift hold the gnome too. Shared by travel_to() and the free trip to a calling mentor.
 */
function travel_blocked(array $u): string
{
    if (q_val("SELECT 1 FROM expeditions WHERE user_id = ? AND status = 'active'", [$u['id']])) return 'Finish your walk first.';
    require_once __DIR__ . '/trek_data.php';
    if (trek_inside((int)$u['id'])) return 'You’re on a trek. Leave the trek first.';   // v1.9.4: no fast travel inside a trek (gathering is fine)
    if (ts($u['community_shift_until'] ?? null) > time()) return 'You’re on a tending shift at the community garden. Finish or end it first.';   // v0.7.85
    return '';
}

function travel_to(array $u, int $regionId): array
{
    if (($why = travel_blocked($u)) !== '') return [false, $why];
    $target =q_one('SELECT * FROM regions WHERE id = ?', [$regionId]);
    if (!$target) return [false, 'There’s no such place.'];
    if ($target['gnomish_name'] === player_location($u)) return [false, 'You’re already here.'];
    if (setting('seals_open') === '1') {   // 2.8.85: a Seal-locked door still needs the Seal (home, gardens and places already reached stay open)
        require_once __DIR__ . '/seals.php';
        if (($warden = seal_region_warden_message((int)$u['id'], (int)$target['id'])) !== '') return [false, $warden];
    }
    if (!can_fast_travel($u, (int)$target['id'])) {   // v0.7.43: walk there once first
        return [false, 'You haven’t been to ' . $target['gnomish_name'] . ' yet. Walk the roads there once (recommended level ' . region_min_level((int)$target['id']) . '), then you can travel straight there any time.'];
    }
    $home = home_region($u);
    require_once __DIR__ . '/journey.php';
    $free = ($home && (int)$home['id'] === (int)$target['id']) || journey_benefit((int)$u['id'], 'free_travel', (int)$target['id']);   // v0.7.65: a Journey project
    $cost = $free ? 0 : (int)setting('travel_cost');
    $energy = $free ? 0 : (int)setting('travel_energy');
    // v0.9.1: calling perks (Wayfinder): a Petals discount and less energy, by calling tier
    $cost = (int)round($cost * (100 - calling_perk($u, 'fast_travel_discount')) / 100);
    $energy = max(0, $energy - calling_perk($u, 'fast_travel_energy_minus'));
    $mkFrom = mark_ctx_here((int)$u['id']);   // lasting marks: a fast travel starts where the gnome stands
    $cost = mark_less($cost, mark_fx((int)$u['id'], 'travel', $mkFrom));   // F18 fast travel cost
    $mkFt = mark_charges_ready((int)$u['id'], 'fast_travel', $mkFrom);   // A1 lasting marks: 1 energy less, taken once the travel is paid
    $energy = mark_charge_energy($mkFt, $energy);
    db()->beginTransaction();
    $market = q_val("SELECT id FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$target['id']]);
    if (q('UPDATE users SET coins = coins - ?, energy = energy - ?, location = ?, location_id = ?, arrived_at = ? WHERE id = ? AND coins >= ? AND energy >= ?',
            [$cost, $energy, $target['gnomish_name'], $market, now(), $u['id'], $cost, $energy])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You need ' . number_format($cost) . ' ' . setting('currency_name') . ' and ' . $energy . ' energy to travel there.'];
    }
    $find = '';
    if (random_int(1, 100) <= calling_perk($u, 'travel_seed_pct') + mark_fx((int)$u['id'], 'trailseed', $mkFrom)) {   // + F23 seed on fast travel   // v0.9.1: chance by calling tier (0 without a calling)
        $options = q('SELECT DISTINCT i.id, i.name FROM plant_regions pr
                      JOIN plants p ON p.id = pr.plant_id JOIN items i ON i.id = p.seed_item_id
                      WHERE pr.region_id = ?', [$target['id']])->fetchAll();
        $seed = $options ? $options[array_rand($options)] : null;
        if ($seed) {
            give_item((int)$u['id'], (int)$seed['id'], 1);
            $find = ' 🧭 On the way you find some wild ' . $seed['name'] . '!';
        }
    }
    if (mark_charges_take((int)$u['id'], $mkFt)) $find .= ' 🏅 A lasting mark saved you 1 energy.';
    record_region_visit((int)$u['id'], (int)$target['id']);
    db()->commit();
    calling_event((int)$u['id'], 'travel', (string)$target['code'], 1);   // v0.9.4 N4: a fast travel
    return [true, ($free ? "You head home to " . $target['gnomish_name'] . "." : "You travel to " . $target['gnomish_name'] . ". (−" . number_format($cost) . ' ' . setting('currency_name') . ", −$energy energy)") . $find];
}

/** v0.7.61: you have to be in the shop's town (Mossbottom's shops are reachable from anywhere). */
function shop_reachable(array $u, array $shop): bool
{
    $loc = $shop['location_id'] ? q_one('SELECT id, region, kind FROM locations WHERE id = ?', [$shop['location_id']]) : null;
    if (!$loc) return false;
    if ($loc['region'] === HUB_REGION || $loc['kind'] === 'hub') return true;
    require_once __DIR__ . '/adventure.php';
    return (int)player_node($u)['id'] === (int)$loc['id'];
}

/** Is this shop one of Mossbottom's (the hub market: reachable from anywhere)? Takes a shops row (a 'loc_region' column saves the lookup). */
function shop_is_hub(array $shop): bool
{
    if (isset($shop['loc_region'])) return (string)$shop['loc_region'] === HUB_REGION;
    $loc = !empty($shop['location_id']) ? q_one('SELECT region, kind FROM locations WHERE id = ?', [$shop['location_id']]) : null;
    return $loc && ((string)$loc['region'] === HUB_REGION || (string)$loc['kind'] === 'hub');
}

/**
 * v2.7.01: what a shop is like for this gnome right now (Shop Street picture and its list). Takes a shops row (open_minute / close_minute are read from it).
 * Returns ['state' => 'open'|'closed'|'away', 'why' => a sentence, 'chip' => a few words, 'staff' => [names]].
 * away = not reachable from where the gnome stands (a town shop while elsewhere); closed = the game clock says shut, or nobody is on shift; else open.
 */
function shop_state(array $u, array $shop): array
{
    $staff = array_column(staff_on_duty((int)$shop['id']), 'name');
    if (!shop_reachable($u, $shop)) {
        $where = (string)($shop['loc_name'] ?? '');
        return ['state' => 'away', 'why' => $where !== '' ? 'Walk to ' . $where . ' to shop here.' : 'You need to be in that town to shop here.', 'chip' => 'away', 'staff' => $staff];
    }
    // The same rules each shop's buy path uses: ordinary shops clock then staff (buy_from_shop), pet shops only the admin switch (petshop_buy), Dye Pot / Curio Cabinet staff only (sink_shop_post).
    if (($shop['shop_type'] ?? '') === 'pets') {
        require_once __DIR__ . '/catfish_pets.php';
        if (catfish_pet_cfg('catfish_pet_shops_open', 1) < 1) return ['state' => 'closed', 'why' => 'The pet shops are closed for now.', 'chip' => 'closed for now', 'staff' => $staff];
        return ['state' => 'open', 'why' => 'Open.', 'chip' => 'open', 'staff' => $staff];
    }
    $sink = sink_shop_kind($shop) !== '';
    if (!$sink && ($why = gclock_closed_reason($u, $shop))) return ['state' => 'closed', 'why' => $why, 'chip' => 'closed for now', 'staff' => $staff];
    if (!$staff) return ['state' => 'closed', 'why' => 'Closed, nobody on shift.', 'chip' => 'nobody on shift', 'staff' => []];
    $hours = '';
    if (!$sink && gclock_on()) {
        [$o, $c] = gclock_place_hours($shop);
        $hours = sprintf('%02d:%02d-%02d:%02d', intdiv($o, 60) % 24, $o % 60, $c >= 1440 ? 24 : intdiv($c, 60) % 24, $c >= 1440 ? 0 : $c % 60);
    }
    return ['state' => 'open', 'why' => 'At the counter: ' . implode(', ', $staff) . ($hours !== '' ? ' (open ' . $hours . ')' : ''), 'chip' => $hours !== '' ? $hours : 'open', 'staff' => $staff];
}

/** Returns [ok, message, cost, item name]. */
function buy_from_shop(array $u, int $stockId, int $qty): array
{
    $qty = max(1, min(999, $qty));
    $s = q_one('SELECT st.*, sh.open, sh.open_minute, sh.close_minute, sh.id AS sid, sh.location_id, i.name, i.category AS item_category, i.effects AS item_effects FROM shop_stock st
                JOIN shops sh ON sh.id = st.shop_id JOIN items i ON i.id = st.item_id WHERE st.id = ?', [$stockId]);
    if (!$s || !(int)$s['open']) return [false, 'That shop is closed.'];
    require_once __DIR__ . '/pfdeck.php';   // 2.7.05: a fight belt is sold only to a gnome old enough to use it
    if (pfd_gear_slug((string)q_val('SELECT slug FROM items WHERE id = ?', [$s['item_id']])) && !pfd_gear_open($u)) return [false, 'That is not on the shelf.'];   // 2.7.08
    $slugB = (string)q_val('SELECT slug FROM items WHERE id = ?', [(int)$s['item_id']]);
    if (($needB = pfd_belt_level_need($slugB)) > (int)($u['level'] ?? 1)) return [false, 'The ' . $s['name'] . ' needs gnome level ' . $needB . '. Come back when you are old enough to wear it.'];
    require_once __DIR__ . '/wearables.php';
    if ($wb = wear_shop_block($u, $slugB)) return [false, $wb];   // the regional outfitters (setting + region level)
    if (!shop_reachable($u, ['location_id' => $s['location_id']])) return [false, 'You need to be in that town first.'];
    if ($why = gclock_closed_reason($u, $s)) return [false, $why];
    if (!staff_on_duty((int)$s['sid'])) return [false, 'Nobody is at the counter right now.'];
    // v0.7.85: a guide you've already read can't be bought again (same key shop.php uses)
    $gkey = $s['item_category'] === 'guide' ? (string)((json_decode((string)$s['item_effects'], true) ?: [])['guide'] ?? '') : '';
    if ($gkey !== '' && q_val('SELECT 1 FROM user_guides WHERE user_id = ? AND guide_key = ?', [$u['id'], $gkey])) {
        return [false, 'You’ve already read this guide.'];
    }
    $cost = shop_price($u, (int)$s['current_price'], (int)$s['shop_id'], (int)$s['item_id']) * $qty;
    db()->beginTransaction();
    if (q('UPDATE shop_stock SET current_stock = current_stock - ? WHERE id = ? AND current_stock >= ?', [$qty, $stockId, $qty])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'There aren’t ' . $qty . ' ' . $s['name'] . ' left on the shelf.'];
    }
    if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $u['id'], $cost])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You can’t afford ' . $qty . ' × ' . $s['name'] . ' (' . number_format($cost) . ' ' . setting('currency_name') . ').'];
    }
    give_item((int)$u['id'], (int)$s['item_id'], $qty);
    $mkLine = mark_buy_charges((int)$u['id'], (int)$s['sid'], (int)$s['item_id'], (string)$s['item_category'], (string)$s['name']);   // A3 lasting marks: one extra
    db()->commit();
    return [true, "You buy $qty × {$s['name']} for " . number_format($cost) . ' ' . setting('currency_name') . '.' . ($mkLine !== '' ? ' ' . $mkLine . '.' : ''), $cost, (string)$s['name']];
}

/** What a player pays in a shop: Charm, then any friendship discount with the staff (v0.7.13). */
function shop_price(array $u, int $price, int $shopId, int $itemId = 0): int
{
    $p = charm_price($u, $price, true);
    $d = shop_discount_pct($u, $shopId, $itemId);
    $p = $d ? max(1, (int)round($p * (100 - $d) / 100)) : $p;
    $p = mark_buy_price($u, $p, $shopId, $itemId);   // F02 lasting marks
    return $itemId > 0 ? max(1, (int)round($p * market_buy_mult($itemId))) : $p;   // v1.0.0: seasonal seeds and crops cost a little less in season
}

/**
 * 2.7.58 EC3: the percent off a shop's prices for this gnome (max 60): friendship with the staff, the weather vane, Silver Tongue, a Trail Sight's
 * shop discount and one scoped to the item's category. shop_price and shop_buy_floor both use it, so the buy-back floor can never sit above what buying costs.
 */
function shop_discount_pct(array $u, int $shopId, int $itemId = 0): int
{
    static $fd = [];
    require_once __DIR__ . '/friends.php';
    $uid = (int)$u['id'];
    $sale = array_key_exists('ev_sale_until', $u) ? $u['ev_sale_until'] : q_val('SELECT ev_sale_until FROM users WHERE id = ?', [$uid]);
    $key = $uid . '|' . $shopId . '|' . ($sale ?? '');
    $fd[$key] ??= friend_discount($uid, $shopId);
    $d = $fd[$key];
    if ($sale && strtotime($sale . ' UTC') > time()) $d += 20;   // the weather vane (v0.7.31)
    require_once __DIR__ . '/player_perks.php';
    $d += mark_vs_old($uid, 'buy', mark_ctx_shop($shopId, $itemId), 'silver_tongue', 'perk_silver_tongue')[0];   // 2.6.33 (a lasting mark that beats it: mark_buy_price instead)
    require_once __DIR__ . '/trail_sight_extras.php'; $d += trail_sight_disc_pct($uid, 'shop') + sights5_disc_item_pct($uid, $itemId);   // 2.7.00: a Trail Sight's shop discount; fifth pass: one scoped to this item's category (disc=shop:20:60:seed)
    return max(0, min(60, $d));
}

function charm_price(array $u, int $price, bool $buying): int
{
    $m = eff_mod($u, 'charm');
    $f = $buying ? 1 - 0.02 * $m : 1 + 0.02 * $m;
    return max(1, (int)round($price * max(0.5, min(1.5, $f))));
}

/**
 * v2.2.x: what a shop pays for one at the flat base share (price_base_pct, no weekly drift, season, demand or sales), with the rarity
 * multiplier and the buy-back cap, using the $L the caller passes (a FRESH item_lookups(), not sell_price()'s per-request cache).
 * Used to price preserves at import, so a fresh install and a live one agree.
 */
function flat_sell_value(array $item, array $L): int
{
    $pct = max(1, mk_int('price_base_pct', 60));
    $base = max(1, (int)floor((int)$item['base_price'] * $pct / 100));
    if (($item['category'] ?? '') === 'packet') return packet_sell_cap($item, $pct, $base);
    if (($item['category'] ?? '') === 'arrangement') return $base;
    require_once __DIR__ . '/items.php';
    [$r] = item_rarity($item, $L);
    $mult = ['C' => 100, 'U' => (int)setting('sell_mult_uncommon'), 'R' => (int)setting('sell_mult_rare'), 'L' => (int)setting('sell_mult_legendary')][$r] ?? 100;
    $base = max(1, (int)round($base * max(1, $mult) / 100));
    $sr = shop_stock_rows((int)($item['id'] ?? 0));
    if ($sr) $base = min($base, max(1, (int)floor(min(array_map(fn($x) => (int)$x['p'], $sr)) * $pct / 100)));
    return $base;
}

/** 2.7.58 EC1: a Seed Packet sells for at most its seeds' flat value (seed base x seeds x the sell share): seeds cannot be sold, so the packet used to turn them into Petals at a profit. */
function packet_sell_cap(array $item, int $pct, int $base): int
{
    $fx = json_decode((string)($item['effects'] ?? ''), true) ?: [];
    $seed = (int)q_val('SELECT si.base_price FROM plants p JOIN items si ON si.id = p.seed_item_id WHERE p.id = ?', [(int)($fx['packet'] ?? 0)]);
    if ($seed < 1) return $base;
    return max(1, min($base, (int)floor($seed * max(1, (int)($fx['seeds'] ?? 1)) * $pct / 100)));
}

function sell_price(array $item, ?array $u = null): int
{
    $pct = market_sell_pct($item);   // v1.0.0: the shop's share of the base price drifts (45-80%) with the week, season, demand and sales
    $base = max(1, (int)floor((int)$item['base_price'] * $pct / 100));
    if (in_array($item['category'] ?? '', ['arrangement', 'packet'], true)) {   // v0.9.9: their value already carries the score, so no rarity multiplier
        if ($item['category'] === 'packet') $base = packet_sell_cap($item, $pct, $base);   // 2.7.58 EC1: never worth more than its seeds
        return $u ? charm_price($u, $base, false) : $base;
    }
    // v0.7.61: rarer things fetch much more (admin: sell_mult_* settings)
    static $L = null;
    require_once __DIR__ . '/items.php';
    $L ??= item_lookups();
    [$r] = item_rarity($item, $L);
    $mult = ['C' => 100, 'U' => (int)setting('sell_mult_uncommon'), 'R' => (int)setting('sell_mult_rare'), 'L' => (int)setting('sell_mult_legendary')][$r] ?? 100;
    $base = max(1, (int)round($base * max(1, $mult) / 100));
    // v0.7.27: never sell anything back for more than the sell % of the cheapest a shop sells it for (v1.0.0: the drifted %, so it never beats buying)
    $shopMin = ($sr = shop_stock_rows((int)($item['id'] ?? 0))) ? min(array_map(fn($r) => (int)$r['p'], $sr)) : 0;
    if ($shopMin) $base = min($base, max(1, (int)floor((int)$shopMin * $pct / 100)));
    if ($u && $item['category'] === 'flower') {   // v0.9.1: Bloomcaller cut flowers sell for more, by calling tier
        $base = (int)round($base * (100 + calling_perk($u, 'flower_sell_pct')) / 100);
    }
    if ($u) $base = charm_price($u, $base, false);
    // v1.0.0: never sell anything back for more than the cheapest a shop would charge THIS gnome for it (after Charm, friendship
    // discounts, the weather vane and the season), so buying and selling again can never make money. Items no shop stocks keep the drift.
    $cap = shop_buy_floor((int)($item['id'] ?? 0), $u);
    if ($cap === null && ($cut = dried_cut_item($item))) {   // 2.7.58 EC2: no shop stocks a dried flower; it is capped at dried_price_pct of what the cut flower costs (so drying never beats buying and reselling)
        $cf = shop_buy_floor((int)$cut['id'], $u);
        if ($cf !== null) $cap = max(1, (int)floor($cf * max(50, mk_int('dried_price_pct', 125)) / 100));
    }
    return $cap !== null ? max(1, min($base, $cap)) : $base;
}

/** v1.0.0: [shop_id, p = lowest price_min] for each shop that stocks an item (cached for the request; indexed on shop_stock.item_id). */
function shop_stock_rows(int $itemId): array
{
    static $cache = [];
    if ($itemId <= 0) return [];
    return $cache[$itemId] ??= q('SELECT shop_id, MIN(price_min) AS p FROM shop_stock WHERE item_id = ? AND price_min > 0 GROUP BY shop_id', [$itemId])->fetchAll();
}

/** v1.0.0: the cheapest price any shop charges this gnome (or a gnome with no discounts, when $u is null) for an item; null if no shop stocks it. */
function shop_buy_floor(int $itemId, ?array $u): ?int
{
    if ($itemId <= 0) return null;
    $rows = shop_stock_rows($itemId);
    if (!$rows) return null;
    $mult = market_buy_mult($itemId);
    $csv = function_exists('market_item_seasons') ? market_item_seasons($itemId) : null;
    if ($csv !== null && setting('price_drift_on') === '1') $mult = min($mult, (100 - max(0, min(30, mk_int('price_buy_season', 6)))) / 100);   // the in-season low
    $best = null;
    foreach ($rows as $r) {
        $p = (int)$r['p'];
        if ($u) {
            $p = charm_price($u, $p, true);
            if ($d = shop_discount_pct($u, (int)$r['shop_id'], $itemId)) $p = max(1, (int)round($p * (100 - $d) / 100));   // 2.7.58 EC3: the same discounts shop_price applies
            $p = mark_buy_price($u, $p, (int)$r['shop_id'], $itemId);   // and the same lasting marks
        }
        $p = max(1, (int)round($p * $mult));
        if ($best === null || $p < $best) $best = $p;
    }
    return $best;
}

/** v1.0.0: what a shop pays for one, with a Journey sell bonus on top, still never above the buy-back floor. */
function sell_price_with_bonus(array $item, ?array $u, int $bonusPct): int
{
    $p = (int)round(sell_price($item, $u) * (100 + $bonusPct) / 100);
    $cap = shop_buy_floor((int)($item['id'] ?? 0), $u);
    return $cap !== null ? max(1, min($p, $cap)) : $p;
}

/** v0.7.65: a finished Journey project can make a region's shops pay more (percent, 0 if none). */
function shop_sell_bonus(int $uid, int $shopId): int
{
    if ($shopId <= 0) return 0;
    $rid = (int)q_val('SELECT l.region_id FROM shops s JOIN locations l ON l.id = s.location_id WHERE s.id = ?', [$shopId]);
    if (!$rid) return 0;
    require_once __DIR__ . '/journey.php';
    return (int)(journey_benefit($uid, 'sell_bonus', $rid) ?? 0);
}

function sell_to_shop(array $u, int $itemId, int $qty, int $shopId = 0): array
{
    $item = q_one("SELECT * FROM items WHERE id = ? AND category IN ('produce','flower','food','part','forage','arrangement','packet')", [$itemId]);
    if (!$item) return [false, 'The shopkeeper isn’t interested in that.'];
    $qty = max(1, min(999, $qty));
    db()->beginTransaction();
    if (!give_item((int)$u['id'], $itemId, -$qty)) {
        db()->rollBack();
        return [false, 'You don’t have ' . $qty . ' × ' . $item['name'] . '.'];
    }
    // 2.7.58 EC9: priced in price_vol_units chunks, each chunk's sales lowering the price of the next, so a big batch pays what the same sales one by one would
    $bonus = shop_sell_bonus((int)$u['id'], $shopId);
    $chunk = max(1, mk_int('price_vol_units', 8));
    $total = 0;
    $mkCtx = mark_ctx_shop($shopId, $itemId);
    $mk = mark_fx((int)$u['id'], 'sell', $mkCtx);   // F01 lasting marks: on top of the batch, never past the buy-back floor
    $room = 0;
    for ($left = $qty; $left > 0; $left -= $chunk) {
        $n = min($chunk, $left);
        $each = sell_price_with_bonus($item, $u, $bonus);
        $total += $each * $n;
        if ($mk > 0) $room += (($cap = shop_buy_floor($itemId, $u)) === null ? $each : max(0, $cap - $each)) * $n;
        try { market_volume_add($itemId, $n); } catch (PDOException $e) { /* pressure is a nicety */ }   // v1.0.0: selling lots of one thing lowers its price a little
    }
    $total += min($room, mark_more($total, $mk));
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [$total, $u['id']]);
    $mkLine = implode('. ', array_filter(array_merge([mark_coins_line(mark_coins_on((int)$u['id'], 'first_sale_at_the_stops_stall', $mkCtx))],   // A4: a stall's first sale of the game day
        array_map(fn($l) => '🏅 ' . $l, mark_charge_lines(mark_charges_fire((int)$u['id'], 'first_sale_at_the_stops_stall', $mkCtx))))));   // A3: the stallholder adds something
    db()->commit();
    calling_event((int)$u['id'], 'sell', (string)$item['slug'], $qty, ['cat' => (string)$item['category'], 'coins' => $total]);   // v0.9.4 N6: sold to a shop
    return [true, "You sell $qty × {$item['name']} for " . number_format($total) . ' ' . setting('currency_name') . '.' . ($mkLine !== '' ? ' ' . $mkLine . '.' : ''), $total, (string)$item['name']];
}
