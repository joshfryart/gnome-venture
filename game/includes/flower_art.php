<?php
declare(strict_types=1);
/**
 * v0.9.9 part A: flower art. Simple flat SVG files live in assets/img/flowers/ (static, no scripts): twelve flower heads
 * (head only, 64x64, petals use currentColor so one shape takes any tint), three vessels (vase, jar, basket: a <!--back--> and a
 * <!--front--> half so stems sit inside), three foliage sprigs and a seed packet. Every flower maps to a shape and a tint in
 * data/flower_looks.txt. The files are read once, stripped of their wrapper and drawn INLINE (no ids, so any number can share a page).
 */

const FLOWER_SHAPES = ['daisy', 'rose', 'tulip', 'lily', 'sunflower', 'bell', 'star', 'pom', 'orchid', 'poppy', 'spike', 'cluster'];
const FLOWER_SPRIGS = ['sprig-leaf', 'sprig-fern', 'sprig-eucalyptus'];
/** vessel => [name, stems it holds, slot numbers it uses] (slots are the SLOT_POS rows below) */
const VESSELS = [
    'jar' => ['Glass jar', 5, [0, 1, 2, 6, 7]],
    'vase' => ['Vase', 7, [0, 1, 2, 5, 6, 7, 8]],
    'basket' => ['Wicker basket', 9, [0, 1, 2, 3, 4, 5, 6, 7, 8]],
];
/** Where each stem's head sits on the 200 x 260 canvas: [x, y, head scale]. Slot 0 is the focal flower. */
const SLOT_POS = [[100, 36, 1.0], [60, 56, .86], [140, 56, .86], [30, 92, .8], [170, 92, .8], [100, 82, .84], [66, 106, .8], [134, 106, .8], [100, 122, .74]];
const CANVAS_MOUTH_Y = 150;   // where the vessel's mouth sits on the canvas (the vessel files have it at y = 16)

/** The inside of one of the art files (wrapper stripped), cached. '' if the name isn't one of ours. */
function flower_svg_inner(string $name): string
{
    static $cache = [];
    if (isset($cache[$name])) return $cache[$name];
    $ok = in_array($name, FLOWER_SHAPES, true) || in_array($name, FLOWER_SPRIGS, true) || in_array($name, ['packet', 'vase', 'jar', 'basket'], true);
    $s = $ok ? (string)@file_get_contents(APP_ROOT . '/assets/img/flowers/' . $name . '.svg') : '';
    $s = preg_replace('~^\s*<svg[^>]*>|</svg>\s*$~', '', $s) ?? '';
    return $cache[$name] = trim($s);
}

/** Both halves of a vessel file: [back, front]. */
function flower_vessel_parts(string $v): array
{
    $s = flower_svg_inner($v);
    $parts = explode('<!--front-->', str_replace('<!--back-->', '', $s), 2);
    return [$parts[0] ?? '', $parts[1] ?? ''];
}

