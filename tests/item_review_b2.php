<?php
// Item review group B part 2 (2.7.58): uA-1/uA-2 drop twins, R3 edelweiss, R4 stop acts, E2 tool prices, E5 dish pricing, E8 buff confirm, EC4/E7 festival, EC11 hovel decor label.
// php tests/item_review_b2.php GAME_DIR (installed game with player "sprout").
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
foreach (['catalog', 'adventure_data', 'upgrade2758', 'festival', 'tools', 'items', 'world', 'home_slim'] as $f) require_once $argv[1] . '/includes/' . $f . '.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$have = fn(int $id) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
$iid = fn(string $slug) => (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
$fu = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);

$today = gclock_my_date(); $day = fn(int $n) => gmdate('Y-m-d', strtotime($today . ' UTC') + $n * 86400);
$scenario = (string)($argv[3] ?? '');
// the festival scenarios run in a fresh process (festival_active() caches for the request and the install already made it); main() below arranges the rows and starts this
if (($argv[2] ?? '') === 'fest') {
    $f = festival_active();
    ok('the festival is on', (bool)$f);
    $first = $scenario === 'first';
    ok($first ? 'the run in progress keeps the plain slug (rows from before this release stay valid)' : 'a second run gets its own key', function_exists('festival_run_key') && ($f['run'] ?? '') === ($first ? 'opening_day' : 'opening_day@' . $f['starts']), (string)($f['run'] ?? 'none'));
    $c0 = $have($iid('plain-compost')); $m0 = (int)$fu()['coins'];
    [$bo, $bm] = festival_buy($fu(), 'compost', 0);
    if ($first) ok('its used-up stall limit still blocks', !$bo, (string)$bm);
    else {
        ok('last run\'s used-up stall limit does not block it', $bo, (string)$bm);
        ok('the compost deal is a bundle of 6 for 50', $have($iid('plain-compost')) === $c0 + 6 && (int)$fu()['coins'] === $m0 - 50, ($have($iid('plain-compost')) - $c0) . ' for ' . ($m0 - (int)$fu()['coins']));
    }
    [$fo, $fm] = festival_find_flag($fu());
    $n = function_exists('festival_flags') ? festival_flags((string)($f['run'] ?? 'x'), $uid) : -1;
    ok($first ? 'today\'s flag is the 4th and the claimed 3-flag reward is not paid twice' : 'today\'s flag is the 1st of the new run', $fo && $n === ($first ? 4 : 1) && !str_contains((string)$fm, '150 Petals'), $n . ' ' . $fm);
    if (!$first && function_exists('festival_run_key')) {
        ok('dates nudged by a couple of days stay the same run', ($k = festival_run_key(['slug' => 'opening_day', 'starts' => $day(1)])) === $f['run'], $k . ' vs ' . $f['run']);
        ok('a run a year on is a new key', festival_run_key(['slug' => 'opening_day', 'starts' => $day(364)]) !== $f['run']);
    }
    echo $fails ? "$fails FAILED\n" : "ok\n";
    exit($fails ? 1 : 0);
}

