<?php
// 2.7.50: the villages of the Maplewold's dead-end road (Honeythorpe, Clovercove) belong to the Maplewold: region, zone, world map position, region map stops, Routes popover map.
// php tests/dead_end_owned.php GAME_DIR   (an installed game; walk.sh installs one)
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/maps.php';
require_once $argv[1] . '/includes/region_layout.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$na = (int)q_val("SELECT id FROM regions WHERE code = 'NA'");
$hid = (int)q_val("SELECT id FROM locations WHERE name = 'Honeythorpe'"); $cid = (int)q_val("SELECT id FROM locations WHERE name = 'Clovercove'");
foreach ([$hid, $cid] as $id) {
    $l = q_one('SELECT l.*, z.region_id AS zr FROM locations l LEFT JOIN zones z ON z.id = l.zone_id WHERE l.id = ?', [$id]);
    ok($l['name'] . ' is a village of The Maplewold (region_id, region text, zone)', (int)$l['region_id'] === $na && $l['region'] === 'The Maplewold' && (int)$l['zr'] === $na, json_encode([$l['region_id'], $l['region'], $l['zr']]));
}
$bram = q_one("SELECT region_id FROM locations WHERE name = 'Brambleburrow'");
ok('Brambleburrow (a side place off Honeythorpe) stays in Blossomreach', (int)$bram['region_id'] !== $na);
$road = q_one("SELECT nodes, name FROM roads WHERE name LIKE '%Clovercove'");
ok('the road is still the Maplewold market, Cloverholt, Honeythorpe, Clovercove', $road && count(json_decode($road['nodes'], true)) === 4, json_encode($road));
$P = map_positions(); $c = REGION_MAP['NA'];
foreach ([$hid, $cid] as $id) { $d = hypot($P[$id][0] - $c[0], $P[$id][1] - $c[1]); ok("world map: stop $id sits inside The Maplewold's disc", $d <= $c[3] * 1.0 + 1, (string)$d); }
$LN = region_layout('NA'); $LE = region_layout('EA');
ok('The Maplewold map draws both as road stops', ($LN['slots'][$hid]['type'] ?? '') === 'stop' && ($LN['slots'][$cid]['type'] ?? '') === 'stop', json_encode([$LN['slots'][$hid] ?? null]));
ok('Blossomreach map no longer carries them', !isset($LE['slots'][$hid]) && !isset($LE['slots'][$cid]));
$before = q_val("SELECT region_id FROM locations WHERE id = $hid");
require_once $argv[1] . '/includes/roads.php'; set_setting('road_deadends_owned', '0'); own_dead_end_villages();
ok('running the migration again changes nothing', (int)q_val("SELECT region_id FROM locations WHERE id = $hid") === (int)$before && (string)q_val("SELECT region FROM locations WHERE id = $hid") === 'The Maplewold');
echo $fails ? "$fails FAILED\n" : "ok\n"; exit($fails ? 1 : 0);
