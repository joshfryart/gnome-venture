<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';

$allNews = isset($_GET['news']);   // v0.7.55: every post, not just the latest few
$news = q('SELECT title, body, created_at FROM news WHERE published = 1 ORDER BY created_at DESC, id DESC LIMIT ' . ($allNews ? 200 : 5))->fetchAll();
$freshNews = $news && strtotime($news[0]['created_at'] . ' UTC') > time() - 3 * 86400;
$u = current_user();
$today = $u && (int)($u['onboarded'] ?? 1) === 1;   // v0.7.48: a "Today" page for players
// v1.9.2: Today is one page again (no tabs); the old ?t=out / ?t=hollow links land on their part of it
if (!$allNews && $u && $today && isset($_GET['t'])) redirect('index.php' . ($_GET['t'] === 'out' ? '#todaycards' : ($_GET['t'] === 'hollow' ? '#hollowtoday' : '')));
if ($today) $GLOBALS['gv_today_page'] = true;   // v1.9.2: layout.php hides the rail boxes this page already shows
if ($today) {
    require_once __DIR__ . '/includes/garden_logic.php';
    require_once __DIR__ . '/includes/world.php';
    require_once __DIR__ . '/includes/town.php';
    refresh_energy($u);
    $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
    $uid = (int)$u['id'];
    require_once __DIR__ . '/includes/today_social.php'; today_social_prepare($u);   // v1.0.0 wave 3: pays Hollow jar tiers before the page starts
    // Your garden at a glance
    [$plot, $tiles, $plants] = load_plot($uid, true);
    $nThirsty = $nReady = $nGrowing = $nEmpty = 0;
    foreach ($tiles as $row) foreach ($row as $t) {
        if ($t['plant_id'] && isset($plants[(int)$t['plant_id']])) {
            $ti = tile_info($t, $plants[(int)$t['plant_id']]);
            if ($ti['ready']) $nReady++; elseif ($ti['thirsty']) $nThirsty++; else $nGrowing++;
        } else {
            $nEmpty++;
        }
    }
    // Your jobs
    $jobs = q("SELECT period, title, qty, progress, stages, stages_paid FROM user_jobs WHERE user_id = ? AND status = 'active' ORDER BY id", [$uid])->fetchAll();
    // The town square: things still to do today
    $town = town_for($u, false);
    $uses = town_uses_today($uid);
    $todo = 0;
    foreach (town_spots($town) as $ts) {
        if (spot_closed($ts)) continue;
        require_once __DIR__ . '/includes/journey.php';
        if (journey_lock($uid, 'spot', (string)$ts['slug'])) continue;   // v0.7.66: closed for repairs
        foreach (town_actions((int)$ts['id']) as $ta) if ($ta['kind'] !== 'link' && (int)$ta['daily'] > 0 && ($uses[(int)$ta['id']] ?? 0) < (int)$ta['daily']) $todo++;
    }
    // In a village there's no square: say what's on locally instead
    require_once __DIR__ . '/includes/adventure.php';
    $node = player_node($u);
    $localHere = $node['kind'] === 'village';
    if ($localHere) {
        require_once __DIR__ . '/includes/local.php';
        [$lline, $lcta] = local_card($u, $node);   // v1.0.0: rest stop types, slots, villagers
    }
    // Wren's tip: the next getting-started page you haven't read yet
    $guide = q_one("SELECT e.id, e.title, e.chapter FROM encyclopedia_entries e JOIN user_encyclopedia ue ON ue.entry_id = e.id AND ue.user_id = ?
                    WHERE e.chapter = 'General' AND ue.read_at IS NULL ORDER BY e.sort_order, e.id LIMIT 1", [$uid]);
    $hour = hollow_hour();
    $hello = $hour < 12 ? 'Good morning' : ($hour < 18 ? 'Good afternoon' : 'Good evening');
}
if (!$u) {   // v0.8.8: what search engines and link previews see
    require_once __DIR__ . '/includes/site_text.php';   // v0.8.9: front page words are editable in Admin → Page text
    seo_set(['title' => stext('home.title'), 'jsonld' => seo_game_jsonld(), 'canonical' => 'index.php']);
}
page_header('Home');
?>
<?php if ($today): ?>
<?php
require_once __DIR__ . '/includes/destination.php'; require_once __DIR__ . '/includes/calling_view.php'; require_once __DIR__ . '/includes/journey.php'; require_once __DIR__ . '/includes/rebuild.php';
require_once __DIR__ . '/includes/first_week.php'; require_once __DIR__ . '/includes/welcome_back.php'; require_once __DIR__ . '/includes/festival.php';
$slot = helper_slot($u);
$fc = hollow_forecast(hollow_user_region($u), 3);
$fx = active_effects($u);
$ds = dest_status($u);
$callLine = calling_today_line($u);
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
if ($nReady) $gb[] = '<b>🧺 ' . $nReady . ' ready</b>';
if ($nThirsty) $gb[] = '<b>💧 ' . $nThirsty . ' thirsty</b>';
if ($nGrowing) $gb[] = '🌿 ' . $nGrowing . ' growing';
if ($nEmpty) $gb[] = '<span class="muted">⬜ ' . $nEmpty . ' empty</span>';
$cards[] = ['', '🌱 ' . eu($plot['garden_name'] ?: 'Your garden'), implode(' · ', $gb) ?: 'Nothing planted yet.', 'Go to your garden →', 'garden.php'];
if ($jc) {
    $jn = count(array_filter($jst['tasks'], fn($t) => $t[3])); $jr = journey_ready($u, $jst);
    $jh = journey_next_hint($u, $jc, $jst);
    $cards[] = ['', '🧭 Wren’s Journey', e((string)$jc['project_icon']) . ' <b>' . e($jc['region']) . '</b>: ' . $jn . ' of ' . count($jst['tasks']) . ' done' . ($jr === 'finish' ? ' · <b>✋ finish!</b>' : ($jr === 'stage' ? ' · <b>✋ hand in</b>' : '')) . ($jh ? '<span class="jhint muted">👉 ' . e($jh[0]) . '</span>' : ''), 'Your Journey →', 'book.php?ch=Journey&j=' . (int)$jc['id']];
} else {
    $jl = journey_next_locked($u);
    $cards[] = ['', '🧭 Wren’s Journey', $jl ? 'Next: <b>' . e($jl['region']) . '</b> (level ' . (int)$jl['min_level'] . '). Starts when you walk there.' : 'Every chapter is finished.', 'Your Journey →', 'book.php?ch=Journey'];
}
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
if ($localHere) $cards[] = ['', '🪧 ' . e($node['name']) . ' rest stop', e($lline), e($lcta), 'town.php'];
else $cards[] = ['', '🏘️ ' . e($town), ($todo ? '<b>' . $todo . ' thing' . ($todo === 1 ? '' : 's') . ' to do today</b>' : 'All done for today.') . $mk, 'Town square →', 'town.php'];
$cards[] = ['', '🌍 Adventure', $next ? 'Next: <b>' . e($next['gnomish_name']) . '</b> (level ' . (int)$next['min_level'] . ')' : 'Walk the roads and wander off the path.', 'Where to next →', 'world.php'];
if ($trekOn) $cards[] = ['', '🥾 Treks', 'Longer walks with fights and finds.', 'Plan a trek →', 'trek.php'];
if (count($cards) + ($slotHtml ? 1 : 0) === 7) $cards[] = ['', '🧑‍🌾 Your gnome', 'Level ' . (int)$u['level'] . '. Stats, gear and looks.', 'Your gnome →', 'gnome.php'];   // keep the tiles even
$wide8 = count($cards) + ($slotHtml ? 1 : 0) > 6;
?>
<div class="todaypage">
<div class="box todayhead">
  <div class="tavatar"><?= gnome_avatar($u, 64) ?></div>
  <div>
    <h1><?= e($hello) ?>, <?= e(gnome_name($u)) ?>!</h1>
    <p class="todayfx tline"><span>📍 <?= e(player_location($u)) ?></span> <span><?= hollow_chip(hollow_user_region($u), 'hollow') ?></span><?php if ($fc): ?> <span class="muted">Tomorrow: <?= e($fc[1]['emoji'] . ' ' . $fc[1]['wlabel']) ?></span><?php endif; ?><?php if ($fx): ?> <a href="<?= e(url('gnome.php#effects')) ?>">✨ <?= implode(' ', array_map(fn($f) => e($f[0] . ' ' . $f[2] . ' (' . effect_time($f[3]) . ')'), $fx)) ?></a><?php endif; ?></p>
    <?php if ($ds): ?><p class="todayfx"><a href="<?= e(url('world.php#gopanel')) ?>">🏁 Heading to <?= e(dest_name((int)$u['id'], $ds[0])) ?> · <?= (int)$ds[1] ?> stop<?= $ds[1] === 1 ? '' : 's' ?> left</a></p><?php endif; ?>
    <?= $callLine ?>
  </div>
</div>
<?php if (!$allNews && $news): $n = $news[0]; ?>
<div class="box todaynews" id="news">
  <p class="tnhead"><span>📰 <b><?= e($n['title']) ?></b><?= $freshNews ? ' <span class="tag">new</span>' : '' ?> <small class="muted"><?= e(gmdate('M j, Y', strtotime($n['created_at'] . ' UTC'))) ?></small></span> <a href="<?= e(url('index.php?news=all#news')) ?>">All news →</a></p>
  <details><summary>Read</summary><div><?= format_text($n['body']) ?></div></details>
</div>
<?php endif; ?>
<div class="todaycards" id="todaycards">
<div class="todaygrid<?= $wide8 ? ' g8' : '' ?>">
<?= $slotHtml ?>
<?php foreach ($cards as [$cc, $ct, $cs, $cl, $ch]): ?>
  <a class="box tcard <?= e($cc) ?>" href="<?= e(url($ch)) ?>">
    <h3><?= $ct ?></h3>
    <p><?= $cs ?></p>
    <span class="tgo"><?= $cl ?></span>
  </a>
<?php endforeach; ?>
</div>
<?php if ($nRepairs): ?>
  <p class="help"><a href="<?= e(url('jobs.php?t=quests#repairs')) ?>">🔨 <?= $nRepairs ?> repair<?= $nRepairs === 1 ? '' : 's' ?> under way</a></p>
<?php endif; ?>
</div>
<div class="todayhollow" id="hollowtoday"><?= today_social_html($u, 'hollow') ?></div>
<?php if ($guide): ?>
  <div class="box wren tip tipcompact todaytip">
    <p class="say"><b>🐦 Wren:</b> “Have you read <a href="<?= e(url('book.php?ch=' . urlencode($guide['chapter']) . '&open=' . (int)$guide['id'] . '#e' . (int)$guide['id'])) ?>"><b><?= e($guide['title']) ?></b></a> in your Almanac yet? It’s worth a look.”</p>
  </div>
<?php endif; ?>
<?php if ($allNews): ?>
<details class="fold todayallnews" id="news" open><summary>📰 News from the Hollow</summary>
<?php foreach ($news as $n): ?>
  <article class="box news"><h3><?= e($n['title']) ?></h3><p class="muted"><?= e(gmdate('F j, Y', strtotime($n['created_at'] . ' UTC'))) ?></p><div><?= format_text($n['body']) ?></div></article>
<?php endforeach; ?>
<?php if (!$news): ?><p class="muted">No news yet.</p><?php endif; ?>
</details>
<?php endif; ?>
</div>
<?php elseif (!$u): ?>
<?php // v0.8.6: a front page that says what the game is, for visitors who've never played ?>
<section class="lp"><?php // v1.6.3: short, phone-first front page. v2.0.29: Hearthlight look: warm hero card, one solid button per block, centred picture tiles ?>
  <div class="lp-hero">
    <img class="lp-scene" src="<?= e(url('assets/img/landing/hero.svg')) ?>" alt="" width="360" height="170" fetchpriority="high">
    <h1><?= e(setting('site_name')) ?><?= is_admin() ? ' <a class="small" href="' . e(url('admin/texts.php?page=' . urlencode('Front page'))) . '">✏️ Edit</a>' : '' ?></h1>
    <p class="lp-pitch"><?= e(stext('home.headline')) ?></p>
    <p class="lp-sub">A free, cosy garden game about gnomes.</p>
    <div class="lp-cta">
      <a class="btn lp-big" href="<?= e(url('register.php')) ?>"><?= e(stext('home.button')) ?></a>
      <a class="lp-login" href="<?= e(url('login.php')) ?>">Already a gnome? <b>Log in</b></a>
    </div>
    <p class="lp-small"><?= e(stext('home.small')) ?></p>
  </div>
  <h2 class="lp-h2">What you do here</h2>
  <ul class="lp-cards">
    <?php foreach ([
        ['garden', 'Grow a garden', 'A 4×4 plot to start. Buy more land as you go.'],
        ['cook', 'Cook, craft, trade', 'Harvests become meals, tools and Petals.'],
        ['stats', 'Eat well, grow strong', 'Food and rare plants change your gnome’s stats.'],
        ['roads', 'Walk the roads', 'Villages and townsfolk with lives of their own.'],
        ['games', 'Little games', 'Quick daily games, at your own pace.'],
        ['almanac', 'Fill your Almanac', 'A book that fills in as you play.'],
    ] as [$img, $ttl, $line]): ?>
    <li class="lp-card">
      <img src="<?= e(url('assets/img/landing/' . $img . '.svg')) ?>" alt="" width="240" height="160" loading="lazy">
      <h3><?= e($ttl) ?></h3>
      <p><?= e($line) ?></p>
    </li>
    <?php endforeach; ?>
  </ul>
  <div class="lp-cta lp-end">
    <a class="btn lp-big" href="<?= e(url('register.php')) ?>"><?= e(stext('home.cta')) ?></a>
    <a class="btn ghost lp-big" href="<?= e(url('guide.php')) ?>">📖 How to play</a>
    <a class="lp-login" href="<?= e(url('login.php')) ?>">Already a gnome? <b>Log in</b></a>
  </div>
  <?php if (!in_array(trim((string)setting('motd')), ['', 'Welcome, new gardener! Open your Almanac to begin.'], true)): ?><p class="help lmotd"><?= format_text(setting('motd')) ?></p><?php endif; ?>
</section>
<?php else: ?>
<div class="box welcome">
  <h2><?= e(setting('site_name')) ?></h2>
  <?php $motdDefault = trim((string)setting('motd')) === 'Welcome, new gardener! Open your Almanac to begin.'; ?>
  <p><?= $motdDefault ? 'Welcome, new gardener! Let’s set up your gnome and garden.' : format_text(setting('motd')) ?></p>
  <?php if ($u): ?><p><a class="btn" href="<?= e(url('welcome.php')) ?>">🌱 Get started</a></p><?php endif; /* v1.6.2: the Almanac opens once your garden exists */ ?>
</div>
<?php endif; ?>
<?php if ($today): /* v1.9.2: news is part of the merged Today page above */ ?>
<?php else: ?>
<details class="fold<?= $u ? '' : ' lp-news' ?>" id="news"<?= ($u && !$today) || $allNews || ($u && $freshNews) ? ' open' : '' ?>><summary>📰 News from the Hollow<?= $freshNews ? ' <span class="tag">new</span>' : '' ?></summary>
<?php foreach ($news as $n): ?>
  <article class="box news">
    <h3><?= e($n['title']) ?></h3>
    <p class="muted"><?= e(gmdate('F j, Y', strtotime($n['created_at'] . ' UTC'))) ?></p>
    <div><?= format_text($n['body']) ?></div>
  </article>
<?php endforeach; ?>
<?php if (!$news): ?><p class="muted">No news yet.</p><?php endif; ?>
<?php if (!$allNews && count($news) >= 5): ?><p><a href="<?= e(url('index.php?news=all#news')) ?>">📰 All news →</a></p><?php endif; ?>
</details>
<?php endif; ?>
<?php page_footer();
