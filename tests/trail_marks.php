<?php
// 2.7.01 the drawn Trail markers on the map (trail/mark/*.png, art-2701): road kinds on the stretch they apply to, the Sight spyglass over a landmark,
// a villager without a sprite, the place the last stretch leads into (haven wonder delve lair market). A missing picture keeps an emoji; the no-picture map keeps working.
// php tests/trail_marks.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/road_kinds.php';
require_once $argv[1] . '/includes/trail_sights.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$markDir = $argv[1] . '/assets/img/trail/mark/';
$away = function (string $f, callable $fn) { rename($f, $f . '.away'); clearstatcache(); try { return $fn(); } finally { rename($f . '.away', $f); clearstatcache(); } };

echo "== the marker files\n";
$names = ['camp', 'ferry', 'tunnel', 'pass', 'toll', 'sight', 'villager', 'fight', 'haven', 'wonder', 'delve', 'lair', 'overgrown', 'flooded', 'market', 'rest', 'signpost'];
ok('every installed marker can be asked for by name', array_filter($names, fn($n) => trail_mark_file('', $n) !== $n) === [], json_encode(array_map(fn($n) => trail_mark_file('', $n), $names)));
ok('an unknown name is no marker; the fight and camp emoji still map', trail_mark_file('', 'nope') === '' && trail_mark_file('⚔️') === 'fight' && trail_mark_file('🏕️') === 'camp' && trail_mark_file('🚪') === '');
ok('hazard is installed but no Trail token asks for it (no data has a hazard)', is_file($markDir . 'hazard.png') && trail_mark_file('', 'hazard') === '');
ok('a missing picture is no marker', $away($markDir . 'ferry.png', fn() => trail_mark_file('', 'ferry')) === '');

echo "== road kinds: which stretch\n";
ok('ferry, tunnel, pass and toll: the first stretch walked only', rk_on_stretch('ferry', 0) && !rk_on_stretch('ferry', 1) && rk_on_stretch('tunnel', 0) && !rk_on_stretch('pass', 2) && rk_on_stretch('toll', 0) && !rk_on_stretch('toll', 1));
ok('overgrown and flooded: every stretch', rk_on_stretch('overgrown', 0) && rk_on_stretch('overgrown', 2) && rk_on_stretch('flooded', 1));
ok('every road kind has a map emoji', count(array_filter(RK_KINDS, fn($k) => (RK_ICON[$k] ?? '') !== '')) === count(RK_KINDS));

