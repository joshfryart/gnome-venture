<?php
declare(strict_types=1);

/**
 * v1.9.3 "road life": the road, the wilds and the delves stop feeling like the same four dice.
 *
 *  - Anti-repeat memory. Every pick (creature, problem, find, off-path choice, sight, ambient line) goes through road_pick(): the last 8
 *    picks of each kind are remembered in users.road_recent (tiny JSON of 4-character tokens). The last 3 are never picked again, the 5
 *    before them count 30% as much. If that leaves nothing, the whole pool is used. The ring is only written inside the transaction and
 *    user-row lock of adventure.php (road_bind() after the lock, road_flush() before commit). Unbound (a GET page, a script) = no memory.
 *  - Conditions. Problems, creatures and gatherables have an optional `cond` (the rest-stop syntax: dp= se= we=, joined with /).
 *    "!dp=night,dusk" is a HARD requirement (the text would be wrong otherwise). A plain cond is a x3 weight when it matches and never
 *    excludes. Rewards never depend on weather: this only changes WHICH thing turns up.
 *  - Ambient lines (data/road_lines.txt): `cond|lands|region|text`, one line per road space, plus the stop's own ambience on arrival.
 */

require_once __DIR__ . '/road_text.php';   // v2.0.4: owner overrides of the road wording (Admin -> Road text)
require_once __DIR__ . '/stops.php';   // stop_now(), stop_cond_ok(), stop_types(), HOLLOW_DAYPARTS

const ROAD_RING_SIZE = 8;     // picks remembered per kind
const ROAD_RING_HARD = 3;     // the last 3 are not picked again
const ROAD_RING_SOFT = 0.3;   // the ones before that count 30%
const ROAD_COND_BOOST = 3;    // a plain cond that matches

// ---------------------------------------------------------------- memory

/** The per-request state (a reference, so every function sees the same array). */
function &road_state(): array
{
    static $s = ['ring' => [], 'dirty' => false, 'bound' => false, 'uid' => 0, 'exp' => null, 'now' => null, 'ts' => null];   // ts: tests only (the clock for who is out on the road)
    return $s;
}

/** A short stable token for a pick (4 hex characters keep the stored JSON well under 300 bytes). */
function road_token(string $key): string
{
    return substr(hash('crc32b', $key), 0, 4);
}

/** Start remembering for this gnome (call after the user-row lock and re-read, so the ring is current). $exp = the walk (sets the weather/region). */
function road_bind(array $u, ?array $exp = null): void
{
    $s = &road_state();
    $s = ['ring' => [], 'dirty' => false, 'bound' => true, 'uid' => (int)$u['id'], 'exp' => $exp, 'now' => null, 'ts' => null];
    $raw = json_decode((string)($u['road_recent'] ?? ''), true);
    if (is_array($raw)) {
        foreach ($raw as $kind => $str) {
            if (is_string($str) && is_string($kind) && preg_match('/^[0-9a-f]*$/', $str)) $s['ring'][$kind] = array_slice(str_split($str, 4), -ROAD_RING_SIZE);
        }
    }
}

/** Forget everything (end of a script or test). */
function road_unbind(): void
{
    $s = &road_state();
    $s = ['ring' => [], 'dirty' => false, 'bound' => false, 'uid' => 0, 'exp' => null, 'now' => null, 'ts' => null];
}

/** The ring as stored (JSON), '' when empty. */
function road_ring_json(): string
{
    $s = &road_state();
    $out = [];
    foreach ($s['ring'] as $kind => $toks) if ($toks) $out[$kind] = implode('', array_slice($toks, -ROAD_RING_SIZE));
    return $out ? (string)json_encode($out) : '';
}

/** Write the ring if it changed. Call inside the transaction, before commit. */
function road_flush(): void
{
    $s = &road_state();
    if (!$s['bound'] || !$s['dirty'] || $s['uid'] < 1) return;
    q('UPDATE users SET road_recent = ? WHERE id = ?', [road_ring_json() ?: null, $s['uid']]);
    $s['dirty'] = false;
}

/** What the Hollow is like on this road right now: ['dp', 'se', 'we'] for the region of the walk (the real clock when unbound). */
function road_now(): array
{
    $s = &road_state();
    if ($s['now'] === null) {
        $loc = [];
        if (!empty($s['exp']) && function_exists('exp_scene')) {
            $sc = exp_scene($s['exp']);
            $loc = (array)($sc['to'] ?? $sc['from'] ?? []);
        }
        $s['now'] = stop_now($loc);   // respects stop_daypart_force and weather_force
    }
    return $s['now'];
}

// ---------------------------------------------------------------- the pick

/**
 * The weight a row's `cond` gives it: 0 = ruled out ("!cond" that does not hold; or any cond when $allHard), 1 = no preference,
 * ROAD_COND_BOOST = a plain cond that matches.
 */
