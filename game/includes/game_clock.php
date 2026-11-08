<?php
/**
 * Sleep-days: each gnome's personal game clock (design: claude/plan-sleep-days.md, section 13 and decisions 1-51).
 * users.game_day  = the day counter (+1 per sleep).
 * users.game_minute = minutes since 00:00 of the current game day (360 = 06:00 wake). May pass 1440 in a long action.
 * Nothing calls this yet; the real clock (hollow_clock.php) is unchanged.
 */

const GAME_WAKE_MINUTE = 360;    // 06:00
const GAME_TIRED_MINUTE = 1320;  // 22:00

/** Schema pieces for schema.php (same shape as here_schema()). */
function game_clock_schema(string $PK, string $ID, string $END): array
{
    return [[], [], [
        ['users', 'game_day', 'INT NOT NULL DEFAULT 0'], ['users', 'game_minute', 'INT NOT NULL DEFAULT ' . GAME_WAKE_MINUTE],
        ['cook_pots', 'ready_tick', 'INT NULL'],   // game tick (day*1440+minute) a game-clock pot is ready at; NULL = real ready_at
        ['dry_racks', 'ready_day', 'INT NULL'],     // game_day a drying bundle is ready on; NULL = real ready_at
        ['pantry_jars', 'ready_day', 'INT NULL'],   // game_day a game-clock jar is ready on; NULL = real ready_at
        ['users', 'carry_minutes', 'INT NOT NULL DEFAULT 0'],   // work left at 22:00 that finishes after the next sleep (decisions 43-44)
        ['users', 'pal_real_at', 'INT NULL'],   // unix time the pal clocks were last held still (real time must not move pal work)
        ['users', 'camp_naps', 'INT NOT NULL DEFAULT 0'],   // naps taken on the gear now in use (2 per gear)
        ['shops', 'open_minute', 'INT NULL'], ['shops', 'close_minute', 'INT NULL'],          // closing hours (decision 41); NULL = default_open/close_minute
        ['locations', 'open_minute', 'INT NULL'], ['locations', 'close_minute', 'INT NULL'],
        ['plot_tiles', 'grow_day', 'INT NULL'],    // the owner's game_day that growth is settled up to
        ['plot_tiles', 'water_day', 'INT NULL'],   // the owner's game_day the bed was last watered on
        ['plot_tiles', 'owed_days', 'INT NOT NULL DEFAULT 0'],   // dry days not yet grown; paid back when a watered day finishes (decision 54)
    ]];
}

/** Whole days from the season epoch to a 'Y-m-d' (the one-time start value for game_day). */
function game_clock_days_from_epoch(?string $today = null): int
{
    return max(0, hollow_day_number($today ?? hollow_today()) - hollow_day_number(hollow_season_epoch()));
}

/** [day, minute, tick, date, hour, dow, tired] for a users row. */
function gclock_state(array $u): array
{
    $day = max(0, (int)($u['game_day'] ?? 0));
    $min = max(0, (int)($u['game_minute'] ?? GAME_WAKE_MINUTE));
    $date = hollow_date_add(hollow_season_epoch(), $day);
    return [
        'day' => $day, 'minute' => $min, 'tick' => $day * 1440 + $min, 'date' => $date,
        'hour' => intdiv($min, 60) % 24, 'dow' => (int)gmdate('w', hollow_day_number($date) * 86400),
        'tired' => $min >= GAME_TIRED_MINUTE,
    ];
}

/** The 'Y-m-d' personal systems pass to hollow_season / weather. */
function hollow_game_date(array $u): string
{
    return gclock_state($u)['date'];
}

function game_is_tired(array $u): bool
{
    return gclock_state($u)['tired'];
}

/** Tired surcharge in percent: +tired_surcharge_pct_per_hour (default 10) per game hour past 22:00 (decision 34). */
function game_surcharge_pct(array $u): int
{
    $over = gclock_state($u)['minute'] - GAME_TIRED_MINUTE;
    if ($over < 0) return 0;
    $per = setting('tired_surcharge_pct_per_hour');
    return ((int)floor($over / 60) + 1) * ($per === '' ? 10 : max(0, (int)$per));   // 22:00-22:59 = 1 step, 23:00-23:59 = 2 ...
}

/** Energy cost with the tired surcharge (rounded up, never below the base). */
function game_energy_cost(array $u, int $base): int
{
    if ($base <= 0) return $base;
    return (int)ceil($base * (100 + game_surcharge_pct($u)) / 100);
}

/**
 * Can the gnome spend $minutes? Fails only when a place closes before the action ends (decision 17).
 * Being tired never blocks. Returns [ok, reason, tired_after, surcharge_pct].
 */
function game_can_spend(array $u, int $minutes, ?int $closesAt = null): array
{
    $s = gclock_state($u);
    $end = $s['minute'] + max(0, $minutes);
    if ($closesAt !== null && $end > $closesAt) return [false, 'closed', $end >= GAME_TIRED_MINUTE, game_surcharge_pct($u)];
    return [true, '', $end >= GAME_TIRED_MINUTE, game_surcharge_pct($u)];
}

/**
 * Spend game minutes. Atomic against a second tab: the update only applies if day and minute are still what we read.
 * Returns the new users-row fields ['game_day','game_minute'] or null when blocked or the race was lost.
 */
function game_spend(int $uid, int $minutes, ?int $closesAt = null): ?array
{
    $u = q('SELECT * FROM users WHERE id = ?', [$uid])->fetch();
    if (!$u) return null;
    [$ok] = game_can_spend($u, $minutes, $closesAt);
    if (!$ok) return null;
    $minutes = max(0, $minutes);
    $n = q('UPDATE users SET game_minute = game_minute + ? WHERE id = ? AND game_day = ? AND game_minute = ?',
        [$minutes, $uid, (int)$u['game_day'], (int)$u['game_minute']])->rowCount();
    if ($n !== 1) return null;
    gclock_plot_clock(0, true);
    return ['game_day' => (int)$u['game_day'], 'game_minute' => (int)$u['game_minute'] + $minutes];
}

/** Sleep: next day, 06:00, full energy. The caller checks the place (home, inn, town, camp). */
function game_sleep(int $uid, int $energyPct = 100): ?array
{
    $u = q('SELECT * FROM users WHERE id = ?', [$uid])->fetch();
    if (!$u) return null;
    $max = max_energy($u);
    $new = $energyPct >= 100 ? $max : max((int)$u['energy'], (int)floor($max * max(0, $energyPct) / 100));   // a weak rest never lowers energy
    $carry = max(0, (int)($u['carry_minutes'] ?? 0));   // unfinished work resumes first thing in the morning
    $n = q('UPDATE users SET game_day = game_day + 1, game_minute = ?, carry_minutes = 0, energy = ? WHERE id = ? AND game_day = ? AND game_minute = ?',
        [GAME_WAKE_MINUTE + $carry, $new, $uid, (int)$u['game_day'], (int)$u['game_minute']])->rowCount();
    if ($n !== 1) return null;
    gclock_plot_clock(0, true);
    game_new_day($uid);
    gclock_heal($u, $energyPct);   // a night's sleep heals as much as it restores energy (a bench heals less)
    return ['game_day' => (int)$u['game_day'] + 1, 'game_minute' => GAME_WAKE_MINUTE + $carry];
}

