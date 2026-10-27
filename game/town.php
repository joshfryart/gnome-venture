<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/town.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/npc_life.php';
require_once __DIR__ . '/includes/town_social.php';
require_once __DIR__ . '/includes/journey.php';
require_once __DIR__ . '/includes/scene.php';   // v2.0.46: place banners
require_once __DIR__ . '/includes/place_ui.php';   // v2.0.61: town folk / action helpers
$u = require_login();
$uid = (int)$u['id'];
$hub = !empty($_GET['hub']) || !empty($_POST['hub']);

if (is_post()) {
    csrf_check();
    refresh_energy($u);
    $do = (string)($_POST['do'] ?? '');
    $pnode = player_node($u);
    if (!$hub && $do !== 'local' && !in_array($pnode['kind'], ['market', 'hub'], true)) {   // v0.7.48: the square is in the town itself
        flash('You’re not in town right now. Walk to the town at the end of the road to use its square.', 'err');
        redirect('town.php');
    }
    [$ok, $msg] = match ($do) {
        'act' => town_act($u, (int)($_POST['action_id'] ?? 0), !empty($_POST['togo']), (int)($_POST['item_id'] ?? 0)),
        'answer' => town_quiz_answer($u, (string)($_POST['token'] ?? ''), (string)($_POST['choice'] ?? '')),
        'festival' => festival_treat($u, town_for($u, $hub)),
        'wave' => town_wave($u, (int)($_POST['to'] ?? 0), (int)($_POST['spot'] ?? 0)),
        'bench' => town_bench($u, (int)($_POST['to'] ?? 0), (int)($_POST['spot'] ?? 0)),
        'snack' => town_snack($u, (int)($_POST['to'] ?? 0), (int)($_POST['spot'] ?? 0), (int)($_POST['item_id'] ?? 0)),
        'rps' => town_rps_challenge($u, (int)($_POST['to'] ?? 0), (int)($_POST['spot'] ?? 0), (string)($_POST['move'] ?? '')),
        'rps_play' => town_rps_play($u, (int)($_POST['game'] ?? 0), (string)($_POST['move'] ?? '')),
        'order' => order_deliver($u, (int)($_POST['npc'] ?? 0), town_for($u, $hub)),   // v1.0.0 wave 2b: orders with a quality bar
        'favour' => favour_deliver($u, (int)($_POST['npc'] ?? 0), town_for($u, $hub)),
        'local' => (function () use ($u) { require_once __DIR__ . '/includes/local.php'; return local_do($u, player_node($u), (string)($_POST['kind'] ?? ''), $_POST); })(),
        default => [false, 'Unknown action.'],
    };
    flash($msg, $ok ? 'ok' : 'err');
    $spot = (int)($_POST['spot'] ?? 0);
    $stTab = ($do === 'local' && in_array($_POST['t'] ?? '', ['folk', 'stop'], true)) ? 't=' . $_POST['t'] : '';   // v1.3.0: rest-stop forms come back to their tab
    if ($stTab) redirect('town.php?' . $stTab);
    if (!$spot && ($_POST['view'] ?? '') === 'quests') redirect('jobs.php?t=orders' . ($hub ? '&hub=1' : ''));   // v1.7.2 tasks: the order board moved to Tasks
    redirect('town.php?' . ($hub ? 'hub=1&' : '') . ($spot ? 'spot=' . $spot : ''));
}

