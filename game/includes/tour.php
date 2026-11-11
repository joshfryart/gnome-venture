<?php
declare(strict_types=1);

/**
 * Wren's welcome tour: a short chain of first tasks that walks a new gnome around the site.
 * users.tour_step = the step they're on (1 = first). 0 = no tour (finished, skipped, or an older account).
 * A step is done when its event happens: a garden action ("till", "plant"…) or opening a page ("visit:book").
 */

/** [event, title, what Wren says, link label, link] */
const TOUR_STEPS = [
    ['till', 'Till a square', "Wild ground needs tilling before it grows anything.\nYour trowel is already in your satchel.\n{energy}", 'Go to my garden', 'garden.php'],
    ['soil', 'Work in some compost', "Compost feeds the soil slowly, over about a day.\nNo need to wait: plant right after.\n{energy}", 'Go to my garden', 'garden.php', 1],   // 6th: 1 = can be skipped (rich soil has no Work in button)
    ['plant', 'Plant a seed', "Radishes and lettuce are quickest: a radish takes {radish} of watered growing.\nThe seed shown is fine.\n{energy}", 'Go to my garden', 'garden.php'],
    ['water', 'Water it', "Plants only grow while watered.\nOne watering lasts several hours, so come and go as you like.\n{energy}", 'Go to my garden', 'garden.php'],
    ['eat', 'Eat your welcome snack', "Open your satchel and eat a crop from your welcome basket.\nEven raw crops give a little energy and a short buff.\nCooked dishes give much more.", 'Open my satchel', 'inventory.php'],
    ['visit:book', 'Open your Almanac', "Your Almanac fills itself in as you:\ngrow crops and cut flowers\nvisit villages and meet creatures\nMilestones in it pay rewards.", 'Open my Almanac', 'book.php'],
    ['visit:gnome', 'Meet your gnome', "Here you will find:\nyour stats and gnome level\nyour gardens\nAt level 5 you choose a calling: a new hat and perks that grow with you.", 'See my gnome', 'gnome.php?tab=gnome'],
    ['visit:world', 'Look around the world', "This is where you are.\nTap a stop on the road to head there.\nWander off the path for finds.\nOpen Gather to forage close by.\nPlaces you have walked to are one tap away under Fast travel.", 'Look around', 'world.php'],
    ['visit:shop', 'Visit a shop', "Shops are staffed around the clock and restock now and then.\nTwigg’s Seed Emporium in Mossbottom is open to everyone, wherever you are.\nTap an item to fill your basket.", 'Find a shop', '{twigg}'],
    ['harvest', 'Harvest your first crop', "When your plant is ready:\nYou might save some seeds.\nYour Almanac gets a new page.\nThen the Hollow is yours to explore!", 'Go to my garden', 'garden.php'],
];

