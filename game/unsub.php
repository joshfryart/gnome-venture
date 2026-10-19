<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/account.php';
require_once __DIR__ . '/includes/mail_nudge.php';
// One click, no login. The link is signed (HMAC), so only the person emailed can use it. POST is for mail apps (List-Unsubscribe-Post).
$uid = (int)($_GET['u'] ?? 0);
$ok = $uid > 0 && hash_equals(nudge_token($uid), (string)($_GET['t'] ?? ''));
if ($ok) q('UPDATE users SET email_nudges = 0 WHERE id = ?', [$uid]);
if (is_post()) {
    http_response_code($ok ? 200 : 400);
    exit($ok ? 'Unsubscribed.' : 'Bad link.');
}
page_header('Unsubscribe');
?>
<div class="box narrow">
  <?php if ($ok): ?>
    <h2>Done</h2>
    <p>You will not get reminder emails any more. You can turn them back on in <a href="<?= e(url('account.php')) ?>">Account</a>.</p>
  <?php else: ?>
    <h2>That link did not work</h2>
    <p>Log in and untick the reminder box in <a href="<?= e(url('account.php')) ?>">Account</a> instead.</p>
  <?php endif; ?>
</div>
<?php page_footer();
