<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/explore.php';   // v0.7.84: region_lands(), stop_near_land()
require_once __DIR__ . '/includes/roads.php';
require_once __DIR__ . '/includes/maps.php';
$u = require_login();

if (is_post()) {
    csrf_check();
    refresh_energy($u);
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'travel') {
        [$ok, $msg] = travel_to($u, (int)($_POST['region_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'deed') {
        [$ok, $msg] = buy_land_deed($u, player_node($u));
        flash($msg, $ok ? 'ok' : 'err');
        if ($ok) redirect('garden.php');
    } elseif ($do === 'set_region' && empty($u['region_id'])) {
        $rid = (int)($_POST['region_id'] ?? 0);
        if (q_val('SELECT 1 FROM regions WHERE id = ?', [$rid])) {
            db()->beginTransaction();
            q('UPDATE users SET region_id = ? WHERE id = ? AND region_id IS NULL', [$rid, $u['id']]);
            give_home_seeds((int)$u['id'], $rid);
            db()->commit();
            flash('Welcome home! You’ve received seeds from your home region.');
        }
    }
    redirect('world.php');
}
require_once __DIR__ . '/includes/items.php';   // v1.5.2: ph_or_emoji

refresh_energy($u);
if (active_expedition((int)$u['id'])) {
    redirect('adventure.php');
}
$node = player_node($u);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
unlock_entries((int)$u['id'], 'village:' . $node['slug']);
unlock_entries((int)$u['id'], 'landmark:' . $node['slug']);
if (!empty($node['region_id'])) record_region_visit((int)$u['id'], (int)$node['region_id']);
$home = home_region($u);
$here = player_location($u);
$guidedRegions = guide_regions((int)$u['id']);
$locationShops = function (string $regionName): array {
    return q('SELECT s.*, l.name AS loc_name, l.id AS loc_id FROM shops s JOIN locations l ON l.id = s.location_id
              WHERE l.region = ? AND s.open = 1 ORDER BY s.name', [$regionName])->fetchAll();
};

function shop_cards(array $shops, array $u): string
{
    $out = '';
    foreach ($shops as $s) {
        $staff = staff_on_duty((int)$s['id']);
        // v1.2.2: a shop in a town you're not standing in can't be used: no link, and a way to walk there
        $reach = shop_reachable($u, $s);
        $title = $reach ? '<a href="' . e(url('shop.php?id=' . (int)$s['id'])) . '">' . e($s['name']) . '</a>' : e($s['name']);
        $out .= '<div class="box shopcard"><h3>' . $title . '</h3>'
            . '<p>' . e($s['description']) . '</p><p class="help">'
            . ($staff ? 'At the counter: ' . e(implode(', ', array_column($staff, 'name'))) : 'Closed — nobody on shift')
            . '</p>'
            . ($reach ? '' : '<p class="help">🚶 <a href="' . e(url('world.php?go=' . (int)$s['loc_id'] . '#gopanel')) . '">Walk to ' . e((string)$s['loc_name']) . '</a> to shop here.</p>')
            . '</div>';
    }
    return $out;
}

$regionList = all_regions();
// v0.7.47: "Where you are" and the world map are one page; Markets stays a tab
$tab = in_array($_GET['tab'] ?? '', ['markets', 'gather', 'travel', 'map'], true) ? (string)$_GET['tab'] : 'here';   // v1.6.3.5: + travel   // v0.7.97: Gather tab; fast travel is a fold beside the map
$travelOpen = ($_GET['tab'] ?? '') === 'travel';   // old links to the Fast travel tab open the fold
require_once __DIR__ . '/includes/seek.php';
$travelBase = (int)round((int)setting('travel_cost') * (100 - calling_perk($u, 'fast_travel_discount')) / 100);   // v1.2.2: the price after your calling's discount
if (isset($_GET['seek'])) {   // v0.7.97: choose what to seek (directions only)
    $sk = (string)$_GET['seek'];
    if ($sk === 'off' || $sk === '') unset($_SESSION['seek']);
    elseif (isset(seek_catalog((int)$u['id'])[$sk])) $_SESSION['seek'] = $sk;
}
[$GLOBALS['gv_seek_regions'], $GLOBALS['gv_seek_stops']] = seek_map_marks($u);
require_once __DIR__ . '/includes/destination.php';   // v0.7.98
if (($_GET['dest'] ?? '') === 'off') { dest_set((int)$u['id'], 0); $u['dest_id'] = null; }
$goId = (int)($_GET['go'] ?? 0);
$selRegion = (int)($_GET['r'] ?? 0) ?: null;
if ($selRegion !== null && !isset($_GET['tab'])) $tab = 'map';   // v1.6.6: maps have their own tab; old ?r= links land there
$worldOpen = isset($_GET['w']);   // v1.6.6: ?w=1 opens the world map fold
$lvl = (int)$u['level'];
/** A level badge: green at or below your level, amber a little above, red well above. */
$badge = function (int $min, int $max = 0) use ($lvl): string {
    $max = max($min, $max);
    $cls = $min <= $lvl ? 'ok' : ($min <= $lvl + 4 ? 'warn' : 'bad');
    return '<span class="lvbadge ' . $cls . '" title="Danger level' . ($cls === 'ok' ? ': fine for you' : ($cls === 'warn' ? ': a bit above your level' : ': well above your level')) . '">Lv ' . $min . ($max > $min ? '–' . $max : '') . ' <small class="muted">' . ($cls === 'ok' ? 'fine for you' : ($cls === 'warn' ? 'a bit high' : 'too high')) . '</small></span>';
};

page_header('World');
?>
<h1>🌍 World</h1>
<nav class="tabs">
  <a class="<?= $tab === 'here' ? 'on' : '' ?>" href="<?= e(url('world.php')) ?>">📍 Here</a>
  <a class="<?= $tab === 'map' ? 'on' : '' ?>" href="<?= e(url('world.php?tab=map#regionmap')) ?>">🗺️ Map</a>
  <a class="<?= $tab === 'gather' ? 'on' : '' ?>" href="<?= e(url('world.php?tab=gather')) ?>">🧺 Gather</a>
  <a class="<?= $tab === 'markets' ? 'on' : '' ?>" href="<?= e(url('world.php?tab=markets')) ?>">🏪 Shops</a>
  <a class="<?= $tab === 'travel' ? 'on' : '' ?>" href="<?= e(url('world.php?tab=travel')) ?>">🧭 Travel</a>
  <a href="<?= e(url('town.php')) ?>"><?= in_array($node['kind'], ['market', 'hub'], true) ? '🏘️ Town square' : '🪧 Rest stop' ?></a>
</nav>

<?php if (!$home): ?>
  <form method="post" class="box form">
    <?= csrf_field() ?><input type="hidden" name="do" value="set_region">
    <h3>Where is home?</h3>
    <p>Choose your home region. You’ll know how to grow its staple crops and its flowers, and you’ll get some seeds to start.</p>
    <?= region_select('region_id') ?>
    <button class="btn">Set home</button>
  </form>
<?php endif; ?>

<?php if ($tab === 'travel'):   // v1.6.3.5: Fast travel is its own tab ?>
<div class="travelfold" id="fasttravel">
  <p class="help">Hop to any region you’ve walked to: <?= money($travelBase) ?> (home is free).</p>
  <details class="fold"><summary>Key</summary><p class="help">🍄 Mossbottom is reachable from anywhere. 🏡 home · 📗 guide read · 🔒 walk there first. Lands: 🌾 grassland · 🌲 forest · 🌊 coast · ⛰️ mountain · 🏜️ desert · 🌴 rainforest · 🪷 wetland · ❄️ tundra · 🏝️ island.</p></details>
    <div class="regionlist">
    <?php foreach ($regionList as $r):
        $isHere = $r['gnomish_name'] === $here;
        $isHome = $home && (int)$home['id'] === (int)$r['id'];
        $hasGuide = in_array((int)$r['id'], $guidedRegions, true); ?>
      <div class="rrow<?= $isHere ? ' here' : '' ?>">
        <a href="<?= e(url('world.php?tab=map&r=' . (int)$r['id'] . '#regionmap')) ?>"><b><?= e($r['gnomish_name']) ?></b></a> <?= $badge(max(1, (int)$r['min_level'])) ?> <?= $isHome ? '🏡' : '' ?><?= $hasGuide ? '📗' : '' ?>
        <span class="rlands" role="group" aria-label="Lands here" title="Lands here"><?php foreach (region_lands((int)$r['id']) as $rl): $RL = LANDSCAPES[$rl] ?? null; if ($RL): ?><span role="img" aria-label="<?= e($RL[1]) ?>" title="<?= e($RL[1]) ?>"><?= ph_or_emoji('land-' . $rl, $RL[0], 20) /* v1.5.2 */ ?></span><?php endif; endforeach; ?></span>
        <span class="rgo"><?php if ($isHere): ?><b>🎩 Here</b><?php elseif (!can_fast_travel($u, (int)$r['id'])): ?><span class="muted">🔒 walk there first</span><?php else: ?>
          <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="travel"><input type="hidden" name="region_id" value="<?= (int)$r['id'] ?>">
            <button class="btn small">🧭 Travel<?php $tc = seek_travel_cost($u, (int)$r['id']); ?> · <?= $tc > 0 ? money($tc) : 'free' ?></button></form><?php endif; ?></span>
      </div>
    <?php endforeach; ?>
    </div>
</div>
<?php endif; ?>
<?php if ($tab === 'map'):   // v1.6.6: region map is its own tab; the world map folds below it
$mapRegion = $selRegion ?? ((int)($node['region_id'] ?? 0) ?: (int)($regionList[0]['id'] ?? 0)); ?>
<?php if (myc_on()): ?>
  <div class="regionmapbox" id="regionmap">
    <?= region_nav($u, $mapRegion) ?>
    <div class="mapwrap regionwrap mycwrap"><?= myc_region_block($u, $mapRegion, $goId, isset($_GET['full']))   /* v1.6.1: ?full=1 = the whole region */ ?></div>
    <p class="help maphelp">Tap any place to see how to get there.</p>
  </div>
<?php else: ?>
  <div class="regionmapbox" id="regionmap">
    <?= region_nav($u, $mapRegion) ?>
    <div class="mapwrap regionwrap"><div class="rzoom"><div class="rzctl" hidden><button type="button" class="btn small" data-z="in" aria-label="Zoom in">＋</button><button type="button" class="btn small" data-z="out" aria-label="Zoom out">−</button><button type="button" class="btn small" data-z="fit" aria-label="Whole region">⤢</button></div><?= region_map_svg($u, $mapRegion, $goId) ?></div></div>
    <?php /* v1.4.2: legend as chips; small sites are named when zoomed */ ?>
    <p class="help maphelp">Tap any place to see how to get there. Zoom ＋ to name the havens, wonders, delves and lairs.</p>
    <ul class="maplegend" aria-label="Map key"><li>🏘️ town</li><li>🏡 village</li><li>🏕️ haven</li><li>✨ wonder</li><li>🕳️ delve</li><li>🐉 lair</li><li>🏚️ ruins</li><li>❔ not visited</li><li>➜ next region</li><li>🎩 you</li></ul>
  </div>
<?php endif; ?>
<?= region_panel($u, $mapRegion) ?>
<div class="mapfolds">
<details class="fold mapfold" id="worldmap"<?= $worldOpen ? ' open' : '' ?>><summary>🌍 World map</summary>
<?php if (myc_on()): ?>
  <div class="mapwrap mycwrap"><?= world_map_svg($u, $mapRegion) ?></div>
  <p class="help">Tap a region to open its chamber: its town, roads and villages as big tap targets. 🎩 you · <a href="<?= e(url('town.php?view=villagers')) ?>">👤 villagers</a> · <a href="<?= e(url('world.php?tab=travel')) ?>">🧭 Fast travel</a> costs <?= money($travelBase) ?> (home is free).</p>
<?php else: ?>
  <div class="mapwrap"><?= world_map_svg($u, $mapRegion) ?></div>
  <p class="help">Tap a region to open its map: its town, roads and villages as big tap targets. Zoom the world with ＋ − (or pinch) and drag to look around. 🎩 you · 🏡 home garden · 🌱 other gardens · <a href="<?= e(url('town.php?view=villagers')) ?>">👤 villagers you know</a> · 📗 guide read · 🔒 not visited yet · 🍄 Mossbottom is reachable from anywhere.
    <a href="<?= e(url('world.php?tab=travel')) ?>">🧭 Fast travel</a> costs <?= money($travelBase) ?> (home is free).</p>
<?php endif; ?>
</details>
</div>
<?php endif; ?>
<?php if ($tab === 'here'):
$nodeRegion = $node['region_id'] ? q_one('SELECT * FROM regions WHERE id = ?', [$node['region_id']]) : null;
$L = LANDSCAPES[$node['landscape'] ?? ''] ?? null;
$kindIcons = ['hub' => '🍄', 'market' => '🏘️', 'village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️'];
$nodeIcon = $kindIcons[loc_real_kind($node)] ?? ($L ? $L[0] : '📍');   // v1.2.2: delves are kind 'wonder' in locations
$road = road_of((int)$node['id']);
$onRoad = on_road((int)$node['id']);
?>
<?php if ($goId): echo dest_panel($u, $goId);   // v0.7.98: a stop was tapped
elseif ($ds = dest_status($u)): echo dest_panel($u, (int)$ds[0]['id'], true); endif; ?>
<?= seek_chip($u) ?>
<?php require_once __DIR__ . '/includes/gathering.php';   // v0.7.80: the land you're standing in, for the card and Gather here
$gatherLand = (string)($node['landscape'] ?: 'grassland');
$GL = LANDSCAPES[$gatherLand] ?? ['🌱', ucfirst($gatherLand)]; ?>
<div class="box place here">
  <div class="youare">
    <span class="bigicon"><?= $nodeIcon ?></span>
    <div>
      <h2><?= e($node['name']) ?></h2>
      <p class="where">🎩 You are here · <?= e((string)$node['region']) ?><?= $nodeRegion ? ' ' . $badge(max(1, (int)$nodeRegion['min_level'])) : '' ?>
        · <?= $GL[0] ?> <?= e($GL[1]) ?><?php if ($onRoad && $node['kind'] === 'village' && ($NL = LANDSCAPES[stop_near_land($node)] ?? null)): ?> (2 steps out: <?= $NL[0] ?> <?= e($NL[1]) ?>)<?php endif; ?>
        <?= $road && $node['kind'] !== 'market' ? ' · on the road ' . e($road['name']) : (!$onRoad && $node['kind'] !== 'hub' && $node['kind'] !== 'market' ? ' · 🌿 off the road' : '') ?></p>
    </div>
  </div>
  <?php if ($road && $node['kind'] !== 'market') echo road_board($u, $road['stops'], (int)$node['id']);   // the road you're on, town to town ?>
  <?php if (($blurb = village_blurb($node)) !== ''): ?><p class="muted placedesc"><?= e($blurb) ?></p><?php endif; ?>
</div>

<?php $routes = visible_routes($u, (int)$node['id']); ?>
<div class="box">
  <h3>🧭 Where to next?</h3>
  <?php $shiftLeft = ts($u['community_shift_until'] ?? null) - time();
  if ($shiftLeft > 0):   // v0.7.48: say so instead of offering walks that would be refused ?>
    <p class="box notice">🧑‍🌾 You’re on a tending shift at the community garden for another <b><?= e(nice_time($shiftLeft)) ?></b>. Finish it, or end it early, before you set off.
      <form method="post" action="<?= e(url('community.php')) ?>" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="end_shift"><button class="btn small alt">End shift</button></form>
      <a class="btn small" href="<?= e(url('community.php')) ?>">Back to the garden →</a></p>
  <?php elseif ($routes): ?>
    <div class="gogrid">
      <?php foreach ($routes as $r):
          $to = $r['to'];
          $tL = LANDSCAPES[$to['landscape'] ?? ''] ?? null;
          $seen = in_array($to['kind'], ['market', 'hub'], true) || place_known((int)$u['id'], $to);
          [$dMin, $dMax] = route_danger($u, $r);
          $isRoad = ($r['kind'] ?? '') === 'road';
          $kindWord = $to['kind'] === 'market' ? 'Town' : ucfirst(loc_real_kind($to));   // v1.2.2
          $dir = compass_between((int)$node['id'], (int)$to['id']);   // v1.7.6: one short meta line
          $meta = [];
          if ($dir) $meta[] = '🧭 ' . e($dir);
          $meta[] = (int)$r['steps'] . ' steps';
          $meta[] = '⚡' . route_energy($u, $r);
          if (!empty($r['quick'])) $meta[] = '💨 ' . nice_time((int)$r['walk_min'] * 60);
          if ($to['kind'] === 'market' && $to['region'] !== $node['region']) $meta[] = 'in ' . e($to['region']);
          $metaLine = ($isRoad ? '' : '🌿 ') . implode(' · ', $meta); ?>
        <form method="post" action="<?= e(url('adventure.php')) ?>" class="goform"><?= csrf_field() ?>
          <input type="hidden" name="do" value="start"><input type="hidden" name="route_id" value="<?= (int)$r['id'] ?>">
          <button class="gocard" title="<?= e($kindWord . ' · ' . ($isRoad ? 'Road' : 'Side path')) ?>" aria-label="<?= e('Go to ' . $to['name'] . ' (' . $kindWord . ', ' . ($isRoad ? 'road' : 'side path') . ')') ?>">
            <span class="goicon"><?= $kindIcons[loc_real_kind($to)] ?? ($tL ? $tL[0] : '📍') ?></span>
            <span class="gotext"><span class="goname"><b><?= e($to['name']) ?></b><?= $seen ? '' : ' <span class="tag">new</span>' ?></span>
              <small><?= $metaLine ?></small></span>
            <span class="goside"><?= $badge($dMin, $dMax) ?><span class="goarrow" aria-hidden="true">›</span><span class="gosr">Go</span></span>
          </button>
        </form>
      <?php endforeach; ?>
    </div>
  <?php else: ?>
    <p class="muted">No paths lead from here yet.</p>
  <?php endif; ?>
  <div class="goextra">
    <?php if ($onRoad && $shiftLeft <= 0): ?>
      <form method="post" action="<?= e(url('adventure.php')) ?>" class="gotileform"><?= csrf_field() ?><input type="hidden" name="do" value="explore">
        <button class="btn alt gotile" title="Wander off the path"><span class="gtic">🌿</span><span>Wander <span class="cost">⚡1</span></span></button></form>
    <?php endif; ?>
    <?php if (in_array($node['kind'], ['market', 'hub'], true)): ?>
      <a class="btn alt gotile" href="<?= e(url('town.php')) ?>" title="<?= e($here . ' town square') ?>"><span class="gtic">🏘️</span><span>Town square</span></a>
    <?php elseif ($node['kind'] === 'village'): ?>
      <a class="btn alt gotile" href="<?= e(url('town.php')) ?>" title="<?= e($node['name'] . ' rest stop') ?>"><span class="gtic">🪧</span><span>Rest stop</span></a>
    <?php endif; ?>
    <a class="btn alt gotile" href="<?= e(url('world.php?tab=travel#fasttravel')) ?>"><span class="gtic">🧭</span><span>Fast travel</span></a>
    <?php if ($shiftLeft <= 0): // v0.7.97: gathering has its own tab ?>
      <a class="btn alt gotile" href="<?= e(url('world.php?tab=gather')) ?>" title="Gather here, or seek something on the Gather tab"><span class="gtic">🧺</span><span>Gather <small><?= $GL[0] ?> <?= e($GL[1]) ?></small></span></a>
    <?php endif; ?>
  </div>
  <?php if ($next = next_region_suggestion($u)): ?>
    <p class="nextup">🧭 Next: <a href="<?= e(url('world.php?tab=map&r=' . (int)$next['id'] . '#regionmap')) ?>"><b><?= e($next['gnomish_name']) ?></b></a> <?= $badge(max(1, (int)$next['min_level'])) ?> <span class="nxvia">via <?= e($next['via']) ?> ›</span></p>
  <?php endif; ?>
  <details class="helpfold"><summary>❓ How travelling works</summary>
    <p class="help">You walk the underground mycelium one stop at a time. 🛣️ Roads run town to town past three villages. Next to home (towns, havens, villages with your garden) they match your level, or a few levels under it with <a href="<?= e(url('gnome.php#easyroads')) ?>">easy roads</a> on. Further along they stay at the recommended level of the region they lead into, so places you’ve outgrown stay easy: a quick walk 💨 takes only half the time. Wandering off the road starts as easy as the road you left and gets harder one step at a time; wild country, with bosses, starts at step <?= (int)setting('explore_wild_from') ?>. Past step <?= (int)setting('explore_deep_from') ?> lie the deep wilds, matched to your own level; areas you’ve outgrown give less XP and fewer Petals.
      🌿 Side paths lead to places you’ve found by wandering off the road. The badge is the danger level: green is fine for you, amber is a bit above, red is well above.
      Losing a fight never costs items: you wake up back where you started. Once you’ve walked to a region, you can fast travel there from the 🧭 Travel tab.</p>
  </details>
</div>

<?php require_once __DIR__ . '/includes/letters.php'; echo letters_box($u);   // v0.8.1: Lost Letters ?>
<?= landmark_panel($u, $node) ?>

<?php // v2.0.4 menu folds: Seasons & weather (was seasons.php) is a fold here; ?tab=seasons opens it
$sRegion = hollow_user_region($u);
$sn = hollow_now($sRegion);
$sNext = hollow_next_season();
$sFc = hollow_forecast($sRegion, 3);
$sCh = hollow_weather_chances($sn['season'], $sRegion);
arsort($sCh);
$sRegions = q('SELECT code, gnomish_name AS name, real_name FROM regions ORDER BY id')->fetchAll(); ?>
<details class="fold box seasonfold" id="seasons"<?= ($_GET['tab'] ?? '') === 'seasons' ? ' open' : '' ?>>
  <summary><?= $sn['season_emoji'] ?> Seasons &amp; weather: <?= e($sn['season_label']) ?>, <?= $sn['weather_emoji'] ?> <?= e($sn['weather_label']) ?></summary>
  <p><b><?= e(hollow_line($sRegion)) ?></b></p>
  <p class="muted"><?= e(HOLLOW_SEASONS[$sn['season']][3]) ?> <?= e(HOLLOW_WEATHER[$sn['weather']][3]) ?>
    <?= $sn['mode'] === 'game' ? 'Day ' . $sn['season_day'] . ' of ' . $sn['season_length'] . '.' : 'Following the real calendar.' ?>
    <?= e(HOLLOW_SEASONS[$sNext['season']][0] . ' ' . HOLLOW_SEASONS[$sNext['season']][1]) ?> begins in <?= (int)$sNext['in_days'] ?> day<?= $sNext['in_days'] === 1 ? '' : 's' ?>.
    <?= $sn['season_forced'] || $sn['weather_forced'] ? '<br><small>(An override is on' . ($sn['season_forced'] ? ': season' : '') . ($sn['weather_forced'] ? ': today’s weather' : '') . '.)</small>' : '' ?></p>
  <h3>Forecast</h3>
  <div class="fcgrid">
  <?php foreach ($sFc as $f): ?>
    <div class="box"><b><?= e($f['label']) ?></b><div class="wxbig" aria-hidden="true"><?= $f['emoji'] ?></div><?= e($f['wlabel']) ?></div>
  <?php endforeach; ?>
  </div>
  <h3>The year</h3>
  <div class="seasonrow">
  <?php foreach (HOLLOW_SEASONS as $k => $s): ?>
    <div class="box<?= $k === $sn['season'] ? ' cur' : '' ?>"><div class="wxbig" aria-hidden="true"><?= $s[0] ?></div><b><?= e($s[1]) ?></b><br><small class="muted"><?= $sn['mode'] === 'game' ? hollow_season_length() . ' days' : '3 months' ?></small></div>
  <?php endforeach; ?>
  </div>
  <h3>What <?= e(HOLLOW_SEASONS[$sn['season']][1]) ?> weather is like</h3>
  <table class="wxtable">
  <?php foreach ($sCh as $k => $pct): if ($pct <= 0) continue; ?>
    <tr><td><?= HOLLOW_WEATHER[$k][0] ?> <?= e(HOLLOW_WEATHER[$k][1]) ?></td><td><?= $pct ?>%</td></tr>
  <?php endforeach; ?>
  </table>
  <h3>Around the world today</h3>
  <table class="wxtable">
  <?php foreach ($sRegions as $r): $w = hollow_weather_info(hollow_weather($r['code']), 'day'); ?>
    <tr><td><?= e($r['name']) ?> <small class="muted">(<?= e($r['real_name']) ?>)</small></td><td><?= $w['emoji'] ?> <?= e($w['label']) ?></td></tr>
  <?php endforeach; ?>
  </table>
  <?php if (is_admin()): ?><p class="help"><a href="<?= e(url('admin/settings.php#s-seasons-weather')) ?>">Admin: seasons &amp; weather settings and overrides</a></p><?php endif; ?>
</details>

<?php if ($node['kind'] === 'village' && $node['region_id']):
    $mine = q_one('SELECT * FROM plots WHERE user_id = ? AND region_id = ?', [$u['id'], $node['region_id']]);
    $owned = (int)q_val('SELECT COUNT(*) FROM plots WHERE user_id = ?', [$u['id']]); ?>
  <div class="box deed">
    <?php if ($mine): ?>
      🏡 Your garden in <?= e($nodeRegion['gnomish_name'] ?? 'this region') ?>: <b><?= e($mine['garden_name'] ?: 'Garden') ?></b>.
    <?php elseif ($owned < max_gardens($u)): ?>
      📜 Land for sale: start a garden here for <b><?= money(deed_cost((int)$u['id'])) ?></b>. Native crops grow faster at home.
      <form method="post" class="inline" data-confirm="Buy a land deed here for <?= number_format(deed_cost((int)$u['id'])) ?>?"><?= csrf_field() ?>
        <input type="hidden" name="do" value="deed"><button class="btn small">Buy land deed</button></form>
    <?php else: ?>
      <span class="muted">📜 Land for sale here<?= next_garden_level($u) ? ' (another garden from gnome level ' . next_garden_level($u) . ')' : ' (you tend as many gardens as a gnome can)' ?>.</span>
    <?php endif; ?>
  </div>
<?php endif; ?>

<?php endif; ?>


<?php if ($tab === 'gather'):   // v0.7.97: gather where you stand, and seek things elsewhere (directions only)
    require_once __DIR__ . '/includes/gathering.php';
    $gLand = (string)($node['landscape'] ?: 'grassland');
    $cat = seek_catalog((int)$u['id']);
    $sg = seek_current((int)$u['id']);
    $shifting = ts($u['community_shift_until'] ?? null) > time();
    if ($sg) $_SESSION['gather_game_last'] = (string)$sg['tool'];   // the game opens on the tool for what you seek ?>
  <?= seek_chip($u) ?>
  <?php if ($shifting): ?><p class="box notice">🧑‍🌾 You’re on a tending shift at the community garden. Finish it before you gather.</p>
  <?php else: ?>
    <?php if ($sg && (in_array('any', $sg['lands'], true) || in_array($gLand, $sg['lands'], true))): ?><p class="flash ok">🎯 <?= e(seek_name($sg)) ?> can be gathered right here.</p><?php endif; ?>
    <?= gather_here_box($u, $gLand, url('gather.php'), '<input type="hidden" name="back" value="world.php?tab=gather">') ?>
  <?php endif; ?>
  <div class="box seekbox">
    <h3>🎯 Seek something</h3>
    <form method="get" action="<?= e(url('world.php')) ?>" class="seekform"><input type="hidden" name="tab" value="gather">
      <select name="seek" aria-label="What to seek">
        <option value="">Choose what you’re looking for…</option>
        <?php $byTool = []; foreach ($cat as $g) $byTool[$g['tool']][] = $g;
        foreach ($byTool as $tool => $list): ?>
          <optgroup label="<?= e((TOOL_TYPES[$tool][1] ?? '') . ' ' . ucfirst(GATHER_TOOL_NOUN[$tool] ?? $tool)) ?>">
            <?php foreach ($list as $g): ?><option value="<?= e($g['slug']) ?>"<?= $sg && $sg['slug'] === $g['slug'] ? ' selected' : '' ?>><?= e($g['known'] ? $g['name'] : '??? · ' . implode(', ', array_map(fn($l) => $l === 'any' ? 'anywhere' : (LANDSCAPES[$l][1] ?? $l), $g['lands']))) ?><?= $g['rarity'] !== 'common' ? ' (' . e($g['rarity']) . ')' : '' ?></option><?php endforeach; ?>
          </optgroup>
        <?php endforeach; ?>
      </select>
      <button class="btn small">🎯 Seek</button>
    </form>
    <?php if ($sg): [$tok, $toolText] = seek_tool_check((int)$u['id'], $sg); ?>
      <p class="help"><?= e(seek_name($sg)) ?> is found in <?= e(implode(', ', array_map(fn($l) => $l === 'any' ? 'any land' : (LANDSCAPES[$l][1] ?? $l), $sg['lands']))) ?>. <span class="<?= $tok ? 'good' : 'bad' ?>"><?= e($toolText) ?></span></p>
      <div class="seekplaces">
      <?php foreach (seek_places($u, $sg, 3) as $i => $p): $PL = LANDSCAPES[$p['land']] ?? ['🌱', $p['land']]; ?>
        <div class="seekplace<?= $i ? '' : ' best' ?>">
          <b><?= $i ? '' : '⭐ ' ?><?= e($p['loc']['name']) ?></b> <span class="muted">· <?= e($p['region']) ?></span><br>
          <?= $PL[0] ?> <?= e($PL[1]) ?>, <?= e(seek_depth_text($p['depth'])) ?><br>
          <small><?= e(seek_how_text($u, $p)) ?></small>
          <?php if ($p['how'] >= 1): ?><br><a class="small" href="<?= e(url('world.php?go=' . (int)$p['loc']['id'] . '#gopanel')) ?>">🧭 How do I get there?</a> · <a class="small" href="<?= e(url('world.php?tab=map&r=' . (int)$p['loc']['region_id'] . '#regionmap')) ?>">🗺️ Show on the map</a><?php endif; ?>
        </div>
      <?php endforeach; ?>
      </div>
      <p class="help">🎯 These places glow on the 🗺️ World map, and while you’re exploring the chip at the top tells you which step to reach. You do the walking.</p>
    <?php else: ?>
      <p class="help">Pick anything you can gather, even things you haven’t found yet, and you’ll be told the nearest places to look: which road stop, and how many steps off the road.</p>
    <?php endif; ?>
  </div>
<?php endif; ?>

<?php if ($tab === 'markets'): ?>
<h2>Shops in <?= e($here) ?></h2>
<?php
$shops = $locationShops($here);
echo $shops ? '<div class="shopgrid">' . shop_cards($shops, $u) . '</div>' : '<p class="muted">No shops here yet.</p>';
?>

<h2>Mossbottom hub <small class="muted">— reachable from anywhere</small></h2>
<div class="shopgrid"><?= shop_cards($locationShops(HUB_REGION), $u) ?></div>

<?php endif; ?>
<?php page_footer();
