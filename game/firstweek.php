<?php
declare(strict_types=1);
/** v1.0.0 wave 3: Wren's First Week: seven small cards, one a day after the tour. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/first_week.php';
$u = require_login();
$uid = (int)$u['id'];

if (is_post()) {
    csrf_check();
    [$ok, $msg] = first_week_claim($u, (int)($_POST['day'] ?? 0));
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('firstweek.php');
}

$st = first_week_state($uid);
page_header('Wren’s First Week');
?>
<h1>🐦 Wren’s First Week</h1>
<?php if (!$st): ?>
  <div class="box">
    <p><?php if (!first_week_on()): ?>Wren’s First Week is switched off.
      <?php elseif ((int)$u['tour_step'] > 0): ?>Finish Wren’s tour first (the card at the top of the page). The First Week starts right after it.
      <?php else: ?>Wren’s First Week is for new gnomes, and yours has already begun your own way. Welcome!<?php endif; ?></p>
    <p><a class="btn small" href="<?= e(url('index.php?today=1')) ?>">Back to Today</a></p>
  </div>
<?php else: ?>
  <p class="help">One card unlocks each day. Do them in any order, any time: they never run out, and nothing is lost if you miss a day.
    <?= $st['complete'] ? '' : '<b>' . $st['claimed_n'] . ' of 7</b> done.' ?></p>
  <?php if ($st['complete']): ?><div class="box notice">🎉 You finished the First Week. Wren is proud of you. The Hollow is all yours now.</div><?php endif; ?>
  <div class="fwgrid">
  <?php foreach ($st['cards'] as $day => $c): ?>
    <section class="box fwcard<?= $c['claimed'] ? ' claimed' : '' ?><?= $c['locked'] ? ' locked' : '' ?><?= $c['done'] && !$c['claimed'] ? ' ready' : '' ?>">
      <header><span class="fwday">Day <?= $day ?></span> <h2><?= $c['locked'] ? '🔒 ' : ($c['claimed'] ? '✅ ' : '') ?><?= e($c['title']) ?></h2></header>
      <?php if ($c['locked']): ?>
        <p class="muted">Unlocks <?= $day - $st['unlocked'] === 1 ? 'tomorrow' : 'in ' . ($day - $st['unlocked']) . ' days' ?>.</p>
      <?php else: ?>
        <p class="say"><?= e($c['intro']) ?></p>
        <ul class="fwtasks">
          <?php foreach ($c['tasks'] as [$key, $label, $link, $how, $done]): ?>
            <li class="<?= $done ? 'done' : '' ?>"><span class="jtick"><?= $done ? '✅' : '⬜' ?></span>
              <span><?= e($label) ?><?php if (!$done): ?> <a href="<?= e(url($link)) ?>">Go →</a><br><small class="muted"><?= e($how) ?></small><?php endif; ?></span></li>
          <?php endforeach; ?>
        </ul>
        <p class="help">🎁 <?= e($c['reward']) ?></p>
        <?php if ($c['claimed']): ?><p class="good">Reward taken.</p>
        <?php elseif ($c['done']): ?>
          <form method="post"><?= csrf_field() ?><input type="hidden" name="day" value="<?= $day ?>"><button class="btn gold">🎁 Take the reward</button></form>
        <?php endif; ?>
      <?php endif; ?>
    </section>
  <?php endforeach; ?>
  </div>
<?php endif; ?>
<?php page_footer();
