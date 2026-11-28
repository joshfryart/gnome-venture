<?php
declare(strict_types=1);
/**
 * One-time installer. Creates the database tables, starter content and your admin account,
 * then writes config.php. Once config.php exists this page refuses to run.
 * DELETE THIS FILE from your host after installing.
 */
define('APP_ROOT', __DIR__);
// The version lives only in includes/bootstrap.php (bootstrap exits when config.php is missing, so read the constant from it).
define('APP_VERSION', preg_match("/define\\('APP_VERSION', '([0-9.]+)'\\)/", (string)@file_get_contents(__DIR__ . '/includes/bootstrap.php'), $m_v) ? $m_v[1] : '0');
require __DIR__ . '/includes/db.php';
require __DIR__ . '/includes/functions.php';
require __DIR__ . '/includes/pixel_art.php';   // v2.0.31: pixel_has() is called by the item seeders (garden100_items etc.)
require __DIR__ . '/includes/seed.php';

send_security_headers();
start_secure_session();

if (is_file(__DIR__ . '/config.php')) {
    http_response_code(403);
    exit('Already installed. For safety, delete install.php from your server.');
}

$errors = [];
$v = [
    'driver' => $_POST['driver'] ?? 'mysql',
    'host' => $_POST['host'] ?? 'localhost',
    'port' => $_POST['port'] ?? '3306',
    'name' => $_POST['name'] ?? '',
    'user' => $_POST['user'] ?? '',
    'site_name' => $_POST['site_name'] ?? 'Gnome Venture',
    'base_url' => $_POST['base_url'] ?? rtrim(dirname($_SERVER['SCRIPT_NAME'] ?? '/'), '/\\'),
    'admin_user' => $_POST['admin_user'] ?? '',
    'admin_email' => $_POST['admin_email'] ?? '',
    // Private test site (includes/lockdown.php): only the main site's admin gets in, signed in from the main site (SSO)
    'sso_main' => $_POST['sso_main'] ?? 'https://gnomeventure.ca',
    'lock_email' => $_POST['lock_email'] ?? '',
    'lock_mode' => $_POST['lock_mode'] ?? 'sso',
    'sso_secret' => $_POST['sso_secret'] ?? bin2hex(random_bytes(24)),
];
$reqHost = strtolower((string)preg_replace('/[^A-Za-z0-9.:\-\[\]]/', '', (string)($_SERVER['HTTP_HOST'] ?? 'localhost')));
$private = is_post() ? !empty($_POST['private']) : str_starts_with($reqHost, 'test.');

