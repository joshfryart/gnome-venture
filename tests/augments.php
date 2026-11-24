<?php
// Tool augments and kit mending (includes/augments.php, creature-parts plan phase 1). Run by tools.sh on its install (gnome "sprout"): php tests/augments.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/crafting.php';
require_once APP_ROOT . '/includes/gathering.php';
require_once APP_ROOT . '/includes/parts.php';
require_once APP_ROOT . '/includes/pal_jobs.php';
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$have = fn(int $id) => (int)q_val('SELECT COALESCE((SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?), 0)', [$uid, $id]);
$row = fn(int $id) => q_one('SELECT wear, aug, aug_left, qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
$tid = fn(string $name) => (int)item_id_by_slug(tool_slug($name));
function setrow(int $uid, int $id, int $qty, int $wear = 0, ?string $aug = null, int $left = 0): void
{
    q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
    if ($qty > 0) db_insert('user_items', ['user_id' => $uid, 'item_id' => $id, 'qty' => $qty, 'wear' => $wear, 'aug' => $aug, 'aug_left' => $left]);
    tool_cache_reset();
}
function mkpart(string $slug, int $rar, int $price): int { return item_id_by_slug($slug) ?: (int)db_insert('items', ['name' => ucwords(str_replace('-', ' ', $slug)), 'slug' => $slug, 'category' => 'part', 'rarity' => $rar, 'base_price' => $price, 'description' => 'test', 'edible' => 0, 'tradable' => 1]); }
function augid(string $slug): int { return (int)item_id_by_slug($slug); }

pj_ensure_content(); ensure_crafts(); ensure_crafts();
set_setting('tool_wear_on', '1'); set_setting('tool_mend_percent', '15'); set_setting('tool_mend_kits', '1,2,4,8'); setting('__reload__');
q('DELETE FROM garden_buildings WHERE building = ? AND plot_id IN (SELECT id FROM plots WHERE user_id = ?)', ['tool_shed', $uid]);   // no free shed mend unless a test builds one
q('UPDATE users SET coins = 100000, energy = 100 WHERE id = ?', [$uid]);

echo "== schema, items, recipes\n";
ok('user_items.aug and aug_left exist', (bool)q_one('SELECT aug, aug_left FROM user_items LIMIT 1') || true);
foreach (['aug-hide-binding', 'aug-hide-binding-2', 'aug-plate-edge', 'aug-wing-fletch', 'aug-gem-charm', 'aug-ooze-salve', 'aug-silk-lashing'] as $s) {
    $it = q_one('SELECT category FROM items WHERE slug = ?', [$s]); $r = q_one('SELECT category, energy FROM recipes WHERE slug = ?', [$s]);
    ok("$s item (supply) and recipe (potions)", $it && $it['category'] === 'supply' && $r && $r['category'] === 'potions' && (int)$r['energy'] === energy_cost_scale(2), json_encode([$it, $r]));
}
ok('plate edge recipe', json_decode((string)q_val("SELECT ingredients FROM recipes WHERE slug = 'aug-plate-edge'"), true) === ['any-plate' => 5, 'flint' => 1]);
ok('silk kit row', ($r = q_one("SELECT * FROM recipes WHERE slug = 'tool-repair-kit-silk'")) && (int)$r['output_qty'] === 2 && json_decode($r['ingredients'], true) === ['any-silk' => 2, 'flint' => 1], json_encode($r));
ok('setting tool_mend_kits default', tool_mend_kit_list() === [1, 2, 4, 8]);

echo "== fitting\n";
$knife = $tid('Foraging Knife'); $fine = $tid('Fine Foraging Knife'); $hoe = $tid('Garden Hoe'); $wheel = $tid('Masterwork Wheel Hoe'); $trowel = $tid('Worn Trowel');
foreach ([$knife, $fine, $hoe, $wheel] as $t) ok('tool item exists', $t > 0);
foreach (array_merge(['aug-hide-binding', 'aug-plate-edge', 'aug-ooze-salve', 'aug-silk-lashing', 'aug-hide-binding-2', 'aug-wing-fletch', 'aug-gem-charm'], []) as $s) q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, augid($s)]);
setrow($uid, $knife, 1); setrow($uid, $hoe, 1); setrow($uid, $trowel, 1);
give_item($uid, augid('aug-plate-edge'), 1);
[$r, $m] = tool_fit_aug($uid, $knife, augid('aug-plate-edge'));
ok('plate edge fits a foraging knife', $r && $row($knife)['aug'] === 'aug-plate-edge' && (int)$row($knife)['aug_left'] === 40 && $have(augid('aug-plate-edge')) === 0, $m);
give_item($uid, augid('aug-plate-edge'), 1);
[$r] = tool_fit_aug($uid, $hoe, augid('aug-plate-edge'));
ok('plate edge does not fit a garden tool', !$r && $row($hoe)['aug'] === null && $have(augid('aug-plate-edge')) === 1);
[$r] = tool_fit_aug($uid, $trowel, augid('aug-hide-binding'));
ok('nothing to fit with no augment held / a tool that never wears', !$r);
give_item($uid, augid('aug-hide-binding'), 1);
[$r] = tool_fit_aug($uid, $trowel, augid('aug-hide-binding'));
ok('a Worn trowel never wears: nothing to bind', !$r && $have(augid('aug-hide-binding')) === 1);
[$r] = tool_fit_aug($uid, $knife, augid('aug-hide-binding'));
ok('one slot: a Hide Binding replaces the Plate Edge', $r && $row($knife)['aug'] === 'aug-hide-binding' && (int)$row($knife)['aug_left'] === 0, json_encode($row($knife)));
echo "-- tier 3 also takes one rare part of the family\n";
setrow($uid, $fine, 1);
give_item($uid, augid('aug-hide-binding'), 1);
q("DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE category = 'part')", [$uid]);
[$r, $m] = tool_fit_aug($uid, $fine, augid('aug-hide-binding'));
ok('Fine knife refuses without a rare Hide part', !$r && $row($fine)['aug'] === null && $have(augid('aug-hide-binding')) === 1, $m);
$rareHide = mkpart('zt-aug-hide', 60, 40); give_item($uid, $rareHide, 1);
[$r, $m] = tool_fit_aug($uid, $fine, augid('aug-hide-binding'));
ok('with a rare Hide part it fits and takes the part', $r && $row($fine)['aug'] === 'aug-hide-binding' && $have($rareHide) === 0, $m);

