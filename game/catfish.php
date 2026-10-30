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
    elseif ($do === 'bulk') $r = catfish_buy_bulk($uid);
    elseif ($do === 'away') $r = catfish_buy_away($uid);
    elseif ($do === 'title') $r = catfish_buy_title($uid, (string)($_POST['key'] ?? ''));
    elseif ($do === 'show') $r = catfish_show_enter($uid, (int)($_POST['cat'] ?? 0), (int)($_POST['slot'] ?? 1));
    elseif ($do === 'hold') $r = catfish_hold($uid, (int)($_POST['slot'] ?? -1));
    elseif ($do === 'stake') $r = catfish_stake($uid, (string)($_POST['pick'] ?? ''));
    elseif ($do === 'show2') $r = catfish_buy_show2($uid);
    elseif ($do === 'buddyunlock') $r = catfish_buy_buddy($uid);
    elseif ($do === 'buddy') $r = catfish_set_buddy($uid, (int)($_POST['cat'] ?? 0));
    elseif ($do === 'keep') $r = catfish_buy_keep($uid);
    elseif ($do === 'tune') $r = catfish_tune($uid, (string)($_POST['branch'] ?? ''));
    elseif ($do === 'catnip') $r = catfish_catnip($uid);
    elseif ($do === 'treat') $r = catfish_treat($uid, (string)($_POST['mood'] ?? ''));
    elseif ($do === 'bio') $r = catfish_set_bio($uid, (int)($_POST['cat'] ?? 0), (string)($_POST['bio'] ?? ''));
    elseif ($do === 'collar') $r = catfish_collar($uid, (int)($_POST['cat'] ?? 0), (string)($_POST['key'] ?? ''));
    elseif ($do === 'season') $r = catfish_buy_season($uid, (string)($_POST['code'] ?? ''));
    elseif ($do === 'bunting') $r = catfish_hang_bunting($uid);
    elseif ($do === 'scarfbuy') $r = catfish_buy_scarf($uid);
    elseif ($do === 'scarfset') $r = catfish_set_scarf($uid, (string)($_POST['key'] ?? ''));
    elseif ($do === 'ballbuy') $r = catfish_buy_ball($uid, (string)($_POST['key'] ?? ''));
    elseif ($do === 'ballset') $r = catfish_set_ball($uid, (string)($_POST['key'] ?? ''));
    elseif ($do === 'reroll') $r = catfish_reroll($uid, (int)($_POST['slot'] ?? -1));
    elseif ($do === 'bigger') $r = catfish_buy_slot($uid);
    elseif ($do === 'rare') $r = catfish_buy_rare($uid);
    elseif ($do === 'petslot') $r = catfish_pet_slot($uid, (int)($_POST['slot'] ?? 0), (string)($_POST['item'] ?? ''));
    elseif ($do === 'petuse') $r = array_slice(catfish_pet_use($uid, (int)($_POST['slot'] ?? 0), ['shelter' => (string)($_POST['shelter'] ?? '')]), 0, 2);
    elseif ($do === 'petunlock') $r = catfish_pet_unlock($uid, (int)($_POST['slot'] ?? 0));
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
        . '<small>' . e($traits) . '</small><br><small class="muted">' . e(ucfirst($c['mood'])) . (!empty($c['mood2']) ? ' + ' . e($c['mood2']) : '') . ($c['quirk'] !== '' ? ' · ' . e($c['quirk']) : '') . '</small>' . (($c['bio'] ?? '') !== '' ? '<br><small class="cfbio">“' . e($c['bio']) . '”</small>' : '') . '</span>';
};
page_header('Cat Fish');
?>
<div class="cfpage<?= !empty($meta['ball']) && isset(CATFISH_BALLS[$meta['ball']]) ? ' cfball-' . e($meta['ball']) : '' ?>">
<?php if (catfish_art_has('cf-banner.png')): ?><h1 class="cfbanner"><?= catfish_img('banner', '', 'Cat Fish', 480, 120) ?></h1>
<?php else: ?><h1>🐱 Cat Fish</h1>
<?php endif; ?>
<?php if (!$cat): ?>
<p class="help">Pick a cat to take home. Your first one is free. The shelter shows new cats every day.</p>
<?php else: ?>
<?php $petScene = catfish_pet_scene($uid); $stage = catfish_stage_html($cats, $cat, $ownedUp, $v['naps'] > 0 && $v['run'] === 0, (int)$v['play']['ever'] === 0, $petScene); $sceneKey = catfish_scene_key($cats, $cat, $ownedUp, $petScene);   // '' without cf-room.png: the old rod box, cat card and room below ?>
<?php if ($stage !== ''): ?>
<?= $stage ?>
<div class="cfscene cfcard box">
  <div class="cfmain"><div class="cfhold"><?= $catCard($cat, false) ?></div>
<?php else: ?>
<div class="cfscene box">
  <?= catfish_rod_html($ownedUp, $cat) ?>
  <div class="cfmain"><div class="cfhold"><?= $catCard($cat) ?></div>
