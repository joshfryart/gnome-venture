<?php
// 2.7.14 WEARING (includes/wearables.php wear_equip / wear_takeoff / wear_worn, includes/pfdeck.php, includes/gnome25.php): 7 slots, one item each;
// a wearable's piece is offered in the Puzzle box only while its item is worn, and switching it on still takes a Keepsake slot.
// php tests/wear_equip.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/pfdeck.php';
require_once $argv[1] . '/includes/wearables.php';
require_once $argv[1] . '/includes/gnome25.php';
require_once $argv[1] . '/includes/schema.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : '  ' . (is_string($extra) ? $extra : json_encode($extra))) . "\n"; if (!$cond) $fails++; }

// arrange: sprout at level 1 (one Keepsake slot), Puzzle combat v1 and wearables on, a packed starter box, nothing worn
set_setting('pfight_v1', '1'); set_setting('wear_open', '1'); setting('__reload__');
wear_ensure_items(); pfd_ensure();
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
q('UPDATE users SET level = 1 WHERE id = ?', [$uid]);
$U = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$give = function (string $slug, int $n = 1) use ($uid) { give_item($uid, item_id_by_slug($slug), $n); };
$have = function (string $slug, int $n) use ($uid) { $d = $n - wear_qty($uid, $slug); if ($d) give_item($uid, item_id_by_slug($slug), $d); };   // exactly n in the satchel
q('DELETE FROM user_wear_slots WHERE user_id = ?', [$uid]); q('DELETE FROM wear_lined WHERE user_id = ?', [$uid]);
pfd_admin_reset($uid);
foreach (['flood-boots', 'work-gloves', 'work-gloves-b-fine', 'wayfarers-hat', 'trail-pack', 'na-sugarbush-snow-boots', 'na-birchwood-clog-lined'] as $s) $have($s, 1);
foreach (['flood-boots-b', 'flood-boots-lined', 'flood-boots-fine', 'flood-boots-b-lined', 'flood-boots-b-fine', 'trail-pack-fine', 'yarn-scarf'] as $s) $have($s, 0);
$wearKeys = fn() => array_values(array_map(fn($p) => $p['key'], array_filter(pfd_deck($uid)['pieces'], fn($p) => $p['src'] === 'wear')));
$piece = function (string $key) use ($uid): ?array { foreach (pfd_deck($uid)['pieces'] as $p) if ($p['key'] === $key) return $p; return null; };

echo "== slots\n";
ok('7 slots: footwear, backpack, coat, cloak, hat, hands, neck', array_keys(WEAR_SLOTS) === ['footwear', 'backpack', 'coat', 'cloak', 'hat', 'hands', 'neck']);
ok('the six older ones: boots feet, pack back, cloak cloak, hat hat, gloves hands, scarf neck', array_map('wear_slot_of', array_keys(WEAR_OLD_SLOT)) === array_values(WEAR_OLD_SLOT) && wear_slot_of('flood-boots') === 'footwear' && wear_slot_of('yarn-scarf') === 'neck');
$bad = []; foreach (wear_tailor_defs() as $s => $d) if (wear_slot_of($s) !== $d['cat']) $bad[] = $s;
ok('the 280 Tailor items go by their category (footwear, backpack, coat, cloak)', !$bad && wear_slot_of('na-sugarbush-snow-boots') === 'footwear', $bad);
ok('the table is in the schema for SQLite and MySQL (UNIQUE user and slot)', count(array_filter(schema_statements('sqlite')[0], fn($t) => str_contains($t, 'user_wear_slots') && str_contains($t, 'UNIQUE (user_id, slot)'))) === 1
    && count(array_filter(schema_statements('mysql')[0], fn($t) => str_contains($t, 'user_wear_slots') && str_contains($t, 'InnoDB'))) === 1);

