<?php
declare(strict_types=1);
/**
 * Cuts the 2.5D gnome (side view, idle frame) into rig parts for the fight engine, and draws the arm.
 * Output: game/assets/img/fight/rig-gnome-{shadow,torso,legB,legF,arm}.png, all 64x80 in the same frame coordinates, so parts stack with no offsets.
 * Pivots (frame px): torso 32,64  legB 28,63  legF 36,63  arm (shoulder) 33,48. The arm is new pixel art (the old gnome had none: hands tucked in the beard).
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
$body = frame0(gnome25_compose('side', $cols, ['shadow']));
$shadow = frame0(gnome25_compose('side', $cols, array_values(array_diff($allBut, ['shadow']))));
save($shadow, "$out/rig-gnome-shadow.png");
save(region($body, fn($x, $y) => $y < 64), "$out/rig-gnome-torso.png");
save(region($body, fn($x, $y) => $y >= 64 && $x < 32), "$out/rig-gnome-legB.png");
save(region($body, fn($x, $y) => $y >= 64 && $x >= 32), "$out/rig-gnome-legF.png");

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
