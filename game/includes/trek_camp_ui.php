<?php
// v2.0.11: the Treks camp pop-over. One server-built <dialog class="tkcamp"> on the Map tab (never in a fight, never in the interlude hub, which has its own
// talk list). Opened by the 🏕️ Camp button, and by itself when the party reaches a camp tile or after an action inside it. assets/trekcamp.js does the
// opening and the Talk bubble; every button inside is an ordinary POST to the existing actions (rest, makecamp, buy_kit, party), so the rules did not change.

/** After a camp action (or a walk onto a camp tile) the next Map render opens the pop-over once. $why = 'arrive' (can be switched off) or 'again'. */
function trek_camp_open_note(array $run, string $why): void
{
    $_SESSION['trek_camp_open'] = ['run' => (int)$run['id'], 't' => time(), 'why' => $why];
}

/** Taken (and cleared) on every call: '', 'arrive' or 'again'. Fresh for 30 s, this run only. */
function trek_camp_open_take(array $run): string
{
    $a = $_SESSION['trek_camp_open'] ?? null;
    unset($_SESSION['trek_camp_open']);
    if (!is_array($a) || (int)($a['run'] ?? 0) !== (int)$run['id'] || time() - (int)($a['t'] ?? 0) > 30) return '';
    return ($a['why'] ?? '') === 'arrive' ? 'arrive' : 'again';
}

/** What a trailmate can say at camp: the banter slots (1-4, as many as are written), then a bit about them. Plain strings. */
function trek_camp_talk_lines(array $run, array $u, string $crewKey): array
{
    $npc = trek_crew_npc($crewKey);
    $vars = ['trailmate' => (string)$npc['name']];
    $out = [];
    for ($n = 1; $n <= 4; $n++) {
        $t = trek_scene_plain('ch' . (int)$run['chapter'] . '.banter.' . $crewKey . '.' . $n, $vars, $u);
        if ($t !== '') $out[] = $t;
    }
    $bio = trim((string)($npc['bio'] ?? ''));
    if ($bio !== '') $out[] = mb_strlen($bio) > 240 ? mb_substr($bio, 0, 237) . '…' : $bio;
    return $out;
}

/** One action as a choice row in its own POST form. */
function trek_camp_choice(string $do, string $icon, string $title, string $sub, array $extra = [], string $cls = ''): string
{
    $h = '';
    foreach ($extra as $k => $v) $h .= '<input type="hidden" name="' . e($k) . '" value="' . e((string)$v) . '">';
    return '<form method="post" class="choiceform tkcform">' . csrf_field() . '<input type="hidden" name="do" value="' . e($do) . '"><input type="hidden" name="t" value="map">' . $h
        . choice_row($icon, $title, $sub, '', $cls, 'type="submit"') . '</form>';
}

/** v2.0.18: the free rest spot (Chapter II's Cushion Corner) the party stands on while it is still unused, or null. */
function trek_here_restspot(array $run): ?array
{
    $s = trek_spot_at((int)$run['chapter'], (int)$run['x'], (int)$run['y']);
    return $s && $s['type'] === 'rest' && !trek_spot_done($run, $s) ? $s : null;
}

