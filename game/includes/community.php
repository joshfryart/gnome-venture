<?php
declare(strict_types=1);
/**
 * The Community Garden (v0.7.14): one shared garden in Mossbottom.
 * - Once a day every gnome may take ONE thing: a seed or crop from the shared store, or a ripe plant of their choice.
 * - Gnomes can donate seeds, and volunteer for a tending shift (30/60/120 min). During a shift they can water, weed,
 *   plant from the store and harvest into the store, earning a small thank-you each time. They can't adventure meanwhile.
 * - Old Moss and the village gnomes (NPCs) keep it alive when it's quiet: a little watering, weeding and planting every hour.
 * Beds grow lazily like real gardens: only while watered, at half speed when weedy.
 */

const COMMUNITY_SHIFTS = [30, 60, 120];
const COMMUNITY_ALMANAC = "In the middle of Mossbottom there’s a garden that belongs to everyone, and only gnomes keep it stocked.\n\n"
    . "💚 [b]Donate[/b] spare seeds and they’re planted for everyone. Nothing grows here unless someone gave it.\n"
    . "🧑‍🌾 [b]Volunteer[/b] for a tending shift: water, weed, plant and harvest into the store (1 energy a job, a small thank-you each time). "
    . "You can’t go adventuring while you’re on shift.\n"
    . "🧺 [b]Once a day[/b], a gnome who’s short of Petals may take one small thing: a seed or crop from the store, or one ripe crop from a bed.\n\n"
    . "Old Moss waters and weeds when it’s quiet, but he can only plant what’s been donated. The most helpful gnomes of the week are thanked on the garden gate.";

function community_size(): int
{
    return max(3, min(10, (int)setting('community_size')));
}

/** Bring a bed's growth and weeds up to date (doesn't save). */
function cbed_tick(array $b, ?array $p): array
{
    $now = time();
    $at = ts($b['grow_at']) ?: $now;
    if ($p && $now > $at) {
        $wet = min($now, ts($b['water_until'])) - $at;
        if ($wet > 0) $b['grown'] = min((int)$p['grow_minutes'] * 60, (int)$b['grown'] + (int)($wet * ((int)$b['weeds'] >= 20 ? 0.5 : 1)));
    }
    $b['grow_at'] = gmdate('Y-m-d H:i:s', $now);
    $wa = ts($b['weeds_at']) ?: $now;
    $h = intdiv($now - $wa, 7200);   // a weed every two hours
    if ($h > 0) {
        $b['weeds'] = min(50, (int)$b['weeds'] + $h);
        $b['weeds_at'] = gmdate('Y-m-d H:i:s', $wa + $h * 7200);
    }
    return $b;
}

/** Did a bed change (growth, weeds, planting, watering) since it was read? v0.7.85: only changed beds are written back. */
function cbed_changed(array $now, array $read): bool
{
    foreach (['plant_id', 'planted_by', 'grown', 'water_until', 'weeds', 'weeds_at'] as $k) {
        if ((string)($now[$k] ?? '') !== (string)($read[$k] ?? '')) return true;
    }
    return false;
}

/**
 * Save a bed only if it is still in the state it was read in (v0.7.85). If another gnome planted, harvested or
 * watered it since, nothing is overwritten and this returns false. Null-safe without <=>, so MySQL and SQLite agree.
 */
function cbed_save(array $b, array $read): bool
{
    $pid = $read['plant_id'] ?? null;
    $wu = $read['water_until'] ?? null;
    return q('UPDATE community_beds SET plant_id = ?, planted_by = ?, grown = ?, grow_at = ?, water_until = ?, weeds = ?, weeds_at = ?
              WHERE id = ? AND (plant_id = ? OR (plant_id IS NULL AND ? IS NULL)) AND grown = ? AND weeds = ?
              AND (water_until = ? OR (water_until IS NULL AND ? IS NULL))',
        [$b['plant_id'], $b['planted_by'], (int)$b['grown'], $b['grow_at'], $b['water_until'], (int)$b['weeds'], $b['weeds_at'],
         $b['id'], $pid, $pid, (int)$read['grown'], (int)$read['weeds'], $wu, $wu])->rowCount() === 1;
}

function cbed_ripe(array $b, ?array $p): bool
{
    return $p && (int)$b['grown'] >= (int)$p['grow_minutes'] * 60;
}

function cbed_thirsty(array $b, ?array $p): bool
{
    return $p && !cbed_ripe($b, $p) && ts($b['water_until']) <= time();
}

