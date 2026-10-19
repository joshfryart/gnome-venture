<?php
declare(strict_types=1);
/**
 * v1.5.0: the six tool games, reworked (assets/gather-games.js draws and plays them; art in assets/img/gather/).
 *   knife  trace   drag along the herb stem's glowing cut line; the server scores the sampled finger path
 *   axe    chop    three swaying logs: drop the axe when the grain lines up with the blade (timing window)
 *   pick   glint   tap crystal glints in the rock before they fade
 *   rod    lure    Spore Lure: a fish blinks a colour pattern, pulse it back with the spore buttons (3 to 6 long)
 *   net    flit    one swipe across fluttering bugs; every bug the net passes through counts
 *   bucket drip    slide the bucket under the drips without sloshing it
 * Reduced-motion players get the plain 'cue' round (a still screen, tap when it says NOW) for the timing games
 * (chop, glint, flit, drip); the lure and the trace are already calm and play as they are.
 *
 * Trust (unchanged): the client never reports a score. The server makes the whole round (fish and pattern, stem curve, log
 * sway, glint spots and times, bug flight paths, drip times) and keeps it in the session with its start time, and gives it
 * out once. The page sends back only what the player DID (colour taps, finger samples, strike times, tap spots) and the
 * server recomputes the same rules itself. A round is used once; inputs must fall in their windows, in order, no faster than
 * a finger, no further than a finger can move, no later than the clock allows, and the round can't be handed in sooner
 * than it could be played. Anything that doesn't check out is a plain find. Result: 'perfect' (+1 find, rarer finds
 * likelier, no tool wear), 'good' (+1 find), 'miss' / '' (a normal find). Same bands as before, so the economy is unchanged.
 * "Quick gather" skips the game for GATHER_QUICK_BAND.
 * Practice (games.php?tab=practice): the same rounds, built and scored by the same code, but never paid: they live in
 * $_SESSION['gather_practice'], need no tool or energy, and gather_practice_result() only tells the page how it went.
 */

/** Which band Quick gather (no game) gives. 'good' = +1 find; '' = a plain find. */
const GATHER_QUICK_BAND = '';   // v0.9.9 Opus: quick = plain find (old economy); set 'good' for +1
const GATHER_ROUND_MAX_S = 300;   // a round not handed in within five minutes is stale

/** [button word, how to play, perfect text, good text, miss text, game type, practice name, practice blurb] */
const GATHER_GAMES = [
    'forage' => ['🔪 Done', 'Drag your finger along the glowing cut line, from the first dot to the last. Stay on the stem. Keys: arrows slide the knife, Enter when done.', 'One long, clean cut. A neat harvest!', 'A mostly steady cut.', 'The knife wandered, but it’ll do.', 'trace', 'Stem Trace', 'Trace the glowing cut line along a herb stem with one steady drag.'],
    'axe'    => ['🪓 Chop!', 'Each log sways on its rope. Tap when the grain line is under the axe. Three logs. Keys: Space or Enter.', 'Three logs split clean as a whistle!', 'A few good, solid chops.', 'The axe glances off, but you get there in the end.', 'chop', 'Log Split', 'Watch the swaying log; chop when its grain lines up under the axe.'],
    'pick'   => ['⛏️ Strike!', 'Crystals glint in the rock for a moment. Tap each one before it fades. Keys: Space or Enter taps the oldest glint, or Tab to a glint.', 'Not a crystal faded unstruck!', 'A good haul of crystals.', 'Chips fly everywhere, but something comes loose.', 'glint', 'Glint Strike', 'Tap the glints in the rock layers before the crystals fade out.'],
    'rod'    => ['🎣 Pulse', 'Spore Lure: a fish swims up and blinks a colour pattern on its side. Pulse your lure back in the same order with the spore buttons. Keys: 1 to 4.', 'The fish swirled right up the thread!', 'It took the lure on the second go.', 'It nibbled and drifted off.', 'lure', 'Spore Lure', 'Lower a glowing thread, watch the fish blink a pattern, then pulse it back in order.'],
    'net'    => ['🦋 Swoop', 'One swipe! Drag the net in a single sweep through the fluttering bugs. Everything it passes through is caught. Keys: arrows then Enter.', 'A swipe full of wings!', 'Got a good few.', 'A clumsy swoop, but you manage.', 'flit', 'Bug Swoop', 'Plan one single swipe that sweeps through as many fluttering bugs as it can.'],
    'bucket' => ['🪣 Hold', 'Slide the bucket under the drips. Move gently: sloshing spills water. Keys: left and right arrows.', 'Every drip caught, not a drop spilled!', 'A good bucketful.', 'Mostly puddle, but there’s something in it.', 'drip', 'Drip Catch', 'Slide the bucket under the cave drips, and keep the water from sloshing out.'],
];

