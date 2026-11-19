<?php
declare(strict_types=1);

/**
 * Trail Sights (v2.6.68, P0 spike; plan claude/plan-trail-sights.md): the big set pieces (landmark sprites) on a Trail map can be used by a gnome standing
 * ON or NEXT TO them (the 8 tiles round the landmark's tile, like fishing by water). One button under the map, 1 energy, a cooldown per section.
 * Data: data/trail_sights.txt. Rewards and the stat check reuse the rest-stop engine (stops.php: stop_rewards, stop_check, stop_cond_ok).
 */

require_once __DIR__ . '/trail_sight_extras.php';
require_once __DIR__ . '/trail_sight_third_b.php';   // 2.7.08 third pass B: birthdays, letters, bottle post, board / green quest lines, growing seeds, keepsakes
require_once __DIR__ . '/trail_sights_3a.php';   // 2.7.08 third pass A: buff2=, lair / delve hints, nxt=
require_once __DIR__ . '/trail_sights_6.php';   // sixth pass B: Sights shared across players (notes, chalk, the cairn count)
require_once __DIR__ . '/trail_sights_5.php';   // fifth pass: an item as a check alternative, a villager's check with a miss line, any-of takes over a category, scoped shop discounts, Sight kinds (nextkind=), a season quest limit
require_once __DIR__ . '/trail_sights_4.php';   // fourth pass: fog (nxt=fog, nxt=lit), a named stretch (sec=), penalties (lose:), a check that depends on the conditions

