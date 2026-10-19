<?php
declare(strict_types=1);
/**
 * Town squares (v0.7.20).
 * Every region's market town (and the Mossbottom hub) has places to go: the Green, a teahouse, the notice board, the library,
 * and two places found only in that region. Each place has a few things to do (town_actions), most a few times a day.
 * Places and actions live in the database (Admin → Town places), first filled from includes/data/towns.txt.
 */

require_once __DIR__ . '/world.php';

/** Per town: [teahouse name, drink, stat the drink boosts, green name]. */
const TOWN_FLAVOUR = [
    'Mossbottom' => ['The Mossy Mug', 'acorn coffee', 'charm', 'Mossbottom Green'],
    'The Maplewold' => ['The Lumberjack’s Kettle', 'maple tea', 'hardiness', 'Maple Green'],
    'Maizehollow' => ['Abuela Bee’s Café', 'spiced hot chocolate', 'charm', 'The Cornfield Green'],
    'The Sunsprinkle Isles' => ['The Breezy Hut', 'coconut water', 'nimble', 'Palm Green'],
    'The Rainroot Reaches' => ['The Yerba Gourd', 'maté', 'grit', 'The Highland Green'],
    'Mistmoor' => ['The Drizzle & Crumpet', 'pot of tea', 'lore', 'The Village Green'],
    'Olivewhistle Shore' => ['Café Cicada', 'tiny espresso', 'nimble', 'The Lemon Grove'],
    'Birchbramble Steppe' => ['The Samovar', 'black tea with jam', 'hardiness', 'The Birch Green'],
    'The Dunewhisper' => ['The Mint Tent', 'sweet mint tea', 'charm', 'The Palm Court'],
    'The Greatcanopy' => ['The Baobab Bar', 'hibiscus tea', 'grit', 'The Shady Green'],
    'Thornacre Savanna' => ['The Rooibos Rest', 'rooibos tea', 'luck', 'The Acacia Green'],
    'Spicepeak' => ['The Chai Stall', 'masala chai', 'sense', 'The Terrace Green'],
    'Blossomreach' => ['The Bamboo Teahouse', 'bowl of matcha', 'lore', 'The Moss Garden'],
    'The Monsoon Tangle' => ['The Kopi Corner', 'iced coffee', 'nimble', 'The Banyan Green'],
    'The Coralscatter' => ['The Flat White', 'flat white', 'luck', 'The Pōhutukawa Green'],
];

/**
 * Festivals (v0.7.31): one day a month in each town (Hollow time). On festival day everything in that town's square
 * pays twice, and there's a festival stall on the Green with a free treat once a day.
 * town => [festival name, icon, day of the month, blurb]
 */
const TOWN_FESTIVALS = [
    'Mossbottom' => ['Moss Fair', '🎡', 1, 'The whole Hollow comes to Mossbottom: stalls, games and far too much acorn cake.'],
    'The Maplewold' => ['Maple Moon Festival', '🍁', 3, 'Sugar-on-snow, leaf piles and a lantern parade under the maples.'],
    'Maizehollow' => ['Festival of the Three Sisters', '🌽', 5, 'Corn, beans and squash are blessed, and everyone dances in the plaza.'],
    'The Sunsprinkle Isles' => ['Steel-drum Carnival', '🥁', 7, 'Costumes, coconut races and music till sunrise.'],
    'The Rainroot Reaches' => ['Potato Hundred Day', '🥔', 9, 'A hundred kinds of potato, roasted, mashed and judged.'],
    'Mistmoor' => ['Puddle Day', '☔', 11, 'Umbrella parades, puddle-jumping and tea in the rain.'],
    'Olivewhistle Shore' => ['Olive Harvest Feast', '🫒', 13, 'Long tables by the harbour and fresh oil on warm bread.'],
    'Birchbramble Steppe' => ['Mushroom Moon', '🍄', 15, 'Baskets of mushrooms, birch-sap drinks and a steam in the banya.'],
    'The Dunewhisper' => ['Night of Lanterns and Dates', '🏮', 17, 'The bazaar stays open all night under a thousand lamps.'],
    'The Greatcanopy' => ['Rain-drum Festival', '🥁', 19, 'The drummers play the rains in, and Grandmother Tortoise tells the longest story of the year.'],
    'Thornacre Savanna' => ['Coffee Bloom Gathering', '☕', 21, 'Coffee ceremonies on Sunset Rock, three cups each.'],
    'Spicepeak' => ['Festival of Colours', '🌈', 23, 'Clouds of coloured spice-powder, music, and sweets made with cardamom.'],
    'Blossomreach' => ['Blossom Viewing', '🌸', 25, 'Picnics under the trees, and every shop closes early.'],
    'The Monsoon Tangle' => ['Floating Lantern Night', '🛶', 27, 'Little boats of flowers and candles drift down every canal.'],
    'The Coralscatter' => ['Tide-turn Feast', '🐚', 28, 'A feast on the beach as the big tide turns.'],
];

