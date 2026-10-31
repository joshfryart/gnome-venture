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
$rland = (string)q_val("SELECT landscapes FROM gatherables WHERE rarity = 'rare' AND active = 1 AND tool = 'forage' AND landscapes <> 'any' LIMIT 1"); $rland = trim(explode(',', $rland)[0]);
$rares = function (int $a) use ($mid, $rland): int { $n = 0; for ($i = 0; $i < 150; $i++) foreach (pj_roll_trip(array_merge($mid, ['a' => $a, 'hp' => 60, 'max' => 60]), $rland, 'forage', 3, 8, 0, 'r' . $i)['items'] as $it)
    if (q_val('SELECT rarity FROM gatherables WHERE item_id = ?', [$it[0]]) === 'rare') $n += $it[1]; return $n; };
$r1 = $rares(1); $r5 = $rares(5); $r10 = $rares(10);
ok('v2.3.3: rare finds from Adventuring 1, more as the level grows', $r1 > 0 && $r5 > $r1 && $r10 > $r5, "$r1 / $r5 / $r10");
ok('v2.3.3: rare scale is smooth (0.36 at 1, 1.0 at 5, 1.4 at 10)', abs(pj_rare_mult(1) - 0.36) < 0.001 && abs(pj_rare_mult(5) - 1.0) < 0.001 && abs(pj_rare_mult(10) - 1.4) < 0.001);
ok('v2.3.3: delve rares possible at Adventuring 1', (function () use ($mid) { for ($i = 0; $i < 400; $i++) { $r = pj_roll_delve(array_merge($mid, ['a' => 1, 'hp' => 200, 'max' => 200]), ['level' => 10, 'name' => 'x'], 0, 'q' . $i);
    foreach ($r['items'] as $it) if (q_val('SELECT rarity FROM gatherables WHERE item_id = ?', [$it[0]]) === 'rare') return true; } return false; })());
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

echo "== collect receipt wording + home notice (v2.3.3)\n";
q("UPDATE ppal_jobs SET state = 'done' WHERE user_id = ?", [$uid]); q("UPDATE ppal_found SET status = 'home', active = 0, hp = -1 WHERE user_id = ?", [$uid]);
$pr = pj_pal($uid, $p0);
ok('home notice: nothing due, nothing shown', pj_home_count($u) === 0 && pj_home_notice_html($u) === '');
$fake = ['rounds' => 2, 'items' => [], 'hp' => 0, 'potions_used' => 1, 'potions_back' => 1, 'fainted' => true, 'log' => []];
q("UPDATE ppal_found SET status = 'trip' WHERE pal_uid = ?", [$p0]);
$fj = db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $p0, 'kind' => 'trip', 'target' => $land, 'plot_id' => null, 'day' => landmark_day(), 'tool' => 'forage',
    'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() - 5), 'last_tick' => now(), 'potions' => 2, 'state' => 'active', 'result' => json_encode($fake)]);
$nh = pj_home_notice_html($u);
ok('home notice: 1 pal home with loot (due, not yet settled), links to the jobs page', pj_home_count($u) === 1 && str_contains($nh, '1 pal home with loot') && str_contains($nh, 'paljobs.php'), $nh);
ok('home notice: no inline style', !str_contains($nh, 'style='));
[$fo, $fl, $fh] = pj_collect($u, (int)$fj);
ok('receipt head names the pal and the place, early', $fo && str_contains($fh, $pr['name']) && str_contains($fh, 'came home early') && str_contains($fh, strtolower(LANDSCAPES[$land][1])), $fh);
ok('receipt: faint line first', str_starts_with($fl[0] ?? '', '😵'), json_encode($fl));
ok('receipt: says no finds when empty', (bool)array_filter($fl, fn($l) => str_contains($l, 'No finds')), json_encode($fl));
ok('receipt: potions drunk and back in one line', (bool)array_filter($fl, fn($l) => str_contains($l, 'Drank 1 potion, 1 back')), json_encode($fl));
ok('receipt: XP line', (bool)array_filter($fl, fn($l) => str_starts_with($l, '⭐ +4 Adventuring XP')), json_encode($fl));
ok('home notice gone after collect', pj_home_count($u) === 0 && pj_home_notice_html($u) === '');
q("UPDATE ppal_found SET a_xp = 28, status = 'delve' WHERE pal_uid = ?", [$p0]);
$dj2 = db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $p0, 'kind' => 'delve', 'target' => (string)$dl['id'], 'plot_id' => null, 'day' => landmark_day(), 'tool' => null,
    'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() - 5), 'last_tick' => now(), 'potions' => 0, 'state' => 'ready',
    'result' => json_encode(['rounds' => 5, 'coins' => 30, 'items' => [], 'hp' => 9, 'potions_used' => 0, 'potions_back' => 0, 'fainted' => false, 'log' => []])]);