/** Nap: spend nap_minutes (default 120) and gain nap_energy_pct (default 40) of max energy; the day does not change (decision 42). */
function game_nap(int $uid): ?array
{
    $u = q('SELECT * FROM users WHERE id = ?', [$uid])->fetch();
    if (!$u) return null;
    $mins = setting('nap_minutes') === '' ? 120 : max(1, (int)setting('nap_minutes'));
    $pct = setting('nap_energy_pct') === '' ? 40 : max(0, min(100, (int)setting('nap_energy_pct')));
    $max = max_energy($u);
    $gain = (int)floor($max * $pct / 100);
    $n = q('UPDATE users SET game_minute = game_minute + ?, energy = CASE WHEN energy + CAST(? AS INTEGER) > CAST(? AS INTEGER) THEN CAST(? AS INTEGER) ELSE energy + CAST(? AS INTEGER) END WHERE id = ? AND game_day = ? AND game_minute = ?',
        [$mins, $gain, $max, $max, $gain, $uid, (int)$u['game_day'], (int)$u['game_minute']])->rowCount();
    if ($n !== 1) return null;
    gclock_plot_clock(0, true);
    gclock_heal($u, $pct);
    return ['game_day' => (int)$u['game_day'], 'game_minute' => (int)$u['game_minute'] + $mins];
}

// ---------------------------------------------------------------------------------------------------------------------
// Garden growth on game-days (decisions 12, 52, 53). Behind the setting game_clock_on (default off).
// ---------------------------------------------------------------------------------------------------------------------

/** SQL for "the game_day of the gnome who owns this tile's plot", for UPDATE plot_tiles ... SET grow_day = (...). */
const GCLOCK_OWNER_DAY_SQL = '(SELECT u.game_day FROM plots pl JOIN users u ON u.id = pl.user_id WHERE pl.id = plot_tiles.plot_id)';

function gclock_on(): bool
{
    return setting('game_clock_on') === '1';
}

/** The plot owner's game_day. Memoised per request; pass $reset after a sleep. */
function gclock_plot_day(int $plotId, bool $reset = false): int
{
    return gclock_plot_clock($plotId, $reset)[0];
}

/** [game_day, game_minute] of the plot owner. Memoised per request; every clock change (spend, nap, sleep) resets it. */
function gclock_plot_clock(int $plotId, bool $reset = false): array
{
    static $memo = [];
    if ($reset) { $memo = []; return [0, 0]; }
    if (!isset($memo[$plotId])) {
        $r = q_one('SELECT u.game_day, u.game_minute FROM plots pl JOIN users u ON u.id = pl.user_id WHERE pl.id = ?', [$plotId]);
        $memo[$plotId] = [(int)($r['game_day'] ?? 0), (int)($r['game_minute'] ?? GAME_WAKE_MINUTE)];
    }
    return $memo[$plotId];
}

/**
 * A "virtual clock" in UNIX seconds for the plot owner: the season epoch plus their game ticks. The no-till upkeep walk (bed_tick) and
 * its stored maint_at run on this, so the same code works on game time. At the one-time start it is close to the real clock.
 */
function gclock_plot_vnow(int $plotId): int
{
    [$d, $m] = gclock_plot_clock($plotId);
    return (int)strtotime(hollow_season_epoch() . ' 00:00:00 UTC') + $d * 86400 + $m * 60;
}

/** The plot owner's game date 'Y-m-d' (flag on), else the real Hollow date. Weather, pest checks and daily stamps of a garden use this. */
function gclock_plot_date(int $plotId): string
{
    return gclock_on() ? hollow_date_add(hollow_season_epoch(), gclock_plot_day($plotId)) : hollow_today();
}

/** Sleeps a plant needs, from its grow_minutes band (tiers 1-6: 15/40/90/180/360/720 min). Setting grow_days_by_tier, default 1,2,3,5,7,10. */
function gclock_grow_sleeps(array $p): int
{
    $days = array_map('intval', explode(',', setting('grow_days_by_tier') !== '' ? setting('grow_days_by_tier') : '1,2,3,5,7,10'));
    $days = array_pad($days, 6, end($days) ?: 1);
    $m = (int)$p['grow_minutes'];
    $tier = $m <= 20 ? 0 : ($m <= 60 ? 1 : ($m <= 120 ? 2 : ($m <= 240 ? 3 : ($m <= 480 ? 4 : 5))));
    return max(1, $days[$tier]);
}

/**
 * Settle a bed's growth up to its owner's game_day. Each finished game-day counts if the bed was watered that day (water_day) or it rained,
 * and adds one sleep's share of growth_seconds (grow_minutes*60 / sleeps) times soil speed and that day's season/weather.
 * growth_seconds keeps its old scale, so everything that reads it (ready, percent, harvest) is unchanged.
 */
function gclock_tile_grow(array $t, ?array $p, ?int $today = null): array
{
    if (empty($t['plant_id']) || !$p) return $t;
    $today ??= gclock_plot_day((int)$t['plot_id']);
    $from = $t['grow_day'] === null || $t['grow_day'] === '' ? $today : (int)$t['grow_day'];
    $need = max(1, (int)$p['grow_minutes'] * 60);
    $sleeps = gclock_grow_sleeps($p);
    $share = $need / $sleeps;
    $owed = max(0, (int)($t['owed_days'] ?? 0));
    $gs = (int)$t['growth_seconds'];
    $base = soil_speed($t);
    $slowPest = !empty($t['pest']) ? max(0, min(90, (int)setting('pest_slow_pct'))) / 100 : 0.0;
    $water = ($t['water_day'] ?? null) === null || ($t['water_day'] ?? '') === '' ? null : (int)$t['water_day'];
    $epoch = hollow_season_epoch();
    $carryPct = gclock_water_carry_pct($t, $p);
    $n = 0;
    for ($d = $from; $d < $today && $n++ < 60; $d++) {
        $fx = garden_day_fx($t, $p, hollow_date_add($epoch, $d));
        $carried = $water !== null && $water === $d - 1 && $carryPct > 0 && hollow_unit('carry|' . $t['id'] . '|' . $d) * 100 < $carryPct;   // rain barrel, shade and the like make a watering last into the next day
        if ($water !== $d && !$carried && empty($fx['wet'])) { $owed = min($owed + 1, $sleeps); continue; }   // a dry day is owed, not lost
        $days = 1 + $owed;
        $owed = 0;
        $gs += (int)($share * $days * $base * $fx['speed'] * (1 - $slowPest));
        if (!empty($fx['nip'])) $t['nipped'] = 1;
    }
    $t['growth_seconds'] = min($gs, $need);
    $t['grow_day'] = $today;
    $t['owed_days'] = $owed;
    return $t;
}

// ---------------------------------------------------------------------------------------------------------------------
// Where a gnome can rest (decisions 21-25, 26-28, 30-33). Settings: inn_fee_petals 110, inn_chore_minutes 240,
// bench_sleep_energy_pct 30, villager_sleep_friend_level 3 (index in FRIEND_LEVELS), camping_gear_nap_charges 2.
// ---------------------------------------------------------------------------------------------------------------------

function gclock_setting_int(string $name, int $default): int
{
    $v = setting($name);
    return $v === '' ? $default : (int)$v;
}

/** The camping gear item id (made on first use; sold and crafted later). */
function gclock_gear_item_id(): int
{
    gclock_ensure_camping();
    return (int)item_id_by_slug('camping-gear');
}

/** Parts of camping gear (decision 50), their base prices chosen so crafting the gear costs about 60 Petals against 100 in a shop (decision 31). */
const GCLOCK_CAMP_ITEMS = [
    'canvas-sheet' => ['Canvas Sheet', 'A stiff sheet of waxed canvas. Becomes a tent roof.', 8],
    'metal-pins' => ['Metal Pins', 'Short iron tent pins, hammered flat at one end.', 1],
    'camping-pot' => ['Camping Pot', 'A small blackened pot with a bail handle. Fits a fire and a pack.', 8],
    'camping-gear' => ['Camping Gear', 'Rope, pins, canvas, planks and a little pot. Two naps on the road, or one night.', 100],
];

