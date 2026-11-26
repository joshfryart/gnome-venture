<?php
// 2.7.01 the approved Opus art (tools/install_art_2701.py) is in place and wired: every installed file at the path the code builds, the right size, art_path() finds it;
// the pal perch pictures (treehouse_pal_pic), the Flood Boots over the tunic in all three views (gnome25), the Trail fight / camp markers (trail_art.php), the 8 Maplewold stop looks (here_layouts.json).
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
ok('the install table has 389 rows (105 of the first install + step 2: 256 pal files, 19 wearable icons, 3 markers, 3 stop looks)', count($rows) === 389, (string)count($rows));
$bad = [];
foreach ($rows as $r) {
    [$src, $dst, $w, $h] = explode('|', $r);
    $s = $repo . '/aseprite-source/v3/' . $src;
    $g = $img . $dst;
    if (!is_file($g)) { $bad[] = "$dst missing"; continue; }
    $gs = getimagesize($g); $ss = getimagesize($s);
    $want = (int)$w ? [(int)$w, (int)$h] : [$ss[0], $ss[1]];
    if ([$gs[0], $gs[1]] !== $want) $bad[] = "$dst is {$gs[0]}x{$gs[1]}, want {$want[0]}x{$want[1]}";
    // 2026-11-21: a non-whimsy pal's yard picture (pals/<key>.png) is now the creature cut into a jigsaw piece; the approved bytes live on in aseprite-source/v3/pals-creature/
    $cre = (preg_match('~^pals/([a-z0-9-]+)\.png$~', $dst, $mm)) ? $repo . '/aseprite-source/v3/pals-creature/' . $mm[1] . '.png' : '';
    // 2026-11-26: the redrawn Puzzle Pals (art-review/redo, owner-approved swap) replace every pals/perch sprite, so those bytes are no longer the 2.7.01 ones; size and art_path() are still checked
    if (!(int)$w && strpos($dst, 'pals/perch/') !== 0 && md5_file($cre !== '' && is_file($cre) ? $cre : $g) !== md5_file($s)) $bad[] = "$dst is not the approved file $src";
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
ok('all 570 pals have a perch picture (142 hand-drawn art-2701, 356 block-pal generator, 72 whimsy downscaled), each with a yard picture too', count(glob($img . 'pals/perch/*.png')) === 570 && !array_filter(glob($img . 'pals/perch/*.png'), fn($f) => !is_file($img . 'pals/' . basename($f))), (string)count(glob($img . 'pals/perch/*.png')));

echo "== pals: the 128 of art-2701-pals-all (step 2), by the key the game looks up\n";
$wl = json_decode((string)file_get_contents($repo . '/aseprite-source/v3/art-2701-pals-all/worklist.json'), true);
$byKey = [];
foreach (file($argv[1] . '/includes/data/puzzle_pals.txt', FILE_IGNORE_NEW_LINES) as $l) { if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); $byKey[$c[1]] = $c; }
$miss = [];
$n = 0;
for ($c = 0; $c < 16; $c++) foreach ($wl[$c] as $p) {
    $n++;
    $row = $byKey[$p['key']] ?? null;
    if (!$row || $row[0] !== $p['pic'] || $row[2] !== $p['name']) { $miss[] = $p['key'] . ' is not pic|key|name ' . $p['pic'] . '|' . $p['name'] . ' in puzzle_pals.txt'; continue; }
    $y = treehouse_pal_pic(['key' => $p['key']]); $q = treehouse_pal_pic(['key' => $p['key']], true);
    if (!str_contains((string)($y['src'] ?? ''), 'assets/img/pals/' . $p['key'] . '.png') || !str_contains((string)($q['src'] ?? ''), 'assets/img/pals/perch/' . $p['key'] . '.png')) $miss[] = $p['key'] . ' ' . json_encode([$y, $q]);
    elseif (md5_file(is_file($repo . '/aseprite-source/v3/pals-creature/' . $p['key'] . '.png') ? $repo . '/aseprite-source/v3/pals-creature/' . $p['key'] . '.png' : $img . 'pals/' . $p['key'] . '.png') !== md5_file(sprintf('%s/aseprite-source/v3/art-2701-pals-all/c%02d/opus3/%s-yard.png', $repo, $c, $p['key']))) $miss[] = $p['key'] . ' yard is not the opus3 file';
    elseif (art_path('assets/img/pals/perch/' . $p['key'] . '.png') === '' || art_path('assets/img/pals/' . $p['key'] . '.png') === '') $miss[] = $p['key'] . ' not found by art_path()';
}
ok('128 pals: in puzzle_pals.txt under the same picture and name, yard (64) and perch (36) picked by treehouse_pal_pic(), the opus3 bytes, art_path() finds both', $n === 128 && !$miss, $n . ' ' . implode('; ', array_slice($miss, 0, 4)));
foreach (['pl-frt-1', 'ss-palm-fidget', 'pl-bjq-4'] as $k) { $a = @getimagesize($img . 'pals/' . $k . '.png'); $b = @getimagesize($img . 'pals/perch/' . $k . '.png'); ok("$k: yard 64x64, perch 36x36", $a && $a[0] === 64 && $a[1] === 64 && $b && $b[0] === 36 && $b[1] === 36); }

