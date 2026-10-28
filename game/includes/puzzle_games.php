<?php
declare(strict_types=1);
/**
 * v2.0.71: the puzzle games behind the Puzzles hub (puzzles.php): shared pieces + Rain Barrel (rainbarrel.php).
 * Pattern for every game here: the SERVER builds the puzzle from a seed (the client never gets the answer), start gives a single-use token,
 * finish sends the moves, the server re-checks them and times the run on its own clock. A daily puzzle is the same for everyone (seed from the
 * Hollow game day); practice is a random seed and pays nothing. The daily reward is paid once per game per day (puzzle_wins UNIQUE insert).
 * Tables puzzle_runs / puzzle_wins come from puzzles_schema() (includes/puzzles.php).
 */
require_once __DIR__ . '/puzzles.php';
require_once __DIR__ . '/jobs.php';   // job_period_key() for game_day()
require_once __DIR__ . '/games.php';
require_once __DIR__ . '/rewards.php';

const PUZZLE_GAMES = [
    'barrel' => ['Rain Barrel', '🚰', 'rainbarrel.php', 'Turn the gutters so the water reaches every sprout.', 'pz_barrel_open'],
    'beds' => ['Gnome Beds', '🛏️', 'gnomebeds.php', 'One gnome in every row, column and bed.', 'pz_beds_open'],
];
const PZ_HINT_MS = 20000;
const PZ_MAX_HINTS = 3;
const PZ_DAILY_STARTS = 20;
const PZ_PRACTICE_STARTS = 60;
const PZ_BARREL_SIZES = [6 => 6000, 8 => 11000, 5 => 4000];   // size => fastest believable solve (ms)
const PZ_BEDS_SIZES = [8 => 9000, 6 => 5000, 7 => 7000, 9 => 11000];

/** Make the run tables if the upgrade hasn't yet. */
function pzgames_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM puzzle_runs LIMIT 1'); q('SELECT 1 FROM puzzle_wins LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        $s = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        [$t, $i] = puzzles_schema($s ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $s ? 'INTEGER' : 'INT UNSIGNED', $s ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
        foreach ($t as $sql) db()->exec($sql);
        foreach ($i as $sql) { try { db()->exec($sql); } catch (Throwable $e) {} }
        return $ok = true;
    } catch (Throwable $e) {
        error_log('pzgames_ensure: ' . $e->getMessage());
        return $ok = false;
    }
}

/** Is a puzzle game open to this viewer? (Puzzles open + the game's own switch; admins always.) */
function puzzle_game_open(string $k): bool
{
    if (!isset(PUZZLE_GAMES[$k])) return false;
    if (is_admin()) return true;
    return setting('puzzles_open') === '1' && setting(PUZZLE_GAMES[$k][4]) === '1';
}

// ---------------- seeded random (same generator as assets/puzzles.js) ----------------

function pz_imul(int $a, int $b): int
{
    return (($a & 0xffff) * $b + (((($a >> 16) & 0xffff) * $b) & 0xffff) * 65536) & 0xffffffff;
}

/** mulberry32 as a closure: each call gives a float in [0, 1). */
function pz_rng(int $seed): callable
{
    $a = $seed & 0xffffffff;
    return function () use (&$a): float {
        $a = ($a + 0x6D2B79F5) & 0xffffffff;
        $t = $a;
        $t = pz_imul($t ^ ($t >> 15), $t | 1);
        $t = ($t ^ (($t + pz_imul($t ^ ($t >> 7), $t | 61)) & 0xffffffff)) & 0xffffffff;
        return (($t ^ ($t >> 14)) & 0xffffffff) / 4294967296;
    };
}

function pz_daily_seed(string $game, string $day, int $size = 0): int
{
    return crc32('pz|' . $game . '|' . $day . '|' . $size) & 0xffffffff;
}

// ---------------- Rain Barrel: pipes on a grid ----------------
// Tile masks: N=1, E=2, S=4, W=8. Turning a tile clockwise moves each opening N->E->S->W.

function rb_rot(int $m, int $times = 1): int
{
    for ($k = 0, $t = $times & 3; $k < $t; $k++) $m = (($m << 1) | ($m >> 3)) & 15;
    return $m;
}

