<?php
declare(strict_types=1);
/**
 * v2.0.88: the Pal Book. Puzzle Pals a gnome has found, picture by picture (6 slots each: found = sticker, name, rarity, date, times; missing = a silhouette with a ?),
 * the pictures whose pals are still locked, and the Expert trophies. Everything behind ppal_open() (flag off or a guest = sent away). Plan: claude/plan-puzzle-pals.md.
 * No inline script or style (CSP). A piece is shown as a crop of its picture (.ppiece, assets/puzzles.css); missing pal art falls back to the placeholder or a piece crop.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/puzzles.php';
require_once __DIR__ . '/includes/puzzle_games.php';
require_once __DIR__ . '/includes/jigsaw.php';
require_once __DIR__ . '/includes/puzzle_pals.php';
$u = require_login();
if (!ppal_open() || is_guest($u)) { flash(is_guest($u) ? 'Puzzle Pals are for gnomes with a home. Sign up to start a collection.' : 'Puzzle Pals are coming soon.', 'err'); redirect(setting('puzzles_open') === '1' ? 'puzzles.php' : 'games.php'); }
$uid = (int)$u['id'];
$book = ppal_book($uid);
$ordr = ['common' => 0, 'uncommon' => 1, 'rare' => 2];
page_header('Puzzle Pals');
?>
<div id="pz" class="ppalbook">
<div id="lib">
  <?= puzzle_cast('pals-banner', '', 'pzbanner') ?>
  <h1>🧩 Puzzle Pals</h1>
  <div class="pzhost box">
    <?= puzzle_cast('jeff-magic', 'Jeff', 'pzface') ?: puzzle_cast('jeff-host', 'Jeff', 'pzface') ?>
    <div>
      <p class="pzline"><b>Jeff:</b> “Finish a picture at Advanced and its pals tumble loose. They turn up on any page, so keep your eyes open!”</p>
      <p class="help"><b><?= (int)$book['found'] ?></b> of <?= (int)$book['total'] ?> pals found · <b><?= count($book['released']) ?></b> picture<?= count($book['released']) === 1 ? '' : 's' ?> released</p>
    </div>
  </div>

  <?php if (!$book['released']): ?>
  <div class="pzempty box"><?= puzzle_cast('empty-box', '') ?><p class="muted">No pals yet. Solve a picture at Advanced to release its six.</p></div>
  <?php endif; ?>

  <?php foreach ($book['released'] as $sec): $pic = $sec['pic']; $roster = $sec['roster']; usort($roster, fn($a, $b) => ($ordr[$a['rarity']] ?? 3) <=> ($ordr[$b['rarity']] ?? 3)); ?>
  <section class="box ppalsec<?= $sec['n'] === count($roster) ? ' full' : '' ?>" aria-label="<?= e((string)$pic['title']) ?>">
    <h2><?= e((string)$pic['title']) ?></h2>
    <p class="help"><b><?= (int)$sec['n'] ?></b> of <?= count($roster) ?> found<?= $sec['n'] === count($roster) ? ' · roster complete' : '' ?>
      <?php if ($sec['trophy']): ?><span class="ppaltrophychip" title="Expert trophy"><span aria-hidden="true">🏆</span> Expert trophy</span><?php endif; ?></p>
    <ul class="ppalgrid">
      <?php foreach ($roster as $p): $got = $p['got']; ?>
      <li class="ppalslot ppr-<?= e($p['rarity']) ?><?= $got ? ' got' : ' miss' ?>">
        <?php if ($got): ?>
          <span class="ppalart"><?= ppal_art_url($p['key']) !== '' ? ppal_img($p['key'], $p['name']) . ppal_piece_html($pic, $p['piece'], 'ppchip') : (ppal_piece_html($pic, $p['piece'], 'ppbig') ?: ppal_img($p['key'], $p['name'])) ?></span>
          <b class="ppalname"><?= e($p['name']) ?></b>
          <span class="ppalrar ppr-<?= e($p['rarity']) ?>"><?= e(ucfirst($p['rarity'])) ?></span>
          <small class="muted">found <?= e(puzzle_local((string)$got['found_at'], 'j M Y')) ?><?= (int)$got['times'] > 1 ? ' · met ' . (int)$got['times'] . '×' : '' ?></small>
        <?php else: ?>
          <span class="ppalart ppsil" title="Not found yet"><?= ppal_art_url($p['key']) !== '' ? ppal_img($p['key'], '') : '' ?><span class="ppalq" aria-hidden="true">?</span></span>
          <b class="ppalname">???</b>
          <span class="ppalrar ppr-<?= e($p['rarity']) ?>"><?= e(ucfirst($p['rarity'])) ?></span>
          <small class="muted">not found yet</small>
        <?php endif; ?>
      </li>
      <?php endforeach; ?>
    </ul>
  </section>
  <?php endforeach; ?>

  <?php if ($book['locked']): ?>
  <h2>Still locked</h2>
  <ul class="ppallocked">
    <?php foreach ($book['locked'] as $lk): $pic = $lk['pic']; ?>
    <li class="box">
      <span class="ppalq" aria-hidden="true">?</span>
      <span><b><?= e((string)$pic['title']) ?></b><br><small class="muted">Solve <?= e((string)$pic['title']) ?> at Advanced to release its pals.</small>
      <?php if ($lk['trophy']): ?><br><span class="ppaltrophychip" title="Expert trophy"><span aria-hidden="true">🏆</span> Expert trophy</span><?php endif; ?></span>
    </li>
    <?php endforeach; ?>
  </ul>
  <?php endif; ?>
  <p><a href="<?= e(url('jigsaw.php')) ?>">🧩 To the Jigsaw</a> · <a href="<?= e(url('puzzles.php')) ?>">← All puzzles</a></p>
</div>
</div>
<?php page_footer();
