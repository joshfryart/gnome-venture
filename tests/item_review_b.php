<?php
// Item review group B (2.7.58), small code: EC1/EC2 packet and dried-flower prices, EC3 shared discount helper, EC5-EC7 broken-tool mending,
// EC8 max_stack, EC9 chunked bulk sell, EC10 markup clamp. php tests/item_review_b.php GAME_DIR (installed game with player "sprout").
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/flowers.php';
require_once $argv[1] . '/includes/tools.php';
require_once $argv[1] . '/includes/items.php';
require_once $argv[1] . '/includes/world.php';
require_once $argv[1] . '/includes/market100.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$have = fn(int $id) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
$wear = fn(int $id) => (int)q_val('SELECT wear FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
$item = fn(string $slug) => q_one('SELECT * FROM items WHERE slug = ?', [$slug]);

echo "== EC1 seed packet is never worth more than its seeds\n";
$pl = q_one("SELECT p.*, si.base_price AS sp FROM plants p JOIN items si ON si.id = p.seed_item_id WHERE p.kind = 'flower' AND si.base_price > 0 ORDER BY si.base_price DESC LIMIT 1");
$n = max(1, (int)setting('packet_seeds'));
$pk = q_one('SELECT * FROM items WHERE id = ?', [packet_item($pl)]);
$pct = market_sell_pct($pk);
ok('packet sells for at most its seeds at the sell share', sell_price($pk) <= (int)floor((int)$pl['sp'] * $n * $pct / 100), sell_price($pk) . ' vs ' . floor((int)$pl['sp'] * $n * $pct / 100));
ok('flat_sell_value agrees', flat_sell_value($pk, item_lookups()) <= (int)floor((int)$pl['sp'] * $n * max(1, mk_int('price_base_pct', 60)) / 100));

echo "== EC2 dried flower inherits the cut flower's tier and buy-back cap\n";
$fp = q_one("SELECT p.* FROM plants p JOIN shop_stock st ON st.item_id = p.produce_item_id WHERE p.kind = 'flower' ORDER BY p.id LIMIT 1");
$cut = q_one('SELECT * FROM items WHERE id = ?', [$fp['produce_item_id']]);
q('UPDATE items SET rarity = 50 WHERE id = ?', [dried_item($cut)]);   // a dried flower of a high numeric rarity used to turn Rare
$dr = q_one('SELECT * FROM items WHERE id = ?', [dried_item($cut)]);
$L = item_lookups();
ok('same rarity letter', item_rarity($dr, $L)[0] === item_rarity($cut, $L)[0], item_rarity($dr, $L)[0] . ' vs ' . item_rarity($cut, $L)[0]);
$fl = shop_buy_floor((int)$cut['id'], $u);
ok('cut flower has a buy floor', $fl !== null);
ok('dried sale is at most dried_price_pct of the cut floor', sell_price($dr, $u) <= (int)floor($fl * max(50, (int)setting('dried_price_pct')) / 100), sell_price($dr, $u) . ' vs ' . $fl);

echo "== EC3 one discount helper for shop_price and shop_buy_floor\n";
q("UPDATE users SET ev_disc = ? WHERE id = ?", [json_encode(['shop' => [30, time() + 3600]]), $uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
set_setting('price_drift_on', '0'); setting('__reload__');
$rows = q('SELECT shop_id, MIN(price_min) AS p FROM shop_stock WHERE item_id = ? AND price_min > 0 GROUP BY shop_id', [(int)$cut['id']])->fetchAll();
$want = min(array_map(fn($r) => shop_price($u, (int)$r['p'], (int)$r['shop_id'], (int)$cut['id']), $rows));
ok('floor equals the cheapest shop_price (trail-sight discount counted)', shop_buy_floor((int)$cut['id'], $u) === $want, shop_buy_floor((int)$cut['id'], $u) . ' vs ' . $want);
q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$uid]);

echo "== EC5 mending a Broken copy leaves the working stack's wear\n";
$tool = $item('tin-lantern'); $tid = (int)$tool['id'];
$bid = broken_item_id($tool);
q('UPDATE users SET coins = 5000, free_mend_day = NULL, free_mend_n = 0 WHERE id = ?', [$uid]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?, ?)', [$uid, $tid, $bid]);
give_item($uid, $tid, 1); give_item($uid, $bid, 1);
q('UPDATE user_items SET wear = 5 WHERE user_id = ? AND item_id = ?', [$uid, $tid]);
[$r] = mend_tool($uid, $bid);
ok('mend ok', $r);
ok('two copies now, the worn stack keeps its wear', $have($tid) === 2 && $wear($tid) === 5, $have($tid) . '/' . $wear($tid));
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?, ?)', [$uid, $tid, $bid]);
give_item($uid, $bid, 1);
[$r] = mend_tool($uid, $bid);
ok('with no working copy the mended tool is fresh', $r && $have($tid) === 1 && $wear($tid) === 0);
[$r] = (function () use ($uid, $tid) { q('UPDATE user_items SET wear = 3 WHERE user_id = ? AND item_id = ?', [$uid, $tid]); return mend_tool($uid, $tid); })();
ok('mending a worn tool still clears its wear', $r && $wear($tid) === 0);

