<?php
// Creature part families (includes/parts.php) and any-<family> / rare-<family> recipe ingredients. Run by craft.sh on its install (gnome "sprout"): php tests/parts.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/crafting.php';
require_once APP_ROOT . '/includes/parts.php';
mt_srand(2758);
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function have(int $uid, string $slug): int { return (int)q_val('SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [$uid, $slug]); }
function mk(string $slug, string $cat, int $rar, int $price): int { return item_id_by_slug($slug) ?: (int)db_insert('items', ['name' => ucwords(str_replace('-', ' ', $slug)), 'slug' => $slug, 'category' => $cat, 'rarity' => $rar, 'base_price' => $price, 'description' => 'test', 'edible' => 0, 'tradable' => 1]); }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");

echo "== part_family\n";
$sample = ['wolf-pelt' => 'hide', 'rabbit-whisker' => 'hide', 'sheep-fleece' => 'hide', 'boar-bristle' => 'hide', 'hare-ear' => 'hide', 'fox-tail' => 'hide',
    'turtle-shell' => 'plate', 'eagle-talon' => 'plate', 'stag-tine' => 'plate', 'ant-chitin' => 'plate', 'frog-leg' => 'plate', 'hen-feather' => 'wing',
    'moth-wing' => 'wing', 'slug-slime' => 'ooze', 'spider-silk' => 'silk', 'sea-pearl' => 'gem', 'flea-legs' => 'plate', 'aphid-wings' => 'wing'];
foreach ($sample as $slug => $fam) ok("$slug is $fam", part_family($slug, 'part') === $fam, (string)part_family($slug, 'part'));
foreach (['stag-beetle-shell', 'dragonfly-wing', 'snow-moth-dust', 'seed-pearl', 'spiral-shell'] as $slug) ok("forage $slug excluded", part_family($slug, 'forage') === null);
ok('tailors-thread excluded', part_family('tailors-thread', 'part') === null);
ok('unmatched part has no family', part_family('puddle-hat', 'part') === null);
ok('six families', array_keys(PART_FAMILIES) === ['hide', 'plate', 'wing', 'ooze', 'silk', 'gem']);
ok('rarity 45 is rare', part_is_rare(['rarity' => 45]) && !part_is_rare(['rarity' => 44]));

echo "== craft_stock and craft_take\n";
$cheap = mk('zt-pelt', 'part', 10, 5); $mid = mk('zt-fur', 'part', 20, 9); $rare = mk('zt-hide', 'part', 60, 3);   // the rare one is the cheapest by price: it must still go last
$forage = mk('zt-forage-hair', 'forage', 5, 1);
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?,?,?,?)', [$uid, $cheap, $mid, $rare, $forage]);
give_item($uid, $cheap, 2); give_item($uid, $mid, 3); give_item($uid, $rare, 1); give_item($uid, $forage, 9);
$s = craft_stock($uid, json_encode(['any-hide' => 4, 'rare-hide' => 1]), 0);
ok('any-hide id 0 and label', $s['any-hide']['id'] === 0 && $s['any-hide']['name'] === 'any Hide part', json_encode($s['any-hide']));
ok('any-hide counts parts, not forage', $s['any-hide']['have'] === 6, (string)$s['any-hide']['have']);
ok('rare-hide counts the rare part', $s['rare-hide']['have'] === 1 && $s['rare-hide']['name'] === 'rare Hide part');
ok('any- lists cheapest first, rare last', array_column($s['any-hide']['any'], 0) === [$cheap, $mid, $rare], json_encode($s['any-hide']['any']));
$before = [have($uid, 'zt-pelt'), have($uid, 'zt-fur'), have($uid, 'zt-hide')];
db()->beginTransaction();
ok('take 4 any-hide', craft_take($uid, $s['any-hide'], 4));
db()->commit();
ok('cheapest went first, rare kept', [have($uid, 'zt-pelt'), have($uid, 'zt-fur'), have($uid, 'zt-hide')] === [0, 1, 1], json_encode([have($uid, 'zt-pelt'), have($uid, 'zt-fur'), have($uid, 'zt-hide')]));
$s = craft_stock($uid, json_encode(['any-hide' => 1]), 0);
db()->beginTransaction();
ok('take 1 rare-capable any takes the common one', craft_take($uid, $s['any-hide'], 1) && have($uid, 'zt-fur') === 0 && have($uid, 'zt-hide') === 1);
db()->commit();
ok('forage untouched', have($uid, 'zt-forage-hair') === 9);

echo "== recipe row and rollback\n";
ensure_crafts(); ensure_crafts();
$r = q_one("SELECT * FROM recipes WHERE slug = 'shell-meal-plate'");
ok('shell-meal-plate row, once', $r && $r['category'] === 'garden' && json_decode($r['ingredients'], true) === ['any-plate' => 2] && (int)$r['output_qty'] === 1 && (int)q_val("SELECT COUNT(*) FROM recipes WHERE slug = 'shell-meal-plate'") === 1, json_encode($r));
ok('no any-/rare- in cooking or pantry', !(int)q_val("SELECT COUNT(*) FROM recipes WHERE category IN ('cooking','pantry') AND (ingredients LIKE '%any-%' OR ingredients LIKE '%rare-%')"));
$p1 = mk('zt-scale', 'part', 10, 4); $p2 = mk('zt-claw', 'part', 50, 6);
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?,?)', [$uid, $p1, $p2]);
$plateOther = q('SELECT i.id FROM items i JOIN user_items ui ON ui.item_id = i.id AND ui.user_id = ? WHERE i.category = ?', [$uid, 'part'])->fetchAll(PDO::FETCH_COLUMN);
foreach ($plateOther as $pid) if (part_family((string)q_val('SELECT slug FROM items WHERE id = ?', [$pid]), 'part') === 'plate') q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $pid]);
if (!q_val("SELECT 1 FROM user_recipes WHERE user_id = ? AND recipe_id = ?", [$uid, $r["id"]])) db_insert("user_recipes", ["user_id" => $uid, "recipe_id" => $r["id"], "learned_at" => now()]);
q('UPDATE users SET energy = 100 WHERE id = ?', [$uid]);
give_item($uid, $p1, 1);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$sm0 = have($uid, 'shell-meal');
[$okc, $msg] = craft($u, (int)$r['id'], 1);
ok('short: 1 of 2 plates refuses', !$okc, $msg);
ok('short: nothing used, rolled back', have($uid, 'zt-scale') === 1 && have($uid, 'shell-meal') === $sm0 && !str_contains($msg, 'Fatal'), $msg);
ok('short: message names the family', str_contains($msg, 'any Plate part'), $msg);
give_item($uid, $p2, 1);
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
[$okc, $msg] = craft($u, (int)$r['id'], 1);
ok('2 plates make 1 Shell Meal', $okc && have($uid, 'shell-meal') === $sm0 + 1 && have($uid, 'zt-scale') === 0 && have($uid, 'zt-claw') === 0, $msg);

echo "== labels\n";
ok('label any', part_ingredient_label('any-plate') === 'any Plate part' && part_ingredient_label('rare-wing') === 'rare Wing part' && part_ingredient_label('flint') === null && part_ingredient_label('any-bogus') === null);
ok('recipe text uses label', recipe_ingredient_text('{"any-plate":2}') === '2 × any Plate part');
$rr = array_values(array_filter(craft_recipes($uid, 'garden'), fn($x) => $x['slug'] === 'shell-meal-plate'))[0] ?? null;
ok('craft_recipes ings label and have', $rr && $rr['ings'][0]['name'] === 'any Plate part' && $rr['ings'][0]['have'] === 0, json_encode($rr['ings'] ?? null));

echo "== drops matching no family\n";
$un = [];
foreach (q("SELECT slug FROM items WHERE category = 'part'")->fetchAll(PDO::FETCH_COLUMN) as $sl) if (strncmp($sl, 'zt-', 3) !== 0 && part_family($sl, 'part') === null) $un[] = $sl;
echo '  unmatched part slugs: ' . count($un) . ' ' . implode(' ', array_slice($un, 0, 40)) . "\n";
exit($fails ? 1 : 0);
