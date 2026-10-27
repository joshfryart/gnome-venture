<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/world.php';
require_once __DIR__ . '/includes/friends.php';
require_once __DIR__ . '/includes/npc_life.php';
$u = require_login();
$uid = (int)$u['id'];
if (!is_post()) redirect('villagers.php' . (isset($_GET['id']) ? '?id=' . (int)$_GET['id'] : ''));   // v2.0.39: the Villagers page replaces this one
if (!isset($_GET['id'])) {   // v2.0.4 menu folds: the list of villagers you know lives on Town (town.php?view=villagers); keep the old search/filter links working
    $keep = array_filter(['q' => (string)($_GET['q'] ?? ''), 'f' => (string)($_GET['f'] ?? ''), 'r' => (string)($_GET['r'] ?? '')], fn($v) => $v !== '');
    redirect('town.php?view=villagers&known=1' . ($keep ? '&' . http_build_query($keep) : '') . '#known');
}
$npc = q_one('SELECT * FROM npcs WHERE id = ? AND active = 1', [(int)($_GET['id'] ?? 0)]);
if (!$npc) {
    flash('Nobody by that name lives here.', 'err');
    redirect('world.php');
}
$nid = (int)$npc['id'];

if (is_post()) {
    csrf_check();
    [$ok, $msg] = match ((string)($_POST['do'] ?? '')) {
        'talk' => npc_talk($u, $nid),
        'gift' => npc_gift($u, $nid, (int)($_POST['item_id'] ?? 0)),
        'deal' => traveller_deal($u, $nid),
        default => [false, 'Unknown action.'],
    };
    flash($msg, $ok ? 'ok' : 'err');
    redirect('folk.php?id=' . $nid . (($_POST['tab'] ?? '') === 'tastes' ? '&tab=tastes' : ''));
}

