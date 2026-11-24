<?php
// Item review group C, second pass (2.7.58): R5 stop-craft dupes, R16 plank and rope yields, R18 wearable pairs, R9/uA-4/B1 creature-part families.
// php tests/item_review_d.php GAME_DIR (installed game with player "sprout").
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
foreach (['upgrade2758', 'parts', 'wearables', 'crafting', 'stops'] as $f) require_once $argv[1] . '/includes/' . $f . '.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$price = function (string $slug): int { static $c = []; return $c[$slug] ??= (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$slug]); };
$value = function (array $ing) use ($price): int { $v = 0; foreach ($ing as $s => $n) $v += $price((string)$s) * (int)$n; return $v; };
stops_import_regional();
$acts = fn() => q("SELECT * FROM stop_acts WHERE kind = 'craft' AND active = 1")->fetchAll();

echo "== R5: exact copies are cut, cheap crafts raised\n";
$cut = ['ca_tortilla_press', 'r_mena_ember_sage', 'r_mena_high_pour', 'w1_meadowsweet_tea', 'w4_smoke_trout', 'r_ee_sunflower_toast', 'w4_snail_glaze', 'w1_griddle_cakes'];
ok('the 8 exact copies are not in a new world', !q_val('SELECT COUNT(*) FROM stop_acts WHERE slug IN (' . implode(',', array_fill(0, 8, '?')) . ')', $cut), '');
// every recipe (kitchen and craft) by output: [ingredients, yield]
$rec = [];
foreach (q('SELECT r.ingredients, r.output_qty, i.slug os FROM recipes r JOIN items i ON i.id = r.output_item_id')->fetchAll() as $r) $rec[$r['os']][] = [json_decode((string)$r['ingredients'], true), (int)$r['output_qty']];
$exact = []; $cheap = [];
foreach ($acts() as $a) {
    [$ins, [$os, $oq]] = stop_craft_parts((string)$a['spec']);
    $mine = []; foreach ($ins as [$s, $n]) $mine[$s] = $n;
    foreach ($rec[$os] ?? [] as [$ing, $yq]) {
        $a1 = $mine; $b1 = $ing; ksort($a1); ksort($b1);
        if ($a1 === $b1 && $oq === $yq) $exact[] = $a['slug'];
    }
    if (in_array($os, ['rope', 'timber-plank', 'shell-meal', 'clay-pot'], true)) continue;   // R16 and the part recipes have their own checks
    $cmp = []; foreach ($rec[$os] ?? [] as [$ing, $yq]) if (!array_filter(array_keys($ing), fn($k) => part_key((string)$k))) $cmp[] = $value($ing) / $yq;
    if ($cmp && $value($mine) / $oq < 0.85 * min($cmp)) $cheap[] = $a['slug'] . ' ' . round($value($mine) / $oq) . ' vs ' . round(min($cmp));
}
ok('no rest-stop craft is an exact copy of a recipe (same inputs, same yield)', !$exact, implode(', ', $exact));
ok('no rest-stop craft makes a dish or material for under 85% of the cheapest recipe\'s input value', !$cheap, implode('; ', $cheap));
foreach (STOP_TUNE_2758 as $slug => [$was, $now]) if ((string)q_val('SELECT spec FROM stop_acts WHERE slug = ?', [$slug]) !== $now) $bad[] = $slug;
ok('all ' . count(STOP_TUNE_2758) . ' tuned acts read their new spec', empty($bad), implode(',', $bad ?? []));
ok('a raised act asks for more of its first ingredient only (the enset rope act of R16 aside)', !array_filter(array_diff_key(STOP_TUNE_2758, array_flip(['r_esa_enset_fibre'])), function ($p) {
    [$a, $b] = [stop_craft_parts($p[0]), stop_craft_parts($p[1])];
    if (array_column($a[0], 0) !== array_column($b[0], 0) || $a[1] !== $b[1] || $b[0][0][1] <= $a[0][0][1] || $b[0][0][1] > $a[0][0][1] + 3) return true;
    foreach ($a[0] as $i => [$s, $n]) if ($i > 0 && $n !== $b[0][$i][1]) return true;
    return false;
}));
echo "-- existing world\n";
$old = ['r_esa_enset_fibre' => 'ensete:2>rope:1', 'w5_three_sisters' => 'corn:1,green-bean:1,pumpkin:1>three-sisters-stew:1'];
foreach ($old as $s => $spec) q('UPDATE stop_acts SET spec = ? WHERE slug = ?', [$spec, $s]);
q('UPDATE stop_acts SET spec = ? WHERE slug = ?', ['corn:9>cornbread:1', 'w5_buried_cornbread']);   // an admin edit
q("DELETE FROM settings WHERE name = 'stop_tune_2758'"); setting('__reload__');
upgrade_2758_stop_tune();
$spec = fn(string $s) => (string)q_val('SELECT spec FROM stop_acts WHERE slug = ?', [$s]);
ok('rows at the old spec move', $spec('r_esa_enset_fibre') === STOP_TUNE_2758['r_esa_enset_fibre'][1] && $spec('w5_three_sisters') === STOP_TUNE_2758['w5_three_sisters'][1], $spec('r_esa_enset_fibre') . ' / ' . $spec('w5_three_sisters'));
ok('an admin-edited row is kept', $spec('w5_buried_cornbread') === 'corn:9>cornbread:1');
q('UPDATE stop_acts SET spec = ? WHERE slug = ?', ['hen-egg:7>pancakes:1', 'r_oc_sago_pancakes']);
upgrade_2758_stop_tune();
ok('it runs once (marker)', $spec('r_oc_sago_pancakes') === 'hen-egg:7>pancakes:1' && (string)q_val("SELECT value FROM settings WHERE name = 'stop_tune_2758'") === '1');
q('UPDATE stop_acts SET spec = ? WHERE slug = ?', [STOP_TUNE_2758['w5_buried_cornbread'][0], 'w5_buried_cornbread']);

