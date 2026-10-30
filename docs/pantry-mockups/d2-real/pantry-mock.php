<?php
declare(strict_types=1);
/* MOCKUP ONLY (D2 "real"): the Pantry as master-detail. Same data and forms as includes/craft_view.php; layout scoped under .pantry2 (assets/pantry2.css).
   ?r=recipe_id picks the recipe, ?k=kind filters, ?show=ready|missing|unknown|known keeps the old list modes, ?q= searches. All forms still POST to crafting.php. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
$u = require_login();
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/crafting.php';
require_once __DIR__ . '/includes/almanac.php';
require_once __DIR__ . '/includes/gardens.php';
require_once __DIR__ . '/includes/item_square.php';
require_once __DIR__ . '/includes/pantry.php';
refresh_energy($u);
$uid = (int)$u['id'];
$tab = 'pantry';
$stations = craft_stations($uid);
$jarLimit = pantry_jar_limit($uid);
if ($jarLimit < 1) $stations['pantry'] = 0;
$recipes = craft_recipes($uid, $tab);
$counts = [];
foreach (q('SELECT r.category, COUNT(*) AS total, COUNT(ur.id) AS have FROM recipes r LEFT JOIN user_recipes ur ON ur.recipe_id = r.id AND ur.user_id = ? GROUP BY r.category', [$uid])->fetchAll() as $c) $counts[$c['category']] = $c;
$now = (int)($u['energy'] ?? 0);
$coins = (int)($u['coins'] ?? 0);

// kinds come from the jar timer the game already uses (pantry.php: jam 1 day, chutney 2, pickles 3, kimchi 5, sauerkraut 7, cordials 14)
const P2_KINDS = ['jam' => ['Jam', [1]], 'chutney' => ['Chutney', [2]], 'pickle' => ['Pickle', [3]], 'ferment' => ['Ferment', [5, 7]], 'cordial' => ['Cordial', [14]]];
$kindOf = function (array $r): string { $d = (int)round(pantry_seconds($r) / 86400); foreach (P2_KINDS as $k => [, $ds]) if (in_array($d, $ds, true)) return $k; return 'jam'; };

$slugs = [];
foreach ($recipes as $r) foreach ($r['ings'] as $i) $slugs[$i['slug']] = true;
$icons = [];
if ($slugs) { $ph = implode(',', array_fill(0, count($slugs), '?')); foreach (q("SELECT * FROM items WHERE slug IN ($ph)", array_keys($slugs))->fetchAll() as $it) $icons[$it['slug']] = $it; }
$outItems = [];
foreach (q('SELECT i.* FROM items i JOIN recipes r ON r.output_item_id = i.id WHERE r.category = ?', [$tab])->fetchAll() as $it) $outItems[(int)$it['id']] = $it;
$pic = fn(int $itemId, string $size, string $fallback = '🫙') => isset($outItems[$itemId]) ? item_icon($outItems[$itemId], $size, '-') : $fallback;

usort($recipes, fn($a, $b) => [$b['known'], $b['known'] && $b['can']] <=> [$a['known'], $a['known'] && $a['can']] ?: strcmp($a['name'], $b['name']));
$ready = array_values(array_filter($recipes, fn($r) => $r['known'] && $r['can']));
$missing = array_values(array_filter($recipes, fn($r) => $r['known'] && !$r['can']));
$unknown = array_values(array_filter($recipes, fn($r) => !$r['known']));
$show = (string)($_GET['show'] ?? 'known');
if (!in_array($show, ['known', 'ready', 'missing', 'unknown'], true)) $show = 'known';
$kind = (string)($_GET['k'] ?? '');
if (!isset(P2_KINDS[$kind])) $kind = '';
$qs = trim((string)($_GET['q'] ?? ''));
$base = ['known' => array_merge($ready, $missing), 'ready' => $ready, 'missing' => $missing, 'unknown' => $unknown][$show];
$list = array_values(array_filter($base, fn($r) => ($kind === '' || $kindOf($r) === $kind) && ($qs === '' || stripos($r['known'] ? $r['name'] : '', $qs) !== false)));
$kindN = []; foreach ($base as $r) $kindN[$kindOf($r)] = ($kindN[$kindOf($r)] ?? 0) + 1;

$jarsList = $stations['pantry'] !== 0 ? pantry_jars_list($uid) : [];
$jarsFree = max(0, $jarLimit - count($jarsList));
$jr = count(array_filter($jarsList, fn($j) => $j['left'] <= 0));

$selId = (int)($_GET['r'] ?? 0);
$sel = null;
foreach ($list as $r) if ((int)$r['id'] === $selId) $sel = $r;
$sel ??= $list[0] ?? null;
$link = function (array $over = []) use ($show, $kind, $qs, $sel): string {
    $p = array_filter(['show' => $show === 'known' ? '' : $show, 'k' => $kind, 'q' => $qs, 'r' => $sel ? (string)$sel['id'] : ''] , 'strlen');
    $p = array_filter(array_merge($p, $over), fn($v) => $v !== '' && $v !== null);
    return url('pantry-mock.php' . ($p ? '?' . http_build_query($p) : ''));
};

/** the make block for one recipe: same rules and same POST as craft_view.php's $card */
$make = function (array $r, bool $compact = false) use ($u, $tab, $stations, $now, $coins, $jarsFree): string {
    ob_start();
    if (!$r['known']) { ?><p class="muted p2note">Collect everything above to discover it.</p><?php return (string)ob_get_clean(); }
    if (!$r['can']) {
        $short = array_filter($r['ings'], fn($i) => $i['have'] < $i['qty']); ?>
        <p class="ccneed p2note">Need <?= e(implode(', ', array_map(fn($i) => ($i['qty'] - $i['have']) . ' ' . $i['name'], $short))) ?></p>
        <?php return (string)ob_get_clean();
    }
    if ($stations[$tab] === 0) return '';
    $cost = craft_energy_cost($u, $tab, (int)$r['energy'], 'preserve');
    $fit = min(craft_fit($r['ings'], $cost, $now), $jarsFree); ?>
    <?php if ($fit >= 1): ?>
      <form method="post" action="<?= e(url('crafting.php?c=' . $tab)) ?>" class="ccbtns p2make"><?= csrf_field() ?><input type="hidden" name="recipe_id" value="<?= (int)$r['id'] ?>">
        <button class="btn" name="qty" value="1">Make ×1<?php if ($cost > 0): ?> <span class="cbcost">⚡<?= (int)$cost ?></span><?php endif; ?></button>
        <?php if ($fit >= 5): ?><button class="btn alt" name="qty" value="5">×5</button><?php elseif ($fit >= 2): ?><button class="btn alt" name="qty" value="2">×2</button><?php endif; ?>
        <?php if ($fit >= 3): ?><button class="btn alt" name="qty" value="all">All <?= $fit ?></button><?php endif; ?>
      </form>
    <?php elseif ($jarsFree < 1): ?><p class="ccneed p2note">All jars are full. Collect one to start another.</p>
    <?php elseif ($cost > 0 && $now < $cost): ?><p class="ccneed p2note">Too tired: this takes ⚡<?= $cost ?>, you have ⚡<?= $now ?>.</p>
    <?php endif;
    return (string)ob_get_clean();
};
$ingGrid = function (array $r) use ($icons): string {
    $sq = '';
    foreach ($r['ings'] as $i) {
        $it = $icons[$i['slug']] ?? ['name' => $i['name']];
        $have = (int)$i['have']; $need = (int)$i['qty'];
        if ($r['known']) {
            $ok = $have >= $need;
            $sq .= item_square(['item' => $it, 'name' => (string)$i['name'], 'tag' => 'div', 'class' => 'ccing', 'count' => $have,
                'chips' => [$ok ? ['ok', '✔ uses ' . number_format($need)] : ['short', '✖ short ' . number_format($need - $have)]],
                'vh' => '<span class="vh">' . ($ok ? 'enough' : 'not enough') . ': you have ' . $have . ', the recipe needs ' . $need . '</span>']);
        } elseif ($i['seen']) {
            $sq .= item_square(['item' => $it, 'name' => (string)$i['name'], 'tag' => 'div', 'class' => 'ccing', 'states' => ['done'], 'chips' => [['note', 'Found']]]);
        } else {
            $sq .= item_square(['item' => $it, 'name' => (string)$i['name'], 'tag' => 'div', 'class' => 'ccing', 'icon' => '❔', 'rarity' => 'C', 'states' => ['off'], 'chips' => [['note', 'Not found yet']]]);
        }
    }
    return item_grid($sq, 'itms--flush ccings p2ings');
};
$when = function (array $r) use ($jarsFree): string {
    $s = pantry_seconds($r);
    return '⏱ <b>' . e(pantry_time_text($s)) . '</b> <span class="muted">· ' . ($jarsFree > 0 ? 'ready ' . e(date('D j M', time() + $s)) . ' in a free jar' : 'no free jar right now') . '</span>';
};

