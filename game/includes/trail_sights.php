<?php
declare(strict_types=1);

/**
 * Trail Sights (v2.6.68, P0 spike; plan claude/plan-trail-sights.md): the big set pieces (landmark sprites) on a Trail map can be used by a gnome standing
 * ON or NEXT TO them (the 8 tiles round the landmark's tile, like fishing by water). One button under the map, 1 energy, a cooldown per section.
 * Data: data/trail_sights.txt. Rewards and the stat check reuse the rest-stop engine (stops.php: stop_rewards, stop_check, stop_cond_ok).
 */

/** The Sights table, [slug => row]. Pure parse of data/trail_sights.txt (an optional $file for the tests). */
function trail_sights_all(?string $file = null): array
{
    static $cache = [];
    $file ??= __DIR__ . '/data/trail_sights.txt';
    if (isset($cache[$file])) return $cache[$file];
    $out = [];
    foreach (is_file($file) ? (file($file, FILE_IGNORE_NEW_LINES) ?: []) : [] as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $p = array_map('trim', explode('|', $line));
        if (count($p) < 11 || !preg_match('/^[a-z0-9-]+$/', $p[0])) continue;
        $out[$p[0]] = ['slug' => $p[0], 'verb' => $p[1], 'icon' => $p[2], 'energy' => max(0, (int)$p[3]), 'cd' => max(0, (int)$p[4]), 'uses' => max(1, (int)$p[5]),
            'when' => $p[6] === '' ? '-' : $p[6], 'check' => $p[7], 'rewards' => $p[8], 'win' => $p[9], 'lose' => $p[10]];
    }
    return $cache[$file] = $out;
}

/**
 * The landmarks of an authored section the gnome stands on or beside (Chebyshev distance 1), [[slug, x, y], ...]. Pure.
 * tests/trail_sights_reach.php proves every landmark of the game has such a tile in reach of the road.
 */
function trail_sights_near(?array $art, int $x, int $y): array
{
    $out = [];
    foreach ((array)($art['objs'] ?? []) as $ob) {
        $key = (string)($ob[2] ?? '');
        if (strncmp($key, 'lm-', 3) !== 0) continue;
        if (max(abs((int)$ob[0] - $x), abs((int)$ob[1] - $y)) <= 1) $out[] = [substr($key, 3), (int)$ob[0], (int)$ob[1]];
    }
    return $out;
}

/** The Sights usable right now where the gnome stands: [[row, ready(bool), note]] (rows from the table only; conditions and cooldown applied). */
function trail_sights_here(array $u, ?array $sc): array
{
    if (!$sc || ($sc['st']['phase'] ?? '') !== 'section') return [];
    $all = trail_sights_all();
    $out = [];
    foreach (trail_sights_near($sc['map']['art'] ?? null, (int)$sc['x'], (int)$sc['y']) as [$slug]) {
        if (!isset($all[$slug])) continue;
        $row = $all[$slug];
        [$left, $why] = trail_sight_state((int)$u['id'], $sc, $row);
        $out[] = [$row, $left, $why];
    }
    return $out;
}

/** [uses left, note] for this gnome, this stretch and this Sight. The cooldown runs on game time (like Trail finds) or real time with the clock off. */
function trail_sight_state(int $uid, array $sc, array $row): array
{
    $route = (int)substr((string)$sc['row']['map_key'], 6);
    $sec = trail_phys_sec($route, (int)$sc['st']['sec'], $sc['st']);
    try {
        $r = q_one('SELECT * FROM trail_sight_uses WHERE user_id = ? AND route_id = ? AND sec = ? AND slug = ?', [$uid, $route, $sec, $row['slug']]);
    } catch (Throwable $e) { return [$row['uses'], '']; }   // table missing before Upgrade database
    if (!$r) return [$row['uses'], ''];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $span = (int)round($row['cd'] * 144);   // game ticks are minutes: cd is tenths of a game day, so 55 = 7920 (same as trail_pickups)
    $gone = $u && gclock_on() && $r['got_tick'] !== null
        ? gclock_state($u)['tick'] - (int)$r['got_tick'] >= $span
        : time() - (int)$r['got_at'] >= (int)round($row['cd'] * 8640);
    if ($gone) return [$row['uses'], ''];
    $left = max(0, $row['uses'] - (int)$r['n']);
    return [$left, $left > 0 ? '' : 'Grows back in a few days.'];
}

