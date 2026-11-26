<?php
// ONE-OFF live-world repair: routes.id one too LOW from 239 up (the W4 route-id bug, fixed in 2.8.74 for NEW worlds only).
// A bad world has 245 routes, ids 228-472, all used (route 239 present). The map data expects 245-slot numbering: 228-473 with 239 empty (the cut dead-end leg).
// This shifts every routes.id >= 239 up by 1 and the same in every table that holds route_id, so each route keeps its trail map, camp, road kind, trail pickups, sight uses, decor edits and walking expeditions.
//
//   php tools/renumber_routes_239.php GAME_DIR                         dry run: checks the world, prints what would change, writes nothing
//   php tools/renumber_routes_239.php GAME_DIR --apply [--backup-dir=DIR] [--i-have-a-db-backup]
//
// --apply always writes a JSON dump of the affected rows into the backup dir (default GAME_DIR/data/backup-route-renumber-<n>/). SQLite: it also copies game.sqlite there.
// MySQL: a JSON dump is NOT a full backup, so --apply refuses unless you pass --i-have-a-db-backup (take a real dump first, e.g. cPanel > phpMyAdmin > Export).
// Safe to repeat: a world already in the right shape is left alone. Anything that does not match the exact bad signature stops with an explanation and changes nothing.
// Run it with the site quiet (take it offline or do it at night): a player mid-walk is handled (expeditions are shifted), but a request in flight between statements is not.

if (PHP_SAPI !== 'cli') { exit("CLI only\n"); }
$game = rtrim((string)($argv[1] ?? ''), '/');
if ($game === '' || !is_file($game . '/includes/bootstrap.php')) { exit("Usage: php tools/renumber_routes_239.php GAME_DIR [--apply] [--backup-dir=DIR] [--i-have-a-db-backup]\n"); }
$apply = in_array('--apply', $argv, true);
$haveBackup = in_array('--i-have-a-db-backup', $argv, true);
$backupDir = '';
foreach ($argv as $a) if (strpos($a, '--backup-dir=') === 0) $backupDir = rtrim(substr($a, 13), '/');

$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $game . '/includes/bootstrap.php';

const GAP = 239;      // the burned id
const COUNT = 245, GOOD_MAX = 473, BAD_MAX = 472;   // both shapes have 245 routes; good ends at 473 with 239 empty, bad ends at 472 with 239 used
function out(string $s): void { echo $s . "\n"; }
function bail(string $s): void { out('STOP: ' . $s); exit(1); }

$driver = db()->getAttribute(PDO::ATTR_DRIVER_NAME);
$sqlite = $driver === 'sqlite';

// 1. state
$count = (int)q_val('SELECT COUNT(*) FROM routes');
$min = (int)q_val('SELECT MIN(id) FROM routes');
$max = (int)q_val('SELECT MAX(id) FROM routes');
$has239 = (bool)q_val('SELECT 1 FROM routes WHERE id = ?', [GAP]);
out("driver=$driver  routes=$count  ids $min-$max  route 239 " . ($has239 ? 'present' : 'absent'));
$nameOf = fn(int $id): string => (string)q_val('SELECT name FROM locations WHERE id = ?', [$id]);
$pair = function (int $id) use ($nameOf): string { $r = q_one('SELECT a_id, b_id FROM routes WHERE id = ?', [$id]); return $r ? $nameOf((int)$r['a_id']) . ' > ' . $nameOf((int)$r['b_id']) : '(none)'; };

if ($count === COUNT && $max === GOOD_MAX && !$has239) { out('This world already has the right numbering (245 routes, 228-473, no 239). Nothing to do.'); exit(0); }
if (!($count === COUNT && $min === 228 && $max === BAD_MAX && $has239)) {
    bail("this is not the known bad shape (want 245 routes, ids 228-472, route 239 present; the good shape is 245 routes, 228-473, no 239). Do not run this on it. Ask for a look.");
}
// the old 239 must be the far-neighbour pair that belongs at 240: Maizehollow Market > Meadowmere
$p238 = $pair(238); $p239 = $pair(GAP);
// in the bad world id 239 is the route that should be 240, and 238 is the last good one below the gap
out("route 238 = $p238");
out("route 239 = $p239   (the one that must become 240)");
if (strpos($p239, 'Maizehollow Market > Meadowmere') !== 0) bail("route 239 is not 'Maizehollow Market > Meadowmere', so this world is not the bad shape this script knows. Nothing changed.");

// 2. every table holding a route id
$tables = [];
if ($sqlite) {
    foreach (q("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")->fetchAll(PDO::FETCH_COLUMN) as $t) {
        foreach (q('PRAGMA table_info(' . $t . ')')->fetchAll() as $c) if ($c['name'] === 'route_id') $tables[] = $t;
    }
} else {
    foreach (q("SELECT TABLE_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND COLUMN_NAME = 'route_id'")->fetchAll(PDO::FETCH_COLUMN) as $t) $tables[] = $t;
}
sort($tables);
out('tables with a route_id column: ' . implode(', ', $tables));
$known = ['expeditions', 'trail_decor_edits', 'trail_pickups', 'trail_sight_uses'];
foreach ($tables as $t) if (!in_array($t, $known, true)) out("NOTE: $t is not one of the four tables this script was written for; it is shifted the same way (route_id >= " . GAP . ' + 1). Look at it after.');
foreach ($known as $t) if (!in_array($t, $tables, true)) out("note: expected table $t has no route_id here (older schema); skipped.");

