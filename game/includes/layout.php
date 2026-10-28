<?php
declare(strict_types=1);

require_once __DIR__ . '/gnome.php';
require_once __DIR__ . '/tour.php';
require_once __DIR__ . '/theme.php';   // v1.6.5: dark/light switch
require_once __DIR__ . '/seo.php';   // v0.8.8: search engines and link previews

// Pages whose buttons update in place (v0.7.39): the games and adventuring. Others reload as usual.
const AJAX_PAGES = ['worms.php', 'memory.php', 'race.php', 'spit.php', 'marrow.php', 'carve.php', 'show.php', 'games.php', 'adventure.php', 'garden.php',
    // v0.7.47: most game pages update in place
    'world.php', 'trek.php', 'town.php', 'inventory.php', 'shop.php', 'crafting.php', 'jobs.php', 'gnome.php', 'community.php', 'market.php', 'folk.php', 'tend.php', 'book.php', 'gotm.php', 'event.php',
    'festival.php', 'marketday.php', 'hollow.php', 'pals.php', 'index.php',   // v1.2.0: festival + market-day stalls, the Hollow, friends and the Today tabs update in place too
    'mushroom.php', 'letters.php', 'fair.php', 'pest.php'];   // v1.4.0: the last three game pages update in place too

function page_header(string $title, bool $admin = false): void
{
    $u = current_user();
    $site = setting('site_name');
    $onboarding = $u && (int)($u['onboarded'] ?? 1) === 0;
    // Wren's tour: opening the page a step asks for completes that step.
    $tourStep = $u ? (int)($u['tour_step'] ?? 0) : 0;
    $page = basename((string)($_SERVER['SCRIPT_NAME'] ?? ''));
    if ($u && !$onboarding) {
        require_once __DIR__ . '/trade.php';
        show_notices((int)$u['id']);   // gifts, trades, stall sales, job news
    }
    if ($u && !$onboarding && !$admin && ($ct = calling_tier($u)) > (int)($u['calling_tier_seen'] ?? 0)) {   // v0.9.1: a new calling tier, said once
        if (q('UPDATE users SET calling_tier_seen = ? WHERE id = ? AND calling_tier_seen < ?', [$ct, $u['id'], $ct])->rowCount() === 1 && $ct >= 2) {
            flash('🎩 You are now a ' . calling_tier_name($ct) . ' ' . CALLINGS[$u['calling']][0] . '! Your calling grew stronger: see My Gnome → Calling.');
        }
    }
    $eventHtml = '';
    if ($u && !$onboarding && !$admin) {
        require_once __DIR__ . '/events.php';
        if (!is_post() && !tour_active($u)) maybe_random_event($u);   // rare little surprises (v0.7.19)
        $eventHtml = event_box_html();
    }
    if (!$admin && $tourStep > 0 && isset(TOUR_PAGES[$page])) {
        $tourStep = tour_event((int)$u['id'], TOUR_PAGES[$page]);
        foreach (tour_messages() as $m) flash($m);
    }
    // v0.7.54: messages go into a list (left side on a computer, a fold under the top bar on a phone) instead of the top of the page
    $useLog = $u && !$admin && !$onboarding;
    $logSide = $logTop = '';
    if ($useLog) [$logSide, $logTop] = msglog_render();
    ?><!doctype html>
<html lang="en"<?= theme_html_attrs() /* v1.6.5 */ ?>>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="<?= theme_pref() === 'light' ? 'light' : 'dark' ?>">
<?= seo_head($title, $admin) ?><link rel="stylesheet" href="<?= e(url('assets/style.css?v=' . APP_VERSION)) ?>">
<?php if (!$admin && !$u && in_array($page, ['index.php', 'guide.php'], true)): ?><link rel="stylesheet" href="<?= e(url('assets/landing.css?v=' . APP_VERSION)) ?>">
<?php endif; /* v1.6.3: landing.css only on the logged-out front page and How to play */ ?>
<?php if ($admin): ?><link rel="stylesheet" href="<?= e(url('assets/admin.css?v=' . APP_VERSION)) ?>"><script src="<?= e(url('assets/admin.js?v=' . APP_VERSION)) ?>" defer></script><?php endif; /* v1.6.3: admin look and menu, admin pages only */ ?>
<script src="<?= e(url('assets/early.js?v=' . APP_VERSION)) ?>"></script>
<script src="<?= e(url('assets/site.js?v=' . APP_VERSION)) ?>" defer></script>
<?php if (!$admin && in_array($page, ['spit.php', 'worms.php', 'memory.php', 'mushroom.php', 'race.php', 'marrow.php', 'letters.php'], true)): ?><script src="<?= e(url('assets/' . substr($page, 0, -4) . '.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v1.4.0: assets/spit.js, assets/worms.js. v1.4.6: assets/memory.js, assets/mushroom.js. v1.4.7: assets/race.js, assets/marrow.js, assets/letters.js */ ?>
<?php if (!$admin && (in_array($page, ['puzzles.php', 'gifsaw.php', 'rainbarrel.php', 'gnomebeds.php'], true) || !empty($GLOBALS['gv_front_demo']))): ?><link rel="stylesheet" href="<?= e(url('assets/puzzles.css?v=' . APP_VERSION)) ?>"><script src="<?= e(url('assets/' . (['puzzles.php' => 'puzzlehub', 'rainbarrel.php' => 'rainbarrel', 'gnomebeds.php' => 'gnomebeds'][$page] ?? 'puzzles') . '.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v2.0.31: Puzzles (assets/puzzles.css + assets/puzzles.js). v2.0.69: puzzles.js = GIFsaw (gifsaw.php), puzzles.php = hub (puzzlehub.js) */ ?>
<?php if (!$admin && $page === 'pest.php'): ?><script src="<?= e(url('assets/pest.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v1.4.8: assets/pest.js (Pest Patrol) */ ?>
<?php if (!$admin && $page === 'adventure.php'): ?><script src="<?= e(url('assets/stage.js?v=' . APP_VERSION)) ?>" defer></script><script src="<?= e(url('assets/hoop.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v2.0.43: the Adventure stage */ ?>
<?php if (!$admin && $page === 'villagers.php'): ?><script src="<?= e(url('assets/stage.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v2.0.68: the home interior shown after a Knock needs the stage */ ?>
<?php if (!$admin && $page === 'trek.php'): ?><script src="<?= e(url('assets/stage.js?v=' . APP_VERSION)) ?>" defer></script><script src="<?= e(url('assets/trekshell.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v2.0.40: the stage and the Party/Pack/Log drawers */ ?>
<?php if (!$admin && $page === 'trek.php'): ?><script src="<?= e(url('assets/trekfight.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v1.8.4: assets/trekfight.js (the fight plan sheet and turn-by-turn stage) */ ?>
<?php if (!$admin && $page === 'trek.php'): ?><script src="<?= e(url('assets/trekmap.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v1.8.10: assets/trekmap.js (the walk animation on the map) */ ?>
<?php if (!$admin && $page === 'trek.php'): ?><script src="<?= e(url('assets/trekscene.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v2.0.8: assets/trekscene.js (the talk pop-over: speaker left, listener faded right) */ ?>
<?php if (!$admin && $page === 'trek.php'): ?><script src="<?= e(url('assets/trekcamp.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v2.0.11: assets/trekcamp.js (the camp pop-over) */ ?>
<?php if (!$admin && $page === 'adventure.php'): ?><script src="<?= e(url('assets/tilemap.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v2.0.6: assets/tilemap.js (walk the token on a delve or lair map) */ ?>
<?php if (!$admin && $u && !$onboarding): ?><script src="<?= e(url('assets/fighton.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v1.4.0: Fight on replay, for the fight card and the walk bar */ ?>
<?php if (!$admin && $u && !$onboarding): ?><script src="<?= e(url('assets/chest.js?v=' . APP_VERSION)) ?>" defer></script>
<?php endif; /* v1.4.6: delve chest opening treat */ ?>
</head>
<body class="<?= $admin ? 'admin' : 'game' ?>"<?= $admin ? '' : ' data-area="' . e(page_area($page)) . '"' ?><?= !$admin && (in_array($page, AJAX_PAGES, true) || !empty($GLOBALS['AJAX_PAGE'])) ? ' data-ajax' : '' ?>>
<a class="skip" href="#main">Skip to content</a>
<header class="banner"><div class="bannerin">
  <a class="logo" href="<?= e(url($admin ? 'admin/index.php' : 'index.php')) ?>"><?= e($site) ?><?= $admin ? ' <small>Admin</small>' : '' ?></a>
  <span class="tagline"><?= e(setting('site_tagline')) ?></span>
  <button type="button" class="menubtn" aria-controls="sidenav" aria-expanded="false" aria-label="Open menu"><span aria-hidden="true">☰</span> Menu</button>
  <?php if ($u): ?>
    <div class="userbar">
<?php if (!$admin && !$onboarding): [$hdrE, $hdrMax] = current_energy($u); ?>
      <span class="hdr-pill hdr-energy<?= (int)$hdrE <= 0 ? ' empty' : '' ?>" role="img" title="<?= e(energy_line($u)) ?>" aria-label="Energy <?= $hdrE ?> of <?= $hdrMax ?>">⚡ <?= $hdrE ?>/<?= $hdrMax ?></span>
      <span class="hdr-pill hdr-coins" role="img" aria-label="<?= e(money((int)$u['coins'])) ?>">🪙 <?= number_format((int)$u['coins']) ?></span>
      <strong><?= e(gnome_name($u)) ?></strong>
<?php else: ?>
      <strong><?= e(gnome_name($u)) ?></strong><?= $onboarding ? '' : ' · ' . money((int)$u['coins']) ?>
<?php endif; ?>
      <?= theme_toggle('th-hdr') /* v1.6.5: desktop header switch (phones use the menu sheet) */ ?>
      <form method="post" action="<?= e(url('logout.php')) ?>" class="inline"><?= csrf_field() ?><button class="linkbtn">Log out</button></form>
    </div>
  <?php else: ?>
    <div class="userbar"><?= theme_toggle('th-hdr') ?></div>
  <?php endif; ?>
</div>
<?php if ($u && !$admin && !$onboarding) echo status_strip($u); ?>
</header>
<?php if ($u && !$admin && !$onboarding) { require_once __DIR__ . '/festival.php'; echo festival_bar_html($page === 'index.php' && helper_slot($u) === 'fest'); }   // v1.0.0: bunting while a festival runs. v1.6.3: the full banner only on Today; elsewhere on a phone it is an icon in the status line ?>
<div class="chrome2"><?php if ($u && !$admin && !$onboarding && $page !== 'adventure.php') echo adventure_topbar($u);
if ($u && !$admin && !$onboarding && !in_array($page, ['adventure.php', 'world.php'], true)) { require_once __DIR__ . '/destination.php'; echo dest_strip_html($u); }   // v2.0.65: trip strip ?>
<?= $logTop /* v1.6.3: on a phone the walk bar and the 🔔 share one line (.chrome2) */ ?></div>
<input type="checkbox" id="navtoggle" class="navtoggle" aria-hidden="true" tabindex="-1">
<div class="wrap">
<nav class="side" id="sidenav" aria-label="Menu">
<?php if ($admin): require_once __DIR__ . '/admin_menu.php'; echo admin_nav_sheet();   // v1.6.3.3: admin menu laid out like the game's menu sheet ?>
<?php else: ?>
  <?php if ($onboarding): ?>
    <?php if (tour_active($u) && (int)$u['level'] < 5): ?><a href="<?= e(url('welcome.php')) ?>">🌱 Getting started</a><?php endif;   // v1.7.0 menu: only while the tour runs and below level 5 (the Almanac holds it after) ?>
  <?php else: ?>
  <?php if ($u): echo nav_sheet($u, $page);   // v0.8.3: grouped icon tiles (a bottom sheet on phones) ?>
  <?php else: ?>
    <a href="<?= e(url('index.php')) ?>">Home</a>
    <a href="<?= e(url('login.php')) ?>">Log in</a>
    <a href="<?= e(url('register.php')) ?>">Join</a>
    <?php foreach (q('SELECT slug, title FROM pages WHERE published = 1 AND show_in_nav = 1 ORDER BY title')->fetchAll() as $p): ?>
      <a href="<?= e(url('page.php?p=' . urlencode($p['slug']))) ?>"><?= e($p['title']) ?></a>
    <?php endforeach; ?>
  <?php endif; ?>
  <?php endif; ?>
<?php endif; ?>
<?= $logSide ?>
</nav>
<label for="navtoggle" class="navbackdrop" aria-hidden="true"></label>
<main id="main" tabindex="-1">
<?= $eventHtml ?>
<?php if (!$useLog): ?>
<?php if (!empty($_SESSION['new_pages'])):
    $why = [];
    foreach ($_SESSION['new_pages'] as $np) {   // [id, reason] since v0.7.42 (plain ids before)
        $id = is_array($np) ? (int)$np[0] : (int)$np;
        $why[$id] ??= is_array($np) ? (string)$np[1] : '';
    }
    $ids = array_slice(array_keys($why), 0, 12);
    unset($_SESSION['new_pages']);
    $pages = q('SELECT id, title, chapter FROM encyclopedia_entries WHERE id IN (' . implode(',', $ids) . ')')->fetchAll(); ?>
  <?php if ($pages): ?><div class="newpages" role="status">📖 New Almanac page<?= count($pages) === 1 ? '' : 's' ?>:
    <?php foreach ($pages as $i => $pg): ?><?= $i ? ' · ' : ' ' ?><a href="<?= e(url('book.php?ch=' . urlencode($pg['chapter']) . '&open=' . (int)$pg['id'] . '#e' . (int)$pg['id'])) ?>"><?= e($pg['title']) ?></a><?= ($why[(int)$pg['id']] ?? '') !== '' ? ' <small>(' . e($why[(int)$pg['id']]) . ')</small>' : '' ?><?php endforeach; ?>
  </div><?php endif; ?>
<?php endif; ?>
<?php foreach (take_prizes() as $pz): ?>
  <div class="prizebox" role="status">
    <div class="pzicon"><?= e($pz['icon']) ?></div>
    <div class="pzbody"><div class="pztitle"><?= e($pz['title']) ?></div>
      <?php if ($pz['big'] !== ''): ?><div class="pzbig"><?= e($pz['big']) ?></div><?php endif; ?>
      <?php if ($pz['lines']): ?><ul><?php foreach ($pz['lines'] as $ln): ?><li><?= e($ln) ?></li><?php endforeach; ?></ul><?php endif; ?></div>
  </div>
<?php endforeach; ?>
<?php foreach (take_flashes() as $f): if ($f['msg'] === '') continue; ?>
  <div class="flash <?= e($f['type']) ?>" role="<?= $f['type'] === 'err' ? 'alert' : 'status' ?>"><?= e($f['msg']) ?></div>
<?php endforeach; ?>
<?php endif;
    if (!$admin && !$onboarding && $tourStep > 0) echo tour_box($tourStep);
}

