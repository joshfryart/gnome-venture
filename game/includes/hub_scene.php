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
 *          chrome (bool: the no-circles look, see hub_hotspot_box), dress (milestone layers [['k','x','y','w','h','src']]), nav (['routes' => [...], 'world' => [...]]: compass + globe cards)
 */
require_once __DIR__ . '/here_layout.php';
require_once __DIR__ . '/scene.php';

/** Safe DOM id fragment. */
function hub_id(string $s): string
{
    return preg_replace('/[^A-Za-z0-9_-]/', '', $s) ?: 'x';
}

/** One hotspot as an SVG link. 44 px tap target at 412 px wide = r >= 26 units on a 480 canvas (r is scaled for other widths). */
function hub_hotspot(array $h, array $L): string
{
    $id = hub_id((string)$h['id']);
    $x = (int)$h['x']; $y = (int)$h['y'];
    $r = (int)($h['r'] ?? max(26, (int)round((int)$L['w'] * 26 / 480)));
    $cls = 'hs' . (($h['cls'] ?? '') !== '' ? ' ' . preg_replace('/[^a-z0-9 _-]/i', '', (string)$h['cls']) : '');
    $icon = (string)($h['icon'] ?? '');
    $s = (int)round($r * 0.62);
    $label = (string)($h['label'] ?? '');
    $chip = (string)($h['chip'] ?? '');
    $a = '<a class="' . $cls . '" id="hs-' . $id . '" href="' . e((string)$h['href']) . '" aria-label="' . e($label . ($chip !== '' ? ', ' . $chip : '')) . '"'
        . (($h['card'] ?? '') !== '' ? ' data-pop="hubpop-' . $id . '" aria-haspopup="dialog"' : '') . '>'
        . '<title>' . e($label) . '</title>'
        . '<circle class="hit" cx="' . $x . '" cy="' . $y . '" r="' . $r . '"/>'
        . '<circle class="ring" cx="' . $x . '" cy="' . $y . '" r="' . ($r - 6) . '"/>';
    if ($icon !== '') $a .= '<image class="pix" href="' . e($icon) . '" x="' . ($x - $s) . '" y="' . ($y - $s) . '" width="' . ($s * 2) . '" height="' . ($s * 2) . '" image-rendering="pixelated"/>';
    else $a .= '<text class="emo" x="' . $x . '" y="' . ($y + (int)round($s * 0.45)) . '" text-anchor="middle" font-size="' . (int)round($s * 1.3) . '" aria-hidden="true">' . e((string)($h['emoji'] ?? '📍')) . '</text>';
    return $a . '</a>';
}

/** The sprite picture. A sprite sheet ('frames' > 1, frames side by side) shows its FIRST frame only (clipped), never the whole strip. */
function hub_sprite_img(array $s, int $x, int $y, int $w, int $h): string
{
    $n = (int)($s['frames'] ?? 1);
    if ($n > 1 && (int)($s['fw'] ?? 0) > 0 && (int)($s['fh'] ?? 0) > 0) {
        return '<svg class="pix" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" viewBox="0 0 ' . (int)$s['fw'] . ' ' . (int)$s['fh'] . '" preserveAspectRatio="xMidYMid meet" overflow="hidden">'
            . '<image href="' . e((string)$s['src']) . '" x="0" y="0" width="' . ((int)$s['fw'] * $n) . '" height="' . (int)$s['fh'] . '" image-rendering="pixelated"/></svg>';
    }
    return '<image class="pix" href="' . e((string)$s['src']) . '" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" image-rendering="pixelated"/>';
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
        $g .= hub_sprite_img($s, $x - intdiv($w, 2), $y - $h, $w, $h);
    } else {
        $r = max(10, intdiv($w, 2));
        $g .= '<circle class="fb" cx="' . $x . '" cy="' . ($y - $r) . '" r="' . $r . '"/><text class="emo" x="' . $x . '" y="' . ($y - $r + (int)round($r * 0.45)) . '" text-anchor="middle" font-size="' . (int)round($r * 1.3) . '" aria-hidden="true">' . e((string)($s['emoji'] ?? '🙂')) . '</text>';
    }
    if (($s['mark'] ?? '') !== '') $g .= '<text class="mark" x="' . ($x + intdiv($w, 3)) . '" y="' . ($y - $h + 8) . '" font-size="12" aria-hidden="true">' . e((string)$s['mark']) . '</text>';
    $hit = '<rect class="hit" x="' . ($x - max(22, intdiv($w, 2))) . '" y="' . ($y - max(44, $h)) . '" width="' . (2 * max(22, intdiv($w, 2))) . '" height="' . max(44, $h) . '"/>';
    if ($href === '') return '<g class="hsp" data-z="' . $p['z'] . '">' . $g . '</g>';
    return '<a class="hsp" id="sp-' . $id . '" href="' . e($href) . '" aria-label="' . e($name) . '"' . (($s['card'] ?? '') !== '' ? ' data-pop="hubpop-' . $id . '" aria-haspopup="dialog"' : '') . '><title>' . e($name) . '</title>' . $hit . $g . '</a>';
}

