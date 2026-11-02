<?php
declare(strict_types=1);
/**
 * v2.3.0: Pal jobs. A found Puzzle Pal can be sent to tend a garden, on a gathering trip, or to re-run a delve the gnome has already cleared.
 * Names start pj_ (ppal_ is the pal collection itself). Everything is behind ppal_open() + the setting pj_open + gnome level pj_min_level (default 10).
 *
 *  - Every found pal has its own hash (ppal_found.pal_uid, 16 hex): jobs and forms use it, never the row id.
 *  - Two levels per pal: Gardening (g_xp) and Adventuring (a_xp), 1 to 10, from pj_level().
 *  - Garden duty: lazy, like hired help (load_plot replays the visits). Does not use a Tool Shed slot.
 *  - Trips and delve re-runs are rolled once, at the start, from a stored seed; the job row holds the result and when it is ready. Collect grants it once.
 *  - A pal at 0 HP goes home at once (the job ends early with what it had). Healing Potions packed for the job are drunk when HP is low; the rest come back.
 *  - A duplicate find gives the pal XP (ppal_claim). A pal that is taken along (equipped) earns a little XP of both kinds each hour.
 */
require_once __DIR__ . '/puzzle_pals.php';
require_once __DIR__ . '/gathering.php';   // gather_candidates, GATHER_RARITY, tool_tier, LANDSCAPES
require_once __DIR__ . '/landmarks.php';   // landmark_day, DELVE_ROOMS
require_once __DIR__ . '/alchemy.php';     // the other potions: healing tiers, Lucky Draught

const PJ_MAX_LEVEL = 10;
const PJ_XP = [0, 30, 80, 150, 250, 380, 540, 730, 950, 1200];   // XP needed for level 1..10
const PJ_PASSIVE_TICK = 600;   // seconds between a tending pal's checks of its pot (real time, caught up lazily on page load)
const PJ_PASSIVE_MAX = 60;     // checks caught up in one load (an 8 h shift is 48)
const PJ_POTION = 'healing-potion';
const PJ_POTION_HEAL = 12;
const PJ_TRIP_HOURS = [1, 3, 8];
const PJ_GARDEN_DAYS = [1, 3, 7];
const PJ_TOOLS = ['forage', 'pick', 'net', 'bucket', 'axe', 'rod'];
const PJ_EQUIP_XP_MAX = 24; // hours of equipped XP that can pile up before it is settled

// ---------------- gates + settings ----------------

function pj_min_level(): int
{
    $v = setting('pj_min_level');
    return $v === '' ? 10 : max(1, min(100, (int)$v));
}

/** Can this gnome use pal jobs? Pals open, setting on, level reached, not a guest. Admins always. */
function pj_open(?array $u = null): bool
{
    if (!ppal_open()) return false;
    if (is_admin()) return true;
    $u ??= current_user();
    if (!$u || is_guest($u) || setting('pj_open') === '0') return false;
    return (int)($u['level'] ?? 0) >= pj_min_level();
}

function pj_max_away(): int { $v = setting('pj_max_away'); return $v === '' ? 3 : max(1, min(10, (int)$v)); }
function pj_stations_per_day(): int { $v = setting('pj_stations_per_day'); return $v === '' ? 4 : max(1, min(30, (int)$v)); }   // v2.4.61: station shifts have their own daily cap
function pj_runs_per_day(): int { $v = setting('pj_runs_per_day'); return $v === '' ? 6 : max(1, min(50, (int)$v)); }

// ---------------- levels, hp, ids ----------------

function pj_level(int $xp): int
{
    $l = 1;
    foreach (PJ_XP as $i => $need) if ($xp >= $need) $l = $i + 1;
    return min(PJ_MAX_LEVEL, $l);
}

/** XP still needed for the next level, or 0 at the top. */
function pj_xp_to_next(int $xp): int
{
    $l = pj_level($xp);
    return $l >= PJ_MAX_LEVEL ? 0 : PJ_XP[$l] - $xp;
}

function pj_max_hp(array $pal, int $aLevel): int
{
    return 12 + 4 * (int)$pal['hardiness'] + 3 * ($aLevel - 1);
}

/** v2.3.3: how a pal's level scales its rare finds (trips and delve chests): 0.36 at level 1, 1.0 at 5 (the old gate), 1.4 at 10. */
function pj_rare_mult(int $lvl): float
{
    return min(1.4, 0.2 + 0.16 * max(1, $lvl));
}

/** v2.3.3: below this Adventuring level a delve re-run is marked risky on the send form (not blocked). */
const PJ_DELVE_SAFE = 5;

/** A fresh 16-hex id for a pal. */
function pj_new_uid(): string { return bin2hex(random_bytes(8)); }

/** Give every found pal of this gnome its hash (older rows have none). Cheap when all have one. */
function pj_backfill(int $uid): void
{
    foreach (q("SELECT id FROM ppal_found WHERE user_id = ? AND (pal_uid IS NULL OR pal_uid = '')", [$uid])->fetchAll(PDO::FETCH_COLUMN) as $id) {
        q("UPDATE ppal_found SET pal_uid = ? WHERE id = ? AND (pal_uid IS NULL OR pal_uid = '')", [pj_new_uid(), $id]);
    }
}

/** XP for one pal (by key), added to both levels or one. */
function pj_add_xp(int $uid, string $key, int $g, int $a): void
{
    if ($g <= 0 && $a <= 0) return;
    q('UPDATE ppal_found SET g_xp = g_xp + ?, a_xp = a_xp + ? WHERE user_id = ? AND pal_key = ?', [max(0, $g), max(0, $a), $uid, $key]);
}

/** v2.4.61: Crafting XP for one pal (station shifts). */
function pj_add_c_xp(int $uid, string $key, int $c): void
{
    if ($c <= 0) return;
    q('UPDATE ppal_found SET c_xp = c_xp + ? WHERE user_id = ? AND pal_key = ?', [$c, $uid, $key]);
}

/** Equipped pals earn 1 XP of each kind per hour at home. Settled when the jobs page loads or a pal is sent. */
function pj_settle_equip(int $uid): void
{
    foreach (q("SELECT id, eq_since FROM ppal_found WHERE user_id = ? AND active = 1 AND status = 'home'", [$uid])->fetchAll() as $r) {
        if (!$r['eq_since']) { q('UPDATE ppal_found SET eq_since = ? WHERE id = ?', [now(), $r['id']]); continue; }
        $h = min(PJ_EQUIP_XP_MAX, intdiv(time() - ts($r['eq_since']), 3600));
        if ($h < 1) continue;
        q('UPDATE ppal_found SET g_xp = g_xp + ?, a_xp = a_xp + ?, eq_since = ? WHERE id = ? AND eq_since = ?',
            [$h, $h, gmdate('Y-m-d H:i:s', ts($r['eq_since']) + $h * 3600), $r['id'], $r['eq_since']]);
    }
}

/**
 * This gnome's found pals with their job state: list of rows keyed by pal_uid, each ['uid','key','pal','pic','name','g','a','gxp','axp','hp','max','status','active'].
 * HP regrows at home: 1 per 6 minutes. A pal whose roster row is gone is left out.
 */
function pj_pals(int $uid): array
{
    if (!ppal_ensure()) return [];
    pj_backfill($uid);
    $out = [];
    foreach (q('SELECT * FROM ppal_found WHERE user_id = ? ORDER BY found_at, id', [$uid])->fetchAll() as $r) {
        $pic = ppal_pic((int)$r['pic_id']);
        $pal = $pic ? ppal_find_pal($pic, (string)$r['pal_key']) : null;
        if (!$pal) continue;
        $a = pj_level((int)$r['a_xp']);
        $max = pj_max_hp($pal, $a);
        $hp = (int)$r['hp'] < 0 ? $max : (int)$r['hp'];
        if ($r['status'] === 'home' && $hp < $max && $r['hp_at']) $hp = min($max, $hp + intdiv(time() - ts($r['hp_at']), 360));
        $out[(string)$r['pal_uid']] = ['uid' => (string)$r['pal_uid'], 'key' => (string)$r['pal_key'], 'pal' => $pal, 'pic' => $pic, 'name' => $pal['name'],
            'g' => pj_level((int)$r['g_xp']), 'a' => $a, 'gxp' => (int)$r['g_xp'], 'axp' => (int)$r['a_xp'], 'c' => pj_level((int)($r['c_xp'] ?? 0)), 'cxp' => (int)($r['c_xp'] ?? 0), 'hp' => max(0, $hp), 'max' => $max,
            'status' => (string)$r['status'], 'active' => (int)$r['active'] === 1];
    }
    return $out;
}

/** One pal by its hash for this gnome, or null. */
function pj_pal(int $uid, string $palUid): ?array
{
    if (!preg_match('/^[0-9a-f]{16}$/', $palUid)) return null;
    return pj_pals($uid)[$palUid] ?? null;
}

