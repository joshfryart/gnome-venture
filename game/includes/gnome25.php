<?php
declare(strict_types=1);
/**
 * The player's gnome as a 2.5D sprite (art: aseprite-source/v3/gnome-dir, a 10-layer rig, 8 frames of 64 x 80 per strip: 1-2 idle, 3-8 walk; views front, back, side).
 * The hat, beard and scarf take the gnome's own colours (hat colour/dye, beard colour/dye, the Cat Fish yarn scarf); tunic, boots, skin and trim keep the colours the gnome was drawn with.
 * Colouring = the rig's palette mapping (not multiply): each tinted layer is drawn in four marker greys (hi/base/shade/deep) that are swapped for a ramp built from the base colour
 * (same recipe as aseprite-source/v3/gnome-dir/recolor.py). gnome_sprite.php composes a strip with GD once per colour set and caches it; the page only holds a URL.
 */
const GNOME25_MARK = ['#f0f0f0' => 0, '#b4b4b4' => 1, '#787878' => 2, '#3c3c3c' => 3];   // hi, base, shade, deep marker greys
const GNOME25_ORDER = [['shadow', null], ['outline', null], ['boots', 'boots'], ['tunic', 'tunic'], ['scarf', 'scarf'], ['skin', 'skin'], ['beard', 'beard'], ['face', null], ['hat', 'hat'], ['trim', 'trim']];
/** 2.7.00 wearables on the rig: code => layer name; the art is `<view>-<layer>.png` (512 x 80, 8 frames like the other layers). A layer with no file is skipped, so nothing changes until it is drawn.
 *  b = Flood Boots (tall boots, drawn over the boots), g = Work Gloves (the hands), c = Travel Cloak, h = Wayfarer's Hat (a brim and band over the hat), p = Trail Pack, s = (the Scarf is the existing scarf layer). */
/** 2.7.01: bump when a layer strip or the stack changes: it is part of the cache file name (gnome_sprite.php), so old composed strips under data/gnome25/ are not served again. */
const GNOME25_ART_REV = '2714a';   // 2701b: back and side Flood Boots over the tunic; 2714a: the worn items (equipped, 2.7.14) and the Tailor items' layers
/** 2.7.14 the 280 Tailor wearables: art at assets/img/gnome25/wear/<item slug>/<view>.png (512 x 80, 8 frames like the rig). No file = nothing drawn.
 *  Where each category goes, per view (after that base layer; '' = first): like wboots, cape and pack. Drawn in this category order. */
const GNOME25_WEAR_CAT_AFTER = ['front' => ['footwear' => 'tunic', 'coat' => 'tunic', 'backpack' => '', 'cloak' => ''],
    'back' => ['footwear' => 'tunic', 'coat' => 'tunic', 'backpack' => 'tunic', 'cloak' => 'tunic'],
    'side' => ['footwear' => 'tunic', 'coat' => 'tunic', 'backpack' => 'tunic', 'cloak' => 'tunic']];
const GNOME25_WEAR = ['b' => 'wboots', 'g' => 'gloves', 'c' => 'cape', 'h' => 'brim', 'p' => 'pack'];
/** where each wearable layer goes in the stack, per view: it is drawn right AFTER the named base layer ('' = first). The cloak and the pack sit behind the body in front view, over the tunic in back and side view.
 *  2.7.01: Flood Boots draw over the tunic in every view (wellies over the legs, rim at row 60, art-2701-opus/wear/MANIFEST.md); back and side got their rim strips after the front.
 *  Wear codes are sorted, so in back and side the boots go down before the cloak and pack (both also after the tunic), which hang over them. */
const GNOME25_WEAR_AFTER = ['front' => ['cape' => '', 'pack' => '', 'wboots' => 'tunic', 'gloves' => 'skin', 'brim' => 'hat'],
    'back' => ['cape' => 'tunic', 'pack' => 'tunic', 'wboots' => 'tunic', 'gloves' => 'skin', 'brim' => 'hat'],
    'side' => ['cape' => 'tunic', 'pack' => 'tunic', 'wboots' => 'tunic', 'gloves' => 'skin', 'brim' => 'hat']];
