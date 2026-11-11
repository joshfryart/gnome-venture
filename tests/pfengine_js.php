<?php
// Emits PHP board-engine traces for tests/pfengine_js.js (the JS port tools/pfengine.js must reproduce every line).
// One JSON line per record: a header (tile library, PHP round() and crc32 samples, extra deck builds), then one line per fight with
// every action (dry runs, bad moves, passes, plays) and, after each, the events, the view and a digest of the hidden state.
// The bots mirror tests/pfboard_sim.php (bsim_act, 'single' and 'builder'), plus a 'chaos' bot that plays random legal and
// illegal moves with random tile boxes, upgrades and options, so every tile tag and upgrade is exercised.
require __DIR__ . '/../game/includes/pfboard.php';
require __DIR__ . '/../game/includes/pfight_game.php';

function out(array $o): void { echo json_encode($o, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRESERVE_ZERO_FRACTION), "\n"; }

// ---- the bots (copied from tests/pfboard_sim.php, which cannot be required: it runs on load)
function bsim_player(int $lv): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $cals = array_keys(PF_CALLING_TILE); $cal = $cals[$lv % 6]; $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0]; $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    $max = 20 + 3 * $lv + 5 * $m;
    $tier = 1 + intdiv($lv, 12);
    return ['me' => ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pf_player_deck($st, $cal, $tier, [], [], [], true, $box), 'luck' => $m], 'args' => [$st, $cal, $tier, [], [], [], true, $box]];
}
function bsim_val(array $s, array $t): float { $w = ['hurt' => $s['hm'], 'charm' => $s['cm'], 'guard' => 0.5, 'heal' => 0.5, 'soothe' => 0.3, 'trick' => 0.4, 'item' => 0.5]; return $t['v'] * ($w[$t['t']] ?? 0.3); }
function bsim_act(array $s, string $mode): ?array
{
    $one = pfb_search($s, 'me');
    $held = $s['me']['held'] ?? null;
    if ($mode === 'builder') {
        if ($held) {
            $n = count($held['pcs']); $spots = pfb_group_spots($s, $held); $best = null;
            foreach ($spots as [$x, $y]) { $w = $s; if (pfb_place_group($w, 'me', $x, $y) === null) continue; $sc = pfb_score($s, $w, 'me'); if ($best === null || $sc > $best[2]) $best = [$x, $y, $sc]; }
            if ($n === 3 && $best) return ['c', $best[0], $best[1]];
            if ($n === 2) {
                $bo = null;
                foreach ($s['me']['hand'] as $bi => $t) foreach (pfb_group_options($held, $t) as [$ai, $side]) { $v = bsim_val($s, $t); if ($bo === null || $v > $bo[0]) $bo = [$v, $bi, $ai, $side]; }
                if ($bo && (!$one || $one[3] < 5.0)) return ['h', $bo[1], $bo[2], $bo[3]];
                if ($best && (!$one || $best[2] >= $one[3])) return ['c', $best[0], $best[1]];
            }
        } elseif (!$one || $one[3] < 4.0) {
            $bo = null; $hand = $s['me']['hand'];
            foreach ($hand as $ai => $ta) foreach ($hand as $bi => $tb) {
                if ($ai === $bi) continue;
                foreach (PFB_SIDE as $side => [$dx, $dy]) { $g = ['pcs' => [['tile' => $ta, 'x' => 0, 'y' => 0]]]; if (pfb_group_fit($g, $tb, $dx, $dy) !== true) continue; $v = bsim_val($s, $ta) + bsim_val($s, $tb); if ($bo === null || $v > $bo[0]) $bo = [$v, $ai, $bi, $side]; }
            }
            if ($bo) return ['j', $bo[1], $bo[2], $bo[3]];
        }
    }
    return $one ? [$one[0], $one[1], $one[2]] : null;
}
/** Candidate moves in order (the first that is legal is played). Chaos tries something random first, then falls back to the single bot. */
function candidates(array $s, string $mode): array
{
    if ($mode !== 'chaos') return [bsim_act($s, $mode)];
    $c = []; $hand = $s['me']['hand']; $held = $s['me']['held'] ?? null; $r = mt_rand(0, 99);
    if ($held && $r < 35) {
        if (count($held['pcs']) < 3 && $hand && mt_rand(0, 1)) { $c[] = ['h', mt_rand(0, count($hand) - 1), mt_rand(0, count($held['pcs']) - 1), array_rand(PFB_SIDE)]; }
        $spots = pfb_group_spots($s, $held);
        if ($spots) { $sp = $spots[mt_rand(0, count($spots) - 1)]; $c[] = ['c', $sp[0], $sp[1]]; }
        else $c[] = ['c', mt_rand(0, 6), mt_rand(0, 4)];
    } elseif (!$held && count($hand) >= 2 && $r < 25) {
        $c[] = ['j', mt_rand(0, count($hand) - 1), mt_rand(0, count($hand) - 1), array_rand(PFB_SIDE)];
    } elseif ($hand && $r < 80) {
        $i = mt_rand(0, count($hand) - 1); $cells = pfb_cells($s, $hand[$i]);
        $c[] = $cells && mt_rand(0, 9) ? array_merge([$i], $cells[mt_rand(0, count($cells) - 1)]) : [$i, mt_rand(0, 6), mt_rand(0, 4)];
    }
    $c[] = bsim_act($s, 'single');
    return $c;
}
/** Everything a UI or bot could ask of the engine before moving (compared with the JS answers). */
function queries(array $s): array
{
    $q = ['search' => pfb_search($s, 'me'), 'search_nh' => pfb_search($s, 'me', false), 'foe_search' => pfb_search($s, 'foe'), 'cells' => [], 'edges' => []];
    foreach ($s['me']['hand'] as $t) { $q['cells'][] = pfb_cells($s, $t); $q['edges'][] = pfb_edges($t); }
    $g = $s['me']['held'] ?? null;
    if ($g) { $q['spots'] = pfb_group_spots($s, $g); $q['opts'] = array_map(fn($t) => pfb_group_options($g, $t), $s['me']['hand']); }
    return $q;
}
/** The hidden state in brief: rng and the order of every pile, so a shuffle or a draw that differs shows up at once. */
function digest(array $s): array
{
    $k = fn(array $a) => array_map(fn($t) => $t['k'] . ':' . $t['v'], $a);
    return ['rng' => $s['rng'], 'md' => $k($s['me']['draw']), 'mx' => $k($s['me']['discard']), 'fh' => $k($s['foe']['hand']), 'fd' => $k($s['foe']['draw']), 'fx' => $k($s['foe']['discard']), 'held' => $s['me']['held'] ?? null];
}
function noNonce(array $s): array { unset($s['nonce']); return $s; }
function slim(array $v): array { unset($v['combos']); return $v; }   // the combo table never changes; it is checked once in the header

