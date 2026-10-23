<?php
declare(strict_types=1);

/**
 * The gnome: stats, callings, meals, gnome level and garden level.
 * Stats work like tabletop RPGs: 10 is average, and every 2 points above 10 gives +1 modifier.
 */

const GNOME_STATS = [
    'grit' => ['Grit', '💪', 'Strength and stubbornness.',
        'Each modifier point gives a 5% chance of a heavier harvest (+1).',
        'Melee damage, and moving or breaking obstacles.'],
    'nimble' => ['Nimble', '🤸', 'Quick, careful hands and feet.',
        'Each modifier point gives a 4% chance that a garden action costs no energy.',
        'Dodging attacks, sneaking past trouble, climbing.'],
    'hardiness' => ['Hardiness', '🛡️', 'Toughness and stamina.',
        'Each modifier point adds 1 to your maximum energy.',
        'Health in fights; shrugging off poison, heat and cold.'],
    'lore' => ['Lore', '📚', 'Book-learning and plant wisdom.',
        'Each modifier point makes plant knowledge grow 10% faster.',
        'Solving riddles and puzzles, reading old signs and maps.'],
    'sense' => ['Sense', '👁️', 'Awareness of the world around you.',
        'Each modifier point adds 3% to your seed-saving chance.',
        'Spotting traps, hidden paths and ambushes; finding rare things.'],
    'charm' => ['Charm', '🌼', 'Warmth, wit and a winning smile.',
        'Each modifier point gives 2% better prices when buying and selling.',
        'Talking your way out of trouble, making friends with NPCs.'],
    'luck' => ['Luck', '🍀', 'The universe smiling on you. Luck works a little differently: it doesn’t use a modifier, it gives a straight percentage.',
        'Every 2 points of Luck adds a small % chance of an extra harvest (set in Game settings; Luck 10 = 0.25% by default). Luck also nudges rare finds your way.',
        'Critical hits, lucky escapes, and rare finds on the road.'],
];

const CALLINGS = [
    'rootwarden' => ['Rootwarden', 'Brown', '#7a5634', 'Keeper of deep soil.',
        'I: no-till grades +25%, checkpoints last 3 more days, +5 health · II: grades +50%, 7 more days, mulching sheets costs 1 less energy, +10 health, +2 armour · III: grades +75%, mulch never wears down, no-till beds never slip, S-grade beds grow 15% faster, Bark Skin heals too.',   // v0.9.1: tiers
        'Tank: lots of health and Bark Skin to shield allies.'],
    'bloomcaller' => ['Bloomcaller', 'Pink', '#d4669b', 'Friend of every flower and bee.',
        'I: flowers yield +1, pollinators come 15% more · II: pollinators always come, cut flowers sell 25% more · III: 3 free Water alls per garden each day, townsfolk always like a flower gift.',   // v0.9.1: tiers
        'Support: heals and cheers allies, can charm enemies into leaving.'],
    'thornblade' => ['Thornblade', 'Red', '#b03a2e', 'Defender of the garden.',
        'I: weeding is free, +2 attack · II: weeds grow half as fast, +1 damage, more critical hits · III: no weeds in your beds, full health after each won fight, creatures drop double parts.',   // v0.9.1: tiers
        'Fighter: hits hard, with more critical hits.'],
    'seedkeeper' => ['Seedkeeper', 'Blue', '#3a6fb0', 'Scholar of seeds and stories.',
        'I: seed saving like annuals for perennials, knowledge +20%, +2 on wonder puzzles · II: knowledge +50%, saved seeds come in pairs · III: every harvest saves a seed, unstudied plants are half as slow and weak.',   // v0.9.1: tiers
        'Scholar: best at riddles and puzzles; casts spore magic.'],
    'wayfinder' => ['Wayfinder', 'Green', '#3f7d2c', 'Wanderer of the wide world.',
        'I: spot hidden places +25%, 30% chance of a seed when you fast travel · II: fast travel 25% cheaper and 1 less energy, Gather here sometimes costs no energy · III: free seed on every fast travel, fast travel free, road walks cost no energy, your staff never wears.',   // v0.9.1: tiers
        'Explorer: finds hidden paths and rare encounters; fights with a sling.'],
    'brewroot' => ['Brewroot', 'Purple', '#6d4a9a', 'Cook, brewer and potion-maker.',
        'I: meal buffs last 25% longer · II: buffs 50% longer, 40% chance of an extra dish when cooking · III: cooking takes half the time and you get an extra pot, home-cooked food gives 20% more energy, two meal buffs at once.',   // v0.9.1: tiers; v0.9.4: pots
        'Alchemist: poisons, and one more home-cooked snack mid-fight (to heal) than other gnomes.'],   // v1.4.0: was "using items mid-fight" (no such thing); now matches the Snack action
];

