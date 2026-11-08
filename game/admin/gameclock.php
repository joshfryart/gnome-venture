<?php
declare(strict_types=1);
// 2.6.27: where is each player on the game clock, and what did they do last. Read-only, admins only.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/action_log.php';
$me = require_admin();

$uid = (int)($_GET['u'] ?? 0);
page_header('Game clocks', true);
admin_crumbs('gameclock.php');

if ($uid > 0) {
    $p = q('SELECT id, username, game_day, game_minute, last_seen FROM users WHERE id = ?', [$uid])->fetch();
    if (!$p) { echo '<p>No such player.</p>'; page_footer(); exit; }
    $rows = [];
    try { $rows = q('SELECT * FROM player_actions WHERE user_id = ? ORDER BY id DESC LIMIT ' . ACTION_LOG_KEEP, [$uid])->fetchAll(); } catch (Throwable $e) {}
    ?>
    <h1>Last <?= (int)ACTION_LOG_KEEP ?> actions: <?= e($p['username']) ?></h1>
    <p><a href="<?= e(url('admin/gameclock.php')) ?>">← All players</a></p>
    <table class="grid">
      <tr><th>Real time (UTC)</th><th>Game day</th><th>Game time</th><th>Page</th><th>What was sent</th></tr>
      <?php foreach ($rows as $r): ?>
        <tr><td><?= e($r['at']) ?></td>
          <td><?= $r['game_day'] === null ? '–' : (int)$r['game_day'] ?></td>
          <td><?= $r['game_minute'] === null ? '–' : e(action_log_hhmm((int)$r['game_minute'])) ?></td>
          <td><?= e($r['page']) ?></td><td class="details"><?= e($r['what']) ?></td></tr>
      <?php endforeach; ?>
      <?php if (!$rows): ?><tr><td colspan="5">Nothing logged yet (or run Upgrade database).</td></tr><?php endif; ?>
    </table>
    <?php
    page_footer();
    exit;
}

$sort = ($_GET['sort'] ?? 'day') === 'seen' ? 'last_seen DESC' : 'game_day DESC, game_minute DESC';
$players = q("SELECT id, username, role, game_day, game_minute, last_seen, banned FROM users WHERE guest = 0 ORDER BY $sort LIMIT 500")->fetchAll();
$cnt = [];
try { foreach (q('SELECT user_id, COUNT(*) n, MAX(at) last FROM player_actions GROUP BY user_id')->fetchAll() as $c) $cnt[(int)$c['user_id']] = $c; } catch (Throwable $e) {}
?>
<h1>Game clocks</h1>
<p class="help">Each player's own game day and time (day 0 = season start). Click a name for their last <?= (int)ACTION_LOG_KEEP ?> actions. Only admins can see this.</p>
<p>Sort: <a href="<?= e(url('admin/gameclock.php?sort=day')) ?>">game day</a> · <a href="<?= e(url('admin/gameclock.php?sort=seen')) ?>">last seen</a></p>
<table class="grid">
  <tr><th>Player</th><th>Game day</th><th>Game date</th><th>Game time</th><th>State</th><th>Last seen (UTC)</th><th>Logged actions</th><th>Last action (UTC)</th></tr>
  <?php foreach ($players as $pl):
      $st = gclock_state($pl); ?>
    <tr><td><a href="<?= e(url('admin/gameclock.php?u=' . (int)$pl['id'])) ?>"><?= e($pl['username']) ?></a><?= $pl['role'] !== 'player' ? ' (' . e($pl['role']) . ')' : '' ?><?= $pl['banned'] ? ' 🚫' : '' ?></td>
      <td><?= (int)$st['day'] ?></td><td><?= e($st['date']) ?></td><td><?= e(action_log_hhmm((int)$st['minute'])) ?></td>
      <td><?= $st['tired'] ? 'tired (after 22:00)' : 'rested' ?></td>
      <td><?= e((string)$pl['last_seen']) ?></td>
      <td><?= (int)($cnt[(int)$pl['id']]['n'] ?? 0) ?></td><td><?= e((string)($cnt[(int)$pl['id']]['last'] ?? '')) ?></td></tr>
  <?php endforeach; ?>
</table>
<?php page_footer();
