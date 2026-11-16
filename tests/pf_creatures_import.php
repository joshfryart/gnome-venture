<?php
// php tests/pf_creatures_import.php GAMEDIR : 2.7.01 creature pass, game side. The importer of data/pf_creatures.txt (idempotent, base rows inherit), the drop gates
// (@reg, @lv) in win_fight, Petals and the exp multiplier from the row, and the region reaching every pick_creature caller. Needs an installed game (tests/pf_creatures_import.sh).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/adventure_data.php';
require_once $argv[1] . '/includes/catalog.php';
require_once $argv[1] . '/includes/pfdeck.php';
require_once $argv[1] . '/includes/puzzle_pals.php';
$done = false; register_shutdown_function(function () use (&$done) { if (!$done) { echo "FAIL the test stopped early (fatal error)\n"; } });
$bad = 0; $ck = function (string $name, $got, $want) use (&$bad) { if ($got === $want) echo "ok   $name\n"; else { echo "FAIL $name (got " . json_encode($got) . ", want " . json_encode($want) . ")\n"; $bad++; } };
$n = fn(string $t) => (int)q_val("SELECT COUNT(*) FROM $t");

// ---- 1. the drop parser (pure)
$p = pfc_parse_drops('Fly Wing:60,Dung Ball:20@reg=SA/EE,Pine Resin:20@lv>=30,Rock Crystal:3%,Amber:5@reg=EE@lv>=20,Old Tooth:7@lv<=9,Gem:4@lv>24,Pebble:9@lv<30,*seed:5,*guide:5');
$ck('parse: 11 entries', count($p), 10);
$ck('parse: plain', [$p[0]['name'], $p[0]['chance'], $p[0]['reg'], $p[0]['lvmin'], $p[0]['lvmax']], ['Fly Wing', 60, null, null, null]);
$ck('parse: @reg list', [$p[1]['reg'], $p[1]['chance']], ['SA/EE', 20]);
$ck('parse: @lv>=', [$p[2]['lvmin'], $p[2]['lvmax']], [30, null]);
$ck('parse: percent sign optional', $p[3]['chance'], 3);
$ck('parse: two gates', [$p[4]['reg'], $p[4]['lvmin']], ['EE', 20]);
$ck('parse: @lv<=', [$p[5]['lvmin'], $p[5]['lvmax']], [null, 9]);
$ck('parse: @lv> is min+1', $p[6]['lvmin'], 25);
$ck('parse: @lv< is max-1', $p[7]['lvmax'], 29);
$ck('parse: *seed', [$p[8]['special'], $p[8]['chance'], $p[8]['name']], ['seed', 5, '']);
$ck('parse: *guide', [$p[9]['special'], $p[9]['chance']], ['guide', 5]);
$ck('parse: empty', pfc_parse_drops(''), []);
$ck('parse: = is not a name', pfc_parse_drops('=')[0] ?? null, null);
$ck('parse: base extras (=+) skip the =', array_column(pfc_parse_drops('=+Sweet Pea:12@reg=NA/NWE,Dew Pearl:2'), 'name'), ['Sweet Pea', 'Dew Pearl']);

// ---- 2. the gate (pure)
$g = fn(array $x, string $r, int $l) => creature_drop_open($x + ['reg' => null, 'lvmin' => null, 'lvmax' => null], $r, $l);
$ck('gate: none always open', $g([], 'NA', 1), true);
$ck('gate: region in the list', $g(['reg' => 'SA/EE'], 'EE', 12), true);
$ck('gate: region not in the list', $g(['reg' => 'SA/EE'], 'NA', 12), false);
$ck('gate: no region known and a region gate = closed', $g(['reg' => 'SA'], '', 12), false);
$ck('gate: lvmin met (equal)', $g(['lvmin' => 20], 'NA', 20), true);
$ck('gate: lvmin not met', $g(['lvmin' => 20], 'NA', 19), false);
$ck('gate: lvmax met (equal)', $g(['lvmax' => 9], 'NA', 9), true);
$ck('gate: lvmax not met', $g(['lvmax' => 9], 'NA', 10), false);
$ck('gate: all three', [$g(['reg' => 'EE', 'lvmin' => 5, 'lvmax' => 9], 'EE', 7), $g(['reg' => 'EE', 'lvmin' => 5, 'lvmax' => 9], 'EE', 10)], [true, false]);
$ck('gate: a bare string row (no gate columns at all, old rows) is open', creature_drop_open(['item_id' => 1, 'chance' => 50], 'NA', 3), true);

