<?php
declare(strict_types=1);
/**
 * The 2.5D gnome cut into rig parts for the fight engine (side view, idle frame), in the player's colours. Shared by tools/gnome_rig_parts.php (writes the default set to disk)
 * and gnome_parts.php (serves a colour set, cached). All parts are 64x80 in the same frame coordinates, so they stack with no offsets.
 * Pivots (frame px): torso 32,64  hat 32,37 (head top)  tip 28,11 (curl base)  legB 28,63  legF 36,63  arm (shoulder) 33,48. The arm is pixel art drawn here (placeholder for an Aseprite redraw).
 * gnome_rig_parts(['hat'=>'#rrggbb','beard'=>..,'scarf'=>..]) -> ['shadow'|'hat'|'tip'|'torso'|'legB'|'legF'|'arm' => GdImage]
 */
require_once __DIR__ . '/gnome25.php';

function gnome_rig_frame0(string $png): GdImage { $s = imagecreatefromstring($png); $f = imagecreatetruecolor(64, 80); imagealphablending($f, false); imagesavealpha($f, true); imagefill($f, 0, 0, imagecolorallocatealpha($f, 0, 0, 0, 127)); imagecopy($f, $s, 0, 0, 0, 0, 64, 80); return $f; }
function gnome_rig_blank(): GdImage { $f = imagecreatetruecolor(64, 80); imagealphablending($f, false); imagesavealpha($f, true); imagefill($f, 0, 0, imagecolorallocatealpha($f, 0, 0, 0, 127)); return $f; }
function gnome_rig_region(GdImage $src, callable $keep): GdImage { $f = gnome_rig_blank(); for ($y = 0; $y < 80; $y++) for ($x = 0; $x < 64; $x++) if ($keep($x, $y)) imagesetpixel($f, $x, $y, imagecolorat($src, $x, $y)); return $f; }
function gnome_rig_save(GdImage $im, string $path): void { imagesavealpha($im, true); imagepng($im, $path); imagedestroy($im); }


function gnome_rig_only(array $names, array $cols, array $all): GdImage { return gnome_rig_frame0(gnome25_compose('side', $cols, array_values(array_diff($all, $names)))); }
function gnome_rig_without(array $names, array $cols): GdImage { return gnome_rig_frame0(gnome25_compose('side', $cols, $names)); }
function gnome_rig_put(GdImage $dst, GdImage $src, ?callable $keep = null): void { imagealphablending($dst, true); for ($y = 0; $y < 80; $y++) for ($x = 0; $x < 64; $x++) { $c = imagecolorat($src, $x, $y); if ((($c >> 24) & 127) > 100) continue; if ($keep && !$keep($x, $y)) continue; imagesetpixel($dst, $x, $y, $c); } imagealphablending($dst, false); }

