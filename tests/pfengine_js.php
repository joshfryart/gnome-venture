<?php
// Emits PHP board-engine traces for tests/pfengine_js.js (the JS port tools/pfengine.js must reproduce every line).
// One JSON line per record: a header (tile library, PHP round() and crc32 samples, extra deck builds), then one line per fight with
// every action (dry runs, bad moves, passes, plays) and, after each, the events, the view and a digest of the hidden state.
// The bots mirror tests/pfboard_sim.php (bsim_act, 'single' and 'builder'), plus a 'chaos' bot that plays random legal and
// illegal moves with random tile boxes, upgrades and options, so every tile tag and upgrade is exercised.
require_once __DIR__ . '/../game/includes/pfboard.php';
require_once __DIR__ . '/../game/includes/pfight_game.php';
require_once __DIR__ . '/../game/includes/pfdeck.php';   // 2.6.74 stage B: the deck model (mode v1d)
require_once __DIR__ . '/pfboard_tune_v1.php';   // tv_sources: a typical gnome's deck sources by level

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
    if (!empty($s['v1'])) {   // the v1 board rules: flip, the lit-cell numbers (own chain only), as dealt and flipped
        $q['canflip'] = array_map(fn($i) => pfb_can_flip($s, $i), array_keys($s['me']['hand']));
        $q['cp'] = array_map(fn($i) => [(object)pfb_cell_preview($s, $i), (object)pfb_cell_preview($s, $i, true)], array_keys($s['me']['hand']));
        if ($g) $q['cpc'] = (object)pfb_cell_preview($s, 'c');
    }
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
// 'blank' = the blank-centre variant (opt blank + a hidden start), played by the single bot. 2.6.74: 'v1' = the v1 board rules with the blank opening (single bot, flips when stuck);
// 'v1b' = v1 with the builder bot and made-up sources (Teamwork); 'v1chaos' = v1 with random moves, random flips and random rule switches
foreach ($rows as $ci => $c) foreach ([['single', 11], ['builder', 22], ['chaos', 33], ['blank', 44], ['v1', 55], ['v1b', 66], ['v1chaos', 77], ['v1d', 88]] as [$mode0, $seed]) {   // 'v1d' (stage B) = v1 with the deck model: the layered creature deck (class base 4 + region + size extras + 3 unique, creature tags) against a deck-model deck (tool pieces wear)
    mt_srand($seed * 1000 + $ci);
    $v1 = str_starts_with($mode0, 'v1'); $mode = ['v1' => 'blank', 'v1b' => 'builder', 'v1chaos' => 'chaos', 'v1d' => 'blank'][$mode0] ?? $mode0;
    if ($v1 && $mode0 !== 'v1' && $mode0 !== 'v1d' && ($ci + ($mode0 === 'v1b' ? 0 : 1)) % 2) continue;   // half the creatures each, to keep the run short
    $opt = $mode === 'blank' ? ['blank' => true] : []; $mods = false;
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
    if ($mode0 === 'v1d') {
        $src = tv_sources($c['level']); $me['deck'] = pfd_tiles(pfd_fight_entries($src), $me['stats'], [], $src['calling'], $src['ctier']);
        $c = pfd_foe_row($c, array_keys(pfd_region_pieces())[$ci % 14]);
    }
    if ($v1) {
        $opt['v1'] = true;
        if ($mode0 === 'v1chaos') {
            $opt['v1'] = [['events' => 0], ['ground' => 0], ['limit' => 0], ['limit' => 4, 'foe_x' => 1.3], ['aim' => 0], ['edges' => 0], ['flip' => 0, 'life' => 0], ['nev' => 3, 'thorn' => 0.3, 'bramble' => 0.25], ['team2' => 2, 'team3' => 3, 'bar_x' => 0.8], true][mt_rand(0, 9)];
            if (mt_rand(0, 1)) $opt['blank'] = true;
        }
        if ($mode0 !== 'v1' && $mode0 !== 'v1d') foreach ($me['deck'] as $i => $t) { $me['deck'][$i]['src'] = ['pal', 'tool', 'crop', 'craft', 'region'][($i + $ci) % 5]; if ($i % 4 === 0) $me['deck'][$i]['life'] = 2 + ($i + $ci) % 3; if ($i % 7 === 3) $me['deck'][$i]['edges'] = false; if ($i % 7 === 5) { $me['deck'][$i]['col'] = 'mind'; $me['deck'][$i]['up'] = false; } }
        if ($ci % 3 === 0 && $mode0 !== 'v1d') $c['class'] = ['Critter', 'Water', 'Bird', 'Plant / Fungus', 'Reptile / Amphibian', 'Beast'][$ci % 6];
    }
    $s = pfb_new($me, $c, $seed + $c['level'], $opt);
    $rec = ['fight' => $c['slug'], 'mode' => $mode0, 'seed' => $seed + $c['level'], 'creature' => $c, 'opt' => $opt, 'me' => $me, 'args' => $args, 'deck0' => $deck0,
        'init' => ['view' => slim(pfb_view($s)), 'state' => noNonce($s)], 'steps' => []];
    if ($mode === 'blank') {   // before the start piece is picked nothing else may happen; bad starts refuse; then the hidden start itself
        $tn = $s['turn'];
        foreach ([['op' => 'play', 'moves' => [[0, 3, 1]]], ['op' => 'pass']] as $bs) {
            $r = $bs['op'] === 'pass' ? pfb_pass($s, $tn) : pfb_play($s, $bs['moves'], $tn);
            $rec['steps'][] = array_merge($bs, ['turn' => $tn, 'dry' => false, 'res' => $r, 'view' => slim(pfb_view($s)), 'dg' => digest($s), 'over' => $s['over'], 'fx' => $s['fx'] ?? null]); $na++;
        }
        foreach ([[0, 'Z'], [99, 'L'], [-1, 'R'], [0, 'l']] as [$bi, $bsd]) { $e = pfb_start($s, $bi, $bsd); $rec['steps'][] = ['op' => 'start', 'hand' => $bi, 'side' => $bsd, 'turn' => $tn, 'res' => ['err' => $e], 'view' => slim(pfb_view($s)), 'dg' => digest($s), 'over' => $s['over'], 'fx' => null]; $na++; }
        $hi = mt_rand(0, count($s['me']['hand']) - 1); $sd = ['L', 'R', 'T', 'B'][mt_rand(0, 3)];
        $e = pfb_start($s, $hi, $sd); $rec['steps'][] = ['op' => 'start', 'hand' => $hi, 'side' => $sd, 'turn' => $tn, 'res' => ['err' => $e], 'view' => slim(pfb_view($s)), 'dg' => digest($s), 'over' => $s['over'], 'fx' => null]; $na++;
        $e = pfb_start($s, 0, 'L'); $rec['steps'][] = ['op' => 'start', 'hand' => 0, 'side' => 'L', 'turn' => $tn, 'res' => ['err' => $e], 'view' => slim(pfb_view($s)), 'dg' => digest($s), 'over' => $s['over'], 'fx' => null]; $na++;
    }
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
        if ($v1) {   // flips: a random one now and then (also a second, refused one, and flipping back), and one that unsticks a hand that only fits flipped
            $tn = $s['turn']; $nh = count($s['me']['hand']);
            $fl = function (int $i) use (&$s, &$emit, $tn) { $e = pfb_flip($s, $i, $tn); $emit(['op' => 'flip', 'hand' => $i, 'turn' => $tn, 'res' => ['err' => $e]]); return $e; };
            if ($mode0 === 'v1chaos' && $nh && mt_rand(0, 3) === 0) { $fl(mt_rand(0, $nh)); if (mt_rand(0, 1)) $fl(mt_rand(0, $nh - 1)); }
            if (!pfb_search($s, 'me')) foreach (array_keys($s['me']['hand']) as $i) { if (!pfb_can_flip($s, $i)) continue; if ($fl($i)) continue; if (pfb_search($s, 'me')) break; $fl($i); }
            if ($mode0 === 'v1chaos' && $nh && mt_rand(0, 5) === 0) { $dr = (bool)mt_rand(0, 1); $r = pfb_play($s, [['f', 0]], $tn, null, $dr); $emit(['op' => 'play', 'moves' => [['f', 0]], 'turn' => $tn, 'dry' => $dr, 'res' => $r]); }
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
