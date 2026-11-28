<?php
// Lasting marks (includes/stop_marks.php, setting stop_marks_open): off = the old meters; stop_is_place for the town and havens; the catalogue
// (540 perks); bar points per game day (B, D, W, F, V); latching and no decay; answer acts; family caps; daily charges once a game day; A4 ceiling;
// flags; migration of old meters and grandfathering of the 7-day perks; the UI pieces. Run by stop_marks.sh on a walk.sh install: php tests/stop_marks.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/stops.php';
require_once APP_ROOT . '/includes/player_perks.php';
require_once APP_ROOT . '/includes/local.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
ok('player sprout exists', $uid > 0);
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$GLOBALS['CURRENT_USER'] = $u();   // the gnome's own clock (gclock_my_date) reads the current user
$sleep = function (int $n = 1) use ($uid) { q('UPDATE users SET game_day = game_day + ? WHERE id = ?', [$n, $uid]); };
foreach (['stop_marks', 'stop_mark_use', 'stop_prog', 'stop_log', 'player_perks'] as $t) q("DELETE FROM $t WHERE user_id = ?", [$uid]);
$loc = fn(string $slug) => q_one('SELECT * FROM locations WHERE slug = ?', [$slug]);
$market = $loc('market-na');
$shack = $loc('lm-na-1-haven-the-sugar-shack');
$aurora = $loc('lm-na-4-haven-aurora-camp');
$poppy = $loc('v-na-1-1');
$wonder = q_one("SELECT * FROM locations WHERE kind = 'wonder' LIMIT 1");
$today = fn() => gclock_my_date();
$log = function (array $l, string $act, string $kind) use ($uid, $today) {
    db_insert('stop_log', ['user_id' => $uid, 'location_id' => (int)$l['id'], 'visit_key' => 'v' . random_int(1, 1 << 30), 'day' => $today(), 'act' => $act, 'kind' => $kind, 'note' => '', 'at' => now()]);
};

echo "== stop_marks_open = 0: everything as before\n";
ok('settings default off on a fresh install', setting('stop_marks_open') === '0' && setting('perk_old_retired') === '0' && setting('mark_decay') === '0');
ok('stop_is_place: a village yes; the town, a haven, a wonder no', stop_is_place($poppy) && !stop_is_place($market) && !stop_is_place($shack) && !stop_is_place($wonder));
ok('no perk popover at the town', stop_perk_body($u(), $market) === '' && stop_do($u(), $market, 'mend_board', [])[0] === false);
stop_prog_set($uid, (int)$poppy['id'], 'meter:cheer', 50, ['d' => gmdate('Y-m-d', strtotime($today() . ' 12:00:00 UTC -5 days'))]);
ok('old meter decays 3 a day (50, 5 days ago = 35)', stop_meter_get($uid, (int)$poppy['id'], 'cheer') === 35);
$lines = stop_living_after($u(), $poppy, ['slug' => 'zz_tale', 'name' => 'A tale', 'blurb' => '', 'kind' => 'lore', 'energy' => 0]);
$fest = !empty(stop_happenings()[(string)(stop_now($poppy)['hp'] ?? '')]['cal']);
ok('old meters move by tag (+10, x2 on a festival day) while off', stop_meter_get($uid, (int)$poppy['id'], 'cheer') === ($fest ? 55 : 45), implode(', ', $lines));
ok('mark API is inert while off', !stop_marks_active($uid) && mark_pct($uid, 'sell') === 0 && !mark_flag($uid, 'info') && !mark_daily_use($uid, 'bakers_thirteenth'));
q('DELETE FROM stop_prog WHERE user_id = ?', [$uid]);

echo "== the catalogue\n";
$cat = mark_catalogue();
ok('540 perks load', count($cat) === 540, (string)count($cat));
ok('every perk has a class W/P/D/F, a family and a bar', !array_filter($cat, fn($p) => !in_array($p['class'], ['W', 'P', 'D', 'F'], true) || !isset(MARK_BARS[$p['bar']]) || ($p['family'][0] !== 'F' && $p['family'][0] !== 'A')));
ok('180 stops x 3 bars', count(array_unique(array_map(fn($p) => $p['stop'] . '|' . $p['bar'], $cat))) === 540 && count(array_unique(array_column($cat, 'stop'))) === 180);
$un = array_values(array_unique(array_column(array_filter($cat, fn($p) => $p['loc_id'] === 0), 'stop')));
echo '   unmatched stops (not in this world yet): ' . (implode(', ', $un) ?: 'none') . "\n";
ok('only the two new Maplewold villages can be unmatched', !array_diff($un, ['Cattailmere', 'Granitegate']), implode(', ', $un));
ok('Poppyburrow larder = Second Breakfast', (mark_perk_for((int)$poppy['id'], 'larder')['key'] ?? '') === 'second_breakfast');
ok('stop_act_bars.txt: the four answer acts', mark_act_bars(['slug' => 'mend_board'], 'inn') === ['repairs', ''] && mark_act_bars(['slug' => 'hang_lanterns'], 'mill') === ['cheer', '']);
$w = [];
foreach ($cat as $p) if ($p['class'] === 'W') $w[$p['family']] = ($w[$p['family']] ?? 0) + abs($p['size']);
ok('no family\'s world perks pass its cap (the budget)', !array_filter(array_keys($w), fn($f) => $w[$f] > MARK_FAMILIES[$f][2]), json_encode($w));

