<?php
// throwaway: shared helpers copied from tests/pf_play.php (engine path via ENG env)
require (getenv('ENG') ?: __DIR__ . '/../../game/includes') . '/pfboard.php';
function pp_creatures(): array {
    $die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10]; $o = [];
    foreach (file(__DIR__ . '/../../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
        if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
        $lv = max(1, (int)$c[4]); $o[$c[0]] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
    }
    return $o;
}
function pp_player(int $lv): array {
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $cals = array_keys(PF_CALLING_TILE); $cal = $cals[$lv % 6]; $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0]; $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, $box), 'luck' => $m, 'calling' => $cal];
}
// self-hurt in MY chain for a single placement (dry run): sum dmg of foe hurt events
function selfhurt(array $ev): int { $d = 0; foreach ($ev as $e) if (($e['by'] ?? '') === 'foe' && ($e['t'] ?? '') === 'hurt' && isset($e['id'])) $d += (int)($e['dmg'] ?? 0) + (int)($e['reflect'] ?? 0); return $d; }
function legal_places(array $s): array { $o = []; foreach ($s['me']['hand'] as $i => $t) foreach (pfb_cells($s, $t, 'me') as [$x, $y]) $o[] = [$i, $x, $y]; return $o; }
function legal_joins(array $s): array { if (!empty($s['me']['held'])) return []; $o = []; $h = $s['me']['hand'];
    foreach ($h as $a => $_) foreach ($h as $b => $_2) if ($a !== $b) foreach (['L','R','T','B'] as $sd) { $w = $s; if (pfb_connect($w, 'me', $a, $b, $sd) === null) $o[] = [$a, $b, $sd]; } return $o; }
