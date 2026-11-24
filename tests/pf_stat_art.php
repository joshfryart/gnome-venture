<?php
// Stat pieces, art wiring: every file the renderer (assets/pfparts47.js) and the board script name exists with the documented size; the 24 icons have both sizes; stat tiles carry their icon key (ik) and stat (st). No DB.
// php tests/pf_stat_art.php
$GLOBALS['TEST_SETTINGS'] = [];
if (!function_exists('setting')) { function setting(string $k): string { return (string)($GLOBALS['TEST_SETTINGS'][$k] ?? ''); } }
if (!function_exists('e')) { function e($s): string { return htmlspecialchars((string)$s, ENT_QUOTES); } }
if (!function_exists('csrf_field')) { function csrf_field(): string { return ''; } }
if (!function_exists('url')) { function url(string $p = ''): string { return '/' . $p; } }
require __DIR__ . '/../game/includes/pfdeck_view.php';
$bad = 0; $n = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad, $n; $n++; if (!$ok) { $bad++; echo 'FAIL ' . $name . ' (got ' . (is_string($got) ? $got : json_encode($got)) . ")\n"; } }
$img = __DIR__ . '/../game/assets/img/pfight/';
$js = (string)file_get_contents(__DIR__ . '/../game/assets/pfparts47.js');
$bv = (string)file_get_contents(__DIR__ . '/../game/assets/pfboardv1.js');
// the kit files, sizes from stat/README.md
$kit = ['badges-stat' => [[44, 11], [72, 18]], 'socks-any' => [[164, 73], [280, 124]], 'envtile-spring' => [[82, 73], [140, 124]], 'envglyph-spring' => [[82, 73], [140, 124]], 'snare' => [[56, 47], [96, 80]], 'stolen' => [[14, 14], [24, 24]]];
foreach ($kit as $name => $sz) foreach (['strip', 'hand'] as $i => $z) {
    $f = $img . 'stat/' . $name . '-' . $z . '.png'; $g = is_file($f) ? getimagesize($f) : false;
    chk('kit_file_' . $name . '_' . $z, $g && $g[0] === $sz[$i][0] && $g[1] === $sz[$i][1], $g ? $g[0] . 'x' . $g[1] : 'missing');
    chk('renderer_names_' . $name, str_contains($js, "'" . $name . "'"));
}
// the 24 icons, both sizes, one per piece of the table
$keys = array_keys(pfd_stat_pieces()); chk('24_stat_pieces', count($keys) === 24, count($keys));
foreach ($keys as $k) {
    $a = $img . 'pieces/ico-' . $k . '.png'; $b = $img . 'pieces/ico-' . $k . '-s.png';
    $ga = is_file($a) ? getimagesize($a) : false; $gb = is_file($b) ? getimagesize($b) : false;
    chk('icon32_' . $k, $ga && $ga[0] === 32 && $ga[1] === 32); chk('icon20_' . $k, $gb && $gb[0] === 20 && $gb[1] === 20);
}
// a stat entry carries the icon key and the stat; the tiles take them
$u = ['id' => 1, 'role' => 'admin', 'level' => 10, 'stat_nimble' => 15, 'stat_lore' => 20, 'stat_luck' => 30, 'stat_sense' => 10];
$e = pfd_stat_entry(pfd_stat_pieces()['stat-skitter'], 15);
chk('entry_has_ik_and_st', ($e['ik'] ?? '') === 'stat-skitter' && ($e['st'] ?? '') === 'nimble', $e);
chk('board_script_passes_st_and_ws', str_contains($bv, 'st: p.st, ws: p.ws') && str_contains($bv, 'ik: data.hand[i].ik'));
chk('board_script_snare_art', str_contains($bv, "stat/snare-strip.png"));
chk('renderer_picoBase_fallback', str_contains($js, "P.picoBase = P.picoBase ||"));
echo $bad ? "pf_stat_art: $bad of $n FAILED\n" : "pf_stat_art: $n ok\n"; exit($bad ? 1 : 0);