<?php endif; ?>
    <p class="cfcount"><?= catfish_ico('ico-kibble') ?><b id="cf-kibble"><?= number_format($v['kibble']) ?></b><span id="cf-spend" class="cfspend" aria-hidden="true"></span> Kibble <small class="muted">· <span id="cf-kph"><?= e((string)$v['kph']) ?></span> an hour</small></p>
    <p class="help">Your cat keeps catching fish while you are away (half speed, up to <?= rtrim(rtrim(number_format(catfish_offline_cap($cat, (int)($meta['away'] ?? 0), 60 * catfish_pet_bonus($uid)['away_min']) / 3600, 1), '0'), '.') ?> hours).<?= $v['gained'] > 0 ? ' While you were away: +' . number_format($v['gained']) . ' Kibble.' : '' ?></p></div>
</div>
<?= $stage === '' ? catfish_room_html($cats, $ownedUp) : '' ?>
<h2>Upgrades</h2>
<p id="cf-msg" role="status"></p>
<?php if (!empty($meta['bulk'])): ?><div class="cfbulk" id="cf-bulk" role="group" aria-label="Buy amount"><button type="button" data-n="1" aria-pressed="true">Buy ×1</button><button type="button" data-n="10" aria-pressed="false">Buy ×10</button></div>
<?php endif; ?>
<div class="cfupwrap" id="cf-ups">
<?php foreach (CATFISH_BRANCHES as $bk => $bl): ?>
  <section class="cfbranch" data-branch="<?= e($bk) ?>" data-label="<?= e($bl) ?>">
  <h3><?= e($bl) ?></h3>
  <div class="cfups">
<?php foreach ($v['ups'] as $up): if ($up['branch'] !== $bk) continue; ?>
  <form method="post" class="cfup" data-key="<?= e($up['key']) ?>">
    <?= csrf_field() ?><input type="hidden" name="do" value="buy"><input type="hidden" name="key" value="<?= e($up['key']) ?>">
    <span class="cficon"><?= catfish_img('up-' . $up['key'], $up['icon'], '', 48) ?></span>
    <span class="cfinfo"><b><?= e($up['name']) ?></b> <small class="muted">×<?= (int)$up['owned'] ?></small><br><small class="cfgives"><?= e($up['gives']) ?><?= $up['mult'] > 1 ? ' · ×' . (int)$up['mult'] . ' bonus' : '' ?></small></span>
    <button class="btn cfcost" type="submit"<?= $up['can'] ? '' : ' disabled' ?> data-cost="<?= (int)$up['cost'] ?>" data-c1="<?= (int)$up['cost'] ?>" data-c10="<?= (int)$up['cost10'] ?>" aria-label="Buy <?= e($up['name']) ?> for <?= number_format($up['cost']) ?> Kibble"><?= number_format($up['cost']) ?></button>
  </form>
<?php endforeach; ?>
  </div>
  </section>
<?php endforeach; ?>
</div>
<?php endif; ?>

<?php if ($room || !$cat): foreach ($shelter as $sc) catfish_book_add($uid, $sc['pattern'], $sc['colour'], 0); ?>
<details class="fold box cfshelter"<?= $cat ? '' : ' open' ?>><summary>🏠 Shelter <span class="cfsav"><?php foreach ($shelter as $s) echo catfish_cat_html($s, 64, 'idleA'); ?></span><small class="muted"> · <?= $adoptCost === 0 ? 'first cat free' : number_format($adoptCost) . ' Kibble' ?> · new in <?= nice_time(job_period_left('daily')) ?></small></summary>
<p class="help"><?= $adoptCost === 0 ? 'Your first cat is free.' : 'Taking another home costs ' . number_format($adoptCost) . ' Kibble.' ?> New cats arrive in <?= nice_time(job_period_left('daily')) ?>.</p>
<div class="cflist">
<?php foreach ($shelter as $s): $has = in_array($s['seed'], array_column($cats, 'seed'), true); ?>
  <form method="post" class="cfshelf">
    <?= csrf_field() ?><input type="hidden" name="do" value="adopt"><input type="hidden" name="slot" value="<?= (int)$s['slot'] ?>"><input type="hidden" name="seed" value="<?= (int)$s['seed'] ?>">
    <?= $catCard($s) ?>
    <?php if ($has): ?><small class="muted">Already yours</small>
    <?php else: ?><?= !empty($s['held']) ? '<small class="muted">Held for you</small>' : '' ?><input class="cfname" type="text" name="name" maxlength="<?= CATFISH_NAME_MAX ?>" value="<?= e($s['name']) ?>" aria-label="Name"><button class="btn" type="submit" data-cost="<?= (int)$adoptCost ?>"<?= $v['kibble'] >= $adoptCost ? '' : ' disabled' ?>>Adopt<?= $adoptCost > 0 ? ' · ' . number_format($adoptCost) : '' ?></button><?php endif; ?>
  </form>
  <?php if (!$has && empty($s['held']) && $v['spend'] >= CATFISH_REROLL_COST && $rolls[$s['slot']] < CATFISH_REROLL_MAX): ?>
  <form method="post" class="cfreroll"><?= csrf_field() ?><input type="hidden" name="do" value="reroll"><input type="hidden" name="slot" value="<?= (int)$s['slot'] ?>"><button class="btn" type="submit" aria-label="Swap <?= e($s['name']) ?> for another cat, <?= CATFISH_REROLL_COST ?> Yarn">Swap this cat · <?= CATFISH_REROLL_COST ?> Yarn</button> <small class="muted"><?= CATFISH_REROLL_MAX - $rolls[$s['slot']] ?> left today</small></form>
  <?php endif; ?>
  <?php if (!$has && $cat && $v['spend'] >= CATFISH_HOLD_COST && ($meta['hold']['for'] ?? '') !== catfish_tomorrow()): ?>
  <form method="post" class="cfreroll"><?= csrf_field() ?><input type="hidden" name="do" value="hold"><input type="hidden" name="slot" value="<?= (int)$s['slot'] ?>"><button class="btn" type="submit" aria-label="Hold <?= e($s['name']) ?> for tomorrow, <?= CATFISH_HOLD_COST ?> Yarn">Hold for tomorrow · <?= CATFISH_HOLD_COST ?> Yarn</button></form>
  <?php endif; ?>
