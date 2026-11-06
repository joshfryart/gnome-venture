<?php
// v2.0.92 Puzzle Pals on the map: spawns kept across days, level bands, one-per-day top-up, collect, the markers on both maps. Run by puzzle_pals.sh on a walk.sh install: php tests/puzzle_pals_map.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/puzzle_pals.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/maps.php';
require_once APP_ROOT . '/includes/maps_myc.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
jigsaw_ensure(); ppal_ensure();
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$pic = q_one("SELECT * FROM puzzle_pics WHERE slug = 'jig-maplewold'");
$pid = (int)$pic['id'];
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
/** forget every per-request cache the spawn code keeps (the refresh keeps a once-per-request guard in a static, so each "new page" is a new process in real life; here we call the pieces) */
function fresh_day(int $uid, string $day = ''): void { q('UPDATE users SET ppal_spawn_day = ? WHERE id = ?', [$day === '' ? null : $day, $uid]); ppal_spawns_reset(); }
q('DELETE FROM ppal_releases WHERE user_id = ?', [$uid]); q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]); q('DELETE FROM ppal_spawns WHERE user_id = ?', [$uid]);
q('INSERT INTO ppal_releases (user_id, pic_id, released_at, src) VALUES (?, ?, ?, ?)', [$uid, $pid, now(), 'free']);
q('UPDATE users SET level = 10 WHERE id = ?', [$uid]);
set_setting('puzzles_open', '1'); set_setting('jigsaw_open', '1'); set_setting('ppal_open', '1'); set_setting('ppal_party', '0'); set_setting('ppal_spawn_count', '3'); setting('__reload__');

echo "== modes (map only; page mode was removed)\n";
set_setting('ppal_find_mode', 'page'); setting('__reload__');   // a leftover row from an old install
ok('a leftover ppal_find_mode = page row is ignored: map spawns are on', ppal_map_on());
q("DELETE FROM settings WHERE name = 'ppal_find_mode'"); setting('__reload__');
ok('the page find lane is gone', !function_exists('ppal_maybe_find') && !function_exists('ppal_find_mode') && !function_exists('ppal_lane') && !defined('PPAL_QUIET_PAGES'));
set_setting('ppal_open', '0'); setting('__reload__');
ok('feature closed: no spawns', ppal_map_spawns($u()) === []);
set_setting('ppal_open', '1'); setting('__reload__');

echo "== level bands\n";
$nodes = []; foreach ([5, 8, 9, 10, 11, 12, 13, 14, 20] as $i => $l) $nodes[] = ['id' => 100 + $i, 'name' => "N$l", 'level' => $l];
$lv = fn(array $n) => $n['level'];
$c = ppal_spawn_node($nodes, $uid, 'k-common', 'common', 10, []);
$un = ppal_spawn_node($nodes, $uid, 'k-unc', 'uncommon', 10, []);
$r = ppal_spawn_node($nodes, $uid, 'k-rare', 'rare', 10, []);
ok('common sits at level 8 to 10 for a level-10 gnome', $c && $c['level'] >= 8 && $c['level'] <= 10, json_encode($c));
ok('uncommon sits at level 9 to 12', $un && $un['level'] >= 9 && $un['level'] <= 12, json_encode($un));
ok('rare sits at level 11 to 13 (a stretch above the gnome)', $r && $r['level'] >= 11 && $r['level'] <= 13, json_encode($r));
ok('the same pal always gets the same place', ppal_spawn_node($nodes, $uid, 'k-rare', 'rare', 10, []) === $r);
$near = ppal_spawn_node([['id' => 1, 'name' => 'a', 'level' => 3], ['id' => 2, 'name' => 'b', 'level' => 7]], $uid, 'k', 'rare', 10, []);
ok('no place in the band: the nearest level is used', $near && $near['level'] === 7);
$tk = ppal_spawn_node($nodes, $uid, 'k-rare', 'rare', 10, [$r['id'] => true]);
ok('a taken place is avoided while another fits', $tk && $tk['id'] !== $r['id'] && $tk['level'] >= 11 && $tk['level'] <= 13);

