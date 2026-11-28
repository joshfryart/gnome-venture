<?php
declare(strict_types=1);
/**
 * 2.8.100 Town states (claude/proposal-town-states.md). Behind `town_states_open` (default 0) and lasting marks (`stop_marks_open`):
 * with either off every town is Thriving ('fixed') and nothing here changes a page, a price or a buy.
 *
 * Per gnome and region: R = floor(100 x (2F + W) / (2N)), N = villages of the region, F = villages whose Repairs bar is latched,
 * W = villages not latched with Repairs >= 34 (the home village always counts here at least). The town's state:
 *   ruin  "Run low"   R < TOWN_WORK_AT
 *   work  "Mending"   R >= TOWN_WORK_AT, or the town's own Repairs bar >= 34 (or latched)
 *   fixed "Thriving"  R >= TOWN_FIXED_AT, or the region's Seal is held
 * The best state reached is kept in town_state_best (written only when it rises), so a town never goes back. The hub has no state.
 *
 * Shops are always open: a state adds no closing and no price change. It adds the back room: a per-gnome allowance a game day per shop row,
 * used only when the shared shelf cannot fill the order, never touching the shelf (TOWN_BACKROOM). shop_stock.min_town_state (the far shelf)
 * hides a row below a state; no row ships with it.
 */

require_once __DIR__ . '/stop_marks.php';

const TOWN_WORK_AT = 15;
const TOWN_FIXED_AT = 50;
const TOWN_BAR_FLOOR = 34;   // a village under repair, and the town's own Repairs floor
const TOWN_STATE_RANK = ['ruin' => 0, 'work' => 1, 'fixed' => 2];
const TOWN_STATE_NAMES = ['ruin' => 'Run low', 'work' => 'Mending', 'fixed' => 'Thriving'];
/** Back room caps (owner's decision 4 and 6): per shop row per gnome game day; the guide copy once ever. */
const TOWN_BACKROOM = ['work' => ['staple' => 5], 'fixed' => ['staple' => 10, 'rare' => 2, 'guide' => 1]];
const TOWN_STORY_LINE = 'The towns kept one lamp lit and the door open. Then the carts stopped coming.';
const TOWN_WREN_ARRIVAL = 'They never shut. They just ran out. Mend the villages and the carts come back.';

function town_states_on(): bool
{
    return stop_marks_on() && setting('town_states_open') === '1';
}

/** Per-request caches (parts, state, rows). */
function &town_states_cache(): array
{
    static $c = ['parts' => [], 'state' => [], 'rows' => [], 'vill' => []];
    return $c;
}

function town_states_reset(): void
{
    $c = &town_states_cache();
    $c = ['parts' => [], 'state' => [], 'rows' => [], 'vill' => []];
}

function town_state_name(string $state): string
{
    return TOWN_STATE_NAMES[$state] ?? '';
}

/** @return int[] village ids of a region (road and off-road). */
function town_region_villages(int $rid): array
{
    $c = &town_states_cache();
    return $c['vill'][$rid] ??= array_map('intval', q("SELECT id FROM locations WHERE region_id = ? AND kind = 'village'", [$rid])->fetchAll(PDO::FETCH_COLUMN));
}

/** ['n' => N, 'f' => F, 'w' => W, 'r' => R] for a gnome and region. */
function town_region_parts(int $uid, int $rid): array
{
    $c = &town_states_cache();
    $k = $uid . ':' . $rid;
    if (isset($c['parts'][$k])) return $c['parts'][$k];
    $vill = town_region_villages($rid);
    $n = count($vill);
    $f = $w = 0;
    if ($n > 0 && $uid > 0) {
        $in = implode(',', $vill);
        $latched = array_flip(array_map('intval', q("SELECT location_id FROM stop_marks WHERE user_id = ? AND bar = 'repairs' AND location_id IN ($in)", [$uid])->fetchAll(PDO::FETCH_COLUMN)));
        $metered = array_map('intval', q("SELECT location_id FROM stop_prog WHERE user_id = ? AND k = 'meter:repairs' AND location_id IN ($in)", [$uid])->fetchAll(PDO::FETCH_COLUMN));
        $home = (int)q_val('SELECT home_village_id FROM users WHERE id = ?', [$uid]);
        $work = [];
        foreach ($metered as $lid) if (!isset($latched[$lid]) && mark_bar_get($uid, $lid, 'repairs') >= TOWN_BAR_FLOOR) $work[$lid] = true;
        if ($home > 0 && in_array($home, $vill, true) && !isset($latched[$home])) $work[$home] = true;   // the home village is always at least under repair
        $f = count($latched);
        $w = count($work);
    }
    $r = $n > 0 ? (int)floor(100 * (2 * $f + $w) / (2 * $n)) : 0;
    return $c['parts'][$k] = ['n' => $n, 'f' => $f, 'w' => $w, 'r' => min(100, $r)];
}

