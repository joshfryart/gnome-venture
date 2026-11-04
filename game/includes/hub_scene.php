<?php
declare(strict_types=1);
/**
 * Graphical navigation, Phase 1b-2: ONE scene engine for every picture page (Here, Residential, Door, Crafting, Treehouse, Pal Yard).
 * A picture page is a backdrop + hotspots + sprites + a popover. Only the content of each popover differs.
 *
 *   hub_scene('here-village-forest', $hotspots, $sprites, ['layout' => $L, 'alt' => 'The village green', 'open' => 'x'])  ->  HTML
 *
 * Rules (plan 2a): inline SVG, positions are SVG attributes (no style=, no inline script, CSP safe); the canvas size comes from the
 * layout ('w', 'h'), never from here. Every hotspot is a real <a href>: with no JS it follows its href (callers use ?o=<id>, and
 * pass 'open' => id to show that card). With assets/hubscene.js a tap opens the card as a <dialog>. Actions never happen from the
 * picture: a card holds the POST form with its CSRF field. Art is optional: no PNG = a drawn sky and ground. Every scene has a text twin.
 *
 * Hotspot: ['id', 'x', 'y', 'label', 'href', 'icon' => img path|'' , 'emoji', 'cls' => 'goal'|'locked'|'ruin'|'', 'r' => 26, 'chip' => text, 'card' => html|'']
 * Sprite:  ['id', 'x' (feet), 'y' (feet), 'w', 'h' (natural px), 'src' => img path|'', 'emoji', 'name', 'href' => ''|link, 'card' => html|'', 'mark' => emoji]
 * Options: layout (array, required), alt, open (hotspot/sprite id), twin (bool, default true), more (['label' =>, 'href' =>] "+N more" chip),
 *          debug (bool, admin only: numbered dots on every slot), art (kind of picture file: default 'here'), title (heading for the twin)
 */
require_once __DIR__ . '/here_layout.php';
require_once __DIR__ . '/scene.php';

/** Safe DOM id fragment. */
function hub_id(string $s): string
{
    return preg_replace('/[^A-Za-z0-9_-]/', '', $s) ?: 'x';
}

/** Button art for a hotspot (assets/img/hs/hs-<key>.png), or '' so the emoji shows. Key: 'hs' if given, else the id without 's-'; exits (id e<n>) use their compass letter 'a' and goal state. */
function hub_hs_icon(array $h): string
{
    $id = (string)($h['id'] ?? '');
    if (isset($h['hs'])) $k = (string)$h['hs'];
    elseif (preg_match('/^e\d+$/', $id)) { if (empty($h['a'])) return ''; $k = 'exit-' . $h['a'] . (($h['cls'] ?? '') === 'goal' ? '-goal' : ''); }
    else $k = preg_replace('/^s-/', '', $id);
    if (!preg_match('/^[A-Za-z-]+$/', $k)) return '';
    $rel = 'assets/img/hs/hs-' . $k . '.png';
    return function_exists('pixel_has') && pixel_has($rel) ? url($rel) : '';
}

/** One hotspot as an SVG link. 44 px tap target at 412 px wide = r >= 26 units on a 480 canvas (r is scaled for other widths). */
function hub_hotspot(array $h, array $L): string
{
    $id = hub_id((string)$h['id']);
    $x = (int)$h['x']; $y = (int)$h['y'];
    $r = (int)($h['r'] ?? max(26, (int)round((int)$L['w'] * 26 / 480)));
    $icon = (string)($h['icon'] ?? '');
    if ($icon === '') $icon = hub_hs_icon($h);
    $art = $icon !== '' && strpos($icon, '/hs/') !== false;
    $cls = 'hs' . ($art ? ' hsart' : '') . (($h['cls'] ?? '') !== '' ? ' ' . preg_replace('/[^a-z0-9 _-]/i', '', (string)$h['cls']) : '');
    $s = (int)round($r * ($art ? 0.92 : 0.62));
    $label = (string)($h['label'] ?? '');
    $chip = (string)($h['chip'] ?? '');
    $a = '<a class="' . $cls . '" id="hs-' . $id . '" href="' . e((string)$h['href']) . '" aria-label="' . e($label . ($chip !== '' ? ', ' . $chip : '')) . '"'
        . (($h['card'] ?? '') !== '' ? ' data-pop="hubpop-' . $id . '" aria-haspopup="dialog"' : '') . '>'
        . '<title>' . e($label) . '</title>'
        . '<circle class="hit" cx="' . $x . '" cy="' . $y . '" r="' . $r . '"/>'
        . '<circle class="ring" cx="' . $x . '" cy="' . $y . '" r="' . ($art ? $r - 1 : $r - 6) . '"/>';
    if ($icon !== '') $a .= '<image class="pix" href="' . e($icon) . '" x="' . ($x - $s) . '" y="' . ($y - $s) . '" width="' . ($s * 2) . '" height="' . ($s * 2) . '" image-rendering="pixelated"/>';
    else $a .= '<text class="emo" x="' . $x . '" y="' . ($y + (int)round($s * 0.45)) . '" text-anchor="middle" font-size="' . (int)round($s * 1.3) . '" aria-hidden="true">' . e((string)($h['emoji'] ?? '📍')) . '</text>';
    return $a . '</a>';
}

