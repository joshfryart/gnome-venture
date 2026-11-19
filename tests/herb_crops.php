<?php
// The six tea crops (lemon balm, peppermint, lemon verbena, garden sage, tulsi, star anise): data rows, a new world, and a LIVE world that never had them
// (boot step tea_crops_ensure, catalog.php: import_catalog($only) + catalog_stock_crops). Also pins the true trigger of the boot steps (the version bump).
// php tests/herb_crops.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one; ci_suites.sh does that first).
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/catalog.php';
require_once APP_ROOT . '/includes/tea.php';
require_once APP_ROOT . '/includes/garden_world.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$C = TEA_CROPS;
$common = ['lemon-balm', 'peppermint', 'garden-sage'];
$region = ['lemon-verbena' => 'SE', 'tulsi' => 'CSA', 'star-anise' => 'EA'];   // uncommon in these regions
$rowOf = function (string $file, string $slug): ?array { foreach (catalog_lines($file) as $r) if (($r[0] ?? '') === $slug) return $r; return null; };

echo "== data\n";
ok('TEA_CROPS lists the six', $C === ['lemon-balm', 'peppermint', 'lemon-verbena', 'garden-sage', 'tulsi', 'star-anise']);
$bad = [];
foreach ($C as $s) {
    $r = $rowOf('crops.txt', $s);
    if (!$r || count($r) < 6 || !in_array($r[2], ['herb', 'spice'], true) || (int)$r[3] < 1 || (int)$r[3] > 6) $bad[] = "$s: crops.txt";
    if (!$rowOf('crop_seasons.txt', $s)) $bad[] = "$s: crop_seasons.txt";
    foreach (['', '-seed'] as $suf) if (!is_file(APP_ROOT . '/assets/img/ph/' . $s . $suf . '.svg')) $bad[] = "$s$suf: placeholder svg";
}
ok('every crop has a crops.txt row, a season row and crop + seed placeholder art', !$bad, implode('; ', $bad));
$rc = []; foreach (catalog_lines('region_crops.txt') as $r) if (($r[1] ?? '') === 'uncommon') foreach (explode(',', $r[2]) as $s) $rc[$s][] = $r[0];
ok('the three region crops are uncommon in their region only; the others are everyday crops', array_map(fn($s) => $rc[$s] ?? [], array_keys($region)) === [['SE'], ['CSA'], ['EA']] && !array_filter($common, fn($s) => isset($rc[$s])) && !array_diff($common, COMMON_CROPS));
ok('no crop slug is used twice in crops.txt', count(array_unique(array_column(catalog_lines('crops.txt'), 0))) === count(catalog_lines('crops.txt')));

echo "== a new world has them\n";
$state = function (string $s): array {
    $p = q_one('SELECT * FROM plants WHERE slug = ?', [$s]);
    return ['plant' => $p, 'seed' => item_id_by_slug($s . '-seed'), 'produce' => item_id_by_slug($s), 'page' => (int)q_val('SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key = ?', ['plant:' . $s]),
        'links' => $p ? (int)q_val('SELECT COUNT(*) FROM plant_regions WHERE plant_id = ?', [$p['id']]) : 0,
        'stock' => (int)q_val('SELECT COUNT(*) FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE i.slug = ?', [$s . '-seed'])];
};
$bad = [];
foreach ($C as $s) {
    $x = $state($s); $p = $x['plant'];
    if (!$p || !$x['seed'] || !$x['produce'] || (int)$p['seed_item_id'] !== $x['seed'] || (int)$p['produce_item_id'] !== $x['produce']) { $bad[] = "$s: plant / items"; continue; }
    if ($x['page'] !== 1) $bad[] = "$s: Almanac page x" . $x['page'];
    if (q_val('SELECT category FROM items WHERE id = ?', [$x['seed']]) !== 'seed' || q_val('SELECT category FROM items WHERE id = ?', [$x['produce']]) !== 'produce') $bad[] = "$s: item categories";
    if ((int)$p['common'] !== (int)in_array($s, $common, true)) $bad[] = "$s: common flag";
    if (isset($region[$s]) && $x['links'] !== 1) $bad[] = "$s: region links " . $x['links'];
    if ($x['stock'] < 1) $bad[] = "$s: seed on sale nowhere";
    if ((int)$p['timing_v'] !== 1 || $p['nutrient'] === null) $bad[] = "$s: grow time / nutrient";
}
ok('plant row, seed + produce items, Almanac page, region link, stock, grow time and nutrient for each', !$bad, implode('; ', $bad));
$twigg = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
ok("everyday crops' seeds are on Twigg's shelf", $twigg > 0 && (int)q_val('SELECT COUNT(*) FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE st.shop_id = ? AND i.slug IN (\'lemon-balm-seed\', \'peppermint-seed\', \'garden-sage-seed\')', [$twigg]) === 3);
$bad = [];
foreach ($region as $s => $code) if (!q_val('SELECT 1 FROM shop_stock st JOIN shops sh ON sh.id = st.shop_id JOIN items i ON i.id = st.item_id WHERE sh.slug = ? AND i.slug = ?', [strtolower($code) . '-seed-market', $s . '-seed'])) $bad[] = "$s not in the $code seed market";
ok('the region crops are in their own region\'s seed market', !$bad, implode('; ', $bad));
ok('climates: peppermint cool, tulsi tropical', q_val("SELECT climate FROM plants WHERE slug = 'peppermint'") === 'cool' && q_val("SELECT climate FROM plants WHERE slug = 'tulsi'") === 'tropical');
$g = garden_data_rows('crop_seasons.txt');
ok('seasons are read: tulsi grows in summer and autumn, tender', in_array('tulsi', array_column($g, 0), true));
$ING = tea_ingredients();
ok('the tea kettle finds each crop\'s produce item', !array_filter($C, fn($s) => !isset($ING[$s]) || $ING[$s]['items'] !== [[$s, false]]), json_encode(array_map(fn($s) => $ING[$s]['items'] ?? null, $C)));

