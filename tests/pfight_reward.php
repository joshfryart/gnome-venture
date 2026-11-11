<?php
// php tests/pfight_reward.php GAMEDIR : puzzle upgrades. Offers per real day, the waiting bank, no double pay for one run, pick, replace, remove, and the mod reaching the deck.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/pfight_game.php';
$bad = 0; $ck = function (string $name, $got, $want) use (&$bad) { if ($got === $want) echo "ok   $name\n"; else { echo "FAIL $name (got " . json_encode($got) . ", want " . json_encode($want) . ")\n"; $bad++; } };
set_setting('pfight_open', '1');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
q('UPDATE users SET level = 8 WHERE id = ?', [$uid]); $u['level'] = 8;
pmod_ensure(); q('DELETE FROM user_poffer WHERE user_id = ?', [$uid]); q('DELETE FROM user_pgrant WHERE user_id = ?', [$uid]); q('DELETE FROM user_pmod WHERE user_id = ?', [$uid]);

$m1 = pfight_puzzle_reward($u, 'run1', 0); $ck('first puzzle earns an offer and says 1 of 3', str_contains($m1, '1 of 3 today'), true);
$ck('the same run pays once', pfight_puzzle_reward($u, 'run1', 0), '');
$m2 = pfight_puzzle_reward($u, 'run2', 1); $ck('second offer, 2 of 3', str_contains($m2, '2 of 3 today'), true);
$m3 = pfight_puzzle_reward($u, 'run3', 2); $ck('third offer, 3 of 3', str_contains($m3, '3 of 3 today'), true);
$m4 = pfight_puzzle_reward($u, 'run4', 2); $ck('a fourth puzzle is told the daily cap', str_contains($m4, 'all 3 for today') && str_contains($m4, 'midnight'), true);
$ck('three offers are waiting', count(pfight_offers($uid)), 3);
foreach (pfight_offers($uid) as $o) {
    $ck('offer ' . $o['id'] . ' has up to three distinct legal choices', count($o['choices']) >= 1 && count($o['choices']) <= 3 && count(array_unique(array_map('json_encode', $o['choices']))) === count($o['choices']), true);
    foreach ($o['choices'] as [$tk, $mk]) if (!isset(pf_tiles()[$tk]) || !pfight_mod_fits($mk, pf_tiles()[$tk]['t'])) { echo "FAIL illegal choice $tk $mk\n"; $bad++; }
}
// a new day: the bank is still full, so no new offer, and the player is told
q('UPDATE user_pgrant SET day = ? WHERE user_id = ?', ['2000-01-01', $uid]);
$ck('a full bank is told to open the box', str_contains(pfight_puzzle_reward($u, 'run5', 0), 'waiting'), true);
$offer = pfight_offers($uid)[0]; [$tk, $mk] = $offer['choices'][0];
$ck('picking works', pfight_offer_pick($u, (int)$offer['id'], 0), null);
$ck('the upgrade is stored on the tile', pfight_mods($uid)[$tk] ?? '', $mk);
$ck('an offer cannot be used twice', pfight_offer_pick($u, (int)$offer['id'], 0) !== null, true);
$ck('a bad choice number is refused', pfight_offer_pick($u, (int)pfight_offers($uid)[0]['id'], 9) !== null, true);
$deck = pfight_apply_mods(pf_player_deck(['level' => 8], '', 1, [], [], [], true, pf_collection(8, '')), pfight_mods($uid));
$on = array_values(array_filter($deck, fn($t) => $t['k'] === $tk));
$ck('the upgrade reaches the deck tile', $on ? $on[0]['m'] : null, $mk);
pfight_mod_remove($u, $tk); $ck('removing an upgrade works', isset(pfight_mods($uid)[$tk]), false);
// a pal tile (key pal:...) never takes an upgrade
$ck('upgrades only fit their tile types', pfight_mod_fits('hardy', 'hurt'), false);
$ck('another gnome has none of this', pfight_mods($uid + 999), []);
$ck('rarity: small puzzle', pfight_rarity_for_pieces(12), 0); $ck('rarity: medium puzzle', pfight_rarity_for_pieces(40), 1); $ck('rarity: big puzzle', pfight_rarity_for_pieces(100), 2);
set_setting('pfight_rarity_mid', '20'); set_setting('pfight_rarity_big', '30');
$ck('rarity follows the admin settings', [pfight_rarity_for_pieces(19), pfight_rarity_for_pieces(20), pfight_rarity_for_pieces(30)], [0, 1, 2]);
set_setting('pfight_rarity_mid', '40'); set_setting('pfight_rarity_big', '100');
echo $bad ? "$bad FAILED\n" : "reward ok\n";
exit($bad ? 1 : 0);
