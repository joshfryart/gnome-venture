<?php
declare(strict_types=1);

/**
 * v2.3.5 Health that stays with the gnome. Before, every adventure (road walk, off-road explore, delve, lair) started at full health because health lived
 * on the expedition. Now users.hp is the gnome's health (NULL = full), carried into the next adventure; it comes back by:
 *   - 1 a minute while the gnome stands in a town (village, market, hub, haven) and is not adventuring (users.hp_at is when the clock last ran; NULL = not running),
 *   - resting at a haven (half) or staying the night (full), the rest-stop inn and baths (half, soaks and baths full),
 *   - a Healing Potion or a home-cooked snack used from My Gnome, a level up (full), and the quiet-step heal on the road (unchanged).
 * A knock-out wakes the gnome at half. Treks keep their own party health. Switch off with the setting hp_persist (0 = the old full-health starts).
 * The expedition row still holds the health of the adventure in progress; save_exp() copies it to the gnome.
 */

const HP_TOWN_KINDS = ['village', 'market', 'hub', 'haven'];

/** Admin settings, merged into settings_schema(). */
function hp_settings(): array
{
    return [
        'hp_persist' => ['label' => 'Health: stays with the gnome between adventures (off = every adventure starts at full health)', 'type' => 'bool', 'default' => '1'],
        'hp_regen_per_minute' => ['label' => 'Health: healed a minute while in a town and not adventuring (0 = none)', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 20],
        'hp_ko_percent' => ['label' => 'Health: percent of max health a knocked-out gnome wakes up with', 'type' => 'int', 'default' => '50', 'min' => 1, 'max' => 100],
        'hp_rest_percent' => ['label' => 'Health: percent healed by resting (haven fire, rest-stop inn)', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 100],
        'hp_potion_percent' => ['label' => 'Health: percent of max healed by a Healing Potion', 'type' => 'int', 'default' => '50', 'min' => 1, 'max' => 100],
    ];
}

function hp_on(): bool
{
    return setting('hp_persist') !== '0';
}

function hp_regen_rate(): int
{
    $v = setting('hp_regen_per_minute');
    return $v === '' ? 1 : max(0, min(20, (int)$v));
}

function hp_pct(string $name, int $default): int
{
    $v = setting($name);
    return $v === '' ? $default : max(0, min(100, (int)$v));
}

/** Max health of the gnome now. */
function hp_max(array $u): int
{
    require_once __DIR__ . '/adventure.php';
    return (int)gnome_combat($u, true)['max_hp'];
}

/** Does the health clock run? In a town, and not adventuring. */
function hp_clock_runs(int $uid, int $locId): bool
{
    if (hp_regen_rate() <= 0 || active_expedition($uid)) return false;
    return in_array((string)q_val('SELECT kind FROM locations WHERE id = ?', [$locId]), HP_TOWN_KINDS, true);
}

/** Store health: full = NULL. $running = the clock starts now (the adventure is over), else it is stopped. */
function hp_store(int $uid, int $hp, int $max, bool $running): void
{
    if ($hp >= $max) { q('UPDATE users SET hp = NULL, hp_at = NULL WHERE id = ?', [$uid]); return; }
    q('UPDATE users SET hp = ?, hp_at = ? WHERE id = ?', [max(1, $hp), $running ? now() : null, $uid]);
}

/** [health now, max]: the stored health plus what has come back in town since the clock was last read. $max may be passed when the caller has it. */
function hp_get(array $u, ?int $max = null): array
{
    $uid = (int)$u['id'];
    $max ??= hp_max($u);
    if (!hp_on()) return [$max, $max];
    $r = q_one('SELECT hp, hp_at, location_id FROM users WHERE id = ?', [$uid]);
    if (!$r) return [$max, $max];
    $hp = $r['hp'] === null ? $max : min($max, max(1, (int)$r['hp']));
    if ($hp >= $max) {
        if ($r['hp'] !== null) q('UPDATE users SET hp = NULL, hp_at = NULL WHERE id = ?', [$uid]);
        return [$max, $max];
    }
    if (!hp_clock_runs($uid, (int)$r['location_id'])) {
        if ($r['hp_at'] !== null) q('UPDATE users SET hp_at = NULL WHERE id = ?', [$uid]);
        return [$hp, $max];
    }
    if ($r['hp_at'] === null) { q('UPDATE users SET hp_at = ? WHERE id = ?', [now(), $uid]); return [$hp, $max]; }
    $mins = intdiv(time() - ts($r['hp_at']), 60);
    if ($mins > 0) {
        $hp = min($max, $hp + $mins * hp_regen_rate());
        if ($hp >= $max) q('UPDATE users SET hp = NULL, hp_at = NULL WHERE id = ?', [$uid]);
        else q('UPDATE users SET hp = ?, hp_at = ? WHERE id = ?', [$hp, gmdate('Y-m-d H:i:s', ts($r['hp_at']) + $mins * 60), $uid]);
    }
    return [$hp, $max];
}

/** The health an adventure starts with (never above its max). Old rule when the setting is off. */
function hp_start(array $u, int $max): int
{
    if (!hp_on()) return $max;
    return min($max, hp_get($u, $max)[0]);
}

