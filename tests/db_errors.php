<?php
// db_migrate() must report an index that cannot be created (only "already exists" is ignored), and give_item() must
// swallow only a duplicate-key race and rethrow every other insert failure.
// Needs no installed world: builds throw-away databases itself.
//   SQLite (default):  php tests/db_errors.php
//   MySQL:             GV_TEST_DRIVER=mysql GV_DB_HOST=127.0.0.1 GV_DB_PORT=3306 GV_DB_NAME=gv GV_DB_USER=root GV_DB_PASS=... php tests/db_errors.php
//                      (the database is emptied first: use a scratch one)
$game = dirname(__DIR__) . '/game';
define('APP_ROOT', $game);
require $game . '/includes/db.php';
require $game . '/includes/functions.php';
if (is_file($game . '/includes/inventory.php')) require_once $game . '/includes/inventory.php';   // give_item() lives here in newer trees
if (getenv('GV_TEST_WORKER')) {   // child of the MySQL race below: give one item, say so loudly if it throws
    $GLOBALS['CONFIG'] = ['db' => ['driver' => 'mysql', 'host' => getenv('GV_DB_HOST') ?: '127.0.0.1', 'port' => (int)(getenv('GV_DB_PORT') ?: 3306), 'name' => getenv('GV_DB_NAME') ?: 'gv', 'user' => getenv('GV_DB_USER') ?: 'root', 'pass' => (string)getenv('GV_DB_PASS')]];
    try { $r = give_item((int)getenv('GV_W_UID'), (int)getenv('GV_W_IID'), 1); echo $r ? 'WORKER_OK' : 'WORKER_FAIL returned false'; }
    catch (Throwable $e) { echo 'WORKER_FAIL ' . $e->getMessage(); }
    exit(0);
}
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

$driver = getenv('GV_TEST_DRIVER') ?: 'sqlite';
$tmp = sys_get_temp_dir() . '/gv-dberr-' . getmypid() . '.sqlite';
$conf = $driver === 'mysql'
    ? ['driver' => 'mysql', 'host' => getenv('GV_DB_HOST') ?: '127.0.0.1', 'port' => (int)(getenv('GV_DB_PORT') ?: 3306), 'name' => getenv('GV_DB_NAME') ?: 'gv', 'user' => getenv('GV_DB_USER') ?: 'root', 'pass' => (string)getenv('GV_DB_PASS')]
    : ['driver' => 'sqlite', 'path' => $tmp];
$GLOBALS['CONFIG'] = ['db' => $conf];
register_shutdown_function(function () use ($tmp) { foreach ([$tmp, "$tmp-wal", "$tmp-shm"] as $f) @unlink($f); });

/** Empty the database so each section starts from nothing. */
$wipe = function () use ($driver, $tmp) {
    $pdo = db();
    if ($driver === 'mysql') {
        $pdo->exec('SET FOREIGN_KEY_CHECKS = 0');
        foreach ($pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN) as $t) $pdo->exec("DROP TABLE `$t`");
        $pdo->exec('SET FOREIGN_KEY_CHECKS = 1');
    } else {
        foreach ($pdo->query("SELECT name, type FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' AND type IN ('table')")->fetchAll() as $r) $pdo->exec('DROP TABLE "' . $r['name'] . '"');
    }
};
$wipe();   // also makes sure the connection works
$pdo = db();
$mig = fn() => db_migrate($pdo, $driver);

echo "== db_migrate: clean run and rerun\n";
unset($GLOBALS['gv_migrate_errors']);
$mig();
ok('fresh database migrates with no errors', empty($GLOBALS['gv_migrate_errors']), implode('; ', $GLOBALS['gv_migrate_errors'] ?? []));
unset($GLOBALS['gv_migrate_errors']);
$mig();
ok('running it again is silent ("already exists" is ignored)', empty($GLOBALS['gv_migrate_errors']), implode('; ', $GLOBALS['gv_migrate_errors'] ?? []));