if (($_GET['view'] ?? '') === 'quests') redirect('jobs.php?t=orders' . ($hub ? '&hub=1' : ''));   // v1.7.2 tasks: orders, Journey and repairs live on the Tasks page
refresh_energy($u);
if (active_expedition($uid)) { flash('You’re still on the road.', 'err'); redirect('adventure.php'); }   // v0.9.1a
$viewReq = (string)($_GET['view'] ?? '');
if ($viewReq === 'folk') $viewReq = 'villagers';
if ($viewReq === 'stop') $viewReq = 'passport';   // v2.0.61: the Stop tab (Passport, Orders link, Seasons, Land)   // v2.0.4 menu folds: old name of the Villagers tab
if ($viewReq === 'villagers' && !$hub && !in_array(player_node($u)['kind'], ['market', 'hub'], true)) redirect('villagers.php' . (isset($_GET['q']) && $_GET['q'] !== '' ? '?q=' . urlencode((string)$_GET['q']) : ''));   // v2.0.39: the Villagers page; v2.0.60: main stops (market/hub) show who is in town inline
$nodeNow = player_node($u);
$inTown = $hub || in_array($nodeNow['kind'], ['market', 'hub'], true);
if ($viewReq === 'passport' || ($viewReq === 'villagers' && !$inTown)) {   // v2.0.4 menu folds: Passport and Villagers you know (were passport.php, folk.php) work from anywhere
    require_once __DIR__ . '/includes/stop_pass.php';
    $isPass = $viewReq === 'passport';
    page_header($isPass ? 'Stamp passport' : 'Villagers you know');
    ?>
    <h1>🏘️ Town</h1>
    <?= place_tabs_html(main_stop_tabs($hub, $inTown, $isPass ? 'stop' : 'villagers'), $isPass ? 'stop' : 'villagers', 'Town sections', 'tabs mst') ?>
    <div class="townview">
    <?php if ($isPass): ?>
      <?= stop_tab_html($u, $nodeNow, $hub) ?>
    <?php else: ?>
      <?= town_known_html($u, $hub) ?>
    <?php endif; ?>
    </div>
    <?php
    page_footer();
    exit;
}
$town = town_for($u, $hub);
$q = $hub ? 'hub=1&' : '';
$spot = !empty($_GET['spot']) ? q_one('SELECT * FROM town_spots WHERE id = ? AND region = ? AND active = 1', [(int)$_GET['spot'], $town]) : null;
if ($spot) town_mark_present($uid, (int)$spot['id']);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$uses = town_uses_today($uid);
$quiz = $_SESSION['town_quiz'] ?? null;
// v1.4.6: the clock/energy/Petals line is gone from town pages (header and status strip already show them)
$clock = '🕰️ It’s ' . hour_label(hollow_hour()) . ' in the Hollow, ' . hollow_date('l');

// v0.7.48: away from a town, this tab shows the little place you're actually in
$node = player_node($u);
if (!$hub && !in_array($node['kind'], ['market', 'hub'], true)) {
    require_once __DIR__ . '/includes/local.php';
    require_once __DIR__ . '/includes/landmarks.php';
    require_once __DIR__ . '/includes/roads.php';
    $kindIcons = ['village' => '🏡', 'haven' => '🏕️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️'];
    $road = road_of((int)$node['id']);
    page_header($node['name']);
    ?>
    <p class="crumbs">🌍 <a href="<?= e(url('world.php')) ?>">World</a> › <?= e((string)$node['region']) ?> › <b><?= e($node['name']) ?></b></p>
    <?= place_switcher_html($node, 'here') ?>
    <?php if ($node['kind'] === 'village'): $stType = stop_type_of($node); ?>
      <?= place_header_html('stop-' . $stType . '.png', $node['name'], 'Rest stop · ' . (string)$node['region'], $node['name'], '', [$road ? '🛣️ ' . e($road['name']) : '🌿 Hidden village, off the road']) ?>
    <?php else: ?>
      <h1><?= $kindIcons[$node['kind']] ?? '📍' ?> <?= e($node['name']) ?></h1>
      <?= scene_place_banner($node, $node['name']) ?>
    <?php endif; ?>
    <?php require_once __DIR__ . '/includes/destination.php'; echo dest_resume_html($u);   // v1.0.4: carry on along the route ?>
    <?php $eb = $_SESSION['explore_back'] ?? null;
    if ($eb && (int)$eb['place'] === (int)$node['id'] && ($ebFrom = q_one('SELECT name FROM locations WHERE id = ?', [$eb['from']]))): // v0.7.61 ?>
      <div class="box notice comeback">🌿 You found this place while exploring off the path.
        <form method="post" action="<?= e(url('adventure.php')) ?>" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="explore_back"><button class="btn small">🌿 Back to exploring</button></form>
        <form method="post" action="<?= e(url('adventure.php')) ?>" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="explore_road"><button class="btn small alt">🛣️ Back to the road at <?= e($ebFrom['name']) ?></button></form>
        <span class="help">Both are free.</span></div>
    <?php endif; ?>
    <?php if ($node['kind'] === 'village'): ?>
      <?php /* v2.0.65: the "Rest stop · a small village on the road …" line is gone: the place header says rest stop, and the road is a chip there */ ?>
      <?= local_panel($u, $node) ?>
      <?php $mine = q_one('SELECT id, garden_name FROM plots WHERE user_id = ? AND village_id = ?', [$uid, $node['id']]);
      if ($mine): ?><p>🏡 Your garden <a href="<?= e(url('garden.php')) ?>"><b><?= eu($mine['garden_name'] ?: 'Garden') ?></b></a> is here.</p><?php endif; ?>
    <?php else: ?>
      <?= landmark_panel($u, $node) ?>
    <?php endif; ?>
    <?php /* v1.6.2: removed the "full town square … end of the road" footer line (redundant; the rest-stop line above says it) */ ?>
    <?php
    page_footer();
    exit;
}

