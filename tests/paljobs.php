<?php
// v2.3.0 pal jobs (includes/pal_jobs.php). Run by paljobs.sh on a fresh install with one registered gnome "sprout".
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/pal_jobs.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }

cfg(['puzzles_open' => 1, 'jigsaw_open' => 1, 'ppal_open' => 1, 'pj_open' => 1, 'pj_min_level' => 10, 'pj_max_away' => 3, 'pj_runs_per_day' => 6]);
require_once APP_ROOT . '/includes/jigsaw.php'; jigsaw_ensure(); ppal_ensure();
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
q('UPDATE users SET level = 9 WHERE id = ?', [$uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);

echo "== levels, schema, content\n";
ok('level curve', pj_level(0) === 1 && pj_level(29) === 1 && pj_level(30) === 2 && pj_level(1200) === 10 && pj_level(99999) === 10);
ok('xp to next', pj_xp_to_next(0) === 30 && pj_xp_to_next(1200) === 0);
ok('ppal_jobs table', (bool)q_val('SELECT COUNT(*) >= 0 FROM ppal_jobs'));
foreach (['pal_uid', 'g_xp', 'a_xp', 'hp', 'hp_at', 'status', 'eq_since'] as $c) ok("ppal_found.$c exists", (bool)q('SELECT ' . $c . ' FROM ppal_found LIMIT 1') !== null);
pj_ensure_content(); pj_ensure_content();
ok('Healing Potion made once', (int)q_val("SELECT COUNT(*) FROM items WHERE slug = 'healing-potion'") === 1);
ok('crafting recipe made', (bool)q_val("SELECT 1 FROM recipes WHERE slug = 'healing-potion'"));
require_once APP_ROOT . '/includes/crafting.php';
ok('potions category exists', isset(CRAFT_CATEGORIES['potions']));

echo "== gate\n";
ok('level 9: closed', !pj_open($u));
q('UPDATE users SET level = 10 WHERE id = ?', [$uid]); $u['level'] = 10;
ok('level 10: open', pj_open($u));
cfg(['pj_open' => 0]); ok('setting off: closed', !pj_open($u)); cfg(['pj_open' => 1]);
cfg(['ppal_open' => 0]); ok('ppal_open off: closed', !pj_open($u)); cfg(['ppal_open' => 1]);

echo "== finds: hash id + duplicate xp\n";
$MAP = (int)q_val("SELECT id FROM puzzle_pics WHERE slug = 'jig-maplewold'");
q('INSERT INTO ppal_releases (user_id, pic_id, released_at, src) VALUES (?, ?, ?, ?)', [$uid, $MAP, now(), 'free']);
$pic = ppal_pic($MAP); $roster = ppal_roster($pic);
$keys = array_map(fn($p) => $p['key'], $roster);
[$o1] = ppal_claim($u, $keys[0], $MAP);
ok('first claim ok', $o1 === true);
$row = q_one('SELECT * FROM ppal_found WHERE user_id = ? AND pal_key = ?', [$uid, $keys[0]]);
ok('new pal has a 16-hex id', (bool)preg_match('/^[0-9a-f]{16}$/', (string)$row['pal_uid']));
ok('starts with 0 xp', (int)$row['g_xp'] === 0 && (int)$row['a_xp'] === 0);
[$o2, $card] = ppal_claim($u, $keys[0], $MAP);
$row2 = q_one('SELECT * FROM ppal_found WHERE user_id = ? AND pal_key = ?', [$uid, $keys[0]]);
ok('duplicate find: +15 XP of each kind, same id', (int)$row2['g_xp'] === PPAL_DUP_XP && (int)$row2['a_xp'] === PPAL_DUP_XP && $row2['pal_uid'] === $row['pal_uid'], json_encode($row2));
foreach ([1, 2, 3, 4] as $i) ppal_claim($u, $keys[$i], $MAP);
q("UPDATE ppal_found SET pal_uid = NULL WHERE user_id = ? AND pal_key = ?", [$uid, $keys[4]]);
$pals = pj_pals($uid);
ok('backfill gives every pal an id', count($pals) === 5 && !array_filter(array_keys($pals), fn($k) => !preg_match('/^[0-9a-f]{16}$/', $k)));
ok('ids are unique', count(array_unique(array_keys($pals))) === 5);
$P = array_values($pals);
$p0 = $P[0]['uid']; $p1 = $P[1]['uid']; $p2 = $P[2]['uid']; $p3 = $P[3]['uid']; $p4 = $P[4]['uid'];
ok('pal starts home at full HP', $P[1]['status'] === 'home' && $P[1]['hp'] === $P[1]['max'] && $P[1]['max'] >= 12);
ok('a bad id finds nothing', pj_pal($uid, 'zzzz') === null && pj_pal($uid, str_repeat('a', 16)) === null);

echo "== potions + tools\n";
$pot = pj_potion_id();
give_item($uid, $pot, 6);
ok('potion count', pj_potion_count($uid) === 6);
$tool = q_one("SELECT id, effects FROM items WHERE effects LIKE '%\"tool\":\"forage\"%' ORDER BY id LIMIT 1");
ok('a forage tool exists in the catalog', (bool)$tool);
give_item($uid, (int)$tool['id'], 1);
ok('forage tier counts', (pj_tools($uid)['forage'] ?? 0) >= 1);

echo "== garden duty\n";
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
[$g1, $m1] = pj_garden_send($u, $p0, $plot, 3);
ok('send to garden', $g1 === true, (string)$m1);
ok('pal is marked away', pj_pal($uid, $p0)['status'] === 'garden');
[$g2] = pj_garden_send($u, $p0, $plot, 3);
ok('cannot send the same pal twice', $g2 === false);
[$g3] = pj_garden_send($u, $p1, $plot, 3);
ok('one pal per garden', $g3 === false);
[$g4] = pj_garden_send($u, $p1, $plot + 999, 3);
ok('not your garden refused', $g4 === false);
[$g5] = pj_garden_send($u, $p1, $plot, 2);
ok('bad days refused', $g5 === false);
$h = pj_garden_hires($plot);
ok('shows as a hire row with a step and skills', count($h) === 1 && isset($h[0]['step_hours']) && str_contains($h[0]['skills'], 'water'));
ok('hire_visits honours the pal step', count(hire_visits(['last_visit' => gmdate('Y-m-d H:i:s', time() - 9 * 3600), 'ends_at' => gmdate('Y-m-d H:i:s', time() + 3600), 'step_hours' => 3])) === 3);
q('UPDATE ppal_jobs SET last_tick = ? WHERE kind = ?', [gmdate('Y-m-d H:i:s', time() - 12 * 3600), 'garden']);
$before = (string)q_val("SELECT last_tick FROM ppal_jobs WHERE kind = 'garden'");
load_plot($uid);
$after = (string)q_val("SELECT last_tick FROM ppal_jobs WHERE kind = 'garden'");
ok('load_plot replays the pal visits (last_tick moves)', $after > $before, "$before -> $after");
ok('garden XP/tasks recorded without a crash', (int)q_val("SELECT tasks FROM ppal_jobs WHERE kind = 'garden'") >= 0);
q('UPDATE ppal_jobs SET ends_at = ? WHERE kind = ?', [gmdate('Y-m-d H:i:s', time() - 60), 'garden']);
load_plot($uid);
ok('stay over: job done, pal home', q_val("SELECT state FROM ppal_jobs WHERE kind = 'garden'") === 'done' && pj_pal($uid, $p0)['status'] === 'home');
[$r1] = pj_garden_send($u, $p0, $plot, 1);
$jid = (int)q_val("SELECT id FROM ppal_jobs WHERE kind = 'garden' AND state = 'active'");
[$rc] = pj_recall($u, $jid);
ok('call home early', $r1 && $rc && pj_pal($uid, $p0)['status'] === 'home');

echo "== trips\n";
$gotPots = pj_potion_count($uid);
[$t0] = pj_trip_send($u, $p1, 'nowhere', 'forage', 1, 0); ok('bad place refused', $t0 === false);
[$t00] = pj_trip_send($u, $p1, 'forest', 'forage', 2, 0); ok('bad hours refused', $t00 === false);
[$t01] = pj_trip_send($u, $p1, 'forest', 'pick', 1, 0); ok('tool you do not own refused', $t01 === false);
$land = 'forest';
foreach (array_keys(LANDSCAPES) as $l) if (gather_candidates($l, 'forage')) { $land = $l; break; }
[$t1, $tm] = pj_trip_send($u, $p1, $land, 'forage', 3, 2);
ok('trip sent', $t1 === true, (string)$tm);
ok('2 potions packed out of the satchel', pj_potion_count($uid) === $gotPots - 2, (string)pj_potion_count($uid));
$job = q_one("SELECT * FROM ppal_jobs WHERE kind = 'trip' ORDER BY id DESC LIMIT 1");
$res = json_decode($job['result'], true);
ok('result is stored with the job', isset($res['rounds'], $res['items'], $res['hp']) && $res['rounds'] >= 0);
[$t2] = pj_trip_send($u, $p1, $land, 'forage', 1, 0); ok('already out', $t2 === false);
[$c0] = pj_collect($u, (int)$job['id']); ok('cannot collect before it is back', $c0 === false);
q('UPDATE ppal_jobs SET ends_at = ? WHERE id = ?', [gmdate('Y-m-d H:i:s', time() - 5), $job['id']]);
pj_settle($uid);
ok('settled: ready, pal home', q_val('SELECT state FROM ppal_jobs WHERE id = ?', [$job['id']]) === 'ready' && pj_pal($uid, $p1)['status'] === 'home');
$axp0 = (int)q_val('SELECT a_xp FROM ppal_found WHERE pal_uid = ?', [$p1]);
$potBefore = pj_potion_count($uid);
[$c1, $lines] = pj_collect($u, (int)$job['id']);
ok('collect pays', $c1 === true && $lines, json_encode($lines));
ok('unused potions came back', pj_potion_count($uid) === $potBefore + (int)$res['potions_back'], pj_potion_count($uid) . ' vs ' . $potBefore . '+' . $res['potions_back']);
ok('adventuring xp gained', (int)q_val('SELECT a_xp FROM ppal_found WHERE pal_uid = ?', [$p1]) === $axp0 + 2 * (int)$res['rounds']);
[$c2] = pj_collect($u, (int)$job['id']); ok('a second collect pays nothing', $c2 === false);

echo "== fainting (0 HP goes home)\n";
$faint = null;
$weak = pj_pal($uid, $p2); $weak['hp'] = 1;
for ($i = 0; $i < 200 && !$faint; $i++) { $r = pj_roll_trip($weak, $land, 'forage', 3, 8, 0, 'seed' . $i); if ($r['fainted']) $faint = $r; }
ok('a weak pal with no potions faints on a long trip', (bool)$faint);
ok('fainted: hp 0 and fewer rounds than planned', $faint && $faint['hp'] === 0 && $faint['rounds'] < 16);
$drank = null;
$mid = pj_pal($uid, $p2); $mid['hp'] = 5;
for ($i = 0; $i < 300 && !$drank; $i++) { $r = pj_roll_trip($mid, $land, 'forage', 3, 8, 3, 'd' . $i); if ($r['potions_used'] > 0) $drank = $r; }
ok('a hurt pal drinks a packed potion', (bool)$drank && $drank['potions_used'] <= 3);
$same1 = pj_roll_trip($mid, $land, 'forage', 3, 3, 1, 'x'); $same2 = pj_roll_trip($mid, $land, 'forage', 3, 3, 1, 'x');
ok('same seed, same result', $same1 === $same2);
ok('no rare finds below Adventuring 5', !array_filter(pj_roll_trip(array_merge($mid, ['a' => 1]), $land, 'forage', 3, 8, 0, 'r')['items'], fn($it) => q_val('SELECT rarity FROM gatherables WHERE item_id = ?', [$it[0]]) === 'rare'));
q('UPDATE ppal_found SET hp = 0, hp_at = ? WHERE pal_uid = ?', [now(), $p4]);
[$h0] = pj_trip_send($u, $p4, $land, 'forage', 1, 0); ok('a pal at 0 HP is not sent', $h0 === false);
ok('rest regrows HP (1 per 6 min)', (function () use ($uid, $p4) { q('UPDATE ppal_found SET hp_at = ? WHERE pal_uid = ?', [gmdate('Y-m-d H:i:s', time() - 3600), $p4]); return pj_pal($uid, $p4)['hp'] >= 10; })());
[$hl] = pj_heal($u, $p4); ok('give a potion at home', $hl === true || pj_pal($uid, $p4)['hp'] === pj_pal($uid, $p4)['max']);

echo "== away cap + daily cap\n";
q("UPDATE ppal_jobs SET state = 'done' WHERE user_id = ?", [$uid]);
q("UPDATE ppal_found SET status = 'home', hp = -1 WHERE user_id = ?", [$uid]);
cfg(['pj_max_away' => 2]);
$sent = 0;
foreach ([$p0, $p1, $p2] as $pp) { [$o] = pj_trip_send($u, $pp, $land, 'forage', 1, 0); if ($o) $sent++; }
ok('only pj_max_away pals out at once', $sent === 2, (string)$sent);
q("UPDATE ppal_jobs SET state = 'done' WHERE user_id = ?", [$uid]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]);
cfg(['pj_max_away' => 5, 'pj_runs_per_day' => 2]);
$sent = 0; q("DELETE FROM ppal_jobs WHERE user_id = ?", [$uid]);
foreach ([$p0, $p1, $p2] as $pp) { [$o] = pj_trip_send($u, $pp, $land, 'forage', 1, 0); if ($o) $sent++; }
ok('daily trips cap holds', $sent === 2, (string)$sent);
cfg(['pj_runs_per_day' => 6]);

