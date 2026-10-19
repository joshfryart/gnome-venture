<?php
declare(strict_types=1);
// v1.1.0: crop breeding. Turn hybrids on and off, give one a better chance, re-import the data file (adds missing only).
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();
require_once dirname(__DIR__) . '/includes/breeding110.php';
breeding110_boot();

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'import') {
        [$added, $skipped] = breeding110_import();
        admin_log('hybrids_import', '', "added $added, skipped $skipped");
        flash("Re-imported from hybrids.txt: $added added" . ($skipped ? ", $skipped skipped (a parent crop is missing)" : '') . '. Existing hybrids were not touched.');
    } elseif ($do === 'save') {
        $id = (int)($_POST['id'] ?? 0);
        if (q_val('SELECT 1 FROM hybrids WHERE id = ?', [$id])) {
            $en = !empty($_POST['enabled']) ? 1 : 0;
            $bonus = max(-50, min(50, (int)($_POST['chance_bonus'] ?? 0)));
            $hint = mb_substr(trim((string)($_POST['hint'] ?? '')), 0, 255);
            q('UPDATE hybrids SET enabled = ?, chance_bonus = ?, hint = ? WHERE id = ?', [$en, $bonus, $hint === '' ? null : $hint, $id]);
            admin_log('hybrid_edit', 'hybrids#' . $id, "enabled=$en bonus=$bonus");
            flash('Saved.');
        } else {
            flash('Unknown hybrid.', 'err');
        }
    }
    redirect('admin/hybrids.php');
}

$rows = q('SELECT h.*, pa.name AS an, pb.name AS bn, hp.name AS hn, (SELECT COUNT(*) FROM user_hybrids uh WHERE uh.hybrid_id = h.id) AS finders
           FROM hybrids h JOIN plants pa ON pa.id = h.parent_a_plant_id JOIN plants pb ON pb.id = h.parent_b_plant_id JOIN plants hp ON hp.id = h.plant_id ORDER BY hp.name')->fetchAll();
page_header('Hybrids', true);
?>
<?php admin_crumbs('hybrids.php');   // v1.6.3 ?>
<h1>🧬 Hybrids</h1>
<p class="help">Crop breeding: chance <?= (int)setting('hybrid_chance_pct') ?>% (+<?= (int)setting('hybrid_beehive_pct') ?>% per beehive level, up to <?= (int)setting('hybrid_chance_max_pct') ?>%), from gnome level <?= (int)setting('hybrid_min_level') ?>.
  Change these in <a href="<?= e(url('admin/settings.php')) ?>">Game settings</a>. Each hybrid is also an ordinary plant (Plants, Items) you can edit.</p>
<form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="import"><button class="btn small">Re-import from hybrids.txt (adds missing only)</button></form>
<table class="grid">
  <tr><th>Hybrid</th><th>Parents</th><th>Found by</th><th>Enabled</th><th>Chance bonus</th><th>Hint</th><th></th></tr>
  <?php foreach ($rows as $r): ?>
    <tr><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="save"><input type="hidden" name="id" value="<?= (int)$r['id'] ?>">
      <td><?= e($r['icon'] . ' ' . $r['hn']) ?><br><small class="help"><?= e((string)$r['trait']) ?></small></td>
      <td><?= e($r['an']) ?> × <?= e($r['bn']) ?></td>
      <td><?= (int)$r['finders'] ?></td>
      <td><input type="checkbox" name="enabled" value="1" <?= (int)$r['enabled'] ? 'checked' : '' ?>></td>
      <td><input type="number" name="chance_bonus" value="<?= (int)$r['chance_bonus'] ?>" min="-50" max="50" style="width:5em"></td>
      <td><input type="text" name="hint" maxlength="255" value="<?= e((string)($r['hint'] ?? '')) ?>" placeholder="(made from the parents' kinds)"></td>
      <td><button class="btn small">Save</button></td></form></tr>
  <?php endforeach; ?>
</table>
<?php if (!$rows): ?><p>No hybrids yet. Press re-import.</p><?php endif; ?>
<?php page_footer();