echo "== db_migrate: a unique index that cannot be built (duplicate data) is reported\n";
$wipe();
// an old plants table with duplicate slugs, so CREATE UNIQUE INDEX idx_plants_slug has to fail
$pdo->exec($driver === 'mysql' ? 'CREATE TABLE plants (id INT AUTO_INCREMENT PRIMARY KEY, slug VARCHAR(80) NOT NULL)' : 'CREATE TABLE plants (id INTEGER PRIMARY KEY AUTOINCREMENT, slug VARCHAR(80) NOT NULL)');
$pdo->exec("INSERT INTO plants (slug) VALUES ('dupe'), ('dupe')");
unset($GLOBALS['gv_migrate_errors']);
$done = $mig();
$errs = $GLOBALS['gv_migrate_errors'] ?? [];
$hit = array_values(array_filter($errs, fn($m) => stripos($m, 'idx_plants_slug') !== false));
ok('the failed unique index is in gv_migrate_errors', count($hit) === 1, json_encode($errs));
ok('the error carries the database message', $hit && preg_match('/unique|duplicate/i', $hit[0]) === 1, $hit[0] ?? '');
ok('the failed index is not reported as done', !array_filter($done, fn($s) => is_string($s) && stripos($s, 'idx_plants_slug') !== false));
ok('the other indexes were still created', in_array('CREATE INDEX idx_routes_a ON routes (a_id)', $done, true));

echo "== db_migrate: an index on a missing column is reported (not mistaken for \"already exists\")\n";
$wipe();
$pdo->exec($driver === 'mysql' ? 'CREATE TABLE routes (id INT AUTO_INCREMENT PRIMARY KEY)' : 'CREATE TABLE routes (id INTEGER PRIMARY KEY AUTOINCREMENT)');
unset($GLOBALS['gv_migrate_errors']);
$mig();
$errs = $GLOBALS['gv_migrate_errors'] ?? [];
// the ADD COLUMN step may legitimately add a_id; only assert when the column really is still missing
$stillMissing = true;
try { $pdo->query('SELECT a_id FROM routes LIMIT 1'); $stillMissing = false; } catch (PDOException $e) {}
if ($stillMissing) ok('idx_routes_a failure is reported', (bool)array_filter($errs, fn($m) => stripos($m, 'idx_routes_a') !== false), json_encode($errs));
else echo "  skip routes case (column was added by migrate)\n";

echo "== db_migrate: GV_MIGRATE_STRICT throws on an index error\n";
$wipe();
$pdo->exec($driver === 'mysql' ? 'CREATE TABLE plants (id INT AUTO_INCREMENT PRIMARY KEY, slug VARCHAR(80) NOT NULL)' : 'CREATE TABLE plants (id INTEGER PRIMARY KEY AUTOINCREMENT, slug VARCHAR(80) NOT NULL)');
$pdo->exec("INSERT INTO plants (slug) VALUES ('dupe'), ('dupe')");
define('GV_MIGRATE_STRICT', true);
$threw = false; $msg = '';
try { $mig(); } catch (RuntimeException $e) { $threw = true; $msg = $e->getMessage(); }
ok('strict mode throws RuntimeException naming the index', $threw && stripos($msg, 'idx_plants_slug') !== false, $msg);

