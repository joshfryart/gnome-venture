<?php
declare(strict_types=1);
/**
 * v2.3.3: the Crafting "area map". With no ?c= the Crafting tab shows one picture card per area (Stitched Toy scenes, assets/img/craftmap/);
 * inside an area a compact strip of the same pictures switches area, an "All areas" button goes back, and the area's scene has tappable
 * objects (plain links to that area's list, filtered by ?q= or the Pantry's ?k=). Everything is a real link, so it works without JS.
 * Scene art and hotspot boxes: includes/data/craft_scenes.php (percent of the picture; the matching .hs-<area>-<id> rules sit in style.css because the CSP blocks inline styles). Called from craft_view(), craft_shelves() and pantry_view().
 */
require_once __DIR__ . '/crafting.php';

function craft_scenes(): array
{
    static $s = null;
    return $s ??= require __DIR__ . '/data/craft_scenes.php';
}

/** v2.3.7: does a recipe slug match an object's tag list (fnmatch globs like "pickled-*")? */
function craft_tag_match(array $globs, string $slug): bool
{
    foreach ($globs as $g) if (fnmatch($g, $slug)) return true;
    return false;
}

/** v2.3.7: the scene object picked by ?o= in this area, or null: ['id', 'label', 'globs']. Only objects with a tag list count. */
function craft_obj_pick(string $tab): ?array
{
    $o = (string)($_GET['o'] ?? '');
    if ($o === '') return null;
    foreach (craft_scenes()[$tab]['hot'] ?? [] as [$id, $label, , , , , $to]) {
        if ($id === $o && is_array($to)) return ['id' => $id, 'label' => $label, 'globs' => $to];
    }
    return null;
}

/** v2.3.7: the "Showing: <object> · Show all" line above a filtered list. */
function craft_obj_line(array $obj, string $clearUrl, int $n): string
{
    return '<p class="cmap-on"><span>Showing <b>' . e($obj['label']) . '</b>: ' . $n . ' recipe' . ($n === 1 ? '' : 's') . '</span> <a class="btn small alt" href="' . e($clearUrl) . '">Show all</a></p>';
}

/**
 * v2.3.7: ready recipes per category for the landing badges, from ONE craft_recipes() pass over every category (was one pass per area, six
 * on the landing). The pass also saves newly discovered recipes, so it runs before the known counts. No cross-request cache on purpose:
 * the satchel changes from many places and a stale "3 ready" would mislead.
 */
function craft_map_ready(int $uid): array
{
    $n = [];
    foreach (craft_recipes($uid) as $r) if ($r['known'] && $r['can']) $n[$r['category']] = ($n[$r['category']] ?? 0) + 1;
    return $n;
}