/** Today's festival in a town (Hollow time), or null. */
function town_festival(string $town, ?int $ts = null): ?array
{
    $f = TOWN_FESTIVALS[$town] ?? null;
    return $f && (int)hollow_date('j', $ts) === $f[2] ? $f : null;
}

/** The next few festivals across the Hollow: [[town, festival, days away], …]. */
function upcoming_festivals(int $n = 3): array
{
    $out = [];
    for ($d = 0; $d < 32 && count($out) < $n; $d++) {
        $ts = time() + $d * 86400;
        foreach (TOWN_FESTIVALS as $town => $f) {
            if ((int)hollow_date('j', $ts) === $f[2]) $out[] = [$town, $f, $d];
        }
    }
    return array_slice($out, 0, $n);
}

/** The festival stall's free treat (once a day, in a town having its festival). */
function festival_treat(array $u, string $town): array
{
    $f = town_festival($town);
    if (!$f) return [false, 'There’s no festival here today.'];
    if (!can_reach($u, $town)) return [false, 'You need to be in ' . $town . '.'];
    $uid = (int)$u['id'];
    // A town_uses slot of its own. v0.7.61: a big positive number (it was negative, which MySQL's unsigned
    // column refused, so everyone was told they'd already had their treat).
    $key = 2000000000 + (int)array_search($town, array_keys(TOWN_FESTIVALS), true);
    if (q_val('SELECT 1 FROM town_uses WHERE user_id = ? AND action_id = ? AND day = ?', [$uid, $key, town_day()])) {
        return [false, 'You’ve had your festival treat today. Enjoy the rest of the party!'];
    }
    try {
        db_insert('town_uses', ['user_id' => $uid, 'action_id' => $key, 'day' => town_day(), 'uses' => 1]);
    } catch (PDOException $e) {
        return [false, 'You’ve had your festival treat today. Enjoy the rest of the party!'];
    }
    require_once __DIR__ . '/events.php';
    $r = region_by_name($town);
    $seed = $r ? q_one("SELECT i.id, i.name FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id JOIN items i ON i.id = p.seed_item_id
                        WHERE pr.region_id = ? AND pr.tier IN ('staple', 'uncommon', 'flower') ORDER BY " . sql_random() . ' LIMIT 1', [$r['id']]) : null;
    $lines = apply_event_effect($u, 'xp:10+coins:20-40+rand:food');
    if ($seed) { give_item($uid, (int)$seed['id'], 1); $lines[] = '+1 × ' . $seed['name']; }
    prize($f[1], $f[0], 'The festival-goers press a treat into your hands and pull you into the dancing!', $lines);
    return [true, ''];
}

/** Every town's name, Mossbottom first. */
function town_names(): array
{
    return array_merge([HUB_REGION], array_column(all_regions(), 'gnomish_name'));
}

function town_key(string $town): string
{
    if ($town === HUB_REGION) return 'hub';
    $r = region_by_name($town);
    return $r ? strtolower((string)$r['code']) : 'x';
}

function ensure_towns(): void
{
    require_once __DIR__ . '/catalog.php';
    $spotIds = [];
    $addSpot = function (array $row) use (&$spotIds): void {
        $id = q_val('SELECT id FROM town_spots WHERE slug = ?', [$row['slug']]);
        $spotIds[$row['slug']] = $id ? (int)$id : db_insert('town_spots', $row + ['hours' => '', 'months' => '', 'active' => 1]);
    };
    $addAction = function (string $spot, array $row) use (&$spotIds): void {
        if (empty($spotIds[$spot]) || q_val('SELECT 1 FROM town_actions WHERE slug = ?', [$row['slug']])) return;
        if (isset($row['effect'])) $row['effect'] = energy_scale_effect((string)$row['effect']);   // data is written in the old scale
        if (isset($row['energy'])) $row['energy'] = energy_cost_scale((int)$row['energy']);
        db_insert('town_actions', $row + ['spot_id' => $spotIds[$spot], 'kind' => 'effect', 'effect' => '', 'cost_coins' => 0, 'cost_item' => '',
            'energy' => 0, 'chance' => 100, 'stat' => '', 'daily' => 1, 'active' => 1, 'sort_order' => 0]);
    };
    // The four shared places in every town
    foreach (town_names() as $town) {
        $k = town_key($town);
        [$tea, $drink, $stat, $green] = TOWN_FLAVOUR[$town] ?? ['The Teahouse', 'cup of tea', 'charm', 'The Green'];
        $addSpot(['slug' => $k . '-green', 'region' => $town, 'kind' => 'green', 'icon' => '🌳', 'name' => $green, 'sort_order' => 1,
            'description' => 'Benches under the trees, a duck pond, and plenty of grass for a picnic. Gnomes come here to rest and to meet.']);
        $addAction($k . '-green', ['slug' => $k . '-bench', 'label' => 'Sit on a bench', 'effect' => 'energy:6', 'sort_order' => 1,
            'success_text' => 'You sit for a while and watch the town go by. Lovely.']);
        $addAction($k . '-green', ['slug' => $k . '-birds', 'label' => 'Feed the birds', 'effect' => 'rand:forage+xp:2', 'cost_item' => 'anyseed',
            'chance' => 50, 'stat' => 'sense', 'daily' => 3, 'sort_order' => 2,
            'success_text' => 'The birds flutter round you, and one leaves a little present at your feet.',
            'fail_text' => 'They gobble every crumb and fly off. Sweet, though.']);
        $addAction($k . '-green', ['slug' => $k . '-picnic', 'label' => 'Have a picnic', 'effect' => 'energy:12+xp:3', 'cost_item' => 'anyfood', 'sort_order' => 3,
            'success_text' => 'Food always tastes better outside, on a blanket, in the sun.']);
        $addSpot(['slug' => $k . '-tea', 'region' => $town, 'kind' => 'teahouse', 'icon' => '☕', 'name' => $tea, 'sort_order' => 2,
            'description' => 'Little tables, a steaming kettle, and the best gossip in town. Everyone passes through here sooner or later.']);
        $addAction($k . '-tea', ['slug' => $k . '-drink', 'label' => 'Order ' . an($drink) . ' (12 Petals)', 'cost_coins' => 12, 'daily' => 2, 'sort_order' => 1,
            'effect' => 'tbuff:' . $stat . ':2:60', 'success_text' => 'You sip your ' . $drink . ' slowly. Just what you needed.']);
        $addSpot(['slug' => $k . '-board', 'region' => $town, 'kind' => 'board', 'icon' => '📋', 'name' => 'The Notice Board', 'sort_order' => 3,
            'description' => 'Pinned notes flap in the breeze: jobs, lost hats, contests and favours.']);
        foreach ([['jobs', '📋 Job Board', 'jobs.php'], ['show', '🏅 Village Show', 'show.php'], ['community', '🌻 Community Garden', 'community.php'], ['games', '🎲 Games & contests', 'games.php']] as $i => [$s, $l, $page]) {
            $addAction($k . '-board', ['slug' => $k . '-link-' . $s, 'label' => $l, 'kind' => 'link', 'link' => $page, 'daily' => 0, 'sort_order' => $i + 1]);
        }
        $addSpot(['slug' => $k . '-library', 'region' => $town, 'kind' => 'library', 'icon' => '📚', 'name' => $town === HUB_REGION ? 'The Hub Library' : 'The Town Library',
            'sort_order' => 4, 'description' => 'Tall shelves, a sleepy librarian, and a big book of local history open on a stand.']);
        $addAction($k . '-library', ['slug' => $k . '-read', 'label' => 'Read the local history', 'kind' => 'read', 'effect' => 'xp:6', 'sort_order' => 1,
            'success_text' => 'You turn the old pages carefully and read:']);
        $addAction($k . '-library', ['slug' => $k . '-riddle', 'label' => 'Answer the librarian’s question', 'kind' => 'quiz', 'effect' => 'coins:15-30+xp:4', 'sort_order' => 2,
            'success_text' => '“Quite right!” The librarian beams over her spectacles.', 'fail_text' => '“Not quite, dear.” She shows you the page.']);
    }
    // Places found only in one region
    $order = [];
    foreach (catalog_lines('towns.txt') as $r) {
        if ($r[0] === 'S' && count($r) >= 8) {
            $order[$r[1]] = ($order[$r[1]] ?? 4) + 1;
            $addSpot(['slug' => $r[2], 'region' => $r[1], 'kind' => 'special', 'icon' => $r[3], 'name' => $r[4], 'hours' => $r[5], 'months' => $r[6],
                'description' => $r[7], 'sort_order' => $order[$r[1]]]);
        } elseif ($r[0] === 'A' && count($r) >= 14) {
            $addAction($r[1], ['slug' => $r[2], 'label' => $r[3], 'kind' => $r[4], 'effect' => $r[5], 'cost_coins' => (int)$r[6], 'cost_item' => $r[7],
                'energy' => (int)$r[8], 'chance' => (int)$r[9], 'stat' => $r[10], 'daily' => (int)$r[11], 'success_text' => $r[12], 'fail_text' => $r[13] ?? '']);
        } elseif ($r[0] === 'L' && count($r) >= 3 && !q_val('SELECT 1 FROM town_lore WHERE region = ? AND text = ?', [$r[1], $r[2]])) {
            db_insert('town_lore', ['region' => $r[1], 'text' => $r[2]]);
        }
    }
    // Almanac: a "Tales of …" page per town, unlocked by reading in its library, and a getting-started page for everyone
    foreach (town_names() as $town) {
        $key = 'lore:' . town_key($town);
        $body = implode("\n\n", q('SELECT text FROM town_lore WHERE region = ? ORDER BY id', [$town])->fetchAll(PDO::FETCH_COLUMN));
        if ($body === '') continue;
        $have = q_val('SELECT id FROM encyclopedia_entries WHERE unlock_key = ?', [$key]);
        if ($have) {
            q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [$body, $have]);
        } else {
            db_insert('encyclopedia_entries', ['chapter' => 'Towns', 'category' => 'Local lore', 'title' => 'Tales of ' . $town, 'body' => $body,
                'unlock_key' => $key, 'hint' => 'Read the local history in ' . $town . '’s library.', 'sort_order' => 0]);
        }
    }
    if (!q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'Town squares' AND chapter = 'General'")) {
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'Town squares',
            'body' => "🏘️ Every region’s market town has a [b]Town Square[/b], and so does Mossbottom. There’s always something to do: "
                . "rest on the Green, have a drink at the teahouse, read the local history at the library, and visit the places "
                . "you’ll only find in that region, like the Standing Stones of Mistmoor or the Koi Pond of Blossomreach.\n\n"
                . "Most things can be done once or a few times a day. Some places only open at certain hours, or in certain months. "
                . "The Hollow keeps its own clock, shown at the top of the town page.",
            'unlock_key' => 'start', 'hint' => '', 'sort_order' => 10]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            if (!q_val('SELECT 1 FROM user_encyclopedia WHERE user_id = ? AND entry_id = ?', [$uid, $eid])) {
                db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
            }
        }
    }
}

