<?php
declare(strict_types=1);
// Build plans (2.7.06): a read-only list of how each ruined haven, wonder and delve is made safe (four stages each).
// The data is GENERATED: edit claude/build-plans-base.txt and run python3 tools/scale_build_plans.py; the game reads includes/data/build_plans.txt. Nothing here changes the game.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/rebuild.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();
$plans = build_plans(true);
$lms = q('SELECT lm.name, lm.kind, r.code AS region FROM landmarks lm LEFT JOIN regions r ON r.id = lm.region_id')->fetchAll();
$byName = []; foreach ($lms as $l) $byName[strtolower((string)$l['name'])] = $l;
$kindN = []; $verbN = []; $missing = [];
foreach ($plans as $name => $st) {
    $lm = $byName[$name] ?? null; if (!$lm) $missing[] = $name; else $kindN[$lm['kind']] = ($kindN[$lm['kind']] ?? 0) + 1;
    foreach ($st as $s) $verbN[$s['verb']] = ($verbN[$s['verb']] ?? 0) + 1;
}
$needText = function (array $needs): string {
    $o = [];
    foreach ($needs as [$k, $a, $n]) $o[] = match ($k) { 'item' => $n . ' × ' . $a, 'coins' => $n . ' Petals', 'meal' => $n . ' meals', 'fine' => $n . ' fine finds', 'days' => $n . ' days, ' . $a . ' energy each', default => $k };
    return implode(', ', $o);
};
page_header('Build plans', true);
?>
<?php admin_crumbs('buildplans.php'); ?>
<h1>🧱 Build plans</h1>
<p class="help">Read-only. This data is generated: edit <code>claude/build-plans-base.txt</code> and run <code>python3 tools/scale_build_plans.py</code>. <?= count($plans) ?> places have a plan (<?= implode(', ', array_map(fn($k, $n) => e($k) . ' ' . (int)$n, array_keys($kindN), $kindN)) ?>). Stage verbs used: <?= implode(', ', array_map(fn($v, $n) => e(BUILD_VERBS[$v] ?? $v) . ' ' . (int)$n, array_keys($verbN), $verbN)) ?>.
<?php if ($missing): ?> <b>No landmark of this name:</b> <?= e(implode('; ', $missing)) ?>.<?php endif; ?></p>
<table class="grid"><tr><th>Place</th><th>Kind</th><th>Region</th><th>1</th><th>2</th><th>3</th><th>4</th></tr>
<?php foreach ($plans as $name => $st): $lm = $byName[$name] ?? null; ?>
  <tr><td><?= e($lm['name'] ?? $name) ?></td><td><small><?= e($lm['kind'] ?? '?') ?></small></td><td><small><?= e($lm['region'] ?? '') ?></small></td>
  <?php foreach ($st as $s): ?><td><b><?= e($s['name']) ?></b> <small class="help">(<?= e(BUILD_VERBS[$s['verb']] ?? $s['verb']) ?>)</small><br><small><?= e($needText($s['needs'])) ?></small></td><?php endforeach; ?></tr>
<?php endforeach; ?></table>
<?php page_footer();