<?php endforeach; ?>
<?php if ($cat && ($meta['hold']['for'] ?? '') === catfish_tomorrow()): ?><p class="help"><?= catfish_img('yi-hold', '', '', 24) ?> Holding a cat for tomorrow.</p><?php endif; ?>
<?php if ($cat && ($meta['stake']['for'] ?? '') === catfish_today()): ?><p class="help">Stakeout today: looking for <?= e((string)$meta['stake']['value']) ?> cats.</p><?php endif; ?>
</div>
</details>
<?php endif; ?>

<?php if ($cat): catfish_claim_petals($uid); $st = catfish_state($uid); $meta = $st['meta'];   // milestones reached since the last visit, after the shelter cats above are in the Book
$extra = (int)($meta['extra'] ?? 0); $rareLvl = (int)($meta['rare'] ?? 0);
$awayLvl = (int)($meta['away'] ?? 0); $bulk = !empty($meta['bulk']); $myTitles = (array)($meta['titles'] ?? []); $sp = $v['spend'];
$yarnReady = (int)(($extra < count(CATFISH_SLOT_COSTS) && $sp >= CATFISH_SLOT_COSTS[$extra]) + ($rareLvl < count(CATFISH_RARE_COSTS) && $sp >= CATFISH_RARE_COSTS[$rareLvl])
    + (!$bulk && $sp >= CATFISH_BULK_COST) + (empty($meta['buddyon']) && $sp >= CATFISH_BUDDY_COST) + (empty($meta['show2on']) && $sp >= CATFISH_SHOW2_COST) + ((int)($meta['keepsake'] ?? 0) < count(CATFISH_KEEP_COSTS) && $sp >= CATFISH_KEEP_COSTS[(int)($meta['keepsake'] ?? 0)]) + ($awayLvl < count(CATFISH_AWAY_COSTS) && $sp >= CATFISH_AWAY_COSTS[$awayLvl]));
foreach (CATFISH_TITLES as $tk => [, $tc]) if (!in_array($tk, $myTitles, true) && $sp >= $tc) $yarnReady++; ?>
<div class="cfhubwrap" id="cf-hub">
<section class="cfpanel box" id="cf-p-nap" data-icon="😴" data-title="Nap" data-status="<?= $v['yarn'] > 0 ? number_format($v['yarn']) . ' Yarn' : 'Start over' ?>" data-badge="<?= $v['nap_yarn'] >= 1 ? 1 : 0 ?>"><h3><?= catfish_ico('ico-yarn', 24) ?>😴 Nap</h3>
<?php if ($v['yarn'] > 0): ?><p><b><?= number_format($v['yarn']) ?> Yarn</b> (×<?= rtrim(rtrim(number_format(catfish_yarn_mult($v['yarn']), 2), '0'), '.') ?> Kibble)</p><?php endif; ?>
  <p class="help">Napping puts your upgrades and Kibble back to zero and gives Yarn. Yarn makes all the Kibble your cat earns go further, for good, though each extra Yarn helps a little less. Longer runs give more Yarn. Your cats, Cat Book and badges stay.</p>
  <p>This run: <b id="cf-run"><?= number_format($v['run']) ?></b> Kibble earned. A Nap now gives <b id="cf-napyarn"><?= (int)$v['nap_yarn'] ?></b> Yarn.<span id="cf-napneed"<?= $v['nap_yarn'] < 1 ? '' : ' hidden' ?>> You need <?= number_format(CATFISH_NAP_BASE) ?> for your first.</span></p>
  <form method="post" id="cf-napform"<?= $v['nap_yarn'] >= 1 ? '' : ' hidden' ?>><?= csrf_field() ?><input type="hidden" name="do" value="nap"><button class="btn" type="submit">Nap</button></form>
</section>
<section class="cfpanel box" id="cf-p-yarn" data-icon="🧶" data-title="Yarn" data-status="<?= number_format($v['spend']) ?> to spend" data-badge="<?= $yarnReady ?>"><h3>🧶 Yarn · <?= catfish_ico('ico-yarn', 24) ?><?= number_format($v['spend']) ?> to spend</h3>

  <p class="help">Yarn you spend here never lowers your Kibble bonus. That follows all the Yarn you have earned.</p>
