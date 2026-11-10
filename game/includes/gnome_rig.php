<?php
declare(strict_types=1);
/**
 * The 2.5D gnome cut into rig parts for the fight engine (side view, idle frame), in the player's colours. Shared by tools/gnome_rig_parts.php (writes the default
 * sheet to assets/img/fight/rig-gnome.png) and gnome_parts.php (serves a colour set, cached).
 * ONE sheet: a column per part (GNOME_RIG_PARTS, 64x80 each, all in the same frame coordinates so they stack with no offsets), row 0 = the part's paint,
 * row 1 = its ink (a 1 px outline). The engine draws every ink behind every paint, so the gnome keeps one outline however the parts move.
 * Parts and pivots (frame px, see RIGS.gnome in assets/fightengine.js): legB 28,63  legF 36,63  body (tunic) 32,63  scarf 29,46  armU (shoulder) 33,48  armL (elbow) 33,55
 * head 33,46  beard 33,44  lid (closed eye)  hat 32,37  tip 28,11 (curl base). The arm, the bald head under the hat, the chin and the tunic under the beard are drawn here.
 * gnome_rig_parts(['hat'=>'#rrggbb','beard'=>..,'scarf'=>..]) -> [part => GdImage paint]
 */
require_once __DIR__ . '/gnome25.php';

const GNOME_RIG_PARTS = ['legB', 'legF', 'body', 'scarf', 'armU', 'armL', 'head', 'beard', 'lid', 'hat', 'tip'];
const GNOME_RIG_NOINK = ['armU', 'armL', 'lid'];   // the arm carries its own outline; the eyelid is a detail on the face

function gnome_rig_frame0(string $png): GdImage { $s = imagecreatefromstring($png); $f = imagecreatetruecolor(64, 80); imagealphablending($f, false); imagesavealpha($f, true); imagefill($f, 0, 0, imagecolorallocatealpha($f, 0, 0, 0, 127)); imagecopy($f, $s, 0, 0, 0, 0, 64, 80); return $f; }
function gnome_rig_blank(int $w = 64, int $h = 80): GdImage { $f = imagecreatetruecolor($w, $h); imagealphablending($f, false); imagesavealpha($f, true); imagefill($f, 0, 0, imagecolorallocatealpha($f, 0, 0, 0, 127)); return $f; }
function gnome_rig_has(GdImage $im, int $x, int $y): bool { return $x >= 0 && $y >= 0 && $x < 64 && $y < 80 && ((imagecolorat($im, $x, $y) >> 24) & 127) < 100; }
function gnome_rig_region(GdImage $src, callable $keep): GdImage { $f = gnome_rig_blank(); for ($y = 0; $y < 80; $y++) for ($x = 0; $x < 64; $x++) if ($keep($x, $y) && gnome_rig_has($src, $x, $y)) imagesetpixel($f, $x, $y, imagecolorat($src, $x, $y)); return $f; }
function gnome_rig_only(array $names, array $cols): GdImage { return gnome_rig_frame0(gnome25_compose('side', $cols, array_values(array_diff(array_column(GNOME25_ORDER, 0), $names)))); }
function gnome_rig_put(GdImage $dst, GdImage $src, ?callable $keep = null): void { for ($y = 0; $y < 80; $y++) for ($x = 0; $x < 64; $x++) { if (!gnome_rig_has($src, $x, $y)) continue; if ($keep && !$keep($x, $y)) continue; imagesetpixel($dst, $x, $y, imagecolorat($src, $x, $y)); } }
function gnome_rig_px(GdImage $im, int $x, int $y, array $c): void { imagesetpixel($im, $x, $y, imagecolorallocatealpha($im, $c[0], $c[1], $c[2], 0)); }
/** The colour used most in a picture (its base tone). */
function gnome_rig_main(GdImage $im): array { $n = []; for ($y = 0; $y < 80; $y++) for ($x = 0; $x < 64; $x++) if (gnome_rig_has($im, $x, $y)) { $c = imagecolorat($im, $x, $y) & 0xFFFFFF; $n[$c] = ($n[$c] ?? 0) + 1; } arsort($n); $c = (int)array_key_first($n); return [($c >> 16) & 255, ($c >> 8) & 255, $c & 255]; }

