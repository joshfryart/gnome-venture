<?php
declare(strict_types=1);

// Gameplay balance pass after 2.4.89 (garden reachable, no prizes for being alone). Same idea as upgrade140.php: each step runs once
// (flag setting upg249_<step>), inside try/catch, and is safe to call again. A stored setting is only rewritten while it still holds the old default.

const UPGRADE_249_STEPS = [
    'bedgrowth' => 'Add 4 beds: price growth becomes 20% (only if it was still the old 50)',
    'marrowmax' => 'Guess the Weight: the jackpot grows to 10,000 at most (only if it was still the old 25,000)',
    'marrowgrow' => 'Guess the Weight: the jackpot grows 500 a day (only if it was still the old 1,000)',
];

/** Run every step that has not been done yet. Returns the names of the steps that are done afterwards. */
function upgrade_249_run(): array
{
    $done = [];
    foreach (array_keys(UPGRADE_249_STEPS) as $name) {
        $flag = 'upg249_' . $name;
        if (setting($flag) === '1') { $done[] = $name; continue; }
        try {
            upgrade_tx(function () use ($name) {
                if ($name === 'bedgrowth') q("UPDATE settings SET value = '20' WHERE name = 'bed_add_growth_pct' AND value = '50'");
                if ($name === 'marrowmax') q("UPDATE settings SET value = '10000' WHERE name = 'marrow_jackpot_max' AND value = '25000'");
                if ($name === 'marrowgrow') q("UPDATE settings SET value = '500' WHERE name = 'marrow_jackpot_grow' AND value = '1000'");
            });
            set_setting($flag, '1');
            setting('__reload__');
            $done[] = $name;
        } catch (Throwable $e) {
            $msg = get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine();
            error_log('upgrade 2.4.9 step ' . $name . ' failed: ' . $msg);
            if (function_exists('game_error_log')) game_error_log('Upgrade 2.4.9 step "' . $name . '" failed: ' . $msg);
        }
    }
    return $done;
}
