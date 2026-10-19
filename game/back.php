<?php
declare(strict_types=1);
/** v1.0.0 wave 3: Welcome back. A kind summary after a few days away. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/welcome_back.php';
$u = require_login();
$uid = (int)$u['id'];
if (is_post()) {
    csrf_check();
    [$ok, $msg] = welcome_back_open($u, ($_POST['do'] ?? '') === 'basket');
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('index.php');
}
if (!welcome_back_due($u)) redirect('index.php');
$s = welcome_back_summary($u);
page_header('Welcome back');
?>
<div class="box todayhead wbhead">
  <div class="tavatar"><?= gnome_avatar($u, 64) ?></div>
  <div>
    <h1>Welcome back, <?= e(gnome_name($u)) ?>!</h1>
    <p class="muted">You were away about <?= (int)$s['away'] ?> day<?= (int)$s['away'] === 1 ? '' : 's' ?>. Nothing was lost, and nothing is owed. Here is what happened.</p>
  </div>
</div>

<div class="wbgrid">
  <section class="box">
    <h2>🌱 Your garden</h2>
    <?php if ($s['ready'] || $s['thirsty'] || $s['growing']): ?>
      <p><?php if ($s['ready']): ?><b>🧺 <?= (int)$s['ready'] ?> ready to harvest</b><?= $s['crops'] ? ' (' . e(implode(', ', array_map(fn($n, $c) => $n . ($c > 1 ? ' ×' . $c : ''), array_keys($s['crops']), $s['crops']))) . ')' : '' ?><br><?php endif; ?>
        <?php if ($s['thirsty']): ?>💧 <?= (int)$s['thirsty'] ?> thirsty<br><?php endif; ?>
        <?php if ($s['growing']): ?>🌿 <?= (int)$s['growing'] ?> still growing<?php endif; ?></p>
    <?php else: ?><p class="muted">The beds are quiet. A fresh start whenever you like.</p><?php endif; ?>
    <p><a class="btn small" href="<?= e(url('garden.php')) ?>">To the garden →</a></p>
  </section>
  <?php if ($s['pots'] || $s['jars'] || $s['racks']): ?>
  <section class="box">
    <h2>🍲 Ready and waiting</h2>
    <p><?= $s['pots'] ? '🍲 ' . (int)$s['pots'] . ' pot' . ($s['pots'] === 1 ? '' : 's') . ' ready<br>' : '' ?><?= $s['jars'] ? '🫙 ' . (int)$s['jars'] . ' jar' . ($s['jars'] === 1 ? '' : 's') . ' ready<br>' : '' ?><?= $s['racks'] ? '🪢 ' . (int)$s['racks'] . ' drying rack' . ($s['racks'] === 1 ? '' : 's') . ' ready' : '' ?></p>
    <p><a class="btn small" href="<?= e(url('inventory.php?tab=craft')) ?>">To the kitchen →</a></p>
  </section>
  <?php endif; ?>
  <section class="box">
    <h2>📬 Letters</h2>
    <?php if ($s['noticeN'] === 0): ?><p class="muted">No letters came while you were away. Peaceful!</p>
    <?php else: ?><ul class="wbletters"><?php foreach ($s['notices'] as $n): ?><li><?= e($n['text']) ?></li><?php endforeach; ?></ul>
      <?php if ($s['noticeN'] > count($s['notices'])): ?><p class="help">…and <?= $s['noticeN'] - count($s['notices']) ?> more.</p><?php endif; ?><?php endif; ?>
    <?php if ($s['requests']): ?><p><a href="<?= e(url('pals.php?tab=requests')) ?>">🤝 <?= (int)$s['requests'] ?> friend request<?= $s['requests'] === 1 ? '' : 's' ?> waiting →</a></p><?php endif; ?>
  </section>
  <?php if ($s['goal']): $g = $s['goal']['goal']; $st = $s['goal']['state']; ?>
  <section class="box">
    <h2><?= e($g['icon']) ?> The Hollow’s jar</h2>
    <p><b><?= e($g['title']) ?></b></p>
    <p class="jarnums"><?= number_format($st['total']) ?> of <?= number_format($st['target']) ?> (<?= $st['pct'] ?>%)</p>
    <progress max="<?= $st['target'] ?>" value="<?= $st['total'] ?>" aria-label="Jar progress"></progress>
    <p class="help">The townsfolk and the other gnomes have been busy. <?= $s['goal']['mine'] ? 'You’ve put in ' . number_format($s['goal']['mine']) . '.' : 'Anything you do now counts.' ?></p>
    <p><a href="<?= e(url('community.php?t=jar')) ?>">The Hollow jar →</a></p>
  </section>
  <?php endif; ?>
  <section class="box">
    <h2>✨ What’s new</h2>
    <ul>
      <?php if ($s['newGnomes']): ?><li>👋 <?= (int)$s['newGnomes'] ?> new gnome<?= $s['newGnomes'] === 1 ? ' has' : 's have' ?> moved into the Hollow.</li><?php endif; ?>
      <?php foreach ($s['news'] as $n): ?><li>📰 <?= e($n['title']) ?></li><?php endforeach; ?>
      <?php if (function_exists('festival_active')): require_once __DIR__ . '/includes/festival.php'; if ($f = festival_active()): ?><li><?= e($f['icon']) ?> <a href="<?= e(url('festival.php')) ?>"><?= e($f['name']) ?> is on!</a></li><?php endif; endif; ?>
      <?php if (!$s['newGnomes'] && !$s['news']): ?><li class="muted">Nothing new to report. Same cosy Hollow.</li><?php endif; ?>
    </ul>
    <p><a href="<?= e(url('index.php#news')) ?>">All the news →</a></p>
  </section>
</div>

<form method="post" class="box wbbasket"><?= csrf_field() ?>
  <h2>🧺 A welcome-back basket</h2>
  <p><?= $s['basket'] > 0 ? 'The townsfolk left you ' . e(money($s['basket'])) . '. ' : '' ?>No streaks, no catching up. Pick up where you like.</p>
  <button class="btn gold" name="do" value="basket"><?= $s['basket'] > 0 ? 'Open the basket and go on' : 'Go on' ?></button>
</form>
<?php page_footer();
