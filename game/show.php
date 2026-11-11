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
<div data-ptabs>
<nav class="chtabs" role="tablist" aria-label="Show classes"><button type="button" role="tab" class="on" aria-selected="true" data-ptab="crop">🏅 <?= e($name) ?></button><button type="button" role="tab" aria-selected="false" data-ptab="arrangements">💐 Arrangements</button><button type="button" role="tab" aria-selected="false" data-ptab="past">📜 Hall of fame</button></nav>
<div class="ppanel" data-ppanel="crop" id="crop">
  <div class="hero">
    <span class="herobig" aria-hidden="true">🏅</span><h2><?= e($name) ?></h2>
    <p class="help">Grow and harvest <b><?= e($plantName) ?></b>. Your best is entered for you. Judging in <?= nice_time(job_period_left('weekly')) ?>.</p>
    <p class="heropills"><span class="tag">Your best: <?= $mine ? e(show_size_text($crop, (float)$mine['size'])) : 'not entered yet' ?></span></p>
  </div>
  <?php if ($board): $mark = fn($b) => !$b['npc'] && (int)$b['user_id'] === $uid; $podium = array_slice($board, 0, 3); $restRows = array_slice($board, 3); ?>
    <div class="podium"><?php foreach ([1, 0, 2] as $k): if (!isset($podium[$k])) continue; $b = $podium[$k]; ?>
      <div class="pod p<?= $k + 1 ?><?= $mark($b) ? ' here' : '' ?>"><i aria-hidden="true"><?= ['🥇', '🥈', '🥉'][$k] ?></i><b><?= e($b['gname']) ?></b><?= $b['npc'] ? townsfolk_tag() : '' ?><small><?= e(show_size_text($crop, (float)$b['size'])) ?></small></div>
    <?php endforeach; ?></div>
    <?php if ($restRows): ?><ol class="podrest" start="4"><?php foreach ($restRows as $i => $b): ?>
      <li<?= $mark($b) ? ' class="here"' : '' ?>><i><?= $i + 4 ?></i><span><?= e($b['gname']) ?><?= $b['npc'] ? ' ' . townsfolk_tag() : '' ?></span><b><?= e(show_size_text($crop, (float)$b['size'])) ?></b></li>
    <?php endforeach; ?></ol><?php endif; ?>
    <?php if (array_filter($board, fn($b) => $b['npc'])) echo townsfolk_note(); ?>
    <p class="help">🥇 <?= money(SHOW_PRIZES[1][0]) ?> and a rare seed · 🥈 <?= money(SHOW_PRIZES[2][0]) ?> · 🥉 <?= money(SHOW_PRIZES[3][0]) ?> · the top three get a 🎀.</p>
  <?php else: ?><p class="muted">No entries yet. Be the first!</p><?php endif; ?>
</div>
<?php
$arrMine = q_one('SELECT * FROM arrangement_entries WHERE week = ? AND user_id = ?', [$week, $uid]);
$owned = arrangements_owned($uid);
$leaders = array_slice(townsfolk_merge(arrangement_leaders($week, 5), townsfolk_arrangements($week), 'score'), 0, 7);   // v1.0.0: townsfolk show too (never judged, never paid)
$arrPrev = arrangement_leaders(job_period_key('weekly', time() - 7 * 86400), 3);
?>
<section class="box ppanel" data-ppanel="arrangements" id="arrangements" hidden>
  <h2>💐 Arrangements</h2>
  <p class="help">One flower arrangement each, judged with the crop at the end of the week. The one you enter <b>stays at the show</b>, and a better one swaps in (the old one comes home). Top three: <?= money($pzR[0]) ?>, <?= money($pzR[1]) ?> and <?= money($pzR[2]) ?> and a ribbon.</p>
  <?php if ($arrMine): ?><p>Your entry: <b>“<?= e($arrMine['title']) ?>”</b>, <?= (int)$arrMine['score'] ?>/100</p><?php endif; ?>
  <?php if (!$owned): ?><p class="muted">You have no arrangements. <a href="<?= e(url('inventory.php?tab=arrange')) ?>">Make one in your Satchel</a>.</p>
  <?php else: ?>
  <div class="arrowned">
    <?php foreach ($owned as $a): $better = !$arrMine || (int)$a['arr']['score'] > (int)$arrMine['score']; ?>
      <form method="post" action="<?= e(url('show.php')) ?>" class="arrcard" data-noajax><?= csrf_field() ?><input type="hidden" name="do" value="enter_arr"><input type="hidden" name="item_id" value="<?= (int)$a['id'] ?>">
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
  
</section>
<div class="ppanel" data-ppanel="past" id="past" hidden>
<?php if ($past): ?>
  <div class="box"><h3>Past champions</h3><ol class="podrest pastlist">
    <?php foreach ($past as $p): ?><li><i aria-hidden="true">🏅</i><span><b><?= e($p['gname']) ?></b> <small class="muted"><?= e($p['week']) ?> · <?= e(SHOW_CROPS[$p['crop']][0] ?? $p['crop']) ?></small></span><b><?= e(show_size_text($p['crop'], (float)$p['size'])) ?></b></li><?php endforeach; ?>
  </ol></div>
<?php else: ?><p class="muted">No champions yet. The first judging is coming.</p><?php endif; ?>
<?php if ($arrPrev): ?><div class="box"><h3>Last week’s arrangement winners</h3><ol class="podrest pastlist"><?php foreach ($arrPrev as $i => $l): ?><li><i aria-hidden="true"><?= ['🥇', '🥈', '🥉'][$i] ?? '' ?></i><span><b><?= e($l['gname']) ?></b> <small class="muted">“<?= e($l['title']) ?>”</small></span><b><?= (int)$l['score'] ?></b></li><?php endforeach; ?></ol></div><?php endif; ?>
</div>
</div>
<p><a href="<?= e(url('games.php?tab=contests')) ?>">← Contests</a></p>
<?php page_footer();
