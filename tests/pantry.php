<?php
// v0.9.8 part A: the Pantry. Run by pantry.sh on the world walk.sh made (player "sprout"): php pantry.php GAME [npc]
//   "npc": prints the id of a townsfolk who dislikes home cooking (for the gift test) and exits.
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
require_once $argv[1] . '/includes/friends.php';
require_once $argv[1] . '/includes/world.php';
require_once $argv[1] . '/includes/fair.php';
set_setting('price_drift_on', '0'); setting('__reload__');   // v1.1.0: the worth-ratio check compares base prices; weekly price drift made it flaky
require_once $argv[1] . '/includes/trade.php';
set_exception_handler(function (Throwable $e) { echo '  FAIL uncaught ' . get_class($e) . ': ' . $e->getMessage() . ' at ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
if (session_status() !== PHP_SESSION_ACTIVE) session_start();

if (($argv[2] ?? '') === 'npc') {
    $pre = (int)q_val("SELECT id FROM items WHERE slug = 'dill-pickles'");
    foreach (q('SELECT * FROM npcs WHERE active = 1 ORDER BY id')->fetchAll() as $n) {
        $t = npc_tastes($n);
        if ($t['disliked'] === 'food' && $t['loved'] !== $pre && !in_array('food', $t['liked'], true)) { echo $n['id'], "\n"; exit; }
    }
    echo q_val('SELECT id FROM npcs WHERE active = 1 ORDER BY id LIMIT 1'), "\n";
    exit;
}

$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);

echo "== stacking: 5 jars, +2 at Kitchen III, +1 per other Pantry up to +3\n";
$p1 = (int)q_val('SELECT id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
q('DELETE FROM garden_buildings WHERE plot_id IN (SELECT id FROM plots WHERE user_id = ?)', [$uid]);
q('DELETE FROM plots WHERE user_id = ? AND id <> ?', [$uid, $p1]);
$jars = fn() => pantry_jar_limit($uid);
ok('no Kitchen: 0 jars', $jars() === 0);
q("INSERT INTO garden_buildings (plot_id, building, built_at, last_collect, level, pantry) VALUES (?, 'kitchen', ?, ?, 1, 0)", [$p1, now(), now()]);
ok('Kitchen without a Pantry: 0 jars', $jars() === 0, (string)$jars());
q("UPDATE garden_buildings SET pantry = 1 WHERE plot_id = ?", [$p1]);
ok('Kitchen I + Pantry: 5 jars', $jars() === 5, (string)$jars());
q("UPDATE garden_buildings SET level = 2 WHERE plot_id = ?", [$p1]);
ok('Kitchen II: still 5', $jars() === 5);
q("UPDATE garden_buildings SET level = 3 WHERE plot_id = ?", [$p1]);
ok('Kitchen III + Pantry: 7 jars', $jars() === 7, (string)$jars());
$g2 = create_garden($uid, null, null, 'Second');
q("INSERT INTO garden_buildings (plot_id, building, built_at, last_collect, level, pantry) VALUES (?, 'kitchen', ?, ?, 3, 0)", [$g2, now(), now()]);
ok('a Kitchen III elsewhere WITHOUT a Pantry adds nothing', $jars() === 7, (string)$jars());
q("UPDATE garden_buildings SET pantry = 1, level = 1 WHERE plot_id = ?", [$g2]);
ok('+1 for a second Pantry: 8', $jars() === 8, (string)$jars());
$g3 = create_garden($uid, null, null, 'Third'); q("INSERT INTO garden_buildings (plot_id, building, built_at, last_collect, level, pantry) VALUES (?, 'kitchen', ?, ?, 1, 1)", [$g3, now(), now()]);
ok('third Pantry: 9', $jars() === 9);
$g4 = create_garden($uid, null, null, 'Fourth'); q("INSERT INTO garden_buildings (plot_id, building, built_at, last_collect, level, pantry) VALUES (?, 'kitchen', ?, ?, 1, 1)", [$g4, now(), now()]);
ok('fourth Pantry: 10 (+3 cap reached)', $jars() === 10);
$g5 = create_garden($uid, null, null, 'Fifth'); q("INSERT INTO garden_buildings (plot_id, building, built_at, last_collect, level, pantry) VALUES (?, 'kitchen', ?, ?, 1, 1)", [$g5, now(), now()]);
ok('fifth Pantry: still 10', $jars() === 10, (string)$jars());
q("UPDATE garden_buildings SET level = 1 WHERE plot_id = ?", [$p1]);
ok('best Kitchen back to I, others I: 5 + 3 = 8', $jars() === 8, (string)$jars());
q("UPDATE garden_buildings SET level = 3 WHERE plot_id = ?", [$g5]);
ok('Kitchen III in another garden WITH a Pantry also gives the +2: 10', $jars() === 10, (string)$jars());
set_setting('pantry_jars', '6'); set_setting('stack_pantry_jar_max', '1'); setting('__reload__');
ok('admin settings: 6 jars, other-garden cap +1: 6 + 2 + 1 = 9', $jars() === 9, (string)$jars());
q("DELETE FROM settings WHERE name IN ('pantry_jars', 'stack_pantry_jar_max')"); setting('__reload__');
ok('settings back to default: 10', $jars() === 10);
q('DELETE FROM garden_buildings WHERE plot_id <> ?', [$p1]); q('DELETE FROM plots WHERE user_id = ? AND id <> ?', [$uid, $p1]);
q("UPDATE garden_buildings SET level = 3, pantry = 1 WHERE plot_id = ?", [$p1]);
ok('back to one K3 Pantry: 7', $jars() === 7);
$peek = building_peek(q_one('SELECT * FROM plots WHERE id = ?', [$p1]), 'kitchen');
ok('visitors see shelves of jars through the door', $peek && str_contains(implode(' ', $peek[1]), 'jars'), json_encode($peek));
ok('home_dish_tier(preserve) is "preserve"', home_dish_tier((int)q_val("SELECT id FROM items WHERE slug = 'plum-jam'")) === 'preserve');
ok('home_dish_tier(soup) is still "meal"', home_dish_tier((int)q_val("SELECT id FROM items WHERE slug = 'garden-vegetable-soup'")) === 'meal');

echo "== prices: a batch sells for more than its crops, and more the longer it takes\n";
$byTimer = [];
foreach (q("SELECT r.*, i.id AS item_id FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.category = 'pantry'")->fetchAll() as $r) {
    $item = q_one('SELECT * FROM items WHERE id = ?', [$r['item_id']]);
    $batch = sell_price($item) * (int)$r['output_qty'];
    $raw = 0;
    foreach (json_decode($r['ingredients'], true) as $slug => $n) $raw += sell_price(q_one('SELECT * FROM items WHERE slug = ?', [$slug])) * (int)$n;
    ok(sprintf('%-22s batch %4d > crops %4d', $r['slug'], $batch, $raw), $batch > $raw);
    $byTimer[(int)$r['cook_minutes']][] = $batch / max(1, $raw);
}
ksort($byTimer);
$avg = array_map(function ($a) { sort($a); return $a[intdiv(count($a), 2)]; }, $byTimer);   // the median: the 20-coin floor lifts the cheapest batches, which skews a mean
ok('worth ratio (median) rises with the timer: ' . implode(' < ', array_map(fn($x) => number_format($x, 2), $avg)), array_values($avg) === (function ($a) { sort($a); return $a; })(array_values($avg)) && count(array_unique(array_map(fn($x) => round($x, 2), $avg))) === count($avg));

echo "== preserve pricing: the same on every world, no stale-cache Legendary mispricing, new time curve\n";
require_once $argv[1] . '/includes/catalog.php';
require_once $argv[1] . '/includes/pantry.php';
require_once $argv[1] . '/includes/items.php';
$FL = item_lookups();   // fresh, after every plant and gatherable exists
$off = [];
foreach (q("SELECT r.slug, r.ingredients, r.cook_minutes, r.output_qty, i.base_price FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.category = 'pantry' AND r.tier = 'preserve'")->fetchAll() as $r) {
    $want = preserve_price(json_decode($r['ingredients'], true), (int)$r['cook_minutes'], (int)$r['output_qty'], $FL);
    if ($want !== (int)$r['base_price']) $off[] = $r['slug'] . ' ' . $r['base_price'] . '!=' . $want;
}
ok('every installed preserve costs what a fresh item_lookups() says (no stale cache, no install-week drift)', !$off, implode('; ', array_slice($off, 0, 8)));
foreach (['jostaberry-jam', 'pluot-jam', 'nectaplum-jam', 'meyer-lemon-marmalade', 'tangelo-marmalade', 'pickled-fiddleheads'] as $sl) {   // their crops are Common: Common shop value is floor(base x 60%), the stale cache read them as x2.5
    $r = q_one('SELECT r.*, i.base_price AS bp FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.slug = ?', [$sl]);
    $v = 0; foreach (json_decode($r['ingredients'], true) as $ing => $n) $v += (int)floor((int)q_val('SELECT base_price FROM items WHERE slug = ?', [$ing]) * 0.6) * (int)$n;
    $want = max(20, (int)ceil($v * (1 + 0.8 * ($r['cook_minutes'] / 1440) ** 0.6) / (int)$r['output_qty'] / 0.6));
    ok("$sl is priced as Common crops would make it, not about 2.6x ($r[bp])", (int)$r['bp'] === $want, "want $want");
}
set_setting('price_drift_on', '1'); setting('__reload__');
$withDrift = []; foreach (['plum-jam', 'elderberry-cordial'] as $sl) { $r = q_one('SELECT * FROM recipes WHERE slug = ?', [$sl]); $withDrift[$sl] = preserve_price(json_decode($r['ingredients'], true), (int)$r['cook_minutes'], (int)$r['output_qty'], $FL); }
set_setting('price_drift_on', '0'); setting('__reload__');
$noDrift = []; foreach (['plum-jam', 'elderberry-cordial'] as $sl) { $r = q_one('SELECT * FROM recipes WHERE slug = ?', [$sl]); $noDrift[$sl] = preserve_price(json_decode($r['ingredients'], true), (int)$r['cook_minutes'], (int)$r['output_qty'], $FL); }
ok('preserve_price ignores weekly price drift', $withDrift === $noDrift, json_encode([$withDrift, $noDrift]));
$straw = q_one("SELECT i.* FROM plants p JOIN items i ON i.id = p.produce_item_id WHERE p.slug = 'strawberry'");
$v1 = flat_sell_value($straw, $FL);
ok('time curve: 1 day = x1.8 (jams unchanged)', preserve_price(['strawberry' => 10], 1440, 1, $FL) === (int)ceil($v1 * 10 * 1.8 / 0.6));
ok('time curve: 14 days = 1 + 0.8 x 14^0.6 (x4.8)', preserve_price(['strawberry' => 10], 20160, 1, $FL) === (int)ceil($v1 * 10 * (1 + 0.8 * 14 ** 0.6) / 0.6));
ok('a missing crop prices nothing', preserve_price(['no-such-crop' => 1], 1440, 3, $FL) === null);
// the one-off re-price for worlds that already have the bad prices
$bugged = ['jostaberry-jam', 'pluot-jam', 'pickled-fiddleheads'];
$good = []; foreach ($bugged as $sl) $good[$sl] = (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$sl]);
foreach ($bugged as $sl) q('UPDATE items SET base_price = ? WHERE slug = ?', [(int)round($good[$sl] * 2.6), $sl]);   // as the old import left them
q("UPDATE items SET base_price = 7 WHERE slug = 'nectaplum-jam'");                                                  // an admin set this one low: never touched
$plumGood = (int)q_val("SELECT base_price FROM items WHERE slug = 'plum-jam'"); q('UPDATE items SET base_price = ? WHERE slug = ?', [$plumGood * 3, 'plum-jam']);   // no hybrid crop in it: not the bug
$adminHi = (int)q_val("SELECT base_price FROM items WHERE slug = 'tangelo-marmalade'"); q("UPDATE items SET base_price = ? WHERE slug = 'tangelo-marmalade'", [(int)round($adminHi * 1.5)]);   // an admin's own price, well under 1.8x
q("DELETE FROM settings WHERE name = 'upg_pantry_reprice'"); setting('__reload__');
$n = pantry_reprice_run();
ok('re-price step fixes exactly the bugged jars (' . $n . ')', $n === count($bugged));
foreach ($bugged as $sl) ok("$sl back to $good[$sl]", (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$sl]) === $good[$sl]);
ok('an admin-lowered price stays', (int)q_val("SELECT base_price FROM items WHERE slug = 'nectaplum-jam'") === 7);
ok('an admin price under 1.8x of the right one stays', (int)q_val("SELECT base_price FROM items WHERE slug = 'tangelo-marmalade'") === (int)round($adminHi * 1.5));
ok('a jar with no mispriced crop stays, whatever its price', (int)q_val("SELECT base_price FROM items WHERE slug = 'plum-jam'") === $plumGood * 3);
ok('the step sets its flag and a second run changes nothing', setting('upg_pantry_reprice') === '1' && pantry_reprice_run() === 0);
q('UPDATE items SET base_price = ? WHERE slug = ?', [$plumGood, 'plum-jam']); q("UPDATE items SET base_price = ? WHERE slug = 'tangelo-marmalade'", [$adminHi]);
$nectaGood = preserve_price(json_decode((string)q_val("SELECT ingredients FROM recipes WHERE slug = 'nectaplum-jam'"), true), 1440, 4, $FL); q('UPDATE items SET base_price = ? WHERE slug = ?', [$nectaGood, 'nectaplum-jam']);

