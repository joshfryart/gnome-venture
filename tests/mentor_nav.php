<?php
// 2.7.06 (Josh): every town (market / hub node) whose region has a calling mentor shows the Mentor button; rest stops, villages and other places never do.
// php tests/mentor_nav.php GAME_DIR (an installed game; walk.sh installs one).
$_SERVER['SCRIPT_NAME'] = '/here.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/here_view.php';
require_once $argv[1] . '/includes/calling_quests.php';
ensure_calling_mentors();
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . json_encode($got) . ')') . "\n"; if (!$ok) $bad++; }
foreach (CALLING_MENTORS as $calling => $m) {
    $town = q_one("SELECT l.* FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code = ? AND l.kind IN ('market','hub') ORDER BY l.id LIMIT 1", [$m[5]]);
    if (!$town) { chk($calling . ': the region has a town node', false); continue; }
    $nav = here_mentor_nav($town);
    chk($m[0] . ' in ' . $town['name'] . ': one Mentor button', count($nav) === 1 && $nav[0]['label'] === 'Mentor', $nav);
    chk($m[0] . ': the button opens the lodge spot or the mentor page', $nav && (str_contains($nav[0]['href'], 'town.php?spot=') || str_contains($nav[0]['href'], 'mentor.php?m=' . $m[1])), $nav);
    $stop = q_one("SELECT l.* FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code = ? AND l.kind = 'village' ORDER BY l.id LIMIT 1", [$m[5]]);
    if ($stop) chk($m[0] . ': a rest stop / village in the region has no Mentor button', here_mentor_nav($stop) === [], here_mentor_nav($stop));
}
$other = q_one("SELECT l.* FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code NOT IN ('EE','CA','NWE','SE','SA','CB') AND l.kind = 'market' ORDER BY l.id LIMIT 1");
if ($other) chk('a town with no calling mentor has no Mentor button', here_mentor_nav($other) === [], here_mentor_nav($other));
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