echo "== EC6 Broken copies cannot be traded\n";
ok('new Broken items are tradable=0', (int)q_val('SELECT tradable FROM items WHERE id = ?', [$bid]) === 0);
q('UPDATE items SET tradable = 1 WHERE id = ?', [$bid]);
give_item($uid, $bid, 1);
ok('tool_trade_block refuses a Broken copy', tool_trade_block($uid, $bid) !== null);
require_once $argv[1] . '/includes/upgrade2758.php';
upgrade_2758_broken();
ok('the boot step makes existing Broken items untradable', (int)q_val('SELECT tradable FROM items WHERE id = ?', [$bid]) === 0);
ok('boot step is wired', str_contains((string)file_get_contents($argv[1] . '/includes/bootstrap.php'), "boot_step('broken_untradable_2758'"));
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $bid]);

echo "== EC7 a free shed mend is used before a Glowcap kit\n";
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? LIMIT 1', [$uid]);
if (!$plot) { db_insert('plots', ['user_id' => $uid, 'name' => 'Test']); $plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? LIMIT 1', [$uid]); }
q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'tool_shed'", [$plot]);
q("INSERT INTO garden_buildings (plot_id, building, level, built_at) VALUES (?, 'tool_shed', 1, ?)", [$plot, now()]);
$kit = $item('glowcap-repair-kit');
if (!$kit) { require_once $argv[1] . '/includes/trail_sight_extras.php'; trail_sights_ensure_items(); }
$kit = $item('glowcap-repair-kit');
ok('kit item exists', (bool)$kit);
$kid = (int)$kit['id'];
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?, ?)', [$uid, $kid, $tid]);
give_item($uid, $kid, 1); give_item($uid, $bid, 1);
q('UPDATE users SET free_mend_day = NULL, free_mend_n = 0 WHERE id = ?', [$uid]);
[$r, $msg] = mend_tool($uid, $bid);
ok('mended by the shed, kit kept', $r && $have($kid) === 1 && str_contains($msg, 'Tool Shed'), $msg . ' kit=' . $have($kid));
give_item($uid, $bid, 1);
[$r, $msg] = mend_tool($uid, $bid);
ok('shed used up, now the kit goes', $r && $have($kid) === 0, $msg);
ok('the kit text says it is not the fight-belt Tool Repair Kit', str_contains((string)$item('glowcap-repair-kit')['description'], 'Tool Repair Kit'));
q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'tool_shed'", [$plot]);

echo "== EC8 give_item respects max_stack\n";
$it = $item('flint'); $iid = (int)$it['id'];
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]);
q('UPDATE items SET max_stack = 5 WHERE id = ?', [$iid]);
give_item($uid, $iid, 3); give_item($uid, $iid, 9);
ok('stack clamps at max_stack', $have($iid) === 5, (string)$have($iid));
q('UPDATE items SET max_stack = 999 WHERE id = ?', [$iid]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]);

echo "== EC9 a bulk sell is priced in price_vol_units chunks\n";
set_setting('price_drift_on', '1'); set_setting('price_vol_units', '8'); set_setting('price_vol_max', '12'); setting('__reload__');
$ca = q_one("SELECT * FROM items WHERE category = 'produce' AND tradable = 1 AND base_price >= 20 ORDER BY id LIMIT 1"); $cid = (int)$ca['id'];
q('DELETE FROM market_volume WHERE item_id = ?', [$cid]); market_vol_rows(true);
$one = sell_price_with_bonus($ca, $u, 0);
q('UPDATE users SET coins = 0 WHERE id = ?', [$uid]);
give_item($uid, $cid, 400);
[$r, , $total] = sell_to_shop($u, $cid, 400, 0);
ok('bulk sold', $r);
ok('400 sold for less than 400 at the first price', $total < $one * 400, $total . ' vs ' . $one * 400);
q('DELETE FROM market_volume WHERE item_id = ?', [$cid]); market_vol_rows(true);

echo "== EC10 shop markup never goes below 0\n";
$sh = q_one("SELECT id FROM shops ORDER BY id LIMIT 1"); $st = q_one('SELECT * FROM shop_stock WHERE shop_id = ? LIMIT 1', [$sh['id']]);
q('UPDATE shops SET markup_percent = -50, last_restock = NULL WHERE id = ?', [$sh['id']]);
q('UPDATE shop_stock SET restock_chance = 100, price_min = 100, price_max = 100 WHERE shop_id = ?', [$sh['id']]);
shop_restock((int)$sh['id']);
ok('a -50 markup does not cut prices', (int)q_val('SELECT MIN(current_price) FROM shop_stock WHERE shop_id = ?', [$sh['id']]) >= 100);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
