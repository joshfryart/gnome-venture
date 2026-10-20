<?php
// v2.0.20: the Treks mini-map. One small server-rendered SVG of the whole chapter map, drawn from the seen bitset only (display only: no links, no tap-to-travel).
// Walkable seen tiles are one <path> per class (floor / water / mud), run-length encoded per row (one stroked line per run); walls are the backdrop rect.
// Spots are drawn only when their tile is seen, and a hidden spot only with a Wayfinder (the same check as the real map). No names or codes are printed.
require_once __DIR__ . '/trek.php';

/** The tile class of one map character: '' (wall / nothing to draw), f floor, w water, m mud. */
function trek_minimap_class(string $t): string
{
    return match (true) {
        $t === '#' || $t === '^' || $t === ' ' || $t === '*' => '',
        $t === 'w' => 'w',
        $t === '~' || $t === ':' || $t === '%' || $t === ',' => 'm',
        default => 'f',
    };
}

function trek_minimap_html(array $run, array $u): string
{
    $ch = (int)$run['chapter'];
    $m = trek_map($ch);
    $W = (int)$m['w'];
    $H = (int)$m['h'];
    if ($W < 1 || $H < 1 || !isset($run['sn'])) return '';
    $paths = ['f' => '', 'w' => '', 'm' => ''];
    $x0 = $W; $y0 = $H; $x1 = -1; $y1 = -1;
    for ($y = 0; $y < $H; $y++) {
        $row = $m['t'][$y];
        $start = -1; $cls = '';
        for ($x = 0; $x <= $W; $x++) {
            $c = '';
            if ($x < $W && trek_seen_get($run, $x, $y)) {
                if ($x < $x0) $x0 = $x;
                if ($x > $x1) $x1 = $x;
                if ($y < $y0) $y0 = $y;
                if ($y > $y1) $y1 = $y;
                $c = trek_minimap_class($row[$x]);
            }
            if ($c !== $cls) {
                if ($cls !== '') $paths[$cls] .= 'M' . $start . ' ' . $y . 'h' . ($x - $start);
                $start = $x; $cls = $c;
            }
        }
    }
    if ($x1 < 0) return '';
    // the visible area plus one tile of margin
    $vx = max(0, $x0 - 1); $vy = max(0, $y0 - 1);
    $vw = min($W, $x1 + 2) - $vx; $vh = min($H, $y1 + 2) - $vy;
    // spots: seen, and visible to this player
    $obj = trek_objective($run);
    $camps = ''; $pts = ''; $dones = ''; $bang = '';
    foreach (trek_spots($ch) as $s) {
        if (!trek_seen_get($run, $s['x'], $s['y'])) continue;
        if ($s['type'] === 'hidden' && !trek_spot_visible($run, $u, $s)) continue;
        $cx = $s['x'] + .5; $cy = $s['y'] + .5;
        if ($obj && $obj['code'] === $s['code']) { $bang = '<text class="tmob" x="' . $cx . '" y="' . ($s['y'] + 1.4) . '" text-anchor="middle">!</text>'; continue; }
        $done = !in_array($s['type'], ['gate', 'start', 'exit', 'camp', 'npc', 'sign', 'oldcamp'], true) && trek_spot_done($run, $s);
        if ($s['type'] === 'camp' || $s['type'] === 'oldcamp') $camps .= '<rect x="' . ($s['x'] + .1) . '" y="' . ($s['y'] + .1) . '" width=".8" height=".8"/>';
        elseif ($done) $dones .= '<circle cx="' . $cx . '" cy="' . $cy . '" r=".3"/>';
        else $pts .= '<circle cx="' . $cx . '" cy="' . $cy . '" r=".35"/>';
    }
    $px = (int)$run['x']; $py = (int)$run['y'];
    $me = trek_seen_get($run, $px, $py) ? '<circle class="tmme" cx="' . ($px + .5) . '" cy="' . ($py + .5) . '" r=".75"/>' : '';
    $svg = '<svg class="tkminimap" viewBox="' . $vx . ' ' . $vy . ' ' . $vw . ' ' . $vh . '" role="img" aria-label="Whole map so far" preserveAspectRatio="xMidYMid meet" xmlns="http://www.w3.org/2000/svg">'
        . '<rect class="tmbg" x="' . $vx . '" y="' . $vy . '" width="' . $vw . '" height="' . $vh . '"/><g transform="translate(0 .5)">';
    foreach (['f' => 'tmf', 'w' => 'tmw', 'm' => 'tmm'] as $k => $cl) if ($paths[$k] !== '') $svg .= '<path class="' . $cl . '" d="' . $paths[$k] . '"/>';
    $svg .= '</g>';
    if ($camps !== '') $svg .= '<g class="tmcp">' . $camps . '</g>';
    if ($dones !== '') $svg .= '<g class="tmdn">' . $dones . '</g>';
    if ($pts !== '') $svg .= '<g class="tmsp">' . $pts . '</g>';
    return $svg . $bang . $me . '</svg>';
}

/** The fold for the map tab (closed by default). */
function trek_minimap_fold(array $run, array $u): string
{
    $s = trek_minimap_html($run, $u);
    return $s === '' ? '' : '<details class="tkmini"><summary>🗺️ Whole map</summary>' . $s . '<p class="tkminikey">▮ camp · ● place · ! next · ◉ you</p></details>';
}
