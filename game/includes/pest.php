<?php
declare(strict_types=1);
/**
 * v1.4.8: Pest Patrol. One plant a round, pests pop up on its leaves, flick them off before they chew a leaf away.
 *
 * Trust: the SERVER makes the whole round (plant design, which pests appear on which leaf and when, the butterfly) and keeps it
 * in game_state with a token and a start time. assets/pest.js plays that schedule, records the taps (time + leaf) and sends them
 * at the end. The server replays the taps through pest_sim(), the same rules the page runs (PEST_RULES is handed to the page in
 * data-rules and the machine in pest.js mirrors pest_sim() step for step), so the score is the server's. One claim (the DELETE
 * of the round row), a least play time, a tap-rate cap and a tap-count cap. Payout: Petals by score band, XP and energy like the other games.
 */

/** The plant designs, in the order assets/pest.js draws them: name => leaves on that plant (8 to 12). */
const PEST_PLANTS = [
    'Tomato' => 10, 'Bean' => 12, 'Sunflower' => 9, 'Rose' => 11, 'Lettuce' => 12, 'Kale' => 10, 'Pepper' => 10, 'Strawberry' => 9,
    'Pumpkin vine' => 8, 'Cucumber' => 9, 'Basil' => 12, 'Mint' => 12, 'Fern' => 8, 'Monstera' => 8, 'Orchid' => 8, 'Tulip' => 8,
    'Lavender' => 12, 'Corn' => 9, 'Cabbage' => 10, 'Chard' => 9, 'Poppy' => 9, 'Daisy' => 10, 'Ivy' => 12, 'Fig' => 8, 'Citrus sapling' => 11,
];

/**
 * The rules both sides play by (all whole numbers, times in ms).
 * kinds: hp = taps to flick it, pts = points, chew = ms before it eats its leaf off (0 = never), dwell = a gnat's ms on each leaf.
 * react = ms after a pest shows before a tap counts, gap = least ms between two counted taps, bruise = bare taps that drop a leaf,
 * quick/quickHp = a flick this fast (plus quickHp for each extra tap) keeps the combo, step/cap = combo points (+step per link, up to cap),
 * leaf = bonus per leaf left at the end, fall = points lost for a lost leaf, bf = butterfly points, bfReact/bfDur = butterfly window.
 */
const PEST_RULES = [
    'kinds' => [
        'a' => ['hp' => 3, 'pts' => 9, 'chew' => 6500, 'dwell' => 0],     // aphids: a cluster, several taps
        'g' => ['hp' => 1, 'pts' => 12, 'chew' => 0, 'dwell' => 2000],    // gnats: hop between leaves, never chew
        'c' => ['hp' => 1, 'pts' => 8, 'chew' => 5200, 'dwell' => 0],     // caterpillars: slow, hungry
        's' => ['hp' => 2, 'pts' => 10, 'chew' => 5800, 'dwell' => 0],    // slugs: two taps
    ],
    'react' => 150, 'gap' => 80, 'bruise' => 3, 'quick' => 1400, 'quickHp' => 350, 'step' => 1, 'cap' => 8,
    'leaf' => 4, 'fall' => 15, 'bf' => 25, 'bfReact' => 100, 'bfDur' => 4500,
];

/** Petals by score: [least score, Petals]. Score 100 or more is a "good game" for the energy bonus. */
const PEST_BANDS = [[60, 5], [150, 12], [250, 20], [370, 30]];
const PEST_GOOD = 150;
const PEST_MAX_TAPS = 260;

/** Seconds of the round: pest round length (30 s) plus 1 s per Ladybird Lodge level (up to +3), in ms. */
function pest_dur(int $uid): int
{
    $plot = function_exists('active_plot_id') ? active_plot_id($uid) : 0;
    $lvl = $plot && function_exists('building_level') ? min(3, max(0, building_level($plot, 'ladybird_lodge'))) : 0;
    return (30 + $lvl) * 1000;
}

/** Does the gnome carry a Bug Net (any tier) in the satchel / toolbelt? */
function pest_has_net(int $uid): bool
{
    return tool_tier($uid, 'net') > 0;
}

