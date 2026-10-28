<?php
declare(strict_types=1);
/**
 * v2.0.71: Rain Barrel, a Puzzles game. Turn the gutter tiles until the water from the barrel reaches every sprout with no leaks.
 * One daily barrel (same for everyone, best time counts, reward paid once a day) plus practice barrels. Dealt by the server (includes/puzzle_games.php),
 * run by assets/rainbarrel.js, handed in through puzzle_game_api.php. Styled by assets/puzzles.css.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/puzzle_games.php';
$u = require_login();
if (!puzzle_game_open('barrel')) { flash('Rain Barrel is coming soon.', 'err'); redirect('puzzles.php'); }
$uid = (int)$u['id'];
$done = pz_done_today($uid, 'barrel');
$board = pz_daily_board('barrel', 10);
$streak = pz_streak($uid, 'barrel');
$best = pzgames_ensure() ? q_val("SELECT MIN(ms) FROM puzzle_runs WHERE user_id = ? AND game = 'barrel' AND day = ? AND mode = 'daily' AND status = 'done'", [$uid, game_day()]) : null;
$J = JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT;
$data = ['api' => url('puzzle_game_api.php'), 'csrf' => csrf_token(), 'hintMs' => PZ_HINT_MS, 'maxHints' => PZ_MAX_HINTS];
page_header('Rain Barrel');
?>
<div id="pz" class="rb">
  <h1>🚰 Rain Barrel</h1>
  <div class="pzhost box">
    <?= puzzle_cast('jeff-host', 'Jeff', 'pzface') ?>
    <div>
      <p class="pzline"><b>Jeff:</b> “Tip the barrel and turn the gutters until water reaches every sprout. Leaks are bad. Today’s barrel is the same for every gnome.”</p>
      <details class="fold"><summary>How to play</summary>
        <p class="help">Tap a gutter to turn it a quarter turn. Water runs from the barrel (brown) through joined gutters and turns blue. Every gutter must be joined up and no gutter may point at nothing. Sprouts are the green ends. The Old Wizard can fix one wrong tile for you: +<?= intdiv(PZ_HINT_MS, 1000) ?> seconds each, <?= PZ_MAX_HINTS ?> at most.</p>
        <p class="help">Daily barrel: best time counts, the daily reward comes once a day. Practice: any size, no reward.</p>
      </details>
    </div>
  </div>
  <div class="pzrow" id="rbtop">
    <button class="btn" id="rbdaily" type="button"><?= $done !== null ? 'Another go at today’s barrel' : 'Start today’s barrel' ?></button>
    <span class="pzprac"><select id="rbsize" aria-label="Practice size"><option value="5">Small 5×5</option><option value="6" selected>Medium 6×6</option><option value="8">Big 8×8</option></select>
    <button class="btn ghost" id="rbprac" type="button">Practice</button></span>
  </div>
  <p class="help" id="rbstat" aria-live="polite">
    <?php if ($done !== null): ?>Today: done ✓ best <b><?= e(puzzle_ms_text((int)$best)) ?></b>.<?php else: ?>Today’s barrel is waiting.<?php endif; ?>
    <?= $streak > 0 ? ' Streak: <b>' . $streak . '</b> day' . ($streak === 1 ? '' : 's') . '.' : '' ?>
  </p>
  <div id="rbplay" hidden>
    <div class="rbbar"><span id="rbclock" aria-live="off">0:00</span><span id="rbhints"></span><button class="btn ghost" id="rbhint" type="button" title="The Old Wizard fixes one tile (+<?= intdiv(PZ_HINT_MS, 1000) ?>s)">Hint</button></div>
    <div id="rbgrid" role="group" aria-label="Gutters"></div>
    <p id="rbmsg" class="pzmsg" aria-live="polite"></p>
  </div>
  <div id="rbwin" class="box" hidden>
    <span class="pzcast-wrap"><?= puzzle_cast('jeff-cheer', 'Jeff cheering', 'pzface') ?></span>
    <p id="rbwintx"></p>
  </div>
  <div class="box">
    <h2>Today’s fastest gnomes</h2>
    <?php if ($board): ?>
    <ol class="pzboard">
      <?php foreach ($board as $r): ?><li class="<?= (int)$r['user_id'] === $uid ? 'me' : '' ?>"><span class="nm"><?= eu((string)$r['name']) ?></span> <b><?= e(puzzle_ms_text((int)$r['best'])) ?></b></li><?php endforeach; ?>
    </ol>
    <?php else: ?><div class="pzempty"><?= puzzle_cast('empty-box', '') ?><p class="muted">No finished times yet. Be the first!</p></div><?php endif; ?>
    <p class="help">Fun only: no trophies. The daily reward is Petals and a little energy, once a day.</p>
  </div>
  <p><a href="<?= e(url('puzzles.php')) ?>">← All puzzles</a></p>
</div>
<script type="application/json" id="rb-data"><?= json_encode($data, $J) ?></script>
<?php page_footer();