/**
 * CHROME MODE (opts 'chrome' => true; the treehouse and the yard use it): no circles anywhere, hit areas from the layout.
 * A hotspot is the painted thing itself: an invisible <rect> over its 'box' [x0,y0,x1,y1] (else 56 x 56 around x,y), a centred tag, gold corner
 * brackets when tapped / focused / lit. A missing image draws nothing extra. A locked room gets closed shutters.
 */
function hub_hotspot_box(array $h, array $L): string
{
    $id = hub_id((string)$h['id']);
    [$x0, $y0, $x1, $y1] = here_hit_box($h, $L);
    $W = (int)$L['w'];
    $cx = intdiv($x0 + $x1, 2);
    $cls = 'hs hsb' . (($h['cls'] ?? '') !== '' ? ' ' . preg_replace('/[^a-z0-9 _-]/i', '', (string)$h['cls']) : '');
    $label = (string)($h['label'] ?? '');
    $chip = (string)($h['chip'] ?? '');
    $a = '<a class="' . $cls . '" id="hs-' . $id . '" href="' . e((string)$h['href']) . '" aria-label="' . e($label . ($chip !== '' ? ', ' . $chip : '')) . '"'
        . (($h['card'] ?? '') !== '' ? ' data-pop="hubpop-' . $id . '" aria-haspopup="dialog"' : '') . '>'
        . '<title>' . e($label) . '</title>'
        . '<rect class="hit" x="' . $x0 . '" y="' . $y0 . '" width="' . ($x1 - $x0) . '" height="' . ($y1 - $y0) . '"/>';
    $icon = (string)($h['icon'] ?? '');
    if ($icon !== '') $a .= '<image class="pix" href="' . e($icon) . '" x="' . $x0 . '" y="' . $y0 . '" width="' . ($x1 - $x0) . '" height="' . ($y1 - $y0) . '" preserveAspectRatio="xMidYMid meet" image-rendering="pixelated"/>';
    if (str_contains((string)($h['cls'] ?? ''), 'locked')) {   // closed shutters: two plain panels over the room
        $m = intdiv($x1 - $x0, 2);
        $a .= '<rect class="shutter" x="' . $x0 . '" y="' . $y0 . '" width="' . $m . '" height="' . ($y1 - $y0) . '"/><rect class="shutter" x="' . ($x0 + $m) . '" y="' . $y0 . '" width="' . ($x1 - $x0 - $m) . '" height="' . ($y1 - $y0) . '"/>';
    }
    $k = 8; $i = 1;   // gold corner brackets
    $a .= '<path class="brk" d="M' . ($x0 + $i) . ' ' . ($y0 + $k) . 'V' . ($y0 + $i) . 'H' . ($x0 + $k) . 'M' . ($x1 - $k) . ' ' . ($y0 + $i) . 'H' . ($x1 - $i) . 'V' . ($y0 + $k)
        . 'M' . ($x1 - $i) . ' ' . ($y1 - $k) . 'V' . ($y1 - $i) . 'H' . ($x1 - $k) . 'M' . ($x0 + $k) . ' ' . ($y1 - $i) . 'H' . ($x0 + $i) . 'V' . ($y1 - $k) . '"/>';
    if (!empty($h['pill'])) {   // a named pill (label in the picture): 11-unit text on a dark plate, positions resolved by hub_pill_layout()
        [$pcx, $pcy, $pw] = $h['pill'];
        $a .= '<g class="pill"><rect x="' . ($pcx - intdiv($pw, 2)) . '" y="' . ($pcy - 8) . '" width="' . $pw . '" height="16" rx="8"/><text x="' . $pcx . '" y="' . ($pcy + 4) . '" text-anchor="middle" font-size="11">' . e(hub_pill_text($label)) . '</text></g>';
        return $a . '</a>';
    }
    $half = (int)ceil(mb_strlen($label) * 2.6) + 4;   // keep the tag inside the picture
    $tx = max($half, min($W - $half, $cx));
    $a .= '<text class="tag" x="' . $tx . '" y="' . ($y1 - 4) . '" text-anchor="middle" font-size="9">' . e($label) . '</text>';
    return $a . '</a>';
}