const TRAIL_SIGHT_HINTS = ['weather', 'season', 'away', 'creature', 'tide', 'moon', 'snore', 'webhum', 'glow', 'rut', 'firstroom'];   // snore webhum glow rut firstroom: 2.7.08 third pass A (trail_sights_3a.php)   // hint=<kind>: a true line from the game state (tide and moon: 2.7.08)
const TRAIL_SIGHT_COLS = ['slug', 'verb', 'icon', 'energy', 'cd', 'uses', 'when', 'check', 'rewards', 'win', 'lose', 'tool', 'fail_en'];
const TRAIL_SIGHT_REWARD_TOKENS = ['c', 'xp', 'en', 'item', 'crop', 'find', 'fish', 'seed', 'buff', 'fp', 'reveal', 'gather', 'take', 'unlock', 'hint', 'title', 'page', 'nocheck', 'give', 'fpto', 'tally', 'streak', 'lend', 'repay', 'time', 'escort', 'check', 'choose', 'disc', 'fpall', 'buff2', 'nxt', 'sec', 'nextkind'];   // buff2 nxt: 2.7.08 third pass A; sec: fourth pass (a named stretch)   // fpall: 2.7.08
const TRAIL_SIGHT_COND_RE = '/^((dp|se|we|hp|st|pal|ti|fd|to)=[a-z0-9,_-]+|mk=(yes|no)|hv=[a-z0-9-]+:\d+|mo=[a-z,-]+|(tl|tn|sk)=[a-z0-9-]+(@today)?:\d+|qd=[a-z0-9,-]+|bd=[a-z0-9,-]+|gd=\d+:\d+(,\d+:\d+)*)$/';   // gd = the game day: gd=7:3 is every 7th game day (day mod 7 = 3), several values = any of them (2.7.00)   // tl = a tally is AT LEAST N, tn = a tally is EXACTLY N (the use that reaches it: pays once), qd = one of these Sight quest lines is done   // a condition part: dp= se= we= hp= (rest-stop words), st= (sneak hunt normal), pal= (1 with a Puzzle Pal along)

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
        $first = false; $cond = ''; $lose = false;
        if (str_starts_with($tok, 'lose:')) { $lose = true; $tok = substr($tok, 5); }   // fourth pass: a penalty, paid on a lost check (trail_sight_do splits these off before anything else reads the row)
        if (str_starts_with($tok, 'first:')) { $first = true; $tok = substr($tok, 6); }
        if (($i = strpos($tok, '?')) !== false) { $cond = str_replace(';', ',', substr($tok, $i + 1)); $tok = substr($tok, 0, $i); }
        $out[] = ['tok' => $tok, 'cond' => $cond, 'first' => $first, 'lose' => $lose];
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
            $fileRows = trail_sights_file();
            foreach (q('SELECT * FROM trail_sight_rows')->fetchAll() as $r) {
                if (!(int)$r['active']) { unset($out[$r['slug']]); continue; }
                $out[$r['slug']] = ['slug' => $r['slug'], 'verb' => (string)$r['verb'], 'icon' => (string)$r['icon'], 'energy' => max(0, (int)$r['energy']), 'cd' => max(0, (int)$r['cd']),
                    'uses' => max(1, (int)$r['uses']), 'when' => (string)$r['cond'] ?: '-', 'check' => (string)$r['chk'] ?: '-', 'rewards' => (string)$r['rewards'], 'win' => (string)$r['win'],
                    'lose' => (string)$r['lose'], 'tool' => (string)$r['tool'] ?: '-', 'fail_en' => max(0, (int)$r['fail_en']), 'src' => isset($fileRows[$r['slug']]) ? 'edited' : 'new'];
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
    if ($r['cd'] < 1) $bad[] = 'cooldown must be at least 0.1 game day (a Sight with none could be used without end)';
    if ($r['uses'] > 9) $bad[] = 'more than 9 uses';
    if ($r['fail_en'] > 3) $bad[] = 'a fail may cost at most 3 energy';
    if ($r['win'] === '') $bad[] = 'no win line';
    foreach (['win', 'lose'] as $lk) foreach (explode(' // ', (string)$r[$lk]) as $lv) {   // 2.7.08: a variant may start with {cond} (shown only when it holds)
        if (preg_match('/^\s*\{([^}]*)\}/', $lv, $lm)) { foreach (explode('/', $lm[1]) as $part) if (!preg_match(TRAIL_SIGHT_COND_RE, trim($part))) $bad[] = 'bad condition "' . $part . '" in a ' . $lk . ' line';
            elseif ($db && str_starts_with(trim($part), 'to=')) foreach (explode(',', substr(trim($part), 3)) as $tv) if (!trail_sight_to_known(trim($tv))) $bad[] = 'to= "' . $tv . '" is no place slug, place kind or land'; }
        elseif (str_contains($lv, '{') || str_contains($lv, '}')) $bad[] = 'a ' . $lk . ' line has { } that are not a {condition} at its start';
    }
    if ($r['check'] !== '-') {
        $c = explode(':', $r['check'], 3);
        if ($c[0] === 'pick') {   // pick:N or pick:N:label;label;label : choose one of N, one is right (fixed per gnome and game day)
            if (!ctype_digit($c[1] ?? '') || (int)$c[1] < 2 || (int)$c[1] > 5 || (isset($c[2]) && count(explode(';', $c[2])) !== (int)$c[1])) $bad[] = 'pick must be pick:N[:N labels joined by ;] with N 2 to 5';
            if ($r['lose'] === '') $bad[] = 'a pick needs a lose line';
        } else {
            foreach (explode('+', $r['check']) as $alt) {   // 2.7.06 either / or: stat:dc+stat:dc (any one pass wins)
                if (($ib = sights5_lint_item_alt($alt, $db)) !== null) { $bad = array_merge($bad, $ib); continue; }   // fifth pass: item:slug[:qty] = an item as the other way
                if ($ab = sights4_lint_check_alt($alt)) { $bad = array_merge($bad, $ab); break; }   // fourth pass: stat:dc?cond:dc2 = another difficulty while the condition holds
            }
            if (!array_filter(explode('+', $r['check']), fn($a) => !str_starts_with($a, 'item:'))) $bad[] = 'a check needs at least one stat (item:slug is only another way to pass it)';
            if ($r['lose'] === '') $bad[] = 'a check needs a lose line';
        }
    }
    if ($r['when'] !== '-') foreach (array_filter(array_map('trim', explode('/', $r['when']))) as $part) if (!preg_match(TRAIL_SIGHT_COND_RE, $part)) $bad[] = 'bad condition "' . $part . '"';
        elseif ($db && str_starts_with($part, 'to=')) foreach (explode(',', substr($part, 3)) as $tv) if (!trail_sight_to_known(trim($tv))) $bad[] = 'to= "' . $tv . '" is no place slug, place kind or land';
    if ($r['tool'] !== '-') {
        $t = explode(':', $r['tool']);
        if (count($t) !== 2 || !in_array($t[0], GATHER_TOOLS, true) || !in_array((int)$t[1], [1, 2, 3, 4], true)) $bad[] = 'tool must be type:tier 1-4 (' . implode(', ', GATHER_TOOLS) . ')';
    }
    foreach (sights3a_lint_row(trail_sight_tokens($r['rewards'])) as $p3a) $bad[] = $p3a;   // 2.7.08 third pass A: two buff= in a row
    foreach (trail_sight_tokens($r['rewards']) as $t) {
        $tok = $t['tok'];
        if ($t['lose']) foreach (sights4_lint_lose($t, $r['check'], trail_sight_free_pick($r)) as $p4) $bad[] = $p4;   // fourth pass: lose: = a penalty on a lost check
        if ($t['cond'] !== '') foreach (explode('/', $t['cond']) as $part) if (!preg_match(TRAIL_SIGHT_COND_RE, trim($part))) $bad[] = 'bad condition "' . $part . '" in ' . $tok;
        if (preg_match('/^(.*)@(\d+(?:\/\d+){1,3})$/', $tok, $cm)) {   // 2.7.00 tool-tier odds: @a/b/c/d = the chance at the Sight's tool tier 1 / 2 / 3 / 4 (the last one repeats for a higher tier)
            $tok = $cm[1]; if ($r['tool'] === '-') $bad[] = 'tier odds @a/b/c need a tool column in ' . $tok;
            foreach (explode('/', $cm[2]) as $pc) if ((int)$pc > 100) $bad[] = 'bad chance in ' . $tok;
        }
        elseif (preg_match('/^(.*)@(\d+)$/', $tok, $cm)) { $tok = $cm[1]; if ((int)$cm[2] > 100) $bad[] = 'bad chance in ' . $tok; }   // a trailing @N is a chance (a villager's @village-slug is not)
        elseif (str_contains($tok, '@') && !str_starts_with($tok, 'fpto=') && !str_starts_with($tok, 'fp=')) $bad[] = 'bad chance in ' . $tok;
        [$k, $v] = array_pad(explode('=', $tok, 2), 2, '');
        if (!in_array($k, TRAIL_SIGHT_REWARD_TOKENS, true) && !in_array($k, TRAIL_SIGHT_REWARD_TOKENS_B, true)) { $bad[] = 'unknown reward "' . $k . '"'; continue; }
        foreach (trail_sight_b_lint($k, $v, $db) as $bp) $bad[] = $bp;   // 2.7.08 third pass B: bday= letter= bottle= quest= seed=<slug>
        if ($k === 'gather' && !in_array($v, GATHER_TOOLS, true)) $bad[] = 'gather= needs a tool type';
        if ($k === 'unlock' && !preg_match('/^[a-z]+:[a-z0-9-]+$/', $v)) $bad[] = 'unlock= needs kind:slug';
        if ($k === 'hint' && !in_array($v, TRAIL_SIGHT_HINTS, true)) $bad[] = 'hint= needs ' . implode(', ', TRAIL_SIGHT_HINTS);
        if ($k === 'page' && !isset(trail_sight_pages()[$v])) $bad[] = 'page= needs a key in trail_sight_pages.txt';
        if ($k === 'title' && ($v === '' || mb_strlen($v) > 60)) $bad[] = 'title= needs a title of 1 to 60 characters';
        if ($k === 'nocheck' && $v !== '') $bad[] = 'nocheck takes no value';
        if ($k === 'fpall' && !preg_match('/^([1-9]|10)$/', $v)) $bad[] = 'fpall= needs points 1 to 10 (every villager of the start place)';   // 2.7.08
        foreach (sights3a_lint_token($k, $v) as $p3a) $bad[] = $p3a;   // 2.7.08 third pass A: buff2= nxt=
        foreach (sights5_lint_token($k, $v, $db) as $p5) $bad[] = $p5;   // fifth pass: any-of take / give, disc scope, nextkind=
        foreach (sights4_lint_token($k, $v, $db) as $p4) $bad[] = $p4;   // fourth pass: sec= (a named stretch), time= range
        if ($k === 'buff' && (!preg_match('/^([a-z]+):(\d{1,2})(:(\d{1,4}|sleep|delve|section))?$/', $v, $bm) || !($bm[1] === 'all' || array_key_exists($bm[1], GNOME_STATS)))) $bad[] = 'buff= needs stat:amount[:minutes|sleep|delve|section] (stat: ' . implode(', ', array_keys(GNOME_STATS)) . ', or all = every stat)';   // 2.7.08: all
        if ($k === 'disc' && !preg_match('/^(rest|shop):([1-9]\d?|100):([1-9]\d{0,3})(:[a-z][a-z0-9-]*)?$/', $v)) $bad[] = 'disc= needs rest|shop:percent:minutes[:item category or item slug] (real minutes), e.g. disc=rest:10:120 or disc=shop:20:60:seed';
        if ($k === 'check' && !preg_match('/^[a-z]+:\d{1,2}$/', $v)) $bad[] = 'check= needs stat:difficulty (a villager row)';
        if ($k === 'choose' && !empty($r['folk']) && str_contains($v, '~')) { foreach (sights6a_lint_vchoose($v, $db) as $vp) $bad[] = $vp; }   // sixth pass A: a villager row's choice (Label~reward+reward;...)
        elseif ($k === 'choose') {   // choose=A;B;C: the gnome picks ONE of these rewards (2.7.00); each is a plain reward token
            $opts = array_values(array_filter(array_map('trim', explode(';', $v))));
            if (count($opts) < 2 || count($opts) > 4) $bad[] = 'choose= needs 2 to 4 rewards joined by ;';
            if ($r['check'] !== '-' && str_starts_with($r['check'], 'pick') && count($opts) !== (int)(explode(':', $r['check'])[1] ?? 0)) $bad[] = 'choose= on a pick needs one reward per label (a free pick: label i pays reward i, 2.7.08)';
            foreach ($opts as $o) {
                $ok0 = explode('=', $o, 2)[0];
                if (!in_array($ok0, ['c', 'xp', 'en', 'item', 'crop', 'seed', 'fish', 'find', 'buff', 'disc'], true)) $bad[] = 'choose= option "' . $o . '" is not a plain reward';
                if ($ok0 === 'item' && $db && !trail_sight_item_known(explode(':', explode('=', $o, 2)[1] ?? '')[0])) $bad[] = 'choose= item "' . $o . '" does not exist';
            }
        }
        if ($k === 'tally' && !preg_match('/^[a-z0-9-]{2,30}$/', $v)) $bad[] = 'tally= needs a key of 2 to 30 letters, digits or -';
        if ($k === 'fpto' && !preg_match('/^[^:@]+(@[a-z0-9-]+)?(:\d+)?$/', $v)) $bad[] = 'fpto= needs Name[@village][:points]';
        if ($k === 'take' && ($t['first'] || str_contains($t['tok'], '@'))) $bad[] = 'take= is a cost: it cannot have first: or a chance (a ?condition is fine, 2.7.08)';
        if ($k === 'give') { $gs = explode(':', $v)[0]; if (!preg_match(SIGHTS5_ANY_RE, $gs) && !trail_sight_item_known($gs)) $bad[] = 'give= item "' . $gs . '" does not exist'; }
        if (($k === 'item' || $k === 'take') && $db) { $slug = explode(':', $v)[0]; if (!($k === 'take' && preg_match(SIGHTS5_ANY_RE, $slug)) && !trail_sight_item_known($slug)) $bad[] = 'no item "' . $slug . '"'; }
    }
    return $bad;
}

