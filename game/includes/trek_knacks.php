<?php
// v2.0.20 Trek Knacks: skill slots that SWAP one strength for another (sidegrades, never a pure add), so the boss maths stay as tuned.
// A member gets a slot at every even trek level (Lv2 minor, Lv4 major, ... max 11), kept per chapter run in st.kn[crew key] = a positional list of knack ids, '' = empty.
// A knack is stat-only and is applied in trek_party_stats() after the trek-level bonus. With no st.kn nothing here touches anything (stats byte-identical, no RNG).
// Filling an EMPTY slot works anywhere but mid-fight; changing or clearing a FILLED slot only at a camp tile or in the interlude. Free: nothing to pay, nothing to exploit.

const TREK_KNACK_MAX = 11;   // slots: one at every even trek level, Lv2 to Lv22

/**
 * id => [name, icon, health %, to hit, damage, armour, one-line text, pool]. Every knack gives and takes (a sidegrade). Pool: slot 1, 3, 5... (Lv2, 6, 10...)
 * take a MINOR knack, slot 2, 4, 6... (Lv4, 8, 12...) a MAJOR one. A knack can be used once per member.
 * Worth in the Chapter II boss sims (tests/trek_knacks.php): to hit +1 ~ damage +1 ~ health 5%; armour is worth very little there, so it is the
 * cheap side of several trades. A win rate near 90% rises slowly and falls fast, and a health cost hurts the squishy parties most, so health is rarely the price.
 */
const TREK_KNACKS = [
    'sharp'    => ['Sharp', '🎯', -7, 1, 0, 0, '+1 to hit, -7% health', 'minor'],
    'stout'    => ['Stout', '🌰', 5, -1, 0, 0, '+5% health, -1 to hit', 'minor'],
    'rough'    => ['Rough', '🪨', 0, -1, 1, 0, '+1 damage, -1 to hit', 'minor'],
    'lunge'    => ['Lunge', '🗡️', 0, 1, -1, 0, '+1 to hit, -1 damage', 'minor'],
    'bold'     => ['Bold', '💥', 0, 0, 1, -2, '+1 damage, -2 armour', 'minor'],
    'hearty'   => ['Hearty', '🍲', 3, 0, 0, -1, '+3% health, -1 armour', 'minor'],
    'heavy'    => ['Heavy', '🔨', 0, -1, 2, -2, '+2 damage, -1 to hit, -2 armour', 'major'],
    'deadeye'  => ['Deadeye', '👁️', 0, 2, -2, 0, '+2 to hit, -2 damage', 'major'],
    'sturdy'   => ['Sturdy', '🛡️', 8, -1, 0, 0, '+8% health, -1 to hit', 'major'],
    'reckless' => ['Reckless', '🔥', 0, -1, 2, -1, '+2 damage, -1 to hit, -1 armour', 'major'],
    'steady'   => ['Steady', '🧱', 6, 0, 0, -2, '+6% health, -2 armour', 'major'],
    'bulwark'  => ['Bulwark', '🏰', 0, -1, 0, 6, '+6 armour, -1 to hit', 'major'],
];

/** Slots a trek level has earned: one per even level, 0 to 11. */
function trek_knack_slots(int $tl): int
{
    return max(0, min(TREK_KNACK_MAX, intdiv($tl, 2)));
}

/** The pool of slot $i (0-based): minor for the 1st, 3rd...; major for the 2nd, 4th... */
function trek_knack_pool(int $i): string
{
    return $i % 2 === 0 ? 'minor' : 'major';
}

/** The trek level that opens slot $i (0-based). */
function trek_knack_slot_level(int $i): int
{
    return 2 * ($i + 1);
}

