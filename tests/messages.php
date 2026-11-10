<?php
// 2.6.37: messages (admin replies to feedback, player answers, the "!" count), the Tools error badge, and the Page code editor rules.
// Run: php tests/messages.php GAME_DIR   (an installed copy with an admin and one more player)
$_SERVER['SCRIPT_NAME'] = '/community.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/messages.php';
require_once $argv[1] . '/includes/admin_menu.php';
require_once $argv[1] . '/includes/code_edit.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
msg_boot();
$admin = q_one("SELECT * FROM users WHERE role = 'admin' ORDER BY id LIMIT 1");
$pl = q_one("SELECT * FROM users WHERE role <> 'admin' AND guest = 0 ORDER BY id LIMIT 1");
$uid = (int)$pl['id'];
q('DELETE FROM feedback_replies'); q('DELETE FROM feedback'); q('DELETE FROM notices WHERE user_id = ?', [$uid]);

echo "== thread\n";
$tid = db_insert('feedback', ['user_id' => $uid, 'page' => 'garden.php', 'body' => 'The bean is stuck', 'created_at' => now()]);
ok('a new note waits for the admin', msg_admin_new() === 1 && msg_unread($uid) === 0);
[$k, $m] = msg_admin_reply($admin, $tid, ' ');
ok('empty reply refused', !$k);
[$k, $m] = msg_admin_reply($admin, $tid, 'Fixed in the next update <b>');
ok('admin reply sent', $k, $m);
ok('thread is dealt with, player has 1 unread', msg_admin_new() === 0 && msg_unread($uid) === 1);
ok('player got a notice', (int)q_val('SELECT COUNT(*) FROM notices WHERE user_id = ? AND seen = 0', [$uid]) === 1);
$html = msg_thread_html(q_one('SELECT * FROM feedback WHERE id = ?', [$tid]), msg_replies([$tid])[$tid], false);
ok('bubbles: both messages, html escaped', str_contains($html, 'The bean is stuck') && str_contains($html, '&lt;b&gt;') && substr_count($html, 'class="msg ') === 2);
msg_mark_seen($uid);
ok('opening Messages clears the !', msg_unread($uid) === 0);

echo "== player answers\n";
[$k, $m] = msg_player_reply($pl, $tid, 'Thank you');
ok('player reply sent', $k, $m);
ok('thread is new for the admin again', msg_admin_new() === 1);
[$k] = msg_player_reply($admin, $tid, 'not my thread');
ok('cannot reply in someone else’s thread', !$k);
[$k] = msg_player_reply($pl, $tid, str_repeat('x', MSG_MAX + 1));
ok('too long refused', !$k);
set_setting('feedback_replies_per_day', '1'); setting('__reload__');
[$k] = msg_player_reply($pl, $tid, 'one more');
ok('daily reply limit holds', !$k);
set_setting('feedback_replies_per_day', '20'); setting('__reload__');

echo "== admin writes first\n";
[$k, $m, $nid] = msg_admin_start($admin, 'nobody-here', 'hello');
ok('unknown player refused', !$k);
[$k, $m, $nid] = msg_admin_start($admin, (string)$pl['username'], 'Hello from the keeper');
ok('started', $k && $nid > 0, $m);
ok('player sees it unread, admin has nothing new from it', msg_unread($uid) === 1 && (string)q_val('SELECT status FROM feedback WHERE id = ?', [$nid]) === 'done');
ok('threads newest first', (int)msg_threads_for($uid)[0]['id'] === $nid);
$html = msg_thread_html(q_one('SELECT * FROM feedback WHERE id = ?', [$nid]), msg_replies([$nid])[$nid], false);
ok('no empty first bubble', substr_count($html, 'class="msg ') === 1);

echo "== tools badge\n";
$log = APP_ROOT . '/data/error-log.txt'; $keep = is_file($log) ? file_get_contents($log) : null;
file_put_contents($log, '');
ok('empty log: 0, badge ok', admin_error_count() === 0 && admin_menu_badges()['boot'][0] === 'ok');
file_put_contents($log, "[2026-11-10 10:00:00 UTC] GET /x.php\nBoom\n\n[2026-11-10 10:01:00 UTC] GET /y.php\nBang\n\n");
$b = admin_menu_badges()['boot'];
ok('2 entries: badge says 2 errors, red', admin_error_count() === 2 && str_contains($b[0], '2 errors') && $b[1] === 'poor', json_encode($b));
if ($keep === null) unlink($log); else file_put_contents($log, $keep);

echo "== page code\n";
ok('config.php never', code_resolve('config.php') === null && !code_path_ok('config.php'));
ok('no climbing out', !code_path_ok('../x.php') && !code_path_ok('includes/../config.php') && !code_path_ok('data/game.sqlite') && !code_path_ok('uploads/a.php') && !code_path_ok('/etc/passwd'));
ok('a game page opens', code_resolve('community.php') !== null && code_resolve('includes/messages.php') !== null && code_resolve('assets/style.css') !== null);
$all = array_merge(...array_values(code_files()));
ok('picker lists pages, not config or data', in_array('garden.php', $all, true) && in_array('admin/index.php', $all, true) && !in_array('config.php', $all, true));
file_put_contents(APP_ROOT . '/zz_codetest.php', "<?php\necho 'one';\n");
$h = sha1(file_get_contents(APP_ROOT . '/zz_codetest.php'));
[$k, $m] = code_save('zz_codetest.php', "<?php\necho 'two'\n", $h);
ok('broken PHP refused, file untouched', !$k && str_contains($m, 'line') && str_contains(file_get_contents(APP_ROOT . '/zz_codetest.php'), 'one'), $m);
[$k, $m] = code_save('zz_codetest.php', "<?php\r\necho 'two';\r\n", 'stale');
ok('stale copy refused', !$k);
[$k, $m] = code_save('zz_codetest.php', "<?php\r\necho 'two';\r\n", $h);
ok('good PHP saved, line ends kept', $k && file_get_contents(APP_ROOT . '/zz_codetest.php') === "<?php\necho 'two';\n", $m);
$bk = code_backups('zz_codetest.php');
ok('old version kept', count($bk) === 1 && str_contains(file_get_contents(code_backup_dir() . '/' . $bk[0]['name']), 'one'));
[$k, $m] = code_restore('zz_codetest.php', $bk[0]['name']);
ok('put back', $k && str_contains(file_get_contents(APP_ROOT . '/zz_codetest.php'), 'one'), $m);
[$k] = code_restore('zz_codetest.php', '../config.php');
ok('restore only from its own backups', !$k);
foreach (code_backups('zz_codetest.php') as $b) unlink(code_backup_dir() . '/' . $b['name']);
unlink(APP_ROOT . '/zz_codetest.php');

q('DELETE FROM feedback_replies'); q('DELETE FROM feedback');
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);
