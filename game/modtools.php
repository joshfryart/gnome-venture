<?php
declare(strict_types=1);
/** The moderation queue (v0.7.28): for moderators and admins. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/moderation.php';
$u = require_login();
if (!is_staff()) {
    flash('Moderators only.', 'err');
    redirect('index.php');
}
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = $do === 'lift'
        ? mod_lift($u, (int)($_POST['user'] ?? 0), (string)($_POST['what'] ?? ''))
        : mod_act($u, (int)($_POST['report'] ?? 0), $do, (int)($_POST['hours'] ?? 24));
    flash($msg, $ok ? 'ok' : 'err');
    redirect('modtools.php');
}
$open = q("SELECT r.*, t.username AS t_user, t.gnome_name AS t_name, t.role AS t_role, t.muted_until, t.banned_until,
           rp.gnome_name AS r_name, rp.username AS r_user,
           (SELECT COUNT(*) FROM reports x WHERE x.target_id = r.target_id AND x.status = 'resolved') AS priors
           FROM reports r JOIN users t ON t.id = r.target_id JOIN users rp ON rp.id = r.reporter_id
           WHERE r.status = 'open' ORDER BY r.created_at")->fetchAll();
$done = q("SELECT r.*, t.gnome_name AS t_name, t.username AS t_user, m.gnome_name AS m_name, m.username AS m_user FROM reports r
           JOIN users t ON t.id = r.target_id LEFT JOIN users m ON m.id = r.handled_by WHERE r.status <> 'open' ORDER BY r.handled_at DESC LIMIT 30")->fetchAll();
$held = q('SELECT id, username, gnome_name, muted_until, banned_until FROM users WHERE muted_until > ? OR banned_until > ? ORDER BY id', [now(), now()])->fetchAll();
page_header('Moderation');
?>
<h1>🛡️ Moderation</h1>
<p class="help">Clear the text if it breaks the rules. Mute stops someone writing names and notes for a while (they can still play). A time-out bans them for a while.
  <?= is_admin() ? 'As an admin you can also ban for good.' : 'Only admins can ban for good.' ?> Everything is written to the admin log.</p>
<h2>Open reports (<?= count($open) ?>)</h2>
<?php if (!$open): ?><p class="muted">Nothing to look at. 🌿</p><?php endif; ?>
<?php foreach ($open as $r):
    $f = fn(string $do, string $label, string $extra = '') => '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="' . $do . '"><input type="hidden" name="report" value="' . (int)$r['id'] . '">' . $extra . '<button class="btn small' . ($do === 'dismiss' ? ' alt' : '') . '">' . $label . '</button></form> '; ?>
  <div class="box report">
    <p><b><?= e(REPORT_KINDS[$r['kind']] ?? $r['kind']) ?></b> from <b><?= e($r['t_name'] ?: $r['t_user']) ?></b> <small class="muted">(log-in <?= e($r['t_user']) ?>, #<?= (int)$r['target_id'] ?><?= $r['priors'] ? ', ' . (int)$r['priors'] . ' earlier report' . ((int)$r['priors'] === 1 ? '' : 's') . ' upheld' : '' ?>)</small></p>
    <?php if ((string)$r['snapshot'] !== ''): ?><blockquote class="snap"><?= e((string)$r['snapshot']) ?></blockquote><?php endif; ?>
    <p class="help">Reason: <?= e(REPORT_REASONS[$r['reason']] ?? $r['reason']) ?><?= $r['details'] ? ' · “' . eu($r['details']) . '”' : '' ?> · reported by <?= e($r['r_name'] ?: $r['r_user']) ?>, <?= e($r['created_at']) ?> UTC</p>
    <?php if ((int)$r['target_id'] === (int)$u['id']): ?><p class="muted">This one is about you. Another moderator must handle it.</p><?php elseif ($r['t_role'] === 'admin' && !is_admin()): ?><p class="muted">This is an admin’s; only another admin can act.</p><?php else: ?>
    <?= $f('dismiss', 'Dismiss') ?>
    <?php if (in_array($r['kind'], ['yard', 'garden'], true) && $r['ref_id']): ?><a class="btn small alt" href="<?= e(url('visit.php?g=' . (int)$r['ref_id'])) ?>" target="_blank" rel="noopener">👀 Look at the garden</a> <?php endif; ?>
    <?= $r['kind'] === 'yard' ? $f('clear', 'Clear the yard (decor back to their satchel)') : ($r['kind'] !== 'other' ? $f('clear', 'Clear the text') : '') ?>
    <?= $f('mute', 'Clear + mute', '<select name="hours"><option value="1">1 hour</option><option value="24" selected>1 day</option><option value="168">1 week</option></select>') ?>
    <?= $f('timeban', 'Time-out', '<select name="hours"><option value="24">1 day</option><option value="72">3 days</option><option value="168">1 week</option></select>') ?>
    <?= is_admin() ? $f('ban', '⛔ Ban for good') : '' ?>
    <?php endif; ?>
  </div>
<?php endforeach; ?>
<?php if ($held): ?>
  <h2>Muted and timed out</h2>
  <table class="grid"><tr><th>Gnome</th><th>Muted until</th><th>Timed out until</th><th></th></tr>
  <?php foreach ($held as $h): ?>
    <tr><td><?= e($h['gnome_name'] ?: $h['username']) ?></td><td><?= e((string)$h['muted_until']) ?></td><td><?= e((string)$h['banned_until']) ?></td>
      <td><?php foreach (['mute' => 'muted_until', 'timeban' => 'banned_until'] as $what => $col): if ((int)$h['id'] !== (int)$u['id'] && $h[$col] && $h[$col] > now()): ?>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="lift"><input type="hidden" name="user" value="<?= (int)$h['id'] ?>"><input type="hidden" name="what" value="<?= $what ?>"><button class="btn small alt">Lift <?= $what === 'mute' ? 'mute' : 'time-out' ?></button></form>
      <?php endif; endforeach; ?></td></tr>
  <?php endforeach; ?></table>
<?php endif; ?>
<h2>Recently handled</h2>
<table class="grid"><tr><th>When</th><th>What</th><th>Gnome</th><th>Action</th><th>By</th></tr>
<?php foreach ($done as $d): ?>
  <tr><td><?= e((string)$d['handled_at']) ?></td><td><?= e(REPORT_KINDS[$d['kind']] ?? $d['kind']) ?>: <?= e(mb_substr((string)$d['snapshot'], 0, 60)) ?></td>
    <td><?= e($d['t_name'] ?: $d['t_user']) ?></td><td><?= e((string)$d['action']) ?></td><td><?= e($d['m_name'] ?: (string)$d['m_user']) ?></td></tr>
<?php endforeach; ?>
</table>
<?php page_footer();
