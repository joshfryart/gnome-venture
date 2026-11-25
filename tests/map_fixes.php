<?php
// 2.8.53 Map fixes: (1) the walking hat (player_map_pos) follows the road's drawn curve; (2) the go-card compass (compass_between) agrees with the region map
// (region_layout slots, rl_heading8); (3) road stops clamped to a region's edge are spread along the road instead of piling up.
// php tests/map_fixes.php GAME_DIR   (an installed game with player "sprout"; walk.sh installs one)
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/maps.php';
require_once $argv[1] . '/includes/region_layout.php';
require_once $argv[1] . '/includes/adventure.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
/** distance from a point to the road's drawn curve (sampled) */
function curve_dist(array $a, array $b, array $p): float
{
    $c = road_ctrl($a, $b); $best = 1e9;
    for ($k = 0; $k <= 400; $k++) { [$x, $y] = map_bez($a, $c, $b, $k / 400); $best = min($best, hypot($x - $p[0], $y - $p[1])); }
    return $best;
}

$P = map_positions();
$roads = q('SELECT id, nodes FROM roads ORDER BY id')->fetchAll();

echo "== 3: stops are spread along the road\n";
$off = []; $tight = []; $n = 0;
foreach ($roads as $rd) {
    $nodes = array_map('intval', json_decode((string)$rd['nodes'], true) ?: []); $c = count($nodes);
    if ($c < 3 || !isset($P[$nodes[0]], $P[$nodes[$c - 1]])) continue;
    for ($i = 1; $i < $c - 1; $i++) {
        $n++;
        if (curve_dist($P[$nodes[0]], $P[$nodes[$c - 1]], $P[$nodes[$i]]) > 14) $off[] = $rd['id'] . ':' . $nodes[$i];
        if ($i >= 2 && hypot($P[$nodes[$i]][0] - $P[$nodes[$i - 1]][0], $P[$nodes[$i]][1] - $P[$nodes[$i - 1]][1]) < 12) $tight[] = $rd['id'] . ':' . $nodes[$i];
    }
}
ok("all $n road stops sit within 14 units of their road's drawn curve", $n > 50 && !$off, implode(', ', array_slice($off, 0, 6)));
ok('no two neighbouring road stops are closer than 12 units', !$tight, implode(', ', array_slice($tight, 0, 6)));

echo "== 2: the card compass matches the region map\n";
$bad = []; $cmp = 0; $seen = []; $heads = [];   // a stop on a road shared by two towns is a slot of both regions' maps: any region map that draws the trail may be the one on screen
foreach (q('SELECT code FROM regions ORDER BY id')->fetchAll(PDO::FETCH_COLUMN) as $code) {
    $L = region_layout((string)$code); if (!$L) continue;
    foreach ($L['trails'] as $t) {
        $a = $L['slots'][$t['from']]; $b = $L['slots'][$t['to']];
        $heads[$t['from'] . '>' . $t['to']][] = rl_heading8((float)($b['x'] - $a['x']), (float)($b['y'] - $a['y']));
    }
}
foreach ($heads as $k => $want) {
    [$f, $t] = array_map('intval', explode('>', $k)); $cmp++;
    $got = compass_between($f, $t); $seen[$got] = true;
    if (!in_array($got, $want, true)) $bad[] = "$k $got/" . implode('|', $want);
}
ok("compass_between = rl_heading8 of the region slots on all $cmp side paths", $cmp > 100 && !$bad, implode(', ', array_slice($bad, 0, 5)));
ok('headings are the 8 compass words', !array_diff(array_keys($seen), RL_HEADINGS), implode(',', array_keys($seen)));
$rd0 = array_map('intval', json_decode((string)$roads[0]['nodes'], true));
ok('and back the other way is the opposite heading on a road', compass_between($rd0[0], $rd0[1]) !== '' && compass_between($rd0[1], $rd0[0]) !== compass_between($rd0[0], $rd0[1]));
ok('same place: empty', compass_between($rd0[0], $rd0[0]) === '');

echo "== 1: the walking hat follows the road curve\n";
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
ok('test player exists', (bool)$u);
$worst = 0.0; $legs = 0; $maxLeg = 0.0;
foreach ($roads as $rd) {
    $nodes = array_map('intval', json_decode((string)$rd['nodes'], true) ?: []); $c = count($nodes);
    if ($c < 3 || !isset($P[$nodes[0]], $P[$nodes[$c - 1]])) continue;
    for ($i = 0; $i < $c - 1; $i++) {
        foreach ([0, 2] as $step) {
            q('DELETE FROM expeditions WHERE user_id = ?', [$u['id']]);
            q("INSERT INTO expeditions (user_id, from_id, to_id, route_id, steps_total, step, hp, max_hp, status, started_at, arrive_at) VALUES (?, ?, ?, 0, 4, ?, 10, 10, 'active', ?, ?)",
                [$u['id'], $nodes[$i], $nodes[$i + 1], $step, date('Y-m-d H:i:s'), date('Y-m-d H:i:s', time() + 600)]);
            $me = player_map_pos($u); $legs++;
            $worst = max($worst, curve_dist($P[$nodes[0]], $P[$nodes[$c - 1]], $me));
        }
        $maxLeg = max($maxLeg, hypot($P[$nodes[$i + 1]][0] - $P[$nodes[$i]][0], $P[$nodes[$i + 1]][1] - $P[$nodes[$i]][1]));
    }
}
q('DELETE FROM expeditions WHERE user_id = ?', [$u['id']]);
ok("hat is within 2 units of the road curve at $legs sampled points (longest leg " . round($maxLeg) . ')', $legs > 100 && $worst <= 2.0, 'worst ' . round($worst, 1));
echo $fails ? "FAILED $fails\n" : "ok\n";
exit($fails ? 1 : 0);
