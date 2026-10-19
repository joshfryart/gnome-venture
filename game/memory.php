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
        'start' => memory_start($u, (string)($_POST['mode'] ?? '')),
        'flip' => memory_flip($u, (int)($_POST['card'] ?? -1)),
        'quit' => memory_quit($uid),
        default => [false, 'Unknown action.'],
    };
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('memory.php');
}

$s = game_state($uid, 'memory');
page_header('Seed Memory');
?>
<h1>🃏 Seed Memory</h1>
<?= game_tabs_html('memory.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    [$ea, $ep, $eb, $el] = MEMORY_MODES['easy']; [$ha, $hp, $hb, $hl] = MEMORY_MODES['hard'];
    echo game_rules_html([
        ['🎯', 'Goal.', 'Turn over two seed packets at a time and find every matching pair.'],
        ['🧩', 'Easy or hard.', 'Easy is ' . $ea . ' × ' . $ea . ' (' . $ep . ' pairs). Hard is ' . $ha . ' × ' . $ha . ' (' . $hp . ' pairs).'],
        ['⭐', 'Score.', 'Fewer turns, higher score. A perfect easy game scores ' . $eb . ' and a perfect hard one ' . $hb . '. Every extra turn costs ' . $el . ' (easy) or ' . $hl . ' (hard) points.'],
        ['🪙', 'Prize.', 'Your score turns into Petals. Hard scores higher.'],
        ['🔁', 'Daily limit.', (int)setting('memory_plays_per_day') . ' games a day. Giving up still counts as one.'],
        game_energy_rule('for a hard game or a score of 40+'),
        ['💡', 'Tip.', 'Remember where the packets were. A miss turns back over when you pick the next one.'],
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Find the matching seed packets in as few turns as you can.</p>
<?php if (!$s): $left = game_plays_left($uid, 'memory'); ?>
  <div class="box">
    <p><?= $left ?> game<?= $left === 1 ? '' : 's' ?> left today · your best: <?= game_best($uid, 'memory') ?></p>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="start">
      <button class="btn" name="mode" value="easy" <?= $left ? '' : 'disabled' ?>>Easy · 4 × 4</button>
      <button class="btn" name="mode" value="hard" <?= $left ? '' : 'disabled' ?>>Hard · 6 × 6</button></form>
    <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
  </div>
<?php else: $side = MEMORY_MODES[$s['mode']][0]; ?>
  <div class="gmchips" role="status"><?php /* v1.4.6: tidy chips */ ?>
    <span class="gmchip"><?= $s['mode'] === 'hard' ? '🧠' : '🌱' ?> <b><?= ucfirst($s['mode']) ?></b></span>
    <span class="gmchip">🔄 Turns <b><?= (int)$s['turns'] ?></b></span>
    <span class="gmchip">🃏 Pairs <b><?= intdiv(count($s['matched']), 2) ?> / <?= MEMORY_MODES[$s['mode']][1] ?></b></span>
    <span class="gmchip">⭐ Score now <b><?= memory_score($s) ?></b></span>
  </div>
  <form method="post" class="memboard s<?= $side ?>" data-total="<?= count($s['cards']) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="flip">
    <?php foreach ($s['cards'] as $i => $face):
        $isM = in_array($i, $s['matched'], true);
        $up = $isM || in_array($i, $s['shown'], true) || $s['first'] === $i; ?>
      <?php if ($up): ?>
        <span class="card up<?= $isM ? ' matched' : '' ?><?= in_array($i, $s['shown'], true) ? ' miss' : '' ?><?= $s['first'] === $i ? ' fresh' : '' ?>" data-i="<?= (int)$i ?>" role="img" aria-label="Seed packet <?= $i + 1 ?>: <?= e($face) ?>"><span class="pk" aria-hidden="true"><span class="pkface"><?= $face ?></span></span></span>
      <?php else: ?>
        <button class="card down" name="card" value="<?= (int)$i ?>" data-i="<?= (int)$i ?>" aria-label="Seed packet <?= $i + 1 ?>"><span class="pkback" aria-hidden="true"><span class="pkhat"></span><span class="pkleaf">🌱</span></span></button>
      <?php endif; ?>
    <?php endforeach; ?>
  </form>
  <?php if ($s['shown']): ?><p class="help">Not a pair. Remember where they are! Pick another packet to carry on.</p><?php endif; ?>
  <form method="post" data-confirm="Give up this game? It still counts as one of today’s plays."><?= csrf_field() ?><input type="hidden" name="do" value="quit"><button class="btn small alt">Give up</button></form>
<?php endif; ?>
<?php page_footer();
