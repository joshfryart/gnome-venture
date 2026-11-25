<?php
// 2.8.53 Hollow jar sizing: the next weekly jar is sized by the larger of last week's helpers and the average of the last two weeks' helpers.
// php tests/hollow_sizing.php GAME_DIR (installed game; the suite adds its own scratch gnomes and jars).
$_SERVER['SCRIPT_NAME'] = '/community.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/hollow_goals.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

[$thisKey, $start] = hollow_goal_week();
$lastKey = hollow_date('o-\WW', $start - 86400);
[, $s2] = hollow_goal_week($start - 86400);
$beforeKey = hollow_date('o-\WW', $s2 - 86400);
ok('three different week keys', count(array_unique([$thisKey, $lastKey, $beforeKey])) === 3, "$thisKey $lastKey $beforeKey");
q('INSERT OR REPLACE INTO settings (name, value) VALUES (?, ?)', ['goal_per_gnome', '4']);
q('INSERT OR REPLACE INTO settings (name, value) VALUES (?, ?)', ['goal_min_share', '1']);
q('INSERT OR REPLACE INTO settings (name, value) VALUES (?, ?)', ['gourmand_open', '0']);

$uids = [];
for ($i = 1; $i <= 30; $i++) $uids[] = db_insert('users', ['username' => "hs$i", 'email' => "hs$i@x.local", 'password_hash' => 'x', 'onboarded' => 1, 'created_at' => now(), 'last_seen' => '2000-01-01 00:00:00']);

/** Replace the jar for a week key and give it $n helpers (the first $n scratch gnomes); null = no jar that week. */
function week(string $key, ?int $n): void
{
    global $uids;
    foreach (q('SELECT id FROM hollow_goals WHERE period_key = ?', ['week:' . $key])->fetchAll() as $g) { q('DELETE FROM hollow_goal_contrib WHERE goal_id = ?', [$g['id']]); q('DELETE FROM hollow_goals WHERE id = ?', [$g['id']]); }
    if ($n === null) return;
    $gid = db_insert('hollow_goals', ['period_key' => 'week:' . $key, 'kind' => 'any', 'filter' => '', 'title' => 'Scratch', 'icon' => 'x', 'target' => 100, 'progress' => 0, 'festival' => null,
        'starts_at' => '2000-01-01 00:00:00', 'ends_at' => '2000-01-08 00:00:00', 'created_at' => now()]);
    for ($i = 0; $i < $n; $i++) db_insert('hollow_goal_contrib', ['goal_id' => $gid, 'user_id' => $uids[$i], 'amount' => 5]);
}
week($thisKey, null); week($lastKey, null); week($beforeKey, null);
$seen = (int)q_val('SELECT COUNT(*) FROM users u WHERE u.onboarded = 1 AND u.deleted_at IS NULL AND u.last_seen > ? AND ' . gnome_in_play_sql('u'), [gmdate('Y-m-d H:i:s', time() - 7 * 86400)]);

echo "== no jars: falls back to gnomes seen in the last week\n";
ok('helpers 0', hollow_goal_last_helpers() === 0);
ok('sized by gnomes seen (floor 4)', hollow_goal_gnomes() === max(4, $seen), (string)hollow_goal_gnomes());

echo "== second-week sizing\n";
week($lastKey, 10);
ok('last 10, week before has no jar: 10', hollow_goal_last_helpers() === 10, (string)hollow_goal_last_helpers());
week($beforeKey, 20);
ok('last 10, before 20: average 15', hollow_goal_last_helpers() === 15, (string)hollow_goal_last_helpers());
week($beforeKey, 11);
ok('last 10, before 11: average rounds up to 11', hollow_goal_last_helpers() === 11, (string)hollow_goal_last_helpers());
week($lastKey, 20); week($beforeKey, 4);
ok('last 20, before 4: last week wins (20)', hollow_goal_last_helpers() === 20, (string)hollow_goal_last_helpers());
week($lastKey, 3); week($beforeKey, null);
ok('last 3, no week before: raw 3, jar sized for the floor 4', hollow_goal_last_helpers() === 3 && hollow_goal_gnomes() === 4, hollow_goal_last_helpers() . '/' . hollow_goal_gnomes());
week($lastKey, 8); week($beforeKey, 20);
ok('niche week (8) after a busy one (20): 14, not 8', hollow_goal_gnomes() === 14, (string)hollow_goal_gnomes());

echo "== the made jar's target\n";
foreach ([[10, 20, 15], [20, 4, 20], [6, null, 6]] as [$l, $b, $expect]) {
    week($lastKey, $l); week($beforeKey, $b); week($thisKey, null);
    $g = hollow_goal_make_weekly();
    $pool = hollow_goal_pool(); $per = $pool[crc32('hollowgoal|' . $thisKey) % count($pool)][4];
    $want = hollow_goal_round($per * HOLLOW_GOAL_SCALE * $expect);
    ok("last $l, before " . ($b ?? 'none') . ": jar target $want", (int)$g['target'] === $want, (string)$g['target']);
}
week($thisKey, null);

echo "== helpers who do not count\n";
week($lastKey, 10); week($beforeKey, null);
$gid = (int)q_val('SELECT id FROM hollow_goals WHERE period_key = ?', ['week:' . $lastKey]);
q('UPDATE users SET guest = 1 WHERE id = ?', [$uids[0]]);
q('UPDATE users SET banned = 1 WHERE id = ?', [$uids[1]]);
q('UPDATE users SET deleted_at = ? WHERE id = ?', [now(), $uids[2]]);
ok('guest, banned and deleted helpers are not counted (10 - 3)', hollow_goal_last_helpers() === 7, (string)hollow_goal_last_helpers());
q('UPDATE hollow_goal_contrib SET amount = 0 WHERE goal_id = ? AND user_id = ?', [$gid, $uids[3]]);
ok('a zero share is not helping', hollow_goal_last_helpers() === 6, (string)hollow_goal_last_helpers());

echo "== cleanup\n";
week($lastKey, null); week($beforeKey, null);
foreach ($uids as $id) q('DELETE FROM users WHERE id = ?', [$id]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
