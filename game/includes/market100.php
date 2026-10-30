<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 2b, "the economy": townsfolk orders with a quality bar, the weekly market day, and demand drift on sell prices.
 * Everything is a pure function of the Hollow date (so every gnome sees the same market) and is worked out on view: no cron.
 *
 *   QUALITY       item_quality keeps the average quality of the stack you hold (harvest = Harvest Fair score, preserves = jar score).
 *                 Things you didn't grow count as "plain" (35). Arrangements carry their own score; dishes are judged by recipe tier.
 *   ORDERS        npc_order($npc, $town) => this cycle's order from one townsfolk (null once its deadline has passed).
 *                 order_deliver() takes the goods and pays Petals, friendship, XP and sometimes a seed or soil.
 *   MARKET DAY    market_day_on(): one weekday (setting market_day) when the town square runs stalls, wanted goods pay more
 *                 and a best-basket judging is held against three townsfolk.
 *   PRICE DRIFT   market_sell_pct($item): the % of base price a shop pays, 45-80, from the week's noise, the season, the "wanted"
 *                 list and how much of it gnomes have been selling. market_buy_mult($itemId): shops sell seasonal crops a bit cheaper in season.
 */

const MARKET_PLAIN_Q = 35;   // quality of a thing you didn't grow or make
/** Quality bands for the letters shown on orders: [min quality, letter]. */
const MARKET_GRADES = [[88, 'S'], [75, 'A'], [60, 'B'], [45, 'C'], [30, 'D'], [0, 'F']];
/** Seasons a crop is "in season" when the plant row has none set (Admin → Plants → Seasons overrides this). */
const MARKET_KIND_SEASONS = ['vegetable' => 'summer,autumn', 'tuber' => 'autumn,winter', 'legume' => 'spring,summer', 'grain' => 'summer,autumn',
    'fruit' => 'summer,autumn', 'tree' => 'autumn', 'nut' => 'autumn,winter', 'herb' => 'spring,summer', 'spice' => 'summer'];
const MARKET_SELLABLE = "('produce','flower','food','part','forage','arrangement','packet')";
const MARKET_WEEKDAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

function market100_settings(): array
{
    return [
        'orders_on'           => ['label' => 'Orders: townsfolk post orders with a quality bar and a deadline (off = the old weekly “bring N crops” favours)', 'type' => 'bool', 'default' => '1'],
        'orders_food_quality' => ['label' => 'Orders: crop and preserve orders ask for a quality grade (v1.7.6 off: the Satchel doesn’t split stacks by quality)', 'type' => 'bool', 'default' => '0'],
        'orders_cycle_days'   => ['label' => 'Orders: a new round of orders every this many days', 'type' => 'int', 'default' => '7', 'min' => 3, 'max' => 28],
        'orders_min_days'     => ['label' => 'Orders: shortest deadline in days (each order gets a deadline between this and the round length)', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 28],
        'orders_board_max'    => ['label' => 'Orders: most orders on one town’s board at once (v1.1.0: 3)', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 20],
        'orders_pay_percent'  => ['label' => 'Orders: pay this % of the goods’ base price (hard orders pay up to 1.6× this)', 'type' => 'int', 'default' => '150', 'min' => 0, 'max' => 1000],
        'market_on'           => ['label' => 'Market day: a weekly market in the town squares', 'type' => 'bool', 'default' => '1'],
        'market_day'          => ['label' => 'Market day: which weekday (0 = Sunday … 6 = Saturday, Hollow time)', 'type' => 'int', 'default' => '6', 'min' => 0, 'max' => 6],
        'market_stalls'       => ['label' => 'Market day: stalls in a town square', 'type' => 'int', 'default' => '4', 'min' => 1, 'max' => 10],
        'market_stall_stock'  => ['label' => 'Market day: kinds of goods on each stall', 'type' => 'int', 'default' => '4', 'min' => 1, 'max' => 10],
        'market_stall_limit'  => ['label' => 'Market day: most of one good a gnome may buy from a stall in a day', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 99],
        'market_stall_markup' => ['label' => 'Market day: stall prices as % of base price (±10% by stall)', 'type' => 'int', 'default' => '115', 'min' => 50, 'max' => 400],
        'basket_on'           => ['label' => 'Market day: the best-basket judging against three townsfolk', 'type' => 'bool', 'default' => '1'],
        'basket_rewards'      => ['label' => 'Market day: Petals for beating 0, 1, 2 or all 3 townsfolk baskets, comma separated', 'type' => 'text', 'default' => '30,90,200,400'],
        'price_drift_on'      => ['label' => 'Prices: shop sell prices drift with the week, season, demand and sales (off = flat base %)', 'type' => 'bool', 'default' => '1'],
        'price_base_pct'      => ['label' => 'Prices: normal sell price as % of base price', 'type' => 'int', 'default' => '60', 'min' => 10, 'max' => 100],
        'price_min_pct'       => ['label' => 'Prices: lowest the sell % can drift to', 'type' => 'int', 'default' => '45', 'min' => 5, 'max' => 100],
        'price_max_pct'       => ['label' => 'Prices: highest the sell % can drift to (keep below what shops charge)', 'type' => 'int', 'default' => '80', 'min' => 10, 'max' => 95],
        'price_noise'         => ['label' => 'Prices: weekly wobble, ± this many points per item', 'type' => 'int', 'default' => '6', 'min' => 0, 'max' => 30],
        'price_season_swing'  => ['label' => 'Prices: points an in-season crop sells lower (and an off-season one higher)', 'type' => 'int', 'default' => '6', 'min' => 0, 'max' => 30],
        'price_wanted_count'  => ['label' => 'Prices: goods on the “wanted this week” list', 'type' => 'int', 'default' => '6', 'min' => 0, 'max' => 30],
        'price_wanted_bonus'  => ['label' => 'Prices: points added to a wanted good', 'type' => 'int', 'default' => '12', 'min' => 0, 'max' => 40],
        'price_market_bonus'  => ['label' => 'Prices: extra points for a wanted good on market day', 'type' => 'int', 'default' => '8', 'min' => 0, 'max' => 40],
        'price_vol_units'     => ['label' => 'Prices: gnomes sell this many of one good to lower its price by 1 point', 'type' => 'int', 'default' => '8', 'min' => 1, 'max' => 1000],
        'price_vol_max'       => ['label' => 'Prices: most points that heavy selling can take off', 'type' => 'int', 'default' => '12', 'min' => 0, 'max' => 40],
        'price_vol_halflife'  => ['label' => 'Prices: days for sales pressure to halve (recovery)', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 60],
        'price_buy_season'    => ['label' => 'Prices: shops charge this % less for seasonal seeds and crops in season (and more out of season)', 'type' => 'int', 'default' => '6', 'min' => 0, 'max' => 30],
    ];
}

