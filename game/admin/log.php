<?php
declare(strict_types=1);
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();

$per = 100;
$page = max(1, (int)($_GET['page'] ?? 1));
$total = (int)q_val('SELECT COUNT(*) FROM admin_log');
$rows = q('SELECT l.*, u.username FROM admin_log l LEFT JOIN users u ON u.id = l.user_id ORDER BY l.id DESC LIMIT ' . $per . ' OFFSET ' . (($page - 1) * $per))->fetchAll();

page_header('Admin log', true);
?>
<?php admin_crumbs('log.php');   // v1.6.3 ?>
<h1>Admin log</h1>
<p class="help">Every change made in the admin panel, newest first. Useful if something breaks or an account is misused.</p>
<table class="grid">
  <tr><th>When (UTC)</th><th>Who</th><th>IP</th><th>Action</th><th>What</th><th>Details</th></tr>
  <?php foreach ($rows as $l): ?>
    <tr><td><?= e($l['created_at']) ?></td><td><?= e($l['username'] ?? '?') ?></td><td><?= e($l['ip']) ?></td>
      <td><?= e($l['action']) ?></td><td><?= e($l['target']) ?></td>
      <td class="details"><?= e(mb_strimwidth((string)$l['details'], 0, 300, '…')) ?></td></tr>
  <?php endforeach; ?>
</table>
<p class="pager">
  <?php if ($page > 1): ?><a href="<?= e(url('admin/log.php?page=' . ($page - 1))) ?>">← Newer</a><?php endif; ?>
  <?php if ($page * $per < $total): ?><a href="<?= e(url('admin/log.php?page=' . ($page + 1))) ?>">Older →</a><?php endif; ?>
</p>
<?php page_footer();
