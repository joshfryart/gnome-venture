<?php
declare(strict_types=1);
/**
 * The Crafting tabs other than the Pantry as "Shelves" (mockup design 3): one strip (energy, Petals and the pots for Cooking, the Tool Shed for
 * Tools, "No building needed" elsewhere), a Shopping list of what the recipes one trip away still need, a search box, then shelves by how close
 * you are: Ready, One trip away (short 2 or less), Need more, To discover. A pill opens its recipe inline: You have / Still need and the Make buttons.
 * Same rules and POSTs as the old cards (includes/shelves.php: sh_craft_entries). ?c= category, ?show=ready|missing|unknown keeps one list,
 * ?r=recipe_id opens a recipe, ?q= searches names and ingredients. Called from craft_view(). Expects $u (energy refreshed by inventory.php).
 */
require_once __DIR__ . '/shelves.php';

function craft_shelves(array $u, string $tab): void
{
$uid = (int)$u['id'];
$stations = craft_stations($uid);
if ($tab === 'cooking' && !q_val("SELECT 1 FROM recipes WHERE slug LIKE 'feast-%'")) ensure_crafts();   // v0.7.96: feasts arrive even if the site was already on 0.7.96
$recipes = craft_recipes($uid, $tab);
$counts = [];
foreach (q('SELECT r.category, COUNT(*) AS total, COUNT(ur.id) AS have FROM recipes r
            LEFT JOIN user_recipes ur ON ur.recipe_id = r.id AND ur.user_id = ? GROUP BY r.category', [$uid])->fetchAll() as $c) $counts[$c['category']] = $c;
[$label, $icon, $building, $blurb] = CRAFT_CATEGORIES[$tab];
usort($recipes, fn($a, $b) => [$b['known'], $b['known'] && $b['can']] <=> [$a['known'], $a['known'] && $a['can']] ?: strcmp($a['name'], $b['name']));
$all = sh_craft_entries($u, $tab, $recipes, $stations);
$n = ['ready' => 0, 'missing' => 0, 'unknown' => 0];
foreach ($all as $e) $n[$e['status'] === 'ok' ? 'ready' : ($e['status'] === 'unk' ? 'unknown' : 'missing')]++;
$known = $n['ready'] + $n['missing'];
$show = (string)($_GET['show'] ?? '');
if (!in_array($show, ['ready', 'missing', 'unknown'], true)) $show = '';
$qs = trim((string)($_GET['q'] ?? ''));
$selId = (int)($_GET['r'] ?? 0);
require_once __DIR__ . '/craft_map.php';
$obj = craft_obj_pick($tab);   // v2.3.7: a tapped scene object (?o=) keeps only its recipes, known or not
$slugOf = [];
foreach ($recipes as $r) $slugOf[(int)$r['id']] = (string)($r['slug'] ?? '');
$shelfOf = ['ready' => ['ready'], 'missing' => ['close', 'far'], 'unknown' => ['unk']];
$shown = array_values(array_filter($all, fn($e) => ($show === '' || in_array($e['group'], $shelfOf[$show], true)) && ($qs === '' || mb_stripos($e['hay'], $qs) !== false)
    && (!$obj || craft_tag_match($obj['globs'], $slugOf[(int)$e['id']] ?? ''))));
$defs = ['ready' => ['✅', 'Ready to ' . ($tab === 'cooking' ? 'cook' : 'make')], 'close' => ['🧺', 'One trip away'], 'far' => ['📋', 'Need more'], 'unk' => ['❔', 'To discover']];
$open = $show !== '' || $qs !== '' || $obj ? array_fill_keys(array_keys($defs), true) : ['ready' => true, 'close' => true];
$base = 'inventory.php?' . http_build_query(array_filter(['tab' => 'craft', 'c' => $tab, 'show' => $show, 'q' => $qs, 'o' => $obj['id'] ?? ''], 'strlen'));
$link = fn(int $id) => url($base . '&r=' . $id) . '#r' . $id;
$close = fn() => url($base);
$potsOn = $tab === 'cooking' && cook_pots_on() && $stations['cooking'] !== 0;   // v0.9.4: pots with timers (kitchen_pots 0 = instant)
?>
<?php craft_area_header($tab, craft_can_by_obj($tab, $all, $slugOf)); ?>
<?= craft_pop_html($tab, $all, $slugOf) /* v2.4.0: outside .shelves so the shelf handlers never see the dialogs */ ?>
<div class="pantry2 shelves shcraft">
<div class="p2head shhead">
  <?php // v2.3.3: the area is picked on the map above (craft_map.php); this form keeps it and only filters the list ?>
  <h2 class="p2title" id="shelves"><?= $icon ?> <?= e($label) ?> <small><?= $known ?>/<?= count($all) ?> recipes known</small></h2>
  <details class="helpfold p2help"><summary>❓ How crafting works</summary><p class="help"><?= e($blurb) ?> One workbench for everything you make. A recipe appears once you’ve collected every ingredient:
    grown it, gathered it on an adventure, or carried it in your satchel. Once found, it stays found.<?= $tab === 'cooking' ? ' Dishes wait in the pot until you collect them. Snacks cook in minutes, meals take longer, feasts longest.' : '' ?></p></details>
</div>
<?php if ($stations[$tab] === 0): $b = BUILDINGS[$building]; ?>
  <div class="box notice">You need a <b><?= e($b[1] . ' ' . $b[0]) ?></b> in one of your gardens to make these.
    A garden at <b>level <?= (int)$b[2] ?></b> can build one for <?= money((int)$b[3]) ?> from
    <a href="<?= e(url('garden.php')) ?>">the garden page</a>. Every harvest raises your garden level.
    You can still discover recipes in the meantime.</div>
<?php endif; ?>
<section class="p2jars shstation" aria-label="<?= $potsOn ? 'Pots' : 'Station' ?>">
  <div class="p2jarrow<?= $potsOn ? ' p2shelf' : '' ?>">
    <?php if ($potsOn):
        require_once __DIR__ . '/pal_jobs.php';
        try { pj_settle($uid); } catch (Throwable $e) {}   // pals tending pots check them when you look
        $pots = cook_pots_list($uid); $lim = cook_pot_limit($u); $readyN = count(array_filter($pots, fn($p) => $p['left'] <= 0 && empty($p['pal'])));
        $palOpts = [];   // recipes a tending pal can be set to, per station
        $outItems = [];
        foreach (q("SELECT i.* FROM items i JOIN recipes r ON r.output_item_id = i.id WHERE r.category = 'cooking'")->fetchAll() as $it) $outItems[(int)$it['id']] = $it;
        foreach ($pots as $p): $done = $p['left'] <= 0;
          if (!empty($p['pal'])): // a pal tends this pot: its dish is the pal's choice, changed here and kept until changed or the shift ends
            $jr = q_one('SELECT target FROM ppal_jobs WHERE id = ?', [(int)$p['job']]);
            if (!isset($palOpts[(string)($jr['target'] ?? '')])) {
                [$pa, $pb] = array_pad(explode(':', (string)($jr['target'] ?? ''), 2), 2, ''); $po = pj_station_object($pa, $pb);
                $palOpts[(string)($jr['target'] ?? '')] = $po ? pj_station_recipes($uid, $pa, $po['globs']) : [];
            }
            $opts = $palOpts[(string)($jr['target'] ?? '')]; ?>
      <div class="p2jar pot potsq palpot <?= $done && empty($p['idle']) ? 'done' : 'busy' ?>" title="<?= e($p['pal'] . ' is tending this pot') ?>">
        <span class="p2ic" aria-hidden="true"><?= isset($outItems[(int)$p['item_id']]) ? sh_icon($outItems[(int)$p['item_id']], 'sm') : '🧩' ?></span>
        <span class="shpn"><?= e($p['name']) ?><?= (int)$p['makes'] > 1 ? ' ×' . (int)$p['makes'] : '' ?></span>
        <span class="potleft">🧩 <?= e($p['pal']) ?> is tending this pot<?= !empty($p['idle']) ? '' : ' · ' . ($done ? 'ready, served at the next check' : e(energy_clock((int)$p['left']))) ?></span>
        <?php if (empty($p['locked'])): ?>
        <form method="post" action="<?= e(url('crafting.php?c=cooking')) ?>" class="potpick"><?= csrf_field() ?>
          <input type="hidden" name="do" value="pal_pot_recipe"><input type="hidden" name="job_id" value="<?= (int)$p['job'] ?>">
          <label><span class="muted">Cooks next</span> <select name="recipe_id" aria-label="What <?= e($p['pal']) ?> cooks next">
            <?php foreach ($opts as $rid => $rx): ?><option value="<?= (int)$rid ?>"<?= (int)$rid === (int)$p['plan'] ? ' selected' : '' ?>><?= e((string)$rx['name']) ?></option><?php endforeach; ?>
          </select></label> <button class="btn small">Set</button></form>
        <?php else: ?><a class="rgo" href="<?= e(url('paljobs.php')) ?>">Collect the shift →</a><?php endif; ?>
      </div>
    <?php continue; endif; ?>
      <div class="p2jar pot potsq <?= $done ? 'done' : 'busy' ?>" title="<?= e($p['name']) ?>">
        <span class="p2ic" aria-hidden="true"><?= isset($outItems[(int)$p['item_id']]) ? sh_icon($outItems[(int)$p['item_id']], 'sm') : '🍲' ?></span>
        <span class="shpn"><?= e($p['name']) ?><?= (int)$p['makes'] > 1 ? ' ×' . (int)$p['makes'] : '' ?></span>
        <span class="potleft" data-potleft="<?= (int)$p['left'] ?>"><?= $done ? 'Ready!' : e(energy_clock((int)$p['left'])) ?></span>
        <form method="post" action="<?= e(url('crafting.php?c=cooking')) ?>" class="potcollect"<?= $done ? '' : ' hidden' ?>><?= csrf_field() ?>
          <input type="hidden" name="do" value="collect"><input type="hidden" name="pot_id" value="<?= (int)$p['id'] ?>"><button class="btn small">Collect</button></form>
      </div>
    <?php endforeach;
        $free = max(0, $lim - count($pots)); ?>
    <?php for ($fi = 0; $fi < $free; $fi++): ?><div class="p2jar pot potsq empty" title="Empty pot"><span class="p2ic" aria-hidden="true">🫕</span><span class="shpn">Empty</span><span class="potleft">free</span></div><?php endfor; ?>
    </div><div class="p2potacts">
    <?php if ($free > 0 && ($lastDish = (string)q_val('SELECT i.name FROM users u JOIN items i ON i.id = u.last_cooked_id WHERE u.id = ?', [(int)$u['id']])) !== ''): ?>
    <form method="post" action="<?= e(url('crafting.php?c=cooking')) ?>" class="p2all"><?= csrf_field() ?><input type="hidden" name="do" value="cook_again"><button class="btn small">Cook again: <?= e($lastDish) ?></button></form>
    <?php endif; ?>
    <form method="post" action="<?= e(url('crafting.php?c=cooking')) ?>" class="p2all" data-potall<?= $readyN >= 2 ? '' : ' hidden' ?>><?= csrf_field() ?><input type="hidden" name="do" value="collect_all"><button class="btn small alt">Collect all</button></form>
    <?php elseif ($stations[$tab] === 0): $b = BUILDINGS[$building]; ?>
      <span class="p2jar shstat empty"><span class="p2ic" aria-hidden="true">🔒</span><span class="p2jt"><?= e($b[0]) ?> needed</span></span>
    <?php elseif ($building !== null): $b = BUILDINGS[$building]; ?>
      <span class="p2jar shstat done"><span class="p2ic" aria-hidden="true"><?= $b[1] ?></span><span class="p2jt"><?= e($b[0]) ?> ready</span></span>
    <?php else: ?>
      <span class="p2jar shstat empty"><span class="p2jt">No building needed</span></span>
    <?php endif; ?>
  </div>
</section>
<?php // v2.4.0: the long list is a closed fold: the scene popovers do the crafting. It opens by itself for a tapped object, a search, a List pick or an open recipe (and without JS) ?>
<details class="craftall" id="shelves-all"<?= ($obj || $qs !== '' || $show !== '' || $selId > 0) ? ' open' : '' ?>><summary><b>All recipes</b> <small class="muted"><?= $n['ready'] ?> ready · <?= $n['missing'] ?> missing · <?= $n['unknown'] ?> to discover</small></summary>
<div class="p2head shhead craftallhd">
  <form method="get" action="<?= e(url('inventory.php')) ?>" class="pickform p2cat shpick"><input type="hidden" name="tab" value="craft"><input type="hidden" name="c" value="<?= e($tab) ?>"><?php if ($obj): ?><input type="hidden" name="o" value="<?= e($obj['id']) ?>"><?php endif; ?>
    <label>List <select name="show" data-autosubmit>
      <option value=""<?= $show === '' ? ' selected' : '' ?>>🗂️ All shelves</option>
      <?php foreach (['ready' => ['✅ Ready', $n['ready']], 'missing' => ['📋 Missing', $n['missing']], 'unknown' => ['❔ To discover', $n['unknown']]] as $k => [$l, $c]): ?><option value="<?= $k ?>"<?= $show === $k ? ' selected' : '' ?>><?= $l ?> (<?= $c ?>)</option><?php endforeach; ?>
    </select></label>
    <button class="btn small pickgo">Go</button>
  </form>
</div>
<?php // v2.5.0: the shopping list is gone: a popover's Missing tab already says what you lack ?>
<?= sh_search($qs, '<input type="hidden" name="tab" value="craft"><input type="hidden" name="c" value="' . e($tab) . '">' . ($show !== '' ? '<input type="hidden" name="show" value="' . e($show) . '">' : ''), '🔍 Search ' . $known . ' recipes or an ingredient…') ?>
<?php if ($obj) echo craft_obj_line($obj, url('inventory.php?' . http_build_query(array_filter(['tab' => 'craft', 'c' => $tab, 'show' => $show, 'q' => $qs], 'strlen'))) . '#shelves', count($shown)); ?>
<?php if (!$shown): ?>
  <p class="muted"><?= $obj ? 'Nothing here on this list.' : '' ?><?= $obj ? '' : ($qs !== '' ? 'Nothing matches “' . e($qs) . '”.' : (['ready' => 'Nothing you can make right now. Check 📋 Missing to see what to gather.', 'missing' => 'Nothing missing: everything you know, you can make.', 'unknown' => 'You’ve discovered every recipe here!'][$show] ?? 'No recipes yet.')) ?></p>
<?php endif; ?>
<?= sh_shelves($shown, $defs, $open, $selId, 'craft-' . $tab, $link, $close, false) ?>
<p class="muted shnone" hidden>Nothing matches.</p>
</details>
</div>
<?php
}