/** Make the camping items if missing, and put the gear on sale in the Home & curios (decor) shops. Safe to call often. */
function gclock_ensure_camping(): void
{
    static $done = false;
    if ($done) return;
    foreach (GCLOCK_CAMP_ITEMS as $slug => [$name, $desc, $price]) {
        if (!item_id_by_slug($slug)) db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => 'part', 'rarity' => 20, 'base_price' => $price, 'description' => $desc, 'edible' => 0, 'tradable' => 1]);
    }
    $done = true;
    $gear = (int)item_id_by_slug('camping-gear');
    if (!$gear) return;
    $price = gclock_setting_int('camping_gear_price', 100);
    foreach (q("SELECT id FROM shops WHERE open = 1 AND shop_type = 'decor'")->fetchAll(PDO::FETCH_COLUMN) as $shopId) {
        if (q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shopId, $gear])) continue;
        db_insert('shop_stock', ['shop_id' => $shopId, 'item_id' => $gear, 'price_min' => $price, 'price_max' => $price, 'max_stock' => 3, 'restock_chance' => 40, 'current_stock' => 1, 'current_price' => $price]);
    }
}

/**
 * What the gnome can do to rest right now. Each option: ['key','label','kind' => sleep|nap,'cost' => text,'ok' => bool,'why' => text].
 * Where: 'road' (on a trail), 'home' (in the home village), 'town' (any other village).
 */
function gclock_rest_options(array $u): array
{
    $uid = (int)$u['id'];
    $out = [];
    $opt = function (string $key, string $label, string $kind, string $cost, bool $ok = true, string $why = '') use (&$out) {
        $out[] = ['key' => $key, 'label' => $label, 'kind' => $kind, 'cost' => $cost, 'ok' => $ok, 'why' => $why];
    };
    $nap = gclock_setting_int('nap_minutes', 120) / 60;
    $napPct = gclock_setting_int('nap_energy_pct', 40);
    if (function_exists('active_expedition') && active_expedition($uid)) {
        $gear = gclock_gear_item_id();
        $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $gear]);
        $why = $have > 0 ? '' : 'You need camping gear.';
        $opt('camp_sleep', 'Camp for the night', 'sleep', 'uses up your camping gear', $have > 0, $why);
        $opt('camp_nap', 'Nap at camp (' . $nap . ' h, +' . $napPct . '% energy)', 'nap', $u['camp_naps'] > 0 ? 'last nap on this gear' : '1 of ' . gclock_setting_int('camping_gear_nap_charges', 2) . ' naps on a gear', $have > 0, $why);
        return $out;
    }
    $home = (int)($u['location_id'] ?? 0) === 0 || (int)$u['location_id'] === (int)($u['home_village_id'] ?? 0);
    if ($home) {
        $opt('home_sleep', 'Sleep in your hovel', 'sleep', 'free');
        $opt('home_nap', 'Nap in your hovel (' . $nap . ' h, +' . $napPct . '% energy)', 'nap', 'free');
        return $out;
    }
    $fee = gclock_setting_int('inn_fee_petals', 110);
    $chore = gclock_setting_int('inn_chore_minutes', 240);
    $opt('inn_pay', 'Rent a room at the inn', 'sleep', $fee . ' ' . setting('currency_name'), (int)$u['coins'] >= $fee, 'Not enough ' . setting('currency_name') . '.');
    $opt('inn_chores', 'Help around the inn for a bed', 'sleep', ($chore / 60) . ' game hours of chores');
    $opt('bench', 'Sleep on a bench in the park', 'sleep', 'free, only ' . gclock_setting_int('bench_sleep_energy_pct', 30) . '% energy back');
    $opt('bench_nap', 'Nap on a bench (' . $nap . ' h, +' . $napPct . '% energy)', 'nap', 'free');
    $need = gclock_setting_int('villager_sleep_friend_level', 4);
    $host = null;
    if (function_exists('friend_level')) {
        foreach (q('SELECT n.name, f.points FROM npcs n JOIN npc_friends f ON f.npc_id = n.id AND f.user_id = ? WHERE n.home_location_id = ?', [$uid, (int)$u['location_id']])->fetchAll() as $r) {
            if (friend_level((int)$r['points'])['index'] >= $need) { $host = $r['name']; break; }
        }
    }
    $opt('villager', $host ? 'Stay with ' . $host : 'Stay with a friendly villager', 'sleep', 'free', $host !== null, 'A villager here must be a ' . (FRIEND_LEVELS[$need][1] ?? 'closer friend') . ' first.');
    return $out;
}

/** Do one rest option. Returns [ok, message]. Pays costs; refuses if the option is not on offer. */
function gclock_rest(int $uid, string $key, int $campRecipe = 0): array
{
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    if (!$u) return [false, 'No such gnome.'];
    $found = null;
    foreach (gclock_rest_options($u) as $o) if ($o['key'] === $key) $found = $o;
    if (!$found) return [false, 'You can’t rest that way here.'];
    if (!$found['ok']) return [false, $found['why'] ?: 'Not right now.'];
    $pre = ['recipe' => null];
    if ($campRecipe > 0 && str_starts_with($key, 'camp_')) {
        $pre = gclock_camp_check($u, $campRecipe);   // decision 32/49: one pot at camp, ready when you wake
        if ($pre['error'] ?? '') return [false, $pre['error']];
    }
    $res = gclock_rest_do($uid, $key, $u);
    if ($res[0] && !empty($pre['recipe'])) $res[1] .= ' ' . gclock_camp_cook($uid, $pre['recipe']);
    return $res;
}

/** Check a camp meal before resting: a known cooking recipe, a free pot and the ingredients. Returns ['recipe' => row] or ['error' => text]. */
function gclock_camp_check(array $u, int $recipeId): array
{
    require_once __DIR__ . '/crafting.php';
    $uid = (int)$u['id'];
    $r = q_one("SELECT * FROM recipes WHERE id = ? AND category = 'cooking'", [$recipeId]);
    if (!$r || !q_val('SELECT 1 FROM user_recipes WHERE user_id = ? AND recipe_id = ?', [$uid, $recipeId])) return ['error' => 'You don’t know that camp meal.'];
    $energy = craft_energy_cost($u, 'cooking', (int)$r['energy'], (string)($r['tier'] ?: 'meal'));
    if (craft_fit(craft_stock($uid, (string)$r['ingredients']), $energy, (int)$u['energy']) < 1) return ['error' => 'You are missing something for that camp meal (ingredients or energy).'];
    return ['recipe' => $r];
}

/** After the rest: start the pot, ready at once (it cooked while you slept). */
function gclock_camp_cook(int $uid, array $r): string
{
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    [$ok, $msg, $info] = cook_start($u, $r, 1, 1, true);
    if (!$ok) return 'The camp meal did not work out: ' . $msg;
    foreach ($info['ids'] as $id) q('UPDATE cook_pots SET ready_tick = ?, ready_at = ? WHERE id = ?', [gclock_user_tick($uid), now(), $id]);
    return '🍲 Your camp meal is ready to collect.';
}

