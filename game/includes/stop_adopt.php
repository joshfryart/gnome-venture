<?php
declare(strict_types=1);
/**
 * Adopt a stop (v1.0.0 wave 1). A gnome adopts one rest stop (setting stop_adopt_limit), pays a small fee, then hands in building
 * materials and Petals over time (the same stone, planks, rope, meals and fine finds as repairing a ruin: rebuild.php).
 * When every need of the next tier is met the stop moves up a tier for EVERYONE: tiers unlock extra activities (stop_acts.tier), tier 4 gives
 * one more slot per visit. The adopter's name is on the plaque, and they get a small daily perk there. Releasing keeps the tier;
 * the next adopter carries on.
 */

require_once __DIR__ . '/rebuild.php';

/** @return array<int, array> tier rows by number */
function stop_tiers(): array
{
    static $cache = null;
    if ($cache === null) {
        $cache = [];
        foreach (q('SELECT * FROM stop_tiers ORDER BY tier')->fetchAll() as $r) $cache[(int)$r['tier']] = $r;
    }
    return $cache;
}

/** v2.0.77: the two local materials of a region ({a}, {b}), from data/region_locals.txt; a region not listed uses stone and rope. */
function region_locals(string $code): array
{
    static $map = null;
    if ($map === null) {
        $map = [];
        $f = __DIR__ . '/data/region_locals.txt';
        foreach (is_file($f) ? file($f, FILE_IGNORE_NEW_LINES) : [] as $line) {
            $x = array_map('trim', explode('|', trim($line)));
            if (count($x) >= 3 && $x[0] !== '' && $x[0][0] !== '#') $map[strtoupper($x[0])] = [$x[1], $x[2]];
        }
    }
    return $map[strtoupper($code)] ?? ['building-stone', 'rope'];
}

/**
 * v2.0.77: the upgrade tiers of THIS stop: the plain ones (stop_tiers) with the themed row for its kind of stop laid over each tier, and
 * {a} {b} in the needs turned into the region's own materials. @return array<int, array> tier rows by number
 */
function stop_tiers_for(array $loc): array
{
    static $themes = null;
    if ($themes === null) {
        $themes = [];
        foreach (q('SELECT * FROM stop_tier_themes ORDER BY tier')->fetchAll() as $r) $themes[(string)$r['stop_type']][(int)$r['tier']] = $r;
    }
    require_once __DIR__ . '/stops.php';
    $out = stop_tiers();
    $over = $themes[stop_type_of($loc)] ?? [];
    foreach ($out as $n => $row) if (isset($over[$n])) $out[$n] = array_merge($row, array_intersect_key($over[$n], array_flip(['name', 'icon', 'needs', 'gives', 'plaque'])));
    [$a, $b] = region_locals(stop_region_code($loc));
    foreach ($out as $n => $row) $out[$n]['needs'] = str_replace(['{a}', '{b}'], [$a, $b], (string)$row['needs']);
    return $out;
}

/** v2.0.77: the picture of a themed upgrade (assets/img/stoptiers/<kind>-<tier>.png: PLACEHOLDER art for now, see claude/todo-art-variety.md), else its emoji. */
function stop_tier_img(array $loc, int $n, array $t): string
{
    $rel = 'assets/img/stoptiers/' . stop_type_of($loc) . '-' . $n . '.png';
    if (!pixel_has($rel)) return e((string)$t['icon']);
    return '<img class="ico pix tierimg" src="' . e(url($rel)) . '" alt="" width="24" height="24" loading="lazy" decoding="async">';
}

