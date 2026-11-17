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

/**
 * 2.7.06 (Josh): a family panel (the wind row, the lantern row, the aurora ...) starts collapsed like the moon pill: a <details> whose summary is the panel's own first line, the rest behind a tap.
 * A panel that already collapses (a moon pill or its own <details>) and one that is not a single <section> are left as they are.
 */
function trail_fam_collapse(string $html): string
{
    $html = trim($html);
    if ($html === '' || !str_starts_with($html, '<section') || !str_ends_with($html, '</section>')) return $html;
    if (str_contains($html, 'class="moonpill"') || str_contains($html, '<details')) return $html;
    require_once __DIR__ . '/moon.php';
    $i = strpos($html, '>'); if ($i === false) return $html;
    $inner = substr($html, $i + 1, -strlen('</section>'));
    $head = ''; if (preg_match('/<(p|div|h[1-6])\b[^>]*>(.*?)<\/\1>/s', $inner, $m)) $head = trim(html_entity_decode(strip_tags($m[2]), ENT_QUOTES));
    if ($head === '') $head = trim(html_entity_decode(strip_tags($inner), ENT_QUOTES));
    $head = preg_replace('/\s+/u', ' ', $head);
    if (mb_strlen($head) > 90) $head = mb_substr($head, 0, 88) . '…';
    $icon = '🧭'; if (preg_match('/^(\X)\s/u', $head, $g) && preg_match('/[\x{2190}-\x{1FAFF}]/u', $g[1])) { $icon = $g[1]; $head = trim(mb_substr($head, mb_strlen($g[1]))); }
    if ($head === '') $head = 'Trail notes';
    return substr($html, 0, $i + 1) . moon_pill($icon, $head, $inner) . '</section>';
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
            $out .= trail_fam_collapse((string)$fn($ctx));   // 2.7.06 (Josh): every family panel starts collapsed with its headline showing, like the moon pill
        } catch (Throwable $e) { error_log('trail_fam_' . $name . ': ' . $e->getMessage()); }
    }
    return $out === '' ? '' : '<div class="trailfam">' . $out . '</div>';
}
