<?php
declare(strict_types=1);

/**
 * v1.8.8 Treks: the "a bit more between finding each person" pieces.
 *  - trail events: now and then a plain tile has a small choice card (st.ev, one pending at a time; a choice resolves once inside trek_tx)
 *  - crew moments: a few walks after a trailmate joins, one short beat with a tiny task only they can do (st.cm; flag cm_<crew> = once per run)
 *  - the three hand-placed side stops (cart, mush camp; the Riddle Stone reuses the riddle code)
 * Story text is always trek_text(); button labels and result numbers are plain strings. Petals and XP go through the same daily caps as fights
 * (trek_petals_capped()), so no event is a way around it. Since v1.8.9 events give trek XP (never gnome XP). Everything here runs inside trek_tx (users row locked, run re-read).
 */

/** id => [icon, title]. The card text is ch1.ev.<id>.text; each choice's result is ch1.ev.<id>.<part>. */
const TREK_EVENTS = [
    'stash'   => ['🪙', 'A hidden stash'],
    'forager' => ['🧺', 'A lost forager'],
    'fork'    => ['🔀', 'A fork in the path'],
    'trader'  => ['🧳', 'A passing trader'],
    'shrine'  => ['🕯️', 'A little shrine'],
    'puddle'  => ['✨', 'A glowing puddle'],
    'beetle'  => ['🪲', 'A wounded beetle'],
    'song'    => ['🎶', 'A song stone'],
    'handprints' => ['🖐️', 'Clay handprints'],   // v1.9.2: Chapter II only (TREK_EVENT_CH)
    'pot'     => ['🏺', 'A rolling pot'],
    'echo'    => ['📣', 'A listening wall'],     // v1.9.4: Chapter II-b only (TREK_EVENT_ZONES)
    'moth'    => ['🦋', 'A dim moth'],
    'kettle'  => ['🫖', 'A forgotten kettle'],
    'drumbeat' => ['🥁', 'A far-off drum'],
];

/** v1.9.2: events that belong to some chapters only (id => chapters). The Chapter I events can happen anywhere; their text falls back to Chapter I's. */
const TREK_EVENT_CH = ['handprints' => [2], 'pot' => [2], 'echo' => [2], 'moth' => [2], 'kettle' => [2], 'drumbeat' => [2]];

/** v1.9.4: events that belong to some zones of their chapter only (id => zone letters): Chapter II-b's four. */
const TREK_EVENT_ZONES = ['echo' => ['n', 'o'], 'moth' => ['p'], 'kettle' => ['p', 'q', 'r'], 'drumbeat' => ['r', 's']];

/** trailmate key => [icon, task button]. Each key is a recruit (the flag freed_<key> in their own chapter, or the recruits table when carried into a later one). */
const TREK_CREW_BEATS = [
    'burdock' => ['🌳', 'Burdock moves the roots'],
    'zinnia'  => ['🌸', 'Zinnia tends the party'],
    'bracken' => ['🔭', 'Bracken scouts ahead'],
    'sorrel'  => ['🗺️', 'Sorrel inks a little map'],   // v1.9.2
    'tumble'  => ['🧭', 'Tumble reads the signs'],       // v1.9.4
    'juniper' => ['🍲', 'Juniper stirs up a snack'],
    'wren'    => ['🌟', 'Wren coaxes the glowcaps'],     // v2.0.20: Chapter III. Bloomcaller; reuses the shrine’s blessing (st.bless)
];

/** A roll from 1 to $max. The tests can pin it with $GLOBALS['trek_test_roll'] (never set in the game). */
function trek_roll(int $max): int
{
    if (isset($GLOBALS['trek_test_roll'])) return max(1, min($max, (int)$GLOBALS['trek_test_roll']));
    return random_int(1, max(1, $max));
}

function trek_d20(): int
{
    return isset($GLOBALS['trek_test_d20']) ? (int)$GLOBALS['trek_test_d20'] : d(20);
}

/** The best modifier of one stat among the living party (the gnome counts; a trailmate's stat comes from the crew file). */
function trek_best_mod(array &$run, array $u, string $stat): int
{
    $best = -99;
    foreach (trek_party_stats($run, $u) as $slot => $m) {
        if ((int)$run['party'][$slot]['hp'] <= 0) continue;
        $best = max($best, eff_mod($m['user'], $stat));
    }
    return $best === -99 ? 0 : $best;
}

