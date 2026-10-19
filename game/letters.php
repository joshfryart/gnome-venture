<?php declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
require_once __DIR__ . '/includes/letters.php';
$u = require_login();
$uid = (int)$u['id'];

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'hint') {
        [$ok, $msg] = letters_hint($u);
    } elseif ($do === 'look') {
        [$ok, $msg] = letters_look($u);
    } else {
        [$ok, $msg] = [false, 'Nothing to do there.'];
    }
    flash($msg, $ok ? 'ok' : 'err');
    redirect('letters.php');
}

$info = letters_info($u);
$here = player_node($u);
$hereRegion = !empty($here['region_id']) ? q_val('SELECT gnomish_name FROM regions WHERE id = ?', [(int)$here['region_id']]) : null;
page_header('Lost Letters');
?>
<h1>🗺️ Lost Letters</h1>
<?= game_tabs_html('letters.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    echo game_rules_html([
        game_energy_rule('every letter you find'),   // v1.4.7
        ['🎯', 'Goal.', 'A letter goes astray each day and turns up at a town or village in the Hollow. Find it.'],
        ['🧩', 'The riddle.', 'Two clues tell you the region and what the place is like.'],
        ['📮', 'Postmark.', 'Read it for a third clue and the first letter of the name. The prize drops from ' . money(game_petals(LETTER_PETALS)) . ' to ' . money(game_petals(LETTER_HINT_PETALS)) . '.'],
        ['🚶', 'Go there.', 'Travel to the place, then press “Lift the stone”. The World page shows the stone when you are there.'],
        ['🪙', 'Prize.', money(game_petals(LETTER_PETALS)) . ' and a kind note from the sender.'],
        ['🔁', 'Daily limit.', (int)setting('letters_per_day') . ' letter a day. A new one comes after the daily reset.'],
        ['💡', 'Tip.', 'Looking in the wrong place costs nothing.'],
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Work out where today’s letter is hiding. New one in <?= nice_time(job_period_left('daily')) ?>.</p>
<?php /* v1.4.7: postbag look. Envelope art is inline SVG (includes/letters.php), the opening animation is in assets/letters.js. The server still decides every hint and find. */ ?>

<?php if (!$info): ?>
  <div class="box"><p class="muted">The post is quiet today. Try again after the daily reset.</p></div>
<?php else:
    $s = $info['state'];
    $loc = $info['loc'];
    $c = $info['clues'];
    $atTarget = (int)$here['id'] === (int)$s['target'];
    $clues = ($s['hint'] || $s['found']) ? 3 : 2;
    $prize = game_petals($s['hint'] ? LETTER_HINT_PETALS : LETTER_PETALS);
?>
  <div class="gmchips" role="status">
    <span class="gmchip gold">🪙 Prize <b><?= money($prize) ?></b></span>
    <span class="gmchip">🧩 Clues <b><?= $clues ?> / 3</b></span>
    <span class="gmchip">📮 Postmark <b><?= ($s['hint'] || $s['found']) ? 'read' : 'unread' ?></b></span>
    <span class="gmchip">🔁 Left today <b><?= letters_left($uid) ?></b></span>
  </div>
  <div class="box letterbox letterdesk" data-found="<?= $s['found'] ? '1' : '0' ?>" data-hint="<?= $s['hint'] ? '1' : '0' ?>">
    <div class="envstage<?= $s['found'] ? ' open' : '' ?>"><?= letters_envelope_svg((bool)$s['found'], $s['hint'] ? letters_initial((string)$loc['name']) : '') ?></div>
    <div class="riddlepaper">
      <p class="letter-dear">Dear gnome,</p>
      <p class="letter-clue clue"><span class="cico" aria-hidden="true">🗺️</span><span><?= e($c['one']) ?></span></p>
      <p class="letter-clue clue"><span class="cico" aria-hidden="true">🏞️</span><span><?= e($c['two']) ?></span></p>
      <?php if ($s['hint'] || $s['found']): ?>
        <p class="letter-clue letter-extra clue"><span class="cico" aria-hidden="true">🧭</span><span><?= e($c['three']) ?></span></p>
      <?php else: ?>
        <p class="clue locked"><span class="cico" aria-hidden="true">🔒</span><span>A third clue is sealed in the postmark.</span></p>
      <?php endif; ?>
      <?php if ($s['hint']): ?>
        <p class="letter-post postmarkline">📮 The postmark begins with “<b><?= e(letters_initial((string)$loc['name'])) ?></b>”.</p>
      <?php elseif (!$s['found']): ?>
        <form method="post" class="inline letterform"><?= csrf_field() ?><input type="hidden" name="do" value="hint"><button class="btn alt small">Read the postmark</button> <small class="help">(an extra clue, but the reward drops from <?= money(game_petals(LETTER_PETALS)) ?> to <?= money(game_petals(LETTER_HINT_PETALS)) ?>)</small></form>
      <?php endif; ?>
      <p class="letter-sign">Yours, from the post.</p>
    </div>
  </div>

  <?php if ($s['found']): ?>
    <div class="box letter-result">
      <h3>📬 You found it!</h3>
      <p class="gmchips left"><span class="gmchip gold">🪙 <b>+<?= money($prize) ?></b></span><span class="gmchip">📍 <b><?= e((string)$loc['name']) ?></b></span></p>
      <p class="letter-note"><?= e((string)$s['letter']) ?></p>
      <p class="muted">Found at <?= e((string)$loc['name']) ?>. Come back tomorrow for another letter.</p>
    </div>
  <?php else: ?>
    <div class="box wherecard<?= $atTarget ? ' here' : '' ?>">
      <div class="wherehead"><span class="pin" aria-hidden="true"><?= $atTarget ? '📬' : '📍' ?></span>
        <p class="letter-here">You are now at <b><?= e((string)$here['name']) ?></b><?= $hereRegion ? ', in ' . e((string)$hereRegion) : '' ?>.</p></div>
      <?php if ($atTarget): ?>
        <p class="wheresay">📬 Something’s tucked under a stone here…</p>
      <?php else: ?>
        <p class="muted wheresay">Not the right place yet. Keep reading the clues.</p>
      <?php endif; ?>
      <form method="post" class="inline letterform"><?= csrf_field() ?><input type="hidden" name="do" value="look"><button class="btn<?= $atTarget ? '' : ' alt' ?>"><?= $atTarget ? 'Lift the stone' : 'Look around here' ?></button></form>
    </div>
  <?php endif; ?>
<?php endif; ?>

<p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
<?php page_footer();