// ---- header: library, round(), crc32, a few deck builds with every pf_player_deck argument
mt_srand(5);
$rounds = [];
for ($i = 0; $i < 4000; $i++) {
    $x = [mt_rand(1, 400) / 10 * 0.8, mt_rand(1, 60) * 1.25, mt_rand(1, 300) * 0.62 / 3, mt_rand(1, 900) * 0.7 / 7, mt_rand(0, 2000) / 20 * 0.25, mt_rand(1, 99) * 0.4, mt_rand(-50, 50) / 4][$i % 7];
    $rounds[] = [$x, round($x, 1), (int)round($x)];
}
foreach ([0.5, 1.5, 2.5, 3.5, 4.5, 2.675, 1.005, 0.285, 1.45, 5.055, 0.15, 0.25, 0.35, 8.55, 7.5, 3.75, 10.5] as $x) $rounds[] = [$x, round($x, 1), (int)round($x)];
$crc = []; foreach (array_merge(array_keys(pf_tiles()), ['pal:Wolf', 'f:hit1', 'pal:Ünï']) as $k) foreach (['|T', '|B'] as $salt) $crc[] = [$k . $salt, crc32($k . $salt)];
$decks = [];
$st = ['grit' => 2, 'nimble' => 1, 'hardiness' => 3, 'charm' => 2, 'lore' => 1, 'luck' => 0, 'level' => 8];
$pals = [['swap' => 'dodge', 'n' => 'Wolf', 't' => 'guard', 'v' => 5, 'r' => 'mind'], ['swap' => 'nope', 'n' => 'Fox', 't' => 'hurt', 'v' => 4, 'r' => null], ['swap' => 'x', 'n' => 'Third', 't' => 'heal', 'v' => 2, 'r' => 'body']];
foreach ([[$st, 'bloomcaller', 2, [], ['soothe', 'jab', 'nonexistent', 'swing'], ['charm' => 1], false, null], [$st, 'thornblade', 3, $pals, ['smash', 'offer'], ['hurt' => 2, 'guard' => 1], true, null],
          [$st, '', 1, $pals, [], [], true, ['swing', 'pierce', 'dodge', 'rest', 'charm', 'snack', 'bark', 'nothing']], [$st, 'wayfinder', 1, [], pf_unlocks(16), [], true, null]] as $a) {
    $decks[] = ['args' => $a, 'deck' => pf_player_deck(...$a)];
}
out(['hdr' => true, 'tiles' => pf_tiles(), 'combos' => PF_COMBOS, 'tags' => PF_TAGS, 'mods' => PF_MODS, 'rounds' => $rounds, 'crc' => $crc, 'decks' => $decks]);

