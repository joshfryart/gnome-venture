<?php
// Treks v2.0.7 text pass: bodies from trek_final_207.txt replace shipped bodies (draft / 2.0.0 / 2.0.4 final); an edited row keeps its words;
// idempotent; the new slot ch2.banter.burdock.2 exists; every fixed body fits the phone card (<= 200 chars for tutorials, <= 4 lines).
// Run by treks.sh: php tests/trek_text207.php GAME_DIR  (a fresh, already-booted install).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$body = fn(string $k) => trim((string)q_val('SELECT body FROM trek_texts WHERE text_key = ?', [$k]));
$snap = fn() => json_encode(q('SELECT text_key, body, status FROM trek_texts ORDER BY text_key')->fetchAll(PDO::FETCH_NUM));
$new = trek_kv_file('trek_final_207.txt');
$f204 = trek_kv_file('trek_final_204.txt');
ok('trek_final_207.txt has rows', count($new) >= 10, (string)count($new));

q('DELETE FROM trek_texts'); trek_import_texts(); q("DELETE FROM settings WHERE name = 'trek_text_pass'"); setting('__reload__'); trek_text_rows(true);
echo "== the new slot and the pass on a drafts-only install\n";
ok('slot ch2.banter.burdock.2 exists with a brief', (string)q_val('SELECT brief FROM trek_texts WHERE text_key = ?', ['ch2.banter.burdock.2']) !== '');
trek_apply_text_204();
$n = trek_apply_text_207();
ok('pass reports every key', $n === count($new), "$n / " . count($new));
$bad = []; foreach ($new as $k => $b) if ($body($k) !== $b) $bad[] = $k;
ok('every key has its 2.0.7 body', !$bad, implode(', ', $bad));
ok('new slot has a non-empty body and a status', $body('ch2.banter.burdock.2') !== '' && (string)q_val('SELECT status FROM trek_texts WHERE text_key = ?', ['ch2.banter.burdock.2']) !== '');

echo "== an edited row keeps its words; a 2.0.4 row is replaced; idempotent\n";
$keys = array_keys($new);
$edited = $keys[0]; $old = null;
foreach ($keys as $k) if (isset($f204[$k]) && $k !== $edited) { $old = $k; break; }
ok('found test rows', $old !== null);
q('UPDATE trek_texts SET body = ? WHERE text_key = ?', ['MINE', $edited]);
q('UPDATE trek_texts SET body = ? WHERE text_key = ?', [$f204[$old], $old]);
trek_apply_text_207();
ok('edited row keeps MINE', $body($edited) === 'MINE', $body($edited));
ok('row holding its 2.0.4 final gets the 2.0.7 body', $body($old) === $new[$old], $body($old));
$s1 = $snap(); trek_apply_text_207(); trek_apply_text_207();
ok('second and third run change nothing', $snap() === $s1);

echo "== sizes\n";
foreach (['ch1.tut.treklevel', 'ch1.tut.firstfight'] as $k) ok("$k <= 200 chars", mb_strlen($new[$k]) <= 200, (string)mb_strlen($new[$k]));
$long = []; foreach ($new as $k => $b) if (count(explode("\n", $b)) > 4) $long[] = $k;
ok('no fixed body longer than 4 lines', !$long, implode(', ', $long));

echo "== party-full note\n";
ok('trek_recruit_crew returns bool and trek_benched_line names the trailmate', trek_benched_line('Sorrel Inkcap') !== '' && strpos(trek_benched_line('Sorrel Inkcap'), 'full') !== false);

q('DELETE FROM trek_texts'); trek_import_texts(); q("DELETE FROM settings WHERE name = 'trek_text_pass'"); setting('__reload__'); trek_text_rows(true);
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
