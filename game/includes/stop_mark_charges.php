<?php
declare(strict_types=1);
/**
 * Lasting marks, hooks part 2 (claude/proposal-stop-perks.md "Hook list"): the daily charges A1-A3 at their game sites and the flags
 * A5/A6 on their pages. Part 1 (stop_mark_hooks.php) has the number families, their place scopes and the A4 coins.
 * Behind stop_marks_open: while it is 0 every helper here returns [] / '' / the number unchanged without a query.
 *
 * A charge is a perk of class D (data/stop_perks.txt) with a trig= in its scope. It fires once per game day (the gnome's sleep,
 * mark_daily_use) at the first event that fits. Where it fits:
 *   stop triggers (MARK_TRIG_STOP): at the perk's own stop (ctx at), unless the perk names a region;
 *   walk triggers: a walk that starts or ends at the perk's own stop;
 *   any other trigger: anywhere, or in the perk's region when its scope says here (at= / from= / to=);
 *   always: the rest of its scope (region, items, land, weather...) and, for an act or a wonder check, the act kinds or stat it names.
 * What it does: A1 = 1 energy less (the site), A2 = something back (the site), A3 = the item in brackets in its effect, or 1 energy,
 * or a little health; "one extra" = the site gives one more of the thing. A perk with hook=todo in the catalogue never fires.
 */

require_once __DIR__ . '/stop_mark_hooks.php';

const MARK_TRIG_STOP = ['first_visit_to_the_stop', 'first_act_of_a_kind_at_the_stop', 'first_rest_act_at_the_stop', 'first_sale_at_the_stops_stall',
    'first_buy_at_the_stops_stall', 'first_gift_to_the_stops_folk', 'lost_contest_replay', 'first_dish_eaten_cooked_at_the_stop'];
const MARK_TRIG_WALK = 'first_walk_from_to_the_stop';
/** Triggers whose effect may name what it applies to: act kinds, or the stat of a wonder check. */
const MARK_TRIG_WORDS = [
    'first_act_of_a_kind_at_the_stop' => ['check', 'pick', 'power', 'lore', 'craft', 'collect', 'tend', 'contest', 'rest', 'buy', 'swap', 'snack', 'gossip'],
    'failed_check_at_a_wonder' => ['grit', 'nimble', 'hardiness', 'lore', 'sense', 'charm', 'luck'],
];
const MARK_TOOL_TRIG = ['staff' => 'staff_wear', 'rod' => 'rod_wear', 'pick' => 'rock_pick_wear', 'net' => 'bug_net_wear'];
/** Flags (A5/A6): the page each script shows (scope page=, proposal "Flags: page -> file"). */
const MARK_FLAG_PAGES = [
    'garden.php' => ['garden'], 'index.php' => ['today_page'], 'gnome.php' => ['today_page', 'gnome_home'], 'profile.php' => ['gnome_home'],
    'hovel.php' => ['gnome_home', 'kitchen_recipes_tea'], 'here.php' => ['stop_page', 'route_menu'], 'town.php' => ['stop_page', 'route_menu'],
    'adventure.php' => ['walk_view_route_maps', 'delve'], 'inventory.php' => ['satchel', 'seed_packets'], 'world.php' => ['world_map'],
    'shop.php' => ['shops'], 'market.php' => ['shops'], 'kitchen.php' => ['kitchen_recipes_tea'], 'passport.php' => ['passport'],
    'villagers.php' => ['friends'], 'folk.php' => ['friends'],
];

/** The act kinds / stat words a charge's effect names for its trigger ([] = any). */
function mark_charge_words(array $p, string $trig): array
{
    $words = MARK_TRIG_WORDS[$trig] ?? [];
    if (!$words || !preg_match_all('/\b(' . implode('|', $words) . ')\b/', strtolower((string)$p['effect']), $m)) return [];
    return array_values(array_unique($m[1]));
}

