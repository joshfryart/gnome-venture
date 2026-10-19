<?php
declare(strict_types=1);
/**
 * Rebuild a landmark (v0.7.29): a monthly job on the Job Board.
 * A haven, wonder or delve in your home region has fallen into ruin. Four stages, each handed in at once:
 *   1 foundations (dressed stone + Petals) · 2 the frame (timber + rope) · 3 feed the crew (home-cooked meals)
 *   4 finishing touches (fine finds + Petals).
 * Stone, timber and rope are crafted (Crafting → Building) from things gathered on adventures and wood chips.
 * v0.7.88: ruins are per gnome. Each gnome makes a ruin safe for themselves; the first to finish is its Founder (on the plaque).
 * Made safe for you: havens rest better and stock a 4th pantry item, wonders are a little easier, delve chests hold more.
 * v0.7.77: the monthly job is retired (no new offers). Repairs replace it: any gnome can take on a ruin at the place
 * itself (see repair_* below). Old jobs still run through rebuild_hand_in.
 */

const REBUILD_STAGES = [
    1 => ['Clear your path in', [['item', 'building-stone', 6], ['coins', '', 150]]],   // v0.7.88 stage names: the repair is making it safe for yourself
    2 => ['Shore up your corner', [['item', 'timber-plank', 6], ['item', 'rope', 3]]],
    3 => ['Earn the keeper’s trust', [['meal', '', 4]]],
    4 => ['Finishing touches', [['fine', '', 2], ['coins', '', 300]]],
];
const BUILDING_ITEMS = [
    'building-stone' => ['Dressed Stone', 'A squared-off block of stone, ready for building.', 14],
    'timber-plank' => ['Timber Plank', 'A sturdy plank, planed smooth. Builders always need more.', 12],
    'rope' => ['Rope', 'Strong twisted rope for hauling and tying.', 10],
    'beeswax' => ['Beeswax', 'Golden wax from a level 3 beehive. Smells of honey. Makes lovely candles.', 18],   // v0.7.95
];

/** v0.7.88: has this gnome made this place safe (finished its repair)? */
function landmark_rebuilt_by(array $lm, int $uid): bool
{
    return $uid > 0 && (bool)q_val('SELECT 1 FROM landmark_rebuilds WHERE landmark_id = ? AND user_id = ?', [(int)$lm['id'], $uid]);
}

/**
 * v0.7.87: is this place closed because it's in ruins? v0.7.88: ruins are per gnome, so it stays closed
 * for each gnome until that gnome has made it safe.
 */
function landmark_in_ruins(array $lm, int $uid): bool
{
    return in_array($lm['kind'] ?? '', ['haven', 'wonder', 'delve'], true) && !empty($lm['ruined']) && !landmark_rebuilt_by($lm, $uid);
}

/**
 * v0.7.87: about 1 in 3 havens, wonders and delves start in ruins (never in the start region), picked the same way on every
 * world from the place's name. Places someone has already repaired, or started repairing, stay ruins so their work counts.
 * Runs once (setting ruins_assigned); the admin can still set landmarks.ruined by hand afterwards.
 */
function ensure_ruins(bool $force = false): void
{
    if (!$force && setting('ruins_assigned') === '1') return;
    $start = (string)setting('start_region');
    $worked = array_fill_keys(array_map('intval', q('SELECT DISTINCT landmark_id FROM landmark_repairs')->fetchAll(PDO::FETCH_COLUMN)), true);
    foreach (q("SELECT m.id, m.kind, m.restored_at, l.slug, g.code FROM landmarks m JOIN locations l ON l.id = m.location_id
               LEFT JOIN regions g ON g.id = m.region_id")->fetchAll() as $m) {
        $ruined = 0;
        if (in_array($m['kind'], ['haven', 'wonder', 'delve'], true)) {
            $ruined = ((string)$m['code'] !== $start && crc32((string)$m['slug']) % 3 === 0) || isset($worked[(int)$m['id']]) || !empty($m['restored_at']) ? 1 : 0;
        }
        q('UPDATE landmarks SET ruined = ? WHERE id = ?', [$ruined, (int)$m['id']]);
    }
    q("DELETE FROM settings WHERE name = 'ruins_assigned'");
    db_insert('settings', ['name' => 'ruins_assigned', 'value' => '1']);
}

/** Make sure the building materials exist (before crafting recipes are imported). */
function ensure_building_items(): void
{
    foreach (BUILDING_ITEMS as $slug => [$name, $desc, $price]) {
        if (!q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) {
            db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => 'part', 'rarity' => 20, 'base_price' => $price, 'description' => $desc]);
        }
    }
}

