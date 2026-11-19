<?php
declare(strict_types=1);

/**
 * Sights engine gaps, fourth pass (claude/sights/GRAMMAR.md "Fourth pass"; test tests/trail_sights_282.sh). No schema change.
 *  1. FOG: `nxt=fog` = the next stretch lies in fog: its finds are not drawn on the map until the gnome stands next to one (they are still there and still
 *     picked up by walking onto them), and `nxt=peek` cannot see into it. `nxt=lit` = a lit path (the Lantern Path): no stretch of this walk is in fog from
 *     now on (a pending fog is dropped, a fog on the stretch you stand in lifts). Walk state: st.fog = [stretches as walked], st.lit = 1.
 *     Setting trail_fog_weather (default 0 = off): foggy WEATHER puts every newly entered stretch in fog too.
 *  2. A NAMED stretch: `sec=<route id>.<stretch 1-6 as drawn>:<effect>` aims an effect at one stretch of one route instead of "the next one". It waits
 *     (private tally `sec#route#stretch#effect`) until a walk of this gnome enters that stretch, on this walk or a later one.
 *  3. PENALTIES: a reward token with `lose:` in front is paid on a LOST check instead of a win: `lose:time=20`, `lose:nxt=fog`, `lose:sec=...`.
 *  4. A check whose difficulty depends on the conditions: `sense:11?se=spring:9` (difficulty 9 when the condition holds, else 11).
 * Everything here is new functions; trail_sights.php, trail_sight_extras.php, trail_sights_3a.php and trail_tiles.php only call them.
 */

require_once __DIR__ . '/trail_sights_5.php';

const SIGHTS4_SEC_RE = '/^(\d{1,4})\.([1-6]):(find(?::[1-3])?|calm|fog|quick:(?:[5-9]|[1-5]\d|60)|skip)$/';
const SIGHTS4_LOSE_KEYS = ['time', 'nxt', 'sec'];
const SIGHTS4_CHECK_RE = '/^([a-z]+):(\d{1,2})(?:\?(.+):(\d{1,2}))?$/';

// ---------------------------------------------------------------- 1. fog

/** Is the stretch the gnome stands in foggy? (st.fog lists the foggy stretches as walked; a lit path has none.) */
function sights4_fog_on(array $st): bool
{
    return empty($st['lit']) && in_array((int)($st['sec'] ?? -1), array_map('intval', (array)($st['fog'] ?? [])), true);
}

/** The scene as the map may show it: in fog, a find not yet taken is left out unless the gnome stands on or next to it. The saved scene is not changed. */
function sights4_fog_view(array $sc): array
{
    if (!sights4_fog_on((array)($sc['st'] ?? []))) return $sc;
    $sc['st']['tokens'] = array_values(array_filter((array)$sc['st']['tokens'],
        fn($t) => $t[2] !== 'F' || (int)$t[3] !== 0 || max(abs((int)$t[0] - (int)$sc['x']), abs((int)$t[1] - (int)$sc['y'])) <= 1 || sights5_is_marked($sc['st'], (int)$t[0], (int)$t[1])));   // fifth pass: a find marked with a map scrap shows in fog
    return $sc;
}

/** Is a fog waiting for the next stretch (a Sight's nxt=fog not yet used up, and no lit path)? */
function sights4_fog_pending(array $st): bool
{
    return empty($st['lit']) && in_array('fog', (array)($st['nxt'] ?? []), true);
}

/** Does foggy weather fog the Trail? (Setting trail_fog_weather, default off: an owner switch.) $exp = the walk. */
function sights4_weather_fog(array $exp): bool
{
    if (setting('trail_fog_weather') !== '1') return false;
    try {
        require_once __DIR__ . '/stops.php';
        $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)($exp['from_id'] ?? 0)]);
        return $loc && (string)(stop_now($loc)['we'] ?? '') === 'fog';
    } catch (Throwable $e) { return false; }
}

/** Put the stretch $st stands in into fog (unless the path is lit). True = it is foggy now and was not before. */
function sights4_fog_set(array &$st): bool
{
    if (!empty($st['lit'])) return false;
    $fog = array_map('intval', (array)($st['fog'] ?? []));
    if (in_array((int)$st['sec'], $fog, true)) return false;
    $fog[] = (int)$st['sec']; $st['fog'] = array_values($fog);
    return true;
}

