<?php
declare(strict_types=1);
/**
 * The Satchel tab as "Shelves" (mockup design 3): a Quick bar of one-tap Eat / Open / Read / Mend buttons, a search box, then one foldable
 * shelf per type (or one shelf for another sort or the Untasted list) of compact pills; a pill opens its panel inline under its row.
 * Same Show (?cat=) and Sort (?sort=) lists as before, ?open=item_id opens an item (the POST redirect uses it), ?q= searches.
 * Pieces in includes/shelves.php; layout .shelves in assets/style.css; folding, picking and filtering in assets/site.js.
 * Called from inventory.php for the default view. Expects $u.
 */
require_once __DIR__ . '/shelves.php';

function satchel_view(array $u): void
{
$uid = (int)$u['id'];
$items = q('SELECT i.id, i.slug, i.name, i.category, i.description, i.edible, i.effects, i.rarity, i.base_price, i.image, i.tradable, ui.qty, ui.wear, ui.id AS uiid, ui.got_at,
            (SELECT 1 FROM user_tasted t WHERE t.user_id = ui.user_id AND t.item_id = i.id) AS tasted
            FROM user_items ui JOIN items i ON i.id = ui.item_id
            WHERE ui.user_id = ? AND ui.qty > 0 ORDER BY i.category, i.name', [$uid])->fetchAll();
$cats = ['all' => 'All', 'untasted' => '✨ Untasted'];   // v1.6.3: "Untasted": edible things never eaten yet (some raise a stat for good)
foreach (SH_BAG_GROUPS as $k => [$ic, $l]) $cats[$k] = $ic . ' ' . $l;
$cat = (string)($_GET['cat'] ?? 'all');
if (!isset($cats[$cat])) $cat = 'all';
$sorts = ['new' => '🕒 Newest first', 'old' => '🕰️ Oldest first', 'az' => '🔤 Name A–Z', 'za' => '🔤 Name Z–A', 'most' => '📦 Most owned', 'least' => '📦 Fewest owned', 'rare' => '💎 Rarest first', 'type' => '🗂️ By type'];
$sort = (string)($_GET['sort'] ?? 'type');
if (!isset($sorts[$sort])) $sort = 'type';
$qs = trim((string)($_GET['q'] ?? ''));
$hid = '<input type="hidden" name="cat" value="' . e($cat) . '"><input type="hidden" name="sort" value="' . e($sort) . '">';   // v0.7.86: every form comes back to this list
$all = sh_bag_entries($u, $items, $hid);
$counts = ['all' => count($all), 'untasted' => count(array_filter($all, fn($e) => $e['untasted']))];
foreach ($all as $e) $counts[$e['group']] = ($counts[$e['group']] ?? 0) + 1;
$shown = array_values(array_filter($all, fn($e) => ($cat === 'all' || ($cat === 'untasted' ? $e['untasted'] : $e['group'] === $cat)) && ($qs === '' || mb_stripos($e['hay'], $qs) !== false)));
// v0.7.61: sort every list
$rankOf = ['L' => 4, 'R' => 3, 'U' => 2, 'C' => 1];
$got = fn(array $e) => [(string)($e['item']['got_at'] ?? ''), (int)$e['item']['uiid']];
$order = array_flip(array_keys(SH_BAG_GROUPS));
usort($shown, match ($sort) {
    'new' => fn($a, $b) => $got($b) <=> $got($a),
    'old' => fn($a, $b) => $got($a) <=> $got($b),
    'az' => fn($a, $b) => strcasecmp($a['name'], $b['name']),
    'za' => fn($a, $b) => strcasecmp($b['name'], $a['name']),
    'most' => fn($a, $b) => [$b['count'], $a['name']] <=> [$a['count'], $b['name']],
    'least' => fn($a, $b) => [$a['count'], $a['name']] <=> [$b['count'], $b['name']],
    'rare' => fn($a, $b) => [$rankOf[$b['rarity']] ?? 0, $a['name']] <=> [$rankOf[$a['rarity']] ?? 0, $b['name']],
    default => fn($a, $b) => [$order[$a['group']] ?? 99, (string)$a['item']['category'], $a['name']] <=> [$order[$b['group']] ?? 99, (string)$b['item']['category'], $b['name']],
});
if ($cat === 'untasted') usort($shown, fn($a, $b) => [$b['perm'], 0] <=> [$a['perm'], 0]);   // v1.6.3: rare first-taste (stat) items first; usort is stable
// shelves: by type when sorted by type, else one shelf in the chosen order
if ($sort === 'type' && $cat !== 'untasted') { $defs = SH_BAG_GROUPS; $open = array_fill_keys(array_keys(SH_BAG_GROUPS), true); }
else { foreach ($shown as &$e) $e['group'] = 'list'; unset($e); $defs = ['list' => $cat === 'untasted' ? ['✨', 'Untasted'] : [explode(' ', $sorts[$sort], 2)[0], explode(' ', $sorts[$sort], 2)[1]]]; $open = ['list' => true]; }
$selId = (int)($_GET['open'] ?? 0);
$selSheet = preg_match('/^[a-z]{2,12}$/', (string)($_GET['sheet'] ?? '')) ? (string)$_GET['sheet'] : '';   // v2.4.67
$landing = $cat === 'all' && $sort === 'type' && $qs === '' && $all;   // v2.5.0: the tile page; any other choice shows the list as before
$base = 'inventory.php?' . http_build_query(array_filter(['cat' => $cat === 'all' ? '' : $cat, 'sort' => $sort === 'type' ? '' : $sort, 'q' => $qs], 'strlen'));
$link = fn(int $id) => url($base . (str_ends_with($base, '?') ? '' : '&') . 'open=' . $id) . '#i' . $id;
$close = fn() => url(rtrim($base, '?'));
$things = array_sum(array_map(fn($e) => $e['count'], $all));
?>
<div class="pantry2 shelves shbag<?= $landing ? ' shbagtiles' : '' ?>">
<?php if ($landing): // v2.5.0: 8 square tiles; each opens a sheet with that group's things (search, chips, sort inside) ?>
<?= sh_search('', '', '🔍 Search ' . count($all) . ' things in your satchel…') ?>
<p class="muted p2title shcount"><?= count($all) ?> kind<?= count($all) === 1 ? '' : 's' ?> · <?= number_format($things) ?> thing<?= $things === 1 ? '' : 's' ?></p>
<?php
  $byG = [];
  foreach ($all as $e) $byG[$e['group']][] = $e;
  $untN = count(array_filter($all, fn($e) => $e['untasted'])); ?>
<div class="shtiles">
<?php foreach (SH_BAG_GROUPS as $gk => [$gi, $gl]): $rows = $byG[$gk] ?? []; $n = count($rows); $hay = implode(' ', array_map(fn($e) => mb_strtolower($e['hay']), $rows)); ?>
  <?php if ($n): ?><a class="shtile" href="<?= e(url('inventory.php?cat=' . $gk)) ?>" data-shpop="shd-<?= e($gk) ?>" data-count="<?= $n ?>"><span class="shti" aria-hidden="true"><?= $gi ?></span><b><?= e($gl) ?></b><small><?= $n ?> · ×<?= number_format(array_sum(array_column($rows, 'count'))) ?></small><?php if ($gk === 'kitchen' && $untN): ?><i class="shtb" title="<?= $untN ?> untasted"><?= $untN ?>✨</i><?php endif; ?></a>
  <?php else: ?><span class="shtile empty" aria-hidden="true"><span class="shti"><?= $gi ?></span><b><?= e($gl) ?></b><small>none</small></span><?php endif; ?>
<?php endforeach; ?>
</div>
<?php $quick = array_values(array_filter($all, fn($e) => $e['quick'] !== null));
  $qrank = fn(array $e) => [$e['perm'] ? 0 : 1, ['packet' => 0, 'guide' => 1, 'broken' => 2, 'food' => 3][$e['item']['category']] ?? 4, $e['name']];
  usort($quick, fn($a, $b) => $qrank($a) <=> $qrank($b));   // rare tastes, packets, guides, mending and dishes first, then the raw crops
  if ($quick): ?>
<section class="shquick" aria-label="Quick actions"><h3 class="shqh">⚡ Quick <small>one tap, no digging</small></h3>
  <div class="shqrow">
    <?php foreach (array_slice($quick, 0, 8) as $e): ?>
      <div class="shqi"><span class="p2ic" aria-hidden="true"><?= sh_icon($e['item'], 'sm') ?></span><span class="shqt"><b><?= e($e['name']) ?></b><small>×<?= number_format((int)$e['count']) ?><?= $e['perm'] ? ' · <span class="shtaste">rare taste</span>' : ($e['untasted'] ? ' · ✨ untasted' : '') ?></small></span><?= $e['quick'] ?></div>
    <?php endforeach; ?>
  </div>
</section>
<?php endif; ?>
<?php
  foreach (SH_BAG_GROUPS as $gk => [$gi, $gl]): $rows = $byG[$gk] ?? []; if (!$rows) continue;
    $subs = [];
    foreach ($rows as $e) { $c = (string)($e['item']['category'] ?? ''); if (isset(SH_BAG_CATS[$c])) $subs[$c] = SH_BAG_CATS[$c][2]; }
    $hasSel = $selId > 0 && (in_array($selId, array_column($rows, 'id'), true) || $gk === $selSheet); ?>
<dialog class="picker craftpop shbagpop" id="shd-<?= e($gk) ?>" aria-labelledby="shd-<?= e($gk) ?>-t"<?= $hasSel ? ' data-autoopen="1"' : '' ?>><div class="pickbox">
  <div class="pickhead"><h3 id="shd-<?= e($gk) ?>-t"><?= $gi ?> <?= e($gl) ?> <small class="muted"><?= count($rows) ?> kind<?= count($rows) === 1 ? '' : 's' ?> · ×<?= number_format(array_sum(array_column($rows, 'count'))) ?></small></h3><button type="button" class="pickx" data-shpd-close aria-label="Close">✕</button></div>
  <div class="shpdctl">
    <input type="search" class="shpdq" data-shpd-filter placeholder="🔍 Search <?= e(mb_strtolower($gl)) ?>…" aria-label="Search <?= e($gl) ?>" autocomplete="off">
    <select class="shpds" data-shpd-sort aria-label="Sort"><option value="type">Default</option><option value="az">Name A–Z</option><option value="za">Name Z–A</option><option value="most">Most owned</option><option value="least">Fewest owned</option><option value="new">Newest first</option></select>
  </div>
  <?php if (count($subs) > 1 || ($gk === 'kitchen' && $untN)): ?><div class="shpdchips" role="group" aria-label="Filter">
    <button type="button" class="shpdchip on" data-shpd-chip="">All <?= count($rows) ?></button>
    <?php foreach ($subs as $c => $cl): $cn = count(array_filter($rows, fn($e) => (string)($e['item']['category'] ?? '') === $c)); ?><button type="button" class="shpdchip" data-shpd-chip="<?= e($c) ?>"><?= e($cl) ?> <?= $cn ?></button><?php endforeach; ?>
    <?php if ($gk === 'kitchen' && $untN): ?><button type="button" class="shpdchip" data-shpd-chip="*untasted">✨ Untasted <?= $untN ?></button><?php endif; ?>
  </div><?php endif; ?>
  <div class="shpdbody"><?= sh_shelves($rows, [$gk => [$gi, $gl]], [$gk => true], $selId, 'bag', $link, $close, true) ?><p class="muted shpdnone" hidden>Nothing matches.</p></div>
</div></dialog>
<?php endforeach; ?>
<?php else: ?>
<div class="p2head shhead">
  <?php // v1.6.3: category and sort are two dropdowns in one row (a GET form; site.js sends it when a choice changes) ?>
  <form method="get" action="<?= e(url('inventory.php')) ?>" class="pickform p2cat shpick">
    <label>Show <select name="cat" data-autosubmit>
      <?php foreach ($cats as $k => $label): if ($k !== 'all' && empty($counts[$k]) && $k !== $cat) continue; ?><option value="<?= e($k) ?>"<?= $k === $cat ? ' selected' : '' ?>><?= e($label) ?> (<?= (int)($counts[$k] ?? 0) ?>)</option><?php endforeach; ?>
    </select></label>
    <label>Sort <select name="sort" data-autosubmit>
      <?php foreach ($sorts as $k => $label): ?><option value="<?= e($k) ?>"<?= $k === $sort ? ' selected' : '' ?>><?= e($label) ?></option><?php endforeach; ?>
    </select></label>
    <button class="btn small pickgo">Go</button>
  </form>
  <p class="muted p2title shcount"><?= count($all) ?> kind<?= count($all) === 1 ? '' : 's' ?> · <?= number_format($things) ?> thing<?= $things === 1 ? '' : 's' ?></p>
</div>
<?php if (!$all): ?><p class="muted">Empty. Time to visit the market!</p><?php endif; ?>
<?php $quick = array_values(array_filter($all, fn($e) => $e['quick'] !== null));
  $qrank = fn(array $e) => [$e['perm'] ? 0 : 1, ['packet' => 0, 'guide' => 1, 'broken' => 2, 'food' => 3][$e['item']['category']] ?? 4, $e['name']];
  usort($quick, fn($a, $b) => $qrank($a) <=> $qrank($b));   // rare tastes, packets, guides, mending and dishes first, then the raw crops
  if ($quick): ?>
<section class="shquick" aria-label="Quick actions"><h3 class="shqh">⚡ Quick <small>one tap, no digging</small></h3>
  <div class="shqrow">
    <?php foreach (array_slice($quick, 0, 8) as $e): ?>
      <div class="shqi"><span class="p2ic" aria-hidden="true"><?= sh_icon($e['item'], 'sm') ?></span><span class="shqt"><b><?= e($e['name']) ?></b><small>×<?= number_format((int)$e['count']) ?><?= $e['perm'] ? ' · <span class="shtaste">rare taste</span>' : ($e['untasted'] ? ' · ✨ untasted' : '') ?></small></span><?= $e['quick'] ?></div>
    <?php endforeach; ?>
  </div>
</section>
<?php endif; ?>
<?php if ($all): ?>
<?= sh_search($qs, ($cat !== 'all' ? '<input type="hidden" name="cat" value="' . e($cat) . '">' : '') . ($sort !== 'type' ? '<input type="hidden" name="sort" value="' . e($sort) . '">' : ''), '🔍 Search ' . count($all) . ' things in your satchel…') ?>
<?php endif; ?>
<?php if ($all && !$shown): ?><p class="muted"><?= $qs !== '' ? 'Nothing matches “' . e($qs) . '”.' : 'Nothing here.' ?></p><?php endif; ?>
<?= sh_shelves($shown, $defs, $open, $selId, 'bag', $link, $close, true) ?>
<p class="muted shnone" hidden>Nothing matches.</p>
<?php endif; ?>
</div>
<?php
}
