<?php
declare(strict_types=1);
/**
 * v2.0.0.1: Puzzles. Animated jigsaws for fun (no prizes, nothing saved on the server).
 * Inside the site shell (page_header/page_footer). Playing is a mode of the same page (body.pz-play: the table fills the view under the header). Styled by assets/puzzles.css, run by assets/puzzles.js.
 * Pictures are plain files in assets/img/puzzles/ (the site's CSP has no blob:, no inline script or style).
 */
require __DIR__ . '/includes/bootstrap.php';
$u = require_login();
if (setting('puzzles_open') !== '1' && !is_admin()) { flash('Puzzles are coming soon.', 'err'); redirect('games.php'); }   // v2.0.2: locked for players for now

/** id => [title, picture file, default piece count] (add a .gif to assets/img/puzzles/ and a row here) */
const PUZZLES = [
    'sunflower' => ['Swaying Sunflower', 'sunflower.gif', 54],
    'flower' => ['Spinning Flower', 'flower.gif', 54],
    'balloons' => ['Night Balloons', 'balloons.gif', 54],
    'waves' => ['Sunset Waves', 'waves.gif', 54],
    'balls' => ['Bouncing Balls', 'balls.gif', 54],
    'pig' => ['Mud Bath Pig', 'pig.gif', 96],
    'skeleton' => ['Dancing Skeleton', 'skeleton.gif', 54],
];
$list = [];
foreach (PUZZLES as $id => [$title, $file, $n]) $list[] = ['id' => $id, 'title' => $title, 'pieces' => $n, 'gif' => url('assets/img/puzzles/' . $file)];
page_header('Puzzles');   // assets/puzzles.css and assets/puzzles.js are added by page_header() for this page
?>
<div id="pz">
<div id="lib">
  <h1>🧩 Puzzles</h1>
  <p class="gtagline">Pick a picture and a piece count. The pictures move while you solve them. Just for fun: no prizes.</p>
  <ul class="pzgrid" id="grid"></ul>
  <p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
</div>
<div id="game" hidden>
<div class="bar">
  <div id="prog" role="presentation"></div>
  <div class="brand">
    <div class="gt">🧩 Puzzles</div>
    <p class="sub" id="sub">Drag pieces onto the outline; matching neighbours join. Drag the empty table to scroll.</p>
  </div>
  <div class="controls">
    <button class="btn ghost" id="back" type="button">&larr; Library</button>
    <select id="count" aria-label="Number of pieces">
      <option value="24">24 pieces</option>
      <option value="54">54 pieces</option>
      <option value="96">96 pieces</option>
      <option value="150">150 pieces</option>
    </select>
    <button class="btn ghost" id="guide" aria-pressed="false" type="button">Guide</button>
    <button class="btn ghost" id="scatter" type="button">Scatter</button>
    <div class="zoom" role="group" aria-label="Zoom"><button class="btn ghost" id="zout" type="button" aria-label="Zoom out">−</button><span id="zl" aria-live="polite">1×</span><button class="btn ghost" id="zin" type="button" aria-label="Zoom in">+</button></div>
    <button class="btn ghost" id="copy" type="button">Copy link</button>
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

<div id="win" hidden>
  <strong>Solved!</strong>
  <span id="winText"></span>
  <div class="row">
    <button class="btn" id="again" type="button">Play again</button>
    <button class="btn ghost" id="copy2" type="button">Copy link</button>
    <button class="btn ghost" id="back2" type="button">Back to library</button>
  </div>
</div>

</div>
<div id="lk" hidden><input id="lkin" readonly aria-label="Link to this puzzle"><button class="btn ghost" id="lkx" type="button">Close</button></div>
</div>
<script type="application/json" id="pz-data"><?= json_encode($list, JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?></script>
<?php page_footer();
