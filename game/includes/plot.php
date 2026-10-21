<?php
declare(strict_types=1);
/**
 * Garden Plot Logic: one fresh 5 x 5 bed a day, the same for everyone (v2.0.31).
 * Each row and column holds one of each of today’s 5 plants. Companion clues ("Every Tomato touches a Basil") and
 * pest squares come from the companion_plants table (seeded from includes/data/companions.txt). The generator is
 * deterministic (HMAC of the day, local xorshift PRNG) and a solver proves every bed has exactly one solution.
 * The solution lives only in the day cache (setting plot_cache) and the player’s game_state row, never in the page.
 * State (game_state key plot): v, day, plants[5 slugs], given{cell:idx}, rules[[helper,crop]], pests{cell:kind}, pk{cell:[idx]},
 *   sol[25], grid[25 (-1 = empty)], hints[cells], hmax, wrong, t0, paid.
 */

const PLOT_N = 5;
const PLOT_CELLS = 25;
const PLOT_HINTS = 2;
const PLOT_CHECKS = 3;
const PLOT_BONUS_SECONDS = 180;
const PLOT_PEST_KINDS = ['aphids' => ['aphid', '🐜'], 'slugs' => ['slug', '🐌'], 'gnats' => ['gnat', '🦟'], 'caterpillars' => ['caterpillar', '🐛']];
/** Fixed seasonal crop pools (slugs that have a crop picture). */
const PLOT_POOLS = [
    'spring' => ['onion', 'garlic', 'coriander', 'dill', 'thyme', 'carrot', 'lettuce', 'spinach', 'beet', 'strawberry'],
    'summer' => ['basil', 'dill', 'thyme', 'coriander', 'tomato', 'bell-pepper', 'chili-pepper', 'cucumber', 'strawberry'],
    'autumn' => ['garlic', 'mint', 'rosemary', 'coriander', 'cabbage', 'broccoli', 'lettuce', 'spinach', 'carrot'],
    'winter' => ['garlic', 'onion', 'mint', 'rosemary', 'thyme', 'carrot', 'beet', 'cabbage'],
];

/** A small local PRNG (xorshift32). Never mt_srand: that is global. */
final class PlotRng
{
    private int $s;
    public function __construct(string $seed)
    {
        $this->s = hexdec(substr(hash('sha256', $seed), 0, 8)) ?: 0x9E3779B9;
    }
    public function next(): int
    {
        $x = $this->s;
        $x ^= ($x << 13) & 0xFFFFFFFF;
        $x ^= $x >> 17;
        $x ^= ($x << 5) & 0xFFFFFFFF;
        return $this->s = $x & 0xFFFFFFFF;
    }
    public function int(int $n): int
    {
        return $n <= 1 ? 0 : $this->next() % $n;
    }
    public function shuffle(array $a): array
    {
        $a = array_values($a);
        for ($i = count($a) - 1; $i > 0; $i--) {
            $j = $this->int($i + 1);
            [$a[$i], $a[$j]] = [$a[$j], $a[$i]];
        }
        return $a;
    }
}

/** Orthogonal neighbours of each cell (precomputed). */
function plot_nb(): array
{
    static $nb = null;
    if ($nb === null) {
        $nb = [];
        for ($i = 0; $i < PLOT_CELLS; $i++) {
            $x = $i % PLOT_N;
            $y = intdiv($i, PLOT_N);
            $l = [];
            if ($y > 0) $l[] = $i - PLOT_N;
            if ($x > 0) $l[] = $i - 1;
            if ($x < PLOT_N - 1) $l[] = $i + 1;
            if ($y < PLOT_N - 1) $l[] = $i + PLOT_N;
            $nb[$i] = $l;
        }
    }
    return $nb;
}

/**
 * Backtracking solver. $given = cell => plant index. $rules = list of [helperIdx, cropIdx] (every crop touches a helper).
 * $pestOk = cell => list of plant indexes allowed there. Returns up to $limit solutions (arrays of 25 ints).
 * With $rng the value order is shuffled (used to build a random square) and $nodeCap bounds the work (0 = none).
 */