echo "== nothing worn: no wear piece in the box\n";
ok('owned but not worn: no piece offered', $wearKeys() === [], $wearKeys());
$pk = pfd_toggle($uid, 'w:flood-boots', true); $ps = pfd_swap($uid, 'w:flood-boots', 'w:work-gloves-b');
ok('owned but not worn: packing it (Puzzle box / pre-fight toggle, swap) is refused and nothing is saved', $pk === 'Wear it first (My Gnome, Wearing).' && $ps !== null && $wearKeys() === [] && !q_val("SELECT 1 FROM pf_deck_pieces WHERE user_id = ? AND piece_key LIKE 'w:%'", [$uid]), [$pk, $ps]);

echo "== equip, replace, take off\n";
[$a, $m] = wear_equip($U(), 'footwear', 'flood-boots');
ok('wear the Flood Boots on the feet', $a && wear_worn($uid) === ['footwear' => 'flood-boots'], [$m, wear_worn($uid)]);
ok('its piece is now offered, switched off and New', ($p = $piece('w:flood-boots')) && !$p['on'] && !empty($p['new']) && $p['rank'] === 1, $piece('w:flood-boots'));
[$a, $m] = wear_equip($U(), 'footwear', 'na-sugarbush-snow-boots');
ok('replace: the Sugarbush Snow Boots take the feet; the Flood Boots come off (one row)', $a && wear_worn($uid) === ['footwear' => 'na-sugarbush-snow-boots'] && (int)q_val('SELECT COUNT(*) FROM user_wear_slots WHERE user_id = ?', [$uid]) === 1, [$m, wear_worn($uid)]);
ok('the old item\'s piece left the box, the new one is offered', $piece('w:flood-boots') === null && $piece('w:na-sugarbush-snow-boots') !== null, $wearKeys());
[$a, $m] = wear_equip($U(), 'hat', 'work-gloves');
ok('wrong slot refused (gloves on the head): nothing changes', !$a && str_contains($m, 'does not go there') && !isset(wear_worn($uid)['hat']), $m);
[$a, $m] = wear_equip($U(), 'backpack', 'trail-pack-fine');
ok('not owned refused (a Fine pack the gnome does not have)', !$a && str_contains($m, 'do not have') && !isset(wear_worn($uid)['backpack']), $m);
[$a, $m] = wear_equip($U(), 'neck', 'yarn-scarf');
ok('not owned refused (no scarf in the satchel)', !$a && str_contains($m, 'do not have'), $m);
[$a, $m] = wear_takeoff($U(), 'footwear');
ok('take off: the feet are bare, the piece leaves the box', $a && wear_worn($uid) === [] && $wearKeys() === [], [$m, $wearKeys()]);
[$a, $m] = wear_takeoff($U(), 'footwear');
ok('take off an empty slot: refused', !$a, $m);

echo "== more worn items than Keepsake slots (level 1: one slot)\n";
foreach ([['footwear', 'flood-boots'], ['hands', 'work-gloves'], ['hat', 'wayfarers-hat'], ['backpack', 'trail-pack']] as [$s, $it]) wear_equip($U(), $s, $it);
$k = $wearKeys(); sort($k);
ok('four items worn: four pieces offered', $k === ['w:flood-boots', 'w:trail-pack', 'w:wayfarers-hat', 'w:work-gloves'], $k);
ok('switch the first on: in the deck, a Keepsake slot used', pfd_toggle($uid, 'w:flood-boots', true) === null && $piece('w:flood-boots')['on'] && pfd_deck($uid)['counts']['keeps'] === 1);
$e = pfd_toggle($uid, 'w:wayfarers-hat', true);
ok('switching a second on is refused: the Keepsake slots are full', $e !== null && str_contains($e, 'Keepsake') && !$piece('w:wayfarers-hat')['on'], (string)$e);
ok('the Puzzle box still counts Keepsakes: 1 of 1', pfd_deck($uid)['counts']['keeps'] === 1 && pfd_deck($uid)['counts']['keeps_max'] === 1);

