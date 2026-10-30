<?php
declare(strict_types=1);
/** The Gourmand: Pomeroy Crumbworth, the travelling food writer. Serve him a plate, a pot or a jar for spoons. Tabs: now, journal, menu, how it works. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/world.php';
require_once __DIR__ . '/includes/friends.php';
require_once __DIR__ . '/includes/npc_life.php';
require_once __DIR__ . '/includes/gourmand.php';
$u = require_login();
$uid = (int)$u['id'];
if (!gourmand_open()) {
    flash('That page isn’t open yet.', 'err');
    redirect('world.php');
}
$TABS = ['now' => '🍽️ Now', 'journal' => '📓 Journal', 'menu' => '📜 Menu', 'howto' => '❓ How it works'];
$tab = array_key_exists((string)($_GET['t'] ?? ''), $TABS) ? (string)$_GET['t'] : 'now';
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'serve') [$ok, $msg] = gourmand_serve($u, (string)($_POST['course'] ?? ''));
    elseif ($do === 'home') [$ok, $msg] = gourmand_serve_home($u, (string)($_POST['dish'] ?? ''));
    elseif ($do === 'seat') [$ok, $msg] = gourmand_seat($u);
    else [$ok, $msg] = [false, 'Unknown action.'];
    flash($msg, $ok ? 'ok' : 'err');
    redirect('gourmand.php?t=now');
}
$npc = q_one("SELECT * FROM npcs WHERE traveller = 'gourmand'");
$beats = gourmand_beats($u);   // plays the finale once, at the first meeting after the 14th Taste
$stop = gourmand_stop();
$tour = $stop['tour'];
$day = (int)hollow_date('j', gourmand_now());
$prog = gourmand_progress($uid);
$ledger = gourmand_ledger($uid);
$code = gourmand_here($u);
$R = gourmand_rows()['R'];
$names = fn(array $menu) => array_column(q('SELECT slug, name FROM items WHERE slug IN (' . implode(',', array_fill(0, max(1, count($menu)), '?')) . ')', array_values(array_map(fn($r) => $r['item'], $menu)) ?: [''])->fetchAll(), 'name', 'slug');
$spoons = fn(int $n) => str_repeat('🥄', $n) . str_repeat('▫️', 3 - $n);
$tl = fn(string $t) => e(url('gourmand.php' . ($t === 'now' ? '' : '?t=' . $t)));
page_header('The Gourmand');
?>
<h1>🥄 The Gourmand</h1>
<?php if (setting('gourmand_open') !== '1'): ?><p class="help">🛠️ Closed to players: only admins can see this page.</p><?php endif; ?>
<nav class="tabs">
  <?php foreach ($TABS as $k => $label): ?><a class="<?= $tab === $k ? 'on' : '' ?>" href="<?= $tl($k) ?>"><?= e($label) ?><?= $k === 'journal' ? ' <small>' . (int)$prog['tastes'] . '/14</small>' : '' ?></a><?php endforeach; ?>
</nav>

<?php if ($tab === 'now'): ?>
<div class="box">
  <div class="npchead"><div class="npcpic"><?= npc_portrait($npc ?: ['name' => 'Pomeroy Crumbworth', 'species' => 'Dormouse', 'slug' => 'pomeroy-crumbworth']) ?></div>
    <div class="npcid">
      <h2>🐭 Pomeroy Crumbworth</h2>
      <p class="muted">Fussy dormouse · travelling food writer</p>
      <p>📍 <?= e($R[$stop['code']]['line'] ?? ('Pomeroy is in ' . $stop['town'] . '.')) ?>
        <?php if (!empty($stop['festival'])): ?><br>🎪 It’s the festival here today: your friendship with him grows twice as fast, and his tips are bigger.<?php endif; ?></p>
      <p class="help">His camp moves with the festivals, but he’ll take a course from you any day, wherever you are in a region.<?php if ($npc): ?> <a href="<?= e(url('villagers.php?id=' . (int)$npc['id'])) ?>">Chat with him →</a><?php endif; ?></p>
    </div></div>
  <?php if ($beats): $b = end($beats); ?><p class="story"><b><?= e($b['title']) ?></b><br><?= e(str_replace('{gnome}', (string)($u['gnome_name'] ?: $u['username']), $b['text'])) ?></p><?php endif; ?>
</div>

<?php if ($code === ''): ?>
<section class="box">
  <h2>🪑 The Long Table</h2>
  <?php if ($stop['long_table']): $prev = gourmand_prev_tour($tour); $nSeat = (int)q_val("SELECT COUNT(*) FROM traveller_deals WHERE user_id = ? AND npc_id = ? AND stop LIKE ? AND stop <> ?", [$uid, gourmand_npc_id(), $prev . '|%', $prev . '|LT|seat']);
        $took = (bool)q_val('SELECT 1 FROM traveller_deals WHERE user_id = ? AND npc_id = ? AND stop = ?', [$uid, gourmand_npc_id(), $prev . '|LT|seat']); ?>
    <p>It’s the first of the month, and Pomeroy has laid the Long Table on the Green. “Sit, sit. There’s always a second spoon at this table.”</p>
    <p class="help">Last month you served <b><?= $nSeat ?></b> course<?= $nSeat === 1 ? '' : 's' ?> (a seat takes <?= GOURMAND_SEAT_MIN ?>).</p>
    <?php if ($took): ?><p class="good">🪑 You have your seat this month.</p>
    <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="seat"><button class="btn gold"<?= $nSeat >= GOURMAND_SEAT_MIN ? '' : ' disabled' ?>>🪑 Take a seat</button></form><?php endif; ?>
  <?php else: ?>
    <p>Mossbottom has no menu. The Long Table is laid on the first of every month, for gnomes who fed Pomeroy last month. Out in the regions he takes your plates, pots and jars any day.</p>
  <?php endif; ?>
</section>
<?php else:
    $menu = gourmand_menu($code, $tour); $nm = $names($menu); ?>
<section class="box">
  <h2>🍽️ This month in <?= e(gourmand_region_name($code)) ?></h2>
  <p class="help">One of each course a month. Quality is the average of the stack you hold. Spoons: <?= GOURMAND_BARS['plate'][0] ?> / <?= GOURMAND_BARS['plate'][1] ?> / <?= GOURMAND_BARS['plate'][2] ?> (jars <?= implode(' / ', gourmand_bars('jar', (string)($menu['jar']['item'] ?? ''))) ?>).</p>
  <?php foreach (GOURMAND_COURSES as $course => [$ic, $label, $what]): $row = $menu[$course] ?? null; if (!$row) continue;
        [$item, $have, $q, $sp, $loose] = gourmand_preview($uid, $row); $done = gourmand_served_this_tour($uid, $code, $course, $tour); $mine = $ledger[$code][$course] ?? null; ?>
    <div class="box inset">
      <h3><?= $ic ?> <?= e($label) ?> <small class="muted"><?= e($what) ?></small> <span title="Your best here"><?= $spoons((int)($mine['spoons'] ?? 0)) ?></span></h3>
      <p>“<?= e($row['ask']) ?>”</p>
      <p>He wants <b><?= (int)$row['qty'] ?> × <?= e($nm[$row['item']] ?? $row['item']) ?></b>.
        <?php if ($have < (int)$row['qty']): ?>You have <?= (int)$have ?>.
        <?php else: ?>Your <?= e($nm[$row['item']] ?? $row['item']) ?>: <?= (int)$have ?> held, quality <?= (int)$q ?> → <?= $sp ? e($spoons($sp) . ' (' . gourmand_word($sp) . ')') : 'not enough for a spoon' ?>.<?php endif; ?></p>
      <?php if ($loose > 0 && $have >= (int)$row['qty'] && $sp < 3): ?><p class="help">Older or bought ones are dragging this down. A fresh harvest scores higher.</p><?php endif; ?>
      <?php if ($done): ?><p class="good">✔️ Served this month. Back next month.</p>
      <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="serve"><input type="hidden" name="course" value="<?= e($course) ?>">
        <button class="btn"<?= $have >= (int)$row['qty'] && $sp > 0 ? '' : ' disabled' ?>>🥄 Serve it</button></form><?php endif; ?>
    </div>
  <?php endforeach; ?>
  <?php if (!empty($menu['grand'])): $row = $menu['grand']; $nmG = $names($menu); [$item, $have, $q, $sp, $loose] = gourmand_preview($uid, $row);
        $done = gourmand_served_this_tour($uid, $code, 'grand', $tour); $mine = $ledger[$code]['grand'] ?? null;
        $kit = user_building_bonus($uid, 'kitchen')['best']; $taste = isset($ledger[$code]['table']); ?>
    <div class="box inset">
      <h3><?= GOURMAND_GRAND[0] ?> <?= e(GOURMAND_GRAND[1]) ?> <small class="muted"><?= e(GOURMAND_GRAND[2]) ?></small> <span title="Your best here"><?= $spoons((int)($mine['spoons'] ?? 0)) ?></span><?= isset($ledger[$code]['grandpay']) ? ' 🥄' : '' ?></h3>
      <p>“<?= e($row['ask']) ?>”</p>
      <p>He wants <b><?= (int)$row['qty'] ?> × <?= e($nmG[$row['item']] ?? $row['item']) ?></b>, cooked in a Kitchen at level III.</p>
      <?php if ($kit < 3): ?><p class="help">🔒 A feast needs a Kitchen at level III.</p>
      <?php elseif (!$taste): ?><p class="help">🔒 He sits down to a feast after your first Taste of <?= e(gourmand_region_name($code)) ?>: a plate, a pot and a jar.</p>
      <?php else: ?>
        <?php if ($have < (int)$row['qty']): ?><p>You have <?= (int)$have ?>.</p>
        <?php else: ?><p>Your <?= e($nmG[$row['item']] ?? $row['item']) ?>: quality <?= (int)$q ?> → <?= $sp ? e($spoons($sp) . ' (' . gourmand_word($sp) . ')') : 'not enough for a spoon' ?>.</p><?php endif; ?>
        <?php if (!isset($ledger[$code]['grandpay'])): ?><p class="help">The first feast here pays <?= money(GOURMAND_GRAND_PAY[0]) ?> and <?= GOURMAND_GRAND_PAY[1] ?> XP, once.</p><?php endif; ?>
        <?php if ($done): ?><p class="good">✔️ Served this month. Back next month.</p>
        <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="serve"><input type="hidden" name="course" value="grand">
          <button class="btn gold"<?= $have >= (int)$row['qty'] && $sp > 0 ? '' : ' disabled' ?>>🍽️ Serve the feast</button></form><?php endif; ?>
      <?php endif; ?>
    </div>
  <?php endif; ?>
</section>
<?php endif; ?>

<?php if ((int)$prog['tastes'] >= GOURMAND_HOME_TASTES): $homeCode = gourmand_home_code($u); ?>
<section class="box">
  <h2>🏡 The Home Plate</h2>
  <?php if (gourmand_home_done($uid)): ?><p class="good">🏡 You have shown Pomeroy the cooking of your home.</p>
  <?php elseif ($homeCode === ''): ?><p class="help">You have no home village to cook for.</p>
  <?php else: $opts = gourmand_home_options($u); ?>
    <p>Pomeroy wants a cooked dish made with a crop of <?= e(gourmand_region_name($homeCode)) ?>, at <?= GOURMAND_BARS['pot'][1] ?> quality or better (🥄🥄). Serve it from anywhere. <?= money(GOURMAND_HOME_PAY[0]) ?> and <?= GOURMAND_HOME_PAY[1] ?> XP, once in your life.</p>
    <?php if (!$opts): ?><p class="help">You hold no such dish yet.</p>
    <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="home">
      <select name="dish"><?php foreach ($opts as $o): ?><option value="<?= e($o['slug']) ?>"><?= e($o['name']) ?> (<?= (int)$o['held'] ?> held, quality <?= (int)$o['q'] ?><?= $o['spoons'] >= 2 ? '' : ', too low' ?>)</option><?php endforeach; ?></select>
      <button class="btn gold">🏡 Serve the Home Plate</button></form><?php endif; ?>
  <?php endif; ?>
</section>
<?php endif; ?>

<?php elseif ($tab === 'journal'): ?>
<section class="box">
  <h2>📓 Pomeroy’s journal</h2>
  <p><b>Tastes <?= (int)$prog['tastes'] ?>/14</b> · Spoons <?= (int)$prog['spoons'] ?>/<?= (int)$prog['spoons_max'] ?> · Golden tables <?= (int)$prog['gold'] ?> · Grand <?= (int)$prog['grand'] ?>/<?= (int)$prog['grand_max'] ?></p>
  <p class="help">A Taste is a region where you have served him a plate, a pot and a jar. Fourteen Tastes finish his story.</p>
  <?php foreach ($beats as $b): ?><p class="story"><b><?= e($b['title']) ?></b><br><?= e(str_replace('{gnome}', (string)($u['gnome_name'] ?: $u['username']), $b['text'])) ?></p><?php endforeach; ?>
  <?php if ($beats && (int)$prog['tastes'] >= 7): ?><p class="story">🥄 A second spoon is laid at his table now.</p><?php endif; ?>
</section>
<div class="gcards gcards--2">
<?php foreach ($R as $rc => $r): if ($rc === GOURMAND_HUB_CODE) continue; $town = gourmand_region_name($rc); $got = isset($ledger[$rc]['table']); $gold = isset($ledger[$rc]['gold']); $menuJ = gourmand_menu($rc, $tour); ?>
  <div class="box">
    <h3><?= TOWN_FESTIVALS[$town][1] ?? '🍽️' ?> <?= e($town) ?> <?= $gold ? '🏅' : '' ?></h3>
    <p><?= $got ? '<b>' . e(ucfirst($r['taste'])) . '</b>' : '<span class="muted">A Taste still to find</span>' ?></p>
    <ul class="plain">
    <?php foreach (GOURMAND_COURSES as $course => [$ic, $label]): $m = $ledger[$rc][$course] ?? null; ?>
      <li><?= $ic ?> <?= e($label) ?>: <?= $spoons((int)($m['spoons'] ?? 0)) ?><?= $m ? ' <small class="muted">best ' . (int)$m['best_q'] . '</small>' : '' ?>
        <?php if ($m && !empty($menuJ[$course]['note'])): ?><br><small class="muted">“<?= e($menuJ[$course]['note']) ?>”</small><?php endif; ?></li>
    <?php endforeach; ?>
      <?php if (!empty($menuJ['grand'])): $gm = $ledger[$rc]['grand'] ?? null; ?><li><?= GOURMAND_GRAND[0] ?> <?= e(GOURMAND_GRAND[1]) ?>: <?= $spoons((int)($gm['spoons'] ?? 0)) ?><?= isset($ledger[$rc]['grandpay']) ? ' 🥄 <small class="muted">gold spoon</small>' : '' ?></li><?php endif; ?>
    </ul>
  </div>
<?php endforeach; ?>
</div>

<?php elseif ($tab === 'menu'): ?>
<section class="box">
  <h2>📜 This month’s menu</h2>
  <p class="help">The menu turns over on the first of the month<?= $day >= 20 ? ', and next month’s is below' : '' ?>. Serve in the region itself.</p>
  <?php foreach (array_values(array_filter([$tour, $day >= 20 ? (new DateTimeImmutable($tour . '-01 12:00:00', hollow_tz()))->modify('+1 month')->format('Y-m') : null])) as $tr): $first = $tr === $tour; ?>
    <h3><?= $first ? 'This month' : 'Next month' ?> <small class="muted">(<?= e($tr) ?>)</small></h3>
    <?php foreach (gourmand_itinerary($tr) as $w): $town = $w['town']; $mc = $w['code']; $menu = gourmand_menu($mc, $tr); if (!$menu) { ?>
      <p>🪑 <b><?= e($town) ?></b> · day <?= (int)$w['from'] ?>: the Long Table (a seat for gnomes who fed him <?= GOURMAND_SEAT_MIN ?>+ courses last month).</p>
      <?php continue; } $nm = $names($menu); ?>
      <p><?= TOWN_FESTIVALS[$town][1] ?? '' ?> <b><?= e($town) ?></b> · camp days <?= (int)$w['from'] ?>–<?= (int)$w['to'] ?>
        <br><small>
        <?php foreach (GOURMAND_COURSES + ['grand' => GOURMAND_GRAND] as $course => [$ic]): if (empty($menu[$course])) continue; ?><?= $ic ?> <?= (int)$menu[$course]['qty'] ?> × <?= e($nm[$menu[$course]['item']] ?? $menu[$course]['item']) ?> &nbsp;<?php endforeach; ?></small></p>
    <?php endforeach; ?>
  <?php endforeach; ?>
</section>

<?php else: ?>
<section class="box">
  <h2>❓ How it works</h2>
  <p>Pomeroy Crumbworth is a dormouse food writer who lost his sense of taste in fourteen pieces, one to every region. Feed him and it comes back.</p>
  <ul>
    <li><b>Three courses a region.</b> A <b>Plate</b> is a raw crop (judged by its harvest quality), a <b>Pot</b> is a cooked dish (judged by how well it was cooked) and a <b>Jar</b> is a Pantry preserve. He names what he wants each month.</li>
    <li><b>Anywhere in the region, any day.</b> Stand in the region and serve it here. He moves to a new camp with each festival, but his table is always open. From level <?= GOURMAND_LEVEL ?>.</li>
    <li><b>Spoons.</b> 🥄 Honest, 🥄🥄 Seconds, please, 🥄🥄🥄 Splendid. Quality is the average of the stack you hold, so keep your best apart: shop-bought and old goods drag it down, and a plain stack earns no spoon at all.</li>
    <li><b>Once a month per course.</b> The first time you earn each spoon on a course you are paid (<?= GOURMAND_FIRST[1][0] ?> / <?= GOURMAND_FIRST[2][0] ?> / <?= GOURMAND_FIRST[3][0] ?> Petals). Serving it again in a later month earns a <?= GOURMAND_TIP[0] ?> Petal tip.</li>
    <li><b>A Taste</b> is a region with all three courses served: <?= GOURMAND_TABLE ?> Petals and two seeds of its plate crop. Three splendid courses in one region make a golden table: <?= GOURMAND_GOLD ?> Petals and a rare seed.</li>
    <li><b>Festival day.</b> On a region’s festival day, a serve there doubles your friendship with Pomeroy and his tip experience. You do not need to be at his camp.</li>
    <li><b>The Grand course.</b> Eight regions have a feast. With a Kitchen at level III and your first Taste of the region, you can serve him its feast (judged like a pot): <?= money(GOURMAND_GRAND_PAY[0]) ?> and <?= GOURMAND_GRAND_PAY[1] ?> XP the first time, a tip after. All eight earns the title Grand Diner.</li>
    <li><b>The Home Plate.</b> At <?= GOURMAND_HOME_TASTES ?> Tastes he asks for the cooking of your home: one cooked dish made with a crop of your home region, at two spoons or better, served from anywhere. Once only.</li>
    <li><b>The Long Table.</b> On the first of the month, a gnome who served <?= GOURMAND_SEAT_MIN ?> courses or more last month can take a seat for <?= money(50) ?> and a charm boost.</li>
    <li><b>Fourteen Tastes</b> finish his story. Come back and sit down when you get there.</li>
  </ul>
  <p class="help">Your Journal tab keeps every spoon you have earned.</p>
</section>
<?php endif; ?>