function plot_solve(array $given, array $rules, array $pestOk, int $limit = 2, ?PlotRng $rng = null, int $nodeCap = 0): array
{
    $nb = plot_nb();
    $det = array_fill(0, PLOT_CELLS, []);   // cells whose companion check can be done once cell i is set
    foreach ($nb as $j => $l) $det[max($j, max($l))][] = $j;
    $allow = [];
    foreach ($pestOk as $c => $ok) { $m = 0; foreach ($ok as $v) $m |= 1 << $v; $allow[(int)$c] = $m; }
    $grid = array_fill(0, PLOT_CELLS, -1);
    $rowM = array_fill(0, PLOT_N, 0);
    $colM = array_fill(0, PLOT_N, 0);
    $out = [];
    $nodes = 0;
    $helpersOf = [];
    foreach ($rules as [$h, $c]) $helpersOf[$c][] = $h;
    $rec = function (int $i) use (&$rec, &$grid, &$rowM, &$colM, &$out, &$nodes, $given, $limit, $rng, $nodeCap, $det, $nb, $allow, $helpersOf): bool {
        if ($i === PLOT_CELLS) { $out[] = $grid; return count($out) >= $limit; }
        $r = intdiv($i, PLOT_N);
        $c = $i % PLOT_N;
        $vals = isset($given[$i]) ? [(int)$given[$i]] : [0, 1, 2, 3, 4];
        if ($rng && !isset($given[$i])) $vals = $rng->shuffle($vals);
        foreach ($vals as $v) {
            $bit = 1 << $v;
            if (($rowM[$r] & $bit) || ($colM[$c] & $bit)) continue;
            if (isset($allow[$i]) && !($allow[$i] & $bit)) continue;
            if ($nodeCap && ++$nodes > $nodeCap) return true;
            $grid[$i] = $v;
            $rowM[$r] |= $bit;
            $colM[$c] |= $bit;
            $good = true;
            if ($helpersOf) {
                foreach ($det[$i] as $j) {
                    $crop = $grid[$j];
                    if (!isset($helpersOf[$crop])) continue;
                    $has = false;
                    foreach ($nb[$j] as $k) if (in_array($grid[$k], $helpersOf[$crop], true)) { $has = true; break; }
                    if (!$has) { $good = false; break; }
                }
            }
            if ($good && $rec($i + 1)) return true;
            $grid[$i] = -1;
            $rowM[$r] &= ~$bit;
            $colM[$c] &= ~$bit;
        }
        return false;
    };
    $rec(0);
    return $out;
}

/** Does a full grid satisfy the Latin rule, the companion rules and the pest squares? (Belt and braces for a check.) */
function plot_valid(array $grid, array $rules, array $pestOk): bool
{
    if (count($grid) !== PLOT_CELLS) return false;
    for ($a = 0; $a < PLOT_N; $a++) {
        $rs = [];
        $cs = [];
        for ($b = 0; $b < PLOT_N; $b++) {
            $rs[] = $grid[$a * PLOT_N + $b];
            $cs[] = $grid[$b * PLOT_N + $a];
        }
        sort($rs); sort($cs);
        if ($rs !== [0, 1, 2, 3, 4] || $cs !== [0, 1, 2, 3, 4]) return false;
    }
    $nb = plot_nb();
    foreach ($rules as [$h, $c]) {
        foreach ($grid as $i => $v) {
            if ($v !== $c) continue;
            $has = false;
            foreach ($nb[$i] as $k) if ($grid[$k] === $h) { $has = true; break; }
            if (!$has) return false;
        }
    }
    foreach ($pestOk as $cell => $ok) if (!in_array($grid[(int)$cell], $ok, true)) return false;
    return true;
}

/** The pest kinds a plant keeps off, limited to the four the game shows. */
function plot_keeps(array $comp, string $slug): array
{
    return array_values(array_intersect($comp[$slug]['pests'] ?? [], array_keys(PLOT_PEST_KINDS)));
}

/**
 * One bed from a seed. $comp = companion_defs() shape (slug => ['pests' => [...], 'helps' => [...]]).
 * Returns ['plants' => [5 slugs], 'given' => cell => idx, 'rules' => [[helper, crop]] (slugs), 'pests' => cell => kind, 'sol' => [25]].
 * Pure (no database), so tests can run it for many seeds.
 */
