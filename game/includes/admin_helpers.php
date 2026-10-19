<?php
declare(strict_types=1);
require_once __DIR__ . '/admin_menu.php';   // v1.6.3: the Admin menu and breadcrumbs

/** For one shop: [day 0-6][hour 0-23] => list of NPC names working then. */
function shop_coverage(int $shopId): array
{
    $grid = array_fill(0, 7, array_fill(0, 24, []));
    $rows = q("SELECT s.*, n.name FROM npc_schedules s JOIN npcs n ON n.id = s.npc_id
               WHERE s.shop_id = ? AND s.activity = 'working' AND n.active = 1", [$shopId])->fetchAll();
    foreach ($rows as $s) {
        foreach (schedule_days($s['days']) as $d) {
            foreach (schedule_hours((int)$s['start_hour'], (int)$s['end_hour']) as $h) {
                $grid[$d][$h][] = $s['name'];
            }
        }
    }
    return $grid;
}

function coverage_gaps(array $grid): int
{
    $gaps = 0;
    foreach ($grid as $hours) {
        foreach ($hours as $who) {
            if (!$who) $gaps++;
        }
    }
    return $gaps;
}

function render_shop_coverage(int $shopId): void
{
    $grid = shop_coverage($shopId);
    $gaps = coverage_gaps($grid);
    $days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    echo '<div class="box"><h3>Staffing coverage</h3>';
    echo $gaps ? "<p class=\"flash err\">$gaps unstaffed hour(s) a week (red). Add working schedules to fill them.</p>"
               : '<p class="flash ok">Staffed around the clock, every day.</p>';
    echo '<div class="scroll"><table class="cover"><tr><th></th>';
    for ($h = 0; $h < 24; $h++) echo '<th>' . $h . '</th>';
    echo '</tr>';
    foreach ($grid as $d => $hours) {
        echo '<tr><th>' . $days[$d] . '</th>';
        foreach ($hours as $h => $who) {
            $cls = $who ? (count($who) > 1 ? 'many' : 'one') : 'none';
            echo '<td class="' . $cls . '" title="' . e(sprintf('%s %02d:00 — %s', $days[$d], $h, $who ? implode(', ', $who) : 'nobody')) . '"></td>';
        }
        echo '</tr>';
    }
    echo '</table></div><p class="help">Hover a square to see who is working. Times are server time (UTC).</p></div>';
}