/** Make the schedule of pests for a plant of $n leaves in a round of $dur ms. */
function pest_schedule(int $n, int $dur): array
{
    $K = PEST_RULES['kinds'];
    $bag = array_merge(array_fill(0, 30, 'a'), array_fill(0, 22, 'g'), array_fill(0, 22, 'c'), array_fill(0, 26, 's'));
    $busy = array_fill(0, $n, []);   // per leaf: [from, to] windows already promised to a pest
    $free = function (int $leaf, int $from, int $to) use (&$busy): bool {
        foreach ($busy[$leaf] as [$a, $b]) if ($from < $b && $to > $a) return false;
        return true;
    };
    $t = random_int(300, 700);
    $out = [];
    $last = $dur - 5200;   // the last pest shows with time to deal with it
    $tries = 0;
    while ($t <= $last && count($out) < 44 && $tries++ < 200) {
        $k = $bag[array_rand($bag)];
        if ($k === 'g') {
            $hops = random_int(1, 3); $dw = $K['g']['dwell'];
            $h = []; $prev = -1; $ok = true;
            for ($j = 0; $j < $hops; $j++) {
                $from = $t + $j * $dw; $to = $from + $dw;
                $cand = [];
                for ($l = 0; $l < $n; $l++) if ($l !== $prev && $free($l, $from, $to)) $cand[] = $l;
                if (!$cand) { $ok = false; break; }
                $l = $cand[array_rand($cand)];
                $h[] = [$from, $l]; $prev = $l;
            }
            if (!$ok) { $t += 300; continue; }
            foreach ($h as [$from, $l]) $busy[$l][] = [$from, $from + $dw];
            $out[] = ['k' => 'g', 'h' => $h];
        } else {
            $to = $t + $K[$k]['chew'];
            $cand = [];
            for ($l = 0; $l < $n; $l++) if ($free($l, $t, $to)) $cand[] = $l;
            if (!$cand) { $t += 300; continue; }
            $l = $cand[array_rand($cand)];
            $busy[$l][] = [$t, $to];
            $out[] = ['k' => $k, 't' => $t, 'l' => $l];
        }
        $ramp = 1.0 - 0.3 * min(1.0, $t / max(1, $dur));   // busier as the round goes on
        $t += (int)round(random_int(650, 1350) * $ramp);
    }
    return $out;
}

/** A fresh round (what the page needs, and what the server keeps to score it). */
function pest_new_round(int $uid): array
{
    $plants = array_keys(PEST_PLANTS);
    $design = random_int(0, count($plants) - 1);
    $n = PEST_PLANTS[$plants[$design]];
    $dur = pest_dur($uid);
    $bf = null;
    if (random_int(1, 100) <= max(0, min(100, (int)setting('pest_butterfly_pct')))) {
        $bf = [random_int(5000, max(5200, $dur - 9000)), PEST_RULES['bfDur']];
    }
    return ['tok' => bin2hex(random_bytes(8)), 't0' => microtime(true), 'design' => $design, 'n' => $n, 'dur' => $dur,
        'seed' => random_int(1, 2147483646), 'pests' => pest_schedule($n, $dur), 'bf' => $bf, 'net' => pest_has_net($uid) ? 1 : 0];
}

