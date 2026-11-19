<?php
declare(strict_types=1);
// Sights sixth pass B: review the notes and chalk words players send each other (reported first). Hide, show again, delete, clear reports. Admins only; authors are shown here and nowhere else.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/trail_sights_6.php';
$me = require_admin();
sights6_ensure();
$filter = in_array($_GET['f'] ?? '', ['reported', 'recent', 'hidden', 'notes', 'marks'], true) ? (string)$_GET['f'] : 'reported';
if (is_post()) {
    csrf_check();
    $act = is_scalar($_POST['act'] ?? null) ? (string)$_POST['act'] : '';
    $id = (int)($_POST['id'] ?? 0);
    $msg = sights6_admin_act($id, $act);
    admin_log('sights_shared', (string)$id, $act);
    flash($msg);
    redirect('admin/sights_shared.php?f=' . $filter);
}
$rows = sights6_admin_rows($filter === 'recent' ? 'all' : $filter);
page_header('Shared Sights', true);
admin_crumbs('sights_shared.php');
?>
<h1>🍾 Shared Sights</h1>
<p class="help">Notes players send into other players’ bottles, and words chalked on the star-chart stones. Players see them anonymously; you see who wrote and who got them. A note hides at the first report, a mark at the second. Hidden items are never shown to players. Switch the whole feature in <a href="<?= e(url('admin/settings.php')) ?>">Settings</a> (<code>sights_shared_on</code>, <code>sights_shared_text</code>, <code>sights_shared_block</code>). Feature is <b><?= sights6_on() ? 'ON' : 'OFF' ?></b>; text is <b><?= sights6_text_on() ? 'ON' : 'OFF' ?></b>. Shared cairn: <b><?= (int)sights6_tally(SIGHTS6_TALLIES['cairn-stones']) ?></b> stones.</p>
<nav class="tabs">
<?php foreach (['reported' => 'Reported', 'recent' => 'Recent', 'hidden' => 'Hidden', 'notes' => 'Notes', 'marks' => 'Marks'] as $k => $lab): ?><a class="<?= $filter === $k ? 'on' : '' ?>" href="<?= e(url('admin/sights_shared.php?f=' . $k)) ?>"><?= e($lab) ?></a><?php endforeach; ?>
</nav>
<table class="grid">
  <tr><th>#</th><th>Kind</th><th>Words</th><th>Written by</th><th>Sent to</th><th>When</th><th>Reports</th><th>Shown?</th><th></th></tr>
  <?php foreach ($rows as $r): ?>
    <tr><td><?= (int)$r['id'] ?></td><td><?= e($r['kind']) ?></td><td><?= e($r['body']) ?></td><td><?= e((string)$r['author']) ?></td><td><?= $r['kind'] === 'note' ? e((string)($r['receiver'] ?: 'not delivered yet')) : e((string)$r['place']) ?></td>
      <td><?= e($r['created_at']) ?></td><td><?= (int)$r['reports'] ?></td><td><?= (int)$r['hidden'] ? 'hidden' : 'shown' ?></td>
      <td><?php foreach (((int)$r['hidden'] ? ['unhide' => 'Show again'] : ['hide' => 'Hide']) + ((int)$r['reports'] > 0 ? ['clear' => 'Clear reports'] : []) + ['delete' => 'Delete'] as $a => $lab): ?>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="id" value="<?= (int)$r['id'] ?>"><input type="hidden" name="act" value="<?= e($a) ?>"><button class="btn small<?= $a === 'delete' ? ' danger' : ' alt' ?>"><?= e($lab) ?></button></form>
      <?php endforeach; ?></td></tr>
  <?php endforeach; ?>
  <?php if (!$rows): ?><tr><td colspan="9">Nothing here.</td></tr><?php endif; ?>
</table>
<?php page_footer();
