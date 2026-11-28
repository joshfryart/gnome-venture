<?php
// 2.8.100 Town states (claude/proposal-town-states.md, includes/town_states.php): the region repair number R, the state ladder (Run low / Mending /
// Thriving) kept as a best-ever row, a held Seal = Thriving, the per-gnome back room (5 staples at Mending; 10 staples, 2 rarer seeds and one guide
// copy at Thriving), the far-shelf gate column, the words on the town and shop pages, Wren's lines, and: setting off = the pages exactly as before
// (golden hashes recorded from 2.8.99 code), no price changes, selling caps unchanged, shops always open.
// Usage: php tests/town_states.php GAME_DIR [PORT]   (a walk.sh install: player "sprout"; with PORT a server for GAME_DIR answers on it)
$_SERVER['SCRIPT_NAME'] = '/index.php';
$GAME = $argv[1];
$PORT = (int)($argv[2] ?? 0);
require $GAME . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/world.php';
require_once APP_ROOT . '/includes/stops.php';
require_once APP_ROOT . '/includes/stop_marks.php';
require_once APP_ROOT . '/includes/seals.php';
require_once APP_ROOT . '/includes/town.php';
require_once APP_ROOT . '/includes/first_week.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
function done(): void { global $fails; echo $fails ? "$fails FAILED\n" : "ok\n"; exit($fails ? 1 : 0); }