/** Spore Lure fish: [name, pattern length, colours, blink ms, hue turn, size % of the pond]. Bigger fish: longer patterns, faster blinks. */
const GATHER_LURE_FISH = [
    ['Dimple minnow', 3, 3, 780, 0, 26], ['Pond perch', 4, 3, 720, 38, 30], ['Glowfin carp', 4, 4, 680, 190, 34],
    ['Moss trout', 5, 4, 620, 105, 38], ['Lantern eel', 5, 4, 560, 270, 42], ['Old Whiskerpike', 6, 4, 520, 330, 46],
];
const GATHER_LURE_GAP = 140;     // ms of dark between two blinks
const GATHER_LURE_REPLAY = 700;  // ms after a mistake before the fish blinks the pattern again
const GATHER_LURE_IDLE = 8000;   // ms of no pulse before the fish loses interest

/** How forgiving the game is for this gnome and tool: tool tier (1–4) plus half of Nimble. */
function gather_game_ease(array $u, string $tool): int
{
    $t = max(1, tool_tier((int)$u['id'], $tool));
    $n = max(0, function_exists('eff_mod') ? eff_mod($u, 'nimble') : 0);
    return min(8, $t + intdiv($n, 2));
}

/** Zone widths (% of the field) for the chop: [good, perfect]. Better tools and Nimble make it easier (as in 0.7.91). */
function gather_game_widths(array $u, string $tool): array
{
    $t = max(1, tool_tier((int)$u['id'], $tool));
    $n = max(0, function_exists('eff_mod') ? eff_mod($u, 'nimble') : 0);
    $good = min(40, 14 + 3 * $t + 2 * $n);
    return [$good, max(6, intdiv($good, 3))];
}

/** Where a log's grain is (percent left or right of the axe) $ms after that log appeared. */
function gather_chop_off(array $r, int $i, float $ms): float
{
    return $r['amp'] * sin(2 * M_PI * $ms / $r['per'][$i] + $r['ph'][$i]);
}

/** A bug's place (0–100 each way) at $t ms: along its line, fluttering to either side. */
function gather_flit_pos(array $b, float $t): array
{
    $u = min(1.0, max(0.0, ($t - $b['a']) / $b['life']));
    $dx = $b['x1'] - $b['x0']; $dy = $b['y1'] - $b['y0']; $len = max(1.0, hypot($dx, $dy));
    $off = $b['fa'] * sin($b['ff'] * ($t - $b['a']) + $b['fp']);
    return [$b['x0'] + $dx * $u - $dy / $len * $off, $b['y0'] + $dy * $u + $dx / $len * $off];
}

/** Distance from point to the segment (ax,ay)-(bx,by). */
function gather_seg_dist(float $px, float $py, float $ax, float $ay, float $bx, float $by): float
{
    $dx = $bx - $ax; $dy = $by - $ay; $l2 = $dx * $dx + $dy * $dy;
    $u = $l2 > 0 ? max(0.0, min(1.0, (($px - $ax) * $dx + ($py - $ay) * $dy) / $l2)) : 0.0;
    return hypot($px - ($ax + $u * $dx), $py - ($ay + $u * $dy));
}

/** A new round for this tool, kept in the session (replaces any unplayed one). Returns what the page needs to play it.
 *  $calm = reduced motion. $practice = a practice round: same round, kept apart, never paid. */
