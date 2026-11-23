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
ok('classes are produce, flower, preserve, diorama (2.7.58)', array_keys(FAIR_CATS) === ['produce', 'flower', 'preserve', 'diorama'], implode(',', array_keys(FAIR_CATS)));
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

echo "== 2.7.58 creature diorama class\n";
require_once $argv[1] . '/includes/parts.php';
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
q('DELETE FROM fair_best WHERE user_id = ?', [$uid]); q('DELETE FROM fair_entries WHERE user_id = ?', [$uid]);
foreach (['hide', 'plate', 'wing', 'ooze', 'silk', 'gem'] as $f) foreach (part_family_items($f) as $it) q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $it['id']]);
ok('diorama has no plant kinds (like Preserves)', FAIR_CATS['diorama'][2] === [] && fair_cat_label('diorama') === 'Creature diorama');
[$o, $m] = fair_enter($u, 'diorama');
ok('no parts: refused, nothing entered', !$o && !q_val("SELECT 1 FROM fair_entries WHERE user_id = ? AND cat = 'diorama'", [$uid]), $m);
$c1 = part_family_items('hide')[0]; $c2 = part_family_items('plate')[0]; $c3 = part_family_items('wing')[0];
$rareAny = null; foreach (['plate', 'hide', 'wing', 'ooze', 'silk', 'gem'] as $f) { $r = part_family_items($f, true); if ($r) { $rareAny = $r[0]; $rareFam = $f; break; } }
ok('have three common parts and a rare one to test with', $c1 && $c2 && $c3 && $rareAny);
give_item($uid, $c1['id'], 4); give_item($uid, $c2['id'], 2); give_item($uid, $c3['id'], 1); give_item($uid, $rareAny['id'], 1);
$fams = count(array_unique(['hide', 'plate', 'wing', $rareFam]));
ok('fair_diorama_score: families x 10 + rare parts x 5 (capped at 100)', fair_diorama_score([$c1, $c2, $c3, $rareAny]) === $fams * 10 + 5 && fair_diorama_score(array_fill(0, 12, $rareAny)) <= 100, (string)fair_diorama_score([$c1, $c2, $c3, $rareAny]));
$want = $fams * 10 + 5;
[$o, $m] = fair_enter($u, 'diorama');
$e = q_one("SELECT score, label FROM fair_entries WHERE user_id = ? AND cat = 'diorama'", [$uid]);
ok('entered: the score is families x 10 + rare x 5', $o && $e && (int)$e['score'] === $want, $m . ' ' . json_encode($e));
$have = fn($it) => (int)q_val('SELECT COALESCE(SUM(qty), 0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $it['id']]);
ok('one of each distinct part was used up, the spares stay', $have($c1) === 3 && $have($c2) === 1 && $have($c3) === 0 && $have($rareAny) === 0, json_encode([$have($c1), $have($c2), $have($c3), $have($rareAny)]));
ok('the entry is in fair_best too (via fair_keep_best)', (int)q_val("SELECT score FROM fair_best WHERE user_id = ? AND cat = 'diorama' AND month = ?", [$uid, $month]) === $want);
[$o, $m] = fair_enter($u, 'diorama');
ok('a weaker diorama is refused and keeps the parts', !$o && $have($c1) === 3, $m);
give_item($uid, part_family_items('ooze')[0]['id'], 1); give_item($uid, part_family_items('silk')[0]['id'], 1);
[$o, $m] = fair_enter($u, 'diorama');
ok('a better one (two more families) replaces the entry', $o && (int)q_val("SELECT score FROM fair_entries WHERE user_id = ? AND cat = 'diorama'", [$uid]) > $want, $m);
q('DELETE FROM fair_best WHERE user_id = ?', [$uid]); q('DELETE FROM fair_entries WHERE user_id = ?', [$uid]);

echo $fails ? "$fails FAILED\n" : "all ok\n";