function stop_adoption(int $locId): ?array
{
    return q_one('SELECT a.*, u.gnome_name, u.username, f.gnome_name AS founder_name, f.username AS founder_user
                  FROM stop_adoptions a LEFT JOIN users u ON u.id = a.user_id LEFT JOIN users f ON f.id = a.founder_id WHERE a.location_id = ?', [$locId]);
}

function stop_tier(int $locId): int
{
    return (int)q_val('SELECT tier FROM stop_adoptions WHERE location_id = ?', [$locId]);
}

function stop_adopt_limit(): int
{
    return max(0, min(20, (int)setting('stop_adopt_limit')));
}

/** v1.6.3: the highest tier a stop can be built to (the Hall). */
function stop_top_tier(): int
{
    $t = stop_tiers();
    return $t ? max(array_keys($t)) : 0;
}

/**
 * v1.6.3: how many stops this gnome may look after: 1, plus 1 for each stop they look after that is built to the top tier,
 * never above the admin max (stop_adopt_limit). Returns [slots, used, the name of a stop still being built or '' ].
 */
function stop_adopt_slots(int $uid): array
{
    $mine = stop_adopted_by($uid);
    $top = stop_top_tier();
    $finished = 0;
    $building = '';
    foreach ($mine as $m) {
        if ($top > 0 && (int)$m['tier'] >= $top) $finished++;
        elseif ($building === '') $building = (string)$m['name'];
    }
    return [max(0, min(stop_adopt_limit(), 1 + $finished)), count($mine), $building];
}

/** The stops this gnome looks after. */
function stop_adopted_by(int $uid): array
{
    return q('SELECT a.*, l.name, l.slug FROM stop_adoptions a JOIN locations l ON l.id = a.location_id WHERE a.user_id = ? ORDER BY a.adopted_at', [$uid])->fetchAll();
}

/** "building-stone:4,coins:200" => [['building-stone', 4], ['coins', 200]] */
function stop_tier_needs(array $tierRow): array
{
    $out = [];
    foreach (array_filter(array_map('trim', explode(',', (string)$tierRow['needs']))) as $n) {
        [$k, $q] = array_pad(explode(':', $n, 2), 2, '1');
        if ($k !== '' && (int)$q > 0) $out[] = [$k, (int)$q];
    }
    return $out;
}

function stop_need_label(string $key): string
{
    return match ($key) {
        'coins' => (string)setting('currency_name'),
        'meal' => 'home-cooked meals or feasts',
        'fine' => 'uncommon or rare finds',
        default => BUILDING_ITEMS[$key][0] ?? (string)q_val('SELECT name FROM items WHERE slug = ?', [$key]) ?: $key,
    };
}

/** What this gnome has of a need. */
function stop_need_have(array $u, string $key): int
{
    if ($key === 'coins') return (int)$u['coins'];
    $type = in_array($key, ['meal', 'fine'], true) ? $key : 'item';
    return array_sum(array_column(rebuild_supply((int)$u['id'], [$type, $key]), 'qty'));
}

function stop_pool_of(?array $adoption): array
{
    return $adoption ? ((json_decode((string)($adoption['pool'] ?? ''), true) ?: [])) : [];
}

/** Adopt this stop. */
function stop_adopt(array $u, array $loc): array
{
    $uid = (int)$u['id'];
    if (($loc['kind'] ?? '') !== 'village') return [false, 'Only rest stops can be adopted.'];
    $limit = stop_adopt_limit();
    if ($limit < 1) return [false, 'Adopting stops is switched off for now.'];
    if (!q_val('SELECT 1 FROM stop_stamps WHERE user_id = ? AND location_id = ?', [$uid, (int)$loc['id']])) return [false, 'Visit the stop first and collect its stamp.'];
    [$slots, $used] = stop_adopt_slots($uid);   // v1.6.3: slots grow with finished stops
    if ($used >= $slots) return [false, 'You already look after ' . $used . ' stop' . ($used === 1 ? '' : 's') . '. Finish building one to its Hall to look after another' . ($slots >= $limit ? ' (the most is ' . $limit . ')' : '') . ', or let one go first.'];
    $cost = max(0, (int)setting('stop_adopt_cost'));
    db()->beginTransaction();
    try {
        q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // v1.6.3: row lock, then count again (two logins can't both take the last slot)
        [$slots2, $used2] = stop_adopt_slots($uid);
        if ($used2 >= $slots2) { db()->rollBack(); return [false, 'You have no free adopt slot. Finish building a stop to its Hall first.']; }
        $a = q_one('SELECT * FROM stop_adoptions WHERE location_id = ?', [(int)$loc['id']]);
        if ($a && $a['user_id']) { db()->rollBack(); return [false, 'Someone already looks after this stop.']; }
        if ($cost > 0 && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $uid, $cost])->rowCount() !== 1) { db()->rollBack(); return [false, 'Adopting costs ' . money($cost) . '.']; }
        if ($a) {   // (the perk day is kept: let go and re-adopt can't earn a second daily welcome)
            if (q('UPDATE stop_adoptions SET user_id = ?, adopted_at = ? WHERE id = ? AND user_id IS NULL', [$uid, now(), $a['id']])->rowCount() !== 1) {
                db()->rollBack();   // someone else got there first: the fee comes back with the rollback
                return [false, 'Someone just adopted this stop.'];
            }
        } else {
            db_insert('stop_adoptions', ['location_id' => (int)$loc['id'], 'user_id' => $uid, 'founder_id' => $uid, 'tier' => 0, 'pool' => '{}', 'adopted_at' => now()]);
        }
        db()->commit();
    } catch (PDOException $e) {
        if (db()->inTransaction()) db()->rollBack();
        return [false, 'Someone just adopted this stop.'];
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();
        throw $e;
    }
    return [true, '🏡 You now look after ' . $loc['name'] . '. Hand in building materials and ' . setting('currency_name') . ' to give it a bench, a stall, a well and a hall.'];
}

