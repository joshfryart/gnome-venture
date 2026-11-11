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
/** A competent gnome's box: the Hurt tiles first (up to 5), then Charm (3), Guard (3), a Heal, a Trick, then whatever else fits. */
function smart_box(int $lv, string $cal): array
{
    $own = pf_collection($lv, $cal); $cap = pf_box_capacity($lv);
    $want = ['hurt' => 5, 'charm' => 3, 'guard' => 3, 'heal' => 1, 'trick' => 1, 'item' => 1, 'soothe' => 0];
    $box = []; $n = [];
    foreach ($own as $k) { $t = pf_tiles()[$k]['t']; if (($n[$t] ?? 0) < ($want[$t] ?? 0) && count($box) < $cap) { $box[] = $k; $n[$t] = ($n[$t] ?? 0) + 1; } }
    foreach ($own as $k) if (!in_array($k, $box, true) && count($box) < $cap) $box[] = $k;
    return $box;
}

function sim_player(int $lv, bool $smart = true, bool $mods = false): array
{
    // a real gnome has 4 + (L-1) stat points over 7 stats, 2 points per +1 modifier: about (L+3)/14 on every stat (the old sim gave L/4+1, about 6x too much)
    $m = max(0, intdiv($lv + 3, 14));
    $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $callings = array_keys(PF_CALLING_TILE);
    $cal = $callings[$lv % 6];
    $deck = pf_player_deck($st, $cal, 1 + intdiv($lv, 12), [], [], [], true, $smart ? smart_box($lv, $cal) : pf_box($lv, $cal, null));   // a packed box, or the default (collection in order, up to capacity)
    if ($mods) {   // every other tile carries a random fitting upgrade (deterministic)
        mt_srand($lv * 7 + 1);
        foreach ($deck as $i => $t) if ($i % 2 === 0) { $fit = array_keys(array_filter(PF_MODS, fn($x) => in_array($t['t'], $x[4], true))); $deck[$i]['m'] = $fit[mt_rand(0, count($fit) - 1)]; }
    }
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
$s = $base(['pierce']); $s['foe']['block'] = 100; pf_resolve($s, 'me', [$s['me']['hand'][0]]); $pierced = $s['fh']['now'];
$s = $base(['swing']); $s['foe']['block'] = 100; pf_resolve($s, 'me', [$s['me']['hand'][0]]);
if ($pierced <= 0 || $s['fh']['now'] != 0) { echo "FAIL pierce/guard rule\n"; $bad++; }
// poison ticks twice, trip shortens the next foe chain, quick draws, bash uses the guard
$s = $base(['sting']); pf_resolve($s, 'me', [$s['me']['hand'][0]]);
if ($s['foe']['poison'] !== 2) { echo "FAIL poison not applied\n"; $bad++; }
$n0 = $s['fh']['now']; pf_foe_turn($s, 0); pf_foe_turn($s, 0); pf_foe_turn($s, 0);
if (!($s['fh']['now'] > $n0) || $s['foe']['poison'] !== 0) { echo "FAIL poison did not tick twice and stop\n"; $bad++; }
$s = $base(['trip']); $s['foe']['hand'] = array_slice($s['foe']['draw'], 0, 3); $l0 = pf_foe_len($s, 0); pf_resolve($s, 'me', [$s['me']['hand'][0]]);
if (pf_foe_len($s, 0) !== max(1, $l0 - 1)) { echo "FAIL trip did not shorten the foe chain\n"; $bad++; }
$s = $base(['jab']); $h0 = count($s['me']['hand']); $t = $s['me']['hand'][0]; array_splice($s['me']['hand'], 0, 1); pf_resolve($s, 'me', [$t]);
if (count($s['me']['hand']) !== $h0) { echo "FAIL quick did not draw a tile\n"; $bad++; }
$s = $base(['dodge', 'bash']); pf_resolve($s, 'me', $s['me']['hand']);
$s2 = $base(['hide', 'bash']); pf_resolve($s2, 'me', $s2['me']['hand']);
if ($s['me']['block'] !== 0 || $s['fh']['now'] <= $s2['fh']['now']) { echo "FAIL bash did not spend the guard as damage\n"; $bad++; }
// the puzzle box
foreach ([1 => 8, 3 => 9, 12 => 12, 18 => 14, 60 => 14] as $lv => $cap) if (pf_box_capacity($lv) !== $cap) { echo "FAIL capacity at level $lv\n"; $bad++; }
$own = pf_collection(30, 'thornblade');
if (count(pf_box(30, 'thornblade', null)) !== 14 || count(pf_box(1, '', null)) !== 6) { echo "FAIL default box size\n"; $bad++; }
if (count(pf_box(30, 'thornblade', $own)) !== 14) { echo "FAIL oversize saved box not trimmed\n"; $bad++; }
if (pf_box(1, '', ['smash', 'jab', 'swing', 'dodge', 'rest', 'charm', 'hide', 'snack']) !== PF_BASE_KEYS + [6 => 'x'] && in_array('smash', pf_box(1, '', ['smash', 'jab', 'swing', 'dodge', 'rest', 'charm', 'hide', 'snack']), true)) { echo "FAIL unowned tile in box\n"; $bad++; }
if (pf_box_check(['dodge', 'rest', 'charm', 'hide', 'snack', 'soothe'], 8) === null) { echo "FAIL a box with no Hurt tile was accepted\n"; $bad++; }
if (pf_box_check(['swing', 'dodge'], 8) === null) { echo "FAIL a tiny box was accepted\n"; $bad++; }
if (pf_box_check(array_slice($own, 0, 14), 8) === null) { echo "FAIL an overfull box was accepted\n"; $bad++; }
// upgrades must not run away with the game: every other tile upgraded, compare the greedy bot's pace with and without
$run = function (bool $mods) use ($rows, $bots) { $t = 0; $n = 0; $loss = 0;
    foreach ($rows as $c) foreach ([11, 22] as $seed) { $me = sim_player($c['level'], true, $mods); $s = pf_new($me, $c, $seed + $c['level']); $k = 0;
        while (!$s['over'] && $k++ < 60) { $mv = $bots['greedy']($s); $hv = array_values(array_filter($mv, fn($i) => ($s['me']['hand'][$i]['tag'] ?? '') === 'heavy' && ($s['me']['hand'][$i]['m'] ?? '') !== 'steady')); if ($hv) $mv = [...array_values(array_diff($mv, $hv)), $hv[0]]; $r = pf_play($s, $mv, $s['turn']); if ($r['err']) break; }
        $t += $s['turn']; $n++; $loss += $s['over'] === 'defeat'; }
    return [$t / $n, $loss / $n]; };
[$t0, $l0] = $run(false); [$t1, $l1] = $run(true);
printf("upgrades: avg turns %.2f -> %.2f, defeats %.0f%% -> %.0f%%\n", $t0, $t1, $l0 * 100, $l1 * 100);
if ($t1 < $t0 * 0.75) { echo "FAIL upgrades make fights more than 25% faster\n"; $bad++; }
// the new tile tags and upgrades
$mkc = ['slug' => 'x', 'size' => 'medium', 'level' => 5, 'dmg_die' => 6, 'dmg_bonus' => 0, 'temper' => 'hostile'];
$st0 = ['level' => 1];
$new = function (array $hand, array $opt = [], int $luck = 0) use ($mkc, $st0) { $s = pf_new(['hp' => 50, 'max_hp' => 99, 'stats' => $st0, 'deck' => pf_player_deck($st0), 'luck' => $luck], $mkc, 3, $opt);
    $s['me']['hand'] = array_map(fn($k) => pf_make_tile($k, $st0), $hand); $s['me']['draw'] = array_map(fn($k) => pf_make_tile($k, $st0), ['swing', 'swing', 'swing', 'swing']); return $s; };
$res = function (array &$s, array $idx) { return pf_resolve($s, 'me', array_map(fn($i) => $s['me']['hand'][$i], $idx)); };
$s = $new(['brace']); $res($s, [0]); pf_resolve($s, 'me', [pf_make_tile('swing', $st0)]);
if ($s['me']['block'] < 3) { echo "FAIL Hold guard did not carry over\n"; $bad++; }
$s = $new(['roll']); $res($s, [0]); $hp = $s['me']['hp']; pf_resolve($s, 'foe', [['k' => 'f', 'n' => 'F', 't' => 'hurt', 'v' => 9, 'r' => null, 'tag' => '', 'm' => '']]);
if ($s['me']['hp'] !== $hp) { echo "FAIL Roll did not dodge the first Hurt\n"; $bad++; }
$s = $new(['thornhide']); $res($s, [0]); $b0 = $s['fh']['now']; pf_resolve($s, 'foe', [['k' => 'f', 'n' => 'F', 't' => 'hurt', 'v' => 2, 'r' => null, 'tag' => '', 'm' => '']]);
if ($s['fh']['now'] <= $b0) { echo "FAIL Thorn Hide did not prick\n"; $bad++; }
$s = $new(['mending']); $hp = $s['me']['hp']; $res($s, [0]); if ($s['me']['hp'] !== $hp + 2) { echo "FAIL Mending did not heal 2\n"; $bad++; }
$s = $new(['hum']); $res($s, [0]); if ($s['foe']['agg'] < 2) { echo "FAIL Hum did not calm\n"; $bad++; }
$s = $new(['lull']); $l0 = pf_foe_len($s, 0); $res($s, [0]); if (pf_foe_len($s, 0) !== max(1, $l0 - 1)) { echo "FAIL Lull did not slow the foe\n"; $bad++; }
$s = $new(['bond', 'bond']); $c0 = $s['cm']; $res($s, [0]); if ($s['cm'] <= $c0) { echo "FAIL Bond did not warm the creature\n"; $bad++; }
// upgrades
$s = $new(['swing']); $s['me']['hand'][0]['m'] = 'hardy'; $t = $s['me']['hand'][0]; $t['t'] = 'guard'; $t['tag'] = ''; pf_resolve($s, 'me', [$t]); if ($s['me']['block'] < 6) { echo "FAIL Hardy\n"; $bad++; }
$s = $new(['swing']); $t = $s['me']['hand'][0]; $t['m'] = 'leech'; $s['me']['hp'] = 10; pf_resolve($s, 'me', [$t]); if ($s['me']['hp'] <= 10) { echo "FAIL Leech\n"; $bad++; }
$s = $new(['swing']); $t = $s['me']['hand'][0]; $t['m'] = 'warm'; pf_resolve($s, 'me', [$t]); if ($s['bar']['charm'] <= 0) { echo "FAIL Warm\n"; $bad++; }
$s = $new(['swing']); $t = $s['me']['hand'][0]; $t['m'] = 'finisher'; $s['fh']['now'] = 0.7 * $s['fh']['max']; $a0 = $s['fh']['now']; pf_resolve($s, 'me', [$t]); $with = $s['fh']['now'] - $a0;
$s = $new(['swing']); $t = $s['me']['hand'][0]; $s['fh']['now'] = 0.7 * $s['fh']['max']; $a0 = $s['fh']['now']; pf_resolve($s, 'me', [$t]); if ($with <= $s['fh']['now'] - $a0) { echo "FAIL Finisher\n"; $bad++; }
$s = $new(['swing', 'swing']); $x = $s['me']['hand'][0]; $x['m'] = 'swift'; $y = [$s['me']['hand'][1], $s['me']['hand'][1], $s['me']['hand'][1]]; $s['me']['hand'] = [$x, ...$y]; $b = $s['foe']['hand']; pf_play($s, [0, 1, 2, 3], 1);
$s2 = $new(['swing', 'swing', 'swing', 'swing']); $b2 = count($s2['foe']['hand']); pf_play($s2, [0, 1, 2, 3], 1);
if (count($s['log']) && $s['log'][0]['n'] !== 4) { echo "FAIL log\n"; $bad++; }
$s = $new(['smash', 'swing']); $s['me']['hand'][0]['m'] = 'steady'; $r = pf_play($s, [0, 1], 1); if ($r['err'] !== null) { echo "FAIL Steady should lift the heavy rule: {$r['err']}\n"; $bad++; }
// Pluck: a low chance that Luck raises, once per fight, nothing to take = nothing happens
foreach ([0 => [4, 12], 5 => [18, 30]] as $luck => [$lo, $hi]) {
    $got = 0; $N = 3000;
    for ($i = 0; $i < $N; $i++) { $s = $new(['pluck'], ['can_pluck' => true], $luck); $s['rng'] = 1000 + $i * 7919; $e = $res($s, [0]); if (($e[0]['pluck'] ?? '') === 'got') $got++; }
    $pct = 100 * $got / $N;
    if ($pct < $lo || $pct > $hi) { printf("FAIL Pluck at luck %d: %.1f%% (want %d-%d%%)\n", $luck, $pct, $lo, $hi); $bad++; }
}
$s = $new(['pluck'], ['can_pluck' => false]); $e = $res($s, [0]); if (($e[0]['pluck'] ?? '') !== 'none') { echo "FAIL Pluck with nothing to take\n"; $bad++; }
$s = $new(['pluck', 'pluck'], ['can_pluck' => true], 40); $s['plucked'] = 1; $e = $res($s, [0]); if (($e[0]['pluck'] ?? '') !== 'none') { echo "FAIL a second Pluck in one fight\n"; $bad++; }
// determinism: same seed, same moves, same result
$a = pf_new(sim_player(5), $rows[3], 99); $b = pf_new(sim_player(5), $rows[3], 99);
pf_play($a, [0, 1], 1); pf_play($b, [0, 1], 1);
unset($a['nonce'], $b['nonce']);   // the nonce is random on purpose
if (json_encode($a) !== json_encode($b)) { echo "FAIL seeded fight not deterministic\n"; $bad++; }
// stale turn ignored, view hides draw and foe hand
$r = pf_play($a, [0], 1); if ($r['err'] !== 'stale') { echo "FAIL stale turn accepted\n"; $bad++; }
$v = json_encode(pf_view($a)); $pv = pf_view($a);   // counts only: never the draw pile's tiles, the foe's hand, the seed or the nonce
if (str_contains($v, '"rng"') || str_contains($v, '"nonce"') || !is_int($pv['foe']['hand']) || !is_int($pv['piles']['draw']) || !is_int($pv['piles']['discard'])) { echo "FAIL view leaks\n"; $bad++; }
foreach ($rows as $c) if (!isset(PF_GIFT[$c['slug']])) { echo "FAIL no charm gift authored for {$c['slug']}\n"; $bad++; }
$bl = pf_player_deck(['charm' => 2, 'level' => 1], 'bloomcaller'); $plain = pf_player_deck(['charm' => 2, 'level' => 1], 'rootwarden');
if ($bl[3]['v'] <= $plain[3]['v']) { echo "FAIL Bloomcaller Charm not bigger\n"; $bad++; }
echo $bad ? "$bad FAILED\n" : "ok: " . count($rows) . " creatures\n";
exit($bad ? 1 : 0);
