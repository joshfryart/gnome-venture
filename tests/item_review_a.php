<?php
// Item review group A (2.7.58), data rows: cheaper camping / decor alt recipes, sinks for dead items, hybrids in dishes, Dewdrop Kitchen soup price, weak dish buffs, keepsake effects,
// and the boot step item_review_data_2758 that carries the changed rows to an existing world. php tests/item_review_a.php GAME_DIR (installed game; ci_suites.sh installs one first).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/crafting.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$rec = fn(string $slug) => q_one('SELECT * FROM recipes WHERE slug = ?', [$slug]);
$ing = fn(string $slug) => json_decode((string)($rec($slug)['ingredients'] ?? '{}'), true) ?: [];
$price = fn(string $s) => (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$s]);
$value = function (array $ings) use ($price) { $v = 0; foreach ($ings as $s => $n) $v += $price($s) * $n; return $v; };
/** Every ingredient of a recipe is a real item (a typo in a data row would make it forever uncraftable). */
$real = function (string $slug) use ($ing) { foreach (array_keys($ing($slug)) as $s) if (!part_key((string)$s) && !q_val('SELECT 1 FROM items WHERE slug = ?', [$s])) return false; return (bool)$ing($slug); };
$usedAnywhere = function (string $item) { foreach (q('SELECT ingredients FROM recipes')->fetchAll(PDO::FETCH_COLUMN) as $j) if (isset((json_decode((string)$j, true) ?: [])[$item])) return true; return false; };

echo "== E1 camping gear: cheaper alt rows (the 100-Petal shop price is unchanged)\n";
foreach (['metal-pins-flint' => 'metal-pins', 'camping-pot-clay' => 'camping-pot', 'canvas-sheet-coir' => 'canvas-sheet'] as $alt => $base) {
    $r = $rec($alt);
    ok("$alt exists and makes the same item as $base", $r && $r['output_item_id'] === $rec($base)['output_item_id'] && $real($alt));
    ok("$alt is cheaper than $base per item", $r && $value($ing($alt)) / max(1, (int)$r['output_qty']) < $value($ing($base)) / max(1, (int)$rec($base)['output_qty']));
}
$cheap = $value($ing('metal-pins-flint')) + $value($ing('camping-pot-clay')) + $value($ing('canvas-sheet-coir'));
ok('camping gear: the cheap parts plus rope and planks stay near the 100 shop price', $cheap > 0 && $cheap + 2 * $price('rope') + 2 * $price('timber-plank') <= 150, (string)$cheap);
ok('camping_gear_price is still 100', (int)(setting('camping_gear_price') ?: 100) === 100);
ok('the game_clock comment no longer claims about 60 Petals', !str_contains((string)file_get_contents($argv[1] . '/includes/game_clock.php'), 'about 60 Petals'));

echo "== E3 decor: cheaper alt rows\n";
foreach (['firefly-jar-small' => 'firefly-jar', 'toadstool-ring-small' => 'toadstool-ring'] as $alt => $base) {
    ok("$alt makes $base and is cheaper", $rec($alt) && $real($alt) && $rec($alt)['output_item_id'] === $rec($base)['output_item_id'] && $value($ing($alt)) < $value($ing($base)));
}

echo "== uA-5 black truffle, B2 legacy parts, B3 trek parts, B5 hybrids have a use\n";
ok('black-truffle is an ingredient', $usedAnywhere('black-truffle'));
foreach (['rat-pelt', 'rat-tooth', 'snake-skin', 'snake-fang', 'shed-skin', 'spider-fang', 'venom-fang', 'slug-slime', 'snail-slime', 'leech-slime', 'stolen-trinket', 'spotted-hide', 'gnat-dust', 'aphid-wings', 'flea-legs', 'ant-chitin', 'earwig-pincer', 'moth-wing', 'wing-dust', 'paper-comb', 'croak-sac', 'frog-skin', 'scorpion-plate', 'centipede-plate', 'forager-s-crumb'] as $p) ok("legacy part $p has a recipe", $usedAnywhere($p));
foreach (['newt-tail', 'pale-scale', 'quartz-shell', 'silverfish-scales'] as $p) ok("trek part $p has a recipe", $usedAnywhere($p));
foreach (['triticale', 'tritordeum', 'pomato', 'raphanobrassica', 'tangor', 'orangelo', 'sunrise-lime', 'nessberry'] as $h) ok("hybrid $h is cooked", $usedAnywhere($h));
$bad = [];
foreach (q("SELECT slug FROM recipes")->fetchAll(PDO::FETCH_COLUMN) as $s) if (!$real((string)$s)) $bad[] = $s;
ok('every recipe ingredient is a real item', !$bad, implode(' ', array_slice($bad, 0, 8)));