function road_cond_weight(array $row, array $now, bool $allHard = false, string $col = 'cond'): float
{
    $cond = trim((string)($row[$col] ?? ''));
    if ($cond === '' || $cond === '-') return 1.0;
    $hard = $allHard;
    if ($cond[0] === '!') { $hard = true; $cond = substr($cond, 1); }
    $ok = stop_cond_ok($cond, $now);
    if ($hard) return $ok ? 1.0 : 0.0;
    return $ok ? (float)ROAD_COND_BOOST : 1.0;
}

/**
 * Pick one row. Returns its KEY in $rows, or null if every row is ruled out by a hard cond (or $rows is empty).
 * $keyFn: a column name or fn($row, $key) => string: what identifies a row in the memory. $kind: the ring ('cr', 'pr', 'fd', ...).
 * $ctx: 'now' (default road_now()), 'hard' (every cond is a hard one: ambient lines), 'weight' (fn($row) => float, extra weight),
 *       'seed' (string: a pick that is the same every time for that seed, for page views), 'record' (false = do not remember it).
 */
function road_pick_k(array $rows, string $kind, $keyFn, array $ctx = [])
{
    if (!$rows) return null;
    $now = $ctx['now'] ?? road_now();
    $w = [];
    foreach ($rows as $k => $r) {
        $x = road_cond_weight(is_array($r) ? $r : [], $now, !empty($ctx['hard']));
        if ($x > 0 && isset($ctx['weight'])) $x *= max(0.0, (float)($ctx['weight'])($r));
        if ($x > 0) $w[$k] = $x;
    }
    if (!$w) return null;
    $tok = [];
    foreach ($w as $k => $_) {
        $key = is_callable($keyFn) ? (string)$keyFn($rows[$k], $k) : (string)($rows[$k][$keyFn] ?? $k);
        $tok[$k] = road_token($key);
    }
    $s = &road_state();
    $recent = array_reverse($s['ring'][$kind] ?? []);   // newest first
    $pos = [];
    foreach ($recent as $i => $t) if (!isset($pos[$t])) $pos[$t] = $i;
    $hardWin = min(ROAD_RING_HARD, max(0, count($w) - 1));   // a pool of 2 still alternates; a pool of 1 can only repeat
    $w2 = [];
    foreach ($w as $k => $x) {
        if (isset($pos[$tok[$k]])) {
            if ($pos[$tok[$k]] < $hardWin) continue;
            $x *= ROAD_RING_SOFT;
        }
        $w2[$k] = $x;
    }
    if (!$w2) $w2 = $w;   // nothing left: the whole pool
    $units = array_map(fn($x) => max(1, (int)round($x * 100)), $w2);
    $total = array_sum($units);
    $r = isset($ctx['seed']) ? (int)floor(hollow_unit((string)$ctx['seed']) * $total) : random_int(0, $total - 1);
    $pick = array_key_last($units);
    foreach ($units as $k => $n) {
        if ($r < $n) { $pick = $k; break; }
        $r -= $n;
    }
    if ($s['bound'] && ($ctx['record'] ?? true)) {
        $ring = $s['ring'][$kind] ?? [];
        $ring[] = $tok[$pick];
        $s['ring'][$kind] = array_slice($ring, -ROAD_RING_SIZE);
        $s['dirty'] = true;
    }
    return $pick;
}

/** road_pick_k(), but returns the row itself (or null). */
function road_pick(array $rows, string $kind, $keyFn, array $ctx = []): ?array
{
    $k = road_pick_k($rows, $kind, $keyFn, $ctx);
    return $k === null ? null : $rows[$k];
}

/** The active creatures / problems, read once per request (the pickers used to reload them on every call). */
function road_rows(string $table, bool $reload = false): array
{
    static $cache = [];
    if (!in_array($table, ['creatures', 'problems'], true)) return [];
    if ($reload || !isset($cache[$table])) $cache[$table] = q('SELECT * FROM ' . $table . ' WHERE active = 1')->fetchAll();
    return $cache[$table];
}

// ---------------------------------------------------------------- ambient lines

