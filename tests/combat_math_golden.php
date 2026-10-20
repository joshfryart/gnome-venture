<?php
// Combat maths golden test (2.0.5): proves the shared maths (includes/combat_math.php) gives EXACTLY what the old copies in adventure.php and
// trek_fight.php gave. Fixed seeds, many inputs, both engines; the table lives in tests/combat_golden.json (recorded from the pre-refactor code).
// Run on an installed copy (walk.sh), random_int switched off so the test can seed it:
//   php -d disable_functions=random_int tests/combat_math_golden.php GAME_DIR            compare with tests/combat_golden.json
//   php -d disable_functions=random_int tests/combat_math_golden.php GAME_DIR --record   write the table (only from known-good code)
if (function_exists('random_int') && (new ReflectionFunction('random_int'))->isInternal()) { fwrite(STDERR, "Run with: php -d disable_functions=random_int tests/combat_math_golden.php GAME_DIR [--record]\n"); exit(2); }
function random_int(int $min, int $max): int { return mt_rand($min, $max); }   // seeded stand-in: every roll in the game goes through random_int
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$record = in_array('--record', $argv, true);
$file = __DIR__ . '/combat_golden.json';
$out = [];
$tail = fn() => mt_rand();   // the next number in the stream: proves the number AND order of RNG calls match
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$base = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$callings = [null, 'rootwarden', 'bloomcaller', 'thornblade', 'seedkeeper', 'wayfinder', 'brewroot'];
$stats = [['grit' => 10, 'nimble' => 10, 'hardiness' => 10, 'luck' => 10], ['grit' => 15, 'nimble' => 8, 'hardiness' => 12, 'luck' => 30], ['grit' => 7, 'nimble' => 16, 'hardiness' => 9, 'luck' => 60]];
$prof = function (?string $calling, int $lvl, array $st) use ($base): array {
    $u = $base; $u['level'] = $lvl; $u['calling'] = $calling; $u['calling_qt'] = 99;
    foreach ($st as $k => $v) $u['stat_' . $k] = $v;
    return $u;
};

// 1. gnome_combat (stats, level, calling perks) over levels 1-40
foreach ($callings as $ci => $cal) foreach ($stats as $si => $st) for ($l = 1; $l <= 40; $l++) $out['gc'][($cal ?? 'none') . ":$si:$l"] = gnome_combat($prof($cal, $l, $st));

// 2. attack roll and damage, seeded: every gnome profile, bonuses 0/3/5, advantage, crits, extra damage (trek and road copies both)
$ar = function_exists('trek_attack_roll') ? 'trek_attack_roll' : 'attack_roll';
$dm = function_exists('trek_damage') ? 'trek_damage' : 'damage';
$n = 0;
foreach ([1, 7, 15, 22, 30, 40] as $l) foreach ($callings as $cal) foreach ($stats as $si => $st) {
    $gc = gnome_combat($prof($cal, $l, $st));
    $gc['luck_crit'] = [0, 5, 50][$si];   // a big luck crit % so the second RNG call is exercised
    foreach ([['attack_roll', 'damage'], [$ar, $dm]] as $pi => [$fa, $fd]) {
        mt_srand(1000 + $n++);
        $seq = [];
        for ($i = 0; $i < 25; $i++) {
            [$b, $adv, $ex] = [[0, 3, 5][$i % 3], $i % 4 === 0, [0, 2, 3, 5, 6][$i % 5]];
            [$raw, $tot, $crit] = $fa($gc, $b, $adv);
            $seq[] = [$raw, $tot, $crit, $fd($gc, $crit, $ex), $fd($gc, !$crit)];
        }
        $out['roll'][($cal ?? 'none') . ":$si:$l:" . ($pi ? 'trek' : 'road')] = [$seq, $tail()];
    }
}