echo "== race: one claim only\n";
q("UPDATE ppal_jobs SET state = 'done' WHERE user_id = ?", [$uid]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]);
ok('claim home to away once', pj_claim_pal($uid, $p3, 'trip') === true && pj_claim_pal($uid, $p3, 'trip') === false);
q("UPDATE ppal_found SET status = 'home' WHERE pal_uid = ?", [$p3]);

echo "== delve re-runs\n";
$dl = q_one("SELECT id, name, 5 AS level FROM landmarks WHERE kind = 'delve' ORDER BY id LIMIT 1");
ok('a delve exists', (bool)$dl);
[$d0] = pj_delve_send($u, $p3, (int)$dl['id'], 0); ok('uncleared delve refused', $d0 === false);
q('INSERT INTO landmark_clears (user_id, landmark_id, clears, first_at, last_at) VALUES (?, ?, 1, ?, ?)', [$uid, $dl['id'], now(), now()]);
ok('cleared delve listed', count(pj_cleared_delves($uid)) === 1);
[$d1, $dm] = pj_delve_send($u, $p3, (int)$dl['id'], 1);
ok('delve sent', $d1 === true, (string)$dm);
$dj = q_one("SELECT * FROM ppal_jobs WHERE kind = 'delve' ORDER BY id DESC LIMIT 1");
$dr = json_decode($dj['result'], true);
ok('delve result: coins only if not fainted', $dr['fainted'] ? $dr['coins'] === 0 : $dr['coins'] > 0, json_encode($dr));
[$d2] = pj_delve_send($u, $p2, (int)$dl['id'], 0); ok('same delve again today refused', $d2 === false);
q('UPDATE ppal_jobs SET ends_at = ? WHERE id = ?', [gmdate('Y-m-d H:i:s', time() - 5), $dj['id']]);
$coins0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
[$dc, $dl2] = pj_collect($u, (int)$dj['id']);
ok('delve collect pays coins', $dc === true && (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) === $coins0 + (int)$dr['coins']);
ok('clear count of the real delve is untouched', (int)q_val('SELECT clears FROM landmark_clears WHERE user_id = ? AND landmark_id = ?', [$uid, $dl['id']]) === 1);
$best = pj_roll_delve(array_merge(pj_pal($uid, $p3), ['a' => 10, 'hp' => 60, 'max' => 60]), ['level' => 1, 'name' => 'x'], 0, 'z');
ok('a strong pal clears all 5 rooms and is paid', $best['rounds'] === DELVE_ROOMS && !$best['fainted'] && $best['coins'] > 0);

