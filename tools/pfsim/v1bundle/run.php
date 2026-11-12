<?php
// php run.php BOT OFFSETS [SHARD/NSHARDS] [MULT]   env V1='{"limit":3,...}' (see pfboard_v1.php). Prints one JSON line per fight.
// BOT: random | chain | greedy | look | smart | never3 | smartn3 (the last two avoid chains that use pieces up).  OFFSETS: gnome level minus creature level, e.g. 0,-4,-8.
// A suffix makes look or smart blind to the environment when it chooses: look-g (ignores ground), look-e (ignores events), look-ge, smart-ge.
// look and smart fights also record how often the best one-turn move changes when ground / events are ignored (keys bm_*). METRIC=0 turns that off.
// Fights per creature are set so every size has >= 200 fights per offset (x MULT, default 1).
require __DIR__ . '/pfboard_v1.php';
const SEEDS = ['small' => 21, 'medium' => 8, 'large' => 5, 'boss' => 23];   // 10 small, 26 medium, 43 large, 9 boss creatures -> 210 / 208 / 215 / 207 fights

function creatures(): array {
    $die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10]; $o = [];
    foreach (file((getenv('ENG') ?: __DIR__ . '/../../../game/includes') . '/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
        if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
        $lv = max(1, (int)$c[4]); $o[] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
    }
    return $o;
}
/** The default gnome of tools/pfsim/common.php, plus a source on each piece for Teamwork: 2 pal, 2 tool, 2 crop, the rest knack. */
function player(int $lv): array {
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $cals = array_keys(PF_CALLING_TILE); $cal = $cals[$lv % 6]; $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0]; $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    $max = 20 + 3 * $lv + 5 * $m;
    $deck = pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, $box);
    // Sources for Teamwork. Default "mixed": 1 pal, 2 tool (the starting belt), 2 crop, the rest knacks. SRC=built: 2 pal (a full party), 4 tool (the top belt), 4 crop. SRC=thirds: every piece has a source. SRC=none: no sources.
    $mode = getenv('SRC') ?: 'mixed'; $n = count($deck);
    $plan = $mode === 'built' ? ['pal', 'tool', 'crop', 'tool', 'crop', 'pal', 'tool', 'crop', 'tool', 'crop'] : ['tool', 'crop', 'pal', 'tool', 'crop'];
    $slots = []; for ($i = 0; $i < count($plan); $i++) $slots[(int)floor(($i + 0.5) * $n / count($plan))] = $plan[$i];   // spread over the deck (it is shuffled anyway)
    foreach ($deck as $i => $t) $deck[$i]['src'] = $mode === 'thirds' ? ['pal', 'tool', 'crop'][$i % 3] : ($mode === 'none' ? 'knack' : ($slots[$i] ?? 'knack'));
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => $deck, 'luck' => $m, 'calling' => $cal];
}
function places(array $s): array { $o = []; foreach ($s['me']['hand'] as $i => $t) foreach (pfb_cells($s, $t, 'me') as [$x, $y]) $o[] = [$i, $x, $y]; if (!empty($s['me']['held'])) foreach (pfb_group_spots($s, $s['me']['held']) as [$x, $y]) $o[] = ['c', $x, $y]; return $o; }
function joins(array $s): array {
    $o = []; $h = $s['me']['hand']; $g = $s['me']['held'] ?? null;
    if (!$g) { foreach ($h as $a => $_) foreach ($h as $b => $_2) if ($a !== $b) foreach (['L', 'R', 'T', 'B'] as $sd) { $w = $s; if (pfb_connect($w, 'me', $a, $b, $sd) === null) $o[] = ['j', $a, $b, $sd]; } }
    elseif (count($g['pcs']) < PFB_GROUP_MAX) { foreach ($h as $b => $_) foreach ($g['pcs'] as $ai => $_2) foreach (['L', 'R', 'T', 'B'] as $sd) { $w = $s; if (pfb_connect($w, 'me', null, $b, $sd, $ai) === null) $o[] = ['h', $b, $ai, $sd]; } }
    return $o;
}
/** My own chain only (what the lit cell shows: damage, charm, health cost, pieces fired). No creature answer. [state after, pieces fired]. */
function dry(array $s, array $a): array { $w = $s; $w['reshuf'] = []; $w['cut'] = 0; $w['spent'] = []; $ev = $a[0] === 'c' ? pfb_place_group($w, 'me', $a[1], $a[2]) : pfb_place($w, 'me', $a[0], $a[1], $a[2]); return [$w, count(array_filter($ev ?? [], fn($e) => isset($e['id'])))]; }
function act(array &$s, array $a): array { return $a[0] === 'pass' ? pfb_pass($s, $s['turn']) : pfb_play($s, [$a], $s['turn']); }
/** State value: progress share + 1.2 x health share (design doc section 7), a little for guard that is up, big for the result. */
function value(array $s): float {
    $p = $s['fh']['now'] / $s['fh']['max']; if ($s['cm'] > 0) $p = max($p, $s['bar']['now'] / $s['bar']['max']);
    $v = min(1.0, $p) + 1.2 * $s['me']['hp'] / $s['me']['max'] + 0.3 * min($s['me']['block'] + $s['me']['keep'], 0.3 * $s['me']['max']) / $s['me']['max'] - 0.15 * $s['foe']['block'] / $s['fh']['max'];
    if (getenv('HOARD') !== false) $v += (float)getenv('HOARD') * count(array_filter($s['pcs'], fn($q) => $q['by'] === 'me'));
    if ($s['over']) $v += $s['over'] === 'defeat' ? -3 : ($s['over'] === 'stall' ? -1 : 3);
    return $v;
}
/** look: the state after my chain, the creature's shown aim and the announced environment turn (all public with the v1 rules). */
function ranked(array $s, array $acts): array {
    $o = [];
    foreach ($acts as $a) { $w = $s; $r = act($w, $a); if ($r['err']) continue; $o[] = [value($w), $a, $w]; }
    usort($o, fn($x, $y) => $y[0] <=> $x[0]);
    return $o;
}
/** The state as a player who ignores ground ('g') and / or events ('e') reads it. */
function strip(array $s, string $what): array { if (strpos($what, 'g') !== false) $s['ter'] = []; if (strpos($what, 'e') !== false) $s['envs'] = []; return $s; }
/** How often does the best one-turn move change when the environment is ignored? Counts turns where the move picked blind is worse (by the full reading) than the best move: any amount, and by 0.03+ / 0.08+ of the state value (1.0 = the whole creature bar, 1.2 = all your health). */
function metric(array $s, array $pl, array &$m): void {
    if (count($pl) < 2) return;
    $full = ranked($s, $pl); if (count($full) < 2) return; $val = []; foreach ($full as [$v, $a]) $val[json_encode($a)] = $v; $best = $full[0][0]; $ba = $full[0][1];
    $m['bm_n']++;
    foreach (['g', 'e', 'ge'] as $w) { $r = ranked(strip($s, $w), $pl)[0][1] ?? null; if ($r === null) continue; $reg = $best - ($val[json_encode($r)] ?? $best);
        if ($reg > 1e-6) { $m["bm_$w"]++; if ($w === 'e') $m['bm_efight'] = 1; if ($r[1] !== $ba[1] || $r[2] !== $ba[2]) $m["bmc_$w"]++; } if ($reg >= 0.03) $m["bm3_$w"]++; if ($reg >= 0.08) $m["bm8_$w"]++; $m["bmr_$w"] += $reg; }
}
/** smart's score of one action: 0.35 x the look value + 0.65 x the value after my best own chain next turn with the pieces I keep (no peeking at the draw pile). */
function smart_score(array $s, array $a, float $v1, array $w): float {
    $v2 = $v1;
    if (!$w['over']) {
        $keep = count($s['me']['hand']) - ($a[0] === 'j' ? 2 : ($a[0] === 'c' ? 0 : 1)); $v2 = $v1 - 0.02;
        foreach ($w['me']['hand'] as $i => $t) { if ($i >= $keep) break; foreach (pfb_cells($w, $t, 'me') as [$x, $y]) { [$w2] = dry($w, [$i, $x, $y]); $v2 = max($v2, value($w2)); } }
        if (!empty($w['me']['held'])) foreach (pfb_group_spots($w, $w['me']['held']) as [$x, $y]) { [$w2] = dry($w, ['c', $x, $y]); $v2 = max($v2, value($w2)); }
    }
    return 0.35 * $v1 + 0.65 * $v2;
}
/** smart: two turns. The top 6 actions by look (set-aside included), scored by smart_score, best first. */
function smart_rank(array $s, array $acts): array {
    $o = []; foreach (array_slice(ranked($s, $acts), 0, 6) as [$v1, $a, $w]) $o[] = [smart_score($s, $a, $v1, $w), $a];
    usort($o, fn($x, $y) => $y[0] <=> $x[0]); return $o;
}
/** The same measure for the two-turn planner: its pick with ground / events hidden, scored with everything visible. */
function metric2(array $s, array $pl, array &$m): void {
    $acts = array_merge($pl, joins($s)); if (count($acts) < 2) return;
    $full = smart_rank($s, $acts); if (!$full) return; $best = $full[0][0]; $ba = $full[0][1]; $val = []; foreach ($full as [$v, $a]) $val[json_encode($a)] = $v;
    $m['bm_n']++; $hit = false;
    foreach (['g', 'e', 'ge'] as $w) { $r = smart_rank(strip($s, $w), $acts)[0][1] ?? null; if ($r === null || $r === $ba) continue; $k = json_encode($r);
        if (!isset($val[$k])) { $x = $s; $rr = act($x, $r); if ($rr['err']) continue; $val[$k] = smart_score($s, $r, value($x), $x); }
        $reg = $best - $val[$k];
        if ($reg > 1e-6) { $m["bm_$w"]++; if ($w === 'e') $hit = true; } if ($reg >= 0.03) $m["bm3_$w"]++; if ($reg >= 0.08) $m["bm8_$w"]++; $m["bmr_$w"] += max(0, $reg); }
    if ($hit) $m['bm_efight'] = 1;
}
function choose(array $s, string $bot, array $pl, array $dr): array {
    if (strpos($bot, '-') !== false) { [$bot, $bl] = explode('-', $bot, 2); $s = strip($s, $bl); }
    if ($bot === 'smartn3') { $lim = (int)v1('limit') ?: 3; $ok = []; foreach ($pl as $i => $a) if ($dr[$i][1] < $lim) $ok[] = $a; if ($ok) $pl = $ok; $bot = 'smart'; }   // smart, but never uses pieces up if it can help it
    if (!$pl && $bot !== 'smart') return ['pass'];
    if ($bot === 'random') return $pl[mt_rand(0, count($pl) - 1)];
    if ($bot === 'chain') { $b = 0; $bs = -1e9; foreach ($dr as $i => $d) { $sc = $d[1] * 1000 + ($d[0]['fh']['now'] + $d[0]['bar']['now']) + ($d[0]['over'] && $d[0]['over'] !== 'defeat' ? 1e6 : 0); if ($sc > $bs + 1e-9) { $bs = $sc; $b = $i; } } return $pl[$b]; }   // always the longest chain; on a tie the one that moves the creature's bars most. Never looks at its own health or the creature's answer
    if ($bot === 'greedy') { $b = 0; $bs = -1e9; foreach ($dr as $i => $d) { $sc = pfb_score($s, $d[0], 'me'); if ($sc > $bs + 1e-9) { $bs = $sc; $b = $i; } } return $pl[$b]; }   // best own-chain numbers
    if ($bot === 'never3') { $lim = (int)v1('limit') ?: 3; $ok = []; foreach ($pl as $i => $a) if ($dr[$i][1] < $lim) $ok[] = $a; return ranked($s, $ok ?: $pl)[0][1] ?? ['pass']; }   // look, but never uses pieces up if it can help it
    if ($bot === 'look') return ranked($s, $pl)[0][1] ?? ['pass'];
    if ($bot === 'smart') { $acts = array_merge($pl, joins($s)); if (!$acts) return ['pass']; $r = smart_rank($s, $acts); return $r ? $r[0][1] : ['pass']; }
    throw new Exception("bot $bot");
}