function gather_round_new(array $u, string $tool, bool $calm = false, bool $practice = false): ?array
{
    $G = GATHER_GAMES[$tool] ?? null;
    if (!$G) return null;
    $e = gather_game_ease($u, $tool);
    $type = $G[5];
    if ($calm && in_array($type, ['chop', 'glint', 'flit', 'drip'], true)) $type = 'cue';   // still round for reduced motion
    $r = ['tok' => bin2hex(random_bytes(8)), 'tool' => $tool, 'type' => $type, 'seed' => random_int(1, 2147483646), 'e' => $e];
    switch ($type) {
        case 'lure': {
            $maxI = min(count(GATHER_LURE_FISH) - 1, 1 + $e);   // a better rod meets bigger fish
            $w = []; for ($i = 0; $i <= $maxI; $i++) $w[$i] = $maxI - $i + 1 + ($i >= 2 ? 1 : 0);
            $pick = random_int(1, array_sum($w)); $fi = 0;
            foreach ($w as $i => $x) { $pick -= $x; if ($pick <= 0) { $fi = $i; break; } }
            [$name, $L, $nc, $bl, $hue, $size] = GATHER_LURE_FISH[$fi];
            $bl = min(900, $bl + 25 * $e);
            $pat = []; for ($i = 0; $i < $L; $i++) $pat[] = random_int(0, $nc - 1);
            if (count(array_unique($pat)) === 1) $pat[$L - 1] = ($pat[0] + 1) % $nc;
            $a = 1100;
            $r += ['fish' => $name, 'fi' => $fi, 'L' => $L, 'nc' => $nc, 'pat' => $pat, 'bl' => $bl, 'gap' => GATHER_LURE_GAP, 'a' => $a, 'rep' => GATHER_LURE_REPLAY,
                'lives' => $L <= 4 ? 2 : 1, 'hue' => $hue, 'size' => $size, 'idle' => GATHER_LURE_IDLE, 'showEnd' => $a + $L * ($bl + GATHER_LURE_GAP), 'dur' => 120000];
            break;
        }
        case 'trace': {
            $ph1 = random_int(0, 628) / 100; $ph2 = random_int(0, 628) / 100;
            $k1 = 2 * M_PI / random_int(90, 130); $k2 = 2 * M_PI / random_int(40, 60);
            $a1 = random_int(130, 190) / 10; $a2 = max(2.0, 8 - 0.7 * $e);
            $flip = random_int(0, 1) === 1; $pts = []; $len = 0.0;
            for ($i = 0; $i <= 44; $i++) {
                $x = 10 + 80 * $i / 44;
                $y = max(14.0, min(86.0, 50 + $a1 * sin($k1 * ($x - 10) + $ph1) + $a2 * sin($k2 * ($x - 10) + $ph2)));
                $pt = $flip ? [round($y, 1), round($x, 1)] : [round($x, 1), round($y, 1)];
                if ($pts) $len += hypot($pt[0] - $pts[count($pts) - 1][0], $pt[1] - $pts[count($pts) - 1][1]);
                $pts[] = $pt;
            }
            $r += ['pts' => $pts, 'tol' => round(min(9.0, 4.6 + 0.55 * $e), 1), 'len' => round($len, 1), 'dur' => 16000];
            break;
        }
        case 'chop': {
            [$g, $p] = gather_game_widths($u, $tool);
            $per = []; $ph = [];
            for ($i = 0; $i < 3; $i++) { $per[] = 2400 + 130 * $e - 330 * $i; $ph[] = random_int(0, 628) / 100; }
            $r += ['n' => 3, 'amp' => 38, 'per' => $per, 'ph' => $ph, 'g' => $g, 'p' => $p, 'arrive' => 800, 'wait' => 9000, 'first' => 700, 'dur' => 3 * 9800 + 1500];
            break;
        }
        case 'glint': {
            $n = 10; $life = 1500 + 170 * $e; $rad = round(min(13.0, 8 + 0.6 * $e), 1); $gl = [];
            for ($i = 0; $i < $n; $i++) {
                $a = 500 + $i * 720 + random_int(-60, 60);
                for ($try = 0; $try < 40; $try++) {
                    $x = random_int(12, 88); $y = random_int(12, 88); $ok = true;
                    foreach ($gl as $o) if ($o['a'] + $life > $a && hypot($o['x'] - $x, $o['y'] - $y) < 24) { $ok = false; break; }
                    if ($ok) break;
                }
                $gl[] = ['x' => $x, 'y' => $y, 'a' => $a, 'k' => random_int(0, 2)];
            }
            $r += ['n' => $n, 'life' => $life, 'rad' => $rad, 'gl' => $gl, 'dur' => $gl[$n - 1]['a'] + $life + 400];
            break;
        }
        case 'flit': {
            $n = 7; $life = 5200 + 200 * $e; $bugs = [];
            for ($i = 0; $i < $n; $i++) {
                do { [$x0, $y0, $x1, $y1] = [random_int(14, 86), random_int(14, 86), random_int(14, 86), random_int(14, 86)]; } while (hypot($x1 - $x0, $y1 - $y0) < 25);
                $bugs[] = ['x0' => $x0, 'y0' => $y0, 'x1' => $x1, 'y1' => $y1, 'a' => $i * 200 + random_int(0, 140), 'life' => $life,
                    'fa' => random_int(30, 70) / 10, 'ff' => random_int(40, 90) / 10000, 'fp' => random_int(0, 628) / 100, 'k' => $i % 3];
            }
            $r += ['n' => $n, 'rad' => round(min(14.0, 8.5 + 0.7 * $e), 1), 'bugs' => $bugs, 'dur' => $bugs[$n - 1]['a'] + $life + 400, 'vmax' => 0.14];
            break;
        }
        case 'drip': {
            $sx = [20 + random_int(-4, 4), 50 + random_int(-3, 3), 80 + random_int(-4, 4)];
            $n = 14; $t = 1200; $dr = [];
            for ($i = 0; $i < $n; $i++) { $dr[] = ['s' => random_int(0, 2), 'a' => $t]; $t += random_int(620, 980); }
            $r += ['n' => $n, 'sx' => $sx, 'fd' => 1000, 'dr' => $dr, 'bw' => round(min(18.0, 9 + 1.1 * $e), 1), 'vs' => round(0.055 + 0.004 * $e, 3), 'vmax' => 0.12, 'dur' => $dr[$n - 1]['a'] + 1000 + 700];
            break;
        }
        case 'cue': {
            $T = random_int(2000, 4500); $W = 2000 + 250 * $e;
            $r += ['T' => $T, 'W' => $W, 'dur' => $T + $W + 2500];
            break;
        }
        default:
            return null;
    }
    $key = $practice ? 'gather_practice' : 'gather_round';
    $_SESSION[$key][$tool] = $r + ['at' => microtime(true)];
    if (!$practice) $_SESSION['gather_game_last'] = $tool;
    return $r + ['word' => $G[0], 'how' => $type === 'cue' ? 'Wait for the word NOW, then tap. Keys: Space or Enter.' : $G[1], 'practice' => $practice];
}

