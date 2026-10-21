<?php
declare(strict_types=1);
/** v0.8.6: notes players sent from the menu. */
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();

if (is_post()) {
    csrf_check();
    $id = (int)($_POST['id'] ?? 0);
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'done' || $do === 'new') {
        q('UPDATE feedback SET status = ? WHERE id = ?', [$do, $id]);
    } elseif ($do === 'delete') {
        q('DELETE FROM feedback WHERE id = ?', [$id]);
        admin_log('feedback_delete', '#' . $id);
    }
    redirect('admin/feedback.php' . (isset($_POST['all']) ? '?all=1' : ''));
}

$all = isset($_GET['all']);
$rows = q('SELECT f.*, u.username, COALESCE(u.gnome_name, u.username) AS gname FROM feedback f LEFT JOIN users u ON u.id = f.user_id'
    . ($all ? '' : " WHERE f.status = 'new'") . ' ORDER BY f.id DESC LIMIT 200')->fetchAll();
page_header('Feedback', true);
?>
<?php admin_crumbs('feedback.php');   // v1.6.3 ?>
<h1>💬 Feedback</h1>
<p class="help">Notes players sent with “💬 Send feedback” in the menu. Mark one as read when you’ve dealt with it. Players see it as “✅ read”.
  <?= $all ? '<a href="' . e(url('admin/feedback.php')) . '">Show only new</a>' : '<a href="' . e(url('admin/feedback.php?all=1')) . '">Show all, including read</a>' ?></p>
<?php if (!$rows): ?><p class="muted">Nothing <?= $all ? 'yet' : 'new' ?>.</p><?php endif; ?>
<?php foreach ($rows as $r): ?>
  <div class="box">
    <p class="muted"><?= e($r['created_at']) ?> UTC · <b><?= e((string)($r['gname'] ?? '?')) ?></b> (<?= e((string)($r['username'] ?? '?')) ?>)<?= $r['page'] !== '' ? ' · from ' . e($r['page']) : '' ?>
      · <?= $r['status'] === 'done' ? '✅ read' : '<span class="tag">new</span>' ?></p>
    <p><?= nl2br(eu($r['body'])) ?></p>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="id" value="<?= (int)$r['id'] ?>"><?= $all ? '<input type="hidden" name="all" value="1">' : '' ?>
      <?php if ($r['status'] === 'done'): ?><button class="btn small alt" name="do" value="new">Mark as new</button>
      <?php else: ?><button class="btn small" name="do" value="done">✅ Mark as read</button><?php endif; ?>
    </form>
    <form method="post" class="inline" data-confirm="Delete this note for good?"><?= csrf_field() ?><input type="hidden" name="id" value="<?= (int)$r['id'] ?>"><?= $all ? '<input type="hidden" name="all" value="1">' : '' ?>
      <button class="btn small alt" name="do" value="delete">Delete</button></form>
  </div>
<?php endforeach; ?>
<?php page_footer();
