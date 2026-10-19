<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
$u = require_login();
$uid = (int)$u['id'];
ensure_race_secret();
settle_races();

if (is_post()) {
    csrf_check();
    [$ok, $msg] = place_bet($u, (int)($_POST['snail'] ?? -1), (int)($_POST['amount'] ?? 0));
    flash($msg, $ok ? 'ok' : 'err');
    redirect('race.php');
}

[$race, $start] = next_race();
$last = race_key(time());
$order = race_result($last);
$mine = q_one('SELECT * FROM snail_bets WHERE user_id = ? AND race = ?', [$uid, $race]);
$backers = [];
foreach (q('SELECT snail, COUNT(*) AS n FROM snail_bets WHERE race = ? GROUP BY snail', [$race])->fetchAll() as $r) $backers[(int)$r['snail']] = (int)$r['n'];
$history = q('SELECT * FROM snail_bets WHERE user_id = ? AND paid = 1 ORDER BY id DESC LIMIT 5', [$uid])->fetchAll();
$left = game_plays_left($uid, 'race');
$lastBet = q_one('SELECT * FROM snail_bets WHERE user_id = ? AND race = ?', [$uid, $last]);   // v1.4.7: how you did in the race shown above
require_once __DIR__ . '/includes/townsfolk.php';
$cheer = townsfolk_cheer($race, count(SNAILS));   // v1.0.0: townsfolk in the stands
page_header('Snail Race');
?>
<h1>🐌 Snail Race</h1>
<?= game_tabs_html('race.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    $odds = implode(', ', array_map(fn($i) => SNAILS[$i][0] . ' ' . snail_payout($i) . '×', array_keys(SNAILS)));
    echo game_rules_html([
        game_energy_rule('when your snail wins'),   // v1.4.7
        ['🎯', 'Goal.', 'Back the snail you think will win. A race runs every hour, on the hour.'],
        ['🪙', 'Your bet.', 'One snail per race, from 1 to ' . money((int)setting('race_max_bet')) . '. Bets close when the race starts.'],
        ['💰', 'Payout.', 'If your snail wins you get your bet times its number: ' . $odds . '.'],
        ['🎲', 'Long shots.', 'The slower the snail, the bigger the payout. A loss costs the bet.'],
        ['🔁', 'Daily limit.', 'Back up to ' . (int)setting('race_bets_per_day') . ' races a day.'],
        ['📬', 'Results.', 'Winnings are paid to you automatically when the race is over. Your last five races are on the Play tab.'],
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">A race every hour. Back a snail and cheer it home.</p>
<?php /* v1.4.7: race-day look. Snail art in assets/img/games/, replay + countdown in assets/race.js. The server still runs and pays every race. */ ?>
<div class="gmchips" role="status">
  <span class="gmchip">🎟️ Bets left <b><?= $left ?></b></span>
  <span class="gmchip">🪙 Up to <b><?= money((int)setting('race_max_bet')) ?></b></span>
  <span class="gmchip racecd" data-secs="<?= max(0, $start - time()) ?>">⏱️ Next race <b><?= nice_time($start - time()) ?></b></span>
</div>

<div class="box racebox">
  <div class="racehead"><h2>Last race <small><?= hollow_date('H:00', intdiv(time(), 3600) * 3600) ?></small></h2>
    <button type="button" class="btn alt small racereplay" hidden>▶ Replay</button></div>
  <div class="racetrack" data-race="<?= e($last) ?>" data-order="<?= e(implode(',', $order)) ?>">
    <?php $rank = array_flip($order); foreach (SNAILS as $i => [$name, $colour]): $mineHere = $lastBet && (int)$lastBet['snail'] === $i; ?>
      <div class="racelane rk<?= (int)$rank[$i] ?> lane-<?= $colour ?><?= $mineHere ? ' mine' : '' ?>" data-i="<?= $i ?>" data-rank="<?= (int)$rank[$i] ?>">
        <span class="lanenum"><?= $i + 1 ?></span>
        <span class="laneway"><span class="racer"><span class="rankbadge"><?= (int)$rank[$i] === 0 ? '🏆' : race_place((int)$rank[$i]) ?></span><?= snail_img($i, 'racerimg') ?></span></span>
      </div>
    <?php endforeach; ?>
    <span class="finishline" aria-hidden="true"></span>
  </div>
  <p class="racehint help" hidden>Tap the track to skip.</p>
  <ol class="racepodium">
    <?php foreach ($order as $pos => $i): ?><li class="pod-<?= SNAILS[$i][1] ?><?= $pos === 0 ? ' win' : '' ?>"><span class="pl"><?= $pos === 0 ? '🏆' : race_place($pos) ?></span> <?= e(SNAILS[$i][0]) ?></li><?php endforeach; ?>
  </ol>
  <?php if ($lastBet): $won = (int)$lastBet['paid'] === 1 && (int)$lastBet['winnings'] > 0; ?>
    <p class="racemine <?= $won ? 'won' : '' ?>"><?= snail_img((int)$lastBet['snail'], 'mineimg') ?><span>You backed <b><?= e(SNAILS[(int)$lastBet['snail']][0]) ?></b> with <?= money((int)$lastBet['amount']) ?>:
      <?= $won ? 'it won! <b>+' . money((int)$lastBet['winnings']) . '</b>' : 'not this time.' ?></span></p>
  <?php endif; ?>
</div>

<div class="box racebox">
  <h2>Place your bet</h2>
  <?php if ($mine): $mi = (int)$mine['snail']; ?>
    <div class="raceticket snail-<?= SNAILS[$mi][1] ?>">
      <?= snail_img($mi, 'scimg') ?>
      <div class="rtbody"><b>You backed <?= e(SNAILS[$mi][0]) ?></b>
        <span class="gmchips left"><span class="gmchip">🪙 <b><?= money((int)$mine['amount']) ?></b></span><span class="gmchip">🎲 Pays <b><?= snail_payout($mi) ?>×</b></span><span class="gmchip">💰 Win <b><?= money((int)floor((int)$mine['amount'] * snail_payout($mi))) ?></b></span></span></div>
    </div>
    <p class="help">Come back after the race!</p>
  <?php elseif ($left <= 0): ?>
    <p class="muted">You’ve backed enough snails for today.</p>
  <?php else: ?>
    <form method="post" class="raceform"><?= csrf_field() ?>
      <div class="snailcards">
      <?php foreach (SNAILS as $i => [$name, $colour, $chance]): ?>
        <label class="snailcard snail-<?= $colour ?>" data-name="<?= e($name) ?>"><input type="radio" name="snail" value="<?= $i ?>" <?= $i === 0 ? 'checked' : '' ?>><span class="scframe"></span>
          <?= snail_img($i, 'scimg') ?>
          <span class="scinfo"><b><?= e($name) ?></b>
            <span class="scmeta">👥 <?= (int)($backers[$i] ?? 0) ?> cheering<?= !empty($cheer[$i]) ? ' · <span class="tfolk" title="Townsfolk cheering. They don’t bet.">🏡 ' . e(implode(', ', $cheer[$i])) . '</span>' : '' ?></span></span>
          <span class="scodds"><b><?= snail_payout($i) ?>×</b><small>pays</small></span></label>
      <?php endforeach; ?>
      </div>
      <div class="betrow"><label class="betlabel">Bet <input type="number" name="amount" value="10" min="1" max="<?= (int)setting('race_max_bet') ?>" class="qty" inputmode="numeric"></label>
        <span class="betquick" data-max="<?= (int)setting('race_max_bet') ?>"></span></div>
      <button class="btn racego">Back this snail</button>
    </form>
  <?php endif; ?>
</div>
<?php if ($history): ?>
  <div class="box racebox"><h3>Your recent races</h3>
    <ul class="racehist">
      <?php foreach ($history as $h): $hw = (int)$h['winnings']; ?><li><span class="rhtime"><?= e(substr((string)$h['race'], 8, 2)) ?>:00</span><?= snail_img((int)$h['snail'], 'histimg') ?><b><?= e(SNAILS[(int)$h['snail']][0]) ?></b>
        <span class="gmchip">Bet <b><?= money((int)$h['amount']) ?></b></span><span class="gmchip<?= $hw ? ' win' : '' ?>"><?= $hw ? '🏆 Won <b>' . money($hw) . '</b>' : 'No win' ?></span></li><?php endforeach; ?>
    </ul></div>
<?php endif; ?>
<p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
<?php page_footer();
