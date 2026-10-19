<?php
declare(strict_types=1);
// v0.9.1: where gnome XP comes from, over the last 7 Hollow days.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';   // v1.6.3
$me = require_admin();

$days = [];
for ($i = 0; $i < 7; $i++) $days[] = hollow_date('Y-m-d', time() - $i * 86400);
$in = implode(',', array_fill(0, count($days), '?'));

$labels = [
    'do_harvest' => 'Harvests', 'win_fight' => 'Fights', 'journey_finish' => 'Journey chapters', 'finish_job' => 'Jobs',
    'rebuild_pay' => 'Repairs', 'friend_chat' => 'Townsfolk chats', 'friend_gift' => 'Townsfolk gifts',
    'apply_event_effect' => 'Events and outings', 'other' => 'Other', 'Chatting with folk' => 'Townsfolk chats', 'Gifts to folk' => 'Townsfolk gifts',
    'solve_problem' => 'Problems on the road', 'craft' => 'Crafting and cooking', 'worm_finish' => 'Games',
    'mentor_share' => 'Mentor share (from a newcomer’s XP)',   // v1.2.3
    // v1.4.5: codes that showed raw in the export; old and new names of the same thing share a label so they sit together
    'Harvesting' => 'Harvests', 'Fighting' => 'Fights', 'Crafting' => 'Crafting and cooking', 'Cooking' => 'Crafting and cooking', 'Jobs' => 'Jobs',
    'rest_stop' => 'Rest stops', 'local_do' => 'Rest stops', 'arrive' => 'Arriving somewhere new', 'explore_discover' => 'Exploring off the path',
    'explore_return' => 'Exploring off the path', 'percy_trade' => 'Garden neighbours', 'biddy_trade' => 'Garden neighbours',
    'town_quiz_answer' => 'Town quiz', 'Volunteering' => 'Florist volunteering', 'Arranging' => 'Flower arranging',
];
$label = fn(string $s) => $labels[$s] ?? $s;

$bySource = q("SELECT source, SUM(xp) AS xp FROM xp_log WHERE day IN ($in) GROUP BY source ORDER BY SUM(xp) DESC", $days)->fetchAll();
// v1.4.5: one row per label (codes listed under it)
$g = [];
foreach ($bySource as $r) { $l = $label((string)$r['source']); $g[$l]['xp'] = ($g[$l]['xp'] ?? 0) + (int)$r['xp']; $g[$l]['codes'][] = (string)$r['source']; }
uasort($g, fn($a, $b) => $b['xp'] <=> $a['xp']);
$bySource = [];
foreach ($g as $l => $v) $bySource[] = ['source' => implode(', ', $v['codes']), 'label' => $l, 'xp' => $v['xp']];
$label = function (string $s) use ($labels, $bySource) { foreach ($bySource as $r) if ($r['source'] === $s) return $r['label']; return $labels[$s] ?? $s; };
$byDay = q("SELECT day, SUM(xp) AS xp FROM xp_log WHERE day IN ($in) GROUP BY day", $days)->fetchAll();
$dayTotals = array_column($byDay, 'xp', 'day');
$total = (int)array_sum(array_column($bySource, 'xp'));
$top = q("SELECT l.user_id, u.username, u.gnome_name, u.level, SUM(l.xp) AS xp FROM xp_log l LEFT JOIN users u ON u.id = l.user_id
          WHERE l.day IN ($in) GROUP BY l.user_id, u.username, u.gnome_name, u.level ORDER BY SUM(l.xp) DESC LIMIT 10", $days)->fetchAll();

// v1.4.4: Export: one plain CSV file (sources, per day, top players) to share or open in a spreadsheet
if (($_GET['export'] ?? '') === 'csv') {
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="xp-sources-' . $days[0] . '.csv"');
    $out = fopen('php://output', 'w');
    fwrite($out, "\xEF\xBB\xBF");   // so Excel reads the emoji and accents
    fputcsv($out, ['XP sources, last 7 Hollow days', end($days) . ' to ' . $days[0]]);
    fputcsv($out, []);
    fputcsv($out, ['Source', 'Code', 'XP', 'Share %']);
    foreach ($bySource as $r) fputcsv($out, [$label((string)$r['source']), $r['source'], (int)$r['xp'], $total ? round((int)$r['xp'] * 100 / $total, 1) : 0]);
    fputcsv($out, ['Total', '', $total, 100]);
    fputcsv($out, []);
    fputcsv($out, ['Day', 'XP']);
    foreach ($days as $d) fputcsv($out, [$d, (int)($dayTotals[$d] ?? 0)]);
    fputcsv($out, []);
    fputcsv($out, ['Top player', 'Level', 'XP']);
    foreach ($top as $r) fputcsv($out, [trim((string)($r['gnome_name'] ?? '')) ?: (string)($r['username'] ?? ('#' . $r['user_id'])), (int)$r['level'], (int)$r['xp']]);
    fclose($out);
    exit;
}

page_header('XP sources', true);
?>
<?php admin_crumbs('xp.php');   // v1.6.3 ?>
<h1>📈 XP sources</h1>
<p><a class="btn small" href="<?= e(url('admin/xp.php?export=csv')) ?>" download>⬇️ Export (CSV)</a></p>
<p class="help">Gnome XP earned over the last 7 Hollow days (<?= e(end($days)) ?> to <?= e($days[0]) ?>), by where it came from.</p>
<?php if (!$bySource): ?>
  <p>No XP has been logged yet.</p>
<?php else: ?>
<table class="grid">
  <tr><th>Source</th><th>XP</th><th>Share</th></tr>
  <?php foreach ($bySource as $r): ?>
    <tr><td><?= e($label((string)$r['source'])) ?><?php if ($label((string)$r['source']) !== $r['source']): ?> <small class="help"><?= e($r['source']) ?></small><?php endif; ?></td>
      <td><?= number_format((int)$r['xp']) ?></td><td><?= $total ? round((int)$r['xp'] * 100 / $total, 1) : 0 ?>%</td></tr>
  <?php endforeach; ?>
  <tr><th>Total</th><th><?= number_format($total) ?></th><th>100%</th></tr>
</table>

<h2>Per day</h2>
<table class="grid">
  <tr><?php foreach ($days as $d): ?><th><?= e($d) ?></th><?php endforeach; ?></tr>
  <tr><?php foreach ($days as $d): ?><td><?= number_format((int)($dayTotals[$d] ?? 0)) ?></td><?php endforeach; ?></tr>
</table>

<h2>Top 10 players</h2>
<table class="grid">
  <tr><th>Player</th><th>Level</th><th>XP</th></tr>
  <?php foreach ($top as $r): ?>
    <tr><td><?= e(trim((string)($r['gnome_name'] ?? '')) ?: (string)($r['username'] ?? ('#' . $r['user_id']))) ?></td>
      <td><?= (int)$r['level'] ?></td><td><?= number_format((int)$r['xp']) ?></td></tr>
  <?php endforeach; ?>
</table>
<?php endif; ?>
<?php page_footer();