function plot_generate(string $seed, string $season, array $comp): array
{
    $pool = PLOT_POOLS[$season] ?? PLOT_POOLS['spring'];
    $best = null;
    for ($attempt = 0; $attempt < 14; $attempt++) {
        $rng = new PlotRng($seed . '|' . $attempt);
        // 1. today's 5 plants: one helper -> crop pair and one helper with a pest, when the pool allows
        $pairs = [];
        foreach ($pool as $h) foreach ($comp[$h]['helps'] ?? [] as $c) if ($c !== $h && in_array($c, $pool, true)) $pairs[] = [$h, $c];
        $pick = [];
        if ($pairs) { $p = $pairs[$rng->int(count($pairs))]; $pick = [$p[0], $p[1]]; }
        $hasPest = fn(array $set) => (bool)array_filter($set, fn($s) => plot_keeps($comp, $s));
        if (!$hasPest($pick)) {
            $withPest = array_values(array_diff(array_filter($pool, fn($s) => plot_keeps($comp, $s)), $pick));
            if ($withPest) $pick[] = $withPest[$rng->int(count($withPest))];
        }
        $rest = $rng->shuffle(array_values(array_diff($pool, $pick)));
        $plants = $rng->shuffle(array_slice(array_merge($pick, $rest), 0, 5));
        $idx = array_flip($plants);
        // 2. companion rules that can apply to these five
        $cand = [];
        foreach ($plants as $h) foreach ($comp[$h]['helps'] ?? [] as $c) if ($c !== $h && isset($idx[$c])) $cand[] = [$idx[$h], $idx[$c]];
        $cand = $rng->shuffle($cand);
        $rules = [];
        $sol = null;
        if ($cand) {
            $want = min(count($cand), 1 + $rng->int(2));
            for ($k = $want; $k >= 1 && !$sol; $k--) {
                for ($start = 0; $start < min(count($cand), 3) && !$sol; $start++) {
                    $try = array_slice(array_merge(array_slice($cand, $start), array_slice($cand, 0, $start)), 0, $k);
                    $found = plot_solve([], $try, [], 1, $rng, 6000);
                    if ($found && plot_valid($found[0], $try, [])) { $sol = $found[0]; $rules = $try; }
                }
            }
        }
        if (!$sol) { $found = plot_solve([], [], [], 1, $rng); $sol = $found[0]; $rules = []; }
        // 3. one or two pest squares: a plant that keeps that pest off sits there
        $pests = [];
        $pestOk = [];
        $cells = $rng->shuffle(range(0, PLOT_CELLS - 1));
        $wantPests = 1 + $rng->int(2);
        foreach ($cells as $cell) {
            if (count($pests) >= $wantPests) break;
            $keeps = plot_keeps($comp, $plants[$sol[$cell]]);
            if (!$keeps) continue;
            $kinds = [];
            foreach ($keeps as $kind) {
                $n = count(array_filter($plants, fn($s) => in_array($kind, plot_keeps($comp, $s), true)));
                if ($n <= 3) $kinds[] = $kind;
            }
            $kinds = $kinds ?: $keeps;
            $kind = $kinds[$rng->int(count($kinds))];
            $pests[$cell] = $kind;
            $pestOk[$cell] = array_keys(array_filter($plants, fn($s) => in_array($kind, plot_keeps($comp, $s), true)));
        }
        // 4. givens: add until unique, then drop what is not needed (kept between 6 and 10)
        $order = $rng->shuffle(range(0, PLOT_CELLS - 1));
        $given = [];
        foreach ($order as $cell) {
            if (count(plot_solve($given, $rules, $pestOk, 2)) === 1) break;
            $given[$cell] = $sol[$cell];
        }
        foreach ($rng->shuffle(array_keys($given)) as $cell) {
            $v = $given[$cell];
            unset($given[$cell]);
            if (count(plot_solve($given, $rules, $pestOk, 2)) !== 1) $given[$cell] = $v;
        }
        foreach ($order as $cell) {   // too few clues: put a few back so the bed is not a gift
            if (count($given) >= 6) break;
            $given[$cell] ??= $sol[$cell];
        }
        ksort($given);
        ksort($pests);
        $bed = ['plants' => $plants, 'given' => $given, 'rules' => array_map(fn($r) => [$plants[$r[0]], $plants[$r[1]]], $rules), 'pests' => $pests, 'sol' => $sol];
        $good = count($given) <= 10 && $pests;
        if ($best === null || ($good && !($best['_good'] ?? false))) { $best = $bed; $best['_good'] = $good; }
        if ($good) break;
    }
    unset($best['_good']);
    return $best;
}