/** The town the player is standing in, or Mossbottom if they asked for the hub. */
function town_for(array $u, bool $hub): string
{
    return $hub ? HUB_REGION : player_location($u);
}

function town_spots(string $town): array
{
    return q('SELECT * FROM town_spots WHERE region = ? AND active = 1 ORDER BY sort_order, id', [$town])->fetchAll();
}

function town_actions(int $spotId): array
{
    return q('SELECT * FROM town_actions WHERE spot_id = ? AND active = 1 ORDER BY sort_order, id', [$spotId])->fetchAll();
}

/** Is a place open right now? Returns null if open, or a short reason if not. */
function spot_closed(array $s): ?string
{
    if (trim((string)$s['months']) !== '') {
        $months = array_map('intval', explode(',', (string)$s['months']));
        if (!in_array((int)hollow_date('n'), $months, true)) {
            return 'Only open in ' . implode(', ', array_map(fn($m) => date('F', mktime(0, 0, 0, $m, 1)), $months)) . '.';
        }
    }
    if (preg_match('/^(\d{1,2})-(\d{1,2})$/', trim((string)$s['hours']), $m)) {
        if (!in_array(hollow_hour(), schedule_hours((int)$m[1], (int)$m[2]), true)) {
            return 'Open ' . hour_label((int)$m[1]) . ' to ' . hour_label((int)$m[2]) . ' (Hollow time).';
        }
    }
    return null;
}