/** All beds, brought up to date, with their plants. Runs the NPC gardeners first. */
function community_beds(): array
{
    community_npc_tick();
    $plants = [];
    $beds = [];
    foreach (q('SELECT * FROM community_beds ORDER BY y, x')->fetchAll() as $read) {
        $p = $read['plant_id'] ? ($plants[(int)$read['plant_id']] ??= q_one('SELECT * FROM plants WHERE id = ?', [$read['plant_id']])) : null;
        $b = cbed_tick($read, $p);
        // v0.7.85: a bed is written back only when it grew or got weedy, and only if nobody changed it meanwhile.
        // '_read' is the state in the database now, which is what a tending action must still find.
        if (cbed_changed($b, $read) && cbed_save($b, $read)) $read = $b;
        $beds[(int)$b['id']] = $b + ['_p' => $p, '_read' => $read];
    }
    return $beds;
}

/** Old Moss and friends: each hour that's passed, water a few beds, pull a few weeds and plant a couple of empty ones. */
function community_npc_tick(): void
{
    $last = ts(setting('community_npc_at')) ?: time() - 3600;
    $hours = min(24, intdiv(time() - $last, 3600));
    if ($hours < 1) return;
    set_setting('community_npc_at', gmdate('Y-m-d H:i:s', $last + $hours * 3600));
    setting('__reload__');
    for ($h = 0; $h < $hours; $h++) {
        $beds = q('SELECT * FROM community_beds ORDER BY ' . sql_random())->fetchAll();
        $water = 4;
        $weed = 2;
        $plant = 1;
        foreach ($beds as $read) {
            $p = $read['plant_id'] ? q_one('SELECT * FROM plants WHERE id = ?', [$read['plant_id']]) : null;
            $b = cbed_tick($read, $p);
            $dirty = cbed_changed($b, $read);
            if ($p && $water > 0 && cbed_thirsty($b, $p)) {
                $b['water_until'] = gmdate('Y-m-d H:i:s', time() + (int)setting('community_water_hours') * 3600);
                $water--;
                $dirty = true;
            }
            if ($weed > 0 && (int)$b['weeds'] >= 15) {
                $b['weeds'] = 0;
                $weed--;
                $dirty = true;
            }
            $seed = 0;
            if (!$p && $plant > 0) {
                $seed = community_pick_seed();
                if ($seed) {
                    $b = array_merge($b, ['plant_id' => $seed, 'planted_by' => null, 'grown' => 0, 'water_until' => gmdate('Y-m-d H:i:s', time() + 3 * 3600)]);
                    $plant--;
                    $dirty = true;
                }
            }
            // v0.7.85: write only changed beds, and only if no gnome changed the bed since it was read
            if ($dirty && !cbed_save($b, $read) && $seed) {
                q('UPDATE community_store SET qty = qty + 1 WHERE item_id = (SELECT seed_item_id FROM plants WHERE id = ?)', [$seed]);   // put the seed back
            }
        }
    }
}

/** A plant for the NPCs to sow: only from seeds gnomes have donated (v0.7.27: nothing comes from nowhere). */
function community_pick_seed(): int
{
    $st = q_one("SELECT s.item_id, p.id AS plant_id FROM community_store s JOIN plants p ON p.seed_item_id = s.item_id WHERE s.qty > 0 ORDER BY " . sql_random() . " LIMIT 1");
    if ($st) {
        q('UPDATE community_store SET qty = qty - 1 WHERE item_id = ? AND qty > 0', [$st['item_id']]);
        return (int)$st['plant_id'];
    }
    return 0;
}

/** Can this gnome take today's boon? Like a soup kitchen: only for gnomes without much (setting community_need_coins; 0 = anyone). */
function community_need_ok(array $u): bool
{
    $limit = (int)setting('community_need_coins');
    return $limit <= 0 || (int)$u['coins'] < $limit;
}

function community_log(int $uid, string $action): void
{
    db_insert('community_log', ['user_id' => $uid, 'action' => $action, 'week' => job_period_key('weekly'), 'at' => now()]);
    q('UPDATE users SET community_rep = community_rep + 1 WHERE id = ?', [$uid]);
}

function community_took_today(array $u): bool
{
    return ($u['community_day'] ?? '') === job_period_key('daily');
}

