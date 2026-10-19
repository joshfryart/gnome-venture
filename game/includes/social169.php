<?php
declare(strict_types=1);

/**
 * v1.6.9, two no-typing social features on a friend's / any garden (visit.php):
 *  1. "Water for them": a friend waters the thirsty squares of a friend's garden, once per garden per helper per Hollow day,
 *     at most social169_water_gardens gardens a day per helper. Costs the helper energy, nothing to the owner. Small XP + Petals to the helper.
 *  2. v1.7.0: the 🌻 👏 🐝 ✨ reactions are now gate stamps (the Guestbook, PAL_STAMPS in pals.php). Counts here come from garden_stamps.
 *     The owner gets ONE rolled-up notice per garden per Hollow day (stamps + friend watering), which grows while it is unread.
 *
 * Wiring: social169_settings() merged by settings_schema(); social169_schema() by schema.php; upgrade170.php copies old garden_reacts rows into garden_stamps.
 * Alt farming: the Petals come from the game, not from the owner; the helper must be past fresh_hold(), a friend (both accepted),
 * both in play, and the per-day cap bounds what any pair can earn. The day's claim is a UNIQUE row taken under a users-row lock.
 */

function social169_settings(): array
{
    $int = fn(string $label, int $def, int $min, int $max) => ['label' => $label, 'type' => 'int', 'default' => (string)$def, 'min' => $min, 'max' => $max];
    return [
        'social169_water_on'      => ['label' => 'Helping: any gnome can water another’s garden (💧 Water for them)', 'type' => 'bool', 'default' => '1'],
        'social169_water_gardens' => $int('Helping: most gardens one gnome can water per Hollow day', 3, 1, 50),
        'social169_water_energy'  => $int('Helping: energy it costs the helper', 1, 0, 100),
        'social169_water_xp'      => $int('Helping: XP the helper earns for helping', 5, 0, 10000),
        'social169_water_petals'  => $int('Helping: Petals the helper earns for helping', 5, 0, 100000),
    ];
}

/** [tables, indexes, columns] for schema_statements(). */
function social169_schema(string $PK, string $ID, string $END): array
{
    $t = [];
    $t[] = "CREATE TABLE IF NOT EXISTS garden_waterings (
        id $PK,
        plot_id $ID NOT NULL,
        helper_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        squares INT NOT NULL DEFAULT 0,
        created_at DATETIME NOT NULL,
        UNIQUE (plot_id, helper_id, day)
    )$END";
    // v1.7.0: garden_reacts is UNUSED now (reactions became Guestbook stamps; upgrade170.php copied the rows). Left in place, never dropped on a live game.
    $t[] = "CREATE TABLE IF NOT EXISTS garden_reacts (
        id $PK,
        plot_id $ID NOT NULL,
        user_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        kind VARCHAR(12) NOT NULL,
        created_at DATETIME NOT NULL,
        UNIQUE (plot_id, user_id, day)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS garden_react_notes (
        plot_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        notice_id $ID NOT NULL DEFAULT 0,
        PRIMARY KEY (plot_id, day)
    )$END";
    $i = [
        'CREATE INDEX idx_gwater_helper ON garden_waterings (helper_id, day)',
        'CREATE INDEX idx_greact_plot ON garden_reacts (plot_id, day)',
    ];
    return [$t, $i, []];
}

// ---------------- Water for them ----------------

/** How many of this garden's squares are thirsty right now (growing plants only). Expects tiles/plants from load_plot(). */
function social169_thirsty(array $tiles, array $plants): array
{
    $out = [];
    foreach ($tiles as $row) foreach ($row as $t) {
        if (!$t['plant_id'] || !isset($plants[(int)$t['plant_id']])) continue;
        if (tile_info($t, $plants[(int)$t['plant_id']])['thirsty']) $out[] = $t;
    }
    return $out;
}

function social169_water_used(int $helperId): int
{
    return (int)q_val('SELECT COUNT(*) FROM garden_waterings WHERE helper_id = ? AND day = ?', [$helperId, hollow_date('Y-m-d')]);
}

/**
 * v1.7.0: the checks the Guestbook and watering share. '' when $u may interact with $owner's garden gate, else a short reason:
 * not their own garden, not blocked either way, owner not deleted / banned / in a time-out.
 */
function gate_can_interact(array $u, array $owner): string
{
    require_once __DIR__ . '/pals.php';
    if ((int)$owner['id'] === (int)$u['id']) return 'Your own garden.';
    if (pal_blocked((int)$u['id'], (int)$owner['id'])) return 'Not available.';
    if (!empty($owner['deleted_at']) || (int)$owner['banned'] !== 0 || (!empty($owner['banned_until']) && $owner['banned_until'] > now())) return 'Not available.';
    return '';
}