function town_day(): string
{
    return hollow_date('Y-m-d');
}

/** Uses of each action today: [action_id => uses]. */
function town_uses_today(int $uid): array
{
    $out = [];
    foreach (q('SELECT action_id, uses FROM town_uses WHERE user_id = ? AND day = ?', [$uid, town_day()])->fetchAll() as $r) $out[(int)$r['action_id']] = (int)$r['uses'];
    return $out;
}

/** The item a cost like "anyseed" would use (the cheapest one the player has). */
function town_cost_item(int $uid, string $cost, int $pickId = 0): ?array
{
    if ($cost === '') return null;
    if ($pickId > 0 && in_array($cost, ['anyseed', 'anyfood'], true)) {   // v0.7.61: the player picked one
        return q_one("SELECT i.id, i.name FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.id = ? AND i.category = ?",
            [$uid, $pickId, $cost === 'anyseed' ? 'seed' : 'food']) ?: null;
    }
    $where = match ($cost) {
        'anyseed' => "i.category = 'seed'",
        'anyfood' => "i.category = 'food'",
        default => 'i.slug = ' . db()->quote($cost),
    };
    return q_one("SELECT i.id, i.name FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND $where
                  ORDER BY i.base_price, i.name LIMIT 1", [$uid]) ?: null;
}

function town_cost_label(array $a): string
{
    $bits = [];
    if ((int)$a['energy'] > 0) $bits[] = '⚡' . (int)$a['energy'];
    if ($a['cost_item'] === 'anyseed') $bits[] = '1 seed';
    elseif ($a['cost_item'] === 'anyfood') $bits[] = '1 food';
    elseif ($a['cost_item'] !== '') $bits[] = '1 × ' . (q_val('SELECT name FROM items WHERE slug = ?', [$a['cost_item']]) ?: $a['cost_item']);
    return implode(' · ', $bits);
}

/** The chance of success, with the stat's help. */
function town_chance(array $u, array $a): int
{
    $c = (int)$a['chance'];
    if ($c >= 100) return 100;
    if ($a['stat'] === 'luck') $c += (int)round(luck_percent($u));
    elseif ($a['stat'] !== '' && isset(GNOME_STATS[$a['stat']])) $c += 5 * eff_mod($u, $a['stat']);
    return max(1, min(100, $c));
}

/** Claim one of today's uses. False if they're all used up. */
function town_claim_use(int $uid, array $a): bool
{
    if ((int)$a['daily'] <= 0) return true;   // as often as you like
    $day = town_day();
    $row = q_one('SELECT id FROM town_uses WHERE user_id = ? AND action_id = ? AND day = ?', [$uid, $a['id'], $day]);
    if (!$row) {
        try {
            db_insert('town_uses', ['user_id' => $uid, 'action_id' => $a['id'], 'day' => $day, 'uses' => 1]);
            return true;
        } catch (PDOException $e) {
            $row = q_one('SELECT id FROM town_uses WHERE user_id = ? AND action_id = ? AND day = ?', [$uid, $a['id'], $day]);
            if (!$row) return false;
        }
    }
    return q('UPDATE town_uses SET uses = uses + 1 WHERE id = ? AND uses < ?', [$row['id'], (int)$a['daily']])->rowCount() === 1;
}

/** Do something in town. Results are shown as a prize box; returns [ok, error message]. */
/** The take-away version of a town's teahouse drink (v0.7.37): an item you can drink later from the satchel. */
function town_tea_item(string $region): int
{
    $slug = 'teahouse-' . town_key($region);
    $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
    if ($id) return $id;
    [$tea, $drink, $stat] = TOWN_FLAVOUR[$region] ?? ['The Teahouse', 'cup of tea', 'charm'];
    return db_insert('items', ['name' => mb_substr(ucfirst($drink) . ' (to go)', 0, 80), 'slug' => $slug, 'category' => 'food', 'rarity' => 5,
        'base_price' => 4, 'edible' => 1, 'tradable' => 1,
        'description' => 'A flask from ' . $tea . ' in ' . $region . '. Drink it whenever you like: ' . (GNOME_STATS[$stat][0] ?? $stat) . ' +2 for an hour.',
        'effects' => json_encode(['tea' => 'tbuff:' . $stat . ':2:60'])]);
}

function town_act(array $u, int $actionId, bool $toGo = false, int $pickId = 0): array
{
    $uid = (int)$u['id'];
    $a = q_one('SELECT a.*, s.region, s.slug AS spot_slug, s.name AS spot_name, s.icon AS spot_icon, s.hours, s.months, s.active AS spot_active
                FROM town_actions a JOIN town_spots s ON s.id = a.spot_id WHERE a.id = ? AND a.active = 1', [$actionId]);
    if (!$a || !(int)$a['spot_active'] || $a['kind'] === 'link') return [false, 'There’s nothing like that to do here.'];
    if (!can_reach($u, (string)$a['region'])) return [false, 'You need to be in ' . $a['region'] . ' for that.'];
    if ($why = spot_closed($a)) return [false, $a['spot_name'] . ' is closed. ' . $why];
    require_once __DIR__ . '/journey.php';
    if ($jc = journey_lock($uid, 'spot', (string)$a['spot_slug'])) return [false, '🚧 ' . $a['spot_name'] . ' is closed for repairs. Help rebuild it in Wren’s Journey (' . $jc['region'] . ': ' . $jc['title'] . ').'];
    if (q_val("SELECT 1 FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid])) return [false, 'Finish your walk first.'];
    db()->beginTransaction();
    if (!town_claim_use($uid, $a)) {
        db()->rollBack();
        return [false, 'You’ve done that ' . ((int)$a['daily'] === 1 ? 'once' : (int)$a['daily'] . ' times') . ' today already. Come back tomorrow!'];
    }
    $e = (int)$a['energy'];
    if ($e > 0 && q('UPDATE users SET energy = energy - ? WHERE id = ? AND energy >= ?', [$e, $uid, $e])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You need ' . $e . ' energy for that.'];
    }
    $c = (int)$a['cost_coins'];
    if ($c > 0 && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$c, $uid, $c])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You need ' . money($c) . ' for that.'];
    }
    $lines = [];
    if ($a['cost_item'] !== '') {
        $it = town_cost_item($uid, (string)$a['cost_item'], $pickId);   // v0.7.61: the seed or food you chose
        if (!$it || !give_item($uid, (int)$it['id'], -1)) {
            db()->rollBack();
            return [false, match ($a['cost_item']) { 'anyseed' => 'You need a seed packet for that.', 'anyfood' => 'You need something to eat for that.', default => 'You don’t have what you need for that.' }];
        }
        $lines[] = '−1 × ' . $it['name'];
        // v0.8.6: a picnic gives the food's own energy plus 1 for eating outside (it used to give 2 for any food, even a raw radish)
        if (str_ends_with((string)$a['slug'], '-picnic') && $a['cost_item'] === 'anyfood') {
            $foodFx = json_decode((string)q_val('SELECT effects FROM items WHERE id = ?', [(int)$it['id']]), true) ?: [];
            $a['effect'] = 'energy:' . (max(0, (int)($foodFx['energy'] ?? 0)) + 1) . '+xp:3';
        }
    }
    if ($c > 0) $lines[] = '−' . money($c);
    if ($a['kind'] === 'quiz') {
        $q = town_quiz_question();
        if (!$q) {
            db()->rollBack();
            return [false, 'The quizmaster has lost the question cards. Try later!'];
        }
        db()->commit();
        $_SESSION['town_quiz'] = $q + ['action' => (int)$a['id'], 'token' => bin2hex(random_bytes(8))];
        return [true, ''];
    }
    if ($toGo && str_ends_with((string)$a['slug'], '-drink')) {   // take it with you instead (v0.7.37)
        $n = town_festival((string)$a['region']) ? 2 : 1;
        $teaId = town_tea_item((string)$a['region']);
        give_item($uid, $teaId, $n);
        db()->commit();
        calling_event($uid, 'townact', (string)$a['slug'], 1, ['spot' => (string)$a['spot_slug'], 'kind' => (string)$a['kind'], 'region' => (string)$a['region']]);   // v0.9.4 N11: a take-away drink counts too
        prize((string)($a['spot_icon'] ?: '☕'), $a['spot_name'], 'To go, please!', array_merge($lines,
            ['+' . $n . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$teaId]), 'Drink it from your Satchel whenever you like.']));
        return [true, ''];
    }
    $fresh = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $win = random_int(1, 100) <= town_chance($fresh, $a);
    $text = $win ? (string)$a['success_text'] : (string)($a['fail_text'] ?: 'Not this time.');
    if ($a['kind'] === 'read') {
        $lore = q('SELECT text FROM town_lore WHERE region = ? ORDER BY id', [$a['region']])->fetchAll(PDO::FETCH_COLUMN);
        if ($lore) {
            $lines[] = '“' . $lore[(int)$fresh['lore_read'] % count($lore)] . '”';
            q('UPDATE users SET lore_read = lore_read + 1 WHERE id = ?', [$uid]);
        }
        $lines[] = library_roll($u, (string)$a['region']);
    }
    if ($win && $a['effect'] !== '') {
        require_once __DIR__ . '/events.php';
        $lines = array_merge($lines, apply_event_effect($fresh, (string)$a['effect']));
        if ($fest = town_festival((string)$a['region'])) {   // festival day: everything pays twice (v0.7.31)
            $lines[] = $fest[1] . ' Festival day, double!';
            $lines = array_merge($lines, apply_event_effect($fresh, (string)$a['effect']));
        }
    }
    db()->commit();
    if ($win || $a['kind'] === 'read') calling_event($uid, 'townact', (string)$a['slug'], 1, ['spot' => (string)$a['spot_slug'], 'kind' => (string)$a['kind'], 'region' => (string)$a['region']]);   // v0.9.4 N11
    prize((string)($a['spot_icon'] ?: '🏘️'), $a['spot_name'] . ': ' . $a['label'], $text, $lines);
    return [true, ''];
}

