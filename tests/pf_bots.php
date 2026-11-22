<?php
// 2.7.10 playtest bots + edge cases for the v1 board rules, on the REAL engine and every creature in data/creatures.txt (no DB).
//   php tests/pf_bots.php [BOTS=all] [OFFSETS=0] [SEEDS=1] [BUILDS=std] [SHARD/NSHARDS=0/1] [json]
//   BOTS: comma list of chain, look, random, greedy, defensive, charm, newbie, or all (the last 5 are new in 2.7.10; chain and look are the tuner's)
//   BUILDS: comma list of std (the tuner's typical gnome), pals (pal-heavy: 4 pals, no belt tools), norare (nothing above Uncommon: Rare / Masterwork pieces left out)
//   OFFSETS: gnome level minus creature level (e.g. -8,-4,0,4,8).  SEEDS: fights per creature, bot, build and offset.
//   env V1='{"firex":0}' = pfb_v1_cfg overrides for every fight (a rule off, a number changed)
//   php tests/pf_bots.php edge      the edge cases (empty deck, tiny and huge boards, level mismatch +/-8, every size and ability, aim re-roll): exit 1 on any broken invariant
//   php tests/pf_bots.php agg < json lines of several shards   the report: win rate and turns by bot, build, size and offset, plus the creatures furthest from the target
// The bots mirror a kind of player, not a solver: random (any legal placement), greedy (most damage and charm this turn), defensive (guard and health first), charm (only the charm bar),
// newbie (the chain bot that plays a random move 30% of the time and never flips), plus the tuner's chain (always the longest chain) and look (best state after the whole round).
require_once __DIR__ . '/pfboard_tune_v1.php';

const PB_BOTS = ['chain', 'look', 'random', 'greedy', 'defensive', 'charm', 'newbie'];
const PB_BUILDS = ['std', 'pals', 'norare'];

/** A gnome of level $lv with a build: std = the tuner's gnome; pals = four pals and no belt tools; norare = no piece above rank 2. */
function pb_player(int $lv, string $build): array
{
    if ($build === 'std') return tv_player($lv);
    $m = max(0, intdiv($lv + 3, 14));
    $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv]; $max = 20 + 3 * $lv + 5 * $m; $src = tv_sources($lv);
    if ($build === 'pals') {
        $src['tools'] = []; $src['belt'] = [];
        $names = [['Bark Badger', 'guard', 'craft'], ['Samara Spin', 'hurt', 'body'], ['Moss Mole', 'charm', 'body'], ['Dew Wren', 'hurt', 'craft']];
        $src['pals'] = []; foreach ($names as $i => [$n, $t, $r]) $src['pals'][] = ['n' => $n, 't' => $t, 'v' => 5 + intdiv($lv, 6), 'r' => $r, 'rank' => min(3, 1 + intdiv($lv, 12))];
    }
    $ent = pfd_fight_entries($src);
    if ($build === 'norare') $ent = array_values(array_filter($ent, fn($e) => (int)($e['rank'] ?? 0) <= 2));
    $deck = pfd_tiles($ent, $st, [], $src['calling'], $src['ctier']);
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => $deck, 'luck' => $m];
}

/** One placement for $bot. [handIdx | 'c' | 'j' | 'h', x, y, flip] or ['pass']. $rng: a mt_rand-seeded closure for the random bots. */
function pb_choose(array $s, string $bot, array $pl, callable $rng): array
{
    if ($bot === 'chain' || $bot === 'look') return tv_choose($s, $bot, $pl);
    if (!$pl) return ['pass'];
    if ($bot === 'random') return $pl[$rng(count($pl))];
    if ($bot === 'newbie') {
        if ($rng(100) < 30) return $pl[$rng(count($pl))];   // a slip: any legal move
        $nf = array_values(array_filter($pl, fn($a) => empty($a[3])));   // no flipping
        return tv_choose($s, 'chain', $nf ?: $pl);
    }
    $best = null; $bs = -1e9;
    foreach ($pl as $a) {
        [$w] = tv_dry($s, $a);
        $dmg = ($w['fh']['now'] - $s['fh']['now']) + ($w['bar']['now'] - $s['bar']['now']);
        $score = match ($bot) {
            'greedy' => $dmg + ($w['over'] && $w['over'] !== 'defeat' ? 1e6 : 0),
            'defensive' => ($w['me']['hp'] - $s['me']['hp']) * 2 + ($w['me']['block'] - $s['me']['block']) + 0.2 * $dmg,
            'charm' => ($w['bar']['charm'] ?? 0) - ($s['bar']['charm'] ?? 0) + 0.05 * $dmg,
            default => 0.0,
        };
        if ($score > $bs + 1e-9) { $bs = $score; $best = $a; }
    }
    return $best ?? ['pass'];
}

