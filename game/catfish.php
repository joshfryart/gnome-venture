<?php
declare(strict_types=1);
/**
 * Cat Fish (Lazy Rod): adopt a cat, a toy rod sways by itself, the cat catches fish and drops Kibble, Kibble buys upgrades. Plan: claude/plan-catfish.md.
 * Plain forms do everything (adopt, buy, switch, rename); assets/catfish.js only keeps the Kibble counter ticking and buys without a reload.
 * No inline script or style (CSP): data goes in a JSON block.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/catfish.php';
require_once __DIR__ . '/includes/jobs.php';   // job_period_left(): the same daily and weekly clocks as the rest of the game
$u = require_login();
if (!catfish_open()) { flash('Cat Fish is coming soon.', 'err'); redirect('games.php'); }
if (!empty($u['guest'])) { flash('Guests can look around, but making your own gnome is needed to keep a cat.', 'err'); redirect('games.php'); }
if (!catfish_ensure()) { flash('Cat Fish could not start. Try again soon.', 'err'); redirect('games.php'); }
$uid = (int)$u['id'];
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $r = [false, 'Unknown action.'];
    if ($do === 'adopt') $r = catfish_adopt($uid, (int)($_POST['slot'] ?? -1), (string)($_POST['name'] ?? ''), '', (int)($_POST['seed'] ?? 0));
    elseif ($do === 'buy') $r = catfish_buy($uid, (string)($_POST['key'] ?? ''));
    elseif ($do === 'show') $r = catfish_show_enter($uid, (int)($_POST['cat'] ?? 0));
    elseif ($do === 'reroll') $r = catfish_reroll($uid, (int)($_POST['slot'] ?? -1));
    elseif ($do === 'bigger') $r = catfish_buy_slot($uid);
    elseif ($do === 'rare') $r = catfish_buy_rare($uid);
    elseif ($do === 'nap') $r = catfish_nap($uid);
    elseif ($do === 'switch') $r = catfish_switch($uid, (int)($_POST['cat'] ?? 0));
    elseif ($do === 'rename') $r = catfish_rename($uid, (int)($_POST['cat'] ?? 0), (string)($_POST['name'] ?? ''));
    flash($r[1], $r[0] ? 'ok' : 'err');
    redirect('catfish.php');
}
$newRibbon = catfish_show_settle($uid);   // a finished week's entry gets judged before anything is shown
if ($newRibbon) { [$ri, $rl] = catfish_ribbon_face((string)$newRibbon['tier']); flash($ri . ' ' . $rl . ' for ' . $newRibbon['cat_name'] . ' (' . $newRibbon['theme'] . ')!', 'ok'); }
$v = catfish_view($uid);
$st = catfish_state($uid); $meta = $st['meta'];
$cats = catfish_cats($uid);
$cat = $v['cat'];
$shelter = catfish_shelter_now($uid, $meta);
$rolls = array_replace([0, 0, 0], ($meta['roll']['day'] ?? '') === catfish_today() ? (array)($meta['roll']['n'] ?? []) : []);
$slots = catfish_slots($uid, $st); $owned = count($cats); $room = $owned < $slots;
$adoptCost = catfish_adopt_cost($owned);
$ownedUp = array_column($v['ups'], 'owned', 'key');   // upgrade key => level, for the rod's fish and the room's overlays
$J = JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT;
/** One cat (layered art when the PNGs exist, else a tinted placeholder block) plus its trait line. */
$catCard = function (array $c, bool $sprite = true): string {
    $traits = ucfirst($c['colour']) . ' ' . $c['pattern'] . ', ' . $c['eyes'] . ' eyes' . ($c['ears'] === 'folded' ? ', folded ears' : '') . ($c['tail'] === 'bobtail' ? ', bobtail' : '');
    return ($sprite ? catfish_cat_html($c, 64, 'idleA') : '')
        . '<span class="cfinfo"><b>' . e($c['name']) . '</b> <span class="cfrar r-' . e($c['rarity']) . '">' . e(ucfirst($c['rarity'])) . '</span><br>'
        . '<small>' . e($traits) . '</small><br><small class="muted">' . e(ucfirst($c['mood'])) . ($c['quirk'] !== '' ? ' · ' . e($c['quirk']) : '') . '</small></span>';
};
page_header('Cat Fish');
?>
<div class="cfpage">
<?php if (catfish_art_has('cf-banner.png')): ?><h1 class="cfbanner"><?= catfish_img('banner', '', 'Cat Fish', 480, 120) ?></h1>
<?php else: ?><h1>🐱 Cat Fish</h1>
<?php endif; ?>
<?php if (!$cat): ?>
<p class="help">Pick a cat to take home. Your first one is free. The shelter shows new cats every day.</p>
<?php else: ?>
<?php $stage = catfish_stage_html($cats, $cat, $ownedUp, $v['naps'] > 0 && $v['run'] === 0);   // '' without cf-room.png: the old rod box, cat card and room below ?>
<?php if ($stage !== ''): ?>
<?= $stage ?>
<div class="cfscene cfcard box">
  <div class="cfmain"><div class="cfhold"><?= $catCard($cat, false) ?></div>
