<?php
// v1.0.0 review fixes (C1, H1-H4, M7-M10): run by fix100.sh on a fresh install (temp copy, SQLite).
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/pals.php';
require_once $argv[1] . '/includes/trade.php';
require_once $argv[1] . '/includes/hollow_goals.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function clone_user(string $name, string $gnome): int {
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $r['username'] = $name; $r['email'] = $name . '@b.local'; $r['gnome_name'] = $gnome; $r['active_plot_id'] = null; $r['last_seen'] = now(); $r['level'] = 20; $r['coins'] = 5000;
    $id = db_insert('users', $r);
    return $id;
}

echo "== C1: the critter column is not a reserved word\n";
ok('garden_critters.held exists', (bool)q_val("SELECT COUNT(*) FROM pragma_table_info('garden_critters') WHERE name = 'held'"));
ok('no column called stored', !q_val("SELECT COUNT(*) FROM pragma_table_info('garden_critters') WHERE name = 'stored'"));

echo "== H1: settings defaults\n";
ok('schema is the same array each call', settings_schema() === settings_schema());
ok('a 1.0.0 default is read without a row', setting('goal_min_share') === '1');

echo "== H4: upgrade steps flagged, nothing failed\n";
foreach (UPGRADE_100_STEPS as $n => [$flag]) ok("step $n done ($flag)", setting($flag) === '1');
ok('no failed steps', upgrade_100_failed() === []);
ok('running a done step is a no-op', upgrade_100_run_step('stops') === true);
ok('stop_sets unique key holds', !q_val('SELECT COUNT(*) FROM (SELECT 1 FROM stop_sets GROUP BY scope, target, need HAVING COUNT(*) > 1) x'));
$before = (int)q_val('SELECT COUNT(*) FROM stop_sets');
set_setting('fresh_hold_days', '0'); set_setting('fresh_hold_level', '1'); setting('__reload__');   // v1.0.1: these gnomes are brand new; the hold has its own suite (fresh_hold.sh)
set_setting('upg100_stops', '0'); setting('__reload__');
ok('re-running a step adds no duplicates', upgrade_100_run_step('stops') && (int)q_val('SELECT COUNT(*) FROM stop_sets') === $before && setting('upg100_stops') === '1');

echo "== H2/M7/M8/M9/M10: friends\n";
$a = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$ua = q_one('SELECT * FROM users WHERE id = ?', [$a]);
$b = clone_user('friendb', 'Twin');
$c = clone_user('twinc', 'Twin');           // a namesake
$d = clone_user('Twin', 'Dee');             // a login name equal to the gnome name
q('UPDATE users SET onboarded = 1 WHERE id IN (?, ?, ?)', [$b, $c, $d]);
$f = find_player('Twin', $a);
ok('gnome-name match wins over a login name', $f && (int)$f['id'] === $b, json_encode($f));
ok('Find tab: gnome names only', !find_player('twinc', $a, false) && find_player('Twin', $a, false));
q('UPDATE users SET level = 20, coins = 1000 WHERE id = ?', [$a]);
$ua = q_one('SELECT * FROM users WHERE id = ?', [$a]);
q("INSERT INTO player_friends (user_id, friend_id, status, created_at, answered_at) VALUES (?, ?, 'accepted', ?, ?)", [$a, $c, now(), now()]);
$seed = (int)q_val("SELECT id FROM items WHERE category = 'seed' AND tradable = 1 ORDER BY id LIMIT 1");
give_item($a, $seed, 5);
[$ok, $msg] = pal_gift($ua, $c, $seed, 1, 'grow');
ok('pal gift goes to the friend by id, not the first namesake', $ok && (int)q_val('SELECT to_id FROM gifts ORDER BY id DESC LIMIT 1') === $c, $msg);
[$ok2] = pal_gift($ua, $c, $seed, 1, 'grow');
ok('second gift the same day refused (claim row)', !$ok2);
ok('claim row exists', (int)q_val('SELECT COUNT(*) FROM pal_gift_days WHERE from_id = ? AND to_id = ?', [$a, $c]) === 1);

[$ok] = pal_request($ua, $b);
ok('request sent', $ok);
pal_cancel($ua, $b);
ok('cancel keeps a cancelled row', q_val('SELECT status FROM player_friends WHERE user_id = ? AND friend_id = ?', [$a, $b]) === 'cancelled');
$n0 = (int)q_val('SELECT COUNT(*) FROM notices WHERE user_id = ?', [$b]);
[$ok] = pal_request($ua, $b);
ok('re-asking straight after a cancel is refused', !$ok && (int)q_val('SELECT COUNT(*) FROM notices WHERE user_id = ?', [$b]) === $n0);