/** "just now", "5 min ago", "2 h ago", "3 days ago". Self-contained: layout.php runs on every page (v0.7.60 fix). */
function msglog_ago(int $s): string
{
    if ($s < 60) return 'just now';
    if ($s < 3600) return intdiv($s, 60) . ' min ago';
    if ($s < 86400) return intdiv($s, 3600) . ' h ago';
    $d = intdiv($s, 86400);
    return $d . ' day' . ($d === 1 ? '' : 's') . ' ago';
}

/**
 * v0.7.54: the message list. Flashes, prize boxes and new Almanac pages are moved into $_SESSION['msglog'] (newest
 * first, last 30 kept); the ones from this page load are marked new. Returns [sidebar html, phone fold html].
 */
function msglog_render(): array
{
    $log = $_SESSION['msglog'] ?? [];
    foreach ($log as &$m) $m['new'] = 0;
    unset($m);
    $add = [];
    if (!empty($_SESSION['new_pages'])) {
        $why = [];
        foreach ($_SESSION['new_pages'] as $np) {
            $id = is_array($np) ? (int)$np[0] : (int)$np;
            $why[$id] ??= is_array($np) ? (string)$np[1] : '';
        }
        unset($_SESSION['new_pages']);
        $ids = array_slice(array_keys($why), 0, 12);
        $items = [];
        foreach (q('SELECT id, title, chapter FROM encyclopedia_entries WHERE id IN (' . implode(',', array_map('intval', $ids)) . ')')->fetchAll() as $pg) {
            $items[] = [(int)$pg['id'], (string)$pg['title'], (string)$pg['chapter'], $why[(int)$pg['id']] ?? ''];
        }
        if ($items) $add[] = ['k' => 'pages', 'items' => $items];
    }
    foreach (take_prizes() as $pz) $add[] = ['k' => 'prize'] + $pz;
    foreach (take_flashes() as $f) if ($f['msg'] !== '') $add[] = ['k' => 'flash', 'type' => $f['type'] === 'err' ? 'err' : 'ok', 'msg' => $f['msg']];
    foreach (array_reverse($add) as $m) array_unshift($log, $m + ['t' => time(), 'new' => 1]);
    $log = array_slice($log, 0, 30);
    $_SESSION['msglog'] = $log;
    $lis = '';
    $new = 0;
    foreach ($log as $m) {
        $new += (int)$m['new'];
        $ago = time() - (int)$m['t'];
        $when = '<small class="mlwhen">' . e(msglog_ago($ago)) . '</small>';
        if ($m['k'] === 'pages') {
            $links = [];
            foreach ($m['items'] as [$id, $title, $ch, $why]) {
                $links[] = '<a href="' . e(url('book.php?ch=' . urlencode($ch) . '&open=' . $id . '#e' . $id)) . '">' . e($title) . '</a>' . ($why !== '' ? ' <small>(' . e($why) . ')</small>' : '');
            }
            $body = '📖 New Almanac page' . (count($links) === 1 ? '' : 's') . ': ' . implode(' · ', $links);
            $cls = 'pages';
        } elseif ($m['k'] === 'prize') {
            $body = '<b>' . e($m['icon'] . ' ' . $m['title']) . '</b>' . ($m['big'] !== '' ? ' <span class="mlbig">' . e($m['big']) . '</span>' : '')
                . ($m['lines'] ? '<br><small>' . e(implode(' · ', $m['lines'])) . '</small>' : '');
            $cls = 'prize';
        } else {
            $body = e($m['msg']);
            $cls = $m['type'];
        }
        $lis .= '<li class="ml ' . $cls . ($m['new'] ? ' new' : '') . '">' . $body . ' ' . $when . '</li>';
    }
    $list = $lis !== '' ? '<ul class="mllist">' . $lis . '</ul>' : '<p class="muted mlempty">Nothing yet. Messages about what you do show up here.</p>';
    $side = '<section class="msglog mlside" aria-label="Messages"><h3>🔔 Messages' . ($new ? ' <b class="mlnew">' . $new . ' new</b>' : '') . '</h3>' . $list . '</section>';
    $latest = $log[0] ?? null;
    $peek = $latest ? trim(html_entity_decode(strip_tags($latest['k'] === 'flash' ? $latest['msg'] : ($latest['k'] === 'prize' ? $latest['icon'] . ' ' . $latest['title'] . ' ' . $latest['big'] : '📖 New Almanac page')))) : 'No messages yet';
    $top = '<details class="msglog top' . ($new ? ' hasnew' : '') . ($latest && $latest['new'] && ($latest['type'] ?? '') === 'err' ? ' haserr' : '') . '"><summary><span class="mlbell" aria-label="Messages">🔔</span><span class="mlpeek">' . e(mb_strimwidth($peek, 0, 90, '…')) . '</span>'
        . ($new > 0 ? ' <b class="mlnew">' . ($new > 1 ? $new . ' new' : 'new') . '</b>' : '') . '</summary>' . $list . '</details>';
    return [$side, $top];
}