/** The puzzle for a seed: ['n', 'sol' (solved masks), 'scr' (masks as dealt), 'src' (barrel cell)]. A spanning tree, so there are no loops. */
function rb_make(int $seed, int $n): array
{
    $rnd = pz_rng($seed);
    $N = $n * $n;
    $sol = array_fill(0, $N, 0);
    $seen = array_fill(0, $N, false);
    $start = (int)floor($rnd() * $N);
    $seen[$start] = true;
    $front = [];
    $addFront = function (int $c) use (&$front, $n, $seen) {
        $x = $c % $n; $y = intdiv($c, $n);
        if ($y > 0) $front[] = [$c, $c - $n, 1, 4];
        if ($x < $n - 1) $front[] = [$c, $c + 1, 2, 8];
        if ($y < $n - 1) $front[] = [$c, $c + $n, 4, 1];
        if ($x > 0) $front[] = [$c, $c - 1, 8, 2];
    };
    $addFront($start);
    while ($front) {
        $k = $rnd() < 0.5 ? count($front) - 1 : (int)floor($rnd() * count($front));
        [$a, $b, $da, $db] = $front[$k];
        array_splice($front, $k, 1);
        if ($seen[$b]) continue;
        $seen[$b] = true;
        $sol[$a] |= $da; $sol[$b] |= $db;
        $addFront($b);
    }
    $scr = [];
    for ($i = 0; $i < $N; $i++) $scr[$i] = rb_rot($sol[$i], (int)floor($rnd() * 4));
    for ($guard = 0; rb_valid($scr, $n) && $guard < 50; $guard++) { $k = (int)floor($rnd() * $N); $scr[$k] = rb_rot($scr[$k]); }
    $leaves = [];
    foreach ($sol as $i => $m) if (in_array($m, [1, 2, 4, 8], true)) $leaves[] = $i;
    $src = $leaves ? $leaves[(int)floor($rnd() * count($leaves))] : $start;   // the barrel sits at the end of a pipe; every other end is a sprout
    return ['n' => $n, 'sol' => $sol, 'scr' => $scr, 'src' => $src];
}

/** True when every tile is joined to the barrel's water with no open end left over (no leaks). */
function rb_valid(array $m, int $n): bool
{
    $N = $n * $n;
    if (count($m) !== $N) return false;
    $dirs = [[1, 4, 0, -1], [2, 8, 1, 0], [4, 1, 0, 1], [8, 2, -1, 0]];   // bit, opposite bit, dx, dy
    for ($c = 0; $c < $N; $c++) {
        $x = $c % $n; $y = intdiv($c, $n);
        foreach ($dirs as [$bit, $opp, $dx, $dy]) {
            if (!($m[$c] & $bit)) continue;
            $nx = $x + $dx; $ny = $y + $dy;
            if ($nx < 0 || $ny < 0 || $nx >= $n || $ny >= $n) return false;
            if (!($m[$ny * $n + $nx] & $opp)) return false;
        }
    }
    $seen = [0 => true]; $stack = [0];
    while ($stack) {
        $c = array_pop($stack); $x = $c % $n; $y = intdiv($c, $n);
        foreach ($dirs as [$bit, , $dx, $dy]) {
            if (!($m[$c] & $bit)) continue;
            $d = ($y + $dy) * $n + $x + $dx;
            if (!isset($seen[$d])) { $seen[$d] = true; $stack[] = $d; }
        }
    }
    return count($seen) === $N;
}

/** Apply a player's turns (r[i] = clockwise quarter-turns from the dealt tile) to the dealt masks. Null if r is malformed. */
function rb_apply(array $scr, array $r): ?array
{
    if (count($r) !== count($scr)) return null;
    $out = [];
    foreach ($scr as $i => $m) {
        $t = $r[$i] ?? null;
        if (!is_int($t) || $t < 0 || $t > 3) return null;
        $out[$i] = rb_rot((int)$m, $t);
    }
    return $out;
}