<?php else: ?>
<div class="cfscene box">
  <?= catfish_rod_html($ownedUp, $cat) ?>
  <div class="cfmain"><div class="cfhold"><?= $catCard($cat) ?></div>
<?php endif; ?>
    <p class="cfcount"><?= catfish_ico('ico-kibble') ?><b id="cf-kibble"><?= number_format($v['kibble']) ?></b> Kibble <small class="muted">· <span id="cf-kph"><?= e((string)$v['kph']) ?></span> an hour</small></p>
    <p class="help">Your cat keeps catching fish while you are away (half speed, up to <?= (int)(catfish_offline_cap($cat) / 3600) ?> hours).<?= $v['gained'] > 0 ? ' While you were away: +' . number_format($v['gained']) . ' Kibble.' : '' ?></p></div>
</div>
<?= $stage === '' ? catfish_room_html($cats, $ownedUp) : '' ?>
<h2>Upgrades</h2>
<p id="cf-msg" role="status"></p>
<div class="cfups" id="cf-ups">
<?php foreach (CATFISH_BRANCHES as $bk => $bl): ?>
  <h3><?= e($bl) ?></h3>
<?php foreach ($v['ups'] as $up): if ($up['branch'] !== $bk) continue; ?>
  <form method="post" class="cfup" data-key="<?= e($up['key']) ?>">
    <?= csrf_field() ?><input type="hidden" name="do" value="buy"><input type="hidden" name="key" value="<?= e($up['key']) ?>">
    <span class="cficon"><?= catfish_img('up-' . $up['key'], $up['icon'], '', 48) ?></span>
    <span class="cfinfo"><b><?= e($up['name']) ?></b> <small class="muted">×<?= (int)$up['owned'] ?></small><br><small class="cfgives"><?= e($up['gives']) ?><?= $up['mult'] > 1 ? ' · ×' . (int)$up['mult'] . ' bonus' : '' ?></small></span>
    <button class="btn" type="submit"<?= $up['can'] ? '' : ' disabled' ?> data-cost="<?= (int)$up['cost'] ?>">Buy · <?= number_format($up['cost']) ?></button>
  </form>
<?php endforeach; endforeach; ?>
</div>
<details class="fold box"><summary><?= catfish_ico('ico-yarn', 24) ?>😴 Nap<?= $v['yarn'] > 0 ? ' · ' . number_format($v['yarn']) . ' Yarn (×' . rtrim(rtrim(number_format(catfish_yarn_mult($v['yarn']), 2), '0'), '.') . ' Kibble)' : '' ?></summary>
  <p class="help">Napping puts your upgrades and Kibble back to zero and gives Yarn. Yarn makes all the Kibble your cat earns go further, for good, though each extra Yarn helps a little less. Longer runs give more Yarn. Your cats, Cat Book and badges stay.</p>
  <p>This run: <b id="cf-run"><?= number_format($v['run']) ?></b> Kibble earned. A Nap now gives <b id="cf-napyarn"><?= (int)$v['nap_yarn'] ?></b> Yarn.<span id="cf-napneed"<?= $v['nap_yarn'] < 1 ? '' : ' hidden' ?>> You need <?= number_format(CATFISH_NAP_BASE) ?> for your first.</span></p>
  <form method="post" id="cf-napform"<?= $v['nap_yarn'] >= 1 ? '' : ' hidden' ?>><?= csrf_field() ?><input type="hidden" name="do" value="nap"><button class="btn" type="submit">Nap</button></form>
</details>
<?php endif; ?>

