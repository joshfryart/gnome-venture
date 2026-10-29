<?php
declare(strict_types=1);
/**
 * Cat Fish (Lazy Rod): adopt a cat, a toy rod sways by itself, the cat catches fish and drops Kibble, Kibble buys upgrades. Plan: claude/plan-catfish.md.
 * Plain forms do everything (adopt, buy, switch, rename); assets/catfish.js only keeps the Kibble counter ticking and buys without a reload.
 * No inline script or style (CSP): data goes in a JSON block.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/catfish.php';
$u = require_login();
if (!catfish_open()) { flash('Cat Fish is coming soon.', 'err'); redirect('games.php'); }
if (!empty($u['guest'])) { flash('Guests can look around, but making your own gnome is needed to keep a cat.', 'err'); redirect('games.php'); }
if (!catfish_ensure()) { flash('Cat Fish could not start. Try again soon.', 'err'); redirect('games.php'); }
$uid = (int)$u['id'];
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $r = [false, 'Unknown action.'];
    if ($do === 'adopt') $r = catfish_adopt($uid, (int)($_POST['slot'] ?? -1), (string)($_POST['name'] ?? ''), (string)($_POST['day'] ?? ''));
    elseif ($do === 'buy') $r = catfish_buy($uid, (string)($_POST['key'] ?? ''));
    elseif ($do === 'nap') $r = catfish_nap($uid);
    elseif ($do === 'switch') $r = catfish_switch($uid, (int)($_POST['cat'] ?? 0));
    elseif ($do === 'rename') $r = catfish_rename($uid, (int)($_POST['cat'] ?? 0), (string)($_POST['name'] ?? ''));
    flash($r[1], $r[0] ? 'ok' : 'err');
    redirect('catfish.php');
}
$v = catfish_view($uid);
$cats = catfish_cats($uid);
$cat = $v['cat'];
$shelter = catfish_shelter($uid);
$owned = count($cats); $room = $owned < catfish_slots($uid);
$adoptCost = catfish_adopt_cost($owned);
$J = JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT;
/** One cat as a tinted placeholder block plus its trait line. */
$catCard = function (array $c): string {
    $traits = ucfirst($c['colour']) . ' ' . $c['pattern'] . ', ' . $c['eyes'] . ' eyes' . ($c['ears'] === 'folded' ? ', folded ears' : '') . ($c['tail'] === 'bobtail' ? ', bobtail' : '');
    return '<span class="cfcat c-' . e($c['colour']) . ' p-' . e($c['pattern']) . ' e-' . e($c['eyes']) . '" aria-hidden="true">🐱</span>'
        . '<span class="cfinfo"><b>' . e($c['name']) . '</b> <span class="cfrar r-' . e($c['rarity']) . '">' . e(ucfirst($c['rarity'])) . '</span><br>'
        . '<small>' . e($traits) . '</small><br><small class="muted">' . e(ucfirst($c['mood'])) . ($c['quirk'] !== '' ? ' · ' . e($c['quirk']) : '') . '</small></span>';
};
page_header('Cat Fish');
?>
<h1>🐱 Cat Fish</h1>
<?php if (!$cat): ?>
<p class="help">Pick a cat to take home. Your first one is free. The shelter shows new cats every day.</p>
<?php else: ?>
<div class="cfscene box">
  <div class="cfrod" aria-hidden="true"><span class="cfwand">🎣</span><span class="cffish f1">🐟</span><span class="cffish f2">🐠</span><span class="cffish f3">🐡</span></div>
  <div class="cfmain"><div class="cfhold"><?= $catCard($cat) ?></div>
    <p class="cfcount"><b id="cf-kibble"><?= number_format($v['kibble']) ?></b> Kibble <small class="muted">· <span id="cf-kph"><?= e((string)$v['kph']) ?></span> an hour</small></p>
    <p class="help">Your cat keeps catching fish while you are away (half speed, up to <?= (int)(catfish_offline_cap($cat) / 3600) ?> hours).<?= $v['gained'] > 0 ? ' While you were away: +' . number_format($v['gained']) . ' Kibble.' : '' ?></p></div>
</div>
<h2>Upgrades</h2>
<p id="cf-msg" role="status"></p>
<div class="cfups" id="cf-ups">
<?php foreach (CATFISH_BRANCHES as $bk => $bl): ?>
  <h3><?= e($bl) ?></h3>
<?php foreach ($v['ups'] as $up): if ($up['branch'] !== $bk) continue; ?>
  <form method="post" class="cfup" data-key="<?= e($up['key']) ?>">
    <?= csrf_field() ?><input type="hidden" name="do" value="buy"><input type="hidden" name="key" value="<?= e($up['key']) ?>">
    <span class="cficon" aria-hidden="true"><?= $up['icon'] ?></span>
    <span class="cfinfo"><b><?= e($up['name']) ?></b> <small class="muted">×<?= (int)$up['owned'] ?></small><br><small class="cfgives"><?= e($up['gives']) ?><?= $up['mult'] > 1 ? ' · ×' . (int)$up['mult'] . ' bonus' : '' ?></small></span>
    <button class="btn" type="submit"<?= $up['can'] ? '' : ' disabled' ?> data-cost="<?= (int)$up['cost'] ?>">Buy · <?= number_format($up['cost']) ?></button>
  </form>
