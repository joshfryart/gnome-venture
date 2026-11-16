<?php
declare(strict_types=1);

/**
 * 2.7.00 ROAD KINDS: a few Trail routes are not plain roads (list: data/road_kinds.txt, one line per route: id|kind|tier).
 *   ferry      pay 20 Petals a crossing, at the start of the walk
 *   tunnel     a lantern of at least the route's tier is needed to start the walk
 *   pass       a staff of at least the route's tier is needed to start the walk
 *   toll       at section 1: pay 10 Petals (safer: random fights at half the chance; faster: 5 game minutes a section instead of 10) or take the old road
 *   overgrown  +10 game minutes a section; an axe (any tier) in the satchel = no slowdown
 *   flooded    +10 game minutes a section; Flood Boots in the satchel halve it (+5)
 * Everything here is a plain function: no state of its own except the toll choice, kept in the Trail scene ('toll' 1 paid, 0 refused, missing = not asked yet).
 */

const RK_FERRY_PETALS = 20;
const RK_TOLL_PETALS = 10;
const RK_SLOW_MIN = 10;          // game minutes added per section on an overgrown or a flooded road
const RK_BOOTS_MIN = 5;          // the same with Flood Boots
const RK_TOLL_MIN = 5;           // game minutes a section on a toll road once the toll is paid (10 on the old road)
const RK_TOLL_ENC = 0.5;         // the share of the random-fight chance left on a paid toll road
const RK_KINDS = ['ferry', 'tunnel', 'pass', 'toll', 'overgrown', 'flooded'];
const RK_ICON = ['ferry' => '⛴️', 'tunnel' => '🔦', 'pass' => '⛰️', 'toll' => '🪙', 'overgrown' => '🌿', 'flooded' => '💧'];   // 2.7.01: the emoji of the map token (rk_label's), when its drawn marker trail/mark/<kind>.png is missing
const RK_ITEMS = [   // slug => [name, category, rarity, price, description] (Flood Boots are a wearable now)
    'toll-receipt' => ['Toll Receipt', 'other', 4, 1, 'A stamped scrap that says you paid the toll. It has a very small drawing of a bridge on it.'],
];

/** [route id => ['kind' => string, 'tier' => int]] from data/road_kinds.txt. */
function rk_all(): array
{
    static $c = null;
    if ($c !== null) return $c;
    $c = [];
    foreach (@file(__DIR__ . '/data/road_kinds.txt', FILE_IGNORE_NEW_LINES) ?: [] as $l) {
        $l = trim($l);
        if ($l === '' || $l[0] === '#') continue;
        $p = explode('|', $l);
        if (count($p) >= 2 && ctype_digit($p[0]) && in_array($p[1], RK_KINDS, true)) $c[(int)$p[0]] = ['kind' => $p[1], 'tier' => (int)($p[2] ?? 0)];
    }
    return $c;
}

/** The kind of a route (['kind', 'tier']) or null for a plain road. */
function rk_of(int $routeId): ?array { return rk_all()[$routeId] ?? null; }

/** 2.7.01: does the kind's map marker stand on this stretch (0 = the first one walked)? Ferry, tunnel, pass and toll are met where the walk starts; overgrown and flooded slow every stretch. */
function rk_on_stretch(string $kind, int $sec): bool { return in_array($kind, ['overgrown', 'flooded'], true) || ($sec === 0 && in_array($kind, RK_KINDS, true)); }

/** Tool type the kind asks for. */
function rk_tool(string $kind): string { return $kind === 'tunnel' ? 'lantern' : ($kind === 'pass' ? 'staff' : ''); }

/** A short label for the route cards and the Trail strip, or ''. */
function rk_label(?array $k): string
{
    if (!$k) return '';
    return match ($k['kind']) {
        'ferry' => '⛴️ Ferry · ' . RK_FERRY_PETALS . ' Petals',
        'tunnel' => '🔦 Tunnel · lantern tier ' . $k['tier'],
        'pass' => '⛰️ Pass · staff tier ' . $k['tier'],
        'toll' => '🪙 Toll road · ' . RK_TOLL_PETALS . ' Petals',
        'overgrown' => '🌿 Overgrown · slow',
        'flooded' => '💧 Flooded · slow',
        default => '',
    };
}

