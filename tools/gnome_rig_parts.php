<?php
declare(strict_types=1);
/**
 * Writes the gnome's rig sheet for the fight engine to game/assets/img/fight/rig-gnome.png (the cutting lives in game/includes/gnome_rig.php).
 * Usage: php tools/gnome_rig_parts.php [hat=#rrggbb beard=#rrggbb scarf=#rrggbb out=file.png]   (no args = the colours the gnome was drawn with)
 */
define('APP_ROOT', dirname(__DIR__) . '/game');
require APP_ROOT . '/includes/gnome_rig.php';
$o = [];
foreach (array_slice($argv, 1) as $a) { [$k, $v] = array_pad(explode('=', $a, 2), 2, ''); $o[$k] = $v; }
$cols = array_filter(array_intersect_key($o, ['hat' => 1, 'beard' => 1, 'scarf' => 1]), fn($v) => preg_match('/^#[0-9a-f]{6}$/i', $v) === 1);
$out = $o['out'] ?? APP_ROOT . '/assets/img/fight/rig-gnome.png';
file_put_contents($out, gnome_rig_sheet($cols));
echo "sheet written to $out (" . implode(', ', GNOME_RIG_PARTS) . ")\n";