echo "== a live world that never had them\n";
$wipe = function () use ($C) {
    foreach ($C as $s) {
        $p = q_one('SELECT id FROM plants WHERE slug = ?', [$s]);
        foreach ([$s, $s . '-seed'] as $is) { $iid = item_id_by_slug($is); if ($iid) { q('DELETE FROM shop_stock WHERE item_id = ?', [$iid]); q('DELETE FROM user_items WHERE item_id = ?', [$iid]); } }
        if ($p) { q('DELETE FROM plant_regions WHERE plant_id = ?', [$p['id']]); q('DELETE FROM user_plant_knowledge WHERE plant_id = ?', [$p['id']]); q('DELETE FROM plants WHERE id = ?', [$p['id']]); }
        q('DELETE FROM user_encyclopedia WHERE entry_id IN (SELECT id FROM encyclopedia_entries WHERE unlock_key = ?)', ['plant:' . $s]);
        q('DELETE FROM encyclopedia_entries WHERE unlock_key = ?', ['plant:' . $s]);
        q('DELETE FROM items WHERE slug IN (?, ?)', [$s, $s . '-seed']);
    }
};
$wipe();
ok('wiped: no plant, item, page or stock left', !array_filter($C, fn($s) => q_val('SELECT 1 FROM plants WHERE slug = ?', [$s]) || item_id_by_slug($s) || item_id_by_slug($s . '-seed')));
$other = (int)q_val('SELECT COUNT(*) FROM plants'); $itemsBefore = (int)q_val('SELECT COUNT(*) FROM items'); $shopsBefore = (int)q_val('SELECT COUNT(*) FROM shops'); $locBefore = (int)q_val('SELECT COUNT(*) FROM locations'); $pagesBefore = (int)q_val('SELECT COUNT(*) FROM encyclopedia_entries');
$n = tea_crops_ensure();
ok('tea_crops_ensure adds all six', $n === 6, (string)$n);
$bad = []; foreach ($C as $s) { $x = $state($s); if (!$x['plant'] || !$x['seed'] || !$x['produce'] || $x['page'] !== 1 || $x['stock'] < 1 || (int)$x['plant']['timing_v'] !== 1 || $x['plant']['nutrient'] === null || (string)$x['plant']['climate'] === '' && in_array($s, ['peppermint', 'tulsi'], true)) $bad[] = $s; }
ok('each is back with plant, items, page, stock, grow time, nutrient (and climate)', !$bad, implode(', ', $bad));
ok('it added only those: 6 plants, 12 items, 6 pages; no shop, no place, nothing else', (int)q_val('SELECT COUNT(*) FROM plants') === $other + 6 && (int)q_val('SELECT COUNT(*) FROM items') === $itemsBefore + 12 && (int)q_val('SELECT COUNT(*) FROM shops') === $shopsBefore && (int)q_val('SELECT COUNT(*) FROM locations') === $locBefore && (int)q_val('SELECT COUNT(*) FROM encyclopedia_entries') === $pagesBefore + 6);
$stockN = (int)q_val('SELECT COUNT(*) FROM shop_stock');
ok('a second run adds nothing', tea_crops_ensure() === 0 && (int)q_val('SELECT COUNT(*) FROM shop_stock') === $stockN && (int)q_val('SELECT COUNT(*) FROM plants') === $other + 6);
q("UPDATE plants SET grow_minutes = 77 WHERE slug = 'tulsi'"); q("UPDATE items SET name = 'My Sage' WHERE slug = 'garden-sage'"); tea_crops_ensure();
ok('an Admin edit stands (grow time, item name)', (int)q_val("SELECT grow_minutes FROM plants WHERE slug = 'tulsi'") === 77 && q_val("SELECT name FROM items WHERE slug = 'garden-sage'") === 'My Sage');
$sid = item_id_by_slug('lemon-verbena-seed'); q('DELETE FROM shop_stock WHERE item_id = ?', [$sid]);
ok('a crop made but not on sale (a step that stopped half way) is stocked again', tea_crops_ensure() === 0 && (int)q_val('SELECT COUNT(*) FROM shop_stock WHERE item_id = ?', [$sid]) === 1);

echo "== the trigger: a version change runs the boot steps; nothing else does\n";
$boot = fn() => trim((string)shell_exec(escapeshellarg(PHP_BINARY) . ' -d display_errors=1 -r ' . escapeshellarg('$_SERVER["SCRIPT_NAME"]="/index.php"; require ' . var_export($argv[1] . '/includes/bootstrap.php', true) . '; echo "booted";') . ' 2>&1'));
$wipe();
set_setting('db_version', APP_VERSION); q("DELETE FROM settings WHERE name = 'boot_retry_after'");
ok('same version: a page load runs no boot step, the crops stay missing', $boot() === 'booted' && !q_val("SELECT 1 FROM plants WHERE slug = 'peppermint'"));
set_setting('db_version', '2.7.0'); setting('__reload__');
$out = $boot();
setting('__reload__');
ok('an older db_version: the boot chain ran clean (' . $out . ')', $out === 'booted', $out);
$bad = []; foreach ($C as $s) { $x = $state($s); if (!$x['plant'] || !$x['seed'] || !$x['produce'] || $x['page'] !== 1 || $x['stock'] < 1) $bad[] = $s; }
ok('... and the six crops are there (no manual step)', !$bad, implode(', ', $bad));
ok('... and db_version moved to ' . APP_VERSION, q_val("SELECT value FROM settings WHERE name = 'db_version'") === APP_VERSION);

echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);
