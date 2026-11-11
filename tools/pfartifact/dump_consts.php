<?php
// php tools/pfartifact/dump_consts.php : the tables the artifact needs, as JSON (tags, upgrades, combos, which tag icon file).
require __DIR__ . '/../../game/includes/pfboard.php';
$src = file_get_contents(__DIR__ . '/../../game/includes/pfight_game.php');
preg_match("/const PF_TAG_ICON = \[(.*?)\];/s", $src, $m); preg_match_all("/'(\w+)' => '(\w+)'/", $m[1], $mm, PREG_SET_ORDER);
$ti = []; foreach ($mm as $x) $ti[$x[1]] = $x[2];
echo json_encode(['tags' => PF_TAGS, 'mods' => PF_MODS, 'combos' => PF_COMBOS, 'tagIcon' => $ti, 'hole' => PF_HOLE, 'life' => PFB_LIFE], JSON_UNESCAPED_UNICODE);