function gnome_rig_parts(array $cols): array
{
$parts = []; $allBut = array_column(GNOME25_ORDER, 0);
$HAT_Y = 37;   // the hat (cone, brim, trim, and its outline) is everything at or above this row; head, beard and body are below it
$parts["shadow"] = gnome_rig_only(['shadow'], $cols, $allBut);

// hat = hat + trim layers over the outline rows above the brim; tip = the curl and bobble (left of x=28, above y=22), cut from the hat
$hat = gnome_rig_blank(); gnome_rig_put($hat, gnome_rig_only(['outline'], $cols, $allBut), fn($x, $y) => $y <= $HAT_Y); gnome_rig_put($hat, gnome_rig_only(['hat', 'trim'], $cols, $allBut), fn($x, $y) => $y <= 40);   // trim pixels lower down are the buckle etc.: body
$tip = gnome_rig_region($hat, fn($x, $y) => $x <= 28 && $y <= 22);
$parts["hat"] = gnome_rig_region($hat, fn($x, $y) => !($x < 28 && $y <= 22));
$parts["tip"] = $tip;

// torso = everything else; under the hat there is a bald head with a few hairs, so the hat can come off
$torso = gnome_rig_blank();
$ink = [43, 28, 38]; $sk = [240, 185, 141]; $sh = [201, 138, 99]; $hr = [244, 241, 234];
$dome = [30 => [30, 39], 31 => [28, 41], 32 => [27, 43], 33 => [26, 44], 34 => [26, 45], 35 => [26, 45], 36 => [26, 46]];
$px = function (GdImage $im, int $x, int $y, array $c) { imagesetpixel($im, $x, $y, imagecolorallocatealpha($im, $c[0], $c[1], $c[2], 0)); };
imagealphablending($torso, false);
foreach ($dome as $y => [$x0, $x1]) { $px($torso, $x0 - 1, $y, $ink); $px($torso, $x1 + 1, $y, $ink); for ($x = $x0; $x <= $x1; $x++) $px($torso, $x, $y, $x > $x1 - 3 ? $sh : $sk); }
for ($x = 30; $x <= 39; $x++) $px($torso, $x, 29, $ink);
foreach ([[33, 28], [33, 27], [34, 26], [36, 28], [37, 27], [35, 28]] as [$x, $y]) $px($torso, $x, $y, $hr);   // three hairs
gnome_rig_put($torso, gnome_rig_only(['outline'], $cols, $allBut), fn($x, $y) => $y > $HAT_Y && !($y <= 39 && $x <= 21));   // not the brim underside
gnome_rig_put($torso, gnome_rig_without(['shadow', 'hat', 'trim', 'outline'], $cols));
gnome_rig_put($torso, gnome_rig_only(['trim'], $cols, $allBut), fn($x, $y) => $y > 40);
$parts["torso"] = gnome_rig_region($torso, fn($x, $y) => $y < 64);
$legs = gnome_rig_without(['shadow', 'hat', 'trim'], $cols);
$parts["legB"] = gnome_rig_region($legs, fn($x, $y) => $y >= 64 && $x < 32);
$parts["legF"] = gnome_rig_region($legs, fn($x, $y) => $y >= 64 && $x >= 32);

// The arm: sleeve + cuff + hand, 7x16, hangs from the shoulder at (33,48). o ink, q/b/s sleeve hi/base/shade, t cuff, k/K hand.
$pal = ['o' => '#2b1c26', 'q' => '#8fdcd9', 'b' => '#5fc4c8', 's' => '#3a86b0', 't' => '#2b5f8a', 'k' => '#f0b98d', 'K' => '#c98a63'];
$arm = ['.ooooo.', 'oqqbbbo', 'oqbbbso', 'oqbbbso', 'oqbbbso', 'oqbbsso', 'oqbbsso', 'oqbbsso', 'oqbbsso', 'obbbsso', 'ottttto', '.okkkko', 'okkkkKo', 'okkkkKo', 'okkkKKo', '.oKKKo.', '..ooo..'];
$im = gnome_rig_blank(); $ox = 30; $oy = 46;
foreach ($arm as $r => $row) for ($c = 0; $c < 7; $c++) {
    $ch = $row[$c]; if ($ch === '.') continue;
    [$R, $G, $B] = gnome25_hex($pal[$ch]); imagesetpixel($im, $ox + $c, $oy + $r, imagecolorallocatealpha($im, $R, $G, $B, 0));
}
$parts["arm"] = $im;
return $parts;
}

const GNOME_RIG_PARTS = ['torso', 'legB', 'legF', 'arm', 'hat', 'tip'];

/** All rig parts for a colour set as PNG bytes (the engine's part list only; the shadow part is unused). */
function gnome_rig_png(array $cols): array
{
    $out = [];
    foreach (gnome_rig_parts($cols) as $name => $im) {
        if (!in_array($name, GNOME_RIG_PARTS, true)) { imagedestroy($im); continue; }
        imagesavealpha($im, true); ob_start(); imagepng($im); $out[$name] = (string)ob_get_clean(); imagedestroy($im);
    }
    return $out;
}

/** URLs of the player's rig parts (part id => url) in the player's colours, for FightEngine.add(...,{parts}). [] when the art is not there (use the default parts). */
function gnome_rig_urls(array $u): array
{
    if (!is_file(APP_ROOT . '/assets/img/gnome25/side-hat.png')) return [];
    $c = gnome25_colours($u); $q = [];
    foreach (['hat' => 'h', 'beard' => 'b', 'scarf' => 's'] as $role => $k) if (isset($c[$role])) $q[$k] = ltrim($c[$role], '#');
    $urls = [];
    foreach (GNOME_RIG_PARTS as $p) $urls[$p] = url('gnome_parts.php?' . http_build_query(['p' => $p] + $q));
    return $urls;
}