echo "== R16: plank and rope yields\n";
$row = fn(string $s) => q_one('SELECT * FROM recipes WHERE slug = ?', [$s]);
foreach (['timber-plank' => 3, 'timber-plank-palm' => 2, 'timber-plank-log' => 2, 'timber-plank-birch' => 2, 'timber-plank-oak' => 3, 'timber-plank-drift' => 2, 'timber-plank-palm-trunk' => 2] as $s => $y)
    ok("$s makes $y planks", (int)($row($s)['output_qty'] ?? 0) === $y, (string)($row($s)['output_qty'] ?? '?'));
foreach (['rope', 'rope-cottongrass', 'rope-cattail'] as $s) { $i = json_decode((string)$row($s)['ingredients'], true); ok("$s takes 2 fibres for 1 rope", array_values($i) === [2] && (int)$row($s)['output_qty'] === 1, json_encode($i)); }
ok('goat hair rope: 1 hair for 2 rope', json_decode((string)$row('rope-goat-hair')['ingredients'], true) === ['goat-hair' => 1] && (int)$row('rope-goat-hair')['output_qty'] === 2);
foreach (['timber-plank' => 12, 'rope' => 10] as $out => $base) {
    $bad = [];
    foreach (q('SELECT r.slug, r.ingredients, r.output_qty FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE i.slug = ?', [$out])->fetchAll() as $r) {
        $ing = json_decode((string)$r['ingredients'], true);
        if (array_filter(array_keys($ing), fn($k) => (string)q_val('SELECT category FROM items WHERE slug = ?', [$k]) === 'part' && part_family((string)$k, 'part'))) continue;   // creature-part sink rows (rope-shed-skin) price by the part
        $per = $value($ing) / (int)$r['output_qty'];
        if ($per > 4 * $base || $per < 0.4 * $base) $bad[] = $r['slug'] . ' ' . round($per);
    }
    ok("every $out recipe costs between 0.4x and 4x of one $out in input value", !$bad, implode(', ', $bad));
}
foreach ($acts() as $a) {
    [$ins, [$os, $oq]] = stop_craft_parts((string)$a['spec']);
    if (!in_array($os, ['rope', 'timber-plank'], true)) continue;
    $mine = []; foreach ($ins as [$s, $n]) $mine[$s] = $n;
    $per = $value($mine) / $oq;
    ok($a['slug'] . ' (' . $a['spec'] . ') is no cheaper than the craft (24 a rope, 8 a plank) and not above 4x', $per >= ($os === 'rope' ? 24 : 8) - 0.5 && $per <= 4 * ($os === 'rope' ? 10 : 12), (string)round($per));
}
echo "-- existing world\n";
foreach (PLANK_ROPE_2758 as [$slug, $oi, $oq]) q('UPDATE recipes SET ingredients = ?, output_qty = ? WHERE slug = ?', [json_encode($oi), $oq, $slug]);
q('UPDATE recipes SET output_qty = 9 WHERE slug = ?', ['timber-plank-oak']);   // an admin edit
q("DELETE FROM settings WHERE name = 'plank_rope_2758'"); setting('__reload__');
upgrade_2758_plank_rope();
ok('rows at the old numbers move', (int)$row('timber-plank')['output_qty'] === 3 && json_decode((string)$row('rope-cattail')['ingredients'], true) === ['cattail-root' => 2] && json_decode((string)$row('rope-goat-hair')['ingredients'], true) === ['goat-hair' => 1]);
ok('an admin-edited row is kept', (int)$row('timber-plank-oak')['output_qty'] === 9);
q('UPDATE recipes SET output_qty = 4 WHERE slug = ?', ['timber-plank']);
upgrade_2758_plank_rope();
ok('it runs once', (int)$row('timber-plank')['output_qty'] === 4);
q('UPDATE recipes SET output_qty = 3 WHERE slug = ?', ['timber-plank']); q('UPDATE recipes SET output_qty = 3 WHERE slug = ?', ['timber-plank-oak']);