echo "== the Fair: Preserves class judged like the others\n";
$mk = function (string $name) use ($uid): int {
    $row = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    unset($row['id']);
    $row['username'] = $name; $row['email'] = $name . '@b.local'; $row['gnome_name'] = ucfirst($name);
    return db_insert('users', $row);
};
$a = $mk('jarra'); $b = $mk('jarrb');
$prev = fair_prev_month();
q("DELETE FROM fair_entries WHERE cat = 'preserve'"); q("DELETE FROM fair_best WHERE cat = 'preserve'"); q("DELETE FROM fair_ribbons WHERE cat = 'preserve'");
ok('no jar yet: cannot enter', fair_enter($u(), 'preserve')[0] === false);
fair_keep_best($uid, 'preserve', 0, 55, 'Strawberry Jam');
fair_keep_best($uid, 'preserve', 0, 50, 'Plum Jam');
ok('best of the month keeps the better jar', q_val("SELECT label || score FROM fair_best WHERE user_id = ? AND cat = 'preserve'", [$uid]) === 'Strawberry Jam55');
fair_keep_best($uid, 'preserve', 0, 61, 'Elderberry Cordial');
[$e1, $m1] = fair_enter($u(), 'preserve');
ok('enter: ' . $m1, $e1 && str_contains($m1, 'Preserves class') && str_contains($m1, 'Elderberry Cordial'));
ok('entering again with nothing better: refused', fair_enter($u(), 'preserve')[0] === false);
foreach ([[$a, 70, 'Kimchi'], [$b, 40, 'Sauerkraut']] as [$g, $sc, $nm]) {
    db_insert('fair_entries', ['user_id' => $g, 'month' => job_period_key('monthly'), 'cat' => 'preserve', 'plant_id' => 0, 'score' => $sc, 'at' => now(), 'label' => $nm]);
}
q("UPDATE fair_entries SET month = ? WHERE cat = 'preserve'", [$prev]);
$coins0 = [$uid => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]), $a => (int)q_val('SELECT coins FROM users WHERE id = ?', [$a])];
fair_judge($prev);
$place = fn(int $g) => (int)q_val("SELECT place FROM fair_ribbons WHERE user_id = ? AND month = ? AND cat = 'preserve'", [$g, $prev]);
ok('ranking by score: Kimchi 1st, cordial 2nd, sauerkraut 3rd', $place($a) === 1 && $place($uid) === 2 && $place($b) === 3, sprintf('%d/%d/%d', $place($a), $place($uid), $place($b)));
ok('winner paid', (int)q_val('SELECT coins FROM users WHERE id = ?', [$a]) > $coins0[$a]);
ok('every entry marked placed', (int)q_val("SELECT COUNT(*) FROM fair_entries WHERE cat = 'preserve' AND placed IS NULL") === 0);
$note = (string)q_val("SELECT text FROM notices WHERE user_id = ? AND text LIKE '%Preserves%' ORDER BY id DESC LIMIT 1", [$a]);
ok('notice names the preserve and the class', str_contains($note, 'Kimchi') && str_contains($note, 'Preserves'), $note);
$c1 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$a]);
fair_judge($prev);
ok('judging again pays nothing more', (int)q_val('SELECT coins FROM users WHERE id = ?', [$a]) === $c1);
ok('fair_cat() never routes a harvest to Preserves', fair_cat('vegetable') === 'veg' && fair_cat('preserve') === null);
ok('ribbon label reads Preserves', fair_cat_label('preserve') === 'Preserves');

