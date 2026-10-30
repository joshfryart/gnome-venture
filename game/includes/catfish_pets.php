<?php
declare(strict_types=1);
/**
 * Cat Fish pet shops (2.2.x, unreleased): 11 shops in regions 4 and up, 55 Petal-bought room things, 8 scene slots. Design: claude/plan-catfish-petshops.md.
 * Data (no logic) lives in data/catfish_pets.php. Every name here starts catfish_pet_ or petshop_. Loaded by includes/catfish.php (the Kibble, away, rare fish, Catnip, Cat Show and play hooks call
 * catfish_pet_bonus()), so everything below runs only when a function is called: nothing happens on load but the data constants.
 *
 * Rules (plan section 4):
 *  - Petals only, spent in petshop_buy(). Nothing here ever pays Petals out (this file has no Petal-paying call at all; tests/catfish.sh greps for it).
 *  - Items live in their own table catfish_items (never user_items), so they cannot be sold, traded or gifted. The cooldown belongs to the owned item (last_used), not the slot.
 *  - No cap on the summed Kibble %; the other bonuses are capped by admin settings. Active use: 4 a Hollow day, pops at most 60 minutes of Kibble a day, at most 1 Yarn per ISO week.
 *  - An active item must have been slotted for an hour before use. A hint only returns text: it never writes cat_book (book12 and book_half pay Petals from those rows).
 *  - Meta keys in catfish_state.meta: slots (slot no => item key), slotn (list of slot keys opened with Yarn), pa {day, n, kmin} (uses and pop minutes today), py {week, n} (Yarn from items this week),
 *    phint (item key => last hint text), rain (unix time the window rain stops).
 */
require_once __DIR__ . '/data/catfish_pets.php';

const CATFISH_PET_HOUR = 3600;

/** An admin setting as an int, or $default when the setting is unset or the settings layer is a stub (balance sim, unit tests). */
function catfish_pet_cfg(string $name, int $default): int
{
    $v = function_exists('setting') ? setting($name) : '';
    return $v !== '' ? max(0, (int)$v) : $default;
}

/** Slot definition by number (1..8), or null. */
function catfish_pet_slot_def(int $no): ?array
{
    foreach (CATFISH_PET_SLOTS as $s) if ($s['no'] === $no) return $s;
    return null;
}

/** Petal price of an item (the data price scaled by the admin setting catfish_pet_price_pct, default 100). */
function catfish_pet_price(array $item): int
{
    return max(1, (int)round($item['price'] * max(1, catfish_pet_cfg('catfish_pet_price_pct', 100)) / 100));
}

/** The gnome's owned items: item key => ['got_at', 'last_used', 'slotted_at']. Tolerates a missing table (nothing owned). */
function catfish_pet_owned(int $uid): array
{
    $out = [];
    try {
        foreach (q('SELECT item_key, got_at, last_used, slotted_at FROM catfish_items WHERE user_id = ?', [$uid])->fetchAll() as $r) {
            if (isset(CATFISH_PET_ITEMS[$r['item_key']])) $out[(string)$r['item_key']] = ['got_at' => (string)$r['got_at'], 'last_used' => (int)$r['last_used'], 'slotted_at' => (int)$r['slotted_at']];
        }
    } catch (Throwable $e) {}
    return $out;
}

/** The slot map of a meta array: slot no => item key, only for known slots and known items. */
function catfish_pet_slotmap(array $meta): array
{
    $out = [];
    foreach ((array)($meta['slots'] ?? []) as $no => $key) {
        if (catfish_pet_slot_def((int)$no) !== null && isset(CATFISH_PET_ITEMS[(string)$key])) $out[(int)$no] = (string)$key;
    }
    ksort($out);
    return $out;
}

/** In how many different regional pet shops has the gnome bought something? (Derived from the owned items, so it never goes down.) */
function catfish_pet_shops_bought(array $owned): int
{
    $s = [];
    foreach (array_keys($owned) as $k) $s[CATFISH_PET_ITEMS[$k]['shop']] = 1;
    return count($s);
}

/** Is slot $no open for this gnome? [open, reason when locked, Yarn price when it can be opened with Yarn (0 otherwise)]. */
function catfish_pet_slot_open(array $slot, array $meta, array $owned): array
{
    $u = $slot['unlock'];
    if (!empty($u['free'])) return [true, '', 0];
    if (isset($u['after_shops'])) {
        $have = catfish_pet_shops_bought($owned); $need = (int)$u['after_shops'];
        return [$have >= $need, $have >= $need ? '' : 'Opens after you buy something in ' . $need . ' different pet shop' . ($need === 1 ? '' : 's') . ' (' . $have . ' so far).', 0];
    }
    if (isset($u['yarn'])) {
        $open = in_array($slot['key'], (array)($meta['slotn'] ?? []), true);
        return [$open, $open ? '' : 'Opens for ' . (int)$u['yarn'] . ' Yarn.', (int)$u['yarn']];
    }
    return [false, 'Locked.', 0];
}

/** The slots that count right now: slot no => item key, for open slots holding an owned item that fits. */
function catfish_pet_active_slots(array $meta, array $owned): array
{
    $out = [];
    foreach (catfish_pet_slotmap($meta) as $no => $key) {
        $slot = catfish_pet_slot_def($no); $item = CATFISH_PET_ITEMS[$key];
        if (!isset($owned[$key]) || !in_array($slot['key'], $item['fit'], true) || !catfish_pet_slot_open($slot, $meta, $owned)[0]) continue;
        $out[$no] = $key;
    }
    return $out;
}

/**
 * Bonuses of the slotted passive items, capped (admin settings). Cached per request and gnome; pass $fresh after a slot change.
 * kibble_pct is NOT capped (Joshua): it is bounded by the slots and CATFISH_MAX_KPH. away_min, rare_pct and catnip_min are capped; show is a list for catfish_pet_show_bonus();
 * tap = ['n' => taps a day it counts for, 'mult' => factor] (1.5 for x1.5, 1.25 for +25%) or null; bird_x is 2 with a Weaver-bird Nest, else 1.
 */