echo "== wear limit\n";
$kn = q_one('SELECT * FROM items WHERE id = ?', [$knife]);
setrow($uid, $knife, 1); setrow($uid, $knife, 1);
$base = tool_wear_limit('forage', 1);
ok('no augment: base limit', tool_wear_limit_for($uid, $kn) === $base);
setrow($uid, $knife, 1, 0, 'aug-hide-binding', 0);
ok('Hide Binding +25%', tool_wear_limit_for($uid, $kn) === (int)ceil($base * 1.25), (string)tool_wear_limit_for($uid, $kn));
setrow($uid, $knife, 1, 0, 'aug-hide-binding-2', 0);
ok('Hide Binding II +50%', tool_wear_limit_for($uid, $kn) === (int)ceil($base * 1.5));
ok('tool_wear_info uses it', tool_wear_info($kn, 0, $uid)['limit'] === (int)ceil($base * 1.5) && tool_wear_info($kn, 0)['limit'] === $base);
setrow($uid, $knife, 1, $base - 1, 'aug-hide-binding-2', 0);   // one use from the base limit: still fine
$msg = tool_use($uid, 'forage');
ok('a bound tool does not break at the base limit', $msg === null || !str_contains((string)$msg, 'broke'), (string)$msg);
ok('it still has its row', $have($knife) === 1);

