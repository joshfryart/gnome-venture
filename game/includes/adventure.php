<?php
declare(strict_types=1);

require_once __DIR__ . '/combat_math.php';   // v2.0.5: d(), attack_roll, damage, scale_creature, foe_hits ... shared with trek_fight.php
require_once __DIR__ . '/garden_logic.php';
require_once __DIR__ . '/adventure_data.php';
require_once __DIR__ . '/gathering.php';
require_once __DIR__ . '/catalog.php';   // guide_item_slug() for guide drops and delve chests
require_once __DIR__ . '/explore.php';
require_once __DIR__ . '/landmarks.php';
require_once __DIR__ . '/road_life.php';   // v1.9.3: anti-repeat memory, cond tags, ambient lines

/**
 * Adventuring: walking routes between villages. Each route has a few steps; each step is a
 * creature, a problem or a find. Losing a fight never costs items: you wake up where you started.
 * All rolls happen on the server.
 */

const CALLING_ABILITIES = [
    '' => ['Gnome Pluck', 'A determined swing: +3 to hit and +3 damage.'],
    'rootwarden' => ['Bark Skin', 'Your skin hardens like bark: damage you take is halved for 3 rounds.'],
    'bloomcaller' => ['Befriend', 'Charm the creature into leaving peacefully (Charm check). Half XP, no drops, but no fighting.'],
    'thornblade' => ['Thorn Flurry', 'Strike twice in one turn.'],
    'seedkeeper' => ['Spore Burst', 'A cloud of spores that always hits: 2d6 + Lore damage.'],
    'wayfinder' => ['Aimed Shot', 'A careful sling shot: roll twice, keep the best, +2 damage.'],
    'brewroot' => ['Bitter Brew', 'Throw a vial: 1d6 now, and 2 poison damage every round after.'],
];

function luck_mod(array $u): int
{
    return stat_mod(eff_stat($u, 'luck'));
}

/** v0.7.75: how much of its XP and Petals an area still gives this gnome (100 = all of it). Items are never scaled. */
function outlevel_percent(array $u, int $areaLevel): int
{
    $gap = (int)$u['level'] - $areaLevel - (int)setting('outlevel_grace');
    if ($gap <= 0) return 100;
    return max((int)setting('outlevel_min_percent'), 100 - $gap * (int)setting('outlevel_step_percent'));
}

/** v0.7.75: a reward number scaled by an outlevel percent (never below 1 if it was above 0). */
function outlevel_scale(int $n, int $pct): int
{
    return $pct >= 100 || $n <= 0 ? $n : max(1, (int)round($n * $pct / 100));
}

/** v0.7.75: the note added to a log line when an area has been outgrown. */
function outlevel_note(int $pct): string
{
    return $pct >= 100 ? '' : ' (you’ve outgrown these parts: ' . $pct . '%)';
}

/** v0.7.75: scale the XP and Petals numbers in an effect string, e.g. "xp:5+coins:10-20+item:x:1". Other parts are left alone. */
function outlevel_fx(string $fx, int $pct): string
{
    $parts = [];
    foreach (explode('+', $fx) as $part) {
        [$k, $v] = array_pad(explode(':', $part, 2), 2, '');
        if ($k === 'xp' && preg_match('/^\d+$/', $v)) {
            $part = 'xp:' . outlevel_scale((int)$v, $pct);
        } elseif ($k === 'coins' && preg_match('/^\d+(-\d+)?$/', $v)) {
            $part = 'coins:' . implode('-', array_map(fn($n) => outlevel_scale((int)$n, $pct), explode('-', $v)));
        }
        $parts[] = $part;
    }
    return implode('+', $parts);
}

/** The gnome's fighting numbers, from stats, level and calling. $pals = true only for road, lair and delve fights (Puzzle Pals road perk); Treks never pass it. */
function gnome_combat(array $u, bool $pals = false): array
{
    $lvl = (int)$u['level'];
    $sk = [];   // v2.0.92: the pals' combat skills (ppal_skills); empty unless pals come along, so a gnome without pals fights exactly as before
    $pal = 0;   // v2.0.88: the Puzzle Pals road perk: +N Grit, Nimble and Hardiness modifiers in road, lair and delve fights (Treks and contests use other code)
    if ($pals && setting('ppal_party') === '1') { require_once __DIR__ . '/puzzle_pals.php'; if ((int)$u['level'] >= PPAL_PARTY_LEVEL) { $pal = ppal_perks($u)['road']; $sk = ppal_skills($u); } }
    $tonic = !empty($sk['tonic']) && active_buff($u) ? (int)$sk['tonic'] : 0;   // v2.3.8 Boon tonic: a meal or potion boost is on, so Grit and Nimble count more
    $grit = eff_mod($u, 'grit') + $pal + $tonic;
    $nim = eff_mod($u, 'nimble') + $pal + $tonic;
    return [   // v0.9.1: calling numbers now come from the tier table (calling_perk)
        'max_hp' => max(10, 20 + 3 * $lvl + 5 * (eff_mod($u, 'hardiness') + $pal) + calling_perk($u, 'hp_bonus') + ($sk['bulwark'] ?? 0)),
        'ac' => 10 + $nim + intdiv($lvl, 4) + calling_perk($u, 'def_bonus') + ($sk['foot'] ?? 0),
        'atk' => 2 + intdiv($lvl, 2) + max($grit, $nim + calling_perk($u, 'atk_nimble')) + calling_perk($u, 'atk_bonus'),
        'dmg_die' => 8,
        'dmg_bonus' => max(0, $grit) + intdiv($lvl, 4) + calling_perk($u, 'dmg_bonus') + ($sk['edge'] ?? 0),
        'crit_from' => calling_perk($u, 'crit_from', 20),
        'luck_crit' => luck_percent($u) + ($sk['petal'] ?? 0),   // % chance any hit becomes a crit (2 Luck = 0.05% by default)
    ] + ($sk ? ['pal' => $sk] : []);
}

function player_node(array $u): array
{
    $loc = $u['location_id'] ? q_one('SELECT * FROM locations WHERE id = ?', [$u['location_id']]) : null;
    if ($loc) return $loc;
    // First visit: start at your home village (or the hub if you have no home yet)
    $loc = $u['home_village_id'] ? q_one('SELECT * FROM locations WHERE id = ?', [$u['home_village_id']]) : null;
    if (!$loc && !empty($u['region_id'])) {
        $loc = q_one("SELECT * FROM locations WHERE region_id = ? AND kind = 'village' ORDER BY sort_order LIMIT 1", [$u['region_id']]);
    }
    $loc ??= q_one("SELECT * FROM locations WHERE kind = 'hub' LIMIT 1") ?? q_one('SELECT * FROM locations ORDER BY id LIMIT 1');
    q('UPDATE users SET location_id = ?, location = ? WHERE id = ?', [$loc['id'], $loc['region'], $u['id']]);
    return $loc;
}

/** Routes from a place, with the place at the other end. */
function routes_from(int $locId): array
{
    $out = [];
    foreach (q('SELECT * FROM routes WHERE a_id = ? OR b_id = ?', [$locId, $locId])->fetchAll() as $r) {
        $other = (int)$r['a_id'] === $locId ? (int)$r['b_id'] : (int)$r['a_id'];
        $r['to'] = q_one('SELECT l.*, reg.gnomish_name AS region_name FROM locations l LEFT JOIN regions reg ON reg.id = l.region_id WHERE l.id = ?', [$other]);
        $out[] = $r;
    }
    usort($out, fn($a, $b) => $a['level'] <=> $b['level']);
    return $out;
}

function active_expedition(int $uid): ?array
{
    return q_one("SELECT * FROM expeditions WHERE user_id = ? AND status = 'active' ORDER BY id DESC LIMIT 1", [$uid]);
}

/** Safe bases: markets, the hub, and any village where this gnome owns a garden. */
function is_safe_base(array $u, int $locId): bool
{
    static $cache = [];
    $key = $u['id'] . ':' . $locId;
    if (!isset($cache[$key])) {
        $kind = q_val('SELECT kind FROM locations WHERE id = ?', [$locId]);
        $cache[$key] = in_array($kind, ['market', 'hub', 'haven'], true)   // havens are safe stops (v0.7.26)
            || (bool)q_val('SELECT 1 FROM plots WHERE user_id = ? AND village_id = ?', [$u['id'], $locId]);
    }
    return $cache[$key];
}

/** v0.9.7: is this gnome's easy-roads switch on (users.easy_roads)? */
function easy_roads_on(array $u): bool
{
    return (int)($u['easy_roads'] ?? 0) === 1;
}

