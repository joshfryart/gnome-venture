<?php
declare(strict_types=1);
/**
 * v2.0.31: shared helpers for the pixel art (additive: every caller falls back to the old SVG/vector when a PNG is missing).
 * CSP-safe tinting: an SVG feColorMatrix filter per tint hex (ids are tint-<hex>, plus an optional per-drawing suffix).
 * v2.0.36: a drawing that can sit next to a hidden twin (the gnome in the phone nav drawer) passes a unique $uid. Duplicate ids are NOT harmless:
 * url(#id) binds to the first element in the page, and a filter inside a display:none svg does not apply, so the visible copy showed untinted grey art.
 */

/** PNG if it exists under the game folder, else the SVG. $relNoExt like 'assets/img/ph/foo'. */
function art_url(string $relNoExt): string
{
    $png = $relNoExt . '.png';
    return url(is_file(APP_ROOT . '/' . $png) ? $png : $relNoExt . '.svg');
}

/**
 * v2.0.82: popover animation strips. $rel = 'assets/img/acts/act-fire-anim.png' (a horizontal strip of N equal-width frames).
 * Returns ' data-anim="url" data-frames="N" data-fps="F"' or '' when the file is missing / not a usable strip.
 * Frame count: an optional sidecar <file>.json {"frames":N,"fps":F}, else width / $frameW (or width / height when $frameW is 0).
 * Fixed 6 fps unless the sidecar says otherwise. Written ONLY on the popover picture, never on a card.
 */
function anim_strip_attrs(string $rel, int $frameW = 0): string
{
    $f = APP_ROOT . '/' . $rel;
    if (!is_file($f)) return '';
    $sz = @getimagesize($f);
    if (!$sz || $sz[0] < 2 || $sz[1] < 1) return '';
    $n = 0;
    $fps = 6;
    $side = $f . '.json';
    if (is_file($side) && is_array($j = json_decode((string)@file_get_contents($side), true))) {
        $n = (int)($j['frames'] ?? 0);
        if (isset($j['fps'])) $fps = max(1, min(24, (int)$j['fps']));
    }
    if ($n < 1) $n = intdiv($sz[0], $frameW > 0 ? $frameW : $sz[1]);
    if ($n < 2 || $n > 64) return '';
    return ' data-anim="' . e(url($rel)) . '" data-frames="' . $n . '" data-fps="' . $fps . '"';
}

function pixel_has(string $rel): bool
{
    return is_file(APP_ROOT . '/' . $rel);
}

/** Normalise to 6 hex digits (no #), or '' if not a colour. */
function pixel_hex(string $c): string
{
    $c = ltrim(trim($c), '#');
    if (strlen($c) === 3) $c = $c[0] . $c[0] . $c[1] . $c[1] . $c[2] . $c[2];
    return preg_match('/^[0-9a-fA-F]{6}$/', $c) ? strtolower($c) : '';
}

/** <filter> that multiplies grey art by the tint. $gain brightens (petals/hats are ~80% of swatch: 1.25 lands on it; values clamp). */
function pixel_tint_filter(string $hex, float $gain = 1.25, string $uid = ''): string
{
    $h = pixel_hex($hex);
    if ($h === '') return '';
    [$r, $g, $b] = array_map(static fn($x) => round(hexdec($x) / 255 * $gain, 4), str_split($h, 2));
    return '<filter id="tint-' . $h . $uid . '" color-interpolation-filters="sRGB"><feColorMatrix type="matrix" values="' . "$r 0 0 0 0  0 $g 0 0 0  0 0 $b 0 0  0 0 0 1 0" . '"/></filter>';
}

/** One pixel <image> inside an SVG. $tintHex optional (needs pixel_tint_filter() in the same SVG's <defs>). */
function pixel_image(string $rel, float $x, float $y, float $w, float $h, string $tintHex = '', string $uid = '', string $par = '', string $cls = ''): string
{
    $f = $tintHex !== '' && pixel_hex($tintHex) !== '' ? ' filter="url(#tint-' . pixel_hex($tintHex) . $uid . ')"' : '';
    if ($par !== '') $f .= ' preserveAspectRatio="' . e($par) . '"';   // e.g. 'none' to stretch a scene over its box
    if ($cls !== '') $f .= ' class="' . e($cls) . '"';
    return '<image href="' . e(url($rel)) . '" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" image-rendering="pixelated"' . $f . '/>';
}