/** slug => [shape, tint, seasons[]] from data/flower_looks.txt. */
function flower_looks(): array
{
    static $L = null;
    if ($L !== null) return $L;
    $L = [];
    foreach ((array)@file(__DIR__ . '/data/flower_looks.txt', FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $p = array_map('trim', explode('|', $line));
        if (count($p) < 3 || !in_array($p[1], FLOWER_SHAPES, true) || !preg_match('/^#[0-9a-f]{6}$/i', $p[2])) continue;
        $L[$p[0]] = [$p[1], strtolower($p[2]), flower_seasons($p[3] ?? '*')];
    }
    return $L;
}

/** "sp,su" => ['sp','su']; '*' or anything odd = all four. */
function flower_seasons(string $s): array
{
    $out = array_values(array_intersect(array_map('trim', explode(',', $s)), ['sp', 'su', 'au', 'wi']));
    return $out ?: ['sp', 'su', 'au', 'wi'];
}

/** The look of a flower by its plant slug: from the table, else a guess from its name (flowers added in the admin). */
function flower_look(string $slug): array
{
    $L = flower_looks();
    if (isset($L[$slug])) return $L[$slug];
    $guess = ['orchid' => 'orchid', 'poppy' => 'poppy', 'tulip' => 'tulip', 'lily' => 'lily', 'iris' => 'lily', 'sunflower' => 'sunflower', 'daisy' => 'daisy',
        'rose' => 'rose', 'peony' => 'rose', 'camellia' => 'rose', 'bell' => 'bell', 'lavender' => 'spike', 'lupine' => 'spike', 'sage' => 'spike',
        'jasmine' => 'star', 'blossom' => 'star', 'violet' => 'orchid', 'hydrangea' => 'cluster', 'lilac' => 'cluster', 'marigold' => 'pom',
        'dahlia' => 'pom', 'chrysanthemum' => 'pom'];
    $shape = null;
    foreach ($guess as $w => $sh) if (str_contains($slug, $w)) { $shape = $sh; break; }
    $h = crc32($slug);
    $shape ??= FLOWER_SHAPES[$h % count(FLOWER_SHAPES)];
    $tints = ['#f29bbc', '#d93a3a', '#f6c744', '#8a58c9', '#4f86e0', '#f6f1e7', '#ee7a62', '#a99be4', '#f28c28'];
    return [$shape, $tints[intdiv($h, 12) % count($tints)], flower_seasons('*')];
}

/** A hex colour mixed toward another by $t (0-1). */
function flower_mix(string $a, string $b, float $t): string
{
    $x = sscanf($a, '#%02x%02x%02x');
    $y = sscanf($b, '#%02x%02x%02x');
    $o = '#';
    for ($i = 0; $i < 3; $i++) $o .= sprintf('%02x', (int)round($x[$i] + ($y[$i] - $x[$i]) * $t));
    return $o;
}

/** How a tint looks once the flower is dried: faded toward straw. */
function flower_dried_tint(string $hex): string
{
    return flower_mix(flower_mix($hex, '#b8996a', .5), '#6b5030', .12);
}

/** [hue 0-359, saturation 0-1, lightness 0-1] of a hex colour. */
function flower_hsl(string $hex): array
{
    [$r, $g, $b] = array_map(fn($v) => $v / 255, sscanf($hex, '#%02x%02x%02x'));
    $max = max($r, $g, $b);
    $min = min($r, $g, $b);
    $l = ($max + $min) / 2;
    if ($max === $min) return [0, 0.0, $l];
    $d = $max - $min;
    $s = $d / (1 - abs(2 * $l - 1));
    $h = match (true) {
        $max === $r => fmod(($g - $b) / $d, 6),
        $max === $g => ($b - $r) / $d + 2,
        default => ($r - $g) / $d + 4,
    } * 60;
    return [(int)round($h < 0 ? $h + 360 : $h) % 360, $s, $l];
}

/** One flower head as a <g> placed on a canvas: centre at x,y, $scale 1 = 64 units. */
function flower_head_g(string $shape, string $tint, float $x, float $y, float $scale, float $rotate = 0): string
{
    $inner = flower_svg_inner($shape);
    if ($inner === '') return '';
    $tr = 'translate(' . round($x - 32 * $scale, 2) . ' ' . round($y - 32 * $scale, 2) . ') scale(' . round($scale, 3) . ')';
    if ($rotate) $tr = 'translate(' . round($x, 2) . ' ' . round($y, 2) . ') rotate(' . round($rotate, 1) . ') scale(' . round($scale, 3) . ') translate(-32 -32)';
    return '<g transform="' . $tr . '" color="' . e($tint) . '">' . $inner . '</g>';
}

/** The pixel size for sm / md / lg (same sizes as the rest of the picture helpers). */
function flower_px(string $size): int
{
    return ['sm' => 24, 'md' => 40, 'lg' => 64][$size] ?? 40;
}

/** A single flower on its stem as a square inline SVG icon. $dried = faded, brown stem, no leaf. */
function flower_icon_svg(array $look, string $size, string $alt, bool $dried = false): string
{
    [$shape, $tint] = $look;
    $px = flower_px($size);
    $tint = $dried ? flower_dried_tint($tint) : $tint;
    $stem = $dried ? '#a98b5e' : '#3f8f4f';
    $g = '<path d="M48 54 C48 70 46 82 50 95" fill="none" stroke="' . $stem . '" stroke-width="3.4" stroke-linecap="round"/>';
    if (!$dried) $g .= '<path d="M48.6 80 C56 76 62 78 66 72 C62 84 54 86 48.6 80 Z" fill="#4f9d5d"/>';
    $g .= flower_head_g($shape, $tint, 48, 30, .9);
    return '<svg class="flsvg flsvg-' . e($size) . '" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96" width="' . $px . '" height="' . $px . '" role="img" aria-label="' . e($alt) . '">' . $g . '</svg>';
}

/** A seed packet icon with the flower on its label. */
function flower_packet_svg(array $look, string $size, string $alt): string
{
    $px = flower_px($size);
    $body = str_replace('<!--HEAD-->', flower_svg_inner($look[0]), flower_svg_inner('packet'));
    return '<svg class="flsvg flsvg-' . e($size) . '" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="' . $px . '" height="' . $px . '" role="img" aria-label="' . e($alt)
        . '"><g color="' . e($look[1]) . '">' . $body . '</g></svg>';
}

/**
 * The composition of an arrangement: vessel + stems, each stem [slot, plant slug, dried 0/1]. $comp = ['v' => 'vase', 's' => [[0, 'dahlia', 0], ...]].
 * Returns the INNER markup of a 200 x 260 canvas (vessel at the bottom). Deterministic: the same composition always draws the same.
 */
function arrangement_inner(array $comp): string
{
    $v = isset(VESSELS[$comp['v'] ?? '']) ? (string)$comp['v'] : 'vase';
    [$back, $front] = flower_vessel_parts($v);
    $my = CANVAS_MOUTH_Y;
    $stems = [];
    foreach ((array)($comp['s'] ?? []) as $s) {
        $slot = (int)($s[0] ?? -1);
        if (!isset(SLOT_POS[$slot])) continue;
        $stems[$slot] = [(string)($s[1] ?? ''), !empty($s[2])];
    }
    ksort($stems);
    $key = [];
    foreach ($stems as $slot => [$slug, $dried]) $key[] = $slot . ':' . $slug . ':' . (int)$dried;
    $seed = crc32(implode('|', $key));   // assets/arrange.js draws the same picture live, from the same seed
    $out = '<g transform="translate(0 ' . ($my - 16) . ')">' . $back . '</g>';
    // foliage behind the flowers: a sprig either side and one in the middle
    $sprigs = FLOWER_SPRIGS;
    $mouthW = ['jar' => 12, 'vase' => 14, 'basket' => 26][$v];
    foreach ([[-1, 36, 1.0], [1, 36, .95], [0, 0, 1.12]] as $k => [$side, $ang, $sc]) {
        $name = $sprigs[($seed >> ($k * 3)) % count($sprigs)];
        $out .= '<g transform="translate(' . (100 + $side * $mouthW * .6) . ' ' . ($my + 4) . ') rotate(' . ($side * $ang) . ') scale(' . $sc . ') translate(-32 -96)">' . flower_svg_inner($name) . '</g>';
    }
    // stems first (all behind), then heads, so a low head never gets a stem drawn across it
    $heads = '';
    foreach ($stems as $slot => [$slug, $dried]) {
        [$cx, $cy, $sc] = SLOT_POS[$slot];
        $bx = 100 + ($cx - 100) * .2;
        [$shape, $tint] = flower_look($slug);
        $stemCol = $dried ? '#a98b5e' : '#3f8f4f';
        $out .= '<path d="M' . round($bx, 1) . ' ' . ($my + 6) . ' Q' . round($bx + ($cx - $bx) * .15, 1) . ' ' . round(($my + $cy) / 2, 1) . ' ' . $cx . ' ' . ($cy + 6) . '" fill="none" stroke="' . $stemCol . '" stroke-width="3" stroke-linecap="round"/>';
        if (!$dried && $slot % 2 === 1) {
            $lx = $bx + ($cx - $bx) * .5;
            $ly = ($my + $cy) / 2 + 8;
            $dir = $cx < 100 ? -1 : 1;
            $out .= '<path d="M' . round($lx, 1) . ' ' . round($ly, 1) . ' q' . (7 * $dir) . ' -9 ' . (15 * $dir) . ' -6 q' . (-4 * $dir) . ' 9 ' . (-15 * $dir) . ' 6 Z" fill="#4f9d5d"/>';
        }
        $heads .= flower_head_g($shape, $dried ? flower_dried_tint($tint) : $tint, $cx, $cy, $sc * .98, (($seed >> $slot) & 1 ? 6 : -6) * ($slot ? 1 : 0.5));
    }
    $out .= $heads;
    $out .= '<g transform="translate(0 ' . ($my - 16) . ')">' . $front . '</g>';
    return $out;
}

/** The whole arrangement as an inline SVG. $size sm/md/lg for icons, or 'full' (fills its box, up to 340px). */
function arrangement_svg(array $comp, string $size = 'md', string $alt = 'An arrangement'): string
{
    $dim = $size === 'full' ? '' : ' width="' . flower_px($size) . '" height="' . flower_px($size) . '"';   // 'full' is sized by .flsvg-full in style.css (no inline styles: the CSP forbids them)
    return '<svg class="flsvg flsvg-' . e($size) . '" xmlns="http://www.w3.org/2000/svg" viewBox="-30 -4 260 262"' . $dim . ' role="img" aria-label="' . e($alt) . '">' . arrangement_inner($comp) . '</svg>';
}

/** plant produce item id => [slug, name, region_code], once per request. */
function flower_plant_map(): array
{
    static $m = null;
    if ($m === null) {
        $m = [];
        foreach (q("SELECT slug, name, region_code, produce_item_id AS pid FROM plants WHERE kind = 'flower' AND produce_item_id IS NOT NULL")->fetchAll() as $r) {
            $m[(int)$r['pid']] = [(string)$r['slug'], (string)$r['name'], (string)($r['region_code'] ?? '')];
        }
    }
    return $m;
}

/** The plant slug a flower item stands for (cut or dried), '' if it is no known flower. */
function flower_item_slug(array $i): string
{
    $fx = json_decode((string)($i['effects'] ?? ''), true) ?: [];
    if (!empty($fx['dried']) && !empty($fx['of'])) return (string)$fx['of'];
    $m = flower_plant_map();
    if (isset($m[(int)($i['id'] ?? 0)])) return $m[(int)$i['id']][0];
    $slug = (string)($i['slug'] ?? '');
    return str_starts_with($slug, 'cut-') ? substr($slug, 4) : '';
}

/**
 * The SVG picture for an item, or '' to let the emoji show: cut and dried flowers, seed packets and arrangements.
 * Called by item_icon() after a real uploaded picture and before the emoji.
 */
function flower_icon(array $i, string $size = 'md', string $alt = ''): string
{
    $cat = (string)($i['category'] ?? '');
    if (!in_array($cat, ['flower', 'arrangement', 'packet'], true)) return '';
    $alt = $alt !== '' ? $alt : (string)($i['name'] ?? '');
    $fx = json_decode((string)($i['effects'] ?? ''), true) ?: [];
    if ($cat === 'arrangement') return !empty($fx['arrangement']) ? arrangement_svg($fx['arrangement'], $size, $alt) : '';
    if ($cat === 'packet') return !empty($fx['of']) ? flower_packet_svg(flower_look((string)$fx['of']), $size, $alt) : '';
    $slug = flower_item_slug($i);
    return $slug === '' ? '' : flower_icon_svg(flower_look($slug), $size, $alt, !empty($fx['dried']));
}

// ---------- facts about arrangements (used by the Satchel and the Arranging page) ----------

function arrange_word(int $score): string
{
    return $score >= 85 ? 'Masterpiece' : ($score >= 70 ? 'Splendid' : ($score >= 55 ? 'Lovely' : ($score >= 40 ? 'Pretty' : 'Humble')));
}

/** An arrangement item's composition + score (from its effects), or null. */
function arrangement_of(array $item): ?array
{
    $fx = json_decode((string)($item['effects'] ?? ''), true) ?: [];
    return !empty($fx['arrangement']['s']) ? $fx['arrangement'] : null;
}

/** Extra plain facts for flowers, dried flowers, packets and arrangements (already escaped HTML). */
function flower_item_facts(array $i): array
{
    $fx = json_decode((string)($i['effects'] ?? ''), true) ?: [];
    $f = [];
    if (($i['category'] ?? '') === 'arrangement' && ($a = arrangement_of($i))) {
        $f[] = e('💐 ' . arrange_word((int)$a['score']) . ', ' . (int)$a['score'] . '/100 · ' . count($a['s']) . ' stems in a ' . strtolower(VESSELS[$a['v']][0] ?? 'vase') . '.');
        $f[] = e('🎁 A loved present: it pleases folk more than a single flower. You can also put it in the weekly Arrangements show.');
    } elseif (($i['category'] ?? '') === 'flower') {
        if (!empty($fx['dried'])) $f[] = e('🌾 Dried: it never wilts. Use it in an arrangement as an everlasting flower.');
        else $f[] = e('💐 Use cut flowers in Satchel → Arranging, or hang them to dry for a day.');
    } elseif (($i['category'] ?? '') === 'packet') {
        $f[] = e('📦 Open it in your Satchel for ' . (int)($fx['seeds'] ?? 3) . ' seeds. Give it away or sell it.');
    }
    return $f;
}
