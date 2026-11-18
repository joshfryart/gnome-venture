<?php
// Draws the 12 gnome NPCs as 2.5D strips (front, back, side; 512 x 80, 8 frames of 64 x 80) from the player's gnome rig (game/assets/img/gnome25) with a look of their own:
// a full set of rig colours (hat, beard, scarf, tunic, boots, skin, trim) and worn pieces (c cloak, p pack, h brim, g gloves, b flood boots). Output: game/assets/img/npc25/gnome-<slug>-<view>.png.
// Usage: php tools/gen_gnome_npcs.php        (re-run after changing the table; the pictures are committed)
define('APP_ROOT', dirname(__DIR__) . '/game');
require_once APP_ROOT . '/includes/gnome25.php';
$LOOKS = [   // slug => [colours by rig role, worn pieces]
    'coral-pennyfeather'     => [['hat' => '#2f9e9a', 'beard' => '#f0e6d2', 'scarf' => '#ff7f6e', 'tunic' => '#f2c14e', 'boots' => '#6b4a3a', 'skin' => '#f0b98d', 'trim' => '#ffffff'], ''],     // cheerful: sea-teal hat, coral scarf, sunny tunic
    'nonna-briscola'         => [['hat' => '#8c2f39', 'beard' => '#e8e4ec', 'scarf' => '#e8d9b0', 'tunic' => '#4a6741', 'boots' => '#5b3b2e', 'skin' => '#f0b98d', 'trim' => '#d6a64a'], 'p'],    // warm: wine-red hat, olive tunic, a market basket pack
    'abuela-quilla'          => [['hat' => '#d96ca0', 'beard' => '#f4f1f6', 'scarf' => '#6a4c93', 'tunic' => '#f4a259', 'boots' => '#7a4b3a', 'skin' => '#d9a074', 'trim' => '#ffe29a'], ''],     // quilt-bright: pink hat, plum scarf, marigold tunic
    'babka-wren'             => [['hat' => '#5a6b7b', 'beard' => '#c9ced6', 'scarf' => '#a05a3c', 'tunic' => '#3d4f63', 'boots' => '#3b2a22', 'skin' => '#e8b48c', 'trim' => '#9aa7b5'], 'c'],    // gruff: slate hat, grey beard, a travelling cloak
    'auntie-saffira'         => [['hat' => '#e0a526', 'beard' => '#fff3d2', 'scarf' => '#c1121f', 'tunic' => '#7b2d8e', 'boots' => '#6b3e2a', 'skin' => '#c68a5e', 'trim' => '#ffe27a'], ''],     // gentle: saffron hat, crimson scarf, violet tunic
    'grandmother-hoshi'      => [['hat' => '#7d9ec0', 'beard' => '#f7f7fb', 'scarf' => '#f2f2f2', 'tunic' => '#e9d8f0', 'boots' => '#4d4a5a', 'skin' => '#f2cfa6', 'trim' => '#b9c6dd'], ''],     // calm: moon-blue hat, silver-white everything
    'didi-marigold'          => [['hat' => '#f28f1c', 'beard' => '#7a4b2a', 'scarf' => '#2a9d8f', 'tunic' => '#e76f51', 'boots' => '#43302b', 'skin' => '#b9784f', 'trim' => '#ffd166'], 'g'],    // cheerful: marigold hat, brown beard, gardening gloves
    'pak-lontar'             => [['hat' => '#3a7d44', 'beard' => '#3b2a22', 'scarf' => '#f0d58a', 'tunic' => '#b5651d', 'boots' => '#2f241f', 'skin' => '#a86b45', 'trim' => '#e9c46a'], 'h'],    // eager: palm-green hat, a wayfarer brim
    'auntie-mossbead'        => [['hat' => '#6b8f3a', 'beard' => '#ece6d6', 'scarf' => '#7bb274', 'tunic' => '#8a6f47', 'boots' => '#4a3a2a', 'skin' => '#efb98f', 'trim' => '#c9d99a'], 'p'],    // warm: moss hat and scarf, a mushroom-gathering pack
    'old-baobab-kito'        => [['hat' => '#a5673f', 'beard' => '#d9d0c1', 'scarf' => '#8a3b12', 'tunic' => '#6e4b2f', 'boots' => '#3a2a20', 'skin' => '#8d5a3b', 'trim' => '#e0b872'], ''],     // patient: baobab-bark brown, ash beard
    'captain-pipi-shellback' => [['hat' => '#1d3557', 'beard' => '#c8d6e5', 'scarf' => '#e63946', 'tunic' => '#f1faee', 'boots' => '#22303c', 'skin' => '#e6ad84', 'trim' => '#f5c542'], 'cb'],  // salty: navy cap, red neckerchief, cloak and sea boots
    'keeper-marram'          => [['hat' => '#7a8fa6', 'beard' => '#d8d2c4', 'scarf' => '#e7c26a', 'tunic' => '#3f5a73', 'boots' => '#3b2c26', 'skin' => '#e6b08a', 'trim' => '#f2e6c8'], 'c'],    // warm lighthouse keeper: knitted slate-blue cap, navy coat, a lantern-yellow scarf, a weather cloak
];
$out = APP_ROOT . '/assets/img/npc25/';
if (!is_dir($out)) mkdir($out, 0775, true);
$n = 0;
foreach ($LOOKS as $slug => [$cols, $wear]) foreach (['front', 'back', 'side'] as $view) {
    $png = gnome25_compose($view, $cols, [], $wear);
    if ($png === '') { fwrite(STDERR, "FAILED $slug $view\n"); exit(1); }
    file_put_contents($out . 'gnome-' . $slug . '-' . $view . '.png', $png); $n++;
}
echo "wrote $n strips\n";
