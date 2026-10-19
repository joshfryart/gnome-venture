<?php
$_SERVER['SCRIPT_NAME'] = '/admin/update.php';
require $argv[1] . '/includes/bootstrap.php';
require $argv[1] . '/includes/updater.php';
$info = update_inspect($argv[2]);
echo "version ", $info['version'] ?? '?', " · files ", count($info['files'] ?? []), " · skipped: ", implode(', ', $info['skipped'] ?? []) ?: '(none)', "\n";
copy($argv[2], update_dir('update') . '/pending.zip');
$admin = q_one("SELECT * FROM users WHERE role = 'admin' LIMIT 1");
[$ok, $msg] = update_install($admin, 'TestPassword123', false);
echo ($ok ? 'OK ' : 'FAIL ') . $msg, "\n";
