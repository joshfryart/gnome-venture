<?php
declare(strict_types=1);
// v2.0.3: usage counts. How much is each feature really used by real players? Read-only. Decides what to cut or merge.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();

$now = time();
$D7 = 7 * 86400;
$cut_dt = gmdate('Y-m-d H:i:s', $now - $D7); // datetime columns (UTC)
$cut_day = gmdate('Y-m-d', $now - $D7);      // day columns (Y-m-d)
$cut_30 = gmdate('Y-m-d H:i:s', $now - 30 * 86400);

// Players only: no admins, mods or banned. Same rule as Retention.
$PLAYERS = "SELECT id FROM users WHERE banned = 0 AND role NOT IN ('admin','mod')";

/**
 * Feature list. [label, table, user column, time column or '', time kind dt|day].
 * No time column = totals only (the 7-day columns show a dash).
 */
$groups = [
    'Tasks & requests' => [
        ['Daily/weekly/monthly jobs', 'user_jobs', 'user_id', '', ''],
        ['Posted jobs (player to player)', 'player_jobs', 'poster_id', '', ''],
        ['Townsfolk orders done', 'npc_orders', 'user_id', 'done_at', 'dt'],
        ['Favours done', 'npc_favours', 'user_id', 'done_at', 'dt'],
        ['Rest stop errands', 'stop_errands', 'user_id', 'created_at', 'dt'],
        ['Journey (quest chapters)', 'user_quests', 'user_id', 'started_at', 'dt'],
        ['Calling tasks done', 'user_calling_tasks', 'user_id', 'done_at', 'dt'],
        ['Hollow Goal claims', 'hollow_goal_claims', 'user_id', 'claimed_at', 'dt'],
        ['First Week claims', 'first_week_claims', 'user_id', 'claimed_at', 'dt'],
        ['Daily card (days seen)', 'daily_ticks', 'user_id', 'day', 'day'],
    ],
    'Helpers & social' => [
        ['Hired garden help', 'garden_hires', 'user_id', 'started_at', 'dt'],
        ['Helper side of hires', 'garden_hires', 'helper_id', 'started_at', 'dt'],
        ['Helping water', 'garden_waterings', 'helper_id', 'created_at', 'dt'],
        ['Gifts sent', 'gifts', 'from_id', 'sent_at', 'dt'],
        ['Friend requests', 'player_friends', 'user_id', 'created_at', 'dt'],
        ['Player mentor links', 'pmentor_links', 'newcomer_id', 'created_at', 'dt'],
        ['Trade offers', 'trade_offers', 'from_id', 'created_at', 'dt'],
        ['Stall listings', 'stall_listings', 'seller_id', 'listed_at', 'dt'],
        ['Community garden log', 'community_log', 'user_id', 'at', 'dt'],
    ],
    'Villagers & places' => [
        ['Rest stop log (visits, acts)', 'stop_log', 'user_id', 'at', 'dt'],
        ['Stop villager friendships', 'stop_friend', 'user_id', 'last_talk', 'dt'],
        ['Named NPC friendships', 'npc_friends', 'user_id', '', ''],
        ['Adopted stops', 'stop_adoptions', 'user_id', 'adopted_at', 'dt'],
        ['Landmark uses', 'landmark_uses', 'user_id', 'at', 'dt'],
        ['Town action uses', 'town_uses', 'user_id', 'day', 'day'],
        ['Local deals (stops)', 'local_deals', 'user_id', 'at', 'dt'],
        ['Traveller deals', 'traveller_deals', 'user_id', 'at', 'dt'],
    ],
    'Buying & selling' => [
        ['Market day buys', 'market_buys', 'user_id', 'day', 'day'],
        ['Curio buys', 'curio_buys', 'user_id', '', ''],
        ['Dye pot / skins owned', 'sink_owned', 'user_id', 'at', 'dt'],
        ['Festival stall buys', 'festival_buys', 'user_id', '', ''],
    ],
    'Contests' => [
        ['Harvest Fair entries', 'fair_entries', 'user_id', 'at', 'dt'],
        ['Village Show entries', 'show_entries', 'user_id', 'entered_at', 'dt'],
        ['Garden of the Month entries', 'gotm_entries', 'user_id', 'entered_at', 'dt'],
        ['Pumpkin carvings', 'carvings', 'user_id', 'carved_at', 'dt'],
        ['Guess the Weight', 'marrow_guesses', 'user_id', 'at', 'dt'],
        ['Snail Race bets', 'snail_bets', 'user_id', 'placed_at', 'dt'],
    ],
    'Adventuring' => [
        ['Road walks and wanders', 'expeditions', 'user_id', '', ''],
        ['Treks started (admins excluded)', 'trek_runs', 'user_id', '', ''],
    ],
];

/** Counts for one feature. Returns null when the table or column is missing (e.g. old install). */
$count = function (string $table, string $ucol, string $tcol, string $kind) use ($PLAYERS, $cut_dt, $cut_day): ?array {
    try {
        $in = "$ucol IN ($PLAYERS)";
        $all = q("SELECT COUNT(*) AS n, COUNT(DISTINCT $ucol) AS u FROM $table WHERE $in")->fetch();
        $out = ['n' => (int)$all['n'], 'u' => (int)$all['u'], 'n7' => null, 'u7' => null];
        if ($tcol !== '') {
            $cut = $kind === 'day' ? $cut_day : $cut_dt;
            $w = q("SELECT COUNT(*) AS n, COUNT(DISTINCT $ucol) AS u FROM $table WHERE $in AND $tcol >= ?", [$cut])->fetch();
            $out['n7'] = (int)$w['n'];
            $out['u7'] = (int)$w['u'];
        }
        return $out;
    } catch (Throwable $e) {
        return null;
    }
};

