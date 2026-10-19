<?php
declare(strict_types=1);

/**
 * v1.0.0 upgrade steps. Each step has its own "done" flag in settings and runs inside try/catch (Throwable), so one failing step
 * never takes the site down: it is logged (data/error-log.txt), a failure note is kept in settings, and the admin dashboard shows
 * "upgrade step X failed" with a Retry button. A lock file stops two first requests from running the upgrade at the same time.
 * Every step is idempotent, so re-running it (a retry, or a request that died halfway) is safe.
 */
const UPGRADE_100_STEPS = [
    // name => [done flag in settings, what it does]
    'clock'  => ['upg100_clock',  'Seasons calendar and Almanac page'],
    'garden' => ['upg100_garden', 'Crop seasons, pests, companions and garden animals'],
    'market' => ['market100',     'Orders, market day and the old favours carried over'],
    'social' => ['social100',     'Friends, festivals, goals and First Week'],
    'stops'  => ['upg100_stops',  'Rest stop types, villagers and the passport'],
];
const UPGRADE_100_RETRY_AFTER = 600;   // seconds before a failed step is tried again by itself

/** Take the upgrade lock (waits up to $waitMs). True if this process now holds it (or already did). Without a writable data/ folder it just carries on. */
function upgrade_lock(int $waitMs = 20000): bool
{
    static $fh = null;
    if ($fh !== null) return true;
    $path = dirname(__DIR__) . '/data/upgrade.lock';
    $h = @fopen($path, 'c');
    if (!$h) return true;   // can't lock here; better to go on than to block the upgrade
    $until = microtime(true) + $waitMs / 1000;
    do {
        if (flock($h, LOCK_EX | LOCK_NB)) { $fh = $h; return true; }
        usleep(250000);
    } while (microtime(true) < $until);
    fclose($h);
    return false;
}

function upgrade_unlock(): void
{
    // the lock is released when the request ends; nothing else to do (kept as a named hook for tests/tools)
}

function upgrade_100_failed(): array
{
    $out = [];
    foreach (UPGRADE_100_STEPS as $name => [$flag, $label]) {
        $f = setting('upg100_fail_' . $name);
        if ($f !== '' && setting($flag) !== '1') $out[$name] = [$label, $f];
    }
    return $out;
}

function upgrade_100_pending(): array
{
    $out = [];
    foreach (UPGRADE_100_STEPS as $name => [$flag, $label]) if (setting($flag) !== '1') $out[] = $name;
    return $out;
}

/** Run a bulk loop in one transaction (when none is open). */
function upgrade_tx(callable $fn)
{
    $own = !db()->inTransaction();
    if ($own) db()->beginTransaction();
    try {
        $r = $fn();
        if ($own) db()->commit();
        return $r;
    } catch (Throwable $e) {
        if ($own && db()->inTransaction()) db()->rollBack();
        throw $e;
    }
}

/**
 * Run one step unless its flag says it is done. $force skips the "failed a moment ago" back-off (admin retry, install).
 * Returns true if the step is done afterwards.
 */
function upgrade_100_run_step(string $name, bool $force = false): bool
{
    if (!isset(UPGRADE_100_STEPS[$name])) return false;
    [$flag] = UPGRADE_100_STEPS[$name];
    if (setting($flag) === '1') return true;
    $failKey = 'upg100_fail_' . $name;
    $failed = setting($failKey);
    if (!$force && $failed !== '' && (int)strtok($failed, '|') > time() - UPGRADE_100_RETRY_AFTER) return false;   // failed a moment ago: don't hammer it every request
    if (!upgrade_lock(5000)) return false;
    setting('__reload__');
    if (setting($flag) === '1') return true;   // someone else finished it while we waited
    try {
        upgrade_tx(function () use ($name, $flag) {   // all or nothing: a step that dies halfway leaves nothing behind to trip over
            switch ($name) {
                case 'clock': require_once __DIR__ . '/hollow_clock.php'; upgrade_100_clock(); break;
                case 'garden': require_once __DIR__ . '/garden_world.php'; upgrade_100_garden(); break;
                case 'market': require_once __DIR__ . '/market100.php'; upgrade_100_market(); break;
                case 'social': require_once __DIR__ . '/social.php'; upgrade_100_social(); break;
                case 'stops': require_once __DIR__ . '/stops.php'; upgrade_100_stops(); break;
            }
            if ($flag !== 'market100' && $flag !== 'social100') set_setting($flag, '1');   // (market and social set their own flags at the end)
        });
        if ($failed !== '') q('DELETE FROM settings WHERE name = ?', [$failKey]);
        setting('__reload__');
        return setting($flag) === '1';
    } catch (Throwable $e) {
        $msg = get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine();
        error_log('upgrade 1.0.0 step ' . $name . ' failed: ' . $msg);
        if (function_exists('game_error_log')) game_error_log('Upgrade step "' . $name . '" failed: ' . $msg . "\n" . $e->getTraceAsString());
        try { set_setting($failKey, time() . '|' . mb_substr($msg, 0, 300)); setting('__reload__'); } catch (Throwable $e2) {}
        return false;
    }
}
