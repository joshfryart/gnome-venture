<?php
declare(strict_types=1);
/**
 * Exploring off the path (v0.7.25; gentler climb v0.7.74; deep wilds v0.7.75).
 * From any road stop, a gnome can wander off into the mycelium wilds. Every step deeper costs 1 energy.
 * v0.7.74: the first steps start at the road stop's own level (as easy as the road you left), and each step adds
 * a little more danger from the explore_step_levels setting (default 0,0,1,2,3,5, then +2 a step, up to +20).
 * Warnings and tiers follow explore_warn_from (Medium) and explore_wild_from (Hard, then Wild with bosses about).
 * v0.7.75: past explore_deep_from lie the deep wilds, matched to the gnome's own level with full rewards and bosses.
 * Areas the gnome has outgrown give less XP and Petals (see outlevel_percent in adventure.php); items are unchanged.
 * What's out there is random: creatures, problems, finds, strange sights, and hidden villages and landmarks,
 * which are found for good (a side path to them appears on the road). Turning back is always free.
 * Uses the expeditions table with kind = 'explore' (from_id = to_id = the road stop, depth = how far out).
 */

require_once __DIR__ . '/roads.php';
require_once __DIR__ . '/adventure.php';   // v0.7.75: the outgrown-area helpers (outlevel_*); adventure.php loads this file, but require_once makes that safe
require_once __DIR__ . '/gathering.php';   // v0.7.80: gather here, from a step off the path

/** [name, css class] of the danger tier at a depth (v0.7.74: gentle first, then medium, hard and wild; v0.7.75: deep wilds). */
function explore_tier(int $depth): array
{
    $warn = (int)setting('explore_warn_from');
    $wild = (int)setting('explore_wild_from');
    $deep = (int)setting('explore_deep_from');   // v0.7.75
    return match (true) {
        $depth <= 0 => ['The road', 'road'],
        $depth <= 2 => ['Gentle', 'gentle'],
        $depth >= $deep => ['Deep wilds', 'deep'],   // v0.7.75: first, so it wins even if it's set below the wild
        $depth < $wild && $depth < $warn => ['Medium', 'medium'],
        $depth < $wild => ['Hard', 'hard'],
        default => ['Wild', 'wild'],
    };
}

/** v0.7.74: the danger base for a road stop: the same rule roads use (see route_danger). */
function explore_base(array $u, int $fromId): int
{
    $floor = location_min_level($fromId);
    if (near_home($u, $fromId)) {   // v0.9.7: next to home the wilds start at the gnome's level (easy roads: a few levels below)
        $lvl = max(1, (int)$u['level'], $floor);
        return easy_roads_on($u) ? min($lvl, easy_road_cap($u)) : $lvl;
    }
    return $floor < (int)setting('road_fixed_below') ? max(1, $floor) : max(1, (int)$u['level'], $floor);
}

/** v0.7.74: how much danger each step off the road adds, from the explore_step_levels setting. */
function explore_offset(int $depth): int
{
    if ($depth <= 0) return 0;
    $parts = array_values(array_filter(array_map('trim', explode(',', setting('explore_step_levels'))), fn($s) => $s !== ''));
    $list = array_map('intval', $parts) ?: [0, 0, 1, 2, 3, 5];
    $n = count($list);
    $v = $depth <= $n ? $list[$depth - 1] : $list[$n - 1] + 2 * ($depth - $n);
    return min(20, max(0, $v));
}

/** Danger level at a depth, for this gnome (v0.7.74: starts at the road stop's level, see explore_base; v0.7.75: deep wilds match the gnome). */
function explore_level(array $u, int $depth, array $exp = []): int
{
    $lvl = explore_base($u, (int)($exp['from_id'] ?? 0) ?: (int)($u['location_id'] ?? 0)) + explore_offset($depth);
    $deep = (int)setting('explore_deep_from');   // v0.7.75: the deep wilds are a match for the gnome's own level, one more each step
    if ($depth >= $deep) $lvl = max($lvl, min((int)$u['level'] + 1 + ($depth - $deep), (int)$u['level'] + 10));
    return $lvl;
}