/** v0.9.7: the top level an easy road lets near-home encounters reach: easy_roads_gap below the gnome, never under 1. */
function easy_road_cap(array $u): int
{
    return max(1, (int)$u['level'] - (int)setting('easy_roads_gap'));
}

/** v0.9.7: is this place near home for the gnome: a safe base (town, hub, haven, a village with their garden) or their home village? */
function near_home(array $u, int $locId): bool
{
    return is_safe_base($u, $locId) || ((int)($u['home_village_id'] ?? 0) !== 0 && (int)$u['home_village_id'] === $locId);
}

/**
 * Danger for this gnome on this path:
 * - paths touching a place near home (a town, a haven, a village with their garden, their home) match the gnome's level, never
 *   below the region's own level (v0.9.7: they used to follow the region's level, so a level 28 gnome met level 1-2 creatures
 *   next to home). With easy roads on they stay at most easy_roads_gap levels below the gnome, and never meet bosses.
 * - other roads and gentle side paths keep the level of the region they lead into (until road_fixed_below)
 * - everything further out (and any path marked "fixed") uses its set level range
 * Returns [min, max, scaled].
 */
function route_danger(array $u, array $route): array
{
    // v0.7.43: never easier than the recommended level of the region the path is in (the far end, for roads between regions)
    $floor = max(location_min_level((int)$route['a_id']), location_min_level((int)$route['b_id']));
    if (!(int)$route['fixed'] && (near_home($u, (int)$route['a_id']) || near_home($u, (int)$route['b_id']))) {   // v0.9.7
        $lvl = max(1, (int)$u['level'], $floor);
        if (easy_roads_on($u)) $lvl = min($lvl, easy_road_cap($u));
        return [$lvl, $lvl, true];
    }
    // v0.7.57 (Joshua): roads and gentle paths in regions below the road_fixed_below level stay at the region's own level,
    // so places you've outgrown stay easy to get around; only wandering off the road climbs with you. Higher regions match your level.
    $gentle = $floor < (int)setting('road_fixed_below') ? max(1, $floor) : max(1, (int)$u['level'], $floor);
    if (($route['kind'] ?? '') === 'road' || (($route['kind'] ?? '') === 'side' && !(int)$route['fixed'])) {   // v0.7.24: roads (and gentle side paths)
        return [$gentle, $gentle, true];
    }
    // v0.7.85: fixed-route levels are stored as absolute values (roads.php), so use them as they are; never above 40
    $min = min(40, max(1, (int)$route['min_level']));
    return [$min, min(40, max($min, (int)$route['max_level'])), false];
}

/**
 * v0.9.7: the walking time of a path for this gnome, in minutes, and whether it is a quick walk: a path whose top level is
 * low_road_gap or more levels below the gnome takes low_road_time_pct % of its time. [minutes, quick]
 */
function route_walk_minutes(array $u, array $route): array
{
    $mins = (int)$route['minutes'];
    $pct = (int)setting('low_road_time_pct');
    if ($mins <= 0 || $pct >= 100) return [$mins, false];
    [, $hi] = route_danger($u, $route);
    if ($hi > (int)$u['level'] - max(1, (int)setting('low_road_gap'))) return [$mins, false];
    return [max(0, (int)round($mins * $pct / 100)), true];
}

function route_energy(array $u, array $route): int
{
    if (($route['kind'] ?? 'road') === 'road' && calling_perk($u, 'free_walks') > 0) return 0;   // v0.9.1: Master Wayfinders walk roads for free (the old halving is gone)
    return max(1, intdiv((int)$route['steps'], 3));   // v0.7.23 scale: 1 for a short walk, 2 for a long one
}

function start_expedition(array $u, int $routeId): array
{
    if (active_expedition((int)$u['id'])) return [false, 'You’re already on the road.'];
    require_once __DIR__ . '/trek_data.php';
    if (trek_inside((int)$u['id'])) return [false, 'You’re on a trek. Leave the trek first.'];   // v1.8.0
    if (ts($u['community_shift_until'] ?? null) > time()) return [false, 'You’re on a tending shift at the community garden. Finish or end it first.'];
    $here = player_node($u);
    $route = q_one('SELECT * FROM routes WHERE id = ? AND (a_id = ? OR b_id = ?)', [$routeId, $here['id'], $here['id']]);
    if (!$route) return [false, 'That path doesn’t start here.'];
    $to = (int)$route['a_id'] === (int)$here['id'] ? (int)$route['b_id'] : (int)$route['a_id'];
    if (($route['kind'] ?? 'road') === 'side') {   // v0.7.24: side paths only lead to places you've found
        require_once __DIR__ . '/roads.php';
        $dest = q_one('SELECT * FROM locations WHERE id = ?', [$to]);
        if (!$dest || (!on_road($to) && !place_known((int)$u['id'], $dest))) return [false, 'You don’t know the way there yet. Explore off the road to find it.'];
    }
    $cost = route_energy($u, $route);
    $staffWear = null;
    $roadFree = $cost === 0;   // v0.9.1: a Master Wayfinder's road walk is already free
    if ($cost > 0 && staff_free((int)$u['id'])) {   // v0.7.30: the walking staff carries you (v0.7.86: and wears a little); v0.9.1: a free walk doesn't touch the staff
        $cost = 0;
        $staffWear = calling_perk($u, 'staff_no_wear') > 0 ? null : tool_use((int)$u['id'], 'staff');   // v0.9.1: Master Wayfinder's staff never wears
    }
    $quick = q('UPDATE users SET ev_quickwalk = 0 WHERE id = ? AND ev_quickwalk = 1', [$u['id']])->rowCount() === 1;   // fireflies (v0.7.31): an instant walk, free roads too (v0.9.1 review)
    if ($quick) $cost = 0;
    if ($cost > 0 && !spend_energy((int)$u['id'], $cost)) return [false, "You need $cost energy for this walk. Rest or eat something first."];
    $gc = gnome_combat($u, true);
    [$min, $max, $scaled] = route_danger($u, $route);
    [$mins, $quickWalk] = route_walk_minutes($u, $route);   // v0.9.7: a road far below you is a quick walk
    if (setting('climate_on') === '1') {   // v0.8.9: some climates make walks into the region slower
        require_once __DIR__ . '/climate.php';
        $walk = climate_fx((int)q_val('SELECT region_id FROM locations WHERE id = ?', [$to]))['walk'] ?? 0;
        if ($walk) $mins = max(0, (int)round($mins * (1 + $walk / 100)));
    }
    db_insert('expeditions', [
        'level' => random_int($min, $max), 'scaled' => $scaled ? 1 : 0,
        'user_id' => $u['id'], 'from_id' => $here['id'], 'to_id' => $to, 'route_id' => $route['id'],
        'steps_total' => $route['steps'], 'step' => 0, 'hp' => hp_start($u, (int)$gc['max_hp']), 'max_hp' => $gc['max_hp'],
        'log' => json_encode(['🍄 You step onto the mycelium thread at ' . $here['name'] . '.' . ($quickWalk ? ' 💨 A quick walk: you know this road well.' : '')]),
        'started_at' => now(), 'arrive_at' => gmdate('Y-m-d H:i:s', time() + ($quick ? 0 : $mins * 60)),
    ]);
    return [true, '🍄 You step onto the mycelium. ' . ($quickWalk && !$quick ? '💨 Quick walk. ' : '') . ($cost ? '(−' . $cost . ' energy)' : ($roadFree ? '🧭 A Wayfinder knows the road: no energy used.' : '🦯 Your staff makes light work of it: no energy used.'))
        . ($staffWear ? ' ' . $staffWear : '')];
}

/** v1.9.0: how many log lines to keep: the usual 25, or 160 while a fight is on (the whole fight, for "Show all"). */
function exp_log_cap(array $exp): int
{
    return !empty($exp['encounter']) ? 160 : 25;
}

function exp_log(array &$exp, string $line): void
{
    $log = json_decode((string)$exp['log'], true) ?: [];
    $log[] = $line;
    $exp['log'] = json_encode(array_slice($log, -exp_log_cap($exp)));
}