/** Perspective for chrome sprites: 0.55 (feet near the horizon / top) to 0.95 (feet at the bottom). */
function hub_persp_chrome(array $L, int $y): array
{
    $h = (int)($L['h'] ?? 270);
    $hz = (int)($L['horizon'] ?? 0);
    $t = max(0.0, min(1.0, ($y - $hz) / max(1, $h - $hz)));
    return ['scale' => round(0.55 + 0.40 * $t, 3), 'z' => $y];
}

/**
 * A sprite in chrome mode: feet at x,y. Picture = 'src' (a file), else 'crop' => [url, fullW, fullH, sx, sy, sw, sh] (a piece of the pal's own picture),
 * else a plain silhouette when 'sil' is set, else NOTHING. 'away' => text draws an empty dashed perch with that tag; 'new' => a one-off sparkle.
 */
function hub_sprite_chrome(array $s, array $L): string
{
    $p = hub_persp_chrome($L, (int)$s['y']);
    $sc = $p['scale'];
    $w = (int)round(max(8, (int)($s['w'] ?? 48)) * $sc);
    $h = (int)round(max(8, (int)($s['h'] ?? 64)) * $sc);
    $x = (int)$s['x']; $y = (int)$s['y'];
    $id = hub_id((string)$s['id']);
    $href = (string)($s['href'] ?? '');
    $name = (string)($s['name'] ?? '');
    $g = '<ellipse class="shadow" cx="' . $x . '" cy="' . $y . '" rx="' . (int)round($w * 0.4) . '" ry="' . max(2, (int)round($w * 0.1)) . '"/>';
    $away = (string)($s['away'] ?? '');
    if ($away !== '') {
        $g = '<rect class="perch" x="' . ($x - intdiv($w, 2)) . '" y="' . ($y - $h) . '" width="' . $w . '" height="' . $h . '"/>'
            . '<text class="awaytag" x="' . $x . '" y="' . ($y - intdiv($h, 2) + 3) . '" text-anchor="middle" font-size="7">' . e($away) . '</text>';
    } elseif ((string)($s['src'] ?? '') !== '') {
        $g .= hub_sprite_img($s, $x - intdiv($w, 2), $y - $h, $w, $h);
    } elseif (is_array($s['crop'] ?? null)) {
        [$cu, $fw, $fh, $sx, $sy, $sw, $sh] = $s['crop'];
        $g .= '<svg class="crop" x="' . ($x - intdiv($w, 2)) . '" y="' . ($y - $h) . '" width="' . $w . '" height="' . $h . '" viewBox="' . (int)$sx . ' ' . (int)$sy . ' ' . (int)$sw . ' ' . (int)$sh . '" preserveAspectRatio="xMidYMid slice" overflow="hidden">'
            . '<image href="' . e((string)$cu) . '" x="0" y="0" width="' . (int)$fw . '" height="' . (int)$fh . '"/></svg>';
    } elseif (!empty($s['sil'])) {
        $g .= '<rect class="sil" x="' . ($x - intdiv($w, 2)) . '" y="' . ($y - $h) . '" width="' . $w . '" height="' . $h . '"/>';
    }
    if (isset($s['bar'])) {   // a pal at work: a thin progress bar under its feet (never a ring: no circles)
        $bw = max(16, $w); $fillw = (int)round($bw * max(0, min(100, (int)$s['bar'])) / 100);
        $g .= '<g class="pjring"><rect class="back" x="' . ($x - intdiv($bw, 2)) . '" y="' . ($y + 3) . '" width="' . $bw . '" height="3"/><rect class="fill" x="' . ($x - intdiv($bw, 2)) . '" y="' . ($y + 3) . '" width="' . $fillw . '" height="3"/></g>';
    }
    if (!empty($s['collect'])) $g .= '<text class="collect" x="' . $x . '" y="' . ($y - $h - 3) . '" text-anchor="middle" font-size="8">' . e((string)$s['collect']) . '</text>';
    if (!empty($s['new'])) {   // arrival: three little four-point stars, once (reduced-motion safe in CSS)
        foreach ([[-0.35, 0.0], [0.3, 0.25], [0.0, -0.1]] as [$fx, $fy]) {
            $sx = $x + (int)round($w * $fx); $sy = $y - $h + (int)round($h * (0.2 + $fy));
            $g .= '<path class="spark" d="M' . $sx . ' ' . ($sy - 4) . 'L' . ($sx + 1) . ' ' . ($sy - 1) . 'L' . ($sx + 4) . ' ' . $sy . 'L' . ($sx + 1) . ' ' . ($sy + 1) . 'L' . $sx . ' ' . ($sy + 4) . 'L' . ($sx - 1) . ' ' . ($sy + 1) . 'L' . ($sx - 4) . ' ' . $sy . 'L' . ($sx - 1) . ' ' . ($sy - 1) . 'Z"/>';
        }
    }
    if (($s['mark'] ?? '') !== '') $g .= '<text class="mark" x="' . ($x + intdiv($w, 3)) . '" y="' . ($y - $h + 8) . '" font-size="10" aria-hidden="true">' . e((string)$s['mark']) . '</text>';
    $hw = max(22, intdiv($w, 2));
    $hit = '<rect class="hit" x="' . ($x - $hw) . '" y="' . ($y - max(44, $h)) . '" width="' . (2 * $hw) . '" height="' . max(44, $h) . '"/>';
    if ($href === '') return '<g class="hsp" data-z="' . $p['z'] . '">' . $g . '</g>';
    return '<a class="hsp" id="sp-' . $id . '" href="' . e($href) . '" aria-label="' . e($name) . '"' . (($s['card'] ?? '') !== '' ? ' data-pop="hubpop-' . $id . '" aria-haspopup="dialog"' : '') . '><title>' . e($name) . '</title>' . $hit . $g . '</a>';
}