/** [tables, indexes, columns] for schema_statements(). */
function market100_schema(string $PK, string $ID, string $END): array
{
    $t = [];
    $t[] = "CREATE TABLE IF NOT EXISTS item_quality (
        id $PK,
        user_id $ID NOT NULL,
        item_id $ID NOT NULL,
        q INT NOT NULL DEFAULT 35,
        n INT NOT NULL DEFAULT 0,
        UNIQUE (user_id, item_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS npc_orders (
        id $PK,
        user_id $ID NOT NULL,
        npc_id $ID NOT NULL,
        cycle INT NOT NULL,
        kind VARCHAR(12) NOT NULL DEFAULT 'legacy',
        quality INT NOT NULL DEFAULT 0,
        coins INT NOT NULL DEFAULT 0,
        done_at DATETIME NOT NULL,
        UNIQUE (user_id, npc_id, cycle)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS market_volume (
        item_id $ID NOT NULL UNIQUE,
        vol FLOAT NOT NULL DEFAULT 0,
        at DATETIME NOT NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS market_buys (
        id $PK,
        user_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        npc_id $ID NOT NULL,
        item_id $ID NOT NULL,
        n INT NOT NULL DEFAULT 0,
        UNIQUE (user_id, day, npc_id, item_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS market_baskets (
        id $PK,
        user_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        town VARCHAR(60) NOT NULL DEFAULT '',
        score INT NOT NULL DEFAULT 0,
        beat INT NOT NULL DEFAULT 0,
        coins INT NOT NULL DEFAULT 0,
        items TEXT NULL,
        UNIQUE (user_id, day)
    )$END";
    return [$t, [], []];
}

const MARKET_ALMANAC = [
    'Orders, market day and prices' => [38, "📜 [b]Orders.[/b] Townsfolk pin orders to their town's Notice Board: “three carrots”, “a jar of jam”, “an arrangement scoring 60+”, “a feast”, “dried lavender”. Every order has a [b]deadline[/b], and a harder order pays more Petals, more friendship and sometimes a rare seed. Everyone sees the same orders.\n\n"
        . "[b]Quality[/b]: crop and jam orders take any quality. An arrangement order wants a score, and every arrangement carries its own. Quality still counts at the Harvest Fair and in the market-day basket judging (a rich, healthy, high-grade bed grows the best crops).\n\n"
        . "🧺 [b]Market day.[/b] One day a week the town square runs a market: townsfolk stalls with different stock each time, better prices for [b]wanted[/b] goods, and a best-basket judging against three townsfolk.\n\n"
        . "💰 [b]Prices drift.[/b] A shop pays a share of a thing's base price, and that share moves from week to week. Crops sell for a little less in their season (everyone has them) and more out of it. A few goods are [b]wanted[/b] each week. If gnomes sell a lot of one thing its price dips, then recovers over a few days. Look for the ↑ and ↓ marks on the Sell tab."],
];

/** v1.7.6: the Orders Almanac page no longer promises graded crop and jam orders (only rewrites the shipped wording). */
const MARKET176_OLD = [
    ["“three grade-B carrots”, “a jam of quality 70+”, “an arrangement scoring 60+”", "“three carrots”, “a jar of jam”, “an arrangement scoring 60+”"],
    ["[b]Quality[/b] comes from how you grew or made the thing. A crop's grade is its Harvest Fair score (a rich, healthy, high-grade bed does best). A preserve's quality is its jar's score. An arrangement carries its own score. Goods you bought count as plain. Keep your best crops back for orders.", "[b]Quality[/b]: crop and jam orders take any quality. An arrangement order wants a score, and every arrangement carries its own. Quality still counts at the Harvest Fair and in the market-day basket judging (a rich, healthy, high-grade bed grows the best crops)."],
];
function market176_almanac(): void
{
    $r = q_one("SELECT id, body FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", ['Orders, market day and prices']);
    if (!$r) return;
    $body = (string)$r['body'];
    foreach (MARKET176_OLD as [$old, $new]) if (str_contains($body, $old)) $body = str_replace($old, $new, $body);
    if ($body !== (string)$r['body']) q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [$body, (int)$r['id']]);
}

/** One-off 1.0.0 upgrade (also run for fresh installs): Almanac page, old favours carried over. Idempotent; guarded by the market100 setting. */
function upgrade_100_market(): void
{
    if (setting('market100') === '1') return;
    foreach (MARKET_ALMANAC as $title => [$sort, $body]) {
        if (q_val("SELECT 1 FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title])) continue;
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => $title, 'body' => $body, 'unlock_key' => 'start', 'hint' => '', 'sort_order' => $sort]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) { /* already there */ }
        }
    }
    // The old weekly favours stay as history: copy each into npc_orders as a finished 'legacy' order in the round it was done.
    try {
        $L = max(3, min(28, (int)setting('orders_cycle_days') ?: 7));
        foreach (q('SELECT user_id, npc_id, done_at FROM npc_favours')->fetchAll() as $f) {
            $cycle = intdiv(hollow_day_number(substr((string)$f['done_at'], 0, 10)), $L);
            try { db_insert('npc_orders', ['user_id' => $f['user_id'], 'npc_id' => $f['npc_id'], 'cycle' => $cycle, 'kind' => 'legacy', 'quality' => 0, 'coins' => 0, 'done_at' => $f['done_at']]); } catch (PDOException $e) { /* already copied */ }
        }
    } catch (PDOException $e) { /* no favours table yet */ }
    set_setting('market100', '1');
    setting('__reload__');
}

/** For pages: make sure the 1.0.0 market content exists even if db_version was set without the upgrade running (a dev copy). */
function market_boot(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    if (setting('market100') !== '1') {
        require_once __DIR__ . '/upgrade100.php';
        upgrade_100_run_step('market');   // v1.0.0: guarded, locked, logged; retried at most every 10 minutes if it fails
    }
}

/** Remove a gnome's market rows (Admin → Fresh start). Call inside the caller's transaction. */
function market_fresh_start(int $uid): void
{
    foreach (['item_quality', 'npc_orders', 'market_buys', 'market_baskets'] as $t) q("DELETE FROM $t WHERE user_id = ?", [$uid]);
}

// ======================================================================= helpers

function mk_h(string $s): int { return crc32($s); }

/** The Hollow's date to use (a test can pass one). */
function mk_date(?string $date = null): string { return hollow_clock_date($date); }

/** 0 = Sunday … 6 = Saturday for a Hollow date. */
function mk_weekday(string $date): int { return (int)gmdate('w', strtotime($date . ' 00:00:00 UTC')); }

/** Weeks counted so that a new one starts on Monday (same for everyone). */
function mk_week(?string $date = null): int { return intdiv(hollow_day_number(mk_date($date)) + 3, 7); }

function mk_int(string $name, int $def): int { $v = trim(setting($name)); return $v === '' ? $def : (int)$v; }

function market_grade(int $q): string
{
    foreach (MARKET_GRADES as [$min, $l]) if ($q >= $min) return $l;
    return 'F';
}

/** "Grade B+ (60+)" for a quality bar. */
function market_bar_label(int $minq): string
{
    return $minq <= 0 ? 'any quality' : 'grade ' . market_grade($minq) . '+ (quality ' . $minq . '+)';
}

/** [name => ['plant'=>row]] helpers: item id => seasons csv ('' = none) for seeds and crops, cached. */
function market_item_seasons(int $itemId): ?string
{
    static $map = null;
    if ($map === null) {
        $map = [];
        $flower = [];
        if (is_file(__DIR__ . '/flower_art.php')) { require_once __DIR__ . '/flower_art.php'; if (function_exists('flower_looks')) $flower = flower_looks(); }
        $codes = ['sp' => 'spring', 'su' => 'summer', 'au' => 'autumn', 'wi' => 'winter'];
        foreach (q('SELECT slug, kind, seasons, seed_item_id, produce_item_id FROM plants')->fetchAll() as $p) {
            $csv = strtolower(trim((string)($p['seasons'] ?? '')));
            if ($csv === '' && $p['kind'] === 'flower' && isset($flower[$p['slug']])) {
                $csv = implode(',', array_map(fn($c) => $codes[$c] ?? '', $flower[$p['slug']][2]));
                if (count($flower[$p['slug']][2]) >= 4) $csv = '';
            }
            if ($csv === '') $csv = MARKET_KIND_SEASONS[$p['kind']] ?? '';
            if ($csv === '') continue;
            if ($p['seed_item_id']) $map[(int)$p['seed_item_id']] = $csv;
            if ($p['produce_item_id']) $map[(int)$p['produce_item_id']] = $csv;
        }
    }
    return $map[$itemId] ?? null;
}

// ======================================================================= price drift

/** All sales-pressure rows: item id => [units, unix time]. Cached for the request; $reset re-reads. */
function market_vol_rows(bool $reset = false, ?array $set = null): array
{
    static $rows = null;
    if ($set !== null && $rows !== null) { $rows[$set[0]] = [$set[1], $set[2]]; return $rows; }   // v1.0.0: update one item in place (a bulk sell no longer re-reads the table per stack)
    if ($rows === null || $reset) {
        $rows = [];
        try { foreach (q('SELECT item_id, vol, at FROM market_volume')->fetchAll() as $r) $rows[(int)$r['item_id']] = [(float)$r['vol'], (int)strtotime($r['at'] . ' UTC')]; } catch (PDOException $e) { /* table not made yet */ }
    }
    return $rows;
}

/** Sales pressure (fractional units) on an item right now: it halves every price_vol_halflife days. */
function market_volume(int $itemId, ?int $at = null): float
{
    $r = market_vol_rows()[$itemId] ?? null;
    if (!$r) return 0.0;
    $days = max(0.0, (($at ?? time()) - $r[1]) / 86400);
    return $r[0] * (0.5 ** ($days / max(1, mk_int('price_vol_halflife', 3))));
}

/** Record a sale of $qty of an item to the shops. Keeps one row per item. */
function market_volume_add(int $itemId, int $qty): void
{
    if ($qty <= 0) return;
    $new = min(100000.0, market_volume($itemId) + $qty);
    if (q('UPDATE market_volume SET vol = ?, at = ? WHERE item_id = ?', [$new, now(), $itemId])->rowCount() < 1) {
        try { db_insert('market_volume', ['item_id' => $itemId, 'vol' => $new, 'at' => now()]); } catch (PDOException $e) { q('UPDATE market_volume SET vol = vol + ?, at = ? WHERE item_id = ?', [$qty, now(), $itemId]); }
    }
    market_vol_rows(false, [$itemId, $new, time()]);
}

/** The wanted-this-week goods: [item id => true]. Same for everyone. */
function market_wanted(?string $date = null): array
{
    static $cache = [];
    $week = mk_week($date);
    if (isset($cache[$week])) return $cache[$week];
    $n = mk_int('price_wanted_count', 6);
    $out = [];
    if ($n > 0) {
        // v1.0.0: worked out once a week and kept in a settings row (the same for everyone), so a page doesn't hash every item
        $key = 'market_wanted_' . $week;
        $saved = setting($key);
        if ($saved !== '' && strncmp($saved, $n . ':', strlen((string)$n) + 1) === 0) {
            foreach (array_filter(array_map('intval', explode(',', substr($saved, strlen((string)$n) + 1)))) as $id) $out[$id] = true;
        } else {
            $ids = q("SELECT id FROM items WHERE category IN ('produce','flower','food','forage') AND tradable = 1 AND NOT (category = 'flower' AND slug LIKE 'dried-%') ORDER BY id")->fetchAll(PDO::FETCH_COLUMN);
            $h = [];
            foreach ($ids as $id) $h[(int)$id] = mk_h("want|$week|$id");
            usort($ids, fn($a, $b) => $h[(int)$a] <=> $h[(int)$b]);
            foreach (array_slice($ids, 0, $n) as $id) $out[(int)$id] = true;
            try {
                q("DELETE FROM settings WHERE name LIKE 'market_wanted_%' AND name <> ?", [$key]);
                set_setting($key, $n . ':' . implode(',', array_keys($out)));
                setting('__reload__');
            } catch (Throwable $e) { /* a cache is never worth a broken page */ }
        }
    }
    return $cache[$week] = $out;
}

function market_is_wanted(int $itemId, ?string $date = null): bool { return isset(market_wanted($date)[$itemId]); }

/**
 * Why a shop pays what it does for an item: ['pct' => final %, 'base', 'noise', 'season' (-1 in season / 0 / +1 off), 'wanted', 'market', 'vol' (points off), 'trend' => up|down|flat].
 * Shop prices stay between price_min_pct and price_max_pct. Dried flowers and arrangements are not seasonal.
 */
function market_price_parts(array $item, ?string $date = null): array
{
    $base = mk_int('price_base_pct', 60);
    $lo = mk_int('price_min_pct', 45);
    $hi = max($lo, mk_int('price_max_pct', 80));
    $flat = ['pct' => $base, 'base' => $base, 'noise' => 0, 'season' => 0, 'wanted' => false, 'market' => false, 'vol' => 0, 'trend' => 'flat'];
    $id = (int)($item['id'] ?? 0);
    if (setting('price_drift_on') !== '1' || $id <= 0) return $flat;
    $date = mk_date($date);
    $noiseMax = mk_int('price_noise', 6);
    $noise = $noiseMax > 0 ? (mk_h('pn|' . mk_week($date) . '|' . $id) % (2 * $noiseMax + 1)) - $noiseMax : 0;
    $season = 0;
    $csv = market_item_seasons($id);
    if ($csv !== null) $season = hollow_in_season($csv, $date) ? -1 : 1;
    $swing = mk_int('price_season_swing', 6);
    $wanted = market_is_wanted($id, $date);
    $market = $wanted && market_day_on($date);
    $vol = (int)min(mk_int('price_vol_max', 12), floor(market_volume($id) / max(1, mk_int('price_vol_units', 8))));
    $pct = $base + $noise + $season * $swing + ($wanted ? mk_int('price_wanted_bonus', 12) : 0) + ($market ? mk_int('price_market_bonus', 8) : 0) - $vol;
    $pct = max($lo, min($hi, $pct));
    return ['pct' => $pct, 'base' => $base, 'noise' => $noise, 'season' => $season, 'wanted' => $wanted, 'market' => $market, 'vol' => $vol,
        'trend' => $pct >= $base + 3 ? 'up' : ($pct <= $base - 3 ? 'down' : 'flat')];
}

/** The sell % for an item (what sell_price() multiplies the base price by). */
function market_sell_pct(array $item, ?string $date = null): int
{
    return market_price_parts($item, $date)['pct'];
}

/** What shops charge: a seed or crop in season is a little cheaper, out of season a little dearer (1.0 = no change). */
function market_buy_mult(int $itemId, ?string $date = null): float
{
    if (setting('price_drift_on') !== '1' || $itemId <= 0) return 1.0;
    $csv = market_item_seasons($itemId);
    if ($csv === null) return 1.0;
    $s = max(0, min(30, mk_int('price_buy_season', 6)));
    return hollow_in_season($csv, mk_date($date)) ? (100 - $s) / 100 : (100 + $s) / 100;
}

/** The little ↑/↓ chip (and “wanted” star) for the Sell tab. Already escaped HTML; '' when the price is unremarkable. */
function market_chip(array $item): string
{
    $p = market_price_parts($item);
    $why = [];
    if ($p['wanted']) $why[] = 'wanted this week' . ($p['market'] ? ' (market day)' : '');
    if ($p['season'] < 0) $why[] = 'in season, plentiful';
    if ($p['season'] > 0) $why[] = 'out of season, scarce';
    if ($p['vol'] > 0) $why[] = 'lots have been sold lately';
    $arrow = ['up' => '↑', 'down' => '↓', 'flat' => '·'][$p['trend']];
    $h = '';
    if ($p['wanted']) $h .= '<span class="tag up" title="Wanted this week">⭐ wanted</span> ';
    if ($p['trend'] !== 'flat' || $why) $h .= '<span class="tag ' . $p['trend'] . '" title="' . e(ucfirst(implode(', ', $why ?: ['the week’s price wobble'])) . '. Shops pay ' . $p['pct'] . '% of base price (usually ' . $p['base'] . '%).') . '">' . $arrow . ' ' . $p['pct'] . '% <small class="muted">of base</small></span>';
    return trim($h);
}

/** Chip for the Buy tab: seasonal pricing, if any. */
function market_buy_chip(int $itemId): string
{
    $m = market_buy_mult($itemId);
    if ($m < 1.0) return '<span class="tag down" title="In season, so shops charge a little less">🌱 in season ↓</span>';
    if ($m > 1.0) return '<span class="tag up" title="Out of season, so shops charge a little more">🍂 off-season ↑</span>';
    return '';
}

// ======================================================================= quality of what you hold

/** Average quality (0-100) of the stack of an item a gnome holds. Untracked units count as plain. 0 when none held. */
function market_stack_q(int $uid, int $itemId, ?int $qty = null): int
{
    $qty ??= (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $itemId]);
    if ($qty <= 0) return 0;
    $r = q_one('SELECT q, n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $itemId]);
    if (!$r) return MARKET_PLAIN_Q;
    $n = min((int)$r['n'], $qty);
    return (int)round(((int)$r['q'] * $n + MARKET_PLAIN_Q * ($qty - $n)) / $qty);
}

/** $added units of quality $q just joined the stack (call after give_item). */
function market_note_quality(int $uid, int $itemId, int $added, int $q): void
{
    if ($added <= 0 || $itemId <= 0) return;
    $q = max(0, min(100, $q));
    $qty = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $itemId]);
    $prior = max(0, $qty - $added);
    $r = q_one('SELECT q, n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $itemId]);
    $n0 = $r ? min((int)$r['n'], $prior) : 0;
    $q0 = $r ? (int)$r['q'] : 0;
    $n = $n0 + $added;
    $newq = (int)round(($q0 * $n0 + $q * $added) / $n);
    if ($r) q('UPDATE item_quality SET q = ?, n = ? WHERE user_id = ? AND item_id = ?', [$newq, min($n, 100000), $uid, $itemId]);
    else {
        try { db_insert('item_quality', ['user_id' => $uid, 'item_id' => $itemId, 'q' => $newq, 'n' => min($n, 100000)]); }
        catch (PDOException $e) { q('UPDATE item_quality SET q = ?, n = ? WHERE user_id = ? AND item_id = ?', [$newq, min($n, 100000), $uid, $itemId]); }
    }
}

/** Called from do_harvest after the crop is in the satchel: its quality is the Harvest Fair score of the bed. */
function market_note_harvest(array $u, array $t, array $p, int $added): void
{
    if ($added <= 0 || empty($p['produce_item_id'])) return;
    try {
        require_once __DIR__ . '/fair.php';
        market_note_quality((int)$u['id'], (int)$p['produce_item_id'], $added, fair_quality($u, $t, $p));
    } catch (Throwable $e) { error_log('market quality: ' . $e->getMessage()); }
}

// ======================================================================= orders

/** The current round of orders: ['cycle' => n, 'start' => date, 'end' => date, 'len' => days]. */
function orders_cycle(?string $date = null): array
{
    $date = mk_date($date);
    $L = max(3, min(28, mk_int('orders_cycle_days', 7)));
    $k = intdiv(hollow_day_number($date), $L);
    $start = hollow_date_add($date, -(hollow_day_number($date) - $k * $L));
    return ['cycle' => $k, 'start' => $start, 'end' => hollow_date_add($start, $L - 1), 'len' => $L];
}

/** Pools the generator draws from, cached for the request. */
function orders_pools(): array
{
    static $P = null;
    if ($P !== null) return $P;
    $P = ['crop' => [], 'preserve' => [], 'meal' => [], 'feast' => [], 'flower' => [], 'seed' => []];
    $P['crop'] = q("SELECT DISTINCT i.id, i.name, i.base_price FROM plants p JOIN items i ON i.id = p.produce_item_id
                    WHERE p.kind NOT IN ('flower','cover') AND i.tradable = 1 AND (p.common = 1 OR p.id IN (SELECT plant_id FROM plant_regions WHERE tier = 'staple')) ORDER BY i.id")->fetchAll();
    foreach (['preserve' => 'pantry', 'meal' => 'cooking', 'feast' => 'cooking'] as $tier => $cat) {   // dishes and preserves only (tools and decor are recipes too)
        $P[$tier] = q("SELECT DISTINCT i.id, i.name, i.base_price FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.tier = ? AND r.category = ? ORDER BY i.id", [$tier, $cat])->fetchAll();
    }
    require_once __DIR__ . '/flower_art.php';
    $P['flower'] = q("SELECT i.id, i.name, i.slug, i.base_price, i.effects FROM items i WHERE i.category = 'flower' AND i.slug NOT LIKE 'dried-%' AND i.tradable = 1 ORDER BY i.id")->fetchAll();
    foreach ($P['flower'] as &$fl) { $fl['pslug'] = flower_item_slug($fl); $fl['pname'] = preg_replace('/^Cut\s+/u', '', (string)$fl['name']); }
    unset($fl);
    $P['seed'] = q("SELECT id, name FROM items WHERE category = 'seed' ORDER BY rarity DESC, id LIMIT 12")->fetchAll();
    return $P;
}

/**
 * This round's order from one townsfolk, or null when its deadline has passed (or the town has no goods to ask for). Same for every gnome.
 * Keys: npc_id, cycle, kind (crop|preserve|arrangement|dish|feast|dried), item_id (0 = any), item_name, qty, minq, diff 1-3,
 * deadline (last day, Hollow date), days_left, coins, friend, xp, reward_item (['id','name','qty'] or null), text, bar.
 */
function npc_order(array $npc, ?string $date = null): ?array
{
    $date = mk_date($date);
    $cy = orders_cycle($date);
    $nid = (int)$npc['id'];
    $seed = "ord|$nid|{$cy['cycle']}";
    $h = fn(string $k): int => mk_h("$seed|$k");
    $P = orders_pools();

    // what is asked for
    $roll = $h('kind') % 100;
    $kinds = [['crop', 38], ['preserve', 16], ['arrangement', 14], ['dish', 12], ['feast', 4], ['dried', 16]];
    $avail = ['crop' => (bool)$P['crop'], 'preserve' => (bool)$P['preserve'], 'arrangement' => true, 'dish' => (bool)$P['meal'], 'feast' => (bool)$P['feast'], 'dried' => (bool)$P['flower']];
    $kinds = array_values(array_filter($kinds, fn($k) => $avail[$k[0]]));
    if (!$kinds) return null;
    $tot = array_sum(array_column($kinds, 1));
    $pick = $roll * $tot / 100;
    $kind = $kinds[0][0];
    foreach ($kinds as [$k, $w]) { if ($pick < $w) { $kind = $k; break; } $pick -= $w; }

    $itemId = 0; $name = ''; $qty = 1; $minq = 0; $diff = 1; $unit = 20; $text = '';
    $r = $h('bar') % 100;
    $foodQ = (string)setting('orders_food_quality') === '1';   // v1.7.6
    switch ($kind) {
        case 'crop':
            $it = $P['crop'][$h('item') % count($P['crop'])];
            [$minq, $diff] = $r < 30 ? [0, 1] : ($r < 62 ? [45, 1] : ($r < 88 ? [60, 2] : [75, 3]));
            if (!$foodQ) [$minq, $diff] = [0, 1];
            $qty = ($diff === 3 ? 2 : 3) + $h('qty') % 4;
            $itemId = (int)$it['id']; $name = $it['name']; $unit = (int)$it['base_price'];
            $text = 'Could you bring me ' . $qty . ' × ' . $name . ($minq ? ', ' . market_bar_label($minq) : '') . '?';
            break;
        case 'preserve':
            $it = $P['preserve'][$h('item') % count($P['preserve'])];
            [$minq, $diff] = $r < 30 ? [55, 1] : ($r < 65 ? [65, 2] : ($r < 90 ? [75, 2] : [85, 3]));
            if (!$foodQ) [$minq, $diff] = [0, 1];
            $qty = $diff === 3 ? 1 : 1 + $h('qty') % 3;
            $itemId = (int)$it['id']; $name = $it['name']; $unit = max(40, (int)$it['base_price']);
            $text = 'I’m after ' . ($qty > 1 ? $qty . ' × ' : 'a jar of ') . $name . ($minq ? ' of quality ' . $minq . '+' : '') . '.';
            break;
        case 'arrangement':
            [$minq, $diff] = $r < 28 ? [40, 1] : ($r < 62 ? [55, 2] : ($r < 88 ? [70, 2] : [85, 3]));
            $qty = 1; $name = 'Arrangement'; $unit = 70 + $minq;
            $text = 'I’d love an arrangement scoring ' . $minq . '+ for the table.';
            break;
        case 'dish':
            $it = $P['meal'][$h('item') % count($P['meal'])];
            $qty = 2 + $h('qty') % 3; $diff = 1;
            $itemId = (int)$it['id']; $name = $it['name']; $unit = max(30, (int)$it['base_price']);
            $text = 'We are hungry: ' . $qty . ' × ' . $name . ', please.';
            break;
        case 'feast':
            $qty = 1; $diff = 3; $name = 'a feast'; $unit = 200;
            $text = 'I’m hosting! I need a feast (any feast dish).';
            break;
        default:   // dried
            $fl = $P['flower'][$h('item') % count($P['flower'])];
            $diff = 2; $qty = 3 + $h('qty') % 4;
            $name = 'Dried ' . $fl['pname']; $unit = max(10, (int)round((int)$fl['base_price'] * max(50, mk_int('dried_price_pct', 130)) / 100));
            $text = 'Could you hang and dry ' . $qty . ' × ' . $fl['pname'] . ' for me? I need ' . $qty . ' × ' . $name . '.';
            $itemId = (int)q_val('SELECT id FROM items WHERE slug = ?', ['dried-' . $fl['pslug']]) ?: -1;
            break;
    }
    // deadline
    $minD = max(1, min($cy['len'], mk_int('orders_min_days', 3)));
    $dd = $minD + $h('dl') % ($cy['len'] - $minD + 1);
    $deadline = hollow_date_add($cy['start'], $dd - 1);
    if ($date > $deadline) return null;
    $daysLeft = hollow_day_number($deadline) - hollow_day_number($date) + 1;

    $coins = max(40, (int)round($unit * $qty * mk_int('orders_pay_percent', 150) / 100 * [1.0, 1.25, 1.6][$diff - 1]));
    $reward = null;
    if ($diff === 3 && $P['seed']) { $s = $P['seed'][$h('rw') % count($P['seed'])]; $reward = ['id' => (int)$s['id'], 'name' => $s['name'], 'qty' => 1]; }
    elseif ($diff === 2 && $h('rw') % 100 < 45) {
        $sl = ['worm-castings', 'rich-loam'][$h('rw2') % 2];
        $row = q_one('SELECT id, name FROM items WHERE slug = ?', [$sl]);
        if ($row) $reward = ['id' => (int)$row['id'], 'name' => $row['name'], 'qty' => 1];
    }
    return ['npc_id' => $nid, 'cycle' => $cy['cycle'], 'kind' => $kind, 'item_id' => $itemId, 'item_name' => $name, 'qty' => $qty, 'minq' => $minq, 'diff' => $diff,
        'deadline' => $deadline, 'days_left' => $daysLeft, 'coins' => $coins, 'friend' => 5 * $diff, 'xp' => 8 * $diff, 'reward_item' => $reward, 'text' => $text,
        'bar' => $minq > 0 ? market_bar_label($minq) : ''];
}

/** The orders on a town's board right now (those whose deadline has not passed), nicest first. Each: ['npc' => row, 'o' => order]. */
function orders_board(string $town, ?string $date = null): array
{
    require_once __DIR__ . '/town_social.php';
    $cy = orders_cycle($date);
    $folk = town_folk($town);
    usort($folk, fn($a, $b) => mk_h("board|{$cy['cycle']}|{$a['id']}") <=> mk_h("board|{$cy['cycle']}|{$b['id']}"));
    $out = [];
    foreach ($folk as $n) {
        if (count($out) >= max(1, mk_int('orders_board_max', 3))) break;
        if ($o = npc_order($n, $date)) $out[] = ['npc' => $n, 'o' => $o];
    }
    return $out;
}

function order_done(int $uid, int $npcId, int $cycle): bool
{
    return (bool)q_val('SELECT 1 FROM npc_orders WHERE user_id = ? AND npc_id = ? AND cycle = ?', [$uid, $npcId, $cycle]);
}

/**
 * What the gnome holds that meets an order: [takes => [[item id, n], ...], enough => bool, have => int, quality => int|null (their stack's quality), note].
 * Arrangements: the lowest-scoring ones that still pass are used, so your best stays for the show.
 */
function order_check(int $uid, array $o): array
{
    $need = (int)$o['qty'];
    $res = ['takes' => [], 'enough' => false, 'have' => 0, 'quality' => null, 'note' => ''];
    switch ($o['kind']) {
        case 'crop': case 'preserve': case 'dish': case 'dried':
            if ($o['item_id'] <= 0) { $res['note'] = 'You have none yet.'; return $res; }
            $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $o['item_id']]);
            $res['have'] = $have;
            if (in_array($o['kind'], ['crop', 'preserve'], true)) {
                $res['quality'] = $have > 0 ? market_stack_q($uid, (int)$o['item_id'], $have) : null;
                if ($o['minq'] > 0 && $have > 0 && $res['quality'] < $o['minq']) { $res['note'] = 'Yours are ' . market_bar_label($res['quality']) . ': not good enough.'; return $res; }
            }
            if ($have >= $need) { $res['enough'] = true; $res['takes'] = [[(int)$o['item_id'], $need]]; }
            return $res;
        case 'feast':
            $rows = q("SELECT ui.item_id, ui.qty FROM user_items ui WHERE ui.user_id = ? AND ui.qty > 0 AND ui.item_id IN (SELECT output_item_id FROM recipes WHERE tier = 'feast') ORDER BY ui.item_id", [$uid])->fetchAll();
            $have = (int)array_sum(array_column($rows, 'qty'));
            $res['have'] = $have;
            if ($have >= $need) { $res['enough'] = true; $left = $need; foreach ($rows as $r) { if ($left < 1) break; $n = min($left, (int)$r['qty']); $res['takes'][] = [(int)$r['item_id'], $n]; $left -= $n; } }
            return $res;
        case 'arrangement':
            $rows = q("SELECT i.id, i.effects, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'arrangement'", [$uid])->fetchAll();
            $ok = [];
            $best = 0;
            foreach ($rows as $r) {
                $sc = (int)((json_decode((string)$r['effects'], true) ?: [])['arrangement']['score'] ?? 0);
                $best = max($best, $sc);
                if ($sc >= $o['minq']) $ok[] = [$sc, (int)$r['id'], (int)$r['qty']];
            }
            usort($ok, fn($a, $b) => $a[0] <=> $b[0]);
            $res['have'] = (int)array_sum(array_column($ok, 2));
            $res['quality'] = $best ?: null;
            if ($res['have'] >= $need) { $res['enough'] = true; $left = $need; foreach ($ok as [$sc, $id, $qt]) { if ($left < 1) break; $n = min($left, $qt); $res['takes'][] = [$id, $n]; $left -= $n; } }
            elseif ($rows && $best < $o['minq']) $res['note'] = 'Your best scores ' . $best . '.';
            return $res;
    }
    return $res;
}

/** Deliver an order. Returns [ok, message]. */
function order_deliver(array $u, int $npcId, string $town): array
{
    require_once __DIR__ . '/town_social.php';
    require_once __DIR__ . '/friends.php';
    $uid = (int)$u['id'];
    if (setting('orders_on') !== '1') return [false, 'Orders are off right now.'];
    if (!can_reach($u, $town)) return [false, 'You need to be in ' . $town . '.'];
    $npc = q_one('SELECT n.* FROM npcs n JOIN town_spots t ON t.id = n.fav_spot_id WHERE n.id = ? AND t.region = ? AND n.active = 1 AND n.traveller IS NULL', [$npcId, $town]);
    if (!$npc) return [false, 'Nobody here asked for that.'];
    $o = npc_order($npc);
    if (!$o) return [false, $npc['name'] . '’s order has run out of time.'];
    if (order_done($uid, $npcId, $o['cycle'])) return [false, 'You’ve already filled ' . $npc['name'] . '’s order.'];
    $c = order_check($uid, $o);
    if (!$c['enough']) return [false, $c['note'] ?: 'You don’t have what ' . $npc['name'] . ' asked for yet.'];
    db()->beginTransaction();
    try {
        db_insert('npc_orders', ['user_id' => $uid, 'npc_id' => $npcId, 'cycle' => $o['cycle'], 'kind' => $o['kind'], 'quality' => (int)($c['quality'] ?? 0), 'coins' => $o['coins'], 'done_at' => now()]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, 'You’ve already filled ' . $npc['name'] . '’s order.'];
    }
    foreach ($c['takes'] as [$iid, $n]) {
        if (!give_item($uid, $iid, -$n)) { db()->rollBack(); return [false, 'Your goods have gone missing.']; }
    }
    $bonus = (int)round($o['coins'] * 0.04 * friend_level((int)friendship($uid, $npcId)['points'])['index']);   // friends pay a little more
    $coins = $o['coins'] + $bonus;
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    add_xp($uid, $o['xp']);
    $new = friend_add($uid, $npcId, $o['friend']);
    $lines = ['−' . $o['qty'] . ' × ' . $o['item_name'], '+' . money($coins) . ($bonus ? ' (friends pay a little extra)' : ''), '+' . $o['xp'] . ' XP', '💛 +' . $o['friend'] . ' friendship (' . friend_level($new)['name'] . ')'];
    if ($o['reward_item']) { give_item($uid, $o['reward_item']['id'], $o['reward_item']['qty']); $lines[] = '🎁 +' . $o['reward_item']['qty'] . ' × ' . $o['reward_item']['name']; }
    db()->commit();
    prize(npc_icon($npc['species']), $npc['name'] . ' is delighted!', '“' . ['Just what I needed.', 'Oh, lovely work.', 'Now that is quality!'][$o['diff'] - 1] . '”', $lines);
    return [true, ''];
}

/** The order board, drawn as a box (Notice Board and the Quests tab). $sid = spot id (0 from the Quests tab). */
function orders_board_box(int $uid, string $town, bool $hub, int $sid): void
{
    $board = orders_board($town);
    $cy = orders_cycle(); ?>
    <div class="box favours orders" id="orders"><h3>📜 Orders from the townsfolk</h3>
      <p class="help">Fill an order before its deadline. Harder orders (a higher quality bar) pay more. New orders every <?= (int)$cy['len'] ?> days; next round <?= e(date('D j M', strtotime(hollow_date_add($cy['end'], 1) . ' UTC'))) ?>.</p>
      <?php foreach ($board as ['npc' => $n, 'o' => $o]):
          $done = order_done($uid, (int)$n['id'], $o['cycle']);
          $c = $done ? null : order_check($uid, $o); ?>
        <div class="favour order d<?= (int)$o['diff'] ?><?= $done ? ' done' : '' ?>"><span class="ficon"><?= npc_icon($n['species']) ?></span>
          <div><b><a href="<?= e(url('folk.php?id=' . (int)$n['id'])) ?>"><?= e($n['name']) ?></a></b>: “<?= e($o['text']) ?>”
            <br><small>
              <span class="tag" role="img" aria-label="Difficulty: <?= (int)$o['diff'] ?> of 3" title="Difficulty"><?= str_repeat('★', $o['diff']) . str_repeat('☆', 3 - $o['diff']) ?></span>
              <?php if ($o['bar']): ?><span class="tag"><?= e($o['bar']) ?></span> <?php endif; ?>
              <span class="tag <?= $o['days_left'] <= 1 ? 'warn' : '' ?>">⏳ <?= $o['days_left'] ?> day<?= $o['days_left'] === 1 ? '' : 's' ?> left</span></small>
            <br><small class="muted">Reward: <?= money($o['coins']) ?>, <?= (int)$o['xp'] ?> XP, +<?= (int)$o['friend'] ?> friendship<?= $o['reward_item'] ? ', 🎁 ' . e($o['reward_item']['name']) : '' ?>
              <?php if ($c): ?> · you have <?= (int)$c['have'] ?><?= $c['quality'] !== null && ($o['kind'] === 'arrangement' || $o['minq'] > 0) ? ' (' . ($o['kind'] === 'arrangement' ? 'best ' . (int)$c['quality'] : 'grade ' . e(market_grade((int)$c['quality'])) . ', ' . (int)$c['quality']) . ')' : '' ?><?= $c['note'] ? ' · ' . e($c['note']) : '' ?><?php endif; ?></small></div>
          <?php if ($done): ?><span class="muted">✔️ Delivered</span>
          <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="order"><input type="hidden" name="npc" value="<?= (int)$n['id'] ?>">
            <input type="hidden" name="spot" value="<?= $sid ?>"><?php if (!$sid): ?><input type="hidden" name="view" value="quests"><?php endif; ?><?php if ($hub): ?><input type="hidden" name="hub" value="1"><?php endif; ?>
            <button class="btn small" <?= $c['enough'] ? '' : 'disabled' ?>>Deliver</button></form><?php endif; ?>
        </div>
      <?php endforeach; ?>
      <?php if (!$board): ?><p class="muted">No open orders in <?= e($town) ?> right now. The next round is pinned on <?= e(date('D j M', strtotime(hollow_date_add($cy['end'], 1) . ' UTC'))) ?>.</p><?php endif; ?>
    </div>
<?php
}

/** Number of open (not yet delivered) orders on a town's board for this gnome. */
function orders_open_count(int $uid, string $town): int
{
    $n = 0;
    foreach (orders_board($town) as $b) if (!order_done($uid, (int)$b['npc']['id'], $b['o']['cycle'])) $n++;
    return $n;
}

// ======================================================================= market day

function market_day_on(?string $date = null): bool
{
    if (setting('market_on') !== '1') return false;
    return mk_weekday(mk_date($date)) === max(0, min(6, mk_int('market_day', 6)));
}

/** Days until the next market day (0 = today). -1 when markets are off. */
function market_days_until(?string $date = null): int
{
    if (setting('market_on') !== '1') return -1;
    $date = mk_date($date);
    return (max(0, min(6, mk_int('market_day', 6))) - mk_weekday($date) + 7) % 7;
}

/**
 * What a stall charges for one: base price x the stall markup (115%) x the day's wobble (90-110%) x the rarity multiplier shops
 * pay on top (Uncommon, Rare, Legendary), so buying at a stall and selling back to a shop never makes money. $L is a fresh
 * item_lookups() (cached for the request).
 */
function market_stall_price(array $it, int $wobble, ?array $L = null): int
{
    static $RL = null;
    require_once __DIR__ . '/items.php';
    $L ??= ($RL ??= item_lookups());
    $mult = ['C' => 100, 'U' => mk_int('sell_mult_uncommon', 130), 'R' => mk_int('sell_mult_rare', 180), 'L' => mk_int('sell_mult_legendary', 250)][item_rarity($it, $L)[0]] ?? 100;
    return max(1, (int)round((int)$it['base_price'] * mk_int('market_stall_markup', 115) / 100 * $wobble / 100 * max(1, $mult) / 100));
}

/** The stalls in a town's square today: [['npc' => row, 'goods' => [['item' => row, 'price' => int], ...]], ...]. Same for everyone. */
function market_stalls(string $town, ?string $date = null): array
{
    require_once __DIR__ . '/town_social.php';
    $date = mk_date($date);
    $folk = town_folk($town);
    usort($folk, fn($a, $b) => mk_h("stall|$date|$town|{$a['id']}") <=> mk_h("stall|$date|$town|{$b['id']}"));
    static $pool = null;
    $pool ??= q("SELECT id, name, slug, category, base_price, rarity, image FROM items WHERE category IN ('seed','produce','flower','food','forage','soil') AND tradable = 1 AND base_price > 0 AND NOT (category = 'flower' AND slug LIKE 'dried-%') ORDER BY id")->fetchAll();
    $out = [];
    foreach (array_slice($folk, 0, max(1, mk_int('market_stalls', 4))) as $n) {
        $items = $pool;
        usort($items, fn($a, $b) => mk_h("stk|$date|{$n['id']}|{$a['id']}") <=> mk_h("stk|$date|{$n['id']}|{$b['id']}"));
        $goods = [];
        foreach (array_slice($items, 0, max(1, mk_int('market_stall_stock', 4))) as $it) {
            $wobble = 90 + mk_h("sp|$date|{$n['id']}|{$it['id']}") % 21;
            $goods[] = ['item' => $it, 'price' => market_stall_price($it, $wobble)];
        }
        $out[] = ['npc' => $n, 'goods' => $goods];
    }
    return $out;
}

function market_bought_today(int $uid, int $npcId, int $itemId, ?string $date = null): int
{
    return (int)q_val('SELECT n FROM market_buys WHERE user_id = ? AND day = ? AND npc_id = ? AND item_id = ?', [$uid, mk_date($date), $npcId, $itemId]);
}

/** Buy from a market stall. Returns [ok, message]. */
function market_stall_buy(array $u, string $town, int $npcId, int $itemId, int $qty): array
{
    $uid = (int)$u['id'];
    if (!market_day_on()) return [false, 'There’s no market today.'];
    if (!can_reach($u, $town)) return [false, 'You need to be in ' . $town . ' to shop at its market.'];
    $qty = max(1, min(99, $qty));
    $found = null;
    foreach (market_stalls($town) as $s) {
        if ((int)$s['npc']['id'] !== $npcId) continue;
        foreach ($s['goods'] as $g) if ((int)$g['item']['id'] === $itemId) $found = [$s['npc'], $g];
    }
    if (!$found) return [false, 'That stall doesn’t sell that today.'];
    [$npc, $g] = $found;
    $limit = mk_int('market_stall_limit', 3);
    $had = market_bought_today($uid, $npcId, $itemId);
    if ($had + $qty > $limit) return [false, $npc['name'] . ' will only sell you ' . $limit . ' of those a day' . ($had ? ' (you’ve had ' . $had . ')' : '') . '.'];
    $cost = $g['price'] * $qty;
    return db_tx(function () use ($uid, $npcId, $itemId, $qty, $cost, $limit, $g, $npc): array {
        if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $uid, $cost])->rowCount() !== 1) {
            db()->rollBack();
            return [false, 'You can’t afford ' . $qty . ' × ' . $g['item']['name'] . ' (' . number_format($cost) . ' ' . setting('currency_name') . ').'];
        }
        // v1.0.0: the daily limit is part of the update itself, so two devices can't both slip under it
        if (q('UPDATE market_buys SET n = n + ? WHERE user_id = ? AND day = ? AND npc_id = ? AND item_id = ? AND n + ? <= ?', [$qty, $uid, mk_date(), $npcId, $itemId, $qty, $limit])->rowCount() < 1) {
            if (q_val('SELECT 1 FROM market_buys WHERE user_id = ? AND day = ? AND npc_id = ? AND item_id = ?', [$uid, mk_date(), $npcId, $itemId])) {
                db()->rollBack();
                return [false, $npc['name'] . ' will only sell you ' . $limit . ' of those a day.'];
            }
            try { db_insert('market_buys', ['user_id' => $uid, 'day' => mk_date(), 'npc_id' => $npcId, 'item_id' => $itemId, 'n' => $qty]); }
            catch (PDOException $e) { db()->rollBack(); return [false, 'Try that again.']; }
        }
        give_item($uid, $itemId, $qty);
        return [true, '🧺 You buy ' . $qty . ' × ' . $g['item']['name'] . ' from ' . $npc['name'] . ' for ' . number_format($cost) . ' ' . setting('currency_name') . '.'];
    });
}