/** 2.7.08: is $v something a to= condition can match (a location slug, a location kind or a landscape)? Database lookup, cached. */
function trail_sight_to_known(string $v): bool
{
    static $c = null;
    if ($c === null) {
        $c = [];
        try { foreach (q('SELECT slug, kind, landscape FROM locations')->fetchAll() as $l) foreach ([$l['slug'], $l['kind'], $l['landscape']] as $x) if ((string)$x !== '') $c[(string)$x] = true; } catch (Throwable $e) { return true; }
    }
    return isset($c[$v]);
}

/** Make the Sights tables if the Upgrade database run has not yet (the admin page uses this; the game falls back to the file and no cooldown). */
function trail_sights_ensure_tables(): bool
{
    try { q('SELECT 1 FROM trail_sight_rows LIMIT 1'); q('SELECT 1 FROM trail_sight_uses LIMIT 1'); q('SELECT 1 FROM trail_sight_first LIMIT 1'); q('SELECT 1 FROM user_sight_quests LIMIT 1'); q('SELECT 1 FROM user_sight_titles LIMIT 1'); q('SELECT 1 FROM trail_sight_tally LIMIT 1'); trail_sights_ensure_items(); trail_sights_ensure_pages(); return true; } catch (Throwable $e) {}
    try {
        require_once __DIR__ . '/action_log.php';
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        [$t, $i] = action_log_schema($sqlite ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $sqlite ? 'INTEGER' : 'INT UNSIGNED', $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
        foreach ($t as $sql) if (str_contains($sql, 'trail_sight_')) db()->exec($sql);
        foreach ($i as $sql) if (str_contains($sql, 'trail_sight_')) { try { db()->exec($sql); } catch (Throwable $e) {} }
        trail_sights_ensure_items();
        trail_sights_ensure_pages();
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
    static $cache = [];   // every use row of this stretch in one query, for the request (reset after a use: trail_sight_state_reset)
    $ck = $uid . '|' . $route . '|' . $sec;
    if (!empty($GLOBALS['gv_sights_nocache'])) $cache = [];
    if (!isset($cache[$ck])) {
        try { $cache[$ck] = array_column(q('SELECT * FROM trail_sight_uses WHERE user_id = ? AND route_id = ? AND sec = ?', [$uid, $route, $sec])->fetchAll(), null, 'slug'); }
        catch (Throwable $e) { return [$row['uses'], '']; }   // table missing before Upgrade database
    }
    $GLOBALS['gv_sights_state_cache'] = &$cache;
    $r = $cache[$ck][$row['slug']] ?? null;
    if (!$r) return [$row['uses'], ''];
    static $uc = []; $u = $uc[$uid] ??= q_one('SELECT * FROM users WHERE id = ?', [$uid]);   // once per request (the tick is for the Sight list, not for money)
    $span = (int)round($row['cd'] * 144);   // game ticks are minutes: cd is tenths of a game day, so 55 = 7920 (same as trail_pickups)
    $gone = $u && gclock_on() && $r['got_tick'] !== null
        ? gclock_state($u)['tick'] - (int)$r['got_tick'] >= $span
        : time() - (int)$r['got_at'] >= (int)round($row['cd'] * 8640);
    if ($gone) return [$row['uses'], ''];
    $left = max(0, $row['uses'] - (int)$r['n']);
    return [$left, $left > 0 ? '' : 'Grows back in a few days.'];
}

/**
 * One of the variants of a line (variants are joined with " // " in the data): a random one.
 * 2.7.08: a variant may start with `{cond}` (the `when` grammar: `{to=coast}`, `{we=sun/dp=day}`): it is shown only when that holds, and a matching
 * {cond} variant wins over the plain ones (so a line for one destination beats the general text). With no $now, or nothing matching, a plain variant shows.
 */
function trail_sight_line(string $t, ?array $now = null): string
{
    $plain = []; $hit = [];
    foreach (array_map('trim', explode(' // ', $t)) as $x) {
        if ($x === '') continue;
        if (preg_match('/^\{([^}]*)\}\s*(.*)$/s', $x, $m)) { if ($now !== null && trim($m[2]) !== '' && trail_sight_cond_ok($m[1], $now)) $hit[] = trim($m[2]); continue; }
        $plain[] = $x;
    }
    $v = $hit ?: $plain;
    if (!$v) foreach (array_map('trim', explode(' // ', $t)) as $x) if ($x !== '') { $v = [trim((string)preg_replace('/^\{[^}]*\}\s*/', '', $x))]; break; }   // only {cond} variants and none hold: the first one, without its condition
    return $v ? $v[array_rand($v)] : '';
}

/** The pick of a `pick:N[:labels]` check that is right today for this gnome at this Sight (fixed per gnome and game day, so the card and the use agree). */
function trail_sight_pick_answer(int $uid, array $row, string $salt = ''): int
{
    $c = explode(':', $row['check'], 3); $n = max(2, min(5, (int)($c[1] ?? 3)));
    return (int)floor(hollow_unit('sgp|' . $uid . '|' . $row['slug'] . '|' . $salt . '|' . (function_exists('gclock_my_date') ? gclock_my_date() : date('Y-m-d'))) * $n);
}

/** The right pick right now: a fresh draw for every stretch (route and section) and every try within the cooldown window, so a second try is not a sure thing. */
function trail_sight_pick_right(array $u, array $sc, array $row): int
{
    [$left] = trail_sight_state((int)$u['id'], $sc, $row);
    $route = (int)substr((string)$sc['row']['map_key'], 6);
    return trail_sight_pick_answer((int)$u['id'], $row, $route . '|' . trail_phys_sec($route, (int)$sc['st']['sec'], $sc['st']) . '|' . max(0, $row['uses'] - $left));
}

/** [N, [labels]] of a pick check, or null. */
function trail_sight_pick_info(array $row): ?array
{
    $c = explode(':', $row['check'], 3);
    if (($c[0] ?? '') !== 'pick') return null;
    $n = max(2, min(5, (int)($c[1] ?? 3)));
    $labels = isset($c[2]) ? explode(';', $c[2]) : array_map(fn($i) => (string)($i + 1), range(0, $n - 1));
    return [$n, $labels];
}

/** 2.7.08: a pick with a reward choice: a `pick:N:labels` row whose `choose=` has N options. Every label is right ("no wrong answer"); label i pays option i. */
function trail_sight_free_pick(array $row): bool
{
    $p = trail_sight_pick_info($row); $c = trail_sight_choose_info($row);
    return $p && $c && count($c) === $p[0];
}

/** The options of a `choose=A;B;C` reward: [[token, label], ...] or null. */
function trail_sight_choose_info(array $row): ?array
{
    foreach (trail_sight_tokens($row['rewards']) as $t) if (str_starts_with($t['tok'], 'choose=')) {
        $opts = array_values(array_filter(array_map('trim', explode(';', substr($t['tok'], 7)))));
        return $opts ? array_map(fn($o) => [$o, trail_sight_reward_label($o)], $opts) : null;
    }
    return null;
}

/** A short player-facing name for one reward token (a button label). */
function trail_sight_reward_label(string $tok): string
{
    [$k, $v] = array_pad(explode('=', $tok, 2), 2, '');
    $n = (int)explode(':', $v)[0];
    switch ($k) {
        case 'c': return $n . ' ' . (function_exists('setting') && setting('currency_name') !== '' ? setting('currency_name') : 'Petals');
        case 'en': return $n . ' energy';
        case 'xp': return $n . ' XP';
        case 'item': $q = (int)(explode(':', $v)[1] ?? 1); $nm = (string)q_val('SELECT name FROM items WHERE slug = ?', [explode(':', $v)[0]]) ?: explode(':', $v)[0]; return ($q > 1 ? $q . ' × ' : '') . $nm;
        case 'crop': return 'A crop';
        case 'seed': return 'A seed';
        case 'fish': return 'A fish';
        case 'find': return 'A find';
        case 'buff': return 'A boost';
        case 'disc': [$kind, $pct] = explode(':', $v) + [1 => '']; return $pct . '% off ' . ($kind === 'rest' ? 'a room at the inn' : 'in the shops');
    }
    return $tok;
}

/** Tool-tier odds: `item=x:1@5/15/30/50` becomes `item=x:1@15` for a gnome whose tool of the Sight's type is tier 2 (no tool or tier 1 = the first number; a tier past the list repeats the last). */
function trail_sight_tier_chance(string $tok, int $tier): string
{
    if (!preg_match('/^(.*)@(\d+(?:\/\d+){1,3})$/', $tok, $m)) return $tok;
    $c = explode('/', $m[2]);
    return $m[1] . '@' . $c[max(0, min(count($c), $tier) - 1)];
}

/**
 * Rewards pass (2.7.00): a flat Petals or XP reward (`xp=5`, no second number) grows with the level of the place where the walk began, by the setting
 * sights_flat_pct_per_level percent a level (default 3, approved by Josh 2026-11-15; 0 = off; claude/sights-rewards-2.7.00.md). Rewards that already carry a per-level
 * part (`xp=3:1`) are left alone, and so is everything else. `xp=5` at level 1 stays 5.
 */
function trail_sight_flat_scale(string $tok, int $level): string
{
    $pct = (int)setting('sights_flat_pct_per_level');
    if ($pct <= 0 || $level <= 1 || !preg_match('/^(c|xp)=(\d+)(@.*)?$/', $tok, $m)) return $tok;
    return $m[1] . '=' . max(1, (int)round((int)$m[2] * (1 + $pct / 100 * ($level - 1)))) . ($m[3] ?? '');
}

/** Forget the cached use rows (after a use, so the next read is fresh). */
function trail_sight_state_reset(): void
{
    if (isset($GLOBALS['gv_sights_state_cache']) && is_array($GLOBALS['gv_sights_state_cache'])) $GLOBALS['gv_sights_state_cache'] = [];
}

/**
 * Use the Sight $slug where the gnome stands. [ok, message]. The journal line goes in the walk log; costs energy and game time.
 * $opt['pick'] = the chosen index for a `pick:N` Sight. A pseudo "place" (the walk's start, with the Sight's name and the land) lets the rest-stop reward code work.
 * Villagers who are here today (trail_sight_folk_here): one with `nocheck` makes the check a sure thing; one with `give=` waits for trail_sight_give(); the first other one pays after a win.
 */
function trail_sight_do(array $u, array &$exp, string $slug, array $opt = []): array
{
    $sc = trail_scene($exp);
    if (!$sc) return [false, 'Not on a tile walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    $all = trail_sights_all();
    if (!isset($all[$slug])) return [false, 'There is nothing to do here.'];
    $row = $all[$slug];
    [$row['rewards'], $loseToks] = sights4_split_lose((string)$row['rewards']);   // fourth pass: lose: tokens are penalties for a lost check; the rest of this function sees only the win rewards
    if (($sc['st']['phase'] ?? '') !== 'section' || !array_filter(trail_sights_near($sc['map']['art'] ?? null, (int)$sc['x'], (int)$sc['y']), fn($n) => $n[0] === $slug)) return [false, 'You need to be next to it.'];
    require_once __DIR__ . '/stops.php';
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: [];
    $loc['name'] = $row['verb'];
    $loc['landscape'] = (string)(exp_scene($exp)['land'] ?? ($loc['landscape'] ?? 'grassland'));
    $now = trail_sight_now($loc, $sc, $u);
    $row['check'] = sights4_check_resolve((string)$row['check'], $now);   // fourth pass: sense:11?se=spring:9 = difficulty 9 in spring
    if ($row['when'] !== '-' && !trail_sight_cond_ok($row['when'], $now)) return [false, 'Not the right time for that.' . (($tx = trail_sight_cond_text($row['when'])) !== '' ? ' (' . $tx . ')' : '')];
    [$left, $why] = trail_sight_state((int)$u['id'], $sc, $row);
    if ($left < 1) return [false, $why ?: 'Not again just yet.'];
    $walkCap = trail_sight_walk_cap(); $walkId = (int)($exp['id'] ?? 0);   // 2.7.08: at most sights_walk_cap Sight uses on one walk (0 = no cap)
    if ($walkCap > 0 && $walkId > 0 && trail_sight_walk_uses((int)$u['id'], $walkId) >= $walkCap) return [false, trail_sight_walk_cap_msg($walkCap)];
    $pick = trail_sight_pick_info($row);
    $folkHere = trail_sight_folk_here($slug, $now, (int)$u['id']);
    $sure = false; foreach ($folkHere as $fh) if (in_array('nocheck', array_map(fn($t) => $t['tok'], trail_sight_tokens($fh['rewards'])), true)) { $sure = $fh; break; }
    $choose = trail_sight_choose_info($row);
    if ($pick && $choose && trail_sight_free_pick($row)) { if (isset($opt['pick']) && !isset($opt['reward'])) $opt['reward'] = $opt['pick']; if (isset($opt['reward']) && !isset($opt['pick'])) $opt['pick'] = $opt['reward']; }   // 2.7.08: a free pick: the chosen label is its reward
    if ($choose && (!isset($opt['reward']) || (int)$opt['reward'] < 0 || (int)$opt['reward'] >= count($choose))) return [false, 'Choose your reward.'];   // 2.7.00
    if ($pick && !$sure && (!isset($opt['pick']) || (int)$opt['pick'] < 0 || (int)$opt['pick'] >= $pick[0])) return [false, 'Choose one.'];   // a villager with nocheck settles a pick too
    if ($row['tool'] !== '-') {   // needs a gathering tool of at least this tier
        require_once __DIR__ . '/gathering.php';
        [$tt, $tier] = array_pad(explode(':', $row['tool']), 2, '1');
        if (tool_tier((int)$u['id'], $tt) < (int)$tier) return [false, 'You need a ' . (TOOL_TIERS[(int)$tier] ?? '') . ' ' . (GATHER_TOOL_NOUN[$tt] ?? 'tool') . ' for that.'];
    }
    $takes = [];   // take=slug:qty: needed in the satchel (checked before any energy goes), used up on a win
    foreach (trail_sight_tokens($row['rewards']) as $t) if (str_starts_with($t['tok'], 'take=') && ($t['cond'] === '' || trail_sight_cond_ok($t['cond'], $now))) {   // 2.7.08: take=x:1?ti=low only costs when that holds
        [$tslug, $tqty] = array_pad(explode(':', substr($t['tok'], 5), 2), 2, '1'); $tq = max(1, (int)$tqty);
        if (preg_match('/^any-([a-z]+(?:\+[a-z]+)*)$/', $tslug, $anm)) {   // 2.7.06: take=any-nut:2 / any-feather:1 = any items of that kind (a crop kind, else a slug ending in it), several kinds of item allowed
            $cand = trail_sight_any_items($anm[1]); $have = 0; foreach ($cand as $cid) $have += (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $cid]);
            if ($have < $tq) return [false, 'You need ' . $tq . ' × ' . sights5_any_label($anm[1]) . ' for that.'];
            $takes[] = [-1, $tq, $cand]; continue;
        }
        $tid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$tslug]);
        if (!$tid || (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $tid]) < $tq) return [false, 'You need ' . $tq . ' × ' . ($tid ? (string)q_val('SELECT name FROM items WHERE id = ?', [$tid]) : $tslug) . ' for that.'];
        $takes[] = [$tid, $tq];
    }
    $loanKey = 'lend#' . $slug; $loanOpen = false; $lends = [];   // 2.7.06 lend=slug:qty hands an item over for a while; the next use of the Sight repay=slug:qty gives it back
    try { $loanOpen = (int)(trail_sight_tallies((int)$u['id'])[$loanKey] ?? 0) > 0; } catch (Throwable $e) {}
    foreach (trail_sight_tokens($row['rewards']) as $t) if (str_starts_with($t['tok'], 'lend=') && !$loanOpen) {
        [$lslug, $lqty] = array_pad(explode(':', substr($t['tok'], 5), 2), 2, '1'); $lid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$lslug]); $lq = max(1, (int)$lqty);
        if (!$lid || (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $lid]) < $lq) return [false, 'You need ' . $lq . ' × ' . ($lid ? (string)q_val('SELECT name FROM items WHERE id = ?', [$lid]) : $lslug) . ' to lend here.'];
        $lends[] = [$lid, $lq];
    }
    trail_sights_ensure_items();   // a Sight can hand out an item only Sights give (data/trail_sight_items.txt): make them before the first use
    trail_sights_ensure_newfolk();
    if (!spend_energy((int)$u['id'], $row['energy'], 'sight')) return [false, 'You need ' . $row['energy'] . ' energy for that.'];   // time: setting time_sight (10 game minutes); an energy-free Sight still takes the time
    if ($walkId > 0) trail_sight_walk_count((int)$u['id'], $walkId);   // a use counts toward the walk's cap, win or lose
    $ok = true; $chkNotes = [];
    if ($pick && !$sure) $ok = trail_sight_free_pick($row) || (int)($opt['pick'] ?? -1) === trail_sight_pick_right($u, $sc, $row);   // 2.7.08: a free pick has no wrong answer
    elseif ($row['check'] !== '-' && str_contains($row['check'], ':') && !$sure) {   // 2.7.06: stat:dc+stat:dc = either passes; fifth pass: item:slug = an item is the other way; nextkind= tips lower each difficulty
        $kb = sights5_kind_take_bonus($u, $slug); if ($kb > 0) $chkNotes[] = '🤝 +' . $kb . ' from the tip you were given';
        [$ok, $itemNotes] = sights5_check_roll($u, (string)$row['check'], $kb); $chkNotes = array_merge($chkNotes, $itemNotes);
    }
    $kfish = $ok ? sights5_kind_take_fish($u, $slug) : 0;   // fifth pass: a waiting "next fishing Sight pays more" tip is taken before this Sight's own rewards can set a new one
    $lines = $chkNotes;
    $first = false;
    try { $first = !q_val('SELECT 1 FROM trail_sight_first WHERE user_id = ? AND slug = ?', [(int)$u['id'], $slug]); } catch (Throwable $e) { /* table missing: no first-time bonus */ }
    if ($ok) {   // tally=<key> counts this use for the gnome (a private cairn, a collection); conditions tl=<key>:N see the new count
        foreach (trail_sight_tokens($row['rewards']) as $t) if (str_starts_with($t['tok'], 'tally=') && ($t['cond'] === '' || trail_sight_cond_ok($t['cond'], $now))) { trail_sight_tally_add((int)$u['id'], substr($t['tok'], 6)); trail_sight_tally_add((int)$u['id'], substr($t['tok'], 6) . '@' . (int)($now['gd'] ?? 0)); try { q("DELETE FROM trail_sight_tally WHERE user_id = ? AND tkey LIKE '%@%' AND tkey NOT LIKE ?", [(int)$u['id'], '%@' . (int)($now['gd'] ?? 0)]); } catch (Throwable $e) { } foreach (sights6_tally_hook($u, substr($t['tok'], 6)) as $s6l) $lines[] = $s6l; $now['tl'] = trail_sight_tallies((int)$u['id']); $lines[] = '🪨 ' . substr($t['tok'], 6) . ' ' . ($now['tl'][substr($t['tok'], 6)] ?? 0); }
    }
    if ($ok) {   // 2.7.06 streak=<key>: using the Sight on consecutive game days builds a streak (a missed day starts again at 1); conditions sk=<key>:N see it
        $gdNow = (int)($now['gd'] ?? 0); $bumped = false;
        foreach (trail_sight_tokens($row['rewards']) as $t) if (str_starts_with($t['tok'], 'streak=') && ($t['cond'] === '' || trail_sight_cond_ok($t['cond'], $now))) { trail_sight_streak_bump((int)$u['id'], substr($t['tok'], 7), $gdNow); $bumped = true; }
        if ($bumped) $now['tl'] = trail_sight_tallies((int)$u['id']);
    }
    if ($ok) {
        $plain = [];   // the rest-stop reward grammar for most tokens; gather= runs the gather table; hint= title= page= unlock= are ours; take= is paid below
        foreach (trail_sight_tokens($row['rewards']) as $t) {
            if ($t['first'] && !$first) continue;
            if ($t['cond'] !== '' && !trail_sight_cond_ok($t['cond'], $now)) continue;
            $tok = $t['tok'];
            if (str_starts_with($tok, 'take=') || str_starts_with($tok, 'tally=') || str_starts_with($tok, 'streak=') || str_starts_with($tok, 'lend=') || str_starts_with($tok, 'repay=') || str_starts_with($tok, 'escort=')) continue;
            if (str_starts_with($tok, 'item=')) { require_once __DIR__ . '/wearables.php'; if (wear_parse(explode(':', substr($tok, 5))[0]) !== null && !wear_live($u)) continue; }   // 2.7.01: wearables drop only while puzzle combat (pfight_v1) is on for this gnome
            if (str_starts_with($tok, 'choose=')) { $tok = $choose[(int)$opt['reward']][0]; if (preg_match('/^(hint|title|page|fpto|fpall|disc|nxt|sec|nextkind)=/', $tok)) { $lines = array_merge($lines, trail_sight_pay($u, $loc, $tok, '', $now)); continue; } $plain[] = $tok; continue; }
            $tok = trail_sight_flat_scale($tok, stop_level($loc));   // 2.7.00 rewards pass (setting sights_flat_pct_per_level, default 3)
            if ($row['tool'] !== '-' && str_contains($tok, '@')) $tok = trail_sight_tier_chance($tok, tool_tier((int)$u['id'], explode(':', $row['tool'])[0]));   // 2.7.00 tool-tier odds
            if (str_starts_with($tok, 'gather=')) {
                require_once __DIR__ . '/gathering.php';
                $gl = gather_on_walk($u, $loc['landscape'], substr($tok, 7), true, $found);
                if ($found) gather_reveal_set($found);
                $lines[] = $gl ?? 'You find nothing this time.';
            } elseif (str_starts_with($tok, 'unlock=')) { if (unlock_entries((int)$u['id'], substr($tok, 7)) > 0) $lines[] = '📖 A new Almanac page'; }
            elseif (str_starts_with($tok, 'time=')) {   // 2.7.06: time=N = N more game minutes pass (a long sit-down, a slow walk): needs the sleep-days clock
                $tm = max(1, min(480, (int)substr($tok, 5)));
                if (function_exists('gclock_on') && gclock_on() && game_spend((int)$u['id'], $tm)) $lines[] = '⏱️ ' . ($tm >= 60 ? round($tm / 60, 1) . ' h' : $tm . ' min') . ' pass';
            }
            elseif (trail_sight_b_token($tok)) $lines = array_merge($lines, trail_sight_b_pay($u, $loc, $tok, $now));   // 2.7.08 third pass B (rolls its own @chance)
            elseif (preg_match('/^(hint|title|page|fpto|fpall|disc|nxt|sec|nextkind)=/', $tok)) { if (trail_sight_chance_pass($tok)) $lines = array_merge($lines, trail_sight_pay($u, $loc, $tok, '', $now)); }   // 2.7.06: @chance now works on these too
            else $plain[] = $tok;
        }
        foreach ($takes as $tk) {
            [$tid, $tq] = $tk;
            if ($tid !== -1) { give_item((int)$u['id'], $tid, -$tq); continue; }
            $left = $tq;   // any-<kind>: use up the biggest stacks first
            $stk = []; foreach ($tk[2] as $cid) { $qy = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $cid]); if ($qy > 0) $stk[$cid] = $qy; }
            arsort($stk); foreach ($stk as $cid => $qy) { $use = min($left, $qy); give_item((int)$u['id'], (int)$cid, -$use); $left -= $use; if ($left <= 0) break; }
        }
        foreach (trail_sight_tokens($row['rewards']) as $t) if (str_starts_with($t['tok'], 'escort=') && ($t['cond'] === '' || trail_sight_cond_ok($t['cond'], $now))) {   // 2.7.06: a villager walks with you for the rest of this walk (drawn beside the gnome)
            $ename = substr($t['tok'], 7);
            if (trail_escort_pic($ename) !== '') { $sc2 = trail_scene($exp); if ($sc2) { $sc2['st']['escort'] = $ename; if (trail_save($sc2)) $lines[] = '🚶 ' . trail_sight_split_who($ename)[0] . ' walks with you for the rest of the way'; } }
        }
        foreach ($lends as [$lid, $lq]) { give_item((int)$u['id'], $lid, -$lq); trail_sight_tally_set((int)$u['id'], $loanKey, max(1, (int)($now['gd'] ?? 0))); $lines[] = '📚 lent out ' . $lq . ' × ' . (string)q_val('SELECT name FROM items WHERE id = ?', [$lid]) . ' (it comes back the next time you use this)'; }
        if ($loanOpen) foreach (trail_sight_tokens($row['rewards']) as $t) if (str_starts_with($t['tok'], 'repay=') && ($t['cond'] === '' || trail_sight_cond_ok($t['cond'], $now))) {
            [$rslug, $rqty] = array_pad(explode(':', substr($t['tok'], 6), 2), 2, '1'); $rid2 = (int)q_val('SELECT id FROM items WHERE slug = ?', [$rslug]);
            if ($rid2) { give_item((int)$u['id'], $rid2, max(1, (int)$rqty)); $lines[] = '📗 returned: ' . max(1, (int)$rqty) . ' × ' . (string)q_val('SELECT name FROM items WHERE id = ?', [$rid2]); }
            trail_sight_tally_set((int)$u['id'], $loanKey, 0);
        }
        if ($kfish > 0) { $plain[] = 'fish=' . $kfish; array_unshift($lines, '🎣 the tip pays off'); }   // fifth pass: nextkind=fishing:fish=N
        $lines = array_merge($plain ? stop_rewards($u, $loc, implode(',', $plain), max(0.25, (int)setting('sights_reward_pct') / 100)) : [], $lines);
    } elseif ($row['fail_en'] > 0) {   // a slip costs a little energy (never below 0)
        q('UPDATE users SET energy = CASE WHEN energy >= ? THEN energy - ? ELSE 0 END WHERE id = ?', [$row['fail_en'], $row['fail_en'], (int)$u['id']]);
        $lines[] = '-' . $row['fail_en'] . ' energy';
    }
    if (!$ok && $loseToks !== '') $lines = array_merge($lines, sights4_lose_pay($u, $loseToks, $now));   // fourth pass: lose:time= lose:nxt= lose:sec=
    $qlines = [];
    if ($ok) {   // villagers who are here, quest lines, the Almanac page
        if ($sure) $lines[] = '💬 ' . $sure['line'] . ' (no roll needed)';
        foreach ($folkHere as $fh) {
            $toks = array_map(fn($t) => $t['tok'], trail_sight_tokens($fh['rewards']));
            if ($fh === $sure) { $lines = array_merge($lines, trail_sight_pay($u, $loc, $fh['rewards'], $fh['who'], $now)); break; }
            if (array_filter($toks, fn($t) => str_starts_with($t, 'give=')) || sights6a_vchoose((string)$fh['rewards'])) continue;   // waits for trail_sight_give() (a give= row, or a villager's choice: sixth pass A)
            $rolled = sights5_folk_roll($u, $fh, $now);   // fifth pass: their own check is rolled here, once: a miss says the row's miss line and pays nothing
            if ($rolled === false) { $lines[] = '💬 ' . sights5_folk_miss_text($fh, $now); break; }
            $lines = array_merge($lines, ['💬 ' . $fh['line']], trail_sight_pay($u, $loc, $fh['rewards'], $fh['who'], $now, $rolled === true)); break;
        }
        $qlines = trail_sight_quest_hook($u, $slug, $loc, $now);
        try { unlock_entries((int)$u['id'], 'sight:' . $slug); } catch (Throwable $e) {}
    }
    if ($ok && $first) { try { db_insert('trail_sight_first', ['user_id' => (int)$u['id'], 'slug' => $slug]); } catch (Throwable $e) {} }
    $said = trail_sight_line($ok ? $row['win'] : $row['lose'], $now);   // 2.7.08: {cond} variants (destination, weather ...) see this use's conditions; the popup shows the same line
    $text = $row['icon'] . ' ' . $said . ($lines ? ' (' . implode(', ', array_filter($lines)) . ')' : '');
    exp_log($exp, $text);
    foreach ($qlines as $ql) exp_log($exp, $ql);
    if ($ok && array_filter($lines) && function_exists('session_status') && session_status() === PHP_SESSION_ACTIVE && empty($_SESSION['event_box'])) {   // 2.7.06 (Josh): what a Sight gives (items, prizes, titles) shows as its own popup, not only a log line
        $_SESSION['event_box'] = ['icon' => (string)$row['icon'], 'title' => (string)$row['verb'], 'text' => $said, 'lines' => array_values(array_filter(array_map('strval', array_merge($lines, $qlines))))];
    }
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
    trail_sight_state_reset();
    if (random_int(1, 40) === 1) { try { q('DELETE FROM trail_sight_uses WHERE got_at < ?', [time() - 120 * 86400]); } catch (Throwable $e) {} }   // old cooldown rows (the longest cooldown is 40 days)
    return [true, ''];
}