/** The once-a-day take: a store item or a ripe bed. */
function community_take(array $u, string $what, int $id): array
{
    $uid = (int)$u['id'];
    if (community_took_today($u)) return [false, 'You’ve already taken something today. Come back after the daily reset.'];
    if (!community_need_ok($u)) return [false, 'The garden’s gifts are for gnomes who are short of Petals (under ' . money((int)setting('community_need_coins')) . '). Why not donate some seeds instead?'];
    db()->beginTransaction();
    if (q('UPDATE users SET community_day = ? WHERE id = ? AND (community_day IS NULL OR community_day <> ?)', [job_period_key('daily'), $uid, job_period_key('daily')])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You’ve already taken something today.'];
    }
    if ($what === 'store') {
        if (q('UPDATE community_store SET qty = qty - 1 WHERE item_id = ? AND qty > 0', [$id])->rowCount() !== 1) {
            db()->rollBack();
            return [false, 'Someone took the last one.'];
        }
        give_item($uid, $id, 1);
        db()->commit();
        return [true, '🧺 You take 1 × ' . q_val('SELECT name FROM items WHERE id = ?', [$id]) . ' from the community store. Enjoy!'];
    }
    $beds = community_beds();
    $b = $beds[$id] ?? null;
    if (!$b || !cbed_ripe($b, $b['_p'])) {
        db()->rollBack();
        return [false, 'That one isn’t ripe.'];
    }
    $p = $b['_p'];
    if (q('UPDATE community_beds SET plant_id = NULL, planted_by = NULL, grown = 0, water_until = NULL WHERE id = ? AND plant_id = ?', [$b['id'], $p['id']])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'Someone picked it first.'];
    }
    $n = 1;   // v0.7.27: a small boon
    if ($p['produce_item_id']) give_item($uid, (int)$p['produce_item_id'], $n);
    db()->commit();
    return [true, '🌾 You pick ' . $n . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$p['produce_item_id']]) . ' from the community garden.'];
}

function community_donate(array $u, int $itemId, int $qty): array
{
    $uid = (int)$u['id'];
    $item = q_one("SELECT * FROM items WHERE id = ? AND category = 'seed'", [$itemId]);
    if (!$item || $qty < 1) return [false, 'Pick some seeds to donate.'];
    db()->beginTransaction();
    if (!give_item($uid, $itemId, -$qty)) {
        db()->rollBack();
        return [false, 'You don’t have that many.'];
    }
    if (q('UPDATE community_store SET qty = qty + ? WHERE item_id = ?', [$qty, $itemId])->rowCount() === 0) {
        db_insert('community_store', ['item_id' => $itemId, 'qty' => $qty]);
    }
    community_log($uid, 'donate');
    db()->commit();
    return [true, '💚 You donate ' . $qty . ' × ' . $item['name'] . ' to the community store. Thank you!'];
}

function community_on_shift(array $u): bool
{
    return ts($u['community_shift_until'] ?? null) > time();
}