/** Points one item earns in the best-basket judging (0-100). */
function basket_item_points(int $uid, array $item): int
{
    $id = (int)$item['id'];
    switch ($item['category']) {
        case 'arrangement':
            return (int)((json_decode((string)$item['effects'], true) ?: [])['arrangement']['score'] ?? 40);
        case 'food':
            $tier = (string)q_val('SELECT tier FROM recipes WHERE output_item_id = ? LIMIT 1', [$id]);
            if ($tier === 'preserve') return market_stack_q($uid, $id);   // a jar's own score
            return ['snack' => 40, 'meal' => 62, 'feast' => 85][$tier] ?? 45;
        case 'produce':
            return market_stack_q($uid, $id);
        case 'flower':
            return min(100, 38 + (int)round((int)$item['rarity'] * 0.45));
        default:
            return min(100, 35 + (int)round((int)$item['rarity'] * 0.5));
    }
}

/** Score a basket (list of item rows): the average of the items, a little extra for variety and for wanted goods. */
function basket_score(int $uid, array $items): int
{
    if (!$items) return 0;
    $pts = []; $cats = []; $wanted = 0;
    foreach ($items as $it) {
        $pts[] = basket_item_points($uid, $it); $cats[$it['category']] = true;
        if (market_is_wanted((int)$it['id'])) $wanted++;
    }
    return (int)max(0, min(100, round(array_sum($pts) / count($pts) + 3 * min(3, count($cats) - 1) + 2 * min(4, $wanted))));
}

