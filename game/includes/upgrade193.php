<?php
declare(strict_types=1);

// v1.9.3 upgrade steps. Same idea as upgrade170.php: each step runs once (flag setting upg193_<step>), inside try/catch, and is safe to call again.
// (The columns users.road_recent and problems/creatures/gatherables.cond come from db_migrate in schema.php.)

const UPGRADE_193_STEPS = [
    'road_cond' => 'Road life: new weather and season problems are added, and the time/season/weather tags (data files, last column) go on the problems, creatures and gatherables that have none yet',
];

/** Run every v1.9.3 step that has not been done yet. Returns the names of the steps that are done afterwards. */
function upgrade_193_run(): array
{
    $done = [];
    foreach (array_keys(UPGRADE_193_STEPS) as $name) {
        $flag = 'upg193_' . $name;
        if (setting($flag) === '1') { $done[] = $name; continue; }
        try {
            upgrade_tx(function () use ($name) {
                if ($name === 'road_cond') {
                    require_once __DIR__ . '/catalog.php';
                    require_once __DIR__ . '/adventure_data.php';
                    require_once __DIR__ . '/road_life.php';
                    import_problems_txt();    // only slugs the world does not have yet
                    road_cond_backfill();     // only rows whose cond is still empty: an admin's own tags stay
                }
            });
            set_setting($flag, '1');
            setting('__reload__');
            $done[] = $name;
        } catch (Throwable $e) {
            $msg = get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine();
            error_log('upgrade 1.9.3 step ' . $name . ' failed: ' . $msg);
            if (function_exists('game_error_log')) game_error_log('Upgrade 1.9.3 step "' . $name . '" failed: ' . $msg);
        }
    }
    return $done;
}
