<?php
declare(strict_types=1);
/**
 * Delve family layer (2.7.01): "Torch bar" (proposal-route-sights.md, delve end pieces). Above a section that has a delve Sight (a mark whose slug starts `end-delve-`) a dark strip
 * shows (1) how far your torch reaches (a ring and five pips, in words too): full by day, 4 at dusk and dawn, and at night only as much as the MOON gives (new moon 1 .. full moon 4), plus 1 for
 * every mouth of the section that is lit, (2) a torch per delve mouth of the section: lit (used this cooldown) or unlit (ready), the Lamplighter's Round live (a lantern-line mouth lit counts), and
 * (3) the Torchbearer tally (data: every `end-delve-*` row tallies `delve-torches`, coins from the 3rd, a title at 12, a sense buff at a dark moon night) and up to 2 villager chips
 * from npc_cw_sight_lines. Pure function of the clock (ctx['clock'] = [dow, hour, day index], moon.php). Style: assets/style.css "Delve family" block. No JS. Text says it; colour alone never does.
 */

/** Torch reach 1..5 for a daypart, a moon light (0..1) and the number of mouths lit here. */
function trail_fam_delve_reach(string $dp, float $moonLight, int $lit): int
{
    $base = $dp === 'night' ? 1 + (int)round($moonLight * 3) : (($dp === 'dusk' || $dp === 'dawn') ? 4 : 5);
    return max(1, min(5, $base + $lit));
}

function trail_fam_delve(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'end-delve-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    require_once __DIR__ . '/moon.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, , $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $mo = moon_phase((int)$di);
    $dp = (string)($ctx['now']['dp'] ?? 'day');
    $li = ''; $lit = 0; $lamps = 0; $lampsLit = 0;
    foreach ($marks as $m) {
        $used = (int)($m['left'] ?? 0) < (int)($m['row']['uses'] ?? 1);
        $lamp = str_starts_with($m['slug'], 'end-delve-2-');
        if ($used) $lit++;
        if ($lamp) { $lamps++; if ($used) $lampsLit++; }
        $li .= '<li class="tfd-t ' . ($used ? 'lit' : 'unlit') . '"><span class="tfd-ico" aria-hidden="true">' . ($used ? '🔥' : '🕯️') . '</span><span class="tfd-nm">' . e(trail_sight_label($m['slug'])[0]) . '</span>'
            . '<span class="tfd-st">' . ($used ? 'lit' : 'unlit') . ($lamp ? ' · lantern line' : ' · echo mouth') . '</span></li>';
    }
    $r = trail_fam_delve_reach($dp, (float)$mo['light'], $lit);
    $pips = '<span class="tfd-pips" aria-hidden="true">' . str_repeat('<i class="on"></i>', $r) . str_repeat('<i></i>', 5 - $r) . '</span>';
    $why = $dp === 'night' ? 'night, ' . e($mo['name']) . ' gives ' . (1 + (int)round($mo['light'] * 3)) . ' of 4' : e($dp) . ' light';
    $h = '<section class="tfdelve" aria-label="Torch bar">'
        . '<p class="tfd-h"><span aria-hidden="true">' . e($mo['icon']) . '</span> <b>' . $lit . ' of ' . count($marks) . ' delve mouths lit</b> · ' . e($mo['name']) . '</p>'
        . '<p class="tfd-reach"><span class="tfd-ring tfd-r' . (int)$r . '" aria-hidden="true"></span><span>Torch reach ' . $r . ' of 5 steps ' . $pips . '<br><small>(' . $why . ($lit ? ', +' . $lit . ' for lit mouths' : '') . ')</small></span></p>'
        . '<ul class="tfd-torches">' . $li . '</ul>';
    if ($lamps) $h .= '<p class="tfd-tally">Lamplighter\'s Round here: ' . $lampsLit . ' of ' . $lamps . ' lantern mouths lit this round.</p>';
    $tl = (int)((($ctx['now'] ?? [])['tl'] ?? [])['delve-torches'] ?? 0);
    $h .= '<p class="tfd-tally">Torches lit so far: ' . $tl . ' (coins from the 3rd, a title at 12; a new or crescent moon night lends a sense buff)</p>';
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $chips[] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfd-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">🧑‍🔧</span> ' . e($c['text']) . '</p>';
    return moon_pill_section($h . '</section>', (string)$mo['icon'], 'Torch bar · ' . $mo['name']);
}
