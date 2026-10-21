<?php
declare(strict_types=1);
/** Garden of the Month (v0.7.35): enter a garden, vote for others, the top three win at month's end. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/yard.php';
require_once __DIR__ . '/includes/catalog.php';
require_once __DIR__ . '/includes/games.php';   // v1.4.1: game tabs
$u = require_login();
$uid = (int)$u['id'];
settle_gotm();

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'enter') {
        [$ok, $msg] = gotm_enter($u, (int)($_POST['plot_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'vote') {
        [$ok, $msg] = gotm_vote($u, (int)($_POST['entry'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    }
    redirect('gotm.php');
}

$month = gotm_month();
$entries = q('SELECT e.*, p.garden_name, u.gnome_name, u.username, u.id AS uid FROM gotm_entries e
              JOIN plots p ON p.id = e.plot_id JOIN users u ON u.id = e.user_id
              WHERE e.month = ? AND u.deleted_at IS NULL AND u.garden_public = 1 AND ' . gnome_in_play_sql('u') . ' ORDER BY e.votes DESC, e.entered_at', [$month])->fetchAll();
require_once __DIR__ . '/includes/townsfolk.php';   // v1.0.0: townsfolk gardens keep the race company (never voted on, never paid)
$entries = townsfolk_merge($entries, townsfolk_gotm($month, $entries ? (int)max(array_column($entries, 'votes')) : 0), 'votes');
// v1.4.7: players' gardens first, townsfolk gardens underneath (each keeps its own order)
usort($entries, fn($a, $b) => (int)!empty($a['npc']) <=> (int)!empty($b['npc']));
$myVotes = array_flip(array_map('intval', q('SELECT entry_id FROM gotm_votes WHERE user_id = ? AND month = ?', [$uid, $month])->fetchAll(PDO::FETCH_COLUMN)));
$myEntry = q_one('SELECT * FROM gotm_entries WHERE user_id = ? AND month = ?', [$uid, $month]);
$block = gotm_vote_block($u);
$left = gotm_votes_left($u);
$last = q("SELECT e.*, p.garden_name, u.gnome_name, u.username, u.id AS uid FROM gotm_entries e LEFT JOIN plots p ON p.id = e.plot_id
           JOIN users u ON u.id = e.user_id WHERE e.placed BETWEEN 1 AND 3 AND e.month = (SELECT MAX(month) FROM gotm_entries WHERE placed IS NOT NULL)
           AND " . gnome_in_play_sql('u') . " ORDER BY e.placed")->fetchAll();
$wander = q('SELECT p.id, p.garden_name, p.appeal, u.id AS uid, u.gnome_name, u.username FROM plots p JOIN users u ON u.id = p.user_id
             WHERE u.garden_public = 1 AND u.deleted_at IS NULL AND ' . gnome_in_play_sql('u') . ' AND p.user_id <> ? AND p.appeal > 0 ORDER BY p.appeal DESC, p.id DESC LIMIT 40', [$uid])->fetchAll();
shuffle($wander);
$wander = array_slice($wander, 0, 8);
$daysLeft = (int)hollow_date('t') - (int)hollow_date('j');
$mini = function (int $plotId, int $ownerId): string {
    [$plot, $tiles, $plants] = load_plot($ownerId, true, $plotId);
    return render_yard($plot, $tiles, $plants, yard_objects($plotId), 'mini');
};
page_header('Garden of the Month');
?>
<h1>🏆 Garden of the Month</h1>
<p class="help"><a href="<?= e(url('games.php?tab=contests')) ?>">← Contests</a></p>
<?= game_tabs_html('gotm.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    $gp = array_slice(array_map('intval', explode(',', setting('gotm_prizes'))), 0, 3);
    echo game_rules_html([
        ['🎯', 'Goal.', 'Show off your garden. The three with the most votes win.'],
        ['🌼', 'Entering.', 'One garden a month, with a curb appeal of ' . (int)setting('gotm_min_appeal') . ' or more. Your gardens must be open to visitors.'],
        ['✏️', 'Curb appeal.', 'Decorate with ✏️ Design yard on your garden page.'],
        ['🗳️', 'Voting.', 'You get ' . (int)setting('gotm_votes') . ' votes a month, one per garden, never your own. Voting opens at gnome level ' . (int)setting('gotm_vote_level') . '.'],
        ['🏆', 'Prizes.', 'Top three: ' . implode(', ', array_map(fn($n) => number_format($n), $gp)) . ' ' . setting('currency_name') . ' and a 🎀 ribbon.'],
        ['🎁', 'Everyone else.', 'Entries with at least one vote get ' . money((int)setting('gotm_thanks')) . '.'],
        ['⚖️', 'Ties.', 'The higher curb appeal wins.'],
        ['🕐', 'Results.', 'When the month ends, Hollow time.'],
    ]);
    echo '<p><a href="' . e(url('games.php?tab=contests')) . '">← Contests</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Enter a garden and vote for your favourites. The month ends in <?= $daysLeft ?> day<?= $daysLeft === 1 ? '' : 's' ?>.</p>

<div class="box">
  <?php if ($myEntry): ?>
    <p>✅ You’ve entered <b><?= e((string)q_val('SELECT garden_name FROM plots WHERE id = ?', [$myEntry['plot_id']]) ?: 'your garden') ?></b> this month: <?= (int)$myEntry['votes'] ?> vote<?= (int)$myEntry['votes'] === 1 ? '' : 's' ?> so far.</p>
  <?php elseif ((int)$u['garden_public'] !== 1): ?>
    <p class="help">Your gardens are private, so you can’t enter. You can open them to visitors on the <a href="<?= e(url('account.php')) ?>">Account</a> page.</p>
  <?php else: ?>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="enter">
      <label>Enter a garden <select name="plot_id"><?php foreach (user_gardens($uid) as $g): $ap = yard_appeal((int)$g['id']); ?>
        <option value="<?= (int)$g['id'] ?>"><?= e(($g['garden_name'] ?: 'Garden') . ' · appeal ' . $ap) ?></option><?php endforeach; ?></select></label>
      <button class="btn small">🏆 Enter</button></form>
    <p class="help">Gardens need a curb appeal of <?= (int)setting('gotm_min_appeal') ?> or more. Decorate with ✏️ Design yard on your garden page.</p>
  <?php endif; ?>
  <p class="help"><?= $block ? e($block) : '🗳️ You have ' . $left . ' of ' . (int)setting('gotm_votes') . ' votes left this month (one per garden).' ?></p>
</div>

<h2>This month’s gardens (<?= count(array_filter($entries, fn($x) => !$x['npc'])) ?>)</h2>
<?php if (!array_filter($entries, fn($x) => !$x['npc'])): ?><p class="muted">No gardens entered yet. Be the first!</p><?php endif; ?>
<div class="gardencards">
<?php foreach ($entries as $e): if ($e['npc']): ?>
  <div class="box gardencard tfcard">
    <div class="tficon" aria-hidden="true"><?= e($e['icon']) ?>🏡</div>
    <h3><?= eu($e['garden_name']) ?></h3>
    <p class="help">by <?= e($e['owner']) ?> <?= townsfolk_tag() ?> · 🗳️ <?= (int)$e['votes'] ?> · 🌼 <?= (int)$e['appeal'] ?></p>
  </div>
<?php continue; endif; $mineE = (int)$e['uid'] === $uid; ?>
  <div class="box gardencard">
    <a href="<?= e(url('visit.php?g=' . (int)$e['plot_id'])) ?>"><div class="yardwrap"><?= $mini((int)$e['plot_id'], (int)$e['uid']) ?></div></a>
    <h3><a href="<?= e(url('visit.php?g=' . (int)$e['plot_id'])) ?>"><?= eu($e['garden_name'] ?: 'Garden') ?></a></h3>
    <p class="help">by <?= profile_link(['id' => $e['uid'], 'gnome_name' => $e['gnome_name'], 'username' => $e['username']]) ?> · 🗳️ <?= (int)$e['votes'] ?></p>
    <?php if (isset($myVotes[(int)$e['id']])): ?><p class="good">You voted for this one.</p>
    <?php elseif (!$mineE && !$block && $left > 0): ?>
      <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="vote"><input type="hidden" name="entry" value="<?= (int)$e['id'] ?>">
        <button class="btn small">🗳️ Vote</button></form>
    <?php endif; ?>
  </div>
<?php endforeach; ?>
</div>
<?php if (array_filter($entries, fn($x) => $x['npc'])) echo townsfolk_note(); ?>

<?php if ($last): ?>
  <h2>Last winners (<?= e($last[0]['month']) ?>)</h2>
  <ul><?php foreach ($last as $w): ?>
    <li><?= ['', '🥇', '🥈', '🥉'][(int)$w['placed']] ?> <?= $w['garden_name'] !== null ? '<a href="' . e(url('visit.php?g=' . (int)$w['plot_id'])) . '">' . eu($w['garden_name'] ?: 'Garden') . '</a>' : 'a garden' ?>
      by <?= profile_link(['id' => $w['uid'], 'gnome_name' => $w['gnome_name'], 'username' => $w['username']]) ?> (<?= (int)$w['votes'] ?> votes)</li>
  <?php endforeach; ?></ul>
<?php endif; ?>

<?php if ($wander): ?>
  <h2>Wander the lanes</h2>
  <p class="help">Some gardens to peek into. Admire the ones you like: their gardeners will hear about it.</p>
  <ul class="lanes"><?php foreach ($wander as $w): ?>
    <li><a href="<?= e(url('visit.php?g=' . (int)$w['id'])) ?>"><?= eu($w['garden_name'] ?: 'Garden') ?></a> by <?= profile_link(['id' => $w['uid'], 'gnome_name' => $w['gnome_name'], 'username' => $w['username']]) ?>
      <small class="muted">· 🌼 <?= (int)$w['appeal'] ?></small></li>
  <?php endforeach; ?></ul>
<?php endif; ?>
<?php page_footer();