function gnome_rig_parts(array $cols): array
{
    $parts = [];
    $ink = [43, 28, 38]; $sk = [240, 185, 141]; $sh = [201, 138, 99]; $hr = [244, 241, 234];
    // hat = cone, brim and trim (rows up to 36); tip = the curl and bobble (left of x = 28, above y = 22), cut from the hat
    $hat = gnome_rig_region(gnome_rig_only(['hat', 'trim'], $cols), fn($x, $y) => $y <= 36);
    $parts['tip'] = gnome_rig_region($hat, fn($x, $y) => $x <= 28 && $y <= 22);
    $parts['hat'] = gnome_rig_region($hat, fn($x, $y) => !($x <= 28 && $y <= 22));

    // head = face skin, eye and mouth, plus what the art never drew: a bald dome with three hairs (the hat comes off) and a chin (the beard swings)
    $head = gnome_rig_blank();
    $dome = [30 => [30, 39], 31 => [28, 41], 32 => [27, 43], 33 => [26, 44], 34 => [26, 45], 35 => [26, 45], 36 => [26, 46]];
    foreach ($dome as $y => [$x0, $x1]) for ($x = $x0; $x <= $x1; $x++) gnome_rig_px($head, $x, $y, $x > $x1 - 3 ? $sh : $sk);
    foreach ([[33, 28], [33, 27], [34, 26], [36, 28], [37, 27], [35, 28]] as [$x, $y]) gnome_rig_px($head, $x, $y, $hr);   // three hairs
    foreach ([37 => [25, 42], 38 => [25, 42], 39 => [25, 44], 40 => [25, 45], 41 => [26, 46], 42 => [26, 46], 43 => [27, 46], 44 => [28, 45], 45 => [29, 44], 46 => [31, 42]] as $y => [$x0, $x1])
        for ($x = $x0; $x <= $x1; $x++) gnome_rig_px($head, $x, $y, $y >= 44 || $x < 28 ? $sh : $sk);
    gnome_rig_put($head, gnome_rig_only(['skin', 'face'], $cols), fn($x, $y) => $y <= 47);
    $parts['head'] = $head;
    // lid = the closed eye: skin over the eye, a dark lash line
    $lid = gnome_rig_blank();
    for ($y = 37; $y <= 40; $y++) for ($x = 36; $x <= 39; $x++) gnome_rig_px($lid, $x, $y, $y === 39 ? $ink : $sk);
    $parts['lid'] = $lid;
    $parts['beard'] = gnome_rig_only(['beard'], $cols);
    $parts['scarf'] = gnome_rig_only(['scarf'], $cols);

    // body = the tunic and its trim, with the holes (beard, scarf, the old tucked-in hand) filled in tunic colour and shoulders added under the beard
    $tunic = gnome_rig_only(['tunic'], $cols); $tc = gnome_rig_main($tunic);
    $body = gnome_rig_blank();
    foreach ([46 => [27, 39], 47 => [25, 41], 48 => [24, 42], 49 => [23, 42]] as $y => [$x0, $x1]) for ($x = $x0; $x <= $x1; $x++) gnome_rig_px($body, $x, $y, $tc);
    for ($y = 50; $y <= 63; $y++) {
        $x0 = 99; $x1 = -1;
        for ($x = 0; $x < 64; $x++) if (gnome_rig_has($tunic, $x, $y)) { $x0 = min($x0, $x); $x1 = max($x1, $x); }
        for ($x = min($x0, 23); $x <= $x1; $x++) gnome_rig_px($body, $x, $y, $tc);
    }
    gnome_rig_put($body, $tunic);
    gnome_rig_put($body, gnome_rig_only(['trim'], $cols), fn($x, $y) => $y > 40);
    $parts['body'] = $body;
    $boots = gnome_rig_only(['boots'], $cols);
    $parts['legB'] = gnome_rig_region($boots, fn($x, $y) => $x < 32);
    $parts['legF'] = gnome_rig_region($boots, fn($x, $y) => $x >= 32);

    // The arm, two pieces: sleeve (armU, hangs from the shoulder at 33,48) and cuff + hand (armL, turns at the elbow 33,55). o ink, q/b/s sleeve hi/base/shade, t cuff, k/K hand.
    $pal = ['o' => '#2b1c26', 'q' => '#8fdcd9', 'b' => '#5fc4c8', 's' => '#3a86b0', 't' => '#2b5f8a', 'k' => '#f0b98d', 'K' => '#c98a63'];
    $draw = function (array $rows, int $oy) use ($pal): GdImage {
        $im = gnome_rig_blank();
        foreach ($rows as $r => $row) for ($c = 0; $c < 7; $c++) { $ch = $row[$c]; if ($ch !== '.') gnome_rig_px($im, 30 + $c, $oy + $r, gnome25_hex($pal[$ch])); }
        return $im;
    };
    $parts['armU'] = $draw(['.ooooo.', 'oqqbbbo', 'oqbbbso', 'oqbbbso', 'oqbbbso', 'oqbbsso', 'oqbbsso', 'oqbbsso', 'oqbbsso', 'oqbbsso', 'oqbbsso', '.ooooo.'], 46);
    $parts['armL'] = $draw(['.ooooo.', 'oqbbsso', 'oqbbsso', 'obbbsso', 'ottttto', '.okkkko', 'okkkkKo', 'okkkkKo', 'okkkKKo', '.oKKKo.', '..ooo..'], 52);
    return $parts;
}

/** The sheet for a colour set as PNG bytes: GNOME_RIG_PARTS left to right, paint over ink. */
function gnome_rig_sheet(array $cols): string
{
    $parts = gnome_rig_parts($cols); $n = count(GNOME_RIG_PARTS);
    $out = gnome_rig_blank(64 * $n, 160);
    foreach (GNOME_RIG_PARTS as $i => $name) {
        $im = $parts[$name];
        for ($y = 0; $y < 80; $y++) for ($x = 0; $x < 64; $x++) {
            if (gnome_rig_has($im, $x, $y)) { imagesetpixel($out, $i * 64 + $x, $y, imagecolorat($im, $x, $y)); continue; }
            if (in_array($name, GNOME_RIG_NOINK, true)) continue;
            if (gnome_rig_has($im, $x + 1, $y) || gnome_rig_has($im, $x - 1, $y) || gnome_rig_has($im, $x, $y + 1) || gnome_rig_has($im, $x, $y - 1)) gnome_rig_px($out, $i * 64 + $x, 80 + $y, [43, 28, 38]);
        }
        imagedestroy($im);
    }
    ob_start(); imagepng($out); $png = (string)ob_get_clean(); imagedestroy($out);
    return $png;
}

/** URL of the player's rig sheet in the player's colours, for FightEngine.add(...,{sheet}). '' when the art is not there (the engine then uses the default sheet). */
function gnome_rig_url(array $u): string
{
    if (!is_file(APP_ROOT . '/assets/img/gnome25/side-hat.png')) return '';
    $c = gnome25_colours($u); $q = [];
    foreach (['hat' => 'h', 'beard' => 'b', 'scarf' => 's'] as $role => $k) if (isset($c[$role])) $q[$k] = ltrim($c[$role], '#');
    return url('gnome_parts.php?' . http_build_query(['p' => 'sheet', 'v' => '2'] + $q));
}
