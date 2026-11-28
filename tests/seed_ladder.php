<?php
// 2.8.100 The seed ladder (claude/proposal-seed-ladder.md, includes/seed_ladder.php): 14 seeds at Twigg's and Wren's five in each region town for a
// new gnome, gates m1-m4 / r1-r4 that open by a garden way or a road way and latch for good, one harvest opens a row, story seeds always open
// (start shelves + step ties, with a lint), the bottom drawer, the special order, old gnomes from their record, and: setting off = shops and buys
// exactly as before (golden hashes recorded from the code before the ladder), no price changes, shops never buy seeds, florists untouched.
// Usage: php tests/seed_ladder.php GAME_DIR [PORT]   (a walk.sh install: player "sprout"; with PORT a server for GAME_DIR answers on it)
$_SERVER['SCRIPT_NAME'] = '/index.php';
$GAME = $argv[1];
$PORT = (int)($argv[2] ?? 0);
require $GAME . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/world.php';
require_once APP_ROOT . '/includes/stops.php';
require_once APP_ROOT . '/includes/stop_marks.php';
require_once APP_ROOT . '/includes/seals.php';
require_once APP_ROOT . '/includes/town_states.php';
require_once APP_ROOT . '/includes/contests.php';
require_once APP_ROOT . '/includes/journey_v2.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
function done(): void { global $fails; echo $fails ? "$fails FAILED\n" : "ok\n"; exit($fails ? 1 : 0); }