/** Landmarks in this gnome's home region that are in ruins (havens, wonders, delves), for a job offer. */
function rebuild_targets(array $u): array
{
    $rid = (int)($u['region_id'] ?? 0);
    if (!$rid) return [];
    // v0.7.88: ruins are per gnome: only the ones this gnome hasn't made safe yet
    return q("SELECT m.id, m.name AS item_name, m.kind FROM landmarks m WHERE m.region_id = ? AND m.kind IN ('haven', 'wonder', 'delve') AND m.ruined = 1
              AND NOT EXISTS (SELECT 1 FROM landmark_rebuilds b WHERE b.landmark_id = m.id AND b.user_id = ?) ORDER BY m.id", [$rid, (int)$u['id']])->fetchAll();
}

/** Things in the satchel that count for a need: [[item_id, name, qty], …], cheapest first. */
function rebuild_supply(int $uid, array $need): array
{
    [$type, $slug] = $need;
    $where = match ($type) {
        'item' => 'i.slug = ' . db()->quote($slug),
        'meal' => "i.category = 'food' AND i.slug NOT LIKE 'bought-%' AND i.id IN (SELECT output_item_id FROM recipes WHERE category = 'cooking' AND tier IN ('meal', 'feast'))",   // v0.9.4: Meal and Feast only, not snacks
        'fine' => "i.id IN (SELECT item_id FROM gatherables WHERE rarity IN ('uncommon', 'rare'))",
        default => '1 = 0',
    };
    return q("SELECT i.id, i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND $where ORDER BY i.base_price, i.name", [$uid])->fetchAll();
}

/** What a stage needs, with how much this gnome has: [[label, need, have], …]. */
function rebuild_stage_status(array $u, int $stage): array
{
    $out = [];
    foreach (REBUILD_STAGES[$stage][1] ?? [] as $need) {
        [$type, $slug, $qty] = $need;
        $have = $type === 'coins' ? (int)$u['coins'] : array_sum(array_column(rebuild_supply((int)$u['id'], $need), 'qty'));
        $label = match ($type) {
            'item' => BUILDING_ITEMS[$slug][0] ?? $slug,
            'meal' => 'home-cooked meals or feasts (not snacks)',
            'fine' => 'uncommon or rare finds (any)',
            'coins' => setting('currency_name'),
        };
        $out[] = [$label, $qty, $have];
    }
    return $out;
}

/** Hand in the next stage's materials. */
function rebuild_hand_in(array $u, array $job): array
{
    $uid = (int)$u['id'];
    $stage = (int)$job['progress'] + 1;
    if (!isset(REBUILD_STAGES[$stage])) return [false, 'This rebuild is finished.'];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    foreach (rebuild_stage_status($u, $stage) as [$label, $need, $have]) {
        if ($have < $need) return [false, 'Stage ' . $stage . ' needs ' . $need . ' ' . $label . ' (you have ' . $have . ').'];
    }
    db()->beginTransaction();
    foreach (REBUILD_STAGES[$stage][1] as $need) {
        [$type, , $qty] = $need;
        if ($type === 'coins') {
            if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$qty, $uid, $qty])->rowCount() !== 1) { db()->rollBack(); return [false, 'You need ' . money($qty) . '.']; }
            continue;
        }
        $left = $qty;
        foreach (rebuild_supply($uid, $need) as $it) {
            $take = min($left, (int)$it['qty']);
            if ($take > 0 && !give_item($uid, (int)$it['id'], -$take)) { db()->rollBack(); return [false, 'Something went missing from your satchel.']; }
            $left -= $take;
            if ($left <= 0) break;
        }
        if ($left > 0) { db()->rollBack(); return [false, 'You don’t have enough for this stage.']; }
    }
    if (q('UPDATE user_jobs SET progress = progress + 1 WHERE id = ? AND progress = ?', [$job['id'], $stage - 1])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That stage is already done.'];
    }
    $job['progress'] = $stage;
    require_once __DIR__ . '/jobs.php';
    job_pay($uid, $job);
    $msg = '🧱 ' . REBUILD_STAGES[$stage][0] . ': done!';
    if ($stage === count(REBUILD_STAGES)) $msg .= ' ' . rebuild_finish($u, $job);
    db()->commit();
    return [true, $msg];
}

/** The last stage of an old monthly job: restore its landmark (see rebuild_restore). */
function rebuild_finish(array $u, array $job): string
{
    return rebuild_restore($u, (int)substr((string)$job['target'], 3));
}

