<?php
declare(strict_types=1);
/**
 * World progression (v0.7.43): everyone starts in the Maplewold and travels outward.
 * Each region has a recommended level. Roads and the wilds there are at least that tough,
 * and you can only fast-travel to a region once you've walked there yourself.
 */

/** Default recommended level per region code, in the order a gnome is meant to wander. */
const REGION_LEVELS = ['NA' => 1, 'CA' => 4, 'NWE' => 6, 'CB' => 8, 'SE' => 10, 'SA' => 12, 'EE' => 14,
    'MENA' => 17, 'EA' => 20, 'CSA' => 23, 'SEA' => 26, 'WCA' => 29, 'ESA' => 32, 'OC' => 35];

/** The region new gnomes start in (admin setting, by code). */
function start_region_id(): int
{
    $code = strtoupper(trim(setting('start_region'))) ?: 'NA';
    $id = (int)q_val('SELECT id FROM regions WHERE code = ?', [$code]);
    return $id ?: (int)q_val('SELECT id FROM regions ORDER BY sort_order, id LIMIT 1');
}

function region_min_level(?int $regionId): int
{
    static $cache = null;
    if ($cache === null) {
        $cache = [];
        foreach (q('SELECT id, min_level FROM regions')->fetchAll() as $r) $cache[(int)$r['id']] = max(1, (int)$r['min_level']);
    }
    return $regionId ? ($cache[$regionId] ?? 1) : 1;
}

/**
 * How tough a place is (v0.7.48): its region's recommended level (1 for the hub). Villages on a road between two
 * regions ease you in: the first stop over the border into a tougher region sits halfway between the two levels,
 * so the walk out of the Maplewold goes 1 → 2 → 4 instead of jumping straight to the next region's level.
 */
function location_min_level(int $locId): int
{
    static $cache = null;
    if ($cache === null) {
        $cache = [];
        $regionOf = [];
        foreach (q('SELECT id, region_id FROM locations')->fetchAll() as $l) $regionOf[(int)$l['id']] = (int)$l['region_id'];
        foreach ($regionOf as $id => $rid) $cache[$id] = region_min_level($rid ?: null);
        foreach (q('SELECT nodes FROM roads')->fetchAll(PDO::FETCH_COLUMN) as $json) {
            $nodes = array_map('intval', json_decode((string)$json, true) ?: []);
            $last = count($nodes) - 1;
            for ($i = 1; $i < $last; $i++) {   // the villages between the two towns
                $own = $cache[$nodes[$i]] ?? 1;
                foreach ([$nodes[$i - 1], $nodes[$i + 1]] as $nb) {
                    $nl = region_min_level(($regionOf[$nb] ?? 0) ?: null);
                    if (($regionOf[$nb] ?? 0) !== ($regionOf[$nodes[$i]] ?? 0) && $nl < $own) $own = max($nl, intdiv($own + $nl, 2));
                }
                $cache[$nodes[$i]] = $own;
            }
        }
    }
    return $cache[$locId] ?? 1;
}

function record_region_visit(int $uid, ?int $regionId): bool
{
    if (!$uid || !$regionId) return false;
    if (q_val('SELECT 1 FROM region_visits WHERE user_id = ? AND region_id = ?', [$uid, $regionId])) return false;
    try {
        db_insert('region_visits', ['user_id' => $uid, 'region_id' => $regionId, 'first_at' => now()]);
        return true;
    } catch (Throwable) {
        return false;   // a double click got there first
    }
}