/** One sprite (feet at x,y), sized by perspective, with a soft shadow. */
function hub_sprite(array $s, array $L): string
{
    $p = here_persp($L, (int)$s['y']);
    $sc = $p['scale'];
    $w = (int)round(max(8, (int)($s['w'] ?? 48)) * $sc);
    $h = (int)round(max(8, (int)($s['h'] ?? 64)) * $sc);
    $x = (int)$s['x']; $y = (int)$s['y'];
    $id = hub_id((string)$s['id']);
    $href = (string)($s['href'] ?? '');
    $name = (string)($s['name'] ?? '');
    $g = '<ellipse class="shadow" cx="' . $x . '" cy="' . $y . '" rx="' . (int)round($w * 0.4) . '" ry="' . max(2, (int)round($w * 0.1)) . '"/>';
    if ((string)($s['src'] ?? '') !== '') {
        $g .= '<image class="pix" href="' . e((string)$s['src']) . '" x="' . ($x - intdiv($w, 2)) . '" y="' . ($y - $h) . '" width="' . $w . '" height="' . $h . '" image-rendering="pixelated"/>';
    } else {
        $r = max(10, intdiv($w, 2));
        $g .= '<circle class="fb" cx="' . $x . '" cy="' . ($y - $r) . '" r="' . $r . '"/><text class="emo" x="' . $x . '" y="' . ($y - $r + (int)round($r * 0.45)) . '" text-anchor="middle" font-size="' . (int)round($r * 1.3) . '" aria-hidden="true">' . e((string)($s['emoji'] ?? '🙂')) . '</text>';
    }
    if (($s['mark'] ?? '') !== '') $g .= '<text class="mark" x="' . ($x + intdiv($w, 3)) . '" y="' . ($y - $h + 8) . '" font-size="12" aria-hidden="true">' . e((string)$s['mark']) . '</text>';
    $hit = '<rect class="hit" x="' . ($x - max(22, intdiv($w, 2))) . '" y="' . ($y - max(44, $h)) . '" width="' . (2 * max(22, intdiv($w, 2))) . '" height="' . max(44, $h) . '"/>';
    if ($href === '') return '<g class="hsp" data-z="' . $p['z'] . '">' . $g . '</g>';
    return '<a class="hsp" id="sp-' . $id . '" href="' . e($href) . '" aria-label="' . e($name) . '"' . (($s['card'] ?? '') !== '' ? ' data-pop="hubpop-' . $id . '" aria-haspopup="dialog"' : '') . '><title>' . e($name) . '</title>' . $hit . $g . '</a>';
}