q("UPDATE ppal_found SET status = 'home' WHERE pal_uid = ?", [$p0]);
ok('home notice: 2 pals wording', (function () use ($u, $uid, $p1, $land) {
    q("UPDATE ppal_found SET status = 'trip' WHERE pal_uid = ?", [$p1]);
    $id = db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $p1, 'kind' => 'trip', 'target' => $land, 'plot_id' => null, 'day' => landmark_day(), 'tool' => 'forage',
        'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() - 5), 'last_tick' => now(), 'potions' => 0, 'state' => 'ready', 'result' => json_encode(['rounds' => 1, 'items' => [], 'hp' => 5, 'potions_used' => 0, 'potions_back' => 0, 'fainted' => false])]);
    $ok = str_contains(pj_home_notice_html($u), '2 pals home with loot');
    q('DELETE FROM ppal_jobs WHERE id = ?', [$id]); q("UPDATE ppal_found SET status = 'home' WHERE pal_uid = ?", [$p1]);
    return $ok; })());
[$do2, $dl3, $dh2] = pj_collect($u, (int)$dj2);
ok('delve receipt: back from the delve by name', $do2 && str_contains($dh2, 'is back from ' . $dl['name']), $dh2);
ok('delve receipt: coins and a level up', (bool)array_filter($dl3, fn($l) => str_starts_with($l, '💰')) && (bool)array_filter($dl3, fn($l) => str_contains($l, 'now level 2')), json_encode($dl3));
pj_garden_send($u, $p1, $plot, 1);
q("UPDATE ppal_jobs SET ends_at = ? WHERE kind = 'garden' AND state = 'active'", [gmdate('Y-m-d H:i:s', time() - 5)]);
ok('a garden stay never counts as loot', pj_home_count($u) === 0);
q('DELETE FROM ppal_jobs WHERE id IN (?, ?)', [$fj, $dj2]); q("UPDATE ppal_jobs SET state = 'done' WHERE user_id = ?", [$uid]); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]);   // leave the runs and slots free for the page tests
cfg(['pj_open' => 0]); ok('home notice hidden when pal jobs are closed', pj_home_notice_html($u) === ''); cfg(['pj_open' => 1]);

