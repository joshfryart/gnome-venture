<?php
// Puzzle Combat bot sim (no DB): php tests/pfight_sim.php [--quiet]. Every creature in creatures.txt x 4 bots x seeds.
// Checks invariants (tile conservation, a legal move always exists, every fight ends within the turn cap) and prints pace/win tables.
require __DIR__ . '/../game/includes/pfight.php';
$quiet = in_array('--quiet', $argv, true);
$rows = [];
$sizeMult = ['small' => 0.8, 'medium' => 1.1, 'large' => 1.6, 'boss' => 2.4]; $die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10];
foreach (file(__DIR__ . '/../game/includes/data/creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue;
    $c = explode('|', $l); if (count($c) < 7) continue;
    $lv = max(1, (int)$c[4]);
    $rows[] = ['slug' => $c[0], 'name' => $c[1], 'size' => $c[2], 'level' => $lv, 'dmg_die' => $die[$c[2]] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
}
function sim_player(int $lv): array
{
    // a real gnome has 4 + (L-1) stat points over 7 stats, 2 points per +1 modifier: about (L+3)/14 on every stat (the old sim gave L/4+1, about 6x too much)
    $m = max(0, intdiv($lv + 3, 14));
    $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $callings = array_keys(PF_CALLING_TILE);
    $cal = $callings[$lv % 6];
    $deck = pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, pf_box($lv, $cal, null));   // the default puzzle box: collection in order, up to capacity
    $max = 20 + 3 * $lv + 5 * $m;
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => $deck, 'luck' => $m];
}
// bots: each returns a hand index list
$bots = [
    'greedy' => function ($s) { $h = $s['me']['hand']; $best = null; $bv = -1;
        $try = function ($chosen, $used) use (&$try, &$best, &$bv, $h, $s) {
            if ($chosen) { $prev = $s['strip'] ? $s['strip'][count($s['strip']) - 1]['tile'] : null; $v = 0;
                foreach ($chosen as $i) { [$x] = pf_value($prev, $h[$i]); $w = in_array($h[$i]['t'], ['hurt', 'charm'], true) ? 1 : 0.3; $v += $x * $w; $prev = $h[$i]; }
                if ($v > $bv) { $bv = $v; $best = $chosen; } }
            if (count($chosen) < 3) foreach (array_keys($h) as $i) if (!in_array($i, $used, true)) $try([...$chosen, $i], [...$used, $i]); };
        $try([], []); return $best ?: [0]; },
    'always4' => fn($s) => array_slice(array_keys($s['me']['hand']), 0, 4),
    'charm' => function ($s) { $h = $s['me']['hand']; $o = []; foreach ($h as $i => $t) if (in_array($t['t'], ['charm', 'soothe', 'heal', 'item'], true)) $o[] = $i; return $o ? array_slice($o, 0, 3) : [0]; },
    'stall' => function ($s) { $h = $s['me']['hand']; foreach ($h as $i => $t) if ($t['t'] === 'guard') return [$i]; return [0]; },
];
$bad = 0; $tbl = [];
foreach ($rows as $c) {
    foreach ($bots as $bn => $bot) {
        foreach ([11, 22, 33] as $seed) {
            $me = sim_player($c['level']);
            $s = pf_new($me, $c, $seed + $c['level']);
            $total = count($me['deck']);
            $t = 0;
            while (!$s['over'] && $t++ < 60) {
                $mv = $bot($s);
                $hv = array_values(array_filter($mv, fn($i) => ($s['me']['hand'][$i]['tag'] ?? '') === 'heavy'));   // bots obey the rule: one heavy tile, last
                if ($hv) $mv = [...array_values(array_diff($mv, $hv)), $hv[0]];
                if ($s['me']['hand'] === []) { echo "FAIL no legal move: {$c['slug']} $bn turn {$s['turn']}\n"; $bad++; break; }
                $r = pf_play($s, $mv, $s['turn']);
                if ($r['err']) { echo "FAIL illegal bot move {$c['slug']} $bn: {$r['err']}\n"; $bad++; break; }
                $n = count($s['me']['hand']) + count($s['me']['draw']) + count($s['me']['discard']);
                if ($n !== $total) { echo "FAIL tile conservation {$c['slug']} $bn: $n vs $total\n"; $bad++; break; }
            }
            if (!$s['over']) { echo "FAIL fight did not end: {$c['slug']} $bn\n"; $bad++; }
            $tbl[$c['size']][$bn][] = [$s['over'], $s['turn']];
        }
    }
}
if (!$quiet) foreach ($tbl as $size => $byBot) foreach ($byBot as $bn => $res) {
    $cnt = array_count_values(array_column($res, 0)); ksort($cnt);
    printf("%-7s %-8s n=%-3d avg turns %.1f  %s\n", $size, $bn, count($res), array_sum(array_column($res, 1)) / count($res), json_encode($cnt));
}
$bounds = ['small' => [1.5, 4.5], 'medium' => [2.0, 6.0], 'large' => [3.0, 7.5], 'boss' => [4.0, 11.0]];
foreach ($bounds as $size => [$lo, $hi]) {
    $res = $tbl[$size]['greedy'] ?? []; if (!$res) continue;
    $avg = array_sum(array_column($res, 1)) / count($res);
    if ($avg < $lo || $avg > $hi) { printf("FAIL pace: %s greedy avg %.1f turns, want %.1f to %.1f\n", $size, $avg, $lo, $hi); $bad++; }
    $lost = count(array_filter($res, fn($r) => $r[0] === 'defeat')) / count($res);
    if ($lost > 0.35) { printf("FAIL %s greedy defeat rate %.0f%%\n", $size, $lost * 100); $bad++; }
}
$d = pf_player_deck(['level' => 1], '', 1, [], [], [], false);
if (in_array('item', array_column($d, 't'), true) || !in_array('Breather', array_column($d, 'n'), true)) { echo "FAIL no-snack deck should hold a Breather and no item tile\n"; $bad++; }
// a pal must never take the last Hurt tile
$d = pf_player_deck(['level' => 1], '', 1, [['swap' => 'swing', 'n' => 'Shield Pal', 't' => 'guard', 'v' => 5, 'r' => null]]);
if (!in_array('hurt', array_column($d, 't'), true)) { echo "FAIL a guard pal replaced the only Hurt tile\n"; $bad++; }
// the foe's Hurt does not get a combo from my Guard/Trick (combos chain off your own tiles only)
$st = ['level' => 1, 'grit' => 0]; $s = pf_new(['hp' => 99, 'max_hp' => 99, 'stats' => $st, 'deck' => pf_player_deck($st), 'luck' => 0], ['slug' => 'x', 'size' => 'small', 'level' => 1, 'dmg_die' => 4, 'dmg_bonus' => 0], 5);
[$g, $h] = [['k' => 'g', 'n' => 'G', 't' => 'guard', 'v' => 4, 'r' => 'body', 'tag' => ''], ['k' => 'h', 'n' => 'H', 't' => 'hurt', 'v' => 6, 'r' => 'mind', 'tag' => '']];
[$v, , $ck] = pf_value($g, $h, false);
if ($ck !== null) { echo "FAIL seam combo given to the other side\n"; $bad++; }
[, , $ck2] = pf_value($g, $h, true);
if ($ck2 !== 'guard>hurt') { echo "FAIL own combo missing\n"; $bad++; }
// the new Hurt tactics
$mkc = ['slug' => 'x', 'size' => 'medium', 'level' => 5, 'dmg_die' => 6, 'dmg_bonus' => 0, 'temper' => 'hostile'];
$mkst = ['level' => 1];
$base = function (array $hand) use ($mkc, $mkst) { $s = pf_new(['hp' => 99, 'max_hp' => 99, 'stats' => $mkst, 'deck' => pf_player_deck($mkst), 'luck' => 0], $mkc, 3);
    $s['me']['hand'] = array_map(fn($k) => pf_make_tile($k, $mkst), $hand); $s['me']['draw'] = array_map(fn($k) => pf_make_tile($k, $mkst), ['swing', 'swing', 'swing']); return $s; };
