<?php
declare(strict_types=1);
// v1.6.x: retention funnel. Of the players who signed up in a period: how many finished the welcome tour and came back.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();

$now = time();
$DAY = 86400;
$fmt = fn(int $t) => gmdate('Y-m-d H:i:s', $t);
// Players only: no admins, mods or banned. Only four plain columns, counted in PHP so it runs the same on MySQL and SQLite.
$rows = q("SELECT created_at, onboarded, last_seen FROM users WHERE banned = 0 AND role NOT IN ('admin','mod')")->fetchAll();
$users = [];
foreach ($rows as $r) {
    $c = strtotime((string)$r['created_at'] . ' UTC');
    if (!$c) continue;
    $l = !empty($r['last_seen']) ? strtotime((string)$r['last_seen'] . ' UTC') : 0;
    $users[] = ['c' => $c, 'on' => (int)$r['onboarded'] === 1, 'l' => $l ?: 0];
}

/** Funnel for signups with $from <= created < $to. Day-N figures only count players old enough to have had N days. */
function retention_funnel(array $users, int $from, int $to, int $now): array
{
    $D = 86400;
    $f = ['signed' => 0, 'tour' => 0, 'd1' => 0, 'd1e' => 0, 'd7' => 0, 'd7e' => 0, 'd30' => 0, 'd30e' => 0, 'act' => 0];
    foreach ($users as $u) {
        if ($u['c'] < $from || $u['c'] >= $to) continue;
        $f['signed']++;
        if ($u['on']) $f['tour']++;
        foreach ([1 => 'd1', 7 => 'd7', 30 => 'd30'] as $n => $k) {
            if ($u['c'] + $n * $D <= $now) { $f[$k . 'e']++; if ($u['l'] >= $u['c'] + $n * $D) $f[$k]++; }
        }
        if ($u['l'] >= $now - 7 * $D) $f['act']++;
    }
    return $f;
}
$pct = fn(int $n, int $d) => $d > 0 ? round($n * 100 / $d, 1) . '%' : '–';

$cohorts = [
    ['Last 7 days', $now - 7 * $DAY, $now + 1],
    ['Last 30 days', $now - 30 * $DAY, $now + 1],
    ['All time', 0, $now + 1],
];
// weekly cohorts: 8 weeks, Monday to Sunday (UTC), this week first
$mon = strtotime('monday this week 00:00:00 UTC', $now);
for ($i = 0; $i < 8; $i++) {
    $s = $mon - $i * 7 * $DAY;
    $cohorts[] = ['Week of ' . gmdate('M j', $s) . ($i === 0 ? ' (so far)' : ''), $s, $s + 7 * $DAY];
}
$data = [];
foreach ($cohorts as [$name, $a, $b]) $data[] = [$name, retention_funnel($users, $a, $b, $now)];

$steps = [
    ['Signed up', 'signed', null],
    ['Finished the tour', 'tour', 'signed'],
    ['Back after day 1', 'd1', 'd1e'],
    ['Back after day 7', 'd7', 'd7e'],
    ['Back after day 30', 'd30', 'd30e'],
    ['Active in last 7 days', 'act', 'signed'],
];

if (($_GET['export'] ?? '') === 'csv') {
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="retention-' . gmdate('Y-m-d', $now) . '.csv"');
    $out = fopen('php://output', 'w');
    fwrite($out, "\xEF\xBB\xBF");
    fputcsv($out, ['Cohort', 'Signed up', 'Finished tour', 'Tour %', 'Day 1 back', 'Day 1 eligible', 'Day 1 %', 'Day 7 back', 'Day 7 eligible', 'Day 7 %', 'Day 30 back', 'Day 30 eligible', 'Day 30 %', 'Active 7d', 'Active 7d %']);
    foreach ($data as [$name, $f]) {
        fputcsv($out, [$name, $f['signed'], $f['tour'], $pct($f['tour'], $f['signed']), $f['d1'], $f['d1e'], $pct($f['d1'], $f['d1e']),
            $f['d7'], $f['d7e'], $pct($f['d7'], $f['d7e']), $f['d30'], $f['d30e'], $pct($f['d30'], $f['d30e']), $f['act'], $pct($f['act'], $f['signed'])]);
    }
    fclose($out);
    exit;
}

page_header('Retention', true);
?>
<?php admin_crumbs('retention.php'); ?>
<h1>🔁 Retention</h1>
<p><a class="btn small" href="<?= e(url('admin/retention.php?export=csv')) ?>" download>⬇️ Export (CSV)</a></p>
<p class="help">Of the players who signed up in each period: how many finished the welcome tour and came back. Admins, moderators and banned players are left out. “Back after day N” only counts players who signed up at least N days ago.</p>
<p class="help">Heads up: the game only remembers each player’s latest visit, so a player who came back on day 2 but also played on day 40 counts as back after day 30. Day 1 and 7 are a little too high, not too low.</p>
<?php
$box = function (array $list) use ($data, $steps, $pct) { ?>
<table class="grid">
  <tr><th>Step</th><?php foreach ($list as $i): ?><th><?= e($data[$i][0]) ?></th><?php endforeach; ?></tr>
  <?php foreach ($steps as [$label, $k, $den]): ?>
    <tr><td><?= e($label) ?></td>
    <?php foreach ($list as $i): $f = $data[$i][1]; $d = $den === null ? 0 : $f[$den]; ?>
      <td><?= number_format($f[$k]) ?><?php if ($den !== null): ?> <small class="help"><?= $pct($f[$k], $d) ?><?= $den !== 'signed' ? ' of ' . number_format($d) : '' ?></small><?php endif; ?></td>
    <?php endforeach; ?></tr>
  <?php endforeach; ?>
</table>
<?php };
?>
<div class="box"><h2>Overview</h2><?php $box([0, 1, 2]); ?></div>
<h2>Weekly sign-ups</h2>
<?php for ($i = 3; $i < count($data); $i += 2): ?>
  <div class="box"><?php $box(array_filter([$i, $i + 1], fn($x) => $x < count($data))); ?></div>
<?php endfor; ?>