function trek_signed(int $n): string
{
    return ($n >= 0 ? '+' : '−') . abs($n);
}

/** Add fatigue (or take it off), kept between 0 and 100. */
function trek_add_fatigue(array &$run, int $d): void
{
    $run['fatigue'] = max(0, min(100, (int)$run['fatigue'] + $d));
}

/** Petals found on the trail: under the daily limit shared with fights, carried (not banked) like fight Petals. */
function trek_find_petals(array &$run, int $want): void
{
    $n = trek_petals_capped($run, $want);
    if ($n > 0) {
        $run['petals_found'] = (int)$run['petals_found'] + $n;
        trek_say($run, '🪙 You find ' . $n . ' ' . setting('currency_name') . ' (carried: bank them at a camp).');
    } else {
        trek_say($run, '🪙 (today’s trek ' . setting('currency_name') . ' limit is reached)');
    }
}

/** v1.8.9: a little trek XP for the living party (it was gnome XP under a daily limit before trek levels). Never touches the gnome's main XP. */
function trek_find_xp(array &$run, array $u, int $xp): void
{
    trek_say($run, '✨ +' . $xp . ' trek XP.');
    trek_tl_give($run, $u, $xp, false);
}

/** [slot, name] of the first living Bloomcaller in the party, or null. */
function trek_bloomcaller(array &$run, array $u): ?array
{
    foreach (trek_party_stats($run, $u) as $slot => $m) {
        if ($m['calling'] === 'bloomcaller' && (int)$run['party'][$slot]['hp'] > 0) return [(int)$slot, trek_first_name_of((string)$m['name'])];
    }
    return null;
}

function trek_first_name_of(string $n): string
{
    return trek_short_name($n);
}

/** The trader's price: a bit under the camp's, paid from carried Petals. */
function trek_trader_price(): int
{
    return max(1, (int)round(max(0, (int)setting('trek_campkit_price')) * 0.75));
}

// ------------------------------------------------------------------ trail events

/**
 * The choices an event offers now: n => [icon, title, sub, off]. Choice 0 (walk on) is always there and is not listed. A choice that is "off" is shown
 * greyed and refused (the event stays). The Bloomcaller choice of the beetle only exists with a Bloomcaller in the party.
 */
function trek_ev_choices(array &$run, array $u, string $id): array
{
    switch ($id) {
        case 'stash':
            return [1 => ['⛏️', 'Dig it out', 'a few ' . setting('currency_name'), false]];
        case 'forager':
            return [1 => ['🤝', 'Help them home', 'tiring · a little trek XP', false]];
        case 'fork':
            return [1 => ['🧗', 'The narrow ledge', 'Nimble ' . trek_signed(trek_best_mod($run, $u, 'nimble')), false],
                    2 => ['🪨', 'The wet crawl', 'Hardy ' . trek_signed(trek_best_mod($run, $u, 'hardiness')), false]];
        case 'trader':
            $price = trek_trader_price();
            $full = (int)$run['campkits'] >= max(0, (int)setting('trek_campkit_max'));
            $poor = (int)$run['petals_found'] < $price;
            return [1 => ['🏕️', 'Buy a Camp Kit', $price . ' ' . setting('currency_name') . ' carried' . ($full ? ' · kits full' : ($poor ? ' · not enough' : '')), $full || $poor]];
        case 'shrine':
            return [1 => ['🕯️', 'Rest a while', 'heal a quarter', false], 2 => ['🙏', 'Say thanks', '+1 in the next fight', false]];
        case 'puddle':
            return [1 => ['✨', 'Sip it', 'may heal, may sting', false]];
        case 'beetle':
            $c = [1 => ['🩹', 'Patch it up', 'tiring · a little trek XP', false]];
            $b = trek_bloomcaller($run, $u);
            if ($b) $c[2] = ['🌸', $b[1] . ' heals it', 'a small reward', false];
            return $c;
        case 'song':
            return [1 => ['🎶', 'Hum along', 'rest a little', false]];
        case 'handprints':
            return [1 => ['🖐️', 'Press your hand to them', '+1 in the next fight', false], 2 => ['✏️', 'Trace them', 'a little trek XP', false]];
        case 'pot':
            return [1 => ['🤲', 'Catch it', 'Nimble ' . trek_signed(trek_best_mod($run, $u, 'nimble')), false]];
        case 'echo':
            return [1 => ['🤫', 'Whisper a thank-you', 'rest a little', false]];
        case 'moth':
            return [1 => ['🦋', 'Follow it', 'lights the fog nearby', false]];
        case 'kettle':
            return [1 => ['🫖', 'Warm it up and share', 'heal a fifth · rest a little', false]];
        case 'drumbeat':
            return [1 => ['👂', 'Count the beats', 'Sense ' . trek_signed(trek_best_mod($run, $u, 'sense')), false]];
    }
    return [];
}