$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$admin = (int)q_val("SELECT id FROM users WHERE username = 'admin'");
ok('player sprout exists', $uid > 0);
$na = (int)q_val("SELECT id FROM regions WHERE code = 'NA'");
$ca = (int)q_val("SELECT id FROM regions WHERE code = 'CA'");
$town = q_one("SELECT * FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$na]);
$home = (int)q_val('SELECT home_village_id FROM users WHERE id = ?', [$uid]);
$vill = array_map('intval', q("SELECT id FROM locations WHERE region_id = ? AND kind = 'village' ORDER BY id", [$na])->fetchAll(PDO::FETCH_COLUMN));
$others = array_values(array_diff($vill, [$home]));
ok('the Maplewold has 10 villages and the home village is one of them', count($vill) === 10 && in_array($home, $vill, true), count($vill) . ' / ' . $home);
$shop = q_one("SELECT * FROM shops WHERE location_id = ? AND shop_type = 'seeds'", [(int)$town['id']]);
$hubShop = q_one("SELECT s.* FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.kind = 'hub' AND s.shop_type = 'seeds'");
$tier = fn(int $itemId) => (string)q_val('SELECT GROUP_CONCAT(DISTINCT pr.tier) FROM plants p JOIN plant_regions pr ON pr.plant_id = p.id WHERE p.seed_item_id = ? AND pr.region_id = ?', [$itemId, $na]);
$rows = q('SELECT st.*, i.category, i.name FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE st.shop_id = ? ORDER BY st.id', [(int)$shop['id']])->fetchAll();
$staples = array_values(array_filter($rows, fn($r) => $r['category'] === 'seed' && $tier((int)$r['item_id']) === 'staple'));
$flowers = array_values(array_filter($rows, fn($r) => $r['category'] === 'seed' && $tier((int)$r['item_id']) === 'flower'));
$guide = current(array_filter($rows, fn($r) => $r['category'] === 'guide')) ?: null;
ok('Maple & Furrow sells staples, flower seeds and the region guide', count($staples) >= 2 && $flowers && $guide, count($staples) . '/' . count($flowers));

// the gnome stands in the town at 10:00 of its own day, rich, with every keeper at the counter
setg('npc_clockwork', '0');
q('UPDATE users SET location_id = ?, location = ?, region_id = ?, game_day = 10, game_minute = 600, coins = 1000000, guest = 0 WHERE id = ?', [(int)$town['id'], 'The Maplewold', $na, $uid]);
q("DELETE FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid]);
$U = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$clean = function () use ($uid, $admin) {
    foreach (['stop_marks', 'region_seals', 'stop_mark_use'] as $t) q("DELETE FROM $t WHERE user_id IN (?, ?)", [$uid, $admin]);
    q("DELETE FROM stop_prog WHERE user_id IN (?, ?) AND k LIKE 'meter:%'", [$uid, $admin]);
    foreach (['town_state_best', 'town_backroom'] as $t) { try { q("DELETE FROM $t WHERE user_id IN (?, ?)", [$uid, $admin]); } catch (Throwable $e) {} }
    if (function_exists('town_states_reset')) town_states_reset();
};
$latch = fn(int $lid, int $who = 0) => db_insert('stop_marks', ['user_id' => $who ?: $uid, 'location_id' => $lid, 'bar' => 'repairs', 'perk_key' => '', 'filled_on' => gclock_my_date(), 'latched_at' => now(), 'kept' => 0]);
$meter = fn(int $lid, int $n, bool $old = false) => stop_prog_set($uid, $lid, 'meter:repairs', $n, $old ? ['d' => gclock_my_date()] : ['d' => gclock_my_date(), 'mk' => 1]);
$fresh = function () use ($uid, $town) { if (function_exists('town_states_reset')) town_states_reset(); mark_latched($uid, (int)$town['id'], true); };
$stockOf = fn(int $sid) => (int)q_val('SELECT current_stock FROM shop_stock WHERE id = ?', [$sid]);
$shelfSum = fn() => (int)q_val('SELECT SUM(current_stock) FROM shop_stock WHERE shop_id = ?', [(int)$shop['id']]);
q('UPDATE shops SET last_restock = ? WHERE id IN (?, ?)', [now(), (int)$shop['id'], (int)$hubShop['id']]);   // no restock during the test
$pin = function () use ($shop) { q('UPDATE shop_stock SET current_stock = (id % 5) + 1, current_price = price_min WHERE shop_id = ?', [(int)$shop['id']]); };

// ---------------------------------------------------------------- HTTP helpers
$ck = tempnam(sys_get_temp_dir(), 'tsck');
$get = function (string $path) use ($PORT, $ck): string {
    $c = curl_init('http://127.0.0.1:' . $PORT . '/' . $path);
    curl_setopt_array($c, [CURLOPT_RETURNTRANSFER => true, CURLOPT_COOKIEJAR => $ck, CURLOPT_COOKIEFILE => $ck, CURLOPT_TIMEOUT => 60]);
    $h = (string)curl_exec($c); curl_close($c); return $h;
};
$post = function (string $path, array $f) use ($PORT, $ck): string {
    $c = curl_init('http://127.0.0.1:' . $PORT . '/' . $path);
    curl_setopt_array($c, [CURLOPT_RETURNTRANSFER => true, CURLOPT_COOKIEJAR => $ck, CURLOPT_COOKIEFILE => $ck, CURLOPT_POST => true, CURLOPT_POSTFIELDS => http_build_query($f), CURLOPT_TIMEOUT => 60]);
    $h = (string)curl_exec($c); curl_close($c); return $h;
};
$norm = fn(string $h) => trim(preg_replace('/\s+/', ' ', preg_replace('/\d+/', '', preg_replace('/name="(csrf|_n)" value="[^"]*"/', '', $h))));
$between = function (string $h, string $a, array $bs): string { $i = strpos($h, $a); if ($i === false) return ''; $j = false; foreach ($bs as $b) { $j = strpos($h, $b, $i); if ($j !== false) break; } return substr($h, $i, ($j === false ? strlen($h) : $j) - $i); };
/** The town square above "Today at a glance": crumbs, place switcher, header (no weather chips), whatever sits under it (no festival / market / birthday banners). */
$townFrag = function (string $h) use ($between, $norm): string {
    $f = $between($h, '<p class="crumbs">', ['<section class="tday"', '<nav class="tabs']);
    $f = preg_replace('~<p class="ph-chips">.*?</p>~s', '', $f);
    $f = preg_replace('~<div class="festival[^"]*">.*?</div></div>~s', '', $f);
    $f = preg_replace('~<p class="bday tnote">.*?</p>~s', '', $f);
    return $norm($f);
};
/** The shop: crumbs and header, then each tile's stock id and how many can be bought (prices drift by the day, so they are tested by function). */
$shopFrag = function (string $h) use ($between, $norm): string {
    preg_match_all('/<div class="btile stile[^"]*" data-cat="[^"]*" data-id="(\d+)" data-price="\d+" data-max="(\d+)"/', $h, $m, PREG_SET_ORDER);
    return $norm($between($h, '<p class="crumbs">', ['<p class="status shopintro">'])) . '|' . implode(',', array_map(fn($x) => $x[1] . 'x' . $x[2], $m))
        . '|' . (str_contains($h, 'The shelves are bare') ? 'bare' : '') . '|' . (int)substr_count($h, 'class="flash');
};
$hereFrag = fn(string $h) => preg_match('~<div class="hubscene[^"]*" data-hub="[^"]*">~', $h, $a) && preg_match('~<image class="pix back" href="[^"]*"~', $h, $b) ? $norm($a[0] . $b[0]) : '';

if ($PORT > 0) {
    echo "== setting off: the pages are exactly as in 2.8.99 (golden hashes)\n";
    $clean(); $pin();
    setg('stop_marks_open', '1');
    setg('town_states_open', '0');
    $lp = $get('login.php');
    preg_match('/name="csrf" value="([^"]*)"/', $lp, $m);
    $post('login.php', ['csrf' => $m[1] ?? '', 'username' => 'sprout', 'password' => 'TestPass123!']);
    $t0 = $get('town.php'); $s0 = $get('shop.php?id=' . (int)$shop['id']); $h0 = $get('here.php');
    ok('logged in: the town square shows', str_contains($t0, 'Town square'), substr(strip_tags($t0), 0, 200));
    $G = ['town' => sha1($townFrag($t0)), 'shop' => sha1($shopFrag($s0)), 'here' => sha1($hereFrag($h0))];
    $GOLD = ['town' => 'b29c2642f2f067d38f7b40422d0133e74f4bc5fd', 'shop' => 'd243ed2ad560c2c0eeb78e0249684905f750ac0e', 'here' => 'c3a2e40362adb8117d9278bfcb010ce06e7a38b9'];   // recorded from the 2.8.99 code
    foreach ($G as $k => $v) ok("golden $k page with town_states_open = 0", $v === $GOLD[$k], "got $v; if the page changed on purpose, record the new hash here");
    if (getenv('TS_GOLD_DUMP')) { echo "--- town\n" . $townFrag($t0) . "\n--- shop\n" . $shopFrag($s0) . "\n--- here\n" . $hereFrag($h0) . "\n"; }
}

$have = is_file(APP_ROOT . '/includes/town_states.php');
ok('includes/town_states.php is there', $have);
if (!$have) done();
require_once APP_ROOT . '/includes/town_states.php';

echo "== the setting\n";
ok('town_states_open defaults to 0 and is in the settings list', array_key_exists('town_states_open', settings_schema()) && (string)settings_schema()['town_states_open']['default'] === '0');
ok('its label starts Hollow-style and says it needs lasting marks', str_contains((string)settings_schema()['town_states_open']['label'], 'Lasting marks'));
setg('stop_marks_open', '1'); setg('town_states_open', '0'); $clean();
ok('off: every town is Thriving (as today)', town_state($uid, $na) === 'fixed' && town_state($uid, $ca) === 'fixed');
setg('stop_marks_open', '0'); setg('town_states_open', '1'); $fresh();
ok('on without lasting marks: still Thriving (needs stop_marks_open)', town_state($uid, $na) === 'fixed' && !town_states_on());
ok('off: no back room', town_backroom_left($U(), (int)$staples[0]['id']) === 0);
setg('stop_marks_open', '1'); $fresh();
ok('both on: town states are on', town_states_on());

echo "== the region repair number (proposal section 1, the Maplewold, N = 10)\n";
$clean();
$p = town_region_parts($uid, $na);
ok('1. a new gnome: F 0, W 1 (home village floor), R 5, Run low', $p['n'] === 10 && $p['f'] === 0 && $p['w'] === 1 && town_region_repair($uid, $na) === 5 && town_state($uid, $na) === 'ruin', json_encode($p));
ok('...shown as "Run low"', town_state_name('ruin') === 'Run low' && town_state_name('work') === 'Mending' && town_state_name('fixed') === 'Thriving');
$latch($home); $meter($others[0], 40); $fresh();
ok('2. week one: home latched, a village at Repairs 40: R 15, Mending', town_region_repair($uid, $na) === 15 && town_state($uid, $na) === 'work', json_encode(town_region_parts($uid, $na)));
foreach ([1, 2, 3] as $i) $latch($others[$i]);
$meter($others[4], 34); $meter($others[5], 99); $meter($others[6], 33); $fresh();
ok('3. near the Seal: 4 latched, 3 under repair (33 does not count): R 55, Thriving', town_region_repair($uid, $na) === 55 && town_state($uid, $na) === 'fixed', json_encode(town_region_parts($uid, $na)));
$tmp = [];
foreach (['Cattailmere', 'Granitegate'] as $nm) $tmp[] = db_insert('locations', ['name' => $nm . ' (test)', 'slug' => 'ts-test-' . strtolower($nm), 'region' => 'The Maplewold', 'kind' => 'village', 'region_id' => $na]);
$fresh();
ok('3b. the Maplewold grows to N = 12: R 45, still Thriving (best kept)', town_region_parts($uid, $na)['n'] === 12 && town_region_repair($uid, $na) === 45 && town_state($uid, $na) === 'fixed');
foreach ($tmp as $id) q('DELETE FROM locations WHERE id = ?', [$id]);
q('DELETE FROM stop_marks WHERE user_id = ?', [$uid]); q("DELETE FROM stop_prog WHERE user_id = ? AND k LIKE 'meter:%'", [$uid]); $fresh();
ok('the state never drops: every bar gone (Admin decay), R 5, still Thriving', town_region_repair($uid, $na) === 5 && town_state($uid, $na) === 'fixed');
ok('...the best row is stored once', (int)q_val('SELECT state FROM town_state_best WHERE user_id = ? AND region_id = ?', [$uid, $na]) === 2 && (int)q_val('SELECT COUNT(*) FROM town_state_best WHERE user_id = ?', [$uid]) === 1);
$clean(); $latch($home); $meter($others[0], 40); $fresh(); town_state($uid, $na);
q("DELETE FROM stop_prog WHERE user_id = ? AND k LIKE 'meter:%'", [$uid]); $fresh();
ok('Mending never drops back to Run low either', town_region_repair($uid, $na) === 10 && town_state($uid, $na) === 'work');
$clean();
ok('a Run low town writes no row', town_state($uid, $na) === 'ruin' && !q_val('SELECT 1 FROM town_state_best WHERE user_id = ?', [$uid]));

echo "== the town's own Repairs bar, the Seal, other gnomes, the hub\n";
$clean(); $meter((int)$town['id'], 33); $fresh();
ok('town Repairs 33: Run low', town_state($uid, $na) === 'ruin');
$meter((int)$town['id'], 34); $fresh();
ok('town Repairs 34: Mending (a floor, not part of R)', town_state($uid, $na) === 'work' && town_region_repair($uid, $na) === 5);
$clean(); $latch((int)$town['id']); $fresh();
ok('town Repairs latched: Mending', town_state($uid, $na) === 'work');
$clean(); db_insert('region_seals', ['user_id' => $uid, 'region_id' => $na, 'earned_at' => now()]); $fresh();
ok('a held Seal: Thriving at once (R 5)', town_region_repair($uid, $na) === 5 && town_state($uid, $na) === 'fixed');
ok('...and the other regions stay as they are (CA: no home there, R 0, Run low)', town_region_repair($uid, $ca) === 0 && town_state($uid, $ca) === 'ruin');
ok('a second gnome has its own state (admin: Run low)', town_state($admin, $na) === 'ruin');
$clean(); foreach ([0, 1] as $i) $meter($others[$i], 50, true); $fresh();
ok('old gnomes are grandfathered: old (pre-marks) meters count like new ones: R 15, Mending', town_region_repair($uid, $na) === 15 && town_state($uid, $na) === 'work', json_encode(town_region_parts($uid, $na)));
ok('the hub (no region) is always Thriving', town_state($uid, 0) === 'fixed' && town_state_at($uid, q_one("SELECT * FROM locations WHERE kind = 'hub'")) === 'fixed');
ok('a village is not a town: no state', town_state_at($uid, q_one('SELECT * FROM locations WHERE id = ?', [$home])) === '');

echo "== words (3 lines per state)\n";
$clean(); $fresh();
$L = town_state_lines($uid, $na);
ok('Run low lines', $L[0] === 'The shelves are thin but the door is open.' && str_contains($L[1], 'Mend a village and one might.') && $L[2] === 'What you see is what there is. Nothing in the back.', json_encode($L));
$latch($home); $meter($others[0], 40); $fresh();
$L = town_state_lines($uid, $na, 5);
ok('Mending lines name F of N and what is left', $L[0] === 'Carts are getting through again.' && $L[1] === '1 of 10 villages mended. The square is waking up.' && str_contains($L[2], '(5 left today)'), json_encode($L));
$clean(); db_insert('region_seals', ['user_id' => $uid, 'region_id' => $na, 'earned_at' => now()]); $fresh();
$L = town_state_lines($uid, $na);
ok('Thriving lines name the region', $L[0] === 'Every stall is up and the lamps are all lit.' && $L[1] === 'The roads of The Maplewold carry goods again. You did that.', json_encode($L));
ok('Wren\'s area count: "Town: Thriving (R 5 of 50)"', str_contains(town_state_count_html($uid, $na), 'Town: Thriving (R 5 of 50)'), town_state_count_html($uid, $na));
ok('the story line', TOWN_STORY_LINE === 'The towns kept one lamp lit and the door open. Then the carts stopped coming.');
$clean(); $fresh();
ok('Wren\'s arrival line at a Run low town', str_contains(town_wren_html($uid, $na), 'They never shut. They just ran out. Mend the villages and the carts come back.') && str_contains(town_wren_html($uid, $na), TOWN_STORY_LINE));
$latch($home); $meter($others[0], 40); $fresh();
ok('...not once the town is Mending', town_wren_html($uid, $na) === '');
setg('town_states_open', '0'); $fresh();
ok('setting off: no chip, no lines, no Wren, no count', town_chip_html($uid, $na) === '' && town_wren_html($uid, $na) === '' && town_state_count_html($uid, $na) === '' && town_shop_line_html($U(), $shop) === '');
setg('town_states_open', '1'); $fresh();

echo "== the moment of change: flash lines from mark_after()\n";
$clean(); $meter($others[0], 99); $fresh();
$locA = q_one('SELECT * FROM locations WHERE id = ?', [$others[0]]);
$act = null;
foreach (stop_acts() as $a) if (mark_act_bars($a, stop_type_of($locA))[0] === 'repairs' && mark_base_points($a) >= 1) { $act = $a; break; }
ok('an act that feeds Repairs', $act !== null);
ok('before: Run low (R 10)', town_state($uid, $na) === 'ruin' && town_region_repair($uid, $na) === 10);
$lines = mark_after($U(), $locA, $act, '', false);
ok('latching a village lifts the town: "A cart got through to The Maplewold Market. The square is mending."', in_array('🛒 A cart got through to ' . $town['name'] . '. The square is mending.', $lines, true), json_encode($lines));
ok('...and the town is Mending', town_state($uid, $na) === 'work');
$lines = mark_after($U(), $locA, $act, '', false);
ok('no line when nothing changes', !preg_grep('/cart got through|thriving again/', $lines), json_encode($lines));

echo "== pictures: a state twin, else the fixed picture\n";
$scn = APP_ROOT . '/assets/img/scenes/';
ok('Thriving is the fixed file', town_state_art('here-town-na.png', 'fixed') === 'here-town-na.png' && town_state_art('stop-market.png', 'fixed') === 'stop-market.png');
$made = [];
foreach (['here-town-na-work.png', 'stop-market-work.png'] as $f) if (!is_file($scn . $f)) { copy($scn . 'here-town-na.png', $scn . $f); $made[] = $f; }
foreach (['here-town-na-ruin.png', 'stop-market-ruin.png'] as $f) if (is_file($scn . $f)) { rename($scn . $f, $scn . $f . '.bak'); $made[] = '!' . $f; }
ok('a twin that is there is used (here-town-na-work.png, stop-market-work.png)', town_state_art('here-town-na.png', 'work') === 'here-town-na-work.png' && town_state_art('stop-market.png', 'work') === 'stop-market-work.png');
ok('a missing twin falls back to the fixed picture without error', town_state_art('here-town-na.png', 'ruin') === 'here-town-na.png' && town_state_art('stop-market.png', 'ruin') === 'stop-market.png');
ok('the picture keys of the proposal: here-town-<code>-ruin / -work, stop-market-ruin / -work', town_state_twin('here-town-na.png', 'ruin') === 'here-town-na-ruin.png' && town_state_twin('stop-market.png', 'work') === 'stop-market-work.png');

echo "== the back room (per gnome, never the shared shelf)\n";
$st1 = $staples[0]; $st2 = $staples[1]; $fl1 = $flowers[0];
$backPrice = fn(array $r) => max(1, (int)round((int)$r['price_max'] * (100 + max(0, (int)$shop['markup_percent'])) / 100));
$zero = fn() => q('UPDATE shop_stock SET current_stock = 0 WHERE shop_id = ?', [(int)$shop['id']]);
q('DELETE FROM user_guides WHERE user_id = ?', [$uid]);
$clean(); $zero(); $fresh();
setg('town_states_open', '0'); $fresh();
[$okOff, $msgOff] = buy_from_shop($U(), (int)$st1['id'], 1);
setg('town_states_open', '1'); $fresh();
[$okR, $msgR] = buy_from_shop($U(), (int)$st1['id'], 1);
ok('Run low: an order above the shelf fails exactly as today', !$okOff && !$okR && $msgR === $msgOff, $msgR . ' / ' . $msgOff);
ok('Run low: nothing in the back', town_backroom_left($U(), (int)$st1['id']) === 0 && town_backroom_left($U(), (int)$fl1['id']) === 0);
$latch($home); $meter($others[0], 40); $fresh();
ok('Mending: 5 staples a row, no rarer seeds, no guide', town_backroom_left($U(), (int)$st1['id']) === 5 && town_backroom_left($U(), (int)$fl1['id']) === 0 && town_backroom_left($U(), (int)$guide['id']) === 0);
$coins = (int)$U()['coins']; $sum = $shelfSum();
$each = shop_price($U(), $backPrice($st1), (int)$shop['id'], (int)$st1['item_id']);
$have0 = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$st1['item_id']]);
[$ok5, $m5, $c5] = buy_from_shop($U(), (int)$st1['id'], 5) + [2 => 0];
ok('Mending: 5 from the back room, at price_max then the usual discounts', $ok5 && $c5 === 5 * $each && (int)$U()['coins'] === $coins - 5 * $each && str_contains($m5, 'back room'), "$m5 / $c5 vs " . 5 * $each);
ok('...the gnome has them', (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$st1['item_id']]) === $have0 + 5);
ok('...the shared shelf is untouched', $shelfSum() === $sum && $stockOf((int)$st1['id']) === 0);
[$ok6, $m6] = buy_from_shop($U(), (int)$st1['id'], 1);
ok('...the 6th is refused', !$ok6 && town_backroom_left($U(), (int)$st1['id']) === 0, $m6);
q('UPDATE shop_stock SET current_stock = 3 WHERE id = ?', [(int)$st2['id']]);
$coins = (int)$U()['coins'];
$cost = 3 * shop_price($U(), (int)$st2['current_price'] ?: 0, (int)$shop['id'], (int)$st2['item_id']);
$curP = (int)q_val('SELECT current_price FROM shop_stock WHERE id = ?', [(int)$st2['id']]);
$cost = 3 * shop_price($U(), $curP, (int)$shop['id'], (int)$st2['item_id']) + 2 * shop_price($U(), $backPrice($st2), (int)$shop['id'], (int)$st2['item_id']);
[$okM, $mM, $cM] = buy_from_shop($U(), (int)$st2['id'], 5) + [2 => 0];
ok('shelf first, then the back room: 3 on the shelf + 2 from the back', $okM && $cM === $cost && $stockOf((int)$st2['id']) === 0 && town_backroom_left($U(), (int)$st2['id']) === 3, "$mM / $cM vs $cost");
q('UPDATE users SET game_day = game_day + 1 WHERE id = ?', [$uid]); $fresh();
ok('a new game day of the gnome: the back room is full again', town_backroom_left($U(), (int)$st1['id']) === 5 && town_backroom_left($U(), (int)$st2['id']) === 5);
db_insert('region_seals', ['user_id' => $uid, 'region_id' => $na, 'earned_at' => now()]); $fresh();
ok('Thriving: 10 staples, 2 of a rarer seed, the guide once', town_backroom_left($U(), (int)$st1['id']) === 10 && town_backroom_left($U(), (int)$fl1['id']) === 2 && town_backroom_left($U(), (int)$guide['id']) === 1);
[$okF] = buy_from_shop($U(), (int)$fl1['id'], 2);
[$okF3] = buy_from_shop($U(), (int)$fl1['id'], 1);
ok('Thriving: 2 rarer seeds, the 3rd refused', $okF && !$okF3);
[$okG, $mG] = buy_from_shop($U(), (int)$guide['id'], 1);
ok('Thriving: one guide copy from under the counter', $okG && town_backroom_left($U(), (int)$guide['id']) === 0, $mG);
q('UPDATE users SET game_day = game_day + 1 WHERE id = ?', [$uid]); $fresh();
ok('the guide copy is once, not once a day', town_backroom_left($U(), (int)$guide['id']) === 0 && town_backroom_left($U(), (int)$st1['id']) === 10);
q('DELETE FROM town_backroom WHERE user_id = ? AND stock_id = ?', [$uid, (int)$guide['id']]);
db_insert('user_guides', ['user_id' => $uid, 'guide_key' => (string)((json_decode((string)q_val('SELECT effects FROM items WHERE id = ?', [(int)$guide['item_id']]), true) ?: [])['guide'] ?? ''), 'read_at' => now()]);
ok('a guide already read: none in the back either', town_backroom_left($U(), (int)$guide['id']) === 0);
ok('a second gnome has its own back room (admin, Run low: none)', town_backroom_left(q_one('SELECT * FROM users WHERE id = ?', [$admin]), (int)$st1['id']) === 0);
ok('the hub shop (Twigg\'s) has no back room', town_backroom_left($U(), (int)q_val('SELECT id FROM shop_stock WHERE shop_id = ? ORDER BY id LIMIT 1', [(int)$hubShop['id']])) === 0);
ok('nothing is ever taken off the shelf list: the same rows are sold', (int)q_val('SELECT COUNT(*) FROM shop_stock WHERE shop_id = ?', [(int)$shop['id']]) === count($rows));
ok('the back-room table counts per gnome, row and game day', (int)q_val('SELECT COUNT(*) FROM town_backroom WHERE user_id = ?', [$uid]) >= 3);

