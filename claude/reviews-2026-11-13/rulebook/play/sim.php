<?php
// Rule book playtest driver: whole fights on the real engine (game/includes/pfboard.php) with hand-chosen policies.
//   php sim.php POLICY SEEDS [creature,creature,...]   -> one line per fight (json) on stdout
// The gnome and both decks are dealt exactly as tests/pf_play.php deals them (functions copied from it). Nothing in the game is changed.
require __DIR__ . '/../../../../game/includes/pfboard.php'; require __DIR__ . '/../../../../game/includes/pfdeck.php';
$die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
function pp_creatures(): array { global $die; $o = [];
    foreach (file(__DIR__ . '/../../../../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) { if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
        $lv = max(1, (int)$c[4]); $o[$c[0]] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)]; }
    return $o; }
function pp_sources(int $lv): array {
    $cals = array_keys(PF_CALLING_TILE); $src = pfd_sources_blank($lv, $cals[$lv % 6], ['NA', 'NWE', 'SE', 'EA'][$lv % 4]);
    $src['ctier'] = min(3, 1 + intdiv($lv, 12));
    $src['starter'] = array_merge(PFD_CORE, pfd_offer_keys($src['calling'], $src['home'], PFD_KITS[['bold', 'steady', 'kind'][$lv % 3]]));
    $tier = min(3, 1 + intdiv($lv, 10)); $src['slots'] = $lv >= 20 ? 4 : ($lv >= 10 ? 3 : 2);
    foreach (array_slice(['axe', 'till', 'staff', 'lantern'], 0, $src['slots']) as $i => $t) $src['tools'][$t] = max(1, $tier - ($i > 1 ? 1 : 0));
    $src['belt'] = array_keys($src['tools']);
    if ($lv >= 3) $src['pals'][] = ['n' => 'Bark Badger', 't' => 'guard', 'v' => 5 + ($lv >= 12 ? 2 : 0), 'r' => 'craft', 'rank' => $lv >= 12 ? 2 : 1];
    if ($lv >= 8) $src['pals'][] = ['n' => 'Samara Spin', 't' => 'hurt', 'v' => 5 + ($lv >= 20 ? 2 : 0), 'r' => 'body', 'rank' => $lv >= 20 ? 2 : 1];
    foreach (['vegetable' => 2, 'spice' => 10, 'fruit' => 14, 'nut' => 22] as $k => $at) if ($lv >= $at) $src['crops'][$k] = min(3, 1 + intdiv($lv - $at, 12));
    foreach (['garden' => 6, 'potions' => 12, 'tools' => 18] as $k => $at) if ($lv >= $at) $src['crafts'][$k] = 1;
    if ($lv >= 5) $src['regions'][$src['home']] = 1; if ($lv >= 16) $src['regions']['MENA'] = 2;
    $on = 0; foreach (['smash', 'sting', 'lull', 'pierce', 'hum', 'brace'] as $k) if ($on < 3 && $lv >= (int)pfd_catalog()[$k]['ref'] && !in_array($k, $src['starter'], true)) { $src['state'][$k] = true; $on++; }
    return $src; }
function pp_player(int $lv): array {
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $max = 20 + 3 * $lv + 5 * $m; $src = pp_sources($lv);
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pfd_tiles(pfd_fight_entries($src), $st, [], $src['calling'], $src['ctier']), 'luck' => $m]; }