/**
 * What else turns up while reading in a library (v0.7.27): a roll on a table, and often nothing new.
 *   45% nothing · 25% the town's "Tales of" page · 15% a hidden village of the region · 10% a hidden landmark · 5% a creature sketch.
 * Hidden places found this way go on your map (a side path appears), just like exploring.
 */
function library_roll(array $u, string $town): string
{
    $uid = (int)$u['id'];
    $roll = random_int(1, 100);
    $r = region_by_name($town);
    if ($roll > 45 && $roll <= 70 && unlock_entries($uid, 'lore:' . town_key($town))) {
        return '📖 Tucked between the pages: the whole “Tales of ' . $town . '”.';
    }
    if ($r && $roll > 70) {
        require_once __DIR__ . '/roads.php';
        $kinds = $roll <= 85 ? ['village'] : ($roll <= 95 ? ['haven', 'wonder', 'lair'] : []);
        if ($kinds) {
            $marks = implode(',', array_fill(0, count($kinds), '?'));
            foreach (q("SELECT l.* FROM locations l JOIN routes rt ON rt.b_id = l.id AND rt.kind = 'side' WHERE l.region_id = ? AND l.kind IN ($marks) ORDER BY " . sql_random(),
                         array_merge([$r['id']], $kinds))->fetchAll() as $l) {
                if (place_known($uid, $l)) continue;
                unlock_entries($uid, ($l['kind'] === 'village' ? 'village:' : 'landmark:') . $l['slug']);
                return '🗺️ An old map in the margin shows the way to ' . $l['name'] . '. It’s on your map now (a side path off the road).';
            }
        } else {
            $lands = q('SELECT landscape FROM zones WHERE region_id = ?', [$r['id']])->fetchAll(PDO::FETCH_COLUMN);
            foreach (q("SELECT c.slug, c.name, c.landscapes FROM creatures c WHERE c.active = 1 AND c.size <> 'boss' ORDER BY " . sql_random())->fetchAll() as $c) {
                if ($c['landscapes'] !== 'any' && !array_intersect($lands, array_map('trim', explode(',', $c['landscapes'])))) continue;
                if (unlock_entries($uid, 'creature:' . $c['slug'])) return '🖋️ A careful sketch of the ' . $c['name'] . ', with notes. You copy it into your Almanac.';
            }
        }
    }
    return '📚 Nothing new in the margins today, but it was a good read.';
}

