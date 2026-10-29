<?php
declare(strict_types=1);
/**
 * v0.9.9 part A: Arranging. Tabs: Arrange (pick a vessel, tap flowers into spots), Drying rack, Seed packets, Weekly show, Florists.
 * The logic is in includes/flowers.php, the art in includes/flower_art.php (SVG files in assets/img/flowers/), the live screen in assets/arrange.js.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/flowers.php';
$u = require_login();
$uid = (int)$u['id'];
flowers_boot();
settle_arrangements();

const ARR_TABS = ['arrange' => '💐 Arrange', 'dry' => '🪢 Drying rack', 'packets' => '📦 Seed packets', 'show' => '🎗️ Weekly show', 'florists' => '🌷 Florists'];
$tab = (string)($_GET['t'] ?? 'arrange');
if (!isset(ARR_TABS[$tab]) && $tab !== 'preview') $tab = 'arrange';

// The score for a composition in progress (JSON, read-only). s = "slot:itemId,slot:itemId"
if ($tab === 'preview') {
    header('Content-Type: application/json; charset=utf-8');
    $v = (string)($_GET['v'] ?? '');
    $slots = [];
    foreach (explode(',', (string)($_GET['s'] ?? '')) as $pair) {
        [$sl, $iid] = array_map('intval', array_pad(explode(':', $pair), 2, 0));
        if ($iid > 0 && isset(SLOT_POS[$sl])) $slots[$sl] = $iid;
    }
    if (!isset(VESSELS[$v]) || count($slots) < max(1, (int)setting('arrange_min_stems')) || count($slots) > VESSELS[$v][1]) { echo json_encode(['ok' => false]); exit; }
    $stems = [];
    foreach ($slots as $sl => $iid) {
        $it = q_one("SELECT * FROM items WHERE id = ? AND category = 'flower'", [$iid]);
        if (!$it || ($slug = flower_item_slug($it)) === '') { echo json_encode(['ok' => false]); exit; }
        $stems[] = ['slot' => $sl, 'slug' => $slug, 'dried' => !empty((json_decode((string)$it['effects'], true) ?: [])['dried']), 'rarity' => (int)$it['rarity']];
    }
    $sc = arrange_score($stems, $v, arrange_ctx($u));
    echo json_encode(['ok' => true, 'total' => $sc['total'], 'word' => $sc['word'], 'name' => arrange_name($stems, $v, $sc),
        'parts' => array_values(array_map(fn($k, $p) => [$k, $p[0], $p[1], $p[2]], array_keys($sc['parts']), $sc['parts']))]);
    exit;
}

if (is_post()) {
    csrf_check();
    refresh_energy($u);
    $do = (string)($_POST['do'] ?? '');
    $back = 'arrange.php';
    if ($do === 'arrange') {
        $slots = [];
        foreach ((array)($_POST['slot'] ?? []) as $sl => $iid) if (is_numeric($sl) && is_numeric($iid)) $slots[(int)$sl] = (int)$iid;
        [$ok, $msg, $made] = arrange_make($u, (string)($_POST['v'] ?? ''), $slots);
        if ($ok) $back .= '?made=' . $made;
    } elseif ($do === 'dry') {
        [$ok, $msg] = dry_start($u, (int)($_POST['item_id'] ?? 0), (int)($_POST['qty'] ?? 1));
        $back .= '?t=dry';
    } elseif ($do === 'dry_collect') {
        [$ok, $msg] = dry_collect($u, (int)($_POST['rack'] ?? 0));
        $back .= '?t=dry';
    } elseif ($do === 'dry_all') {
        [$ok, $msg] = dry_collect_all($u);
        $back .= '?t=dry';
    } elseif ($do === 'packet') {
        [$ok, $msg] = packet_make($u, (int)($_POST['plant_id'] ?? 0));
        $back .= '?t=packets';
    } elseif ($do === 'enter') {
        [$ok, $msg] = arrangement_enter($u, (int)($_POST['item_id'] ?? 0));
        $back .= '?t=show';
    } elseif ($do === 'flo_collect') {
        [$ok, $msg] = florist_collect($u, (int)($_POST['shift'] ?? 0));
        $back .= '?t=florists';
    } else {
        [$ok, $msg] = [false, 'Nothing happened.'];
    }
    flash($msg, $ok ? 'ok' : 'err');
    redirect($back);
}

refresh_energy($u);
page_header('Arranging');
$IL = null;
?>
<h1>👜 Your Satchel</h1>
<nav class="tabs bagtabs tabs4">   <?php // v1.6.3: same four equal columns as the Satchel ?>
  <a href="<?= e(url('inventory.php')) ?>"><span aria-hidden="true">👜</span> Satchel</a>
  <a href="<?= e(url('inventory.php?tab=craft')) ?>"><span aria-hidden="true">🔨</span> Crafting</a>
  <a href="<?= e(url('inventory.php?tab=belt')) ?>"><span aria-hidden="true">🧰</span> Belt</a>
  <a class="on" href="<?= e(url('arrange.php')) ?>"><span aria-hidden="true">💐</span> Arrange</a>
</nav>
<nav class="chips arrtabs" aria-label="Arranging">
  <?php $dryReady = dry_ready_count($uid); foreach (ARR_TABS as $k => $label): ?>
    <a class="<?= $k === $tab ? 'on' : '' ?>" href="<?= e(url('arrange.php' . ($k === 'arrange' ? '' : '?t=' . $k))) ?>"><?= $label ?><?= $k === 'dry' && $dryReady ? ' <small>' . $dryReady . ' ready</small>' : '' ?></a>
  <?php endforeach; ?>
</nav>

<?php if ($tab === 'arrange'):
    $stock = flower_stock($uid);
    $made = (int)($_GET['made'] ?? 0);
    $madeItem = $made ? q_one("SELECT * FROM items WHERE id = ? AND category = 'arrangement'", [$made]) : null;
    $madeComp = $madeItem ? arrangement_of($madeItem) : null;
    if ($madeComp && !q_val('SELECT 1 FROM user_items WHERE user_id = ? AND item_id = ? AND qty > 0', [$uid, $made])) $madeComp = null;   // only the owner sees the card
    ?>
  <?php if ($madeComp): ?>
  <section class="box arrmade">
    <h2>✨ <?= e($madeItem['name']) ?></h2>
    <div class="arrbig"><?= arrangement_svg($madeComp, 'full', $madeItem['name']) ?></div>
    <p><b><?= e(arrange_word((int)$madeComp['score'])) ?>, <?= (int)$madeComp['score'] ?>/100.</b> It’s in your Satchel. Sell it for about <?= money(sell_price($madeItem, $u)) ?>, give it as a present, or enter it in the weekly show.</p>
    <form method="post" action="<?= e(url('arrange.php')) ?>" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="enter"><input type="hidden" name="item_id" value="<?= $made ?>"><button class="btn small">🎗️ Enter the weekly show</button></form>
  </section>
  <?php endif; ?>

  <?php if (!$stock): ?>
    <div class="box notice"><b>No flowers in your satchel yet.</b> Grow flowers and harvest them (they become cut flowers), buy some at a 🌷 florist, or <a href="<?= e(url('arrange.php?t=florists')) ?>">volunteer at one</a> for a free bundle.</div>
  <?php else:
    $flowers = [];
    foreach ($stock as $f) {
        $flowers[(int)$f['id']] = ['name' => $f['name'], 'slug' => $f['pslug'], 'qty' => (int)$f['qty'], 'dried' => $f['dried'], 'shape' => $f['look'][0], 'tint' => $f['look'][1], 'dtint' => flower_dried_tint($f['look'][1])];
    }
    $vessels = [];
    foreach (VESSELS as $k => [$vn, $cap, $sl]) {
        [$bk, $fr] = flower_vessel_parts($k);
        $vessels[$k] = ['name' => $vn, 'cap' => $cap, 'slots' => $sl, 'back' => $bk, 'front' => $fr, 'mouthW' => ['jar' => 12, 'vase' => 14, 'basket' => 26][$k]];
    }
    $shapes = [];
    foreach (FLOWER_SHAPES as $sh) $shapes[$sh] = flower_svg_inner($sh);
    $sprigInner = [];
    foreach (FLOWER_SPRIGS as $sp) $sprigInner[$sp] = flower_svg_inner($sp);
    $data = ['v' => 'vase', 'mouth' => CANVAS_MOUTH_Y, 'slots' => SLOT_POS, 'vessels' => $vessels, 'shapes' => $shapes, 'sprigs' => FLOWER_SPRIGS, 'sprigInner' => $sprigInner, 'px' => flower_pixel_data(),
        'preview' => url('arrange.php?t=preview'), 'min' => max(1, (int)setting('arrange_min_stems')), 'flowers' => $flowers];
    $ctxLocal = arrange_ctx($u);
  ?>
  <script type="application/json" id="arrdata"><?= json_encode($data, JSON_HEX_TAG | JSON_HEX_AMP | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?></script>
  <form method="post" id="arrform" action="<?= e(url('arrange.php')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="arrange">
    <div id="arrhidden"></div>
    <div class="arrgrid">
      <section class="box arrstage">
        <div class="arrvessels" role="group" aria-label="Vessel">
          <?php foreach (VESSELS as $k => [$vn, $cap]): ?>
            <button type="button" class="arrvessel" data-v="<?= e($k) ?>" aria-pressed="<?= $k === 'vase' ? 'true' : 'false' ?>"><?= e($vn) ?> <small><?= $cap ?> stems</small></button>
          <?php endforeach; ?>
        </div>
        <svg id="arrcanvas" class="flsvg-full arrcanvas" xmlns="http://www.w3.org/2000/svg" viewBox="-30 -4 260 262" role="group" aria-label="Your arrangement"><?= arrangement_inner(['v' => 'vase', 's' => []]) ?></svg>
        <p class="arrcount"><b id="arrcount">0 / 7 stems</b> · <span id="arrhint" class="help">Tap a flower to add it. Tap a numbered spot first to choose where it goes.</span></p>
        <noscript>
          <p class="help">Without JavaScript, choose a vessel and a flower for each spot:</p>
          <label>Vessel <select name="v"><?php foreach (VESSELS as $k => [$vn, $cap]): ?><option value="<?= e($k) ?>"><?= e($vn) ?> (<?= $cap ?>)</option><?php endforeach; ?></select></label>
          <?php foreach (SLOT_POS as $sl => $_): ?>
            <label>Spot <?= $sl + 1 ?> <select name="slot[<?= $sl ?>]"><option value="0">(empty)</option><?php foreach ($stock as $f): ?><option value="<?= (int)$f['id'] ?>"><?= e($f['name']) ?> (<?= (int)$f['qty'] ?>)</option><?php endforeach; ?></select></label>
          <?php endforeach; ?>
        </noscript>
        <div class="arrbtns"><button type="button" class="btn alt small" id="arrclear">Clear</button> <button class="btn" id="arrmake" disabled>💐 Make it · ⚡<?= (int)setting('arrange_energy') ?></button></div>
      </section>
      <section class="box arrside">
        <h2>Score</h2>
        <div id="arrscore" aria-live="polite"><p class="muted">Your score shows here once you have <?= (int)$data['min'] ?> stems.</p></div>
        <p class="help">Rarest flower in the top middle, colours that sit together, three kinds and an even left and right score best. The stems are used up.</p>
      </section>
    </div>
    <h2>Your flowers</h2>
    <div class="arrstock">
      <?php foreach ($stock as $f): ?>
        <button type="button" class="arrtile" data-id="<?= (int)$f['id'] ?>" title="<?= e($f['name']) ?>"><span class="iicon"><?= item_icon($f, 'lg') ?></span><span class="iname"><?= e($f['name']) ?></span><b class="arrq iqty"><?= (int)$f['qty'] ?></b><?= $f['dried'] ? '<span class="tag">dried</span>' : '' ?></button>
      <?php endforeach; ?>
    </div>
  </form>
  <script src="<?= e(url('assets/arrange.js?v=' . APP_VERSION)) ?>" defer></script>
  <?php endif; ?>

<?php elseif ($tab === 'dry'):
    $cuts = array_values(array_filter(flower_stock($uid), fn($f) => !$f['dried']));
    $racks = dry_list($uid);
    $maxRacks = (int)setting('dry_racks'); ?>
  <section class="box">
    <h2>🪢 Drying rack</h2>
    <p class="help">Hang cut flowers upside down and they dry into everlastings in <?= e(nice_time(max(1, (int)setting('dry_hours')) * 3600)) ?> of real time, even while you are away. Dried flowers never wilt, sell for a bit more and look lovely in an arrangement.
      Bundles hung: <?= count($racks) ?> of <?= $maxRacks ?> (up to <?= (int)setting('dry_per_rack') ?> stems each).</p>
    <?php if ($racks): ?>
    <ul class="arrlist">
      <?php foreach ($racks as $r): ?>
        <li><span class="iicon"><?= item_icon(['id' => $r['item_id']] + $r, 'md') ?></span> <b><?= (int)$r['qty'] ?> × <?= e($r['name']) ?></b>
          <?php if ($r['left'] > 0): ?><span class="muted">⏳ <?= e(nice_time((int)$r['left'])) ?> to go</span>
          <?php else: ?>
            <form method="post" action="<?= e(url('arrange.php')) ?>" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="dry_collect"><input type="hidden" name="rack" value="<?= (int)$r['id'] ?>"><button class="btn small">🌾 Collect</button></form>
          <?php endif; ?></li>
      <?php endforeach; ?>
    </ul>
    <?php if ($dryReady > 1): ?><form method="post" action="<?= e(url('arrange.php')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="dry_all"><button class="btn small alt">Collect all that are dry</button></form><?php endif; ?>
    <?php else: ?><p class="muted">Nothing is hanging yet.</p><?php endif; ?>
  </section>
  <section class="box">
    <h2>Hang a bundle</h2>
    <?php if (!$cuts): ?><p class="muted">You have no cut flowers. Harvest some, buy them at a florist or volunteer at one.</p>
    <?php elseif (count($racks) >= $maxRacks): ?><p class="muted">The rack is full. Collect a dry bundle first.</p>
    <?php else: ?>
    <form method="post" action="<?= e(url('arrange.php')) ?>" class="arrdryform"><?= csrf_field() ?><input type="hidden" name="do" value="dry">
      <label>Flower <select name="item_id"><?php foreach ($cuts as $f): ?><option value="<?= (int)$f['id'] ?>"><?= e($f['name']) ?> (<?= (int)$f['qty'] ?>)</option><?php endforeach; ?></select></label>
      <label>How many <input type="number" name="qty" value="1" min="1" max="<?= (int)setting('dry_per_rack') ?>"></label>
      <button class="btn">Hang to dry</button>
    </form>
    <?php endif; ?>
  </section>

<?php elseif ($tab === 'packets'):
    $mine = packet_choices($uid);
    $perDay = (int)setting('packets_per_day');
    $made = flower_daily_count($uid, 'packet');
    $n = max(1, (int)setting('packet_seeds')); ?>
  <section class="box">
    <h2>📦 Seed packets</h2>
    <p class="help">Master a flower (full knowledge, from growing it) and you can pack its seeds: <?= $n ?> seeds and <?= money((int)setting('packet_fee')) ?> for the paper make a packet to sell, trade or give away. Whoever opens it gets the seeds.
      You packed <?= $made ?> of <?= $perDay ?> today.</p>
    <?php if (!$mine): ?><p class="muted">You haven’t mastered a flower yet. Keep growing and harvesting the same one; its page in your Almanac shows your knowledge.</p>
    <?php else: ?>
    <div class="scroll"><table class="grid">
      <tr><th>Flower</th><th>Seeds</th><th></th></tr>
      <?php foreach ($mine as $m): ?>
        <tr><td data-l="Flower"><span class="iicon"><?= flower_packet_svg(flower_look((string)$m['slug']), 'md', $m['name']) ?></span> <b><?= e($m['name']) ?></b></td>
          <td data-l="Seeds"><?= (int)$m['seeds'] ?></td>
          <td><form method="post" action="<?= e(url('arrange.php?t=packets')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="packet"><input type="hidden" name="plant_id" value="<?= (int)$m['id'] ?>">
            <button class="btn small" <?= (int)$m['seeds'] >= $n && $made < $perDay ? '' : 'disabled' ?>>Pack a packet</button></form></td></tr>
      <?php endforeach; ?>
    </table></div>
    <?php endif; ?>
    <p class="help">Open a packet from your Satchel (Seeds tab).</p>
  </section>

<?php elseif ($tab === 'show'):
    $week = job_period_key('weekly');
    $mineEntry = q_one('SELECT * FROM arrangement_entries WHERE week = ? AND user_id = ?', [$week, $uid]);
    $owned = arrangements_owned($uid);
    require_once __DIR__ . '/includes/townsfolk.php';
    $leaders = array_slice(townsfolk_merge(arrangement_leaders($week, 5), townsfolk_arrangements($week), 'score'), 0, 7);   // v1.0.0: townsfolk show too (never judged, never paid)
    $pz = arr_prizes();
    $prevWeek = job_period_key('weekly', time() - 7 * 86400);
    $prev = arrangement_leaders($prevWeek, 3); ?>
  <section class="box">
    <h2>🎗️ The Arrangements show</h2>
    <p class="help">Each week the show judges the best arrangement entered. The top three win <?= money($pz[0]) ?>, <?= money($pz[1]) ?> and <?= money($pz[2]) ?> and a ribbon; everyone else who enters gets <?= money($pz[3]) ?>.
      One entry each. The arrangement you enter <b>stays at the show</b>, and a better one swaps in (the old one comes home). Judging in <?= e(nice_time(job_period_left('weekly'))) ?>.</p>
    <?php if ($mineEntry): ?><p>Your entry: <b>“<?= e($mineEntry['title']) ?>”</b>, <?= (int)$mineEntry['score'] ?>/100</p><?php endif; ?>
    <?php if (!$owned): ?><p class="muted">You have no arrangements. <a href="<?= e(url('arrange.php')) ?>">Make one</a>.</p>
    <?php else: ?>
    <div class="arrowned">
      <?php foreach ($owned as $a): $better = !$mineEntry || (int)$a['arr']['score'] > (int)$mineEntry['score']; ?>
        <form method="post" action="<?= e(url('arrange.php?t=show')) ?>" class="arrcard"><?= csrf_field() ?><input type="hidden" name="do" value="enter"><input type="hidden" name="item_id" value="<?= (int)$a['id'] ?>">
          <?= arrangement_svg($a['arr'], 'lg', $a['name']) ?><b><?= e($a['name']) ?></b><small><?= (int)$a['arr']['score'] ?>/100 · <?= (int)$a['qty'] ?> held</small>
          <button class="btn small" <?= $better ? '' : 'disabled' ?>><?= $mineEntry ? ($better ? 'Swap it in' : 'Not better') : 'Enter it' ?></button></form>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>
  </section>
  <section class="box">
    <h2>This week’s leaders</h2>
    <?php if (!$leaders): ?><p class="muted">No entries yet. Be the first!</p>
    <?php else: ?><ol class="arrleaders"><?php foreach ($leaders as $l): ?>
      <li><?= $l['npc'] ? '<span class="tficon sm" aria-hidden="true">🏡</span>' : arrangement_svg(json_decode((string)$l['comp'], true) ?: [], 'md', $l['title']) ?> <span><b><?= e($l['gname']) ?></b><?= $l['npc'] ? ' ' . townsfolk_tag() : '' ?>: “<?= e($l['title']) ?>”, <?= (int)$l['score'] ?>/100</span></li>
    <?php endforeach; ?></ol>
    <?php if (array_filter($leaders, fn($l) => $l['npc'])) echo townsfolk_note(); ?><?php endif; ?>
    <?php if ($prev): ?><h3>Last week’s winners</h3><ul><?php foreach ($prev as $i => $l): ?><li><?= ['🥇', '🥈', '🥉'][$i] ?? '' ?> <?= e($l['gname']) ?>: “<?= e($l['title']) ?>” (<?= (int)$l['score'] ?>)</li><?php endforeach; ?></ul><?php endif; ?>
  </section>

<?php else:   // florists
    $act = florist_active($uid);
    $shops = florist_shops();
    $left = florist_shifts_left($uid); ?>
  <section class="box">
    <h2>🌷 Florists</h2>
    <p class="help">Florists sell cut flowers. Volunteer for <?= max(1, (int)setting('florist_minutes')) ?> minutes on a florist’s shop page for XP, friendship and a bundle of cut flowers. <?= $left ?> shift<?= $left === 1 ? '' : 's' ?> left today.</p>
    <?php if ($act): ?>
      <p><b><?= $act['left'] > 0 ? '⏳ Shift at ' . e($act['shop_name']) . ': ' . e(nice_time((int)$act['left'])) . ' to go.' : '✅ Your shift at ' . e($act['shop_name']) . ' is over.' ?></b></p>
      <?php if ($act['left'] <= 0): ?><form method="post" action="<?= e(url('arrange.php?t=florists')) ?>"><?= csrf_field() ?><input type="hidden" name="do" value="flo_collect"><input type="hidden" name="shift" value="<?= (int)$act['id'] ?>"><button class="btn">🎁 Collect your thanks</button></form><?php endif; ?>
    <?php endif; ?>
    <ul class="arrlist">
      <?php foreach ($shops as $s): ?>
        <li><b><a href="<?= e(url('shop.php?id=' . (int)$s['id'])) ?>"><?= e($s['name']) ?></a></b> <span class="muted">in <?= e((string)($s['town'] ?? '')) ?></span><br><span class="help"><?= e($s['description']) ?></span></li>
      <?php endforeach; ?>
      <?php if (!$shops): ?><li class="muted">No florists have opened yet.</li><?php endif; ?>
    </ul>
  </section>
<?php endif; ?>
<?php page_footer();
