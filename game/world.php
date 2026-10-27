<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/explore.php';   // v0.7.84: region_lands(), stop_near_land()
require_once __DIR__ . '/includes/roads.php';
require_once __DIR__ . '/includes/maps.php';
require_once __DIR__ . '/includes/place_ui.php';
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
$tab = in_array($_GET['tab'] ?? '', ['markets', 'gather', 'travel', 'map', 'seasons'], true) ? (string)$_GET['tab'] : 'go';   // v2.0.61: Go / Map / Gather / Shops; old here, travel and seasons links still land
if ($tab === 'seasons') redirect('town.php?view=stop&tab=seasons#seasons');   // Seasons & weather live on the Stop tab now
$travelOpen = $tab === 'travel';   // old links to the Fast travel tab open the fold on Go
if ($tab === 'travel') $tab = 'go';
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
<?= place_switcher_html($node, 'world') ?>
<?php $mapCode = !empty($node['region_id']) ? (string)q_val('SELECT code FROM regions WHERE id = ?', [$node['region_id']]) : ''; ?>
<?= place_header_html(is_file(__DIR__ . '/assets/img/scenes/map-' . $mapCode . '.png') ? 'map-' . $mapCode . '.png' : 'map-world.png', 'Map of ' . (string)$node['region'], 'World · ' . (string)$node['region'], '🌍 World', '', place_chips($u)) ?>
<?= place_tabs_html([
    'go' => ['🧭 Go', url('world.php'), ''],
    'map' => ['🗺️ Map', url('world.php?tab=map#regionmap'), ''],
    'gather' => ['🧺 Gather', url('world.php?tab=gather'), ''],
    'markets' => ['🏪 Shops', url('world.php?tab=markets'), ''],
    'here' => [in_array($node['kind'], ['market', 'hub'], true) ? '🏘️ Town square' : '🪧 Rest stop', url('town.php'), ''],
], $tab, 'World sections') ?>

<?php if (!$home): ?>
  <form method="post" class="box form">
    <?= csrf_field() ?><input type="hidden" name="do" value="set_region">
    <h3>Where is home?</h3>
    <p>Choose your home region. You’ll know how to grow its staple crops and its flowers, and you’ll get some seeds to start.</p>
    <?= region_select('region_id') ?>
    <button class="btn">Set home</button>
  </form>
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
<?php if ($tab === 'go'):
$nodeRegion = $node['region_id'] ? q_one('SELECT * FROM regions WHERE id = ?', [$node['region_id']]) : null;
$L = LANDSCAPES[$node['landscape'] ?? ''] ?? null;
$kindIcons = ['hub' => '🍄', 'market' => '🏘️', 'village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️'];
$nodeIcon = $kindIcons[loc_real_kind($node)] ?? ($L ? $L[0] : '📍');   // v1.2.2: delves are kind 'wonder' in locations
$road = road_of((int)$node['id']);
$onRoad = on_road((int)$node['id']);
?>
<?php // v2.0.61: GPS (route panel + seek chip) sits in a right column from 1200px wide, above the content on narrower screens
$gpsHtml = $goId ? dest_panel($u, $goId) : (($ds = dest_status($u)) ? dest_panel($u, (int)$ds[0]['id'], true) : '');   // v0.7.98: a stop was tapped
$gpsHtml .= seek_chip($u); ?>
<div class="pcols">
<?php if (trim($gpsHtml) !== ''): ?><aside class="paside" aria-label="Where you are headed"><?= $gpsHtml ?></aside><?php endif; ?>
<div class="pmain">
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

<?= go_panel_html($u, $node, $here, $badge, $kindIcons, $GL, $onRoad) ?>

<?php require_once __DIR__ . '/includes/letters.php'; echo letters_box($u);   // v0.8.1: Lost Letters ?>
<?= landmark_panel($u, $node) ?>

<details class="fold box travelfold" id="fasttravel"<?= $travelOpen ? ' open' : '' ?>><summary>🧭 Fast travel</summary>
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
</details>
</div>
</div>
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
