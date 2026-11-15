<?php
// 2.7.00 Admin > Trail decor: parsing and checking (includes/trail_decor_edit.php), the saved edit replacing the map data's decor, and Back to the data.
// php tests/trail_decor_edit.php GAME_DIR   (an installed game; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trail_decor_edit.php';
require_once $argv[1] . '/includes/tilemap.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

$rows = array_fill(0, 18, str_repeat('.', 30));   // a 30 x 18 section
echo "== parsing\n";
[$d, $bad] = tde_parse(['looks' => "hedge 0 0 29 1\npond 5 5 8 8", 'rough' => 'marsh 10 10 12 12', 'floor' => 'furrows 1 14 10 16', 'props' => "haybale 3 3\nboulder 20 9", 'rough_default' => 'grass', 'tree' => 'maple'], $rows);
ok('a good form gives a v1 decor with every entry', $d !== null && !$bad && $d['v'] === 1 && count($d['looks']) === 2 && count($d['rough']) === 1 && count($d['floor']) === 1 && count($d['props']) === 2 && $d['rough_default'] === 'grass' && $d['tree'] === 'maple', json_encode([$d, $bad]));
ok('blank lines and commas are fine', ($x = tde_parse(['looks' => "\n  hedge,0,0,5,1  \n\n"], $rows)[0]) !== null && $x['looks'] === [['hedge', 0, 0, 5, 1]]);
ok('trail_decor (the reader) keeps all of it', ($c = trail_decor(['rows' => $rows, 'decor' => $d])) && count($c['looks']) === 2 && count($c['props']) === 2 && $c['tree'] === 'maple');
foreach ([['looks' => 'Hedge 0 0 1 1'], ['looks' => 'hedge 0 0 1'], ['looks' => 'hedge 5 5 3 8'], ['looks' => 'hedge 0 0 30 1'], ['looks' => 'hedge 0 0 1 18'], ['looks' => "hedge 0 0 5 5\npond 4 4 8 8"], ['props' => 'rock 1'], ['props' => 'rock 30 2'], ['props' => 'rock a b'], ['tree' => 'Big Tree'], ['rough_default' => 'x']] as $case) {
    [$dd, $bb] = tde_parse($case, $rows);
    ok('refused: ' . json_encode($case), $dd === null && $bb, json_encode($bb));
}
ok('a line number is named', str_contains(tde_parse(['rough' => "marsh 1 1 2 2\nbroken"], $rows)[1][0] ?? '', 'rough line 2'));
echo "== tde_lines round trip\n";
ok('the lines come back as typed', tde_lines($d, 'looks') === "hedge 0 0 29 1\npond 5 5 8 8" && tde_lines($d, 'props') === "haybale 3 3\nboulder 20 9" && tde_lines([], 'looks') === '');

echo "== the saved edit replaces the map data\n";
ok('the table is there', tde_ensure_table());
$routes = trail_authored_all(); $rid = (int)array_key_first($routes); $sec = 0;
tde_save($rid, $sec, null);
$orig = trail_authored_section($rid, $sec); $w = strlen($orig['rows'][0]); $h = count($orig['rows']);
ok('before an edit the section carries the map data decor', ($orig['decor']['v'] ?? 0) === 1);
[$mine] = tde_parse(['looks' => "boulder 1 1 3 2", 'tree' => 'birch'], $orig['rows']);
tde_save($rid, $sec, $mine);
$now = trail_authored_section($rid, $sec);
ok('after saving, the section carries the edit', $now['decor'] === $mine && trail_decor($now)['tree'] === 'birch' && count(trail_decor($now)['looks']) === 1, json_encode($now['decor']));
ok('the map of the section is built with it', ($m = trail_map_authored($now)) && trail_decor($m[0]['art'])['tree'] === 'birch');
ok('another section of the route is untouched', trail_authored_count($rid) < 2 || (trail_authored_section($rid, 1)['decor'] ?? null) === ($routes[(string)$rid]['sections'][1]['decor'] ?? null));
$n1 = (int)q_val('SELECT COUNT(*) FROM trail_decor_edits WHERE route_id = ?', [$rid]);
tde_save($rid, $sec, $mine);
ok('saving again replaces, it does not add a row', (int)q_val('SELECT COUNT(*) FROM trail_decor_edits WHERE route_id = ?', [$rid]) === $n1);
tde_save($rid, $sec, null);
ok('Back to the data restores the map data decor', trail_authored_section($rid, $sec)['decor'] === $orig['decor'] && (int)q_val('SELECT COUNT(*) FROM trail_decor_edits WHERE route_id = ?', [$rid]) === $n1 - 1);
ok('the admin page and its menu entry exist', is_file($argv[1] . '/admin/trail_decor.php') && str_contains((string)file_get_contents($argv[1] . '/includes/admin_menu.php'), "'trail_decor.php'"));
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