function gclock_rest_do(int $uid, string $key, array $u): array
{
    switch ($key) {
        case 'home_sleep': case 'villager':
            return game_sleep($uid) ? [true, 'You sleep soundly. A new day: energy full.'] : [false, 'Something stirred. Try again.'];
        case 'home_nap': case 'bench_nap':
            return game_nap($uid) ? [true, 'You nap a while and feel a little better.'] : [false, 'Something stirred. Try again.'];
        case 'bench':
            return game_sleep($uid, gclock_setting_int('bench_sleep_energy_pct', 30)) ? [true, 'A stiff night on the bench. A new day, a little rested.'] : [false, 'Something stirred. Try again.'];
        case 'inn_pay':
            $fee = gclock_setting_int('inn_fee_petals', 110);
            if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$fee, $uid, $fee])->rowCount() !== 1) return [false, 'Not enough ' . setting('currency_name') . '.'];
            if (!game_sleep($uid)) { q('UPDATE users SET coins = coins + ? WHERE id = ?', [$fee, $uid]); return [false, 'Something stirred. Try again.']; }
            return [true, 'A proper bed. A new day: energy full.'];
        case 'inn_chores':
            if (!game_spend($uid, gclock_setting_int('inn_chore_minutes', 240))) return [false, 'Something stirred. Try again.'];
            return game_sleep($uid) ? [true, 'You swept and stacked all evening, then slept well. A new day: energy full.'] : [false, 'Something stirred. Try again.'];
        case 'camp_sleep': case 'camp_nap':
            $gear = gclock_gear_item_id();
            if (!give_item($uid, $gear, -1)) return [false, 'You need camping gear.'];   // taken now; a nap with a charge left gives it back below
            if ($key === 'camp_sleep') {
                q('UPDATE users SET camp_naps = 0 WHERE id = ?', [$uid]);
                return game_sleep($uid) ? [true, 'You camp under the stars. A new day: energy full.'] : [false, 'Something stirred. Try again.'];
            }
            $charges = gclock_setting_int('camping_gear_nap_charges', 2);
            $used = (int)$u['camp_naps'] + 1;
            if ($used < $charges) { give_item($uid, $gear, 1); q('UPDATE users SET camp_naps = ? WHERE id = ?', [$used, $uid]); }
            else q('UPDATE users SET camp_naps = 0 WHERE id = ?', [$uid]);   // the last nap uses the gear up
            return game_nap($uid) ? [true, 'You nap at camp and feel a little better.'] : [false, 'Something stirred. Try again.'];
    }
    return [false, 'Unknown rest.'];
}

// ---------------------------------------------------------------------------------------------------------------------
// Cook pots on the game clock (decision 45: 4x longer, ready_tick). A pot made under game_clock_on has ready_tick; old pots
// and pal-tended pots keep ready_at (real time).
// ---------------------------------------------------------------------------------------------------------------------

/** The gnome's game tick (day*1440 + minute). */
function gclock_user_tick(int $uid): int
{
    $r = q_one('SELECT game_day, game_minute FROM users WHERE id = ?', [$uid]);
    return $r ? gclock_state($r)['tick'] : 0;
}

/** Real seconds of cooking -> game minutes (cook_time_multiplier, default 4). */
function gclock_pot_minutes(int $secs): int
{
    return max(1, (int)ceil($secs / 60) * max(1, gclock_setting_int('cook_time_multiplier', 4)));
}

/** SQL + params for "this pot is ready" (columns of cook_pots, no alias). */
function gclock_pot_ready(int $uid): array
{
    return ['((ready_tick IS NOT NULL AND ready_tick <= ?) OR (ready_tick IS NULL AND ready_at <= ?))', [gclock_user_tick($uid), now()]];
}

// Pantry jars: ready after N sleeps (decision 12). A jar's real cook_minutes are read as real days: 1 day = 1 sleep.

function gclock_jar_days(array $recipe): int
{
    return max(1, (int)ceil(max(0, (int)$recipe['cook_minutes']) / 1440));
}

/** SQL + params for "this jar is ready" (columns of pantry_jars, no alias). */
function gclock_jar_ready(int $uid): array
{
    $r = q_one('SELECT game_day FROM users WHERE id = ?', [$uid]);
    return ['((ready_day IS NOT NULL AND ready_day <= ?) OR (ready_day IS NULL AND ready_at <= ?))', [(int)($r['game_day'] ?? 0), now()]];
}

// ---------------------------------------------------------------------------------------------------------------------
// The one new-day hook (decision 56). Pal jobs keep their real-time code; a sleep moves their clocks forward instead.
// ---------------------------------------------------------------------------------------------------------------------

/** Called once after every sleep. Only does anything while game_clock_on is 1. */
function game_new_day(int $uid): void
{
    if (!gclock_on()) return;
    gclock_freeze_pals($uid);
    $h = gclock_setting_int('pal_hours_per_sleep', 8);
    if ($h > 0) gclock_shift_pal_clocks($uid, $h * 3600);
}

/**
 * Pal work runs on game time only (Josh, 2026-11-08): real seconds since the last look are pushed back onto every running job and
 * pal-tended pot, so only sleeps (and nothing else) bring them closer to done. Cheap, safe to call often. First call only stamps the time.
 */
function gclock_freeze_pals(int $uid): void
{
    if (!gclock_on()) return;
    $last = q_val('SELECT pal_real_at FROM users WHERE id = ?', [$uid]);
    $t = time();
    if ($last === null || $last === false || $last === '') { q('UPDATE users SET pal_real_at = ? WHERE id = ? AND pal_real_at IS NULL', [$t, $uid]); return; }
    $d = $t - (int)$last;
    if ($d < 1) return;
    if (q('UPDATE users SET pal_real_at = ? WHERE id = ? AND pal_real_at = ?', [$t, $uid, (int)$last])->rowCount() !== 1) return;   // another tab got it
    gclock_shift_pal_clocks($uid, -$d);
}

/**
 * Move a gnome's running pal work $secs closer to done: active jobs get started_at, ends_at and last_tick earlier (so progress,
 * passive ticks and the end time all jump ahead), and pots a pal tends get their start and ready time earlier.
 * Pal-tended pots are not on the gnome's tick because a pal's cooking is checked by the real-time job code.
 */
function gclock_shift_pal_clocks(int $uid, int $secs): void
{
    foreach (q("SELECT id, started_at, ends_at, last_tick FROM ppal_jobs WHERE user_id = ? AND state = 'active'", [$uid])->fetchAll() as $j) {
        $sh = fn($v) => $v === null || $v === '' ? $v : gmdate('Y-m-d H:i:s', (int)strtotime($v . ' UTC') - $secs);
        q('UPDATE ppal_jobs SET started_at = ?, ends_at = ?, last_tick = ? WHERE id = ?', [$sh($j['started_at']), $sh($j['ends_at']), $sh($j['last_tick']), $j['id']]);
    }
    foreach (q('SELECT id, started_at, ready_at FROM cook_pots WHERE user_id = ? AND collected_at IS NULL AND pal_uid IS NOT NULL', [$uid])->fetchAll() as $p) {
        $sh = fn($v) => $v === null || $v === '' ? $v : gmdate('Y-m-d H:i:s', (int)strtotime($v . ' UTC') - $secs);
        q('UPDATE cook_pots SET started_at = ?, ready_at = ? WHERE id = ?', [$sh($p['started_at']), $sh($p['ready_at']), $p['id']]);
    }
}

// ---------------------------------------------------------------------------------------------------------------------
// Time costs (plan section 11, decision 48). Only actions of 10+ game minutes cost time. Setting time_<key> overrides.
// ---------------------------------------------------------------------------------------------------------------------

const GCLOCK_TIME_DEFAULTS = [
    'travel' => 10,        // per trail section
    'wander' => 20, 'gather' => 10, 'craft' => 15,   // craft is per unit
    'arrange' => 10, 'seed' => 10, 'shift' => 480, 'sapling' => 10, 'tend' => 10, 'repair' => 480,
    'lair' => 120, 'landmark' => 20, 'stop' => 15, 'water_other' => 10,
];

