<?php
// 2.7.06: a lair guardian copies its template's drops, but not the ones gated to another region, and its own level replaces the template's level gate.
// php tests/lair_drops.php GAME_DIR   (an installed game; tests/lair_drops.sh)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/landmarks.php';
$fails = 0;
function ok(string $what, bool $cond, $x = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : '  ' . json_encode($x)) . "\n"; if (!$cond) $fails++; }
$na = (int)q_val("SELECT id FROM regions WHERE code = 'NA'"); $ids = q('SELECT id FROM items ORDER BY id LIMIT 3')->fetchAll(PDO::FETCH_COLUMN);
ok('setup: region NA and three items exist', $na > 0 && count($ids) === 3, [$na, $ids]);
$loc = db_insert('locations', ['name' => 'Zz Test Lair', 'slug' => 'zz-test-lair', 'landscape' => 'zzland', 'region_id' => $na]);
db_insert('landmarks', ['region_id' => $na, 'location_id' => $loc, 'kind' => 'lair', 'name' => 'Lair of the Zz Test', 'description' => 'test']);
$tpl = db_insert('creatures', ['slug' => 'zz-tpl', 'name' => 'Zz Template', 'size' => 'boss', 'landscapes' => 'zzland', 'level' => 20, 'hp' => 50, 'attack' => 5, 'defense' => 12, 'dmg_die' => 10, 'dmg_bonus' => 1, 'xp' => 100, 'description' => 'x', 'active' => 1]);
db_insert('creature_drops', ['creature_id' => $tpl, 'item_id' => $ids[0], 'chance' => 50, 'reg' => 'NA']);
db_insert('creature_drops', ['creature_id' => $tpl, 'item_id' => $ids[1], 'chance' => 50, 'reg' => 'EE']);
db_insert('creature_drops', ['creature_id' => $tpl, 'item_id' => $ids[2], 'chance' => 50, 'lvmin' => 30]);
ensure_lair_bosses();
$gid = (int)q_val("SELECT id FROM creatures WHERE slug = 'boss-zz-test-lair'");
ok('the lair got its guardian', $gid > 0);
$d = q('SELECT * FROM creature_drops WHERE creature_id = ?', [$gid])->fetchAll(); $by = array_column($d, null, 'item_id');
ok('a drop gated to the lair\'s own region is kept (with its gate)', isset($by[$ids[0]]) && $by[$ids[0]]['reg'] === 'NA', $d);
ok('a drop gated to another region is not copied', !isset($by[$ids[1]]), $d);
ok('the template\'s level gate is dropped (the guardian has its own level)', isset($by[$ids[2]]) && $by[$ids[2]]['lvmin'] === null, $d);
foreach ([$gid, $tpl] as $cid) { q('DELETE FROM creature_drops WHERE creature_id = ?', [$cid]); q('DELETE FROM creatures WHERE id = ?', [$cid]); }
q('DELETE FROM encyclopedia_entries WHERE unlock_key = ?', ['creature:boss-zz-test-lair']); q('DELETE FROM landmarks WHERE location_id = ?', [$loc]); q('DELETE FROM locations WHERE id = ?', [$loc]);
echo $fails ? "$fails FAILED\n" : "ok\n"; exit($fails ? 1 : 0);
