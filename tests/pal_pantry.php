<?php
// 2.7.06 (Josh): a pal tends the Pantry's jars: collects ready jars, fills free ones (never-made recipes first), no energy, jar timers in game days.
// php tests/pal_pantry.php GAME_DIR   (an installed game, player "sprout"; tests/ci_suites.sh installs it with walk.sh first)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/crafting.php';
require_once $argv[1] . '/includes/pal_jobs.php';
require_once $argv[1] . '/includes/pantry.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
ppal_ensure();
$p1 = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
q('DELETE FROM garden_buildings WHERE plot_id IN (SELECT id FROM plots WHERE user_id = ?)', [$uid]);
q("INSERT INTO garden_buildings (plot_id, building, built_at, last_collect, level, pantry) VALUES (?, 'kitchen', ?, ?, 1, 1)", [$p1, now(), now()]);
q('DELETE FROM pantry_jars WHERE user_id = ?', [$uid]);
ok('the gnome has jars', pantry_jar_limit($uid) >= 1, (string)pantry_jar_limit($uid));
// two pantry recipes of the same room (kind): one never made, one made often; ingredients for both
$recs = q("SELECT * FROM recipes WHERE category = 'pantry' ORDER BY id")->fetchAll(); $byKind = [];
foreach ($recs as $r) { $k = pantry_kind($r); if (count(json_decode((string)$r['ingredients'], true) ?: []) <= 3) $byKind[$k][] = $r; }
$pair = null; foreach ($byKind as $k => $list) if (count($list) >= 2) { $pair = [$list[0], $list[1]]; break; }
ok('two pantry recipes of one kind to test with', (bool)$pair);
[$old, $new] = $pair;
foreach ([$old, $new] as $r) { q('INSERT OR IGNORE INTO user_recipes (user_id, recipe_id, learned_at, made) VALUES (?, ?, ?, 0)', [$uid, $r['id'], now()]);
    foreach (json_decode((string)$r['ingredients'], true) as $slug => $qn) { $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]); give_item($uid, $iid, $qn * 40); } }
q('UPDATE user_recipes SET made = 9 WHERE user_id = ? AND recipe_id = ?', [$uid, $old['id']]); q('UPDATE user_recipes SET made = 0 WHERE user_id = ? AND recipe_id = ?', [$uid, $new['id']]);
$energy0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
pj_pantry_tick($uid, ['id' => 0]);
$jars = q('SELECT recipe_id, COUNT(*) AS n FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL GROUP BY recipe_id', [$uid])->fetchAll(PDO::FETCH_KEY_PAIR);
$perKind = []; foreach (q('SELECT r.id, j.n FROM recipes r JOIN (SELECT recipe_id, COUNT(*) AS n FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL GROUP BY recipe_id) j ON j.recipe_id = r.id', [$uid])->fetchAll() as $row) { $rr = q_one('SELECT * FROM recipes WHERE id = ?', [$row['id']]); $perKind[pantry_kind($rr)] = ($perKind[pantry_kind($rr)] ?? 0) + (int)$row['n']; }
ok('the pal filled the free jars, never more than a room holds', array_sum($jars) >= 2 && max($perKind) <= pantry_jar_limit($uid), json_encode([$jars, $perKind]));
ok('the never-made recipe got a jar, and so did the other one (one of each per pass)', ($jars[(int)$new['id']] ?? 0) >= 1 && ($jars[(int)$old['id']] ?? 0) >= 1, json_encode($jars));
ok('the never-made recipe got at least as many jars as the often-made one', ($jars[(int)$new['id']] ?? 0) >= ($jars[(int)$old['id']] ?? 0), json_encode($jars));
ok('no energy was spent', (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $energy0);
ok('jar timers run on game days when the sleep-days clock is on (ready_day set)', !gclock_on() || (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND ready_day IS NOT NULL', [$uid]) === array_sum($jars));
$n0 = array_sum($jars); pj_pantry_tick($uid, ['id' => 0]);
ok('a second look with nothing ready and no free jar starts nothing', (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL', [$uid]) === $n0);
q('UPDATE users SET game_day = game_day + 30 WHERE id = ?', [$uid]);   // thirty sleeps later every jar is ready
$col0 = (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND collected_at IS NOT NULL', [$uid]);
pj_pantry_tick($uid, ['id' => 0]);
$col1 = (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND collected_at IS NOT NULL', [$uid]);
ok('the ready jars were collected (into the satchel) and the free jars refilled', $col1 - $col0 >= $n0 && (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL', [$uid]) >= 2, json_encode([$col0, $col1, $n0]));
// 2.7.xx: a tending pal also checks the jars when you LOOK at them (Pantry page, craft map, Kitchen card), not only on the Jobs page
q('DELETE FROM pantry_jars WHERE user_id = ?', [$uid]);   // every jar free again
db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => 'test-pal', 'kind' => 'station', 'target' => 'pantry:all', 'plot_id' => null, 'day' => landmark_day(), 'tool' => 'jars',
    'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() + 3600), 'last_tick' => now(), 'potions' => 0, 'state' => 'active', 'result' => json_encode(['full' => false, 'jars' => true, 'hp' => 5, 'rounds' => 0, 'area' => 'pantry', 'obj' => 'Pantry', 'started' => 0, 'collected' => 0])]);
foreach ([$old, $new] as $r) foreach (json_decode((string)$r['ingredients'], true) as $slug => $qn) { $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]); give_item($uid, $iid, $qn * 6); }
pj_settle_pantry($uid);
ok('looking at the Pantry makes a tending pal refill the free jars (pj_settle_pantry)', (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL', [$uid]) >= 2, (string)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ?', [$uid]));
echo $fails ? "$fails FAILED\n" : "ok\n"; exit($fails ? 1 : 0);