function catfish_pet_bonus(int $uid, bool $fresh = false): array
{
    static $cache = [];
    if (!$fresh && isset($cache[$uid])) return $cache[$uid];
    $b = ['kibble_pct' => 0, 'away_min' => 0, 'rare_pct' => 0, 'catnip_min' => 0, 'show' => [], 'tap' => null, 'bird_x' => 1];
    try {
        $row = q_one('SELECT meta FROM catfish_state WHERE user_id = ?', [$uid]);
        $meta = $row ? json_decode((string)$row['meta'], true) : null;
        if (is_array($meta) && !empty($meta['slots'])) {
            $owned = catfish_pet_owned($uid);
            foreach (catfish_pet_active_slots($meta, $owned) as $key) {
                $it = CATFISH_PET_ITEMS[$key]; if ($it['kind'] !== 'P') continue;
                $fx = $it['effect'];
                $b['kibble_pct'] += (int)($fx['kibble_pct'] ?? 0);
                $b['away_min'] += (int)($fx['away_min'] ?? 0);
                $b['rare_pct'] += (int)($fx['rare_pct'] ?? 0);
                $b['catnip_min'] += (int)($fx['catnip_min'] ?? 0);
                if (isset($fx['show_plus'])) $b['show'][] = ['plus' => (int)$fx['show_plus'], 'if_trait' => $fx['if_trait'] ?? null];
                if (isset($fx['tap_mult'])) $b['tap'] = ['n' => (int)$fx['tap_n'], 'mult' => (float)$fx['tap_mult']];
                if (isset($fx['tap_pct'])) $b['tap'] = ['n' => (int)$fx['tap_n'], 'mult' => 1 + (int)$fx['tap_pct'] / 100];
                if (isset($fx['bird_x'])) $b['bird_x'] = max($b['bird_x'], (int)$fx['bird_x']);
            }
            $b['away_min'] = min($b['away_min'], catfish_pet_cfg('catfish_pet_cap_away', 30));
            $b['rare_pct'] = min($b['rare_pct'], catfish_pet_cfg('catfish_pet_cap_rare', 10));
            $b['catnip_min'] = min($b['catnip_min'], catfish_pet_cfg('catfish_pet_cap_catnip', 10));
        }
    } catch (Throwable $e) {}
    return $cache[$uid] = $b;
}

/** Cat Show points the slotted items add for this cat (capped at catfish_pet_cap_show, default 2). */
function catfish_pet_show_bonus(int $uid, array $cat): int
{
    $n = 0; $moods = [$cat['mood'] ?? '', $cat['mood2'] ?? ''];
    foreach (catfish_pet_bonus($uid)['show'] as $s) {
        if ($s['if_trait'] === null || in_array($s['if_trait'], $moods, true)) $n += $s['plus'];
    }
    return min($n, catfish_pet_cfg('catfish_pet_cap_show', 2));
}

/** One tap's Kibble after the rod charm (Toucan Feather Lure, Coffee-bean Rattle): $k = the tap's number in the Hollow day. $tap = catfish_pet_bonus()['tap']. */
function catfish_pet_tap_value(int $v, int $k, ?array $tap): int
{
    return ($tap !== null && $v > 0 && $k <= $tap['n']) ? max($v, (int)floor($v * $tap['mult'])) : $v;
}

// ---------- slots ----------

/**
 * Put owned item $itemKey in slot $no, or empty the slot with ''. The item must fit the slot and the slot must be open. One item sits in one slot: moving it empties its old slot,
 * and an item already in the target slot goes back to the shelf. Placing resets the item's slotted_at (the 1-hour rule); putting it where it already is does not. Free and repeatable.
 */
function catfish_pet_slot(int $uid, int $no, string $itemKey): array
{
    $slot = catfish_pet_slot_def($no);
    if ($slot === null) return [false, 'No such spot.'];
    if ($itemKey !== '' && !isset(CATFISH_PET_ITEMS[$itemKey])) return [false, 'No such thing.'];
    return catfish_locked($uid, function () use ($uid, $slot, $no, $itemKey) {
        $s = catfish_state($uid); $meta = $s['meta']; $owned = catfish_pet_owned($uid);
        [$open, $why] = catfish_pet_slot_open($slot, $meta, $owned);
        if (!$open) return [false, $why !== '' ? $why : 'That spot is locked.'];
        $map = catfish_pet_slotmap($meta); $now = time();
        if ($itemKey === '') {
            $old = $map[$no] ?? '';
            unset($map[$no]);
            if ($old !== '') q('UPDATE catfish_items SET slotted_at = 0 WHERE user_id = ? AND item_key = ?', [$uid, $old]);
            $msg = $old === '' ? 'That spot is already empty.' : CATFISH_PET_ITEMS[$old]['name'] . ' is back on the shelf.';
        } else {
            $item = CATFISH_PET_ITEMS[$itemKey];
            if (!isset($owned[$itemKey])) return [false, 'You do not have that yet. Pet shops sell it.'];
            if (!in_array($slot['key'], $item['fit'], true)) return [false, $item['name'] . ' does not fit here (' . $slot['label'] . ').'];
            if (($map[$no] ?? '') === $itemKey) return [true, $item['name'] . ' is already there.'];
            if (isset($map[$no])) q('UPDATE catfish_items SET slotted_at = 0 WHERE user_id = ? AND item_key = ?', [$uid, $map[$no]]);
            foreach ($map as $n2 => $k2) if ($k2 === $itemKey) unset($map[$n2]);   // one item, one spot
            $map[$no] = $itemKey;
            q('UPDATE catfish_items SET slotted_at = ? WHERE user_id = ? AND item_key = ?', [$now, $uid, $itemKey]);
            $msg = $item['name'] . ' is in place (' . $slot['label'] . ').' . ($item['kind'] === 'A' ? ' You can tap it in ' . catfish_pet_dur(catfish_pet_cfg('catfish_pet_slot_hours', 1) * CATFISH_PET_HOUR) . '.' : '');
        }
        ksort($map);
        $meta['slots'] = $map ?: new stdClass();
        catfish_meta_save($uid, $meta);
        catfish_pet_bonus($uid, true);
        return [true, $msg];
    });
}

