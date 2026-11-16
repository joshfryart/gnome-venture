<?php
// 2.7.01: the ten simulations of claude/review-tailor-2.7.00.md section 5, on the BUILT 2.7.00 wearables (game/includes/wearables.php WEAR_DEFS) and the real engine.
// Results: claude/sims-tailor-2.7.01.md. Uses the tuner's bots and gnome (tests/pfboard_tune_v1.php: tv_sources, tv_places, tv_choose, tv_act).
//   php tools/sims/tailor_sims_2701.php SIM [BOT] [MULT] [SHARD/N]    SIM = 1 | 2 | 4 | 5 | 6 | 7 | 8 | 9 | 10   (3 has no built piece to test: see the md)
// Prints one json line per fight (sims 1, 2, 4, 5, 7, 8, 10) or a table (6, 9). Aggregate with: php tools/sims/tailor_sims_2701.php agg < lines
require_once __DIR__ . '/../../tests/pfboard_tune_v1.php';
require_once __DIR__ . '/../../game/includes/wearables.php';

/** The tuner's gnome at a level, wearing $wears (item slug => 1; each one switched on in a Keepsake slot). $opt: luck (override), extra (tiles appended), col (per-type families for wearable pieces). */
function ts_player(int $lv, array $wears, array $opt = []): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $opt['luck'] ?? $m, 'level' => $lv];
    $max = 20 + 3 * $lv + 5 * $m; $src = tv_sources($lv);
    if ($lv >= 40) $src['slots'] = 4;
    $src['wears'] = $wears; foreach (wear_pieces($wears) as $wp) $src['state'][$wp['key']] = true;
    $b = pfd_build($src); $entries = $b['deck'];
    if (!empty($opt['col'])) foreach ($entries as &$e) if ($e['src'] === 'wear') $e['r'] = ['hurt' => 'body', 'guard' => 'craft', 'charm' => 'mind', 'soothe' => 'mind', 'trick' => 'mind'][$e['t']] ?? 'body'; unset($e);
    $deck = pfd_tiles($entries, $st, [], $src['calling'], $src['ctier']);
    foreach ($opt['extra'] ?? [] as $t) $deck[] = $t;
    $worn = array_values(array_map(fn($e) => $e['n'], array_filter($entries, fn($e) => $e['src'] === 'wear')));
    $outW = array_values(array_map(fn($e) => $e['n'] . ':' . $e['out'], array_filter($b['pieces'], fn($e) => $e['src'] === 'wear' && $e['on'] && $e['out'] !== '')));
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => $deck, 'luck' => $opt['luck'] ?? $m, '_worn' => $worn, '_out' => $outW];
}

/** One fight: the tuner's loop with its bots. Returns win, turns, health lost, the largest single hit of yours (bar points, one event), pluck result, poison taken. */
function ts_fight(array $me, array $c, int $seed, string $bot, int $k, array $over = [], bool $pluck = false): array
{
    $cr = pfd_foe_row($c, array_keys(pfd_region_pieces())[(crc32($c['slug']) + $k) % 14]);
    $worn = $me['_worn']; $out = $me['_out']; unset($me['_worn'], $me['_out']);
    $s = pfb_new($me, $cr, $seed, ['blank' => true, 'v1' => $over ?: true, 'can_pluck' => $pluck]);
    $hand = $s['me']['hand']; $bi = 0; foreach ($hand as $i => $t) if ($t['t'] === 'hurt' && $t['v'] > $hand[$bi]['v']) $bi = $i;
    pfb_start($s, $bi, ['L', 'R', 'T', 'B'][$k % 4]);
    $t = 0; $maxHit = 0.0; $maxHitBy = ''; $poison = 0; $plays = 0; $wearPlays = 0; $evadeHits = 0; $bashed = 0;
    while (!$s['over'] && $t++ < 40) {
        $pl = tv_places($s); $a = tv_choose($s, $bot, $pl);
        if (isset($a[0]) && is_int($a[0]) && ($s['me']['hand'][$a[0]]['src'] ?? '') === 'wear') $wearPlays++;
        $fh0 = (float)$s['fh']['now'] + (float)$s['bar']['now'];
        $r = tv_act($s, $a);
        if ($r['err']) { $r = pfb_pass($s, $s['turn']); if ($r['err']) { if (!$pl) break; $r = tv_act($s, $pl[0]); if ($r['err']) break; } }
        $prev = $fh0;
        foreach ($r['ev'] as $e) {
            if (($e['by'] ?? '') === 'me' && !empty($e['bashed'])) $bashed += (int)$e['bashed'];   // guard your Bash pieces put into hits
            if (!isset($e['fhnow'])) continue;
            $now = (float)$e['fhnow'] + (float)$e['barnow'];
            if (($e['by'] ?? '') === 'me' && $now - $prev > $maxHit) { $maxHit = $now - $prev; $maxHitBy = (string)$e['n'] . ($e['combo'] ? ' (' . $e['combo'] . ')' : ''); }
            $prev = $now;
        }
        foreach ($s['envlog'] ?? [] as $l) if (($l['k'] ?? '') === 'poison') $poison += (int)$l['me'];
        $s['envlog'] = [];
        $plays++;
    }
    return ['win' => in_array($s['over'], ['seen_off', 'charmed'], true) ? 1 : 0, 'turns' => $s['turn'], 'hp' => round(1 - $s['me']['hp'] / $s['me']['max'], 4), 'maxhit' => round($maxHit, 1), 'maxby' => $maxHitBy,
        'pluck' => (int)($s['plucked'] ?? 0), 'poison' => $poison, 'worn' => $worn, 'out' => $out, 'wplays' => $wearPlays, 'bashed' => $bashed, 'size' => $c['size'], 'clv' => $c['level'], 'slug' => $c['slug'], 'class' => $cr['class'] ?? ''];
}