// 3. creature scaling, hp easing, trek foes (Chapter I and II tunes, party sizes 1-4), over levels 1-40
$creatures = q('SELECT * FROM creatures ORDER BY id')->fetchAll();
$out['n_creatures'] = count($creatures);
foreach ($creatures as $c) {
    foreach ([1, 5, 12, 20, 28, 40] as $to) foreach ([[100, 100], [60, 70], [30, 50]] as [$pct, $hpp]) $out['scale'][$c['slug'] . ":$to:$pct:$hpp"] = scale_creature($c, $to, $pct, $hpp);
    $out['hp_pct'][$c['slug']] = creature_hp_percent($c);
    foreach ([1, 20, 35] as $lv) { $cc = $c; $cc['level'] = $lv; $out['hp_pct'][$c['slug'] . ":$lv"] = creature_hp_percent($cc); }
    foreach ([[4, 4], [0, 0], [1, 1]] as [$mx, $hp]) {   // fight_prep: a fresh encounter, a nearly dead one, a one-health one
        $enc = ['hp' => $hp ?: 0, 'max' => $mx ?: 1]; $mxs = (int)$c['hp']; $enc = ['hp' => $hp ? $mxs : 0, 'max' => $mxs];
        fight_prep($enc, $c); $out['prep'][$c['slug'] . ":$mx$hp"] = $enc;
        $enc = ['hp' => $hp ? max(1, intdiv($mxs, 3)) : 0, 'max' => $mxs]; fight_prep($enc, $c); $out['prep'][$c['slug'] . ":$mx$hp:b"] = $enc;
    }
    foreach ([1, 2] as $ch) foreach ([1, 2, 3, 4] as $size) foreach ([[100, 0, 0, 0], [80, 2, -1, 1], [120, -2, 3, 2]] as $ti => $tune) {
        $f = trek_make_foe($c, $base, $size, false, $tune, $ch);
        unset($f['icon']);
        $out['foe'][$c['slug'] . ":$ch:$size:$ti"] = $f;
    }
    $f = trek_make_foe($c, ['level' => 1], 1, true); unset($f['icon']); $out['foe'][$c['slug'] . ':add'] = $f;
}

// 4. fight_odds / fight_certainty (road engine), no RNG
$nOdds = 0;
foreach ([3, 10, 20, 35] as $l) foreach ($callings as $cal) {
    $u = $prof($cal, $l, $stats[1]);
    foreach (array_slice($creatures, 0, 400, true) as $ci => $c) {
        if ($ci % 7) continue;
        $enc = ['id' => (int)$c['id'], 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => $ci % 2, 'poison' => 0, 'used' => false, 'lv' => 0];
        $exp = ['hp' => 20 + $l * 3, 'max_hp' => 20 + $l * 3];
        $o = fight_odds($u, $exp, $enc); $o['cert'] = fight_certainty($u, $exp, $c, $enc);
        $out['odds'][($cal ?? 'none') . ":$l:" . $c['slug']] = $o; $nOdds++;
    }
}

// 5. the road engine: whole combat_turn rounds (attack, every calling ability, flee, snack refusal, the creature's turn, bark, poison, win, knock-out)
$from = (int)q_val('SELECT id FROM locations ORDER BY id LIMIT 1');
$bestRows = array_values(array_filter($creatures, fn($c) => (int)$c['id'] % 5 === 0));
$k = 0;
foreach ($bestRows as $c) foreach ($callings as $cal) {
    $l = [4, 12, 24][$k % 3]; $u = $prof($cal, $l, $stats[$k % 3]); $u['id'] = 999000 + ($k % 50);
    foreach (['attack', 'ability', 'flee', 'attack', 'attack'] as $ai => $action) {
        mt_srand(5000 + $k++);
        $big = $ai < 3;   // 0-2: long fights (nobody dies), 3-4: a one-health creature (win) / a one-health gnome (knock-out)
        $enc = ['type' => 'creature', 'id' => (int)$c['id'], 'lv' => $ai === 2 ? max((int)$c['level'], 14) : 0, 'sp' => 70, 'hpp' => 90, 'hp' => $ai === 3 ? 1 : 900, 'max' => $ai === 3 ? 1 : 900,
            'bark' => $ai === 1 ? 2 : 0, 'poison' => $ai === 2 ? 1 : 0, 'used' => false];
        $exp = ['id' => 77, 'status' => 'active', 'hp' => $ai === 4 ? 1 : 900, 'max_hp' => 900, 'log' => '[]', 'encounter' => json_encode($enc), 'from_id' => $from, 'level' => 5, 'kind' => 'walk', 'step' => 1];
        $rec = [];
        try {
            for ($r = 0; $r < 6; $r++) {
                $over = combat_turn($u, $exp, $action);
                $rec[] = [$over, (int)$exp['hp'], $exp['encounter'], $exp['log'], $exp['status']];
                if ($over) break;
            }
        } catch (Throwable $e) { $rec[] = get_class($e) . ': ' . $e->getMessage(); }
        $rec[] = $tail();
        $out['road'][$c['slug'] . ':' . ($cal ?? 'none') . ":$ai"] = $rec;
    }
}