page_header($spot ? $spot['name'] : $town . ' Town Square');

?>
<p class="crumbs"><a href="<?= e(url('world.php')) ?>">🌍 World</a> › <?php if ($spot): ?><a href="<?= e(url('town.php?' . rtrim($q, '&'))) ?>"><?= e($town) ?></a> › <b><?= e($spot['name']) ?></b><?php else: ?><b><?= e($town) ?></b><?php endif; ?></p>

<?php if ($quiz): $qa = q_one('SELECT s.id FROM town_actions a JOIN town_spots s ON s.id = a.spot_id WHERE a.id = ?', [$quiz['action']]); ?>
  <div class="eventbox waiting quizbox" role="dialog" aria-label="A question">
    <div class="evicon">🧠</div>
    <div class="evbody"><div class="evkicker">A question!</div><div class="evtitle"><?= e($quiz['q']) ?></div>
      <div class="evbtns">
        <?php foreach ($quiz['options'] as $k => $label): ?>
          <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="answer"><input type="hidden" name="token" value="<?= e($quiz['token']) ?>">
            <input type="hidden" name="choice" value="<?= e($k) ?>"><input type="hidden" name="spot" value="<?= (int)($qa['id'] ?? 0) ?>">
            <?php if ($hub): ?><input type="hidden" name="hub" value="1"><?php endif; ?>
            <button class="btn"><?= e($label) ?></button></form>
        <?php endforeach; ?>
      </div></div>
  </div>
<?php endif; ?>