page_header('Crafting');
?>
<link rel="stylesheet" href="<?= e(url('assets/pantry2.css')) ?>">
<h1>👜 Your Satchel</h1>
<nav class="tabs bagtabs tabs4">
  <a href="<?= e(url('inventory.php')) ?>"><span aria-hidden="true">👜</span> Satchel</a>
  <a class="on" href="<?= e(url('inventory.php?tab=craft')) ?>"><span aria-hidden="true">🔨</span> Crafting</a>
  <a href="<?= e(url('inventory.php?tab=belt')) ?>"><span aria-hidden="true">🧰</span> Belt</a>
  <a href="<?= e(url('arrange.php')) ?>"><span aria-hidden="true">💐</span> Arrange</a>
</nav>
<div class="pantry2">
<div class="p2head">
  <form method="get" action="<?= e(url('inventory.php')) ?>" class="pickform p2cat"><input type="hidden" name="tab" value="craft">
    <label><span class="vh">Make</span><select name="c" data-autosubmit>
      <?php foreach (CRAFT_CATEGORIES as $k => [$l, $ic]): ?><option value="<?= e($k) ?>"<?= $k === $tab ? ' selected' : '' ?>><?= $ic ?> <?= e($l) ?> (<?= (int)($counts[$k]['have'] ?? 0) ?>/<?= (int)($counts[$k]['total'] ?? 0) ?>)</option><?php endforeach; ?>
    </select></label>
    <button class="btn small pickgo">Go</button>
  </form>
  <h2 class="p2title">🫙 Pantry <small><?= count($jarsList) ?>/<?= $jarLimit ?> jars in use</small></h2>
  <details class="helpfold p2help"><summary>❓ How the Pantry works</summary><p class="help">One jar holds one batch. Timers run in real days, even while you are away, and nothing spoils. Jam takes 1 day, chutney 2, pickles 3, kimchi 5, sauerkraut 7, cordials 14. A recipe appears once you’ve collected every ingredient.</p></details>