q("INSERT INTO player_friends (user_id, friend_id, status, created_at, answered_at) VALUES (?, ?, 'accepted', ?, ?)", [$a, $d, now(), now()]);
$cnt = pal_count($a);
q("UPDATE users SET deleted_at = ?, banned = 1 WHERE id = ?", [now(), $d]);
ok('a deleted gnome no longer counts as a friend', pal_count($a) === $cnt - 1 && !in_array($d, pal_friend_ids($a), true));

// privacy: friend list on a public profile names open gardens only
q('UPDATE users SET garden_public = 1 WHERE id = ?', [$a]);
q('UPDATE users SET garden_public = 0 WHERE id = ?', [$c]);
$g = q_one('SELECT * FROM users WHERE id = ?', [$a]);
$html = pal_profile_list($g, false, false);
ok('a private-garden friend is not named to visitors', strpos($html, 'Twin') === false, $html);
ok('the owner still sees them', strpos(pal_profile_list($g, true, false), 'Twin') !== false);

// pulse
q('UPDATE users SET garden_public = 1, pulse_show = 1, last_seen = ? WHERE id = ?', [now(), $b]);
$p = hollow_pulse_build($ua);
ok('pulse names an open garden that has not opted out', in_array($b, array_column($p['about']['names'], 0), true));
pal_set_pulse($b, false);
$p = hollow_pulse_build($ua);
ok('pulse only counts a gnome who turned it off', !in_array($b, array_column($p['about']['names'], 0), true) && $p['about']['quiet'] >= 1);
pal_set_pulse($b, true);
q('INSERT INTO player_blocks (blocker_id, blocked_id, created_at) VALUES (?, ?, ?)', [$b, $a, now()]);
$p = hollow_pulse_build($ua);
ok('a blocked pair does not see each other in the pulse', !in_array($b, array_column($p['about']['names'], 0), true) && $p['about']['n'] === (int)q_val("SELECT COUNT(*) FROM users u WHERE u.last_seen > ? AND u.onboarded = 1 AND u.deleted_at IS NULL AND u.id <> ? AND u.id <> ? AND " . gnome_in_play_sql('u'), [gmdate('Y-m-d H:i:s', time() - 900), $a, $b]));
q('DELETE FROM player_blocks');

echo "== H3: selling back never beats buying\n";
$viol = 0; $n = 0; $why = [];
$FP = [0, 40, 80];   // friendship points with the shop's staff: none, some, lots (+ the weather vane for the last two)
foreach (q('SELECT st.item_id, st.shop_id, st.price_min FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE st.price_min > 0 AND i.category IN (\'produce\',\'flower\',\'food\',\'part\',\'forage\')')->fetchAll() as $s) {
    $it = q_one('SELECT * FROM items WHERE id = ?', [$s['item_id']]);
    $npc = (int)q_val('SELECT npc_id FROM npc_schedules WHERE shop_id = ? LIMIT 1', [$s['shop_id']]);
    foreach ($FP as $i => $pts) {
        if ($npc) { q('DELETE FROM npc_friends WHERE user_id = ? AND npc_id = ?', [$a, $npc]); if ($pts) q('INSERT INTO npc_friends (user_id, npc_id, points) VALUES (?, ?, ?)', [$a, $npc, $pts]); }
        q('UPDATE users SET ev_sale_until = ? WHERE id = ?', [$i ? gmdate('Y-m-d H:i:s', time() + 3600) : null, $a]);
        $u2 = q_one('SELECT * FROM users WHERE id = ?', [$a]);
        $n++;
        $buy = shop_price($u2, (int)$s['price_min'], (int)$s['shop_id'], (int)$s['item_id']);
        $sell = sell_price_with_bonus($it, $u2, 20);   // even with a +20% Journey bonus
        if ($sell > $buy) { $viol++; $why[] = $it['slug'] . ' pts' . $pts . ' buy ' . $buy . ' sell ' . $sell; }
    }
}
ok("sell (with bonus) <= cheapest buy after discounts, $n checks", $viol === 0, "violations=$viol " . implode("; ", array_slice($why, 0, 4)));
q('UPDATE users SET ev_sale_until = NULL WHERE id = ?', [$a]);
q('DELETE FROM npc_friends WHERE user_id = ?', [$a]);

echo "== account deletion leaves no ghosts\n";
q("INSERT INTO player_friends (user_id, friend_id, status, created_at, answered_at) VALUES (?, ?, 'accepted', ?, ?)", [$b, $c, now(), now()]);
q("UPDATE users SET password_hash = ? WHERE id = ?", [password_hash('x', PASSWORD_DEFAULT), $c]);
$uc = q_one('SELECT * FROM users WHERE id = ?', [$c]);
require_once $argv[1] . '/includes/account.php';
[$okd] = delete_account($uc, 'x', 'DELETE');
ok('deleted', $okd);
ok('their friend rows are gone', !q_val('SELECT 1 FROM player_friends WHERE user_id = ? OR friend_id = ?', [$c, $c]));

echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);