/** v0.9.1: calling perks per tier (cumulative: every tier lists every key). Read with calling_perk(). */
const CALLING_TIERS = [
    'rootwarden' => [
        1 => ['grade_pct' => 25, 'checkpoint_days' => 3, 'sheet_discount' => 0, 'mulch_forever' => 0, 'never_slip' => 0, 's_grade_growth' => 0, 'hp_bonus' => 5, 'def_bonus' => 0, 'bark_heal' => 0],
        2 => ['grade_pct' => 50, 'checkpoint_days' => 7, 'sheet_discount' => 1, 'mulch_forever' => 0, 'never_slip' => 0, 's_grade_growth' => 0, 'hp_bonus' => 10, 'def_bonus' => 2, 'bark_heal' => 0],
        3 => ['grade_pct' => 75, 'checkpoint_days' => 7, 'sheet_discount' => 1, 'mulch_forever' => 1, 'never_slip' => 1, 's_grade_growth' => 15, 'hp_bonus' => 10, 'def_bonus' => 2, 'bark_heal' => 1],
    ],
    'bloomcaller' => [
        1 => ['flower_extra' => 1, 'pollinator_bonus' => 15, 'flower_sell_pct' => 0, 'free_water_all' => 0, 'flower_liked_gift' => 0],
        2 => ['flower_extra' => 1, 'pollinator_bonus' => 100, 'flower_sell_pct' => 25, 'free_water_all' => 0, 'flower_liked_gift' => 0],
        3 => ['flower_extra' => 1, 'pollinator_bonus' => 100, 'flower_sell_pct' => 25, 'free_water_all' => 3, 'flower_liked_gift' => 1],
    ],
    'thornblade' => [
        1 => ['free_weeding' => 1, 'weed_slow' => 1, 'no_weeds' => 0, 'atk_bonus' => 2, 'dmg_bonus' => 0, 'crit_from' => 20, 'full_heal' => 0, 'drop_double' => 0],
        2 => ['free_weeding' => 1, 'weed_slow' => 2, 'no_weeds' => 0, 'atk_bonus' => 2, 'dmg_bonus' => 1, 'crit_from' => 19, 'full_heal' => 0, 'drop_double' => 0],
        3 => ['free_weeding' => 1, 'weed_slow' => 2, 'no_weeds' => 1, 'atk_bonus' => 2, 'dmg_bonus' => 1, 'crit_from' => 19, 'full_heal' => 1, 'drop_double' => 1],
    ],
    'seedkeeper' => [
        1 => ['knowledge_pct' => 20, 'perennial_seed_full' => 1, 'seed_pairs' => 0, 'seed_always' => 0, 'unstudied_half' => 0, 'wonder_bonus' => 2],
        2 => ['knowledge_pct' => 50, 'perennial_seed_full' => 1, 'seed_pairs' => 1, 'seed_always' => 0, 'unstudied_half' => 0, 'wonder_bonus' => 2],
        3 => ['knowledge_pct' => 50, 'perennial_seed_full' => 1, 'seed_pairs' => 1, 'seed_always' => 1, 'unstudied_half' => 1, 'wonder_bonus' => 2],
    ],
    'wayfinder' => [
        1 => ['spot_pct' => 25, 'travel_seed_pct' => 30, 'fast_travel_discount' => 0, 'fast_travel_energy_minus' => 0, 'gather_free_pct' => 0, 'free_walks' => 0, 'staff_no_wear' => 0, 'atk_nimble' => 1],
        2 => ['spot_pct' => 25, 'travel_seed_pct' => 30, 'fast_travel_discount' => 25, 'fast_travel_energy_minus' => 1, 'gather_free_pct' => 25, 'free_walks' => 0, 'staff_no_wear' => 0, 'atk_nimble' => 1],
        3 => ['spot_pct' => 25, 'travel_seed_pct' => 100, 'fast_travel_discount' => 100, 'fast_travel_energy_minus' => 99, 'gather_free_pct' => 25, 'free_walks' => 1, 'staff_no_wear' => 1, 'atk_nimble' => 1],
    ],
    'brewroot' => [
        1 => ['buff_pct' => 25, 'extra_dish_pct' => 0, 'meal_energy_pct' => 0, 'cook_time_pct' => 0, 'extra_pot' => 0, 'two_buffs' => 0],
        2 => ['buff_pct' => 50, 'extra_dish_pct' => 40, 'meal_energy_pct' => 0, 'cook_time_pct' => 0, 'extra_pot' => 0, 'two_buffs' => 0],
        3 => ['buff_pct' => 50, 'extra_dish_pct' => 40, 'meal_energy_pct' => 20, 'cook_time_pct' => 50, 'extra_pot' => 1, 'two_buffs' => 1],
    ],
];

/**
 * v0.9.1: 0 with no calling, else 1-3 by gnome level.
 * v0.9.4: min(level tier, 1 + calling_qt): tiers II and III also need the mentor's chapter (setting calling_quests; off = level only).
 * Any user row with calling and level. calling_qt comes from the row, else (row has an id) from the database once per request;
 * a row with neither is judged by level alone.
 */
function calling_tier(array $u): int
{
    if (empty($u['calling']) || !isset(CALLING_TIERS[$u['calling']])) return 0;
    $lv = (int)($u['level'] ?? 1);
    if ($lv >= (int)setting('calling_tier3_level')) $tier = 3;
    elseif ($lv >= (int)setting('calling_tier2_level')) $tier = 2;
    else return $lv >= (int)setting('calling_level') ? 1 : 0;
    if (setting('calling_quests') !== '1') return $tier;
    if (isset($u['calling_qt'])) $qt = (int)$u['calling_qt'];
    elseif (!empty($u['id'])) $qt = calling_qt_cached((int)$u['id']);
    else return $tier;
    return min($tier, 1 + max(0, $qt));
}