<details class="cfgroup" open><summary><b>🏡 Home and cats</b></summary>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="bigger">
    <span class="cficon" aria-hidden="true">🏡</span><span class="cfinfo"><b>Bigger home</b> <small class="muted"><?= $slots ?> of <?= CATFISH_MAX_CATS ?> places</small><br><small>Room for one more cat.</small></span>
    <?php if ($extra < count(CATFISH_SLOT_COSTS)): ?><button class="btn" type="submit"<?= $v['spend'] >= CATFISH_SLOT_COSTS[$extra] ? '' : ' disabled' ?>><?= CATFISH_SLOT_COSTS[$extra] ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="rare">
    <span class="cficon" aria-hidden="true">🔭</span><span class="cfinfo"><b>Rare Shelter</b> <small class="muted">level <?= $rareLvl ?> of <?= count(CATFISH_RARE_COSTS) ?></small><br><small><?= $rareLvl === 0 ? 'Each spot shows one cat.' : 'Each spot shows the best of ' . ($rareLvl + 1) . ' cats.' ?> <?= $rareLvl < count(CATFISH_RARE_COSTS) ? 'Next level: best of ' . ($rareLvl + 2) . '.' : '' ?></small></span>
    <?php if ($rareLvl < count(CATFISH_RARE_COSTS)): ?><button class="btn" type="submit"<?= $v['spend'] >= CATFISH_RARE_COSTS[$rareLvl] ? '' : ' disabled' ?>><?= CATFISH_RARE_COSTS[$rareLvl] ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="stake">
    <span class="cficon"><?= catfish_img('yi-stake', '🔭', '', 48) ?></span><span class="cfinfo"><b>Stakeout</b> <small class="muted"><?= CATFISH_STAKE_COST ?> Yarn a day</small><br><small><?= ($meta['stake']['for'] ?? '') === catfish_tomorrow() ? 'Set for tomorrow: ' . e((string)$meta['stake']['value']) . '.' : 'Tomorrow the shelter looks harder for the coat you pick.' ?></small>
      <select name="pick" aria-label="Pattern or colour"><?php foreach (['pattern', 'colour'] as $tr): ?><optgroup label="<?= e(ucfirst($tr)) ?>"><?php foreach (array_keys(CATFISH_TRAITS[$tr]) as $tv): ?><option value="<?= e($tr . ':' . $tv) ?>"><?= e(ucfirst($tv)) ?></option><?php endforeach; ?></optgroup><?php endforeach; ?></select></span>
    <button class="btn" type="submit"<?= $sp >= CATFISH_STAKE_COST && ($meta['stake']['for'] ?? '') !== catfish_tomorrow() ? '' : ' disabled' ?>><?= CATFISH_STAKE_COST ?> Yarn</button></form>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="show2">
    <span class="cficon"><?= catfish_img('yi-show2', '🎀', '', 48) ?></span><span class="cfinfo"><b>Second show entry</b><br><small>Enter two cats in the Cat Show. The better result wins the week's ribbon.</small></span>
    <?php if (empty($meta['show2on'])): ?><button class="btn" type="submit"<?= $sp >= CATFISH_SHOW2_COST ? '' : ' disabled' ?>><?= CATFISH_SHOW2_COST ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="buddyunlock">
    <span class="cficon"><?= catfish_img('yi-buddy', '🐾', '', 48) ?></span><span class="cfinfo"><b>Buddy cat</b><br><small>A second cat keeps the playing cat company: +<?= (int)(CATFISH_BUDDY_PCT * 100) ?>% Kibble. Choose it under Your cats.</small></span>
    <?php if (empty($meta['buddyon'])): ?><button class="btn" type="submit"<?= $sp >= CATFISH_BUDDY_COST ? '' : ' disabled' ?>><?= CATFISH_BUDDY_COST ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
