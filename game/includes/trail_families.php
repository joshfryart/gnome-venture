<?php
declare(strict_types=1);
/**
 * Trail map families (2.7.01, claude/proposal-route-sights.md): each family of route maps (Maplewold, the nine lands, the four end kinds) can draw its own picture
 * layer above the Trail map and give its Sights their own little game. A family is a file includes/trail_fam_<name>.php with a function trail_fam_<name>(array $ctx): string
 * (HTML, '' when the family has nothing to show). $ctx = ['u','exp','sc','marks','land','route_id','region','clock' => [dow, hour, dayIndex],'now' => trail_sight_now,'maplewold' => bool].
 * The page calls trail_fam_html() once above the map; every family file is loaded and asked, so a family decides for itself whether the section is its own.
 * Games are data: Sight rows with tally= / pick: / take= tokens, quest lines with `npc=Name` beats (the villager must be at the Sight: their weekly clockwork).
 */

function trail_fam_ctx(array $u, array $exp, array $sc, array $marks): array
{
    require_once __DIR__ . '/npc_clockwork.php';
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)($exp['from_id'] ?? 0)]) ?: [];
    $loc += ['landscape' => 'grassland', 'name' => '', 'region' => ''];
    $mw = (string)($loc['region'] ?? '') === 'The Maplewold';
    foreach ($marks as $m) if (preg_match('/^\d/', (string)$m['slug'])) $mw = true;
    return ['u' => $u, 'exp' => $exp, 'sc' => $sc, 'marks' => $marks, 'land' => (string)($sc['land'] ?? exp_scene($exp)['land'] ?? 'grassland'), 'route_id' => (int)($exp['route_id'] ?? 0),
        'region' => (string)$loc['region'], 'clock' => npc_cw_clock(), 'now' => trail_sight_now($loc, $sc, $u), 'maplewold' => $mw];
}

/** The family layers for this section ('' when none). */
function trail_fam_html(array $u, array $exp, array $sc, array $marks = []): string
{
    $out = '';
    $ctx = null;
    foreach (glob(__DIR__ . '/trail_fam_*.php') ?: [] as $f) {
        $name = substr(basename($f, '.php'), 10);
        if (!preg_match('/^[a-z0-9_]+$/', $name)) continue;
        try {
            require_once $f;
            $fn = 'trail_fam_' . $name;
            if (!function_exists($fn)) continue;
            $ctx ??= trail_fam_ctx($u, $exp, $sc, $marks);
            $out .= (string)$fn($ctx);
        } catch (Throwable $e) { error_log('trail_fam_' . $name . ': ' . $e->getMessage()); }
    }
    return $out === '' ? '' : '<div class="trailfam">' . $out . '</div>';
}
