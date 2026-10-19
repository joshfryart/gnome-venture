<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/world.php';
require_once __DIR__ . '/includes/friends.php';
require_once __DIR__ . '/includes/npc_life.php';
$u = require_login();
$uid = (int)$u['id'];
if (!isset($_GET['id'])) {   // v0.7.52 / v0.7.69: everyone you've met, where they are now, with search and filters
    require_once __DIR__ . '/includes/maps.php';
    require_once __DIR__ . '/includes/folk_list.php';
    $all = met_npcs($uid);
    $qs = trim((string)($_GET['q'] ?? ''));
    $f = (string)($_GET['f'] ?? '');
    $reg = (string)($_GET['r'] ?? '');
    $regions = array_values(array_unique(array_filter(array_map(fn($n) => (string)($n['home']['region'] ?? ''), $all))));
    sort($regions);
    $list = array_filter($all, function ($n) use ($qs, $f, $reg, $u) {
        if ($qs !== '' && stripos($n['name'] . ' ' . $n['species'] . ' ' . $n['personality'], $qs) === false) return false;
        if ($f === 'here' && !npc_here($u, (int)$n['id'])) return false;
        if ($reg !== '' && ($n['home']['region'] ?? '') !== $reg) return false;
        return true;
    });
    $byLevel = [];
    foreach ($list as $n) $byLevel[$n['level']['index']][] = $n;
    krsort($byLevel);
    $total = (int)q_val('SELECT COUNT(*) FROM npcs WHERE active = 1');
    page_header('Villagers you know');
    ?>
    <h1>👥 Villagers you know</h1>
    <p class="help">Everyone you’ve met: <?= count($all) ?> of the Hollow’s <?= $total ?> villagers. You meet people by visiting their shop while they’re at the counter, finding them about town, or chatting and giving gifts. Their full pages are in your <a href="<?= e(url('book.php?ch=Folk')) ?>">Almanac → Villagers</a> too.</p>
    <form method="get" class="box folkfilter">
      <input type="search" name="q" value="<?= e($qs) ?>" placeholder="Search by name…" aria-label="Search by name">
      <select name="r" aria-label="Home region"><option value="">All regions</option><?php foreach ($regions as $rg): ?><option<?= $rg === $reg ? ' selected' : '' ?>><?= e($rg) ?></option><?php endforeach; ?></select>
      <label><input type="checkbox" name="f" value="here"<?= $f === 'here' ? ' checked' : '' ?>> Here now</label>
      <button class="btn small">Show</button><?php if ($qs !== '' || $f !== '' || $reg !== ''): ?> <a href="<?= e(url('folk.php')) ?>">Clear</a><?php endif; ?>
    </form>
    <?php if (!$all): ?><div class="box"><p class="muted">Nobody yet. Visit a shop or wander the town square to meet the locals.</p></div>
    <?php elseif (!$list): ?><div class="box"><p class="muted">Nobody matches that.</p></div><?php endif; ?>
    <?php foreach ($byLevel as $li => $group): ?>
      <h2 class="folkgroup">💛 <?= e(FRIEND_LEVELS[$li][1] ?? 'Stranger') ?> <small><?= count($group) ?></small></h2>
      <div class="box">
        <?php foreach ($group as $n): ?>
          <div class="folkrow">
            <a href="<?= e(url('folk.php?id=' . (int)$n['id'])) ?>"><?= npc_portrait($n, 'small') ?></a>
            <div><a href="<?= e(url('folk.php?id=' . (int)$n['id'])) ?>"><b><?= e($n['name']) ?></b></a> <small class="muted"><?= e(trim(strtolower((string)$n['personality'] . ' ' . (string)$n['species']))) ?><?= !empty($n['traveller']) ? ' · traveller' : '' ?></small>
              <br><small>📍 <?= e($n['now']['what']) ?><?= npc_here($u, (int)$n['id']) ? ' · <b class="good">here now</b>' : '' ?></small>
              <br><small class="muted">🏡 <?= $n['home'] ? e($n['home']['name'] . ' · ' . $n['home']['region']) : (!empty($n['traveller']) ? 'travels the Hollow' : '—') ?><?= npc_birthday_today($n) ? ' · 🎂 birthday today!' : '' ?></small></div>
          </div>
        <?php endforeach; ?>
      </div>
    <?php endforeach; ?>
    <?php
    echo '<details class="fold mapfold"><summary>🗺️ On the world map</summary><div class="mapwrap">' . world_map_svg($u) . '</div>'
        . '<p class="help">👤 marks a town where villagers you know (Acquaintance or better) are right now. 🎩 is you.</p></details>';
    page_footer();
    exit;
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
$giftable = q("SELECT i.id, i.name, i.category, i.effects, i.rarity, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
               WHERE ui.user_id = ? AND ui.qty > 0 AND i.tradable = 1 AND i.category <> 'tool' ORDER BY i.name", [$uid])->fetchAll();
$tab = in_array($_GET['tab'] ?? '', ['tastes'], true) ? (string)$_GET['tab'] : 'about';   // v0.7.61: tabs
$now = npc_now($npc);
$favSpot = $npc['fav_spot_id'] ? q_one('SELECT * FROM town_spots WHERE id = ?', [$npc['fav_spot_id']]) : null;
$tastes = known_tastes($f, $npc);
$tl = fn(string $t) => e(url('folk.php?id=' . $nid . ($t === 'about' ? '' : '&tab=' . $t)));
page_header($npc['name']);
?>
<p class="crumbs">👤 <a href="<?= e(url('folk.php')) ?>">Villagers you know</a> › <b><?= e($npc['name']) ?></b></p>
<?php
// v0.7.73: the gift picker — Satchel-style tiles, with the tastes you've found marked
$known = json_decode((string)($f['known'] ?? '[]'), true) ?: [];
$T = npc_tastes($npc);
$bdayNow = npc_birthday_today($npc);
$giftCards = '';
if ($here && $f['last_gift'] !== $today && $giftable) {
    require_once __DIR__ . '/includes/items.php';
    $IL = item_lookups();
    foreach ($giftable as $g) {
        $mark = ''; $score = 0;
        if ((int)$g['id'] === (int)$T['loved'] && in_array('loved', $known, true)) { $mark = '💛'; $score = 3; }
        elseif (in_array($g['category'], $T['liked'], true) && in_array('like:' . $g['category'], $known, true)) { $mark = '👍'; $score = 2; }
        elseif ($g['category'] === $T['disliked'] && in_array('dislike:' . $g['category'], $known, true)) { $mark = '👎'; $score = 0; }
        else $score = 1;
        [$rl, $rw] = item_rarity($g, $IL);
        $giftCards .= '<button type="button" class="pcard gcard" data-id="' . (int)$g['id'] . '" data-score="' . $score . '" data-cat="' . e((string)$g['category']) . '" data-name="' . e($g['name']) . '">'
            . '<i class="rar r' . $rl . '" title="' . e($rw) . '">' . $rl . '</i><span class="pcicon">' . item_icon($g) . '</span>'
            . '<span class="pcname">' . e($g['name']) . '</span><b class="pcqty">×' . (int)$g['qty'] . '</b>'
            . '<span class="pcinfo">' . e(GIFT_CATS[$g['category']] ?? (string)$g['category']) . ($mark ? ' <span class="gmark">' . $mark . '</span>' : '') . '</span></button>';
    }
}
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
<?php if ($giftCards !== ''): ?>
<dialog class="picker giftpick" aria-label="Choose a gift"><div class="pickbox">
  <div class="pickhead"><b>🎁 A gift for <?= e($npc['name']) ?></b><button type="button" class="pickx" aria-label="Close">✕</button></div>
  <nav class="chips gsort"><a href="#" class="on" data-gsort="like">They’ll like it</a><a href="#" data-gsort="cat">By kind</a><a href="#" data-gsort="name">A–Z</a></nav>
  <div class="pickgrid"><?= $giftCards ?></div>
  <form method="post" class="giftgo" hidden><?= csrf_field() ?><input type="hidden" name="do" value="gift"><input type="hidden" name="item_id" value="0">
    <span class="gname"></span> <button class="btn">🎁 Give it</button></form>
  <p class="help">💛 their favourite · 👍 a kind they like · 👎 one they’d rather not get. Marks appear once you’ve found out.<?= $bdayNow ? ' 🎂 Birthday: gifts count triple!' : '' ?></p>
</div></dialog>
<?php endif; ?>

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
