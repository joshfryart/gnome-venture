<?php
// v2.0.31 Garden Plot Logic. Run by plot.sh on a fresh install (temp copy, SQLite):
//   generator property tests (every daily bed has exactly one solution, checked by a second, independent solver),
//   then the server rules: input checks, min-time, hints, wrong checks, first-solve-only payout, stale-bed clearing.
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
require_once $argv[1] . '/includes/games.php';
require_once $argv[1] . '/includes/plot.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }

/** A second solver on purpose different from plot_solve: whole rows from the 120 permutations, rules checked only on full grids. */
function ind_count(array $plants, array $given, array $rules, array $pests, array $comp, int $limit = 2): int
{
    $perms = [];
    $gen = function (array $pre, array $left) use (&$gen, &$perms) {
        if (!$left) { $perms[] = $pre; return; }
        foreach ($left as $k => $v) { $r = $left; unset($r[$k]); $gen(array_merge($pre, [$v]), $r); }
    };
    $gen([], [0, 1, 2, 3, 4]);
    $found = 0;
    $rows = [];
    $dfs = function (int $r) use (&$dfs, &$rows, &$found, $perms, $plants, $given, $rules, $pests, $comp, $limit): void {
        if ($found >= $limit) return;
        if ($r === 5) {
            $g = array_merge(...$rows);
            foreach ($rules as [$h, $c]) {
                foreach ($g as $i => $v) {
                    if ($plants[$v] !== $c) continue;
                    $x = $i % 5; $y = intdiv($i, 5); $touch = false;
                    foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
                        $xx = $x + $dx; $yy = $y + $dy;
                        if ($xx >= 0 && $xx < 5 && $yy >= 0 && $yy < 5 && $plants[$g[$yy * 5 + $xx]] === $h) $touch = true;
                    }
                    if (!$touch) return;
                }
            }
            $found++;
            return;
        }
        foreach ($perms as $p) {
            $good = true;
            foreach ($p as $c => $v) {
                $cell = $r * 5 + $c;
                if (isset($given[$cell]) && $given[$cell] !== $v) { $good = false; break; }
                if (isset($pests[$cell]) && !in_array($pests[$cell], $comp[$plants[$v]]['pests'] ?? [], true)) { $good = false; break; }
                foreach ($rows as $prev) if ($prev[$c] === $v) { $good = false; break 2; }
            }
            if (!$good) continue;
            $rows[] = $p;
            $dfs($r + 1);
            array_pop($rows);
        }
    };
    $dfs(0);
    return $found;
}

$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u['id'];
q('UPDATE users SET coins = 0, level = 20, energy = 5 WHERE id = ?', [$uid]);
cfg(['games_petals_percent' => 60, 'games_give_xp' => 0, 'plot_plays_per_day' => 5, 'plot_min_seconds' => 45, 'season_force' => '']);

echo "== table and registry\n";
$comp = companion_defs(true);
ok('companion_plants is seeded from companions.txt', count($comp) >= 11 && in_array('tomato', $comp['basil']['helps'] ?? [], true));
ok('GAMES has the plot row', isset(GAMES['plot']) && GAMES['plot'][2] === 'plot.php' && GAMES['plot'][4] === 'plot_plays_per_day');
ok('settings default: 1 bed a day, 45 s', setting('plot_min_seconds') === '45');