// ---------------- Gnome Beds: one gnome per row, column and bed, none touching ----------------
// A grid n x n of n coloured beds (regions). Cells are row*n+col. A placement is a list of n columns, one per row (-1 = none yet).

/** Solutions (up to $limit) of a bed layout; each is a list of n columns. */
function gb_solutions(array $reg, int $n, int $limit = 2): array
{
    $out = [];
    $cols = array_fill(0, $n, -1);
    $rec = function (int $r, int $usedC, int $usedR) use (&$rec, &$out, &$cols, $reg, $n, $limit) {
        if (count($out) >= $limit) return;
        if ($r === $n) { $out[] = $cols; return; }
        for ($c = 0; $c < $n; $c++) {
            if ($usedC & (1 << $c)) continue;
            $g = $reg[$r * $n + $c];
            if ($usedR & (1 << $g)) continue;
            if ($r > 0 && abs($c - $cols[$r - 1]) <= 1) continue;
            $cols[$r] = $c;
            $rec($r + 1, $usedC | (1 << $c), $usedR | (1 << $g));
            $cols[$r] = -1;
            if (count($out) >= $limit) return;
        }
    };
    $rec(0, 0, 0);
    return $out;
}

/** Is region $a still one connected piece once cell $x is taken out of it? */
function gb_connected_without(array $reg, int $n, int $a, int $x): bool
{
    $cells = [];
    foreach ($reg as $c => $g) if ($g === $a && $c !== $x) $cells[] = $c;
    if (!$cells) return false;
    $seen = [$cells[0] => true]; $st = [$cells[0]];
    while ($st) {
        $c = array_pop($st); $cx = $c % $n; $cy = intdiv($c, $n);
        foreach ([[0, -1], [1, 0], [0, 1], [-1, 0]] as [$dx, $dy]) {
            $nx = $cx + $dx; $ny = $cy + $dy;
            if ($nx < 0 || $ny < 0 || $nx >= $n || $ny >= $n) continue;
            $d = $ny * $n + $nx;
            if (($reg[$d] ?? -1) === $a && $d !== $x && !isset($seen[$d])) { $seen[$d] = true; $st[] = $d; }
        }
    }
    return count($seen) === count($cells);
}

/** The puzzle for a seed: ['n', 'reg' (bed index per cell), 'sol' (columns per row)]. The layout has exactly one solution:
 *  beds grow from a legal placement, then any other solution is broken by moving a border cell into a neighbouring bed. */
