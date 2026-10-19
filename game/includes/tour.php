<?php
declare(strict_types=1);

/**
 * Wren's welcome tour: a short chain of first tasks that walks a new gnome around the site.
 * users.tour_step = the step they're on (1 = first). 0 = no tour (finished, skipped, or an older account).
 * A step is done when its event happens: a garden action ("till", "plant"…) or opening a page ("visit:book").
 */

/** [event, title, what Wren says, link label, link] */
const TOUR_STEPS = [
    ['till', 'Till a square', 'Open your garden, tap a square of wild ground and press Till. A trowel is already in your satchel. {energy}', 'Go to my garden', 'garden.php'],
    ['soil', 'Work in some compost', 'Pick the square you tilled and work in some Plain Compost. It feeds the soil slowly, over about a day, so plant right away. You don’t need to wait for it. {energy}', 'Go to my garden', 'garden.php'],
    ['plant', 'Plant a seed', 'Choose the tilled square and plant one of your seeds. Radishes and lettuce are the quickest: a radish takes {radish} of watered growing. {energy}', 'Go to my garden', 'garden.php'],
    ['water', 'Water it', 'Plants only grow while they’re watered. One watering lasts several hours, so you can come and go as you please. {energy}', 'Go to my garden', 'garden.php'],
    ['eat', 'Eat your welcome snack', 'Open your satchel and eat a crop from your welcome basket. Even raw crops give a little energy and a short buff, so a hungry gnome can always eat something from the satchel. Cooked dishes give much more.', 'Open my satchel', 'inventory.php'],
    ['visit:book', 'Open your Almanac', 'Your Almanac fills itself in as you grow crops, cut flowers, visit villages and meet creatures. Milestones in it pay rewards.', 'Open my Almanac', 'book.php'],
    ['visit:gnome', 'Meet your gnome', 'Here are your stats, your gnome level and your gardens. At level 5 you’ll choose a calling: it gives you a new hat and perks that grow as you level up.', 'See my gnome', 'gnome.php'],
    ['visit:world', 'Look around the world', 'This is where you are. Tap a stop on the road to head there, wander off the path for finds, or open the Gather tab to forage close by. Places you’ve walked to are one tap away under Fast travel.', 'Look around', 'world.php'],
    ['visit:shop', 'Visit a shop', 'Shops are staffed around the clock and restock every so often. Twigg’s Seed Emporium in Mossbottom is open to everyone, wherever you are. Tap an item to fill your basket.', 'Find a shop', '{twigg}'],
    ['harvest', 'Harvest your first crop', 'When your plant is ready, harvest it from your garden. You might save some seeds, and your Almanac gets a new page. Then the Hollow is yours to explore!', 'Go to my garden', 'garden.php'],
];

const TOUR_PAGES = ['book.php' => 'visit:book', 'gnome.php' => 'visit:gnome',
    'world.php' => 'visit:world', 'shop.php' => 'visit:shop'];

/** v0.7.85: a plant's real grow time in words (the tour used to hard-code "15 minutes"; the data says 5). */
function tour_grow_text(string $slug, string $fallback): string
{
    $m = (int)q_val('SELECT grow_minutes FROM plants WHERE slug = ?', [$slug]);
    if ($m < 1) return $fallback;
    if ($m >= 60) return round($m / 60, 1) . ' hours';
    return $m . ' minute' . ($m === 1 ? '' : 's');
}

/**
 * v0.9.4: is this garden action the one the gnome's current tour step is waiting for? Then it costs no energy
 * (setting tour_free_actions), so a newcomer's first session is never blocked by an empty energy bar.
 */
function tour_action_is_free(int $uid, string $action): bool
{
    if (setting('tour_free_actions') !== '1') return false;
    if ($action === 'sheet') $action = 'till';
    $step = (int)q_val('SELECT tour_step FROM users WHERE id = ?', [$uid]);
    return $step >= 1 && $step <= count(TOUR_STEPS) && TOUR_STEPS[$step - 1][0] === $action;
}

/** Something happened. If it's what the current tour step is waiting for, move on. Returns the new step. */
function tour_event(int $uid, string $event): int
{
    if ($event === 'sheet') $event = 'till';   // sheet mulching a no-till bed counts as preparing the ground
    $step = (int)q_val('SELECT tour_step FROM users WHERE id = ?', [$uid]);
    if ($step < 1 || $step > count(TOUR_STEPS) || TOUR_STEPS[$step - 1][0] !== $event) return $step;
    $next = $step + 1;
    if ($next > count(TOUR_STEPS)) {
        // Only the request that actually moves the step pays the reward.
        if (q('UPDATE users SET tour_step = 0 WHERE id = ? AND tour_step = ?', [$uid, $step])->rowCount() === 1) {
            tour_reward($uid);
        }
        return 0;
    }
    // v1.6.2: no toast + message-bar line any more; the next step's card shows once, then a one-line chip (tour_box)
    q('UPDATE users SET tour_step = ? WHERE id = ? AND tour_step = ?', [$next, $uid, $step]);
    return $next;
}

/** Still on Wren's tour? Everything else that greets a newcomer waits until it is done (or skipped). */
function tour_active(?array $u): bool
{
    return $u && (int)($u['tour_step'] ?? 0) > 0 && empty($u['away_from']);   // v1.7.0: back after days away = no longer a first session; welcome back wins
}

