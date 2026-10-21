<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
require_once __DIR__ . '/includes/plot.php';
$u = require_login();
$uid = (int)$u['id'];

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $g = $_POST['g'] ?? [];
    [$ok, $msg] = match ($do) {
        'start' => plot_start($u),
        'save' => plot_save($u, $g),
        'hint' => plot_hint($u, $g),
        'check' => plot_check($u, $g),
        default => [false, 'Unknown action.'],
    };
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('plot.php');
}

plot_stale($uid);   // yesterday’s unfinished bed never blocks today
$s = game_state($uid, 'plot');
$last = $s ? null : ($_SESSION['plot_last'] ?? null);   // an unsolved bed’s answer, shown once
unset($_SESSION['plot_last']);
page_header('Garden Plot Logic');
?>
<h1>🪴 Garden Plot Logic</h1>
<?= game_tabs_html('plot.php') ?>
<?php if (game_tab() === 'rules'):
    echo game_rules_html([
        ['🎯', 'Goal.', 'Plant the 5 × 5 bed: each row and column has one of each of today’s 5 plants.'],
        ['🌱', 'Seedlings.', 'Some squares come planted. They stay put.'],
        ['🌿', 'Companions.', '“Every Tomato touches a Basil” means each one has a Basil directly beside it (up, down, left or right).'],
        ['🐌', 'Pest squares.', 'A marked square needs a plant that keeps that pest off.'],
        ['🧑‍🌾', 'Old Moss.', PLOT_HINTS . ' hints a bed (one more with good Lore). Each costs 10 points.'],
        ['✅', 'Checking.', PLOT_CHECKS . ' checks a bed. A wrong check costs 10 points.'],
        ['⏱️', 'Time.', 'Solve within 3 minutes for up to 20 bonus points.'],
        ['🪙', 'Petals.', 'Up to ' . money(game_petals(120)) . ', for your first solve each day.'],
        ['📅', 'Daily.', 'Everyone gets the same bed. A new one sprouts at the daily reset.'],
        game_energy_rule('for a solve with no hints and no wrong checks'),
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif;

$bed = plot_today();
$view = $s ?: ($last ?: null);
$slugs = $s ? $s['plants'] : $bed['plants'];
$names = plot_names($slugs);
$pic = fn(string $slug, int $px) => ph_or_emoji($slug, '🪴', $px, '');
$tags = plot_tags($names);
$sq = fn(string $slug, array $tg) => $pic($slug, 44) . '<span class="plottag" aria-hidden="true">' . e($tg[$slug]) . '</span>';   // picture + short name in a square
$season = HOLLOW_SEASONS[$bed['season'] ?? 'spring'] ?? HOLLOW_SEASONS['spring'];
?>
<div class="plotgame">
<p class="gtagline">One fresh bed a day. Plant it so every row, column and companion is happy.</p>

<?php if ($s):
    $locked = array_map('intval', array_merge(array_keys($s['given']), $s['hints']));
    $hintsLeft = max(0, (int)$s['hmax'] - count($s['hints']));
    $checksLeft = PLOT_CHECKS - (int)$s['wrong'];
    $mins = max(0, intdiv(time() - (int)$s['t0'], 60)); ?>
  <div class="gmchips" role="status">
    <span class="gmchip">🧑‍🌾 Hints left <b><?= $hintsLeft ?></b></span>
    <span class="gmchip">✅ Checks left <b><?= $checksLeft ?></b></span>
    <span class="gmchip">⏱️ Started <b><?= $mins < 1 ? 'just now' : $mins . ' min ago' ?></b></span>
  </div>
  <form method="post" class="plotform"><?= csrf_field() ?>
    <div class="plotlayout">
      <div class="plotleft">
        <div class="plotbed" data-n="<?= PLOT_N ?>">
          <?php for ($i = 0; $i < PLOT_CELLS; $i++):
              $r = intdiv($i, PLOT_N) + 1; $c = $i % PLOT_N + 1; $v = (int)$s['grid'][$i];
              $pest = $s['pests'][$i] ?? null;
              $rc = 'Row ' . $r . ', column ' . $c . ($pest ? ', ' . PLOT_PEST_KINDS[$pest][0] . ' square' : ''); ?>
            <?php if (in_array($i, $locked, true)):
                $isHint = in_array($i, array_map('intval', $s['hints']), true);
                $pn = $names[$slugs[$v]]; ?>
              <span class="plotcell lock<?= $isHint ? ' hint' : '' ?>" data-i="<?= $i ?>" data-p="<?= $v ?>" role="img" aria-disabled="true" aria-label="<?= e($rc . ', ' . $pn . ', planted by ' . ($isHint ? 'Old Moss' : 'a seedling start')) ?>">
                <?php if ($pest): ?><span class="plotpest" aria-hidden="true"><?= PLOT_PEST_KINDS[$pest][1] ?></span><?php endif; ?>
                <span class="plotpic"><?= $sq($slugs[$v], $tags) ?></span>
              </span>
            <?php else: ?>
              <div class="plotcell open" data-i="<?= $i ?>" data-rc="<?= e($rc) ?>">
                <?php if ($pest): ?><span class="plotpest" aria-hidden="true"><?= PLOT_PEST_KINDS[$pest][1] ?></span><?php endif; ?>
                <span class="plotpic"><?= $v >= 0 ? $sq($slugs[$v], $tags) : '' ?></span>
                <select class="plotsel" name="g[<?= $i ?>]" aria-label="<?= e($rc) ?>">
                  <option value="">Empty</option>
                  <?php foreach ($slugs as $k => $sl): ?><option value="<?= $k ?>"<?= $v === $k ? ' selected' : '' ?>><?= e($names[$sl]) ?></option><?php endforeach; ?>
                </select>
              </div>
            <?php endif; ?>
          <?php endfor; ?>
        </div>
        <div class="plotpal" hidden role="group" aria-label="Plants">
          <?php foreach ($slugs as $k => $sl): ?>
            <button type="button" class="plotp" data-v="<?= $k ?>" data-name="<?= e($names[$sl]) ?>" data-tag="<?= e($tags[$sl]) ?>" aria-pressed="false"><span class="plotpic"><?= $pic($sl, 36) ?></span><span><?= e($names[$sl]) ?></span></button>
          <?php endforeach; ?>
          <button type="button" class="plotp ghost" data-v="-1" data-name="Empty" aria-pressed="false"><span>Clear</span></button>
        </div>
      </div>
      <div class="box plotclues">
        <p><b>🌱 Each row and column: one of each plant.</b></p>
        <ul class="plotcl">
          <?php $pidx = array_flip($slugs);
          foreach ($s['rules'] as [$h, $cr]): ?>
            <li class="plotrule" data-h="<?= (int)$pidx[$h] ?>" data-c="<?= (int)$pidx[$cr] ?>">🌿 Every <?= $pic($cr, 20) ?> <b><?= e($names[$cr]) ?></b> touches <?= preg_match('/^[aeiou]/i', $names[$h]) ? 'an' : 'a' ?> <?= $pic($h, 20) ?> <b><?= e($names[$h]) ?></b> (side by side).<span class="plotyet" hidden> Not yet.</span></li>
          <?php endforeach; ?>
          <?php
          $byKind = [];
          foreach ($s['pests'] as $cell => $kind) $byKind[$kind][] = (int)$cell;
          foreach ($byKind as $kind => $cells):
              $ok = [];
              foreach ($s['pk'][$cells[0]] as $k) $ok[] = $names[$slugs[$k]]; ?>
            <li><?= PLOT_PEST_KINDS[$kind][1] ?> <?= e(ucfirst(plot_a(PLOT_PEST_KINDS[$kind][0]))) ?> square needs a plant that keeps <?= e($kind) ?> off: <b><?= e(plot_or($ok)) ?></b>.</li>
          <?php endforeach; ?>
        </ul>
      </div>
    </div>
    <div class="plotacts">
      <button class="btn" name="do" value="check" data-check>✅ Check my bed</button>
      <button class="btn small alt" name="do" value="hint" data-confirm="Ask Old Moss? It costs 10 points." <?= $hintsLeft ? '' : 'disabled' ?>>🧑‍🌾 Ask Old Moss</button>
      <button class="btn small alt" name="do" value="save">💾 Save and come back later</button>
    </div>
  </form>
<?php endif; ?>

<?php if ($last):
    $lidx = $last['plants']; $ln = plot_names($lidx); $lt = plot_tags($ln); ?>
  <div class="box">
    <p><b>Here’s how Old Moss planted it</b></p>
    <div class="plotbed last" data-n="<?= PLOT_N ?>">
      <?php for ($i = 0; $i < PLOT_CELLS; $i++): $sv = (int)$last['sol'][$i]; ?>
        <span class="plotcell lock" role="img" aria-label="<?= e('Row ' . (intdiv($i, PLOT_N) + 1) . ', column ' . ($i % PLOT_N + 1) . ', ' . $ln[$lidx[$sv]]) ?>"><span class="plotpic"><?= $sq($lidx[$sv], $lt) ?></span></span>
      <?php endfor; ?>
    </div>
  </div>
<?php endif; ?>

<?php if (!$s):
    $left = game_plays_left($uid, 'plot');
    $solved = plot_scored_today($uid);
    $played = plot_played_today($uid);
    $state = $solved ? 'solved ✅' : ($played ? 'out of checks' : 'not started'); ?>
  <div class="box plotstart">
    <p class="gmchips"><span class="gmchip"><?= $season[0] ?> <b><?= e($season[1]) ?> bed</b></span></p>
    <div class="plotrow" aria-label="Today’s plants">
      <?php foreach ($bed['plants'] as $sl): $nm = plot_names([$sl])[$sl]; ?>
        <span class="plotplant"><?= $pic($sl, 36) ?><small><?= e($nm) ?></small></span>
      <?php endforeach; ?>
    </div>
    <p>Today’s bed: <?= $state ?> · <?= $left ?> bed<?= $left === 1 ? '' : 's' ?> left today · your best: <?= game_best($uid, 'plot') ?></p>
    <?php if ($played && $left > 0): ?><p class="help"><?= $solved ? 'Practice: today’s bed is already solved.' : 'Practice: only the first bed of the day pays.' ?></p><?php endif; ?>
    <?php if ($played && $left === 0): ?><p class="help">Today’s bed is done. A fresh one sprouts at the daily reset (in <?= e(nice_time(job_period_left('daily'))) ?>).</p><?php endif; ?>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="start"><button class="btn" <?= $left ? '' : 'disabled' ?>>🪴 Plant today’s bed</button></form>
    <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
  </div>
<?php else: ?>
  <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
<?php endif; ?>
</div>
<?php page_footer();
