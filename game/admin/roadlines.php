<?php
declare(strict_types=1);
// Road lines (2.7.06): a read-only look at data/road_lines.txt, the one-line ambience of each road space: how many lines each landscape and region has, and every row.
// Wording can be changed in Admin > Road text; new rows go in the data file (cond|lands|region|text). Nothing here changes the game.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/road_life.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();
$rows = road_lines(true);
$lands = ['forest', 'grassland', 'coast', 'mountain', 'desert', 'rainforest', 'wetland', 'tundra', 'island'];
$byLand = array_fill_keys($lands, 0); $byRegion = []; $anyLand = 0;
foreach ($rows as $r) {
    if ($r['lands'] === ['any']) $anyLand++; else foreach ($r['lands'] as $l) if (isset($byLand[$l])) $byLand[$l]++;
    foreach ($r['region'] as $g) $byRegion[$g] = ($byRegion[$g] ?? 0) + 1;
}
ksort($byRegion);
page_header('Road lines', true);
?>
<?php admin_crumbs('roadlines.php'); ?>
<h1>🛣️ Road lines</h1>
<p class="help">Read-only. <?= count($rows) ?> lines in <code>data/road_lines.txt</code> (format <code>cond|lands|region|text</code>). Change the wording in <a href="<?= e(url('admin/road_text.php')) ?>">Road text</a>; add rows in the data file.</p>
<h2>Coverage</h2>
<table class="grid"><tr><th>Landscape</th><?php foreach ($lands as $l): ?><th><?= e($l) ?></th><?php endforeach; ?><th>any</th></tr>
  <tr><td>Lines that name it</td><?php foreach ($lands as $l): ?><td><?= (int)$byLand[$l] ?><?= $byLand[$l] === 0 ? ' ⚠️' : '' ?></td><?php endforeach; ?><td><?= (int)$anyLand ?></td></tr></table>
<p class="help">By region: <?php foreach ($byRegion as $g => $n): ?><b><?= e($g) ?></b> <?= (int)$n ?> · <?php endforeach; ?></p>
<h2>Every line</h2>
<table class="grid"><tr><th>When</th><th>Landscape</th><th>Region</th><th>Text</th></tr>
<?php foreach ($rows as $r): ?>
  <tr><td><small><?= e($r['cond']) ?></small></td><td><small><?= e(implode(', ', $r['lands'])) ?></small></td><td><small><?= e(implode(', ', $r['region'])) ?></small></td><td><?= e($r['text']) ?></td></tr>
<?php endforeach; ?></table>
<?php page_footer();