/** Game minutes one unit of an action costs (0 = free). */
function gclock_time_cost(string $key): int
{
    $v = setting('time_' . $key);
    return $v === '' ? (GCLOCK_TIME_DEFAULTS[$key] ?? 0) : max(0, (int)$v);
}

/** Spend the game time for an action, after its energy was paid. Does nothing while game_clock_on is 0. Never blocks (being tired never blocks). */
function gclock_charge(int $uid, string $key, int $units = 1): void
{
    if (!gclock_on()) return;
    $m = gclock_time_cost($key) * max(1, $units);
    if ($m <= 0) return;
    gclock_ledger_snap($uid);
    if (in_array($key, GCLOCK_SPLIT_KEYS, true)) { gclock_charge_split($uid, $m); return; }
    game_spend($uid, $m);
}

/** Long actions that may run past 22:00 and finish after the next sleep (decision 43). */
const GCLOCK_SPLIT_KEYS = ['shift', 'repair'];

/**
 * Spend $m minutes; whatever would pass 22:00 is carried to the morning instead (no tired surcharge on it) and the gnome is busy
 * until they sleep (decision 44). Returns the carried minutes.
 */
function gclock_charge_split(int $uid, int $m): int
{
    $u = q_one('SELECT game_day, game_minute, carry_minutes FROM users WHERE id = ?', [$uid]);
    if (!$u) return 0;
    $now = (int)$u['game_minute'];
    $today = max(0, GAME_TIRED_MINUTE - $now);          // minutes left before 22:00
    $spendNow = min($m, $today);
    $carry = $m - $spendNow;
    q('UPDATE users SET game_minute = game_minute + ?, carry_minutes = carry_minutes + ? WHERE id = ? AND game_day = ? AND game_minute = ?',
        [$spendNow, $carry, $uid, (int)$u['game_day'], $now]);
    return $carry;
}

/** Minutes of work still waiting for the next sleep (0 = free to act). */
function gclock_busy_minutes(int $uid): int
{
    return gclock_on() ? max(0, (int)q_val('SELECT carry_minutes FROM users WHERE id = ?', [$uid])) : 0;
}

// ---------------------------------------------------------------------------------------------------------------------
// Closing hours (decisions 17, 41). A shop or stop row may carry open_minute / close_minute; blank = settings
// default_open_minute (360 = 06:00) and default_close_minute (1320 = 22:00). Inns are open all night and never call this.
// ---------------------------------------------------------------------------------------------------------------------

/** [open, close] minutes of the day for a shop / location row (null row = the defaults). */
function gclock_place_hours(?array $row): array
{
    $o = $row['open_minute'] ?? null;
    $c = $row['close_minute'] ?? null;
    $do = setting('default_open_minute');
    $dc = setting('default_close_minute');
    return [
        ($o !== null && $o !== '') ? (int)$o : ($do === '' ? GAME_WAKE_MINUTE : (int)$do),
        ($c !== null && $c !== '') ? (int)$c : ($dc === '' ? GAME_TIRED_MINUTE : (int)$dc),
    ];
}

/**
 * Null when the place is open for an action of $minutes starting now, else a short reason. Flag off = always open.
 * $mayRunLate (split actions, decision 43): only the start must be inside opening hours.
 */
function gclock_closed_reason(array $u, ?array $row, int $minutes = 0, bool $mayRunLate = false): ?string
{
    if (!gclock_on()) return null;
    [$open, $close] = gclock_place_hours($row);
    $now = gclock_state($u)['minute'];
    $fmt = fn(int $m): string => sprintf('%02d:%02d', intdiv($m, 60) % 24, $m % 60);
    if ($now < $open) return 'Closed for now. It opens at ' . $fmt($open) . '.';
    if ($now >= $close) return 'Closed for the day. Come back after you sleep (it opens at ' . $fmt($open) . ').';
    if (!$mayRunLate && $minutes > 0 && $now + $minutes > $close) return 'Too late to start that here: it closes at ' . $fmt($close) . '.';
    return null;
}

// ---------------------------------------------------------------------------------------------------------------------
// The logged-in gnome's own date / hour / weekday, for personal systems (NPC chat and gifts, stop limits, errands, festivals,
// NPC schedules). Flag off, or no logged-in gnome (cron, guests of shared pages): the real Hollow clock, exactly as before.
// ---------------------------------------------------------------------------------------------------------------------

/** gclock_state() of the logged-in gnome, read fresh; null when the flag is off or nobody is logged in. */
function gclock_me(): ?array
{
    if (!gclock_on() || !($cu = current_user()) || empty($cu['id'])) return null;
    $u = q_one('SELECT game_day, game_minute FROM users WHERE id = ?', [(int)$cu['id']]);
    return $u ? gclock_state($u) : null;
}

function gclock_my_date(): string
{
    $s = gclock_me();
    return $s ? $s['date'] : hollow_date('Y-m-d');
}

function gclock_my_hour(): int
{
    $s = gclock_me();
    return $s ? $s['hour'] : hollow_hour();
}

function gclock_my_dow(): int
{
    $s = gclock_me();
    return $s ? $s['dow'] : hollow_dow();
}

/** The weather the logged-in gnome sees now: their own game day (admin force reaches it) with the flag on, else the real weather. */
function gclock_my_weather(?string $region = null): string
{
    if (!gclock_me()) return hollow_weather($region);
    return hollow_weather_forced() ?: hollow_weather($region, gclock_my_date());
}

/** The little clock pill for the status strip: game time, day number, tired mark. Links to the Rest page. */
function gclock_pill(array $u, bool $line = false): string
{
    $s = gclock_state($u);
    $t = sprintf('%02d:%02d', intdiv($s['minute'], 60) % 24, $s['minute'] % 60);
    $carry = max(0, (int)($u['carry_minutes'] ?? 0));
    $title = 'Day ' . $s['day'] . ', ' . $t . ($s['tired'] ? ' (tired: +' . game_surcharge_pct($u) . '% energy)' : '') . ($carry > 0 ? '; ' . round($carry / 60, 1) . ' h of work waits for tomorrow' : '') . '. Open the Rest page to nap or sleep.';
    if ($line) return '<a class="stl gclkl' . ($s['tired'] ? ' tired' : '') . '" href="' . e(url('hovel.php')) . '" title="' . e($title) . '">🕐 <b>' . $t . '</b> <small>day ' . $s['day'] . '</small>' . ($s['tired'] ? ' 😴' : '') . '</a>';
    return '<span class="st gclk' . ($s['tired'] ? ' tired' : '') . '" title="' . e($title) . '"><a href="' . e(url('hovel.php')) . '">🕐 <b>' . $t . '</b> <small>day ' . $s['day'] . '</small>' . ($s['tired'] ? ' 😴' : '') . '</a></span>';
}

// Drying racks: like pantry jars, ready after N sleeps (the real dry_hours read as days, minimum 1).
function gclock_rack_days(): int
{
    return max(1, (int)ceil(max(1, (int)setting('dry_hours')) / 24));
}

/** SQL + params for "this bundle is ready" (columns of dry_racks, no alias). */
function gclock_rack_ready(int $uid): array
{
    $day = (int)q_val('SELECT game_day FROM users WHERE id = ?', [$uid]);
    return ['((ready_day IS NOT NULL AND ready_day <= ?) OR (ready_day IS NULL AND ready_at <= ?))', [$day, now()]];
}

/** The gnome's game tick when the flag is on, else null (stored beside real timestamps so each can be read by the right clock). */
function gclock_tick_or_null(int $uid): ?int
{
    return gclock_on() ? gclock_user_tick($uid) : null;
}

