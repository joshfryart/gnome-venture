<?php
declare(strict_types=1);
/** A gnome's public profile (v0.7.35): who they are, their ribbons, and their gardens to visit. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/yard.php';
require_once __DIR__ . '/includes/catalog.php';
require_once __DIR__ . '/includes/pals.php';   // v1.0.0: gnome friends
$me = require_login();
$id = (int)($_GET['id'] ?? $me['id']);
$g = q_one('SELECT * FROM users WHERE id = ? AND deleted_at IS NULL', [$id]);
if (!$g || (int)($g['onboarded'] ?? 1) === 0 && (int)$g['id'] !== (int)$me['id']) {
    http_response_code(404);
    page_header('Gnome not found');
    echo '<h1>Gnome not found</h1><p class="muted">There’s no gnome by that number.</p>';
    page_footer();
    exit;
}
$mine = (int)$g['id'] === (int)$me['id'];
$staff = in_array($me['role'], ['admin', 'mod'], true);
$open = (int)$g['garden_public'] === 1 || $mine || $staff;
$home = $g['home_village_id'] ? q_one('SELECT l.name, r.gnomish_name FROM locations l LEFT JOIN regions r ON r.id = l.region_id WHERE l.id = ?', [$g['home_village_id']]) : null;
[$pages, $totalPages] = almanac_counts((int)$g['id']);
$gardens = $open ? user_gardens((int)$g['id']) : [];
$wins = q('SELECT e.month, e.placed, p.garden_name FROM gotm_entries e LEFT JOIN plots p ON p.id = e.plot_id
           WHERE e.user_id = ? AND e.placed BETWEEN 1 AND 3 ORDER BY e.month DESC LIMIT 12', [$g['id']])->fetchAll();
$calling = CALLINGS[$g['calling'] ?? ''] ?? null;
page_header(gnome_name($g));
?>
<div class="profilehead box">
  <?= gnome_avatar($g, 80) ?>
  <div>
    <h1><?= e(gnome_name($g)) ?> <?= report_link((int)$g['id'], 'name') ?></h1>
    <?php if (!empty($g['title'])): ?><p class="title"><i><?= e((string)$g['title']) ?></i></p><?php endif; ?>
    <p>Gnome level <b><?= (int)$g['level'] ?></b><?= $calling ? ' · ' . e(trim(calling_tier_name(calling_tier($g)) . ' ' . $calling[0])) : '' ?>
      <?= $home ? ' · from ' . e($home['name'] . ($home['gnomish_name'] ? ', ' . $home['gnomish_name'] : '')) : '' ?>
      · gardening since <?= e(hollow_date('F Y', ts($g['created_at']))) ?></p>
    <p>🎀 <?= (int)$g['ribbons'] ?> ribbon<?= (int)$g['ribbons'] === 1 ? '' : 's' ?> · 📖 <?= (int)$pages ?> Almanac pages</p>
    <p class="palactions"><?= pal_profile_actions($me, $g) ?> <?php require_once __DIR__ . '/includes/mentors120.php'; echo mentors120_profile_button($me, $g); ?></p>
    <?php if ($mine): ?><p class="help">This is how other gnomes see you. <?= (int)$g['garden_public'] === 1 ? 'Your gardens are open to visitors.' : 'Your gardens are private.' ?>
      <a href="<?= e(url('account.php')) ?>">Change on the Account page</a>.</p><?php endif; ?>
  </div>
</div>

<?php // v0.7.62: view-only tabs
$tab = in_array($_GET['tab'] ?? '', ['gardens', 'awards'], true) ? (string)$_GET['tab'] : 'about';
$tl = fn(string $t) => e(url('profile.php?id=' . (int)$g['id'] . ($t === 'about' ? '' : '&tab=' . $t)));
$gid = (int)$g['id']; ?>
<nav class="tabs">
  <a class="<?= $tab === 'about' ? 'on' : '' ?>" href="<?= $tl('about') ?>">👤 About</a>
  <a class="<?= $tab === 'gardens' ? 'on' : '' ?>" href="<?= $tl('gardens') ?>">🏡 Gardens<?= $open ? ' <small>' . count($gardens) . '</small>' : '' ?></a>
  <a class="<?= $tab === 'awards' ? 'on' : '' ?>" href="<?= $tl('awards') ?>">🏆 Awards</a>
</nav>

<?php if ($tab === 'about'):
    $lc = q_one("SELECT SUM(CASE WHEN lm.kind = 'lair' THEN 1 ELSE 0 END) AS lairs, SUM(CASE WHEN lm.kind = 'delve' THEN 1 ELSE 0 END) AS delves
                 FROM landmark_clears c JOIN landmarks lm ON lm.id = c.landmark_id WHERE c.user_id = ?", [$gid]);
    $facts = [
        ['🧑‍🌾', (int)$g['level'], 'gnome level'],
        ['🎩', $calling ? trim(calling_tier_name(calling_tier($g)) . ' ' . $calling[0]) : '—', 'calling'],   // v0.9.1: tier
        ['📖', (int)$pages, 'Almanac pages'],
        ['🍴', (int)q_val('SELECT COUNT(*) FROM user_tasted WHERE user_id = ?', [$gid]), 'foods tasted'],
        ['⭐', (int)q_val('SELECT COUNT(*) FROM user_plant_knowledge k JOIN plants p ON p.id = k.plant_id WHERE k.user_id = ? AND k.knowledge >= p.knowledge_max', [$gid]), 'plants mastered'],
        ['🗺️', (int)q_val('SELECT COUNT(*) FROM region_visits WHERE user_id = ?', [$gid]), 'regions visited'],
        ['💛', (int)q_val('SELECT COUNT(*) FROM npc_friends WHERE user_id = ? AND points > 0', [$gid]), 'folk who know them'],
        ['🐉', (int)($lc['lairs'] ?? 0), 'lairs conquered'],
        ['🕳️', (int)($lc['delves'] ?? 0), 'delves cleared'],
    ]; ?>
  <div class="factrow">
    <?php foreach ($facts as [$ic, $v, $label]): ?><span class="fact"><span><?= $ic ?></span><b><?= e((string)$v) ?></b><small><?= e($label) ?></small></span><?php endforeach; ?>
  </div>
  <?php if ($calling): ?><p class="help">🎩 <b><?= e($calling[0]) ?></b>: <i><?= e($calling[3]) ?></i></p><?php endif; ?>
  <div class="box"><h3>🤝 Gnome friends</h3><?= pal_profile_list($g, $mine, $staff) ?></div>

<?php elseif ($tab === 'gardens'): ?>
  <?php if (!$open): ?>
    <p class="muted">🔒 <?= e(gnome_name($g)) ?> keeps their gardens private.</p>
  <?php else: ?>
    <div class="gardencards">
    <?php foreach ($gardens as $pl):
        [$plot, $tiles, $plants] = load_plot($gid, true, (int)$pl['id']);
        $objs = yard_objects((int)$pl['id']); $ap = yard_appeal((int)$pl['id'], $objs); ?>
      <div class="box gardencard">
        <a href="<?= e(url('visit.php?g=' . (int)$pl['id'])) ?>" aria-label="Visit <?= e($pl['garden_name'] ?: 'this garden') ?>"><div class="yardwrap"><?= render_yard($plot, $tiles, $plants, $objs, 'mini') ?></div></a>
        <h3><a href="<?= e(url('visit.php?g=' . (int)$pl['id'])) ?>"><?= eu($pl['garden_name'] ?: 'Garden') ?></a></h3>
        <p class="help"><?= e((string)($pl['region'] ?? '')) ?> · level <?= (int)$pl['garden_level'] ?> · 🌼 <?= $ap ?> (<?= e(appeal_word($ap)) ?>)</p>
      </div>
    <?php endforeach; ?>
    </div>
  <?php endif; ?>

<?php else:
    $ms = q('SELECT m.name, m.reward_title, um.achieved_at FROM user_milestones um JOIN almanac_milestones m ON m.id = um.milestone_id
             WHERE um.user_id = ? ORDER BY um.achieved_at DESC', [$gid])->fetchAll(); ?>
  <div class="box"><h3>🎀 Ribbons: <?= (int)$g['ribbons'] ?></h3><p class="help">Won at the Village Show, the Grand Harvest Fair and in contests.</p>
    <?php require_once __DIR__ . '/includes/fair.php'; echo fair_ribbons_html((int)$g['id']);   // v0.8.1 ?></div>
  <?php require_once __DIR__ . '/includes/puzzles.php'; if (setting('puzzles_tournaments') === '1' && ($pzb = puzzle_badges_html($gid)) !== ''): ?>
  <div class="box"><h3>🧩 Puzzle tournaments</h3><?= $pzb /* v2.0.68: cosmetic trophies and badges */ ?></div>
  <?php endif; ?>
  <div class="box"><h3>🏆 Garden of the Month</h3>
    <?php if ($wins): ?><ul><?php foreach ($wins as $w): ?><li><?= ['', '🥇 1st', '🥈 2nd', '🥉 3rd'][(int)$w['placed']] ?> in <?= e($w['month']) ?> with <?= eu($w['garden_name'] ?: 'a garden') ?></li><?php endforeach; ?></ul>
    <?php else: ?><p class="muted">No placings yet.</p><?php endif; ?>
  </div>
  <div class="box"><h3>📜 Milestones earned: <?= count($ms) ?></h3>
    <?php if ($ms): ?><ul><?php foreach ($ms as $m): ?><li><?= e($m['name']) ?><?= $m['reward_title'] ? ' <span class="muted">· title “' . e($m['reward_title']) . '”</span>' : '' ?></li><?php endforeach; ?></ul>
    <?php else: ?><p class="muted">None yet.</p><?php endif; ?>
  </div>
<?php endif; ?>
<?php page_footer();