// ---------------- potions ----------------

function pj_potion_id(): int
{
    static $id = null;
    return $id ??= item_id_by_slug(PJ_POTION);
}

function pj_potion_count(int $uid): int
{
    $id = pj_potion_id();
    return $id ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]) : 0;
}

/** Make the Healing Potion item, its recipe (data/crafts.txt) and a shelf in Twigg's shop. Adds only; safe to repeat. */
function pj_ensure_content(): void
{
    $id = item_id_by_slug(PJ_POTION);
    if (!$id) {
        $id = db_insert('items', ['name' => 'Healing Potion', 'slug' => PJ_POTION, 'category' => 'supply', 'rarity' => 10, 'base_price' => 40,
            'description' => 'A sweet green tonic. Pack some for a pal going out; it drinks one when it is hurt (+' . PJ_POTION_HEAL . ' HP). Or give it to a pal at home.',
            'edible' => 0, 'effects' => null, 'tradable' => 1]);
    }
    $shop = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
    if ($shop && !q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, $id])) {
        db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => $id, 'price_min' => 45, 'price_max' => 60,
            'max_stock' => 12, 'restock_chance' => 60, 'current_stock' => 0, 'current_price' => 50]);
    }
    alchemy_ensure_items();   // the Alchemy Table's other potions (their recipes are in data/crafts.txt)
}

// ---------------- the random roll (seeded, so a job's result is fixed when it starts) ----------------

/** A tiny seeded generator: pj_rng('seed')(10) is 0..9. */
function pj_rng(string $seed): Closure
{
    $s = crc32($seed) ?: 1;
    return function (int $max) use (&$s): int {
        $s = ($s * 1103515245 + 12345) & 0x7fffffff;
        return $max <= 1 ? 0 : (int)(($s >> 8) % $max);
    };
}

// ---------------- jobs: shared ----------------

/** Jobs still out (active or ready to collect). */
function pj_jobs(int $uid, bool $openOnly = true): array
{
    if (!ppal_ensure()) return [];
    return q('SELECT * FROM ppal_jobs WHERE user_id = ?' . ($openOnly ? " AND state IN ('active','ready')" : '') . ' ORDER BY id DESC LIMIT 60', [$uid])->fetchAll();
}

function pj_runs_today(int $uid): int
{
    return (int)q_val('SELECT COUNT(*) FROM ppal_jobs WHERE user_id = ? AND kind IN (\'trip\',\'delve\') AND day = ?', [$uid, landmark_day()]);
}

/**
 * Turn finished jobs into ready ones, send their pals home, and end garden stays whose time is up (the garden itself closes them when it loads, this covers a gnome who
 * never opens that garden). Call at the top of the jobs page and before sending anything.
 */
function pj_settle(int $uid): void
{
    if (!ppal_ensure()) return;
    pj_settle_equip($uid);
    foreach (q("SELECT * FROM ppal_jobs WHERE user_id = ? AND state = 'active' AND kind = 'station' AND tool = 'passive'", [$uid])->fetchAll() as $j) pj_passive_tick($uid, $j);
    foreach (q("SELECT * FROM ppal_jobs WHERE user_id = ? AND state = 'active' AND ends_at <= ?", [$uid, now()])->fetchAll() as $j) {
        if ($j['kind'] === 'garden') { pj_garden_close($j); continue; }
        if (q("UPDATE ppal_jobs SET state = 'ready' WHERE id = ? AND state = 'active'", [$j['id']])->rowCount() !== 1) continue;
        if ($j['kind'] === 'station' && $j['tool'] === 'passive') pj_passive_finish($uid, (int)$j['id']);
        $r = json_decode((string)$j['result'], true) ?: [];
        q("UPDATE ppal_found SET status = 'home', hp = ?, hp_at = ? WHERE user_id = ? AND pal_uid = ?", [max(0, (int)($r['hp'] ?? 0)), now(), $uid, $j['pal_uid']]);
    }
}

/** Send a pal out: claim it (home to away) in one conditional UPDATE, so two tabs cannot send it twice. */
function pj_claim_pal(int $uid, string $palUid, string $status): bool
{
    return q("UPDATE ppal_found SET status = ?, active = 0, eq_since = NULL WHERE user_id = ? AND pal_uid = ? AND status = 'home'", [$status, $uid, $palUid])->rowCount() === 1;
}

/** Common checks for sending. Returns [pal row or null, error text]. */
function pj_can_send(array $u, string $palUid, bool $unequip = false): array
{
    $uid = (int)$u['id'];
    if (!pj_open($u)) return [null, 'Pal jobs open at gnome level ' . pj_min_level() . '.'];
    pj_settle($uid);
    $p = pj_pal($uid, $palUid);
    if (!$p) return [null, 'You have not met that pal.'];
    if ($p['status'] !== 'home') return [null, $p['name'] . ' is already out.'];
    if ($p['hp'] < 1) return [null, $p['name'] . ' needs to rest first.'];
    if ($p['active'] && !$unequip) return [null, $p['name'] . ' is on your party. Tick "Take off my party" to send them out instead.'];
    $away = (int)q_val("SELECT COUNT(*) FROM ppal_jobs WHERE user_id = ? AND state IN ('active','ready')", [$uid]);
    if ($away >= pj_max_away()) return [null, 'That is as many jobs at once as your pals can manage (' . pj_max_away() . '). Collect or wait.'];
    return [$p, ''];
}

/** Take n potions out of the satchel for a job. False = not enough. */
function pj_take_potions(int $uid, int $n): bool
{
    if ($n <= 0) return true;
    $id = pj_potion_id();
    return $id > 0 && give_item($uid, $id, -$n);
}

// ---------------- garden duty ----------------

/** v2.3.3: every pal waters, weeds and harvests from Gardening 1. Level shows in pj_garden_step (more visits) and pj_garden_extra_pct (extra crops). */
function pj_garden_skills(int $g = 1): array
{
    return ['water', 'weed', 'harvest'];
}

/**
 * v2.3.3: a pal and hired help (garden_hires, the Tool Shed helpers) work TOGETHER. A pal can always be sent; it keeps all three tasks.
 * load_plot runs the hired helpers first, then the pal on whatever is still undone at its own visit times (a square still dry, weeds still there,
 * a crop still ripe). Each action happens once: helper_water_tile only waters a dry square, a bed is weeded once a load, a harvested square is skipped.
 * The pal earns XP only for what it did itself. Other helpers (a friend watering, a player job, a watering event) also act only where a square needs it.
 */
function pj_garden_has_help(int $plotId): bool
{
    require_once __DIR__ . '/hired_help.php';
    return (bool)current_hires($plotId);
}

/** "Waters, weeds and harvests" + " after your hired help" when the garden has some. */
function pj_garden_task_text(int $plotId): string
{
    return 'Waters, weeds and harvests' . (pj_garden_has_help($plotId) ? ', working after your hired help' : '');
}

/** v2.3.3: chance (%) that a pal's harvest of a square brings one extra crop: 0 at Gardening 1, +4 a level, 36 at 10. */
function pj_garden_extra_pct(int $g): int
{
    return 4 * (max(1, min(PJ_MAX_LEVEL, $g)) - 1);
}

/** load_plot calls this after a pal's harvest of one square: maybe one extra crop for the owner. Returns how many were added (0 or 1). */
function pj_garden_extra(int $ownerId, array $plant, array $hire): int
{
    if (empty($hire['pj_job']) || empty($plant['produce_item_id']) || random_int(1, 100) > (int)($hire['pj_extra'] ?? 0)) return 0;
    give_item($ownerId, (int)$plant['produce_item_id'], 1);
    return 1;
}

/** Hours between a pal's visits: the hired-help setting, 1 less at Gardening 4 and again at 8. */
function pj_garden_step(int $g): int
{
    return max(1, (int)setting('helper_visit_hours') - intdiv($g, 4));
}

function pj_garden_send(array $u, string $palUid, int $plotId, int $days, bool $unequip = false): array
{
    $uid = (int)$u['id'];
    if (!in_array($days, PJ_GARDEN_DAYS, true)) return [false, 'Pick 1, 3 or 7 days.'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid])) return [false, 'That is not your garden.'];
    [$p, $err] = pj_can_send($u, $palUid, $unequip);
    if (!$p) return [false, $err];
    if (q_val("SELECT 1 FROM ppal_jobs WHERE plot_id = ? AND kind = 'garden' AND state = 'active'", [$plotId])) return [false, 'A pal is already tending that garden.'];
    if (!pj_claim_pal($uid, $palUid, 'garden')) return [false, $p['name'] . ' is already out.'];
    db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $palUid, 'kind' => 'garden', 'target' => (string)$plotId, 'plot_id' => $plotId, 'day' => landmark_day(),
        'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() + $days * 86400), 'last_tick' => now(), 'potions' => 0, 'state' => 'active', 'result' => null]);
    return [true, $p['name'] . ' heads to the garden for ' . $days . ' day' . ($days > 1 ? 's' : '') . '. ' . pj_garden_task_text($plotId) . '.'];
}