/** Clean list of numbers/arrays from the posted JSON, or null if it isn't one. */
function gather_round_events($raw): ?array
{
    if (!is_string($raw) || $raw === '' || strlen($raw) > 14000) return null;
    $ev = json_decode($raw, true);
    if (!is_array($ev) || !array_is_list($ev) || count($ev) > 220) return null;
    foreach ($ev as $x) {
        foreach ((array)$x as $v) if (!is_int($v) && !is_float($v)) return null;
        foreach ((array)$x as $v) if (!is_finite((float)$v) || abs($v) > 1e7) return null;
    }
    return $ev;
}

/** Score the taps for a cue round. 'perfect' | 'good' | 'miss', or null if it can't be right. */
function gather_calm_score(array $r, array $ev): ?string
{
    if (count($ev) > 1) return null;
    if (!$ev) return 'miss';   // waited it out
    $t = (float)(is_array($ev[0]) ? ($ev[0][0] ?? -1) : $ev[0]);
    if ($t < 1200 || $t > $r['dur'] + 300) return null;
    if ($t < $r['T']) return 'miss';
    return $t <= $r['T'] + 0.7 * $r['W'] ? 'perfect' : ($t <= $r['T'] + $r['W'] + 300 ? 'good' : 'miss');
}

/**
 * Clean finger samples [x10, y10, t] (x and y in tenths of a percent) into [[x, y, t], ...], or null if no finger could do it:
 * times rising, spots inside the field, no jump faster than $vmax percent per ms (+ a little slack), no gap over $maxGap.
 */
function gather_samples(array $ev, float $vmax, float $maxGap, float $tEnd, float $regrab = 1e9): ?array
{
    $s = []; $pt = null;
    foreach ($ev as $x) {
        if (!is_array($x) || count($x) !== 3) return null;
        [$a, $b, $t] = $x;
        $px = $a / 10; $py = $b / 10;
        if ($px < 0 || $px > 100 || $py < 0 || $py > 100 || $t < 0 || $t > $tEnd) return null;
        if ($pt) {
            $dt = $t - $pt[2];
            if ($dt < 8 || $dt > $maxGap) return null;
            if ($dt < $regrab && hypot($px - $pt[0], $py - $pt[1]) > $vmax * $dt + 2.5) return null;   // a lifted finger ($regrab ms or more) may land elsewhere
        }
        $pt = [$px, $py, (float)$t]; $s[] = $pt;
    }
    return $s;
}

