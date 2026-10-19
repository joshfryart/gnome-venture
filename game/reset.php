<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/account.php';
$token = (string)($_GET['token'] ?? $_POST['token'] ?? '');
$error = '';
if (is_post()) {
    csrf_check();
    if (rate_limited('reset', 10, 15)) {
        $error = 'Too many tries. Please wait a few minutes.';
    } else {
        record_attempt('reset');
        [$ok, $msg] = do_password_reset($token, (string)($_POST['password'] ?? ''), (string)($_POST['password2'] ?? ''));
        if ($ok) {
            flash($msg);
            redirect('login.php');
        }
        $error = $msg;
    }
}
$valid = reset_lookup($token) !== null;
page_header('Choose a new password');
?>
<div class="box narrow">
  <h2>Choose a new password</h2>
  <?php if ($error): ?><div class="flash err"><?= e($error) ?></div><?php endif; ?>
  <?php if (!$valid): ?>
    <p>That link has expired or has already been used. <a href="<?= e(url('forgot.php')) ?>">Ask for a new one</a>.</p>
  <?php else: ?>
    <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="token" value="<?= e($token) ?>">
      <label>New password (10+ characters) <input type="password" name="password" required minlength="10" autocomplete="new-password"></label>
      <label>Again <input type="password" name="password2" required minlength="10" autocomplete="new-password"></label>
      <button class="btn">Save new password</button></form>
  <?php endif; ?>
</div>
<?php page_footer();
