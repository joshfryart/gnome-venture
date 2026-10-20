<?php
declare(strict_types=1);
// v2.0.4: Road text editor. Tune the wording of road lines, road/wild scenes (scene, buttons, outcomes), wonder text and delve rooms without a release.
// The data files are the defaults; a row here (status Draft or Live with a body) overrides ONE text. Only words: conditions, lands, stats, dc and effects stay in the files.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/road_text.php';
$me = require_admin();

function rt_arg(string $name): string
{
    foreach ([$_GET[$name] ?? null, $_POST['f_' . $name] ?? null] as $v) if (is_scalar($v)) return (string)$v;
    return '';
}
$fKind = rt_arg('kind');
if (!isset(ROAD_TEXT_KINDS[$fKind])) $fKind = '';
$fStatus = rt_arg('status');
if (!in_array($fStatus, ['todo', 'draft', 'done', 'changed'], true)) $fStatus = '';
$fSearch = mb_substr(trim(rt_arg('q')), 0, 60);
$fPage = max(1, (int)rt_arg('p'));
const ROAD_TEXT_PER_PAGE = 25;
$filterQs = http_build_query(array_filter(['kind' => $fKind ?: null, 'status' => $fStatus ?: null, 'q' => $fSearch !== '' ? $fSearch : null]));

if (!road_text_ensure_table()) { page_header('Road text', true); echo '<p class="flash err">The road_texts table could not be created. Run Admin -> Update once, then come back.</p>'; page_footer(); exit; }
$catalog = road_text_catalog();

if (is_post()) {
    csrf_check();
    $key = is_scalar($_POST['key'] ?? null) ? (string)$_POST['key'] : '';
    $row = strlen($key) <= 120 ? q_one('SELECT * FROM road_texts WHERE text_key = ?', [$key]) : null;
    $back = 'admin/road_text.php?' . ($filterQs !== '' ? $filterQs . '&' : '') . 'p=' . $fPage . '&open=' . rawurlencode($key) . '#r-' . substr(sha1($key), 0, 10);
    if (!$row) { flash('Unknown text.', 'err'); redirect('admin/road_text.php'); }
    if (!empty($_POST['restore']) || !empty($_POST['delete'])) {
        if (!empty($_POST['delete']) && !isset($catalog[$key])) { q('DELETE FROM road_texts WHERE id = ?', [$row['id']]); admin_log('road_text', $key, 'deleted an orphan'); flash('Deleted.'); redirect('admin/road_text.php?' . $filterQs); }
        q("UPDATE road_texts SET body = NULL, status = 'todo', updated_at = ? WHERE id = ?", [now(), $row['id']]);
        admin_log('road_text', $key, 'restored the file text');
        flash('↩️ Back to the file text.');
        redirect($back);
    }
    $max = $catalog[$key][5] ?? ROAD_TEXT_MAX['event'];
    [$body, $err] = road_text_clean(is_scalar($_POST['body'] ?? null) ? (string)$_POST['body'] : '', (int)$max);
    if ($body === null) { flash($err, 'err'); redirect($back); }
    $status = is_scalar($_POST['status'] ?? null) ? (string)$_POST['status'] : 'done';
    if (!in_array($status, ['todo', 'draft', 'done'], true)) $status = 'done';
    if ($body === '') $status = 'todo';
    q('UPDATE road_texts SET body = ?, status = ?, updated_at = ? WHERE id = ?', [$body !== '' ? $body : null, $status, now(), $row['id']]);
    admin_log('road_text', $key, mb_substr($body, 0, 200));
    flash('✅ Saved (' . ['todo' => 'file text', 'draft' => 'draft', 'done' => 'live'][$status] . ').');
    redirect($back);
}

