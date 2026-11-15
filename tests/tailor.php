<?php
// 2.7.00 the Tailor (includes/wearables.php + the 'tailor' garden building + the Keepsake pieces in includes/pfdeck.php).
// php tests/tailor.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
require_once $argv[1] . '/includes/gardens.php';
require_once $argv[1] . '/includes/pfdeck.php';
require_once $argv[1] . '/includes/wearables.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
set_setting('pfight_v1', '1'); setting('__reload__');   // wearables are behind the Puzzle combat setting
q('UPDATE users SET energy = 90, level = 30 WHERE id = ?', [$uid]); $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
$give = function (string $slug, int $n) use ($uid) { give_item($uid, item_id_by_slug($slug), $n); };
$qty = fn(string $slug) => wear_qty($uid, $slug);
wear_ensure_items();

echo "== the building\n";
ok('Tailor is a garden building: key, garden level 6, 1800 Petals, levels 2 and 3', isset(BUILDINGS['tailor']) && BUILDINGS['tailor'][2] === 6 && BUILDINGS['tailor'][3] === 1800 && isset(BUILDING_UPGRADES['tailor'][2], BUILDING_UPGRADES['tailor'][3]));
q('DELETE FROM garden_buildings WHERE plot_id IN (SELECT id FROM plots WHERE user_id = ?) AND building = ?', [$uid, 'tailor']);
ok('no Tailor built: no power, nothing made', !tailor_has($uid) && tailor_power($uid) === 0 && tailor_levels($uid) === []);
foreach (['coir-fibre' => 2, 'pine-resin' => 1, 'stag-beetle-shell' => 1] as $s => $n) $give($s, $n);
[$a, $m] = tailor_craft($u, 'work-gloves', 'a');
ok('without a Tailor the craft is refused and nothing is taken', !$a && str_contains($m, 'Tailor') && $qty('coir-fibre') >= 2 && $qty('work-gloves') === 0, $m);
db_insert('garden_buildings', ['plot_id' => $plot, 'building' => 'tailor', 'built_at' => now(), 'level' => 1]);
ok('one level 1 Tailor: power 1, chance 38%', tailor_has($uid) && tailor_levels($uid) === [1] && tailor_power($uid) === 1 && tailor_chance(1) === 38);

echo "== make\n";
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
[$a, $m] = tailor_craft($u, 'work-gloves', 'b');
ok('Work Gloves, cut b (Knuckle Down): made, materials and 4 energy taken', $a && $qty('work-gloves-b') === 1 && $qty('coir-fibre') === 0 && $qty('pine-resin') === 0 && $e0 - (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) >= 4, $m);
[$a, $m] = tailor_craft($u, 'work-gloves', 'b');
ok('without the materials it is refused', !$a && str_contains($m, 'You need'), $m);
[$a, $m] = tailor_craft($u, 'wayfarers-hat', 'a');
ok('the Hat is bought, not made here', !$a && str_contains($m, 'not something'), $m);
[$a, $m] = tailor_craft($u, 'nonsense', 'a');
ok('an unknown wearable is refused', !$a);

echo "== lining and finishing\n";
$give('cottongrass', 6); $give('butterfly-scales', 3);
[$a, $m] = tailor_line($u, 'work-gloves-b', false, fn($pct) => true);
ok('a lucky lining: Common becomes Lined, the materials are used up', $a && $qty('work-gloves-b') === 0 && $qty('work-gloves-b-lined') === 1 && $qty('cottongrass') === 4 && $qty('butterfly-scales') === 2 && str_contains($m, 'Lined'), $m);
$asked = []; [$a, $m] = tailor_line($u, 'work-gloves-b-lined', false, function ($pct) use (&$asked) { $asked[] = $pct; return false; });
$give('seed-pearl', 2); $give('snow-moth-dust', 2);
[$a2, $m2] = tailor_line($u, 'work-gloves-b-lined', false, function ($pct) use (&$asked) { $asked[] = $pct; return false; });
ok('Lined to Fine needs a Seed Pearl and Snow Moth Dust (refused without them: first call)', !$a && str_contains($m, 'You need'), $m);
ok('a failed roll: the item stays Lined, the materials are gone, you get 1 Thread; the dice were asked 38', $a2 && $qty('work-gloves-b-lined') === 1 && $qty('work-gloves-b-fine') === 0 && $qty('seed-pearl') === 1 && $qty(WEAR_THREAD) === 1 && $asked === [38], json_encode([$asked, $qty(WEAR_THREAD), $m2]));
$give(WEAR_THREAD, 4);
[$a3, $m3] = tailor_line($u, 'work-gloves-b-lined', true, function ($pct) { throw new Exception('the dice must not be rolled for a sure thing'); });
ok('five Threads make it a sure thing: Fine, the Threads used up, no roll', $a3 && $qty('work-gloves-b-fine') === 1 && $qty('work-gloves-b-lined') === 0 && $qty(WEAR_THREAD) === 0 && str_contains($m3, 'sure thing'), $m3);
[$a4, $m4] = tailor_line($u, 'work-gloves-b-fine');
ok('Fine is as fine as it gets', !$a4 && str_contains($m4, 'as fine'), $m4);
$give('cottongrass', 2); $give('butterfly-scales', 1); give_item($uid, item_id_by_slug('flood-boots'), 1);
[$a5, $m5] = tailor_line($u, 'flood-boots', true);
ok('a sure thing without 5 Threads is refused', !$a5 && str_contains($m5, 'Thread'), $m5);
[$a6, $m6] = tailor_line($u, 'trail-pack');
ok('you cannot line what you do not have', !$a6 && str_contains($m6, 'do not have'), $m6);

