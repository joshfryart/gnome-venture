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
];
const PZ_HINT_MS = 20000;
const PZ_MAX_HINTS = 3;
const PZ_DAILY_STARTS = 20;
const PZ_PRACTICE_STARTS = 60;
const PZ_BARREL_SIZES = [6 => 6000, 8 => 11000, 5 => 4000];   // size => fastest believable solve (ms)

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

// ---------------- runs ----------------

function pzr_row(array $u, string $token): ?array
{
    if (!preg_match('/^[a-f0-9]{32}$/', $token)) return null;
    return q_one('SELECT * FROM puzzle_runs WHERE token = ? AND user_id = ?', [$token, (int)$u['id']]) ?: null;
}

/** Start a run. Returns [ok, message, data]. mode: daily | practice. */
function pz_barrel_start(array $u, string $mode, int $size): array
{
    if (!pzgames_ensure()) return [false, 'Puzzles aren’t ready yet.', []];
    $uid = (int)$u['id'];
    $day = game_day();
    if (random_int(1, 50) === 1) q('DELETE FROM puzzle_runs WHERE started_at < ?', [gmdate('Y-m-d H:i:s', time() - 14 * 86400)]);   // old runs (the daily wins and streaks live in puzzle_wins)
    if ($mode !== 'practice') { $mode = 'daily'; $size = 6; }
    if (!isset(PZ_BARREL_SIZES[$size])) $size = 6;
    $since = q_val("SELECT COUNT(*) FROM puzzle_runs WHERE user_id = ? AND game = 'barrel' AND day = ? AND mode = ?", [$uid, $day, $mode]);
    if ((int)$since >= ($mode === 'daily' ? PZ_DAILY_STARTS : PZ_PRACTICE_STARTS)) return [false, 'That’s enough for today. Come back tomorrow!', []];
    q("UPDATE puzzle_runs SET status = 'void' WHERE user_id = ? AND game = 'barrel' AND status = 'open'", [$uid]);
    $seed = $mode === 'daily' ? pz_daily_seed('barrel', $day, $size) : random_int(1, 2147483646);
    $token = bin2hex(random_bytes(16));
    db_insert('puzzle_runs', ['token' => $token, 'user_id' => $uid, 'game' => 'barrel', 'day' => $day, 'mode' => $mode, 'size' => $size, 'seed' => $seed,
        'start_ms' => (int)floor(microtime(true) * 1000), 'started_at' => now(), 'status' => 'open']);
    $p = rb_make($seed, $size);
    return [true, $token, ['n' => $size, 'tiles' => $p['scr'], 'src' => $p['src'], 'mode' => $mode]];
}

/** A hint: the first tile (by position) that is wrong against the dealt answer, with its turns. +20 s each, 3 at most. [ok, message, data] */
function pz_barrel_hint(array $u, string $token, array $r): array
{
    $run = pzr_row($u, $token);
    if (!$run || $run['status'] !== 'open' || $run['game'] !== 'barrel') return [false, 'That run isn’t open.', []];
    if ((int)$run['hints'] >= PZ_MAX_HINTS) return [false, 'The Old Wizard has no more hints for this one.', []];
    $p = rb_make((int)$run['seed'], (int)$run['size']);
    $cur = rb_apply($p['scr'], $r);
    if ($cur === null) return [false, 'Something went wrong. Refresh and try again.', []];
    foreach ($p['sol'] as $i => $want) {
        if ($cur[$i] === $want) continue;
        for ($t = 0; $t < 4; $t++) if (rb_rot($p['scr'][$i], $t) === $want) break;
        if (q("UPDATE puzzle_runs SET hints = hints + 1 WHERE id = ? AND status = 'open' AND hints < " . PZ_MAX_HINTS, [(int)$run['id']])->rowCount() !== 1) return [false, 'No more hints.', []];
        return [true, 'Try this one.', ['cell' => $i, 'r' => $t, 'hints' => (int)$run['hints'] + 1]];
    }
    return [false, 'Nothing is wrong that I can see.', []];
}

/** Hand in a run. [ok, message, data]. The time is the server's; each hint adds 20 s. The daily reward is paid once per day. */
function pz_barrel_finish(array $u, string $token, array $r): array
{
    $run = pzr_row($u, $token);
    if (!$run || $run['game'] !== 'barrel') return [false, 'That run wasn’t found.', []];
    if ($run['status'] !== 'open') return [false, 'That run was already handed in.', []];
    $n = (int)$run['size'];
    $p = rb_make((int)$run['seed'], $n);
    $fin = rb_apply($p['scr'], $r);
    if ($fin === null || !rb_valid($fin, $n)) return [false, 'Still leaking. Keep turning!', ['retry' => true]];
    $real = (int)floor(microtime(true) * 1000) - (int)$run['start_ms'];
    if ($real < (PZ_BARREL_SIZES[$n] ?? 6000)) {
        q("UPDATE puzzle_runs SET status = 'reject', ms = ? WHERE id = ? AND status = 'open'", [$real, (int)$run['id']]);
        return [false, 'That was faster than a gnome can turn gutters. It didn’t count.', ['rejected' => true]];
    }
    $ms = $real + (int)$run['hints'] * PZ_HINT_MS;
    if (q("UPDATE puzzle_runs SET status = 'done', ms = ? WHERE id = ? AND status = 'open'", [$ms, (int)$run['id']])->rowCount() !== 1) return [false, 'That run was already handed in.', []];
    $uid = (int)$u['id'];
    $extra = ['ms' => $ms, 'text' => puzzle_ms_text($ms)];
    $msg = 'Every sprout is watered in ' . puzzle_ms_text($ms) . '!';
    if ($run['mode'] === 'daily') {
        $best = (int)q_val("SELECT MIN(ms) FROM puzzle_runs WHERE user_id = ? AND game = 'barrel' AND day = ? AND mode = 'daily' AND status = 'done'", [$uid, $run['day']]);
        $extra['best'] = $best;
        $first = false;
        try { db_insert('puzzle_wins', ['game' => 'barrel', 'day' => $run['day'], 'user_id' => $uid, 'ms' => $ms, 'created_at' => now()]); $first = true; } catch (Throwable $e) {}
        if ($first) {
            $pet = game_petals((int)setting('pz_daily_petals'));
            if ($pet > 0) give_petals($uid, $pet, 'puzzle barrel daily');
            $en = game_energy($uid, true);
            $msg .= ' Daily reward: ' . ($pet > 0 ? money($pet) : 'a pat on the back') . $en . '.';
            $extra['reward'] = $pet;
        } else {
            $msg .= $ms <= $best ? ' A new best for today!' : ' Your best today is ' . puzzle_ms_text($best) . '.';
        }
        $extra['rank'] = 1 + (int)q_val("SELECT COUNT(*) FROM (SELECT user_id, MIN(ms) AS b FROM puzzle_runs WHERE game = 'barrel' AND day = ? AND mode = 'daily' AND status = 'done' GROUP BY user_id) x WHERE x.b < ?", [$run['day'], $best]);
    } else {
        $msg .= ' Practice pays nothing but it’s good for you.';
    }
    return [true, $msg, $extra];
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