echo "== give_item\n";
$wipe();
$mig();   // strict is on, so this also proves a clean schema has no index errors
$pdo->exec("INSERT INTO users (username, email, password_hash, created_at) VALUES ('t', 't@b.local', 'x', '2020-01-01 00:00:00')");
$uid = (int)$pdo->lastInsertId();
$pdo->exec("INSERT INTO items (slug, name) VALUES ('test-item', 'Test item')");
$iid = (int)$pdo->lastInsertId();
$qty = fn() => (int)q_val('SELECT COALESCE(SUM(qty), 0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]);
$rows = fn() => (int)q_val('SELECT COUNT(*) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]);

ok('plain give creates the row', give_item($uid, $iid, 3) === true && $qty() === 3 && $rows() === 1);
ok('second give adds to it', give_item($uid, $iid, 2) === true && $qty() === 5 && $rows() === 1);
q('DELETE FROM user_items');

// A real duplicate race: the winner's row exists, but our first UPDATE has already missed it, so our INSERT hits the genuine
// unique constraint. SQLite is single-writer, so the miss is staged with a one-shot trigger that skips the first UPDATE.
if ($driver === 'sqlite') {
    $pdo->exec("INSERT INTO user_items (user_id, item_id, qty) VALUES ($uid, $iid, 100)");
    $pdo->exec('CREATE TABLE gv_once (n INTEGER)');
    $pdo->exec('INSERT INTO gv_once VALUES (0)');
    $pdo->exec("CREATE TRIGGER gv_race BEFORE UPDATE ON user_items WHEN (SELECT n FROM gv_once) = 0
        BEGIN UPDATE gv_once SET n = 1; SELECT RAISE(IGNORE); END");
}
if ($driver === 'sqlite') {
    try { $r = give_item($uid, $iid, 3); } catch (Throwable $e) { $r = false; echo "    threw: " . $e->getMessage() . "\n"; }
    ok('duplicate race: give_item returns true', $r === true);
    ok('duplicate race: quantity was added to the winner\'s row (100 + 3)', $qty() === 103, (string)$qty());
    ok('duplicate race: still exactly one row', $rows() === 1);
    $pdo->exec('DROP TRIGGER gv_race');
    $pdo->exec('DROP TABLE gv_once');
} else {
    // Real concurrency on MySQL: many children give the same new item at once; exactly one INSERT wins, the rest hit 1062.
    q('DELETE FROM user_items');
    $self = escapeshellarg(PHP_BINARY);
    $worker = escapeshellarg(__FILE__);
    $env = 'GV_TEST_DRIVER=mysql GV_TEST_WORKER=1 GV_W_UID=' . $uid . ' GV_W_IID=' . $iid;
    $procs = [];
    for ($i = 0; $i < 12; $i++) $procs[] = popen("$env $self $worker 2>&1", 'r');
    $out = '';
    foreach ($procs as $p) { $out .= stream_get_contents($p); pclose($p); }
    ok('duplicate race (12 parallel givers): no worker threw', strpos($out, 'WORKER_FAIL') === false, $out);
    ok('duplicate race: one row, all 12 quantities added', $rows() === 1 && $qty() === 12, 'rows=' . $rows() . ' qty=' . $qty());
}

// A non-duplicate failure must be rethrown, not swallowed.
q('DELETE FROM user_items');
if ($driver === 'sqlite') {
    $pdo->exec("CREATE TRIGGER gv_boom BEFORE INSERT ON user_items BEGIN SELECT RAISE(ABORT, 'disk on fire'); END");
    $threw = null;
    try { give_item($uid, $iid, 4); } catch (PDOException $e) { $threw = $e; }
    ok('non-duplicate insert failure is rethrown as PDOException', $threw instanceof PDOException && stripos($threw->getMessage(), 'disk on fire') !== false, $threw ? $threw->getMessage() : 'nothing thrown');
    ok('nothing was written', $rows() === 0);
    $pdo->exec('DROP TRIGGER gv_boom');
    // a constraint failure that is not UNIQUE (same SQLite code 19) must also come through
    $pdo->exec('DROP TABLE user_items');
    $pdo->exec('CREATE TABLE user_items (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, item_id INTEGER NOT NULL, qty INTEGER NOT NULL DEFAULT 0 CHECK (qty < 50), got_at DATETIME NULL, UNIQUE (user_id, item_id))');
    $threw = null;
    try { give_item($uid, $iid, 99); } catch (PDOException $e) { $threw = $e; }
    ok('CHECK constraint failure (SQLite code 19, not UNIQUE) is rethrown', $threw instanceof PDOException && stripos($threw->getMessage(), 'CHECK') !== false, $threw ? $threw->getMessage() : 'nothing thrown');
} else {
    // MySQL: a foreign key to a user that does not exist is a non-duplicate failure (1452)
    $pdo->exec('ALTER TABLE user_items ADD CONSTRAINT gv_fk_user FOREIGN KEY (user_id) REFERENCES users (id)');
    $threw = null;
    try { give_item($uid + 9999, $iid, 4); } catch (PDOException $e) { $threw = $e; }
    ok('FK violation (MySQL 1452) is rethrown', $threw instanceof PDOException && ($threw->errorInfo[1] ?? 0) === 1452, $threw ? $threw->getMessage() : 'nothing thrown');
}
// a missing table is always a non-duplicate failure
$pdo->exec('DROP TABLE user_items');
$threw = null;
try { give_item($uid, $iid, 1); } catch (PDOException $e) { $threw = $e; }
ok('missing table is rethrown', $threw instanceof PDOException);

echo $fails ? "\n$fails FAILED\n" : "\nall passed\n";
exit($fails ? 1 : 0);
