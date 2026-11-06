<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/contests.php';
require_once __DIR__ . '/includes/games.php';   // v1.4.1: game tabs
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/flowers.php';   // T2.1: the Arrangements show is the second class on this page (it was arrange.php?t=show)
$u = require_login();
$uid = (int)$u['id'];
settle_shows();
settle_arrangements();
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'enter_arr' || $do === 'enter') {   // 'enter' = an old arrange.php form, sent on by the arrange.php stub
        [$ok, $msg] = arrangement_enter($u, (int)($_POST['item_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    }
    redirect('show.php#arrangements');
}
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
<?php $pzR = arr_prizes();
if (game_tab() === 'rules'):   // v1.4.1
    echo game_rules_html([
        ['🎯', 'Goal.', 'Grow the biggest one of the week’s crop. The crop changes every week.'],
        ['📏', 'Entering.', 'Nothing to press. Each one you harvest is measured, and your best is entered for you.'],
        ['🌱', 'Growing big.', 'Rich soil, the crop’s own nutrient, healthy soil life and a good soil grade all help. So does a little luck.'],
        ['⏳', 'Judging.', 'At the end of the week, when the weekly reset comes.'],
        ['🥇', 'Prizes.', '1st ' . money(SHOW_PRIZES[1][0]) . ' and a rare seed, 2nd ' . money(SHOW_PRIZES[2][0]) . ', 3rd ' . money(SHOW_PRIZES[3][0]) . '. The top three also get a 🎀 ribbon.'],
        ['🎁', 'Everyone else.', 'Anyone who enters gets ' . money(25) . ' for taking part.'],
        ['🌙', 'Quiet weeks.', 'If fewer than ' . max(1, (int)setting('fair_min_entries')) . ' gnomes entered, nobody is placed: every entrant gets ' . money(SHOW_QUIET_COINS) . ' and ' . SHOW_QUIET_XP . ' XP for taking part.'],
        ['💐', 'Arrangements class.', 'Enter one flower arrangement a week (make them in Satchel → Arrange). A better one swaps in and the old one comes home. Top three: '
            . money($pzR[0]) . ', ' . money($pzR[1]) . ' and ' . money($pzR[2]) . ' and a 🎀 ribbon; everyone else ' . money($pzR[3]) . '. Quiet weeks work the same way (' . money(ARR_QUIET_COINS) . ' and ' . ARR_QUIET_XP . ' XP).'],
    ]);
    echo '<p><a href="' . e(url('games.php?tab=contests')) . '">← Contests</a></p>';
    page_footer(); return;
endif; ?>
<nav class="chips" aria-label="Show classes"><a href="#crop">🏅 <?= e($name) ?></a> <a href="#arrangements">💐 Arrangements</a></nav>
<div class="box" id="crop">
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
<?php
$arrMine = q_one('SELECT * FROM arrangement_entries WHERE week = ? AND user_id = ?', [$week, $uid]);
$owned = arrangements_owned($uid);
$leaders = array_slice(townsfolk_merge(arrangement_leaders($week, 5), townsfolk_arrangements($week), 'score'), 0, 7);   // v1.0.0: townsfolk show too (never judged, never paid)
$arrPrev = arrangement_leaders(job_period_key('weekly', time() - 7 * 86400), 3);
?>
<section class="box" id="arrangements">
  <h2>💐 Arrangements</h2>
  <p class="help">One flower arrangement each, judged with the crop at the end of the week. The one you enter <b>stays at the show</b>, and a better one swaps in (the old one comes home). Top three: <?= money($pzR[0]) ?>, <?= money($pzR[1]) ?> and <?= money($pzR[2]) ?> and a ribbon.</p>
  <?php if ($arrMine): ?><p>Your entry: <b>“<?= e($arrMine['title']) ?>”</b>, <?= (int)$arrMine['score'] ?>/100</p><?php endif; ?>
  <?php if (!$owned): ?><p class="muted">You have no arrangements. <a href="<?= e(url('inventory.php?tab=arrange')) ?>">Make one in your Satchel</a>.</p>
  <?php else: ?>
  <div class="arrowned">
    <?php foreach ($owned as $a): $better = !$arrMine || (int)$a['arr']['score'] > (int)$arrMine['score']; ?>
      <form method="post" action="<?= e(url('show.php')) ?>" class="arrcard"><?= csrf_field() ?><input type="hidden" name="do" value="enter_arr"><input type="hidden" name="item_id" value="<?= (int)$a['id'] ?>">
        <?= arrangement_svg($a['arr'], 'lg', $a['name']) ?><b><?= e($a['name']) ?></b><small><?= (int)$a['arr']['score'] ?>/100 · <?= (int)$a['qty'] ?> held</small>
        <button class="btn small" <?= $better ? '' : 'disabled' ?>><?= $arrMine ? ($better ? 'Swap it in' : 'Not better') : 'Enter it' ?></button></form>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>
  <h3>This week’s leaders</h3>
  <?php if (!$leaders): ?><p class="muted">No entries yet. Be the first!</p>
  <?php else: ?><ol class="arrleaders"><?php foreach ($leaders as $l): ?>
    <li><?= $l['npc'] ? '<span class="tficon sm" aria-hidden="true">🏡</span>' : arrangement_svg(json_decode((string)$l['comp'], true) ?: [], 'md', $l['title']) ?> <span><b><?= e($l['gname']) ?></b><?= $l['npc'] ? ' ' . townsfolk_tag() : '' ?>: “<?= e($l['title']) ?>”, <?= (int)$l['score'] ?>/100</span></li>
  <?php endforeach; ?></ol>
  <?php if (array_filter($leaders, fn($l) => $l['npc'])) echo townsfolk_note(); ?><?php endif; ?>
  <?php if ($arrPrev): ?><h3>Last week’s winners</h3><ul><?php foreach ($arrPrev as $i => $l): ?><li><?= ['🥇', '🥈', '🥉'][$i] ?? '' ?> <?= e($l['gname']) ?>: “<?= e($l['title']) ?>” (<?= (int)$l['score'] ?>)</li><?php endforeach; ?></ul><?php endif; ?>
</section>
<?php if ($past): ?>
  <div class="box"><h3>Past champions</h3><ul>
    <?php foreach ($past as $p): ?><li><?= e($p['week']) ?> · <?= e(SHOW_CROPS[$p['crop']][0] ?? $p['crop']) ?>: <b><?= e($p['gname']) ?></b> (<?= e(show_size_text($p['crop'], (float)$p['size'])) ?>)</li><?php endforeach; ?>
  </ul></div>
<?php endif; ?>
<p><a href="<?= e(url('games.php?tab=contests')) ?>">← Contests</a></p>
<?php page_footer();