set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); setting('__reload__');
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$walk = function (int $rid) use ($uid) {
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
    $r = q_one('SELECT * FROM routes WHERE id = ?', [$rid]);
    q('UPDATE users SET location_id = ?, level = 40, energy = 100, coins = 500 WHERE id = ?', [$r['a_id'], $uid]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $to = q_one('SELECT * FROM locations WHERE id = ?', [$r['b_id']]);
    if ($to && !place_known($uid, $to)) unlock_entries($uid, ($to['kind'] === 'village' ? 'village:' : 'landmark:') . $to['slug']);
    start_expedition($u, $rid);
    $exp = active_expedition($uid); $exp['encounter'] = null;
    return [q_one('SELECT * FROM users WHERE id = ?', [$uid]), $exp];
};
$atSec = function (array $exp, int $sec): array { $sc = trail_scene($exp); $sc['st']['sec'] = $sec; trail_save($sc); $sc = trail_scene($exp); [$sc['x'], $sc['y']] = $sc['map']['entry']; trail_save($sc); return trail_scene($exp); };   // at that stretch's way in

echo "== a ferry road (route 308)\n";
[$u, $exp] = $walk(308);
ok('the walk is on the tile map', (bool)trail_scene($exp));
$sc = trail_scene($exp);
$html = trail_view_html($u, $exp, $sc, false);
ok('stretch 1 draws the ferry marker', str_contains($html, 'mark/ferry.png'));
$spot = trail_road_mark($sc);
ok('it stands on floor beside the way in, not on a token or the way on', $spot && in_array(tm_tile($sc['map'], $spot[0], $spot[1]), ['.', ','], true)
    && max(abs($spot[0] - $sc['map']['entry'][0]), abs($spot[1] - $sc['map']['entry'][1])) <= 3 && trail_token_at($sc, $spot[0], $spot[1]) < 0 && $spot !== $sc['map']['spots']['9'], json_encode($spot));
ok('its tile says what it is', str_contains($html, 'aria-label="Ferry · ' . RK_FERRY_PETALS . ' Petals"'));
ok('the marker has a fixed box (no layout shift)', (bool)preg_match('~<image class="tmmark" href="[^"]*mark/ferry\.png[^"]*" x="[-0-9.]+" y="[-0-9.]+" width="42" height="42"~', $html));
$sc2 = $atSec($exp, 1);
ok('stretch 2 has no ferry marker', !str_contains(trail_view_html($u, $exp, $sc2, false), 'mark/ferry.png'));
$sc = $atSec($exp, 0);
$noPic = $away($markDir . 'ferry.png', fn() => trail_view_html($u, $exp, $sc, false));
ok('without its picture the ferry keeps an emoji disc (no red placeholder)', !str_contains($noPic, 'mark/ferry.png') && (bool)preg_match('~<g class="tmmarkx"><circle[^>]*/><text[^>]*>⛴️</text></g>~u', $noPic));
$gp = trail_ground_file(308, 1, $argv[1], '-r');
$fb = $gp ? $away($gp, fn() => trail_view_html($u, $exp, $sc, false)) : '';
ok('the no-picture map draws the ferry as an emoji token', $gp !== null && !str_contains($fb, 'ground/308-') && (bool)preg_match('~class="tmtok"><circle[^>]*/><text[^>]*>⛴️</text>~u', $fb), (string)$gp);

echo "== an overgrown road (route 304)\n";
[$u, $exp] = $walk(304);
$sc = trail_scene($exp);
ok('stretch 1 draws the overgrown marker', str_contains(trail_view_html($u, $exp, $sc, false), 'mark/overgrown.png'));
$sc = $atSec($exp, 1);
ok('stretch 2 draws it too', str_contains(trail_view_html($u, $exp, $sc, false), 'mark/overgrown.png'));

echo "== a plain road (route 240)\n";
[$u, $exp] = $walk(240);
$sc = trail_scene($exp);
$h240 = trail_view_html($u, $exp, $sc, false);
ok('no road-kind marker', !preg_match('~mark/(ferry|tunnel|pass|toll|overgrown|flooded)\.png~', $h240) && trail_road_mark($sc) === null);

echo "== the place the last stretch leads into\n";
$last = $sc; $last['st']['sec'] = (int)$sc['st']['S'] - 1; $last['x'] = $sc['map']['spots']['9'][0] - 1; $last['y'] = $sc['map']['spots']['9'][1];   // in memory: the last stretch, beside its way on (in the view)
require_once $argv[1] . '/includes/destination.php';
foreach (['lair', 'haven', 'wonder', 'delve', 'market'] as $k) {
    $loc = null;
    foreach (q('SELECT * FROM locations ORDER BY id')->fetchAll() as $l) if (loc_real_kind($l) === $k) { $loc = $l; break; }
    if (!$loc) { ok("a $k exists in the world", false); continue; }
    $e2 = $exp; $e2['to_id'] = (int)$loc['id'];
    $h = trail_view_html($u, $e2, $last, false);
    ok("into a $k: its marker on the way on, and the tile names the place", str_contains($h, 'mark/' . $k . '.png') && str_contains($h, 'aria-label="The way on to ' . e((string)$loc['name']) . '"'), $loc['name'] . ' ' . (preg_match('~aria-label="The way on[^"]*"~', $h, $mm) ? $mm[0] : '-') . ' ' . (int)str_contains($h, 'mark/' . $k . '.png'));
}
$vil = q_one("SELECT * FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1");
$e2 = $exp; $e2['to_id'] = (int)$vil['id'];
$h = trail_view_html($u, $e2, $last, false);
ok('into a rest stop (village): the rest marker on the way on, and the tile names it', str_contains($h, 'mark/rest.png') && str_contains($h, 'aria-label="The way on to ' . e((string)$vil['name']) . '"'), (int)str_contains($h, 'mark/rest.png') . ' ' . (preg_match('~aria-label="The way on[^"]*"~', $h, $mm) ? $mm[0] : '-') . ' ' . (int)str_contains($h, '🚪'));
$noRest = $away($markDir . 'rest.png', fn() => trail_view_html($u, $e2, $last, false));
ok('...without its picture: an emoji disc', !str_contains($noRest, 'mark/rest.png') && (bool)preg_match('~<g class="tmmarkx"><circle[^>]*/><text[^>]*>🛖</text></g>~u', $noRest));
$hub = q_one("SELECT * FROM locations WHERE kind NOT IN ('village', 'market', 'wonder', 'lair', 'haven', 'delve') ORDER BY id LIMIT 1");
$e2['to_id'] = (int)$hub['id'];
$h = trail_view_html($u, $e2, $last, false);
ok('into a ' . $hub['kind'] . ': the way on keeps its door', !preg_match('~mark/(haven|wonder|delve|lair|market|rest)\.png~', $h) && str_contains($h, '🚪'));
$e2['to_id'] = (int)$vil['id'];
$e2['to_id'] = (int)q_val("SELECT id FROM locations WHERE id IN (SELECT location_id FROM landmarks WHERE kind = 'lair') LIMIT 1");
ok('not the last stretch: the way on keeps its door', !str_contains(trail_view_html($u, $e2, $sc, false), 'mark/lair.png'));

echo "== a side path: the signpost beside the way in, first stretch only\n";
$side = 0;
foreach (q("SELECT id FROM routes WHERE kind = 'side' ORDER BY id")->fetchAll() as $r) if (rk_of((int)$r['id']) === null) { $side = (int)$r['id']; break; }   // a side path with no road kind (a road kind keeps its own marker)
ok('the world has a side path with no road kind', $side > 0);
[$u, $exp] = $walk($side);
$sc = trail_scene($exp);
$hs = trail_view_html($u, $exp, $sc, false);
$spot = trail_road_mark($sc);
ok('stretch 1 draws the signpost on floor beside the way in, and its tile says what it is', $spot && $spot[2] === 'side' && str_contains($hs, 'mark/signpost.png') && str_contains($hs, 'aria-label="A side path, off the road"'), json_encode($spot));
if ((int)$sc['st']['S'] > 1) { $sc2 = $atSec($exp, 1); ok('stretch 2 has no signpost', !str_contains(trail_view_html($u, $exp, $sc2, false), 'mark/signpost.png') && trail_road_mark($sc2) === null); }
ok('a road (route 240) has no signpost', !str_contains($h240, 'mark/signpost.png'));

echo "== the Sight spyglass\n";
$art = trail_authored_section(240, 0);
[$map] = trail_map_authored($art);
$lm = null; foreach ($art['objs'] as $ob) if (str_starts_with((string)$ob[2], 'lm-')) { $lm = $ob; break; }
$st = ['px' => 0, 'py' => 0, 'x0' => max(0, $lm[0] - 3), 'y0' => max(0, $lm[1] - 3), 'cols' => 7, 'rows' => 7, 'tokens' => []];   // (no 'folk' key: + would keep it over the one a case adds)
$ready = trail_art_svg($map, $st + ['sights' => [$lm[0] . ',' . $lm[1] => true]]);
$spent = trail_art_svg($map, $st + ['sights' => [$lm[0] . ',' . $lm[1] => false]]);
ok('a ready Sight: the spyglass with the gold ! (tmsight)', str_contains($ready, 'class="tmsight"') && str_contains($ready, 'mark/sight.png') && str_contains($ready, '>!</text>'));
ok('a used-up Sight: the spyglass, faded, no !', str_contains($spent, 'class="tmsightx"') && str_contains($spent, 'mark/sight.png') && !str_contains($spent, '>!</text>'));
$old = $away($markDir . 'sight.png', fn() => [trail_art_svg($map, $st + ['sights' => [$lm[0] . ',' . $lm[1] => true]]), trail_art_svg($map, $st + ['sights' => [$lm[0] . ',' . $lm[1] => false]])]);
ok('without the picture: the old gold ! circle when ready, nothing when used up', str_contains($old[0], 'class="tmsight"><circle') && !str_contains($old[0], 'mark/sight.png') && !str_contains($old[1], 'tmsight'));

echo "== a villager without a sprite\n";
$folkSt = $st + ['sights' => [], 'folk' => [[$lm[0], $lm[1] + 1, trail_art_url('mark/villager.png'), 'Test Person', 0, 's', 1, false]]];
$fsvg = trail_art_svg($map, $folkSt);
ok('drawn as the villager marker on its tile (tmfolk tmfolkmark)', str_contains($fsvg, 'class="tmfolk tmfolkmark"') && str_contains($fsvg, 'mark/villager.png') && str_contains($fsvg, '<title>Test Person</title>'));
require_once $argv[1] . '/includes/stop_folk.php';
$v = q_one("SELECT * FROM locations WHERE kind = 'village' ORDER BY id LIMIT 1"); stop_folk_ensure($v);
$f = q_one('SELECT * FROM stop_folk WHERE location_id = ? ORDER BY id LIMIT 1', [$v['id']]);
$pic0 = trail_sight_folk_pic($f['name'] . '@' . $v['slug']);
q("UPDATE stop_folk SET species = 'nosuchkind' WHERE id = ?", [$f['id']]);
$pic = trail_sight_folk_pic($f['name'] . '@' . $v['slug']);
q('UPDATE stop_folk SET species = ? WHERE id = ?', [$f['species'], $f['id']]);
ok('a villager with a sprite keeps it', $pic0 && !str_contains($pic0[0], 'mark/villager.png') && in_array($pic0[1], [4, 8], true), json_encode($pic0));
ok('a villager without one gets the marker (frames 0), same id', $pic && str_contains($pic[0], 'mark/villager.png') && $pic[1] === 0 && $pic[2] === 's' && $pic[3] === (int)$f['id'], json_encode($pic));

echo $fails ? "$fails FAILED\n" : "ok\n";
