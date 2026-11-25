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
// 2.8.61 (owner: "im not seeing some pieces drawn, the newer stat pieces, when they are in my picked pieces"): every stat piece draws its own icon in every place it is drawn.
// The box and the pre-fight screen take ik from the entry; the fight takes it from the TILE (pfd_tiles) through pfb_view to the page data (pfight_game.php), then pfparts47.js draws it.
$stats = ['grit' => 0, 'nimble' => 5, 'hardiness' => 0, 'charm' => 0, 'lore' => 5, 'luck' => 5, 'sense' => 5, 'level' => 30];
$tiles = pfd_tiles(array_map(fn($k) => pfd_stat_entry(pfd_stat_pieces()[$k], 30) + ['key' => $k, 'rank' => 0, 'tool' => '', 'life' => 0], $keys), $stats);
foreach ($tiles as $i => $t) chk('tile_carries_icon_key_' . $keys[$i], ($t['ik'] ?? '') === $keys[$i] && ($t['st'] ?? '') === pfd_stat_pieces()[$keys[$i]]['stat'], ['ik' => $t['ik'] ?? null, 'st' => $t['st'] ?? null]);
foreach ($tiles as $i => $t) chk('tile_icon_file_exists_' . $keys[$i], is_file($img . 'pieces/ico-' . ($t['ik'] ?? '?') . '.png') && is_file($img . 'pieces/ico-' . ($t['ik'] ?? '?') . '-s.png'));
$deck = $tiles; foreach (range(1, 8) as $i) $deck[] = pf_make_tile(['swing', 'dodge', 'rest', 'charm'][$i % 4], ['level' => 10]) + ['src' => 'basic'];
$fs = pfb_new(['hp' => 40, 'max_hp' => 40, 'deck' => $deck, 'luck' => 0, 'lpts' => 5], ['slug' => 'tst', 'name' => 'Test', 'size' => 'medium', 'level' => 10, 'dmg_die' => 6, 'dmg_bonus' => 1], 3, ['v1' => true]);
$fs['me']['hand'] = $tiles;   // all 24 in the hand
$pc0 = null; foreach ($fs['pcs'] as $q) { $pc0 = $q; break; }
$fs['pcs'] = []; $fs['cell'] = [];   // and all 24 on the board (one cell each; the view only reads them)
foreach ($tiles as $i => $t) { $id = 900 + $i; $x = $i % 6; $y = intdiv($i, 6); $fs['pcs'][$id] = ['id' => $id, 'by' => 'me', 'x' => $x, 'y' => $y, 'tile' => $t, 'born' => (int)$fs['round'], 'seq' => $i] + ($pc0 ?? []); unset($fs['pcs'][$id]['f']); $fs['cell']["$x,$y"] = $id; }
$fv = pfb_view($fs);
foreach ($keys as $i => $k) chk('fight_view_hand_has_ik_and_st_' . $k, ($fv['hand'][$i]['ik'] ?? '') === $k && ($fv['hand'][$i]['st'] ?? '') !== '', $fv['hand'][$i] ?? null);
$byIk = []; foreach ($fv['pcs'] as $q) $byIk[$q['ik']] = $q;
foreach ($keys as $k) chk('fight_view_board_has_ik_and_st_' . $k, isset($byIk[$k]) && ($byIk[$k]['st'] ?? '') !== '', $byIk[$k] ?? null);
$pg = (string)file_get_contents(__DIR__ . '/../game/includes/pfight_game.php');
chk('fight_page_data_hand_keeps_st_and_ik', str_contains($pg, "'canflip' => \$t['canflip']] + array_intersect_key(\$t, ['st' => 1, 'ik' => 1])"));
chk('renderer_crisp_cache_keyed_by_icon_at_its_own_size', str_contains($js, "P.keyOf = function (o, z)") && str_contains($js, "P.cicoFor(z ? { ik: o.ik, size: z } : o)") && substr_count($js, "'c|' + size + '|' + P.keyOf(o, size)") === 2 && !str_contains($js, "'c|' + size + '|' + P.keyOf(o)]"));
chk('board_script_redraws_hand_icons_that_came_late', str_contains($bv, 'function cicoRedraw() { tiles.forEach(function (t, i) { if (data.hand[i] && data.hand[i].ik) redrawTile(i); }); render(); }'));
// 2.8.63 (owner: "Played pieces sometimes revert to default icons and then back"): the page data gives a held group's stat pieces their ik and st, and the icon keys of the draw pile (sorted) so they load before a piece is drawn
chk('fight_page_data_held_group_keeps_st_and_ik', str_contains($pg, "\$data['held']['pcs'][\$i] += ['st' => (string)(\$ht['st'] ?? ''), 'ik' => (string)(\$ht['ik'] ?? '')]"));
chk('fight_page_data_draw_pile_icons_sorted', str_contains($pg, "foreach (['draw', 'discard', 'hand'] as \$pile)") && str_contains($pg, "ksort(\$dik); \$data['dik'] = array_keys(\$dik);"));
echo $bad ? "pf_stat_art: $bad of $n FAILED\n" : "pf_stat_art: $n ok\n"; exit($bad ? 1 : 0);
