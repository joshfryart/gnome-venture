<?php
declare(strict_types=1);

/**
 * Trail Sights (v2.6.68, P0 spike; plan claude/plan-trail-sights.md): the big set pieces (landmark sprites) on a Trail map can be used by a gnome standing
 * ON or NEXT TO them (the 8 tiles round the landmark's tile, like fishing by water). One button under the map, 1 energy, a cooldown per section.
 * Data: data/trail_sights.txt. Rewards and the stat check reuse the rest-stop engine (stops.php: stop_rewards, stop_check, stop_cond_ok).
 */

require_once __DIR__ . '/trail_sight_extras.php';

const TRAIL_SIGHT_COLS = ['slug', 'verb', 'icon', 'energy', 'cd', 'uses', 'when', 'check', 'rewards', 'win', 'lose', 'tool', 'fail_en'];
const TRAIL_SIGHT_REWARD_TOKENS = ['c', 'xp', 'en', 'item', 'crop', 'find', 'fish', 'seed', 'buff', 'fp', 'reveal', 'gather', 'take', 'unlock'];

/** One data row (an array of strings in TRAIL_SIGHT_COLS order, the last two optional) as a Sight row, or null if it is not one. */
function trail_sight_row(array $p): ?array
{
    $p = array_map(fn($v) => trim((string)$v), $p);
    if (count($p) < 11 || !preg_match('/^[a-z0-9-]+$/', $p[0])) return null;
    return ['slug' => $p[0], 'verb' => $p[1], 'icon' => $p[2], 'energy' => max(0, (int)$p[3]), 'cd' => max(0, (int)$p[4]), 'uses' => max(1, (int)$p[5]),
        'when' => $p[6] === '' ? '-' : $p[6], 'check' => $p[7] === '' ? '-' : $p[7], 'rewards' => $p[8], 'win' => $p[9], 'lose' => $p[10],
        'tool' => ($p[11] ?? '') === '' ? '-' : $p[11], 'fail_en' => max(0, (int)($p[12] ?? 0)), 'src' => 'file'];
}

/** The rows of data/trail_sights.txt and every data/trail_sights_*.txt (one per region), [slug => row]. Pure parse (an optional $file for the tests: that one file only). */
function trail_sights_file(?string $file = null): array
{
    $files = $file !== null ? [$file] : array_merge([__DIR__ . '/data/trail_sights.txt'], glob(__DIR__ . '/data/trail_sights_*.txt') ?: []);
    $out = [];
    foreach ($files as $f) foreach (is_file($f) ? (file($f, FILE_IGNORE_NEW_LINES) ?: []) : [] as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        if ($r = trail_sight_row(explode('|', $line))) $out[$r['slug']] = $r;
    }
    return $out;
}

/**
 * The reward list of a row as tokens: [['tok' => 'item=x:1@25', 'cond' => 'se=summer' | '', 'first' => bool], ...].
 * Grammar on top of the rest-stop one: `first:xp=10` pays only the first time this gnome ever uses the Sight; `item=x:1@25?se=summer;dp=dusk` only when the condition holds
 * (stop words; ; between values, / between conditions); `take=slug:qty` is a cost (needed in the satchel, used up on a win); `unlock=kind:slug` opens an Almanac page;
 * `gather=<tool>` runs the gather table.
 */
function trail_sight_tokens(string $rewards): array
{
    $out = [];
    foreach (array_filter(array_map('trim', explode(',', $rewards))) as $tok) {
        $first = false; $cond = '';
        if (str_starts_with($tok, 'first:')) { $first = true; $tok = substr($tok, 6); }
        if (($i = strpos($tok, '?')) !== false) { $cond = str_replace(';', ',', substr($tok, $i + 1)); $tok = substr($tok, 0, $i); }
        $out[] = ['tok' => $tok, 'cond' => $cond, 'first' => $first];
    }
    return $out;
}

/** The Sights of the game, [slug => row]: the data file, with the admin's rows laid over it (a row there replaces the file row; active = 0 hides it). */
function trail_sights_all(?string $file = null, bool $db = true): array
{
    static $cache = [];
    $key = ($file ?? '') . ($db ? '|db' : '');
    if ($db && $file === null && isset($cache[$key]) && empty($GLOBALS['gv_sights_reload'])) return $cache[$key];
    $out = trail_sights_file($file);
    if ($db && $file === null) {
        try {
            foreach (q('SELECT * FROM trail_sight_rows')->fetchAll() as $r) {
                if (!(int)$r['active']) { unset($out[$r['slug']]); continue; }
                $out[$r['slug']] = ['slug' => $r['slug'], 'verb' => (string)$r['verb'], 'icon' => (string)$r['icon'], 'energy' => max(0, (int)$r['energy']), 'cd' => max(0, (int)$r['cd']),
                    'uses' => max(1, (int)$r['uses']), 'when' => (string)$r['cond'] ?: '-', 'check' => (string)$r['chk'] ?: '-', 'rewards' => (string)$r['rewards'], 'win' => (string)$r['win'],
                    'lose' => (string)$r['lose'], 'tool' => (string)$r['tool'] ?: '-', 'fail_en' => max(0, (int)$r['fail_en']), 'src' => isset(trail_sights_file()[$r['slug']]) ? 'edited' : 'new'];
            }
        } catch (Throwable $e) { /* table missing before Upgrade database: the file alone */ }
    }
    $GLOBALS['gv_sights_reload'] = false;
    return $cache[$key] = $out;
}