</div>

<?php if ($jarLimit > 0): ?>
<section class="p2jars jarstrip" aria-label="Pantry jars">
  <div class="p2jarrow">
    <?php foreach ($jarsList as $j): $done = $j['left'] <= 0; ?>
      <div class="p2jar jar <?= $done ? 'done' : 'busy' ?>" title="<?= e($j['name']) ?> ×<?= (int)$j['qty'] ?>">
        <span class="p2ic"><?= $pic((int)$j['item_id'], 'sm') ?></span>
        <span class="p2jt"><span class="vh"><?= e($j['name']) ?> ×<?= (int)$j['qty'] ?>: </span><span class="potleft" data-jarleft="<?= (int)$j['left'] ?>"><?= $done ? 'Ready!' : e(pantry_time_text((int)$j['left'])) ?></span></span>
        <form method="post" action="<?= e(url('crafting.php?c=pantry')) ?>" class="potcollect"<?= $done ? '' : ' hidden' ?>><?= csrf_field() ?>
          <input type="hidden" name="do" value="jar_collect"><input type="hidden" name="jar_id" value="<?= (int)$j['id'] ?>"><button class="btn small">Collect</button></form>
      </div>
    <?php endforeach; ?>
    <?php if ($jarsFree > 0): ?><div class="p2jar empty"><span class="p2ic" aria-hidden="true">🫙</span><span class="p2jt">+<?= $jarsFree ?> free</span></div><?php endif; ?>
    <form method="post" action="<?= e(url('crafting.php?c=pantry')) ?>" class="p2all" data-jarall<?= $jr >= 2 ? '' : ' hidden' ?>><?= csrf_field() ?><input type="hidden" name="do" value="jar_collect_all"><button class="btn small alt">Collect all</button></form>
  </div>
</section>
<?php else: [$pc, $pm] = pantry_cost(); ?>
  <div class="box notice">You need a <b>🫙 Pantry</b> to make these: an add-on for your Kitchen (<?= money($pc) ?><?= $pm ? ' + ' . e(upgrade_mats_text($pm)) : '' ?>).</div>
<?php endif; ?>

<form method="get" action="<?= e(url('pantry-mock.php')) ?>" class="p2search" role="search">
  <?php if ($show !== 'known'): ?><input type="hidden" name="show" value="<?= e($show) ?>"><?php endif; ?>
  <?php if ($kind !== ''): ?><input type="hidden" name="k" value="<?= e($kind) ?>"><?php endif; ?>
  <label class="vh" for="p2q">Search recipes</label>
  <input id="p2q" type="search" name="q" value="<?= e($qs) ?>" placeholder="🔍 Search <?= count($ready) + count($missing) ?> recipes…" autocomplete="off">