/** One line of facts per area for the map cards: have/total known, a lock if the building is missing, ready counts. */
function craft_map_facts(array $u): array
{
    $uid = (int)$u['id'];
    $stations = craft_stations($uid);
    $readyN = craft_map_ready($uid);
    $counts = [];
    foreach (q('SELECT r.category, COUNT(*) AS total, COUNT(ur.id) AS have FROM recipes r
                LEFT JOIN user_recipes ur ON ur.recipe_id = r.id AND ur.user_id = ? GROUP BY r.category', [$uid])->fetchAll() as $c) $counts[$c['category']] = $c;
    require_once __DIR__ . '/pantry.php';
    $jarLimit = pantry_jar_limit($uid);
    if ($jarLimit < 1) $stations['pantry'] = 0;
    $out = [];
    foreach (CRAFT_CATEGORIES as $k => [$label, $icon, $building]) {
        $have = (int)($counts[$k]['have'] ?? 0);
        $total = (int)($counts[$k]['total'] ?? 0);
        $badge = '';
        $locked = $stations[$k] === 0;
        if ($locked) {
            $badge = $k === 'pantry' ? 'Needs a Pantry' : 'Needs a ' . (BUILDINGS[$building][0] ?? 'building');
        } elseif ($k === 'pantry') {
            $jars = pantry_jars_list($uid);
            $done = count(array_filter($jars, fn($j) => $j['left'] <= 0));
            $badge = $done ? $done . ' jar' . ($done > 1 ? 's' : '') . ' done' : (count($jars) ? count($jars) . ' in use' : '');
        } else {
            $ready = $readyN[$k] ?? 0;
            if ($ready) $badge = $ready . ' ready';
        }
        $out[$k] = ['label' => $label, 'icon' => $icon, 'have' => $have, 'total' => $total, 'locked' => $locked, 'badge' => $badge];
    }
    return $out;
}

/** The landing view: every area as a picture card. */
function craft_map_landing(array $u): void
{
    $facts = craft_map_facts($u);
    $scenes = craft_scenes();
    ?>
<section class="cmap cmap-land" aria-label="Crafting areas">
  <h2 class="cmap-h">Where to craft?</h2>
  <p class="help cmap-sub">Pick an area.</p>
  <ul class="cmap-grid">
  <?php foreach ($facts as $k => $f): ?>
    <li><a class="cmap-card<?= $f['locked'] ? ' cmap-off' : '' ?>" href="<?= e(url('inventory.php?tab=craft&c=' . $k)) ?>">
      <span class="cmap-pic"><img src="<?= e(url('assets/img/craftmap/' . $k . '-t.png')) ?>" alt="" width="450" height="300" loading="lazy">
        <?php if ($f['badge'] !== ''): ?><span class="cmap-badge<?= $f['locked'] ? ' cmap-lockb' : '' ?>"><?= $f['locked'] ? 'Locked: ' : '' ?><?= e($f['badge']) ?></span><?php endif; ?></span>
      <span class="cmap-name"><?= e($f['label']) ?></span>
      <progress class="cmap-bar" max="<?= max(1, $f['total']) ?>" value="<?= $f['have'] ?>" aria-hidden="true"></progress>
      <span class="cmap-count"><?= $f['have'] ?> of <?= $f['total'] ?> known<?= $f['locked'] ? ', locked' : '' ?><span class="vh"><?= $f['badge'] !== '' ? ', ' . e($f['badge']) : '' ?></span></span>
    </a></li>
  <?php endforeach; ?>
  </ul>
</section>
<?php
}

/** Inside an area: "All areas", the picture strip and the scene with tappable objects. $tab = the open area. */
function craft_area_header(string $tab): void
{
    $scenes = craft_scenes();
    $sc = $scenes[$tab] ?? null;
    $qs = fn(string $to) => 'inventory.php?tab=craft&c=' . $tab . '&' . $to . '#shelves';
    ?>
<nav class="cmap cmap-in" aria-label="Crafting areas">
  <a class="cmap-all" href="<?= e(url('inventory.php?tab=craft')) ?>"><span aria-hidden="true">🗺️</span> All areas</a>
  <ul class="cmap-strip">
  <?php foreach (CRAFT_CATEGORIES as $k => [$l]): ?>
    <li><a href="<?= e(url('inventory.php?tab=craft&c=' . $k)) ?>"<?= $k === $tab ? ' aria-current="page"' : '' ?>><img src="<?= e(url('assets/img/craftmap/' . $k . '-t.png')) ?>" alt="" width="68" height="45" loading="lazy"><span><?= e($l) ?></span></a></li>
  <?php endforeach; ?>
  </ul>
</nav>
<?php if ($sc): ?>
<figure class="cmap-scene">
  <img src="<?= e(url('assets/img/craftmap/' . $tab . '.png')) ?>" alt="<?= e($sc['alt']) ?>" width="900" height="600">
  <?php $pick = (string)($_GET['o'] ?? '');
  foreach ($sc['hot'] as [$id, $label, $x, $y, $w, $h, $to]): $tag = is_array($to); ?>
    <a class="cmap-hs hs-<?= e($tab . '-' . $id) ?>" href="<?= e(url($qs($tag ? 'o=' . $id : $to))) ?>" aria-label="<?= e($label) ?>"<?= $tag && $pick === $id ? ' aria-current="true"' : '' ?>><span><?= e($label) ?></span></a>
  <?php endforeach; ?>
</figure>
<?php endif;
}