// Player base.
$total = (int)q_val("SELECT COUNT(*) FROM users WHERE banned = 0 AND role NOT IN ('admin','mod')");
$act7 = (int)q_val("SELECT COUNT(*) FROM users WHERE banned = 0 AND role NOT IN ('admin','mod') AND last_seen >= ?", [$cut_dt]);
$act30 = (int)q_val("SELECT COUNT(*) FROM users WHERE banned = 0 AND role NOT IN ('admin','mod') AND last_seen >= ?", [$cut_30]);

// Mini-games: per game plays, players, last 7 days.
$games = [];
try {
    $games = q("SELECT game, COUNT(*) AS n, COUNT(DISTINCT user_id) AS u,
                   SUM(CASE WHEN played_at >= ? THEN 1 ELSE 0 END) AS n7
                FROM game_scores WHERE user_id IN ($PLAYERS) GROUP BY game ORDER BY n DESC", [$cut_dt])->fetchAll();
    foreach ($games as &$g) {
        $g['u7'] = (int)q_val("SELECT COUNT(DISTINCT user_id) FROM game_scores WHERE game = ? AND played_at >= ? AND user_id IN ($PLAYERS)", [$g['game'], $cut_dt]);
    }
    unset($g);
} catch (Throwable $e) {
    $games = [];
}

$rows = [];
foreach ($groups as $gname => $list) {
    foreach ($list as [$label, $table, $ucol, $tcol, $kind]) {
        $rows[] = [$gname, $label, $table, $count($table, $ucol, $tcol, $kind)];
    }
}

if (($_GET['export'] ?? '') === 'csv') {
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="usage-' . gmdate('Y-m-d', $now) . '.csv"');
    $out = fopen('php://output', 'w');
    fwrite($out, "\xEF\xBB\xBF");
    fputcsv($out, ['Group', 'Feature', 'Table', 'Rows', 'Players', 'Rows 7d', 'Players 7d']);
    foreach ($rows as [$g, $l, $t, $c]) {
        fputcsv($out, [$g, $l, $t, $c['n'] ?? '', $c['u'] ?? '', $c['n7'] ?? '', $c['u7'] ?? '']);
    }
    foreach ($games as $g) {
        fputcsv($out, ['Mini-games', (string)$g['game'], 'game_scores', $g['n'], $g['u'], $g['n7'], $g['u7']]);
    }
    fclose($out);
    exit;
}

$cell = fn($v) => $v === null ? '–' : number_format((int)$v);
$pct = fn(int $n, int $d) => $d > 0 ? round($n * 100 / $d) . '%' : '–';

page_header('Usage', true);
?>
<?php admin_crumbs('usage.php'); ?>
<h1>📊 Usage</h1>
<p><a class="btn small" href="<?= e(url('admin/usage.php?export=csv')) ?>" download>⬇️ Export (CSV)</a></p>
<p class="help">What real players use. Admins, moderators and banned players are left out. Use this before you cut or merge anything. “–” = the table keeps no date, so only totals exist.</p>

<div class="box">
  <h2>Players</h2>
  <table class="grid">
    <tr><th>Signed up</th><th>Seen in 7 days</th><th>Seen in 30 days</th></tr>
    <tr><td><?= number_format($total) ?></td><td><?= number_format($act7) ?> <small class="help"><?= e($pct($act7, $total)) ?></small></td><td><?= number_format($act30) ?> <small class="help"><?= e($pct($act30, $total)) ?></small></td></tr>
  </table>
  <p class="help">With only a few players, a “0” is weak proof. Check again with more people before you delete.</p>
</div>

<?php
$by = [];
foreach ($rows as $r) $by[$r[0]][] = $r;
foreach ($by as $gname => $list): ?>
<div class="box">
  <h2><?= e($gname) ?></h2>
  <table class="grid">
    <tr><th>Feature</th><th>Rows</th><th>Players</th><th>Rows 7d</th><th>Players 7d</th></tr>
    <?php foreach ($list as [$g, $label, $table, $c]): ?>
      <tr<?= $c !== null && $c['n'] === 0 ? ' class="muted"' : '' ?>>
        <td><?= e($label) ?></td>
        <?php if ($c === null): ?>
          <td colspan="4"><small class="help">no data (table missing)</small></td>
        <?php else: ?>
          <td><?= $cell($c['n']) ?></td><td><?= $cell($c['u']) ?></td><td><?= $cell($c['n7']) ?></td><td><?= $cell($c['u7']) ?></td>
        <?php endif; ?>
      </tr>
    <?php endforeach; ?>
  </table>
</div>
<?php endforeach; ?>

<div class="box">
  <h2>Mini-games</h2>
  <?php if (!$games): ?>
    <p class="help">No plays yet.</p>
  <?php else: ?>
  <table class="grid">
    <tr><th>Game</th><th>Plays</th><th>Players</th><th>Plays 7d</th><th>Players 7d</th></tr>
    <?php foreach ($games as $g): ?>
      <tr><td><?= e((string)$g['game']) ?></td><td><?= $cell($g['n']) ?></td><td><?= $cell($g['u']) ?></td><td><?= $cell($g['n7']) ?></td><td><?= $cell($g['u7']) ?></td></tr>
    <?php endforeach; ?>
  </table>
  <p class="help">Only games that log a score show here. Games with no score row (for example Snail Race, Guess the Weight) are in Contests above.</p>
  <?php endif; ?>
</div>
