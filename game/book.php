<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/almanac.php';
require_once __DIR__ . '/includes/items.php';   // v0.9.8: item_pic
require_once __DIR__ . '/includes/world.php';
require_once __DIR__ . '/includes/catalog.php';
require_once __DIR__ . '/includes/glossary.php';
$u = require_login();
require_once __DIR__ . '/includes/garden_logic.php';   // v0.9.1: unstudied_slow_pct()
$uid = (int)$u['id'];
require_once __DIR__ . '/includes/breeding110.php'; breeding110_boot();   // v1.1.0: imports the hybrids once on an upgraded world

// Choose a title from the ones you've earned
if (is_post()) {
    csrf_check();
    $want = (string)($_POST['title'] ?? '');
    $earned = q('SELECT m.reward_title FROM user_milestones um JOIN almanac_milestones m ON m.id = um.milestone_id
                 WHERE um.user_id = ? AND m.reward_title IS NOT NULL', [$uid])->fetchAll(PDO::FETCH_COLUMN);
    require_once __DIR__ . '/includes/journey.php';
    require_once __DIR__ . '/includes/stop_pass.php';
    $earned = array_merge($earned, journey_titles($uid), calling_titles($uid), stop_titles($uid));   // v1.0.0: passport titles   // v0.7.65: Journey titles too; v0.9.4: calling chapter titles
    if ($want === '' || in_array($want, $earned, true)) {
        q('UPDATE users SET title = ? WHERE id = ?', [$want === '' ? null : $want, $uid]);
        flash($want === '' ? 'Title removed.' : 'You are now known as “' . $want . '”.');
    }
    redirect('book.php?ch=Milestones');
}

// Chapter tabs with progress
$chapters = [];
foreach (q('SELECT e.chapter, COUNT(*) AS total, COUNT(ue.entry_id) AS have FROM encyclopedia_entries e
            LEFT JOIN user_encyclopedia ue ON ue.entry_id = e.id AND ue.user_id = ?
            GROUP BY e.chapter', [$uid])->fetchAll() as $c) {
    $chapters[$c['chapter']] = $c;
}
$order = ['General', 'Plants', 'Flowers', 'Regions', 'Villages', 'Landmarks', 'Creatures', 'Gathering', 'Recipes'];
// Plants the player has studied (home region, guides) but not grown yet
$tastedPlants = array_fill_keys(q('SELECT p.slug FROM user_tasted t JOIN plants p ON p.produce_item_id = t.item_id WHERE t.user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN), true);
$studied = [];
foreach (q('SELECT id, slug FROM plants')->fetchAll() as $pl) {
    if (isset(known_plants($u)[(int)$pl['id']])) $studied['plant:' . $pl['slug']] = true;
}
uksort($chapters, fn($a, $b) => (array_search($a, $order, true) === false ? 99 : array_search($a, $order, true))
                              <=> (array_search($b, $order, true) === false ? 99 : array_search($b, $order, true)));

// v0.7.61: tabs are Milestones, Guides, the chapters, then the Glossary. Milestones is the default page.
$tab = (string)($_GET['ch'] ?? 'Contents');   // v0.7.72: a front page first
if (!in_array($tab, ['Contents', 'Milestones', 'Journey', 'Guides', 'Folk', 'Glossary'], true) && !isset($chapters[$tab])) {
    $tab = 'Contents';
}
// v0.7.72: seven sections, each with its chapters as chips
const ALMANAC_SECTIONS = [
    'contents' => ['📖', 'Contents', ['Contents']],
    'journey' => ['🧭', 'Journey', ['Journey', 'Callings', 'Treks', 'Milestones']],
    'growing' => ['🌱', 'Growing', ['Plants', 'Flowers', 'Guides']],
    'world' => ['🗺️', 'World', ['Regions', 'Towns', 'Villages', 'Landmarks']],
    'wild' => ['🐾', 'Wild', ['Creatures', 'Gathering']],
    'folk' => ['👥', 'Villagers & Recipes', ['Folk', 'Recipes']],
    'help' => ['📚', 'How to play', ['General', 'Glossary']],
];
$chapterLabel = fn(string $c) => ['General' => 'How to play', 'Towns' => 'Town lore', 'Contents' => 'Contents', 'Journey' => 'Wren’s Journey', 'Milestones' => 'Milestones',
    'Guides' => 'Guides', 'Folk' => 'Villagers', 'Glossary' => 'Glossary'][$c] ?? $c;
$section = 'contents';
foreach (ALMANAC_SECTIONS as $sk => [, , $chs]) if (in_array($tab, $chs, true)) $section = $sk;
require_once __DIR__ . '/includes/almanac_notes.php';
// Unread (✨ new) pages per chapter
$unread = [];
// v1.6.2: on day one only 3 "Start here" pages are marked new; the rest that unlocked at sign-up are quiet until the account is 2 days old
$quiet = [];
$firstUnlock = (string)q_val('SELECT MIN(unlocked_at) FROM user_encyclopedia WHERE user_id = ?', [$uid]);
if ($firstUnlock !== '' && time() - strtotime($firstUnlock . ' UTC') < 2 * 86400) {
    $cut = gmdate('Y-m-d H:i:s', strtotime($firstUnlock . ' UTC') + 120);
    $startIds = array_map('intval', q("SELECT id FROM encyclopedia_entries WHERE chapter = 'General' AND category = 'Getting started' ORDER BY sort_order, id LIMIT 3")->fetchAll(PDO::FETCH_COLUMN));
    foreach (q('SELECT ue.entry_id FROM user_encyclopedia ue WHERE ue.user_id = ? AND ue.read_at IS NULL AND ue.unlocked_at <= ?', [$uid, $cut])->fetchAll(PDO::FETCH_COLUMN) as $qid) {
        if (!in_array((int)$qid, $startIds, true)) $quiet[(int)$qid] = true;
    }
}
foreach (q('SELECT e.chapter, ue.entry_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND ue.read_at IS NULL', [$uid])->fetchAll() as $r) {
    if (!isset($quiet[(int)$r['entry_id']])) $unread[$r['chapter']] = ($unread[$r['chapter']] ?? 0) + 1;
}

// v0.7.61: every guide in the game, and which ones the player has read
$readKeys = array_fill_keys(q('SELECT guide_key FROM user_guides WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN), true);
$guides = [];
foreach (q("SELECT id, name, effects FROM items WHERE category = 'guide' ORDER BY name")->fetchAll() as $g) {
    $key = (string)((json_decode((string)$g['effects'], true) ?: [])['guide'] ?? '');
    $region = str_starts_with($key, 'region:') ? region_by_slug(substr($key, 7)) : null;
    $guides[] = [
        'name' => (string)$g['name'],
        'read' => isset($readKeys[$key]),
        'region' => $region,
        'plants' => $region ? (int)q_val('SELECT COUNT(*) FROM plant_regions WHERE region_id = ?', [$region['id']]) : 0,
    ];
}
$guidesRead = count(array_filter($guides, fn($g) => $g['read']));

[$have, $total] = almanac_counts($uid);

page_header('My Almanac');
?>
<div class="book">
  <h1>The Gardener’s Almanac</h1>
  <p class="muted">Property of <?= e(gnome_name($u)) ?><?= $u['title'] ? ', “' . e($u['title']) . '”' : '' ?>
    · <?= $have ?> of <?= $total ?> pages (<?= $total ? floor($have * 100 / $total) : 0 ?>%)</p>
  <progress max="<?= max(1, $total) ?>" value="<?= $have ?>"></progress>

  <?php $metN = (int)q_val('SELECT COUNT(DISTINCT n.id) FROM npcs n WHERE n.active = 1 AND (EXISTS (SELECT 1 FROM user_npc_met m WHERE m.user_id = ? AND m.npc_id = n.id) OR EXISTS (SELECT 1 FROM npc_friends f WHERE f.user_id = ? AND f.npc_id = n.id))', [$uid, $uid]); ?>
  <?php $chipCount = function (string $c) use ($chapters, $guidesRead, $guides, $metN, $unread): string {
      $n = $unread[$c] ?? 0;
      $base = match ($c) { 'Guides' => $guidesRead . '/' . count($guides), 'Folk' => $metN . '/' . (int)q_val('SELECT COUNT(*) FROM npcs WHERE active = 1'),
          'Contents', 'Journey', 'Milestones', 'Glossary' => '', default => isset($chapters[$c]) ? (int)$chapters[$c]['have'] . '/' . (int)$chapters[$c]['total'] : '' };
      return ($base !== '' ? ' <small>' . $base . '</small>' : '') . ($n ? ' <b class="newdot" role="img" aria-label="' . $n . ' new" title="' . $n . ' new">✨' . $n . '</b>' : '');
  };
  $secNew = function (array $chs) use ($unread): int { $n = 0; foreach ($chs as $c) $n += $unread[$c] ?? 0; return $n; }; ?>
  <?php // v1.6.3: sections and chapters are two dropdowns in one row (each its own GET form; site.js sends it when a choice changes) ?>
  <div class="pickrow">
    <form method="get" action="<?= e(url('book.php')) ?>" class="pickform">
      <label>Section <select name="ch" data-autosubmit>
        <?php foreach (ALMANAC_SECTIONS as $sk => [$ic, $label, $chs]): $sn = $secNew($chs); ?><option value="<?= e($chs[0]) ?>"<?= $sk === $section ? ' selected' : '' ?>><?= $ic ?> <?= e($label) ?><?= $sn ? ' ✨' : '' ?></option><?php endforeach; ?>
      </select></label><button class="btn small pickgo">Go</button>
    </form>
    <?php if (count(ALMANAC_SECTIONS[$section][2]) > 1): ?>
    <form method="get" action="<?= e(url('book.php')) ?>" class="pickform">
      <label>Chapter <select name="ch" data-autosubmit>
        <?php foreach (ALMANAC_SECTIONS[$section][2] as $c): if (!in_array($c, ['Milestones', 'Journey', 'Guides', 'Folk', 'Glossary'], true) && !isset($chapters[$c])) continue; ?><option value="<?= e($c) ?>"<?= $c === $tab ? ' selected' : '' ?>><?= e($chapterLabel($c)) ?><?= ($pc = trim(html_entity_decode(strip_tags($chipCount($c))))) !== '' ? ' (' . e($pc) . ')' : '' ?></option><?php endforeach; ?>
      </select></label><button class="btn small pickgo">Go</button>
    </form>
    <?php endif; ?>
  </div>

<?php if ($tab === 'Contents'):   // v0.7.72: the front page
    require_once __DIR__ . '/includes/journey.php';
    $qs = trim((string)($_GET['q'] ?? ''));
    $hits = $qs !== '' && mb_strlen($qs) >= 2 ? q('SELECT e.id, e.chapter, e.category, e.title FROM encyclopedia_entries e JOIN user_encyclopedia ue ON ue.entry_id = e.id AND ue.user_id = ?
                                     WHERE e.title LIKE ? OR e.body LIKE ? ORDER BY CASE WHEN e.title LIKE ? THEN 0 ELSE 1 END, e.title LIMIT 40',
                                     [$uid, '%' . $qs . '%', '%' . $qs . '%', '%' . $qs . '%'])->fetchAll() : [];
    // v0.7.79: pages you haven't found yet that match by title, with how to unlock them (hidden villages and landmarks stay hidden)
    $locked = $qs !== '' && mb_strlen($qs) >= 2 ? q("SELECT e.id, e.chapter, e.category, e.title, e.unlock_key, e.hint FROM encyclopedia_entries e
                                     WHERE e.title LIKE ? AND e.chapter NOT IN ('Villages', 'Landmarks')
                                     AND NOT EXISTS (SELECT 1 FROM user_encyclopedia ue WHERE ue.entry_id = e.id AND ue.user_id = ?) ORDER BY e.title LIMIT 15",
                                     ['%' . $qs . '%', $uid])->fetchAll() : [];
    $newPages = q('SELECT e.id, e.chapter, e.title FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id
                   WHERE ue.user_id = ? AND ue.read_at IS NULL ORDER BY ue.unlocked_at DESC, e.title LIMIT 80', [$uid])->fetchAll();
    $newPages = array_slice(array_values(array_filter($newPages, fn($np) => !isset($quiet[(int)$np['id']]))), 0, 12);   // v1.6.2
    $newTotal = array_sum($unread);
    $jc = journey_current($u);
    $jst = $jc ? journey_status($u, $jc) : null;
    $nextMs = q_one('SELECT m.* FROM almanac_milestones m WHERE m.active = 1 AND NOT EXISTS (SELECT 1 FROM user_milestones um WHERE um.milestone_id = m.id AND um.user_id = ?)
                     ORDER BY CASE m.kind WHEN \'pages\' THEN 0 WHEN \'percent\' THEN 1 ELSE 2 END, m.threshold, m.name LIMIT 1', [$uid]);
    $open = fn(array $en) => e(url('book.php?ch=' . urlencode((string)$en['chapter']) . '&open=' . (int)$en['id'] . '#e' . (int)$en['id'])); ?>
  <div class="bookwide contents">
    <form method="get" class="almsearch"><input type="hidden" name="ch" value="Contents">
      <input type="search" name="q" value="<?= e($qs) ?>" placeholder="Search your Almanac…" aria-label="Search your Almanac"> <button class="btn small">🔍 Search</button></form>
    <?php if ($qs !== ''): ?>
      <div class="box"><h3>🔍 “<?= e($qs) ?>” <small><?= count($hits) ?><?= count($hits) >= 40 ? '+' : '' ?> found</small></h3>
        <?php if (!$hits && !$locked): ?><p class="muted">Nothing in the Almanac by that name. Try another word.</p><?php elseif (!$hits): ?><p class="muted">Nothing on the pages you’ve found so far.</p><?php endif; ?>
        <ul class="hitlist"><?php foreach ($hits as $h): ?><li><a href="<?= $open($h) ?>"><?= e($h['title']) ?></a> <small class="muted"><?= e($chapterLabel((string)$h['chapter'])) ?> · <?= e((string)$h['category']) ?></small></li><?php endforeach; ?></ul>
        <?php if ($locked): require_once __DIR__ . '/includes/almanac_notes.php'; ?>
          <h4>🔒 Not found yet</h4>
          <ul class="hitlist"><?php foreach ($locked as $h): $hint = almanac_locked_hint($h); ?><li><b><?= e($h['title']) ?></b> <small class="muted"><?= e($chapterLabel((string)$h['chapter'])) ?></small><?= $hint !== '' ? '<br><small>💡 ' . e($hint) . '</small>' : '' ?></li><?php endforeach; ?></ul>
        <?php endif; ?>
      </div>
    <?php endif; ?>
    <div class="cgrid">
      <div class="box ccard"><h3>✨ New pages <small><?= $newTotal ?></small></h3>
        <?php if ($newPages): ?><ul class="hitlist"><?php foreach ($newPages as $np): ?><li><a href="<?= $open($np) ?>"><?= e($np['title']) ?></a> <small class="muted"><?= e($chapterLabel((string)$np['chapter'])) ?></small></li><?php endforeach; ?></ul>
          <?php if ($newTotal > count($newPages)): ?><p class="help">…and <?= $newTotal - count($newPages) ?> more, marked ✨ in their chapters.</p><?php endif; ?>
        <?php else: ?><p class="muted">You’ve read everything you’ve found. New pages appear as you grow, travel and explore.</p><?php endif; ?>
        <?php if ($quiet): ?><p class="help">📚 <?= count($quiet) ?> more pages are waiting in <a href="<?= e(url('book.php?ch=General')) ?>">How to play</a> and your other chapters. Read them whenever you like.</p><?php endif; /* v1.6.2 */ ?></div>
      <div class="box ccard"><h3>🧭 Next steps</h3>
        <?php if ($jc): $jr = journey_ready($u, $jst); $jn = count(array_filter($jst['tasks'], fn($t) => $t[3])); ?>
          <p><a href="<?= e(url('book.php?ch=Journey&j=' . (int)$jc['id'])) ?>"><?= e($jc['project_icon'] . ' ' . $jc['region'] . ': ' . $jc['title']) ?></a><br><small><?= $jn ?> of <?= count($jst['tasks']) ?> done<?= $jr ? ' · <b>✋ ' . ($jr === 'finish' ? 'ready to finish' : 'a stage is ready to hand in') . '</b>' : '' ?></small></p>
        <?php else: ?><p class="muted">No Journey chapter on the go: one starts when you reach a new region.</p><?php endif; ?>
        <?php if ($nextMs): $mp = almanac_milestone_progress($uid, $nextMs, $have, $total); ?>
          <p>🏆 <a href="<?= e(url('book.php?ch=Milestones')) ?>"><?= e($nextMs['name']) ?></a><br><small><?= e(almanac_goal_text($nextMs)) ?><?= $mp ? ' · ' . (int)$mp['now'] . '/' . (int)$mp['goal'] . e($mp['unit']) : '' ?></small></p>
        <?php endif; ?>
        <p class="help">📚 New here? Start with <a href="<?= e(url('book.php?ch=General')) ?>">How to play</a>.</p></div>
      <?php // v0.7.72: recently found, and the region medals you're closest to
      $recent = q('SELECT e.id, e.chapter, e.title FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id
                   WHERE ue.user_id = ? ORDER BY ue.unlocked_at DESC, e.id DESC LIMIT 8', [$uid])->fetchAll();
      $near = [];
      foreach (q('SELECT r.id, r.gnomish_name, r.code FROM regions r WHERE EXISTS (SELECT 1 FROM region_visits v WHERE v.user_id = ? AND v.region_id = r.id)', [$uid])->fetchAll() as $rg) {
          $t = region_tier_progress($uid, (int)$rg['id']);
          if ($t['gold']) continue;
          [$medal, $parts] = !$t['bronze'] ? ['🥉 Bronze', ['staple']] : (!$t['silver'] ? ['🥈 Silver', ['staple', 'uncommon']] : ['🥇 Gold', ['staple', 'uncommon', 'treasure', 'flower']]);
          $h = 0; $nd = 0;
          foreach ($parts as $pt) { $need = max(1, (int)$t[$pt]['need']); $h += min((int)$t[$pt]['have'], $need); $nd += $need; }
          if ($nd > 0) $near[] = [$h / $nd, $medal . ' in ' . $rg['gnomish_name'], $h, $nd, (int)q_val('SELECT id FROM encyclopedia_entries WHERE unlock_key = ?', ['region:' . strtolower((string)$rg['code'])])];
      }
      usort($near, fn($a, $b) => $b[0] <=> $a[0]);
      $near = array_slice($near, 0, 3); ?>
      <div class="box ccard"><h3>🕒 Recently found</h3>
        <?php if ($recent): ?><ul class="hitlist"><?php foreach ($recent as $rp): ?><li><a href="<?= $open($rp) ?>"><?= e($rp['title']) ?></a> <small class="muted"><?= e($chapterLabel((string)$rp['chapter'])) ?></small></li><?php endforeach; ?></ul>
        <?php else: ?><p class="muted">Nothing yet.</p><?php endif; ?></div>
      <div class="box ccard"><h3>📈 Nearly there</h3>
        <?php if ($near): foreach ($near as [$frac, $label, $h, $nd, $eid]): ?>
          <p><?= e($label) ?><br><progress max="<?= $nd ?>" value="<?= $h ?>"></progress> <small><?= $h ?>/<?= $nd ?> crops grown</small></p>
        <?php endforeach; ?><p class="help">Medals come from growing a region’s crops: every staple (bronze), then every uncommon (silver), then every treasure and flower (gold).</p>
        <?php else: ?><p class="muted">Visit a region and grow its crops to start on its medals.</p><?php endif; ?></div>
    </div>
    <div class="secgrid">
      <?php foreach (ALMANAC_SECTIONS as $sk => [$ic, $label, $chs]): if ($sk === 'contents') continue;
          $h = 0; $tt = 0;
          foreach ($chs as $c) if (isset($chapters[$c])) { $h += (int)$chapters[$c]['have']; $tt += (int)$chapters[$c]['total']; }
          if ($sk === 'journey') { $tt = count(journey_chapters()); $h = (int)q_val('SELECT COUNT(*) FROM user_quests WHERE user_id = ? AND done_at IS NOT NULL', [$uid]); }
          if ($sk === 'growing') { $h += $guidesRead; $tt += count($guides); }
          if ($sk === 'folk') { $h += $metN; $tt += (int)q_val('SELECT COUNT(*) FROM npcs WHERE active = 1'); }
          $sn = $secNew($chs); ?>
        <a class="box seccard" href="<?= e(url('book.php?ch=' . urlencode($chs[0]))) ?>">
          <span class="secicon"><?= $ic ?></span><b><?= e($label) ?></b>
          <small class="muted"><?= e(implode(' · ', array_map($chapterLabel, $chs))) ?></small>
          <?php if ($tt): ?><progress max="<?= $tt ?>" value="<?= $h ?>"></progress><small><?= $h ?> of <?= $tt ?><?= $sk === 'journey' ? ' chapters' : '' ?><?= $sn ? ' · ✨ ' . $sn . ' new' : '' ?></small><?php endif; ?>
        </a>
      <?php endforeach; ?>
    </div>
  </div>

<?php elseif ($tab === 'Milestones'):
    $earnedTitles = q('SELECT DISTINCT m.reward_title FROM user_milestones um JOIN almanac_milestones m ON m.id = um.milestone_id
                       WHERE um.user_id = ? AND m.reward_title IS NOT NULL ORDER BY m.reward_title', [$uid])->fetchAll(PDO::FETCH_COLUMN);
    require_once __DIR__ . '/includes/journey.php';
    $earnedTitles = array_values(array_unique(array_merge($earnedTitles, journey_titles($uid), calling_titles($uid), (function () use ($uid) { require_once __DIR__ . '/includes/stop_pass.php'; return stop_titles($uid); })())));
    if ($earnedTitles): ?>
  <form method="post" class="titlepick"><?= csrf_field() ?>
    <label>Your title <select name="title"><option value="">— none —</option>
      <?php foreach ($earnedTitles as $tt): ?><option <?= $u['title'] === $tt ? 'selected' : '' ?>><?= e($tt) ?></option><?php endforeach; ?>
    </select></label> <button class="btn small">Use title</button></form>
<?php endif;
    $ms = q('SELECT m.*, um.achieved_at, i.name AS item_name FROM almanac_milestones m
             LEFT JOIN user_milestones um ON um.milestone_id = m.id AND um.user_id = ?
             LEFT JOIN items i ON i.id = m.reward_item_id
             WHERE m.active = 1 ORDER BY m.kind DESC, m.threshold, m.name', [$uid])->fetchAll();
    // Show what's been earned, then only the next 10 to aim for (the rest stay a surprise)
    $earnedMs = array_values(array_filter($ms, fn($m) => $m['achieved_at']));
    $openMs = array_values(array_filter($ms, fn($m) => !$m['achieved_at']));
    usort($openMs, fn($a, $b) => [(int)$a['threshold'], $a['name']] <=> [(int)$b['threshold'], $b['name']]);
    $hidden = max(0, count($openMs) - 10);
    $ms = array_merge(array_slice($openMs, 0, 10), $earnedMs);
    // v0.7.61: the shown milestones, grouped by kind, each with a short explanation
    $groupInfo = [
        'pages' => ['📖 Page count', 'Every new Almanac page counts: grow new plants, visit villages and find landmarks.'],
        'percent' => ['📊 How full the Almanac is', 'Rewards for filling in a share of the whole book.'],
        'soil' => ['🪱 Soil grades', 'Raise your no-till beds to better soil grades. Better soil grows faster and gives bigger harvests.'],
        'regions' => ['🗺️ Region medals', 'Grow every staple (Bronze), every uncommon (Silver), and every treasure and flower (Gold) of a region. Each medal includes the ones before it.'],
        'other' => ['✨ Other milestones', 'Special goals.'],
    ];
    $groups = [];
    foreach ($ms as $m) $groups[almanac_milestone_group($m)][] = $m;
    // Each region's medals read Bronze, Silver, Gold
    if (!empty($groups['regions'])) {
        $rank = ['bronze' => 0, 'silver' => 1, 'gold' => 2];
        $tierOf = fn(array $m) => $rank[substr(strrchr((string)$m['unlock_key'], ':') ?: '', 1)] ?? 3;
        usort($groups['regions'], fn($a, $b) => [explode(' — ', (string)$a['name'])[0], $tierOf($a)]
                                              <=> [explode(' — ', (string)$b['name'])[0], $tierOf($b)]);
    } ?>
  <div class="bookwide">
    <p class="intro">🏆 <b>Milestones</b> are rewards for filling in your Almanac and growing things. Reach a goal and its reward arrives on its own, so keep growing, visiting and exploring.</p>
    <p class="help">🎯 Your next <?= min(10, count($openMs)) ?> milestones<?= $hidden ? ' — and ' . $hidden . ' more waiting to be discovered' : '' ?>. <?= count($earnedMs) ?> earned so far.</p>
    <?php foreach ($groupInfo as $gk => [$gTitle, $gBlurb]):
        if (empty($groups[$gk])) continue; ?>
      <h3 class="mgroup"><?= e($gTitle) ?></h3>
      <p class="mblurb"><?= e($gBlurb) ?></p>
      <ul class="mcards">
        <?php foreach ($groups[$gk] as $m):
            $done = (bool)$m['achieved_at'];
            $prog = $done ? null : almanac_milestone_progress($uid, $m, $have, $total);
            $reward = [];
            if ((int)$m['reward_coins']) $reward[] = money((int)$m['reward_coins']);
            if ($m['item_name']) $reward[] = (int)$m['reward_qty'] . ' × ' . e($m['item_name']);
            if ($m['reward_title']) $reward[] = 'the title “' . e($m['reward_title']) . '”'; ?>
          <li class="mcard<?= $done ? ' done' : '' ?>">
            <p class="mtop"><span class="mic" aria-hidden="true"><?= $done ? '🏆' : '🎯' ?></span> <b><?= e($m['name']) ?></b></p>
            <p class="mgoal"><?= e(almanac_goal_text($m)) ?></p>
            <?php if ($prog): ?>
              <p class="mprog"><progress max="<?= (int)$prog['goal'] ?>" value="<?= (int)$prog['now'] ?>"></progress>
                <small><?= (int)$prog['now'] ?> / <?= (int)$prog['goal'] ?><?= e($prog['unit']) ?></small></p>
            <?php else: ?>
              <p class="mprog"><small><?= $done ? '✔ Earned' : 'Not yet' ?></small></p>
            <?php endif; ?>
            <p class="mreward">Reward: <?= $reward ? implode(', ', $reward) : 'none' ?></p>
          </li>
        <?php endforeach; ?>
      </ul>
    <?php endforeach; ?>
  </div>

<?php elseif ($tab === 'Journey'):
    require_once __DIR__ . '/includes/journey_view.php';
    journey_view($u); ?>

<?php elseif ($tab === 'Guides'): ?>
  <div class="bookwide">
    <h2>📗 Gardening guides <small><?= $guidesRead ?> of <?= count($guides) ?> read</small></h2>
    <p class="intro">You can plant any seed, but crops from a region you haven’t studied grow <?= unstudied_slow_pct($u) ?>% slower and give <?= 100 - unstudied_yield_pct($u) ?>% less. Study a region to grow all its crops properly:
      📗 buy its guide in a shop (about <?= money((int)setting('guide_price')) ?>) and read it from your Satchel, or 🧭 finish its chapter of Wren’s Journey, which gives you the guide for free. Mastering a single crop by growing it teaches you that one, too.</p>
    <?php if (!$guides): ?><p class="muted">There are no guides in the Hollow yet.</p><?php endif; ?>
    <div class="gtiles">
      <?php foreach ($guides as $g): ?>
        <div class="gtile<?= $g['read'] ? ' read' : '' ?>">
          <span class="gicon" aria-hidden="true">📗</span>
          <b class="gname"><?= e($g['name']) ?></b>
          <span class="gstate"><?= $g['read'] ? '✔ Read' : 'Not read yet' ?></span>
          <span class="gmeta"><?= $g['region'] ? e($g['region']['gnomish_name']) : 'Unknown region' ?> · <?= (int)$g['plants'] ?> plants</span>
        </div>
      <?php endforeach; ?>
    </div>
  </div>

<?php elseif ($tab === 'Folk'):   // v0.7.69: a page for everyone you've met, filling in as you get to know them
    require_once __DIR__ . '/includes/folk_list.php';
    $met = [];
    foreach (met_npcs($uid) as $n) $met[(int)$n['id']] = $n;
    $everyone = q('SELECT n.*, COALESCE(s.region, l.region) AS hregion FROM npcs n LEFT JOIN town_spots s ON s.id = n.fav_spot_id LEFT JOIN locations l ON l.id = n.home_location_id
                   WHERE n.active = 1 ORDER BY COALESCE(s.region, l.region, \'~\'), n.name')->fetchAll();
    $sel = $met[(int)($_GET['n'] ?? 0)] ?? null; ?>
  <div class="bookwide">
    <h2>👥 Villagers of the Hollow <small><?= count($met) ?> of <?= count($everyone) ?> met</small></h2>
    <p class="intro">A page for everyone you meet. It fills in as you get to know them: their tastes as you give gifts, their birthday once you’re acquainted. See where everyone is right now on <a href="<?= e(url('town.php?view=villagers')) ?>">Villagers you know</a>.</p>
    <?php if ($sel): $lv = $sel['level']; $tastes = known_tastes(friendship($uid, (int)$sel['id']), $sel);
        $work = q('SELECT DISTINCT sh.id, sh.name FROM npc_schedules s JOIN shops sh ON sh.id = s.shop_id WHERE s.npc_id = ?', [$sel['id']])->fetchAll(); ?>
      <article class="bookpage folkpage" id="np">
        <div class="npchead"><?= npc_portrait($sel) ?><div>
          <h2><?= npc_icon($sel['species']) ?> <?= e($sel['name']) ?></h2>
          <p class="muted"><?= e(trim($sel['personality'] . ' ' . strtolower((string)$sel['species']))) ?><?= !empty($sel['traveller']) ? ' · traveller' : '' ?></p>
          <p>💛 <?= e($lv['name']) ?><?= $lv['discount'] ? ' · 🏷️ ' . (int)$lv['discount'] . '% off' : '' ?></p>
          <p>🏡 <?= $sel['home'] ? e($sel['home']['name'] . ', ' . $sel['home']['region']) : (!empty($sel['traveller']) ? 'Travels the Hollow' : '—') ?></p>
          <?php if ($work): ?><p>🏪 Works at <?= e(implode(', ', array_column($work, 'name'))) ?></p><?php endif; ?>
          <p>🎂 <?= $lv['index'] >= 1 ? e(npc_birthday_text($sel)) : '<span class="muted">get acquainted to find out</span>' ?></p>
        </div></div>
        <?php if ($sel['bio']): ?><div class="ptext"><p><?= e($sel['bio']) ?></p></div><?php endif; ?>
        <p><b>🎁 Tastes:</b> <?= $tastes ? e(implode(' · ', $tastes)) : '<span class="muted">not discovered yet: try a few gifts</span>' ?></p>
        <p class="help">First met: <?= $sel['first_at'] ? e(hollow_date('j F Y', (int)strtotime($sel['first_at'] . ' UTC'))) : 'a while ago' ?> · <a href="<?= e(url('folk.php?id=' . (int)$sel['id'])) ?>">Open their page (chat, gifts, where they are) →</a></p>
      </article>
    <?php endif; ?>
    <?php $lastR = null; foreach ($everyone as $n):
        if ($n['hregion'] !== $lastR): if ($lastR !== null) echo '</div>'; $lastR = $n['hregion']; ?>
          <h3><?= e($lastR ?: 'Wanderers') ?></h3><div class="ctiles">
        <?php endif;
        $m = $met[(int)$n['id']] ?? null; ?>
        <?php if ($m): ?>
          <a class="ctile<?= $sel && (int)$sel['id'] === (int)$n['id'] ? ' cur' : '' ?>" href="<?= e(url('book.php?ch=Folk&n=' . (int)$n['id'] . '#np')) ?>"><span class="ci"><?= npc_icon($n['species']) ?></span><span class="cn"><?= e($n['name']) ?></span><small class="muted"><?= e($m['level']['name']) ?></small></a>
        <?php else: ?>
          <span class="ctile locked" title="Not met yet"><span class="ci">👤</span><span class="cn">???</span></span>
        <?php endif; ?>
    <?php endforeach; if ($lastR !== null) echo '</div>'; ?>
  </div>

<?php elseif ($tab === 'Glossary'):
    $terms = GLOSSARY;
    ksort($terms, SORT_FLAG_CASE | SORT_STRING);
    $byLetter = [];
    foreach ($terms as $term => $def) $byLetter[strtoupper(substr($term, 0, 1))][$term] = $def; ?>
  <div class="bookwide">
    <h2>📚 Glossary</h2>
    <p class="intro">The words you will meet around the Hollow, in plain English.</p>
    <nav class="gletters" aria-label="Jump to a letter">
      <?php foreach (array_keys($byLetter) as $L): ?><a href="#gl-<?= e($L) ?>"><?= e($L) ?></a><?php endforeach; ?>
    </nav>
    <?php foreach ($byLetter as $L => $list): ?>
      <h3 class="gletter" id="gl-<?= e($L) ?>"><?= e($L) ?></h3>
      <dl class="glossary">
        <?php foreach ($list as $term => $def): ?>
          <dt id="gt-<?= e(strtolower((string)preg_replace('/[^a-z0-9]+/i', '-', $term))) ?>"><?= e($term) ?></dt>
          <dd><?= e($def) ?></dd>
        <?php endforeach; ?>
      </dl>
    <?php endforeach; ?>
  </div>

<?php else:
    $entries = q('SELECT e.*, ue.unlocked_at, ue.read_at FROM encyclopedia_entries e
                  LEFT JOIN user_encyclopedia ue ON ue.entry_id = e.id AND ue.user_id = ?
                  WHERE e.chapter = ? ORDER BY e.category, e.sort_order, e.title', [$uid, $tab])->fetchAll();
    // v0.7.27: a real book. Left page: this chapter's contents. Right page: the page you've opened. Turn pages in order.
    $readable = [];   // page number => entry (unlocked or studied)
    foreach ($entries as $i => $en) {
        $entries[$i]['_n'] = $i + 1;
        $entries[$i]['_studied'] = !$en['unlocked_at'] && isset($studied[$en['unlock_key']]);
        if ($en['unlocked_at'] || $entries[$i]['_studied']) $readable[$i + 1] = $entries[$i];
    }
    $openId = (int)($_GET['open'] ?? 0);
    $cur = null;
    foreach ($readable as $n => $en) if ((int)$en['id'] === $openId) $cur = $en;
    $cur ??= $readable ? reset($readable) : null;
    if ($cur && $openId && $cur['unlocked_at']) q('UPDATE user_encyclopedia SET read_at = ? WHERE user_id = ? AND entry_id = ? AND read_at IS NULL', [now(), $uid ?? (int)$u['id'], $cur['id']]);   // v0.7.48
    $nums = array_keys($readable);
    $pos = $cur ? array_search($cur['_n'], $nums, true) : false;
    $prev = $pos !== false && $pos > 0 ? $readable[$nums[$pos - 1]] : null;
    $next = $pos !== false && $pos < count($nums) - 1 ? $readable[$nums[$pos + 1]] : null;
    $link = fn(array $en) => e(url('book.php?ch=' . urlencode($tab) . '&open=' . (int)$en['id'] . '#e' . (int)$en['id']));
    $byCat = [];
    foreach ($entries as $en) $byCat[$en['category']][] = $en;
    // v0.7.61: a tile per page, with a picture for its chapter (plants get their kind's picture)
    $chapterIcon = ['General' => '📜', 'Plants' => '🌱', 'Flowers' => '🌸', 'Regions' => '🗺️', 'Villages' => '🏘️', 'Towns' => '🏘️',
        'Landmarks' => '🏛️', 'Creatures' => '🐾', 'Gathering' => '🍄', 'Recipes' => '🍲'];
    $kindBySlug = [];
    if ($tab === 'Plants') {
        foreach (q('SELECT slug, kind FROM plants WHERE slug IS NOT NULL')->fetchAll() as $p) $kindBySlug[(string)$p['slug']] = (string)$p['kind'];
    }
    $iconFor = function (array $en, string $size = 'md') use ($tab, $chapterIcon, $kindBySlug): string {
        $key = (string)$en['unlock_key'];
        if (str_starts_with($key, 'item:') && ($pic = item_pic(['slug' => substr($key, 5)], $size)) !== '') return $pic;   // v0.9.8: an item's picture
        if ($tab === 'Plants' && str_starts_with($key, 'plant:')) return catalog_kind_icon($kindBySlug[substr($key, 6)] ?? '');
        return $chapterIcon[$tab] ?? '📜';
    }; ?>
  <?php // v0.7.72: filter the tiles by category and by found / not found / new
  $fcat = (string)($_GET['cat'] ?? '');
  if (!isset($byCat[$fcat])) $fcat = '';
  $fshow = in_array($_GET['show'] ?? '', ['found', 'missing', 'new'], true) ? (string)$_GET['show'] : '';
  // v1.7.3: Plants / Flowers can be filtered by region and tier ("staples of The Maplewold")
  $plantCh = in_array($tab, ['Plants', 'Flowers'], true);
  $freg = $plantCh ? (int)($_GET['reg'] ?? 0) : 0;
  $ftier = $plantCh && in_array($_GET['tier'] ?? '', ['staple', 'uncommon', 'treasure', 'flower'], true) ? (string)$_GET['tier'] : '';
  $tierOf = [];
  if ($plantCh) foreach (q('SELECT p.slug, pr.region_id, pr.tier FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id WHERE p.slug IS NOT NULL')->fetchAll() as $r) $tierOf[(string)$r['slug']][(int)$r['region_id']] = (string)$r['tier'];
  $regionOk = function (array $x) use ($freg, $ftier, $tierOf): bool {
      if (!$freg && $ftier === '') return true;
      $k = (string)$x['unlock_key'];
      if (!str_starts_with($k, 'plant:')) return false;
      $m = $tierOf[substr($k, 6)] ?? [];
      if ($freg) return isset($m[$freg]) && ($ftier === '' || $m[$freg] === $ftier);
      return in_array($ftier, $m, true);
  };
  $furl = fn(string $c, string $sh) => e(url('book.php?ch=' . urlencode($tab) . ($c !== '' ? '&cat=' . urlencode($c) : '') . ($sh !== '' ? '&show=' . $sh : '')));
  $keepF = ($fcat !== '' ? '&cat=' . urlencode($fcat) : '') . ($fshow !== '' ? '&show=' . $fshow : '') . ($freg ? '&reg=' . $freg : '') . ($ftier !== '' ? '&tier=' . $ftier : '');
  $link = fn(array $en) => e(url('book.php?ch=' . urlencode($tab) . $keepF . '&open=' . (int)$en['id'] . '#e' . (int)$en['id']));
  // Turning pages stays inside the filter you chose
  $freadable = array_values(array_filter($readable, fn($x) => ($fcat === '' || $x['category'] === $fcat) && ($fshow !== 'new' || ($x['unlocked_at'] && !$x['read_at'])) && $regionOk($x)));
  if ($cur && ($fcat !== '' || $fshow === 'new' || $freg || $ftier !== '')) {
      $pi = array_search((int)$cur['id'], array_map(fn($x) => (int)$x['id'], $freadable), true);
      if ($pi !== false) { $prev = $freadable[$pi - 1] ?? null; $next = $freadable[$pi + 1] ?? null; }
  }
  if (count($byCat) > 1 || count($entries) > 12): ?>
    <div class="almfilter">
      <?php // v1.6.3: category and found/new are two dropdowns in one row ?>
      <form method="get" action="<?= e(url('book.php')) ?>" class="pickform"><input type="hidden" name="ch" value="<?= e($tab) ?>">
        <?php if (count($byCat) > 1): ?><label>Show <select name="cat" data-autosubmit><option value="">All</option><?php foreach ($byCat as $cn => $cl): ?><option value="<?= e((string)$cn) ?>"<?= $fcat === (string)$cn ? ' selected' : '' ?>><?= e((string)$cn) ?> (<?= count($cl) ?>)</option><?php endforeach; ?></select></label><?php endif; ?>
        <label>Pages <select name="show" data-autosubmit><?php foreach (['' => 'Everything', 'found' => '✔ Found', 'missing' => '??? Not found', 'new' => '✨ New'] as $k => $lab): ?><option value="<?= e($k) ?>"<?= $fshow === $k ? ' selected' : '' ?>><?= $lab ?></option><?php endforeach; ?></select></label>
        <?php if ($plantCh): ?>
        <label>Region <select name="reg" data-autosubmit><option value="0">Any</option><?php foreach (all_regions() as $rg): ?><option value="<?= (int)$rg['id'] ?>"<?= $freg === (int)$rg['id'] ? ' selected' : '' ?>><?= e($rg['gnomish_name']) ?></option><?php endforeach; ?></select></label>
        <label>Kind <select name="tier" data-autosubmit><?php foreach (['' => 'Any', 'staple' => '🌾 Staples', 'uncommon' => 'Uncommon', 'treasure' => '💎 Treasures', 'flower' => '🌸 Flowers'] as $k => $lab): ?><option value="<?= e($k) ?>"<?= $ftier === $k ? ' selected' : '' ?>><?= $lab ?></option><?php endforeach; ?></select></label>
        <?php endif; ?>
        <button class="btn small pickgo">Go</button>
      </form>
    </div>
  <?php endif; ?>
  <div class="spread<?= $openId ? ' reading' : '' ?>">
    <div class="leaf left">
      <h2><?= e($chapterLabel($tab)) ?> <small><?= (int)($chapters[$tab]['have'] ?? 0) ?>/<?= (int)($chapters[$tab]['total'] ?? 0) ?></small></h2>
      <details class="toc" id="toc" open><summary>Contents</summary>
      <?php foreach ($byCat as $cat => $list):
          if ($fcat !== '' && $cat !== $fcat) continue;
          $list = array_values(array_filter($list, fn($x) => $regionOk($x) && ($fshow === '' || ($fshow === 'found' && $x['unlocked_at']) || ($fshow === 'missing' && !$x['unlocked_at']) || ($fshow === 'new' && $x['unlocked_at'] && !$x['read_at']))));
          if (!$list && ($fshow !== '' || $freg || $ftier !== '')) continue;
          $n = count(array_filter($list, fn($x) => $x['unlocked_at'])); ?>
        <h3><?= e($cat) ?> <small><?= $n ?>/<?= count($list) ?></small></h3>
        <div class="ctiles">
        <?php foreach ($list as $en):
            $isCur = $cur && (int)$cur['id'] === (int)$en['id'];
            $icon = $iconFor($en);
            if ($en['unlocked_at'] || $en['_studied']): ?>
          <a class="ctile<?= $isCur ? ' cur' : '' ?><?= $en['_studied'] && !$en['unlocked_at'] ? ' studied' : '' ?><?= $en['unlocked_at'] && !$en['read_at'] && !$isCur && !isset($quiet[(int)$en['id']]) ? ' new' : '' ?>" href="<?= $link($en) ?>" title="<?= e($en['title']) ?>">
            <?php if ($en['unlocked_at'] && !$en['read_at'] && !$isCur && !isset($quiet[(int)$en['id']])): ?><span class="newbadge" role="img" aria-label="New" title="New">✨</span><?php endif; ?>
            <span class="ci" aria-hidden="true"><?= $icon ?></span>
            <span class="cn"><?= e($en['title']) ?></span>
            <?php if ($en['_studied'] && !$en['unlocked_at']): ?><span class="tag">studied</span><?php endif; ?>
          </a>
            <?php else:
              $hint = trim(almanac_locked_hint($en)); ?>
          <span class="ctile locked" title="<?= e($hint !== '' ? $hint : 'Not found yet') ?>">
            <span class="ci" aria-hidden="true"><?= $icon ?></span>
            <span class="cn"><?= $tab === 'Regions' ? e($en['title']) : '???' ?></span>
            <?php if ($hint !== ''): ?><span class="chint"><?= e($hint) ?></span><?php endif; ?>
          </span>
            <?php endif; ?>
        <?php endforeach; ?>
        </div>
      <?php endforeach; ?>
      </details>
    </div>
    <div class="leaf right">
      <?php if ($cur): ?>
        <article class="bookpage" id="e<?= (int)$cur['id'] ?>">
          <a class="tocjump" href="#toc">☰ Contents</a>
          <div class="bpicon" aria-hidden="true"><?= $iconFor($cur, 'lg') ?></div>
          <p class="pcat"><?= e($cur['category']) ?></p>
          <h2><?= e($cur['title']) ?><?= isset($tastedPlants[substr((string)$cur['unlock_key'], 6)]) && str_starts_with((string)$cur['unlock_key'], 'plant:') ? ' <span class="tag">🍴 tasted</span>' : '' ?></h2>
          <?php $bodyText = (string)$cur['body'];
          if (str_starts_with((string)$cur['unlock_key'], 'plant:')) $bodyText = (string)preg_replace('/\n*\[b\]Grows in:\[\/b\][^\n]*/u', '', $bodyText);   // v0.7.72: the live 🌱 Growing box replaces these old numbers ?>
          <div class="ptext"><?= almanac_glossary_links(format_text($bodyText)) ?></div>
          <?= $cur['unlocked_at'] || $cur['_studied'] ? almanac_notes($u, $cur) : '' ?>
          <?php if ($cur['_studied']): ?><p class="hint">Grow it to complete this page.</p><?php endif; ?>
        </article>
        <nav class="turn">
          <?php if ($prev): ?><a class="btn alt" href="<?= $link($prev) ?>">← <?= e($prev['title']) ?></a><?php else: ?><span></span><?php endif; ?>
          <span class="pno">page <?= (int)$cur['_n'] ?> of <?= count($entries) ?></span>
          <?php if ($next): ?><a class="btn alt" href="<?= $link($next) ?>"><?= e($next['title']) ?> →</a><?php else: ?><span></span><?php endif; ?>
        </nav>
      <?php else: ?>
        <div class="bookpage blank"><p class="muted">These pages are still blank. They’ll fill themselves in as you discover things.</p></div>
      <?php endif; ?>
    </div>
  </div>
<?php endif; ?>
</div>
<?php page_footer();
