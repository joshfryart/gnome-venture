<?php
// v0.9.7 part A: action XP scaling, near-home roads that track the gnome's level, easy roads, quick walks, the new creatures.
// Run by roads097.sh on a fresh install (sprout is onboarded, standing at the home village of the Maplewold).
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/destination.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$row = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$set = function (int $lvl, int $easy) use ($uid) { q('UPDATE users SET level = ?, easy_roads = ? WHERE id = ?', [$lvl, $easy, $uid]); };

echo "== settings\n";
foreach (['xp_action_scale_percent' => '5', 'easy_roads_below' => '5', 'easy_roads_gap' => '3', 'low_road_gap' => '10', 'low_road_time_pct' => '50'] as $k => $v) ok("$k default $v", setting($k) === $v, setting($k));
ok('new gnome starts with easy roads on', (int)$row()['easy_roads'] === 1);

echo "== action XP scaling\n";
q('UPDATE users SET level = 10, xp = 0 WHERE id = ?', [$uid]);
ok('level 10: no change', action_xp_scale(5, 10) === 5 && action_xp_scale(5, 3) === 5);
ok('level 15: +25%', action_xp_scale(20, 15) === 25, (string)action_xp_scale(20, 15));
ok('level 28: +90%', action_xp_scale(20, 28) === 38, (string)action_xp_scale(20, 28));
ok('never below 1, 0 stays 0', action_xp_scale(1, 28) === 2 && action_xp_scale(0, 28) === 0);
q('UPDATE settings SET value = ? WHERE name = ?', ['0', 'xp_action_scale_percent']); setting('__reload__');
ok('setting 0 = off', action_xp_scale(20, 28) === 20);
q('UPDATE settings SET value = ? WHERE name = ?', ['5', 'xp_action_scale_percent']);
if (!q_val("SELECT 1 FROM settings WHERE name = 'xp_action_scale_percent'")) q('DELETE FROM settings WHERE name = ?', ['xp_action_scale_percent']);
setting('__reload__');
$set(20, 1);
[$paid, $lv] = add_action_xp($uid, 10, 'Fighting', 20);
ok('add_action_xp pays the scaled XP (10 -> 15 at level 20)', $paid === 15 && (int)$row()['xp'] === 15, "paid $paid xp " . $row()['xp']);
ok('and logs it under its source', (int)q_val("SELECT SUM(xp) FROM xp_log WHERE user_id = ? AND source = 'Fighting'", [$uid]) === 15);
q('UPDATE users SET xp = 0 WHERE id = ?', [$uid]);
foreach (['garden_logic.php' => 'Harvesting', 'crafting.php' => 'Crafting', 'adventure.php' => 'Fighting'] as $f => $src) ok("$f pays action XP ($src)", str_contains(file_get_contents($argv[1] . '/includes/' . $f), "add_action_xp(\$uid, \$xp, '$src'"));
ok('cooking too', str_contains(file_get_contents($argv[1] . '/includes/crafting.php'), "'Cooking'"));
$quest = file_get_contents($argv[1] . '/includes/journey.php') . file_get_contents($argv[1] . '/includes/calling_quests.php');
ok('quest and chapter XP are not scaled', !str_contains($quest, 'add_action_xp'));

echo "== roads near home\n";
$home = player_node($row());
ok('sprout stands in a village with a garden', $home['kind'] === 'village' && is_safe_base($row(), (int)$home['id']));
$near = q("SELECT * FROM routes WHERE kind = 'road' AND (a_id = ? OR b_id = ?)", [$home['id'], $home['id']])->fetchAll();
ok('home village has a road', count($near) > 0);
$set(28, 0); $u = $row();
foreach ($near as $r) { [$lo, $hi, $sc] = route_danger($u, $r); ok("level 28, easy off: road {$r['id']} next to home = level 28", $lo === 28 && $hi === 28 && $sc, "$lo-$hi"); }
$set(28, 1); $u = $row();
foreach ($near as $r) { [$lo, $hi] = route_danger($u, $r); ok("level 28, easy on: road {$r['id']} next to home = level 25", $lo === 25 && $hi === 25, "$lo-$hi"); }
$set(15, 0); $u = $row();
ok('level 15, easy off: 15', route_danger($u, $near[0])[0] === 15);
$set(3, 1); $u = $row();
ok('level 3, easy on: never below 1', route_danger($u, $near[0])[0] === 1);
$set(4, 0); $u = $row();
ok('level 4, easy off: level 4 (was region level 1)', route_danger($u, $near[0])[0] === 4);

