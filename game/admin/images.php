<?php
declare(strict_types=1);
// v0.9.8: Images. Bulk-upload pictures for items, creatures, NPCs, buildings, building looks and fence pieces, matched by file name.
require dirname(__DIR__) . '/includes/bootstrap.php';
require dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();
require_once dirname(__DIR__) . '/includes/art_upload.php';

$report = null;
if (is_post() && ($_POST['do'] ?? '') === 'delete') {   // delete one uploaded picture, back to the same search
    csrf_check();
    $rel = (string)($_POST['path'] ?? '');
    if (art_delete($rel)) { admin_log('image_delete', $rel, ''); flash('Deleted ' . $rel . '. The built-in picture (if any) shows again.'); }
    else flash('Only uploaded pictures can be deleted.', 'err');
    redirect('admin/images.php?' . http_build_query(array_filter(['q' => (string)($_POST['q'] ?? ''), 'src' => (string)($_POST['src'] ?? ''), 'page' => (string)($_POST['page'] ?? '')])) . '#browse');
}
if (is_post()) {
    csrf_check();
    @set_time_limit(300);
    $f = $_FILES['pics'] ?? null;
    if (!$f || !is_array($f['name'] ?? null) || !array_filter((array)$f['name'], fn($n) => $n !== '')) {
        flash('Pick one or more pictures, or a zip file.', 'err');
        redirect('admin/images.php');
    }
    $report = art_process_upload($f);
    item_art_map(true);
    $cnt = array_count_values(array_column($report, 1));
    admin_log('images_upload', (string)count($report) . ' files', json_encode($cnt));
}
$prog = art_progress(25);
$bq = substr(preg_replace('/[^a-z0-9_\/.-]/', '', strtolower((string)($_GET['q'] ?? ''))), 0, 60);
$bs = isset(ART_BROWSE[(string)($_GET['src'] ?? '')]) ? (string)$_GET['src'] : '';
$found = art_browse($bq, $bs);
$per = 60; $pages = max(1, (int)ceil(count($found) / $per)); $pg = max(1, min($pages, (int)($_GET['page'] ?? 1)));
$show = array_slice($found, ($pg - 1) * $per, $per);
$bu = fn(int $n) => 'admin/images.php?' . http_build_query(array_filter(['q' => $bq, 'src' => $bs, 'page' => $n > 1 ? $n : ''])) . '#browse';

page_header('Images', true);
?>
<?php admin_crumbs('images.php');   // v1.6.3 ?>
<h1>Images</h1>
<div class="box">
  <h3>Upload pictures</h3>
  <p class="help">Pick many pictures at once, or one <b>.zip</b>. Each file is matched by its name and saved for you (PNG, JPG or WebP, up to <?= (int)setting('image_max_kb') ?> KB each; change in <a href="<?= e(url('admin/settings.php')) ?>">Game settings</a>). Everything is re-saved as a PNG.</p>
  <ul class="help">
    <li>Item: <code>{item slug}.png</code>, e.g. <code>garden-honey.png</code> (draw at 80×80 or 128×128; shown at 24, 40 or 64 pixels)</li>
    <li>Creature: <code>creature-{slug}.png</code> &nbsp; NPC portrait: <code>npc-{slug}.png</code> (400×500)</li>
    <li>Menu icon: <code>nav-{name}.png</code> (64×64 or 128×128), one of: <?= e(implode(', ', array_keys(NAV_ICONS))) ?></li>
    <li>Building at a level: <code>{building}-{1,2,3}.png</code>, e.g. <code>kitchen-2.png</code> &nbsp; Building look: <code>{building}-{mossy|painted|lantern}.png</code></li>
    <li>Fence, wall or hedge pieces: <code>{item slug}-{end|straight|corner|tee|cross|gate}.png</code></li>
  </ul>
  <form method="post" enctype="multipart/form-data"><?= csrf_field() ?>
    <input type="file" name="pics[]" multiple required accept=".png,.jpg,.jpeg,.webp,.zip,image/png,image/jpeg,image/webp,application/zip">
    <button class="btn small">Upload</button></form>
</div>
<?php if ($report !== null): $cnt = array_count_values(array_column($report, 1)); ?>
<div class="box" id="report">
  <h3>Report</h3>
  <p><b class="good"><?= (int)($cnt['matched'] ?? 0) ?> matched</b> · <b><?= (int)($cnt['replaced'] ?? 0) ?> replaced</b> · <b><?= (int)($cnt['unmatched'] ?? 0) ?> unmatched</b> · <b class="bad"><?= (int)($cnt['rejected'] ?? 0) ?> rejected</b></p>
  <table class="grid">
    <tr><th>File</th><th>Result</th><th>Details</th></tr>
    <?php foreach ($report as [$file, $status, $msg]): ?>
      <tr class="rep-<?= e($status) ?>"><td><?= e($file) ?></td><td><?= e($status) ?></td><td><?= e($msg) ?></td></tr>
    <?php endforeach; ?>
  </table>
