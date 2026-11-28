<?php
// World v2 creatures (includes/creatures_v2.php; master doc section 10, claude/proposal-creatures-38-55.txt): world_v2_open off = none of them exists and
// data/pf_creatures_v2.txt is not read; on = 60 creatures for levels 38-55 (every landscape but tundra covered), the 6 new regional rares, the seven
// tier 4-5 lair guardians at band top with their own name, drops and page, board-fight rows that lint, and an import that is safe to repeat.
// Run by creatures_v2.sh on a walk.sh install: php tests/creatures_v2.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/adventure_data.php';
require_once APP_ROOT . '/includes/explore.php';
require_once APP_ROOT . '/includes/pfdeck.php';
require_once APP_ROOT . '/includes/creatures_v2.php';
$fails = 0;
$done = false; register_shutdown_function(function () use (&$done) { if (!$done) echo "FAIL the test stopped early (fatal error)\n"; });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
$DATA = APP_ROOT . '/includes/data/';
$rows = []; foreach (catalog_lines('creatures_v2.txt') as $c) if (count($c) >= 7) $rows[$c[0]] = $c;
$pfFile = []; foreach (file($DATA . 'pf_creatures_v2.txt', FILE_IGNORE_NEW_LINES) as $l) if ($l !== '' && $l[0] !== '#') { $c = explode('|', $l); $pfFile[$c[0]] = $c; }
$lairs = creatures_v2_lair_rows();
$slugs = array_keys($rows);
$inList = fn(array $s) => implode(',', array_map(fn($x) => db()->quote($x), $s));
$n = fn(string $t) => (int)q_val("SELECT COUNT(*) FROM $t");
$counts = fn() => [$n('creatures'), $n('creature_drops'), $n('items'), $n('encyclopedia_entries')];
$guardian = fn(string $lair) => q_one("SELECT c.* FROM creatures c JOIN locations l ON c.slug = 'boss-' || l.slug JOIN landmarks lm ON lm.location_id = l.id WHERE lm.kind = 'lair' AND lm.name = ?", [$lair]);

echo "== the data files\n";
ok('60 creatures: 53 ordinary + 7 roaming bosses', count($rows) === 60 && count(array_filter($rows, fn($c) => $c[2] === 'boss')) === 7, (string)count($rows));
ok('no *new marker left, sizes known, levels 38-55', !array_filter($rows, fn($c) => str_contains(implode('|', $c), '*new') || !in_array($c[2], ['medium', 'large', 'boss'], true) || (int)$c[4] < 38 || (int)$c[4] > 55));
$old = [];
foreach (['creatures.txt', 'trek_creatures.txt', 'trek_creatures_ch2.txt', 'trek_creatures_ch2b.txt', 'trek_creatures_ch3.txt', 'trek_creatures_ch3b.txt'] as $f) foreach (catalog_lines($f) as $c) $old[$c[0]] = 1;
foreach (file($DATA . 'pf_creatures.txt', FILE_IGNORE_NEW_LINES) as $l) if ($l !== '' && $l[0] !== '#') $old[explode('|', $l)[0]] = 1;
ok('no slug repeats a creature of creatures.txt, pf_creatures.txt or the trek files', !array_intersect_key($rows, $old), implode(',', array_keys(array_intersect_key($rows, $old))));
$gap = [];
foreach (['coast', 'desert', 'forest', 'grassland', 'island', 'mountain', 'rainforest', 'wetland'] as $land) {
    $lv = array_values(array_unique(array_map(fn($c) => (int)$c[4], array_filter($rows, fn($c) => $c[2] !== 'boss' && in_array($land, explode(',', $c[3]), true))))); sort($lv);
    $maxGap = 0; for ($i = 1; $i < count($lv); $i++) $maxGap = max($maxGap, $lv[$i] - $lv[$i - 1]);
    if (!$lv || $lv[0] > 39 || end($lv) < 53 || $maxGap > 3) $gap[] = "$land " . json_encode($lv);
}
ok('every landscape but tundra has ordinary creatures from 38-39 to 53+, never more than 3 levels apart', !$gap, implode('; ', $gap));
ok('7 lair overrides at band top (45 tier 4, 55 tier 5)', count($lairs) === 7 && !array_filter($lairs, fn($r) => !in_array($r[1], [45, 55], true)));
ok('pf_creatures_v2.txt: one base row for each creature, 17 cells', array_keys($pfFile) == $slugs && !array_filter($pfFile, fn($c) => count($c) !== 17 || $c[2] !== '='), json_encode(array_diff($slugs, array_keys($pfFile))));

