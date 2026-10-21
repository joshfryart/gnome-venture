<?php
declare(strict_types=1);
/**
 * Burrow Sorting (v2.1): five doors, five sleepy neighbours. A few clues leave 3 to 8 possible orders; the player
 * places everyone and knocks, and hears only HOW MANY are at home. Server-authoritative: the solution lives in
 * game_state ('sol') and is never printed. State: v, cast (5 creature keys), sol[door] = cast index, clues (structured,
 * rendered to text on the page), knocks (left), max, hist [[arrangement, hits]...], last, season, t0.
 */

const BURROW_DOORS = 5;
/** Door looks, left to right: [adjective for "the __ door", noun for "by the __", short label, placeholder picture, fallback emoji] */
const BURROW_FEATURES = [
    ['mossy', 'mossy step', 'Mossy step', 'burrow-door-moss', '🚪'],
    ['acorn-knocker', 'acorn knocker', 'Acorn knocker', 'burrow-door-acorn', '🚪'],
    ['round blue', 'round blue door', 'Round blue door', 'burrow-door-round', '🚪'],
    ['lantern', 'lantern', 'Lantern', 'burrow-door-lantern', '🚪'],
    ['flowerpot', 'flowerpot', 'Flowerpot', 'burrow-door-pot', '🚪'],
];
/** key => [name, emoji ('' = own icon only), ico slug (for the mole) */
const BURROW_CREATURES = [
    'hedgehog' => ['Hedgehog', '🦔', ''], 'rabbit' => ['Rabbit', '🐇', ''], 'frog' => ['Frog', '🐸', ''], 'mole' => ['Mole', '', 'ico-mole'],
    'fieldmouse' => ['Field mouse', '🐭', ''], 'badger' => ['Badger', '🦡', ''], 'squirrel' => ['Squirrel', '🐿', ''],
    'lizard' => ['Lizard', '🦎', ''], 'bumblebee' => ['Bumblebee', '🐝', ''], 'owl' => ['Owl', '🦉', ''], 'dormouse' => ['Dormouse', '🐭', ''],
];
const BURROW_CASTS = [
    'spring' => ['hedgehog', 'rabbit', 'frog', 'mole', 'fieldmouse', 'badger', 'squirrel'],
    'summer' => ['rabbit', 'frog', 'hedgehog', 'mole', 'fieldmouse', 'lizard', 'bumblebee'],
    'autumn' => ['squirrel', 'hedgehog', 'badger', 'mole', 'fieldmouse', 'owl', 'rabbit'],
    'winter' => ['dormouse', 'hedgehog', 'badger', 'mole', 'owl', 'rabbit', 'squirrel'],
];
const BURROW_BASE_KNOCKS = 4;
const BURROW_FAIL_RAW = 5;

/** Every order of the five neighbours: each entry maps cast index => door position 1-5. */
function burrow_orders(): array
{
    static $all = null;
    if ($all !== null) return $all;
    $all = [];
    $rec = function (array $left, array $cur) use (&$rec, &$all): void {
        if (!$left) { $all[] = $cur; return; }
        foreach ($left as $i => $v) {
            $rest = $left;
            unset($rest[$i]);
            $rec($rest, array_merge($cur, [$v]));
        }
    };
    $rec([1, 2, 3, 4, 5], []);
    return $all;
}

/** Is clue $c true when neighbour k sits at door position $p[k] (1-5)? */
function burrow_clue_ok(array $c, array $p): bool
{
    $id = $c[0];
    $x = isset($c[1]) ? $p[$c[1]] : 0;
    switch ($id) {
        case 'T1': case 'T2': case 'T15':
            return $id === 'T1' ? $x === $c[2] : $x !== $c[2];
        case 'T3': return $x === 1 || $x === 5;
        case 'T4': case 'T15e': return $x >= 2 && $x <= 4;
        case 'T5': return $x < $p[$c[2]];
        case 'T6': return abs($x - $p[$c[2]]) === 1;
        case 'T7': return abs($x - $p[$c[2]]) !== 1;
        case 'T8': return $x === $p[$c[2]] - 1;
        case 'T9': $y = $p[$c[2]]; $z = $p[$c[3]]; return ($y < $x && $x < $z) || ($z < $x && $x < $y);
        case 'T10': return $x === 3;
        case 'T11': $y = $p[$c[2]]; return (($x === 1 || $x === 5) xor ($y === 1 || $y === 5));
        case 'T12': return $x > $p[$c[2]] && $x > $p[$c[3]];
        case 'T13': return abs($x - $p[$c[2]]) === 3;
        case 'T14': return $x - 1 < 5 - $p[$c[2]];
    }
    return false;
}