const GNOME25_DEFAULT = [   // the colours the gnome was drawn with: hi, base, shade, deep
    'hat' => ['#ff8a5c', '#e8493b', '#b52e3f', '#6e2038'], 'tunic' => ['#b6f0e0', '#5fc4c8', '#3a86b0', '#2a4a7a'], 'scarf' => ['#ffe38a', '#f5b82e', '#d98322', '#51302b'],
    'beard' => ['#fff4d6', '#e2e0e6', '#aaa9b8', '#74758c'], 'boots' => ['#e8b982', '#b97a4a', '#864c33', '#51302b'], 'skin' => ['#ffe0bd', '#f0b98d', '#c98462', '#51302b'],
    'trim' => ['#ffe38a', '#f5b82e', '#d98322', '#51302b'],
];

function gnome25_hex(string $h): array { $h = ltrim($h, '#'); return [hexdec(substr($h, 0, 2)), hexdec(substr($h, 2, 2)), hexdec(substr($h, 4, 2))]; }

function gnome25_hsl(array $c): array
{
    [$r, $g, $b] = [$c[0] / 255, $c[1] / 255, $c[2] / 255];
    $mx = max($r, $g, $b); $mn = min($r, $g, $b); $l = ($mx + $mn) / 2;
    if ($mx === $mn) return [0.0, 0.0, $l];
    $d = $mx - $mn; $s = $l > 0.5 ? $d / (2 - $mx - $mn) : $d / ($mx + $mn);
    if ($mx === $r) $h = ($g - $b) / $d + ($g < $b ? 6 : 0); elseif ($mx === $g) $h = ($b - $r) / $d + 2; else $h = ($r - $g) / $d + 4;
    return [$h * 60, $s, $l];
}

function gnome25_h2c(float $p, float $q, float $t): float
{
    if ($t < 0) $t += 1; if ($t > 1) $t -= 1;
    if ($t < 1 / 6) return $p + ($q - $p) * 6 * $t;
    if ($t < 1 / 2) return $q;
    if ($t < 2 / 3) return $p + ($q - $p) * (2 / 3 - $t) * 6;
    return $p;
}

function gnome25_rgb(float $h, float $s, float $l): array
{
    if ($s == 0) { $r = $g = $b = $l; }
    else {
        $q = $l < 0.5 ? $l * (1 + $s) : $l + $s - $l * $s; $p = 2 * $l - $q; $hh = $h / 360;
        [$r, $g, $b] = [gnome25_h2c($p, $q, $hh + 1 / 3), gnome25_h2c($p, $q, $hh), gnome25_h2c($p, $q, $hh - 1 / 3)];
    }
    return [(int)floor($r * 255 + 0.5), (int)floor($g * 255 + 0.5), (int)floor($b * 255 + 0.5)];
}

function gnome25_toward(float $h, float $t, float $amt): float
{
    $d = fmod(($t - $h + 540), 360) - 180;
    $step = min(abs($d), $amt) * ($d >= 0 ? 1 : -1);
    return fmod($h + $step + 360, 360);
}

/** Ramp [hi, base, shade, deep] (each [r,g,b]) from a base colour: the art guide's recipe (hi toward yellow and lighter, shade and deep toward violet and darker). */
function gnome25_ramp(string $base): array
{
    [$h, $s, $l] = gnome25_hsl(gnome25_hex($base));
    $cl = fn(float $x) => min(0.97, max(0.03, $x));
    return [
        gnome25_rgb(gnome25_toward($h, 45, 10), $s, $cl($l + (1 - $l) * 0.30)),
        gnome25_rgb($h, $s, $l),
        gnome25_rgb(gnome25_toward($h, 270, 8), $s * 0.80, $cl($l * 0.80)),
        gnome25_rgb(gnome25_toward($h, 270, 20), $s * 0.60, $cl($l * 0.55)),
    ];
}

