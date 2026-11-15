<?php
// 2.7.00 ruin pictures: landmark_scene() shows assets/img/wonders/ruin/<same name> for a ruined place that has one, the greyed live picture for any other.
// php tests/ruin_scene.php GAME_DIR   (an installed game)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/items.php';
require_once $argv[1] . '/includes/landmarks.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$nine = ['haven' => ['Market of a Thousand Chilies', 'Driftwood Tavern', 'Turtle Nesting Beach'], 'wonder' => ['The Stepped Seed Temple', 'Cenote of Echoes', 'Sunken Gnome Galleon', 'The Singing Waterfall'], 'delve' => ['Jaguar Root Caves', 'Mangrove Root Maze']];
echo "== the nine pilot places\n";
foreach ($nine as $kind => $names) foreach ($names as $n) {
    $slug = landmark_scene_slug($kind, $n); $f = $argv[1] . '/assets/img/wonders/ruin/' . $slug . '.png'; $live = $argv[1] . '/assets/img/wonders/' . $slug . '.png';
    $sz = is_file($f) ? getimagesize($f) : null;
    ok("$n: a 480x270 ruin picture beside the live one", $sz && $sz[0] === 480 && $sz[1] === 270 && is_file($live), $slug);
    $lm = ['kind' => $kind, 'name' => $n];
    $ruin = landmark_scene($lm, true); $whole = landmark_scene($lm, false);
    ok("$n: ruined shows the ruin picture and no grey filter; repaired shows the live picture", str_contains($ruin, 'wonders/ruin/' . $slug . '.png') && !str_contains($ruin, 'lmscene-ruin') && str_contains($whole, 'wonders/' . $slug . '.png') && !str_contains($whole, '/ruin/') && !str_contains($whole, 'lmscene-ruin'), $ruin);
}
echo "== any other place keeps the grey filter\n";
$other = ['kind' => 'haven', 'name' => 'Beaver Pond Lodge'];
foreach (glob($argv[1] . '/assets/img/wonders/haven-*.png') as $f) { $b = basename($f, '.png'); if (!is_file($argv[1] . '/assets/img/wonders/ruin/' . $b . '.png')) { $other = ['kind' => 'haven', 'name' => ucwords(str_replace('-', ' ', substr($b, 6)))]; break; } }
$h = landmark_scene($other, true);
ok('a ruined place with no ruin picture uses the live picture with the lmscene-ruin filter', $h !== '' && str_contains($h, 'lmscene-ruin') && !str_contains($h, '/ruin/'), $h);
ok('a kind with no scene returns nothing', landmark_scene(['kind' => 'village', 'name' => 'x'], true) === '');
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