echo "== world_v2_open = 0: none of it\n";
ok('setting defaults to 0', setting('world_v2_open') === '0');
ok('no v2 creature in the world', !q_val("SELECT 1 FROM creatures WHERE slug IN ({$inList($slugs)})"));
ok('no new item in the world', !q_val('SELECT 1 FROM items WHERE name IN (' . $inList(array_keys(CREATURES_V2_ITEMS)) . ')'));
ok('pfd_creature_rows() does not read pf_creatures_v2.txt', !array_intersect_key(pfd_creature_rows(true), $rows) && pfd_creature_v2_path() === '');
$oldLair = $guardian('Snowcrown Peak');
ok('the Snowcrown Peak guardian is the generated one', ($oldLair['name'] ?? '') === 'Guardian of Snowcrown Peak', (string)($oldLair['name'] ?? 'none'));
$before = $counts();
creatures_v2_boot();
ok('creatures_v2_boot() does nothing while off', $counts() === $before && setting('creatures_v2_done') !== '1');

echo "== world_v2_open = 1\n";
setg('world_v2_open', '1');
require_once APP_ROOT . '/includes/world_v2.php';
world_v2_boot();
$items0 = $n('items');
creatures_v2_boot();
ok('the boot ran once (creatures_v2_done)', setting('creatures_v2_done') === '1');
ok('all 60 creatures are in the world, active', (int)q_val("SELECT COUNT(*) FROM creatures WHERE active = 1 AND slug IN ({$inList($slugs)})") === 60);
ok('exactly the 5 new items were made (no item made by a misspelt drop)', $n('items') - $items0 === 5, (string)($n('items') - $items0));
$bad = [];
foreach (CREATURES_V2_ITEMS as $name => [$desc]) { $i = q_one('SELECT * FROM items WHERE name = ?', [$name]); if (!$i || $i['category'] !== 'part' || $i['description'] !== $desc || !ph_path((string)$i['slug'])) $bad[] = $name; }
ok('each new item is a part with its own description and a placeholder picture', !$bad, implode(',', $bad));
$dropCat = fn(string $slug, string $item) => (string)q_val('SELECT i.category FROM creature_drops d JOIN items i ON i.id = d.item_id JOIN creatures c ON c.id = d.creature_id WHERE c.slug = ? AND i.id = ?', [$slug, pfc_item_for_drop($item)]);
ok('Kola Nut and Silk Cocoon bind to the items that exist (the crop, the Silkworm Shelf part)', $dropCat('okapi', 'Kola Nut') !== '' && $dropCat('okapi', 'Kola Nut') !== 'part' && $dropCat('great-panda', 'Silk Cocoon') === 'part' && (string)q_val('SELECT slug FROM items WHERE id = ?', [pfc_item_for_drop('Silk Cocoon')]) === 'silk-cocoon', $dropCat('okapi', 'Kola Nut'));
$rh = q_one("SELECT * FROM creatures WHERE slug = 'acacia-giraffe'");
ok('stats from size and level above 40 (large Lv 45: 224 hp, attack 18, defence 26, d8+11, 432 xp)', [(int)$rh['hp'], (int)$rh['attack'], (int)$rh['defense'], (int)$rh['dmg_die'], (int)$rh['dmg_bonus'], (int)$rh['xp']] === [224, 18, 26, 8, 11, 432], json_encode($rh));
ok('an Almanac page for each', (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN (" . $inList(array_map(fn($s) => 'creature:' . $s, $slugs)) . ')') === 60);

$badL = [];
foreach ($lairs as $lair => [$name, $lv, $drops, $desc, $cond]) {
    $g = $guardian($lair);
    $want = count(pfc_parse_drops($drops));
    $page = $g ? q_one('SELECT title, body FROM encyclopedia_entries WHERE unlock_key = ?', ['creature:' . $g['slug']]) : null;
    $route = $g ? (int)q_val("SELECT rt.level FROM routes rt JOIN landmarks lm ON lm.location_id = rt.b_id WHERE lm.name = ? AND rt.kind = 'side' LIMIT 1", [$lair]) : 0;
    if (!$g || $g['name'] !== $name || (int)$g['level'] !== $lv || $g['description'] !== $desc || (string)$g['cond'] !== $cond || (int)$g['active'] !== 0
        || (int)q_val('SELECT COUNT(*) FROM creature_drops WHERE creature_id = ?', [$g['id']]) !== $want || ($page['title'] ?? '') !== $name || !str_contains((string)$page['body'], "Level:[/b] $lv") || $route !== $lv) $badL[] = $lair . ' ' . json_encode([$g['name'] ?? null, $g['level'] ?? null, $route]);
}
ok('the seven lair guardians: name, band-top level (and their path), drops, description, cond, page; still only in their lair', !$badL, implode('; ', $badL));

echo "== the board\n";
$pf = pfd_creature_rows(true);
ok('pfd_creature_rows() now has the 60 rows', count(array_intersect_key($pf, $rows)) === 60);
$lint = [];
$kindOf = ['Critter' => 'critter', 'Bird' => 'bird', 'Beast' => 'beast', 'Reptile/Amphibian' => 'reptile', 'Water' => 'water', 'Plant/Fungus' => 'plant'];
$lands = []; foreach (q('SELECT id, code FROM regions')->fetchAll() as $r) $lands[$r['code']] = region_lands((int)$r['id']);
foreach ($rows as $slug => $c) {
    $r = $pf[$slug]; $lv = (int)$c[4];
    $class = pfd_class_map(true)[$slug] ?? '';
    if (!isset($kindOf[$class])) $lint[] = "$slug class";
    if (count($r['ab']) !== count(explode('+', $pfFile[$slug][8]))) $lint[] = "$slug ability";
    foreach ($r['ab'] as $id) if (PFB_ABIL[$id][0] === 'E' && PFB_ABIL[$id][1] !== ($c[2] === 'boss' ? 'boss' : ($kindOf[$class] ?? ''))) $lint[] = "$slug $id is not its class rule";
    if (!isset(PFB_AI[$r['ai']])) $lint[] = "$slug style";
    if (count($r['deck'] ?? []) !== 4 || count(array_unique(array_column($r['deck'], 'r'))) < 2) $lint[] = "$slug deck";
    foreach ($r['regions'] as $reg) {
        $lo = REGION_LEVELS_V2[$reg] ?? 0;
        if ($lo < 35 || $lv < $lo || $lv > $lo + 10 || !array_intersect(explode(',', $c[3]), $lands[$reg] ?? [])) $lint[] = "$slug in $reg";
    }
    $row = pfd_foe_row(q_one('SELECT * FROM creatures WHERE slug = ?', [$slug]), $r['regions'][0]);
    $lay = array_count_values(array_column($row['deck'], 'layer'));
    if (($lay['uni'] ?? 0) !== 4 || count(array_unique(array_column($row['deck'], 'r'))) !== 3 || $row['class'] !== $class) $lint[] = "$slug fight deck " . json_encode($lay);
}
ok('every row lints: class, its class rule, style, 4 own pieces, its region in its tier with one of its lands, a full fight deck', !$lint, implode('; ', array_slice($lint, 0, 6)));
ok('region-bound: the Quokka turns up in the Coralscatter only', pfd_creature_in_region('quokka', 'OC') && !pfd_creature_in_region('quokka', 'NA'));
$met = [];
for ($i = 0; $i < 60; $i++) if ($p = pick_creature('island', 52, false, true, 0, 'OC', road_rows('creatures', true))) $met[$p['slug']] = 1;
ok('a Lv 52 island walk in the Coralscatter meets the new creatures', (bool)array_intersect_key($met, $rows), json_encode(array_keys($met)));

echo "== safe to repeat\n";
$c0 = $counts();
creatures_v2_import(); creatures_v2_lairs(); $st = ['items' => 0, 'pages' => 0]; import_creatures_txt($st, 'creatures_v2.txt'); smooth_creatures();
ok('a second import and lair pass change no table', $counts() === $c0, json_encode([$c0, $counts()]));
$g = $guardian('Dragonlizard Den');
ok('the guardian is still the override after the repeat', ($g['name'] ?? '') === 'Dragonlizard' && (int)$g['level'] === 55);

$atk = 2 + intdiv(55, 2); $def = 9 + intdiv(55, 3) + 3;
echo "diag balance (not tuned here): Lv 55 gnome attack +$atk before stats vs a Lv 55 boss defence $def; boss attack +" . (1 + intdiv(55, 3) + 2) . ' vs gnome armour ' . (10 + intdiv(55, 4)) . " + nimble\n";
$done = true;
echo $fails ? "$fails FAILED\n" : "all ok\n";