echo "== stop_marks_open = 1: the town and havens are stops\n";
setg('stop_marks_open', '1');
ok('stop_is_place: town, both Maplewold havens; a wonder still no', stop_is_place($market) && stop_is_place($shack) && stop_is_place($aurora) && !stop_is_place($wonder));
ok('their stop types (master 7.5): market, orchard, camp', stop_type_of($market) === 'market' && stop_type_of($shack) === 'orchard' && stop_type_of($aurora) === 'camp');
ok('another region\'s town takes its catalogue type', stop_is_place($loc('market-ca')) && stop_type_of($loc('market-ca')) === 'market');
ok('the town has a perk popover and acts', stop_perk_body($u(), $market) !== '' && count(stop_pool($market, null, $uid)['offer']) > 0);

echo "== migration: old meters freeze, nothing latches for free\n";
stop_prog_set($uid, (int)$poppy['id'], 'meter:repairs', 50, ['d' => gmdate('Y-m-d', strtotime($today() . ' 12:00:00 UTC -5 days'))]);
ok('first read: the old decay one last time (35)', stop_meter_get($uid, (int)$poppy['id'], 'repairs') === 35);
$sleep(30);
ok('then frozen: 35 after 30 sleeps', stop_meter_get($uid, (int)$poppy['id'], 'repairs') === 35);
stop_prog_set($uid, (int)$poppy['id'], 'meter:cheer', 99, ['d' => $today()]);
ok('a stored 99 is not a mark', stop_meter_get($uid, (int)$poppy['id'], 'cheer') === 99 && !q_val('SELECT COUNT(*) FROM stop_marks WHERE user_id = ?', [$uid]));
q('DELETE FROM stop_prog WHERE user_id = ?', [$uid]);

