<?php
// v1.2.0: player mentors, server-side checks. Run by mentors120.sh on a fresh install (temp copy, SQLite).
// usage: php mentors120.php GAME xp UID N   -> "gain=<newcomer xp gained> mentor=<mentor xp gained> level=<level>"
//        php mentors120.php GAME grad LINKID -> "graduated=0|1"
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/mentors120.php';
$cmd = $argv[2];
if ($cmd === 'xp') {
    $uid = (int)$argv[3]; $n = (int)$argv[4];
    $l = mentors120_link_of($uid);
    $mid = $l ? (int)$l['mentor_id'] : 0;
    $x0 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
    $m0 = $mid ? (int)q_val('SELECT xp FROM users WHERE id = ?', [$mid]) : 0;
    add_xp($uid, $n, 'test');
    echo 'gain=' . ((int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]) - $x0) . ' mentor=' . ($mid ? (int)q_val('SELECT xp FROM users WHERE id = ?', [$mid]) - $m0 : 0)
        . ' level=' . (int)q_val('SELECT level FROM users WHERE id = ?', [$uid]) . "\n";
} elseif ($cmd === 'grad') {
    echo 'graduated=' . (mentors120_graduate((int)$argv[3]) ? 1 : 0) . "\n";
} elseif ($cmd === 'upgrade') {
    mentors120_upgrade(); mentors120_upgrade();
    echo 'pages=' . (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key LIKE 'pmentor:%'") . "\n";
}