/** '' when this gnome may help water this owner's garden at all, else a short reason. */
function social169_water_block(array $u, array $owner): string
{
    if (setting('social169_water_on') !== '1') return 'Helping is switched off.';
    if (($why = gate_can_interact($u, $owner)) !== '') return $why;
    if (fresh_hold($u) !== '') return 'New gnomes can’t help yet.';
    return '';
}

/** The button (or why not) for visit.php. */
function social169_water_html(array $u, array $plot, array $owner, array $tiles, array $plants): string
{
    if ((int)$owner['id'] === (int)$u['id'] || setting('social169_water_on') !== '1') return '';
    require_once __DIR__ . '/pals.php';
    $plotId = (int)$plot['id'];
    $block = social169_water_block($u, $owner);
    $cap = max(1, (int)setting('social169_water_gardens'));
    $done = (bool)q_val('SELECT 1 FROM garden_waterings WHERE plot_id = ? AND helper_id = ? AND day = ?', [$plotId, $u['id'], hollow_date('Y-m-d')]);
    $n = count(social169_thirsty($tiles, $plants));
    $cost = max(0, (int)setting('social169_water_energy'));
    if ($block !== '') return '<p class="help">💧 ' . e($block) . '</p>';
    if ($done) return '<p class="good">💧 You watered here today.</p>';
    if (social169_water_used((int)$u['id']) >= $cap) return '<p class="help">💧 ' . $cap . ' gardens watered today. Tomorrow!</p>';
    $dis = '';
    $sub = $n . ' thirsty square' . ($n === 1 ? '' : 's');
    if (!$n) { $dis = ' disabled'; $sub = 'Nothing thirsty'; }
    return '<form method="post">' . csrf_field() . '<input type="hidden" name="g" value="' . $plotId . '"><input type="hidden" name="do" value="water_friend">'
        . choice_row('💧', 'Water for them', $sub, $cost > 0 ? [$cost . ' ⚡', 'cost'] : ['free', 'free'], $n ? 'primary' : '', 'type="submit"' . $dis)
        . '</form>';
}

/** Water a friend's thirsty squares. Returns [ok, message]. */
function social169_water(array $u, int $plotId): array
{
    require_once __DIR__ . '/pals.php';
    require_once __DIR__ . '/garden_logic.php';
    require_once __DIR__ . '/trade.php';
    $me = (int)$u['id'];
    $plot = q_one('SELECT * FROM plots WHERE id = ?', [$plotId]);
    if (!$plot) return [false, 'No such garden.'];
    $owner = q_one('SELECT * FROM users WHERE id = ?', [$plot['user_id']]);
    require_once __DIR__ . '/yard.php';
    if (!$owner || !garden_visible($plot, $u)) return [false, 'You can’t visit that garden.'];
    if (($why = social169_water_block($u, $owner)) !== '') return [false, $why];
    $ownerId = (int)$owner['id'];
    [, $tiles, $plants] = load_plot($ownerId, true, $plotId);
    $thirsty = social169_thirsty($tiles, $plants);
    if (!$thirsty) return [false, 'Nothing thirsty here.'];
    $day = hollow_date('Y-m-d');
    $cap = max(1, (int)setting('social169_water_gardens'));
    $cost = max(0, (int)setting('social169_water_energy'));
    $watered = 0;
    db()->beginTransaction();
    try {
        q('UPDATE users SET id = id WHERE id = ?', [$me]);   // lock the helper's row: two tabs can't both pass the daily cap
        if (social169_water_used($me) >= $cap) { db()->rollBack(); return [false, 'You’ve helped in ' . $cap . ' gardens today. Tomorrow!']; }
        if (q_val('SELECT 1 FROM garden_waterings WHERE plot_id = ? AND helper_id = ? AND day = ?', [$plotId, $me, $day])) { db()->rollBack(); return [false, 'You’ve watered here today.']; }
        if ($cost > 0 && !spend_energy($me, $cost)) { db()->rollBack(); return [false, 'Too tired. Rest a little first.']; }
        foreach ($thirsty as $t) {
            // a plain conditional write: only if nobody watered that square in between
            save_growth($t);
            $n = q('UPDATE plot_tiles SET last_watered = ?, growth_updated_at = ?, moisture = ? WHERE id = ? AND (last_watered IS NULL OR last_watered = ?)',
                [now(), now(), $t['method'] === 'notill' ? min(100, max((int)$t['moisture'], 20) + 10) : min(60, (int)$t['moisture'] + 4), $t['id'], $t['last_watered']])->rowCount();
            $watered += $n;
        }
        if ($watered < 1) { db()->rollBack(); return [false, 'Nothing thirsty here.']; }
        db_insert('garden_waterings', ['plot_id' => $plotId, 'helper_id' => $me, 'day' => $day, 'squares' => $watered, 'created_at' => now()]);
        require_once __DIR__ . '/mentors120.php';
        $twin = mentors120_same_origin($me, $ownerId);   // v1.6.9.1: anyone can help now; same sign-up IP still waters but earns nothing (alt farming)
        $pet = $twin ? 0 : max(0, (int)setting('social169_water_petals'));
        if ($pet > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$pet, $me]);
        db()->commit();
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();
        if ($e instanceof PDOException && str_contains($e->getMessage(), 'UNIQUE') || $e instanceof PDOException && (string)$e->getCode() === '23000') return [false, 'You’ve watered here today.'];
        throw $e;
    }
    $xp = $twin ? 0 : max(0, (int)setting('social169_water_xp'));
    if ($xp > 0) add_xp($me, $xp, 'water_friend');
    social169_notify_owner($ownerId, $plot, $day);   // v1.7.0: one rolled-up notice a day
    return [true, '💧 You water ' . $watered . ' square' . ($watered === 1 ? '' : 's') . ' for ' . gnome_name($owner) . '.'
        . ($pet > 0 ? ' +' . $pet . ' ' . setting('currency_name') : '') . ($xp > 0 ? ' +' . $xp . ' XP' : '')];
}