<?php if ($spot): $closed = spot_closed($spot); ?>
  <nav class="tabs placetabs">
    <a href="<?= e(url('town.php?' . rtrim($q, '&'))) ?>">🏘️ Square</a>
    <?php foreach (town_spots($town) as $ts): ?>
      <a class="<?= (int)$ts['id'] === (int)$spot['id'] ? 'on' : '' ?><?= spot_closed($ts) ? ' shut' : '' ?>" href="<?= e(url('town.php?' . $q . 'spot=' . (int)$ts['id'])) ?>"><?= e((string)$ts['icon']) ?> <?= e($ts['name']) ?></a>
    <?php endforeach; ?>
  </nav>
  <h1><?= e((string)$spot['icon']) ?> <?= e($spot['name']) ?></h1>
  <div class="box spotbox<?= $closed ? ' closed' : '' ?>">
    <p><?= e((string)$spot['description']) ?></p>
    <?php if ($closed): ?><p class="notice">🔒 Closed right now. <?= e($closed) ?></p><?php endif; ?>
    <?php require_once __DIR__ . '/includes/journey.php';
    if ($jlock = journey_lock($uid, 'spot', (string)$spot['slug'])): echo journey_lock_note($jlock, (string)$spot['name']);   // v0.7.66
    else: ?>
    <?= action_buttons($spot, $u, $uses, $q) ?>
    <?= town_pickers($uid) ?>
    <?php endif; ?>
    <?php if ($spot['kind'] === 'green' && ($fest = town_festival($town))): ?>
      <form method="post" class="tact"><?= csrf_field() ?><input type="hidden" name="do" value="festival"><input type="hidden" name="spot" value="<?= (int)$spot['id'] ?>"><?php if ($hub): ?><input type="hidden" name="hub" value="1"><?php endif; ?>
        <button class="btn act gold"><?= $fest[1] ?> Visit the festival stall</button><small class="muted">a free treat, once today</small></form>
    <?php endif; ?>
  </div>
  <?php $here = npcs_at_spot($spot); require_once __DIR__ . '/includes/folk_list.php'; npc_meet($uid, array_column($here, 'id')); /* v0.7.69, ids fixed 0.7.73 */ ?>
  <?php $sid = (int)$spot['id']; $games = town_rps_waiting($uid, $sid); foreach ($games as $g): ?>
    <div class="eventbox waiting" role="dialog" aria-label="Rock, paper, trowel"><div class="evicon">✊</div><div class="evbody">
      <div class="evkicker">A challenge!</div><div class="evtitle"><?= e($g['from_name']) ?> challenges you to rock-paper-trowel!</div>
      <div class="evbtns"><?php foreach (RPS_MOVES as $mv => $lab): ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="rps_play">
        <input type="hidden" name="game" value="<?= (int)$g['id'] ?>"><input type="hidden" name="spot" value="<?= $sid ?>"><?php if ($hub): ?><input type="hidden" name="hub" value="1"><?php endif; ?>
        <button class="btn"><?= e($lab) ?></button></form><?php endforeach; ?></div></div></div>
  <?php endforeach; ?>
  <?php $gnomes = gnomes_at_spot($sid, $uid);
      $snacks = q("SELECT i.id, i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'food' AND i.tradable = 1 ORDER BY i.name", [$uid])->fetchAll(); ?>
  <div class="box">
    <h3>Who’s here</h3>
    <?php if ($here): ?><p class="faces"><?= npc_faces($here, true) ?></p><p class="help">Tap a townsfolk to say hello. A chat at someone’s favourite place counts double.</p>
    <?php else: ?><p class="muted">None of the townsfolk right now.</p><?php endif; ?>
    <?php if (!$gnomes): ?><p class="muted">No other gnomes in the last <?= TOWN_PRESENCE_MINUTES ?> minutes. <?= (int)$u['town_hidden'] ? 'You’re hidden from these lists (Account page).' : 'Others will see you here for a little while.' ?></p>
    <?php else: ?><div class="gnomelist">
      <?php foreach ($gnomes as $g): $hid = '<input type="hidden" name="to" value="' . (int)$g['id'] . '"><input type="hidden" name="spot" value="' . $sid . '">' . ($hub ? '<input type="hidden" name="hub" value="1">' : ''); ?>
        <details class="gnomerow"><summary><?= gnome_avatar($g, 36) ?><b><?= e(gnome_name($g)) ?></b> <small class="muted">level <?= (int)$g['level'] ?> · tap to say hi</small></summary>
          <span class="gacts"><?= profile_link($g, '👤 Profile') ?> <?= report_link((int)$g['id'], 'name') ?>
            <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="wave"><?= $hid ?><button class="btn small">👋 Wave</button></form>
            <?php if ($spot['kind'] === 'green'): ?><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="bench"><?= $hid ?><button class="btn small">🪑 Sit together</button></form><?php endif; ?>
            <?php if ($snacks): ?><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="snack"><?= $hid ?>
              <select name="item_id" aria-label="Snack to share"><?php foreach ($snacks as $sn): ?><option value="<?= (int)$sn['id'] ?>"><?= e($sn['name']) ?> (<?= (int)$sn['qty'] ?>)</option><?php endforeach; ?></select>
              <button class="btn small">🍪 Share</button></form><?php endif; ?>
            <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="rps"><?= $hid ?>
              <select name="move" aria-label="Your secret move"><?php foreach (RPS_MOVES as $mv => $lab): ?><option value="<?= e($mv) ?>"><?= e($lab) ?></option><?php endforeach; ?></select>
              <button class="btn small">Challenge</button></form>
          </span></details>
      <?php endforeach; ?></div>
      <p class="help">Waves, benches and snacks: once a day for each gnome. Rock-paper-trowel is just for fun (your wins: <?= (int)$u['rps_wins'] ?>).</p>
    <?php endif; ?>
  </div>
  <?php if ($spot['kind'] === 'board') town_favours_box($uid, $town, $hub, $sid); ?>
  <?php if ($spot['kind'] === 'teahouse' && ($rumours = teahouse_rumours($town))): ?>
    <div class="box rumours"><h3>👂 Overheard</h3><?php foreach ($rumours as $r): ?><p><?= e($r) ?></p><?php endforeach; ?>
      <p class="help">The gossip changes every hour.</p></div>
  <?php endif; ?>
  <p><a class="btn alt" href="<?= e(url('town.php?' . rtrim($q, '&'))) ?>">← Back to the square</a></p>
