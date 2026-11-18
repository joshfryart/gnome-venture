<?php
declare(strict_types=1);
// 2.7.00 The Tailor: make wearables, line them, finish them, re-cut them (includes/wearables.php; plan claude/plan-tailor-2.7.00.md).
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/wearables.php';
$u = require_login();
$uid = (int)$u['id'];
if (!wear_live($u)) { flash('Nothing here yet.', 'err'); redirect('index.php'); }
wear_ensure_items();
require_once __DIR__ . '/includes/almanac_pages.php'; almanac_unlock_wearables_2700($uid);   // the Almanac page opens on the first visit

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $slug = is_scalar($_POST['slug'] ?? null) ? (string)$_POST['slug'] : '';
    $base = is_scalar($_POST['base'] ?? null) ? (string)$_POST['base'] : '';
    $cut = (string)($_POST['cut'] ?? 'a') === 'b' ? 'b' : 'a';
    $res = match ($do) {
        'craft' => tailor_craft($u, $base, $cut),
        'line' => tailor_line($u, $slug, !empty($_POST['pity'])),
        'recut' => tailor_recut($u, $slug),
        'lined' => wear_lined_toggle($u, $slug),
        default => [false, 'Nothing to do.'],
    };
    flash($res[1], $res[0] ? 'ok' : 'err');
    redirect('tailor.php');
}

$levels = tailor_levels($uid); $power = tailor_power($uid); $has = $levels !== [];
$threads = wear_qty($uid, WEAR_THREAD);
$owned = wear_owned($uid); $linedSet = wear_lined_set($uid);
page_header('Tailor');
?>
<h1>🧵 Tailor</h1>
<?php if (!$has): ?>
  <p class="help">You need a <b>Tailor</b> built in at least one of your gardens (garden level <?= (int)BUILDINGS['tailor'][2] ?>, <?= money((int)BUILDINGS['tailor'][3]) ?>). Then you can make wearables here, line them and re-cut them. <a href="<?= e(url('garden.php')) ?>">Go to your garden</a></p>
<?php endif; ?>
<?php if ($has): ?>
  <p class="help">Your Tailors: <?= e(implode(', ', array_map(fn($l) => 'level ' . $l, $levels))) ?>. Tailor power <b><?= $power ?></b>: a lining attempt takes <b><?= tailor_chance($power) ?>%</b> of the time<?= $power > WEAR_POWER_CAP ? ' (the points over ' . WEAR_POWER_CAP . ' pay ' . tailor_commission_pct($power) . '% of the wearable’s price in commission Petals on each job)' : '' ?>. A lining that does not take gives a Tailor’s Thread; <?= WEAR_PITY ?> Threads make the next one a sure thing. You have <b><?= $threads ?></b> Thread<?= $threads === 1 ? '' : 's' ?>.<?= tailor_free_ready($uid) ? ' Your level 3 Tailor makes your first craft today for nothing.' : '' ?></p>
  <h2>Make</h2>
  <ul class="rcards tlr">
  <?php foreach (WEAR_DEFS as $base => $d): if (($d['get'] ?? '') !== 'craft') continue; ?>
    <li class="box"><b><?= ($pi = ph_path($base)) !== '' ? art_img($pi, 'md', $d['name']) : $d['icon'] ?> <?= e($d['name']) ?></b> <small class="muted"><?= e(wear_mats_text($d['mats'])) ?> · ⚡<?= (int)$d['energy'] ?></small><br><span class="help"><?= e($d['desc']) ?></span>
      <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="craft"><input type="hidden" name="base" value="<?= e($base) ?>">
        <select name="cut" aria-label="Cut"><?php foreach ($d['cuts'] as $k => $c): ?><option value="<?= e($k) ?>"><?= e($c[0]) ?>: <?= e(ucfirst($c[1])) ?> <?= (int)$c[2] ?><?= $c[3] !== '' ? ', ' . e($c[3]) : ($c[4] !== '' ? ', ' . e($c[4]) : '') ?></option><?php endforeach; ?></select>
        <button class="btn small">Make</button></form></li>
  <?php endforeach; ?>
  </ul>
  <p class="help">The Wayfarer’s Hat and the Trail Pack are sold at Twigg’s; the Yarn Scarf comes from Cat Fish. Bring them here to line or re-cut them.</p>
  <h2>Regional wearables</h2>
  <p class="help">Twenty from every region: footwear, backpacks, coats and cloaks, one puzzle piece each. The Tailor makes them once you have reached the region’s level, for a Petal fee and two things gathered in that region. Common ones need a level 1 Tailor, Uncommon level 2, Rare level 3. Lining costs Petals too (Lined is worth 1.5 times the fee, Fine 2.5 times).</p>
  <?php
    $rnames = []; foreach (q('SELECT code, gnomish_name FROM regions')->fetchAll() as $r) $rnames[(string)$r['code']] = (string)$r['gnomish_name'];
    $byRegion = []; foreach (wear_tailor_defs() as $base => $d) $byRegion[$d['region']][$base] = $d;
    uksort($byRegion, fn($a, $b) => (REGION_LEVELS[$a] ?? 99) <=> (REGION_LEVELS[$b] ?? 99));
    $coins = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
  ?>
  <?php foreach ($byRegion as $code => $defs): $need = (int)(REGION_LEVELS[$code] ?? 1); $nm = $rnames[$code] ?? $code; ?>
    <?php if ((int)$u['level'] < $need): ?>
      <p class="muted">🔒 <?= e($nm) ?>: <?= count($defs) ?> wearables once you reach level <?= $need ?>.</p>
    <?php continue; endif; ?>
    <details class="box"><summary><b><?= e($nm) ?></b> <small class="muted"><?= count($defs) ?> wearables · level <?= $need ?></small></summary>
    <ul class="rcards tlr">
    <?php foreach ($defs as $base => $d): $c = $d['cuts']['a']; $why = tailor_gate($u, $d, $levels); $fee = wear_fee($d, 1); ?>
      <li class="box"><b><?= ($pi = ph_path($base)) !== '' ? art_img($pi, 'md', $d['name']) : $d['icon'] ?> <?= e($d['name']) ?></b> <span class="tag"><?= e($d['rarity']) ?></span> <small class="muted"><?= e(WEAR_CAT_NAME[$d['cat']] ?? $d['cat']) ?></small><br>
        <span class="help">Piece: <b><?= e($c[0]) ?></b>, <?= e(ucfirst($c[1])) ?> <?= (int)$c[2] ?>. <?= e($c[5]) ?></span><br>
        <small class="muted"><?= $fee ?> Petals · <?= e(wear_mats_text($d['mats'])) ?> · ⚡<?= (int)$d['energy'] ?> · Tailor level <?= (int)$d['tailor'] ?></small>
        <?php if ($why !== null): ?><br><small class="muted"><?= e($why) ?></small>
        <?php else: ?>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="craft"><input type="hidden" name="base" value="<?= e($base) ?>"><button class="btn small"<?= $coins < $fee ? ' disabled title="Not enough Petals"' : '' ?>>Make</button></form>
        <?php endif; ?></li>
    <?php endforeach; ?>
    </ul></details>
  <?php endforeach; ?>