/** Problems with a Sight row (empty = fine): unknown sprite, odd numbers, unknown stat / tool / reward / item. $db = also look items up in the database. */
function trail_sight_lint(array $r, bool $db = true): array
{
    $bad = [];
    if (!is_file(dirname(__DIR__) . '/assets/img/trail/obj/lm-' . $r['slug'] . '.png')) $bad[] = 'no landmark picture lm-' . $r['slug'] . '.png';
    if ($r['verb'] === '' || mb_strlen($r['verb']) > 24) $bad[] = 'verb must be 1 to 24 characters';
    if ($r['icon'] === '') $bad[] = 'no icon';
    if ($r['energy'] > 5) $bad[] = 'energy over 5';
    if ($r['cd'] > 400) $bad[] = 'cooldown over 40 game days';
    if ($r['uses'] > 9) $bad[] = 'more than 9 uses';
    if ($r['fail_en'] > 3) $bad[] = 'a fail may cost at most 3 energy';
    if ($r['win'] === '') $bad[] = 'no win line';
    if ($r['check'] !== '-') {
        $c = explode(':', $r['check']);
        if (count($c) !== 2 || !array_key_exists($c[0], GNOME_STATS) || !ctype_digit($c[1]) || (int)$c[1] > 25) $bad[] = 'check must be stat:difficulty (' . implode(', ', array_keys(GNOME_STATS)) . ')';
        elseif ($r['lose'] === '') $bad[] = 'a check needs a lose line';
    }
    if ($r['when'] !== '-') foreach (array_filter(array_map('trim', explode('/', $r['when']))) as $part) if (!preg_match('/^(dp|se|we|hp)=[a-z,]+$/', $part)) $bad[] = 'bad condition "' . $part . '"';
    if ($r['tool'] !== '-') {
        $t = explode(':', $r['tool']);
        if (count($t) !== 2 || !in_array($t[0], GATHER_TOOLS, true) || !in_array((int)$t[1], [1, 2, 3, 4], true)) $bad[] = 'tool must be type:tier 1-4 (' . implode(', ', GATHER_TOOLS) . ')';
    }
    foreach (trail_sight_tokens($r['rewards']) as $t) {
        $tok = $t['tok'];
        if ($t['cond'] !== '') foreach (explode('/', $t['cond']) as $part) if (!preg_match('/^(dp|se|we|hp)=[a-z,]+$/', trim($part))) $bad[] = 'bad condition "' . $part . '" in ' . $tok;
        if (str_contains($tok, '@')) { [$tok, $pc] = explode('@', $tok, 2); if (!ctype_digit($pc) || (int)$pc > 100) $bad[] = 'bad chance in ' . $tok; }
        [$k, $v] = array_pad(explode('=', $tok, 2), 2, '');
        if (!in_array($k, TRAIL_SIGHT_REWARD_TOKENS, true)) { $bad[] = 'unknown reward "' . $k . '"'; continue; }
        if ($k === 'gather' && !in_array($v, GATHER_TOOLS, true)) $bad[] = 'gather= needs a tool type';
        if ($k === 'unlock' && !preg_match('/^[a-z]+:[a-z0-9-]+$/', $v)) $bad[] = 'unlock= needs kind:slug';
        if (($k === 'item' || $k === 'take') && $db) { $slug = explode(':', $v)[0]; if (!trail_sight_item_known($slug)) $bad[] = 'no item "' . $slug . '"'; }
    }
    return $bad;
}

