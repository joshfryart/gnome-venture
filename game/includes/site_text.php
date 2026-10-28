<?php
declare(strict_types=1);

/*
 * v0.8.9: words on public pages that the admin can edit (Admin → 📝 Page text), with the original kept as a default.
 * Only changed texts are stored (table site_texts); "Reset" deletes the stored copy.
 * Placeholders filled in when shown: {site} {start_region} {energy_rate} {energy_minutes} {native} {pages} {regions}
 */

/** key => [page, label, default, kind]  kind: line = one line, no formatting; text = BBCode allowed; faq = Q:/A: lines */
const SITE_TEXTS = [
    // ---- Front page (visitors)
    'home.title' => ['Front page', 'Browser tab & Google title', '{site}: a free, cosy garden game in your browser', 'line'],
    'home.headline' => ['Front page', 'Headline', 'Grow a garden. Wander the Hollow. 🍄', 'line'],
    'home.lede' => ['Front page', 'Opening paragraph', 'A free, cosy browser game about garden gnomes. Plant real-world crops in living soil, cook what you grow, walk the roads of fourteen regions, befriend the townsfolk and play little daily games.', 'text'],
    'home.button' => ['Front page', 'Sign-up button', '🌱 Claim your plot, it’s free', 'line'],
    'home.small' => ['Front page', 'Small line under the button', 'No ads, nothing to buy. Plays on your phone or computer, a few minutes at a time.', 'line'],
    'home.f1' => ['Front page', 'Feature box 1 (first line = title)', "🌱 Soil you care for\nTill or build no-till beds, feed the soil and watch it grade up from F to S. Plants only grow while watered, so check in when it suits you.", 'text'],
    'home.f2' => ['Front page', 'Feature box 2 (first line = title)', "🍲 Cook and craft\nBuild a kitchen and turn harvests into meals that restore energy and boost your gnome. Craft tools, compost and yard decor.", 'text'],
    'home.f3' => ['Front page', 'Feature box 3 (first line = title)', "🗺️ Fourteen regions\nWalk the roads between towns, wander into the wilds, gather, meet creatures and restore old landmarks. Every region has its own climate.", 'text'],
    'home.f4' => ['Front page', 'Feature box 4 (first line = title)', "🏘️ Towns that live\nShopkeepers keep their own hours, travellers wander from town to town, and friendships grow with chats and gifts.", 'text'],
    'home.f5' => ['Front page', 'Feature box 5 (first line = title)', "🎲 Games and contests\nSeven daily games, from Mushroom Sweeper to Guess the Weight, plus a weekly Village Show and a monthly Grand Harvest Fair.", 'text'],
    'home.f6' => ['Front page', 'Feature box 6 (first line = title)', "📖 Your Almanac\nA book that fills itself in as you grow, cook, travel and meet folk. {pages} pages to find.", 'text'],
    'home.jeff' => ['Front page', 'Jeff’s hello (speech bubble in the top card)', 'Hi, I’m Jeff, the Puzzler! I’m a jigsaw piece and your host. Want a quick look around before you plant anything?', 'line'],
    'home.tourbtn' => ['Front page', 'Tour button', '👀 Take the tour with Jeff', 'line'],
    'home.tour.1' => ['Front page', 'Tour stop 1 (first line = title, second = what Jeff says)', "🌱 Grow a garden\nThis is your garden. Plant, water, wait. Soil gets better the more you look after it.", 'text'],
    'home.tour.2' => ['Front page', 'Tour stop 2 (first line = title, second = what Jeff says)', "🧺 Your satchel\nEverything you grow, cook and find lives here: seeds, tools, dinner.", 'text'],
    'home.tour.3' => ['Front page', 'Tour stop 3 (first line = title, second = what Jeff says)', "🗺️ Walk the world\nFourteen regions, with roads, rest stops and villagers who have lives of their own.", 'text'],
    'home.tour.4' => ['Front page', 'Tour stop 4 (first line = title, second = what Jeff says)', "🏘️ Visit the town\nShops, orders and neighbours. Bring a few Petals.", 'text'],
    'home.tour.5' => ['Front page', 'Tour stop 5 (first line = title, second = what Jeff says)', "🎲 Little games\nQuick daily games, and my favourites: the puzzles. Jigsaws that move, gutters, gnome beds.", 'text'],
    'home.tour.6' => ['Front page', 'Tour stop 6 (first line = title, second = what Jeff says)', "📖 Fill your Almanac\nA book that fills in as you play. It knows more than I do. Mostly.", 'text'],
    'home.try' => ['Front page', 'Jeff’s line above the puzzle demo', 'Go on, try one. No sign-up. The picture moves while you solve it.', 'line'],
    'home.gate' => ['Front page', 'Jeff’s line before the last button', 'Ready to make your own gnome? It’s free, and it takes a minute.', 'line'],
    'home.cta' => ['Front page', 'Bottom button', '🌱 Start growing', 'line'],

    // ---- How to play (guide.php)
    'guide.title' => ['How to play', 'Browser tab & Google title', 'How to play {site}: a cosy garden browser game', 'line'],
    'guide.desc' => ['How to play', 'Google description', 'A beginner’s guide to {site}, the free browser game about garden gnomes: planting and soil care, cooking, the fourteen regions, towns, games and the Almanac.', 'line'],
    'guide.intro' => ['How to play', 'Opening paragraph', '{site} is a free, cosy browser game about garden gnomes. You start with a small 4×4 plot, a satchel of seeds and an Almanac with empty pages. Grow crops in living soil, cook what you harvest, walk the roads of fourteen regions, make friends in town and fill your Almanac one page at a time.', 'text'],
    'guide.firstday' => ['How to play', '🌱 Your first day', "[list][*][b]Make your gnome.[/b] Pick a name and your hat and beard colours. Every gnome starts in {start_region}: choose one of its villages for your first garden. Each village sends you off with its own welcome basket.\n[*][b]Follow Wren.[/b] Wren the naturalist walks you through ten first steps: your garden, your Satchel, your Almanac, your gnome, the world map and a shop. Finish them all for a reward.\n[*][b]Plant your first seeds.[/b] Till a square, work in some compost, plant, then water. Plants only grow while they’re watered. Radishes are quick, so start there.\n[*][b]Mind your energy.[/b] Gardening, walking and gathering cost energy. It refills on its own ({energy_rate}). Out of energy? Eat a crop from your satchel: raw crops give 1 or 2 energy and many give a short stat boost, and a few rare ones raise a stat for good the first time you eat them. Home-cooked dishes give much more, and at your first Kitchen you can cook snacks, meals and feasts.\n[*][b]Explore.[/b] Follow the roads to the next village, wander off the path for finds and creatures, and see what the shops have in stock today.[/list]", 'text'],
    'guide.cooking' => ['How to play', '🍲 Cooking, crafting and trading', "Your garden levels up as you work it. At garden level 2 you can build a [b]Kitchen[/b] and start cooking meals from your harvests: they restore much more energy than raw food and give a stat boost for a while. Snacks (teas, jams, toasts) are quick and cost no energy to cook, meals cost 1, and feasts (Kitchen III) cost 2 and give the most. Leftover Food Scraps from eating raw food make compost: add them to a Compost Bin’s heap, or craft 12 of them into Plain Compost in your satchel. More buildings follow as the garden grows: a rain barrel, root cellar, tool shed (for crafting better tools), compost bin, beehive and greenhouse, all bought with Petals and upgradable later.\n\nCrafting turns wood, stone and wild finds into compost and mulch, yard decor, and the stone, timber and rope used to repair ruined landmarks. Tools wear down and can be mended. Sell to the shops, trade with other gnomes, or set up your own market stall.", 'text'],
    'guide.towns' => ['How to play', '🏘️ Towns and folk', 'Every shop is staffed around the clock. Shopkeepers keep their own hours and go home at night, and a few travellers wander from town to town. Chat and bring gifts once a day to make friends: friends give you a discount in their shops. Town squares have daily things to do, and the Job Board has new work every day.', 'text'],
    'guide.games' => ['How to play', '🎲 Games and contests', 'Seven daily games: Worm Hunting, Seed Memory, Snail Race, Seed Spitting, Mushroom Sweeper, Lost Letters and Guess the Weight. Contests too: a weekly Village Show, Garden of the Month, pumpkin carving in October, and a monthly Grand Harvest Fair where your best crops compete for ribbons.', 'text'],
    'guide.regions' => ['How to play', '🗺️ The regions (shown above the list of regions)', 'Each region has its own crops, flowers, climate, villages, landmarks and creatures, and its own chapter of Wren’s Journey. Crops grow {native}% faster in their native region, the climate helps some crops and slows others, and owning a garden in a region teaches you all its crops. Roads join the regions, and you can wander off the path into the wilds.', 'text'],
    'guide.faq' => ['How to play', '❓ Questions (each question starts with Q: and its answer with A:)', "Q: Is {site} free?\nA: Yes. It’s free to play, with no adverts and nothing to buy. You just make an account.\n\nQ: Do I need to download anything?\nA: No. It runs in your web browser on a phone, tablet or computer. Add it to your home screen if you like.\n\nQ: Is it like Neopets?\nA: It’s inspired by the classic browser games many of us grew up with, like Neopets: shops that restock, daily games, a world to explore and a book to fill in. Instead of a pet, you’re a garden gnome with a plot of land.\n\nQ: How much time does it take?\nA: As much or as little as you like. Plants only grow while watered, so you can check in for a few minutes when it suits you.\n\nQ: Can I play with friends?\nA: Yes. Visit each other’s gardens, send gifts, trade, set up a market stall, help in the community garden, meet in town squares and compete at the monthly Grand Harvest Fair.\n\nQ: Are the crops real?\nA: Yes. Hundreds of real-world crops and flowers from fourteen regions of the world, each with a gnomish name, plus mushrooms and wild finds to gather.\n\nQ: How old do I need to be?\nA: You must be 13 or older to play.", 'faq'],
    'guide.outro' => ['How to play', 'Last line', 'There are {pages} Almanac pages to discover. Happy growing!', 'text'],

    // ---- Join page
    'join.title' => ['Join page', 'Browser tab & Google title', 'Join {site}: claim your free garden plot', 'line'],
    'join.desc' => ['Join page', 'Google description', 'Make your garden gnome and claim a free 4×4 plot with starter seeds, tools and compost. Choose a village for your first garden and start growing in minutes, on your phone or computer.', 'line'],
];