/** Spore Lure: replay the pulses against the pattern. */
function gather_lure_score(array $r, array $ev): ?string
{
    $phase = (float)$r['showEnd']; $pos = 0; $tries = 0; $last = null; $out = null;
    foreach ($ev as $x) {
        if (!is_array($x) || count($x) !== 2) return null;
        [$c, $t] = $x;
        if ($out !== null || !is_int($c) || $c < 0 || $c >= $r['nc'] || $t < $phase) return null;
        if ($last !== null && $t - $last < 130) return null;
        if ($t - max((float)($last ?? 0), $phase) > $r['idle']) return null;   // it would have swum off by then
        $last = $t;
        if ($c === $r['pat'][$pos]) {
            if (++$pos >= $r['L']) $out = $tries === 0 ? 'perfect' : 'good';
        } else {
            if (++$tries >= $r['lives']) $out = 'miss';
            else { $pos = 0; $phase = $t + $r['rep'] + $r['L'] * ($r['bl'] + $r['gap']); }
        }
    }
    return $out ?? 'miss';   // the fish lost interest
}

/** Stem Trace: how much of the cut line the finger covered, and how much of the finger stayed near it. */
function gather_trace_score(array $r, array $ev, float $real): ?string
{
    if (!$ev) return 'miss';
    $s = gather_samples($ev, 0.14, 9000, (float)$r['dur'] + 300, 350);
    if ($s === null || count($s) < 2 || $s[0][2] < 250) return null;
    $pts = $r['pts']; $np = count($pts); $tol = (float)$r['tol'];
    // bins along the line (every few points) must have the finger within reach
    $bins = []; for ($i = 0; $i < $np; $i += 2) $bins[] = $pts[$i]; $bins[] = $pts[$np - 1];
    $cov = 0;
    foreach ($bins as $b) {
        $hit = false;
        for ($j = 0; $j < count($s) && !$hit; $j++) {
            $d = $j > 0 && $s[$j][2] - $s[$j - 1][2] < 400
                ? gather_seg_dist($b[0], $b[1], $s[$j - 1][0], $s[$j - 1][1], $s[$j][0], $s[$j][1])
                : hypot($b[0] - $s[$j][0], $b[1] - $s[$j][1]);
            if ($d <= $tol * 1.15) $hit = true;
        }
        if ($hit) $cov++;
    }
    $near = 0;
    foreach ($s as $p) {
        $m = 1e9;
        for ($i = 1; $i < $np; $i++) $m = min($m, gather_seg_dist($p[0], $p[1], $pts[$i - 1][0], $pts[$i - 1][1], $pts[$i][0], $pts[$i][1]));
        if ($m <= $tol * 1.7) $near++;
    }
    $cv = $cov / count($bins); $pr = $near / count($s);
    return $cv >= 0.93 && $pr >= 0.85 ? 'perfect' : ($cv >= 0.75 && $pr >= 0.6 ? 'good' : 'miss');
}

/** Log Split: each tap against that log's sway. A tap of -1 = the log was left to swing out its time. */
function gather_chop_score(array $r, array $ev): ?string
{
    if (count($ev) !== $r['n']) return null;
    $start = (float)$r['first']; $pts = 0;
    foreach ($ev as $i => $t) {
        if (is_array($t)) return null;
        if ($t == -1) { $start += $r['wait'] + $r['arrive']; continue; }
        if ($t < $start + 350 || $t > $start + $r['wait']) return null;
        $d = abs(gather_chop_off($r, $i, (float)$t - $start));
        $pts += $d <= $r['p'] / 2 ? 2 : ($d <= $r['g'] / 2 ? 1 : 0);
        $start = (float)$t + $r['arrive'];
    }
    return $pts >= 5 ? 'perfect' : ($pts >= 3 ? 'good' : 'miss');
}

/** Glint Strike: [glint, time, x10, y10] taps, each glint once, inside its life and near enough. */
function gather_glint_score(array $r, array $ev): ?string
{
    $seen = []; $got = 0; $taps = [];
    foreach ($ev as $x) {
        if (!is_array($x) || count($x) !== 4) return null;
        [$k, $t, $px, $py] = $x;
        if (!is_int($k) || $k < 0 || $k >= $r['n'] || isset($seen[$k])) return null;
        $g = $r['gl'][$k];
        if ($t < $g['a'] || $t > $g['a'] + $r['life'] + 200) return null;
        if (hypot($px / 10 - $g['x'], $py / 10 - $g['y']) > $r['rad'] + 2) return null;   // nowhere near the glint
        $seen[$k] = 1; $got++; $taps[] = $t;
    }
    sort($taps);
    for ($i = 1; $i < count($taps); $i++) if ($taps[$i] - $taps[$i - 1] < 50) return null;   // one finger
    return $got >= 8 ? 'perfect' : ($got >= 5 ? 'good' : 'miss');
}

