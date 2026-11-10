<?php
declare(strict_types=1);

/**
 * v2.6.44: Almanac pages for the sleep-days game clock, the pal garden crew, Messages, the workshop badges,
 * walking the Trail back and Puzzle Pals. Added once per world, by title (a page that exists is left alone, so an
 * admin-edited page is never overwritten), and unlocked for everyone who already has the opening pages.
 * Sort numbers 60+ keep them after the older pages.
 */
const ALMANAC_2644_PAGES = [
    'Sleeping and the game day' => ['Getting started', 60,
        "Your gnome keeps a [b]personal game clock[/b]. A day runs from [b]06:00 to 22:00[/b]. Things you do spend game minutes: a gather takes 10, a long job takes much more, and the clock in the header and the cost lines show what an action will take.\n\n[b]Sleep[/b] moves you to the next morning and fills your energy. Sleep as often as you like: there is no limit. The garden, jars, pots, pal jobs, villagers and festivals all follow game time, so they move on when you sleep, not while the real clock ticks.\n\n[b]Naps[/b] skip about two game hours and give back some energy (about 40%). Energy also trickles back a little as real time passes, up to half of your full bar. Sleep gives the rest.\n\n[b]Tired:[/b] after 22:00 your gnome is tired. Nothing locks, but each game hour past 22:00 adds about 10% to what actions cost in energy.\n\n[b]Closing hours:[/b] shops and stops open and close. An action that would end after a place closes is refused. Some villagers are also away on some days, and come back later.\n\n[b]Your hovel:[/b] sleep and nap at home for free. Open the Hovel from your home page; after a sleep it opens on the [b]Today[/b] tab (see Garden crew and the Hovel)."],
    'Resting away from home' => ['Getting started', 61,
        "Away from home, in a town or village, you can still rest. What is on offer shows on the Hovel page for where you stand.\n\n🛏️ [b]Rent a room at the inn[/b]: about 110 Petals, a full sleep.\n🧹 [b]Help around the inn[/b]: pay with about four game hours of chores instead of Petals.\n🪑 [b]Sleep on a bench[/b]: free, but only about 30% of your energy comes back. A [b]nap on a bench[/b] is free too.\n🏡 [b]Stay with a villager[/b]: free and a full sleep, once a villager there counts you as a best friend.\n\n🏕️ [b]On the road[/b] on a Trail walk you need [b]camping gear[/b]: it is made at the workshop or bought in the shop. One gear gives one full night or about two naps. Before a night at camp you may pick one dish to leave cooking in a camp pot, ready when you wake.\n\nAll these numbers are set by the game keeper and may change."],
    'Garden crew and the Hovel' => ['Garden life', 62,
        "Your Puzzle Pals can tend the garden for you while you sleep. Open Garden > [b]Crew[/b]. Each garden has pal slots: [b]Water[/b], [b]Weed[/b], [b]Pests[/b], [b]Harvest[/b] and [b]Plant[/b]. Give a slot a pal for 1, 3 or 7 sleeps, or full time.\n\nPals work while you sleep, in the order pests, weeds, harvest, plant, water. A pal's harvest keeps no cut for the pal, counts for jobs, and earns the pal some Gardening XP.\n\n[b]Plant:[/b] a pal puts a seed into every empty, prepared bed. A bed gets the same seed it had last; if that has run out or is out of season, the pal uses seeds you ticked in the seed grid. Treasure seeds, saplings and cover crops are never planted for you. Mark a bed [b]hands off[/b] to leave it alone.\n\n[b]Tiredness:[/b] a pal on the same full-time job works at full strength for 7 nights, then slows (60% on night 14, 50% after) and skips some beds. A ! shows from night 14. Call the pal home for a rest day and give them another job to reset.\n\n[b]The Hovel tabs:[/b] [b]Today[/b] lists what needs you (ripe crops, tired pals, requests to hand in, a reply from the game keeper) and what happened overnight (weather, the crew report, pots and jars done, villager news). [b]Pals[/b] shows what your crew did last night. The last three reports are kept.\n\nHired helpers are retired: they no longer exist."],
    'Messages from the game keeper' => ['Getting started', 63,
        "Send feedback from Together and it lands in [b]Together > Messages[/b], the first tab. Each note is a conversation: the game keeper's replies show as bubbles and you can answer.\n\nA yellow [b]![/b] in a circle shows on the Together tile, the phone Menu / More button and the Messages tab while a reply waits. Opening the tab clears it. Together opens on Messages when a reply is waiting."],
    'The workshop and its badges' => ['Garden life', 64,
        "The workshop picture shows every crafting station. A green [b]![/b] sits on a station when there is something to do there: a recipe you can make now, or pantry jars that are done. Tap a station to open its card.\n\nA station with a badge also comes alive: flames and steam, glints on the jars, sparks, a sliding shuttle. Make x2, x5 and All make several at once."],
    'Walking the Trail both ways' => ['Places', 65,
        "A Trail route is drawn from its first end to its last. If you start at the [b]far end[/b], you walk the same stretches in the opposite order and enter each at its far end, so the way on is always where that stretch ends. Stretch numbers on screen still count 1, 2, 3 as you walk.\n\nThings you pick up on a stretch stay gone for a while after you take them (about five and a half game days), whichever way you walk. Fights and bosses stay on their tiles, so on the way back from a delve or lair the boss stretch comes first."],
    'Puzzle Pals' => ['Garden life', 66,
        "Puzzle Pals are small friends you meet by solving the puzzle games. A pal waiting at the place where you stand shows among the villagers on the Here page: tap it to say hello.\n\n[b]Take along:[/b] two pals can travel with you at first (the game keeper can raise this). They stand beside your gnome on Trail maps and behind you in a fight, where they can act: some strike or sap a foe, patch you up, or shield you.\n\n[b]Pal Jobs:[/b] send a free pal on a trip, a delve, a garden stay or a pot. Pal jobs run on game time, so they move when you sleep."],
];