/** Every action open to the player this turn, each with what the page's plan line shows after the piece is down: own chain and the aim total after it. */
function options(array $s): array {
    $o = [];
    foreach ($s['me']['hand'] as $i => $t) foreach ([0, 1] as $fl) {
        $w = $s; if ($fl && pfb_flip($w, $i, $w['turn']) !== null) continue;
        foreach (pfb_cells($w, $w['me']['hand'][$i], 'me') as [$x, $y]) {
            $c = $w; $r = pfb_play($c, [[$i, $x, $y]], $c['turn'], null, true, true); if ($r['err']) continue;
            $a = $r['aim'] ?? null; $n = 0; $foeFired = 0; $thorn = 0;
            foreach ($r['ev'] as $e) { if (!isset($e['id'])) continue; $n++; if ($e['by'] === 'foe') $foeFired++; if ($e['by'] === 'env' && ($e['kind'] ?? '') === 'thorn') $thorn++; }
            $o[] = ['i' => $i, 'fl' => $fl, 'x' => $x, 'y' => $y, 't' => $t['t'], 'yield' => $r['fh'] - $s['fh']['now'] + $r['bar'] - $s['bar']['now'], 'charm' => $r['bar'] - $s['bar']['now'], 'hp' => $r['hp'] - $s['me']['hp'], 'g' => $r['block'], 'n' => $n,
                'used' => !empty($r['ev'][0]['used']), 'end' => in_array($r['over'], ['seen_off', 'charmed'], true), 'dead' => $r['over'] === 'defeat', 'foeFired' => $foeFired, 'thorn' => $thorn,
                'aim' => $a === null ? 0 : (isset($a['broken']) ? null : (int)$a['hp']), 'broken' => is_array($a) && isset($a['broken']) ? $a['broken'] : '', 'quick' => is_array($a) && in_array('Quick: plays again', $a['why'] ?? [], true)];
        }
    }
    return $o;
}
/** The policies. Each returns an option, or null = pass. */
function choose(string $pol, array $s, array $opts): ?array {
    if (!$opts) return null;
    foreach ($opts as $o) if ($o['end']) return $o;                                   // every policy takes a win when it sees one
    $bar = $s['fh']['max']; $mx = $s['me']['max']; $plan = $s['foe']['plan'] ?? null; $pv = $plan && ($plan['t'] ?? '') === 'hurt' ? (int)$plan['v'] : 0;
    $passHit = (int)($plan['tot']['hp'] ?? 0);                                         // what the aim does if I do nothing
    $best = null; $bs = -INF;
    foreach ($opts as $o) {
        $after = $o['aim'] === null ? ($o['broken'] === 'slow' ? 0 : 0.6 * max($pv, $passHit * 0.5)) : $o['aim'];   // a broken aim: it picks again, guess 60% of its piece
        if (($s['foe']['kind'] ?? '') === 'beast' && $o['aim'] === null && $o['broken'] === 'cell') $after *= 1.5;    // Grudge
        $loss = -$o['hp'] + $after + ($o['quick'] ? 0.5 * $pv : 0);
        switch ($pol) {
            case 'greedy': $sc = $o['yield'] + 0.001 * $o['n']; break;                 // the careless player: biggest number on the lit cell
            case 'chain': $sc = $o['n'] + 0.01 * $o['yield']; break;                   // the longest chain, always
            case 'turtle': $sc = -$loss / $mx + 0.2 * $o['yield'] / $bar; break;       // health first
            case 'charmer': $sc = ($o['charm'] > 0 ? 2.0 : 1.0) * $o['yield'] / $bar - 1.0 * $loss / $mx; break;   // charm when it can
            case 'noblock': $sc = $o['yield'] / $bar - 1.0 * $loss / $mx - ($o['aim'] === null ? 0.5 : 0); break;  // reader that never breaks the aim
            default: $sc = $o['yield'] / $bar - 1.0 * $loss / $mx; break;              // 'reader': bar share gained minus health share lost (own chain + the aim after)
        }
        if ($o['dead']) $sc -= 100;
        if ($sc > $bs + 1e-9) { $bs = $sc; $best = $o; }
    }
    if (in_array($pol, ['reader', 'turtle', 'charmer', 'noblock'], true)) { $ps = -$passHit / $mx * ($pol === 'turtle' ? 1 : 1.0); if ($pol !== 'turtle' && $ps > $bs + 1e-9 && $best['yield'] <= 0) return null; if ($pol === 'turtle' && $ps > $bs + 1e-9) return null; }
    return $best;
}
/** The start piece: readers put a Hurt out (the highest), the careless ones the first piece in the hand. */
function start_pick(string $pol, array $s): array {
    $i = 0; if (!in_array($pol, ['greedy', 'chain'], true)) { $bv = -1; foreach ($s['me']['hand'] as $k => $t) if ($t['t'] === 'hurt' && $t['v'] > $bv) { $bv = $t['v']; $i = $k; } }
    return [$i, ['L', 'R', 'T', 'B'][$s['rng'] % 4]];
}
[, $pol, $seeds, $list] = $argv + [null, 'reader', 3, ''];
$all = pp_creatures(); $names = $list !== '' ? explode(',', $list) : array_keys($all); $keys = array_keys(pfd_region_pieces());
foreach ($names as $slug) for ($seed = (int)(getenv("SEED") ?: 1); $seed <= (getenv("SEED") ? (int)getenv("SEED") : (int)$seeds); $seed++) {
    $c = $all[$slug]; $cr = pfd_foe_row($c, $keys[(crc32($slug) + $seed) % 14]) + ['region' => ''];
    $s = pfb_new(pp_player($c['level']), $cr, $seed, ['blank' => true, 'v1' => true]);
    [$si, $sd] = start_pick($pol, $s); pfb_start($s, $si, $sd);
    $st = ['aimOverNP' => 0, 'poisonLost' => 0, 'own' => 0, 'ownFoe' => 0, 'ownThorn' => 0, 'foeTurn' => 0, 'pass' => 0, 'blocked' => 0, 'useups' => 0, 'aimShown' => 0, 'aimReal' => 0, 'aimOver' => 0, 'aimTurns' => 0, 'emptyStart' => 0, 'quickTurns' => 0, 'big' => 0];
    while (!$s['over']) {
        if (!array_filter($s['pcs'], fn($p) => $p['by'] === 'me')) $st['emptyStart']++;
        $opts = options($s); $o = choose($pol, $s, $opts); $hp0 = $s['me']['hp']; $pb = $s['foe']['plan'] ?? null; $planBefore = $pb ? [$pb['n'], $pb['t'], $pb['v'], $pb['tag'], $pb['x'] . ',' . $pb['y'], 'hits ' . ($pb['tot']['hp'] ?? '?')] : null;
        if ($o === null) { $shown = (int)($pb['tot']['hp'] ?? -1); $r = pfb_pass($s, $s['turn']); $st['pass']++; $hpMid = $hp0; }   // 2.6.990 re-run: the chip as it stood BEFORE the pass (the 2.6.986 run read the next round's chip here)
        else {
            if ($o['fl']) pfb_flip($s, $o['i'], $s['turn']);
            $c2 = $s; $d = pfb_play($c2, [[$o['i'], $o['x'], $o['y']]], $s['turn'], null, true, true); $hpMid = (int)$d['hp']; $shown = $o['aim'] ?? -1;
            if ($o['hp'] < 0) { $st['own'] -= $o['hp']; if ($o['thorn']) $st['ownThorn'] -= $o['hp']; elseif ($o['foeFired']) $st['ownFoe'] -= $o['hp']; }
            if ($o['aim'] === null && $o['broken'] !== 'slow') $st['blocked']++;
            if ($o['used']) $st['useups']++;
            $r = pfb_play($s, [[$o['i'], $o['x'], $o['y']]], $s['turn']);
            if ($r['err']) { fwrite(STDERR, "ERR $slug $seed: {$r['err']}\n"); break; }
        }
        if (getenv('TRACE')) {   // one line per turn: what was chosen, what the aim chip said, what happened
            $tx = []; foreach ($r['ev'] as $e) $tx[] = (isset($e['note']) ? 'NOTE ' . $e['note'] : (($e['ta'] ?? '') . ':' . ($e['by'] ?? '') . ' ' . ($e['n'] ?? '') . (isset($e['env']) ? ' [' . $e['env'] . ']' : '') . (!empty($e['combo']) ? ' *' . $e['combo'] : ''))) . ' v' . ($e['v'] ?? '') . (isset($e['hpnow']) ? ' hp' . $e['hpnow'] : '');
            fwrite(STDERR, sprintf("T%d %s | aim before: %s | shown after: %s | hp %d -> %d\n   %s\n", $s['turn'] - ($s['over'] ? 0 : 1), $o ? ($s['over'] ? '' : '') . 'play ' . $o['t'] . ($o['fl'] ? ' flipped' : '') . " @{$o['x']},{$o['y']} yield " . round($o['yield'], 1) . ' n' . $o['n'] : 'PASS', json_encode($planBefore), $shown, $hp0, $s['me']['hp'], implode(' ; ', $tx)));
        }
        $lost = $hpMid - $s['me']['hp']; if ($lost > 0) $st['foeTurn'] += $lost;
        $pz = 0; foreach ($s['envlog'] ?? [] as $L) if (($L['k'] ?? '') === 'poison') $pz += (int)$L['me']; $st['poisonLost'] += $pz;   // 2.6.990 re-run: poison ticks on me this round (not in the chip)
        if ($shown >= 0 && $lost - $pz > $shown) $st['aimOverNP']++;
        if ($shown >= 0) { $st['aimTurns']++; $st['aimShown'] += $shown; $st['aimReal'] += max(0, $lost); if ($lost > $shown) $st['aimOver']++; if ($lost >= 2 * max(1, $shown) && $lost >= 4) $st['big']++; }
    }
    echo json_encode(['pol' => $pol, 'slug' => $slug, 'size' => $c['size'], 'kind' => $s['foe']['kind'], 'lv' => $c['level'], 'seed' => $seed, 'over' => $s['over'], 'turns' => min($s['turn'], PF_TURN_CAP), 'hp' => $s['me']['hp'], 'max' => $s['me']['max'], 'lostpct' => round(100 * ($s['me']['max'] - $s['me']['hp']) / $s['me']['max']), 'charmShare' => round(100 * $s['bar']['now'] / max(0.1, $s['fh']['max']))] + $st) . "\n";
}