function town_region_repair(int $uid, int $rid): int
{
    return town_region_parts($uid, $rid)['r'];
}

/** The town location of a region (its market town), or null. */
function town_of_region(int $rid): ?array
{
    return q_one("SELECT * FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$rid]) ?: null;
}

/** 'ruin', 'work' or 'fixed' (best ever). Off, no gnome or no region (the hub): 'fixed'. */
function town_state(int $uid, int $rid): string
{
    if (!town_states_on() || $uid < 1 || $rid < 1) return 'fixed';
    $c = &town_states_cache();
    $k = $uid . ':' . $rid;
    if (isset($c['state'][$k])) return $c['state'][$k];
    $best = null;
    try { $best = q_one('SELECT state, r_best FROM town_state_best WHERE user_id = ? AND region_id = ?', [$uid, $rid]) ?: null; } catch (PDOException $e) { $best = null; }   // before Upgrade database
    $was = $best ? (int)$best['state'] : 0;
    if ($was >= 2) return $c['state'][$k] = 'fixed';   // Thriving: nothing to compute
    require_once __DIR__ . '/seals.php';
    $r = town_region_repair($uid, $rid);
    $now = $r >= TOWN_FIXED_AT ? 2 : ($r >= TOWN_WORK_AT ? 1 : 0);
    if ($now < 2 && seal_held($uid, $rid)) $now = 2;
    if ($now < 1 && ($t = town_of_region($rid)) && mark_bar_get($uid, (int)$t['id'], 'repairs') >= TOWN_BAR_FLOOR) $now = 1;   // the town's own bar: a floor
    $st = max($was, $now);
    try {
        if ($best && ($st > $was || $r > (int)$best['r_best'])) q('UPDATE town_state_best SET state = ?, r_best = ?, updated_at = ? WHERE user_id = ? AND region_id = ? AND state <= ?', [$st, max($r, (int)$best['r_best']), now(), $uid, $rid, $st]);
        elseif (!$best && $st > 0) db_insert('town_state_best', ['user_id' => $uid, 'region_id' => $rid, 'state' => $st, 'r_best' => $r, 'updated_at' => now()]);
    } catch (PDOException $e) { /* another request wrote it, or the table is not made yet */ }
    return $c['state'][$k] = array_search($st, TOWN_STATE_RANK, true);
}

/** The state of a place: a region town => its state; the hub => 'fixed'; anything else ''. */
function town_state_at(int $uid, ?array $loc): string
{
    if (!$loc) return '';
    if (($loc['kind'] ?? '') === 'hub') return 'fixed';
    if (($loc['kind'] ?? '') !== 'market' || (int)($loc['region_id'] ?? 0) < 1) return '';
    return town_state($uid, (int)$loc['region_id']);
}

/** Best R reached (for Wren's count). */
function town_r_best(int $uid, int $rid): int
{
    $r = town_region_repair($uid, $rid);
    try { $r = max($r, (int)q_val('SELECT r_best FROM town_state_best WHERE user_id = ? AND region_id = ?', [$uid, $rid])); } catch (PDOException $e) {}
    return $r;
}

/** The three lines of a state: [town page 1, town page 2, shop page]. $left: what the back room still holds today (Mending). */
function town_state_lines(int $uid, int $rid, ?int $left = null): array
{
    $st = town_state($uid, $rid);
    $p = town_region_parts($uid, $rid);
    $region = (string)q_val('SELECT gnomish_name FROM regions WHERE id = ?', [$rid]);
    return match ($st) {
        'ruin' => ['The shelves are thin but the door is open.', 'No cart has come up the road in a long while. Mend a village and one might.', 'What you see is what there is. Nothing in the back.'],
        'work' => ['Carts are getting through again.', $p['f'] . ' of ' . $p['n'] . ' villages mended. The square is waking up.',
            'Shelf bare? Ask. The keeper holds a few staples back for you.' . ($left !== null ? ' (' . $left . ' left today)' : '')],
        default => ['Every stall is up and the lamps are all lit.', 'The roads of ' . $region . ' carry goods again. You did that.',
            'The back room is full. Staples, rarer seeds, and a guide kept under the counter for you.'],
    };
}

/** The chip and lines 1-2 for the town page ('' when off or no region). */
function town_chip_html(int $uid, int $rid): string
{
    if (!town_states_on() || $rid < 1) return '';
    $st = town_state($uid, $rid);
    [$a, $b] = town_state_lines($uid, $rid);
    return '<div class="tstate tstate-' . $st . '"><span class="chip tstate-chip">' . e(town_state_name($st)) . '</span> <span class="tstate-l1">' . e($a) . '</span>'
        . '<p class="tstate-l2">' . e($b) . '</p></div>';
}

/** Wren's arrival line at a Run low town, under the story line ('' otherwise). */
function town_wren_html(int $uid, int $rid): string
{
    if (!town_states_on() || $rid < 1 || town_state($uid, $rid) !== 'ruin') return '';
    return '<div class="tstate-wren"><p class="tstate-story">' . e(TOWN_STORY_LINE) . '</p><p>✉️ <b>Wren:</b> “' . e(TOWN_WREN_ARRIVAL) . '”</p></div>';
}

/** Wren's area page: "Town: Mending (R 30 of 50)", for looks only. */
function town_state_count_html(int $uid, int $rid): string
{
    if (!town_states_on() || $rid < 1 || !town_of_region($rid)) return '';
    return '<p class="help tstate-count">🏘️ Town: ' . e(town_state_name(town_state($uid, $rid))) . ' (R ' . town_r_best($uid, $rid) . ' of ' . TOWN_FIXED_AT . ')</p>';
}

/** Is this shop a region town's (not the hub, not a pet shop)? Returns the town's region id, or 0. */
function town_shop_region(array $shop): int
{
    if (($shop['shop_type'] ?? '') === 'pets' || empty($shop['location_id'])) return 0;
    $l = q_one('SELECT kind, region_id FROM locations WHERE id = ?', [(int)$shop['location_id']]);
    return $l && $l['kind'] === 'market' ? (int)$l['region_id'] : 0;
}

/** Line 3 on a town shop's page ('' when off, the hub or a pet shop). */
function town_shop_line_html(array $u, array $shop): string
{
    if (!town_states_on() || ($rid = town_shop_region($shop)) < 1) return '';
    $uid = (int)$u['id'];
    $st = town_state($uid, $rid);
    $left = null;
    if ($st === 'work') {
        $left = 0;
        foreach (q('SELECT id FROM shop_stock WHERE shop_id = ?', [(int)$shop['id']])->fetchAll(PDO::FETCH_COLUMN) as $sid) if (town_backroom_class(town_backroom_row((int)$sid)) === 'staple') $left += town_backroom_left($u, (int)$sid);
    }
    return '<p class="tstate tstate-' . $st . ' tstate-shop"><span class="chip tstate-chip">' . e(town_state_name($st)) . '</span> ' . e(town_state_lines($uid, $rid, $left)[2]) . '</p>';
}

// ---------------------------------------------------------------- pictures

/** The state twin's file name: here-town-na.png + ruin => here-town-na-ruin.png; fixed => the file itself. */
function town_state_twin(string $file, string $state): string
{
    if ($state === 'fixed' || $state === '' || !str_ends_with($file, '.png')) return $file;
    return substr($file, 0, -4) . '-' . $state . '.png';
}

/** The picture to show (under assets/img/scenes): the twin when it is there, else the fixed picture. */
function town_state_art(string $file, string $state): string
{
    $twin = town_state_twin($file, $state);
    return $twin !== $file && is_file(APP_ROOT . '/assets/img/scenes/' . $twin) ? $twin : $file;
}

// ---------------------------------------------------------------- the back room and the far shelf

/** A shop_stock row with what the back room needs (cached per request). */
function town_backroom_row(int $stockId): ?array
{
    $c = &town_states_cache();
    if (!array_key_exists($stockId, $c['rows'])) {
        $c['rows'][$stockId] = q_one('SELECT st.*, i.category, i.effects AS item_effects, sh.shop_type, sh.markup_percent, l.kind AS loc_kind, l.region_id
            FROM shop_stock st JOIN items i ON i.id = st.item_id JOIN shops sh ON sh.id = st.shop_id LEFT JOIN locations l ON l.id = sh.location_id WHERE st.id = ?', [$stockId]) ?: null;
    }
    return $c['rows'][$stockId];
}

/** 'staple', 'rare' (flower and uncommon seeds, florist flowers), 'guide', or '' (not in the back room: treasure seeds, other wares, the hub, pets). */
function town_backroom_class(?array $row): string
{
    if (!$row || ($row['loc_kind'] ?? '') !== 'market' || ($row['shop_type'] ?? '') === 'pets') return '';
    $cat = (string)$row['category'];
    if ($cat === 'guide') return 'guide';
    if ($cat === 'flower') return 'rare';
    if ($cat !== 'seed') return '';
    $p = q_one('SELECT id, common FROM plants WHERE seed_item_id = ?', [(int)$row['item_id']]);
    if (!$p) return '';
    $tiers = q('SELECT DISTINCT tier FROM plant_regions WHERE plant_id = ? AND region_id = ?', [(int)$p['id'], (int)$row['region_id']])->fetchAll(PDO::FETCH_COLUMN);
    if (in_array('treasure', $tiers, true)) return '';
    if (in_array('staple', $tiers, true) || (int)$p['common'] === 1) return 'staple';
    return in_array('flower', $tiers, true) || in_array('uncommon', $tiers, true) ? 'rare' : '';
}

/** The gnome's own game date (the back room's day). */
function town_backroom_day(int $uid): string
{
    if (gclock_on() && ($g = q_one('SELECT game_day, game_minute FROM users WHERE id = ?', [$uid]))) return gclock_state($g)['date'];
    return hollow_date('Y-m-d');
}

/** May a gnome see / buy a far-shelf row ($min = shop_stock.min_town_state) in this region? */
function town_far_ok(int $uid, int $rid, int $min): bool
{
    return $min <= 0 || TOWN_STATE_RANK[town_state($uid, $rid)] >= $min;
}

/** The back room's price for one: the row's price_max with the shop's markup (the gnome's discounts come after, in shop_price). */
function town_backroom_price(array $row): int
{
    return max(1, (int)round((int)$row['price_max'] * (100 + max(0, (int)($row['markup_percent'] ?? 0))) / 100));
}

/** How many the back room still holds for this gnome today (0 when off, Run low, not a town shop row, or a guide already read or taken). */
function town_backroom_left(array $u, int $stockId): int
{
    if (!town_states_on()) return 0;
    $row = town_backroom_row($stockId);
    $cls = town_backroom_class($row);
    if ($cls === '') return 0;
    $uid = (int)$u['id'];
    $st = town_state($uid, (int)$row['region_id']);
    $cap = TOWN_BACKROOM[$st][$cls] ?? 0;
    if ($cap < 1 || !town_far_ok($uid, (int)$row['region_id'], (int)($row['min_town_state'] ?? 0))) return 0;
    try {
        if ($cls === 'guide') {
            $key = (string)((json_decode((string)$row['item_effects'], true) ?: [])['guide'] ?? '');
            if ($key !== '' && q_val('SELECT 1 FROM user_guides WHERE user_id = ? AND guide_key = ?', [$uid, $key])) return 0;
            $used = (int)q_val('SELECT SUM(n) FROM town_backroom WHERE user_id = ? AND stock_id = ?', [$uid, $stockId]);   // once, not once a day
        } else {
            $used = (int)q_val('SELECT n FROM town_backroom WHERE user_id = ? AND stock_id = ? AND day = ?', [$uid, $stockId, town_backroom_day($uid)]);
        }
    } catch (PDOException $e) { return 0; }
    return max(0, $cap - $used);
}

/** Take $n from the back room (inside the caller's transaction). False when someone (another request) took it first. */
function town_backroom_take(int $uid, int $stockId, int $n, int $left): bool
{
    if ($n < 1 || $n > $left) return false;
    $day = town_backroom_day($uid);
    $had = (int)q_val('SELECT n FROM town_backroom WHERE user_id = ? AND stock_id = ? AND day = ?', [$uid, $stockId, $day]);
    $capToday = $had + $left;
    if (q('UPDATE town_backroom SET n = n + ? WHERE user_id = ? AND stock_id = ? AND day = ? AND n + ? <= ?', [$n, $uid, $stockId, $day, $n, $capToday])->rowCount() === 1) return true;
    try { db_insert('town_backroom', ['user_id' => $uid, 'stock_id' => $stockId, 'day' => $day, 'n' => $n]); return true; }
    catch (PDOException $e) { return false; }
}

/** The flash line after a village's Repairs add lifts the town ('' when it did not). */
function town_lift_line(string $before, string $after, string $townName): string
{
    if (TOWN_STATE_RANK[$after] <= TOWN_STATE_RANK[$before]) return '';
    return $after === 'fixed' ? '🛒 ' . $townName . ' is thriving again.' : '🛒 A cart got through to ' . $townName . '. The square is mending.';
}
