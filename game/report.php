<?php
declare(strict_types=1);
/** Report something to the moderators (v0.7.28). */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/moderation.php';
$u = require_login();
$target = (int)($_GET['u'] ?? $_POST['u'] ?? 0);
$kind = (string)($_GET['k'] ?? $_POST['k'] ?? 'other');
$ref = (int)($_GET['r'] ?? $_POST['r'] ?? 0);
if (!isset(REPORT_KINDS[$kind])) $kind = 'other';
if (is_post()) {
    csrf_check();
    [$ok, $msg] = file_report($u, $target, $kind, $ref, (string)($_POST['reason'] ?? ''), (string)($_POST['details'] ?? ''));
    flash($msg, $ok ? 'ok' : 'err');
    redirect($ok ? safe_back('index.php') : 'report.php?u=' . $target . '&k=' . $kind . ($ref ? '&r=' . $ref : ''));
}
$who = q_one('SELECT id, username, gnome_name FROM users WHERE id = ?', [$target]);
$snap = $who ? report_snapshot($kind, $target, $ref, $u) : null;
$back = (string)($_GET['back'] ?? '');
page_header('Report');
?>
<h1>🚩 Report to a moderator</h1>
<?php if (!$who || $snap === null): ?>
  <p class="muted">That’s already gone, or it can’t be reported.</p>
<?php else: ?>
  <div class="box narrow">
    <p>You’re reporting <b><?= e(REPORT_KINDS[$kind]) ?></b> from <b><?= e(gnome_name($who)) ?></b><?= $snap !== '' ? ':' : '.' ?></p>
    <?php if ($snap !== ''): ?><blockquote class="snap"><?= e($snap) ?></blockquote><?php endif; ?>
    <form method="post" class="form"><?= csrf_field() ?>
      <input type="hidden" name="u" value="<?= (int)$target ?>"><input type="hidden" name="k" value="<?= e($kind) ?>"><input type="hidden" name="r" value="<?= (int)$ref ?>">
      <input type="hidden" name="back" value="<?= e(preg_match('~^[a-z0-9_/-]+\.php(\?[A-Za-z0-9=&_.-]*)?$~', $back) ? $back : 'index.php') ?>">
      <label>What’s wrong? <select name="reason" required><?php foreach (REPORT_REASONS as $k => $l): ?><option value="<?= e($k) ?>"><?= e($l) ?></option><?php endforeach; ?></select></label>
      <label>Anything else a moderator should know? (optional) <input name="details" maxlength="255" autocomplete="off"></label>
      <button class="btn">Send report</button>
    </form>
    <p class="help">Reports are private. The other gnome won’t know who sent it. Please only report things that break the <a href="<?= e(url('page.php?p=rules')) ?>">rules</a>.</p>
  </div>
<?php endif; ?>
<?php page_footer();