echo "== E6 soup restock at 1.0x base, E9 dish buffs, uA-3/B4 keepsakes (new world)\n";
$stock = fn() => q_one("SELECT st.* FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE i.slug = 'bought-garden-vegetable-soup'");
$soupBase = $price('garden-vegetable-soup');
$s = $stock();
ok('Dewdrop Kitchen soup is stocked at 1.0x the home dish base', $s && (int)$s['price_min'] === $soupBase && (int)$s['price_max'] === $soupBase && (int)$s['current_price'] === $soupBase, json_encode($s));
$fxOf = fn(string $slug) => json_decode((string)q_val('SELECT effects FROM items WHERE slug = ?', [$slug]), true) ?: [];
$pts = function (array $fx) { $t = $fx['temp'] ?? []; $m = (int)($t['minutes'] ?? 0); unset($t['minutes']); return array_sum($t) * $m / 60; };
$rawBest = function (string $dish) use ($fxOf) { $best = 0; foreach (array_keys(json_decode((string)q_val('SELECT ingredients FROM recipes WHERE slug = ?', [$dish]), true) ?: []) as $i) { $t = ($fxOf($i)['temp'] ?? []); $m = (int)($t['minutes'] ?? 0); unset($t['minutes']); $best = max($best, array_sum($t) * $m / 60); } return $best; };
foreach (['grilled-sardines', 'toffee-apple', 'sunflower-snack', 'goat-cheese-salad'] as $d) ok("$d buffs at least as much as its best raw ingredient", $pts($fxOf($d)) >= $rawBest($d), $pts($fxOf($d)) . ' vs ' . $rawBest($d));
$keep = ['brass-button', 'dew-pearl', 'echo-pebble', 'frost-window-pane', 'lagoon-glass-bead', 'lost-sock', 'mirage-marble', 'mirror-pebble', 'wishing-coin', 'raindrop-bead', 'squeaky-ice-chip', 'seaside-stationery', 'taper', 'old-river-pebble', 'rivers-postcard', 'root-race-ribbon', 'visitors-book-page'];
require_once $argv[1] . '/includes/trail_sights.php';
trail_sight_b_ensure();
$none = array_values(array_filter($keep, fn($k) => !isset($fxOf($k)['keepsake']['gather'])));
ok('all 17 curios and trinkets carry a keepsake effect', !$none, implode(' ', $none));
ok('keepsake data lints clean', !array_filter(trail_sight_b_data_lint(), fn($p) => str_contains($p, 'keepsake')));

echo "== an existing world: ensure_crafts adds the new rows, the boot step carries the changed ones, once, and keeps admin edits\n";
q("DELETE FROM recipes WHERE slug IN ('metal-pins-flint', 'firefly-jar-small', 'feast-truffle-risotto')"); q("DELETE FROM items WHERE slug = 'feast-truffle-risotto'");
ensure_crafts();
ok('ensure_crafts re-adds a missing alt row and a missing dish', $rec('metal-pins-flint') && $rec('firefly-jar-small') && $rec('feast-truffle-risotto'));
$old = ['grilled-sardines' => '{"temp":{"grit":2,"minutes":120},"energy":4}', 'toffee-apple' => '{"temp":{"charm":2,"minutes":120},"energy":6}'];
foreach ($old as $sl => $j) q('UPDATE items SET effects = ? WHERE slug = ?', [$j, $sl]);
q("UPDATE items SET effects = ? WHERE slug = 'sunflower-snack'", ['{"temp":{"nimble":5,"minutes":300},"energy":6}']);   // an admin's own edit
q("UPDATE shop_stock SET price_min = 40, price_max = 55, current_price = 45 WHERE id = ?", [(int)$stock()['id']]);
q("UPDATE items SET base_price = 20 WHERE slug = 'bought-garden-vegetable-soup'");
q("DELETE FROM settings WHERE name = 'item_review_data_2758'"); setting('__reload__');
require_once $argv[1] . '/includes/upgrade2758.php';
upgrade_2758_data();
$s = $stock();
ok('soup stock moves to 1.0x base', (int)$s['price_min'] === $soupBase && (int)$s['price_max'] === $soupBase && (int)$s['current_price'] === $soupBase, json_encode($s));
ok('the shop-bought soup keeps half the stock price as its base', $price('bought-garden-vegetable-soup') === (int)floor($soupBase * 0.5), (string)$price('bought-garden-vegetable-soup'));
ok('weak dishes raised', $pts($fxOf('grilled-sardines')) >= $rawBest('grilled-sardines') && $pts($fxOf('toffee-apple')) >= $rawBest('toffee-apple'));
ok('an admin-edited dish is left alone', ($fxOf('sunflower-snack')['temp']['nimble'] ?? 0) === 5);
setting('__reload__');
ok('marker set', setting('item_review_data_2758') === '1');
q("UPDATE shop_stock SET price_min = 61, price_max = 61, current_price = 61 WHERE id = ?", [(int)$stock()['id']]);
upgrade_2758_data();
ok('a second run changes nothing', (int)$stock()['price_min'] === 61);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
