<?php
declare(strict_types=1);
/** v0.8.6: players send a short note to the people who run the game. Read in Admin → Feedback. */
require __DIR__ . '/includes/bootstrap.php';
$u = require_login();
$uid = (int)$u['id'];

$from = (string)($_GET['from'] ?? $_POST['from'] ?? '');
if (!preg_match('/^[a-z0-9_]{1,40}\.php$/', $from)) $from = '';
$perDay = (int)setting('feedback_per_day');
$sentToday = (int)q_val('SELECT COUNT(*) FROM feedback WHERE user_id = ? AND created_at >= ?', [$uid, gmdate('Y-m-d H:i:s', time() - 86400)]);
$left = max(0, $perDay - $sentToday);

if (is_post()) {
    csrf_check();
    $body = trim(str_replace("\r", '', (string)($_POST['body'] ?? '')));
    if ($left <= 0) {
        flash('That’s all the notes for today. Thank you! You can send more tomorrow.', 'err');
    } elseif (mb_strlen($body) < 5) {
        flash('Write a little more so we know what you mean.', 'err');
    } elseif (mb_strlen($body) > 1000) {
        flash('Please keep it under 1,000 letters.', 'err');
    } else {
        db_insert('feedback', ['user_id' => $uid, 'page' => $from, 'body' => $body, 'created_at' => now()]);
        flash('💬 Thank you! Your note is on its way.');
        redirect('feedback.php?sent=1' . ($from !== '' ? '&from=' . urlencode($from) : ''));
    }
    redirect('feedback.php' . ($from !== '' ? '?from=' . urlencode($from) : ''));
}

$mine = q('SELECT body, page, status, created_at FROM feedback WHERE user_id = ? ORDER BY id DESC LIMIT 5', [$uid])->fetchAll();
page_header('Send feedback');
?>
<h1>💬 Send feedback</h1>
<p class="help">Found a bug, got stuck, or have an idea? Tell us here. Every note is read by the person who makes the game.
  <?php if ($from !== ''): ?>We’ll know you came from the <b><?= e(str_replace('_', ' ', basename($from, '.php'))) ?></b> page.<?php endif; ?></p>
<?php if ($left > 0): ?>
<form method="post" class="box form">
  <?= csrf_field() ?>
  <input type="hidden" name="from" value="<?= e($from) ?>">
  <label for="fbbody"><b>Your note</b></label>
  <textarea id="fbbody" name="body" rows="6" maxlength="1000" required placeholder="What happened, or what would make the game better?"></textarea>
  <p class="help">You can send <?= $left ?> more today. Please don’t include passwords or other private details.</p>
  <p><button class="btn">Send</button></p>
</form>
<?php else: ?>
<div class="box"><p>That’s all the notes for today. Thank you! You can send more tomorrow.</p></div>
<?php endif; ?>
<?php if ($mine): ?>
<details class="fold"><summary>📮 Notes you’ve sent</summary>
  <?php foreach ($mine as $m): ?>
    <div class="box"><p class="muted"><?= e(gmdate('M j', ts($m['created_at']))) ?><?= $m['page'] !== '' ? ' · ' . e($m['page']) : '' ?> · <?= $m['status'] === 'done' ? '✅ read' : '📬 sent' ?></p>
      <p><?= nl2br(e($m['body'])) ?></p></div>
  <?php endforeach; ?>
</details>
<?php endif; ?>
<?php page_footer();