echo "== break and mend keep the augment\n";
$hbox = (int)item_id_by_slug('broken-' . tool_slug('Foraging Knife'));
setrow($uid, $knife, 1, 5, 'aug-plate-edge', 17);
$msg = tool_break($uid, $kn);
$bid = (int)item_id_by_slug('broken-' . tool_slug('Foraging Knife'));
ok('last copy: working row gone, Broken row carries the augment', $have($knife) === 0 && $have($bid) === 1 && $row($bid)['aug'] === 'aug-plate-edge' && (int)$row($bid)['aug_left'] === 17, json_encode($row($bid)));
q('UPDATE users SET coins = 100000 WHERE id = ?', [$uid]);
[$r, $m] = mend_tool($uid, $bid);
ok('mend copies it back and resets wear', $r && $have($bid) === 0 && $row($knife)['aug'] === 'aug-plate-edge' && (int)$row($knife)['aug_left'] === 17 && (int)$row($knife)['wear'] === 0, $m . json_encode($row($knife)));
echo "-- a spare copy keeps the shared augment\n";
setrow($uid, $knife, 2, 5, 'aug-plate-edge', 9);
tool_break($uid, $kn);
$r1 = $row($knife);
ok('stack of two: one breaks, the working one keeps the augment, wear starts fresh', (int)$r1['qty'] === 1 && $r1['aug'] === 'aug-plate-edge' && (int)$r1['aug_left'] === 9 && (int)$r1['wear'] === 0 && $row($bid)['aug'] === null, json_encode([$r1, $row($bid)]));
[$r] = mend_tool($uid, $bid);
ok('mending the second joins the stack with the same augment', $r && (int)$row($knife)['qty'] === 2 && $row($knife)['aug'] === 'aug-plate-edge' && (int)$row($knife)['aug_left'] === 9);
echo "-- a worn (not broken) tool keeps it too\n";
setrow($uid, $knife, 1, 7, 'aug-ooze-salve', 3);
mend_tool($uid, $knife);
ok('worn tool mend: wear 0; ooze salve spent one', (int)$row($knife)['wear'] === 0 && $row($knife)['aug'] === 'aug-ooze-salve' && (int)$row($knife)['aug_left'] === 2, json_encode($row($knife)));

echo "== Plate Edge\n";
$GLOBALS['aug_seeded'] = true; mt_srand(2758);
$here = [];
foreach ([['common', 'c1'], ['common', 'c2'], ['uncommon', 'u1'], ['uncommon', 'u2'], ['rare', 'r1']] as [$rar, $sl]) $here[] = ['tool' => 'forage', 'rarity' => $rar, 'item_id' => 1, 'slug' => $sl, 'name' => $sl, 'cond' => ''];
$here[] = ['tool' => 'pick', 'rarity' => 'uncommon', 'item_id' => 1, 'slug' => 'other-tool', 'name' => 'x', 'cond' => ''];
foreach ([$fine, $tid('Hooked Forager’s Knife')] as $other) setrow($uid, $other, 0);   // the knife under test must be the best forage tool
setrow($uid, $knife, 1);   // a tier 1 knife gathers only common finds
ok('tier 1 knife', tool_tier($uid, 'forage') >= 1);
$aug = function (int $left) use ($uid, $knife) { q("UPDATE user_items SET aug = 'aug-plate-edge', aug_left = ? WHERE user_id = ? AND item_id = ?", [$left, $uid, $knife]); };
$aug(40); $n = 0; $swaps = 0; $notes = [];
db()->beginTransaction();
for ($i = 0; $i < 4000; $i++) {
    $aug(40);
    $p = aug_plate_edge($uid, $here[0], $here, [], $notes);
    if ($p['rarity'] === 'uncommon') { $swaps++; if ($p['tool'] !== 'forage') $swaps += 1000; }
    elseif ($p['rarity'] !== 'common') $swaps += 100000;
}
db()->commit();
ok("seeded: $swaps swaps in 4000 picks is 22-28%", $swaps >= 880 && $swaps <= 1120, (string)$swaps);
$aug(40); $up = 0; $rare = 0;
for ($i = 0; $i < 400; $i++) { $aug(40); $p = aug_plate_edge($uid, $here[2], $here, [], $notes); if ($p['rarity'] === 'rare') $rare++; elseif ($p['rarity'] !== 'uncommon') $rare += 1000; }
ok('an uncommon find can go to rare (one step), never beyond', $rare > 40 && $rare < 200, (string)$rare);
$aug(40); $rareHeld = 0;
for ($i = 0; $i < 200; $i++) { $p = aug_plate_edge($uid, $here[4], $here, [], $notes); if ($p['rarity'] !== 'rare') $rareHeld++; }
ok('a rare find stays rare and spends no use', $rareHeld === 0 && (int)$row($knife)['aug_left'] === 40);
$aug(40); $swaps = 0;
for ($i = 0; $i < 20000 && $row($knife)['aug'] !== null; $i++) { $p = aug_plate_edge($uid, $here[0], $here, [], $notes); if ($p['rarity'] === 'uncommon') $swaps++; $l = $row($knife); if ($l['aug'] !== null) { if ((int)$l['aug_left'] !== 40 - $swaps) { $swaps = -1; break; } } }
ok('uses only go down on a swap; cleared after 40 swaps', $swaps === 40 && $row($knife)['aug'] === null && (int)$row($knife)['aug_left'] === 0, (string)$swaps);
$p = aug_plate_edge($uid, $here[0], $here, [], $notes);
ok('no augment: no swap', $p['rarity'] === 'common');
$GLOBALS['aug_seeded'] = false;

