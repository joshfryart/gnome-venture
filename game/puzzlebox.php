<?php
declare(strict_types=1);
/**
 * The Puzzle box (puzzle combat): the tiles a gnome brings to a fight. It only holds so many (pf_box_capacity: 8 at level 1, +1 per 3 levels, 14 at most),
 * so the gnome chooses from everything they own (the base six, their calling tile and the unlocks). Logic: includes/pfight.php (pf_box*), storage: includes/pfight_game.php (pbox_*).
 * Behind pfight_open. Plain form, works without JS; assets/pbox.js only keeps the count. No inline script or style (CSP).
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/pfight_game.php';
$u = require_login();
if (!pfight_on($u) || is_guest($u)) { flash('The Puzzle box is not open yet.', 'err'); redirect('gnome.php'); }
$uid = (int)$u['id'];
$lvl = (int)$u['level']; $cal = (string)($u['calling'] ?? '');
$cap = pf_box_capacity($lvl);

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'reset') { pbox_save($u, null); flash('Back to the default box.', 'ok'); }
    elseif ($do === 'save') {
        $why = pbox_save($u, array_map('strval', (array)($_POST['tile'] ?? [])));
        flash($why ?? 'Box packed.', $why ? 'err' : 'ok');
    }
    redirect('puzzlebox.php');
}

[$st, , $bonus] = pfight_calc($u);
$own = pf_collection($lvl, $cal);
$box = pf_box($lvl, $cal, pbox_load($uid));
page_header('Puzzle box');
?>
<link rel="stylesheet" href="<?= e(url('assets/pfight.css?v=' . APP_VERSION)) ?>">
<div class="box pbox" id="pbox" data-cap="<?= $cap ?>" data-min="<?= PF_BOX_MIN ?>">
  <h2>🧩 Puzzle box</h2>
  <p class="help">Your box holds <b><?= $cap ?></b> tiles (it grows as you level). Pack the ones you want in a fight: <?= PF_BOX_MIN ?> at least, and at least one ⚔️ Hurt tile. You own <?= count($own) ?>.</p>
  <form method="post" class="pbox-form">
    <?= csrf_field() ?><input type="hidden" name="do" value="save">
    <p class="pbox-count" aria-live="polite"><span id="pbox-n"><?= count($box) ?></span> of <?= $cap ?> packed</p>
    <ul class="pbox-list">
    <?php foreach ($own as $k):
        $def = pf_tiles()[$k]; $tile = pf_make_tile($k, $st, ($bonus[$def['t']] ?? 0) + ($cal === 'bloomcaller' && in_array($def['t'], ['charm', 'soothe'], true) ? 2 : 0));
        $tg = PF_TAGS[$def['tag'] ?? ''] ?? null; $on = in_array($k, $box, true);
        $view = ['n' => $tile['n'], 't' => $tile['t'], 'v' => $tile['v'], 'r' => $tile['r'], 'hole' => PF_HOLE[$tile['t']], 'tag' => $def['tag'] ?? '']; ?>
      <li><label class="pbox-item"><input type="checkbox" name="tile[]" value="<?= e($k) ?>"<?= $on ? ' checked' : '' ?>>
        <span class="pfight"><?= pfight_tile_html($view, true) ?></span>
        <span class="pbox-txt"><b><?= e($tile['n']) ?></b> · <?= e(ucfirst($tile['t'])) ?> <?= (int)$tile['v'] ?><?= $tg ? '<br><small>' . $tg[0] . ' ' . e($tg[1]) . '</small>' : '' ?></span></label></li>
    <?php endforeach; ?>
    </ul>
    <p><button class="btn primary">Pack the box</button></p>
  </form>
  <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="reset"><button class="btn">Use the default box</button></form>
  <p class="help">A pal swaps in for one of these tiles in a fight. A change applies from your next fight.</p>
</div>
<script src="<?= e(url('assets/pbox.js?v=' . APP_VERSION)) ?>" defer></script>
<?php page_footer();
