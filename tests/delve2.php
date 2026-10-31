<?php
// v2.3.1 delve redo engine.  php tests/delve2.php unit GAME_DIR | tap GAME_DIR EXP | state GAME_DIR EXP
$cmd = $argv[1] ?? 'unit';
$game = $argv[2] ?? dirname(__DIR__) . '/game';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

if ($cmd === 'unit') {
    require $game . '/includes/delve_route.php';
    echo "== generated floors (every node kind, every tier, 60 seeds)\n";
    require_once $game . '/includes/tilemap.php';
    // delve_v2.php needs the game; load only the pure bits by evaluating the function bodies we need
    $src = file_get_contents($game . '/includes/delve_v2.php');
    preg_match('/const DV2_GEN = \[.*?\];/s', $src, $m1); eval($m1[0]);
    preg_match('/function dv2_gen_floor\(.*?\n}\n/s', $src, $m2); eval($m2[0]);
    $bad = [];
    $n = 0;
    foreach (DV2_GEN as $kind => $objs) {
        foreach ($kind === 'boss' ? ['standard', 'large'] : ['small', 'standard'] as $tier) {
            for ($i = 0; $i < 60; $i++) {
                $map = dv2_gen_floor("s$i|$kind", $tier, $kind);
                $n++;
                $count = fn(string $c) => count(dv_find_all($map, $c));
                $want = array_count_values($objs);
                foreach (['F', 'T', 'C', 'E', 'B'] as $c) if ($count($c) !== ($want[$c] ?? 0)) $bad[] = "$kind/$tier/$i: $c x" . $count($c);
                if (count(dv_finds($map)) !== ($want['1'] ?? 0)) $bad[] = "$kind/$tier/$i: finds " . count(dv_finds($map));
                $f = ['tier' => $tier, 'rule' => 'x', 'for' => [$kind], 'rows' => $map['t'], 'map' => $map];
                $b = dv_floor_lint($f);
                if ($b) $bad[] = "$kind/$tier/$i: " . implode('; ', $b);
            }
        }
    }
    ok("$n generated floors have the right objects and pass the floor lint", !$bad, json_encode(array_slice($bad, 0, 4)));
    ok('generated floor is deterministic', dv2_gen_floor('a', 'small', 'fight') === dv2_gen_floor('a', 'small', 'fight'));
    echo $fails ? "\nFAILED: $fails\n" : "\nall unit tests passed\n";
    exit($fails ? 1 : 0);
}

$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $game . '/includes/bootstrap.php';
require_once $game . '/includes/adventure.php';
$exp = q_one('SELECT * FROM expeditions WHERE id = ?', [(int)($argv[3] ?? 0)]);
if (!$exp) { echo "no such expedition\n"; exit(1); }
$sc = dv2_scene($exp);
if (!$sc) { echo "none\n"; exit(0); }
if ($cmd === 'state') { echo json_encode(['st' => $sc['st'], 'x' => $sc['x'], 'y' => $sc['y'], 'depth' => (int)$exp['depth'], 'steps' => (int)$exp['steps_total'], 'key' => $sc['row']['map_key']]) . "\n"; exit(0); }
if ($cmd === 'light') {   // light the whole floor (so only the rules, not the fog, decide what a tap does)
    if ($sc['map']) q('UPDATE walk_scene SET seen = ? WHERE id = ?', [str_repeat('f', (int)ceil($sc['map']['w'] * $sc['map']['h'] / 4)), $sc['row']['id']]);
    exit(0);
}
if ($cmd === 'tap') {   // what to tap next: menu | quick | the nearest live object (the way down / guardian last), as "x,y kind"
    if (!$sc['map']) { echo ($sc['st']['q'] ? 'quick' : 'menu ' . implode(',', dv_route_choices($sc['route'], $sc['st']['at']))) . "\n"; exit(0); }
    $map = $sc['map'];
    $reach = tm_reach($map, $sc['x'], $sc['y'], dv2_gate($sc));
    $best = null;
    foreach (['digit', 'K', 'F', 'T', 'M', 'C', 'B', 'E'] as $rank => $kind) {
        for ($y = 0; $y < $map['h']; $y++) for ($x = 0; $x < $map['w']; $x++) {
            $t = $map['t'][$y][$x];
            $isKind = $kind === 'digit' ? ctype_digit($t) : $t === $kind;
            if (!$isKind || !dv2_live($sc, $x, $y)) continue;
            if ($t === 'C' && dv2_boss_floor($sc) && !dv2_boss_down($sc)) continue;
            $near = false;
            foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) if (isset($reach[($y + $dy) * $map['w'] + $x + $dx]) || ($x + $dx === $sc['x'] && $y + $dy === $sc['y'])) $near = true;
            if ($x === $sc['x'] && $y === $sc['y']) $near = true;
            if (!$near) continue;
            if ($best === null) $best = [$rank, $x, $y, $t];
        }
        if ($best !== null && $kind !== 'digit') break;
        if ($best !== null && $kind === 'digit') break;
    }
    echo $best ? $best[1] . ',' . $best[2] . ' ' . $best[3] . "\n" : "stuck\n";
    exit(0);
}
echo "unknown command\n";
exit(1);