/** 2.7.08: the most Sight uses on one walk (setting sights_walk_cap, default 6; 0 = no cap). */
function trail_sight_walk_cap(): int
{
    return max(0, (int)setting('sights_walk_cap'));
}

/** 2.7.08: Sight uses on the walk (expedition) $expId so far. Two private tallies: walk#id (the walk counted) and walk#n (its uses); a new walk starts at 0. */
function trail_sight_walk_uses(int $uid, int $expId): int
{
    $t = trail_sight_tallies($uid);
    return (int)($t['walk#id'] ?? 0) === $expId ? (int)($t['walk#n'] ?? 0) : 0;
}

/** 2.7.08: count one more Sight use on this walk. Returns the new count. */
function trail_sight_walk_count(int $uid, int $expId): int
{
    $n = trail_sight_walk_uses($uid, $expId) + 1;
    trail_sight_tally_set($uid, 'walk#id', $expId);
    trail_sight_tally_set($uid, 'walk#n', $n);
    return $n;
}

/** 2.7.08: what the gnome is told at the cap. */
function trail_sight_walk_cap_msg(int $cap): string
{
    return 'You have used ' . $cap . ' Sight' . ($cap === 1 ? '' : 's') . ' on this walk, the most for one walk. The next walk starts afresh.';
}