echo "== no price changes, selling caps unchanged\n";
$pin();
$prices = function () use ($U, $shop, $rows) { $o = []; foreach ($rows as $r) $o[] = shop_price($U(), (int)q_val('SELECT current_price FROM shop_stock WHERE id = ?', [(int)$r['id']]), (int)$shop['id'], (int)$r['item_id']); return $o; };
$caps = function () use ($U) { $o = []; foreach (q("SELECT * FROM items WHERE category IN ('produce', 'flower') ORDER BY id LIMIT 40")->fetchAll() as $it) $o[] = [sell_price($it, $U()), shop_buy_floor((int)$it['id'], $U())]; return $o; };
setg('town_states_open', '0'); $fresh(); $pOff = $prices(); $cOff = $caps();
setg('town_states_open', '1');
$clean(); $fresh(); $pR = $prices(); $cR = $caps();
$latch($home); $meter($others[0], 40); $fresh(); $pW = $prices();
db_insert('region_seals', ['user_id' => $uid, 'region_id' => $na, 'earned_at' => now()]); $fresh(); $pF = $prices(); $cF = $caps();
ok('shelf prices are the same off, Run low, Mending and Thriving', $pOff === $pR && $pR === $pW && $pW === $pF);
ok('what a shop pays and the buy-back floor are the same in every state', $cOff === $cR && $cR === $cF);
$flo = q_one("SELECT st.*, i.* , st.id AS sid FROM shop_stock st JOIN items i ON i.id = st.item_id JOIN shops s ON s.id = st.shop_id WHERE s.shop_type = 'florist' AND s.location_id <> (SELECT id FROM locations WHERE kind = 'hub') LIMIT 1");
ok('a florist flower from the back room always costs more than a shop pays for it', $flo && $backPrice($flo) >= sell_price(q_one('SELECT * FROM items WHERE id = ?', [(int)$flo['item_id']]), $U()));

