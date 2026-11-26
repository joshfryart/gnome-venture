<?php
// 2.8.74 ROUTE IDS: a fresh install lays the roads with the same routes.id numbering the map data is keyed by (228-473, no 239).
// The ROAD_DEAD_ENDS leg (Clovercove to Blossomreach Market) takes id 239 and is deleted again, as cut_dead_end_roads used to do.
// php tests/route_ids.php GAME_DIR   (an installed game; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trail_art.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$name = fn(int $id): string => (string)q_val('SELECT name FROM locations WHERE id = ?', [$id]);
$rt = fn(int $id) => q_one('SELECT a_id, b_id FROM routes WHERE id = ?', [$id]);

echo "== route ids\n";
ok('no route 239', !$rt(239));
ok('no route Clovercove to Blossomreach Market', !q_val("SELECT 1 FROM routes r JOIN locations a ON a.id = r.a_id JOIN locations b ON b.id = r.b_id WHERE a.name = 'Clovercove' AND b.name = 'Blossomreach Market'"));
$r = $rt(240); ok('240 = Maizehollow Market to Meadowmere', $r && $name((int)$r['a_id']) === 'Maizehollow Market' && $name((int)$r['b_id']) === 'Meadowmere');
$r = $rt(241); ok('241 = Meadowmere to Shoreford', $r && $name((int)$r['a_id']) === 'Meadowmere' && $name((int)$r['b_id']) === 'Shoreford');
ok('245 routes', (int)q_val('SELECT COUNT(*) FROM routes') === 245, (string)q_val('SELECT COUNT(*) FROM routes'));
ok('ids 228-473', (int)q_val('SELECT MIN(id) FROM routes') === 228 && (int)q_val('SELECT MAX(id) FROM routes') === 473);
$rd = q_one("SELECT b_town, nodes FROM roads WHERE name = ?", [(string)q_val("SELECT gnomish_name FROM regions WHERE code = 'NA'") . ' – Clovercove']);
ok('dead-end road ends at Clovercove, nodes without the far town', $rd && $name((int)$rd['b_town']) === 'Clovercove' && (int)array_slice(json_decode($rd['nodes'], true), -1)[0] === (int)$rd['b_town']);

echo "== authored maps match the routes\n";
$bad = []; $n = 0;
foreach (trail_authored_all() as $id => $a) {
    if ((int)$id === 239) continue;   // the authored data still holds the cut dead-end leg
    $n++;
    $r = $rt((int)$id);
    if (!$r) { $bad[] = "$id missing"; continue; }
    if ($name((int)$r['a_id']) !== ($a['from'] ?? '') || $name((int)$r['b_id']) !== ($a['to'] ?? '')) $bad[] = "$id " . $name((int)$r['a_id']) . ' > ' . $name((int)$r['b_id']) . " vs " . ($a['from'] ?? '?') . ' > ' . ($a['to'] ?? '?');
}
ok("all $n authored routes match by from/to", $n > 0 && !$bad, implode('; ', array_slice($bad, 0, 8)) . ' (' . count($bad) . ')');
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
