<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/community.php';
require_once __DIR__ . '/includes/catalog.php';
require_once __DIR__ . '/includes/hollow_goals.php';
require_once __DIR__ . '/includes/festival.php';
social_boot();
$u = require_login();
$uid = (int)$u['id'];

if (is_post()) {
    csrf_check();
    refresh_energy($u);
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = match ($do) {
        'take_store' => community_take($u, 'store', (int)($_POST['item_id'] ?? 0)),
        'take_bed' => community_take($u, 'bed', (int)($_POST['bed'] ?? 0)),
        'donate' => community_donate($u, (int)($_POST['item_id'] ?? 0), (int)($_POST['qty'] ?? 1)),
        'shift' => community_start_shift($u, (int)($_POST['minutes'] ?? 0)),
        'end_shift' => community_end_shift($u),
        'tend' => (function () use ($u) {
            [$act, $bed] = explode(':', (string)($_POST['act'] ?? ':')) + [1 => 0];
            return community_tend($u, $act, (int)$bed, (int)($_POST['seed'] ?? 0));
        })(),
        default => [false, 'Unknown action.'],
    };
    flash($msg, $ok ? 'ok' : 'err');
    redirect('community.php?t=garden');
}

$t = in_array($_GET['t'] ?? '', ['garden', 'jar', 'about'], true) ? (string)$_GET['t'] : 'garden';
$tl = fn(string $k) => e(url('community.php?t=' . $k));
if ($t === 'garden') {
$beds = community_beds();
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);   // fresh shift and daily flags
$onShift = community_on_shift($u);
$took = community_took_today($u);
$store = q('SELECT s.item_id, s.qty, i.name, i.category FROM community_store s JOIN items i ON i.id = s.item_id WHERE s.qty > 0 ORDER BY i.category, i.name')->fetchAll();
$storeSeeds = array_filter($store, fn($s) => $s['category'] === 'seed');
$mySeeds = q("SELECT i.id, i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'seed' ORDER BY i.name", [$uid])->fetchAll();
$helpers = q("SELECT COALESCE(us.gnome_name, us.username) AS name, COUNT(*) AS n FROM community_log l JOIN users us ON us.id = l.user_id
              WHERE l.week = ? AND " . gnome_in_play_sql('us') . " GROUP BY l.user_id, us.gnome_name, us.username ORDER BY n DESC LIMIT 5", [job_period_key('weekly')])->fetchAll();
$ripe = array_filter($beds, fn($b) => cbed_ripe($b, $b['_p']));
$n = community_size();
}
if ($t === 'jar') {
    hollow_goal_settle_flash($uid);
    $goals = hollow_goals_active();
    $hist = hollow_goal_history($uid, 6);
    $fest = festival_active();
}
page_header('Together');
?>
<h1>🤝 Together</h1>
<nav class="tabs">
  <a class="<?= $t === 'garden' ? 'on' : '' ?>" href="<?= $tl('garden') ?>">🏡 Community garden</a>
  <a class="<?= $t === 'jar' ? 'on' : '' ?>" href="<?= $tl('jar') ?>">🫙 Hollow jar</a>
  <a class="<?= $t === 'about' ? 'on' : '' ?>" href="<?= $tl('about') ?>">💓 Who’s about</a>
</nav>

<?php if ($t === 'garden'): ?>
<h2>🏡 The Community Garden</h2>
<p class="help">Everyone’s garden, in the middle of Mossbottom, kept going by gnomes: everything here was donated or grown by someone.
  Donate seeds, volunteer for a tending shift, and if you’re short of Petals, take one small thing a day. You’ve helped <?= (int)$u['community_rep'] ?> times.</p>

