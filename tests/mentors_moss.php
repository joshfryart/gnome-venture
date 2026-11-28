<?php
// 2.8.99c: every calling (class) mentor lives in Mossbottom, in the Mentors' Hall: reachable from the Mossbottom picture and its town cards, from anywhere;
// no region town offers a second mentor entry; old lodge rows stay (old links resolve); an install from before the move keeps every chapter and its progress.
// php tests/mentors_moss.php GAME_DIR   (an installed game, player "sprout")
$_SERVER['SCRIPT_NAME'] = '/here.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/here_view.php';
require_once $argv[1] . '/includes/place_ui.php';
require_once $argv[1] . '/includes/calling_quests.php';
require_once $argv[1] . '/includes/calling_view.php';
require_once $argv[1] . '/includes/friends.php';
require_once $argv[1] . '/includes/npc_life.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function card_of(string $h, string $id): string { return preg_match('~<dialog[^>]*id="hubpop-' . preg_quote($id, '~') . '".*?</dialog>~s', $h, $m) ? html_entity_decode($m[0]) : ''; }
/** Mentor slugs linked (mentor.php?m=...) in some HTML. */
function mentor_links(string $h): array { preg_match_all('~mentor\.php\?m=([a-z-]+)~', html_entity_decode($h), $m); $s = array_values(array_unique($m[1])); sort($s); return $s; }
$slugs = array_column(CALLING_MENTORS, 1); sort($slugs);
$hubLoc = here_hub_node();

echo "== an install from before the move (mentors in their region towns' lodges, a gnome part-way through a chapter)\n";
// Arrange: put every mentor back in their lodge as 0.9.4-2.8.98 made them, and give sprout an open chapter with progress
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u['id'];
foreach (CALLING_MENTORS as $calling => $m) {
    $town = (string)q_val('SELECT gnomish_name FROM regions WHERE code = ?', [$m[5]]);
    $loc = (int)q_val("SELECT id FROM locations WHERE region = ? AND kind = 'market' ORDER BY id LIMIT 1", [$town]);
    $sid = (int)q_val('SELECT id FROM town_spots WHERE slug = ?', [$m[6]]);
    if (!$sid) $sid = (int)db_insert('town_spots', ['slug' => $m[6], 'region' => $town, 'kind' => 'special', 'icon' => $m[7], 'name' => $m[8], 'description' => $m[9], 'hours' => '', 'months' => '', 'sort_order' => 8, 'active' => 1]);
    q('UPDATE town_spots SET region = ?, active = 1 WHERE id = ?', [$town, $sid]);
    if (!q_val('SELECT 1 FROM town_actions WHERE slug = ?', [$m[6] . '-link-mentor'])) db_insert('town_actions', ['spot_id' => $sid, 'slug' => $m[6] . '-link-mentor', 'label' => 'Talk to ' . $m[0], 'kind' => 'link', 'link' => 'mentor.php?m=' . $m[1], 'daily' => 0, 'sort_order' => 1, 'active' => 1]);
    q('UPDATE town_actions SET active = 1 WHERE slug = ?', [$m[6] . '-link-mentor']);
    $nid = (int)q_val('SELECT id FROM npcs WHERE slug = ?', [$m[1]]);
    q('UPDATE npcs SET home_location_id = ?, fav_spot_id = ? WHERE id = ?', [$loc, $sid, $nid]);
    q('UPDATE npc_schedules SET location_id = ?, spot_id = ? WHERE npc_id = ?', [$loc, $sid, $nid]);
}
$ch = q_one("SELECT * FROM calling_chapters WHERE calling = 'rootwarden' AND tier = 2 AND active = 1 ORDER BY id LIMIT 1");
q("UPDATE users SET calling = 'rootwarden', calling_qt = 0, calling_chapter = NULL, level = 40 WHERE id = ?", [$uid]);
$st = calling_start(q_one('SELECT * FROM users WHERE id = ?', [$uid]), (int)$ch['id']);
if (!$st[0]) {   // start needs the mentor here: stand in Birchbramble Steppe's market (the old lodge town) for it
    q("UPDATE users SET location = 'Birchbramble Steppe', location_id = (SELECT id FROM locations WHERE region = 'Birchbramble Steppe' AND kind = 'market' ORDER BY id LIMIT 1) WHERE id = ?", [$uid]);
    $st = calling_start(q_one('SELECT * FROM users WHERE id = ?', [$uid]), (int)$ch['id']);
}
q('UPDATE user_calling_tasks SET progress = 1 WHERE user_id = ? AND task_id = (SELECT MIN(id) FROM calling_tasks WHERE chapter_id = ?)', [$uid, (int)$ch['id']]);
$progBefore = q('SELECT task_id, progress, done_at FROM user_calling_tasks WHERE user_id = ? ORDER BY task_id', [$uid])->fetchAll();
$chapBefore = q('SELECT chapter_id, done_at FROM user_calling_chapters WHERE user_id = ? ORDER BY chapter_id', [$uid])->fetchAll();
$friendBefore = (int)q_val('SELECT COALESCE(SUM(points), 0) FROM npc_friends WHERE user_id = ?', [$uid]);
ok('arranged: sprout has the Rootwarden chapter open', $st[0] && (int)q_val('SELECT calling_chapter FROM users WHERE id = ?', [$uid]) === (int)$ch['id'], json_encode($st));
$lodgeIds = [];
foreach (CALLING_MENTORS as $m) $lodgeIds[$m[1]] = (int)q_val('SELECT id FROM town_spots WHERE slug = ?', [$m[6]]);

