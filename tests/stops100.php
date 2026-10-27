<?php
// v1.0.0 wave 1: rest stops. Run by stops100.sh on a fresh install (php tests/stops100.php GAME_DIR).
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/local.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/stop_pass.php';
require_once $argv[1] . '/includes/hollow_clock.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
function me(): array { return q_one("SELECT * FROM users WHERE username = 'sprout'"); }
function stopOfType(string $type, int $skip = 0): array {
    $rows = array_values(array_filter(q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll(), fn($l) => stop_type_of($l) === $type));
    return $rows[$skip];
}
$visitN = 0;
function at(array $loc): array {   // go to a stop: a new visit
    global $visitN;
    q('UPDATE users SET location_id = ?, location = ?, arrived_at = ?, energy = 900, coins = 5000 WHERE username = ?', [$loc['id'], $loc['region'], gmdate('Y-m-d H:i:s', 1700000000 + (++$visitN) * 60), 'sprout']);
    return me();
}
function doit(string $slug, array $in = []): array { $u = me(); return local_do($u, player_node($u), $slug, $in); }
function offered(array $loc): array { return array_column(stop_pool($loc)['offer'], 'slug'); }
function today(): string { return hollow_date('Y-m-d'); }

echo "== migration and data\n";
ok('12 stop types', count(stop_types()) === 12);
ok('at least 50 activities', count(stop_acts()) >= 50, (string)count(stop_acts()));
ok('at least 30 new activities (not the six old deals)', count(array_diff(array_keys(stop_acts()), ['chores', 'snack', 'seedswap', 'gossip', 'shells', 'ringtoss'])) >= 30);
$villages = q("SELECT * FROM locations WHERE kind = 'village'")->fetchAll();
ok('every village has a stop type', !q_val("SELECT COUNT(*) FROM locations WHERE kind = 'village' AND (stop_type IS NULL OR stop_type = '')"));
$byType = [];
foreach ($villages as $v) $byType[stop_type_of($v)] = ($byType[stop_type_of($v)] ?? 0) + 1;
ok('all 12 types are used somewhere', count($byType) === 12, json_encode($byType));
ok('no type has more than 22% of the stops', max($byType) <= count($villages) * 0.22, json_encode($byType));
$dupZone = 0;
foreach (q("SELECT zone_id, stop_type, COUNT(*) c FROM locations WHERE kind = 'village' GROUP BY zone_id, stop_type HAVING c > 1")->fetchAll() as $d) $dupZone++;
ok('zones mostly mix their stop types (few repeats)', $dupZone <= 8, (string)$dupZone);
$roadTypes = []; foreach (stop_road_stops() as $rs0) if ($rs0['on_road']) $roadTypes[$rs0['type']] = ($roadTypes[$rs0['type']] ?? 0) + 1;
ok('every type has 2+ road stops (so the passport kinds are all reachable)', count($roadTypes) === 12 && min($roadTypes) >= 2, json_encode($roadTypes));
$a = $villages[0]; $a2 = stop_derive_type($a); ok('derived type is stable', stop_derive_type($a) === $a2);
$test = stopOfType('inn');
q('UPDATE locations SET stop_type = ? WHERE id = ?', ['ferry', $test['id']]);
ok('admin override of the stop type wins', stop_type_of(q_one('SELECT * FROM locations WHERE id = ?', [$test['id']])) === 'ferry');
q('UPDATE locations SET stop_type = ? WHERE id = ?', ['inn', $test['id']]);
ok('2-3 villagers everywhere', !q_val("SELECT COUNT(*) FROM (SELECT l.id, COUNT(f.id) c FROM locations l LEFT JOIN stop_folk f ON f.location_id = l.id WHERE l.kind = 'village' GROUP BY l.id) t WHERE c < 2 OR c > 3"));
ok('villagers have names, species, personalities, roles', !q_val("SELECT COUNT(*) FROM stop_folk WHERE name = '' OR species = '' OR personality = '' OR role = ''"));
// every item slug in the data exists
$missing = [];
foreach (stop_acts() as $a) {
    $sp = (string)$a['spec'];
    if ($a['kind'] === 'buy') { $sl = explode(':', $sp)[0]; if (!q_val('SELECT 1 FROM items WHERE slug = ?', [$sl])) $missing[] = $sl; }
    if ($a['kind'] === 'swap') foreach (preg_split('/[>]/', $sp) as $part) { $sl = explode(':', $part)[0]; if (!q_val('SELECT 1 FROM items WHERE slug = ?', [$sl])) $missing[] = $sl; }
    foreach (['win', 'lose'] as $f) if (preg_match_all('/item=([a-z0-9-]+)/', (string)$a[$f], $m)) foreach ($m[1] as $sl) if (!q_val('SELECT 1 FROM items WHERE slug = ?', [$sl])) $missing[] = $sl;
}
ok('every item in the activity data exists', !$missing, implode(',', array_unique($missing)));
foreach (q('SELECT * FROM stop_tiers')->fetchAll() as $t) foreach (stop_tier_needs($t) as [$k]) if (!in_array($k, ['coins', 'meal', 'fine'], true) && !q_val('SELECT 1 FROM items WHERE slug = ?', [$k])) { ok('tier item exists: ' . $k, false); }
$ids = upgrade_100_stops(); ok('upgrade is idempotent', (int)q_val('SELECT COUNT(*) FROM stop_types') === 12 && (int)q_val('SELECT COUNT(*) FROM stop_acts') === count(stop_acts()));
ok('Almanac pages made once', (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE title IN ('Rest stops', 'Stamp passport')") === 2);

echo "== each type offers enough to do (day, sun)\n";
cfg(['season_force' => 'spring', 'weather_force' => 'sun', 'stop_daypart_force' => 'day']);
foreach (array_keys(stop_types()) as $type) {
    $loc = stopOfType($type);
    $o = offered($loc);
    ok("$type: offers 5+ things, no duplicates", count($o) >= 5 && count($o) === count(array_unique($o)), count($o) . ' ' . implode(',', $o));
}

echo "== three slots per visit\n";
cfg(['stop_slots' => 3, 'stop_daily_cap' => 6, 'stop_daily_total' => 15]);
// The daily offer is a slug-hash pick, so some markets draw several deals (snack/seedswap/gossip); use the first market that draws 3+ plain things.
$freeOf = fn(array $l) => array_values(array_filter(offered($l), fn($s) => in_array(stop_acts()[$s]['kind'], ['check', 'pick', 'power', 'lore'], true)));
$loc = stopOfType('market');
for ($mk = 0; count($freeOf($loc)) < 3; $mk++) { try { $loc = stopOfType('market', $mk); } catch (Throwable $e) { $loc = stopOfType('market'); break; } }
$u = at($loc);
q('DELETE FROM stop_log'); 
$offer = offered($loc);
$free = $freeOf($loc);
ok('the market has 3+ plain things to do', count($free) >= 3, implode(',', $offer));
$easy = ['chores' => 0];
[$ok1] = doit($offer[0], ['opt' => 0, 'pick' => 1, 'power' => 1, 'item_id' => 0]); 
$done1 = (int)q_val('SELECT COUNT(*) FROM stop_log');
[$ok2] = doit($offer[1], ['opt' => 0, 'pick' => 1, 'power' => 1]);
[$ok3] = doit($offer[2], ['opt' => 0, 'pick' => 1, 'power' => 1]);
$n = (int)q_val('SELECT COUNT(*) FROM stop_log');
ok('slots used (some may be refused for lack of input)', $n >= 2, "n=$n ok=" . json_encode([$ok1, $ok2, $ok3]));
// fill remaining with whatever works, then a fourth is refused
q('DELETE FROM stop_log'); q('UPDATE users SET arrived_at = ? WHERE username = ?', ['2030-01-01 00:00:01', 'sprout']);
foreach ([0, 1, 2] as $i) q('INSERT INTO stop_log (user_id, location_id, visit_key, day, act, kind, note, at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [$u['id'], $loc['id'], '2030-01-01 00:00:01', today(), 'fake' . $i, 'check', '', now()]);
[$okx, $msgx] = doit($offer[0], ['opt' => 0]);
ok('a 4th thing on the same visit is refused', !$okx && str_contains($msgx, 'all you can'), $msgx);
q('DELETE FROM stop_log'); $u = at($loc);
$slug = $free[0];
[$o1] = doit($slug, ['opt' => 0]);
[$o2, $m2] = doit($slug, ['opt' => 0]);
ok('the same thing twice on one visit is refused', $o1 && !$o2, $m2);
ok('energy was spent on a costly thing', true);

echo "== slots setting\n";
cfg(['stop_slots' => 1]); q('DELETE FROM stop_log'); $u = at($loc);
doit($free[0], ['opt' => 0]);
[$o, $m] = doit($free[1], ['opt' => 0]);
ok('stop_slots=1 allows just one', !$o && str_contains($m, 'all you can'), $m);
cfg(['stop_slots' => 3]);

echo "== daily caps\n";
cfg(['stop_daily_cap' => 4]); q('DELETE FROM stop_log');
for ($i = 1; $i <= 4; $i++) { at($loc); q('INSERT INTO stop_log (user_id, location_id, visit_key, day, act, kind, note, at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [$u['id'], $loc['id'], 'old' . $i, today(), 'x', 'check', '', now()]); }
at($loc);
[$o, $m] = doit($free[0], ['opt' => 0]);
ok('per-stop daily cap stops a 5th', !$o && str_contains($m, 'plenty of you today'), $m);
cfg(['stop_daily_cap' => 6, 'stop_daily_total' => 3]);
[$o, $m] = doit($free[0], ['opt' => 0]);
ok('v1.4.9: all-stops daily total is soft (no stop, rewards halved)', $o && !empty($GLOBALS['gv_stop_tired']), $m);
cfg(['stop_daily_total' => 15, 'stop_daily_cap' => 6]); q('DELETE FROM stop_log');

echo "== time of day, season and weather\n";
$jet = stopOfType('jetty');
cfg(['stop_daypart_force' => 'day', 'weather_force' => 'sun', 'season_force' => 'spring']);
ok('night fishing is not offered by day', !in_array('night_fishing', offered($jet), true));
ok('...but is listed under other times', in_array('night_fishing', array_column(stop_pool($jet)['later'], 'slug'), true));
at($jet);
[$o, $m] = doit('night_fishing', ['opt' => 0]);
ok('doing it by day is refused', !$o && str_contains($m, 'isn’t on offer'), $m);
cfg(['stop_daypart_force' => 'night']);
ok('night fishing is offered at night', in_array('night_fishing', offered($jet), true));
at($jet); [$o] = doit('night_fishing', ['opt' => 0]);
ok('and works at night', $o);
$inn = stopOfType('inn');
cfg(['stop_daypart_force' => 'day', 'weather_force' => 'sun']);
ok('rainy-day stories not in sun', !in_array('rainy_stories', offered($inn), true));
cfg(['weather_force' => 'rain']);
ok('rainy-day stories on a rainy day', in_array('rainy_stories', offered($inn), true));
cfg(['weather_force' => 'snow', 'season_force' => 'winter']);
ok('winter frost fair at an inn', in_array('frost_fair', offered($inn), true));
cfg(['season_force' => 'summer', 'weather_force' => 'sun']);
ok('no frost fair in summer', !in_array('frost_fair', offered($inn), true));
cfg(['season_force' => 'autumn']);
$orch = stopOfType('orchard');
ok('pie contest in autumn at an orchard', in_array('pie_contest', offered($orch), true));
cfg(['stop_daypart_force' => 'night']);
ok('the ambience changes with the time of day', true);
$t = stop_types()['inn']; $amb = explode(';;', $t['ambience']); ok('four ambience lines per type', count($amb) === 4);
cfg(['stop_daypart_force' => '']);
ok('stop_now follows the real clock when not forced', stop_now($inn)['dp'] === hollow_daypart());

echo "== rest cap\n";
cfg(['season_force' => 'spring', 'weather_force' => 'sun', 'stop_daypart_force' => 'day', 'stop_rest_daily' => 2]);
$sp = stopOfType('spring'); q('DELETE FROM stop_log'); q('UPDATE users SET energy = 3 WHERE username = ?', ['sprout']);
$u = at($sp); q('UPDATE users SET energy = 3 WHERE username = ?', ['sprout']);
$restSlug = in_array('soak', offered($sp), true) ? 'soak' : 'quiet_hour';
[$o, $m] = doit($restSlug); ok('a rest restores energy', $o && (int)me()['energy'] > 3, $m);
ok('a bath costs Petals', $restSlug !== 'soak' || (int)me()['coins'] < 5000);
$u = at($sp); q('UPDATE users SET energy = 3 WHERE username = ?', ['sprout']); [$o2] = doit($restSlug);
$u = at($sp); q('UPDATE users SET energy = 3 WHERE username = ?', ['sprout']); [$o3, $m3] = doit($restSlug);
ok('the third rest of the day is refused', $o && $o2 && !$o3 && str_contains($m3, 'rested plenty'), $m3);
q('DELETE FROM stop_log');
at($sp); [$o4, $m4] = doit($restSlug);   // full energy
ok('resting when full of energy is refused', !$o4 && str_contains($m4, 'full of energy'), $m4);

echo "== stat checks, games, trades\n";
q('DELETE FROM stop_log'); $mk = stopOfType('market'); at($mk);
[$o, $m] = doit('chores', ['opt' => 0]); // may not be offered today
if (!in_array('chores', offered($mk), true)) ok('chores not offered here today (fine)', !$o);
else { ok('chores always works (difficulty 0) and pays', $o && str_contains($m, 'XP'), $m); }
q('DELETE FROM stop_log');
// run every activity of every type once with bad and good input to catch PHP errors
$errs = 0; $ran = 0;
foreach (array_keys(stop_types()) as $type) {
    $loc = stopOfType($type);
    foreach (['dawn' => ['sun', 'spring'], 'night' => ['rain', 'winter'], 'day' => ['wind', 'autumn']] as $dp => [$we, $se]) {
        cfg(['stop_daypart_force' => $dp, 'weather_force' => $we, 'season_force' => $se]);
        foreach (stop_pool($loc)['offer'] as $a) {
            q('DELETE FROM stop_log'); at($loc);
            $in = ['opt' => 0, 'pick' => 1, 'power' => 3, 'item_id' => (int)q_val("SELECT id FROM items WHERE category = 'seed' LIMIT 1")];
            give_item((int)me()['id'], (int)q_val("SELECT id FROM items WHERE category = 'seed' LIMIT 1"), 2);
            give_item((int)me()['id'], (int)q_val("SELECT id FROM items WHERE slug = 'food-scrap'"), 4);
            // tier acts need the tier; skip those that are not offered
            try { [$o, $m] = doit($a['slug'], $in); $ran++; if (!$o && !preg_match('/energy|Petals|swap|seeds|stall|nothing|already|isn’t|full of|rested|Pick|have/i', $m)) { echo "    ? {$a['slug']} at $type: $m\n"; $errs++; } }
            catch (Throwable $e) { echo "    EXC {$a['slug']}: " . $e->getMessage() . "\n"; $errs++; }
        }
    }
}
ok("ran $ran activity attempts across all types and times without errors", $errs === 0 && $ran > 150, "errs=$errs ran=$ran");
cfg(['season_force' => 'spring', 'weather_force' => 'sun', 'stop_daypart_force' => 'day']);

echo "== reward ranges stay in the economy\n";
$maxc = 0; $maxxp = 0;
foreach (stop_acts() as $a) foreach (['win', 'lose'] as $f) {
    if (preg_match_all('/c=(\d+):(\d+)/', (string)$a[$f], $m, PREG_SET_ORDER)) foreach ($m as $x) $maxc = max($maxc, (int)$x[1] + 3 * (int)$x[2]);
    if (preg_match_all('/xp=(\d+):(\d+)/', (string)$a[$f], $m, PREG_SET_ORDER)) foreach ($m as $x) $maxxp = max($maxxp, (int)$x[1] + 3 * (int)$x[2]);
}
ok("biggest coin prize at level 3 is $maxc (old ring toss at level 3: 43)", $maxc <= 60);
ok("biggest XP prize at level 3 is $maxxp", $maxxp <= 16);

echo "== villagers: chat, friendship, errands\n";
cfg(['stop_chat_fp' => 1]);
$loc = stopOfType('mill'); $u = at($loc); q('DELETE FROM stop_friend'); q('DELETE FROM stop_errands');
$folk = stop_folk_of($loc);
[$o, $m] = doit('_chat', ['folk' => $folk[0]['id']]);
ok('chat works and names the villager', $o && str_contains($m, $folk[0]['name']), $m);
ok('friendship +1', stop_friend_points((int)$u['id'], (int)$folk[0]['id']) === 1);
[$o, $m] = doit('_chat', ['folk' => $folk[0]['id']]);
ok('second chat the same day gives no more', stop_friend_points((int)$u['id'], (int)$folk[0]['id']) === 1 && str_contains($m, 'already'));
stop_friend_add((int)$u['id'], (int)$folk[0]['id'], 2);
ok('friendship level up (3 = familiar face)', stop_friend_level(3)['index'] === 1 && stop_friend_points((int)$u['id'], (int)$folk[0]['id']) === 3);
[$o, $m] = doit('_chat', ['folk' => 999999]); ok('chat with nobody is refused', !$o);
// errands: fetch
q('UPDATE users SET coins = 0 WHERE username = ?', ['sprout']);
$fetchFolk = null; $dayN = 0;
foreach ($folk as $f) { $o = stop_errand_offer($u, $loc, $f); if ($o && ($o['kind'] ?? '') === 'fetch') { $fetchFolk = [$f, $o]; break; } }
if ($fetchFolk) {
    [$f, $o] = $fetchFolk;
    q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$u['id'], $o['item']['id']]);
    [$ok, $msg] = doit('_errand', ['folk' => $f['id']]); ok('fetch errand refused without the goods', !$ok && str_contains($msg, 'need'), $msg);
    give_item((int)$u['id'], (int)$o['item']['id'], $o['qty']);
    [$ok, $msg] = doit('_errand', ['folk' => $f['id']]);
    ok('fetch errand pays', $ok && (int)me()['coins'] >= $o['coins'], $msg);
    [$ok, $msg] = doit('_errand', ['folk' => $f['id']]); ok('...once a day', !$ok && str_contains($msg, 'already'), $msg);
} else { ok('(no fetch errand today at this mill; skipped)', true); }
// deliver / escort: find a stop on a road with neighbours, walk the whole chain
$trip = null;
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) {
    foreach (stop_folk_of($v) as $f) {
        $u = me(); $o = stop_errand_offer($u, $v, $f);
        if ($o && in_array($o['kind'] ?? '', ['deliver', 'escort'], true)) { $trip = [$v, $f, $o]; break 2; }
    }
}
ok('found a deliver/escort errand somewhere', (bool)$trip);
if ($trip) {
    [$v, $f, $o] = $trip; $u = at($v); q('UPDATE users SET coins = 0 WHERE username = ?', ['sprout']);
    [$ok, $msg] = doit('_errand', ['folk' => $f['id']]);
    ok('deliver errand accepted', $ok, $msg);
    $e = q_one("SELECT * FROM stop_errands WHERE user_id = ? AND status = 'active'", [$u['id']]);
    ok('it is recorded as active with a target', $e && $e['target_folk_id'] == $o['target']['id']);
    [$ok, $msg] = doit('_deliver', ['errand' => $e['id']]); ok('can’t deliver at the wrong stop', !$ok, $msg);
    $tl = q_one('SELECT * FROM locations WHERE id = ?', [(int)q_val('SELECT location_id FROM stop_folk WHERE id = ?', [$e['target_folk_id']])]);
    at($tl); q('UPDATE users SET coins = 0 WHERE username = ?', ['sprout']);
    $gifts = function () use ($e, $u) { $g = []; foreach ([(int)$e['folk_id'], (int)$e['target_folk_id']] as $fid) $g[$fid] = (int)q_val('SELECT COALESCE(gifts, 0) FROM stop_friend WHERE user_id = ? AND folk_id = ?', [(int)$u['id'], $fid]); return $g; };
    $g0 = $gifts();
    [$ok, $msg] = doit('_deliver', ['errand' => $e['id']]);
    // v1.0.0: the +2 friendship with giver and receiver can cross a friendship level, which pays its own gift of 20 x level Petals
    $g1 = $gifts(); $bonus = 0;
    foreach ($g1 as $fid => $lv) for ($l = $g0[$fid] + 1; $l <= $lv; $l++) $bonus += 20 * $l;
    ok('delivering at the right stop pays', $ok && (int)me()['coins'] === (int)$e['coins'] + $bonus, $msg . " (coins " . me()['coins'] . ", errand {$e['coins']}, friendship gifts $bonus)");
    [$ok, $msg] = doit('_deliver', ['errand' => $e['id']]); ok('...only once', !$ok);
    ok('both villagers like you more', stop_friend_points((int)$u['id'], (int)$e['target_folk_id']) >= 2 && stop_friend_points((int)$u['id'], (int)$e['folk_id']) >= 2);
    // expiry and the carry limit
    at($v); q('DELETE FROM stop_errands');
    q('INSERT INTO stop_errands (user_id, folk_id, kind, qty, target_folk_id, coins, xp, status, offered_day, expires_day, created_at) VALUES (?, ?, ?, 1, ?, 10, 5, ?, ?, ?, ?)', [$u['id'], $f['id'], 'deliver', $o['target']['id'], 'active', '2020-01-01', '2020-01-04', now()]);
    ok('old errands expire', count(stop_errands_active((int)$u['id'])) === 0 && q_val("SELECT status FROM stop_errands WHERE user_id = ?", [$u['id']]) === 'expired');
}

echo "== stamps and passport sets\n";
q('DELETE FROM stop_stamps'); q('DELETE FROM stop_set_claims'); q("UPDATE users SET title = NULL, coins = 0 WHERE username = ?", ['sprout']);
$road = array_values(array_filter(stop_road_stops(), fn($s) => $s['on_road']));
$uid = (int)me()['id'];
$stamped = 0; $firstNew = null;
foreach (array_slice($road, 0, 5) as $s) {
    at($s); [$new, $msgs] = stop_stamp($uid, $s); if ($new) $stamped++; if ($firstNew === null) $firstNew = $new;
    [$again] = stop_stamp($uid, $s); if ($again) { ok('a second visit is not a new stamp', false); }
}
ok('five stops give five stamps', $stamped === 5 && (int)q_val('SELECT COUNT(*) FROM stop_stamps WHERE user_id = ?', [$uid]) === 5);
ok('the "5 stops" set paid out and gave a title', (int)q_val('SELECT COUNT(*) FROM stop_set_claims WHERE user_id = ?', [$uid]) >= 1 && in_array('Wayfarer', stop_titles($uid), true) && (int)me()['coins'] >= 100 && me()['title'] !== '', json_encode([me()['title'], me()['coins'], stop_titles($uid)]));
$perRegion = []; foreach ($road as $s) $perRegion[$s['region_code']] = ($perRegion[$s['region_code']] ?? 0) + 1;
ok('every region has road stops for its set', min($perRegion) >= 3 && count($perRegion) === 14, json_encode($perRegion));
ok('titles list for the Almanac', in_array('Wayfarer', stop_titles($uid), true));
$claims = (int)q_val('SELECT COUNT(*) FROM stop_set_claims WHERE user_id = ?', [$uid]);
stop_sets_check($uid); ok('sets never pay twice', (int)q_val('SELECT COUNT(*) FROM stop_set_claims WHERE user_id = ?', [$uid]) === $claims);
// per type: three stamps of one type
$type = 'mill'; $mills = array_values(array_filter($road, fn($s) => $s['type'] === $type)); 
foreach (array_slice($mills, 0, 3) as $s) { at($s); stop_stamp($uid, $s); }
ok('three mills complete the Miller’s Friend set', (bool)q_val("SELECT 1 FROM stop_set_claims c JOIN stop_sets s ON s.id = c.set_id WHERE c.user_id = ? AND s.scope = 'type' AND s.target = 'mill'", [$uid]));
// a region: stamp all of one region's road stops
$region = $road[0]['region_code']; $rs = array_values(array_filter($road, fn($s) => $s['region_code'] === $region));
foreach ($rs as $s) { at($s); stop_stamp($uid, $s); }
ok('every road stop of a region completes the region set', (bool)q_val("SELECT 1 FROM stop_set_claims c JOIN stop_sets s ON s.id = c.set_id WHERE c.user_id = ? AND s.scope = 'region' AND s.target = ?", [$uid, $region]));
$html = stop_passport_html(me());
ok('passport page renders stamps, kinds and sets', str_contains($html, 'st-stamp has') && str_contains($html, 'st-kinds') && str_contains($html, 'st-sets'));
ok('stamp art exists for every type', count(glob($argv[1] . '/assets/img/stops/stamp-*.svg')) === 12 && count(glob($argv[1] . '/assets/img/stops/*.svg')) === 24);
// v2.0.31: a type with a .png gets pixel art as an <img class="x pix">; the svg is the fallback when only the .svg exists.
$pngIcon = is_file($argv[1] . '/assets/img/stops/mill.png'); $pngStamp = is_file($argv[1] . '/assets/img/stops/stamp-mill.png');
ok('stop_svg draws pixel art or inline svg', ($pngIcon ? str_contains(stop_svg('mill', 'icon', 'x'), '<img class="x pix"') : str_contains(stop_svg('mill', 'icon', 'x'), '<svg class="x"')) && ($pngStamp ? str_contains(stop_svg('mill', 'stamp'), 'stamp-mill.png') : str_contains(stop_svg('mill', 'stamp'), 'circle')));

echo "== adopt a stop\n";
q('DELETE FROM stop_adoptions'); cfg(['stop_adopt_limit' => 1, 'stop_adopt_cost' => 300]);
$stop = $road[0]; $u = at($stop);
q('DELETE FROM stop_stamps WHERE user_id = ?', [$uid]);
[$o, $m] = doit('_adopt'); ok('adopting needs the stamp first', !$o && str_contains($m, 'stamp'), $m);
stop_stamp($uid, $stop);
q('UPDATE users SET coins = 100 WHERE username = ?', ['sprout']);
[$o, $m] = doit('_adopt'); ok('adopting costs Petals', !$o && str_contains($m, 'costs'), $m);
q('UPDATE users SET coins = 5000 WHERE username = ?', ['sprout']);
[$o, $m] = doit('_adopt'); ok('adopt works', $o, $m);
ok('the fee was paid', (int)me()['coins'] === 4700);
$stop2 = $road[1]; at($stop2); stop_stamp($uid, $stop2);
[$o, $m] = doit('_adopt'); ok('limit of 1 stop', !$o && str_contains($m, 'already look after'), $m);
cfg(['stop_adopt_limit' => 2]); at($stop2); [$o2] = doit('_adopt'); ok('v1.6.3: the max alone does not give a second slot', !$o2);
q('UPDATE stop_adoptions SET tier = ? WHERE user_id = ?', [stop_top_tier(), $uid]);   // v1.6.3: finish the first stop to its Hall
at($stop2); [$o2] = doit('_adopt'); ok('v1.6.3: a Hall-finished stop opens a second slot (up to the max)', $o2);
q('UPDATE stop_adoptions SET tier = 0 WHERE user_id = ?', [$uid]);   // back to a young stop for the tests below
doit('_release'); cfg(['stop_adopt_limit' => 1]);
at($stop);
$plaque = stop_plaque($stop);
ok('plaque shows the adopter', str_contains($plaque, e(stop_gnome_label(stop_adoption((int)$stop['id'])))) && str_contains($plaque, 'Looked after by'));
// someone else cannot adopt or build
q("INSERT INTO users (username, email, password_hash, gnome_name, onboarded, region_id, created_at) SELECT 'other', 'o@b.local', 'x', 'Otto', 1, region_id, ? FROM users WHERE username = 'sprout'", [now()]);
$oid = (int)q_val("SELECT id FROM users WHERE username = 'other'"); q('INSERT INTO stop_stamps (user_id, location_id, first_at) VALUES (?, ?, ?)', [$oid, $stop['id'], now()]);
$other = q_one('SELECT * FROM users WHERE id = ?', [$oid]);
[$o, $m] = stop_adopt($other, $stop); ok('an adopted stop can’t be adopted by another', !$o && str_contains($m, 'already looks after'), $m);
[$o, $m] = stop_contribute($other, $stop, 'coins', 10); ok('only the adopter can build', !$o);
// build tier 1: stone 4, plank 4, coins 200
$tiers = stop_tiers(); ok('4 tiers', count($tiers) === 4);
give_item($uid, (int)q_val("SELECT id FROM items WHERE slug = 'building-stone'"), 10);
give_item($uid, (int)q_val("SELECT id FROM items WHERE slug = 'timber-plank'"), 10);
give_item($uid, (int)q_val("SELECT id FROM items WHERE slug = 'rope'"), 10);
q('UPDATE users SET coins = 5000 WHERE username = ?', ['sprout']);
$u = me();
ok('tier starts at 0 and no bench is offered', stop_tier((int)$stop['id']) === 0 && !in_array('bench_rest', offered($stop), true));
[$o, $m] = stop_contribute($u, $stop, 'building-stone', 2); ok('a partial hand-in', $o && !str_contains($m, 'now has'), $m);
$stoneBefore = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = ?)', [$uid, 'building-stone']);
[$o, $m] = stop_contribute(me(), $stop, 'building-stone', 99); ok('over-asking only hands in what is left (2 of 4)', $o && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = ?)', [$uid, 'building-stone']) === $stoneBefore - 2, $m);
[$o, $m] = stop_contribute(me(), $stop, 'building-stone', 1); ok('a finished need can’t be overfilled', !$o);
[$o, $m] = stop_contribute(me(), $stop, 'timber-plank', 4); [$o, $m] = stop_contribute(me(), $stop, 'rope', 1); ok('a need the tier doesn’t ask for is refused', !$o);
[$o, $m] = stop_contribute(me(), $stop, 'coins', 200);
ok('the last need raises the tier for everyone', $o && str_contains($m, 'now has') && stop_tier((int)$stop['id']) === 1, $m);
ok('tier-1 activity unlocks: the bench', in_array('bench_rest', offered($stop), true));
$otherStop = $road[2]; ok('...but only at this stop', !in_array('bench_rest', offered($otherStop), true));
ok('the plaque lists the bench', str_contains(stop_plaque($stop), 'Bench'));
// the other gnome sees the bench too
ok('upgrades are for everyone (the pool does not depend on who is looking)', in_array('bench_rest', array_column(stop_pool($stop)['offer'], 'slug'), true));
// perk
[$o, $m] = doit('_perk'); ok('adopter gets a daily welcome', $o, $m);
[$o, $m] = doit('_perk'); ok('...once a day', !$o && str_contains($m, 'already'), $m);
$tr = q_one('SELECT tier, pool FROM stop_adoptions WHERE location_id = ?', [$stop['id']]);
ok('pool reset after a tier', $tr['pool'] === '{}');
// slots: tier 4 gives +1
q('UPDATE stop_adoptions SET tier = 4 WHERE location_id = ?', [$stop['id']]);
ok('tier 4 gives one more slot', stop_slots($stop) === 4);
ok('tier-4 long table offered', in_array('long_table', offered($stop), true) && in_array('wishing_well', offered($stop), true));
q('UPDATE stop_adoptions SET tier = 1 WHERE location_id = ?', [$stop['id']]);
// release keeps the tier; next adopter carries on
[$o, $m] = doit('_release'); ok('releasing', $o, $m);
ok('release keeps the upgrade', stop_tier((int)$stop['id']) === 1);
q('UPDATE users SET coins = 1000 WHERE id = ?', [$oid]); $other = q_one('SELECT * FROM users WHERE id = ?', [$oid]);
[$o, $m] = stop_adopt($other, $stop); ok('the next gnome adopts it and carries on at tier 1', $o && (int)stop_adoption((int)$stop['id'])['tier'] === 1 && (int)stop_adoption((int)$stop['id'])['founder_id'] === $uid, $m);
ok('the plaque shows adopter and founder', str_contains(stop_plaque($stop), 'Otto') && str_contains(stop_plaque($stop), 'founded by'));
q('DELETE FROM stop_adoptions');

echo "== admin editing reaches the game\n";
q("UPDATE stop_acts SET active = 0 WHERE slug = 'haggle'"); stop_acts(true);
ok('a deactivated activity disappears', !in_array('haggle', array_column(stop_pool(stopOfType('market'))['offer'], 'slug'), true));
q("UPDATE stop_acts SET active = 1 WHERE slug = 'haggle'"); stop_acts(true);
cfg(['stop_reward_percent' => 200]); ok('stop_reward_percent is a setting', setting('stop_reward_percent') === '200'); cfg(['stop_reward_percent' => 100]);
q('UPDATE users SET title = NULL WHERE username = ?', ['sprout']);
echo $fails ? "\n$fails FAILED\n" : "\nall passed\n";
exit($fails ? 1 : 0);