function stop_release(array $u, array $loc): array
{
    if (q('UPDATE stop_adoptions SET user_id = NULL WHERE location_id = ? AND user_id = ?', [(int)$loc['id'], (int)$u['id']])->rowCount() !== 1) return [false, 'You don’t look after this stop.'];
    return [true, 'You hand ' . $loc['name'] . ' back to the road. Its upgrades stay for everyone, and the next adopter picks up where you left off.'];
}

/** Hand in some of a need for the next tier. Completing the last need raises the tier. */
function stop_contribute(array $u, array $loc, string $key, int $qty): array
{
    $uid = (int)$u['id'];
    $a = stop_adoption((int)$loc['id']);
    if (!$a || (int)$a['user_id'] !== $uid) return [false, 'Only the stop’s adopter can build here.'];
    $aid = (int)$a['id'];
    return db_tx(function () use ($uid, $loc, $key, $qty, $aid): array {
        // v1.0.0: lock the adoption row first (a no-op write), then read it, so two hand-ins can't both work from the same pool
        q('UPDATE stop_adoptions SET id = id WHERE id = ?', [$aid]);
        $a = stop_adoption((int)$loc['id']);
        if (!$a || (int)$a['user_id'] !== $uid) { db()->rollBack(); return [false, 'Only the stop’s adopter can build here.']; }
        $tiers = stop_tiers_for($loc);
        $next = (int)$a['tier'] + 1;
        if (!isset($tiers[$next])) { db()->rollBack(); return [false, 'This stop has everything. It’s a wonderful place!']; }
        $needs = stop_tier_needs($tiers[$next]);
        $want = null;
        foreach ($needs as [$k, $q]) if ($k === $key) $want = $q;
        if ($want === null) { db()->rollBack(); return [false, 'That isn’t needed for this upgrade.']; }
        $pool = stop_pool_of($a);
        $left = $want - (int)($pool[$key] ?? 0);
        $qty = min(max(1, $qty), $left);
        if ($qty <= 0) { db()->rollBack(); return [false, 'That part is already covered.']; }
        if ($key === 'coins') {
            if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$qty, $uid, $qty])->rowCount() !== 1) { db()->rollBack(); return [false, 'You need ' . money($qty) . '.']; }
        } else {
            $type = in_array($key, ['meal', 'fine'], true) ? $key : 'item';
            $take = $qty;
            foreach (rebuild_supply($uid, [$type, $key]) as $it) {
                $n = min($take, (int)$it['qty']);
                if ($n > 0 && !give_item($uid, (int)$it['id'], -$n)) { db()->rollBack(); return [false, 'Something went missing from your satchel.']; }
                $take -= $n;
                if ($take <= 0) break;
            }
            if ($take > 0) { db()->rollBack(); return [false, 'You don’t have enough ' . stop_need_label($key) . '.']; }
        }
        $pool[$key] = (int)($pool[$key] ?? 0) + $qty;
        $done = true;
        foreach ($needs as [$k, $q]) if ((int)($pool[$k] ?? 0) < $q) $done = false;
        if ($done) {
            if (q('UPDATE stop_adoptions SET tier = ?, pool = ? WHERE id = ? AND tier = ?', [$next, '{}', $a['id'], (int)$a['tier']])->rowCount() !== 1) { db()->rollBack(); return [false, 'Someone else just finished that upgrade.']; }
            add_xp($uid, 20 * $next, 'rest_stop');   // (only when this request raised the tier)
        } else {
            if (q('UPDATE stop_adoptions SET pool = ? WHERE id = ? AND tier = ?', [json_encode($pool), $a['id'], (int)$a['tier']])->rowCount() !== 1) { db()->rollBack(); return [false, 'The upgrade just changed. Try again.']; }
        }
        if ($done) return [true, '🎉 ' . $loc['name'] . ' now has: ' . $tiers[$next]['name'] . '! (+' . (20 * $next) . ' XP) ' . (string)$tiers[$next]['gives']];
        return [true, '🧱 You hand in ' . $qty . ' × ' . stop_need_label($key) . '.'];
    });
}