<div class="commwrap">
  <div>
  <?php if ($onShift): ?><form method="post" class="tendform"><?= csrf_field() ?><input type="hidden" name="do" value="tend">
    <p class="help">🧑‍🌾 On shift: tap 💧 to water, 🌿 to weed, 🧺 to harvest into the store, or 🌱 to plant
      <?php if ($storeSeeds): ?><select name="seed" aria-label="Seed to plant"><?php foreach ($storeSeeds as $s): ?><option value="<?= (int)$s['item_id'] ?>"><?= e($s['name']) ?> (<?= (int)$s['qty'] ?>)</option><?php endforeach; ?></select><?php else: ?>(the store has no seeds — donate some!)<?php endif; ?></p>
  <?php endif; ?>
  <div class="commgrid g<?= $n ?>">
    <?php foreach ($beds as $b): $p = $b['_p'];
        $state = !$p ? 'empty' : (cbed_ripe($b, $p) ? 'ripe' : (cbed_thirsty($b, $p) ? 'thirsty' : 'growing'));
        $pct = $p ? (int)min(100, (int)$b['grown'] * 100 / max(1, (int)$p['grow_minutes'] * 60)) : 0; ?>
      <div class="cbed <?= $state ?><?= (int)$b['weeds'] >= 20 ? ' weedy' : '' ?>" title="<?= $p ? e($p['name']) . ' · ' . $pct . '%' : 'Empty bed' ?>">
        <span class="ic"><?= !$p ? '·' : ($state === 'ripe' ? catalog_kind_icon((string)$p['kind']) : ($pct < 34 ? '🌱' : '🌿')) ?></span>
        <small><?= $p ? e(mb_strimwidth((string)$p['name'], 0, 10, '…')) : '' ?></small>
        <?= $state === 'thirsty' ? '<em>💧</em>' : '' ?><?= (int)$b['weeds'] >= 20 ? '<em class="w">🌿</em>' : '' ?>
        <?php if ($onShift): ?>
          <span class="bedacts">
            <?php if ($state === 'thirsty'): ?><button name="act" value="water:<?= (int)$b['id'] ?>" title="Water" aria-label="Water">💧</button><?php endif; ?>
            <?php if ((int)$b['weeds'] >= 5): ?><button name="act" value="weed:<?= (int)$b['id'] ?>" title="Weed" aria-label="Weed">🌿</button><?php endif; ?>
            <?php if ($state === 'ripe'): ?><button name="act" value="harvest:<?= (int)$b['id'] ?>" title="Harvest into the store" aria-label="Harvest into the store">🧺</button><?php endif; ?>
            <?php if ($state === 'empty' && $storeSeeds): ?><button name="act" value="plant:<?= (int)$b['id'] ?>" title="Plant the chosen seed" aria-label="Plant the chosen seed">🌱</button><?php endif; ?>
          </span>
        <?php endif; ?>
      </div>
    <?php endforeach; ?>
  </div>
  <?php if ($onShift): ?></form><?php endif; ?>
  </div>

  <div class="commside">
    <div class="box">
      <h3>🧺 Today’s take</h3>
      <?php if ($took): ?><p class="muted">You’ve had your share today. Back after the reset (<?= nice_time(job_period_left('daily')) ?>).</p>
      <?php elseif (!community_need_ok($u)): ?><p class="muted">The daily gift is for gnomes who are short of Petals (under <?= money((int)setting('community_need_coins')) ?>). You’re doing fine, so why not donate some seeds?</p>
      <?php else: ?>
        <?php if ($ripe): ?>
          <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="take_bed">
            <label>Pick something ripe <select name="bed"><?php foreach ($ripe as $b): ?><option value="<?= (int)$b['id'] ?>"><?= e($b['_p']['name']) ?> (bed <?= (int)$b['x'] + 1 ?>, <?= (int)$b['y'] + 1 ?>)</option><?php endforeach; ?></select></label>
            <button class="btn small">Pick it</button></form>
        <?php endif; ?>
        <?php if ($store): ?>
          <form method="post" class="form"><?= csrf_field() ?><input type="hidden" name="do" value="take_store">
            <label><?= $ripe ? '…or take' : 'Take' ?> from the store <select name="item_id"><?php foreach ($store as $s): ?><option value="<?= (int)$s['item_id'] ?>"><?= e($s['name']) ?> (<?= (int)$s['qty'] ?>)</option><?php endforeach; ?></select></label>
            <button class="btn small">Take one</button></form>
        <?php endif; ?>
        <p class="help">One small thing a day, so there’s enough for everyone.</p>
      <?php endif; ?>
    </div>
    <div class="box">
      <h3>🧑‍🌾 Volunteer</h3>
      <?php if ($onShift): ?>
        <p>On shift for another <b><?= nice_time(ts($u['community_shift_until']) - time()) ?></b>. Use the buttons on the beds. <?= (int)$u['shift_actions'] ?> / <?= (int)setting('community_shift_cap') ?> jobs done,
          <?= money((int)setting('community_tip')) ?> thanks each.</p>
        <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="end_shift"><button class="btn small alt">End shift</button></form>
      <?php else: ?>
        <p class="help">Water, weed, plant from the store and harvest into it. Each job takes 1 energy and earns <?= money((int)setting('community_tip')) ?> and 1 XP. You can’t go adventuring while on shift.</p>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="shift">
          <?php foreach (COMMUNITY_SHIFTS as $m): ?><button class="btn small" name="minutes" value="<?= $m ?>"><?= $m ?> min</button> <?php endforeach; ?></form>
      <?php endif; ?>
    </div>
    <div class="box">
      <h3>💚 Donate seeds</h3>
      <?php if ($mySeeds): ?>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="donate">
          <select name="item_id"><?php foreach ($mySeeds as $s): ?><option value="<?= (int)$s['id'] ?>"><?= e($s['name']) ?> (<?= (int)$s['qty'] ?>)</option><?php endforeach; ?></select>
          × <input type="number" name="qty" value="1" min="1" class="qty"> <button class="btn small">Donate</button></form>
      <?php else: ?><p class="muted">No seeds to spare right now.</p><?php endif; ?>
    </div>
    <?php if ($helpers): ?>
      <div class="box"><h3>🌟 This week’s helpers</h3><ol class="top"><?php foreach ($helpers as $h): ?><li><?= e($h['name']) ?> — <?= (int)$h['n'] ?></li><?php endforeach; ?></ol></div>
    <?php endif; ?>
  </div>
