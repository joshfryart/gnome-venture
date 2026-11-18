<?php
declare(strict_types=1);

/**
 * 2.7.08 third pass A: Sights engine gaps (claude/sights/GRAMMAR.md "2.7.08 third pass A"; test tests/trail_sights_280.sh).
 *  1. A second lucky-moment slot: `buff2=stat:amount[:minutes|sleep|delve|section]` (users.ev2_* columns, next to ev_*). `buff=` keeps slot 1, so a row
 *     can carry two buffs at once. eff_stat / active_effects (gnome.php) read both slots.
 *  2. Lair hints from real state: `hint=snore|webhum|glow|rut` = how many nights the lair ahead has slept since this gnome last went in
 *     (landmark_uses rows, action 'lair': one per run, kept for good).
 *  3. `hint=firstroom`: the first row of rooms of the delve ahead (the route is seeded per gnome, delve and day: dv2_seed), and a note in the delve's
 *     log when the run starts (the delve-start hook sights3a_delve_start, called by delve_start()).
 *  4. `nxt=find[:N]|calm|quick:N|skip|peek`: effects on the NEXT Trail stretch, kept in the walk scene state (st.nxt) and used up once when trail_next()
 *     enters it (peek tells it at once).
 * Everything here is new functions; the engine files only call them.
 */

const SIGHTS3A_EV2_COLS = [['users', 'ev2_stat', 'VARCHAR(10) NULL'], ['users', 'ev2_amt', 'INT NOT NULL DEFAULT 0'], ['users', 'ev2_until', 'DATETIME NULL'], ['users', 'ev2_day', 'INT NULL'], ['users', 'ev2_scope', 'VARCHAR(10) NULL']];
const SIGHTS3A_LAIR_HINTS = ['snore', 'webhum', 'glow', 'rut'];
const SIGHTS3A_HINTS = ['snore', 'webhum', 'glow', 'rut', 'firstroom'];
const SIGHTS3A_NXT_RE = '/^(find(:[1-3])?|calm|quick:([5-9]|[1-5]\d|60)|skip|peek)$/';

// ---------------------------------------------------------------- 1. the second lucky moment

/** Add the ev2_* columns if they are missing (the schema.php list does this on an upgrade; this is the safety net for a copy that has not upgraded yet). Same ALTER as db_migrate: works on SQLite and MySQL. */
function sights3a_ev2_columns(): void
{
    foreach (SIGHTS3A_EV2_COLS as [$t, $c, $d]) {
        try { db()->query("SELECT $c FROM $t LIMIT 1"); }
        catch (Throwable $e) { try { db()->exec("ALTER TABLE $t ADD COLUMN $c $d"); } catch (Throwable $e2) { error_log('sights3a_ev2_columns: ' . $e2->getMessage()); } }
    }
}

/** The second slot's UPDATE; on a missing column the columns are added and it is tried once more. */
function sights3a_ev2_write(string $set, array $args): bool
{
    for ($try = 0; $try < 2; $try++) {
        try { q('UPDATE users SET ' . $set . ' WHERE id = ?', $args); return true; }
        catch (Throwable $e) { if ($try === 0) sights3a_ev2_columns(); }
    }
    return false;
}

