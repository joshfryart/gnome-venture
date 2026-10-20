<?php
/**
 * v2.0.1: old campsites. A spot type (oldcamp) on the Chapter I and II maps: a free, repeatable rest that is better than a cold rest and needs no kit,
 * with a smaller ambush chance. Fatigue -trek_oldcamp_fatigue, everyone heals half, no Petals, no XP, nothing found (no faucet).
 * With trek_oldcamp_checkpoint on, a knock-out after resting at one wakes you there instead of at the last camp, as long as it lies further along than that camp
 * (spots further down the map, larger y). Camps stay the real checkpoints: only a camp banks your finds and sells kits.
 * Everything here runs inside trek_tx (the caller holds the users-row lock); state is run['st']['oc'] (the code of the site) and the existing fatigue/party fields.
 */

function trek_oldcamp_fatigue(): int
{
    return max(0, min(100, (int)setting('trek_oldcamp_fatigue')));
}

function trek_oldcamp_ambush_pct(): int
{
    return max(0, min(100, (int)setting('trek_oldcamp_ambush_pct')));
}

/** The old campsite the party stands on, or null. */
function trek_here_oldcamp(array $run): ?array
{
    $s = trek_spot_at((int)$run['chapter'], (int)$run['x'], (int)$run['y']);
    return $s && $s['type'] === 'oldcamp' ? $s : null;
}

/** Is anybody hurt? */
function trek_party_hurt(array &$run, array $u): bool
{
    foreach (trek_party_stats($run, $u) as $s => $mm) if ((int)$run['party'][$s]['hp'] < (int)$mm['max']) return true;
    return false;
}

/** The rest itself: fatigue down, half health back. */
function trek_oldcamp_apply(array &$run, array $u): void
{
    $run['fatigue'] = max(0, (int)$run['fatigue'] - trek_oldcamp_fatigue());
    $run['st']['fh'] = 0;
    trek_heal_party($run, $u, 50);
}

/** The log lines of a finished old-campsite rest. */
function trek_apply_oldcamp_log(array &$run, int $n): void
{
    trek_say_text($run, 'ch' . $n . '.oldcamp.rest');
    trek_say($run, '⛺ An old campsite rest. Fatigue −' . trek_oldcamp_fatigue() . ', everyone heals half their health.');
}

/** After an ambush at an old campsite is won: the rest the party came for (called by the fight code for after = oldrest). */
function trek_oldcamp_after_fight(array &$run, array $u, int $n): void
{
    trek_oldcamp_apply($run, $u);
    trek_apply_oldcamp_log($run, $n);
}

/** The site a knock-out wakes you at (checkpoint on, a site rested at that lies further along than the last camp), or null. */
function trek_oldcamp_ko_spot(array $run): ?array
{
    if ((int)setting('trek_oldcamp_checkpoint') !== 1) return null;
    $code = (string)($run['st']['oc'] ?? '');
    if ($code === '') return null;
    $spots = trek_spots((int)$run['chapter']);
    $s = $spots[$code] ?? null;
    if (!$s || $s['type'] !== 'oldcamp') return null;
    $camp = ($run['camp'] && isset($spots[$run['camp']])) ? $spots[$run['camp']] : null;
    return (!$camp || $s['y'] > $camp['y']) ? $s : null;
}

/** Remember this site as the fallback, unless one further along is already remembered. */
function trek_oldcamp_mark(array &$run, array $s): void
{
    $cur = trek_spots((int)$run['chapter'])[(string)($run['st']['oc'] ?? '')] ?? null;
    if (!$cur || $cur['type'] !== 'oldcamp' || $s['y'] >= $cur['y']) $run['st']['oc'] = $s['code'];
}

/** Rest at the old campsite you are standing on (again and again). [ok, message] */
function trek_act_oldcamp(array &$run, array $u): array
{
    $s = trek_here_oldcamp($run);
    if (!$s || $run['fi'] || !(int)$run['inside']) return [false, 'Nothing to do here.'];
    $n = (int)$run['chapter'];
    trek_oldcamp_mark($run, $s);
    if ((int)$run['fatigue'] <= 0 && !trek_party_hurt($run, $u)) {   // nothing to mend: no rest, no ambush roll, no faucet (a second tap lands here too)
        return [false, 'Everyone is rested already.' . ((int)setting('trek_oldcamp_checkpoint') === 1 ? ' This spot is marked: if you fall, you wake here.' : '')];
    }
    $zone = trek_zone_at($n, (int)$run['x'], (int)$run['y']);
    $pool = trek_zone_pool($zone, $n);
    if (random_int(1, 100) <= trek_oldcamp_ambush_pct() && $pool && $pool['list']) {
        trek_say_text($run, 'ch' . $n . '.oldcamp.ambush');
        trek_start_random_fight($run, $u, $zone, 'oldrest');
        return [true, ''];
    }
    trek_oldcamp_apply($run, $u);
    trek_apply_oldcamp_log($run, $n);
    return [true, ''];
}

/** The card of an old campsite: its text, the rest button and a plain line on what it does. */
function trek_oldcamp_panel(array $run, array $spot, string $textKey): string
{
    $fat = trek_oldcamp_fatigue();
    $amb = trek_oldcamp_ambush_pct();
    $h = '<div class="trektext">' . trek_text($textKey) . '</div>'
        . '<div class="trekbtns trekone">' . trek_form('rest_old', '⛺ Rest here (free)', ['t' => 'map']) . '</div>'
        . '<p class="help">No kit needed. Fatigue −' . $fat . ', everyone heals half' . ($amb > 0 ? '. A small chance of an ambush.' : '.') . '</p>';
    if ((int)setting('trek_oldcamp_checkpoint') === 1) {
        $here = ($run['st']['oc'] ?? '') === $spot['code'];
        $h .= '<p class="help">' . ($here ? 'If you fall, you wake up here.' : 'Rest here and, if you fall, you wake up here instead of far back at a camp.') . ' Only a camp banks your finds.</p>';
    }
    return $h;
}
