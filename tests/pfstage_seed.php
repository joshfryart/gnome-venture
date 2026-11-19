<?php
// php tests/pfstage_seed.php GAME KIND : put the test gnome (sprout) in front of a waiting creature on each page that can carry .pfover (tests/pfstage.js layout checks).
//   KIND = delve | lair | wander | trail   (delve and lair start at the first such landmark; wander is an explore walk; trail is a tile walk from the market)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/landmarks.php';
require_once APP_ROOT . '/includes/pfdeck.php';
$kind = $argv[2] ?? 'wander';
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$uid]);
q('UPDATE users SET level = 40, energy = 500, stat_grit = 30, stat_hardiness = 30, stat_nimble = 30 WHERE id = ?', [$uid]);
q('DELETE FROM landmark_uses WHERE user_id = ?', [$uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
if ($kind === 'delve' || $kind === 'lair') {
    $lm = q_one("SELECT * FROM landmarks WHERE kind = ? ORDER BY id LIMIT 1", [$kind]);
    q('UPDATE users SET location_id = ? WHERE id = ?', [(int)$lm['location_id'], $uid]); $u['location_id'] = $lm['location_id'];
    [$ok, $m] = $kind === 'delve' ? delve_start($u, (int)$lm['id']) : lair_start($u, (int)$lm['id']);
    if (!$ok) { echo "FAIL $m\n"; exit(1); }
} elseif ($kind === 'trail') {
    require_once APP_ROOT . '/includes/trail_tiles.php';
    set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); setting('__reload__');
    $mk = (int)q_val("SELECT id FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1");
    q('UPDATE users SET location_id = ? WHERE id = ?', [$mk, $uid]); $u['location_id'] = $mk;
    [$ok, $m] = start_expedition($u, (int)visible_routes($u, $mk)[0]['id']);
    if (!$ok) { echo "FAIL $m\n"; exit(1); }
} else {
    q("UPDATE users SET location_id = (SELECT id FROM locations WHERE kind = 'market' ORDER BY id LIMIT 1) WHERE id = ?", [$uid]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    [$ok, $m] = explore_start($u);
    if (!$ok) { echo "FAIL $m\n"; exit(1); }
}
$exp = active_expedition($uid);
$c = q_one("SELECT * FROM creatures WHERE size = 'small' ORDER BY level, id LIMIT 1");
$exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
save_exp($exp); q('UPDATE expeditions SET hp = 60, max_hp = 60 WHERE id = ?', [$exp['id']]);
pfd_ensure(); pfd_row($uid);
echo "ok $kind {$exp['kind']} {$c['name']}\n";
