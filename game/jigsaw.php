<?php
declare(strict_types=1);
/**
 * v2.0.87: Jigsaw. Classic still-picture jigsaws in three fixed tiers (Easy 24, Advanced 96, Expert 216), beside GIFsaw (gifsaw.php). Same table and engine
 * (includes/gifsaw_play.php, assets/puzzles.js in "still" mode: the #pz-mode JSON block). The tier is picked on a picture's card, never a free piece count.
 * Free play is timed on the server for personal bests (puzzles_api.php pstart / pfinish) and pays nothing. Tournaments land on this page in a later step (?t=ID).
 * No inline script or style (CSP): data goes in JSON blocks. Plan: claude/plan-jigsaw.md.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/jigsaw.php';
$u = require_login();
if (!jigsaw_open()) { flash('Jigsaw is coming soon.', 'err'); redirect(setting('puzzles_open') === '1' ? 'puzzles.php' : 'games.php'); }
if ((int)($_GET['t'] ?? 0) > 0) redirect('jigsaw.php');   // tournaments: next step
$guest = !empty($u['guest']);
$J = JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT;
jigsaw_backfill_places((int)$u['id']);
$list = array_map('jigsaw_js_row', jigsaw_pics(true, (int)$u['id']));
[$plFound, $plTotal] = jigsaw_places_count((int)$u['id']);
$mode = ['tiers' => jigsaw_js_tiers(), 'api' => url('puzzles_api.php'), 'csrf' => csrf_token(), 'live' => !$guest, 'bests' => $guest ? new stdClass : (jigsaw_bests((int)$u['id']) ?: new stdClass)];
$t = null; $pzStill = true;   // $t: the play table is shared with GIFsaw tournaments
page_header('Jigsaw');   // assets/puzzles.css and assets/puzzles.js are added by page_header() for this page
?>
<div id="pz" class="jig">
<div id="lib">
  <?= puzzle_cast('puzzles-banner', '', 'pzbanner') ?>
  <h1>🧩 Jigsaw</h1>
  <div class="pzhost box">
    <?= puzzle_cast('jeff-host', 'Jeff', 'pzface') ?>
    <div>
      <p class="pzline"><b>Jeff:</b> “A proper jigsaw! Pick a picture, then <?= e(implode(', ', array_map(fn($k) => JIGSAW_TIERS[$k][0] . ' (' . jigsaw_pieces($k) . ')', array_keys(JIGSAW_TIERS)))) ?>. Same sizes for everyone, so your times mean something.”</p>
      <p class="help">Stuck? The Old Wizard keeps the Guide. And if the pieces jump about, that’s my twin Ffej.<?= $guest ? ' Guests can play, but only gnomes keep best times.' : '' ?></p>
    </div>
  </div>
  <?php if (!$list): ?><div class="pzempty box"><?= puzzle_cast('empty-box', '') ?><p><b>Jeff:</b> “The puzzle box is empty! New pictures are on their way.”</p></div><?php endif; ?>
  <div class="pzchips" id="cats"></div>
  <?php if ($plTotal > 0): ?><p class="help pzplaces">🗺️ Places: <b><?= $plFound ?></b> of <?= $plTotal ?> found. Visit a haven, wonder, delve or lair and its picture joins your puzzle room.</p><?php endif; ?>
  <ul class="pzgrid" id="grid"></ul>
  <p><a href="<?= e(url('puzzles.php')) ?>">← All puzzles</a></p>
</div>
<?php require __DIR__ . '/includes/gifsaw_play.php'; ?>
</div>
<script type="application/json" id="pz-data"><?= json_encode($list, $J) ?></script>
<script type="application/json" id="pz-mode"><?= json_encode($mode, $J) ?></script>
<?php page_footer();
