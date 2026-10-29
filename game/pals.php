<?php
declare(strict_types=1);
/** v1.0.0 wave 3: gnome friends: your friends, requests, finding a gnome, and who you have blocked. Seedling gifts go from here. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/pals.php';
$u = require_login();
$uid = (int)$u['id'];

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $id = (int)($_POST['id'] ?? 0);
    $back = safe_back('pals.php');
    switch ($do) {
        case 'request': [$ok, $msg] = pal_request($u, $id); break;
        case 'accept': [$ok, $msg] = pal_answer($u, $id, 'accept'); break;
        case 'decline': [$ok, $msg] = pal_answer($u, $id, 'decline'); break;
        case 'cancel': [$ok, $msg] = pal_cancel($u, $id); break;
        case 'remove': [$ok, $msg] = pal_remove($u, $id); break;
        case 'block': [$ok, $msg] = pal_block($u, $id); break;
        case 'unblock': [$ok, $msg] = pal_unblock($u, $id); break;
        case 'pm_request': require_once __DIR__ . '/includes/mentors120.php'; [$ok, $msg] = mentors120_request($u, $id); $back = safe_back('pals.php?tab=mentor'); break;
        case 'pm_accept': require_once __DIR__ . '/includes/mentors120.php'; [$ok, $msg] = mentors120_answer($u, $id, 'accept'); $back = safe_back('pals.php?tab=mentor'); break;
        case 'pm_decline': require_once __DIR__ . '/includes/mentors120.php'; [$ok, $msg] = mentors120_answer($u, $id, 'decline'); $back = safe_back('pals.php?tab=mentor'); break;
        case 'pm_cancel': require_once __DIR__ . '/includes/mentors120.php'; [$ok, $msg] = mentors120_cancel($u, $id); $back = safe_back('pals.php?tab=mentor'); break;
        case 'pm_end': require_once __DIR__ . '/includes/mentors120.php'; [$ok, $msg] = mentors120_end($u, $id); $back = safe_back('pals.php?tab=mentor'); break;
        case 'pm_open': require_once __DIR__ . '/includes/mentors120.php'; [$ok, $msg] = mentors120_set_open($u, !empty($_POST['open'])); $back = safe_back('pals.php?tab=mentor'); break;
        case 'pulse': [$ok, $msg] = pal_set_pulse($uid, !empty($_POST['pulse_show'])); $back = 'pals.php'; break;
        case 'gift': [$ok, $msg] = pal_gift($u, $id, (int)($_POST['item_id'] ?? 0), (int)($_POST['qty'] ?? 1), (string)($_POST['note'] ?? '')); break;
        case 'find':
            require_once __DIR__ . '/includes/trade.php';
            $f = find_player((string)($_POST['name'] ?? ''), $uid, false);   // v1.0.0: by gnome name only, so log-in names can't be confirmed
            if ($f) redirect('profile.php?id=' . (int)$f['id']);
            [$ok, $msg] = [false, 'No gnome by that name. Type their gnome name exactly.'];
            $back = 'pals.php?tab=find';
            break;
        default: [$ok, $msg] = [false, 'Unknown action.'];
    }
    flash($msg, $ok ? 'ok' : 'err');
    redirect($back);
}

$tab = in_array($_GET['tab'] ?? '', ['friends', 'requests', 'find', 'blocked', 'mentor'], true) ? (string)$_GET['tab'] : 'friends';
$incoming = pal_requests_in($uid);
$outgoing = pal_requests_out($uid);
if ($tab === 'friends' && $incoming && !isset($_GET['tab'])) $tab = 'requests';
$friends = $tab === 'friends' ? pal_list($uid) : [];
$tl = fn(string $t) => e(url('pals.php?tab=' . $t));
page_header('Gnome friends');
?>
<h1>🤝 Gnome friends</h1>
<p class="help">Friends can send each other a seed or seedling once a day, and their names sit together here. Sign the guestbook of any open garden. No chat, only little signs that you were there.</p>
<nav class="tabs">
  <a class="<?= $tab === 'friends' ? 'on' : '' ?>" href="<?= $tl('friends') ?>">🤝 Gnome friends <small><?= pal_count($uid) ?></small></a>
  <a class="<?= $tab === 'requests' ? 'on' : '' ?>" href="<?= $tl('requests') ?>">📨 Requests<?= $incoming ? ' <small>' . count($incoming) . '</small>' : '' ?></a>
  <a class="<?= $tab === 'find' ? 'on' : '' ?>" href="<?= $tl('find') ?>">🔎 Find a gnome</a>
  <a class="<?= $tab === 'mentor' ? 'on' : '' ?>" href="<?= $tl('mentor') ?>">🎓 Gnome mentor</a>
  <a class="<?= $tab === 'blocked' ? 'on' : '' ?>" href="<?= $tl('blocked') ?>">🚫 Blocked</a>
</nav>

<?php if ($tab === 'friends'): ?>
  <div class="box"><h2>Who’s about</h2>
    <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="pulse">
      <label><input type="checkbox" name="pulse_show" value="1"<?= (int)($u['pulse_show'] ?? 1) === 1 ? ' checked' : '' ?>> Show me in Who’s about when I’m about</label>
      <p class="help">Only gnomes with an open garden are ever named. Turn this off and you are counted as a “quiet gnome” instead.</p>
      <button class="btn small">Save</button></form>
  </div>
  <?php if (!$friends): ?>
    <div class="box"><p>No gnome friends yet.</p>
      <p class="help">Open another gnome’s profile (tap a name on the <a href="<?= e(url('community.php?t=about')) ?>">Together page</a>, in Garden of the Month or in a contest) and press <b>Add friend</b>.</p></div>
  <?php else:
      $gifts = pal_giftable($uid); $giftOn = setting('friend_gifts_on') === '1'; ?>
    <div class="palgrid">
    <?php foreach ($friends as $f): $sentToday = pal_gift_sent_today($uid, (int)$f['id']); ?>
      <div class="box palcard">
        <div class="palhead"><div><b><a href="<?= e(url('profile.php?id=' . (int)$f['id'])) ?>"><?= e($f['name']) ?></a></b>
          <small class="muted">level <?= (int)$f['level'] ?> · about <?= e($f['about']) ?></small></div></div>
        <p class="palacts">
          <?php if ($f['plot_id']): ?><a class="btn small" href="<?= e(url('visit.php?g=' . $f['plot_id'])) ?>">🏡 Visit garden</a><?php else: ?><span class="muted">🔒 Garden is private</span><?php endif; ?>
          <a class="btn small ghost" href="<?= e(url('profile.php?id=' . (int)$f['id'])) ?>">Profile</a>
        </p>
        <?php if ($giftOn): ?>
          <details class="palgift"><summary>🎁 Send a seedling</summary>
            <?php if ($sentToday): ?><p class="help">You’ve sent them something today. Tomorrow!</p>
            <?php elseif (!$gifts): ?><p class="help">You have no seeds or seedlings to give. Raise saplings from mastered plants, or buy seeds.</p>
            <?php else: ?>
              <form method="post" class="palform"><?= csrf_field() ?><input type="hidden" name="do" value="gift"><input type="hidden" name="id" value="<?= (int)$f['id'] ?>">
                <label>What <select name="item_id"><?php foreach ($gifts as $g): ?><option value="<?= (int)$g['id'] ?>"><?= e($g['name']) ?> (<?= (int)$g['qty'] ?>)</option><?php endforeach; ?></select></label>
                <label>How many <select name="qty"><option>1</option><option>2</option><option>3</option></select></label>
                <label>Note <select name="note"><?php foreach (PAL_GIFT_NOTES as $k => $t): ?><option value="<?= e($k) ?>"><?= e($t) ?></option><?php endforeach; ?></select></label>
                <button class="btn small">Send</button>
              </form>
            <?php endif; ?>
          </details>
        <?php endif; ?>
      </div>
    <?php endforeach; ?>
    </div>
  <?php endif; ?>

<?php elseif ($tab === 'requests'): ?>
  <div class="box"><h2>Asked to be your friend</h2>
    <?php if (!$incoming): ?><p class="muted">Nobody is waiting.</p><?php endif; ?>
    <?php foreach ($incoming as $r): ?>
      <div class="palreq"><span><b><a href="<?= e(url('profile.php?id=' . (int)$r['from_id'])) ?>"><?= e($r['name']) ?></a></b> <small class="muted">level <?= (int)$r['level'] ?></small></span>
        <span class="palbtns">
          <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="accept"><input type="hidden" name="id" value="<?= (int)$r['from_id'] ?>"><input type="hidden" name="back" value="pals.php?tab=requests"><button class="btn small">Accept</button></form>
          <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="decline"><input type="hidden" name="id" value="<?= (int)$r['from_id'] ?>"><input type="hidden" name="back" value="pals.php?tab=requests"><button class="btn small ghost">Not now</button></form>
        </span></div>
    <?php endforeach; ?>
  </div>
  <div class="box"><h2>Waiting for an answer</h2>
    <?php if (!$outgoing): ?><p class="muted">No requests out.</p><?php endif; ?>
    <?php foreach ($outgoing as $r): ?>
      <div class="palreq"><span><b><a href="<?= e(url('profile.php?id=' . (int)$r['to_id'])) ?>"><?= e($r['name']) ?></a></b></span>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="cancel"><input type="hidden" name="id" value="<?= (int)$r['to_id'] ?>"><input type="hidden" name="back" value="pals.php?tab=requests"><button class="btn small ghost">Take it back</button></form></div>
    <?php endforeach; ?>
  </div>

<?php elseif ($tab === 'find'): ?>
  <div class="box"><h2>Find a gnome</h2>
    <p class="help">Type a gnome’s name exactly. You’ll land on their profile, where <b>Add friend</b> is.</p>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="find"><label>Name <input name="name" maxlength="40" required autocomplete="off"></label> <button class="btn small">Look</button></form>
  </div>

<?php elseif ($tab === 'mentor'): require_once __DIR__ . '/includes/mentors120.php'; ?>
  <p class="help">Gnome mentors are other players. For your calling’s teacher, see <a href="<?= e(url('gnome.php?tab=calling')) ?>">My calling</a>.</p>
  <?= mentors120_tab_html($u) ?>

<?php else: $blocked = pal_blocked_list($uid); ?>
  <div class="box"><h2>Blocked gnomes</h2>
    <p class="help">A blocked gnome can’t send you requests, guestbook signs, gifts or trade offers, and isn’t told. You can unblock them any time.</p>
    <?php if (!$blocked): ?><p class="muted">Nobody blocked.</p><?php endif; ?>
    <?php foreach ($blocked as $b): ?>
      <div class="palreq"><span><?= e($b['name']) ?></span>
        <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="unblock"><input type="hidden" name="id" value="<?= (int)$b['id'] ?>"><input type="hidden" name="back" value="pals.php?tab=blocked"><button class="btn small ghost">Unblock</button></form></div>
    <?php endforeach; ?>
  </div>
<?php endif; ?>
<?php page_footer();