/**
 * v0.7.88: this gnome makes a ruin safe for themselves (a landmark_rebuilds row). The first gnome to do it is the Founder
 * (restored_at / restored_by), and is named first on the plaque. Used by repairs and the old monthly jobs.
 */
function rebuild_restore(array $u, int $lmId): string
{
    $lm = q_one('SELECT * FROM landmarks WHERE id = ?', [$lmId]);
    if (!$lm) return '';
    $uid = (int)$u['id'];
    try {
        db_insert('landmark_rebuilds', ['landmark_id' => $lmId, 'user_id' => $uid, 'done_at' => now()]);
    } catch (PDOException $e) {
        return '✨ ' . $lm['name'] . ' is already safe for you.';   // done before
    }
    unlock_entries($uid, 'landmark:' . (string)q_val('SELECT slug FROM locations WHERE id = ?', [$lm['location_id']]));
    if (q('UPDATE landmarks SET restored_at = ?, restored_by = ? WHERE id = ? AND restored_at IS NULL', [now(), $uid, $lmId])->rowCount() === 1) {
        return '✨ You’ve made ' . $lm['name'] . ' safe again, the first gnome to do it: you’re its Founder, and your name is on the plaque.';
    }
    return '✨ You’ve made ' . $lm['name'] . ' safe again. Your name joins the plaque.';
}

/** v0.7.88: how many gnomes have made this place safe. */
function landmark_restorers(array $lm): int
{
    return (int)q_val('SELECT COUNT(*) FROM landmark_rebuilds WHERE landmark_id = ?', [(int)$lm['id']]);
}

/** v0.7.88: "Founder: Name (date)." (the first gnome to make the place safe). */
function founder_line(array $lm): string
{
    $by = empty($lm['restored_by']) ? null : q_one('SELECT gnome_name, username FROM users WHERE id = ?', [(int)$lm['restored_by']]);
    return 'Founder: ' . ($by ? ($by['gnome_name'] ?: $by['username']) : 'a gnome') . (empty($lm['restored_at']) ? '' : ' (' . substr((string)$lm['restored_at'], 0, 10) . ')') . '.';
}

/** v0.7.88: the plaque: "🪧 Restored by N gnomes · Founder: Name (date).", or '' if nobody has made it safe yet. */
function restored_line(array $lm): string
{
    $n = landmark_restorers($lm);
    return $n ? '🪧 Restored by ' . $n . ' gnome' . ($n === 1 ? '' : 's') . ' · ' . founder_line($lm) : '';
}

/** v0.7.88: for a gnome who still has the ruin to make safe: "N gnomes have already made it safe; Founder: …", or ''. */
function landmark_safe_note(array $lm): string
{
    $n = landmark_restorers($lm);
    return $n ? $n . ' gnome' . ($n === 1 ? ' has' : 's have') . ' already made it safe; ' . founder_line($lm) : '';
}

// ---------------- Repairs (v0.7.77) ----------------
// A gnome makes a ruined haven, wonder or delve safe for themselves, at the place itself. Four stages, handed in one at a time
// (the same materials as the old job). Each stage pays Petals and XP. v0.7.88: ruins are per gnome; the first to finish is the Founder.

/** Rewards per stage for a landmark: [coins, xp]. Higher-level regions pay more. */
function repair_rewards(array $lm): array
{
    $L = region_min_level((int)($lm['region_id'] ?? 0));
    // v0.9.1: XP = repair_stage_xp + repair_stage_xp_per_level a level (was +20 a level)
    return [(int)setting('repair_stage_coins') + 10 * $L, (int)setting('repair_stage_xp') + (int)setting('repair_stage_xp_per_level') * $L];   // v0.7.86: Petals +10 a level (was +50)
}

