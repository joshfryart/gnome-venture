<?php
declare(strict_types=1);
/**
 * Graphical navigation (plan: claude/plan-graphical-nav.md), Phase 1: settings and tables.
 * Wiring: here_settings() is merged by settings_schema() (functions.php); here_schema() by schema.php.
 * Everything is additive: with gnav_on = 0 (the default) the game is exactly as before.
 */

/** Admin settings, merged into settings_schema(). */
function here_settings(): array
{
    return [
        'gnav_on' => ['label' => 'Picture navigation: the Here page, and Here in the bottom bar and menu (off = today’s game exactly)', 'type' => 'bool', 'default' => '0'],
        'gnav_tiles' => ['label' => 'Picture navigation: walk the Trail as tile sections (needs the above; not built yet)', 'type' => 'bool', 'default' => '0'],
        'gnav_enter_energy' => ['label' => 'Picture navigation: energy to step onto the Trail from a place (tile walks only; the number shown is the number charged)', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 100],
        'gnav_login_here' => ['label' => 'Picture navigation: logging in lands on Here (a player can pick Home in Account)', 'type' => 'bool', 'default' => '1'],
    ];
}

/** Tables and columns. Returns [tables, indexes, columns] like the other *_schema() functions. */
function here_schema(string $PK, string $ID, string $END): array
{
    $t = ["CREATE TABLE IF NOT EXISTS here_layouts (
        layout_key VARCHAR(80) NOT NULL PRIMARY KEY,
        json TEXT NOT NULL,
        updated_at DATETIME NOT NULL
    )$END"];
    return [$t, [], [['users', 'start_page', 'VARCHAR(8) NULL']]];   // start_page: NULL = the default, 'here' or 'home'
}

/** Is the picture navigation on for everyone? */
function gnav_on(): bool
{
    return setting('gnav_on') === '1';
}

/** Does this gnome use Here as the first page after login / welcome back? (gnav_on, gnav_login_here, and not their own "Home" choice) */
function gnav_start_here(array $u): bool
{
    return gnav_on() && setting('gnav_login_here') === '1' && ($u['start_page'] ?? null) !== 'home';
}

/**
 * Make sure users.start_page and here_layouts exist. The upgrade makes them when the version changes; this covers the days between
 * uploading the files and the upgrade running. Returns true when the column is there.
 */
function here_ensure_schema(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT start_page FROM users LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        db()->exec('ALTER TABLE users ADD COLUMN start_page VARCHAR(8) NULL');
        return $ok = true;
    } catch (Throwable $e) {
        error_log('here_ensure_schema: ' . $e->getMessage());
        return $ok = false;
    }
}

/** Make the here_layouts table if the upgrade has not yet (admin editor; reading it never needs it). */
function here_ensure_layouts_table(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM here_layouts LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        [$t] = here_schema('', '', $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
        foreach ($t as $sql) db()->exec($sql);
        return $ok = true;
    } catch (Throwable $e) {
        error_log('here_ensure_layouts_table: ' . $e->getMessage());
        return $ok = false;
    }
}
