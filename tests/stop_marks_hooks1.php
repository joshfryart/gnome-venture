<?php
// Lasting marks, hooks part 1 (includes/stop_mark_hooks.php): the number families F01-F23 and the A4 coins at their real game sites.
// For every family: stop_marks_open = 0 = the number is as before; on with a faked latched mark = it moves by the perk's size (at least 1 unit);
// chance families: the chance the site rolls against; with every perk held the family caps (world cap + place stack, stop_marks.php) hold;
// the old 7-day perk and a mark never stack. Run by stop_marks_hooks1.sh on a walk.sh install: php tests/stop_marks_hooks1.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/stops.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/crafting.php';
require_once APP_ROOT . '/includes/health.php';
require_once APP_ROOT . '/includes/delve_v2.php';
require_once APP_ROOT . '/includes/stop_folk.php';
require_once APP_ROOT . '/includes/player_perks.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
ok('player sprout exists', $uid > 0);
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$cat = mark_catalogue();
$fake = 900000;
$latch = function (string $key) use ($uid, $cat, &$fake): void {
    $p = $cat[$key] ?? null;
    if (!$p) { ok("catalogue has $key", false); return; }
    db_insert('stop_marks', ['user_id' => $uid, 'location_id' => $p['loc_id'] ?: ++$fake, 'bar' => $p['bar'], 'perk_key' => $key, 'filled_on' => gclock_my_date(), 'latched_at' => now(), 'kept' => 0]);
    mark_held($uid, true);
};
$reset = function () use ($uid): void {
    foreach (['stop_marks', 'stop_mark_use', 'player_perks'] as $t) q("DELETE FROM $t WHERE user_id = ?", [$uid]);
    mark_held($uid, true);
    player_perks_active($uid, true);
};
/** [value with marks off, value with marks on] of $fn, with only $keys latched. */
$both = function (array $keys, callable $fn) use ($reset, $latch): array {
    $reset();
    foreach ($keys as $k) $latch($k);
    setg('stop_marks_open', '0');
    $off = $fn();
    setg('stop_marks_open', '1');
    $on = $fn();
    setg('stop_marks_open', '0');
    return [$off, $on];
};
$R = []; foreach (q('SELECT id, code FROM regions')->fetchAll() as $r) $R[$r['code']] = (int)$r['id'];
$naTown = (int)q_val("SELECT id FROM locations WHERE slug = 'market-na'");
q("DELETE FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid]);
q('UPDATE users SET location_id = ?, coins = 100000, energy = 50 WHERE id = ?', [$naTown, $uid]);
$recipeItem = fn(string $slug) => (int)q_val('SELECT output_item_id FROM recipes WHERE slug = ?', [$slug]);
$plant = fn(string $slug) => q_one('SELECT * FROM plants WHERE slug = ?', [$slug]);

echo "== off: nothing loads, nothing moves\n";
setg('stop_marks_open', '0');
ok('setting defaults to 0', setting('stop_marks_open') === '0');
ok('helpers are inert: mark_fx 0, context empty, plot owner unread', mark_fx($uid, 'sell') === 0 && mark_ctx_here($uid) === [] && mark_ctx_item(1) === [] && mark_plot_owner(1) === 0);
ok('mark_more / mark_less: at least 1 unit when a mark fires, nothing at 0%', mark_more(10, 1) === 1 && mark_more(1000, 2) === 20 && mark_more(10, 0) === 0
    && mark_less(10, 1) === 9 && mark_less(1, 2, 1) === 1 && mark_less(500, 0) === 500 && mark_less(0, 2) === 0);

echo "== F01 sell (sell_to_shop)\n";
$tomato = (int)q_val("SELECT id FROM items WHERE slug = 'tomato'");
$sale = function () use ($u, $uid, $tomato): array {
    give_item($uid, $tomato, 1);
    $p = sell_price_with_bonus(q_one('SELECT * FROM items WHERE id = ?', [$tomato]), $u(), 0);
    $before = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
    sell_to_shop($u(), $tomato, 1);
    return [$p, (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $before, shop_buy_floor($tomato, $u())];
};
[[$p0, $got0], [$p1, $got1, $floor]] = $both(['level_scales'], $sale);
ok('off: the shop price', $got0 === $p0, "$got0 vs $p0");
ok('on: +1% (at least 1), never past the buy-back floor', $got1 === $p1 + min(mark_more($p1, 1), $floor === null ? PHP_INT_MAX : max(0, $floor - $p1)), "$got1 vs $p1 floor " . var_export($floor, true));

echo "== F02 buy (shop_price)\n";
[$off, $on] = $both(['porters_crate'], fn() => shop_price($u(), 1000, 0));
ok("1% less: $off -> $on", $on === $off - max(1, (int)round($off / 100)), "$off $on");

echo "== F03 XP (add_xp)\n";
$xpDelta = function () use ($uid): int { $b = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]); add_xp($uid, 300, 'test'); return (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]) - $b; };
[$off, $on] = $both(['up_with_the_lark'], $xpDelta);
ok("+1% XP: $off -> $on", $on - $off >= 3 && $on - $off <= 4, "$off $on");
$reset(); $latch('up_with_the_lark');
db_insert('player_perks', ['user_id' => $uid, 'perk_key' => 'bright_mood', 'meter' => 'cheer', 'until' => gmdate('Y-m-d', strtotime(gclock_my_date() . ' 12:00 UTC +3 days')), 'from_location_id' => 0]);
player_perks_active($uid, true);
setg('stop_marks_open', '1');
$withOld = $xpDelta();
setg('stop_marks_open', '0');
$oldOnly = $xpDelta();
ok("an old 7-day perk and a mark never stack (the larger counts): $oldOnly / $withOld", $withOld === $oldOnly && $oldOnly > $off, "$oldOnly $withOld");

