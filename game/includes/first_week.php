<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 3: Wren's First Week.
 * After Wren's tour a gnome gets seven small cards, one unlocking each day (Hollow days since the tour ended).
 * Each card has two little goals that tick themselves off from what the gnome has really done, points at one key feature, and pays a gentle
 * reward when both are ticked. Cards never expire and never take anything away: a skipped day only means more cards are waiting.
 * The last card gives a keepsake title.
 */

/**
 * day => [title, intro (Wren speaking), [task key => [label, link, how]], coins, xp, item spec, extra].
 * The check for each task key is in first_week_check().
 */
const FIRST_WEEK = [
    1 => ['Settle in', 'Welcome to your first week! Two small things to get the soil under your nails.',
          ['harvest' => ['Harvest a crop', 'garden.php', 'Plant a quick radish, water it, and pick it when it is ready.'],
           'read' => ['Read three Almanac pages', 'book.php', 'Open the Almanac and read three pages. The Getting started chapter is a good one.']],
          50, 10, 'plain-compost:3'],
    2 => ['Meet the neighbours', 'Gnomes are lovely company. Say hello and look at what needs doing.',
          ['talk' => ['Chat with a townsperson', 'town.php?view=villagers', 'Open Town → Villagers, pick someone who is about, and press Talk.'],
           'job' => ['Take a job from the Job Board', 'jobs.php', 'Pick any daily job. Doing your usual gardening usually finishes it.']],
          60, 10, ''],
    3 => ['Out and about', 'The Hollow is bigger than one garden. Take a short walk.',
          ['walk' => ['Walk to another stop on the road', 'world.php', 'Open World and tap a stop along the road.'],
           'gather' => ['Gather something wild', 'world.php', 'At a stop, open the Gather tab and forage. Finds fill your Almanac.']],
          70, 15, 'worm-castings:2'],
    4 => ['Kitchen day', 'Home cooking beats anything from a shop. Put a pot on.',
          ['cook' => ['Cook something', 'inventory.php?tab=craft&c=cooking', 'Open Satchel → Crafting → Cooking. A simple dish is fine.'],
           'town' => ['Do something in a town square', 'town.php', 'Open Town and try a stall, a bench or a wishing well.']],
          80, 15, ''],
    5 => ['Together', 'You are not on your own out here. Make a friend and leave a mark.',
          ['stamp' => ['Sign another gnome’s garden guestbook', 'gotm.php', 'Visit a garden from Garden of the Month or a friend’s page, and sign the guestbook.'],
           'pal' => ['Send (or accept) a gnome friend request', 'pals.php', 'Open someone’s profile and press Add friend. You can also accept a waiting request.']],
          90, 20, 'rich-loam:2'],
    6 => ['The Hollow together', 'Everyone helps fill the jar, and there is always a ribbon to chase.',
          ['jar' => ['Put something in the Hollow jar', 'community.php?t=jar', 'Whatever the week’s goal is, doing it counts. Check the jar on the Together page.'],
           'contest' => ['Enter a contest', 'games.php?tab=contests', 'The Village Show enters you automatically when you harvest the week’s crop. Or try the Fair.']],
          100, 20, ''],
    7 => ['Make it yours', 'One last card. Your garden, your story.',
          ['decor' => ['Put a decoration in your yard', 'garden.php', 'Buy a little decoration at the Hedge & Hearth, then use ✏️ Design yard.'],
           'journey' => ['Hand in a stage of Wren’s Journey', 'book.php?ch=Journey', 'Your first chapter has a project to build. Hand in the first stage when you have the materials.']],
          250, 40, 'rich-loam:3'],
];

const FIRST_WEEK_TITLE = 'Sprout of the Hollow';

function first_week_on(): bool
{
    return setting('first_week_on') === '1';
}

