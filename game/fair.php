<?php declare(strict_types=1); require __DIR__ . '/includes/bootstrap.php'; require_once __DIR__ . '/includes/garden_logic.php'; require_once __DIR__ . '/includes/games.php'; require_once __DIR__ . '/includes/fair.php'; require_once __DIR__ . '/includes/townsfolk.php'; $u = require_login(); $uid = (int)$u['id'];

settle_fair();

if (is_post()) {
    csrf_check();
    if (($_POST['do'] ?? '') === 'enter') {
        [$ok, $msg] = fair_enter($u, (string)($_POST['cat'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    }
    redirect('fair.php');
}

$month = job_period_key('monthly');
$prev = fair_prev_month();
$inPlay = fair_in_play($uid);

// Last month's winners, grouped by class.
$wins = [];
foreach (q('SELECT r.cat, r.place, COALESCE(u.gnome_name, u.username) AS gname FROM fair_ribbons r JOIN users u ON u.id = r.user_id
            WHERE r.month = ? ORDER BY r.cat, r.place', [$prev])->fetchAll() as $w) {
    $wins[$w['cat']][] = $w;
}

page_header('Grand Harvest Fair');
?>
<h1>🏆 Grand Harvest Fair</h1>
<p class="help"><a href="<?= e(url('games.php?tab=contests')) ?>">← Contests</a></p>
<?= game_tabs_html('fair.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    $fm = max(1, (int)setting('fair_min_entries'));
    echo game_rules_html([
        ['🎯', 'Goal.', 'Grow the best crop in each class. The best of all wins Best in Show.'],
        ['🌽', 'Classes.', implode(', ', array_map(fn($c) => $c[1], FAIR_CATS)) . '. Produce is every vegetable, fruit, grain and herb.'],
        ['⭐', 'Judging.', 'Every harvest is judged for quality, and your best in each class is kept for the month.'],
        ['🫙', 'Preserves.', 'Judged on jars from your Pantry. The longer the ferment, the better the score.'],
        ['📝', 'Entering.', 'Press “Enter it” to put your best in the fair. You can swap in a better one before the month ends. It is free.'],
        ['🥇', 'Prizes.', 'Top three in each class: ' . money((int)setting('fair_prize_1')) . ', ' . money((int)setting('fair_prize_2')) . ' and ' . money((int)setting('fair_prize_3')) . ', plus a 🎀 ribbon.'],
        ['👑', 'Best in Show.', money((int)setting('fair_best_in_show')) . ' and the title “Fair Champion”, if you do not have a title yet.'],
        $fm > 1 ? ['👥', 'Small classes.', 'A class with fewer than ' . $fm . ' gnomes pays half prizes, and Best in Show needs ' . $fm . ' gnomes in the fair.'] : null,
    ]);
    echo '<p><a href="' . e(url('games.php?tab=contests')) . '">← Contests</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Enter your best crop in each class. Judging in <?= nice_time(job_period_left('monthly')) ?>.</p>
<?php if (!$inPlay): ?><p class="help">You are in a time-out, so you can look but not enter this month.</p><?php endif; ?>

<?php $tiles = ""; $sheets = "";
foreach (FAIR_CATS as $key => [$icon, $label]):
    $mine = q_one('SELECT b.score, COALESCE(p.name, b.label) AS crop FROM fair_best b LEFT JOIN plants p ON p.id = b.plant_id
                   WHERE b.user_id = ? AND b.month = ? AND b.cat = ?', [$uid, $month, $key]);
    $entry = q_one('SELECT e.score, COALESCE(p.name, e.label) AS crop FROM fair_entries e LEFT JOIN plants p ON p.id = e.plant_id
                    WHERE e.user_id = ? AND e.month = ? AND e.cat = ?', [$uid, $month, $key]);
    $top = q('SELECT e.score, COALESCE(p.name, e.label) AS crop, COALESCE(u.gnome_name, u.username) AS gname FROM fair_entries e
              JOIN users u ON u.id = e.user_id LEFT JOIN plants p ON p.id = e.plant_id
              WHERE e.month = ? AND e.cat = ? AND ' . gnome_in_play_sql('u') . ' ORDER BY e.score DESC, e.at, e.id LIMIT 3', [$month, $key])->fetchAll();
    $top = townsfolk_merge($top, townsfolk_fair($month, $key), 'score');   // v1.0.0: townsfolk enter too (never judged, never paid)
    $canEnter = $inPlay && $mine && (!$entry || (int)$mine['score'] > (int)$entry['score']);
ob_start(); ?>
<dialog class="picker fairsheet" id="fs-<?= e($key) ?>" aria-label="<?= e($label) ?>"><div class="pickbox">
  <div class="pickhead"><h3><?= $icon ?> <?= e($label) ?></h3><button type="button" class="pickx" data-closedlg aria-label="Close">✕</button></div>
  <div class="fsbody">
  <?php if ($mine): ?>
    <p>Your best: <b><?= e($mine['crop'] ?? 'a crop') ?></b>, <?= e(fair_word((int)$mine['score'])) ?> <?= (int)$mine['score'] ?></p>
  <?php else: ?>
    <p class="muted"><?= $key === 'preserve' ? 'No jar collected yet this month. Fill a jar in your 🫙 Pantry, wait for it, and collect it.' : 'No harvest yet this month. ' . ($key === 'produce' ? 'Grow any vegetable, fruit, grain or herb and harvest it.' : 'Harvest one to see it here.') ?></p>
  <?php endif; ?>
  <?php if ($entry): ?><p class="help">In the fair: <?= e($entry['crop'] ?? 'a crop') ?>, <?= e(fair_word((int)$entry['score'])) ?> <?= (int)$entry['score'] ?></p><?php endif; ?>
  <?php if ($canEnter): ?>
    <form method="post" action="<?= e(url('fair.php')) ?>"><?= csrf_field() ?>
      <input type="hidden" name="do" value="enter"><input type="hidden" name="cat" value="<?= e($key) ?>">
      <button class="btn" type="submit"><?= $entry ? 'Swap in the better one' : 'Enter it' ?></button>
    </form>
  <?php endif; ?>
  <?php if ($top): $mk = ['🥇', '🥈', '🥉']; ?>
    <h4>This month’s leaders</h4>
    <ol class="podrest"><?php foreach ($top as $i => $t): ?>
      <li><i aria-hidden="true"><?= $mk[$i] ?></i><span><b><?= e($t['gname']) ?></b><?= $t['npc'] ? ' ' . townsfolk_tag() : '' ?> <small class="muted"><?= e($t['crop'] ?? 'a crop') ?>, <?= e(fair_word((int)$t['score'])) ?></small></span><b><?= (int)$t['score'] ?></b></li>
    <?php endforeach; ?></ol>
    <?php if (array_filter($top, fn($t) => $t['npc'])) echo townsfolk_note(); ?>
  <?php else: ?><p class="muted">No entries yet. Be the first!</p><?php endif; ?>
  </div>
</div></dialog>
<?php $sheets .= ob_get_clean();
    $state = $entry ? ['✔ Entered', 'cin'] : ($canEnter ? ['Ready to enter', 'ready'] : ['Not yet', 'cout']);
    $tiles .= '<button type="button" class="chsq' . ($entry ? ' in' : '') . '" data-opendlg="fs-' . e($key) . '"><span class="chsi" aria-hidden="true">' . $icon . '</span><b>' . e($label) . '</b>'
        . '<small>' . ($mine ? e(fair_word((int)$mine['score'])) . ' ' . (int)$mine['score'] : 'No harvest yet') . '</small><span class="tag ' . $state[1] . '">' . $state[0] . '</span>'
        . '<em>' . ($top ? '🥇 ' . e((string)$top[0]['gname']) : 'No entries yet') . '</em></button>';
endforeach; ?>
<div class="chsqs fairsqs"><?= $tiles ?></div>
<?= $sheets ?>

<details class="fold box"><summary>🏅 Last month’s winners</summary>
  <?php if ($wins): ?>
    <ul>
      <?php foreach ($wins as $cat => $list): ?>
        <?php foreach ($list as $w): ?>
          <li><?= fair_medal((int)$w['place'], (string)$cat) ?> <?= e(fair_cat_label((string)$cat)) ?>: <b><?= e($w['gname']) ?></b></li>
        <?php endforeach; ?>
      <?php endforeach; ?>
    </ul>
  <?php else: ?>
    <p class="muted">No winners were recorded for <?= e($prev) ?>.</p>
  <?php endif; ?>
</details>

<p><a href="<?= e(url('games.php?tab=contests')) ?>">← Contests</a></p>
<?php page_footer();