echo "== R18: wearable pairs differ in materials\n";
$defs = wear_tailor_defs(); $by = [];
foreach ($defs as $slug => $d) $by[$d['region'] . '|' . $d['cat']][(int)$d['n']] = $d;
$same = []; $far = []; $tot = []; $pairs = 0;
foreach ($by as $k => $g) foreach ([[1, 2], [3, 4]] as [$x, $y]) {
    if (!isset($g[$x], $g[$y])) continue;
    $pairs++;
    if ($g[$x]['mats'] === $g[$y]['mats']) $same[] = "$k $x/$y";
    if (array_sum($g[$x]['mats']) !== array_sum($g[$y]['mats'])) $tot[] = "$k $x/$y";
    $vx = $value($g[$x]['mats']); $vy = $value($g[$y]['mats']);
    if (abs($vx - $vy) > 0.2 * max($vx, $vy)) $far[] = "$k $x/$y $vx/$vy";
}
ok('112 pairs (n=1/2 and n=3/4) are checked', $pairs === 112, (string)$pairs);
ok('no pair asks for the same materials', !$same, implode(', ', array_slice($same, 0, 5)));
ok('a pair asks for the same number of materials', !$tot, implode(', ', array_slice($tot, 0, 5)));
ok('a pair\'s two costs are within 20% of each other', !$far, implode(', ', array_slice($far, 0, 5)));
$r5 = array_filter($defs, fn($d) => (int)$d['n'] === 5); $r1 = array_filter($defs, fn($d) => (int)$d['n'] === 1);
ok('the odd one of a pair and the single Rare rows keep the local amounts 2+1 / 3+2 / 4+3 (+1 any-hide)', !array_filter($r1 + $r5, function ($d) { $v = array_values(array_diff_key($d['mats'], ['any-hide' => 1])); return !in_array($v, [[2, 1], [3, 2], [4, 3]], true); }));

echo "== R9 / uA-4 / B1: creature parts in families\n";
$sample = ['antler-shard' => 'plate', 'army-ant-jaw' => 'plate', 'emperor-carapace' => 'plate', 'warthog-tusk' => 'plate', 'hatchling-eggshell' => 'plate', 'snapper-beak' => 'plate', 'mudskipper-fin' => 'plate',
    'dingo-ruff' => 'hide', 'calf-velvet' => 'hide', 'pig-beard' => 'hide', 'hare-foot' => 'hide', 'mandrill-face-patch' => 'hide', 'buzzard-pinion' => 'wing', 'kite-tailfeather' => 'wing',
    'marmot-fat' => 'ooze', 'blubber-chunk' => 'ooze', 'elder-toad-wart' => 'ooze', 'owl-pellet' => 'ooze', 'baron-sash' => 'silk', 'ratline-knot' => 'silk',
    'desert-gem' => 'gem', 'jade-eye' => 'gem', 'toad-jewel' => 'gem', 'golem-pebble' => 'gem', 'stolen-trinket' => 'gem', 'ember-spark' => 'gem', 'glowworm-lantern' => 'gem'];
foreach ($sample as $slug => $fam) ok("$slug is $fam", part_family($slug, 'part') === $fam, (string)part_family($slug, 'part'));
foreach (['stag-beetle-shell', 'dragonfly-wing', 'snow-moth-dust', 'seed-pearl', 'spiral-shell', 'rock-crystal', 'sea-lamp'] as $slug) ok("forage $slug is still no part", part_family($slug, 'forage') === null);
$left = [];
foreach (q("SELECT i.slug FROM items i WHERE i.category = 'part' AND EXISTS (SELECT 1 FROM creature_drops d WHERE d.item_id = i.id) ORDER BY i.slug")->fetchAll() as $r) if (!part_family((string)$r['slug'], 'part')) $left[] = $r['slug'];
$allowed = ['beeswax', 'black-truffle', 'foxfire-cap', 'gorse-flower', 'honeydew', 'lavender', 'living-moss', 'nest-scrap', 'nettle-fibre', 'palm-sugar', 'paper-comb', 'peat-brick', 'pika-haypile', 'star-tendril', 'tallow-wax', 'termite-clay',
    'thistle-heart', 'vine-twine', 'vole-nest-grass', 'weaver-silk-leaf', 'white-clover', 'willow-withies', 'forager-s-crumb'];
ok('every dropped creature part is in a family, except plants, nests and materials with a recipe of their own', !array_diff($left, $allowed), implode(',', array_diff($left, $allowed)));
ok('no family took a non-part or a currency', part_family('tailors-thread', 'part') === null && part_family('rope', 'part') === null && part_family('timber-plank', 'part') === null && part_family('beeswax', 'part') === null);

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