/** The adopter's small daily perk at their stop. */
function stop_adopter_perk(array $u, array $loc): array
{
    $uid = (int)$u['id'];
    $a = stop_adoption((int)$loc['id']);
    if (!$a || (int)$a['user_id'] !== $uid) return [false, 'This isn’t your stop.'];
    $today = hollow_date('Y-m-d');
    if (q('UPDATE stop_adoptions SET perk_day = ? WHERE id = ? AND (perk_day IS NULL OR perk_day <> ?)', [$today, $a['id'], $today])->rowCount() !== 1) return [false, 'You’ve already had today’s welcome from the villagers.'];
    $t = (int)$a['tier'];
    $coins = 6 + 8 * $t;
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    $line = '+' . $coins . ' ' . setting('currency_name');
    if ($t >= 1) { apply_event_effect(q_one('SELECT * FROM users WHERE id = ?', [$uid]), 'energy:' . $t); $line .= ', +' . $t . ' energy'; }
    return [true, '🏡 The villagers of ' . $loc['name'] . ' thank their adopter. (' . $line . ')'];
}

function stop_gnome_label(array $a, string $who = 'name'): string
{
    $n = (string)($a['gnome_name'] ?? '') ?: (string)($a['username'] ?? '');
    return $n !== '' ? $n : 'a gnome';
}

/** The plaque by the door: what's been built, and who looks after it. */
function stop_plaque(array $loc): string
{
    $a = stop_adoption((int)$loc['id']);
    if (!$a) return '';
    $tiers = stop_tiers_for($loc);
    $built = [];
    for ($t = 1; $t <= (int)$a['tier']; $t++) if (isset($tiers[$t])) $built[] = stop_tier_img($loc, $t, $tiers[$t]) . ' ' . e((string)$tiers[$t]['name']);
    $who = $a['user_id'] ? 'Looked after by <b>' . e(stop_gnome_label($a)) . '</b>' : 'Waiting for someone to look after it';
    $founder = $a['founder_id'] && (int)$a['founder_id'] !== (int)$a['user_id'] ? ' · founded by <b>' . e((string)($a['founder_name'] ?: $a['founder_user'])) . '</b>' : '';
    return '<div class="st-plaque"><span class="st-plaque-t">🪧 Plaque</span> ' . $who . $founder . ($built ? '<br><small>' . implode(' · ', $built) . '</small>' : '') . '</div>';
}