/** v0.9.4: calling_qt for a user id, read once per request (pass $forget = true after it changes). */
function calling_qt_cached(int $uid, bool $forget = false): int
{
    static $cache = [];
    if ($forget) { unset($cache[$uid]); return 0; }
    return $cache[$uid] ??= (int)q_val('SELECT calling_qt FROM users WHERE id = ?', [$uid]);
}

/** v0.9.1: a perk's value for this gnome's calling and tier, or $default. */
function calling_perk(array $u, string $key, int $default = 0): int
{
    $t = calling_tier($u);
    return $t ? (int)(CALLING_TIERS[$u['calling']][$t][$key] ?? $default) : $default;
}

function calling_tier_name(int $tier): string
{
    return [1 => 'Apprentice', 2 => 'Journeyman', 3 => 'Master'][$tier] ?? '';
}

function stat_mod(int $value): int
{
    return intdiv($value - 10 - ($value < 10 ? 1 : 0), 2);   // 10-11 = +0, 12-13 = +1, 8-9 = -1
}

function active_buff(array $u): array
{
    $out = [];
    foreach ([['buff', 'buff_until'], ['buff2', 'buff2_until']] as [$b, $until]) {   // v0.9.1: a second slot for Brewroot masters
        if (empty($u[$b]) || ts_gnome($u[$until] ?? null) <= time()) continue;
        foreach ((json_decode((string)$u[$b], true) ?: []) as $stat => $n) $out[$stat] = (int)($out[$stat] ?? 0) + (int)$n;
    }
    return $out;
}

/** v0.7.90: everything boosting this gnome right now: [icon, name, what it does, seconds left], soonest to end last. */
function active_effects(array $u): array
{
    $out = [];
    $left = fn(?string $dt) => ts_gnome($dt) - time();
    $stats = fn(array $b) => implode(', ', array_map(fn($s, $n) => GNOME_STATS[$s][0] . ' +' . (int)$n, array_keys($b), $b));
    foreach ([['buff', 'buff_until'], ['buff2', 'buff2_until']] as [$bk, $uk]) {   // v0.9.1: both meal slots
        if (empty($u[$bk]) || $left($u[$uk] ?? null) <= 0) continue;
        $b = array_filter(json_decode((string)$u[$bk], true) ?: [], fn($s) => isset(GNOME_STATS[$s]), ARRAY_FILTER_USE_KEY);
        if ($b) $out[] = ['🍽️', 'Meal', $stats($b), $left($u[$uk])];
    }
    if (!empty($u['ev_stat']) && isset(GNOME_STATS[$u['ev_stat']]) && $left($u['ev_until'] ?? null) > 0) $out[] = ['🍀', 'A lucky moment', $stats([$u['ev_stat'] => $u['ev_amt']]), $left($u['ev_until'])];
    if (!empty($u['town_stat']) && isset(GNOME_STATS[$u['town_stat']]) && $left($u['town_until'] ?? null) > 0) $out[] = ['🏘️', 'Town outing', $stats([$u['town_stat'] => $u['town_amt']]), $left($u['town_until'])];
    if ($left($u['ev_gather_until'] ?? null) > 0) $out[] = ['🌈', 'Rainbow', 'Double gathering', $left($u['ev_gather_until'])];
    if ($left($u['ev_sale_until'] ?? null) > 0) $out[] = ['🐓', 'Shop sale', '20% off in every shop', $left($u['ev_sale_until'])];
    usort($out, fn($a, $b) => $b[3] <=> $a[3]);
    return $out;
}

/** Seconds as "1h 20m" / "12m" / "40s", without needing garden_logic.php. */
function effect_time(int $s): string
{
    if ($s >= 3600) return intdiv($s, 3600) . 'h' . ($s % 3600 >= 60 ? ' ' . intdiv($s % 3600, 60) . 'm' : '');
    return $s >= 60 ? intdiv($s, 60) . 'm' : max(1, $s) . 's';
}

function ts_gnome(?string $dt): int
{
    return $dt ? (int)strtotime($dt . ' UTC') : 0;
}

/** A stat including the current meal's buff. */
function eff_stat(array $u, string $stat): int
{
    $ev = (!empty($u['ev_stat']) && $u['ev_stat'] === $stat && ts_gnome($u['ev_until'] ?? null) > time()) ? (int)$u['ev_amt'] : 0;   // a random event's little boost
    $tw = (!empty($u['town_stat']) && $u['town_stat'] === $stat && ts_gnome($u['town_until'] ?? null) > time()) ? (int)$u['town_amt'] : 0;   // a town drink or outing (v0.7.20)
    return (int)($u['stat_' . $stat] ?? 10) + (int)(active_buff($u)[$stat] ?? 0) + $ev + $tw;
}

/** Luck as a straight percentage: every 2 points = setting luck_percent_per_2 (default 0.05%). */
function luck_percent(array $u): float
{
    return eff_stat($u, 'luck') / 2 * max(0.0, (float)setting('luck_percent_per_2'));
}