/** Play one fight. Returns the result row; never throws (an engine error is reported as 'err'). */
function pb_fight(array $c, int $lv, string $bot, string $build, int $seed, array $v1 = [], ?array $player = null): array
{
    mt_srand($seed); $rng = fn(int $n) => $n > 0 ? mt_rand(0, $n - 1) : 0;
    try {
        $cr = pfd_foe_row($c, array_keys(pfd_region_pieces())[(crc32($c['slug']) + $seed) % 14]);
        $s = pfb_new($player ?? pb_player($lv, $build), $cr, $seed, ['blank' => true, 'v1' => $v1 ?: true]);
        $hand = $s['me']['hand'];
        if ($hand) { $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i; pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$seed % 4]); }
        $t = 0; $pass = 0;
        while (!$s['over'] && $t++ < 40) {
            $pl = tv_places($s); $a = pb_choose($s, $bot, $pl, $rng);
            if ($a[0] === 'pass') $pass++;
            $r = tv_act($s, $a);
            if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { if (!$pl) break; $r = tv_act($s, $pl[0]); if ($r['err']) break; } }
        }
        return ['win' => in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0, 'turns' => (int)$s['turn'], 'hp' => 1 - max(0, $s['me']['hp']) / max(1, $s['me']['max']), 'cap' => (int)($s['over'] === 'stall' || $t > 40), 'pass' => $pass, 'over' => (string)$s['over']];
    } catch (Throwable $e) {
        return ['win' => 0, 'turns' => 0, 'hp' => 0, 'cap' => 0, 'pass' => 0, 'over' => 'err', 'err' => get_class($e) . ': ' . $e->getMessage()];
    }
}

function pb_edge(): int
{
    $bad = 0; $ok = function (string $n, bool $c, $x = '') use (&$bad) { echo ($c ? '  ok   ' : '  FAIL ') . $n . ($c ? '' : '  ' . (is_string($x) ? $x : json_encode($x))) . "\n"; if (!$c) $bad++; };
    $cr = tv_creatures(); $by = []; foreach ($cr as $c) $by[$c['size']][] = $c;
    $fin = fn(array $r) => $r['over'] !== 'err' && $r['over'] !== '' && $r['turns'] > 0;
    echo "== the playing board by creature size (2.7.55, Josh: small 3x3, medium 4x4, large and boss 5x5; 4x4 for every size 2.6.94-2.7.54)\n";
    foreach (['small' => 3, 'medium' => 4, 'large' => 5, 'boss' => 5] as $sz => $n) { $cf = pfb_v1_cfg($sz); $ok("$sz board is {$n}x{$n}", $cf['w'] === $n && $cf['h'] === $n, [$cf['w'], $cf['h']]); }
    echo "== level mismatch +/-8: every size, every bot finishes\n";
    foreach (['small', 'medium', 'large', 'boss'] as $sz) foreach ([-8, 8] as $d) foreach (PB_BOTS as $b) {
        $c = $by[$sz][0]; $r = pb_fight($c, max(1, $c['level'] + $d), $b, 'std', 11);
        $ok("$sz {$c['slug']} d$d bot $b ends (" . $r['over'] . ')', $fin($r), $r);
    }
    echo "== board sizes: tiny and huge\n";
    foreach ([[3, 3], [4, 4], [9, 9], [12, 12]] as [$w, $h]) foreach (['small', 'large'] as $sz) {
        $c = $by[$sz][0]; $r = pb_fight($c, $c['level'], 'chain', 'std', 12, ['w' => $w, 'h' => $h]);
        $ok("{$w}x{$h} $sz {$c['slug']} ends (" . $r['over'] . ')', $fin($r), $r);
    }
    echo "== empty and tiny decks\n";
    $c = $by['small'][0]; $p = tv_player($c['level']);
    $r = pb_fight($c, $c['level'], 'chain', 'std', 13, [], ['deck' => []] + $p);
    $ok('empty deck: no crash, the fight ends or stalls (' . $r['over'] . ')', $r['over'] !== 'err', $r);
    $p1 = $p; $p1['deck'] = array_slice($p['deck'], 0, 1);
    $r = pb_fight($c, $c['level'], 'random', 'std', 14, [], $p1);
    $ok('one-piece deck: no crash (' . $r['over'] . ')', $r['over'] !== 'err', $r);
    $p2 = $p; $p2['deck'] = array_slice($p['deck'], 0, 3);
    $r = pb_fight($c, $c['level'], 'look', 'std', 15, [], $p2);
    $ok('three-piece deck: no crash (' . $r['over'] . ')', $r['over'] !== 'err', $r);
    echo "== every creature (size and ability) finishes against two bots\n";
    $n = 0; foreach ($cr as $c) foreach (['random', 'chain'] as $b) { $r = pb_fight($c, $c['level'], $b, 'std', 100 + $n++); if (!$fin($r)) $ok("{$c['slug']} ($b) ends", false, $r); }
    $ok("all $n creature fights ended without an engine error", true);
    echo "== aim re-roll: a played-over aim gets picked again, never a stale or illegal cell\n";
    $reaims = 0; $nf = 0;
    foreach (array_slice($cr, 0, 12) as $c) for ($k = 0; $k < 2; $k++) {
        mt_srand(900 + $k); $cc = pfd_foe_row($c, 'NA'); $s = pfb_new(tv_player($c['level']), $cc, 900 + $k, ['blank' => true, 'v1' => true]);
        $hand = $s['me']['hand']; $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i; pfb_start($s, $bi, 'R'); $nf++;
        for ($t = 0; $t < 12 && !$s['over']; $t++) {
            $pl = tv_places($s); $a = $pl ? $pl[mt_rand(0, count($pl) - 1)] : ['pass']; $aim = $s['foe']['plan'] ?? null;
            $r = tv_act($s, $a); if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) break; }
            if ($aim && !empty($s['reaim'])) $reaims++;   // the creature's shown aim was taken or no longer fits: it picked again
        }
    }
    $ok("aim re-roll: $nf fights played with random moves, $reaims re-aims seen, no engine error", $reaims > 0, $reaims);
    echo "== 2.7.08 Teamwork reachable but not dominant, re-aims and bait aims within bounds (chain bot, std build, 30 creatures)\n";
    $m = pb_aim_stats(array_slice($cr, 0, 30));
    $ok(sprintf('Teamwork fires in %.0f%% of your turns (reachable: 5-50%%), x1.6 in %.0f%% (at most 10%%)', 100 * $m['tw'], 100 * $m['tw3']), $m['tw'] >= 0.05 && $m['tw'] <= 0.5 && $m['tw3'] <= 0.1, $m);
    $ok(sprintf('re-aims: %.2f a fight (at most 2), at most %d in one fight (never more than its turns)', $m['re'], $m['remax']), $m['re'] <= 2.0 && $m['reover'] === 0, $m);
    $ok(sprintf('bait aims: its own chain fires your pieces in %.0f%% of its turns, at most %.0f%% of its bar in one turn (under 50%%)', 100 * $m['bait'], 100 * $m['baitmax']), $m['baitmax'] < 0.5, $m);
    echo $bad ? "$bad FAILED\n" : "ok\n";
    return $bad ? 1 : 0;
}

