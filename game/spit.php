<?php
declare(strict_types=1);
/** Seed Spitting (v0.7.31). v1.4.0: aim and power against the wind (assets/spit.js); the server works the distance out itself. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/games.php';
$u = require_login();
$uid = (int)$u['id'];
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    [$ok, $msg] = match ($do) {
        'start' => spit_start($u),
        'fire' => spit_fire($u, (string)($_POST['tok'] ?? ''), (int)($_POST['angle'] ?? 0), (int)($_POST['power'] ?? 0)),   // v1.4.0:
        default => spit_go($u),   // the quick spit (and the old one-button form)
    };
    if ($msg !== '') flash($msg, $ok ? 'ok' : 'err');
    redirect('spit.php');
}
$s = game_state($uid, 'spit');
$left = game_plays_left($uid, 'spit');
page_header('Seed Spitting');
$P = SPIT_PHYS;
?>
<h1>🍉 Seed Spitting</h1>
<?= game_tabs_html('spit.php') ?>
<?php if (game_tab() === 'rules'):   // v1.4.1
    $aim = setting('spit_game_on') === '1';
    echo game_rules_html([
        ['🎯', 'Goal.', 'Spit a melon seed as far as you can. Your best distance counts on the weekly board.'],
        $aim ? ['🏹', 'Aim.', 'Drag back from the gnome like a slingshot, then let go. Or use the angle and power sliders.'] : null,
        $aim ? ['💨', 'Wind.', 'You see the wind before you spit. A tailwind helps, a headwind slows you. A lucky gust (about 1 in 20) is a strong tailwind.'] : null,
        $aim ? ['🪶', 'Quick spit.', 'No aiming: a random distance, helped by your Grit and Nimble. It uses a go too.'] : null,
        !$aim ? ['🎲', 'How far.', 'A random distance, helped by your Grit and Nimble, and now and then a lucky gust.'] : null,
        ['💪', 'Grit and Nimble.', $aim ? 'Grit adds puff to every spit. Nimble steadies the seed against the wind.' : 'Grit and Nimble both add a little distance.'],
        ['🪙', 'Prizes.', '30 cm earns ' . money(game_petals(5)) . ', 45 cm ' . money(game_petals(15)) . ', and 60 cm ' . money(game_petals(30)) . '.'],
        ['🔁', 'Daily limit.', (int)setting('spit_plays_per_day') . ' goes a day. Loading a seed uses one.'],
        game_energy_rule('for 45 cm or more'),
    ]);
    echo '<p><a href="' . e(url('games.php')) . '">← All games</a></p>';
    page_footer(); return;
endif; ?>
<p class="gtagline">Pucker up and spit a melon seed as far as you can.</p>
<div class="box spitbox">
<?php if ($s): $w = (int)$s['wind']; ?>
  <div class="spitgame" data-wind="<?= $w ?>" data-gust="<?= !empty($s['gust']) ? 1 : 0 ?>" data-grit="<?= (int)$s['grit'] ?>" data-nim="<?= (int)$s['nim'] ?>"
       data-phys="<?= e(json_encode($P)) ?>" data-wmax="<?= max(1, (int)round((int)setting('spit_wind_max') * 1.5)) ?>">
    <p class="spitwind"><b>💨 Wind:</b> <?= $w === 0 ? 'calm' : abs($w) . ' cm/s ' . ($w > 0 ? 'blowing towards the melon →' : '← blowing against you') ?><?= !empty($s['gust']) ? ' · a lucky gust!' : '' ?></p>
    <form method="post" class="spitform"><?= csrf_field() ?><input type="hidden" name="do" value="fire"><input type="hidden" name="tok" value="<?= e((string)$s['tok']) ?>">
      <label>Angle <input type="range" name="angle" min="<?= $P['amin'] ?>" max="<?= $P['amax'] ?>" value="40"> <output>40°</output></label>
      <label>Power <input type="range" name="power" min="0" max="100" value="75"> <output>75%</output></label>
      <button class="btn act">💨 Spit!</button>
    </form>
    <p class="help spithow">Drag back from the gnome like a slingshot, then let go. Or use the sliders and the button.</p>
  </div>
  <form method="post" data-confirm="Spit quickly instead, with no aiming? It uses this go."><?= csrf_field() ?><button class="btn small alt">Quick spit instead</button></form>
<?php else: ?>
  <div class="spitlane" aria-hidden="true"><span>🧑‍🌾</span><i></i><span>🍉</span></div>
  <p><?= $left ?> go<?= $left === 1 ? '' : 'es' ?> left today · your best this week: <?= number_format(game_best($uid, 'spit') / 10, 1) ?> cm · the Hollow’s best: <?= number_format(spit_record() / 10, 1) ?> cm</p>
  <?php if (setting('spit_game_on') === '1'): ?>
  <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="start"><button class="btn act" <?= $left ? '' : 'disabled' ?>>🍉 Load a seed</button></form>
  <form method="post" class="spitquick"><?= csrf_field() ?><button class="btn small alt" <?= $left ? '' : 'disabled' ?>>Quick spit (no aiming)</button></form>
  <?php else: ?>
  <form method="post"><?= csrf_field() ?><button class="btn act" <?= $left ? '' : 'disabled' ?>>💨 Spit!</button></form>
  <?php endif; ?>
<?php endif; ?>
</div>
<?php $top = game_top('spit'); if ($top): ?><div class="box"><h3>This week’s best</h3><ol class="top"><?php foreach ($top as $t): ?><li><?= e($t['name']) ?>: <?= number_format((int)$t['best'] / 10, 1) ?> cm</li><?php endforeach; ?></ol></div><?php endif; ?>
<p><a href="<?= e(url('games.php')) ?>">← All games</a></p>
<?php page_footer();