/** Open a Yarn slot (the ceiling and the rod charm). Yarn spent never lowers the Kibble bonus (catfish_yarn_spend). */
function catfish_pet_unlock(int $uid, int $no): array
{
    $slot = catfish_pet_slot_def($no);
    if ($slot === null || !isset($slot['unlock']['yarn'])) return [false, 'That spot does not open with Yarn.'];
    return catfish_yarn_spend($uid, function (&$meta) use ($slot) {
        $have = (array)($meta['slotn'] ?? []);
        if (in_array($slot['key'], $have, true)) return [false, 'That spot is already open.'];
        $meta['slotn'] = array_values(array_merge($have, [$slot['key']]));
        return [(int)$slot['unlock']['yarn'], $slot['label'] . ' is open for room things.'];
    });
}

// ---------- using active items ----------

/** The day's use budget: ['n' => uses so far, 'kmin' => pop minutes so far]. */
function catfish_pet_day(array $meta): array
{
    $pa = $meta['pa'] ?? [];
    return is_array($pa) && ($pa['day'] ?? '') === catfish_today() ? ['n' => (int)($pa['n'] ?? 0), 'kmin' => (int)($pa['kmin'] ?? 0)] : ['n' => 0, 'kmin' => 0];
}

/** Seconds until an item can be used: ['slot' => seconds still to wait for the slotted hour, 'cool' => seconds of cooldown left]. */
function catfish_pet_waits(array $row, array $item, ?int $now = null): array
{
    $now ??= time();
    return ['slot' => max(0, (int)$row['slotted_at'] + catfish_pet_cfg('catfish_pet_slot_hours', 1) * CATFISH_PET_HOUR - $now),
        'cool' => max(0, (int)$row['last_used'] + (int)$item['effect']['cooldown_h'] * CATFISH_PET_HOUR - $now)];
}

/** "3 h 20 min" for a number of seconds (at least 1 min). */
function catfish_pet_dur(int $secs): string
{
    $m = max(1, (int)ceil($secs / 60)); $h = intdiv($m, 60);
    return $h > 0 ? $h . ' h' . ($m % 60 > 0 ? ' ' . ($m % 60) . ' min' : '') : $m . ' min';
}

/** Pure: does a roll in [0, 1) win a 1-in-$odds draw? */
function catfish_pet_yarn_hit(int $odds, float $roll): bool
{
    return $odds > 0 && $roll < 1 / $odds;
}

/** The coat names of tomorrow's shelter (colour and pattern of each cat), with stakeouts and holds as they will be. */
function catfish_pet_tomorrow(int $uid, array $meta): array
{
    $t = catfish_tomorrow(); $st = $meta['stake'] ?? null;
    $out = catfish_shelter($uid, $t, [], (int)($meta['rare'] ?? 0), is_array($st) && ($st['for'] ?? '') === $t ? [(string)$st['trait'], (string)$st['value']] : null);
    $h = $meta['hold'] ?? null;
    if (is_array($h) && ($h['for'] ?? '') === $t && isset($out[(int)$h['slot']])) { $c = catfish_cat((int)$h['seed']); $c['slot'] = (int)$h['slot']; $out[(int)$h['slot']] = $c; }
    return $out;
}

/** Text for a hint item. Reads only: nothing is written (the Cat Book in particular). */
function catfish_pet_hint(int $uid, string $kind, array $meta, ?array $cat): string
{
    if ($kind === 'tomorrow_coat') {
        $sh = catfish_pet_tomorrow($uid, $meta); $c = $sh[crc32($uid . '|' . catfish_tomorrow() . '|perch') % count($sh)];
        return 'The parrot whispers: tomorrow the shelter has a ' . $c['colour'] . ' ' . $c['pattern'] . ' cat.';
    }
    if ($kind === 'tomorrow_uncommon') {
        $hit = false; foreach (catfish_pet_tomorrow($uid, $meta) as $c) if ($c['rarity'] !== 'common') $hit = true;
        return $hit ? 'The mirror glints: tomorrow\'s shelter has a cat that is uncommon or better.' : 'The mirror stays plain: tomorrow\'s shelter has only everyday cats.';
    }
    if ($kind === 'unseen_coat') {
        $seen = []; foreach (catfish_book($uid) as $r) $seen[$r[0] . '/' . $r[1]] = 1;
        $left = [];
        foreach (array_keys(CATFISH_TRAITS['pattern']) as $p) foreach (array_keys(CATFISH_TRAITS['colour']) as $c) if (!isset($seen[$p . '/' . $c])) $left[] = $c . ' ' . $p;
        if (!$left) return 'The shadows have nothing to tell: you have seen every coat.';
        return 'The shadows show a coat you have never seen: ' . $left[crc32($uid . '|' . catfish_today() . '|shadow') % count($left)] . '.';
    }
    if ($kind === 'show_score') {
        $e = $meta['show'] ?? null; $week = catfish_show_week(); $pick = $cat;
        if (is_array($e) && ($e['week'] ?? '') === $week && (int)($e['cat'] ?? 0) > 0) {
            $row = q_one('SELECT * FROM cats WHERE id = ? AND user_id = ?', [(int)$e['cat'], $uid]);
            if ($row) { $pick = catfish_cat((int)$row['seed']); $pick['name'] = (string)$row['name']; }
        }
        if (!$pick) return 'Adopt a cat first; the bowl needs someone to listen for.';
        $theme = catfish_show_theme($week); $j = catfish_show_judge($uid, $week, $pick, $theme);
        $score = $j['score'] + catfish_pet_show_bonus($uid, $pick); $tier = catfish_show_tier($score);
        return $pick['name'] . ' would score ' . $score . ' for "' . $theme['label'] . '" right now: ' . (CATFISH_RIBBONS[$tier][2] ?? CATFISH_RIBBON_PART[2]) . '.';
    }
    return '';
}

/**
 * Use the active item in slot $no. Inside the gnome's lock. Checks, in order: the item is slotted and active, slotted long enough (an hour), off cooldown, under the day's 4 uses,
 * then the effect: a pop pays minutes of the current Kibble/h (cut to what is left of the day's 60 minutes, refused when none is left), a Yarn chance (1-in-N, at most one Yarn an ISO week
 * from all items), window rain, happy cats, a hint (text only) or a free shelter reroll (counts toward CATFISH_REROLL_MAX). $opts['shelter'] picks the shelter spot for a reroll.
 * $roll (tests only; the API never passes it) replaces the random Yarn roll. Returns [ok, message, extra] with extra = ['pop' => Kibble paid, 'yarn' => 0|1, 'happy' => bool, 'rain' => bool, 'hint' => text].
 */