echo "== re-cut\n";
$give(WEAR_THREAD, 1);
[$a, $m] = tailor_recut($u, 'flood-boots');
ok('a level 1 Tailor: re-cut costs 1 Thread: Puddle Hop becomes Sure Foot', $a && $qty('flood-boots') === 0 && $qty('flood-boots-b') === 1 && $qty(WEAR_THREAD) === 0 && str_contains($m, 'Sure Foot'), $m);
[$a, $m] = tailor_recut($u, 'flood-boots-b');
ok('no Thread left: refused', !$a && str_contains($m, 'Thread'), $m);
q('UPDATE garden_buildings SET level = 2 WHERE plot_id = ? AND building = ?', [$plot, 'tailor']);
[$a, $m] = tailor_recut($u, 'flood-boots-b');
ok('a level 2 Tailor re-cuts for nothing', $a && $qty('flood-boots') === 1 && $qty('flood-boots-b') === 0, $m);
$give('yarn-scarf', 1); [$a, $m] = tailor_recut($u, 'yarn-scarf');
ok('the Scarf has one cut: refused', !$a && str_contains($m, 'one cut'), $m);
db_insert('garden_buildings', ['plot_id' => $plot + 1000, 'building' => 'tailor', 'built_at' => now(), 'level' => 3]);
$other = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id DESC LIMIT 1', [$uid]);
ok('power sums the levels of every Tailor (here one level 2 Tailor; a Tailor in a plot of nobody is not yours)', tailor_levels($uid) === [2] && tailor_power($uid) === 2 && tailor_chance(tailor_power($uid)) === 46);
q('DELETE FROM garden_buildings WHERE plot_id = ?', [$plot + 1000]);