echo "== Gem Charm, Wing Fletch\n";
setrow($uid, $knife, 1, 0, 'aug-gem-charm', 30);
ok('Gem Charm: Luck +4 for that tool only', aug_gem_luck($uid, 'forage') === 4 && aug_gem_luck($uid, 'pick') === 0);
$GLOBALS['aug_seeded'] = true; mt_srand(2758);
setrow($uid, $knife, 1, 0, 'aug-wing-fletch', 25000);
$bonus = 0; $nn = [];
for ($i = 0; $i < 2000; $i++) $bonus += aug_wing_bonus($uid, 'forage', $nn);
ok("Wing Fletch: $bonus of 2000 finds got +1 (31-39%)", $bonus >= 620 && $bonus <= 780, (string)$bonus);
ok('its uses went down once per bonus', (int)$row($knife)['aug_left'] === 25000 - $bonus, json_encode($row($knife)));
$GLOBALS['aug_seeded'] = false;
setrow($uid, $knife, 1, 0, 'aug-wing-fletch', 1);
$GLOBALS['aug_seeded'] = true; mt_srand(7); for ($i = 0; $i < 50 && $row($knife)['aug'] !== null; $i++) aug_wing_bonus($uid, 'forage', $nn); $GLOBALS['aug_seeded'] = false;
ok('the last use clears it', $row($knife)['aug'] === null);

echo "== kit mending by tier\n";
$kit = (int)item_id_by_slug('tool-repair-kit'); ok('tool repair kit item', $kit > 0);
$hide = mkpart('zt-aug-pelt', 10, 5); $rareP = mkpart('zt-aug-fur', 60, 5);
$clean = function () use ($uid, $kit, $hide, $rareP) { q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?,?,?)', [$uid, $kit, $hide, $rareP]); q("DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE category = 'part')", [$uid]); q('UPDATE users SET coins = 100000, free_mend_day = NULL, free_mend_n = 0 WHERE id = ?', [$uid]); };
$sturdy = $tid('Hooked Forager’s Knife');
$cases = [[1, $knife, 1], [2, $sturdy, 2], [3, $fine, 4], [4, $wheel, 8]];
foreach ($cases as [$tier, $t, $need]) {
    $clean(); setrow($uid, $t, 1, 5);
    $kitsHeld = $need - 1; if ($kitsHeld) give_item($uid, $kit, $kitsHeld);
    if ($tier === 3) give_item($uid, $hide, 1);
    if ($tier === 4) give_item($uid, $rareP, 1);
    $c0 = $coins();
    [$r, $m] = mend_tool($uid, $t);
    if ($tier === 1) {
        ok('tier 1 with no kit: Petals', $r && $coins() < $c0 && $row($t)['wear'] == 0, $m);
        $clean(); setrow($uid, $t, 1, 5); give_item($uid, $kit, 1); $c0 = $coins();
        [$r, $m] = mend_tool($uid, $t);
        ok('tier 1 with 1 kit: kit used, no Petals', $r && $have($kit) === 0 && $coins() === $c0 && (int)$row($t)['wear'] === 0, $m);
        continue;
    }
    ok("tier $tier one kit short: Petals, kits kept", $r && $coins() < $c0 && $have($kit) === $kitsHeld, $m);
    $clean(); setrow($uid, $t, 1, 5); give_item($uid, $kit, $need + 1);
    if ($tier === 3) give_item($uid, $hide, 1); if ($tier === 4) give_item($uid, $rareP, 1);
    $c0 = $coins();
    [$r, $m] = mend_tool($uid, $t);
    ok("tier $tier: $need kits (and a part) used, no Petals", $r && $have($kit) === 1 && $coins() === $c0 && (int)$row($t)['wear'] === 0 && ($tier < 3 || ($have($hide) + $have($rareP)) === 0), $m);
}
echo "-- tier 3 and 4 part rules\n";
$clean(); setrow($uid, $fine, 1, 5); give_item($uid, $kit, 4); $c0 = $coins();
[$r, $m] = mend_tool($uid, $fine);
ok('tier 3 with 4 kits but no part: Petals', $r && $coins() < $c0 && $have($kit) === 4, $m);
$clean(); setrow($uid, $wheel, 1, 5); give_item($uid, $kit, 8); give_item($uid, $hide, 1); $c0 = $coins();
[$r, $m] = mend_tool($uid, $wheel);
ok('tier 4 with a common part only: Petals, nothing spent', $r && $coins() < $c0 && $have($kit) === 8 && $have($hide) === 1, $m);
echo "-- a worn garden tool and a lantern are mended by kits too\n";
$clean(); setrow($uid, $hoe, 1, 5); give_item($uid, $kit, 2); $c0 = $coins();
[$r] = mend_tool($uid, $hoe);
ok('garden hoe (tier 2): 2 kits', $r && $have($kit) === 0 && $coins() === $c0);
echo "-- setting 0 switches kits off for a tier\n";
set_setting('tool_mend_kits', '0,0,0,0'); setting('__reload__');
$clean(); setrow($uid, $knife, 1, 5); give_item($uid, $kit, 5); $c0 = $coins();
[$r] = mend_tool($uid, $knife);
ok('0,0,0,0: Petals only', $r && $coins() < $c0 && $have($kit) === 5);
set_setting('tool_mend_kits', '1,2,4,8'); setting('__reload__');