/** nxt=lit: the path is lit for the rest of this walk. Returns the line ('' = the scene could not be saved). */
function sights4_lit(array $sc): string
{
    $was = sights4_fog_on($sc['st']) || sights4_fog_pending($sc['st']);
    $sc['st']['lit'] = 1;
    $sc['st']['nxt'] = array_values(array_filter((array)($sc['st']['nxt'] ?? []), fn($e) => $e !== 'fog'));
    if (!$sc['st']['nxt']) unset($sc['st']['nxt']);
    if (!trail_save($sc)) return '';
    return $was ? '🏮 The path is lit: the fog draws back, and stays back for the rest of this walk' : '🏮 The path is lit: no fog will settle on the rest of this walk';
}

// ---------------------------------------------------------------- 2. a named stretch

/** [route id, stretch 1-6, effect] of a sec= value, or null. */
function sights4_sec_parse(string $v): ?array
{
    return preg_match(SIGHTS4_SEC_RE, $v, $m) ? [(int)$m[1], (int)$m[2], (string)$m[3]] : null;
}

/** "the Trail between A and B" for a route id ('' when there is no such route). */
function sights4_route_name(int $rid): string
{
    try {
        $r = q_one('SELECT a.name AS an, b.name AS bn FROM routes r JOIN locations a ON a.id = r.a_id JOIN locations b ON b.id = r.b_id WHERE r.id = ?', [$rid]);
        return $r ? 'the Trail between ' . $r['an'] . ' and ' . $r['bn'] : '';
    } catch (Throwable $e) { return ''; }
}

/** sec=<route>.<stretch>:<effect>: kept for this gnome until a walk enters that stretch. find keeps the biggest count, quick the most minutes. Returns the line. */
function sights4_sec_add(array $u, string $v): string
{
    $p = sights4_sec_parse($v);
    if (!$p) return '';
    [$rid, $n, $fx] = $p;
    $where = sights4_route_name($rid);
    if ($where === '') return '';
    [$k, $a] = array_pad(explode(':', $fx, 2), 2, '');
    $key = 'sec#' . $rid . '#' . $n . '#' . $k;
    $val = $k === 'find' ? max(1, (int)($a ?: 1)) : ($k === 'quick' ? (int)$a : 1);
    $have = (int)(trail_sight_tallies((int)$u['id'])[$key] ?? 0);
    if ($val > $have) trail_sight_tally_set((int)$u['id'], $key, $val);
    $what = match ($k) {
        'find' => ($val > 1 ? $val . ' finds wait' : 'A find waits') . ' on',
        'calm' => 'No surprise waits at the door of',
        'fog' => 'Fog is settling on',
        'quick' => 'You know a quicker line (' . $val . ' game minutes) through',
        default => 'You know a shortcut through',
    };
    return ($k === 'fog' ? '🌫️ ' : '🗺️ ') . $what . ' stretch ' . $n . ' of ' . $where;
}

/** The named effects waiting for this gnome at one stretch (as drawn, 0-based): [[tally key, effect], ...]. $start = the walk's first stretch: only find and fog can be used there. */
function sights4_sec_pending(int $uid, int $rid, int $phys, bool $start = false): array
{
    $out = [];
    $pre = 'sec#' . $rid . '#' . ($phys + 1) . '#';
    foreach (trail_sight_tallies($uid) as $key => $n) {
        if ($n < 1 || !str_starts_with((string)$key, $pre)) continue;
        $k = substr((string)$key, strlen($pre));
        if ($start && !in_array($k, ['find', 'fog'], true)) continue;
        $fx = $k === 'find' ? 'find:' . max(1, min(3, $n)) : ($k === 'quick' ? 'quick:' . max(5, min(60, $n)) : $k);
        if (preg_match(SIGHTS3A_NXT_RE, $fx)) $out[] = [(string)$key, $fx];
    }
    return $out;
}

/** The named effects were used: forget them. */
function sights4_sec_clear(int $uid, array $pending): void
{
    foreach ($pending as [$key]) { try { q('DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey = ?', [$uid, $key]); } catch (Throwable $e) {} }
}