/** Pick a trail event for this tile: not the last one, and only ones that can matter. null if none. */
function trek_ev_pick(array &$run, array $u, string $zone = ''): ?string
{
    $ids = array_keys(TREK_EVENTS);
    $last = (string)($run['st']['ev_last'] ?? '');
    $ids = array_values(array_filter($ids, function (string $id) use ($run, $last, $zone) {
        if ($id === $last) return false;
        if (isset(TREK_EVENT_CH[$id]) && !in_array((int)$run['chapter'], TREK_EVENT_CH[$id], true)) return false;
        if (isset(TREK_EVENT_ZONES[$id]) && !in_array($zone, TREK_EVENT_ZONES[$id], true)) return false;   // v1.9.4
        if ($id === 'trader') return (int)$run['campkits'] < max(0, (int)setting('trek_campkit_max')) && (int)$run['petals_found'] >= trek_trader_price();
        return true;
    }));
    return $ids ? $ids[random_int(0, count($ids) - 1)] : null;
}

/**
 * Called for every step onto a plain tile (no spot) when the walk is not about to stop for a fight: counts the step, and maybe stops the walk
 * with a crew moment or a trail event. No events in a fight, before the first fight is won, or too soon after the last one. Returns true if it stopped.
 */
function trek_step_extras(array &$run, array $u, string $zone): bool
{
    $run['st']['ev_steps'] = (int)($run['st']['ev_steps'] ?? 0) + 1;
    if ($run['fi'] || !trek_flag($run, 'won_fight')) return false;
    $cmLive = !empty($run['st']['cm']) && trek_in_party($run, (string)$run['st']['cm']);   // v1.9.9: a moment whose trailmate was swapped out is hidden: it must not hold back the trail events (nor a new moment)
    $k = (string)($run['st']['cm_next'] ?? '');
    if ($k !== '') {
        unset($run['st']['cm_next']);
        if (!$cmLive && empty($run['st']['ev']) && trek_is_recruit($run, $k) && !trek_flag($run, 'cm_' . $k) && trek_in_party($run, $k)) {
            trek_flag_set($run, 'cm_' . $k);   // once per recruit per run, whether or not the task is taken
            $run['st']['cm'] = $k;
            $run['st']['ev_steps'] = 0;
            return true;
        }
    }
    $pct = max(0, min(100, (int)setting('trek_event_pct')));
    if ($pct <= 0 || (int)$run['st']['ev_steps'] < max(1, (int)setting('trek_event_gap')) || $cmLive) return false;
    if (trek_roll(10000) > $pct * 100) return false;
    $id = trek_ev_pick($run, $u, $zone);
    if (!$id) return false;
    $run['st']['ev'] = ['id' => $id];
    $run['st']['ev_last'] = $id;
    $run['st']['ev_steps'] = 0;
    return true;
}

/** v1.9.2: is this trailmate one of the recruits of this run (freed in this chapter, or carried over from the one before)? */
function trek_is_recruit(array $run, string $crewKey): bool
{
    return trek_flag($run, 'freed_' . $crewKey) || in_array($crewKey, trek_recruits((int)$run['id']), true);
}

function trek_in_party(array $run, string $crewKey): bool
{
    foreach ($run['party'] as $p) if ($p['crew_key'] === $crewKey) return true;
    return false;
}