echo "== points per game day (an inn: an untagged act feeds its lean, larder)\n";
$poppy = q_one("SELECT * FROM locations WHERE kind = 'village' AND stop_type = 'inn' ORDER BY id LIMIT 1");   // the world's types are its own (stop_assign_all), not the catalogue's
$innPerk = mark_perk_for((int)$poppy['id'], 'larder');
$a = fn(string $slug, string $kind, int $en = 1) => ['slug' => $slug, 'name' => 'Zz', 'blurb' => '', 'kind' => $kind, 'energy' => $en];
$lid = (int)$poppy['id'];
$bar = fn(string $b) => stop_meter_get($uid, $lid, $b);
ok('an inn village with a catalogue larder perk: ' . $poppy['name'], stop_type_of($poppy) === 'inn' && $innPerk !== null);
$log($poppy, 'zz_a1', 'check'); mark_after($u(), $poppy, $a('zz_a1', 'check'), '', false);
ok('1st act of the bar today: B 9 + variety 2 = 11', $bar('larder') === 11, (string)$bar('larder'));
$log($poppy, 'zz_a2', 'check'); mark_after($u(), $poppy, $a('zz_a2', 'check'), '', false);
ok('2nd act of the same bar, same kind: 9 x 0.5 = 4 (15)', $bar('larder') === 15, (string)$bar('larder'));
$log($poppy, 'zz_a3', 'check'); mark_after($u(), $poppy, $a('zz_a3', 'check'), '', false);
ok('3rd: 1 point (16)', $bar('larder') === 16, (string)$bar('larder'));
$log($poppy, 'zz_a4', 'pick'); mark_after($u(), $poppy, $a('zz_a4', 'pick'), 'miss', false);
ok('4th, lost, a new kind: 1 + variety 2 (19)', $bar('larder') === 19, (string)$bar('larder'));
$sleep();
$log($poppy, 'zz_a1', 'check'); mark_after($u(), $poppy, $a('zz_a1', 'check'), 'stat miss', false);
ok('after a sleep D restarts: lost 1st act = floor(9 x 0.5) + 2 = 6 (25)', $bar('larder') === 25, (string)$bar('larder'));
$log($poppy, 'mend_board', 'check'); mark_after($u(), $poppy, stop_acts()['mend_board'], '', false);
ok('answer act x1.5: mend_board (2 energy) 12 x 1.5 = 18, no variety (check done today)', $bar('repairs') === 18, (string)$bar('repairs'));
$log($poppy, 'zz_f1', 'lore'); mark_after($u(), $poppy, $a('zz_f1', 'lore', 0), '', true);
ok('festival x2 on a 0-energy act of a fed bar: floor(6 x 0.5 x 2) + 2 = 8 (33)', $bar('larder') === 33, (string)$bar('larder'));
$sleep();
$lines = (function () use ($log, $poppy, $u) { $log($poppy, 'hang_lanterns', 'check'); return mark_after($u(), $poppy, stop_acts()['hang_lanterns'], '', false); })();
ok('cheer 18 + 2 variety = 20', $bar('cheer') === 20, implode(', ', $lines));
$log($poppy, 'fill_shelf', 'tend'); mark_after($u(), $poppy, ['kind' => 'tend'] + stop_acts()['fill_shelf'], '', false);
$log($poppy, 'tidy_yard', 'craft'); $lines = mark_after($u(), $poppy, ['kind' => 'craft'] + stop_acts()['tidy_yard'], '', false);
ok('first full round of the day: R 18+20, L 33+20, and +5 to the lowest unfilled bar (cheer 20 -> 25)', $bar('repairs') === 38 && $bar('larder') === 53 && $bar('cheer') === 25, "R {$bar('repairs')} L {$bar('larder')} C {$bar('cheer')}");
$sleep();
$log($poppy, 'tidy_yard', 'craft'); mark_after($u(), $poppy, ['kind' => 'craft'] + stop_acts()['tidy_yard'], '', false);
$log($poppy, 'mend_board', 'check'); mark_after($u(), $poppy, stop_acts()['mend_board'], '', false);
ok('a day that feeds only one bar: no round bonus (cheer stays 25, repairs 38 + 20 + floor(12 x 0.5 x 1.5) + 2 = 69)', $bar('cheer') === 25 && $bar('repairs') === 69, "R {$bar('repairs')} C {$bar('cheer')}");

echo "== latching: a full bar stays full, its perk for good\n";
stop_prog_set($uid, $lid, 'meter:larder', 96, ['d' => $today(), 'mk' => 1]);
$log($poppy, 'zz_l1', 'check'); $lines = mark_after($u(), $poppy, $a('zz_l1', 'check'), '', false);
$row = q_one('SELECT * FROM stop_marks WHERE user_id = ? AND location_id = ? AND bar = ?', [$uid, $lid, 'larder']);
ok('96 + 11 latches at 100 with the stop\'s perk', $row && $row['perk_key'] === $innPerk['key'] && $bar('larder') === 100, implode(' / ', $lines));
ok('the line names the perk', (bool)array_filter($lines, fn($l) => str_contains($l, $innPerk['name']) && str_contains($l, 'for good')));
ok('filled_on is the gnome\'s game date', $row && $row['filled_on'] === $today());
$rep = $bar('repairs');
$sleep(30);
ok('30 sleeps later: still 100, and the unfilled bar has not moved (mark_decay 0)', $bar('larder') === 100 && $bar('repairs') === $rep, $rep . ' -> ' . $bar('repairs'));
$log($poppy, 'zz_l2', 'check'); mark_after($u(), $poppy, $a('zz_l2', 'check'), '', false);
ok('an act at a full bar: kept up +1, still 100', (int)q_val('SELECT kept FROM stop_marks WHERE user_id = ? AND location_id = ? AND bar = ?', [$uid, $lid, 'larder']) === 1 && $bar('larder') === 100);
stop_prog_set($uid, $lid, 'meter:repairs', 40, ['d' => $today(), 'mk' => 1]);
setg('mark_decay', '1');
$sleep(5);
ok('mark_decay 1: an unfilled bar loses 1 a game day, a full one never', $bar('repairs') === 35 && $bar('larder') === 100, (string)$bar('repairs'));
setg('mark_decay', '0');
ok('answer act for a full bar is not offered, one for an unfilled bar is (even over 60)', !stop_needs_ok('meter:larder<60', $uid, $lid) && (stop_prog_set($uid, $lid, 'meter:cheer', 70, ['d' => $today(), 'mk' => 1]) || true) && stop_needs_ok('meter:cheer<60', $uid, $lid));
ok('notice board: only unfilled bars need help', !str_contains(stop_board_html($u(), $poppy), 'is running low') && str_contains(stop_board_html($u(), $poppy), 'could do with some fun'));

