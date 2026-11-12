<?php
// php run.php BOT OFFSETS [SHARD/NSHARDS] [MULT]   env V1='{"limit":3,...}' (see pfboard_v1.php). Prints one JSON line per fight.
// BOT: random | chain | greedy | look | smart | never3 | smartn3 (the last two avoid chains that use pieces up).  OFFSETS: gnome level minus creature level, e.g. 0,-4,-8.
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
    $src = [1 => 'pal', 2 => 'tool', 3 => 'crop', 5 => 'pal', 6 => 'tool', 7 => 'crop'];
    foreach ($deck as $i => $t) $deck[$i]['src'] = getenv('SRC') === 'thirds' ? ['pal', 'tool', 'crop'][$i % 3] : ($src[$i] ?? 'knack');   // SRC=thirds: every piece has a source (a deck built for Teamwork)
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
function choose(array $s, string $bot, array $pl, array $dr): array {
    if ($bot === 'smartn3') { $lim = (int)v1('limit') ?: 3; $ok = []; foreach ($pl as $i => $a) if ($dr[$i][1] < $lim) $ok[] = $a; if ($ok) $pl = $ok; $bot = 'smart'; }   // smart, but never uses pieces up if it can help it
    if (!$pl && $bot !== 'smart') return ['pass'];
    if ($bot === 'random') return $pl[mt_rand(0, count($pl) - 1)];
    if ($bot === 'chain') { $b = 0; $bs = -1e9; foreach ($dr as $i => $d) { $sc = $d[1] * 1000 + ($d[0]['fh']['now'] + $d[0]['bar']['now']) + ($d[0]['over'] && $d[0]['over'] !== 'defeat' ? 1e6 : 0); if ($sc > $bs + 1e-9) { $bs = $sc; $b = $i; } } return $pl[$b]; }   // always the longest chain; on a tie the one that moves the creature's bars most. Never looks at its own health or the creature's answer
    if ($bot === 'greedy') { $b = 0; $bs = -1e9; foreach ($dr as $i => $d) { $sc = pfb_score($s, $d[0], 'me'); if ($sc > $bs + 1e-9) { $bs = $sc; $b = $i; } } return $pl[$b]; }   // best own-chain numbers
    if ($bot === 'never3') { $lim = (int)v1('limit') ?: 3; $ok = []; foreach ($pl as $i => $a) if ($dr[$i][1] < $lim) $ok[] = $a; return ranked($s, $ok ?: $pl)[0][1] ?? ['pass']; }   // look, but never uses pieces up if it can help it
    if ($bot === 'look') return ranked($s, $pl)[0][1] ?? ['pass'];
    if ($bot === 'smart') {   // two turns: top 6 by look (set-aside included), then my best own chain next turn with the pieces I keep (no peeking at the draw pile)
        $acts = array_merge($pl, joins($s)); if (!$acts) return ['pass'];
        $top = array_slice(ranked($s, $acts), 0, 6); if (!$top) return ['pass'];
        $best = null; $bs = -1e9;
        foreach ($top as [$v1, $a, $w]) {
            $v2 = $v1;
            if (!$w['over']) {
                $keep = count($s['me']['hand']) - ($a[0] === 'j' ? 2 : ($a[0] === 'c' ? 0 : 1)); $v2 = $v1 - 0.02;
                foreach ($w['me']['hand'] as $i => $t) { if ($i >= $keep) break; foreach (pfb_cells($w, $t, 'me') as [$x, $y]) { [$w2] = dry($w, [$i, $x, $y]); $v2 = max($v2, value($w2)); } }
                if (!empty($w['me']['held'])) foreach (pfb_group_spots($w, $w['me']['held']) as [$x, $y]) { [$w2] = dry($w, ['c', $x, $y]); $v2 = max($v2, value($w2)); }
            }
            $sc = 0.35 * $v1 + 0.65 * $v2;
            if ($sc > $bs + 1e-9) { $bs = $sc; $best = $a; }
        }
        return $best;
    }
    throw new Exception("bot $bot");
}

[, $bot, $offs] = $argv + [null, 'chain', '0']; [$shard, $nsh] = array_map('intval', explode('/', $argv[3] ?? '0/1')); $mult = (float)($argv[4] ?? 1);
$lim = (int)v1('limit') ?: 3; $ci = 0;
foreach (array_map('intval', explode(',', $offs)) as $d) foreach (creatures() as $c) {
    if ($ci++ % $nsh !== $shard) continue;
    $nk = max(1, (int)ceil(SEEDS[$c['size']] * $mult));
    for ($k = 0; $k < $nk; $k++) {
        $lv = max(1, $c['level'] + $d); $seed = 500 + 7 * $k + $c['level'] + 1000 * (crc32($c['slug']) % 97); mt_srand($seed * 31 + $d);
        $s = pfb_new(player($lv), $c, $seed, ['blank' => true]);
        $hand = $s['me']['hand']; $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i;
        pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$k % 4]);
        $t = 0; $m = ['pl' => 0, 'fired' => 0, 'long' => 0, 'opp' => 0, 'tookopp' => 0, 'longest' => 0, 'pass' => 0, 'join' => 0, 'hand' => 0, 'board' => 0, 'legal' => 0, 'nolegal' => 0];
        while (!$s['over'] && $t++ < 40) {
            $pl = places($s); $dr = array_map(fn($a) => dry($s, $a), $pl);
            $m['hand'] += count($s['me']['hand']); $m['board'] += count(array_filter($s['pcs'], fn($q) => $q['by'] === 'me')); $m['legal'] += count($pl); if (!$pl) $m['nolegal']++;
            $a = choose($s, $bot, $pl, $dr);
            if ($a[0] === 'pass') $m['pass']++; elseif ($a[0] === 'j' || $a[0] === 'h') $m['join']++;
            else { $i = array_search($a, $pl); $n = $dr[$i][1]; $mx = max(array_map(fn($x) => $x[1], $dr)); $m['pl']++; $m['fired'] += $n; if ($n >= $lim) $m['long']++; if ($mx >= $lim) { $m['opp']++; if ($n >= $lim) $m['tookopp']++; } if ($n === $mx) $m['longest']++; }
            $r = act($s, $a);
            if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { if (!$pl) break; pfb_play($s, [$pl[0]], $s['turn']); } }
        }
        echo json_encode(['bot' => $bot, 'd' => $d, 'size' => $c['size'], 'slug' => $c['slug'], 'win' => in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0, 'over' => $s['over'] ?: 'cap', 'turns' => $s['turn'], 'hp' => round(1 - $s['me']['hp'] / $s['me']['max'], 3), 't' => $t] + $m + ['st' => $s['st']]), "\n";
    }
}