/** The short name on a pill: drop a leading "The ", cap at 22 characters. */
function hub_pill_text(string $label): string
{
    $t = preg_replace('/^The\s+/u', '', trim($label));
    return mb_strlen($t) > 22 ? mb_substr($t, 0, 21) . '…' : $t;
}

/** Pill positions: centred a third down each box, inside the picture, moved down/up until no two pills overlap. Sets $h['pill'] = [cx, cy, width]. */
function hub_pill_layout(array $hotspots, array $L): array
{
    $W = (int)$L['w']; $H = (int)$L['h'];
    $placed = [];
    foreach ($hotspots as $k => $h) {
        [$x0, $y0, $x1, $y1] = here_hit_box($h, $L);
        $w = (int)ceil(mb_strlen(hub_pill_text((string)($h['label'] ?? ''))) * 6.3) + 14;
        $cx = max(intdiv($w, 2) + 3, min($W - intdiv($w, 2) - 3, intdiv($x0 + $x1, 2)));
        $cy = min($H - 12, max(12, $y0 + intdiv($y1 - $y0, 3)));
        $dir = [20, -40, 60, -80, 100, -120, 140, -160];
        for ($try = 0; $try <= count($dir); $try++) {
            $hit = false;
            foreach ($placed as [$px, $py, $pw]) if (abs($px - $cx) < intdiv($pw + $w, 2) + 3 && abs($py - $cy) < 19) { $hit = true; break; }
            if (!$hit || $try === count($dir)) break;
            $cy = max(12, min($H - 12, $cy + $dir[$try]));
        }
        $placed[] = [$cx, $cy, $w];
        $hotspots[$k]['pill'] = [$cx, $cy, $w];
    }
    return $hotspots;
}

