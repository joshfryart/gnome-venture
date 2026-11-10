<?php
declare(strict_types=1);
/** v2.6.37: see the code of a game page and, with your password, edit it. */
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/code_edit.php';
$me = require_admin();

$rel = (string)($_POST['f'] ?? $_GET['f'] ?? '');
$abs = $rel !== '' ? code_resolve($rel) : null;
if ($rel !== '' && $abs === null) { flash('That file cannot be opened here.', 'err'); redirect('admin/code.php'); }

if (is_post() && $abs !== null) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $back = 'admin/code.php?f=' . urlencode($rel);
    if (!password_verify((string)($_POST['password'] ?? ''), (string)q_val('SELECT password_hash FROM users WHERE id = ?', [$me['id']]))) {
        admin_log('code_edit_refused', $rel, 'wrong password');
        $_SESSION['code_draft'] = $do === 'save' ? ['f' => $rel, 'src' => (string)($_POST['src'] ?? '')] : null;   // do not lose the typing
        flash('That password isn’t right. Nothing was changed.', 'err');
        redirect($back);
    }
    if ($do === 'save') {
        [$ok, $msg] = code_save($rel, (string)($_POST['src'] ?? ''), (string)($_POST['was'] ?? ''));
        if (!$ok) $_SESSION['code_draft'] = ['f' => $rel, 'src' => (string)($_POST['src'] ?? '')];
    } elseif ($do === 'restore') {
        [$ok, $msg] = code_restore($rel, (string)($_POST['backup'] ?? ''));
        if ($ok) $msg = '↩️ Put back the earlier version of ' . $rel . '.';
    } else {
        [$ok, $msg] = [false, 'Nothing to do there.'];
    }
    if ($ok && $msg !== 'Nothing changed.') admin_log($do === 'restore' ? 'code_restore' : 'code_edit', $rel, $do === 'restore' ? (string)($_POST['backup'] ?? '') : strlen((string)($_POST['src'] ?? '')) . ' bytes');
    flash($msg, $ok ? 'ok' : 'err');
    redirect($back);
}

$files = code_files();
$src = $abs !== null ? (string)file_get_contents($abs) : '';
$was = sha1($src);
$draft = $_SESSION['code_draft'] ?? null;
unset($_SESSION['code_draft']);
$isDraft = $abs !== null && is_array($draft) && $draft['f'] === $rel;
$shown = $isDraft ? (string)$draft['src'] : $src;
$tooBig = strlen($src) > CODE_MAX_BYTES;
$badText = $abs !== null && !mb_check_encoding($src, 'UTF-8');
$canWrite = $abs !== null && is_writable($abs) && is_writable(dirname($abs));
$editable = $abs !== null && !$tooBig && !$badText && $canWrite;
$backups = $abs !== null ? code_backups($rel) : [];
page_header('Page code', true);
?>
<?php admin_crumbs('code.php', $abs !== null ? $rel : ''); ?>
<h1>🧑‍💻 Page code</h1>
<p class="help">See the code behind any game page, or change it. A save needs your password, checks PHP for typing mistakes first, and keeps the old file
  (the last <?= CODE_KEEP_BACKUPS ?> versions) so you can put it back. <b>Installing a game update replaces edited files with the update’s version.</b>
  For wording only, <a href="<?= e(url('admin/texts.php')) ?>">Page text</a> is safer.</p>
<form method="get" class="box form codepick">
  <label for="codef"><b>File</b></label>
  <select id="codef" name="f">
    <option value="">Choose a file…</option>
    <?php foreach ($files as $group => $list): ?><optgroup label="<?= e($group) ?> (<?= count($list) ?>)">
      <?php foreach ($list as $f): ?><option value="<?= e($f) ?>"<?= $f === $rel ? ' selected' : '' ?>><?= e($f) ?></option><?php endforeach; ?>
    </optgroup><?php endforeach; ?>
  </select>
  <button class="btn small">Open</button>
</form>
<?php if ($abs !== null): ?>
<div class="box">
  <h2><code><?= e($rel) ?></code></h2>
  <p class="muted"><?= number_format(strlen($src)) ?> bytes · <?= number_format(substr_count($src, "\n") + 1) ?> lines · last changed <?= e(gmdate('Y-m-d H:i', (int)filemtime($abs))) ?> UTC
    <?php if (str_ends_with($rel, '.php') && !str_contains($rel, '/')): ?> · <a href="<?= e(url($rel)) ?>" target="_blank" rel="noopener">👀 Open the page</a><?php endif; ?></p>
  <?php if ($isDraft): ?><p class="flash err">This is your unsaved change, not what is on the server. <a href="<?= e(url('admin/code.php?f=' . urlencode($rel))) ?>">Throw it away</a></p><?php endif; ?>
  <?php if (!$editable): ?>
    <p class="flash err"><?= $tooBig ? 'This file is too big to edit here; you can only read it.' : ($badText ? 'This file is not plain UTF-8 text; you can only read it.' : 'The server does not let the game write this file (file permissions), so you can only read it.') ?></p>
    <pre class="maillog codeview"><?= e($src) ?></pre>
  <?php else: ?>
    <?php if (in_array($rel, ['includes/bootstrap.php', 'includes/functions.php', 'includes/db.php', 'includes/layout.php', 'admin/code.php', 'includes/code_edit.php'], true)): ?>
      <p class="flash err">⚠️ Every page loads this file. A mistake the checker cannot see (a wrong name, not a typing error) can take the whole site down, this page included. Then the fix is to upload the backup from <code>data/code-backups/</code> over FTP.</p>
    <?php endif; ?>
    <form method="post" class="form codeform">
      <?= csrf_field() ?><input type="hidden" name="f" value="<?= e($rel) ?>"><input type="hidden" name="was" value="<?= e($was) ?>">
      <label class="asr" for="codesrc">Code of <?= e($rel) ?></label>
      <textarea id="codesrc" name="src" class="codesrc" rows="28" wrap="off" spellcheck="false" autocapitalize="off" autocomplete="off" autocorrect="off"><?= "\n" . e($shown) ?></textarea>
      <label>Your password, to save <input type="password" name="password" required autocomplete="current-password"></label>
      <p><button class="btn small" name="do" value="save">💾 Save the file</button></p>
    </form>
  <?php endif; ?>
</div>
<?php if ($backups): ?>
<details class="fold box"><summary>🕘 Earlier versions (<?= count($backups) ?>)</summary>
  <table class="list"><tr><th>Saved over at</th><th>Size</th><th></th></tr>
  <?php foreach ($backups as $b): ?>
    <tr><td><?= e(gmdate('Y-m-d H:i:s', $b['at'])) ?> UTC</td><td><?= number_format($b['size']) ?> bytes</td>
      <td><?php if ($editable): ?><form method="post" class="inline" data-confirm="Put this earlier version back? The file as it is now is kept as a new earlier version."><?= csrf_field() ?>
        <input type="hidden" name="f" value="<?= e($rel) ?>"><input type="hidden" name="backup" value="<?= e($b['name']) ?>">
        <input type="password" name="password" placeholder="Your password" required autocomplete="current-password" aria-label="Your password">
        <button class="btn small alt" name="do" value="restore">↩️ Put back</button></form><?php endif; ?></td></tr>
  <?php endforeach; ?></table>
</details>
<?php endif; ?>
<?php endif; ?>
<?php page_footer();