/** Roll a luck chance. */
function luck_roll(array $u): bool
{
    return random_int(1, 1000000) <= (int)round(luck_percent($u) * 10000);
}

function eff_mod(array $u, string $stat): int
{
    return stat_mod(eff_stat($u, $stat));
}

function is_calling(array $u, string $calling): bool
{
    return ($u['calling'] ?? null) === $calling;
}

function max_energy(array $u): int
{
    // v0.7.23: 10 at level 1, +5 a level (settings), +1 per Hardiness modifier point
    $lvl = max(1, (int)($u['level'] ?? 1));
    return max(5, (int)setting('max_energy') + (int)setting('energy_per_level') * ($lvl - 1) + eff_mod($u, 'hardiness'));
}

function food_bonus(int $uid): array
{
    $out = [];
    foreach (q('SELECT stat, amount FROM user_food_bonus WHERE user_id = ?', [$uid])->fetchAll() as $r) {
        $out[$r['stat']] = (int)$r['amount'];
    }
    return $out;
}

function xp_for_level(int $level): int
{
    // gardener: L2 = 100, L3 = 300, L4 = 600 ... v0.7.64: from xp_steep_from on, each level past it needs xp_steep_percent % more
    $base = 50 * $level * ($level - 1);
    $over = max(0, $level - max(1, (int)setting('xp_steep_from')));
    return (int)round($base * (1 + $over * (int)setting('xp_steep_percent') / 100));
}

function garden_xp_for_level(int $level): int
{
    return 40 * $level * ($level - 1);   // garden: L2 = 80, L3 = 240, L4 = 480 ...
}

/** Gardener XP. Each new level gives stat points. Returns the new level if it went up. */
function add_xp(int $uid, int $n, string $source = ''): ?int
{
    $earned = $n;   // v1.2.0: player mentors: what the gnome earned before any newcomer bonus
    if ($n > 0) {
        require_once __DIR__ . '/mentors120.php';
        $n += mentors120_xp_bonus($uid, $n, $source !== '' ? $source : (string)(debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 2)[1]['function'] ?? 'other'));
    }
    if ($n > 0) {   // v0.9.1: keep a per-day log of where XP comes from (never breaks the award)
        try {
            if ($source === '') $source = (string)(debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 2)[1]['function'] ?? 'other');
            $day = hollow_date('Y-m-d');
            $src = mb_substr($source, 0, 40);
            $args = [$n, $day, $uid, $src];
            if (q('UPDATE xp_log SET xp = xp + ? WHERE day = ? AND user_id = ? AND source = ?', $args)->rowCount() === 0) {
                try {
                    q('INSERT INTO xp_log (day, user_id, source, xp) VALUES (?, ?, ?, ?)', [$day, $uid, $src, $n]);
                } catch (Throwable $e) {
                    q('UPDATE xp_log SET xp = xp + ? WHERE day = ? AND user_id = ? AND source = ?', $args);
                }
            }
        } catch (Throwable $e) { /* the log is optional */ }
    }
    $u = q_one('SELECT level, xp FROM users WHERE id = ?', [$uid]);
    $xp = (int)$u['xp'] + $n;
    $level = (int)$u['level'];
    while ($xp >= xp_for_level($level + 1)) {
        $level++;
    }
    $gained = $level - (int)$u['level'];
    q('UPDATE users SET xp = ?, level = ?, stat_points = stat_points + ? WHERE id = ?',
        [$xp, $level, $gained * (int)setting('stat_points_per_level'), $uid]);
    if ($earned > 0) mentors120_after_xp($uid, $earned, $source !== '' ? $source : (string)(debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 2)[1]['function'] ?? 'other'), $level);   // v1.2.0: mentor share + graduation
    return $gained ? $level : null;
}

/** Garden XP for one garden. Returns the new garden level if it went up. */
function add_garden_xp(int $plotId, int $n): ?int
{
    $p = q_one('SELECT garden_level, garden_xp FROM plots WHERE id = ?', [$plotId]);
    if (!$p) return null;
    $xp = (int)$p['garden_xp'] + $n;
    $level = (int)$p['garden_level'];
    while ($xp >= garden_xp_for_level($level + 1)) {
        $level++;
    }
    q('UPDATE plots SET garden_xp = ?, garden_level = ? WHERE id = ?', [$xp, $level, $plotId]);
    return $level > (int)$p['garden_level'] ? $level : null;
}

/** v0.9.1a: " (garden XP 120/240)": this garden's XP against what the given garden level needs. */
function garden_xp_hint(array $plot, int $level): string
{
    return ' (garden XP ' . (int)$plot['garden_xp'] . '/' . garden_xp_for_level($level) . ')';
}

/** Biggest plot side allowed at this garden level: starts at the starting size, +1 every 2 garden levels. */
function garden_max_side(array $plot): int
{
    return min((int)setting('max_plot_size'), (int)setting('starting_plot_size') + intdiv((int)$plot['garden_level'], 2));
}