/** data/road_lines.txt as rows [cond, lands[], region[], text]. A line that is not 4 fields or has no text is skipped. */
function road_lines(bool $reload = false): array
{
    static $rows = null;
    if ($rows !== null && !$reload) return $rows;
    $rows = [];
    $path = __DIR__ . '/data/road_lines.txt';
    if (!is_file($path)) return $rows;
    foreach (file($path, FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $f = array_map('trim', explode('|', $line, 4));
        if (count($f) < 4 || $f[3] === '') continue;
        $lands = $f[1] === '' || strtolower($f[1]) === 'any' ? ['any'] : array_values(array_filter(array_map('strtolower', array_map('trim', explode(',', $f[1])))));
        $reg = $f[2] === '' || strtolower($f[2]) === 'any' ? ['any'] : array_values(array_filter(array_map('strtoupper', array_map('trim', explode(',', $f[2])))));
        $rows[] = ['cond' => $f[0] === '' ? '-' : $f[0], 'lands' => $lands ?: ['any'], 'region' => $reg ?: ['any'], 'text' => road_text_apply('road.line.' . road_text_hash($f[3]), $f[3])];   // v2.0.4: Admin -> Road text can override the words
    }
    return $rows;
}

/**
 * One ambient line for a road space: the lines that fit this land, region, time, season and weather; lines that match specifically
 * (a region, a condition) are likelier than generic ones; and not one of the last few shown. $seed makes it repeatable for a page view.
 */
function road_line(array $scene, array $ctx = []): ?string
{
    $land = strtolower((string)($scene['land'] ?? ''));
    $loc = (array)($scene['to'] ?? $scene['from'] ?? []);
    $rc = strtoupper(stop_region_code($loc));
    $pool = [];
    foreach (road_lines() as $r) {
        if ($r['lands'] !== ['any'] && !in_array($land, $r['lands'], true)) continue;
        if ($r['region'] !== ['any'] && !in_array($rc, $r['region'], true)) continue;
        $pool[] = $r;
    }
    $row = road_pick($pool, 'am', 'text', $ctx + ['hard' => true, 'weight' => function (array $r): float {
        return 1 + ($r['region'] !== ['any'] ? 3 : 0) + (trim($r['cond']) !== '-' ? 2 : 0) + ($r['lands'] !== ['any'] ? 1 : 0);
    }]);
    return $row ? $row['text'] : null;
}

/** The seed for the ambient line of a space: the same one for the page (before the click) and for the step itself. $at = the step number, or the journal length when wandering. */
function road_line_seed(array $exp, int $at): string
{
    return 'rl|' . (int)($exp['id'] ?? 0) . '|' . $at;
}

/** The stop type's own ambience for this time of day, for a destination that is a rest stop ('' if it is not). */
function road_arrival_line(array $to): string
{
    if (($to['kind'] ?? '') !== 'village') return '';
    $types = stop_types();
    $type = stop_type_of($to);
    if (!isset($types[$type])) return '';
    $dp = road_now()['dp'];
    $amb = array_map('trim', explode(';;', (string)$types[$type]['ambience']));
    $line = $amb[array_search($dp, ['dawn', 'day', 'dusk', 'night'], true)] ?? ($amb[0] ?? '');
    return $line === '' ? '' : (HOLLOW_DAYPARTS[$dp][0] ?? '🍃') . ' ' . $line;
}

// ---------------------------------------------------------------- result card

/** A journal line like "✅ Hop across: success! (Nimble 14 vs 12) +10 XP" as [class, icon, title, sub] for the small result card. */
function road_result_parts(string $line): array
{
    $icon = '✨';
    $rest = $line;
    if (preg_match('/^(\X)\s+(.*)$/us', $line, $m)) { $icon = $m[1]; $rest = $m[2]; }
    $cls = $icon === '✅' ? 'good' : ($icon === '❌' ? 'bad' : '');
    if (preg_match('/^([^:.]{3,60}?)[:.]\s+(.+)$/us', $rest, $mm)) return [$cls, $icon, $mm[1], $mm[2]];
    return [$cls, $icon, rtrim($rest), ''];
}

// ---------------------------------------------------------------- data: cond column

/** slug => cond from a data file's optional last column (problems 5th, creatures 8th, gatherables 9th). */
function road_cond_map(string $file, int $slugAt, int $condAt): array
{
    $out = [];
    $path = __DIR__ . '/data/' . $file;
    if (!is_file($path)) return $out;
    foreach (file($path, FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $f = array_map('trim', explode('|', $line));
        if (isset($f[$condAt]) && $f[$condAt] !== '' && $f[$condAt] !== '-') $out[$f[$slugAt]] = $f[$condAt];
    }
    return $out;
}

/**
 * Put the cond tags from the data files on rows that already exist. Only rows whose cond is empty are touched, so anything an
 * admin has typed stays. Safe to run again. Returns how many rows got a tag.
 */
function road_cond_backfill(): int
{
    $n = 0;
    foreach (road_cond_map('problems.txt', 0, 4) as $slug => $cond) {
        $n += q("UPDATE problems SET cond = ? WHERE slug = ? AND (cond IS NULL OR cond = '')", [$cond, $slug])->rowCount();
    }
    foreach (road_cond_map('creatures.txt', 0, 7) as $slug => $cond) {
        $n += q("UPDATE creatures SET cond = ? WHERE slug = ? AND (cond IS NULL OR cond = '')", [$cond, $slug])->rowCount();
    }
    foreach (road_cond_map('gatherables.txt', 0, 8) as $slug => $cond) {
        $n += q("UPDATE gatherables SET cond = ? WHERE (cond IS NULL OR cond = '') AND item_id IN (SELECT id FROM items WHERE slug = ?)", [$cond, $slug])->rowCount();
    }
    return $n;
}

// ---------------------------------------------------------------- v1.9.4: choice cards (data/road_events.txt)

const ROAD_ROLL_DEFAULTS = ['creature' => 40, 'problem' => 22, 'choice' => 14, 'find' => 24];   // the shipped split of road spaces

/**
 * v2.0.16: the road roll as settings (road_roll_creature / _problem / _choice / _find). Each is clamped 0-100 and used as a weight;
 * all zero = the shipped split. Returns the cumulative edges and the total: a d100 roll r falls in a band when r * total <= edge * 100
 * (with the defaults the total is 100, so the edges are the old 40 / 62 / 76 exactly).
 */
function road_roll_bands(): array
{
    $w = [];
    foreach (ROAD_ROLL_DEFAULTS as $k => $d) {
        $v = setting('road_roll_' . $k);
        $w[$k] = ($v === null || $v === '' || !is_numeric($v)) ? $d : max(0, min(100, (int)$v));
    }
    if (array_sum($w) <= 0) $w = ROAD_ROLL_DEFAULTS;
    $total = array_sum($w);
    return ['creature' => $w['creature'], 'problem' => $w['creature'] + $w['problem'], 'choice' => $w['creature'] + $w['problem'] + $w['choice'], 'total' => $total];
}
const ROAD_ITEM_CAP = 20;      // an item or find from a road event happens at most this often (percent)
/** v2.0.79: the shapes of a road card. choice = today's; fork = two ways on; riddle = one answer is right; trade = swap goods; chain = leads to the next card; sketch = a journal page. */
const ROAD_EVENT_KINDS = ['choice', 'fork', 'riddle', 'trade', 'chain', 'sketch'];
const ROAD_KIND_LABEL = ['choice' => '', 'fork' => '🔀 A fork in the road', 'riddle' => '🧩 A riddle', 'trade' => '🤝 A trade', 'chain' => '🔗 The story goes on', 'sketch' => '📓 For your road journal'];
const ROAD_LEGACY_EVENTS = 14; // the first 14 scenes keep their order: walks saved before v1.9.4 point at them by number

/** The land / region / where columns: "any" or a comma list (lands lower case, regions upper case). */
function road_event_list(string $s, bool $upper): array
{
    $s = trim($s);
    if ($s === '' || strtolower($s) === 'any' || $s === '-') return ['any'];
    $l = array_values(array_filter(array_map(fn($x) => $upper ? strtoupper(trim($x)) : strtolower(trim($x)), explode(',', $s))));
    return $l ?: ['any'];
}

/**
 * data/road_events.txt: ['ev' => [id => event], 'sights' => [id => sight]] in file order.
 * event: id, cond, lands[], region[], where, icon, text, opts[] (each: label, stat, dc, win, wintext, lose, losetext), n (its number in the file).
 * A malformed row is skipped (never fatal): an E row needs 8 columns, an O row 8, an S row 9.
 */
function road_events(bool $reload = false): array
{
    static $data = null;
    if ($data !== null && !$reload) return $data;
    $data = ['ev' => [], 'sights' => []];
    $path = __DIR__ . '/data/road_events.txt';
    if (!is_file($path)) return $data;
    $cur = null;
    foreach (file($path, FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $f = array_map('trim', explode('|', $line));
        $t = $f[0];
        if ($t === 'E' && count($f) >= 8 && $f[1] !== '' && $f[7] !== '') {
            $cur = $f[1];
            $data['ev'][$cur] = ['id' => $cur, 'cond' => $f[2] === '' ? '-' : $f[2], 'lands' => road_event_list($f[3], false), 'region' => road_event_list($f[4], true),
                'where' => in_array($f[5], ['road', 'wild'], true) ? $f[5] : 'both', 'icon' => $f[6], 'text' => road_text_apply('road.event.' . $cur, $f[7]), 'opts' => [], 'n' => count($data['ev']),
                'kind' => in_array($f[8] ?? '', ROAD_EVENT_KINDS, true) ? $f[8] : 'choice', 'name' => (string)($f[9] ?? '')];   // v2.0.79: kind + journal name (columns 9 and 10, optional)
        } elseif ($t === 'O' && $cur !== null && count($f) >= 8) {
            $ok = 'road.event.' . $cur . '.' . road_text_hash($f[1]) . '.';   // v2.0.4: only the words can be overridden, never stat/dc/effects
            $data['ev'][$cur]['opts'][] = ['label' => road_text_apply($ok . 'label', $f[1]), 'stat' => $f[2], 'dc' => (int)$f[3], 'win' => $f[4], 'wintext' => $f[5] === '' ? '' : road_text_apply($ok . 'win', $f[5]),
                'lose' => $f[6], 'losetext' => $f[7] === '' ? '' : road_text_apply($ok . 'lose', $f[7])];
        } elseif ($t === 'S' && count($f) >= 9 && $f[1] !== '' && $f[7] !== '') {
            $cur = null;
            $data['sights'][$f[1]] = ['id' => $f[1], 'cond' => $f[2] === '' ? '-' : $f[2], 'lands' => road_event_list($f[3], false), 'region' => road_event_list($f[4], true),
                'where' => in_array($f[5], ['road', 'wild'], true) ? $f[5] : 'both', 'icon' => $f[6], 'text' => road_text_apply('road.sight.' . $f[1], $f[7]), 'fx' => $f[8]];
        }
    }
    foreach ($data['ev'] as $id => $e) if (!$e['opts']) unset($data['ev'][$id]);   // a scene with no options cannot be played
    return $data;
}

/** The event a saved encounter points at: by id, or (walks saved before v1.9.4) by its old number. */
function road_event_get(array $enc): ?array
{
    $ev = road_events()['ev'];
    if (isset($enc['ev'])) return $ev[(string)$enc['ev']] ?? null;
    $i = (int)($enc['i'] ?? -1);
    foreach ($ev as $e) if ($e['n'] === $i && $i < ROAD_LEGACY_EVENTS) return $e;
    return null;
}

/** Rows that fit this land, region and place ('road' = on a walk, 'wild' = off the path). */
function road_event_fit(array $rows, array $scene, string $where): array
{
    $land = strtolower((string)($scene['land'] ?? ''));
    $rc = strtoupper(stop_region_code((array)($scene['to'] ?? $scene['from'] ?? [])));
    $out = [];
    foreach ($rows as $r) {
        if ($r['where'] !== 'both' && $r['where'] !== $where) continue;
        if ($r['lands'] !== ['any'] && !in_array($land, $r['lands'], true)) continue;
        if ($r['region'] !== ['any'] && !in_array($rc, $r['region'], true)) continue;
        $out[] = $r;
    }
    return $out;
}

/** Scenes from this region and land are likelier than the generic ones (about half of a starter region's cards are its own). */
function road_event_weight(array $r): float
{
    return 1 + ($r['region'] !== ['any'] ? 3 : 0) + ($r['lands'] !== ['any'] ? 1 : 0);
}

/** A choice card for this place, or null if nothing fits (a "!" cond that fails rules a card out). Not one of the last few shown. */
function road_event_pick(array $scene, string $where, array $ctx = []): ?array
{
    // v2.0.79: a card that only exists as the second half of a chain is never drawn alone (its id starts with chain-), and the same shape never comes twice running
    $pool = array_filter(road_event_fit(road_events()['ev'], $scene, $where), fn($e) => !str_starts_with($e['id'], 'chain-'));
    $s = &road_state();
    $lastKind = (string)(array_slice($s['ring']['ek'] ?? [], -1)[0] ?? '');
    $w = fn($r) => road_event_weight($r) * (($r['kind'] ?? 'choice') !== 'choice' && road_token('k|' . ($r['kind'] ?? '')) === $lastKind ? 0.15 : 1);
    $ev = road_pick($pool, 'oc', 'id', $ctx + ['weight' => $w]);
    if ($ev && $s['bound'] && ($ctx['record'] ?? true)) {
        $s['ring']['ek'] = array_slice(array_merge($s['ring']['ek'] ?? [], [road_token('k|' . ($ev['kind'] ?? 'choice'))]), -ROAD_RING_SIZE);
        $s['dirty'] = true;
    }
    return $ev;
}

/** v2.0.79: the card a chain left for the next space (expeditions.chain = an event id), or null. */
function road_chain_event(array $exp): ?array
{
    $id = trim((string)($exp['chain'] ?? ''));
    return $id !== '' ? (road_events()['ev'][$id] ?? null) : null;
}

/** v2.0.79: how many pages of the Road Journal there are in a region (code), and the entries: [id => name]. */
function road_journal_pages(string $code): array
{
    $out = [];
    foreach (road_events()['ev'] as $e) if (($e['kind'] ?? '') === 'sketch' && $e['name'] !== '' && in_array(strtoupper($code), $e['region'], true)) $out[$e['id']] = $e['name'];
    return $out;
}

/** v2.0.79: stamp a page of the Road Journal. Returns a line to log ('' when you already had it). The whole set pays once. */
function road_journal_add(int $uid, string $entryId, string $regionCode): string
{
    $pages = road_journal_pages($regionCode);
    if (!isset($pages[$entryId])) return '';
    try { db_insert('road_journal', ['user_id' => $uid, 'region' => strtoupper($regionCode), 'entry' => $entryId, 'at' => now()]); }
    catch (PDOException $e) { return ''; }
    $have = (int)q_val("SELECT COUNT(*) FROM road_journal WHERE user_id = ? AND region = ? AND entry <> '_done'", [$uid, strtoupper($regionCode)]);
    $line = '📓 Journal: ' . $pages[$entryId] . ' (' . $have . ' of ' . count($pages) . ')';
    if ($have >= count($pages)) {
        try {
            db_insert('road_journal', ['user_id' => $uid, 'region' => strtoupper($regionCode), 'entry' => '_done', 'at' => now()]);
            require_once __DIR__ . '/rewards.php';
            give_petals($uid, 80 + 10 * (int)q_val('SELECT level FROM users WHERE id = ?', [$uid]), 'road_journal');
            $b = (int)q_val("SELECT id FROM items WHERE slug = 'beeswax'");
            if ($b) give_item($uid, $b, 2);
            $line .= ' 🎉 A full page! You are paid for it.';
        } catch (PDOException $e) { /* paid already */ }
    }
    return $line;
}

/** v2.0.79: the Road Journal as HTML (for the passport): each region with pages found, names of the pages you have. */
function road_journal_html(int $uid): string
{
    $got = [];
    foreach (q("SELECT region, entry FROM road_journal WHERE user_id = ? AND entry <> '_done'", [$uid])->fetchAll() as $r) $got[$r['region']][$r['entry']] = true;
    $h = '';
    $allN = $allPages = 0;
    foreach (q('SELECT code, gnomish_name FROM regions ORDER BY id')->fetchAll() as $rg) {
        $pages = road_journal_pages((string)$rg['code']);
        if (!$pages) continue;
        $n = count(array_intersect_key($pages, $got[$rg['code']] ?? []));
        $allN += $n;
        $allPages += count($pages);
        $jimg = 'assets/img/journal/' . strtolower((string)$rg['code']) . '.png';   // PLACEHOLDER art until drawn (claude/todo-art-variety.md)
        $h .= '<li>' . (pixel_has($jimg) ? '<img class="ico pix rjimg" src="' . e(url($jimg)) . '" alt="" width="48" height="48"> ' : '') . '<b>' . e((string)$rg['gnomish_name']) . '</b> <small class="muted">' . $n . ' of ' . count($pages) . '</small>';
        $names = [];
        foreach ($pages as $id => $nm) $names[] = isset($got[$rg['code']][$id]) ? '<span class="rj-got">' . e($nm) . '</span>' : '<span class="rj-miss">?</span>';
        $h .= '<br><small>' . implode(' · ', $names) . '</small></li>';
    }
    // v2.3.x: a fold (closed) under the passport, with the page count on its summary, so the Stop tab stays short on a phone
    return $h === '' ? '' : '<details class="box fold roadjournal" id="journal"><summary>📓 Road Journal <small class="muted">' . $allN . ' / ' . $allPages . ' pages</small></summary><p class="help">Sketch the sights you meet on the roads. A full page pays.</p><ul class="rj-list">' . $h . '</ul></details>';
}

/** A strange sight (wilds). */
function road_sight_pick(array $scene, array $ctx = []): ?array
{
    $pool = road_event_fit(road_events()['sights'], $scene, 'wild');
    return road_pick($pool, 'os', 'id', $ctx + ['weight' => 'road_event_weight']);
}

/** The icons of every sight (the small result card recognises a journal line that starts with one). */
function road_sight_icons(): array
{
    return array_values(array_unique(array_column(road_events()['sights'], 'icon')));
}

/**
 * Turn an effect string into the one that happens: "@N" after a part = it only happens N% of the time (the dice are rolled here).
 * On a road ($road) any item or find is capped at ROAD_ITEM_CAP percent and can only be a common or uncommon one, and "landmark" is
 * dropped, unless the effect also costs Petals (pay:N): a purchase is a trade, not a gift.
 */
function road_fx_resolve(string $fx, bool $road): string
{
    if (trim($fx) === '') return '';
    $parts = explode('+', $fx);
    $buys = false;
    foreach ($parts as $p) if (str_starts_with(trim($p), 'pay:')) $buys = true;
    $out = [];
    foreach ($parts as $part) {
        $part = trim($part);
        $chance = null;
        if (preg_match('/^(.*)@(\d{1,3})$/', $part, $m)) { $part = $m[1]; $chance = min(100, (int)$m[2]); }
        $k = explode(':', $part, 2)[0];
        if ($road && $k === 'landmark') continue;
        if ($road && !$buys && in_array($k, ['item', 'rand'], true)) {
            $chance = min($chance ?? 100, ROAD_ITEM_CAP);
            if ($k === 'rand' && !in_array(explode(':', $part)[1] ?? '', ['forage', 'uncommon', 'food'], true)) $part = 'rand:forage';
        }
        if ($chance !== null && random_int(1, 100) > $chance) continue;
        if ($part !== '') $out[] = $part;
    }
    return implode('+', $out);
}

// ---------------------------------------------------------------- v1.9.4: villagers and travellers met on the road

const ROAD_MEET_PCT = 30;        // of the road spaces that would have been a find, when somebody is about
const ROAD_FOLK_OUT_PCT = 40;    // a villager is "out on the road" in this share of 3-hour blocks (a hash of the clock, the same for everyone)
const ROAD_TRAVEL_WINDOW = 2 * 3600;   // a traveller is on the road into / out of a town for the first / last 2 hours of their stay

/** data/road_meet.txt as rows [cond, who[], text]. */
function road_meet_lines(bool $reload = false): array
{
    static $rows = null;
    if ($rows !== null && !$reload) return $rows;
    $rows = [];
    foreach (stops_file_rows('road_meet.txt') as $f) {
        if (count($f) < 3 || $f[2] === '') continue;
        $rows[] = ['cond' => $f[0] === '' ? '-' : $f[0], 'who' => array_values(array_filter(array_map('trim', explode(',', $f[1])))), 'text' => $f[2]];
    }
    return $rows;
}

/** The stops either side of a stop on its road (ids). */
function road_neighbours(int $locId): array
{
    static $memo = [];
    if (isset($memo[$locId])) return $memo[$locId];
    $out = [];
    foreach (q("SELECT a_id, b_id FROM routes WHERE kind = 'road' AND (a_id = ? OR b_id = ?) ORDER BY id", [$locId, $locId])->fetchAll() as $r) {
        $out[] = (int)$r['a_id'] === $locId ? (int)$r['b_id'] : (int)$r['a_id'];
    }
    return $memo[$locId] = array_values(array_unique($out));
}

/**
 * Who is about on this leg of a road at a moment ($ts, default now). A pure function of the Hollow's clock: no row is ever written to move
 * anyone. A villager of one end of the road is "out" in about 40% of 3-hour blocks, and walks toward ONE of the stops next to their own
 * (picked by a hash), so they are on this leg only when that stop is the other end of it. A travelling NPC is on the road into the town's
 * market in the first 2 hours of their stay there, and on the road out of it in the last 2. Returns candidates, in a stable order:
 *   ['w' => 'f', 'folk' => row, 'home' => loc row, 'dest' => loc row]  or  ['w' => 't', 'npc' => row, 'dir' => 'in'|'out', 'town' => name, 'other' => name]
 */
function road_meet_candidates(array $scene, ?int $ts = null): array
{
    $ts ??= time();
    $from = (array)($scene['from'] ?? []);
    $to = (array)($scene['to'] ?? []);
    if (!$from || !$to) return [];
    require_once __DIR__ . '/stop_folk.php';   // also loads npc_life.php (travellers)
    $day = hollow_date('Y-m-d', $ts);
    $blk = intdiv((int)hollow_date('G', $ts), 3);
    $out = [];
    foreach ([[$from, $to], [$to, $from]] as [$home, $dest]) {
        if (($home['kind'] ?? '') !== 'village') continue;
        $nb = road_neighbours((int)$home['id']);
        foreach (stop_folk_of($home) as $f) {
            if (crc32('rmout|' . $day . '|' . $blk . '|' . $f['id']) % 100 >= ROAD_FOLK_OUT_PCT) continue;
            $want = $nb ? $nb[crc32('rmdir|' . $day . '|' . $blk . '|' . $f['id']) % count($nb)] : (int)$dest['id'];
            if ($want !== (int)$dest['id']) continue;
            $out[] = ['w' => 'f', 'folk' => $f, 'home' => $home, 'dest' => $dest];
        }
    }
    foreach (q('SELECT * FROM npcs WHERE traveller IS NOT NULL AND active = 1 ORDER BY id')->fetchAll() as $t) {
        $s = traveller_stop($t, $ts);
        $started = $s['starts'] ?? ($s['ends'] - TRAVEL_STOP_HOURS * 3600);   // next version: the Gourmand's stay is whole days
        $town = (string)$s['town'];
        $touches = false;
        foreach ([$from, $to] as $l) if (($l['kind'] ?? '') === 'market' && (string)($l['region'] ?? '') === $town) $touches = true;
        if (!$touches) continue;
        if ($ts - $started < ROAD_TRAVEL_WINDOW) {
            $out[] = ['w' => 't', 'npc' => $t, 'dir' => 'in', 'town' => $town, 'other' => (string)traveller_stop($t, $started - 1)['town']];
        } elseif ($s['ends'] - $ts <= ROAD_TRAVEL_WINDOW) {
            $out[] = ['w' => 't', 'npc' => $t, 'dir' => 'out', 'town' => $town, 'other' => (string)$s['next']];
        }
    }
    return $out;
}

/** The ring key of a candidate. */
function road_meet_key(array $c): string
{
    return $c['w'] === 'f' ? 'f' . $c['folk']['id'] : 't' . $c['npc']['id'];
}

/** Pick one of the people about, not one of the last few met. Null if nobody is about. */
function road_meet_pick(array $scene, ?int $ts = null): ?array
{
    $c = road_meet_candidates($scene, $ts);
    return $c ? road_pick($c, 'mt', fn($r) => road_meet_key($r), ['record' => false]) : null;
}

/** A line from road_meet.txt for who they are ('@folk', '@trav-in', '@trav-out' for the card; otherwise the chat), with the placeholders filled in. */
function road_meet_text(string $kind, array $who, array $vars, array $now): string
{
    $pool = [];
    foreach (road_meet_lines() as $r) {
        if (!array_intersect($r['who'], $kind[0] === '@' ? [$kind] : array_merge($who, ['any']))) continue;
        $pool[] = $r;
    }
    $row = road_pick($pool, $kind[0] === '@' ? 'mi' : 'mc', 'text', ['now' => $now, 'hard' => true, 'weight' => function (array $r) use ($who): float {
        return 1 + (array_intersect($r['who'], $who) ? 3 : 0) + (trim($r['cond']) !== '-' ? 2 : 0);
    }]);
    if (!$row) return '';
    $find = $rep = [];
    foreach ($vars as $k => $v) { $find[] = '{' . $k . '}'; $rep[] = (string)$v; }
    return str_replace($find, $rep, $row['text']);
}

/** Turn a candidate into the encounter on the road (and log what you see). The card keeps everything it shows, so it needs no lookups. */
function road_meet_start(array $u, array &$exp, array $c): void
{
    $now = road_now();
    $gname = (string)($u['gnome_name'] ?: $u['username']);
    if ($c['w'] === 'f') {
        $f = $c['folk'];
        $vars = ['name' => $gname, 'folk' => $f['name'], 'role' => strtolower((string)$f['role']), 'place' => $c['home']['name'], 'dest' => $c['dest']['name']];
        $intro = road_meet_text('@folk', [], $vars, $now);
        $chat = road_meet_text('chat', [(string)$f['personality']], $vars, $now);
        $enc = ['type' => 'meet', 'w' => 'f', 'id' => (int)$f['id'], 'loc' => (int)$c['home']['id'], 'ic' => npc_icon($f['species']), 'n' => $f['name'],
            's' => trim((string)$f['role'] . ' · ' . $c['home']['name']), 't' => $intro, 'l' => $chat];
    } else {
        $t = $c['npc'];
        $vars = ['name' => $gname, 'folk' => $t['name'], 'place' => $c['town'], 'dest' => $c['dir'] === 'in' ? $c['town'] : $c['other'], 'from' => $c['other']];
        $intro = road_meet_text($c['dir'] === 'in' ? '@trav-in' : '@trav-out', [], $vars, $now);
        $chat = road_meet_text('chat', [(string)$t['traveller'], (string)$t['personality']], $vars, $now);
        $enc = ['type' => 'meet', 'w' => 't', 'id' => (int)$t['id'], 'loc' => 0, 'ic' => npc_icon($t['species']), 'n' => $t['name'],
            's' => 'Travelling ' . ($t['traveller'] === 'gourmand' ? 'food writer' : (string)$t['traveller']), 't' => $intro, 'l' => $chat];
    }
    if ($enc['t'] === '') $enc['t'] = $enc['n'] . ' is out on the road.';
    if ($enc['l'] === '') $enc['l'] = '“Hello, ' . $gname . '.”';
    road_pick([['k' => road_meet_key($c)]], 'mt', 'k');   // remember them (the ring), so the same person is not met again straight away
    $exp['encounter'] = json_encode($enc, JSON_UNESCAPED_UNICODE);
    exp_log($exp, $enc['ic'] . ' ' . $enc['t']);
}

/**
 * Answer a meeting: option 0 = stop for a chat (uses up that person's once-a-day chat, the same claim as at the stop), 1 = wave and walk on.
 * Nothing is paid here that the chat at the stop would not pay.
 */
function road_meet_resolve(array $u, array &$exp, int $option): void
{
    $enc = json_decode((string)$exp['encounter'], true);
    if (!is_array($enc) || ($enc['type'] ?? '') !== 'meet' || !in_array($option, [0, 1], true)) return;
    $exp['encounter'] = null;
    if ($option === 1) {
        exp_log($exp, '👋 You wave to ' . $enc['n'] . ' and walk on.');
        return;
    }
    $uid = (int)$u['id'];
    if ($enc['w'] === 'f') {
        require_once __DIR__ . '/stop_folk.php';
        $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$enc['loc']]);
        if (!$loc) { exp_log($exp, '👋 You wave to ' . $enc['n'] . ' and walk on.'); return; }
        [, $msg] = stop_chat($u, $loc, (int)$enc['id'], (string)$enc['l']);
        exp_log($exp, '💬 ' . $msg);
        return;
    }
    exp_log($exp, '💬 ' . road_traveller_chat($u, (int)$enc['id'], (string)$enc['l']));
}

/** Chat with a travelling NPC on the road: the same once-a-day claim and the same pay as npc_talk() (friendship, chat XP), minus its gifts and tips. */
function road_traveller_chat(array $u, int $npcId, string $line): string
{
    require_once __DIR__ . '/friends.php';
    $uid = (int)$u['id'];
    $npc = q_one('SELECT * FROM npcs WHERE id = ? AND active = 1', [$npcId]);
    if (!$npc) return 'They have gone on ahead.';
    $head = npc_icon($npc['species']) . ' ' . $npc['name'] . ': ' . $line;
    $today = hollow_date('Y-m-d');
    if (!friend_claim($uid, $npcId, 'last_talk', $today)) return $head . ' (you’ve already had your chat today)';
    $f = friendship($uid, $npcId);
    $gain = max(1, 3 + eff_mod($u, 'charm'));
    $before = friend_level((int)$f['points']);
    $new = friend_add($uid, $npcId, $gain, ['talks' => (int)$f['talks'] + 1]);
    $xp = (int)setting('friend_chat_xp');
    if ($xp > 0) add_xp($uid, $xp, 'Chatting with folk');
    unlock_entries($uid, 'npc:' . $npc['slug']);
    calling_event($uid, 'talk', (string)$npc['slug'], 1, ['npc' => (string)$npc['slug']]);
    $after = friend_level($new);
    return $head . ' (+' . $gain . ' friendship' . ($xp > 0 ? ', +' . $xp . ' XP' : '') . ')' . ($after['index'] > $before['index'] ? ' 💛 You and ' . $npc['name'] . ' are now: ' . $after['name'] . '!' : '');
}
