<?php
// Treks v2.0.20 text pass 8 (trek_text_pass 8): camp-type rests are full rests, the kit / old campsite / rest spot lines say rested and whole.
// Run by treks.sh: php tests/trek_text2021.php GAME_DIR  (a fresh, already-booted install).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
require_once $argv[1] . '/includes/trek_textpass.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$body = fn(string $k) => trim((string)q_val('SELECT body FROM trek_texts WHERE text_key = ?', [$k]));
$snap = fn() => json_encode(q('SELECT text_key, body, status FROM trek_texts ORDER BY text_key')->fetchAll(PDO::FETCH_NUM));
$new = trek_kv_file('trek_final_2021.txt');
$old = trek_kv_file('trek_final_2021_old.txt');
ok('final file has 6 rows', count($new) === 6, implode(',', array_keys($new)));
ok('old file covers the same keys', array_keys($old) === array_keys($new));
foreach ($new as $k => $b) ok("$k: says rested/whole, no half or numbers", (stripos($b, 'whole') !== false) && !preg_match('/half|much better|short|\d/i', $b));

$reset = function () { q('DELETE FROM trek_texts'); trek_import_texts(); q("DELETE FROM settings WHERE name = 'trek_text_pass'"); setting('__reload__'); trek_text_rows(true); };
$earlier = function () { trek_apply_final_texts(); trek_apply_text_204(); trek_apply_text_207(); trek_apply_text_2012(); trek_apply_text_2015(); trek_apply_text_2020(); };
echo "== rows holding the previously shipped words are replaced; upgrade path\n";
$reset(); $earlier();
$have = 0; foreach ($old as $k => $b) if ($body($k) === $b) $have++;
ok('before pass 8 every slot holds the old words (' . $have . ' of ' . count($old) . ')', $have === count($old), $have . '');
$n = trek_apply_text_2021();
ok('pass reports six rows', $n === 6, (string)$n);
foreach ($new as $k => $b) ok("$k replaced", $body($k) === $b);
setting('__reload__');
ok('pass sets trek_text_pass = 8', (int)q_val("SELECT value FROM settings WHERE name = 'trek_text_pass'") === 8);

echo "== an edited row keeps its words; idempotent\n";
q('UPDATE trek_texts SET body = ? WHERE text_key = ?', ['MINE', 'ch2.oldcamp.rest']);
trek_apply_text_2021();
ok('edited row keeps MINE', $body('ch2.oldcamp.rest') === 'MINE');
$s1 = $snap(); trek_apply_text_2021(); trek_apply_text_2021();
ok('later runs change nothing', $snap() === $s1);
ok('the cold rest line is untouched', stripos($body('ch1.camp.makecamp.free'), 'not as good as a kit') !== false);

echo "== a fresh install (seed) already ends on the new words\n";
$reset(); $earlier(); trek_apply_text_2021();
ok('fresh: kit line is the new one', $body('ch1.camp.makecamp') === $new['ch1.camp.makecamp']);
ok('briefs no longer say "not as good as a proper camp" for the old camp rest slots', !(int)q_val("SELECT COUNT(*) FROM trek_texts WHERE text_key LIKE '%oldcamp.rest' AND brief LIKE '%not as good as a proper camp%'"));
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