echo "== Silk Lashing\n";
$clean(); setrow($uid, $sturdy, 1, 5, 'aug-silk-lashing', 40); give_item($uid, $kit, 1); $c0 = $coins();
[$r, $m] = mend_tool($uid, $sturdy);
ok('tier 2 needs 2 kits, a Lashing makes it 1', $r && $have($kit) === 0 && $coins() === $c0 && (int)$row($sturdy)['aug_left'] === 39 && (int)$row($sturdy)['wear'] === 0, $m . json_encode($row($sturdy)));
$clean(); setrow($uid, $knife, 1, 5, 'aug-silk-lashing', 40); give_item($uid, $kit, 1);
[$r, $m] = mend_tool($uid, $knife);
ok('tier 1 stays at 1 kit (floor) and spends no Lashing use', $r && $have($kit) === 0 && (int)$row($knife)['aug_left'] === 40, $m);
$clean(); setrow($uid, $wheel, 1, 5, 'aug-silk-lashing', 40); give_item($uid, $kit, 7); give_item($uid, $rareP, 1);
[$r] = mend_tool($uid, $wheel);
ok('tier 4: 7 kits with a Lashing', $r && $have($kit) === 0 && (int)$row($wheel)['aug_left'] === 39);
$clean(); setrow($uid, $sturdy, 1, 5, 'aug-silk-lashing', 1); give_item($uid, $kit, 2);
mend_tool($uid, $sturdy);
ok('the last Lashing use clears it', $row($sturdy)['aug'] === null && $have($kit) === 1);

echo "== Ooze Salve\n";
$clean(); setrow($uid, $sturdy, 1, 5, 'aug-ooze-salve', 3);
$c0 = $coins();
for ($i = 1; $i <= 3; $i++) { q('UPDATE user_items SET wear = 5 WHERE user_id = ? AND item_id = ?', [$uid, $sturdy]); [$r, $m] = mend_tool($uid, $sturdy); ok("free Petal mend $i of 3", $r && $coins() === $c0, $m); }
ok('salve used up after 3', $row($sturdy)['aug'] === null);
q('UPDATE user_items SET wear = 5 WHERE user_id = ? AND item_id = ?', [$uid, $sturdy]); mend_tool($uid, $sturdy);
ok('the fourth mend costs Petals', $coins() < $c0);
echo "-- kits come before the salve\n";
$clean(); setrow($uid, $knife, 1, 5, 'aug-ooze-salve', 3); give_item($uid, $kit, 1);
mend_tool($uid, $knife);
ok('kit used, salve kept', $have($kit) === 0 && (int)$row($knife)['aug_left'] === 3);
echo "-- the salve survives a break and a mend\n";
$clean(); setrow($uid, $sturdy, 1, 5, 'aug-ooze-salve', 3);
$st = q_one('SELECT * FROM items WHERE id = ?', [$sturdy]); tool_break($uid, $st);
$sb = (int)item_id_by_slug('broken-' . $st['slug']); $c0 = $coins();
[$r, $m] = mend_tool($uid, $sb);
ok('Broken copy mended free with the salve, 2 left', $r && $coins() === $c0 && $row($sturdy)['aug'] === 'aug-ooze-salve' && (int)$row($sturdy)['aug_left'] === 2, $m . json_encode($row($sturdy)));