<?php endif; ?>
<h2>Your wearables</h2>
<?php if (!$owned): ?><p class="muted">You have no wearables yet.</p><?php else: ?>
  <ul class="rcards tlr">
  <?php foreach ($owned as $slug => $qty): [$base, $cut, $rank] = wear_parse($slug); $d = wear_defs()[$base]; $c = $d['cuts'][$cut]; $lf = ($d['get'] ?? '') === 'tailor' && $rank < 3 ? wear_fee($d, $rank + 1) - wear_fee($d, $rank) : 0; ?>
    <li class="box"><b><?= ($pi = ph_path($slug)) !== '' ? art_img($pi, 'md', $d['name']) : $d['icon'] ?> <?= e($d['name']) ?></b> <span class="tag"><?= e(WEAR_RANK_NAME[$rank]) ?></span> <small class="muted">× <?= (int)$qty ?></small><br>
      <span class="help">Piece: <b><?= e($c[0]) ?></b>, <?= e(ucfirst($c[1])) ?> <?= (int)$c[2] ?>. <?= e($c[5]) ?></span>
      <?php if ($rank === 3): $asL = in_array($base . '|' . $cut, $linedSet, true); ?>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="lined"><input type="hidden" name="slug" value="<?= e($slug) ?>"><button class="btn small alt"><?= $asL ? 'Wear as Fine' : 'Wear as Lined' ?></button></form>
      <?php endif; ?>
      <?php if ($has): ?>
        <?php if ($rank < 3): $mats = wear_line_mats($rank); ?>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="line"><input type="hidden" name="slug" value="<?= e($slug) ?>">
          <button class="btn small"><?= $rank === 1 ? 'Line it' : 'Finish it' ?></button> <small class="muted"><?= $lf ? $lf . ' Petals · ' : '' ?><?= e(wear_mats_text($mats)) ?> · ⚡2</small>
          <?php if ($threads >= WEAR_PITY): ?><button class="btn small alt" name="pity" value="1">A sure thing <small><?= WEAR_PITY ?> Threads</small></button><?php endif; ?></form>
        <?php endif; ?>
        <?php if (count($d['cuts']) > 1): ?>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="recut"><input type="hidden" name="slug" value="<?= e($slug) ?>">
          <button class="btn small alt">Re-cut to <?= e($d['cuts'][$cut === 'a' ? 'b' : 'a'][0]) ?> <small><?= max($levels) >= 2 ? 'free' : '1 Thread' ?></small></button></form>
        <?php endif; ?>
      <?php endif; ?>
    </li>
  <?php endforeach; ?>
  </ul>
  <p class="help">Wear it on <a href="<?= e(url('gnome.php?tab=gnome')) ?>#wearing">My Gnome</a> (one item in each of 7 spots); a worn item's piece can then be switched on in the <a href="<?= e(url('puzzlebox.php')) ?>">Puzzle box</a> (a Keepsake slot: 1 at level 1, 2 at 15, 3 at 25, 4 at 40). Flood Boots work on flooded roads from your satchel.</p>
<?php endif; ?>
<?php page_footer();
