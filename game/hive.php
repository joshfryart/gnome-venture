<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
require_once __DIR__ . '/includes/hive.php';
$u = require_login();
$uid = (int)$u['id'];

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = match ($do) {
        'start' => hive_start($u),
        'lift' => hive_lift($u, (int)($_POST['cell'] ?? -1)),
        'smoke' => hive_smoke($u, (int)($_POST['cell'] ?? -1)),
        'mode' => hive_mode($u, (string)($_POST['mode'] ?? '')),
        'bank' => hive_bank($u),
        default => [false, 'Unknown action.'],
    };
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('hive.php');
}

$s = game_state($uid, 'hive');
$v = ($s && isset($s['frames'])) ? hive_view($s) : null;
$last = $v ? null : ($_SESSION['hive_last'] ?? null);   // the last hive, face up, shown once
unset($_SESSION['hive_last']);
page_header('Honey Hive Harvest');
?>
<h1>🍯 Honey Hive Harvest</h1>
<?= game_tabs_html('hive.php') ?>
<?php if (game_tab() === 'rules'):
    echo game_rules_html([
        ['🎯', 'Goal.', 'Lift honeycomb frames and bank your basket before a swarm wakes.'],
        ['🔊', 'Hum.', 'Each frame hums Quiet, Humming or Loud. Swarms are always Loud. Quiet and Humming frames are always safe.'],
        ['📊', 'Buzz meter.', 'Shows how many Loud frames are left and how many of them are swarms.'],
        ['🍯', 'Combs.', 'Clear ' . game_petals(6) . ', golden ' . game_petals(12) . ', amber ' . game_petals(20) . ', heather ' . game_petals(30) . ' Petals. Loud frames hold the best combs.'],
        ['💨', 'Smoke.', 'One puff a round (two with good Sense) shows what is in a frame without lifting it.'],
        ['💥', 'Swarm.', 'Lifting a swarm loses this round’s basket only. You still get ' . money(game_petals(HIVE_SWARM_PETALS)) . '.'],
        ['🧺', 'Bank.', 'Bank any time to take your basket as Petals (' . money(game_petals(10)) . ' per 10 sweetness).'],
        ['🌻', 'Seasons.', 'Summer hives are richer, winter hives are sleepy.'],
        ['🛡️', 'Hardiness.', 'Very hardy gnomes face one fewer swarm.'],
        ['🎁', 'Honey.', 'Your first bank of the day with 4 or more combs gives Garden Honey (and Beeswax with a heather comb).'],
        ['🔁', 'Daily limit.', (int)setting('hive_plays_per_day') . ' rounds a day.'],
        game_energy_rule('for banking 40 or more'),
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif;

/** One face-up frame (end view and lifted/peeked cells). */
function hive_face(string $kind): string
{
    $emoji = $kind === 'swarm' ? '💥' : ($kind === 'drowsy' ? '🐝' : '🍯');
    $art = $kind === 'swarm' ? 'hive-swarm' : ($kind === 'drowsy' ? 'hive-drowsy-bee' : 'comb-' . $kind);
    return '<span class="hface">' . ph_or_emoji($art, $emoji, 48) . '</span>';
}
?>
<p class="gtagline">Lift the frames, listen to the hum, bank before the bees wake.</p>

<?php if ($v): ?>
  <div class="gmchips" role="status">
    <span class="gmchip">🧺 Basket <b><?= $v['basket'] ?></b></span>
    <span class="gmchip">🔊 Loud frames <b><?= $v['loud'] ?></b> · swarms <b><?= $v['swarms'] ?></b></span>
    <span class="gmchip">💨 Smoke <b><?= $v['puffs'] ?></b></span>
  </div>
  <div class="hivemeter" aria-hidden="true"><?php for ($k = 0; $k < $v['loud']; $k++): ?><i class="<?= $k < $v['swarms'] ? 'swarm' : 'safe' ?>"></i><?php endfor; ?></div>
  <form method="post" class="mushtools"><?= csrf_field() ?><input type="hidden" name="do" value="mode">
    <button class="btn small<?= $v['mode'] === 'lift' ? '' : ' alt' ?>" name="mode" value="lift" aria-pressed="<?= $v['mode'] === 'lift' ? 'true' : 'false' ?>">🍯 Lift</button>
    <button class="btn small<?= $v['mode'] === 'smoke' ? '' : ' alt' ?>" name="mode" value="smoke" aria-pressed="<?= $v['mode'] === 'smoke' ? 'true' : 'false' ?>">💨 Smoke</button>
  </form>
  <form method="post" class="hiveboard"><?= csrf_field() ?><input type="hidden" name="do" value="<?= $v['mode'] === 'smoke' ? 'smoke' : 'lift' ?>">
    <?php foreach ($v['cells'] as $i => $c):
        $n = $i + 1; $word = HIVE_HUM_WORD[$c['hum']]; ?>
      <?php if ($c['lifted']): $val = HIVE_VALUE[$c['kind']]; ?>
        <span class="hopen k-<?= e($c['kind']) ?>" role="img" aria-label="Frame <?= $n ?>, lifted: <?= e(HIVE_NAMES[$c['kind']]) ?><?= $val ? ', +' . $val : '' ?>">
          <?= hive_face($c['kind']) ?><b class="hval"><?= $val ? '+' . $val : '' ?></b></span>
      <?php elseif ($c['peeked'] && $c['kind'] === 'swarm'): ?>
        <button type="button" class="hframe peek k-swarm" disabled aria-label="Frame <?= $n ?>, peeked: a swarm. Leave it be."><?= hive_face('swarm') ?><span class="hword">Leave it be</span></button>
      <?php elseif ($c['peeked']): ?>
        <button class="hframe peek k-<?= e($c['kind']) ?>" name="cell" value="<?= $i ?>" aria-label="Frame <?= $n ?>, <?= e(strtolower($word)) ?> hum, peeked: <?= e(HIVE_NAMES[$c['kind']]) ?>"><?= hive_face($c['kind']) ?><span class="hword"><?= e(ucfirst(HIVE_NAMES[$c['kind']])) ?></span></button>
      <?php else: ?>
        <button class="hframe" name="cell" value="<?= $i ?>" data-hum="<?= $c['hum'] ?>" aria-label="Frame <?= $n ?>, <?= e(strtolower($word)) ?> hum">
          <span class="hart"><?= ph_img('hive-frame', 56) ?></span>
          <span class="hdots" aria-hidden="true"><i></i><i></i><i></i></span>
          <span class="hword"><?= e($word) ?></span></button>
      <?php endif; ?>
    <?php endforeach; ?>
  </form>
  <form method="post" class="hivebank"><?= csrf_field() ?><input type="hidden" name="do" value="bank">
    <button class="btn" <?= $s['lifted'] ? '' : 'disabled' ?>>🧺 Bank it (+<?= $v['basket'] ?>)</button>
  </form>
<?php endif; ?>

<?php if ($last): ?>
  <p><b>Last hive:</b> here is what was in every frame.</p>
  <div class="hiveboard last">
    <?php for ($i = 0; $i < HIVE_N; $i++):
        $k = $last['frames'][$i]; $val = HIVE_VALUE[$k]; $lf = in_array($i, $last['lifted'], true); ?>
      <span class="hopen k-<?= e($k) ?><?= $lf ? '' : ' dim' ?>" role="img" aria-label="Frame <?= $i + 1 ?>: <?= e(HIVE_NAMES[$k]) ?><?= $lf ? ', lifted' : ', not lifted' ?>">
        <?= hive_face($k) ?><b class="hval"><?= $val ? '+' . $val : '' ?></b></span>
    <?php endfor; ?>
  </div>
<?php endif; ?>

<?php if (!$v): $left = game_plays_left($uid, 'hive'); $season = (string)hollow_season(); ?>
  <div class="box hivestart">
    <?= ph_img('beehive-2', 72) ?>
    <p><span class="gmchip"><?= e(hive_season_line($season)) ?></span></p>
    <p><?= $left ?> round<?= $left === 1 ? '' : 's' ?> left today · your best: <?= game_best($uid, 'hive') ?></p>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="start"><button class="btn" <?= $left ? '' : 'disabled' ?>>🍯 Open the hive</button></form>
    <?php if (!$left): ?><p class="help">The bees need a rest. Come back after the daily reset.</p><?php endif; ?>
    <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
  </div>
<?php endif; ?>
<?php page_footer();