echo "== shops\n";
$shop = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
$onSale = fn(string $slug) => (int)q_val('SELECT COUNT(*) FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, item_id_by_slug($slug)]);
ok("Twigg's sells the Hat (300) and the Pack (800); the Tailor makes the rest, so no boots, gloves or cloak on a shelf", $shop > 0 && $onSale('wayfarers-hat') === 1 && $onSale('trail-pack') === 1 && !$onSale('flood-boots') && !$onSale('work-gloves') && !$onSale('travel-cloak'));
ok('the Tailor\'s Thread exists', item_id_by_slug(WEAR_THREAD) > 0);

echo "== the Puzzle box: wearables are Keepsake pieces\n";
foreach (['flood-boots', 'flood-boots-b', 'wayfarers-hat', 'work-gloves-b-fine'] as $s) if (!$qty($s)) $give($s, 1);
$src = pfd_sources($uid);
ok('pfd_sources lists the wearables in the satchel', isset($src['wears']['flood-boots'], $src['wears']['work-gloves-b-fine']), json_encode($src['wears'] ?? null));
$b = pfd_build($src); $byKey = array_column($b['pieces'], null, 'key');
ok('each makes a piece: boots a and b, the Hat, the Gloves (cut b), all src wear, off and New until switched on', isset($byKey['w:flood-boots'], $byKey['w:flood-boots-b'], $byKey['w:wayfarers-hat'], $byKey['w:work-gloves-b'])
    && !$byKey['w:flood-boots']['on'] && !empty($byKey['w:flood-boots']['new']) && $byKey['w:flood-boots']['src'] === 'wear', json_encode(array_keys($byKey)));
ok('the Gloves are Fine (rank 3), the Boots Common', $byKey['w:work-gloves-b']['rank'] === 3 && $byKey['w:flood-boots']['rank'] === 1);
$src['level'] = 1; $src['state'] = ['w:flood-boots' => true, 'w:wayfarers-hat' => true]; $b1 = pfd_build($src);
$by1 = array_column($b1['pieces'], null, 'key');
ok('level 1 has ONE Keepsake slot: the first piece on is in the deck, the second stays out (slots)', $by1['w:flood-boots']['out'] === '' && $by1['w:wayfarers-hat']['out'] === 'slots' && $b1['counts']['keeps_max'] === 1, json_encode([$by1['w:flood-boots']['out'], $by1['w:wayfarers-hat']['out'], $b1['counts']['keeps_max']]));
$src['level'] = 15; $b2 = pfd_build($src);
ok('level 15 has two: both are in', array_column($b2['pieces'], null, 'key')['w:wayfarers-hat']['out'] === '' && $b2['counts']['keeps_max'] === 2);
$src['level'] = 30; $src['state'] = ['w:work-gloves-b' => true]; $b3 = pfd_build($src);
ok('a Fine wearable counts as a Rare piece in the deck', $b3['counts']['rare'] === 1);
$tiles = pfd_tiles(array_values(array_filter($b2['deck'], fn($e) => $e['src'] === 'wear')), ['grit' => 1, 'nimble' => 1, 'hardiness' => 1, 'charm' => 1, 'lore' => 1, 'luck' => 0, 'level' => 15]);
$tt = array_column($tiles, null, 'n');
ok('the tiles carry the cut: Puddle Hop = a Guard with Evade on a body knob, Brim Down is Guard with Thorns', ($tt['Puddle Hop']['t'] ?? '') === 'guard' && ($tt['Puddle Hop']['tag'] ?? '') === 'evade' && ($tt['Brim Down']['tag'] ?? '') === 'thorns' && ($tt['Brim Down']['v'] ?? 0) >= 2, json_encode(array_keys($tt)));
$src['state'] = ['w:work-gloves-b' => true]; $gl = array_column(pfd_tiles(array_values(array_filter(pfd_build($src)['deck'], fn($e) => $e['src'] === 'wear')), ['grit' => 0, 'nimble' => 0, 'hardiness' => 0, 'charm' => 0, 'lore' => 0, 'luck' => 0, 'level' => 3]), null, 'n');
ok('Knuckle Down is Hurt with Bash; a Fine piece is worth +4 over the Common value (3 + 4 = 7 at stat 0, level 3)', ($gl['Knuckle Down']['t'] ?? '') === 'hurt' && ($gl['Knuckle Down']['tag'] ?? '') === 'bash' && ($gl['Knuckle Down']['v'] ?? 0) === 8, json_encode($gl['Knuckle Down'] ?? null));
$pfb = pfb_src(['src' => 'wear']);
ok('the board engine knows the source and gives it the body family', $pfb === 'wear' && (PFB_SRC_FAM['wear'] ?? '') === 'body');
echo "== level 3 free craft and commission\n";
q('UPDATE garden_buildings SET level = 3 WHERE plot_id = ? AND building = ?', [$plot, 'tailor']);
q("DELETE FROM festival_flags WHERE festival = 'tailor-free' AND user_id = ?", [$uid]);
ok('a level 3 Tailor: the free craft is ready', tailor_free_ready($uid));
$e1 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]); $g0 = $qty('work-gloves');
[$a, $m] = tailor_craft($u, 'work-gloves', 'a');
ok('the first craft of the day needs no materials or energy', $a && $qty('work-gloves') === $g0 + 1 && (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $e1 && str_contains($m, 'for nothing'), $m);
ok('and only the first', !tailor_free_ready($uid) && !tailor_craft($u, 'work-gloves', 'a')[0]);
q('UPDATE garden_buildings SET level = 1 WHERE plot_id = ? AND building = ?', [$plot, 'tailor']);
ok('a level 1 Tailor has no free craft', !tailor_free_ready($uid));
ok('power 6 or less pays no commission', tailor_commission($uid, 'work-gloves') === 0);
$c0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
$cm = tailor_commission($uid, 'work-gloves', 10);   // power 10
ok('power over 6 pays commission Petals (20% of the price, at least 1)', $cm >= 1 && (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) === $c0 + $cm, "$cm");
echo "== wear Fine as Lined\n";
$give('work-gloves-b-fine', 1);
[$a, $m] = wear_lined_toggle($u, 'work-gloves-b-lined');
ok('only a Fine wearable can be worn as Lined', !$a, $m);
ok('Fine, worn as Fine: rank 3', (array_column(wear_pieces(wear_owned($uid), wear_lined_set($uid)), null, 'key')['w:work-gloves-b']['rank'] ?? 0) === 3);
[$a, $m] = wear_lined_toggle($u, 'work-gloves-b-fine');
$pc = array_column(wear_pieces(wear_owned($uid), wear_lined_set($uid)), null, 'key')['w:work-gloves-b'] ?? [];
ok('switched to Lined: the piece is rank 2, same key', $a && ($pc['rank'] ?? 0) === 2 && ($pc['v'] ?? 0) < 8 && ($pc['ref'] ?? '') === 'work-gloves-b-lined', json_encode($pc));
[$a, $m] = wear_lined_toggle($u, 'work-gloves-b-fine');
ok('switched back to Fine', $a && (array_column(wear_pieces(wear_owned($uid), wear_lined_set($uid)), null, 'key')['w:work-gloves-b']['rank'] ?? 0) === 3);
echo "== behind the Puzzle combat setting\n";
set_setting('pfight_v1', '0'); setting('__reload__');
ok('setting Off: wearables are not live, for anyone', !wear_live() && !wear_live($u));
set_setting('pfight_v1', 'admin'); setting('__reload__');
ok('Admins only: live for an admin, not for a player', wear_live() && wear_live(['role' => 'admin']) && !wear_live(['role' => 'player']));
[$a, $m] = build_building($u, $plot, 'tailor');
ok('Admins only: a player cannot build the Tailor', !$a, $m);
set_setting('pfight_v1', '1'); setting('__reload__'); ok('On: live for all', wear_live(['role' => 'player']));
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