$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$admin = (int)q_val("SELECT id FROM users WHERE username = 'admin'");
ok('player sprout exists', $uid > 0);
$na = (int)q_val("SELECT id FROM regions WHERE code = 'NA'");
$town = q_one("SELECT * FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$na]);
$hub = q_one("SELECT s.* FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.kind = 'hub' AND s.shop_type = 'seeds'");
$naShop = q_one("SELECT * FROM shops WHERE location_id = ? AND shop_type = 'seeds'", [(int)$town['id']]);
$petal = q_one("SELECT s.* FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.kind = 'hub' AND s.shop_type = 'florist'");
$hedge = q_one("SELECT s.* FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.kind = 'hub' AND s.shop_type = 'decor'");
$townShops = q("SELECT s.id, s.name, r.code, r.id AS rid, l.id AS loc_id FROM shops s JOIN locations l ON l.id = s.location_id JOIN regions r ON r.id = l.region_id
                WHERE s.shop_type = 'seeds' AND l.kind = 'market' ORDER BY s.id")->fetchAll();
ok('Twigg\'s, Maple & Furrow, Petalpin\'s, Hedge & Hearth and 14 region seed shops', $hub && $naShop && $petal && $hedge && count($townShops) === 14);
$seedShopIds = array_merge([(int)$hub['id']], array_map(fn($s) => (int)$s['id'], $townShops));
$rowBySlug = fn(int $shopId, string $plant) => q_one('SELECT st.* FROM shop_stock st JOIN plants p ON p.seed_item_id = st.item_id WHERE st.shop_id = ? AND p.slug = ?', [$shopId, $plant]);

setg('npc_clockwork', '0');
q('UPDATE users SET location_id = ?, location = ?, region_id = ?, game_day = 10, game_minute = 600, coins = 10000000, guest = 0 WHERE id = ?', [(int)$town['id'], 'The Maplewold', $na, $uid]);
q("DELETE FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid]);
$U = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$allShops = array_merge($seedShopIds, [(int)$petal['id'], (int)$hedge['id']]);
q('UPDATE shops SET last_restock = ? WHERE id IN (' . implode(',', $allShops) . ')', [now()]);   // no restock during the test
$pin = function () use ($allShops) { q('UPDATE shop_stock SET current_stock = (id % 5) + 1, current_price = price_min WHERE shop_id IN (' . implode(',', $allShops) . ')'); };
$stockOf = fn(int $sid) => (int)q_val('SELECT current_stock FROM shop_stock WHERE id = ?', [$sid]);
$haveQty = fn(int $itemId) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $itemId]);

// ---------------------------------------------------------------- HTTP helpers (as tests/town_states.php)
$ck = tempnam(sys_get_temp_dir(), 'slck');
$get = function (string $path) use ($PORT, $ck): string {
    $c = curl_init('http://127.0.0.1:' . $PORT . '/' . $path);
    curl_setopt_array($c, [CURLOPT_RETURNTRANSFER => true, CURLOPT_COOKIEJAR => $ck, CURLOPT_COOKIEFILE => $ck, CURLOPT_TIMEOUT => 60, CURLOPT_FOLLOWLOCATION => true]);
    $h = (string)curl_exec($c); curl_close($c); return $h;
};
$post = function (string $path, array $f) use ($PORT, $ck): string {
    $c = curl_init('http://127.0.0.1:' . $PORT . '/' . $path);
    curl_setopt_array($c, [CURLOPT_RETURNTRANSFER => true, CURLOPT_COOKIEJAR => $ck, CURLOPT_COOKIEFILE => $ck, CURLOPT_POST => true, CURLOPT_POSTFIELDS => http_build_query($f), CURLOPT_TIMEOUT => 60, CURLOPT_FOLLOWLOCATION => true]);
    $h = (string)curl_exec($c); curl_close($c); return $h;
};
$norm = fn(string $h) => trim(preg_replace('/\s+/', ' ', preg_replace('/\d+/', '', preg_replace('/name="(csrf|_n)" value="[^"]*"/', '', $h))));
$between = function (string $h, string $a, array $bs): string { $i = strpos($h, $a); if ($i === false) return ''; $j = false; foreach ($bs as $b) { $j = strpos($h, $b, $i); if ($j !== false) break; } return substr($h, $i, ($j === false ? strlen($h) : $j) - $i); };
/** The shop: crumbs and header, each tile's stock id, how many can be bought and its item name, the bare line and the flashes. */
$shopFrag = function (string $h) use ($between, $norm): string {
    preg_match_all('/<div class="btile stile[^"]*" data-cat="[^"]*" data-id="(\d+)" data-price="\d+" data-max="(\d+)"/', $h, $m, PREG_SET_ORDER);
    return $norm($between($h, '<p class="crumbs">', ['<p class="status shopintro">'])) . '|' . implode(',', array_map(fn($x) => $x[1] . 'x' . $x[2], $m))
        . '|' . (str_contains($h, 'The shelves are bare') ? 'bare' : '') . '|' . (int)substr_count($h, 'class="flash') . '|' . (int)substr_count($h, 'Not on the shelf yet');
};
$csrf = function (string $h): string { preg_match('/name="csrf" value="([^"]*)"/', $h, $m); return $m[1] ?? ''; };
/** A buy, normalised (digits out: prices drift with the day): ok flag, message, what left the shelf and what the gnome got. */
$buyFrag = function (int $shopId, string $plant) use ($rowBySlug, $U, $stockOf, $haveQty, $norm): string {
    $r = $rowBySlug($shopId, $plant);
    $s0 = $stockOf((int)$r['id']); $h0 = $haveQty((int)$r['item_id']);
    [$okB, $msg] = buy_from_shop($U(), (int)$r['id'], 1);
    return ($okB ? 'ok' : 'no') . '|' . $norm($msg) . '|' . ($s0 - $stockOf((int)$r['id'])) . '|' . ($haveQty((int)$r['item_id']) - $h0);
};
$GOLD = ['hub' => '4d9069516aa3567c7dbbcd070b0365914cf7a358', 'na' => '6d4d4f40e5cb60b8f685a4000c84618424c74b42', 'petal' => '86b4a357abb549dd985607f7c45371785029af1a', 'buy' => '7ed4105e7104dc7037062da2fb164cbe7e20f740'];   // recorded from the code before the ladder
$golden = function () use ($PORT, $get, $shopFrag, $buyFrag, $pin, $hub, $naShop, $petal): array {
    $pin();
    $g = [];
    if ($PORT > 0) {
        $g['hub'] = sha1($shopFrag($get('shop.php?id=' . (int)$hub['id'])));
        $g['na'] = sha1($shopFrag($get('shop.php?id=' . (int)$naShop['id'])));
        $g['petal'] = sha1($shopFrag($get('shop.php?id=' . (int)$petal['id'])));
    }
    $g['buy'] = sha1($buyFrag((int)$hub['id'], 'radish') . '#' . $buyFrag((int)$hub['id'], 'beet') . '#' . $buyFrag((int)$naShop['id'], 'oats') . '#' . $buyFrag((int)$naShop['id'], 'hops'));
    $pin();
    return $g;
};

setg('seed_ladder_open', '0');
setg('town_states_open', '0');
setg('stop_marks_open', '0');
if ($PORT > 0) {
    $lp = $get('login.php');
    $post('login.php', ['csrf' => $csrf($lp), 'username' => 'sprout', 'password' => 'TestPass123!']);
    ok('logged in: Twigg\'s shows', str_contains($get('shop.php?id=' . (int)$hub['id']), 'Twigg'));
}
echo "== setting off: the shops and a buy are exactly as before the ladder (golden hashes)\n";
$G0 = $golden();
foreach ($G0 as $k => $v) ok("golden $k with seed_ladder_open = 0", $v === $GOLD[$k], "got $v; if the page changed on purpose, record the new hash here");
if (getenv('SL_GOLD_DUMP')) { echo json_encode($G0) . "\n"; }

$have = is_file(APP_ROOT . '/includes/seed_ladder.php');
ok('includes/seed_ladder.php is there', $have);
if (!$have) done();
require_once APP_ROOT . '/includes/seed_ladder.php';

echo "== the setting\n";
$sch = settings_schema();
ok('seed_ladder_open defaults to 0 and is in the settings list', array_key_exists('seed_ladder_open', $sch) && (string)$sch['seed_ladder_open']['default'] === '0');
ok('it sits beside town_states_open (Hollow group)', ($k = array_keys($sch)) && array_search('seed_ladder_open', $k, true) === array_search('town_states_open', $k, true) + 1);
ok('its label starts "Seed ladder:"', str_starts_with((string)$sch['seed_ladder_open']['label'], 'Seed ladder:'));
ok('off: seed_ladder_on() is false', !seed_ladder_on());

echo "== slice 0: data (the 14, the 14 fives, the gate rule)\n";
$n1 = seed_ladder_ensure();
$gates = function () use ($seedShopIds): array { $o = []; foreach (q('SELECT st.id, st.shop_id, st.ladder_gate FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE i.category = \'seed\' AND st.shop_id IN (' . implode(',', $seedShopIds) . ') ORDER BY st.id')->fetchAll() as $r) $o[(int)$r['id']] = $r['ladder_gate']; return $o; };
$g1 = $gates();
ok('the first run fills every seed row of the 15 seed shops', $n1 === 36 + 293 && !in_array(null, $g1, true), "set $n1");
$cnt = fn(int $shopId, ?string $gate) => (int)q_val('SELECT COUNT(*) FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE i.category = \'seed\' AND st.shop_id = ?' . ($gate === null ? ' AND st.ladder_gate <> \'\'' : ' AND st.ladder_gate = ?'), $gate === null ? [$shopId] : [$shopId, $gate]);
ok('Twigg\'s: 14 rows with gate \'\', 22 gated (6 / 6 / 6 / 4)', $cnt((int)$hub['id'], '') === 14 && $cnt((int)$hub['id'], null) === 22 && $cnt((int)$hub['id'], 'm1') === 6 && $cnt((int)$hub['id'], 'm2') === 6 && $cnt((int)$hub['id'], 'm3') === 6 && $cnt((int)$hub['id'], 'm4') === 4);
$t0 = 0; $tg = 0; foreach ($townShops as $s) { $t0 += $cnt((int)$s['id'], ''); $tg += $cnt((int)$s['id'], null); }
ok('the 14 towns: 70 rows with gate \'\', 223 gated', $t0 === 70 && $tg === 223, "$t0 / $tg");
$slugsOf = fn(int $shopId, string $gate) => q('SELECT p.slug FROM shop_stock st JOIN plants p ON p.seed_item_id = st.item_id WHERE st.shop_id = ? AND st.ladder_gate = ? ORDER BY p.slug', [$shopId, $gate])->fetchAll(PDO::FETCH_COLUMN);
$sorted = function (string $csv) { $a = explode(',', $csv); sort($a); return $a; };
$HUB = ['' => 'radish,lettuce,carrot,tomato,onion,potato,pea,mint,basil,dill,strawberry,sunflower,white-clover,pumpkin', 'm1' => 'beet,cucumber,spinach,turnip,green-bean,garlic',
    'm2' => 'coriander,parsley,thyme,lemon-balm,peppermint,kale', 'm3' => 'cabbage,broccoli,cauliflower,celery,fennel,crimson-clover', 'm4' => 'winter-rye,garden-sage,rosemary,horseradish'];
foreach ($HUB as $g => $csv) ok("Twigg's gate '$g' is exactly the proposal's list", $slugsOf((int)$hub['id'], $g) === $sorted($csv), implode(',', $slugsOf((int)$hub['id'], $g)));
$FIVES = ['NA' => 'oats,lentil,wild-rice,apple,goldenrod', 'CA' => 'corn,black-bean,tomatillo,amaranth,marigold', 'NWE' => 'rye,leek,barley,brussels-sprouts,heather',
    'CB' => 'sweet-potato,plantain,pigeon-pea,breadfruit,frangipani', 'SA' => 'cassava,peanut,quinoa,yerba-mate,passionflower', 'SE' => 'artichoke,fava-bean,oregano,olive,lavender',
    'EE' => 'buckwheat,plum,bell-pepper,sorrel,chamomile', 'MENA' => 'chickpea,eggplant,cumin,date,damask-rose', 'CSA' => 'wheat,mung-bean,ginger,turmeric,sacred-lotus',
    'WCA' => 'yam,okra,millet,fonio,wild-gardenia', 'ESA' => 'teff,sorghum,collard,banana,king-protea', 'EA' => 'bok-choy,daikon,adzuki,persimmon,sakura',
    'SEA' => 'rice,kangkong,lemongrass,bitter-melon,sampaguita', 'OC' => 'taro,coconut,pandanus,warrigal-greens,tiare'];
foreach ($townShops as $s) ok("{$s['name']} ({$s['code']}): Wren's five is exactly the proposal's", $slugsOf((int)$s['id'], '') === $sorted($FIVES[$s['code']]), implode(',', $slugsOf((int)$s['id'], '')));
ok('Maple & Furrow r1 = kidney-bean, soybean, black-eyed-susan, california-poppy, blue-violet; r2 = raspberry; r4 = hops', $slugsOf((int)$naShop['id'], 'r1') === $sorted('kidney-bean,soybean,black-eyed-susan,california-poppy,blue-violet') && $slugsOf((int)$naShop['id'], 'r2') === ['raspberry'] && $slugsOf((int)$naShop['id'], 'r4') === ['hops']);
$caShop = current(array_filter($townShops, fn($s) => $s['code'] === 'CA'));
ok('Kernel & Cob r2 = chayote, nopal, papaya', $slugsOf((int)$caShop['id'], 'r2') === ['chayote', 'nopal', 'papaya']);
$n2 = seed_ladder_ensure();
ok('a second run changes nothing', $n2 === 0 && $gates() === $g1);
$nonSeed = (int)q_val("SELECT COUNT(*) FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE i.category <> 'seed' AND COALESCE(st.ladder_gate, '') <> ''");
ok('no other row gets a gate (tools, guides, florists, kitchen)', $nonSeed === 0);
q("UPDATE shop_stock SET ladder_gate = '' WHERE id = ?", [(int)$rowBySlug((int)$hub['id'], 'horseradish')['id']]);
seed_ladder_ensure();
ok('an Admin edit (horseradish to always) is kept by the next run', q_val('SELECT ladder_gate FROM shop_stock WHERE id = ?', [(int)$rowBySlug((int)$hub['id'], 'horseradish')['id']]) === '');
q("UPDATE shop_stock SET ladder_gate = 'm4' WHERE id = ?", [(int)$rowBySlug((int)$hub['id'], 'horseradish')['id']]);
ok('the tables are there', (bool)q('SELECT COUNT(*) FROM seed_ladder_gates')->fetch() && (bool)q('SELECT COUNT(*) FROM seed_ladder_items')->fetch());

// ---------------------------------------------------------------- a new gnome (sprout, made after the switch)
$clean = function () use ($uid, $admin) {
    foreach (['seed_ladder_gates', 'seed_ladder_items', 'seed_ladder_orders', 'town_backroom', 'town_state_best', 'stop_marks', 'region_seals', 'user_plant_knowledge', 'user_quests'] as $t) q("DELETE FROM $t WHERE user_id IN (?, ?)", [$uid, $admin]);
    q("DELETE FROM stop_prog WHERE user_id IN (?, ?) AND k LIKE 'meter:%'", [$uid, $admin]);
    q('DELETE FROM plots WHERE user_id = ? AND region_id <> (SELECT region_id FROM users WHERE id = ?)', [$uid, $uid]);
    town_states_reset(); seed_ladder_reset();
};
$asNew = function () use ($clean) { setg('seed_ladder_since', '2000-01-01 00:00:00'); $clean(); };
$openRows = fn(int $shopId) => count(seed_ladder_shelf($U(), $shopId)['open_seeds']);
$openSlugs = function (int $shopId) use ($U): array { $a = array_map(fn($r) => (string)$r['plant_slug'], seed_ladder_shelf($U(), $shopId)['open_seeds']); sort($a); return $a; };
$know = function (array $plantIds) use ($uid) { foreach ($plantIds as $p) { q('DELETE FROM user_plant_knowledge WHERE user_id = ? AND plant_id = ?', [$uid, $p]); db_insert('user_plant_knowledge', ['user_id' => $uid, 'plant_id' => $p, 'knowledge' => 10]); } seed_ladder_reset(); };
$plantId = fn(string $slug) => (int)q_val('SELECT id FROM plants WHERE slug = ?', [$slug]);
$notAtTwigg = q('SELECT p.id FROM plants p WHERE p.seed_item_id NOT IN (SELECT item_id FROM shop_stock WHERE shop_id = ?) ORDER BY p.id LIMIT 30', [(int)$hub['id']])->fetchAll(PDO::FETCH_COLUMN);
$show = show_crop();

setg('seed_ladder_open', '1');
echo "== slice 1: a new gnome sees 14 and 5 (all road systems off)\n";
$asNew();
ok('on: seed_ladder_on()', seed_ladder_on());
$hubStart = $openSlugs((int)$hub['id']);
$expHub = $sorted($HUB['']); if (!in_array($show, $expHub, true) && $rowBySlug((int)$hub['id'], $show)) { $expHub[] = $show; sort($expHub); }
ok('Twigg\'s: exactly the start 14 (+ this week\'s Village Show crop "' . $show . '" when it is gated)', $hubStart === $expHub, implode(',', $hubStart));
foreach ($townShops as $s) ok("{$s['name']}: exactly 5 seeds", $openSlugs((int)$s['id']) === $sorted($FIVES[$s['code']]), implode(',', $openSlugs((int)$s['id'])));
ok('the region guide is still on the shelf (not a seed)', (bool)array_filter(seed_ladder_shelf($U(), (int)$naShop['id'])['open'], fn($r) => $r['category'] === 'guide'));
ok('the starter seeds a new gnome holds (kidney-bean, soybean, coneflower) do not open their rows', !seed_ladder_row_open($U(), $rowBySlug((int)$naShop['id'], 'kidney-bean')) && !seed_ladder_row_open($U(), $rowBySlug((int)$naShop['id'], 'coneflower')));
ok('every shipped gate starts closed', !seed_ladder_gate_open($uid, (int)$hub['id'], 'm1') && !seed_ladder_gate_open($uid, (int)$naShop['id'], 'r1'));

echo "== the Mossbottom tiers by the garden way: 14 / 20 / 26 / 32 / 36\n";
$showGate = (string)q_val('SELECT ladder_gate FROM shop_stock WHERE id = ?', [(int)($rowBySlug((int)$hub['id'], $show)['id'] ?? 0)]);
foreach ([[4, 14, ''], [5, 20, 'm1'], [10, 26, 'm2'], [16, 32, 'm3'], [24, 36, 'm4']] as [$k, $want, $upTo]) {
    $asNew(); $know(array_slice($notAtTwigg, 0, $k));
    $got = $openRows((int)$hub['id']);
    $extra = $showGate !== '' && strcmp($showGate, $upTo) > 0 ? 1 : 0;   // the show crop is open whatever its gate
    ok("$k different crops harvested: Twigg's shows $want" . ($extra ? ' (+ the show crop)' : ''), $got === $want + $extra, "got $got");
}

echo "== the 14 towns by the garden way: 70 / 119 / 154 / 266 / 293\n";
$T = [0, 0, 0, 0, 0];
$tierPlants = function (int $rid, string $tier) { return array_map('intval', q('SELECT plant_id FROM plant_regions WHERE region_id = ? AND tier = ? ORDER BY plant_id', [$rid, $tier])->fetchAll(PDO::FETCH_COLUMN)); };
foreach ($townShops as $s) {
    $rid = (int)$s['rid']; $sid = (int)$s['id'];
    $five = array_map($plantId, explode(',', $FIVES[$s['code']]));
    $fiveStaples = array_values(array_intersect($five, $tierPlants($rid, 'staple')));
    $fiveFlower = array_values(array_intersect($five, $tierPlants($rid, 'flower')));
    $treasure = $tierPlants($rid, 'treasure');
    $asNew(); $T[0] += $openRows($sid);
    $asNew(); $know(array_slice($fiveStaples, 0, 2)); $c1 = $openRows($sid); $T[1] += $c1;
    $r1Flowers = array_map($plantId, $slugsOf($sid, 'r1'));
    $r1Flowers = array_values(array_intersect($r1Flowers, $tierPlants($rid, 'flower')));
    $asNew(); $know(array_merge(array_slice($fiveStaples, 0, 2), $five, array_slice($treasure, 0, 1))); $c2 = $openRows($sid); $T[2] += $c2;
    ok("{$s['code']}: 2 staples -> r1 only, 6 plants -> r2 too", seed_ladder_gate_open($uid, $sid, 'r2') && !seed_ladder_gate_open($uid, $sid, 'r3'), "$c1 / $c2");
    $asNew(); $know(array_merge(array_slice($fiveStaples, 0, 2), $five, array_slice($treasure, 0, 1), $fiveFlower, array_slice($r1Flowers, 0, 2))); $c3 = $openRows($sid); $T[3] += $c3;
    $openNow = array_map($plantId, array_map(fn($r) => $r['plant_slug'], seed_ladder_shelf($U(), $sid)['open_seeds']));
    $twelve = array_slice(array_values(array_unique(array_merge($five, $treasure, $openNow))), 0, 12);
    $asNew(); $know($twelve); seed_ladder_gate_open($uid, $sid, 'r1'); seed_ladder_gate_open($uid, $sid, 'r2'); seed_ladder_gate_open($uid, $sid, 'r3');
    $know(array_merge($twelve, array_slice($fiveStaples, 0, 2), $fiveFlower, array_slice($r1Flowers, 0, 2)));
    $c4 = $openRows($sid); $T[4] += $c4;
}
ok('all 14 towns: start 70', $T[0] === 70, json_encode($T));
ok('all 14 towns: r1 119', $T[1] === 119, json_encode($T));
ok('all 14 towns: r2 154', $T[2] === 154, json_encode($T));
ok('all 14 towns: r3 266', $T[3] === 266, json_encode($T));
ok('all 14 towns: r4 293 = today', $T[4] === 293, json_encode($T));

echo "== latches never close; one harvest opens a row for good\n";
$asNew(); $know(array_slice($notAtTwigg, 0, 5));
ok('5 crops: m1 opens', seed_ladder_gate_open($uid, (int)$hub['id'], 'm1') && seed_ladder_row_open($U(), $rowBySlug((int)$hub['id'], 'beet')));
q('DELETE FROM user_plant_knowledge WHERE user_id = ?', [$uid]); seed_ladder_reset();
ok('...every crop record gone (Admin reset of the Almanac): m1 stays open (latched)', seed_ladder_gate_open($uid, (int)$hub['id'], 'm1') && seed_ladder_row_open($U(), $rowBySlug((int)$hub['id'], 'beet')));
ok('...the latch is one row of seed_ladder_gates', (int)q_val("SELECT COUNT(*) FROM seed_ladder_gates WHERE user_id = ? AND gate = 'm1'", [$uid]) === 1);
setg('mark_decay', '50'); seed_ladder_reset();
ok('...a bigger mark_decay closes nothing', seed_ladder_gate_open($uid, (int)$hub['id'], 'm1'));
setg('mark_decay', '0');
$hops = $rowBySlug((int)$naShop['id'], 'hops');
ok('hops (r4) is locked for a new gnome', !seed_ladder_row_open($U(), $hops));
$know([$plantId('hops')]);
ok('one harvest of hops (a gift, a find, a saved seed): its row opens', seed_ladder_row_open($U(), $hops));
q('DELETE FROM user_plant_knowledge WHERE user_id = ?', [$uid]); seed_ladder_reset();
ok('...for good (latched in seed_ladder_items as grown)', seed_ladder_row_open($U(), $hops) && q_val('SELECT how FROM seed_ladder_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$hops['item_id']]) === 'grown');
ok('...and nothing else in the r4 gate opened', !seed_ladder_gate_open($uid, (int)$naShop['id'], 'r4'));
ok('per gnome: admin is not changed by sprout\'s latches', seed_ladder_shelf(q_one('SELECT * FROM users WHERE id = ?', [$admin]), (int)$naShop['id'])['admin_all'] === true);
q("UPDATE users SET role = 'player' WHERE id = ?", [$admin]);
ok('...a plain second gnome still sees 5 at Maple & Furrow', count(seed_ladder_shelf(q_one('SELECT * FROM users WHERE id = ?', [$admin]), (int)$naShop['id'])['open_seeds']) === 5);
q("UPDATE users SET role = 'admin' WHERE id = ?", [$admin]);
ok('an admin sees every row (with a gate tag), a "view as a new gnome" shows 5', count(seed_ladder_shelf(q_one('SELECT * FROM users WHERE id = ?', [$admin]), (int)$naShop['id'])['open_seeds']) === 20
    && count(seed_ladder_shelf(q_one('SELECT * FROM users WHERE id = ?', [$admin]), (int)$naShop['id'], true)['open_seeds']) === 5);
$asNew();
db_insert('plots', ['user_id' => $uid, 'region_id' => (int)$caShop['rid'], 'garden_name' => 'test plot', 'created_at' => now()]);
seed_ladder_reset();
ok('a second garden in another area (Maizehollow) opens r1 there', seed_ladder_gate_open($uid, (int)$caShop['id'], 'r1'));
ok('...but the home garden does not open r1 at home (the Maplewold stays at 5)', !seed_ladder_gate_open($uid, (int)$naShop['id'], 'r1'));

echo "== slice 4: the road ways (lasting marks, town states, Seals on)\n";
setg('stop_marks_open', '1'); setg('town_states_open', '1'); setg('seals_open', '1');
$home = (int)q_val('SELECT home_village_id FROM users WHERE id = ?', [$uid]);
$vill = array_map('intval', q("SELECT id FROM locations WHERE region_id = ? AND kind = 'village' ORDER BY id", [$na])->fetchAll(PDO::FETCH_COLUMN));
$others = array_values(array_diff($vill, [$home]));
$latch = fn(int $lid, string $bar = 'repairs') => db_insert('stop_marks', ['user_id' => $uid, 'location_id' => $lid, 'bar' => $bar, 'perk_key' => '', 'filled_on' => gclock_my_date(), 'latched_at' => now(), 'kept' => 0]);
$meter = fn(int $lid, int $n, string $bar = 'repairs') => stop_prog_set($uid, $lid, 'meter:' . $bar, $n, ['d' => gclock_my_date(), 'mk' => 1]);
$fresh = function () use ($uid, $town) { town_states_reset(); seed_ladder_reset(); mark_latched($uid, (int)$town['id'], true); foreach (q('SELECT DISTINCT location_id FROM stop_marks WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $l) mark_latched($uid, (int)$l, true); };
$asNew(); $fresh();
ok('road ways, nothing done: m1 and r1 closed', !seed_ladder_gate_open($uid, (int)$hub['id'], 'm1') && !seed_ladder_gate_open($uid, (int)$naShop['id'], 'r1'));
$caVill = array_map('intval', q("SELECT id FROM locations WHERE region_id = ? AND kind = 'village' ORDER BY id", [(int)$caShop['rid']])->fetchAll(PDO::FETCH_COLUMN));   // away from the Maplewold, whose town state is m3's
$meter($caVill[0], 33); $fresh();
ok('a bar at 33: m1 still closed', !seed_ladder_gate_open($uid, (int)$hub['id'], 'm1'));
$meter($caVill[0], 34); $fresh();
ok('m1: any bar at any stop reaches 34', seed_ladder_gate_open($uid, (int)$hub['id'], 'm1') && !seed_ladder_gate_open($uid, (int)$hub['id'], 'm2'));
$latch($caVill[1]); $fresh();
ok('m2: the first bar latched anywhere', seed_ladder_gate_open($uid, (int)$hub['id'], 'm2') && !seed_ladder_gate_open($uid, (int)$hub['id'], 'm3'));
$asNew(); $latch($home); $meter($others[0], 40); $fresh();
ok('m3: the Maplewold town Mending (R 15)', town_state($uid, $na) === 'work' && seed_ladder_gate_open($uid, (int)$hub['id'], 'm3') && !seed_ladder_gate_open($uid, (int)$hub['id'], 'm4'));
ok('r2: the town state Mending opens r2 at Maple & Furrow', seed_ladder_gate_open($uid, (int)$naShop['id'], 'r2'));
$asNew(); foreach ([0, 1, 2] as $i) $latch($others[$i]); $fresh();
ok('m3: or 3 bars latched', seed_ladder_gate_open($uid, (int)$hub['id'], 'm3'));
$asNew(); db_insert('region_seals', ['user_id' => $uid, 'region_id' => (int)$caShop['rid'], 'earned_at' => now()]); $fresh();
ok('m4: any Seal; r4 at Kernel & Cob: the area\'s Seal', seed_ladder_gate_open($uid, (int)$hub['id'], 'm4') && seed_ladder_gate_open($uid, (int)$caShop['id'], 'r4') && !seed_ladder_gate_open($uid, (int)$naShop['id'], 'r4'));
$asNew(); foreach (array_slice($others, 0, 8) as $l) $latch($l); $fresh();
ok('m4: or 8 bars latched; and Maplewold Thriving (R >= 50) opens r4 there', seed_ladder_gate_open($uid, (int)$hub['id'], 'm4') && seed_ladder_gate_open($uid, (int)$naShop['id'], 'r4'));
$asNew(); $meter((int)$town['id'], 34, 'larder'); $fresh();
ok('r1: any bar at the town reaches 34', seed_ladder_gate_open($uid, (int)$naShop['id'], 'r1'));
$asNew(); $latch((int)$town['id'], 'cheer'); $fresh();
ok('r3: Cheer latched at the town', seed_ladder_gate_open($uid, (int)$naShop['id'], 'r3'));
$asNew(); $latch($others[0], 'cheer'); $fresh();
ok('...one village is not enough', !seed_ladder_gate_open($uid, (int)$naShop['id'], 'r3'));
$latch($others[1], 'cheer'); $fresh();
ok('...Cheer latched at 2 villages of the area is', seed_ladder_gate_open($uid, (int)$naShop['id'], 'r3'));
echo "== town states off: the road ways that need R never fire, the garden ways carry the ladder\n";
setg('town_states_open', '0');
$asNew(); $latch($home); $meter($others[0], 40); $fresh();
ok('Mending record but town_states_open = 0: no m3, no r2 (and no error)', !seed_ladder_gate_open($uid, (int)$hub['id'], 'm3') && !seed_ladder_gate_open($uid, (int)$naShop['id'], 'r2'));
$know(array_slice($notAtTwigg, 0, 16));
ok('...16 crops still open m3 (garden way)', seed_ladder_gate_open($uid, (int)$hub['id'], 'm3'));
setg('stop_marks_open', '0'); setg('seals_open', '0');
$asNew(); $latch($others[0]); db_insert('region_seals', ['user_id' => $uid, 'region_id' => $na, 'earned_at' => now()]); $fresh();
ok('all three systems off: bars and Seals on file open nothing (and no error)', !seed_ladder_gate_open($uid, (int)$hub['id'], 'm2') && !seed_ladder_gate_open($uid, (int)$naShop['id'], 'r4'));

echo "== slice 3: the story never blocks (lint + step ties)\n";
$lint = seed_ladder_lint();
ok('lint: every seed a chapter, errand or First Week step names is on a start shelf or tied to its step', $lint['problems'] === [], implode('; ', $lint['problems']));
ok('lint: it read the v2 chapters, the errands and the old chapters', $lint['chapter_slugs'] >= 20 && $lint['errand_slugs'] >= 3, json_encode([$lint['chapter_slugs'], $lint['errand_slugs']]));
ok('lint: chayote is the one step-tied seed (ca-s05, ca-s08)', array_keys($lint['tied']) === ['chayote'] && count($lint['tied']['chayote']) === 2, json_encode($lint['tied']));
$asNew();
$bad = [];
foreach ($lint['needs'] as [$area, $slug, $src]) {
    $sid = $area === '' ? (int)$hub['id'] : (int)q_val("SELECT s.id FROM shops s JOIN locations l ON l.id = s.location_id JOIN regions r ON r.id = l.region_id WHERE s.shop_type = 'seeds' AND l.kind = 'market' AND r.code = ?", [$area]);
    $r = $rowBySlug($sid, $slug) ?: $rowBySlug((int)$hub['id'], $slug);
    if ($r && !in_array($src, ['errand ca-s05', 'errand ca-s08'], true) && !seed_ladder_row_open($U(), $r)) $bad[] = "$slug ($src)";
}
ok('a new gnome can buy every chapter seed of every area at the first visit (' . count($lint['needs']) . ' named)', !$bad, implode(', ', $bad));
ok('radish (First Week day 1) and mint (day 4, mint tea) are on the start shelf', seed_ladder_row_open($U(), $rowBySlug((int)$hub['id'], 'radish')) && seed_ladder_row_open($U(), $rowBySlug((int)$hub['id'], 'mint')));
$st = []; foreach ($townShops as $s) { $five = array_map($plantId, explode(',', $FIVES[$s['code']])); $st[] = count(array_intersect($five, $tierPlants((int)$s['rid'], 'staple'))); }
ok('every five holds at least 2 staples (grow staple 2; a 3rd opens with r1 after 2 harvests)', min($st) >= 2, json_encode($st));
$chay = $rowBySlug((int)$caShop['id'], 'chayote');
ok('chayote is locked before its errand opens', !seed_ladder_row_open($U(), $chay));
journey_v2_seed();
$gran = (int)q_val("SELECT id FROM quest_chapters WHERE slug = 'maizehollow-c1-the-granary'");
ok('the Maizehollow granary chapter is there', $gran > 0);
db_insert('user_quests', ['user_id' => $uid, 'chapter_id' => $gran, 'stage' => 0, 'started_at' => now(), 'done_at' => now()]);
seed_ladder_reset();
ok('ca-s05 opens (its chapter done): chayote is open and latched as a step', seed_ladder_row_open($U(), $chay) && q_val('SELECT how FROM seed_ladder_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$chay['item_id']]) === 'step');
q('DELETE FROM user_quests WHERE user_id = ?', [$uid]); seed_ladder_reset();
ok('...and stays open', seed_ladder_row_open($U(), $chay));
$asNew();
ok('ca-s08 trigger: the Stepped Seed Temple not found = closed', !seed_ladder_trigger_ok($uid, 'found=the-stepped-seed-temple'));
$tmpl = q_one("SELECT * FROM locations WHERE slug LIKE '%the-stepped-seed-temple'");
if ($tmpl) {
    $eid = (int)q_val('SELECT id FROM encyclopedia_entries WHERE unlock_key = ?', ['landmark:' . $tmpl['slug']]);
    if (!$eid) $eid = db_insert('encyclopedia_entries', ['chapter' => 'test', 'category' => 'test', 'title' => 'Temple (test)', 'body' => '-', 'unlock_key' => 'landmark:' . $tmpl['slug']]);
    db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
    seed_ladder_reset();
    ok('ca-s08 opens when the temple is found: chayote open', seed_ladder_trigger_ok($uid, 'found=the-stepped-seed-temple') && seed_ladder_row_open($U(), $chay));
    q('DELETE FROM user_encyclopedia WHERE user_id = ? AND entry_id = ?', [$uid, $eid]);
}
$asNew();
$ch = db_insert('quest_chapters', ['slug' => 'sl-test-chapter', 'region_id' => $na, 'sort_order' => 99, 'title' => 'Ladder test', 'engine' => 1, 'active' => 1]);
db_insert('quest_tasks', ['chapter_id' => $ch, 'sort_order' => 1, 'kind' => 'plant', 'spec' => 'crop:raspberry/hops:3', 'qty' => 1, 'label' => 'Grow raspberry or hops']);
ok('a chapter not started: raspberry locked', !seed_ladder_row_open($U(), $rowBySlug((int)$naShop['id'], 'raspberry')));
db_insert('user_quests', ['user_id' => $uid, 'chapter_id' => $ch, 'stage' => 0, 'started_at' => now()]);
seed_ladder_reset();
ok('an open chapter step naming crop:raspberry/hops opens both rows', seed_ladder_row_open($U(), $rowBySlug((int)$naShop['id'], 'raspberry')) && seed_ladder_row_open($U(), $rowBySlug((int)$naShop['id'], 'hops')));
q('DELETE FROM quest_tasks WHERE chapter_id = ?', [$ch]); q('DELETE FROM quest_chapters WHERE id = ?', [$ch]);
$asNew();
$showRow = $rowBySlug((int)$hub['id'], $show);
ok("this week's Village Show crop ($show) is always open", $showRow && seed_ladder_row_open($U(), $showRow));

echo "== slice 2 and 5: buying, the bottom drawer, the special order\n";
$asNew(); $pin();
$beet = $rowBySlug((int)$hub['id'], 'beet');
$s0 = $stockOf((int)$beet['id']); $c0 = (int)$U()['coins'];
[$okL, $mL] = buy_from_shop($U(), (int)$beet['id'], 1);
ok('a locked row: the buy is refused with the hint', !$okL && str_starts_with($mL, 'That one is not on your shelf yet. ') && str_contains($mL, 'Kitchen row'), $mL);
ok('...the shelf and the purse are unchanged', $stockOf((int)$beet['id']) === $s0 && (int)$U()['coins'] === $c0);
q("UPDATE users SET role = 'player' WHERE id = ?", [$admin]);
$adminU = q_one('SELECT * FROM users WHERE id = ?', [$admin]);
db_insert('seed_ladder_gates', ['user_id' => $admin, 'shop_id' => (int)$hub['id'], 'gate' => 'm1', 'opened_at' => now()]);
q('UPDATE users SET coins = 100000, location_id = ?, game_day = 10, game_minute = 600 WHERE id = ?', [(int)$town['id'], $admin]);
seed_ladder_reset();
[$okA] = buy_from_shop(q_one('SELECT * FROM users WHERE id = ?', [$admin]), (int)$beet['id'], 1);
ok('a second gnome with the gate open buys it off the same shelf', $okA && $stockOf((int)$beet['id']) === $s0 - 1);
q("UPDATE users SET role = 'admin' WHERE id = ?", [$admin]);
$radish = $rowBySlug((int)$hub['id'], 'radish');
q('UPDATE shop_stock SET current_stock = 0 WHERE id = ?', [(int)$radish['id']]);
$drawerPrice = shop_price($U(), town_backroom_price(town_backroom_row((int)$radish['id'])), (int)$hub['id'], (int)$radish['item_id']);
ok('a bare start row (radish): the bottom drawer holds 10 for this gnome today', seed_ladder_drawer_left($U(), (int)$radish['id']) === 10);
$c0 = (int)$U()['coins']; $h0 = $haveQty((int)$radish['item_id']);
[$okD, $mD, $cD] = buy_from_shop($U(), (int)$radish['id'], 10) + [2 => 0];
ok('10 from the bottom drawer at price_max (then the usual discounts)', $okD && $cD === 10 * $drawerPrice && str_contains($mD, 'bottom drawer') && $haveQty((int)$radish['item_id']) === $h0 + 10, "$mD / $cD vs " . 10 * $drawerPrice);
ok('...the shared shelf is untouched', $stockOf((int)$radish['id']) === 0);
[$okD2, $mD2] = buy_from_shop($U(), (int)$radish['id'], 1);
ok('...the 11th is refused', !$okD2 && seed_ladder_drawer_left($U(), (int)$radish['id']) === 0, $mD2);
q('UPDATE users SET game_day = game_day + 1 WHERE id = ?', [$uid]); seed_ladder_reset();
ok('a new game day: the drawer holds 10 again', seed_ladder_drawer_left($U(), (int)$radish['id']) === 10);
$hopsRow = $rowBySlug((int)$naShop['id'], 'hops');
q('UPDATE shop_stock SET current_stock = 0 WHERE id = ?', [(int)$hopsRow['id']]);
ok('a gated row has no drawer', seed_ladder_drawer_left($U(), (int)$hopsRow['id']) === 0);
$oats = $rowBySlug((int)$naShop['id'], 'oats');
q('UPDATE shop_stock SET current_stock = 0 WHERE id = ?', [(int)$oats['id']]);
ok('a town start row (oats) has the drawer too', seed_ladder_drawer_left($U(), (int)$oats['id']) === 10);
ok('one special order a game day', seed_ladder_order_left($U()) === 1);
$each = shop_price($U(), 2 * town_backroom_price(town_backroom_row((int)$hopsRow['id'])), (int)$naShop['id'], (int)$hopsRow['item_id']);
$c0 = (int)$U()['coins']; $h0 = $haveQty((int)$hopsRow['item_id']);
[$okO, $mO, $cO] = seed_ladder_order($U(), (int)$hopsRow['id']) + [2 => 0];
ok('special order of a locked seed (hops): 3 seeds at 2 x price_max', $okO && $cO === 3 * $each && $haveQty((int)$hopsRow['item_id']) === $h0 + 3 && (int)$U()['coins'] === $c0 - 3 * $each, "$mO / $cO vs " . 3 * $each);
ok('...the shelf is untouched and the row stays locked', $stockOf((int)$hopsRow['id']) === 0 && !seed_ladder_row_open($U(), $hopsRow));
[$okO2, $mO2] = seed_ladder_order($U(), (int)$rowBySlug((int)$naShop['id'], 'raspberry')['id']);
ok('...a second order the same game day is refused (any shop)', !$okO2 && seed_ladder_order_left($U()) === 0, $mO2);
q('UPDATE users SET game_day = game_day + 1 WHERE id = ?', [$uid]); seed_ladder_reset();
[$okO3, $mO3] = seed_ladder_order($U(), (int)$oats['id']);
ok('an open row cannot be special-ordered (buy it)', !$okO3 && seed_ladder_order_left($U()) === 1, $mO3);
[$okO4] = seed_ladder_order($U(), (int)$beet['id']);
ok('the next game day: one more order (beet at Twigg\'s)', $okO4 && seed_ladder_order_left($U()) === 0);

echo "== old gnomes keep everything (decision 6)\n";
setg('seed_ladder_since', '2999-01-01 00:00:00'); $clean();
$kb = $rowBySlug((int)$naShop['id'], 'kidney-bean');
$items0 = q('SELECT item_id, qty FROM user_items WHERE user_id = ? ORDER BY item_id', [$uid])->fetchAll();
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
$tile = (int)q_val('SELECT id FROM plot_tiles WHERE plot_id = ? ORDER BY id LIMIT 1', [$plot]);
$was = q_one('SELECT plant_id FROM plot_tiles WHERE id = ?', [$tile]);
q('UPDATE plot_tiles SET plant_id = ? WHERE id = ?', [$plantId('blue-violet'), $tile]);
$know([$plantId('raspberry')]);
ok('held kidney-bean seed: its row is open', seed_ladder_row_open($U(), $kb));
ok('planted blue-violet and harvested raspberry: open too', seed_ladder_row_open($U(), $rowBySlug((int)$naShop['id'], 'blue-violet')) && seed_ladder_row_open($U(), $rowBySlug((int)$naShop['id'], 'raspberry')));
ok('the snapshot is taken once (one marker row) and latches what was held', (int)q_val("SELECT COUNT(*) FROM seed_ladder_gates WHERE user_id = ? AND gate = 'snap'", [$uid]) === 1 && q_val('SELECT how FROM seed_ladder_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$kb['item_id']]) === 'held');
q('UPDATE plot_tiles SET plant_id = ? WHERE id = ?', [$was['plant_id'] ?? null, $tile]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$kb['item_id']]); seed_ladder_reset();
ok('...it stays open after the seed is planted or given away', seed_ladder_row_open($U(), $kb));
ok('nothing is taken from an old gnome (satchel unchanged but for the seed we dropped)', count(q('SELECT item_id FROM user_items WHERE user_id = ?', [$uid])->fetchAll()) === count($items0) - 1);
ok('an old gnome\'s gates read the live record (24 crops = the whole Emporium)', (function () use ($know, $notAtTwigg, $openRows, $hub) { $know(array_slice($notAtTwigg, 0, 24)); return $openRows((int)$hub['id']) === 36; })());
give_item($uid, (int)$kb['item_id'], 2);

echo "== setting off: full stock again, latches kept\n";
$asNew(); $nLatch = (int)q_val('SELECT COUNT(*) FROM seed_ladder_gates') + (int)q_val('SELECT COUNT(*) FROM seed_ladder_items');
setg('seed_ladder_open', '0'); seed_ladder_reset(); $pin();
ok('off: every row open, Twigg\'s 36, Maple & Furrow 20', $openRows((int)$hub['id']) === 36 && $openRows((int)$naShop['id']) === 20 && seed_ladder_row_open($U(), $rowBySlug((int)$hub['id'], 'beet')));
[$okOff] = buy_from_shop($U(), (int)$rowBySlug((int)$hub['id'], 'beet')['id'], 1);
ok('off: a gated row sells', $okOff);
q('UPDATE shop_stock SET current_stock = 0 WHERE id = ?', [(int)$radish['id']]);
[$okOffD] = buy_from_shop($U(), (int)$radish['id'], 1);
ok('off: no bottom drawer (a bare row fails as today)', !$okOffD && seed_ladder_drawer_left($U(), (int)$radish['id']) === 0);
ok('off: the latch tables are left alone', (int)q_val('SELECT COUNT(*) FROM seed_ladder_gates') + (int)q_val('SELECT COUNT(*) FROM seed_ladder_items') === $nLatch);
setg('seed_ladder_open', '1');

echo "== the shared shelf: hidden rows still restock; prices and selling unchanged\n";
$asNew();
q('UPDATE shop_stock SET current_stock = 0, restock_chance = 100 WHERE id = ?', [(int)$beet['id']]);
q('UPDATE shops SET last_restock = NULL WHERE id = ?', [(int)$hub['id']]);
shop_restock((int)$hub['id']);
ok('a locked row restocks like any row', $stockOf((int)$beet['id']) > 0 && !seed_ladder_row_open($U(), $beet));
q('UPDATE shop_stock SET restock_chance = ? WHERE id = ?', [(int)$beet['restock_chance'], (int)$beet['id']]);
q('UPDATE shops SET last_restock = ? WHERE id = ?', [now(), (int)$hub['id']]);
$pin();
$rowsAll = q('SELECT * FROM shop_stock WHERE shop_id IN (' . implode(',', $seedShopIds) . ') ORDER BY id')->fetchAll();
$prices = function () use ($U, $rowsAll) { $o = []; foreach ($rowsAll as $r) $o[] = shop_price($U(), (int)q_val('SELECT current_price FROM shop_stock WHERE id = ?', [(int)$r['id']]), (int)$r['shop_id'], (int)$r['item_id']); return $o; };
$caps = function () use ($U) { $o = []; foreach (q("SELECT * FROM items WHERE category IN ('produce', 'flower', 'seed') ORDER BY id LIMIT 80")->fetchAll() as $it) $o[] = [sell_price($it, $U()), shop_buy_floor((int)$it['id'], $U())]; return $o; };
setg('seed_ladder_open', '0'); seed_ladder_reset(); $pOff = $prices(); $cOff = $caps();
setg('seed_ladder_open', '1'); seed_ladder_reset(); $pOn = $prices(); $cOn = $caps();
ok('every seed shop price is the same on and off', $pOff === $pOn);
ok('what shops pay and the buy-back floor (shop_buy_floor reads all rows) are the same', $cOff === $cOn);
$seedItem = (int)$radish['item_id']; give_item($uid, $seedItem, 1);
[$okSell, $mSell] = sell_to_shop($U(), $seedItem, 1, (int)$hub['id']);
ok('shops never buy seeds', !$okSell, $mSell);

echo "== other shops are not in the ladder\n";
foreach ([$petal, $hedge] as $sh) {
    $sl = seed_ladder_shelf($U(), (int)$sh['id']);
    ok("{$sh['name']}: every row open, nothing locked", $sl['locked'] === [] && count($sl['open']) === (int)q_val('SELECT COUNT(*) FROM shop_stock WHERE shop_id = ?', [(int)$sh['id']]));
}
$flor = q_one("SELECT s.* FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.kind = 'market' AND s.shop_type = 'florist' LIMIT 1");
if ($flor) ok("a town florist ({$flor['name']}): nothing locked", seed_ladder_shelf($U(), (int)$flor['id'])['locked'] === []);

echo "== slice 6: words\n";
$asNew();
$line = seed_ladder_gate_line($U(), (int)$hub['id'], 'm1');
ok('m1 line: "Kitchen row: ... Twigg: \'Grow five different things, or start mending a stop, and I\'ll put it out.\' (0 of 5)"', str_starts_with($line, 'Kitchen row: ') && str_contains($line, 'Twigg: ‘Grow five different things, or start mending a stop, and I’ll put it out.’ (0 of 5)'), $line);
ok('m2 / m3 / m4 lines', str_contains(seed_ladder_gate_line($U(), (int)$hub['id'], 'm2'), 'Herb shelf.') && str_contains(seed_ladder_gate_line($U(), (int)$hub['id'], 'm3'), 'Field sacks.') && str_contains(seed_ladder_gate_line($U(), (int)$hub['id'], 'm4'), 'The top shelf.'));
ok('r1-r4 lines name the area and town', str_contains(seed_ladder_gate_line($U(), (int)$naShop['id'], 'r1'), 'Harvest two Maplewold staples') && str_contains(seed_ladder_gate_line($U(), (int)$naShop['id'], 'r2'), '(0 of 6)')
    && str_contains(seed_ladder_gate_line($U(), (int)$naShop['id'], 'r3'), 'Flower crates.') && str_contains(seed_ladder_gate_line($U(), (int)$naShop['id'], 'r4'), 'The orchard order.'));
ok('the town sentence at start: Wren\'s five', seed_ladder_town_line($U(), $na) === 'Maple & Furrow has Wren’s five on the counter and empty hooks behind.', seed_ladder_town_line($U(), $na));
$know(array_map($plantId, ['oats', 'lentil']));
ok('...after r1: "has unpacked the staples and a few flowers."', seed_ladder_town_line($U(), $na) === 'Maple & Furrow has unpacked the staples and a few flowers.');
$news = seed_ladder_new_lines($U());
ok('a gate that opens gives a flash line naming the new seeds', (bool)array_filter($news, fn($l) => str_starts_with($l, 'New on your shelf at Maple & Furrow: ') && str_contains($l, 'Kidney Bean')), json_encode($news));
setg('seed_ladder_open', '0');
ok('off: no town sentence', seed_ladder_town_line($U(), $na) === '');
setg('seed_ladder_open', '1');

if ($PORT > 0) {
    echo "== the pages with the setting on\n";
    $asNew(); $pin();
    $s = $get('shop.php?id=' . (int)$hub['id']);
    preg_match_all('/<div class="btile stile[^"]*" data-cat="seed"/', $s, $mm);
    ok('Twigg\'s page: 14 seed tiles (+ the show crop when gated)', count($mm[0]) === count($expHub), (string)count($mm[0]));
    ok('...and "Not on the shelf yet" with the 22 others and their hints', str_contains($s, 'Not on the shelf yet') && str_contains($s, 'Kitchen row') && substr_count($s, 'class="sl-lrow') === 36 - count($expHub), (string)substr_count($s, 'class="sl-lrow'));
    ok('...a locked row has no price and a Special order button', str_contains($s, 'Special order'));
    ok('...Wren\'s Twigg line at the start', str_contains($s, 'Fourteen jars. It was a hundred once. Grow what’s here and Twigg will find the rest.'));
    $n = $get('shop.php?id=' . (int)$naShop['id']);
    preg_match_all('/<div class="btile stile[^"]*" data-cat="seed"/', $n, $mm);
    ok('Maple & Furrow page: 5 seed tiles and the guide', count($mm[0]) === 5 && str_contains($n, 'data-cat="guide"'), (string)count($mm[0]));
    ok('...Wren\'s first-visit line', str_contains($n, 'I asked them to keep five things back for you. They’re what this place needs first.'));
    q('UPDATE shop_stock SET current_stock = 0 WHERE id = ?', [(int)$oats['id']]);
    $n = $get('shop.php?id=' . (int)$naShop['id']);
    ok('sold out start row: "Sold out. More within the half hour. Or from the bottom drawer: ..., 10 left today."', str_contains($n, 'Sold out. More within the half hour.') && str_contains($n, 'Or from the bottom drawer:') && str_contains($n, '10 left today.'));
    ok('locked and sold-out never share words', !preg_match('/class="sl-lrow[^>]*>[^<]*Sold out/', $n) && !str_contains($between($n, 'class="sl-locked', ['</details>']), 'Sold out'));
    $post('shop.php?id=' . (int)$hub['id'], ['csrf' => $csrf($s), 'do' => 'buy', 'qty' => [(int)$beet['id'] => 1]]);
    $s2 = $get('shop.php?id=' . (int)$hub['id']);
    ok('buying a locked row by a forged form: "That one is not on your shelf yet."', str_contains($s2, 'That one is not on your shelf yet.'));
    $h0 = $haveQty((int)$beet['item_id']);
    $post('shop.php?id=' . (int)$hub['id'], ['csrf' => $csrf($s2), 'do' => 'sl_order', 'stock' => (int)$beet['id']]);
    ok('the Special order button gives 3 seeds', $haveQty((int)$beet['item_id']) === $h0 + 3);
    $know(array_slice($notAtTwigg, 0, 5));
    $s3 = $get('shop.php?id=' . (int)$hub['id']);
    ok('a gate opens on the page: "New on your shelf at Twigg\'s Seed Emporium: ..."', str_contains($s3, 'New on your shelf at Twigg') && str_contains($s3, 'Beet'));
    $t = $get('town.php');
    ok('the town page: the shop sentence', str_contains($t, 'Maple &amp; Furrow has Wren’s five on the counter and empty hooks behind.'));
    $pf = $get('shop.php?id=' . (int)$petal['id']);
    ok('Petalpin\'s page: no ladder', !str_contains($pf, 'Not on the shelf yet') && !str_contains($pf, 'sl-'));

    echo "== setting off again: the golden hashes\n";
    setg('seed_ladder_open', '0'); seed_ladder_reset();
    $G1 = $golden();
    foreach ($G1 as $k => $v) ok("off, with gates, latches, orders and drawer rows on file: golden $k", $v === $GOLD[$k], $v);
}
$clean();
done();
