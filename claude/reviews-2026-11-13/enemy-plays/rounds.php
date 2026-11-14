<?php
// Plays seeded v1 fights (blank start, the live rules) with a greedy player bot and lists, per creature round, what put pieces on the board and why.
// usage: php claude/reviews-2026-11-13/enemy-plays/rounds.php [N] [verbose 0|1]   (rounds-40-fights.txt = N 40)
// (evaluates the harness's own helper functions: our repo file, not outside input)
$R = realpath(__DIR__ . '/../../..') . '/';
$src = file_get_contents($R . 'tests/pf_play.php');
$src = substr($src, 0, strpos($src, '[, $cmd, $f] = $argv'));
$src = str_replace("__DIR__ . '/../", "'$R", $src);
eval('?>' . $src);
$N = (int)($argv[1] ?? 16); $V = (int)($argv[2] ?? 1);
$all = pp_creatures(); $bySize = [];
foreach ($all as $c) $bySize[$c['size']][] = $c;
$keys = array_keys(pfd_region_pieces());
$T = ['rounds' => 0, 'aim_as_shown' => 0, 'repick' => 0, 'quick' => 0, 'quick_piece_not_aim' => 0, 'slow' => 0, 'foe_fires_mine' => 0, 'foe_fires_env' => 0, 'foe_fires_env_named' => 0, 'foe_fires_own_old' => 0,
  'foe_fires_spawn' => 0, 'spawn' => 0, 'env_place' => 0, 'env_pass' => 0, 'env_pass_full' => 0, 'rounds_env_pass' => 0, 'rounds_spawn' => 0, 'rounds_foe_free_env' => 0, 'rounds_foe_fires_spawn' => 0, 'aim_fires_spawn_shown' => 0];