function spend_stat_point(array $u, string $stat): array
{
    if (!isset(GNOME_STATS[$stat])) return [false, 'Unknown stat.'];
    $max = (int)setting('stat_max');
    if ((int)$u['stat_' . $stat] >= $max) return [false, GNOME_STATS[$stat][0] . ' is already at the maximum.'];
    $ok = q("UPDATE users SET stat_points = stat_points - 1, stat_$stat = stat_$stat + 1 WHERE id = ? AND stat_points > 0 AND stat_$stat < ?",
        [$u['id'], $max])->rowCount() === 1;
    return $ok ? [true, GNOME_STATS[$stat][1] . ' ' . GNOME_STATS[$stat][0] . ' +1!'] : [false, 'No stat points to spend.'];
}

/** v0.9.1a: may this gnome change its calling? Whenever one is set; the Petal cost (calling_change_cost()) is the gate. */
function calling_can_change(array $u): bool
{
    return !empty($u['calling']);
}

/** v0.9.1a: Petals the next change of calling costs: calling_change_cost x 2^changes so far; 0 for the one free change. */
function calling_change_cost(array $u): int
{
    if ((int)($u['calling_free_change'] ?? 0) > 0) return 0;
    return (int)setting('calling_change_cost') * (2 ** min(30, max(0, (int)($u['calling_changes'] ?? 0))));
}

function choose_calling(array $u, string $calling): array
{
    if (!isset(CALLINGS[$calling])) return [false, 'Unknown calling.'];
    if ((int)$u['level'] < (int)setting('calling_level')) return [false, 'You can choose a calling at gnome level ' . setting('calling_level') . '.'];
    if ($u['calling'] === $calling) return [false, 'That’s already your calling.'];
    $c = CALLINGS[$calling];
    $paid = '';
    if (empty($u['calling'])) {   // v0.9.1: the first choice is free
        // v0.9.1a: picking a calling uses up the old "one free change" (changes cost Petals now); gnomes from before 0.9.1 keep theirs (2)
        $ok = q("UPDATE users SET calling = ?, calling_free_change = 0 WHERE id = ? AND (calling IS NULL OR calling = '')", [$calling, $u['id']])->rowCount() === 1;
        if (!$ok) return [false, 'Your calling is already set.'];
    } else {   // v0.9.1a: one free change (older gnomes / admin reset), then Petals that double each time
        $cost = calling_change_cost($u);
        if ($cost > 0 && (int)$u['coins'] < $cost) return [false, 'Changing your calling costs ' . $cost . ' Petals; you have ' . (int)$u['coins'] . '.'];
        if ((int)($u['calling_free_change'] ?? 0) > 0) {
            $ok = q('UPDATE users SET calling = ?, calling_free_change = 0 WHERE id = ? AND calling_free_change > 0', [$calling, $u['id']])->rowCount() === 1;
        } elseif ($cost === 0) {   // admin set the cost to 0: changes are free
            $ok = q('UPDATE users SET calling = ?, calling_changes = calling_changes + 1 WHERE id = ? AND calling_changes = ?', [$calling, $u['id'], (int)($u['calling_changes'] ?? 0)])->rowCount() === 1;
        } else {
            $ok = q('UPDATE users SET calling = ?, coins = coins - ?, calling_changes = calling_changes + 1 WHERE id = ? AND coins >= ? AND calling_changes = ? AND calling_free_change = 0',
                [$calling, $cost, $u['id'], $cost, (int)($u['calling_changes'] ?? 0)])->rowCount() === 1;
        }
        if (!$ok) return [false, 'Your calling didn’t change. Try again.'];
        $paid = $cost > 0 ? ' (−' . $cost . ' Petals)' : '';
    }
    require_once __DIR__ . '/calling_quests.php';
    calling_resync((int)$u['id']);   // v0.9.4: each calling keeps its own chapter progress; pick up the new calling's
    return [true, '🎩 You put on the ' . strtolower($c[1]) . ' hat of the ' . $c[0] . $paid . '!'];
}

/** v0.9.1a: how long a meal buff lasts for this gnome: base minutes x Brewroot buff_pct (v0.9.1) x kitchen level (v0.7.96). */
function buff_minutes(array $u, int $base): int
{
    $minutes = (int)round($base * (100 + calling_perk($u, 'buff_pct')) / 100);
    require_once __DIR__ . '/gardens.php';
    $pct = user_building_bonus((int)$u['id'], 'kitchen')['buff_pct'];   // v0.9.5: best kitchen +25% / +50%, other gardens' kitchens add a little (stacking)
    if ($pct > 0) $minutes = (int)round($minutes * (100 + $pct) / 100);
    return $minutes;
}

/** v0.9.4: the tier (snack, meal, feast; v0.9.8: preserve) of a dish that has a cooking or Pantry recipe, '' for anything else (raw food, honey, shop-bought). */
function home_dish_tier(int $itemId): string
{
    static $cache = [];
    if (!array_key_exists($itemId, $cache)) {
        $t = q_val("SELECT tier FROM recipes WHERE output_item_id = ? AND category IN ('cooking', 'pantry')", [$itemId]);
        $cache[$itemId] = $t === false || $t === null ? '' : ((string)$t ?: 'meal');
    }
    return $cache[$itemId];
}

