<?php
// Emits random boards with the cells the PHP engine says are legal for a tile, for tests/pfboard_js.js to compare with the legality in game/assets/pfboard.js.
require __DIR__ . '/../game/includes/pfboard.php';
mt_srand(11); $keys = array_keys(pf_tiles()); $cases = [];
$st = ['level' => 1];
for ($n = 0; $n < 400; $n++) {
    $s = pf_new(['hp' => 50, 'max_hp' => 50, 'stats' => $st, 'deck' => pf_player_deck($st), 'luck' => 0], ['slug' => 'x', 'size' => 'small', 'level' => 1, 'dmg_die' => 4, 'dmg_bonus' => 0], $n + 1);
    $s['strip'] = []; $s['pcs'] = []; $s['cell'] = []; $s['pid'] = 0; $s['seq'] = 0; $s['round'] = 1;
    $count = mt_rand(0, 9);
    for ($k = 0; $k < $count; $k++) {
        $t = pf_make_tile($keys[mt_rand(0, count($keys) - 1)], $st); $cells = pfb_cells($s, $t); if (!$cells) continue;
        [$x, $y] = $cells[mt_rand(0, count($cells) - 1)]; $id = ++$s['pid']; $s['seq']++;
        $s['pcs'][$id] = ['id' => $id, 'by' => ['me', 'foe'][mt_rand(0, 1)], 'tile' => $t, 'x' => $x, 'y' => $y, 'born' => 1, 'seq' => $s['seq']]; $s['cell']["$x,$y"] = $id;
    }
    $t = pf_make_tile($keys[mt_rand(0, count($keys) - 1)], $st);
    $cases[] = ['pcs' => array_values(array_map(fn($p) => ['x' => $p['x'], 'y' => $p['y'], 'e' => pfb_edges($p['tile'])], $s['pcs'])), 'e' => pfb_edges($t), 'legal' => pfb_cells($s, $t)];
}
echo json_encode(['w' => PFB_W, 'h' => PFB_H, 'cases' => $cases]);