/** Null if this gnome can take on the repair here now, else the reason. */
function repair_can_start(array $u, array $lm): ?string
{
    $uid = (int)$u['id'];
    if (!landmark_in_ruins($lm, $uid)) return 'Nothing here needs repairing.';   // v0.7.87: only places in ruins; v0.7.88: not once this gnome has made it safe
    $min = (int)setting('repair_min_level');
    if ((int)$u['level'] < $min) return 'Repairs open up at gnome level ' . $min . '.';
    // v0.7.85: a given-up repair (dropped_at set) is kept, so it can be taken on again where it was left off
    if ($mine = q_one('SELECT done_at, dropped_at FROM landmark_repairs WHERE user_id = ? AND landmark_id = ?', [$uid, $lm['id']])) {
        if ($mine['done_at']) return 'Nothing here needs repairing.';   // v0.7.88: finished by this gnome
        if (!$mine['dropped_at']) return 'You’re already repairing this.';
    }
    $active = (int)q_val('SELECT COUNT(*) FROM landmark_repairs r JOIN landmarks m ON m.id = r.landmark_id
                          WHERE r.user_id = ? AND r.done_at IS NULL AND r.dropped_at IS NULL', [$uid]);
    if ($active >= (int)setting('repair_max_active')) return 'You already have ' . $active . ' repairs going. Finish one first.';
    if ((int)$u['location_id'] !== (int)$lm['location_id']) return 'You need to be there to take it on.';
    require_once __DIR__ . '/journey.php';
    $slug = (string)q_val('SELECT slug FROM locations WHERE id = ?', [$lm['location_id']]);
    if (journey_lock($uid, 'place', $slug)) return 'Wren’s Journey has plans for this place first.';
    return null;
}

/** Take on a repair of a landmark. Returns [ok, message]. */
function repair_start(array $u, int $lmId): array
{
    $lm = q_one('SELECT * FROM landmarks WHERE id = ?', [$lmId]);
    if (!$lm) return [false, 'Nothing here needs repairing.'];
    if ($why = repair_can_start($u, $lm)) return [false, $why];
    [$coins, $xp] = repair_rewards($lm);
    $uid = (int)$u['id'];
    $old = q_one('SELECT id, stage FROM landmark_repairs WHERE user_id = ? AND landmark_id = ? AND done_at IS NULL AND dropped_at IS NOT NULL', [$uid, $lmId]);
    if ($old) {
        // v0.7.85: pick up the given-up row with its stage kept, so stages already paid are never paid again
        if (q('UPDATE landmark_repairs SET dropped_at = NULL WHERE id = ? AND user_id = ? AND done_at IS NULL AND dropped_at IS NOT NULL', [(int)$old['id'], $uid])->rowCount() !== 1) {
            return [false, 'You’re already repairing this.'];
        }
        return [true, '🔨 You pick up making ' . $lm['name'] . ' safe where you left off (' . (int)$old['stage'] . ' of ' . count(REBUILD_STAGES) . ' stages done).'];
    }
    try {
        db_insert('landmark_repairs', ['user_id' => $uid, 'landmark_id' => $lmId, 'stage' => 0, 'started_at' => now()]);
    } catch (PDOException $e) {
        return [false, 'You’re already repairing this.'];   // a double click
    }
    return [true, '🔨 You start making ' . $lm['name'] . ' safe for yourself: clearing your own path in, shoring up your corner, earning the keeper’s trust. Hand in each stage when you have the materials, here, from the Job Board or from a town square’s Quests tab. Each one pays ' . money($coins) . ' and ' . $xp . ' XP.'];
}

/** Hand in the next stage of a repair. Returns [ok, message]. */
function repair_hand(array $u, int $repairId): array
{
    require_once __DIR__ . '/gnome.php';   // add_xp
    $uid = (int)$u['id'];
    $r = q_one('SELECT * FROM landmark_repairs WHERE id = ? AND user_id = ? AND done_at IS NULL AND dropped_at IS NULL', [$repairId, $uid]);
    if (!$r) return [false, 'That repair is finished or gone.'];
    $lm = q_one('SELECT * FROM landmarks WHERE id = ?', [$r['landmark_id']]);
    if (!$lm) return [false, 'That repair is gone.'];
    // v0.7.88: ruins are per gnome, so your repair stays yours to finish even after others have made the place safe
    $stage = (int)$r['stage'] + 1;
    if (!isset(REBUILD_STAGES[$stage])) return [false, 'This repair is finished.'];
    $fresh = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    foreach (rebuild_stage_status($fresh, $stage) as [$label, $need, $have]) {
        if ($have < $need) return [false, 'Stage ' . $stage . ' needs ' . $need . ' ' . $label . ' (you have ' . $have . ').'];
    }
    [$coins, $xp] = repair_rewards($lm);
    db()->beginTransaction();
    foreach (REBUILD_STAGES[$stage][1] as $need) {
        [$type, , $qty] = $need;
        if ($type === 'coins') {
            if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$qty, $uid, $qty])->rowCount() !== 1) { db()->rollBack(); return [false, 'You need ' . money($qty) . '.']; }
            continue;
        }
        $left = $qty;
        foreach (rebuild_supply($uid, $need) as $it) {
            $take = min($left, (int)$it['qty']);
            if ($take > 0 && !give_item($uid, (int)$it['id'], -$take)) { db()->rollBack(); return [false, 'Something went missing from your satchel.']; }
            $left -= $take;
            if ($left <= 0) break;
        }
        if ($left > 0) { db()->rollBack(); return [false, 'You don’t have enough for this stage.']; }
    }
    if (q('UPDATE landmark_repairs SET stage = stage + 1 WHERE id = ? AND user_id = ? AND stage = ? AND done_at IS NULL AND dropped_at IS NULL', [$repairId, $uid, $stage - 1])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That stage is already done.'];
    }
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    add_xp($uid, $xp, 'Repairs');   // v0.9.1: named source for the XP log
    $msg = '🧱 ' . REBUILD_STAGES[$stage][0] . ': done! +' . money($coins) . ', +' . $xp . ' XP.';
    if ($stage === count(REBUILD_STAGES)) {
        q('UPDATE landmark_repairs SET done_at = ? WHERE id = ? AND user_id = ? AND dropped_at IS NULL', [now(), $repairId, $uid]);
        $msg .= ' ' . rebuild_restore($fresh, (int)$lm['id']);
    }
    db()->commit();
    return [true, $msg];
}

