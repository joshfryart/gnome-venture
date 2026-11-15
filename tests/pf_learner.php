<?php
// 2.7.01 learner rules: a gnome's first fights (pfight_learner_n, default 3) have no Thornburst, no creature tags and creature pieces x0.8; then the full rules.
// php tests/pf_learner.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/pfight_game.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
q('DELETE FROM pf_learn WHERE user_id = ?', [$uid]);
ok('a new gnome has learner rules left', pf_learner_left($uid));
pf_learner_bump($uid); pf_learner_bump($uid);
ok('still after 2 fights', pf_learner_left($uid));
pf_learner_bump($uid);
ok('not after 3 fights', !pf_learner_left($uid), (string)q_val('SELECT fights FROM pf_learn WHERE user_id = ?', [$uid]));
set_setting('pfight_learner_n', '0'); setting('__reload__'); q('DELETE FROM pf_learn WHERE user_id = ?', [$uid]);
ok('pfight_learner_n = 0 switches them off', !pf_learner_left($uid));
set_setting('pfight_learner_n', '3'); setting('__reload__');
$kinds = fn(array $d) => array_unique(array_map(fn($t) => $t['env'], $d));
ok('the normal deck has Thornburst', in_array('thorn', $kinds(pfb_env_deck('medium')), true));
ok('the learner deck has none', !in_array('thorn', $kinds(pfb_env_deck('medium', '', true, true)), true) && count(pfb_env_deck('medium', '', true, true)) > 0);
$cfg = pfb_v1_cfg('small', ['foe_x' => 0.8, 'tags' => 0, 'nothorn' => 1], 1); $base = pfb_v1_cfg('small', [], 1);
ok('learner cfg: tags off, nothorn on, creature pieces x0.8', $cfg['tags'] === 0 && $cfg['nothorn'] === 1 && abs($cfg['foe'] - 0.8 * $base['foe']) < 0.001, json_encode([$cfg['tags'], $cfg['nothorn'], $cfg['foe'], $base['foe']]));
// 2.7.01 learner UI: End turn asks before a costly move in the first 5 fights; "New today" on the first fight after the learner fights
q('DELETE FROM pf_learn WHERE user_id = ?', [$uid]);
ok('costly-move ask is on for a new gnome', function_exists('pf_cost_warn') && pf_cost_warn($uid));
ok('no "New today" for a new gnome', function_exists('pf_new_today') && pf_new_today($uid) === []);
for ($i = 0; $i < 3; $i++) pf_learner_bump($uid);
$nt = function_exists('pf_new_today') ? pf_new_today($uid) : [];
ok('"New today" after the 3 learner fights names Thornburst and creature tags', (bool)preg_grep('/^Thornburst\./', $nt) && (bool)preg_grep('/^Creature tags\./', $nt), json_encode($nt));
$h = function_exists('pf_new_today_html') ? pf_new_today_html(['newt' => $nt, 'turn' => 1]) : '';
ok('the card shows on turn 1', str_contains($h, 'id="pfv-new"') && str_contains($h, 'New today:') && str_contains($h, 'Thornburst'), $h);
ok('the card is gone from turn 2', function_exists('pf_new_today_html') && pf_new_today_html(['newt' => $nt, 'turn' => 2]) === '');
ok('a fight without new rules has no card', function_exists('pf_new_today_html') && pf_new_today_html(['turn' => 1]) === '');
pf_learner_bump($uid);
ok('no "New today" from the 5th fight', pf_new_today($uid) === []);
ok('costly-move ask still on in fight 5', pf_cost_warn($uid));
pf_learner_bump($uid);
ok('costly-move ask off after 5 fights', !pf_cost_warn($uid));
set_setting('pfight_costwarn_n', '0'); setting('__reload__'); q('DELETE FROM pf_learn WHERE user_id = ?', [$uid]);
ok('pfight_costwarn_n = 0 switches the ask off', !pf_cost_warn($uid));
set_setting('pfight_costwarn_n', '5'); setting('__reload__');
q('DELETE FROM pf_learn WHERE user_id = ?', [$uid]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