/** One line that says what the kind does (the Almanac page and the walk card). */
function rk_text(string $kind, int $tier = 0): string
{
    return match ($kind) {
        'ferry' => 'A ferry crosses the water on this road. It costs ' . RK_FERRY_PETALS . ' Petals each time you set out.',
        'tunnel' => 'A dark tunnel runs through this road. You need a lantern of tier ' . $tier . ' or better to set out.',
        'pass' => 'A mountain pass climbs along this road. You need a staff of tier ' . $tier . ' or better to set out.',
        'toll' => 'A toll road. Pay ' . RK_TOLL_PETALS . ' Petals at the first stretch and the road is safer (half the surprise fights) and quicker (' . RK_TOLL_MIN . ' game minutes a stretch instead of ' . gclock_time_cost_or('travel', 10) . '). Or take the old road.',
        'overgrown' => 'The road is overgrown: each stretch takes ' . RK_SLOW_MIN . ' game minutes longer. An axe in your satchel clears the way.',
        'flooded' => 'The road is flooded: each stretch takes ' . RK_SLOW_MIN . ' game minutes longer, or ' . RK_BOOTS_MIN . ' with Flood Boots in your satchel.',
        default => '',
    };
}

function gclock_time_cost_or(string $key, int $fallback): int { return function_exists('gclock_time_cost') ? gclock_time_cost($key) : $fallback; }

/** Does the gnome carry the item (by slug)? */
function rk_has_item(int $uid, string $slug): bool
{
    $id = item_id_by_slug($slug);
    return $id > 0 && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]) > 0;
}

/**
 * Before a walk on this route starts: null = fine, or the reason it cannot start (nothing was spent). Tunnel and pass need the tool; a ferry needs the Petals.
 * Pure of side effects.
 */
function rk_start_check(array $u, array $route): ?string
{
    $k = rk_of((int)$route['id']);
    if (!$k) return null;
    if ($k['kind'] === 'tunnel' || $k['kind'] === 'pass') {
        $type = rk_tool($k['kind']);
        if (function_exists('tool_tier') && tool_tier((int)$u['id'], $type) < $k['tier']) {
            $names = [1 => 'Worn', 2 => 'Sturdy', 3 => 'Fine', 4 => 'Masterwork'];
            return ($k['kind'] === 'tunnel' ? 'A dark tunnel: bring a lantern' : 'A steep mountain pass: bring a walking staff') . ' of tier ' . $k['tier'] . ' (' . ($names[$k['tier']] ?? '') . ') or better.';
        }
    }
    if ($k['kind'] === 'ferry' && (int)($u['coins'] ?? 0) < RK_FERRY_PETALS) return 'The ferry costs ' . RK_FERRY_PETALS . ' Petals and you do not have them.';
    return null;
}

/**
 * Game minutes to add per section on this road (overgrown, flooded), and the Petals the ferry takes. [extraMinutesPerSection, petals, note].
 * Does not spend anything.
 */
function rk_start_costs(array $u, array $route): array
{
    $k = rk_of((int)$route['id']);
    if (!$k) return [0, 0, ''];
    $uid = (int)$u['id'];
    if ($k['kind'] === 'ferry') return [0, RK_FERRY_PETALS, '⛴️ You pay ' . RK_FERRY_PETALS . ' Petals for the ferry.'];
    if ($k['kind'] === 'overgrown') {
        if (function_exists('tool_tier') && tool_tier($uid, 'axe') >= 1) return [0, 0, '🪓 Your axe clears the overgrown road.'];
        return [RK_SLOW_MIN, 0, '🌿 The road is overgrown: it takes longer.'];
    }
    if ($k['kind'] === 'flooded') {
        require_once __DIR__ . '/wearables.php'; wear_ensure_items();
        if (wear_has_boots($uid)) return [RK_BOOTS_MIN, 0, '👢 Your flood boots keep you drier: the flooded road is only a little slower.'];
        return [RK_SLOW_MIN, 0, '💧 The road is flooded: it takes longer.'];
    }
    return [0, 0, ''];
}