/**
 * trail_scene_make(), before the scene row is written: the walk's first stretch takes its named find / fog effects and, with the weather setting on, the
 * weather's fog. $st, the tokens in it and nothing else change. Returns [pending rows to clear after the insert, log lines].
 */
function sights4_start_apply(int $uid, int $expId, int $rid, array $map, array &$st): array
{
    try {
        $pending = sights4_sec_pending($uid, $rid, trail_phys_sec($rid, 0, $st), true);
        $lines = [];
        if ($pending) {
            $old = ['st' => ['nxt' => array_column($pending, 1)]];
            $new = ['st' => $st, 'x' => (int)$map['entry'][0], 'y' => (int)$map['entry'][1], 'seen' => ''];
            foreach (sights3a_nxt_prepare($old, $new, $map, false) as $e) $lines[] = str_starts_with($e, 'find') ? '🗺️ ' . ((int)(explode(':', $e)[1] ?? 1) > 1 ? 'Finds wait' : 'A find waits') . ' on this stretch, as you were told.' : '🌫️ Fog lies on this stretch, as you were told: a find shows only when you are next to it.';
            $st = $new['st'];
        }
        $exp = q_one('SELECT * FROM expeditions WHERE id = ?', [$expId]);
        if ($exp && sights4_weather_fog($exp) && sights4_fog_set($st)) $lines[] = '🌫️ Fog lies on the Trail today: a find shows only when you are next to it.';
        return [$pending, $lines];
    } catch (Throwable $e) { error_log('sights4_start_apply: ' . $e->getMessage()); return [[], []]; }
}

/** trail_scene_make(), after the scene row is written: forget the used effects and say them in the walk's log. */
function sights4_start_done(int $uid, int $expId, array $pending, array $lines): void
{
    try {
        sights4_sec_clear($uid, $pending);
        if (!$lines) return;
        $log = json_decode((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$expId]), true) ?: [];
        q('UPDATE expeditions SET log = ? WHERE id = ?', [json_encode(array_values(array_merge($log, $lines))), $expId]);
    } catch (Throwable $e) { error_log('sights4_start_done: ' . $e->getMessage()); }
}

// ---------------------------------------------------------------- 3. penalties (lose:)

/** [the rewards without their lose: tokens, the lose: tokens without the prefix], both comma-joined. */
function sights4_split_lose(string $rewards): array
{
    $win = []; $lose = [];
    foreach (array_filter(array_map('trim', explode(',', $rewards)), fn($t) => $t !== '') as $t) {
        if (str_starts_with($t, 'lose:')) $lose[] = substr($t, 5); else $win[] = $t;
    }
    return [implode(',', $win), implode(',', $lose)];
}

/** Pay the penalties of a lost check ($lose = the lose: tokens, prefix gone). ?cond and @chance work. Lines for the walk log. */
function sights4_lose_pay(array $u, string $lose, array $now): array
{
    $now = sights5_dry_now($now);   // fifth pass: the rain charm keeps a rain penalty off
    $lines = [];
    foreach (trail_sight_tokens($lose) as $t) {
        if ($t['cond'] !== '' && !trail_sight_cond_ok($t['cond'], $now)) continue;
        $tok = $t['tok'];
        if (!trail_sight_chance_pass($tok)) continue;
        [$k, $v] = array_pad(explode('=', $tok, 2), 2, '');
        if ($k === 'time') {
            $tm = max(1, min(480, (int)$v));
            if (function_exists('gclock_on') && gclock_on() && game_spend((int)$u['id'], $tm)) $lines[] = '⏱️ ' . ($tm >= 60 ? round($tm / 60, 1) . ' h' : $tm . ' min') . ' lost';
        } elseif ($k === 'nxt') $lines[] = sights3a_nxt_add($u, $v);
        elseif ($k === 'sec') $lines[] = sights4_sec_add($u, $v);
    }
    return array_values(array_filter($lines, fn($l) => $l !== ''));
}

// ---------------------------------------------------------------- 4. a check whose difficulty depends on the conditions

