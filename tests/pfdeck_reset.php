<?php
// 2.7.01: the fixed starter box and the admin reset of a Puzzle box (pfd_ensure_starter, pfd_admin_reset). Database checks on an installed copy (player "sprout");
// tests/pfdeck_reset.sh installs one, runs this, then checks the admin page admin/puzzlebox.php.
// php tests/pfdeck_reset.php GAMEDIR [dirty]     dirty: only put sprout's box in a changed state (switched pieces, a set belt, auto on) for the page checks
$G = $argv[1] ?? ''; if ($G === '') { echo "usage: php tests/pfdeck_reset.php GAMEDIR [dirty]\n"; exit(1); }
$_SERVER['SCRIPT_NAME'] = '/puzzlebox.php'; require $G . '/includes/bootstrap.php'; require_once $G . '/includes/adventure.php'; require_once $G . '/includes/pfight_game.php'; require_once $G . '/includes/pfdeck.php';
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$item = fn(string $slug, int $n = 1) => give_item($uid, item_id_by_slug($slug), $n);
q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_v1', 'admin')"); setting('__reload__'); pfd_ensure_content(); pmod_ensure();
$FIXED = array_merge(PFD_CORE, PFD_STARTER_FIXED);
$rows = fn(int $id) => q('SELECT piece_key, starter, active, pos FROM pf_deck_pieces WHERE user_id = ? ORDER BY pos, piece_key', [$id])->fetchAll(PDO::FETCH_ASSOC);
$deckRow = fn(int $id) => q_one('SELECT starter, auto_use, belt_set FROM pf_decks WHERE user_id = ?', [$id]);
$beltRows = fn(int $id) => q('SELECT tool_type FROM pf_belts WHERE user_id = ? ORDER BY slot', [$id])->fetchAll(PDO::FETCH_COLUMN);
$wearRows = fn(int $id) => q('SELECT tool_type, wear FROM pf_tool_wear WHERE user_id = ? ORDER BY tool_type', [$id])->fetchAll(PDO::FETCH_KEY_PAIR);
$kits = fn() => (int)q_val('SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [$uid, PFD_REPAIR]);
/** What the account unlocked (the sources of the pieces), without what the box itself saves. */
$owned = function (int $id): array { $s = pfd_sources($id); unset($s['starter'], $s['state'], $s['belt'], $s['auto']); return $s; };
/** Put sprout's box in a changed state: switched pieces, a belt that was set, auto-use on. */
$dirty = function () use ($uid) {
    $on = array_column(pfd_deck($uid)['belt'], 'type'); $off = array_values(array_diff(['axe', 'till', 'rod'], $on));   // the belt never set holds the best two of the three tools: swap one for the third
    $e = [pfd_toggle($uid, 'soothe', false), pfd_toggle($uid, 'hide', true), pfd_toggle($uid, 'c:vegetable', true), $on ? pfd_unequip($uid, $on[0]) : 'no tool on the belt', $off ? pfd_equip_tool($uid, $off[0]) : 'no tool to put on', pfd_set_auto($uid, true)];
    return array_values(array_filter($e, fn($x) => $x !== null));
};

if (($argv[2] ?? '') === 'dirty') { $e = $dirty(); echo $e ? 'dirty: ' . implode(' / ', $e) . "\n" : "dirty: done\n"; exit($e ? 1 : 0); }

echo "== the fixed starter, packed once\n";
q('UPDATE users SET level = 9 WHERE id = ?', [$uid]);
chk('a new gnome has no starter saved', !pfd_deck($uid)['starter'] && !q_val('SELECT COUNT(*) FROM pf_deck_pieces WHERE user_id = ?', [$uid]));
chk('pfd_ensure_starter packs the fixed starter: 10 rows, in order, all starter and on', pfd_ensure_starter($uid) && array_column($rows($uid), 'piece_key') === $FIXED && !array_filter($rows($uid), fn($r) => (int)$r['starter'] !== 1 || (int)$r['active'] !== 1) && (int)$deckRow($uid)['starter'] === 1, $rows($uid));
$r0 = $rows($uid);
chk('a second pfd_ensure_starter changes nothing', pfd_ensure_starter($uid) && $rows($uid) === $r0);
chk('pfd_set_starter "fixed" again is refused (once only)', pfd_set_starter($uid, 'fixed') === 'You have already packed your first Puzzle box.' && $rows($uid) === $r0);

echo "== an admin reset of a changed box\n";
$item('hatchet'); $item('worn-trowel'); $item('willow-fishing-rod'); $item(PFD_REPAIR, 3); tool_cache_reset();
$tomato = item_id_by_slug('tomato'); q('INSERT INTO user_food_mastery (user_id, item_id, eaten, grown) VALUES (?, ?, 0, 3)', [$uid, $tomato]);   // a crop grown: Garden Greens is owned
$de = $dirty(); chk('the gnome changes the box: a starter piece off, two owned pieces on, a tool taken off and another put on, auto-use on', $de === [], $de);
pfd_wear_add($uid, ['axe' => 6, 'rod' => 4]);
q('INSERT INTO user_pmod (user_id, tile_key, mod_key) VALUES (?, ?, ?)', [$uid, 'jab', 'sticky']);   // an earned puzzle upgrade
$other = (int)db_insert('users', ['username' => 'other', 'email' => 'o@b.local', 'password_hash' => (string)$u['password_hash'], 'created_at' => (string)$u['created_at']]);
pfd_set_starter($other, 'kind'); pfd_belt_save($other, ['water']); q('INSERT INTO pf_tool_wear (user_id, tool_type, wear) VALUES (?, ?, 9)', [$other, 'water']);
$oRows = $rows($other); $oDeck = $deckRow($other);
$keys = array_column(pfd_deck($uid)['deck'], 'key'); $belt0 = $beltRows($uid); $d0 = $deckRow($uid);
chk('before the reset: the box differs from the starter (extra pieces, a saved belt, auto on)', in_array('hide', $keys, true) && in_array('c:vegetable', $keys, true) && !in_array('soothe', $keys, true) && count($belt0) === 2 && (int)$d0['auto_use'] === 1 && (int)$d0['belt_set'] === 1, [$keys, $belt0, $d0]);
$wear0 = $wearRows($uid); $mods0 = pfight_mods($uid); $own0 = $owned($uid); $kits0 = $kits();
chk('before the reset: tool wear, an upgrade and repair kits are there', $wear0 === ['axe' => 6, 'rod' => 4] && $mods0 === ['jab' => 'sticky'] && $kits0 === 3, [$wear0, $mods0, $kits0]);
$why = pfd_admin_reset($uid); $rReset = $rows($uid);
chk('pfd_admin_reset: no error', $why === null, $why);
chk('the box rows are exactly the fixed starter again (10, in order, all starter and on; nothing switched)', array_column($rows($uid), 'piece_key') === $FIXED && !array_filter($rows($uid), fn($r) => (int)$r['starter'] !== 1 || (int)$r['active'] !== 1), $rows($uid));
chk('the deck in a fight is the fixed starter plus the belt\'s tool pieces only', array_values(array_filter(array_column(pfd_deck($uid)['deck'], 'key'), fn($k) => !str_starts_with($k, 't:'))) === $FIXED, array_column(pfd_deck($uid)['deck'], 'key'));
chk('auto-use is off, the starter flag is set', (int)$deckRow($uid)['auto_use'] === 0 && (int)$deckRow($uid)['starter'] === 1 && pfd_deck($uid)['auto'] === false, $deckRow($uid));
chk('the belt is not set any more: no saved slots (it shows the best usable tools, as for a new gnome)', $beltRows($uid) === [] && (int)$deckRow($uid)['belt_set'] === 0 && pfd_sources($uid)['belt'] === null && array_column(pfd_deck($uid)['belt'], 'type') === array_column(pfd_belt(['belt' => null] + pfd_sources($uid)), 'type'), [$beltRows($uid), $deckRow($uid)]);
chk('kept: tool wear, the earned upgrade, repair kits', $wearRows($uid) === $wear0 && pfight_mods($uid) === $mods0 && $kits() === $kits0, [$wearRows($uid), pfight_mods($uid), $kits()]);
chk('kept: everything the account unlocked (tools, crops, crafts, regions, pals, wearables, level, calling)', $owned($uid) === $own0);
chk('the owned pieces are still owned, off: they can be switched on again', ($p = array_column(pfd_deck($uid)['pieces'], null, 'key')) && isset($p['hide'], $p['c:vegetable']) && !$p['hide']['on'] && !$p['c:vegetable']['on'] && pfd_toggle($uid, 'hide', true) === null && pfd_toggle($uid, 'hide', false) === null);
chk('another gnome\'s box is untouched', $rows($other) === $oRows && $deckRow($other) === $oDeck && $beltRows($other) === ['water'] && $wearRows($other) === ['water' => 9]);
chk('a second reset (after a piece was switched on and off again) gives the same box as the first', pfd_admin_reset($uid) === null && $rows($uid) === $rReset && $beltRows($uid) === [], $rows($uid));
chk('a gnome with no box yet: the reset packs the starter', q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$other]) && q('DELETE FROM pf_decks WHERE user_id = ?', [$other]) && pfd_admin_reset($other) === null && array_column($rows($other), 'piece_key') === $FIXED);
$nDecks = (int)q_val('SELECT COUNT(*) FROM pf_decks');
chk('an id with no account is refused, no rows made', pfd_admin_reset(999999) === 'There is no such gnome.' && (int)q_val('SELECT COUNT(*) FROM pf_decks') === $nDecks && !q_val('SELECT COUNT(*) FROM pf_deck_pieces WHERE user_id = 999999'));

