<?php
declare(strict_types=1);
// v1.2.0: player mentors. See the links, end one, switch the feature off or on. (Numbers live in Game settings, "Player mentors".)
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/mentors120.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'toggle') {
        $on = !empty($_POST['on']);
        set_setting('pmentor_on', $on ? '1' : '0');
        admin_log('pmentor_toggle', 'pmentor_on', $on ? 'on' : 'off');
        flash($on ? 'Player mentors are on.' : 'Player mentors are off. XP bonuses and shares stop; links stay and resume when switched on.');
    } elseif ($do === 'end') {
        $id = (int)($_POST['id'] ?? 0);
        $n = q("UPDATE pmentor_links SET status = 'ended', closed_at = ?, closed_by = ? WHERE id = ? AND status IN ('active', 'pending')", [now(), (int)$me['id'], $id])->rowCount();
        if ($n) admin_log('pmentor_end', (string)$id, '');
        flash($n ? 'Link ended.' : 'That link was already closed.', $n ? 'ok' : 'err');
    }
    redirect('admin/mentors.php');
}

$rows = q("SELECT l.*, COALESCE(m.gnome_name, m.username) AS mname, m.level AS mlevel, COALESCE(n.gnome_name, n.username) AS nname, n.level AS nlevel
           FROM pmentor_links l JOIN users m ON m.id = l.mentor_id JOIN users n ON n.id = l.newcomer_id
           ORDER BY CASE l.status WHEN 'active' THEN 0 WHEN 'pending' THEN 1 ELSE 2 END, l.id DESC LIMIT 100")->fetchAll();
$grads = (int)q_val('SELECT COUNT(*) FROM pmentor_grads');
$on = mentors120_on();
page_header('Mentors', true);
?>
<?php admin_crumbs('mentors.php');   // v1.6.3 ?>
<h1>🎓 Player mentors</h1>
<form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="toggle">
  <label><input type="checkbox" name="on" value="1"<?= $on ? ' checked' : '' ?>> Mentors on</label> <button class="btn small">Save</button></form>
<p class="help"><?= $grads ?> graduate<?= $grads === 1 ? '' : 's' ?> so far. Rates, caps and rewards: <a href="<?= e(url('admin/settings.php')) ?>">Game settings</a>, “Player mentors”. Latest 100 links.</p>
<table class="grid">
  <tr><th>Mentor</th><th>Newcomer</th><th>Status</th><th>XP</th><th></th></tr>
  <?php foreach ($rows as $r): ?>
    <tr><td><?= e($r['mname']) ?> <small class="help">L<?= (int)$r['mlevel'] ?></small></td>
      <td><?= e($r['nname']) ?> <small class="help">L<?= (int)$r['nlevel'] ?></small></td>
      <td><?= e($r['status']) ?><br><small class="help"><?= e((string)($r['closed_at'] ?: $r['created_at'])) ?></small></td>
      <td><small>+<?= (int)$r['xp_bonus'] ?> bonus<br><?= (int)$r['xp_given'] ?> shared</small></td>
      <td><?php if (in_array($r['status'], ['active', 'pending'], true)): ?>
        <form method="post" class="inline" data-confirm="End this link?"><?= csrf_field() ?><input type="hidden" name="do" value="end"><input type="hidden" name="id" value="<?= (int)$r['id'] ?>"><button class="btn small ghost">End</button></form>
      <?php endif; ?></td></tr>
  <?php endforeach; ?>
  <?php if (!$rows): ?><tr><td colspan="5" class="muted">No mentor links yet.</td></tr><?php endif; ?>
</table>
<?php page_footer();
