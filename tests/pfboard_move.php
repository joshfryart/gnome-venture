<?php
// php tests/pfboard_move.php GAMEDIR : prints one legal move for the test gnome in its current board fight, as "handIndex,x,y" (or "PASS" when nothing fits, or "NONE" when there is no board fight).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/pfight_game.php';
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$exp = active_expedition((int)$u['id']);
$enc = $exp && $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
$s = $enc['pf'] ?? null;
if (!$s || ($s['mode'] ?? '') !== 'board') { echo "NONE\n"; exit; }
$mode = $argv[2] ?? 'place';
if ($mode === 'join') {   // a legal "j,a,b,SIDE" (set two hand pieces aside), or NONE
    $hand = $s['me']['hand'];
    foreach ($hand as $ai => $ta) foreach ($hand as $bi => $tb) { if ($ai === $bi) continue; foreach (PFB_SIDE as $side => [$dx, $dy]) { $g = ['pcs' => [['tile' => $ta, 'x' => 0, 'y' => 0]]]; if (pfb_group_fit($g, $tb, $dx, $dy) === true) { echo "j,$ai,$bi,$side\n"; exit; } } }
    echo "NONE\n"; exit;
}
if ($mode === 'add') {   // a legal "h,b,anc,SIDE" onto the set-aside group, or NONE
    $g = $s['me']['held'] ?? null; if (!$g) { echo "NONE\n"; exit; }
    foreach ($s['me']['hand'] as $bi => $t) { $o = pfb_group_options($g, $t); if ($o) { echo "h,$bi,{$o[0][0]},{$o[0][1]}\n"; exit; } }
    echo "NONE\n"; exit;
}
if ($mode === 'group') {   // "c,x,y" for the set-aside group, or NONE
    $g = $s['me']['held'] ?? null; $sp = $g ? pfb_group_spots($s, $g) : []; echo $sp ? "c,{$sp[0][0]},{$sp[0][1]}\n" : "NONE\n"; exit;
}
$m = pfb_search($s, 'me');
echo $m ? $m[0] . ',' . $m[1] . ',' . $m[2] . "\n" : "PASS\n";