/** The Hollow date the week began, starting it now if the gnome is new enough and has finished or skipped the tour. Null = not on. */
function first_week_start(int $uid, bool $force = false): ?string
{
    if (!first_week_on()) return null;
    $u = q_one('SELECT fw_start, tour_step, onboarded, created_at FROM users WHERE id = ?', [$uid]);
    if (!$u || (int)$u['onboarded'] !== 1) return null;
    if (!empty($u['fw_start'])) return (string)$u['fw_start'];
    if (!$force && ((int)$u['tour_step'] > 0 || strtotime($u['created_at'] . ' UTC') < time() - 14 * 86400)) return null;   // still on the tour, or an older gnome
    $today = hollow_date('Y-m-d');
    q('UPDATE users SET fw_start = ? WHERE id = ? AND fw_start IS NULL', [$today, $uid]);
    return $today;
}

/** How many cards are unlocked (1 on the first day, up to 7). */
function first_week_unlocked(string $start): int
{
    $d = (int)floor((strtotime(hollow_date('Y-m-d') . ' UTC') - strtotime($start . ' UTC')) / 86400);
    return max(1, min(7, $d + 1));
}

function first_week_check(int $uid, string $key): bool
{
    return match ($key) {
        'harvest' => (bool)q_val('SELECT 1 FROM user_plant_knowledge WHERE user_id = ? AND knowledge > 0 LIMIT 1', [$uid]),
        'read' => (int)q_val('SELECT COUNT(*) FROM user_encyclopedia WHERE user_id = ? AND read_at IS NOT NULL', [$uid]) >= 3,
        'talk' => (bool)q_val('SELECT 1 FROM npc_friends WHERE user_id = ? AND talks > 0 LIMIT 1', [$uid]),
        'job' => (bool)q_val('SELECT 1 FROM user_jobs WHERE user_id = ? LIMIT 1', [$uid]),
        'walk' => (int)q_val("SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key LIKE 'village:%'", [$uid]) >= 2,
        'gather' => (bool)q_val("SELECT 1 FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key LIKE 'gather:%' LIMIT 1", [$uid]),
        'cook' => (bool)q_val('SELECT 1 FROM cook_pots WHERE user_id = ? LIMIT 1', [$uid]),
        'town' => (bool)q_val('SELECT 1 FROM town_uses WHERE user_id = ? LIMIT 1', [$uid]),
        'stamp' => (bool)q_val('SELECT 1 FROM garden_stamps WHERE user_id = ? LIMIT 1', [$uid]),
        'pal' => (bool)q_val("SELECT 1 FROM player_friends WHERE (user_id = ? OR friend_id = ?) AND status IN ('pending', 'accepted') LIMIT 1", [$uid, $uid]),
        'jar' => (bool)q_val('SELECT 1 FROM hollow_goal_contrib WHERE user_id = ? LIMIT 1', [$uid]),
        'contest' => (bool)q_val('SELECT 1 FROM show_entries WHERE user_id = ? UNION ALL SELECT 1 FROM fair_entries WHERE user_id = ? UNION ALL SELECT 1 FROM gotm_entries WHERE user_id = ?
                                  UNION ALL SELECT 1 FROM arrangement_entries WHERE user_id = ? UNION ALL SELECT 1 FROM carvings WHERE user_id = ? LIMIT 1', [$uid, $uid, $uid, $uid, $uid]),
        'decor' => (bool)q_val("SELECT 1 FROM garden_objects o JOIN plots p ON p.id = o.plot_id WHERE p.user_id = ? AND o.kind = 'decor' AND o.x >= 0 LIMIT 1", [$uid]),
        'journey' => (bool)q_val('SELECT 1 FROM user_quests WHERE user_id = ? AND (stage > 0 OR done_at IS NOT NULL) LIMIT 1', [$uid]),
        default => false,
    };
}

/**
 * Where the gnome stands: null when the First Week is not on for them, else
 * ['start', 'unlocked', 'cards' => [day => ['title', 'intro', 'tasks' => [[key, label, link, how, done]], 'done' => bool, 'claimed' => bool, 'reward' => text]], 'claimed_n', 'complete'].
 */
function first_week_state(int $uid, bool $currentOnly = false): ?array
{
    $start = first_week_start($uid);
    if ($start === null) return null;
    $claimed = array_map('intval', q('SELECT day FROM first_week_claims WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN));
    $unlocked = first_week_unlocked($start);
    $cards = [];
    $current = null;   // v1.0.0: the card Today shows (first unlocked, unclaimed); with $currentOnly the others' tasks aren't checked (saves ~12 queries)
    foreach (FIRST_WEEK as $day => [$title, $intro, $tasks, $coins, $xp, $item]) {
        $card = ['title' => $title, 'intro' => $intro, 'tasks' => [], 'done' => false, 'claimed' => in_array($day, $claimed, true), 'locked' => $day > $unlocked,
            'reward' => money($coins) . ', ' . $xp . ' XP' . ($item !== '' ? ', ' . first_week_item_text($item) : '') . ($day === 7 ? ', the title “' . FIRST_WEEK_TITLE . '”' : '')];
        if ($day <= $unlocked) {
            $all = true;
            $skip = $currentOnly && !$card['claimed'] && $current !== null;
            if (!$card['claimed'] && $current === null) $current = $day;
            foreach ($tasks as $key => [$label, $link, $how]) {
                $done = $card['claimed'] || (!$skip && first_week_check($uid, $key));
                $card['tasks'][] = [$key, $label, $link, $how, $done];
                if (!$done) $all = false;
            }
            $card['done'] = $all;
        } else {
            foreach ($tasks as $key => [$label, $link, $how]) $card['tasks'][] = [$key, $label, $link, $how, false];
        }
        $cards[$day] = $card;
    }
    return ['start' => $start, 'unlocked' => $unlocked, 'cards' => $cards, 'claimed_n' => count($claimed), 'complete' => count($claimed) >= 7];
}

function first_week_item_text(string $spec): string
{
    [$slug, $qty] = explode(':', $spec) + [1 => '1'];
    return (int)$qty . ' × ' . (string)(q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug);
}

/** Claim a finished card's reward. */
function first_week_claim(array $u, int $day): array
{
    $uid = (int)$u['id'];
    if (!isset(FIRST_WEEK[$day])) return [false, 'There is no such card.'];
    $st = first_week_state($uid);
    if (!$st) return [false, 'Wren’s First Week is not on for you.'];
    $c = $st['cards'][$day];
    if ($c['claimed']) return [false, 'You already took that reward.'];
    if ($c['locked']) return [false, 'That card unlocks on day ' . $day . '.'];
    if (!$c['done']) return [false, 'Finish both little goals first.'];
    [, , , $coins, $xp, $item] = FIRST_WEEK[$day];
    db()->beginTransaction();
    try {
        db_insert('first_week_claims', ['user_id' => $uid, 'day' => $day, 'claimed_at' => now()]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, 'You already took that reward.'];
    }
    give_petals((int)$uid, (int)$coins);
    $lines = [money($coins), $xp . ' XP'];
    if ($item !== '') {
        [$slug, $qty] = explode(':', $item) + [1 => '1'];
        if ($iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug])) { give_item($uid, $iid, max(1, (int)$qty)); $lines[] = first_week_item_text($item); }
    }
    if ($day === 7) {
        q("UPDATE users SET title = ? WHERE id = ? AND (title IS NULL OR title = '')", [FIRST_WEEK_TITLE, $uid]);
        $lines[] = 'the title “' . FIRST_WEEK_TITLE . '”';
    }
    db()->commit();
    add_xp($uid, $xp, 'Wren’s First Week');
    prize('🐦', $day === 7 ? 'First Week complete!' : 'Day ' . $day . ' card done', $day === 7 ? '“You’re a proper Hollow gnome now.”' : '“' . FIRST_WEEK[$day][0] . ': lovely work.”', $lines);
    return [true, ''];
}

/** The card Today shows: the first unlocked, unclaimed day. Null when there is nothing to do or the week is over. */
function first_week_today_card(int $uid): ?array
{
    $st = first_week_state($uid, true);
    if (!$st || $st['complete']) return null;
    foreach ($st['cards'] as $day => $c) {
        if ($c['locked'] || $c['claimed']) continue;
        return ['day' => $day] + $c + ['unlocked' => $st['unlocked'], 'claimed_n' => $st['claimed_n']];
    }
    return null;
}
