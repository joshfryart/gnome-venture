<?php
declare(strict_types=1);
/**
 * v2.6.40: Garden crew. Every garden has five pal slots (Water, Weed, Pests, Harvest, Plant). A pal in a slot works while the gnome SLEEPS:
 * game_new_day() calls pcrew_night() once per sleep, in a fixed order: pests, weeds, harvest, (plant: phase 3), water. Time modes: 'timed' (1/3/7 sleeps,
 * counted from the next sleep) or 'full' (until called home). A pal sent home rests one game day (garden_pal_rest) and cannot be assigned until the next sleep.
 * What happened is saved per sleep in sleep_report (the Hovel shows it). Design + mockups: claude/todo.md (2026-11-10), pal_garden_mockups.html.
 * Growth is lazy (gclock_tile_grow settles whole days from water_day), so each tile is settled to the day that just ended, worked, then watered FOR that day.
 */
require_once __DIR__ . '/pal_jobs.php';
require_once __DIR__ . '/trade.php';   // notify()

const PCREW_ROLES = [   // key => [icon, label, what it does, open?]
    'water'   => ['💧', 'Water', 'Waters every dry bed so it grows.', true],
    'weed'    => ['🌿', 'Weed', 'Pulls weeds from no-till beds.', true],
    'pests'   => ['🐛', 'Pests', 'Picks pests off the beds.', true],
    'harvest' => ['🧺', 'Harvest', 'Picks every ripe crop into your satchel.', true],
    'plant'   => ['🌰', 'Plant', 'Replants emptied beds. Coming soon.', false],
];
const PCREW_NIGHTS = [1, 3, 7];
const PCREW_XP_PCT = 40;      // share of the old Gardening XP a pal earns from crew work
const PCREW_XP_DAILY = 12;    // most Gardening XP one pal earns in one night

/** Make sure the tables exist (an update that has not had "Upgrade database" pressed yet). Safe to call often. */
function pcrew_boot(): void
{
    static $ok = false;
    if ($ok) return;
    try {
        q('SELECT id FROM garden_pal_slots LIMIT 1');
        q('SELECT id FROM garden_pal_rest LIMIT 1');
        q('SELECT id FROM sleep_report LIMIT 1');
    } catch (Throwable $e) {
        global $CONFIG;
        db_migrate(db(), (string)$CONFIG['db']['driver']);
    }
    $ok = true;
}

function pcrew_open(array $u): bool
{
    return function_exists('ppal_open') && ppal_open() && !is_guest($u) && pj_open($u) && gclock_on();
}

/** The slots of a garden by role. */
function pcrew_slots(int $plotId): array
{
    pcrew_boot();
    $out = [];
    foreach (q('SELECT * FROM garden_pal_slots WHERE plot_id = ?', [$plotId])->fetchAll() as $r) $out[(string)$r['role']] = $r;
    return $out;
}

function pcrew_count(int $uid): int
{
    try { pcrew_boot(); return (int)q_val('SELECT COUNT(*) FROM garden_pal_slots WHERE user_id = ?', [$uid]); } catch (Throwable $e) { return 0; }
}

/** Game day the pal is free again (0 = not resting). */
function pcrew_rest_until(int $uid, string $palUid): int
{
    pcrew_boot();
    return (int)q_val('SELECT until_day FROM garden_pal_rest WHERE user_id = ? AND pal_uid = ?', [$uid, $palUid]);
}

function pcrew_is_resting(int $uid, string $palUid, int $today): bool
{
    return pcrew_rest_until($uid, $palUid) > $today;
}

function pcrew_send_home(int $uid, string $palUid, int $today): void
{
    q("UPDATE ppal_found SET status = 'home' WHERE user_id = ? AND pal_uid = ? AND status = 'crew'", [$uid, $palUid]);
    $until = $today + 1;
    if (q('UPDATE garden_pal_rest SET until_day = ? WHERE user_id = ? AND pal_uid = ?', [$until, $uid, $palUid])->rowCount() < 1) {
        try { db_insert('garden_pal_rest', ['user_id' => $uid, 'pal_uid' => $palUid, 'until_day' => $until]); } catch (Throwable $e) {}
    }
}