/** buff2:stat:amount[:minutes|sleep|delve|section] (apply_event_effect's 'buff2' case): the same lengths as the first slot, kept in users.ev2_*. Lines for the box. */
function sights3a_buff2_apply(int $uid, array $p): array
{
    $stat = (string)($p[1] ?? ''); $amt = (int)($p[2] ?? 1); $len = (string)($p[3] ?? '');
    if (!isset(GNOME_STATS[$stat]) && $stat !== 'all') return [];
    $bl = $stat === 'all' ? ['every stat', '✨'] : GNOME_STATS[$stat];
    $far = gmdate('Y-m-d H:i:s', time() + 30 * 86400);
    if ($len === 'section' && function_exists('gnome_walk_section') && ($wk = gnome_walk_section($uid)) !== null) {
        $ok = sights3a_ev2_write('ev2_stat = ?, ev2_amt = ?, ev2_until = ?, ev2_day = ?, ev2_scope = ?', [$stat, $amt, $far, $wk, 'section', $uid]); $txt = 'until the next section';
    } elseif ($len === 'delve') {
        $ok = sights3a_ev2_write('ev2_stat = ?, ev2_amt = ?, ev2_until = ?, ev2_day = NULL, ev2_scope = ?', [$stat, $amt, $far, 'delve', $uid]); $txt = 'in delves and lairs';
    } elseif ($len === 'sleep' && function_exists('gclock_on') && gclock_on()) {
        $ok = sights3a_ev2_write('ev2_stat = ?, ev2_amt = ?, ev2_until = ?, ev2_day = game_day, ev2_scope = NULL', [$stat, $amt, $far, $uid]); $txt = 'until you sleep';
    } else {
        $min = ctype_digit($len) && (int)$len > 0 ? (int)$len : 60;
        $ok = sights3a_ev2_write('ev2_stat = ?, ev2_amt = ?, ev2_until = ?, ev2_day = NULL, ev2_scope = NULL', [$stat, $amt, gmdate('Y-m-d H:i:s', time() + $min * 60), $uid]); $txt = 'for ' . $min . ' minutes';
    }
    return $ok ? [$bl[1] . ' +' . $amt . ' ' . $bl[0] . ' ' . $txt] : [];
}

// ---------------------------------------------------------------- 2. and 3. hints from real state

/** The lair or delve the walk is heading for (destination of the active walk), else the first one of the start place's region. Location row or null. */
function sights3a_ahead(array $u, array $loc, string $kind): ?array
{
    try {
        if (function_exists('active_expedition') && ($ex = active_expedition((int)$u['id']))) {
            $d = q_one('SELECT l.* FROM locations l JOIN landmarks lm ON lm.location_id = l.id WHERE l.id = ? AND lm.kind = ?', [(int)$ex['to_id'], $kind]);   // by the landmark's kind: a delve stands at a 'wonder' location
            if ($d) return $d;
        }
        return q_one('SELECT l.* FROM locations l JOIN landmarks lm ON lm.location_id = l.id WHERE lm.kind = ? AND l.region_id = ? ORDER BY l.id LIMIT 1', [$kind, (int)($loc['region_id'] ?? 0)]) ?: null;
    } catch (Throwable $e) { return null; }
}

/** Nights since this gnome last went into the lair (landmark_uses, action 'lair', by the landmark day), or null = never. */
function sights3a_lair_nights(int $uid, int $lmId): ?int
{
    $last = (string)q_val("SELECT MAX(day) FROM landmark_uses WHERE user_id = ? AND landmark_id = ? AND action = 'lair'", [$uid, $lmId]);
    if ($last === '') return null;
    return max(0, (int)round((strtotime(landmark_day() . ' 00:00:00 UTC') - strtotime($last . ' 00:00:00 UTC')) / 86400));
}