echo "== caps: no family passes its cap, place perks never pass the P2 ceiling\n";
q('DELETE FROM stop_marks WHERE user_id = ?', [$uid]);
$ctx = [];
foreach ($cat as $p) {
    if ($p['loc_id'] < 1) continue;
    try { db_insert('stop_marks', ['user_id' => $uid, 'location_id' => $p['loc_id'], 'bar' => $p['bar'], 'perk_key' => $p['key'], 'filled_on' => $today(), 'latched_at' => now(), 'kept' => 0]); } catch (PDOException $e) {}
    foreach ($p['scope'] as $k => $vals) foreach ($vals as $v) $ctx[$k][] = $v === 'here' ? (string)$p['loc_id'] : $v;
}
$ctx['at'] = $ctx['from'] = array_merge($ctx['from'] ?? [], $ctx['at'] ?? [], $ctx['to'] ?? []);
$ctx['to'] = $ctx['from'];
mark_held($uid, true);
ok('the gnome holds every matched perk', count(mark_held($uid)) === count(array_filter($cat, fn($p) => $p['loc_id'] > 0)), (string)count(mark_held($uid)));
$bad = []; $bites = 0;
foreach (MARK_FAMILIES as $code => [$name, , $cap]) {
    $raw = array_sum(array_map(fn($p) => abs($p['size']), array_filter(mark_held($uid), fn($p) => $p['family'] === $code && $p['class'] !== 'D' && $p['class'] !== 'F')));
    [$wd, $pl] = mark_sums($uid, $name, $ctx);
    $stack = MARK_PLACE_STACK[$code] ?? MARK_PLACE_STACK_DEFAULT;
    if ($wd > $cap || $pl > $stack || mark_pct($uid, $code, $ctx) !== $wd + $pl || mark_place($uid, $name, $ctx) !== $pl) $bad[] = "$name $wd/$cap $pl/$stack";
    if ($raw > $cap + $stack) $bites++;
}
ok('every family: world <= cap, place <= ceiling, pct = world + place', !$bad, implode('; ', $bad));
ok('the caps really cut (raw sums pass cap + ceiling in several families)', $bites >= 5, (string)$bites);
ok('walk at most -6% world -4% place = 10 (proposal 4.1)', mark_pct($uid, 'walk', $ctx) <= 10);
ok('a place perk needs its place: Straightened Signpost only on the Maplewold\'s forest/grassland/wetland roads', mark_place($uid, 'walk', ['region' => 'NA', 'land' => 'forest']) >= 2 && mark_place($uid, 'walk', ['region' => 'NA', 'land' => 'tundra', 'we' => 'sun']) === 0);
ok('a weather perk follows the weather (Watcher\'s Flask in rain, not in sun)', mark_pct($uid, 'walk', ['we' => 'rain']) - mark_pct($uid, 'walk', ['we' => 'sun']) >= 2);

echo "== daily charges: once a game day\n";
ok('a held daily charge is there', mark_daily_available($uid, 'bakers_thirteenth'));
ok('take it once', mark_daily_use($uid, 'bakers_thirteenth'));
ok('not twice in a game day', !mark_daily_use($uid, 'bakers_thirteenth') && !mark_daily_available($uid, 'bakers_thirteenth'));
ok('a flag or a number perk is not a daily charge', !mark_daily_use($uid, 'level_scales') && !mark_daily_use($uid, 'known_at_the_stalls'));
$sleep();
ok('back after a sleep', mark_daily_use($uid, 'bakers_thirteenth'));
$coins = 0; for ($i = 0; $i < 8; $i++) $coins += mark_daycoin($uid, 'pebble_in_the_boot', 2);
ok('A4 coins: 10 a game day at most', $coins === MARK_A4_CEILING, (string)$coins);
$sleep();
ok('A4 coins come back after a sleep', mark_daycoin($uid, 'pebble_in_the_boot', 2) === 2);
q("DELETE FROM stop_marks WHERE user_id = ? AND perk_key = 'meltwater_can'", [$uid]); mark_held($uid, true);
ok('a perk not held: no charge', !mark_daily_available($uid, 'meltwater_can') && !mark_daily_use($uid, 'meltwater_can'));
ok('flags by key and by family', mark_flag($uid, 'known_at_the_stalls') && mark_flag($uid, 'info') && mark_flag($uid, 'A6') && !mark_flag($uid, 'level_scales'));

