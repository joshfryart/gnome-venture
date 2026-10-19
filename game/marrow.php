<?php
declare(strict_types=1);
/** Guess the Giant Marrow (v0.7.31): a daily guessing game for the whole Hollow. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
$u = require_login();
$uid = (int)$u['id'];
settle_marrows();
if (is_post()) {
    csrf_check();
    [$ok, $msg] = marrow_guess($u, (float)str_replace(',', '.', (string)($_POST['kg'] ?? '0')));
    flash($msg, $ok ? 'ok' : 'err');
    redirect('marrow.php');
}
$day = game_day();
[$crop, $cropIcon] = marrow_crop($day);
$mine = q_val('SELECT grams FROM marrow_guesses WHERE user_id = ? AND day = ?', [$uid, $day]);
$count = (int)q_val('SELECT COUNT(*) FROM marrow_guesses WHERE day = ?', [$day]);
$last = q_one('SELECT day FROM marrow_guesses WHERE day <> ? ORDER BY day DESC LIMIT 1', [$day]);
$lastExact = $last ? q("SELECT COALESCE(u.gnome_name, u.username) AS name FROM marrow_guesses g JOIN users u ON u.id = g.user_id
                        WHERE g.day = ? AND g.grams = ?", [$last['day'], marrow_weight($last['day'])])->fetchAll(PDO::FETCH_COLUMN) : [];
$lastClose = $last ? q_one("SELECT g.grams, COALESCE(u.gnome_name, u.username) AS name FROM marrow_guesses g JOIN users u ON u.id = g.user_id
                           WHERE g.day = ? AND g.placed = 1", [$last['day']]) : null;
$block = marrow_block($u);
// v1.4.7: render-only extras for the new look (how you did last time, and the last few weights)
$lastMine = $last ? q_val('SELECT grams FROM marrow_guesses WHERE user_id = ? AND day = ?', [$uid, $last['day']]) : null;
$recent = [];
foreach (q('SELECT DISTINCT day FROM marrow_guesses WHERE day <> ? ORDER BY day DESC LIMIT 6', [$day])->fetchAll(PDO::FETCH_COLUMN) as $d) {
    if ($last && $d === $last['day']) continue;
    $w = marrow_weight((string)$d);
    $recent[] = [$d, marrow_crop((string)$d)[1], $w, (int)q_val('SELECT COUNT(*) FROM marrow_guesses WHERE day = ? AND grams = ?', [$d, $w])];
}
page_header('Guess the Weight');
?>
<h1>⚖️ Guess the Weight</h1>
<?= game_tabs_html('marrow.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    $cp = (int)setting('marrow_close_prize');
    echo game_rules_html([
        ((int)setting('games_energy_cap') > 0 ? ['⚡', 'Energy.', 'Each guess gives you +1 energy' . ((int)setting('games_energy_cap') >= 100 ? '.' : ' (up to ' . (int)setting('games_energy_cap') . ' a day from games).')] : null),   // v1.4.7
        ['🎯', 'Goal.', 'Old Moss puts something enormous on the scales each day. Guess its weight to the nearest 0.1 kg.'],
        ['🔍', 'Clues.', 'You see the crop, roughly how wide it is and how plump. It weighs between 8 and 40 kg.'],
        ['💰', 'Jackpot.', 'Only an exact guess wins it, shared if more than one gnome is exact. Now ' . money(marrow_pot()) . '.'],
        ['📈', 'No exact guess?', 'The jackpot grows by ' . money((int)setting('marrow_jackpot_grow')) . ' (up to ' . money((int)setting('marrow_jackpot_max')) . ')' . ($cp ? ' and the closest guess gets ' . money($cp) . '.' : '.')],
        ['🔁', 'Daily limit.', (int)setting('marrow_guesses_per_day') . ' guess a day. Results come after the daily reset, as a message.'],
        ['🔑', 'Who can guess.', 'Gnome level ' . (int)setting('marrow_min_level') . ' or more' . ((int)setting('marrow_min_days') > 0 ? ', and ' . (int)setting('marrow_min_days') . ' days in the Hollow.' : '.')],
        (int)setting('games_energy_cap') > 0 ? ['⚡', 'Energy.', 'Making your guess gives you +1 energy' . ((int)setting('games_energy_cap') >= 100 ? '.' : ' (up to ' . (int)setting('games_energy_cap') . ' a day from games).')] : null,
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Guess today’s giant crop to the nearest 0.1 kg. Results in <?= nice_time(job_period_left('daily')) ?>.</p>
<?php /* v1.4.7: fair-stall look. The scale art is inline SVG (includes/games.php), the slider and needle swing are in assets/marrow.js. The server still takes and settles every guess. */ ?>
<div class="gmchips" role="status">
  <span class="gmchip gold">💰 Jackpot <b><?= money(marrow_pot()) ?></b></span>
  <span class="gmchip">👥 <b><?= $count ?></b> guessed</span>
  <span class="gmchip">⚖️ <b>8 to 40</b> kg</span>