/** hint=snore|webhum|glow|rut|firstroom: a true line ('' when there is nothing to tell). */
function sights3a_hint(array $u, array $loc, string $kind): string
{
    try {
        require_once __DIR__ . '/landmarks.php';
        if (in_array($kind, SIGHTS3A_LAIR_HINTS, true)) {
            $at = sights3a_ahead($u, $loc, 'lair'); $lm = $at ? landmark_at((int)$at['id']) : null;
            if (!$lm) return '';
            $boss = lair_boss($lm); $who = $boss ? 'the ' . $boss['name'] : 'whoever lives in ' . $at['name'];
            $n = sights3a_lair_nights((int)$u['id'], (int)$lm['id']);
            $since = $n === null ? 'you have never gone in, so ' . $who . ' has slept undisturbed by you' : ($n === 0 ? 'you went in today, so ' . $who . ' is wide awake' : $n . ' night' . ($n === 1 ? '' : 's') . ' since you last went in: ' . $who . ' is ' . ($n >= 7 ? 'deep asleep' : ($n >= 3 ? 'sound asleep' : 'only dozing')));
            $deep = $n === null || $n >= 3; $cnt = $n === null ? 'past counting' : (string)min(99, $n);
            return match ($kind) {
                'snore' => '💤 Snores: ' . $cnt . '. ' . ucfirst($since) . '.',
                'webhum' => '🕸️ The thread hums ' . ($deep ? 'low and slow' : 'high and twitchy') . ': ' . $since . '.',
                'glow' => '🪼 The glow pulses ' . ($deep ? 'slowly' : 'fast') . ': ' . $since . '.',
                default => '📏 The rut is ' . ($n === null ? 'old and smooth' : ($n === 0 ? 'fresh' : $cnt . ' day' . ($n === 1 ? '' : 's') . ' old')) . ': ' . $since . '.',
            };
        }
        if ($kind === 'firstroom') {
            $at = sights3a_ahead($u, $loc, 'delve'); $lm = $at ? landmark_at((int)$at['id']) : null;
            if (!$lm) return '';
            require_once __DIR__ . '/delve_map.php';
            if (!dv_on()) return '';
            $words = sights3a_first_rooms((int)$u['id'], $lm, null);
            if ($words === '') return '';
            if (function_exists('trail_sight_tally_set')) trail_sight_tally_set((int)$u['id'], 'dvhint#' . (int)$lm['id'], sights3a_day_no());   // the delve-start hook says it again inside
            return '🕯️ The way into ' . $lm['name'] . ' opens today on ' . $words . '.';
        }
    } catch (Throwable $e) { error_log('sights3a_hint: ' . $e->getMessage()); }
    return '';
}

function sights3a_day_no(): int { return (int)floor(strtotime(landmark_day() . ' 00:00:00 UTC') / 86400); }

/** The first row of a v2 delve route as words ("a fight, a treasure room or a puzzle"). $seed = the run's own route seed, or null = today's seed for this gnome. */
function sights3a_first_rooms(int $uid, array $lm, ?string $seed): string
{
    require_once __DIR__ . '/delve_v2.php';
    $route = dv_route($seed ?? dv2_seed($uid, (int)$lm['id']), dv2_slug($lm), dv_stages((int)$lm['level']));
    $name = ['fight' => 'a fight', 'treasure' => 'a treasure room', 'mystery' => 'a mystery room', 'puzzle' => 'a puzzle room', 'shrine' => 'a shrine', 'mole' => 'a mole', 'boss' => 'the guardian'];
    $w = array_values(array_unique(array_map(fn($n) => $name[$n['kind']] ?? $n['kind'], $route['rows'][0] ?? [])));
    if (!$w) return '';
    return count($w) === 1 ? $w[0] : implode(', ', array_slice($w, 0, -1)) . ' or ' . end($w);
}

/** Delve-start hook (delve_start): a gnome told by hint=firstroom hears it again in the delve's log, from the run's real route. The note is used up. */
function sights3a_delve_start(int $uid, array $lm, int $expId): void
{
    try {
        $key = 'dvhint#' . (int)$lm['id'];
        $day = (int)q_val('SELECT n FROM trail_sight_tally WHERE user_id = ? AND tkey = ?', [$uid, $key]);
        if ($day <= 0) return;
        q('DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey = ?', [$uid, $key]);
        $row = q_one("SELECT state FROM walk_scene WHERE exp_id = ? AND user_id = ? AND map_key = 'v2'", [$expId, $uid]);
        $st = $row ? json_decode((string)$row['state'], true) : null;
        if (!is_array($st) || empty($st['rs'])) return;
        $words = sights3a_first_rooms($uid, $lm, (string)$st['rs']);
        if ($words === '') return;
        $line = $day === sights3a_day_no() ? '🕯️ Just as the Sight told you: the first rooms are ' . $words . '.' : '🕯️ The rooms have shifted since the Sight told you: today the first ones are ' . $words . '.';
        $log = json_decode((string)q_val('SELECT log FROM expeditions WHERE id = ?', [$expId]), true) ?: [];
        $log[] = $line;
        q('UPDATE expeditions SET log = ? WHERE id = ?', [json_encode(array_values($log)), $expId]);
    } catch (Throwable $e) { error_log('sights3a_delve_start: ' . $e->getMessage()); }
}

// ---------------------------------------------------------------- 4. effects on the next Trail stretch

