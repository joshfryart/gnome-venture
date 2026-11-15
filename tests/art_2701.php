<?php
// 2.7.01 the approved Opus art (tools/install_art_2701.py) is in place and wired: every installed file at the path the code builds, the right size, art_path() finds it;
// the pal perch pictures (treehouse_pal_pic), the front Flood Boots over the tunic (gnome25), the Trail fight / camp markers (trail_art.php), the 8 Maplewold stop looks (here_layouts.json).
// php tests/art_2701.php GAME_DIR REPO_DIR   (an installed game; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/items.php';
require_once $argv[1] . '/includes/hub_pages.php';
require_once $argv[1] . '/includes/gnome25.php';
require_once $argv[1] . '/includes/trail_art.php';
require_once $argv[1] . '/includes/here_layout.php';
require_once $argv[1] . '/includes/pfight_game.php';
$repo = $argv[2];
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$img = $argv[1] . '/assets/img/';

echo "== every installed file (tools/install_art_2701.py --list)\n";
$rows = array_filter(explode("\n", trim((string)shell_exec('python3 ' . escapeshellarg($repo . '/tools/install_art_2701.py') . ' --list'))));
ok('the install table has 105 rows', count($rows) === 105, (string)count($rows));
$bad = [];
foreach ($rows as $r) {
    [$src, $dst, $w, $h] = explode('|', $r);
    $s = $repo . '/aseprite-source/v3/' . $src;
    $g = $img . $dst;
    if (!is_file($g)) { $bad[] = "$dst missing"; continue; }
    $gs = getimagesize($g); $ss = getimagesize($s);
    $want = (int)$w ? [(int)$w, (int)$h] : [$ss[0], $ss[1]];
    if ([$gs[0], $gs[1]] !== $want) $bad[] = "$dst is {$gs[0]}x{$gs[1]}, want {$want[0]}x{$want[1]}";
    if (!(int)$w && md5_file($g) !== md5_file($s)) $bad[] = "$dst is not the approved file $src";
    if (art_path('assets/img/' . $dst) === '') $bad[] = "art_path() does not find assets/img/$dst";
}
ok('every file is at its game path, the size of what it replaces, the approved bytes, and art_path() finds it', !$bad, implode('; ', array_slice($bad, 0, 6)));
$sizes = ['ph/travel-cloak.png' => 64, 'ph/flood-boots-fine.png' => 64, 'pals/mw-acorn-nip.png' => 64, 'pals/perch/mw-acorn-nip.png' => 36, 'trail/mark/fight.png' => 32, 'pfight/ico-mending.png' => 32, 'pfight/ico-thornhide-s.png' => 20];
foreach ($sizes as $f => $px) { $sz = @getimagesize($img . $f); ok("$f is {$px}x{$px}", $sz && $sz[0] === $px && $sz[1] === $px); }

echo "== tag icons: every PF_TAG_ICON name has its 32 px and 20 px icon\n";
foreach (array_unique(PF_TAG_ICON) as $n) ok("ico-$n", (@getimagesize($img . "pfight/ico-$n.png")[0] ?? 0) === 32 && (@getimagesize($img . "pfight/ico-$n-s.png")[0] ?? 0) === 20);

echo "== pals: perch pictures on the treehouse perches\n";
$p = treehouse_pal_pic(['key' => 'mw-acorn-nip'], true);
ok('a pal with a perch picture: the perch (36 px) file', str_contains((string)($p['src'] ?? ''), 'assets/img/pals/perch/mw-acorn-nip.png'), json_encode($p));
$p = treehouse_pal_pic(['key' => 'mw-acorn-nip']);
ok('the same pal in the yard: the 64 px yard picture', str_contains((string)($p['src'] ?? ''), 'assets/img/pals/mw-acorn-nip.png'), json_encode($p));
$other = null;
foreach (glob($img . 'pals/*.png') as $f) { $k = basename($f, '.png'); if (!is_file($img . 'pals/perch/' . $k . '.png')) { $other = $k; break; } }
$p = $other ? treehouse_pal_pic(['key' => $other], true) : [];
ok('a pal with no perch picture keeps its yard picture on a perch (' . $other . ')', $other && str_contains((string)($p['src'] ?? ''), 'assets/img/pals/' . $other . '.png'), json_encode($p));
ok('14 pals have a perch picture, each with a yard picture too', count(glob($img . 'pals/perch/*.png')) === 14 && !array_filter(glob($img . 'pals/perch/*.png'), fn($f) => !is_file($img . 'pals/' . basename($f))));

