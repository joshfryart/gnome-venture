<?php
declare(strict_types=1);
/**
 * Grassland family layer (2.7.01): "Kite sky strip". Above a section that has a grassland Sight (a mark whose slug starts `grassland-`) a sky strip shows the wind from the TRUE weather
 * (ctx['now']['we'], the same weather the Sights read): an arrow that points where the wind blows, a speed in words and numbers, a kite that flies higher the harder it blows, and a verdict
 * ("Kite day" on wind days). Under it: the kite Sights (the wind-combed meadow, the dandelion drift, the sleepy windmill: they pay more when we=wind), the Kite String tally, and the
 * progress of "Mabel's Sky Letters" (which weather each letter still needs, and whether today's weather is one of them). Mabel's chip comes from the clockwork (npc_cw_sight_lines).
 * Speed and direction are pure functions of the game day and hour (no storage). Style: assets/style.css "Grassland family" block (prefix tfg). No JS. Words carry the meaning; colour never does.
 */

/** The kite Sights: they pay more on wind days (`we=wind` reward rows in data/trail_sights_shared.txt). */
const TRAIL_FAM_GRASSLAND_KITE = ['grassland-the-wind-combed-meadow', 'grassland-the-dandelion-drift', 'grassland-the-sleepy-windmill'];
const TRAIL_FAM_GRASSLAND_QUEST = 'mabels-sky-letters';
/** weather key => [min, max] wind speed (mph) and the word for it. */
const TRAIL_FAM_GRASSLAND_SPEED = ['wind' => [22, 38], 'storm' => [45, 62], 'sun' => [3, 12], 'cloud' => [5, 14], 'rain' => [6, 16], 'fog' => [0, 4], 'frost' => [1, 7], 'heat' => [0, 6], 'snow' => [2, 9]];
const TRAIL_FAM_GRASSLAND_DIRS = ['north', 'north-east', 'east', 'south-east', 'south', 'south-west', 'west', 'north-west'];
const TRAIL_FAM_GRASSLAND_WX = ['sun' => ['☀️', 'sun'], 'cloud' => ['☁️', 'cloud'], 'wind' => ['💨', 'wind'], 'rain' => ['🌧️', 'rain'], 'fog' => ['🌫️', 'fog'], 'storm' => ['⛈️', 'storm'], 'frost' => ['🥶', 'frost'], 'heat' => ['🌡️', 'heat'], 'snow' => ['🌨️', 'snow']];

/** The wind now: ['mph', 'dir' (0-7), 'dirName', 'word', 'kite' (none|low|good|wild), 'verdict', 'level' 0..1]. A pure function of the weather, the game day and the hour. */
function trail_fam_grassland_wind(string $we, float $hour, int $dayIndex): array
{
    require_once __DIR__ . '/hollow_clock.php';
    [$lo, $hi] = TRAIL_FAM_GRASSLAND_SPEED[$we] ?? [3, 10];
    $u = hollow_unit('tfg|' . $dayIndex . '|' . (int)floor($hour / 3));
    $mph = (int)round($lo + $u * ($hi - $lo));
    $dir = (int)floor(hollow_unit('tfgdir|' . $dayIndex . '|' . (int)floor($hour / 8)) * 8) % 8;
    $word = $mph < 4 ? 'still air' : ($mph < 13 ? 'a light breeze' : ($mph < 25 ? 'a fresh wind' : ($mph < 40 ? 'a strong wind' : 'a gale')));
    $kite = $we === 'storm' || $mph >= 40 ? 'wild' : ($mph >= 18 ? 'good' : ($mph >= 6 ? 'low' : 'none'));
    $verdict = ['good' => 'Kite day: the wind is up', 'low' => 'A kite would only just lift', 'none' => 'No kite weather: the string hangs', 'wild' => 'Too wild for a kite: it would take you with it'][$kite];
    return ['mph' => $mph, 'dir' => $dir, 'dirName' => TRAIL_FAM_GRASSLAND_DIRS[$dir], 'word' => $word, 'kite' => $kite, 'verdict' => $verdict, 'level' => min(1.0, $mph / 40)];
}

/** The sky as an inline SVG: grass line, a kite on a string (higher in a harder wind), an arrow pointing where the wind blows (a compass-ish rose: the arrow points TOWARDS the compass way, 0 = north = up). */
function trail_fam_grassland_svg(array $w, string $we): string
{
    $kx = 60 + $w['level'] * 70; $ky = 52 - $w['level'] * 36; $gx = 20; $gy = 54;
    $alt = 'Wind today: ' . $w['word'] . ', ' . $w['mph'] . ' mph, blowing towards the ' . $w['dirName'] . '. ' . $w['verdict'] . '.';
    $s = '<svg class="tfg-svg" viewBox="0 0 240 64" role="img" aria-label="' . e($alt) . '" focusable="false"><title>' . e($alt) . '</title>';
    $s .= '<rect class="tfg-sky" x="0" y="0" width="240" height="64"/><path class="tfg-grass" d="M0 58 Q30 52 60 58 T120 58 T180 58 T240 56 V64 H0 Z"/>';
    $s .= '<path class="tfg-string" fill="none" d="M' . $gx . ' ' . $gy . ' Q' . round(($gx + $kx) / 2 + 6) . ' ' . round(($gy + $ky) / 2 + 12) . ' ' . round($kx, 1) . ' ' . round($ky + 7, 1) . '"/>';
    $s .= '<polygon class="tfg-kite" points="' . round($kx, 1) . ',' . round($ky - 8, 1) . ' ' . round($kx + 7, 1) . ',' . round($ky, 1) . ' ' . round($kx, 1) . ',' . round($ky + 8, 1) . ' ' . round($kx - 7, 1) . ',' . round($ky, 1) . '"/>';
    $s .= '<g transform="translate(206 28) rotate(' . ($w['dir'] * 45) . ')"><circle class="tfg-dial" r="17"/><path class="tfg-arrow" d="M0 -13 L6 -3 H2 V12 H-2 V-3 H-6 Z"/></g>';
    $s .= '<text class="tfg-n" x="206" y="6" text-anchor="middle">N</text>';
    return $s . '</svg>';
}