echo "== generator: many daily seeds, each with exactly one solution\n";
$total = 0; $badUnique = 0; $badGivens = 0; $noPest = 0; $badPool = 0; $badRule = 0; $badPestOk = 0; $maxMs = 0.0; $sumMs = 0.0; $withRule = 0;
$per = (int)(getenv('PLOT_DAYS') ?: 365);
foreach (array_keys(PLOT_POOLS) as $season) {
    for ($d = 0; $d < $per; $d++) {
        $t = microtime(true);
        $b = plot_generate(hash_hmac('sha256', 'plot|day' . $d, 'testsecret'), $season, $comp);
        $ms = (microtime(true) - $t) * 1000; $sumMs += $ms; $maxMs = max($maxMs, $ms); $total++;
        $n = count($b['given']);
        if ($n < 6 || $n > 10) $badGivens++;
        if (!$b['pests']) $noPest++;
        if (array_diff($b['plants'], PLOT_POOLS[$season]) || count(array_unique($b['plants'])) !== 5) $badPool++;
        foreach ($b['rules'] as [$h, $c]) if (!in_array($c, $comp[$h]['helps'] ?? [], true) || !in_array($h, $b['plants'], true) || !in_array($c, $b['plants'], true)) $badRule++;
        if ($b['rules']) $withRule++;
        foreach ($b['pests'] as $cell => $kind) if (!in_array($kind, $comp[$b['plants'][$b['sol'][$cell]]]['pests'] ?? [], true)) $badPestOk++;
        $given = [];
        foreach ($b['given'] as $c => $v) $given[(int)$c] = (int)$v;
        $one = ind_count($b['plants'], $given, $b['rules'], $b['pests'], $comp) === 1;
        $mine = count(plot_solve($given, array_map(fn($r) => [array_search($r[0], $b['plants']), array_search($r[1], $b['plants'])], $b['rules']), [], 2)) >= 1;
        foreach ($b['given'] as $c => $v) if ($b['sol'][(int)$c] !== $v) $one = false;
        if (!$one || !$mine) { $badUnique++; if ($badUnique < 4) echo "    not unique: $season day $d\n"; }
    }
}
ok("$total beds ($per days x 4 seasons): every one has exactly one solution (independent solver)", $badUnique === 0, "$badUnique bad");
ok('every bed has 6-10 givens', $badGivens === 0, "$badGivens bad");
ok('every bed has at least one pest square', $noPest === 0, "$noPest without");
ok('plants are 5 distinct crops from that season’s pool', $badPool === 0, "$badPool bad");
ok('every companion rule is a real helps pair from the table', $badRule === 0, "$badRule bad");
ok('every pest square holds a plant that keeps that pest off', $badPestOk === 0, "$badPestOk bad");
ok('most beds carry a companion clue (' . $withRule . '/' . $total . ')', $withRule >= $total * 0.9);
ok('generation averages under 150 ms (avg ' . round($sumMs / $total) . ' ms, max ' . round($maxMs) . ' ms)', $sumMs / $total < 150);
$a = plot_generate('seedA', 'summer', $comp); $a2 = plot_generate('seedA', 'summer', $comp); $b = plot_generate('seedB', 'summer', $comp);
ok('same seed gives the same bed, another seed another bed', $a === $a2 && $a !== $b);

echo "== today's bed\n";
$t1 = plot_today(); $t2 = plot_today();
ok('plot_today is cached and stable', $t1 === $t2 && $t1['day'] === game_day() && json_decode(setting('plot_cache'), true)['day'] === game_day());
ok('the cache is a hidden setting (not in the schema)', !isset(settings_schema()['plot_cache']));
$names = plot_names($t1['plants']);
ok('plant names come from the plants table', count($names) === 5 && !in_array('', $names, true));

function reset_user(): void { global $uid; q('DELETE FROM game_state WHERE user_id = ?', [$uid]); q("DELETE FROM game_scores WHERE user_id = ? AND game = 'plot'", [$uid]); }
function petals(): int { global $uid; return (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]); }
function st(): ?array { global $uid; return game_state($uid, 'plot'); }
function fresh_u(): array { global $uid; return q_one('SELECT * FROM users WHERE id = ?', [$uid]); }
function setst(array $s): void { global $uid; game_save($uid, 'plot', $s); }
/** The posted g[] for the right answer (locked squares are forced anyway). */
function solgrid(array $s): array { $g = []; foreach ($s['sol'] as $i => $v) $g[$i] = (string)$v; return $g; }
function wronggrid(array $s): array { $g = solgrid($s); foreach ($s['sol'] as $i => $v) if (!isset($s['given'][$i]) && !in_array($i, $s['hints'], true)) { $g[$i] = (string)(($v + 1) % 5); } return $g; }
function back(int $secs): void { $s = st(); $s['t0'] = time() - $secs; setst($s); }