road_text_sync();
$counts = [];
foreach (q("SELECT kind, COUNT(*) AS n, SUM(CASE WHEN status <> 'todo' AND body IS NOT NULL AND body <> '' THEN 1 ELSE 0 END) AS o FROM road_texts GROUP BY kind")->fetchAll() as $r) $counts[(string)$r['kind']] = $r;
$where = [];
$args = [];
if ($fKind !== '') { $where[] = 'kind = ?'; $args[] = $fKind; }
if ($fStatus === 'changed') $where[] = "(body IS NOT NULL AND body <> '')";
elseif ($fStatus !== '') { $where[] = 'status = ?'; $args[] = $fStatus; }
if ($fSearch !== '') { $like = '%' . str_replace(['!', '%', '_'], ['!!', '!%', '!_'], $fSearch) . '%'; $where[] = "(text_key LIKE ? ESCAPE '!' OR orig LIKE ? ESCAPE '!' OR body LIKE ? ESCAPE '!')"; array_push($args, $like, $like, $like); }
$total = (int)q_val('SELECT COUNT(*) FROM road_texts' . ($where ? ' WHERE ' . implode(' AND ', $where) : ''), $args);
$pages = max(1, (int)ceil($total / ROAD_TEXT_PER_PAGE));
$fOpen = is_scalar($_GET['open'] ?? null) ? (string)$_GET['open'] : '';
$fPage = min($fPage, $pages);
$rows = q('SELECT * FROM road_texts' . ($where ? ' WHERE ' . implode(' AND ', $where) : '') . ' ORDER BY id LIMIT ' . ROAD_TEXT_PER_PAGE . ' OFFSET ' . (($fPage - 1) * ROAD_TEXT_PER_PAGE), $args)->fetchAll();
$orphans = q("SELECT * FROM road_texts WHERE body IS NOT NULL AND body <> ''")->fetchAll();
$orphans = array_values(array_filter($orphans, fn($r) => !isset($catalog[(string)$r['text_key']])));

page_header('Road text', true);
admin_crumbs('road_text.php');
$pager = function () use ($pages, $fPage, $filterQs) {
    if ($pages <= 1) return '';
    $h = '<p class="trekpager">';
    for ($i = 1; $i <= $pages; $i++) $h .= $i === $fPage ? '<b class="tag">' . $i . '</b> ' : '<a class="btn small ghost" href="' . e(url('admin/road_text.php?' . ($filterQs !== '' ? $filterQs . '&' : '') . 'p=' . $i)) . '">' . $i . '</a> ';
    return $h . '</p>';
};
?>
<h1>🛣️ Road text</h1>
<p class="help">The words players see on roads, in the wilds, at wonders and in delves. The data files hold the <b>file text</b> (the default). Write your own to replace one line, no release needed. <b>Live</b> and <b>Draft</b> both show to players; <b>File text</b> turns your words off but keeps them. “Restore” clears your words. Only wording is edited here: what turns up, when and how often is not.
  One line each, no HTML, no “|”, short.</p>
<p class="help"><?php foreach (ROAD_TEXT_KINDS as $k => $l): $c = $counts[$k] ?? ['n' => 0, 'o' => 0]; ?><span class="tag"><?= e($l) ?>: <?= (int)$c['o'] ?> changed / <?= (int)$c['n'] ?></span> <?php endforeach; ?></p>
<form method="get" class="form trekfilters">
  <label>Kind <select name="kind" data-autosubmit><option value="">All</option><?php foreach (ROAD_TEXT_KINDS as $k => $l): ?><option value="<?= e($k) ?>"<?= $k === $fKind ? ' selected' : '' ?>><?= e($l) ?></option><?php endforeach; ?></select></label>
  <label>Status <select name="status" data-autosubmit><option value="">All</option><?php foreach (['changed' => 'Any of my words', 'done' => 'Live', 'draft' => 'Draft', 'todo' => 'File text'] as $k => $l): ?><option value="<?= $k ?>"<?= $k === $fStatus ? ' selected' : '' ?>><?= e($l) ?></option><?php endforeach; ?></select></label>
  <label>Find <input type="search" name="q" value="<?= e($fSearch) ?>" maxlength="60"></label>
  <button class="btn small">Filter</button>