<?php if ($room || !$cat): foreach ($shelter as $sc) catfish_book_add($uid, $sc['pattern'], $sc['colour'], 0); ?>
<h2>🏠 Shelter</h2>
<p class="help"><?= $adoptCost === 0 ? 'Your first cat is free.' : 'Taking another home costs ' . number_format($adoptCost) . ' Kibble.' ?> New cats arrive in <?= nice_time(job_period_left('daily')) ?>.</p>
<div class="cflist">
<?php foreach ($shelter as $s): $has = in_array($s['seed'], array_column($cats, 'seed'), true); ?>
  <form method="post" class="cfshelf">
    <?= csrf_field() ?><input type="hidden" name="do" value="adopt"><input type="hidden" name="slot" value="<?= (int)$s['slot'] ?>"><input type="hidden" name="seed" value="<?= (int)$s['seed'] ?>">
    <?= $catCard($s) ?>
    <?php if ($has): ?><small class="muted">Already yours</small>
    <?php else: ?><input class="cfname" type="text" name="name" maxlength="<?= CATFISH_NAME_MAX ?>" value="<?= e($s['name']) ?>" aria-label="Name"><button class="btn" type="submit" data-cost="<?= (int)$adoptCost ?>"<?= $v['kibble'] >= $adoptCost ? '' : ' disabled' ?>>Adopt<?= $adoptCost > 0 ? ' · ' . number_format($adoptCost) : '' ?></button><?php endif; ?>
  </form>
  <?php if (!$has && $v['spend'] >= CATFISH_REROLL_COST && $rolls[$s['slot']] < CATFISH_REROLL_MAX): ?>
  <form method="post" class="cfreroll"><?= csrf_field() ?><input type="hidden" name="do" value="reroll"><input type="hidden" name="slot" value="<?= (int)$s['slot'] ?>"><button class="btn" type="submit" aria-label="Swap <?= e($s['name']) ?> for another cat, <?= CATFISH_REROLL_COST ?> Yarn">Swap this cat · <?= CATFISH_REROLL_COST ?> Yarn</button> <small class="muted"><?= CATFISH_REROLL_MAX - $rolls[$s['slot']] ?> left today</small></form>
  <?php endif; ?>
<?php endforeach; ?>
</div>
<?php endif; ?>

<?php if ($cat): catfish_claim_petals($uid); $st = catfish_state($uid); $meta = $st['meta'];   // milestones reached since the last visit, after the shelter cats above are in the Book
$extra = (int)($meta['extra'] ?? 0); $rareLvl = (int)($meta['rare'] ?? 0); ?>
<details class="fold box"><summary>🏡 Home and shelter · <?= catfish_ico('ico-yarn', 24) ?><?= number_format($v['spend']) ?> Yarn to spend</summary>
  <p class="help">Yarn you spend here never lowers your Kibble bonus. That follows all the Yarn you have earned.</p>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="bigger">
    <span class="cficon" aria-hidden="true">🏡</span><span class="cfinfo"><b>Bigger home</b> <small class="muted"><?= $slots ?> of <?= CATFISH_MAX_CATS ?> places</small><br><small>Room for one more cat.</small></span>
    <?php if ($extra < count(CATFISH_SLOT_COSTS)): ?><button class="btn" type="submit"<?= $v['spend'] >= CATFISH_SLOT_COSTS[$extra] ? '' : ' disabled' ?>><?= CATFISH_SLOT_COSTS[$extra] ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="rare">
    <span class="cficon" aria-hidden="true">🔭</span><span class="cfinfo"><b>Rare Shelter</b> <small class="muted">level <?= $rareLvl ?> of <?= count(CATFISH_RARE_COSTS) ?></small><br><small><?= $rareLvl === 0 ? 'Each spot shows one cat.' : 'Each spot shows the best of ' . ($rareLvl + 1) . ' cats.' ?> <?= $rareLvl < count(CATFISH_RARE_COSTS) ? 'Next level: best of ' . ($rareLvl + 2) . '.' : '' ?></small></span>
    <?php if ($rareLvl < count(CATFISH_RARE_COSTS)): ?><button class="btn" type="submit"<?= $v['spend'] >= CATFISH_RARE_COSTS[$rareLvl] ? '' : ' disabled' ?>><?= CATFISH_RARE_COSTS[$rareLvl] ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
