<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';

$allNews = isset($_GET['news']);   // v0.7.55: every post, not just the latest few
$news = q('SELECT title, body, created_at FROM news WHERE published = 1 ORDER BY created_at DESC, id DESC LIMIT ' . ($allNews ? 200 : 5))->fetchAll();
$freshNews = $news && strtotime($news[0]['created_at'] . ' UTC') > time() - 3 * 86400;
$u = current_user();
$today = $u && (int)($u['onboarded'] ?? 1) === 1;   // v0.7.48: a "Today" page for players
// v1.9.2: Today is one page again (no tabs); the old ?t=out / ?t=hollow links land on their part of it
if (!$allNews && $u && $today && isset($_GET['t'])) redirect('index.php?today=1' . ($_GET['t'] === 'out' ? '#todaycards' : ($_GET['t'] === 'hollow' ? '#hollowtoday' : '')));
// v2.0.90: My Gnome is the home page for players; Today is still at index.php?today=1
if (!$allNews && $u && $today && !isset($_GET['today'])) redirect('gnome.php');
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
  <div class="lp-hero lp-jeff">
    <?= puzzle_cast('jeff-host', 'Jeff the Puzzler', 'lp-jeffface') ?>
    <p class="lp-bubble"><b>Jeff:</b> “<?= e(stext('home.jeff')) ?>”</p>
    <h1><?= e(setting('site_name')) ?><?= is_admin() ? ' <a class="small" href="' . e(url('admin/texts.php?page=' . urlencode('Front page'))) . '">✏️ Edit</a>' : '' ?></h1>
    <p class="lp-pitch"><?= e(stext('home.headline')) ?></p>
    <p class="lp-sub">A free, cosy garden game about gnomes.</p>
    <div class="lp-cta">
      <a class="btn lp-big" href="<?= e(url('register.php')) ?>"><?= e(stext('home.button')) ?></a>
      <a class="btn ghost lp-big" href="#tour"><?= e(stext('home.tourbtn')) ?></a>
      <?php if (setting('guest_open') === '1'): ?><a class="btn ghost lp-big" href="<?= e(url('guest.php')) ?>"><?= e(stext('home.guestbtn')) ?></a><?php endif; ?>
      <a class="lp-login" href="<?= e(url('login.php')) ?>">Already a gnome? <b>Log in</b></a>
    </div>
    <p class="lp-small"><?= e(stext('home.small')) ?></p>
  </div>
  <h2 class="lp-h2" id="tour">The tour</h2>
  <ol class="lp-stops">
    <?php $tourPose = [1 => 'jeff-point', 2 => 'jeff-point', 3 => 'jeff-point', 4 => 'jeff-point', 5 => 'jeff-cheer', 6 => 'jeff-think']; $tourKey = [1 => 'garden', 2 => 'satchel', 3 => 'world', 4 => 'town', 5 => 'games', 6 => 'almanac'];
    foreach ($tourKey as $n => $shot): [$ttl, $say] = array_pad(explode("\n", stext('home.tour.' . $n), 2), 2, ''); ?>
    <li class="lp-stop">
      <p class="lp-step">Stop <?= $n ?> of 6</p>
      <h3><?= e($ttl) ?></h3>
      <div class="lp-frame"><img class="lt" src="<?= e(url('assets/img/landing/shot-' . $shot . '.png?v=' . APP_VERSION)) ?>" alt="<?= e(trim(preg_replace('/^\P{L}+/u', '', $ttl))) ?> in the game" width="412" height="560" loading="lazy"><img class="dk" src="<?= e(url('assets/img/landing/shot-' . $shot . '-dark.png?v=' . APP_VERSION)) ?>" alt="" width="412" height="560" loading="lazy"></div>
      <div class="lp-say"><?= puzzle_cast($tourPose[$n] ?? 'jeff-host', 'Jeff', 'lp-sayface') ?><p class="lp-bubble"><?= e($say) ?></p></div>
    </li>
    <?php endforeach; ?>
  </ol>
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
<?php foreach ($news as $n): ?>
  <article class="box news">
    <h3><?= e($n['title']) ?></h3>
    <p class="muted"><?= e(gmdate('F j, Y', strtotime($n['created_at'] . ' UTC'))) ?></p>
    <div><?= format_text($n['body']) ?></div>
  </article>
<?php endforeach; ?>
<?php if (!$news): ?><p class="muted">No news yet.</p><?php endif; ?>
<?php if (!$allNews && count($news) >= 5): ?><p><a href="<?= e(url('index.php?news=all#news')) ?>">📰 All news →</a></p><?php endif; ?>
</details>
<?php endif; ?>
<?php page_footer();