echo "== jobs and callings: a preserve is a craft, never a meal\n";
require_once $argv[1] . '/includes/jobs.php';
q('DELETE FROM user_jobs WHERE user_id = ?', [$uid]);
$jk = job_period_key('daily');
foreach (['cook', 'craft'] as $k) {
    db_insert('user_jobs', ['user_id' => $uid, 'period' => 'daily', 'period_key' => $jk, 'kind' => $k, 'title' => $k, 'text' => $k, 'qty' => 9, 'progress' => 0, 'status' => 'active', 'taken_at' => now()]);
}
job_event($uid, 'cook', 'kimchi', 1, ['tier' => 'preserve']);
$prog = fn(string $k) => (int)q_val('SELECT progress FROM user_jobs WHERE user_id = ? AND kind = ?', [$uid, $k]);
ok('preserve: craft job +1, cook job 0', $prog('craft') === 1 && $prog('cook') === 0);
job_event($uid, 'cook', 'garden-vegetable-soup', 1, ['tier' => 'meal']);
ok('a real meal still counts as cook + craft', $prog('cook') === 1 && $prog('craft') === 2);
job_event($uid, 'cook', 'mint-tea', 1, ['tier' => 'snack']);
ok('a snack is still a craft only', $prog('cook') === 1 && $prog('craft') === 3);
q('DELETE FROM user_jobs WHERE user_id = ?', [$uid]);