function pest_start(array $u): array
{
    $uid = (int)$u['id'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if (game_state($uid, 'pest')) { db()->rollBack(); return [true, 'Your patrol is still on. Back to the leaves!']; }
    if (game_plays_left($uid, 'pest') <= 0) { db()->rollBack(); return [false, 'The pests have gone quiet for today. Come back after the daily reset.']; }
    game_save($uid, 'pest', pest_new_round($uid));
    db()->commit();
    return [true, ''];
}

/**
 * Replay the taps through the rules. $taps = [[t ms, target], ...] sorted by t; target = leaf number, or -1 for the butterfly.
 * Mirrors the Machine in assets/pest.js (the same steps, whole numbers only). Returns the totals.
 */
function pest_sim(array $round, array $taps): array
{
    $R = PEST_RULES; $K = $R['kinds'];
    $n = (int)$round['n']; $dur = (int)$round['dur'];
    $alive = array_fill(0, $n, true); $bru = array_fill(0, $n, 0);
    $P = [];
    foreach ($round['pests'] as $p) {
        $k = (string)$p['k'];
        $P[] = ['k' => $k, 'l' => (int)($p['l'] ?? -1), 't' => (int)($p['t'] ?? 0), 'h' => $p['h'] ?? [], 'hp' => $K[$k]['hp'], 'alive' => true];
    }
    $ev = [];   // [time, pest, type 0 arrive / 1 escape / 2 chew, hop]
    foreach ($P as $pi => $p) {
        if ($p['k'] === 'g') {
            foreach ($p['h'] as $j => $hh) $ev[] = [(int)$hh[0], $pi, 0, $j];
            $ev[] = [(int)$p['h'][count($p['h']) - 1][0] + $K['g']['dwell'], $pi, 1, 0];
        } else {
            $ev[] = [$p['t'] + $K[$p['k']]['chew'], $pi, 2, 0];
        }
    }
    usort($ev, fn($a, $b) => [$a[0], $a[1], $a[2]] <=> [$b[0], $b[1], $b[2]]);
    $S = ['score' => 0, 'combo' => 0, 'best' => 0, 'flicked' => 0, 'lost' => 0, 'bruises' => 0, 'escaped' => 0, 'caught' => 0, 'nonet' => 0];
    $ei = 0; $ne = count($ev);
    $bf = $round['bf'] ?? null; $bfUsed = false; $net = !empty($round['net']);
    $curLeaf = function (array $p, int $t): int {   // the leaf a gnat is on at time $t (-1 = none)
        if (!$p['h'] || $t < (int)$p['h'][0][0]) return -1;
        $j = intdiv($t - (int)$p['h'][0][0], PEST_RULES['kinds']['g']['dwell']);
        return $j < count($p['h']) ? (int)$p['h'][$j][1] : -1;
    };
    $drop = function (int $l, int $t) use (&$alive, &$P, &$S, $R, $curLeaf): void {
        $alive[$l] = false; $S['lost']++; $S['score'] -= $R['fall']; $S['combo'] = 0;
        foreach ($P as $qi => $q) {
            if (!$q['alive']) continue;
            if ($q['k'] === 'g' ? $curLeaf($q, $t) === $l : $q['l'] === $l) $P[$qi]['alive'] = false;
        }
    };
    $advance = function (int $t) use (&$ei, $ne, &$ev, &$P, &$alive, &$S, $drop): void {
        while ($ei < $ne && $ev[$ei][0] <= $t) {
            [$et, $pi, $type, $j] = $ev[$ei++];
            $p = $P[$pi];
            if ($type === 0) { if ($p['alive'] && !$alive[(int)$p['h'][$j][1]]) $P[$pi]['alive'] = false; }
            elseif ($type === 1) { if ($p['alive']) { $P[$pi]['alive'] = false; $S['escaped']++; } }
            else { if ($p['alive'] && $alive[$p['l']]) $drop($p['l'], $et); }
        }
    };
    $last = -1000000;
    foreach ($taps as [$t, $target]) {
        if ($t - $last < $R['gap']) continue;
        $advance($t);
        $last = $t;
        if ($target === -1) {
            if ($bf && !$bfUsed && $t >= $bf[0] + $R['bfReact'] && $t <= $bf[0] + $bf[1]) {
                $bfUsed = true;
                if ($net) { $S['caught'] = 1; $S['score'] += $R['bf']; } else { $S['nonet'] = 1; }
            }
            continue;
        }
        if ($target < 0 || $target >= $n || !$alive[$target]) continue;
        $hit = -1; $start = 0;
        foreach ($P as $pi => $p) {
            if (!$p['alive']) continue;
            if ($p['k'] === 'g') {
                if ($curLeaf($p, $t) !== $target) continue;
                $start = (int)$p['h'][0][0] + intdiv($t - (int)$p['h'][0][0], $K['g']['dwell']) * $K['g']['dwell'];
            } else {
                if ($p['l'] !== $target || $t < $p['t']) continue;
                $start = $p['t'];
            }
            $hit = $pi; break;
        }
        if ($hit >= 0) {
            if ($t < $start + $R['react']) continue;   // still popping up
            $P[$hit]['hp']--;
            if ($P[$hit]['hp'] > 0) continue;
            $k = $P[$hit]['k'];
            $P[$hit]['alive'] = false; $S['flicked']++;
            $fast = ($t - $start) <= $R['quick'] + $R['quickHp'] * ($K[$k]['hp'] - 1);
            $bonus = 0;
            if ($fast) { $S['combo']++; $bonus = min($S['combo'] - 1, $R['cap']) * $R['step']; $S['best'] = max($S['best'], $S['combo']); }
            else $S['combo'] = 0;
            $S['score'] += $K[$k]['pts'] + $bonus;
        } else {
            $S['bruises']++; $S['combo'] = 0;
            if (++$bru[$target] >= $R['bruise']) $drop($target, $t);
        }
    }
    $advance($dur);
    $left = count(array_filter($alive));
    $unresolved = 0;
    foreach ($P as $p) {
        if (!$p['alive']) continue;
        $st = $p['k'] === 'g' ? (int)$p['h'][0][0] : $p['t'];
        if ($st <= $dur) $unresolved++;
    }
    $S['leaves'] = $left; $S['unresolved'] = $unresolved;
    $S['score'] = max(0, $S['score'] + $left * $R['leaf']);
    $S['perfect'] = $S['lost'] === 0 && $unresolved === 0 && $S['escaped'] === 0 && $S['bruises'] <= 2 && $S['flicked'] >= 15;   // every pest flicked, no lost leaves, at most 2 stray taps
    return $S;
}

/** Read the posted taps: JSON [[t, target], ...] -> clean, sorted list (whole numbers inside the round, at most PEST_MAX_TAPS). */
function pest_clean_taps(string $json, int $n, int $dur): array
{
    $a = json_decode($json, true);
    if (!is_array($a)) return [];
    $out = [];
    foreach ($a as $row) {
        if (!is_array($row) || count($row) < 2 || !is_numeric($row[0]) || !is_numeric($row[1])) continue;
        $t = (int)round((float)$row[0]); $g = (int)$row[1];
        if ($t < 0 || $t > $dur || $g < -1 || $g >= $n) continue;
        $out[] = [$t, $g];
        if (count($out) >= PEST_MAX_TAPS) break;
    }
    usort($out, fn($x, $y) => $x[0] <=> $y[0]);
    return $out;
}

/** Petals for a score. */
function pest_coins(int $score): int
{
    $c = 0;
    foreach (PEST_BANDS as [$min, $coins]) if ($score >= $min) $c = $coins;
    return $c;
}

function pest_finish(array $u, string $tok, string $tapsJson): array
{
    $uid = (int)$u['id'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    $s = game_state($uid, 'pest');
    if (!$s || !isset($s['tok'])) { db()->rollBack(); return [false, 'Start a patrol first.']; }
    if (!hash_equals((string)$s['tok'], $tok)) { db()->rollBack(); return [false, 'That was an old patrol. Try again.']; }
    $dur = (int)$s['dur'];
    if ((microtime(true) - (float)$s['t0']) * 1000 < $dur - 500) { db()->rollBack(); return [false, 'Too quick! The patrol is not over yet.']; }
    // the round row is the claim: only the call that deletes it scores
    if (q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'pest'])->rowCount() !== 1) { db()->rollBack(); return [false, 'That patrol is already over.']; }
    $r = pest_sim($s, pest_clean_taps($tapsJson, (int)$s['n'], $dur));
    $score = (int)$r['score'];
    game_score($uid, 'pest', $score);
    $coins = game_petals(pest_coins($score));
    if ($coins) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    $xp = (string)setting('games_give_xp') === '1' ? 1 + intdiv($score, 60) : 0;
    if ($xp) add_xp($uid, $xp);
    $en = game_energy($uid, $score >= PEST_GOOD);
    $items = [];
    if ($r['caught']) {   // a butterfly, caught with the Bug Net: it sheds a Wing Scale
        require_once __DIR__ . '/animals140.php';
        animals140_items();
        $iid = (int)q_val("SELECT id FROM items WHERE slug = 'wing-scale'");
        if ($iid && give_item($uid, $iid, 1)) $items[] = '🦋 Wing Scale';
    }
    $charm = false;
    $capDay = max(0, (int)setting('pest_charm_per_day'));
    if ($r['perfect'] && $capDay > 0 && random_int(1, 100) <= max(0, min(100, (int)setting('pest_charm_pct'))) && (int)q_val("SELECT COUNT(*) FROM game_scores WHERE user_id = ? AND game = 'pestcharm' AND day = ?", [$uid, game_day()]) < $capDay) {
        require_once __DIR__ . '/garden_world.php';
        garden100_items();
        $iid = (int)q_val("SELECT id FROM items WHERE slug = 'ladybird-charm'");
        if ($iid && give_item($uid, $iid, 1)) {
            game_score($uid, 'pestcharm', 1);
            $items[] = '🐞 Ladybird Charm';
            $charm = true;
        }
    }
    db()->commit();
    $best = game_best($uid, 'pest');
    prize('🪰', $r['perfect'] ? 'A perfect patrol!' : ($score >= PEST_GOOD ? 'Well patrolled!' : ($score >= 60 ? 'Pests seen off.' : 'The pests had a feast…')), $score . ' points',
        array_filter([$coins ? '+' . money($coins) : '', $xp ? '+' . $xp . ' XP' : '', $en !== '' ? trim($en) . ' energy' : '',
            $items ? 'Found: ' . implode(', ', $items) : '',
            '🍃 ' . $r['leaves'] . ' of ' . (int)$s['n'] . ' leaves saved · 🪰 ' . $r['flicked'] . ' pests flicked' . ($r['best'] > 1 ? ' · best streak ' . $r['best'] : ''),
            $r['nonet'] ? '🦋 A butterfly fluttered by, but you had no bug net.' : '',
            $score >= $best ? '🏅 Your best this week!' : '']));
    return [true, ''];
}