/** The adopt / upgrade panel (HTML). */
function stop_adopt_panel(array $u, array $loc, callable $form): string
{
    $uid = (int)$u['id'];
    $a = stop_adoption((int)$loc['id']);
    $mine = $a && (int)$a['user_id'] === $uid;
    $tiers = stop_tiers_for($loc);
    $limit = stop_adopt_limit();
    if ($limit < 1 && !$a) return '';
    $h = '<details class="box st-adopt"' . ($mine ? ' open' : '') . '><summary><b>🏡 ' . ($mine ? 'You look after this stop' : ($a && $a['user_id'] ? 'Adopted by ' . e(stop_gnome_label($a)) : 'Adopt this stop')) . '</b></summary>';
    if (!$a || !$a['user_id']) {
        $has = (bool)q_val('SELECT 1 FROM stop_stamps WHERE user_id = ? AND location_id = ?', [$uid, (int)$loc['id']]);
        [$slots, $mineCount, $building] = stop_adopt_slots($uid);   // v1.6.3
        $h .= '<p>Look after ' . e($loc['name']) . ': hand in building materials over time and it grows a bench, a stall, a well and a hall for everyone who passes. Your name goes on the plaque, and the villagers give you a small gift every day.</p>'
            . '<p class="help">Costs ' . money(max(0, (int)setting('stop_adopt_cost'))) . '. You look after ' . $mineCount . ' of ' . $slots . '.'
            . ($mineCount >= $slots && $slots < $limit && $building !== '' ? ' Finish ' . e($building) . '’s Hall to look after one more.' : ($mineCount >= $slots && $slots >= $limit ? ' That’s the most one gnome can look after.' : '')) . '</p>';
        $h .= $has ? $form('_adopt', '<button class="btn small"' . ($mineCount >= $slots ? ' disabled' : '') . '>🏡 Adopt ' . e($loc['name']) . '</button>') : '<p class="muted">Collect this stop’s stamp first (it comes with your first visit).</p>';
        if ($a && (int)$a['tier'] > 0) $h .= '<p class="help">It already has a tier ' . (int)$a['tier'] . ' upgrade from an earlier adopter.</p>';
    } else {
        $h .= '<p>' . stop_plaque($loc) . '</p>';
    }
    if ($mine) {
        $next = (int)$a['tier'] + 1;
        $h .= '<ol class="st-tiers">';
        foreach ($tiers as $n => $t) {
            $h .= '<li class="' . ($n <= (int)$a['tier'] ? 'done' : ($n === $next ? 'now' : '')) . '">' . ($n <= (int)$a['tier'] ? '✅ ' : '') . stop_tier_img($loc, (int)$n, $t) . ' <b>' . e((string)$t['name']) . '</b><small class="muted"> · ' . e((string)$t['gives']) . '</small></li>';
        }
        $h .= '</ol>';
        if (isset($tiers[$next])) {
            $pool = stop_pool_of($a);
            $h .= '<p><b>Next: ' . e((string)$tiers[$next]['name']) . '</b> needs:</p><ul class="st-needs">';
            foreach (stop_tier_needs($tiers[$next]) as [$k, $q]) {
                $given = min($q, (int)($pool[$k] ?? 0));
                $have = stop_need_have($u, $k);
                $left = $q - $given;
                $h .= '<li class="' . ($left <= 0 ? 'good' : '') . '"><span>' . ($left <= 0 ? '✅ ' : '') . e(stop_need_label($k)) . ' <b>' . $given . '/' . $q . '</b> <small class="muted">(you have ' . number_format($have) . ')</small></span>';
                if ($left > 0) {
                    $max = max(1, min($left, $have));
                    $h .= $form('_give', '<input type="hidden" name="need" value="' . e($k) . '"><input type="number" name="qty" min="1" max="' . $left . '" value="' . $max . '" aria-label="How many"> <button class="btn small"' . ($have < 1 ? ' disabled' : '') . '>Hand in</button>');
                }
                $h .= '</li>';
            }
            $h .= '</ul><p class="help">Hand in a little at a time. The tier rises when every line is full. <a href="' . e(url('inventory.php?tab=craft&c=building')) . '">Craft building materials →</a></p>';
        } else {
            $h .= '<p class="good"><b>🎉 Every upgrade is built. What a stop!</b></p>';
        }
        $done = ($a['perk_day'] ?? '') === hollow_date('Y-m-d');
        $h .= $form('_perk', '<button class="btn small alt"' . ($done ? ' disabled' : '') . '>🎁 ' . ($done ? 'Today’s welcome taken' : 'Collect the villagers’ welcome') . '</button>')
            . $form('_release', '<button class="btn small alt" data-confirm="Hand this stop back? Its upgrades stay for everyone.">Let it go</button>');
    }
    return $h . '</details>';
}