</div>
<?php endif; ?>
<div class="box" id="browse">
  <h3>Browse pictures</h3>
  <p class="help">Every picture the game can show. <b>Uploaded</b> ones win over <b>built-in</b> ones with the same name, so an old upload hides newer built-in art: delete it to bring the built-in one back.</p>
  <form method="get" action="<?= e(url('admin/images.php')) ?>#browse" class="inline">
    <input type="search" name="q" value="<?= e($bq) ?>" placeholder="Search by file name, e.g. beehive" aria-label="Search pictures">
    <select name="src" aria-label="Where from"><option value="">All sources</option>
      <?php foreach (array_keys(ART_BROWSE) as $l): ?><option value="<?= e($l) ?>"<?= $bs === $l ? ' selected' : '' ?>><?= e(ucfirst($l)) ?></option><?php endforeach; ?></select>
    <button class="btn small">Search</button>
  </form>
  <p class="help"><?= count($found) ?> picture<?= count($found) === 1 ? '' : 's' ?><?= $pages > 1 ? ' · page ' . $pg . ' of ' . $pages : '' ?></p>
  <div class="artgrid">
  <?php foreach ($show as [$rel, $label, $bytes, $mt, $over]): ?>
    <figure class="artcard<?= $over ? ' over' : '' ?>">
      <img src="<?= e(url($rel)) ?>" width="64" height="64" loading="lazy" decoding="async" alt="">
      <figcaption><code><?= e(substr($rel, (int)strrpos($rel, '/') + 1)) ?></code><br>
        <span class="tag"><?= e($label) ?></span><?= $over ? ' <span class="tag phtag">hides built-in</span>' : '' ?><br>
        <span class="muted"><?= round($bytes / 1024, 1) ?> KB<?= $label === 'uploaded' ? ' · ' . e(date('Y-m-d', $mt)) : '' ?></span>
        <?php if ($label === 'uploaded'): ?>
          <form method="post" class="inline" data-confirm="Delete this uploaded picture?"><?= csrf_field() ?>
            <input type="hidden" name="do" value="delete"><input type="hidden" name="path" value="<?= e($rel) ?>">
            <input type="hidden" name="q" value="<?= e($bq) ?>"><input type="hidden" name="src" value="<?= e($bs) ?>"><input type="hidden" name="page" value="<?= $pg ?>">
            <button class="btn small danger">Delete</button></form>
        <?php endif; ?>
      </figcaption>
    </figure>
  <?php endforeach; ?>
  </div>
  <?php if (!$show): ?><p class="help">Nothing matches.</p><?php endif; ?>
  <?php if ($pages > 1): ?><p>
    <?php if ($pg > 1): ?><a class="btn small alt" href="<?= e(url($bu($pg - 1))) ?>">← Previous</a><?php endif; ?>
    <?php if ($pg < $pages): ?><a class="btn small alt" href="<?= e(url($bu($pg + 1))) ?>">Next →</a><?php endif; ?></p><?php endif; ?>
</div>
<div class="box" id="missing">
  <h3>Missing art</h3>
  <table class="grid">
    <tr><th>Category</th><th>With a picture</th><th>Missing</th><th>…of those, a placeholder</th></tr>
    <?php $T = [0, 0, 0]; foreach ($prog['cats'] as $c => [$total, $have, $phn]): $T[0] += $total; $T[1] += $have; $T[2] += $phn; ?>
      <tr><td><?= e($c) ?></td><td><?= (int)$have ?> / <?= (int)$total ?></td><td><?= $total - $have ? (int)($total - $have) : '<span class="good">0 ✔</span>' ?></td><td><?= $phn ? '<span class="tag phtag">' . (int)$phn . ' placeholder</span>' : '' ?></td></tr>
    <?php endforeach; ?>
    <tr><th>All</th><th><?= $T[1] ?> / <?= $T[0] ?></th><th><?= $T[0] - $T[1] ?></th><th><?= $T[2] ?></th></tr>
    <?php /* v1.5.2: red-outlined placeholders (assets/img/ph/) still count as missing; real art always replaces them */ ?>
  </table>
  <?php if ($prog['missing']): ?>
    <h4>Items most worth drawing next</h4>
    <p class="help">Ordered by how many gnomes hold them and how many shops sell them. The file name to use is shown.</p>
    <table class="grid">
      <tr><th>Item</th><th>Category</th><th>File name</th></tr>
      <?php foreach ($prog['missing'] as $it): ?>
        <tr><td><?= e($it['name']) ?><?= !empty($it['ph']) ? ' <span class="tag phtag">placeholder</span>' : '' ?></td><td><?= e($it['category']) ?></td><td><code><?= e($it['slug']) ?>.png</code></td></tr>
      <?php endforeach; ?>
    </table>
    <?php if ($prog['missing_total'] > count($prog['missing'])): ?><p class="help">…and <?= (int)($prog['missing_total'] - count($prog['missing'])) ?> more items.</p><?php endif; ?>
  <?php endif; ?>
</div>
<?php page_footer();
