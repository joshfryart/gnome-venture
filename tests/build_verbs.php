<?php
// 2.7.06 build verbs: carry, decorate (deco:N), wait (wait:N game days), vigil (vigil:H game hours). php tests/build_verbs.php GAME_DIR (installed game, player "sprout").
$_SERVER['SCRIPT_NAME'] = '/landmark.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/rebuild.php'; require_once $argv[1] . '/includes/trade.php'; require_once $argv[1] . '/includes/gnome.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
ok('the new verbs exist and each has its own picture file', isset(BUILD_VERBS['carry'], BUILD_VERBS['decorate'], BUILD_VERBS['wait'], BUILD_VERBS['vigil']) && !array_diff_key(array_flip(['carry','decorate','wait','vigil','befriend','trial']), array_flip(array_keys(BUILD_VERBS))) && !array_filter(['carry','decorate','wait','vigil','befriend','trial'], fn($v) => !is_file(__DIR__ . '/../game/assets/img/steps/stage-' . (BUILD_VERB_ART[$v] ?? $v) . '.png') || isset(BUILD_VERB_ART[$v])));
ok('needs parse: wait:2, vigil:3, deco:4', build_parse_needs('wait:2') === [['wait', '', 2]] && build_parse_needs('vigil:3') === [['vigil', '', 3]] && build_parse_needs('deco:4') === [['deco', '', 4]] && build_parse_needs('wait:0') === []);
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
// a plan for one real landmark: 1 wait, 2 vigil, 3 decorate, 4 haul
$lm = q_one("SELECT * FROM landmarks WHERE kind IN ('haven','wonder') ORDER BY id LIMIT 1"); $name = $lm['name'];
$file = $argv[1] . '/includes/data/build_plans.txt'; $orig = file_get_contents($file);
$lines = array_filter(explode("\n", $orig), fn($l) => !str_starts_with($l, 'P|' . $name . '|'));
$lines[] = "P|$name|1|wait|Let it dry|wait:2|The mortar needs time.";
$lines[] = "P|$name|2|vigil|Keep watch|vigil:1|Someone should sit up with it.";
$lines[] = "P|$name|3|decorate|Make it homely|deco:1|A few touches.";
$lines[] = "P|$name|4|carry|Carry the last stones|item:rope:1|Heavy going.";
file_put_contents($file, implode("\n", $lines)); build_plans(true);
$plan = build_plan_of($lm); ok('the plan loads with the new verbs', $plan && $plan[1]['verb'] === 'wait' && $plan[2]['verb'] === 'vigil' && $plan[3]['verb'] === 'decorate' && $plan[4]['verb'] === 'carry', json_encode($plan));
q('UPDATE users SET location_id = ?, level = 40, game_day = 10, game_minute = 360, energy = 50 WHERE id = ?', [$lm['location_id'], $uid]);
q('DELETE FROM landmark_repairs WHERE user_id = ? AND landmark_id = ?', [$uid, $lm['id']]);
$rid = db_insert('landmark_repairs', ['user_id' => $uid, 'landmark_id' => $lm['id'], 'stage' => 0, 'started_at' => now(), 'plan' => 'v1']);
$arm = repair_arm_wait($uid, $rid, ['id' => $rid, 'plan' => 'v1', 'name' => $name], 1);
ok('a wait of 2 days armed on game day 10 finishes on day 12', $arm === 12, (string)$arm);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
[$hok] = repair_hand($u, $rid); ok('a wait stage cannot be handed in', $hok === false);
q('UPDATE users SET game_day = 11 WHERE id = ?', [$uid]); repair_settle($uid);
ok('one day later the wait is not over', (int)q_val('SELECT stage FROM landmark_repairs WHERE id = ?', [$rid]) === 0);
q('UPDATE users SET game_day = 12 WHERE id = ?', [$uid]); repair_settle($uid);
ok('on day 12 the wait stage finishes by itself', (int)q_val('SELECT stage FROM landmark_repairs WHERE id = ?', [$rid]) === 1, (string)q_val('SELECT stage FROM landmark_repairs WHERE id = ?', [$rid]));
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]); [$vk, $vm] = repair_vigil($u, $rid);
ok('the vigil takes an hour of game time and finishes stage 2', $vk === true && (int)q_val('SELECT stage FROM landmark_repairs WHERE id = ?', [$rid]) === 2 && (int)q_val('SELECT game_minute FROM users WHERE id = ?', [$uid]) >= 420, $vm);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]); [$dk] = repair_hand($u, $rid); ok('decorate with no decor item is refused', $dk === false);
$decor = q_val("SELECT id FROM items WHERE category = 'decor' ORDER BY id LIMIT 1");
if ($decor) { give_item($uid, (int)$decor, 1); $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]); [$dk2, $dm2] = repair_hand($u, $rid); ok('one decor item finishes the decorate stage', $dk2 === true && (int)q_val('SELECT stage FROM landmark_repairs WHERE id = ?', [$rid]) === 3, $dm2); }
else echo "  (no decor item in this world: decorate hand-in skipped)\n";
$box = repair_box(q_one('SELECT * FROM users WHERE id = ?', [$uid]), q_one('SELECT lr.*, l.name FROM landmark_repairs lr JOIN landmarks l ON l.id = lr.landmark_id WHERE lr.id = ?', [$rid]), 'x');
ok('the repair box draws a stage list for the new verbs without errors', str_contains($box, 'Keep watch') && str_contains($box, 'Carry the last stones'), substr($box, 0, 200));
// befriend and trial are conditions, not hand-ins
ok('needs parse: befriend:2, trial:1', build_parse_needs('befriend:2') === [['befriend', '', 2]] && build_parse_needs('trial:1') === [['trial', '', 1]]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$r0 = rebuild_need_rows($u, [['befriend', '', 1], ['trial', '', 1]], 0, $lm);
ok('before anything: friendship 0 and no clears', $r0[0][2] === 0 && $r0[1][2] === 0, json_encode($r0));
$folk = q_one('SELECT f.id FROM stop_folk f JOIN locations l ON l.id = f.location_id WHERE l.region_id = ? ORDER BY f.id LIMIT 1', [$lm['region_id']]);
if ($folk) { require_once $argv[1] . '/includes/stop_folk.php'; q('DELETE FROM stop_friend WHERE user_id = ? AND folk_id = ?', [$uid, $folk['id']]); stop_friend_ensure($uid, (int)$folk['id']); $need1 = STOP_FRIEND_LEVELS[1][0]; q('UPDATE stop_friend SET points = ? WHERE user_id = ? AND folk_id = ?', [$need1, $uid, $folk['id']]);
    ok('with a friendly villager of the region the befriend row reads level 1', rebuild_need_rows($u, [['befriend', '', 1]], 0, $lm)[0][2] >= 1); }
else echo "  (no stop villager in the region: befriend check skipped)\n";
q('DELETE FROM landmark_runs WHERE user_id = ? AND landmark_id = ?', [$uid, $lm['id']]);
try { db_insert('landmark_runs', ['user_id' => $uid, 'landmark_id' => $lm['id'], 'exp_id' => 987001, 'kind' => 'delve', 'outcome' => 'cleared', 'level' => 3, 'depth' => 4, 'stages' => 5, 'started_at' => '2026-01-01 00:00:00', 'ended_at' => '2026-01-01 00:10:00']);
    ok('one cleared run of the place counts as a trial', rebuild_need_rows($u, [['trial', '', 1]], 0, $lm)[0][2] === 1); } catch (Throwable $e) { echo "  (landmark_runs not writable here: trial check skipped)\n"; }
file_put_contents($file, $orig); build_plans(true);
echo $fails ? "$fails FAILED\n" : "ok\n"; exit($fails ? 1 : 0);