echo "== UI\n";
$card = mark_card_html($uid);
ok('Lasting marks card: count, pips, perk names, totals', str_contains($card, 'Lasting marks') && str_contains($card, 'mk-pip on') && str_contains($card, $innPerk['name']) && str_contains($card, 'Adds up to'), substr(strip_tags($card), 0, 200));
ok('Do tab: a full bar shows its stamp', str_contains(mark_bars_html($uid, $lid), 'STOCKED ✔'));
ok('plaque line for a full bar', str_contains(mark_plaque_html($u(), $poppy), 'Stocked.'));
ok('stop popover: medals and the lasting marks card', str_contains(stop_perk_body($u(), $poppy), 'Lasting marks'));
ok('the town\'s rest stop panel renders', str_contains(local_panel($u(), $market), 'st-meters'));

echo "== grandfathering: old 7-day perks run out, no free marks, retirement\n";
q('DELETE FROM stop_marks WHERE user_id = ?', [$uid]); mark_held($uid, true); mark_latched($uid, $lid, true);
db_insert('player_perks', ['user_id' => $uid, 'perk_key' => 'bright_mood', 'meter' => 'cheer', 'until' => gmdate('Y-m-d', strtotime($today() . ' 12:00:00 UTC +3 days')), 'from_location_id' => $lid]);
stop_prog_set($uid, $lid, 'perk:cheer', 1, ['until' => gmdate('Y-m-d', strtotime($today() . ' 12:00:00 UTC +3 days'))]);
player_perks_active($uid, true);
ok('a running 7-day perk keeps running with marks on', player_perk($uid, 'bright_mood'));
ok('its "was full here" row is still shown', str_contains(stop_meters_html($uid, $lid), 'was full here'));
stop_prog_set($uid, $lid, 'meter:cheer', 99, ['d' => $today(), 'mk' => 1]);
ok('it gives no mark', !q_val('SELECT COUNT(*) FROM stop_marks WHERE user_id = ?', [$uid]));
$log($poppy, 'zz_g1', 'lore'); mark_after($u(), $poppy, ['slug' => 'zz_g1', 'name' => 'A tale', 'blurb' => '', 'kind' => 'lore', 'energy' => 1], '', false);
ok('a bar filled with marks on latches and grants no new 7-day perk', (int)q_val('SELECT COUNT(*) FROM player_perks WHERE user_id = ?', [$uid]) === 1 && $bar('cheer') === 100, q_val('SELECT COUNT(*) FROM player_perks WHERE user_id = ?', [$uid]) . ' ' . $bar('cheer'));
setg('perk_old_retired', '1');
player_perks_active($uid, true);
ok('perk_old_retired: the old perk stops, its row is kept', !player_perk($uid, 'bright_mood') && q_val('SELECT COUNT(*) FROM player_perks WHERE user_id = ?', [$uid]) == 1 && !str_contains(stop_meters_html($uid, $lid), 'was full here'));
setg('stop_marks_open', '0');
player_perks_active($uid, true);
ok('...but only with marks on (off again: the old perk is back)', player_perk($uid, 'bright_mood'));
setg('perk_old_retired', '0');

echo "== a real act with marks on (stop_do)\n";
setg('stop_marks_open', '1');
q('DELETE FROM stop_log WHERE user_id = ?', [$uid]); q('DELETE FROM stop_prog WHERE user_id = ?', [$uid]);
q('UPDATE users SET location_id = ?, energy = 50 WHERE id = ?', [(int)$market['id'], $uid]);
$GLOBALS['CURRENT_USER'] = $u();
$lore = null;
foreach (stop_pool($market, null, $uid)['offer'] as $x) if (in_array($x['kind'], ['lore', 'gossip', 'check', 'tend'], true)) { $lore = $x; break; }
if ($lore) {
    [$okDo, $msg] = stop_do($u(), $market, (string)$lore['slug'], ['opt' => 0]);
    echo "   stop_do {$lore['slug']}: $msg\n";
    $sum = 0; foreach (array_keys(MARK_BARS) as $b) $sum += stop_meter_get($uid, (int)$market['id'], $b);
    ok('an act at the town feeds a bar', $okDo && $sum > 0, $msg);
} else ok('the town offers an act that needs no pick today', false);
setg('stop_marks_open', '0');
foreach (['stop_marks', 'stop_mark_use', 'stop_prog', 'stop_log', 'player_perks'] as $t) q("DELETE FROM $t WHERE user_id = ?", [$uid]);
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
