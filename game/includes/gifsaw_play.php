<?php
/* v2.0.69: the GIFsaw play table (game bar, stage, win card, link box). Shared by gifsaw.php and the logged-out front page (index.php, $pzDemo = true).
   Needs $t (tournament row or null); $pzDemo optional. Driven by assets/puzzles.js. */
$pzDemo = !empty($pzDemo); ?>
<div id="game" hidden>
<div class="bar">
  <div id="prog" role="presentation"></div>
  <div class="brand">
    <div>
      <div class="gt">🧩 <?= $t ? e($t['title']) : 'GIFsaw' ?></div>
      <p class="sub" id="sub">Drop pieces on the outline and neighbours snap together. Drag the empty table to look around.</p>
    </div>
  </div>
  <div class="controls">
    <button class="btn ghost" id="back" type="button">&larr; <?= $t ? 'Tournament' : 'Library' ?></button>
    <select id="count" aria-label="Number of pieces"<?= $t ? ' disabled' : '' ?>>
      <?php foreach (PUZZLE_COUNTS as $n): ?><option value="<?= $n ?>"><?= $n ?> pieces</option><?php endforeach; ?>
      <?php if ($t && !in_array((int)$t['pieces'], PUZZLE_COUNTS, true)): ?><option value="<?= (int)$t['pieces'] ?>"><?= (int)$t['pieces'] ?> pieces</option><?php endif; ?>
    </select>
    <button class="btn ghost" id="guide" aria-pressed="false" type="button" title="The Old Wizard shows a faint picture under the outline">Guide</button>
    <button class="btn ghost" id="anim" aria-pressed="true" type="button" title="Animate the solved part of the picture (off = still picture)">Motion</button>
    <button class="btn ghost" id="scatter" type="button" title="Ffej tips the loose pieces about">Scatter</button>
    <div class="zoom" role="group" aria-label="Zoom"><button class="btn ghost" id="zout" type="button" aria-label="Zoom out">−</button><span id="zl" aria-live="polite">1×</span><button class="btn ghost" id="zin" type="button" aria-label="Zoom in">+</button></div>
    <button class="btn ghost" id="copy" type="button"<?= $t ? ' hidden' : '' ?>>Copy link</button>
    <span class="hud" id="hud" aria-live="off">0 / 0</span>
  </div>
</div>

<div id="stage">
  <div id="field" class="noguide">
    <div id="tray" hidden></div>
    <div id="board"><img id="ghost" alt=""><svg id="slots"><path id="slotp"/></svg></div>
    <img id="final" alt="The finished picture">
  </div>
</div>

<div id="win" data-res="ok" hidden>
  <div class="winart"><span class="w-ok"><?= puzzle_cast('win-scene', '', 'pzscene') . puzzle_cast('jeff-cheer', 'Jeff cheering', 'pzface') ?></span><span class="w-caught"><?= puzzle_cast('ffej-caught', 'Ffej, caught', 'pzface') ?></span></div>
  <div class="wintx">
    <strong id="winHead">Solved!</strong>
    <span id="winText"></span>
  </div>
  <div class="row">
    <button class="btn" id="again" type="button"><?= $t ? 'Another go' : 'Play again' ?></button>
    <button class="btn ghost" id="copy2" type="button"<?= $t ? ' hidden' : '' ?>>Copy link</button>
    <button class="btn ghost" id="back2" type="button"><?= $t ? 'See the times' : 'Back to library' ?></button>
    <?php if ($pzDemo): ?><a class="btn" href="<?= e(url('register.php')) ?>">Join the Hollow</a><?php endif; ?>
  </div>
</div>

</div>
<div id="lk" hidden><input id="lkin" readonly aria-label="Link to this puzzle"><button class="btn ghost" id="lkx" type="button">Close</button></div>
