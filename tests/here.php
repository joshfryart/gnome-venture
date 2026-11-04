<?php
// Graphical navigation helpers. php tests/here.php GAMEDIR        (pure helpers + layouts; no database needed)
//                                php tests/here.php GAMEDIR db     (also the DB-backed parts; needs an installed game, player "sprout")
$game = $argv[1] ?? dirname(__DIR__) . '/game';
$withDb = in_array('db', $argv, true);
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
if ($withDb) { $_SERVER['SCRIPT_NAME'] = '/here.php'; require $game . '/includes/bootstrap.php'; }
else { function e($v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); } }
require_once $game . '/includes/here_layout.php';

echo "== perspective\n";
$L = ['h' => 270, 'horizon' => 112];
$prev = -1.0; $mono = true; $zmono = true; $pz = -1;
for ($y = 112; $y <= 270; $y += 6) { $p = here_persp($L, $y); if ($p['scale'] < $prev) $mono = false; if ($p['z'] < $pz) $zmono = false; $prev = $p['scale']; $pz = $p['z']; }
ok('scale never shrinks going down the picture', $mono);
ok('z follows feet y', $zmono);
ok('far end 0.75, near end 1.25', here_persp($L, 112)['scale'] === 0.75 && here_persp($L, 270)['scale'] === 1.25);
ok('above the horizon clamps to far', here_persp($L, 0)['scale'] === 0.75);
ok('works for another canvas size', here_persp(['h' => 540, 'horizon' => 224], 540)['scale'] === 1.25);

echo "== bearing\n";
$o = ['x' => 100, 'y' => 100];
ok('north', abs(here_bearing($o, ['x' => 100, 'y' => 50]) - 0) < 0.01);
ok('east', abs(here_bearing($o, ['x' => 150, 'y' => 100]) - 90) < 0.01);
ok('south', abs(here_bearing($o, ['x' => 100, 'y' => 150]) - 180) < 0.01);
ok('west', abs(here_bearing($o, ['x' => 50, 'y' => 100]) - 270) < 0.01);
ok('north-east', abs(here_bearing($o, ['x' => 150, 'y' => 50]) - 45) < 0.01);

echo "== assign exits\n";
$anchors = HERE_ANCHORS;
$routes = [['id' => 5, 'bearing' => 10.0], ['id' => 2, 'bearing' => 12.0], ['id' => 9, 'bearing' => 200.0], ['id' => 4, 'bearing' => 12.0]];
[$a1, $m1] = here_assign_exits($anchors, $routes);
[$a2, $m2] = here_assign_exits($anchors, array_reverse($routes));
ok('deterministic whatever the input order', $a1 === $a2);
ok('total: every route gets an anchor when there is room', count($a1) === 4 && !$m1);
ok('every exit gets a distinct anchor', count(array_unique($a1)) === count($a1));
ok('lowest bearing takes the nearest anchor, then ties by id', $a1[5] === 'N' && $a1[2] === 'NE' && $a1[4] === 'NW');
$many = []; for ($i = 1; $i <= 11; $i++) $many[] = ['id' => $i, 'bearing' => (float)($i * 7)];
[$a3, $m3] = here_assign_exits($anchors, $many);
ok('more routes than anchors: 8 placed, 3 in More ways', count($a3) === 8 && count($m3) === 3);
ok('no id both placed and in More ways', !array_intersect(array_keys($a3), $m3));
[$a4, $m4] = here_assign_exits($anchors, []);
ok('no routes = no exits', $a4 === [] && $m4 === []);
[$a5, $m5] = here_assign_exits(['N' => 0.0, 'S' => 180.0], [['id' => 1, 'bearing' => 350.0], ['id' => 2, 'bearing' => 355.0], ['id' => 3, 'bearing' => 10.0]]);
ok('a template with 2 anchors takes 2 routes', count($a5) === 2 && count($m5) === 1);
ok('first by (bearing, id) gets north, the rest wait', ($a5[3] ?? '') === 'N' && $m5 === [2]);

echo "== place npcs\n";
$stand = [['x' => 1, 'y' => 1], ['x' => 2, 'y' => 2], ['x' => 3, 'y' => 3]];
$npcs = []; foreach (['ada', 'bo', 'cy', 'di', 'ed'] as $s) $npcs[] = ['slug' => $s, 'id' => $s];
[$p1, $over1] = here_place_npcs($stand, $npcs, 100);
[$p2, $over2] = here_place_npcs($stand, array_reverse($npcs), 100);
ok('3 slots, 5 villagers: 3 placed, 2 over', count($p1) === 3 && $over1 === 2);
ok('same hour, same crowd, same slots (input order does not matter)', $p1 === $p2);
[$p3] = here_place_npcs($stand, $npcs, 101);
ok('a new hour may shuffle', true);
ok('no villager twice', count(array_unique(array_column(array_column($p1, 1), 'slug'))) === 3);
[$p4, $over4] = here_place_npcs($stand, [], 1);
ok('nobody home = nothing placed', $p4 === [] && $over4 === 0);
[$p5, $over5] = here_place_npcs([], $npcs, 1);
ok('no stand slots = all overflow', $p5 === [] && $over5 === 5);