$plan = ['routes' => (int)q_val('SELECT COUNT(*) FROM routes WHERE id >= ?', [GAP])];
foreach ($tables as $t) $plan[$t] = (int)q_val("SELECT COUNT(*) FROM $t WHERE route_id >= ?", [GAP]);
out('rows that move up by 1:');
foreach ($plan as $t => $n) out(sprintf('  %-22s %d', $t, $n));
// a route_id that points at no route (before the shift) would be shifted into a wrong one: report
foreach ($tables as $t) {
    $orphans = (int)q_val("SELECT COUNT(*) FROM $t WHERE route_id NOT IN (SELECT id FROM routes)");
    if ($orphans) out("WARNING: $t has $orphans row(s) whose route_id matches no route (left as they are if below " . GAP . ', shifted if above).');
}
$live = (int)q_val('SELECT COUNT(*) FROM expeditions WHERE route_id >= ?', [GAP]) ;
if ($live) out("note: $live expedition row(s) are on a shifted route (finished ones are shifted too, so history stays right).");

if (!$apply) { out("\nDRY RUN: nothing written. Add --apply to do it."); exit(0); }

// 3. backup
if (!$sqlite && !$haveBackup) bail('MySQL: take a full database dump first, then run again with --i-have-a-db-backup. A JSON dump of the affected rows is written, but it is not a full backup.');
if ($backupDir === '') {
    $n = 1; while (is_dir($game . '/data/backup-route-renumber-' . $n)) $n++;
    $backupDir = $game . '/data/backup-route-renumber-' . $n;
}
if (!is_dir($backupDir) && !mkdir($backupDir, 0775, true)) bail("cannot create backup dir $backupDir");
$dump = ['driver' => $driver, 'tables' => []];
foreach (array_merge(['routes'], $tables) as $t) $dump['tables'][$t] = q("SELECT * FROM $t" . ($t === 'routes' ? ' WHERE id >= ?' : ' WHERE route_id >= ?'), [GAP])->fetchAll(PDO::FETCH_ASSOC);
if (file_put_contents($backupDir . '/affected-rows.json', json_encode($dump, JSON_PRETTY_PRINT)) === false) bail('cannot write the JSON backup');
if ($sqlite) {
    $dbFile = $game . '/data/game.sqlite';
    if (!is_file($dbFile) || !copy($dbFile, $backupDir . '/game.sqlite.bak')) bail("cannot copy $dbFile into the backup dir");
}
out("backup written to $backupDir");

// 4. shift, highest id first (so no id lands on one not yet moved), all in one transaction
$ok = false;
db()->beginTransaction();
try {
    $ids = q('SELECT id FROM routes WHERE id >= ? ORDER BY id DESC', [GAP])->fetchAll(PDO::FETCH_COLUMN);
    foreach ($ids as $id) q('UPDATE routes SET id = ? WHERE id = ?', [(int)$id + 1, (int)$id]);
    foreach ($tables as $t) {
        $rids = q("SELECT DISTINCT route_id FROM $t WHERE route_id >= ? ORDER BY route_id DESC", [GAP])->fetchAll(PDO::FETCH_COLUMN);
        foreach ($rids as $rid) q("UPDATE $t SET route_id = ? WHERE route_id = ?", [(int)$rid + 1, (int)$rid]);
    }
    // verify BEFORE commit
    $c2 = (int)q_val('SELECT COUNT(*) FROM routes'); $mn = (int)q_val('SELECT MIN(id) FROM routes'); $mx = (int)q_val('SELECT MAX(id) FROM routes');
    $g2 = (bool)q_val('SELECT 1 FROM routes WHERE id = ?', [GAP]);
    $q240 = $pair(240); $q241 = $pair(241);
    if ($c2 !== COUNT || $mn !== 228 || $mx !== GOOD_MAX || $g2) throw new RuntimeException("after the shift: $c2 routes, ids $mn-$mx, 239 " . ($g2 ? 'present' : 'absent') . ' (want 245, 228-473, absent)');
    if (strpos($q240, 'Maizehollow Market > Meadowmere') !== 0) throw new RuntimeException("route 240 is '$q240'");
    if (strpos($q241, 'Meadowmere > Shoreford') !== 0) throw new RuntimeException("route 241 is '$q241'");
    db()->commit();
    $ok = true;
} catch (Throwable $e) {
    if (db()->inTransaction()) db()->rollBack();
    out('FAILED, rolled back: ' . $e->getMessage());
}
if (!$ok) { out('Nothing was changed. The backup is in ' . $backupDir); exit(1); }

// 5. next new route id (outside the transaction: MySQL DDL commits on its own)
$mx = (int)q_val('SELECT MAX(id) FROM routes');
if ($sqlite) { q("UPDATE sqlite_sequence SET seq = ? WHERE name = 'routes'", [$mx]); }
else { q('ALTER TABLE routes AUTO_INCREMENT = ' . ($mx + 1)); }
out("DONE: routes now " . q_val('SELECT COUNT(*) FROM routes') . ", ids 228-$mx, no 239. 240 = " . $pair(240) . '; 241 = ' . $pair(241));
out('Next: load a Trail page and a camp in the live game and look. To undo: put the backup back (SQLite: game.sqlite.bak; MySQL: your full dump).');