echo "== taking off and wearing again keeps the switch\n";
wear_takeoff($U(), 'footwear');
ok('boots off: their piece leaves the box and frees the Keepsake slot', $piece('w:flood-boots') === null && pfd_deck($uid)['counts']['keeps'] === 0);
ok('a worn-off piece cannot be switched on', pfd_toggle($uid, 'w:flood-boots', true) !== null);
wear_equip($U(), 'footwear', 'flood-boots');
ok('boots on again: the piece comes back switched on (its switch was kept)', ($p = $piece('w:flood-boots')) && $p['on'] && $p['out'] === '' && pfd_deck($uid)['counts']['keeps'] === 1, $piece('w:flood-boots'));

echo "== the Rare cap with a Fine item\n";
q('UPDATE users SET level = 40 WHERE id = ?', [$uid]);   // four Keepsake slots
ok('gloves (Common) on at level 40', pfd_toggle($uid, 'w:work-gloves', true) === null && $piece('w:work-gloves')['on']);
$fine = pfd_sources($uid); $fine['worn']['hands'] = 'work-gloves-b-fine'; $fine['state']['w:work-gloves-b'] = true;
ok('a worn Fine piece switched on counts as Rare (rank 3)', (array_column(pfd_build($fine)['pieces'], null, 'key')['w:work-gloves-b']['rank'] ?? 0) === 3 && pfd_build($fine)['counts']['rare'] === 1);
// fill the Rare cap: 7 region guides read make every read region's piece Rare (rank 3); three of them switched on
pfd_toggle($uid, 'w:work-gloves', true);   // the Common gloves on: equipping the Fine pair of the same wearable keeps the switch
q('DELETE FROM user_guides WHERE user_id = ?', [$uid]);
$regs = ['NA', 'CA', 'CB', 'SA', 'NWE', 'SE', 'EE'];
foreach ($regs as $rc) q('INSERT INTO user_guides (user_id, guide_key, read_at) VALUES (?, ?, ?)', [$uid, 'region:' . strtolower($rc), now()]);
$rare3 = ['r:NA', 'r:CA', 'r:CB'];
$on = 0; foreach ($rare3 as $rk) { if (pfd_toggle($uid, $rk, true) === null) $on++; }
ok('arrange: three Rare region pieces on, the deck is legal', $on === 3 && pfd_deck($uid)['counts']['rare'] === 3 && pfd_deck($uid)['err'] === null, [$on, pfd_deck($uid)['counts']['rare'], pfd_deck($uid)['err']]);
q('INSERT INTO pf_deck_pieces (user_id, piece_key, starter, active, pos) VALUES (?, ?, 0, 1, 100)', [$uid, 'w:work-gloves-b']);   // the cut-b switch was on before
[$a, $m] = wear_equip($U(), 'hands', 'work-gloves-b-fine');
ok('wearing the Fine gloves (switch on) as a 4th Rare is refused, with the Lined way out; the Common gloves stay worn', !$a && str_contains($m, 'Rare') && str_contains($m, 'Lined') && wear_worn($uid)['hands'] === 'work-gloves', $m);
wear_lined_toggle($U(), 'work-gloves-b-fine');
[$a, $m] = wear_equip($U(), 'hands', 'work-gloves-b-fine');
ok('worn as Lined it is not Rare: allowed, rank 2, the deck stays legal', $a && ($piece('w:work-gloves-b')['rank'] ?? 0) === 2 && pfd_deck($uid)['err'] === null, $m);
wear_lined_toggle($U(), 'work-gloves-b-fine');
wear_equip($U(), 'hands', 'work-gloves');
q('DELETE FROM user_guides WHERE user_id = ?', [$uid]);
foreach ($rare3 as $rk) pfd_toggle($uid, $rk, false);
q('DELETE FROM pf_deck_pieces WHERE user_id = ? AND piece_key = ?', [$uid, 'w:work-gloves-b']);
q('UPDATE users SET level = 1 WHERE id = ?', [$uid]);

