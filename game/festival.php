<?php
declare(strict_types=1);
/** v1.0.0 wave 3: the festival page (Opening Day, and later seasonal festivals): dates, the flag, the festival jar, the stalls. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/hollow_goals.php';
require_once __DIR__ . '/includes/festival.php';
social_boot();
$u = require_login();
$uid = (int)$u['id'];
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'flag') [$ok, $msg] = festival_find_flag($u);
    elseif ($do === 'buy') [$ok, $msg] = festival_buy($u, (string)($_POST['stall'] ?? ''), (int)($_POST['idx'] ?? -1));
    else [$ok, $msg] = [false, 'Unknown action.'];
    flash($msg, $ok ? 'ok' : 'err');
    redirect('festival.php');
}
hollow_goal_settle_flash($uid);
$f = festival_active();
$next = $f ? null : festival_next();
$last = $f ? null : festival_last();
$season = festival_season_line();
page_header($f ? $f['name'] : 'Festivals');
?>
<?php if ($f):
    $goal = festival_goal($f); $st = $goal ? hollow_goal_state($goal) : null; $flags = festival_flags($f['slug'], $uid); $got = festival_flag_today($f['slug'], $uid);
    $stalls = festival_stalls($f, $uid); ?>
<div class="box festhero">
  <h1><?= e($f['icon'] . ' ' . $f['name']) ?></h1>
  <p class="festdates">Day <?= (int)$f['day'] ?> of <?= (int)$f['days'] ?> · <?= e(festival_left_text((int)$f['left'])) ?> left<?= $season ? ' · ' . e($season) : '' ?></p>
  <p><?= e($f['blurb']) ?></p>
</div>

<section class="box">
  <h2>🚩 The flag of the day</h2>
  <p class="help">One flag is hung somewhere in the Hollow every festival day. Find it here (no hunting required). Collect <?= e(implode(', ', array_keys($f['flag_rewards']))) ?> flags for rewards. You don’t need every day.</p>
  <p class="flagrow" aria-label="<?= $flags ?> of <?= (int)$f['days'] ?> flags"><?php for ($i = 1; $i <= (int)$f['days']; $i++): ?><span class="flagdot<?= $i <= $flags ? ' on' : '' ?>"><?= $i <= $flags ? '🎏' : '○' ?></span><?php endfor; ?></p>
  <ul class="flagrew">
    <?php foreach ($f['flag_rewards'] as $need => $r): $ok = (bool)q_val('SELECT 1 FROM festival_claims WHERE festival = ? AND user_id = ? AND reward = ?', [$f['slug'], $uid, 'flags' . $need]); ?>
      <li class="<?= $ok ? 'done' : '' ?>"><?= $ok ? '✅' : ($flags >= $need ? '🎁' : '⬜') ?> <?= (int)$need ?> flags: <?= e($r['text']) ?></li>
    <?php endforeach; ?>
  </ul>
  <?php if ($got): ?><p class="good">🎏 You found today’s flag. Come back tomorrow!</p>
  <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="flag"><button class="btn gold">🎏 Find today’s flag</button></form><?php endif; ?>
</section>

<?php if ($goal): $mine = hollow_goal_share((int)$goal['id'], $uid); ?>
<section class="box jarbox festjar">
  <div class="jarwrap">
    <?= hollow_jar_svg($st['pct'], (string)$goal['icon'], (string)$goal['title']) ?>
    <div class="jarinfo">
      <h2>🫙 The festival jar</h2>
      <p class="jartitle"><b><?= e($goal['title']) ?></b></p>
      <p class="jarnums"><b><?= number_format($st['total']) ?></b> of <?= number_format($st['target']) ?> · <?= $st['pct'] ?>%</p>
      <p class="help">Everything you do counts: a harvest, a walk, a pot of stew. <?= $mine ? 'You put in <b>' . number_format($mine) . '</b>.' : 'You haven’t added anything yet.' ?> <a href="<?= e(url('community.php?t=jar')) ?>">Tiers and rewards →</a></p>
    </div>
  </div>
</section>
<?php endif; ?>

<section class="box">
  <h2>🛍️ The stalls</h2>
  <p class="help">Run by the townsfolk, here for the festival only. A few of each per gnome. The number on a tile is what you have left.</p>
  <div class="stalls">
  <?php foreach ($stalls as $s): ?>
    <div class="stall">
      <h3><?= e($s['icon'] . ' ' . $s['name']) ?></h3>
      <?php if ($s['keeper']): ?><p class="help">Run by <b><?= e($s['keeper']) ?></b> 🏡</p><?php endif; ?>
      <div class="shopwrap"><div class="itmwrap"><div class="itms">
      <?php foreach ($s['goods'] as $g): $left = $g['limit'] - $g['bought']; ?>
        <?= sink_tile(['id' => (int)$g['item']['id'], 'item' => $g['item'], 'price' => (int)$g['price'], 'action' => url('festival.php'), 'verb' => 'Buy', 'do' => 'buy',
            'fields' => ['stall' => $s['key'], 'idx' => (int)$g['idx']], 'open' => $left > 0, 'dim' => $left < 1, 'coins' => (int)$u['coins'], 'badge' => (string)max(0, $left), 'badgeTitle' => 'Left for you',
            'note' => 'You have all you can carry', 'offNote' => 'Sold out', 'mini' => '']) ?>
      <?php endforeach; ?>
      </div></div></div>
    </div>
  <?php endforeach; ?>
  </div>
</section>

<section class="box">
  <h2>🏡 Who is about</h2>
  <?= hollow_pulse_html($u, true) ?>
  <p class="help">Sign a garden’s guestbook with 🎏 Bunting while the festival lasts (one a day per garden).</p>
</section>

<?php else: ?>
<div class="box festhero">
  <h1>🎏 Festivals</h1>
  <?php if ($next): ?>
    <p><b><?= e($next['icon'] . ' ' . $next['name']) ?></b> starts on <?= e(gmdate('F j', strtotime($next['starts'] . ' UTC'))) ?> and runs to <?= e(gmdate('F j', strtotime($next['ends'] . ' UTC'))) ?>.</p>
    <p><?= e($next['blurb']) ?></p>
  <?php else: ?>
    <p>No festival is on right now, and none is planned yet.<?= $last ? ' ' . e($last['name']) . ' was lovely. Its decorations come back next time.' : '' ?></p>
  <?php endif; ?>
  <?php if ($season): ?><p class="help"><?= e($season) ?></p><?php endif; ?>
</div>
<?php endif; ?>
<p><a href="<?= e(url('community.php?t=jar')) ?>">← The Hollow jar</a></p>
<?php page_footer();