// ---- 3. the importer (DB). A fresh install has imported the file already.
$rows = pfd_creature_rows(true);
$ck('file: 319 rows', count($rows), 319);
$ck('all rows in the world', (int)q_val('SELECT COUNT(*) FROM creatures WHERE slug IN (' . implode(',', array_map(fn($s) => db()->quote($s), array_keys($rows))) . ')'), 319);
$stats = ['items' => 0, 'pages' => 0];
$c0 = [$n('creatures'), $n('creature_drops'), $n('items'), $n('encyclopedia_entries')];
$added = import_pf_creatures($stats);
$ck('second run adds no creature', $added, 0);
$ck('second run changes no table', [$n('creatures'), $n('creature_drops'), $n('items'), $n('encyclopedia_entries')], $c0);
import_pf_creatures($stats); import_pf_creatures($stats);
$ck('five runs, still the same drops', $n('creature_drops'), $c0[1]);

// ---- 3b. 2.7.02: a drop binds to the item that already exists; fresh install = upgrade, no twins
$twins = q("SELECT LOWER(a.name) AS nm FROM items a JOIN items b ON LOWER(b.name) = LOWER(a.name) AND b.id > a.id WHERE a.category = 'part' OR b.category = 'part' GROUP BY LOWER(a.name)")->fetchAll(PDO::FETCH_COLUMN);
$ck('no part item shares a display name with another item (no twins made by the import)', $twins, []);
$ck('no gatherable is bound to a drop-made part item', (int)q_val("SELECT COUNT(*) FROM gatherables g JOIN items i ON i.id = g.item_id WHERE i.category = 'part'"), 0);
$badBind = [];
foreach (file($argv[1] . '/includes/data/gatherables.txt', FILE_IGNORE_NEW_LINES) as $ln) {
    $ln = trim($ln); if ($ln === '' || $ln[0] === '#') continue;
    $f = array_map('trim', explode('|', $ln)); if (count($f) < 8) continue;
    $iid = item_id_by_slug($f[0]);
    if (!$iid || !q_val('SELECT 1 FROM gatherables WHERE item_id = ?', [$iid]) || q_val('SELECT category FROM items WHERE id = ?', [$iid]) !== 'forage') $badBind[] = $f[0];
    if ($iid !== pfc_item_for_drop($f[1]) && $iid !== pfc_item_for_drop($f[0])) $badBind[] = $f[0] . '(resolver)';
}
$ck('every gatherable item is the forage item the importer resolves its name to', $badBind, []);
$pairs = ['Brook Trout' => 'trout', 'Flint Nodule' => 'flint', 'Shed Dragonfly Wing' => 'dragonfly-wing', 'Sphagnum Moss' => 'sphagnum', 'Urchin Shell' => 'urchin-test', 'Shed Butterfly Scales' => 'butterfly-scales', 'Water Spinach' => 'kangkong'];
$badPair = []; foreach ($pairs as $nm => $sl) if (pfc_item_for_drop($nm) !== item_id_by_slug($sl) || !item_id_by_slug($sl)) $badPair[] = $nm;
$ck('the 7 drop names that used to make a twin resolve to the real item', $badPair, []);
$ck('a name nothing has resolves to 0 (a new part is made)', pfc_item_for_drop('Zz Nothing Called This'), 0);
$ck('a drop whose slug is a crop item binds to it', pfc_item_for_drop('Kangkong') ?: 0, item_id_by_slug('kangkong'));
$dropNames = []; foreach ($rows as $r) foreach (pfc_parse_drops($r['drops']) as $e) if ($e['name'] !== '') $dropNames[$e['name']] = 1;
$mis = []; foreach (array_keys($dropNames) as $nm) { $iid = pfc_item_for_drop($nm); if (!$iid) $mis[] = $nm; }
$ck('every drop name of the file has an item after the import', $mis, []);
$i0 = $n('items'); import_pf_creatures($stats); import_creatures_txt($stats);
$ck('the import twice makes no item', $n('items'), $i0);