/** Take the pending event's choice (0 = walk on). The event is cleared before anything is paid, inside the run lock, so a second tap finds nothing. */
function trek_act_event(array &$run, array $u, int $c): array
{
    $ev = $run['st']['ev'] ?? null;
    if (!is_array($ev) || $run['fi'] || !isset(TREK_EVENTS[(string)($ev['id'] ?? '')])) return [false, 'Nothing to decide here.'];
    $id = (string)$ev['id'];
    $ch = (int)$run['chapter'];
    $choices = trek_ev_choices($run, $u, $id);
    if ($c !== 0 && !isset($choices[$c])) return [false, 'Pick one of the choices.'];
    if ($c !== 0 && $choices[$c][3]) return [false, $id === 'trader' ? 'You can’t buy a Camp Kit right now.' : 'Not now.'];
    unset($run['st']['ev']);
    $run['st']['evn'] = (int)($run['st']['evn'] ?? 0) + 1;   // v1.8.9: events resolved (a milestone check)
    $k = fn(string $part) => 'ch' . $ch . '.ev.' . $id . '.' . $part;
    if ($c === 0) { trek_say_text($run, 'ch' . $ch . '.ev.walkon'); return [true, '']; }
    switch ($id . ':' . $c) {
        case 'stash:1':
            trek_say_text($run, $k('dig'));
            trek_find_petals($run, random_int(6, 14));
            break;
        case 'forager:1':
            trek_say_text($run, $k('help'));
            trek_add_fatigue($run, 3);
            trek_say($run, '😮‍💨 It took a little while. Fatigue +3.');
            trek_find_xp($run, $u, 12);
            break;
        case 'fork:1':
        case 'fork:2':
            $mod = trek_best_mod($run, $u, $c === 1 ? 'nimble' : 'hardiness');
            if (trek_d20() + $mod >= 11) {
                trek_say_text($run, $k('win'));
                trek_add_fatigue($run, -10);
                trek_say($run, '😌 Fatigue −10.');
            } else {
                trek_say_text($run, $k('fail'));
                trek_add_fatigue($run, 4);
                trek_say($run, '😮‍💨 Fatigue +4.');
            }
            break;
        case 'trader:1':
            $price = trek_trader_price();
            $run['petals_found'] = (int)$run['petals_found'] - $price;
            $run['campkits'] = (int)$run['campkits'] + 1;
            trek_say_text($run, $k('buy'));
            trek_say($run, '🏕️ Camp Kit bought (−' . $price . ' ' . setting('currency_name') . ' carried).');
            break;
        case 'shrine:1':
            trek_say_text($run, $k('rest'));
            trek_heal_party($run, $u, 25);
            trek_say($run, '💚 Everyone heals a quarter of their health.');
            break;
        case 'shrine:2':
            trek_say_text($run, $k('bless'));
            $run['st']['bless'] = 1;
            trek_say($run, '🙏 +1 to hit and armour in the next fight.');
            break;
        case 'puddle:1':
            if (trek_roll(100) <= 60) {
                trek_say_text($run, $k('good'));
                trek_heal_party($run, $u, 30);
                trek_say($run, '💚 Everyone heals about a third.');
            } else {
                trek_say_text($run, $k('bad'));
                foreach (trek_party_stats($run, $u) as $slot => $m) {   // a sting, never a knock-out
                    $hp = (int)$run['party'][$slot]['hp'];
                    if ($hp > 1) $run['party'][$slot]['hp'] = max(1, $hp - (int)ceil($m['max'] * 0.10));
                }
                trek_add_fatigue($run, 2);
                trek_say($run, '🤢 Everyone loses a little health (never the last point). Fatigue +2.');
            }
            break;
        case 'beetle:1':
            trek_say_text($run, $k('patch'));
            trek_add_fatigue($run, 2);
            trek_say($run, '😮‍💨 Fatigue +2.');
            trek_find_xp($run, $u, 8);
            break;
        case 'beetle:2':
            $b = trek_bloomcaller($run, $u);
            trek_say_text($run, $k('heal'), ['trailmate' => $b ? $b[1] : 'Your bloomcaller']);
            trek_find_petals($run, random_int(8, 16));
            trek_find_xp($run, $u, 12);
            break;
        case 'song:1':
            trek_say_text($run, $k('hum'));
            trek_add_fatigue($run, -15);
            trek_say($run, '😌 Fatigue −15.');
            break;
        case 'handprints:1':
            trek_say_text($run, $k('press'));
            $run['st']['bless'] = 1;
            trek_say($run, '🙏 +1 to hit and armour in the next fight.');
            break;
        case 'handprints:2':
            trek_say_text($run, $k('trace'));
            trek_find_xp($run, $u, 10);
            break;
        case 'echo:1':
            trek_say_text($run, $k('whisper'));
            trek_add_fatigue($run, -8);
            trek_say($run, '😌 Fatigue −8.');
            break;
        case 'moth:1':
            trek_say_text($run, $k('follow'));
            trek_seen_reveal($run, (int)$run['x'], (int)$run['y'], 6);
            trek_say($run, '🦋 The fog lifts a little nearby.');
            break;
        case 'kettle:1':
            trek_say_text($run, $k('sip'));
            trek_heal_party($run, $u, 20);
            trek_add_fatigue($run, -5);
            trek_say($run, '💚 Everyone heals a fifth of their health. Fatigue −5.');
            break;
        case 'drumbeat:1':
            if (trek_d20() + trek_best_mod($run, $u, 'sense') >= 10) {
                trek_say_text($run, $k('listen'));
                $run['st']['bless'] = 1;
                trek_say($run, '🙏 +1 to hit and armour in the next fight.');
            } else {
                trek_say_text($run, $k('miss'));
                trek_add_fatigue($run, 2);
                trek_say($run, '😮‍💨 Fatigue +2.');
            }
            break;
        case 'pot:1':
            if (trek_d20() + trek_best_mod($run, $u, 'nimble') >= 10) {
                trek_say_text($run, $k('catch'));
                trek_find_petals($run, random_int(8, 16));
            } else {
                trek_say_text($run, $k('miss'));
                trek_add_fatigue($run, 2);
                trek_say($run, '😮‍💨 Fatigue +2.');
            }
            break;
        default:
            return [false, 'Nothing to decide here.'];
    }
    return [true, ''];
}