/** Bug Swoop: the one swipe, checked every 25 ms against where each bug was. */
function gather_flit_score(array $r, array $ev): ?string
{
    if (!$ev) return 'miss';
    $s = gather_samples($ev, (float)$r['vmax'], 4000, (float)$r['dur'] + 300);
    if ($s === null || count($s) < 2 || $s[0][2] < 400 || $s[count($s) - 1][2] - $s[0][2] > 7000) return null;
    $got = [];
    for ($j = 0; $j < count($s); $j++) {
        $a = $s[max(0, $j - 1)]; $b = $s[$j]; $t0 = $a[2]; $t1 = $b[2];
        for ($t = $t0; $t <= $t1 + 0.001; $t += 25) {
            $f = $t1 > $t0 ? ($t - $t0) / ($t1 - $t0) : 1.0;
            $nx = $a[0] + ($b[0] - $a[0]) * $f; $ny = $a[1] + ($b[1] - $a[1]) * $f;
            foreach ($r['bugs'] as $k => $bg) {
                if (isset($got[$k]) || $t < $bg['a'] || $t > $bg['a'] + $bg['life']) continue;
                [$bx, $by] = gather_flit_pos($bg, $t);
                if (hypot($bx - $nx, $by - $ny) <= $r['rad']) $got[$k] = 1;
            }
        }
    }
    $n = count($got);
    return $n >= 5 ? 'perfect' : ($n >= 3 ? 'good' : 'miss');
}

/** Drip Catch: [caught, spills] from the bucket's recorded places [x10, t]. null if they can't be real. */
function gather_drip_eval(array $r, array $ev): ?array
{
    $s = []; $prev = null;
    foreach ($ev as $x) {
        if (!is_array($x) || count($x) !== 2) return null;
        [$a, $t] = $x; $px = $a / 10;
        if ($px < 0 || $px > 100 || $t < 0 || $t > $r['dur'] + 300) return null;
        if ($prev) {
            $dt = $t - $prev[1];
            if ($dt < 8 || $dt > 800 || abs($px - $prev[0]) > $r['vmax'] * $dt * 1.2 + 0.3) return null;   // a bucket can only be dragged so fast
        } elseif ($t > 400) return null;
        $prev = [$px, (float)$t]; $s[] = $prev;
    }
    $last = $r['dr'][$r['n'] - 1]['a'] + $r['fd'];
    if (count($s) < 2 || $s[count($s) - 1][1] < $last) return null;
    $at = function (float $t) use ($s): float {
        for ($j = 1; $j < count($s); $j++) if ($s[$j][1] >= $t) { $d = $s[$j][1] - $s[$j - 1][1]; return $s[$j - 1][0] + ($s[$j][0] - $s[$j - 1][0]) * ($d > 0 ? ($t - $s[$j - 1][1]) / $d : 1.0); }
        return $s[count($s) - 1][0];
    };
    $caught = 0;
    foreach ($r['dr'] as $d) if (abs($at((float)($d['a'] + $r['fd'])) - $r['sx'][$d['s']]) <= $r['bw']) $caught++;
    $spills = 0; $lastSpill = -1e9;
    for ($j = 1; $j < count($s); $j++) {
        $dt = $s[$j][1] - $s[$j - 1][1];
        if ($dt >= 30 && abs($s[$j][0] - $s[$j - 1][0]) / $dt > $r['vs'] && $s[$j][1] >= $lastSpill + 500) { $spills++; $lastSpill = $s[$j][1]; }
    }
    return [$caught, $spills];
}

/** Score a played round. Returns 'perfect' | 'good' | 'miss', or null if what was played doesn't check out. */
function gather_round_score(array $r, array $ev, float $real): ?string
{
    $type = $r['type'];
    $tmax = 0.0;
    foreach ($ev as $x) $tmax = max($tmax, (float)(is_array($x) ? ($type === 'trace' || $type === 'flit' ? ($x[2] ?? 0) : ($type === 'drip' ? ($x[1] ?? 0) : ($x[1] ?? $x[0] ?? 0))) : $x));
    if ($tmax > $real + 300) return null;   // inputs from the future
    $floor = ['trace' => 1800, 'chop' => 2500, 'glint' => 3500, 'lure' => (float)($r['showEnd'] ?? 0) + 400, 'flit' => 1500, 'drip' => (float)($r['dur'] ?? 0) - 700][$type] ?? 0;
    if ($type !== 'cue' && $real < $floor) return null;   // can't be played that fast
    switch ($type) {
        case 'lure': return gather_lure_score($r, $ev);
        case 'trace': return gather_trace_score($r, $ev, $real);
        case 'chop': return gather_chop_score($r, $ev);
        case 'glint': return gather_glint_score($r, $ev);
        case 'flit': return gather_flit_score($r, $ev);
        case 'drip':
            $x = gather_drip_eval($r, $ev);
            if ($x === null) return null;
            $net = max(0, $x[0] - $x[1]);
            return $net >= 11 ? 'perfect' : ($net >= 6 ? 'good' : 'miss');
        case 'cue': return gather_calm_score($r, $ev);
    }
    return null;
}