echo "== gnome: front Flood Boots over the tunic\n";
ok('front wboots is drawn after the tunic', GNOME25_WEAR_AFTER['front']['wboots'] === 'tunic');
ok('back and side wboots stay after the boots (their strips have no rim yet)', GNOME25_WEAR_AFTER['back']['wboots'] === 'boots' && GNOME25_WEAR_AFTER['side']['wboots'] === 'boots');
$plain = imagecreatefromstring(gnome25_compose('front', []));
$boots = imagecreatefromstring(gnome25_compose('front', [], [], 'b'));
$layer = imagecreatefrompng($img . 'gnome25/front-wboots.png');
$tall = 0; $hem = 0;
for ($x = 0; $x < 512; $x++) for ($y = 58; $y <= 63; $y++) {
    $l = imagecolorat($layer, $x, $y);
    if ((($l >> 24) & 127) !== 0) continue;
    if ((imagecolorat($boots, $x, $y) & 0xFFFFFF) === ($l & 0xFFFFFF)) $tall++;
    if ((((imagecolorat($plain, $x, $y) >> 24) & 127) === 0)) $hem++;
}
ok('the boot shafts show over the tunic legs (rows 58-63, all 8 frames: about 680 px; drawn under the tunic it was 122)', $tall > 400, "$tall px");
ok('...where the plain gnome has its tunic', $hem > 150, "$hem px");
ok('the boots do not paint over the face or hat (rows 0-50 unchanged)', (function () use ($plain, $boots) { for ($x = 0; $x < 512; $x++) for ($y = 0; $y <= 50; $y++) if (imagecolorat($plain, $x, $y) !== imagecolorat($boots, $x, $y)) return false; return true; })());
ok('the cache name carries the art revision', defined('GNOME25_ART_REV') && str_contains((string)file_get_contents($argv[1] . '/gnome_sprite.php'), 'GNOME25_ART_REV'));

echo "== Trail markers\n";
ok('the fight token draws mark/fight.png', trail_mark_file('⚔️') === 'fight');
ok('the camp token draws mark/camp.png', trail_mark_file('🏕️') === 'camp');
ok('the way on keeps its emoji tile (no marker drawn)', trail_mark_file('🚪') === '' && trail_mark_file('✨') === '');

echo "== stop looks (Maplewold)\n";
$all = here_layouts_shipped();
foreach (['market', 'mill', 'shrine', 'jetty', 'herb', 'workshop', 'orchard', 'tower', 'camp'] as $t) {
    $f = here_layout_find($all, 'stop', 'grassland', 'some-stop', ['type' => $t, 'style' => 'maplewold']);
    $key = 'stop-' . $t . '-grassland_maplewold';
    $file = $img . 'scenes/' . here_layout_file($key);
    $sz = @getimagesize($file);
    ok("$t: layout $key, picture 480x270, lint clean", $f && $f[0] === $key && $sz && $sz[0] === 480 && $sz[1] === 270 && !here_lint_layout($f[1]), json_encode([$f[0] ?? null, $sz ? [$sz[0], $sz[1]] : null, $f ? here_lint_layout($f[1]) : null]));
}
foreach (['inn', 'ferry', 'spring'] as $t) {
    $f = here_layout_find($all, 'stop', 'grassland', 'some-stop', ['type' => $t, 'style' => 'maplewold']);
    ok("$t (no Maplewold look): falls back to stop-$t", $f && $f[0] === 'stop-' . $t);
}
$f = here_layout_find($all, 'stop', 'forest', 'some-stop', ['type' => 'mill', 'style' => 'maplewold']);
ok('a Maplewold mill in another landscape: its stop-mill picture', $f && $f[0] === 'stop-mill');

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