echo "== start, input checks, min time\n";
reset_user();
[$ok1, $m1] = plot_start(fresh_u());
$s = st();
ok('start makes a state with the day’s bed', $ok1 && $s && $s['day'] === game_day() && $s['plants'] === $t1['plants'] && $s['paid'] === true && count($s['grid']) === 25);
ok('state holds the solution server side (sol), copied from the day', count($s['sol']) === 25);
[$ok2, $m2] = plot_start(fresh_u());
ok('a second start keeps the same bed', $ok2 && st()['t0'] === $s['t0']);
ok('a round in progress counts as a play', game_plays_left($uid, 'plot') === 4);
ok('26 posted entries are refused', plot_read_grid($s, array_fill(0, 26, '1')) === null);
$g = plot_read_grid($s, [0 => '5', 1 => 'x', 2 => '3', 3 => '-1', 4 => '2']);
$free = array_values(array_diff(range(0, 24), array_keys($s['given'])));
ok('bad values (5, x, -1) become empty, good ones stay', $g !== null);
$firstFree = $free[0];
$g2 = plot_read_grid($s, [$firstFree => '5']); $g3 = plot_read_grid($s, [$firstFree => '3']);
ok('5 and text are sanitised to empty, 3 is kept', $g2[$firstFree] === -1 && $g3[$firstFree] === 3);
$lockedCell = (int)array_key_first($s['given']);
$g4 = plot_read_grid($s, [$lockedCell => ($s['given'][$lockedCell] + 1) % 5]);
ok('posting a changed given leaves it unchanged', $g4[$lockedCell] === $s['given'][$lockedCell]);
ok('a key outside 0-24 is refused', plot_read_grid($s, [30 => '1']) === null);
[$okc, $mc] = plot_check(fresh_u(), solgrid($s));
ok('a check before plot_min_seconds is refused, checks unchanged', !$okc && stripos($mc, 'proper look') !== false && st() && st()['wrong'] === 0);
[$okn, $mn] = plot_check(fresh_u(), array_slice(solgrid($s), 0, 3, true));
ok('an unfilled bed is refused', !$okn && stripos($mn, 'Fill every square') !== false && st()['wrong'] === 0);

echo "== save, hints\n";
back(600);
$part = []; foreach ($free as $i) { $part[$i] = (string)$s['sol'][$i]; break; }
[$oks] = plot_save(fresh_u(), $part);
ok('save keeps the posted squares', $oks && st()['grid'][$free[0]] === $s['sol'][$free[0]]);
$full = wronggrid($s);
[$okf, $mf] = plot_hint(fresh_u(), $full);
ok('a full bed gets no hint (no free oracle), hints unchanged', !$okf && stripos($mf, 'bed is full') !== false && count(st()['hints']) === 0);
[$okf2, $mf2] = plot_hint(fresh_u(), solgrid($s));
ok('a full correct bed gets the same answer, not "already right"', !$okf2 && $mf2 === $mf && count(st()['hints']) === 0 && st()['wrong'] === 0);
$w = $full; unset($w[$free[0]]);   // one square cleared, so Old Moss can help
$p0 = petals();
[$okh, $mh] = plot_hint(fresh_u(), $w);
$s = st();
ok('hint plants a right plant on a wrong square and locks it', $okh && count($s['hints']) === 1 && $s['grid'][$s['hints'][0]] === $s['sol'][$s['hints'][0]]);
[$okh2] = plot_hint(fresh_u(), $w);
[$okh3, $mh3] = plot_hint(fresh_u(), $w);
ok('only 2 hints a bed without Lore', $okh2 && !$okh3 && stripos($mh3, 'all his hints') !== false && count(st()['hints']) === 2);
$hs = st()['hints'];
$g5 = plot_read_grid(st(), [$hs[0] => ($s['sol'][$hs[0]] + 1) % 5]);
ok('a hint square cannot be overwritten', $g5[$hs[0]] === $s['sol'][$hs[0]]);
q('UPDATE users SET stat_lore = 30 WHERE id = ?', [$uid]);
reset_user(); plot_start(fresh_u());
ok('Lore mod 2 or more gives a third hint (hmax 3)', st()['hmax'] === 3);
q('UPDATE users SET stat_lore = 10 WHERE id = ?', [$uid]);