/** The three townsfolk baskets to beat today in a town: [['npc' => row, 'score' => n], ...] easiest first. */
function basket_rivals(string $town, ?string $date = null): array
{
    require_once __DIR__ . '/town_social.php';
    $date = mk_date($date);
    $folk = town_folk($town);
    usort($folk, fn($a, $b) => mk_h("bk|$date|$town|{$a['id']}") <=> mk_h("bk|$date|$town|{$b['id']}"));
    $out = [];
    foreach ([[44, 12], [58, 12], [72, 10]] as $i => [$lo, $span]) {
        $n = $folk[$i % max(1, count($folk))] ?? null;
        if (!$n) break;
        $out[] = ['npc' => $n, 'score' => $lo + mk_h("bks|$date|$town|$i") % $span];
    }
    return $out;
}

function basket_reward(int $beat): int
{
    $r = array_map('intval', explode(',', (string)setting('basket_rewards')));
    return max(0, (int)($r[max(0, min(3, $beat))] ?? 0));
}

function basket_entry(int $uid, ?string $date = null): ?array
{
    $r = q_one('SELECT * FROM market_baskets WHERE user_id = ? AND day = ?', [$uid, mk_date($date)]);
    return $r ?: null;
}

/** Enter the best-basket judging with up to 5 different items from the satchel (they are shown, not handed over). Returns [ok, message]. */
function basket_enter(array $u, string $town, array $itemIds): array
{
    $uid = (int)$u['id'];
    if (setting('basket_on') !== '1' || !market_day_on()) return [false, 'There’s no judging today.'];
    if (!can_reach($u, $town)) return [false, 'You need to be in ' . $town . '.'];
    if (basket_entry($uid)) return [false, 'You’ve already shown a basket today.'];
    $ids = array_slice(array_values(array_unique(array_filter(array_map('intval', $itemIds), fn($i) => $i > 0))), 0, 5);
    if (!$ids) return [false, 'Pick at least one thing for your basket.'];
    $items = [];
    foreach ($ids as $id) {
        $it = q_one("SELECT i.*, ui.qty FROM items i JOIN user_items ui ON ui.item_id = i.id AND ui.user_id = ? WHERE i.id = ? AND ui.qty > 0 AND i.category IN ('produce','flower','food','forage','arrangement')", [$uid, $id]);
        if (!$it) return [false, 'One of those isn’t in your Satchel any more.'];
        $items[] = $it;
    }
    $score = basket_score($uid, $items);
    $rivals = basket_rivals($town);
    $beat = count(array_filter($rivals, fn($r) => $score > $r['score']));
    $coins = basket_reward($beat);
    db()->beginTransaction();
    try {
        db_insert('market_baskets', ['user_id' => $uid, 'day' => mk_date(), 'town' => $town, 'score' => $score, 'beat' => $beat, 'coins' => $coins, 'items' => json_encode(array_column($items, 'name'))]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, 'You’ve already shown a basket today.'];
    }
    if ($coins > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    add_xp($uid, 5 + 5 * $beat);
    db()->commit();
    $lines = array_map(fn($r) => ($score > $r['score'] ? '✔ beat ' : '✖ lost to ') . $r['npc']['name'] . ' (' . $r['score'] . ')', $rivals);
    $lines[] = '+' . money($coins);
    prize('🧺', 'Your basket scores ' . $score . '!', $beat === 3 ? 'Best in the market!' : ($beat ? 'Beat ' . $beat . ' of 3' : 'Not this time'), $lines);
    return [true, ''];
}

/** Sell wanted goods to the market buyers at today's prices. Returns [ok, message]. */
function market_sell_wanted(array $u, string $town, int $itemId, int $qty): array
{
    if (!market_day_on()) return [false, 'There’s no market today.'];
    if (!can_reach($u, $town)) return [false, 'You need to be in ' . $town . '.'];
    if (!market_is_wanted($itemId)) return [false, 'The market buyers only want this week’s wanted goods.'];
    $r = sell_to_shop($u, $itemId, $qty, 0);
    return [$r[0], $r[1]];
}

/** Today page card + town square banner data. Returns HTML of one small card (or ''). */
function market_today_card(array $u, string $town): string
{
    $uid = (int)$u['id'];
    $h = '';
    $open = setting('orders_on') === '1' ? orders_open_count($uid, $town) : 0;
    if (setting('orders_on') === '1') {
        $b = array_values(array_filter(orders_board($town), fn($x) => !order_done($uid, (int)$x['npc']['id'], $x['o']['cycle'])));
        $h .= '<a class="box tcard" href="' . e(url('jobs.php?t=orders#orders')) . '"><h3>📜 Orders</h3><p>';
        if ($b) {
            foreach (array_slice($b, 0, 3) as $x) $h .= e($x['npc']['name']) . ': ' . (int)$x['o']['qty'] . ' × ' . e($x['o']['item_name']) . ($x['o']['minq'] ? ' <small class="muted">' . e(market_grade($x['o']['minq'])) . '+</small>' : '') . ' <small class="muted">⏳' . (int)$x['o']['days_left'] . 'd</small><br>';
            if ($open > 3) $h .= '<span class="muted">and ' . ($open - 3) . ' more</span>';
        } else $h .= '<span class="muted">Nothing open in ' . e($town) . ' right now.</span>';
        $h .= '</p><span class="tgo">Order board →</span></a>';
    }
    if (market_day_on()) {
        $h .= '<a class="box tcard marketcard" href="' . e(url('marketday.php')) . '"><h3>🧺 Market day!</h3><p><b>Stalls are up in ' . e($town) . '.</b><br>Wanted goods pay more, and the best-basket judging is on.</p><span class="tgo">To the market →</span></a>';
    } elseif (($d = market_days_until()) > 0) {
        $h .= '<a class="box tcard marketcard" href="' . e(url('marketday.php')) . '"><h3>🧺 Market day</h3><p class="muted">' . MARKET_WEEKDAYS[max(0, min(6, mk_int('market_day', 6)))] . ' (in ' . $d . ' day' . ($d === 1 ? '' : 's') . '). Stock up on goods to sell and show.</p><span class="tgo">What’s wanted →</span></a>';
    }
    return $h;
}

/** Right-rail box: market day now, or when the next one is, and the week’s wanted goods. */
function market_rail_section(): string
{
    if (setting('market_on') !== '1' && setting('price_drift_on') !== '1') return '';
    // v1.0.1: the same for everyone and it only changes with the day, so each gnome keeps a copy for 10 minutes
    $ck = hollow_date('Y-m-d') . '|' . setting('market_day') . '|' . setting('price_wanted_count');
    $c = $_SESSION['gv_mrail'] ?? null;
    if (is_array($c) && ($c['k'] ?? '') === $ck && ($c['at'] ?? 0) > time() - 600) return (string)$c['h'];
    $h = market_rail_build();
    $_SESSION['gv_mrail'] = ['k' => $ck, 'at' => time(), 'h' => $h];
    return $h;
}

function market_rail_build(): string
{
    $now = market_day_on();
    $h = '<section class="rbox rmarket" aria-labelledby="rt-market"><h3 id="rt-market">🧺 Market' . ($now ? ' <b class="rbadge">today</b>' : '') . '</h3>';
    if ($now) $h .= '<p class="rhnow"><a href="' . e(url('marketday.php')) . '">Stalls are up. Wanted goods pay extra.</a></p>';
    elseif (($d = market_days_until()) > 0) $h .= '<p class="muted rempty">Market day in ' . $d . ' day' . ($d === 1 ? '' : 's') . ' (' . e(MARKET_WEEKDAYS[max(0, min(6, mk_int('market_day', 6)))]) . ').</p>';
    $w = market_wanted();
    if ($w) {
        $names = q('SELECT name FROM items WHERE id IN (' . implode(',', array_map('intval', array_slice(array_keys($w), 0, 6))) . ') ORDER BY name')->fetchAll(PDO::FETCH_COLUMN);
        $h .= '<ul class="rlist"><li><span>⭐ Wanted</span> <small class="rtime">' . e(implode(', ', array_slice($names, 0, 3))) . (count($names) > 3 ? '…' : '') . '</small></li></ul>';
    }
    return $h . '</section>';
}
