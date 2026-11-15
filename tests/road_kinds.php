<?php
// 2.7.00 ROAD KINDS (includes/road_kinds.php, data/road_kinds.txt): ferry, tunnel, pass, toll, overgrown, flooded.
// php tests/road_kinds.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/road_kinds.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

echo "== the data file\n";
$all = rk_all(); $cnt = array_count_values(array_column($all, 'kind'));
ok('84 routes: 14 of each of the six kinds', count($all) === 84 && $cnt === array_fill_keys(['ferry', 'tunnel', 'pass', 'toll', 'overgrown', 'flooded'], 14), json_encode($cnt));
ok('tier is 2 or 3 for tunnel and pass, 0 for the rest', !array_filter($all, fn($k) => in_array($k['kind'], ['tunnel', 'pass'], true) ? !in_array($k['tier'], [2, 3], true) : $k['tier'] !== 0));
$missing = array_filter(array_keys($all), fn($id) => !q_val('SELECT 1 FROM routes WHERE id = ?', [$id]));
ok('every route of the list exists in the world', !$missing, json_encode(array_values($missing)));
$bossy = array_filter(array_keys($all), fn($id) => (int)q_val("SELECT COUNT(*) FROM routes WHERE id = ? AND kind = 'side'", [$id]) > 0 && false);
ok('no route of the list is a plain unknown id', rk_of(999999) === null && rk_of(array_key_first($all)) !== null);

set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
$u0 = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u0['id'];
$pick = function (string $kind) use ($all) { foreach ($all as $id => $k) if ($k['kind'] === $kind) return [$id, $k]; return [0, null]; };
/** put sprout at the a end of the route, nothing active, given Petals / energy, no tools, no boots */
$setup = function (int $rid, int $petals = 500) use ($uid) {
    q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
    $r = q_one('SELECT * FROM routes WHERE id = ?', [$rid]);
    q('UPDATE users SET location_id = ?, level = 40, energy = 90, coins = ?, ev_quickwalk = 0, game_day = 5, game_minute = 360 WHERE id = ?', [$r['a_id'], $petals, $uid]);
    q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE effects LIKE ? OR effects LIKE ? OR effects LIKE ? OR slug = ?)', [$uid, '%"tool":"lantern"%', '%"tool":"staff"%', '%"tool":"axe"%', 'flood-boots']);
    tool_cache_reset();
    $to = q_one('SELECT * FROM locations WHERE id = ?', [$r['b_id']]);   // a side path only starts toward a place you know: make it known
    if ($to && !place_known($uid, $to)) unlock_entries($uid, ($to['kind'] === 'village' ? 'village:' : 'landmark:') . $to['slug']);
    return q_one('SELECT * FROM users WHERE id = ?', [$uid]);
};
$tool = function (string $type, int $tier) use ($uid) {   // a throwaway tool item of the type and tier in the satchel
    $slug = "rk-test-$type-$tier";
    if (!item_id_by_slug($slug)) db_insert('items', ['name' => "Test $type $tier", 'slug' => $slug, 'category' => 'tool', 'rarity' => 5, 'base_price' => 1, 'description' => 't', 'edible' => 0, 'effects' => json_encode(['tool' => $type, 'tier' => $tier]), 'tradable' => 0]);
    give_item($uid, item_id_by_slug($slug), 1); tool_cache_reset();
};
$clock = fn() => (int)q_val('SELECT game_day * 1440 + game_minute FROM users WHERE id = ?', [$uid]);
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);

echo "== ferry: 20 Petals a crossing\n";
[$rid, $k] = $pick('ferry'); $u = $setup($rid, 19);
[$a, $m] = start_expedition($u, $rid);
ok('with 19 Petals the walk does not start and nothing is spent', !$a && $coins() === 19 && !active_expedition($uid), $m);
$u = $setup($rid, 500); [$a, $m] = start_expedition($u, $rid);
ok('with 500 Petals it starts and takes exactly 20', $a && $coins() === 480, "$m / " . $coins());
ok('the message says so', str_contains((string)$m, 'ferry'), $m);