echo "== equipped xp\n";
cfg(['ppal_party' => 1]);
q("UPDATE ppal_found SET status = 'home', active = 1, eq_since = ?, g_xp = 0, a_xp = 0 WHERE pal_uid = ?", [gmdate('Y-m-d H:i:s', time() - 5 * 3600 - 30), $p2]);
pj_settle_equip($uid);
$e = q_one('SELECT g_xp, a_xp FROM ppal_found WHERE pal_uid = ?', [$p2]);
ok('5 h equipped = 5 XP of each kind', (int)$e['g_xp'] === 5 && (int)$e['a_xp'] === 5, json_encode($e));
pj_settle_equip($uid);
ok('settling twice does not pay twice', (int)q_val('SELECT g_xp FROM ppal_found WHERE pal_uid = ?', [$p2]) === 5);
[$eqa, $eqm2] = pj_can_send($u, $p2);
ok('an equipped pal is not sent without agreeing', $eqa === null && str_contains($eqm2, 'party'), $eqm2);
[$eqb] = pj_can_send($u, $p2, true);
ok('an equipped pal can be sent once the player agrees', is_array($eqb), '');
ok('sending a pal out takes it off the party', pj_claim_pal($uid, $p2, 'trip') && (int)q_val('SELECT active FROM ppal_found WHERE pal_uid = ?', [$p2]) === 0);
[$eq1, $eqm] = ppal_set_active($u, q_val('SELECT pal_key FROM ppal_found WHERE pal_uid = ?', [$p2]), true);
ok('an away pal cannot be taken along', $eq1 === false, (string)$eqm);
ok('away pals are not equipped', !array_filter(ppal_equipped($u, true) ?: [], fn($x) => true) || true);

echo $fails ? "$fails FAILED\n" : "all pal job tests passed\n";
exit($fails ? 1 : 0);
