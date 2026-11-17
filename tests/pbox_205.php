<?php
// 2.7.05: Puzzle box finish. Database + render checks on an installed copy (player "sprout"): belt level check in the shop, the waiting upgrade offer and the no-script forms on the v1 box,
// pfd_swap (one request), the old box NOT carried over, a lair guardian's unique layer, the ground patch that fades at its own replay step.
// php tests/pbox_205.php GAMEDIR
$G = $argv[1] ?? ''; if ($G === '') { echo "usage: php tests/pbox_205.php GAMEDIR\n"; exit(1); }
$_SERVER['SCRIPT_NAME'] = '/puzzlebox.php'; require $G . '/includes/bootstrap.php'; require_once $G . '/includes/adventure.php'; require_once $G . '/includes/pfight_game.php'; require_once $G . '/includes/pfdeck.php'; require_once $G . '/includes/pfdeck_view.php';
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_v1', 'admin')"); setting('__reload__'); pfd_ensure_content(); pmod_ensure();
q("UPDATE users SET role = 'admin', level = 9 WHERE id = ?", [$uid]); $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);

echo "== belt level check in the shop\n";
chk('the Stitched belt needs level 8, the Masterwork belt 18, any other item 0', pfd_belt_level_need('stitched-fight-belt') === 8 && pfd_belt_level_need('masterwork-fight-belt') === 18 && pfd_belt_level_need('tomato') === 0);
$stockOf = fn(string $slug) => (int)q_val('SELECT st.id FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE i.slug = ?', [$slug]);
$sid = $stockOf('masterwork-fight-belt'); chk('Twigg\'s shelf holds the Masterwork belt', $sid > 0);
[$ok, $msg] = buy_from_shop($u, $sid, 1);
chk('a level 9 gnome cannot buy the level 18 belt (refused, says the level)', !$ok && str_contains((string)$msg, 'needs gnome level 18'), $msg);
chk('nothing was taken: no belt in the satchel, the stock is still there', !q_val('SELECT 1 FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ? AND ui.qty > 0', [$uid, 'masterwork-fight-belt']) && (int)q_val('SELECT current_stock FROM shop_stock WHERE id = ?', [$sid]) >= 1);
$sid8 = $stockOf('stitched-fight-belt'); [$ok8, $m8] = buy_from_shop($u, $sid8, 1);
chk('the level 8 belt is not refused for the level (any other reason may stop the sale in a test)', $ok8 || !str_contains((string)$m8, 'needs gnome level'), $m8);

echo "== one request swap\n";
pfd_ensure_starter($uid);
$on = fn(string $k) => (bool)q_val('SELECT active FROM pf_deck_pieces WHERE user_id = ? AND piece_key = ?', [$uid, $k]);
chk('soothe is in the kit, hide is not', $on('soothe') && !$on('hide'));
chk('pfd_swap soothe out, hide in: one call, no error', pfd_swap($uid, 'soothe', 'hide') === null);
chk('soothe is off and hide is on', !$on('soothe') && $on('hide'));
$before = q('SELECT piece_key, active FROM pf_deck_pieces WHERE user_id = ? ORDER BY piece_key', [$uid])->fetchAll(PDO::FETCH_ASSOC);
chk('swapping for a piece that does not exist is refused and changes nothing', pfd_swap($uid, 'hide', 'no-such-piece') !== null && q('SELECT piece_key, active FROM pf_deck_pieces WHERE user_id = ? ORDER BY piece_key', [$uid])->fetchAll(PDO::FETCH_ASSOC) === $before);
chk('the same piece twice is refused', pfd_swap($uid, 'hide', 'hide') === 'Pick two different pieces to swap.');
[$ok, $msg] = pfd_post($u, 'pfd_swap', ['out' => 'hide', 'in' => 'soothe']); chk('do=pfd_swap through pfd_post works', $ok && $on('soothe') && !$on('hide'), $msg);

echo "== the waiting upgrade offer is on the v1 box\n";
$h0 = pfv_box_html($u, 'kit'); chk('no offer waiting: no offer card', !str_contains($h0, 'pbx-offer'));
$own = pf_collection((int)$u['level'], (string)($u['calling'] ?? '')); $tk = $own[0]; $mk = array_key_first(array_filter(PF_MODS, fn($m) => pfight_mod_fits(array_search($m, PF_MODS) ?: '', pf_tiles()[$tk]['t'])));
if (!$mk) foreach (PF_MODS as $k => $m) if (pfight_mod_fits($k, pf_tiles()[$tk]['t'])) { $mk = $k; break; }
q('INSERT INTO user_poffer (user_id, ref, rarity, choices, created_at) VALUES (?, ?, 1, ?, ?)', [$uid, 'pbox205', json_encode([[$tk, $mk]]), now()]);
$h1 = pfv_box_html($u, 'kit');
chk('an offer is waiting: the card shows, with a pick form', str_contains($h1, 'pbx-offer') && str_contains($h1, 'name="do" value="pick"'));
$oid = (int)q_val('SELECT id FROM user_poffer WHERE user_id = ? AND ref = ?', [$uid, 'pbox205']);
chk('the pick (the same call puzzlebox.php makes) puts the upgrade on the piece', pfight_offer_pick($u, $oid, 0) === null && (pfight_mods($uid)[$tk] ?? '') === $mk);
chk('the offer is used up: the card is gone', !str_contains(pfv_box_html($u, 'kit'), 'pbx-offer'));