// ------------------------------------------------------------------ crew moments

/** Once per walk: counts the walk for every recruit whose moment has not happened, and decides whether one falls on this walk (the 2nd to 4th after they joined). */
function trek_crew_walk(array &$run): void
{
    unset($run['st']['cm_next']);
    $have = trek_recruits((int)$run['id']);   // v1.9.2: a mate carried into this chapter has no freed_ flag here, but is in the recruits table
    foreach (array_keys(TREK_CREW_BEATS) as $k) {
        if ((!trek_flag($run, 'freed_' . $k) && !in_array($k, $have, true)) || trek_flag($run, 'cm_' . $k)) continue;
        $w = (int)($run['st']['cmw'][$k] ?? 0) + 1;
        $run['st']['cmw'][$k] = $w;
        if (!isset($run['st']['cm_next']) && $w >= 2 && ($w >= 4 || trek_roll(100) <= 50)) $run['st']['cm_next'] = $k;
    }
}

/** The trailmate's tiny task (0 = not now). Only while they are in the party and the moment is pending; clears before it pays. */
function trek_act_crew(array &$run, array $u, int $c): array
{
    $k = (string)($run['st']['cm'] ?? '');
    if ($k === '' || $run['fi'] || !isset(TREK_CREW_BEATS[$k])) return [false, 'Nothing to do here.'];
    if ($c === 0) { unset($run['st']['cm']); return [true, '']; }
    if (!trek_in_party($run, $k)) return [false, trek_crew_npc($k)['name'] . ' isn’t in your party right now.'];
    unset($run['st']['cm']);
    trek_flag_set($run, 'cmt_' . $k);   // v1.8.9: the moment was taken (a milestone check)
    $ch = (int)$run['chapter'];
    $name = trek_first_name_of((string)trek_crew_npc($k)['name']);
    trek_say_text($run, 'ch' . $ch . '.crew.' . $k . '.done', ['trailmate' => $name]);
    if ($k === 'burdock') {
        trek_find_petals($run, random_int(10, 18));
    } elseif ($k === 'zinnia') {
        trek_heal_party($run, $u, 20);
        trek_say($run, '💚 Everyone heals a fifth of their health.');
    } elseif ($k === 'juniper') {   // v1.9.4: a hot snack for the road
        trek_heal_party($run, $u, 25);
        trek_add_fatigue($run, -4);
        trek_say($run, '💚 Everyone heals a quarter of their health. Fatigue −4.');
    } elseif ($k === 'wren') {   // v2.0.20: she coaxes the glowcaps to shine on the party: the shrine’s blessing, +1 to hit and armour until the next fight ends
        $run['st']['bless'] = 1;
        trek_say($run, '🌟 The glowcaps shine on you. +1 to hit and armour until the next fight ends.');
    } elseif ($k === 'tumble') {   // v2.0.15: Tumble's own: he reads the signs and finds an easier way (fatigue -6)
        trek_add_fatigue($run, -6);
        trek_say($run, '🧭 Tumble reads the signs and finds an easier way. Fatigue −6.');
    } elseif ($k === 'sorrel') {   // v1.9.2: she inks a map: the fog lifts around the next goal
        $obj = trek_objective($run);
        trek_seen_reveal($run, (int)$run['x'], (int)$run['y'], 4);
        if ($obj) {
            trek_seen_reveal($run, $obj['x'], $obj['y'], 3);
            trek_say($run, '🗺️ The little map shows the way. Next: ' . $obj['name'] . ', ' . trek_compass($run, $obj) . '.');
        } else {
            trek_say($run, '🗺️ The little map fills in the fog nearby.');
        }
    } else {
        trek_seen_reveal($run, (int)$run['x'], (int)$run['y'], 6);
        $obj = trek_objective($run);
        if ($obj) {
            trek_seen_reveal($run, $obj['x'], $obj['y'], 1);
            trek_say($run, '🔭 The fog lifts nearby. Next: ' . $obj['name'] . ', ' . trek_compass($run, $obj) . '.');
        } else {
            trek_say($run, '🔭 The fog lifts nearby.');
        }
    }
    return [true, ''];
}