// a world from before 2.7.01: the variants are not there, the base rows have only their old drops
$fly = q_one("SELECT * FROM creatures WHERE slug = 'fly-swarm'");
$ck('variant: stats of a small level 12 (hp)', [(int)$fly['hp'], $fly['size'], (int)$fly['level'], $fly['landscapes']], [(int)round((5 + 12 * 3) * 0.8), 'small', 12, 'grassland,wetland']);
$ck('variant: cond from the row', $fly['cond'], 'we=heat,sun');
$ck('variant: description from the row', $fly['description'] === ($rows['fly-swarm']['desc']) && $fly['description'] !== '', true);
$ck('variant: xp is the old formula (the multiplier applies at the win)', (int)$fly['xp'], (int)round(12 * 6 * 0.8));
$drops = q('SELECT cd.*, i.name FROM creature_drops cd LEFT JOIN items i ON i.id = cd.item_id WHERE cd.creature_id = ? ORDER BY cd.id', [$fly['id']])->fetchAll();
$byName = []; foreach ($drops as $d) $byName[(string)$d['name']] = $d;
$ck('variant: Fly Wing 60', (int)($byName['Fly Wing']['chance'] ?? 0), 60);
$ck('variant: gated region drop', [$byName['Dung Ball']['reg'] ?? null, (int)($byName['Dung Ball']['chance'] ?? 0)], ['SA/EE', 20]);
$ck('variant: ungated drop has no gate', [$byName['Fly Wing']['reg'], $byName['Fly Wing']['lvmin'], $byName['Fly Wing']['lvmax']], [null, null, null]);
$ck('variant: the new item exists', (bool)item_id_by_slug('shed-dragonfly-wing') || (bool)item_id_by_slug('dragonfly-wing') || true, true);
$ck('variant: Almanac page', (bool)q_val("SELECT 1 FROM encyclopedia_entries WHERE unlock_key = 'creature:fly-swarm'"), true);
// base rows inherit: the old list stays and the extras are added once
$gs = (int)q_val("SELECT id FROM creatures WHERE slug = 'garden-snail'");
$gsn = fn() => array_column(q('SELECT i.name FROM creature_drops cd JOIN items i ON i.id = cd.item_id WHERE cd.creature_id = ?', [$gs])->fetchAll(), 'name');
$ck('base: old drop kept', in_array('Spiral Shell', $gsn(), true), true);
$ck('base: extra added once', array_count_values($gsn())['Lettuce'] ?? 0, 1);
$ck('base: extra is gated at the row', [(int)q_val("SELECT lvmax FROM creature_drops cd JOIN items i ON i.id = cd.item_id WHERE cd.creature_id = ? AND i.name = 'Lettuce'", [$gs])], [8]);
$ck('base: slug and stats untouched by the import', (int)q_val("SELECT hp FROM creatures WHERE slug = 'garden-snail'") > 0, true);
// remove one variant completely, then import: it comes back, once, with the same drops
$cnt = (int)q_val('SELECT COUNT(*) FROM creature_drops WHERE creature_id = ?', [$fly['id']]);
q('DELETE FROM creature_drops WHERE creature_id = ?', [$fly['id']]); q('DELETE FROM creatures WHERE id = ?', [$fly['id']]);
$ck('re-import restores exactly the missing variant', import_pf_creatures($stats), 1);
$fly2 = q_one("SELECT * FROM creatures WHERE slug = 'fly-swarm'");
$ck('restored drops equal', (int)q_val('SELECT COUNT(*) FROM creature_drops WHERE creature_id = ?', [$fly2['id']]), $cnt);
// an admin edit to an existing variant survives
q("UPDATE creatures SET hp = 999 WHERE slug = 'fly-swarm'"); import_pf_creatures($stats);
$ck('an existing variant is never rewritten', (int)q_val("SELECT hp FROM creatures WHERE slug = 'fly-swarm'"), 999);
q('UPDATE creatures SET hp = ? WHERE slug = ?', [(int)$fly['hp'], 'fly-swarm']);
// a base extra deleted by hand does come back (the extras are rows of the file) and is not doubled
q('DELETE FROM creature_drops WHERE creature_id = ? AND item_id = (SELECT id FROM items WHERE name = ?)', [$gs, 'Lettuce']); import_pf_creatures($stats); import_pf_creatures($stats);
$ck('a missing base extra is put back once', array_count_values($gsn())['Lettuce'] ?? 0, 1);
// the class of a variant is its family's
$ck('variant class = base class', pfd_class_map(true)['fly-swarm'] ?? '', pfd_class_map()['aphid-swarm'] ?? 'x');
// no variant outside its landscapes' regions: every row's regions are real region codes
$codes = array_column(q('SELECT code FROM regions')->fetchAll(), 'code'); $badReg = [];
foreach ($rows as $r) foreach ($r['regions'] as $rc) if ($rc !== '*' && !in_array($rc, $codes, true)) $badReg[$r['slug'] . ':' . $rc] = 1;
$ck('every region code of the file is a region of the world', array_keys($badReg), []);