/** The compass and the world globe, bottom-right (HTML buttons over the picture; the bottom-right 100 x 40 of the art stays clear). Each opens a card. */
function hub_navbuttons(array $routes, array $world): string
{
    $img = function (string $f, string $alt): string {
        return is_file(APP_ROOT . '/assets/img/ico/' . $f) ? '<img src="' . e(url('assets/img/ico/' . $f)) . '" width="28" height="28" alt="" decoding="async">' : '';
    };
    return '<div class="hubnav">'
        . '<a class="hubnavbtn" id="hs-world" href="' . e((string)$world['href']) . '" data-pop="hubpop-world" aria-haspopup="dialog" aria-label="World map">' . $img('ico-globe.png', 'World') . '</a>'
        . '<a class="hubnavbtn" id="hs-routes" href="' . e((string)$routes['href']) . '" data-pop="hubpop-routes" aria-haspopup="dialog" aria-label="Routes">' . $img('ico-compass.png', 'Routes') . '</a></div>';
}

/** The villagers in a line under the picture ("street"): each stands full size (their 2.5D sprite, first frame) with a name pill; a tap opens the villager popover. */
function hub_street(array $sprites): string
{
    $o = '';
    foreach ($sprites as $s) {
        if (($s['href'] ?? '') === '') continue;
        $id = hub_id((string)$s['id']);
        $w = (int)($s['w'] ?? 64); $h = (int)($s['h'] ?? 96);
        $fw = (int)($s['fw'] ?? $w); $fh = (int)($s['fh'] ?? $h);
        $img = ((string)($s['src'] ?? '') !== '') ? '<svg class="stp" viewBox="0 0 ' . $fw . ' ' . $fh . '" width="' . $w . '" height="' . $h . '" aria-hidden="true" overflow="hidden"><image href="' . e((string)$s['src']) . '" x="0" y="0" width="' . ($fw * max(1, (int)($s['frames'] ?? 1))) . '" height="' . $fh . '" image-rendering="pixelated"/></svg>' : '<span class="stp stemo" aria-hidden="true">' . e((string)($s['emoji'] ?? '🙂')) . '</span>';
        $o .= '<li><a class="hubst" id="sp-' . $id . '" href="' . e((string)$s['href']) . '"' . (($s['card'] ?? '') !== '' ? ' data-pop="hubpop-' . $id . '" aria-haspopup="dialog"' : '') . '>' . $img . '<span class="stn">' . e(hub_pill_text((string)($s['name'] ?? ''))) . ((string)($s['mark'] ?? '') !== '' ? ' ' . e((string)$s['mark']) : '') . '</span></a></li>';
    }
    return $o === '' ? '' : '<ul class="hubstreet" aria-label="People here">' . $o . '</ul>';
}

