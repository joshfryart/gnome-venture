<?php
// 2.5D villager sprites are wired: every NPC species and stop-villager species has its 3 strips, the 11 gnome NPCs each have their own look, and the Here scene, spot faces and Trail map use them.
// php tests/npc25_wire.php GAME_DIR
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/npc25.php';
require_once $argv[1] . '/includes/here_view.php';
require_once $argv[1] . '/includes/spot_card.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/trail_sights.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
echo "== every species has its strips\n";
$missing = [];
$species = array_column(q("SELECT DISTINCT species FROM npcs WHERE species IS NOT NULL AND species <> 'Gnome'")->fetchAll(), 'species');
foreach (STOP_SPECIES as $list) foreach ($list as $sp) $species[] = $sp;
foreach (array_unique($species) as $sp) foreach (['front', 'back', 'side'] as $v) if (!npc25_strip($sp, $v)) $missing[] = "$sp/$v";
ok('all NPC and stop-villager species are drawn in 3 views', !$missing, implode(', ', array_slice($missing, 0, 8)));
echo "== the gnome NPCs\n";
$gn = q("SELECT * FROM npcs WHERE species = 'Gnome' ORDER BY id")->fetchAll();
ok('there are 11 gnome NPCs', count($gn) === 11, (string)count($gn));
$hash = [];
foreach ($gn as $g) {
    $ok = true; foreach (['front', 'back', 'side'] as $v) { $st = npc25_for($g, $v); $f = $st ? APP_ROOT . '/assets/img/npc25/gnome-' . $g['slug'] . '-' . $v . '.png' : ''; if (!$st || !is_file($f)) $ok = false; else { $sz = getimagesize($f); if ($sz[0] !== 512 || $sz[1] !== 80) $ok = false; $hash[$g['slug']][$v] = md5_file($f); } }
    ok($g['name'] . ' has a 512 x 80 strip in all three views', $ok);
}
ok('every gnome NPC looks different (front strips all unique)', count(array_unique(array_column($hash, 'front'))) === 11);
ok('and from the player\'s default gnome', !in_array(md5_file(APP_ROOT . '/assets/img/gnome25/front-hat.png'), array_column($hash, 'front'), true));
echo "== wiring\n";
$g0 = $gn[0];
$sp = here_sprite($g0);
ok('the Here scene sprite of a gnome NPC is its strip (first frame shown)', str_contains($sp['src'], 'npc25/gnome-' . $g0['slug']) && $sp['frames'] === 8 && $sp['fw'] === 64 && $sp['fh'] === 80, json_encode($sp));
$town = q("SELECT * FROM npcs WHERE species = 'Hedgehog' ORDER BY id LIMIT 1")->fetch();
ok('and of a hedgehog NPC the hedgehog strip', $town && str_contains(here_sprite($town)['src'], 'npc25/hedgehog-front'));
ok('the spot face uses the strip', str_contains(spot_face($g0), 'npc25/gnome-' . $g0['slug']) && str_contains(spot_face($town), 'npc25/hedgehog-front'));
$pic = trail_sight_folk_pic($g0['name']);
ok('the Trail map picture of a gnome NPC is its strip', $pic && str_contains($pic[0], 'npc25/gnome-') && $pic[1] === 8 && $pic[4] === [64, 80], json_encode($pic));
foreach (q('SELECT * FROM locations WHERE kind = \'village\' ORDER BY id LIMIT 3')->fetchAll() as $v) stop_folk_ensure($v);
$f = q('SELECT * FROM stop_folk ORDER BY id LIMIT 1')->fetch();
$pf = trail_sight_folk_pic($f['name']);
ok('and of a stop villager', $pf && str_contains($pf[0], 'npc25/') && $pf[1] === 8, json_encode($pf));
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
