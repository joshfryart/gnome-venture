<?php
declare(strict_types=1);

/**
 * The Today part of the home page (moved out of index.php so gnome.php can show it as its TODAY tab). Two calls:
 *   today_prepare($u)          BEFORE page_header: refreshes energy and pays Hollow jar tiers (the prize pop-up must be queued
 *                              before the page starts), and gathers the garden, jobs and town numbers. Returns the context.
 *   today_html($u, $ctx, $o)   where the cards go. today_head_html($u, $ctx) is the greeting header.
 * Only one of index.php?news=all and gnome.php?tab=today draws it per request (helper_slot() is memoised per request).
 */

function today_prepare(array $u, bool $allNews = false): array
{
    require_once __DIR__ . '/garden_logic.php';
    require_once __DIR__ . '/world.php';
    require_once __DIR__ . '/town.php';
    require_once __DIR__ . '/journey.php';
    require_once __DIR__ . '/adventure.php';
    refresh_energy($u);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
    $uid = (int)$u['id'];
    require_once __DIR__ . '/today_social.php'; today_social_prepare($u);   // v1.0.0 wave 3: pays Hollow jar tiers before the page starts
    $c = ['u' => $u, 'allNews' => $allNews];
    $c['news'] = q('SELECT title, body, created_at FROM news WHERE published = 1 ORDER BY created_at DESC, id DESC LIMIT ' . ($allNews ? 200 : 5))->fetchAll();
    $c['freshNews'] = $c['news'] && strtotime($c['news'][0]['created_at'] . ' UTC') > time() - 3 * 86400;
    // Your garden at a glance
    [$c['plot'], $tiles, $plants] = load_plot($uid, true);
    $c['nThirsty'] = $c['nReady'] = $c['nGrowing'] = $c['nEmpty'] = 0;
    foreach ($tiles as $row) foreach ($row as $t) {
        if ($t['plant_id'] && isset($plants[(int)$t['plant_id']])) {
            $ti = tile_info($t, $plants[(int)$t['plant_id']]);
            if ($ti['ready']) $c['nReady']++; elseif ($ti['thirsty']) $c['nThirsty']++; else $c['nGrowing']++;
        } else {
            $c['nEmpty']++;
        }
    }
    // Your jobs
    $c['jobs'] = q("SELECT period, title, qty, progress, stages, stages_paid FROM user_jobs WHERE user_id = ? AND status = 'active' ORDER BY id", [$uid])->fetchAll();
    // The town square: things still to do today
    $c['town'] = town_for($u, false);
    $uses = town_uses_today($uid);
    $c['todo'] = 0;
    foreach (town_spots($c['town']) as $ts) {
        if (spot_closed($ts)) continue;
        if (journey_lock($uid, 'spot', (string)$ts['slug'])) continue;   // v0.7.66: closed for repairs
        foreach (town_actions((int)$ts['id']) as $ta) if ($ta['kind'] !== 'link' && (int)$ta['daily'] > 0 && ($uses[(int)$ta['id']] ?? 0) < (int)$ta['daily']) $c['todo']++;
    }
    // In a village there's no square: say what's on locally instead
    $c['node'] = player_node($u);
    $c['localHere'] = $c['node']['kind'] === 'village';
    $c['lline'] = $c['lcta'] = '';
    if ($c['localHere']) {
        require_once __DIR__ . '/local.php';
        [$c['lline'], $c['lcta']] = local_card($u, $c['node']);   // v1.0.0: rest stop types, slots, villagers
    }
    // Wren's tip: the next getting-started page you haven't read yet
    $c['guide'] = q_one("SELECT e.id, e.title, e.chapter FROM encyclopedia_entries e JOIN user_encyclopedia ue ON ue.entry_id = e.id AND ue.user_id = ?
                    WHERE e.chapter = 'General' AND ue.read_at IS NULL ORDER BY e.sort_order, e.id LIMIT 1", [$uid]);
    $hour = hollow_hour();
    $c['hello'] = $hour < 12 ? 'Good morning' : ($hour < 18 ? 'Good afternoon' : 'Good evening');
    return $c;
}

/** The greeting header: avatar, "Good morning, Name!", place, weather, tomorrow, boosts, trip and calling lines. $o['class'] adds classes, $o['px'] sizes the avatar. */
function today_head_html(array $u, array $c, array $o = []): string
{
    require_once __DIR__ . '/destination.php'; require_once __DIR__ . '/calling_view.php';
    $fc = hollow_forecast(hollow_user_region($u), 3);
    $fx = active_effects($u);
    $ds = dest_status($u);
    $h = '<div class="box todayhead' . (isset($o['class']) ? ' ' . e($o['class']) : '') . '">'
        . "\n  " . '<div class="tavatar">' . gnome_avatar_pals($u, (int)($o['px'] ?? 64)) . '</div>'
        . "\n  <div>\n    " . '<h1>' . e($c['hello']) . ', ' . e(gnome_name($u)) . '!</h1>'
        . "\n    " . '<p class="todayfx tline"><span>📍 ' . e(player_location($u)) . '</span> <span>' . hollow_chip(hollow_user_region($u), 'hollow') . '</span>'
        . ($fc ? ' <span class="muted">Tomorrow: ' . e($fc[1]['emoji'] . ' ' . $fc[1]['wlabel']) . '</span>' : '')
        . ($fx ? ' <a href="' . e(url('gnome.php?tab=stats#effects')) . '">✨ ' . implode(' ', array_map(fn($f) => e($f[0] . ' ' . $f[2]), array_slice($fx, 0, 2))) . (count($fx) > 2 ? ' +' . (count($fx) - 2) : '') . '</a>' : '') . '</p>'   // two boosts at most: the full list with times is on Stats
        . "\n    " . ($ds ? '<p class="todayfx"><a href="' . e(url('world.php#gopanel')) . '">🏁 Heading to ' . e(dest_name((int)$u['id'], $ds[0])) . ' · ' . (int)$ds[1] . ' stop' . ($ds[1] === 1 ? '' : 's') . ' left</a></p>' : '')
        . "\n    " . calling_today_line($u)
        . "\n  </div>\n</div>\n";
    return $h;
}

/**
 * The Today cards. $o: 'hollow' => 'full' (the Hollow today box) or 'line' (one line: jars, who is about, Open),
 * 'pals' => false to leave out the pals-home notice (the caller draws it).
 */
function today_html(array $u, array $c, array $o = []): string
{
    require_once __DIR__ . '/journey.php'; require_once __DIR__ . '/rebuild.php';
    require_once __DIR__ . '/first_week.php'; require_once __DIR__ . '/welcome_back.php'; require_once __DIR__ . '/festival.php';
    require_once __DIR__ . '/today_social.php';
    $uid = (int)$u['id'];
    $allNews = !empty($c['allNews']); $news = $c['news']; $plot = $c['plot']; $node = $c['node']; $localHere = $c['localHere']; $town = $c['town'];
    $slot = helper_slot($u);
    $jc = journey_current($u);
    $jst = $jc ? journey_status($u, $jc) : null;
    $nRepairs = count(repair_list($uid));
    $nOrders = setting('orders_on') === '1' ? orders_open_count($uid, $town) : 0;
    $next = next_region_suggestion($u);
    $trekOn = (int)($u['level'] ?? 0) >= (int)setting('trek_level') && (setting('trek_open') === '1' || ($u['role'] ?? '') === 'admin');
    $cards = [];   // each: [extra class, icon + title, status html, link label, href]
    // 1. the one helper card: welcome back > First Week > daily card > festival; the Almanac when nothing applies
    $slotHtml = '';
    if ($slot === 'back') {
        $cards[] = ['fwcard wbcard', '👋 Welcome back!', 'See what grew while you were away.', 'Open →', 'back.php'];
    } elseif ($slot === 'fw' && ($fw = first_week_today_card($uid))) {
        $nDone = count(array_filter($fw['tasks'], fn($t) => $t[4]));
        $cards[] = ['fwcard', '🐦 First Week', 'Day ' . (int)$fw['day'] . ': ' . $nDone . ' of ' . count($fw['tasks']) . ' done' . ($fw['done'] ? ' · <b>🎁 ready!</b>' : ''), $fw['done'] ? 'Reward →' : 'All the cards →', 'firstweek.php'];
    } elseif ($slot === 'daily' && ($dc = daily_card($u))) {
        if ($dc['done']) $cards[] = ["dailycard htdaily done", '🌤️ Today', e($dc['closer']), 'Your Almanac →', 'book.php'];
        else $slotHtml = '<div class="box tcard dailycard htdaily"><h3>' . e($dc['icon']) . ' Today</h3><p>' . e($dc['text']) . '</p><span class="tacts"><a class="btn small" href="' . e(url($dc['link'])) . '">' . e($dc['label']) . '</a>'
            . '<form method="post" action="' . e(url('daily.php')) . '" class="inline">' . csrf_field() . '<button class="linkbtn" title="No need to do it. Just tuck the day in. No streaks.">✔ Enough for today</button></form></span></div>';
    } elseif ($slot === 'fest' && ($fe = festival_active())) {
        $cards[] = ['festcard', e($fe['icon']) . ' ' . e($fe['name']), 'Day ' . (int)$fe['day'] . ' of ' . (int)$fe['days'] . '. The Hollow is celebrating.', 'To the festival →', 'festival.php'];
    } else {
        $cards[] = ['', '📖 Your Almanac', 'The book fills in as you play.', 'Open the book →', 'book.php'];
    }
    $gb = [];
    if ($c['nReady']) $gb[] = '<b>🧺 ' . $c['nReady'] . ' ready</b>';
    if ($c['nThirsty']) $gb[] = '<b>💧 ' . $c['nThirsty'] . ' thirsty</b>';
    if ($c['nGrowing']) $gb[] = '🌿 ' . $c['nGrowing'] . ' growing';
    if ($c['nEmpty']) $gb[] = '<span class="muted">⬜ ' . $c['nEmpty'] . ' empty</span>';
    $cards[] = ['', '🌱 ' . eu($plot['garden_name'] ?: 'Your garden'), implode(' · ', $gb) ?: 'Nothing planted yet.', 'Go to your garden →', 'garden.php'];
    if ($jc) {
        $jn = count(array_filter($jst['tasks'], fn($t) => $t[3])); $jr = journey_ready($u, $jst);
        $jh = journey_next_hint($u, $jc, $jst);
        $cards[] = ['', '🧭 Wren’s Journey', e((string)$jc['project_icon']) . ' <b>' . e($jc['region']) . '</b>: ' . $jn . ' of ' . count($jst['tasks']) . ' done' . ($jr === 'finish' ? ' · <b>✋ finish!</b>' : ($jr === 'stage' ? ' · <b>✋ hand in</b>' : '')) . ($jh ? '<span class="jhint muted">👉 ' . e($jh[0]) . '</span>' : ''), 'Your Journey →', 'book.php?ch=Journey&j=' . (int)$jc['id']];
    } else {
        $jl = journey_next_locked($u);
        $cards[] = ['', '🧭 Wren’s Journey', $jl ? 'Next: <b>' . e($jl['region']) . '</b> (level ' . (int)$jl['min_level'] . '). Starts when you walk there.' : 'Every chapter is finished.', 'Your Journey →', 'book.php?ch=Journey'];
    }
    $jobs = $c['jobs'];
    $jb = [];
    if ($jobs) {
        $j0 = $jobs[0];
        $jb[] = e($j0['title']) . ' <span class="muted">' . ((int)$j0['stages'] > 1 ? 'stage ' . min((int)$j0['stages'], (int)$j0['stages_paid'] + 1) . '/' . (int)$j0['stages'] : (int)$j0['progress'] . '/' . (int)$j0['qty']) . '</span>' . (count($jobs) > 1 ? ' <span class="muted">+' . (count($jobs) - 1) . ' more</span>' : '');
    } else {
        $jb[] = '<span class="muted">No job yet. New ones every day.</span>';
    }
    if ($nOrders) $jb[] = '📜 ' . $nOrders . ' order' . ($nOrders === 1 ? '' : 's') . ' open';
    $cards[] = ['', '📋 Your jobs', implode(' · ', $jb), 'Tasks →', 'jobs.php'];
    $mk = '';
    if (!$localHere) {
        if (market_day_on()) $mk = ' · <b>🧺 market day!</b>';
        elseif (($md = market_days_until()) > 0) $mk = ' · <span class="muted">🧺 market in ' . $md . 'd</span>';
    }
    if ($localHere) $cards[] = ['', '🪧 ' . e($node['name']) . ' rest stop', e($c['lline']), e($c['lcta']), 'town.php'];
    else $cards[] = ['', '🏘️ ' . e($town), ($c['todo'] ? '<b>' . $c['todo'] . ' thing' . ($c['todo'] === 1 ? '' : 's') . ' to do today</b>' : 'All done for today.') . $mk, 'Town square →', 'town.php'];
    $cards[] = ['', '🌍 Adventure', $next ? 'Next: <b>' . e($next['gnomish_name']) . '</b> (level ' . (int)$next['min_level'] . ')' : 'Walk the roads and wander off the path.', 'Where to next →', 'world.php'];
    if ($trekOn) $cards[] = ['', '🥾 Treks', 'Longer walks with fights and finds.', 'Plan a trek →', 'trek.php'];
    if (!empty($o['filler']) && count($cards) + ($slotHtml ? 1 : 0) === 7) $cards[] = ['', '🧑‍🌾 Your gnome', 'Level ' . (int)$u['level'] . '. Stats, gear and looks.', 'Your gnome →', 'gnome.php?tab=gnome'];   // keep the tiles even
    $wide8 = count($cards) + ($slotHtml ? 1 : 0) > 6;

    $h = '';
    if (($o['pals'] ?? true)) { require_once __DIR__ . '/puzzle_pals.php'; if (ppal_open() && !is_guest($u)) { require_once __DIR__ . '/pal_jobs.php'; $h .= pj_home_notice_html($u); } }   // v2.3.3: pals back from a trip or delve
    if (!$allNews && $news) {
        $n = $news[0];
        $h .= '<div class="box todaynews" id="news">'
            . '<p class="tnhead"><span>📰 <b>' . e($n['title']) . '</b>' . ($c['freshNews'] ? ' <span class="tag">new</span>' : '') . ' <small class="muted">' . e(gmdate('M j, Y', strtotime($n['created_at'] . ' UTC'))) . '</small></span> <a href="' . e(url('index.php?news=all#news')) . '">All news →</a></p>'
            . '<details><summary>Read</summary><div>' . format_text($n['body']) . '</div></details></div>';
    }
    $h .= '<div class="todaycards" id="todaycards"><div class="todaygrid' . ($wide8 ? ' g8' : '') . '">' . $slotHtml;
    foreach ($cards as [$cc, $ct, $cs, $cl, $ch]) {
        $h .= '<a class="box tcard ' . e($cc) . '" href="' . e(url($ch)) . '"><h3>' . $ct . '</h3><p>' . $cs . '</p><span class="tgo">' . $cl . '</span></a>';
    }
    $h .= '</div>';
    if ($nRepairs) $h .= '<p class="help"><a href="' . e(url('jobs.php?t=journey#repairs')) . '">🔨 ' . $nRepairs . ' repair' . ($nRepairs === 1 ? '' : 's') . ' under way</a></p>';
    $h .= '</div>';
    $h .= '<div class="todayhollow" id="hollowtoday">' . today_social_html($u, ($o['hollow'] ?? 'full') === 'line' ? 'line' : 'hollow') . '</div>';
    if ($c['guide']) {
        $g = $c['guide'];
        $h .= '<div class="box wren tip tipcompact todaytip"><p class="say"><b>🐦 Wren:</b> “Have you read <a href="' . e(url('book.php?ch=' . urlencode($g['chapter']) . '&open=' . (int)$g['id'] . '#e' . (int)$g['id'])) . '"><b>' . e($g['title']) . '</b></a> in your Almanac yet? It’s worth a look.”</p></div>';
    }
    if ($allNews) {
        $h .= '<details class="fold todayallnews" id="news" open><summary>📰 News from the Hollow</summary>';
        foreach ($news as $n) $h .= '<article class="box news"><h3>' . e($n['title']) . '</h3><p class="muted">' . e(gmdate('F j, Y', strtotime($n['created_at'] . ' UTC'))) . '</p><div>' . format_text($n['body']) . '</div></article>';
        if (!$news) $h .= '<p class="muted">No news yet.</p>';
        $h .= '</details>';
    }
    return $h;
}