</details>
<?php
$reached = catfish_milestones_reached($uid, $st); $done = (array)($meta['ms'] ?? []);
$week = catfish_week(); $paidWk = ($meta['pw']['week'] ?? '') === $week ? (int)$meta['pw']['paid'] : 0; $capWk = (int)setting('catfish_petal_cap');
if ($capWk > 0): ?>
<details class="fold box"><summary>🌸 Milestones · <?= number_format($paidWk) ?> of <?= number_format($capWk) ?> Petals this week</summary>
  <p class="help">Each milestone pays Petals once. At most <?= number_format($capWk) ?> a week, so a milestone that does not fit waits for next week.</p>
  <ul class="cfms">
  <?php foreach (CATFISH_MILESTONES_PETALS as $mk => [$ml, $mb]): $state = in_array($mk, $done, true) ? '✅ paid' : (!empty($reached[$mk]) ? '⏳ next week' : 'not yet'); ?>
    <li><?= e($ml) ?> · <?= number_format(game_petals($mb)) ?> Petals <small class="muted">· <?= e($state) ?></small></li>
  <?php endforeach; ?>
  </ul>
</details>
<?php endif; endif; ?>

<?php if ($owned > 0): $week = catfish_show_week(); $theme = catfish_show_theme($week); $entry = $meta['show'] ?? null; $entered = is_array($entry) && ($entry['week'] ?? '') === $week ? $entry : null; $myRibbons = catfish_ribbons($uid, 6);
?>
<details class="fold box"><summary>🎀 Cat Show · <?= e($theme['label']) ?></summary>
  <p class="help">A new show every week (Monday to Sunday, <?= e(setting('game_timezone') ?: 'America/Halifax') ?> time). This one is judged in <?= nice_time(job_period_left('weekly')) ?>. Enter one cat. Three judges look at it when the week ends; a cat that fits the theme and a rarer cat score higher. Kibble and Yarn do not count. Prizes are ribbons on your profile.</p>
  <?php if ($entered): foreach ($cats as $c) if ($c['id'] === (int)$entered['cat']): ?><p>Entered: <b><?= e($c['name']) ?></b><?= ($c[$theme['trait']] ?? '') === $theme['value'] ? ' (fits the theme!)' : '' ?></p><?php endif; endif; ?>
  <form method="post" class="cfshowform"><?= csrf_field() ?><input type="hidden" name="do" value="show">
    <label for="cf-showcat">Cat</label>
    <select id="cf-showcat" name="cat"><?php foreach ($cats as $c): ?><option value="<?= (int)$c['id'] ?>"<?= $entered && (int)$entered['cat'] === $c['id'] ? ' selected' : '' ?>><?= e($c['name']) ?> (<?= e($c['colour'] . ' ' . $c['pattern']) ?>)</option><?php endforeach; ?></select>
    <button class="btn" type="submit"><?= $entered ? 'Swap entry' : 'Enter' ?></button></form>
  <?php if ($myRibbons): ?><ul class="cfms"><?php foreach ($myRibbons as $rb): [$ri, $rl] = catfish_ribbon_face((string)$rb['tier']); ?><li><?= catfish_img('ribbon-' . $rb['tier'], $ri, '', 24) ?> <?= e($rl) ?> · <?= e($rb['cat_name']) ?> <small class="muted">· <?= e($rb['theme']) ?> (<?= e($rb['week']) ?>)</small></li><?php endforeach; ?></ul><?php endif; ?>
</details>
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
  <p class="help">Every coat you have seen at the shelter or taken home (<?= catfish_art_has('cf-bookhead-unknown.png') ? 'bright = adopted, faded = only seen' : '🐱 = adopted' ?>). Fill the book for badges.</p>
  <div class="cfbook">
  <?php foreach (array_keys(CATFISH_TRAITS['pattern']) as $pat): ?>
    <div class="cfbrow"><b><?= e(ucfirst($pat)) ?></b>
    <?php foreach (array_keys(CATFISH_TRAITS['colour']) as $col): $st = $have[$pat . '/' . $col] ?? -1; $nm = ucfirst($col) . ' ' . $pat . ($st === 1 ? ', adopted' : ($st === 0 ? ', seen' : ', not seen yet')); ?>
      <?= catfish_book_cell($col, $st, $nm) ?>
    <?php endforeach; ?></div>
  <?php endforeach; ?>
  </div>
<?php if ($bg = catfish_badges($uid)): ?><p class="cfbadgeline"><?php foreach ($bg as $bk2 => [$bi, $bl2]): ?><span class="cfbadge" title="<?= e($bl2) ?>"><?= catfish_img('badge-' . $bk2, $bi, '', 24) ?> <?= e($bl2) ?></span> <?php endforeach; ?></p><?php endif; ?>
</details>
<?php endif; ?>
</div>
<script type="application/json" id="cf-data"><?= json_encode(['kibble' => $v['kibble'], 'kph' => $v['kph'], 'api' => url('catfish_api.php'), 'csrf' => csrf_token(), 'has' => $cat !== null], $J) ?></script>
<?php page_footer();
