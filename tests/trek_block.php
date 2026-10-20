<?php
// Treks v2.0.18: a blocking spot (duel, mini-boss, boss, stuck cart, a riddle door that gives way) that is NOT dealt with keeps blocking.
// The party stops ON it every time, and backing out of its text / fight / pop-over (leave, re-enter, flee, reload) never lets it walk on past;
// only its flag does. Optional pass=1 stops (mushroom camp, riddle stones) do not block. Run by treks.sh: php tests/trek_block.php GAME_DIR
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_ambush_pct', '0'); set_setting('trek_petals_daily', '5000'); set_setting('trek_entry_energy', '1');
setting('__reload__');
$n = 0;
function mkuser(int $ch): int
{
    global $n;
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $n++;
    $r['username'] = 't2018_' . $n . '_' . substr(md5((string)microtime(true)), 0, 5); $r['email'] = $r['username'] . '@b.local'; $r['gnome_name'] = 'Bea' . $n; $r['active_plot_id'] = null;
    $r['last_seen'] = now(); $r['level'] = 16; $r['coins'] = 5000; $r['energy'] = 900; $r['calling'] = null; $r['trek_ch'] = $ch; $r['trek_pet_day'] = null; $r['trek_pet_today'] = 0; $r['role'] = 'player';
    return db_insert('users', $r);
}

