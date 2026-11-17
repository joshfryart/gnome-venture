<?php
// 2.7.08 Trail engine: the side-trail heading rule (region_layout.php rl_trail_heading), the region map art sync check (tools/map_layout.php --check:
// the art scripts' copy of the layout, tools/map_layout.lua, matches the game), and the gates outside the Maplewold (first pass, Josh 2026-11-14 tiers).
// php tests/region_trails_gates.php GAME_DIR   (an installed game; walk.sh installs one)
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/maps.php';
require_once $argv[1] . '/includes/region_layout.php';
require_once $argv[1] . '/includes/trail_art.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

echo "== heading rule: pure parts\n";
ok('rl_heading8 snaps to 8 screen headings (y down)', rl_heading8(1, 0) === 'E' && rl_heading8(0, 1) === 'S' && rl_heading8(-1, 0) === 'W' && rl_heading8(0, -1) === 'N' && rl_heading8(1, 1) === 'SE' && rl_heading8(-1, -1) === 'NW' && rl_heading8(1, 0.3) === 'E');
$roads = [['nodes' => [1, 2, 3], 'pts' => [[0, 0], [100, 0], [200, 0]]]];   // a road running east through stop 2 at (100, 0)
$s = rl_trail_heading($roads, 2, [100, 0], [100, 40]);   // a place to the south: to the right of an eastbound road
ok('a place right of the road: bow R, the first leg leans along the road (SE), ctrl pushed forward', $s['bow'] === 'R' && $s['heading'] === 'SE' && $s['ctrl'] === [110, 20], json_encode($s));
$n = rl_trail_heading($roads, 2, [100, 0], [100, -40]);
ok('a place left of the road: bow L, heading NE', $n['bow'] === 'L' && $n['heading'] === 'NE', json_encode($n));
$e = rl_trail_heading($roads, 3, [200, 0], [200, 40]);
ok('at a road\'s last stop the way in counts as forward', $e['bow'] === 'R' && $e['heading'] === 'SE', json_encode($e));
$z = rl_trail_heading([], 9, [0, 0], [0, 40]);
ok('a stop on no road: the chord heading, bow R', $z['bow'] === 'R' && $z['heading'] === 'S', json_encode($z));

echo "== heading rule: every side trail of every region\n";
$bad = []; $n = 0;
foreach (q('SELECT code FROM regions ORDER BY id')->fetchAll(PDO::FETCH_COLUMN) as $code) {
    $L = region_layout((string)$code); if (!$L) continue;
    foreach ($L['trails'] as $t) { $n++;
        if (count($t['pts']) !== 2 || !in_array($t['bow'] ?? '', ['L', 'R'], true) || !in_array($t['heading'] ?? '', RL_HEADINGS, true) || count($t['ctrl'] ?? []) !== 2) $bad[] = $code . ':' . $t['from'] . '>' . $t['to'];
    }
}
ok("all $n side trails have a bow, a heading and a control point, and the drawn line stays straight (the art)", $n > 100 && !$bad, implode(', ', array_slice($bad, 0, 5)));

echo "== region map art sync\n";
$out = []; exec('php ' . escapeshellarg(dirname(__DIR__) . '/tools/map_layout.php') . ' --check ' . escapeshellarg($argv[1]) . ' 2>&1', $out, $rc);
ok('tools/map_layout.lua (what the region map art is drawn from) matches the game\'s region layouts', $rc === 0, implode(' ', $out));
$lua = (string)file_get_contents(dirname(__DIR__) . '/tools/map_layout.lua');
ok('the dump carries the trail bends for the art and the Trail map generator', str_contains($lua, 'trail_bends') && str_contains($lua, 'heading = "'));

echo "== gates outside the Maplewold (first pass; Josh 2026-11-14: NA CA NWE CB SE SA EE tier 2, the rest tier 3)\n";
$low = ['na', 'ca', 'nwe', 'cb', 'se', 'sa', 'ee'];
$files = glob($argv[1] . '/includes/data/trail_maps/*_30x18.json');
$per = []; $wrong = []; $bad = [];
foreach ($files as $f) {
    $reg = basename($f, '_30x18.json'); if ($reg === 'maplewold') continue;
    $j = json_decode((string)file_get_contents($f), true);
    foreach ($j['routes'] as $rid => $r) {
        if (!trail_authored_valid($r)) { $bad[] = $reg . '/' . $rid; continue; }
        foreach ($r['sections'] as $sec) foreach ($sec['gates'] ?? [] as $g) {
            $per[$reg] = ($per[$reg] ?? 0) + 1;
            if ((int)$g['min_tier'] !== (in_array($reg, $low, true) ? 2 : 3)) $wrong[] = $reg . '/' . $rid;
            $closed = trail_gates_closed(['gates' => [$g]], fn($t) => 0); $open = trail_gates_closed(['gates' => [$g]], fn($t) => 4);
            if (count($closed) !== count($g['tiles']) || $open) $wrong[] = $reg . '/' . $rid . ' (closing)';
        }
    }
}
ok('every region file outside the Maplewold has gates (14 regions, 1 to 3 each)', count($per) === 14 && min($per) >= 1 && max($per) <= 3, json_encode($per));
ok('every gated route is a valid authored route', !$bad, implode(', ', $bad));
ok('gate tiers follow the region rule, and a gate shuts without the tool and opens with it', !$wrong, implode(', ', array_slice($wrong, 0, 5)));

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
