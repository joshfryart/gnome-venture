<?php
declare(strict_types=1);

// v1.2.0 upgrade steps. Same idea as upgrade110.php: each step runs once (flag setting upg120_<step>), inside try/catch, and is safe to call again.

const UPGRADE_120_STEPS = [
    'animals' => 'More garden animals: Quail Coop, Silkworm Shelf, Tortoise Run, Clementine the goat, Percy the pigeon (items, kinds, recipes, Almanac pages)',
    'mentors' => 'Player mentors: tables, columns and Almanac pages',
];

/** Run every v1.2.0 step that has not been done yet. Returns the names of the steps that are done afterwards. */
function upgrade_120_run(): array
{
    $done = [];
    foreach (array_keys(UPGRADE_120_STEPS) as $name) {
        $flag = 'upg120_' . $name;
        if (setting($flag) === '1') { $done[] = $name; continue; }
        try {
            if ($name === 'mentors') {   // CREATE/ALTER commit implicitly on MySQL, so this one runs outside a transaction (it is idempotent)
                require_once __DIR__ . '/mentors120.php';
                mentors120_upgrade();
            } else {
                upgrade_tx(function () {
                    require_once __DIR__ . '/animals120.php';
                    animals120_upgrade();
                });
            }
            set_setting($flag, '1');
            setting('__reload__');
            $done[] = $name;
        } catch (Throwable $e) {
            $msg = get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine();
            error_log('upgrade 1.2.0 step ' . $name . ' failed: ' . $msg);
            if (function_exists('game_error_log')) game_error_log('Upgrade 1.2.0 step "' . $name . '" failed: ' . $msg);
        }
    }
    return $done;
}