echo "== the far shelf (shop_stock.min_town_state)\n";
ok('the column is there, every shipped row 0', (int)q_val('SELECT COUNT(*) FROM shop_stock WHERE min_town_state <> 0') === 0);
$far = $flowers[1] ?? $flowers[0];
q('UPDATE shop_stock SET min_town_state = 2, current_stock = 4 WHERE id = ?', [(int)$far['id']]);
$floor0 = shop_buy_floor((int)$far['item_id'], $U());
$clean(); $latch($home); $meter($others[0], 40); $fresh();
[$okFar, $mFar] = buy_from_shop($U(), (int)$far['id'], 1);
ok('below Thriving a far-shelf row cannot be bought', !$okFar && $stockOf((int)$far['id']) === 4 && !town_far_ok($uid, $na, 2), $mFar);
ok('...but shop_buy_floor still counts it', shop_buy_floor((int)$far['item_id'], $U()) === $floor0);
db_insert('region_seals', ['user_id' => $uid, 'region_id' => $na, 'earned_at' => now()]); $fresh();
[$okFar2] = buy_from_shop($U(), (int)$far['id'], 1);
ok('at Thriving it can', $okFar2 && $stockOf((int)$far['id']) === 3);
q('UPDATE shop_stock SET min_town_state = 0 WHERE id = ?', [(int)$far['id']]);

