<?php
declare(strict_types=1);

// v1.7.0 upgrade steps. Same idea as upgrade163.php: each step runs once (flag setting upg170_<step>), inside try/catch, and is safe to call again.

const UPGRADE_170_STEPS = [
    'reacts' => 'Garden reactions become Guestbook stamps: old garden_reacts rows are copied into garden_stamps (the old table is left in place, unused)',
];

/** Run every v1.7.0 step that has not been done yet. Returns the names of the steps that are done afterwards. */
function upgrade_170_run(): array
{
    $done = [];
    foreach (array_keys(UPGRADE_170_STEPS) as $name) {
        $flag = 'upg170_' . $name;
        if (setting($flag) === '1') { $done[] = $name; continue; }
        try {
            upgrade_tx(function () use ($name) {
                if ($name === 'reacts') {
                    // one stamp per plot + user + day (the table's UNIQUE key): a day that already has a stamp keeps it, the reaction is dropped
                    q("INSERT INTO garden_stamps (plot_id, user_id, day, stamp, stamped_at)
                       SELECT r.plot_id, r.user_id, r.day,
                              CASE r.kind WHEN 'sun' THEN 'sunflower' WHEN 'clap' THEN 'clap' WHEN 'bee' THEN 'bee' ELSE 'sparkle' END,
                              r.created_at
                       FROM garden_reacts r
                       WHERE r.kind IN ('sun', 'clap', 'bee', 'spark')
                         AND NOT EXISTS (SELECT 1 FROM garden_stamps s WHERE s.plot_id = r.plot_id AND s.user_id = r.user_id AND s.day = r.day)");
                }
            });
            set_setting($flag, '1');
            setting('__reload__');
            $done[] = $name;
        } catch (Throwable $e) {
            $msg = get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine();
            error_log('upgrade 1.7.0 step ' . $name . ' failed: ' . $msg);
            if (function_exists('game_error_log')) game_error_log('Upgrade 1.7.0 step "' . $name . '" failed: ' . $msg);
        }
    }
    return $done;
}
