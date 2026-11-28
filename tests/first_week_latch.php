<?php
// 2.8.90: a First Week goal that was met stays ticked (first_week_ticks), even when what it counted is reset later (Almanac pages re-marked unread).
// Usage: php tests/first_week_latch.php GAME_DIR  (an installed copy with player "sprout")
$game = $argv[1];
chdir($game);
require $game . '/includes/bootstrap.php';
require_once $game . '/includes/first_week.php';
$fail = 0;
$ok = function (string $n, bool $c) use (&$fail) { echo ($c ? 'ok   ' : 'FAIL ') . $n . "\n"; if (!$c) $fail++; };
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
q('DELETE FROM first_week_ticks WHERE user_id = ?', [$uid]);
q('UPDATE user_encyclopedia SET read_at = NULL WHERE user_id = ?', [$uid]);
$ok('no pages read: the goal is not met', first_week_check($uid, 'read') === false);
$ok('...and nothing is written down', (int)q_val("SELECT COUNT(*) FROM first_week_ticks WHERE user_id = ? AND task = 'read'", [$uid]) === 0);
$ids = q('SELECT entry_id FROM user_encyclopedia WHERE user_id = ? AND unlocked_at IS NOT NULL ORDER BY entry_id LIMIT 3', [$uid])->fetchAll(PDO::FETCH_COLUMN);
foreach ($ids as $id) q('UPDATE user_encyclopedia SET read_at = ? WHERE user_id = ? AND entry_id = ?', [now(), $uid, $id]);
$ok('three pages read: met', first_week_check($uid, 'read') === true);
q('UPDATE user_encyclopedia SET read_at = NULL WHERE user_id = ?', [$uid]);
$ok('pages marked unread again: still ticked', first_week_check($uid, 'read') === true);
$ok('the check itself would say no now', first_week_check_now($uid, 'read') === false);
q('DELETE FROM first_week_ticks WHERE user_id = ?', [$uid]);
exit($fail ? 1 : 0);