/** Make the Sights tables if the Upgrade database run has not yet (the admin page uses this; the game falls back to the file and no cooldown). */
function trail_sights_ensure_tables(): bool
{
    try { q('SELECT 1 FROM trail_sight_rows LIMIT 1'); q('SELECT 1 FROM trail_sight_uses LIMIT 1'); q('SELECT 1 FROM trail_sight_first LIMIT 1'); q('SELECT 1 FROM user_sight_quests LIMIT 1'); trail_sights_ensure_items(); return true; } catch (Throwable $e) {}
    try {
        require_once __DIR__ . '/action_log.php';
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        [$t, $i] = action_log_schema($sqlite ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $sqlite ? 'INTEGER' : 'INT UNSIGNED', $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
        foreach ($t as $sql) if (str_contains($sql, 'trail_sight_')) db()->exec($sql);
        foreach ($i as $sql) if (str_contains($sql, 'trail_sight_')) { try { db()->exec($sql); } catch (Throwable $e) {} }
        trail_sights_ensure_items();
        return true;
    } catch (Throwable $e) { error_log('trail_sights_ensure_tables: ' . $e->getMessage()); return false; }
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
    if ($row['tool'] !== '-') {   // needs a gathering tool of at least this tier
        require_once __DIR__ . '/gathering.php';
        [$tt, $tier] = explode(':', $row['tool']);
        if (tool_tier((int)$u['id'], $tt) < (int)$tier) return [false, 'You need a ' . (TOOL_TIERS[(int)$tier] ?? '') . ' ' . (GATHER_TOOL_NOUN[$tt] ?? 'tool') . ' for that.'];
    }
    $takes = [];   // take=slug:qty: needed in the satchel (checked before any energy goes), used up on a win
    foreach (trail_sight_tokens($row['rewards']) as $t) if (str_starts_with($t['tok'], 'take=')) {
        [$tslug, $tqty] = array_pad(explode(':', substr($t['tok'], 5), 2), 2, '1'); $tid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$tslug]); $tq = max(1, (int)$tqty);
        if (!$tid || (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $tid]) < $tq) return [false, 'You need ' . $tq . ' × ' . ($tid ? (string)q_val('SELECT name FROM items WHERE id = ?', [$tid]) : $tslug) . ' for that.'];
        $takes[] = [$tid, $tq];
    }
    trail_sights_ensure_items();   // a Sight can hand out an item only Sights give (data/trail_sight_items.txt): make them before the first use
    if (!spend_energy((int)$u['id'], $row['energy'], 'sight')) return [false, 'You need ' . $row['energy'] . ' energy for that.'];   // time: setting time_sight (10 game minutes); an energy-free Sight still takes the time
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: [];
    $loc['name'] = $row['verb'];
    $loc['landscape'] = (string)(exp_scene($exp)['land'] ?? ($loc['landscape'] ?? 'grassland'));
    $ok = true; $f = 1.0;
    if ($row['check'] !== '-' && str_contains($row['check'], ':')) { [$stat, $dc] = explode(':', $row['check'], 2); [$ok] = stop_check($u, $stat, (int)$dc); }
    $lines = [];
    $first = false;
    try { $first = !q_val('SELECT 1 FROM trail_sight_first WHERE user_id = ? AND slug = ?', [(int)$u['id'], $slug]); } catch (Throwable $e) { /* table missing: no first-time bonus */ }
    if ($ok) {
        $now = null; $plain = [];   // the rest-stop reward grammar for most tokens; gather= runs the gather table, unlock= opens an Almanac page, take= is paid below
        foreach (trail_sight_tokens($row['rewards']) as $t) {
            if ($t['first'] && !$first) continue;
            if ($t['cond'] !== '') { $now ??= stop_now($loc); if (!stop_cond_ok($t['cond'], $now)) continue; }
            $tok = $t['tok'];
            if (str_starts_with($tok, 'take=')) continue;
            if (str_starts_with($tok, 'gather=')) {
                require_once __DIR__ . '/gathering.php';
                $gl = gather_on_walk($u, $loc['landscape'], substr($tok, 7), true, $found);
                if ($found) gather_reveal_set($found);
                $lines[] = $gl ?? 'You find nothing this time.';
            } elseif (str_starts_with($tok, 'unlock=')) { if (unlock_entries((int)$u['id'], substr($tok, 7)) > 0) $lines[] = '📖 A new Almanac page'; }
            else $plain[] = $tok;
        }
        foreach ($takes as [$tid, $tq]) give_item((int)$u['id'], $tid, -$tq);
        $lines = array_merge($plain ? stop_rewards($u, $loc, implode(',', $plain), $f) : [], $lines);
    } elseif ($row['fail_en'] > 0) {   // a slip costs a little energy (never below 0)
        q('UPDATE users SET energy = CASE WHEN energy >= ? THEN energy - ? ELSE 0 END WHERE id = ?', [$row['fail_en'], $row['fail_en'], (int)$u['id']]);
        $lines[] = '-' . $row['fail_en'] . ' energy';
    }
    if ($ok) {   // villagers who turn up, quest lines, the Almanac page
        $now ??= stop_now($loc);
        foreach (trail_sight_folk_here($slug, $now) as $f) if (random_int(1, 100) <= $f['chance']) { $lines = array_merge($lines, ['💬 ' . $f['line']], trail_sight_pay($u, $loc, $f['rewards'], $f['who'])); break; }
        $qlines = trail_sight_quest_hook($u, $slug, $loc, $now);
        try { unlock_entries((int)$u['id'], 'sight:' . $slug); } catch (Throwable $e) {}
    }
    if ($ok && $first) { try { db_insert('trail_sight_first', ['user_id' => (int)$u['id'], 'slug' => $slug]); } catch (Throwable $e) {} }
    $text = $row['icon'] . ' ' . ($ok ? $row['win'] : $row['lose']) . ($lines ? ' (' . implode(', ', $lines) . ')' : '');
    exp_log($exp, $text);
    foreach ($qlines ?? [] as $ql) exp_log($exp, $ql);
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