/** v0.9.4: the energy a home-cooked dish gives: its number x cook_energy_percent (setting; default 115 since v1.1.0). */
function dish_energy(int $base): int
{
    return $base <= 0 ? 0 : max(1, (int)round($base * max(0, (int)setting('cook_energy_percent')) / 100));
}

/**
 * Eat something. Effects JSON: {"temp":{"grit":2,"minutes":60},"perm":{"luck":1},"energy":10}
 * - temp: becomes your one active meal buff (a new meal replaces the old one)
 * - perm: only the FIRST time this gnome eats this item, and only up to the food cap per stat
 * - energy: restores energy up to your maximum
 */
function eat_item(array $u, int $itemId): array
{
    $item = q_one('SELECT * FROM items WHERE id = ? AND edible = 1', [$itemId]);
    if (!$item) return [false, ['You can’t eat that.']];
    $fx = json_decode((string)$item['effects'], true) ?: [];
    $uid = (int)$u['id'];
    $msgs = [];
    // v0.9.4: a dish made at a Kitchen (it has a cooking recipe) is "home-cooked": its tier counts for quests and cook_energy_percent applies
    $dishTier = (string)home_dish_tier($itemId);
    $homeCooked = $dishTier !== '' && strncmp((string)$item['slug'], 'bought-', 7) !== 0;
    // v0.7.85: at full energy, food that only restores energy is not eaten; food with other effects still is, minus the energy line
    $energyFull = !empty($fx['energy']) && (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) >= max_energy($u);
    if ($energyFull && !array_filter(array_diff_key($fx, ['energy' => 1]))) {
        return [false, ['You’re already full of energy. Save this for when you’re hungry.']];
    }
    db()->beginTransaction();
    if (!give_item($uid, $itemId, -1)) {
        db()->rollBack();
        return [false, ['You don’t have any.']];
    }
    $firstTaste = !q_val('SELECT 1 FROM user_tasted WHERE user_id = ? AND item_id = ?', [$uid, $itemId]);
    if ($firstTaste) db_insert('user_tasted', ['user_id' => $uid, 'item_id' => $itemId, 'tasted_at' => now()]);   // v0.7.61 drinks count too
    if (!empty($fx['tea'])) {   // a take-away teahouse drink (v0.7.37): the town boost, not a meal
        require_once __DIR__ . '/events.php';
        $lines = apply_event_effect(q_one('SELECT * FROM users WHERE id = ?', [$uid]), (string)$fx['tea']);
        db()->commit();
        return [true, array_merge(['☕ You drink the ' . $item['name'] . '. Lovely.'], $lines)];
    }
    $msgs[] = '😋 You eat the ' . $item['name'] . '.' . ($firstTaste ? ' 🍴 First taste, added to your list.' : '');

    // Permanent bonus: once per item per gnome, capped per stat
    if (!empty($fx['perm']) && is_array($fx['perm'])) {
        if (!$firstTaste) {
            $msgs[] = 'You’ve already gained what this can teach your body. It’s still tasty!';
        } else {
            $cap = (int)setting('food_perm_cap');
            $have = food_bonus($uid);
            foreach ($fx['perm'] as $stat => $n) {
                if (!isset(GNOME_STATS[$stat])) continue;
                $room = max(0, $cap - ($have[$stat] ?? 0));
                $n = min((int)$n, $room);
                if ($n <= 0) {
                    $msgs[] = 'Your ' . GNOME_STATS[$stat][0] . ' can’t grow any more from food (' . $cap . '/' . $cap . ').';
                    continue;
                }
                q("UPDATE users SET stat_$stat = stat_$stat + ? WHERE id = ?", [$n, $uid]);
                if (isset($have[$stat])) {
                    q('UPDATE user_food_bonus SET amount = amount + ? WHERE user_id = ? AND stat = ?', [$n, $uid, $stat]);
                } else {
                    db_insert('user_food_bonus', ['user_id' => $uid, 'stat' => $stat, 'amount' => $n]);
                }
                $msgs[] = '✨ Permanent ' . GNOME_STATS[$stat][1] . ' ' . GNOME_STATS[$stat][0] . ' +' . $n . '! (' . (($have[$stat] ?? 0) + $n) . '/' . $cap . ' from food)';
            }
        }
    }

    // Temporary meal buff (replaces the previous one)
    if (!empty($fx['temp']) && is_array($fx['temp'])) {
        $minutes = buff_minutes($u, (int)($fx['temp']['minutes'] ?? 60));   // v0.9.1a: shared with buff_text()
        $buff = [];
        foreach ($fx['temp'] as $stat => $n) {
            if (isset(GNOME_STATS[$stat])) $buff[$stat] = (int)$n;
        }
        if ($buff) {
            $json = json_encode($buff);
            $until = gmdate('Y-m-d H:i:s', time() + $minutes * 60);
            for ($try = 0; $try < 2; $try++) {   // v0.9.1a: slot writes are guarded by the values read, so a double-click can't clobber a slot; one retry
                $cur = q_one('SELECT buff, buff_until, buff2, buff2_until FROM users WHERE id = ?', [$uid]) ?: [];
                $live1 = !empty($cur['buff']) && ts_gnome($cur['buff_until'] ?? null) > time();
                $live2 = !empty($cur['buff2']) && ts_gnome($cur['buff2_until'] ?? null) > time();
                if (calling_perk($u, 'two_buffs') && ($live1 || $live2)) {   // v0.9.1: Brewroot master: fill the free slot, else replace the one ending sooner
                    $slot2 = !$live2 || ($live1 && ts_gnome($cur['buff2_until']) <= ts_gnome($cur['buff_until']));
                    $col = $slot2 ? 'buff2' : 'buff';
                    $guard = ['', ''];
                    $args = [$json, $until, $uid];
                    foreach ([$col, $col . '_until'] as $k => $c) {
                        if (($cur[$c] ?? null) === null) $guard[$k] = $c . ' IS NULL';
                        else { $guard[$k] = $c . ' = ?'; $args[] = $cur[$c]; }
                    }
                    $rows = q('UPDATE users SET ' . $col . ' = ?, ' . $col . '_until = ? WHERE id = ? AND ' . $guard[0] . ' AND ' . $guard[1], $args)->rowCount();
                } else {
                    $rows = q('UPDATE users SET buff = ?, buff_until = ?, buff2 = NULL, buff2_until = NULL WHERE id = ?', [$json, $until, $uid])->rowCount();
                }
                if ($rows > 0) break;
            }
            $parts = array_map(fn($s, $n) => GNOME_STATS[$s][0] . ' +' . $n, array_keys($buff), $buff);
            $msgs[] = $rows > 0 ? '🍽️ Meal buff for ' . nice_minutes($minutes) . ': ' . implode(', ', $parts) . '.'
                : '🍽️ The meal boost didn’t settle (you ate two things at once). Eat another for the boost.';
        }
    }

    if (!empty($fx['energy'])) {
        if ($energyFull) {   // v0.7.85: no energy gained, so no energy line
            $msgs[] = '(energy already full)';
        } else {
            $max = max_energy($u);
            $n = (int)$fx['energy'];
            if ($homeCooked) $n = dish_energy($n);   // v0.9.4: the 1.5x seed-to-plate knob (home-cooked only)
            $pct = ($item['category'] === 'food' && strncmp((string)$item['slug'], 'bought-', 7) !== 0) ? calling_perk($u, 'meal_energy_pct') : 0;   // v0.9.1 (v0.9.4: a percent, not +1): home-cooked meals only
            if ($pct > 0) $n += max(1, (int)round($n * $pct / 100));
            // whole numbers written into the SQL so the comparison is numeric (SQLite compares bound values as text)
            q('UPDATE users SET energy = CASE WHEN energy + ' . $n . ' > ' . (int)$max . ' THEN ' . (int)$max . ' ELSE energy + ' . $n . ' END WHERE id = ? AND energy < ' . (int)$max, [$uid]);
            $msgs[] = '⚡ +' . $n . ' energy.';
        }
    }
    // v0.9.4: eating a raw crop or find leaves food scraps (the item's effects.scrap, default 1) for the compost heap
    if (in_array($item['category'], ['produce', 'forage'], true) && ($scrapId = (int)q_val("SELECT id FROM items WHERE slug = 'food-scrap'"))) {
        $scraps = max(1, (int)($fx['scrap'] ?? 1));
        give_item($uid, $scrapId, $scraps);
        $msgs[] = '♻️ +' . $scraps . ' Food Scrap' . ($scraps === 1 ? '' : 's') . '.';
    }
    db()->commit();
    require_once __DIR__ . '/jobs.php';
    job_event($uid, 'eat', (string)$item['slug'], 1, ['homecooked' => $homeCooked, 'tier' => $dishTier]);   // v0.9.4: quests count Meal/Feast home-cooked only
    if (function_exists('tour_event')) {   // v0.9.4: tour step 5 is "eat your welcome snack"
        tour_event($uid, 'eat');
        $msgs = array_merge($msgs, tour_messages());
    }
    return [true, $msgs];
}