// Act: the boot step that runs on every upgrade (and on a fresh install)
ensure_calling_quests();

// Assert: nothing lost
ok('chapter progress rows unchanged', $progBefore === q('SELECT task_id, progress, done_at FROM user_calling_tasks WHERE user_id = ? ORDER BY task_id', [$uid])->fetchAll());
ok('chapter rows unchanged and the open chapter is still open', $chapBefore === q('SELECT chapter_id, done_at FROM user_calling_chapters WHERE user_id = ? ORDER BY chapter_id', [$uid])->fetchAll() && (int)q_val('SELECT calling_chapter FROM users WHERE id = ?', [$uid]) === (int)$ch['id']);
ok('mentor friendships unchanged', $friendBefore === (int)q_val('SELECT COALESCE(SUM(points), 0) FROM npc_friends WHERE user_id = ?', [$uid]));
ok('the old lodge rows are kept (ids stay valid for old links)', !in_array(0, $lodgeIds, true) && count(array_filter($lodgeIds, fn($id) => (bool)q_val('SELECT 1 FROM town_spots WHERE id = ?', [$id]))) === 6, json_encode($lodgeIds));

echo "== the Mentors' Hall in Mossbottom\n";
$hall = q_one("SELECT s.* FROM town_spots s WHERE s.region = ? AND s.active = 1 AND EXISTS (SELECT 1 FROM town_actions a WHERE a.spot_id = s.id AND a.kind = 'link' AND a.active = 1 AND a.link LIKE 'mentor.php?m=%')", [HUB_REGION]);
ok('one active Mossbottom spot holds the mentors', (bool)$hall);
$hallLinks = $hall ? q("SELECT link FROM town_actions WHERE spot_id = ? AND kind = 'link' AND active = 1", [(int)$hall['id']])->fetchAll(PDO::FETCH_COLUMN) : [];
ok('it links every calling mentor once', mentor_links(implode(' ', $hallLinks)) === $slugs && count($hallLinks) === 6, json_encode($hallLinks));
$moved = []; $atHall = [];
foreach (CALLING_MENTORS as $calling => $m) {
    $npc = calling_mentor($calling);
    $now = npc_now($npc);
    if (($now['town'] ?? '') !== HUB_REGION) $moved[] = $m[0] . ': ' . ($now['what'] ?? '?');
    if ($hall && (int)($now['spot']['id'] ?? 0) !== (int)$hall['id']) $atHall[] = $m[0];
    if ((int)$npc['home_location_id'] !== (int)$hubLoc['id']) $moved[] = $m[0] . ' home ' . $npc['home_location_id'];
}
ok('every mentor is in Mossbottom now (npc_now), at home there', !$moved, implode('; ', $moved));
ok('every mentor stands in the hall', $hall && !$atHall, implode(',', $atHall));
ok('calling_mentor_place names Mossbottom', (calling_mentor_place('seedkeeper')['region']['gnomish_name'] ?? '') === HUB_REGION, json_encode(calling_mentor_place('seedkeeper')));
ok('the hall\'s Who\'s here lists all six', $hall && count(array_intersect(array_column(npcs_at_spot($hall), 'slug'), $slugs)) === 6);