/** Today’s bed, cached in the hidden setting plot_cache (generation is deterministic, so a write race is harmless). */
function plot_today(): array
{
    $day = game_day();
    $c = json_decode(setting('plot_cache'), true);
    if (is_array($c) && ($c['day'] ?? '') === $day && isset($c['sol'])) return $c;
    ensure_race_secret();
    $seed = hash_hmac('sha256', 'plot|' . $day, setting('race_secret'));
    $season = hollow_season();
    $bed = plot_generate($seed, $season, companion_defs());
    $bed = ['day' => $day, 'season' => $season] + $bed;
    set_setting('plot_cache', json_encode($bed));
    setting('__reload__');
    return $bed;
}

/** Plant slug => display name. */
function plot_names(array $slugs): array
{
    $out = [];
    foreach ($slugs as $s) $out[$s] = ucwords(str_replace('-', ' ', $s));
    if ($slugs) {
        $ph = implode(',', array_fill(0, count($slugs), '?'));
        foreach (q("SELECT slug, name FROM plants WHERE slug IN ($ph)", array_values($slugs))->fetchAll() as $r) $out[$r['slug']] = (string)$r['name'];
    }
    return $out;
}

/** Short labels that tell today’s plants apart in a square ("Let", "Thy", "Bel"), because many herb pictures share one leaf drawing. slug => tag. */
function plot_tags(array $names): array
{
    $out = [];
    foreach ($names as $slug => $n) {
        for ($len = 3; $len < 6; $len++) {
            $p = mb_strtolower(mb_substr($n, 0, $len));
            $clash = false;
            foreach ($names as $o => $m) if ($o !== $slug && mb_strtolower(mb_substr($m, 0, $len)) === $p) $clash = true;
            if (!$clash) break;
        }
        $out[$slug] = rtrim(mb_substr($n, 0, $len));
    }
    return $out;
}

/** A yesterday’s bed in progress is dropped with no score and no payout, so it never blocks today’s play. */
function plot_stale(int $uid): void
{
    $s = game_state($uid, 'plot');
    if ($s && ($s['day'] ?? '') !== game_day()) game_clear($uid, 'plot');
}

function plot_scored_today(int $uid): bool
{
    return (bool)q_val("SELECT 1 FROM game_scores WHERE user_id = ? AND game = 'plot' AND day = ? AND score > 0 LIMIT 1", [$uid, game_day()]);
}

/** Any finished bed today (solved, practice or out of checks). Only the first bed of the day may pay: a replay of a bed whose answer was shown, or of a solved one, never does. */
function plot_played_today(int $uid): bool
{
    return (bool)q_val("SELECT 1 FROM game_scores WHERE user_id = ? AND game = 'plot' AND day = ? LIMIT 1", [$uid, game_day()]);
}

/** "a Basil" / "an Onion". */
function plot_a(string $word): string
{
    return (preg_match('/^[aeiou]/i', $word) ? 'an ' : 'a ') . $word;
}

/** "Garlic", "Garlic or Dill", "Garlic, Dill or Mint". */
function plot_or(array $words): string
{
    $last = array_pop($words);
    return $words ? implode(', ', $words) . ' or ' . $last : (string)$last;
}

/** v2.0.31: puts the Almanac line (from GAMES_PAGE) into an existing Games page; new installs get it from GAMES_PAGE itself. */
function plot_almanac(): void
{
    if (!preg_match('/^🪴 \[b\]Garden Plot Logic:.*$/mu', GAMES_PAGE, $m)) return;
    $row = q_one("SELECT id, body FROM encyclopedia_entries WHERE title = 'Games' AND chapter = 'General' AND body LIKE 'When the garden is growing on its own%' AND body NOT LIKE '%Garden Plot Logic%'");
    if (!$row) return;
    $body = (string)$row['body'];
    $at = strpos($body, "\n⚖️ [b]Guess the Weight");
    if ($at === false) $at = strpos($body, "\n\nThe [b]🏆 Contests");
    $body = $at === false ? rtrim($body) . "\n" . $m[0] : substr($body, 0, $at) . "\n" . $m[0] . substr($body, $at);
    q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [$body, (int)$row['id']]);
}

function plot_score(int $hints, int $wrong, int $elapsed): int
{
    $bonus = $elapsed <= PLOT_BONUS_SECONDS ? 20 : max(0, 20 - (int)ceil(($elapsed - PLOT_BONUS_SECONDS) / 15));
    return max(30, 100 - 10 * $hints - 10 * $wrong + $bonus);
}