echo "== layouts\n";
$all = here_layouts_shipped();
ok('shipped layouts load', count($all) >= 10, 'got ' . count($all));
ok('generic exists', isset($all['generic']));
ok('all shipped layouts lint clean', here_lint_all($all) === [], json_encode(here_lint_all($all)));
foreach ($all as $k => $Lx) ok("$k has its own w/h", ($Lx['w'] ?? 0) > 0 && ($Lx['h'] ?? 0) > 0);
ok('generic has 8 exits and at least 4 stand slots', count($all['generic']['exits']) === 8 && count($all['generic']['stand']) >= 4);
ok('lookup: slug beats kind-landscape', here_layout_find(['slug:a' => ['w' => 1], 'village-forest' => ['w' => 2], 'generic' => ['w' => 3]], 'village', 'forest', 'a')[0] === 'slug:a');
ok('lookup: kind-landscape beats kind', here_layout_find(['village-forest' => ['w' => 2], 'village' => ['w' => 4], 'generic' => ['w' => 3]], 'village', 'forest', 'x')[0] === 'village-forest');
ok('lookup: kind beats generic', here_layout_find(['village' => ['w' => 4], 'generic' => ['w' => 3]], 'village', 'coast')[0] === 'village');
ok('lookup: falls back to generic', here_layout_find(['generic' => ['w' => 3]], 'delve', 'tundra')[0] === 'generic');
ok('missing template (not even generic) = null', here_layout_find([], 'village', 'forest') === null);
ok('town finds the town template', here_layout_find($all, 'market', '')[0] === 'generic' && here_layout_find($all, 'town', 'desert')[0] === 'town');
$anch = here_layout_anchors($all['generic']);
ok('anchors read from a layout', count($anch) === 8 && $anch['N'] === 0.0);
ok('exit position', here_exit_pos($all['generic'], 'N') === ['x' => 240, 'y' => 118] && here_exit_pos($all['generic'], 'X') === null);
ok('spot position', here_spot_pos($all['town'], 'green') !== null && here_spot_pos($all['town'], 'nope') === null);
$bad = $all['generic']; $bad['stand'][0] = ['x' => 240, 'y' => 130];
ok('lint: stand next to an exit is caught', here_lint_layout($bad) !== []);
$bad = $all['generic']; $bad['exits'][1]['x'] = 250;
ok('lint: exits too close are caught', here_lint_layout($bad) !== []);
$bad = $all['generic']; $bad['spots'][0]['x'] = 600;
ok('lint: a slot outside the picture is caught', here_lint_layout($bad) !== []);
$bad = $all['generic']; $bad['stand'][1]['y'] = 100;
ok('lint: stand above the horizon is caught', here_lint_layout($bad) !== []);
$bad = $all['generic']; $bad['stand'] = array_slice($bad['stand'], 0, 3);
ok('lint: fewer than 4 stand slots is caught', here_lint_layout($bad) !== []);
$big = json_decode(str_replace('"', '"', json_encode($all['generic'])), true); array_walk_recursive($big, function (&$v, $k) { if (in_array($k, ['x', 'y', 'w', 'h', 'horizon'], true)) $v *= 2; });
ok('canvas size is not hard-coded: a 960x540 layout lints by its own size', here_lint_layout($big) === []);

echo "== settings and schema\n";
require_once $game . '/includes/here_schema.php';
$s = here_settings();
ok('four settings with the planned defaults', ($s['gnav_on']['default'] ?? null) === '0' && ($s['gnav_tiles']['default'] ?? null) === '0' && ($s['gnav_enter_energy']['default'] ?? null) === '1' && ($s['gnav_login_here']['default'] ?? null) === '1');
[$t, $i, $c] = here_schema('INTEGER PRIMARY KEY AUTOINCREMENT', 'INTEGER', '');
ok('here_layouts table and users.start_page', str_contains($t[0], 'here_layouts') && $c === [['users', 'start_page', 'VARCHAR(8) NULL']]);
if ($withDb) {
    ok('gnav_on is off by default in a live game', setting('gnav_on') === '0');
    ok('settings reach settings_schema()', isset(settings_schema()['gnav_on']));
    ok('here_layouts table exists', (function () { try { q('SELECT 1 FROM here_layouts LIMIT 1'); return true; } catch (Throwable $e) { return false; } })());
    ok('users.start_page exists', (function () { try { q('SELECT start_page FROM users LIMIT 1'); return true; } catch (Throwable $e) { return false; } })());
    q("INSERT INTO here_layouts (layout_key, json, updated_at) VALUES ('generic', ?, ?)", [json_encode(['w' => 100, 'h' => 100]), gmdate('Y-m-d H:i:s')]);
    ok('admin edit overrides the shipped layout', (here_layouts_all()['generic']['w'] ?? 0) === 100);
    q("DELETE FROM here_layouts WHERE layout_key = 'generic'");
    ok('shipped layout back after the override is removed', (here_layouts_all()['generic']['w'] ?? 0) === 480);
}
echo $fails ? "$fails FAILED\n" : "all passed\n";
exit($fails ? 1 : 0);
