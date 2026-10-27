<?php
declare(strict_types=1);
// v2.0.61: shared place UI pieces (World / Town / Stops consolidation, phase 1: moved out of world.php unchanged)

/** Where to next: route cards, Wander, Fast travel, Gather, how-it-works fold. */
function go_panel_html(array $u, array $node, string $here, callable $badge, array $kindIcons, array $GL, bool $onRoad): string
{
    ob_start(); ?>
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
<?php return (string)ob_get_clean();
}

/** Seasons & weather fold (?tab=seasons opens it). */
function season_fold_html(array $u): string
{
    ob_start(); ?>
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
<?php return (string)ob_get_clean();
}

/** Land for sale / your garden card at village stops. */
function land_card_html(array $u, array $node, ?array $nodeRegion): string
{
    ob_start(); ?>
<?php if ($node['kind'] === 'village' && $node['region_id']):
    $mine = q_one('SELECT * FROM plots WHERE user_id = ? AND region_id = ?', [$u['id'], $node['region_id']]);
    $owned = (int)q_val('SELECT COUNT(*) FROM plots WHERE user_id = ?', [$u['id']]); ?>
  <div class="box deed">
    <?php if ($mine): ?>
      🏡 Your garden in <?= e($nodeRegion['gnomish_name'] ?? 'this region') ?>: <b><?= eu($mine['garden_name'] ?: 'Garden') ?></b>.
    <?php elseif ($owned < max_gardens($u)): ?>
      📜 Land for sale: start a garden here for <b><?= money(deed_cost((int)$u['id'])) ?></b>. Native crops grow faster at home.
      <form method="post" action="<?= e(url('world.php')) ?>" class="inline" data-confirm="Buy a land deed here for <?= number_format(deed_cost((int)$u['id'])) ?>?"><?= csrf_field() ?>
        <input type="hidden" name="do" value="deed"><button class="btn small">Buy land deed</button></form>
    <?php else: ?>
      <span class="muted">📜 Land for sale here<?= next_garden_level($u) ? ' (another garden from gnome level ' . next_garden_level($u) . ')' : ' (you tend as many gardens as a gnome can)' ?>.</span>
    <?php endif; ?>
  </div>
<?php endif; ?>
<?php return (string)ob_get_clean();
}