echo "== gnome: Flood Boots over the tunic (front, back, side)\n";
ok('front wboots is drawn after the tunic', GNOME25_WEAR_AFTER['front']['wboots'] === 'tunic');
ok('back and side wboots are drawn after the tunic too (their strips have the rim at row 60 now)', GNOME25_WEAR_AFTER['back']['wboots'] === 'tunic' && GNOME25_WEAR_AFTER['side']['wboots'] === 'tunic');
foreach (['back', 'side'] as $v) {   // the same check as the front below: the shafts show over the tunic legs, the head is untouched
    $pl = imagecreatefromstring(gnome25_compose($v, [])); $bo = imagecreatefromstring(gnome25_compose($v, [], [], 'b')); $ly = imagecreatefrompng($img . "gnome25/$v-wboots.png");
    $sh = 0; $same = true;
    for ($x = 0; $x < 512; $x++) { for ($y = 58; $y <= 63; $y++) { $l = imagecolorat($ly, $x, $y); if ((($l >> 24) & 127) === 0 && (imagecolorat($bo, $x, $y) & 0xFFFFFF) === ($l & 0xFFFFFF) && (((imagecolorat($pl, $x, $y) >> 24) & 127) === 0)) $sh++; }
        for ($y = 0; $y <= 50; $y++) if (imagecolorat($pl, $x, $y) !== imagecolorat($bo, $x, $y)) $same = false; }
    ok("$v: the boot shafts show over the tunic legs (rows 58-63, all 8 frames: back 882 px, side 401; the old rimless strips gave 691 and 333)", $sh > ($v === 'back' ? 800 : 370), "$sh px");
    ok("$v: the boots do not paint over the face or hat (rows 0-50 unchanged)", $same);
}
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
ok('step 2: the rest stop and the side path markers can be asked for by name', trail_mark_file('', 'rest') === 'rest' && trail_mark_file('', 'signpost') === 'signpost');
ok('step 2: the hazard marker is installed and can be asked for by name (2.7.06; no Trail data names one yet)', is_file($img . 'trail/mark/hazard.png') && trail_mark_file('', 'hazard') === 'hazard');
ok('a rest stop (village) is a place the last stretch shows on its way on', (TRAIL_DEST_MARKS['village'] ?? '') !== '' && trail_dest_mark_name('village') === 'rest' && trail_dest_mark_name('lair') === 'lair');

echo "== stop looks (Maplewold)\n";
$all = here_layouts_shipped();
foreach (['market', 'mill', 'shrine', 'jetty', 'herb', 'workshop', 'orchard', 'tower', 'camp', 'inn', 'ferry', 'spring'] as $t) {
    $f = here_layout_find($all, 'stop', 'grassland', 'some-stop', ['type' => $t, 'style' => 'maplewold']);
    $key = 'stop-' . $t . '-grassland_maplewold';
    $file = $img . 'scenes/' . here_layout_file($key);
    $sz = @getimagesize($file);
    ok("$t: layout $key, picture 480x270, lint clean", $f && $f[0] === $key && $sz && $sz[0] === 480 && $sz[1] === 270 && !here_lint_layout($f[1]), json_encode([$f[0] ?? null, $sz ? [$sz[0], $sz[1]] : null, $f ? here_lint_layout($f[1]) : null]));
}
foreach (['inn', 'ferry', 'spring'] as $t) {   // step 2: drawn now (batch4); each layout has the five spots of a stop and six stand slots, on the picture
    $L = $all['stop-' . $t . '-grassland_maplewold'] ?? null;
    $ks = $L ? array_column($L['spots'], 'k') : [];
    sort($ks);
    ok("$t: the Maplewold layout has do / homes / people / stop / wild with boxes, and 6 stand slots", $L && $ks === ['do', 'homes', 'people', 'stop', 'wild'] && count(array_filter($L['spots'], fn($s) => isset($s['box']))) === 5 && count($L['stand']) === 6, json_encode($ks));
    ok("$t: it is not the plain look's layout (spots placed on the new picture)", $L && $L['spots'] !== ($all['stop-' . $t]['spots'] ?? null));
}
$f = here_layout_find($all, 'stop', 'savanna', 'some-stop', ['type' => 'mill', 'style' => 'maplewold']);   // a landscape with no look of its own (forest, mountain, coast ... have one each since the 84 stop looks)
ok('a Maplewold mill in a landscape with no look: its stop-mill picture', $f && $f[0] === 'stop-mill');
$f = here_layout_find($all, 'stop', 'forest', 'some-stop', ['type' => 'mill', 'style' => 'maplewold']);
ok('a Maplewold mill in the forest: the forest look of the mill', $f && $f[0] === 'stop-mill-forest_pinewood', $f[0] ?? '');

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