function community_start_shift(array $u, int $minutes): array
{
    $uid = (int)$u['id'];
    if (!in_array($minutes, COMMUNITY_SHIFTS, true)) return [false, 'Pick a shift length.'];
    if (community_on_shift($u)) return [false, 'You’re already on shift.'];
    if (q_val("SELECT 1 FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid])) return [false, 'Finish your walk first.'];
    q('UPDATE users SET community_shift_until = ?, shift_actions = 0 WHERE id = ?', [gmdate('Y-m-d H:i:s', time() + $minutes * 60), $uid]);
    return [true, '🧑‍🌾 You pull on your gardening gloves. Thanks for helping! You can’t go adventuring until your shift ends (' . $minutes . ' min).'];
}

function community_end_shift(array $u): array
{
    q('UPDATE users SET community_shift_until = NULL WHERE id = ?', [$u['id']]);
    return [true, 'You hang up your gloves. Thanks for your help today!'];
}

/** A tending action on a shift: water, weed, plant (store seed), harvest (into the store). */
function community_tend(array $u, string $action, int $bedId, int $seedId = 0): array
{
    $uid = (int)$u['id'];
    if (!community_on_shift($u)) return [false, 'Start a tending shift first.'];
    if ((int)$u['shift_actions'] >= (int)setting('community_shift_cap')) return [false, 'You’ve done plenty this shift. Have a rest!'];
    $beds = community_beds();
    $b = $beds[$bedId] ?? null;
    if (!$b) return [false, 'No such bed.'];
    $p = $b['_p'];
    // v0.7.85: check the bed before any energy is spent, so a refused job costs nothing
    $np = null;
    switch ($action) {
        case 'water':
            if (!cbed_thirsty($b, $p)) return [false, 'It doesn’t need water.'];
            break;
        case 'weed':
            if ((int)$b['weeds'] < 5) return [false, 'No weeds worth pulling.'];
            break;
        case 'plant':
            if ($p) return [false, 'Something is already growing there.'];
            $np = q_one('SELECT p.* FROM plants p JOIN community_store s ON s.item_id = p.seed_item_id WHERE p.seed_item_id = ? AND s.qty > 0', [$seedId]);
            if (!$np) return [false, 'Pick seeds from the store.'];
            break;
        case 'harvest':
            if (!cbed_ripe($b, $p) || !$p['produce_item_id']) return [false, 'Nothing ripe there.'];
            break;
        default:
            return [false, 'Unknown job.'];
    }
    db()->beginTransaction();
    if (!spend_energy($uid, 1)) {   // v0.7.27
        db()->rollBack();
        return [false, 'You’re too tired to help right now. Each job takes 1 energy.'];
    }
    switch ($action) {
        case 'water':
            $b['water_until'] = gmdate('Y-m-d H:i:s', time() + (int)setting('community_water_hours') * 3600);
            $msg = '💧 You water the ' . $p['name'] . '.';
            break;
        case 'weed':
            $b['weeds'] = 0;
            $msg = '🌿 You pull the weeds.';
            break;
        case 'plant':
            if (q('UPDATE community_store SET qty = qty - 1 WHERE item_id = ? AND qty > 0', [$seedId])->rowCount() !== 1) {
                db()->rollBack();
                return [false, 'Pick seeds from the store.'];
            }
            $b = array_merge($b, ['plant_id' => (int)$np['id'], 'planted_by' => $uid, 'grown' => 0, 'water_until' => gmdate('Y-m-d H:i:s', time() + (int)setting('community_water_hours') * 3600)]);
            $msg = '🌱 You plant ' . $np['name'] . ' and give it a drink.';
            break;
        case 'harvest':
            $n = random_int(2, 3);
            if (q('UPDATE community_store SET qty = qty + ? WHERE item_id = ?', [$n, $p['produce_item_id']])->rowCount() === 0) {
                db_insert('community_store', ['item_id' => (int)$p['produce_item_id'], 'qty' => $n]);
            }
            $b = array_merge($b, ['plant_id' => null, 'planted_by' => null, 'grown' => 0, 'water_until' => null]);
            $msg = '🧺 You harvest ' . $n . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$p['produce_item_id']]) . ' into the community store.';
            break;
    }
    // Written only if the bed is still as it was read. If another gnome got there first, undo everything (energy included).
    if (!cbed_save($b, $b['_read'])) {
        db()->rollBack();
        return [false, 'Someone else just tended that bed. Try again.'];
    }
    $tip = (int)setting('community_tip');
    q('UPDATE users SET coins = coins + ?, shift_actions = shift_actions + 1 WHERE id = ?', [$tip, $uid]);
    add_xp($uid, 1);
    community_log($uid, $action);
    db()->commit();
    return [true, $msg . ' (+' . money($tip) . ', +1 XP)'];
}

/** Make the beds and stock the store on first run. Adds only. */
function ensure_community(): void
{
    // v0.7.27: a smaller boon, supplied only by gnomes. Older worlds keep any settings an admin changed.
    if (setting('community_v') !== '2') {
        foreach (['community_shift_cap' => ['20', '8'], 'community_tip' => ['4', '2']] as $k => [$old, $new]) {
            if (q_val('SELECT value FROM settings WHERE name = ?', [$k]) === $old) set_setting($k, $new);
        }
        q("UPDATE encyclopedia_entries SET body = ? WHERE title = 'The Community Garden' AND chapter = 'General'", [COMMUNITY_ALMANAC]);
        set_setting('community_v', '2');
        setting('__reload__');
    }
    $n = community_size();
    if (!(int)q_val('SELECT COUNT(*) FROM community_beds')) {
        for ($y = 0; $y < $n; $y++) for ($x = 0; $x < $n; $x++) {
            db_insert('community_beds', ['x' => $x, 'y' => $y, 'grown' => 0, 'weeds' => 0, 'grow_at' => now(), 'weeds_at' => now()]);
        }
        set_setting('community_npc_at', gmdate('Y-m-d H:i:s', time() - 6 * 3600));   // Old Moss gets a head start
    }
    if (!q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'The Community Garden' AND chapter = 'General'")) {
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'The Community Garden',
            'body' => COMMUNITY_ALMANAC,
            'unlock_key' => 'start', 'hint' => '', 'sort_order' => 8]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
        }
    }
}
