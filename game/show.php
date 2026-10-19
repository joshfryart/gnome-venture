<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/contests.php';
require_once __DIR__ . '/includes/games.php';   // v1.4.1: game tabs
$u = require_login();
$uid = (int)$u['id'];
settle_shows();
$week = job_period_key('weekly');
$crop = show_crop();
[$name, $unit] = SHOW_CROPS[$crop];
$board = q('SELECT e.*, COALESCE(u.gnome_name, u.username) AS gname FROM show_entries e JOIN users u ON u.id = e.user_id
            WHERE e.week = ? AND u.banned = 0 ORDER BY e.size DESC, e.entered_at LIMIT 10', [$week])->fetchAll();
require_once __DIR__ . '/includes/townsfolk.php';
$board = townsfolk_merge($board, townsfolk_show($week, $crop), 'size');   // v1.0.0: townsfolk grow too (never judged, never paid)
$mine = q_one('SELECT * FROM show_entries WHERE week = ? AND user_id = ?', [$week, $uid]);
$past = q("SELECT e.*, COALESCE(u.gnome_name, u.username) AS gname FROM show_entries e JOIN users u ON u.id = e.user_id
           WHERE e.placed = 1 ORDER BY e.week DESC LIMIT 6")->fetchAll();
$plantName = q_val('SELECT name FROM plants WHERE slug = ?', [$crop]) ?: $crop;
page_header('Village Show');
?>
<h1>🏅 The Village Show</h1>
<p class="help"><a href="<?= e(url('games.php?tab=contests')) ?>">← Contests</a></p>
<?= game_tabs_html('show.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    echo game_rules_html([
        ['🎯', 'Goal.', 'Grow the biggest one of the week’s crop. The crop changes every week.'],
        ['📏', 'Entering.', 'Nothing to press. Each one you harvest is measured, and your best is entered for you.'],
        ['🌱', 'Growing big.', 'Rich soil, the crop’s own nutrient, healthy soil life and a good soil grade all help. So does a little luck.'],
        ['⏳', 'Judging.', 'At the end of the week, when the weekly reset comes.'],
        ['🥇', 'Prizes.', '1st ' . money(SHOW_PRIZES[1][0]) . ' and a rare seed, 2nd ' . money(SHOW_PRIZES[2][0]) . ', 3rd ' . money(SHOW_PRIZES[3][0]) . '. The top three also get a 🎀 ribbon.'],
        ['🎁', 'Everyone else.', 'Anyone who enters gets ' . money(25) . ' for taking part.'],
    ]);
    echo '<p><a href="' . e(url('games.php?tab=contests')) . '">← Contests</a></p>';
    page_footer(); return;
endif; ?>
<div class="box">
  <h2>This week: <?= e($name) ?></h2>
  <p>Grow and harvest <b><?= e($plantName) ?></b>. Your best is entered for you. Judging in <?= nice_time(job_period_left('weekly')) ?>.</p>
  <p class="help">Your best: <?= $mine ? '<b>' . e(show_size_text($crop, (float)$mine['size'])) . '</b>' : 'not entered yet' ?></p>
  <?php if ($board): ?>
    <table class="grid"><tr><th>#</th><th>Gnome</th><th><?= e(ucfirst($unit === 'cm' ? 'length' : 'weight')) ?></th></tr>
      <?php foreach ($board as $b): ?><tr<?= !$b['npc'] && (int)$b['user_id'] === $uid ? ' class="here"' : '' ?>><td><?= $b['npc'] ? '🏡' : (['🥇', '🥈', '🥉'][$b['prank'] - 1] ?? $b['prank']) ?></td><td><?= e($b['gname']) ?><?= $b['npc'] ? ' ' . townsfolk_tag() : '' ?></td><td><?= e(show_size_text($crop, (float)$b['size'])) ?></td></tr><?php endforeach; ?>
    </table>
    <?php if (array_filter($board, fn($b) => $b['npc'])) echo townsfolk_note(); ?>
  <?php else: ?><p class="muted">No entries yet. Be the first!</p><?php endif; ?>
</div>
<?php if ($past): ?>
  <div class="box"><h3>Past champions</h3><ul>
    <?php foreach ($past as $p): ?><li><?= e($p['week']) ?> · <?= e(SHOW_CROPS[$p['crop']][0] ?? $p['crop']) ?>: <b><?= e($p['gname']) ?></b> (<?= e(show_size_text($p['crop'], (float)$p['size'])) ?>)</li><?php endforeach; ?>
  </ul></div>
<?php endif; ?>
<p><a href="<?= e(url('games.php?tab=contests')) ?>">← Contests</a></p>
<?php page_footer();
