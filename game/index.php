<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';

$allNews = isset($_GET['news']);   // v0.7.55: every post, not just the latest few
$newsTab = $allNews && ($_GET['tab'] ?? '') === 'notes' ? 'notes' : 'news';   // two tabs: News and Release notes
$news = q('SELECT title, body, created_at FROM news WHERE published = 1 AND kind = ? ORDER BY created_at DESC, id DESC LIMIT ' . ($allNews ? 200 : 5), [$newsTab])->fetchAll();
$freshNews = $news && strtotime($news[0]['created_at'] . ' UTC') > time() - 3 * 86400;
$u = current_user();
$today = $u && (int)($u['onboarded'] ?? 1) === 1;   // v0.7.48: a "Today" page for players
// Next version: Today is the TODAY tab of the home page (gnome.php). Every old address lands there: index.php, ?today=1, and the
// old ?t=out / ?t=hollow links on their part of it. Only ?news=all (every news post) still draws here.
if (!$allNews && $u && $today) redirect('gnome.php' . (($_GET['t'] ?? '') === 'out' ? '#todaycards' : (($_GET['t'] ?? '') === 'hollow' ? '#hollowtoday' : '')));
if ($today) $GLOBALS['gv_today_page'] = true;   // v1.9.2: layout.php hides the rail boxes this page already shows
if ($today) {   // the Today cards live in includes/today_view.php (gnome.php shows them on its TODAY tab)
    require_once __DIR__ . '/includes/today_view.php';
    $tctx = today_prepare($u, $allNews);
    $u = $tctx['u'];
}
if (!$u) {   // v0.8.8: what search engines and link previews see
    require_once __DIR__ . '/includes/site_text.php';   // v0.8.9: front page words are editable in Admin → Page text
    seo_set(['title' => stext('home.title'), 'jsonld' => seo_game_jsonld(), 'canonical' => 'index.php']);
    require_once __DIR__ . '/includes/puzzles.php';   // v2.0.69: the front page lets visitors play a GIFsaw (no login, no rewards)
    $pzFront = setting('puzzles_front') !== '0' && ($pzFrontList = array_slice(array_map('puzzle_js_row', puzzle_pics()), 0, 3)) !== [];
    if ($pzFront) $GLOBALS['gv_front_demo'] = true;   // layout.php then loads assets/puzzles.css + puzzles.js
    require_once __DIR__ . '/includes/landing_view.php'; $GLOBALS['gv_landing'] = true;   // 2.6.41: the landing card and How to play (layout.php then loads assets/landing.js)
}
page_header('Home');
?>
<?php if ($today): ?>
<div class="todaypage">
<?= today_head_html($u, $tctx) ?>
<?= today_html($u, $tctx, ['filler' => true]) ?>
</div>
<?php elseif (!$u): ?>
<?php // v0.8.6: a front page that says what the game is, for visitors who've never played ?>
<section class="lp"><?php // v1.6.3: short, phone-first front page. v2.0.29: Hearthlight look. v2.0.73: Jeff the Puzzler shows visitors around with screenshots of the current game (tests/shots.sh) ?>
  <?= landing_html() /* 2.6.41: the landing card and How to play (includes/landing_view.php); Jeff's screenshot tour is retired */ ?>
  <?php if ($pzFront): $t = null; $pzDemo = true; ?>
  <h2 class="lp-h2" id="try">Try a puzzle</h2>
  <div class="lp-say lp-sayrow"><?= puzzle_cast('jeff-cheer', 'Jeff', 'lp-sayface') ?><p class="lp-bubble"><?= e(stext('home.try')) ?></p></div>
  <div id="pz" class="lp-try">
    <div id="lib">
      <ul class="pzgrid" id="grid"></ul>
    </div>
    <?php require __DIR__ . '/includes/gifsaw_play.php'; ?>
  </div>
  <script type="application/json" id="pz-data"><?= json_encode($pzFrontList, JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?></script>
  <?php endif; ?>
  <div class="lp-hero lp-jeff lp-gate">
    <?= puzzle_cast('jeff-key', 'Jeff with a key', 'lp-jeffface') ?>
    <p class="lp-bubble"><b>Jeff:</b> “<?= e(stext('home.gate')) ?>”</p>
  </div>
  <div class="lp-cta lp-end">
    <a class="btn lp-big" href="<?= e(url('register.php')) ?>"><?= e(stext('home.cta')) ?></a>
    <?php if (setting('guest_open') === '1'): ?><a class="btn ghost lp-big" href="<?= e(url('guest.php')) ?>"><?= e(stext('home.guestbtn')) ?></a><?php endif; ?>
    <a class="btn ghost lp-big" href="<?= e(url('guide.php')) ?>">📖 How to play</a>
    <a class="lp-login" href="<?= e(url('login.php')) ?>">Already a gnome? <b>Log in</b></a>
  </div>
  <?php if (!in_array(trim((string)setting('motd')), ['', 'Welcome, new gardener! Open your Almanac to begin.'], true)): ?><p class="help lmotd"><?= format_text(setting('motd')) ?></p><?php endif; ?>
</section>
<?php else: ?>
<div class="box welcome">
  <h2><?= e(setting('site_name')) ?></h2>
  <?php $motdDefault = trim((string)setting('motd')) === 'Welcome, new gardener! Open your Almanac to begin.'; ?>
  <p><?= $motdDefault ? 'Welcome, new gardener! Let’s set up your gnome and garden.' : format_text(setting('motd')) ?></p>
  <?php if ($u): ?><p><a class="btn" href="<?= e(url('welcome.php')) ?>">🌱 Get started</a></p><?php endif; /* v1.6.2: the Almanac opens once your garden exists */ ?>
</div>
<?php endif; ?>
<?php if ($today): /* v1.9.2: news is part of the merged Today page above */ ?>
<?php else: ?>
<details class="fold<?= $u ? '' : ' lp-news' ?>" id="news"<?= ($u && !$today) || $allNews || ($u && $freshNews) ? ' open' : '' ?>><summary>📰 News from the Hollow<?= $freshNews ? ' <span class="tag">new</span>' : '' ?></summary>
<?php if ($allNews): ?><p class="newstabs"><a class="btn<?= $newsTab === 'news' ? '' : ' ghost' ?>" href="<?= e(url('index.php?news=all#news')) ?>">📰 News</a> <a class="btn<?= $newsTab === 'notes' ? '' : ' ghost' ?>" href="<?= e(url('index.php?news=all&tab=notes#news')) ?>">📝 Release notes</a></p><?php endif; ?>
<?php foreach ($news as $n): ?>
  <article class="box news">
    <h3><?= e($n['title']) ?></h3>
    <p class="muted"><?= e(gmdate('F j, Y', strtotime($n['created_at'] . ' UTC'))) ?></p>
    <div><?= format_text($n['body']) ?></div>
  </article>
<?php endforeach; ?>
<?php if (!$news): ?><p class="muted">Nothing here yet.</p><?php endif; ?>
<?php if (!$allNews): ?><p><a href="<?= e(url('index.php?news=all#news')) ?>">📰 All news →</a> · <a href="<?= e(url('index.php?news=all&tab=notes#news')) ?>">📝 Release notes →</a></p><?php endif; ?>
</details>
<?php endif; ?>
<?php page_footer();
