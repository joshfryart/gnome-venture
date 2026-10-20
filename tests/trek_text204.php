<?php
// Treks v2.0.4 text pass: bodies from trek_final_204.txt land on a fresh install; an edited row keeps its words; a row still holding the 2.0.0 final
// (or a shipped draft) takes the new body; the pass is idempotent; every key in the file is a slot.
// Run by treks.sh after the 2.0.1 checks: php tests/trek_text204.php GAME_DIR  (a fresh, already-booted install).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$body = fn(string $k) => trim((string)q_val('SELECT body FROM trek_texts WHERE text_key = ?', [$k]));
$snap = fn() => json_encode(q('SELECT text_key, body, status FROM trek_texts ORDER BY text_key')->fetchAll(PDO::FETCH_NUM));

// start from what the harness install holds: the drafts, no text pass (earlier suites may have rewritten rows)
q('DELETE FROM trek_texts'); trek_import_texts(); q("DELETE FROM settings WHERE name = 'trek_text_pass'"); setting('__reload__'); trek_text_rows(true);
echo "== fresh install, then a boot: the 2.0.4 bodies are in\n";
// The harness install seeds the drafts and stamps db_version (seed.php does not run the text passes), so the boot is what a version upgrade does:
// db_version is reset, a new PHP process loads bootstrap.php (boot steps: trek_bodies_200, then trek_bodies_204).
$pass0 = (string)setting('trek_text_pass');
ok('(info) fresh install: trek_text_pass before the boot is "' . $pass0 . '"', true);
set_setting('db_version', '0.0.0');
set_setting('trek_text_pass', '');
$out = []; exec(escapeshellarg(PHP_BINARY) . ' -d display_errors=1 -r ' . escapeshellarg('$_SERVER["SCRIPT_NAME"]="/trek.php"; require ' . var_export($argv[1] . '/includes/bootstrap.php', true) . '; echo "booted";') . ' 2>&1', $out);
ok('the boot ran clean', implode("\n", $out) === 'booted', implode(' | ', $out));
setting('__reload__');
ok('db_version is back to the app version, no failed boot step', setting('db_version') === APP_VERSION && (string)setting('boot_failed_steps') === '', (string)setting('db_version') . ' / ' . (string)setting('boot_failed_steps'));
$new = trek_kv_file('trek_final_204.txt');
$f200 = trek_kv_file('trek_final_200.txt');
$n207 = trek_kv_file('trek_final_207.txt') + trek_kv_file('trek_final_2012.txt') + trek_kv_file('trek_final_2015.txt') + trek_kv_file('trek_final_2020.txt') + trek_kv_file('trek_final_2021.txt');   // v2.0.7, v2.0.12, v2.0.15 and v2.0.20 (passes 7 and 8) replace a few 2.0.4 bodies at boot
$exp = fn(string $k) => $n207[$k] ?? $new[$k];
$drafts = trek_drafts();
ok('trek_final_204.txt has rows', count($new) >= 50, (string)count($new));
ok('trek_text_pass is 8 after boot (2.0.4, 2.0.7, 2.0.12, 2.0.15, then the 2.0.20 passes 7 and 8)', setting('trek_text_pass') === '8', (string)setting('trek_text_pass'));
$missing = []; $wrong = [];
foreach ($new as $k => $b) {
    if (!q_val('SELECT 1 FROM trek_texts WHERE text_key = ?', [$k])) { $missing[] = $k; continue; }
    if ($body($k) !== $exp($k)) $wrong[] = $k;
}
ok('every key in trek_final_204.txt exists as a slot', !$missing, implode(', ', array_slice($missing, 0, 8)));
ok('every row has the 2.0.4 body (or its 2.0.7 fix) after boot', !$wrong, implode(', ', array_slice($wrong, 0, 8)));
ok('no empty body among the 2.0.4 keys', !array_filter(array_keys($new), fn($k) => $body($k) === ''));

echo "== a re-run of the pass\n";
$edited = null; $old200 = null; $oldDraft = null;
foreach ($new as $k => $b) {
    if (isset($n207[$k])) continue;   // test rows: keys the 2.0.7 pass leaves alone
    if ($edited === null) $edited = $k;
    elseif ($old200 === null && isset($f200[$k]) && trim($f200[$k]) !== $b && $k !== $edited) $old200 = $k;
    elseif ($oldDraft === null && !isset($f200[$k]) && isset($drafts[$k]) && trim($drafts[$k]) !== $b && $k !== $edited) $oldDraft = $k;
}
ok('found test rows (edited, old final, old draft)', $edited !== null && $old200 !== null, "$edited / $old200 / $oldDraft");
q('UPDATE trek_texts SET body = ? WHERE text_key = ?', ['MINE', $edited]);
q('UPDATE trek_texts SET body = ? WHERE text_key = ?', [$f200[$old200], $old200]);
if ($oldDraft !== null) q('UPDATE trek_texts SET body = ? WHERE text_key = ?', [$drafts[$oldDraft], $oldDraft]);
set_setting('trek_text_pass', '2');
$n = trek_apply_text_204();
ok('the pass reports rows changed', $n >= 1, (string)$n);
ok('an edited row keeps MINE', $body($edited) === 'MINE', $body($edited));
ok('a row holding its 2.0.0 final gets the new body', $body($old200) === $new[$old200], $body($old200));
if ($oldDraft !== null) ok('a row holding its shipped draft gets the new body', $body($oldDraft) === $new[$oldDraft], $body($oldDraft));
$bad = []; foreach ($new as $k => $b) if ($k !== $edited && !isset($n207[$k]) && $body($k) !== $b) $bad[] = $k;
ok('every other row still has the 2.0.4 body', !$bad, implode(', ', array_slice($bad, 0, 8)));
$s1 = $snap();
trek_apply_text_204();
trek_apply_text_204();
ok('idempotent: a second and third run change nothing', $snap() === $s1);
ok('and the edited row still says MINE', $body($edited) === 'MINE');
// leave the install as a fresh one is (drafts, no text pass), so the suites after this one see what they expect
q('DELETE FROM trek_texts'); trek_import_texts(); q("DELETE FROM settings WHERE name = 'trek_text_pass'"); setting('__reload__'); trek_text_rows(true);
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