echo "== shops are always open; First Week day 4 works in a Run low town\n";
$pin();
foreach (['ruin', 'work', 'fixed'] as $want) {
    $clean();
    if ($want === 'work') { $latch($home); $meter($others[0], 40); }
    if ($want === 'fixed') db_insert('region_seals', ['user_id' => $uid, 'region_id' => $na, 'earned_at' => now()]);
    $fresh();
    $st = shop_state($U(), $shop);
    [$b] = buy_from_shop($U(), (int)$st2['id'], 1);
    ok("$want: the shop is open and sells off the shelf", town_state($uid, $na) === $want && $st['state'] === 'open' && $b, json_encode($st));
}
$clean(); $fresh();
q('DELETE FROM town_uses WHERE user_id = ?', [$uid]);
$did = false;
foreach (town_spots((string)$town['region']) as $sp) {
    if (spot_closed($sp)) continue;
    foreach (town_actions((int)$sp['id']) as $ta) { if ($ta['kind'] === 'link') continue; [$did] = town_act($U(), (int)$ta['id']); if ($did) break 2; }
}
ok('Run low: something done in the town square ticks the First Week day 4 goal', town_state($uid, $na) === 'ruin' && $did && first_week_check_now($uid, 'town'));

if ($PORT > 0) {
    echo "== the pages with the setting on\n";
    $pin(); q('DELETE FROM user_guides WHERE user_id = ?', [$uid]);
    setg('town_states_open', '1');
    $clean(); $fresh();
    $t = $get('town.php'); $s = $get('shop.php?id=' . (int)$shop['id']); $h = $get('here.php');
    ok('Run low town page: chip and lines 1 and 2', str_contains($t, 'tstate-ruin') && str_contains($t, 'Run low') && str_contains($t, 'The shelves are thin but the door is open.') && str_contains($t, 'No cart has come up the road in a long while.'));
    ok('...Wren\'s arrival line and the story line', str_contains($t, 'They never shut. They just ran out.') && str_contains($t, 'Then the carts stopped coming.'));
    ok('Run low shop page: line 3', str_contains($s, 'What you see is what there is. Nothing in the back.'));
    ok('Run low shop page: every shelf row is still listed', $shopFrag($s) === $shopFrag($get('shop.php?id=' . (int)$shop['id'])) && substr_count($s, 'class="btile stile') === (int)q_val('SELECT COUNT(*) FROM shop_stock WHERE shop_id = ? AND current_stock > 0', [(int)$shop['id']]));
    ok('Run low Here picture: the town scene carries the state (twin or filter) and a caption', (bool)preg_match('/class="hubscene[^"]*tstate-ruin/', $h) && str_contains($h, 'class="tstate-cap'));
    $latch($home); $meter($others[0], 40); $fresh();
    q('UPDATE shop_stock SET current_stock = 0 WHERE id = ?', [(int)$st1['id']]);
    $t = $get('town.php'); $s = $get('shop.php?id=' . (int)$shop['id']);
    ok('Mending town page', str_contains($t, 'tstate-work') && str_contains($t, 'Carts are getting through again.') && str_contains($t, '1 of 10 villages mended.') && !str_contains($t, 'They never shut.'));
    ok('Mending shop page: line 3 and the back-room row listed with 5 to buy', str_contains($s, 'The keeper holds a few staples back for you.') && preg_match('/data-id="' . (int)$st1['id'] . '" data-price="\d+" data-max="5"/', $s) === 1);
    preg_match('/name="csrf" value="([^"]*)"/', $s, $m);
    $post('shop.php?id=' . (int)$shop['id'], ['csrf' => $m[1] ?? '', 'do' => 'buy', 'qty' => [(int)$st1['id'] => 2]]);
    ok('the buy form works from the back room', town_backroom_left($U(), (int)$st1['id']) === 3 && $stockOf((int)$st1['id']) === 0);
    db_insert('region_seals', ['user_id' => $uid, 'region_id' => $na, 'earned_at' => now()]); $fresh();
    $t = $get('town.php'); $s = $get('shop.php?id=' . (int)$shop['id']);
    ok('Thriving town page', str_contains($t, 'tstate-fixed') && str_contains($t, 'Every stall is up and the lamps are all lit.') && str_contains($t, 'The roads of The Maplewold carry goods again.'));
    ok('Thriving shop page', str_contains($s, 'The back room is full.'));
    $hb = $get('town.php?hub=1'); $sh = $get('shop.php?id=' . (int)$hubShop['id']);
    ok('Mossbottom: no chip, no lines', !str_contains($hb, 'tstate') && !str_contains($sh, 'tstate'));
    echo "== setting off again: the same pages as with no town data at all\n";
    setg('town_states_open', '0'); $fresh(); $pin();
    $a = [$townFrag($get('town.php')), $shopFrag($get('shop.php?id=' . (int)$shop['id'])), $hereFrag($get('here.php'))];
    $clean(); $fresh();
    $b = [$townFrag($get('town.php')), $shopFrag($get('shop.php?id=' . (int)$shop['id'])), $hereFrag($get('here.php'))];
    ok('off, with latches, a Seal and back-room rows on file: the pages do not change', $a === $b);
    ok('off: the pages still match the golden hashes', sha1($b[0]) === $GOLD['town'] && sha1($b[1]) === $GOLD['shop'] && sha1($b[2]) === $GOLD['here'], sha1($b[0]) . ' ' . sha1($b[1]) . ' ' . sha1($b[2]));
}
foreach ($made as $f) { if ($f[0] === '!') rename($scn . substr($f, 1) . '.bak', $scn . substr($f, 1)); else @unlink($scn . $f); }
$clean();
done();
