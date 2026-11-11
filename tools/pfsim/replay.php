<?php
require __DIR__ . '/common.php';
$dir = rtrim($argv[1] ?? 'runs2', '/') . '/';   // folder holding the res-*, assign-* and *.log files (unpack docs/playtest-data/round2-*.tar.gz)
$all = pp_creatures(); $meta = [];
foreach (glob($dir . 'assign-*.json') as $f) foreach (json_decode(file_get_contents($f), true) as $a) $meta[$a['seed'] . '-' . $a['mode']] = $a;
$out = [];
foreach ($meta as $key => $a) {
    $log = $dir . "state-$key.json.log"; if (!is_file($log)) continue;
    $s = pfb_new(pp_player($a['level']), $all[$a['slug']], $a['seed'], $a['mode'] === 'blank' ? ['blank' => true] : []);
    $F = ['key' => $key, 'mode' => $a['mode'], 'size' => $a['size'], 'off' => $a['offset'], 'style' => $a['playstyle'], 'max' => $s['me']['max'], 'turns' => [], 'mismatch' => 0];
    foreach (file($log, FILE_IGNORE_NEW_LINES) as $l) {
        $d = json_decode($l, true); if ($d['err']) continue; $p = explode(' ', $d['act']); $cmd = $p[0]; $ar = array_map('intval', array_slice($p, 1));
        if ($cmd === 'start') { pfb_start($s, (int)$p[1], $p[2]); continue; }
        // decision-point analysis
        $T = ['cmd' => $cmd, 'hp0' => $s['me']['hp']];
        $lp = legal_places($s); $sh = [];
        foreach ($lp as [$i, $x, $y]) { $w = $s; $r = pfb_play($w, [[$i, $x, $y]], $s['turn'], null, true); $sh[] = selfhurt($r['ev']); }
        $T['nlegal'] = count($lp); $T['nsafe'] = count(array_filter($sh, fn($v) => $v == 0)); $T['minsh'] = $sh ? min($sh) : 0;
        $T['canjoin'] = count(legal_joins($s)) > 0;
        $T['grp'] = !empty($s['me']['held']) ? count(pfb_group_spots($s, $s['me']['held'])) : -1;
        $S0 = $s;
        if ($cmd === 'place') $r = pfb_play($s, [[$ar[0], $ar[1], $ar[2]]], $s['turn']);
        elseif ($cmd === 'join') $r = pfb_play($s, [['j', $ar[0], $ar[1], strtoupper($p[3])]], $s['turn']);
        elseif ($cmd === 'add') $r = pfb_play($s, [['h', $ar[0], $ar[1], strtoupper($p[3])]], $s['turn']);
        elseif ($cmd === 'group') $r = pfb_play($s, [['c', $ar[0], $ar[1]]], $s['turn']);
        elseif ($cmd === 'pass') $r = pfb_pass($s, $s['turn']);
        else continue;
        if ($r['err']) { $F['mismatch']++; break; }
        // attribution
        $mine = 0; $foe = 0; $myBlocked = 0; $guardLate = 0; $poison = 0; $foeRefire = 0; $combos = [];
        $chainSeenGuard = false;
        foreach ($r['ev'] as $e) {
            if (!empty($e['tick'])) { $poison += $e['v']; continue; }
            if (!isset($e['id'])) continue;
            if (($e['by']) === 'foe' && $e['t'] === 'hurt') { $dm = (int)($e['dmg'] ?? 0); if ($e['ta'] === 'me') $mine += $dm; else { $foe += $dm; if (empty($e['root'])) $foeRefire += $dm; } }
            if ($e['by'] === 'me' && $e['t'] === 'hurt') $myBlocked += (int)($e['blocked'] ?? 0);
            if (!empty($e['combo'])) $combos[] = $e['by'] . ':' . $e['combo'];
        }
        // guard-late: in my turn's chain, my guard pieces that fired AFTER a creature hurt that did damage
        $hitSoFar = 0; foreach ($r['ev'] as $e) { if (($e['ta'] ?? '') !== 'me' || !isset($e['id'])) continue; if ($e['by'] === 'foe' && $e['t'] === 'hurt') $hitSoFar += (int)($e['dmg'] ?? 0); if ($e['by'] === 'me' && $e['t'] === 'guard' && $hitSoFar > 0) $guardLate += min($hitSoFar, (int)$e['v']); }
        $T += ['selfhurt' => $mine, 'foeturn' => $foe, 'foerefire' => $foeRefire, 'myblocked' => $myBlocked, 'guardlate' => $guardLate, 'poison' => $poison, 'combos' => $combos, 'hp1' => $s['me']['hp'], 'loghp' => $d['hp']];
        if ($s['me']['hp'] !== $d['hp']) $F['mismatch']++;
        $F['turns'][] = $T;
    }
    $F['over'] = $s['over']; $out[] = $F;
}
file_put_contents(__DIR__ . '/replay.json', json_encode($out));
echo count($out), " fights, mismatches: ", count(array_filter($out, fn($f) => $f['mismatch'])), "\n";
