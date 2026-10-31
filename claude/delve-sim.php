<?php
// Delve redo balance sim (pure, no database). php claude/delve-sim.php [runs]
// New: a random path through a route of generated floors (what an unauthored delve plays today). Old: five rooms by the old rolls.
// Counts per run: fights (guardian included), traps, finds (a give_find each; a floor chest = 2 finds, an old find room = 2), torch steps taken, minutes (steps x 1.5 s + 8 s per object, a guess).
$runs = (int)($argv[1] ?? 300);
$game = dirname(__DIR__) . '/game';
require $game . '/includes/delve_route.php';
$src = file_get_contents($game . '/includes/delve_v2.php');
preg_match('/const DV2_GEN = \[.*?\];/s', $src, $m1); eval($m1[0]);
preg_match('/function dv2_gen_floor\(.*?\n}\n/s', $src, $m2); eval($m2[0]);
function sim_new(int $i, int $stages): array
{
    $route = dv_route("sim$i", 'd', $stages);
    $rng = tm_rng("path$i");
    $at = null;
    $r = ['fights' => 0, 'traps' => 0, 'finds' => 0, 'steps' => 0, 'objs' => 0, 'fuel' => 0, 'over' => 0];
    for ($row = 0; $row < $stages; $row++) {
        $ch = dv_route_choices($route, $at);
        $at = $ch[$rng(0, count($ch) - 1)];
        $n = dv_route_node($route, $at);
        if (!dv_node_has_floor($n)) { $r['finds'] += $n['kind'] === 'mole' ? 1 : 0; continue; }
        $map = dv2_gen_floor("sim$i|$at", $n['tier'], $n['kind']);
        $steps = dv_tour_cost($map);
        $r['steps'] += $steps;
        $r['fuel'] += DV_TORCH[$n['tier']];
        $r['over'] += max(0, $steps - DV_TORCH[$n['tier']]);
        foreach (['F', 'B'] as $c) $r['fights'] += count(dv_find_all($map, $c));
        $r['traps'] += count(dv_find_all($map, 'T'));
        $r['finds'] += count(dv_finds($map)) + ($n['kind'] === 'boss' ? 0 : 2 * count(dv_find_all($map, 'C')));   // the guardian's chest is the delve chest, not 2 finds
        $r['objs'] += count(dv_finds($map)) + count(dv_find_all($map, 'F')) + count(dv_find_all($map, 'T')) + count(dv_find_all($map, 'C')) + 1;
    }
    return $r;
}
function sim_old(): array
{
    $r = ['fights' => 0, 'traps' => 0, 'finds' => 0, 'rooms' => 5];
    for ($room = 1; $room <= 5; $room++) {
        $roll = random_int(1, 100);
        if ($room === 5 || $roll <= 45) $r['fights']++;
        elseif ($roll <= 70) $r['traps']++;
        else $r['finds'] += 2;
    }
    return $r;
}
$avg = function (array $rows, string $k) { return round(array_sum(array_column($rows, $k)) / max(1, count($rows)), 2); };
foreach ([3, 4] as $st) {
    $a = []; for ($i = 0; $i < $runs; $i++) $a[] = sim_new($i, $st);
    $mins = round(($avg($a, 'steps') * 1.5 + $avg($a, 'objs') * 8) / 60, 1);
    echo "NEW $st stages: fights {$avg($a,'fights')}  traps {$avg($a,'traps')}  finds {$avg($a,'finds')}  steps {$avg($a,'steps')} (fuel {$avg($a,'fuel')}, over by {$avg($a,'over')})  about $mins min\n";
}
$o = []; for ($i = 0; $i < $runs * 3; $i++) $o[] = sim_old();
echo "OLD 5 rooms:    fights {$avg($o,'fights')}  traps {$avg($o,'traps')}  finds {$avg($o,'finds')}  (and 1 energy a room)\n";
