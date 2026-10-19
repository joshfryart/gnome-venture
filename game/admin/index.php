<?php
declare(strict_types=1);
require dirname(__DIR__) . '/includes/bootstrap.php';
require dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();

if (is_post() && ($_POST['do'] ?? '') === 'migrate') {
    csrf_check();
    global $CONFIG;
    db_migrate(db(), $CONFIG['db']['driver']);
    $left = [];
    foreach (UPGRADE_100_STEPS as $name => $_) if (!upgrade_100_run_step($name, true)) $left[] = $name;   // v1.0.0: any step that is not done yet gets another go
    admin_log('db_upgrade', '', $left ? 'steps not done: ' . implode(',', $left) : '');
    if ($left) flash('Database tables are up to date, but upgrade step' . (count($left) > 1 ? 's' : '') . ' ' . implode(', ', $left) . ' did not finish. See the dashboard and Admin → Tools → Error log.', 'err');
    else flash('Database is up to date.');
    redirect('admin/index.php');
}

if (is_post() && ($_POST['do'] ?? '') === 'retry_step') {   // v1.0.0: try a failed upgrade step again
    csrf_check();
    @set_time_limit(600);
    $step = (string)($_POST['step'] ?? '');
    if (!isset(UPGRADE_100_STEPS[$step])) { flash('Unknown upgrade step.', 'err'); redirect('admin/index.php'); }
    $ok = upgrade_100_run_step($step, true);
    admin_log('upgrade_retry', $step, $ok ? 'done' : 'failed');
    flash($ok ? 'Upgrade step “' . $step . '” is done.' : 'Upgrade step “' . $step . '” failed again. The details are in Admin → Tools → Error log.', $ok ? 'ok' : 'err');
    redirect('admin/index.php');
}

if (is_post() && ($_POST['do'] ?? '') === 'import') {
    csrf_check();
    @set_time_limit(600);
    @ignore_user_abort(true);
    require_once dirname(__DIR__) . '/includes/catalog.php';
    $st = import_catalog();
    require_once dirname(__DIR__) . '/includes/roads.php';
    ensure_roads();   // new places get side paths off the roads
    ensure_grow_times();   // new plants get the v0.7.27 grow times
    require_once dirname(__DIR__) . '/includes/tools.php';
    require_once dirname(__DIR__) . '/includes/gathering.php';
    $st['items'] += ensure_tools() + ensure_gatherables();
    require_once __DIR__ . '/../includes/nutrients.php';
    $st['items'] += ensure_nutrients();
    require_once __DIR__ . '/../includes/hired_help.php';
    ensure_helpers();
    require_once __DIR__ . '/../includes/jobs.php';
    ensure_jobs();
    require_once __DIR__ . '/../includes/crafting.php';
    $st['recipes'] = ($st['recipes'] ?? 0) + ensure_crafts();
    admin_log('catalog_import', '', json_encode($st));
    flash(sprintf('Catalog imported: %d items, %d plants, %d regions, %d zones, %d landmarks, %d plant/region links, %d Almanac pages, %d milestones added.',
        $st['items'], $st['plants'], $st['regions'] ?? 0, $st['zones'] ?? 0, $st['landmarks'] ?? 0,
        $st['links'], $st['pages'], $st['milestones']));
    redirect('admin/index.php');
}

$count = fn(string $t) => (int)q_val("SELECT COUNT(*) FROM $t");
$online = (int)q_val('SELECT COUNT(*) FROM users WHERE last_seen > ?', [gmdate('Y-m-d H:i:s', time() - 900)]);
$newToday = (int)q_val('SELECT COUNT(*) FROM users WHERE created_at > ?', [gmdate('Y-m-d 00:00:00')]);

page_header('Dashboard', true);
?>
<?php if (setting('site_url') === ''): ?><div class="flash err">Set <b>site_url</b> in <a href="<?= e(url('admin/settings.php')) ?>">Game settings</a> (the game’s full web address) so password-reset emails have working links.</div><?php endif; ?>
<h1>Dashboard</h1>
<?php if (setting('maintenance_mode') === '1'): ?>
  <div class="flash err">Maintenance mode is ON. Players can’t use the site. <a href="<?= e(url('admin/settings.php')) ?>">Change</a></div>
<?php endif; ?>
<?php foreach (upgrade_100_failed() as $stepName => [$stepLabel, $stepErr]): ?>
  <div class="flash err">⚠️ Upgrade step <b><?= e($stepName) ?></b> failed (<?= e($stepLabel) ?>): <?= e((string)substr((string)strstr($stepErr, '|'), 1)) ?>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="retry_step"><input type="hidden" name="step" value="<?= e($stepName) ?>"><button class="btn small">Retry</button></form></div>