echo "== reachable from anywhere\n";
$places = q("SELECT * FROM locations WHERE kind IN ('market', 'village') AND region_id IS NOT NULL ORDER BY id")->fetchAll();
$miss = [];
foreach ([$places[0], $places[(int)(count($places) / 2)], end($places)] as $p) {
    q('UPDATE users SET location = ?, location_id = ? WHERE id = ?', [(string)$p['region'], (int)$p['id'], $uid]);
    $uu = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    foreach (CALLING_MENTORS as $calling => $m) if (!npc_here($uu, (int)calling_mentor($calling)['id'])) $miss[] = $m[0] . ' from ' . $p['name'];
}
ok('npc_here: every mentor can be talked to from a town and a rest stop anywhere', !$miss, implode('; ', array_slice($miss, 0, 6)));

echo "== the Mossbottom picture and cards\n";
$town = q_one("SELECT * FROM locations WHERE kind = 'market' AND region = 'Mistmoor' ORDER BY id LIMIT 1");
q('UPDATE users SET location = ?, location_id = ? WHERE id = ?', [(string)$town['region'], (int)$town['id'], $uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$GLOBALS['gnav_gate'] = false;
$h = here_hub_view($u);
ok('the Mossbottom picture has a Mentors button', str_contains($h, 'id="hs-mentors"'), substr($h, 0, 120));
$card = card_of($h, 'mentors');
ok('its card lists every calling mentor', mentor_links($card) === $slugs, json_encode(mentor_links($card)));
ok('its card opens the Mentors\' Hall page', $hall && str_contains($card, 'town.php?hub=1&spot=' . (int)$hall['id']));
ok('the card marks the gnome\'s own mentor', str_contains($card, 'Your mentor'));
ok('town.php?hub=1 lists the hall', $hall && in_array((int)$hall['id'], array_map('intval', array_column(town_spots(HUB_REGION), 'id')), true));

echo "== no second mentor entry in a region town\n";
$second = [];
foreach (q("SELECT * FROM locations WHERE kind = 'market' ORDER BY id")->fetchAll() as $t) {
    if (here_mentor_nav($t)) $second[] = $t['name'] . ' Mentor button';
    $GLOBALS['gnav_gate'] = false;
    $ht = here_view($u, $t);
    if (mentor_links($ht) || str_contains($ht, 'id="hs-mentor')) $second[] = $t['name'] . ' picture';
    foreach (town_spots((string)$t['region']) as $s) foreach (town_actions((int)$s['id']) as $a) if (str_contains((string)$a['link'], 'mentor.php')) $second[] = $t['name'] . ' spot ' . $s['slug'];
}
ok('no region town has a Mentor button, a lodge or a mentor link', !$second, implode('; ', array_slice($second, 0, 8)));
ok('the old lodges are off the region town squares', !q_val('SELECT COUNT(*) FROM town_spots WHERE active = 1 AND slug IN (' . implode(',', array_fill(0, 6, '?')) . ')', array_column(CALLING_MENTORS, 6)));

echo "== texts\n";
q("UPDATE users SET calling_chapter = NULL, calling_qt = 0 WHERE id = ?", [$uid]);
$line = calling_today_line(q_one('SELECT * FROM users WHERE id = ?', [$uid]));
ok('the Today line says Mossbottom', str_contains($line, 'in Mossbottom'), strip_tags($line));
$gl = calling_gnome_line(q_one('SELECT * FROM users WHERE id = ?', [$uid]));
ok('My Gnome: mentor in the Mentors\' Hall in Mossbottom, no free-trip button', str_contains($gl, 'Mossbottom') && !str_contains($gl, 'value="trip"'), strip_tags($gl));

echo "== idempotent\n";
$before = [(int)q_val('SELECT COUNT(*) FROM npcs'), (int)q_val('SELECT COUNT(*) FROM town_spots'), (int)q_val('SELECT COUNT(*) FROM npc_schedules'), (int)q_val('SELECT COUNT(*) FROM town_actions')];
ok('ensure_calling_mentors makes nothing new the second time', ensure_calling_mentors() === 0 && $before === [(int)q_val('SELECT COUNT(*) FROM npcs'), (int)q_val('SELECT COUNT(*) FROM town_spots'), (int)q_val('SELECT COUNT(*) FROM npc_schedules'), (int)q_val('SELECT COUNT(*) FROM town_actions')]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
