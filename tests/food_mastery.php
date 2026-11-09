<?php
// 2.6.32: Foodie rank (unique foods) and food mastery (500/1000/1650/2000 of one food). Run: php tests/food_mastery.php GAME_DIR  (on an installed copy)
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/gnome.php';
require_once $argv[1] . '/includes/food_mastery.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
db_migrate(db(), 'sqlite');
$uid = (int)q_val("SELECT id FROM users ORDER BY id LIMIT 1");
if (!$uid) { $uid = db_insert('users', ['username' => 'fm', 'email' => 'fm@x.l', 'password_hash' => 'x']); }
q('DELETE FROM user_food_mastery WHERE user_id = ?', [$uid]); q('DELETE FROM user_tasted WHERE user_id = ?', [$uid]);

echo "== marks and tiers\n";
ok('marks', food_marks() === [500, 1000, 1650, 2000]);
foreach ([[0, 0], [499, 0], [500, 1], [999, 1], [1000, 2], [1649, 2], [1650, 3], [1999, 3], [2000, 4], [9999, 4]] as [$n, $t]) ok("count $n = tier $t", food_mastery_tier($n) === $t);

echo "== counting eaten + grown\n";
$item = (int)q_val('SELECT id FROM items WHERE edible = 1 ORDER BY id LIMIT 1');
$r = food_mastery_add($uid, $item, 'eaten', 499);
ok('499 eaten: no step', $r[0] === 0 && $r[1] === 0 && $r[2] === 499);
$r = food_mastery_add($uid, $item, 'grown', 1);
ok('+1 grown crosses 500', $r[0] === 0 && $r[1] === 1 && $r[2] === 500);
ok('up line says Familiar', str_contains(food_mastery_up_line('Carrot', $r), 'Familiar'));
ok('no line without a step', food_mastery_up_line('Carrot', food_mastery_add($uid, $item, 'eaten', 1)) === '');

echo "== boost\n";
$fx = ['temp' => ['grit' => 4, 'minutes' => 60], 'energy' => 10];
$b0 = food_mastery_boost($fx, 0); ok('tier 0 unchanged', $b0 === $fx);
$b2 = food_mastery_boost($fx, 2);
ok('tier 2: grit 4 -> 5 (+20%, rounds to +1)', $b2['temp']['grit'] === 5, (string)$b2['temp']['grit']);
ok('tier 2: minutes 60 -> 78 (+30%)', $b2['temp']['minutes'] === 78, (string)$b2['temp']['minutes']);
ok('tier 2: energy 10 -> 12', $b2['energy'] === 12, (string)$b2['energy']);
ok('small boosts still get +1', food_mastery_boost(['temp' => ['grit' => 1]], 1)['temp']['grit'] === 2);

echo "== Foodie rank\n";
$ids = array_map('intval', q('SELECT id FROM items WHERE edible = 1 ORDER BY id LIMIT 25')->fetchAll(PDO::FETCH_COLUMN));
ok('have 25 edibles to test with', count($ids) >= 21, (string)count($ids));
foreach (array_slice($ids, 0, 9) as $i) db_insert('user_tasted', ['user_id' => $uid, 'item_id' => $i, 'tasted_at' => now()]);
ok('9 foods: rank 0', food_rank($uid, true) === 0);
db_insert('user_tasted', ['user_id' => $uid, 'item_id' => $ids[9], 'tasted_at' => now()]);
ok('10 foods: rank 1', food_rank($uid, true) === 1);
ok('rank 1 gives +1 max energy', food_rank_energy($uid) === 1);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$withRank = max_energy($u);
foreach (array_slice($ids, 10, 10) as $i) db_insert('user_tasted', ['user_id' => $uid, 'item_id' => $i, 'tasted_at' => now()]);
food_rank($uid, true);
ok('20 foods: max energy +1 more', max_energy($u) === $withRank + 1, max_energy($u) . ' vs ' . $withRank);
ok('buff time +4% at rank 2', food_rank_buff_pct($uid) === 4);
q('DELETE FROM user_food_mastery WHERE user_id = ?', [$uid]); q('DELETE FROM user_tasted WHERE user_id = ?', [$uid]);
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