function plot_start(array $u): array
{
    $uid = (int)$u['id'];
    plot_stale($uid);
    $bed = plot_today();
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if (game_state($uid, 'plot')) { db()->commit(); return [true, 'Your bed is still waiting for you.']; }
    if (game_plays_left($uid, 'plot') <= 0) { db()->commit(); return [false, 'Old Moss has no more seedlings today. A fresh bed sprouts after the daily reset.']; }
    $grid = array_fill(0, PLOT_CELLS, -1);
    foreach ($bed['given'] as $c => $v) $grid[(int)$c] = (int)$v;
    $pk = [];
    foreach ($bed['pests'] as $c => $kind) {
        $pk[(int)$c] = array_keys(array_filter($bed['plants'], fn($s) => in_array($kind, plot_keeps(companion_defs(), $s), true)));
    }
    game_save($uid, 'plot', [
        'v' => 1, 'day' => $bed['day'], 'plants' => $bed['plants'], 'given' => $bed['given'], 'rules' => $bed['rules'], 'pests' => $bed['pests'],
        'pk' => $pk, 'sol' => $bed['sol'], 'grid' => $grid, 'hints' => [], 'hmax' => PLOT_HINTS + (eff_mod($u, 'lore') >= 2 ? 1 : 0),
        'wrong' => 0, 't0' => time(), 'paid' => !plot_played_today($uid),   // only the day's first bed can pay
    ]);
    db()->commit();
    return [true, '🪴 Old Moss hands you a tray of seedlings. “Mind the companions, now.”'];
}

/** Read the posted grid: g[0..24] each blank/-1 or 0-4. Too many entries are refused; bad values become empty. Locked squares are forced back. */
function plot_read_grid(array $s, $posted): ?array
{
    if (!is_array($posted) || count($posted) > PLOT_CELLS) return null;
    $grid = array_fill(0, PLOT_CELLS, -1);
    foreach ($posted as $k => $v) {
        if (!is_int($k) && !(is_string($k) && ctype_digit($k))) return null;
        $k = (int)$k;
        if ($k < 0 || $k >= PLOT_CELLS) return null;
        $v = is_string($v) ? trim($v) : $v;
        if (is_string($v) && preg_match('/^[0-4]$/', $v)) $grid[$k] = (int)$v;
    }
    foreach ($s['given'] as $c => $v) $grid[(int)$c] = (int)$v;
    foreach ($s['hints'] as $c) $grid[(int)$c] = (int)$s['sol'][(int)$c];
    return $grid;
}

/** Runs $fn($u, $state) inside a transaction with the users-row lock and the state re-read. $fn returns [ok, msg]. */
function plot_move(array $u, $posted, callable $fn, bool $needGrid = true): array
{
    $uid = (int)$u['id'];
    plot_stale($uid);
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    $s = game_state($uid, 'plot');
    if (!$s) { db()->commit(); return [false, 'Plant today’s bed first.']; }
    if ($needGrid) {
        $grid = plot_read_grid($s, $posted);
        if ($grid === null) { db()->commit(); return [false, 'Old Moss can’t read that bed. Try again.']; }
        $s['grid'] = $grid;
    }
    try {
        $r = $fn($u, $s);
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();
        throw $e;
    }
    if (db()->inTransaction()) db()->commit();
    return $r;
}

function plot_save(array $u, $posted): array
{
    return plot_move($u, $posted, function (array $u, array $s): array {
        game_save((int)$u['id'], 'plot', $s);
        return [true, '💾 Bed saved. Old Moss will keep an eye on it.'];
    });
}