/** nxt=<effect>: kept for the next stretch of the active Trail walk (peek: told at once). Returns the line. */
function sights3a_nxt_add(array $u, string $v): string
{
    if (!preg_match(SIGHTS3A_NXT_RE, $v)) return '';
    try {
        $exp = function_exists('active_expedition') ? active_expedition((int)$u['id']) : null;
        $sc = $exp && function_exists('trail_scene') ? trail_scene($exp) : null;
        if (!$sc) return '';
        $sec = (int)$sc['st']['sec'];
        if ($sec + 1 >= (int)$sc['st']['S']) return '🗺️ No stretch is left on this walk for that.';
        if ($v === 'peek') {
            $rid = (int)substr((string)$sc['row']['map_key'], 6);
            $hist = (array)($sc['st']['hist'] ?? []);
            $toks = $hist[$sec + 1] ?? null;
            if ($toks === null) { [, $tk] = trail_map_make(trail_seed($rid, (int)$u['id'], (int)($sc['st']['sx'] ?? $exp['id']), $sec + 1, $sc['st'])); $toks = trail_pickup_apply((int)$u['id'], $rid, trail_phys_sec($rid, $sec + 1, $sc['st']), array_map(fn($t) => [$t[0], $t[1], $t[2], 0], $tk)); }
            $n = count(array_filter($toks, fn($t) => $t[2] === 'F' && (int)$t[3] === 0));
            foreach ((array)($sc['st']['nxt'] ?? []) as $e) if (str_starts_with($e, 'find')) $n += (int)(explode(':', $e)[1] ?? 1);
            return '🔭 ' . ($n ? 'The next stretch has ' . $n . ' find' . ($n === 1 ? '' : 's') . ' waiting.' : 'Nothing to find on the next stretch.');
        }
        $sc['st']['nxt'] = array_values(array_merge((array)($sc['st']['nxt'] ?? []), [$v]));
        if (!trail_save($sc)) return '';
        [$k, $a] = array_pad(explode(':', $v, 2), 2, '');
        return match ($k) {
            'find' => '🗺️ ' . ((int)$a > 1 ? (int)$a . ' finds wait' : 'A find waits') . ' on the next stretch',
            'calm' => '🍃 The next stretch begins quietly',
            'quick' => '⏱️ You will reach the next stretch ' . (int)$a . ' game minutes sooner',
            default => '🪜 A shortcut: you will skip most of the next stretch',
        };
    } catch (Throwable $e) { error_log('sights3a_nxt_add: ' . $e->getMessage()); return ''; }
}

/**
 * trail_next(), before its save: use up the old stretch's pending nxt effects on the new one ($new: tokens, position, phase). A revisited stretch keeps
 * them for the next new one. Also carries the escort (2.7.06: "for the rest of this walk"). Returns the effects to finish after the save.
 */
function sights3a_nxt_prepare(array $old, array &$new, array $map, bool $revisit): array
{
    if (!empty($old['st']['escort'])) $new['st']['escort'] = $old['st']['escort'];
    $fx = array_values(array_filter((array)($old['st']['nxt'] ?? []), fn($e) => is_string($e) && preg_match(SIGHTS3A_NXT_RE, $e)));
    if (!$fx) return [];
    if ($revisit) { $new['st']['nxt'] = $fx; return []; }
    $done = [];
    foreach ($fx as $e) {
        [$k, $a] = array_pad(explode(':', $e, 2), 2, '');
        if ($k === 'find') {
            $want = max(1, (int)($a ?: 1)); $en = $map['entry']; $ex = $map['spots']['9'] ?? [-9, -9];
            $taken = []; foreach ($new['st']['tokens'] as $t) $taken[(int)$t[0] . ',' . (int)$t[1]] = 1;
            $cand = [];
            for ($y = 0; $y < $map['h']; $y++) for ($x = 0; $x < $map['w']; $x++) {
                if (!in_array(tm_tile($map, $x, $y), ['.', ','], true) || isset($taken[$x . ',' . $y]) || abs($x - $en[0]) + abs($y - $en[1]) < 2 || ($x === $ex[0] && $y === $ex[1])) continue;
                if (tm_path($map, (int)$en[0], (int)$en[1], $x, $y)) $cand[] = [$x, $y];
            }
            $h = crc32((string)($new['st']['sx'] ?? 0) . '|' . (int)$new['st']['sec']);
            for ($i = 0; $i < $want && $cand; $i++) { [$cx, $cy] = array_splice($cand, ($h + $i * 7) % count($cand), 1)[0]; $new['st']['tokens'][] = [$cx, $cy, 'F', 0]; }
        } elseif ($k === 'skip' && isset($map['spots']['9'])) {
            [$new['x'], $new['y']] = [(int)$map['spots']['9'][0], (int)$map['spots']['9'][1]];
            tm_reveal($new['seen'], $map['w'], $map['h'], $new['x'], $new['y'], 20);
            $new['st']['phase'] = 'confirm';
        }
        $done[] = $e;
    }
    return $done;
}