function catfish_pet_use(int $uid, int $no, array $opts = [], ?float $roll = null): array
{
    return catfish_locked($uid, function () use ($uid, $no, $opts, $roll) {
        $s = catfish_tick($uid); $meta = $s['meta']; $owned = catfish_pet_owned($uid);
        $key = catfish_pet_active_slots($meta, $owned)[$no] ?? '';
        if ($key === '') return [false, 'Nothing is in that spot.', []];
        $item = CATFISH_PET_ITEMS[$key]; $row = $owned[$key]; $fx = $item['effect'];
        if ($item['kind'] !== 'A') return [false, $item['name'] . ' just sits there looking lovely. It needs no tapping.', []];
        $w = catfish_pet_waits($row, $item);
        if ($w['slot'] > 0) return [false, $item['name'] . ' needs ' . catfish_pet_dur($w['slot']) . ' more in its spot before you can use it.', []];
        if ($w['cool'] > 0) return [false, $item['name'] . ' is ready again in ' . catfish_pet_dur($w['cool']) . '.', []];
        $day = catfish_pet_day($meta); $maxUses = catfish_pet_cfg('catfish_pet_uses_day', 4);
        if ($day['n'] >= $maxUses) return [false, 'That is ' . $maxUses . ' room things used today. Try again tomorrow.', []];
        $cat = catfish_active($uid, $s); $extra = ['pop' => 0, 'yarn' => 0, 'happy' => false, 'rain' => false, 'hint' => ''];
        $popMin = (int)($fx['pop_min'] ?? 0); $paidMin = 0; $paid = 0;
        if ($popMin > 0) {
            if (!$cat) return [false, 'Adopt a cat first, so there is Kibble to find.', []];
            $paidMin = min($popMin, catfish_pet_cfg('catfish_pet_pop_min_day', 60) - $day['kmin']);
            if ($paidMin < 1) return [false, 'Today\'s room things have found all the Kibble they can (' . catfish_pet_cfg('catfish_pet_pop_min_day', 60) . ' minutes of it). Try again tomorrow.', []];
            $kph = catfish_kph($s['up'], $cat, true, (int)$s['yarn'], catfish_extra_mult($uid));
            $paid = max(1, (int)floor($kph * $paidMin / 60));
        }
        if (isset($fx['reroll'])) {
            $n = array_replace([0, 0, 0], ($meta['roll']['day'] ?? '') === catfish_today() ? (array)($meta['roll']['n'] ?? []) : []);
            $shelter = catfish_shelter_now($uid, $meta); $pick = -1;
            $ok = function (int $i) use ($n, $shelter, $uid) {
                return isset($shelter[$i]) && $n[$i] < CATFISH_REROLL_MAX && empty($shelter[$i]['held']) && !q_val('SELECT 1 FROM cats WHERE user_id = ? AND seed = ?', [$uid, $shelter[$i]['seed']]);
            };
            if (isset($opts['shelter']) && $opts['shelter'] !== '') $pick = $ok((int)$opts['shelter']) ? (int)$opts['shelter'] : -2;
            else foreach ([0, 1, 2] as $i) if ($ok($i)) { $pick = $i; break; }
            if ($pick < 0) return [false, 'There is no shelter cat the drum can shuffle right now.', []];
            $n[$pick]++;
            $meta['roll'] = ['day' => catfish_today(), 'n' => $n];
        }
        if (!empty($fx['hint'])) { $extra['hint'] = catfish_pet_hint($uid, (string)$fx['hint'], $meta, $cat); $meta['phint'][$key] = ['day' => catfish_today(), 'text' => $extra['hint']]; }
        if (!empty($fx['rain_min'])) { $meta['rain'] = time() + (int)$fx['rain_min'] * 60; $extra['rain'] = true; }
        if (!empty($fx['happy_frames'])) $extra['happy'] = true;
        $yarn = 0;
        if (!empty($fx['yarn_odds']) && catfish_pet_yarn_hit((int)$fx['yarn_odds'], $roll ?? random_int(0, 999999) / 1000000)) {
            $week = catfish_week(); $py = $meta['py'] ?? [];
            $thisWeek = is_array($py) && ($py['week'] ?? '') === $week ? (int)($py['n'] ?? 0) : 0;
            if ($thisWeek < catfish_pet_cfg('catfish_pet_yarn_week', 1)) { $yarn = 1; $meta['py'] = ['week' => $week, 'n' => $thisWeek + 1]; }
        }
        $meta['pa'] = ['day' => catfish_today(), 'n' => $day['n'] + 1, 'kmin' => $day['kmin'] + $paidMin];
        $claim = q('UPDATE catfish_items SET last_used = ? WHERE user_id = ? AND item_key = ? AND last_used = ?', [time(), $uid, $key, $row['last_used']])->rowCount();
        if ($claim !== 1) return [false, 'Try that again.', []];
        q('UPDATE catfish_state SET kibble = kibble + ?, run_kibble = run_kibble + ?, total_kibble = total_kibble + ?, yarn = yarn + ?, meta = ? WHERE user_id = ?', [$paid, $paid, $paid, $yarn, json_encode($meta), $uid]);
        $extra['pop'] = $paid; $extra['yarn'] = $yarn;
        $msg = ($item['use_text'] ?? 'Done.') . ($paid > 0 ? ' +' . number_format($paid) . ' Kibble.' : '') . ($yarn ? ' +1 Yarn!' : '') . ($extra['hint'] !== '' ? ' ' . $extra['hint'] : '');
        return [true, trim($msg), $extra];
    });
}

// ---------- the scene ----------

