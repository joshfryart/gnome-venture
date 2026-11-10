<?php
declare(strict_types=1);

// Player perks (2.6.33): a full stop meter (Repairs, Larder, Cheer) gives the PLAYER a perk that works everywhere for
// player_perk_days (7) game days. Same perk again = refresh, no stack. At most player_perk_max (3) run; a 4th drops the one ending soonest.
// Which perk: seeded by (player, stop, game day) from that meter's pool, preferring one that is not already running.
// Numbers are admin settings (perk_*). Design notes: docs/stop-perk-ideas.md.

const PLAYER_PERKS = [   // key => [meter, icon, name, text]
    'light_feet'   => ['repairs', '🥾', 'Light Feet', 'Walking a road costs 1 less energy'],
    'good_bones'   => ['repairs', '🦴', 'Good Bones', 'Healing gives 25% more'],
    'seasoned'     => ['larder', '🧂', 'Seasoned', 'Home-cooked dishes give 20% more energy'],
    'green_thumb'  => ['larder', '🌱', 'Green Thumb', 'Harvests: 10% chance of one extra'],
    'packed_lunch' => ['larder', '🥪', 'Packed Lunch', 'Meal and potion boosts last 25% longer'],
    'slow_simmer'  => ['larder', '🍲', 'Slow Simmer', 'Pots cook 20% faster'],
    'spring_step'  => ['cheer', '👟', 'Spring in Step', 'Walking takes 15% less time'],
    'bright_mood'  => ['cheer', '😊', 'Bright Mood', '10% more XP from everything'],
    'silver_tongue' => ['cheer', '🗣️', 'Silver Tongue', 'Shops charge 5% less'],
];

/** perk key => last day (Y-m-d), running now. */
function player_perks_active(int $uid, bool $refresh = false): array
{
    static $cache = [];
    if ($uid < 1) return [];
    $today = gclock_my_date();
    if ($refresh || !isset($cache[$uid]) || $cache[$uid][0] !== $today) {
        $out = [];
        try {
            foreach (q('SELECT perk_key, until FROM player_perks WHERE user_id = ?', [$uid])->fetchAll() as $r) {
                if ((string)$r['until'] >= $today && isset(PLAYER_PERKS[$r['perk_key']])) $out[(string)$r['perk_key']] = (string)$r['until'];
            }
        } catch (Throwable $e) { $out = []; }   // table not made yet (before Upgrade database)
        $cache[$uid] = [$today, $out];
    }
    return $cache[$uid][1];
}

function player_perk(int $uid, string $key): bool
{
    return isset(player_perks_active($uid)[$key]);
}

/** Percent change helper: $n scaled by the perk's setting when it runs. */
function player_perk_pct(int $uid, string $key, string $setting): int
{
    return player_perk($uid, $key) ? (int)setting($setting) : 0;
}

/** Days left (1 = last day) for a running perk. */
function player_perk_days_left(string $until): int
{
    return max(1, stop_days_between(gclock_my_date(), $until) + 1);
}

/** Give a perk for a filled meter. Returns [key, refreshed?, dropped key or '']. */
function player_perk_grant(int $uid, int $locId, string $meter): array
{
    $pool = array_keys(array_filter(PLAYER_PERKS, fn($p) => $p[0] === $meter));
    if (!$pool) return ['', false, ''];
    $run = player_perks_active($uid, true);
    $today = gclock_my_date();
    $start = crc32($uid . '|' . $locId . '|' . $today) % count($pool);
    $key = $pool[$start];
    for ($i = 0; $i < count($pool); $i++) if (!isset($run[$pool[($start + $i) % count($pool)]])) { $key = $pool[($start + $i) % count($pool)]; break; }
    $days = max(1, (int)setting('perk_days'));
    $until = gmdate('Y-m-d', strtotime($today . ' 12:00:00 UTC +' . ($days - 1) . ' days'));
    $refreshed = isset($run[$key]);
    $dropped = '';
    if (!$refreshed && count($run) >= max(1, (int)setting('perk_max'))) {
        asort($run);
        $dropped = (string)array_key_first($run);
        q('DELETE FROM player_perks WHERE user_id = ? AND perk_key = ?', [$uid, $dropped]);
    }
    if (q_val('SELECT 1 FROM player_perks WHERE user_id = ? AND perk_key = ?', [$uid, $key])) {
        q('UPDATE player_perks SET until = ?, meter = ?, from_location_id = ? WHERE user_id = ? AND perk_key = ?', [$until, $meter, $locId, $uid, $key]);
    } else {
        db_insert('player_perks', ['user_id' => $uid, 'perk_key' => $key, 'meter' => $meter, 'until' => $until, 'from_location_id' => $locId]);
    }
    player_perks_active($uid, true);
    return [$key, $refreshed, $dropped];
}

/** Line for a new perk. */
function player_perk_line(array $res): string
{
    [$key, $refreshed] = $res;
    if ($key === '') return '';
    [, $ico, $name, $text] = PLAYER_PERKS[$key];
    return '🌟 ' . $ico . ' ' . $name . ($refreshed ? ' refreshed' : '') . ': ' . $text . ', everywhere, for ' . max(1, (int)setting('perk_days')) . ' days.';
}

/** Rows for the header effects list: [icon, name, what it does, seconds left]. */
function player_perk_effects(int $uid): array
{
    $out = [];
    foreach (player_perks_active($uid) as $key => $until) {
        [, $ico, $name, $text] = PLAYER_PERKS[$key];
        $d = player_perk_days_left($until);
        $out[] = [$ico, $name, $text . ' · ' . $d . ' day' . ($d === 1 ? '' : 's') . ' left', $d * 86400];
    }
    return $out;
}

/** HTML for the Perks card: your running perks, account-wide. */
function player_perks_html(int $uid): string
{
    $run = player_perks_active($uid);
    $h = '<h4>Your perks (work everywhere)</h4>';
    if (!$run) return $h . '<div class="pkempty"><span>None yet. Fill a bar at any stop to earn one.</span></div>';
    foreach ($run as $key => $until) {
        [, $ico, $name, $text] = PLAYER_PERKS[$key];
        $d = player_perk_days_left($until);
        $h .= '<div class="pkperk"><span class="pkbadge">' . e($ico) . '</span><div class="pkpt"><b>' . e($name) . '</b><span class="pkfx">' . e($text) . '</span></div>'
            . '<div class="pkleft"><small>' . $d . ' day' . ($d === 1 ? '' : 's') . ' left</small></div></div>';
    }
    return $h;
}