/** v2.4.97: where to point on each step, most specific first: [CSS selector, hint]. tour.js rings the first one that is on the page. */
const TOUR_TARGETS = [
    'till' => [['.sqactions .toolform:has(input[value=till]) button[value=one]', 'Press Till.'], ['#yard a.tile.wild', 'Tap a square of wild ground.'], ['.gardentabnav a[href$="garden.php"]', 'Tap Beds.'], ['.bottombar a[href$="garden.php"]:not(.on)', 'Tap Garden.'], ['.navtile[href$="garden.php"]', 'Tap Garden.']],
    'soil' => [['.sqactions .toolform:has(input[value=soil]) button[value=one]', 'Press Work in. The compost shown is fine.'], ['#yard a.tile.tilled', 'Tap your tilled square.'], ['.gardentabnav a[href$="garden.php"]', 'Tap Beds.'], ['.bottombar a[href$="garden.php"]:not(.on)', 'Tap Garden.'], ['.navtile[href$="garden.php"]', 'Tap Garden.']],
    'plant' => [['.sqactions .toolform:has(input[value=plant]) button[value=one]', 'Press Plant. The seed shown is fine.'], ['#yard a.tile.tilled', 'Tap your tilled square.'], ['.gardentabnav a[href$="garden.php"]', 'Tap Beds.'], ['.bottombar a[href$="garden.php"]:not(.on)', 'Tap Garden.'], ['.navtile[href$="garden.php"]', 'Tap Garden.']],
    'water' => [['.piact .toolform:has(input[value=water]) button[value=one]', 'Press Water.'], ['#yard a.tile.planted', 'Tap your planted square.'], ['.gardentabnav a[href$="garden.php"]', 'Tap Beds.'], ['.bottombar a[href$="garden.php"]:not(.on)', 'Tap Garden.'], ['.navtile[href$="garden.php"]', 'Tap Garden.']],
    'eat' => [['.shquick .shf:has(input[value=eat]) button', 'Tap Eat.'], ['.bottombar a[href$="inventory.php"]:not(.on)', 'Tap Satchel.'], ['.navtile[href$="inventory.php"]', 'Tap Satchel.']],
    'visit:book' => [['.statusstrip .st.alm a', 'Tap Almanac.'], ['.navtile[href$="book.php"]', 'Tap Almanac.']],
    'visit:gnome' => [['.statusstrip a.stl[href*="tab=gnome"]', 'Tap your level.'], ['.navme', 'Tap your gnome.']],
    'visit:world' => [['.bottombar a[href$="world.php"]:not(.on)', 'Tap World.'], ['.navtile[href$="world.php"]', 'Tap World.']],
    'visit:shop' => [['#wrentour .tourgo', 'Tap this button.']],
    'harvest' => [['.piact .toolform:has(input[value=harvest]) button[value=one]', 'Press Harvest.'], ['#yard a.tile.ready', 'Tap the ready square.'], ['.gardentabnav a[href$="garden.php"]', 'Tap Beds.'], ['.bottombar a[href$="garden.php"]:not(.on)', 'Tap Garden.'], ['.navtile[href$="garden.php"]', 'Tap Garden.']],
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
    [$step, $ask] = tour_state($uid);
    return $ask === 0 && $step >= 1 && $step <= count(TOUR_STEPS) && TOUR_STEPS[$step - 1][0] === $action;
}

/** Is the gnome's current tour step waiting for this event? (Rain-watered plants must still be waterable on the "Water it" step, or the tour sticks.) */
function tour_waiting_for(int $uid, string $event): bool
{
    [$step, $ask] = tour_state($uid);
    return $ask === 0 && $step >= 1 && $step <= count(TOUR_STEPS) && TOUR_STEPS[$step - 1][0] === $event;
}

/** [tour_step, tour_ask] for a gnome. tour_ask: 1 = Wren is asking "tour now or later?", 2 = said later (asked again next login), 0 = answered. */
function tour_state(int $uid): array
{
    $r = q_one('SELECT tour_step, tour_ask FROM users WHERE id = ?', [$uid]);
    return [(int)($r['tour_step'] ?? 0), (int)($r['tour_ask'] ?? 0)];
}

/** v2.4.97: the answer to Wren's question ('start' or 'later'), and the one-step skip for a step the gnome cannot do. */
function tour_answer(int $uid, string $do): void
{
    if ($do === 'start') {
        q('UPDATE users SET tour_ask = 0 WHERE id = ? AND tour_step > 0', [$uid]);
        unset($_SESSION['tour_later']);
    } elseif ($do === 'later') {
        q('UPDATE users SET tour_ask = 2 WHERE id = ? AND tour_step > 0 AND tour_ask = 1', [$uid]);
        $_SESSION['tour_later'] = 1;   // asked again on the next login (page_header)
    } elseif ($do === 'nextstep') {   // "Can't see it? Skip this step": no reward difference, the tour just moves on
        [$step, $ask] = tour_state($uid);
        if ($ask === 0 && $step >= 1 && $step < count(TOUR_STEPS) && !empty(TOUR_STEPS[$step - 1][5])) {
            q('UPDATE users SET tour_step = ? WHERE id = ? AND tour_step = ?', [$step + 1, $uid, $step]);
        }
    }
}