function save_exp(array $exp): void
{
    if (!empty($GLOBALS['gv_hp_full'])) $exp['hp'] = (int)$exp['max_hp'];   // v2.3.5: a level up in this request healed the gnome fully
    q('UPDATE expeditions SET step = ?, hp = ?, encounter = ?, log = ?, status = ?, depth = ?, level = ?, steps_total = ?, trail = ?, chain = ? WHERE id = ?',
        [$exp['step'], $exp['hp'], $exp['encounter'], $exp['log'], $exp['status'], (int)($exp['depth'] ?? 0), (int)$exp['level'], (int)$exp['steps_total'], $exp['trail'] ?? null, ($exp['chain'] ?? '') !== '' ? $exp['chain'] : null, $exp['id']]);
    if (($exp['status'] ?? 'active') !== 'active' && in_array($exp['kind'] ?? 'walk', ['delve', 'lair'], true)) dm_scene_drop((int)$exp['id']);   // v2.0.6: the map goes when the delve ends
    if (hp_on() && in_array($exp['kind'] ?? 'walk', ['walk', 'explore', 'delve', 'lair'], true)) hp_store((int)$exp['user_id'], max(1, (int)$exp['hp']), (int)$exp['max_hp'], ($exp['status'] ?? 'active') !== 'active');   // v2.3.5: the health goes home with the gnome
}

/** v0.9.7: on an easy road (a walk next to home with the switch on) the walk's level is the most any creature may have; else 0. */
function exp_easy_cap(array $u, array $exp): int
{
    if (!easy_roads_on($u) || ($exp['kind'] ?? 'walk') !== 'walk' || empty($exp['scaled'])) return 0;
    $route = q_one('SELECT a_id, b_id, fixed FROM routes WHERE id = ?', [(int)($exp['route_id'] ?? 0)]);
    if (!$route || (int)$route['fixed'] || !(near_home($u, (int)$route['a_id']) || near_home($u, (int)$route['b_id']))) return 0;
    return max(1, (int)$exp['level']);
}

/** Landscape and difficulty of the current walk (the destination sets the scene). */
function exp_scene(array $exp): array
{
    if (in_array($exp['kind'] ?? 'walk', ['delve', 'lair'], true)) {   // v0.7.26: inside a landmark
        $at = q_one('SELECT * FROM locations WHERE id = ?', [$exp['from_id']]);
        return ['land' => (string)($at['landscape'] ?: 'forest'), 'level' => (int)$exp['level'], 'scaled' => false, 'region_id' => $at['region_id'],
            'region' => $at['region'], 'to' => $at, 'from' => $at];
    }
    if (($exp['kind'] ?? 'walk') === 'explore') {   // v0.7.25: off the path
        require_once __DIR__ . '/explore.php';
        $from = q_one('SELECT * FROM locations WHERE id = ?', [$exp['from_id']]);
        return ['land' => explore_land($exp), 'level' => (int)$exp['level'], 'scaled' => false, 'region_id' => $from['region_id'],
            'region' => $from['region'], 'to' => $from, 'from' => $from];
    }
    $to = q_one('SELECT * FROM locations WHERE id = ?', [$exp['to_id']]);
    $from = q_one('SELECT * FROM locations WHERE id = ?', [$exp['from_id']]);
    $route = q_one('SELECT * FROM routes WHERE id = ?', [$exp['route_id']]);
    $land = $to['landscape'] ?: ($from['landscape'] ?: 'grassland');
    $regionId = $to['region_id'] ?: $from['region_id'];
    $level = (int)($exp['level'] ?? 0) ?: (int)$route['level'];
    return ['land' => $land, 'level' => $level, 'scaled' => !empty($exp['scaled']), 'region_id' => $regionId,
        'region' => $to['region'], 'to' => $to, 'from' => $from];
}

/** The creature in an encounter, grown to its level if it was scaled up (v0.7.64; eased strength v0.7.74). */
function encounter_creature(array $enc): ?array
{
    $c = q_one('SELECT * FROM creatures WHERE id = ?', [(int)($enc['id'] ?? 0)]);
    if ($c && !empty($enc['lv'])) $c = scale_creature($c, (int)$enc['lv'], (int)($enc['sp'] ?? 100), (int)($enc['hpp'] ?? 100));
    return $c;
}

/** v0.7.74: $full = full strength (wild country); otherwise the strong ordinary ones are eased by the settings. */
function pick_creature(string $land, int $level, bool $allowBoss = true, bool $full = false, int $cap = 0): ?array
{   // v0.9.7: $cap > 0 = easy road: nothing above that level, no bosses
    if ($cap > 0) { $allowBoss = false; $level = min($level, $cap); }
    $all = road_rows('creatures');   // v1.9.3: read once per request
    $fits = fn($c) => $c['landscapes'] === 'any' || in_array($land, array_map('trim', explode(',', $c['landscapes'])), true);
    $hi = $cap > 0 ? $cap : $level + 2;
    // v1.4.0: the band is "level-6 .. level+2" among this landscape's ordinary creatures. If it is empty, the strongest ones up to
    // level+2 are grown to fit (never something far below; the old code used the landscape's top level and fell back to level-1 bugs)
    $bosses = array_values(array_filter($all, fn($c) => $fits($c) && $c['size'] === 'boss' && (int)$c['level'] <= $level + 8));
    if ($allowBoss && $bosses && random_int(1, 100) <= 6) {
        $b = road_pick($bosses, 'cr', 'slug');   // v1.9.3: not the same boss again and again; weather/time tags lean the pick
        if ($b) return (int)$b['level'] < $level ? scale_creature($b, $level) : $b;   // v0.7.64: bosses roam a little below their level too
    }
    $ord = array_values(array_filter($all, fn($c) => $fits($c) && $c['size'] !== 'boss' && (int)$c['level'] <= $hi));
    $pool = array_values(array_filter($ord, fn($c) => (int)$c['level'] >= $level - 6));
    if ($pool && ($pick = road_pick($pool, 'cr', 'slug'))) return $pick;
    if (!$ord) {   // nothing this weak on this landscape: take the weakest there is
        $any = array_values(array_filter($all, fn($c) => $fits($c) && $c['size'] !== 'boss'));
        if (!$any) return null;
        usort($any, fn($x, $y) => (int)$x['level'] <=> (int)$y['level']);
        return $any[0];
    }
    $best = max(array_map(fn($c) => (int)$c['level'], $ord));
    $strong = array_values(array_filter($ord, fn($c) => (int)$c['level'] >= $best - 4));
    // v0.7.74: eased growth (settings), unless this is wild country
    return scale_creature(road_pick($strong, 'cr', 'slug') ?? $strong[0], max(1, $level - random_int(0, 2)),
        $full ? 100 : (int)setting('creature_scale_percent'), $full ? 100 : (int)setting('creature_scaled_hp_percent'));
}

/** v1.9.3: a problem that fits the land, the time and the weather ("!" conds are hard: no fog puzzle in sunshine), not one of the last few. */
function pick_problem(string $land): ?array
{
    $pool = array_values(array_filter(road_rows('problems'),
        fn($p) => $p['landscapes'] === 'any' || in_array($land, array_map('trim', explode(',', $p['landscapes'])), true)));
    return $pool ? road_pick($pool, 'pr', 'slug') : null;
}

function give_local_seed(array $u, array $scene): ?string
{
    if (empty($scene['region_id'])) return null;
    $seeds = q('SELECT i.id, i.name FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id JOIN items i ON i.id = p.seed_item_id
                WHERE pr.region_id = ?', [$scene['region_id']])->fetchAll();
    if (!$seeds) return null;
    $s = $seeds[array_rand($seeds)];
    give_item((int)$u['id'], (int)$s['id'], 1);
    return '🌱 You find some ' . $s['name'] . ' and tuck them into your satchel.';
}

/** A small reward: Petals, a landscape find, or a seed of a local crop. */
function give_find(array $u, array $scene): string
{
    $uid = (int)$u['id'];
    $rich = 0;
    if (setting('climate_on') === '1' && !empty($scene['region_id'])) {   // v0.8.9: rich-find climates
        require_once __DIR__ . '/climate.php';
        $rich = max(0, climate_fx((int)$scene['region_id'])['finds'] ?? 0);
    }
    // Gathering comes first: what the landscape offers, if the gnome carries the right tool.
    $hint = '';
    if (random_int(1, 100) <= 60 && ($g = gather_on_walk($u, (string)$scene['land']))) {
        if (!str_starts_with($g, '👀')) return $g;
        $hint = $g . ' ';
    }
    $r = random_int(1, 100);
    if ($r <= 35 && ($msg = give_local_seed($u, $scene))) {
        return $hint . $msg;
    }
    if ($r <= 70) {
        $finds = LANDSCAPE_FINDS[$scene['land']] ?? [];
        if ($finds) {
            [$name] = road_pick($finds, 'fd', 0) ?? $finds[0];   // v1.9.3: not the same find three times running
            $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [slugify($name)]);
            if ($iid) {
                $two = $rich && random_int(1, 100) <= $rich;
                give_item($uid, $iid, $two ? 2 : 1);
                return $hint . '✨ You find ' . ($two ? '2 × ' : '') . $name . '.';
            }
        }
    }
    $coins = outlevel_scale((int)round((random_int(5, 15) + 2 * $scene['level']) * (1 + $rich / 100)), outlevel_percent($u, (int)$scene['level']));   // v0.7.75: outgrown areas pay fewer Petals
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    return $hint . '🪙 You find ' . $coins . ' ' . setting('currency_name') . ' glinting in the dirt.';
}

