<?php
declare(strict_types=1);
/**
 * v2.0.69: GIFsaw (was puzzles.php; puzzles.php is now the hub, old links redirect here). v2.0.0.1: Puzzles. Animated jigsaws. v2.0.68: hosted by Jeff (Ffej meddles on Scatter, the Old Wizard gives hints),
 * pictures from puzzle_pics (includes/puzzles.php), tournaments at gifsaw.php?t=ID (best time, server clock, puzzles_api.php).
 * Inside the site shell (page_header/page_footer). Playing is a mode of the same page (body.pz-play: the table fills the view under the header). Styled by assets/puzzles.css, run by assets/puzzles.js.
 * The site's CSP has no blob:, no inline script or style: data goes in JSON blocks, cast art is plain <img> (light/dark pairs switched by CSS).
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/puzzles.php';
$u = require_login();
if (setting('puzzles_open') !== '1' && !is_admin()) { flash('Puzzles are coming soon.', 'err'); redirect('games.php'); }   // v2.0.2: locked for players for now
$tourOn = puzzle_tournaments_on();
if ($tourOn) settle_puzzle_tournaments();
$tid = (int)($_GET['t'] ?? 0);
$t = null;
if ($tid > 0) {
    if (!$tourOn) { flash('Puzzle tournaments aren’t running right now.', 'err'); redirect('gifsaw.php'); }
    $t = puzzle_tourney($tid);
    if (!$t || $t['status'] === 'draft') { flash('That tournament wasn’t found.', 'err'); redirect('gifsaw.php'); }
    if ($t['kind'] === 'still') redirect('jigsaw.php?t=' . $tid);   // v2.0.87: Jigsaw tournaments live on jigsaw.php
}
if ($t) {
    $list = [puzzle_js_row(['slug' => $t['slug'], 'title' => $t['pic_title'], 'pieces_default' => $t['pieces'], 'source' => $t['source'], 'file' => $t['file'], 'still' => $t['still']])];
    $phase = puzzle_tourney_phase($t);
    $board = puzzle_board($tid, 20);
    $mine = q_one("SELECT MIN(ms) AS best, COUNT(*) AS runs FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND status = 'done'", [$tid, (int)$u['id']]);
    $myPlace = q_val('SELECT place FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND place IS NOT NULL', [$tid, (int)$u['id']]);
    $triesToday = (int)q_val('SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND started_at >= ?', [$tid, (int)$u['id'], gmdate('Y-m-d 00:00:00')]);
    $tdata = ['id' => $tid, 'pieces' => (int)$t['pieces'], 'seed' => puzzle_tourney_seed($tid), 'api' => url('puzzles_api.php'), 'csrf' => csrf_token(), 'back' => url('gifsaw.php?t=' . $tid)];
} else {
    $list = array_map('puzzle_js_row', puzzle_pics());
    $live = $tourOn && puzzles_ensure() ? q("SELECT t.*, p.title AS pic_title FROM puzzle_tournaments t JOIN puzzle_pics p ON p.id = t.pic_id WHERE t.kind = 'gif' AND t.status IN ('live', 'settled') AND t.ends_at > ? ORDER BY t.starts_at LIMIT 6", [gmdate('Y-m-d H:i:s', time() - 7 * 86400)])->fetchAll() : [];
}
$J = JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT;
page_header($t ? $t['title'] : 'GIFsaw');   // assets/puzzles.css and assets/puzzles.js are added by page_header() for this page
?>
<div id="pz">
<?php if ($t): ?>
<div id="lib" class="pztour">
  <?= puzzle_cast('tourney-banner', '', 'pzbanner') ?>
  <h1>🏆 <?= e($t['title']) ?></h1>
  <div class="pzhost box">
    <?php $gold = $phase === 'settled' && (int)$myPlace === 1;   // v2.0.74: Jeff hugs a trophy for the winner ?>
    <?= $gold ? puzzle_cast('jeff-trophy', 'Jeff with a trophy', 'pzface') : puzzle_cast(in_array($phase, ['soon', 'ended', 'settled'], true) ? 'wizard-hourglass' : 'jeff-host', in_array($phase, ['soon', 'ended', 'settled'], true) ? 'The Old Wizard' : 'Jeff', 'pzface') ?>
    <div>
      <p class="pzline"><?php if ($phase === 'soon'): ?><b>The Old Wizard:</b> “Patience, young one. The sands say this one opens <?= e(puzzle_local($t['starts_at'])) ?>.”
      <?php elseif ($phase === 'open'): ?><b>Jeff:</b> “Same picture, same pieces, same scramble for everyone. Your best time counts, so have as many goes as you like (up to <?= PUZZLE_DAILY_TRIES ?> a day). Ready when you are!”
      <?php elseif ($phase === 'closing'): ?><b>Jeff:</b> “Time’s up for starting new goes. If you’re mid-puzzle, finish it: you have a few minutes.”
      <?php elseif ($gold): ?><b>Jeff:</b> “You won! First place, and a gold trophy for your shelf. I’m not crying, you’re crying.”
      <?php else: ?><b>The Old Wizard:</b> “The sands have run out on this one. Here is how it ended.”<?php endif; ?></p>
      <p class="help"><?= e($t['pic_title']) ?> · <?= (int)$t['pieces'] ?> pieces · <?= e(puzzle_local($t['starts_at'])) ?> to <?= e(puzzle_local($t['ends_at'])) ?> (Hollow time). Prizes are just for show: a trophy or badge on your profile.</p>
      <?php if ($phase === 'open'): ?><p><button class="btn" id="tstart" type="button">Start a timed go</button> <small class="muted"><?= max(0, PUZZLE_DAILY_TRIES - $triesToday) ?> left today</small></p><?php endif; ?>
      <p id="tmsg" class="pzmsg" aria-live="polite" hidden></p>
    </div>
  </div>
  <div class="pzcols">
    <div class="box pzthumbbox"><img src="<?= e($list[0]['still']) ?>" alt="<?= e($t['pic_title']) ?>" class="pzpic"></div>
    <div class="box">
      <h2>Fastest gnomes</h2>
      <?php if ($board): ?>
      <ol class="pzboard">
        <?php foreach ($board as $k => $r): $pl = $k + 1; ?>
          <li class="<?= (int)$r['user_id'] === (int)$u['id'] ? 'me' : '' ?>"><?= $t['status'] === 'settled' ? (puzzle_cast(PUZZLE_PLACES[$pl <= 3 ? $pl : 0][0], PUZZLE_PLACES[$pl <= 3 ? $pl : 0][1], 'pzmini') ?: '') : '' ?><span class="nm"><?= eu((string)$r['name']) ?></span> <b><?= e(puzzle_ms_text((int)$r['best'])) ?></b></li>
        <?php endforeach; ?>
      </ol>
      <?php else: ?><div class="pzempty"><?= puzzle_cast('empty-box', '') ?><p class="muted">No finished times yet. Be the first!</p></div><?php endif; ?>
      <p class="help">Your best: <b><?= $mine && $mine['best'] !== null ? e(puzzle_ms_text((int)$mine['best'])) : '–' ?></b><?= $mine && (int)$mine['runs'] ? ' from ' . (int)$mine['runs'] . ' finished go' . ((int)$mine['runs'] === 1 ? '' : 'es') : '' ?>.
        <?php if ($myPlace): $pl = (int)$myPlace; ?><br><?= puzzle_cast(PUZZLE_PLACES[$pl <= 3 ? $pl : 0][0], '', 'pzmini') ?> You placed <b>#<?= $pl ?></b>: <?= e(PUZZLE_PLACES[$pl <= 3 ? $pl : 0][1]) ?>.<?php endif; ?></p>
    </div>
  </div>
  <p><a href="<?= e(url('gifsaw.php')) ?>">← GIFsaw</a></p>
</div>
<?php else: ?>
<div id="lib">
  <?= puzzle_cast('puzzles-banner', '', 'pzbanner') ?>
  <h1>🧩 GIFsaw</h1>
  <div class="pzhost box">
    <?= puzzle_cast('jeff-host', 'Jeff', 'pzface') ?>
    <div>
      <p class="pzline"><b>Jeff:</b> “Hello, I’m Jeff! Pick a picture and a piece count and I’ll tip the box out for you. The pictures move while you solve them. No rush, no prizes, just a nice puzzle.”</p>
      <p class="help">Stuck? The Old Wizard keeps the Guide. And if the pieces jump about, that’s my twin Ffej. Sorry about him.</p>
    </div>
  </div>
  <?php if ($live): ?>
  <h2>🏆 Tournaments</h2>
  <ul class="pztours">
    <?php foreach ($live as $lt): $ph = puzzle_tourney_phase($lt); ?>
      <li><a class="box" href="<?= e(url('gifsaw.php?t=' . (int)$lt['id'])) ?>"><?= puzzle_cast('tourney-banner', '', 'pzmini') ?><b><?= e($lt['title']) ?></b>
        <small><?= e($lt['pic_title']) ?> · <?= (int)$lt['pieces'] ?> pieces · <?= ['soon' => 'opens ' . puzzle_local($lt['starts_at']), 'open' => 'on now, until ' . puzzle_local($lt['ends_at']), 'closing' => 'finishing up', 'ended' => 'ended', 'settled' => 'results are in'][$ph] ?? '' ?></small></a></li>
    <?php endforeach; ?>
  </ul>
  <?php endif; ?>
  <?php if (!$list): ?><div class="pzempty box"><?= puzzle_cast('empty-box', '') ?><p><b>Jeff:</b> “The puzzle box is empty! New pictures are on their way.”</p></div><?php endif; ?>
  <ul class="pzgrid" id="grid"></ul>
  <p><a href="<?= e(url('puzzles.php')) ?>">← All puzzles</a></p>
</div>
<?php endif; ?>
<?php require __DIR__ . '/includes/gifsaw_play.php'; ?>
</div>
<script type="application/json" id="pz-data"><?= json_encode($list, $J) ?></script>
<?php if ($t): ?><script type="application/json" id="pz-t"><?= json_encode($tdata, $J) ?></script><?php endif; ?>
<?php page_footer();