/** The compass and the globe as a bar of two wide buttons just UNDER the picture (gate view): nothing sits on the art. */
function hub_navbar(array $routes, array $world): string
{
    $img = function (string $f, string $alt): string {
        return is_file(APP_ROOT . '/assets/img/ico/' . $f) ? '<img src="' . e(url('assets/img/ico/' . $f)) . '" width="28" height="28" alt="" decoding="async">' : e($alt);
    };
    return '<div class="hubnavbar"><span class="hubnavhint">Tap a name or a villager</span>'
        . '<a class="hubnavbtn round" id="hs-world" href="' . e((string)$world['href']) . '" data-pop="hubpop-world" aria-haspopup="dialog" aria-label="World map" title="World map">' . $img('ico-globe.png', 'World') . '</a>'
        . '<a class="hubnavbtn round" id="hs-routes" href="' . e((string)$routes['href']) . '" data-pop="hubpop-routes" aria-haspopup="dialog" aria-label="Routes" title="Routes">' . $img('ico-compass.png', 'Routes') . '</a></div>';
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
    $chrome = !empty($opts['chrome']);
    if ($chrome && !empty($opts['pills'])) $hotspots = hub_pill_layout($hotspots, $L);   // named pills on the picture
    $svg = '<svg class="hubsvg' . ($chrome ? ' chrome' : '') . ($chrome && $path === '' ? ' noart' : '') . '" viewBox="0 0 ' . $W . ' ' . $H . '" role="group" aria-label="' . e((string)($opts['alt'] ?? 'Picture')) . '" focusable="false">';
    if ($path !== '') {
        $svg .= '<image class="pix back" href="' . e(url($path)) . '" x="0" y="0" width="' . $W . '" height="' . $H . '" image-rendering="pixelated"/>';
    } else {   // no art yet: a drawn sky, ground and horizon (attributes only), so the page still works and the slots still line up
        $svg .= '<rect class="sky" x="0" y="0" width="' . $W . '" height="' . max(1, $hz) . '"/><rect class="ground" x="0" y="' . $hz . '" width="' . $W . '" height="' . max(1, $H - $hz) . '"/>'
            . '<line class="horizon" x1="0" y1="' . $hz . '" x2="' . $W . '" y2="' . $hz . '"/>';
    }
    $svg .= '<rect class="hub-tint" x="0" y="0" width="' . $W . '" height="' . $H . '" fill="#0b1226" opacity="0" aria-hidden="true"/>';
    $items = [];
    if (empty($opts['street'])) foreach ($sprites as $s) $items[] = [(int)$s['y'], $chrome ? hub_sprite_chrome($s, $L) : hub_sprite($s, $L)];   // 'street': the villagers stand in a line under the picture instead
    usort($items, fn($a, $b) => $a[0] <=> $b[0]);   // far first, near last
    if ($chrome) {   // rooms and sites are the backdrop (boxes), dressing sits on them, creatures stand in front so they stay tappable
        foreach ($hotspots as $h) $svg .= hub_hotspot_box($h, $L);
        foreach ($opts['dress'] ?? [] as $d) {
            $svg .= '<g class="dress" data-dress="' . e(hub_id((string)$d['k'])) . '">' . (($d['src'] ?? '') !== '' ? '<image class="pix" href="' . e((string)$d['src']) . '" x="' . (int)$d['x'] . '" y="' . (int)$d['y'] . '" width="' . (int)$d['w'] . '" height="' . (int)$d['h'] . '" image-rendering="pixelated"/>' : '') . '</g>';
        }
        foreach ($items as $it) $svg .= $it[1];
    } else {
        foreach ($items as $it) $svg .= $it[1];
        foreach ($hotspots as $h) $svg .= hub_hotspot($h, $L);
    }
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
    $out = '<div class="hubscene' . ($chrome ? ' chrome' : '') . '" data-hub="' . e($key) . '">' . ($chrome ? '<div class="hubstage">' . $svg . (!empty($opts['nav']) && empty($opts['navbar']) ? hub_navbuttons($opts['nav']['routes'], $opts['nav']['world']) : '') . '</div>' . (!empty($opts['nav']) && !empty($opts['navbar']) ? hub_navbar($opts['nav']['routes'], $opts['nav']['world']) : '') . (!empty($opts['street']) ? hub_street($sprites) : '') : $svg) . ($leg !== '' ? '<ul class="hubleg" aria-label="In this picture">' . $leg . '</ul>' : '');

    // cards: one <dialog> per hotspot/sprite with a card. 'open' shows that one (no-JS: it sits open under the picture)
    $open = (string)($opts['open'] ?? '');
    $navCards = [];
    foreach (['routes', 'world'] as $nk) if (!empty($opts['nav'][$nk]['card'])) $navCards[] = ['id' => $nk, 'label' => (string)$opts['nav'][$nk]['title'], 'card' => $opts['nav'][$nk]['card']];
    foreach (array_merge($hotspots, $sprites, $navCards) as $h) {
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
