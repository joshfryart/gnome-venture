<?php
declare(strict_types=1);
// v0.8.8: a public "How to play" page, for newcomers and for search engines. Anyone can read it, logged in or not.
// v0.8.9: the words come from Admin → 📝 Page text (includes/site_text.php), and each region shows its climate.
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/site_text.php';
require_once __DIR__ . '/includes/climate.php';

$u = current_user();
// v1.6.3: the Almanac starter pages and region list moved out of this page (it is short now).
$faq = stext_faq('guide.faq');

seo_set([
    'title' => stext('guide.title'),
    'desc' => stext('guide.desc'),
    'jsonld' => $faq ? [[
        '@context' => 'https://schema.org', '@type' => 'FAQPage',
        'mainEntity' => array_map(fn($q) => ['@type' => 'Question', 'name' => $q[0], 'acceptedAnswer' => ['@type' => 'Answer', 'text' => seo_plain($q[1], 1000)]], $faq),
    ]] : [],
]);
page_header('How to play');
$edit = is_admin() ? ' <a class="small" href="' . e(url('admin/texts.php?page=' . urlencode('How to play'))) . '">✏️ Edit</a>' : '';
// v2.0.29: Hearthlight look. Each fold title is an h2 inside its summary (screen readers get a heading per section); FAQ questions are h3.
$fold = function (string $icon, string $title, bool $open = false): string {
    return '<details class="lpg-fold"' . ($open ? ' open' : '') . '><summary><span class="lpg-ico" aria-hidden="true">' . $icon . '</span><h2>' . e($title) . '</h2></summary><div class="lpg-body">';
};
?>
<?php // v1.6.3: short, scannable guide. Closed folds, a few lines each. The FAQ stays (it feeds the search-engine FAQ data above). ?>
<article class="guide lpg">
<div class="lpg-top">
  <h1>How to play<?= $edit ?></h1>
  <p class="lpg-lede">Short and simple. Tap a heading to open it.</p>
  <?php if (!$u): ?><div class="lp-cta lp-top"><a class="btn lp-big" href="<?= e(url('register.php')) ?>"><?= e(stext('home.button')) ?></a><a class="lp-login" href="<?= e(url('login.php')) ?>">Already a gnome? <b>Log in</b></a></div><?php endif; ?>
</div>

<?= $fold('🌱', 'Your first day', true) ?>
  <ol>
    <li><b>Till</b> a square in your <a href="<?= e(url('garden.php')) ?>">Garden</a>.</li>
    <li><b>Plant</b> a seed. Radishes are quick.</li>
    <li><b>Water</b> it. Plants only grow on days they are watered (or it rains).<?php if (gclock_on()): ?> A day passes when you <b>sleep</b>.<?php endif; ?></li>
    <li><b>Harvest</b> when it is ready.</li>
    <li><b>Eat, cook or sell</b> what you grew.</li>
  </ol>
  <p>Wren, the naturalist, walks you through the first ten steps. Finish them for a reward.</p>
</div></details>

<?php if (gclock_on()): ?>
<?= $fold('🌙', 'Sleep, the clock and days', true) ?>
  <ul>
    <li>Your gnome has their own <b>clock</b>, at the top of the screen. The day runs from <b>06:00 to 22:00</b>. After 22:00 you get tired: actions cost more energy, but you are never locked out.</li>
    <li><b>A day only passes when you sleep.</b> Sleep in your hovel, at an inn, on a park bench (a bit of energy only), at a friend's house, or on the road with camping gear. See the <a href="<?= e(url('hovel.php')) ?>">Rest page</a>.</li>
    <li>Sleeping refills your energy and health and starts a new day at 06:00. A <b>nap</b> takes 2 hours and gives back some energy. You need a seat or bed.</li>
    <li>Longer jobs take game time: walking a trail section, wandering, gathering, crafting, rest-stop visits, florist shifts and repairs. Each button shows its time. Crafting several at once shows the total.</li>
    <li>Crops, cooking pots, pantry jars, helpers and Puzzle Pal jobs all follow <b>your</b> days. They move on when you sleep, not while you are away.</li>
    <li>Shops and stops have opening hours, and some villagers are away on some days.</li>
    <li>Contests, shared goals, visits and daily game plays still use real time.</li>
  </ul>
</div></details>

