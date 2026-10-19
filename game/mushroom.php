<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
require_once __DIR__ . '/includes/mushroom.php';
$u = require_login();
$uid = (int)$u['id'];

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = match ($do) {
        'start' => mush_start($u),
        'pick' => mush_pick($u, (int)($_POST['cell'] ?? -1)),
        'flag' => mush_flag($u, (int)($_POST['cell'] ?? -1)),
        'mode' => mush_mode($u, (string)($_POST['mode'] ?? '')),
        'stop' => mush_stop($u),
        default => [false, 'Unknown action.'],
    };
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('mushroom.php');
}

$s = game_state($uid, 'mushroom');
$last = $s ? null : ($_SESSION['mush_last'] ?? null);   // the last round's board, shown once
unset($_SESSION['mush_last']);
$n = MUSH_SIZE * MUSH_SIZE;
page_header('Mushroom Sweeper');
?>
<h1>🍄 Mushroom Sweeper</h1>
<?= game_tabs_html('mushroom.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    echo game_rules_html([
        game_energy_rule('for a clean sweep'),   // v1.4.7
        ['🎯', 'Goal.', 'Forage the safe squares of the forest floor without stepping on a toadstool. ' . MUSH_TOADS . ' hide among ' . $n . ' squares.'],
        ['🔢', 'Numbers.', 'A number shows how many toadstools touch that square, corners too. A blank square opens its neighbours for you.'],
        ['🛟', 'First pick.', 'Your first pick is always safe.'],
        ['🚩', 'Flags.', 'Switch to Flag mode to mark a square you think is a toadstool. Flagged squares stay shut.'],
        ['🪙', 'Petals.', 'Petals for each safe square, up to ' . money(game_petals(MUSH_PETALS_MAX)) . '. You keep them even if you hit a toadstool.'],
        ['🏆', 'Clean sweep.', 'Forage all ' . MUSH_SAFE . ' safe squares for a ' . money(game_petals(MUSH_SWEEP_PETALS)) . ' bonus and a forage find.'],
        ['🧺', 'Stop any time.', 'Take what you found and head home whenever you like.'],
        ['🔁', 'Daily limit.', (int)setting('mush_plays_per_day') . ' walks a day.'],
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Clear the forest floor without stepping on a toadstool.</p>

<?php if ($s): ?>
  <div class="gmchips" role="status"><?php /* v1.4.6: tidy chips */ ?>
    <span class="gmchip"><?= $s['mode'] === 'flag' ? '🚩' : '⛏️' ?> <b><?= $s['mode'] === 'flag' ? 'Flag mode' : 'Pick mode' ?></b></span>
    <span class="gmchip">🌿 Foraged <b><?= count($s['open']) ?> / <?= MUSH_SAFE ?></b></span>
    <span class="gmchip">🍄 Toadstools <b><?= MUSH_TOADS ?></b></span>
    <span class="gmchip">🚩 Flags <b><?= count($s['flags']) ?></b></span>
  </div>
  <form method="post" class="mushtools"><?= csrf_field() ?><input type="hidden" name="do" value="mode">
    <button class="btn small<?= $s['mode'] === 'pick' ? '' : ' alt' ?>" name="mode" value="pick" aria-pressed="<?= $s['mode'] === 'pick' ? 'true' : 'false' ?>">⛏️ Pick</button>
    <button class="btn small<?= $s['mode'] === 'flag' ? '' : ' alt' ?>" name="mode" value="flag" aria-pressed="<?= $s['mode'] === 'flag' ? 'true' : 'false' ?>">🚩 Flag</button>
  </form>
  <form method="post" class="mushboard" data-size="<?= MUSH_SIZE ?>"><?= csrf_field() ?><input type="hidden" name="do" value="<?= $s['mode'] === 'flag' ? 'flag' : 'pick' ?>">
    <?php for ($i = 0; $i < $n; $i++):
        if (in_array($i, $s['open'], true)):
            $c = mush_clue($s['toads'], $i); ?>
          <span class="mushopen<?= $c ? ' n' . min($c, 4) : '' ?>" data-i="<?= $i ?>"><?= $c ?: '' ?></span>
        <?php elseif (in_array($i, $s['flags'], true)): ?>
          <button class="mushcell mushflag" name="cell" value="<?= $i ?>" data-i="<?= $i ?>" aria-label="Flagged square <?= $i % MUSH_SIZE + 1 ?>, <?= intdiv($i, MUSH_SIZE) + 1 ?>">🚩</button>
        <?php else: ?>
          <button class="mushcell" name="cell" value="<?= $i ?>" data-i="<?= $i ?>" aria-label="Square <?= $i % MUSH_SIZE + 1 ?>, <?= intdiv($i, MUSH_SIZE) + 1 ?>"></button>
        <?php endif;
    endfor; ?>
  </form>
  <form method="post" data-confirm="Head home now and keep what you’ve foraged?"><?= csrf_field() ?><input type="hidden" name="do" value="stop"><button class="btn small alt">🧺 Stop and take what I found</button></form>
<?php endif; ?>

<?php if ($last): ?>
  <p><b>Last walk:</b> <?= $last['boom'] !== null ? 'a toadstool got you. Here is where they were.' : 'all clear. Here is where they were.' ?></p>
  <div class="mushboard last" data-size="<?= MUSH_SIZE ?>">
    <?php for ($i = 0; $i < $n; $i++):
        if (in_array($i, $last['open'], true)):
            $c = mush_clue($last['toads'], $i); ?>
          <span class="mushopen<?= $c ? ' n' . min($c, 4) : '' ?>" data-i="<?= $i ?>"><?= $c ?: '' ?></span>
        <?php elseif (in_array($i, $last['toads'], true)): ?>
          <span class="mushtoad<?= $last['boom'] === $i ? ' boom' : '' ?>" data-i="<?= $i ?>"><?= $last['boom'] === $i ? '☠️' : '🍄' ?></span>
        <?php elseif (in_array($i, $last['flags'], true)): ?>
          <span class="mushflag" data-i="<?= $i ?>">🚩</span>
        <?php else: ?>
          <span class="mushopen mushdim"></span>
        <?php endif;
    endfor; ?>
  </div>
<?php endif; ?>

<?php if (!$s): $left = game_plays_left($uid, 'mushroom'); ?>
  <div class="box">
    <p><?= $left ?> walk<?= $left === 1 ? '' : 's' ?> left today · your best: <?= game_best($uid, 'mushroom') ?> squares</p>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="start"><button class="btn" <?= $left ? '' : 'disabled' ?>>🍄 Start a walk</button></form>
    <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
  </div>
<?php endif; ?>
<?php page_footer();