echo "== F04 garden XP (add_garden_xp)\n";
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
ok('sprout has a garden', $plot > 0);
$gx = function () use ($plot): int { $b = (int)q_val('SELECT garden_xp FROM plots WHERE id = ?', [$plot]); add_garden_xp($plot, 100); return (int)q_val('SELECT garden_xp FROM plots WHERE id = ?', [$plot]) - $b; };
[$off, $on] = $both(['propped_boughs'], $gx);
ok("+1%: $off -> $on", $off === 100 && $on === 101, "$off $on");

echo "== F05 walk time (route_walk_minutes)\n";
$route = q_one('SELECT * FROM routes WHERE a_id = ? OR b_id = ? LIMIT 1', [$naTown, $naTown]);
$route = ['minutes' => 100, 'min_level' => 99, 'max_level' => 99, 'level' => 99] + $route;
[$off, $on] = $both(['border_lamp'], fn() => route_walk_minutes($u(), $route)[0]);
ok("1% less: $off -> $on", $off === 100 && $on === 99, "$off $on");
[, $on1] = $both(['border_lamp'], fn() => route_walk_minutes($u(), ['minutes' => 1] + $route)[0]);
ok('a 1-minute walk stays 1 minute', $on1 === 1);

echo "== F06 pot time (cook_seconds)\n";
$tart = q_one('SELECT * FROM recipes WHERE slug = ?', ['berry-tart']);
ok('berry tart counts as grain (wheat)', $tart && in_array('grain', (function () use ($tart) { setg('stop_marks_open', '1'); $g = mark_ctx_item((int)$tart['output_item_id'])['group'] ?? []; setg('stop_marks_open', '0'); return $g; })(), true));
[$off, $on] = $both(['greased_wheel'], fn() => cook_seconds($u(), ['cook_minutes' => 10] + $tart));
ok("2% less: $off -> $on", $off === 600 && $on === 588, "$off $on");

echo "== F07 dish energy (eat_item, its context)\n";
$soup = $recipeItem('garden-vegetable-soup');
[, $on] = $both(['second_breakfast'], fn() => mark_fx($uid, 'meal', mark_ctx_here($uid) + mark_ctx_item($soup)));
ok('home-cooked dish at dawn or by day: 2%, else 0 (' . hollow_daypart() . ')', $on === (in_array(hollow_daypart(), ['dawn', 'day'], true) ? 2 : 0), (string)$on);

echo "== F08 boost length (buff_minutes)\n";
[$off, $on] = $both(['packed_by_the_cook'], fn() => buff_minutes($u(), 300, $soup));
ok("home-cooked: 2% longer: $off -> $on", $on === $off + mark_more($off, 2), "$off $on");
[$off2, $on2] = $both(['packed_by_the_cook'], fn() => buff_minutes($u(), 300, $tomato));
ok('a raw crop: unchanged', $off2 === $on2);