</div>
<div class="box marrowbox" data-day="<?= e($day) ?>">
  <h2>Today: a giant <?= e($crop) ?></h2>
  <?= marrow_scale_html($cropIcon, null, $mine ? [['you', (int)$mine, 'Your guess']] : [], 'today') ?>
  <p class="mhint"><?= e(marrow_hint($day)) ?></p>
  <?php if ($mine): ?>
    <p class="gmine">Your guess: <b><?= number_format((int)$mine / 1000, 1) ?> kg</b>. Fingers crossed!</p>
  <?php elseif ($block): ?>
    <p class="muted"><?= e($block) ?></p>
  <?php else: ?>
    <form method="post" class="guessform"><?= csrf_field() ?>
      <label class="gguess">My guess <span class="gnum"><input name="kg" type="number" min="8" max="40" step="0.1" required inputmode="decimal" placeholder="24.0"> <span class="gkg">kg</span></span></label>
      <button class="btn mgo">Write it on the board</button>
    </form>
  <?php endif; ?>
</div>
<?php if ($last): [$lc, $lcIcon] = marrow_crop($last['day']); $lw = marrow_weight($last['day']);
    $marks = [];
    if ($lastMine !== null && $lastMine !== false) $marks[] = ['you', (int)$lastMine, 'You: ' . number_format((int)$lastMine / 1000, 1) . ' kg'];
    if (!$lastExact && $lastClose && (!$marks || (int)$lastClose['grams'] !== (int)$lastMine)) $marks[] = ['near', (int)$lastClose['grams'], 'Closest: ' . number_format((int)$lastClose['grams'] / 1000, 1) . ' kg']; ?>
  <div class="box marrowlast" data-day="<?= e($last['day']) ?>"><h3>Last time (<?= e($last['day']) ?>): the giant <?= e($lc) ?> weighed <?= number_format($lw / 1000, 1) ?> kg</h3>
    <div class="mlrow">
      <?= marrow_scale_html($lcIcon, $lw, $marks, 'past') ?>
      <div class="mlinfo">
        <p class="gmchips left"><span class="gmchip real">📏 Real weight <b><?= number_format($lw / 1000, 1) ?> kg</b></span>
          <?php if ($lastMine !== null && $lastMine !== false): ?><span class="gmchip you">You <b><?= number_format((int)$lastMine / 1000, 1) ?> kg</b></span><?php endif; ?>
          <?php if (!$lastExact && $lastClose): ?><span class="gmchip near">🎯 Closest <b><?= number_format((int)$lastClose['grams'] / 1000, 1) ?> kg</b> <?= e($lastClose['name']) ?></span><?php endif; ?></p>
        <?php if ($lastExact): ?><p>🎉 Guessed exactly by <b><?= e(implode(', ', $lastExact)) ?></b>!</p>
        <?php else: ?><p class="muted">Nobody guessed it exactly<?= $lastClose ? '. Closest: ' . e($lastClose['name']) . ' with ' . number_format((int)$lastClose['grams'] / 1000, 1) . ' kg' : '' ?>.</p><?php endif; ?>
        <button type="button" class="btn alt small marrowreplay" hidden>▶ Weigh again</button>
      </div>
    </div>
    <?php if ($recent): ?><p class="gmchips left recentw" aria-label="Earlier weights"><?php foreach ($recent as [$rd, $ri, $rw, $rx]): ?><span class="gmchip" title="<?= e($rd) ?>"><?= $ri ?> <b><?= number_format($rw / 1000, 1) ?> kg</b><?= $rx ? ' 🎉' : '' ?> <small class="muted"><?= e($rd) ?></small></span><?php endforeach; ?></p><?php endif; ?>
  </div>
<?php endif; ?>
<p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
<?php page_footer();
