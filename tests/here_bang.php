<?php
// The "!" over a villager (here_quest_ready) follows the town Orders board when Orders are on: a real order you can fill now, not the retired weekly favour crops.
// php tests/here_bang.php GAME_DIR   (an installed game, player "sprout")
$_SERVER['SCRIPT_NAME'] = '/here.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/here_view.php';
require_once $argv[1] . '/includes/town_social.php';
require_once $argv[1] . '/includes/market100.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('orders_on', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$node = q_one("SELECT * FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1");
$town = (string)$node['region'];
$folk = town_folk($town);
ok('the market town has townsfolk', count($folk) >= 3, (string)count($folk));
foreach ($folk as $n) { q('DELETE FROM npc_friends WHERE user_id = ? AND npc_id = ?', [$uid, $n['id']]); db_insert('npc_friends', ['user_id' => $uid, 'npc_id' => $n['id'], 'points' => 300, 'talks' => 0, 'gifts' => 0, 'known' => '[]']); }
$board = orders_board($town); $onBoard = array_map(fn($b) => (int)$b['npc']['id'], $board);
$off = array_values(array_filter($folk, fn($n) => !in_array((int)$n['id'], $onBoard, true)));
ok('some townsfolk are NOT on the Orders board (the board shows a few)', count($off) >= 1 && count($board) >= 1, count($off) . ' off, ' . count($board) . ' on');
// a villager with no order: holding the old favour crop must not give a "!"
$npc = $off[0]; $o = favour_offer($uid, $npc, $town);
ok('the old favour still exists for them in the code', (bool)$o);
give_item($uid, (int)$o['item']['id'], (int)$o['qty'] + 2);
ok('NO "!" for a villager without an order, even when you hold the old favour crop', here_quest_ready($u, $node, $npc) === false);
// a villager with a fillable order: "!" ; after delivering: none
$target = null; foreach ($board as $b) if ($b['o']['kind'] === 'crop' && (int)$b['o']['minq'] === 0 && (int)$b['o']['item_id'] > 0) { $target = $b; break; }
if ($target) {
    q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $target['o']['item_id']]);
    ok('no "!" while you hold none of the order\'s goods', here_quest_ready($u, $node, $target['npc']) === false);
    give_item($uid, (int)$target['o']['item_id'], (int)$target['o']['qty']);
    ok('a "!" when a real order on the board can be filled now', here_quest_ready($u, $node, $target['npc']) === true);
    db_insert('npc_orders', ['user_id' => $uid, 'npc_id' => (int)$target['npc']['id'], 'cycle' => $target['o']['cycle'], 'done_at' => now()]);
    ok('no "!" once that order is delivered', here_quest_ready($u, $node, $target['npc']) === false);
} else echo "  (no plain crop order on today's board: fill checks skipped)\n";
// orders off: the old favours drive it again
set_setting('orders_on', '0'); setting('__reload__');
ok('with Orders off the old favour crop gives the "!" again', here_quest_ready($u, $node, $npc) === true);
set_setting('orders_on', '1'); setting('__reload__');
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
