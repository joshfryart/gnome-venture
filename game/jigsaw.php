<?php
declare(strict_types=1);
/**
 * v2.0.87: Jigsaw. Classic still-picture jigsaws in three fixed tiers (Easy 24, Advanced 96, Expert 216), beside GIFsaw (gifsaw.php). Same table and engine
 * (includes/gifsaw_play.php, assets/puzzles.js in "still" mode: the #pz-mode JSON block). The tier is picked on a picture's card, never a free piece count.
 * Free play is timed on the server for personal bests (puzzles_api.php pstart / pfinish) and pays nothing. Tournaments (v2.0.87 B) are ?t=ID on this page: one picture and one tier each, a cup is three tiers linked by cup_id.
 * No inline script or style (CSP): data goes in JSON blocks. Plan: claude/plan-jigsaw.md.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/jigsaw.php';
require_once __DIR__ . '/includes/puzzle_pals.php';
$u = require_login();
if (!jigsaw_open()) { flash('Jigsaw is coming soon.', 'err'); redirect(setting('puzzles_open') === '1' ? 'puzzles.php' : 'games.php'); }
$tourOn = jigsaw_tournaments_on();
if ($tourOn) settle_puzzle_tournaments();
jigsaw_release_reserved();   // only does anything while jigsaw_reserve_days > 0
$tid = (int)($_GET['t'] ?? 0);
$t = null;
if ($tid > 0) {
    if (!$tourOn) { flash('Jigsaw tournaments aren’t running right now.', 'err'); redirect('jigsaw.php'); }
    $t = puzzle_tourney($tid);
    if (!$t || $t['status'] === 'draft') { flash('That tournament wasn’t found.', 'err'); redirect('jigsaw.php'); }
    if ($t['kind'] !== 'still' || !isset(JIGSAW_TIERS[(string)$t['tier']])) redirect($t['kind'] === 'gif' ? 'gifsaw.php?t=' . $tid : 'jigsaw.php');   // GIFsaw tournaments live on gifsaw.php
}
$guest = !empty($u['guest']);
$J = JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT;
jigsaw_backfill_places((int)$u['id']);
$pzStill = true;   // $t (set above or null): the play table is shared with GIFsaw tournaments
if ($t) {
    $tier = (string)$t['tier']; [$tLabel, , , , $tIcon] = JIGSAW_TIERS[$tier]; $tPieces = jigsaw_pieces($tier); $tTries = jigsaw_tries($tier);
    $phase = puzzle_tourney_phase($t);
    $mystery = $phase === 'soon';   // before it opens the picture stays hidden: not printed, not in the page data
    $list = $mystery ? [] : [jigsaw_js_row(['slug' => $t['slug'], 'title' => $t['pic_title'], 'cat' => $t['cat'], 'source' => $t['source'], 'file' => $t['file'], 'thumb' => $t['thumb']])];
    $board = puzzle_board($tid, 20);
    $mine = q_one("SELECT MIN(ms) AS best, COUNT(*) AS runs FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND status = 'done'", [$tid, (int)$u['id']]);
    $myPlace = q_val('SELECT place FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND place IS NOT NULL', [$tid, (int)$u['id']]);
    $triesToday = (int)q_val('SELECT COUNT(*) FROM puzzle_attempts WHERE tournament_id = ? AND user_id = ? AND started_at >= ?', [$tid, (int)$u['id'], gmdate('Y-m-d 00:00:00')]);
    $cup = [];
    if ((int)$t['cup_id'] > 0) {   // the cup's tiers (2 or 3 tournaments sharing cup_id) as tabs
        $cup = q("SELECT id, tier FROM puzzle_tournaments WHERE kind = 'still' AND cup_id = ? AND status <> 'draft'", [(int)$t['cup_id']])->fetchAll();
        $ord = array_flip(array_keys(JIGSAW_TIERS));
        usort($cup, fn($a, $b) => ($ord[$a['tier']] ?? 9) <=> ($ord[$b['tier']] ?? 9));
        if (count($cup) < 2) $cup = [];
    }
    $tdata = ['id' => $tid, 'pieces' => $tPieces, 'seed' => puzzle_tourney_seed($tid), 'api' => url('puzzles_api.php'), 'csrf' => csrf_token(), 'back' => url('jigsaw.php?t=' . $tid)];
    $mode = ['tiers' => jigsaw_js_tiers(), 'api' => url('puzzles_api.php'), 'csrf' => csrf_token(), 'live' => false, 'bests' => new stdClass];   // live = false: no free-play pstart / pfinish in a tournament
} else {
    $list = array_map('jigsaw_js_row', jigsaw_pics(true, (int)$u['id']));
    [$plFound, $plTotal] = jigsaw_places_count((int)$u['id']);
    $mode = ['tiers' => jigsaw_js_tiers(), 'api' => url('puzzles_api.php'), 'csrf' => csrf_token(), 'live' => !$guest, 'bests' => $guest ? new stdClass : (jigsaw_bests((int)$u['id']) ?: new stdClass)];
    if (!$guest && ppal_open() && ($pips = ppal_pips((int)$u['id']))) $mode['pals'] = $pips;   // v2.0.88 Puzzle Pals: slug => [found, total]
    $live = $tourOn && puzzles_ensure() ? q("SELECT t.*, p.title AS pic_title FROM puzzle_tournaments t JOIN puzzle_pics p ON p.id = t.pic_id WHERE t.kind = 'still' AND t.status IN ('live', 'settled') AND t.ends_at > ? ORDER BY t.starts_at DESC, t.id LIMIT 12", [gmdate('Y-m-d H:i:s', time() - 7 * 86400)])->fetchAll() : [];
}
page_header($t ? $t['title'] : 'Jigsaw');   // assets/puzzles.css and assets/puzzles.js are added by page_header() for this page
?>
<div id="pz" class="jig">
<?php if ($t): ?>
<div id="lib" class="pztour">
  <?= puzzle_cast('tourney-banner', '', 'pzbanner') ?>
  <h1>🏆 <?= e($t['title']) ?></h1>
  <?php if ($cup): ?>
  <nav class="pzchips pzcup" aria-label="Cup tiers"><?php foreach ($cup as $c): $ct = JIGSAW_TIERS[$c['tier']] ?? null; if (!$ct) continue; ?>
    <a class="pzchip<?= (int)$c['id'] === $tid ? ' on' : '' ?>"<?= (int)$c['id'] === $tid ? ' aria-current="page"' : '' ?> href="<?= e(url('jigsaw.php?t=' . (int)$c['id'])) ?>"><?= $ct[4] ?> <?= e($ct[0]) ?></a>
  <?php endforeach; ?></nav>
  <?php endif; ?>
  <div class="pzhost box">
    <?php $gold = $phase === 'settled' && (int)$myPlace === 1;
    $wiz = in_array($phase, ['soon', 'ended', 'settled'], true); ?>
    <?= $gold ? puzzle_cast('jeff-trophy', 'Jeff with a trophy', 'pzface') : puzzle_cast($wiz ? 'wizard-hourglass' : ($tier === 'expert' ? 'jeff-headband' : 'jeff-host'), $wiz ? 'The Old Wizard' : 'Jeff', 'pzface') ?>
    <div>
      <p class="pzline"><?php if ($phase === 'soon'): ?><b>The Old Wizard:</b> “Patience, young one. A mystery picture, <?= e($tLabel) ?> size, and the sands say it opens <?= e(puzzle_local($t['starts_at'])) ?>.”
      <?php elseif ($phase === 'open'): ?><b>Jeff:</b> “Same picture, same <?= $tPieces ?> pieces, same scramble for everyone. Your best time counts, so have as many goes as you like (up to <?= $tTries ?> a day). Ready when you are!”
      <?php elseif ($phase === 'closing'): ?><b>Jeff:</b> “Time’s up for starting new goes. If you’re mid-puzzle, finish it: you have a few minutes.”
      <?php elseif ($gold): ?><b>Jeff:</b> “You won! First place, and a gold trophy for your shelf. I’m not crying, you’re crying.”
      <?php else: ?><b>The Old Wizard:</b> “The sands have run out on this one. Here is how it ended.”<?php endif; ?></p>
      <p class="help"><?= $mystery ? 'Mystery picture' : e($t['pic_title']) ?> · <?= $tIcon ?> <?= e($tLabel) ?>, <?= $tPieces ?> pieces · <?= e(puzzle_local($t['starts_at'])) ?> to <?= e(puzzle_local($t['ends_at'])) ?> (Hollow time). Prizes are just for show: a trophy or badge on your profile.</p>
      <?php if ($phase === 'open'): ?><p><button class="btn" id="tstart" type="button">Start a timed go</button> <small class="muted"><?= max(0, $tTries - $triesToday) ?> left today</small></p><?php endif; ?>
      <p id="tmsg" class="pzmsg" aria-live="polite" hidden></p>
    </div>
  </div>
  <div class="pzcols">
    <div class="box pzthumbbox">
      <?php if ($mystery): ?><div class="pzmystery"><?= puzzle_cast('ffej-pocket', 'Ffej, with a piece in his pocket', 'pzface') ?><p><b>Mystery picture</b><br><small class="muted">Revealed when it opens.</small></p></div>
      <?php else: ?><img src="<?= e($list[0]['thumb']) ?>" alt="<?= e($t['pic_title']) ?>" class="pzpic"><?php endif; ?>
    </div>
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
  <p><a href="<?= e(url('jigsaw.php')) ?>">← Jigsaw</a></p>
</div>
<?php else: ?>
<div id="lib">
  <?= puzzle_cast('jigsaw-banner', '', 'pzbanner') ?: puzzle_cast('puzzles-banner', '', 'pzbanner') ?>
  <h1>🧩 Jigsaw</h1>
  <div class="pzhost box">
    <?= puzzle_cast('jeff-piece', 'Jeff holding a jigsaw piece', 'pzface') ?: puzzle_cast('jeff-host', 'Jeff', 'pzface') ?>
    <div>
      <p class="pzline"><b>Jeff:</b> “A proper jigsaw! Pick a picture, then <?= e(implode(', ', array_map(fn($k) => JIGSAW_TIERS[$k][0] . ' (' . jigsaw_pieces($k) . ')', array_keys(JIGSAW_TIERS)))) ?>. Same sizes for everyone, so your times mean something.”</p>
      <p class="help">Stuck? The Old Wizard keeps the Guide. And if the pieces jump about, that’s my twin Ffej.<?= $guest ? ' Guests can play, but only gnomes keep best times.' : '' ?></p>
    </div>
  </div>
  <?php if ($live): ?>
  <h2>🏆 Tournaments</h2>
  <ul class="pztours">
    <?php foreach ($live as $lt): $ph = puzzle_tourney_phase($lt); $lti = JIGSAW_TIERS[(string)$lt['tier']] ?? ['', 0, 0, 0, '']; ?>
      <li><a class="box" href="<?= e(url('jigsaw.php?t=' . (int)$lt['id'])) ?>"><?= puzzle_cast('tourney-banner', '', 'pzmini') ?><b><?= e($lt['title']) ?></b>
        <small><?= $ph === 'soon' ? 'Mystery picture' : e($lt['pic_title']) ?> · <?= $lti[4] ?> <?= e($lti[0]) ?>, <?= $lti[1] * $lti[2] ?> pieces · <?= ['soon' => 'opens ' . puzzle_local($lt['starts_at']), 'open' => 'on now, until ' . puzzle_local($lt['ends_at']), 'closing' => 'finishing up', 'ended' => 'ended', 'settled' => 'results are in'][$ph] ?? '' ?></small></a></li>
    <?php endforeach; ?>
  </ul>
  <?php endif; ?>
  <?php if (!$list): ?><div class="pzempty box"><?= puzzle_cast('empty-box', '') ?><p><b>Jeff:</b> “The puzzle box is empty! New pictures are on their way.”</p></div><?php endif; ?>
  <div class="pzchips" id="cats"></div>
  <?php if ($plTotal > 0): ?><p class="help pzplaces">🗺️ Places: <b><?= $plFound ?></b> of <?= $plTotal ?> found. Visit a haven, wonder, delve or lair and its picture joins your puzzle room.</p><?php endif; ?>
  <ul class="pzgrid" id="grid"></ul>
  <p><a href="<?= e(url('puzzles.php')) ?>">← All puzzles</a></p>
</div>
<?php endif; ?>
<?php require __DIR__ . '/includes/gifsaw_play.php'; ?>
</div>
<script type="application/json" id="pz-data"><?= json_encode($list, $J) ?></script>
<?php if ($t): ?><script type="application/json" id="pz-t"><?= json_encode($tdata, $J) ?></script><?php endif; ?>
<script type="application/json" id="pz-mode"><?= json_encode($mode, $J) ?></script>
<?php page_footer();
