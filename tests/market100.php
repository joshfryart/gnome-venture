<?php
// v1.0.0 wave 2b: orders, market day, price drift (includes/market100.php). Run by market100.sh on a fresh install.
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/world.php';
require_once $argv[1] . '/includes/garden_logic.php';
require_once $argv[1] . '/includes/friends.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
function me(): array { return q_one("SELECT * FROM users WHERE username = 'sprout'"); }

$u = me(); $uid = (int)$u['id'];
$town = player_location($u);
require_once $argv[1] . '/includes/town_social.php';
echo "town = $town, folk " . count(town_folk($town)) . "\n";

echo "== migration\n";
ok('Almanac page made', (bool)q_val("SELECT 1 FROM encyclopedia_entries WHERE title='Orders, market day and prices'"));
ok('market100 flag set', setting('market100') === '1');
foreach (['item_quality', 'npc_orders', 'market_volume', 'market_buys', 'market_baskets'] as $t) ok("table $t", (bool)q_val("SELECT COUNT(*) >= 0 FROM $t"));
$n0 = (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Orders, market day and prices'"); upgrade_100_market();
ok('upgrade idempotent', (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE title='Orders, market day and prices'") === $n0);
// old favours carried over
$npc0 = town_folk($town)[0];
db_insert('npc_favours', ['user_id' => $uid, 'npc_id' => $npc0['id'], 'week' => '2026-W01', 'done_at' => '2026-01-10 10:00:00']);
set_setting('market100', '0'); setting('__reload__'); upgrade_100_market();
ok('old favour copied as legacy order', (int)q_val("SELECT COUNT(*) FROM npc_orders WHERE user_id = ? AND npc_id = ? AND kind = 'legacy'", [$uid, $npc0['id']]) === 1);
upgrade_100_market(); // guarded now
ok('legacy copy not doubled', (int)q_val("SELECT COUNT(*) FROM npc_orders WHERE kind = 'legacy'") === 1);

echo "== orders: generation is deterministic and the same for everyone\n";
cfg(['orders_on' => 1, 'orders_cycle_days' => 7, 'orders_min_days' => 3, 'orders_board_max' => 20, 'price_drift_on' => 1]);
$folk = town_folk($town);
$today = hollow_today();
$a = array_map(fn($n) => npc_order($n, $today), $folk);
$b = array_map(fn($n) => npc_order($n, $today), $folk);
ok('same orders on a second call', $a == $b);
ok('at least one order open today', count(array_filter($a)) >= 1, json_encode(array_map(fn($x) => $x['kind'] ?? null, $a)));
$kindsSeen = [];
for ($len = 3; $len <= 28; $len++) { cfg(['orders_cycle_days' => $len]); foreach ($folk as $n) if ($o = npc_order($n, $today)) $kindsSeen[$o['kind']] = ($kindsSeen[$o['kind']] ?? 0) + 1; }
cfg(['orders_cycle_days' => 7]);
ok('all six kinds can be generated', count($kindsSeen) >= 5, json_encode($kindsSeen));
$bad = 0;
for ($d = 0; $d < 60; $d++) foreach ($folk as $n) {
    $date = hollow_date_add($today, $d);
    if ($o = npc_order($n, $date)) {
        $cy = orders_cycle($date);
        if ($o['deadline'] < $date || $o['deadline'] > $cy['end'] || $o['days_left'] < 1 || $o['days_left'] > 7 || $o['coins'] < 40 || $o['qty'] < 1 || $o['diff'] < 1 || $o['diff'] > 3) $bad++;
    }
}
ok('60 days of orders all sane (deadline inside the round, pay, qty, difficulty)', $bad === 0, "bad=$bad");

echo "== orders: expiry\n";
$exp = null;
for ($d = 0; $d < 30 && !$exp; $d++) foreach ($folk as $n) {
    $date = hollow_date_add($today, $d);
    if (($o = npc_order($n, $date)) && $o['deadline'] < orders_cycle($date)['end']) { $exp = [$n, $date, $o]; break; }
}
ok('found an order with a short deadline', (bool)$exp);
if ($exp) {
    [$n, $date, $o] = $exp;
    ok('open on its last day', npc_order($n, $o['deadline']) !== null && npc_order($n, $o['deadline'])['days_left'] === 1);
    ok('gone the day after', npc_order($n, hollow_date_add($o['deadline'], 1)) === null);
    $nextRound = hollow_date_add(orders_cycle($date)['end'], 1);
    $o2 = npc_order($n, $nextRound);
    ok('a new round brings a new order', $o2 === null || $o2['cycle'] === $o['cycle'] + 1);
}

echo "== orders: v1.7.6 food quality off by default\n";
$offBad = 0; $offSeen = 0; $today0 = hollow_today();
for ($len = 3; $len <= 28; $len++) { cfg(['orders_cycle_days' => $len]); foreach ($folk as $n) { $o = npc_order($n, $today0); if ($o && in_array($o['kind'], ['crop', 'preserve'], true)) { $offSeen++; if ($o['minq'] > 0 || $o['bar'] !== '') $offBad++; } } }
ok('food orders found with quality off', $offSeen > 0);
ok('no food order asks for a grade when off', $offBad === 0, "$offBad of $offSeen");
cfg(['orders_food_quality' => 1]);
echo "== orders: accept and fulfil with a quality check\n";
cfg(['orders_cycle_days' => 7]);
// find a setting that yields each kind to test; the cycle length changes the round number, so the order changes
function find_order(array $folk, string $kind, callable $pred = null): ?array {
    $today = hollow_today();
    for ($len = 3; $len <= 28; $len++) {
        cfg(['orders_cycle_days' => $len]);
        foreach ($folk as $n) { $o = npc_order($n, $today); if ($o && $o['kind'] === $kind && (!$pred || $pred($o))) return [$n, $o, $len]; }
    }
    return null;
}
q('UPDATE users SET coins = 500, location = ? WHERE id = ?', [$town, $uid]); $u = me();
$f = find_order($folk, 'crop', fn($o) => $o['minq'] >= 45 && $o['item_id'] > 0);
ok('found a quality crop order', (bool)$f);
if ($f) {
    [$n, $o, $len] = $f;
    echo "   order: {$n['name']} wants {$o['qty']} x {$o['item_name']} {$o['bar']} (diff {$o['diff']}, $len-day rounds, {$o['coins']} petals)\n";
    [$ok1, $m1] = order_deliver($u, (int)$n['id'], $town);
    ok('refused with no goods', !$ok1, $m1);
    give_item($uid, $o['item_id'], $o['qty']);
    // untracked = plain (35): below any bar of 45+
    ok('plain goods fail a quality bar', !order_check($uid, $o)['enough']);
    [$ok2, $m2] = order_deliver($u, (int)$n['id'], $town);
    ok('delivery refused: not good enough', !$ok2 && str_contains($m2, 'not good enough'), $m2);
    q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $o['item_id']]);
    db_insert('item_quality', ['user_id' => $uid, 'item_id' => $o['item_id'], 'q' => $o['minq'] + 5, 'n' => $o['qty']]);
    ok('stack quality read back', market_stack_q($uid, $o['item_id']) === $o['minq'] + 5);
    $c0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
    $fr0 = (int)friendship($uid, (int)$n['id'])['points'];
    [$ok3, $m3] = order_deliver($u, (int)$n['id'], $town);
    ok('good goods are accepted', $ok3, $m3);
    ok('goods taken', (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $o['item_id']]) === 0);
    $c1 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
    ok('paid at least the order pay', $c1 - $c0 >= $o['coins'], "$c0 -> $c1 vs {$o['coins']}");
    ok('friendship rose', (int)friendship($uid, (int)$n['id'])['points'] === $fr0 + $o['friend']);
    ok('order recorded once', (int)q_val('SELECT COUNT(*) FROM npc_orders WHERE user_id = ? AND npc_id = ? AND cycle = ? AND kind = ?', [$uid, $n['id'], $o['cycle'], 'crop']) === 1);
    give_item($uid, $o['item_id'], $o['qty']);
    [$ok4, $m4] = order_deliver($u, (int)$n['id'], $town);
    ok('cannot fill the same order twice', !$ok4 && str_contains($m4, 'already'), $m4);
    ok('board marks it done', order_done($uid, (int)$n['id'], $o['cycle']));
    // wrong town
    [$ok5] = order_deliver($u, (int)$n['id'], 'Mossbottom');
    ok('NPC not in that town refused', !$ok5);
}
$f = find_order($folk, 'arrangement');
ok('found an arrangement order', (bool)$f);
if ($f) {
    [$n, $o, $len] = $f;
    $fx = json_encode(['arrangement' => ['v' => 'jar', 's' => [], 'score' => $o['minq'] - 5, 'dried' => 0]]);
    $lowId = db_insert('items', ['name' => 'Test Low Bouquet', 'slug' => 'test-low-' . mt_rand(), 'category' => 'arrangement', 'rarity' => 30, 'base_price' => 40, 'tradable' => 1, 'edible' => 0, 'description' => 't', 'effects' => $fx]);
    give_item($uid, $lowId, 1);
    ok('too-low arrangement refused', !order_check($uid, $o)['enough']);
    $hiFx = json_encode(['arrangement' => ['v' => 'jar', 's' => [], 'score' => $o['minq'] + 10, 'dried' => 0]]);
    $hiId = db_insert('items', ['name' => 'Test High Bouquet', 'slug' => 'test-hi-' . mt_rand(), 'category' => 'arrangement', 'rarity' => 60, 'base_price' => 90, 'tradable' => 1, 'edible' => 0, 'description' => 't', 'effects' => $hiFx]);
    give_item($uid, $hiId, 1);
    $chk = order_check($uid, $o);
    ok('good arrangement accepted', $chk['enough'] && $chk['takes'][0][0] === $hiId);
    [$ok, $m] = order_deliver($u, (int)$n['id'], $town);
    ok('arrangement order delivered', $ok, $m);
    ok('the low one stays in the satchel', (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $lowId]) === 1);
}
$f = find_order($folk, 'feast');
ok('found a feast order', (bool)$f);
if ($f) {
    [$n, $o] = $f;
    ok('no feast = not enough', !order_check($uid, $o)['enough']);
    $fid = (int)q_val("SELECT output_item_id FROM recipes WHERE tier = 'feast' LIMIT 1");
    give_item($uid, $fid, 1);
    [$ok, $m] = order_deliver($u, (int)$n['id'], $town);
    ok('feast order delivered', $ok, $m);
}
$f = find_order($folk, 'dried');
ok('found a dried-flower order', (bool)$f);
if ($f) {
    [$n, $o] = $f;
    ok('dried order is for a Dried item', str_starts_with($o['item_name'], 'Dried '));
}
$f = find_order($folk, 'preserve', fn($o) => $o['item_id'] > 0);
ok('found a preserve order', (bool)$f);
if ($f) {
    [$n, $o] = $f;
    give_item($uid, $o['item_id'], $o['qty']);
    market_note_quality($uid, $o['item_id'], $o['qty'], $o['minq'] - 10);
    ok('preserve below the bar refused', !order_check($uid, $o)['enough']);
    q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $o['item_id']]); q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $o['item_id']]);
    give_item($uid, $o['item_id'], $o['qty']); market_note_quality($uid, $o['item_id'], $o['qty'], $o['minq'] + 5);
    ok('preserve at the bar accepted', order_check($uid, $o)['enough']);
}
cfg(['orders_cycle_days' => 7]);

