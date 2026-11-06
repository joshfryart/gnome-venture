<?php
declare(strict_types=1);
// v2.0.3: usage counts. How much is each feature really used by real players? Read-only. Decides what to cut or merge.
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();
stats_reset_handle('usage', 'usage.php');   // v2.4.94
$base = stats_baseline('usage');   // '' = never reset; else count only from then on
$snap = $base !== '' ? (json_decode((string)setting('stats_usage_snap'), true) ?: []) : [];

$now = time();
$D7 = 7 * 86400;
$cut_dt = gmdate('Y-m-d H:i:s', $now - $D7); // datetime columns (UTC)
$cut_day = gmdate('Y-m-d', $now - $D7);      // day columns (Y-m-d)
$cut_30 = gmdate('Y-m-d H:i:s', $now - 30 * 86400);

// Players only: no admins, mods or banned. Same rule as Retention.
$PLAYERS = "SELECT id FROM users WHERE banned = 0 AND guest = 0 AND role NOT IN ('admin','mod')";   // v2.0.75: guests are counted on their own line

/**
 * Feature list. [label, table, user column, time column or '', time kind dt|day].
 * No time column = totals only (the 7-day columns show a dash).
 */
$groups = usage_feature_list();

/** Counts for one feature. Returns null when the table or column is missing (e.g. old install). */
$count = function (string $table, string $ucol, string $tcol, string $kind) use ($PLAYERS, $cut_dt, $cut_day, $base, $snap): ?array {
    try {
        $in = "$ucol IN ($PLAYERS)";
        $from = $base === '' ? null : ($kind === 'day' ? substr($base, 0, 10) : $base);   // v2.4.94: after a reset, count only from then on
        $since = ($tcol !== '' && $from !== null) ? " AND $tcol >= " . db()->quote($from) : '';
        $all = q("SELECT COUNT(*) AS n, COUNT(DISTINCT $ucol) AS u FROM $table WHERE $in$since")->fetch();
        $out = ['n' => (int)$all['n'], 'u' => (int)$all['u'], 'n7' => null, 'u7' => null];
        if ($tcol === '' && $base !== '') {   // no date column: total now minus the total at the reset; the player count cannot be split
            $out['n'] = max(0, $out['n'] - (int)($snap[$table . '|' . $ucol] ?? 0));
            $out['u'] = null;
        }
        if ($tcol !== '') {
            $cut = $kind === 'day' ? $cut_day : $cut_dt;
            if ($from !== null && $from > $cut) $cut = $from;
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
$total = (int)q_val("SELECT COUNT(*) FROM users WHERE banned = 0 AND role NOT IN ('admin','mod') AND created_at >= ?", [$base]);
$act7 = (int)q_val("SELECT COUNT(*) FROM users WHERE banned = 0 AND role NOT IN ('admin','mod') AND last_seen >= ?", [$cut_dt]);
$act30 = (int)q_val("SELECT COUNT(*) FROM users WHERE banned = 0 AND role NOT IN ('admin','mod') AND last_seen >= ?", [$cut_30]);

// Mini-games: per game plays, players, last 7 days.
$games = [];
try {
    $games = q("SELECT game, COUNT(*) AS n, COUNT(DISTINCT user_id) AS u,
                   SUM(CASE WHEN played_at >= ? THEN 1 ELSE 0 END) AS n7
                FROM game_scores WHERE user_id IN ($PLAYERS) AND played_at >= ? GROUP BY game ORDER BY n DESC", [max($cut_dt, $base), $base])->fetchAll();
    foreach ($games as &$g) {
        $g['u7'] = (int)q_val("SELECT COUNT(DISTINCT user_id) FROM game_scores WHERE game = ? AND played_at >= ? AND user_id IN ($PLAYERS)", [$g['game'], max($cut_dt, $base)]);
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
<p class="help"><?= $base !== '' ? '<b>Counting since ' . e($base) . ' UTC</b> (reset). Rows with no date show only what was added since; their player counts show “–”. ' : '' ?>What real players use. Admins, moderators and banned players are left out. Use this before you cut or merge anything. “–” = the table keeps no date, so only totals exist.</p>

<div class="box">
  <h2>Players</h2>
  <table class="grid">
    <tr><th>Signed up</th><th>Seen in 7 days</th><th>Seen in 30 days</th></tr>
    <tr><td><?= number_format($total) ?></td><td><?= number_format($act7) ?> <small class="help"><?= e($pct($act7, $total)) ?></small></td><td><?= number_format($act30) ?> <small class="help"><?= e($pct($act30, $total)) ?></small></td></tr>
  </table>
  <?php $gMade = (int)setting('guest_made_total'); $gConv = (int)setting('guest_converted_total'); $gLive = (int)q_val('SELECT COUNT(*) FROM users WHERE guest = 1'); ?>
  <p class="help">Guest gardens (<?= setting('guest_open') === '1' ? 'on' : 'off' ?>): <b><?= number_format($gLive) ?></b> alive now · <b><?= number_format($gMade) ?></b> made in all · <b><?= number_format($gConv) ?></b> turned into accounts<?= $gMade > 0 ? ' (' . round(100 * $gConv / $gMade) . '%)' : '' ?>. Guests are left out of every number on this page.</p>
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

<?php stats_reset_box('usage', 'Starts the Rows and Players columns from zero as of now. Nothing in the game is deleted: only this report forgets the past.', 'Reset the Usage numbers? Nothing in the game is deleted.'); ?>
