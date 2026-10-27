<?php
// v2.1 updater: maintenance lock, automatic rollback on a mid-install write failure, integrity check. Run by updrollback.sh on a fresh install.
$_SERVER['SCRIPT_NAME'] = '/admin/update.php';
require $argv[1] . '/includes/bootstrap.php';
require $argv[1] . '/includes/updater.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function mkzip(array $f): string { $p = sys_get_temp_dir() . '/updrb-' . bin2hex(random_bytes(3)) . '.zip'; $z = new ZipArchive(); $z->open($p, ZipArchive::CREATE); foreach ($f as $n => $d) $z->addFromString($n, $d); $z->close(); return $p; }
$admin = q_one("SELECT * FROM users WHERE role = 'admin' LIMIT 1");
$boot = file_get_contents(APP_ROOT . '/includes/bootstrap.php');
$v = '9.9.9';
$newBoot = preg_replace("/define\\('APP_VERSION', '[0-9.]+'\\)/", "define('APP_VERSION', '$v')", $boot);
$idx = file_get_contents(APP_ROOT . '/index.php');
$hash = fn(string $rel) => is_file(APP_ROOT . "/$rel") ? sha1_file(APP_ROOT . "/$rel") : 'absent';
$before = ['index' => $hash('index.php'), 'boot' => $hash('includes/bootstrap.php')];

echo "== mid-install write failure -> rollback + lock release\n";
// zzz-block.php is a directory, so replacing it with a file fails after index.php (and 'a-new.php') were already written
mkdir(APP_ROOT . '/zzz-block.php');
$zip = mkzip(['includes/bootstrap.php' => $newBoot, 'index.php' => $idx . "\n// changed\n", 'a-new.php' => '<?php // new', 'zzz-block.php' => '<?php // cannot land']);
copy($zip, update_dir('update') . '/pending.zip');
set_setting('maintenance_mode', '0'); setting('__reload__');
[$okI, $msg] = update_install($admin, 'TestPassword123', false);
echo "  message: $msg\n";
ok('install reports failure', !$okI);
ok('message says rolled back', str_contains($msg, 'rolled back'));
ok('index.php restored byte-for-byte', $hash('index.php') === $before['index']);
ok('bootstrap.php untouched', $hash('includes/bootstrap.php') === $before['boot']);
ok('newly created file removed', !is_file(APP_ROOT . '/a-new.php'));
ok('no temp files left', !glob(APP_ROOT . '/*.upd-*') && !glob(APP_ROOT . '/*.rb'));
ok('maintenance lock released (was off)', setting('maintenance_mode') === '0');
ok('failure logged', (bool)q_val("SELECT 1 FROM admin_log WHERE action='update_failed' LIMIT 1"));
ok('safety copies cleaned up', !glob(update_dir('backups') . '/preimage-*'));
rmdir(APP_ROOT . '/zzz-block.php'); @unlink(update_dir('update') . '/pending.zip');

echo "== lock is on during the install and an admin's own maintenance mode survives\n";
set_setting('maintenance_mode', '1'); setting('__reload__');
mkdir(APP_ROOT . '/zzz-block.php');
copy($zip, update_dir('update') . '/pending.zip');
[$okI] = update_install($admin, 'TestPassword123', false);
ok('failed again as expected', !$okI);
ok('maintenance stays on if the admin had it on', setting('maintenance_mode') === '1');
rmdir(APP_ROOT . '/zzz-block.php'); @unlink(update_dir('update') . '/pending.zip');
set_setting('maintenance_mode', '0'); setting('__reload__');
$prev = update_lock_on();
ok('update_lock_on turns it on and returns the old value', $prev === '0' && setting('maintenance_mode') === '1');
update_lock_off($prev);
ok('update_lock_off restores it', setting('maintenance_mode') === '0');

echo "== integrity check\n";
$files = ['index.php' => 0, 'includes/bootstrap.php' => 1];
$same = mkzip(['index.php' => $idx, 'includes/bootstrap.php' => $boot]);
ok('matching files verify clean', update_verify($same, $files) === []);
$tamper = mkzip(['index.php' => $idx . 'x', 'includes/bootstrap.php' => $boot, 'ghost.php' => '<?php']);
ok('hash mismatch and missing file are both caught', update_verify($tamper, $files + ['ghost.php' => 2]) === ['index.php', 'ghost.php']);

echo "== rollback helper\n";
file_put_contents(APP_ROOT . '/rb-old.php', '<?php // original');
$pdir = sys_get_temp_dir() . '/pre-' . bin2hex(random_bytes(3)); mkdir($pdir);
copy(APP_ROOT . '/rb-old.php', $pdir . '/x');
file_put_contents(APP_ROOT . '/rb-old.php', '<?php // overwritten'); file_put_contents(APP_ROOT . '/rb-new.php', '<?php');
ok('rollback reports nothing failed', update_rollback(['rb-old.php' => $pdir . '/x', 'rb-new.php' => null]) === []);
ok('overwritten file restored, new file gone', file_get_contents(APP_ROOT . '/rb-old.php') === '<?php // original' && !is_file(APP_ROOT . '/rb-new.php'));
@unlink(APP_ROOT . '/rb-old.php'); update_rmdir($pdir);

echo "== successful install still works (and releases the lock)\n";
set_setting('maintenance_mode', '0'); setting('__reload__');
$good = mkzip(['includes/bootstrap.php' => $newBoot, 'index.php' => $idx . "\n// changed\n"]);
copy($good, update_dir('update') . '/pending.zip');
[$okI, $msg] = update_install($admin, 'TestPassword123', true);
echo "  message: $msg\n";
ok('install ok', $okI);
ok('files match the zip', $hash('index.php') === sha1($idx . "\n// changed\n") && str_contains(file_get_contents(APP_ROOT . '/includes/bootstrap.php'), "'$v'"));
ok('lock released after success', setting('maintenance_mode') === '0');
ok('safety copies cleaned up', !glob(update_dir('backups') . '/preimage-*'));
echo $fails ? "\n$fails FAILED\n" : "\nall passed\n";
exit($fails ? 1 : 0);