function trail_fam_grassland(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'grassland-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, $hour, $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $now = (array)($ctx['now'] ?? []);
    $we = (string)($now['we'] ?? 'sun');
    $w = trail_fam_grassland_wind($we, (float)$hour, (int)$di);
    $wx = TRAIL_FAM_GRASSLAND_WX[$we] ?? ['🌤️', $we];
    $h = '<section class="tfgrass tfg-' . e($w['kite']) . '" aria-label="Kite sky strip">'
        . '<p class="tfg-h"><span aria-hidden="true">🪁</span> <b>' . e($w['verdict']) . '</b> <span class="tfg-st">(' . $wx[0] . ' ' . e($wx[1]) . ' · ' . e($w['word']) . ', ' . $w['mph'] . ' mph, blowing towards the ' . e($w['dirName']) . ')</span></p>'
        . trail_fam_grassland_svg($w, $we);
    $kites = ''; $nk = 0;
    foreach ($marks as $m) {
        if (!in_array($m['slug'], TRAIL_FAM_GRASSLAND_KITE, true)) continue;
        $nk++;
        $boost = $we === 'wind';
        $kites .= '<li class="tfg-k ' . ($boost ? 'good' : 'calm') . '"><span aria-hidden="true">' . ($boost ? '🪁' : '🍃') . '</span> ' . e(trail_sight_label($m['slug'])[0]) . ' <b>' . ($boost ? 'pays more today' : 'pays its usual') . '</b></li>';
    }
    if ($nk) {
        $tl = (int)(($now['tl'] ?? [])['kite-string'] ?? 0);
        $h .= '<p class="tfg-note">Kite Sights pay more on wind days (a coin, extra gifts, a keener mind). Kite string wound: ' . $tl . ' (a weather hint at 5).</p><ul class="tfg-kites">' . $kites . '</ul>';
    }
    $h .= trail_fam_grassland_letters($ctx, $we);
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight' || !str_starts_with($l['who'], 'Mabel Pennywhistle')) continue;
            $chips[] = ['now' => $l['now'], 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => (int)$b['now'] <=> (int)$a['now']);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfg-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">💌</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}

/** "Mabel's Sky Letters" progress: one chip per letter (the weather it needs, found or not) and whether today's weather suits one. '' when the line is not in the data. */
function trail_fam_grassland_letters(array $ctx, string $we): string
{
    try {
        $q = trail_sight_quests()[TRAIL_FAM_GRASSLAND_QUEST] ?? null;
        if (!$q) return '';
        $uid = (int)(($ctx['u'] ?? [])['id'] ?? 0);
        $row = $uid ? q_one('SELECT * FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$uid, TRAIL_FAM_GRASSLAND_QUEST]) : null;
        $done = trail_sight_quest_done($q, $row ?: null);
        $items = ''; $open = 0; $today = '';
        foreach ($q['beats'] as $i => $b) {
            $need = preg_match('/we=([a-z]+)/', (string)$b[2], $mm) ? $mm[1] : '';
            $wx = TRAIL_FAM_GRASSLAND_WX[$need] ?? ['✉️', $need];
            $got = in_array($i, $done, true);
            if (!$got) { $open++; if ($need === $we) $today = trail_sight_label($b[0])[0]; }
            $items .= '<li class="tfg-l ' . ($got ? 'got' : 'todo') . '"><span aria-hidden="true">' . $wx[0] . '</span> ' . e(ucfirst($wx[1])) . ' letter <b>' . ($got ? 'found' : 'waiting') . '</b></li>';
        }
        $started = $row && !$row['done_at'];
        if ($row && $row['done_at']) return '<p class="tfg-note">Mabel\'s Sky Letters: all five letters found.</p>';
        $line = $today !== '' ? 'Today\'s weather has a letter waiting at ' . e($today) . '.' : ($started ? 'None of today\'s weather is a letter you still need.' : 'Each letter needs a different weather. Mabel Pennywhistle gives the quest.');
        return '<p class="tfg-note"><b>Mabel\'s Sky Letters:</b> ' . $line . '</p><ul class="tfg-letters">' . $items . '</ul>';
    } catch (Throwable $e) { return ''; }
}