function gb_make(int $seed, int $n): array
{
    $rnd = pz_rng($seed);
    $shuffle = function (array $a) use ($rnd): array { for ($i = count($a) - 1; $i > 0; $i--) { $j = (int)floor($rnd() * ($i + 1)); [$a[$i], $a[$j]] = [$a[$j], $a[$i]]; } return $a; };
    $dirs = [[0, -1], [1, 0], [0, 1], [-1, 0]];
    $best = null;
    for ($outer = 0; $outer < 12; $outer++) {
        $cols = array_fill(0, $n, -1);
        $place = function (int $r, int $used) use (&$place, &$cols, $n, $shuffle): bool {
            if ($r === $n) return true;
            foreach ($shuffle(range(0, $n - 1)) as $c) {
                if ($used & (1 << $c)) continue;
                if ($r > 0 && abs($c - $cols[$r - 1]) <= 1) continue;
                $cols[$r] = $c;
                if ($place($r + 1, $used | (1 << $c))) return true;
                $cols[$r] = -1;
            }
            return false;
        };
        if (!$place(0, 0)) continue;
        $gn = []; foreach ($cols as $r => $c) $gn[$r * $n + $c] = $r;   // gnome cell => bed
        $reg = array_fill(0, $n * $n, -1);
        $front = [];
        $push = function (int $c, int $g) use (&$front, $n, &$reg, $dirs) {
            $x = $c % $n; $y = intdiv($c, $n);
            foreach ($dirs as [$dx, $dy]) {
                $nx = $x + $dx; $ny = $y + $dy;
                if ($nx >= 0 && $ny >= 0 && $nx < $n && $ny < $n && $reg[$ny * $n + $nx] < 0) $front[] = [$ny * $n + $nx, $g];
            }
        };
        foreach ($gn as $c => $g) $reg[$c] = $g;
        foreach ($gn as $c => $g) $push($c, $g);
        while ($front) {
            $k = (int)floor($rnd() * count($front));
            [$c, $g] = $front[$k];
            $front[$k] = $front[count($front) - 1]; array_pop($front);
            if ($reg[$c] >= 0) continue;
            $reg[$c] = $g;
            $push($c, $g);
        }
        for ($it = 0; $it < 400; $it++) {
            $sols = gb_solutions($reg, $n, 6);
            if (count($sols) === 1) return ['n' => $n, 'reg' => $reg, 'sol' => $sols[0]];
            if ($best === null || count($sols) < $best[0]) $best = [count($sols), ['n' => $n, 'reg' => $reg, 'sol' => $cols]];
            $alt = null;
            foreach ($sols as $sl) if ($sl !== $cols) { $alt = $sl; break; }
            if ($alt === null) break;
            // moves that kill this other solution: take one of its gnomes' cells (not our own gnome) into a bed it already uses elsewhere
            $moves = []; $other = [];
            foreach ($shuffle(array_keys($alt)) as $r) {
                $x = $r * $n + $alt[$r];
                if (isset($gn[$x])) continue;
                $a = $reg[$x];
                $xc = $x % $n; $xr = intdiv($x, $n);
                foreach ($shuffle($dirs) as [$dx, $dy]) {
                    $nx = $xc + $dx; $ny = $xr + $dy;
                    if ($nx < 0 || $ny < 0 || $nx >= $n || $ny >= $n) continue;
                    $b = $reg[$ny * $n + $nx];
                    if ($b === $a || !gb_connected_without($reg, $n, $a, $x)) continue;
                    $used = false;
                    foreach ($alt as $r2 => $c2) if ($r2 !== $r && $reg[$r2 * $n + $c2] === $b) { $used = true; break; }
                    if ($used) $moves[] = [$x, $b]; else $other[] = [$x, $b];
                }
            }
            $pick = $moves ?: $other;
            if (!$pick || $rnd() < 0.08) {   // stuck (the other answer sits inside a bed) or a little noise: move any border cell that isn't a gnome's
                $pick = [];
                foreach ($shuffle(range(0, $n * $n - 1)) as $x) {
                    if (isset($gn[$x])) continue;
                    $xc = $x % $n; $xr = intdiv($x, $n);
                    foreach ($shuffle($dirs) as [$dx, $dy]) {
                        $nx = $xc + $dx; $ny = $xr + $dy;
                        if ($nx < 0 || $ny < 0 || $nx >= $n || $ny >= $n) continue;
                        $b = $reg[$ny * $n + $nx];
                        if ($b !== $reg[$x] && gb_connected_without($reg, $n, $reg[$x], $x)) { $pick[] = [$x, $b]; break 2; }
                    }
                }
                if (!$pick) break;
            }
            [$x, $b] = $pick[(int)floor($rnd() * count($pick))];
            $reg[$x] = $b;
        }
    }
    return $best[1] ?? ['n' => $n, 'reg' => [], 'sol' => []];   // not reached for sizes 5 to 9 in practice (tests check)
}

/** gb_make() with a small file cache (data/pzcache): a garden can take a second to build and start, hint and finish all need it. */
function gb_get(int $seed, int $n): array
{
    static $mem = [];
    $k = $seed . '-' . $n;
    if (isset($mem[$k])) return $mem[$k];
    $dir = APP_ROOT . '/data/pzcache';
    $f = $dir . '/beds-' . $k . '.json';
    $j = is_file($f) ? json_decode((string)@file_get_contents($f), true) : null;
    if (is_array($j) && isset($j['reg'], $j['sol'])) return $mem[$k] = $j;
    $p = gb_make($seed, $n);
    if (@is_dir($dir) || @mkdir($dir, 0775, true)) {
        $tmp = $f . '.' . bin2hex(random_bytes(4));
        if (@file_put_contents($tmp, json_encode($p)) !== false) @rename($tmp, $f);
        if (random_int(1, 30) === 1) foreach (glob($dir . '/beds-*.json') ?: [] as $old) if (@filemtime($old) < time() - 3 * 86400) @unlink($old);
    }
    return $mem[$k] = $p;
}