/** v0.7.80: which zone (2, 3 or 4) of its region the landscape at a depth comes from. Steps 1–2 use the road stop's own land (zone 2 is the fallback). */
function explore_zone_of_depth(int $depth): int
{
    if ($depth <= 2) return 2;
    return match (explore_tier($depth)[1]) { 'medium' => 2, 'hard' => 3, default => 4 };
}

/**
 * v0.7.84: lands a region has beyond its four zones (real-world flavour the zones leave out), for the land beside road stops.
 * Editing this list changes which lands can turn up one step from the road.
 */
const REGION_EXTRA_LANDS = ['NA' => ['mountain', 'wetland'], 'NWE' => ['mountain', 'wetland'], 'CB' => ['forest'], 'SE' => ['forest'],
    'EE' => ['tundra'], 'EA' => ['mountain', 'wetland'], 'WCA' => ['forest'], 'OC' => ['mountain', 'rainforest']];

/** v0.7.84: every land a region has: its zones (in order) plus REGION_EXTRA_LANDS. */
function region_lands(int $regionId): array
{
    static $cache = [];
    if (isset($cache[$regionId])) return $cache[$regionId];
    $lands = array_map('strval', q('SELECT landscape FROM zones WHERE region_id = ? ORDER BY zone_num', [$regionId])->fetchAll(PDO::FETCH_COLUMN));
    $code = (string)q_val('SELECT code FROM regions WHERE id = ?', [$regionId]);
    return $cache[$regionId] = array_values(array_unique(array_filter(array_merge($lands, REGION_EXTRA_LANDS[$code] ?? []))));
}

/**
 * v0.7.84: the land one step past a road stop's own (step 2 off the path), so the roads aren't grassland on every side.
 * Each region's road villages share out its lands in turn: the extra lands first (e.g. the Maplewold's mountains), then its
 * wilder zones, so neighbouring stops differ. Never the stop's own land when there's another.
 */
