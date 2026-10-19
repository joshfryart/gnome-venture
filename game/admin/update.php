<?php
declare(strict_types=1);
/** Update the game from an uploaded zip (v0.7.40). */
require dirname(__DIR__) . '/includes/bootstrap.php';
require dirname(__DIR__) . '/includes/updater.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();
$pending = update_dir('update') . '/pending.zip';

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'upload') {
        $f = $_FILES['zip'] ?? null;
        if (!$f || ($f['error'] ?? 1) !== UPLOAD_ERR_OK || !is_uploaded_file((string)$f['tmp_name'])) {
            flash(($f['error'] ?? 0) === UPLOAD_ERR_INI_SIZE || ($f['error'] ?? 0) === UPLOAD_ERR_FORM_SIZE
                ? 'That file is bigger than this server accepts. Use the small web-update zip, or update by hand.' : 'The upload didn’t arrive. Try again.', 'err');
        } elseif ((int)$f['size'] > UPDATE_MAX_BYTES) {
            flash('That file is too big for an update.', 'err');
        } else {
            $info = update_inspect((string)$f['tmp_name']);
            if (isset($info['error'])) {
                flash($info['error'], 'err');
            } elseif (!move_uploaded_file((string)$f['tmp_name'], $pending)) {
                flash('Couldn’t save the upload in the data folder. Is it writable?', 'err');
            } else {
                admin_log('update_upload', $info['version'], (string)$f['name']);
                flash('Update v' . $info['version'] . ' uploaded and checked. Look it over below, then install.');
            }
        }
        redirect('admin/update.php');
    }
    if ($do === 'cancel') {
        @unlink($pending);
        flash('Upload removed. Nothing was changed.');
        redirect('admin/update.php');
    }
    if ($do === 'install') {
        [$ok, $msg] = update_install($me, (string)($_POST['password'] ?? ''), !empty($_POST['older']));
        flash($msg, $ok ? 'ok' : 'err');
        redirect($ok ? 'admin/index.php' : 'admin/update.php');   // the next page load upgrades the database
    }
    if ($do === 'restore') {
        [$ok, $msg] = update_restore($me, (string)($_POST['password'] ?? ''), (string)($_POST['name'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
        redirect($ok ? 'admin/index.php' : 'admin/update.php');
    }
    if ($do === 'download') {
        $name = (string)($_POST['name'] ?? '');
        $path = update_dir('backups') . '/' . $name;
        if (preg_match('/^(db|files)-v[0-9.]+-\d{8}-\d{6}\.(sql|zip)$/', $name) && is_file($path)) {
            admin_log('backup_download', $name, '');
            header('Content-Type: ' . (str_ends_with($name, '.zip') ? 'application/zip' : 'application/sql'));
            header('Content-Disposition: attachment; filename="' . $name . '"');
            header('Content-Length: ' . filesize($path));
            header('X-Content-Type-Options: nosniff');
            readfile($path);
            exit;
        }
        flash('That backup isn’t there.', 'err');
        redirect('admin/update.php');
    }
}

$info = is_file($pending) ? update_inspect($pending) : null;
$bad = update_unwritable();
$limit = update_upload_limit();
page_header('Update the game', true);
?>
<?php admin_crumbs('update.php');   // v1.6.3 ?>
<h1>⬆️ Update the game</h1>
<p>You’re running <b>v<?= e(APP_VERSION) ?></b>. Upload the <b>web-update zip</b> I send you, check what it will change, then install.
  Before anything is changed, the database and the current program files are backed up automatically.
  Players’ accounts, gardens and items live in the database and are never removed by an update.</p>

<?php if (!class_exists('ZipArchive')): ?>
  <div class="flash err">This server’s PHP can’t open zip files (the “zip” extension is off). In cPanel, “Select PHP Version” → Extensions, tick <b>zip</b>. Until then, update by hand.</div>
<?php endif; ?>
<?php if ($bad): ?>
  <div class="flash err">PHP can’t write to: <?= e(implode(', ', $bad)) ?>. Updating from here won’t work until it can; update by hand in cPanel’s File Manager instead.</div>
<?php endif; ?>

<?php if (!$info): ?>
  <div class="box">
    <h2>1. Upload the update</h2>
    <form method="post" enctype="multipart/form-data" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="upload">
      <label>Update zip <input type="file" name="zip" accept=".zip,application/zip" required></label>
      <button class="btn">Upload and check</button></form>
    <p class="help">This server accepts uploads up to <?= number_format($limit / 1048576, 1) ?> MB. The web-update zip is under 1 MB. (The bigger Windows zip works too, if the limit allows.)</p>
  </div>
<?php elseif (isset($info['error'])): ?>
  <div class="box"><div class="flash err"><?= e($info['error']) ?></div>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="cancel"><button class="btn alt">Remove it</button></form></div>
<?php else:
    $older = version_compare($info['version'], APP_VERSION, '<');
    $sameV = version_compare($info['version'], APP_VERSION, '='); ?>
  <div class="box">
    <h2>2. Check and install</h2>
    <table class="kv">
      <tr><th>Update</th><td><b>v<?= e($info['version']) ?></b> <?= $older ? '<span class="bad">⚠️ older than what you’re running</span>' : ($sameV ? '<span class="muted">(same version: re-installs the files)</span>' : '<span class="good">newer ✔</span>') ?></td></tr>
      <tr><th>Files</th><td><?= (int)$info['new'] ?> new · <?= (int)$info['changed'] ?> changed · <?= (int)$info['same'] ?> unchanged</td></tr>
      <?php if (!empty($info['needs'])): // v0.7.82 slim updates ?>
        <tr><th>Kind</th><td>Slim update (only recent changes). Needs v<?= e((string)$info['needs']) ?> or newer installed
          <?= version_compare(APP_VERSION, (string)$info['needs'], '<') ? '<b class="bad">⚠️ You have v' . e(APP_VERSION) . ': install the updates in between first, or ask for a full update.</b>' : '✔ you have v' . e(APP_VERSION) ?></td></tr>
      <?php else: ?><tr><th>Kind</th><td>Full update</td></tr><?php endif; ?>
      <tr><th>Left alone</th><td class="help">config.php, install.php, the data folder (your database settings, logs and backups) and uploaded images</td></tr>
      <?php if ($info['skipped']): ?><tr><th>Skipped</th><td class="help"><?= e(implode(', ', array_slice($info['skipped'], 0, 12))) ?><?= count($info['skipped']) > 12 ? '…' : '' ?> (not game files)</td></tr><?php endif; ?>
    </table>
    <form method="post" class="form" data-confirm="Install v<?= e($info['version']) ?> now? It takes a few seconds."><?= csrf_field() ?><input type="hidden" name="do" value="install">
      <?php if ($older): ?><label class="check"><input type="checkbox" name="older" value="1"> Yes, install an older version</label><?php endif; ?>
      <label>Your admin password (to confirm) <input type="password" name="password" required autocomplete="current-password"></label>
      <button class="btn"<?= $bad ? ' disabled' : '' ?>>⬆️ Back up and install</button></form>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="cancel"><button class="btn small alt">Cancel and remove the upload</button></form>
    <p class="help">Tip: switch on Maintenance mode in Game settings first if players are online. The update itself takes a few seconds.</p>
  </div>
<?php endif; ?>

<div class="box">
  <h2>Backups made before updates</h2>
  <?php $bk = update_backups(); if (!$bk): ?><p class="muted">None yet. One is made automatically every time you install an update here.</p>
  <?php else: ?>
    <table class="grid"><tr><th>When (UTC)</th><th>What</th><th>Size</th><th></th></tr>
    <?php foreach ($bk as $b): $w = DateTime::createFromFormat('Ymd-His', $b['when'], new DateTimeZone('UTC')); ?>
      <tr><td><?= e($w ? $w->format('Y-m-d H:i') : $b['when']) ?></td>
        <td><?= $b['kind'] === 'db' ? '🗄️ Database' : '📦 Program files' ?> of v<?= e($b['version']) ?></td>
        <td><?= number_format($b['size'] / 1048576, 1) ?> MB</td>
        <td><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="download"><input type="hidden" name="name" value="<?= e($b['name']) ?>"><button class="btn small alt">Download</button></form>
          <?php if ($b['kind'] === 'files'): ?>
            <details class="inline"><summary class="btn small alt">Restore…</summary>
              <form method="post" class="form" data-confirm="Put back the program files of v<?= e($b['version']) ?>?"><?= csrf_field() ?><input type="hidden" name="do" value="restore"><input type="hidden" name="name" value="<?= e($b['name']) ?>">
                <label>Admin password <input type="password" name="password" required autocomplete="current-password"></label>
                <button class="btn small">↩️ Restore these files</button></form></details>
          <?php endif; ?></td></tr>
    <?php endforeach; ?></table>
    <p class="help">The newest <?= UPDATE_KEEP_BACKUPS ?> database backups and the newest <?= UPDATE_KEEP_FILE_BACKUPS ?> program-file backups are kept. Backup folder total: <?= number_format(update_backups_size() / 1048576, 1) ?> MB. A database backup can be loaded back with phpMyAdmin’s Import if ever needed.</p>
  <?php endif; ?>
</div>
<?php page_footer();