/** True when $g (n columns, -1 = empty) is a full legal placement: every row, column and bed once, no gnomes touching. */
function gb_valid(array $g, array $reg, int $n): bool
{
    if (count($g) !== $n) return false;
    $uc = $ur = 0;
    foreach ($g as $r => $c) {
        if (!is_int($c) || $c < 0 || $c >= $n) return false;
        $b = $reg[$r * $n + $c];
        if (($uc & (1 << $c)) || ($ur & (1 << $b))) return false;
        $uc |= 1 << $c; $ur |= 1 << $b;
        if ($r > 0 && abs($c - $g[$r - 1]) <= 1) return false;
    }
    return true;
}

// ---------------- runs ----------------

function pzr_row(array $u, string $token): ?array
{
    if (!preg_match('/^[a-f0-9]{32}$/', $token)) return null;
    return q_one('SELECT * FROM puzzle_runs WHERE token = ? AND user_id = ?', [$token, (int)$u['id']]) ?: null;
}

/** Open a run for any game: caps, voids the open one, picks the seed (daily = same for everyone). [ok, token or message, seed, size, mode] */
function pz_run_start(array $u, string $game, string $mode, int $size, array $sizes, int $dailySize): array
{
    if (!pzgames_ensure()) return [false, 'Puzzles aren’t ready yet.', 0, 0, ''];
    $uid = (int)$u['id'];
    $day = game_day();
    if (random_int(1, 50) === 1) q('DELETE FROM puzzle_runs WHERE started_at < ?', [gmdate('Y-m-d H:i:s', time() - 14 * 86400)]);   // old runs (the daily wins and streaks live in puzzle_wins)
    if ($mode !== 'practice') { $mode = 'daily'; $size = $dailySize; }
    if (!isset($sizes[$size])) $size = $dailySize;
    $n = (int)q_val("SELECT COUNT(*) FROM puzzle_runs WHERE user_id = ? AND game = ? AND day = ? AND mode = ?", [$uid, $game, $day, $mode]);
    if ($n >= ($mode === 'daily' ? PZ_DAILY_STARTS : PZ_PRACTICE_STARTS)) return [false, 'That’s enough for today. Come back tomorrow!', 0, 0, ''];
    q("UPDATE puzzle_runs SET status = 'void' WHERE user_id = ? AND game = ? AND status = 'open'", [$uid, $game]);
    $seed = $mode === 'daily' ? pz_daily_seed($game, $day, $size) : random_int(1, 2147483646);
    $token = bin2hex(random_bytes(16));
    db_insert('puzzle_runs', ['token' => $token, 'user_id' => $uid, 'game' => $game, 'day' => $day, 'mode' => $mode, 'size' => $size, 'seed' => $seed,
        'start_ms' => (int)floor(microtime(true) * 1000), 'started_at' => now(), 'status' => 'open']);
    return [true, $token, $seed, $size, $mode];
}

/** An open run of this game for the user, or [null, message]. */
function pz_run_open(array $u, string $game, string $token): array
{
    $run = pzr_row($u, $token);
    if (!$run || $run['game'] !== $game) return [null, 'That run wasn’t found.'];
    if ($run['status'] !== 'open') return [null, 'That run was already handed in.'];
    return [$run, ''];
}

/** Take a hint on a run: +20 s each, 3 at most. True if counted. */
function pz_run_hint(array $run): bool
{
    return q("UPDATE puzzle_runs SET hints = hints + 1 WHERE id = ? AND status = 'open' AND hints < " . PZ_MAX_HINTS, [(int)$run['id']])->rowCount() === 1;
}