/** What the scene draws: ['slots' => slot no => item key, 'ready' => slot no => true when an active item can be used now, 'rain' => bool, 'bird_x' => int]. */
function catfish_pet_scene(int $uid): array
{
    $out = ['slots' => [], 'ready' => [], 'rain' => false, 'bird_x' => 1];
    try {
        $row = q_one('SELECT meta FROM catfish_state WHERE user_id = ?', [$uid]);
        $meta = $row ? json_decode((string)$row['meta'], true) : null;
        if (!is_array($meta)) return $out;
        $owned = catfish_pet_owned($uid); $out['slots'] = catfish_pet_active_slots($meta, $owned);
        $day = catfish_pet_day($meta);
        foreach ($out['slots'] as $no => $key) {
            $it = CATFISH_PET_ITEMS[$key]; if ($it['kind'] !== 'A') continue;
            $w = catfish_pet_waits($owned[$key], $it);
            $out['ready'][$no] = $w['slot'] === 0 && $w['cool'] === 0 && $day['n'] < catfish_pet_cfg('catfish_pet_uses_day', 4);
        }
        $out['rain'] = (int)($meta['rain'] ?? 0) > time();
        $out['bird_x'] = catfish_pet_bonus($uid)['bird_x'];
    } catch (Throwable $e) {}
    return $out;
}

/** The spot name for an item type: 'Shelf', 'Window sill', 'Picture frame', 'Ceiling', 'Floor, corner', 'Floor, by the bowl', 'Rod charm'. */
function catfish_pet_type_label(string $type): string
{
    foreach (CATFISH_PET_SLOTS as $s) if ($s['type'] === $type) return $type === 'shelf' ? 'Shelf' : $s['label'];
    return ucfirst($type);
}

/** One item sprite (cf-pet-<key>.png, exactly the slot's size) or, with no PNG, a red-outlined placeholder with an emoji. */
function catfish_pet_sprite(string $key, int $scale = 1): string
{
    $it = CATFISH_PET_ITEMS[$key]; $slot = null;
    foreach (CATFISH_PET_SLOTS as $s) if ($s['type'] === $it['type']) { $slot = $s; break; }
    $w = ($slot['w'] ?? 24) * $scale; $h = ($slot['h'] ?? 24) * $scale;
    if (catfish_art_has('cf-pet-' . $key . '.png')) return '<img class="cfimg cfpetimg" src="' . e(catfish_art_url('cf-pet-' . $key . '.png')) . '" alt="" width="' . $w . '" height="' . $h . '">';
    return '<span class="cfpetph" aria-hidden="true">🐾</span>';
}

/**
 * The room things on the stage, drawn right after the room extras and before the wand, fish and cats (so the cats and fish stay in front, and floor things are behind every cat).
 * Positions are classes (.cfpet-s1..s8 from room-layout.json "pet_slots"), no inline style. A passive item is a plain span, an active item a button the page's JS uses (data-slot);
 * without JS the Room things panel does the same with forms. The rod charm (slot 8) is drawn by catfish_pet_charm_html() after the rod line. $pets = catfish_pet_scene().
 */
function catfish_pets_html(array $pets): string
{
    $slots = (array)($pets['slots'] ?? []);
    $h = !empty($pets['rain']) ? '<span class="cfrain" aria-hidden="true"></span>' : '';   // a Rain Stick's hour of rain on the window
    if (!$slots) return $h;
    $order = [6, 7, 1, 2, 3, 4, 5];   // the two floor spots first (they sit lowest), then shelf, shelf, sill, frame, ceiling
    foreach ($order as $no) {
        $key = $slots[$no] ?? ''; if ($key === '') continue;
        $it = CATFISH_PET_ITEMS[$key];
        $cls = 'cfpet cfpet-s' . $no . ' cfpi-' . $key . (isset($it['effect']['cosmetic']) ? ' cfpc-' . $it['effect']['cosmetic'] : '');
        if ($it['kind'] === 'A') {
            $ready = !empty($pets['ready'][$no]);
            $h .= '<button type="button" class="' . $cls . ($ready ? ' is-ready' : ' is-wait') . '" data-slot="' . $no . '" data-item="' . $key . '" aria-label="' . e($it['name'] . ($ready ? ': ready, tap to use' : ': not ready yet')) . '">' . catfish_pet_sprite($key) . '</button>';
        } else {
            $h .= '<span class="' . $cls . '" data-item="' . $key . '" aria-hidden="true">' . catfish_pet_sprite($key) . '</span>';
        }
    }
    return $h;
}

/** The rod charm (slot 8), tied to the rod line: drawn after the line so it hangs in front of it. '' with none. */
function catfish_pet_charm_html(array $pets): string
{
    $key = ((array)($pets['slots'] ?? []))[8] ?? '';
    return $key === '' ? '' : '<span class="cfpet cfpet-s8 cfpi-' . $key . '" data-item="' . $key . '" aria-hidden="true">' . catfish_pet_sprite($key) . '</span>';
}

/** Classes for .cfstage from the room things (a leading space each, '' with none): rain on the window, a Weaver-bird Nest, lit ceiling lanterns. */
function catfish_pet_stage_classes(array $pets): string
{
    $c = !empty($pets['rain']) ? ' cfpr-rain' : '';
    if ((int)($pets['bird_x'] ?? 1) > 1) $c .= ' cfpr-birdx2';
    return $c;
}

/** The scene key's share: the slot map, the rain flag and which active things are ready (a swap, a use or the end of a cooldown changes the key, so the stage is redrawn); '' with nothing placed. */
function catfish_pet_key(array $pets): string
{
    if (empty($pets['slots']) && empty($pets['rain'])) return '';   // nothing placed: the key is what it was before room things
    return json_encode([(object)($pets['slots'] ?? []), !empty($pets['rain']), array_keys(array_filter((array)($pets['ready'] ?? [])))]);   // the ready list: a thing that becomes ready (or is used) swaps the stage at the next tick
}

// ---------- the Room things panel (catfish.php) ----------

/** One state record per slot for the panel. */
function catfish_pet_panel_data(int $uid, array $meta): array
{
    $owned = catfish_pet_owned($uid); $map = catfish_pet_slotmap($meta); $active = catfish_pet_active_slots($meta, $owned); $day = catfish_pet_day($meta); $out = [];
    foreach (CATFISH_PET_SLOTS as $slot) {
        [$open, $why, $yarn] = catfish_pet_slot_open($slot, $meta, $owned);
        $key = $active[$slot['no']] ?? ''; $r = ['slot' => $slot, 'open' => $open, 'why' => $why, 'yarn' => $yarn, 'item' => $key, 'use' => null];
        if ($key !== '' && CATFISH_PET_ITEMS[$key]['kind'] === 'A') {
            $w = catfish_pet_waits($owned[$key], CATFISH_PET_ITEMS[$key]);
            $r['use'] = ['slot_wait' => $w['slot'], 'cool' => $w['cool'], 'can' => $w['slot'] === 0 && $w['cool'] === 0 && $day['n'] < catfish_pet_cfg('catfish_pet_uses_day', 4)];
        }
        $out[] = $r;
    }
    return ['slots' => $out, 'owned' => $owned, 'day' => $day, 'map' => $map];
}

