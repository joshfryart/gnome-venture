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
        ['pantry_jars', 'ready_day', 'INT NULL'],   // game_day a game-clock jar is ready on; NULL = real ready_at
        ['users', 'carry_minutes', 'INT NOT NULL DEFAULT 0'],   // work left at 22:00 that finishes after the next sleep (decisions 43-44)
        ['users', 'camp_naps', 'INT NOT NULL DEFAULT 0'],   // naps taken on the gear now in use (2 per gear)
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
    game_new_day($uid);
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
    static $memo = [];
    if ($reset) { $memo = []; return 0; }
    return $memo[$plotId] ??= (int)q_val('SELECT u.game_day FROM plots pl JOIN users u ON u.id = pl.user_id WHERE pl.id = ?', [$plotId]);
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
    $n = 0;
    for ($d = $from; $d < $today && $n++ < 60; $d++) {
        $fx = garden_day_fx($t, $p, hollow_date_add($epoch, $d));
        if ($water !== $d && empty($fx['wet'])) { $owed = min($owed + 1, $sleeps); continue; }   // a dry day is owed, not lost
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
    $id = item_id_by_slug('camping-gear');
    if ($id) return (int)$id;
    return (int)db_insert('items', ['name' => 'Camping Gear', 'slug' => 'camping-gear', 'category' => 'misc', 'rarity' => 10, 'base_price' => 100,
        'description' => 'Rope, pins, canvas and a little pot. Two naps on the road, or one night.', 'edible' => 0, 'tradable' => 1]);
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
function gclock_rest(int $uid, string $key): array
{
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    if (!$u) return [false, 'No such gnome.'];
    $found = null;
    foreach (gclock_rest_options($u) as $o) if ($o['key'] === $key) $found = $o;
    if (!$found) return [false, 'You can’t rest that way here.'];
    if (!$found['ok']) return [false, $found['why'] ?: 'Not right now.'];
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
    $h = gclock_setting_int('pal_hours_per_sleep', 8);
    if ($h > 0) gclock_shift_pal_clocks($uid, $h * 3600);
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
    'wander' => 20, 'gather' => 15, 'craft' => 15,   // craft is per unit
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