/** Put a pal in a slot. Returns [ok, message]. */
function pcrew_assign(array $u, int $plotId, string $role, string $palUid, string $mode, int $nights, bool $unequip = false): array
{
    $uid = (int)$u['id'];
    pcrew_boot();
    if (!pcrew_open($u)) return [false, 'Garden crews open with pal jobs (gnome level ' . pj_min_level() . ').'];
    if (!isset(PCREW_ROLES[$role]) || !PCREW_ROLES[$role][3]) return [false, 'That job is not open yet.'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid])) return [false, 'That is not your garden.'];
    if ($mode !== 'full' && !in_array($nights, PCREW_NIGHTS, true)) return [false, 'Pick 1, 3 or 7 days, or full time.'];
    $today = (int)$u['game_day'];
    $p = pj_pal($uid, $palUid);
    if (!$p) return [false, 'You have not met that pal.'];
    if (pcrew_is_resting($uid, $palUid, $today)) return [false, $p['name'] . ' is resting at home until you sleep.'];
    if ($p['status'] !== 'home') return [false, $p['name'] . ' is already out.'];
    if ($p['active'] && !$unequip) return [false, $p['name'] . ' is on your party. Tick "Take off my party" to send them out instead.'];
    if (q_val('SELECT 1 FROM garden_pal_slots WHERE plot_id = ? AND role = ?', [$plotId, $role])) return [false, 'That slot already has a pal.'];
    if (!pj_claim_pal($uid, $palUid, 'crew')) return [false, $p['name'] . ' is already out.'];
    try {
        db_insert('garden_pal_slots', ['plot_id' => $plotId, 'user_id' => $uid, 'role' => $role, 'pal_uid' => $palUid, 'mode' => $mode === 'full' ? 'full' : 'timed',
            'nights' => $mode === 'full' ? 0 : $nights, 'done' => 0, 'start_day' => $today, 'created_at' => now()]);
    } catch (Throwable $e) {
        q("UPDATE ppal_found SET status = 'home' WHERE user_id = ? AND pal_uid = ?", [$uid, $palUid]);
        return [false, 'That slot already has a pal.'];
    }
    $len = $mode === 'full' ? 'full time' : $nights . ' sleep' . ($nights > 1 ? 's' : '');
    return [true, $p['name'] . ' takes the ' . strtolower(PCREW_ROLES[$role][1]) . ' job (' . $len . '). They start working when you sleep.'];
}

/** Call a pal home early. It rests until the next sleep. */
function pcrew_recall(array $u, int $plotId, string $role): array
{
    $uid = (int)$u['id'];
    pcrew_boot();
    $s = q_one('SELECT * FROM garden_pal_slots WHERE plot_id = ? AND user_id = ? AND role = ?', [$plotId, $uid, $role]);
    if (!$s) return [false, 'Nobody is on that job.'];
    q('DELETE FROM garden_pal_slots WHERE id = ?', [$s['id']]);
    pcrew_send_home($uid, (string)$s['pal_uid'], (int)$u['game_day']);
    $p = pj_pal($uid, (string)$s['pal_uid']);
    return [true, ($p['name'] ?? 'Your pal') . ' comes home to rest until you sleep.'];
}