echo "== tunnel (lantern) and pass (staff): the tool tier is the gate\n";
foreach (['tunnel' => 'lantern', 'pass' => 'staff'] as $kind => $type) {
    [$rid, $k] = $pick($kind); $u = $setup($rid); $t = $k['tier'];
    [$a, $m] = start_expedition($u, $rid);
    ok("$kind without a $type: refused, and the message names the tier", !$a && str_contains($m, 'tier ' . $t) && !active_expedition($uid), $m);
    $tool($type, $t - 1); [$a, $m] = start_expedition(q_one('SELECT * FROM users WHERE id = ?', [$uid]), $rid);
    ok("$kind with a tier " . ($t - 1) . " $type: still refused", !$a, $m);
    $tool($type, $t); [$a, $m] = start_expedition(q_one('SELECT * FROM users WHERE id = ?', [$uid]), $rid);
    ok("$kind with a tier $t $type: the walk starts", $a, $m);
}

echo "== overgrown and flooded: more game minutes a section\n";
$sections = fn(int $rid) => trail_sections(q_one('SELECT * FROM routes WHERE id = ?', [$rid]));
[$rid, $k] = $pick('overgrown'); $S = $sections($rid);
$u = $setup($rid); $t0 = $clock(); [$a, $m] = start_expedition($u, $rid); $d1 = $clock() - $t0;
$base = gclock_time_cost('travel') * $S;
ok("overgrown without an axe: +10 per section over the plain $base ($S sections)", $a && $d1 === $base + 10 * $S, "got $d1");
$u = $setup($rid); $tool('axe', 1); $t0 = $clock(); [$a, $m] = start_expedition(q_one('SELECT * FROM users WHERE id = ?', [$uid]), $rid); $d2 = $clock() - $t0;
ok('overgrown with an axe (tier 1): no slowdown', $a && $d2 === $base, "got $d2");
[$rid, $k] = $pick('flooded'); $S = $sections($rid); $base = gclock_time_cost('travel') * $S;
$u = $setup($rid); $t0 = $clock(); [$a] = start_expedition($u, $rid); $d3 = $clock() - $t0;
ok('flooded: +10 per section', $a && $d3 === $base + 10 * $S, "got $d3");
$u = $setup($rid); rk_ensure_items(); give_item($uid, item_id_by_slug('flood-boots'), 1); $t0 = $clock(); [$a] = start_expedition(q_one('SELECT * FROM users WHERE id = ?', [$uid]), $rid); $d4 = $clock() - $t0;
ok('flooded with Flood Boots: +5 per section', $a && $d4 === $base + 5 * $S, "got $d4");
ok('Flood Boots are on sale in a shop', (int)q_val('SELECT COUNT(*) FROM shop_stock WHERE item_id = ?', [item_id_by_slug('flood-boots')]) > 0);