/** Does a held charge fit this event? (rules in the file comment) */
function mark_charge_fits(array $p, string $trig, array $ctx): bool
{
    $here = array_intersect_key($p['scope'], array_flip(['at', 'from', 'to']));
    if (!mark_scope_fits(['scope' => array_diff_key($p['scope'], $here)] + $p, $ctx)) return false;
    $words = mark_charge_words($p, $trig);
    if ($words && !in_array((string)($ctx['kind'] ?? ''), $words, true)) return false;
    if (in_array($trig, MARK_TRIG_STOP, true)) return isset($p['scope']['region']) || ($p['loc_id'] > 0 && (int)($ctx['at'] ?? 0) === $p['loc_id']);
    if ($trig === MARK_TRIG_WALK) return $p['loc_id'] > 0 && in_array($p['loc_id'], [(int)($ctx['from'] ?? 0), (int)($ctx['to'] ?? 0)], true);
    return !$here || (string)($ctx['region'] ?? '') === (string)$p['region'];
}

/** The held charges (A1-A3) for $trig that fit $ctx and are still unused this game day. Nothing is taken yet. */
function mark_charges_ready(int $uid, string $trig, array $ctx): array
{
    if ($uid < 1 || !mark_hooks_on()) return [];
    require_once __DIR__ . '/stops.php';
    $out = [];
    foreach (mark_held($uid) as $p) {
        if ($p['class'] !== 'D' || $p['family'] === 'A4' || $p['hook'] === 'todo' || !in_array($trig, $p['scope']['trig'] ?? [], true)) continue;
        if (mark_charge_fits($p, $trig, $ctx) && mark_daily_available($uid, (string)$p['key'])) $out[] = $p;
    }
    return $out;
}

/**
 * Take ready charges (each once a game day) and pay what an A3 gives by itself: the item in brackets, else 1 energy, else
 * "heals N health". Returns the perks taken, each with its 'line' ('' when the site pays: energy less, one extra, something back).
 */
function mark_charges_take(int $uid, array $ready): array
{
    $taken = [];
    foreach ($ready as $p) {
        if (!mark_daily_use($uid, (string)$p['key'])) continue;
        $p['line'] = $p['family'] === 'A3' ? mark_charge_gift($uid, $p) : '';
        $taken[] = $p;
    }
    return $taken;
}

/** mark_charges_ready, then take them all. */
function mark_charges_fire(int $uid, string $trig, array $ctx): array
{
    return mark_charges_take($uid, mark_charges_ready($uid, $trig, $ctx));
}

/** An A3's own gift; '' when it is a "one extra" the site gives. */
function mark_charge_gift(int $uid, array $p): string
{
    $fx = (string)$p['effect'];
    $tag = ' (' . $p['icon'] . ' ' . $p['name'] . ')';
    if (preg_match('/\(([a-z0-9]+(?:-[a-z0-9]+)*)\)/', $fx, $m) && ($iid = item_id_by_slug($m[1]))) {
        give_item($uid, $iid, 1);
        return '+1 × ' . q_val('SELECT name FROM items WHERE id = ?', [$iid]) . $tag;
    }
    if (preg_match('/heals (\d+) health/', $fx, $m)) {
        require_once __DIR__ . '/health.php';
        return ($got = hp_heal_points(q_one('SELECT * FROM users WHERE id = ?', [$uid]), (int)$m[1])) > 0 ? '+' . $got . ' ❤️' . $tag : '';
    }
    if (preg_match('/\b1 (more )?energy\b/', $fx)) {
        require_once __DIR__ . '/events.php';
        apply_event_effect(q_one('SELECT * FROM users WHERE id = ?', [$uid]), 'energy:1');
        return '+1 energy' . $tag;
    }
    return '';
}

/** The lines of taken charges (for a site's message). */
function mark_charge_lines(array $taken): array
{
    return array_values(array_filter(array_column($taken, 'line')));
}

/** A cost after the ready A1 charges, 1 less each. A1 charges that would save nothing are dropped from $ready (not spent). */
function mark_charge_energy(array &$ready, int $cost): int
{
    $off = 0;
    foreach ($ready as $i => $p) {
        if ($p['family'] !== 'A1') continue;
        if ($cost - $off > 0) $off++;
        else unset($ready[$i]);
    }
    return $cost - $off;
}

