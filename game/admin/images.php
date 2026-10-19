<?php
declare(strict_types=1);
// v0.9.8: Images. Bulk-upload pictures for items, creatures, NPCs, buildings, building looks and fence pieces, matched by file name.
require dirname(__DIR__) . '/includes/bootstrap.php';
require dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();
require_once dirname(__DIR__) . '/includes/art_upload.php';

$report = null;
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