</details>
<details class="cfgroup"><summary><b>🎮 Play and runs</b></summary>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="bulk">
    <span class="cficon" aria-hidden="true">🔟</span><span class="cfinfo"><b>Buy ×10</b><br><small>Buy ten levels of an upgrade at once.</small></span>
    <?php if (!$bulk): ?><button class="btn" type="submit"<?= $sp >= CATFISH_BULK_COST ? '' : ' disabled' ?>><?= CATFISH_BULK_COST ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="away">
    <span class="cficon" aria-hidden="true">🌙</span><span class="cfinfo"><b>Longer naps away</b> <small class="muted">level <?= $awayLvl ?> of <?= count(CATFISH_AWAY_COSTS) ?></small><br><small>Your cat fishes up to <?= 8 + $awayLvl ?> hours while you are away. Each level adds an hour.</small></span>
    <?php if ($awayLvl < count(CATFISH_AWAY_COSTS)): ?><button class="btn" type="submit"<?= $sp >= CATFISH_AWAY_COSTS[$awayLvl] ? '' : ' disabled' ?>><?= CATFISH_AWAY_COSTS[$awayLvl] ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="keep">
    <span class="cficon"><?= catfish_img('yi-keepsake', '🧺', '', 48) ?></span><span class="cfinfo"><b>Keepsake</b> <small class="muted">level <?= (int)($meta['keepsake'] ?? 0) ?> of <?= count(CATFISH_KEEP_COSTS) ?></small><br><small>A Nap keeps <?= max(1, (int)($meta['keepsake'] ?? 0)) ?> level<?= (int)($meta['keepsake'] ?? 0) > 1 ? 's' : '' ?> of Plushie fish, Longer string, Sunbeam and Fancy bowl.</small></span>
    <?php if ((int)($meta['keepsake'] ?? 0) < count(CATFISH_KEEP_COSTS)): ?><button class="btn" type="submit"<?= $sp >= CATFISH_KEEP_COSTS[(int)($meta['keepsake'] ?? 0)] ? '' : ' disabled' ?>><?= CATFISH_KEEP_COSTS[(int)($meta['keepsake'] ?? 0)] ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
  <?php $tunedNow = isset($meta['tune']['branch']) && (int)($meta['tune']['naps'] ?? -1) === (int)$st['naps']; $cnLeft = catfish_catnip_left($meta, time()); $treatDone = ($meta['treat']['day'] ?? '') === catfish_today(); ?>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="tune">
    <span class="cficon"><?= catfish_img('yi-tune', '🔧', '', 48) ?></span><span class="cfinfo"><b>Rod Tune-up</b> <small class="muted"><?= CATFISH_TUNE_COST ?> Yarn a run</small><br><small><?= $tunedNow ? 'Tuned this run: ' . e(CATFISH_BRANCHES[$meta['tune']['branch']] ?? '') . '.' : 'Pick a branch. Its bonuses double at ' . implode(', ', CATFISH_MILESTONES_TUNED) . ' owned instead of ' . implode(', ', CATFISH_MILESTONES) . ', until your next Nap.' ?></small>
      <select name="branch" aria-label="Branch"><?php foreach (CATFISH_BRANCHES as $bk2 => $bl2): ?><option value="<?= e($bk2) ?>"><?= e($bl2) ?></option><?php endforeach; ?></select></span>
    <button class="btn" type="submit"<?= !$tunedNow && $sp >= CATFISH_TUNE_COST ? '' : ' disabled' ?>><?= CATFISH_TUNE_COST ?> Yarn</button></form>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="catnip">
    <span class="cficon"><?= catfish_img('yi-catnip', '🌿', '', 48) ?></span><span class="cfinfo"><b>Catnip Hour</b> <small class="muted"><?= CATFISH_CATNIP_COST ?> Yarn a day</small><br><small><?= $cnLeft > 0 ? 'Taps pay double. ' . (int)ceil($cnLeft / 60) . ' minutes left.' : 'Taps on the fish pay double for an hour.' ?></small></span>
    <button class="btn" type="submit"<?= ($meta['catnip']['day'] ?? '') !== catfish_today() && $sp >= CATFISH_CATNIP_COST ? '' : ' disabled' ?>><?= CATFISH_CATNIP_COST ?> Yarn</button></form>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="treat">
    <span class="cficon"><?= catfish_img('yi-treat', '🍤', '', 48) ?></span><span class="cfinfo"><b>Mood Treat</b> <small class="muted"><?= CATFISH_TREAT_COST ?> Yarn a day</small><br><small><?= $treatDone ? 'Today ' . e($cat['name']) . ' also feels ' . e((string)$meta['treat']['mood']) . '.' : e($cat['name']) . ' gets a second mood for today.' ?></small>
      <select name="mood" aria-label="Mood"><?php foreach (CATFISH_TREAT_MOODS as $tm): if ($tm === $cat['mood']) continue; ?><option value="<?= e($tm) ?>"><?= e(ucfirst($tm)) ?></option><?php endforeach; ?></select></span>
    <button class="btn" type="submit"<?= !$treatDone && $sp >= CATFISH_TREAT_COST ? '' : ' disabled' ?>><?= CATFISH_TREAT_COST ?> Yarn</button></form>
</details>
<details class="cfgroup"><summary><b>🎨 Looks and titles</b></summary>
  <div class="cfup"><span class="cficon"><?= catfish_img('yi-balls', '🧶', '', 48) ?></span><span class="cfinfo"><b>Yarn ball colours</b> <small class="muted"><?= CATFISH_BALL_COST ?> Yarn each</small><br><small>Tints the ball by the rug.</small></span></div>
  <div class="cfballs">
<?php $ownBalls = (array)($meta['balls'] ?? []); $curBall = (string)($meta['ball'] ?? ''); foreach (array_merge(['' => 'Plain'], CATFISH_BALLS) as $bk => $bn): $mine = $bk === '' || in_array($bk, $ownBalls, true); ?>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="<?= $mine ? 'ballset' : 'ballbuy' ?>"><input type="hidden" name="key" value="<?= e($bk) ?>"><button class="btn cfballbtn cfball-sw-<?= e($bk === '' ? 'plain' : $bk) ?>" type="submit" aria-pressed="<?= $curBall === $bk ? 'true' : 'false' ?>"<?= !$mine && $sp < CATFISH_BALL_COST ? ' disabled' : '' ?>><?= e($bn) ?><?= $mine ? '' : ' · ' . CATFISH_BALL_COST . ' Yarn' ?></button></form>
<?php endforeach; ?>
  </div>
  <div class="cfup"><span class="cficon"><?= catfish_img('yi-season', '🍂', '', 48) ?></span><span class="cfinfo"><b>Seasonal room</b> <small class="muted"><?= CATFISH_SEASON_COST ?> Yarn each</small><br><small>Bits drift through the room while that season is on.</small></span></div>
  <div class="cfballs">
