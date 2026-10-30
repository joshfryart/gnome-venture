<?php
declare(strict_types=1);
/** v0.7.61: the Crafting tab of the Satchel page (was crafting.php). Expects $u. */
require_once __DIR__ . '/crafting.php';
require_once __DIR__ . '/almanac.php';

function craft_view(array $u, string $tab): void
{
$uid = (int)$u['id'];
if (!isset(CRAFT_CATEGORIES[$tab])) $tab = 'cooking';
if ($tab === 'pantry') {   // The Pantry has its own master-detail view
    require_once __DIR__ . '/pantry_view.php';
    pantry_view($u);
    return;
}
$stations = craft_stations($uid);
$isPantry = $tab === 'pantry';   // v0.9.8: preserves in Pantry jars (a Kitchen add-on)
$kitchenOk = $stations[$tab] !== 0;
$jarLimit = $isPantry ? pantry_jar_limit($uid) : 0;
if ($isPantry && $jarLimit < 1) $stations['pantry'] = 0;   // no Pantry yet: recipes show, nothing can be made
if ($tab === 'cooking' && !q_val("SELECT 1 FROM recipes WHERE slug LIKE 'feast-%'")) ensure_crafts();   // v0.7.96: feasts arrive even if the site was already on 0.7.96
$recipes = craft_recipes($uid, $tab);
$counts = [];
foreach (q('SELECT r.category, COUNT(*) AS total, COUNT(ur.id) AS have FROM recipes r
            LEFT JOIN user_recipes ur ON ur.recipe_id = r.id AND ur.user_id = ? GROUP BY r.category', [$uid])->fetchAll() as $c) {
    $counts[$c['category']] = $c;
}
[$label, $icon, $building, $blurb] = CRAFT_CATEGORIES[$tab];
usort($recipes, fn($a, $b) => [$b['known'], $b['known'] && $b['can']] <=> [$a['known'], $a['known'] && $a['can']] ?: strcmp($a['name'], $b['name']));
?>
<details class="helpfold"><summary>❓ How crafting works</summary><p class="help">One workbench for everything you make. A recipe appears once you’ve collected every ingredient:
  grown it, gathered it on an adventure, or carried it in your satchel. Once found, it stays found.</p></details>
<?php // v1.6.3: category and Ready/Missing/To discover are two dropdowns in one row; $show is worked out below, so the form is printed there ?>
<p class="help"><?= e($blurb) ?></p>
<?php if ($isPantry && $kitchenOk && $jarLimit < 1): [$pc, $pm] = pantry_cost(); ?>
  <div class="box notice">You need a <b>🫙 Pantry</b> to make these: an add-on for your Kitchen (<?= money($pc) ?><?= $pm ? ' + ' . e(upgrade_mats_text($pm)) : '' ?>).
    Add one in <a href="<?= e(url('garden.php?bld=kitchen#b-kitchen')) ?>">🏠 Garden buildings → Kitchen</a>. You can still discover recipes in the meantime.</div>
<?php elseif ($stations[$tab] === 0): $b = BUILDINGS[$building]; ?>
  <div class="box notice">You need a <b><?= e($b[1] . ' ' . $b[0]) ?></b> in one of your gardens to make these.
    A garden at <b>level <?= (int)$b[2] ?></b> can build one for <?= money((int)$b[3]) ?> from
    <a href="<?= e(url('garden.php')) ?>">the garden page</a>. Every harvest raises your garden level.
    You can still discover recipes in the meantime.</div>
<?php endif; ?>
<?php
// v0.7.47: what you can make now first; the rest folded so the page stays short on a phone
$ready = array_values(array_filter($recipes, fn($r) => $r['known'] && $r['can']));
$missing = array_values(array_filter($recipes, fn($r) => $r['known'] && !$r['can']));
$unknown = array_values(array_filter($recipes, fn($r) => !$r['known']));
$now = (int)($u['energy'] ?? 0);   // v0.7.88: energy left (refreshed by inventory.php)
require_once __DIR__ . '/gardens.php';
$kitchen3 = user_building_bonus($uid, 'kitchen')['feasts'];   // v0.7.96: feasts
// v0.8.5: Design A: recipe cards, two to a row, with ingredient chips and the make buttons on the card. Filter chips pick the list.
require_once __DIR__ . '/items.php';
require_once __DIR__ . '/item_square.php';   // v2.0.67: the ingredients are item squares (mockup 4)
$slugs = [];
foreach ($recipes as $r) foreach ($r['ings'] as $i) $slugs[$i['slug']] = true;
$icons = [];   // slug => items row
if ($slugs) {
    $ph = implode(',', array_fill(0, count($slugs), '?'));
    foreach (q("SELECT * FROM items WHERE slug IN ($ph)", array_keys($slugs))->fetchAll() as $it) $icons[$it['slug']] = $it;
}
$outIcons = [];
foreach (q('SELECT i.* FROM items i JOIN recipes r ON r.output_item_id = i.id WHERE r.category = ?', [$tab])->fetchAll() as $it) $outIcons[(int)$it['id']] = item_icon($it);
$show = (string)($_GET['show'] ?? '');
if (!in_array($show, ['ready', 'missing', 'unknown'], true)) $show = $ready ? 'ready' : ($missing ? 'missing' : 'unknown');
$list = ['ready' => $ready, 'missing' => $missing, 'unknown' => $unknown][$show];
$potsOn = $tab === 'cooking' && cook_pots_on();   // v0.9.4: pots with timers (kitchen_pots 0 = instant)
$potsList = $potsOn && $stations['cooking'] !== 0 ? cook_pots_list($uid) : [];
$potLimit = $potsOn ? cook_pot_limit($u) : 0;
$potsFree = max(0, $potLimit - cook_pots_busy($uid));
$jarsList = $isPantry && $stations['pantry'] !== 0 ? pantry_jars_list($uid) : [];   // v0.9.8
$jarsFree = max(0, $jarLimit - count($jarsList));
$coins = (int)($u['coins'] ?? 0);
$card = function (array $r) use ($u, $tab, $stations, $now, $kitchen3, $icons, $outIcons, $potsOn, $potsFree, $coins, $isPantry, $jarsFree): string {   // v0.9.4: pots; v0.9.8: jars
    $feast = str_starts_with((string)($r['slug'] ?? ''), 'feast-');
    $tier = $tab === 'cooking' ? (string)($r['tier'] ?: 'meal') : ($isPantry ? 'preserve' : '');
    $known = $r['known'];
    $cls = !$known ? 'unk' : ($r['can'] ? 'ready' : 'miss');
    ob_start(); ?>
    <div class="ccard <?= $cls ?>">
      <div class="cctop"><span class="ccdish"><?= $known ? ($outIcons[(int)$r['output_item_id']] ?? '🍲') : '❔' ?></span>
        <div><div class="ccname"><?= $known ? e($r['name']) : '???' ?><?= $known && $tier ? ' <span class="tag">' . ['snack' => '🥨 snack', 'meal' => '🍲 meal', 'feast' => '🍳 feast', 'preserve' => '🫙 preserve'][$tier] . '</span>' : '' ?><?= !empty($r['new']) ? ' <span class="tag">new!</span>' : '' ?></div>
          <?php if ($known): ?><div class="ccsub"><?= $isPantry ? e('Makes ' . (int)$r['output_qty'] . ' jars · ' . buff_text($r['effects'], $u, true)) : ($tab === 'cooking' ? e(buff_text($r['effects'], $u, true)) : 'Makes ' . (int)$r['output_qty'] . ' × ' . e($r['out_name'])) ?></div><?php endif; ?></div></div>
      <p class="ccingh">Ingredients</p>
      <?php $sq = '';   // v2.0.67: one item square per ingredient: the corner count is what you have, the chip says uses N / short N
        foreach ($r['ings'] as $i) {
            $it = $icons[$i['slug']] ?? ['name' => $i['name']];
            $have = (int)$i['have']; $need = (int)$i['qty'];
            if ($known) {
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
        echo item_grid($sq, 'itms--flush ccings'); ?>
      <?php if (!$known): ?><small class="muted">Collect everything above to discover it.</small>
      <?php elseif ($feast && !$kitchen3): ?><small class="muted">🔒 Needs a level 3 Kitchen.</small>
      <?php elseif (!$r['can']): ?><small class="ccneed">Need <?= e(implode(', ', array_map(fn($i) => ($i['qty'] - $i['have']) . ' ' . $i['name'], array_filter($r['ings'], fn($i) => $i['have'] < $i['qty'])))) ?></small>
      <?php elseif ($stations[$tab] !== 0):
          $cost = craft_energy_cost($u, $tab, (int)$r['energy'], $tier);
          $fit = craft_fit($r['ings'], $cost, $now);
          $fee = $tier === 'feast' ? max(0, (int)setting('feast_petal_fee')) : 0;
          if ($fee > 0) $fit = min($fit, intdiv($coins, $fee));
          $chunk = max(1, (int)$r['batch_max']);
          if ($potsOn) $fit = min($fit, $potsFree * $chunk);
          if ($isPantry) $fit = min($fit, $jarsFree);   // v0.9.8: one jar per batch
          $secs = $isPantry ? pantry_seconds($r) : ($tier ? cook_seconds($u, $r) : 0); ?>
        <?php if ($fit >= 1): ?>
        <form method="post" action="<?= e(url('crafting.php?c=' . $tab)) ?>" class="ccbtns"><?= csrf_field() ?><input type="hidden" name="recipe_id" value="<?= (int)$r['id'] ?>">
          <?php if ($potsOn && $chunk > 1): ?>
            <?php for ($n = 1; $n <= min($fit, $chunk); $n++): ?><button class="btn small<?= $n > 1 ? ' alt' : '' ?>" name="qty" value="<?= $n ?>">×<?= $n ?></button><?php endfor; ?>
          <?php else: ?>
          <button class="btn small" name="qty" value="1">×1<?php if ($cost > 0): ?> <span class="cbcost">⚡<?= (int)$cost ?> each</span><?php endif; ?></button>
          <?php if ($fit >= 5): ?><button class="btn small" name="qty" value="5">×5</button><?php elseif ($fit >= 2): ?><button class="btn small" name="qty" value="2">×2</button><?php endif; ?>
          <?php if ($fit >= 3): ?><button class="btn small alt" name="qty" value="all">All <?= $fit ?></button><?php endif; ?>
          <?php endif; ?>
        </form>
        <?php elseif ($isPantry && $jarsFree < 1): ?><small class="ccneed">All jars are full.</small>
        <?php elseif ($potsOn && $potsFree < 1): ?><small class="ccneed">All pots are busy.</small>
        <?php elseif ($fee > 0 && $coins < $fee): ?><small class="ccneed">Needs <?= e(money($fee)) ?> for firewood and spices.</small>
        <?php elseif ($cost > 0 && $now < $cost): ?><small class="ccneed">Too tired: this takes ⚡<?= $cost ?>, you have ⚡<?= $now ?>.</small>
        <?php endif; ?>
        <?php if ($tier): ?><small class="muted"><?= $cost ? '⚡' . $cost . ' each · ' : '' ?><?= $fee ? e(money($fee)) . ' each · ' : '' ?>⏱ <?= $isPantry ? e(pantry_time_text($secs)) : ($secs > 0 ? e(cook_time_text($secs)) : 'instant') ?><?= $potsOn && $chunk > 1 ? ' · up to ' . $chunk . ' in one pot' : '' ?></small>
        <?php elseif ($cost && $fit < 1): ?><small class="muted">⚡<?= $cost ?> each</small><?php endif; ?>
      <?php endif; ?>
    </div>
    <?php return (string)ob_get_clean();
};
$chip = fn(string $k, string $label, int $n) => '<a class="' . ($show === $k ? 'on' : '') . '" href="' . e(url('inventory.php?tab=craft&c=' . $tab . '&show=' . $k)) . '">' . $label . ' (' . $n . ')</a>'; ?>
<?php if ($potsOn && $stations['cooking'] !== 0): $readyN = count(array_filter($potsList, fn($p) => $p['left'] <= 0)); ?>
<section class="potstrip" aria-label="Pots">
  <h3>🍳 Pots <small><?= count($potsList) ?>/<?= $potLimit ?> in use</small></h3>
  <div class="potrow">
    <?php foreach ($potsList as $p): ?>
      <div class="pot <?= $p['left'] <= 0 ? 'done' : 'busy' ?>">
        <span class="potdish"><?= $outIcons[(int)$p['item_id']] ?? '🍲' ?></span>
        <span class="potname"><?= e($p['name']) ?><?= (int)$p['makes'] > 1 ? ' ×' . (int)$p['makes'] : '' ?></span>
        <span class="potleft" data-potleft="<?= (int)$p['left'] ?>"><?= $p['left'] > 0 ? e(energy_clock((int)$p['left'])) : 'Ready!' ?></span>
        <form method="post" action="<?= e(url('crafting.php?c=cooking')) ?>" class="potcollect"<?= $p['left'] > 0 ? ' hidden' : '' ?>><?= csrf_field() ?>
          <input type="hidden" name="do" value="collect"><input type="hidden" name="pot_id" value="<?= (int)$p['id'] ?>"><button class="btn small">Collect</button></form>
      </div>
    <?php endforeach; ?>
    <?php for ($n = count($potsList); $n < $potLimit; $n++): ?><div class="pot empty"><span class="potdish">🫕</span><span class="potname">Empty pot</span></div><?php endfor; ?>
  </div>
  <form method="post" action="<?= e(url('crafting.php?c=cooking')) ?>" data-potall<?= $readyN >= 2 ? '' : ' hidden' ?>><?= csrf_field() ?><input type="hidden" name="do" value="collect_all"><button class="btn small alt">Collect all</button></form>
  <small class="muted">Dishes wait in the pot until you collect them. Snacks cook in minutes, meals take longer, feasts longest.</small>
</section>
<?php endif; ?>
<?php if ($isPantry && $jarLimit > 0): $jr = count(array_filter($jarsList, fn($j) => $j['left'] <= 0)); ?>
<section class="potstrip jarstrip" aria-label="Pantry jars">
  <h3>🫙 Pantry <small><?= count($jarsList) ?>/<?= $jarLimit ?> jars in use</small></h3>
  <div class="potrow">
    <?php foreach ($jarsList as $j): ?>
      <div class="pot jar <?= $j['left'] <= 0 ? 'done' : 'busy' ?>">
        <span class="potdish"><?= $outIcons[(int)$j['item_id']] ?? '🫙' ?></span>
        <span class="potname"><?= e($j['name']) ?> ×<?= (int)$j['qty'] ?></span>
        <span class="potleft" data-jarleft="<?= (int)$j['left'] ?>"><?= $j['left'] > 0 ? e(pantry_time_text((int)$j['left'])) : 'Ready!' ?></span>
        <form method="post" action="<?= e(url('crafting.php?c=pantry')) ?>" class="potcollect"<?= $j['left'] > 0 ? ' hidden' : '' ?>><?= csrf_field() ?>
          <input type="hidden" name="do" value="jar_collect"><input type="hidden" name="jar_id" value="<?= (int)$j['id'] ?>"><button class="btn small">Collect</button></form>
      </div>
    <?php endforeach; ?>
    <?php for ($n = count($jarsList); $n < $jarLimit; $n++): ?><div class="pot empty"><span class="potdish">🫙</span><span class="potname">Empty jar</span></div><?php endfor; ?>
  </div>
  <form method="post" action="<?= e(url('crafting.php?c=pantry')) ?>" data-jarall<?= $jr >= 2 ? '' : ' hidden' ?>><?= csrf_field() ?><input type="hidden" name="do" value="jar_collect_all"><button class="btn small alt">Collect all</button></form>
  <small class="muted">One jar holds one batch. Timers run in real days, even while you are away, and nothing spoils. Jam takes 1 day, chutney 2, pickles 3, kimchi 5, sauerkraut 7, cordials 14.</small>
</section>
<?php endif; ?>
<form method="get" action="<?= e(url('inventory.php')) ?>" class="pickform"><input type="hidden" name="tab" value="craft">
  <label>Make <select name="c" data-autosubmit>
    <?php foreach (CRAFT_CATEGORIES as $k => [$l, $ic]): ?><option value="<?= e($k) ?>"<?= $k === $tab ? ' selected' : '' ?>><?= $ic ?> <?= e($l) ?> (<?= (int)($counts[$k]['have'] ?? 0) ?>/<?= (int)($counts[$k]['total'] ?? 0) ?>)</option><?php endforeach; ?>
  </select></label>
  <label>List <select name="show" data-autosubmit>
    <?php foreach (['ready' => ['✅ Ready', count($ready)], 'missing' => ['📋 Missing', count($missing)], 'unknown' => ['❔ To discover', count($unknown)]] as $k => [$l, $n]): ?><option value="<?= $k ?>"<?= $show === $k ? ' selected' : '' ?>><?= $l ?> (<?= $n ?>)</option><?php endforeach; ?>
  </select></label>
  <button class="btn small pickgo">Go</button>
</form>
<?php if ($list): ?>
  <div class="ccgrid"><?php foreach ($list as $r) echo $card($r); ?></div>
<?php else: ?>
  <p class="muted"><?= ['ready' => 'Nothing you can make right now. Check 📋 Missing to see what to gather.', 'missing' => 'Nothing missing: everything you know, you can make.', 'unknown' => 'You’ve discovered every recipe here!'][$show] ?></p>
<?php endif; ?>

<?php
}
