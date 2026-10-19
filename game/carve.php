<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/contests.php';
require_once __DIR__ . '/includes/games.php';   // v1.4.1: game tabs
$u = require_login();
$uid = (int)$u['id'];
settle_carving();

if (is_post()) {
    csrf_check();
    [$ok, $msg] = match ((string)($_POST['do'] ?? '')) {
        'carve' => carve_save($u, array_flip(array_map('intval', array_keys((array)($_POST['c'] ?? [])))), (string)($_POST['title'] ?? '')),
        'vote' => carve_vote($u, (int)($_POST['id'] ?? 0)),
        default => [false, 'Unknown action.'],
    };
    flash($msg, $ok ? 'ok' : 'err');
    redirect('carve.php');
}

$open = carving_open();
$year = carving_year();
$mine = q_one('SELECT * FROM carvings WHERE user_id = ? AND year = ?', [$uid, $year]);
$entries = q('SELECT c.*, COALESCE(u.gnome_name, u.username) AS gname, (SELECT 1 FROM carving_votes v WHERE v.carving_id = c.id AND v.user_id = ?) AS voted
              FROM carvings c JOIN users u ON u.id = c.user_id WHERE c.year = ? AND ' . gnome_in_play_sql('u') . ' ORDER BY c.votes DESC, c.carved_at LIMIT 60', [$uid, $year])->fetchAll();
require_once __DIR__ . '/includes/townsfolk.php';
$entries = townsfolk_merge($entries, $open ? townsfolk_carvings($year, $entries ? (int)max(array_column($entries, 'votes')) : 0) : [], 'votes');   // v1.0.0: townsfolk carve too (never voted on, never paid)
$pumpkins = (int)q_val("SELECT ui.qty FROM user_items ui JOIN plants p ON p.produce_item_id = ui.item_id WHERE ui.user_id = ? AND p.slug = 'pumpkin'", [$uid]);
page_header('Pumpkin Carving');
?>
<h1>🎃 Pumpkin Carving</h1>
<p class="help"><a href="<?= e(url('games.php?tab=contests')) ?>">← Contests</a></p>
<?= game_tabs_html('carve.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    $cm = date('F', mktime(0, 0, 0, (int)setting('carving_month'), 1));
    echo game_rules_html([
        ['🎯', 'Goal.', 'Carve a pumpkin face that the Hollow loves best.'],
        ['📅', 'When.', 'Every ' . $cm . '. Prizes are paid when the month is over.'],
        ['🔪', 'Carving.', 'Tap squares to cut them out, add a name, and put it on show. Cut at least 3 squares.'],
        ['🎃', 'One pumpkin.', 'Carving uses up a pumpkin. Grow one, buy one, or ask a friend.'],
        ['🔁', 'One each.', 'Carving again replaces your old pumpkin and its votes.'],
        ['🗳️', 'Voting.', 'Vote once for each carving you like. Not your own.'],
        ['🏆', 'Prizes.', 'Top three: ' . money(1500) . ', ' . money(800) . ' and ' . money(400) . ', plus a 🎀 ribbon. Everyone else who carved gets ' . money(50) . '.'],
    ]);
    echo '<p><a href="' . e(url('games.php?tab=contests')) . '">← Contests</a></p>';
    page_footer(); return;
endif; ?>
<?php if (!$open): ?>
  <div class="box notice">The carving contest runs every <?= e(date('F', mktime(0, 0, 0, (int)setting('carving_month'), 1))) ?>. Grow some pumpkins ready for it!</div>
<?php else: ?>
  <div class="box">
    <p class="gtagline">Carve a face, name it, put it on show. You have <?= $pumpkins ?> pumpkin<?= $pumpkins === 1 ? '' : 's' ?>.</p>
    <form method="post" class="carveform"><?= csrf_field() ?><input type="hidden" name="do" value="carve">
      <div class="pumpkin big">
        <?php for ($i = 0; $i < CARVE_SIZE * CARVE_SIZE; $i++): $on = $mine && $mine['pattern'][$i] === '1'; ?>
          <input type="checkbox" name="c[<?= $i ?>]" id="c<?= $i ?>" value="1" <?= $on ? 'checked' : '' ?>><label for="c<?= $i ?>" aria-label="Square <?= $i + 1 ?>"></label>
        <?php endfor; ?>
      </div>
      <label>Name <input name="title" maxlength="40" value="<?= e((string)($mine['title'] ?? '')) ?>" placeholder="Grinning Gourd"></label>
      <button class="btn" <?= $pumpkins ? '' : 'disabled' ?>>🔪 Carve it!</button>
    </form>
  </div>
<?php endif; ?>
<?php if ($entries): ?>
  <h2>On show (<?= count(array_filter($entries, fn($x) => !$x['npc'])) ?> gnomes<?= array_filter($entries, fn($x) => $x['npc']) ? ' and some townsfolk' : '' ?>)</h2>
  <div class="carvings">
    <?php foreach ($entries as $c): ?>
      <div class="box carving">
        <?= carving_html((string)$c['pattern']) ?>
        <b><?= e($c['title']) ?></b><?= $c['npc'] ? '' : report_link((int)$c['user_id'], 'carving', (int)$c['id']) ?><br><span class="muted">by <?= $c['npc'] ? e($c['gname']) . ' ' . townsfolk_tag() : profile_link(['id' => $c['user_id']], (string)$c['gname']) ?> · <?= (int)$c['votes'] ?> vote<?= (int)$c['votes'] === 1 ? '' : 's' ?></span>
        <?php if ($c['placed']): ?><span class="tag">#<?= (int)$c['placed'] ?></span><?php endif; ?>
        <?php if ($c['npc']): ?>
        <?php elseif ($open && (int)$c['user_id'] !== $uid && !$c['voted']): ?>
          <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="vote"><input type="hidden" name="id" value="<?= (int)$c['id'] ?>"><button class="btn small">🗳️ Vote</button></form>
        <?php elseif ($c['voted']): ?><span class="muted">✔ voted</span><?php endif; ?>
      </div>
    <?php endforeach; ?>
  </div>
  <?php if (array_filter($entries, fn($x) => $x['npc'])) echo townsfolk_note(); ?>
<?php endif; ?>
<p><a href="<?= e(url('games.php?tab=contests')) ?>">← Contests</a></p>
<?php page_footer();