if (is_post()) {
    csrf_check();
    foreach ($v as $k => $val) {
        $v[$k] = is_string($val) ? trim($val) : '';
    }
    $pass = (string)($_POST['admin_pass'] ?? '');
    $pass2 = (string)($_POST['admin_pass2'] ?? '');
    if (!in_array($v['driver'], ['mysql', 'sqlite'], true)) $errors[] = 'Pick a database type.';
    if ($private) {
        // The admin account is the main site's admin: same email. Username and password may be left blank (sign-in is by the main site).
        $v['sso_main'] = rtrim($v['sso_main'], '/');
        if (!preg_match('~^https://[A-Za-z0-9.\-]+(:\d+)?$~', $v['sso_main'])) $errors[] = 'Main site address: like https://gnomeventure.ca (https, no folder).';
        if (!filter_var($v['lock_email'], FILTER_VALIDATE_EMAIL)) $errors[] = 'Main site admin email looks wrong.';
        if (!in_array($v['lock_mode'], ['sso', 'admin'], true)) $errors[] = 'Pick how the admin signs in.';
        if ($v['lock_mode'] === 'sso' && !preg_match('/^[A-Za-z0-9_\-]{32,200}$/', $v['sso_secret'])) $errors[] = 'SSO secret: 32 to 200 letters, numbers, - or _.';
        if ($v['admin_email'] !== '' && strtolower($v['admin_email']) !== strtolower($v['lock_email'])) $errors[] = 'On a private test site the admin account’s email must be the main site admin email (or leave it blank).';
        $v['admin_email'] = $v['lock_email'];
        if ($v['admin_user'] === '') $v['admin_user'] = substr((string)preg_replace('/[^A-Za-z0-9_]/', '', strstr($v['lock_email'], '@', true) ?: ''), 0, 20) ?: 'admin';
        if (strlen($v['admin_user']) < 3) $v['admin_user'] = str_pad($v['admin_user'], 3, '_');
        if ($pass === '' && $pass2 === '' && $v['lock_mode'] === 'sso') { $pass = $pass2 = bin2hex(random_bytes(32)); }   // nobody knows it: sign-in is only by the main site
    }
    if (!preg_match('/^[A-Za-z0-9_]{3,20}$/', $v['admin_user'])) $errors[] = 'Admin username: 3–20 letters, numbers or _.';
    if (!filter_var($v['admin_email'], FILTER_VALIDATE_EMAIL)) $errors[] = 'Admin email looks wrong.';
    if (strlen($pass) < 12) $errors[] = 'Admin password must be at least 12 characters.';
    if ($pass !== $pass2) $errors[] = 'Admin passwords do not match.';

    if ($v['driver'] === 'sqlite') {
        // Stored relative to the game folder, so the folder can be moved after installing
        $dbConf = ['driver' => 'sqlite', 'path' => 'data/game.sqlite'];
        if (!is_dir(__DIR__ . '/data') || !is_writable(__DIR__ . '/data')) $errors[] = 'The data/ folder must exist and be writable.';
    } else {
        $dbConf = ['driver' => 'mysql', 'host' => $v['host'], 'port' => (int)$v['port'],
            'name' => $v['name'], 'user' => $v['user'], 'pass' => (string)($_POST['pass'] ?? '')];
    }

    if (!$errors) {
        @set_time_limit(900);       // the first import adds thousands of rows: give slow shared hosts time
        @ignore_user_abort(true);   // and keep going even if the browser gives up waiting
        try {
            $GLOBALS['CONFIG'] = ['db' => $dbConf, 'base_url' => $v['base_url']];
            db();
        } catch (Throwable $e) {
            $errors[] = 'Could not connect to the database: ' . $e->getMessage();
        }
    }

    if (!$errors) {
        try {
            db_migrate(db(), $dbConf['driver']);
            if ((int)q_val('SELECT COUNT(*) FROM users') > 0) {
                throw new RuntimeException('This database already has players in it. Use an empty database.');
            }
            db()->beginTransaction();
            foreach (settings_schema() as $k => $def) {
                set_setting($k, (string)$def['default']);
            }
            set_setting('site_name', $v['site_name'] ?: 'Gnome Venture');
            // Links in emails: the address used to install (the admin can change it in Game settings)
            $host = preg_replace('/[^A-Za-z0-9.:\-\[\]]/', '', (string)($_SERVER['HTTP_HOST'] ?? 'localhost'));
            set_setting('site_url', ((!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https://' : 'http://') . $host);
            if ($dbConf['driver'] === 'sqlite') set_setting('mail_mode', 'log');   // a PC can't send email: write it to the mail log
            if ($private) {   // a private test site never emails anyone, takes no sign-ups or guests
                set_setting('mail_mode', 'log');
                set_setting('registration_open', '0');
                set_setting('guest_open', '0');
                set_setting('site_url', 'https://' . preg_replace('/:\d+$/', '', $host));
            }
            set_setting('db_version', APP_VERSION);
            setting('__reload__');
            seed_starter_content();
            $uid = db_insert('users', [
                'username' => $v['admin_user'], 'email' => strtolower($v['admin_email']),
                'password_hash' => password_hash($pass, PASSWORD_DEFAULT), 'role' => 'admin',
                'coins' => (int)setting('starting_coins'), 'created_at' => now(), 'onboarded' => 0,
            ]);
            // The admin creates their gnome and first garden in the welcome flow, like every player.
            db()->commit();

            $config = [
                'db' => $dbConf,
                'base_url' => $v['base_url'],
                'debug' => false,
            ];
            if ($private) {
                $config['lockdown'] = $v['lock_mode'];
                $config['lockdown_email'] = strtolower($v['lock_email']);
                $config['sso_main'] = $v['sso_main'];
                if ($v['lock_mode'] === 'sso') $config['sso_secret'] = $v['sso_secret'];
            }
            $php = "<?php\n// Generated by install.php. Keep this file private.\nreturn " . var_export($config, true) . ";\n";
            if (file_put_contents(__DIR__ . '/config.php', $php, LOCK_EX) === false) {
                throw new RuntimeException('Could not write config.php. Make the site folder writable, or create config.php by hand with this content:' . "\n\n" . $php);
            }
            @chmod(__DIR__ . '/config.php', 0640);
            if ($private) @file_put_contents(__DIR__ . '/robots.txt', "# Private test site: nothing here is for search engines.\nUser-agent: *\nDisallow: /\n", LOCK_EX);   // same text as LOCKDOWN_ROBOTS (includes/lockdown.php), which keeps it so after updates
            $done = true;
        } catch (Throwable $e) {
            if (db()->inTransaction()) db()->rollBack();
            $errors[] = $e->getMessage();
        }
    }
}
?><!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Install</title><link rel="stylesheet" href="assets/style.css"></head>
<body class="game"><header class="banner"><span class="logo">Garden game installer</span></header>
<div class="wrap"><main class="narrowmain">
<?php if (!empty($done)): ?>
  <div class="box"><h2>All planted! 🌱</h2>
  <p>Your game is installed and your admin account is ready.</p>
  <?php if ($private && $v['lock_mode'] === 'sso'): $tHost = (string)preg_replace('/:\d+$/', '', $reqHost); ?>
  <h3>Private test site: one more step on the main site</h3>
  <p>This is the SSO secret. It is shown only now (it is also in <code>config.php</code>). Copy it:</p>
  <p><input readonly value="<?= e($v['sso_secret']) ?>" aria-label="SSO secret" size="56"></p>
  <ol>
    <li>On <?= e((string)parse_url($v['sso_main'], PHP_URL_HOST)) ?>, deploy the web update that includes <code>sso_issue.php</code> (main site first).</li>
    <li>On <?= e((string)parse_url($v['sso_main'], PHP_URL_HOST)) ?> open Admin &gt; Game settings and set <b>SSO secret</b> to this value, and <b>SSO targets</b> to <code><?= e($tHost) ?></code>. Save.</li>
    <li>Log in on the main site as the admin with the email <code><?= e(strtolower($v['lock_email'])) ?></code>, then open this site's sign-in page and press <b>Sign in with <?= e((string)parse_url($v['sso_main'], PHP_URL_HOST)) ?></b>.</li>
  </ol>
  <?php elseif ($private): ?>
  <p>Private test site: only the admin account with the email <code><?= e(strtolower($v['lock_email'])) ?></code> can sign in, with the password you chose.</p>
  <?php endif; ?>
  <p><strong>Now delete <code>install.php</code> from your server.</strong></p>
  <p><a class="btn" href="login.php">Log in</a></p></div>
<?php else: ?>
  <?php foreach ($errors as $err): ?><div class="flash err"><?= nl2br(e($err)) ?></div><?php endforeach; ?>
  <form method="post" class="box form">
    <?= csrf_field() ?>
    <h2>1. Database</h2>
    <label>Type
      <select name="driver">
        <option value="mysql" <?= $v['driver'] === 'mysql' ? 'selected' : '' ?>>MySQL / MariaDB (your web host)</option>
        <option value="sqlite" <?= $v['driver'] === 'sqlite' ? 'selected' : '' ?>>SQLite (testing on your own computer)</option>
      </select></label>
    <p class="help">For MySQL, create an empty database in your host's control panel first, then copy its details here.</p>
    <label>Host <input name="host" value="<?= e($v['host']) ?>"></label>
    <label>Port <input name="port" value="<?= e($v['port']) ?>"></label>
    <label>Database name <input name="name" value="<?= e($v['name']) ?>"></label>
    <label>Database user <input name="user" value="<?= e($v['user']) ?>" autocomplete="off"></label>
    <label>Database password <input type="password" name="pass" autocomplete="off"></label>
    <h2>2. Your game</h2>
    <label>Game name <input name="site_name" value="<?= e($v['site_name']) ?>"></label>
    <label>Web folder (leave as-is unless you know otherwise) <input name="base_url" value="<?= e($v['base_url']) ?>"></label>
    <h2>3. Private test site</h2>
    <label class="check"><input type="checkbox" name="private" value="1" <?= $private ? 'checked' : '' ?>> This is a private test site (like test.gnomeventure.ca): only the main site's admin can get in</label>
    <p class="help">Ticked: everyone else is sent to the sign-in page, sign-ups, guests and password resets are off, search engines are told to stay away and email is only written to the mail log. Leave it unticked for a normal game.</p>
    <label>Main site address <input name="sso_main" value="<?= e($v['sso_main']) ?>"></label>
    <label>Main site admin email (the admin account on the main site) <input type="email" name="lock_email" value="<?= e($v['lock_email']) ?>"></label>
    <label>How the admin signs in
      <select name="lock_mode">
        <option value="sso" <?= $v['lock_mode'] === 'sso' ? 'selected' : '' ?>>Sign in with the main site (single sign-on, no password here)</option>
        <option value="admin" <?= $v['lock_mode'] === 'admin' ? 'selected' : '' ?>>Admin password on this site (no single sign-on)</option>
      </select></label>
    <label>SSO secret (made for you; you copy it to the main site after installing) <input name="sso_secret" value="<?= e($v['sso_secret']) ?>" autocomplete="off" size="56"></label>
    <h2>4. Your admin account</h2>
    <p class="help">For a private test site with single sign-on, username and password may be left blank: the account gets the main site admin email and a random password nobody knows.</p>
    <label>Username <input name="admin_user" value="<?= e($v['admin_user']) ?>"></label>
    <label>Email <input type="email" name="admin_email" value="<?= e($v['admin_email']) ?>"></label>
    <label>Password (12+ characters) <input type="password" name="admin_pass" minlength="12"></label>
    <label>Password again <input type="password" name="admin_pass2" minlength="12"></label>
    <button class="btn">Install</button>
  </form>
<?php endif; ?>
</main></div></body></html>