/** Pseudo hire rows for load_plot (same fields hire_visits and helper_finish read), one per pal tending this garden. */
function pj_garden_hires(int $plotId): array
{
    if (!ppal_ensure() || !ppal_open()) return [];
    $out = [];
    try {
        foreach (q("SELECT * FROM ppal_jobs WHERE plot_id = ? AND kind = 'garden' AND state = 'active'", [$plotId])->fetchAll() as $j) {
            $p = pj_pal((int)$j['user_id'], (string)$j['pal_uid']);
            if (!$p) continue;
            $out[] = ['id' => 0, 'pj_job' => (int)$j['id'], 'user_id' => (int)$j['user_id'], 'last_visit' => $j['last_tick'], 'ends_at' => $j['ends_at'],
                'name' => $p['name'], 'icon' => '🧩', 'skills' => implode(',', pj_garden_skills($p['g'])), 'step_hours' => pj_garden_step($p['g']), 'pj_extra' => pj_garden_extra_pct($p['g']),
                'pj_key' => $p['key'], 'wage' => 0, 'paid' => 0];
        }
    } catch (Throwable $e) { error_log('pj_garden_hires: ' . $e->getMessage()); }
    return $out;
}

/** load_plot calls this in place of helper_finish for a pal: record the visits, give the pal XP, close the stay when it is over. Returns the "while you were out" line. */
function pj_garden_finish(array $hire, array $visits, array $stats): ?string
{
    $job = q_one('SELECT * FROM ppal_jobs WHERE id = ?', [$hire['pj_job']]);
    if (!$job || $job['state'] !== 'active') return null;
    $last = $visits ? gmdate('Y-m-d H:i:s', end($visits)) : $job['last_tick'];
    $ended = ts($hire['ends_at']) <= time();
    $n = (int)$stats['water'] + (int)$stats['weed'] + 2 * (int)$stats['harvest'];
    q('UPDATE ppal_jobs SET last_tick = ?, tasks = tasks + ? WHERE id = ?', [$last, $n, $job['id']]);
    if ($n > 0) pj_add_xp((int)$job['user_id'], (string)$hire['pj_key'], $n, 0);
    if ($ended) pj_garden_close($job);
    $did = [];
    if ($stats['water']) $did[] = 'watered ' . $stats['water'] . ' time' . ($stats['water'] > 1 ? 's' : '');
    if ($stats['weed']) $did[] = 'weeded ' . $stats['weed'] . ' bed' . ($stats['weed'] > 1 ? 's' : '');
    if ($stats['harvest']) $did[] = 'harvested ' . $stats['harvest'] . ' crop' . ($stats['harvest'] > 1 ? 's' : '') . (!empty($stats['extra']) ? ' (+' . (int)$stats['extra'] . ' extra)' : '');
    if (!$did && !$ended) return null;
    return '🧩 ' . $hire['name'] . ($did ? ' ' . implode(', ', $did) . ' while you were out.' : '') . ($ended ? ' Their stay is over and they have gone home.' : '');
}

/** End a garden stay: the job is done and the pal goes home. */
function pj_garden_close(array $job): void
{
    if (q("UPDATE ppal_jobs SET state = 'done' WHERE id = ? AND state = 'active'", [$job['id']])->rowCount() === 1) {
        q("UPDATE ppal_found SET status = 'home' WHERE user_id = ? AND pal_uid = ?", [$job['user_id'], $job['pal_uid']]);
    }
}

/** Fraction of its time a job has run (0..1). */
function pj_job_frac(array $j): float
{
    $t0 = pj_ts((string)$j['started_at']); $t1 = pj_ts((string)$j['ends_at']);
    return max(0.0, min(1.0, (time() - $t0) / max(1, $t1 - $t0)));
}

/** Below this share of its time a trip, delve or old shift cannot be called home (the scaled haul would be nothing). */
const PJ_RECALL_MIN = 0.10;

/**
 * What a recall keeps of a loot job's result: coins, items, makes and XP scale by (time done) x 50%. Rounds scale by time done. Potions drunk scale
 * by time done (the rest come back). Items that round to 0 drop out.
 */
function pj_recall_scale(array $r, float $frac, int $potions): array
{
    $keep = $frac * 0.5;
    if (!empty($r['coins'])) $r['coins'] = (int)floor((int)$r['coins'] * $keep);
    $items = [];
    foreach ($r['items'] ?? [] as [$iid, $qty, $name]) if (($q = (int)floor((int)$qty * $keep)) > 0) $items[] = [$iid, $q, $name];
    $r['items'] = $items;
    foreach (['makes', 'xp_base'] as $k) if (isset($r[$k])) $r[$k] = (int)floor((int)$r[$k] * $keep);
    $r['rounds'] = (int)floor((int)($r['rounds'] ?? 0) * $frac);
    $used = (int)ceil((int)($r['potions_used'] ?? 0) * $frac);
    $r['potions_used'] = $used; $r['potions_back'] = max(0, $potions - $used);
    $r['recalled'] = true;
    return $r;
}

/** Words for the confirm box: what calling this job home early costs. [can, text]. */
function pj_recall_preview(array $j): array
{
    if ($j['state'] !== 'active') return [false, ''];
    $r = json_decode((string)$j['result'], true) ?: [];
    if ($j['kind'] === 'garden') return [true, 'Your pal comes home now. Nothing is lost.'];
    if (($j['tool'] ?? '') === 'passive') {
        $served = (int)($r['served'] ?? 0);
        return [true, 'Dishes already served (' . $served . ') stay in your satchel. A dish still cooking loses half its dishes (rounded down) and the pot is yours again.'];
    }
    $f = pj_job_frac($j);
    if ($f < PJ_RECALL_MIN) return [false, 'Too early: wait until about ' . (int)(PJ_RECALL_MIN * 100) . '% of the time has passed.'];
    $s = pj_recall_scale($r, $f, (int)$j['potions']);
    $n0 = array_sum(array_map(fn($i) => (int)$i[1], $r['items'] ?? [])); $n1 = array_sum(array_map(fn($i) => (int)$i[1], $s['items']));
    $txt = 'Done ' . (int)round($f * 100) . '% so far; you keep half of that: ' . $n1 . ' of ' . $n0 . ' items' . (!empty($r['coins']) ? ', ' . money((int)$s['coins']) . ' of ' . money((int)$r['coins']) : '') . '.';
    return [true, $txt];
}

/** Call a pal home early. Garden: no loss. Pot: the cook in the pot loses half. Others: half of what the time so far earned. Returns [ok, message]. */
function pj_recall(array $u, int $jobId): array
{
    $uid = (int)$u['id'];
    pj_settle($uid);
    $j = q_one("SELECT * FROM ppal_jobs WHERE id = ? AND user_id = ? AND state = 'active'", [$jobId, $uid]);
    if (!$j) return [false, 'No pal to call home.'];
    $p = pj_pal($uid, (string)$j['pal_uid']); $name = $p['name'] ?? 'Your pal';
    if ($j['kind'] === 'garden') { pj_garden_close($j); return [true, $name . ' comes home from the garden.']; }
    $r = json_decode((string)$j['result'], true) ?: [];
    $passive = $j['kind'] === 'station' && ($j['tool'] ?? '') === 'passive';
    if (!$passive) {
        [$can, $why] = pj_recall_preview($j);
        if (!$can) return [false, $why];
        $r = pj_recall_scale($r, pj_job_frac($j), (int)$j['potions']);
    }
    if (q("UPDATE ppal_jobs SET state = 'ready', ends_at = ?, result = ? WHERE id = ? AND state = 'active'", [now(), json_encode($r), $jobId])->rowCount() !== 1) return [false, 'Already home.'];
    q("UPDATE ppal_found SET status = 'home', hp = ?, hp_at = ? WHERE user_id = ? AND pal_uid = ?", [max(0, (int)($r['hp'] ?? 0)), now(), $uid, $j['pal_uid']]);
    if ($passive) pj_passive_finish($uid, $jobId, true);
    return [true, $name . ' comes home early. Collect to get what they brought.'];
}

// ---------------- gathering trips ----------------

/** The gather tool types this gnome owns, with their tier. */
function pj_tools(int $uid): array
{
    $o = [];
    foreach (PJ_TOOLS as $t) if (($tier = tool_tier($uid, $t)) > 0) $o[$t] = $tier;
    return $o;
}

