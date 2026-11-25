<?php
// 2.6.36: town uses (2.8.60: a note only, no daily limit) count by the gnome's game day, and place hours by the game hour. Run: php tests/game_time.php GAME_DIR (installed copy with a gnome)
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/gnome.php';
require_once $argv[1] . '/includes/game_clock.php';
require_once $argv[1] . '/includes/town.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
db_migrate(db(), 'sqlite');
$uid = (int)q_val("SELECT id FROM users ORDER BY id LIMIT 1");
set_setting('game_clock_on', '1'); setting('__reload__');
$setClock = function (int $day, int $min) use ($uid) { q('UPDATE users SET game_day = ?, game_minute = ? WHERE id = ?', [$day, $min, $uid]); $GLOBALS['CURRENT_USER'] = q_one('SELECT * FROM users WHERE id = ?', [$uid]); };

echo "== place hours follow the game hour\n";
$plaza = ['hours' => '18-23', 'months' => ''];
$setClock(10, 8 * 60);  ok('08:00 game time: Plaza closed', spot_closed($plaza) !== null);
$setClock(10, 20 * 60); ok('20:00 game time: Plaza open', spot_closed($plaza) === null);

echo "== daily uses follow the game day\n";
$setClock(10, 20 * 60); $d1 = town_use_day();
$setClock(11, 20 * 60); $d2 = town_use_day();
ok('a new game day is a new use day', $d1 !== $d2, "$d1 / $d2");
$setClock(10, 21 * 60);
ok('same game day, later hour: same use day', town_use_day() === $d1);
$aid = 987654;   // 2.8.60: town uses are only noted (no daily limit); the note still follows the game day
q('DELETE FROM town_uses WHERE user_id = ? AND action_id = ?', [$uid, $aid]);
$setClock(10, 20 * 60);
town_note_use($uid, $aid); town_note_use($uid, $aid);
ok('two dances the same game day: both noted on that day', (int)q_val('SELECT uses FROM town_uses WHERE user_id = ? AND action_id = ? AND day = ?', [$uid, $aid, $d1]) === 2);
$setClock(11, 20 * 60);
town_note_use($uid, $aid);
ok('after sleeping into the next game day it is a new day\'s note', (int)q_val('SELECT uses FROM town_uses WHERE user_id = ? AND action_id = ? AND day = ?', [$uid, $aid, $d2]) === 1);
q('DELETE FROM town_uses WHERE user_id = ? AND action_id = ?', [$uid, $aid]);
ok('NPC meetings still use the real day', town_day() === hollow_date('Y-m-d'));
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