<?php $ownSeasons = (array)($meta['seasons'] ?? []); foreach (CATFISH_SEASONS as $sc2 => $sn2): $mineS = in_array($sc2, $ownSeasons, true); ?>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="season"><input type="hidden" name="code" value="<?= e($sc2) ?>"><button class="btn" type="submit"<?= $mineS || $sp < CATFISH_SEASON_COST ? ' disabled' : '' ?>><?= e($sn2) ?><?= $mineS ? ' ✓' : ' · ' . CATFISH_SEASON_COST . ' Yarn' ?></button></form>
<?php endforeach; ?>
  </div>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="scarfbuy">
    <span class="cficon"><?= catfish_img('yi-scarf', '🧣', '', 48) ?></span><span class="cfinfo"><b>Yarn scarf</b><br><small>Your gnome wears a scarf everywhere on the site. Colours are free.</small></span>
    <?php if (empty($meta['scarfown'])): ?><button class="btn" type="submit"<?= $sp >= CATFISH_SCARF_COST ? '' : ' disabled' ?>><?= CATFISH_SCARF_COST ?> Yarn</button><?php else: ?><small class="muted">Done</small><?php endif; ?></form>
<?php if (!empty($meta['scarfown'])): ?>
  <div class="cfballs">
<?php foreach (array_merge(['' => ['Scarf off', '']], CATFISH_SCARVES) as $sk => $sv): ?>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="scarfset"><input type="hidden" name="key" value="<?= e($sk) ?>"><button class="btn cfballbtn" type="submit" aria-pressed="<?= (string)($meta['scarf'] ?? '') === $sk ? 'true' : 'false' ?>"><?= e($sv[0]) ?></button></form>
<?php endforeach; ?>
  </div>
<?php endif; ?>
<?php if (catfish_festival_on()): ?>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="bunting">
    <span class="cficon"><?= catfish_img('yi-bunting', '🎏', '', 48) ?></span><span class="cfinfo"><b>Yarn bunting</b> <small class="muted"><?= max(0, CATFISH_BUNTING_DAILY - (($meta['bunting']['day'] ?? '') === catfish_today() ? (int)$meta['bunting']['n'] : 0)) ?> left today</small><br><small>Adds <?= CATFISH_BUNTING_ADD ?> to the festival jar.</small></span>
    <button class="btn" type="submit"<?= $sp >= CATFISH_BUNTING_COST && (($meta['bunting']['day'] ?? '') !== catfish_today() || (int)$meta['bunting']['n'] < CATFISH_BUNTING_DAILY) ? '' : ' disabled' ?>><?= CATFISH_BUNTING_COST ?> Yarn</button></form>
<?php endif; ?>
<?php foreach (CATFISH_TITLES as $tk => [$tn, $tc]): $got = in_array($tk, $myTitles, true); ?>
  <form method="post" class="cfup"><?= csrf_field() ?><input type="hidden" name="do" value="title"><input type="hidden" name="key" value="<?= e($tk) ?>">
    <span class="cficon"><?= catfish_img('yi-titles', '🏷️', '', 48) ?></span><span class="cfinfo"><b>Title: <?= e($tn) ?></b><br><small>Shown by your name. Pick it in the <a href="<?= e(url('book.php?ch=Milestones')) ?>">Almanac</a>.</small></span>
    <?php if (!$got): ?><button class="btn" type="submit"<?= $sp >= $tc ? '' : ' disabled' ?>><?= $tc ?> Yarn</button><?php else: ?><small class="muted">Yours</small><?php endif; ?></form>
<?php endforeach; ?>
</details>
</section>
<?= catfish_pet_panel_html($uid, $v, $meta) ?>
<?php
$reached = catfish_milestones_reached($uid, $st); $done = (array)($meta['ms'] ?? []);
$week = catfish_week(); $paidWk = ($meta['pw']['week'] ?? '') === $week ? (int)$meta['pw']['paid'] : 0; $capWk = (int)setting('catfish_petal_cap');
if ($capWk > 0): ?>
<section class="cfpanel box" id="cf-p-ms" data-icon="🌸" data-title="Milestones" data-status="<?= number_format($paidWk) ?> of <?= number_format($capWk) ?>" data-badge="0"><h3>🌸 Milestones · <?= number_format($paidWk) ?> of <?= number_format($capWk) ?> Petals this week</h3>
  <p class="help">Each milestone pays Petals once. At most <?= number_format($capWk) ?> a week, so a milestone that does not fit waits for next week.</p>
  <ul class="cfms">
  <?php foreach (CATFISH_MILESTONES_PETALS as $mk => [$ml, $mb]): $state = in_array($mk, $done, true) ? '✅ paid' : (!empty($reached[$mk]) ? '⏳ next week' : 'not yet'); ?>
    <li><?= e($ml) ?> · <?= number_format(game_petals($mb)) ?> Petals <small class="muted">· <?= e($state) ?></small></li>
  <?php endforeach; ?>
  </ul>