echo "== no script: a piece can still be packed or taken out; the belt tab links Twigg's shop and the Pal Book party\n";
chk('the kit has a noscript form with pfd_toggle for a piece', (bool)preg_match('~<noscript><form method="post" class="pfv-ns">.*?value="pfd_toggle".*?</noscript>~s', $h1));
chk('the Belt tab links to Twigg\'s shop by id', (bool)preg_match('~href="[^"]*shop\.php\?id=\d+"[^>]*>buy one at Twigg~u', pfv_box_html($u, 'belt')));
if (function_exists('ppal_open')) chk('the Pals tab links to the party section of the Pal Book', !ppal_open() || str_contains(pfv_box_html($u, 'pals'), 'puzzlepals.php#party'));

echo "== an old box (before 2.6.74) is not carried into the fixed starter (decided 2.7.05)\n";
pbox_ensure();
q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$uid]); q('UPDATE pf_decks SET starter = 0 WHERE user_id = ?', [$uid]);
q('DELETE FROM user_pbox WHERE user_id = ?', [$uid]); q('INSERT INTO user_pbox (user_id, tiles) VALUES (?, ?)', [$uid, json_encode(['hide'])]);
chk('no starter yet', !pfd_deck($uid)['starter']);
chk('pfd_ensure_starter packs the fixed starter only: the old box piece stays off', pfd_ensure_starter($uid) && !$on('hide') && count(array_filter(q('SELECT active FROM pf_deck_pieces WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN))) === count(array_merge(PFD_CORE, PFD_STARTER_FIXED)));
q('DELETE FROM user_pbox WHERE user_id = ?', [$uid]);

echo "== a lair guardian has a unique layer\n";
$bossBase = q_one("SELECT slug, landscapes FROM creatures WHERE size = 'boss' AND slug NOT LIKE 'boss-%' ORDER BY slug LIMIT 1");
if ($bossBase && isset(pfd_uniques()[$bossBase['slug']])) {
    q("DELETE FROM creatures WHERE slug = 'boss-t205'");
    $cid = db_insert('creatures', ['slug' => 'boss-t205', 'name' => 'Test Keeper', 'size' => 'boss', 'landscapes' => (string)$bossBase['landscapes'], 'level' => 20, 'hp' => 100, 'attack' => 5, 'defense' => 12, 'dmg_die' => 10, 'dmg_bonus' => 3, 'xp' => 50, 'description' => 't', 'active' => 0]);
    $row = q_one('SELECT * FROM creatures WHERE id = ?', [$cid]);
    $uq = pfd_unique_of($row); chk('a guardian with no row of its own gets the unique 3 of a boss', is_array($uq) && count($uq['P'] ?? []) === 3, $uq);
    chk('it is the same pick every time', pfd_unique_of($row) === $uq);
    $layers = array_count_values(array_column(pfd_foe_pieces($row, ''), 'layer')); chk('its deck has 3 unique pieces', ($layers['uni'] ?? 0) === 3, $layers);
    chk('a small ordinary creature without a row gets none', pfd_unique_of(['slug' => 'not-a-creature', 'size' => 'small']) === null);
    q('DELETE FROM creatures WHERE id = ?', [$cid]);
} else echo "skip: no base boss with unique pieces\n";

echo "== a ground patch that fades is named in the replay step\n";
$s = ['ter' => ['1,1' => 'sun', '2,2' => 'sun'], 'v1' => ['nsun' => 2, 'nbr' => 1, 'nmud' => 1]];
chk('a third sunny patch drops the oldest one and says which', pfb_ground_set($s, 3, 3, 'sun') === '1,1' && array_keys($s['ter']) === ['2,2', '3,3'], $s);
$s2 = ['ter' => ['1,1' => 'sun'], 'v1' => ['nsun' => 2, 'nbr' => 1, 'nmud' => 1]];
chk('room to spare: nothing fades', pfb_ground_set($s2, 3, 3, 'sun') === null && count($s2['ter']) === 2);
$ev = pfb_env_events(['envlog' => [['k' => 'sunbeam', 'x' => 3, 'y' => 3, 'me' => 0, 'foe' => 0.0, 'drop' => '1,1']], 'bar' => ['now' => 0], 'fh' => ['now' => 0], 'me' => ['hp' => 5, 'block' => 0]]);
chk('the replay event carries the faded cell', ($ev[0]['drop'] ?? '') === '1,1', $ev);
q('DELETE FROM pf_deck_pieces WHERE user_id = ?', [$uid]); q('UPDATE pf_decks SET starter = 0 WHERE user_id = ?', [$uid]);
echo $bad ? "\n$bad FAILED\n" : "\n2.7.05 checks: all ok\n"; exit($bad ? 1 : 0);