/** v0.9.2: the colour group of a page (body data-area), so each part of the game has its own hue. */
function page_area(string $page): string
{
    static $map = null;
    if ($map === null) {
        $map = [];
        $groups = [
            'garden' => 'garden tend yard spit worms',
            'world' => 'seasons world town adventure visit landmark journey gather carve explore destination maps passport',
            'kitchen' => 'kitchen crafting',
            'book' => 'book guide memory marrow',
            'market' => 'market shop inventory fair jobs',
            'community' => 'community letters profile folk friends show gotm race games puzzles gifsaw rainbarrel gnomebeds event hollow pals festival firstweek back daily',
        ];
        foreach ($groups as $area => $pages) foreach (explode(' ', $pages) as $p) $map[$p . '.php'] = $area;
    }
    if ($page === 'inventory.php' && (($_GET['tab'] ?? '') === 'craft')) return 'kitchen';
    return $map[$page] ?? 'garden';
}

/** [energy now, max energy], with regeneration since the last update counted (shared by the header pill and the status strip). */
function current_energy(array $u): array
{
    $max = max_energy($u);
    $energy = (int)$u['energy'];
    $last = !empty($u['energy_updated_at']) ? (int)strtotime($u['energy_updated_at'] . ' UTC') : 0;
    [$eAmt, $ePer] = energy_tick();   // v0.9.0
    if ($last && $energy < $max) $energy = min($max, $energy + intdiv(time() - $last, $ePer) * $eAmt);
    return [$energy, $max];
}

/** v0.9.4: seconds until the next energy tick (null when energy is full). */
function energy_next_secs(array $u): ?int
{
    [$energy, $max] = current_energy($u);
    if ($energy >= $max) return null;
    $last = !empty($u['energy_updated_at']) ? (int)strtotime($u['energy_updated_at'] . ' UTC') : 0;
    [, $per] = energy_tick();
    if (!$last) return $per;
    return $per - ((time() - $last) % $per);
}

/** v0.9.4: m:ss for a number of seconds. */
function energy_clock(int $secs): string
{
    return intdiv($secs, 60) . ':' . str_pad((string)($secs % 60), 2, '0', STR_PAD_LEFT);
}

/** v0.9.4: "+1 every minute, next in 0:42" ('' when energy is full). */
function energy_line(array $u): string
{
    $secs = energy_next_secs($u);
    if ($secs === null) return '';
    [$amt, $per] = energy_tick();
    $every = $per === 60 ? 'minute' : ($per < 60 ? $per . ' seconds' : rtrim(rtrim(number_format($per / 60, 1), '0'), '.') . ' minutes');
    return '+' . $amt . ' every ' . $every . ', next in ' . energy_clock($secs);
}

/** v0.9.4: "Next +1 in 0:42." for messages ('' when full). */
function energy_next_text(array $u): string
{
    $secs = energy_next_secs($u);
    return $secs === null ? '' : 'Next +' . energy_tick()[0] . ' in ' . energy_clock($secs) . '.';
}

/** v0.9.4: what to add to a "too tired" message: the countdown and the quick fix. Starts with a space. */
function tired_hint(array|int $u): string
{
    if (is_int($u)) $u = q_one('SELECT * FROM users WHERE id = ?', [$u]) ?: [];
    if (!$u) return '';
    $n = energy_next_text($u);
    return ($n !== '' ? ' ' . $n : '') . ' Eat something from your satchel for energy now.';
}

