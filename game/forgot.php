<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/account.php';
$sent = false;
$error = '';
$pendingEmail = null;
if (is_post()) {
    csrf_check();
    if (rate_limited('forgot', 3, 15) || rate_limited('forgot:*', 50, 15)) {
        $error = 'Too many requests. Please wait a few minutes.';
    } else {
        record_attempt('forgot');
        $pendingEmail = (string)($_POST['email'] ?? '');   // v1.2.2: looked up and mailed after the page is sent, so timing says nothing
        $sent = true;
    }
}
page_header('Forgotten password');
?>
<div class="box narrow">
  <h2>Forgotten your password?</h2>
  <?php if ($sent): ?>
    <p>If that email has an account, a reset link is on its way. It works for one hour. Check your spam folder too.</p>
  <?php else: ?>
    <?php if ($error): ?><div class="flash err"><?= e($error) ?></div><?php endif; ?>
    <form method="post" class="form"><?= csrf_field() ?>
      <label>Your account’s email <input type="email" name="email" required autocomplete="email"></label>
      <button class="btn">Send me a reset link</button></form>
  <?php endif; ?>
  <p><a href="<?= e(url('login.php')) ?>">← Back to log in</a></p>
</div>
<?php page_footer();
if ($pendingEmail !== null) {   // v1.2.2
    if (function_exists('fastcgi_finish_request')) fastcgi_finish_request();
    request_password_reset($pendingEmail);
}