/**
 * Use the Sight $slug where the gnome stands. [ok, message]. The journal line goes in the walk log; costs energy and game time.
 * A pseudo "place" (the walk's start, with the Sight's name and the land) lets the rest-stop reward code work: level, region crops and finds.
 */
function trail_sight_do(array $u, array &$exp, string $slug): array
{
    $sc = trail_scene($exp);
    if (!$sc) return [false, 'Not on a tile walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    $all = trail_sights_all();
    if (!isset($all[$slug])) return [false, 'There is nothing to do here.'];
    $row = $all[$slug];
    if (($sc['st']['phase'] ?? '') !== 'section' || !array_filter(trail_sights_near($sc['map']['art'] ?? null, (int)$sc['x'], (int)$sc['y']), fn($n) => $n[0] === $slug)) return [false, 'You need to be next to it.'];
    require_once __DIR__ . '/stops.php';
    if ($row['when'] !== '-' && !stop_cond_ok($row['when'], stop_now(['id' => (int)$exp['from_id']] + (q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: [])))) return [false, 'Not the right time for that.'];
    [$left, $why] = trail_sight_state((int)$u['id'], $sc, $row);
    if ($left < 1) return [false, $why ?: 'Not again just yet.'];
    if ($row['energy'] > 0 && !spend_energy((int)$u['id'], $row['energy'], 'gather')) return [false, 'You need ' . $row['energy'] . ' energy for that.'];
    gclock_charge((int)$u['id'], 'gather');
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: [];
    $loc['name'] = $row['verb'];
    $loc['landscape'] = (string)(exp_scene($exp)['land'] ?? ($loc['landscape'] ?? 'grassland'));
    $ok = true; $f = 1.0;
    if ($row['check'] !== '-' && str_contains($row['check'], ':')) { [$stat, $dc] = explode(':', $row['check'], 2); [$ok] = stop_check($u, $stat, (int)$dc); }
    $lines = $ok ? stop_rewards($u, $loc, $row['rewards'], $f) : [];
    $text = $row['icon'] . ' ' . ($ok ? $row['win'] : $row['lose']) . ($lines ? ' (' . implode(', ', $lines) . ')' : '');
    exp_log($exp, $text);
    $route = (int)substr((string)$sc['row']['map_key'], 6);
    $sec = trail_phys_sec($route, (int)$sc['st']['sec'], $sc['st']);
    try {
        $r = q_one('SELECT * FROM trail_sight_uses WHERE user_id = ? AND route_id = ? AND sec = ? AND slug = ?', [(int)$u['id'], $route, $sec, $slug]);
        $fresh = !$r || $left === (int)$row['uses'];   // a new cooldown window starts on the first use
        if ($r && $fresh) q('DELETE FROM trail_sight_uses WHERE id = ?', [$r['id']]);
        if ($fresh) { $uu = q_one('SELECT * FROM users WHERE id = ?', [(int)$u['id']]);
            db_insert('trail_sight_uses', ['user_id' => (int)$u['id'], 'route_id' => $route, 'sec' => $sec, 'slug' => $slug, 'n' => 1, 'got_at' => time(), 'got_tick' => $uu && gclock_on() ? gclock_state($uu)['tick'] : null]);
        } else q('UPDATE trail_sight_uses SET n = n + 1 WHERE id = ?', [$r['id']]);
    } catch (Throwable $e) { /* table missing before Upgrade database: no cooldown, the energy still counts */ }
    return [true, ''];
}
