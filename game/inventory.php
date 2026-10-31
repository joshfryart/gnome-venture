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
    } elseif (($_POST['do'] ?? '') === 'drink_heal') {   // Alchemy: a healing tier, from the Satchel
        require_once __DIR__ . '/includes/health.php';
        require_once __DIR__ . '/includes/adventure.php';   // hp_use reads active_expedition()
        [$ok, $msg] = hp_use($u, 'potion', (int)($_POST['item_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
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
    $quick = !empty($_POST['quick']);   // the Satchel's quick bar: stay at the top, nothing opened
    redirect('inventory.php?cat=' . $back . $srt . ($iid && !$quick ? '&open=' . $iid . '#i' . $iid : ''));
}

$tabNow = (string)($_GET['tab'] ?? '');
$view = in_array($tabNow, ['craft', 'belt'], true) ? $tabNow : 'bag';   // v0.7.61: Satchel and Crafting share one page; v0.7.88: and the Toolbelt
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
    craft_view($u, (string)($_GET['c'] ?? ''));
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
require_once __DIR__ . '/includes/satchel_view.php';   // Shelves (mockup design 3): quick bar, foldable type shelves of pills, the pick opens inline
satchel_view($u);
page_footer();
