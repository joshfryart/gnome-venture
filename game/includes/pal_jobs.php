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
            'g' => pj_level((int)$r['g_xp']), 'a' => $a, 'gxp' => (int)$r['g_xp'], 'axp' => (int)$r['a_xp'], 'hp' => max(0, $hp), 'max' => $max,
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
    return $id ??= (int)q_val('SELECT id FROM items WHERE slug = ?', [PJ_POTION]);
}

function pj_potion_count(int $uid): int
{
    $id = pj_potion_id();
    return $id ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]) : 0;
}

/** Make the Healing Potion item, its recipe (data/crafts.txt) and a shelf in Twigg's shop. Adds only; safe to repeat. */
function pj_ensure_content(): void
{
    $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [PJ_POTION]);
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
    foreach (q("SELECT * FROM ppal_jobs WHERE user_id = ? AND state = 'active' AND ends_at <= ?", [$uid, now()])->fetchAll() as $j) {
        if ($j['kind'] === 'garden') { pj_garden_close($j); continue; }
        if (q("UPDATE ppal_jobs SET state = 'ready' WHERE id = ? AND state = 'active'", [$j['id']])->rowCount() !== 1) continue;
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

function pj_garden_skills(int $g): array
{
    $s = ['water'];
    if ($g >= 3) $s[] = 'weed';
    if ($g >= 9) $s[] = 'harvest';
    return $s;
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
    return [true, $p['name'] . ' heads to the garden for ' . $days . ' day' . ($days > 1 ? 's' : '') . '. Gardening level ' . $p['g'] . ': ' . implode(', ', pj_garden_skills($p['g'])) . '.'];
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
                'name' => $p['name'], 'icon' => '🧩', 'skills' => implode(',', pj_garden_skills($p['g'])), 'step_hours' => pj_garden_step($p['g']),
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
    if ($stats['harvest']) $did[] = 'harvested ' . $stats['harvest'] . ' crop' . ($stats['harvest'] > 1 ? 's' : '');
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

/** Send a garden pal home early. */
function pj_recall(array $u, int $jobId): array
{
    $uid = (int)$u['id'];
    $j = q_one("SELECT * FROM ppal_jobs WHERE id = ? AND user_id = ? AND kind = 'garden' AND state = 'active'", [$jobId, $uid]);
    if (!$j) return [false, 'No pal to call home.'];
    pj_garden_close($j);
    return [true, 'Your pal comes home from the garden.'];
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
    $cands = array_values(array_filter(gather_candidates($land, $tool), fn($g) => (GATHER_RARITY[$g['rarity']][0] ?? 9) <= $tier && ($g['rarity'] !== 'rare' || $a >= 5)));
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
            $tot = 0; foreach ($cands as $g) $tot += GATHER_RARITY[$g['rarity']][1];
            $pick = $rng($tot);
            foreach ($cands as $g) {
                $pick -= GATHER_RARITY[$g['rarity']][1];
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
        $coins = (int)round(random_int(20 + 5 * $lvl, 40 + 10 * $lvl) * 0.6);
        $n = 1 + ($rng(100) < 50 ? 1 : 0);
        for ($i = 0; $i < $n; $i++) {
            $rare = $rng(100) < 20 + $lvl && $a >= 5;
            $it = q_one("SELECT i.id, i.name FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.active = 1 AND g.rarity = ? ORDER BY " . sql_random() . ' LIMIT 1', [$rare ? 'rare' : 'uncommon']);
            if ($it) $items[(int)$it['id']] = [(int)$it['id'], ($items[(int)$it['id']][1] ?? 0) + 1, (string)$it['name']];
        }
    }
    return ['rounds' => $rooms, 'coins' => $coins, 'items' => array_values($items), 'hp' => $hp, 'potions_used' => $used, 'fainted' => $fainted, 'log' => $log];
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
    $res = pj_roll_delve($p, $lm, $potions, bin2hex(random_bytes(6)));
    $res['potions_back'] = $potions - $res['potions_used'];
    $secs = $res['fainted'] ? max(600, (int)(3600 * $res['rounds'] / DELVE_ROOMS)) : 3600;
    db_insert('ppal_jobs', ['user_id' => $uid, 'pal_uid' => $palUid, 'kind' => 'delve', 'target' => (string)$lmId, 'plot_id' => null, 'day' => landmark_day(), 'tool' => null,
        'started_at' => now(), 'ends_at' => gmdate('Y-m-d H:i:s', time() + $secs), 'last_tick' => now(), 'potions' => $potions, 'state' => 'active', 'result' => json_encode($res)]);
    return [true, $p['name'] . ' goes down ' . $lm['name'] . '. Back in ' . pj_ago($secs) . '.'];
}

// ---------------- collect ----------------

/** Collect a ready trip or delve: the claim UPDATE (ready to done) comes first, so a double click pays once. Returns [ok, lines]. */
function pj_collect(array $u, int $jobId): array
{
    $uid = (int)$u['id'];
    pj_settle($uid);
    $j = q_one('SELECT * FROM ppal_jobs WHERE id = ? AND user_id = ?', [$jobId, $uid]);
    if (!$j || $j['state'] !== 'ready') return [false, ['Nothing to collect.']];
    if (q("UPDATE ppal_jobs SET state = 'done' WHERE id = ? AND state = 'ready'", [$jobId])->rowCount() !== 1) return [false, ['Already collected.']];
    $r = json_decode((string)$j['result'], true) ?: [];
    $p = pj_pal($uid, (string)$j['pal_uid']);
    $lines = [];
    if (!empty($r['coins'])) { give_petals($uid, (int)$r['coins'], 'pal delve'); $lines[] = '💰 ' . money((int)$r['coins']); }
    foreach ($r['items'] ?? [] as [$iid, $qty, $name]) { give_item($uid, (int)$iid, (int)$qty); $lines[] = '🎁 ' . $name . ' ×' . (int)$qty; }
    if (!empty($r['potions_back'])) { give_item($uid, pj_potion_id(), (int)$r['potions_back']); $lines[] = '🧪 ' . (int)$r['potions_back'] . ' potion' . ((int)$r['potions_back'] > 1 ? 's' : '') . ' back'; }
    if ($p) {
        $xp = $j['kind'] === 'delve' ? 4 * (int)($r['rounds'] ?? 0) + (empty($r['fainted']) ? 10 : 0) : 2 * (int)($r['rounds'] ?? 0);
        pj_add_xp($uid, $p['key'], 0, $xp);
        $lines[] = '⭐ ' . $p['name'] . ' +' . $xp . ' Adventuring XP';
        if (!empty($r['fainted'])) $lines[] = '😵 ' . $p['name'] . ' ran out of HP and came home early to rest.';
    }
    if (!$lines) $lines[] = 'Nothing this time.';
    return [true, $lines];
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