echo "== roads far from home (region level; quick walks)\n";
$far = null;
$set(28, 0); $u = $row();
foreach (q("SELECT * FROM routes WHERE kind = 'road' ORDER BY id")->fetchAll() as $r) {
    if (!near_home($u, (int)$r['a_id']) && !near_home($u, (int)$r['b_id'])) { $far = $r; break; }
}
ok('found a road leg away from home', (bool)$far);
if ($far) {
    [$lo, $hi] = route_danger($u, $far);
    ok("far leg keeps the region's level ($lo-$hi)", $hi < 20, "$lo-$hi");
    [$m, $quick] = route_walk_minutes($u, $far);
    ok("level 28: quick walk, 6 min -> 3 ($m)", $quick && $m === (int)round($far['minutes'] / 2), "$m " . (int)$quick);
    $set($hi + 10, 0); [$m, $quick] = route_walk_minutes($row(), $far);
    ok('exactly low_road_gap above its top level: quick', $quick);
    $set($hi + 9, 0); [$m, $quick] = route_walk_minutes($row(), $far);
    ok('one level less: normal time', !$quick && $m === (int)$far['minutes']);
    $set(28, 0);
    q('UPDATE settings SET value = ? WHERE name = ?', ['100', 'low_road_time_pct']);
    if (!q_val("SELECT 1 FROM settings WHERE name = 'low_road_time_pct'")) set_setting('low_road_time_pct', '100'); setting('__reload__');
    ok('low_road_time_pct 100 = no quick walks', !route_walk_minutes($row(), $far)[1]);
    q('DELETE FROM settings WHERE name = ?', ['low_road_time_pct']); setting('__reload__');
    $plan = null;
    q('UPDATE users SET location_id = ? WHERE id = ?', [(int)$far['a_id'], $uid]);
    $plan = dest_plan($row(), (int)$far['b_id']);
    ok('route plan carries the quick flag and halved minutes', $plan && $plan['stops'][0]['quick'] && $plan['stops'][0]['minutes'] === 3, json_encode($plan['stops'][0] ?? null));
    $panel = dest_panel($row(), (int)$far['b_id']);
    ok('route panel says quick walk', str_contains($panel, 'quick walk'));
    q('UPDATE users SET location_id = ? WHERE id = ?', [(int)$home['id'], $uid]);
}

echo "== easy roads: no bosses, nothing above the cap\n";
$bad = 0; $bossN = 0;
for ($i = 0; $i < 600; $i++) {
    foreach (['forest', 'grassland', 'coast', 'wetland'] as $land) {
        $c = pick_creature($land, 9, true, false, 6);
        if ($c && ((int)$c['level'] > 6 || $c['size'] === 'boss')) $bad++;
    }
}
ok('2400 picks with cap 6: none above level 6, no bosses', $bad === 0, "$bad bad");
$c = pick_creature('forest', 28, true, false, 25);
ok('cap 25 at level 28 is a level 25 or lower creature', $c && (int)$c['level'] <= 25 && $c['size'] !== 'boss');
$sawBoss = false; for ($i = 0; $i < 3000 && !$sawBoss; $i++) { $c = pick_creature('forest', 24, true, false, 0); $sawBoss = $c && $c['size'] === 'boss'; }
ok('without the cap bosses can still turn up', $sawBoss);