/** Admin settings for sleep-days, merged into settings_schema(). Every default is what the code already uses when the setting is blank. */
function gclock_settings(): array
{
    $i = fn(string $label, int $d, int $min = 0, int $max = 100000): array => ['label' => 'Sleep-days: ' . $label, 'type' => 'int', 'default' => (string)$d, 'min' => $min, 'max' => $max];
    $out = [
        'game_clock_on' => ['label' => 'Sleep-days: ON (each gnome has their own game clock; energy comes back by sleeping; garden, jars, pots, jobs, NPCs and festivals follow it). Do not turn on before the start step is done.', 'type' => 'bool', 'default' => '1'],
        'nap_minutes' => $i('a nap takes this many game minutes', 120, 10, 480),
        'nap_energy_pct' => $i('a nap gives this % of max energy', 40, 0, 100),
        'tired_surcharge_pct_per_hour' => $i('extra energy cost per game hour past 22:00 (%)', 10, 0, 100),
        'bench_sleep_energy_pct' => $i('a night on a bench gives this % of max energy', 30, 0, 100),
        'inn_fee_petals' => $i('inn room price (Petals)', 110, 0, 100000),
        'inn_chore_minutes' => $i('inn chores for a bed take this many game minutes', 240, 0, 960),
        'villager_sleep_friend_level' => $i('villager lets you sleep over from this friendship level (0 = first, 4 = best)', 4, 0, 6),
        'camping_gear_nap_charges' => $i('camping gear: naps per gear (a full sleep uses it up)', 2, 1, 10),
        'camping_gear_price' => $i('camping gear shop price (Petals)', 100, 1, 100000),
        'cook_time_multiplier' => $i('cooking pots take this many times longer on the game clock', 4, 1, 100),
        'job_month_days' => $i('a job-board month is this many sleeps', 28, 7, 120),
        'pal_hours_per_sleep' => $i('pal jobs and pots advance this many hours per sleep', 8, 0, 24),
        'npc_away_pct' => $i('chance a villager is away on a given game day (no chat or gift that day), %', 25, 0, 90),
        'default_open_minute' => $i('shops and stops open at this minute of the day (360 = 06:00)', 360, 0, 1439),
        'default_close_minute' => $i('shops and stops close at this minute of the day (1320 = 22:00)', 1320, 1, 1440),
        'hp_crop_heal' => ['label' => 'Sleep-days: health from eating a crop: everyday, uncommon or flower, treasure, legendary (four numbers, comma separated)', 'type' => 'text', 'default' => '1,2,3,4'],
        'hp_dish_heal' => ['label' => 'Sleep-days: health from a home-cooked snack, meal, feast (three numbers; bought food gives 1)', 'type' => 'text', 'default' => '2,3,4'],
        'amend_game_multiplier' => $i('soil improvers (compost etc.) take their listed minutes times this to work in, in game minutes (96 turns 15 minutes into one sleep); the nutrients are released over the same time', 96, 1, 2000),
        'mulch_game_multiplier' => $i('mulch cover lasts its listed hours times this, in game hours (24 game hours = one sleep; 1 = straw lasts 6 sleeps)', 1, 1, 50),
        'grow_days_by_tier' => ['label' => 'Sleep-days: sleeps a crop needs for growth tiers 1-6 (six numbers, comma separated)', 'type' => 'text', 'default' => '1,2,3,5,7,10'],
    ];
    foreach (GCLOCK_TIME_DEFAULTS as $k => $m) $out['time_' . $k] = $i('game minutes an action costs: ' . $k . ' (0 = free)', $m, 0, 1440);
    return $out;
}

/**
 * THE ONE-TIME START (run only when Josh says; nothing calls it). Puts a gnome's game date on today's Hollow date (so festival windows,
 * stop_log days and seasons line up at the moment the flag is turned on) at 06:00, and clears any carried work.
 * Returns the number of gnomes changed. Safe to run twice (it sets, it does not add).
 */
function gclock_start_all(?string $today = null): int
{
    $day = game_clock_days_from_epoch($today);
    return q('UPDATE users SET game_day = ?, game_minute = ?, carry_minutes = 0, camp_naps = 0', [$day, GAME_WAKE_MINUTE])->rowCount();
}

// Health (Josh, 2026-11-08): no timed healing. Sleep and naps heal the same % as the energy they give; potions as before;
// food from the garden heals a little (hp_crop_heal: everyday, uncommon or flower, treasure, legendary = 1,2,3,4).

/** Heal a gnome by $pct of max health (sleep, nap). No-op when health is off. */
function gclock_heal(array $u, int $pct): int
{
    require_once __DIR__ . '/health.php';
    return $pct > 0 ? hp_heal_pct($u, min(100, $pct)) : 0;
}

/** Health a raw crop or find gives when eaten: 0 for anything that is not produce. */
function gclock_crop_heal(array $item): int
{
    if (($item['category'] ?? '') !== 'produce') return 0;
    $v = array_map('intval', array_pad(array_map('trim', explode(',', setting('hp_crop_heal') !== '' ? setting('hp_crop_heal') : '1,2,3,4')), 4, '1'));
    $plant = q_one('SELECT id, kind FROM plants WHERE produce_item_id = ?', [(int)$item['id']]);
    if (!$plant) return max(0, $v[0]);
    $tiers = q('SELECT tier FROM plant_regions WHERE plant_id = ?', [(int)$plant['id']])->fetchAll(PDO::FETCH_COLUMN);
    $rank = ['staple' => 0, 'flower' => 1, 'uncommon' => 1, 'treasure' => 2];
    $band = $tiers ? min(array_map(fn($t) => $rank[$t] ?? 0, $tiers)) : ($plant['kind'] === 'flower' ? 1 : 0);
    if ($band === 2 && (int)($item['rarity'] ?? 0) >= 80) $band = 3;   // a legendary crop
    return max(0, $v[$band]);
}

/** The value to store in plot_tiles.maint_at "now": the owner's virtual game time with the flag on, else the real time. */
function gclock_maint_now(int $plotId): string
{
    return gclock_on() ? gmdate('Y-m-d H:i:s', gclock_plot_vnow($plotId)) : now();
}

/** Health any food gives when eaten (Josh, decision 58): crops 1-4, finds by rarity, home-cooked snack/meal/feast (hp_dish_heal 2,3,4), bought food 1. */
function gclock_food_heal(array $item): int
{
    $cat = (string)($item['category'] ?? '');
    if ($cat === 'produce') return gclock_crop_heal($item);
    $v = array_map('intval', array_pad(array_map('trim', explode(',', setting('hp_crop_heal') !== '' ? setting('hp_crop_heal') : '1,2,3,4')), 4, '1'));
    if ($cat === 'forage') {
        $r = (int)($item['rarity'] ?? 0);
        return max(0, $v[$r >= 80 ? 3 : ($r >= 45 ? 2 : ($r >= 20 ? 1 : 0))]);
    }
    if ($cat === 'supply' || empty($item['edible'])) return 0;   // potions heal by their own rule
    $tier = (string)home_dish_tier((int)$item['id']);
    if ($tier === '' || strncmp((string)$item['slug'], 'bought-', 7) === 0) return 1;
    $d = array_map('intval', array_pad(array_map('trim', explode(',', setting('hp_dish_heal') !== '' ? setting('hp_dish_heal') : '2,3,4')), 3, '3'));
    return max(0, $d[['snack' => 0, 'meal' => 1, 'feast' => 2][$tier] ?? 1]);
}

/** The owner's "now" in UNIX seconds for a plot: the virtual game clock with the flag, else the real time. For settle_until and similar stamps. */
function gclock_plot_now(int $plotId): int
{
    return gclock_on() && $plotId > 0 ? gclock_plot_vnow($plotId) : time();
}