echo "== F09 healing (hp_heal_points, rest_heal)\n";
$ee = q_one("SELECT id FROM locations WHERE region_id = ? AND landscape IN ('forest', 'mountain') AND kind = 'village' LIMIT 1", [$R['EE']]);
$eeKey = (string)array_key_first(array_filter($cat, fn($p) => $p['family'] === 'F09' && ($p['scope']['region'] ?? []) === ['EE']));
ok('an EE healing place perk and an EE forest/mountain village', $eeKey !== '' && $ee);
q('UPDATE users SET location_id = ? WHERE id = ?', [(int)$ee['id'], $uid]);
$heal = function () use ($u, $uid): int { setg('hp_persist', '1'); hp_store($uid, 1, hp_max($u()), false); return hp_heal_points($u(), 10); };
[$off, $on] = $both([$eeKey], $heal);
ok("region perk: 10 -> 11 health ($off -> $on)", $off === 10 && $on === 11, "$off $on");
q('UPDATE users SET location_id = ? WHERE id = ?', [$naTown, $uid]);
setg('walk_rest_heal_percent', '20');
$rest = function () use ($uid, $naTown): int { $e = ['max_hp' => 100, 'hp' => 10, 'log' => '["a step"]', 'user_id' => $uid, 'from_id' => $naTown, 'to_id' => $naTown, 'route_id' => 0, 'status' => 'active']; rest_heal($e); return $e['hp'] - 10; };
[$off, $on] = $both(['dry_woodpile'], $rest);
ok("a trail rest heals 2% more: $off -> $on", $off === 20 && $on === 21, "$off $on");

echo "== F10 harvest extra, F13 seed back, F12 watering, F17 pests (garden)\n";
$oats = $plant('oats');
ok('oats is a crop', (bool)$oats);
[$off, $on] = $both(['millers_pinch'], fn() => mark_fx($uid, 'harvest', mark_ctx_crop($oats)));
ok('oats harvest: 2% chance of one extra', $off === 0 && $on === 2, "$off $on");
[, $onT] = $both(['millers_pinch'], fn() => mark_fx($uid, 'harvest', mark_ctx_crop($plant('tomato'))));
ok('a tomato harvest: no chance', $onT === 0);
[$off, $on] = $both(['what_you_leave_comes_back'], fn() => mark_fx($uid, 'seed', mark_ctx_crop($oats)));
ok('every crop: +1 seed-back chance', $off === 0 && $on === 1);
$corn = $plant('corn');
$tile = ['plot_id' => $plot, 'moisture' => 50, 'method' => 'till', 'bed_score' => 0, 'mulch' => 0, 'yx' => 0, 'yy' => 0];
[$off, $on] = $both(['shored_up_terraces'], fn() => water_seconds($tile, $corn));
ok("corn watering lasts 2% longer: $off -> $on", $on === $off + mark_more($off, 2), "$off $on");
[$off, $on] = $both(['shored_up_terraces'], fn() => water_seconds($tile, $oats));
ok('oats: unchanged', $off === $on);
setg('pest_chance', '50');
$pctx = ['bonus' => [], 'near' => [], 'comp' => [], 'lodge' => false, 'pond' => false, 'greenhouse' => false];
$flower = q_one("SELECT * FROM plants WHERE kind = 'flower' ORDER BY id LIMIT 1");
[$off, $on] = $both(['tidy_skeps'], fn() => pest_chances($tile, $flower, gclock_my_date(), $pctx));
$good = (bool)$off; foreach ($off as $k => $c) if (abs($on[$k] - $c * 0.98) > 1e-9) $good = false;
ok('flower pests 2% less likely (' . count($off) . ' pests)', $good, json_encode([$off, $on]));
[$off, $on] = $both(['tidy_skeps'], fn() => pest_chances($tile, $corn, gclock_my_date(), $pctx));
ok('grain pests: unchanged', $off === $on);