/** v2.0.79: the order a riddle's answers are shown in (a list of option numbers, shuffled once when the card is drawn). */
function road_shuffled_order(int $n): array
{
    $o = range(0, max(0, $n - 1));
    shuffle($o);
    return $o;
}

/** Move to the next step and set up what happens there. */
function next_step(array $u, array &$exp): void
{
    $scene = exp_scene($exp);
    $exp['step'] = (int)$exp['step'] + 1;
    // v1.9.3: one ambient line a space, before whatever happens (the page shows the same line above the button; same seed)
    if ($line = road_line($scene, ['seed' => road_line_seed($exp, (int)$exp['step'])])) exp_log($exp, '🍃 ' . $line);
    // v2.0.79: a chain leaves its next card for this space (before anything else); the card order of a riddle is shuffled once and kept
    if (($ch = road_chain_event($exp)) && ($exp['kind'] ?? 'walk') === 'walk') {
        $exp['chain'] = null;
        $exp['encounter'] = json_encode(['type' => 'choice', 'ev' => $ch['id']] + ($ch['kind'] === 'riddle' ? ['ord' => road_shuffled_order(count($ch['opts']))] : []));
        exp_log($exp, $ch['icon'] . ' ' . $ch['text']);
        return;
    }
    $exp['chain'] = null;
    $roll = random_int(1, 100);
    $cap = exp_easy_cap($u, $exp);   // v0.9.7
    $rb = road_roll_bands();   // v2.0.16: the split is a setting (defaults 40 / 22 / 14 / 24)
    $rr = $roll * $rb['total'];
    if ($rr <= $rb['creature'] * 100 && ($c = pick_creature($scene['land'], $scene['level'], !$scene['scaled'], false, $cap))) {
        $exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => !empty($c['_scaled']) ? (int)$c['level'] : 0, 'sp' => (int)($c['_pct'] ?? 100), 'hpp' => (int)($c['_hpp'] ?? 100),
            'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
        exp_log($exp, '⚔️ ' . (preg_match('/^[AEIOU]/i', $c['name']) ? 'An ' : 'A ') . $c['name'] . ' blocks your way!');
    } elseif ($rr <= $rb['problem'] * 100 && ($p = pick_problem($scene['land']))) {   // v1.9.4: problems 30 -> 22 ...
        $exp['encounter'] = json_encode(['type' => 'problem', 'id' => (int)$p['id']]);
        exp_log($exp, '❓ ' . $p['text']);
    } elseif ($rr > $rb['problem'] * 100 && $rr <= $rb['choice'] * 100 && ($ev = road_event_pick($scene, 'road'))) {   // ... and a little choice card takes 14 (finds 30 -> 24): no new reward layer
        $exp['encounter'] = json_encode(['type' => 'choice', 'ev' => $ev['id']] + ($ev['kind'] === 'riddle' ? ['ord' => road_shuffled_order(count($ev['opts']))] : []));
        exp_log($exp, $ev['icon'] . ' ' . $ev['text']);
    } elseif ($rr > $rb['choice'] * 100 && ($exp['kind'] ?? 'walk') === 'walk' && ($mt = road_meet_pick($scene, road_state()['ts'])) && random_int(1, 100) <= ROAD_MEET_PCT) {
        road_meet_start($u, $exp, $mt);   // v1.9.4: somebody on the road (a chat card; the only pay is the usual once-a-day chat)
    } else {
        $exp['encounter'] = null;
        exp_log($exp, give_find($u, $scene));
        rest_heal($exp);   // v1.3.0
    }
}

// ----------------------------------------------------------------- Combat

/**
 * Is the outcome already certain? Auto-resolve is only offered then.
 * Creatures never auto-hit, and nobody auto-misses, so these are exact:
 *  - certain win: the creature can't hit you even on its best roll
 *  - certain loss: it hits you on its worst roll, and even your best possible damage every turn
 *    can't finish it before its weakest hits finish you
 */
function fight_certainty(array $u, array $exp, array $c, array $enc): ?string
{
    $gc = gnome_combat($u, true);
    if ((int)$c['attack'] + 20 < $gc['ac']) return 'win';
    // You hit even on a 1, and your weakest hits finish it before its strongest hits could finish you
    if ($gc['atk'] + 1 >= (int)$c['defense']) {
        $minHit = max(1, 1 + $gc['dmg_bonus']);
        $yourRounds = (int)ceil(max(1, (int)$enc['hp']) / $minHit);
        $maxCreature = (int)$c['dmg_die'] + (int)$c['dmg_bonus'];
        if (($yourRounds - 1) * $maxCreature < (int)$exp['hp']) return 'win';
    }
    if ((int)$c['attack'] + 1 >= $gc['ac']) {
        $bestHit = $gc['dmg_die'] * 2 + $gc['dmg_bonus'] + 3;            // a crit, with the biggest bonus available
        $playerRounds = (int)ceil($enc['hp'] / max(1, $bestHit));
        $minCreature = max(1, 1 + (int)$c['dmg_bonus']);
        if (!empty($enc['bark'])) $minCreature = max(1, intdiv($minCreature, 2));
        $creatureRounds = (int)ceil((int)$exp['hp'] / $minCreature);
        if ($creatureRounds < $playerRounds) return 'lose';
    }
    return null;
}

/** v1.4.0: snacks one may eat in this fight: the setting, plus one for Brewroot. */
function snack_limit(array $u): int
{
    $n = max(0, (int)setting('fight_snacks_per_fight'));
    return $n > 0 && ($u['calling'] ?? '') === 'brewroot' ? $n + 1 : $n;
}

/** v1.4.0: how many snacks are left to eat in this fight. */
function snacks_left(array $u, array $enc): int
{
    return max(0, snack_limit($u) - (int)($enc['snacks'] ?? 0));
}

/**
 * v1.4.0: the snack dishes this gnome carries that can be eaten mid-fight: made at a kitchen (a cooking recipe of tier snack), not
 * shop-bought, and giving energy. Raw crops, meals, feasts and preserves never count. Each row has qty and heal (energy x multiplier).
 */