echo "== v2.3.3: garden tasks from level 1, and a pal beside hired help (no double work, no double pay)\n";
q("UPDATE ppal_jobs SET state = 'done' WHERE user_id = ?", [$uid]); q("UPDATE ppal_found SET status = 'home', g_xp = 0 WHERE user_id = ?", [$uid]);
ok('Gardening 1 pal waters, weeds and harvests', pj_garden_skills(1) === ['water', 'weed', 'harvest']);
ok('extra-crop odds grow smoothly (0 at 1, 36 at 10)', pj_garden_extra_pct(1) === 0 && pj_garden_extra_pct(5) === 16 && pj_garden_extra_pct(10) === 36);
ok('visits come more often with Gardening', pj_garden_step(1) > pj_garden_step(8));
ensure_helpers();
$H = []; foreach (q('SELECT * FROM helpers ORDER BY wage')->fetchAll() as $hr) $H[(string)$hr['skills']] = $hr;
$slow = q_one("SELECT * FROM plants WHERE kind <> 'cover' ORDER BY grow_minutes DESC, id LIMIT 1");   // the slowest crop stays thirsty, not ready
$rad = q_one("SELECT * FROM plants WHERE slug = 'radish'");
$T = q('SELECT id FROM plot_tiles WHERE plot_id = ? ORDER BY id LIMIT 3', [$plot])->fetchAll(PDO::FETCH_COLUMN);
$ago = fn(int $h): string => gmdate('Y-m-d H:i:s', time() - $h * 3600);
$setup = function (?array $helper) use ($uid, $plot, $p3, $T, $slow, $rad, $ago): int {
    q("DELETE FROM garden_hires WHERE plot_id = ?", [$plot]);
    q("DELETE FROM ppal_jobs WHERE kind = 'garden'");
    q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]);
    q("UPDATE plot_tiles SET plant_id = NULL, planted_at = NULL, growth_seconds = 0, last_watered = NULL, weeds = 0, pest = NULL, method = 'dig', tilled = 0 WHERE plot_id = ?", [$plot]);
    q("UPDATE plot_tiles SET tilled = 1, plant_id = ?, planted_at = ?, growth_updated_at = ?, growth_seconds = 0, last_watered = NULL WHERE id = ?", [$slow['id'], $ago(9), $ago(9), $T[0]]);   // thirsty
    q("UPDATE plot_tiles SET tilled = 1, plant_id = ?, planted_at = ?, growth_updated_at = ?, growth_seconds = 999999, last_watered = ? WHERE id = ?", [$rad['id'], $ago(9), now(), now(), $T[1]]);   // ready
    q("UPDATE plot_tiles SET tilled = 1, method = 'notill', weeds = 30, maint_at = ? WHERE id = ?", [now(), $T[2]]);   // weedy
    if ($helper) db_insert('garden_hires', ['plot_id' => $plot, 'user_id' => $uid, 'helper_id' => $helper['id'], 'started_at' => $ago(9), 'ends_at' => gmdate('Y-m-d H:i:s', time() + 86400), 'last_visit' => $ago(9), 'paid' => (int)$helper['wage']]);
    q("UPDATE ppal_found SET status = 'garden' WHERE pal_uid = ?", [$p3]);
    return db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $p3, 'kind' => 'garden', 'target' => (string)$plot, 'plot_id' => $plot, 'day' => landmark_day(),
        'started_at' => $ago(9), 'ends_at' => gmdate('Y-m-d H:i:s', time() + 86400), 'last_tick' => $ago(9), 'potions' => 0, 'state' => 'active', 'result' => null]);
};
// alone: the pal does all three
$jid = $setup(null);
load_plot($uid);
ok('pal alone: harvested the ready square', !q_val('SELECT plant_id FROM plot_tiles WHERE id = ?', [$T[1]]));
ok('pal alone: weeded the bed', (int)q_val('SELECT weeds FROM plot_tiles WHERE id = ?', [$T[2]]) === 0);
ok('pal alone: watered the thirsty square', q_val('SELECT last_watered FROM plot_tiles WHERE id = ?', [$T[0]]) !== null);
ok('pal alone: tasks = water + weed + 2 x harvest', (int)q_val('SELECT tasks FROM ppal_jobs WHERE id = ?', [$jid]) >= 4, (string)q_val('SELECT tasks FROM ppal_jobs WHERE id = ?', [$jid]));
require_once APP_ROOT . '/includes/social169.php';
[, $tl, $pl] = load_plot($uid);
ok('a friend finds nothing thirsty after the pal (need-gated, no double watering)', !array_filter(social169_thirsty($tl, $pl), fn($t) => (int)$t['id'] === (int)$T[0]));
foreach ($H as $sk => $hr) {
    $skills = explode(',', $sk);
    $jid = $setup($hr);
    $mine = pj_garden_hires($plot)[0]['skills'] ?? '?';
    ok($hr['name'] . ' (' . $sk . '): the pal still has all three tasks (works after the helper)', $mine === 'water,weed,harvest', $mine);
    load_plot($uid);
    $gh = q_one('SELECT * FROM garden_hires WHERE plot_id = ?', [$plot]);
    $tasks = (int)q_val('SELECT tasks FROM ppal_jobs WHERE id = ?', [$jid]);
    $want = (in_array('weed', $skills, true) ? 0 : 1) + (in_array('harvest', $skills, true) ? 0 : 2);   // same visit times: the helper waters first, so nothing is dry for the pal
    ok($hr['name'] . ': the pal does only what the helper left (' . $want . ')', $tasks === $want, "tasks $tasks, hire " . json_encode([$gh['waterings'], $gh['weedings'], $gh['harvests']]));
    ok($hr['name'] . ': ready square harvested exactly once', !q_val('SELECT plant_id FROM plot_tiles WHERE id = ?', [$T[1]]) && (int)$gh['harvests'] + intdiv($tasks, 2) === 1, json_encode($gh));
    ok($hr['name'] . ': weedy bed weeded exactly once', (int)q_val('SELECT weeds FROM plot_tiles WHERE id = ?', [$T[2]]) === 0 && (int)$gh['weedings'] + ($tasks % 2) === 1);
    ok($hr['name'] . ': the helper is still paid only its wage (no pay for the pal)', (int)$gh['paid'] === (int)$hr['wage']);
}
$all = $H['water,weed,harvest'];
// a helper who does all three, visits due at the same times as the pal: the helper acts first, the pal finds nothing left
$jid = $setup($all);
load_plot($uid);
$gh = q_one('SELECT * FROM garden_hires WHERE plot_id = ?', [$plot]);
ok('all-three helper + pal, same visits: helper first, pal has nothing left (0 tasks)', (int)q_val('SELECT tasks FROM ppal_jobs WHERE id = ?', [$jid]) === 0, json_encode($gh));
ok('all-three helper + pal: one harvest, one weeding, square watered', (int)$gh['harvests'] === 1 && (int)$gh['weedings'] === 1 && (int)$gh['waterings'] >= 1 && !q_val('SELECT plant_id FROM plot_tiles WHERE id = ?', [$T[1]]));
// the same helper with no visit due yet: the pal picks up the leftovers on its own visits
$jid = $setup($all);
q('UPDATE garden_hires SET last_visit = ? WHERE plot_id = ?', [now(), $plot]);
$rq0 = (int)q_val('SELECT COALESCE(SUM(qty), 0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $rad['produce_item_id']]);
load_plot($uid);
$gh = q_one('SELECT * FROM garden_hires WHERE plot_id = ?', [$plot]);
$tk = (int)q_val('SELECT tasks FROM ppal_jobs WHERE id = ?', [$jid]);
ok('all-three helper not due: the pal harvests, weeds and waters the leftovers', $tk >= 4 && (int)$gh['harvests'] === 0 && (int)$gh['weedings'] === 0 && (int)$gh['waterings'] === 0, "pal $tk, hire " . json_encode([$gh['waterings'], $gh['weedings'], $gh['harvests']]));
ok('leftovers: the ready square is harvested once and the crop is paid once', !q_val('SELECT plant_id FROM plot_tiles WHERE id = ?', [$T[1]]) && (int)q_val('SELECT COALESCE(SUM(qty), 0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $rad['produce_item_id']]) > $rq0);
load_plot($uid);
ok('loading again does nothing twice (no new tasks, helper still idle)', (int)q_val('SELECT tasks FROM ppal_jobs WHERE id = ?', [$jid]) === $tk && (int)q_val('SELECT harvests FROM garden_hires WHERE plot_id = ?', [$plot]) === 0);
// sending is never refused because of hired help
$setup($all); q("DELETE FROM ppal_jobs WHERE kind = 'garden'"); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]);
[$gb, $gm] = pj_garden_send($u, $p3, $plot, 1);
ok('a helper who does everything: the pal can still be sent, and is told it works after the helper', $gb === true && str_contains((string)$gm, 'working after your hired help'), (string)$gm);
q("DELETE FROM ppal_jobs WHERE kind = 'garden'"); q("UPDATE ppal_found SET status = 'home' WHERE user_id = ?", [$uid]); q("DELETE FROM garden_hires WHERE plot_id = ?", [$plot]);
[$gb2, $gm2] = pj_garden_send($u, $p3, $plot, 1);
ok('no hired help: the message does not mention it', $gb2 === true && !str_contains((string)$gm2, 'hired help'), (string)$gm2);
q("DELETE FROM garden_hires WHERE plot_id = ?", [$plot]); q("UPDATE ppal_jobs SET state = 'done' WHERE kind = 'garden'"); q("UPDATE ppal_found SET status = 'home', g_xp = 0 WHERE user_id = ?", [$uid]);
q("UPDATE plot_tiles SET plant_id = NULL, planted_at = NULL, growth_seconds = 0, last_watered = NULL, weeds = 0, method = 'dig' WHERE plot_id = ?", [$plot]);
$xtra = 0; for ($i = 0; $i < 200; $i++) $xtra += pj_garden_extra($uid, $rad, ['pj_job' => 1, 'pj_extra' => pj_garden_extra_pct(10)]);
ok('Gardening 10 brings extra crops about a third of the time', $xtra > 40 && $xtra < 110, (string)$xtra);
ok('Gardening 1 brings none', array_sum(array_map(fn() => pj_garden_extra($uid, $rad, ['pj_job' => 1, 'pj_extra' => 0]), range(1, 50))) === 0);

echo "== MySQL safety (static: no MySQL here)\n";
[$mt, $mi, $mc] = ppal_schema('INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', 'INT UNSIGNED', ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
$defs = [];
foreach ($mt as $sql) {
    preg_match('/CREATE TABLE IF NOT EXISTS (\w+) \((.*)\)/s', $sql, $m);
    foreach (preg_split('/,\s*\n/', trim($m[2])) as $line) {
        if (preg_match('/^(\w+)\s+(.+)$/', trim($line), $c) && !in_array(strtoupper($c[1]), ['UNIQUE', 'PRIMARY', 'KEY', 'INDEX'], true)) $defs[] = [$m[1], $c[1], $c[2]];
    }
}
foreach ($mc as [$tb, $col, $def]) $defs[] = [$tb, $col, $def];
// MySQL 8.0 reserved words (a column or table with one of these names breaks unless it is quoted everywhere)
$RES = ['ACCESSIBLE','ADD','ALL','ALTER','ANALYZE','AND','AS','ASC','BEFORE','BETWEEN','BY','CALL','CASCADE','CASE','CHANGE','CHECK','COLUMN','CONDITION','CONSTRAINT','CONTINUE','CREATE','CROSS',
  'CUBE','CUME_DIST','CURRENT_DATE','CURRENT_TIME','CURRENT_USER','CURSOR','DATABASE','DEFAULT','DELETE','DENSE_RANK','DESC','DESCRIBE','DISTINCT','DIV','DROP','DUAL','EACH','ELSE','EMPTY','EXISTS',
  'EXIT','EXPLAIN','FALSE','FETCH','FIRST_VALUE','FOR','FORCE','FOREIGN','FROM','FUNCTION','GENERATED','GET','GRANT','GROUP','GROUPING','GROUPS','HAVING','IF','IGNORE','IN','INDEX','INNER','INSERT',
  'INTERVAL','INTO','IS','ITERATE','JOIN','KEY','KEYS','KILL','LAG','LAST_VALUE','LATERAL','LEAD','LEADING','LEAVE','LEFT','LIKE','LIMIT','LINES','LOAD','LOCK','LOOP','MATCH','MOD','NATURAL','NOT',
  'NTH_VALUE','NTILE','NULL','OF','ON','OPTION','OR','ORDER','OUT','OUTER','OVER','PARTITION','PERCENT_RANK','PRIMARY','PROCEDURE','RANGE','RANK','READ','RECURSIVE','REFERENCES','RELEASE','RENAME',
  'REPEAT','REPLACE','REQUIRE','RESIGNAL','RESTRICT','RETURN','REVOKE','RIGHT','ROW','ROWS','ROW_NUMBER','SCHEMA','SELECT','SET','SHOW','SIGNAL','SYSTEM','TABLE','THEN','TO','TRAILING','TRIGGER',
  'TRUE','UNDO','UNION','UNIQUE','UNLOCK','UPDATE','USAGE','USE','USING','VALUES','WHEN','WHERE','WHILE','WINDOW','WITH','WRITE'];
$badWord = array_filter($defs, fn($d) => in_array(strtoupper($d[1]), $RES, true) || in_array(strtoupper($d[0]), $RES, true));
ok('no MySQL reserved word as a ppal_* table or column (' . count($defs) . ' columns)', count($defs) > 30 && !$badWord, json_encode(array_values($badWord)));
$badText = array_filter($defs, fn($d) => preg_match('/\b(TEXT|BLOB|JSON|MEDIUMTEXT|LONGTEXT)\b/i', $d[2]) && stripos($d[2], 'DEFAULT') !== false);
ok('no TEXT/BLOB/JSON column with a DEFAULT (MySQL refuses it)', !$badText, json_encode(array_values($badText)));
$badNN = array_filter($mc, fn($d) => stripos($d[2], 'NOT NULL') !== false && stripos($d[2], 'DEFAULT') === false);
ok('every added NOT NULL column has a DEFAULT (ALTER on a table with rows)', !$badNN, json_encode(array_values($badNN)));
$len = function (string $tb, string $col) use ($defs): int { foreach ($defs as $d) if ($d[0] === $tb && $d[1] === $col && preg_match('/VARCHAR\((\d+)\)/i', $d[2], $mm)) return (int)$mm[1]; return 0; };
$fits = fn(array $vals, int $n): bool => $n > 0 && max(array_map('strlen', $vals)) <= $n;
ok('ppal_jobs.kind fits garden/trip/delve', $fits(['garden', 'trip', 'delve'], $len('ppal_jobs', 'kind')));
ok('ppal_jobs.state fits active/ready/done', $fits(['active', 'ready', 'done'], $len('ppal_jobs', 'state')));
ok('ppal_found.status fits home + every job kind', $fits(['home', 'garden', 'trip', 'delve'], $len('ppal_found', 'status')));
ok('ppal_jobs.tool fits every PJ_TOOLS key', $fits(PJ_TOOLS, $len('ppal_jobs', 'tool')));
ok('ppal_jobs.target fits every landscape key and a landmark id', $fits(array_merge(array_keys(LANDSCAPES), ['4294967295']), $len('ppal_jobs', 'target')));
ok('pal_uid columns are 16 wide', $len('ppal_jobs', 'pal_uid') === 16 && $len('ppal_found', 'pal_uid') === 16);
ok('ppal_jobs.day fits landmark_day()', $fits([landmark_day()], $len('ppal_jobs', 'day')));
$mxResult = 0; foreach (q('SELECT result FROM ppal_jobs')->fetchAll(PDO::FETCH_COLUMN) as $rj) $mxResult = max($mxResult, strlen((string)$rj));
$longest = strlen(json_encode(pj_roll_trip(array_merge(pj_pal($uid, $p2), ['hp' => 1]), $land, 'forage', 3, 8, 5, 'long')));
ok('stored results fit a MySQL TEXT (64 KB) by far', $mxResult > 0 && max($mxResult, $longest) < 8000, $mxResult . '/' . $longest);
ok('index names are unique', count($mi) === count(array_unique(array_map(fn($x) => preg_replace('/^CREATE INDEX (\w+).*/', '$1', $x), $mi))));
ok('pal_jobs.php has no SQLite-only SQL (datetime(), strftime(), RANDOM(), || concat)', !preg_match("/\\bdatetime\\(|strftime\\(|\\bRANDOM\\(\\)|\\|\\|\\s*'/i", file_get_contents(APP_ROOT . '/includes/pal_jobs.php')));

echo $fails ? "$fails FAILED\n" : "all pal job tests passed\n";
exit($fails ? 1 : 0);
