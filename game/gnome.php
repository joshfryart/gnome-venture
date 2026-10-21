<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/adventure.php';   // v0.9.7: easy_roads_on()
$u = require_login();

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'stat') {
        [$ok, $msg] = spend_stat_point($u, (string)($_POST['stat'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'easy_roads') {   // v0.9.7
        q('UPDATE users SET easy_roads = ? WHERE id = ?', [empty($_POST['easy_roads']) ? 0 : 1, $u['id']]);
        flash(empty($_POST['easy_roads']) ? 'Easy roads are off: roads next to home match your level and can be tough.' : 'Easy roads are on: roads next to home stay a few levels below you, with no legendary creatures.', 'ok');
    } elseif ($do === 'calling') {
        [$ok, $msg] = choose_calling($u, (string)($_POST['calling'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'dye') {   // v0.9.7: wear the dyes you own
        $bad = 0;
        foreach (['hat', 'beard'] as $part) {
            if (!isset($_POST[$part])) continue;
            [$ok, $msg] = dye_use($u, $part, (string)$_POST[$part]);
            if (!$ok) { flash($msg, 'err'); $bad++; }
        }
        if (!$bad) flash('🎨 Your gnome looks splendid.');
        redirect('gnome.php?dye=1#dyes');
    }
    redirect('gnome.php');
}

refresh_energy($u);
$GLOBALS['CURRENT_USER'] = $u;
$buff = active_buff($u);
$food = food_bonus((int)$u['id']);
$cap = (int)setting('food_perm_cap');
$plot = q_one('SELECT * FROM plots WHERE id = ?', [active_plot_id((int)$u['id'])]);
$gardens = user_gardens((int)$u['id']);
$home = home_region($u);
$callingLevel = (int)setting('calling_level');

page_header('My Gnome');
?>
<div class="gnomehead box">
  <?= gnome_avatar($u, 90) ?>
  <div>
    <h1><?= e(gnome_name($u)) ?><?= $u['title'] ? ' <small class="title">“' . e($u['title']) . '”</small>' : '' ?></h1>
    <p class="help"><a href="<?= e(url('profile.php')) ?>">👤 See your profile as others do</a></p>
    <p><?= $u['calling'] ? e(CALLINGS[$u['calling']][0]) . ' · ' : '' ?>Garden gnome<?= $home ? ' of ' . e($home['gnomish_name']) : '' ?></p>
    <p class="status">
      🧑‍🌾 Gnome level <b><?= (int)$u['level'] ?></b> (<?= (int)$u['xp'] ?>/<?= xp_for_level((int)$u['level'] + 1) ?> XP)
      · 🏡 <?= count($gardens) ?>/<?= max_gardens($u) ?> garden<?= max_gardens($u) === 1 ? '' : 's' ?>
      (<?= eu(implode(', ', array_map(fn($g) => ($g['garden_name'] ?: 'Garden') . ' L' . $g['garden_level'], $gardens))) ?>)
      · ⚡ <?= (int)$u['energy'] ?>/<?= max_energy($u) ?> energy
    </p>
  </div>
</div>
<?= dye_editor_html($u) /* v0.9.7 */ ?>
<?php // v0.7.61: the little facts at a glance, each opening its details
$tastedList = q('SELECT i.name, i.category FROM user_tasted t JOIN items i ON i.id = t.item_id WHERE t.user_id = ? ORDER BY t.tasted_at DESC, i.name', [$u['id']])->fetchAll();
$edibleTotal = (int)q_val('SELECT COUNT(*) FROM items WHERE edible = 1');
$lc = q_one("SELECT SUM(CASE WHEN lm.kind = 'lair' THEN 1 ELSE 0 END) AS lairs, SUM(CASE WHEN lm.kind = 'delve' THEN 1 ELSE 0 END) AS delves
             FROM landmark_clears c JOIN landmarks lm ON lm.id = c.landmark_id WHERE c.user_id = ?", [$u['id']]); ?>
<div class="factrow">
  <a class="fact" href="#tasted"><span>🍴</span><b><?= count($tastedList) ?></b><small>foods tasted<?= $edibleTotal ? ' of ' . $edibleTotal : '' ?></small></a>
  <a class="fact" href="#calling"><span><?= ph_or_emoji('hat-' . (string)$u['calling'], '🎩', 24) /* v1.5.2 */ ?></span><b><?= $u['calling'] ? e(CALLINGS[$u['calling']][0]) : ((int)$u['level'] >= $callingLevel ? 'Choose!' : 'Lv ' . $callingLevel) ?></b><small>calling</small></a>
  <a class="fact" href="#friends"><span>💛</span><b><?= (int)q_val('SELECT COUNT(*) FROM npc_friends WHERE user_id = ? AND points > 0', [$u['id']]) ?></b><small>villagers who know you</small></a>
  <?php if ((int)($u['ribbons'] ?? 0)): ?><span class="fact"><span>🎀</span><b><?= (int)$u['ribbons'] ?></b><small>ribbons</small></span><?php endif; ?>
  <?php if ((int)($u['community_rep'] ?? 0)): ?><span class="fact"><span>💚</span><b><?= (int)$u['community_rep'] ?></b><small>community help</small></span><?php endif; ?>
  <?php if ((int)($lc['lairs'] ?? 0)): ?><span class="fact"><span>🐉</span><b><?= (int)$lc['lairs'] ?></b><small>lairs conquered</small></span><?php endif; ?>
  <?php if ((int)($lc['delves'] ?? 0)): ?><span class="fact"><span>🕳️</span><b><?= (int)$lc['delves'] ?></b><small>delves cleared</small></span><?php endif; ?>
</div>
<details class="fold box" id="tasted"><summary>🍴 Foods you’ve tasted (<?= count($tastedList) ?>)</summary>
  <?php if ($tastedList): ?><p class="tasted"><?php foreach ($tastedList as $tf): ?><span class="chip"><?= item_icon(['id' => 0, 'category' => $tf['category'], 'name' => $tf['name']], 'sm') ?> <?= e($tf['name']) ?></span> <?php endforeach; ?></p>
  <?php else: ?><p class="muted">Nothing yet. Eat or drink something from your <a href="<?= e(url('inventory.php?cat=food')) ?>">satchel</a>.</p><?php endif; ?>
  <p class="help">The first taste of a rare crop can raise a stat for good. Newest first.</p>
</details>

<div class="box" id="easyroads">
  <h2>🛣️ Easy roads</h2>
  <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="easy_roads">
    <label class="check"><input type="checkbox" name="easy_roads" value="1" <?= easy_roads_on($u) ? 'checked' : '' ?>> Keep the roads next to home easy</label> <button class="btn small">Save</button>
  </form>
  <p class="help"><?= easy_roads_on($u) ? 'On: on the roads next to your home, towns and gardens, creatures stay at most ' . (int)setting('easy_roads_gap') . ' levels below you (level ' . easy_road_cap($u) . ' or lower) and legendary creatures stay away.' : 'Off: on the roads next to your home, towns and gardens, creatures match your level (level ' . max(1, (int)$u['level']) . '), and the ones you meet can be tough.' ?> Roads further out and off the path are not changed.</p>
</div>

<div class="box">
  <h2>Stats</h2>
  <details class="helpfold"><summary>❓ How stats work</summary>
  <p class="help">10 is an average gnome. Every 2 points above 10 gives a +1 modifier, which powers your gardening and your adventures.
    You earn <?= (int)setting('stat_points_per_level') ?> stat point per gnome level. Rare crops can raise a stat permanently the first time you eat each one (up to +<?= $cap ?> per stat from food).</p></details>
  <?php if ((int)$u['stat_points'] > 0): ?>
    <div class="flash ok">You have <b><?= (int)$u['stat_points'] ?></b> stat point<?= (int)$u['stat_points'] === 1 ? '' : 's' ?> to spend!</div>
  <?php endif; ?>
  <div class="statcards">
    <?php foreach (GNOME_STATS as $key => [$name, $icon, $desc, $garden, $adventure]):
        $base = (int)$u['stat_' . $key];
        $total = eff_stat($u, $key);   // v0.7.90: meal, event and town boosts together
        $b = $total - $base;
        $mod = stat_mod($total); ?>
      <div class="statcard<?= $b ? ' buffed' : '' ?>">
        <div class="stattop">
          <span class="staticon"><?= $icon ?></span>
          <span class="statname"><?= e($name) ?></span>
          <span class="statmod" title="Modifier"><?= $key === 'luck' ? rtrim(rtrim(number_format(luck_percent($u), 3), '0'), '.') . '%' : ($mod >= 0 ? '+' : '') . $mod ?></span>
        </div>
        <div class="statscore"><?= $total ?><?= $b ? '<small class="good"> +' . $b . ' boost</small>' : '' ?></div>
        <div class="statmeta">food bonus <?= (int)($food[$key] ?? 0) ?>/<?= $cap ?></div>
        <details><summary>What it does</summary>
          <p><?= e($desc) ?></p><p>🌱 <?= e($garden) ?></p><p>⚔️ <?= e($adventure) ?></p></details>
        <?php if ((int)$u['stat_points'] > 0 && $base < (int)setting('stat_max')): ?>
          <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="stat"><input type="hidden" name="stat" value="<?= e($key) ?>">
            <button class="btn small">+1 <?= e($name) ?></button></form><?php endif; ?>
      </div>
    <?php endforeach; ?>
  </div>
  <h3 id="effects">✨ Active effects</h3>
  <?php $fx = active_effects($u); if ($fx): ?>
    <ul class="effects"><?php foreach ($fx as [$ic, $nm, $what, $sec]): ?>
      <li><span class="efi"><?= $ic ?></span> <b><?= e($nm) ?>:</b> <?= e($what) ?> <span class="muted">· <?= e(effect_time($sec)) ?> left</span></li>
    <?php endforeach; ?></ul>
    <p class="help">A new meal replaces the old meal’s boost. Town outings and lucky moments each have their own slot, so they add up.</p>
  <?php endif; ?>
  <?php if (!$buff): ?>
    <p class="help">No meal buff right now. Eat something from your <a href="<?= e(url('inventory.php')) ?>">satchel</a> or cook something at your <a href="<?= e(url('inventory.php?tab=craft')) ?>">workbench</a>.</p>
  <?php endif; ?>
</div>

<details class="fold box" id="friends"><summary>💛 Villagers you know</summary>
  <?php require_once __DIR__ . '/includes/friends.php';
  $friends = q('SELECT f.*, n.name, n.slug, n.species, n.personality FROM npc_friends f JOIN npcs n ON n.id = f.npc_id
                WHERE f.user_id = ? ORDER BY f.points DESC LIMIT 20', [$u['id']])->fetchAll(); ?>
  <?php if (!$friends): ?>
    <p class="help">Nobody knows you well yet. Click a shopkeeper’s name in any shop to chat, or bring them a gift.</p>
  <?php else: ?>
    <table class="grid">
      <tr><th>Who</th><th>Friendship</th><th>What you know</th></tr>
      <?php foreach ($friends as $fr): $lv = friend_level((int)$fr['points']); ?>
        <tr><td><a href="<?= e(url('folk.php?id=' . (int)$fr['npc_id'])) ?>"><?= e($fr['name']) ?></a> <span class="muted"><?= e(strtolower((string)$fr['species'])) ?></span></td>
          <td><?= e($lv['name']) ?><?= $lv['discount'] ? ' · ' . (int)$lv['discount'] . '% off' : '' ?></td>
          <td class="help"><a href="<?= e(url('folk.php?id=' . (int)$fr['npc_id'] . '&tab=tastes')) ?>"><?= e(implode(' · ', known_tastes($fr, $fr)) ?: 'Find out →') ?></a></td></tr>
      <?php endforeach; ?>
    </table>
  <?php endif; ?>
  <p><a href="<?= e(url('town.php?view=villagers')) ?>">👤 Everyone you know, and where they are now →</a></p>
</details>

<?php if ((int)$u['level'] < $callingLevel): ?>
<div class="box callinglock" id="calling"><p>🎩 Your <b>calling</b> unlocks at gnome level <?= $callingLevel ?>: your gnome’s path in life, with its own hat and perks.</p></div>
<?php else: ?>
<?php $myTier = calling_tier($u); $t2 = (int)setting('calling_tier2_level'); $t3 = (int)setting('calling_tier3_level');
      $canChange = calling_can_change($u); $changeCost = calling_change_cost($u);   // v0.9.1a ?>
<details class="fold box" id="calling"<?= $u['calling'] ? '' : ' open' ?>><summary>🎩 Calling<?= $u['calling'] ? ': ' . e(trim(calling_tier_name($myTier) . ' ' . CALLINGS[$u['calling']][0])) : ' (ready to choose!)' ?></summary>
  <?php if (!$u['calling']): ?>
    <div class="flash ok">🎩 You’re ready to choose your calling! Choose well: changing it later costs Petals (<?= (int)setting('calling_change_cost') ?> the first time, doubling each time).</div>
  <?php else: ?>
    <p>You are a <b><?= e(calling_tier_name($myTier)) ?> <?= e(CALLINGS[$u['calling']][0]) ?></b>.
      <?= $myTier < 3 ? 'Your calling grows stronger at gnome level ' . ($myTier < 2 ? $t2 : $t3) . ' once you finish ' . ($myTier < 2 ? 'its Journeyman' : 'its Master') . ' chapter with your calling’s mentor.' : 'You’ve mastered your calling.' ?>
      <?= $changeCost > 0 ? 'Changing your calling costs ' . $changeCost . ' Petals.' : 'You have one free change.' ?></p>
    <?php require_once __DIR__ . '/includes/calling_view.php'; echo calling_gnome_line($u);   // v0.9.4: mentor and chapter ?>
  <?php endif; ?>
  <p class="help">Each calling has three tiers: 🎩 Apprentice (level <?= $callingLevel ?>), 🎗️ Journeyman (level <?= $t2 ?> and a chapter) and ⭐ Master (level <?= $t3 ?> and a chapter). Each chapter is a set of tasks for your calling’s mentor. Each tier keeps what the one before gave.</p>
  <div class="callings">
    <?php $foldOpen = false; $list = CALLINGS;
    if ($u['calling'] && isset($list[$u['calling']])) $list = [$u['calling'] => $list[$u['calling']]] + $list;   // v0.9.1a: yours first
    foreach ($list as $key => [$name, $hat, $color, $tag, $garden, $adventure]):
        $mine = $u['calling'] === $key;
        if ($u['calling'] && !$mine && !$foldOpen) { $foldOpen = true; echo '</div><details class="fold"><summary>Other callings</summary><div class="callings">'; }   // v0.9.1a: only your own card up front
        $tiers = array_map('trim', explode('·', preg_replace('/^\s*I:\s*/', '', $garden)));   // "I: … · II: … · III: …" ?>
      <div class="calling box<?= $mine ? ' mine' : '' ?>">
        <?= gnome_hat(['calling' => $key]) ?>
        <h3><?= e($name) ?> <small class="muted"><?= e($hat) ?> hat</small></h3>
        <p><i><?= e($tag) ?></i></p>
        <ol class="ctiers">
          <?php foreach ($tiers as $n => $txt): $tn = $n + 1; $txt = preg_replace('/^I{1,3}:\s*/', '', $txt); ?>
            <li class="<?= $mine && $myTier >= $tn ? 'got' : '' ?>"><b><?= ['', '🎩 Apprentice', '🎗️ Journeyman', '⭐ Master'][$tn] ?? '' ?></b> <small class="muted">(level <?= [1 => $callingLevel, 2 => $t2, 3 => $t3][$tn] ?? '' ?><?= $tn > 1 ? ' + chapter' : '' ?>)</small>: <?= e(rtrim($txt, '.')) ?>.</li>
          <?php endforeach; ?>
        </ol>
        <p>⚔️ <b>Adventure:</b> <?= e($adventure) ?></p>
        <?php if (!$mine && (!$u['calling'] || $canChange)): ?>
          <form method="post" data-confirm="Become a <?= e($name) ?>?<?= $u['calling'] ? ($changeCost > 0 ? ' This costs ' . $changeCost . ' Petals.' : ' This uses your one free change.') : ' Changing it later costs Petals.' ?>">
            <?= csrf_field() ?><input type="hidden" name="do" value="calling"><input type="hidden" name="calling" value="<?= e($key) ?>">
            <button class="btn small"><?= $u['calling'] ? ($changeCost > 0 ? 'Switch (' . $changeCost . ' Petals)' : 'Switch (free, once)') : 'Choose' ?></button></form>
        <?php elseif ($mine): ?><p class="good">✔ Your calling<?= $myTier ? ' · ' . e(calling_tier_name($myTier)) : '' ?></p><?php endif; ?>
      </div>
    <?php endforeach; ?>
    <?= $foldOpen ? '</div></details><div>' : '' ?>
  </div>
</details>
<?php endif; ?>
<?php page_footer();
