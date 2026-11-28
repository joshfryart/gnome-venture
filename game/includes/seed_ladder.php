<?php
declare(strict_types=1);
/**
 * 2.8.100 The seed ladder (claude/proposal-seed-ladder.md). Behind `seed_ladder_open` (default 0): with it off nothing here is read and every
 * shop sells exactly what it sells today.
 *
 * A seed row of Twigg's (the hub) or a region town's seed shop carries a gate key (shop_stock.ladder_gate, filled once from
 * data/seed_ladder.txt by seed_ladder_ensure(); Admin may edit it; '' = on the shelf from the first visit). Per gnome a gated row is hidden
 * (and refused by buy_from_shop()) until one of these holds, checked live and then latched for good (seed_ladder_gates / seed_ladder_items):
 *   the gnome has harvested that crop once (S3) · a chapter in play or an errand whose trigger holds names it (S2) · it is this week's
 *   Village Show crop · an old gnome held or planted it when the ladder came (decision 6) · its gate is open:
 *     Twigg's  m1 5 / m2 10 / m3 16 / m4 24 different crops harvested, or the road way (bars, latches, the Maplewold town state, a Seal)
 *     a town   r1 2 staples of the area / r2 6 plants / r3 3 flowers / r4 12 plants harvested, or the road way (the town's bars, its state, Cheer, the Seal)
 * The road ways read lasting marks, town states and Seals only while their own settings are on; with them off the garden ways carry the ladder.
 * The shared shelf is never changed: hidden rows restock and are priced as before (shop_restock() untouched). A bare start row still sells
 * 10 a game day to the gnome at price_max (the bottom drawer, the town_backroom table); a locked seed can be special-ordered once a game day
 * (3 seeds at 2 x price_max).
 */

require_once __DIR__ . '/catalog.php';

const SEED_LADDER_GATES = ['hub' => ['m1', 'm2', 'm3', 'm4'], 'town' => ['r1', 'r2', 'r3', 'r4']];
const SEED_LADDER_NEED = ['m1' => 5, 'm2' => 10, 'm3' => 16, 'm4' => 24, 'r1' => 2, 'r2' => 6, 'r3' => 3, 'r4' => 12];   // the garden ways
const SEED_LADDER_BAR_FLOOR = 34;
const SEED_LADDER_DRAWER = 10;        // S4: a bare start row, per gnome and game day
const SEED_LADDER_ORDER_SEEDS = 3;    // S5: one special order a game day, 3 seeds at 2 x price_max
const SEED_LADDER_ORDER_MULT = 2;
const SEED_LADDER_HUB_AREA = 'NA';    // "the Maplewold" of the hub's road ways
const SEED_LADDER_WREN = [
    'hub' => 'Fourteen jars. It was a hundred once. Grow what’s here and Twigg will find the rest.',
    'town' => 'I asked them to keep five things back for you. They’re what this place needs first.',
    'full' => 'Every hook has a packet on it again. That was you.',
];

function seed_ladder_on(): bool
{
    return setting('seed_ladder_open') === '1';
}

/** [tables, indexes, columns] for schema_statements(). */
function seed_ladder_schema(string $PK, string $ID, string $END): array
{
    $t = [
        // a gate a gnome has opened at a shop (shop 0, gate 'snap' = the one-time snapshot of an old gnome's seeds is done); seen = the flash line was shown
        "CREATE TABLE IF NOT EXISTS seed_ladder_gates (
            user_id $ID NOT NULL,
            shop_id $ID NOT NULL,
            gate VARCHAR(8) NOT NULL,
            opened_at DATETIME NOT NULL,
            seen INT NOT NULL DEFAULT 0,
            PRIMARY KEY (user_id, shop_id, gate)
        )$END",
        // one seed opened for good for a gnome: how = grown (S3), step (S2), held / planted (old gnome)
        "CREATE TABLE IF NOT EXISTS seed_ladder_items (
            user_id $ID NOT NULL,
            item_id $ID NOT NULL,
            how VARCHAR(8) NOT NULL,
            at DATETIME NOT NULL,
            PRIMARY KEY (user_id, item_id)
        )$END",
        // S5: the special order of a gnome's game day
        "CREATE TABLE IF NOT EXISTS seed_ladder_orders (
            user_id $ID NOT NULL,
            day VARCHAR(10) NOT NULL,
            stock_id $ID NOT NULL,
            n INT NOT NULL DEFAULT 0,
            at DATETIME NOT NULL,
            PRIMARY KEY (user_id, day)
        )$END",
    ];
    return [$t, [], [['shop_stock', 'ladder_gate', 'VARCHAR(8) NULL']]];   // NULL = not given a gate yet (seed_ladder_ensure fills seed rows), '' = always
}

