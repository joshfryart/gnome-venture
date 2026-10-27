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
      <form method="post" class="inline" data-confirm="Buy a land deed here for <?= number_format(deed_cost((int)$u['id'])) ?>?"><?= csrf_field() ?>
        <input type="hidden" name="do" value="deed"><button class="btn small">Buy land deed</button></form>
    <?php else: ?>
      <span class="muted">📜 Land for sale here<?= next_garden_level($u) ? ' (another garden from gnome level ' . next_garden_level($u) . ')' : ' (you tend as many gardens as a gnome can)' ?>.</span>
    <?php endif; ?>
  </div>
<?php endif; ?>
<?php return (string)ob_get_clean();
}
