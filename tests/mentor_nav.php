<?php
// 2.7.06 (Josh): every town whose region had a calling mentor showed the Mentor button; rest stops, villages and other places never did.
// 2.8.99c: the calling mentors all live in Mossbottom now (the Mentors' Hall): only the hub has the Mentors button; no region town, rest stop or village has one.
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
    chk($m[0] . '\'s old town ' . $town['name'] . ': no Mentor button (the mentor lives in Mossbottom)', here_mentor_nav($town) === [], here_mentor_nav($town));
    $stop = q_one("SELECT l.* FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code = ? AND l.kind = 'village' ORDER BY l.id LIMIT 1", [$m[5]]);
    if ($stop) chk($m[0] . ': a rest stop / village in the region has no Mentor button', here_mentor_nav($stop) === [], here_mentor_nav($stop));
}
$hub = q_one("SELECT * FROM locations WHERE kind = 'hub' ORDER BY id LIMIT 1");
$hall = calling_mentor_hall();
$nav = $hub ? here_mentor_nav($hub) : [];
chk('Mossbottom: one Mentors button', count($nav) === 1 && $nav[0]['label'] === 'Mentors', $nav);
chk('Mossbottom: the button opens the Mentors\' Hall', $nav && $hall && str_contains($nav[0]['href'], 'town.php?hub=1&spot=' . (int)$hall['id']), $nav);
$other = q_one("SELECT l.* FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code NOT IN ('EE','CA','NWE','SE','SA','CB') AND l.kind = 'market' ORDER BY l.id LIMIT 1");
if ($other) chk('a town that never had a calling mentor has no Mentor button', here_mentor_nav($other) === [], here_mentor_nav($other));
echo $bad ? "$bad FAILED\n" : "all ok\n"; exit($bad ? 1 : 0);