</div>

<?php elseif ($t === 'jar'): ?>
<?php if ($fest): ?>
  <a class="box festcall" href="<?= e(url('festival.php')) ?>"><b><?= e($fest['icon'] . ' ' . $fest['name']) ?> is on!</b> Day <?= (int)$fest['day'] ?> of <?= (int)$fest['days'] ?>. Stalls, a flag to find, and a shared jar. <span class="tgo">Open the festival →</span></a>
<?php endif; ?>

<?php if (!hollow_goals_on()): ?>
  <div class="box"><p class="muted">Hollow Goals are switched off right now.</p></div>
<?php endif; ?>
<?php foreach ($goals as $g): $st = hollow_goal_state($g); $mine = hollow_goal_share((int)$g['id'], $uid); $helpers = hollow_goal_helpers((int)$g['id'], 5); ?>
  <section class="box jarbox<?= $g['festival'] ? ' festjar' : '' ?>">
    <div class="jarwrap">
      <?= hollow_jar_svg($st['pct'], (string)$g['icon'], (string)$g['title']) ?>
      <div class="jarinfo">
        <h2><?= $g['festival'] ? '🎏 Festival jar' : '🫙 This week’s jar' ?></h2>
        <p class="jartitle"><b><?= e($g['title']) ?></b></p>
        <p class="jarnums"><b><?= number_format($st['total']) ?></b> of <?= number_format($st['target']) ?> · <?= $st['pct'] ?>%
          <small class="muted">· <?= e(nice_time($st['left'])) ?> left</small></p>
        <p class="help">Gnomes <?= number_format($st['gnomes']) ?>, townsfolk 🏡 <?= number_format($st['folk']) ?>. <?= $mine ? 'You put in <b>' . number_format($mine) . '</b>.' : 'You haven’t added anything yet. Whatever you do anyway counts.' ?></p>
      </div>
    </div>
    <ol class="tiers">
      <?php foreach (HOLLOW_GOAL_TIERS as $i => $p): $reached = $st['tier'] > $i; $paid = $mine >= max(1, (int)setting('goal_min_share')); ?>
        <li class="<?= $reached ? 'on' : '' ?>"><span class="tk"><?= $reached ? '✅' : '⬜' ?></span> <b><?= $p ?>%</b> <small class="muted">(<?= number_format((int)ceil($st['target'] * $p / 100)) ?>)</small> <span class="tr">🎁 <?= e(hollow_goal_tier_text($i + 1)) ?></span></li>
      <?php endforeach; ?>
    </ol>
    <p class="help">Everyone who puts something in gets every tier’s reward, whenever it is reached. Rewards arrive by themselves the next time you open this page or Today.</p>
    <?php if ($helpers): ?><p class="help">Helping most: <?php $bits = []; foreach ($helpers as $h) $bits[] = (int)$h['garden_public'] === 1 || (int)$h['id'] === $uid ? e($h['name']) . ' (' . number_format((int)$h['amount']) . ')' : 'a quiet gnome (' . number_format((int)$h['amount']) . ')'; echo implode(', ', $bits); ?>.</p><?php endif; ?>
  </section>
<?php endforeach; ?>

<?php if ($hist): ?>
<section class="box">
  <h2>📜 Past jars</h2>
  <ul class="jarhist">
    <?php foreach ($hist as $h): $g = $h['goal']; $s = $h['state']; ?>
      <li><span class="jh-ic"><?= e($g['icon']) ?></span>
        <span><b><?= e($g['title']) ?></b><br><small class="muted"><?= $s['pct'] ?>% · tier <?= (int)$s['tier'] ?> of 4 · <?= (int)$h['gnomes'] ?> gnome<?= (int)$h['gnomes'] === 1 ? '' : 's' ?> helped<?= $h['mine'] ? ' · you put in ' . number_format((int)$h['mine']) : '' ?></small></span></li>
    <?php endforeach; ?>
  </ul>
</section>
<?php endif; ?>
<?php else: ?>
<section class="box">
  <h2>💓 Who’s about</h2>
  <?= hollow_pulse_html($u) ?>
  <p class="help">Only public things show here. Gnomes with private gardens are counted, never named.</p>
</section>
<?php endif; ?>
<?php page_footer();