echo "== F11 gather extra, F14 friendship, F16 stop check, F19 spot, F23 seed on fast travel (the chances the sites roll)\n";
[$off, $on] = $both(['squirrels_arithmetic'], fn() => mark_fx($uid, 'gather', ['land' => 'forest'] + mark_ctx_here($uid)));
ok('gathering in forest: 2%', $off === 0 && $on === 2);
[, $on] = $both(['squirrels_arithmetic'], fn() => mark_fx($uid, 'gather', ['land' => 'desert'] + mark_ctx_here($uid)));
ok('gathering in desert: 0', $on === 0);
[$off, $on] = $both(['hop_yard_hum'], fn() => mark_fx($uid, 'friend', mark_ctx_here($uid) + mark_ctx_item($soup)));
ok('a gift of food: 2% chance of +1 friendship', $off === 0 && $on === 2);
[, $on] = $both(['hop_yard_hum'], fn() => mark_fx($uid, 'friend', mark_ctx_here($uid) + mark_ctx_item((int)q_val("SELECT id FROM items WHERE category = 'tool' LIMIT 1"))));
ok('a gift of a tool: 0', $on === 0);
[$off] = $both(['hop_yard_hum'], function () use ($uid, $soup) { $n = 0; for ($i = 0; $i < 300; $i++) $n += mark_friend_extra($uid, mark_ctx_item($soup)); return $n; });
ok('off: never an extra point', $off === 0);
[$off, $on] = $both(['fireside_regular'], fn() => mark_fx($uid, 'check', ['at' => $naTown, 'kind' => 'check']));
ok('stop checks 1% kinder', $off === 0 && $on === 1);
[$off, $on] = $both(['swept_steps'], fn() => mark_more(14, mark_fx($uid, 'spot', mark_ctx_walk($naTown, $naTown))));
ok('spotting: 14 -> 15', $off === 0 && $on === 1);
[$off, $on] = $both(['rice_in_the_turn_ups'], fn() => mark_fx($uid, 'trailseed', mark_ctx_here($uid)));
ok('seed on fast travel: +1%', $off === 0 && $on === 1);