/** The "Room things" hub panel. $v = catfish_view(); $meta = the state's meta (fresh). One <form> and <select> per spot, works without JS. */
function catfish_pet_panel_html(int $uid, array $v, array $meta): string
{
    $d = catfish_pet_panel_data($uid, $meta); $owned = $d['owned']; $maxUses = catfish_pet_cfg('catfish_pet_uses_day', 4); $popMax = catfish_pet_cfg('catfish_pet_pop_min_day', 60);
    $ready = 0; foreach ($d['slots'] as $r) if ($r['use'] && $r['use']['can']) $ready++;
    $openN = 0; foreach ($d['slots'] as $r) if ($r['open']) $openN++;
    $h = '<section class="cfpanel box" id="cf-p-pets" data-icon="🪴" data-title="Room things" data-status="' . count($owned) . ' owned" data-badge="' . $ready . '"><h3>🪴 Room things · ' . $openN . ' of ' . count(CATFISH_PET_SLOTS) . ' spots open</h3>'
        . '<p class="help">Pet shops in regions from the Sunsprinkle Isles on sell things for your room, for Petals. Place them in a spot below; swapping is free. Some are just pretty, some add a little Kibble, and some can be tapped once a day or so. '
        . 'A thing you tap must sit in its spot for an hour first. Up to ' . $maxUses . ' taps and ' . $popMax . ' minutes of Kibble a day from all of them.</p>';
    $h .= '<p>Today: <b>' . $d['day']['n'] . ' of ' . $maxUses . '</b> taps used · <b>' . $d['day']['kmin'] . ' of ' . $popMax . '</b> minutes of Kibble found.</p>';
    foreach ($d['slots'] as $r) {
        $slot = $r['slot']; $no = $slot['no']; $label = e($slot['label']);
        $h .= '<div class="cfpetslot" id="cf-pet-' . $no . '"><div class="cfup cfpetrow"><span class="cficon">' . ($r['item'] !== '' ? catfish_pet_sprite($r['item']) : '<span aria-hidden="true">' . ($r['open'] ? '▫️' : '🔒') . '</span>') . '</span><span class="cfinfo"><b>' . $label . '</b>';
        if (!$r['open']) {
            $h .= '<br><small class="muted">' . e($r['why']) . '</small></span>';
            if ($r['yarn'] > 0) $h .= '<form method="post">' . csrf_field() . '<input type="hidden" name="do" value="petunlock"><input type="hidden" name="slot" value="' . $no . '"><button class="btn" type="submit"' . ($v['spend'] >= $r['yarn'] ? '' : ' disabled') . '>' . $r['yarn'] . ' Yarn</button></form>';
            $h .= '</div></div>';
            continue;
        }
        if ($r['item'] === '') $h .= ' <small class="muted">empty</small>';
        else {
            $it = CATFISH_PET_ITEMS[$r['item']];
            $h .= ' <small class="muted">' . e($it['name']) . '</small><br><small>' . e($it['desc']) . '</small>';
            if ($r['use']) {
                $u = $r['use'];
                $h .= '<br><small class="cfpetstate">' . ($u['slot_wait'] > 0 ? 'Settling in: ' . e(catfish_pet_dur($u['slot_wait'])) . ' to go.' : ($u['cool'] > 0 ? 'Ready again in ' . e(catfish_pet_dur($u['cool'])) . '.' : ($u['can'] ? 'Ready!' : 'No taps left today.'))) . '</small>';
                $ph = $meta['phint'][$r['item']] ?? null;
                if (is_array($ph) && ($ph['text'] ?? '') !== '') $h .= '<br><small class="cfpethint">Last: ' . e((string)$ph['text']) . '</small>';
            }
        }
        $h .= '</span></div>';
        $h .= '<div class="cfpetacts"><form method="post" class="cfpetform">' . csrf_field() . '<input type="hidden" name="do" value="petslot"><input type="hidden" name="slot" value="' . $no . '"><label class="vh" for="cf-petsel-' . $no . '">Thing for ' . $label . '</label>'
            . '<select id="cf-petsel-' . $no . '" name="item"><option value="">(empty)</option>';
        $map = $d['map'];
        foreach ($owned as $key => $o) {
            $it = CATFISH_PET_ITEMS[$key]; if (!in_array($slot['key'], $it['fit'], true)) continue;
            $at = array_search($key, $map, true);
            $h .= '<option value="' . e($key) . '"' . (($map[$no] ?? '') === $key ? ' selected' : '') . '>' . e($it['name']) . ($at !== false && $at !== $no ? ' (now in ' . e(catfish_pet_slot_def((int)$at)['label']) . ')' : '') . '</option>';
        }
        $h .= '</select> <button class="btn" type="submit">Place</button></form>';
        if ($r['use']) {
            $key = $r['item']; $it = CATFISH_PET_ITEMS[$key];
            $h .= '<form method="post" class="cfpetform">' . csrf_field() . '<input type="hidden" name="do" value="petuse"><input type="hidden" name="slot" value="' . $no . '">';
            if (isset($it['effect']['reroll'])) {
                $h .= '<label class="vh" for="cf-petsh">Shelter cat to shuffle</label><select id="cf-petsh" name="shelter">';
                foreach (catfish_shelter_now($uid, $meta) as $sc) $h .= '<option value="' . (int)$sc['slot'] . '">' . e(ucfirst($sc['colour'] . ' ' . $sc['pattern'])) . '</option>';
                $h .= '</select> ';
            }
            $h .= '<button class="btn" type="submit"' . ($r['use']['can'] ? '' : ' disabled') . '>Use ' . e($it['name']) . '</button></form>';
        }
        $h .= '</div></div>';
    }
    $h .= '<details class="cfgroup"><summary><b>🏪 Pet shops</b></summary><ul class="cfpshops">';
    foreach (CATFISH_PET_SHOPS as $code => $sh) {
        $id = (int)q_val('SELECT id FROM shops WHERE slug = ?', [petshop_slug($code)]);
        $region = (string)q_val('SELECT gnomish_name FROM regions WHERE code = ?', [$code]);
        $bought = 0; foreach ($owned as $k => $o) if (CATFISH_PET_ITEMS[$k]['shop'] === $code) $bought++;
        $h .= '<li>' . ($id ? '<a href="' . e(url('shop.php?id=' . $id)) . '">' . e($sh['name']) . '</a>' : e($sh['name'])) . ' <small class="muted">· ' . e($region) . ' · ' . $bought . ' of 5</small></li>';
    }
    return $h . '</ul><p class="help">You have to be in the region\'s market town to buy.</p></details></section>';
}

