<?php
declare(strict_types=1);
/**
 * Rainforest family layer (2.7.01): "Canopy layers" + "Mist Pool Tally". Above a section that has a rainforest Sight (a mark whose slug starts `rainforest-`) a strip lists the
 * Sights in two layers, FLOOR and CANOPY, as two <details> in one exclusive group (pure HTML/CSS toggle, no JS; the floor is open). Under it: the mist pools (the Sights that
 * `tally=mist-pools`: mist pool, rain-drum leaf, canopy gap) with how many you have filled and the next milestone (a title at 12), the moon (night + full moon pays more, and the orchid
 * opens), and a chip per villager due at one of the section's Sights (npc_cw_sight_lines). ctx['clock'] = [dow, hour, game day index]. Style: assets/style.css "Rainforest family" block.
 * Words say everything (layer, ready or resting, lit or not); colour never carries meaning alone.
 */

/** Sights up in the canopy (the rest are on the floor). */
const TRAIL_FAM_RAINFOREST_CANOPY = ['rainforest-the-canopy-gap', 'rainforest-the-parrot-perch', 'rainforest-the-vine-bridge', 'rainforest-the-orchid-tree', 'rainforest-the-lantern-fruit'];
/** The pools of the Mist Pool Tally (rows carry `tally=mist-pools`). */
const TRAIL_FAM_RAINFOREST_POOLS = ['rainforest-the-mist-pool', 'rainforest-the-rain-drum-leaf', 'rainforest-the-canopy-gap'];
const TRAIL_FAM_RAINFOREST_TITLE_AT = 12;

function trail_fam_rainforest_li(array $m): string
{
    $ready = ((int)($m['left'] ?? 1)) > 0;
    $pool = in_array($m['slug'], TRAIL_FAM_RAINFOREST_POOLS, true);
    return '<li class="tfr-s ' . ($ready ? 'ready' : 'rest') . '"><span aria-hidden="true">' . ($pool ? '💧' : ($ready ? '🌿' : '💤')) . '</span> ' . e(trail_sight_label($m['slug'])[0])
        . ($pool ? ' <i>(pool)</i>' : '') . ' <b>' . ($ready ? 'ready' : 'resting') . '</b></li>';
}

function trail_fam_rainforest(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'rainforest-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    require_once __DIR__ . '/moon.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, $hour, $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $hour = (float)$hour; $di = (int)$di;
    $now = (array)($ctx['now'] ?? []);
    $moon = moon_phase($di);
    $night = ($now['dp'] ?? '') === 'night';
    $floor = ''; $canopy = ''; $nf = 0; $nc = 0; $np = 0; $pr = 0;
    foreach ($marks as $m) {
        if (in_array($m['slug'], TRAIL_FAM_RAINFOREST_CANOPY, true)) { $canopy .= trail_fam_rainforest_li($m); $nc++; } else { $floor .= trail_fam_rainforest_li($m); $nf++; }
        if (in_array($m['slug'], TRAIL_FAM_RAINFOREST_POOLS, true)) { $np++; if (((int)($m['left'] ?? 1)) > 0) $pr++; }
    }
    $tally = (int)(($now['tl'] ?? [])['mist-pools'] ?? 0);
    $h = '<section class="tfrain' . ($night ? ' tfr-night' : '') . '" aria-label="Canopy layers and mist pools">'
        . '<div class="tfr-h"><span aria-hidden="true">🌴</span> <b>Canopy layers</b> ' . moon_pill((string)$moon['icon'], (string)$moon['name'], 'Night and a full moon: the orchid opens wider.' . ($night ? ($moon['key'] === 'full' ? ' A full moon tonight: more to find.' : ' It is night.') : '')) . '</div>'
        . '<details class="tfr-layer" name="tfr-layer" open><summary>Forest floor (' . $nf . ')</summary>' . ($nf ? '<ul class="tfr-list">' . $floor . '</ul>' : '<p class="tfr-note">Nothing on the floor here.</p>') . '</details>'
        . '<details class="tfr-layer" name="tfr-layer"><summary>Canopy (' . $nc . ')</summary>' . ($nc ? '<ul class="tfr-list">' . $canopy . '</ul>' : '<p class="tfr-note">Nothing in the canopy here.</p>') . '</details>';
    if ($np) {
        $left = max(0, TRAIL_FAM_RAINFOREST_TITLE_AT - $tally);
        $h .= '<p class="tfr-note"><b>Mist Pool Tally:</b> ' . $tally . ' pools filled (' . ($left ? $left . ' more for the title Mist Keeper' : 'Mist Keeper earned') . '). ' . $pr . ' of ' . $np . ' pools here are ready.</p>';
    }
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $chips[] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    $seen = []; $chips = array_values(array_filter($chips, function ($c) use (&$seen) { if (isset($seen[$c['text']])) return false; return $seen[$c['text']] = true; }));
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfr-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">🌺</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}