// Town helpers moved from town.php (phase 1b, unchanged)
/** v2.0.4 menu folds: everyone you've met, where they are now, with search and filters (was the folk.php list). */
function town_known_html(array $u, bool $hub, bool $title = true): string
{
    require_once __DIR__ . '/maps.php';
    require_once __DIR__ . '/folk_list.php';
    require_once __DIR__ . '/friends.php';
    $uid = (int)$u['id'];
    $all = met_npcs($uid);
    $qs = trim((string)($_GET['q'] ?? ''));
    $f = (string)($_GET['f'] ?? '');
    $reg = (string)($_GET['r'] ?? '');
    $regions = array_values(array_unique(array_filter(array_map(fn($n) => (string)($n['home']['region'] ?? ''), $all))));
    sort($regions);
    $list = array_filter($all, function ($n) use ($qs, $f, $reg, $u) {
        if ($qs !== '' && stripos($n['name'] . ' ' . $n['species'] . ' ' . $n['personality'], $qs) === false) return false;
        if ($f === 'here' && !npc_here($u, (int)$n['id'])) return false;
        if ($reg !== '' && ($n['home']['region'] ?? '') !== $reg) return false;
        return true;
    });
    $byLevel = [];
    foreach ($list as $n) $byLevel[$n['level']['index']][] = $n;
    krsort($byLevel);
    $total = (int)q_val('SELECT COUNT(*) FROM npcs WHERE active = 1');
    $h = ($title ? '<h2 id="known">👥 Villagers you know</h2>' : '')
        . '<p class="help">Everyone you’ve met: ' . count($all) . ' of the Hollow’s ' . $total . ' villagers. You meet people by visiting their shop while they’re at the counter, finding them about town, or chatting and giving gifts. Their full pages are in your <a href="' . e(url('book.php?ch=Folk')) . '">Almanac → Villagers</a> too.</p>'
        . '<form method="get" action="' . e(url('town.php')) . '" class="box folkfilter"><input type="hidden" name="view" value="villagers"><input type="hidden" name="known" value="1">' . ($hub ? '<input type="hidden" name="hub" value="1">' : '')
        . '<input type="search" name="q" value="' . e($qs) . '" placeholder="Search by name…" aria-label="Search by name">'
        . '<select name="r" aria-label="Home region"><option value="">All regions</option>';
    foreach ($regions as $rg) $h .= '<option' . ($rg === $reg ? ' selected' : '') . '>' . e($rg) . '</option>';
    $h .= '</select><label><input type="checkbox" name="f" value="here"' . ($f === 'here' ? ' checked' : '') . '> Here now</label>'
        . '<button class="btn small">Show</button>' . ($qs !== '' || $f !== '' || $reg !== '' ? ' <a href="' . e(url('town.php?' . ($hub ? 'hub=1&' : '') . 'view=villagers#known')) . '">Clear</a>' : '') . '</form>';
    if (!$all) $h .= '<div class="box"><p class="muted">Nobody yet. Visit a shop or wander the town square to meet the locals.</p></div>';
    elseif (!$list) $h .= '<div class="box"><p class="muted">Nobody matches that.</p></div>';
    foreach ($byLevel as $li => $group) {
        $h .= '<h3 class="folkgroup">💛 ' . e(FRIEND_LEVELS[$li][1] ?? 'Stranger') . ' <small>' . count($group) . '</small></h3><div class="box">';
        foreach ($group as $n) {
            $lnk = e(url('folk.php?id=' . (int)$n['id']));
            $h .= '<div class="folkrow"><a href="' . $lnk . '">' . npc_portrait($n, 'small') . '</a>'
                . '<div><a href="' . $lnk . '"><b>' . e($n['name']) . '</b></a> <small class="muted">' . e(trim(strtolower((string)$n['personality'] . ' ' . (string)$n['species']))) . (!empty($n['traveller']) ? ' · traveller' : '') . '</small>'
                . '<br><small>📍 ' . e($n['now']['what']) . (npc_here($u, (int)$n['id']) ? ' · <b class="good">here now</b>' : '') . '</small>'
                . '<br><small class="muted">🏡 ' . ($n['home'] ? e($n['home']['name'] . ' · ' . $n['home']['region']) : (!empty($n['traveller']) ? 'travels the Hollow' : '—')) . (npc_birthday_today($n) ? ' · 🎂 birthday today!' : '') . '</small></div></div>';
        }
        $h .= '</div>';
    }
    return $h . '<details class="fold mapfold"><summary>🗺️ On the world map</summary><div class="mapwrap">' . world_map_svg($u) . '</div>'
        . '<p class="help">👤 marks a town where villagers you know (Acquaintance or better) are right now. 🎩 is you.</p></details>';
}

/** Who's at a place: little links to each NPC. */
function npc_faces(array $npcs, bool $names): string
{
    $h = '';
    foreach ($npcs as $n) {
        $h .= '<a class="npcface" href="' . e(url('folk.php?id=' . (int)$n['id'])) . '" title="' . e($n['name']) . '">' . npc_icon($n['species'])
            . ($names ? ' ' . e($n['name']) . (!empty($n['traveller']) ? ' <small class="tag">traveller</small>' : '') : '') . '</a>';
    }
    return $h;
}

