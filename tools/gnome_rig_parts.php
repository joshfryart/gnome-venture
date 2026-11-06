<?php
declare(strict_types=1);
/**
 * Writes the gnome rig parts for the fight engine to game/assets/img/fight/rig-gnome-<part>.png (the cutting lives in game/includes/gnome_rig.php).
 * Usage: php tools/gnome_rig_parts.php [hat=#rrggbb beard=#rrggbb scarf=#rrggbb out=dir]   (no args = the colours the gnome was drawn with)
 */
define('APP_ROOT', dirname(__DIR__) . '/game');
require APP_ROOT . '/includes/gnome_rig.php';
$o = [];
foreach (array_slice($argv, 1) as $a) { [$k, $v] = array_pad(explode('=', $a, 2), 2, ''); $o[$k] = $v; }
$cols = array_filter(array_intersect_key($o, ['hat' => 1, 'beard' => 1, 'scarf' => 1]), fn($v) => preg_match('/^#[0-9a-f]{6}$/i', $v) === 1);
$out = $o['out'] ?? APP_ROOT . '/assets/img/fight';
if (!is_dir($out)) mkdir($out, 0775, true);
foreach (gnome_rig_parts($cols) as $name => $im) { imagesavealpha($im, true); imagepng($im, "$out/rig-gnome-$name.png"); imagedestroy($im); }
echo "parts written to $out\n";
