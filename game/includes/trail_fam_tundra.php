<?php
declare(strict_types=1);
/**
 * Tundra family layer (2.7.01): "Aurora overlay" (proposal "Warm Hut Relay"). Above a section that has a tundra Sight (a mark whose slug starts `tundra-`) a sky strip shows the aurora
 * on a winter night (CSS only: three drifting ribbons; BRIGHTER near the new moon, faint at the full moon: trail_fam_tundra_aurora). By day or out of winter it says the sky is pale and when
 * to come back. Below: the three warm huts (snow fort, lone fir, star-chart stones) with a warmth chain of 3 lamps (the Warm Hand tally, `hut-warmth`), and a chip per villager due at a
 * tundra Sight (npc_cw_sight_lines). Style: assets/style.css "Tundra family" block. No JS. Text says it; colour alone never does.
 */

const TRAIL_FAM_TUNDRA_HUTS = ['tundra-the-snow-fort', 'tundra-the-lone-fir', 'tundra-the-star-chart-stones'];

/** The aurora: ['on' bool (winter night), 'bright' 0..1 (1 at new moon), 'word', 'text', 'moon' => moon_phase]. Pure: the same day and daypart give the same sky. */
function trail_fam_tundra_aurora(int $dayIndex, string $dp, string $season): array
{
    require_once __DIR__ . '/moon.php';
    $ph = moon_phase($dayIndex);
    $on = $season === 'winter' && $dp === 'night';
    $bright = round(1 - 0.75 * $ph['light'], 2);   // new moon 1.0, full moon 0.25
    $word = $bright >= 0.85 ? 'blazing' : ($bright >= 0.6 ? 'bright' : ($bright >= 0.4 ? 'soft' : 'faint'));
    $text = $on ? 'Aurora ' . $word . ($ph['key'] === 'new' ? ' (new moon: the darkest, brightest sky)' : '')
        : ($season !== 'winter' ? 'No aurora: it only dances in winter' : 'Aurora asleep until night');
    return ['on' => $on, 'bright' => $bright, 'word' => $word, 'text' => $text, 'moon' => $ph];
}

function trail_fam_tundra(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'tundra-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, , $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $now = (array)($ctx['now'] ?? []);
    $a = trail_fam_tundra_aurora((int)$di, (string)($now['dp'] ?? 'day'), (string)($now['se'] ?? ''));
    $ph = $a['moon'];
    $lvl = (int)ceil($a['bright'] * 4);   // 1..4 brightness step for the CSS
    $h = '<section class="tftundra ' . ($a['on'] ? 'tft-on tft-b' . $lvl : 'tft-off') . '" aria-label="Aurora overlay">'
        . ($a['on'] ? '<div class="tft-sky" aria-hidden="true"><i></i><i></i><i></i></div>' : '')
        . '<div class="tft-h"><span aria-hidden="true">🌌</span> <b>' . e($a['text']) . '</b> ' . moon_pill((string)$ph['icon'], (string)$ph['name'], 'Day ' . ((int)$ph['age'] + 1) . ' of ' . MOON_DAYS . '. The aurora is brightest near the new moon.') . '</div>';
    $tl = (int)(($now['tl'] ?? [])['hut-warmth'] ?? 0);
    $huts = '';
    $nh = 0;
    foreach ($marks as $m) {
        if (!in_array($m['slug'], TRAIL_FAM_TUNDRA_HUTS, true)) continue;
        $nh++;
        $huts .= '<li class="tft-hut"><span aria-hidden="true">🛖</span> ' . e(trail_sight_label($m['slug'])[0]) . ' <b>warm</b></li>';
    }
    if ($nh) {
        $lamps = '';
        for ($i = 0; $i < 3; $i++) $lamps .= '<i class="' . ($i < min(3, $tl) ? 'on' : '') . '"></i>';
        $h .= '<ul class="tft-huts">' . $huts . '</ul>'
            . '<p class="tft-chain" role="img" aria-label="Warm Hut Relay: ' . min(3, $tl) . ' of 3 huts warmed"><span aria-hidden="true">🔥</span> <span class="tft-lamps" aria-hidden="true">' . $lamps . '</span> Warm Hut Relay: each hut warms you for 90 minutes. Huts warmed: ' . $tl . ' (a title at 3).</p>';
    }
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $key = $l['name'] . '|' . $m['slug'];
            if (isset($chips[$key]) && $chips[$key]['now'] >= $l['now']) continue;
            $chips[$key] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    $chips = array_values($chips);
    usort($chips, fn($x, $y) => [$y['now'], $y['near']] <=> [$x['now'], $x['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tft-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">🧣</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}
