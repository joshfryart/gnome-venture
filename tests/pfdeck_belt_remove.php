<?php
// Puzzle box belt: "Remove" for a broken (worn-out) or gone tool. Database checks on an installed copy (player "sprout"); tests/pfdeck_belt_remove.sh installs one and runs this.
// php tests/pfdeck_belt_remove.php GAMEDIR
$G = $argv[1] ?? ''; if ($G === '') { echo "usage: php tests/pfdeck_belt_remove.php GAMEDIR\n"; exit(1); }
$_SERVER['SCRIPT_NAME'] = '/puzzlebox.php'; require $G . '/includes/bootstrap.php'; require_once $G . '/includes/adventure.php'; require_once $G . '/includes/pfight_game.php'; require_once $G . '/includes/pfdeck.php';
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$re = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$item = fn(string $slug, int $n = 1) => give_item($uid, item_id_by_slug($slug), $n);
q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_v1', 'admin')"); setting('__reload__'); pfd_ensure_content();
$belt = fn() => array_column(pfd_deck($uid)['belt'], 'type');
$states = fn() => array_column(pfd_deck($uid)['belt'], 'state', 'type');
$keys = fn() => array_column(pfd_fight_entries(pfd_sources($uid)), 'key');
$rows = fn(int $id) => q('SELECT tool_type FROM pf_belts WHERE user_id = ? ORDER BY slot', [$id])->fetchAll(PDO::FETCH_COLUMN);
chk('the starter is packed', pfd_set_starter($uid, 'kind') === null);
$item('hatchet'); $item('worn-trowel'); $item('willow-fishing-rod'); tool_cache_reset();
pfd_belt_save($uid, ['axe', 'till']); $e1 = pfd_equip_tool($uid, 'axe'); $e2 = pfd_equip_tool($uid, 'till'); chk('belt of two: axe and till', $e1 === null && $e2 === null && $belt() === ['axe', 'till'], [$e1, $e2, $belt()]);
chk('both tools\' pieces are in the fight deck', in_array('t:axe', $keys(), true) && in_array('t:till', $keys(), true), $keys());

// a broken tool clogs its slot
pfd_wear_add($uid, ['axe' => 20]);
chk('the axe is worn out: broken, still in slot 1', $states() === ['axe' => 'broken', 'till' => 'ok'], $states());
chk('its piece is already out of the fight deck', !in_array('t:axe', $keys(), true) && in_array('t:till', $keys(), true), $keys());
chk('the clog: the belt is full, the rod cannot come on', pfd_equip_tool($uid, 'rod') === 'Your belt is full (2 tools). Take one off first.');

// the guards
chk('an ok tool cannot be removed this way', pfd_remove_broken($uid, 'till') === 'Only a worn-out or missing tool can be removed. Use Take off for the others.' && $belt() === ['axe', 'till']);
chk('a tool that is not on the belt is refused', pfd_remove_broken($uid, 'rod') === 'That tool is not on your belt.' && pfd_remove_broken($uid, '') === 'That tool is not on your belt.' && pfd_remove_broken($uid, 'nope') === 'That tool is not on your belt.' && $belt() === ['axe', 'till']);
// another gnome's broken entry is not reachable
q("INSERT INTO users (username, email, password_hash, created_at) SELECT 'other', 'o@b.local', password_hash, created_at FROM users WHERE id = ?", [$uid]);
$oid = (int)q_val("SELECT id FROM users WHERE username = 'other'"); pfd_belt_save($oid, ['water']); q('INSERT INTO pf_tool_wear (user_id, tool_type, wear) VALUES (?, ?, 99)', [$oid, 'water']);
chk('another gnome\'s entry: refused for me, theirs is untouched', pfd_remove_broken($uid, 'water') === 'That tool is not on your belt.' && $rows($oid) === ['water'] && $belt() === ['axe', 'till']);

// the removal
$wearBefore = (int)q_val('SELECT wear FROM pf_tool_wear WHERE user_id = ? AND tool_type = ?', [$uid, 'axe']);
chk('remove the broken axe: the slot frees', pfd_remove_broken($uid, 'axe') === null && $belt() === ['till'], $belt());
chk('nothing valuable is lost: the axe is still in the satchel and its wear is kept (a kit can still fix it)', (pfd_sources($uid)['tools']['axe'] ?? 0) >= 1 && (int)q_val('SELECT wear FROM pf_tool_wear WHERE user_id = ? AND tool_type = ?', [$uid, 'axe']) === $wearBefore && pfd_wear($uid)['axe']['broken']);
chk('the next usable tool takes the slot, and its piece is in the deck', pfd_equip_tool($uid, 'rod') === null && $belt() === ['till', 'rod'] && in_array('t:rod', $keys(), true) && !in_array('t:axe', $keys(), true), [$belt(), $keys()]);
chk('removing twice is safe: an error, no change', pfd_remove_broken($uid, 'axe') === 'That tool is not on your belt.' && $belt() === ['till', 'rod'] && $rows($oid) === ['water']);
chk('the other gnome was not touched by any of it', $rows($oid) === ['water']);

// fix after removal still works and the tool can come back
$item('tool-repair-kit'); pfd_unequip($uid, 'rod');
chk('after removal, Fix still works and the fixed axe goes back on', pfd_fix($uid, 'axe') === null && pfd_equip_tool($uid, 'axe') === null && $belt() === ['till', 'axe'] && in_array('t:axe', $keys(), true), $belt());

// a tool that is gone ("none") also clogs a slot
pfd_unequip($uid, 'axe'); pfd_equip_tool($uid, 'rod'); give_item($uid, item_id_by_slug('willow-fishing-rod'), -1); tool_cache_reset();
chk('a tool that left the satchel is "none" and holds its slot', ($states()['rod'] ?? '') === 'none' && pfd_equip_tool($uid, 'axe') === 'Your belt is full (2 tools). Take one off first.', $states());
chk('remove the gone tool: the slot frees for the next one', pfd_remove_broken($uid, 'rod') === null && $belt() === ['till'] && pfd_equip_tool($uid, 'axe') === null, $belt());

// the POST action
pfd_wear_add($uid, ['axe' => 20]);
chk('POST pfd_remove: [ok, message]; an ok tool and a repeat answer [false, why]', pfd_post($re(), 'pfd_remove', ['tool' => 'axe']) === [true, 'Removed from your belt.'] && pfd_post($re(), 'pfd_remove', ['tool' => 'axe']) === [false, 'That tool is not on your belt.'] && pfd_post($re(), 'pfd_remove', ['tool' => 'till'])[0] === false);
echo $bad ? "\n$bad FAILED\n" : "\nbelt remove checks: all ok\n"; exit($bad ? 1 : 0);
