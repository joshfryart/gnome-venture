<?php
declare(strict_types=1);
/**
 * Wetland family layer (2.7.01): "Reed-line ripples" and the firefly dusk row. Above a section with a wetland Sight (a mark whose slug starts `wetland-`) a strip shows one ripple per Sight
 * (an open ring when the Sight works now, a dashed ring when it is resting, said in words as well), the Stepping Stones tally, and a firefly row: 8 lamps of which more are lit the
 * nearer the MOON is to new (moon.php: moon_phase()['light'] is 0 at new moon), only after dusk. The reed-causeway `firefly-light` reward uses the same `mo=new` rule. Below: a chip per villager due at one of
 * the section's wetland Sights (npc_cw_sight_lines). Style: assets/style.css "Wetland family" block. No JS. Motion stops under prefers-reduced-motion.
 */

/** The Stepping Stones Sight (nimble pick chain; a miss costs only energy). */
const TRAIL_FAM_WETLAND_FORD = 'wetland-the-lily-pad-ford';

/** The fireflies for a game day and part of day: ['lit' 0..8, 'of' 8, 'out' bool (dusk or night), 'word', 'moon']. Brighter near the new moon. */
function trail_fam_wetland_fireflies(int $dayIndex, string $dp): array
{
    require_once __DIR__ . '/moon.php';
    $ph = moon_phase($dayIndex);
    $lit = 2 + (int)round(6 * (1 - $ph['light']));   // new moon 8, full moon 2
    $out = in_array($dp, ['dusk', 'night'], true);
    $word = $lit >= 7 ? 'blazing' : ($lit >= 5 ? 'bright' : ($lit >= 3 ? 'dim' : 'faint'));
    return ['lit' => $lit, 'of' => 8, 'out' => $out, 'word' => $word, 'moon' => $ph];
}

function trail_fam_wetland(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'wetland-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, $hour, $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $di = (int)$di;
    $now = (array)($ctx['now'] ?? []);
    $dp = (string)($now['dp'] ?? 'day');
    $ff = trail_fam_wetland_fireflies($di, $dp);
    $ph = $ff['moon'];
    $rip = ''; $hasFord = false;
    foreach ($marks as $m) {
        $isOpen = trail_sight_cond_ok((string)($m['row']['when'] ?? '-'), $now);
        if ($m['slug'] === TRAIL_FAM_WETLAND_FORD) $hasFord = true;
        $rip .= '<li class="tfw-r ' . ($isOpen ? 'open' : 'rest') . '"><span class="tfw-ring" aria-hidden="true"></span> ' . e(trail_sight_label($m['slug'])[0]) . ' <b>' . ($isOpen ? 'rippling' : 'still') . '</b></li>';
    }
    $h = '<section class="tfwetland' . ($ff['out'] ? ' tfw-dusk' : '') . '" aria-label="Reed-line ripples">'
        . '<div class="tfw-h"><span aria-hidden="true">🪷</span> <b>Reed-line ripples</b> ' . moon_pill((string)$ph['icon'], (string)$ph['name'], 'Day ' . ((int)$ph['age'] + 1) . ' of ' . MOON_DAYS . '. The moon sets the fireflies: brightest near the new moon.') . '</div>'
        . '<ul class="tfw-rips">' . $rip . '</ul>';
    if ($hasFord) {
        $st = (int)(($now['tl'] ?? [])['stones'] ?? 0);
        $h .= '<p class="tfw-note">Stepping Stones: pick the stone that holds. A slip costs only a little energy. Crossings: ' . $st . ' (a gift at 5, a title at 12).</p>';
    }
    $lamps = '';
    for ($i = 0; $i < $ff['of']; $i++) $lamps .= '<i class="' . ($ff['out'] && $i < $ff['lit'] ? 'on' : '') . '"></i>';
    $h .= '<p class="tfw-ff" role="img" aria-label="Fireflies: ' . ($ff['out'] ? $ff['lit'] . ' of ' . $ff['of'] . ' lamps lit, ' . $ff['word'] : 'asleep until dusk') . '"><span aria-hidden="true">✨</span> <span class="tfw-lamps" aria-hidden="true">' . $lamps . '</span> '
        . ($ff['out'] ? 'Fireflies ' . e($ff['word']) . ' (' . $ff['lit'] . ' of ' . $ff['of'] . ')' . ($ph['key'] === 'new' ? ', best near the new moon' : '') : 'Fireflies asleep until dusk (brightest at new moon)') . '</p>';
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $chips[] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfw-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">🐸</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}
