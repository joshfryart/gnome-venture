<?php
// v2.3.1 delve route generator + floor draw (pure, no database).  php tests/delveroute.php [GAME_DIR]
$game = $argv[1] ?? dirname(__DIR__) . '/game';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
require $game . '/includes/delve_route.php';

// a synthetic pool: 12 floors (5 small, 5 standard, 1 large treasure, 1 boss), two signature floors
$pool = [];
$add = function (string $name, string $tier, array $for, bool $sig) use (&$pool) { $pool["d/$name"] = ['key' => "d/$name", 'slug' => 'd', 'name' => $name, 'tier' => $tier, 'for' => $for, 'sig' => $sig]; };
$K = ['fight', 'treasure', 'mystery', 'puzzle'];
for ($i = 1; $i <= 5; $i++) $add("s$i", 'small', $K, $i === 1);
for ($i = 1; $i <= 5; $i++) $add("m$i", 'standard', $K, $i === 1);
$add('big', 'large', ['treasure'], false);
$add('boss', 'standard', ['boss'], true);

echo "== stages\n";
ok('stages by level', dv_stages(1) === 3 && dv_stages(2) === 3 && dv_stages(3) === 4 && dv_stages(20) === 4);

echo "== route shape (300 seeds x 3 stage counts)\n";
$bad = [];
$sameKind = 0;
foreach ([3, 4, 5] as $st) {
    for ($i = 0; $i < 300; $i++) {
        $r = dv_route("seed$i", 'd', $st);
        $w = array_map('count', $r['rows']);
        if ($w !== DV_WIDTHS[$st]) $bad[] = "widths $st/$i";
        $ids = [];
        foreach ($r['rows'] as $row) foreach ($row as $n) $ids[$n['id']] = $n;
        $parents = [];
        foreach ($ids as $n) {
            if ($n['row'] < $st - 1 && !$n['to']) $bad[] = "dead end {$n['id']} $st/$i";
            if ($n['row'] === $st - 1 && $n['to']) $bad[] = "boss has exits $st/$i";
            foreach ($n['to'] as $t) { if (!isset($ids[$t]) || $ids[$t]['row'] !== $n['row'] + 1) $bad[] = "bad edge {$n['id']}>$t $st/$i"; $parents[$t] = true; }
            if ($n['row'] === $st - 1 && $n['kind'] !== 'boss') $bad[] = "last row not boss $st/$i";
            if ($n['row'] < $st - 1 && $n['kind'] === 'boss') $bad[] = "boss early $st/$i";
            if ($n['row'] === $st - 2 && !in_array($n['kind'], DV_FLOOR_KINDS, true)) $bad[] = "quick node before boss $st/$i";
            if (isset($n['tier']) && $n['tier'] === 'large' && !in_array($n['kind'], ['treasure', 'boss'], true)) $bad[] = "large non-treasure $st/$i";
            if (in_array($n['kind'], DV_QUICK_KINDS, true) && isset($n['tier'])) $bad[] = "quick node has a tier $st/$i";
            if (dv_node_has_floor($n) && !isset($n['tier'])) $bad[] = "floor node without tier $st/$i";
        }
        foreach ($ids as $id => $n) if ($n['row'] > 0 && empty($parents[$id])) $bad[] = "orphan $id $st/$i";
        // every first-row node reaches the boss
        $reach = array_map(fn($n) => $n['id'], $r['rows'][0]);
        for ($row = 1; $row < $st; $row++) { $next = []; foreach ($reach as $id) foreach ($ids[$id]['to'] as $t) $next[$t] = true; $reach = array_keys($next); }
        if (count($reach) !== 1) $bad[] = "boss not reached $st/$i";
    }
}
ok('widths, edges, boss, no dead ends or orphans, tiers', !$bad, json_encode(array_slice($bad, 0, 5)));

