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
$party = ppal_party_on();   // step 4: take along (needs ppal_party; any gnome level)
$canParty = $party && ppal_can_party($u);
if (is_post() && $party) {   // Take along / Send home (one pal at a time; a full party sends one home first)
    csrf_check();
    $key = (string)($_POST['pal'] ?? '');
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'swap') ppal_set_active($u, (string)($_POST['out'] ?? ''), false);
    [$okp, $msgp] = ppal_set_active($u, $key, $do === 'on' || $do === 'swap');
    flash($msgp, $okp ? 'ok' : 'err');
    redirect('puzzlepals.php');
}
$book = ppal_book($uid);
$eq = $canParty ? ppal_equipped($u) : [];
$eqKeys = array_map(fn($e) => $e['pal']['key'], $eq);
$perks = $canParty ? ppal_perks($u) : ['lines' => []];
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
      <p class="pzline"><b>Jeff:</b> “Finish a picture at Advanced and its pals tumble loose. They wait at places on the map, so go and find them!”</p>
      <?php if ((int)$book['found'] === 0) echo ppal_howto_html(); ?>
      <p class="help"><b><?= (int)$book['found'] ?></b> of <?= (int)$book['total'] ?> pals found · <b><?= count($book['released']) ?></b> picture<?= count($book['released']) === 1 ? '' : 's' ?> released</p>
    </div>
  </div>

  <?= ppal_waiting_html($u) ?>

  <?php if ($party): ?>
  <section class="box ppalparty" aria-label="Your party">
    <h2>Your party</h2>
    <?php if (!$canParty): ?>
      <p class="help">Pals cannot come along just yet. You can still find and collect them.</p>
    <?php else: ?>
    <ul class="ppalslots">
      <li class="ppalme"><?= gnome_avatar($u, 48) ?><small>You</small></li>
      <?php for ($i = 0; $i < ppal_party_max(); $i++): $e = $eq[$i] ?? null; ?>
      <li class="ppalpslot<?= $e ? ' got ppr-' . e($e['pal']['rarity']) : '' ?>">
        <?php if ($e): ?><?= ppal_img($e['pal']['key'], $e['pal']['name'], 'ppalimg', 48) ?><b><?= e($e['pal']['name']) ?></b><small class="muted"><?= e(ppal_perk_line($e['pal'], (int)$e['units'])) ?></small>
        <?php else: ?><span class="ppalq" aria-hidden="true">+</span><small class="muted">Room for a pal</small><?php endif; ?>
      </li>
      <?php endfor; ?>
    </ul>
    <?php if ($perks['lines']): ?><p class="help ppalperks"><b>Pal perks:</b> <?= e(implode('. ', $perks['lines'])) ?>.</p><?php endif; ?>
    <?php endif; ?>
  </section>
  <?php endif; ?>

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
          <?php if ($canParty): $isEq = in_array($p['key'], $eqKeys, true); ?>
          <small class="ppalperk muted"><?= e(ppal_perk_line($p, ppal_pal_units($p, $uid, (int)$pic['id']))) ?></small>
          <form method="post" action="<?= e(url('puzzlepals.php')) ?>" class="ppaltake"><?= csrf_field() ?><input type="hidden" name="pal" value="<?= e($p['key']) ?>">
            <?php if ($isEq): ?><button class="btn small ghost" name="do" value="off">Send home</button>
            <?php elseif (count($eq) >= ppal_party_max()): ?><input type="hidden" name="out" value="<?= e($eq[0]['pal']['key']) ?>"><button class="btn small ghost" name="do" value="swap">Swap with <?= e($eq[0]['pal']['name']) ?></button>
            <?php else: ?><button class="btn small" name="do" value="on">Take along</button><?php endif; ?>
          </form>
          <?php endif; ?>
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