/** The picture page, whole: svg, legend, cards (dialogs) and the text twin. */
function hub_scene(string $key, array $hotspots, array $sprites, array $opts): string
{
    $L = $opts['layout'];
    $W = (int)$L['w']; $H = (int)$L['h'];
    $hz = (int)($L['horizon'] ?? 0);
    $key = scene_key(str_replace(':', '-', $key));   // 'slug:foo' templates use the file name here-slug-foo.png
    $art = (string)($opts['art'] ?? 'here');
    $path = $key !== '' ? scene_path($art, $key) : '';
    $svg = '<svg class="hubsvg" viewBox="0 0 ' . $W . ' ' . $H . '" role="group" aria-label="' . e((string)($opts['alt'] ?? 'Picture')) . '" focusable="false">';
    if ($path !== '') {
        $svg .= '<image class="pix back" href="' . e(url($path)) . '" x="0" y="0" width="' . $W . '" height="' . $H . '" image-rendering="pixelated"/>';
    } else {   // no art yet: a drawn sky, ground and horizon (attributes only), so the page still works and the slots still line up
        $svg .= '<rect class="sky" x="0" y="0" width="' . $W . '" height="' . max(1, $hz) . '"/><rect class="ground" x="0" y="' . $hz . '" width="' . $W . '" height="' . max(1, $H - $hz) . '"/>'
            . '<line class="horizon" x1="0" y1="' . $hz . '" x2="' . $W . '" y2="' . $hz . '"/>';
    }
    $svg .= '<rect class="hub-tint" x="0" y="0" width="' . $W . '" height="' . $H . '" fill="#0b1226" opacity="0" aria-hidden="true"/>';
    $items = [];
    foreach ($sprites as $s) $items[] = [(int)$s['y'], hub_sprite($s, $L)];
    usort($items, fn($a, $b) => $a[0] <=> $b[0]);   // far first, near last
    foreach ($items as $it) $svg .= $it[1];
    foreach ($hotspots as $h) $svg .= hub_hotspot($h, $L);
    if (!empty($opts['debug'])) {
        $n = 0;
        foreach (['exits' => '#d33', 'spots' => '#36c', 'stand' => '#2a2', 'houses' => '#c80'] as $k => $col) {
            foreach ($L[$k] ?? [] as $p) {
                $svg .= '<circle cx="' . (int)$p['x'] . '" cy="' . (int)$p['y'] . '" r="5" fill="' . $col . '"/><text x="' . ((int)$p['x'] + 7) . '" y="' . ((int)$p['y'] + 4) . '" font-size="9" fill="' . $col . '">' . ++$n . ($p['a'] ?? $p['k'] ?? '') . '</text>';
            }
        }
    }
    $svg .= '</svg>';

    // legend: the labels live in HTML, because SVG text is unreadable at phone size
    $leg = '';
    foreach ($hotspots as $h) {
        $id = hub_id((string)$h['id']);
        $leg .= '<li><a class="hubchip ' . e((string)($h['cls'] ?? '')) . '" href="' . e((string)$h['href']) . '" data-for="hs-' . $id . '"' . (($h['card'] ?? '') !== '' ? ' data-pop="hubpop-' . $id . '"' : '') . '>'
            . '<span class="hubchip-t">' . e((string)($h['label'] ?? '')) . '</span>' . (($h['chip'] ?? '') !== '' ? ' <small class="hubchip-c">' . e((string)$h['chip']) . '</small>' : '') . '</a></li>';
    }
    if (!empty($opts['more'])) $leg .= '<li><a class="hubchip" href="' . e((string)$opts['more']['href']) . '"><span class="hubchip-t">' . e((string)$opts['more']['label']) . '</span></a></li>';
    $out = '<div class="hubscene" data-hub="' . e($key) . '">' . $svg . ($leg !== '' ? '<ul class="hubleg" aria-label="In this picture">' . $leg . '</ul>' : '');

    // cards: one <dialog> per hotspot/sprite with a card. 'open' shows that one (no-JS: it sits open under the picture)
    $open = (string)($opts['open'] ?? '');
    foreach (array_merge($hotspots, $sprites) as $h) {
        if (($h['card'] ?? '') === '') continue;
        $id = hub_id((string)$h['id']);
        $title = (string)($h['label'] ?? $h['name'] ?? '');
        $out .= '<dialog class="picker hubpop" id="hubpop-' . $id . '" aria-labelledby="hubpop-' . $id . '-t"' . ($open !== '' && hub_id($open) === $id ? ' open' : '') . '><div class="pickbox">'
            . '<div class="pickhead"><h3 id="hubpop-' . $id . '-t">' . e($title) . '</h3><a class="pickx" href="' . e((string)($opts['close_href'] ?? '?')) . '" data-pop-close aria-label="Close">✕</a></div>'
            . '<div class="hubcard">' . $h['card'] . '</div></div></dialog>';
    }

    if (($opts['twin'] ?? true) !== false) {
        $out .= '<details class="hubtwin"' . (!empty($opts['twin_open']) ? ' open' : '') . '><summary>' . e((string)($opts['title'] ?? 'List view')) . ' <small class="muted">(as a list)</small></summary><ul class="hubtwin-l">';
        foreach ($hotspots as $h) {
            $out .= '<li><a href="' . e((string)$h['href']) . '">' . e((string)($h['label'] ?? '')) . '</a>' . (($h['chip'] ?? '') !== '' ? ' <span class="muted">' . e((string)$h['chip']) . '</span>' : '') . '</li>';
        }
        foreach ($sprites as $s) {
            if (($s['href'] ?? '') !== '') $out .= '<li><a href="' . e((string)$s['href']) . '">' . e((string)($s['name'] ?? '')) . '</a> <span class="muted">is here</span></li>';
        }
        $out .= '</ul></details>';
    }
    return $out . '</div>';
}

/** Loads assets/hubscene.js (the layout calls this from page_header's script list for picture pages). */
function hub_script_tag(): string
{
    return '<script src="' . e(url('assets/hubscene.js?v=' . APP_VERSION)) . '" defer></script>';
}
