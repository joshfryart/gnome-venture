<?php
// T2.1: the Grand Harvest Fair has three classes (Produce, Flowers, Preserves). Run by contest.sh on the world walk.sh made (player "sprout"): php fair3.php GAME
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
require_once $argv[1] . '/includes/fair.php';
set_exception_handler(function (Throwable $e) { echo '  FAIL uncaught ' . get_class($e) . ': ' . $e->getMessage() . ' at ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$month = job_period_key('monthly');

echo "== three classes; every crop kind that was judged before is still judged\n";
ok('classes are produce, flower, preserve', array_keys(FAIR_CATS) === ['produce', 'flower', 'preserve'], implode(',', array_keys(FAIR_CATS)));
$k = [];
foreach (['vegetable', 'tuber', 'legume', 'fruit', 'tree', 'nut', 'grain', 'herb', 'spice'] as $kind) $k[] = fair_cat($kind);
ok('vegetable, fruit, grain, herb kinds all go to Produce', array_unique($k) === ['produce'], implode(',', $k));
ok('flowers stay Flowers, covers are never judged', fair_cat('flower') === 'flower' && fair_cat('cover') === null);
ok('old ribbons keep their labels', fair_cat_label('veg') === 'Vegetables' && fair_cat_label('herb') === 'Herbs & spices' && fair_cat_label('produce') === 'Produce');
ok('old classes can not be entered', fair_enter(q_one('SELECT * FROM users WHERE id = ?', [$uid]), 'veg')[0] === false);
ok('upgrade step done on a fresh world', setting('upg249_faircats') === '1');

echo "== switchover: this month's open old-class rows become one Produce row (the best)\n";
q('DELETE FROM fair_best WHERE user_id = ?', [$uid]); q('DELETE FROM fair_entries WHERE user_id = ?', [$uid]);
foreach (['veg' => 40, 'fruit' => 61, 'herb' => 55, 'flower' => 30] as $c => $s) {
    db_insert('fair_best', ['user_id' => $uid, 'month' => $month, 'cat' => $c, 'plant_id' => 1, 'score' => $s, 'at' => now()]);
    if ($c !== 'herb') db_insert('fair_entries', ['user_id' => $uid, 'month' => $month, 'cat' => $c, 'plant_id' => 1, 'score' => $s, 'at' => now()]);
}
fair_merge_old_classes($month);
$rows = fn($t) => implode(',', q("SELECT cat || ':' || score FROM $t WHERE user_id = ? AND month = ? ORDER BY cat", [$uid, $month])->fetchAll(PDO::FETCH_COLUMN));
ok('fair_best: best old row is now Produce, Flowers untouched', $rows('fair_best') === 'flower:30,produce:61', $rows('fair_best'));
ok('fair_entries: best entry is now Produce', $rows('fair_entries') === 'flower:30,produce:61', $rows('fair_entries'));
fair_merge_old_classes($month);
ok('running it again changes nothing', $rows('fair_best') === 'flower:30,produce:61' && $rows('fair_entries') === 'flower:30,produce:61');
q('DELETE FROM fair_best WHERE user_id = ?', [$uid]); q('DELETE FROM fair_entries WHERE user_id = ?', [$uid]);

echo "== an old unjudged month is judged in its old classes\n";
set_setting('fair_min_entries', '1'); setting('__reload__');
db_insert('fair_entries', ['user_id' => $uid, 'month' => '2000-01', 'cat' => 'grain', 'plant_id' => 1, 'score' => 70, 'at' => now()]);
$r0 = (int)q_val('SELECT ribbons FROM users WHERE id = ?', [$uid]);
settle_fair();
ok('old Grains entry placed 1st', (int)q_val("SELECT placed FROM fair_entries WHERE user_id = ? AND month = '2000-01'", [$uid]) === 1);
ok('ribbon recorded under the old key', (bool)q_val("SELECT 1 FROM fair_ribbons WHERE user_id = ? AND month = '2000-01' AND cat = 'grain'", [$uid]));
ok('ribbon counted', (int)q_val('SELECT ribbons FROM users WHERE id = ?', [$uid]) >= $r0 + 1);
ok('profile ribbon row names the old class', str_contains(fair_ribbons_html($uid), 'Grains, 2000-01'), fair_ribbons_html($uid));
q("DELETE FROM settings WHERE name = 'fair_min_entries'"); setting('__reload__');

echo $fails ? "$fails FAILED\n" : "all ok\n";