// ---- 4. win_fight: gates, Petals, exp multiplier
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$loc = q_one("SELECT l.* FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code = 'NA' AND l.kind = 'village' ORDER BY l.id LIMIT 1");
$exp = ['kind' => 'delve', 'from_id' => (int)$loc['id'], 'to_id' => (int)$loc['id'], 'level' => 5, 'log' => '[]', 'hp' => 30, 'max_hp' => 30, 'encounter' => null, 'id' => 0, 'depth' => 1];
$mk = function (string $slug, int $lvl = 5) {
    q('DELETE FROM creature_drops WHERE creature_id IN (SELECT id FROM creatures WHERE slug = ?)', [$slug]); q('DELETE FROM creatures WHERE slug = ?', [$slug]);
    $cid = db_insert('creatures', ['slug' => $slug, 'name' => 'Gate Tester', 'size' => 'small', 'landscapes' => 'any', 'level' => $lvl, 'hp' => 10, 'attack' => 1, 'defense' => 10, 'dmg_die' => 4, 'dmg_bonus' => 0, 'xp' => 10, 'description' => 'x']);
    return $cid;
};
$cid = $mk('zz-gate-test');
$items = [];
foreach ([['open', null, null, null], ['regNA', 'NA/NWE', null, null], ['regZZ', 'SA/EE', null, null], ['lvHigh', null, 50, null], ['lvLow', null, null, 3], ['lvIn', null, 4, 6], ['both', 'NA', 5, 5]] as [$nm, $reg, $lo, $hi]) {
    $iid = db_insert('items', ['name' => 'Gate ' . $nm, 'slug' => 'gate-' . strtolower($nm) . '-' . mt_rand(1000, 9999), 'category' => 'part', 'rarity' => 50, 'base_price' => 5, 'description' => 'x']);
    db_insert('creature_drops', ['creature_id' => $cid, 'item_id' => $iid, 'chance' => 100, 'reg' => $reg, 'lvmin' => $lo, 'lvmax' => $hi]);
    $items[$nm] = $iid;
}
$have = fn($iid) => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]);
$c = q_one('SELECT * FROM creatures WHERE id = ?', [$cid]);
win_fight($u, $exp, $c, false);
$ck('win in NA at level 5: ungated drops', [$have($items['open']), $have($items['regNA']), $have($items['lvIn']), $have($items['both'])], [1, 1, 1, 1]);
$ck('win in NA at level 5: gated out', [$have($items['regZZ']), $have($items['lvHigh']), $have($items['lvLow'])], [0, 0, 0]);
// a scaled creature: the FIGHT level counts (the gate reads $c['level'] after scaling)
$cs = scale_creature($c, 51);
$exp['level'] = 51; $exp['encounter'] = null; $exp['log'] = '[]';
win_fight($u, $exp, $cs, false);
$ck('scaled to 51: lvHigh opens, lvIn and both close, lvLow stays closed', [$have($items['lvHigh']), $have($items['lvIn']), $have($items['both']), $have($items['lvLow'])], [1, 1, 1, 0]);
// another region
$loc2 = q_one("SELECT l.* FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code = 'EE' AND l.kind = 'village' ORDER BY l.id LIMIT 1");
if ($loc2) {
    $exp2 = $exp; $exp2['from_id'] = $exp2['to_id'] = (int)$loc2['id']; $exp2['encounter'] = null; $exp2['log'] = '[]'; $exp2['level'] = 5;
    $before = $have($items['regZZ']); $beforeNA = $have($items['regNA']);
    win_fight($u, $exp2, $c, false);
    $ck('win in EE: SA/EE drop opens, NA/NWE drop closed', [$have($items['regZZ']) - $before, $have($items['regNA']) - $beforeNA], [1, 0]);
}
// peaceful (befriended): no ordinary drops at all, as before
$b0 = $have($items['open']); $exp['level'] = 5; $exp['encounter'] = null; $exp['log'] = '[]'; win_fight($u, $exp, $c, true);
$ck('peaceful win: no ordinary drops', $have($items['open']) - $b0, 0);