</form>
<nav class="chips p2show" aria-label="Which recipes">
  <?php foreach (['known' => ['All known', count($ready) + count($missing)], 'ready' => ['✅ Can make', count($ready)], 'missing' => ['📋 Missing', count($missing)], 'unknown' => ['❔ To discover', count($unknown)]] as $k => [$l, $n]): ?>
    <a class="<?= $show === $k ? 'on' : '' ?>" href="<?= e($link(['show' => $k === 'known' ? '' : $k, 'r' => ''])) ?>"><?= $l ?> <small><?= $n ?></small></a>
  <?php endforeach; ?>
</nav>
<nav class="chips p2kinds" aria-label="Kind">
  <a class="<?= $kind === '' ? 'on' : '' ?>" href="<?= e($link(['k' => '', 'r' => ''])) ?>">All</a>
  <?php foreach (P2_KINDS as $k => [$l, $ds]): ?><a class="<?= $kind === $k ? 'on' : '' ?>" href="<?= e($link(['k' => $k, 'r' => ''])) ?>"><?= $l ?> <small><?= (int)($kindN[$k] ?? 0) ?></small></a><?php endforeach; ?>
</nav>

<?php if (!$list): ?>
  <p class="muted"><?= ['known' => 'No recipes yet.', 'ready' => 'Nothing you can make right now. Check 📋 Missing to see what to gather.', 'missing' => 'Nothing missing: everything you know, you can make.', 'unknown' => 'You’ve discovered every recipe here!'][$show] ?></p>
<?php else: ?>
<div class="p2md">
  <ul class="p2list" aria-label="Recipes">
    <?php foreach ($list as $r): $isSel = $sel && (int)$sel['id'] === (int)$r['id'];
      $shortN = array_sum(array_map(fn($i) => max(0, $i['qty'] - $i['have']), $r['ings'])); ?>
      <li><a class="p2row <?= !$r['known'] ? 'unk' : ($r['can'] ? 'ok' : 'miss') ?><?= $isSel ? ' sel' : '' ?>" href="<?= e($link(['r' => (string)$r['id']])) ?>#p2d"<?= $isSel ? ' aria-current="true"' : '' ?>>
        <span class="p2ic"><?= $r['known'] ? $pic((int)$r['output_item_id'], 'sm') : '❔' ?></span>
        <span class="p2rm"><b><?= $r['known'] ? e($r['name']) : '???' ?><?= !empty($r['new']) ? ' <span class="tag">new!</span>' : '' ?></b>
          <small><?= e(pantry_time_text(pantry_seconds($r))) ?> · <?= (int)$r['output_qty'] ?> jars<?php if ($r['known'] && !$r['can']): ?> · <span class="p2short">short <?= $shortN ?></span><?php endif; ?></small></span>
        <i class="p2dot" aria-hidden="true"></i><span class="vh"><?= !$r['known'] ? 'not discovered' : ($r['can'] ? 'you can make this' : 'missing ingredients') ?></span>
      </a></li>
    <?php endforeach; ?>
  </ul>

  <?php if ($sel): $sk = $kindOf($sel); ?>
  <section class="p2det box <?= !$sel['known'] ? 'unk' : ($sel['can'] ? 'ok' : 'miss') ?>" id="p2d" aria-label="Selected recipe">
    <details class="p2sheet" open>
      <summary class="p2dh">
        <span class="p2big"><?= $sel['known'] ? $pic((int)$sel['output_item_id'], 'lg') : '❔' ?></span>
        <span class="p2dt"><b class="p2name"><?= $sel['known'] ? e($sel['name']) : '???' ?></b>
          <span class="p2tags"><span class="tag">🫙 preserve</span> <span class="tag"><?= e(P2_KINDS[$sk][0]) ?></span></span>
          <?php if ($sel['known']): ?><small class="p2sub">Makes <?= (int)$sel['output_qty'] ?> jars · <?= e(buff_text($sel['effects'], $u, true)) ?></small><?php endif; ?></span>
        <span class="p2grab" aria-hidden="true"></span>
      </summary>
      <?php if ($sel['known']): ?><p class="p2fit"><?= $when($sel) ?></p><?php endif; ?>
      <p class="ccingh p2ingh">Ingredients</p>
      <?= $ingGrid($sel) ?>
    </details>
    <div class="p2acts"><?= $make($sel) ?></div>
  </section>
  <?php endif; ?>
</div>
<?php endif; ?>
</div>
<?php page_footer();