echo "== a stale worn item falls back to the gnome's copy of the same wearable\n";
wear_equip($U(), 'coat', 'na-birchwood-clog-lined');
ok('a footwear item does not go in the coat slot', !isset(wear_worn($uid)['coat']));
$have('flood-boots-lined', 1); $have('flood-boots', 0);
ok('the Common Flood Boots are gone (lined at the Tailor): the Lined pair is worn in their place', wear_worn($uid)['footwear'] === 'flood-boots-lined' && ($piece('w:flood-boots')['rank'] ?? 0) === 2, wear_worn($uid));
$have('flood-boots-lined', 0);
ok('no Flood Boots left: nothing worn on the feet, no piece', !isset(wear_worn($uid)['footwear']) && $piece('w:flood-boots') === null);

echo "== migration from switched-on pieces\n";
q('DELETE FROM user_wear_slots WHERE user_id = ?', [$uid]); q('DELETE FROM pf_deck_pieces WHERE user_id = ? AND piece_key LIKE ?', [$uid, 'w:%']);
$have('flood-boots', 1); $have('flood-boots-b', 1);
foreach ([['w:flood-boots-b', 1, 101], ['w:flood-boots', 1, 102], ['w:work-gloves', 1, 103], ['w:wayfarers-hat', 0, 104]] as [$k, $ac, $pos]) q('INSERT INTO pf_deck_pieces (user_id, piece_key, starter, active, pos) VALUES (?, ?, 0, ?, ?)', [$uid, $k, $ac, $pos]);
set_setting('wear_slots_2714', ''); setting('__reload__');
$n = wear_slots_migrate();
$w = wear_worn($uid);
ok('switched-on pieces become worn: boots cut b first (box order) wins the feet, the gloves the hands; the Hat (off) stays unworn', ($w['footwear'] ?? '') === 'flood-boots-b' && ($w['hands'] ?? '') === 'work-gloves' && !isset($w['hat']) && $n >= 2, $w);
ok('the migrated piece stays switched on', ($piece('w:flood-boots-b')['on'] ?? false) === true && ($piece('w:work-gloves')['on'] ?? false) === true);
setting('__reload__');
ok('it runs once (the setting is set; a second call does nothing)', setting('wear_slots_2714') === '1' && wear_slots_migrate() === 0);

echo "== the avatar draws every worn item, switched on or not\n";
q('UPDATE pf_deck_pieces SET active = 0 WHERE user_id = ? AND piece_key LIKE ?', [$uid, 'w:%']);
wear_equip($U(), 'hat', 'wayfarers-hat');
$ask = fn(string $fn) => trim((string)shell_exec('php -d error_reporting=0 -r \'$_SERVER["SCRIPT_NAME"]="/adventure.php"; require "' . $argv[1] . '/includes/bootstrap.php"; require_once "' . $argv[1] . '/includes/gnome25.php"; $u = q_one("SELECT * FROM users WHERE id = ' . $uid . '"); echo ' . $fn . ';\' 2>/dev/null'));
ok('boots (cut b), gloves and hat worn, every switch off: codes bgh', $ask('gnome25_worn($u)') === 'bgh', $ask('gnome25_worn($u)'));
wear_equip($U(), 'footwear', 'na-sugarbush-snow-boots');
ok('a Tailor item worn: listed with its category, and the url carries it as x= (the cache key)', $ask('json_encode(gnome25_worn_items($u))') === '{"na-sugarbush-snow-boots":"footwear"}' && str_contains($ask('gnome25_url($u)'), 'x=na-sugarbush-snow-boots') && str_contains($ask('gnome25_url($u)'), 'w=gh'), $ask('gnome25_url($u)'));
ok('the art revision was bumped for the new cache key', GNOME25_ART_REV === '2714a');
$plain = gnome25_compose('front', []);
$tw = 'zz-test-wear-' . getmypid();   // a slug no real art uses: the hook is checked on a throwaway layer (real art may exist for the 280 items)
ok('no art for a Tailor item: the strip is the same as without it', gnome25_compose('front', [], [], '', [$tw => 'footwear']) === $plain);
$wd = $argv[1] . '/assets/img/gnome25/wear/' . $tw; @mkdir($wd, 0775, true);
$im = imagecreatetruecolor(512, 80); imagealphablending($im, false); imagesavealpha($im, true); imagefill($im, 0, 0, imagecolorallocatealpha($im, 0, 0, 0, 127));
imagefilledrectangle($im, 20, 60, 40, 70, imagecolorallocatealpha($im, 200, 20, 20, 0)); imagepng($im, $wd . '/front.png');
ok('with its art (gnome25/wear/<slug>/front.png) the layer is drawn', gnome25_compose('front', [], [], '', [$tw => 'footwear']) !== $plain);
ok('a missing view (back) still draws nothing new', gnome25_compose('back', [], [], '', [$tw => 'footwear']) === gnome25_compose('back', []));
@unlink($wd . '/front.png'); @rmdir($wd);