/** Make the tables and the column on an install that upgraded before they existed (the version was not bumped). Once per request. */
function seed_ladder_tables(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
    [$t, , $c] = seed_ladder_schema($sqlite ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $sqlite ? 'INTEGER' : 'INT UNSIGNED',
        $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
    try { q('SELECT 1 FROM seed_ladder_orders LIMIT 1'); } catch (Throwable $e) { foreach ($t as $sql) { try { db()->exec($sql); } catch (Throwable $e2) { error_log('seed_ladder table: ' . $e2->getMessage()); } } }
    foreach ($c as [$tb, $col, $def]) {
        try { q("SELECT $col FROM $tb LIMIT 1"); } catch (Throwable $e) { try { db()->exec("ALTER TABLE $tb ADD COLUMN $col $def"); } catch (Throwable $e2) { /* another request added it */ } }
    }
}

/** Per-request caches. */
function &seed_ladder_cache(): array
{
    static $c = [];
    return $c;
}

function seed_ladder_reset(): void
{
    $c = &seed_ladder_cache();
    $c = [];
    if (function_exists('town_states_reset')) town_states_reset();
}

// ---------------------------------------------------------------- data

/** data/seed_ladder.txt: ['hub' => [slug => gate], 'five' => [area code => [slugs]]]. */
function seed_ladder_data(): array
{
    static $d = null;
    if ($d !== null) return $d;
    $d = ['hub' => [], 'five' => []];
    foreach (catalog_lines('seed_ladder.txt') as $r) {
        $kind = array_shift($r);
        $slugs = array_values(array_filter(array_map('trim', explode(',', (string)($r[1] ?? '')))));
        if ($kind === 'H') foreach ($slugs as $s) $d['hub'][$s] = (string)$r[0];
        elseif ($kind === 'F') $d['five'][(string)$r[0]] = $slugs;
    }
    return $d;
}

/** Slugs on a start shelf: [slug => '' for the hub, or the area code of the five that holds it]. */
function seed_ladder_start_slugs(): array
{
    $out = [];
    foreach (seed_ladder_data()['five'] as $code => $slugs) foreach ($slugs as $s) $out[$s] = $code;
    foreach (seed_ladder_data()['hub'] as $s => $g) if ($g === '') $out[$s] = '';
    return $out;
}

/** A shop as the ladder sees it: kind 'hub' (Twigg's), 'town' (a region town's seed shop) or '' (not in the ladder). Cached. */
function seed_ladder_shop_ctx(int $shopId): ?array
{
    $c = &seed_ladder_cache();
    if (!array_key_exists('shop' . $shopId, $c)) {
        $s = q_one('SELECT s.id, s.name, s.shop_type, l.id AS loc_id, l.name AS loc_name, l.kind AS loc_kind, l.region_id, r.code, r.gnomish_name
                    FROM shops s LEFT JOIN locations l ON l.id = s.location_id LEFT JOIN regions r ON r.id = l.region_id WHERE s.id = ?', [$shopId]) ?: null;
        if ($s) $s['kind'] = ($s['shop_type'] ?? '') !== 'seeds' ? '' : (($s['loc_kind'] ?? '') === 'hub' ? 'hub' : (($s['loc_kind'] ?? '') === 'market' && (int)$s['region_id'] > 0 ? 'town' : ''));
        $c['shop' . $shopId] = $s;
    }
    return $c['shop' . $shopId];
}

/** The gate rule for one shop: [stock id => gate] for its seed rows. */
function seed_ladder_rule(int $shopId): array
{
    $ctx = seed_ladder_shop_ctx($shopId);
    if (!$ctx || $ctx['kind'] === '') return [];
    $rows = q("SELECT st.id, st.price_min, p.slug, pr.tier FROM shop_stock st JOIN items i ON i.id = st.item_id AND i.category = 'seed' JOIN plants p ON p.seed_item_id = i.id
               LEFT JOIN plant_regions pr ON pr.plant_id = p.id AND pr.region_id = ? WHERE st.shop_id = ? ORDER BY st.price_min, p.slug, st.id", [(int)($ctx['region_id'] ?? 0), $shopId])->fetchAll();
    $g = [];
    if ($ctx['kind'] === 'hub') {
        $hub = seed_ladder_data()['hub'];
        foreach ($rows as $r) $g[(int)$r['id']] = $hub[$r['slug']] ?? 'm4';
        return $g;
    }
    $left = function (string $tier) use (&$g, $rows): array { return array_values(array_filter($rows, fn($r) => $r['tier'] === $tier && !isset($g[(int)$r['id']]))); };
    $five = seed_ladder_data()['five'][(string)$ctx['code']] ?? null;
    if ($five !== null) {
        foreach ($rows as $r) if (in_array($r['slug'], $five, true)) $g[(int)$r['id']] = '';
    } else {   // a new area: two staples, an uncommon and a flower, filled to five with the cheapest staple (else uncommon) left
        foreach ([['staple', 2], ['uncommon', 1], ['flower', 1]] as [$t, $n]) foreach (array_slice($left($t), 0, $n) as $r) $g[(int)$r['id']] = '';
        while (count(array_keys($g, '', true)) < 5 && ($r = ($left('staple')[0] ?? $left('uncommon')[0] ?? null))) $g[(int)$r['id']] = '';
    }
    foreach ($left('staple') as $r) $g[(int)$r['id']] = 'r1';
    foreach (array_slice($left('flower'), 0, 3) as $r) $g[(int)$r['id']] = 'r1';
    $un = $left('uncommon');
    $half = (int)ceil(count($un) / 2);
    foreach ($un as $i => $r) $g[(int)$r['id']] = $i < $half ? 'r2' : 'r4';
    foreach ($left('flower') as $r) $g[(int)$r['id']] = 'r3';
    foreach ($rows as $r) $g[(int)$r['id']] ??= 'r4';
    return $g;
}

/** Fill ladder_gate of the seed rows that have none (never an Admin's value). Returns rows set. Safe to run any number of times. */
function seed_ladder_ensure(): int
{
    static $ran = false;
    seed_ladder_tables();
    if (seed_ladder_on() && setting('seed_ladder_since') === '') { set_setting('seed_ladder_since', now()); setting('__reload__'); }
    if ($ran) return 0;
    $ran = true;
    $shops = q("SELECT DISTINCT st.shop_id FROM shop_stock st JOIN items i ON i.id = st.item_id JOIN shops s ON s.id = st.shop_id JOIN locations l ON l.id = s.location_id
                WHERE i.category = 'seed' AND s.shop_type = 'seeds' AND l.kind IN ('hub', 'market') AND st.ladder_gate IS NULL")->fetchAll(PDO::FETCH_COLUMN);
    $n = 0;
    foreach ($shops as $sid) {
        foreach (seed_ladder_rule((int)$sid) as $stockId => $gate) $n += q('UPDATE shop_stock SET ladder_gate = ? WHERE id = ? AND ladder_gate IS NULL', [$gate, $stockId])->rowCount();
    }
    return $n;
}

// ---------------------------------------------------------------- what a gnome has done

/** All plants: ['item' => [seed item id => [id, slug, name]], 'slug' => [slug => seed item id], 'produce' => [produce slug => plant slug]]. */
function seed_ladder_plants(): array
{
    $c = &seed_ladder_cache();
    if (!isset($c['plants'])) {
        $p = ['item' => [], 'slug' => [], 'produce' => []];
        foreach (q('SELECT p.id, p.slug, p.name, p.seed_item_id, pi.slug AS produce FROM plants p LEFT JOIN items pi ON pi.id = p.produce_item_id')->fetchAll() as $r) {
            $p['item'][(int)$r['seed_item_id']] = ['id' => (int)$r['id'], 'slug' => (string)$r['slug'], 'name' => (string)$r['name']];
            $p['slug'][(string)$r['slug']] = (int)$r['seed_item_id'];
            if ($r['produce']) $p['produce'][(string)$r['produce']] = (string)$r['slug'];
        }
        $c['plants'] = $p;
    }
    return $c['plants'];
}

/** [plant id => true] of the crops this gnome has harvested (knowledge > 0). */
function seed_ladder_known(int $uid): array
{
    $c = &seed_ladder_cache();
    return $c['known' . $uid] ??= array_fill_keys(array_map('intval', q('SELECT plant_id FROM user_plant_knowledge WHERE user_id = ? AND knowledge > 0', [$uid])->fetchAll(PDO::FETCH_COLUMN)), true);
}

/** [plant id => tier] of an area. */
function seed_ladder_area_plants(int $rid): array
{
    $c = &seed_ladder_cache();
    if (!isset($c['area' . $rid])) {
        $c['area' . $rid] = [];
        foreach (q('SELECT plant_id, tier FROM plant_regions WHERE region_id = ?', [$rid])->fetchAll() as $r) $c['area' . $rid][(int)$r['plant_id']] = (string)$r['tier'];
    }
    return $c['area' . $rid];
}

/** The garden way's count for a gate (different crops / area plants / staples / flowers harvested). */
function seed_ladder_progress(int $uid, array $ctx, string $gate): int
{
    $known = seed_ladder_known($uid);
    if ($ctx['kind'] === 'hub') return count($known);
    $area = seed_ladder_area_plants((int)$ctx['region_id']);
    $n = 0;
    foreach ($area as $pid => $tier) {
        if (!isset($known[$pid])) continue;
        if ($gate === 'r1' ? $tier === 'staple' : ($gate === 'r3' ? $tier === 'flower' : true)) $n++;
    }
    return $n;
}

/** Bars of lasting marks: ['latched' => n, 'cheer' => [location id => region id], 'any34' => bool]. */
function seed_ladder_bars(int $uid): array
{
    $c = &seed_ladder_cache();
    if (isset($c['bars' . $uid])) return $c['bars' . $uid];
    $b = ['latched' => 0, 'cheer' => [], 'any34' => false];
    $b['latched'] = (int)q_val('SELECT COUNT(*) FROM stop_marks WHERE user_id = ?', [$uid]);
    foreach (q("SELECT m.location_id, l.region_id FROM stop_marks m JOIN locations l ON l.id = m.location_id WHERE m.user_id = ? AND m.bar = 'cheer'", [$uid])->fetchAll() as $r) $b['cheer'][(int)$r['location_id']] = (int)$r['region_id'];
    $b['any34'] = $b['latched'] > 0;
    if (!$b['any34']) {
        foreach (q("SELECT location_id, k FROM stop_prog WHERE user_id = ? AND k LIKE 'meter:%'", [$uid])->fetchAll() as $r) {
            if (mark_bar_get($uid, (int)$r['location_id'], substr((string)$r['k'], 6)) >= SEED_LADDER_BAR_FLOOR) { $b['any34'] = true; break; }
        }
    }
    return $c['bars' . $uid] = $b;
}

/** Is the gate open by its garden way or its road way right now (not latched)? */
function seed_ladder_gate_live(int $uid, array $ctx, string $gate): bool
{
    if (seed_ladder_progress($uid, $ctx, $gate) >= (SEED_LADDER_NEED[$gate] ?? PHP_INT_MAX)) return true;
    require_once __DIR__ . '/stop_marks.php';
    $sm = stop_marks_on();
    $ts = false;
    if (setting('town_states_open') === '1') { require_once __DIR__ . '/town_states.php'; $ts = town_states_on(); }
    $seals = setting('seals_open') === '1';
    $bars = $sm ? seed_ladder_bars($uid) : ['latched' => 0, 'cheer' => [], 'any34' => false];
    if ($ctx['kind'] === 'hub') {
        $naRid = (int)q_val('SELECT id FROM regions WHERE code = ?', [SEED_LADDER_HUB_AREA]);
        $naState = $ts && $naRid > 0 ? town_state($uid, $naRid) : '';
        return match ($gate) {
            'm1' => $bars['any34'],
            'm2' => $bars['latched'] >= 1,
            'm3' => in_array($naState, ['work', 'fixed'], true) || $bars['latched'] >= 3,
            'm4' => $naState === 'fixed' || ($seals && (bool)q_val('SELECT 1 FROM region_seals WHERE user_id = ?', [$uid])) || $bars['latched'] >= 8,
            default => false,
        };
    }
    $rid = (int)$ctx['region_id'];
    $state = $ts ? town_state($uid, $rid) : '';
    switch ($gate) {
        case 'r1':   // the town's own bars; a second garden in the area (not the home one)
            if ((bool)q_val('SELECT 1 FROM plots WHERE user_id = ? AND region_id = ? AND region_id <> COALESCE((SELECT region_id FROM users WHERE id = ?), 0)', [$uid, $rid, $uid])) return true;
            if ($sm && (int)$ctx['loc_id'] > 0) foreach (array_keys(MARK_BARS) as $bar) if (mark_bar_get($uid, (int)$ctx['loc_id'], $bar) >= SEED_LADDER_BAR_FLOOR) return true;
            return false;
        case 'r2': return in_array($state, ['work', 'fixed'], true);
        case 'r3':
            if (!$sm) return false;
            if (isset($bars['cheer'][(int)$ctx['loc_id']])) return true;
            return count(array_filter($bars['cheer'], fn($r) => $r === $rid)) >= 2;
        case 'r4':
            if ($state === 'fixed') return true;
            if ($seals) { require_once __DIR__ . '/seals.php'; return seal_held($uid, $rid); }
            return false;
    }
    return false;
}

/** The gates this gnome has latched: [shop id => [gate => true]]. */
function seed_ladder_latched(int $uid): array
{
    $c = &seed_ladder_cache();
    if (!isset($c['latched' . $uid])) {
        $c['latched' . $uid] = [];
        foreach (q('SELECT shop_id, gate FROM seed_ladder_gates WHERE user_id = ?', [$uid])->fetchAll() as $r) $c['latched' . $uid][(int)$r['shop_id']][(string)$r['gate']] = true;
    }
    return $c['latched' . $uid];
}

/** Is a gate of a shop open for a gnome? Live checks that pass are latched (never closes). '' and gates the shop does not have are open. */
function seed_ladder_gate_open(int $uid, int $shopId, string $gate): bool
{
    if ($gate === '') return true;
    $ctx = seed_ladder_shop_ctx($shopId);
    if (!$ctx || $ctx['kind'] === '' || !in_array($gate, SEED_LADDER_GATES[$ctx['kind']], true)) return true;
    seed_ladder_tables();
    if (isset(seed_ladder_latched($uid)[$shopId][$gate])) return true;
    if (!seed_ladder_gate_live($uid, $ctx, $gate)) return false;
    try { db_insert('seed_ladder_gates', ['user_id' => $uid, 'shop_id' => $shopId, 'gate' => $gate, 'opened_at' => now(), 'seen' => 0]); } catch (PDOException $e) { /* another request latched it */ }
    $c = &seed_ladder_cache();
    $c['latched' . $uid][$shopId][$gate] = true;
    return true;
}

/** [item id => how] this gnome has opened for good. */
function seed_ladder_items(int $uid): array
{
    $c = &seed_ladder_cache();
    return $c['items' . $uid] ??= array_column(array_map(fn($r) => ['i' => (int)$r['item_id'], 'h' => (string)$r['how']], q('SELECT item_id, how FROM seed_ladder_items WHERE user_id = ?', [$uid])->fetchAll()), 'h', 'i');
}

function seed_ladder_item_latch(int $uid, int $itemId, string $how): void
{
    try { db_insert('seed_ladder_items', ['user_id' => $uid, 'item_id' => $itemId, 'how' => $how, 'at' => now()]); } catch (PDOException $e) { /* already there */ }
    $c = &seed_ladder_cache();
    $c['items' . $uid][$itemId] = $how;
}

/** Decision 6: a gnome made before the ladder came keeps every seed it held or had planted (once; the marker is gate 'snap' of shop 0). */
function seed_ladder_snapshot(int $uid): void
{
    $c = &seed_ladder_cache();
    if (isset($c['snap' . $uid])) return;
    $c['snap' . $uid] = true;
    if (q_val("SELECT 1 FROM seed_ladder_gates WHERE user_id = ? AND shop_id = 0 AND gate = 'snap'", [$uid])) return;
    try { db_insert('seed_ladder_gates', ['user_id' => $uid, 'shop_id' => 0, 'gate' => 'snap', 'opened_at' => now(), 'seen' => 1]); } catch (PDOException $e) { return; }
    $since = setting('seed_ladder_since');
    $made = (string)q_val('SELECT created_at FROM users WHERE id = ?', [$uid]);
    if ($since === '' || $made === '' || $made >= $since) return;   // a new gnome: the ladder from the start
    $gated = "SELECT item_id FROM shop_stock WHERE COALESCE(ladder_gate, '') <> ''";
    foreach (q("SELECT DISTINCT ui.item_id FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'seed' AND ui.item_id IN ($gated)", [$uid])->fetchAll(PDO::FETCH_COLUMN) as $i) seed_ladder_item_latch($uid, (int)$i, 'held');
    foreach (['plot_tiles', 'cellar_plants'] as $tb) {
        foreach (q("SELECT DISTINCT p.seed_item_id FROM $tb t JOIN plants p ON p.id = t.plant_id WHERE t.user_id = ? AND p.seed_item_id IN ($gated)", [$uid])->fetchAll(PDO::FETCH_COLUMN) as $i) seed_ladder_item_latch($uid, (int)$i, 'planted');
    }
}

// ---------------------------------------------------------------- the story (S2)

/**
 * The seeds a step spec or alt asks for, as groups of alternatives: crop:a/b:N, flower:x, plant:crop:x:1, item:x-seed:1, item:<produce>/<produce>:2
 * (comma parts; one group per token). A deliver spec with from: hands its things out at that place, so nothing in it needs growing: no groups.
 */
function seed_ladder_spec_groups(string $spec): array
{
    $P = seed_ladder_plants();
    if (preg_match('/(^|,)\s*from:/', $spec)) return [];
    $out = [];
    foreach (explode(',', $spec) as $part) {
        $tok = explode(':', trim($part));
        foreach ($tok as $i => $t) {
            $next = (string)($tok[$i + 1] ?? '');
            if ($next === '' || !in_array($t, ['crop', 'flower', 'item'], true)) continue;
            $g = [];
            foreach (explode('/', $next) as $s) {
                if ($t !== 'item') { if (isset($P['slug'][$s])) $g[] = $s; }
                elseif (str_ends_with($s, '-seed') && isset($P['slug'][substr($s, 0, -5)])) $g[] = substr($s, 0, -5);
                elseif (isset($P['produce'][$s])) $g[] = $P['produce'][$s];
            }
            if ($g) $out[] = array_values(array_unique($g));
        }
    }
    return $out;
}

/** Every plant slug a step spec or alt names (the groups flattened). */
function seed_ladder_spec_slugs(string $spec): array
{
    return array_values(array_unique(array_merge([], ...seed_ladder_spec_groups($spec))));
}

/** Errand steps that name a seed no start shelf holds: [[slug, errand id, area, trigger], ...] (data/journey_errands.txt). */
function seed_ladder_errand_ties(): array
{
    $c = &seed_ladder_cache();
    if (isset($c['ties'])) return $c['ties'];
    $start = seed_ladder_start_slugs();
    $q = []; $out = [];
    foreach (catalog_lines('journey_errands.txt') as $r) {
        $kind = array_shift($r);
        if ($kind === 'Q' && count($r) >= 6) $q[(string)$r[0]] = ['area' => (string)$r[1], 'trigger' => (string)$r[5]];
        elseif ($kind === 'S' && count($r) >= 5 && isset($q[(string)$r[0]])) {
            foreach (array_merge(seed_ladder_spec_slugs((string)$r[2]), seed_ladder_spec_slugs((string)$r[4])) as $s) {
                if (!isset($start[$s])) $out[$s . '|' . $r[0]] = [$s, (string)$r[0], $q[(string)$r[0]]['area'], $q[(string)$r[0]]['trigger']];
            }
        }
    }
    return $c['ties'] = array_values($out);
}

/** Can the ladder read every part of an errand trigger? (chapter=, found=, seal=) */
function seed_ladder_trigger_known(string $trigger): bool
{
    foreach (array_filter(array_map('trim', explode(',', $trigger))) as $p) if (!preg_match('/^(chapter|found|seal)=[A-Za-z0-9-]+$/', $p)) return false;
    return trim($trigger) !== '' && trim($trigger) !== '-';
}

/** Does an errand trigger hold for this gnome now? Parts the ladder cannot read count as not holding. */
function seed_ladder_trigger_ok(int $uid, string $trigger): bool
{
    if (!seed_ladder_trigger_known($trigger)) return false;
    foreach (array_filter(array_map('trim', explode(',', $trigger))) as $p) {
        [$k, $v] = explode('=', $p, 2);
        if ($k === 'chapter') {
            if (!q_val('SELECT 1 FROM user_quests uq JOIN quest_chapters c ON c.id = uq.chapter_id WHERE uq.user_id = ? AND c.slug = ? AND uq.done_at IS NOT NULL', [$uid, $v])) return false;
        } elseif ($k === 'found') {
            $loc = q_one('SELECT * FROM locations WHERE slug = ? OR slug LIKE ? ORDER BY id LIMIT 1', [$v, '%-' . $v]);
            require_once __DIR__ . '/roads.php';
            if (!$loc || !place_known($uid, $loc)) return false;
        } elseif ($k === 'seal') {
            require_once __DIR__ . '/seals.php';
            $rid = (int)q_val('SELECT id FROM regions WHERE code = ?', [$v]);
            if ($rid < 1 || !seal_held($uid, $rid)) return false;
        }
    }
    return true;
}

/** [seed item id => true] the story asks of this gnome right now: steps of chapters in play, errands whose trigger holds. */
function seed_ladder_story_items(int $uid): array
{
    $c = &seed_ladder_cache();
    if (isset($c['story' . $uid])) return $c['story' . $uid];
    $P = seed_ladder_plants();
    $slugs = [];
    foreach (q('SELECT t.spec, t.alt FROM quest_tasks t JOIN quest_chapters c ON c.id = t.chapter_id AND c.active = 1
                JOIN user_quests uq ON uq.chapter_id = c.id AND uq.user_id = ? AND uq.done_at IS NULL', [$uid])->fetchAll() as $t) {
        foreach (array_merge(seed_ladder_spec_slugs((string)$t['spec']), seed_ladder_spec_slugs((string)($t['alt'] ?? ''))) as $s) $slugs[$s] = true;
    }
    foreach (seed_ladder_errand_ties() as [$s, , , $trigger]) if (!isset($slugs[$s]) && seed_ladder_trigger_ok($uid, $trigger)) $slugs[$s] = true;
    $out = [];
    foreach (array_keys($slugs) as $s) if (isset($P['slug'][$s])) $out[$P['slug'][$s]] = true;
    return $c['story' . $uid] = $out;
}

/**
 * The lint (S1, S2): each seed group a step needs (a chapter or errand step's own spec; First Week) has one seed on a start shelf, or, for an
 * errand, one tied to its step by a trigger the ladder can read. A step's alt (the second, peaceful way) is not needed; its seeds still open
 * while the chapter is in play (seed_ladder_story_items). Seeds no shop sells (treasure, given) are not the shelf's business.
 * Returns ['problems', 'chapter_slugs', 'errand_slugs', 'tied' => [slug => [errand ids]], 'needs' => [[area code or '' (hub), slug, source]]].
 */
function seed_ladder_lint(): array
{
    $start = seed_ladder_start_slugs();
    $sold = array_fill_keys(q("SELECT DISTINCT p.slug FROM shop_stock st JOIN plants p ON p.seed_item_id = st.item_id JOIN shops s ON s.id = st.shop_id WHERE s.shop_type = 'seeds'")->fetchAll(PDO::FETCH_COLUMN), true);
    $out = ['problems' => [], 'chapter_slugs' => 0, 'errand_slugs' => 0, 'tied' => [], 'needs' => []];
    $ties = seed_ladder_errand_ties();
    $check = function (array $groups, string $src, ?string $errand) use (&$out, $start, $sold, $ties): void {
        foreach ($groups as $g) {
            $g = array_values(array_filter($g, fn($s) => isset($sold[$s])));
            if (!$g) continue;
            $out[$errand === null ? 'chapter_slugs' : 'errand_slugs']++;
            $ok = array_values(array_filter($g, fn($s) => isset($start[$s])));
            if ($ok) { $out['needs'][] = [$start[$ok[0]], $ok[0], $src]; continue; }
            if ($errand !== null) {
                $tie = array_values(array_filter($ties, fn($t) => in_array($t[0], $g, true) && $t[1] === $errand && seed_ladder_trigger_known($t[3])));
                if ($tie) { $out['tied'][$tie[0][0]][$errand] = true; $out['needs'][] = [$tie[0][2], $tie[0][0], $src]; continue; }
            }
            $out['problems'][] = $src . ': ' . implode('/', $g) . ($errand === null ? ' is not on a start shelf' : ' is neither on a start shelf nor tied to a step the ladder can read');
        }
    };
    foreach (catalog_lines('journey_chapters.txt') as $r) {
        if (array_shift($r) === 'T' && count($r) >= 3) $check(seed_ladder_spec_groups((string)$r[2]), 'chapter ' . $r[0], null);
    }
    foreach (q('SELECT c.slug, t.spec FROM quest_tasks t JOIN quest_chapters c ON c.id = t.chapter_id WHERE c.engine = 0')->fetchAll() as $t) {   // the old chapters (grow staple: each five holds 2)
        $check(seed_ladder_spec_groups((string)$t['spec']), 'old chapter ' . $t['slug'], null);
    }
    foreach (catalog_lines('journey_errands.txt') as $r) {
        if (array_shift($r) === 'S' && count($r) >= 3) $check(seed_ladder_spec_groups((string)$r[2]), 'errand ' . $r[0], (string)$r[0]);
    }
    foreach ($out['tied'] as $s => $e) $out['tied'][$s] = array_keys($e);
    foreach (['radish'] as $s) if (!isset($start[$s])) $out['problems'][] = "First Week: $s is not on a start shelf";   // day 1: "Plant a quick radish"
    return $out;
}

// ---------------------------------------------------------------- one row

/** Is this shop row on the shelf for this gnome? $row: shop_id, item_id, ladder_gate. $asNew: as a new gnome sees it (Admin preview). */
function seed_ladder_row_open(array $u, array $row, bool $asNew = false): bool
{
    if (!seed_ladder_on()) return true;
    $gate = (string)($row['ladder_gate'] ?? '');
    if ($gate === '') return true;
    $ctx = seed_ladder_shop_ctx((int)$row['shop_id']);
    if (!$ctx || $ctx['kind'] === '' || !in_array($gate, SEED_LADDER_GATES[$ctx['kind']], true)) return true;
    if ($asNew) return false;
    if (($u['role'] ?? '') === 'admin') return true;   // Admin sees every row (with a gate tag), and can preview as a new gnome
    seed_ladder_tables();
    $uid = (int)$u['id'];
    $item = (int)$row['item_id'];
    seed_ladder_snapshot($uid);
    if (isset(seed_ladder_items($uid)[$item])) return true;
    $plant = seed_ladder_plants()['item'][$item] ?? null;
    if ($plant && isset(seed_ladder_known($uid)[$plant['id']])) { seed_ladder_item_latch($uid, $item, 'grown'); return true; }   // S3
    if ($plant) { require_once __DIR__ . '/jobs.php'; require_once __DIR__ . '/contests.php'; if ($plant['slug'] === seed_ladder_show_crop()) return true; }   // this week's Village Show crop
    if (isset(seed_ladder_story_items($uid)[$item])) { seed_ladder_item_latch($uid, $item, 'step'); return true; }   // S2
    return seed_ladder_gate_open($uid, (int)$row['shop_id'], $gate);
}

function seed_ladder_show_crop(): string
{
    $c = &seed_ladder_cache();
    return $c['show'] ??= show_crop();
}

/** The shelf of a shop for a gnome: ['open' => rows, 'open_seeds' => seed rows, 'locked' => [gate => rows], 'admin_all' => bool]. */
function seed_ladder_shelf(array $u, int $shopId, bool $asNew = false): array
{
    if (seed_ladder_on()) seed_ladder_ensure();
    $rows = q('SELECT st.*, i.name, i.category, p.slug AS plant_slug, p.name AS plant_name FROM shop_stock st JOIN items i ON i.id = st.item_id LEFT JOIN plants p ON p.seed_item_id = i.id
               WHERE st.shop_id = ? ORDER BY i.name, st.id', [$shopId])->fetchAll();
    $ctx = seed_ladder_shop_ctx($shopId);
    $out = ['open' => [], 'open_seeds' => [], 'locked' => [], 'admin_all' => !$asNew && seed_ladder_on() && ($u['role'] ?? '') === 'admin' && $ctx && $ctx['kind'] !== ''];
    foreach ($rows as $r) {
        if (seed_ladder_row_open($u, $r, $asNew)) {
            $out['open'][] = $r;
            if ($r['category'] === 'seed') $out['open_seeds'][] = $r;
        } else $out['locked'][(string)$r['ladder_gate']][] = $r;
    }
    return $out;
}

// ---------------------------------------------------------------- words

/** "the Maplewold" in the middle of a sentence; "Maplewold" before a noun. */
function seed_ladder_area_mid(string $name): string { return str_starts_with($name, 'The ') ? 'the ' . substr($name, 4) : $name; }
function seed_ladder_area_adj(string $name): string { return str_starts_with($name, 'The ') ? substr($name, 4) : $name; }

/** The plant names of a gate's rows at a shop (lower case), for "beet, garlic and four more". */
function seed_ladder_gate_names(int $shopId, string $gate): array
{
    return array_map('strtolower', q('SELECT p.name FROM shop_stock st JOIN plants p ON p.seed_item_id = st.item_id WHERE st.shop_id = ? AND st.ladder_gate = ? ORDER BY st.price_min, p.name', [$shopId, $gate])->fetchAll(PDO::FETCH_COLUMN));
}

/** The hint of a locked gate (section 5). */
function seed_ladder_gate_line(array $u, int $shopId, string $gate): string
{
    $ctx = seed_ladder_shop_ctx($shopId);
    if (!$ctx || $ctx['kind'] === '') return '';
    $n = min(SEED_LADDER_NEED[$gate] ?? 0, seed_ladder_progress((int)$u['id'], $ctx, $gate));
    $num = [2 => 'two', 4 => 'four', 5 => 'five', 6 => 'six', 3 => 'three'];
    $names = seed_ladder_gate_names($shopId, $gate);
    $area = (string)($ctx['gnomish_name'] ?? '');
    return match ($gate) {
        'm1' => 'Kitchen row: ' . (count($names) > 2 ? implode(', ', array_slice($names, 0, 2)) . ' and ' . ($num[count($names) - 2] ?? (string)(count($names) - 2)) . ' more' : implode(' and ', $names))
            . '. Twigg: ‘Grow five different things, or start mending a stop, and I’ll put it out.’ (' . $n . ' of 5)',
        'm2' => 'Herb shelf. ‘Finish one bar at any stop, or grow ten different things.’ (' . $n . ' of 10)',
        'm3' => 'Field sacks. ‘When carts reach the Maplewold again, or you’ve grown sixteen.’ (' . $n . ' of 16)',
        'm4' => 'The top shelf. ‘When the Maplewold thrives, or you’ve grown twenty-four.’ (' . $n . ' of 24)',
        'r1' => 'Not unpacked yet. Harvest two ' . seed_ladder_area_adj($area) . ' staples, or lend a hand in town. (' . $n . ' of 2)',
        'r2' => 'Waiting on a cart. Mend the villages of ' . seed_ladder_area_mid($area) . ', or grow six of its plants. (' . $n . ' of 6)',
        'r3' => 'Flower crates. They come when ' . seed_ladder_area_mid((string)$ctx['loc_name']) . ' is merry, or when you’ve grown three of its flowers. (' . $n . ' of 3)',
        'r4' => 'The orchard order. It comes when ' . seed_ladder_area_mid($area) . ' thrives, or when you’ve grown twelve of its plants. (' . $n . ' of 12)',
        default => '',
    };
}

/** '' when the gnome may buy the row, else the refusal (section 5). */
function seed_ladder_buy_block(array $u, array $row): string
{
    if (seed_ladder_row_open($u, $row)) return '';
    return 'That one is not on your shelf yet. ' . seed_ladder_gate_line($u, (int)$row['shop_id'], (string)$row['ladder_gate']);
}

/** The town page sentence of a region's seed shop for this gnome ('' when off). */
function seed_ladder_town_line(array $u, int $rid): string
{
    if (!seed_ladder_on() || $rid < 1) return '';
    $shop = q_one("SELECT s.id, s.name FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.region_id = ? AND l.kind = 'market' AND s.shop_type = 'seeds' ORDER BY s.id LIMIT 1", [$rid]);
    if (!$shop) return '';
    seed_ladder_ensure();
    $top = '';
    foreach (SEED_LADDER_GATES['town'] as $g) if (seed_ladder_gate_open((int)$u['id'], (int)$shop['id'], $g)) $top = $g;
    $s = (string)$shop['name'];
    return match ($top) {
        'r1' => $s . ' has unpacked the staples and a few flowers.',
        'r2' => 'A cart got through. ' . $s . ' has rarer seed again.',
        'r3' => 'Flower crates by the door of ' . $s . '.',
        'r4' => $s . ' is full to the rafters.',
        default => $s . ' has Wren’s five on the counter and empty hooks behind.',
    };
}

function seed_ladder_town_line_html(array $u, int $rid): string
{
    $l = seed_ladder_town_line($u, $rid);
    return $l === '' ? '' : '<p class="help sl-town">🌱 ' . e($l) . '</p>';
}

/** Flash lines for gates latched and not shown yet ("New on your shelf at {shop}: {names}."), optionally of one shop, marking them seen. */
function seed_ladder_new_lines(array $u, ?int $shopId = null, bool $markSeen = false): array
{
    $uid = (int)$u['id'];
    try {
        $rows = q("SELECT shop_id, gate FROM seed_ladder_gates WHERE user_id = ? AND seen = 0 AND shop_id > 0" . ($shopId ? ' AND shop_id = ' . (int)$shopId : '') . ' ORDER BY opened_at, gate', [$uid])->fetchAll();
    } catch (PDOException $e) { return []; }
    $out = [];
    foreach ($rows as $r) {
        $ctx = seed_ladder_shop_ctx((int)$r['shop_id']);
        if (!$ctx || $ctx['kind'] === '') continue;
        $names = q('SELECT i.name FROM shop_stock st JOIN items i ON i.id = st.item_id WHERE st.shop_id = ? AND st.ladder_gate = ? ORDER BY i.name', [(int)$r['shop_id'], (string)$r['gate']])->fetchAll(PDO::FETCH_COLUMN);
        if ($names) $out[] = 'New on your shelf at ' . $ctx['name'] . ': ' . implode(', ', $names) . '.';
        $all = true;
        foreach (SEED_LADDER_GATES[$ctx['kind']] as $g) if (!isset(seed_ladder_latched($uid)[(int)$r['shop_id']][$g])) $all = false;
        if ($all && $names) $out[] = 'Wren: “' . SEED_LADDER_WREN['full'] . '”';
        if ($markSeen) q('UPDATE seed_ladder_gates SET seen = 1 WHERE user_id = ? AND shop_id = ? AND gate = ?', [$uid, (int)$r['shop_id'], (string)$r['gate']]);
    }
    return array_values(array_unique($out));
}

/** Wren's line on a ladder shop while none of its gates is open ('' otherwise). */
function seed_ladder_wren_html(array $u, int $shopId): string
{
    $ctx = seed_ladder_shop_ctx($shopId);
    if (!seed_ladder_on() || !$ctx || $ctx['kind'] === '' || ($u['role'] ?? '') === 'admin') return '';
    foreach (SEED_LADDER_GATES[$ctx['kind']] as $g) if (isset(seed_ladder_latched((int)$u['id'])[$shopId][$g])) return '';
    return '<p class="sl-wren">✉️ <b>Wren:</b> “' . e(SEED_LADDER_WREN[$ctx['kind']]) . '”</p>';
}

// ---------------------------------------------------------------- the bottom drawer (S4) and the special order (S5)

/** How many of a bare start row the bottom drawer still holds for this gnome today (0 when off, gated, or not a ladder shop). */
function seed_ladder_drawer_left(array $u, int $stockId): int
{
    if (!seed_ladder_on()) return 0;
    require_once __DIR__ . '/town_states.php';
    $row = town_backroom_row($stockId);
    if (!$row || ($row['category'] ?? '') !== 'seed' || !array_key_exists('ladder_gate', $row) || $row['ladder_gate'] !== '') return 0;
    $ctx = seed_ladder_shop_ctx((int)$row['shop_id']);
    if (!$ctx || $ctx['kind'] === '') return 0;
    try { $used = (int)q_val('SELECT n FROM town_backroom WHERE user_id = ? AND stock_id = ? AND day = ?', [(int)$u['id'], $stockId, town_backroom_day((int)$u['id'])]); }
    catch (PDOException $e) { return 0; }
    return max(0, SEED_LADDER_DRAWER - $used);
}

/** Special orders left today (0 or 1). */
function seed_ladder_order_left(array $u): int
{
    if (!seed_ladder_on()) return 0;
    seed_ladder_tables();
    require_once __DIR__ . '/town_states.php';
    try { return q_val('SELECT 1 FROM seed_ladder_orders WHERE user_id = ? AND day = ?', [(int)$u['id'], town_backroom_day((int)$u['id'])]) ? 0 : 1; }
    catch (PDOException $e) { return 0; }
}

/** What one seed of a special order costs this gnome. */
function seed_ladder_order_price(array $u, array $row): int
{
    require_once __DIR__ . '/town_states.php';
    return shop_price($u, SEED_LADDER_ORDER_MULT * town_backroom_price(town_backroom_row((int)$row['id'])), (int)$row['shop_id'], (int)$row['item_id']);
}

/** S5: a special order of a locked seed: 3 seeds at 2 x price_max, one a game day; never off the shelf. Returns [ok, message, cost]. */
function seed_ladder_order(array $u, int $stockId): array
{
    if (!seed_ladder_on()) return [false, 'There are no special orders here.', 0];
    $s = q_one('SELECT st.*, sh.open, sh.open_minute, sh.close_minute, sh.id AS sid, sh.location_id, i.name, i.category FROM shop_stock st
                JOIN shops sh ON sh.id = st.shop_id JOIN items i ON i.id = st.item_id WHERE st.id = ?', [$stockId]);
    if (!$s || !(int)$s['open']) return [false, 'That shop is closed.', 0];
    $ctx = seed_ladder_shop_ctx((int)$s['shop_id']);
    if ($s['category'] !== 'seed' || !$ctx || $ctx['kind'] === '') return [false, 'Only seeds can be special-ordered.', 0];
    if (seed_ladder_row_open($u, $s)) return [false, 'That one is on your shelf: just buy it.', 0];
    if (!shop_reachable($u, ['location_id' => $s['location_id']])) return [false, 'You need to be in that town first.', 0];
    if ($why = gclock_closed_reason($u, $s)) return [false, $why, 0];
    if (!staff_on_duty((int)$s['sid'])) return [false, 'Nobody is at the counter right now.', 0];
    if (seed_ladder_order_left($u) < 1) return [false, 'One special order a day. The keeper is still writing up today’s.', 0];
    $n = SEED_LADDER_ORDER_SEEDS;
    $cost = $n * seed_ladder_order_price($u, $s);
    $uid = (int)$u['id'];
    db()->beginTransaction();
    try { db_insert('seed_ladder_orders', ['user_id' => $uid, 'day' => town_backroom_day($uid), 'stock_id' => $stockId, 'n' => $n, 'at' => now()]); }
    catch (PDOException $e) { db()->rollBack(); return [false, 'One special order a day. The keeper is still writing up today’s.', 0]; }
    if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $uid, $cost])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'A special order of ' . $n . ' × ' . $s['name'] . ' costs ' . number_format($cost) . ' ' . setting('currency_name') . '.', 0];
    }
    give_item($uid, (int)$s['item_id'], $n);
    db()->commit();
    return [true, '📦 Special order: ' . $n . ' × ' . $s['name'] . ' for ' . number_format($cost) . ' ' . setting('currency_name') . '. Grow it once and the keeper puts it on your shelf for good.', $cost];
}

/** The folded "Not on the shelf yet" list under a shop's stock: one hint per gate, the seeds by name, a Special order button each. */
function seed_ladder_locked_html(array $u, array $shop, array $locked, bool $open): string
{
    if (!$locked) return '';
    $sid = (int)$shop['id'];
    $left = $open ? seed_ladder_order_left($u) : 0;
    $n = array_sum(array_map('count', $locked));
    $h = '<details class="sl-locked"><summary>🔒 Not on the shelf yet (' . $n . ')</summary>';
    foreach (SEED_LADDER_GATES as $gates) foreach ($gates as $g) {
        if (empty($locked[$g])) continue;
        $h .= '<div class="sl-gate"><p class="sl-hint">' . e(seed_ladder_gate_line($u, $sid, $g)) . '</p><ul>';
        foreach ($locked[$g] as $r) {
            $h .= '<li class="sl-lrow"><span>' . e((string)$r['name']) . '</span>';
            if ($left > 0) {
                $h .= '<form method="post" action="' . e(url('shop.php?id=' . $sid)) . '">' . csrf_field() . '<input type="hidden" name="do" value="sl_order"><input type="hidden" name="stock" value="' . (int)$r['id'] . '">'
                    . '<button class="btn small alt">Special order: ' . SEED_LADDER_ORDER_SEEDS . ' for ' . number_format(SEED_LADDER_ORDER_SEEDS * seed_ladder_order_price($u, $r)) . '</button></form>';
            }
            $h .= '</li>';
        }
        $h .= '</ul></div>';
    }
    $h .= '<p class="help">' . ($open ? ($left > 0 ? 'A special order: ' . SEED_LADDER_ORDER_SEEDS . ' seeds at twice the top price, one a day. Grow it once and it stays on your shelf.' : 'You have made today’s special order.') : 'Special orders are taken at the counter.') . '</p></details>';
    return $h;
}