function stop_near_land(array $loc): string
{
    static $cache = [];
    $id = (int)($loc['id'] ?? 0);
    if (isset($cache[$id])) return $cache[$id];
    $own = (string)($loc['landscape'] ?? '');
    $rid = (int)($loc['region_id'] ?? 0);
    $code = (string)q_val('SELECT code FROM regions WHERE id = ?', [$rid]);
    $zones = array_map('strval', q('SELECT landscape FROM zones WHERE region_id = ? AND zone_num >= 2 ORDER BY zone_num', [$rid])->fetchAll(PDO::FETCH_COLUMN));
    $pool = array_values(array_unique(array_merge(REGION_EXTRA_LANDS[$code] ?? [], $zones)));
    $stops = array_map('intval', q("SELECT DISTINCT l.id FROM locations l JOIN routes r ON (r.a_id = l.id OR r.b_id = l.id) AND r.kind = 'road'
                                   WHERE l.region_id = ? AND l.kind = 'village' ORDER BY l.id", [$rid])->fetchAll(PDO::FETCH_COLUMN));
    $i = array_search($id, $stops, true);
    $i = $i === false ? crc32((string)($loc['slug'] ?? $id)) : $i;
    $choices = array_values(array_filter($pool, fn($l) => $l !== $own));
    if (!$choices) return $cache[$id] = $own ?: 'grassland';
    return $cache[$id] = $choices[$i % count($choices)];
}

/** The landscape out there: the stop's own land at step 1, its neighbouring land at step 2 (v0.7.84), then the region's wilder zones. */
function explore_land(array $exp): string
{
    $from = q_one('SELECT * FROM locations WHERE id = ?', [$exp['from_id']]);
    $depth = (int)$exp['depth'];
    if ($depth === 2 && $from && $from['region_id']) return stop_near_land($from);
    $zoneNum = explore_zone_of_depth($depth);
    $z = $from && $from['region_id'] ? q_val('SELECT landscape FROM zones WHERE region_id = ? AND zone_num = ?', [$from['region_id'], $zoneNum]) : null;
    return (string)($depth <= 2 && !empty($from['landscape']) ? $from['landscape'] : ($z ?: ($from['landscape'] ?? 'grassland') ?: 'grassland'));
}

/**
 * v0.7.80: how many steps out a zone covers, for the region panel and the Almanac: 'near the road' (zone 1),
 * 'steps 3–4', 'step 5' or 'step 7+' (open-ended). '' if the zone is never reached with the current settings.
 * Worked out from explore_zone_of_depth, so it always matches what the gnome actually walks into.
 */
function explore_zone_steps(int $zoneNum): string
{
    if ($zoneNum <= 1) return 'near the road';
    static $cache = [];
    $key = $zoneNum . '|' . setting('explore_warn_from') . '|' . setting('explore_wild_from') . '|' . setting('explore_deep_from');
    if (isset($cache[$key])) return $cache[$key];
    $last = 80;   // settings top out well below this, so anything reaching it is open-ended
    $lo = 0;
    $hi = 0;
    for ($d = 3; $d <= $last; $d++) {
        if (explore_zone_of_depth($d) !== $zoneNum) continue;
        if (!$lo) $lo = $d;
        $hi = $d;
    }
    if (!$lo) return $cache[$key] = '';
    if ($hi === $last) return $cache[$key] = 'step ' . $lo . '+';
    return $cache[$key] = $lo === $hi ? 'step ' . $lo : 'steps ' . $lo . '–' . $hi;
}

/** v0.7.80: gather here from a step off the path (a 🧺 button in the Gather here box). Refused on the road itself or mid-encounter. */
function explore_gather(array $u, array &$exp, string $tool): void
{
    if ($exp['encounter'] || (int)$exp['depth'] < 1) return;
    [, $line] = gather_here($u, explore_land($exp), $tool);
    exp_log($exp, $line);
}

// v1.9.4: the strange sights and little choices that used to be listed here are in includes/data/road_events.txt (loaded by road_life.php),
// so they can be edited as text, filtered by land, region and weather, and shown on the road as well as off it.

function explore_start(array $u): array
{
    $uid = (int)$u['id'];
    require_once __DIR__ . '/adventure.php';
    if (active_expedition($uid)) return [false, 'You’re already out and about.'];
    require_once __DIR__ . '/trek_data.php';
    if (trek_inside($uid)) return [false, 'You’re on a trek. Leave the trek first.'];   // v1.8.0
    if (ts($u['community_shift_until'] ?? null) > time()) return [false, 'You’re on a tending shift at the community garden. Finish or end it first.'];
    $here = player_node($u);
    if (!on_road((int)$here['id'])) return [false, 'Head back to a road first. You can only wander off from a road.'];
    $free = staff_free($uid);
    if (!$free && !spend_energy($uid, 1)) return [false, 'You need 1 energy to wander off the path. Rest or eat something first.'];
    unset($_SESSION['explore_found'], $_SESSION['explore_back']);
    $gc = gnome_combat($u, true);
    db_insert('expeditions', [
        'user_id' => $uid, 'from_id' => $here['id'], 'to_id' => $here['id'], 'route_id' => 0, 'kind' => 'explore', 'depth' => 0,
        'steps_total' => 0, 'step' => 0, 'hp' => $gc['max_hp'], 'max_hp' => $gc['max_hp'], 'level' => max(1, (int)$u['level']), 'scaled' => 0,
        'log' => json_encode(['🌿 You step off the road at ' . $here['name'] . ' and into the wild mycelium.']),
        'started_at' => now(), 'arrive_at' => now(),
    ]);
    $wear = ($free && calling_perk($u, 'staff_no_wear') < 1) ? tool_use($uid, 'staff') : null;   // v0.9.1: Master Wayfinder's staff never wears; v0.7.86: a staff that saves energy wears a little
    return [true, '🌿 You wander off the path. ' . ($free ? '🦯 (Your staff: no energy used.)' : '(−1 energy)') . ($wear ? ' ' . $wear : '')];
}

/** One step: further out ($delta 1), wandering about at the same depth (0), or back toward the road (-1). (v0.7.37) */
function explore_deeper(array $u, array &$exp, int $delta = 1): void
{
    if ($exp['encounter']) return;
    $logLen = count(json_decode((string)$exp['log'], true) ?: []);   // v1.9.3: seeds this step's ambient line (the page uses the same number)
    $delta = max(-1, min(1, $delta));
    if ((int)$exp['depth'] + $delta < 1) $delta = 1 - (int)$exp['depth'];   // you can't wander about on the road itself
    $free = staff_free((int)$u['id']);
    if (!$free && !spend_energy((int)$u['id'], 1)) {
        exp_log($exp, '😮‍💨 You’re too tired to go further. Rest, or head back to the road.');
        return;
    }
    if ($free) {
        exp_log($exp, '🦯 Your staff carries you on: no energy used.');
        if (calling_perk($u, 'staff_no_wear') < 1 && ($wear = tool_use((int)$u['id'], 'staff'))) exp_log($exp, $wear);   // v0.7.86
    }
    $exp['depth'] = (int)$exp['depth'] + $delta;
    $exp['step'] = (int)$exp['depth'];
    $exp['steps_total'] = (int)$exp['depth'];
    $depth = (int)$exp['depth'];
    $trail = json_decode((string)($exp['trail'] ?? ''), true) ?: [];   // v2.0.45: every step, in order, for the hoop map's thread
    $trail[] = $depth;
    $exp['trail'] = json_encode(array_slice($trail, -60));
    calling_event((int)$u['id'], 'depth', '', $depth);   // v0.9.4 N2: how far off the road (highest counts)
    $exp['level'] = explore_level($u, $depth, $exp);
    $pct = outlevel_percent($u, (int)$exp['level']);   // v0.7.75: how much of its XP and Petals this area still gives
    $tier = explore_tier($depth)[0];
    $land = explore_land($exp);
    $L = LANDSCAPES[$land] ?? ['🌱', 'Wilds'];
    exp_log($exp, $L[0] . ' ' . ($delta > 0 ? 'Deeper' : ($delta === 0 ? 'You roam about' : 'Back toward the road')) . ' (' . $depth . ', ' . strtolower($tier) . '): '
        . strtolower($L[1]) . ', danger level ' . $exp['level'] . '.' . ($free ? '' : ' (−1⚡)'));   // v0.7.78: show the energy each step costs
    if ($line = road_line(exp_scene($exp), ['seed' => road_line_seed($exp, $logLen)])) exp_log($exp, '🍃 ' . $line);   // v1.9.3
    // What happens (v0.7.41: fewer fights, more choices): creature 27 · problem 13 · choice 22 · discovery 8–15 · sight · find
    $roll = random_int(1, 100);
    $wild = min((int)setting('explore_wild_from'), (int)setting('explore_deep_from'));   // v0.7.74: wild country from this step (bosses and full-strength creatures); v0.7.75: deep wilds too
    $discoverChance = $depth <= 2 ? 12 : ($depth <= 5 ? 16 : 14);
    $discoverChance = (int)round($discoverChance * (100 + calling_perk($u, 'spot_pct')) / 100);   // v0.9.1: Wayfinders spot hidden places more often
    if ($roll > 40 && $roll <= 62) {
        if ($ev = road_event_pick(exp_scene($exp), 'wild')) {   // v1.9.3: not the same scene again soon; v1.9.4: from road_events.txt, by land, region and weather
            $exp['encounter'] = json_encode(['type' => 'choice', 'ev' => $ev['id']]);
            exp_log($exp, $ev['icon'] . ' ' . $ev['text']);
            return;
        }
        $roll = 100;   // nothing fits (a data file with no scene for this place): a find instead
    }
    if ($roll > 62) $roll -= 22;   // the rest share out as before
    $easyCap = $depth <= 2 && easy_roads_on($u) && near_home($u, (int)$exp['from_id']) ? (int)$exp['level'] : 0;   // v0.9.7: the first steps off an easy road stay at or under its level, no bosses
    if ($roll <= 27 && ($c = pick_creature($land, (int)$exp['level'], $depth >= $wild, $depth >= $wild, $easyCap))) {
        $exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => !empty($c['_scaled']) ? (int)$c['level'] : 0, 'sp' => (int)($c['_pct'] ?? 100), 'hpp' => (int)($c['_hpp'] ?? 100),
            'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
        exp_log($exp, '⚔️ ' . (preg_match('/^[AEIOU]/i', $c['name']) ? 'An ' : 'A ') . $c['name'] . ' blocks your way!');
    } elseif ($roll <= 40 && ($p = pick_problem($land))) {
        $exp['encounter'] = json_encode(['type' => 'problem', 'id' => (int)$p['id'], 'dc_bonus' => intdiv($depth, 2)]);
        exp_log($exp, '❓ ' . $p['text']);
    } elseif ($roll <= 40 + $discoverChance && ($found = explore_discover($u, $exp, $pct))) {
        exp_log($exp, $found);
    } elseif ($roll <= 63) {
        $s = road_sight_pick(exp_scene($exp));   // v1.9.3: not the same sight again soon; v1.9.4: from road_events.txt
        if (!$s) { exp_log($exp, give_find($u, exp_scene($exp))); return; }
        $c = 5 * $depth + intdiv((int)$exp['level'], 2);
        $fx = str_replace(['{c}', '{x}'], [$c . '-' . (2 * $c), (string)(2 + $depth)], $s['fx']);
        require_once __DIR__ . '/events.php';
        $lines = apply_event_effect($u, outlevel_fx($fx, $pct));   // v0.7.75: outgrown areas give less XP and Petals
        exp_log($exp, $s['icon'] . ' ' . $s['text'] . ($lines ? ' (' . implode(', ', $lines) . ')' : ''));
    } else {
        exp_log($exp, give_find($u, exp_scene($exp)));
        if ($depth >= 3 && random_int(1, 100) <= 10 * ($depth - 2)) exp_log($exp, give_find($u, exp_scene($exp)));   // richer further out
    }
}

/** Maybe find a hidden village or landmark of this region. Returns the log line, or null if there's nothing left to find here. */
function explore_discover(array $u, array $exp, int $pct = 100): ?string
{
    $uid = (int)$u['id'];
    $from = q_one('SELECT * FROM locations WHERE id = ?', [$exp['from_id']]);
    if (!$from || !$from['region_id']) return null;
    $depth = (int)$exp['depth'];
    $want = $depth <= 2 ? ['village', 'haven'] : ($depth <= 4 ? ['wonder', 'village', 'haven'] : ['lair', 'wonder']);
    // v0.7.61: only places whose side path leaves from this stop or the stops either side of it on the road
    $near = [(int)$from['id']];
    foreach (q("SELECT a_id, b_id FROM routes WHERE kind = 'road' AND (a_id = ? OR b_id = ?)", [$from['id'], $from['id']])->fetchAll() as $r) {
        $near[] = (int)$r['a_id'] === (int)$from['id'] ? (int)$r['b_id'] : (int)$r['a_id'];
    }
    $in = implode(',', array_map('intval', array_unique($near)));
    $candidates = [];
    foreach (q("SELECT l.* FROM locations l JOIN routes r ON r.b_id = l.id AND r.kind = 'side' WHERE l.region_id = ? AND r.a_id IN ($in) ORDER BY l.id", [$from['region_id']])->fetchAll() as $l) {
        if (place_known($uid, $l)) continue;
        $candidates[in_array($l['kind'], $want, true) ? 0 : 1][] = $l;
    }
    $pool = $candidates[0] ?? $candidates[1] ?? [];
    if (!$pool) return null;
    $l = $pool[array_rand($pool)];
    $key = ($l['kind'] === 'village' ? 'village:' : 'landmark:') . $l['slug'];
    unlock_entries($uid, $key);
    $anchor = (string)q_val("SELECT a.name FROM routes r JOIN locations a ON a.id = r.a_id WHERE r.b_id = ? AND r.kind = 'side' LIMIT 1", [$l['id']]);
    $xp = outlevel_scale(5 + 2 * $depth, $pct);   // v0.7.75: outgrown areas give less XP
    add_xp($uid, $xp);
    $_SESSION['explore_found'] = (int)$l['id'];   // v0.7.61: offer a visit right now
    $icon = ['village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉'][$l['kind']] ?? '📍';
    // v0.7.77: a ruined haven, wonder or delve can be repaired by whoever finds it
    $ruin = q_val("SELECT 1 FROM landmarks m WHERE m.location_id = ? AND m.kind IN ('haven', 'wonder', 'delve') AND m.ruined = 1 AND NOT EXISTS (SELECT 1 FROM landmark_rebuilds b WHERE b.landmark_id = m.id AND b.user_id = ?)", [$l['id'], $uid]);   // v0.7.88: per gnome
    return '🗺️ Through the trees you spot ' . $icon . ' ' . $l['name'] . '! It’s on your map now: a side path from ' . ($anchor ?: 'the road') . '. (+' . $xp . ' XP, new Almanac page)'
        . ($ruin ? ' It’s fallen into ruin: visit it to make it safe for yourself.' : '');
}

/** Back to the road. Always free. */
function explore_return(array $u, array &$exp): void
{
    if ($exp['encounter']) return;
    $from = q_one('SELECT * FROM locations WHERE id = ?', [$exp['from_id']]);
    q('UPDATE users SET location_id = ?, location = ?, arrived_at = ? WHERE id = ?', [$from['id'], $from['region'], now(), $u['id']]);
    $exp['status'] = 'done';
    unset($_SESSION['explore_found']);
    exp_log($exp, '🛣️ You follow your own footprints back to the road at ' . $from['name'] . '.');
    // v0.7.74: a long trip pays: XP from step 3, and Petals from the warning step on (more the further out)
    $depth = (int)$exp['depth'];
    $warn = (int)setting('explore_warn_from');
    $pct = outlevel_percent($u, (int)$exp['level']);   // v0.7.75: outgrown areas give less XP and Petals
    // v0.7.85: the bonus is paid once per stop per Hollow day. Re-entering the wilds from a found place
    // (explore_come_back) starts a new trip from the same stop, so without this the bonus could be collected again.
    // v1.2.2: the once-per-stop-per-day claim lives in landmark_uses (UNIQUE user+id+action+day), not the session: action 'xbonus', id = the stop.
    require_once __DIR__ . '/landmarks.php';
    $xp = outlevel_scale($depth >= 3 ? 2 * $depth : 0, $pct);
    $coins = outlevel_scale($depth >= $warn ? 10 * ($depth - $warn + 1) : 0, $pct);
    if (($xp || $coins) && !landmark_once((int)$u['id'], (int)$exp['from_id'], 'xbonus')) { $xp = 0; $coins = 0; }
    if ($xp) add_xp((int)$u['id'], $xp);
    if ($coins) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $u['id']]);
    if ($xp || $coins) {
        $bits = [];
        if ($xp) $bits[] = '+' . $xp . ' XP';
        if ($coins) $bits[] = '+' . money($coins);
        exp_log($exp, '🎒 Your long trip pays off: ' . implode(', ', $bits) . '.' . outlevel_note($pct));
    }
}