/** A question from the Almanac's knowledge: [q, options => [key => label], answer]. */
function town_quiz_question(): ?array
{
    for ($try = 0; $try < 5; $try++) {
        $kind = random_int(1, 3);
        if ($kind === 1) {
            $p = q_one("SELECT p.name, r.gnomish_name AS region, r.id AS rid, r.climate_trait FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id
                        JOIN regions r ON r.id = pr.region_id WHERE pr.tier = 'staple' ORDER BY " . sql_random() . ' LIMIT 1');
            if (!$p) continue;
            $others = q('SELECT gnomish_name FROM regions WHERE id <> ? AND id NOT IN (SELECT region_id FROM plant_regions pr JOIN plants pl ON pl.id = pr.plant_id WHERE pl.name = ?)
                         ORDER BY ' . sql_random() . ' LIMIT 2', [$p['rid'], $p['name']])->fetchAll(PDO::FETCH_COLUMN);
            if (count($others) < 2) continue;
            $opts = array_merge([$p['region']], $others);
            return town_quiz_pack('Which region grows ' . $p['name'] . ' as an everyday staple crop?', $opts, $p['region'],
                'The region you want is known for this: “' . strtok((string)$p['climate_trait'], ':') . '”.');
        }
        if ($kind === 2) {
            require_once __DIR__ . '/nutrients.php';
            $p = q_one("SELECT name, nutrient FROM plants WHERE nutrient IN ('n', 'p', 'k') ORDER BY " . sql_random() . ' LIMIT 1');
            if (!$p) continue;
            $opts = array_map(fn($k) => NUTRIENTS[$k][0], array_keys(NUTRIENTS));
            $ans = NUTRIENTS[$p['nutrient']][0];
            return town_quiz_pack('Which nutrient does the ' . $p['name'] . ' plant hunger for most?', $opts, $ans,
                'The answer starts with “' . $ans[0] . '” and has ' . strlen($ans) . ' letters.');
        }
        $f = q_one("SELECT p.name, (SELECT r.gnomish_name FROM plant_regions pr JOIN regions r ON r.id = pr.region_id WHERE pr.plant_id = p.id LIMIT 1) AS region
                    FROM plants p WHERE p.kind = 'flower' ORDER BY " . sql_random() . ' LIMIT 1');
        $o = q("SELECT name FROM plants WHERE kind NOT IN ('flower', 'cover') ORDER BY " . sql_random() . ' LIMIT 2')->fetchAll(PDO::FETCH_COLUMN);
        if (!$f || count($o) < 2) continue;
        return town_quiz_pack('Which of these is grown for its flowers?', array_merge([$f['name']], $o), $f['name'],
            $f['region'] ? 'The flower you want grows wild in ' . $f['region'] . '.' : 'The flower’s name starts with “' . mb_substr($f['name'], 0, 1) . '”.');
    }
    return null;
}

function town_quiz_pack(string $question, array $opts, string $answer, string $clue = ''): array
{
    shuffle($opts);
    $keyed = [];
    foreach (array_values($opts) as $i => $o) $keyed['o' . $i] = $o;
    return ['q' => $question, 'options' => $keyed, 'answer' => (string)array_search($answer, $keyed, true), 'clue' => $clue];
}

/** Answer the question waiting in the session. */
function town_quiz_answer(array $u, string $token, string $choice): array
{
    $q = $_SESSION['town_quiz'] ?? null;
    if (!$q || !hash_equals((string)$q['token'], $token)) return [false, 'That question has gone.'];
    unset($_SESSION['town_quiz']);
    $a = q_one('SELECT a.*, s.name AS spot_name, s.icon AS spot_icon FROM town_actions a JOIN town_spots s ON s.id = a.spot_id WHERE a.id = ?', [$q['action']]);
    if (!$a) return [false, 'That question has gone.'];
    $right = hash_equals((string)$q['answer'], $choice);
    $lines = ['Q: ' . $q['q']];
    if ($right) {
        $lines[] = 'A: ' . ($q['options'][$q['answer']] ?? '?');
        if ($a['effect'] !== '') {
            require_once __DIR__ . '/events.php';
            $lines = array_merge($lines, apply_event_effect($u, (string)$a['effect']));
        }
    } else {
        // v0.7.27: a wrong answer earns a clue, not the whole answer
        $lines[] = 'It isn’t ' . ($q['options'][$choice] ?? 'that') . '.';
        if (!empty($q['clue'])) $lines[] = '📝 A clue for next time: ' . $q['clue'];
        add_xp((int)$u['id'], 1);
        $lines[] = '+1 XP for trying';
    }
    prize((string)($a['spot_icon'] ?: '🧠'), $a['spot_name'], $right ? (string)$a['success_text'] : (string)($a['fail_text'] ?: 'Not quite!'), $lines);
    return [true, ''];
}
