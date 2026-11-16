<?php
declare(strict_types=1);
/**
 * Island family layer (2.7.01): "Ferry strip" (proposal "Ferry Timetable"). Above a section that has an island Sight (a mark whose slug starts `island-`) a strip draws the
 * day's ferry as an inline SVG lane (24 h wide) with the two docked windows and a boat dot for now, and says it in words ("Ferry at the dock, leaves in 1 h"). The ferry is a
 * pure function of the game clock like the tide (trail_fam_island_ferry): a 12 hour rhythm, it docks at 6 and at 18 for 2 hours (6 to 8 am, 6 to 8 pm) and is away on its round the
 * rest of the time. The hammock palms are only reachable by a crossing: their row has `when` = dp=dawn,dusk, the data approximation of the two docked windows (a `when` cannot say an
 * hour; dawn is 5 to 7, dusk 6 to 9 pm, so the row and the strip can disagree by an hour at the edges). Below the strip: the palms (open / no boat), the crossings tally, and a chip per
 * villager due at one of the section's island Sights (npc_cw_sight_lines). Style: assets/style.css "Island family" block. No JS. Text says it; colour alone never does.
 */

const TRAIL_FAM_ISLAND_DOCK = [6.0, 18.0];   // hours the ferry docks, a 12 hour rhythm
const TRAIL_FAM_ISLAND_STAY = 2.0;           // hours it waits at the dock
const TRAIL_FAM_ISLAND_PALMS = 'island-the-hammock-palms';

/** The ferry at a clock hour: state 'docked' | 'away', hours to the change, the text. Pure: the same hour gives the same answer. */
function trail_fam_island_ferry(float $hour, int $dayIndex = 0): array
{
    $hour = fmod(fmod($hour, 24.0) + 24.0, 24.0);
    $phase = fmod($hour - TRAIL_FAM_ISLAND_DOCK[0] + 24.0, 12.0);   // 0..12 since the last docking
    $docked = $phase < TRAIL_FAM_ISLAND_STAY;
    $in = $docked ? (int)ceil(TRAIL_FAM_ISLAND_STAY - $phase - 1e-9) : (int)ceil(12.0 - $phase - 1e-9);
    $nextAt = fmod($hour + ($docked ? TRAIL_FAM_ISLAND_STAY - $phase : 12.0 - $phase), 24.0);
    $text = $docked ? 'Ferry at the dock, leaves in ' . max(1, $in) . ' h' : 'Ferry away, back in ' . max(1, $in) . ' h';
    // where the boat dot sits on the lane (0 at the dock, 1 far out): away it sails out and back
    $pos = $docked ? 0.0 : sin(M_PI * ($phase - TRAIL_FAM_ISLAND_STAY) / (12.0 - TRAIL_FAM_ISLAND_STAY));
    return ['hour' => $hour, 'state' => $docked ? 'docked' : 'away', 'in' => max(1, $in), 'next' => round($nextAt, 1), 'text' => $text, 'pos' => $pos, 'docks' => TRAIL_FAM_ISLAND_DOCK];
}

function trail_fam_island_svg(array $f): string
{
    $W = 240; $H = 44; $lane = 20;
    $x = fn(float $t): float => $t / 24.0 * $W;
    $alt = 'Ferry timetable: the ferry docks at ' . hour_label(6) . ' and ' . hour_label(18) . ' for ' . (int)TRAIL_FAM_ISLAND_STAY . ' hours each. ' . $f['text'] . '.';
    $s = '<svg class="tfi-svg" viewBox="0 0 ' . $W . ' ' . $H . '" role="img" aria-label="' . e($alt) . '" focusable="false"><title>' . e($alt) . '</title>';
    $s .= '<line class="tfi-lane" x1="0" y1="' . $lane . '" x2="' . $W . '" y2="' . $lane . '"/>';
    foreach (TRAIL_FAM_ISLAND_DOCK as $d) $s .= '<rect class="tfi-dock" x="' . round($x($d), 1) . '" y="' . ($lane - 8) . '" width="' . round($x(TRAIL_FAM_ISLAND_STAY), 1) . '" height="16"/>';
    foreach ([6, 12, 18] as $tk) $s .= '<line class="tfi-tick" x1="' . $x((float)$tk) . '" y1="' . ($lane + 10) . '" x2="' . $x((float)$tk) . '" y2="' . ($lane + 13) . '"/>';
    foreach ([[0, '12a'], [6, '6a'], [12, '12p'], [18, '6p']] as [$tk, $lb]) $s .= '<text class="tfi-lbl" x="' . ($x((float)$tk) + ($tk === 0 ? 1 : 0)) . '" y="' . ($H - 2) . '" text-anchor="' . ($tk === 0 ? 'start' : 'middle') . '">' . $lb . '</text>';
    $nx = round($x($f['hour']), 1);
    $by = round($lane - $f['pos'] * 12, 1);
    $s .= '<line class="tfi-nowline" x1="' . $nx . '" y1="3" x2="' . $nx . '" y2="' . ($lane + 10) . '"/><circle class="tfi-boat" cx="' . $nx . '" cy="' . $by . '" r="4"/>';
    return $s . '</svg>';
}

function trail_fam_island(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'island-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, $hour, $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $hour = (float)$hour; $di = (int)$di;
    $f = trail_fam_island_ferry($hour, $di);
    $now = (array)($ctx['now'] ?? []);
    $h = '<section class="tfisland tfi-' . e($f['state']) . '" aria-label="Ferry strip">'
        . '<p class="tfi-h"><span aria-hidden="true">⛴️</span> <b>' . e($f['text']) . '</b> <span class="tfi-st">(' . e($f['state'] === 'docked' ? 'docked now' : 'away now') . ' · ' . e(hour_label((int)floor($hour))) . ' · crossings at ' . e(hour_label(6)) . ' and ' . e(hour_label(18)) . ')</span></p>'
        . trail_fam_island_svg($f);
    $palms = '';
    foreach ($marks as $m) {
        if ($m['slug'] !== TRAIL_FAM_ISLAND_PALMS) continue;
        $isOpen = trail_sight_cond_ok((string)($m['row']['when'] ?? '-'), $now);
        $tl = (int)(($now['tl'] ?? [])['crossings'] ?? 0);
        $palms = '<p class="tfi-note">The hammock palms are only reachable by a crossing (dawn or dusk boat). Crossings made: ' . $tl . ' (a gift at 5, a title at 12).</p>'
            . '<ul class="tfi-palms"><li class="tfi-p ' . ($isOpen ? 'open' : 'shut') . '"><span aria-hidden="true">' . ($isOpen ? '🌴' : '🌊') . '</span> ' . e(trail_sight_label($m['slug'])[0]) . ' <b>' . ($isOpen ? 'open: the boat is in' : 'no boat now') . '</b></li></ul>';
    }
    $h .= $palms;
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $chips[] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfi-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">💌</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}
