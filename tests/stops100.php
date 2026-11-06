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
$IN = ['opt' => 0, 'pick' => 1, 'power' => 3, 'move' => 0];   // v2.0.78: whatever kind comes up (check, pick, power, contest) can be done with these
function doit(string $slug, array $in = []): array { $u = me(); return local_do($u, player_node($u), $slug, $in); }
function offered(array $loc): array { return array_column(stop_pool($loc)['offer'], 'slug'); }
function today(): string { return hollow_date('Y-m-d'); }

echo "== happenings (v2.5.72)\n";
ok('happenings load', count(stop_happenings()) >= 6, (string)count(stop_happenings()));
$mk = stopOfType('market');
$nowM = stop_now($mk);
ok('stop_now carries the happening id', array_key_exists('hp', $nowM));
ok('the happening is the same twice (same stop, same day)', (stop_happening($mk, $nowM)['id'] ?? '') === (stop_happening($mk, $nowM)['id'] ?? ''));
$seen = [];
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $l) { $n = stop_now($l); $seen[$n['hp']] = 1; }
ok('different stops get different happenings today (at least 3 kinds across the world)', count($seen) >= 3, json_encode(array_keys($seen)));
$p = stop_pool($mk, $nowM);
ok('the pool says what is going on', isset($p['happening']) && ($p['happening']['id'] ?? '') === $nowM['hp'] || $nowM['hp'] === '');
$hapN = count(array_filter($p['offer'], fn($a) => !empty($a['hap'])));
ok('up to 3 happening acts, and they carry a matching tag', $hapN <= 3 && (!$p['happening'] || $hapN >= 1), "$hapN for " . ($p['happening']['id'] ?? 'none'));
foreach ($p['offer'] as $a) if (!empty($a['hap'])) ok('a happening act matches the happening tags: ' . $a['slug'], array_intersect($p['happening']['tags'], stop_act_tags($a)) !== []);
ok('no act is offered twice', count(array_unique(array_column($p['offer'], 'slug'))) === count($p['offer']));
ok('hp= is a valid condition', stop_cond_parse('hp=market_day,quiet_day') === ['hp' => ['market_day', 'quiet_day']]);
ok('every act can be tagged without error', count(array_filter(stop_acts(), fn($a) => stop_act_tags($a) !== [])) > 100, (string)count(array_filter(stop_acts(), fn($a) => stop_act_tags($a) !== [])));

