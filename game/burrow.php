<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
require_once __DIR__ . '/includes/burrow.php';
$u = require_login();
$uid = (int)$u['id'];

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = match ($do) {
        'start' => burrow_start($u),
        'knock' => burrow_knock($u, $_POST['d'] ?? null),
        default => [false, 'Unknown action.'],
    };
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('burrow.php');
}

$s = game_state($uid, 'burrow');
page_header('Burrow Sorting');
?>
<h1>🦔 Burrow Sorting</h1>
<?= game_tabs_html('burrow.php') ?>
<?php if (game_tab() === 'rules'):
    echo game_rules_html([
        ['🎯', 'Goal.', 'Work out who lives behind each of the 5 doors.'],
        ['🔎', 'Clues.', 'The clues narrow it down to a few ways. Knocking tells you which.'],
        ['✊', 'Knock.', 'Fill every door and knock. You hear how many are at home, but not which.'],
        ['🔢', 'Knocks.', BURROW_BASE_KNOCKS . ' a round (' . (BURROW_BASE_KNOCKS + 1) . ' with good Charm).'],
        ['⭐', 'Score.', 'Fewer knocks, more Petals: up to ' . money(game_petals(burrow_score(BURROW_BASE_KNOCKS - 1))) . '.'],
        ['🌙', 'Out of knocks.', 'You still get ' . money(game_petals(BURROW_FAIL_RAW)) . ' for the walk.'],
        ['🍂', 'Seasons.', 'Different neighbours live here each season.'],
        ['🔁', 'Daily limit.', (int)setting('burrow_plays_per_day') . ' rounds a day.'],
        game_energy_rule('for sorting it in 2 knocks or fewer'),
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Five doors, five sleepy neighbours. Who lives where?</p>
<?php
$last = $_SESSION['burrow_last'] ?? null;
unset($_SESSION['burrow_last']);
if (!$s):
    $left = game_plays_left($uid, 'burrow'); ?>
  <?php if (is_array($last)): ?>
  <div class="box burrowreveal">
    <h3>Here’s who really lives where</h3>
    <ol class="burrowans">
      <?php foreach ($last['sol'] as $d => $ci): ?><li><span class="bdn">Door <?= $d + 1 ?>, <?= e(BURROW_FEATURES[$d][2]) ?>:</span> <?= burrow_who((string)$last['cast'][$ci]) ?></li><?php endforeach; ?>
    </ol>
  </div>
  <?php endif; ?>
  <div class="box burrowstart">
    <div class="burrowrow preview" aria-hidden="true">
      <?php for ($i = 0; $i < BURROW_DOORS; $i++): ?><div class="bdoor"><?= burrow_door_pic($i, 64) ?></div><?php endfor; ?>
    </div>
    <p><?= $left ?> round<?= $left === 1 ? '' : 's' ?> left today · your best: <?= game_best($uid, 'burrow') ?></p>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="start"><button class="btn" <?= $left ? '' : 'disabled' ?>>🚪 Visit the burrows</button></form>
    <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
  </div>
<?php else:
    $cast = $s['cast'];
    $prefill = array_map('intval', is_array($s['last'] ?? null) ? $s['last'] : []);
    $hist = array_reverse($s['hist']);
    $knocksLeft = (int)$s['knocks']; ?>
  <div class="gmchips" role="status">
    <span class="gmchip">✊ Knocks <b><?= $knocksLeft ?></b></span>
    <span class="gmchip">🔎 Clues <b><?= count($s['clues']) ?></b></span>
  </div>
  <div class="box burrowclues">
    <ol>
      <?php foreach ($s['clues'] as $c): ?><li><?= burrow_clue_html($c, $cast, (string)$s['season']) ?></li><?php endforeach; ?>
    </ol>
  </div>
  <form method="post" class="burrowform"><?= csrf_field() ?><input type="hidden" name="do" value="knock">
    <div class="burrowrow">
      <?php for ($i = 0; $i < BURROW_DOORS; $i++): $pv = $prefill[$i] ?? -1; ?>
        <div class="bdoor" data-d="<?= $i ?>">
          <?= burrow_door_pic($i, 64) ?>
          <span class="bnum"><b><?= $i + 1 ?></b> <?= e(BURROW_FEATURES[$i][2]) ?></span>
          <label class="bsel"><span class="sr">Who lives behind door <?= $i + 1 ?>, <?= e(BURROW_FEATURES[$i][2]) ?>?</span>
            <select name="d[<?= $i ?>]">
              <option value="">Who?</option>
              <?php foreach ($cast as $ci => $key): ?><option value="<?= $ci ?>"<?= $pv === $ci ? ' selected' : '' ?>><?= e(BURROW_CREATURES[$key][0]) ?></option><?php endforeach; ?>
            </select></label>
          <button type="button" class="bslot" data-d="<?= $i ?>" data-label="Door <?= $i + 1 ?>, <?= e(BURROW_FEATURES[$i][2]) ?>"><span class="bslotin">?</span></button>
        </div>
      <?php endfor; ?>
    </div>
    <div class="burrowtray" role="group" aria-label="The five neighbours">
      <?php foreach ($cast as $ci => $key): ?>
        <button type="button" class="bchip" data-c="<?= $ci ?>" data-name="<?= e(BURROW_CREATURES[$key][0]) ?>" aria-pressed="false"><?= burrow_who($key) ?></button>
      <?php endforeach; ?>
    </div>
    <p class="help burrowhelp">Tap a neighbour, then tap a door to put them there.</p>
    <div class="burrowact">
      <button class="btn bknock" <?= $knocksLeft > 0 ? '' : 'disabled' ?>>✊ Knock</button>
      <button type="button" class="btn ghost bclear">Clear doors</button>
    </div>
  </form>
  <?php if ($hist): ?>
  <div class="box burrowhist">
    <h3>Knocks so far</h3>
    <ol class="knocks">
      <?php foreach ($hist as $h): ?>
        <li><span class="kmini"><?php foreach ($h[0] as $ci): ?><?= burrow_who((string)$cast[(int)$ci], false) ?><?php endforeach; ?></span>
          <b class="khome"><?= (int)$h[1] ?></b> at home</li>
      <?php endforeach; ?>
    </ol>
  </div>
  <?php endif; ?>
  <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
<?php endif; ?>
<?php page_footer();
