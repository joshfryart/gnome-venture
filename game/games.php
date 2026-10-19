<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
require_once __DIR__ . '/includes/gathering.php';   // v1.5.0: the Practice tab
$u = require_login();
$uid = (int)$u['id'];
ensure_race_secret();
settle_races();
settle_marrows();
$tab = in_array($_GET['tab'] ?? '', ['contests', 'practice'], true) ? $_GET['tab'] : 'games';   // v1.5.0: + practice   // v0.8.2: games and contests on their own tabs
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
  <a class="<?= $tab === 'practice' ? 'on' : '' ?>" href="<?= e(url('games.php?tab=practice')) ?>">🎯 Practice</a><?php /* v1.5.0 */ ?>
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
  <a class="gtile ok" href="<?= e(url('puzzles.php')) ?>" title="Animated jigsaw puzzles. Just for fun: no prizes, no daily limit."><?php /* v2.0.0.1 */ ?>
    <span class="gticon">🧩</span>
    <b>Puzzles</b>
    <span class="gtbadge">Relax</span>
  </a>
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
<?php elseif ($tab === 'practice'): /* v1.5.0: the six tool games, for fun: nothing is paid */ ?>
<h2>🎯 Tool game practice</h2>
<?= gather_practice_html($u) ?>
<?php else: ?>
<?= contests_hub_html($u) ?>
<p class="help">Contests run on their own: the Village Show enters your best harvest of its crop for you, and the Fair keeps your best of each class until you enter it. Winners get Petals and a 🎀 ribbon on their profile.</p>
<?php endif; ?>
<?php page_footer();
