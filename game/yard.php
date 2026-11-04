<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/yard.php';
require_once __DIR__ . '/includes/catalog.php';
$u = require_login();
$uid = (int)$u['id'];
$plotId = active_plot_id($uid);
if (!$plotId) redirect('garden.php');

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'save') {
        [$ok, $msg] = yard_save($u, $plotId, (string)($_POST['layout'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
        redirect($ok ? 'garden.php' : 'yard.php');
    } elseif ($do === 'undo') {   // v0.9.5: back to how the yard was before the last save
        [$ok, $msg] = yard_undo($u, $plotId);
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'extend') {
        [$ok, $msg] = yard_extend($u, $plotId, (string)($_POST['dir'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    }
    redirect('yard.php');
}

refresh_energy($u);
[$plot, $tiles, $plants] = load_plot($uid);
$objs = yard_objects($plotId);
$owned = decor_owned($uid);
[$yw, $yh] = yard_size($plot);
$byType = [];
foreach ($owned as $id => $d) $byType[$d['def']['type']][$id] = $d;
$waiting = array_filter($objs, fn($o) => (int)$o['x'] < 0);

page_header('Design your yard');
?>
<h1>✏️ Design your yard</h1>
<p class="help"><b>Drag</b> things to move them, or <b>tap</b> one and then tap where it should go. Drag decor from the tray onto the yard, and back to the tray to put it away.
  Empty bed squares can move too; beds with something growing stay put. Nothing changes until you press <b>Save</b>.
  Fences, walls and hedges join up by themselves; <b>🔀 Shape</b> picks a shape by hand.</p>
<noscript><div class="flash err">The yard designer needs JavaScript turned on.</div></noscript>

<div class="yardtools" data-yard-tools>
  <button type="button" class="btn small" data-act="rotate" disabled>↻ Rotate</button>
  <button type="button" class="btn small" data-act="shape" disabled title="Fences, walls and hedges join their neighbours by themselves. Tap to choose a shape instead: end, straight, corner, T, cross, then back to automatic.">🔀 Shape</button>
  <button type="button" class="btn small" data-act="away" disabled>📦 Put away</button>
  <label class="multi"><input type="checkbox" data-act="multi"> Pick several</label>
  <label class="multi"><input type="checkbox" data-act="grid"> Grid</label>
  <label class="multi"><input type="checkbox" data-act="snap" checked> Snap to beds</label>
  <button type="button" class="btn small alt" data-act="undo" disabled>↶ Undo</button>
  <button type="button" class="btn small" data-act="save">💾 Save</button>
  <a class="btn small alt" href="<?= e(url('garden.php')) ?>">Cancel</a>
  <span class="yardstatus" data-yard-status role="status">Tap or drag something to start.</span>
</div>

<div class="designer">
  <div class="yardwrap"><?= render_yard($plot, $tiles, $plants, $objs, 'edit') ?></div>
  <div class="tray box" data-tray>
    <h3>Tray</h3>
    <?php if ($waiting): ?>
      <p class="help">Waiting for a spot:</p>
      <div class="traygroup">
      <?php foreach ($waiting as $o): ?>
        <button type="button" class="trayitem" data-key="o<?= (int)$o['id'] ?>" title="<?= e($o['name']) ?>"><span class="oi"><?= e($o['icon']) ?></span> <?= e($o['name']) ?> <small><?= (int)$o['bw'] ?>×<?= (int)$o['bh'] ?></small></button>
      <?php endforeach; ?>
      </div>
    <?php endif; ?>
    <?php if (!$owned && !$waiting): ?>
      <p class="muted">No decorations in your satchel yet.</p>
    <?php endif; ?>
    <?php foreach (DECOR_TYPES as $type => $label): if (empty($byType[$type])) continue; ?>
      <p class="traylabel"><?= e($label) ?></p>
      <div class="traygroup">
      <?php foreach ($byType[$type] as $id => $d): $def = $d['def']; ?>
        <button type="button" class="trayitem" data-item="<?= (int)$id ?>" data-qty="<?= (int)$d['qty'] ?>" data-w="<?= $def['w'] ?>" data-h="<?= $def['h'] ?>"
          data-fam="<?= e(yard_family(['kind' => 'decor', 'bw' => $def['w'], 'bh' => $def['h'], 'look' => $d['slug'], 'type' => $def['type']])) ?>"
          data-img="<?= e(($im = yard_decor_image((string)$d['slug'], (string)($d['image'] ?? ''))) !== '' ? url($im) : '') ?>" data-icon="<?= e($def['icon']) ?>" data-type="<?= e($def['type']) ?>" data-look="<?= e($d['slug']) ?>" data-name="<?= e($d['name']) ?>"
          title="<?= e($d['name'] . ($def['bonus'] !== '' ? ' · ' . YARD_BONUSES[$def['bonus']][3] : '') . ' · appeal ' . $def['appeal']) ?>">
          <span class="swatch t-<?= e($def['type']) ?> d-<?= e($d['slug']) ?>"><?= e($def['icon']) ?></span> <?= e($d['name']) ?>
          <?= $def['w'] * $def['h'] > 1 ? '<small>' . $def['w'] . '×' . $def['h'] . '</small>' : '' ?> <b data-left>×<?= (int)$d['qty'] ?></b></button>
      <?php endforeach; ?>
      </div>
    <?php endforeach; ?>
    <p class="help">Buy decor at the <b>Hedge &amp; Hearth</b> in Mossbottom Market, or make it on the <a href="<?= e(url('inventory.php?tab=craft')) ?>">Crafting</a> page (Yard &amp; decor).</p>
  </div>
</div>

<?php if ($hist = yard_history_count($plotId)): ?>
<form method="post" class="inline" data-confirm="Put the yard back how it was before your last save?"><?= csrf_field() ?><input type="hidden" name="do" value="undo">
  <button class="btn small alt">↶ Undo last save (<?= $hist ?>)</button></form>
<?php endif; ?>
<form method="post" id="yardsave" hidden><?= csrf_field() ?><input type="hidden" name="do" value="save"><input type="hidden" name="layout" value=""></form>

<div class="box">
  <h3>Placement bonuses</h3>
  <ul class="bonuslist">
    <?php foreach (YARD_BONUSES as $k => [$icon, $name, $reach, $text]): ?>
      <li><?= $icon ?> <b><?= e($name) ?></b>: <?= e($text) ?></li>
    <?php endforeach; ?>
  </ul>
</div>

<div class="box">
  <h3>Make the yard bigger</h3>
  <p>Your yard is <?= $yw ?> × <?= $yh ?> squares. It grows by itself as your beds do, and you can buy extra room:
    <b><?= money(yard_extend_cost($plot)) ?></b> for the next column or row.</p>
  <?php foreach (['w' => 'Add a column', 'h' => 'Add a row'] as $dir => $lab):
      $side = $dir === 'w' ? $yw : $yh;
      if ($side < YARD_MAX_SIDE && (int)$plot['yard_x' . $dir] < (int)setting('yard_extend_max')): ?>
    <form method="post" class="inline" data-confirm="Spend <?= number_format(yard_extend_cost($plot)) ?> to make the yard bigger? (Unsaved changes here will be lost.)"><?= csrf_field() ?>
      <input type="hidden" name="do" value="extend"><input type="hidden" name="dir" value="<?= $dir ?>">
      <button class="btn small"><?= $lab ?></button></form>
  <?php endif; endforeach; ?>
</div>
<?php page_footer();