echo "== refused in a fight\n";
$dirty();
if (!active_expedition($uid)) explore_start(q_one('SELECT * FROM users WHERE id = ?', [$uid]));
$exp = active_expedition($uid); $c = q_one("SELECT * FROM creatures WHERE slug = 'badger'");
$enc = ['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false, 'pf' => ['over' => '', 'turn' => 1]];
$exp['encounter'] = json_encode($enc); save_exp($exp);
$rL = $rows($uid); $bL = $beltRows($uid); $dL = $deckRow($uid);
chk('in a fight (pfd_locked) the reset is refused and nothing changes', pfd_locked($uid) && pfd_admin_reset($uid) === 'That gnome is in a fight; the box is locked until it ends.' && $rows($uid) === $rL && $beltRows($uid) === $bL && $deckRow($uid) === $dL, [$rows($uid), $deckRow($uid)]);
$enc['pf']['over'] = 'run'; $exp['encounter'] = json_encode($enc); save_exp($exp);
chk('the fight is over: the reset works', !pfd_locked($uid) && pfd_admin_reset($uid) === null && array_column($rows($uid), 'piece_key') === $FIXED && $beltRows($uid) === [] && (int)$deckRow($uid)['auto_use'] === 0);
$exp['encounter'] = null; save_exp($exp);
q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$other]); q('DELETE FROM pf_decks WHERE user_id = ?', [$other]); q('DELETE FROM pf_belts WHERE user_id = ?', [$other]); q('DELETE FROM pf_tool_wear WHERE user_id = ?', [$other]); q('DELETE FROM users WHERE id = ?', [$other]);
echo $bad ? "\n$bad FAILED\n" : "\nreset checks: all ok\n"; exit($bad ? 1 : 0);