/** The whole pop-over. $party = trek_party_stats(). $auto = '' | 'arrive' | 'again' (what opens it by itself). */
function trek_camp_dialog_html(array &$run, array $u, array $party, string $auto): string
{
    $ch = (int)$run['chapter'];
    $camp = trek_here_camp($run);
    $oc = $camp ? null : trek_here_oldcamp($run);   // v2.0.18: old campsites and the Cushion Corner get the pop-over too, with their own free rest
    $rs = $camp || $oc ? null : trek_here_restspot($run);
    $fat = (int)$run['fatigue'];
    $kits = (int)$run['campkits'];
    $kitMax = max(0, (int)setting('trek_campkit_max'));
    $cur = (string)setting('currency_name');
    $hurt = false;
    foreach ($party as $m) if ((int)$m['hp'] < (int)$m['max']) $hurt = true;

    $h = '<dialog class="tkcamp" aria-labelledby="tkcname"' . ($auto !== '' ? ' data-auto="' . e($auto) . '"' : '') . '><div class="tkccard">';
    $h .= '<h3 id="tkcname">🏕️ ' . e($camp ? (string)$camp['name'] : ($oc ? (string)$oc['name'] : ($rs ? (string)$rs['name'] : 'Make camp'))) . '</h3>';
    $greet = $camp ? trek_scene_plain(trek_camp_key($ch, $camp, 'greet'), [], $u) : '';
    if ($greet !== '' && mb_strlen($greet) <= 220) $h .= '<p class="tkcgreet">' . e($greet) . '</p>';
    $h .= '<div class="tkcchips"><span class="chip fat">😮‍💨 Fatigue ' . $fat . '/100</span><span class="chip">🏕️ ' . $kits . '/' . $kitMax . ' kits</span></div>';

    // the party: health, and a Talk button for each trailmate
    $h .= '<ul class="tkcparty">';
    foreach ($party as $m) {
        $hp = (int)$m['hp'];
        $lines = (int)$m['slot'] === 0 ? [] : trek_camp_talk_lines($run, $u, (string)$m['key']);
        $h .= '<li class="tkcmem' . ($hp <= 0 ? ' down' : '') . '"><span class="tkcico" aria-hidden="true">' . $m['ico'] . '</span>'
            . '<span class="tkcwho"><b>' . e(trek_first_name_of((string)$m['name'])) . '</b><small>' . e((int)$m['slot'] === 0 ? 'You' : (CALLINGS[$m['calling']][0] ?? '')) . '</small></span>'
            . '<span class="tkchp">' . trek_camp_bar($hp, (int)$m["max"]) . '<small>' . $hp . '/' . (int)$m['max'] . '</small></span>'
            . ($lines ? '<button type="button" class="btn alt small tkctalkbtn" data-tkcamp-talk data-who="' . e(trek_first_name_of((string)$m['name'])) . '" data-lines="' . e((string)json_encode($lines, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)) . '" aria-label="Talk to ' . e(trek_first_name_of((string)$m['name'])) . '">💬 Talk</button>' : '<span class="tkcnotalk"></span>')
            . '</li>';
    }
    $h .= '</ul><div class="tkctalk" data-tkcamp-bubble hidden aria-live="polite"><b></b><p></p><small></small></div>';

    // rest
    $h .= '<div class="tkcblock"><b class="tkchead">Rest</b><div class="choicelist">';
    if ($camp) {
        $h .= trek_camp_choice('rest', '🛌', 'Rest and bank', 'Free. Everyone heals, fatigue to 0, finds go to your satchel');
    } elseif ($oc && ($fat > 0 || $hurt)) {
        $h .= trek_camp_choice('rest_old', '⛺', 'Rest here (free)', 'No kit needed. Fatigue −' . trek_oldcamp_fatigue() . ', everyone heals half. Finds are not banked');
    } elseif ($rs) {
        $h .= trek_camp_choice('rest_spot', '🛋️', 'Sit a while (free rest)', 'Free, once');
    } elseif ($fat <= 0 && !$hurt) {
        $h .= '<p class="help tkcnote">Everyone is rested already.</p>';
    } elseif ($kits > 0) {
        $h .= trek_camp_choice('makecamp', '🏕️', 'Use a Camp Kit', 'Fatigue −50, everyone heals half their health');
    } else {
        $h .= trek_camp_choice('makecamp', '🌙', 'Cold rest', 'Free: fatigue −' . trek_cold_rest_fatigue() . ', heal a quarter. ' . max(0, (int)setting('trek_ambush_pct')) . '% chance of an ambush first');
    }
    $h .= '</div></div>';

    // camp only: the kit shop and the party swap
    if ($camp) {
        $price = max(0, (int)setting('trek_campkit_price'));
        if ($kits < $kitMax) $h .= '<div class="tkcblock"><b class="tkchead">Supplies</b><div class="choicelist">'
            . trek_camp_choice('buy_kit', '🛒', 'Buy a Camp Kit', $price . ' ' . $cur . ' · you carry ' . $kits . '/' . $kitMax) . '</div></div>';
        $recruits = trek_recruits((int)$run['id']);
        if ($recruits) {
            $inParty = [];
            foreach ($party as $m) if ((int)$m['slot'] > 0) $inParty[] = (string)$m['key'];
            $full = count($inParty) >= 3;
            $h .= '<div class="tkcblock"><b class="tkchead">Trailmates</b><div class="choicelist">';
            foreach ($recruits as $rk) {
                $name = trek_first_name_of((string)trek_crew_npc($rk)['name']);
                $ico = TREK_CREW_ICONS[trek_crew()[$rk]['calling'] ?? ''] ?? '🧑';
                $cl = CALLINGS[trek_crew()[$rk]['calling'] ?? ''][0] ?? '';
                if (in_array($rk, $inParty, true)) {
                    $want = array_values(array_diff($inParty, [$rk]));
                    $row = ['p1' => $want[0] ?? '', 'p2' => $want[1] ?? '', 'p3' => $want[2] ?? ''];
                    $h .= trek_camp_choice('party', $ico, $name . ': rest here', $cl . ' · in your party now', $row);
                } elseif (!$full) {
                    $want = array_merge($inParty, [$rk]);
                    $h .= trek_camp_choice('party', $ico, $name . ': bring along', $cl . ' · waiting at camp', ['p1' => $want[0] ?? '', 'p2' => $want[1] ?? '', 'p3' => $want[2] ?? '']);
                } else {
                    $h .= choice_row($ico, $name . ': waiting', $cl . ' · party full, send someone to rest first', '', '', 'type="button" disabled');
                }
            }
            $h .= '</div></div>';
        }
    }

    $h .= '<div class="tkcfoot"><label class="tkcauto"><input type="checkbox" data-tkcamp-auto checked> Open this when I reach a camp</label>'
        . '<button type="button" class="btn tkcclose" data-tkcamp-close>Close</button></div>';
    return $h . '</div></dialog>';
}

/** A health bar (same markup as the page's trek_bar, which lives in trek.php and so is not there for tests). */
function trek_camp_bar(int $v, int $max): string
{
    return '<progress max="' . max(1, $max) . '" value="' . max(0, min($max, $v)) . '"></progress>';
}
