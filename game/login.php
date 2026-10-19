<?php
declare(strict_types=1);
define('ALLOW_DURING_MAINTENANCE', true);   // so admins can still log in
require __DIR__ . '/includes/bootstrap.php';

if (current_user()) {
    redirect('index.php');
}

$error = '';
$username = '';
if (is_post()) {
    csrf_check();
    $username = trim((string)($_POST['username'] ?? ''));
    $password = (string)($_POST['password'] ?? '');
    $key = 'login:' . strtolower($username);

    if (rate_limited($key, 5, 15) || rate_limited('login:*', 30, 15)) {
        $error = 'Too many tries. Wait 15 minutes and try again.';
    } else {
        $u = q_one('SELECT * FROM users WHERE username = ?', [$username]);
        // password_verify on a dummy hash when the user doesn't exist, so timing doesn't reveal valid usernames
        $hash = $u['password_hash'] ?? '$2y$10$u9xY8hOGvagnFdBa/wPzTeZgKUW2jWG081etOX2xNKbSHPaF40wSu';
        if (password_verify($password, $hash) && $u) {
            if ((int)$u['banned'] === 1) {
                $error = 'This account is banned' . ($u['ban_reason'] ? ': ' . $u['ban_reason'] : '.');
            } elseif (!empty($u['banned_until']) && strtotime($u['banned_until'] . ' UTC') > time()) {
                $error = 'This account is in a time-out until ' . gmdate('M j, H:i', (int)strtotime($u['banned_until'] . ' UTC')) . ' UTC' . ($u['ban_reason'] ? ' (' . $u['ban_reason'] . ')' : '') . '.';
            } else {
                if (password_needs_rehash($u['password_hash'], PASSWORD_DEFAULT)) {
                    q('UPDATE users SET password_hash = ? WHERE id = ?', [password_hash($password, PASSWORD_DEFAULT), $u['id']]);
                }
                clear_attempts($key);
                log_in_user($u);
                redirect($u['role'] === 'admin' && setting('maintenance_mode') === '1' ? 'admin/index.php' : (q_val('SELECT away_from FROM users WHERE id = ?', [$u['id']]) ? 'back.php' : 'garden.php'));   // v1.0.0: away for days? the welcome-back page first
            }
        } else {
            record_attempt($key);
            record_attempt('login:*');
            $error = 'Wrong username or password.';
        }
    }
}

page_header('Log in');
?>
<div class="box narrow">
  <h2>Log in</h2>
  <?php if ($error): ?><div class="flash err"><?= e($error) ?></div><?php endif; ?>
  <form method="post" class="form">
    <?= csrf_field() ?>
    <label>Username <input name="username" value="<?= e($username) ?>" required autocomplete="username"></label>
    <label>Password <input type="password" name="password" required autocomplete="current-password"></label>
    <button class="btn">Log in</button>
  </form>
  <p><a href="<?= e(url('forgot.php')) ?>">Forgotten your password?</a></p>
  <p>New here? <a href="<?= e(url('register.php')) ?>">Claim your plot</a>.</p>
</div>
<?php page_footer();
