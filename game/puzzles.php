<?php
declare(strict_types=1);
/**
 * v2.0.69: Puzzles hub. GIFsaw (the animated jigsaw, gifsaw.php) is one game here; more puzzle games land as cards.
 * Old jigsaw links (puzzles.php?t=ID, ?seed=N) are sent on to gifsaw.php; hash-only links (#slug-n) by assets/puzzlehub.js (no inline script under the CSP).
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/puzzles.php';
require_once __DIR__ . '/includes/puzzle_games.php';
$u = require_login();
if (setting('puzzles_open') !== '1' && !is_admin()) { flash('Puzzles are coming soon.', 'err'); redirect('games.php'); }
if (isset($_GET['t']) || isset($_GET['seed'])) {
    $qs = array_intersect_key($_GET, ['t' => 1, 'seed' => 1]);
    redirect('gifsaw.php?' . http_build_query($qs));
}
$tourOn = puzzle_tournaments_on();
$live = $tourOn && puzzles_ensure() && q_val("SELECT 1 FROM puzzle_tournaments WHERE status = 'live' AND starts_at <= ? AND ends_at > ?", [now(), now()]);
page_header('Puzzles');
?>
<div id="pz">
<div id="lib">
  <?= puzzle_cast('puzzles-banner', '', 'pzbanner') ?>
  <h1>🧩 Puzzles</h1>
  <div class="pzhost box">
    <?= puzzle_cast('jeff-host', 'Jeff', 'pzface') ?>
    <div>
      <p class="pzline"><b>Jeff:</b> “Welcome to the puzzle room! Pick a game. More are coming, and I’ll tell you when they arrive.”</p>
    </div>
  </div>
  <ul class="pzhub">
    <li><a class="box pzhubcard" href="<?= e(url('gifsaw.php')) ?>">
      <span class="gticon"><?= puzzle_cast('tile-puzzles', '', 'gtart') ?: '🧩' ?></span>
      <b>GIFsaw</b>
      <small>Moving jigsaws. The picture plays while you solve it.</small>
      <span class="gtbadge"><?= $live ? '🏆 Tournament' : 'Relax' ?></span>
    </a></li>
    <?php $soon = ['snail' => ['🐌', 'Snail Trail', 'Draw one slimy trail through every square.']];
    foreach (PUZZLE_GAMES as $k => [$nm, $ic, $pg, $bl]): if (!puzzle_game_open($k)) { $soon = [$k => [$ic, $nm, $bl]] + $soon; continue; } $bd = pz_done_today((int)$u['id'], $k); ?>
    <li><a class="box pzhubcard" href="<?= e(url($pg)) ?>">
      <span class="gticon"><?= $ic ?></span>
      <b><?= e($nm) ?></b>
      <small><?= e($bl) ?></small>
      <span class="gtbadge"><?= $bd !== null ? 'Daily done ✓' : 'Daily ready' ?></span>
    </a></li>
    <?php endforeach; ?>
    <?php foreach ($soon as [$ic, $nm, $bl]): ?>
    <li><div class="box pzhubcard pzsoon" aria-disabled="true">
      <span class="gticon"><?= $ic ?></span>
      <b><?= e($nm) ?></b>
      <small><?= e($bl) ?></small>
      <span class="gtbadge">Coming soon</span>
    </div></li>
    <?php endforeach; ?>
  </ul>
  <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
</div>
</div>
<?php page_footer();