/** "about 1 sleep" / "3 sleeps" for a span of game minutes (1440 = one sleep), for labels that used to say minutes. */
function gclock_sleeps_text(int $minutes): string
{
    if ($minutes < 1440) return $minutes . ' game min';
    $n = (int)ceil($minutes / 1440);
    return $n . ' sleep' . ($n === 1 ? '' : 's');
}

// ---------------------------------------------------------------------------------------------------------------------
// The cost ledger: every energy point and game minute spent during a request is added up and shown to the player once, as
// "⚡ −3 · 🕐 +15 min (now 14:35)". Nothing is hidden: if it cost something, the page says so.
// ---------------------------------------------------------------------------------------------------------------------

/** Remember a gnome's energy and clock before this request first changes them. The summary is the difference at the end, so an action that rolls back shows nothing. */
function gclock_ledger_snap(int $uid): void
{
    if (!gclock_on() || isset($GLOBALS['gclock_ledger'][$uid])) return;
    $r = q_one('SELECT energy, game_day, game_minute, carry_minutes FROM users WHERE id = ?', [$uid]);
    if ($r) $GLOBALS['gclock_ledger'][$uid] = ['energy' => (int)$r['energy'], 'day' => (int)$r['game_day'], 'tick' => (int)$r['game_day'] * 1440 + (int)$r['game_minute'], 'carry' => (int)$r['carry_minutes']];
}

/** The one-line summary text for a tally, or '' when nothing was spent. $nowMinute = the clock afterwards. */
function gclock_cost_line(int $energy, int $minutes, ?int $nowMinute = null, int $carry = 0): string
{
    $bits = [];
    if ($energy > 0) $bits[] = '⚡ −' . $energy . ' energy';
    if ($minutes > 0) {
        $h = intdiv($minutes, 60);
        $span = $h > 0 ? $h . ' h' . ($minutes % 60 ? ' ' . ($minutes % 60) . ' min' : '') : $minutes . ' min';
        $bits[] = '🕐 +' . $span . ($nowMinute !== null ? ' (now ' . sprintf('%02d:%02d', intdiv($nowMinute, 60) % 24, $nowMinute % 60) . ')' : '');
    }
    if ($carry > 0) $bits[] = round($carry / 60, 1) . ' h of it waits for tomorrow';
    return $bits ? implode(' · ', $bits) : '';
}

/** Turn what changed during this request into a message for the logged-in gnome and clear it. Safe to call any number of times. */
function gclock_ledger_flush(): void
{
    if (empty($GLOBALS['gclock_ledger']) || !function_exists('current_user')) return;
    $L = $GLOBALS['gclock_ledger'];
    $GLOBALS['gclock_ledger'] = [];
    if (!gclock_on() || !($cu = current_user()) || empty($L[(int)$cu['id']])) return;
    $s = $L[(int)$cu['id']];
    $row = q_one('SELECT energy, game_day, game_minute, carry_minutes FROM users WHERE id = ?', [(int)$cu['id']]);
    if (!$row) return;
    $minutes = ((int)$row['game_day'] * 1440 + (int)$row['game_minute']) - $s['tick'];
    $carry = max(0, (int)$row['carry_minutes'] - $s['carry']);
    $line = gclock_cost_line(max(0, $s['energy'] - (int)$row['energy']), max(0, $minutes) + $carry, (int)$row['game_minute'], $carry);
    if ($line !== '' && (int)$row['game_day'] === $s['day']) flash($line, 'ok');   // a sleep (day change) has its own message
}

// ---------------------------------------------------------------------------------------------------------------------
// Telling the player what things cost, BEFORE they click. gclock_cost_guide() is the full list (Rest page); gclock_cost_tag() is
// the little " · ⚡3 · 🕐15 min" for a button label. Both read the same settings the game charges from, so they cannot drift.
// ---------------------------------------------------------------------------------------------------------------------

/** "15 min" / "2 h" / "8 h" for game minutes. */
function gclock_span_text(int $minutes): string
{
    if ($minutes <= 0) return 'no time';
    if ($minutes < 60) return $minutes . ' min';
    $h = intdiv($minutes, 60);
    return $h . ' h' . ($minutes % 60 ? ' ' . ($minutes % 60) . ' min' : '');
}

/**
 * Button-label tag for an action: energy (with the tired surcharge for this gnome) and game time. '' with the flag off.
 * $energy 0 = free of energy; null = leave the energy out (its own label says it). $units multiplies the time (crafting).
 */
function gclock_cost_tag(?array $u, ?int $energy, string $timeKey = '', int $units = 1): string
{
    if (!gclock_on()) return '';
    $bits = [];
    if ($energy !== null) {
        $e = $u ? game_energy_cost($u, $energy) : $energy;
        $bits[] = $energy > 0 ? '⚡' . $e . ($e !== $energy ? ' (tired)' : '') : 'no energy';
    }
    if ($timeKey !== '') {
        $m = gclock_time_cost($timeKey) * max(1, $units);
        $bits[] = $m > 0 ? '🕐' . gclock_span_text($m) : 'no game time';
    }
    return $bits ? ' · ' . implode(' · ', $bits) : '';
}

/** Every kind of action with its energy and game-time cost: [[label, energy text, time text], ...]. */
function gclock_cost_guide(?array $u = null): array
{
    $t = fn(string $k, int $units = 1): string => gclock_time_cost($k) > 0 ? gclock_span_text(gclock_time_cost($k) * $units) : 'none';
    $e = fn(int $n): string => $n > 0 ? (string)($u ? game_energy_cost($u, $n) : $n) : 'none';
    $nap = gclock_setting_int('nap_minutes', 120);
    $napPct = gclock_setting_int('nap_energy_pct', 40);
    return [
        ['Walk one trail section', 'shown on the walk button', $t('travel') . ' per section'],
        ['Wander off the path', $e(1), $t('wander')],
        ['Gather', $e(1), $t('gather')],
        ['Craft', 'shown on the recipe', $t('craft') . ' per item'],
        ['Arrange flowers', $e(max(0, (int)setting('arrange_energy'))), $t('arrange')],
        ['Pack a seed packet', 'none', $t('seed')],
        ['Florist shift', $e(max(0, (int)setting('florist_energy'))), $t('shift') . ' (anything past 22:00 waits for tomorrow, and you cannot start another timed job until you sleep)'],
        ['Work on a landmark repair', 'shown on the button', $t('repair') . ' (same rule as a shift)'],
        ['Visit a landmark', $e(1), $t('landmark')],
        ['Enter a lair', $e(2), $t('lair')],
        ['Rest-stop activity', 'shown on the activity', $t('stop')],
        ['Plant a sapling', 'shown on the button', $t('sapling')],
        ['Tend (pals, community beds)', 'shown on the button', $t('tend')],
        ['Water a friend’s plot', 'shown on the button', $t('water_other')],
        ['Garden taps: till, plant, water, weed, harvest', 'shown on the button', 'none (the crops move on when you sleep)'],
        ['Nap (needs a seat or bed)', 'gives +' . $napPct . '% energy and health', gclock_span_text($nap)],
        ['Sleep', 'refills energy and health (a bench gives ' . gclock_setting_int('bench_sleep_energy_pct', 30) . '%)', 'jumps to 06:00 of the next day'],
    ];
}