/** Pick an option in a choice card (v0.7.41 off the path; v1.9.4 also on the road). Runs inside the page's transaction and user-row lock. */
function explore_choose(array $u, array &$exp, int $option): void
{
    $enc = json_decode((string)$exp['encounter'], true);
    $ev = road_event_get((array)$enc);
    if (!$ev || !isset($ev['opts'][$option])) return;
    $o = $ev['opts'][$option];
    $label = $o['label'];
    $stat = $o['stat'];
    $dc = $o['dc'];
    $road = ($exp['kind'] ?? 'walk') === 'walk';   // v1.9.4: on a road every item is rare and small (road_fx_resolve)
    $uid = (int)$u['id'];
    $depth = max(1, (int)$exp['depth']);
    $win = true;
    $rollText = '';
    if ($stat !== '' && isset(GNOME_STATS[$stat])) {
        $dc = (int)$dc + intdiv($depth - 1, 2);
        $total = d(20) + eff_mod($u, $stat) + calling_perk($u, 'wonder_bonus');   // v0.9.1: Seedkeepers read puzzles better
        $win = $total >= $dc;
        $rollText = ' (' . GNOME_STATS[$stat][0] . ' ' . $total . ' vs ' . $dc . ')';
    } elseif ($stat === '!') {
        $win = false;   // v2.0.79: a wrong answer to a riddle: no roll, it simply is not right
    }
    $fx = $win ? $o['win'] : $o['lose'];
    $text = $win ? $o['wintext'] : $o['losetext'];
    $c = 5 * $depth + intdiv((int)$exp['level'], 2);
    $fx = str_replace('{c}', $c . '-' . (2 * $c), (string)$fx);
    $fx = road_fx_resolve($fx, $road);   // v1.9.4: "@N" chances; items capped on a road
    $fx = outlevel_fx($fx, outlevel_percent($u, (int)$exp['level']));   // v0.7.75: outgrown areas give less XP and Petals (pay:N costs are not touched)
    $lines = [];
    $rest = [];
    foreach ($fx === '' ? [] : explode('+', $fx) as $part) {
        $p = explode(':', $part);
        if ($p[0] === 'pay') {
            $n = (int)($p[1] ?? 0);
            if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$n, $uid, $n])->rowCount() !== 1) {
                $exp['encounter'] = null;
                exp_log($exp, '👛 You haven’t got ' . $n . ' Petals on you. You wander on.');
                return;
            }
            $lines[] = '−' . money($n);
        } elseif ($p[0] === 'hp') {
            $exp['hp'] = max(1, (int)$exp['hp'] + (int)($p[1] ?? 0));
            $lines[] = (int)($p[1] ?? 0) . ' ❤️';
        } elseif ($p[0] === 'take') {   // v2.0.79: hand over goods (a trade, a toll in kind): take:slug:qty
            $tid = (int)q_val('SELECT id FROM items WHERE slug = ?', [(string)($p[1] ?? '')]);
            $tq = max(1, (int)($p[2] ?? 1));
            if (!$tid || !give_item($uid, $tid, -$tq)) {
                $exp['encounter'] = null;
                exp_log($exp, '🎒 You haven’t got ' . $tq . ' × ' . ((string)q_val('SELECT name FROM items WHERE slug = ?', [(string)($p[1] ?? '')]) ?: (string)($p[1] ?? '')) . ' on you. You wander on.');
                return;
            }
            $lines[] = '−' . $tq . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$tid]);
        } elseif ($p[0] === 'next') {   // v2.0.79: a chain: this card leads to another on the next space
            if ($road && isset(road_events()['ev'][(string)($p[1] ?? '')])) $exp['chain'] = (string)$p[1];
        } elseif ($p[0] === 'skip') {   // v2.0.79: a short way: the next spaces pass without a card (walks only)
            if (!$road) continue;
            $sk = max(1, min(3, (int)($p[1] ?? 1)));
            $before = (int)$exp['step'];
            $exp['step'] = min((int)$exp['steps_total'], $before + $sk);
            if ((int)$exp['step'] > $before) $lines[] = '⏩ ' . ((int)$exp['step'] - $before) . ' space' . ((int)$exp['step'] - $before === 1 ? '' : 's') . ' saved';
        } elseif ($p[0] === 'journal') {   // v2.0.79: a page of the Road Journal
            require_once __DIR__ . '/stops.php';
            $sc = exp_scene($exp);
            if ($jl = road_journal_add($uid, (string)($p[1] ?? ''), stop_region_code((array)($sc['to'] ?? [])))) $lines[] = $jl;
        } elseif ($p[0] === 'heal') {
            $before = (int)$exp['hp'];
            $exp['hp'] = min((int)$exp['max_hp'], $before + (int)($p[1] ?? 0));
            if ($exp['hp'] > $before) $lines[] = '+' . ((int)$exp['hp'] - $before) . ' ❤️';
        } else {
            $rest[] = $part;
        }
    }
    if ($rest) {
        require_once __DIR__ . '/events.php';
        $lines = array_merge($lines, apply_event_effect(q_one('SELECT * FROM users WHERE id = ?', [$uid]), implode('+', $rest)));
    }
    $exp['encounter'] = null;
    exp_log($exp, ($win ? ($stat !== '' ? '✅ ' : '👉 ') : '❌ ') . $label . $rollText . ': ' . $text . ($lines ? ' (' . implode(', ', $lines) . ')' : ''));
}