/** All clue instances that are true for the position map $p, as structured clues. $cast = the five keys, $season for T15. */
function burrow_true_clues(array $p, array $cast, string $season): array
{
    $out = [];
    $n = BURROW_DOORS;
    for ($x = 0; $x < $n; $x++) {
        for ($d = 1; $d <= $n; $d++) {
            $out[] = ['T1', $x, $d];
            $out[] = ['T2', $x, $d];
            if ($season !== 'winter' && $season !== 'summer') $out[] = ['T15', $x, $d];
        }
        $out[] = ['T3', $x]; $out[] = ['T4', $x]; $out[] = ['T10', $x];
        if ($season === 'winter' && in_array($cast[$x], ['dormouse', 'hedgehog'], true)) $out[] = ['T15e', $x];
        if ($season === 'summer' && $cast[$x] === 'bumblebee') $out[] = ['T15', $x, 4];
        for ($y = 0; $y < $n; $y++) {
            if ($y === $x) continue;
            foreach (['T5', 'T6', 'T7', 'T8', 'T11', 'T13', 'T14'] as $t) $out[] = [$t, $x, $y];
            for ($z = $y + 1; $z < $n; $z++) {
                if ($z === $x) continue;
                $out[] = ['T9', $x, $y, $z];
                $out[] = ['T12', $x, $y, $z];
            }
        }
    }
    return array_values(array_filter($out, fn($c) => burrow_clue_ok($c, $p)));
}

/** How many of the 120 orders fit all these clues. */
function burrow_fit_count(array $clues): int
{
    $n = 0;
    foreach (burrow_orders() as $o) {
        foreach ($clues as $c) if (!burrow_clue_ok($c, $o)) continue 2;
        $n++;
    }
    return $n;
}

/**
 * A fresh puzzle: ['cast' => [5 keys], 'sol' => [door => cast index], 'clues' => [...], 'fit' => 3..8].
 * $rnd(min, max) defaults to random_int (tests pass a seeded one).
 */
function burrow_new_puzzle(string $season, ?callable $rnd = null): array
{
    $rnd = $rnd ?? 'random_int';
    if (!isset(BURROW_CASTS[$season])) $season = 'spring';
    $shuffle = function (array $a) use ($rnd): array {
        for ($i = count($a) - 1; $i > 0; $i--) {
            $j = $rnd(0, $i);
            [$a[$i], $a[$j]] = [$a[$j], $a[$i]];
        }
        return $a;
    };
    $best = null;
    for ($try = 0; $try < 60; $try++) {
        $cast = array_slice($shuffle(BURROW_CASTS[$season]), 0, 5);
        $doorOf = $shuffle([1, 2, 3, 4, 5]);   // cast index => door position
        $p = $doorOf;
        $pool = $shuffle(burrow_true_clues($p, $cast, $season));
        $fit = array_values(burrow_orders());
        $chosen = [];
        $used = [];
        $posClues = 0;
        foreach ($pool as $c) {
            if (count($chosen) >= 6) break;
            $isPos = $c[0] === 'T1' || $c[0] === 'T10';
            if ($isPos && $posClues >= 1) continue;
            if (($used[$c[0]] ?? 0) >= 2) continue;
            $next = array_values(array_filter($fit, fn($o) => burrow_clue_ok($c, $o)));
            if (count($next) >= count($fit) || count($next) < 3) continue;
            $fit = $next;
            $chosen[] = $c;
            $used[$c[0]] = ($used[$c[0]] ?? 0) + 1;
            if ($isPos) $posClues++;
            if (count($fit) <= 8 && count($chosen) >= 3) break;
        }
        if (count($fit) >= 3 && count($fit) <= 8 && count($chosen) >= 3 && count($chosen) <= 6) {
            $sol = [];
            foreach ($doorOf as $k => $d) $sol[$d - 1] = $k;
            ksort($sol);
            return ['cast' => $cast, 'sol' => array_values($sol), 'clues' => $chosen, 'fit' => count($fit), 'season' => $season];
        }
    }
    throw new RuntimeException('Burrow puzzle generator failed');
}