<?php endforeach; endforeach; ?>
</div>
<details class="fold box"><summary>😴 Nap<?= $v['yarn'] > 0 ? ' · ' . number_format($v['yarn']) . ' Yarn (×' . rtrim(rtrim(number_format(catfish_yarn_mult($v['yarn']), 2), '0'), '.') . ' Kibble)' : '' ?></summary>
  <p class="help">Napping puts your upgrades and Kibble back to zero and gives Yarn. Yarn makes all the Kibble your cat earns go further, for good, though each extra Yarn helps a little less. Longer runs give more Yarn. Your cats, Cat Book and badges stay.</p>
  <p>This run: <b id="cf-run"><?= number_format($v['run']) ?></b> Kibble earned. A Nap now gives <b id="cf-napyarn"><?= (int)$v['nap_yarn'] ?></b> Yarn.<span id="cf-napneed"<?= $v['nap_yarn'] < 1 ? '' : ' hidden' ?>> You need <?= number_format(CATFISH_NAP_BASE) ?> for your first.</span></p>
  <form method="post" id="cf-napform"<?= $v['nap_yarn'] >= 1 ? '' : ' hidden' ?>><?= csrf_field() ?><input type="hidden" name="do" value="nap"><button class="btn" type="submit">Nap</button></form>
</details>
<?php endif; ?>

<?php if ($room || !$cat): foreach ($shelter as $sc) catfish_book_add($uid, $sc['pattern'], $sc['colour'], 0); ?>
<h2>🏠 Shelter</h2>
<p class="help"><?= $adoptCost === 0 ? 'Your first cat is free.' : 'Taking another home costs ' . number_format($adoptCost) . ' Kibble.' ?> New cats arrive at the daily reset.</p>
<div class="cflist">
<?php foreach ($shelter as $s): $has = in_array($s['seed'], array_column($cats, 'seed'), true); ?>
  <form method="post" class="cfshelf">
    <?= csrf_field() ?><input type="hidden" name="do" value="adopt"><input type="hidden" name="slot" value="<?= (int)$s['slot'] ?>"><input type="hidden" name="day" value="<?= e(gmdate('Y-m-d')) ?>">
    <?= $catCard($s) ?>
    <?php if ($has): ?><small class="muted">Already yours</small>
    <?php else: ?><input class="cfname" type="text" name="name" maxlength="<?= CATFISH_NAME_MAX ?>" value="<?= e($s['name']) ?>" aria-label="Name"><button class="btn" type="submit" data-cost="<?= (int)$adoptCost ?>"<?= $v['kibble'] >= $adoptCost ? '' : ' disabled' ?>>Adopt<?= $adoptCost > 0 ? ' · ' . number_format($adoptCost) : '' ?></button><?php endif; ?>
  </form>
<?php endforeach; ?>
</div>
<?php endif; ?>

<?php if ($owned > 0): ?>
<details class="fold box"><summary>🐾 Your cats (<?= $owned ?>)</summary>
<?php foreach ($cats as $c): $on = $cat && $c['id'] === $cat['id']; ?>
  <div class="cfshelf"><?= $catCard($c) ?>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="rename"><input type="hidden" name="cat" value="<?= (int)$c['id'] ?>">
      <input class="cfname" type="text" name="name" maxlength="<?= CATFISH_NAME_MAX ?>" value="<?= e($c['name']) ?>" aria-label="Name"><button class="btn" type="submit">Rename</button></form>
    <?php if ($on): ?><small class="muted">Playing now</small>
    <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="switch"><input type="hidden" name="cat" value="<?= (int)$c['id'] ?>"><button class="btn" type="submit">Play with</button></form><?php endif; ?>
  </div>
<?php endforeach; ?>
</details>
<?php endif; ?>
<?php if ($owned > 0): $book = catfish_book($uid); $have = []; foreach ($book as $bk) $have[$bk[0] . '/' . $bk[1]] = $bk[2]; ?>
<details class="fold box"><summary>📖 Cat Book (<?= count($book) ?> of <?= count(CATFISH_TRAITS['pattern']) * count(CATFISH_TRAITS['colour']) ?>)</summary>
  <p class="help">Every coat you have seen at the shelter or taken home (🐱 = adopted). Fill the book for badges.</p>
  <div class="cfbook">
  <?php foreach (array_keys(CATFISH_TRAITS['pattern']) as $pat): ?>
    <div class="cfbrow"><b><?= e(ucfirst($pat)) ?></b>
    <?php foreach (array_keys(CATFISH_TRAITS['colour']) as $col): $st = $have[$pat . '/' . $col] ?? -1; $nm = ucfirst($col) . ' ' . $pat . ($st === 1 ? ', adopted' : ($st === 0 ? ', seen' : ', not seen yet')); ?>
      <span class="cfbcell <?= $st >= 0 ? 'got c-' . e($col) : 'none' ?>" role="img" aria-label="<?= e($nm) ?>" title="<?= e($nm) ?>"><?= $st === 1 ? '🐱' : '' ?></span>
    <?php endforeach; ?></div>
  <?php endforeach; ?>
  </div>
<?php if ($bg = catfish_badges($uid)): ?><p class="cfbadgeline"><?php foreach ($bg as [$bi, $bl2]): ?><span class="cfbadge" title="<?= e($bl2) ?>"><?= $bi ?> <?= e($bl2) ?></span> <?php endforeach; ?></p><?php endif; ?>
</details>
<?php endif; ?>
<script type="application/json" id="cf-data"><?= json_encode(['kibble' => $v['kibble'], 'kph' => $v['kph'], 'api' => url('catfish_api.php'), 'csrf' => csrf_token(), 'has' => $cat !== null], $J) ?></script>
<?php page_footer();