/** The strip (PNG bytes) for a view and colours ['hat' => '#rrggbb', 'beard' => ..., 'scarf' => ...] (missing = as drawn), or '' when the art or GD is missing. */
function gnome25_compose(string $view, array $cols, array $skip = [], string $wear = '', array $items = []): string
{
    if (!function_exists('imagecreatetruecolor') || !in_array($view, ['front', 'back', 'side'], true)) return '';
    $dir = APP_ROOT . '/assets/img/gnome25/';
    $out = null;
    $extra = [];   // [after, layer name, file]: the worn wearables' layers (2.7.00), then the Tailor items' (2.7.14: $items = [item base slug => category])
    foreach (array_values(array_filter(array_map(fn($ch) => GNOME25_WEAR[$ch] ?? '', str_split($wear)))) as $wl) $extra[] = [GNOME25_WEAR_AFTER[$view][$wl] ?? null, $wl, $dir . $view . '-' . $wl . '.png'];
    foreach (array_keys(GNOME25_WEAR_CAT_AFTER[$view]) as $cat) foreach ($items as $slug => $c) {
        if ($c === $cat && preg_match('/^[a-z0-9-]+$/', (string)$slug)) $extra[] = [GNOME25_WEAR_CAT_AFTER[$view][$cat], 'x:' . $slug, $dir . 'wear/' . $slug . '/' . $view . '.png'];
    }
    $extra = array_values(array_filter($extra, fn($x) => $x[0] !== null && is_file($x[2])));
    $stack = [];   // [name, role, file]: the base layers with the extra layers put in
    foreach ($extra as [$after, $nm, $f]) if ($after === '') $stack[] = [$nm, null, $f];
    foreach (GNOME25_ORDER as [$name, $role]) {
        $stack[] = [$name, $role, $dir . $view . '-' . $name . '.png'];
        foreach ($extra as [$after, $nm, $f]) if ($after === $name) $stack[] = [$nm, null, $f];
    }
    foreach ($stack as [$name, $role, $f]) {
        if (in_array($name, $skip, true)) continue;   // rig parts (tools/gnome_rig_parts.php) leave layers out
        if (!is_file($f)) return '';
        $im = @imagecreatefrompng($f);
        if (!$im) return '';
        imagealphablending($im, false); imagesavealpha($im, true);
        $w = imagesx($im); $h = imagesy($im);
        if ($out === null) { $out = imagecreatetruecolor($w, $h); imagealphablending($out, false); imagesavealpha($out, true); imagefill($out, 0, 0, imagecolorallocatealpha($out, 0, 0, 0, 127)); imagealphablending($out, true); }
        if ($role !== null) {
            $ramp = isset($cols[$role]) ? gnome25_ramp($cols[$role]) : array_map('gnome25_hex', GNOME25_DEFAULT[$role]);
            $map = [];
            foreach (GNOME25_MARK as $hex => $i) { $c = gnome25_hex($hex); $map[($c[0] << 16) | ($c[1] << 8) | $c[2]] = $ramp[$i]; }
            for ($y = 0; $y < $h; $y++) for ($x = 0; $x < $w; $x++) {
                $px = imagecolorat($im, $x, $y);
                if ((($px >> 24) & 127) > 100) continue;   // transparent
                $k = $px & 0xFFFFFF;
                if (isset($map[$k])) { $c = $map[$k]; imagesetpixel($im, $x, $y, imagecolorallocatealpha($im, $c[0], $c[1], $c[2], ($px >> 24) & 127)); }
            }
        }
        imagealphablending($out, true);
        imagecopy($out, $im, 0, 0, 0, 0, $w, $h);
       
    }
    imagesavealpha($out, true);
    ob_start(); imagepng($out); $png = (string)ob_get_clean();
    return $png;
}