function nice_minutes(int $m): string
{
    return $m >= 120 ? round($m / 60, 1) . ' hours' : $m . ' minutes';
}

/** Small round hat in the calling colour (or plain grey before a calling is chosen). */
/** Starting hat colours a new gnome can pick. A calling's hat colour replaces it from level 5. */
const HAT_COLORS = ['#c0392b' => 'Poppy red', '#2e7d4f' => 'Moss green', '#2f5d9e' => 'Bluebell', '#e0a526' => 'Buttercup',
    '#7d4fa0' => 'Violet', '#d9773a' => 'Pumpkin', '#5b4636' => 'Bark brown', '#8a8370' => 'Pebble grey'];
const BEARD_COLORS = ['#f4f1ea' => 'Snowy', '#d8c9a8' => 'Wheat', '#b5651d' => 'Ginger', '#6b4a2b' => 'Chestnut',
    '#3b2f2f' => 'Dark loam', '#9aa0a6' => 'Silver'];

function gnome_hat_color(array $u): string
{
    $d = (string)($u['hat_dye'] ?? '');   // v0.9.7: a hat dye is worn over the calling's colour
    if ($d !== '' && dye_valid('hat', $d)) return $d;
    $c = CALLINGS[$u['calling'] ?? ''] ?? null;
    if ($c) return $c[2];
    $h = (string)($u['hat_color'] ?? '');
    return isset(HAT_COLORS[$h]) ? $h : '#8a8370';
}