/** 2.7.06: a token's trailing `@N` (percent chance) on hint= title= page= fpto= disc=: true when it pays this time; $tok loses the `@N`. No `@N` = always. */
function trail_sight_chance_pass(string &$tok): bool
{
    if (!preg_match('/^(.*)@(\d{1,3})$/', $tok, $m)) return true;
    $tok = $m[1];
    return random_int(1, 100) <= (int)$m[2];
}

/** 2.7.06: the item ids that count as "any <kind>" for take=any-<kind>: the produce of every plant of that kind (nut, fruit, vegetable ...), else every item whose slug ends with it (feather). */
function trail_sight_any_items(string $kind): array
{
    if (str_contains($kind, '+') || in_array($kind, SIGHTS5_ANY_CATS, true) || sights6a_word_list($kind) !== null) return sights5_any_items($kind);   // fifth pass: an item category (seed, flower, food, produce) and several kinds joined by +
    $ids = array_map('intval', q('SELECT i.id FROM plants p JOIN items i ON i.id = p.produce_item_id WHERE p.kind = ?', [$kind])->fetchAll(PDO::FETCH_COLUMN));
    if (!$ids) $ids = array_map('intval', q("SELECT id FROM items WHERE slug = ? OR slug LIKE ?", [$kind, '%-' . $kind])->fetchAll(PDO::FETCH_COLUMN));
    return array_values(array_unique($ids));
}