/** The tool's round from the session, used once whatever happens (so a bad hand-in can't be retried). */
function gather_round_take(string $tool, string $tok, string $key = 'gather_round'): ?array
{
    $r = $_SESSION[$key][$tool] ?? null;
    unset($_SESSION[$key][$tool]);
    if (!$r || $tok === '' || !hash_equals((string)$r['tok'], $tok)) return null;
    if ($key === 'gather_round') $_SESSION['gather_game_last'] = $tool;
    return $r;
}

/**
 * What the player did this time, from the posted form: 'perfect' / 'good' / 'miss', or '' (a plain find) when no game was
 * played or it doesn't check out. gquick = Quick gather (skip the game). Used by gather.php and adventure.php.
 */
function gather_game_result(string $tool): string
{
    if (!isset(GATHER_GAMES[$tool])) return '';
    if (($_POST['gquick'] ?? '') === '1') return GATHER_QUICK_BAND;
    $tok = (string)($_POST['gtok'] ?? '');
    if ($tok === '') return '';
    $r = gather_round_take($tool, $tok);
    $ev = gather_round_events($_POST['gev'] ?? null);
    if (!$r || $ev === null) return '';
    $real = (microtime(true) - (float)$r['at']) * 1000;
    if ($real > GATHER_ROUND_MAX_S * 1000) return '';
    return gather_round_score($r, $ev, $real) ?? '';
}

/** v1.5.0: how a practice round went, for the page: ['res' => 'perfect'|'good'|'miss'|'', 'text' => ...]. Pays nothing, uses nothing. */
function gather_practice_result(string $tool): array
{
    $G = GATHER_GAMES[$tool] ?? null;
    if (!$G) return ['res' => '', 'text' => 'No game for that.'];
    $r = gather_round_take($tool, (string)($_POST['gtok'] ?? ''), 'gather_practice');
    $ev = gather_round_events($_POST['gev'] ?? null);
    $real = $r ? (microtime(true) - (float)$r['at']) * 1000 : 0;
    $res = $r && $ev !== null && $real <= GATHER_ROUND_MAX_S * 1000 ? (gather_round_score($r, $ev, $real) ?? '') : '';
    $text = $res === 'perfect' ? $G[2] : ($res === 'good' ? $G[3] : ($res === 'miss' ? $G[4] : 'That round didn’t check out (too quick, or not a real play). No harm: try again.'));
    return ['res' => $res, 'text' => $text];
}

