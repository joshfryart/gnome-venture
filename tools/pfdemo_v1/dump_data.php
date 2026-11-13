<?php
// Build-time: the game's own data tables for the playable demo (read by tools/build_pf_demo_v1.py). Prints JSON.
// php tools/pfdemo_v1/dump_data.php > data.json     (no database: the pure part of the deck model)
$G = ($argv[1] ?? (__DIR__ . '/../..')) . '/game/includes/';   // the game root (a copy of a release, or the working copy)
require $G . 'pfboard.php'; require $G . 'pfight_game.php'; require $G . 'pfdeck.php'; require $G . 'tools.php';
$SLUGS = ['aphid-swarm' => 'CA', 'garden-snail' => 'NWE', 'leopard-slug' => 'SA', 'shore-crab' => 'SE', 'carrion-crow' => 'EE', 'thistle-beast' => 'ESA', 'orb-spider' => 'NA',
    'grass-snake' => 'SA', 'badger' => 'NWE', 'red-fox' => 'EE', 'bramble-wolf' => 'NA', 'dune-wyrm' => 'MENA', 'ancient-snapper' => 'CB'];
$die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10]; $cr = [];
foreach (file($G . 'data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue; $slug = trim($c[0]);
    if (!isset($SLUGS[$slug])) continue;
    $lv = max(1, (int)$c[4]); $row = ['slug' => $slug, 'name' => trim($c[1]), 'size' => trim($c[2]), 'level' => $lv, 'dmg_die' => $die[trim($c[2])] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
    $row = pfd_foe_row($row, $SLUGS[$slug]); $row['desc'] = trim($c[6]); $row['region'] = $SLUGS[$slug]; $row['temper'] = pf_temper($row);
    $cr[$slug] = $row;
}
$order = array_keys($SLUGS); $creatures = []; foreach ($order as $s) if (isset($cr[$s])) $creatures[] = $cr[$s];
$reg = []; foreach (file($G . 'data/regions.txt', FILE_IGNORE_NEW_LINES) as $l) { if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); $reg[trim($c[0])] = trim($c[1]); }
$tt = []; foreach (TOOL_TYPES as $k => $v) $tt[$k] = [$v[0], $v[1]];
echo json_encode(['catalog' => pfd_catalog(), 'creatures' => $creatures, 'regions' => $reg, 'toolTypes' => $tt, 'tags' => PF_TAGS, 'mods' => PF_MODS, 'callingTile' => PF_CALLING_TILE,
    'consts' => ['offer' => PFD_OFFER, 'kits' => PFD_KITS, 'core' => PFD_CORE, 'rankName' => PFD_RANK_NAME, 'rankBonus' => PFD_RANK_BONUS, 'belts' => PFD_BELTS, 'layers' => PFD_LAYERS, 'durBase' => PFD_DUR_BASE, 'durRank' => PFD_DUR_RANK,
        'rareCap' => PFD_RARE_CAP, 'mwCap' => PFD_MW_CAP, 'kitMin' => PFD_KIT_MIN, 'picks' => PFD_PICKS, 'toolWear' => PFB_TOOL_WEAR, 'foeFires' => PFB_FOE_FIRES]], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
