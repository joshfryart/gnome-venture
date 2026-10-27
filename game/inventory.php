<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
$u = require_login();

require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/crafting.php';
require_once __DIR__ . '/includes/tools.php';
if (is_post()) {
    csrf_check();
    if (($_POST['do'] ?? '') === 'read') {
        [$ok, $msg] = read_guide($u, (int)($_POST['item_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif (($_POST['do'] ?? '') === 'eat') {
        refresh_energy($u);
        [$ok, $msgs] = eat_item($u, (int)($_POST['item_id'] ?? 0));
        if ($msgs) flash(implode(' ', $msgs), $ok ? 'ok' : 'err');   // one message box for the whole meal
    } elseif (($_POST['do'] ?? '') === 'open_packet') {   // v0.9.9: open a seed packet
        require_once __DIR__ . '/includes/flowers.php';
        [$ok, $msg] = packet_open($u, (int)($_POST['item_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif (($_POST['do'] ?? '') === 'mend') {   // v0.7.86: mend a worn tool or a Broken copy
        [$ok, $msg] = mend_tool((int)$u['id'], (int)($_POST['item_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    }
    if (($_POST['tab'] ?? '') === 'belt') redirect('inventory.php?tab=belt' . (preg_match('/^[a-z]{3,8}$/', (string)($_POST['b'] ?? '')) ? '&b=' . $_POST['b'] : ''));   // v0.7.88: a mend from the Toolbelt tab stays there. v0.9.1a: and on its sub-tab
    // v0.7.59: stay where you were (same tab, same item open)
    $back = preg_match('/^[a-z]{2,10}$/', (string)($_POST['cat'] ?? '')) ? (string)$_POST['cat'] : 'all';
    $iid = (int)($_POST['item_id'] ?? 0);
    $srt = preg_match('/^[a-z]{2,6}$/', (string)($_POST['sort'] ?? '')) ? '&sort=' . $_POST['sort'] : '';
    redirect('inventory.php?cat=' . $back . $srt . ($iid ? '&open=' . $iid . '#i' . $iid : ''));
}

$tabNow = (string)($_GET['tab'] ?? '');
$view = in_array($tabNow, ['craft', 'belt'], true) ? $tabNow : 'bag';   // v0.7.61: Satchel and Crafting share one page; v0.7.88: and the Toolbelt
$items = q('SELECT i.id, i.slug, i.name, i.category, i.description, i.edible, i.effects, i.rarity, i.base_price, ui.qty, ui.wear, ui.id AS uiid, ui.got_at,
            (SELECT 1 FROM user_tasted t WHERE t.user_id = ui.user_id AND t.item_id = i.id) AS tasted
            FROM user_items ui JOIN items i ON i.id = ui.item_id
            WHERE ui.user_id = ? ORDER BY i.category, i.name', [$u['id']])->fetchAll();
// v0.7.45: raw grains, beans and roots can't be eaten as they are; say what to cook them into
$cookInto = [];
foreach (q("SELECT r.ingredients, i.name FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.category = 'cooking' ORDER BY i.name")->fetchAll() as $r) {
    foreach (array_keys(json_decode((string)$r['ingredients'], true) ?: []) as $slug) $cookInto[$slug][] = $r['name'];
}
$hasKitchen = (bool)q_val("SELECT 1 FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE p.user_id = ? AND gb.building = 'kitchen'", [$u['id']]);   // v0.7.48
page_header(['craft' => 'Crafting', 'belt' => 'Toolbelt'][$view] ?? 'Satchel');
?>
<h1>👜 Your Satchel</h1>
<nav class="tabs bagtabs tabs4">   <?php // v1.6.3: four equal columns, one row (icon over a short word) ?>
  <a class="<?= $view === 'bag' ? 'on' : '' ?>" href="<?= e(url('inventory.php')) ?>"><span aria-hidden="true">👜</span> Satchel</a>
  <a class="<?= $view === 'craft' ? 'on' : '' ?>" href="<?= e(url('inventory.php?tab=craft')) ?>"><span aria-hidden="true">🔨</span> Crafting</a>
  <a class="<?= $view === 'belt' ? 'on' : '' ?>" href="<?= e(url('inventory.php?tab=belt')) ?>"><span aria-hidden="true">🧰</span> Belt</a>
  <a href="<?= e(url('arrange.php')) ?>"><span aria-hidden="true">💐</span> Arrange</a>
</nav>
<?php if ($view === 'craft') {
    refresh_energy($u);   // v0.7.88: the ×N buttons count the energy the gnome has now
    require_once __DIR__ . '/includes/craft_view.php';
    craft_view($u, (string)($_GET['c'] ?? 'cooking'));
    page_footer();
    exit;
}
if ($view === 'belt') {   // v0.7.88: the toolbelt, by job. Its mend forms post back here (tab=belt).
    $uid = (int)$u['id'];
    // v0.9.1a: sub-tabs (?b=): garden tools, gathering, travel, mend, upgrades
    $beltTabs = ['garden' => '🌱 Garden tools', 'gather' => '🧺 Gathering', 'travel' => '🥾 Travel', 'mend' => '🔧 Mend', 'upgrade' => '⬆️ Upgrades'];
    $bNow = (string)($_GET['b'] ?? 'garden');
    if (!isset($beltTabs[$bNow])) $bNow = 'garden';
    $hidBelt = '<input type="hidden" name="tab" value="belt"><input type="hidden" name="b" value="' . e($bNow) . '">';
    $garden = array_diff_key(TOOL_TYPES, array_flip(GATHER_TOOLS));
    $travelKeys = ['staff', 'lantern'];
    $adventure = array_diff_key(array_intersect_key(TOOL_TYPES, array_flip(GATHER_TOOLS)), array_flip($travelKeys));   // gathering tools
    $travel = array_intersect_key(TOOL_TYPES, array_flip($travelKeys));
    $brokenOwned = q("SELECT i.* FROM user_items ui JOIN items i ON i.id = ui.item_id
                      WHERE ui.user_id = ? AND i.category = 'broken' AND ui.qty > 0 ORDER BY i.name", [$uid])->fetchAll();
    $jobRow = function (string $type, array $t, bool $upgrade = false) use ($uid): string {
        [$label, $icon, $what, $byHand] = $t;
        $tier = tool_tier($uid, $type);
        $best = best_tool($uid, $type);
        $brokenCopy = $best ? null : tool_broken_owned($uid, $type);
        $next = null;
        foreach (TOOL_ITEMS as $ti) if ($ti[0] === $type && $ti[1] === $tier + 1) $next = $ti;
        ob_start(); ?>
        <tr>
          <td data-l="Job"><?= $icon ?> <b><?= e($label) ?></b></td>
          <td data-l="Using"><?php if ($best): ?><b><?= e($best['name']) ?></b> <span class="ptier t<?= $tier ?>"><?= e(TOOL_TIERS[$tier] ?? '') ?></span>
            <?php elseif ($byHand): ?><span class="muted">By hand</span>
            <?php else: ?><span class="bad">None yet</span><?php endif; ?></td>
          <?php if (!$upgrade): ?>
          <td class="help" data-l="What it does"><?= e($tier ? tool_tier_text($type, $tier) : ($byHand ? 'One square at a time.' : $what)) ?></td>
          <td class="help" data-l="Wear"><?php if ($best): ?><?= e(tool_left_text($uid, $type) ?: 'Never wears out') ?>
            <?php elseif ($brokenCopy): ?><span class="bad">💥 Broken: mend it on the Mend tab</span>
            <?php else: ?>—<?php endif; ?></td>
          <?php else: ?>
          <td class="help" data-l="Next upgrade"><?php if ($next): ?><?= e($next[2]) ?> · <?= $next[1] >= 4 ? 'rare stock, or craft at a Tool Shed' : money($next[3]) . ' at Twigg’s' ?><?php elseif (in_array($type, ['broadfork', 'soiltest'], true) && !$tier): ?>Sold at Twigg’s<?php else: ?>Nothing better to make: you have the best.<?php endif; ?></td>
          <?php endif; ?>
        </tr>
        <?php return (string)ob_get_clean();
    };
    ?>
<details class="helpfold"><summary>ℹ️ How tools work</summary><p class="help">Your best tool of each kind is used automatically. No need to equip anything. Tools wear out with use: gathering tools, the walking staff and the lantern by uses, garden tools by days of use. A broken tool is mended here or in your Satchel (a Tool Shed mends one free each day). Sturdy, Fine and Masterwork tools also give a 20%, 30% or 50% chance that a garden action costs no energy.</p></details>
<div class="toolbelt">
  <div class="belt">
    <span class="buckle" aria-hidden="true"></span>
    <?php foreach (TOOL_TYPES as $type => [$label, $icon, $what, $byHand]):
        $tier = tool_tier($uid, $type);
        $best = best_tool($uid, $type);
        $broken = $best ? null : tool_broken_owned($uid, $type); ?>
      <div class="pouch<?= $best ? '' : ' empty' ?>" title="<?= e($label . ': ' . ($tier ? tool_tier_text($type, $tier) : ($byHand ? 'By hand, one square at a time.' : $what))) ?>">
        <span class="picon"><?= $icon ?></span>
        <span class="pname"><?= $best ? e($best['name']) : ($broken ? '💥 ' . e($broken['name']) : ($byHand ? 'By hand' : '—')) ?></span>
        <?php if ($tier): ?><span class="ptier t<?= $tier ?>"><?= e(TOOL_TIERS[$tier] ?? '') ?></span><?php endif; ?>
        <?php if ($left = tool_left_text($uid, $type)): ?><span class="pwear"><?= e($left) ?></span><?php endif; ?>
      </div>
    <?php endforeach; ?>
  </div>
  <nav class="tabs belttabs">
    <?php foreach ($beltTabs as $k => $label): ?><a class="<?= $k === $bNow ? 'on' : '' ?>" href="<?= e(url('inventory.php?tab=belt&b=' . $k)) ?>"><?= $label ?></a><?php endforeach; ?>
  </nav>
  <?php if ($bNow === 'garden' || $bNow === 'gather' || $bNow === 'travel'):
      $list = ['garden' => $garden, 'gather' => $adventure, 'travel' => $travel][$bNow]; ?>
  <h2><?= $bNow === 'garden' ? '🌱 Garden jobs' : ($bNow === 'gather' ? '🧺 Gathering gear' : '🥾 Travel gear') ?></h2>
  <div class="scroll"><table class="grid">
    <tr><th>Job</th><th>Using</th><th>What it does</th><th>Wear</th></tr>
    <?php foreach ($list as $type => $t) echo $jobRow($type, $t); ?>
  </table></div>
  <?php elseif ($bNow === 'upgrade'): ?>
  <h2>⬆️ What to make next</h2>
  <div class="scroll"><table class="grid">
    <tr><th>Job</th><th>Using</th><th>Next upgrade</th></tr>
    <?php foreach (TOOL_TYPES as $type => $t) echo $jobRow($type, $t, true); ?>
  </table></div>
  <?php else:   // mend
      $worn = [];
      foreach (TOOL_TYPES as $type => $t) {
          $best = best_tool($uid, $type);
          if ($best && (int)q_val('SELECT wear FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$best['id']]) > 0) $worn[$type] = $t;
      } ?>
  <h2>🔧 Worn tools</h2>
  <?php if (!$worn): ?><p class="muted">None. Nothing you carry has been used yet.</p>
  <?php else: ?><div class="scroll"><table class="grid">
    <tr><th>Job</th><th>Using</th><th>Wear</th></tr>
    <?php foreach ($worn as $type => [$label, $icon]): $best = best_tool($uid, $type); ?>
      <tr><td data-l="Job"><?= $icon ?> <b><?= e($label) ?></b></td><td data-l="Using"><b><?= e($best['name']) ?></b></td><td data-l="Wear"><?= tool_belt_wear_html($uid, $type, $hidBelt) ?></td></tr>
    <?php endforeach; ?>
  </table></div><?php endif; ?>
  <h2>💥 Broken tools</h2>
  <?php if (!$brokenOwned): ?><p class="muted">None. Everything you carry is in working order.</p>
  <?php else: foreach ($brokenOwned as $b): ?>
    <div class="box"><b><?= e($b['name']) ?></b><?= tool_wear_html($uid, $b, 0, $hidBelt) ?></div>
  <?php endforeach; endif; ?>
  <?php endif; ?>
</div>
<?php page_footer();
    exit;
}
$uid = (int)$u['id'];
$cats = ['all' => 'All', 'seed' => '🌱 Seeds', 'produce' => '🥕 Crops', 'flower' => '🌸 Flowers', 'food' => '🍲 Food', 'soil' => '🪱 Soil', 'mulch' => '🍂 Mulch', 'forage' => '🍄 Finds', 'tool' => '🧰 Tools', 'decor' => '🏡 Decor', 'arrangement' => '💐 Arrangements', 'other' => '📦 Other'];   // v0.9.9: arrangements
$main = ['seed', 'produce', 'flower', 'food', 'soil', 'mulch', 'forage', 'tool', 'decor', 'arrangement'];
$cat = (string)($_GET['cat'] ?? 'all');
if (!isset($cats[$cat]) && $cat !== 'untasted') $cat = 'all';   // v1.6.3: 'untasted' is added to $cats below
$counts = ['all' => count($items)];
// v0.7.86: Broken tools sit on the Tools tab
$tabOf = fn(array $i): string => $i['category'] === 'broken' ? 'tool' : ($i['category'] === 'packet' ? 'seed' : (in_array($i['category'], $main, true) ? $i['category'] : 'other'));
foreach ($items as $i) { $k = $tabOf($i); $counts[$k] = ($counts[$k] ?? 0) + 1; }
// v1.6.3: "Untasted": edible things never eaten yet (each first taste can give a small bonus; some raise a stat for good)
$untasted = fn(array $i): bool => (int)$i['edible'] === 1 && !$i['tasted'];
$permFirst = fn(array $i): bool => $untasted($i) && !empty((json_decode((string)$i['effects'], true) ?: [])['perm']);
$counts['untasted'] = count(array_filter($items, $untasted));
$cats = ['all' => $cats['all'], 'untasted' => '✨ Untasted'] + $cats;
$shown = array_values(array_filter($items, fn($i) => $cat === 'untasted' ? $untasted($i) : ($cat === 'all' || $tabOf($i) === $cat)));
$iconFor = fn(array $i): string => item_icon($i);   // v0.7.61: shared with the shops
require_once __DIR__ . '/includes/catalog.php';
$IL = item_lookups();
// v0.7.61: sort every tab
$sorts = ['new' => '🕒 Newest first', 'old' => '🕰️ Oldest first', 'az' => '🔤 Name A–Z', 'za' => '🔤 Name Z–A', 'most' => '📦 Most owned', 'least' => '📦 Fewest owned', 'rare' => '💎 Rarest first', 'type' => '🗂️ By type'];
$sort = (string)($_GET['sort'] ?? 'type');
if (!isset($sorts[$sort])) $sort = 'type';
$rankOf = ['L' => 4, 'R' => 3, 'U' => 2, 'C' => 1];
$got = fn(array $i) => [(string)($i['got_at'] ?? ''), (int)$i['uiid']];
usort($shown, match ($sort) {
    'new' => fn($a, $b) => $got($b) <=> $got($a),
    'old' => fn($a, $b) => $got($a) <=> $got($b),
    'az' => fn($a, $b) => strcasecmp($a['name'], $b['name']),
    'za' => fn($a, $b) => strcasecmp($b['name'], $a['name']),
    'most' => fn($a, $b) => [(int)$b['qty'], $a['name']] <=> [(int)$a['qty'], $b['name']],
    'least' => fn($a, $b) => [(int)$a['qty'], $a['name']] <=> [(int)$b['qty'], $b['name']],
    'rare' => fn($a, $b) => [$rankOf[item_rarity($b, $IL)[0]] ?? 0, $a['name']] <=> [$rankOf[item_rarity($a, $IL)[0]] ?? 0, $b['name']],
    default => fn($a, $b) => [$a['category'], $a['name']] <=> [$b['category'], $b['name']],
});
if ($cat === 'untasted') usort($shown, fn($a, $b) => [$permFirst($b), 0] <=> [$permFirst($a), 0]);   // v1.6.3: rare first-taste (stat) items first; usort is stable, so the chosen sort holds inside each group
$qs = fn(string $c, string $s) => 'inventory.php?cat=' . $c . ($s !== 'type' ? '&sort=' . $s : '');
$hid = '<input type="hidden" name="cat" value="' . e($cat) . '"><input type="hidden" name="sort" value="' . e($sort) . '">';   // v0.7.86: mend forms stay on this tab ?>
<?php // v1.6.3: category and sort are two dropdowns in one row (a GET form; site.js sends it when a choice changes) ?>
<form method="get" action="<?= e(url('inventory.php')) ?>" class="pickform">
  <label>Show <select name="cat" data-autosubmit>
    <?php foreach ($cats as $k => $label): if ($k !== 'all' && empty($counts[$k]) && $k !== $cat) continue; ?><option value="<?= e($k) ?>"<?= $k === $cat ? ' selected' : '' ?>><?= e($label) ?> (<?= (int)($counts[$k] ?? 0) ?>)</option><?php endforeach; ?>
  </select></label>
  <label>Sort <select name="sort" data-autosubmit>
    <?php foreach ($sorts as $k => $label): ?><option value="<?= e($k) ?>"<?= $k === $sort ? ' selected' : '' ?>><?= e($label) ?></option><?php endforeach; ?>
  </select></label>
  <button class="btn small pickgo">Go</button>
</form>
<?php if (!$items): ?><p class="muted">Empty. Time to visit the market!</p><?php endif; ?>
<?php   // v2.0.67: item squares (includes/item_square.php, mockup 4); one grid per type when sorted by type
require_once __DIR__ . '/includes/item_square.php';
$inUse = [];   // the tool of each job the gnome uses now
foreach (array_keys(TOOL_TYPES) as $tt) if ($bt = best_tool($uid, $tt)) $inUse[(int)$bt['id']] = true;
$newSince = gmdate('Y-m-d H:i:s', time() - 3600);   // "New": got in the last hour
$openId = (int)($_GET['open'] ?? 0);
$groups = $sort === 'type' && $cat !== 'untasted' ? [] : ['' => $shown];
if (!$groups) { foreach ($shown as $i) $groups[$tabOf($i)][] = $i; $groups = array_merge(array_intersect_key(array_flip(array_keys($cats)), $groups), $groups); }   // in the Show list's order
foreach ($groups as $gk => $list):
    if ($gk !== ''): ?><h3 class="itm-h"><?= e($cats[$gk] ?? $gk) ?> <span class="itm-h__sub"><?= count($list) ?> kind<?= count($list) === 1 ? '' : 's' ?></span></h3><?php endif; ?>
<div class="itmwrap"><div class="itms">
  <?php foreach ($list as $i):
      [$rl, $rw] = item_rarity($i, $IL);
      $isTool = $i['category'] === 'tool' && !empty((json_decode((string)$i['effects'], true) ?: [])['tool']);
      $broken = $i['category'] === 'broken';
      $st = []; $chips = [];
      if ($isTool && isset($inUse[(int)$i['id']])) { $st[] = 'use'; $chips[] = ['use', 'In use']; }
      elseif ($isTool) $chips[] = ['note', 'Spare'];
      if ($broken) { $st[] = 'off'; $chips[] = ['note', 'Mend it']; }
      $flag = $permFirst($i) ? 'Rare taste!' : ((string)($i['got_at'] ?? '') >= $newSince ? 'New' : ''); ?>
    <details class="itile itmcell" id="i<?= (int)$i['id'] ?>"<?= $openId === (int)$i['id'] ? ' open' : '' ?>>
      <?= item_square(['item' => $i, 'rarity' => $rl, 'tag' => 'summary', 'count' => (int)$i['qty'], 'states' => $st, 'chips' => $chips,
          'flag' => $flag, 'flagClass' => $permFirst($i) ? 'taste' : '', 'vh' => $permFirst($i) ? '<span class="vh">: eating it raises a stat for good</span>' : '']) ?>
      <div class="ipop">
        <button type="button" class="ipclose" aria-label="Close">✕</button>
        <b><?= e($i['name']) ?></b> <span class="cat"><?= e($cats[$i['category']] ?? ucfirst((string)$i['category'])) ?></span> <span class="rarword r<?= $rl ?>"><?= e($rw) ?></span>
        <p><?= desc_html((string)$i['description']) ?></p>
        <?php if ($i['category'] === 'seed' && ($sp = $IL['seed'][(int)$i['id']] ?? null) && plant_unstudied($u, $sp)): ?><p class="help unstudied">📕 Unstudied: you can plant it, but it grows <?= unstudied_slow_pct($u) ?>% slower and gives <?= 100 - unstudied_yield_pct($u) ?>% less until you study <?= e(plant_home_name((int)$sp['id']) ?: 'its region') ?> or master it.</p><?php endif; ?>
        <?php if ($facts = item_facts($i, $IL)): ?><ul class="ifacts"><?php foreach ($facts as $fl): ?><li><?= $fl ?></li><?php endforeach; ?></ul><?php endif; ?>
        <?= tool_wear_html($uid, $i, (int)$i['wear'], $hid) ?>
        <?php if ((int)$i['edible']):
            $fx = json_decode((string)$i['effects'], true) ?: [];
            $permNew = !empty($fx['perm']) && !$i['tasted']; ?>
          <p class="help"><?= $i['tasted'] ? '🍴 Tasted' : '✨ Never tasted' ?><?= $permNew ? ' — rare! Eating it raises a stat permanently.' : '' ?></p>
          <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="eat"><input type="hidden" name="cat" value="<?= e($cat) ?>"><input type="hidden" name="sort" value="<?= e($sort) ?>"><input type="hidden" name="item_id" value="<?= (int)$i['id'] ?>">
            <button class="btn small"><?= !empty($fx['tea']) ? '☕ Drink' : '😋 Eat' ?></button></form>
        <?php elseif (in_array($i['category'], ['produce', 'forage', 'flower'], true)):
            $dishes = array_unique($cookInto[$i['slug']] ?? []); ?>
          <p class="help">🍳 Can’t be eaten as it is<?= $i['category'] === 'flower' ? '' : ': it needs cooking first' ?>.<?= $dishes ? ' Cook it into ' . e(implode(', ', array_slice($dishes, 0, 4))) . (count($dishes) > 4 ? ' and more' : '') . '.' : '' ?></p>
          <?php if ($dishes && !$hasKitchen): ?><p class="help">🔒 Cooking needs a <b>Kitchen</b> in your garden: build one on the garden page once your garden reaches level 2 (every harvest helps).</p>
          <?php elseif ($dishes): ?><a class="btn small alt" href="<?= e(url('inventory.php?tab=craft&c=cooking')) ?>">🍳 Cook in Crafting</a><?php endif; ?>
        <?php endif; ?>
        <?php if ($i['category'] === 'arrangement' && ($arrComp = arrangement_of($i))): ?>
          <div class="arrbig"><?= arrangement_svg($arrComp, 'full', $i['name']) ?></div>
          <a class="btn small alt" href="<?= e(url('arrange.php?t=show')) ?>">🎗️ Enter the weekly show</a>
        <?php elseif ($i['category'] === 'packet'): ?>
          <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="open_packet"><input type="hidden" name="cat" value="<?= e($cat) ?>"><input type="hidden" name="sort" value="<?= e($sort) ?>"><input type="hidden" name="item_id" value="<?= (int)$i['id'] ?>">
            <button class="btn small">📦 Open the packet</button></form>
        <?php endif; ?>
        <?php if ($i['category'] === 'decor'): ?><a class="btn small" href="<?= e(url('yard.php')) ?>">✏️ Place it in your yard</a><?php endif; ?>
        <?php if ($i['category'] === 'guide'): ?>
          <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="read"><input type="hidden" name="cat" value="<?= e($cat) ?>"><input type="hidden" name="sort" value="<?= e($sort) ?>"><input type="hidden" name="item_id" value="<?= (int)$i['id'] ?>">
            <button class="btn small">📗 Read guide</button></form>
        <?php endif; ?>
      </div>
    </details>
  <?php endforeach; ?>
</div></div>
<?php endforeach; ?>

<p class="help"><a href="<?= e(url('inventory.php?tab=belt')) ?>">🧰 Your toolbelt →</a></p>
<?php page_footer();
