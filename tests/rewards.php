<?php
// Reward wrapper: give_petals / take_petals / give_xp. Run by rewards.sh on the world walk.sh made (player "sprout"): php rewards.php GAME
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
set_exception_handler(function (Throwable $e) { echo '  FAIL uncaught ' . get_class($e) . ': ' . $e->getMessage() . ' at ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$other = (int)q_val("SELECT id FROM users WHERE id <> ? ORDER BY id LIMIT 1", [$uid]);
$c = fn(int $id = 0) => (int)q_val('SELECT coins FROM users WHERE id = ?', [$id ?: $uid]);
q('UPDATE users SET coins = 100 WHERE id = ?', [$uid]);
$oc = $other ? $c($other) : 0;

echo "== give_petals\n";
ok('give 0 false', give_petals($uid, 0) === false);
ok('give negative false', give_petals($uid, -5) === false);
ok('unchanged after 0/neg', $c() === 100, (string)$c());
ok('give 25 true', give_petals($uid, 25, 'test') === true);
ok('100 + 25 = 125', $c() === 125, (string)$c());
ok('unknown user false', give_petals(999999999, 10) === false);
if ($other) ok('other gnome untouched', $c($other) === $oc);

echo "== take_petals\n";
ok('take 0 false', take_petals($uid, 0) === false);
ok('take negative false', take_petals($uid, -5) === false);
ok('unchanged after 0/neg', $c() === 125, (string)$c());
ok('take more than held false', take_petals($uid, 126) === false);
ok('not enough leaves coins', $c() === 125, (string)$c());
ok('take 25 true', take_petals($uid, 25, 'test') === true);
ok('125 - 25 = 100', $c() === 100, (string)$c());
ok('take exact true', take_petals($uid, 100) === true);
ok('exact leaves 0', $c() === 0, (string)$c());
ok('take from 0 false', take_petals($uid, 1) === false);
ok('still 0', $c() === 0);

echo "== inside a transaction (rollback undoes it)\n";
q('UPDATE users SET coins = 50 WHERE id = ?', [$uid]);
db()->beginTransaction();
ok('take 30 in tx', take_petals($uid, 30));
ok('give 5 in tx', give_petals($uid, 5));
db()->rollBack();
ok('rolled back to 50', $c() === 50, (string)$c());

echo "== give_xp = add_xp\n";
$xp0 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$r = give_xp($uid, 3, 'rewards_test');
$xp1 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
ok('xp rose by at least 3 (or level-up reset)', $xp1 !== $xp0 || $r !== null, "$xp0 -> $xp1");
ok('reward_log is callable and silent', (function () { ob_start(); reward_log('xp', 1, 1, 'x'); return ob_get_clean() === ''; })());

echo $fails ? "FAILS: $fails\n" : "all ok\n";
exit($fails ? 1 : 0);