/** Give up an unfinished repair. Materials already handed in are not returned. Returns [ok, message]. */
function repair_drop(array $u, int $repairId): array
{
    // v0.7.85: keep the row (stage kept) so taking it on again does not pay the stages twice
    if (q('UPDATE landmark_repairs SET dropped_at = ? WHERE id = ? AND user_id = ? AND done_at IS NULL AND dropped_at IS NULL', [now(), $repairId, (int)$u['id']])->rowCount() !== 1) {
        return [false, 'That repair is finished or gone.'];
    }
    return [true, '🏳️ You gave up that repair. The materials you handed in stay with the builders.'];
}

/** This gnome's unfinished repairs, oldest first (including ones others have already made safe: this gnome can still finish). */
function repair_list(int $uid): array
{
    return q('SELECT r.id, r.landmark_id, r.stage, r.started_at, m.name, m.kind, m.region_id, m.location_id, l.slug AS loc_slug, l.name AS loc_name
              FROM landmark_repairs r JOIN landmarks m ON m.id = r.landmark_id JOIN locations l ON l.id = m.location_id
              WHERE r.user_id = ? AND r.done_at IS NULL AND r.dropped_at IS NULL ORDER BY r.started_at, r.id', [$uid])->fetchAll();
}

/** One repair as a box: the four stages, what the current one needs, and the buttons. $repair is a repair_list row. */
function repair_box(array $u, array $repair, string $back): string
{
    $stage = (int)$repair['stage'] + 1;
    $st = rebuild_stage_status($u, $stage);
    $ready = !array_filter($st, fn($x) => $x[2] < $x[1]);
    [$coins, $xp] = repair_rewards($repair);
    $hidden = '<input type="hidden" name="lm" value="' . (int)$repair['landmark_id'] . '"><input type="hidden" name="repair" value="' . (int)$repair['id'] . '"><input type="hidden" name="back" value="' . e($back) . '">';
    $h = '<div class="rebuild repair"><h3>🔨 ' . e((string)$repair['name']) . '</h3><ol class="stages">';
    foreach (REBUILD_STAGES as $n => [$sname]) {
        $h .= '<li class="' . ($n < $stage ? 'done' : ($n === $stage ? 'now' : '')) . '">' . ($n < $stage ? '✅ ' : '') . e($sname) . '</li>';
    }
    $h .= '</ol>';
    $h .= '<p><b>Stage ' . $stage . ': ' . e(REBUILD_STAGES[$stage][0]) . '</b> needs:</p><ul>';
    foreach ($st as [$lbl, $need, $have]) {
        $h .= '<li class="' . ($have >= $need ? 'good' : 'bad') . '">' . $need . ' ' . e((string)$lbl) . ' <small class="muted">(you have ' . number_format($have) . ')</small></li>';
    }
    $h .= '</ul><p class="help">Each stage pays ' . money($coins) . ' and ' . $xp . ' XP.</p>'
        . '<form method="post" class="inline" action="' . e(url('landmark.php')) . '">' . csrf_field() . '<input type="hidden" name="do" value="repair_hand">' . $hidden
        . '<button class="btn small"' . ($ready ? '' : ' disabled') . '>🧱 Hand in stage ' . $stage . '</button></form> '
        . '<a class="btn small alt" href="' . e(url('inventory.php?tab=craft&c=building')) . '">Craft materials →</a> '
        . '<form method="post" class="inline" action="' . e(url('landmark.php')) . '" data-confirm="Give up this repair? The materials you’ve handed in are not returned.">' . csrf_field() . '<input type="hidden" name="do" value="repair_drop">' . $hidden
        . '<button class="btn small alt">Give up</button></form></div>';
    return $h;
}