/** Close a SOLVED run: refuse impossibly fast ones, add hint time, pay the daily reward once. [ok, message, data] */
function pz_run_finish(array $u, array $run, int $minMs, string $winText): array
{
    $real = (int)floor(microtime(true) * 1000) - (int)$run['start_ms'];
    if ($real < $minMs) {
        q("UPDATE puzzle_runs SET status = 'reject', ms = ? WHERE id = ? AND status = 'open'", [$real, (int)$run['id']]);
        return [false, 'That was faster than a gnome can manage. It didn’t count.', ['rejected' => true]];
    }
    $ms = $real + (int)$run['hints'] * PZ_HINT_MS;
    if (q("UPDATE puzzle_runs SET status = 'done', ms = ? WHERE id = ? AND status = 'open'", [$ms, (int)$run['id']])->rowCount() !== 1) return [false, 'That run was already handed in.', []];
    $uid = (int)$u['id'];
    $game = (string)$run['game'];
    $extra = ['ms' => $ms, 'text' => puzzle_ms_text($ms)];
    $msg = $winText . ' ' . puzzle_ms_text($ms) . '!';
    if ($run['mode'] === 'daily') {
        $best = (int)q_val("SELECT MIN(ms) FROM puzzle_runs WHERE user_id = ? AND game = ? AND day = ? AND mode = 'daily' AND status = 'done'", [$uid, $game, $run['day']]);
        $extra['best'] = $best;
        $first = false;
        try { db_insert('puzzle_wins', ['game' => $game, 'day' => $run['day'], 'user_id' => $uid, 'ms' => $ms, 'created_at' => now()]); $first = true; } catch (Throwable $e) {}
        if ($first) {
            $pet = game_petals((int)setting('pz_daily_petals'));
            if ($pet > 0) give_petals($uid, $pet, 'puzzle ' . $game . ' daily');
            $en = game_energy($uid, true);
            $msg .= ' Daily reward: ' . ($pet > 0 ? money($pet) : 'a pat on the back') . $en . '.';
            $extra['reward'] = $pet;
        } else {
            $msg .= $ms <= $best ? ' A new best for today!' : ' Your best today is ' . puzzle_ms_text($best) . '.';
        }
        $extra['rank'] = 1 + (int)q_val("SELECT COUNT(*) FROM (SELECT user_id, MIN(ms) AS b FROM puzzle_runs WHERE game = ? AND day = ? AND mode = 'daily' AND status = 'done' GROUP BY user_id) x WHERE x.b < ?", [$game, $run['day'], $best]);
    } else {
        $msg .= ' Practice pays nothing but it’s good for you.';
    }
    return [true, $msg, $extra];
}

// ---------------- Rain Barrel runs ----------------

function pz_barrel_start(array $u, string $mode, int $size): array
{
    [$ok, $tok, $seed, $n, $m] = pz_run_start($u, 'barrel', $mode, $size, PZ_BARREL_SIZES, 6);
    if (!$ok) return [false, $tok, []];
    $p = rb_make($seed, $n);
    return [true, $tok, ['n' => $n, 'tiles' => $p['scr'], 'src' => $p['src'], 'mode' => $m]];
}

/** A hint: the first tile (by position) that is wrong against the dealt answer, with its turns. [ok, message, data] */
function pz_barrel_hint(array $u, string $token, array $r): array
{
    [$run, $err] = pz_run_open($u, 'barrel', $token);
    if (!$run) return [false, $err, []];
    if ((int)$run['hints'] >= PZ_MAX_HINTS) return [false, 'The Old Wizard has no more hints for this one.', []];
    $p = rb_make((int)$run['seed'], (int)$run['size']);
    $cur = rb_apply($p['scr'], $r);
    if ($cur === null) return [false, 'Something went wrong. Refresh and try again.', []];
    foreach ($p['sol'] as $i => $want) {
        if ($cur[$i] === $want) continue;
        for ($t = 0; $t < 4; $t++) if (rb_rot($p['scr'][$i], $t) === $want) break;
        if (!pz_run_hint($run)) return [false, 'No more hints.', []];
        return [true, 'Try this one.', ['cell' => $i, 'r' => $t, 'hints' => (int)$run['hints'] + 1]];
    }
    return [false, 'Nothing is wrong that I can see.', []];
}