$f = friendship($uid, $nid);
$lvl = friend_level((int)$f['points']);
$here = npc_here($u, $nid);
if ($here) { require_once __DIR__ . '/includes/folk_list.php'; npc_meet($uid, [$nid]); }   // v0.7.69
$today = hollow_date('Y-m-d');   // v0.7.85: same Hollow day as the chat and gift limits
$work = q('SELECT DISTINCT sh.id, sh.name FROM npc_schedules s JOIN shops sh ON sh.id = s.shop_id WHERE s.npc_id = ?', [$nid])->fetchAll();
$giftable = q("SELECT i.*, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
               WHERE ui.user_id = ? AND ui.qty > 0 AND i.tradable = 1 AND i.category <> 'tool' ORDER BY i.name", [$uid])->fetchAll();
$tab = in_array($_GET['tab'] ?? '', ['tastes'], true) ? (string)$_GET['tab'] : 'about';   // v0.7.61: tabs
$now = npc_now($npc);
$favSpot = $npc['fav_spot_id'] ? q_one('SELECT * FROM town_spots WHERE id = ?', [$npc['fav_spot_id']]) : null;
$tastes = known_tastes($f, $npc);
$tl = fn(string $t) => e(url('folk.php?id=' . $nid . ($t === 'about' ? '' : '&tab=' . $t)));
page_header($npc['name']);
?>
<p class="crumbs">👤 <a href="<?= e(url('town.php?view=villagers#known')) ?>">Villagers you know</a> › <b><?= e($npc['name']) ?></b></p>
<?php
// v0.7.73: the gift picker; v2.0.67: item squares, shared with the Villagers panel (gift_picker_html in includes/friends.php)
$bdayNow = npc_birthday_today($npc);
$giftPick = $here && $f['last_gift'] !== $today && $giftable ? gift_picker_html($npc, $f, $giftable, $bdayNow) : '';
$bar = $lvl['next'] ? max(0, min(100, (int)round(100 * (int)$f['points'] / max(1, (int)$lvl['next'][0])))) : 100;
?>
<div class="npchead box">
  <div class="npcpic">
    <?= npc_portrait($npc) ?>
    <div class="fondbar" title="Fondness">
      <div class="fbtrack"><span class="fbfill w<?= (int)(round($bar / 5) * 5) ?>"></span></div>
      <small>💛 <b><?= e($lvl['name']) ?></b><?= $lvl['next'] ? ' · ' . (int)$f['points'] . '/' . (int)$lvl['next'][0] . ' to ' . e($lvl['next'][1]) : ' · best of friends' ?><?= $lvl['discount'] ? ' · 🏷️ ' . (int)$lvl['discount'] . '% off' : '' ?></small>
    </div>
    <details class="fondmore"><summary>Friendship ladder</summary>
      <ul class="ladder"><?php foreach (FRIEND_LEVELS as $i => $L): ?><li class="<?= $i <= $lvl['index'] ? 'done' : '' ?>"><?= $i <= $lvl['index'] ? '✔' : '·' ?> <?= e($L[1]) ?><?= $L[2] ? ' <small class="muted">(' . (int)$L[2] . '% off)</small>' : '' ?></li><?php endforeach; ?></ul>
      <p class="help">💬 Chat once a day and 🎁 give a gift once a day<?= $favSpot ? '; chats at their favourite place count double' : '' ?>. Friends give a discount in the shop where they work.</p>
    </details>
  </div>
  <div class="npcid">
    <h1><?= npc_icon($npc['species']) ?> <?= e($npc['name']) ?><?= $bdayNow ? ' 🎂' : '' ?></h1>
    <p class="muted"><?= e(trim($npc['personality'] . ' ' . strtolower((string)$npc['species']))) ?></p>
    <p>📍 <?= e($now['what']) ?><?= !empty($now['home']) && $now['town'] ? ' in ' . e($now['town']) : '' ?><?php if ($now['spot'] && $now['town']): ?> · <a href="<?= e(url('town.php?' . ($now['town'] === HUB_REGION ? 'hub=1&' : '') . 'spot=' . (int)$now['spot']['id'])) ?>">go there</a><?php endif; ?></p>
    <?php if ($here): ?>
      <?php if (!empty($now['home'])): ?><p class="help">🚪 You knocked, and <?= e($npc['name']) ?> asks you in.</p><?php endif; ?>
      <div class="npcacts">
        <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="talk">
          <button class="btn" <?= $f['last_talk'] === $today ? 'disabled' : '' ?>>💬 <?= $f['last_talk'] === $today ? 'Chatted today' : 'Chat' ?></button></form>
        <?php if ($f['last_gift'] === $today): ?><button class="btn alt" disabled>🎁 Gift given today</button>
        <?php elseif (!$giftable): ?><button class="btn alt" disabled title="Nothing in your Satchel to give">🎁 Nothing to give</button>
        <?php else: ?><button type="button" class="btn alt" data-giftopen="1">🎁 Give a gift</button><?php endif; ?>
      </div>
      <?php if ($here && $npc['traveller'] && ($offer = traveller_offer($npc))): ?>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="deal">
          <button class="btn small" <?= traveller_dealt($uid, $npc) ? 'disabled' : '' ?>><?= e($offer['label']) ?><?= traveller_dealt($uid, $npc) ? ' (done this visit)' : '' ?></button></form>
      <?php endif; ?>
    <?php else: ?><p class="help">Not anywhere you can reach right now. Find them in town or knock when they’re home.</p><?php endif; ?>
  </div>
</div>
<?php if ($bdayNow): ?><p class="bday">🎂 It’s <?= e($npc['name']) ?>’s birthday today! A gift counts three times as much.</p><?php endif; ?>
<?= $giftPick ?>

<nav class="tabs">
  <a class="<?= $tab === 'about' ? 'on' : '' ?>" href="<?= $tl('about') ?>">📖 About</a>
  <a class="<?= $tab === 'tastes' ? 'on' : '' ?>" href="<?= $tl('tastes') ?>">🎁 Likes &amp; dislikes <small><?= count($tastes) ?>/4</small></a>
</nav>

<?php if ($tab === 'about'): ?>
<div class="box npcday">
  <?php if ($npc['bio']): ?><p><?= e($npc['bio']) ?></p><?php endif; ?>
  <?php if ($work): ?><p>🏪 Works at <?= implode(', ', array_map(fn($w) => '<a href="' . e(url('shop.php?id=' . (int)$w['id'])) . '">' . e($w['name']) . '</a>', $work)) ?><span class="help"> (you need to be in that town to shop)</span></p><?php endif; ?>
  <?php $hm = npc_home($npc); if ($hm): ?><p>🏡 Lives at <?= e($hm['name']) ?> in <?= e($hm['region']) ?>. Usually home <?= e(npc_home_hours($npc)) ?>.</p><?php endif; ?>
  <?php if ($lvl['index'] >= 1): ?><p>🎂 Birthday: <?= e(npc_birthday_text($npc)) ?></p><?php else: ?><p class="help">🎂 Birthday: get to know them better to find out.</p><?php endif; ?>
  <?php if ($favSpot): ?><p>💛 Favourite place: <?= e($favSpot['icon'] . ' ' . $favSpot['name']) ?> in <?= e($favSpot['region']) ?>. A chat there counts double.</p><?php endif; ?>
  <details><summary>🕰️ Their usual day <small class="muted">(Hollow time)</small></summary><ul><?php foreach (npc_routine($npc) as $line): ?><li><?= e($line) ?></li><?php endforeach; ?></ul></details>
</div>

<?php else: ?>
<div class="box">
  <?php if ($tastes): ?><ul class="tastelist"><?php foreach ($tastes as $t): ?><li><?= e($t) ?></li><?php endforeach; ?></ul>
  <?php else: ?><p class="muted">You don’t know what they like yet.</p><?php endif; ?>
  <p class="help">Everyone has one favourite thing, two kinds of thing they like, and one they’d rather not get. Give gifts to find out: <?= 4 - count($tastes) ?> still to discover.</p>
</div>
<?php endif; ?>
<?php page_footer();