/** The fights of a run: every creature (or those $keep accepts), gnome at $lvFn(creature), seeds as the tuner's, x MULT. */
function ts_run(string $tag, callable $meFn, string $bot, float $mult, array $shard, ?callable $keep = null, ?callable $lvFn = null, bool $pluck = false): void
{
    $ci = 0;
    foreach (tv_creatures() as $c) {
        if ($keep && !$keep($c)) continue;
        if ($ci++ % $shard[1] !== $shard[0]) continue;
        $nk = max(1, (int)ceil(TV_SEEDS[$c['size']] * $mult)); $lv = $lvFn ? $lvFn($c) : $c['level'];
        for ($k = 0; $k < $nk; $k++) {
            $seed = 500 + 7 * $k + $c['level'] + 1000 * (crc32($c['slug']) % 97);
            echo json_encode(['tag' => $tag, 'bot' => $bot, 'lv' => $lv, 'k' => $k] + ts_fight($meFn($lv), $c, $seed, $bot, $k, [], $pluck)), "\n";
        }
    }
}

/** A wearable's tile as the deck would deal it at a level (for the extra copies in sim 2). */
function ts_tile(string $slug, int $lv): array
{
    $m = max(0, intdiv($lv + 3, 14)); $st = ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv];
    $wp = wear_pieces([$slug => 1])[0]; $e = ['k' => $wp['key'], 'n' => $wp['n'], 't' => $wp['t'], 'v' => $wp['v'], 'r' => $wp['r'], 'tag' => $wp['tag'], 'src' => 'wear', 'life' => 0, 'rank' => $wp['rank'], 'tool' => ''] + (isset($wp['mod']) ? ['mod' => $wp['mod']] : []);
    return pfd_tiles([$e], $st)[0];
}

if (realpath($argv[0]) !== __FILE__) return;
$sim = $argv[1] ?? '1'; $bot = $argv[2] ?? 'chain'; $mult = (float)($argv[3] ?? 0.25); $shard = array_map('intval', explode('/', $argv[4] ?? '0/1'));
$cuts = []; foreach (WEAR_DEFS as $base => $d) foreach ($d['cuts'] as $cut => $cc) $cuts[$base . ($cut === 'b' ? '-b' : '')] = $cc[0];