/** Stale wording fixed in worlds that already hold the old pages: title => [[old text, new text], ...]. A page that no longer holds the old text is left alone. */
const ALMANAC_2644_FIXES = [
    'Hired help' => [["Going adventuring? A garden with a [b]Tool Shed[/b] can give a helper somewhere to stay.\n\nHire one on the garden page for 1, 3 or 7 days, paid up front. They visit every few hours and do the jobs they know: 💧 watering, 🌿 weeding no-till beds, 🧺 harvesting.\n\nHelpers keep a share of what they harvest as their pay, and you learn less from a harvest you didn’t pick yourself, so you get less XP. Send a helper home early and you get back the whole days you didn’t use.", "Hired helpers have retired. Your Puzzle Pals tend the garden now, while you sleep: see [b]Garden crew and the Hovel[/b]."]],
    'Pests & companions' => [["\n- A hired helper who weeds will pick pests off as well.", ""]],
    'Pantry' => [["[b]Real days:[/b] the timers run in real time, jam 1 day, chutney 2, pickles 3, kimchi 5, sauerkraut 7 and cordials 14, even while you are away.", "[b]Sleeps:[/b] the timers count your sleeps (game days): jam 1, chutney 2, pickles 3, kimchi 5, sauerkraut 7 and cordials 14."]],
    'Pots' => [["snacks about 3 minutes, meals 15, feasts 45", "snacks about 3 game minutes, meals 15, feasts 45"]],
    'Energy & food' => [["[b]Snacks[/b] (teas, jams, toasts, salads) cook in minutes and cost no energy.", "[b]Snacks[/b] (teas, toasts, salads) cook in minutes and cost no energy. [b]Jam[/b] is a snack that costs 1 energy."], ["It comes back when you sleep (a nap gives some back)", "It comes back when you sleep (a nap gives some back; see [b]Sleeping and the game day[/b] and [b]Resting away from home[/b])"]],
    'Dried flowers' => [["each takes a real day, even while you are away", "each takes one sleep"]],
    'Town squares' => [["The Hollow keeps its own clock, shown at the top of the town page.", "Your gnome’s game clock is shown at the top of the town page, and places close by it."]],
    'Seasons & weather' => [["each last a set number of real days, then the next one begins, round and round. Every gnome sees the same season and the same weather.", "each last a set number of game days (14 to start with), then the next one begins, round and round. Seasons and weather follow your own game days, so they move on when you sleep."], [" Look out for the changes: seasons and weather will matter more and more as the Hollow wakes up.", ""]],
    'Seasons in the garden' => [["Each season in the Hollow lasts a few real days (see the Seasons & weather page)", "Each season lasts a set number of game days, so it moves on when you sleep (see the Seasons & weather page)"]],
    'The florists' => [["it costs 3 energy and a real half hour", "it costs 3 energy and half an hour of game time"]],
    'The Job Board' => [["A new one after each daily reset.", "A new one after each sleep."]],
];

