<?php
declare(strict_types=1);
// 2.7.00: Trail decor editor. The dressing of one Trail section (looks, rough, floor zones, props, rough default, tree) as plain lines; no preview.
// The map data (includes/data/trail_maps/) holds the defaults; a section saved here uses the saved dressing instead; "Back to the data" deletes the edit.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/trail_decor_edit.php';
$me = require_admin();
if (!tde_ensure_table()) { page_header('Trail decor', true); echo '<p class="flash err">The table could not be made. Run Admin → Update once, then come back.</p>'; page_footer(); exit; }

$routes = trail_authored_all();
$rid = is_scalar($_GET['route'] ?? $_POST['route'] ?? null) ? (int)($_GET['route'] ?? $_POST['route']) : 0;
$sec = is_scalar($_GET['sec'] ?? $_POST['sec'] ?? null) ? (int)($_GET['sec'] ?? $_POST['sec']) : 0;
$route = $rid > 0 ? ($routes[(string)$rid] ?? null) : null;
$art = $route && isset($route['sections'][$sec]) ? $route['sections'][$sec] : null;
$back = 'admin/trail_decor.php?route=' . $rid . '&sec=' . $sec;

if (is_post()) {
    csrf_check();
    if (!$art) { flash('That route or section does not exist.', 'err'); redirect('admin/trail_decor.php'); }
    if (!empty($_POST['restore'])) { tde_save($rid, $sec, null); admin_log('trail_decor', $rid . ':' . $sec, 'back to the data'); flash('↩️ Back to the map data.'); redirect($back); }
    $in = []; foreach (['looks', 'rough', 'floor', 'props', 'rough_default', 'tree'] as $k) $in[$k] = mb_substr(is_scalar($_POST[$k] ?? null) ? (string)$_POST[$k] : '', 0, 12000);
    [$decor, $bad] = tde_parse($in, (array)$art['rows']);
    if ($decor === null) { flash('Not saved: ' . implode('; ', array_slice($bad, 0, 8)) . '.', 'err'); redirect($back); }
    tde_save($rid, $sec, $decor); admin_log('trail_decor', $rid . ':' . $sec, 'saved'); flash('✅ Saved. Tell the game to reload by walking the Trail again: no cache to clear.');
    redirect($back);
}

$edits = []; foreach (q('SELECT route_id, sec, updated_at FROM trail_decor_edits ORDER BY route_id, sec')->fetchAll() as $r) $edits[] = $r;
page_header('Trail decor', true);
?>
<h1>🌿 Trail decor</h1>
<p class="help">The dressing of a Trail section: which tiles are a hedge, a pond, a haybale. Lines only, no preview. Pick a route and a section (1 = the first), edit, save. <b><?= count($edits) ?></b> sections have an edit.</p>
<form method="get" class="form"><label>Route <select name="route"><?php foreach ($routes as $id => $r): ?><option value="<?= (int)$id ?>"<?= (int)$id === $rid ? ' selected' : '' ?>><?= (int)$id ?> · <?= e((string)($r['from'] ?? '')) ?> to <?= e((string)($r['to'] ?? '')) ?></option><?php endforeach; ?></select></label>
  <label>Section <input name="sec" type="number" min="0" value="<?= (int)$sec ?>"> <small>(0 = the first)</small></label> <button class="btn">Open</button></form>
<?php if ($art): $cur = trail_decor(array_merge($art, ['decor' => trail_decor_edit($rid, $sec) ?? ($art['decor'] ?? null)])); $edited = trail_decor_edit($rid, $sec) !== null; $w = strlen((string)$art['rows'][0]); $h = count($art['rows']); ?>
  <h2>Route <?= (int)$rid ?>, section <?= (int)$sec ?> <small>(<?= $w ?> × <?= $h ?> tiles, x across, y down from 0)</small><?= $edited ? ' <span class="pchip">edited here</span>' : '' ?></h2>
  <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="route" value="<?= (int)$rid ?>"><input type="hidden" name="sec" value="<?= (int)$sec ?>">
    <?php foreach (TDE_RECT_FIELDS as $f => $lab): ?><label><?= e($lab) ?> <small>(one per line: kind x0 y0 x1 y1; no overlaps)</small><textarea name="<?= e($f) ?>" rows="5"><?= e(tde_lines($cur, $f)) ?></textarea></label><?php endforeach; ?>
    <label>Props <small>(one per line: kind x y)</small><textarea name="props" rows="5"><?= e(tde_lines($cur, 'props')) ?></textarea></label>
    <label>Rough default <input name="rough_default" maxlength="20" value="<?= e((string)($cur['rough_default'] ?? '')) ?>"> <small>what rough tiles outside the rectangles are</small></label>
    <label>Tree <input name="tree" maxlength="20" value="<?= e((string)($cur['tree'] ?? '')) ?>"></label>
    <p class="help">Known kinds: <?= e(implode(', ', tde_kinds())) ?>. Any other lowercase word is kept but has no colour in the fallback look.</p>
    <button class="btn">💾 Save</button> <?php if ($edited): ?><button class="btn ghost" name="restore" value="1">↩️ Back to the map data</button><?php endif; ?>
  </form>
<?php elseif ($rid > 0): ?><p class="flash err">That route or section does not exist.</p><?php endif; ?>
<?php if ($edits): ?><h2>Edited sections</h2><ul><?php foreach ($edits as $r): ?><li><a href="<?= e(url('admin/trail_decor.php?route=' . (int)$r['route_id'] . '&sec=' . (int)$r['sec'])) ?>">route <?= (int)$r['route_id'] ?>, section <?= (int)$r['sec'] ?></a> <small class="muted"><?= e((string)$r['updated_at']) ?></small></li><?php endforeach; ?></ul><?php endif; ?>
<?php page_footer();