// ---------------- Guestbook counts (v1.7.0: from garden_stamps) ----------------

/** [stamp key => count] this week (7 Hollow days), the all-time total. */
function social169_counts(int $plotId): array
{
    $from = hollow_date('Y-m-d', time() - 6 * 86400);
    $week = [];
    foreach (q('SELECT stamp, COUNT(*) c FROM garden_stamps WHERE plot_id = ? AND day >= ? GROUP BY stamp', [$plotId, $from])->fetchAll() as $r) $week[$r['stamp']] = (int)$r['c'];
    arsort($week);
    return ['week' => $week, 'all' => (int)q_val('SELECT COUNT(*) FROM garden_stamps WHERE plot_id = ?', [$plotId])];
}

/** "🌻 12 · 👏 3 this week · 40 all time" (top four stamps this week) or '' when there is nothing yet. */
function social169_counts_line(int $plotId): string
{
    require_once __DIR__ . '/pals.php';
    $c = social169_counts($plotId);
    if ($c['all'] < 1) return '';
    $set = pal_stamp_set();
    $bits = [];
    foreach ($c['week'] as $k => $n) {
        if (!isset($set[$k]) || count($bits) >= 4) continue;
        $bits[] = $set[$k][0] . ' ' . $n;
    }
    return ($bits ? implode(' · ', $bits) . ' this week · ' : '') . number_format($c['all']) . ' all time';
}

/** A span for the garden header bars (visit.php and garden.php). */
function social169_garden_counts(int $plotId): string
{
    $l = social169_counts_line($plotId);
    return $l === '' ? '' : '<span title="Guestbook">' . e($l) . '</span>';
}

/**
 * One notice a day per garden: "🏡 Visitors today at <garden>: 3 stamps · 💧 watered by Bramble".
 * The first visitor makes it (the garden_react_notes row is claimed first, so two at once make one); later ones rewrite it while it is unread.
 * Stamps and friend watering both call this. The text is rebuilt from today's rows, so it is always right.
 */
function social169_notify_owner(int $ownerId, array $plot, string $day): void
{
    $plotId = (int)$plot['id'];
    $stamps = (int)q_val('SELECT COUNT(*) FROM garden_stamps WHERE plot_id = ? AND day = ?', [$plotId, $day]);
    $names = array_column(q('SELECT COALESCE(u.gnome_name, u.username) AS n FROM garden_waterings w JOIN users u ON u.id = w.helper_id WHERE w.plot_id = ? AND w.day = ? ORDER BY w.id LIMIT 4', [$plotId, $day])->fetchAll(), 'n');
    $bits = [];
    if ($stamps > 0) $bits[] = $stamps . ' stamp' . ($stamps === 1 ? '' : 's');
    if ($names) $bits[] = '💧 watered by ' . implode(', ', array_slice($names, 0, 3)) . (count($names) > 3 ? ' +more' : '');
    if (!$bits) return;
    $text = mb_substr('🏡 Visitors today at ' . ($plot['garden_name'] ?: 'your garden') . ': ' . implode(' · ', $bits), 0, 300);
    try {
        db_insert('garden_react_notes', ['plot_id' => $plotId, 'day' => $day, 'notice_id' => 0]);
    } catch (PDOException $e) {
        $nid = (int)q_val('SELECT notice_id FROM garden_react_notes WHERE plot_id = ? AND day = ?', [$plotId, $day]);
        if ($nid > 0) q('UPDATE notices SET text = ? WHERE id = ? AND user_id = ? AND seen = 0', [$text, $nid, $ownerId]);
        return;
    }
    $nid = db_insert('notices', ['user_id' => $ownerId, 'text' => $text, 'created_at' => now(), 'seen' => 0]);
    q('UPDATE garden_react_notes SET notice_id = ? WHERE plot_id = ? AND day = ?', [$nid, $plotId, $day]);
}