/** The gnome's at-a-glance numbers, under the banner on every page (v0.7.17). Read-only: energy shown with regen. */
function status_strip(array $u): string
{
    [$energy, $max] = current_energy($u);
    $enl = energy_line($u);   // v0.9.4
    require_once __DIR__ . '/almanac.php';
    require_once __DIR__ . '/crafting.php';   // v0.9.4: pots (the 🍳 N ready badge)
    [$pages, $total] = almanac_counts((int)$u['id']);
    $glevel = (int)q_val('SELECT p.garden_level FROM plots p JOIN users u ON u.active_plot_id = p.id WHERE u.id = ?', [$u['id']]);
    // v1.6.3: the pills are built once. A computer shows them as the old scrolling row; a phone shows one slim line (level · season · festival, stat-point badge) that opens to the same pills.
    $lvlPill = '<span class="st lvl" title="Gnome experience">🌱 Gnome level <b>' . (int)$u['level'] . '</b> <small>(' . number_format((int)$u['xp']) . '/' . number_format(xp_for_level((int)$u['level'] + 1)) . ' XP)</small></span>';
    $rest = hollow_chip(hollow_user_region($u))   // v1.0.0: season · weather · part of the day
        . ($glevel ? '<span class="st lvl glvl">🏡 Garden level <b>' . $glevel . '</b></span>' : '')
        . '<span class="st alm"><a href="' . e(url('book.php')) . '">📖 Almanac <b>' . $pages . '</b>/' . $total . '</a></span>'
        . (($pots = cook_pots_on() ? cook_ready_count((int)$u['id']) : 0) > 0 ? '<span class="st hot"><a href="' . e(url('inventory.php?tab=craft&c=cooking')) . '">🍳 ' . $pots . ' ready</a></span>' : '')   // v0.9.4: finished pots waiting
        . (($jars = pantry_ready_count((int)$u['id'])) > 0 ? '<span class="st hot"><a href="' . e(url('inventory.php?tab=craft&c=pantry')) . '">🫙 ' . $jars . ' ready</a></span>' : '');   // v0.9.8: finished Pantry jars waiting
    $sp = (int)$u['stat_points'];
    $statHot = $sp > 0 ? '<span class="st hot"><a href="' . e(url('gnome.php')) . '">✨ ' . $sp . ' stat point' . ($sp === 1 ? '' : 's') . ' to spend</a></span>' : '';
    $titleP = $u['title'] ? '<span class="st title">“' . e($u['title']) . '”</span>' : '';
    $hn = hollow_now(hollow_user_region($u));
    require_once __DIR__ . '/festival.php';
    $fest = festival_active();
    $h = '<div class="statusstrip"><div class="statusin">'
        . '<span class="st energy" title="Energy' . ($enl !== '' ? ': ' . e($enl) : '') . '">⚡ <progress class="ebar" aria-label="Energy" max="' . $max . '" value="' . $energy . '"></progress> <b>' . $energy . '</b>/' . $max . ($enl !== '' ? ' <small>' . e(energy_next_text($u)) . '</small>' : '') . '</span>'
        . $lvlPill . $rest . $statHot . $titleP
        . '</div>'
        // v1.6.3: phone line, no fold (Joshua: less info): level + small XP bar · season day + weather · festival icon · ready/stat badges
        . '<div class="stfold"><div class="stsum">'
        . '<a class="stl" href="' . e(url('gnome.php')) . '" title="Gnome level ' . (int)$u['level'] . ': ' . number_format((int)$u['xp']) . '/' . number_format(xp_for_level((int)$u['level'] + 1)) . ' XP">🌱 <b>' . (int)$u['level'] . '</b> '
        . '<progress class="xpbar" aria-label="XP to next level" max="' . max(1, xp_for_level((int)$u['level'] + 1) - xp_for_level((int)$u['level'])) . '" value="' . max(0, min((int)$u['xp'], xp_for_level((int)$u['level'] + 1)) - xp_for_level((int)$u['level'])) . '"></progress></a>'
        . '<a class="stl" href="' . e(url('world.php?tab=seasons#seasons')) . '" title="' . e($hn['season_label'] . ' day ' . (int)$hn['season_day'] . ' · ' . $hn['weather_label']) . '">' . $hn['season_emoji'] . ' ' . e($hn['season_label']) . ' ' . (int)$hn['season_day'] . ' ' . $hn['weather_emoji'] . '</a>'
        . ($fest ? '<a class="stl" href="' . e(url('festival.php')) . '" aria-label="' . e($fest['name']) . ' · day ' . (int)$fest['day'] . '/' . (int)$fest['days'] . '" title="' . e($fest['name']) . ' · day ' . (int)$fest['day'] . '/' . (int)$fest['days'] . '">' . e($fest['icon']) . '</a>' : '')
        . ($pots > 0 ? '<a class="stbadge" href="' . e(url('inventory.php?tab=craft&c=cooking')) . '" title="Pots ready" aria-label="' . $pots . ' pots ready">🍳 ' . $pots . '</a>' : '')
        . ($jars > 0 ? '<a class="stbadge" href="' . e(url('inventory.php?tab=craft&c=pantry')) . '" title="Jars ready" aria-label="' . $jars . ' jars ready">🫙 ' . $jars . '</a>' : '')
        . ($sp > 0 ? '<a class="stbadge" href="' . e(url('gnome.php')) . '" title="Stat points to spend" aria-label="' . $sp . ' stat points to spend">✨ ' . $sp . '</a>' : '') . '</div></div>'
        // v1.4.0: the low/out-of-energy band is gone (Joshua: too persistent); the ⚡ chip in the header shows energy
        . '</div>';
    return $h;
}

function page_footer(): void
{
    $u = current_user();
    $inAdmin = str_contains((string)($_SERVER['SCRIPT_NAME'] ?? ''), '/admin/');
    $page = basename((string)($_SERVER['SCRIPT_NAME'] ?? ''));
    if ($u && !$inAdmin) {   // v1.6.8: reminder emails go out after the page is sent, at most once an hour site-wide
        register_shutdown_function(function (): void {
            if (function_exists('fastcgi_finish_request')) @fastcgi_finish_request();
            require_once __DIR__ . '/mail_nudge.php';
            mail_nudge_tick();
        });
    }
    ?></main>
<?php if ($u && !$inAdmin && (int)($u['onboarded'] ?? 1) === 1) echo right_rail($u); ?>
</div>
<?php if ($u && !$inAdmin && (int)($u['onboarded'] ?? 1) === 1):   // v0.7.48: the places you use most, always in reach on a phone
    $tabs = [['garden.php', '🌱', 'Garden'], ['world.php', '🌍', 'World'], ['inventory.php', '👜', 'Satchel'], ['town.php', '📍', 'Here'], ['jobs.php', '📋', 'Tasks']]; ?>
<nav class="bottombar" aria-label="Quick links">
  <?php $rdy = (int)($_SESSION['nav_badges']['garden'] ?? 0);   // v1.0.0.1: the menu's "ready" badge, now on the bar's Garden
  foreach ($tabs as [$f, $i, $l]): ?><a href="<?= e(url($f)) ?>"<?= $page === $f ? ' class="on" aria-current="page"' : '' ?>><span aria-hidden="true"><?= $i ?></span><?= $l ?><?php if ($f === 'garden.php' && $rdy): ?><b class="barpip" aria-label="<?= $rdy ?> ready"><?= $rdy ?></b><?php endif; ?><?php if ($f === 'jobs.php' && ($jr = (int)($_SESSION['nav_badges']['jobs'] ?? 0))): ?><b class="barpip" aria-label="<?= $jr ?> ready"><?= $jr ?></b><?php endif; ?></a><?php endforeach; ?>
  <button type="button" class="menubtn more" aria-controls="sidenav" aria-expanded="false"><span aria-hidden="true">☰</span>More</button>
</nav>
<?php endif; ?>
<footer>&copy; <?= gmdate('Y') ?> <?= e(setting('site_name')) ?> · v<?= e(APP_VERSION) ?> · <a href="<?= e(url('guide.php')) ?>">How to play</a> · <a href="<?= e(url('page.php?p=rules')) ?>">Rules</a> · <a href="<?= e(url('page.php?p=privacy')) ?>">Privacy</a><?php if (!$u || $inAdmin) echo ' ' . theme_toggle('th-foot');   // v1.6.5: logged-out pages and admin get the switch here (players have it in the menu) ?></footer>
</body>
</html>
<?php
}

/**
 * The "on the road" bar under the banner: the whole path, health, what's in the way and the buttons,
 * so a walk keeps going while the gnome uses the rest of the site.
 */
/** A picture for a creature, guessed from its name (creatures have no art yet). */
function creature_icon(string $name, string $size = 'small'): string
{
    $n = strtolower($name);
    foreach (['beetle' => '🪲', 'ladybird' => '🐞', 'slug' => '🐌', 'snail' => '🐌', 'rat' => '🐀', 'mouse' => '🐭', 'wasp' => '🐝', 'hornet' => '🐝', 'bee' => '🐝',
              'spider' => '🕷️', 'scorpion' => '🦂', 'crow' => '🐦‍⬛', 'raven' => '🐦‍⬛', 'magpie' => '🐦', 'bird' => '🐦', 'owl' => '🦉', 'bat' => '🦇',
              'toad' => '🐸', 'frog' => '🐸', 'fox' => '🦊', 'badger' => '🦡', 'boar' => '🐗', 'snake' => '🐍', 'adder' => '🐍', 'viper' => '🐍', 'eel' => '🐍',
              'moth' => '🦋', 'butterfly' => '🦋', 'ant' => '🐜', 'mosquito' => '🦟', 'gnat' => '🦟', 'worm' => '🪱', 'crab' => '🦀', 'lizard' => '🦎', 'gecko' => '🦎',
              'wolf' => '🐺', 'bear' => '🐻', 'troll' => '👹', 'goblin' => '👺', 'mushroom' => '🍄', 'fung' => '🍄', 'spore' => '🍄', 'weasel' => '🦦', 'stoat' => '🦦',
              'otter' => '🦦', 'squirrel' => '🐿️', 'hedgehog' => '🦔', 'monkey' => '🐒', 'croc' => '🐊', 'shark' => '🦈', 'octopus' => '🐙', 'jelly' => '🪼',
              'turtle' => '🐢', 'tortoise' => '🐢', 'dragon' => '🐉', 'wyrm' => '🐉', 'ghost' => '👻', 'wisp' => '👻', 'golem' => '🗿', 'yeti' => '🦍', 'cat' => '🐈',
              'crayfish' => '🦞', 'silverfish' => '🐟', 'silverfin' => '🐟', 'millipede' => '🐛', 'crawler' => '🐛', 'hare' => '🐇', 'rabbit' => '🐇', 'deer' => '🦌', 'stag' => '🦌', 'goat' => '🐐', 'ram' => '🐏', 'tiger' => '🐅', 'lion' => '🦁', 'hyena' => '🐕', 'jackal' => '🐕'] as $k => $ic) {
        if (str_contains($n, $k)) return $ic;
    }
    return ['small' => '🐛', 'medium' => '🐾', 'large' => '👹', 'boss' => '🐉'][$size] ?? '🐾';
}