echo "== wrong checks end the bed, no leak\n";
reset_user(); plot_start(fresh_u()); back(600);
$s = st();
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
[$okw1, $mw1] = plot_check(fresh_u(), wronggrid($s));
ok('a wrong check costs a check and says only how many are left', !$okw1 && st()['wrong'] === 1 && stripos($mw1, '2 checks left') !== false && !preg_match('/row|column|square \d/i', $mw1));
plot_check(fresh_u(), wronggrid($s));
[$okw3] = plot_check(fresh_u(), wronggrid($s));
ok('the 3rd wrong check ends the bed unsolved, 0 Petals', $okw3 && st() === null && petals() === 0);
ok('an unsolved bed writes score 0 and counts as a play', (int)q_val("SELECT COUNT(*) FROM game_scores WHERE user_id = ? AND game = 'plot' AND day = ? AND score = 0", [$uid, game_day()]) === 1);
ok('energy +1 for an unsolved bed', (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $e0 + 1);

echo "== a solve pays once\n";
reset_user(); q('UPDATE users SET coins = 0 WHERE id = ?', [$uid]); plot_start(fresh_u()); back(100);
$s = st();
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
[$oksv] = plot_check(fresh_u(), solgrid($s));
ok('a correct check solves the bed', $oksv && st() === null);
ok('score 120 (100 + 20 time bonus) pays game_petals(120)', petals() === game_petals(120) && (int)q_val("SELECT MAX(score) FROM game_scores WHERE user_id = ? AND game = 'plot'", [$uid]) === 120, petals() . ' vs ' . game_petals(120));
ok('+2 energy for a clean solve', (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $e0 + 2);
$after = petals();
plot_start(fresh_u());
ok('second bed of the day is a practice bed (paid false)', st()['paid'] === false);
back(100);
plot_check(fresh_u(), solgrid(st()));
ok('a practice solve pays 0 Petals and writes score 0', petals() === $after && (int)q_val("SELECT COUNT(*) FROM game_scores WHERE user_id = ? AND game = 'plot' AND day = ? AND score = 0", [$uid, game_day()]) === 1);

echo "== replays (plot_plays_per_day raised) never pay\n";
reset_user(); q('UPDATE users SET coins = 0 WHERE id = ?', [$uid]);
plot_start(fresh_u()); back(600);
for ($k = 0; $k < PLOT_CHECKS; $k++) plot_check(fresh_u(), wronggrid(st()));
ok('the first bed ends unsolved (answer shown)', st() === null && petals() === 0);
plot_start(fresh_u());
ok('a bed started after an unsolved one is a practice bed (paid false)', st()['paid'] === false);
back(100);
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
[$okr] = plot_check(fresh_u(), solgrid(st()));
ok('solving the replay of a failed bed pays 0 Petals, 0 energy and scores 0', $okr && petals() === 0 && (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $e0
    && (int)q_val("SELECT MAX(score) FROM game_scores WHERE user_id = ? AND game = 'plot' AND day = ?", [$uid, game_day()]) === 0);
plot_start(fresh_u()); back(600);
$e1 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
for ($k = 0; $k < PLOT_CHECKS; $k++) plot_check(fresh_u(), wronggrid(st()));
ok('failing a practice bed gives no energy', (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $e1);
reset_user(); q('UPDATE users SET coins = 0 WHERE id = ?', [$uid]);
plot_start(fresh_u()); back(100); plot_check(fresh_u(), solgrid(st()));
$once = petals();
for ($k = 0; $k < 3; $k++) { plot_start(fresh_u()); back(100); plot_check(fresh_u(), solgrid(st())); }
ok('a solved bed pays once, however many replays', $once === game_petals(120) && petals() === $once
    && (int)q_val("SELECT COUNT(*) FROM game_scores WHERE user_id = ? AND game = 'plot' AND day = ? AND score > 0", [$uid, game_day()]) === 1);
reset_user(); plot_start(fresh_u());
$s = st(); $s['paid'] = true; setst($s); back(100);
game_score($uid, 'plot', 0);   // an unsolved bed in another tab finished first
plot_check(fresh_u(), solgrid(st()));
ok('a stale paid flag is re-checked at finish against any finished bed today', petals() === $once);

echo "== copy, Almanac, wiring\n";
ok('articles: an aphid, a slug, an Onion', plot_a('aphid') === 'an aphid' && plot_a('slug') === 'a slug' && plot_a('Onion') === 'an Onion');
ok('lists: A / A or B / A, B or C', plot_or(['A']) === 'A' && plot_or(['A', 'B']) === 'A or B' && plot_or(['A', 'B', 'C']) === 'A, B or C');
$alm = fn() => (string)q_val("SELECT body FROM encyclopedia_entries WHERE title = 'Games' AND chapter = 'General'");
ok('fresh install: the Almanac Games page has the Plot line', str_contains($alm(), '🪴 [b]Garden Plot Logic:[/b]') && $alm() === GAMES_PAGE);
$old = preg_replace('/^🪴 \[b\]Garden Plot Logic:.*\n/mu', '', GAMES_PAGE);
q("UPDATE encyclopedia_entries SET body = ? WHERE title = 'Games' AND chapter = 'General'", [$old]);
ensure_games();
ok('upgrade: ensure_games puts the line back where GAMES_PAGE has it', $old !== GAMES_PAGE && $alm() === GAMES_PAGE);
ensure_games();
ok('and only once', substr_count($alm(), 'Garden Plot Logic') === 1);
$tagBad = 0;
foreach (PLOT_POOLS as $pool) { $nm = plot_names($pool); $tg = plot_tags($nm); if (count(array_unique(array_map('mb_strtolower', $tg))) !== count($pool) || max(array_map('mb_strlen', $tg)) > 5) $tagBad++; }
ok('square tags tell every pool’s plants apart (short, unique)', $tagBad === 0);
ok('page_area: plot.php is in the book area', page_area('plot.php') === 'book');
ok('plot.php updates in place (AJAX_PAGES)', in_array('plot.php', AJAX_PAGES, true));
ok('games_petals_percent label names Garden Plot', str_contains(settings_schema()['games_petals_percent']['label'], 'Garden Plot'));

echo "== scoring formula\n";
ok('no hints, no slips, fast: 120', plot_score(0, 0, 100) === 120);
ok('1 hint, 1 wrong, 3:30: 100-10-10+ (20-2)=98', plot_score(1, 1, 210) === 98, (string)plot_score(1, 1, 210));
ok('slow solve has no bonus and a floor of 30', plot_score(2, 2, 3000) === 60 && plot_score(2, 2, 3000) >= 30);
ok('the floor is 30 when solved', plot_score(3, 2, 3000) >= 30);

echo "== two parallel correct checks pay once\n";
reset_user(); q('UPDATE users SET coins = 0 WHERE id = ?', [$uid]); plot_start(fresh_u()); back(100);
$s = st(); $s['grid'] = array_map('intval', $s['sol']);
db()->beginTransaction(); q('UPDATE users SET id = id WHERE id = ?', [$uid]);
[$r1] = plot_finish(fresh_u(), $s, true);
db()->beginTransaction(); q('UPDATE users SET id = id WHERE id = ?', [$uid]);
[$r2] = plot_finish(fresh_u(), $s, true);
if (db()->inTransaction()) db()->commit();
ok('the second claim finds the round gone and pays nothing', $r1 && !$r2 && petals() === game_petals(120), petals() . '');

echo "== a scored solve elsewhere stops the payout\n";
reset_user(); q('UPDATE users SET coins = 0 WHERE id = ?', [$uid]); plot_start(fresh_u()); back(100);
game_score($uid, 'plot', 80);   // another tab / an admin-raised setting got there first
plot_check(fresh_u(), solgrid(st()));
ok('paid flag alone is not enough: re-checked at finish', petals() === 0);

echo "== stale bed from yesterday\n";
reset_user(); plot_start(fresh_u());
$s = st(); $s['day'] = '2000-01-01'; setst($s);
plot_stale($uid);
ok('yesterday’s bed is cleared with no score and no payout', st() === null && (int)q_val("SELECT COUNT(*) FROM game_scores WHERE user_id = ? AND game = 'plot'", [$uid]) === 0);
ok('and does not use up a play', game_plays_left($uid, 'plot') === 5);
$s = ['day' => '2000-01-01'] + ['plants' => [], 'given' => [], 'hints' => [], 'sol' => [], 'grid' => [], 'rules' => [], 'pests' => [], 'pk' => [], 'wrong' => 0, 't0' => 0, 'hmax' => 2, 'paid' => true];
setst($s);
[$okx] = plot_start(fresh_u());
ok('plot_start clears a stale bed first and starts today’s', $okx && st()['day'] === game_day());

echo "== plays per day and petals percent\n";
reset_user(); cfg(['plot_plays_per_day' => 1]);
plot_start(fresh_u()); back(100); plot_check(fresh_u(), solgrid(st()));
[$okp] = plot_start(fresh_u());
ok('with 1 bed a day a second start is refused', !$okp);
cfg(['plot_plays_per_day' => 5]);
reset_user(); q('UPDATE users SET coins = 0 WHERE id = ?', [$uid]); cfg(['games_petals_percent' => 100]);
plot_start(fresh_u()); back(100); plot_check(fresh_u(), solgrid(st()));
ok('games_petals_percent scales the payout (100% = 120)', petals() === 120, petals() . '');
cfg(['games_petals_percent' => 60]);

reset_user();
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