function plot_hint(array $u, $posted): array
{
    return plot_move($u, $posted, function (array $u, array $s): array {
        $uid = (int)$u['id'];
        if (count($s['hints']) >= (int)$s['hmax']) { game_save($uid, 'plot', $s); return [false, 'Old Moss has given all his hints today.']; }
        // A full bed gets no hint, so asking can never tell you for free that the whole bed is right.
        if (!in_array(-1, $s['grid'], true)) { game_save($uid, 'plot', $s); return [false, 'Your bed is full. Clear a square you’re unsure of, then ask Old Moss.']; }
        $locked = array_map('intval', array_merge(array_keys($s['given']), $s['hints']));
        $wrong = [];
        for ($i = 0; $i < PLOT_CELLS; $i++) {
            if (in_array($i, $locked, true)) continue;
            if ($s['grid'][$i] !== (int)$s['sol'][$i]) $wrong[] = $i;
        }
        $cell = $wrong[random_int(0, count($wrong) - 1)];
        $s['hints'][] = $cell;
        $s['grid'][$cell] = (int)$s['sol'][$cell];
        game_save($uid, 'plot', $s);
        $name = plot_names([$s['plants'][$s['sol'][$cell]]])[$s['plants'][$s['sol'][$cell]]];
        return [true, '🧑‍🌾 Old Moss plants ' . plot_a($name) . ' for you and taps the soil down.'];
    });
}

function plot_check(array $u, $posted): array
{
    return plot_move($u, $posted, function (array $u, array $s): array {
        $uid = (int)$u['id'];
        if (in_array(-1, $s['grid'], true)) { game_save($uid, 'plot', $s); return [false, 'Fill every square before you check.']; }
        if (time() - (int)$s['t0'] < (int)setting('plot_min_seconds')) {
            game_save($uid, 'plot', $s);   // not counted as a check
            return [false, 'Old Moss squints: give the bed a proper look first.'];
        }
        $pestOk = [];
        foreach ($s['pk'] as $c => $ok) $pestOk[(int)$c] = array_map('intval', $ok);
        $idx = array_flip($s['plants']);
        $rules = array_map(fn($r) => [$idx[$r[0]], $idx[$r[1]]], $s['rules']);
        $sol = array_map('intval', $s['sol']);
        if ($s['grid'] === $sol && plot_valid($s['grid'], $rules, $pestOk)) return plot_finish($u, $s, true);
        $s['wrong'] = (int)$s['wrong'] + 1;
        if ($s['wrong'] >= PLOT_CHECKS) return plot_finish($u, $s, false);
        game_save($uid, 'plot', $s);
        $left = PLOT_CHECKS - $s['wrong'];
        return [false, 'Not quite: Old Moss shakes his head. (' . $left . ' check' . ($left === 1 ? '' : 's') . ' left)'];
    });
}

/** Ends the bed. The DELETE of the state row is the claim; only the first scored solve of the day pays. Runs inside plot_move’s transaction. */
function plot_finish(array $u, array $s, bool $solved): array
{
    $uid = (int)$u['id'];
    if (q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'plot'])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That bed is already over.'];
    }
    $elapsed = max(0, time() - (int)$s['t0']);
    $hints = count($s['hints']);
    $wrong = (int)$s['wrong'];
    $score = $solved ? plot_score($hints, $wrong, $elapsed) : 0;
    $first = !empty($s['paid']) && !plot_played_today($uid);   // re-checked under the user-row lock, before this bed's own score row
    $pay = $solved && $first;
    $was = $solved && !$pay && plot_scored_today($uid);
    game_score($uid, 'plot', $pay ? $score : 0);
    $petals = $pay ? game_petals($score) : 0;
    $xp = ($pay && (string)setting('games_give_xp') === '1') ? ($hints ? 5 : 10) : 0;
    if ($petals) give_petals($uid, $petals);
    if ($xp) add_xp($uid, $xp);
    db()->commit();
    $good = $solved && $hints === 0 && $wrong === 0;
    $en = $first ? game_energy($uid, $good) : '';   // practice beds give no energy either
    if ($solved) {
        $mins = sprintf('%d:%02d', intdiv($elapsed, 60), $elapsed % 60);
        prize('🏆', '🏆 A happy bed!', 'Solved in ' . $mins, [
            $petals ? '+' . money($petals) : '',
            $pay ? '' : ($was ? 'Practice bed: today’s Petals are already yours.' : 'Practice bed: only the first bed of the day pays.'),
            $en !== '' ? ($good ? 'No hints, no slips: ' : '') . trim($en) . ' energy' : '',
            $xp ? '+' . $xp . ' XP' : '',
        ]);
    } else {
        $_SESSION['plot_last'] = ['day' => $s['day'], 'plants' => $s['plants'], 'sol' => $s['sol'], 'given' => $s['given'], 'pests' => $s['pests']];
        prize('🌧️', '🌧️ The bed will keep for another day', 'Out of checks', [$en !== '' ? trim($en) . ' energy' : '']);
    }
    return [true, ''];
}