// ---------- the shops ----------

function petshop_slug(string $code): string
{
    return strtolower($code) . '-pet-shop';
}

/** The region code of a pet shop row (from its slug), or ''. */
function petshop_code(array $shop): string
{
    foreach (array_keys(CATFISH_PET_SHOPS) as $code) if (($shop['slug'] ?? '') === petshop_slug($code)) return $code;
    return '';
}

/** A keeper line (kind = greeting, bought_before, bought_after, cannot_afford, region_not_reached, farewell), steady for a gnome for a day so a reload says the same thing. {item} becomes $item. */
function petshop_line(string $code, string $kind, int $uid, string $item = ''): string
{
    $lines = CATFISH_PET_SHOPS[$code]['lines'][$kind] ?? [];
    if (!$lines) return '';
    return str_replace('{item}', $item, $lines[crc32($uid . '|' . $code . '|' . $kind . '|' . hollow_date('Y-m-d')) % count($lines)]);
}

/** Make the 11 pet shops (shop row, round-the-clock keeper, schedule) beside each regional seed market. Idempotent. Returns true when all 11 exist. */
function petshops_ensure(): bool
{
    if (!q_val('SELECT 1 FROM regions LIMIT 1')) return false;
    $all = true; $personality = ['CB' => 'Cheerful', 'SE' => 'Warm', 'SA' => 'Warm', 'EE' => 'Gruff', 'MENA' => 'Gentle', 'EA' => 'Calm', 'CSA' => 'Cheerful', 'SEA' => 'Eager', 'WCA' => 'Warm', 'ESA' => 'Patient', 'OC' => 'Salty'];
    foreach (CATFISH_PET_SHOPS as $code => $sh) {
        $slug = petshop_slug($code);
        if (q_val('SELECT 1 FROM shops WHERE slug = ?', [$slug])) continue;
        $loc = (int)q_val('SELECT id FROM locations WHERE slug = ?', ['market-' . strtolower($code)]);
        if (!$loc) { $all = false; continue; }
        $shopId = db_insert('shops', ['name' => $sh['name'], 'slug' => $slug, 'location_id' => $loc, 'shop_type' => 'pets', 'restock_minutes' => 60,
            'description' => $sh['blurb'] . ' Run by ' . $sh['keeper'] . '. Things for your Cat Fish room, for Petals.']);
        $nslug = str_replace('_', '-', $sh['keeper_slug']);
        $nid = (int)q_val('SELECT id FROM npcs WHERE slug = ?', [$nslug]);
        if (!$nid) $nid = db_insert('npcs', ['name' => $sh['keeper'], 'slug' => $nslug, 'species' => 'Gnome', 'personality' => $personality[$code] ?? 'Cheerful',
            'bio' => 'Keeps ' . $sh['name'] . ', the pet shop at the market. ' . $sh['blurb'], 'home_location_id' => $loc]);
        db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $loc, 'shop_id' => $shopId, 'activity' => 'working', 'start_hour' => 0, 'end_hour' => 0]);   // start = end means all day
    }
    if ($all) set_setting('petshops220', '1');
    return $all;
}

/** Run petshops_ensure() once per request if this world has not had it (a world updated in place while the version is not bumped, or a fresh install). */
function petshops_boot(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    if (setting('petshops220') !== '1') {
        try { petshops_ensure(); } catch (Throwable $e) { error_log('petshops_boot: ' . $e->getMessage()); }   // never take a page down (no tables yet, a half-installed world)
    }
}

/**
 * Buy one item. Needs: Cat Fish open, a real gnome, the item sold by THIS shop, the gnome standing in the shop's town (shop_reachable), the Petals and not owning it yet.
 * Petals and the new row change together in one transaction. Nothing refunds, sells or trades an item. Returns [ok, message].
 */
function petshop_buy(array $u, array $shop, string $key, bool $reachable = true): array
{
    require_once __DIR__ . '/world.php';   // shop_reachable()
    $uid = (int)$u['id']; $code = petshop_code($shop);
    if ($code === '' || !isset(CATFISH_PET_ITEMS[$key]) || CATFISH_PET_ITEMS[$key]['shop'] !== $code) return [false, 'This shop does not sell that.'];
    if (!empty($u['guest'])) return [false, 'Guests can\'t keep a cat. Make your own gnome first!'];
    if (!catfish_open() || !catfish_ensure()) return [false, 'Cat Fish isn\'t open right now.'];
    if (catfish_pet_cfg('catfish_pet_shops_open', 1) < 1) return [false, 'The pet shops are closed for now.'];
    if (!$reachable || !shop_reachable($u, $shop)) return [false, petshop_line($code, 'region_not_reached', $uid)];
    $item = CATFISH_PET_ITEMS[$key]; $price = catfish_pet_price($item);
    try {
        $r = catfish_locked($uid, function () use ($uid, $key, $price, $item, $code) {
            if (q_val('SELECT 1 FROM catfish_items WHERE user_id = ? AND item_key = ?', [$uid, $key])) return [false, 'You already have ' . $item['name'] . '.'];
            if (!take_petals($uid, $price, 'catfish_pet')) return [false, petshop_line($code, 'cannot_afford', $uid)];
            db_insert('catfish_items', ['user_id' => $uid, 'item_key' => $key, 'got_at' => now(), 'last_used' => 0, 'slotted_at' => 0]);
            return [true, petshop_line($code, 'bought_before', $uid, $item['name']) . ' ' . $item['name'] . ' is yours for ' . number_format($price) . ' Petals. ' . petshop_line($code, 'bought_after', $uid, $item['name'])];
        });
    } catch (Throwable $e) {
        return [false, 'You already have ' . $item['name'] . '.'];   // a second tab bought it first: the transaction rolled the Petals back
    }
    if ($r[0]) catfish_pet_bonus($uid, true);
    return $r;
}