/**
 * Roll a whole trip now. Returns ['rounds' => done, 'items' => [[item_id, qty, name]...], 'hp' => left, 'potions_used' => n, 'fainted' => bool, 'log' => [lines]].
 * Each round (30 minutes of the trip): a danger roll, then a find roll. Rare finds need Adventuring 5. A hurt pal drinks a potion at 40% HP; 0 HP ends the trip.
 */
function pj_roll_trip(array $p, string $land, string $tool, int $tier, int $hours, int $potions, string $seed, int $luckBonus = 0): array
{
    $rng = pj_rng($seed);
    $pal = $p['pal'];
    $pal['luck'] = (int)($pal['luck'] ?? 0) + max(0, $luckBonus);   // a Lucky Draught packed for the trip
    $a = $p['a'];
    $rounds = $hours * 2;
    $hp = $p['hp'];
    $used = 0;
    $items = [];
    $log = [];
    $cands = array_values(array_filter(gather_candidates($land, $tool), fn($g) => (GATHER_RARITY[$g['rarity']][0] ?? 9) <= $tier));   // v2.3.3: no level gate on rares
    $wt = fn(array $g): int => $g['rarity'] === 'rare' ? max(1, (int)round(GATHER_RARITY['rare'][1] * pj_rare_mult($a))) : GATHER_RARITY[$g['rarity']][1];
    $done = 0;
    $fainted = false;
    for ($r = 1; $r <= $rounds; $r++) {
        $danger = max(8, 34 - 3 * $a - 2 * (int)$pal['nimble'] - (int)$pal['grit'] + 4 * ($tier === 1 ? 1 : 0));
        if ($rng(100) < $danger) {
            $dmg = 2 + $rng(4) + intdiv($rounds, 6);
            $hp -= $dmg;
            $log[] = 'Round ' . $r . ': a scare, -' . $dmg . ' HP.';
            if ($hp <= intdiv($p['max'] * 4, 10) && $hp > 0 && $potions - $used > 0) {
                $used++;
                $hp = min($p['max'], $hp + PJ_POTION_HEAL);
                $log[] = 'Drank a potion.';
            }
            if ($hp <= 0) { $hp = 0; $fainted = true; $done = $r - 1; $log[] = 'Out of HP: heading home.'; break; }
        }
        $done = $r;
        if ($cands && $rng(100) < 50 + 3 * $a + 2 * (int)$pal['luck']) {
            $tot = 0; foreach ($cands as $g) $tot += $wt($g);
            $pick = $rng($tot);
            foreach ($cands as $g) {
                $pick -= $wt($g);
                if ($pick < 0) { $key = (int)$g['item_id']; $items[$key] = [$key, ($items[$key][1] ?? 0) + 1 + ($rng(100) < 5 * (int)$pal['luck'] ? 1 : 0), (string)$g['name']]; break; }
            }
        }
    }
    return ['rounds' => $done, 'items' => array_values($items), 'hp' => $hp, 'potions_used' => $used, 'fainted' => $fainted, 'log' => array_slice($log, 0, 12)];
}

function pj_trip_send(array $u, string $palUid, string $land, string $tool, int $hours, int $potions, bool $unequip = false, bool $luck = false): array
{
    $uid = (int)$u['id'];
    if (!isset(LANDSCAPES[$land])) return [false, 'Pick a place to go.'];
    if (!in_array($hours, PJ_TRIP_HOURS, true)) return [false, 'Pick 1, 3 or 8 hours.'];
    $tier = tool_tier($uid, $tool);
    if (!in_array($tool, PJ_TOOLS, true) || $tier < 1) return [false, 'Equip a gathering tool you own.'];
    $potions = max(0, min(5, $potions));
    [$p, $err] = pj_can_send($u, $palUid, $unequip);
    if (!$p) return [false, $err];
    if (pj_runs_today($uid) >= pj_runs_per_day()) return [false, 'Your pals have done enough trips and delves for today (' . pj_runs_per_day() . ').'];
    if (!gather_candidates($land, $tool)) return [false, 'Nothing for that tool grows there.'];
    $seed = bin2hex(random_bytes(6));
    $luckId = $luck ? alchemy_item_id(ALCHEMY_LUCK) : 0;
    if ($luck && (!$luckId || !give_item($uid, $luckId, -1))) return [false, 'You do not have a Lucky Draught.'];
    if (!pj_take_potions($uid, $potions)) { if ($luck) give_item($uid, $luckId, 1); return [false, 'You do not have ' . $potions . ' Healing Potion' . ($potions === 1 ? '' : 's') . '.']; }
    if (!pj_claim_pal($uid, $palUid, 'trip')) { if ($potions) give_item($uid, pj_potion_id(), $potions); if ($luck) give_item($uid, $luckId, 1); return [false, $p['name'] . ' is already out.']; }
    $res = pj_roll_trip($p, $land, $tool, $tier, $hours, $potions, $seed, $luck ? ALCHEMY_LUCK_PAL : 0);
    $res['potions_back'] = $potions - $res['potions_used'];
    if ($luck) $res['luck'] = ALCHEMY_LUCK_PAL;
    $secs = $res['fainted'] ? max(600, (int)($hours * 3600 * ($res['rounds'] / ($hours * 2)))) : $hours * 3600;
    db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $palUid, 'kind' => 'trip', 'target' => $land, 'plot_id' => null, 'day' => landmark_day(), 'tool' => $tool,
        'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() + $secs), 'last_tick' => now(), 'potions' => $potions, 'state' => 'active', 'result' => json_encode($res)]);
    return [true, $p['name'] . ' heads out to the ' . strtolower(LANDSCAPES[$land][1]) . ' with a ' . (TOOL_TYPES[$tool][0] ?? $tool) . ' tool' . ($potions ? ' and ' . $potions . ' potion' . ($potions > 1 ? 's' : '') : '') . ($luck ? ', sipping a Lucky Draught' : '') . '. Back in ' . pj_ago($secs) . '.'];
}

// ---------------- station shifts (v2.4.61): a pal mans one object of a crafting area ----------------

/** Minutes a pal needs for one make: 60 at Crafting level 1, 24 at level 10 (a gnome makes it at once, so pals are slower). */
function pj_station_minutes(int $c): int { return max(20, 60 - 4 * (max(1, $c) - 1)); }

/** Chance in percent of one extra output per make: 4 per Crafting level above 1 (cap 36). */
function pj_station_extra_pct(int $c): int { return min(36, 4 * (max(1, $c) - 1)); }

/** The scene object [id, label, globs] of an area, or null (only objects with a tag list count). */
function pj_station_object(string $area, string $obj): ?array
{
    require_once __DIR__ . '/craft_map.php';
    foreach (craft_scenes()[$area]['hot'] ?? [] as [$id, $label, , , , , $to]) if ($id === $obj && is_array($to)) return ['id' => $id, 'label' => $label, 'globs' => $to];
    return null;
}

/** Every station (area + object) with its label, for the board: [ 'cooking:stove' => ['Cooking', 'Stove'], ... ]. Pantry is later; Potions have no building so are included. */
function pj_station_list(): array
{
    require_once __DIR__ . '/craft_map.php';
    $out = [];
    foreach (CRAFT_CATEGORIES as $area => [$label]) {
        if ($area === 'pantry') continue;
        foreach (craft_scenes()[$area]['hot'] ?? [] as [$id, $ol, , , , , $to]) if (is_array($to)) $out[$area . ':' . $id] = [$label, $ol];
    }
    return $out;
}

/** Known recipes of an area that an object makes (rows from craft_recipes with 'ings'). */
function pj_station_recipes(int $uid, string $area, array $globs): array
{
    $out = [];
    foreach (craft_recipes($uid, $area) as $r) if ($r['known'] && craft_tag_match($globs, (string)($r['slug'] ?? ''))) $out[(int)$r['id']] = $r;
    return $out;
}

/**
 * Man a station: the pal works for $hours and makes what its object makes (mode 'all') or the chosen known recipes (up to 5), one make per
 * pj_station_minutes(). No energy is spent. Ingredients are taken NOW (one ledger, so recipes that share an item cannot both spend it); the output is
 * fixed now and arrives when the shift is collected. Cooking holds one of your pots. Pantry is not included yet.
 */
