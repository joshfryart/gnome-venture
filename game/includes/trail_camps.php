<?php
declare(strict_types=1);

/**
 * 2.7.00 CAMP SPOTS: every Trail route has one camp tile on one stretch (includes/data/trail_camps.json, made by tools/gen_trail_camps.py; the game draws the tile,
 * the ground pictures are untouched). Stand on it and the camp card offers:
 *   Sleep         free and safe: a full night (game_sleep), no camping gear needed
 *   Nap           free and safe: a nap (game_nap, 2 game hours, +40% energy by default)
 *   Wait 10-60    wait a while: +1 energy for every 2 minutes (up to your maximum); a fight can find you:
 *                 over 30 minutes 25%, 30 minutes or less 5%; halved on a toll road whose toll was paid. No daily limit.
 */

const TC_WAITS = [10, 20, 30, 45, 60];     // minutes you can wait
const TC_WAIT_FIGHT_LONG = 25;             // % chance of a fight when you wait over 30 minutes
const TC_WAIT_FIGHT_SHORT = 5;             // % when you wait 30 minutes or less
const TC_WAIT_MIN_PER_ENERGY = 2;          // 1 energy for every 2 minutes

/** [route id => ['sec' => stretch as drawn (0-based), 'x' => int, 'y' => int]] */
function tc_all(): array
{
    static $c = null;
    if ($c !== null) return $c;
    $j = json_decode((string)@file_get_contents(__DIR__ . '/data/trail_camps.json'), true);
    $c = [];
    foreach (is_array($j) && is_array($j['camps'] ?? null) ? $j['camps'] : [] as $id => $r) {
        if (ctype_digit((string)$id) && isset($r['sec'], $r['x'], $r['y'])) $c[(int)$id] = ['sec' => (int)$r['sec'], 'x' => (int)$r['x'], 'y' => (int)$r['y']];
    }
    return $c;
}

/** The camp tile of this section of the map ([x, y]) or null. $art = the authored section ('route' and 'sec' are the route and the stretch as drawn). */
function tc_spot(array $art): ?array
{
    if (!isset($art['route'], $art['sec'])) return null;
    $c = tc_all()[(int)$art['route']] ?? null;
    return $c && $c['sec'] === (int)$art['sec'] ? [$c['x'], $c['y']] : null;
}

/** Is the gnome standing on the camp tile of this scene (and free to use it)? */
function tc_here(array $sc): bool
{
    $spot = tc_spot((array)($sc['map']['art'] ?? []));
    return $spot !== null && $spot[0] === (int)$sc['x'] && $spot[1] === (int)$sc['y'] && ($sc['st']['phase'] ?? '') === 'section';
}

/** Chance (percent) that a fight finds you while you wait $minutes. $tollPaid halves it. */
function tc_wait_chance(int $minutes, bool $tollPaid = false): float
{
    $p = $minutes > 30 ? TC_WAIT_FIGHT_LONG : TC_WAIT_FIGHT_SHORT;
    return $tollPaid ? $p * 0.5 : (float)$p;
}

/** Energy a wait of $minutes gives (before the cap). */
function tc_wait_energy(int $minutes): int { return intdiv($minutes, TC_WAIT_MIN_PER_ENERGY); }

/** 2.7.06: take the walk's health from the database into $exp (a sleep, nap or wait healed it there; the caller saves $exp afterwards). */
function tc_refresh_hp(array &$exp): void
{
    $hp = q_val('SELECT hp FROM expeditions WHERE id = ?', [(int)$exp['id']]);
    if ($hp !== null && $hp !== false) $exp['hp'] = (int)$hp;
}

/**
 * Use the camp: $mode 'sleep' | 'nap' | 'wait' ($minutes only for wait). [ok, message]. $roll(float $percent): bool is the dice (tests pass their own).
 * Changes the expedition (a fight may start); the caller saves it as for every Trail action.
 */
