<?php
// Delve redo torch sim (pure, no database). php claude/delve-torch-sim.php [runs] [fog]
// For every delve with chambers: walk random routes (4 stages), draw each floor the way the game does (authored pool first, else stamped
// chambers, else tm_gen), and measure the torch a player spends taking everything (dv_tour_cost: nearest-next tour, hazards cost 2) times
// a fog factor (walking blind adds detours; default 1.25). Compares that with DV_TORCH per tier and with candidate fuel tables.
// Target (plan): the torch is a soft timer. A thorough player should finish most floors lit, and run dark on some (about 1 in 6), never most.
$runs = (int)($argv[1] ?? 60);
$fog = (float)($argv[2] ?? 1.25);
$game = dirname(__DIR__) . '/game';
require $game . '/includes/delve_v2.php';
$slugs = array_values(array_unique(array_map(fn($c) => $c['slug'], ds_chambers())));
$cands = ['now' => DV_TORCH, 'A' => ['small' => 30, 'standard' => 45, 'large' => 60], 'B' => ['small' => 32, 'standard' => 48, 'large' => 64], 'C' => ['small' => 35, 'standard' => 50, 'large' => 65], 'D' => ['small' => 28, 'standard' => 42, 'large' => 50], 'E' => ['small' => 30, 'standard' => 42, 'large' => 50]];
$need = [];   // tier => [torch needed, ...]
$per = [];    // slug => [tier => [needed]]
foreach ($slugs as $slug) {
    if ($slug === 'any') continue;
    for ($i = 0; $i < $runs; $i++) {
        $route = dv_route("sim$i", $slug, 4);
        $rng = tm_rng("path$i|$slug");
        $at = null;
        $used = [];
        for ($row = 0; $row < 4; $row++) {
            $ch = dv_route_choices($route, $at);
            $at = $ch[$rng(0, count($ch) - 1)];
            $n = dv_route_node($route, $at);
            if (!dv_node_has_floor($n)) continue;
            $pick = dv_floor_pick($route, $at, $used, $i % 5 === 0);
            if ($pick['src'] === 'pool') { $used[] = $pick['key']; $f = dv_floors()[$pick['key']]; $map = $f['map']; $tier = $f['tier']; }
            else { $tier = $n['tier']; $map = dv2_gen_floor("sim$i|$at", $tier, $n['kind'], $slug); }
            $t = (int)ceil(dv_tour_cost($map) * $fog);
            $need[$tier][] = $t;
            $per[$slug][$tier][] = $t;
        }
    }
}
$pct = function (array $a, float $p) { sort($a); return $a[(int)floor((count($a) - 1) * $p)]; };
echo "torch needed to take everything (tour x $fog), all delves, $runs routes each\n";
foreach (['small', 'standard', 'large'] as $tier) {
    $a = $need[$tier] ?? [];
    if (!$a) continue;
    printf("  %-8s n=%4d  mean %5.1f  median %3d  p84 %3d  p95 %3d  max %3d\n", $tier, count($a), array_sum($a) / count($a), $pct($a, .5), $pct($a, .84), $pct($a, .95), max($a));
}
echo "\nshare of floors where a thorough player runs dark (needed > fuel), lantern 0 / lantern 1 (+" . DV2_TORCH_LANTERN . ")\n";
foreach ($cands as $name => $fuel) {
    $line = sprintf('  %-4s %-28s', $name, json_encode(array_values($fuel)));
    foreach (['small', 'standard', 'large'] as $tier) {
        $a = $need[$tier] ?? [];
        if (!$a) continue;
        $d0 = count(array_filter($a, fn($x) => $x > $fuel[$tier])) / count($a);
        $d1 = count(array_filter($a, fn($x) => $x > $fuel[$tier] + DV2_TORCH_LANTERN)) / count($a);
        $line .= sprintf('  %s %3d%% / %3d%%', $tier, round(100 * $d0), round(100 * $d1));
    }
    echo $line . "\n";
}
echo "\nper delve, mean needed (small / standard / large)\n";
ksort($per);
foreach ($per as $slug => $t) {
    $m = fn($k) => isset($t[$k]) ? sprintf('%5.1f', array_sum($t[$k]) / count($t[$k])) : '    -';
    printf("  %-26s %s / %s / %s\n", $slug, $m('small'), $m('standard'), $m('large'));
}
$lint = [];
foreach ($cands as $name => $fuel) {
    $bad = 0;
    foreach (dv_floors() as $f) if (dv_tour_cost($f['map']) > (int)floor($fuel[$f['tier']] * DV_TORCH_SLACK)) $bad++;
    $lint[] = "$name $bad";
}
echo "\nauthored floors that would fail the lint (tour > fuel x " . DV_TORCH_SLACK . "): " . implode(', ', $lint) . "\n";
