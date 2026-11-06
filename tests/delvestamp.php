<?php
// v2.3.1 delve chambers + stamped floors (pure, no database).  php tests/delvestamp.php [GAME_DIR]
$game = $argv[1] ?? dirname(__DIR__) . '/game';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
require $game . '/includes/delve_stamp.php';
$fx = file_get_contents(__DIR__ . '/fixtures/delve_chambers_good.txt');
$pool = ds_chambers($fx);

echo "== chambers\n";
ok('10 fixture chambers parse + lint', count($pool) === 10, (string)count($pool));
ok('pool by size, own slug first then any', count(ds_pool('fx', 5, $pool)) === 4 && ds_pool('nope', 5, $pool) === [] && count(ds_pool('fx', 3, $pool)) === 3);
$any = ds_chambers(str_replace('@fx/', '@any/', $fx));
ok('"any" chambers serve every delve', count(ds_pool('whatever', 6, $any)) === 3);
$bad = fn(string $body) => ds_lint(ds_parse("@t/x\n$body")['chambers']['t/x']);
ok('wrong row count', $bad("size: 3\n...\n...\n") !== []);
ok('wrong width', $bad("size: 3\n...\n..\n...\n") !== []);
ok('bad character', $bad("size: 3\n...\n.S.\n...\n") !== []);
ok('bad size', $bad("size: 4\n....\n....\n....\n....\n") !== []);
ok('too much wall', $bad("size: 3\n###\n#.#\n###\n") !== []);
ok('floor split in two', $bad("size: 5\n..#..\n..#..\n..#..\n..#..\n..#..\n") !== []);
ok('mostly water', $bad("size: 3\nWWW\nWWW\n..W\n") !== []);
ok('fine one passes', $bad("size: 3\n...\n.#.\n...\n") === []);

echo "== stamped floors (all kinds, all tiers, 80 seeds)\n";
$kinds = ['fight' => ['F', '1', 'F', 'E'], 'treasure' => ['1', 'C', 'E'], 'mystery' => ['1', 'T', 'E'], 'puzzle' => ['T', '1', '1', 'E'], 'boss' => ['C', 'B']];
$n = 0; $miss = []; $badf = [];
foreach ($kinds as $kind => $objs) {
    foreach ($kind === 'boss' ? ['standard', 'large'] : ($kind === 'treasure' ? ['small', 'standard', 'large'] : ['small', 'standard']) as $tier) {   // large floors are only treasure or boss
        for ($i = 0; $i < 80; $i++) {
            $m = ds_floor("t$i|$kind", 'fx', $tier, $objs, $pool);
            $n++;
            if (!$m) { $miss[] = "$kind/$tier/$i"; continue; }
            $N = DS_CELL[$tier] * 2 + 3;
            if ($m['w'] !== $N || $m['h'] !== $N) $badf[] = "$kind/$tier/$i size";
            $want = array_count_values($objs) + ['S' => 1];
            foreach (['S', 'F', 'T', 'C', 'E', 'B'] as $c) if (count(dv_find_all($m, $c)) !== ($want[$c] ?? 0)) $badf[] = "$kind/$tier/$i $c";
        }
    }
}
ok("$n stamped floors, every one made", !$miss, json_encode(array_slice($miss, 0, 3)));
ok('right size and the right objects', !$badf, json_encode(array_slice($badf, 0, 3)));
ok('same seed = same floor', ds_floor('a', 'fx', 'standard', $kinds['fight'], $pool) === ds_floor('a', 'fx', 'standard', $kinds['fight'], $pool));
ok('different seeds differ', ds_floor('a', 'fx', 'standard', $kinds['fight'], $pool) !== ds_floor('b', 'fx', 'standard', $kinds['fight'], $pool));
ok('no chambers = null (caller falls back)', ds_floor('a', 'zzz', 'standard', $kinds['fight'], $pool) === null && ds_floor('a', 'fx', 'standard', $kinds['fight'], []) === null);
$variety = [];
for ($i = 0; $i < 40; $i++) $variety[md5(implode('', ds_floor("v$i", 'fx', 'standard', $kinds['treasure'], $pool)['t']))] = 1;
ok('floors differ a lot (40 seeds, over 30 distinct)', count($variety) > 30, (string)count($variety));

echo "== the real library\n";
$real = ds_chambers();
$p = ds_parse((string)file_get_contents($game . '/includes/data/delve_chambers.txt'));
ok('real chamber file has no parse errors and every chamber passes', !$p['errors'] && count($p['chambers']) === count($real), json_encode($p['errors']));
foreach (array_unique(array_map(fn($c) => $c['slug'], $real)) as $slug) {
    if (!ds_pool($slug, 5, $real)) { echo "  (no chambers for $slug yet)\n"; continue; }
    $miss = 0;
    foreach (['small', 'standard', 'large'] as $tier) for ($i = 0; $i < 60; $i++) foreach ($kinds as $kd => $objs) if (($tier !== 'large' || in_array($kd, ['treasure', 'boss'], true)) && !ds_floor("r$i", $slug, $tier, $objs, $real)) $miss++;
    ok("$slug: every stamped floor valid (60 seeds x tiers x kinds)", $miss === 0, "$miss failed");
}
echo $fails ? "$fails FAILED\n" : "all delve stamp tests passed\n";
exit($fails ? 1 : 0);