</section>
<?php endif; endif; ?>

<?php if ($owned > 0): $week = catfish_show_week(); $theme = catfish_show_theme($week); $entry = $meta['show'] ?? null; $entered = is_array($entry) && ($entry['week'] ?? '') === $week ? $entry : null; $myRibbons = catfish_ribbons($uid, 6);
?>
<section class="cfpanel box" id="cf-p-show" data-icon="🎀" data-title="Cat Show" data-status="<?php $en = ''; if ($entered) foreach ($cats as $c) if ($c['id'] === (int)$entered['cat']) $en = $c['name']; echo e($en !== '' ? $en . ' entered' : 'Not entered'); ?>" data-badge="0"><h3>🎀 Cat Show · <?= e($theme['label']) ?></h3>
  <p class="help">A new show every week (Monday to Sunday, <?= e(setting('game_timezone') ?: 'America/Halifax') ?> time). This one is judged in <?= nice_time(job_period_left('weekly')) ?>. Enter one cat. Three judges look at it when the week ends; a cat that fits the theme and a rarer cat score higher. Kibble and Yarn do not count. Prizes are ribbons on your profile.</p>
  <?php if ($entered): foreach ($cats as $c) if ($c['id'] === (int)$entered['cat']): ?><p>Entered: <b><?= e($c['name']) ?></b><?= ($c[$theme['trait']] ?? '') === $theme['value'] ? ' (fits the theme!)' : '' ?></p><?php endif; endif; ?>
  <?php if ($entered && !empty($entered['cat2'])): foreach ($cats as $c) if ($c['id'] === (int)$entered['cat2']): ?><p>Second entry: <b><?= e($c['name']) ?></b><?= ($c[$theme['trait']] ?? '') === $theme['value'] ? ' (fits the theme!)' : '' ?></p><?php endif; endif; ?>
  <form method="post" class="cfshowform"><?= csrf_field() ?><input type="hidden" name="do" value="show">
    <label for="cf-showcat">Cat</label>
    <select id="cf-showcat" name="cat"><?php foreach ($cats as $c): ?><option value="<?= (int)$c['id'] ?>"<?= $entered && (int)$entered['cat'] === $c['id'] ? ' selected' : '' ?>><?= e($c['name']) ?> (<?= e($c['colour'] . ' ' . $c['pattern']) ?>)</option><?php endforeach; ?></select>
    <button class="btn" type="submit"><?= $entered ? 'Swap entry' : 'Enter' ?></button></form>
  <?php if (!empty($meta['show2on']) && $entered && count($cats) > 1): ?>
  <form method="post" class="cfshowform"><?= csrf_field() ?><input type="hidden" name="do" value="show"><input type="hidden" name="slot" value="2">
    <label for="cf-showcat2">Second cat</label>
    <select id="cf-showcat2" name="cat"><?php foreach ($cats as $c): ?><option value="<?= (int)$c['id'] ?>"<?= $entered && (int)($entered['cat2'] ?? 0) === $c['id'] ? ' selected' : '' ?>><?= e($c['name']) ?> (<?= e($c['colour'] . ' ' . $c['pattern']) ?>)</option><?php endforeach; ?></select>
    <button class="btn" type="submit"><?= !empty($entered['cat2']) ? 'Swap second entry' : 'Enter second cat' ?></button></form>
  <?php endif; ?>
  <?php if ($myRibbons): ?><ul class="cfms"><?php foreach ($myRibbons as $rb): [$ri, $rl] = catfish_ribbon_face((string)$rb['tier']); ?><li><?= catfish_img('ribbon-' . $rb['tier'], $ri, '', 24) ?> <?= e($rl) ?> · <?= e($rb['cat_name']) ?> <small class="muted">· <?= e($rb['theme']) ?> (<?= e($rb['week']) ?>)</small></li><?php endforeach; ?></ul><?php endif; ?>
</section>
<?php endif; ?>