echo "== all 7 spots worn: the Keepsake slots still cap the worn pieces in a fight (1 / 2 / 3 / 4 by level, never 7)\n";
// arrange: keep what the sections above left (restored below), then one Common item in each of the 7 spots at level 40 (4 Keepsake slots), every switch off
$keepWorn = q('SELECT slot, item_slug, worn_at FROM user_wear_slots WHERE user_id = ?', [$uid])->fetchAll(); $keepSw = q('SELECT piece_key, starter, active, pos FROM pf_deck_pieces WHERE user_id = ? AND piece_key LIKE ?', [$uid, 'w:%'])->fetchAll();
q('DELETE FROM user_wear_slots WHERE user_id = ?', [$uid]); q('DELETE FROM pf_deck_pieces WHERE user_id = ? AND piece_key LIKE ?', [$uid, 'w:%']);
q('UPDATE users SET level = 40 WHERE id = ?', [$uid]);
$seven = ['footwear' => 'flood-boots', 'backpack' => 'trail-pack', 'coat' => 'ca-quilted-cotton-coat', 'cloak' => 'travel-cloak', 'hat' => 'wayfarers-hat', 'hands' => 'work-gloves', 'neck' => 'yarn-scarf'];
$had = []; foreach ($seven as $it) { $had[$it] = wear_qty($uid, $it); $have($it, 1); }
// act: wear all seven, then try to pack every piece (what the Kit tab and the pre-fight bench do: pfd_toggle)
$wornOk = 0; foreach ($seven as $sl => $it) { [$a] = wear_equip($U(), $sl, $it); $wornOk += $a ? 1 : 0; }
$sevenKeys = array_map(fn($it) => 'w:' . $it, array_values($seven));
$res = []; foreach ($sevenKeys as $k) $res[] = pfd_toggle($uid, $k, true);
$d7 = pfd_deck($uid); $inDeck = fn(array $deck) => count(array_filter($deck, fn($p) => $p['src'] === 'wear'));
// assert
ok('seven items worn, one in each spot; seven pieces offered', $wornOk === 7 && count(wear_worn($uid)) === 7 && count($wearKeys()) === 7, [$wornOk, wear_worn($uid), $wearKeys()]);
ok('packing them one by one: the first four go in, the fifth, sixth and seventh are refused (Keepsake slots)', array_map(fn($e) => $e === null ? 'in' : (str_contains($e, '4 Keepsake slots') ? 'full' : $e), $res) === ['in', 'in', 'in', 'in', 'full', 'full', 'full'], $res);
ok('the deck holds four worn pieces, Keepsakes 4 of 4, and is legal', $inDeck($d7['deck']) === 4 && $d7['counts']['keeps'] === 4 && $d7['counts']['keeps_max'] === 4 && $d7['err'] === null, [$inDeck($d7['deck']), $d7['counts'], $d7['err']]);
ok('the fight gets those four (pfd_fight_entries), not seven', $inDeck(pfd_fight_entries(pfd_sources($uid))) === 4);
$all = pfd_sources($uid); foreach ($sevenKeys as $k) $all['state'][$k] = true;   // a box that somehow has all seven switched on (older data)
$byLv = []; foreach ([1, 15, 25, 40, 99] as $lv) { $all['level'] = $lv; $bl = pfd_build($all); $byLv[] = [$inDeck($bl['deck']), count(array_filter($bl['pieces'], fn($p) => $p['src'] === 'wear' && $p['out'] === 'slots')), $inDeck(pfd_fight_entries($all))]; }
ok('all seven switched on anyway: 1 / 2 / 3 / 4 / 4 play at level 1 / 15 / 25 / 40 / 99, the rest are left out (slots), and the fight never gets more', $byLv === [[1, 6, 1], [2, 5, 2], [3, 4, 3], [4, 3, 4], [4, 3, 4]], $byLv);
ok('swap (the pre-fight screen): a packed worn piece out, a benched one in, still four', pfd_swap($uid, $sevenKeys[0], $sevenKeys[6]) === null && $piece($sevenKeys[6])['on'] && !$piece($sevenKeys[0])['on'] && pfd_deck($uid)['counts']['keeps'] === 4);
ok('taking a packed worn piece out again frees its slot; the item stays worn (the Closet decides what is worn, the box what is packed)', pfd_toggle($uid, $sevenKeys[6], false) === null && pfd_deck($uid)['counts']['keeps'] === 3 && wear_worn($uid)['neck'] === 'yarn-scarf');
// clean up: back to what the sections above left
q('DELETE FROM user_wear_slots WHERE user_id = ?', [$uid]); q('DELETE FROM pf_deck_pieces WHERE user_id = ? AND piece_key LIKE ?', [$uid, 'w:%']);
foreach ($keepWorn as $r) q('INSERT INTO user_wear_slots (user_id, slot, item_slug, worn_at) VALUES (?, ?, ?, ?)', [$uid, $r['slot'], $r['item_slug'], $r['worn_at']]);
foreach ($keepSw as $r) q('INSERT INTO pf_deck_pieces (user_id, piece_key, starter, active, pos) VALUES (?, ?, ?, ?, ?)', [$uid, $r['piece_key'], $r['starter'], $r['active'], $r['pos']]);
foreach ($had as $it => $n) $have($it, $n);
q('UPDATE users SET level = 1 WHERE id = ?', [$uid]);

echo "== wear_open Off hides it all\n";
set_setting('wear_open', '0'); setting('__reload__');
[$a, $m] = wear_equip($U(), 'hands', 'work-gloves-b-fine');
ok('equip refused', !$a, $m);
[$a, $m] = wear_takeoff($U(), 'hat');
ok('take off refused', !$a, $m);
ok('no worn piece in the Puzzle box', pfd_sources($uid)['worn'] === [] && $wearKeys() === []);
ok('the avatar draws nothing worn', $ask('gnome25_worn($u)') === '' && !str_contains($ask('gnome25_url($u)'), 'x='), $ask('gnome25_url($u)'));
ok('the outfitter is hidden and its shelf refuses', wear_shop_hidden(['shop_type' => 'outfitter'], $U()) && wear_shop_block($U(), 'na-sugarbush-snow-boots') === 'That is not on the shelf.');
set_setting('wear_open', '1'); setting('__reload__');
ok('on again: what was worn is still worn', wear_worn($uid)['hat'] === 'wayfarers-hat');

q('DELETE FROM user_wear_slots WHERE user_id = ?', [$uid]); q('DELETE FROM pf_deck_pieces WHERE user_id = ? AND piece_key LIKE ?', [$uid, 'w:%']);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