/** One place's things to do. */
function action_buttons(array $s, array $u, array $uses, string $q): string
{
    $closed = spot_closed($s);
    $h = '<div class="tacts">';
    foreach (town_actions((int)$s['id']) as $a) {
        if ($a['kind'] === 'link') {
            $h .= '<a class="btn act alt" href="' . e(url((string)$a['link'])) . '">' . e($a['label']) . '</a>';
            continue;
        }
        $left = (int)$a['daily'] > 0 ? (int)$a['daily'] - ($uses[(int)$a['id']] ?? 0) : null;
        $cost = town_cost_label($a);
        $chance = town_chance($u, $a);
        // v0.7.61: "any seed" / "any food" costs let you choose which one, in a pop-up of your satchel
        $pick = in_array($a['cost_item'], ['anyseed', 'anyfood'], true) ? (string)$a['cost_item'] : '';
        $h .= '<form method="post" class="tact"' . ($pick ? ' data-needpick="' . $pick . '"' : '') . '>' . csrf_field() . '<input type="hidden" name="do" value="act">'
            . '<input type="hidden" name="action_id" value="' . (int)$a['id'] . '"><input type="hidden" name="spot" value="' . (int)$s['id'] . '">'
            . ($pick ? '<input type="hidden" name="item_id" value="0">' : '')
            . ($q !== '' ? '<input type="hidden" name="hub" value="1">' : '')
            . '<button class="btn act"' . ($closed || $left === 0 ? ' disabled' : '') . '>' . (str_ends_with((string)$a['slug'], '-drink') ? '☕ ' : '') . e($a['label']) . ($cost !== '' ? ' <span class="cost">' . e($cost) . '</span>' : '') . '</button>'
            . (str_ends_with((string)$a['slug'], '-drink') ? ' <button class="btn act alt" name="togo" value="1"' . ($closed || $left === 0 ? ' disabled' : '') . '>🥤 Take it to go</button>' : '')
            . '<small class="muted">' . ($left === null ? '' : ($left > 0 ? $left . ' left today' : 'done for today'))
            . ($chance < 100 ? ' · ' . $chance . '% chance' : '') . '</small></form>';
    }
    return $h . '</div>';
}

/** v0.7.66: the townsfolk's favours (on the Notice Board and in the square's Quests tab). $sid 0 = from the Quests tab. */
function town_favours_box(int $uid, string $town, bool $hub, int $sid): void
{
    if (setting('orders_on') === '1') { orders_board_box($uid, $town, $hub, $sid); return; }   // v1.0.0 wave 2b: orders replace the flat weekly favours (admin can switch back)
    $folk = town_folk($town); ?>
    <div class="box favours"><h3>📌 Favours from the townsfolk</h3>
      <?php $shown = 0; foreach ($folk as $n): $o = favour_offer($uid, $n, $town); if (!$o) continue; $shown++;
          $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $o['item']['id']]); ?>
        <div class="favour<?= $o['done'] ? ' done' : '' ?>"><span class="ficon"><?= npc_icon($n['species']) ?></span>
          <div><b><a href="<?= e(url('folk.php?id=' . (int)$n['id'])) ?>"><?= e($n['name']) ?></a></b>: “Could you bring me <?= (int)$o['qty'] ?> × <?= e($o['item']['name']) ?>?”
            <br><small class="muted">Reward: <?= money($o['coins']) ?>, 10 XP and friendship · you have <?= $have ?></small></div>
          <?php if ($o['done']): ?><span class="muted">✔️ Done this week</span>
          <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="favour"><input type="hidden" name="npc" value="<?= (int)$n['id'] ?>">
            <input type="hidden" name="spot" value="<?= $sid ?>"><?php if (!$sid): ?><input type="hidden" name="view" value="quests"><?php endif; ?><?php if ($hub): ?><input type="hidden" name="hub" value="1"><?php endif; ?>
            <button class="btn small" <?= $have < $o['qty'] ? 'disabled' : '' ?>>Deliver</button></form><?php endif; ?>
        </div>
      <?php endforeach; ?>
      <?php if (!$shown): ?><p class="muted">Nothing for you yet. Chat with the townsfolk: once they know you (Acquaintance or better), they’ll pin a favour here each week.</p><?php endif; ?>
      <?php if ($folk && $shown < count($folk)): ?><p class="help">Townsfolk who don’t know you yet: <?= e(implode(', ', array_map(fn($n) => $n['name'], array_filter($folk, fn($n) => !favour_offer($uid, $n, $town))))) ?>.</p><?php endif; ?>
    </div>
<?php
}

