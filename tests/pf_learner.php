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
q('DELETE FROM pf_learn WHERE user_id = ?', [$uid]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
