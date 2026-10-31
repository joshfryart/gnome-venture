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
if ($cmd === 'hazard' || $cmd === 'wander') {   // in-process checks on authored floors: hazard ground effects, wandering creatures
    $u = q_one('SELECT * FROM users WHERE id = ?', [(int)$exp['user_id']]);
    $cfg = function (array $kv): void { foreach ($kv as $k => $v) { q('DELETE FROM settings WHERE name = ?', [$k]); q('INSERT INTO settings (name, value) VALUES (?, ?)', [$k, (string)$v]); } setting('__reload__'); };
    $put = function (string $key) use (&$sc, &$exp): void {
        $f = dv_floors()[$key];
        $sc['st']['f'] = ['k' => $key, 'ti' => $f['tier'], 'kd' => $f['for'][0], 'n' => '0.0', 't' => 30, 'got' => [], 'key' => 0];
        $sc['map'] = $f['map'];
        [$sc['x'], $sc['y']] = $sc['map']['entry'];
        $sc['seen'] = str_repeat('f', (int)ceil($sc['map']['w'] * $sc['map']['h'] / 4));
        $exp['encounter'] = null;
        $exp['status'] = 'active';
    };
    if ($cmd === 'hazard') {
        $cfg(['dv_enc_chance' => 0]);
        $put('beaverdam-tunnels/flooded_pool');   // S at 1,1; 2,3 is water: the walk is 1,2 1,3 2,3
        $sc['lm']['name'] = 'Beaverdam Tunnels';
        $fx = dv_hazard_fx('beaverdam-tunnels', dv2_level($sc, $exp));
        $pth = tm_path($sc['map'], $sc['x'], $sc['y'], 2, 3, dv2_gate($sc, 2, 3));
        $wet = count(array_filter($pth, fn($p) => tm_tile($sc['map'], $p[0], $p[1]) === 'W'));
        $cost = array_sum(array_map(fn($p) => dv_step_cost(tm_tile($sc['map'], $p[0], $p[1])), $pth));
        [$ok, $msg] = dv2_walk($u, $exp, $sc, 2, 3);
        ok('torch hazard: walking into water burns the step cost plus the effect a tile', $wet > 0 && $ok && $sc['st']['f']['t'] === 30 - $cost - $fx['n'] * $wet, 'torch ' . $sc['st']['f']['t'] . " cost $cost wet $wet fx " . $fx['n']);
        ok('torch hazard: the walk says what happened (flash text + log)', $ok && strpos($msg, '🔦') !== false && strpos((string)$exp['log'], 'soaks your boots') !== false, $msg);
        [$ok2, $msg2] = dv2_walk($u, $exp, $sc, 1, 4);
        ok('plain ground says nothing', $ok2 && $msg2 === '', $msg2);
        $put('beaverdam-tunnels/flooded_pool');
        $sc['lm']['name'] = 'Fynbos Fire Trails';
        $fx = dv_hazard_fx('fynbos-fire-trails', dv2_level($sc, $exp));
        $exp['hp'] = 50; $exp['max_hp'] = 50;
        [$ok, $msg] = dv2_walk($u, $exp, $sc, 2, 3);
        ok('health hazard: embers cost health a tile', $ok && (int)$exp['hp'] === 50 - $fx['n'] * $wet && strpos($msg, '❤️') !== false, $exp['hp'] . ' ' . $msg);
        $put('beaverdam-tunnels/flooded_pool');
        $exp['hp'] = 1;
        dv2_walk($u, $exp, $sc, 2, 3);
        ok('health hazard never knocks you out (stays at 1)', (int)$exp['hp'] === 1);
        ok('every delve has a hazard effect of a known kind', !array_filter(DV_HAZARD_FX, fn($v) => !in_array($v[0], ['hp', 'torch'], true) || $v[1] < 1) && count(DV_HAZARD_FX) === count(DV_HAZARD));
        $cfg(['dv_enc_chance' => 25]);
    } else {
        $cfg(['dv_enc_steps' => 1, 'dv_enc_chance' => 100, 'dv_enc_cap' => 1]);
        $put('salt-mine-galleries/rail_gallery');   // S at 1,1, a straight corridor east along row 1
        [$ok, $msg] = dv2_walk($u, $exp, $sc, 10, 1);
        $enc = json_decode((string)$exp['encounter'], true);
        ok('a wandering creature stops the walk (not next to the way in)', $ok && $sc['x'] === 3 && $sc['y'] === 1, $sc['x'] . ',' . $sc['y']);
        ok('it is a fight from the delve’s own creatures', ($enc['type'] ?? '') === 'creature' && strpos($msg, 'jumps out') !== false, json_encode($enc) . ' ' . $msg);
        $lv = (int)$exp['level']; $stage = dv2_level($sc, $exp);
        ok('its level sits between the stage and the gnome (stage-2 .. stage+3)', $lv >= $stage - 2 && $lv <= $stage + 3, "lv $lv stage $stage gnome " . $u['level']);
        $exp['encounter'] = null;
        dv2_walk($u, $exp, $sc, 10, 1);
        ok('the cap per floor holds (1)', !$exp['encounter'] && $sc['x'] === 10 && (int)$sc['st']['f']['ec'] === 1);
        $cfg(['dv_enc_cap' => 5]);
        $put('salt-mine-galleries/rail_gallery');
        $at = [];
        for ($k = 0; $k < 6 && $sc['x'] < 10; $k++) { dv2_walk($u, $exp, $sc, 10, 1); if ($exp['encounter']) $at[] = $sc['x']; $exp['encounter'] = null; }
        $gap = true; for ($k = 1; $k < count($at); $k++) if ($at[$k] - $at[$k - 1] < 2) $gap = false;
        ok('never two in a row: a roll is skipped after each creature (' . implode(',', $at) . ')', count($at) >= 2 && $gap);
        $put('salt-mine-galleries/salt_throne');   // the guardian's floor
        $sc['st']['f']['kd'] = 'boss';
        dv2_walk($u, $exp, $sc, 5, 1);
        ok('no wandering creatures on the guardian’s floor', !$exp['encounter'] && $sc['x'] === 5);
        $cfg(['dv_enc_chance' => 0]);
        $put('salt-mine-galleries/rail_gallery');
        dv2_walk($u, $exp, $sc, 10, 1);
        ok('chance 0 = none', !$exp['encounter'] && $sc['x'] === 10);
        $cfg(['dv_enc_steps' => 6, 'dv_enc_chance' => 25, 'dv_enc_cap' => 2]);
    }
    echo $fails ? "FAILED: $fails\n" : "all $cmd checks passed\n";
    exit($fails ? 1 : 0);
}
echo "unknown command\n";
exit(1);
