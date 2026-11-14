<?php
// Seed for tests/pfv1_belt.js: php tests/pfv1_belt_seed.php GAMEDIR. Sprout (admin, level 9, Stitched belt = 3 slots): starter packed, belt [axe, till, rod], the axe worn out, the rod gone from the satchel.
$G = $argv[1]; $_SERVER['SCRIPT_NAME'] = '/puzzlebox.php'; require $G . '/includes/bootstrap.php'; require_once $G . '/includes/adventure.php'; require_once $G . '/includes/pfight_game.php'; require_once $G . '/includes/pfdeck.php';
q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_open', '1')"); q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_mode', 'board')"); q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_v1', 'admin')"); setting('__reload__'); pfd_ensure_content();
q("UPDATE users SET energy = 100, tour_step = 99, role = 'admin', level = 9 WHERE username = 'sprout'"); $uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
q('DELETE FROM pf_belts WHERE user_id = ?', [$uid]); q('DELETE FROM pf_tool_wear WHERE user_id = ?', [$uid]); q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$uid]); q('DELETE FROM pf_decks WHERE user_id = ?', [$uid]); q('UPDATE expeditions SET encounter = NULL');
foreach (['hatchet', 'worn-trowel', 'willow-fishing-rod', 'stitched-fight-belt'] as $s) { $i = item_id_by_slug($s); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $i]); give_item($uid, $i, 1); }
$k = item_id_by_slug(PFD_REPAIR); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $k]); give_item($uid, $k, 1);
tool_cache_reset(); pfd_set_starter($uid, 'kind'); pfd_belt_save($uid, ['axe', 'till', 'rod']); pfd_wear_add($uid, ['axe' => 20]);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, item_id_by_slug('willow-fishing-rod')]); tool_cache_reset();
echo json_encode(array_column(pfd_deck($uid)['belt'], 'state', 'type')), "\n";