/** v0.9.9: one game panel for all the tools here (chips pick the tool). $formStart opens the gather form for the first tool. */
function gather_game_html(array $u, array $tools, string $formStart): string
{
    $tools = array_values(array_filter($tools, fn($t) => isset(GATHER_GAMES[$t])));
    if (!$tools || setting('gather_games_on') !== '1') return '';
    $chips = '';
    $on = (int)array_search($_SESSION['gather_game_last'] ?? '', $tools, true);   // the tool you last played stays chosen (0 if none)
    foreach ($tools as $i => $tool) {
        $G = GATHER_GAMES[$tool];
        $chips .= '<button type="button" class="chip mgtool' . ($i === $on ? ' on' : '') . '" data-tool="' . e($tool) . '" data-word="' . e($G[0]) . '" data-how="' . e($G[1])
            . '" aria-pressed="' . ($i === $on ? 'true' : 'false') . '">' . (TOOL_TYPES[$tool][1] ?? '🧺') . ' ' . e(GATHER_TOOL_NOUN[$tool] ?? $tool) . '</button>';
    }
    $G = GATHER_GAMES[$tools[$on]];
    return '<details class="mgfold" data-js="' . e(url('assets/gather-games.js?v=' . APP_VERSION)) . '" data-img="' . e(url('assets/img/gather/')) . '" data-v="' . e(APP_VERSION) . '" data-round="' . e(url('gather.php')) . '" data-csrf="' . e(csrf_token()) . '">'
        . '<summary>🎯 Play for a better find</summary><div class="mgame">'
        . '<div class="mgtools' . (count($tools) > 1 ? '' : ' solo') . '" role="group" aria-label="Choose a tool">' . $chips . '</div>'
        . $formStart . '<input type="hidden" name="gtok" value=""><input type="hidden" name="gev" value="">'
        . '<div class="gstage" role="group" aria-label="Gathering mini-game">'
        . '<div class="gintro"><p class="help mghow">' . e($G[1]) . '</p><button type="button" class="btn mgstart">▶ Play</button></div>'
        . '<div class="gplay" hidden><div class="gfield"></div><div class="gbar" aria-hidden="true"><span class="gtime"></span></div>'
        . '<p class="gsay" role="status" aria-live="polite"></p><div class="gpad"></div><button type="button" class="btn gact">' . e($G[0]) . '</button></div>'
        . '</div>'
        . '<button class="btn ghost small mgquick" name="gquick" value="1">⚡ Quick gather: skip the game</button></form>'
        . '<p class="help mgkey">🟩 great play: +1 find, rarer finds likelier, no tool wear · 🟨 good: +1 find · same ⚡1. New to a game? Try it in 🎯 Practice on the Games page. Quick gather is a ' . (GATHER_QUICK_BAND === 'good' ? '🟨 good' : 'plain') . ' find.</p></div></details>';
}

/** v1.5.0: the Practice tab's panel (games.php?tab=practice): all six tool games, no tool, no energy, no finds. */
function gather_practice_html(array $u): string
{
    if (setting('gather_games_on') !== '1') return '<p class="help">The tool games are switched off right now.</p>';
    $chips = ''; $list = '';
    $first = array_key_first(GATHER_GAMES);
    foreach (GATHER_GAMES as $tool => $G) {
        $on = $tool === $first;
        $icon = TOOL_TYPES[$tool][1] ?? '🧺';
        $chips .= '<button type="button" class="chip mgtool' . ($on ? ' on' : '') . '" data-tool="' . e($tool) . '" data-word="' . e($G[0]) . '" data-how="' . e($G[1])
            . '" data-name="' . e($G[6]) . '" aria-pressed="' . ($on ? 'true' : 'false') . '">' . $icon . ' ' . e($G[6]) . '</button>';
        $list .= '<li><b>' . $icon . ' ' . e($G[6]) . '</b> <span class="muted">' . e($G[7]) . '</span></li>';
    }
    $G = GATHER_GAMES[$first];
    return '<div class="mgfold mgprac" data-js="' . e(url('assets/gather-games.js?v=' . APP_VERSION)) . '" data-img="' . e(url('assets/img/gather/')) . '" data-v="' . e(APP_VERSION) . '" data-round="' . e(url('gather.php')) . '" data-csrf="' . e(csrf_token()) . '" data-practice="1">'
        . '<p class="gprac">🎯 Practice — no finds. No tool, no energy, no limit.</p>'
        . '<div class="mgtools" role="group" aria-label="Choose a game">' . $chips . '</div>'
        . '<div class="gstage" role="group" aria-label="Practice mini-game">'
        . '<div class="gintro"><p class="help mghow">' . e($G[1]) . '</p><button type="button" class="btn mgstart">▶ Practice</button></div>'
        . '<div class="gplay" hidden><div class="gfield"></div><div class="gbar" aria-hidden="true"><span class="gtime"></span></div>'
        . '<p class="gsay" role="status" aria-live="polite"></p><div class="gpad"></div><button type="button" class="btn gact">' . e($G[0]) . '</button></div>'
        . '<div class="gres" hidden></div>'
        . '</div></div>'
        . '<ul class="gpraclist">' . $list . '</ul>'
        . '<p class="help">Practice rounds are built and checked by the same rules as the real ones, but they never give finds, XP or tool wear. Get a 🟩 here and you know what to expect out in the world.</p>';
}

/** The line in front of the find, and what the result changes. */
function gather_game_line(string $tool, string $res): string
{
    $G = GATHER_GAMES[$tool] ?? null;
    if (!$G || $res === '') return '';
    return '🎯 ' . ($res === 'perfect' ? $G[2] . ' (+1, and your tool doesn’t wear)' : ($res === 'good' ? $G[3] . ' (+1)' : $G[4])) . ' ';
}