/**
 * The one "extra" helper the Today page may show per load, after the tour: 'back' (welcome back) > 'fw' (First Week) > 'daily' (daily card)
 * > 'fest' (the full festival banner). '' during the tour or when nothing applies. Remembered for the request.
 */
function helper_slot(array $u): string
{
    static $memo = [];
    $uid = (int)$u['id'];
    if (isset($memo[$uid])) return $memo[$uid];
    $r = '';
    if (!tour_active($u) && (int)($u['onboarded'] ?? 1) === 1) {
        require_once __DIR__ . '/welcome_back.php';
        require_once __DIR__ . '/first_week.php';
        require_once __DIR__ . '/festival.php';
        if (welcome_back_due($u)) $r = 'back';
        elseif (first_week_today_card($uid)) $r = 'fw';
        elseif (daily_card($u)) $r = 'daily';
        elseif (festival_active()) $r = 'fest';
    }
    return $memo[$uid] = $r;
}

/** Messages from the tour waiting to be shown (so a page can show them after its own messages). */
function tour_messages(?string $add = null): array
{
    static $q = [];
    if ($add !== null) { $q[] = $add; return []; }
    $out = $q; $q = [];
    return $out;
}

function tour_reward(int $uid): void
{
    $coins = (int)setting('tour_reward_coins');
    if ($coins > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    $castings = (int)q_val("SELECT id FROM items WHERE slug = 'worm-castings'");
    if ($castings) give_item($uid, $castings, 2);
    // v0.8.6: a prize pop-up, so the end of the tour isn't lost among the harvest messages
    prize('🐦', 'Wren’s tour done!', '“You’re a proper gardener now!”',
        [$coins > 0 ? '+' . money($coins) : '', $castings ? '+2 Worm Castings' : '', tour_energy_note($uid), first_week_intro_line($uid)]);   // v1.0.0: the First Week starts here
}

/** v1.6.2: one line on what energy buys, said once when the tour ends (the tour's actions were free). */
function tour_energy_note(int $uid): string
{
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    if (!$u) return '';
    $max = max_energy($u);
    return '⚡ Energy: ' . $max . ' energy is about ' . max(1, intdiv($max, 3)) . ' squares of till + plant + water; you get ' . energy_rate_text() . '.';
}

function tour_skip(int $uid): void
{
    q('UPDATE users SET tour_step = 0 WHERE id = ?', [$uid]);
    require_once __DIR__ . '/first_week.php';
    first_week_start($uid);   // v1.0.0: skipping the tour still gets the First Week
}

/** v1.0.0: starts Wren's First Week (a card a day) and says so. */
function first_week_intro_line(int $uid): string
{
    require_once __DIR__ . '/first_week.php';
    return first_week_start($uid) !== null ? 'Next: Wren’s First Week. A small card unlocks each day on the Today page.' : 'Next: wander the roads, cook what you grow, and fill your Almanac.';
}

/** The tour card shown at the top of game pages. */
function tour_box(int $step): string
{
    if ($step < 1 || $step > count(TOUR_STEPS)) return '';
    [, $title, $text, $label, $link] = TOUR_STEPS[$step - 1];
    if (str_contains($text, '{energy}')) {   // v0.9.4: say what energy is
        $text = str_replace('{energy}', (setting('tour_free_actions') === '1' ? 'This one is free during the tour; later each of these costs 1 energy' : 'Each of these costs 1 energy')
            . ', and yours comes back ' . energy_rate_text() . '.', $text);
    }
    // v0.7.85: placeholders filled from live data (the radish's real grow time, Twigg’s shop page)
    if (str_contains($text, '{radish}')) $text = str_replace('{radish}', tour_grow_text('radish', 'a few minutes'), $text);
    if (str_contains($link, '{twigg}')) {
        $tw = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
        $link = str_replace('{twigg}', $tw ? 'shop.php?id=' . $tw : 'shop.php', $link);
    }
    $here = basename((string)($_SERVER['SCRIPT_NAME'] ?? ''));
    $n = count(TOUR_STEPS);
    $go = $here !== explode('?', $link)[0] ? '<a class="btn small" href="' . e(url($link)) . '">' . e($label) . ' →</a>' : '';
    $skip = '<form method="post" action="' . e(url('tour.php')) . '" class="inline" data-confirm="Skip the rest of Wren’s tour? You won’t get the reward at the end.">'
        . csrf_field() . '<input type="hidden" name="do" value="skip"><button class="skip">Skip the tour</button></form>';
    // v1.6.2: the big card shows the first time this step is seen (per login); after that a one-line chip that opens on tap
    $seen = (int)($_SESSION['tour_seen'] ?? 0);
    $_SESSION['tour_seen'] = max($seen, $step);
    if ($step <= $seen) {
        return '<div class="tourchip"><details><summary>🐦 Tour ' . $step . '/' . $n . ': ' . e($title) . ' <span class="tcmore">More ›</span></summary>'
            . '<p>' . e($text) . '</p><p>' . $go . ' ' . $skip . '</p></details>'
            . ($go !== '' ? '<a class="tcnext" href="' . e(url($link)) . '">Next ›</a>' : '') . '</div>';
    }
    return '<div class="tourbox"><span class="bird" aria-hidden="true">🐦</span><div>'
        . '<h3>Wren’s tour · ' . $step . ' of ' . $n . ': ' . e($title) . '</h3>'
        . '<p>' . e($text) . '</p>'
        . ($go !== '' ? '<p>' . $go . '</p>' : '')
        . $skip . '</div></div>';
}
