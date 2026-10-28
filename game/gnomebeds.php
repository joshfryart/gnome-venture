<?php
declare(strict_types=1);
/**
 * v2.0.72: Gnome Beds, a Puzzles game. One gnome in every row, every column and every coloured bed, and no two gnomes touching (corners too).
 * One daily garden (8x8, same for everyone, best time counts, reward once a day) plus practice gardens. The layout always has exactly one answer.
 * Dealt by the server (includes/puzzle_games.php), run by assets/gnomebeds.js, handed in through puzzle_game_api.php. Styled by assets/puzzles.css.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/puzzle_games.php';
$u = require_login();
if (!puzzle_game_open('beds')) { flash('Gnome Beds is coming soon.', 'err'); redirect('puzzles.php'); }
$uid = (int)$u['id'];
$done = pz_done_today($uid, 'beds');
$board = pz_daily_board('beds', 10);
$streak = pz_streak($uid, 'beds');
$best = pzgames_ensure() ? q_val("SELECT MIN(ms) FROM puzzle_runs WHERE user_id = ? AND game = 'beds' AND day = ? AND mode = 'daily' AND status = 'done'", [$uid, game_day()]) : null;
$J = JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT;
$data = ['api' => url('puzzle_game_api.php'), 'csrf' => csrf_token(), 'hintMs' => PZ_HINT_MS, 'maxHints' => PZ_MAX_HINTS];
page_header('Gnome Beds');
?>
<div id="pz" class="rb gb">
  <h1>🛏️ Gnome Beds</h1>
  <div class="pzhost box">
    <?= puzzle_cast('jeff-gnomehat', 'Jeff in a gnome hat', 'pzface') ?>
    <div>
      <p class="pzline"><b>Jeff:</b> “Every flower bed needs one sleepy gnome. One per row, one per column, one per bed, and they don’t like touching. Today’s garden is the same for every gnome.”</p>
      <details class="fold"><summary>How to play</summary>
        <p class="help">Tap a square once to mark it ✕ (no gnome here), twice to put a gnome there, a third time to clear it. Each coloured bed has its own corner mark, so you can tell them apart. A square turns red when it breaks a rule. The Old Wizard can place one correct gnome: +<?= intdiv(PZ_HINT_MS, 1000) ?> seconds each, <?= PZ_MAX_HINTS ?> at most.</p>
        <p class="help">Daily garden: best time counts, the daily reward comes once a day. Practice: any size, no reward.</p>
      </details>
    </div>
  </div>
  <div class="pzrow" id="rbtop">
    <button class="btn" id="rbdaily" type="button"><?= $done !== null ? 'Another go at today’s garden' : 'Start today’s garden' ?></button>
    <span class="pzprac"><select id="rbsize" aria-label="Practice size"><option value="6">Small 6×6</option><option value="7">Medium 7×7</option><option value="8" selected>Large 8×8</option><option value="9">Huge 9×9</option></select>
    <button class="btn ghost" id="rbprac" type="button">Practice</button></span>
  </div>
  <p class="help" id="rbstat" aria-live="polite">
    <?php if ($done !== null): ?><span class="rbface rbsleep"><?= puzzle_cast('jeff-sleep', 'Jeff asleep') ?></span> Today: done ✓ best <b><?= e(puzzle_ms_text((int)$best)) ?></b>.<?php else: ?>Today’s garden is waiting.<?php endif; ?>
    <?= $streak > 0 ? ' Streak: <b>' . $streak . '</b> day' . ($streak === 1 ? '' : 's') . '.' : '' ?>
  </p>
  <div id="rbplay" hidden>
    <div class="rbbar"><span id="rbclock" aria-live="off">0:00</span><span id="rbhints"></span><button class="btn ghost" id="rbhint" type="button" title="The Old Wizard places one gnome (+<?= intdiv(PZ_HINT_MS, 1000) ?>s)">Hint</button></div>
    <div id="rbgrid" role="group" aria-label="Flower beds"></div>
    <div class="rbmsgrow"><span id="rboops" class="rbface" hidden><?= puzzle_cast('jeff-oops', 'Jeff, oops') ?></span><p id="rbmsg" class="pzmsg" aria-live="polite"></p></div>
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
