<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
$u = require_login();
$uid = (int)$u['id'];

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = match ($do) {
        'start' => worm_start($u),
        'dig' => worm_dig($u, (int)($_POST['cell'] ?? -1)),
        'stop' => ($s = game_state($uid, 'worms')) ? worm_finish($u, $s, 'You climb out early.') : [false, 'No dig to stop.'],
        default => [false, 'Unknown action.'],
    };
    flash($msg, $ok ? 'ok' : 'err');
    redirect('worms.php');
}

$s = game_state($uid, 'worms');
page_header('Worm Hunting');
?>
<h1>🪱 Worm Hunting</h1>
<?= game_tabs_html('worms.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1: the rules live on their own tab
    $wf = fn(string $k) => WORM_FINDS[$k][3];
    echo game_rules_html([
        ['🎯', 'Goal.', 'Dig up worms, fossils and crystals from the old mine for points and Petals.'],
        ['🔢', 'Numbers.', 'A dug square shows how many worms hide in the 8 squares around it. Follow the numbers.'],
        ['🌀', 'Wandering.', 'Worms wriggle about. Now and then one moves a square, and the square it left shivers.'],
        ['⛏️', 'Digs.', (int)setting('worm_digs') . ' digs a go, and 2 more for each rock pick level. A boulder takes 2 digs without a rock pick.'],
        ['🐚', 'Deep finds.', 'Fossils and crystals need two taps: the first loosens (that is your dig), the second pulls it out free. A Fine pick can turn up geodes.'],
        ['⭐', 'Points.', 'Earthworm ' . $wf('worm') . ', nightcrawler ' . $wf('night') . ' (it is three worms), fossil ' . $wf('fossil') . ', crystal ' . $wf('gem') . ', geode ' . $wf('geode') . '. Every 10 points pay ' . money(game_petals((int)setting('worm_coins_per_point') * 10)) . '.'],
        ['🎒', 'Keep your finds.', 'Everything you dig up goes in your bag. You can climb out early and keep it all.'],
        ['🔁', 'Daily limit.', (int)setting('worm_rounds_per_day') . ' goes a day, back at the daily reset.'],
        game_energy_rule('for 10 points or more'),
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Dig the old mine for worms, fossils and gems.</p>
<?php if (!$s): $left = game_plays_left($uid, 'worms'); ?>
  <div class="box">
    <p><?= $left ?> go<?= $left === 1 ? '' : 'es' ?> left today · <?= worm_digs($uid) ?> digs per go · your best score: <?= game_best($uid, 'worms') ?></p>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="start"><button class="btn" <?= $left ? '' : 'disabled' ?>>⛏️ Start digging</button></form>
    <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
  </div>
<?php else: ?>
  <p><b>Digs left: <?= (int)$s['digs'] ?></b> · score so far: <?= (int)$s['score'] ?>
    <?php if ((int)setting('worm_wander') > 0): ?><small class="muted">· worms wander: a square that shivers has a worm right next to it</small><?php endif; ?></p>
  <form method="post" class="digboard"><?= csrf_field() ?><input type="hidden" name="do" value="dig">
    <?php for ($i = 0; $i < WORM_SIZE * WORM_SIZE; $i++):
        $fresh = ($s['last'] ?? null) === $i ? ' fresh' : '';   // v1.4.0: the square just dug (animates)
        if (isset($s['dug'][$i])):
            $what = $s['cells'][$i]; $clue = (int)$s['dug'][$i]; ?>
          <span class="dug c<?= min($clue, 4) ?> k-<?= e($what) ?><?= $fresh ?>" role="img" aria-label="<?= e(WORM_FINDS[$what][0] . ($clue ? ', clue ' . $clue : '')) ?>" title="<?= e(WORM_FINDS[$what][0]) ?>"><?= WORM_FINDS[$what][1] ?><small><?= $clue ?: '' ?></small></span>
        <?php elseif (!empty($s['loose'][$i])): ?>
          <button name="cell" value="<?= $i ?>" class="soil loose<?= $fresh ?>" aria-label="Pull out the find at square <?= $i % WORM_SIZE + 1 ?>, <?= intdiv($i, WORM_SIZE) + 1 ?> (free)"><span aria-hidden="true">✨</span></button>
        <?php else: $shiv = ($s['shiver'] ?? null) === $i; ?>
          <button name="cell" value="<?= $i ?>" class="soil<?= $shiv ? ' shiver' : '' ?>" aria-label="Dig square <?= $i % WORM_SIZE + 1 ?>, <?= intdiv($i, WORM_SIZE) + 1 ?><?= $shiv ? ' (the soil here is shivering)' : '' ?>"></button>
        <?php endif;
    endfor; ?>
  </form>
  <form method="post" data-confirm="Climb out now and keep what you’ve found?"><?= csrf_field() ?><input type="hidden" name="do" value="stop"><button class="btn small alt">Climb out early</button></form>
<?php endif; ?>
<?php page_footer();
