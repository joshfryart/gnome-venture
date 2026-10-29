<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
$u = require_login();
$uid = (int)$u['id'];
ensure_race_secret();
settle_races();
settle_marrows();
$tab = in_array($_GET['tab'] ?? '', ['contests'], true) ? $_GET['tab'] : 'games';   // v2.0.67: the Practice tab is gone with the tool games   // v0.8.2: games and contests on their own tabs
require_once __DIR__ . '/includes/contests.php';
require_once __DIR__ . '/includes/fair.php';
settle_shows();
settle_fair();
page_header('Games');
?>
<h1>🎲 Games</h1>
<nav class="tabs">
  <a class="<?= $tab === 'games' ? 'on' : '' ?>" href="<?= e(url('games.php')) ?>">🎲 Games</a>
  <a class="<?= $tab === 'contests' ? 'on' : '' ?>" href="<?= e(url('games.php?tab=contests')) ?>">🏆 Contests</a>
</nav>
<?php if ($tab === 'games'): ?>
<p class="help">Plays come back at the daily reset (in <?= nice_time(job_period_left('daily')) ?>).</p>
<div class="gtiles">
<?php foreach (GAMES as $key => [$name, $icon, $page, $blurb]):
    $left = game_plays_left($uid, $key);
    $live = game_state($uid, $key) && $key !== 'letters';
    $badge = $live ? ['go', '▶ In progress'] : ($left > 0 ? ['ok', $left . ' left'] : ['done', 'Done today']);
    if ($key === 'marrow' && (int)$u['level'] < (int)setting('marrow_min_level')) $badge = ['done', 'Lv ' . (int)setting('marrow_min_level')];   // v0.9.1a: locked, not "1 left"
    $extra = $key === 'marrow' ? '💰 ' . money(marrow_pot()) : ''; ?>
  <a class="gtile <?= e($badge[0]) ?>" href="<?= e(url($page)) ?>" title="<?= e($blurb) ?>">
    <span class="gticon"><?= $icon ?></span>
    <b><?= e($name) ?></b>
    <span class="gtbadge"><?= e($badge[1]) ?></span>
    <?php if ($extra !== ''): ?><small class="gtextra"><?= $extra ?></small><?php endif; ?>
  </a>
<?php endforeach; ?>
<?php if (setting('puzzles_open') === '1' || is_admin()): ?>
  <?php require_once __DIR__ . '/includes/puzzles.php'; ?>
  <a class="gtile ok" href="<?= e(url('puzzles.php')) ?>" title="Puzzle games with Jeff: GIFsaw moving jigsaws and more. Just for fun, no daily limit."><?php /* v2.0.0.1; v2.0.68 tile art */ ?>
    <span class="gticon"><?= puzzle_cast('tile-puzzles', '', 'gtart') ?: '🧩' ?></span>
    <b>Puzzles</b>
    <span class="gtbadge"><?php require_once __DIR__ . '/includes/jigsaw.php'; $gk = array_keys(array_filter(['gif' => puzzle_tournaments_on(), 'still' => jigsaw_tournaments_on()])); ?><?= $gk && puzzles_ensure() && q_val("SELECT 1 FROM puzzle_tournaments WHERE kind IN ('" . implode("','", $gk) . "') AND status = 'live' AND starts_at <= ? AND ends_at > ?", [now(), now()]) ? '🏆 Tournament' : 'Relax' ?></span>
  </a>
<?php endif;   // v2.0.2: Puzzles locked for players (setting puzzles_open) ?>
<?php require_once __DIR__ . '/includes/catfish.php'; if (catfish_open()): ?>
  <a class="gtile ok" href="<?= e(url('catfish.php')) ?>" title="Adopt a cat and dangle a toy fishing rod. Upgrade it and the cat keeps catching fish, even while you are away.">
    <span class="gticon"><?= catfish_img('tile', '🐱', '', 64) ?></span>
    <b>Cat Fish</b>
    <span class="gtbadge">Relax</span>
  </a>
<?php endif;   // Cat Fish (setting catfish_open) ?>
</div>
<details class="fold box"><summary>🏅 This week’s high scores</summary>
  <div class="gtops">
  <?php foreach (GAMES as $key => [$name, $icon]): $top = game_top($key); if (!$top) continue; ?>
    <div><b><?= $icon ?> <?= e($name) ?></b> <small class="muted">· your best <?= game_best($uid, $key) ?></small>
      <ol class="top"><?php foreach ($top as $t): ?><li><?= e($t['name']) ?> — <?= (int)$t['best'] ?></li><?php endforeach; ?></ol></div>
  <?php endforeach; ?>
  </div>
  <p class="help">High scores reset every week.</p>
</details>
<?php else: ?>
<?= contests_hub_html($u) ?>
<p class="help">Contests run on their own: the Village Show enters your best harvest of its crop for you, and the Fair keeps your best of each class until you enter it. Winners get Petals and a 🎀 ribbon on their profile.</p>
<?php endif; ?>
<?php page_footer();
