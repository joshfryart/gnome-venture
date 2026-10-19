<?php
$_SERVER['SCRIPT_NAME'] = '/admin/update.php';
require $argv[1] . '/includes/bootstrap.php';
require $argv[1] . '/includes/updater.php';
$zipPath = sys_get_temp_dir() . '/evil-update.zip';
@unlink($zipPath);
$z = new ZipArchive(); $z->open($zipPath, ZipArchive::CREATE);
$z->addFromString('includes/bootstrap.php', "<?php define('APP_VERSION', '9.9.9');");
$z->addFromString('index.php', '<?php echo 1;');
$evil = ['../evil.php', '../../tmp/evil2.php', 'uploads/shell.php', 'data/x.php', 'config.php', 'install.php', '/etc/evil.php',
         '.user.ini', 'includes/.env', 'a\\..\\b.php', 'evil.phtml', 'evil.phar', 'assets/x.php' . "\0" . '.png', 'admin/../../outside.php', 'data/../config.php', '.htaccess'];
foreach ($evil as $e) $z->addFromString($e, '<?php system($_GET["c"]);');
$z->close();
$info = update_inspect($zipPath);
$accepted = array_keys($info['files'] ?? []);
echo "accepted for writing: ", implode(', ', $accepted), "\n";
echo "skipped: ", implode(', ', $info['skipped'] ?? []), "\n";
$bad = array_values(array_filter($accepted, fn($p) => !in_array($p, ['includes/bootstrap.php', 'index.php', '.htaccess'], true)));
echo $bad ? "PROBLEM: " . implode(', ', $bad) . "\n" : "OK: nothing outside the game files, no config/data/uploads, no odd file types\n";
// wrong password
copy($zipPath, update_dir('update') . '/pending.zip');
$admin = q_one("SELECT * FROM users WHERE role = 'admin' LIMIT 1");
[$ok, $msg] = update_install($admin, 'wrongpassword', true);
echo "install with wrong password: ", $ok ? 'INSTALLED (BAD)' : 'refused: ' . $msg, "\n";
@unlink(update_dir('update') . '/pending.zip');
[$ok, $msg] = update_restore($admin, 'TestPassword123', '../../config.php');
echo "restore with a path trick: ", $ok ? 'RAN (BAD)' : 'refused: ' . $msg, "\n";