// ---- fights
$die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
$rows = [];
foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
    $lv = max(1, (int)$c[4]); $rows[] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
}
$nf = 0; $na = 0;
foreach ($rows as $ci => $c) foreach ([['single', 11], ['builder', 22], ['chaos', 33]] as [$mode, $seed]) {
    mt_srand($seed * 1000 + $ci);
    $opt = []; $mods = false;
    if ($mode === 'chaos') {
        $all = array_keys(pf_tiles()); $box = [];
        shuffle($all); $n = mt_rand(8, 14); $box = array_slice($all, 0, $n);
        if (pf_box_check($box, 14) !== null) $box[0] = 'swing';
        $stt = ['grit' => mt_rand(0, 4), 'nimble' => mt_rand(0, 4), 'hardiness' => mt_rand(0, 4), 'charm' => mt_rand(0, 4), 'lore' => mt_rand(0, 4), 'luck' => mt_rand(0, 4), 'level' => $c['level']];
        $cals = array_keys(PF_CALLING_TILE); $cal = mt_rand(0, 1) ? $cals[mt_rand(0, 5)] : ''; $tier = mt_rand(1, 3);
        $tb = mt_rand(0, 1) ? ['hurt' => mt_rand(0, 2), 'charm' => mt_rand(0, 2)] : [];
        $args = [$stt, $cal, $tier, [], [], $tb, (bool)mt_rand(0, 1), $box];
        $deck = pf_player_deck(...$args); $deck0 = $deck;
        foreach ($deck as $i => $t) if (mt_rand(0, 2) === 0) { $fit = array_keys(array_filter(PF_MODS, fn($m) => in_array($t['t'], $m[4], true))); $deck[$i]['m'] = $fit[mt_rand(0, count($fit) - 1)]; $mods = true; }
        $hp = mt_rand(14, 45);
        $me = ['hp' => $hp, 'max_hp' => $hp + mt_rand(0, 8), 'stats' => $stt, 'deck' => $deck, 'luck' => mt_rand(0, 9)];
        $opt = ['can_pluck' => (bool)mt_rand(0, 1), 'boss_charm' => (bool)mt_rand(0, 1)];
    } else { $p = bsim_player($c['level']); $me = $p['me']; $args = $p['args']; $deck0 = $me['deck']; }
    $s = pfb_new($me, $c, $seed + $c['level'], $opt);
    $rec = ['fight' => $c['slug'], 'mode' => $mode, 'seed' => $seed + $c['level'], 'creature' => $c, 'opt' => $opt, 'me' => $me, 'args' => $args, 'deck0' => $deck0,
        'init' => ['view' => slim(pfb_view($s)), 'state' => noNonce($s)], 'steps' => []];
    $probe = true; $t = 0;
    while (!$s['over'] && $t++ < 40) {
        $q = queries($s); $first = true;
        $emit = function (array $step) use (&$rec, &$q, &$first, &$s, &$na) {
            if ($first) { $step['q'] = $q; $first = false; }
            $step['view'] = slim(pfb_view($s)); $step['dg'] = digest($s); $step['over'] = $s['over']; $step['fx'] = $s['fx'] ?? null; $na++;
            $rec['steps'][] = $step;
        };
        if ($probe) {   // illegal moves: nothing may change
            $probe = false; $tn = $s['turn'];
            foreach ([[[0, 0, 0]], [[0, 2, 2], [0, 2, 2]], [[99, 1, 1]], [['a', 1, 1]], [], [['c', 1, 1]], [['j', 0, 0, 'R']], [['h', 0, 0, 'R']], [['j', 0, 1, 'Z']], [[0, 1]], [[-1, 3, 2]], [['j', 0, 1, 'R', 5]], [[1.5, 1, 1]]] as $bm) {
                $r = pfb_play($s, $bm, $tn); $emit(['op' => 'play', 'moves' => $bm, 'turn' => $tn, 'dry' => false, 'res' => $r]);
            }
            $r = pfb_play($s, [[0, 3, 2]], $tn + 3); $emit(['op' => 'play', 'moves' => [[0, 3, 2]], 'turn' => $tn + 3, 'dry' => false, 'res' => $r]);
        }
        foreach (candidates($s, $mode) as $mv) {
            $tn = $s['turn'];
            if ($mv === null) {
                $r = pfb_pass($s, $tn); $step = ['op' => 'pass', 'turn' => $tn, 'res' => $r]; $pev = $r['ev'] ?? [];   // the creature plays after a pass too: same records as a play
                $step['lines'] = array_map(fn($e) => pfight_line($e, $s['foe']['name']), $pev);
                $step['chips'] = array_map(fn($e, $i) => pfight_chip_event($e, $i), $pev, array_keys($pev));
                $step['chipsb'] = pfight_chips_board($pev); $emit($step);
                if (!$r['err']) break; else continue;
            }
            if (($mode !== 'single' || $tn % 3 === 0) && ($t % 2 === 0 || $mode === 'chaos')) {   // a dry run first: it must not change anything
                $r = pfb_play($s, [$mv], $tn, null, true); $emit(['op' => 'play', 'moves' => [$mv], 'turn' => $tn, 'dry' => true, 'res' => $r]);
            }
            $r = pfb_play($s, [$mv], $tn);
            $step = ['op' => 'play', 'moves' => [$mv], 'turn' => $tn, 'dry' => false, 'res' => $r];
            $step['lines'] = array_map(fn($e) => pfight_line($e, $s['foe']['name']), $r['ev']);
            $step['chips'] = array_map(fn($e, $i) => pfight_chip_event($e, $i), $r['ev'], array_keys($r['ev']));
            $step['chipsb'] = pfight_chips_board($r['ev']);
            $emit($step);
            if (!$r['err']) break;
        }
    }
    $rec['final'] = noNonce($s); $nf++;
    out($rec);
}
out(['done' => true, 'fights' => $nf, 'actions' => $na]);