/** Fixes to generated text, applied to every page (old text => new text), once per world. */
const ALMANAC_2644_GLOBAL = [
    'butterflys' => 'butterflies',
    'A island village' => 'An island village',
    "\n[b]Can drop:[/b] ." => '',
    'birds that eat slugs' => 'birds that eat caterpillars',
    '(the birds eat the slugs)' => '(the birds eat the caterpillars)',
    'scattered with pistachios and almonds' => 'scattered with pistachios',
];

function ensure_almanac_pages_2644(): void
{
    if (setting('almanac2644') !== '1') ensure_almanac_new_pages_2644();
    if (setting('almanac2644fix') !== '2') {
        foreach (ALMANAC_2644_FIXES as $title => $pairs) {
            $row = q_one("SELECT id, body FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title]);
            if (!$row) continue;
            $body = (string)$row['body'];
            foreach ($pairs as [$old, $new]) $body = str_replace($old, $new, $body);
            if ($body === (string)$row['body']) continue;
            q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [$body, $row['id']]);
            q('UPDATE user_encyclopedia SET read_at = NULL WHERE entry_id = ?', [$row['id']]);   // shows as new again
        }
        set_setting('almanac2644fix', '2');
    }
    if (setting('almanac2644fix2') !== '1') {
        foreach (q('SELECT id, body FROM encyclopedia_entries')->fetchAll() as $row) {
            $body = (string)$row['body'];
            foreach (ALMANAC_2644_GLOBAL as $old => $new) $body = str_replace($old, $new, $body);
            $body = preg_replace('/\(([^()]+?) \(([^()]+)\)\)\./u', '($1, $2).', $body);   // "(North America (Canada, USA))." -> "(North America, Canada, USA)."
            if ($body !== (string)$row['body']) q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [$body, $row['id']]);
        }
        $pots = q_one("SELECT id, body FROM encyclopedia_entries WHERE chapter = 'General' AND title = 'Pots'");
        if ($pots && str_contains((string)$pots['body'], '2 with a Kitchen I, 3 with a Kitchen II, 4 with a Kitchen III')) q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [str_replace('2 with a Kitchen I, 3 with a Kitchen II, 4 with a Kitchen III', '3 with a Kitchen I, 4 with a Kitchen II, 5 with a Kitchen III', (string)$pots['body']), $pots['id']]);
        $rd = q_one("SELECT id, body FROM encyclopedia_entries WHERE chapter = 'General' AND title = 'Roads and the wilds'");
        if ($rd && str_contains((string)$rd['body'], '[b]medium[/b] for the first two steps')) q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [preg_replace('/gets harder: \[b\]medium\[\/b\] for the first two steps, \[b\]hard\[\/b\] for the next two, then \[b\]wild\[\/b\],\s*where bosses roam\./u', 'starts as easy as the road you left, then gets a little harder. [b]Wild country[/b], where bosses roam, starts at step 7; past step 9 lie the deep wilds, always a match for your own level.', (string)$rd['body']), $rd['id']]);
        set_setting('almanac2644fix2', '1');
    }
}

function ensure_almanac_new_pages_2644(): void
{
    foreach (ALMANAC_2644_PAGES as $title => [$category, $sort, $body]) {
        if (q_val("SELECT 1 FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title])) continue;
        try {
            $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => $category, 'title' => $title, 'body' => $body, 'unlock_key' => 'start', 'hint' => '', 'sort_order' => $sort]);
        } catch (PDOException $e) { continue; }   // made at the same moment
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
        }
    }
    set_setting('almanac2644', '1');
}