/** A level up heals fully (also the adventure in progress, see save_exp). */
function hp_full(int $uid): void
{
    if (!hp_on()) return;
    q('UPDATE users SET hp = NULL, hp_at = NULL WHERE id = ?', [$uid]);
    $GLOBALS['gv_hp_full'] = true;
}

/** Heal $pct percent of max (100 = full). Returns the health gained. Also the adventure in progress, if there is one. */
function hp_heal_pct(array $u, int $pct): int
{
    if (!hp_on() || $pct <= 0) return 0;
    $uid = (int)$u['id'];
    [$hp, $max] = hp_get($u);
    if ($hp >= $max) return 0;
    $new = min($max, $hp + max(1, (int)ceil($max * $pct / 100)));
    $loc = (int)q_val('SELECT location_id FROM users WHERE id = ?', [$uid]);
    hp_store($uid, $new, $max, hp_clock_runs($uid, $loc));
    q("UPDATE expeditions SET hp = CASE WHEN hp + ? > max_hp THEN max_hp ELSE hp + ? END WHERE user_id = ? AND status = 'active' AND hp > 0", [$new - $hp, $new - $hp, $uid]);
    return $new - $hp;
}

/** Heal a flat amount (a snack). Returns the health gained. */
function hp_heal_flat(array $u, int $n): int
{
    if (!hp_on() || $n <= 0) return 0;
    [$hp, $max] = hp_get($u);
    return hp_heal_pct($u, (int)ceil(100 * min($n, $max - $hp) / max(1, $max)));
}

/** Use a Healing Potion or a snack from My Gnome (not while adventuring). Returns [ok, message]. */
function hp_use(array $u, string $what, int $itemId): array
{
    $uid = (int)$u['id'];
    if (!hp_on()) return [false, 'Nothing to heal.'];
    if (active_expedition($uid)) return [false, 'Heal up in town or between adventures. You are out on an adventure right now.'];
    [$hp, $max] = hp_get($u);
    if ($hp >= $max) return [false, 'You’re not hurt.'];
    require_once __DIR__ . '/adventure.php';
    require_once __DIR__ . '/pal_jobs.php';
    if ($what === 'potion') {   // a Healing Potion or a stronger tier (alchemy.php ALCHEMY_HEAL)
        foreach (array_keys(ALCHEMY_HEAL) as $slug) {
            $id = alchemy_item_id($slug);
            if (!$id || $itemId !== $id) continue;
            $name = (string)q_val('SELECT name FROM items WHERE id = ?', [$id]);
            if (!give_item($uid, $id, -1)) return [false, 'You have no ' . $name . '.'];
            $n = hp_heal_pct($u, alchemy_gnome_pct($slug));
            return [true, '🧪 You drink a ' . $name . ': +' . $n . ' health.'];
        }
        return [false, 'You have no Healing Potion.'];
    }
    foreach (fight_snacks($u) as $s) {
        if ($s['id'] !== $itemId) continue;
        if (!give_item($uid, $itemId, -1)) return [false, 'You have none left.'];
        $n = hp_heal_flat($u, (int)$s['heal']);
        return [true, '🎒 You eat the ' . $s['name'] . ': +' . $n . ' health.'];
    }
    return [false, 'That isn’t something you can use to heal right now.'];
}

/** The Health box of My Gnome: bar, how it comes back, and the potion and snacks. */
function hp_card_html(array $u): string
{
    if (!hp_on()) return '';
    $uid = (int)$u['id'];
    [$hp, $max] = hp_get($u);
    $out = active_expedition($uid) !== null;
    $pct = $max > 0 ? max(0, min(100, (int)round(100 * $hp / $max))) : 0;
    $h = '<section class="box hpcard" aria-label="Health"><div class="hphead"><b>❤️ Health</b> <span class="hpnum">' . $hp . '/' . $max . '</span></div>'
        . '<div class="hpbar" role="progressbar" aria-valuemin="0" aria-valuemax="' . $max . '" aria-valuenow="' . $hp . '"><i style="width:' . $pct . '%"></i></div>';
    if ($hp >= $max) {
        $h .= '<p class="help">You’re in good shape.</p>';
    } else {
        $rate = hp_regen_rate();
        $h .= '<p class="help">' . ($out ? 'You’re out on an adventure: heal up when you’re back. '
            : ($rate > 0 ? 'You heal ' . $rate . ' a minute while you’re in a town and not adventuring. ' : '')) . 'Resting at a haven, an inn or a hot spring heals more, and so do snacks and Healing Potions.</p>';
        if (!$out) {
            require_once __DIR__ . '/adventure.php';
            require_once __DIR__ . '/pal_jobs.php';
            $btn = fn(string $what, int $id, string $label) => '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="heal"><input type="hidden" name="what" value="' . $what . '"><input type="hidden" name="item" value="' . $id . '"><button class="btn small">' . $label . '</button></form> ';
            $b = '';
            foreach (alchemy_heals($uid) as $hv) $b .= $btn('potion', $hv['id'], '🧪 ' . e($hv['name']) . ' ×' . $hv['qty'] . ' (+' . $hv['pct'] . '%)');
            foreach (fight_snacks($u) as $s) $b .= $btn('snack', $s['id'], '🎒 ' . e($s['name']) . ' ×' . $s['qty'] . ' (+' . $s['heal'] . ')');
            if ($b !== '') $h .= '<div class="hpuse">' . $b . '</div>';
        }
    }
    return $h . '</section>';
}
