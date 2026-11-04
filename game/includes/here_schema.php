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