function trail_camp(array $u, array &$exp, string $mode, int $minutes = 0, ?callable $roll = null): array
{
    $sc = trail_scene($exp);
    if (!$sc) return [false, 'Not on a tile walk.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    if (!tc_here($sc)) return [false, 'Walk to the camp spot first.'];
    $uid = (int)$u['id'];
    if (!gclock_on()) return [false, 'Camping needs the game clock.'];
    if ($mode === 'sleep') {
        if (!game_sleep($uid)) return [false, 'Something stirred. Try again.'];
        tc_refresh_hp($exp);   // 2.7.06: the sleep healed the walk's health in the database; the walk in memory must take it, or saving it puts the old health back
        return [true, '🏕️ You sleep at the camp under the stars. A new day: energy full.'];
    }
    if ($mode === 'nap') {
        if (!game_nap($uid)) return [false, 'Something stirred. Try again.'];
        tc_refresh_hp($exp);
        return [true, '🏕️ You nap at the camp and feel a little better.'];
    }
    if ($mode !== 'wait' || !in_array($minutes, TC_WAITS, true)) return [false, 'Pick how long to wait.'];
    if (!game_spend($uid, $minutes)) return [false, 'You cannot wait that long now.'];
    $max = max_energy(q_one('SELECT * FROM users WHERE id = ?', [$uid]) ?: $u);
    $gain = tc_wait_energy($minutes);
    $cur = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
    if ($cur < $max) q('UPDATE users SET energy = ? WHERE id = ? AND energy = ?', [min($max, $cur + $gain), $uid, $cur]);   // portable (no LEAST on SQLite)
    $healed = 0;
    if ($max > 0 && $gain > 0) { $healed = gclock_heal(q_one('SELECT * FROM users WHERE id = ?', [$uid]) ?: $u, (int)ceil(100 * $gain / $max)); tc_refresh_hp($exp); }   // 2.7.06: resting at a camp heals as much (of your health) as it restores (of your energy)
    $msg = '🏕️ You wait ' . $minutes . ' minutes at the camp and catch your breath (+' . $gain . ' energy' . ($healed > 0 ? ', +' . $healed . ' health' : '') . ').';
    require_once __DIR__ . '/road_kinds.php';
    $roll ??= fn(float $pct): bool => random_int(1, 1000) <= (int)round($pct * 10);
    if ($roll(tc_wait_chance($minutes, rk_toll_paid((array)$sc['st'])))) {
        require_once __DIR__ . '/trail_tiles.php';
        trail_token_event($u, $exp, 'R');   // a random fight: it found you at the camp
        $msg .= ' Something finds you!';
    }
    return [true, $msg];
}

/** The camp card (HTML) for the strip: shown while the gnome stands on the camp tile with nothing else to deal with. */
function tc_card_html(array $u, array $exp, array $sc): string
{
    if (!tc_here($sc) || !empty($exp['encounter'])) return '';
    $o = '<div class="trailui campcard" role="group" aria-label="Camp"><p><b>🏕️ A camp spot.</b> Sleep and nap are free and safe. Waiting gives 1 energy for every 2 minutes, and something may find you.</p>';
    $o .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="trail_camp"><label class="campsel">What to do <select name="mode_min">'
        . '<option value="sleep">Sleep (a full night)</option><option value="nap">Nap (2 hours)</option>';
    foreach (TC_WAITS as $m) $o .= '<option value="wait:' . $m . '">Wait ' . $m . ' minutes (+' . tc_wait_energy($m) . ' energy, ' . (int)tc_wait_chance($m) . '% a fight)</option>';
    return $o . '</select></label> <button class="btn primary">Rest</button></form></div>';
}

/** Split the form value 'sleep' | 'nap' | 'wait:30' into [mode, minutes]. */
function tc_parse(string $v): array
{
    if (preg_match('/^wait:(\d+)$/', $v, $m)) return ['wait', (int)$m[1]];
    return [in_array($v, ['sleep', 'nap'], true) ? $v : '', 0];
}