/** The night pass for one gnome, called from game_new_day() after the day has moved on. Never throws. */
function pcrew_night(int $uid): void
{
    try {
        pcrew_boot();
        $slots = q('SELECT * FROM garden_pal_slots WHERE user_id = ? ORDER BY id', [$uid])->fetchAll();
        $owner = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
        if (!$owner) return;
        $D = (int)$owner['game_day'];
        $report = [];
        $byPlot = [];
        foreach ($slots as $s) $byPlot[(int)$s['plot_id']][(string)$s['role']] = $s;
        foreach ($byPlot as $plotId => $roles) {
            $plot = q_one('SELECT * FROM plots WHERE id = ?', [$plotId]);
            if (!$plot) continue;
            $did = pcrew_work_plot($owner, $plot, $roles, $D);
            foreach ($roles as $role => $s) {
                $pal = pj_pal($uid, (string)$s['pal_uid']);
                $name = $pal['name'] ?? 'A pal';
                $n = $did[$role] ?? 0;
                $first = (int)$s['start_day'] >= $D;   // assigned today before this sleep ran: starts tonight, counted as night 1
                $doneNow = (int)$s['done'] + 1;
                $ended = $s['mode'] === 'timed' && $doneNow >= (int)$s['nights'];
                $xp = $pal && $n > 0 ? min(PCREW_XP_DAILY, (int)ceil($n * PCREW_XP_PCT / 100)) : 0;
                if ($xp > 0) pj_add_xp($uid, (string)$pal['key'], $xp, 0);
                $report[] = ['plot' => (string)($plot['garden_name'] ?: 'Garden'), 'plot_id' => $plotId, 'role' => $role, 'pal' => $name, 'n' => $n, 'text' => (string)($did[$role . '_text'] ?? ''),
                             'mode' => (string)$s['mode'], 'night' => $doneNow, 'nights' => (int)$s['nights'], 'ended' => $ended, 'warn' => (string)($did[$role . '_warn'] ?? '')];
                if ($ended) {
                    q('DELETE FROM garden_pal_slots WHERE id = ?', [$s['id']]);
                    pcrew_send_home($uid, (string)$s['pal_uid'], $D);
                } else {
                    q('UPDATE garden_pal_slots SET done = ?, last_day = ? WHERE id = ?', [$doneNow, $D, $s['id']]);
                }
            }
        }
        if ($report) {
            pcrew_save_report($uid, $D, ['crew' => $report]);
            $bits = [];
            foreach ($report as $r) if ($r['n'] > 0) $bits[] = $r['text'];
            if (function_exists('notify')) notify($uid, '🧩 Your pals worked the garden: ' . ($bits ? implode(' · ', $bits) : 'nothing needed doing') . '.');
        }
    } catch (Throwable $e) {
        error_log('pcrew_night: ' . $e->getMessage());
        if (db()->inTransaction()) db()->rollBack();
    }
}

/** The tile work of one garden, in order. Returns [role => count, role_text => words]. */
function pcrew_work_plot(array $owner, array $plot, array $roles, int $D): array
{
    $uid = (int)$owner['id'];
    $out = ['water' => 0, 'weed' => 0, 'pests' => 0, 'harvest' => 0];
    $names = [];
    foreach ($roles as $role => $s) $names[$role] = (string)(pj_pal($uid, (string)$s['pal_uid'])['name'] ?? 'Your pal');
    $plants = [];
    foreach (q('SELECT * FROM plot_tiles WHERE plot_id = ? ORDER BY y, x', [$plot['id']])->fetchAll() as $raw) {
        $p = null;
        if ($raw['plant_id']) { $pid = (int)$raw['plant_id']; $p = $plants[$pid] ??= q_one('SELECT * FROM plants WHERE id = ?', [$pid]); }
        $t = annotate_tile($raw, $p);
        if ($p) {
            $t = gclock_tile_grow($t, $p, $D - 1);   // settle every finished day up to the day before the one that just ended
            $t = array_merge($t, ['grow_day' => $D - 1]);
        }
        $touched = false;
        if (isset($roles['pests']) && !empty($t['pest'])) { q('UPDATE plot_tiles SET pest = NULL, pest_at = NULL WHERE id = ?', [$t['id']]); $t['pest'] = null; $out['pests']++; }
        if (isset($roles['weed']) && ($t['method'] ?? '') === 'notill' && (int)$t['weeds'] > 0) { $t['weeds'] = 0; $out['weed']++; $touched = true; }
        if ($p || $touched) {
            $keep = $t;
            $r2 = $raw;
            tile_write_guarded($r2, fn() => save_growth($keep));   // a lost race just skips this square tonight
        }
        if ($p && $p['kind'] !== 'cover' && isset($roles['harvest']) && tile_info($t, $p)['ready']) {
            db()->beginTransaction();
            try {
                do_harvest($owner, $t, $p, $names['harvest'], 0, true);
                db()->commit();
                $out['harvest']++;
            } catch (Throwable $e) {
                if (db()->inTransaction()) db()->rollBack();
            }
            $fresh = q_one('SELECT * FROM plot_tiles WHERE id = ?', [$t['id']]);
            if (!$fresh || !$fresh['plant_id']) continue;   // picked clean: nothing left to water
        }
        if ($p && isset($roles['water'])) {
            $fresh = q_one('SELECT * FROM plot_tiles WHERE id = ?', [$t['id']]);
            if ($fresh && $fresh['plant_id'] && (string)($fresh['water_day'] ?? '') !== (string)($D - 1)) {
                $fx = gfx_on() ? garden_day_fx(annotate_tile($fresh, $p), $p, hollow_date_add(hollow_season_epoch(), $D - 1)) : ['wet' => false];
                if (!empty($fx['wet'])) continue;   // rain did it
                q('UPDATE plot_tiles SET water_day = ?, last_watered = ? WHERE id = ?', [$D - 1, now(), $t['id']]);
                $out['water']++;
            }
        }
    }
    $out['water_text'] = $names['water'] ?? ''; $texts = [];
    if (isset($roles['water'])) $texts['water'] = $names['water'] . ' watered ' . $out['water'] . ' bed' . ($out['water'] === 1 ? '' : 's');
    if (isset($roles['weed'])) $texts['weed'] = $names['weed'] . ' weeded ' . $out['weed'] . ' bed' . ($out['weed'] === 1 ? '' : 's');
    if (isset($roles['pests'])) $texts['pests'] = $names['pests'] . ' cleared pests from ' . $out['pests'] . ' bed' . ($out['pests'] === 1 ? '' : 's');
    if (isset($roles['harvest'])) $texts['harvest'] = $names['harvest'] . ' picked ' . $out['harvest'] . ' crop' . ($out['harvest'] === 1 ? '' : 's');
    foreach ($texts as $k => $v) $out[$k . '_text'] = $v;
    return $out;
}