function fight_snacks(array $u): array
{
    $mult = max(0, (int)setting('fight_snack_heal_mult'));
    if ($mult <= 0) return [];
    $rows = q("SELECT i.id, i.name, i.effects, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
               WHERE ui.user_id = ? AND ui.qty > 0 AND i.edible = 1 AND i.slug NOT LIKE 'bought-%'
                 AND EXISTS (SELECT 1 FROM recipes r WHERE r.output_item_id = i.id AND r.category = 'cooking' AND r.tier = 'snack')
               ORDER BY i.name", [$u['id']])->fetchAll();
    $out = [];
    foreach ($rows as $r) {
        $fx = json_decode((string)$r['effects'], true) ?: [];
        $energy = dish_energy((int)($fx['energy'] ?? 0));
        if ($energy <= 0) continue;
        $out[] = ['id' => (int)$r['id'], 'name' => $r['name'], 'qty' => (int)$r['qty'], 'heal' => $energy * $mult];
    }
    return $out;
}

/** v1.4.0: [snack row, ''] if the gnome may eat this item now, else [null, why]. */
function snack_check(array $u, array $exp, array $enc, int $itemId): array
{
    if (snacks_left($u, $enc) <= 0) return [null, 'You’ve already had ' . (snack_limit($u) === 1 ? 'your snack' : 'all your snacks') . ' this fight.'];
    if ((int)$exp['hp'] >= (int)$exp['max_hp']) return [null, 'You’re not hurt. Save the snack.'];
    foreach (fight_snacks($u) as $s) if ($s['id'] === $itemId) return [$s, ''];
    return [null, 'That isn’t a snack you can eat right now.'];
}

/** v1.4.0: the Snack picker for the fight card or walk bar; '' when there is nothing to offer. $form builds a POST form around the fields. */
function fight_snack_picker(array $u, array $exp, array $enc, callable $form): string
{
    if (snacks_left($u, $enc) <= 0) return '';
    $list = fight_snacks($u);
    if (!$list) return '';
    $opts = '';
    foreach ($list as $s) $opts .= '<option value="' . $s['id'] . '">+' . $s['heal'] . '❤️ ' . e($s['name']) . ' ×' . $s['qty'] . '</option>';
    return $form('snack', '🎒 Snack', '<select name="item" class="snackpick" aria-label="Snack to eat">' . $opts . '</select>');
}

/** Player acts, then the creature (if still standing). Returns true if the fight is over. */
function combat_turn(array $u, array &$exp, string $action, int $itemId = 0): bool
{
    $enc = json_decode((string)$exp['encounter'], true);
    $c = encounter_creature($enc);
    fight_prep($enc, $c);   // v1.3.0: late-game creature health easing
    $gc = gnome_combat($u, true);
    $calling = $u['calling'] ?? '';

    // v1.4.0: a snack that can't be eaten costs nothing (no poison tick, no creature turn)
    $snack = null;
    if ($action === 'snack') {
        [$snack, $why] = snack_check($u, $exp, $enc, $itemId);
        if (!$snack) { exp_log($exp, '🎒 ' . $why); return false; }
    }

    // v2.3.8: a rare pal's active skill (Boons): once per fight, uses the turn; refused (nothing spent) when it is not along or already used
    $palAct = null;
    if (str_starts_with($action, 'palskill:')) {
        require_once __DIR__ . '/puzzle_pals.php';
        $want = substr($action, 9);
        foreach (ppal_actives($u) as $a) if ($a['key'] === $want) $palAct = $a;
        if (!$palAct) { exp_log($exp, '✨ That pal is not with you.'); return false; }
        if (in_array($want, (array)($enc['pa'] ?? []), true)) {
            exp_log($exp, '✨ ' . $palAct['pal'] . ' has already helped this fight.');
            $exp['encounter'] = json_encode($enc);
            return false;
        }
        $enc['pa'] = array_merge((array)($enc['pa'] ?? []), [$want]);
        $action = 'palskill';
    }

    $palSk = $gc['pal'] ?? [];   // v2.0.92: pal skills (mend, running, sip, ward); no dice
    $kin = (int)($palSk['kindle'] ?? 0);   // v2.3.8 Boon kindle: the calling ability one step stronger
    if (!empty($palSk['mend']) && (int)$exp['hp'] < (int)$exp['max_hp']) {
        $mend = min((int)$palSk['mend'], (int)$exp['max_hp'] - (int)$exp['hp']);
        $exp['hp'] = (int)$exp['hp'] + $mend;
        exp_log($exp, '🌱 Your pal mends you: +' . $mend . ' health.');
    }

    // Poison ticks first
    if ($enc['poison'] > 0) {
        $enc['hp'] -= 2;
        exp_log($exp, '🧪 Poison stings the ' . $c['name'] . ' for 2.');
    }

    $peaceful = false;
    if ($enc['hp'] > 0) {
        switch ($action) {
            case 'flee':
                if (!empty($enc['pn']) || flee_roll(eff_mod($u, 'nimble') + (int)($palSk['foot'] ?? 0) + (int)($palSk['slip'] ?? 0), (int)$c['level'])) {   // pn: Snare   // v1.3.0: level/3 (was /2)
                    exp_log($exp, '🏃 You slip away from the ' . $c['name'] . '.');
                    $exp['encounter'] = null;
                    return true;
                }
                exp_log($exp, '🏃 You try to run, but the ' . $c['name'] . ' cuts you off!');
                break;
            case 'snack':   // v1.4.0: eat one home-cooked snack; heals, uses the turn
                if (!give_item((int)$u['id'], (int)$snack['id'], -1)) {   // inside the caller's transaction and lock
                    exp_log($exp, '🎒 You reach for it, but it’s gone.');
                    $exp['encounter'] = json_encode($enc);
                    return false;
                }
                $heal = min((int)$exp['max_hp'] - (int)$exp['hp'], (!empty($palSk['sip']) ? (int)round((int)$snack['heal'] * (100 + (int)$palSk['sip']) / 100) : (int)$snack['heal']) + (int)($palSk['feast'] ?? 0));
                $exp['hp'] = (int)$exp['hp'] + $heal;
                $enc['snacks'] = (int)($enc['snacks'] ?? 0) + 1;
                exp_log($exp, '🎒 You gulp down the ' . $snack['name'] . ': +' . $heal . ' health.');
                break;
            case 'palskill':
                switch ($palAct['active']) {
                    case 'strike':
                        $enc['hp'] -= $palAct['value'];
                        exp_log($exp, '✨ ' . $palAct['pal'] . ' strikes the ' . $c['name'] . ' for ' . $palAct['value'] . '.');
                        break;
                    case 'shield':
                        $enc['ps'] = 2;
                        exp_log($exp, '✨ ' . $palAct['pal'] . ' shields you: the next 2 hits are ' . $palAct['value'] . ' lighter.');
                        break;
                    case 'snare':
                        $enc['pn'] = 1;
                        exp_log($exp, '✨ ' . $palAct['pal'] . ' snares the way out: your next run will work.');
                        break;
                    case 'sap':
                        $enc['hp'] -= $palAct['value'];
                        $enc['poison'] = 1;
                        exp_log($exp, '✨ ' . $palAct['pal'] . ' saps the ' . $c['name'] . ' for ' . $palAct['value'] . ' and leaves it poisoned.');
                        break;
                    case 'daze':
                        $enc['pd'] = 1;
                        exp_log($exp, '✨ ' . $palAct['pal'] . ' dazes the ' . $c['name'] . '.');
                        break;
                    case 'rouse':
                        $enc['used'] = false;
                        exp_log($exp, '✨ ' . $palAct['pal'] . ' rouses you: your ability is ready again.');
                        break;
                    case 'gust':
                        $enc['pgu'] = 3;
                        exp_log($exp, '✨ ' . $palAct['pal'] . ' whips up a gust: the ' . $c['name'] . ' will miss more.');
                        break;
                    case 'patch':
                        $heal = min($palAct['value'], (int)$exp['max_hp'] - (int)$exp['hp']);
                        $exp['hp'] = (int)$exp['hp'] + $heal;
                        exp_log($exp, '✨ ' . $palAct['pal'] . ' patches you up: +' . $heal . ' health.');
                        break;
                }
                break;
            case 'ability':
                if ($enc['used']) {
                    exp_log($exp, 'You’ve already used your ability this fight.');
                    $exp['encounter'] = json_encode($enc);
                    return false;
                }
                $enc['used'] = true;
                [$name] = CALLING_ABILITIES[$calling] ?? CALLING_ABILITIES[''];
                switch ($calling) {
                    case 'rootwarden':
                        $enc['bark'] = 3 + $kin;
                        if (calling_perk($u, 'bark_heal') > 0) {   // v0.9.1: Master Rootwardens heal 1d6 too
                            $heal = d(6);
                            $exp['hp'] = min((int)$exp['max_hp'], (int)$exp['hp'] + $heal);
                            exp_log($exp, '🌳 The bark knits your wounds: +' . $heal . ' health.');
                        }
                        exp_log($exp, '🌳 Bark Skin! Damage halved for ' . (3 + $kin) . ' rounds.');
                        break;
                    case 'bloomcaller':
                        $r = d(20) + eff_mod($u, 'charm') + 2 * $kin;
                        if ($r >= 10 + intdiv((int)$c['level'], 2)) {
                            $peaceful = true;
                            $enc['hp'] = 0;
                            exp_log($exp, '🌸 You charm the ' . $c['name'] . '. It wanders off peacefully.');
                        } else {
                            exp_log($exp, '🌸 The ' . $c['name'] . ' isn’t in the mood to be charmed.');
                        }
                        break;
                    case 'thornblade':
                        for ($i = 0; $i < 2; $i++) {
                            [, $tot, $crit] = attack_roll($gc, 0);
                            if ($tot >= (int)$c['defense']) {
                                $dmg = damage($gc, $crit, $kin);
                                $enc['hp'] -= $dmg;
                                exp_log($exp, '🗡️ Thorn Flurry hits for ' . $dmg . ($crit ? ' (critical!)' : '') . '.');
                            } else {
                                exp_log($exp, '🗡️ Thorn Flurry misses.');
                            }
                        }
                        break;
                    case 'seedkeeper':
                        $dmg = max(1, d(6) + d(6) + eff_mod($u, 'lore') + 2 * $kin);
                        $enc['hp'] -= $dmg;
                        exp_log($exp, '🍄 Spore Burst engulfs the ' . $c['name'] . ' for ' . $dmg . '.');
                        break;
                    case 'wayfinder':
                        [, $tot, $crit] = attack_roll($gc, 0, true);
                        if ($tot >= (int)$c['defense']) {
                            $dmg = damage($gc, $crit, 2 + 2 * $kin);
                            $enc['hp'] -= $dmg;
                            exp_log($exp, '🎯 Aimed Shot hits for ' . $dmg . ($crit ? ' (critical!)' : '') . '.');
                        } else {
                            exp_log($exp, '🎯 Aimed Shot just misses.');
                        }
                        break;
                    case 'brewroot':
                        $dmg = d(6) + 2 * $kin;
                        $enc['hp'] -= $dmg;
                        $enc['poison'] = 1;
                        exp_log($exp, '🧪 Bitter Brew splashes for ' . $dmg . ' and keeps burning.');
                        break;
                    default:
                        [, $tot, $crit] = attack_roll($gc, 3);
                        if ($tot >= (int)$c['defense']) {
                            $dmg = damage($gc, $crit, 3);
                            $enc['hp'] -= $dmg;
                            exp_log($exp, '💪 Gnome Pluck! You hit for ' . $dmg . '.');
                        } else {
                            exp_log($exp, '💪 Gnome Pluck... misses.');
                        }
                }
                break;
            default: // attack
                [$raw, $tot, $crit] = attack_roll($gc, empty($enc['rd']) ? (int)($palSk['first'] ?? 0) : 0);   // v2.3.8: Boon first = to-hit on round 1 only
                if ($tot >= (int)$c['defense']) {
                    $dmg = damage($gc, $crit);
                    $enc['hp'] -= $dmg;
                    exp_log($exp, '⚔️ You hit the ' . $c['name'] . ' for ' . $dmg . ($crit ? ' (critical!)' : '') . '.');
                } else {
                    exp_log($exp, '⚔️ You miss (rolled ' . $raw . ').');
                }
        }
    }

    // Creature defeated?
    if ($enc['hp'] <= 0) {
        win_fight($u, $exp, $c, $peaceful);
        return true;
    }

    // Creature's turn
    $dazed = !empty($enc['pd']) && ($c['size'] ?? '') !== 'boss';   // v2.3.8 Daze: a creature loses its turn; a boss only has its next hit halved
    $bossDaze = !empty($enc['pd']) && !$dazed;
    if (!empty($enc['pd'])) $enc['pd'] = 0;
    $gust = (int)($enc['pgu'] ?? 0) > 0 ? 2 : 0;   // Gust: -2 to hit for 3 rounds
    if ($gust) $enc['pgu'] = (int)$enc['pgu'] - 1;
    if ($dazed) {
        exp_log($exp, '💫 The ' . $c['name'] . ' is dazed and loses its turn.');
    } elseif (foe_hits((int)$c['attack'] - $gust, $gc['ac'])) {
        $dmg = foe_damage((int)$c['dmg_die'], (int)$c['dmg_bonus']);
        if ($enc['bark'] > 0) $dmg = max(1, intdiv($dmg, 2));
        if ($bossDaze) $dmg = max(1, intdiv($dmg, 2));
        if (!empty($palSk['guard']) && (int)($enc['pg'] ?? 0) < (int)$palSk['guard']) {   // v2.3.8 Boon guard: the first N hits of a fight are halved
            $dmg = max(1, intdiv($dmg, 2));
            $enc['pg'] = (int)($enc['pg'] ?? 0) + 1;
        }
        if ((int)($enc['ps'] ?? 0) > 0) {   // v2.3.8 shield active: the next 2 hits
            $dmg = max(1, $dmg - 3);
            $enc['ps'] = (int)$enc['ps'] - 1;
        }
        if (!empty($palSk['ward'])) $dmg = max(1, $dmg - (int)$palSk['ward']);
        $exp['hp'] = (int)$exp['hp'] - $dmg;
        exp_log($exp, '💥 The ' . $c['name'] . ' hits you for ' . $dmg . '.');
    } else {
        exp_log($exp, '🛡️ The ' . $c['name'] . ' misses you.');
    }
    if ($enc['bark'] > 0) $enc['bark']--;
    $enc['rd'] = (int)($enc['rd'] ?? 0) + 1;
    if (!empty($palSk['rally']) && empty($enc['pr']) && (int)$exp['hp'] > 0 && (int)$exp['hp'] * 10 <= (int)$exp['max_hp'] * 3) {   // v2.3.8 Boon rally: once a fight at 30% health or less
        $enc['pr'] = 1;
        $rh = min((int)$palSk['rally'], (int)$exp['max_hp'] - (int)$exp['hp']);
        $exp['hp'] = (int)$exp['hp'] + $rh;
        exp_log($exp, '🌱 Your pal rallies you: +' . $rh . ' health.');
    }
    $exp['encounter'] = json_encode($enc);

    if ((int)$exp['hp'] <= 0) {
        knock_out($u, $exp, $c);
        return true;
    }
    return false;
}

function win_fight(array $u, array &$exp, array $c, bool $peaceful): void
{
    $uid = (int)$u['id'];
    $ps = ppal_boons_on() ? ppal_skills($u) : [];   // v2.3.8: Boons spoils (drop chance) and lesson (Fighting XP); [] with no pals along
    $xp = $peaceful ? intdiv((int)$c['xp'], 2) : (int)$c['xp'];
    $pct = outlevel_percent($u, max((int)($exp['level'] ?? 0), (int)$c['level']));   // v0.7.75: outgrown areas give less XP (drops unchanged); judged by the area, not a weaker creature in it
    $xp = outlevel_scale($xp, $pct);
    if (!empty($ps['lesson'])) $xp = intdiv($xp * (100 + (int)$ps['lesson']), 100);
    [$xp, $lvl] = add_action_xp($uid, $xp, 'Fighting', (int)$u['level']);   // v0.9.7: action XP grows with the gnome's level (after the outgrown-area cut)
    require_once __DIR__ . '/jobs.php';
    $fx = ['size' => (string)($c['size'] ?? 'small'), 'peaceful' => $peaceful ? 1 : 0];
    job_event($uid, 'defeat', (string)$c['slug'], 1, $fx);   // v0.9.4 N9: creature slug + size (defeat counts befriended too; peaceful=0 for fights only)
    if ($peaceful) calling_event($uid, 'befriend', (string)$c['slug'], 1, $fx);
    exp_log($exp, ($peaceful ? '🌸' : '🏆') . ' The ' . $c['name'] . ' is ' . ($peaceful ? 'befriended' : 'defeated') . '! +' . $xp . ' XP' . outlevel_note($pct));
    if ($lvl) exp_log($exp, '🎉 Gnome level ' . $lvl . '! New stat points to spend.');
    if (unlock_entries($uid, 'creature:' . $c['slug'])) {
        exp_log($exp, '📖 New Almanac page: ' . $c['name'] . '!');
    }
    if (!$peaceful) {
        $scene = exp_scene($exp);
        $luckBonus = max(0, luck_mod($u)) * 2;
        foreach (q('SELECT * FROM creature_drops WHERE creature_id = ?', [$c['id']])->fetchAll() as $dr) {
            if (random_int(1, 100) > min(100, (int)$dr['chance'] + $luckBonus + (int)($ps['spoils'] ?? 0))) continue;
            if ($dr['special'] === 'seed') {
                exp_log($exp, give_local_seed($u, $scene) ?? give_find($u, $scene));
            } elseif ($dr['special'] === 'guide') {
                $rCode = $scene['region_id'] ? (string)q_val('SELECT code FROM regions WHERE id = ?', [$scene['region_id']]) : '';
                $gid = $rCode ? (int)q_val('SELECT id FROM items WHERE slug = ?', [guide_item_slug($rCode)]) : 0;
                if ($gid) {
                    give_item($uid, $gid, 1);
                    exp_log($exp, '📗 The ' . $c['name'] . ' was guarding a Gardening Guide!');
                }
            } elseif ($dr['item_id']) {
                $qty = calling_perk($u, 'drop_double') > 0 ? 2 : 1;   // v0.9.1: Master Thornblades get double drops
                give_item($uid, (int)$dr['item_id'], $qty);
                exp_log($exp, '🎁 Loot: ' . ($qty > 1 ? $qty . ' × ' : '') . q_val('SELECT name FROM items WHERE id = ?', [$dr['item_id']]));
            }
        }
    }
    foreach (check_milestones($uid) as $m) exp_log($exp, $m);
    if (calling_perk($u, 'full_heal') > 0 && (int)$exp['hp'] < (int)$exp['max_hp']) {   // v0.9.1: Master Thornblades heal fully after a win
        $exp['hp'] = (int)$exp['max_hp'];
        exp_log($exp, '🗡️ You shake it off: full health.');
    }
    $exp['encounter'] = null;
}

function knock_out(array $u, array &$exp, array $c): void
{
    $from = q_one('SELECT * FROM locations WHERE id = ?', [$exp['from_id']]);
    exp_log($exp, '💫 The ' . $c['name'] . ' knocks you flat. You wake up back in ' . $from['name'] . ', a bit sore but with all your things.');
    $exp['status'] = 'ko';
    $exp['encounter'] = null;
    if (hp_on()) $exp['hp'] = max(1, (int)ceil((int)$exp['max_hp'] * hp_pct('hp_ko_percent', 50) / 100));   // v2.3.5: you wake up hurt
    q('UPDATE users SET location_id = ?, location = ?, arrived_at = ?, energy = CASE WHEN energy > 2 THEN energy - 2 ELSE 0 END WHERE id = ?',
        [$from['id'], $from['region'], now(), $u['id']]);
    unlock_entries((int)$u['id'], 'creature:' . $c['slug']);   // you still saw it
}

/** Fight to the end automatically. Only allowed when the outcome is certain. */
function auto_resolve(array $u, array &$exp): void
{
    for ($i = 0; $i < 200; $i++) {
        if (combat_turn($u, $exp, 'attack')) return;
    }
}

// ----------------------------------------------------------------- v1.3.0: odds, fight on, rest

/** v1.3.0: the percent of its health a creature of this level and size has in a fight (100 for the early game). */
function creature_hp_percent(array $c): int
{
    $lvl = (int)($c['level'] ?? 1);
    $from = (int)setting('creature_hp_ramp_from');
    $to = max($from + 1, (int)setting('creature_hp_ramp_to'));
    if ($lvl <= $from) return 100;
    $late = 100;
    foreach (explode(',', (string)setting('creature_hp_late_percent')) as $kv) {
        [$k, $v] = array_pad(explode(':', trim($kv), 2), 2, '');
        if (trim($k) === (string)($c['size'] ?? '') && is_numeric($v)) $late = max(10, min(100, (int)$v));
    }
    return max(10, (int)round(100 - (100 - $late) * min(1, ($lvl - $from) / ($to - $from))));
}

/** v1.3.0: once per fight, ease the creature's health (stored in the encounter, no schema change). Safe to call again; the views call it on a copy. */
function fight_prep(array &$enc, array $c): void
{
    if (isset($enc['hs'])) return;
    $pct = creature_hp_percent($c);
    $enc['hs'] = $pct;
    if ($pct >= 100) return;
    $enc['max'] = combat_pct((int)$enc['max'], $pct);
    $enc['hp'] = (int)$enc['hp'] > 0 ? min($enc['max'], combat_pct((int)$enc['hp'], $pct)) : 0;
}

/** v1.3.0: how many of the d20 rolls reach $need with a +$bonus (never auto-hit or auto-miss), as a 0-20 count. */
function rolls_reaching(int $need, int $bonus): int
{
    return max(0, min(20, 21 - ($need - $bonus)));
}

/** v1.3.0: the numbers behind the fight card's odds line. One place, used by the page and the walk bar. */
function fight_odds(array $u, array $exp, array $enc): array
{
    $c = encounter_creature($enc);
    fight_prep($enc, $c);
    $gc = gnome_combat($u, true);
    $need = max(1, (int)$c['defense'] - $gc['atk']);
    $hitN = max(0, min(20, 21 - $need));
    $hit = $hitN / 20;
    $critN = max(0, min(20, 21 - max($gc['crit_from'], $need)));   // a natural crit roll that also hits
    $critP = $critN / 20 + ((float)$gc['luck_crit'] / 100) * ($hit - $critN / 20);
    $half = ($gc['dmg_die'] + 1) / 2;
    $avg = $half + $gc['dmg_bonus'] + ($hit > 0 ? $critP / $hit * $half : 0);   // average damage of a hit, crit chance included
    $dpr = $hit * $avg;
    $lo = max(1, 1 + (int)$c['dmg_bonus']);
    $hi = max(1, (int)$c['dmg_die'] + (int)$c['dmg_bonus']);
    if (!empty($enc['bark'])) { $lo = max(1, intdiv($lo, 2)); $hi = max(1, intdiv($hi, 2)); }
    $foe = rolls_reaching($gc['ac'], (int)$c['attack']) / 20;
    $rounds = $dpr > 0 ? (int)ceil(max(1, (int)$enc['hp']) / $dpr) : 99;
    return ['hit' => (int)round($hit * 100), 'foe_hit' => (int)round($foe * 100), 'lo' => $lo, 'hi' => $hi, 'rounds' => min(99, $rounds),
        'text' => 'You hit ' . (int)round($hit * 100) . '% · It hits you ' . (int)round($foe * 100) . '% for ' . ($lo === $hi ? $lo : $lo . '–' . $hi) . ' · about ' . min(99, $rounds) . ' round' . ($rounds === 1 ? '' : 's')];
}

/** v1.3.0: the last few rounds of the current fight, oldest first (a round ends with the creature's turn).
 *  v1.9.0: $rounds = 0 gives the whole current fight (back to the line that started it). */
function fight_recent_rounds(array $exp, int $rounds = 3): array
{
    $log = json_decode((string)$exp['log'], true) ?: [];
    $out = [];
    $ends = 0;
    for ($i = count($log) - 1; $i >= 0 && ($rounds === 0 || count($out) < 8); $i--) {
        $line = (string)$log[$i];
        if (preg_match('/^(🏆|🌸|🏃|💫|❓|🎉|📖|🎁)|blocks your way/u', $line)) break;
        if ($rounds > 0 && preg_match('/^(💥|🛡️) /u', $line)) {
            if ($ends >= $rounds) break;
            $ends++;
        }
        array_unshift($out, $line);
    }
    return $out;
}

/** v1.3.0: the odds line and the last three rounds, as one block for both fight views.
 *  v1.9.0: $showAll adds a "Show all (N)" fold with the whole fight so far in a scrollable box (the walk bar keeps it short). */
function fight_card_extra(array $u, array $exp, array $enc, int $nRounds = 3, bool $showAll = false): string
{
    $o = fight_odds($u, $exp, $enc);
    $html = '<p class="fodds" title="Your chance to hit, its chance to hit you and its damage, and roughly how long the fight lasts.">' . e($o['text']) . '</p>';
    $rounds = fight_recent_rounds($exp, $nRounds);
    if ($rounds) $html .= '<ul class="frounds" aria-label="Last rounds">' . implode('', array_map(fn($l) => '<li>' . e($l) . '</li>', $rounds)) . '</ul>';
    if ($showAll) {
        $all = fight_recent_rounds($exp, 0);
        if (count($all) > count($rounds)) {
            $html .= '<details class="trekall fightall"><summary>Show all (' . count($all) . ')</summary><div class="tkall" tabindex="0" role="log" aria-label="Whole fight log"><ul class="frounds">'
                . implode('', array_map(fn($l) => '<li>' . e($l) . '</li>', $all)) . '</ul></div></details>';
        }
    }
    return $html;
}

/** v1.3.0: Fight on is offered while the gnome is at half health or better. */
function can_fight_on(array $exp): bool
{
    return (int)$exp['hp'] * 2 >= (int)$exp['max_hp'];
}

/** v1.3.0: keep attacking (never the ability) until the fight ends, health drops under half, or 30 rounds. Caller holds the transaction.
 *  v1.4.0: also notes every round (log lines, foe and gnome health after) for assets/fighton.js to replay; the server stays the only judge. */
function fight_on(array $u, array &$exp): void
{
    if (!can_fight_on($exp)) { exp_log($exp, '😮‍💨 You’re too hurt to fight on blindly. Choose each move.'); return; }
    $enc0 = json_decode((string)$exp['encounter'], true) ?: [];
    $c = encounter_creature($enc0);
    fight_prep($enc0, $c);
    $foe = max(0, (int)($enc0['hp'] ?? 0));
    $rep = ['exp' => (int)$exp['id'], 't' => time(), 'foe' => (string)($c['name'] ?? 'Creature'), 'lv' => (int)($c['level'] ?? 1),
            'ico' => creature_icon((string)($c['name'] ?? ''), (string)($c['size'] ?? 'small')), 'me' => gnome_name($u),
            'fmax' => max(1, (int)($enc0['max'] ?? $foe)), 'f0' => $foe, 'mmax' => max(1, (int)$exp['max_hp']), 'm0' => max(0, (int)$exp['hp']),
            'end' => false, 'rounds' => []];
    $orig = json_decode((string)$exp['log'], true) ?: [];
    $all = $orig;
    $stopLine = null;
    for ($i = 0; $i < 30; $i++) {
        $exp['log'] = '[]';   // v1.4.0: only this round's lines land here; merged back below
        $over = combat_turn($u, $exp, 'attack');
        $new = json_decode((string)$exp['log'], true) ?: [];
        $all = array_merge($all, $new);
        $mine = max(0, (int)$exp['hp']);
        $encNow = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
        $foe = $encNow ? max(0, (int)($encNow['hp'] ?? 0)) : ($mine > 0 ? 0 : $foe);
        $lines = array_values(array_filter($new, fn($l) => preg_match('/^(⚔️|💥|🛡️|🧪|🗡️)/u', (string)$l)));
        $rep['rounds'][] = ['l' => $lines, 'f' => $foe, 'm' => $mine, 'c' => (bool)preg_grep('/critical/u', $lines)];
        if ($over) { $rep['end'] = true; break; }
        if (!can_fight_on($exp)) {
            $all[] = '⏩ You stop fighting on: you’re under half health (' . $mine . '/' . (int)$exp['max_hp'] . ').';
            break;
        }
    }
    if (!$over) {
        if ($i >= 30) $all[] = '⏩ You pause after 30 rounds to catch your breath.';
    }
    $exp['log'] = json_encode(array_slice($all, -exp_log_cap($exp)));
    if ($rep['rounds']) $_SESSION['fight_replay'] = $rep;
}

/** v1.4.0: the replay of the last Fight on for this expedition (once, if fresh), or null. */
function fight_replay_take(int $expId): ?array
{
    $r = $_SESSION['fight_replay'] ?? null;
    if (!is_array($r) || (int)($r['exp'] ?? 0) !== $expId) return null;
    unset($_SESSION['fight_replay']);
    return time() - (int)($r['t'] ?? 0) <= 30 && !empty($r['rounds']) ? $r : null;
}

/** v1.4.0: a hidden stage that assets/fighton.js plays (rounds one by one) and then removes; without JS it just stays hidden. */
function fight_replay_stage(int $expId): string
{
    $r = fight_replay_take($expId);
    if (!$r) return '';
    $side = fn(string $cls, string $ico, string $name, int $v, int $max) => '<div class="fo-side ' . $cls . '"><span class="fo-ico" aria-hidden="true">' . $ico . '</span> <b>' . e($name) . '</b><br>'
        . '<meter min="0" max="' . $max . '" low="' . (int)ceil($max / 3) . '" value="' . $v . '"></meter> <span class="fo-n">❤️ ' . $v . '/' . $max . '</span></div>';
    $data = ['f0' => $r['f0'], 'fmax' => $r['fmax'], 'm0' => $r['m0'], 'mmax' => $r['mmax'], 'rounds' => $r['rounds']];
    return '<div class="fostage' . (!empty($r['end']) ? ' fo-end' : '') . '" hidden data-replay="' . e((string)json_encode($data, JSON_UNESCAPED_UNICODE)) . '">'
        . $side('me', '🧙', (string)$r['me'], (int)$r['m0'], (int)$r['mmax'])   // you first, on the left like your gnome on the stage
        . $side('foe', (string)$r['ico'], $r['foe'] . ' (lv ' . (int)$r['lv'] . ')', (int)$r['f0'], (int)$r['fmax'])
        . '<ul class="fo-lines" aria-hidden="true"></ul><p class="fo-hint">Tap to skip</p></div>';
}

/** v1.3.0: a quiet step (a find or nothing) lets the gnome catch a breath: heal a percent of max health and note it on the step's log line. */
function rest_heal(array &$exp): void
{
    $pct = max(0, min(50, (int)setting('walk_rest_heal_percent')));
    $max = (int)$exp['max_hp'];
    if ($pct <= 0 || (int)$exp['hp'] >= $max || (int)$exp['hp'] <= 0) return;
    $n = min($max - (int)$exp['hp'], max(1, (int)round($max * $pct / 100)));
    $exp['hp'] = (int)$exp['hp'] + $n;
    $log = json_decode((string)$exp['log'], true) ?: [];
    if ($log) {
        $log[count($log) - 1] .= ' +' . $n . ' ❤️';
        $exp['log'] = json_encode(array_slice($log, -exp_log_cap($exp)));
    }
}

/** v1.3.0: after an explore step, rest-heal if it was a step (its header line says "danger level") that ended with nothing waiting. */
function rest_after_explore(array &$exp, int $logCountBefore): void
{
    if ($exp['status'] !== 'active' || $exp['encounter']) return;
    $log = json_decode((string)$exp['log'], true) ?: [];
    if (count($log) <= $logCountBefore) return;
    foreach (array_slice($log, $logCountBefore) as $l) {
        if (str_contains((string)$l, 'danger level')) { rest_heal($exp); return; }
    }
}

// ----------------------------------------------------------------- Problems

function solve_problem(array $u, array &$exp, int $option): void
{
    $enc = json_decode((string)$exp['encounter'], true);
    $p = q_one('SELECT * FROM problems WHERE id = ?', [$enc['id']]);
    $opts = json_decode((string)$p['options'], true) ?: [];
    if (!isset($opts[$option])) return;
    $o = $opts[$option];
    $o['dc'] = (int)$o['dc'] + (int)($enc['dc_bonus'] ?? 0);   // harder further off the path (v0.7.25)
    $stat = isset(GNOME_STATS[$o['stat']]) ? $o['stat'] : 'grit';
    $roll = d(20);
    $total = $roll + eff_mod($u, $stat) + calling_perk($u, 'wonder_bonus');   // v0.9.1: Seedkeepers read puzzles better
    $name = GNOME_STATS[$stat][0];
    if ($total >= (int)$o['dc']) {
        $pct = outlevel_percent($u, (int)$exp['level']);   // v0.7.75: outgrown areas give less XP
        $xp = outlevel_scale((int)$o['dc'], $pct);
        add_xp((int)$u['id'], $xp);
        exp_log($exp, '✅ ' . $o['label'] . ': success! (' . $name . ' ' . $total . ' vs ' . $o['dc'] . ') +' . $xp . ' XP' . outlevel_note($pct));
        if (random_int(1, 100) <= 35) exp_log($exp, give_find($u, exp_scene($exp)));
    } else {
        q('UPDATE users SET energy = CASE WHEN energy > 1 THEN energy - 1 ELSE 0 END WHERE id = ?', [$u['id']]);
        exp_log($exp, '❌ ' . $o['label'] . ': not quite (' . $name . ' ' . $total . ' vs ' . $o['dc'] . '). It costs you 1 energy, but you get through in the end.');
    }
    $exp['encounter'] = null;
}

/** Finish the walk: arrive at the destination, unlock its Almanac page. */
function arrive(array $u, array &$exp): void
{
    $to = q_one('SELECT * FROM locations WHERE id = ?', [$exp['to_id']]);
    q('UPDATE users SET location_id = ?, location = ?, arrived_at = ? WHERE id = ?', [$to['id'], $to['region'], now(), $u['id']]);
    $exp['status'] = 'done';
    exp_log($exp, '🏡 You arrive at ' . $to['name'] . '.');
    if ($amb = road_arrival_line($to)) exp_log($exp, $amb);   // v1.9.3: the stop's own ambience for this time of day
    if (unlock_entries((int)$u['id'], 'village:' . $to['slug'])) {
        exp_log($exp, '📖 New Almanac page: ' . $to['name'] . '!');
    }
    if ($to['region_id'] && record_region_visit((int)$u['id'], (int)$to['region_id'])) {   // v0.7.43: a new region reached on foot
        $rg = q_one('SELECT gnomish_name FROM regions WHERE id = ?', [$to['region_id']]);
        exp_log($exp, '🗺️ You’ve reached ' . ($rg['gnomish_name'] ?? 'a new region') . ' for the first time! You can now travel straight here from anywhere.');
        add_xp((int)$u['id'], 10 + location_min_level((int)$to['id']));
    }
    $routeKind = (string)q_val('SELECT kind FROM routes WHERE id = ?', [$exp['route_id']]); calling_event((int)$u['id'], 'arrive', (string)$to['slug'], 1, ['kind' => (string)$to['kind']]); if ($routeKind !== '') calling_event((int)$u['id'], 'walk', $routeKind, 1, ['kind' => $routeKind]);   // v0.9.4 N1: one event per leg
    $walkXp = 2 + intdiv((int)q_val('SELECT level FROM routes WHERE id = ?', [$exp['route_id']]), 2);
    add_xp((int)$u['id'], outlevel_scale($walkXp, outlevel_percent($u, (int)($exp['level'] ?? 1))));   // v0.7.75: outgrown areas give less XP
    foreach (check_milestones((int)$u['id']) as $m) exp_log($exp, $m);
}