// heavy only last
$s = $base(['smash', 'swing']); $r = pf_play($s, [0, 1], 1);
if ($r['err'] === null) { echo "FAIL heavy tile played before the end of a chain\n"; $bad++; }
$s = $base(['swing', 'smash']); $r = pf_play($s, [0, 1], 1);
if ($r['err'] !== null) { echo "FAIL heavy tile last was refused: {$r['err']}\n"; $bad++; }
// pierce ignores guard, plain hurt does not
$s = $base(['pierce']); $s['foe']['block'] = 100; pf_resolve($s, 'me', [$s['me']['hand'][0]]); $pierced = $s['bar']['now'];
$s = $base(['swing']); $s['foe']['block'] = 100; pf_resolve($s, 'me', [$s['me']['hand'][0]]);
if ($pierced <= 0 || $s['bar']['now'] != 0) { echo "FAIL pierce/guard rule\n"; $bad++; }
// poison ticks twice, trip shortens the next foe chain, quick draws, bash uses the guard
$s = $base(['sting']); pf_resolve($s, 'me', [$s['me']['hand'][0]]);
if ($s['foe']['poison'] !== 2) { echo "FAIL poison not applied\n"; $bad++; }
$n0 = $s['bar']['now']; pf_foe_turn($s, 0); pf_foe_turn($s, 0); pf_foe_turn($s, 0);
if (!($s['bar']['now'] > $n0) || $s['foe']['poison'] !== 0) { echo "FAIL poison did not tick twice and stop\n"; $bad++; }
$s = $base(['trip']); $s['foe']['hand'] = array_slice($s['foe']['draw'], 0, 3); $l0 = pf_foe_len($s, 0); pf_resolve($s, 'me', [$s['me']['hand'][0]]);
if (pf_foe_len($s, 0) !== max(1, $l0 - 1)) { echo "FAIL trip did not shorten the foe chain\n"; $bad++; }
$s = $base(['jab']); $h0 = count($s['me']['hand']); $t = $s['me']['hand'][0]; array_splice($s['me']['hand'], 0, 1); pf_resolve($s, 'me', [$t]);
if (count($s['me']['hand']) !== $h0) { echo "FAIL quick did not draw a tile\n"; $bad++; }
$s = $base(['dodge', 'bash']); pf_resolve($s, 'me', $s['me']['hand']);
$s2 = $base(['hide', 'bash']); pf_resolve($s2, 'me', $s2['me']['hand']);
if ($s['me']['block'] !== 0 || $s['bar']['now'] <= $s2['bar']['now']) { echo "FAIL bash did not spend the guard as damage\n"; $bad++; }
// the puzzle box
foreach ([1 => 8, 3 => 9, 12 => 12, 18 => 14, 60 => 14] as $lv => $cap) if (pf_box_capacity($lv) !== $cap) { echo "FAIL capacity at level $lv\n"; $bad++; }
$own = pf_collection(30, 'thornblade');
if (count(pf_box(30, 'thornblade', null)) !== 14 || count(pf_box(1, '', null)) !== 6) { echo "FAIL default box size\n"; $bad++; }
if (count(pf_box(30, 'thornblade', $own)) !== 14) { echo "FAIL oversize saved box not trimmed\n"; $bad++; }
if (pf_box(1, '', ['smash', 'jab', 'swing', 'dodge', 'rest', 'charm', 'hide', 'snack']) !== PF_BASE_KEYS + [6 => 'x'] && in_array('smash', pf_box(1, '', ['smash', 'jab', 'swing', 'dodge', 'rest', 'charm', 'hide', 'snack']), true)) { echo "FAIL unowned tile in box\n"; $bad++; }
if (pf_box_check(['dodge', 'rest', 'charm', 'hide', 'snack', 'soothe'], 8) === null) { echo "FAIL a box with no Hurt tile was accepted\n"; $bad++; }
if (pf_box_check(['swing', 'dodge'], 8) === null) { echo "FAIL a tiny box was accepted\n"; $bad++; }
if (pf_box_check(array_slice($own, 0, 14), 8) === null) { echo "FAIL an overfull box was accepted\n"; $bad++; }
// determinism: same seed, same moves, same result
$a = pf_new(sim_player(5), $rows[3], 99); $b = pf_new(sim_player(5), $rows[3], 99);
pf_play($a, [0, 1], 1); pf_play($b, [0, 1], 1);
unset($a['nonce'], $b['nonce']);   // the nonce is random on purpose
if (json_encode($a) !== json_encode($b)) { echo "FAIL seeded fight not deterministic\n"; $bad++; }
// stale turn ignored, view hides draw and foe hand
$r = pf_play($a, [0], 1); if ($r['err'] !== 'stale') { echo "FAIL stale turn accepted\n"; $bad++; }
$v = json_encode(pf_view($a)); if (str_contains($v, '"draw"') || !is_int(pf_view($a)['foe']['hand'])) { echo "FAIL view leaks\n"; $bad++; }
foreach ($rows as $c) if (!isset(PF_GIFT[$c['slug']])) { echo "FAIL no charm gift authored for {$c['slug']}\n"; $bad++; }
$bl = pf_player_deck(['charm' => 2, 'level' => 1], 'bloomcaller'); $plain = pf_player_deck(['charm' => 2, 'level' => 1], 'rootwarden');
if ($bl[3]['v'] <= $plain[3]['v']) { echo "FAIL Bloomcaller Charm not bigger\n"; $bad++; }
echo $bad ? "$bad FAILED\n" : "ok: " . count($rows) . " creatures\n";
exit($bad ? 1 : 0);
