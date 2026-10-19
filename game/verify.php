<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/account.php';
$ok = verify_email_token((string)($_GET['t'] ?? ''));
page_header('Confirm email');
?>
<div class="box narrow">
  <?php if ($ok): ?>
    <h2>Email confirmed</h2>
    <p>Thank you. <a href="<?= e(url('garden.php')) ?>">Back to the garden</a></p>
  <?php else: ?>
    <h2>That link has expired</h2>
    <p>Log in and press “Resend” on the <a href="<?= e(url('account.php')) ?>">Account</a> page for a new one.</p>
  <?php endif; ?>
</div>
<?php page_footer();