/** v0.7.61: a pop-up of the player's seeds or food to choose from (used by "Feed the birds" and "Have a picnic"). */
function town_pickers(int $uid): string
{
    require_once __DIR__ . '/item_square.php';   // v2.0.67: the choices are item squares (hooks .pcard[data-id], .pickgrid kept)
    $out = '';
    foreach (['anyseed' => ['seed', 'Which seeds for the birds?'], 'anyfood' => ['food', 'What will you eat? You get its energy, plus 1 for the fresh air.']] as $kind => [$cat, $title]) {
        $items = q('SELECT i.*, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
                    WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = ? ORDER BY i.base_price, i.name', [$uid, $cat])->fetchAll();
        $cards = '';
        foreach ($items as $i) {
            $cards .= item_square(['item' => $i, 'count' => (int)$i['qty'], 'class' => 'pcard', 'attrs' => ['data-id' => (int)$i['id']]]);
        }
        $out .= '<dialog class="picker townpick" data-kind="' . $kind . '" aria-label="' . e($title) . '"><div class="pickbox">'
            . '<div class="pickhead"><b>' . e($title) . '</b> <span class="muted">cheapest first</span><button type="button" class="pickx" aria-label="Close">✕</button></div>'
            . ($cards !== '' ? item_grid($cards, 'pickgrid') : '<p class="muted">You don’t have any.</p>')
            . '</div></dialog>';
    }
    return $out;
}

/** Shared place tabs. $tabs = [key => [label, href, badge text or '']]. $class: 'tabs' or 'tabs st-tabs'. */
function place_tabs_html(array $tabs, string $active, string $label = 'Place sections', string $class = 'tabs'): string
{
    $h = '<nav class="' . e($class) . '" aria-label="' . e($label) . '">';
    foreach ($tabs as $k => [$lab, $href, $badge]) {
        $h .= '<a class="' . ($k === $active ? 'on' : '') . '" href="' . e($href) . '">' . $lab
            . ($badge !== '' ? ' <span class="st-tabbadge" title="' . e($badge) . '">' . e($badge) . '</span>' : '') . '</a>';
    }
    return $h . '</nav>';
}

/** The Stop tab body for any place: Orders link, Passport, Seasons, Land for sale (villages only). */
function stop_tab_html(array $u, array $node, bool $hub): string
{
    require_once __DIR__ . '/stop_pass.php';
    $uid = (int)$u['id'];
    foreach (stop_sets_check($uid) as $m) flash($m);   // a set can be complete after an admin changed the numbers
    $nodeRegion = !empty($node['region_id']) ? q_one('SELECT * FROM regions WHERE id = ?', [$node['region_id']]) : null;
    $h = '<h2>🛂 Stamp passport</h2><p class="muted">Every rest stop gives you a stamp on your first visit. Fill the sets for rewards and titles. Hidden villages you find count too.</p>';
    $titles = stop_titles($uid);
    if ($titles) {
        $h .= '<p>Titles earned: ';
        foreach ($titles as $t) $h .= '<span class="tag">“' . e($t) . '”</span> ';
        $h .= '<a href="' . e(url('book.php?ch=Milestones')) . '">Choose yours in the Almanac →</a></p>';
    }
    $h .= stop_passport_html($u);
    $h .= '<p class="help">📜 <a href="' . e(url('jobs.php?t=orders' . ($hub ? '&hub=1' : ''))) . '">Orders</a> · all open orders are on the Tasks page.</p>';
    $h .= season_fold_html($u) . land_card_html($u, $node, $nodeRegion);
    return $h;
}

/** Main-stop tabs: Square, Villagers, Shops, Orders, Stop. $folkCount badges Villagers (0 = none). v2.0.67: in town, Shops and Orders are town.php views
 *  (old world.php?tab=markets and jobs.php?t=orders links still work); labels are one word after the icon (the strip never wraps). */
function main_stop_tabs(bool $hub, bool $inTown, string $active, int $folkCount = 0): array
{
    $q = $hub ? 'hub=1&' : '';
    return [
        'square' => ['🏘️ ' . ($inTown ? 'Square' : 'Here'), url('town.php' . ($hub ? '?hub=1' : '')), ''],
        'villagers' => ['👥 Villagers', url('town.php?' . $q . 'view=villagers'), $folkCount > 0 ? (string)$folkCount : ''],
        'shops' => ['🏪 Shops', $inTown ? url('town.php?' . $q . 'view=shops') : url('world.php?tab=markets'), ''],
        'orders' => ['📜 Orders', $inTown ? url('town.php?' . $q . 'view=orders') : url('jobs.php?t=orders' . ($hub ? '&hub=1' : '')), ''],   // 5th tab for now (Joshua, 2026-10-27)
        'stop' => ['🛂 Stop', url('town.php?' . $q . 'view=stop'), ''],
    ];
}

/** v2.0.67: the main-stop tab strip (mockup3): stitched leather, icon over a one-word label, one row at any width. $tabs from main_stop_tabs(). */
function main_stop_tabs_html(array $tabs, string $active, string $label = 'Town sections'): string
{
    $h = '<nav class="mtabs" aria-label="' . e($label) . '">';
    foreach ($tabs as $k => [$lab, $href, $badge]) {
        [$ic, $word] = array_pad(explode(' ', (string)$lab, 2), 2, '');
        $on = $k === $active;
        $h .= '<a class="mtabs__a' . ($on ? ' on' : '') . '" href="' . e($href) . '" data-inplace' . ($on ? ' aria-current="page"' : '') . '>'
            . '<span class="mtabs__ic" aria-hidden="true">' . $ic . '</span><span class="mtabs__t">' . $word . '</span>'
            . ($badge !== '' ? '<span class="mtabs__badge" aria-hidden="true">' . e($badge) . '</span><span class="vh">, ' . e($badge) . ' in town now</span>' : '') . '</a>';
    }
    return $h . '</nav>';
}

/** v2.0.67: Square card art for a town place: its own picture (a few specials), the kind's, else the signpost fallback. Path from the web root. */
const TOWN_PLACE_ART_SLUG = ['sp-grind' => 'grind', 'sp-monastery' => 'monastery', 'mm-stones' => 'stones', 'mm-pub' => 'pub'];
function town_place_art(array $s): string
{
    $dir = __DIR__ . '/../assets/img/town/';
    foreach ([TOWN_PLACE_ART_SLUG[(string)($s['slug'] ?? '')] ?? '', (string)($s['kind'] ?? ''), 'special'] as $n) {
        if ($n !== '' && preg_match('/^[a-z0-9_-]+$/', $n) && is_file($dir . 'place-' . $n . '.png')) return 'assets/img/town/place-' . $n . '.png';
    }
    return '';
}

/** v2.0.67: Shops card art per shops.shop_type, else the signpost. */
function town_shop_art(string $type): string
{
    $dir = __DIR__ . '/../assets/img/town/';
    if (preg_match('/^[a-z0-9_-]+$/', $type) && is_file($dir . 'shop-' . $type . '.png')) return 'assets/img/town/shop-' . $type . '.png';
    return is_file($dir . 'place-special.png') ? 'assets/img/town/place-special.png' : '';
}

/** A 144x108 felt-card picture (decorative). */
function felt_art_img(string $path): string
{
    return $path !== '' ? '<img class="pix" src="' . e(url($path)) . '" width="144" height="108" alt="" loading="lazy" decoding="async">' : '';
}

/**
 * v2.0.67: one Square place card (mockup3): a felt card that links to the place (closed places stay links: a shut place can still be read).
 * States: idle; all done today (stone felt, tick); closed by the clock (padlock, the hours in words); closed for repairs (barrier);
 * found only here (kind special: gold stitch, gold sign, star).
 */
function town_place_card(array $s, int $uid, array $uses, string $q): string
{
    require_once __DIR__ . '/journey.php';
    $closed = spot_closed($s);
    $acts = array_filter(town_actions((int)$s['id']), fn($a) => $a['kind'] !== 'link');
    $todo = 0;
    foreach ($acts as $a) if ((int)$a['daily'] <= 0 || ($uses[(int)$a['id']] ?? 0) < (int)$a['daily']) $todo++;
    $jl = journey_lock($uid, 'spot', (string)$s['slug']);
    $gold = ($s['kind'] ?? '') === 'special';
    $state = $jl ? ' is-repair' : ($closed ? ' is-closed' : ($acts && !$todo ? ' is-done' : ''));
    $chip = $jl ? '<span class="pchip pchip--repair">🚧 closed for repairs</span>'
        : ($closed ? '<span class="pchip pchip--closed">🔒 ' . e($closed) . '</span>'
        : ($acts ? ($todo ? '<span class="pchip pchip--todo">' . $todo . ' thing' . ($todo === 1 ? '' : 's') . ' to do</span>' : '<span class="pchip pchip--done">✔️ all done today</span>')
        : '<span class="pchip pchip--look">Have a look</span>'));
    $folk = '';
    foreach (npcs_at_spot($s) as $n) $folk .= '<span aria-hidden="true" title="' . e($n['name']) . '">' . npc_icon($n['species']) . '</span><span class="vh">' . e($n['name']) . ' is here.</span>';
    $gc = gnome_count_at_spot((int)$s['id'], $uid);
    if ($gc) $folk .= ($folk !== '' ? ' ' : '') . '🧑‍🌾 ' . $gc . ' gnome' . ($gc === 1 ? '' : 's') . ' here';
    return '<a class="gcard placecard' . ($gold ? ' placecard--gold' : '') . $state . '" href="' . e(url('town.php?' . $q . 'spot=' . (int)$s['id'])) . '">'
        . '<span class="gcard__art">' . felt_art_img(town_place_art($s)) . '</span>'
        . '<span class="gcard__ribbon"><span class="gcard__label">' . e($s['name']) . '</span>' . ($gold ? '<span class="vh">, found only here</span>' : '') . '</span>'
        . '<span class="gcard__meta">' . $chip . ($folk !== '' ? '<span class="pfolk">' . $folk . '</span>' : '') . '</span></a>';
}

/** v2.0.67: the Shops tab of a main stop (mockup3): this town's shops, then Mossbottom's (reachable from anywhere). Same rules as world.php's Shops tab. */
function town_shops_html(array $u, string $town): string
{
    require_once __DIR__ . '/world.php';
    $list = fn(string $region): array => q('SELECT s.*, l.name AS loc_name, l.id AS loc_id FROM shops s JOIN locations l ON l.id = s.location_id
              WHERE l.region = ? AND s.open = 1 ORDER BY s.name', [$region])->fetchAll();
    $h = '';
    if ($town !== HUB_REGION) {
        $shops = $list($town);
        $h .= '<h3 class="gx-h">🏪 Shops in ' . e($town) . '</h3>' . ($shops ? '<ul class="scards">' . town_shop_cards($shops, $u) . '</ul>' : '<p class="gx-note">No shops here yet.</p>');
    }
    $hubShops = $list(HUB_REGION);
    $h .= '<h3 class="gx-h">🍄 Mossbottom hub <span class="gx-h__sub">reachable from anywhere</span></h3>'
        . ($hubShops ? '<ul class="scards">' . town_shop_cards($hubShops, $u) . '</ul>' : '<p class="gx-note">No shops here yet.</p>');
    return $h;
}

/** Shop cards: vignette per shop type, the name on a sign, the description, who is at the counter. Whole card = the link; closed shops stay links. */
function town_shop_cards(array $shops, array $u): string
{
    $out = '';
    foreach ($shops as $s) {
        $staff = staff_on_duty((int)$s['id']);
        $reach = shop_reachable($u, $s);
        $inner = '<span class="scard__art">' . felt_art_img(town_shop_art((string)($s['shop_type'] ?? ''))) . '</span>'
            . '<span class="scard__ribbon"><span class="scard__name">' . e($s['name']) . '</span></span>'
            . '<span class="scard__desc">' . e((string)$s['description']) . '</span>'
            . '<span class="scard__staff">' . ($staff ? 'At the counter: ' . e(implode(', ', array_column($staff, 'name'))) : 'Closed — nobody on shift') . '</span>';
        $cls = 'scard' . ($staff ? '' : ' is-closed');
        $out .= '<li>' . ($reach
            ? '<a class="' . $cls . '" href="' . e(url('shop.php?id=' . (int)$s['id'])) . '">' . $inner . '</a>'
            : '<div class="' . $cls . '">' . $inner . '<a class="scard__walk" href="' . e(url('world.php?go=' . (int)$s['loc_id'] . '#gopanel')) . '">🚶 Walk to ' . e((string)$s['loc_name']) . ' to shop here</a></div>') . '</li>';
    }
    return $out;
}

/** v2.0.67: the Orders tab of a main stop (mockup3): each order a pinned felt note. Same data and Deliver POST as orders_board_box (do=order to town.php). */
function town_orders_html(int $uid, string $town, bool $hub): string
{
    if (setting('orders_on') !== '1') { ob_start(); town_favours_box($uid, $town, $hub, 0); return (string)ob_get_clean(); }   // admin switched back to favours
    require_once __DIR__ . '/friends.php';
    $board = orders_board($town);
    $cy = orders_cycle();
    $next = date('D j M', strtotime(hollow_date_add($cy['end'], 1) . ' UTC'));
    $h = '<h3 class="gx-h" id="orders">📜 Orders from the townsfolk</h3>'
        . '<p class="gx-note gx-note--top">Fill an order before its deadline. Harder orders (a higher quality bar) pay more. New orders every ' . (int)$cy['len'] . ' days; next round ' . e($next) . '.</p>';
    if (!$board) return $h . '<p class="gx-note">No open orders in ' . e($town) . ' right now. The next round is pinned on ' . e($next) . '.</p>';
    $h .= '<ul class="ocards">';
    foreach ($board as ['npc' => $n, 'o' => $o]) {
        $done = order_done($uid, (int)$n['id'], $o['cycle']);
        $c = $done ? null : order_check($uid, $o);
        $d = (int)$o['diff'];
        $tags = '<span class="otag otag--stars" role="img" aria-label="Difficulty: ' . $d . ' of 3" title="Difficulty">' . str_repeat('★', $d) . str_repeat('☆', 3 - $d) . '</span>'
            . ($o['bar'] ? '<span class="otag">' . e($o['bar']) . '</span>' : '')
            . '<span class="otag' . ($o['days_left'] <= 1 ? ' otag--warn' : '') . '">⏳ ' . (int)$o['days_left'] . ' day' . ($o['days_left'] === 1 ? '' : 's') . ' left</span>';
        $rw = 'Reward: ' . money($o['coins']) . ', ' . (int)$o['xp'] . ' XP, +' . (int)$o['friend'] . ' friendship' . ($o['reward_item'] ? ', 🎁 ' . e($o['reward_item']['name']) : '');
        if ($c) $rw .= ' · you have ' . (int)$c['have'] . ($c['quality'] !== null && ($o['kind'] === 'arrangement' || $o['minq'] > 0) ? ' (' . ($o['kind'] === 'arrangement' ? 'best ' . (int)$c['quality'] : 'grade ' . e(market_grade((int)$c['quality'])) . ', ' . (int)$c['quality']) . ')' : '') . ($c['note'] ? ' · ' . e($c['note']) : '');
        $foot = $done ? '<span class="ocard__done">✔️ Delivered</span>'
            : '<form method="post">' . csrf_field() . '<input type="hidden" name="do" value="order"><input type="hidden" name="npc" value="' . (int)$n['id'] . '">'
              . '<input type="hidden" name="spot" value="0"><input type="hidden" name="view" value="orders">' . ($hub ? '<input type="hidden" name="hub" value="1">' : '')
              . '<button class="fbtn ocard__act"' . ($c['enough'] ? '' : ' disabled') . '>Deliver</button></form>';
        $h .= '<li class="ocard' . ($done ? ' is-done' : '') . '">'
            . '<a class="ocard__who" href="' . e(url('folk.php?id=' . (int)$n['id'])) . '"><span class="ocard__face">' . npc_portrait($n, 'small') . '</span><span class="vlcard__ribbon"><span class="vlcard__name">' . e($n['name']) . '</span></span></a>'
            . '<p class="ocard__q">“' . e($o['text']) . '”</p><p class="ocard__tags">' . $tags . '</p><p class="ocard__rw">' . $rw . '</p>'
            . '<div class="ocard__foot">' . $foot . '</div></li>';
    }
    return $h . '</ul>';
}

/** v2.0.61: the place switcher bar: World / Here / Mossbottom. $active: 'world', 'here' or 'hub'. */
function place_switcher_html(array $node, string $active): string
{
    $items = [
        'world' => ['🌍 <span>World</span>', url('world.php')],
        'here' => ['📍 <span>' . e((string)$node['name']) . '</span>', url('town.php')],
        'hub' => ['🍄 <span>Mossbottom</span>', url('town.php?hub=1')],
    ];
    $h = '<nav class="psw" aria-label="Where to">';
    foreach ($items as $k => [$lab, $href]) $h .= '<a class="' . ($k === $active ? 'on' : '') . '" href="' . e($href) . '"' . ($k === $active ? ' aria-current="page"' : '') . '>' . $lab . '</a>';
    return $h . '</nav>';
}

/** Place header: scene art (a file in assets/img/scenes/, temporarily red-outlined for review), kicker line, name, optional line and chips. */
function place_header_html(string $art, string $alt, string $kicker, string $title, string $line = '', array $chips = []): string
{
    $hasArt = $art !== '' && is_file(__DIR__ . '/../assets/img/scenes/' . $art);
    $h = '<header class="ph' . ($hasArt ? '' : ' ph-noart') . '">';   // v2.0.65: the name sits on a felt sign under (phone) or beside (desktop) the art
    if ($hasArt) {
        $h .= '<figure class="ph-art"><img src="' . e(url('assets/img/scenes/' . $art)) . '" alt="' . e($alt) . '" width="480" height="240" decoding="async"></figure>';
    }
    $h .= '<div class="ph-body"><p class="ph-kick">' . e($kicker) . '</p><h1>' . e($title) . '</h1>'
        . ($line !== '' ? '<p class="ph-amb">' . e($line) . '</p>' : '');
    if ($chips) $h .= '<p class="ph-chips">' . implode('', array_map(fn($c) => '<span class="chip">' . $c . '</span>', $chips)) . '</p>';
    return $h . '</div></header>';
}

/** Daypart, weather and season chips for a place header (HTML-escaped text, emoji included). */
function place_chips(array $u): array
{
    $n = hollow_now(hollow_user_region($u));
    return [e($n['daypart_emoji'] . ' ' . $n['daypart_label']), e($n['weather_emoji'] . ' ' . $n['weather_label']), e($n['season_emoji'] . ' ' . $n['season_label'] . ' ' . $n['season_day'])];
}

/** v2.0.65: the one villager row (main stop and rest stop). $face and $action are ready HTML; $lines are ready HTML lines; $extra (errands) folds under the row.
 *  v2.0.67: a felt row (mockup3) as an <li> for a <ul class="vlcards">: face + name sign (one link when $href is given), the lines, one action; $badge = ready HTML. */
function villager_row_html(string $face, string $name, array $lines, string $action = '', string $extra = '', string $extraTitle = '', bool $open = false, string $badge = '', string $href = ''): string
{
    $who = '<span class="vlcard__face">' . $face . '</span><span class="vlcard__ribbon"><span class="vlcard__name">' . $name . '</span></span>';
    $h = '<li class="vlcard">' . ($href !== '' ? '<a class="vlcard__who" href="' . e($href) . '">' . $who . '</a>' : '<span class="vlcard__who">' . $who . '</span>');
    $h .= ($action !== '' ? '<span class="vlcard__act">' . $action . '</span>' : '') . '<span class="vlcard__main">';
    foreach ($lines as $l) if ($l !== '') $h .= '<span class="vlcard__sub">' . $l . '</span>';
    $h .= $badge . '</span>';
    if ($extra !== '') $h .= '<details class="vfold vlcard__fold"' . ($open ? ' open' : '') . '><summary>' . $extraTitle . '</summary>' . $extra . '</details>';
    return $h . '</li>';
}