/** Regions this gnome has set foot in. */
function visited_regions(int $uid): array
{
    return array_map('intval', q('SELECT region_id FROM region_visits WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN));
}

/** Can this gnome fast-travel straight to a region? Home, any region with one of their gardens, or anywhere they've walked to. */
function can_fast_travel(array $u, int $regionId): bool
{
    if (setting('travel_needs_visit') !== '1') return true;
    if ((int)($u['region_id'] ?? 0) === $regionId) return true;
    if (q_val('SELECT 1 FROM plots WHERE user_id = ? AND region_id = ?', [$u['id'], $regionId])) return true;
    return (bool)q_val('SELECT 1 FROM region_visits WHERE user_id = ? AND region_id = ?', [$u['id'], $regionId]);
}

/** The next region along the way: the lowest-level region next door by road that this gnome hasn't reached yet. */
function next_region_suggestion(array $u): ?array
{
    require_once __DIR__ . '/roads.php';
    $been = visited_regions((int)$u['id']);
    if (!$been) return null;
    $byCode = [];
    foreach (q('SELECT * FROM regions')->fetchAll() as $r) $byCode[$r['code']] = $r;
    $best = null;
    foreach (ROAD_PAIRS as [$a, $b]) {
        foreach ([[$a, $b], [$b, $a]] as [$from, $to]) {
            if (!isset($byCode[$from], $byCode[$to])) continue;
            if (!in_array((int)$byCode[$from]['id'], $been, true) || in_array((int)$byCode[$to]['id'], $been, true)) continue;
            $cand = $byCode[$to] + ['via' => $byCode[$from]['gnomish_name']];
            if (!$best || (int)$cand['min_level'] < (int)$best['min_level']) $best = $cand;
        }
    }
    return $best;
}

/** Install/upgrade: give regions their levels (once, so admin edits stick) and remember where players have already been. */
function ensure_progression(): void
{
    if (setting('progression_seeded') !== '1') {
        foreach (REGION_LEVELS as $code => $lvl) {
            q('UPDATE regions SET min_level = ? WHERE code = ? AND min_level <= 1', [$lvl, $code]);
        }
        // Players who were here before: everywhere they live, garden or have been counts as visited
        $rows = [];
        foreach (q('SELECT id, region_id, location_id FROM users')->fetchAll() as $us) {
            $rows[] = [(int)$us['id'], (int)$us['region_id']];
            if ($us['location_id']) $rows[] = [(int)$us['id'], (int)q_val('SELECT region_id FROM locations WHERE id = ?', [$us['location_id']])];
        }
        foreach (q('SELECT user_id, region_id FROM plots WHERE region_id IS NOT NULL')->fetchAll() as $p) $rows[] = [(int)$p['user_id'], (int)$p['region_id']];
        // Towns and villages whose Almanac page they've earned
        $slugRegion = [];
        foreach (q('SELECT slug, region_id FROM locations WHERE region_id IS NOT NULL')->fetchAll() as $l) $slugRegion[(string)$l['slug']] = (int)$l['region_id'];
        foreach (q("SELECT ue.user_id, en.unlock_key FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id = ue.entry_id
                    WHERE en.unlock_key LIKE 'village:%'")->fetchAll() as $v) {
            $slug = substr((string)$v['unlock_key'], 8);
            if (isset($slugRegion[$slug])) $rows[] = [(int)$v['user_id'], $slugRegion[$slug]];
        }
        foreach ($rows as [$uid, $rid]) if ($uid && $rid) record_region_visit($uid, $rid);
        set_setting('progression_seeded', '1');
    }
}

/** Starting villages (v0.7.48): only ones whose next stops along the road are gentle for a brand-new gnome. */
function gentle_start_village(int $villageId): bool
{
    $base = location_min_level($villageId);
    foreach (q("SELECT a_id, b_id FROM routes WHERE kind = 'road' AND (a_id = ? OR b_id = ?)", [$villageId, $villageId])->fetchAll() as $r) {
        $other = (int)$r['a_id'] === $villageId ? (int)$r['b_id'] : (int)$r['a_id'];
        if (location_min_level($other) > $base + 3) return false;
    }
    return true;
}

// ----------------------------------------------------------------- v0.9.7: mid/late game XP

/** v0.9.7: action XP is worth more the higher the gnome: 1 + xp_action_scale_percent % per gnome level past xp_steep_from (the bars get steeper from there too). */
function action_xp_scale(int $n, int $level): int
{
    if ($n <= 0) return $n;
    $over = max(0, $level - max(1, (int)setting('xp_steep_from')));
    return max(1, (int)round($n * (1 + $over * (int)setting('xp_action_scale_percent') / 100)));
}

/**
 * v0.9.7: pay XP for an everyday action (harvest, cook, craft, fight) with the scaling above. Quest, chapter, milestone and
 * other already-sized rewards keep calling add_xp() directly. $level = the gnome's level if the caller has it (else looked up).
 * Returns [XP paid, new level or null], so the caller can show the scaled number in its flash.
 */
function add_action_xp(int $uid, int $n, string $source, ?int $level = null): array
{
    $level ??= (int)q_val('SELECT level FROM users WHERE id = ?', [$uid]);
    $paid = action_xp_scale($n, $level);
    return [$paid, $paid > 0 ? add_xp($uid, $paid, $source) : null];
}