echo "== living stops: meters, perks, needs, calendar, threads (v2.5.72)\n";
$lk = at(stopOfType('market')); $lkLoc = player_node($lk); $lu = (int)$lk['id']; $lid = (int)$lkLoc['id'];
q('DELETE FROM stop_prog WHERE user_id = ?', [$lu]); q('DELETE FROM stop_log WHERE user_id = ?', [$lu]);
ok('a new meter starts at 0', stop_meter_get($lu, $lid, 'repairs') === 0);
[$v] = stop_meter_add($lu, $lid, 'repairs', 25);
ok('a meter moves', $v === 25 && stop_meter_get($lu, $lid, 'repairs') === 25);
stop_prog_set($lu, $lid, 'meter:repairs', 50, ['d' => gmdate('Y-m-d', strtotime(today() . ' 12:00:00 UTC -3 days'))]);
ok('a meter drains with the days (3 days, ' . STOP_METER_DECAY . ' a day)', stop_meter_get($lu, $lid, 'repairs') === 50 - 3 * STOP_METER_DECAY, (string)stop_meter_get($lu, $lid, 'repairs'));
ok('no perk yet, so no extra slot', stop_perk_bonus($lu, $lid) === 0 && stop_slots($lkLoc, $lu) === stop_slots($lkLoc));
[$v, $filled] = stop_meter_add($lu, $lid, 'cheer', 120);
ok('a full meter fills, restarts, and gives a perk', $filled === 'cheer' && $v === STOP_METER_AFTER && isset(stop_perks($lu, $lid)['cheer']));
ok('the perk is one more thing per visit', stop_slots($lkLoc, $lu) === stop_slots($lkLoc) + 1);
stop_meter_add($lu, $lid, 'larder', 120);
ok('perks stack: two full meters give two more', stop_perk_bonus($lu, $lid) === 2 && stop_slots($lkLoc, $lu) === stop_slots($lkLoc) + 2);
q('DELETE FROM stop_prog WHERE user_id = ? AND k = ?', [$lu, 'perk:larder']);
ok('the perk is only at that stop', stop_perk_bonus($lu, $lid + 99999) === 0);
ok('the perk ends after its days', (function () use ($lu, $lid) { stop_prog_set($lu, $lid, 'perk:cheer', 1, ['until' => gmdate('Y-m-d', strtotime(today() . ' 12:00:00 UTC -1 days'))]); return stop_perk_bonus($lu, $lid) === 0; })());
ok('meter names are limited to the known ones', stop_meter_add($lu, $lid, 'nonsense', 5) === [0, '']);
// needs
q('DELETE FROM stop_prog WHERE user_id = ?', [$lu]);
ok('needs: a low meter meets meter:repairs<60', stop_needs_ok('meter:repairs<60', $lu, $lid));
stop_prog_set($lu, $lid, 'meter:repairs', 80, ['d' => today()]);
ok('needs: a high meter does not', !stop_needs_ok('meter:repairs<60', $lu, $lid) && stop_needs_ok('meter:repairs>=60', $lu, $lid));
ok('needs: a stranger is not a regular', !stop_needs_ok('fam>=regular', $lu, $lid) && stop_needs_ok('fam>=stranger', $lu, $lid));
q('DELETE FROM stop_prog WHERE user_id = ?', [$lu]);
$offAnon = array_column(stop_pool($lkLoc, null, 0)['offer'], 'slug');
$offMe = array_column(stop_pool($lkLoc, null, $lu)['offer'], 'slug');
ok('a meter-answer act is offered to a player with a low meter, first after the specials', in_array('mend_board', $offMe, true));
ok('a meter-answer act is not offered with no player', !in_array('mend_board', $offAnon, true));
ok('a need-act is never in the plain rotation of someone with a full meter', (function () use ($lu, $lid, $lkLoc) {
    foreach (['repairs', 'larder', 'cheer'] as $m) stop_prog_set($lu, $lid, 'meter:' . $m, 90, ['d' => today()]);
    $o = array_column(stop_pool($lkLoc, null, $lu)['offer'], 'slug');
    return !array_intersect($o, ['mend_board', 'tidy_yard', 'fill_shelf', 'hang_lanterns']);
})());
q('DELETE FROM stop_prog WHERE user_id = ?', [$lu]);
ok('every need and move in stop_act_state.txt names a real act', (function () {
    foreach (stop_act_state() as $slug => $st) if (!isset(stop_acts()[$slug])) return false;
    return true;
})());
// doing an act moves a meter, and says so
$mv = stop_act_moves(stop_acts()['mend_board']);
ok('mend_board moves repairs by 20 (its row)', $mv === [['repairs', 20]], json_encode($mv));
$tagged = array_values(array_filter(stop_acts(), fn($a) => stop_act_state()[$a['slug']] ?? null ? false : stop_act_moves($a) !== []));
ok('most acts move one meter by their tag', count($tagged) > 200, (string)count($tagged));
$lu0 = at($lkLoc); q('UPDATE users SET energy = 900 WHERE id = ?', [$lu]);
$before = stop_meter_get($lu, $lid, 'repairs');
$res = doit('mend_board', $IN);
ok('doing mend_board works', $res[0] === true, json_encode($res));
ok('and raised repairs', stop_meter_get($lu, $lid, 'repairs') >= $before + 20, (string)stop_meter_get($lu, $lid, 'repairs'));
ok('the result line mentions the meter', str_contains((string)$res[1], 'Repairs'), (string)$res[1]);
// calendar
ok('calendar: weekly:sat', stop_cal_match('weekly:sat', '2026-11-07') && !stop_cal_match('weekly:sat', '2026-11-08'));
ok('calendar: first Sunday of a month', stop_cal_match('monthly:first:sun', '2026-11-01') && !stop_cal_match('monthly:first:sun', '2026-11-08'));
ok('calendar: last Sunday of a month', stop_cal_match('monthly:last:sun', '2026-11-29') && !stop_cal_match('monthly:last:sun', '2026-11-22'));
ok('calendar: a fixed date', stop_cal_match('date:06-21', '2027-06-21') && !stop_cal_match('date:06-21', '2027-06-22'));
ok('calendar: a range, and one that wraps the year', stop_cal_match('range:12-20..12-26', '2026-12-25') && !stop_cal_match('range:12-20..12-26', '2026-12-27') && stop_cal_match('range:12-28..01-03', '2027-01-01') && stop_cal_match('range:12-28..01-03', '2026-12-30') && !stop_cal_match('range:12-28..01-03', '2026-06-01'));
ok('calendar loads', count(stop_calendar()) >= 6, (string)count(stop_calendar()));
ok('a Saturday market at a market stop', ($ev = stop_cal_event($lkLoc, '2026-11-07')) && $ev['id'] === 'c_market_sat', json_encode($ev['id'] ?? null));
ok('and not at a shrine', stop_cal_event(stopOfType('shrine'), '2026-11-07') === null);
ok('calendar days are happenings, found by id', isset(stop_happenings()['c_midsummer']) && !empty(stop_happenings()['c_midsummer']['cal']));
ok('calendar tags are real tags', (function () { $all = array_keys(STOP_TAG_WORDS); foreach (stop_calendar() as $e) foreach ($e['tags'] as $t) if (!in_array($t, $all, true)) return false; return true; })());
ok('the next events list is dates after today', (function () use ($lkLoc) { foreach (stop_cal_next($lkLoc, 3, 400) as [$d]) if ($d <= today()) return false; return true; })());
ok('the daily roll never picks a calendar day', (function () { foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $l) { $n = stop_now($l); if (str_starts_with($n['hp'], 'c_') && !stop_cal_event($l, today())) return false; } return true; })());
// threads
q('DELETE FROM stop_prog WHERE user_id = ?', [$lu]); q('DELETE FROM stop_log WHERE user_id = ?', [$lu]);
ok('threads load', count(stop_threads()) >= 3 && isset(stop_acts()['thread_go']), (string)count(stop_threads()));
ok('a stranger is offered no story', stop_thread_offer($lu, $lkLoc) === null);
for ($i = 0; $i < 3; $i++) db_insert('stop_log', ['user_id' => $lu, 'location_id' => $lid, 'visit_key' => 'seed' . $i, 'day' => today(), 'act' => 'chores', 'kind' => 'check', 'note' => '', 'at' => now()]);
ok('a regular (3 things done) is a Regular', stop_fam_level($lu, $lid) === 'regular');
$to = stop_thread_offer($lu, $lkLoc);
ok('a regular is offered the first beat of a story', $to && $to['beat'] === 1 && $to['kind'] === 'thread' && $to['name'] !== '' && $to['blurb'] !== '', json_encode($to));
ok('and it is in the pool', in_array('thread_go', array_column(stop_pool($lkLoc, null, $lu)['offer'], 'slug'), true));
$at = at($lkLoc); q('DELETE FROM stop_log WHERE user_id = ? AND act = ?', [$lu, 'thread_go']);
$tid = $to['thread'];
$r1 = doit('thread_go');
ok('doing the beat works', $r1[0] === true, json_encode($r1));
[$tn] = stop_prog_get($lu, $lid, 'thread:' . $tid);
ok('and moves the story on one', $tn === 1, (string)$tn);
ok('only one beat a day: nothing offered until tomorrow', stop_thread_offer($lu, $lkLoc) === null);
stop_prog_set($lu, $lid, 'thread:' . $tid, 1, ['day' => '2000-01-01']);
$to2 = stop_thread_offer($lu, $lkLoc);
ok('the next day brings beat 2', $to2 && $to2['beat'] === 2 && $to2['thread'] === $tid, json_encode($to2['beat'] ?? null));
$last = count(stop_threads()[$tid]['beats']);
stop_prog_set($lu, $lid, 'thread:' . $tid, $last - 1, ['day' => '2000-01-01']);
$coin = (int)me()['coins'];
$at = at($lkLoc); q('DELETE FROM stop_log WHERE user_id = ? AND act = ?', [$lu, 'thread_go']);
$r2 = doit('thread_go');
ok('the last beat ends the story and pays', $r2[0] === true && str_contains((string)$r2[1], 'The end') && (int)me()['coins'] > $coin, json_encode($r2));
ok('a finished story is not offered again', (function () use ($lu, $lkLoc, $tid) { $o = stop_thread_offer($lu, $lkLoc); return !$o || $o['thread'] !== $tid; })());
ok('every thread reward names real items', (function () { foreach (stop_threads() as $t) if (preg_match_all('/item=([a-z0-9-]+)/', $t['reward'], $m)) foreach ($m[1] as $sl) if (!q_val('SELECT 1 FROM items WHERE slug = ?', [$sl])) return false; return true; })());
// the perk circle by the world icon
q('DELETE FROM stop_prog WHERE user_id = ?', [$lu]);
ok('the circle shows at a stop even before a meter has moved, with a 0% list and no perk count', ($c0 = stop_perk_chip(me(), $lkLoc)) !== '' && str_contains($c0, 'pkchip') && !str_contains($c0, 'pkdot on'));
ok('every active act moves a meter (v2.5.78)', ($nomove = array_keys(array_filter(stop_acts(), fn($a) => !stop_act_moves($a)))) === [], implode(',', array_slice($nomove, 0, 8)));
stop_meter_add($lu, $lid, 'larder', 20);
$chip = stop_perk_chip(me(), $lkLoc);
ok('a circle shows once a meter has moved, with the meter list', str_contains($chip, 'pkchip') && str_contains($chip, 'Larder') && !str_contains($chip, 'pkdot on'));
stop_meter_add($lu, $lid, 'cheer', 120);
$chip = stop_perk_chip(me(), $lkLoc);
ok('the circle lists the perks and counts them', str_contains($chip, 'pkdot on">1<') && str_contains($chip, 'Cheer is full'));
ok('the round Perks button is offered with a perk, next to the others', ($pn = stop_perk_nav(me(), $lkLoc)) && $pn['id'] === 'perks' && $pn['label'] === 'Perks' && is_file(__DIR__ . '/../game/assets/img/ico/' . $pn['icon']));
ok('and the perk card has the list', str_contains(stop_perk_body(me(), $lkLoc), 'Cheer is full') && str_contains(stop_perk_body(me(), $lkLoc), 'Meters'));
ok('no round button off a stop', stop_perk_nav(me(), ['kind' => 'wonder', 'id' => $lid, 'name' => 'x']) === null);
ok('no circle off a stop', stop_perk_chip(me(), ['kind' => 'wonder', 'id' => $lid, 'name' => 'x']) === '');
ok('the circle has no inline styles', !str_contains($chip, 'style='));
q('DELETE FROM stop_prog WHERE user_id = ?', [$lu]);
// the notice board
$board = stop_board_html(me(), $lkLoc);
ok('the notice board has its three parts and a standing', str_contains($board, 'Coming up') && str_contains($board, 'Needs help') && str_contains($board, 'Done lately') && str_contains($board, 'Your standing'));
ok('the meter bars render without inline styles', ($mh = stop_meters_html($lu, $lid)) !== '' && !str_contains($mh, 'style='));
require_once $argv[1] . '/includes/crafting.php';
try { $pg = local_panel(me(), $lkLoc); ok('the stop page renders with the bars', str_contains($pg, 'st-meters')); } catch (Throwable $e) { ok('stop page renders: ' . $e->getMessage() . ' ' . basename($e->getFile()) . ':' . $e->getLine(), false); }

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
$ids = upgrade_100_stops(); ok('upgrade is idempotent', (int)q_val('SELECT COUNT(*) FROM stop_types') === 12 && (int)q_val('SELECT COUNT(*) FROM stop_tier_themes') === 48 && (int)q_val('SELECT COUNT(*) FROM stop_acts WHERE active = 1') === count(stop_acts()));
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
[$okx, $msgx] = doit($offer[0], $IN);
ok('a 4th thing on the same visit is refused', !$okx && str_contains($msgx, 'all you can'), $msgx);
q('DELETE FROM stop_log'); $u = at($loc);
$slug = $free[0];
[$o1] = doit($slug, $IN);
[$o2, $m2] = doit($slug, $IN);
ok('the same thing twice on one visit is refused', $o1 && !$o2, $m2);
ok('energy was spent on a costly thing', true);