foreach ([1, 2] as $ch) {
    echo "== Chapter $ch: every blocking spot\n";
    $uid = mkuser($ch);
    $tx = fn(callable $f, bool $need = true) => trek_tx($uid, $f, $need, $ch);
    $run = fn() => trek_load(trek_run_row($uid, $ch));
    if ($ch === 2) {   // (a Chapter II run needs Chapter I's: carry-over party; a plain new run is enough for walking)
        q('UPDATE users SET trek_ch = 2 WHERE id = ?', [$uid]);
    }
    $tx(fn(&$run, $u) => trek_enter($run, $u), false);
    $spots = trek_spots($ch);
    $blockers = array_filter($spots, fn($s) => in_array($s['type'], ['duel', 'miniboss', 'boss', 'cart'], true) || ($s['type'] === 'riddle' && !empty($s['data']['failopen'])));
    ok("Chapter $ch has blocking spots", count($blockers) >= 2, implode(',', array_keys($blockers)));
    $mine = [];
    foreach ($spots as $c => $s) if (!empty($s['data']['flag'])) $mine[$c] = (string)$s['data']['flag'];
    foreach ($blockers as $code => $b) {
        $own = (string)($b['data']['flag'] ?? 'seen_' . $code);
        // fresh state for this spot: full fog, every gate's need open EXCEPT the flag this blocker itself sets, no fight, full health
        $setup = function (&$run, $u) use ($ch, $b, $own) {
            $run['sn'] = str_repeat("\xff", strlen($run['sn']));
            $run['inside'] = 1; $run['fi'] = null; $run['fatigue'] = 0;
            foreach (trek_spots($ch) as $s) {   // everything else is dealt with: gate needs, every other spot's flag, every sluice
                if ($s['type'] === 'gate' && !empty($s['data']['needs']) && $s['data']['needs'] !== $own) trek_flag_set($run, (string)$s['data']['needs']);
                if (!empty($s['data']['flag']) && $s['data']['flag'] !== $own) trek_flag_set($run, (string)$s['data']['flag']);
            }
            foreach (array_keys(trek_chapter($ch)['zones']) as $z) trek_flag_set($run, 'drained_' . $z);
            trek_flag_set($run, 'won_fight');
            db_delete_flag($run, $own);
            return [true, ''];
        };
        $tx($setup);
        $R = $run();
        $m = trek_map($ch); $w = $m['w'];
        $dist = trek_dist_from_start($R);
        $bi = $b['y'] * $w + $b['x'];
        if (!isset($dist[$bi])) { ok("$code reachable from the start (gates open)", false); continue; }
        $d = $dist[$bi];
        // tiles only reachable THROUGH the blocker (it as a wall): the "other side"
        $cut = [(int)trek_spots($ch)['start']['y'] * $w + (int)trek_spots($ch)['start']['x'] => 0]; $qq = [(int)trek_spots($ch)['start']['y'] * $w + (int)trek_spots($ch)['start']['x']];
        for ($qi = 0; $qi < count($qq); $qi++) {
            $cx = $qq[$qi] % $w; $cy = intdiv($qq[$qi], $w);
            foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
                $nx = $cx + $dx; $ny = $cy + $dy; $k = $ny * $w + $nx;
                if ($nx < 0 || $ny < 0 || $nx >= $w || $ny >= $m['h'] || isset($cut[$k]) || $k === $bi || !trek_passable($R, $nx, $ny)) continue;
                $cut[$k] = 1; $qq[] = $k;
            }
        }
        $other = array_diff_key($dist, $cut, [$bi => 1]);
        $before = $beyond = null;
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $k = ($b['y'] + $dy) * $w + $b['x'] + $dx;
            if (!isset($dist[$k])) continue;
            if ($dist[$k] === $d - 1 && !$before) $before = [$b['x'] + $dx, $b['y'] + $dy];
            if ($dist[$k] > $d && !$beyond) $beyond = [$b['x'] + $dx, $b['y'] + $dy];
            if (isset($other[$k])) $beyond = [$b['x'] + $dx, $b['y'] + $dy];
        }
        ok("$code has a tile before it", (bool)$before);
        if (!$before) continue;
        $pos = fn() => [$run()['x'], $run()['y']];
        // 1. a walk to a tile beyond (or the blocker itself) stops ON the blocker
        $tx(function (&$run, $u) use ($before) { $run['x'] = $before[0]; $run['y'] = $before[1]; return [true, '']; });
        $target = $beyond ?? [$b['x'], $b['y']];
        $far = null;   // the farthest tile on the other side (else the farthest of all), to also test a long walk through the blocker
        foreach ($other as $k => $dd) if ($far === null || $dd > $dist[$far[1] * $w + $far[0]]) $far = [$k % $w, intdiv($k, $w)];
        $far ??= $beyond ?? [$b['x'], $b['y']];
        ok("$code: has an other side to walk to" . ($other ? '' : ' (not a cut: farthest tile used)'), $far !== null);
        $r = $tx(fn(&$run, $u) => trek_walk($run, $u, $far[0], $far[1]));
        ok("$code: a long walk beyond stops ON it", $pos() === [$b['x'], $b['y']], json_encode($pos()) . ' ' . json_encode($r));
        // 2. abandon: leave and step back in, reload (nothing changes), flee a fight (challenge spots)
        $tx(fn(&$run, $u) => trek_leave($run));
        $tx(fn(&$run, $u) => trek_enter($run, $u), false);
        ok("$code: leave + re-enter keeps the party on it", $pos() === [$b['x'], $b['y']]);
        if (in_array($b['type'], ['duel', 'miniboss', 'boss'], true)) {
            $tx(fn(&$run, $u) => trek_act_challenge($run, $u));
            ok("$code: the fight started", (bool)$run()['fi']);
            $tx(function (&$run, $u) { $run['fi'] = null; unset($run['st']['bless']); return [true, '']; });   // what a successful Flee / a lost duel leaves: same tile, no flag
        }
        if ($b['type'] === 'riddle') $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 99));   // one wrong answer, then walk away
        if ($b['type'] === 'cart') $tx(function (&$run, $u) { trek_add_fatigue($run, 3); return [true, '']; });   // (a failed heave)
        ok("$code: abandoned, not dealt with", !trek_spot_done($run(), $b));
        unset($refused);
        // 3. try to walk on: refused, not moved
        foreach (array_filter([$beyond, $far]) as $t) {
            if ($t === [$b['x'], $b['y']]) continue;
            $r = $tx(fn(&$run, $u) => trek_walk($run, $u, $t[0], $t[1])); $refused = $r;
            ok("$code: cannot walk on to " . implode(',', $t), $r[0] === false && $pos() === [$b['x'], $b['y']], json_encode($r) . ' at ' . json_encode($pos()));
        }
        ok("$code: the refusal names it", !isset($refused) || str_contains((string)$refused[1], $b['name']), json_encode($refused ?? null));
        // 4. stepping back is fine, and walking in again stops on it again
        $r = $tx(fn(&$run, $u) => trek_walk($run, $u, $before[0], $before[1]));
        ok("$code: stepping back works", $r[0] === true && $pos() === $before, json_encode($pos()));
        $tx(fn(&$run, $u) => trek_walk($run, $u, $far[0], $far[1]));
        ok("$code: the next walk stops on it again", $pos() === [$b['x'], $b['y']]);
        // 5. dealt with: the way is open
        $tx(function (&$run, $u) use ($own) { trek_flag_set($run, $own); return [true, '']; });
        if ($beyond) {
            $r = $tx(fn(&$run, $u) => trek_walk($run, $u, $beyond[0], $beyond[1]));
            ok("$code: once its flag is set the party walks on", $r[0] === true && $pos() === $beyond, json_encode($r) . json_encode($pos()));
        }
    }
}

echo "== optional side stops do not block (pass=1) and gates still do\n";
$uid = mkuser(1);
$tx = fn(callable $f, bool $need = true) => trek_tx($uid, $f, $need, 1);
$run = fn() => trek_load(trek_run_row($uid, 1));
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$R = $run();
foreach (['mushcamp', 'bridgestone'] as $c) ok("$c never blocks", !trek_spot_blocks($R, trek_spots(1)[$c]));
foreach (['bracken', 'mother', 'gloomtooth', 'cart'] as $c) ok("$c blocks while undone", trek_spot_blocks($R, trek_spots(1)[$c]));
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);

function db_delete_flag(array &$run, string $flag): void
{
    q('DELETE FROM trek_flags WHERE run_id = ? AND flag = ?', [$run['id'], $flag]);
    unset($run['flags'][$flag]);
}