// 6. trek fights (party engine): every Chapter I / II party shape, random zones, the bosses, Auto AI, all the foe, ability, flee and boss-script rolls
$GLOBALS['trek_sim'] = true;
$su = $base; $su['id'] = 999999; $su['level'] = 15; $su['calling'] = null; $su['calling_qt'] = 0;
foreach (['grit', 'nimble', 'hardiness'] as $s) $su['stat_' . $s] = 12;
$simFight = function (int $chapter, array $keys, int $L, callable $start, int $seed, ?string $calling = null, bool $flee = false) use ($su): array {
    mt_srand($seed);
    $u = $su; $u['calling'] = $calling;
    $r = ['id' => 0, 'chapter' => $chapter, 'fatigue' => 0, 'st' => ['tl' => []], 'party' => [], 'fi' => null, 'lg' => [], 'flags' => ['tut_party' => true], 'petals_found' => 0];
    foreach ($keys as $s => $k) { $r['party'][$s] = ['crew_key' => $k, 'hp' => 9999]; $r['st']['tl'][$k] = [$k === 'gnome' ? $L : max(1, $L - 1), 0]; }
    foreach (trek_party_stats($r, $u) as $s => $m) $r['party'][$s]['hp'] = $m['max'];
    $GLOBALS['trek_sim_won'] = false;
    $start($r, $u, count($keys));
    $rounds = 0; $hist = []; $fled = null;
    for (; $rounds < 80 && $r['fi']; $rounds++) {
        if ($flee && $rounds === 1 && !empty($r['fi'])) { $fled = trek_fight_flee($r, $u); if (!$r['fi']) break; }
        trek_fight_round($r, $u, trek_fight_ai($r, $u));
        $hist[] = array_map(fn($p) => (int)$p['hp'], $r['party']);
    }
    return ['won' => (bool)$GLOBALS['trek_sim_won'], 'rounds' => $rounds, 'hist' => $hist, 'fled' => $fled, 'log' => $r['st']['flog'] ?? null, 'tail' => mt_rand()];
};
$randomIn = fn(string $zone, int $ch = 1) => function (array &$r, array $u, int $size) use ($zone, $ch) {
    $cs = trek_pick_foes($zone, $ch); $t = trek_foe_tune(['zone' => $zone], $ch);
    trek_start_fight($r, $u, $cs, ['kind' => 'random', 'zone' => $zone], array_map(fn($c) => trek_make_foe($c, $u, $size, false, $t, $ch), $cs));
};
$bossAt = fn(string $code, int $ch = 1, ?float $weak = null) => function (array &$r, array $u, int $size) use ($code, $ch, $weak) {
    $sp = trek_spots($ch)[$code]; $c = trek_creature($sp['data']['creature']);
    $meta = ['kind' => 'spot', 'spot' => $code, 'script' => $sp['data']['script'], 'zone' => $sp['zone']];
    $f = trek_make_foe($c, $u, $size, false, trek_foe_tune($meta, $ch), $ch);
    if ($weak) $f['hp'] = (int)ceil($f['max'] * $weak);
    trek_start_fight($r, $u, [$c], $meta, [$f]);
};
$P1 = ['gnome']; $P2 = ['gnome', 'burdock']; $P3 = ['gnome', 'burdock', 'zinnia']; $P4 = ['gnome', 'burdock', 'zinnia', 'bracken'];
$jobs = [];
foreach (['g', 'w', 'f', 'd', 'h', 'b', 'r'] as $z) foreach ([[$P1, 1], [$P2, 3], [$P3, 5], [$P4, 6]] as $pi => [$P, $L]) $jobs["c1:$z:$pi"] = [1, $P, $L, $randomIn($z)];
foreach (['mother' => 6, 'gloomtooth' => 8] as $b => $L) foreach ([$P3, $P4] as $pi => $P) $jobs["c1:boss:$b:$pi"] = [1, $P, $L, $bossAt($b)];
foreach (['j', 'l', 'm'] as $z) foreach ([$P3, $P4] as $pi => $P) $jobs["c2:$z:$pi"] = [2, $P, 10, $randomIn($z, 2)];
$ch2 = [['burdock', 'zinnia', 'bracken'], ['burdock', 'zinnia', 'sorrel'], ['zinnia', 'bracken', 'sorrel'], ['burdock', 'bracken', 'tumble'], ['zinnia', 'sorrel', 'juniper'], ['bracken', 'tumble', 'juniper']];
foreach (['silverfin' => 10, 'pinch' => 13, 'thrum' => 14] as $b => $L) foreach ($ch2 as $pi => $mates) {
    $jobs["c2:boss:$b:$pi"] = [2, array_merge(['gnome'], $mates), $L, $bossAt($b, 2)];
    if ($b === 'pinch') $jobs["c2:boss:$b:$pi:weak"] = [2, array_merge(['gnome'], $mates), $L, $bossAt($b, 2, 0.8)];
}
$seed = 70000;
foreach ($jobs as $name => [$ch, $keys, $L, $start]) {
    for ($rep = 0; $rep < 3; $rep++) {
        $cal = [null, 'thornblade', 'wayfinder', 'brewroot', 'rootwarden', 'seedkeeper'][($rep * 2 + strlen($name)) % 6];
        $out['trek'][$name . ":$rep"] = $simFight($ch, $keys, $L, $start, $seed++, $cal, $rep === 2);
    }
}
unset($GLOBALS['trek_sim'], $GLOBALS['trek_sim_won']);