/** Where a spot is, as an arrow and a distance. */
function trek_compass(array $run, array $spot): string
{
    $dx = $spot['x'] - (int)$run['x'];
    $dy = $spot['y'] - (int)$run['y'];
    $arrows = ['↖️', '⬆️', '↗️', '⬅️', '📍', '➡️', '↙️', '⬇️', '↘️'];
    $a = $arrows[(($dy > 0) - ($dy < 0) + 1) * 3 + (($dx > 0) - ($dx < 0) + 1)];
    $n = abs($dx) + abs($dy);
    return $n === 0 ? '📍 You are standing on it' : $a . ' ' . $n . ($n === 1 ? ' step away' : ' steps away');
}

// ------------------------------------------------------------------ the side stops

/** The Stuck Cart: heave it free (a Grit check by the best of the party) or dig it out slowly (tiring, always works). Either gives the cart's Camp Kit, once. */
function trek_act_cart(array &$run, array $u, string $how): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'cart' || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    $ch = (int)$run['chapter'];
    $k = fn(string $part) => 'ch' . $ch . '.spot.' . $s['code'] . '.' . $part;
    if ($how === 'heave') {
        if (trek_d20() + trek_best_mod($run, $u, 'grit') < (int)($s['data']['dc'] ?? 11)) {
            trek_say_text($run, $k('fail'));
            trek_add_fatigue($run, 3);
            trek_say($run, '😮‍💨 Fatigue +3. You can try again, or dig it out slowly.');
            return [true, ''];
        }
        trek_say_text($run, $k('win'));
    } elseif ($how === 'work') {
        trek_say_text($run, $k('work'));
        trek_add_fatigue($run, 8);
        trek_say($run, '😮‍💨 Fatigue +8.');
    } else {
        return [false, 'Pick a way.'];
    }
    trek_flag_set($run, (string)$s['data']['flag']);
    [$slug, $qty] = array_pad(explode(':', (string)($s['data']['item'] ?? 'camp-kit:1'), 2), 2, '1');
    if ($slug === 'camp-kit') trek_say($run, trek_give_kits($run, $u, (int)$qty));
    return [true, ''];
}

/** The Mushroom Camp's side job: hand over the shells from the trail (carried ones) for Petals and a jar of honeydew, once. */
function trek_act_mush(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'mush' || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    $ch = (int)$run['chapter'];
    [$slug, $qty] = array_pad(explode(':', (string)$s['data']['need'], 2), 2, '1');
    $iid = trek_item_id($slug);
    if (!$iid || trek_pack_qty((int)$run['id'], $iid) < (int)$qty) {
        trek_say_text($run, 'ch' . $ch . '.spot.' . $s['code'] . '.short');
        return [false, 'You need ' . (int)$qty . ' × ' . trek_item_name($iid) . ' in your pack.'];
    }
    trek_pack_take((int)$run['id'], $iid, (int)$qty);
    trek_flag_set($run, (string)$s['data']['flag']);
    trek_say_text($run, 'ch' . $ch . '.spot.' . $s['code'] . '.done');
    trek_find_petals($run, (int)($s['data']['petals'] ?? 30));
    $hid = trek_item_id('honeydew');
    if ($hid) { trek_pack_add((int)$run['id'], $hid, 1); trek_say($run, '🎁 You receive 1 × ' . trek_item_name($hid) . ' (carried).'); }
    return [true, ''];
}
