<?php
// Treks v2.0.20 text pass (trek_text_pass 7): sluice lines name the water level and the clay layer; Chapter II stash/shrine overrides; Drum Door label.
// Run by treks.sh: php tests/trek_text2020.php GAME_DIR  (a fresh, already-booted install).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
require_once $argv[1] . '/includes/trek_textpass.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$body = fn(string $k) => trim((string)q_val('SELECT body FROM trek_texts WHERE text_key = ?', [$k]));
$snap = fn() => json_encode(q('SELECT text_key, body, status FROM trek_texts ORDER BY text_key')->fetchAll(PDO::FETCH_NUM));
$new = trek_kv_file('trek_final_2020.txt');
$old = trek_kv_file('trek_final_2020_old.txt');
ok('final file has the three sluice rows', array_keys($new) === ['ch2.spot.sluice1.done', 'ch2.spot.sluice2.done', 'ch2.spot.sluice3.done'], implode(',', array_keys($new)));
ok('old file covers the same keys', array_keys($old) === array_keys($new));
foreach ($new as $k => $b) ok("$k names the clay and the water", stripos($b, 'clay') !== false && stripos($b, 'water') !== false);

$reset = function () { q('DELETE FROM trek_texts'); trek_import_texts(); q("DELETE FROM settings WHERE name = 'trek_text_pass'"); setting('__reload__'); trek_text_rows(true); };
echo "== rows holding the previously shipped words are replaced; upgrade path\n";
$reset();
trek_apply_final_texts(); trek_apply_text_204(); trek_apply_text_207(); trek_apply_text_2012(); trek_apply_text_2015();
ok('before the pass the sluices hold the old words', $body('ch2.spot.sluice1.done') === $old['ch2.spot.sluice1.done'] && $body('ch2.spot.sluice3.done') === $old['ch2.spot.sluice3.done']);
$n = trek_apply_text_2020();
ok('pass reports three rows', $n === 3, (string)$n);
foreach ($new as $k => $b) ok("$k replaced", $body($k) === $b);
setting('__reload__');
ok('pass sets trek_text_pass = 7', (int)q_val("SELECT value FROM settings WHERE name = 'trek_text_pass'") === 7);

echo "== an edited row keeps its words; idempotent\n";
q('UPDATE trek_texts SET body = ? WHERE text_key = ?', ['MINE', 'ch2.spot.sluice2.done']);
trek_apply_text_2020();
ok('edited row keeps MINE', $body('ch2.spot.sluice2.done') === 'MINE');
$s1 = $snap(); trek_apply_text_2020(); trek_apply_text_2020();
ok('later runs change nothing', $snap() === $s1);

echo "== Chapter II stash and shrine use their own slots, not Chapter I's\n";
foreach (['ch2.ev.stash.text', 'ch2.ev.stash.dig', 'ch2.ev.shrine.text'] as $k) ok("$k row exists with a body", $body($k) !== '');
$r = trek_text_row('ch2.ev.stash.text');
ok('stash text resolves to ch2 slot', ($r['text_key'] ?? '') === 'ch2.ev.stash.text' && stripos($r['body'], 'clay') !== false);
$r = trek_text_row('ch2.ev.stash.dig');
ok('stash dig resolves to ch2 slot, clay not roots', ($r['text_key'] ?? '') === 'ch2.ev.stash.dig' && stripos($r['body'], 'clay') !== false && stripos($r['body'], 'root') === false);
ok('Chapter I stash is unchanged', stripos($body('ch1.ev.stash.text'), 'roots') !== false);
ok('shrine in Ch II has no roots', stripos($body('ch2.ev.shrine.text'), 'root') === false);
ok('Chapter I stash still the fallback for ch3', (trek_text_row('ch3.ev.stash.text')['text_key'] ?? '') === 'ch1.ev.stash.text');
ok('Tumble brief says easier, less tiring', stripos((string)q_val('SELECT brief FROM trek_texts WHERE text_key = ?', ['ch2.crew.tumble.done']), 'an easier, less tiring stretch') !== false);

echo "== Drum Door label\n";
$sp = trek_spots(2);
ok('drumdoor is a chest with verb=door', ($sp['drumdoor']['type'] ?? '') === 'chest' && ($sp['drumdoor']['data']['verb'] ?? '') === 'door');
ok('other chests have no verb', count(array_filter($sp, fn($s) => $s['type'] === 'chest' && isset($s['data']['verb']))) === 1);
$src = file_get_contents($argv[1] . '/trek.php');
ok('trek.php prints the door label', str_contains($src, '🚪 Open the door') && str_contains($src, '🧰 Open the chest'));

$reset(); trek_apply_final_texts(); trek_apply_text_204(); trek_apply_text_207(); trek_apply_text_2012(); trek_apply_text_2015(); trek_apply_text_2020();
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
