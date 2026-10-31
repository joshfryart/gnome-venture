<?php
// v2.3.1 delve floor format + lint (pure, no database). Run by delvefloors.sh:  php tests/delvefloors.php [GAME_DIR]
$game = $argv[1] ?? dirname(__DIR__) . '/game';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
require $game . '/includes/delve_floors.php';
$good = (string)file_get_contents(__DIR__ . '/fixtures/delve_floors_good.txt');

echo "== good floors\n";
$r = dv_floors_from_text($good);
ok('three good floors parse + lint', count($r['floors']) === 3 && !$r['problems'], json_encode($r['problems']));
$f = $r['floors']['sample-delve/key_vault'] ?? null;
ok('header fields read', $f && $f['tier'] === 'standard' && $f['sig'] === true && $f['for'] === ['treasure'] && $f['title'] === 'The Key Vault' && $f['slug'] === 'sample-delve');
ok('boss floor keeps for: boss only', $r['floors']['sample-delve/old_throne']['for'] === ['boss']);
ok('real data file lints clean', !dv_floors_from_text((string)file_get_contents($game . '/includes/data/delve_floors.txt'))['problems']);

echo "== pool\n";
$all = $r['floors'];
ok('pool by slug', count(dv_pool('sample-delve', null, null, $all)) === 3 && dv_pool('nope', null, null, $all) === []);
ok('pool by tier', array_keys(dv_pool('sample-delve', 'small', null, $all)) === ['sample-delve/mossy_hall']);
ok('pool by node kind', array_keys(dv_pool('sample-delve', null, 'boss', $all)) === ['sample-delve/old_throne'] && count(dv_pool('sample-delve', null, 'fight', $all)) === 1);

echo "== bad floors (each mutation must be caught)\n";
$mut = function (string $key, callable $edit) use ($good): array {
    $p = dv_floor_parse($good)['floors'][$key];
    $p = $edit($p);
    $p['map'] = tm_parse($p['rows']);
    return dv_floor_lint($p);
};
$rows = fn(array $p, int $y, string $s) => (function () use ($p, $y, $s) { $p['rows'][$y] = $s; return $p; })();
$has = fn(array $b, string $needle) => (bool)array_filter($b, fn($x) => strpos($x, $needle) !== false);
$H = 'sample-delve/mossy_hall'; $V = 'sample-delve/key_vault'; $T = 'sample-delve/old_throne';
$b = $mut($H, fn($p) => ['tier' => 'standard'] + $p);          ok('wrong size for tier', $has($b, 'must be 13x13'), json_encode($b));
$b = $mut($H, fn($p) => ['tier' => 'huge'] + $p);              ok('unknown tier', $has($b, 'tier must be'), json_encode($b));
$b = $mut($H, fn($p) => ['rule' => ''] + $p);                  ok('no rule', $has($b, 'no rule'), json_encode($b));
$b = $mut($H, fn($p) => ['rule' => 'Dark — and deep.'] + $p);  ok('dash in rule', $has($b, 'dash'), json_encode($b));
$b = $mut($H, fn($p) => ['for' => ['fight', 'dance']] + $p);   ok('unknown node kind', $has($b, 'unknown node kind'), json_encode($b));
$b = $mut($H, fn($p) => $rows($p, 1, '#S..1..#.'));            ok('open edge', $has($b, 'edge must be wall'), json_encode($b));
$b = $mut($H, fn($p) => $rows($p, 1, '#S..1..##x'));           ok('ragged row', $has($b, 'must be 9x9') || $has($b, 'wide'), json_encode($b));
$b = $mut($H, fn($p) => $rows($p, 1, '#S..1..#!#'));           ok('bad character', $has($b, 'bad character') || $has($b, 'must be 9x9'), json_encode($b));
$b = $mut($H, fn($p) => $rows($p, 1, '#S..S..##'));            ok('two entries', $has($b, 'exactly one S'), json_encode($b));
$b = $mut($H, fn($p) => $rows($p, 7, '#.......#'));            ok('no exit', $has($b, 'exactly one E'), json_encode($b));
$b = $mut($H, fn($p) => $rows($p, 1, '#S..B..##'));            ok('B on a normal floor', $has($b, 'B is for boss'), json_encode($b));
$b = $mut($H, fn($p) => $rows($rows($p, 1, '#S12345.#'), 3, '#.#678#.#'));
ok('more than 6 finds', $has($b, 'more than 6 finds'), json_encode($b));
$cut = "@s/pocket\ntier: small\nrule: A pocket.\nfor: fight\n#########\n#S.....E#\n#.......#\n#..###..#\n#..#.#..#\n#..###..#\n#.......#\n#.......#\n#########\n";
$rc = dv_floors_from_text($cut);
ok('cut-off floor', $has($rc['problems']['s/pocket'] ?? [], 'cut off'), json_encode($rc['problems']));
$b = $mut($V, fn($p) => $rows($p, 2, '#......#....#'));         ok('door without key', $has($b, 'key and door come together'), json_encode($b));
$b = $mut($V, fn($p) => $rows($rows($p, 2, '#......#...K#'), 1, '#S.....#...C#'));
ok('key behind the door', $has($b, 'key is behind the door'), json_encode($b));
$b = $mut($T, fn($p) => $rows($p, 5, '#...#...#...#'));        ok('boss floor without B', $has($b, 'exactly one B'), json_encode($b));
$b = $mut($T, fn($p) => $rows($p, 5, '#...#.BE#...#'));        ok('boss floor with E', $has($b, 'no E'), json_encode($b));
$b = $mut($T, fn($p) => ['tier' => 'large'] + $p);             ok('large floor needs 15x15', $has($b, 'must be 15x15'), json_encode($b));
$b = $mut($V, fn($p) => ['tier' => 'standard', 'for' => ['fight']] + $p); ok('valid with another node kind', $b === [], json_encode($b));
// torch budget
$ok = "@s/walk\ntier: small\nrule: A plain walk.\nfor: fight\n#########\n#S......#\n#######.#\n#.......#\n#.#######\n#.......#\n#######.#\n#E......#\n#########\n";
$r2 = dv_floors_from_text($ok);
ok('a plain snake is within the torch budget', count($r2['floors']) === 1, json_encode($r2['problems']));
$wet = str_replace(['@s/walk', 'A plain walk.', '#S......#', '#.......#', '#.......#', '#E......#'], ['@s/wet', 'All water.', '#SWWWWWW#', '#WWWWWWW#', '#WWWWWWW#', '#EWWWWWW#'], $ok);
$r3 = dv_floors_from_text($wet);
ok('a snake of hazards is over the torch budget', $has($r3['problems']['s/wet'] ?? [], 'torch steps'), json_encode($r3['problems']));

echo "== parse edge cases\n";
$p = dv_floor_parse("@a/b\ntier: small\n");
ok('floor with no rows is a floor with a problem', count($p['floors']) === 1 && dv_floor_lint($p['floors']['a/b']) !== []);
$p = dv_floor_parse("@Bad Name\n");
ok('bad header reported', count($p['errors']) === 1 && !$p['floors']);
$p = dv_floor_parse("stray line\n@a/b\ntier: small\n@a/b\n");
ok('text outside a floor + duplicate name reported', count($p['errors']) === 2, json_encode($p['errors']));
ok('hazard costs more torch', dv_step_cost('W') === DV_HAZARD_COST && dv_step_cost('.') === 1);

echo $fails ? "$fails FAILED\n" : "all delve floor tests passed\n";
exit($fails ? 1 : 0);
