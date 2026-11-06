<?php
declare(strict_types=1);
/**
 * Cuts the 2.5D gnome (side view, idle frame) into rig parts for the fight engine, and draws the arm.
 * Output: game/assets/img/fight/rig-gnome-{shadow,torso,hat,tip,legB,legF,arm}.png, all 64x80 in the same frame coordinates, so parts stack with no offsets.
 * Pivots (frame px): torso 32,64  hat 32,37 (head top)  tip 28,11 (curl base)  legB 28,63  legF 36,63  arm (shoulder) 33,48. The arm is new pixel art (the old gnome had none: hands tucked in the beard).
 * Usage: php tools/gnome_rig_parts.php [hat=#rrggbb beard=#rrggbb scarf=#rrggbb out=dir]   (no args = the colours the gnome was drawn with)
 */
define('APP_ROOT', dirname(__DIR__) . '/game');
require APP_ROOT . '/includes/gnome25.php';
$o = [];
foreach (array_slice($argv, 1) as $a) { [$k, $v] = array_pad(explode('=', $a, 2), 2, ''); $o[$k] = $v; }
$cols = array_filter(array_intersect_key($o, ['hat' => 1, 'beard' => 1, 'scarf' => 1]), fn($v) => preg_match('/^#[0-9a-f]{6}$/i', $v) === 1);
$out = $o['out'] ?? APP_ROOT . '/assets/img/fight';
if (!is_dir($out)) mkdir($out, 0775, true);

function frame0(string $png): GdImage { $s = imagecreatefromstring($png); $f = imagecreatetruecolor(64, 80); imagealphablending($f, false); imagesavealpha($f, true); imagefill($f, 0, 0, imagecolorallocatealpha($f, 0, 0, 0, 127)); imagecopy($f, $s, 0, 0, 0, 0, 64, 80); return $f; }
function blank(): GdImage { $f = imagecreatetruecolor(64, 80); imagealphablending($f, false); imagesavealpha($f, true); imagefill($f, 0, 0, imagecolorallocatealpha($f, 0, 0, 0, 127)); return $f; }
function region(GdImage $src, callable $keep): GdImage { $f = blank(); for ($y = 0; $y < 80; $y++) for ($x = 0; $x < 64; $x++) if ($keep($x, $y)) imagesetpixel($f, $x, $y, imagecolorat($src, $x, $y)); return $f; }
function save(GdImage $im, string $path): void { imagesavealpha($im, true); imagepng($im, $path); imagedestroy($im); }

$allBut = array_column(GNOME25_ORDER, 0);
function only(array $names, array $cols, array $all): GdImage { return frame0(gnome25_compose('side', $cols, array_values(array_diff($all, $names)))); }
function without(array $names, array $cols): GdImage { return frame0(gnome25_compose('side', $cols, $names)); }
function put(GdImage $dst, GdImage $src, ?callable $keep = null): void { imagealphablending($dst, true); for ($y = 0; $y < 80; $y++) for ($x = 0; $x < 64; $x++) { $c = imagecolorat($src, $x, $y); if ((($c >> 24) & 127) > 100) continue; if ($keep && !$keep($x, $y)) continue; imagesetpixel($dst, $x, $y, $c); } imagealphablending($dst, false); }
$HAT_Y = 37;   // the hat (cone, brim, trim, and its outline) is everything at or above this row; head, beard and body are below it
save(only(['shadow'], $cols, $allBut), "$out/rig-gnome-shadow.png");

// hat = hat + trim layers over the outline rows above the brim; tip = the curl and bobble (left of x=28, above y=22), cut from the hat
$hat = blank(); put($hat, only(['outline'], $cols, $allBut), fn($x, $y) => $y <= $HAT_Y); put($hat, only(['hat', 'trim'], $cols, $allBut), fn($x, $y) => $y <= 40);   // trim pixels lower down are the buckle etc.: body
$tip = region($hat, fn($x, $y) => $x <= 28 && $y <= 22);
save(region($hat, fn($x, $y) => !($x < 28 && $y <= 22)), "$out/rig-gnome-hat.png");
save($tip, "$out/rig-gnome-tip.png");

// torso = everything else; under the hat there is a bald head with a few hairs, so the hat can come off
$torso = blank();
$ink = [43, 28, 38]; $sk = [240, 185, 141]; $sh = [201, 138, 99]; $hr = [244, 241, 234];
$dome = [30 => [30, 39], 31 => [28, 41], 32 => [27, 43], 33 => [26, 44], 34 => [26, 45], 35 => [26, 45], 36 => [26, 46]];
$px = function (GdImage $im, int $x, int $y, array $c) { imagesetpixel($im, $x, $y, imagecolorallocatealpha($im, $c[0], $c[1], $c[2], 0)); };
imagealphablending($torso, false);
foreach ($dome as $y => [$x0, $x1]) { $px($torso, $x0 - 1, $y, $ink); $px($torso, $x1 + 1, $y, $ink); for ($x = $x0; $x <= $x1; $x++) $px($torso, $x, $y, $x > $x1 - 3 ? $sh : $sk); }
for ($x = 30; $x <= 39; $x++) $px($torso, $x, 29, $ink);
foreach ([[33, 28], [33, 27], [34, 26], [36, 28], [37, 27], [35, 28]] as [$x, $y]) $px($torso, $x, $y, $hr);   // three hairs
put($torso, only(['outline'], $cols, $allBut), fn($x, $y) => $y > $HAT_Y && !($y <= 39 && $x <= 21));   // not the brim underside
put($torso, without(['shadow', 'hat', 'trim', 'outline'], $cols));
put($torso, only(['trim'], $cols, $allBut), fn($x, $y) => $y > 40);
save(region($torso, fn($x, $y) => $y < 64), "$out/rig-gnome-torso.png");
$legs = without(['shadow', 'hat', 'trim'], $cols);
save(region($legs, fn($x, $y) => $y >= 64 && $x < 32), "$out/rig-gnome-legB.png");
save(region($legs, fn($x, $y) => $y >= 64 && $x >= 32), "$out/rig-gnome-legF.png");

// The arm: sleeve + cuff + hand, 7x16, hangs from the shoulder at (33,48). o ink, q/b/s sleeve hi/base/shade, t cuff, k/K hand.
$pal = ['o' => '#2b1c26', 'q' => '#8fdcd9', 'b' => '#5fc4c8', 's' => '#3a86b0', 't' => '#2b5f8a', 'k' => '#f0b98d', 'K' => '#c98a63'];
$arm = ['.ooooo.', 'oqqbbbo', 'oqbbbso', 'oqbbbso', 'oqbbbso', 'oqbbsso', 'oqbbsso', 'oqbbsso', 'oqbbsso', 'obbbsso', 'ottttto', '.okkkko', 'okkkkKo', 'okkkkKo', 'okkkKKo', '.oKKKo.', '..ooo..'];
$im = blank(); $ox = 30; $oy = 46;
foreach ($arm as $r => $row) for ($c = 0; $c < 7; $c++) {
    $ch = $row[$c]; if ($ch === '.') continue;
    [$R, $G, $B] = gnome25_hex($pal[$ch]); imagesetpixel($im, $ox + $c, $oy + $r, imagecolorallocatealpha($im, $R, $G, $B, 0));
}
save($im, "$out/rig-gnome-arm.png");
echo "parts written to $out\n";
