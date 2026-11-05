<?php
declare(strict_types=1);
// Living stops (v2.5.72): a read-only preview for admins. What is going on at each kind of stop today, the calendar, the stories and the meter rules.
// The content is in includes/data/stop_happenings.txt, stop_calendar.txt, stop_threads.txt and stop_act_state.txt (edit those files); nothing here changes the game.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/stops.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();
$today = hollow_date('Y-m-d');
$stops = q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll();
$byHap = [];
foreach ($stops as $l) { $hp = stop_now($l)['hp'] ?? ''; $byHap[$hp] = ($byHap[$hp] ?? 0) + 1; }
$all = stop_happenings();
page_header('Living stops', true);
?>
<?php admin_crumbs('livingstops.php'); ?>
<h1>🌱 Living stops</h1>
<p class="help">Today is <code><?= e($today) ?></code>. Read-only: edit the data files named in each heading. Meters, perks and story progress are per player.</p>

<h2>Today across <?= count($stops) ?> stops</h2>
<table class="grid"><tr><th>Happening</th><th>Stops today</th><th>Tags</th></tr>
<?php arsort($byHap); foreach ($byHap as $id => $n): $h = $all[$id] ?? null; ?>
  <tr><td><?= $h ? e($h['icon'] . ' ' . $h['name']) . (!empty($h['cal']) ? ' <small class="help">calendar</small>' : '') : '<small class="help">nothing special</small>' ?></td><td><?= (int)$n ?></td><td><small><?= $h ? e(implode(', ', $h['tags'])) : '' ?></small></td></tr>
<?php endforeach; ?></table>

<h2>Happenings <small class="help">stop_happenings.txt</small></h2>
<table class="grid"><tr><th>Name</th><th>Stop types</th><th>When</th><th>Tags</th><th>Weight</th></tr>
<?php foreach ($all as $h): if (!empty($h['cal'])) continue; ?>
  <tr><td><?= e($h['icon'] . ' ' . $h['name']) ?></td><td><small><?= e($h['types']) ?></small></td><td><small><?= e($h['cond']) ?></small></td><td><small><?= e(implode(', ', $h['tags'])) ?></small></td><td><?= (int)$h['weight'] ?></td></tr>
<?php endforeach; ?></table>

<h2>Calendar <small class="help">stop_calendar.txt</small></h2>
<table class="grid"><tr><th>Rule</th><th>Name</th><th>Stop types</th><th>Regions</th><th>Next date</th></tr>
<?php foreach (stop_calendar() as $ev):
    $next = '';
    for ($i = 0; $i <= 400 && $next === ''; $i++) { $d = gmdate('Y-m-d', strtotime($today . ' 12:00:00 UTC +' . $i . ' days')); if (stop_cal_match($ev['rule'], $d)) $next = $d; } ?>
  <tr><td><code><?= e($ev['rule']) ?></code></td><td><?= e($ev['icon'] . ' ' . $ev['name']) ?></td><td><small><?= e($ev['types']) ?></small></td><td><small><?= e(implode(', ', $ev['regions']) ?: 'all') ?></small></td><td><?= e($next) ?></td></tr>
<?php endforeach; ?></table>

<h2>Stories <small class="help">stop_threads.txt</small></h2>
<table class="grid"><tr><th>Story</th><th>Stop types</th><th>Beats</th><th>Pays</th></tr>
<?php foreach (stop_threads() as $t): ?>
  <tr><td><?= e($t['icon'] . ' ' . $t['name']) ?></td><td><small><?= e($t['types']) ?></small></td><td><small><?= e(implode(' → ', array_column($t['beats'], 'title'))) ?></small></td><td><small><?= e($t['reward']) ?></small></td></tr>
<?php endforeach; ?></table>

<h2>Meters and answers <small class="help">stop_act_state.txt</small></h2>
<p class="help">Meters: <?php foreach (STOP_METERS as $m): ?><?= e($m[0] . ' ' . $m[1]) ?> · <?php endforeach; ?>+<?= STOP_METER_GAIN ?> per thing done, −<?= STOP_METER_DECAY ?> a day, full at 100 gives <?= STOP_PERK_DAYS ?> days of one more thing to do there. Standing: <?= e(implode(', ', array_map(fn($k, $v) => "$k $v+", array_keys(STOP_FAMILIARITY), STOP_FAMILIARITY))) ?>.</p>
<table class="grid"><tr><th>Act</th><th>Needs</th><th>Moves</th></tr>
<?php foreach (stop_act_state() as $slug => $st): $a = stop_acts()[$slug] ?? null; ?>
  <tr><td><?= $a ? e($a['icon'] . ' ' . $a['name']) : '<b>missing: ' . e($slug) . '</b>' ?></td><td><code><?= e($st['needs'] ?: '-') ?></code></td><td><code><?= e($st['moves'] ?: '-') ?></code></td></tr>
<?php endforeach; ?></table>
<?php page_footer();