function pcrew_save_report(int $uid, int $day, array $data): void
{
    pcrew_boot();
    $cur = q_one('SELECT * FROM sleep_report WHERE user_id = ? AND game_day = ?', [$uid, $day]);
    if ($cur) {
        $body = array_merge(json_decode((string)$cur['body'], true) ?: [], $data);
        q('UPDATE sleep_report SET body = ? WHERE id = ?', [json_encode($body), $cur['id']]);
    } else {
        db_insert('sleep_report', ['user_id' => $uid, 'game_day' => $day, 'body' => json_encode($data), 'created_at' => now()]);
        q('DELETE FROM sleep_report WHERE user_id = ? AND game_day <= ?', [$uid, $day - 3]);   // the last 3 reports are kept
    }
}

/** The latest sleep report [game_day, data] or null. */
function pcrew_latest_report(int $uid): ?array
{
    try {
        pcrew_boot();
        $r = q_one('SELECT * FROM sleep_report WHERE user_id = ? ORDER BY game_day DESC LIMIT 1', [$uid]);
        return $r ? [(int)$r['game_day'], json_decode((string)$r['body'], true) ?: []] : null;
    } catch (Throwable $e) { return null; }
}

/**
 * Hired helpers retire (Josh, 2026-11-10): every active contract ends, unused whole days are refunded, the player is told once. Runs once per site (setting flag).
 */
function pcrew_retire_helpers(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    try {
        if (setting('crew_helpers_retired') === '1') return;
        foreach (q('SELECT g.*, h.name, h.wage FROM garden_hires g JOIN helpers h ON h.id = g.helper_id WHERE g.active = 1')->fetchAll() as $hire) {
            $left = max(0, intdiv(ts($hire['ends_at']) - gclock_hire_now($hire), 86400));
            $refund = min((int)$hire['paid'], $left * (int)$hire['wage']);
            if (q('UPDATE garden_hires SET active = 0 WHERE id = ? AND active = 1', [$hire['id']])->rowCount() !== 1) continue;
            if ($refund > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$refund, $hire['user_id']]);
            if (function_exists('notify')) notify((int)$hire['user_id'], '🧰 ' . $hire['name'] . ' has gone home: your pals do the garden work now.' . ($refund > 0 ? ' Unused wages refunded: ' . money($refund) . '.' : ''));
        }
        set_setting('crew_helpers_retired', '1');
    } catch (Throwable $e) { error_log('pcrew_retire_helpers: ' . $e->getMessage()); }
}