/** v2.0.24: a creature's own picture (uploaded, else the drawn placeholder) when it has one, else the emoji guess above. $c = a creatures row (needs slug, name, size). */
function creature_pic(array $c, string $artSize = 'md'): string
{
    require_once __DIR__ . '/items.php';
    $rel = creature_image((string)($c['slug'] ?? ''), true);
    return $rel !== '' ? art_img($rel, $artSize, (string)($c['name'] ?? '')) : creature_icon((string)($c['name'] ?? ''), (string)($c['size'] ?? 'small'));
}

function adventure_topbar(array $u): string
{
    $exp = q_one("SELECT * FROM expeditions WHERE user_id = ? AND status = 'active' ORDER BY id DESC LIMIT 1", [$u['id']]);
    if (!$exp) return '';
    $from = (string)q_val('SELECT name FROM locations WHERE id = ?', [$exp['from_id']]);
    $to = (string)q_val('SELECT name FROM locations WHERE id = ?', [$exp['to_id']]);
    $final = '';   // v1.6.2: where the whole trip ends, when this leg is only part of it
    if (($exp['kind'] ?? 'walk') === 'walk') {
        require_once __DIR__ . '/destination.php';
        $dw = dest_walk_info($u, $exp);
        if ($dw && (int)$dw['loc']['id'] !== (int)$exp['to_id']) $final = ' · 🏁 ' . dest_name((int)$u['id'], $dw['loc']);
    }
    $back = ltrim((string)preg_replace('~^' . preg_quote(rtrim(url(''), '/'), '~') . '/~', '', (string)($_SERVER['REQUEST_URI'] ?? '')), '/');
    if (!preg_match('~^[a-z0-9_/-]+\.php(\?[A-Za-z0-9=&_.-]*)?$~', $back)) $back = 'adventure.php';
    $btn = function (string $do, string $label, string $extra = '', string $attrs = '') use ($back): string {
        return '<form method="post" action="' . e(url('adventure.php')) . '"' . $attrs . '>' . csrf_field()
            . '<input type="hidden" name="do" value="' . e($do) . '"><input type="hidden" name="back" value="' . e($back) . '">'
            . $extra . '<button class="btn small">' . $label . '</button></form>';
    };
    $hp = max(0, (int)$exp['hp']);
    $max = max(1, (int)$exp['max_hp']);
    $lost = $max - $hp;
    $pct = (int)round($hp * 100 / $max);
    $enc = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
    $log = json_decode((string)$exp['log'], true) ?: [];

    $what = '';
    $actions = '';
    if ($enc && $enc['type'] === 'creature') {
        // v0.7.18: a proper face-off with both health bars, and the calling ability right here
        require_once __DIR__ . '/adventure.php';   // encounter_creature() (v0.7.64)
        $c = encounter_creature($enc);
        fight_prep($enc, $c);   // v1.3.0: eased health
        $ch = max(0, (int)$enc['hp']);
        $cm = max(1, (int)$enc['max']);
        require_once __DIR__ . '/adventure.php';
        [$abName, $abDesc] = CALLING_ABILITIES[$u['calling'] ?? ''] ?? CALLING_ABILITIES[''];
        // v0.7.61: one box, the creature on the left and you on the right (with your energy), sized for phones
        $what = '<div class="duel">'
            . '<div class="fighter foe' . ($ch * 3 <= $cm ? ' low' : '') . '"><span class="foeicon">' . creature_pic($c) . '</span>'
            . '<div class="fwho"><b>' . e($c['name'] ?? 'Creature') . '</b> <small>lv ' . (int)($c['level'] ?? 1) . '</small><br><meter min="0" max="' . $cm . '" low="' . (int)ceil($cm / 3) . '" value="' . $ch . '"></meter> <span class="hpnum">❤️ ' . $ch . '/' . $cm . '</span>'
            . (!empty($enc['poison']) ? ' <span class="fx" role="img" aria-label="Poisoned" title="Poisoned">🧪</span>' : '') . '</div></div>'
            . '<div class="vs">vs</div>'
            . '<div class="fighter me' . ($hp * 3 <= $max ? ' low' : '') . '">' . gnome_avatar($u, 44)
            . '<div class="fwho"><b>' . e(gnome_name($u)) . '</b><br><meter min="0" max="' . $max . '" low="' . (int)ceil($max / 3) . '" optimum="' . $max . '" value="' . $hp . '"></meter> <span class="hpnum">❤️ ' . $hp . '/' . $max . '</span>'
            . ' <span class="fx" role="img" aria-label="Energy ' . (int)$u['energy'] . '" title="Energy">⚡' . (int)$u['energy'] . '</span>'
            . (!empty($enc['bark']) ? ' <span class="fx" role="img" aria-label="Bark Skin ' . (int)$enc['bark'] . '" title="Bark Skin">🌳' . (int)$enc['bark'] . '</span>' : '') . '</div></div>'
            . '</div>';
        $actions = $btn('attack', '⚔️ Attack')
            . (!empty($enc['used']) ? '<button class="btn small" disabled title="' . e($abDesc) . '">✨ ' . e($abName) . ' (used)</button>'
                                    : $btn('ability', '✨ ' . e($abName), '', ' title="' . e($abDesc . ' Once per fight.') . '"'))
            . $btn('flee', '🏃 Run')
            . (can_fight_on($exp) ? $btn('fighton', '⏩ Fight on') : '')   // v1.3.0
            . fight_snack_picker($u, $exp, $enc, fn($do, $label, $extra) => $btn($do, $label, $extra, ' class="snackform"'));   // v1.4.0
        $sure = function_exists('fight_certainty') ? fight_certainty($u, $exp, $c, $enc) : null;
        if ($sure === 'win') $actions .= $btn('auto', '⏩ Auto-win');   // v1.3.0: only a sure win
        // v1.6.3.6: the open bar shows the fight actions as .choice rows (same look as the fight page); the closed line keeps the small buttons
        $cbtn = function (string $do, string $icon, string $title, string $sub = '', $badge = '', string $cls = '', string $extra = '', string $battrs = '') use ($back): string {
            return '<form method="post" action="' . e(url('adventure.php')) . '" class="choiceform">' . csrf_field()
                . '<input type="hidden" name="do" value="' . e($do) . '"><input type="hidden" name="back" value="' . e($back) . '">'
                . $extra . choice_row($icon, $title, $sub, $badge, $cls, $battrs) . '</form>';
        };
        $gc = gnome_combat($u);
        $hitPct = (int)fight_odds($u, $exp, $enc)['hit'];
        $runPct = max(0, min(100, (21 - (8 + intdiv((int)($c['level'] ?? 1), 3) - eff_mod($u, 'nimble'))) * 5));
        $actionsRow = '<div class="choices advchoices">'
            . $cbtn('attack', '⚔️', 'Attack', 'd' . $gc['dmg_die'] . '+' . $gc['dmg_bonus'] . ' damage', [$hitPct . '%', choice_odds_class($hitPct)], 'primary')
            . (!empty($enc['used']) ? $cbtn('ability', '✨', $abName, 'Used this fight', '', '', '', 'disabled') : $cbtn('ability', '✨', $abName, 'Once per fight'))
            . $cbtn('flee', '🏃', 'Run', 'No reward', [$runPct . '%', choice_odds_class($runPct)])
            . (can_fight_on($exp) ? $cbtn('fighton', '⏩', 'Fight on', 'Till done or half health') : '')
            . fight_snack_picker($u, $exp, $enc, fn($do, $label, $extra) => $cbtn($do, '🎒', 'Snack', 'Heals; uses your turn', '', '', $extra))
            . ($sure === 'win' ? $cbtn('auto', '⏩', 'Auto-win', 'A sure win', ['sure', 'cost']) : '')
            . '</div>';
        $what = '<div class="fightwrap">' . $what . fight_card_extra($u, $exp, $enc, 2) . '</div>';   // v1.3.0 (two rounds in the bar): odds line and the last rounds
    } elseif ($enc && $enc['type'] === 'problem') {
        $p = q_one('SELECT text, options FROM problems WHERE id = ?', [$enc['id']]);
        $what = '<span class="foe">❓ ' . e($p['text'] ?? 'A problem blocks the path.') . '</span>';
        foreach (json_decode((string)($p['options'] ?? '[]'), true) ?: [] as $i => $o) {
            $stat = isset(GNOME_STATS[$o['stat']]) ? $o['stat'] : 'grit';
            $chance = max(5, min(100, (21 - ((int)$o['dc'] + (int)($enc['dc_bonus'] ?? 0) - eff_mod($u, $stat))) * 5));
            $actions .= $btn('solve', GNOME_STATS[$stat][1] . ' ' . e($o['label']) . ' <small>' . $chance . '%</small>',
                '<input type="hidden" name="option" value="' . (int)$i . '">');
        }
    } elseif ($enc && $enc['type'] === 'choice') {   // v0.7.41: a little choice off the path
        require_once __DIR__ . '/explore.php';
        require_once __DIR__ . '/road_life.php';
        $ch = road_event_get((array)$enc) ?? ['icon' => '🌿', 'text' => 'Something catches your eye.', 'opts' => []];
        $what = '<span class="foe calm">' . e($ch['icon']) . ' ' . e($ch['text']) . '</span>';
        foreach ($ch['opts'] as $i => $o) $actions .= $btn('choose', e($o['label']), '<input type="hidden" name="option" value="' . (int)$i . '">');
    } elseif ($enc && $enc['type'] === 'meet') {   // v1.9.4: somebody on the road
        $what = '<span class="foe calm">' . e((string)$enc['ic']) . ' ' . e((string)$enc['t']) . '</span>';
        $actions = $btn('meet', '💬 Chat', '<input type="hidden" name="option" value="0">') . $btn('meet', '👋 Walk on', '<input type="hidden" name="option" value="1">');
    } elseif (($exp['kind'] ?? 'walk') === 'delve') {
        if ((int)$exp['depth'] >= 5) {
            $what = '<span class="foe calm">💰 The chest awaits.</span>';
            $actions = $btn('chest', '💰 Open the chest');
        } else {
            $what = '<span class="foe calm">🕳️ Room ' . (int)$exp['depth'] . ' of 5.</span>';
            $actions = $btn('next', '🚪 Next room ⚡1') . $btn('leave', '🪜 Climb out');
        }
    } elseif (($exp['kind'] ?? 'walk') === 'lair') {   // v2.0.6: the boss has not risen yet (the lair map)
        $what = '<span class="foe calm">🐉 The boss waits deeper in the lair.</span>';
        $actions = $btn('lair_engage', '⚔️ Face it') . $btn('leave', '🏃 Slip out');
    } elseif (($exp['kind'] ?? 'walk') === 'explore') {
        $what = '<span class="foe calm">🌿 Off the path, ' . (int)$exp['depth'] . ' step' . ((int)$exp['depth'] === 1 ? '' : 's') . ' out.</span>';
        $actions = $btn('deeper', '🌿 Deeper ⚡1') . ((int)$exp['depth'] >= 1 ? $btn('roam', '🔁 Explore here ⚡1') : '') . $btn('return', '🛣️ Back to the road');
    } elseif ((int)$exp['step'] < (int)$exp['steps_total']) {
        $rlTxt = null;   // v1.9.3: the same ambient line the adventure page shows for the next space
        if (function_exists('road_line') || is_file(__DIR__ . '/road_life.php')) {
            require_once __DIR__ . '/road_life.php';
            try { $rlWas = road_state(); if (empty($rlWas['bound'])) road_bind($u, $exp); $rlTxt = road_line(exp_scene($exp), ['seed' => road_line_seed($exp, (int)$exp['step'] + 1), 'record' => false]); if (empty($rlWas['bound'])) road_unbind(); } catch (Throwable $e) { $rlTxt = null; }
        }
        $what = '<span class="foe calm">' . ($rlTxt !== null ? '🍃 ' . e($rlTxt) : 'The thread glows on ahead.') . '</span>';
        $actions = $btn('continue', '🍄 Next space');
    } else {
        $wait = (int)strtotime($exp['arrive_at'] . ' UTC') - time();
        if ($wait > 0) {
            $what = '<span class="foe calm">' . e($to) . ' is in sight.</span>';   // v1.0.2: the countdown sits in the folded bar's summary
            $cd = '<b data-countdown="' . $wait . '">' . max(1, (int)ceil($wait / 60)) . ' min</b>';
            $actions = $btn('arrive', '🏡 Arrive', '', ' hidden data-show-at-zero');
        } else {
            $what = '<span class="foe calm">' . e($to) . ' is just ahead.</span>';
            $actions = $btn('arrive', '🏡 Arrive');
        }
    }
    require_once __DIR__ . '/adventure.php';
    $what = fight_replay_stage((int)$exp['id']) . $what;   // v1.4.0: Fight on replay (assets/fighton.js)
    $recent = array_slice($log, -2);
    // v1.0.2: the bar folds to one line (closed by default). Fights, problems and choices open it; otherwise the buttons sit on the line.
    $busy = $enc && in_array($enc['type'] ?? '', ['creature', 'problem', 'choice', 'meet'], true);
    $label = match ($exp['kind'] ?? 'walk') { 'explore' => '🌿 Off the path', 'delve' => '🕳️ ' . e($from), 'lair' => '🐉 ' . e($from), default => '🍄 → ' . e($to) . e($final) };
    $state = $busy ? ($enc['type'] === 'creature' ? '<b class="advalert">⚔️ Fight!</b>' : ($enc['type'] === 'meet' ? '<b class="advalert">💬 Someone’s on the road</b>' : '<b class="advalert">❓ Something’s in the way</b>'))
        : (isset($cd) ? '⏳ ' . $cd : '');
    $sum = '<summary class="advsum"><span class="advsl">' . $label . '</span><span class="advhp' . ($hp * 3 <= $max ? ' low' : '') . '">❤️ ' . $hp . '/' . $max . '</span>'
        . ($state !== '' ? '<span class="advst">' . $state . '</span>' : '') . (!$busy && $actions !== '' ? '<span class="advbtns">' . $actions . '</span>' : '') . '</summary>';
    return '<div class="advbar" role="region" aria-label="Your adventure"><details class="advfold"' . ($busy ? ' data-busy="' . (int)$exp['id'] . '-' . (int)($exp['step'] ?? 0) . '-' . (int)($exp['depth'] ?? 0) . '-' . e((string)($enc['type'] ?? '')) . '"' : '') . '>' . $sum . '<div class="advin">'
        . '<div class="advhead"><b>' . match ($exp['kind'] ?? 'walk') { 'explore' => '🌿 Exploring off the path near ' . e($from), 'delve' => '🕳️ ' . e($from), 'lair' => '🐉 ' . e($from), default => '🍄 ' . e($from) . ' → ' . e($to) . e($final) } . '</b>'
        . ($enc && $enc['type'] === 'creature' ? '' : '<span class="hpbox" title="Your health">❤️ Your health <meter min="0" max="' . $max . '" low="' . (int)ceil($max / 3) . '" optimum="' . $max . '" value="' . $hp . '"></meter> '
        . $hp . '/' . $max . ($lost > 0 ? ' <small class="lost">(−' . $lost . ' taken)</small>' : '') . '</span>')
        . '<span class="lvl">danger lv ' . (int)$exp['level'] . '</span>'
        . '<a href="' . e(url('adventure.php')) . '">Journal →</a></div>'
        . mycelium_track($exp, true)
        . '<div class="advnow">' . $what . (isset($actionsRow) ? $actionsRow : '<span class="advbtns">' . $actions . '</span>') . '</div>'   // v1.0.2: the line's copy of the buttons hides while open
        . ($recent && !($enc && $enc['type'] === 'creature') ? '<div class="advlog">' . implode(' · ', array_map('e', array_reverse($recent))) . '</div>' : '')
        . '</div></details></div>';
}