/** A toll road whose toll has not been answered yet in this walk? ($st = the Trail scene state) */
function rk_toll_open(int $routeId, array $st): bool
{
    $k = rk_of($routeId);
    return $k && $k['kind'] === 'toll' && !isset($st['toll']);
}

/** Is the toll paid in this walk? */
function rk_toll_paid(array $st): bool { return !empty($st['toll']); }

/** The base percent of a random fight per tile on this walk (setting trail_enc_pct, halved on a paid toll road). */
function rk_enc_base(array $st): ?float
{
    if (!rk_toll_paid($st)) return null;
    return (function_exists('setting') ? (float)setting('trail_enc_pct') : 3.0) * RK_TOLL_ENC;
}

/** Make the road-kind items (the Toll Receipt; the Flood Boots are a wearable: includes/wearables.php) if missing. Safe to call often. */
function rk_ensure_items(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    try {
        foreach (RK_ITEMS as $slug => [$name, $cat, $rar, $price, $desc]) {
            if (!item_id_by_slug($slug)) db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'rarity' => $rar, 'base_price' => $price, 'description' => $desc, 'edible' => 0, 'tradable' => 0]);
        }
        require_once __DIR__ . '/wearables.php';
        wear_ensure_items();
    } catch (Throwable $e) { error_log('rk_ensure_items: ' . $e->getMessage()); }
}

/**
 * The toll answer at the first stretch, in two steps so a double tap never charges twice.
 * rk_toll_set(): checks the answer is open and affordable and writes it into $sc['st']['toll'] (1 paid, 0 refused). The caller saves the scene
 * with its compare-and-swap; only the request that wins goes on to rk_toll_apply(), which takes the Petals and charges the walk's game time
 * (a toll road's travel time is charged here, not at the start, because the price depends on the answer). [ok, message]
 */
function rk_toll_set(array $u, array &$sc, bool $pay): array
{
    if (!rk_toll_open((int)substr((string)$sc['row']['map_key'], 6), $sc['st'])) return [false, 'There is no toll to settle.'];
    if ($pay && (int)($u['coins'] ?? 0) < RK_TOLL_PETALS) return [false, 'The toll is ' . RK_TOLL_PETALS . ' Petals and you do not have them. You can take the old road instead.'];
    $sc['st']['toll'] = $pay ? 1 : 0;
    return [true, ''];
}

/** After the scene was saved with the answer: take the Petals and the time. Returns the line to show. A toll that cannot be paid any more (the Petals were spent meanwhile) counts as the old road. */
function rk_toll_apply(array $u, bool $pay, int $sections): string
{
    $uid = (int)$u['id'];
    if ($pay && take_petals($uid, RK_TOLL_PETALS, 'toll road')) {
        rk_ensure_items();
        if (($rid = item_id_by_slug('toll-receipt')) > 0) give_item($uid, $rid, 1);
        rk_charge_travel($uid, $sections, RK_TOLL_MIN);
        return '🪙 You pay ' . RK_TOLL_PETALS . ' Petals. The toll road is quicker and quieter.';
    }
    rk_charge_travel($uid, $sections, gclock_time_cost_or('travel', 10));
    return $pay ? 'You could not pay the toll after all: you take the old road.' : 'You take the old road.';
}

/** Charge $minutes of game time for each of $sections stretches (no-op with the game clock off). */
function rk_charge_travel(int $uid, int $sections, int $minPerSection): void
{
    if (!function_exists('gclock_on') || !gclock_on() || $minPerSection <= 0) return;
    if (function_exists('gclock_ledger_snap')) gclock_ledger_snap($uid);
    game_spend($uid, $minPerSection * max(1, $sections));
}