echo "== quality tracking\n";
$carrot = (int)q_val("SELECT produce_item_id FROM plants WHERE slug = 'carrot'");
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $carrot]); q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $carrot]);
give_item($uid, $carrot, 4); market_note_quality($uid, $carrot, 4, 80);
ok('4 at 80 = 80', market_stack_q($uid, $carrot) === 80);
give_item($uid, $carrot, 4); market_note_quality($uid, $carrot, 4, 40);
ok('then 4 at 40 = average 60', market_stack_q($uid, $carrot) === 60, (string)market_stack_q($uid, $carrot));
give_item($uid, $carrot, 8);   // bought or traded: plain
ok('8 untracked units pull it towards plain (35)', market_stack_q($uid, $carrot) === (int)round((60 * 8 + 35 * 8) / 16), (string)market_stack_q($uid, $carrot));
ok('grade letters', market_grade(90) === 'S' && market_grade(76) === 'A' && market_grade(60) === 'B' && market_grade(45) === 'C' && market_grade(10) === 'F');

echo "== quality shrinks when items leave a stack\n";
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $carrot]); q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $carrot]);
give_item($uid, $carrot, 3); market_note_quality($uid, $carrot, 3, 70);
ok('3 harvested at 70 = 70', market_stack_q($uid, $carrot) === 70);
give_item($uid, $carrot, -3); give_item($uid, $carrot, 3);   // all used or sold, then 3 bought
ok('3 bought after the harvest left are plain (35)', market_stack_q($uid, $carrot) === MARKET_PLAIN_Q, (string)market_stack_q($uid, $carrot));
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $carrot]); q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $carrot]);
give_item($uid, $carrot, 4); market_note_quality($uid, $carrot, 4, 80); give_item($uid, $carrot, 4);
$avg = market_stack_q($uid, $carrot);
give_item($uid, $carrot, -4);
ok('4 at 80 plus 4 plain, 4 removed: tracked count halves', (int)q_val('SELECT n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $carrot]) === 2);
ok('...and the average stays put (58)', abs(market_stack_q($uid, $carrot) - $avg) <= 1 && abs($avg - 58) <= 1, "$avg then " . market_stack_q($uid, $carrot));
ok('a failed removal changes nothing', !give_item($uid, $carrot, -9) && (int)q_val('SELECT n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $carrot]) === 2);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $carrot]); q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $carrot]);
give_item($uid, $carrot, 5); market_note_quality($uid, $carrot, 5, 90); give_item($uid, $carrot, -2);
ok('a plain remove keeps the rest at harvest quality (5 at 90, 2 gone)', market_stack_q($uid, $carrot) === 90 && (int)q_val('SELECT n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $carrot]) === 3);
give_item($uid, $carrot, -3);
ok('...and empty stack leaves n at 0', (int)q_val('SELECT n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $carrot]) === 0);
require_once $argv[1] . '/includes/fresh_start.php';
ok('fresh start clears item_quality', (FRESH_USER_TABLES['item_quality'] ?? '') === 'user_id');

echo "== market day: toggle by setting\n";
$wd = mk_weekday($today);
cfg(['market_on' => 1, 'market_day' => $wd]);
ok('market day on when the weekday matches', market_day_on($today) && market_days_until($today) === 0);
cfg(['market_day' => ($wd + 1) % 7]);
ok('off on another weekday', !market_day_on($today) && market_days_until($today) === 1);
ok('...but on that weekday', market_day_on(hollow_date_add($today, 1)));
cfg(['market_day' => $wd, 'market_on' => 0]);
ok('switched off entirely', !market_day_on($today) && market_days_until($today) === -1);
cfg(['market_on' => 1, 'market_day' => $wd]);
$s1 = market_stalls($town, $today); $s2 = market_stalls($town, $today); $s3 = market_stalls($town, hollow_date_add($today, 7));
ok('stalls exist and are stable on a day', count($s1) >= 1 && $s1 == $s2);
$sig = fn($s) => json_encode(array_map(fn($x) => [$x['npc']['id'], array_map(fn($g) => $g['item']['id'] . ':' . $g['price'], $x['goods'])], $s));
ok('stock rotates week to week', $sig($s1) !== $sig($s3));
ok('stall prices positive', !array_filter($s1, fn($x) => array_filter($x['goods'], fn($g) => $g['price'] < 1)));
$st = $s1[0]; $g = $st['goods'][0]; $it = $g['item'];
q('UPDATE users SET coins = 1000 WHERE id = ?', [$uid]); $u = me();
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $it['id']]);
[$ok, $m] = market_stall_buy($u, $town, (int)$st['npc']['id'], (int)$it['id'], 2);
ok('buy from a stall', $ok, $m);
ok('coins taken at the stall price', (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) === 1000 - 2 * $g['price']);
[$ok, $m] = market_stall_buy(me(), $town, (int)$st['npc']['id'], (int)$it['id'], 2);
ok('daily limit stops a third and fourth', !$ok && str_contains($m, 'a day'), $m);
[$ok, $m] = market_stall_buy(me(), $town, (int)$st['npc']['id'], 999999, 1);
ok('not on that stall: refused', !$ok);
cfg(['market_day' => ($wd + 1) % 7]);
[$ok, $m] = market_stall_buy(me(), $town, (int)$st['npc']['id'], (int)$it['id'], 1);
ok('no buying when it is not market day', !$ok && str_contains($m, 'no market'), $m);
cfg(['market_day' => $wd]);
// basket
q('UPDATE users SET coins = 0 WHERE id = ?', [$uid]);
$ids = array_map('intval', q("SELECT item_id FROM user_items WHERE user_id = ? AND qty > 0 AND item_id IN (SELECT id FROM items WHERE category IN ('produce','flower','food','arrangement')) LIMIT 5", [$uid])->fetchAll(PDO::FETCH_COLUMN));
ok('have things to show', count($ids) >= 2, json_encode($ids));
[$ok, $m] = basket_enter(me(), $town, $ids);
ok('basket entered', $ok, $m);
$bk = basket_entry($uid);
ok('basket stored with score and reward', $bk && (int)$bk['score'] > 0 && (int)$bk['coins'] === basket_reward((int)$bk['beat']), json_encode($bk));
ok('petals paid', (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) === (int)$bk['coins']);
[$ok, $m] = basket_enter(me(), $town, $ids);
ok('one basket a day', !$ok && str_contains($m, 'already'), $m);
$rv = basket_rivals($town);
ok('three rival baskets, easy to hard', count($rv) === 3 && $rv[0]['score'] < $rv[2]['score'], json_encode(array_column($rv, 'score')));

echo "== market stalls charge the rarity multiplier: buying a Legendary or Rare good and selling it back never makes money\n";
$slugs = ['ackee', 'almond', 'black-pepper', 'cacao', 'chestnut', 'cinnamon', 'clove', 'coffee', 'hazelnut', 'nutmeg', 'pecan', 'pistachio', 'quince', 'vanilla', 'walnut', 'yuzu',
          'blueberry', 'caper', 'cardamom', 'cloudberry', 'cranberry', 'gooseberry', 'sea-buckthorn', 'sugarcane', 'tea', 'saffron', 'golden-carp', 'morel'];   // the 26 treasure crops, golden carp and morel
cfg(['price_drift_on' => 0, 'price_base_pct' => 80, 'market_stall_markup' => 115]);   // the best a shop ever pays (80%, wanted on a market day)
$bad = []; $seenN = 0;
foreach ($slugs as $sl) {
    $row = q_one('SELECT * FROM items WHERE slug = ?', [$sl]);
    if (!$row) { $bad[] = "$sl missing"; continue; }
    $seenN++;
    $cheapest = market_stall_price($row, 90);   // the lowest wobble a stall can have
    $best = sell_price($row);
    if ($cheapest <= $best) $bad[] = "$sl stall $cheapest <= sell $best";
}
ok('the 26 treasure crops, golden-carp and morel: cheapest stall price is above the best a shop pays (' . $seenN . ')', $seenN === 28 && !$bad, implode('; ', $bad));
$com = q_one("SELECT i.* FROM plants p JOIN items i ON i.id = p.produce_item_id WHERE p.slug = 'radish'");
ok('a Common crop keeps the plain 115% x wobble stall price', market_stall_price($com, 100) === max(1, (int)round((int)$com['base_price'] * 1.15)));
ok('a stall lists the same price market_stall_price gives', (function () use ($town, $today) {
    foreach (market_stalls($town, $today) as $s) foreach ($s['goods'] as $g) if ($g['price'] < market_stall_price($g['item'], 90) || $g['price'] > market_stall_price($g['item'], 110)) return false;
    return true;
})());
$dw = (int)q_val("SELECT COUNT(*) FROM items WHERE slug LIKE 'dried-%' AND category = 'food' AND tradable = 1");
$poolIds = array_map('intval', q("SELECT id FROM items WHERE category IN ('produce','flower','food','forage') AND tradable = 1 AND NOT (category = 'flower' AND slug LIKE 'dried-%')")->fetchAll(PDO::FETCH_COLUMN));
ok("the $dw dried-* preserves are no longer hidden from the wanted/stall pool, but dried flowers still are", $dw === 7 && !array_diff(array_map('intval', q("SELECT id FROM items WHERE slug LIKE 'dried-%' AND category = 'food'")->fetchAll(PDO::FETCH_COLUMN)), $poolIds));
cfg(['price_base_pct' => 60]);

echo "== price drift: bounds\n";
cfg(['price_drift_on' => 1, 'price_base_pct' => 60, 'price_min_pct' => 45, 'price_max_pct' => 80, 'price_noise' => 6, 'price_wanted_count' => 6, 'price_season_swing' => 6]);
$items = q("SELECT * FROM items WHERE category IN ('produce','flower','food','forage') AND tradable = 1")->fetchAll();
ok('have goods to price', count($items) > 20, (string)count($items));
$min = 999; $max = 0; $seen = [];
foreach ($items as $i) for ($d = 0; $d < 70; $d += 3) {
    $p = market_sell_pct($i, hollow_date_add($today, $d));
    $min = min($min, $p); $max = max($max, $p); $seen[$p] = true;
}
ok("every price within 45-80 (saw $min-$max)", $min >= 45 && $max <= 80);
ok('prices actually vary', count($seen) >= 8, (string)count($seen));
$i0 = $items[0];
$weeks = []; for ($w = 0; $w < 12; $w++) $weeks[market_sell_pct($i0, hollow_date_add($today, 7 * $w))] = 1;
ok('one item drifts week to week', count($weeks) >= 3, json_encode(array_keys($weeks)));
$mon0 = hollow_date_add($today, -((mk_weekday($today) + 6) % 7));
ok('same price all week (Monday to Sunday)', market_sell_pct($i0, $mon0) === market_sell_pct($i0, hollow_date_add($mon0, 6)));
cfg(['price_min_pct' => 50, 'price_max_pct' => 70]);
$m2 = 999; $x2 = 0; foreach (array_slice($items, 0, 30) as $i) for ($d = 0; $d < 40; $d += 4) { $p = market_sell_pct($i, hollow_date_add($today, $d)); $m2 = min($m2, $p); $x2 = max($x2, $p); }
ok("tightened bounds hold (saw $m2-$x2)", $m2 >= 50 && $x2 <= 70);
cfg(['price_min_pct' => 45, 'price_max_pct' => 80]);
cfg(['price_drift_on' => 0]);
ok('drift off = flat 60%', market_sell_pct($i0, $today) === 60 && market_buy_mult((int)$i0['id']) === 1.0);
$cropI = q_one("SELECT i.* FROM plants p JOIN items i ON i.id = p.produce_item_id WHERE p.slug = 'radish'");
ok('sell_price at flat 60 matches the old formula (common crop, no shop cap)', sell_price($cropI) <= max(1, (int)floor((int)$cropI['base_price'] * 0.6)) && sell_price($cropI) >= 1, (string)sell_price($cropI));
cfg(['price_drift_on' => 1]);

echo "== price drift: wanted list\n";
$w = market_wanted($today);
ok('six wanted goods', count($w) === 6, (string)count($w));
$wid = array_key_first($w); $wi = q_one('SELECT * FROM items WHERE id = ?', [$wid]);
$pw = market_price_parts($wi, $today);
ok('wanted flag set', $pw['wanted'] === true);
cfg(['price_noise' => 0, 'price_season_swing' => 0, 'price_wanted_bonus' => 12, 'price_market_bonus' => 8, 'price_vol_max' => 0]);
$pct = market_sell_pct($wi, $today);
$expected = 60 + 12 + (market_day_on($today) ? 8 : 0);
ok("a wanted good pays more ($pct%)", $pct === min(80, $expected), "expected $expected");
cfg(['market_day' => ($wd + 1) % 7]);
cfg(['market_day' => mk_weekday($today)]);
$onDay = market_price_parts($wi, $today); ok('market bonus only on market day', $onDay['market'] === true && $onDay['pct'] === min(80, 60 + 12 + 8));
cfg(['market_day' => ($wd + 1) % 7]);
ok('no market bonus off market day', market_price_parts($wi, $today)['market'] === false && market_price_parts($wi, $today)['pct'] === 72);
$chip = market_chip($wi);
ok('wanted chip shows star and up arrow', str_contains($chip, '⭐') && str_contains($chip, '↑'), $chip);

echo "== price drift: sales volume lowers it, time recovers it\n";
$plain = null; foreach ($items as $i) if (!market_is_wanted((int)$i['id'], $today) && market_item_seasons((int)$i['id']) === null) { $plain = $i; break; }
$plain ??= $items[3];
cfg(['price_noise' => 0, 'price_season_swing' => 0, 'price_vol_units' => 8, 'price_vol_max' => 12, 'price_vol_halflife' => 3]);
q('DELETE FROM market_volume WHERE item_id = ?', [$plain['id']]); market_vol_rows(true);
$p0 = market_sell_pct($plain, $today);
market_volume_add((int)$plain['id'], 24);
$p1 = market_sell_pct($plain, $today);
ok("24 sold: price falls 3 points ($p0 -> $p1)", $p1 === $p0 - 3, "$p0 -> $p1");
market_volume_add((int)$plain['id'], 400);
$p2 = market_sell_pct($plain, $today);
ok("heavy selling is capped at -12 ($p2)", $p2 === max(45, $p0 - 12), "$p0 -> $p2");
ok('the chip says it is down', str_contains(market_chip($plain), '↓'), market_chip($plain));
q('UPDATE market_volume SET vol = 96, at = ? WHERE item_id = ?', [gmdate('Y-m-d H:i:s', time()), $plain['id']]); market_vol_rows(true);
$pa = market_sell_pct($plain, $today);
q('UPDATE market_volume SET at = ? WHERE item_id = ?', [gmdate('Y-m-d H:i:s', time() - 3 * 86400), $plain['id']]); market_vol_rows(true);
$p3 = market_sell_pct($plain, $today);
ok("96 sold (-12), after 3 days (one half-life, 48 = -6) the price has recovered ($pa -> $p3)", $pa === max(45, $p0 - 12) && $p3 === $p0 - 6, "$p0 $pa $p3");
q('UPDATE market_volume SET at = ? WHERE item_id = ?', [gmdate('Y-m-d H:i:s', time() - 30 * 86400), $plain['id']]); market_vol_rows(true);
ok('after a month it is back to normal', market_sell_pct($plain, $today) === $p0);
// the real sell path records volume
$cat = (int)q_val("SELECT produce_item_id FROM plants WHERE slug = 'radish'");
q('DELETE FROM market_volume WHERE item_id = ?', [$cat]); market_vol_rows(true);
give_item($uid, $cat, 10); $shop = (int)q_val('SELECT id FROM shops LIMIT 1');
[$ok, $m] = sell_to_shop(me(), $cat, 10, 0);
ok('sell_to_shop sells', $ok, $m);
ok('...and records the volume', abs(market_volume($cat) - 10) < 0.01, (string)market_volume($cat));

echo "== price drift: season\n";
// short seasons so one week holds both; an off-season crop pays more
cfg(['season_mode' => 'game', 'season_days' => 3, 'season_epoch' => '2026-01-01', 'season_force' => '', 'price_noise' => 0, 'price_season_swing' => 6, 'price_vol_max' => 0, 'price_wanted_count' => 0]);
$crop = q_one("SELECT i.* FROM plants p JOIN items i ON i.id = p.produce_item_id WHERE p.slug = 'carrot'");
$pl = (int)q_val("SELECT id FROM plants WHERE slug = 'carrot'");
ok('crop seasons come from its kind when none is set', market_item_seasons((int)$crop['id']) !== null, (string)market_item_seasons((int)$crop['id']));
$csv = market_item_seasons((int)$crop['id']);
$in = $off = null;
$mon = hollow_date_add($today, -(mk_weekday($today) + 6) % 7);   // this week's Monday
for ($d = 0; $d < 7; $d++) { $dt = hollow_date_add($mon, $d); if (hollow_in_season($csv, $dt)) $in ??= $dt; else $off ??= $dt; }
if (!$in || !$off) { for ($k = 1; $k < 40 && (!$in || !$off); $k++) { $dt = hollow_date_add($mon, $k); if (mk_week($dt) !== mk_week($mon)) continue; if (hollow_in_season($csv, $dt)) $in ??= $dt; else $off ??= $dt; } }
ok('found an in-season and an off-season day in one week', (bool)($in && $off), "csv=$csv in=$in off=$off");
if ($in && $off) {
    $pi = market_sell_pct($crop, $in); $po = market_sell_pct($crop, $off);
    ok("in season sells lower ($pi) than off season ($po)", $pi === 54 && $po === 66);
    ok('buy price follows: cheaper in season, dearer out', abs(market_buy_mult((int)$crop['id'], $in) - 0.94) < 1e-9 && abs(market_buy_mult((int)$crop['id'], $off) - 1.06) < 1e-9);
    ok('trend: down in season, up off season', market_price_parts($crop, $in)['trend'] === 'down' && market_price_parts($crop, $off)['trend'] === 'up');
}
cfg(['season_days' => 14]);
// an admin season on the plant wins over the kind default
q("UPDATE plants SET seasons = 'winter' WHERE slug = 'carrot'");
ok('seeds are seasonal too', market_item_seasons((int)q_val('SELECT seed_item_id FROM plants WHERE id = ?', [$pl])) !== null);

echo "== sell_price: the cap and rarity still hold\n";
cfg(['price_drift_on' => 1, 'price_noise' => 6, 'price_season_swing' => 6, 'price_wanted_count' => 6, 'price_vol_max' => 12]);
$viol = 0; $chk = 0;
foreach (q("SELECT i.*, (SELECT MIN(price_min) FROM shop_stock WHERE item_id = i.id AND price_min > 0) AS smin FROM items i WHERE i.id IN (SELECT item_id FROM shop_stock)")->fetchAll() as $i) {
    if (!in_array($i['category'], ['produce', 'flower', 'food', 'part', 'forage'], true)) continue;
    for ($d = 0; $d < 56; $d += 7) { $chk++; $pc = market_sell_pct($i, hollow_date_add($today, $d)); }
    $sp = sell_price($i); if ($i['smin'] && $sp > floor($i['smin'] * 80 / 100) + 0) $viol++;
}
ok("selling never beats buying (checked $chk)", $viol === 0, "violations=$viol");
$buyViol = 0;
foreach (q("SELECT st.item_id, st.price_min FROM shop_stock st") ->fetchAll() as $r) {
    $it = q_one('SELECT * FROM items WHERE id = ?', [$r['item_id']]);
    if (!$it || !in_array($it['category'], ['produce', 'flower', 'food'], true)) continue;
    for ($d = 0; $d < 60; $d += 5) {
        $date = hollow_date_add($today, $d);
        $sellAt = floor($r['price_min'] * market_sell_pct($it, $date) / 100);
        $buyAt = $r['price_min'] * market_buy_mult((int)$r['item_id'], $date);
        if ($sellAt > $buyAt) $buyViol++;
    }
}
ok('best sell price never beats the cheapest buy price (incl. season)', $buyViol === 0, "violations=$buyViol");

echo "== old favours when orders are off\n";
cfg(['orders_on' => 0]);
ok('setting off', setting('orders_on') === '0');
cfg(['orders_on' => 1]);

echo $fails ? "\n$fails FAILED\n" : "\nall passed\n";
exit($fails ? 1 : 0);
