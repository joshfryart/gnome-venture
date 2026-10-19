<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';

if (current_user()) {
    redirect('index.php');
}

$errors = [];
$username = '';
$email = '';
$open = setting('registration_open') === '1';

if ($open && is_post()) {
    csrf_check();
    $username = trim((string)($_POST['username'] ?? ''));
    $email = strtolower(trim((string)($_POST['email'] ?? '')));
    $pass = (string)($_POST['password'] ?? '');

    // Honeypot: real people never see or fill the "website" field. Bots usually do.
    if (!empty($_POST['website'])) $errors[] = 'Something went wrong.';
    if (rate_limited('register', 3, 60)) $errors[] = 'Too many new accounts from your connection. Try again in an hour.';
    if (!preg_match('/^[A-Za-z0-9_]{3,20}$/', $username)) $errors[] = 'Username: 3–20 letters, numbers or underscores.';
    if (!filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($email) > 190) $errors[] = 'Please enter a valid email.';
    if (strlen($pass) < 10) $errors[] = 'Password must be at least 10 characters.';
    if (strlen($pass) > 200) $errors[] = 'Password is too long.';
    if ($pass !== ($_POST['password2'] ?? '')) $errors[] = 'Passwords do not match.';
    if (empty($_POST['rules'])) $errors[] = 'Please agree to the rules and privacy policy.';
    if (empty($_POST['age'])) $errors[] = 'You must be 13 or older to play.';
    if (!$errors && q_val('SELECT 1 FROM users WHERE LOWER(username) = LOWER(?)', [$username])) $errors[] = 'That username is taken.';
    if (!$errors && q_val('SELECT 1 FROM users WHERE email = ?', [$email])) $errors[] = 'That email already has an account.';

    if (!$errors) {
        record_attempt('register');
        try {
            // The account only. The gnome, homeland and first garden are made in the welcome flow.
            $uid = db_insert('users', [
                'username' => $username, 'email' => $email,
                'password_hash' => password_hash($pass, PASSWORD_DEFAULT),
                'role' => 'player', 'coins' => (int)setting('starting_coins'),
                'energy' => (int)setting('max_energy'), 'created_at' => now(), 'onboarded' => 0, 'agreed_at' => now(), 'email_nudges' => empty($_POST['nudges']) ? 0 : 1,
            ]);
            require_once __DIR__ . '/includes/mentors120.php'; mentors120_note_signup($uid);   // v1.2.0: alt-account guard for mentors
            try { require_once __DIR__ . '/includes/account.php'; send_verify_email(['id' => $uid, 'username' => $username, 'email' => $email]); } catch (Throwable $e) { error_log('Verify mail failed: ' . $e->getMessage()); }   // v1.7
            log_in_user(['id' => $uid]);
            if ($ct = theme_clean((string)($_COOKIE['gvtheme'] ?? ''))) q('UPDATE users SET theme = ? WHERE id = ?', [$ct, $uid]);   // v1.6.5: keep the choice made before signing up
            redirect('welcome.php');
        } catch (PDOException $e) {
            error_log('Register failed: ' . $e->getMessage());
            $errors[] = 'Could not create your account. Please try again.';
        }
    }
}

require_once __DIR__ . '/includes/site_text.php';
seo_set(['title' => stext('join.title'), 'desc' => stext('join.desc')]);   // v0.8.8; v0.8.9 editable in Admin → Page text
page_header('Join');
?>
<div class="box narrow">
  <h2>Claim your plot</h2>
  <?php if (!$open): ?>
    <p>Sign-ups are closed right now. Check back soon!</p>
  <?php else: ?>
    <p>First, an account to log in with. Next you’ll create your gnome and choose where in the world to plant your first garden.</p>
    <?php foreach ($errors as $err): ?><div class="flash err"><?= e($err) ?></div><?php endforeach; ?>
    <form method="post" class="form">
      <?= csrf_field() ?>
      <label>Username (for logging in) <input name="username" value="<?= e($username) ?>" required maxlength="20" autocomplete="username"></label>
      <label>Email <input type="email" name="email" value="<?= e($email) ?>" required autocomplete="email"></label>
      <label>Password (10+ characters) <input type="password" name="password" required minlength="10" autocomplete="new-password"></label>
      <label>Password again <input type="password" name="password2" required minlength="10" autocomplete="new-password"></label>
      <label class="hp">Website <input name="website" tabindex="-1" autocomplete="off"></label>
      <label class="check"><input type="checkbox" name="age" value="1"> I am 13 or older</label>
      <label class="check"><input type="checkbox" name="rules" value="1"> <span>I agree to the <a href="<?= e(url('page.php?p=rules')) ?>">rules</a> and <a href="<?= e(url('page.php?p=privacy')) ?>">privacy policy</a></span></label>   <?php /* v1.6.2: one span, so a flex label doesn't drop the spaces */ ?>
      <label class="check"><input type="checkbox" name="nudges" value="1"> <span>Email me when my harvest is ready or I have been away a while (optional, you can stop any time)</span></label>
      <button class="btn">Next: create your gnome</button>
    </form>
  <?php endif; ?>
</div>
<?php page_footer();