/** Something happened. If it's what the current tour step is waiting for, move on. Returns the new step. */
function tour_event(int $uid, string $event): int
{
    if ($event === 'sheet') $event = 'till';   // sheet mulching a no-till bed counts as preparing the ground
    [$step, $ask] = tour_state($uid);
    if ($ask !== 0 || $step < 1 || $step > count(TOUR_STEPS) || TOUR_STEPS[$step - 1][0] !== $event) return $step;   // v2.4.97: nothing counts until Wren's "now or later?" is answered
    $next = $step + 1;
    if ($next > count(TOUR_STEPS)) {
        // Only the request that actually moves the step pays the reward.
        if (q('UPDATE users SET tour_step = 0, tour_ask = 0 WHERE id = ? AND tour_step = ?', [$uid, $step])->rowCount() === 1) {
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

const TOUR_REWARD_XP = 100;   // level 2 needs 100 XP

function tour_reward(int $uid): void
{
    $coins = (int)setting('tour_reward_coins');
    if ($coins > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    $castings = (int)q_val("SELECT id FROM items WHERE slug = 'worm-castings'");
    if ($castings) give_item($uid, $castings, 2);
    add_xp($uid, TOUR_REWARD_XP, 'tour');   // the tour ends at gnome level 2 (bigger energy bar, healed): level-up before the energy note below
    // v0.8.6: a prize pop-up, so the end of the tour isn't lost among the harvest messages
    prize('🐦', 'Wren’s tour done!', '“You’re a proper gardener now!”',
        [$coins > 0 ? '+' . money($coins) : '', '+' . TOUR_REWARD_XP . ' XP', $castings ? '+2 Worm Castings' : '', tour_energy_note($uid), first_week_intro_line($uid)]);   // v1.0.0: the First Week starts here
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
    q('UPDATE users SET tour_step = 0, tour_ask = 0 WHERE id = ?', [$uid]);
    require_once __DIR__ . '/first_week.php';
    first_week_start($uid);   // v1.0.0: skipping the tour still gets the First Week
}

/** v1.0.0: starts Wren's First Week (a card a day) and says so. */
function first_week_intro_line(int $uid): string
{
    require_once __DIR__ . '/first_week.php';
    return first_week_start($uid) !== null ? 'Next: Wren’s First Week. A small card unlocks each day on the Today page.' : 'Next: wander the roads, cook what you grow, and fill your Almanac.';
}

/** v2.4.97: Wren's words: the first line is a sentence, the lines after it are petal bullets (one point each). */
function tour_text_html(string $t): string
{
    $lines = array_values(array_filter(array_map('trim', explode("\n", $t)), fn($l) => $l !== ''));
    if (!$lines) return '';
    $h = '<p class="tbtext">' . e(array_shift($lines)) . '</p>';
    if ($lines) $h .= '<ul class="tourlist">' . implode('', array_map(fn($l) => '<li>' . e($l) . '</li>', $lines)) . '</ul>';
    return $h;
}

/** The tour card shown at the top of game pages. tour.js turns it into Wren's speech bubble and rings what to tap; without script it stays a plain card.
 *  $ask: tour_ask (1 = the "now or later?" question, 2 = paused). $arrived: the visit step just finished by opening this page (its words show first). */
function tour_box(int $step, int $ask = 0, int $arrived = 0): string
{
    if ($step < 1 || $step > count(TOUR_STEPS)) return '';
    $n = count(TOUR_STEPS);
    $skip = '<form method="post" action="' . e(url('tour.php')) . '" class="inline" data-confirm="Skip the rest of Wren’s tour? You won’t get the reward at the end.">'
        . csrf_field() . '<input type="hidden" name="do" value="skip"><button class="skip">Skip the tour</button></form>';
    $post = fn(string $do, string $label, string $cls = 'btn small') => '<form method="post" action="' . e(url('tour.php')) . '" class="inline">'
        . csrf_field() . '<input type="hidden" name="do" value="' . $do . '"><button class="' . $cls . '">' . $label . '</button></form> ';
    if ($ask === 1) {   // v2.4.97: right after the garden is named
        return '<div id="wrentour" data-step="0"><div class="tourbox tourask"><span class="bird" aria-hidden="true">🐦</span><div>'
            . '<h3>Wren’s tour</h3><p>Your garden is made!</p><ul class="tourlist"><li>Show you around now?</li><li>Or look around yourself: I will ask again next time.</li></ul>'
            . '<p class="tourbtns">' . $post('start', 'Show me now', 'btn') . $post('later', 'Later', 'btn alt') . '</p>' . $skip . '</div></div></div>';
    }
    if ($ask === 2) {   // said "later": a quiet one-liner until the next login
        return '<div id="wrentour" data-step="0"><div class="tourchip"><span class="tcmore">🐦 Wren’s tour is waiting.</span> ' . $post('start', 'Start it') . '</div></div>';
    }
    [, $title, $text, $label, $link] = TOUR_STEPS[$step - 1];
    $fill = function (string $t): string {
        if (str_contains($t, '{energy}')) {   // v0.9.4: say what energy is
            $t = str_replace('{energy}', (setting('tour_free_actions') === '1' ? 'Free during the tour.' : 'Costs 1 energy.') . "\n" . 'You recharge ' . energy_rate_text() . '.', $t);
        }
        // v0.7.85: placeholders filled from live data (the radish's real grow time)
        return str_contains($t, '{radish}') ? str_replace('{radish}', tour_grow_text('radish', 'a few minutes'), $t) : $t;
    };
    $text = $fill($text);
    if (str_contains($link, '{twigg}')) {   // Twigg’s shop page
        $tw = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
        $link = str_replace('{twigg}', $tw ? 'shop.php?id=' . $tw : 'shop.php', $link);
    }
    $here = basename((string)($_SERVER['SCRIPT_NAME'] ?? ''));
    [$lp, $lq] = array_pad(explode('?', $link, 2), 2, '');   // a link with a ?tab= (My Gnome) counts as "here" only on that tab
    parse_str($lq, $lqa);
    $atLink = $here === $lp;
    foreach ($lqa as $k => $v) if (!is_string($v) || (string)($_GET[$k] ?? '') !== $v) $atLink = false;
    $go = !$atLink ? '<a class="btn small tourgo" href="' . e(url($link)) . '">' . e($label) . ' →</a>' : '';
    $arr = '';
    if ($arrived >= 1 && $arrived <= $n) {   // a visit step finishes before the page is drawn: say what it was about, here
        $arr = '<div class="tourbox tourarr"><span class="bird" aria-hidden="true">🐦</span><div><h3>' . e(TOUR_STEPS[$arrived - 1][1]) . '</h3>' . tour_text_html($fill(TOUR_STEPS[$arrived - 1][2])) . '</div></div>';
    }
    $targets = TOUR_TARGETS[TOUR_STEPS[$step - 1][0]] ?? [];
    $next = !empty(TOUR_STEPS[$step - 1][5]) ? '<div class="tournext"><form method="post" action="' . e(url('tour.php')) . '" class="inline">' . csrf_field()
        . '<input type="hidden" name="do" value="nextstep"><button class="skip">Can’t see it? Skip this step</button></form></div>' : '';
    return '<div id="wrentour" data-step="' . $step . '" data-targets="' . e(json_encode($targets, JSON_UNESCAPED_UNICODE)) . '">' . $arr
        . '<div class="tourbox tourcur"><span class="bird" aria-hidden="true">🐦</span><div>'
        . '<h3>Wren’s tour · ' . $step . ' of ' . $n . ': ' . e($title) . '</h3>'
        . tour_text_html($text)
        . '<p class="tourhint" aria-live="polite"></p>'
        . ($go !== '' ? '<p>' . $go . '</p>' : '')
        . $next . $skip . '</div></div></div>';
}
