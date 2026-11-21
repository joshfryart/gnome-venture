<?php
// 2.7.44: a creature's own 3 pieces carry 'ik', the key of their hand-drawn icon in game/assets/img/pfight/pieces/ (ico-<ik>.png 32px, ico-<ik>-s.png 20px).
// php tests/pf_piece_icons.php   (no database: reads data/pf_creature_pieces.txt and the icon folder)
require __DIR__ . '/../game/includes/pfboard.php'; require __DIR__ . '/../game/includes/pfight_game.php'; require __DIR__ . '/../game/includes/pfdeck.php';
$bad = 0;
function chk(string $n, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $n . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
$dir = __DIR__ . '/../game/assets/img/pfight/pieces/';
$files = array_map('basename', glob($dir . 'ico-*.png'));
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
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
