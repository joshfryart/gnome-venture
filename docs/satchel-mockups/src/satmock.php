<?php
declare(strict_types=1);
/*
 * MOCKUP ONLY: three designs for the Satchel tab and the Crafting tabs, real data and real forms.
 *   ?d=1  "Pantry twin"       list + detail panel / bottom sheet (reuses the shipped .pantry2 CSS and its site.js sheet code as they are)
 *   ?d=2  "Dense grid + drawer" mini item squares (the real item_square) + a docked drawer / bottom sheet
 *   ?d=3  "Shelves"           collapsible shelves of pills, a quick bar on top, the pick opens inline under its row (Have / Need for recipes)
 *   ?s=bag|craft  &c=cooking|tools|garden|building|decor  &g=group  &show=  &q=  &sel=id
 * Data: includes/satmock_data.php (one adapter for both surfaces). CSS: assets/satmock.css. JS: assets/satmock.js.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
$u = require_login();
refresh_energy($u);
require_once __DIR__ . '/includes/satmock_data.php';

$d = in_array((int)($_GET['d'] ?? 1), [1, 2, 3], true) ? (int)$_GET['d'] : 1;
$s = ($_GET['s'] ?? 'bag') === 'craft' ? 'craft' : 'bag';
$c = (string)($_GET['c'] ?? 'cooking');
if (!isset(CRAFT_CATEGORIES[$c]) || $c === 'pantry') $c = 'cooking';
$g = (string)($_GET['g'] ?? '');
$qs = trim((string)($_GET['q'] ?? ''));
$selId = (int)($_GET['sel'] ?? 0);

if ($s === 'bag') {
    $all = sm_bag($u);
    $groups = sm_groups($all, SM_BAG_GROUPS);
    $shows = ['all' => ['All', count($all)], 'untasted' => ['✨ Untasted', count(array_filter($all, fn($e) => $e['untasted']))],
              'new' => ['🕒 New', count(array_filter($all, fn($e) => $e['new']))], 'care' => ['🔧 Needs care', count(array_filter($all, fn($e) => $e['care']))]];
    $show = isset($shows[(string)($_GET['show'] ?? '')]) ? (string)$_GET['show'] : 'all';
    $base = array_values(array_filter($all, fn($e) => $show === 'all' || !empty($e[$show])));
    $sort = in_array($_GET['sort'] ?? '', ['type', 'new', 'az', 'most', 'rare'], true) ? (string)$_GET['sort'] : 'type';
    $rank = ['L' => 4, 'R' => 3, 'U' => 2, 'C' => 1];
    $order = array_flip(array_keys(SM_BAG_GROUPS));
    usort($base, match ($sort) {
        'new' => fn($a, $b) => [(string)$b['item']['got_at'], $b['id']] <=> [(string)$a['item']['got_at'], $a['id']],
        'az' => fn($a, $b) => strcasecmp($a['name'], $b['name']),
        'most' => fn($a, $b) => [$b['count'], $a['name']] <=> [$a['count'], $b['name']],
        'rare' => fn($a, $b) => [$rank[$b['rarity']], $a['name']] <=> [$rank[$a['rarity']], $b['name']],
        default => fn($a, $b) => [$order[$a['group']] ?? 99, $a['name']] <=> [$order[$b['group']] ?? 99, $b['name']],
    });
    $title = '👜 Satchel';
    $titleSmall = count($all) . ' kinds · ' . number_format(array_sum(array_map(fn($e) => $e['count'], $all))) . ' things';
    $noun = 'things';
} else {
    $all = sm_craft($u, $c);
    $known = array_values(array_filter($all, fn($e) => $e['status'] !== 'unk'));
    $groups = sm_groups($c === 'cooking' ? $known : $known, $c === 'cooking' ? SM_TIERS : []);
    $shows = ['known' => ['All known', count($known)], 'ready' => ['✅ Can make', count(array_filter($all, fn($e) => $e['status'] === 'ok'))],
              'missing' => ['📋 Missing', count(array_filter($all, fn($e) => $e['status'] === 'miss'))], 'unknown' => ['❔ To discover', count($all) - count($known)]];
    $show = isset($shows[(string)($_GET['show'] ?? '')]) ? (string)$_GET['show'] : 'known';
    $base = array_values(array_filter($all, fn($e) => match ($show) { 'known' => $e['status'] !== 'unk', 'ready' => $e['status'] === 'ok', 'missing' => $e['status'] === 'miss', default => $e['status'] === 'unk' }));
    if ($show === 'unknown') $groups = [];
    [$cl, $ci] = CRAFT_CATEGORIES[$c];
    $title = $ci . ' ' . $cl;
    $counts = [];
    foreach (q('SELECT r.category, COUNT(*) AS total, COUNT(ur.id) AS have FROM recipes r LEFT JOIN user_recipes ur ON ur.recipe_id = r.id AND ur.user_id = ? GROUP BY r.category', [(int)$u['id']])->fetchAll() as $x) $counts[$x['category']] = $x;
    $titleSmall = count($known) . '/' . count($all) . ' recipes known';
    $noun = 'recipes';
    $sort = 'type';
}
if (!isset($groups[$g])) $g = '';
$list = array_values(array_filter($base, fn($e) => ($g === '' || $e['group'] === $g) && ($qs === '' || stripos($e['hay'], $qs) !== false)));
$sel = null;
foreach ($list as $e) if ($e['id'] === $selId) $sel = $e;
$picked = $sel !== null;
if ($d !== 3) $sel ??= $list[0] ?? null;

$link = function (array $over = []) use ($d, $s, $c, $g, $qs, $show, $sort, $sel): string {
    $p = ['d' => $d, 's' => $s, 'c' => $s === 'craft' ? $c : '', 'show' => in_array($show, ['all', 'known'], true) ? '' : $show, 'g' => $g, 'q' => $qs, 'sort' => $sort === 'type' ? '' : $sort, 'sel' => ''];
    $p = array_filter(array_merge($p, $over), fn($v) => $v !== '' && $v !== null && $v !== 0);
    return url('satmock.php?' . http_build_query($p));
};
$pic = fn(array $e, string $size) => $e['item'] ? item_icon($e['item'], $size, '-') : '❔';
$hidden = function (array $keep) use ($d, $s, $c, $show, $g, $sort): string {
    $h = '';
    foreach (['d' => $d, 's' => $s, 'c' => $s === 'craft' ? $c : '', 'show' => in_array($show, ['all', 'known'], true) ? '' : $show, 'g' => $g, 'sort' => $sort === 'type' ? '' : $sort] as $k => $v)
        if ($v !== '' && in_array($k, $keep, true)) $h .= '<input type="hidden" name="' . $k . '" value="' . e((string)$v) . '">';
    return $h;
};

// shared pieces ------------------------------------------------------------------------------------------
$head = function () use ($s, $c, $title, $titleSmall, $hidden, $sort, $d): void { global $counts; ?>
  <div class="p2head smhead">
    <?php if ($s === 'craft'): ?>
    <form method="get" action="<?= e(url('satmock.php')) ?>" class="pickform p2cat"><?= $hidden(['d', 's']) ?>
      <label><span class="vh">Make</span><select name="c" data-autosubmit>
        <?php foreach (CRAFT_CATEGORIES as $k => [$l, $ic]): ?><option value="<?= e($k) ?>"<?= $k === $c ? ' selected' : '' ?>><?= $ic ?> <?= e($l) ?> (<?= (int)($counts[$k]['have'] ?? 0) ?>/<?= (int)($counts[$k]['total'] ?? 0) ?>)</option><?php endforeach; ?>
      </select></label><button class="btn small pickgo">Go</button>
    </form>
    <?php else: ?>
    <form method="get" action="<?= e(url('satmock.php')) ?>" class="pickform p2cat"><?= $hidden(['d', 's', 'show', 'g']) ?>
      <label><span class="vh">Sort</span><select name="sort" data-autosubmit>
        <?php foreach (['type' => '🗂️ By type', 'new' => '🕒 Newest first', 'az' => '🔤 Name A–Z', 'most' => '📦 Most owned', 'rare' => '💎 Rarest first'] as $k => $l): ?><option value="<?= $k ?>"<?= $k === $sort ? ' selected' : '' ?>><?= $l ?></option><?php endforeach; ?>
      </select></label><button class="btn small pickgo">Go</button>
    </form>
    <?php endif; ?>
    <h2 class="p2title"><?= e($title) ?> <small><?= e($titleSmall) ?></small></h2>
  </div>
<?php };
$search = function () use ($hidden, $qs, $noun, $all, $s): void { ?>
  <form method="get" action="<?= e(url('satmock.php')) ?>" class="p2search" role="search"><?= $hidden(['d', 's', 'c', 'show', 'g', 'sort']) ?>
    <label class="vh" for="smq">Search</label>
    <input id="smq" type="search" name="q" value="<?= e($qs) ?>" placeholder="🔍 Search <?= $s === 'bag' ? count($all) . ' things in your satchel' : 'recipes' ?>…" autocomplete="off">
  </form>
<?php };
$chipsShow = function () use ($shows, $show, $link): void { ?>
  <nav class="chips p2show" aria-label="Which">
    <?php foreach ($shows as $k => [$l, $n]): if ($n === 0 && $k !== $show && !in_array($k, ['all', 'known'], true)) continue; ?>
      <a class="<?= $show === $k ? 'on' : '' ?>" href="<?= e($link(['show' => in_array($k, ['all', 'known'], true) ? '' : $k, 'g' => ''])) ?>"><?= $l ?> <small><?= $n ?></small></a>
    <?php endforeach; ?>
  </nav>
<?php };
$chipsGroup = function () use ($groups, $g, $link): void { if (!$groups) return; ?>
  <nav class="chips p2kinds" aria-label="Kind">
    <a class="<?= $g === '' ? 'on' : '' ?>" href="<?= e($link(['g' => ''])) ?>">All</a>
    <?php foreach ($groups as $k => [$ic, $l, $n]): ?><a class="<?= $g === $k ? 'on' : '' ?>" href="<?= e($link(['g' => $k])) ?>"><?= $ic ?> <?= e($l) ?> <small><?= $n ?></small></a><?php endforeach; ?>
  </nav>
<?php };
$empty = fn() => '<p class="muted">' . ($qs !== '' ? 'Nothing matches “' . e($qs) . '”.' : 'Nothing here yet.') . '</p>';
$cls = fn(array $e) => ['ok' => 'ok', 'miss' => 'miss', 'unk' => 'unk', 'use' => 'use', 'off' => 'off'][$e['status']] ?? '';

page_header($s === 'craft' ? 'Crafting' : 'Satchel');
?>
<link rel="stylesheet" href="<?= e(url('assets/satmock.css?v=' . filemtime(__DIR__ . '/assets/satmock.css'))) ?>">
<script src="<?= e(url('assets/satmock.js?v=' . filemtime(__DIR__ . '/assets/satmock.js'))) ?>" defer></script>
<h1>👜 Your Satchel</h1>
<nav class="tabs bagtabs tabs4">
  <a class="<?= $s === 'bag' ? 'on' : '' ?>" href="<?= e(url('satmock.php?d=' . $d)) ?>"><span aria-hidden="true">👜</span> Satchel</a>
  <a class="<?= $s === 'craft' ? 'on' : '' ?>" href="<?= e(url('satmock.php?d=' . $d . '&s=craft')) ?>"><span aria-hidden="true">🔨</span> Crafting</a>
  <a href="<?= e(url('inventory.php?tab=belt')) ?>"><span aria-hidden="true">🧰</span> Belt</a>
  <a href="<?= e(url('arrange.php')) ?>"><span aria-hidden="true">💐</span> Arrange</a>
</nav>
<?php

// ===================================== DESIGN 1: Pantry twin ============================================
if ($d === 1): ?>
<div class="pantry2 sm sm1">
  <?php $head(); ?>
  <?php if ($s === 'craft') echo sm_station($u, $c); ?>
  <?php $search(); $chipsShow(); $chipsGroup(); ?>
  <?php if (!$list): echo $empty(); else: ?>
  <div class="p2md">
    <ul class="p2list" aria-label="<?= e(ucfirst($noun)) ?>">
      <?php $lastG = null; foreach ($list as $e): $isSel = $sel && $sel['id'] === $e['id'];
        if ($s === 'bag' && $sort === 'type' && $g === '' && $e['group'] !== $lastG): $lastG = $e['group']; [$gi, $gl, $gn] = $groups[$e['group']]; ?>
          <li class="smgh" aria-hidden="true"><?= $gi ?> <?= e($gl) ?> <small><?= $gn ?></small></li>
        <?php endif; ?>
        <li><a class="p2row <?= $cls($e) ?><?= $isSel ? ' sel' : '' ?>" href="<?= e($link(['sel' => $e['id']])) ?>#p2d"<?= $isSel ? ' aria-current="true"' : '' ?>>
          <span class="p2ic"><?= $pic($e, 'sm') ?></span>
          <span class="p2rm"><b><?= e($e['name']) ?><?= $e['flag'] === 'New' || $e['flag'] === 'Rare taste!' ? ' <span class="tag smflag">' . e($e['flag']) . '</span>' : '' ?></b><small><?= $e['meta'] ?></small></span>
          <?php if ($s === 'bag'): ?><b class="smcount"><span class="vh">You have </span>×<?= (int)$e['count'] ?></b>
          <?php else: ?><i class="p2dot" aria-hidden="true"></i><span class="vh"><?= ['ok' => 'you can make this', 'miss' => 'missing ingredients', 'unk' => 'not discovered'][$e['status']] ?? '' ?></span><?php endif; ?>
        </a></li>
      <?php endforeach; ?>
    </ul>
    <?php if ($sel): ?>
    <section class="p2det box <?= $cls($sel) ?>" id="p2d" aria-label="Selected">
      <details class="p2sheet" open>
        <summary class="p2dh">
          <span class="p2big"><?= $pic($sel, 'lg') ?></span>
          <span class="p2dt"><b class="p2name"><?= e($sel['name']) ?></b><span class="p2tags"><?= $sel['tags'] ?></span><small class="p2sub"><?= $sel['sub'] ?></small></span>
          <span class="p2grab" aria-hidden="true"></span><span class="p2chev" aria-hidden="true">▾</span>
        </summary>
        <div class="smbody"><?= $sel['body'] ?></div>
        <?= $sel['lines'] ?>
      </details>
      <div class="p2acts smacts"><?= $sel['acts'] ?></div>
    </section>
    <?php endif; ?>
  </div>
  <?php endif; ?>
</div>
<?php

// ===================================== DESIGN 2: Dense grid + drawer ====================================
elseif ($d === 2): ?>
<div class="pantry2 sm sm2<?= $picked ? ' has-pick' : '' ?>">
  <?php $head(); ?>
  <?php if ($s === 'craft') echo sm_station($u, $c); ?>
  <div class="smbar"><?php $search(); $chipsShow(); $chipsGroup(); ?></div>
  <?php if (!$list): echo $empty(); else: ?>
  <div class="smgridwrap">
    <div class="itmwrap"><div class="itms smgrid">
      <?php foreach ($list as $e):
        $st = [];
        if ($s === 'craft') { if ($e['status'] === 'ok') $st[] = 'done'; if ($e['status'] === 'unk') $st[] = 'off'; }
        else { if ($e['status'] === 'use') $st[] = 'use'; if ($e['status'] === 'off') $st[] = 'off'; }
        if ($sel && $picked && $sel['id'] === $e['id']) $st[] = 'sel';
        echo item_square(['item' => $e['item'] ?? [], 'name' => $e['name'], 'rarity' => $e['rarity'], 'tag' => 'a', 'class' => 'smmini st-' . ($e['status'] ?: 'none'),
            'attrs' => ['href' => $link(['sel' => $e['id']]) . '#smd'], 'count' => $e['count'], 'states' => $st, 'icon' => $e['item'] ? '' : '❔',
            'flag' => $e['flag'], 'flagClass' => $e['flag'] === 'Rare taste!' ? 'taste' : '',
            'vh' => '<span class="vh">' . ($s === 'craft' ? (['ok' => ': you can make this', 'miss' => ': missing ingredients', 'unk' => ': not discovered'][$e['status']] ?? '') : '') . '</span>']);
      endforeach; ?>
    </div></div>
    <?php if ($sel): ?>
    <a class="smscrim" href="<?= e($link()) ?>" aria-label="Close"></a>
    <aside class="smdrawer <?= $cls($sel) ?><?= $picked ? ' is-open' : '' ?>" id="smd" aria-label="Selected">
      <div class="smdh">
        <span class="p2big"><?= $pic($sel, 'lg') ?></span>
        <span class="p2dt"><b class="p2name"><?= e($sel['name']) ?></b><span class="p2tags"><?= $sel['tags'] ?></span><small class="p2sub"><?= $sel['sub'] ?></small></span>
        <a class="smx" href="<?= e($link()) ?>" aria-label="Close">✕</a>
      </div>
      <div class="smdb"><div class="smbody"><?= $sel['body'] ?></div><?= $sel['lines'] ?></div>
      <div class="p2acts smacts"><?= $sel['acts'] ?></div>
    </aside>
    <?php endif; ?>
  </div>
  <?php endif; ?>
</div>
<?php

// ===================================== DESIGN 3: Shelves (+ quick bar, Have / Need) =======================
else:
    if ($s === 'craft') {   // shelves by how close you are, not by kind
        $shelfDefs = ['ready' => ['✅', 'Ready to ' . ($c === 'cooking' ? 'cook' : 'make')], 'close' => ['🧺', 'One trip away'], 'far' => ['📋', 'Need more'], 'unk' => ['❔', 'To discover']];
        $shelfOf = fn(array $e) => $e['status'] === 'ok' ? 'ready' : ($e['status'] === 'unk' ? 'unk' : ($e['short'] <= 2 ? 'close' : 'far'));
        $openDef = ['ready' => true, 'close' => true, 'far' => false, 'unk' => false];
        $src = array_values(array_filter($all, fn($e) => $qs === '' || stripos($e['hay'], $qs) !== false));
    } else {
        $shelfDefs = SM_BAG_GROUPS;
        $shelfOf = fn(array $e) => $e['group'];
        $openDef = array_fill_keys(array_keys(SM_BAG_GROUPS), true);
        $src = $list;
    }
    $shelves = [];
    foreach ($src as $e) $shelves[$shelfOf($e)][] = $e;
    $shelves = array_intersect_key(array_merge(array_fill_keys(array_keys($shelfDefs), []), $shelves), array_filter($shelves));
    $want = (string)($_GET['open'] ?? '');   // a shelf opened by hand (no JS: a link); JS remembers the rest
?>
<div class="pantry2 sm sm3">
  <?php $head(); ?>
  <?php if ($s === 'craft'): echo sm_station($u, $c);
      // shopping list: what the "one trip away" recipes still need, summed
      $shop = [];
      foreach ($shelves['close'] ?? [] as $e) foreach ($e['ings'] as $i) if ($i['have'] < $i['qty']) {
          $shop[$i['slug']] ??= ['name' => $i['name'], 'need' => 0, 'have' => $i['have'], 'for' => 0, 'it' => $e['icons'][$i['slug']] ?? null];
          $shop[$i['slug']]['need'] = max($shop[$i['slug']]['need'], $i['qty']); $shop[$i['slug']]['for']++;
      }
      uasort($shop, fn($a, $b) => $b['for'] <=> $a['for']);
      if ($shop): ?>
      <section class="smquick" aria-label="Shopping list"><h3 class="smqh">🧺 Shopping list <small>gather these to unlock <?= count($shelves['close']) ?> more</small></h3>
        <div class="smqrow"><?php foreach (array_slice($shop, 0, 12, true) as $sl => $x): ?>
          <span class="smqi"><span class="p2ic"><?= $x['it'] ? item_icon($x['it'], 'sm', '-') : '❔' ?></span><span><b><?= e($x['name']) ?></b><small><?= (int)$x['have'] ?>/<?= (int)$x['need'] ?> · for <?= (int)$x['for'] ?></small></span></span>
        <?php endforeach; ?></div></section>
      <?php endif; ?>
  <?php else: $quick = array_values(array_filter($all, fn($e) => $e['quick'])); if ($quick): ?>
    <section class="smquick" aria-label="Quick actions"><h3 class="smqh">⚡ Quick <small>one tap, no digging</small></h3>
      <div class="smqrow"><?php foreach (array_slice($quick, 0, 10) as $e): ?>
        <span class="smqi"><span class="p2ic"><?= $pic($e, 'sm') ?></span><span><b><?= e($e['name']) ?></b><small>×<?= (int)$e['count'] ?><?= $e['flag'] === 'Rare taste!' ? ' · <span class="smtaste">rare taste</span>' : '' ?></small></span><?= $e['quick'][1] ?></span>
      <?php endforeach; ?></div></section>
  <?php endif; endif; ?>
  <?php $search(); ?>
  <?php if (!$shelves): echo $empty(); endif; ?>
  <?php foreach ($shelves as $k => $rows): [$si, $sl] = $shelfDefs[$k]; $hasSel = $selId && in_array($selId, array_column($rows, 'id'), true);
      $open = $hasSel || $want === $k || ($openDef[$k] ?? false) || $qs !== ''; ?>
    <details class="smshelf sh-<?= e($k) ?>" data-shelf="<?= e($s . ':' . $k) ?>"<?= $open ? ' open' : '' ?>>
      <summary class="smsh"><span class="smshi" aria-hidden="true"><?= $si ?></span><b><?= e($sl) ?></b><small><?= count($rows) ?><?= $s === 'bag' ? ' kinds · ×' . array_sum(array_column($rows, 'count')) : '' ?></small>
        <?php if ($s === 'craft' && $k !== 'unk'): ?><span class="smshp" aria-hidden="true"><?php foreach (array_slice($rows, 0, 5) as $e) echo '<span class="p2ic">' . $pic($e, 'sm') . '</span>'; ?></span><?php endif; ?>
        <span class="p2chev" aria-hidden="true">▾</span></summary>
      <div class="smpills">
        <?php foreach ($rows as $e): $isSel = $selId === $e['id']; ?>
          <a class="smpill <?= $cls($e) ?><?= $isSel ? ' sel' : '' ?>" href="<?= e($link(['sel' => $isSel ? '' : $e['id']])) ?><?= $isSel ? '' : '#smp' ?>"<?= $isSel ? ' aria-expanded="true"' : '' ?>>
            <span class="p2ic"><?= $pic($e, 'sm') ?></span>
            <span class="smpt"><b><?= e($e['name']) ?></b><small><?= $s === 'bag' ? '×' . (int)$e['count'] . ($e['status'] === 'use' ? ' · in use' : '') . ($e['untasted'] ? ' · ✨' : '') : ($e['status'] === 'ok' ? $e['pmeta'] : ($e['status'] === 'unk' ? strip_tags((string)$e['meta']) : 'short ' . (int)$e['short'])) ?></small></span>
            <?php if ($e['flag'] === 'New' || $e['flag'] === 'Rare taste!'): ?><i class="smnew" aria-hidden="true"></i><?php endif; ?>
          </a>
          <?php if ($isSel): ?>
          <div class="smpanel <?= $cls($e) ?>" id="smp" role="region" aria-label="<?= e($e['name']) ?>">
            <div class="smdh"><span class="p2big"><?= $pic($e, 'lg') ?></span>
              <span class="p2dt"><b class="p2name"><?= e($e['name']) ?></b><span class="p2tags"><?= $e['tags'] ?></span><small class="p2sub"><?= $e['sub'] ?></small></span>
              <a class="smx" href="<?= e($link()) ?>" aria-label="Close">✕</a></div>
            <?php if ($s === 'craft' && $e['status'] !== 'unk'): ?>
              <?= $e['when'] ? '<p class="p2fit">' . $e['when'] . '</p>' : '' ?>
              <div class="smhn">
                <div class="smhave"><h4>✔ You have</h4><?= $e['have'] !== '' ? '<ul class="p2ingcmp">' . $e['have'] . '</ul>' : '<p class="muted">Nothing yet.</p>' ?></div>
                <div class="smneed"><h4>✖ Still need</h4><?= $e['need'] !== '' ? '<ul class="p2ingcmp">' . $e['need'] . '</ul>' : '<p class="muted">Nothing: ready to go.</p>' ?></div>
              </div>
            <?php else: ?><div class="smbody"><?= $e['body'] ?></div><?php endif; ?>
            <div class="p2acts smacts"><?= $e['acts'] ?></div>
          </div>
          <?php endif; ?>
        <?php endforeach; ?>
      </div>
    </details>
  <?php endforeach; ?>
</div>
<?php endif;
page_footer();
