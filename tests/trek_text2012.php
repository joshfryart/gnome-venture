<?php
// Treks v2.0.12 text pass: bodies from trek_final_2012.txt replace shipped bodies; an edited row keeps its words; idempotent;
// the four new Zinnia/Bracken Chapter II banter slots exist; interlude.1 speakers become slugs (only when still the old first name); no TODO/pack-for-satchel text.
// Run by treks.sh: php tests/trek_text2012.php GAME_DIR  (a fresh, already-booted install).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$body = fn(string $k) => trim((string)q_val('SELECT body FROM trek_texts WHERE text_key = ?', [$k]));
$snap = fn() => json_encode(q('SELECT text_key, body, status, speaker FROM trek_texts ORDER BY text_key')->fetchAll(PDO::FETCH_NUM));
$new = trek_kv_file('trek_final_2012.txt');
ok('trek_final_2012.txt has 9 rows', count($new) === 9, (string)count($new));
$reset = function () { q('DELETE FROM trek_texts'); trek_import_texts(); q("DELETE FROM settings WHERE name = 'trek_text_pass'"); setting('__reload__'); trek_text_rows(true); };
$reset();
echo "== new slots and the pass on a drafts-only install\n";
foreach (['zinnia', 'bracken'] as $w) foreach ([1, 2] as $n) ok("ch2.banter.$w.$n exists with a brief and the npc slug speaker", (string)q_val('SELECT brief FROM trek_texts WHERE text_key = ?', ["ch2.banter.$w.$n"]) !== '' && (string)q_val('SELECT speaker FROM trek_texts WHERE text_key = ?', ["ch2.banter.$w.$n"]) !== '');
trek_apply_text_204(); trek_apply_text_207();
$n = trek_apply_text_2012();
ok('pass reports every key', $n === count($new), "$n / " . count($new));
$bad = []; foreach ($new as $k => $b) if ($body($k) !== $b) $bad[] = $k;
ok('every key has its 2.0.12 body', !$bad, implode(', ', $bad));
$all = q('SELECT text_key, body FROM trek_texts')->fetchAll();
$todo = []; foreach ($all as $r) if (strpos((string)$r['body'], 'TODO') !== false) $todo[] = $r['text_key'];
ok('no player body holds TODO', !$todo, implode(', ', $todo));
ok('ch2.intro + ch2.zone.j.arrive say satchel, not pack', strpos($body('ch2.intro'), 'satchel') !== false && strpos($body('ch2.zone.j.arrive'), 'satchel') !== false && strpos($body('ch2.intro') . $body('ch2.zone.j.arrive'), 'your pack') === false);
ok('Tin Lamp keeper no longer says the snail never came back', strpos($body('ch2.camp.innkeeper.greet'), 'never came back') === false);
ok('kiln.open and cook.nofunds differ from their Chapter I twins', $body('ch2.spot.kiln.open') !== $body('ch1.spot.cellar.open') && $body('ch2.camp.cook.nofunds') !== $body('ch1.camp.innkeeper.nofunds'));
foreach (['burdock' => 'burdock-deepdelve', 'zinnia' => 'zinnia-fuzzbottom', 'bracken' => 'bracken-spurwing'] as $s => $slug) ok("interlude.1.$s speaker is $slug", (string)q_val('SELECT speaker FROM trek_texts WHERE text_key = ?', ["interlude.1.$s"]) === $slug);

echo "== an edited row keeps its words; an old speaker is fixed; idempotent\n";
q('UPDATE trek_texts SET body = ? WHERE text_key = ?', ['MINE', 'ch2.intro']);
q('UPDATE trek_texts SET speaker = ? WHERE text_key = ?', ['Burdock', 'interlude.1.burdock']);
trek_apply_text_2012();
ok('edited row keeps MINE', $body('ch2.intro') === 'MINE', $body('ch2.intro'));
ok('old first-name speaker becomes the slug again', (string)q_val('SELECT speaker FROM trek_texts WHERE text_key = ?', ['interlude.1.burdock']) === 'burdock-deepdelve');
$s1 = $snap(); trek_apply_text_2012(); trek_apply_text_2012();
ok('second and third run change nothing', $snap() === $s1);

echo "== sizes\n";
$long = []; foreach ($new as $k => $b) if (count(explode("\n", $b)) > 3 || mb_strlen($b) > 300) $long[] = $k;
ok('no body over 3 lines or 300 chars', !$long, implode(', ', $long));

$reset();
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