/** Clean a raw list: known ids only, each once, each in the pool of its place (anything else becomes an empty slot), at most 11 places, no trailing empties. */
function trek_knack_clean($raw): array
{
    $out = []; $used = [];
    foreach (array_slice(array_values(is_array($raw) ? $raw : []), 0, TREK_KNACK_MAX) as $i => $id) {
        $good = is_string($id) && isset(TREK_KNACKS[$id]) && TREK_KNACKS[$id][7] === trek_knack_pool($i) && !isset($used[$id]);
        if ($good) $used[$id] = 1;
        $out[] = $good ? $id : '';
    }
    while ($out && end($out) === '') array_pop($out);
    return $out;
}

/** One member's slots now: a list of exactly the earned number of places, each an id or ''. */
function trek_knack_get(array $run, string $key): array
{
    $n = trek_knack_slots(trek_tl_get($run, $key)[0]);
    $have = trek_knack_clean($run['st']['kn'][$key] ?? []);
    $out = [];
    for ($i = 0; $i < $n; $i++) $out[] = $have[$i] ?? '';
    return $out;
}

/** The stat changes of a list of knack ids: ['hp' => percent, 'atk', 'dmg', 'ac']. */
function trek_knack_sum(array $ids): array
{
    $s = ['hp' => 0, 'atk' => 0, 'dmg' => 0, 'ac' => 0];
    foreach ($ids as $id) {
        if (!isset(TREK_KNACKS[$id])) continue;
        $k = TREK_KNACKS[$id];
        $s['hp'] += $k[2]; $s['atk'] += $k[3]; $s['dmg'] += $k[4]; $s['ac'] += $k[5];
    }
    return $s;
}

/** Called from trek_party_stats() after the trek-level bonus. Does nothing at all when the member has no knack. */
function trek_knack_apply(array &$gc, array $run, string $key): void
{
    if (empty($run['st']['kn'][$key])) return;
    $ids = array_filter(trek_knack_get($run, $key), fn($i) => $i !== '');
    if (!$ids) return;
    $s = trek_knack_sum($ids);
    $hp = $s['hp'] !== 0 ? (int)round((int)$gc['max_hp'] * $s['hp'] / 100) : 0;
    $hp = max($hp, 1 - (int)$gc['max_hp']);
    $gc['max_hp'] += $hp;
    $gc['atk'] += $s['atk'];
    $gc['dmg_bonus'] += $s['dmg'];
    $gc['ac'] += $s['ac'];
    $gc['kn_hp'] = $hp;   // so the Party tab can show the trek-level bonus against the right base health
}

/** Who may get knacks in this run: the gnome and every recruited trailmate. */
function trek_knack_crew_ok(array $run, string $key): bool
{
    return $key === 'gnome' || in_array($key, trek_recruits((int)$run['id']), true);
}

/** May a FILLED slot be changed right now? Camp tile or interlude, never mid-fight. */
function trek_knack_can_change(array $run): bool
{
    return empty($run['fi']) && trek_at_camp($run);
}

/**
 * The POST action. Fields: who (crew key), k0..k10 (a knack id or empty). A field that is missing keeps that slot as it is.
 * Everything is checked first; if any slot breaks a rule nothing is saved. [ok, message]
 */
function trek_act_knack(array &$run, array $u, string $who, array $post): array
{
    if (!trek_knack_crew_ok($run, $who)) return [false, 'Pick someone in your party.'];
    $slots = trek_knack_get($run, $who);
    if (!$slots) return [false, 'No knack slot yet. The first comes at trek Lv ' . trek_knack_slot_level(0) . '.'];
    $new = $slots;
    foreach ($post as $i => $v) {
        if (!is_int($i) || $i < 0 || $i >= TREK_KNACK_MAX) return [false, 'No such slot.'];
        if (!is_string($v) || ($v !== '' && !isset(TREK_KNACKS[$v]))) return [false, 'Unknown knack.'];
        if ($i >= count($slots)) { if ($v !== '') return [false, 'That slot is not earned yet.']; continue; }
        if ($v !== '' && TREK_KNACKS[$v][7] !== trek_knack_pool($i)) return [false, 'That knack does not fit that slot.'];
        $new[$i] = $v;
    }
    $filled = array_filter($new, fn($x) => $x !== '');
    if (count($filled) !== count(array_unique($filled))) return [false, 'Each knack only once.'];
    if ($new === $slots) return [true, ''];
    foreach ($new as $i => $v) {
        if ($v === $slots[$i]) continue;
        if (!empty($run['fi'])) return [false, 'Not during a fight.'];
        if ($slots[$i] !== '' && !trek_knack_can_change($run)) return [false, 'Change a filled slot at a camp.'];
    }
    $clean = trek_knack_clean($new);
    if ($clean) $run['st']['kn'][$who] = $clean;
    else unset($run['st']['kn'][$who]);
    if (empty($run['st']['kn'])) unset($run['st']['kn']);
    trek_party_stats($run, $u);   // health that no longer fits the new maximum is cut back (a bigger maximum does not heal)
    return [true, 'Knacks saved.'];
}