/**
 * A board-game track for a walk along the mycelium: start space, one space per step, destination.
 * Done spaces glow, the gnome's hat marks where they are, and a waiting encounter shows on the gnome's space.
 */
function mycelium_track(array $exp, bool $small = false): string
{
    if (in_array($exp['kind'] ?? 'walk', ['delve', 'lair'], true)) {   // v0.7.26: rooms of a delve, or the lair
        $depth = (int)$exp['depth'];
        $total = (int)$exp['steps_total'];
        $enc = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
        $mark = $enc ? ($enc['type'] === 'creature' ? '⚔️' : '❓') : '';
        $done = ($exp['status'] ?? '') !== 'active';
        $cells = ['<span class="sp node' . ($depth === 0 ? ' here' : ' done') . '">' . ($depth === 0 ? '🎩' : ($exp['kind'] === 'lair' ? '🐉' : '🕳️')) . '</span>'];
        for ($i = 1; $i <= $total; $i++) {
            $here = $i === $depth && !$done;
            $cells[] = '<span class="sp t-hard' . ($here ? ' here' : ($i < $depth || $done ? ' done' : '')) . '">' . ($here ? '🎩' . $mark : ($exp['kind'] === 'lair' ? '🐉' : '🚪')) . '</span>';
        }
        if ($exp['kind'] === 'delve') $cells[] = '<span class="sp node">💰</span>';
        return '<div class="track' . ($small ? ' small' : '') . '">' . implode('<i class="thread"></i>', $cells) . '</div>';
    }
    if (($exp['kind'] ?? 'walk') === 'explore') {   // v0.7.25: the road, then each step out, coloured by danger
        require_once __DIR__ . '/explore.php';
        $depth = (int)$exp['depth'];
        $enc = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
        $mark = $enc ? ($enc['type'] === 'creature' ? '⚔️' : '❓') : '';
        $back = ($exp['status'] ?? '') !== 'active';
        $cells = ['<span class="sp node' . ($depth === 0 || $back ? ' here' : ' done') . '">' . ($depth === 0 || $back ? '🎩' : '🛣️') . '</span>'];
        for ($i = 1; $i <= $depth; $i++) {
            $cells[] = '<span class="sp t-' . explore_tier($i)[1] . ($i === $depth && !$back ? ' here' : ' done') . '">' . ($i === $depth && !$back ? '🎩' . $mark : '🌿') . '</span>';
        }
        if (!$back) $cells[] = '<span class="sp t-' . explore_tier($depth + 1)[1] . '">❔</span>';
        return '<div class="track explore' . ($small ? ' small' : '') . '" aria-label="' . $depth . ' steps off the path">' . implode('<i class="thread"></i>', $cells) . '</div>';
    }
    $total = (int)$exp['steps_total'];
    $step = min((int)$exp['step'], $total);
    $enc = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
    $mark = $enc ? ($enc['type'] === 'creature' ? '⚔️' : ($enc['type'] === 'meet' ? '💬' : '❓')) : '';
    $arrived = ($exp['status'] ?? '') === 'done';
    $cells = ['<span class="sp node' . ($step === 0 && !$arrived ? ' here' : ' done') . '">' . ($step === 0 && !$arrived ? '🎩' : '🏠') . '</span>'];
    for ($i = 1; $i <= $total; $i++) {
        $here = $i === $step && !$arrived;
        $cls = $here ? ' here' : ($i < $step || $arrived ? ' done' : '');
        $cells[] = '<span class="sp' . $cls . '">' . ($here ? '🎩' . $mark : '🍄') . '</span>';
    }
    $cells[] = '<span class="sp node' . ($arrived ? ' here' : '') . '">' . ($arrived ? '🎩' : '🏡') . '</span>';
    return '<div class="track' . ($small ? ' small' : '') . '" aria-label="Space ' . $step . ' of ' . $total . '">' . implode('<i class="thread"></i>', $cells) . '</div>';
}