echo "== uA-1 / uA-2 a drop named like a flower or crop is the real item\n";
ok('Cornflower -> Cut Cornflower', pfc_item_for_drop('Cornflower') === $iid('cut-cornflower'), (string)pfc_item_for_drop('Cornflower'));
ok('Heather -> Cut Heather', pfc_item_for_drop('Heather') === $iid('cut-heather'));
ok('Date Palm -> Dates', pfc_item_for_drop('Date Palm') === $iid('date'));
ok('Prickly Pear Cactus -> Prickly Pears', pfc_item_for_drop('Prickly Pear Cactus') === $iid('nopal'));
ok('Water Spinach -> the produce', pfc_item_for_drop('Water Spinach') === $iid('kangkong'));
ok('Lavender stays the part the teas use', pfc_item_for_drop('Lavender') === $iid('lavender') && (string)q_val("SELECT category FROM items WHERE slug = 'lavender'") === 'part');
ok('Edelweiss stays the gatherable', pfc_item_for_drop('Edelweiss') === $iid('edelweiss'));
$twins = (int)q_val("SELECT COUNT(*) FROM items t JOIN plants p ON LOWER(p.name) = LOWER(t.name) WHERE t.category = 'part' AND p.produce_item_id IS NOT NULL AND t.slug <> 'lavender'");
ok('a fresh world has no part item named like a plant', $twins === 0, (string)$twins);
// merge on an existing world: a twin with a drop and satchel stock
$cr = (int)q_val('SELECT id FROM creatures ORDER BY id LIMIT 1');
$real = $iid('cut-cornflower');
$twin = $iid('cornflower') ?: db_insert('items', ['name' => 'Cornflower', 'slug' => 'cornflower', 'category' => 'part', 'rarity' => 20, 'base_price' => 8, 'description' => 'twin']);
q('DELETE FROM creature_drops WHERE creature_id = ? AND item_id IN (?, ?)', [$cr, $twin, $real]);
db_insert('creature_drops', ['creature_id' => $cr, 'item_id' => $twin, 'chance' => 30]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?, ?)', [$uid, $twin, $real]);
give_item($uid, $twin, 3); give_item($uid, $real, 2);
set_setting('drop_twins_2758', '');
function_exists('upgrade_2758_drop_twins') ? upgrade_2758_drop_twins() : null;
ok('the drop row points at the cut flower', (int)q_val('SELECT COUNT(*) FROM creature_drops WHERE creature_id = ? AND item_id = ?', [$cr, $real]) === 1 && !q_val('SELECT 1 FROM creature_drops WHERE item_id = ?', [$twin]));
ok('satchel stock moved (3 + 2)', $have($real) === 5 && $have($twin) === 0, $have($real) . '/' . $have($twin));
function_exists('upgrade_2758_drop_twins') ? upgrade_2758_drop_twins() : null;
ok('a second run changes nothing', $have($real) === 5);

echo "== R3 edelweiss recipes take the cut flower too\n";
foreach (['rock-garden-cut' => 'rock-garden', 'grand-healing-elixir-cut' => 'grand-healing-elixir'] as $rs => $out) {
    $r = q_one('SELECT * FROM recipes WHERE slug = ?', [$rs]);
    $ing = $r ? (json_decode((string)$r['ingredients'], true) ?: []) : [];
    ok("$rs exists, takes cut-edelweiss, makes $out", $r && isset($ing['cut-edelweiss']) && !isset($ing['edelweiss']) && (int)$r['output_item_id'] === $iid($out));
}

echo "== R4 the three stop crafts make the dedicated item\n";
$want = ['r_wca_egusi_soup' => 'egusi-soup', 'r_ee_buckwheat_kasha' => 'buckwheat-kasha', 'r_wca_roselle_cordial' => 'hibiscus-cordial'];
foreach ($want as $s => $o) { $sp = (string)q_val('SELECT spec FROM stop_acts WHERE slug = ?', [$s]); ok("$s makes $o", str_ends_with($sp, '>' . $o . ':1') && $iid($o) > 0, $sp); }
q('UPDATE stop_acts SET spec = ? WHERE slug = ?', ['egusi:2,okra:2>garden-vegetable-soup:1', 'r_wca_egusi_soup']);
q('UPDATE stop_acts SET spec = ? WHERE slug = ?', ['buckwheat:9>goat-milk-porridge:1', 'r_ee_buckwheat_kasha']);   // an admin edit
q('UPDATE stop_acts SET spec = ? WHERE slug = ?', ['hibiscus:3,garden-honey:1>mixed-berry-cordial:1', 'r_wca_roselle_cordial']);
set_setting('stop_acts_2758', '');
function_exists('upgrade_2758_stop_acts') ? upgrade_2758_stop_acts() : null;
$sp = fn(string $s) => (string)q_val('SELECT spec FROM stop_acts WHERE slug = ?', [$s]);
ok('an old spec is moved (egusi, hibiscus)', str_ends_with($sp('r_wca_egusi_soup'), '>egusi-soup:1') && str_ends_with($sp('r_wca_roselle_cordial'), '>hibiscus-cordial:1'));
ok('an edited spec is kept', $sp('r_ee_buckwheat_kasha') === 'buckwheat:9>goat-milk-porridge:1');