/** What a rest option will do, in plain numbers: "clock 14:05 -> 16:05 · energy 12 -> 28 (+16)". */
function gclock_option_effect(array $u, array $o): string
{
    $s = gclock_state($u);
    $fmt = fn(int $m): string => sprintf('%02d:%02d', intdiv($m, 60) % 24, $m % 60);
    $max = max_energy($u);
    $en = (int)$u['energy'];
    if (($o['kind'] ?? '') === 'nap') {
        $mins = gclock_setting_int('nap_minutes', 120);
        $gain = (int)floor($max * gclock_setting_int('nap_energy_pct', 40) / 100);
        $new = min($max, $en + $gain);
        return 'clock ' . $fmt($s['minute']) . ' → ' . $fmt($s['minute'] + $mins) . ' (+' . gclock_span_text($mins) . ') · energy ' . $en . ' → ' . $new . ' (+' . ($new - $en) . ')';
    }
    $key = (string)($o['key'] ?? '');
    $pct = $key === 'bench' ? gclock_setting_int('bench_sleep_energy_pct', 30) : 100;
    $new = $pct >= 100 ? $max : max($en, (int)floor($max * $pct / 100));
    $extra = $key === 'inn_chores' ? ' · the chores take ' . gclock_span_text(gclock_setting_int('inn_chore_minutes', 240)) . ' first' : '';
    return 'clock ' . $fmt($s['minute']) . ' → 06:00 next day (+' . gclock_span_text(1440 - $s['minute'] + GAME_WAKE_MINUTE) . ') · energy ' . $en . ' → ' . $new . ' (+' . ($new - $en) . ')' . $extra;
}

/** After a rest: "Day 6, 06:00 (+8 h 30 min) · ⚡ 12 → 40 (+28) · ❤️ +9". $before/$after = users rows (energy, game_day, game_minute). */
function gclock_rest_summary(array $before, array $after, int $hpGain = 0): string
{
    $fmt = fn(int $m): string => sprintf('%02d:%02d', intdiv($m, 60) % 24, $m % 60);
    $spent = ((int)$after['game_day'] * 1440 + (int)$after['game_minute']) - ((int)$before['game_day'] * 1440 + (int)$before['game_minute']);
    $day = (int)$after['game_day'] !== (int)$before['game_day'] ? 'Day ' . ((int)$after['game_day'] + 1) . ', ' : '';
    $bits = [$day . $fmt((int)$after['game_minute']) . ' (+' . gclock_span_text(max(0, $spent)) . ')'];
    $bits[] = '⚡ ' . (int)$before['energy'] . ' → ' . (int)$after['energy'] . ' (' . ((int)$after['energy'] >= (int)$before['energy'] ? '+' : '') . ((int)$after['energy'] - (int)$before['energy']) . ')';
    if ($hpGain > 0) $bits[] = '❤️ +' . $hpGain . ' health';
    return implode(' · ', $bits);
}

// ---------------------------------------------------------------------------------------------------------------------
// Hired helpers (Tool Shed). A normal hire lives on the owner's virtual game clock: contract days are game days, visits come every
// helper_visit_hours GAME hours, so every sleep brings a full day of visits. A pal on garden duty (pj_job) keeps its pal-job timers.
// ---------------------------------------------------------------------------------------------------------------------

/** "Now" for a hire: the owner's virtual clock for a normal hire with the flag on, else the real time. */
function gclock_hire_now(array $hire): int
{
    return gclock_on() && empty($hire['pj_job']) && !empty($hire['plot_id']) ? gclock_plot_vnow((int)$hire['plot_id']) : time();
}

/**
 * Replay a helper's watering by game day: each game day with a visit, a thirsty bed is watered (water_day = that day) and grows
 * that day's share; days with no visit stay dry (owed, as for the player). Counts waterings like the real-time version.
 */
function gclock_helper_water_tile(array $t, array $p, array $visits, array &$stats, ?array &$raw, bool $virtual = true): array
{
    $epoch = (int)strtotime(hollow_season_epoch() . ' 00:00:00 UTC');
    $today = gclock_plot_day((int)$t['plot_id']);
    $before = $stats['water'];
    $days = [];
    if ($virtual) foreach ($visits as $v) $days[intdiv($v - $epoch, 86400)] = true;
    else for ($i = 0; $i < count($visits) && $i < 60; $i++) $days[$today - $i] = true;   // a pal on garden duty: its pal-job timers give a number of visits, each waters one game day, latest first
    ksort($days);
    $lw0 = $t['water_day'] ?? null;
    foreach (array_keys($days) as $d) {
        if ($d > $today) break;
        if (($t['grow_day'] ?? '') !== '' && $t['grow_day'] !== null && $d < (int)$t['grow_day']) continue;   // before the bed was last settled
        $t = gclock_tile_grow($t, $p, $d);                 // settle the days before this visit
        if ((int)$t['growth_seconds'] >= (int)$p['grow_minutes'] * 60) break;   // ready: nothing more to water
        if (($t['water_day'] ?? null) === null || (int)$t['water_day'] < $d) { $t['water_day'] = $d; $stats['water']++; }
        if ($d < $today) $t = gclock_tile_grow($t, $p, $d + 1);   // that day, watered (today is not finished yet)
    }
    $t = gclock_tile_grow($t, $p, $today);                // and on to today
    $write = fn() => q('UPDATE plot_tiles SET growth_seconds = ?, grow_day = ?, owed_days = ?, water_day = ?, nipped = ? WHERE id = ?',
        [$t['growth_seconds'], $t['grow_day'], $t['owed_days'], $t['water_day'] ?? null, (int)($t['nipped'] ?? 0), $t['id']]);
    if ($raw === null) { $write(); return $t; }
    if (tile_write_guarded($raw, $write)) {
        $raw = array_merge($raw, ['growth_seconds' => $t['growth_seconds'], 'grow_day' => $t['grow_day'], 'owed_days' => $t['owed_days'], 'water_day' => $t['water_day'] ?? null]);
        return $t;
    }
    $stats['water'] = $before;
    return annotate_tile($raw, $p);
}

/**
 * Chance (percent) that a watering also covers the NEXT game day. A watering normally lasts its own game day; whatever makes it last
 * longer in real time (rain barrel levels 25/40/55%, a barrel or shade tree beside the bed, a damp climate) becomes
 * the chance of a second day. Rolled once per bed and day, the same for everyone who looks.
 */
function gclock_water_carry_pct(array $t, ?array $p): int
{
    $rain = !empty($t['_rain']) ? [1 => 1.25, 2 => 1.40, 3 => 1.55][min(3, (int)$t['_rain'])] : 1.0;
    $barrel = !empty($t['_barrel']) ? 1 + (int)setting('yard_barrel_percent') / 100 : 1.0;
    $shade = !empty($t['_shade']) ? 1 + (int)setting('yard_shade_percent') / 100 : 1.0;
    $clim = max(0.2, 1 + ((int)($t['_clim']['water'] ?? 0) + ((int)($t['mulch'] ?? 0) <= 0 ? (int)($t['_clim']['water_bare'] ?? 0) : 0)) / 100);
    return (int)max(0, min(90, round(($rain * $barrel * $shade * $clim - 1) * 100)));
}

/** The weekday name ("Monday") on the logged-in gnome's own date (real weekday with the flag off). */
function gclock_my_weekday(): string
{
    return gclock_me() ? gmdate('l', hollow_day_number(gclock_my_date()) * 86400) : hollow_date('l');
}

/**
 * "Moving on" (decision on NPCs): with sleep-days a villager is away on some game days, so sleeping fast cannot farm friendship.
 * Deterministic per villager and date (setting npc_away_pct, default 25%), same for everyone. $key: 'n<id>' town NPC, 's<id>' stop villager.
 * Always false with the flag off, and never for a gnome who is not logged in.
 */
function gclock_npc_away(string $key): bool
{
    if (!gclock_me()) return false;
    $v = setting('npc_away_pct');
    $pct = $v === '' ? 25 : max(0, min(90, (int)$v));
    return $pct > 0 && hollow_unit('away|' . $key . '|' . gclock_my_date()) * 100 < $pct;
}