echo "== determinism + variety\n";
ok('same seed = same route', dv_route('x', 'd', 4) === dv_route('x', 'd', 4));
$kinds = [];
for ($i = 0; $i < 200; $i++) foreach (dv_route("v$i", 'd', 4)['rows'][1] as $n) $kinds[$n['kind']] = true;
ok('middle rows produce quick nodes and floor nodes', isset($kinds['shrine'], $kinds['mole'], $kinds['fight'], $kinds['treasure']), implode(',', array_keys($kinds)));
ok('different seed or delve = different route', dv_route('a', 'd', 4) !== dv_route('b', 'd', 4) && dv_route('a', 'd', 4) !== dv_route('a', 'e', 4));
$r = dv_route('a', 'd', 4);
ok('choices: start = first row, then the exits, boss = none', count(dv_route_choices($r, null)) === 3 && dv_route_choices($r, '0.0') === $r['rows'][0][0]['to'] && dv_route_choices($r, '3.0') === [] && dv_route_choices($r, 'zz') === []);
ok('node lookup', dv_route_node($r, '2.1')['id'] === '2.1' && dv_route_node($r, '9.9') === null && dv_route_node($r, 'x') === null);

echo "== floor draw (walk 300 random paths)\n";
$bad = [];
$firstSig = 0;
$walks = 0;
for ($i = 0; $i < 300; $i++) {
    $route = dv_route("w$i", 'd', 4);
    $at = null;
    $used = [];
    $rng = tm_rng("walk$i");
    for ($row = 0; $row < 4; $row++) {
        $ch = dv_route_choices($route, $at);
        $at = $ch[$rng(0, count($ch) - 1)];
        $n = dv_route_node($route, $at);
        if (!dv_node_has_floor($n)) continue;
        $p = dv_floor_pick($route, $at, $used, true, $pool);
        if ($p['src'] !== 'pool') { $bad[] = "no floor for $at ({$n['kind']}) walk $i"; continue; }
        if (in_array($p['key'], $used, true)) $bad[] = "repeat {$p['key']} walk $i";
        $f = $pool[$p['key']];
        if (!in_array($n['kind'], $f['for'], true)) $bad[] = "floor {$p['key']} not for {$n['kind']}";
        if ($p['key'] !== dv_floor_pick($route, $at, $used, true, $pool)['key']) $bad[] = "not deterministic walk $i";
        $used[] = $p['key'];
    }
    $walks++;
    if (array_filter($used, fn($k) => $pool[$k]['sig'])) $firstSig++;
}
ok('every floor fits its node kind, no repeats, never empty', !$bad, json_encode(array_slice($bad, 0, 5)));
ok('first clear: every walked path met a signature floor', $firstSig === $walks, "$firstSig of $walks");

echo "== fallbacks\n";
$route = dv_route('f', 'd', 4);
$at = $route['rows'][0][0]['id'];
ok('empty pool = generator', dv_floor_pick($route, $at, [], true, [])['src'] === 'gen');
ok('other delve = generator', dv_floor_pick(dv_route('f', 'zzz', 4), '0.0', [], true, $pool)['src'] === 'gen');
$quick = null;
for ($i = 0; $i < 100 && !$quick; $i++) { $rt = dv_route("q$i", 'd', 4); foreach ($rt['rows'][1] as $n) if (!dv_node_has_floor($n)) $quick = [$rt, $n['id']]; }
ok('a quick node has no floor', $quick && dv_floor_pick($quick[0], $quick[1], [], true, $pool)['src'] === 'gen');
$tiny = ['d/only' => $pool['d/s1']];
$used = ['d/only'];
ok('pool used up = generator', dv_floor_pick($route, $at, $used, false, $tiny)['src'] === 'gen');
ok('tier relaxes to any tier of the kind', (function () use ($route, $pool) {
    $only = ['d/s1' => $pool['d/s1'], 'd/boss' => $pool['d/boss']];   // small floors only
    foreach ($route['rows'] as $row) foreach ($row as $n) if (isset($n['tier']) && $n['tier'] === 'standard' && $n['kind'] !== 'boss') return dv_floor_pick($route, $n['id'], [], false, $only)['key'] === 'd/s1';
    return true;
})());
ok('route seed is all that needs saving (state stays small)', strlen(json_encode(['v' => 2, 'rs' => 'a1b2c3d4e5f6', 'st' => 4, 'at' => '2.1', 'pk' => ['0.1', '1.2'], 'u' => ['d/s1', 'd/m2']])) < 200);

echo $fails ? "$fails FAILED\n" : "all delve route tests passed\n";
exit($fails ? 1 : 0);
