<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 3: what the Today page shows for "together and coming back": the welcome-back call, Wren's First Week card,
 * the Hollow jar, the gentle daily card and the Pulse strip. Two calls from index.php:
 *   today_social_prepare($u)  before page_header (pays jar tiers: the prize pop-up needs to be queued first)
 *   today_social_html($u)     where the cards go
 */

function today_social_prepare(array $u): void
{
    require_once __DIR__ . '/hollow_goals.php';
    social_boot();
    hollow_goal_settle_flash((int)$u['id']);
}

/** The welcome-back call, which goes right under the greeting. */
function today_social_top(array $u): string
{
    require_once __DIR__ . '/welcome_back.php';
    require_once __DIR__ . '/tour.php';
    return (welcome_back_due($u) && helper_slot($u) === 'back') ? '<a class="box notice wbcall" href="' . e(url('back.php')) . '"><b>👋 Welcome back!</b> See what grew and what happened while you were away. <span class="tgo">Open →</span></a>' : '';
}

/** The one compact "Hollow today" box that goes under the main Today grid. */   // v1.0.2
/** v1.2.0: $part 'home' = First Week + daily card only (Home tab); 'hollow' = jars + Pulse (Hollow tab); 'all' = everything. */
function today_social_html(array $u, string $part = 'all'): string
{
    require_once __DIR__ . '/hollow_goals.php';
    require_once __DIR__ . '/first_week.php';
    require_once __DIR__ . '/welcome_back.php';
    require_once __DIR__ . '/festival.php';
    require_once __DIR__ . '/tour.php';
    $uid = (int)$u['id'];
    $slot = helper_slot($u);   // one extra helper per load, after the tour
    $rows = '';
    // Jars: one row each (Hollow + festival)
    foreach ($part === 'home' ? [] : hollow_goals_active() as $g) {
        $st = hollow_goal_state($g);
        $fest = !empty($g['festival']);
        $pct = max(0, min(100, (int)$st['pct']));
        $rows .= '<a class="htrow htjar' . ($fest ? ' festjar' : '') . '" href="' . e(url($fest ? 'festival.php' : 'community.php?t=jar')) . '" title="' . e($g['title']) . '">'
            . '<span class="hti">' . e($g['icon']) . '</span><span class="htn">' . ($fest ? 'Festival' : 'Hollow jar') . '</span>'
            . '<progress max="' . (int)$st['target'] . '" value="' . (int)$st['total'] . '" aria-label="Jar progress"></progress><span class="htp">' . $pct . '%</span></a>';
    }
    // First Week: one line while active
    if ($part !== 'hollow' && $slot === 'fw' && ($fw = first_week_today_card($uid))) {
        $nDone = count(array_filter($fw['tasks'], fn($t) => $t[4]));
        $rows .= '<div class="htrow htfw"><span class="hti">🐦</span><span class="htt">First Week · day ' . (int)$fw['day'] . ': ' . $nDone . ' of ' . count($fw['tasks']) . ' done'
            . ($fw['done'] ? ' · <b>🎁 ready!</b>' : '') . '</span><a class="tgo" href="' . e(url('firstweek.php')) . '">' . ($fw['done'] ? 'Reward →' : 'All the cards →') . '</a></div>';
    }
    // The gentle daily card: one line
    if ($part !== 'hollow' && $slot === 'daily' && ($dc = daily_card($u))) {
        if ($dc['done']) {
            $rows .= '<div class="htrow htdaily done"><span class="hti">🌤️</span><span class="htt">' . e($dc['closer']) . '</span></div>';
        } else {
            $rows .= '<div class="htrow htdaily"><span class="hti">' . e($dc['icon']) . '</span><span class="htt">' . e($dc['text']) . '</span>'
                . '<span class="htacts"><a class="btn small" href="' . e(url($dc['link'])) . '">' . e($dc['label']) . '</a>'
                . '<form method="post" action="' . e(url('daily.php')) . '" class="inline">' . csrf_field() . '<button class="linkbtn" title="No need to do it. Just tuck the day in. No streaks.">✔ Enough for today</button></form></span></div>';
        }
    }
    if ($part === 'home') {
        // v1.7.1: the jar and the Pulse are one line on Home; the full views live on the Hollow tab and hollow.php
        $bits = [];
        foreach (hollow_goals_active() as $g) {
            $st = hollow_goal_state($g);
            $bits[] = e($g['icon']) . (!empty($g['festival']) ? ' ' : ' Hollow jar ') . max(0, min(100, (int)$st['pct'])) . '%';
        }
        $n = (int)hollow_pulse($u)['about']['n'];
        $bits[] = '👥 ' . ($n > 0 ? $n . ' about' : 'just you');
        $line = '<a class="htrow htline" href="' . e(url('community.php?t=jar')) . '"><span class="htt">' . implode(' · ', $bits) . '</span><span class="tgo">Open →</span></a>';
        return '<div class="box hollowtoday">' . $line . $rows . '</div>';
    }
    // Pulse: who is about + at most 2 news lines
    $p = hollow_pulse($u);
    $a = $p['about'];
    $who = [];
    $shown = array_slice($a['names'], 0, 3);   // v1.2.0: a few names, then "N more" (keeps the line short on a phone)
    foreach ($shown as [$id, $name]) $who[] = '<a href="' . e(url('profile.php?id=' . $id)) . '">' . e($name) . '</a>';
    $more = (count($a['names']) - count($shown)) + $a['quiet'];
    if (count($a['names']) > 3) { if ($more > 0) $who[] = $more . ' more'; }
    elseif ($a['quiet'] > 0) $who[] = $a['quiet'] . ' quiet';
    $pulse = '<p class="htabout"><span class="pdot" aria-hidden="true"></span> ' . ($a['n'] > 0 ? '<b>About:</b> ' . implode(', ', $who) . ' + you' : '<b>Just you about.</b> Townsfolk keep you company.') . '</p>';
    $items = [];
    foreach ($p['news'] as [$ic, $tx, $utc]) $items[] = '<li><span>' . $ic . '</span> ' . e($tx) . ' <small class="muted">' . e(pulse_ago($utc)) . '</small></li>';
    foreach ($p['folk'] as $f) $items[] = '<li>🏡 ' . e($f) . '</li>';
    $items = array_slice($items, 0, 2);
    if ($items) $pulse .= '<ul class="htnews">' . implode('', $items) . '</ul>';
    return '<div class="box hollowtoday"><h3>🫙 The Hollow today</h3>' . $rows . '<div class="htpulse">' . $pulse
        . '<a class="tgo" href="' . e(url('community.php?t=jar')) . '">The Hollow jar →</a></div></div>';
}
