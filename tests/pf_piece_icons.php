<?php
// 2.7.44: a creature's own 3 pieces carry 'ik', the key of their hand-drawn icon in game/assets/img/pfight/pieces/ (ico-<ik>.png 32px, ico-<ik>-s.png 20px).
// php tests/pf_piece_icons.php   (no database: reads data/pf_creature_pieces.txt and the icon folder)
require __DIR__ . '/../game/includes/pfboard.php'; require __DIR__ . '/../game/includes/pfight_game.php'; require __DIR__ . '/../game/includes/pfdeck.php';
$bad = 0;
function chk(string $n, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $n . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
$dir = __DIR__ . '/../game/assets/img/pfight/pieces/';
$files = array_values(array_filter(array_map('basename', glob($dir . 'ico-*.png')), fn($f) => strncmp($f, 'ico-pl-', 7) !== 0));   // 2.7.48: ico-pl-* are the player's pieces
chk('2552 icon files (1,276 pieces x 32px and 20px)', count($files) === 2552, count($files));
$U = pfd_uniques(); $have = 0; $miss = 0; $badk = 0;
foreach ($U as $slug => $u) {
    foreach (pfd_foe_pieces(['slug' => $slug, 'size' => 'small']) as $t) {
        if ($t['layer'] !== 'uni') continue;
        if ($t['ik'] === '') { $miss++; continue; }
        if (is_file($dir . 'ico-' . $t['ik'] . '.png') && is_file($dir . 'ico-' . $t['ik'] . '-s.png')) $have++; else $badk++;
    }
}
chk('every icon key points at both files', $badk === 0, $badk);
chk('1,276 creature pieces show a drawn icon', $have === 1276, $have);
chk('every creature piece has an icon (a lair guardian borrowing a boss pieces keeps the type emoji)', $miss === 0, $miss);
$base = array_values(array_filter(pfd_foe_pieces(['slug' => 'aphid-swarm', 'size' => 'small']), fn($t) => $t['layer'] === 'base'));
chk('class base pieces carry no icon key', $base && !array_filter($base, fn($t) => $t['ik'] !== ''));
chk('boss-... guardian borrowing pieces carries no key', !array_filter(pfd_foe_pieces(['slug' => 'boss-zzz-test', 'size' => 'boss']), fn($t) => ($t['ik'] ?? '') !== ''));
// 2.7.48: the player's own pieces (pf_pieces.txt, minus the basic six and the 14 tagged knacks that keep assets/img/pfight/ico-<tag>.png) have ico-pl-<key>
$pl = 0; $plbad = 0; $want = 0;
foreach (pf_data_lines('pf_pieces.txt') as $r) {
    if (count($r) < 10 || !in_array($r[2], ['basic', 'knack', 'calling', 'tool', 'crop', 'craft', 'region', 'legend'], true) || in_array($r[0], ['swing', 'dodge', 'rest', 'charm', 'snack', 'hide', 'jab', 'pierce', 'sting', 'trip', 'bash', 'smash', 'brace', 'roll', 'thornhide', 'mending', 'hum', 'lull', 'bond', 'pluck'], true)) continue;
    $want++; $ik = pf_player_icon_key($r[0]);
    if ($ik !== '' && is_file($dir . 'ico-' . $ik . '.png') && is_file($dir . 'ico-' . $ik . '-s.png')) $pl++; else { $plbad++; echo "  no icon: $r[0]\n"; }
}
chk('every other player piece has both icon files (112)', $plbad === 0 && $want === 112 && $pl === 112, [$want, $pl]);
chk('pf_make_tile carries ik for a player piece', (pf_make_tile('t:till', ['level' => 1])['ik'] ?? '') === 'pl-t-till');
chk('pf_make_tile: a knack with a tag icon keeps no ik', !isset(pf_make_tile('jab', ['level' => 1])['ik']));
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
