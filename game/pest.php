<?php
declare(strict_types=1);
/** Pest Patrol (v1.4.8): flick pests off a growing plant. The server makes and scores the round (includes/pest.php); assets/pest.js plays it. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
require_once __DIR__ . '/includes/pest.php';
$u = require_login();
$uid = (int)$u['id'];
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = match ($do) {
        'start' => pest_start($u),
        'finish' => pest_finish($u, (string)($_POST['tok'] ?? ''), (string)($_POST['taps'] ?? '')),
        default => [false, 'Unknown action.'],
    };
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('pest.php');
}
$s = game_state($uid, 'pest');
$left = game_plays_left($uid, 'pest');
page_header('Pest Patrol');
$R = PEST_RULES;
?>
<h1>🪰 Pest Patrol</h1>
<?= game_tabs_html('pest.php') ?>
<?php if (game_tab() === 'rules'):
    $K = $R['kinds'];
    echo game_rules_html([
        ['🎯', 'Goal.', 'A plant grows on screen and pests land on its leaves. Tap a pest to flick it off before it chews its leaf away.'],
        ['🪰', 'The pests.', 'Aphids are a cluster: tap them ' . $K['a']['hp'] . ' times. Gnats hop from leaf to leaf, so be quick. Caterpillars chew a lot. Slugs take ' . $K['s']['hp'] . ' taps.'],
        ['🍃', 'Leaves.', 'A pest left chewing too long drops its leaf. Tap a bare leaf and it bruises; ' . $R['bruise'] . ' bruises and it falls off, for ' . $R['fall'] . ' points lost. A fallen leaf is gone for the round.'],
        ['🔥', 'Combo.', 'Flick a pest within about ' . number_format($R['quick'] / 1000, 1) . ' seconds of it showing up to keep a streak going. Each flick in a streak earns a little extra. A bare tap breaks it.'],
        ['⭐', 'Score.', 'Points for every pest (' . $K['c']['pts'] . ' to ' . $K['g']['pts'] . '), the streak bonus, and ' . $R['leaf'] . ' for every leaf still on the plant when time is up.'],
        ['🦋', 'Butterflies.', 'Now and then a butterfly flutters past. Tap it with a Bug Net in your satchel to catch it for ' . $R['bf'] . ' points and a Wing Scale. Without a net it just flutters off. No harm done.'],
        ['🐞', 'Ladybird Lodge.', 'Each level of a Ladybird Lodge adds a second to the round (up to 3). A perfect round (every pest flicked, no lost leaves, at most two stray taps) can win a Ladybird Charm (' . max(0, (int)setting('pest_charm_per_day')) . ' a day at most).'],
        ['🪙', 'Prizes.', implode(', ', array_map(fn($b) => $b[0] . '+ points: ' . money(game_petals($b[1])), PEST_BANDS)) . '.'],
        ['🔁', 'Daily limit.', (int)setting('pest_plays_per_day') . ' rounds a day. Starting one uses a go.'],
        game_energy_rule('for ' . PEST_GOOD . ' points or more'),
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Flick the pests off before they eat the leaves.</p>
<?php if ($s): ?>
<div class="box pestbox">
  <div class="pestgame" data-round="<?= e(json_encode(array_diff_key($s, ['t0' => 1]))) ?>" data-rules="<?= e(json_encode($R)) ?>">
    <div class="gmchips pstchips" role="status"><span class="gmchip">⏱ <b>–</b></span><span class="gmchip">⭐ <b>0</b></span><span class="gmchip">🍃 <b><?= (int)$s['n'] ?></b></span></div>
    <div class="pststage" aria-label="A plant with pests on its leaves"><noscript><p>Pest Patrol needs JavaScript switched on.</p></noscript></div>
    <p class="help psthow">Tap a pest to flick it off. Tapping a bare leaf bruises it.</p>
    <form method="post" class="pestform"><?= csrf_field() ?><input type="hidden" name="do" value="finish"><input type="hidden" name="tok" value="<?= e((string)$s['tok']) ?>"><input type="hidden" name="taps" value="[]"></form>
  </div>
</div>
<?php else:
    $lodge = (pest_dur($uid) - 30000) / 1000; ?>
<div class="box pestbox">
  <div class="psthero" aria-hidden="true"><span>🌱</span><i></i><span>🪰</span></div>
  <p><?= $left ?> round<?= $left === 1 ? '' : 's' ?> left today · your best this week: <?= game_best($uid, 'pest') ?></p>
  <p class="help">🦋 Bug net: <?= pest_has_net($uid) ? 'in your satchel' : 'none (needed to catch butterflies)' ?><?= $lodge > 0 ? ' · 🐞 Ladybird Lodge: +' . (int)$lodge . ' s' : '' ?></p>
  <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="start"><button class="btn act" <?= $left ? '' : 'disabled' ?>>🪰 Start patrol</button></form>
</div>
<?php endif; ?>
<?php $top = game_top('pest'); if ($top): ?><div class="box"><h3>This week’s best</h3><ol class="top"><?php foreach ($top as $t): ?><li><?= e($t['name']) ?>: <?= (int)$t['best'] ?></li><?php endforeach; ?></ol></div><?php endif; ?>
<p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
<?php page_footer();