/** The gnome's name (falls back to the account name for players from before gnome naming). */
function gnome_name(array $u): string
{
    return trim((string)($u['gnome_name'] ?? '')) ?: (string)($u['username'] ?? 'Gnome');
}

/** A little gnome portrait. Colours are attributes (not inline styles) so the strict CSP allows them. */
function gnome_avatar(array $u, int $size = 96): string
{
    $hat = gnome_hat_color($u);
    $tier = calling_tier($u);   // v0.9.1
    $b = (string)($u['beard_color'] ?? '');
    $beard = isset(BEARD_COLORS[$b]) || dye_valid('beard', $b) ? $b : '#f4f1ea';   // v0.9.7: or a beard dye
    $L = ['shadow', 'body', 'face', 'beard', 'hat'] + ($tier >= 2 ? [5 => 'band'] : []) + ($tier >= 3 ? [6 => 'star'] : []);
    $px = true;
    foreach ($L as $l) if (!pixel_has('assets/img/gnome/gnome-' . $l . '.png')) { $px = false; break; }
    if ($px) {   // v2.0.31: layered pixel art, beard and hat tinted by an SVG filter (filters live inside this svg's <defs> so trek.php / trek_art.php can re-embed the inner markup)
        require_once __DIR__ . '/pixel_art.php';
        $bh = pixel_hex($beard);
        $hh = pixel_hex($hat);
        $uid = '-' . bin2hex(random_bytes(3));   // v2.0.36: unique filter ids per avatar (the phone nav drawer holds a hidden twin of this gnome)
        $defs = ($hh !== '' ? pixel_tint_filter($hh, 1.25, $uid) : '') . ($bh !== '' && $bh !== $hh ? pixel_tint_filter($bh, 1.25, $uid) : '');
        $o = '<svg class="gnomeart" width="' . $size . '" height="' . (int)round($size * 1.25) . '" viewBox="0 0 80 100" role="img" aria-label="Your gnome" data-tint="' . $uid . '">'
            . ($defs !== '' ? '<defs>' . $defs . '</defs>' : '');
        foreach ($L as $l) {
            $o .= '<g data-part="' . ($l === 'beard' || $l === 'hat' || $l === 'band' || $l === 'star' ? $l : 'base') . '">'
                . pixel_image('assets/img/gnome/gnome-' . $l . '.png', 0, 0, 80, 100, $l === 'beard' ? $beard : ($l === 'hat' ? $hat : ''), $uid) . '</g>';
        }
        return $o . '</svg>';
    }
    return '<svg class="gnomeart" width="' . $size . '" height="' . (int)round($size * 1.25) . '" viewBox="0 0 80 100" role="img" aria-label="Your gnome">'
        . '<ellipse cx="40" cy="96" rx="26" ry="4" fill="#000" opacity=".12"/>'
        . '<path d="M18 92 Q20 64 40 62 Q60 64 62 92 Z" fill="#6b8f4e"/>'                       // tunic
        . '<rect x="22" y="78" width="36" height="5" rx="2" fill="#5b4636"/>'                   // belt
        . '<circle cx="40" cy="48" r="15" fill="#f1c9a5"/>'                                   // face
        . '<path data-part="beard" d="M25 50 Q26 80 40 86 Q54 80 55 50 Q48 60 40 58 Q32 60 25 50 Z" fill="' . e($beard) . '"/>'
        . '<circle cx="34" cy="46" r="1.8" fill="#3b2f2f"/><circle cx="46" cy="46" r="1.8" fill="#3b2f2f"/>'
        . '<ellipse cx="40" cy="52" rx="4" ry="3.2" fill="#e8a587"/>'                         // nose
        . '<path data-part="hat" d="M40 2 Q47 20 58 40 L22 40 Q33 20 40 2 Z" fill="' . e($hat) . '"/>'
        . '<rect data-part="hat" x="20" y="37" width="40" height="6" rx="3" fill="' . e($hat) . '"/>'
        . ($tier >= 2 ? '<rect data-part="band" x="20" y="37" width="40" height="3" fill="#f4d35e" opacity=".9"/>' : '')   // v0.9.1: tier II hat band
        . ($tier >= 3 ? '<path data-part="star" d="M40 16 L41.8 20.2 L46.3 20.5 L42.8 23.4 L43.9 27.8 L40 25.4 L36.1 27.8 L37.2 23.4 L33.7 20.5 L38.2 20.2 Z" fill="#f4d35e" stroke="#b8860b" stroke-width=".6"/>' : '')   // v0.9.1: tier III star
        . '</svg>';
}

function gnome_hat(array $u): string
{
    $color = gnome_hat_color($u);
    return '<svg class="hat" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 1 L20 20 H4 Z" fill="' . e($color) . '"/>'
        . '<ellipse cx="12" cy="20.5" rx="10" ry="2.5" fill="' . e($color) . '"/></svg>';
}

/** A link to a gnome's profile page. */
function profile_link(array $u, ?string $text = null): string
{
    return '<a class="gnomelink" href="' . e(url('profile.php?id=' . (int)$u['id'])) . '">' . e($text ?? gnome_name($u)) . '</a>';
}
