<?php
declare(strict_types=1);
/**
 * Lair family layer (2.7.01): "Footprint tracker" (proposal-route-sights.md, lair end pieces). Above a section that has a lair Sight (a mark whose slug starts `end-lair-`) a strip shows
 * (1) how old the tracks are: days since the last full moon (0-5 fresh, 6-13 fading, 14+ old; tracks are freshest after a full moon), as a row of prints in words too, (2) a line per lair mouth
 * (tracks read this cooldown or not, and whether it is a track-reading Sight with a hint), (3) the true creature hint of the lair ahead (same source as `hint=creature`) and the Long Looker tally,
 * and up to 2 villager chips from npc_cw_sight_lines. Pure function of the clock (ctx['clock'] = [dow, hour, day index], moon.php). Style: assets/style.css "Lair family" block. No JS.
 */

/** Days since the last full moon (0..27) for a game day. */
function trail_fam_lair_days(int $dayIndex): int
{
    return ((moon_phase($dayIndex)['age'] - 14) % MOON_DAYS + MOON_DAYS) % MOON_DAYS;
}

/** [key, label, prints 1..5] for tracks that many days after the full moon. */
function trail_fam_lair_age(int $days): array
{
    if ($days <= 5) return ['fresh', 'Fresh', 5];
    if ($days <= 13) return ['fading', 'Fading', 3];
    return ['old', 'Old', 1];
}

function trail_fam_lair(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'end-lair-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    require_once __DIR__ . '/moon.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, , $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $mo = moon_phase((int)$di);
    $days = trail_fam_lair_days((int)$di);
    [$ak, $al, $np] = trail_fam_lair_age($days);
    $prints = '<span class="tfl-prints" aria-hidden="true">' . str_repeat('<i class="on">🐾</i>', $np) . str_repeat('<i>·</i>', 5 - $np) . '</span>';
    $when = $days === 0 ? 'the full moon is tonight' : ($days === 1 ? '1 day since the full moon' : $days . ' days since the full moon');
    $h = '<section class="tflair tfl-' . $ak . '" aria-label="Footprint tracker">'
        . '<p class="tfl-h"><span aria-hidden="true">' . e($mo['icon']) . '</span> <b>' . e($al) . ' tracks</b> · ' . e($mo['name']) . '</p>'
        . '<p class="tfl-age">' . $prints . ' <small>(' . e($when) . '; tracks are freshest after a full moon)</small></p>';
    $li = '';
    foreach ($marks as $m) {
        $used = (int)($m['left'] ?? 0) < (int)($m['row']['uses'] ?? 1);
        $reads = str_starts_with((string)($m['row']['check'] ?? ''), 'pick');
        $li .= '<li class="tfl-t ' . ($used ? 'read' : 'unread') . '"><span class="tfl-ico" aria-hidden="true">' . ($used ? '📖' : '🐾') . '</span><span class="tfl-nm">' . e(trail_sight_label($m['slug'])[0]) . '</span>'
            . '<span class="tfl-st">' . ($used ? 'read' : 'not read yet') . ($reads ? ' · track reading' : '') . '</span></li>';
    }
    $h .= '<ul class="tfl-list">' . $li . '</ul>';
    $hint = '';
    if (!empty($ctx['exp']['from_id'])) {
        $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$ctx['exp']['from_id']]) ?: [];
        if ($loc && function_exists('trail_sight_hint')) $hint = trail_sight_hint((array)($ctx['u'] ?? []), $loc, 'creature');
    }
    if ($hint !== '' && $ak !== 'old') $h .= '<p class="tfl-hint">' . e($hint) . ' (' . strtolower($al) . ' tracks: a good read is worth trusting)</p>';
    elseif ($hint !== '') $h .= '<p class="tfl-hint">' . e($hint) . ' (old tracks, read them with care)</p>';
    $tl = (int)((($ctx['now'] ?? [])['tl'] ?? [])['lair-looks'] ?? 0);
    $h .= '<p class="tfl-tally">Looks at lairs so far: ' . $tl . ' (a title at 12; tracks read right pay extra when fresh)</p>';
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $chips[] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfl-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">🧑‍🔧</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}
