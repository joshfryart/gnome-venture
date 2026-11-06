<?php
// Welcome village cards (2.5.49): every village in the data has either a readable 160x100 PNG at assets/img/villages/<slug>.png or the landscape emoji fallback
// (known landscape with a .vfall.ls-<landscape> colour rule), and its welcome basket renders without a PHP warning. Usage: php tests/welcome_villages.php GAMEDIR
$_SERVER['SCRIPT_NAME'] = '/welcome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/onboard.php';
require_once $argv[1] . '/includes/adventure_data.php';
$fails = 0; $warn = [];
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_error_handler(function ($no, $str, $file, $line) use (&$warn) { $warn[] = $str . ' @ ' . basename($file) . ':' . $line; return true; });
$css = file_get_contents($argv[1] . '/assets/style.css');
$rows = q("SELECT l.id, l.name, z.landscape FROM locations l LEFT JOIN zones z ON z.id = l.zone_id WHERE l.kind = 'village' ORDER BY l.id")->fetchAll();
echo "== " . count($rows) . " villages\n";
ok('there are villages to walk', count($rows) > 20, (string)count($rows));
$withArt = 0; $bad = []; $badLand = []; $badCss = [];
foreach ($rows as $v) {
    $art = village_card_art((string)$v['name']);
    if ($art !== '') {
        $withArt++;
        $info = @getimagesize($argv[1] . '/' . $art);
        if (!$info || $info[2] !== IMAGETYPE_PNG || $info[0] !== 160 || $info[1] !== 100) $bad[] = $v['name'] . ' (' . $art . ')';
    } else {
        $land = (string)($v['landscape'] ?? '');
        $L = LANDSCAPES[$land] ?? ['📍'];   // the page's own fallback for an unknown landscape
        if ($L[0] === '') $badLand[] = $v['name'];
        $cls = preg_replace('/[^a-z]/', '', $land);
        if ($land !== '' && !isset(LANDSCAPES[$land])) $badLand[] = $v['name'] . ' (' . $land . ')';
        if (isset(LANDSCAPES[$land]) && !str_contains($css, '.vfall.ls-' . $cls)) $badCss[$cls] = 1;
    }
    $pack = village_welcome_pack((int)$v['id']);
    $html = pack_slots($pack, true);
    if (!is_array($pack) || $html === '' && $pack) $bad[] = $v['name'] . ' (basket)';
}
ok('every picture that exists is a 160x100 PNG', !$bad, implode('; ', $bad));
ok('every village without a picture has a known landscape with an emoji', !$badLand, implode('; ', $badLand));
ok('every such landscape has a card colour rule (.vfall.ls-*)', !$badCss, implode(',', array_keys($badCss)));
ok(($withArt) . ' villages have art, ' . (count($rows) - $withArt) . ' use the fallback', $withArt >= 2);
ok('odd names never throw or warn: empty, symbols, long', village_card_art('') === '' && village_card_art('???') === '' && village_card_art(str_repeat('x', 400)) === '' && village_card_art('../../etc/passwd') === '');
ok('Poppyburrow and Honeybrook keep their pictures', village_card_art('Poppyburrow') !== '' && village_card_art('Honeybrook') !== '');
ok('no PHP warning or notice while walking', !$warn, implode(' | ', array_slice($warn, 0, 5)));
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