<?php else: ?>
  <?= place_switcher_html($node, $hub ? 'hub' : 'here') ?>
  <?= place_header_html('stop-market.png', $town . ' town square', 'Main stop · Town square', $town, '', place_chips($u)) ?>
  <?php if (!$hub) { require_once __DIR__ . '/includes/destination.php'; echo dest_resume_html($u); }   // v1.0.4: carry on along the route ?>
  <?php if ($fest = town_festival($town)): ?>
    <div class="festival"><span><?= $fest[1] ?></span><div><b>Today: the <?= e($fest[0]) ?>!</b> <?= e($fest[3]) ?><br><small>Everything in the square pays twice today, and there’s a festival stall on the Green.</small></div></div>
  <?php endif; ?>
  <?php if (market_day_on()): ?>
    <div class="festival marketbanner"><span>🧺</span><div><b>Market day in <?= e($town) ?>!</b> Stalls are up on the square, wanted goods pay extra and the best-basket judging is on.<br><a class="btn small" href="<?= e(url('marketday.php' . ($hub ? '?hub=1' : ''))) ?>">To the market →</a></div></div>
  <?php endif; ?>
  <?php $bdays = array_filter(town_folk($town), fn($n) => npc_birthday_today($n)); if ($bdays): ?>
    <p class="bday">🎂 Today is <?= implode(' and ', array_map(fn($n) => '<a href="' . e(url('folk.php?id=' . (int)$n['id'])) . '">' . e($n['name']) . '</a>’s', $bdays)) ?> birthday! A gift today means three times as much.</p>
  <?php endif; ?>
  <?php // Today at a glance (v0.7.38)
  $todoAll = 0; $openNow = 0; $gnomesAll = 0;
  foreach (town_spots($town) as $ts) {
      if (!spot_closed($ts)) $openNow++;
      $gnomesAll += gnome_count_at_spot((int)$ts['id'], $uid);
      foreach (town_actions((int)$ts['id']) as $ta) if ($ta['kind'] !== 'link' && (int)$ta['daily'] > 0 && ($uses[(int)$ta['id']] ?? 0) < (int)$ta['daily'] && !spot_closed($ts) && !journey_lock($uid, 'spot', (string)$ts['slug'])) $todoAll++;
  }
  $travHere = array_filter(q('SELECT * FROM npcs WHERE traveller IS NOT NULL AND active = 1')->fetchAll(), fn($t) => traveller_stop($t)['town'] === $town);
  $favDue = 0;
  if (setting('orders_on') === '1') $favDue = orders_open_count($uid, $town);   // v1.0.0 wave 2b
  else foreach (town_folk($town) as $fn) { $fo = favour_offer($uid, $fn, $town); if ($fo && !$fo['done']) $favDue++; } ?>
  <div class="todaybox">
    <span>📋 <b><?= $todoAll ?></b> thing<?= $todoAll === 1 ? '' : 's' ?> left to do today</span>
    <span>🚪 <?= $openNow ?> place<?= $openNow === 1 ? '' : 's' ?> open</span>
    <?php if ($gnomesAll): ?><span>🧑‍🌾 <?= $gnomesAll ?> gnome<?= $gnomesAll === 1 ? '' : 's' ?> about</span><?php endif; ?>
    <?php if ($favDue): ?><span>📌 <?= $favDue ?> <?= setting('orders_on') === '1' ? 'order' : 'favour' ?><?= $favDue === 1 ? '' : 's' ?> on the board</span>
    <?php endif; if (market_day_on()): ?><span>🧺 <b><a href="<?= e(url('marketday.php' . ($hub ? '?hub=1' : ''))) ?>">Market day</a></b>: stalls are up!</span><?php elseif (($md = market_days_until()) > 0 && $md <= 2): ?><span>🧺 Market day in <?= $md ?> day<?= $md === 1 ? '' : 's' ?></span><?php endif; ?>
    <?php foreach ($travHere as $th): ?><span>🧭 <a href="<?= e(url('folk.php?id=' . (int)$th['id'])) ?>"><?= e($th['name']) ?></a> is visiting</span><?php endforeach; ?>
  </div>
  <?php $view = $viewReq === 'villagers' ? 'folk' : 'square';   // v0.7.61 folk, v0.7.66 quests
  $present = [];
  foreach (town_spots($town) as $ps) foreach (npcs_at_spot($ps) as $n) $present[(int)$n['id']] = ['n' => $n, 'spot' => $ps];
  require_once __DIR__ . '/includes/friends.php';
  // v0.7.73: the folk who live in this town — at home now, or out
  $homeIn = []; $homeOut = [];
  foreach (q('SELECT * FROM npcs WHERE active = 1 AND traveller IS NULL ORDER BY name')->fetchAll() as $rn) {
      $hm = npc_home($rn);
      if (!$hm || $hm['region'] !== $town) continue;
      $nw = npc_now($rn);
      if (!empty($nw['home'])) $homeIn[] = [$rn, $hm];
      elseif (!isset($present[(int)$rn['id']])) $homeOut[] = [$rn, $hm, $nw];
  } ?>
  <?= place_tabs_html(main_stop_tabs($hub, true, $view === 'folk' ? 'villagers' : 'square', count($present) + count($homeIn)), $view === 'folk' ? 'villagers' : 'square', 'Town sections', 'tabs mst') ?>
  <?php if ($view === 'folk'): ?>
    <h2>🚶 Out and about</h2>
    <div class="box folkabout">
      <?php if (!$present): ?><p class="muted">Nobody’s out and about in the town’s places right now. Shopkeepers are at their counters.</p><?php endif; ?>
      <?php foreach ($present as ['n' => $n, 'spot' => $ps]): $fl = friend_level((int)friendship($uid, (int)$n['id'])['points']); ?>
        <?= villager_row_html(npc_portrait($n, 'small'), e($n['name']),
            [e(trim(strtolower((string)$n['personality'] . ' ' . (string)$n['species']))) . (!empty($n['traveller']) ? ' · traveller' : ''),
             '📍 <a href="' . e(url('town.php?' . $q . 'spot=' . (int)$ps['id'])) . '">' . e($ps['icon'] . ' ' . $ps['name']) . '</a> · 💛 ' . e($fl['name'])],
            '<a class="btn small alt" href="' . e(url('folk.php?id=' . (int)$n['id'])) . '">Chat</a>', '', '', false, npc_birthday_today($n) ? ' <span class="vbadge">🎂 birthday</span>' : '') ?>
      <?php endforeach; ?>
    </div>
    <h2>🏡 At home</h2>
    <?php if (!$homeIn): ?><div class="box"><p class="muted">Nobody lives here<?= $town === HUB_REGION ? '' : ' that you know of' ?>. Travellers sleep under the stars.</p></div><?php endif; ?>
    <?php if ($homeIn): ?>
    <div class="homelist">
      <?php foreach ($homeIn as [$n, $hm]): $fl = friend_level((int)friendship($uid, (int)$n['id'])['points']); ?>
        <?= villager_row_html(npc_portrait($n, 'small'), e($n['name']),
            [e(trim(strtolower((string)$n['personality'] . ' ' . (string)$n['species']))), '🏡 ' . e($hm['name']) . ' · 💛 ' . e($fl['name'])],
            '<a class="btn small alt" href="' . e(url('folk.php?id=' . (int)$n['id'])) . '">🚪 Knock</a>', '', '', false, npc_birthday_today($n) ? ' <span class="vbadge">🎂</span>' : '') ?>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>
    <p class="help">Knock to visit someone at home: you can chat and give a gift there. Tap a name above to see what you know about them.</p>
    <p class="help">📒 Only people in town right now are shown. <a href="<?= e(url('villagers.php')) ?>">Everyone you know →</a></p>
  <?php else: ?>
  <div class="spotgrid">
    <?php foreach (town_spots($town) as $s): $closed = spot_closed($s);
        $acts = array_filter(town_actions((int)$s['id']), fn($a) => $a['kind'] !== 'link');
        $todo = 0;
        foreach ($acts as $a) if ((int)$a['daily'] <= 0 || ($uses[(int)$a['id']] ?? 0) < (int)$a['daily']) $todo++; ?>
      <a class="box spotcard<?= $closed ? ' closed' : '' ?><?= $s['kind'] === 'special' ? ' special' : '' ?>" href="<?= e(url('town.php?' . $q . 'spot=' . (int)$s['id'])) ?>">
        <span class="spicon"><?= e((string)$s['icon']) ?></span>
        <b><?= e($s['name']) ?></b>
        <?php require_once __DIR__ . '/includes/journey.php'; $jl = journey_lock($uid, 'spot', (string)$s['slug']); ?>
        <small class="muted"><?= $jl ? '🚧 closed for repairs' : ($closed ? '🔒 ' . e($closed) : ($acts ? ($todo ? $todo . ' thing' . ($todo === 1 ? '' : 's') . ' to do' : '✔️ all done today') : 'Have a look')) ?></small>
        <?php $gc = gnome_count_at_spot((int)$s['id'], $uid); if ($gc): ?><small class="gcount">🧑‍🌾 <?= $gc ?> gnome<?= $gc === 1 ? '' : 's' ?> here</small><?php endif; ?>
        <?php $who = npcs_at_spot($s); if ($who): ?><span class="faces small"><?php foreach ($who as $n): ?><span title="<?= e($n['name']) ?>"><?= npc_icon($n['species']) ?></span><?php endforeach; ?></span><?php endif; ?>
      </a>
    <?php endforeach; ?>
  </div>
  <?php endif; // square view ?>
  <?php $trav = q('SELECT * FROM npcs WHERE traveller IS NOT NULL AND active = 1 ORDER BY name')->fetchAll(); if ($trav): ?>
    <details class="fold box travellers"><summary>🧭 Where the travellers are</summary>
      <?php foreach ($trav as $t): $st = traveller_stop($t); ?>
        <p><?= npc_icon($t['species']) ?> <a href="<?= e(url('folk.php?id=' . (int)$t['id'])) ?>"><?= e($t['name']) ?></a>:
          <?= $st['town'] === $town ? '<b>here, on the Green!</b>' : 'in ' . e($st['town']) . ', then ' . e($st['next']) ?></p>
      <?php endforeach; ?></details>
  <?php endif; ?>
  <?php $up = upcoming_festivals(3); if ($up): ?>
    <details class="fold box festivals"><summary>🎪 Festivals coming up</summary>
      <?php foreach ($up as [$ft, $ff, $days]): ?><p><?= $ff[1] ?> <b><?= e($ff[0]) ?></b> in <?= e($ft) ?> · <?= $days === 0 ? '<b>today!</b>' : ($days === 1 ? 'tomorrow' : 'in ' . $days . ' days') ?></p><?php endforeach; ?>
      <p class="help">Each town has one festival day a month.</p></details>
  <?php endif; ?>
  <p class="help">Most things can be done once or a few times a day; the day turns over at midnight Hollow time. ⭐ Gold-edged places are found only in <?= e($town) ?>.</p>
<?php endif; ?>
<?php page_footer();