function pj_station_send(array $u, string $palUid, string $area, string $obj, string $mode, array $recipeIds, int $hours, bool $unequip = false): array
{
    $uid = (int)$u['id'];
    require_once __DIR__ . '/crafting.php';
    if (!in_array($hours, PJ_TRIP_HOURS, true)) return [false, 'Pick 1, 3 or 8 hours.'];
    if ($area === 'pantry' || !isset(CRAFT_CATEGORIES[$area])) return [false, 'Pals cannot work that area yet.'];
    $o = pj_station_object($area, $obj);
    if (!$o) return [false, 'Pick a station.'];
    $stations = craft_stations($uid);
    if (($stations[$area] ?? 0) === 0) return [false, 'You need the building for that area first.'];
    [$p, $err] = pj_can_send($u, $palUid, $unequip);
    if (!$p) return [false, $err];
    $target = $area . ':' . $obj;
    $passive = $area === 'cooking';   // pals only cook passively, in a pot of their own
    if ($passive && !cook_pots_on()) return [false, 'Pals cook in pots, and pots are switched off.'];
    if (!$passive && q_val("SELECT 1 FROM ppal_jobs WHERE user_id = ? AND kind = 'station' AND target = ? AND state IN ('active','ready')", [$uid, $target])) return [false, 'A pal is already working at the ' . $o['label'] . '.'];
    if (!$passive && (int)q_val("SELECT COUNT(*) FROM ppal_jobs WHERE user_id = ? AND kind = 'station' AND day = ?", [$uid, landmark_day()]) >= pj_stations_per_day()) return [false, 'Your pals have worked enough shifts today (' . pj_stations_per_day() . ').'];
    $all = pj_station_recipes($uid, $area, $o['globs']);
    if ($mode === 'chosen') {
        $ids = array_values(array_unique(array_map('intval', $recipeIds)));
        if (!$ids) return [false, 'Tick the recipes the pal should make, or pick "everything".'];
        if (count($ids) > 5) return [false, 'Pick up to 5 recipes.'];
        $plan = array_values(array_filter(array_map(fn($id) => $all[$id] ?? null, $ids)));
        if (count($plan) !== count($ids)) return [false, 'You can only pick recipes you know that this station makes.'];
    } else $plan = array_values($all);
    if (!$plan) return [false, 'You know no recipes for the ' . $o['label'] . ' yet.'];
    $cookingArea = $area === 'cooking';
    if ($passive) {   // one pal per pot: the pal holds it until the shift ends. The first recipe it can make now (else the first chosen) is its starting choice.
        if ((int)($stations['cooking'] ?? 0) === 0 || cook_pots_busy($uid) >= cook_pot_limit($u)) return [false, 'All your pots are busy. A pal needs a free pot.'];
        $kitchen3 = user_building_bonus($uid, 'kitchen')['feasts'];
        $first = $plan[0];
        foreach ($plan as $r) if ((!str_starts_with((string)$r['slug'], 'feast-') || $kitchen3) && craft_fit(craft_stock($uid, (string)$r['ingredients']), 0, 0) > 0) { $first = $r; break; }
        db()->beginTransaction();
        if (!pj_claim_pal($uid, $palUid, 'station')) { db()->rollBack(); return [false, $p['name'] . ' is already out.']; }
        db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $palUid, 'kind' => 'station', 'target' => $target, 'plot_id' => null, 'day' => landmark_day(), 'tool' => 'passive',
            'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() + $hours * 3600), 'last_tick' => now(), 'potions' => 0, 'state' => 'active',
            'result' => json_encode(['passive' => true, 'plan' => (int)$first['id'], 'hp' => (int)$p['hp'], 'rounds' => 0, 'area' => $area, 'obj' => $o['label'], 'served' => 0, 'cooks' => 0, 'skipped' => 0])]);
        db()->commit();
        return [true, $p['name'] . ' takes a pot for ' . $hours . ' h and cooks ' . (string)$first['out_name'] . ', checking it every ' . intdiv(PJ_PASSIVE_TICK, 60) . ' min. Change the dish on the pot, in your Kitchen.'];
    }
    $kitchen3 = !$cookingArea || user_building_bonus($uid, 'kitchen')['feasts'];
    $c = (int)$p['c'];
    $cap = max(1, intdiv($hours * 60, pj_station_minutes($c)));
    $have = [];
    foreach (q('SELECT i.slug, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ?', [$uid])->fetchAll() as $r) $have[(string)$r['slug']] = (int)$r['qty'];
    $rng = pj_rng(bin2hex(random_bytes(6)));
    $made = []; $takes = []; $makes = 0; $stopped = '';
    $outItem = [];
    for ($guard = 0; $makes < $cap && $guard < 200; $guard++) {
        $did = false;
        foreach ($plan as $r) {
            if ($makes >= $cap) break;
            if (str_starts_with((string)$r['slug'], 'feast-') && !$kitchen3) continue;
            $need = json_decode((string)$r['ingredients'], true) ?: [];
            $ok = $need !== [];
            foreach ($need as $slug => $q) if (($have[(string)$slug] ?? 0) < (int)$q) { $ok = false; break; }
            if (!$ok) continue;
            foreach ($need as $slug => $q) { $have[(string)$slug] -= (int)$q; $takes[(string)$slug] = ($takes[(string)$slug] ?? 0) + (int)$q; }
            $n = max(1, (int)$r['output_qty']) + ($rng(100) < pj_station_extra_pct($c) ? 1 : 0);
            $made[(int)$r['output_item_id']] = ($made[(int)$r['output_item_id']] ?? 0) + $n;
            $outItem[(int)$r['output_item_id']] = (string)$r['out_name'];
            $makes++; $did = true;
            $xpBase = ($area === 'tools' ? 15 : 5);
            $xpTotal = ($xpTotal ?? 0) + $xpBase;
            $slugsMade[(string)$r['slug']] = ($slugsMade[(string)$r['slug']] ?? 0) + 1;
        }
        if (!$did) break;
    }
    if ($makes < 1) {
        $r0 = $plan[0];
        $stock = craft_stock($uid, (string)$r0['ingredients']);
        return [false, (craft_short_text($stock, 0, 999, 1) ?: 'Nothing in the plan can be made right now.') . ' Nothing was used.'];
    }
    db()->beginTransaction();
    foreach ($takes as $slug => $qty) {
        $iid = item_id_by_slug($slug);
        if (!$iid || !give_item($uid, $iid, -$qty)) { db()->rollBack(); return [false, 'Something changed in your satchel. Nothing was used.']; }
    }
    if (!pj_claim_pal($uid, $palUid, 'station')) { db()->rollBack(); return [false, $p['name'] . ' is already out.']; }
    $items = [];
    foreach ($made as $iid => $q) $items[] = [$iid, $q, $outItem[$iid]];
    $stopTxt = $makes < $cap ? 'Stopped after ' . $makes . ': out of ingredients for the rest.' : '';
    db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $palUid, 'kind' => 'station', 'target' => $target, 'plot_id' => null, 'day' => landmark_day(),
        'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() + $hours * 3600), 'last_tick' => now(), 'potions' => 0, 'state' => 'active',
        'result' => json_encode(['items' => $items, 'makes' => $makes, 'hp' => (int)$p['hp'], 'rounds' => 0, 'xp_base' => (int)($xpTotal ?? 0), 'area' => $area, 'obj' => $o['label'], 'stop' => $stopTxt])]);
    db()->commit();
    return [true, $p['name'] . ' takes the ' . $o['label'] . ' for ' . $hours . ' h: ' . $makes . ' make' . ($makes === 1 ? '' : 's') . ', no energy used.' . ($stopTxt !== '' ? ' ' . $stopTxt : '')];
}

// ---------------- passive cooking: a pal tends one pot ----------------

/** Unix time of a stored UTC datetime. */
function pj_ts(string $d): int { return (int)strtotime($d . ' UTC'); }

/**
 * One check of a tending pal at time $t: serve the pal's pot if it is done, then, if the pot is free, start one make of the chosen recipe (the pal's
 * 'plan' in the job result). Missing ingredients or an unknown recipe just skip this check. One make per cook, so output follows pot time and stock.
 * $r (the job result) is updated in place: served (dishes), cooks, skipped, pal_xp.
 */