/** `sense:11?se=spring:9+grit:12` as it stands right now: `sense:9+grit:12` in spring, `sense:11+grit:12` otherwise. A pick is returned as it is. */
function sights4_check_resolve(string $check, array $now): string
{
    $now = sights5_dry_now($now);   // fifth pass: a harder check in rain is not harder for a gnome with the rain charm
    if ($check === '-' || str_starts_with($check, 'pick') || !str_contains($check, '?')) return $check;
    $out = [];
    foreach (explode('+', $check) as $alt) {
        if (preg_match(SIGHTS4_CHECK_RE, $alt, $m) && isset($m[3]) && $m[3] !== '') $out[] = $m[1] . ':' . (trail_sight_cond_ok($m[3], $now) ? $m[4] : $m[2]);
        else $out[] = $alt;
    }
    return implode('+', $out);
}

/** For the Sights card: 'easier' / 'harder' when the conditions change a check's difficulty right now, else ''. */
function sights4_check_note(string $check, array $now): string
{
    $now = sights5_dry_now($now);
    if ($check === '-' || str_starts_with($check, 'pick') || !str_contains($check, '?')) return '';
    $d = 0;
    foreach (explode('+', $check) as $alt) if (preg_match(SIGHTS4_CHECK_RE, $alt, $m) && isset($m[3]) && $m[3] !== '' && trail_sight_cond_ok($m[3], $now)) $d += (int)$m[4] - (int)$m[2];
    return $d < 0 ? 'easier' : ($d > 0 ? 'harder' : '');
}

// ---------------------------------------------------------------- lint

/** Problems with one alternative of a stat check (`stat:dc` or `stat:dc?cond:dc2`). */
function sights4_lint_check_alt(string $alt): array
{
    if (!preg_match(SIGHTS4_CHECK_RE, $alt, $m) || !array_key_exists($m[1], GNOME_STATS) || (int)$m[2] > 25 || (int)($m[4] ?? 0) > 25) return ['check must be stat:difficulty (or stat:dc+stat:dc: either one; stat:dc?cond:dc2 = another difficulty while the condition holds) or pick:N (' . implode(', ', array_keys(GNOME_STATS)) . ')'];
    $bad = [];
    if (isset($m[3]) && $m[3] !== '') foreach (explode('/', $m[3]) as $part) if (!preg_match(TRAIL_SIGHT_COND_RE, trim($part))) $bad[] = 'bad condition "' . $part . '" in the check';
    return $bad;
}

/** Problems with a sec= value or a time= value ($db = look the route up). */
function sights4_lint_token(string $k, string $v, bool $db = true): array
{
    if ($k === 'time' && (!ctype_digit($v) || (int)$v < 1 || (int)$v > 480)) return ['time= needs game minutes 1 to 480'];
    if ($k !== 'sec') return [];
    $p = sights4_sec_parse($v);
    if (!$p) return ['sec= needs <route id>.<stretch 1-6>:<effect> with effect find[:1-3], calm, fog, quick:5-60 or skip (a named stretch)'];
    if (!$db) return [];
    try {
        $r = q_one('SELECT * FROM routes WHERE id = ?', [$p[0]]);
        if (!$r) return ['sec= route ' . $p[0] . ' does not exist'];
        require_once __DIR__ . '/trail_tiles.php';
        $n = max(trail_sections($r), trail_authored_count($p[0]));
        if ($p[1] > $n) return ['sec= route ' . $p[0] . ' has only ' . $n . ' stretch' . ($n === 1 ? '' : 'es')];
    } catch (Throwable $e) {}
    return [];
}

/** Problems with a lose: token of a row ($t = one trail_sight_tokens() entry with 'lose' set, $check = the row's check column, $free = it is a free pick). */
function sights4_lint_lose(array $t, string $check, bool $free): array
{
    $bad = [];
    $k = explode('=', preg_replace('/@\d+$/', '', $t['tok']), 2)[0];
    if (!in_array($k, SIGHTS4_LOSE_KEYS, true)) $bad[] = 'lose: takes only ' . implode('= ', SIGHTS4_LOSE_KEYS) . '= (a penalty on a lost check), not "' . $k . '"';
    if ($check === '-' || $free) $bad[] = 'lose: needs a check or a pick that can be lost';
    if ($t['first']) $bad[] = 'lose: cannot be first:';
    return $bad;
}
