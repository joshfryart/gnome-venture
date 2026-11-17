<?php
declare(strict_types=1);
/**
 * Forest family layer (2.7.01): "Glow-moss dusk filter". At dusk and night (ctx['now']['dp']) the strip above a forest section's map is a dim lantern row: one lantern per forest
 * Sight of the section, lit when the gnome used it this cooldown, unlit when it is ready; fireflies (pure CSS dots) sit on the lantern where a villager is here now or due today / tomorrow
 * (npc_cw_sight_lines), with a chip that says who and when. A small tally line counts the Lantern Relay (tally lanterns-lit on the lantern-type Sights, data/trail_sights_shared.txt).
 * By dawn and day it is '' (no picture needed). Section is the family's own only when a mark has a `forest-` Sight. Style: assets/style.css "Forest family" block. No JS.
 */

const TRAIL_FAM_FOREST_RELAY = ['forest-the-lantern-branch', 'forest-the-glow-moss-grotto', 'forest-the-woodcutter-s-stump', 'forest-the-mushroom-ring'];

function trail_fam_forest(array $ctx): string
{
    $dp = (string)($ctx['now']['dp'] ?? '');
    if ($dp !== 'dusk' && $dp !== 'night') return '';
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'forest-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    $lines = []; $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $near = $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow');
            if ($near) $lines[$m['slug']] = true;
            $chips[] = ['near' => $near, 'now' => $l['now'], 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    $lit = 0; $relay = 0; $relayLit = 0; $li = '';
    foreach ($marks as $m) {
        $used = (int)($m['left'] ?? 0) < (int)($m['row']['uses'] ?? 1);
        $isRelay = in_array($m['slug'], TRAIL_FAM_FOREST_RELAY, true);
        if ($used) $lit++;
        if ($isRelay) { $relay++; if ($used) $relayLit++; }
        $name = trail_sight_label($m['slug'])[0];
        $fly = isset($lines[$m['slug']]);
        $li .= '<li class="tff-l ' . ($used ? 'lit' : 'unlit') . ($isRelay ? ' relay' : '') . ($fly ? ' fly' : '') . '">'
            . '<span class="tff-ico" aria-hidden="true">' . ($used ? '🏮' : '🕯️') . '</span>'
            . '<span class="tff-nm">' . e($name) . '</span>'
            . '<span class="tff-st">' . ($used ? 'lit' : 'unlit') . ($isRelay ? ' · relay' : '') . ($fly ? ' · villager due' : '') . '</span>'
            . ($fly ? '<span class="tff-fly" aria-hidden="true"><i></i><i></i><i></i></span>' : '') . '</li>';
    }
    $tl = (int)(($ctx['now']['tl'] ?? [])['lanterns-lit@' . (int)($ctx['now']['gd'] ?? 0)] ?? 0);   // 2.7.06: this game day's count (the bonus pays from 3 a day)
    $h = '<section class="tfforest tff-' . e($dp) . '" aria-label="Glow-moss lantern row, ' . e($dp) . '">'
        . '<p class="tff-h"><span aria-hidden="true">🌲</span> Lantern row at ' . e($dp) . ': ' . $lit . ' of ' . count($marks) . ' lit</p>'
        . '<ul class="tff-row">' . $li . '</ul>';
    if ($relay) $h .= '<p class="tff-relay">Lantern Relay: ' . $relayLit . ' of ' . $relay . ' relay lanterns lit this round · ' . $tl . ' lit today (bonus pays from 3 a day)</p>';
    foreach (array_slice($chips, 0, 3) as $c) $h .= '<p class="tff-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">✨</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}