echo "== a Places picture's pals wait at their own place\n";
jigsaw_seed_places();
$allNodes = ppal_spawn_nodes($uid);
$own = null; $ownPic = null;
require_once APP_ROOT . '/includes/landmarks.php'; require_once APP_ROOT . '/includes/progression.php';
foreach (q("SELECT * FROM puzzle_pics WHERE source = 'place' AND kind = 'still' ORDER BY id")->fetchAll() as $pp_) {
    foreach (q('SELECT kind, name, location_id FROM landmarks WHERE location_id IS NOT NULL')->fetchAll() as $lm_) {
        if (landmark_scene_slug((string)$lm_['kind'], (string)$lm_['name']) !== $pp_['unlock_key'] || !in_array((string)q_val('SELECT kind FROM locations WHERE id = ?', [(int)$lm_['location_id']]), ['haven', 'wonder', 'village'], true)) continue;
        $lid = (int)$lm_['location_id'];
        $allNodes = array_values(array_filter($allNodes, fn($n) => $n['id'] !== $lid));
        $allNodes[] = ['id' => $lid, 'name' => (string)$lm_['name'], 'level' => location_min_level($lid)];   // the gnome has found the place (a real gnome has: that is what unlocks the picture)
        if (($o_ = ppal_own_node($pp_, $allNodes))) { $own = $o_; $ownPic = $pp_; break 2; }
    }
}
if ($own) {
    $sameLevel = ppal_spawn_node($allNodes, $uid, 'x-own', 'common', max(1, $own['level']), [], $own);
    ok('the place of a Places picture is a spawn node and gets its pal (' . $own['name'] . ')', $sameLevel && $sameLevel['id'] === $own['id']);
    $far = ppal_spawn_node($allNodes, $uid, 'x-own', 'common', $own['level'] + 20, [], $own);
    ok('...but not when it is far below the gnome (the level band wins)', $far && $far['id'] !== $own['id']);
    $busy = ppal_spawn_node($allNodes, $uid, 'x-own', 'common', max(1, $own['level']), [$own['id'] => true], $own);
    ok('...and not when another pal already waits there', $busy && $busy['id'] !== $own['id']);
} else echo "skip own-place checks (no Places picture with a spawn-node landmark in this install)\n";
ok('a gallery picture has no own place', ppal_own_node($pic, $allNodes) === null);

echo "== the daily top-up\n";
$arrived = fn() => (int)q_val("SELECT COUNT(*) FROM notices WHERE user_id = ? AND text LIKE '%arrived on your map%'", [$uid]);
q("DELETE FROM notices WHERE user_id = ? AND text LIKE '%arrived on your map%'", [$uid]);
fresh_day($uid);
$made = ppal_spawn_refresh($u());
ok('first top-up after a release (day NULL): no "arrived" notice (the release notice said it)', $arrived() === 0);
$sp = ppal_spawns($uid);
ok('3 pals made, one place each', $made === 3 && count($sp) === 3, "$made/" . count($sp));
ok('only pals of the released roster, none found', count(array_filter($sp, fn($w) => (int)$w['pic']['id'] === $pid)) === 3);
$keys = array_map(fn($w) => $w['pal']['key'], $sp); sort($keys);
ok('places are real map places with a level', count(array_filter($sp, fn($w) => $w['level'] >= 1 && $w['loc'] !== '')) === 3);
ok('once a day: the same request does nothing more', ppal_spawn_refresh($u()) === 0);
// a new day: waiting pals are kept, nothing is added or moved while 3 wait
fresh_day($uid, '2000-01-01');
$before = q('SELECT pal_key, loc_id FROM ppal_spawns WHERE user_id = ? ORDER BY pal_key', [$uid])->fetchAll();
// php -r takes args after the code: ($argv[1] = GAME)
$run = function (string $code) use ($argv): string {
    $cmd = PHP_BINARY . ' -d session.save_path=/tmp -r ' . escapeshellarg('$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require APP_ROOT."/includes/puzzle_pals.php"; ' . $code) . ' ' . escapeshellarg($argv[1]);
    return trim((string)shell_exec($cmd . ' 2>&1'));
};
$uidc = $uid;
$out = $run('$u = q_one("SELECT * FROM users WHERE id = ' . $uidc . '"); echo ppal_spawn_refresh($u);');
ok('a new day with 3 still waiting: nothing added, nothing moved', $out === '0');
$after = q('SELECT pal_key, loc_id FROM ppal_spawns WHERE user_id = ? ORDER BY pal_key', [$uid])->fetchAll();
ok('...the same 3 pals at the same places', $before === $after);