echo "== upgrade path: an install without the Pantry becomes one with it, and running it again changes nothing\n";
$dbf = $argv[1] . '/data/game.sqlite';
$pdo = new PDO('sqlite:' . $dbf);
$pdo->exec("DELETE FROM user_items WHERE item_id IN (SELECT output_item_id FROM recipes WHERE category = 'pantry')");
$pdo->exec("DELETE FROM user_recipes WHERE recipe_id IN (SELECT id FROM recipes WHERE category = 'pantry')");
$pdo->exec("DELETE FROM items WHERE id IN (SELECT output_item_id FROM recipes WHERE category = 'pantry')");
$pdo->exec("DELETE FROM recipes WHERE category = 'pantry'");
$pdo->exec("DELETE FROM user_encyclopedia WHERE entry_id IN (SELECT id FROM encyclopedia_entries WHERE category = 'Preserves' OR unlock_key = 'pantry')");
$pdo->exec("DELETE FROM encyclopedia_entries WHERE category = 'Preserves' OR unlock_key = 'pantry'");
$pdo->exec('DROP TABLE pantry_jars');
$pdo->exec('ALTER TABLE garden_buildings DROP COLUMN pantry');
$pdo->exec('ALTER TABLE fair_best DROP COLUMN label');
$pdo->exec('ALTER TABLE fair_entries DROP COLUMN label');
$pdo->exec("UPDATE settings SET value = '0.9.6' WHERE name = 'db_version'");
$code = '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "' . $argv[1] . '/includes/bootstrap.php"; echo APP_VERSION;';
$out = shell_exec('php -d display_errors=1 -r ' . escapeshellarg($code) . ' 2>&1');
ok('the upgrade ran without a message (' . trim((string)$out) . ')', trim((string)$out) === APP_VERSION, (string)$out);
$pdo = new PDO('sqlite:' . $dbf);
$one = fn(string $sql) => $pdo->query($sql)->fetchColumn();
ok('db_version moved on', $one("SELECT value FROM settings WHERE name = 'db_version'") === APP_VERSION);
ok('pantry_jars table is back', (int)$one("SELECT COUNT(*) FROM sqlite_master WHERE name = 'pantry_jars'") === 1);
ok('garden_buildings.pantry, fair_best.label, fair_entries.label are back', (int)$one("SELECT COUNT(*) FROM pragma_table_info('garden_buildings') WHERE name = 'pantry'") === 1
    && (int)$one("SELECT COUNT(*) FROM pragma_table_info('fair_best') WHERE name = 'label'") === 1 && (int)$one("SELECT COUNT(*) FROM pragma_table_info('fair_entries') WHERE name = 'label'") === 1);
