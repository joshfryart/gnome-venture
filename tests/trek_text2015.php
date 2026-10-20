<?php
// Treks v2.0.15 text pass (trek_text_pass 6): Tumble's lines say an easier way, not a short cut. Unedited old rows take the new body; an edited row keeps its words; idempotent.
// Run by treks.sh: php tests/trek_text2015.php GAME_DIR  (a fresh, already-booted install).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$body = fn(string $k) => trim((string)q_val('SELECT body FROM trek_texts WHERE text_key = ?', [$k]));
$snap = fn() => json_encode(q('SELECT text_key, body, status FROM trek_texts ORDER BY text_key')->fetchAll(PDO::FETCH_NUM));
$new = trek_kv_file('trek_final_2015.txt');
$old = trek_kv_file('trek_final_2015_old.txt');
ok('trek_final_2015.txt has the two Tumble rows', array_keys($new) === ['ch2.crew.tumble.talk', 'ch2.crew.tumble.done'], implode(',', array_keys($new)));
ok('old file covers the same keys', array_keys($old) === array_keys($new));
$reset = function () { q('DELETE FROM trek_texts'); trek_import_texts(); q("DELETE FROM settings WHERE name = 'trek_text_pass'"); setting('__reload__'); trek_text_rows(true); };
$reset();
echo "== final files and the pass agree\n";
foreach (['trek_final_200.txt', 'trek_final_204.txt'] as $f) { $t = implode(' ', trek_kv_file($f)); ok("$f no longer promises a short cut", stripos($t, 'short cut') === false); }
trek_apply_final_texts(); trek_apply_text_204(); trek_apply_text_207(); trek_apply_text_2012();
$n = trek_apply_text_2015();
ok('pass reports both rows', $n === 2, (string)$n);
foreach ($new as $k => $b) ok("$k has its 2.0.15 body", $body($k) === $b);
ok('no short cut / way ahead promise left', stripos($body('ch2.crew.tumble.talk') . $body('ch2.crew.tumble.done'), 'short cut') === false);

echo "== rows still holding the previously shipped words are replaced\n";
foreach ($old as $k => $b) q('UPDATE trek_texts SET body = ? WHERE text_key = ?', [$b, $k]);
ok('pass replaces both', trek_apply_text_2015() === 2 && $body('ch2.crew.tumble.talk') === $new['ch2.crew.tumble.talk']);

echo "== an edited row keeps its words; idempotent\n";
q('UPDATE trek_texts SET body = ? WHERE text_key = ?', ['MINE', 'ch2.crew.tumble.talk']);
trek_apply_text_2015();
ok('edited row keeps MINE', $body('ch2.crew.tumble.talk') === 'MINE');
$s1 = $snap(); trek_apply_text_2015(); trek_apply_text_2015();
ok('second and third run change nothing', $snap() === $s1);

$reset();
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
