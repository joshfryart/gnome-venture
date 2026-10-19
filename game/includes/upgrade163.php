<?php
declare(strict_types=1);

// v1.6.3 upgrade steps. Same idea as upgrade140.php: each step runs once (flag setting upg163_<step>), inside try/catch, and is safe to call again.

const UPGRADE_163_STEPS = [
    'adoptlimit' => 'Adopt-a-stop: the limit is now the most one gnome can look after, default 3 (only if it was still the old 1)',
    'wormhours' => 'Worm colony gives a gift every 12 hours instead of 24 (only if it was still the old 24)',
];

/** Run every v1.6.3 step that has not been done yet. Returns the names of the steps that are done afterwards. */
function upgrade_163_run(): array
{
    $done = [];
    foreach (array_keys(UPGRADE_163_STEPS) as $name) {
        $flag = 'upg163_' . $name;
        if (setting($flag) === '1') { $done[] = $name; continue; }
        try {
            upgrade_tx(function () use ($name) {
                if ($name === 'adoptlimit') q("UPDATE settings SET value = '3' WHERE name = 'stop_adopt_limit' AND value = '1'");
                if ($name === 'wormhours') q("UPDATE critter_kinds SET gift_hours = 12 WHERE slug = 'worm' AND gift_hours = 24");
            });
            set_setting($flag, '1');
            setting('__reload__');
            $done[] = $name;
        } catch (Throwable $e) {
            $msg = get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine();
            error_log('upgrade 1.6.3 step ' . $name . ' failed: ' . $msg);
            if (function_exists('game_error_log')) game_error_log('Upgrade 1.6.3 step "' . $name . '" failed: ' . $msg);
        }
    }
    if ($done) { if (function_exists('critter_forget')) critter_forget(); }
    return $done;
}