/** The gnome's own colours for the rig: hat, beard, scarf. */
function gnome25_colours(array $u): array
{
    $c = ['hat' => gnome_hat_color($u)];
    $b = (string)($u['beard_color'] ?? '');
    $c['beard'] = (isset(BEARD_COLORS[$b]) || (function_exists('dye_valid') && dye_valid('beard', $b))) ? $b : '#f4f1ea';
    if (!empty($u['id']) && function_exists('catfish_scarf_color')) { $s = catfish_scarf_color((int)$u['id']); if ($s !== '') $c['scarf'] = $s; }
    return array_filter($c, fn($v) => preg_match('/^#[0-9a-fA-F]{6}$/', (string)$v) === 1);
}

/** URL of the player's strip for a view (gnome_sprite.php composes and caches it). '' when the art is not there. */
function gnome25_url(array $u, string $view = 'front'): string
{
    if (!is_file(APP_ROOT . '/assets/img/gnome25/front-hat.png')) return '';
    $c = gnome25_colours($u);
    $q = ['v' => $view];
    if (($w = gnome25_worn($u)) !== '') $q['w'] = $w;   // 2.7.00: the worn wearables (2.7.14: the equipped items)
    if (($x = gnome25_worn_items($u)) !== []) $q['x'] = implode('.', array_keys($x));   // 2.7.14: the worn Tailor items (their layers are drawn once their art exists)
    foreach (['hat' => 'h', 'beard' => 'b', 'scarf' => 's'] as $role => $k) if (isset($c[$role])) $q[$k] = ltrim($c[$role], '#');
    return url('gnome_sprite.php?' . http_build_query($q));
}

/** v2.5.33: the 2.5D gnome as a standing picture (front, idle frame) in the player's colours, same size ratio as gnome_avatar(). '' when the art is not there. */
function gnome25_avatar(array $u, int $size = 96): string
{
    $url = gnome25_url($u, 'front');
    if ($url === '') return '';
    return '<svg class="gnomeart gnome25" width="' . $size . '" height="' . (int)round($size * 1.25) . '" viewBox="0 0 64 80" role="img" aria-label="Your gnome">'
        . '<image href="' . e($url) . '" x="0" y="0" width="512" height="80" image-rendering="pixelated"/></svg>';
}

/** 2.7.14: what the gnome wears (wearables.php wear_worn: the equipped items), cached for the request. [] when the setting is off or the table is missing. */
function gnome25_equipped(array $u): array
{
    static $c = [];
    $uid = (int)($u['id'] ?? 0);
    if ($uid < 1) return [];
    if (isset($c[$uid])) return $c[$uid];
    try {
        require_once __DIR__ . '/wearables.php';
        $w = wear_live($u) ? wear_worn($uid) : [];
    } catch (Throwable $e) { $w = []; }
    return $c[$uid] = $w;
}

/**
 * 2.7.00: the wearables a gnome WEARS as sorted codes of GNOME25_WEAR ('' = none). 2.7.14: the EQUIPPED items (whatever is switched on in the Puzzle box).
 * The art has one look per wearable whatever its cut or rank; the Scarf is the existing scarf layer (no code).
 */
function gnome25_worn(array $u): string
{
    $map = ['flood-boots' => 'b', 'work-gloves' => 'g', 'travel-cloak' => 'c', 'wayfarers-hat' => 'h', 'trail-pack' => 'p'];
    $codes = [];
    foreach (gnome25_equipped($u) as $slug) { $p = wear_parse($slug); if ($p && isset($map[$p[0]])) $codes[$map[$p[0]]] = 1; }
    $a = array_keys($codes); sort($a);
    return implode('', $a);
}

/** 2.7.14: the worn Tailor items: item base slug => category (footwear, backpack, coat, cloak), sorted by slug. */
function gnome25_worn_items(array $u): array
{
    $o = [];
    foreach (gnome25_equipped($u) as $slug) { $p = wear_parse($slug); $d = $p ? (wear_defs()[$p[0]] ?? null) : null; if ($d && ($d['get'] ?? '') === 'tailor') $o[$p[0]] = (string)$d['cat']; }
    ksort($o);
    return $o;
}
