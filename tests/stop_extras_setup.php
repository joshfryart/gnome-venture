<?php
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php'; require_once $argv[1] . '/includes/local.php'; require_once $argv[1] . '/includes/stop_pass.php'; require_once $argv[1] . '/includes/stop_adopt.php'; require_once $argv[1] . '/includes/adventure.php';
set_setting('stop_adopt_limit','1'); set_setting('gnav_on','1'); setting('__reload__');
q("UPDATE expeditions SET status='done'");
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $n = null;
foreach (stop_road_stops() as $rs) { if (!$rs['on_road']) continue; $c = q_one('SELECT * FROM locations WHERE id = ?', [$rs['id']]); if (stop_pool($c, null, (int)$u['id'])['tiers']) { $n = $c; break; } }
q('DELETE FROM stop_adoptions WHERE location_id = ?', [$n['id']]);
q('INSERT INTO stop_adoptions (location_id, user_id, founder_id, tier, pool, adopted_at, upkeep_month, upkeep_pool) VALUES (?,?,?,?,?,?,?,?)', [$n['id'], $u['id'], $u['id'], stop_top_tier(), '{}', gmdate('Y-m-d H:i:s'), stop_upkeep_month(), '{}']);
q('UPDATE users SET location_id = ?, location = ?, energy = 900, coins = 5000 WHERE id = ?', [$n['id'], $n['region'], $u['id']]);
echo $n['name'], "\n";