echo "== F15 stop coins (stop_rewards), F22 rest energy\n";
setg('stop_reward_percent', '100');
$coinsFor = function (array $act) use ($u, $uid, $naTown): int {
    mark_act_ctx($act);
    $b = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
    stop_rewards($u(), q_one('SELECT * FROM locations WHERE id = ?', [$naTown]), 'c=100');
    mark_act_ctx(null, true);
    return (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $b;
};
[$off, $on] = $both(['sound_nets'], fn() => $coinsFor(['at' => $naTown, 'group' => ['energy']]));
ok("an act that cost energy pays 2% more: $off -> $on", $on === $off + mark_more($off, 2), "$off $on");
[, $on] = $both(['sound_nets'], fn() => $coinsFor([]));
ok('rewards outside a stop act (a trail sight): unchanged', $on === $off);
[, $on] = $both(['sound_nets'], fn() => $coinsFor(['at' => $naTown, 'group' => []]));
ok('a free act: unchanged', $on === $off);
[$off, $on] = $both(['a_bed_with_your_name_on'], fn() => mark_fx($uid, 'restenergy', ['at' => $naTown, 'type' => 'inn', 'kind' => 'rest']));
ok('rest at an inn: +1 energy', $off === 0 && $on === 1);
[, $on] = $both(['a_bed_with_your_name_on'], fn() => mark_fx($uid, 'restenergy', ['at' => $naTown, 'type' => 'mill', 'kind' => 'rest']));
ok('rest at a mill: 0', $on === 0);

echo "== F18 fast travel cost (travel_to)\n";
$ca = $R['CA'];
q('DELETE FROM region_visits WHERE user_id = ? AND region_id = ?', [$uid, $ca]);
db_insert('region_visits', ['user_id' => $uid, 'region_id' => $ca, 'first_at' => now()]);
setg('travel_cost', '200');
$travel = function () use ($u, $uid, $ca, $naTown): int {
    q('UPDATE users SET location_id = ?, location = ?, energy = 50 WHERE id = ?', [$naTown, 'The Maplewold', $uid]);
    $b = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
    [$okT, $msg] = travel_to($u(), $ca);
    if (!$okT) echo "   travel: $msg\n";
    return $b - (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
};
[$off, $on] = $both(['beaver_tight_hull'], $travel);
ok("1% less: $off -> $on", $off > 0 && $on === $off - max(1, (int)round($off / 100)), "$off $on");
q('UPDATE users SET location_id = ?, location = ? WHERE id = ?', [$naTown, 'The Maplewold', $uid]);

echo "== F20 max health on a road, F21 torch steps\n";
$flint = $cat['re_roped_crag_path']['loc_id'] ?? 0;
if ($flint) {
    [$off, $on] = $both(['re_roped_crag_path'], fn() => mark_fx($uid, 'hp', mark_ctx_walk($flint, $naTown)));
    ok('+1 max health on a road from its stop', $off === 0 && $on === 1);
    [, $on] = $both(['re_roped_crag_path'], fn() => mark_fx($uid, 'hp', mark_ctx_walk($naTown, $flint)));
    ok('...not on a road from elsewhere', $on === 0);
} else echo "   (Flintburrow not in this world: skipped)\n";
[$off, $on] = $both(['beacon_basket_refilled'], fn() => dv2_fuel($uid, 'standard', ['name' => 'Test Hollow', 'region_id' => $R['NA']]));
ok("a Maplewold delve: +1 torch step ($off -> $on)", $on === $off + 1);
[$off, $on] = $both(['beacon_basket_refilled'], fn() => dv2_fuel($uid, 'standard', ['name' => 'Test Hollow', 'region_id' => $R['CA']]));
ok('another region\'s delve: unchanged', $on === $off);
$grotto = (string)array_key_first(array_filter($cat, fn($p) => $p['family'] === 'F21' && isset($p['scope']['delve'])));
[$off, $on] = $both([$grotto], fn() => dv2_fuel($uid, 'standard', ['name' => ucwords(str_replace('_', ' ', $cat[$grotto]['scope']['delve'][0])), 'region_id' => 0]));
ok("a named delve ($grotto): +1", $on === $off + 1, "$off $on");

echo "== A4 coins\n";
$reset(); setg('stop_marks_open', '1');
$drift = $cat['grilled_fish_night']['loc_id'] ?? 0;
$latch('grilled_fish_night'); $latch('pebble_in_the_boot');
$c1 = mark_coins_on($uid, 'first_sale_at_the_stops_stall', ['at' => $drift]);
$c2 = mark_coins_on($uid, 'first_sale_at_the_stops_stall', ['at' => $drift]);
ok("first sale at its stop's stall: 2 coins, once a game day ($c1, $c2)", $c1 === 2 && $c2 === 0);
ok('a sale at another stop: nothing', mark_coins_on($uid, 'first_sale_at_the_stops_stall', ['at' => $naTown]) === 0);
$sum = 0; for ($i = 0; $i < 400; $i++) $sum += mark_coins_on($uid, 'coin_on_a_road_walk', []);
ok("road walk coins turn up, and all A4 coins stop at the 10-a-day ceiling ($sum + 2)", $sum > 0 && $sum + 2 <= MARK_A4_CEILING);
setg('stop_marks_open', '0');
ok('off: no coins', mark_coins_on($uid, 'coin_on_a_road_walk', []) === 0);

echo "== caps: every perk held, the sites stay inside cap + place stack\n";
$reset();
foreach ($cat as $k => $p) if ($p['class'] !== 'F') $latch($k);
setg('stop_marks_open', '1');
foreach (MARK_FAMILIES as $code => [$name, $unit, $cap]) {
    $most = 0;
    foreach ([[], mark_ctx_here($uid), ['items' => ['corn', 'oats', 'black-bean'], 'group' => ['grain', 'sweet', 'homecooked', 'food', 'fish', 'trail', 'energy'], 'land' => ['forest', 'mountain', 'grassland'], 'region' => 'EE', 'type' => 'inn', 'at' => $naTown], ['region' => 'NA', 'land' => ['mountain'], 'delve' => ['x']]] as $ctx)
        $most = max($most, mark_pct($uid, $code, $ctx));
    $lim = $cap + (MARK_PLACE_STACK[$code] ?? MARK_PLACE_STACK_DEFAULT);
    ok("$code $name: at most $lim ($most)", $most <= $lim && $most > 0);
}
$walk = route_walk_minutes($u(), $route)[0];
ok("walk: 100 minutes -> $walk (at most 10% less)", $walk >= 90 && $walk < 100);
$cook = cook_seconds($u(), ['cook_minutes' => 10] + $tart);
ok("pots: 600 s -> $cook (at most 10% less)", $cook >= 540 && $cook < 600);
$fuel = dv2_fuel($uid, 'standard', ['name' => 'Test Hollow', 'region_id' => $R['NA']]);
ok('torch: at most +4 (' . ($fuel - DV_TORCH['standard']) . ')', $fuel - DV_TORCH['standard'] <= 4);
setg('stop_marks_open', '0');
ok('off again with every perk held: walk 100, pots 600', route_walk_minutes($u(), $route)[0] === 100 && cook_seconds($u(), ['cook_minutes' => 10] + $tart) === 600);

$reset();
q('UPDATE users SET location_id = ? WHERE id = ?', [$naTown, $uid]);
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