/** Creature as inline HTML: icon then the name in bold. Emoji are swapped for our icons at render; the mole has its own icon file. */
function burrow_who(string $key, bool $withName = true): string
{
    [$name, $emoji, $slug] = BURROW_CREATURES[$key];
    $icon = $emoji !== '' ? e($emoji) : ico_img(['slug' => $slug, 'dec' => true, 'name' => '']);
    return '<span class="bwho">' . $icon . ($withName ? ' <b>' . e($name) . '</b>' : '') . '</span>';
}

/** A door's picture (placeholder art if drawn, else the door emoji). */
function burrow_door_pic(int $i, int $px): string
{
    [, , , $ph, $emoji] = BURROW_FEATURES[$i];
    return '<span class="bpic" aria-hidden="true">' . ph_or_emoji($ph, $emoji, $px) . '</span>';
}

/** One clue as safe HTML. */
function burrow_clue_html(array $c, array $cast, string $season): string
{
    $w = fn(int $i) => burrow_who($cast[$i]);
    $f = BURROW_FEATURES;
    $id = $c[0];
    $X = isset($c[1]) ? $w($c[1]) : '';
    $Y = isset($c[2]) && $id !== 'T1' && $id !== 'T2' && $id !== 'T15' ? $w($c[2]) : '';
    $Z = isset($c[3]) ? $w($c[3]) : '';
    switch ($id) {
        case 'T1': return $X . ' lives behind the ' . e($f[$c[2] - 1][0]) . ' door.';
        case 'T2': return $X . ' doesn’t live behind the ' . e($f[$c[2] - 1][0]) . ' door.';
        case 'T3': return $X . ' lives at one end of the row.';
        case 'T4': return $X . ' doesn’t live at either end.';
        case 'T5': return $X . ' lives somewhere left of ' . $Y . '.';
        case 'T6': return $X . ' and ' . $Y . ' are next-door neighbours.';
        case 'T7': return $X . ' and ' . $Y . ' are not next-door neighbours.';
        case 'T8': return $X . ' lives right next door, on ' . $Y . '’s left.';
        case 'T9': return $X . ' lives somewhere between ' . $Y . ' and ' . $Z . '.';
        case 'T10': return $X . ' has the middle door.';
        case 'T11': return 'Exactly one of ' . $X . ' and ' . $Y . ' lives at an end.';
        case 'T12': return $X . ' lives further right than both ' . $Y . ' and ' . $Z . '.';
        case 'T13': return 'Two doors sit between ' . $X . ' and ' . $Y . '.';
        case 'T14': return $X . ' lives closer to the left end than ' . $Y . ' does to the right end.';
        case 'T15e': return $X . ' is hibernating away from the draughty end doors.';
        case 'T15':
            if ($season === 'summer' && $c[2] === 4) return $X . ' won’t live by the lantern: too hot.';
            return $X . ' never lives by the ' . e($f[$c[2] - 1][1]) . '.';
    }
    return '';
}

/** Charm gives one more knock at mod 2+. */
function burrow_max_knocks(array $u): int
{
    return BURROW_BASE_KNOCKS + (eff_mod($u, 'charm') >= 2 ? 1 : 0);
}

function burrow_score(int $knocksLeft): int
{
    return 40 + 15 * max(0, $knocksLeft);
}

function burrow_start(array $u): array
{
    $uid = (int)$u['id'];
    if (game_state($uid, 'burrow')) return [true, 'Your walk past the burrows is still on.'];
    if (game_plays_left($uid, 'burrow') <= 0) return [false, 'The neighbours have gone to bed. Come back after the daily reset.'];
    $season = function_exists('hollow_season') ? hollow_season() : 'spring';
    $pz = burrow_new_puzzle($season);
    $max = burrow_max_knocks($u);
    game_save($uid, 'burrow', ['v' => 1, 'cast' => $pz['cast'], 'sol' => $pz['sol'], 'clues' => $pz['clues'], 'knocks' => $max, 'max' => $max,
        'hist' => [], 'last' => [], 'season' => $pz['season'], 't0' => time()]);
    return [true, '🚪 You wander down the bank. Five little doors, and everyone’s tidy-up labels have blown away.'];
}