/** trail_next(), after its save: game time back, the log lines. True = calm (no in-between event at this stretch's door). */
function sights3a_nxt_finish(array $u, array &$exp, array $done): bool
{
    $calm = false;
    foreach ($done as $e) {
        [$k, $a] = array_pad(explode(':', $e, 2), 2, '');
        if ($k === 'calm') { $calm = true; exp_log($exp, '🍃 The stretch begins quietly, as you were told.'); }
        elseif ($k === 'find') exp_log($exp, '🗺️ ' . (max(1, (int)$a) > 1 ? 'Finds wait' : 'A find waits') . ' on this stretch, as you were told.');
        elseif ($k === 'quick') { $m = sights3a_time_back((int)$u['id'], (int)$a); exp_log($exp, '⏱️ A quick stretch' . ($m > 0 ? ': ' . $m . ' game minutes back' : '') . '.'); }
        elseif ($k === 'skip') { $m = sights3a_time_back((int)$u['id'], function_exists('gclock_time_cost') ? gclock_time_cost('travel') : 0); exp_log($exp, '🪜 You take the shortcut to the end of this stretch' . ($m > 0 ? ' (' . $m . ' game minutes back)' : '') . '.'); }
    }
    return $calm;
}

/** Give back up to $m game minutes of today (never before the wake-up time). Returns the minutes given back (0 with the game clock off). */
function sights3a_time_back(int $uid, int $m): int
{
    if ($m <= 0 || !function_exists('gclock_on') || !gclock_on()) return 0;
    $now = (int)q_val('SELECT game_minute FROM users WHERE id = ?', [$uid]);
    $back = max(0, min($m, $now - GAME_WAKE_MINUTE));
    if ($back > 0) q('UPDATE users SET game_minute = game_minute - ? WHERE id = ? AND game_minute = ?', [$back, $uid, $now]);
    return $back;
}

// ---------------------------------------------------------------- lint

/** Problems with one of this pass's tokens ($k = the token key, $v = its value). */
function sights3a_lint_token(string $k, string $v): array
{
    if ($k === 'buff2' && (!preg_match('/^([a-z]+):(\d{1,2})(:(\d{1,4}|sleep|delve|section))?$/', $v, $bm) || !($bm[1] === 'all' || array_key_exists($bm[1], GNOME_STATS)))) return ['buff2= needs stat:amount[:minutes|sleep|delve|section] (the second lucky moment; stat: ' . implode(', ', array_keys(GNOME_STATS)) . ', or all)'];
    if ($k === 'nxt' && !preg_match(SIGHTS3A_NXT_RE, $v)) return ['nxt= needs find[:1-3], calm, quick:5-60, skip or peek (the next Trail stretch)'];
    return [];
}

/** Whole-row problems: two unconditional buff= (the second would only replace the first: use buff2=). $toks = trail_sight_tokens(). */
function sights3a_lint_row(array $toks): array
{
    $plain = array_filter($toks, fn($t) => str_starts_with($t['tok'], 'buff=') && $t['cond'] === '' && !str_contains($t['tok'], '@') && !$t['first']);
    return count($plain) > 1 ? ['two buff= in one row: the second replaces the first; write the second as buff2= (a second lucky moment)'] : [];
}