$counts = fn() => implode('/', [$one("SELECT COUNT(*) FROM recipes WHERE category = 'pantry'"), $one("SELECT COUNT(*) FROM items WHERE json_extract(effects, '\$.preserve') = 1"),
    $one("SELECT COUNT(*) FROM encyclopedia_entries WHERE category = 'Preserves'"), $one("SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key = 'pantry'"), $one('SELECT COUNT(*) FROM recipes')]);
$total = $one('SELECT COUNT(*) FROM recipes');
$nPre = count(array_filter(file($argv[1] . '/includes/data/recipes.txt', FILE_IGNORE_NEW_LINES), fn($l) => $l !== '' && $l[0] !== '#' && (explode('|', $l)[7] ?? '') === 'preserve'));   // every preserve row in recipes.txt
ok($nPre . ' recipes, ' . $nPre . ' items, ' . $nPre . ' recipe pages, 2 how-to pages: ' . $counts(), explode('/', $counts())[0] === (string)$nPre && explode('/', $counts())[1] === (string)$nPre && explode('/', $counts())[2] === (string)$nPre && explode('/', $counts())[3] === '2');
$before = $counts();
$code = '$_SERVER["SCRIPT_NAME"]="/gnome.php"; require "' . $argv[1] . '/includes/bootstrap.php"; require_once "' . $argv[1] . '/includes/pantry.php"; echo upgrade_098_pantry(), upgrade_098_pantry();';
$out = shell_exec('php -d display_errors=1 -r ' . escapeshellarg($code) . ' 2>&1');
ok('upgrade_098_pantry() twice adds nothing (output "' . trim((string)$out) . '")', trim((string)$out) === '00', (string)$out);
ok('counts unchanged by a second run', $counts() === $before, $counts() . ' vs ' . $before);

echo $fails ? "\n$fails failure(s)\n" : "\nall ok\n";
exit($fails ? 1 : 0);