function pj_passive_step(array $u, array $j, array &$r, int $t): void
{
    $uid = (int)$u['id'];
    require_once __DIR__ . '/crafting.php';
    $pot = q_one('SELECT * FROM cook_pots WHERE user_id = ? AND pal_uid = ? AND collected_at IS NULL', [$uid, $j['pal_uid']]);
    if ($pot) {
        if (pj_ts((string)$pot['ready_at']) > $t) return;   // still cooking
        [$ok, , $info] = cook_collect_one($u, (int)$pot['id'], true);
        if ($ok) { $r['served'] = (int)($r['served'] ?? 0) + (int)$info['dishes']; $r['cooks'] = (int)($r['cooks'] ?? 0) + 1; $r['pal_xp'] = (int)($r['pal_xp'] ?? 0) + 3; $r['last'] = (string)$info['name']; }
    }
    $rid = (int)($r['plan'] ?? 0);
    $rec = $rid > 0 ? q_one('SELECT r.* FROM recipes r JOIN user_recipes ur ON ur.recipe_id = r.id AND ur.user_id = ? WHERE r.id = ?', [$uid, $rid]) : null;
    if (!$rec) { $r['skipped'] = (int)($r['skipped'] ?? 0) + 1; return; }
    if (str_starts_with((string)$rec['slug'], 'feast-') && !user_building_bonus($uid, 'kitchen')['feasts']) { $r['skipped'] = (int)($r['skipped'] ?? 0) + 1; return; }
    $stock = craft_stock($uid, (string)$rec['ingredients']);
    if (craft_fit($stock, 0, 0) < 1) { $r['skipped'] = (int)($r['skipped'] ?? 0) + 1; return; }
    require_once __DIR__ . '/gourmand.php';
    $pal = pj_pal($uid, (string)$j['pal_uid']);
    $score = gourmand_dish_score($u, $stock);
    db()->beginTransaction();
    foreach ($stock as $s) if ($s['id'] < 1 || !give_item($uid, $s['id'], -$s['qty'])) { db()->rollBack(); $r['skipped'] = (int)($r['skipped'] ?? 0) + 1; return; }
    $dishes = max(1, (int)$rec['output_qty']) + (random_int(1, 100) <= pj_station_extra_pct($pal ? (int)$pal['c'] : 1) ? 1 : 0);
    db_insert('cook_pots', ['user_id' => $uid, 'recipe_id' => $rid, 'makes' => 1, 'dishes' => $dishes, 'started_at' => gmdate('Y-m-d H:i:s', $t),
        'ready_at' => gmdate('Y-m-d H:i:s', $t + cook_seconds($u, $rec)), 'score' => $score, 'pal_uid' => (string)$j['pal_uid']]);
    db()->commit();
}

/** Catch a passive job up on its 10-minute checks (never past its end). The last_tick claim makes two tabs run each check once. */
function pj_passive_tick(int $uid, array $j): void
{
    $last = pj_ts((string)$j['last_tick']);
    $n = min(PJ_PASSIVE_MAX, intdiv(min(time(), pj_ts((string)$j['ends_at'])) - $last, PJ_PASSIVE_TICK));
    if ($n < 1) return;
    if (q('UPDATE ppal_jobs SET last_tick = ? WHERE id = ? AND state = \'active\' AND last_tick = ?', [gmdate('Y-m-d H:i:s', $last + $n * PJ_PASSIVE_TICK), $j['id'], $j['last_tick']])->rowCount() !== 1) return;
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    if (!$u) return;
    $r = json_decode((string)$j['result'], true) ?: [];
    for ($k = 1; $k <= $n; $k++) pj_passive_step($u, $j, $r, $last + $k * PJ_PASSIVE_TICK);
    pj_passive_save($j['id'], $r);
}

/** Save the counters without overwriting a recipe change made in the meantime. */
function pj_passive_save($jobId, array $r): void
{
    $cur = json_decode((string)q_val('SELECT result FROM ppal_jobs WHERE id = ?', [$jobId]), true) ?: [];
    foreach (['served', 'cooks', 'skipped', 'pal_xp', 'last', 'lost'] as $k) if (isset($r[$k])) $cur[$k] = $r[$k];
    q('UPDATE ppal_jobs SET result = ? WHERE id = ?', [json_encode($cur), $jobId]);
}

/** A passive shift is over: serve a finished pot, then let go of any pot still cooking (it becomes the gnome's own to collect). */
function pj_passive_finish(int $uid, int $jobId, bool $recall = false): void
{
    $j = q_one('SELECT * FROM ppal_jobs WHERE id = ?', [$jobId]);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    if (!$j || !$u) return;
    require_once __DIR__ . '/crafting.php';
    $r = json_decode((string)$j['result'], true) ?: [];
    $pot = q_one('SELECT * FROM cook_pots WHERE user_id = ? AND pal_uid = ? AND collected_at IS NULL', [$uid, $j['pal_uid']]);
    if ($pot && pj_ts((string)$pot['ready_at']) <= time()) {
        [$ok, , $info] = cook_collect_one($u, (int)$pot['id'], true);
        if ($ok) { $r['served'] = (int)($r['served'] ?? 0) + (int)$info['dishes']; $r['cooks'] = (int)($r['cooks'] ?? 0) + 1; $r['pal_xp'] = (int)($r['pal_xp'] ?? 0) + 3; $r['last'] = (string)$info['name']; }
    }
    if ($recall && ($pot = q_one('SELECT * FROM cook_pots WHERE user_id = ? AND pal_uid = ? AND collected_at IS NULL', [$uid, $j['pal_uid']]))) {   // recalled mid-cook: half the dishes are lost
        $half = intdiv((int)$pot['dishes'], 2);
        if ($half < 1) q('UPDATE cook_pots SET collected_at = ? WHERE id = ?', [now(), $pot['id']]);
        else q('UPDATE cook_pots SET dishes = ? WHERE id = ?', [$half, $pot['id']]);
        $r['lost'] = (int)$pot['dishes'] - $half;
    }
    q('UPDATE cook_pots SET pal_uid = NULL WHERE user_id = ? AND pal_uid = ? AND collected_at IS NULL', [$uid, $j['pal_uid']]);
    pj_passive_save($jobId, $r);
}

/** Change what a tending pal cooks next. It keeps the choice until changed or the shift ends. Returns [ok, message]. */
function pj_pot_set_recipe(array $u, int $jobId, int $recipeId): array
{
    $uid = (int)$u['id'];
    if (!ppal_ensure()) return [false, 'Pals are not available.'];
    pj_settle($uid);
    $j = q_one("SELECT * FROM ppal_jobs WHERE id = ? AND user_id = ? AND kind = 'station' AND tool = 'passive' AND state = 'active'", [$jobId, $uid]);
    if (!$j) return [false, 'That pal is not tending a pot any more.'];
    [$ar, $ob] = array_pad(explode(':', (string)$j['target'], 2), 2, '');
    $o = pj_station_object($ar, $ob);
    require_once __DIR__ . '/crafting.php';
    $all = $o ? pj_station_recipes($uid, $ar, $o['globs']) : [];
    if (!isset($all[$recipeId])) return [false, 'You can only pick a recipe you know that this station makes.'];
    $cur = json_decode((string)q_val('SELECT result FROM ppal_jobs WHERE id = ?', [$jobId]), true) ?: [];
    $cur['plan'] = $recipeId;
    q('UPDATE ppal_jobs SET result = ? WHERE id = ?', [json_encode($cur), $jobId]);
    $p = pj_pal($uid, (string)$j['pal_uid']);
    return [true, ($p['name'] ?? 'Your pal') . ' will cook ' . (string)$all[$recipeId]['out_name'] . ' next.'];
}

// ---------------- delve re-runs ----------------