echo "== easy roads on a started walk\n";
$set(28, 1); q('UPDATE users SET energy = 100 WHERE id = ?', [$uid]);
[$okS, $msg] = start_expedition($row(), (int)$near[0]['id']);
$x = active_expedition($uid);
ok('walk started, level 25, scaled', $okS && (int)$x['level'] === 25 && (int)$x['scaled'] === 1, $msg . ' ' . json_encode($x));
ok('the walk caps creatures at 25', exp_easy_cap($row(), $x) === 25);
$set(28, 0);
ok('easy off: no cap', exp_easy_cap($row(), $x) === 0);
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
$set(28, 0);
[$okS] = start_expedition($row(), (int)$near[0]['id']); $x = active_expedition($uid);
ok('easy off: walk at level 28', $okS && (int)$x['level'] === 28);
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);

echo "== off the road next to home\n";
$set(28, 0); $u = $row();
ok('explore base at home = gnome level', explore_base($u, (int)$home['id']) === 28);
$set(28, 1); ok('easy: 25', explore_base($row(), (int)$home['id']) === 25);
$set(2, 1); ok('level 2 easy: 1', explore_base($row(), (int)$home['id']) === 1);

echo "== new creatures\n";
$new = ['delta-gharial', 'emerald-python', 'jungle-tiger', 'spice-monitor', 'cloud-leopard', 'savanna-hyena', 'mangrove-crab-king', 'sand-viper-matriarch', 'honey-badger-brute', 'thunder-yak', 'reef-eel-lord', 'outback-dingo', 'fern-cassowary', 'deep-octopus'];
$got = (int)q_val('SELECT COUNT(*) FROM creatures WHERE slug IN (' . implode(',', array_fill(0, count($new), '?')) . ')', $new);
ok('14 new creatures', $got === 14, (string)$got);
ok('all between level 24 and 37', (int)q_val('SELECT COUNT(*) FROM creatures WHERE slug IN (' . implode(',', array_fill(0, count($new), '?')) . ') AND level BETWEEN 24 AND 37', $new) === 14);
ok('none is a boss', (int)q_val("SELECT COUNT(*) FROM creatures WHERE slug IN (" . implode(',', array_fill(0, count($new), '?')) . ") AND size = 'boss'", $new) === 0);
ok('each has drops, and each drop is an item that already existed (no drop item made by these)', (int)q_val('SELECT COUNT(*) FROM creatures c WHERE c.slug IN (' . implode(',', array_fill(0, count($new), '?')) . ') AND EXISTS (SELECT 1 FROM creature_drops d WHERE d.creature_id = c.id)', $new) === 14);
ok('an Almanac page each', (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key LIKE 'creature:%' AND unlock_key IN (" . implode(',', array_map(fn($s) => "'creature:$s'", $new)) . ')') === 14);
$descMax = (int)q_val('SELECT MAX(LENGTH(description)) FROM creatures WHERE slug IN (' . implode(',', array_fill(0, count($new), '?')) . ')', $new);
ok("flavour stays short ($descMax chars)", $descMax <= 140);
// regions 23-35: levels 23-32 are met unscaled on every landscape
$scaledHits = [];
foreach (['wetland', 'grassland', 'rainforest', 'coast', 'island', 'desert', 'mountain', 'forest'] as $land) {
    for ($lv = 23; $lv <= 32; $lv++) {
        for ($i = 0; $i < 25; $i++) { $c = pick_creature($land, $lv, false); if (!$c || !empty($c['_scaled'])) { $scaledHits["$land@$lv"] = 1; break; } }
    }
}
ok('regions 23-35 (levels 23-32): no scaled wolves on any landscape', !$scaledHits, implode(' ', array_keys($scaledHits)));
$wolf = 0; for ($i = 0; $i < 200; $i++) { $c = pick_creature('wetland', 28, false); if ($c && $c['slug'] === 'bramble-wolf') $wolf++; }
ok('level 28 wetland never a bramble wolf', $wolf === 0);

echo $fails ? "\n$fails FAILED\n" : "\nall passed\n";
exit($fails ? 1 : 0);