<?php endforeach; ?>
<?php if (setting('boot_failed_steps') !== ''): ?>
  <div class="flash err">⚠️ Some automatic upgrade steps failed (<?= e(setting('boot_failed_steps')) ?>). The game keeps running; see Admin → Tools → Error log for details, fix the cause, then re-upload the files to try again.</div>
<?php endif; ?>
<?php if (is_file(APP_ROOT . '/install.php')): ?>
  <div class="flash err">Security: delete <code>install.php</code> from your server.</div>
<?php endif; ?>

<?php $fbNew = (int)q_val("SELECT COUNT(*) FROM feedback WHERE status = 'new'"); if ($fbNew): ?>
  <div class="flash ok">💬 <?= $fbNew ?> new feedback note<?= $fbNew === 1 ? '' : 's' ?> from players. <a href="<?= e(url('admin/feedback.php')) ?>">Read</a></div>
<?php endif;   // v0.8.6 ?>
<?php admin_menu_render();   // v1.6.3: sections of .choice rows ?>
<h2>At a glance</h2>
<div class="stats">
  <div><b><?= $count('users') ?></b>players</div>
  <div><b><?= $online ?></b>online now</div>
  <div><b><?= $newToday ?></b>joined today</div>
  <div><b><?= $count('items') ?></b>items</div>
  <div><b><?= $count('plants') ?></b>plants</div>
  <div><b><?= $count('npcs') ?></b>NPCs</div>
  <div><b><?= $count('shops') ?></b>shops</div>
  <div><b><?= $count('encyclopedia_entries') ?></b>Almanac pages</div>
  <div><b><?= $count('regions') ?></b>regions</div>
  <div><b><?= $count('zones') ?></b>zones</div>
  <div><b><?= $count('landmarks') ?></b>landmarks</div>
</div>

<?php require_once dirname(__DIR__) . '/includes/art_upload.php'; $artP = art_progress(0); $artT = array_sum(array_column($artP['cats'], 0)); $artH = array_sum(array_column($artP['cats'], 1)); ?>
<div class="box">
  <h3>Art</h3>
  <p><?= $artH ?> of <?= $artT ?> pictures in. <a href="<?= e(url('admin/images.php#missing')) ?>">Missing art and upload →</a></p>
</div>

<div class="box">
  <h3>Shop staffing</h3>
  <table class="grid">
    <tr><th>Shop</th><th>Status</th><th>Unstaffed hours / week</th><th></th></tr>
    <?php foreach (q('SELECT id, name, open FROM shops ORDER BY name')->fetchAll() as $s):
        $gaps = coverage_gaps(shop_coverage((int)$s['id'])); ?>
      <tr><td><?= e($s['name']) ?></td><td><?= (int)$s['open'] ? 'Open' : '<span class="muted">Closed</span>' ?></td>
        <td><?= $gaps ? '<span class="bad">' . $gaps . '</span>' : '<span class="good">0 ✔</span>' ?></td>
        <td><a href="<?= e(url('admin/crud.php?r=shops&action=edit&id=' . (int)$s['id'])) ?>">View</a></td></tr>
    <?php endforeach; ?>
  </table>
</div>

<div class="box">
  <h3>Recent admin actions</h3>
  <table class="grid">
    <?php foreach (q('SELECT l.*, u.username FROM admin_log l LEFT JOIN users u ON u.id = l.user_id ORDER BY l.id DESC LIMIT 10')->fetchAll() as $l): ?>
      <tr><td><?= e($l['created_at']) ?></td><td><?= e($l['username'] ?? '?') ?></td><td><?= e($l['action']) ?></td><td><?= e($l['target']) ?></td></tr>
    <?php endforeach; ?>
  </table>
  <p><a href="<?= e(url('admin/log.php')) ?>">Full log →</a></p>
</div>

<form method="post" class="box">
  <?= csrf_field() ?><input type="hidden" name="do" value="import">
  <h3>World crop catalog</h3>
  <p class="help">Adds any crops, flowers, regions, zones and landmarks from the files in <code>includes/data/</code> that aren’t in the game yet, with their seeds, produce and Almanac pages. It never changes things you’ve already edited.</p>
  <button class="btn small">Import / update catalog</button>
</form>

<form method="post" class="box">
  <?= csrf_field() ?><input type="hidden" name="do" value="migrate">
  <h3>Database</h3>
  <p class="help">After uploading a new version of the game, press this to add any new tables. Your existing data is kept.</p>
  <button class="btn small">Upgrade database</button>
</form>
<?php page_footer();