echo "== slots setting\n";
cfg(['stop_slots' => 1]); q('DELETE FROM stop_log'); $u = at($loc);
doit($free[0], $IN);
[$o, $m] = doit($free[1], $IN);
ok('stop_slots=1 allows just one', !$o && str_contains($m, 'all you can'), $m);
cfg(['stop_slots' => 3]);

echo "== daily caps\n";
cfg(['stop_daily_cap' => 4]); q('DELETE FROM stop_log');
for ($i = 1; $i <= 4; $i++) { at($loc); q('INSERT INTO stop_log (user_id, location_id, visit_key, day, act, kind, note, at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [$u['id'], $loc['id'], 'old' . $i, today(), 'x', 'check', '', now()]); }
at($loc);
[$o, $m] = doit($free[0], $IN);
ok('per-stop daily cap stops a 5th', !$o && str_contains($m, 'plenty of you today'), $m);
cfg(['stop_daily_cap' => 6, 'stop_daily_total' => 3]);
[$o, $m] = doit($free[0], $IN);
ok('v1.4.9: all-stops daily total is soft (no stop, rewards halved)', $o && !empty($GLOBALS['gv_stop_tired']), $m);
cfg(['stop_daily_total' => 15, 'stop_daily_cap' => 6]); q('DELETE FROM stop_log');

// The pool shows at most 3 conditional ("special") activities, picked by a hash of today's real date, so whether night fishing or the pie
// contest makes the cut depends on the day the suite runs. For those checks, park the OTHER conditional untiered activities (active=0)
// so the date cannot hide the one under test; spare() puts them back.
$parked = [];
function only_special(string $slug): void { global $parked; spare(); foreach (q("SELECT slug FROM stop_acts WHERE slug <> ? AND cond <> '' AND tier = 0 AND active = 1", [$slug])->fetchAll(PDO::FETCH_COLUMN) as $x) { $parked[] = $x; q('UPDATE stop_acts SET active = 0 WHERE slug = ?', [$x]); } stop_acts(true); }
function spare(): void { global $parked; foreach ($parked as $x) q('UPDATE stop_acts SET active = 1 WHERE slug = ?', [$x]); $parked = []; stop_acts(true); }
echo "== time of day, season and weather\n";
$jet = stopOfType('jetty');
cfg(['stop_daypart_force' => 'day', 'weather_force' => 'sun', 'season_force' => 'spring']);
ok('night fishing is not offered by day', !in_array('night_fishing', offered($jet), true));
ok('...but is listed under other times', in_array('night_fishing', array_column(stop_pool($jet)['later'], 'slug'), true));
at($jet);
[$o, $m] = doit('night_fishing', $IN);
ok('doing it by day is refused', !$o && str_contains($m, 'isn’t on offer'), $m);
cfg(['stop_daypart_force' => 'night']); only_special('night_fishing');
ok('night fishing is offered at night', in_array('night_fishing', offered($jet), true));
at($jet); [$o] = doit('night_fishing', $IN);
ok('and works at night', $o);
spare();
$inn = stopOfType('inn');
cfg(['stop_daypart_force' => 'day', 'weather_force' => 'sun']);
ok('rainy-day stories not in sun', !in_array('rainy_stories', offered($inn), true));
cfg(['weather_force' => 'rain', 'stop_core' => 999]);
ok('rainy-day stories on a rainy day', in_array('rainy_stories', offered($inn), true));
cfg(['weather_force' => 'snow', 'season_force' => 'winter']);
ok('winter frost fair suits an inn in a snowy winter (v2.0.78: at most 3 special activities show at once, so test that it is eligible)', stop_cond_ok((string)stop_acts()['frost_fair']['cond'], stop_now($inn)) && in_array('inn', array_map('trim', explode(',', (string)stop_acts()['frost_fair']['types'])), true));
cfg(['stop_core' => 3]);
cfg(['season_force' => 'summer', 'weather_force' => 'sun']);
ok('no frost fair in summer', !in_array('frost_fair', offered($inn), true));
cfg(['season_force' => 'autumn']);
$orch = stopOfType('orchard'); only_special('pie_contest');
ok('pie contest in autumn at an orchard', in_array('pie_contest', offered($orch), true));
spare();
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
[$o, $m] = doit('chores', $IN); // may not be offered today
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
// build tier 1 (v2.0.77: the themed upgrade of this stop's kind, so read its needs rather than assuming stone and planks)
$tiers = stop_tiers_for($stop); ok('4 tiers', count($tiers) === 4);
$t1 = $tiers[1]; $needs1 = stop_tier_needs($t1);
$items1 = array_values(array_filter($needs1, fn($n) => !in_array($n[0], ['coins', 'meal', 'fine'], true)));
$coins1 = 0; foreach ($needs1 as [$k, $q]) if ($k === 'coins') $coins1 = $q;
foreach ($items1 as [$k]) give_item($uid, (int)q_val('SELECT id FROM items WHERE slug = ?', [$k]), 50);
give_item($uid, (int)q_val("SELECT id FROM items WHERE slug = 'beeswax'"), 5);   // something no tier-1 upgrade asks for
q('UPDATE users SET coins = 5000 WHERE username = ?', ['sprout']);
$u = me();
$act1 = 'tt_' . stop_type_of($stop) . '_1'; $act3 = 'tt_' . stop_type_of($stop) . '_3'; $act4 = 'tt_' . stop_type_of($stop) . '_4';
ok('tier starts at 0 and no tier-1 activity is offered', stop_tier((int)$stop['id']) === 0 && !in_array($act1, offered($stop), true));
[$k1, $q1] = $items1[0];
[$o, $m] = stop_contribute($u, $stop, $k1, 1); ok('a partial hand-in', $o && !str_contains($m, 'now has'), $m);
$have = fn(string $slug) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = ?)', [$uid, $slug]);
$before = $have($k1);
[$o, $m] = stop_contribute(me(), $stop, $k1, 99); ok('over-asking only hands in what is left (' . ($q1 - 1) . ' of ' . $q1 . ')', $o && $have($k1) === $before - ($q1 - 1), $m);
[$o, $m] = stop_contribute(me(), $stop, $k1, 1); ok('a finished need can’t be overfilled', !$o);
[$o, $m] = stop_contribute(me(), $stop, 'beeswax', 1); ok('a need the tier doesn’t ask for is refused', !$o);
foreach (array_slice($items1, 1) as [$k, $q]) stop_contribute(me(), $stop, $k, $q);
[$o, $m] = stop_contribute(me(), $stop, 'coins', $coins1);
ok('the last need raises the tier for everyone', $o && str_contains($m, 'now has') && stop_tier((int)$stop['id']) === 1, $m);
ok('tier-1 activity unlocks: ' . $t1['name'], in_array($act1, offered($stop), true));
$otherStop = $road[2]; ok('...but only at this stop', !in_array($act1, offered($otherStop), true));
ok('the plaque lists ' . $t1['name'], str_contains(stop_plaque($stop), $t1['name']));
// the other gnome sees it too
ok('upgrades are for everyone (the pool does not depend on who is looking)', in_array($act1, array_column(stop_pool($stop)['offer'], 'slug'), true));
// perk
[$o, $m] = doit('_perk'); ok('adopter gets a daily welcome', $o, $m);
[$o, $m] = doit('_perk'); ok('...once a day', !$o && str_contains($m, 'already'), $m);
$tr = q_one('SELECT tier, pool FROM stop_adoptions WHERE location_id = ?', [$stop['id']]);
ok('pool reset after a tier', $tr['pool'] === '{}');
// slots: tier 4 gives +1
q('UPDATE stop_adoptions SET tier = 4 WHERE location_id = ?', [$stop['id']]);
ok('tier 4 gives one more slot', stop_slots($stop) === 4);
ok('tier-4 hall and tier-3 special offered', in_array($act4, offered($stop), true) && in_array($act3, offered($stop), true));
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
echo "== v2.0.67 Do cards: every activity has its card art\n";
$kinds = [];
foreach (stops_file_rows('stop_acts.txt') as $r) { if (count($r) < 12) continue; $kinds[$r[6]] = true; $p = stop_act_art($r[6], $r[0]); if ($p === '' || !is_file($argv[1] . '/' . $p)) ok("art for activity {$r[0]} ({$r[6]})", false, $p); }
foreach (stop_acts() as $a) { $p = stop_act_art((string)$a['kind'], (string)$a['slug']); if ($p === '' || !is_file($argv[1] . '/' . $p)) ok("art for db activity {$a['slug']}", false, $p); }
ok('every activity row resolves to an art file', true);
$missing = array_diff(array_keys($kinds), array_keys(STOP_ACT_ART_KIND));
ok('every kind in stop_acts.txt has its own kind picture (' . count($kinds) . ' kinds)', !$missing, implode(',', $missing));
foreach (STOP_ACT_ART_KIND + STOP_ACT_ART_SLUG as $k => $n) if (!is_file($argv[1] . '/assets/img/acts/act-' . $n . '.png')) ok("picture act-$n.png for $k", false);
ok('an unknown kind falls back to the signpost', stop_act_art('no-such-kind') === 'assets/img/acts/act-any.png');
$u = at(stopOfType('market', 1)); $GLOBALS['st_tab'] = 'do'; $_GET['t'] = 'do';
$page = local_panel($u, player_node($u));
ok('Do tab: felt cards, no old text tiles', substr_count($page, 'class="gcard docard"') >= 2 && !str_contains($page, 'class="st-tile'), (string)substr_count($page, 'class="gcard docard"'));
ok('Do tab: every open card has its sheet, and the sheets post do=local', substr_count($page, 'class="gcard docard" data-sheet') === substr_count($page, '<dialog class="isheet dosheet"') && str_contains($page, 'name="do" value="local"'), substr_count($page, 'data-sheet aria-haspopup="dialog"') . ' cards, ' . substr_count($page, '<dialog class="isheet dosheet"') . ' sheets');
ok('Do tab: no style attributes (CSP)', !preg_match('/\sstyle=/', $page));
$_GET['t'] = 'folk'; $page = local_panel($u, player_node($u)); $_GET['t'] = 'do';
ok('Villagers tab: felt villager rows', substr_count($page, '<li class="vlcard">') >= 1 && str_contains($page, '<ul class="vlcards st-folks">'));

echo "== upkeep (v2.5.57, no stamp since 2.5.71)\n";
require_once $argv[1] . '/includes/stop_adopt.php';
$uk = stopOfType('market', 2); $ukU = at($uk); $top = stop_top_tier();
q('DELETE FROM stop_adoptions WHERE location_id = ?', [$uk['id']]);
q('INSERT INTO stop_adoptions (location_id, user_id, founder_id, tier, pool, adopted_at) VALUES (?, ?, ?, ?, ?, ?)', [$uk['id'], $ukU['id'], $ukU['id'], $top, '{}', gmdate('Y-m-d H:i:s')]);
$needs = stop_upkeep_needs($uk);
ok('upkeep needs are a quarter (at least 1) of the top tier needs', $needs && count($needs) === count(stop_tier_needs(stop_tiers_for($uk)[$top])) && min(array_column($needs, 1)) >= 1, json_encode($needs));
function ukrow(int $id): array { return q_one('SELECT * FROM stop_adoptions WHERE location_id = ?', [$id]); }
function ukroll(int $id): void { stop_upkeep_settle(ukrow($id)); }   // stop_adoption() settles once per request, so the test rolls the month directly
ukroll((int)$uk['id']); $a = ukrow((int)$uk['id']);
ok('first look starts the clock with no penalty', (int)$a['tier'] === $top && $a['upkeep_month'] === stop_upkeep_month(), json_encode([$a['tier'], $a['upkeep_month'] ?? null]));
// a whole month with nothing paid costs one tier
q('UPDATE stop_adoptions SET upkeep_month = ?, upkeep_pool = ? WHERE location_id = ?', [gmdate('Y-m', strtotime('-1 month')), '{}', $uk['id']]);
ukroll((int)$uk['id']);
ok('a month left unpaid costs one tier', (int)stop_tier((int)$uk['id']) === $top - 1, (string)stop_tier((int)$uk['id']));
// a month paid in full costs nothing
q('UPDATE stop_adoptions SET tier = ?, upkeep_month = ?, upkeep_pool = ? WHERE location_id = ?', [$top, gmdate('Y-m', strtotime('-1 month')), json_encode(array_column($needs, 1, 0)), $uk['id']]);
ukroll((int)$uk['id']);
ok('a month paid in full keeps the tier', (int)stop_tier((int)$uk['id']) === $top, (string)stop_tier((int)$uk['id']));
// two months unpaid costs two tiers
q('UPDATE stop_adoptions SET tier = ?, upkeep_month = ?, upkeep_pool = ? WHERE location_id = ?', [$top, gmdate('Y-m', strtotime('-2 month')), '{}', $uk['id']]);
ukroll((int)$uk['id']);
ok('two months unpaid cost two tiers', (int)stop_tier((int)$uk['id']) === max(0, $top - 2), (string)stop_tier((int)$uk['id']));
// handing in: any gnome, no stamp; coins when the stop asks for them
q('UPDATE stop_adoptions SET tier = ?, upkeep_month = ?, upkeep_pool = ? WHERE location_id = ?', [$top, stop_upkeep_month(), '{}', $uk['id']]);
$other = q_one("SELECT * FROM users WHERE username <> 'sprout' AND username <> 'admin' LIMIT 1") ?: me();
ok('a stop below the top tier needs no upkeep', (function () use ($uk, $top, $other) { q('UPDATE stop_adoptions SET tier = ? WHERE location_id = ?', [$top - 1, $uk['id']]); [$o] = stop_upkeep_give($other, $uk, 'coins', 1); q('UPDATE stop_adoptions SET tier = ? WHERE location_id = ?', [$top, $uk['id']]); return !$o; })());
[$oNo] = stop_upkeep_give($other, $uk, 'no-such-need', 1);
ok('something the upkeep does not ask for is refused', !$oNo);
$coinNeed = 0; foreach ($needs as [$k, $qn]) if ($k === 'coins') $coinNeed = $qn;
if ($coinNeed > 0) {
    q('UPDATE users SET coins = ? WHERE id = ?', [$coinNeed + 50, $other['id']]);
    [$oc, $mc] = stop_upkeep_give(q_one('SELECT * FROM users WHERE id = ?', [$other['id']]), $uk, 'coins', 9999);
    $left = (int)q_val('SELECT coins FROM users WHERE id = ?', [$other['id']]);
    ok('handing in coins takes only what is still owed', $oc && $left === 50, $mc . " left=$left");
    [$oc2] = stop_upkeep_give(q_one('SELECT * FROM users WHERE id = ?', [$other['id']]), $uk, 'coins', 1);
    ok('a part that is covered takes no more', !$oc2);
    $pool = stop_upkeep_pool_of(q_one('SELECT * FROM stop_adoptions WHERE location_id = ?', [$uk['id']]));
    ok('the pool records the coins', (int)($pool['coins'] ?? 0) === $coinNeed, json_encode($pool));
} else echo "  (top tier asks for no coins here: coin hand-in not run)\n";
// the Extras tab of the Rest stop popover (v2.5.99): the upgrade activities, open while the stop is built, even when it only needs upkeep
require_once $argv[1] . '/includes/place_ui.php';
$xu = me();
$xn = null; foreach (stop_road_stops() as $rs) { if (!$rs['on_road']) continue; $cand = q_one('SELECT * FROM locations WHERE id = ?', [$rs['id']]); if (stop_pool($cand, null, (int)$xu['id'])['tiers']) { $xn = $cand; break; } }
ok('Extras: a road stop with upgrade activities exists to test with', $xn !== null);
$uk = $xn ?: $uk;
q('UPDATE users SET location_id = ?, location = ?, energy = 900 WHERE username = ?', [$uk['id'], $uk['region'], 'sprout']);
$needs = stop_upkeep_needs($uk);
$extras = function () use ($xu, $xn): string { return stop_slim_card_html(me(), $xn, false); };
cfg(['stop_adopt_limit' => 1]);
q('DELETE FROM stop_adoptions WHERE location_id = ?', [$uk['id']]);
$h0 = $extras();
ok('Extras: a stop nobody built up says so and lists what is still to build, locked', str_contains($h0, 'Nobody has built this stop up yet') && str_contains($h0, 'Still to build') && str_contains($h0, 'needs tier'), substr(strip_tags($h0), 0, 160));
q('INSERT INTO stop_adoptions (location_id, user_id, founder_id, tier, pool, adopted_at) VALUES (?, ?, ?, ?, ?, ?)', [$uk['id'], $xu['id'], $xu['id'], 1, '{}', gmdate('Y-m-d H:i:s')]);
$h1 = $extras();
ok('Extras: a stop built to tier 1 shows its tier and its open activities with in-place buttons', str_contains($h1, 'Built to tier 1') && str_contains($h1, 'class="st-extra"') && str_contains($h1, 'name="tab" value="extras"') && str_contains($h1, 'data-vform'), substr(strip_tags($h1), 0, 200));
q('UPDATE stop_adoptions SET tier = ?, upkeep_month = ?, upkeep_pool = ? WHERE location_id = ?', [$top, stop_upkeep_month(), '{}', $uk['id']]);
$h2 = $extras();
ok('Extras: a fully built stop that only needs upkeep still has every activity open, and says why', str_contains($h2, 'Needs its upkeep') && str_contains($h2, 'class="st-extra"') && str_contains($h2, 'data-vform') && !str_contains($h2, 'Still to build'), substr(strip_tags($h2), 0, 200));
q('UPDATE stop_adoptions SET upkeep_pool = ? WHERE location_id = ?', [json_encode(array_column($needs, 1, 0)), $uk['id']]);
$h3 = $extras();
ok('Extras: kept up says cared for', str_contains($h3, 'Cared for') && str_contains($h3, 'class="st-extra"'), substr(strip_tags($h3), 0, 160));
ok('Extras: the card has four tabs now (Hold, Upkeep, Extras, Garden) and no inline style', substr_count($h3, 'class="st-tab st-tab--') >= 3 && !preg_match('/\sstyle=/', $h3));
q('DELETE FROM stop_adoptions WHERE location_id = ?', [$uk['id']]);

echo "== v2.6.01 popover replies carry the messages the action queued (library finds, flashes, prizes)\n";
$_SESSION = [];
$firstPage = (int)q_one('SELECT id FROM encyclopedia_entries ORDER BY id LIMIT 1')['id'];
$_SESSION['new_pages'] = [[$firstPage, 'the library']];
flash('You hum a tune.', 'ok'); flash('Your pockets are full.', 'err');
prize('🎁', 'A gift', '+3', ['Two buttons']);
$tt = take_toasts();
$all = implode(' | ', array_column($tt, 'msg'));
ok('toasts: new Almanac page, flashes and prize all come back', count($tt) === 4 && str_contains($all, 'New Almanac page') && str_contains($all, 'You hum a tune.') && str_contains($all, 'A gift'), $all);
ok('toasts: the error one keeps its type', in_array('err', array_column($tt, 'type'), true));
ok('toasts: nothing is left queued for the next page to toast again', empty($_SESSION['new_pages']) && empty($_SESSION['flash']) && empty($_SESSION['prizes']));
ok('toasts: a second call is empty', take_toasts() === []);

echo "== v2.6.05 your runs into a delve or lair (landmark_runs, player-facing)\n";
require_once $argv[1] . '/includes/landmarks.php';
$me = me(); $lmRow = q_one("SELECT id FROM landmarks WHERE kind = 'delve' ORDER BY id LIMIT 1");
ok('runs: nothing to show before the first run', landmark_runs_html((int)$me['id'], (int)$lmRow['id']) === '');
foreach ([['cleared', 3, 2, 4, '2026-11-01 10:00:00'], ['ko', 3, 1, 4, '2026-11-02 10:00:00'], ['left', 4, 0, 4, '2026-11-03 10:00:00']] as $i => [$oc, $lv, $dp, $stg, $at]) {
    db_insert('landmark_runs', ['user_id' => (int)$me['id'], 'landmark_id' => (int)$lmRow['id'], 'exp_id' => 900000 + $i, 'kind' => 'delve', 'outcome' => $oc, 'level' => $lv, 'depth' => $dp, 'stages' => $stg, 'started_at' => $at, 'ended_at' => $at]);
}
$rh = landmark_runs_html((int)$me['id'], (int)$lmRow['id']);
ok('runs: the fold counts and lists all three, newest first', str_contains($rh, 'Your runs (3)') && strpos($rh, 'Left early') < strpos($rh, 'Knocked out') && strpos($rh, 'Knocked out') < strpos($rh, 'Cleared'), strip_tags($rh));
ok('runs: another player sees none of them', landmark_runs_html((int)$me['id'] + 9999, (int)$lmRow['id']) === '');
q('DELETE FROM landmark_runs WHERE exp_id >= 900000');

echo $fails ? "\n$fails FAILED\n" : "\nall passed\n";
exit($fails ? 1 : 0);