/** A POST from a pet shop page (shop.php routes every do=pet_* here). */
function petshop_post(array $u, array $shop, string $do, bool $reachable): array
{
    if (petshop_code($shop) === '') return [false, 'This shop does not sell that.'];
    if ($do === 'pet_buy') return petshop_buy($u, $shop, (string)($_POST['item'] ?? ''), $reachable);
    return [false, 'This shop does not sell that.'];
}

/** The shop's picture: real art (banner-<CODE>-pets.png, 480 x 120 at 2x) from the Cat Fish art folder or the placeholders, else ''. */
function petshop_banner_html(string $code, string $name): string
{
    foreach (['assets/img/catfish/banner-' . $code . '-pets.png', 'assets/img/catfish/banner-' . strtolower($code) . '-pets.png'] as $p) {
        if (art_path($p) !== '') return '<h2 class="cfpbanner"><img class="cfimg" src="' . e(url($p)) . '" alt="' . e($name) . '" width="480" height="120"></h2>';
    }
    $ph = ph_path('banner-' . strtolower($code) . '-pets');
    if ($ph !== '') return '<h2 class="cfpbanner"><img class="cfimg" src="' . e(url($ph)) . '" alt="' . e($name) . '" width="480" height="120"></h2>';
    return '<h2 class="cfpbanner cfpbanner-ph" role="img" aria-label="' . e($name) . '"><span>' . e($name) . '</span></h2>';
}

/** The whole pet shop page body (below the crumbs): banner, keeper with a line, the five things, buy forms. */
function petshop_page_html(array $u, array $shop, bool $reachable): string
{
    require_once __DIR__ . '/items.php'; require_once __DIR__ . '/friends.php';   // ph_path(), art_path(), npc_portrait()
    $code = petshop_code($shop); $sh = CATFISH_PET_SHOPS[$code]; $uid = (int)$u['id'];
    $owned = catfish_ensure() ? catfish_pet_owned($uid) : [];
    $meta = catfish_ensure() ? catfish_state($uid)['meta'] : [];
    $map = catfish_pet_slotmap($meta); $coins = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
    $canBuy = $reachable && catfish_open() && empty($u['guest']) && catfish_pet_cfg('catfish_pet_shops_open', 1) > 0;
    $nslug = str_replace('_', '-', $sh['keeper_slug']);
    $npc = q_one('SELECT * FROM npcs WHERE slug = ?', [$nslug]) ?: ['name' => $sh['keeper'], 'slug' => $nslug, 'species' => 'Gnome', 'image' => ''];
    $hello = !$reachable ? petshop_line($code, 'region_not_reached', $uid) : petshop_line($code, 'greeting', $uid);
    $h = petshop_banner_html($code, $sh['name']);
    $h .= '<div class="cfpkeeper"><div class="cfpportrait">' . npc_portrait($npc) . '</div><div class="cfpsays"><p class="cfpname"><b>' . e($sh['keeper']) . '</b> <small class="muted">keeps the counter</small></p>'
        . '<p class="cfpline">“' . e($hello) . '”</p><p class="help">' . e($sh['blurb']) . '</p></div></div>';
    $h .= '<p class="status">You have <b class="mycoins" data-coins="' . $coins . '">' . money($coins) . '</b>' . (empty($u['guest']) ? ' · <a href="' . e(url('catfish.php')) . '">Cat Fish → Room things</a>' : '') . '</p>';
    if (!$reachable) $h .= '<div class="flash err">🧭 This shop is in the market town of ' . e((string)q_val('SELECT gnomish_name FROM regions WHERE code = ?', [$code])) . '. You can look at the shelves, but you have to be there to buy.</div>';
    $h .= '<ul class="cfplist">';
    foreach (CATFISH_PET_ITEMS as $key => $it) {
        if ($it['shop'] !== $code) continue;
        $price = catfish_pet_price($it); $has = isset($owned[$key]); $at = $has ? array_search($key, $map, true) : false;
        $kind = $it['kind'] === 'A' ? 'Tap it · every ' . (int)$it['effect']['cooldown_h'] . ' h' : (!empty($it['effect']['cosmetic']) && count($it['effect']) === 1 ? 'Just for looks' : 'Always on');
        $h .= '<li class="cfup cfpitem"><span class="cficon cfpspr">' . catfish_pet_sprite($key, 2) . '</span><span class="cfinfo"><b>' . e($it['name']) . '</b> <small class="muted">· ' . e($kind) . ' · ' . e(catfish_pet_type_label($it['type'])) . '</small><br>'
            . '<small>' . e($it['desc']) . '</small><br><small class="muted">' . e($it['flavour']) . '</small></span>';
        if ($has) $h .= '<span class="cfpown"><small class="muted">' . ($at !== false ? '✓ In your room' : '✓ Yours, not placed') . '</small></span>';
        else $h .= '<form method="post" action="' . e(url('shop.php?id=' . (int)$shop['id'])) . '">' . csrf_field() . '<input type="hidden" name="do" value="pet_buy"><input type="hidden" name="item" value="' . e($key) . '"><button class="btn" type="submit"'
            . ($canBuy && $coins >= $price ? '' : ' disabled') . ' aria-label="Buy ' . e($it['name']) . ' for ' . number_format($price) . ' Petals">' . number_format($price) . '</button></form>';
        $h .= '</li>';
    }
    $h .= '</ul>';
    if ($canBuy) {
        $cheapest = PHP_INT_MAX; foreach (CATFISH_PET_ITEMS as $k => $it) if ($it['shop'] === $code && !isset($owned[$k])) $cheapest = min($cheapest, catfish_pet_price($it));
        if ($cheapest !== PHP_INT_MAX && $coins < $cheapest) $h .= '<p class="help cfpline">“' . e(petshop_line($code, 'cannot_afford', $uid)) . '”</p>';
    }
    return $h . '<p class="help cfpline">“' . e(petshop_line($code, 'farewell', $uid)) . '”</p>';
}
