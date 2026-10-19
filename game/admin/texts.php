<?php
declare(strict_types=1);
/** v0.8.9: edit the words on the public pages (front page, How to play, Join). The original text is always kept as a default. */
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/site_text.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();

$pages = array_values(array_unique(array_column(SITE_TEXTS, 0)));
$pageName = in_array($_GET['page'] ?? '', $pages, true) ? (string)$_GET['page'] : $pages[0];

if (is_post()) {
    csrf_check();
    $key = (string)($_POST['key'] ?? '');
    $back = 'admin/texts.php?page=' . urlencode(SITE_TEXTS[$key][0] ?? $pageName) . '#t-' . str_replace('.', '-', $key);
    if (!isset(SITE_TEXTS[$key])) {
        flash('Unknown text.', 'err');
        redirect('admin/texts.php');
    }
    [, $label, $default, $kind] = SITE_TEXTS[$key];
    if (($_POST['do'] ?? '') === 'reset') {
        q('DELETE FROM site_texts WHERE skey = ?', [$key]);
        admin_log('text_reset', $key);
        flash('↩️ “' . $label . '” is back to the original.');
        redirect($back);
    }
    $body = str_replace("\r\n", "\n", trim((string)($_POST['body'] ?? '')));
    if ($kind === 'line') $body = preg_replace('/\s*\n\s*/', ' ', $body);
    if ($body === '') {
        flash('That text can’t be empty. Use “Back to original” instead.', 'err');
        redirect($back);
    }
    if (mb_strlen($body) > 8000) {
        flash('That’s too long (8,000 letters at most).', 'err');
        redirect($back);
    }
    if ($kind === 'faq' && !preg_match('/^\s*Q:.+\R\s*A:/s', $body)) {
        flash('Questions need “Q:” at the start of each question and “A:” at the start of its answer, with a blank line between them.', 'err');
        redirect($back);
    }
    if ($body === $default) {
        q('DELETE FROM site_texts WHERE skey = ?', [$key]);
    } elseif (q_val('SELECT 1 FROM site_texts WHERE skey = ?', [$key])) {
        q('UPDATE site_texts SET body = ?, updated_at = ? WHERE skey = ?', [$body, now(), $key]);
    } else {
        db_insert('site_texts', ['skey' => $key, 'body' => $body, 'updated_at' => now()]);
    }
    admin_log('text_edit', $key, mb_substr($body, 0, 200));
    flash('✅ Saved “' . $label . '”.');
    redirect($back);
}

$stored = array_column(q('SELECT skey, body, updated_at FROM site_texts')->fetchAll(), null, 'skey');
$view = ['Front page' => 'index.php', 'How to play' => 'guide.php', 'Join page' => 'register.php'];
page_header('Page text', true);
?>
<?php admin_crumbs('texts.php');   // v1.6.3 ?>
<h1>📝 Page text</h1>
<p class="help">Change the words visitors see. Your change shows straight away; the original is kept, so <b>Back to original</b> always undoes it.
  Formatting: [b]bold[/b], [i]italic[/i], [list][*]one[*]two[/list], [url=https://…]a link[/url].
  These fill themselves in: <code>{site}</code> game name, <code>{start_region}</code> where everyone starts, <code>{energy_rate}</code>
  how energy comes back (e.g. “1 energy every minute”), <code>{native}</code> native-region bonus %, <code>{pages}</code> Almanac pages, <code>{regions}</code> number of regions.</p>
<p class="help">Other words you can edit: <a href="<?= e(url('admin/crud.php?r=pages')) ?>">Pages</a> (Rules, Privacy),
  <a href="<?= e(url('admin/crud.php?r=news')) ?>">News</a>, <a href="<?= e(url('admin/crud.php?r=encyclopedia_entries')) ?>">Almanac entries</a>
  (the “Getting started” pages also show on How to play), <a href="<?= e(url('admin/crud.php?r=regions')) ?>">Regions</a> (climates) and
  <a href="<?= e(url('admin/settings.php')) ?>">Game settings</a> (search description, message of the day).</p>
<nav class="tabs">
  <?php foreach ($pages as $p): ?><a class="tab<?= $p === $pageName ? ' on' : '' ?>" href="<?= e(url('admin/texts.php?page=' . urlencode($p))) ?>"><?= e($p) ?></a><?php endforeach; ?>
</nav>
<p><a href="<?= e(url($view[$pageName] ?? 'index.php')) ?>" target="_blank" rel="noopener">👀 View the <?= e($pageName) ?></a>
  <?= $pageName === 'Front page' ? '<span class="muted">(log out or use a private window to see it as a visitor does)</span>' : '' ?></p>
<?php foreach (SITE_TEXTS as $key => [$page, $label, $default, $kind]): if ($page !== $pageName) continue;
    $changed = isset($stored[$key]);
    $cur = $changed ? (string)$stored[$key]['body'] : $default;
    $rows = $kind === 'line' ? 2 : min(18, max(4, (int)ceil(mb_strlen($cur) / 60) + substr_count($cur, "\n"))); ?>
  <div class="box" id="t-<?= e(str_replace('.', '-', $key)) ?>">
    <form method="post" class="form">
      <?= csrf_field() ?><input type="hidden" name="key" value="<?= e($key) ?>">
      <label><b><?= e($label) ?></b> <?= $changed ? '<span class="tag">changed</span> <small class="muted">' . e((string)$stored[$key]['updated_at']) . ' UTC</small>' : '<small class="muted">original</small>' ?>
        <textarea name="body" rows="<?= $rows ?>"><?= e($cur) ?></textarea></label>
      <p><button class="btn small" name="do" value="save">💾 Save</button></p>
    </form>
    <?php if ($changed): ?><form method="post" class="inline" data-confirm="Put the original text back? Your version will be lost."><?= csrf_field() ?><input type="hidden" name="key" value="<?= e($key) ?>">
      <button class="btn small alt" name="do" value="reset">↩️ Back to original</button></form><?php endif; ?>
    <?php if ($changed): ?><details class="fold"><summary>Original text (<?= e($key) ?>)</summary><p class="muted"><?= nl2br(e($default)) ?></p></details><?php endif; ?>
  </div>
<?php endforeach; ?>
<?php page_footer();