/**
 * v0.8.3: the player menu: grouped icon tiles with little badges for things that need you. On phones it's a sheet that slides up
 * from the bottom (the ☰ checkbox); on a computer it's the side menu. Badges are cached for a minute so every page stays quick.
 */
function nav_sheet(array $u, string $page): string
{
    $uid = (int)$u['id'];
    $b = $_SESSION['nav_badges'] ?? null;
    if (!$b || ($b['at'] ?? 0) < time() - 60 || ($page === 'garden.php' && ($b['at'] ?? 0) < time() - 5)) {   // v1.4.0: fresh on the garden page (cover crops never counted)
        $b = ['at' => time(), 'garden' => 0, 'games' => 0, 'fair' => 0];
        try {
            $b['garden'] = (int)q_val('SELECT COUNT(*) FROM plot_tiles t JOIN plants p ON p.id = t.plant_id WHERE t.plot_id = ? AND p.kind <> \'cover\' AND t.growth_seconds >= p.grow_minutes * 60',
                [(int)($u['active_plot_id'] ?? 0)]);
            require_once __DIR__ . '/games.php';
            foreach (array_keys(GAMES) as $g) $b['games'] += game_plays_left($uid, $g) > 0 ? 1 : 0;
            $b['fair'] = (int)q_val('SELECT COUNT(*) FROM fair_best f WHERE f.user_id = ? AND f.month = ? AND NOT EXISTS
                (SELECT 1 FROM fair_entries e WHERE e.user_id = f.user_id AND e.month = f.month AND e.cat = f.cat AND e.score >= f.score)', [$uid, job_period_key('monthly')]);
            require_once __DIR__ . '/quests_view.php';   // v1.7.5: the Tasks badge = jobs + quests + orders ready (not errands carried), same sums as the tab badges
            $tc = tasks_counts($u);
            $b['jobs'] = (int)$tc['jobs'] + (int)$tc['quests'] + (int)$tc['orders'];
            $np = (int)q_val("SELECT COUNT(*) FROM player_friends WHERE friend_id = ? AND status = 'pending'", [$uid]);   // v1.0.0
            $b['pals'] = $np ? $np . ' new' : '';
        } catch (Throwable $e) {
            // a badge is never worth a broken page
        }
        $_SESSION['nav_badges'] = $b;
    }
    $tile = function (string $file, string $icon, string $label, string $badge = '', string $slug = '') use ($page): string {
        $cur = $page . (isset($_GET['tab']) && $_GET['tab'] === 'craft' ? '?tab=craft' : '');
        if ($page === 'folk.php') $cur = 'villagers.php';   // v2.0.39: villagers have their own page   // v1.7.0 menu: Games and Jobs & quests light up on all their tabs
        $on = $cur === $file;
        $bar = in_array($file, ['garden.php', 'world.php', 'inventory.php', 'town.php', 'jobs.php'], true);   // v1.0.0.1: already in the phone's bottom bar, so the phone sheet skips it
        return '<a class="navtile' . ($on ? ' on' : '') . ($bar ? ' inbar' : '') . '" href="' . e(url($file)) . '"' . ($on ? ' aria-current="page"' : '') . '><span class="nti">' . ($slug !== '' ? nav_icon($slug, $icon, 20) : e($icon)) . '</span>'
            . '<span class="ntl">' . e($label) . '</span>' . ($badge !== '' ? '<span class="ntb">' . e($badge) . '</span>' : '') . '</a>';   // menu icons: nav-{slug} art, else placeholder, else emoji
    };
    // menu icons: [file, emoji, label, badge, icon slug]. Account sits under the groups; Games moved into Out & about.
    $trekNav = (int)($u['level'] ?? 0) >= (int)setting('trek_level') && (setting('trek_open') === '1' || ($u['role'] ?? '') === 'admin');   // v1.8.0: Treks tile once the gnome may go (admins always)
    $groups = [
        'You' => [['gnome.php', '🧙', 'My Gnome', '', 'gnome'], ['book.php', '📖', 'Almanac', '', 'almanac'], ['inventory.php', '🎒', 'Satchel', '', 'satchel'], ['inventory.php?tab=craft', '🔨', 'Crafting', '', 'crafting']],
        'Grow' => [['garden.php', '🏡', 'Garden', $b['garden'] ? $b['garden'] . ' ready' : '', 'garden'], ['arrange.php', '💐', 'Arranging', '', 'arranging']],
        'Out & about' => [['world.php', '🌍', 'World', '', 'world'], ['town.php', '📍', 'Here', '', 'town'], ['villagers.php', '👥', 'Villagers', '', 'villagers'],
            ['games.php', '🎲', 'Games', $b['games'] ? $b['games'] . ($b['fair'] ? ' · 🏆' : ' to play') : ($b['fair'] ? '🏆 fair' : ''), 'games']]
            + ($trekNav ? [99 => ['trek.php', '🥾', 'Treks', '', 'treks']] : []),   // v1.7.0 menu: Contests is a tab on Games; v1.8.0 Treks (level + open setting, admins always)
        'Together' => [['market.php', '🤝', 'Trading', '', 'trading'], ['community.php', '🌻', 'Together', '', 'together'], ['jobs.php', '📋', 'Tasks', !empty($b['jobs']) ? $b['jobs'] . ' ready' : '', 'tasks'], ['pals.php', '👫', 'Gnome friends', $b['pals'] ?? '', 'friends']],
    ];
    if (tour_active($u) && (int)$u['level'] < 5) array_unshift($groups['You'], ['welcome.php', '🌱', 'Getting started', '', 'start']);   // v1.7.0 menu: only while the tour runs and below level 5
    require_once __DIR__ . '/festival.php';   // v1.0.0: a Festival tile while one runs
    if (festival_active()) array_splice($groups['Together'], 3, 0, [['festival.php', festival_active()['icon'], 'Festival', '', 'festival']]);   // v1.7.0 menu: no 'on' badge (the status line shows the festival)
    require_once __DIR__ . '/destination.php';
    $ds = function_exists('dest_status') ? dest_status($u) : null;
    $h = '<div class="navhead"><a class="navme" href="' . e(url('gnome.php')) . '">' . gnome_avatar($u, 40) . '<span><b>' . e(gnome_name($u)) . '</b></span></a>'
        . '<button type="button" class="navx" aria-label="Close the menu">✕</button></div>'
        . '<div class="navrow"><p class="navstatus">' . money((int)$u['coins'])
        . ($ds ? ' · 🏁 ' . e(dest_name($uid, $ds[0])) . ', ' . (int)$ds[1] . ' stop' . ($ds[1] === 1 ? '' : 's') : '') . '</p>'
        . '<a class="navhome" href="' . e(url('index.php')) . '"><span class="nti">' . nav_icon('today', '🏠', 20) . '</span> Today</a>' . theme_toggle('th-nav') . '</div>';   // v1.6.5: dark/light switch next to Today   // v1.0.0.1: one row on a phone
    foreach ($groups as $name => $tiles) {
        // menu icons: the groups stay open on every screen (no folding any more)
        $tl = '';
        foreach ($tiles as $t) $tl .= $tile($t[0], $t[1], $t[2], $t[3] ?? '', $t[4] ?? '');
        $h .= '<details class="navgroupt navfixed' . (str_contains($tl, 'navtile on') ? ' cur' : '') . '" open data-g="' . e($name) . '"><summary><h3>' . e($name) . '</h3></summary><div class="navtiles">' . $tl . '</div></details>';
    }
    $h .= '<div class="navtiles navacct">' . $tile('account.php', '⚙️', 'Account', '', 'account') . '</div>';   // Account sits at the bottom, under Together
    if (in_array($u['role'], ['admin', 'mod'], true)) {
        require_once __DIR__ . '/moderation.php';
        $n = open_report_count();
        $h .= '<details class="navstaff"' . ($n ? ' open' : '') . '><summary>🛡️ Staff tools' . ($n ? ' (' . $n . ')' : '') . '</summary>'
            . '<a class="adminlink" href="' . e(url('modtools.php')) . '">Moderation' . ($n ? ' (' . $n . ' reports)' : '') . '</a>'
            . ($u['role'] === 'admin' ? '<a class="adminlink" href="' . e(url('admin/index.php')) . '">Admin panel</a>' : '') . '</details>';
    }
    $h .= '<a class="navfeedback" href="' . e(url('feedback.php?from=' . urlencode($page))) . '"><span class="nti">' . nav_icon('feedback', '💬', 18) . '</span> Send feedback</a>';   // v0.8.6
    $h .= '<form method="post" action="' . e(url('logout.php')) . '" class="navlogout">' . csrf_field() . '<button class="linkbtn">Log out</button></form>';   // v0.9.2: phones hide the header's Log out
    $h .= '<p class="navfoot"><a href="' . e(url('page.php?p=rules')) . '">Rules</a> · <a href="' . e(url('page.php?p=privacy')) . '">Privacy</a>';
    foreach (q('SELECT slug, title FROM pages WHERE published = 1 AND show_in_nav = 1 ORDER BY title')->fetchAll() as $p) {
        if (in_array($p['slug'], ['rules', 'privacy'], true)) continue;
        $h .= ' · <a href="' . e(url('page.php?p=' . urlencode($p['slug']))) . '">' . e($p['title']) . '</a>';
    }
    return $h . '</p>';
}


/**
 * v0.9.6: the right column on a wide screen (CSS shows it from 1200px up; phones never see it). Pots, boosts and chores are drawn here;
 * the message list and the walk bar are NOT copied: site.js moves the one copy of each into this column on a wide screen and back on a small one.
 */
function right_rail(array $u): string
{
    require_once __DIR__ . '/crafting.php';
    $uid = (int)$u['id'];
    $onToday = !empty($GLOBALS['gv_today_page']);   // v1.9.2: the Today page already shows weather, boosts and jobs, so its rail keeps only Messages, Market and Pots
    $h = '<aside class="rail" aria-label="Right now"><div class="railsrv">' . ($onToday ? '' : hollow_rail_section(hollow_user_region($u))) . market_rail_section();   // v1.0.0 (+ wave 2b: market)
    $pots = cook_pots_list($uid);
    if ($pots) {
        $rd = count(array_filter($pots, fn($p) => $p['left'] <= 0));
        $h .= '<section class="rbox rpots" aria-labelledby="rt-pots"><h3 id="rt-pots">🍳 Pots' . ($rd ? ' <b class="rbadge">' . $rd . ' ready</b>' : '') . '</h3><ul class="rlist">';
        foreach ($pots as $p) {
            $h .= '<li><span>' . e($p['name']) . '</span> ' . ($p['left'] <= 0
                ? '<a class="rgo" href="' . e(url('inventory.php?tab=craft&c=cooking')) . '">Ready, collect</a>'
                : '<small class="rtime">' . e(effect_time($p['left'])) . '</small>') . '</li>';
        }
        $h .= '</ul></section>';
    }
    if ($onToday) return $h . '</div></aside>';
    $h .= '<section class="rbox rfx" aria-labelledby="rt-fx"><h3 id="rt-fx">✨ Boosts</h3>';
    $fx = active_effects($u);
    if ($fx) {
        $h .= '<ul class="rlist">';
        foreach ($fx as [$ic, $nm, $what, $sec]) {
            $h .= '<li><span><span aria-hidden="true">' . $ic . '</span> <b>' . e($nm === 'Meal' ? $what : $nm) . '</b>'
                . ($nm === 'Meal' ? ' <small class="muted">meal</small>' : '<br><small class="muted">' . e($what) . '</small>') . '</span><small class="rtime">' . e(effect_time($sec)) . '</small></li>';
        }
        $h .= '</ul>';
    } else {
        $h .= '<p class="muted rempty">No boosts. Eat or cook something.</p>';
    }
    $h .= '</section>';
    $jobs = q("SELECT period, title, qty, progress, stages, stages_paid FROM user_jobs WHERE user_id = ? AND status = 'active' ORDER BY id", [$uid])->fetchAll();
    $h .= '<section class="rbox rjobs" aria-labelledby="rt-jobs"><h3 id="rt-jobs">📋 Tasks</h3>';
    if ($jobs) {
        $h .= '<ul class="rlist">';
        foreach ($jobs as $j) {
            $multi = (int)$j['stages'] > 1;
            $d = $multi ? (int)$j['stages_paid'] : (int)$j['progress'];
            $m = max(1, $multi ? (int)$j['stages'] : (int)$j['qty']);
            $h .= '<li class="rjob"><span><a href="' . e(url('jobs.php')) . '">' . e($j['title']) . '</a> <small class="muted">' . e($j['period']) . '</small>'
                . '<progress max="' . $m . '" value="' . min($d, $m) . '" aria-label="' . e($j['title']) . ' progress"></progress></span><small class="rtime">' . $d . '/' . $m . '</small></li>';
        }
        $h .= '</ul>';
    } else {
        $h .= '<p class="muted rempty">No job yet. <a href="' . e(url('jobs.php')) . '">Tasks</a></p>';
    }
    return $h . '</section></div></aside>';
}