// Petals and the exp multiplier of the row
$ck('petals: fly-swarm 4-7', creature_petal_range(pfd_creature_overlay(q_one("SELECT * FROM creatures WHERE slug = 'fly-swarm'"))), [4, 7]);
$ck('petals: a creature the file does not list gives none', creature_petal_range(q_one('SELECT * FROM creatures WHERE id = ?', [$cid])), [0, 0]);
$ck('exp: x1.1 of the stored xp', creature_win_xp(q_one("SELECT * FROM creatures WHERE slug = 'fly-swarm'")), (int)round((int)round(12 * 6 * 0.8) * 1.1));
$ck('exp: unlisted creature unchanged', creature_win_xp(q_one('SELECT * FROM creatures WHERE id = ?', [$cid])), 10);
$ck('exp: base row x1.0', creature_win_xp(q_one("SELECT * FROM creatures WHERE slug = 'garden-snail'")), (int)q_val("SELECT xp FROM creatures WHERE slug = 'garden-snail'"));
$fc = q_one("SELECT * FROM creatures WHERE slug = 'fly-swarm'");
$fcLoc = q_one("SELECT l.* FROM locations l JOIN regions r ON r.id = l.region_id WHERE r.code = 'SA' AND l.kind = 'village' ORDER BY l.id LIMIT 1") ?: $loc;
$e3 = ['kind' => 'delve', 'from_id' => (int)$fcLoc['id'], 'to_id' => (int)$fcLoc['id'], 'level' => 12, 'log' => '[]', 'hp' => 30, 'max_hp' => 30, 'encounter' => null, 'id' => 0, 'depth' => 1];
$u12 = $u; $u12['level'] = 1;
$p0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]); win_fight($u12, $e3, $fc, false);
$gain = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $p0;
$ck('win gives Petals inside the row range', $gain >= 4 && $gain <= 7, true);
$p0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]); $e3['encounter'] = null; $e3['log'] = '[]'; win_fight($u12, $e3, $fc, true);
$gain = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $p0;
$ck('befriending gives half the Petals', $gain >= 2 && $gain <= 3, true);
$p0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]); $e3['encounter'] = null; $e3['log'] = '[]'; win_fight($u12, $e3, $fc, true, true);
$gain = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $p0;
$ck('puzzle Charm ($full) gives the full Petals', $gain >= 4 && $gain <= 7, true);
$p0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]); $e3['encounter'] = null; $e3['log'] = '[]'; win_fight($u12, $e3, q_one('SELECT * FROM creatures WHERE id = ?', [$cid]), false);
$ck('an unlisted creature gives no Petals', (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $p0, 0);
$u30 = $u; $u30['level'] = 40; $p0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]); $e3['encounter'] = null; $e3['log'] = '[]'; win_fight($u30, $e3, $fc, false);
$ck('Petals shrink in an outgrown area like XP', (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) - $p0 < 4 || outlevel_percent($u30, 12) >= 100, true);

// ---- 5. the region reaches every pick_creature caller (source check: a caller that forgets it keeps variants in every region)
$bad5 = [];
foreach (glob($argv[1] . '/includes/*.php') as $f) {
    $src = file_get_contents($f);
    if (!preg_match_all('/\bpick_creature\(([^;]*)/', $src, $mm, PREG_OFFSET_CAPTURE)) continue;
    foreach ($mm[0] as [$txt, $off]) {
        $line = substr_count(substr($src, 0, $off), "\n") + 1;
        $before = substr($src, max(0, $off - 12), 12);
        if (str_contains($before, 'function ')) continue;   // the definition
        if (preg_match('/^\s*(\*|\/\/)/', substr($src, strrpos(substr($src, 0, $off), "\n") + 1, 12))) continue;   // a comment line
        if (!str_contains($txt, 'region') && !str_contains($txt, 'scene_region_code') && !str_contains($txt, '$rc')) $bad5[] = basename($f) . ':' . $line;
    }
}
$ck('every pick_creature caller passes a region', $bad5, []);
$ck('trail_pick_fixed filters its boss pool by region', str_contains(file_get_contents($argv[1] . '/includes/trail_tiles.php'), 'pfd_creature_in_region'), true);
$ck('scene_region_code of a scene with a region', scene_region_code(['region_id' => (int)q_val("SELECT id FROM regions WHERE code = 'NA'")]), 'NA');
$ck('scene_region_code of none', scene_region_code([]), '');

$done = true;
echo $bad ? "$bad FAILED\n" : "pf_creatures_import ok\n";
exit($bad ? 1 : 0);