/** Delves this gnome has cleared at least once: list of landmark rows (id, name, level, landscape) with clears. */
function pj_cleared_delves(int $uid): array
{
    $out = [];
    foreach (q("SELECT l.id, l.name, l.location_id, c.clears FROM landmark_clears c JOIN landmarks l ON l.id = c.landmark_id
                WHERE c.user_id = ? AND l.kind = 'delve' ORDER BY l.name", [$uid])->fetchAll() as $r) {
        $lm = landmark_at((int)$r['location_id']);   // the level comes from the side road to it
        $r['level'] = (int)($lm['level'] ?? 1);
        $r['landscape'] = (string)($lm['landscape'] ?? 'forest');
        $out[] = $r;
    }
    return $out;
}

/** Roll a delve re-run: 5 rooms; each is a fight against the delve's level. The chest pays about 60% of a real clear and never gives first-clear extras. */
function pj_roll_delve(array $p, array $lm, int $potions, string $seed): array
{
    $rng = pj_rng($seed);
    $pal = $p['pal'];
    $a = $p['a'];
    $lvl = max(1, (int)$lm['level']);
    $hp = $p['hp'];
    $used = 0;
    $log = [];
    $rooms = 0;
    $fainted = false;
    for ($r = 1; $r <= DELVE_ROOMS; $r++) {
        $power = (int)$pal['grit'] + (int)$pal['nimble'] + 2 * $a;
        $foe = $lvl + $r;
        $win = max(25, min(92, 55 + 5 * ($power - $foe)));
        if ($rng(100) >= $win) {
            $dmg = 3 + $rng(4) + intdiv($foe, 3);
            $hp -= $dmg;
            $log[] = 'Room ' . $r . ': a tough fight, -' . $dmg . ' HP.';
        } else {
            $log[] = 'Room ' . $r . ': cleared.';
        }
        while ($hp > 0 && $hp <= intdiv($p['max'] * 4, 10) && $potions - $used > 0) {
            $used++; $hp = min($p['max'], $hp + PJ_POTION_HEAL); $log[] = 'Drank a potion.';
        }
        if ($hp <= 0) { $hp = 0; $fainted = true; $log[] = 'Out of HP: heading home.'; break; }
        $rooms = $r;
    }
    $coins = 0; $items = [];
    if (!$fainted) {
        $coins = (int)round(random_int(20 + 5 * $lvl, 40 + 10 * $lvl) * max(0, (int)setting('ppal_delve_coin_pct')) / 100);
        $n = 1 + ($rng(100) < 50 ? 1 : 0);
        for ($i = 0; $i < $n; $i++) {
            $rare = $rng(100) < (int)round((20 + $lvl) * pj_rare_mult($a));   // v2.3.3: odds grow with Adventuring, no gate
            $it = q_one("SELECT i.id, i.name FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.active = 1 AND g.rarity = ? ORDER BY " . sql_random() . ' LIMIT 1', [$rare ? 'rare' : 'uncommon']);
            if ($it) $items[(int)$it['id']] = [(int)$it['id'], ($items[(int)$it['id']][1] ?? 0) + 1, (string)$it['name']];
        }
    }
    return ['rounds' => $rooms, 'coins' => $coins, 'items' => array_values($items), 'hp' => $hp, 'potions_used' => $used, 'fainted' => $fainted, 'log' => $log];
}

/** How a pal picks its way on a route, by calling: first kind in the list wins (Wayfinder the safe way, Thornblade the fights). Others go as the seed falls. */
const PJ_ROUTE_PREF = [
    'wayfinder' => ['shrine', 'treasure', 'mole', 'puzzle', 'mystery', 'fight'],
    'thornblade' => ['fight', 'treasure', 'mystery', 'puzzle', 'mole', 'shrine'],
];

/**
 * Delve redo (setting delve_v2 on): the pal walks today's route of the delve (dv_route, the same route the gnome sees today) with no screen.
 * Every row but the guardian's: a fight floor is two fights, a mystery or puzzle floor a trap, a treasure floor an extra find, a shrine heals, Mo finds
 * a few Petals. The pal turns back at the guardian's hall (never fights it) and brings home about 60% of a clear, as before.
 * Same result keys as pj_roll_delve ('rounds' is scaled to DELVE_ROOMS so the time out and the XP stay the same), plus 'path' (the node kinds taken).
 */
function pj_roll_delve_route(array $p, array $lm, int $potions, string $seed, string $routeSeed): array
{
    require_once __DIR__ . '/delve_v2.php';
    $rng = pj_rng($seed);
    $pal = $p['pal'];
    $a = $p['a'];
    $lvl = max(1, (int)$lm['level']);
    $route = dv_route($routeSeed, dv2_slug($lm), dv_stages($lvl));
    $pref = PJ_ROUTE_PREF[$pal['calling'] ?? ''] ?? null;
    $power = (int)$pal['grit'] + (int)$pal['nimble'] + 2 * $a;
    $hp = $p['hp'];
    $used = 0;
    $log = [];
    $path = [];
    $done = 0;
    $fainted = false;
    $extraFinds = 0;
    $moleCoins = 0;
    $walk = $route['stages'] - 1;   // the guardian's row is left alone
    $at = null;
    for ($r = 0; $r < $walk && !$fainted; $r++) {
        $choices = dv_route_choices($route, $at);
        if (!$choices) break;
        if ($pref) {
            usort($choices, fn($x, $y) => array_search(dv_route_node($route, $x)['kind'], $pref, true) <=> array_search(dv_route_node($route, $y)['kind'], $pref, true));
            $at = $choices[0];
        } else {
            $at = $choices[$rng(count($choices))];
        }
        $kind = dv_route_node($route, $at)['kind'];
        $path[] = $kind;
        $foe = $lvl + $r + 1;
        $label = 'Stage ' . ($r + 1) . ' (' . $kind . ')';
        if ($kind === 'fight') {
            for ($k = 0; $k < 2; $k++) {
                $win = max(25, min(92, 55 + 5 * ($power - $foe)));
                if ($rng(100) >= $win) { $dmg = 3 + $rng(4) + intdiv($foe, 3); $hp -= $dmg; $log[] = $label . ': a tough fight, -' . $dmg . ' HP.'; }
                else $log[] = $label . ': won a fight.';
            }
        } elseif ($kind === 'mystery' || $kind === 'puzzle') {
            if ($rng(100) < 35) { $dmg = 2 + $rng(3) + intdiv($foe, 4); $hp -= $dmg; $log[] = $label . ': sprang a trap, -' . $dmg . ' HP.'; }
            else $log[] = $label . ': slipped past a trap.';
        } elseif ($kind === 'treasure') {
            $extraFinds++;
            $log[] = $label . ': found a cache.';
        } elseif ($kind === 'shrine') {
            $hp = $p['max'];
            $log[] = $label . ': rested at the shrine.';
        } else {
            $moleCoins += 5 + $lvl;
            $log[] = $label . ': Mo the mole found a few Petals.';
        }
        while ($hp > 0 && $hp <= intdiv($p['max'] * 4, 10) && $potions - $used > 0) {
            $used++; $hp = min($p['max'], $hp + PJ_POTION_HEAL); $log[] = 'Drank a potion.';
        }
        if ($hp <= 0) { $hp = 0; $fainted = true; $log[] = 'Out of HP: heading home.'; break; }
        $done = $r + 1;
    }
    if (!$fainted) $log[] = 'Turned back at the guardian’s hall with the loot.';
    $coins = 0;
    $items = [];
    if (!$fainted) {
        $coins = (int)round(random_int(20 + 5 * $lvl, 40 + 10 * $lvl) * max(0, (int)setting('ppal_delve_coin_pct')) / 100) + $moleCoins;
        $n = 1 + ($rng(100) < 50 ? 1 : 0) + $extraFinds;
        for ($i = 0; $i < $n; $i++) {
            $rare = $rng(100) < 20 + $lvl && $a >= 5;
            $it = q_one("SELECT i.id, i.name FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.active = 1 AND g.rarity = ? ORDER BY " . sql_random() . ' LIMIT 1', [$rare ? 'rare' : 'uncommon']);
            if ($it) $items[(int)$it['id']] = [(int)$it['id'], ($items[(int)$it['id']][1] ?? 0) + 1, (string)$it['name']];
        }
    }
    $rounds = $walk > 0 ? (int)round(DELVE_ROOMS * $done / $walk) : 0;
    return ['rounds' => $rounds, 'coins' => $coins, 'items' => array_values($items), 'hp' => $hp, 'potions_used' => $used, 'fainted' => $fainted, 'log' => $log, 'path' => $path];
}

function pj_delve_send(array $u, string $palUid, int $lmId, int $potions, bool $unequip = false): array
{
    $uid = (int)$u['id'];
    $potions = max(0, min(5, $potions));
    $lm = null;
    foreach (pj_cleared_delves($uid) as $d) if ((int)$d['id'] === $lmId) $lm = $d;
    if (!$lm) return [false, 'Your pal can only re-run a delve you have cleared yourself.'];
    [$p, $err] = pj_can_send($u, $palUid, $unequip);
    if (!$p) return [false, $err];
    if (pj_runs_today($uid) >= pj_runs_per_day()) return [false, 'Your pals have done enough trips and delves for today (' . pj_runs_per_day() . ').'];
    if (q_val("SELECT 1 FROM ppal_jobs WHERE user_id = ? AND kind = 'delve' AND target = ? AND day = ?", [$uid, (string)$lmId, landmark_day()])) return [false, 'That delve needs a day to settle.'];
    if (!pj_take_potions($uid, $potions)) return [false, 'You do not have ' . $potions . ' Healing Potion' . ($potions === 1 ? '' : 's') . '.'];
    if (!pj_claim_pal($uid, $palUid, 'delve')) { if ($potions) give_item($uid, pj_potion_id(), $potions); return [false, $p['name'] . ' is already out.']; }
    require_once __DIR__ . '/delve_map.php';
    if (dv_on()) {
        require_once __DIR__ . '/delve_v2.php';
        $res = pj_roll_delve_route($p, $lm, $potions, bin2hex(random_bytes(6)), dv2_seed($uid, $lmId));
    } else {
        $res = pj_roll_delve($p, $lm, $potions, bin2hex(random_bytes(6)));
    }
    $res['potions_back'] = $potions - $res['potions_used'];
    $secs = $res['fainted'] ? max(600, (int)(3600 * $res['rounds'] / DELVE_ROOMS)) : 3600;
    db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $palUid, 'kind' => 'delve', 'target' => (string)$lmId, 'plot_id' => null, 'day' => landmark_day(), 'tool' => null,
        'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() + $secs), 'last_tick' => now(), 'potions' => $potions, 'state' => 'active', 'result' => json_encode($res)]);
    return [true, $p['name'] . ' goes down ' . $lm['name'] . '. Back in ' . pj_ago($secs) . '.'];
}

// ---------------- collect ----------------

/**
 * Collect a ready trip or delve: the claim UPDATE (ready to done) comes first, so a double click pays once. Returns [ok, lines, head].
 * head (v2.3.3) is the receipt title ("Bramble is back from the forest."); lines are the receipt, faint first so a small haul makes sense.
 */
function pj_collect(array $u, int $jobId): array
{
    $uid = (int)$u['id'];
    pj_settle($uid);
    $j = q_one('SELECT * FROM ppal_jobs WHERE id = ? AND user_id = ?', [$jobId, $uid]);
    if (!$j || $j['state'] !== 'ready') return [false, ['Nothing to collect.'], ''];
    if (q("UPDATE ppal_jobs SET state = 'done' WHERE id = ? AND state = 'ready'", [$jobId])->rowCount() !== 1) return [false, ['Already collected.'], ''];
    $r = json_decode((string)$j['result'], true) ?: [];
    $p = pj_pal($uid, (string)$j['pal_uid']);
    $name = $p ? $p['name'] : 'Your pal';
    $where = $j['kind'] === 'delve' ? (string)(q_val('SELECT name FROM landmarks WHERE id = ?', [(int)$j['target']]) ?: 'the delve')
        : 'the ' . strtolower((string)(LANDSCAPES[$j['target']][1] ?? 'wilds'));
    $fainted = !empty($r['fainted']);
    $isStation = $j['kind'] === 'station';
    $isPassive = $isStation && ($j['tool'] ?? '') === 'passive';
    $head = $isStation ? $name . ' finished a shift at the ' . (string)($r['obj'] ?? 'station') . '.' : ($fainted ? $name . ' came home early from ' . $where . '.' : $name . ' is back from ' . $where . '.');
    $lines = [];
    if ($fainted) $lines[] = '😵 Out of HP, so ' . $name . ' turned back. Let them rest or give a potion.';
    if (!empty($r['coins'])) { give_petals($uid, (int)$r['coins'], 'pal delve'); $lines[] = '💰 ' . money((int)$r['coins']); }
    foreach ($r['items'] ?? [] as [$iid, $qty, $iname]) { give_item($uid, (int)$iid, (int)$qty); $lines[] = '🎁 ' . $iname . ' ×' . (int)$qty; }
    if ($isPassive) {
        $lines[] = !empty($r['cooks']) ? '🍲 ' . $name . ' served ' . (int)$r['served'] . ' dish' . ((int)$r['served'] === 1 ? '' : 'es') . ' from ' . (int)$r['cooks'] . ' cook' . ((int)$r['cooks'] === 1 ? '' : 's') . ' (already in your satchel).' : '🍃 Nothing was cooked.';
        if (!empty($r['lost'])) $lines[] = 'ℹ️ Called home early: ' . (int)$r['lost'] . ' dish' . ((int)$r['lost'] === 1 ? '' : 'es') . ' in the pot were lost.';
        if (!empty($r['skipped'])) $lines[] = 'ℹ️ ' . (int)$r['skipped'] . ' check' . ((int)$r['skipped'] === 1 ? '' : 's') . ' skipped: missing ingredients or no dish chosen.';
        if ($p && ($px = (int)($r['pal_xp'] ?? 0)) > 0) { pj_add_c_xp($uid, $p['key'], $px); $lv = pj_level($p['cxp'] + $px); $lines[] = '⭐ +' . $px . ' Crafting XP for ' . $p['name'] . ($lv > $p['c'] ? ': now level ' . $lv . '!' : ''); }
        return [true, $lines, $head];
    }
    if (empty($r['coins']) && empty($r['items'])) $lines[] = $isStation ? '🍃 Nothing was made.' : '🍃 No finds this time.';
    if (!empty($r['recalled'])) $lines[] = 'ℹ️ Called home early: half of what was earned so far.';
    if ($isStation && !empty($r['stop'])) $lines[] = 'ℹ️ ' . $r['stop'];
    $used = (int)($r['potions_used'] ?? 0);
    $back = (int)($r['potions_back'] ?? 0);
    if ($back) give_item($uid, pj_potion_id(), $back);
    if ($used || $back) $lines[] = '🧪 ' . ($used ? 'Drank ' . $used . ' potion' . ($used > 1 ? 's' : '') : '') . ($used && $back ? ', ' : '') . ($back ? $back . ' back in your satchel' : '') . '.';
    if ($isStation && $p) {   // v2.4.61: the XP of those makes is split: half to the gnome (Crafting XP), half to the pal's Crafting skill
        $base = (int)($r['xp_base'] ?? 0); $palXp = intdiv($base, 2); $gnomeXp = $base - $palXp;
        if ($gnomeXp > 0) { [$gx] = add_action_xp($uid, $gnomeXp, 'Crafting', (int)$u['level']); $lines[] = '⭐ +' . $gx . ' Crafting XP for you'; }
        if ($palXp > 0) { pj_add_c_xp($uid, $p['key'], $palXp); $lv = pj_level($p['cxp'] + $palXp); $lines[] = '⭐ +' . $palXp . ' Crafting XP for ' . $p['name'] . ($lv > $p['c'] ? ': now level ' . $lv . '!' : ''); }
    } elseif ($p) {
        $xp = $j['kind'] === 'delve' ? 4 * (int)($r['rounds'] ?? 0) + ($fainted || !empty($r['recalled']) ? 0 : 10) : 2 * (int)($r['rounds'] ?? 0);
        pj_add_xp($uid, $p['key'], 0, $xp);
        $lv = pj_level($p['axp'] + $xp);
        if ($xp > 0) $lines[] = '⭐ +' . $xp . ' Adventuring XP' . ($lv > $p['a'] ? ': now level ' . $lv . '!' : '');
        if (!empty($r['path'])) { require_once __DIR__ . '/delve_v2.php'; $lines[] = '🗺️ ' . $p['name'] . ' took the ' . implode(', ', array_map(fn($k) => DV2_KIND[$k][1] ?? $k, $r['path'])) . ' way' . (empty($r['fainted']) ? ' and turned back at the guardian.' : '.'); }
    }
    return [true, $lines, $head];
}

/**
 * v2.3.3: "2 pals home with loot" for Today and My Gnome: a small centred link to paljobs.php, or '' (closed, a guest, or nothing due).
 * One COUNT, no settling: a trip or delve whose time is up counts even before the jobs page marks it ready. Garden stays bring no loot, so they never show.
 */
function pj_home_count(array $u): int
{
    if (is_guest($u) || !pj_open($u) || !ppal_ensure()) return 0;
    return (int)q_val("SELECT COUNT(*) FROM ppal_jobs WHERE user_id = ? AND kind IN ('trip','delve') AND (state = 'ready' OR (state = 'active' AND ends_at <= ?))", [(int)$u['id'], now()]);
}

function pj_home_notice_html(array $u): string
{
    $n = pj_home_count($u);
    if ($n < 1) return '';
    return '<p class="pjhome"><a href="' . e(url('paljobs.php')) . '">🧩 ' . ($n === 1 ? '1 pal' : $n . ' pals') . ' home with loot · <b>Collect</b></a></p>';
}

/** Give a pal at home a potion to drink: a Healing Potion, or a stronger tier (ALCHEMY_HEAL). */
function pj_heal(array $u, string $palUid, string $slug = PJ_POTION): array
{
    $uid = (int)$u['id'];
    if (!pj_open($u)) return [false, 'Pal jobs open at gnome level ' . pj_min_level() . '.'];
    $p = pj_pal($uid, $palUid);
    if (!$p || $p['status'] !== 'home') return [false, 'That pal is not at home.'];
    if ($p['hp'] >= $p['max']) return [false, $p['name'] . ' is already well.'];
    if (!isset(ALCHEMY_HEAL[$slug])) $slug = PJ_POTION;
    $id = alchemy_item_id($slug);
    if (!$id || !give_item($uid, $id, -1)) return [false, 'You have no ' . (q_val('SELECT name FROM items WHERE id = ?', [$id]) ?: 'Healing Potion') . '.'];
    $hp = min($p['max'], $p['hp'] + alchemy_pal_heal($slug, $p['max']));
    q("UPDATE ppal_found SET hp = ?, hp_at = ? WHERE user_id = ? AND pal_uid = ? AND status = 'home'", [$hp, now(), $uid, $palUid]);
    return [true, $p['name'] . ' feels better (' . $hp . '/' . $p['max'] . ' HP).'];
}

/** "2 h 10 min" style. */
function pj_ago(int $secs): string
{
    $secs = max(0, $secs);
    if ($secs < 3600) return max(1, intdiv($secs + 59, 60)) . ' min';
    $h = intdiv($secs, 3600); $m = intdiv($secs % 3600, 60);
    return $h . ' h' . ($m ? ' ' . $m . ' min' : '');
}