/** 2.7.08: chain-bot fights on $cr: share of your turns with Teamwork (any, x1.6), re-aims per fight (mean, max, fights with more re-aims than turns), and bait (its chain firing your pieces: share of its turns, the largest one as a share of its bar). $v1 overrides rules (a check run with Teamwork off must fail). */
function pb_aim_stats(array $cr, array $v1 = []): array
{
    $T = 0; $tw = 0; $tw3 = 0; $re = 0; $remax = 0; $reover = 0; $F = 0; $ft = 0; $bt = 0; $bmax = 0.0;
    foreach ($cr as $c) {
        $seed = 500 + $c['level'] + 1000 * (crc32($c['slug']) % 97); mt_srand($seed);
        $s = pfb_new(pb_player($c['level'], 'std'), pfd_foe_row($c, array_keys(pfd_region_pieces())[(crc32($c['slug']) + $seed) % 14]), $seed, ['blank' => true, 'v1' => $v1 ?: true]);
        $hand = $s['me']['hand']; if ($hand) { $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i; pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$seed % 4]); }
        $n = 0; $fr = 0; $F++;
        while (!$s['over'] && $n++ < 40) {
            $r = tv_act($s, tv_choose($s, 'chain', tv_places($s))); if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) break; }
            $T++; $mx = 1.0; $in = false; $b = 0.0;
            foreach ($r['ev'] as $e) { if (isset($e['tw'])) $mx = max($mx, (float)$e['tw']); if (!isset($e['id'])) continue; if (!empty($e['root'])) { $in = ($e['by'] ?? '') === 'foe'; if ($in) $ft++; continue; } if ($in && ($e['by'] ?? '') === 'me') $b += (float)($e['fh'] ?? 0); }
            if ($mx > 1) $tw++; if ($mx >= (float)$s['v1']['team3'] && $mx > 1) $tw3++;
            if ($b > 0) { $bt++; $bmax = max($bmax, $b / max(1.0, (float)$s['fh']['max'])); }
            if (!empty($s['reaim'])) $fr++;
        }
        $re += $fr; $remax = max($remax, $fr); if ($fr > $n) $reover++;
    }
    return ['tw' => $tw / max(1, $T), 'tw3' => $tw3 / max(1, $T), 're' => $re / max(1, $F), 'remax' => $remax, 'reover' => $reover, 'bait' => $bt / max(1, $ft), 'baitmax' => $bmax];
}

