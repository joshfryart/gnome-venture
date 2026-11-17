<?php
// NPC Clockwork: weekly doings, determinism, fixed mentors, reach mix, shop cover, Sight appointments and forecast.
// php tests/npc_clockwork.php GAME_DIR   (an installed game; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
$folk = q('SELECT id FROM stop_folk WHERE active = 1 ORDER BY id')->fetchAll(PDO::FETCH_COLUMN);
$towns = q('SELECT id FROM npcs WHERE active = 1 AND traveller IS NULL ORDER BY id')->fetchAll(PDO::FETCH_COLUMN);
echo "== weeks\n";
ok('there are villagers', count($folk) > 20 && count($towns) > 5, count($folk) . '/' . count($towns));
$bad = 0; $threes = 0; $reach = ['home' => 0, 'away' => 0]; $dayHist = array_fill(0, 7, 0); $hourHist = [];
foreach ($folk as $id) {
    $w = npc_cw_week('s' . $id, 100); $w2 = npc_cw_week('s' . $id, 100);
    if ($w != $w2 || count($w) < 2 || count($w) > 3) $bad++;
    if (count($w) === 3) $threes++;
    $away = false;
    foreach ($w as $d) { if ($d['stops'][0]['t'] !== 'home') $away = true; foreach ($d['days'] as $x) $dayHist[$x]++; $hourHist[$d['start']] = ($hourHist[$d['start']] ?? 0) + 1; if ($d['start'] + $d['dwell'] + 2 > 24) $bad++; }
    $reach[$away ? 'away' : 'home']++;
}
ok('every stop villager has 2 or 3 doings, same every time, none past midnight', $bad === 0, "bad=$bad");
ok('about 40% have three', $threes > 0 && $threes < count($folk) * 0.7, "$threes of " . count($folk));
ok('not all go far: a good share never leave their stop', $reach['home'] > count($folk) * 0.3, json_encode($reach));
ok('and some do walk', $reach['away'] > count($folk) * 0.1, json_encode($reach));
ok('doings are scattered over the week', min($dayHist) > 0, json_encode($dayHist));
ok('and over the day', count($hourHist) >= 4, json_encode($hourHist));
echo "== fixed\n";
require_once $argv[1] . '/includes/calling_quests.php';
ensure_calling_mentors();
$ms = 0;
foreach (CALLING_MENTORS as $m) {
    $id = (int)q_val('SELECT id FROM npcs WHERE slug = ?', [$m[1]]);
    if (!$id) continue;
    $ms++; $out = 0;
    for ($d = 0; $d < 7; $d++) for ($h = 0; $h < 24; $h++) if (npc_cw_state('n' . $id, $d, (float)$h, 100)['out']) $out++;
    ok($m[0] . ' never leaves', $out === 0);
}
ok('the six mentors exist', $ms === 6, (string)$ms);
echo "== state\n";
$k = null; foreach ($folk as $id) { foreach (npc_cw_week('s' . $id, 100) as $d) if ($d['stops'][0]['t'] === 'loc' || $d['stops'][0]['t'] === 'sight') { $k = ['s' . $id, $d]; break 2; } }
ok('someone walks', $k !== null);
if ($k) {
    [$key, $d] = $k; $dow = $d['days'][0];
    ok('at home before they set out', !npc_cw_state($key, $dow, $d['start'] - 0.5, 100)['out']);
    $s = npc_cw_state($key, $dow, $d['start'] + 0.5, 100);
    ok('walking in the first hour', $s['moving'] && $s['out'] && $s['p'] > 0.4 && $s['p'] < 0.6, json_encode($s['p'] ?? null));
    $s = npc_cw_state($key, $dow, $d['start'] + 1.5, 100);
    ok('then at the stop', !$s['moving'] && $s['out'] && $s['at']['t'] === $d['stops'][0]['t']);
    $s = npc_cw_state($key, $dow, $d['start'] + 1 + $d['dwell'] + 1.5, 100);
    ok('home again by the end', !$s['out']);
    $GLOBALS['gv_cw_time'] = [$dow, $d['start'] + 1.5, 696];
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)q_val('SELECT location_id FROM stop_folk WHERE id = ?', [(int)substr($key, 1)])]);
    ok('npc_cw_out is true while they walk', npc_cw_out($key));
    ok('the stop no longer lists them as present', !array_filter(stop_folk_of($loc, true), fn($f) => 's' . $f['id'] === $key));
    $GLOBALS['gv_cw_time'] = [$dow, 3.0, 696];
    ok('but at 3 am they are listed', (bool)array_filter(stop_folk_of($loc, true), fn($f) => 's' . $f['id'] === $key) || gclock_npc_away($key));
    unset($GLOBALS['gv_cw_time']);
}
echo "== sights\n";
$idx = npc_cw_sight_index();
ok('villagers with Sight rows get sight doings', count($idx) > 10, (string)count($idx));
$checked = 0; $appoint = 0; $mentorRows = 0;
foreach (trail_sight_folk() as $slug => $rows) foreach ($rows as $r) {
    $c = npc_cw_sight_check($r['who'], $slug);
    if (in_array(trail_sight_split_who($r['who'])[0], npc_cw_fixed_names(), true)) { $mentorRows++; if ($c !== false) ok('mentor ' . $r['who'] . ' is never at a Sight', false); }
    $checked++;
    $k = npc_cw_who_key($r['who']);
    if ($k && npc_cw_profile($k)['mode'] === 'free') {
        $f = npc_cw_forecast($r['who'], $slug);
        if ($f) { $appoint++; if ($f['in'] > 28 || $f['to'] <= $f['from']) ok('forecast sane for ' . $r['who'], false, json_encode($f)); }
    }
}
ok('rows checked', $checked > 100, (string)$checked);
ok('most free villagers have a forecast within a fortnight', $appoint > 20, (string)$appoint);
// next-game-days: at the appointment the forecast says now, after it the next one is a later day
$pick = null;
foreach (trail_sight_folk() as $slug => $rows) foreach ($rows as $r) { $k = npc_cw_who_key($r['who']); if ($k && npc_cw_profile($k)['mode'] === 'free' && ($f = npc_cw_forecast($r['who'], $slug))) { $pick = [$r, $slug, $f, $k]; break 2; } }
if ($pick) {
    [$r, $slug, $f, $k] = $pick;
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 696 + $f['in']];
    $w = npc_cw_forecast($r['who'], $slug);
    ok('during the window the forecast says here now', !empty($w['now']), json_encode($w));
    ok('and the clockwork puts them at the Sight', npc_cw_sight_check($r['who'], $slug) === true);
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['to'] + 0.5, 696 + $f['in']];
    ok('missed it: no longer there', npc_cw_sight_check($r['who'], $slug) === false);
    $n = npc_cw_forecast($r['who'], $slug);
    ok('missed it: the next appointment is on a later game day', $n && $n['in'] >= 1 && empty($n['now']), json_encode($n));
    unset($GLOBALS['gv_cw_time']);
}
echo "== shop cover\n";
foreach (npc_cw_keepers() as $shopId => $ks) {
    $k = $ks[0]; $sh = npc_cw_shift((int)$k['npc_id']); $dd = array_key_first($sh); $hh = $dd === null ? 0 : array_key_first($sh[$dd]);
    $GLOBALS['gv_cw_out'] = ['n' . $k['npc_id'] => true]; $GLOBALS['gv_cw_time'] = [$dd, (float)$hh, 696];
    $c = npc_cw_shop_cover((int)$shopId, $dd, (float)$hh);
    ok('keeper out on shift: a neighbour minds ' . $k['shop_name'], $c !== null && (int)$c['id'] !== (int)$k['npc_id'], 'none found');
    if ($c) { $ov = npc_cw_overlay($c); ok('the neighbour shows as minding it', $ov && str_contains($ov['what'], 'minding'), json_encode($ov)); }
    unset($GLOBALS['gv_cw_out'], $GLOBALS['gv_cw_time']);
    ok('keeper in: no cover', npc_cw_shop_cover((int)$shopId, $dd, (float)$hh) === null);
    break;
}
$cov = 0; $shops = 0;
foreach (npc_cw_keepers() as $shopId => $ks) {
    $shops++;
    for ($d = 0; $d < 7; $d++) for ($h = 6; $h < 22; $h++) {
        $c = npc_cw_shop_cover((int)$shopId, $d, (float)$h);
        if ($c) { $cov++; if (in_array((int)$c['id'], array_map('intval', array_column($ks, 'npc_id')), true) && !empty(npc_cw_shift((int)$c['id'])[$d][$h]) || !empty(npc_cw_state('n' . $c['id'], $d, (float)$h)['out'])) ok('cover is somebody else and in town', false); }
    }
}
ok('shops exist', $shops > 0, (string)$shops);
echo "  info: cover hours found across the week: $cov\n";
echo "== off switch\n";
// 2.7.06: the forecast honours the foreseeable parts of a row's `when` (a dusk row never promises a morning visit)
foreach (trail_sight_folk() as $slug => $rows) foreach ($rows as $r) { $k = npc_cw_who_key($r['who']); if (!$k || npc_cw_profile($k)['mode'] !== 'free') continue;
    $f0 = npc_cw_forecast($r['who'], $slug); if (!$f0) continue;
    ok('forecast with a never-true dp and the plain one: the plain visit is not later than the filtered one', ($fx = npc_cw_forecast($r['who'], $slug, 'dp=nosuchpart')) === null || $fx['in'] > $f0['in'] || ($fx['in'] === $f0['in'] && $fx['from'] >= $f0['from']));
    ok('a visit it returns for dp=dusk,night reaches dusk or night', !($fd = npc_cw_forecast($r['who'], $slug, 'dp=dusk,night')) || (function () use ($fd) { for ($h = (int)floor($fd['from']); $h < (int)ceil($fd['to']); $h++) if (in_array(hollow_daypart($h % 24), ['dusk', 'night'], true)) return true; return false; })());
    break 2; }
require_once $argv[1] . '/includes/moon.php';
ok('2.7.06 moon line: phase name, tide size and tide text', preg_match('/moon.* · (big|small|middling) tides · (low|high) tide now|tide in \d+ h/i', moon_line()) === 1, moon_line());
set_setting('npc_clockwork', '0');
ok('off: nobody is out', !npc_cw_out('s' . $folk[0]) && npc_cw_sight_check('Anyone', 'x') === null);
set_setting('npc_clockwork', '1');
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