<?php if ($owned > 0): ?>
<section class="cfpanel box" id="cf-p-cats" data-icon="🐾" data-title="Your cats" data-status="<?= $owned ?> <?= $owned === 1 ? 'cat' : 'cats' ?>" data-badge="0"><h3>🐾 Your cats (<?= $owned ?>)</h3>
<?php foreach ($cats as $c): $on = $cat && $c['id'] === $cat['id']; ?>
  <div class="cfshelf cfrow"><?= $catCard($c) ?>
    <details class="cfren"><summary aria-label="Rename <?= e($c['name']) ?>">✎</summary>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="rename"><input type="hidden" name="cat" value="<?= (int)$c['id'] ?>">
      <input class="cfname" type="text" name="name" maxlength="<?= CATFISH_NAME_MAX ?>" value="<?= e($c['name']) ?>" aria-label="Name"><button class="btn" type="submit">Rename</button></form>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="bio"><input type="hidden" name="cat" value="<?= (int)$c['id'] ?>"><?= catfish_img('yi-bio', '', '', 24) ?>
      <input class="cfname cfbioin" type="text" name="bio" maxlength="<?= CATFISH_BIO_MAX ?>" value="<?= e($c['bio'] ?? '') ?>" placeholder="A line about <?= e($c['name']) ?>" aria-label="Bio line for <?= e($c['name']) ?>"><button class="btn" type="submit"><?= in_array((int)$c['id'], array_map('intval', (array)($meta['bios'] ?? [])), true) ? 'Save bio' : 'Bio · ' . CATFISH_BIO_COST . ' Yarn' ?></button></form>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="collar"><input type="hidden" name="cat" value="<?= (int)$c['id'] ?>"><?= catfish_img('yi-collar', '', '', 24) ?>
      <select name="key" aria-label="Collar for <?= e($c['name']) ?>"><option value="">No collar</option><?php $ownC = (array)($meta['collars'][$c['id']] ?? []); foreach (CATFISH_COLLARS as $ck => $cn): ?><option value="<?= e($ck) ?>"<?= ($c['collar'] ?? '') === $ck ? ' selected' : '' ?>><?= e($cn) ?><?= in_array($ck, $ownC, true) ? '' : ' · ' . CATFISH_COLLAR_COST . ' Yarn' ?></option><?php endforeach; ?></select><button class="btn" type="submit">Collar</button></form></details>
    <?php if ($on): ?><small class="muted">Playing</small>
    <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="switch"><input type="hidden" name="cat" value="<?= (int)$c['id'] ?>"><button class="btn" type="submit">Play</button></form><?php endif; ?>
    <?php if (!empty($meta['buddyon']) && !$on): $isB = (int)($meta['buddy'] ?? 0) === (int)$c['id']; ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="buddy"><input type="hidden" name="cat" value="<?= $isB ? 0 : (int)$c['id'] ?>"><button class="btn" type="submit" aria-pressed="<?= $isB ? 'true' : 'false' ?>"><?= $isB ? 'Buddy ✓' : 'Buddy' ?></button></form><?php endif; ?>
  </div>
<?php endforeach; ?>
</section>
<?php endif; ?>
<?php if ($owned > 0): $book = catfish_book($uid); $have = []; foreach ($book as $bk) $have[$bk[0] . '/' . $bk[1]] = $bk[2]; ?>
<section class="cfpanel box" id="cf-p-book" data-icon="📖" data-title="Cat Book" data-status="<?= count($book) ?> of <?= count(CATFISH_TRAITS['pattern']) * count(CATFISH_TRAITS['colour']) ?>" data-badge="0"><h3>📖 Cat Book (<?= count($book) ?> of <?= count(CATFISH_TRAITS['pattern']) * count(CATFISH_TRAITS['colour']) ?>)</h3>
  <p class="help">Every coat you have seen at the shelter or taken home (<?= catfish_art_has('cf-bookhead-unknown.png') ? 'bright = adopted, faded = only seen' : '🐱 = adopted' ?>). Fill the book for badges.</p>
  <div class="cfbook">
  <?php foreach (array_keys(CATFISH_TRAITS['pattern']) as $pat): $got = 0; foreach (array_keys(CATFISH_TRAITS['colour']) as $col) if (($have[$pat . '/' . $col] ?? -1) === 1) $got++; ?>
    <div class="cfbpat" data-label="<?= e(ucfirst($pat)) ?>" data-count="<?= $got ?>/<?= count(CATFISH_TRAITS['colour']) ?>">
    <?php foreach (array_keys(CATFISH_TRAITS['colour']) as $col): $st = $have[$pat . '/' . $col] ?? -1; $nm = ucfirst($col) . ' ' . $pat . ($st === 1 ? ', adopted' : ($st === 0 ? ', seen' : ', not seen yet')); ?>
      <span class="cfbtile<?= $st === 1 ? ' got' : '' ?>"><?= catfish_book_cell($col, $st, $nm) ?><small><?= e(ucfirst($col)) ?><br><span class="muted"><?= $st === 1 ? 'adopted' : ($st === 0 ? 'seen' : '?') ?></span></small></span>
    <?php endforeach; ?></div>
  <?php endforeach; ?>
  </div>
<?php if ($bg = catfish_badges($uid)): ?><p class="cfbadgeline"><?php foreach ($bg as $bk2 => [$bi, $bl2]): ?><span class="cfbadge" title="<?= e($bl2) ?>"><?= catfish_img('badge-' . $bk2, $bi, '', 24) ?> <?= e($bl2) ?></span> <?php endforeach; ?></p><?php endif; ?>
</section>
<?php endif; ?>
<?php if ($cat): ?></div><?php endif; ?>
</div>
<script type="application/json" id="cf-data"><?= json_encode(['kibble' => $v['kibble'], 'kph' => $v['kph'], 'api' => url('catfish_api.php'), 'csrf' => csrf_token(), 'has' => $cat !== null, 'play' => $v['play'], 'scene' => $sceneKey ?? '', 'cat' => (int)($cat['id'] ?? 0)], $J) ?></script>
<?php page_footer();