$perFight = [];
for ($f = 0; $f < $N; $f++) {
    $size = ['small', 'medium', 'large', 'boss'][$f % 4]; $list = $bySize[$size]; $c = $list[($f * 7) % count($list)]; $seed = 1000 + $f * 13;
    $lv = max(1, min(30, $c['level']));
    $cr = pfd_foe_row($c, $keys[(crc32($c['slug']) + $seed) % 14]) + ['region' => ''];
    $s = pfb_new(pp_player($lv), $cr, $seed, ['blank' => true, 'v1' => true]);
    // the hidden start: first hand piece, first side it takes
    foreach (['L', 'R', 'T', 'B'] as $sd) { $w = $s; if (pfb_start($w, 0, $sd) === null) { $s = $w; break; } }
    $F = ['fight' => "$f {$c['slug']} ($size L$lv) seed $seed", 'rounds' => 0, 'repick' => 0, 'quick' => 0, 'free_env' => 0, 'fires_mine' => 0, 'spawn' => 0, 'fires_spawn' => 0, 'env_pass' => 0];
    if ($V) echo "\n=== FIGHT {$F['fight']} board {$s['w']}x{$s['h']}\n";
    $spawnAll = []; $spawnId = null; // the piece the board put out for the creature at the end of last round
    // the opening: what the creature has out (start pieces)
    while (!$s['over'] && $s['turn'] <= PF_TURN_CAP) {
        $plan = $s['foe']['plan'] ?? null; $before = $s['pcs']; $why = $plan['tot']['why'] ?? [];
        $m = pfb_search($s, 'me');
        $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
        if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) break; }
        $ev = $r['ev']; $foe = array_values(array_filter($ev, fn($e) => ($e['ta'] ?? '') === 'foe'));
        if (!$foe && $s['over']) break;
        $T['rounds']++; $F['rounds']++;
        $lines = []; $roots = 0; $quick = false; $slow = false; $freeEnv = 0; $firesSpawn = false; $mine = 0;
        foreach ($foe as $e) {
            if (($e['note'] ?? '') === 'quick') { $quick = true; $lines[] = "  QUICK note ({$e['n']}): one more piece"; continue; }
            if (($e['note'] ?? '') === 'slow') { $slow = true; $lines[] = '  SLOW: it loses its turn'; continue; }
            if (!isset($e['id'])) { $lines[] = '  ' . ($e['k'] ?? '?') . ' ' . ($e['n'] ?? ''); continue; }
            $wasThere = isset($before[$e['id']]);
            if ($e['by'] === 'foe' && !empty($e['root'])) { $roots++; $lines[] = '  PLACES ' . $e['n'] . " {$e['t']} {$e['v']} (#{$e['id']})" . ($roots === 1 ? (!$plan ? ' = PLAYED WITH NO AIM SHOWN' : ($s['reaim'] ? ' = RE-PICK (not the shown aim ' . ($plan['n'] ?? '-') . ')' : ' = the shown aim')) : ' = QUICK EXTRA (never shown)'); }
            elseif ($e['by'] === 'env') { $freeEnv++; $nm = in_array('fires ' . $e['n'], $why, true) || ($e['kind'] === 'sun' && preg_grep('/^Sun x/', $why)); $lines[] = "  chain fires ENV {$e['n']} #{$e['id']} for creature (" . ($e['kind'] === 'rain' ? '+' . ($e['guard'] ?? 0) . ' guard' : ($e['kind'] === 'sun' ? 'x2' : 'you -' . ($e['me'] ?? 0))) . ')' . ($wasThere ? ', on board before your move' : ', NEW') . ($nm ? ', named in aim reasons' : ', NOT in aim reasons'); if ($nm) $T['foe_fires_env_named']++; else { $T['env_unnamed_' . ($s['reaim'] && $roots <= 1 ? 'repick' : ($roots > 1 ? 'quick' : 'other'))] = ($T['env_unnamed_' . ($s['reaim'] && $roots <= 1 ? 'repick' : ($roots > 1 ? 'quick' : 'other'))] ?? 0) + 1; } }
            elseif ($e['by'] === 'me') { $mine++; $lines[] = "  chain fires YOUR {$e['n']} #{$e['id']} (works for you)"; }
            elseif ($e['by'] === 'foe') { $sp = isset($spawnAll[$e['id']]); if ($sp) $firesSpawn = true; $lines[] = "  chain fires its own {$e['n']} {$e['t']} {$e['v']} #{$e['id']}" . ($sp ? ' = A PIECE THE BOARD PUT OUT FOR IT (spawn)' : ''); $T['foe_fires_own_old']++; }
            elseif ($e['by'] === 'none') $lines[] = '  (blank)';
        }
        if (!$plan && $roots) $T['noaim_but_played'] = ($T['noaim_but_played'] ?? 0) + 1;
        if ($plan && !$roots && !$slow) $T['aim_shown_nothing_played'] = ($T['aim_shown_nothing_played'] ?? 0) + 1;
        if ($quick) { $T['quick']++; $F['quick']++; }
        if ($slow) $T['slow']++;
        if ($s['reaim']) { $T['repick']++; $F['repick']++; } elseif ($roots) $T['aim_as_shown']++;
        if ($freeEnv) { $T['foe_fires_env'] += $freeEnv; $T['rounds_foe_free_env']++; $F['free_env']++; }
        if ($mine) { $T['foe_fires_mine'] += $mine; $F['fires_mine']++; }
        if ($firesSpawn) { $T['foe_fires_spawn']++; $T['rounds_foe_fires_spawn']++; $F['fires_spawn']++; if (in_array($spawnId, [], true)) {} }
        $pl = 0; $pa = 0; foreach ($s['envlog'] ?? [] as $L) { if ($L['k'] === 'place') $pl++; if ($L['k'] === 'pass') { $pa++; if (!empty($L['full'])) $T['env_pass_full']++; } }
        $T['env_place'] += $pl; $T['env_pass'] += $pa; if ($pa) { $T['rounds_env_pass']++; $F['env_pass']++; }
        $spawnId = $s['spawn'] ?? null;
        if ($spawnId) { $spawnAll[$spawnId] = 1; $T['spawn']++; $T['rounds_spawn']++; $F['spawn']++; $sp = $s['pcs'][$spawnId]; $lines[] = "  END OF ROUND: board PUTS OUT {$sp['tile']['n']} {$sp['tile']['t']} {$sp['tile']['v']} (#$spawnId) for the creature at {$sp['x']},{$sp['y']} (spawn, no caption)"; }
        $np = $s['foe']['plan'] ?? null;
        if ($spawnId && $np && isset($np['tot']['n']) && $np['tot']['n'] > 1) { $T['aim_fires_spawn_shown']++; }
        if ($V) echo "R" . ($s['round'] - 1) . " aim shown: " . ($plan ? "{$plan['n']} at {$plan['x']},{$plan['y']} why[" . implode('; ', $why) . "]" : 'none') . " | env places $pl, passes $pa\n" . implode("\n", $lines) . "\n";
    }
    $F['over'] = $s['over']; $perFight[] = $F;
}
echo "\nPER FIGHT\n"; foreach ($perFight as $F) echo json_encode($F) . "\n";
echo "\nTOTALS\n" . json_encode($T, JSON_PRETTY_PRINT) . "\n";