/** v2.0.20: the knack selects k0..k10 that were sent: index => string. A k<n> with n above 10, or a non-string value, is passed on so the action refuses it. */
function trek_post_knacks(): array
{
    $o = [];
    foreach ($_POST as $k => $v) {
        if (!is_string($k) || !preg_match('/^k(\d{1,3})$/', $k, $m)) continue;
        $o[(int)$m[1]] = is_string($v) ? $v : '*';
    }
    ksort($o);
    return $o;
}

/** The select options' text for one knack. */
function trek_knack_label(string $id): string
{
    $k = TREK_KNACKS[$id] ?? null;
    return $k ? $k[1] . ' ' . $k[0] . ': ' . str_replace(['damage', 'to hit', 'health', 'armour'], ['dmg', 'hit', 'HP', 'AC'], $k[6]) : '';   // short, so the select text fits a phone
}

/** The Party tab block for one member ($key = crew key): a row per earned slot ("Lv2 minor"...), then the next one locked. Filled rows are locked (disabled) away from camp; nothing fills mid-fight. */
function trek_knack_form_html(array $run, string $key): string
{
    $slots = trek_knack_get($run, $key);
    $h = '<form method="post" class="pknform">' . csrf_field() . '<input type="hidden" name="do" value="knack"><input type="hidden" name="t" value="party"><input type="hidden" name="who" value="' . e($key) . '">'
        . '<b class="ptachead">Knacks</b>';
    if (!$slots) return $h . '<p class="help pknnone">First slot at trek Lv ' . trek_knack_slot_level(0) . '. A knack gives one thing and takes another.</p></form>';
    $fight = !empty($run['fi']);
    $camp = trek_knack_can_change($run);
    $any = false;
    $h .= '<div class="pkngrid">';
    foreach ($slots as $i => $cur) {
        $pool = trek_knack_pool($i);
        $locked = $fight || ($cur !== '' && !$camp);
        if (!$locked) $any = true;
        $h .= '<label><span>Lv' . trek_knack_slot_level($i) . ' ' . $pool . '</span><select name="k' . $i . '"' . ($locked ? ' disabled' : '') . '><option value="">(empty)</option>';
        foreach (TREK_KNACKS as $id => $k) {
            if ($k[7] !== $pool) continue;
            $usedElsewhere = in_array($id, $slots, true) && $id !== $cur;
            $h .= '<option value="' . e($id) . '"' . ($id === $cur ? ' selected' : '') . '>' . e(trek_knack_label($id)) . ($usedElsewhere ? ' (used)' : '') . '</option>';
        }
        $h .= '</select></label>';
    }
    if (count($slots) < TREK_KNACK_MAX) $h .= '<p class="pknlock">Lv' . trek_knack_slot_level(count($slots)) . ' ' . trek_knack_pool(count($slots)) . ' (locked)</p>';
    $h .= '</div>';
    if ($any) $h .= '<button class="btn small">Save knacks</button>';
    if (!$camp && array_filter($slots, fn($x) => $x !== '')) $h .= '<p class="help pknnone">Change a filled slot at a camp.</p>';
    return $h . '</form>';
}