echo "== collect\n";
$locId = (int)array_key_first($sp);
$pal = $sp[$locId]['pal']['key'];
ppal_spawns_reset();
[$okc, $box] = ppal_spawn_collect($u(), $locId);
ok('collect works where the pal waits', $okc === true && ($box['ppal'] ?? '') === $pal, json_encode($box));
ok('...it joins the book once', (int)q_val('SELECT COUNT(*) FROM ppal_found WHERE user_id = ? AND pal_key = ?', [$uid, $pal]) === 1);
ok('...its spawn row is gone, the other 2 stay', (int)q_val('SELECT COUNT(*) FROM ppal_spawns WHERE user_id = ?', [$uid]) === 2 && !isset(ppal_spawns($uid)[$locId]));
ok('collecting where nothing waits is refused', ppal_spawn_collect($u(), $locId)[0] === false);
$other = (int)array_key_last(ppal_spawns($uid));
ok('a pal at another place cannot be collected from here', ppal_spawn_collect($u(), 999999)[0] === false);
// next day: one slot refills, and never a found pal
q('UPDATE users SET ppal_spawn_day = ? WHERE id = ?', ['2000-01-02', $uid]);
$out = $run('$u = q_one("SELECT * FROM users WHERE id = ' . $uidc . '"); echo ppal_spawn_refresh($u);');
ok('next day: the collected slot is topped up (1 new)', $out === '1', $out);
ok('...and the gnome gets one "A Puzzle Pal has arrived on your map" notice', $arrived() === 1 && (int)q_val("SELECT COUNT(*) FROM notices WHERE user_id = ? AND text LIKE '%A Puzzle Pal has arrived on your map%'", [$uid]) === 1);
$rows = q('SELECT pal_key FROM ppal_spawns WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN);
ok('3 waiting again, none of them the pal already found', count($rows) === 3 && !in_array($pal, $rows, true));
ppal_spawns_reset();

echo "== roster complete: nothing more to spawn\n";
foreach (ppal_roster($pic) as $p) { try { q('INSERT INTO ppal_found (user_id, pal_key, pic_id, found_at, times, active) VALUES (?, ?, ?, ?, 1, 0)', [$uid, $p['key'], $pid, now()]); } catch (Throwable $e) {} }
ppal_spawns_reset();
ok('found pals no longer show as waiting', ppal_spawns($uid) === []);

echo "== the maps\n";
q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]); q('DELETE FROM ppal_spawns WHERE user_id = ?', [$uid]);
$town = q_one("SELECT id, region_id FROM locations WHERE kind = 'market' AND region_id IS NOT NULL ORDER BY id LIMIT 1");
$pal0 = ppal_roster($pic)[0];
q('INSERT INTO ppal_spawns (user_id, pal_key, pic_id, loc_id, made_day) VALUES (?, ?, ?, ?, ?)', [$uid, $pal0['key'], $pid, (int)$town['id'], hollow_date('Y-m-d')]);
q('UPDATE users SET ppal_spawn_day = ? WHERE id = ?', [hollow_date('Y-m-d'), $uid]);
ppal_spawns_reset();
q('UPDATE users SET location_id = NULL WHERE id = ?', [$uid]);
$uu = $u();
$rid = (int)$town['region_id'];
$svg = region_map_svg($uu, $rid);
ok('classic region map: the pal marker is on the town', str_contains($svg, 'mppal mppal-' . $pal0['rarity']) && substr_count($svg, 'class="mppal ') === 1, substr($svg, 0, 200));
ok('...with the place still named in the tooltip', str_contains($svg, 'waits here'));
$D = myc_region_data($uu, $rid, 0);
$m = $D ? myc_region_svg_one($uu, $D, 0, false, 'p', false) : '';
ok('mycelium region map: the pal marker too', str_contains($m, 'class="mppal mppal-' . $pal0['rarity'] . '"'));
ok('no inline styles on the markers', !str_contains(ppal_marker_svg(ppal_spawns($uid)[(int)$town['id']] ?? ['pal' => $pal0], '', 20), 'style='));
$wm = myc_world_svg($uu, $rid);
ok('mycelium world map: a pal badge on the region with a waiting pal', str_contains($wm, 'class="mppalreg"') && str_contains($wm, 'Puzzle Pals waiting'));
ok('classic world map: the badge too', str_contains(world_map_svg($uu, $rid), 'class="mppalreg"'));
$book = ppal_waiting_html($uu);
ok('the Pal Book lists the waiting pal with its place and level', str_contains($book, $pal0['name']) && str_contains($book, 'Lv '), $book);
echo "== reworked finds: chip, admin test, wording\n";
ok('the Go tab chip counts the waiting pals and links to the map', str_contains(ppal_chip_html($uu), '1 Puzzle Pal is') && str_contains(ppal_chip_html($uu), 'world.php?tab=map'), ppal_chip_html($uu));
$beforeN = count(ppal_spawns($uid));
$msg = ppal_admin_spawn($uu);
ok('admin test puts one more pal on the map now (' . $msg . ')', str_contains($msg, 'now waits at') && count(ppal_spawns($uid)) === $beforeN + 1, $msg);
ok('the finder perk line says what it does now', str_contains(PPAL_PERK_TEXT['finder'], 'extra Puzzle Pal on your map'));
q('DELETE FROM ppal_spawns WHERE user_id = ?', [$uid]); ppal_spawns_reset();
ok('nothing waiting but pals left to meet: the book says new pals arrive each day', str_contains(ppal_waiting_html($uu), 'Nothing is waiting right now') && ppal_chip_html($uu) === '');
ok('the win card says the pals wait on the map (puzzles.js)', str_contains((string)file_get_contents(APP_ROOT . '/assets/puzzles.js'), "' will wait at places on the map. Look for their stickers!'") && !str_contains((string)file_get_contents(APP_ROOT . '/assets/puzzles.js'), 'somewhere about the Hollow'));
$g = q_one('SELECT * FROM users WHERE guest = 1 LIMIT 1');
ok('guests never get spawns', !$g || ppal_map_spawns($g) === []);

q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]); q('DELETE FROM ppal_releases WHERE user_id = ?', [$uid]); q('DELETE FROM ppal_spawns WHERE user_id = ?', [$uid]);
set_setting('ppal_open', '0'); setting('__reload__');
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