echo "== E2 Twigg's tier 2-4 tools cost less\n";
$bad = [];
foreach (defined('TOOL_OLD_PRICES_2758') ? TOOL_OLD_PRICES_2758 : ['garden-hoe' => 250, 'steel-spade' => 1200] as $slug => $old) { $p = (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$slug]); if ($p < 1 || $p > $old * 0.75) $bad[] = "$slug $p/$old"; }
ok('every tier 2-4 tool is at most 75% of its old price', !$bad, implode(', ', $bad));
$hoe = $iid('garden-hoe'); $spade = $iid('steel-spade');
$min = (int)q_val('SELECT MIN(price_min) FROM shop_stock WHERE item_id = ?', [$hoe]);
ok('the shop row follows (garden hoe at 90% of its price)', $min > 0 && $min === (int)floor((int)q_val('SELECT base_price FROM items WHERE id = ?', [$hoe]) * 0.9), (string)$min);
q('UPDATE items SET base_price = 250 WHERE slug IN (?, ?)', ['garden-hoe', 'broken-garden-hoe']);
q('UPDATE shop_stock SET price_min = 225, price_max = 300, current_price = 250 WHERE item_id = ?', [$hoe]);
q('UPDATE items SET base_price = 999 WHERE id = ?', [$spade]);   // an admin price
set_setting('tool_prices_2758', '');
function_exists('upgrade_2758_tool_prices') ? upgrade_2758_tool_prices() : null;
ok('an old-priced tool and its shop row move', (int)q_val('SELECT base_price FROM items WHERE id = ?', [$hoe]) === 150 && (int)q_val('SELECT price_min FROM shop_stock WHERE item_id = ?', [$hoe]) === 135);
ok('an admin price is kept', (int)q_val('SELECT base_price FROM items WHERE id = ?', [$spade]) === 999);

echo "== E5 a dish is priced from its ingredients' flat value x a tier factor\n";
$L = item_lookups(); $badDish = []; $badRaw = []; $n = 0;
foreach (q("SELECT r.slug, r.tier, r.ingredients, i.* FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.category = 'cooking' AND i.slug NOT LIKE 'bought-%'")->fetchAll() as $r) {
    if (shop_stock_rows((int)$r['id'])) continue;   // a stocked dish is capped by its shop price
    $ing = json_decode((string)$r['ingredients'], true) ?: [];
    $raw = 0; foreach ($ing as $s => $k) $raw += flat_sell_value(q_one('SELECT * FROM items WHERE slug = ?', [$s]), $L) * (int)$k;
    if (flat_sell_value($r, $L) < $raw) $badRaw[] = $r['slug'] . ' ' . flat_sell_value($r, $L) . '<' . $raw;
    $n++;
    $want = function_exists('dish_price') ? dish_price($ing, (string)$r['tier'], $L) : null;
    if ($want !== (int)$r['base_price']) $badDish[] = $r['slug'] . ' ' . $r['base_price'] . '/' . var_export($want, true);
}
ok("all $n dishes sit at dish_price()", !$badDish && $n > 50, implode(', ', array_slice($badDish, 0, 5)) . " n=$n");
ok('no dish sells for less than its raw ingredients', !$badRaw, implode(', ', array_slice($badRaw, 0, 5)));