<?php endif; ?>
<?= $fold('⚡', 'Energy and Petals') ?>
  <ul>
    <li>Gardening, walking and gathering cost <b>energy</b>. Most garden jobs cost 1.</li>
    <li><?= gclock_on() ? 'It refills when you sleep. A nap gives some back. It also trickles back slowly by itself, up to ' . (setting('trickle_energy_cap_pct') === '' ? 50 : (int)setting('trickle_energy_cap_pct')) . '% of your bar.' : 'It refills by itself: ' . e(energy_rate_text()) . '.' ?></li>
    <li>Your max starts at 10 and grows with every Gnome level.</li>
    <li>Out of energy? <a href="<?= e(url('inventory.php')) ?>">Eat something</a>. Cooked food restores much more than raw.</li>
    <li><b>Petals</b> are the money. Sell crops to shops and other gnomes to earn them. Spend them on seeds, land and buildings.</li>
  </ul>
</div></details>

<?= $fold('🧙', 'Your gnome and stats') ?>
  <ul>
    <li>You level up as you work. Each level gives <b>stat points</b> to spend on your home page: <a href="<?= e(url('gnome.php?tab=stats')) ?>">My Gnome → Stats</a>.</li>
    <li>Seven stats: Grit, Nimble, Hardiness, Lore, Sense, Charm and Luck. Each helps in its own way.</li>
    <li>What you eat boosts stats for a while. A few rare plants raise one for good.</li>
  </ul>
</div></details>

<?= $fold('🍲', 'Cook, craft and sell') ?>
  <ul>
    <li>Reach garden level 2 to build a <b>Kitchen</b>. Snacks, meals and feasts restore energy and give boosts.</li>
    <li><a href="<?= e(url('inventory.php?tab=craft')) ?>">Crafting</a> turns wood, stone and wild finds into tools, compost and decor.</li>
    <li>Sell to shops, <a href="<?= e(url('market.php')) ?>">trade</a> with other gnomes, or open a market stall.</li>
  </ul>
</div></details>

<?= $fold('🗺️', 'Travel, rest stops and fights') ?>
  <ul>
    <li>Open the <a href="<?= e(url('world.php')) ?>">World</a> and follow the roads to the next village. Walking costs energy.</li>
    <li>Rest stops along the road have things to do and folk to meet. Each one has a few visits a day.</li>
    <li>Wander off the path to find things and creatures. Some creatures fight back. Check the odds first and bring a snack.</li>
    <li>Shopkeepers keep their own hours<?php if (gclock_on()): ?> (most close at 22:00)<?php endif; ?>. Chat and give gifts to make friends.</li>
  </ul>
</div></details>

<?= $fold('🎲', 'Games') ?>
  <ul>
    <li>Seven quick <a href="<?= e(url('games.php')) ?>">daily games</a>, such as Snail Race and Mushroom Sweeper.</li>
    <li>Each game has its own plays per day. Finishing one gives a little energy back.</li>
    <li>There are also contests: a weekly Village Show and a monthly Grand Harvest Fair.</li>
  </ul>
</div></details>

<?= $fold('📖', 'The Almanac') ?>
  <ul>
    <li>Your <a href="<?= e(url('book.php')) ?>">Almanac</a> starts with empty pages.</li>
    <li>It fills in as you grow, cook, travel and meet folk.</li>
    <li>Stuck? Its Getting started pages explain the basics.</li>
  </ul>
</div></details>

<?= $fold('🧑‍🌾', 'Helpers') ?>
  <ul>
    <li>Build a Tool Shed and you can <a href="<?= e(url('garden.php?t=help')) ?>">hire a helper</a> for 1, 3 or 7 days. You pay up front.</li>
    <li>Helpers water, weed or harvest while you are away<?php if (gclock_on()): ?> (days pass when you sleep)<?php endif; ?>.</li>
    <li>You earn a little less XP and keep less of the harvest.</li>
    <li>Short on time yourself? Take a tending job for another gnome on the <a href="<?= e(url('jobs.php')) ?>">Job Board</a>.</li>
  </ul>
</div></details>

<?php if ($faq): ?>
<?= $fold('❓', 'Questions') ?>
  <?php foreach ($faq as [$q, $a]): ?>
    <h3 class="lpg-q"><?= e($q) ?></h3>
    <p><?= format_text($a) ?></p>
  <?php endforeach; ?>
</div></details>
<?php endif; ?>

<?php if (!$u): ?><div class="lp-cta lp-end"><a class="btn lp-big" href="<?= e(url('register.php')) ?>"><?= e(stext('home.cta')) ?></a><a class="btn ghost lp-big" href="<?= e(url('index.php')) ?>">🏡 Front page</a><a class="lp-login" href="<?= e(url('login.php')) ?>">Already a gnome? <b>Log in</b></a></div><?php endif; ?>
</article>
<?php page_footer();
