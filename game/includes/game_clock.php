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
        ['plot_tiles', 'grow_day', 'INT NULL'],    // the owner's game_day that growth is settled up to
        ['plot_tiles', 'water_day', 'INT NULL'],   // the owner's game_day the bed was last watered on
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
    if ($over <= 0) return 0;
    $per = setting('tired_surcharge_pct_per_hour');
    return (int)ceil($over / 60) * ($per === '' ? 10 : max(0, (int)$per));
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
function game_sleep(int $uid): ?array
{
    $u = q('SELECT * FROM users WHERE id = ?', [$uid])->fetch();
    if (!$u) return null;
    $n = q('UPDATE users SET game_day = game_day + 1, game_minute = ?, energy = ? WHERE id = ? AND game_day = ? AND game_minute = ?',
        [GAME_WAKE_MINUTE, max_energy($u), $uid, (int)$u['game_day'], (int)$u['game_minute']])->rowCount();
    if ($n !== 1) return null;
    return ['game_day' => (int)$u['game_day'] + 1, 'game_minute' => GAME_WAKE_MINUTE];
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
    $share = $need / gclock_grow_sleeps($p);
    $gs = (int)$t['growth_seconds'];
    $base = soil_speed($t);
    $slowPest = !empty($t['pest']) ? max(0, min(90, (int)setting('pest_slow_pct'))) / 100 : 0.0;
    $water = ($t['water_day'] ?? null) === null || ($t['water_day'] ?? '') === '' ? null : (int)$t['water_day'];
    $epoch = hollow_season_epoch();
    $n = 0;
    for ($d = $from; $d < $today && $n++ < 60; $d++) {
        $fx = garden_day_fx($t, $p, hollow_date_add($epoch, $d));
        if ($water !== $d && empty($fx['wet'])) continue;
        $gs += (int)($share * $base * $fx['speed'] * (1 - $slowPest));
        if (!empty($fx['nip'])) $t['nipped'] = 1;
    }
    $t['growth_seconds'] = min($gs, $need);
    $t['grow_day'] = $today;
    return $t;
}