/** The text for a key, with placeholders filled in (raw: escape or format_text it when printing). */
function stext(string $key): string
{
    static $stored = null, $vars = null;
    if ($stored === null) {
        try {
            $stored = array_column(q('SELECT skey, body FROM site_texts')->fetchAll(), 'body', 'skey');
        } catch (Throwable $e) {
            $stored = [];   // table not made yet (mid-upgrade)
        }
    }
    $s = $stored[$key] ?? (SITE_TEXTS[$key][2] ?? '');
    if (!str_contains($s, '{')) return $s;
    $vars ??= [
        '{site}' => (string)setting('site_name'),
        '{start_region}' => (string)(q_val('SELECT gnomish_name FROM regions WHERE id = ?', [function_exists('start_region_id') ? start_region_id() : 0]) ?: 'the first region'),
        '{energy_minutes}' => rtrim(rtrim(number_format(energy_tick()[1] / 60, 1), '0'), '.'),
        '{energy_rate}' => energy_rate_text(),   // v0.9.0
        '{native}' => (string)(int)setting('native_bonus_percent'),
        '{pages}' => number_format((int)q_val('SELECT COUNT(*) FROM encyclopedia_entries')),
        '{regions}' => (string)(int)q_val('SELECT COUNT(*) FROM regions'),
    ];
    return strtr($s, $vars);
}

/** Formatted (BBCode) version, safe to print. */
function stext_html(string $key): string
{
    return format_text(stext($key));
}

/** A feature box text: [title, formatted body]. */
function stext_box(string $key): array
{
    $parts = preg_split('/\R/', trim(stext($key)), 2);
    return [trim($parts[0] ?? ''), format_text(trim($parts[1] ?? ''))];
}

/** Q:/A: text as [[question, answer], …]. */
function stext_faq(string $key): array
{
    $out = [];
    foreach (preg_split('/\R\s*\R/', trim(stext($key))) as $block) {
        if (preg_match('/^\s*Q:\s*(.+?)\R\s*A:\s*(.+)$/s', $block, $m)) $out[] = [trim($m[1]), trim($m[2])];
    }
    return $out;
}