/** Checks the posted arrangement: exactly 5 whole numbers 0-4, each once. Returns [arrangement|null, error]. */
function burrow_read_arrangement($d): array
{
    if (!is_array($d)) return [null, 'Put one neighbour behind every door.'];
    $out = [];
    for ($i = 0; $i < BURROW_DOORS; $i++) {
        $v = $d[$i] ?? null;
        if (!is_string($v) || !preg_match('/^[0-9]$/', $v) || (int)$v >= BURROW_DOORS) return [null, 'Put one neighbour behind every door.'];
        $out[] = (int)$v;
    }
    if (count($d) !== BURROW_DOORS) return [null, 'Put one neighbour behind every door.'];
    if (count(array_unique($out)) !== BURROW_DOORS) return [null, 'Each neighbour can only live in one burrow.'];
    return [$out, ''];
}

function burrow_knock(array $u, $d): array
{
    $uid = (int)$u['id'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // lock this gnome, then re-read the round inside the transaction
    $s = game_state($uid, 'burrow');
    if (!$s) { db()->rollBack(); return [false, 'Visit the burrows first.']; }
    if ((int)$s['knocks'] <= 0) { db()->rollBack(); return [false, 'No knocks left.']; }
    [$arr, $err] = burrow_read_arrangement($d);
    if ($arr === null) { db()->rollBack(); return [false, $err]; }
    $hits = 0;
    foreach ($arr as $door => $who) if ($who === (int)$s['sol'][$door]) $hits++;
    $s['knocks'] = (int)$s['knocks'] - 1;
    $s['hist'][] = [$arr, $hits];
    $s['last'] = $arr;
    $used = (int)$s['max'] - (int)$s['knocks'];
    if ($hits === BURROW_DOORS || $s['knocks'] <= 0) {
        $won = $hits === BURROW_DOORS;
        $pay = burrow_settle($uid, $s, $won);
        if ($pay === null) { db()->rollBack(); return [false, 'That round is already over.']; }
        db()->commit();
        burrow_finish_prize($uid, $s, $pay, $won, $used);   // energy and the prize box, after the commit (as Mushroom does)
        return [true, $won ? '' : '✊ Knock knock… ' . $hits . ' at home. That was your last knock.'];
    }
    game_save($uid, 'burrow', $s);
    db()->commit();
    return [true, $hits === 0 ? '✊ Knock knock… nobody’s in the right place yet.' : '✊ Knock knock… ' . $hits . ' at home.'];
}

/** Inside the caller's transaction: the DELETE is the claim (only the request that removes the round pays), then score and Petals. Null = already over. */
function burrow_settle(int $uid, array $s, bool $won): ?array
{
    $score = $won ? burrow_score((int)$s['knocks']) : 0;
    $petals = game_petals($won ? $score : BURROW_FAIL_RAW);
    $xp = ($won && (string)setting('games_give_xp') === '1') ? intdiv($score, 10) : 0;
    if (q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'burrow'])->rowCount() !== 1) return null;
    game_score($uid, 'burrow', $score);
    if ($petals) give_petals($uid, $petals);
    if ($xp) add_xp($uid, $xp);
    return ['score' => $score, 'petals' => $petals, 'xp' => $xp];
}

/** After the commit: a little energy and the prize box. A lost round keeps the real order for one reveal. */
function burrow_finish_prize(int $uid, array $s, array $pay, bool $won, int $used): void
{
    $en = game_energy($uid, $won && $used <= 2);
    if (!$won) $_SESSION['burrow_last'] = ['cast' => $s['cast'], 'sol' => $s['sol']];
    $petals = (int)$pay['petals'];
    if ($won) {
        prize('🏆', '🏆 Everyone’s home!', 'Sorted in ' . $used . ' knock' . ($used === 1 ? '' : 's'),
            [$petals ? '+' . money($petals) : '', $pay['xp'] ? '+' . $pay['xp'] . ' XP' : '', $en !== '' ? trim($en) . ' energy' : '']);
    } else {
        prize('🌙', '🌙 The neighbours have gone to bed', 'Out of knocks',
            [$petals ? '+' . money($petals) . ' for the walk' : '', $en !== '' ? trim($en) . ' energy' : '']);
    }
}
