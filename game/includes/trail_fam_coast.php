<?php
declare(strict_types=1);
/**
 * Coast family layer (2.7.01): "Tide strip". Above a section that has a coast Sight (a mark whose slug starts `coast-`; a Maplewold route can be coast land too) a small strip draws the
 * day's tide as an inline SVG arc (two highs, two lows a game day) with a notch for now, and says it in words ("Low tide in 3 h"). The tide follows the MOON (moon.php: 28 game day month, spring and neap tides, about 53 minutes later each day)
 * (ctx['clock'] = [dow, hour, game day index]; npc_cw_clock): see trail_fam_coast_tide(). Below the arc: the tide pools (Tide Table, data/trail_sights_shared.txt: they open at dawn
 * and dusk, which is where the tide lows fall, so the rows use `dp=dawn,dusk` since a `when` cannot say an hour), the Tide Reader tally, and a chip per villager due at one of the
 * section's coast Sights (npc_cw_sight_lines). Style: assets/style.css "Coast family" block. No JS. Text says the tide; colour alone never does.
 */

/** The pool Sights of the Tide Table: open at low tide (dawn and dusk). */
const TRAIL_FAM_COAST_POOLS = ['coast-the-kelp-line', 'coast-the-tide-pool-steps', 'coast-the-barnacle-wall', 'coast-the-sandbar-causeway'];

/** The tide at a clock hour: the moon's tide (moon.php): spring tides at new and full moon, small neap tides at the quarters; see moon_tide() for the keys. */
function trail_fam_coast_tide(float $hour, int $dayIndex): array
{
    require_once __DIR__ . '/moon.php';
    return moon_tide($hour, $dayIndex);
}

/** The tide arc as an inline SVG (24 h wide, the notch at $hour). */
function trail_fam_coast_svg(float $hour, int $dayIndex, array $tide): string
{
    $W = 240; $H = 44; $top = 6; $bot = 34;
    $x = fn(float $t): float => $t / 24.0 * $W;
    $y = fn(float $t): float => $top + (1 - (trail_fam_coast_tide($t, $dayIndex)['h'] + 1) / 2) * ($bot - $top);
    $pts = []; for ($m = 0; $m <= 48; $m++) { $t = $m / 2; $pts[] = round($x($t), 1) . ',' . round($y($t), 1); }
    $line = implode(' ', $pts);
    $nx = round($x($hour), 1); $ny = round($y($hour), 1);
    $alt = 'Tide today: ' . $tide['text'] . '. Lows around ' . implode(' and ', array_map(fn($t) => hour_label((int)round($t)), $tide['lows'])) . ', highs around ' . implode(' and ', array_map(fn($t) => hour_label((int)round($t)), $tide['highs'])) . '.';
    $s = '<svg class="tfc-svg" viewBox="0 0 ' . $W . ' ' . $H . '" role="img" aria-label="' . e($alt) . '" focusable="false"><title>' . e($alt) . '</title>';
    $s .= '<polygon class="tfc-sea" points="0,' . $H . ' ' . $line . ' ' . $W . ',' . $H . '"/>';
    $s .= '<polyline class="tfc-wave" fill="none" points="' . $line . '"/>';
    foreach ([6, 12, 18] as $tk) $s .= '<line class="tfc-tick" x1="' . $x((float)$tk) . '" y1="' . $bot . '" x2="' . $x((float)$tk) . '" y2="' . ($bot + 3) . '"/>';
    foreach ([[0, '12a'], [6, '6a'], [12, '12p'], [18, '6p']] as [$tk, $lb]) $s .= '<text class="tfc-lbl" x="' . ($x((float)$tk) + ($tk === 0 ? 1 : 0)) . '" y="' . ($H - 2) . '" text-anchor="' . ($tk === 0 ? 'start' : 'middle') . '">' . $lb . '</text>';
    foreach ($tide['highs'] as $t) $s .= '<text class="tfc-ex" x="' . round($x((float)$t), 1) . '" y="' . ($top - 1) . '" text-anchor="middle">H</text>';
    foreach ($tide['lows'] as $t) $s .= '<text class="tfc-ex" x="' . round($x((float)$t), 1) . '" y="' . ($bot + 1) . '" text-anchor="middle" dy="-2">L</text>';
    $s .= '<line class="tfc-nowline" x1="' . $nx . '" y1="' . $top . '" x2="' . $nx . '" y2="' . $bot . '"/><circle class="tfc-now" cx="' . $nx . '" cy="' . $ny . '" r="4"/>';
    return $s . '</svg>';
}

function trail_fam_coast(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'coast-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, $hour, $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $hour = (float)$hour; $di = (int)$di;
    $tide = trail_fam_coast_tide($hour, $di);
    $now = (array)($ctx['now'] ?? []);
    $pools = ''; $open = 0; $np = 0;
    foreach ($marks as $m) {
        if (!in_array($m['slug'], TRAIL_FAM_COAST_POOLS, true)) continue;
        $np++;
        $isOpen = trail_sight_cond_ok((string)($m['row']['when'] ?? '-'), $now);
        if ($isOpen) $open++;
        $pools .= '<li class="tfc-p ' . ($isOpen ? 'open' : 'shut') . '"><span aria-hidden="true">' . ($isOpen ? '🦀' : '🌊') . '</span> ' . e(trail_sight_label($m['slug'])[0]) . ' <b>' . ($isOpen ? 'open' : 'under water') . '</b></li>';
    }
    $h = '<section class="tfcoast tfc-' . e($tide['state']) . '" aria-label="Tide strip">'
        . '<p class="tfc-h"><span aria-hidden="true">🌊</span> <b>' . e($tide['text']) . '</b> <span class="tfc-st">(' . e($tide['state']) . ' now · ' . e(hour_label((int)floor($hour))) . ')</span> <span class="tfc-moon" title="The moon sets the tide">' . e($tide['moon']['icon']) . ' ' . e($tide['moon']['name']) . ' · ' . e($tide['range']) . ' tides · day ' . ((int)$tide['moon']['age'] + 1) . ' of ' . MOON_DAYS . '</span></p>'
        . trail_fam_coast_svg($hour, $di, $tide);
    if ($np) {
        $tl = (int)(($now['tl'] ?? [])['tide-pools'] ?? 0);
        $h .= '<p class="tfc-note">Tide pools open at low tide (' . ($tide['moon']['range'] === 'spring' ? 'big spring tides: the water goes right out' : ($tide['moon']['range'] === 'neap' ? 'small neap tides: the pools barely open' : 'middling tides')) . ').' . ($np ? ' ' . $open . ' of ' . $np . ' open here.' : '') . ' Pools worked: ' . $tl . ' (a gift at 5, a title at 12).</p><ul class="tfc-pools">' . $pools . '</ul>';
    }
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $chips[] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfc-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">🎣</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}