echo "== toll: the question at the first stretch\n";
[$rid, $k] = $pick('toll'); $S = $sections($rid); $base = gclock_time_cost('travel') * $S;
$u = $setup($rid); $t0 = $clock(); [$a, $m] = start_expedition($u, $rid);
ok('the walk starts and no travel time is charged yet', $a && $clock() === $t0 && $coins() === 500, "$m");
$exp = active_expedition($uid); $exp['encounter'] = null; $sc = trail_scene($exp);
ok('the scene has no toll answer yet', $sc && rk_toll_open($rid, $sc['st']));
[$ga, $gm] = trail_go($u, $exp, $sc['map']['entry'][0], $sc['map']['entry'][1] + 1);
ok('walking is refused until the toll is settled', !$ga && str_contains((string)$gm, 'toll'), (string)$gm);
$strip = trail_strip_html($u, $exp, $sc);
ok('the strip shows the toll card with both buttons', str_contains($strip, 'value="trail_toll"') && str_contains($strip, 'Take the old road') && str_contains($strip, 'Pay 10 Petals'));
[$pa, $pm] = trail_toll($u, $exp, true);
ok('paying takes exactly 10 Petals', $pa && $coins() === 490, "$pm / " . $coins());
ok('and charges 5 game minutes a section', $clock() - $t0 === RK_TOLL_MIN * $S, 'got ' . ($clock() - $t0));
ok('a Toll Receipt is in the satchel', rk_has_item($uid, 'toll-receipt'));
$sc = trail_scene($exp);
ok('the scene says paid and the fight chance is halved', rk_toll_paid($sc['st']) && abs(rk_enc_base($sc['st']) - (float)setting('trail_enc_pct') * 0.5) < 1e-9);
[$pa2] = trail_toll($u, $exp, true);
ok('a second answer (double tap, second tab) takes nothing', !$pa2 && $coins() === 490);
ok('and the strip no longer asks', !str_contains(trail_strip_html($u, $exp, $sc), 'value="trail_toll"'));
// refuse
$u = $setup($rid); $t0 = $clock(); start_expedition($u, $rid); $exp = active_expedition($uid); $exp['encounter'] = null;
[$ra, $rm] = trail_toll($u, $exp, false);
ok('taking the old road costs nothing and charges the plain time', $ra && $coins() === 500 && $clock() - $t0 === $base, "got " . ($clock() - $t0));
ok('the old road keeps the normal fight chance', rk_enc_base(trail_scene($exp)['st']) === null);
// not enough Petals
$u = $setup($rid, 5); start_expedition($u, $rid); $exp = active_expedition($uid); $exp['encounter'] = null;
[$na, $nm] = trail_toll($u, $exp, true);
ok('with 5 Petals paying is refused and the question stays open', !$na && $coins() === 5 && rk_toll_open($rid, trail_scene($exp)['st']), $nm);
// the answer travels to the next stretch
$u = $setup($rid); start_expedition($u, $rid); $exp = active_expedition($uid); $exp['encounter'] = null; trail_toll($u, $exp, true);
$sc = trail_scene($exp); [$ex, $ey] = $sc['map']['spots']['9']; $sc['x'] = $ex; $sc['y'] = $ey; $sc['st']['phase'] = 'confirm'; foreach ($sc['st']['tokens'] as $i => $t) $sc['st']['tokens'][$i][3] = 1; trail_save($sc);
if ($S > 1) { [$na] = trail_next($u, $exp); $s2 = trail_scene($exp); ok('Continue keeps the paid toll for the next stretch', $na && rk_toll_paid($s2['st'])); }

echo "== a plain road is untouched\n";
$plain = (int)q_val('SELECT id FROM routes WHERE id NOT IN (' . implode(',', array_keys($all)) . ") AND kind = 'road' ORDER BY id LIMIT 1");
$u = $setup($plain); $S = $sections($plain); $t0 = $clock(); [$a, $m] = start_expedition($u, $plain);
ok('a plain road: starts, plain time, no Petals taken', $a && $clock() - $t0 === gclock_time_cost('travel') * $S && $coins() === 500, "$m");
ok('no kind chip for it', rk_label(rk_of($plain)) === '');
echo "== the Almanac page\n";
require_once $argv[1] . '/includes/almanac_pages.php';
$u = $setup($pick('ferry')[0]); q('DELETE FROM user_encyclopedia WHERE user_id = ? AND entry_id IN (SELECT id FROM encyclopedia_entries WHERE unlock_key = ?)', [$uid, 'roadkinds']);
ok('the Special roads page is not open before a kind road is walked', !(int)q_val('SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key = ?', [$uid, 'roadkinds']));
start_expedition($u, $pick('ferry')[0]);
ok('starting a ferry walk opens it, and it names every kind', (int)q_val('SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key = ?', [$uid, 'roadkinds']) === 1
    && ($b = (string)q_val("SELECT body FROM encyclopedia_entries WHERE unlock_key = 'roadkinds'")) !== '' && !array_filter(['Ferry', 'Tunnel', 'Pass', 'Toll road', 'Overgrown', 'Flooded'], fn($w) => !str_contains($b, '[b]' . $w . '[/b]')));
echo "== labels\n";
foreach (RK_KINDS as $kd) ok("label and text for $kd", rk_label(['kind' => $kd, 'tier' => 2]) !== '' && rk_text($kd, 2) !== '');
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