/**
 * Hand a villager who is at the Sight today what they ask for (their row has `give=item:qty`): the item is used up, their rewards are paid. No energy; 10 game minutes. [ok, message]
 * $idx = the row's index in trail_sight_folk()[$slug].
 */
function trail_sight_give(array $u, array &$exp, string $slug, int $idx, int $reward = -1): array
{
    $sc = trail_scene($exp);
    if (!$sc || $exp['encounter']) return [false, 'Not now.'];
    if (($sc['st']['phase'] ?? '') !== 'section' || !array_filter(trail_sights_near($sc['map']['art'] ?? null, (int)$sc['x'], (int)$sc['y']), fn($n) => $n[0] === $slug)) return [false, 'You need to be next to it.'];
    require_once __DIR__ . '/stops.php';
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: [];
    $loc['name'] = 'a gift'; $loc['landscape'] = (string)(exp_scene($exp)['land'] ?? ($loc['landscape'] ?? 'grassland'));
    $now = trail_sight_now($loc, $sc, $u);
    $here = array_values(array_filter(trail_sight_folk_here($slug, $now, (int)$u['id']), fn($f) => $f['idx'] === $idx));
    if (!$here) return [false, 'Nobody is here for that today.'];
    $f = $here[0];
    $g = null; foreach (trail_sight_tokens($f['rewards']) as $t) if (str_starts_with($t['tok'], 'give=')) $g = $t['tok'];
    if (!$g && sights6a_vchoose((string)$f['rewards'])) return sights6a_folk_choose($u, $exp, $loc, $now, $f, $slug, $idx, $reward);   // sixth pass A: the villager asks a question instead of an item
    if (!$g) return [false, 'They do not need anything.'];
    [$gs, $gq] = array_pad(explode(':', substr($g, 5), 2), 2, '1'); $gid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$gs]); $gq = max(1, (int)$gq);
    $anyG = preg_match(SIGHTS5_ANY_RE, $gs) ? substr($gs, 4) : null;   // fifth pass: give=any-seed:1 = one of any seed
    if ($anyG !== null) $gid = 0;
    $gname = $anyG !== null ? sights5_any_label($anyG) : ($gid ? (string)q_val('SELECT name FROM items WHERE id = ?', [$gid]) : $gs);
    $gkey = 'give~' . substr(md5($slug . '|' . $idx), 0, 16); $dayNo = (int)floor(strtotime(gclock_my_date() . ' UTC') / 86400);   // one row per villager row, holding the day it was last given: nothing piles up
    $last = (int)(trail_sight_tallies((int)$u['id'])[$gkey] ?? 0);
    if ($last === $dayNo) return [false, trail_sight_split_who($f['who'])[0] . ' has had what they need from you today.'];
    $haveG = $anyG !== null ? sights5_any_have((int)$u['id'], $anyG)[1] >= $gq : ($gid && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $gid]) >= $gq);
    if (!$haveG) return [false, 'You need ' . $gq . ' × ' . $gname . ' for that.'];
    $rolled = sights5_folk_roll($u, $f, $now);   // fifth pass: their own check is rolled BEFORE anything is taken: a miss keeps the gift, costs the time and says the miss line
    if ($rolled === false) { gclock_charge((int)$u['id'], 'sight'); exp_log($exp, '💬 ' . sights5_folk_miss_text($f, $now) . ' (you keep your ' . $gname . ')'); return [true, '']; }
    if (!($anyG !== null ? sights5_any_use((int)$u['id'], $anyG, $gq) : give_item((int)$u['id'], $gid, -$gq))) return [false, 'You need ' . $gq . ' × ' . $gname . ' for that.'];
    try { if (q('UPDATE trail_sight_tally SET n = ? WHERE user_id = ? AND tkey = ?', [$dayNo, (int)$u['id'], $gkey])->rowCount() < 1) db_insert('trail_sight_tally', ['user_id' => (int)$u['id'], 'tkey' => $gkey, 'n' => $dayNo]); } catch (Throwable $e) { /* a double click: the user lock already serialises */ }
    gclock_charge((int)$u['id'], 'sight');
    $lines = trail_sight_pay($u, $loc, $f['rewards'], $f['who'], $now, $rolled === true);
    exp_log($exp, '🎁 You give ' . trail_sight_split_who($f['who'])[0] . ' ' . $gq . ' × ' . $gname . '. ' . $f['line'] . ($lines ? ' (' . implode(', ', $lines) . ')' : ''));
    return [true, ''];
}