echo "== the Tool Shed's free mend comes first, then kits\n";
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? LIMIT 1', [$uid]);
if (!$plot) { db_insert('plots', ['user_id' => $uid, 'name' => 'Test']); $plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? LIMIT 1', [$uid]); }
q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'tool_shed'", [$plot]);
q("INSERT INTO garden_buildings (plot_id, building, level, built_at) VALUES (?, 'tool_shed', 1, ?)", [$plot, now()]);
$clean(); setrow($uid, $knife, 1, 5, 'aug-ooze-salve', 3); give_item($uid, $kit, 1);
[$r, $m] = mend_tool($uid, $knife);
ok('shed mend free: kit and salve kept', $r && str_contains($m, 'Tool Shed') && $have($kit) === 1 && (int)$row($knife)['aug_left'] === 3, $m);
q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'tool_shed'", [$plot]);

echo "== trade block\n";
setrow($uid, $knife, 1, 0, 'aug-plate-edge', 10);
ok('a tool with an augment cannot be traded', tool_trade_block($uid, $knife) !== null, (string)tool_trade_block($uid, $knife));
setrow($uid, $knife, 1, 0);
ok('without one it can', tool_trade_block($uid, $knife) === null);
setrow($uid, $bid, 1, 0, 'aug-plate-edge', 10);
ok('a Broken copy cannot be gifted', tool_trade_block($uid, $bid) !== null);
setrow($uid, $bid, 0);

echo "== upgrade carries the augment\n";
$clean(); ensure_crafts();
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? LIMIT 1', [$uid]);
q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'tool_shed'", [$plot]);
q("INSERT INTO garden_buildings (plot_id, building, level, built_at) VALUES (?, 'tool_shed', 4, ?)", [$plot, now()]);
$rec = q_one("SELECT * FROM recipes WHERE slug = 'masterwork-wheel-hoe'");
ok('masterwork-wheel-hoe uses up the Steel Spade', $rec && isset(json_decode($rec['ingredients'], true)['steel-spade']));
$spade = (int)item_id_by_slug('steel-spade');
setrow($uid, $spade, 1, 0, 'aug-hide-binding', 0); setrow($uid, $wheel, 0);
foreach (['bog-iron' => 2, 'flint' => 4] as $s => $n) { $i = (int)item_id_by_slug($s); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $i]); give_item($uid, $i, $n); }
q('INSERT OR IGNORE INTO user_recipes (user_id, recipe_id, learned_at) VALUES (?, ?, ?)', [$uid, (int)$rec['id'], now()]);
q('UPDATE users SET energy = 100 WHERE id = ?', [$uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
[$r, $m] = craft($u, (int)$rec['id'], 1);
ok('crafted the Masterwork Wheel Hoe', $r && $have($wheel) === 1 && $have($spade) === 0, $m);
q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'tool_shed'", [$plot]);
ok('the Hide Binding moved to the new tool', $row($wheel)['aug'] === 'aug-hide-binding', json_encode($row($wheel)));

echo "== Satchel UI\n";
setrow($uid, $knife, 1, 3); give_item($uid, augid('aug-plate-edge'), 1);
$html = tool_wear_html($uid, q_one('SELECT * FROM items WHERE id = ?', [$knife]), 3, '');
ok('the tool panel has a fit form and a mend button', str_contains($html, 'name="do" value="fit_aug"') && str_contains($html, 'Plate Edge') && str_contains($html, 'name="do" value="mend"'), $html);

echo $fails ? "AUGMENTS FAILS: $fails\n" : "augments: all ok\n";
exit($fails ? 1 : 0);