/** Does the bought, sold or given item fit what the charge's effect names (a seed, food or a dish, a crop)? */
function mark_charge_item_ok(array $p, string $category): bool
{
    $fx = strtolower((string)$p['effect']);
    if (str_contains($fx, 'seed')) return $category === 'seed';
    if (preg_match('/\b(food|dish|bread|bake)\b/', $fx)) return in_array($category, ['food', 'produce', 'forage'], true);
    if (str_contains($fx, 'crop')) return $category === 'produce';
    return true;
}

// ---------------------------------------------------------------- sites (one call each)

/**
 * A stop act, inside its transaction before the energy is spent: the first-act and first-rest charges. A1 = 1 energy less (only when
 * the act costs energy), A3 = its gift. Returns [energy to spend, lines].
 */
function mark_act_charges(int $uid, array $mkAct, int $energy): array
{
    if (!$mkAct) return [$energy, []];
    $ready = mark_charges_ready($uid, 'first_act_of_a_kind_at_the_stop', $mkAct);
    if (($mkAct['kind'] ?? '') === 'rest') $ready = array_merge($ready, mark_charges_ready($uid, 'first_rest_act_at_the_stop', $mkAct));
    $left = mark_charge_energy($ready, $energy);
    $taken = mark_charges_take($uid, $ready);
    $less = count(array_filter($taken, fn($p) => $p['family'] === 'A1'));
    return [$energy - $less, array_merge($less ? ['−' . $less . ' energy (a lasting mark)'] : [], mark_charge_lines($taken))];
}

/** A shop purchase: one extra of the bought thing (the first food bought anywhere, the first seed at a named stall). Returns the line. */
function mark_buy_charges(int $uid, int $shopId, int $itemId, string $category, string $name): string
{
    if (!mark_hooks_on()) return '';
    $ctx = mark_ctx_shop($shopId, $itemId);
    $ready = array_filter(array_merge(mark_charges_ready($uid, 'first_food_bought_in_a_shop', $ctx), mark_charges_ready($uid, 'first_buy_at_the_stops_stall', $ctx)),
        fn($p) => mark_charge_item_ok($p, $category));
    $n = count(mark_charges_take($uid, $ready));
    if ($n < 1) return '';
    give_item($uid, $itemId, $n);
    return '🏅 +' . $n . ' × ' . $name . ' (a lasting mark)';
}

/** A tool that would wear now: true when a charge keeps it from wearing (staff, rod, rock pick, bug net). */
function mark_tool_wear_skipped(int $uid, string $type): bool
{
    if (!isset(MARK_TOOL_TRIG[$type]) || !mark_hooks_on()) return false;
    return (bool)mark_charges_fire($uid, MARK_TOOL_TRIG[$type], mark_ctx_here($uid));
}

// ---------------------------------------------------------------- flags (A5 info, A6 looks)

/** The held flags of one page key (scope page=). */
function mark_flags_on(int $uid, string $page): array
{
    if ($uid < 1 || !mark_hooks_on()) return [];
    require_once __DIR__ . '/stops.php';
    return array_values(array_filter(mark_held($uid), fn($p) => $p['class'] === 'F' && in_array($page, $p['scope']['page'] ?? [], true)));
}

/** The strip under a page's header: every flag held for the pages this script shows ('' for none, or with lasting marks off). */
function mark_flags_html(int $uid, string $script): string
{
    $flags = [];
    foreach (MARK_FLAG_PAGES[$script] ?? [] as $page) foreach (mark_flags_on($uid, $page) as $p) $flags[$p['key']] = $p;
    if (!$flags) return '';
    $h = '<p class="mk-flags help">';
    foreach ($flags as $p) $h .= '<span class="mk-flag mk-' . ($p['family'] === 'A6' ? 'looks' : 'info') . '" title="' . e($p['effect']) . '">' . e($p['icon'] . ' ' . $p['name']) . '</span> ';
    return $h . '</p>';
}