// one short fingerprint per row (the full tables are megabytes); a differing row name says where to look, and the row can be dumped with --dump
$fp = fn($v) => substr(md5(json_encode($v, JSON_UNESCAPED_UNICODE | JSON_PRESERVE_ZERO_FRACTION)), 0, 12);
if (in_array('--dump', $argv, true)) { file_put_contents(sys_get_temp_dir() . '/combat_dump_' . getmypid() . '.json', json_encode($out, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)); }
$full = $out;
$out = array_map(fn($rows) => is_array($rows) ? array_map($fp, $rows) : $rows, $out);
$json = json_encode($out, JSON_PRETTY_PRINT);
if ($record) { file_put_contents($file, $json . "\n"); echo 'recorded ' . strlen($json) . ' bytes, sections: ' . implode(', ', array_map(fn($k, $v) => $k . '=' . (is_array($v) ? count($v) : $v), array_keys($out), $out)) . "\n"; exit(0); }
$want = json_decode((string)@file_get_contents($file), true);
if (!$want) { echo "  FAIL no golden file\n"; exit(1); }
$bad = 0;
foreach ($out as $sec => $rows) {
    $w = $want[$sec] ?? null; $got = $rows;
    if (!is_array($rows)) { $same = $got === $w; echo ($same ? '  ok   ' : '  FAIL ') . "$sec\n"; if (!$same) $bad++; continue; }
    $diff = [];
    foreach ($got as $key => $v) if (json_encode($v) !== json_encode($w[$key] ?? null)) $diff[] = $key;
    foreach (array_diff_key($w ?? [], $got) as $key => $v) $diff[] = "missing:$key";
    echo ($diff ? '  FAIL ' : '  ok   ') . "$sec (" . count($got) . ' rows' . ($diff ? ', ' . count($diff) . ' differ: ' . implode(' ', array_slice($diff, 0, 5)) : '') . ")\n";
    if ($diff) $bad++;
}
echo $bad ? "  $bad section(s) differ from the golden table\n" : "  all sections identical to the golden table\n";
exit($bad ? 1 : 0);