if ($sim === 'agg') {   // rows grouped by tag: n, win %, turns, health lost %, mean and max of the per-fight largest hit, pluck %, poison taken, fights where the wearable was out
    $G = []; while (($l = fgets(STDIN)) !== false) { $r = json_decode($l, true); if ($r) $G[$r['tag'] . ' ' . $r['bot']][] = $r; }
    ksort($G);
    printf("%-34s %5s %6s %6s %6s %7s %7s %6s %7s %5s %6s %6s\n", 'run', 'n', 'win%', 'turns', 'hp%', 'hitavg', 'hitmax', 'pluck', 'poison', 'out', 'wplay', 'bashed');
    foreach ($G as $k => $rs) { $n = count($rs); $f = fn($x) => array_sum(array_column($rs, $x)) / $n;
        printf("%-34s %5d %6.1f %6.2f %6.1f %7.1f %7.1f %6.1f %7.2f %5d %6.2f %6.2f\n", $k, $n, 100 * $f('win'), $f('turns'), 100 * $f('hp'), $f('maxhit'), max(array_column($rs, 'maxhit')), 100 * $f('pluck'), $f('poison'), count(array_filter($rs, fn($r) => $r['out'])), $f('wplays'), $f('bashed')); }
    exit;
}
if ($sim === '1' || $sim === '5') {   // each cut alone, Common and Fine, against no wearable; sim 5: a level 40 gnome (4 belt slots, 4 Keepsake slots) against every creature of level 30+
    $keep = $sim === '5' ? fn($c) => $c['level'] >= 30 : null; $lvFn = $sim === '5' ? fn($c) => 40 : null; $p = $sim === '5' ? 's5 ' : 's1 ';
    ts_run($p . 'none', fn($lv) => ts_player($lv, []), $bot, $mult, $shard, $keep, $lvFn);
    foreach ($cuts as $key => $nm) foreach ([1, 3] as $rk) { [$b, $c] = str_ends_with($key, '-b') ? [substr($key, 0, -2), 'b'] : [$key, 'a'];
        $sl = wear_slug($b, $c, $rk); ts_run($p . $nm . ' r' . $rk, fn($lv) => ts_player($lv, [$sl => 1]), $bot, $mult, $shard, $keep, $lvFn); }
    if ($sim === '5') ts_run($p . 'four Fine (Boots, Gloves, Cloak, Pack)', fn($lv) => ts_player($lv, ['flood-boots-fine' => 1, 'work-gloves-fine' => 1, 'travel-cloak-fine' => 1, 'trail-pack-fine' => 1]), $bot, $mult, $shard, $keep, $lvFn);
    exit;
}
if ($sim === '2') {   // Pluck: 1, 2 or 3 Rummage (Trail Pack cut a, Common) at luck 0, 5, 9; level 16 gnome, creatures level 12-20, the creature carries an item
    foreach ([0, 5, 9] as $luck) foreach ([1, 2, 3] as $np)
        ts_run("s2 luck$luck pluck x$np", fn($lv) => ts_player($lv, ['trail-pack' => 1], ['luck' => $luck, 'extra' => array_fill(0, $np - 1, ts_tile('trail-pack', $lv))]), $bot, $mult, $shard, fn($c) => $c['level'] >= 12 && $c['level'] <= 20, fn($c) => 16, true);
    exit;
}
if ($sim === '4') {   // the largest single hit with a Fine Trail Pack (Tidy Up, Trick) at levels 28 and 40, against the same gnome without it
    foreach ([28, 40] as $L) {
        ts_run("s4 lv$L none", fn($lv) => ts_player($lv, []), $bot, $mult, $shard, fn($c) => $c['level'] >= $L - 6, fn($c) => $L);
        ts_run("s4 lv$L Tidy Up Fine", fn($lv) => ts_player($lv, ['trail-pack-b-fine' => 1]), $bot, $mult, $shard, fn($c) => $c['level'] >= $L - 6, fn($c) => $L);
        ts_run("s4 lv$L Tidy Up Fine + Firm Grip Fine", fn($lv) => ts_player($lv, ['trail-pack-b-fine' => 1, 'work-gloves-fine' => 1]), $bot, $mult, $shard, fn($c) => $c['level'] >= $L - 6, fn($c) => $L);
    }
    exit;
}
if ($sim === '7') {   // columns: two wearables (Firm Grip Hurt + Wrap Up Guard, Lined) all body family (built) against one family per type; level 16 gnome (two pals), creatures 12-20
    foreach (['body' => false, 'per-type' => true] as $nm => $col)
        ts_run("s7 $nm", fn($lv) => ts_player($lv, ['work-gloves-lined' => 1, 'travel-cloak-lined' => 1], ['col' => $col]), $bot, $mult, $shard, fn($c) => $c['level'] >= 12 && $c['level'] <= 20, fn($c) => 16);
    exit;
}
if ($sim === '8') {   // Evade stops poison: Puddle Hop (evade) against Reptiles and against all; Sure Foot (hold) and no wearable as controls; gnome at the creature's level
    $rep = fn($c) => str_starts_with((string)(pfd_foe_row($c, 'NA')['class'] ?? ''), 'Reptile');
    foreach (['none' => [], 'Puddle Hop' => ['flood-boots-lined' => 1], 'Sure Foot' => ['flood-boots-b-lined' => 1]] as $nm => $w) {
        ts_run("s8 reptiles $nm", fn($lv) => ts_player($lv, $w), $bot, $mult * 4, $shard, $rep);
    }
    exit;
}
if ($sim === '10') {   // "Shove" (built as Knuckle Down: Hurt 3, bash) after a Hold guard (Sure Foot): level 28, creatures 22+.
    // 2.7.01 rewrite: the Guard is LINED (not Rare), so the 3 Rare cap cannot drop it (the tuner's gnome at 28 already has 2 Rare belt tools: one Fine wearable is all that fits).
    // Control: Puddle Hop Lined, the same Guard 3 + Spiky without Hold, so "Hold then Bash" is read against "any Guard then Bash". 'bashed' = guard your Bash pieces added to hits a fight.
    $V = ['none' => [], 'Knuckle Down Fine' => ['work-gloves-b-fine' => 1], 'Knuckle Down Fine + Sure Foot Lined (hold)' => ['work-gloves-b-fine' => 1, 'flood-boots-b-lined' => 1],
        'Knuckle Down Fine + Puddle Hop Lined (no hold)' => ['work-gloves-b-fine' => 1, 'flood-boots-lined' => 1]];
    foreach ($V as $nm => $w) { $p = ts_player(28, $w); if ($p['_out'] || count($p['_worn']) !== count($w)) { fwrite(STDERR, "sim 10: '$nm' does not wear every wearable (out: " . implode(', ', $p['_out']) . ")\n"); exit(1); } }
    foreach ($V as $nm => $w) ts_run("s10 $nm", fn($lv) => ts_player($lv, $w), $bot, $mult, $shard, fn($c) => $c['level'] >= 22, fn($c) => 28);
    exit;
}
if ($sim === '6') {   // the Rare cap: which piece the deck drops when a Fine wearable is the 4th Rare (pfd_build order: kit and owned pieces, then wearables, then belt tools, then pals)
    foreach ([16, 28, 40] as $lv) {
        $src = tv_sources($lv); if ($lv >= 40) $src['slots'] = 4;
        $src['wears'] = ['work-gloves-fine' => 1, 'travel-cloak-fine' => 1]; foreach (wear_pieces($src['wears']) as $wp) $src['state'][$wp['key']] = true;
        $b = pfd_build($src); $rares = array_values(array_map(fn($e) => $e['src'] . ':' . $e['n'] . ($e['out'] ? ' OUT(' . $e['out'] . ')' : ''), array_filter($b['pieces'], fn($e) => $e['on'] && $e['rank'] === 3)));
        $keeps = pfd_slots($lv)['keeps'];
        echo "level $lv: Keepsake slots $keeps; Rare pieces switched on, in deck order: " . implode(', ', $rares) . "\n";
    }
    exit;
}
if ($sim === '9') {   // Tailor economy, Monte Carlo: lining attempts (and their materials and energy) to take ONE wearable Common -> Lined -> Fine, and THREE, at power 1, 3, 6; with and without the 5-Thread pity
    mt_srand(2701); $N = 20000;
    printf("%-6s %-6s %8s %8s %8s %8s %10s %10s\n", 'power', 'pity', 'chance', 'att/1', 'p90/1', 'att/3', 'energy/3', 'p90att/3');
    foreach ([1, 3, 6] as $pw) foreach ([false, true] as $pity) {
        $ch = tailor_chance($pw); $one = []; $three = [];
        for ($i = 0; $i < $N; $i++) { $th = 0; $tot = 0; $first = 0;
            for ($w = 0; $w < 3; $w++) { for ($step = 0; $step < 2; $step++) { while (true) { $tot++; if ($pity && $th >= WEAR_PITY) { $th -= WEAR_PITY; break; } if (mt_rand(1, 100) <= $ch) break; $th++; } } if ($w === 0) $first = $tot; }
            $one[] = $first; $three[] = $tot; }
        sort($one); sort($three);
        printf("%-6d %-6s %7d%% %8.2f %8d %8.2f %10.1f %10d\n", $pw, $pity ? 'yes' : 'no', $ch, array_sum($one) / $N, $one[(int)(0.9 * $N)], array_sum($three) / $N, 2 * array_sum($three) / $N, $three[(int)(0.9 * $N)]);
    }
    echo "materials per attempt: Common->Lined " . json_encode(wear_line_mats(1)) . ", Lined->Fine " . json_encode(wear_line_mats(2)) . "; base craft " . json_encode(WEAR_DEFS['work-gloves']['mats']) . " + 4 energy\n";
    exit;
}
fwrite(STDERR, "unknown sim\n"); exit(1);