echo "== E8 a weaker buff asks before it replaces a stronger one\n";
$mk = fn(string $slug, array $temp) => $iid($slug) ?: db_insert('items', ['name' => $slug, 'slug' => $slug, 'category' => 'food', 'rarity' => 1, 'base_price' => 5, 'edible' => 1, 'description' => 't', 'effects' => json_encode(['temp' => $temp])]);
$weak = $mk('zz-weak-snack', ['grit' => 1, 'minutes' => 20]); $strong = $mk('zz-strong-feast', ['grit' => 5, 'hardiness' => 4, 'minutes' => 600]);
$setBuff = fn() => q('UPDATE users SET buff = ?, buff_until = ?, buff2 = NULL, buff2_until = NULL WHERE id = ?', [json_encode(['grit' => 4, 'hardiness' => 3]), gmdate('Y-m-d H:i:s', time() + 480 * 60), $uid]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?, ?)', [$uid, $weak, $strong]);
give_item($uid, $weak, 3); give_item($uid, $strong, 1); $setBuff();
[$r1, $m1, $c1] = eat_item($fu(), $weak, false) + [2 => ''];
ok('refused with a confirm flag, nothing eaten, buff kept', !$r1 && $c1 === 'confirm' && $have($weak) === 3 && str_contains((string)$fu()['buff'], 'hardiness'), json_encode($m1));
[$r2] = eat_item($fu(), $weak, true);
ok('confirmed: eaten and the buff replaced', $r2 && $have($weak) === 2 && $fu()['buff'] === json_encode(['grit' => 1]));
$setBuff(); $_SESSION['eat_confirm'] = [$weak, (int)floor(time() / 120)];
[$r3] = eat_item($fu(), $weak);
ok('a second try of the same item counts as the confirmation', $r3 && $have($weak) === 1);
q('UPDATE users SET buff = ?, buff_until = ? WHERE id = ?', [json_encode(['grit' => 1]), gmdate('Y-m-d H:i:s', time() + 600), $uid]);
[$r4] = eat_item($fu(), $strong, false);
ok('a stronger buff replaces without asking', $r4 && str_contains((string)$fu()['buff'], 'hardiness'));
q('UPDATE users SET buff = NULL, buff_until = NULL WHERE id = ?', [$uid]);
[$r5] = eat_item($fu(), $weak, false);
ok('no live buff: no question', $r5);

echo "== EC4 / E7 festival\n";
$arrange = function (string $scenario) use ($uid, $day) {
    set_setting('festivals_on', '1'); set_setting('fest_opening_day_start', $day($scenario === 'first' ? -3 : -1)); set_setting('fest_opening_day_end', $day(5)); set_setting('fest_opening_day_run', '');
    foreach (['festival_flags', 'festival_claims', 'festival_buys'] as $t) q("DELETE FROM $t WHERE festival LIKE 'opening_day%'");
    q('UPDATE users SET coins = 5000 WHERE id = ?', [$uid]);
    $first = $scenario === 'first';   // a run in progress from before this release: this window's flags, a claimed reward, a used-up stall limit, all under the plain slug
    for ($d = 0; $d < 3; $d++) db_insert('festival_flags', ['festival' => 'opening_day', 'user_id' => $uid, 'day' => $first ? $day(-1 - $d) : $day(-365 + $d), 'at' => now()]);
    db_insert('festival_claims', ['festival' => 'opening_day', 'user_id' => $uid, 'reward' => 'flags3', 'at' => now()]);
    db_insert('festival_buys', ['festival' => 'opening_day', 'user_id' => $uid, 'stall' => 'compost:0', 'qty' => 9]);
};
$scenario = (string)($argv[3] ?? '');
foreach (['second', 'first'] as $sc) {
    echo "-- scenario: $sc\n";
    $arrange($sc);
    $out = (string)shell_exec(escapeshellarg(PHP_BINARY) . ' -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp ' . escapeshellarg(__FILE__) . ' ' . escapeshellarg($argv[1]) . ' fest ' . $sc . ' 2>&1');
    echo preg_replace('/^== .*\n/', '', $out);
    $fails += preg_match_all('/^\s*FAIL |EXCEPTION|Fatal error/m', $out);
}
$bad = [];
foreach (festival_defs()['opening_day']['stalls'] as $s) {
    if ($s['key'] === 'bunting') continue;
    foreach ($s['sells'] as $g) { $base = (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$g[0]]); if ($g[1] / ($g[3] ?? 1) > $base * 1.25) $bad[] = $g[0] . ' ' . round($g[1] / ($g[3] ?? 1), 1) . ' vs base ' . $base; }
}
ok('no stall piece costs more than 1.25x base', !$bad, implode(', ', $bad));
$bun = q_one("SELECT * FROM recipes WHERE slug = 'opening-day-bunting'");
ok('the Opening Day Bunting can also be crafted', $bun && (int)$bun['output_item_id'] === $iid('opening-day-bunting'));

echo "== EC11 a hovel decor item with no source says coming soon\n";
[$dok, $dmsg] = hovel_decor_set($uid, 'floor', 'moss');
ok('not available, and not promising a Market price', !$dok && str_contains(strtolower($dmsg), 'coming soon') && !str_contains($dmsg, 'Petals'), $dmsg);

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