function pz_barrel_finish(array $u, string $token, array $r): array
{
    [$run, $err] = pz_run_open($u, 'barrel', $token);
    if (!$run) return [false, $err, []];
    $n = (int)$run['size'];
    $p = rb_make((int)$run['seed'], $n);
    $fin = rb_apply($p['scr'], $r);
    if ($fin === null || !rb_valid($fin, $n)) return [false, 'Still leaking. Keep turning!', ['retry' => true]];
    return pz_run_finish($u, $run, PZ_BARREL_SIZES[$n] ?? 6000, 'Every sprout is watered in');
}

// ---------------- Gnome Beds runs ----------------

function pz_beds_start(array $u, string $mode, int $size): array
{
    [$ok, $tok, $seed, $n, $m] = pz_run_start($u, 'beds', $mode, $size, PZ_BEDS_SIZES, 8);
    if (!$ok) return [false, $tok, []];
    $p = gb_get($seed, $n);
    return [true, $tok, ['n' => $n, 'reg' => $p['reg'], 'mode' => $m]];
}

/** $g = the player's columns per row (-1 = empty). Hint = a row that is not on the answer yet. */
function pz_beds_hint(array $u, string $token, array $g): array
{
    [$run, $err] = pz_run_open($u, 'beds', $token);
    if (!$run) return [false, $err, []];
    if ((int)$run['hints'] >= PZ_MAX_HINTS) return [false, 'The Old Wizard has no more hints for this one.', []];
    $n = (int)$run['size'];
    $p = gb_get((int)$run['seed'], $n);
    if (count($g) !== $n) return [false, 'Something went wrong. Refresh and try again.', []];
    foreach ($p['sol'] as $r => $c) {
        if (($g[$r] ?? -1) === $c) continue;
        if (!pz_run_hint($run)) return [false, 'No more hints.', []];
        return [true, 'A gnome belongs here.', ['row' => $r, 'col' => $c, 'hints' => (int)$run['hints'] + 1]];
    }
    return [false, 'Nothing is wrong that I can see.', []];
}

function pz_beds_finish(array $u, string $token, array $g): array
{
    [$run, $err] = pz_run_open($u, 'beds', $token);
    if (!$run) return [false, $err, []];
    $n = (int)$run['size'];
    $p = gb_get((int)$run['seed'], $n);
    if (!gb_valid(array_values($g), $p['reg'], $n)) return [false, 'Not quite. A row, column or bed is doubled, or two gnomes touch.', ['retry' => true]];
    return pz_run_finish($u, $run, PZ_BEDS_SIZES[$n] ?? 8000, 'Every bed has its gnome in');
}

/** Today's fastest for a game: rows of [user_id, name, best]. */
function pz_daily_board(string $game, int $limit = 10): array
{
    if (!pzgames_ensure()) return [];
    return q("SELECT r.user_id, COALESCE(u.gnome_name, u.username) AS name, MIN(r.ms) AS best FROM puzzle_runs r JOIN users u ON u.id = r.user_id
              WHERE r.game = ? AND r.day = ? AND r.mode = 'daily' AND r.status = 'done' AND " . gnome_in_play_sql('u') . " GROUP BY r.user_id, u.gnome_name, u.username ORDER BY best LIMIT " . max(1, $limit), [$game, game_day()])->fetchAll();
}

/** Days in a row (ending today or yesterday) with a daily win for this game. */
function pz_streak(int $uid, string $game): int
{
    if (!pzgames_ensure()) return 0;
    $days = array_flip(array_map('strval', q('SELECT day FROM puzzle_wins WHERE user_id = ? AND game = ? ORDER BY day DESC LIMIT 400', [$uid, $game])->fetchAll(PDO::FETCH_COLUMN)));
    $d = new DateTimeImmutable(game_day());
    if (!isset($days[$d->format('Y-m-d')])) $d = $d->modify('-1 day');
    $n = 0;
    while (isset($days[$d->format('Y-m-d')])) { $n++; $d = $d->modify('-1 day'); }
    return $n;
}

function pz_done_today(int $uid, string $game): ?int
{
    if (!pzgames_ensure()) return null;
    $v = q_val('SELECT ms FROM puzzle_wins WHERE user_id = ? AND game = ? AND day = ?', [$uid, $game, game_day()]);
    return $v === false || $v === null ? null : (int)$v;
}
