<?php
declare(strict_types=1);
/**
 * Mountain family layer (2.7.01): "Echo Chain". Above a section that has a mountain Sight (a mark whose slug starts `mountain-`; Maplewold routes with one too) a strip tints the
 * air by ALTITUDE (more mountain Sights on the section = higher; fog, snow and dawn add mist) and draws ECHO RINGS: rings round the echo wall, and one ring per other Sight,
 * the farther away the later its reply (a reply "delay" in beats = tiles between the Sights). Under it the echo wall's rhythm game (pick:), the Echo Cheeks tally, the moon
 * (a new or full moon sends a second pebble: the echo is clearest on a bright or a dark night) and a chip per villager due at a mountain Sight (npc_cw_sight_lines).
 * Style: assets/style.css "Mountain family" block (classes tfmountain, tfm-). No JS. Words say everything the colours say.
 */

const TRAIL_FAM_MOUNTAIN_WALL = 'mountain-the-echo-wall';

/** Altitude 0..3 and its words from how many mountain Sights the section has and the weather. */
function trail_fam_mountain_altitude(int $n, array $now): array
{
    $lvl = $n >= 6 ? 3 : ($n >= 4 ? 2 : ($n >= 2 ? 1 : 0));
    $mist = in_array((string)($now['we'] ?? ''), ['fog', 'snow', 'storm', 'frost'], true) || ($now['dp'] ?? '') === 'dawn';
    $names = ['Foothills', 'Rising ground', 'High ledges', 'Thin air'];
    $feet = [1200, 3200, 5600, 8400][$lvl];
    return ['lvl' => $lvl, 'name' => $names[$lvl], 'feet' => $feet, 'mist' => $mist, 'text' => $names[$lvl] . ', about ' . number_format($feet) . ' ft' . ($mist ? ', misty' : '')];
}

/** Echo replies: for each other mountain Sight its distance from the wall (tiles) and the delay in beats. Sorted nearest first; the wall itself is not listed. */
function trail_fam_mountain_replies(array $marks): array
{
    $wall = null; foreach ($marks as $m) if ($m['slug'] === TRAIL_FAM_MOUNTAIN_WALL) { $wall = $m; break; }
    if (!$wall) return [];
    $o = [];
    foreach ($marks as $m) {
        if ($m['slug'] === TRAIL_FAM_MOUNTAIN_WALL) continue;
        $d = (int)round(sqrt(((int)$m['x'] - (int)$wall['x']) ** 2 + ((int)$m['y'] - (int)$wall['y']) ** 2));
        $o[] = ['slug' => $m['slug'], 'dist' => $d, 'beats' => max(1, min(9, (int)ceil($d / 3)))];
    }
    usort($o, fn($a, $b) => [$a['dist'], $a['slug']] <=> [$b['dist'], $b['slug']]);
    return $o;
}

/** The echo rings as an inline SVG: rings round the wall, one dot per reply at its distance. */
function trail_fam_mountain_svg(array $replies, bool $hasWall, array $moon): string
{
    $W = 240; $H = 56; $cx = 30; $cy = 28;
    $alt = $hasWall ? 'Echo rings: ' . ($replies ? 'replies come back from ' . count($replies) . ' other Sights, the farthest after ' . max(array_column($replies, 'beats')) . ' beats.' : 'no other Sight answers the echo wall.') : 'No echo wall on this stretch.';
    $s = '<svg class="tfm-svg" viewBox="0 0 ' . $W . ' ' . $H . '" role="img" aria-label="' . e($alt) . '" focusable="false"><title>' . e($alt) . '</title>';
    if ($hasWall) {
        foreach ([8, 16, 24] as $r) $s .= '<circle class="tfm-ring" cx="' . $cx . '" cy="' . $cy . '" r="' . $r . '" fill="none"/>';
        $s .= '<circle class="tfm-wall" cx="' . $cx . '" cy="' . $cy . '" r="4"/>';
        foreach (array_slice($replies, 0, 6) as $i => $r) {
            $x = $cx + 26 + $r['beats'] * 20;
            $s .= '<line class="tfm-ray" x1="' . $cx . '" y1="' . $cy . '" x2="' . $x . '" y2="' . $cy . '"/><circle class="tfm-dot" cx="' . $x . '" cy="' . ($cy + (($i % 2) ? 8 : -8)) . '" r="3"/>';
            $s .= '<text class="tfm-lbl" x="' . $x . '" y="' . ($H - 2) . '" text-anchor="middle">' . $r['beats'] . '</text>';
        }
    }
    return $s . '</svg>';
}

function trail_fam_mountain(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'mountain-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    require_once __DIR__ . '/moon.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, $hour, $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $now = (array)($ctx['now'] ?? []);
    $alt = trail_fam_mountain_altitude(count($marks), $now);
    $moon = moon_phase((int)$di);
    $hasWall = (bool)array_filter($marks, fn($m) => $m['slug'] === TRAIL_FAM_MOUNTAIN_WALL);
    $rep = trail_fam_mountain_replies($marks);
    $h = '<section class="tfmountain tfm-a' . $alt['lvl'] . ($alt['mist'] ? ' tfm-mist' : '') . '" aria-label="Echo chain">'
        . '<p class="tfm-h"><span aria-hidden="true">🏔️</span> <b>' . e($alt['text']) . '</b> <span class="tfm-moon" title="The moon and the echo">' . e($moon['icon']) . ' ' . e($moon['name']) . '</span></p>'
        . trail_fam_mountain_svg($rep, $hasWall, $moon);
    if ($hasWall) {
        $tl = (int)(($now['tl'] ?? [])['echo-cheeks'] ?? 0);
        $h .= '<p class="tfm-note">Echo wall: shout the right rhythm (short and long) and it answers. ';
        $h .= $rep ? 'Replies come back from ' . implode(', ', array_map(fn($r) => e(trail_sight_label($r['slug'])[0]) . ' after ' . $r['beats'] . ' beat' . ($r['beats'] > 1 ? 's' : ''), array_slice($rep, 0, 3))) . '. ' : 'Nothing else answers on this stretch. ';
        $h .= 'Cheeky echoes: ' . $tl . ' (a title at 3).' . (in_array($moon['key'], ['full', 'new'], true) ? ' The ' . strtolower($moon['name']) . ' makes the echo clearest: a second pebble may fall.' : '') . '</p>';
    }
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $chips[] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfm-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">🐐</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}
