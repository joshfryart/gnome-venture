<?php
// php run.php BOT MODE N OFFS(comma) [startpolicy]   env switches go to the patched engine
require __DIR__ . '/common.php';
[, $bot, $mode, $N, $offs] = $argv + [null, 'greedy', 'classic', 3, '0,-8']; $N = (int)$N; $sp = $argv[5] ?? 'besthurt';
$offs = array_map('intval', explode(',', $offs));
function rnd_pick(array $a) { return $a[mt_rand(0, count($a) - 1)]; }
function act(array &$s, array $a) { if ($a[0] === 'pass') { $GLOBALS['BRACE_IDX'] = $a[1] ?? 0; return pfb_pass($s, $s['turn']); } return pfb_play($s, [$a], $s['turn']); }
function actions(array $s, bool $joins): array {
    $o = []; foreach (legal_places($s) as $p) $o[] = $p;
    if (!empty($s['me']['held'])) foreach (pfb_group_spots($s, $s['me']['held']) as [$x, $y]) $o[] = ['c', $x, $y];
    if (getenv('PASS')) { if (getenv('PASS') === 'brace') foreach ($s['me']['hand'] as $i => $_) $o[] = ['pass', $i]; else $o[] = ['pass']; }
    elseif (!$o) $o[] = ['pass'];
    if ($joins) foreach (legal_joins($s) as [$a, $b, $sd]) $o[] = ['j', $a, $b, $sd];
    return $o;
}
function look(array $s, bool $joins): array {   // full-turn lookahead (includes the creature's reply)
    $best = null; $bs = -1e9;
    foreach (actions($s, $joins) as $a) { $w = $s; $r = act($w, $a); if ($r['err']) continue; $sc = pfb_score($s, $w, 'me'); if ($sc > $bs + 1e-9) { $bs = $sc; $best = $a; } }
    return $best ?? ['pass'];
}
function dry(array $s, array $a): array { $w = $s; $w['reshuf'] = []; $w['cut'] = 0; $ev = $a[0] === 'c' ? pfb_place_group($w, 'me', $a[1], $a[2]) : pfb_place($w, 'me', $a[0], $a[1], $a[2]); return [$w, $ev ?? []]; }
function selfh(array $s, array $p): int { $w = $s; $r = pfb_play($w, [$p], $s['turn'], null, true); return selfhurt($r['ev']); }
function choose(array $s, string $bot): array {
    if ($bot === 'greedy') { $m = pfb_search($s, 'me'); return $m ? [$m[0], $m[1], $m[2]] : ['pass']; }
    if ($bot === 'noisy') { if (mt_rand(0, 99) < 35) { $l = legal_places($s); if ($l) return rnd_pick($l); } $m = pfb_search($s, 'me'); return $m ? [$m[0], $m[1], $m[2]] : ['pass']; }
    if ($bot === 'random') { $a = actions($s, false); $l = array_values(array_filter($a, fn($x) => $x[0] !== 'pass')); if (getenv('PASS') && mt_rand(0, 9) === 0) return ['pass', 0]; return $l ? rnd_pick($l) : ['pass']; }
    if ($bot === 'look') return look($s, false);
    if ($bot === 'lookj') return look($s, true);
    if ($bot === 'careful' || $bot === 'carefulj') {   // avoid '!' cells; greedy among safe ones (the round-2 "careful" agent)
        $best = null; $bs = -1e9; $minA = null; $minH = 1e9; $minS = -1e9;
        foreach (legal_places($s) as $p) { [$w, $ev] = dry($s, $p); $h = selfhurt($ev); $sc = pfb_score($s, $w, 'me');
            if ($h === 0 && $sc > $bs) { $bs = $sc; $best = $p; } if ($h < $minH || ($h === $minH && $sc > $minS)) { $minH = $h; $minA = $p; $minS = $sc; } }
        if ($best) return $best;
        if (getenv('PASS') === 'brace') { $bi = 0; foreach ($s['me']['hand'] as $i => $t) if ($t['t'] === 'guard' || $t['v'] > $s['me']['hand'][$bi]['v']) $bi = $i; return ['pass', $bi]; }
        if (getenv('PASS')) return ['pass'];
        if ($bot === 'carefulj') { $j = legal_joins($s); if ($j && empty($s['me']['held'])) { $a = $j[0]; return ['j', $a[0], $a[1], $a[2]]; } if (!empty($s['me']['held'])) { $g = pfb_group_spots($s, $s['me']['held']); foreach ($g as [$x, $y]) { [$w, $ev] = dry($s, ['c', $x, $y]); if (selfhurt($ev) === 0) return ['c', $x, $y]; } } }
        return $minA ?? ['pass'];
    }
    if ($bot === 'builder') {   // builds a 3-group when healthy, else greedy
        $hp = $s['me']['hp'] / $s['me']['max']; $g = $s['me']['held'] ?? null;
        if ($g && count($g['pcs']) === 3) { $b = null; $bs = -1e9; foreach (pfb_group_spots($s, $g) as [$x, $y]) { [$w] = dry($s, ['c', $x, $y]); $sc = pfb_score($s, $w, 'me'); if ($sc > $bs) { $bs = $sc; $b = ['c', $x, $y]; } } if ($b) return $b; }
        if ($g && count($g['pcs']) === 2 && $hp >= 0.5) { foreach ($s['me']['hand'] as $bi => $t) if (in_array($t['t'], ['hurt', 'charm'], true)) foreach ($g['pcs'] as $ai => $_) foreach (['L', 'R', 'T', 'B'] as $sd) { $w = $s; if (pfb_connect($w, 'me', null, $bi, $sd, $ai) === null) return ['h', $bi, $ai, $sd]; } }
        if (!$g && $hp >= 0.6) { $bv = -1; $bj = null; foreach (legal_joins($s) as [$a, $b, $sd]) { $h = $s['me']['hand']; $v = $h[$a]['v'] + $h[$b]['v']; if (in_array($h[$a]['t'], ['hurt', 'charm']) && in_array($h[$b]['t'], ['hurt', 'charm']) && $v > $bv) { $bv = $v; $bj = ['j', $a, $b, $sd]; } } if ($bj) return $bj; }
        if ($g) { foreach (pfb_group_spots($s, $g) as [$x, $y]) { [$w] = dry($s, ['c', $x, $y]); if (pfb_score($s, $w, 'me') > 0 && count($g['pcs']) >= 2 && $hp < 0.5) return ['c', $x, $y]; } }
        $m = pfb_search($s, 'me'); return $m ? [$m[0], $m[1], $m[2]] : ['pass'];
    }
    if ($bot === 'charmb' || $bot === 'hurtb') { $best = null; $bs = -1e9; foreach (legal_places($s) as $p) { [$w] = dry($s, $p); $sc = ($bot === 'charmb' ? 1.0 : 0.2) * ($w['bar']['now'] - $s['bar']['now']) + ($bot === 'hurtb' ? 1.0 : 0.2) * ($w['fh']['now'] - $s['fh']['now']) + 0.7 * ($w['me']['hp'] - $s['me']['hp']) + ($w['over'] && $w['over'] !== 'defeat' ? 50 : 0); if ($sc > $bs) { $bs = $sc; $best = $p; } } return $best ?? ['pass']; }
    throw new Exception($bot);
}
$rows = array_values(pp_creatures()); $g = []; $tot = [];
foreach ($offs as $d) foreach ($rows as $c) for ($k = 0; $k < $N; $k++) {
    $lv = max(1, $c['level'] + $d); $seed = 500 + 7 * $k + $c['level']; mt_srand($seed * 31 + $d);
    $s = pfb_new(pp_player($lv), $c, $seed, $mode === 'blank' ? ['blank' => true] : []);
    if ($mode === 'blank') { $hand = $s['me']['hand']; $bi = 0;
        if ($sp === 'besthurt') foreach ($hand as $i => $t) { if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i; }
        elseif ($sp === 'random') $bi = mt_rand(0, count($hand) - 1);
        pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$sp === 'random' ? mt_rand(0, 3) : $k % 4]); }
    $t = 0; $pass = 0; $acts = 0; $joins = 0;
    while (!$s['over'] && $t++ < 40) { $a = choose($s, $bot); $acts++; if ($a[0] === 'pass') $pass++; if ($a[0] === 'j' || $a[0] === 'h') $joins++; $r = act($s, $a); if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { $m = legal_places($s); if (!$m) break; pfb_play($s, [$m[0]], $s['turn']); } } }
    $row = [in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0, $s['over'] === 'defeat' ? 1 : 0, $s['turn'], 1 - $s['me']['hp'] / max(1, $s['me']['max']), $pass / max(1, $acts), $joins];
    $g["d$d"][$c['size']][] = $row; $g["d$d"]['T_' . ($s['size'] === 'boss' ? 'boss' : $s['temper'])][] = $row; $g["d$d"]['all'][] = $row;
}
$o = [];
foreach ($g as $d => $bys) foreach (['all', 'small', 'medium', 'large', 'boss', 'T_gentle', 'T_hostile', 'T_boss'] as $sz) { $a = $bys[$sz] ?? []; if (!$a) continue; $n = count($a); $f = fn($i) => array_sum(array_column($a, $i)) / $n;
    $o[] = sprintf("%-4s %-6s n=%3d win=%3.0f%% def=%3.0f%% turns=%.2f hp_lost=%2.0f%% pass=%2.0f%% joins/f=%.2f", $d, $sz, $n, 100 * $f(0), 100 * $f(1), $f(2), 100 * $f(3), 100 * $f(4), $f(5)); }
echo implode("\n", $o), "\n";