/** v0.7.61: step over to a place you just found while exploring. Remember the way back. */
function explore_visit(array $u, array &$exp, int $placeId): bool
{
    if ($exp['encounter'] || $placeId !== (int)($_SESSION['explore_found'] ?? 0)) return false;
    $l = q_one('SELECT * FROM locations WHERE id = ?', [$placeId]);
    if (!$l) return false;
    q('UPDATE users SET location_id = ?, location = ?, arrived_at = ? WHERE id = ?', [$l['id'], $l['region'], now(), $u['id']]);
    $_SESSION['explore_back'] = ['from' => (int)$exp['from_id'], 'depth' => max(1, (int)$exp['depth']), 'place' => (int)$l['id']];
    unset($_SESSION['explore_found']);
    $exp['status'] = 'done';
    exp_log($exp, '🚶 You push through to ' . $l['name'] . '.');
    return true;
}

/** v0.7.61: from a place found off the path, slip back into the wilds where you were (free) or back to the road. */
function explore_come_back(array $u, string $how): array
{
    $b = $_SESSION['explore_back'] ?? null;
    $uid = (int)$u['id'];
    require_once __DIR__ . '/adventure.php';
    if (!$b || (int)($u['location_id'] ?? 0) !== (int)$b['place']) return [false, 'You’ve moved on since then.'];
    if (active_expedition($uid)) return [false, 'You’re already out and about.'];
    require_once __DIR__ . '/trek_data.php';
    if (trek_inside($uid)) return [false, 'You’re on a trek. Leave the trek first.'];   // v1.8.0
    $from = q_one('SELECT * FROM locations WHERE id = ?', [$b['from']]);
    if (!$from) return [false, 'The way back is lost.'];
    unset($_SESSION['explore_back']);
    if ($how === 'road') {
        q('UPDATE users SET location_id = ?, location = ?, arrived_at = ? WHERE id = ?', [$from['id'], $from['region'], now(), $uid]);
        return [true, '🛣️ You follow your footprints back to the road at ' . $from['name'] . '.'];
    }
    $gc = gnome_combat($u, true);
    $depth = (int)$b['depth'];
    db_insert('expeditions', [
        'user_id' => $uid, 'from_id' => $from['id'], 'to_id' => $from['id'], 'route_id' => 0, 'kind' => 'explore', 'depth' => $depth,
        'steps_total' => $depth, 'step' => $depth, 'hp' => $gc['max_hp'], 'max_hp' => $gc['max_hp'], 'level' => explore_level($u, $depth, ['from_id' => $from['id']]),
        'scaled' => 0, 'log' => json_encode(['🌿 You slip back into the wild mycelium, ' . $depth . ' step' . ($depth === 1 ? '' : 's') . ' out from ' . $from['name'] . '.']),
        'started_at' => now(), 'arrive_at' => now(),
    ]);
    return [true, '🌿 Back into the wilds.'];
}