</form>
<p class="help"><?= $total ?> text<?= $total === 1 ? '' : 's' ?>.</p>
<?= $pager() ?>
<?php foreach ($rows as $r):
    $key = (string)$r['text_key'];
    $cat = $catalog[$key] ?? null;
    $live = (string)$r['status'] !== 'todo' && (string)$r['body'] !== '';
    $shown = $live ? (string)$r['body'] : (string)$r['orig'];
    $max = (int)($cat[5] ?? ROAD_TEXT_MAX['event']); ?>
  <details class="trekrow status-<?= e($r['status']) ?>" id="r-<?= e(substr(sha1($key), 0, 10)) ?>"<?= $fOpen === $key ? ' open' : '' ?>>
    <summary><span class="tag"><?= e($cat[2] ?? ROAD_TEXT_KINDS[$r['kind']] ?? $r['kind']) ?></span> <span class="tag st-<?= e($r['status']) ?>"><?= e(['todo' => 'file text', 'draft' => 'draft', 'done' => 'live'][$r['status']] ?? $r['status']) ?></span> <?= e(mb_strimwidth($shown, 0, 90, '…')) ?></summary>
    <form method="post" class="form">
      <?= csrf_field() ?><input type="hidden" name="key" value="<?= e($key) ?>">
      <input type="hidden" name="f_kind" value="<?= e($fKind) ?>"><input type="hidden" name="f_status" value="<?= e($fStatus) ?>"><input type="hidden" name="f_q" value="<?= e($fSearch) ?>"><input type="hidden" name="f_p" value="<?= $fPage ?>">
      <p class="help"><code><?= e($key) ?></code><?= $cat ? ' · ' . e($cat[3]) : '' ?></p>
      <div class="trek-sug"><b>File text</b><div class="trekdraftbody"><?= e((string)$r['orig']) ?></div></div>
      <label>Your words <small class="muted">(<?= mb_strlen((string)$r['body']) ?>/<?= $max ?>)</small>
        <textarea name="body" rows="3" maxlength="<?= $max ?>"><?= e((string)$r['body']) ?></textarea></label>
      <label>Show to players as <select name="status"><?php $sel = (string)$r['status'] === 'todo' ? 'done' : (string)$r['status'];
        foreach (['done' => 'Live', 'draft' => 'Draft (also shown)', 'todo' => 'File text (keep my words, but off)'] as $k => $l): ?><option value="<?= $k ?>"<?= $k === $sel ? ' selected' : '' ?>><?= e($l) ?></option><?php endforeach; ?></select></label>
      <p><button class="btn small">💾 Save</button> <?php if ((string)$r['body'] !== ''): ?><button class="btn small ghost" name="restore" value="1" formnovalidate>↩️ Restore the file text</button> <?php endif; ?><?= $r['updated_at'] ? '<small class="muted">saved ' . e((string)$r['updated_at']) . ' UTC</small>' : '' ?></p>
    </form>
  </details>
<?php endforeach; ?>
<?= $pager() ?>
<?php if ($orphans && $fPage === 1): ?>
  <h2>No longer in the file</h2>
  <p class="help">These words were written for a line that was edited or removed in the data file, so they are not used any more. Copy what you want, then delete.</p>
  <?php foreach ($orphans as $r): ?>
    <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="key" value="<?= e((string)$r['text_key']) ?>"><input type="hidden" name="f_kind" value="<?= e($fKind) ?>">
      <p><code><?= e((string)$r['text_key']) ?></code><br><?= e((string)$r['body']) ?> <button class="btn small ghost" name="delete" value="1" data-confirm="Delete these words?">🗑️ Delete</button></p></form>
  <?php endforeach; ?>
<?php endif; ?>
<?php page_footer();