function pb_report(): void
{
    $G = []; $C = [];
    while (($l = fgets(STDIN)) !== false) {
        $r = json_decode($l, true); if (!$r) continue;
        $G[$r['bot']][$r['build']][$r['d']][$r['size']][] = $r; $C[$r['slug']][$r['bot']][] = $r;
    }
    echo "# Playtest bot report (tests/pf_bots.php)\n\nWin %, mean turns and turn-cap % per bot, build, level offset (gnome minus creature) and creature size.\n";
    $targets = ['small' => [4, 5], 'medium' => [5, 7], 'large' => [6, 8], 'boss' => [6, 9]];
    foreach ($G as $bot => $bb) foreach ($bb as $build => $dd) {
        echo "\n## bot $bot, build $build\n\n| offset | size | fights | win % | turns | turn cap % | health lost % |\n|---|---|---|---|---|---|---|\n";
        ksort($dd); foreach ($dd as $d => $ss) foreach (['small', 'medium', 'large', 'boss'] as $sz) {
            $a = $ss[$sz] ?? []; if (!$a) continue; $n = count($a); $av = fn(string $k) => array_sum(array_column($a, $k)) / $n;
            printf("| %+d | %s | %d | %.0f | %.1f | %.0f | %.0f |\n", $d, $sz, $n, 100 * $av('win'), $av('turns'), 100 * $av('cap'), 100 * $av('hp'));
        }
    }
    echo "\n## Creatures furthest from the goal (the chain bot at its own level, the 'std' build)\n\nA creature the chain bot beats under 40% or over 98% of the time; its turns against the size target.\n\n| creature | size | win % | turns | target turns |\n|---|---|---|---|---|\n";
    $rows = [];
    foreach ($C as $slug => $byBot) { $a = array_filter($byBot['chain'] ?? [], fn($r) => $r['build'] === 'std' && $r['d'] === 0); if (!$a) continue; $n = count($a); $w = array_sum(array_column($a, 'win')) / $n; if ($w < 0.4 || $w > 0.98) $rows[] = [$slug, $a[array_key_first($a)]['size'], $w, array_sum(array_column($a, 'turns')) / $n]; }
    usort($rows, fn($x, $y) => abs($y[2] - 0.7) <=> abs($x[2] - 0.7));
    foreach (array_slice($rows, 0, 40) as [$slug, $sz, $w, $t]) printf("| %s | %s | %.0f | %.1f | %d-%d |\n", $slug, $sz, 100 * $w, $t, $targets[$sz][0], $targets[$sz][1]);
    if (!$rows) echo "| (none) | | | | |\n";
}

if (PHP_SAPI !== 'cli' || !isset($argv) || realpath($argv[0]) !== __FILE__) return;
if (($argv[1] ?? '') === 'edge') exit(pb_edge());
if (($argv[1] ?? '') === 'agg') { pb_report(); return; }
$bots = ($argv[1] ?? 'all') === 'all' ? PB_BOTS : array_values(array_intersect(explode(',', $argv[1]), PB_BOTS));
$offs = array_map('intval', explode(',', $argv[2] ?? '0')); $seeds = max(1, (int)($argv[3] ?? 1));
$builds = array_values(array_intersect(explode(',', $argv[4] ?? 'std'), PB_BUILDS)) ?: ['std']; [$shard, $nsh] = array_map('intval', explode('/', $argv[5] ?? '0/1')); $json = ($argv[6] ?? '') === 'json';
$ci = 0; $V1 = json_decode(getenv('V1') ?: '{}', true) ?: [];   // env V1='{"firex":0}': pfb_v1_cfg overrides (what-if on any rule)
foreach ($offs as $d) foreach (tv_creatures() as $c) {
    if ($ci++ % $nsh !== $shard) continue;
    foreach ($bots as $bot) foreach ($builds as $build) for ($k = 0; $k < $seeds; $k++) {
        $lv = max(1, $c['level'] + $d); $r = pb_fight($c, $lv, $bot, $build, 500 + 13 * $k + $c['level'] + 1000 * (crc32($c['slug']) % 97), $V1);   // 13: a step of 7 reached only 2 of the 14 regions a creature's seed picks
        echo json_encode(['bot' => $bot, 'build' => $build, 'd' => $d, 'size' => $c['size'], 'slug' => $c['slug']] + $r), "\n";
    }
}
