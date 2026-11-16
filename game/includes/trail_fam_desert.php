<?php
declare(strict_types=1);
/**
 * Desert family layer (2.7.01): "Caravan Stop". Above a section with a desert Sight (a mark whose slug starts `desert-`) a strip shows the heat and the shade. By DAY the heat is a gauge
 * (sun strength 0-5 from the hour, one more in heat weather; the water gauge is what the sun leaves) with a shimmer on the heading, and a pip per shady Sight (awning, arch, well, cactus
 * garden, tent poles). At NIGHT (and dusk) it is the cool strip: the moon (moon.php) and the cool-night bonus Sights (rewards with `mo=`). Under it: the Caravan Stop line (Tobias Trundle
 * camps at the tent poles every 7th game day, a flask of well water for a seed; he is a traveller, he keeps his own circuit) and up to 2 villager chips from npc_cw_sight_lines.
 * Style: assets/style.css "Desert family" block. No JS. Words say everything; colour never does alone.
 */

const TRAIL_FAM_DESERT_SHADE = ['desert-the-shade-awning' => 'awning', 'desert-the-red-rock-arch' => 'arch', 'desert-the-well-and-its-rope' => 'well', 'desert-the-cactus-garden' => 'cactus garden', 'desert-the-trader-s-tent-poles' => 'tent poles'];
const TRAIL_FAM_DESERT_COOL = ['desert-the-sun-bleached-bones', 'desert-the-mirage-pool'];
const TRAIL_FAM_DESERT_POLES = 'desert-the-trader-s-tent-poles';

/** Sun strength 0 (night) to 5 (noon, plus one in heat weather, capped at 5) at a clock hour. */
function trail_fam_desert_sun(float $hour, string $we = ''): int
{
    if ($hour < 6 || $hour >= 18) return 0;
    $s = (int)round(sin(($hour - 6) / 12 * M_PI) * 4);
    return max(0, min(5, $s + ($we === 'heat' ? 1 : 0)));
}

function trail_fam_desert(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'desert-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    require_once __DIR__ . '/moon.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, $hour, $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $hour = (float)$hour; $di = (int)$di;
    $now = (array)($ctx['now'] ?? []);
    $dp = (string)($now['dp'] ?? 'day');
    $we = (string)($now['we'] ?? '');
    $night = $dp === 'night' || $dp === 'dusk';
    $moon = moon_phase($di);
    $sun = trail_fam_desert_sun($hour, $we);
    $slugs = array_column($marks, 'slug');
    $h = '<section class="tfdesert tfd-' . ($night ? 'cool' : 'hot') . ($sun >= 4 ? ' tfd-shimmer' : '') . '" aria-label="Caravan stop">';
    if (!$night) {
        $water = 5 - $sun;
        $pips = '';
        for ($i = 1; $i <= 5; $i++) $pips .= '<i class="' . ($i <= $water ? 'on' : 'off') . '"></i>';
        $word = $sun >= 4 ? 'Fierce sun: stay in the shade' : ($sun >= 2 ? 'Warm sun' : 'Gentle sun');
        $h .= '<p class="tfd-h"><span class="tfd-sun" aria-hidden="true">☀️</span> <b>' . e($word) . '</b> <span class="tfd-st">(sun ' . $sun . ' of 5' . ($we === 'heat' ? ', heat wave' : '') . ' · ' . e(hour_label((int)floor($hour))) . ')</span></p>'
            . '<p class="tfd-gauge" role="img" aria-label="Water gauge: ' . $water . ' of 5. The sun drains it, shade and the well top it up."><span class="tfd-gl">Water</span><span class="tfd-pips" aria-hidden="true">' . $pips . '</span><span class="tfd-gt">' . $water . ' of 5</span></p>';
    } else {
        $nh = '<p class="tfd-h"><span aria-hidden="true">' . e($moon['icon']) . '</span> <b>Cool ' . ($dp === 'dusk' ? 'dusk' : 'night') . '</b> <span class="tfd-st">(' . e($moon['name']) . ' · day ' . ($moon['age'] + 1) . ' of ' . MOON_DAYS . ')</span></p>';
        $bonus = '';
        foreach ($marks as $m) {
            if (!in_array($m['slug'], TRAIL_FAM_DESERT_COOL, true)) continue;
            $on = $dp === 'night' && in_array($moon['key'], ['full', 'waxing-gibbous', 'waning-gibbous'], true) && $m['slug'] === 'desert-the-sun-bleached-bones'
                || $dp === 'night' && $moon['key'] === 'full' && $m['slug'] === 'desert-the-mirage-pool';
            $bonus .= '<li class="tfd-b ' . ($on ? 'on' : 'off') . '"><span aria-hidden="true">' . ($on ? '🌙' : '·') . '</span> ' . e(trail_sight_label($m['slug'])[0]) . ' <b>' . ($on ? 'cool-night bonus tonight' : 'no bonus tonight') . '</b></li>';
        }
        if ($bonus) $nh .= '<ul class="tfd-bl">' . $bonus . '</ul>';
        $h .= moon_pill((string)$moon['icon'], 'Cool ' . ($dp === 'dusk' ? 'dusk' : 'night') . ' · ' . $moon['name'], $nh);
    }
    $shade = '';
    foreach ($marks as $m) {
        if (!isset(TRAIL_FAM_DESERT_SHADE[$m['slug']])) continue;
        $shade .= '<li class="tfd-sh"><span aria-hidden="true">' . ($night ? '·' : '🌴') . '</span> ' . e(TRAIL_FAM_DESERT_SHADE[$m['slug']]) . '</li>';
    }
    if ($shade) $h .= '<ul class="tfd-shade" aria-label="Shade and water here">' . $shade . '</ul>';
    if (in_array(TRAIL_FAM_DESERT_POLES, $slugs, true)) {
        $seventh = ((int)($now['gd'] ?? -1)) % 7 === 0;
        $trades = (int)(($now['tl'] ?? [])['caravan-trades'] ?? 0);
        $h .= '<p class="tfd-cv"><span aria-hidden="true">🐢</span> Caravan Stop: ' . ($seventh ? 'it is the seventh day, Tobias Trundle may be at the tent poles (when his circuit brings him here). A flask of well water buys a rare seed.' : 'Tobias Trundle camps at the tent poles on the seventh day, circuit permitting. Bring a flask of well water for a seed.') . ' Trades: ' . $trades . '</p>';
    }
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $chips[] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfd-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">🏜️</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}