[, $bot, $offs] = $argv + [null, 'chain', '0']; [$shard, $nsh] = array_map('intval', explode('/', $argv[3] ?? '0/1')); $mult = (float)($argv[4] ?? 1);
$lim = (int)v1('limit') ?: 3; $ci = 0; $metric = getenv('METRIC') !== '0' && in_array(explode('-', $bot)[0], ['look', 'smart'], true);
foreach (array_map('intval', explode(',', $offs)) as $d) foreach (creatures() as $c) {
    if ($ci++ % $nsh !== $shard) continue;
    $nk = max(1, (int)ceil(SEEDS[$c['size']] * $mult));
    for ($k = 0; $k < $nk; $k++) {
        $lv = max(1, $c['level'] + $d); $seed = 500 + 7 * $k + $c['level'] + 1000 * (crc32($c['slug']) % 97); mt_srand($seed * 31 + $d);
        $s = pfb_new(player($lv), $c, $seed, ['blank' => true]);
        $hand = $s['me']['hand']; $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i;
        pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$k % 4]);
        $t = 0; $m = ['pl' => 0, 'fired' => 0, 'long' => 0, 'opp' => 0, 'tookopp' => 0, 'longest' => 0, 'pass' => 0, 'join' => 0, 'hand' => 0, 'board' => 0, 'legal' => 0, 'nolegal' => 0, 'on_sun' => 0, 'on_br' => 0, 'on_mud' => 0, 'in_thorn' => 0, 'in_rain' => 0, 'sun_open' => 0, 'thorn_open' => 0,
            'nev' => 0, 'mark_n' => 0, 'on_sunmark' => 0, 'on_brmark' => 0, 'bm_efight' => 0, 'bm_n' => 0, 'bm_g' => 0, 'bm_e' => 0, 'bm_ge' => 0, 'bmc_g' => 0, 'bmc_e' => 0, 'bmc_ge' => 0, 'bm3_g' => 0, 'bm3_e' => 0, 'bm3_ge' => 0, 'bm8_g' => 0, 'bm8_e' => 0, 'bm8_ge' => 0, 'bmr_g' => 0, 'bmr_e' => 0, 'bmr_ge' => 0];
        $zone = function (array $s, string $kind, int $x, int $y): bool { foreach ($s['envs'] ?? [] as $e) if ($e['kind'] === $kind) foreach (pfb_zone($e) as [$zx, $zy]) if ($zx === $x && $zy === $y) return true; return false; };
        while (!$s['over'] && $t++ < 40) {
            $pl = places($s); $dr = array_map(fn($a) => dry($s, $a), $pl);
            $m['hand'] += count($s['me']['hand']); $m['board'] += count(array_filter($s['pcs'], fn($q) => $q['by'] === 'me')); $m['legal'] += count($pl); if (!$pl) $m['nolegal']++;
            if ($metric) { if (explode('-', $bot)[0] === 'smart' && getenv('METRIC') !== '1') metric2($s, $pl, $m); else metric($s, $pl, $m); }
            $m['nev'] += count($s['envs'] ?? []); foreach ($s['envs'] ?? [] as $e) if (in_array($e['kind'], ['sunbeam', 'creep', 'puddle'], true)) { $m['mark_n']++; }
            $a = choose($s, $bot, $pl, $dr);
            if (array_filter($pl, fn($q) => is_int($q[0]) && pfb_ter($s, $q[1], $q[2]) === 'sun' && in_array($s['me']['hand'][$q[0]]['t'], ['hurt', 'charm'], true))) $m['sun_open']++;
            if (array_filter($pl, fn($q) => is_int($q[0]) && $zone($s, 'thorn', $q[1], $q[2]))) $m['thorn_open']++;
            if (is_int($a[0])) { $tk = pfb_ter($s, $a[1], $a[2]); if ($tk === 'sun' && in_array($s['me']['hand'][$a[0]]['t'], ['hurt', 'charm'], true)) $m['on_sun']++; elseif ($tk === 'br') $m['on_br']++; elseif ($tk === 'mud') $m['on_mud']++; if ($zone($s, 'thorn', $a[1], $a[2])) $m['in_thorn']++; foreach ($s['envs'] ?? [] as $e) if ($e['x'] === $a[1] && $e['y'] === $a[2]) { if ($e['kind'] === 'sunbeam') $m['on_sunmark']++; if ($e['kind'] === 'creep') $m['on_brmark']++; } }
            if ($a[0] === 'pass') $m['pass']++; elseif ($a[0] === 'j' || $a[0] === 'h') $m['join']++;
            else { $i = array_search($a, $pl); $n = $dr[$i][1]; $mx = max(array_map(fn($x) => $x[1], $dr)); $m['pl']++; $m['fired'] += $n; if ($n >= $lim) $m['long']++; if ($mx >= $lim) { $m['opp']++; if ($n >= $lim) $m['tookopp']++; } if ($n === $mx) $m['longest']++; }
            $r = act($s, $a);
            if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { if (!$pl) break; pfb_play($s, [$pl[0]], $s['turn']); } }
        }
        echo json_encode(['bot' => $bot, 'd' => $d, 'size' => $c['size'], 'slug' => $c['slug'], 'win' => in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0, 'over' => $s['over'] ?: 'cap', 'turns' => $s['turn'], 'hp' => round(1 - $s['me']['hp'] / $s['me']['max'], 3), 't' => $t, 'w' => pfb_w(), 'h' => pfb_h()] + $m + ['st' => $s['st']]), "\n";
    }
}
