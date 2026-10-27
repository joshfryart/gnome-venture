<?php
declare(strict_types=1);

/** Database access. Works with MySQL (live site) and SQLite (local testing). */

function db_connect(array $c): PDO
{
    $opts = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];
    if (($c['driver'] ?? '') === 'sqlite') {
        $path = (string)$c['path'];
        // Relative paths are relative to the game folder (absolute: /..., C:\..., \\server\...)
        if (!preg_match('~^(/|\\\\|[A-Za-z]:[\\\\/])~', $path) && defined('APP_ROOT')) {
            $path = APP_ROOT . '/' . $path;
        }
        $pdo = new PDO('sqlite:' . $path, null, null, $opts);
        $pdo->exec('PRAGMA foreign_keys = ON');
        $pdo->exec('PRAGMA journal_mode = WAL');
        return $pdo;
    }
    if (defined('PDO::MYSQL_ATTR_FOUND_ROWS')) {
        $opts[PDO::MYSQL_ATTR_FOUND_ROWS] = true;   // rowCount() = rows matched, same as SQLite
    }
    $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
        $c['host'], (int)($c['port'] ?? 3306), $c['name']);
    return new PDO($dsn, $c['user'], $c['pass'], $opts);
}

function db(): PDO
{
    static $pdo = null;
    global $CONFIG;
    if ($pdo === null) {
        $pdo = db_connect($CONFIG['db']);
    }
    return $pdo;
}

/** Run a prepared query. ALWAYS pass user input through $params, never into $sql. */
function q(string $sql, array $params = []): PDOStatement
{
    $st = db()->prepare($sql);
    $st->execute($params);
    return $st;
}

function q_one(string $sql, array $params = []): ?array
{
    $row = q($sql, $params)->fetch();
    return $row === false ? null : $row;
}

function q_val(string $sql, array $params = [])
{
    $v = q($sql, $params)->fetchColumn();
    return $v === false ? null : $v;
}

/** Insert a row from a [column => value] array. Column names must come from code, never from users. */
function db_insert(string $table, array $row): int
{
    $cols = array_keys($row);
    $sql = 'INSERT INTO ' . $table . ' (' . implode(',', $cols) . ') VALUES (' .
        implode(',', array_fill(0, count($cols), '?')) . ')';
    q($sql, array_values($row));
    return (int)db()->lastInsertId();
}

function db_update(string $table, array $row, string $where, array $whereParams): void
{
    $sets = [];
    foreach (array_keys($row) as $c) {
        $sets[] = $c . ' = ?';
    }
    q('UPDATE ' . $table . ' SET ' . implode(', ', $sets) . ' WHERE ' . $where,
        array_merge(array_values($row), $whereParams));
}

/**
 * v1.0.0: run $fn inside a transaction. $fn may roll back itself and return early (then nothing is committed); anything thrown
 * rolls back and is rethrown, so no path leaves a transaction open. Nested use just runs $fn in the caller's transaction.
 */
function db_tx(callable $fn)
{
    if (db()->inTransaction()) return $fn();
    db()->beginTransaction();
    try {
        $r = $fn();
        if (db()->inTransaction()) db()->commit();
        return $r;
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();
        throw $e;
    }
}

/** ORDER BY random, for whichever database is in use. */
function sql_random(): string
{
    return db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql' ? 'RAND()' : 'RANDOM()';
}

function now(): string
{
    return gmdate('Y-m-d H:i:s');
}

/** Create any missing tables/indexes. Safe to run repeatedly (used by installer and "Upgrade database"). */
function db_migrate(PDO $pdo, string $driver): array
{
    require_once __DIR__ . '/schema.php';
    [$tables, $indexes, $columns] = schema_statements($driver);
    $done = [];
    $errors = [];
    foreach ($tables as $sql) {
        try {
            $pdo->exec($sql);
        } catch (PDOException $e) {   // v1.0.0: one bad statement must not stop the columns and indexes from being added
            $errors[] = substr(trim(preg_replace('/\s+/', ' ', $sql)), 0, 60) . ' -> ' . $e->getMessage();
        }
    }
    foreach ($columns as [$table, $col, $def]) {
        try {
            $pdo->query("SELECT $col FROM $table LIMIT 1");
        } catch (PDOException $e) {
            try {
                $pdo->exec("ALTER TABLE $table ADD COLUMN $col $def");
                $done[] = "$table.$col";
            } catch (PDOException $e2) {
                $errors[] = "$table.$col -> " . $e2->getMessage();
            }
        }
    }
    foreach ($indexes as $sql) {
        try {
            $pdo->exec($sql);
            $done[] = $sql;
        } catch (PDOException $e) {
            // Only "index already exists" is fine (MySQL 1061, SQLite "already exists"); anything else must not pass silently.
            if (($e->errorInfo[1] ?? 0) === 1061 || stripos($e->getMessage(), 'already exists') !== false) continue;
            $errors[] = substr(trim(preg_replace('/\s+/', ' ', $sql)), 0, 60) . ' -> ' . $e->getMessage();
        }
    }
    if ($errors) {
        foreach ($errors as $m) error_log('db_migrate: ' . $m);
        $GLOBALS['gv_migrate_errors'] = $errors;
        if (defined('GV_MIGRATE_STRICT')) throw new RuntimeException('db_migrate: ' . implode('; ', $errors));
    }
    return $done;
}
