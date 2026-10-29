<?php
declare(strict_types=1);

/**
 * v0.7.55: a short news post for players with each update, posted automatically the first time the new version
 * loads (one post per version the site skipped over, oldest first, so the newest is on top). Earlier posts are kept.
 * Add an entry here with every release: version => [title, body (BBCode)].
 */
const UPDATE_NEWS = [
    '0.7.51' => ['🌱 Update 0.7.51: little fixes from your feedback',
        "[list][*][b]Gnome level[/b]: \"Gardener level\" is now called Gnome level everywhere.\n"
        . "[*][b]Perennials[/b] show a 🔄 badge when you plant them and while they grow, so you know they come back after harvest.\n"
        . "[*][b]Arriving[/b] somewhere takes you straight to its town square or rest stop.\n"
        . "[*][b]Satchel[/b]: opening one item closes the others, and the pop-ups no longer slip off the edge on phones.\n"
        . "[*][b]Stats[/b]: Nimble, Grit, Lore and Charm give a little less per point (Luck is unchanged).[/list]"],
    '0.7.52' => ['🗺️ Update 0.7.52: the map shows much more',
        "[list][*]Every stop on every road is on the world map, plus the hidden places you've found.\n"
        . "[*]🎩 shows exactly where you are, even halfway down a road. 🏡 marks your gardens.\n"
        . "[*]👤 shows which towns the folk you know are in right now. See everyone you've met on the new [b]Folk you know[/b] page (My Gnome → Friends).\n"
        . "[*]Roads now name the town at each end, and the walking map marks where you're heading with 🎯.\n"
        . "[*]\"Where to next?\" shows a compass direction for each path.[/list]"],
    '0.7.53' => ['🔍 Update 0.7.53: zoom the world map',
        "Zoom in with ＋ and −, pinch on a phone, or use the mouse wheel, and drag to look around. The closer you get, the more you see: road stops, then place names and who's in each town.\n\n"
        . "Tap a place for its name, and a [b]Go →[/b] button if a path leads there from where you stand. 🎩 jumps back to you, 🌍 shows the whole world.\n\n"
        . "Places you find off the road now sit right beside the road stop their path leaves from."],
    '0.7.54' => ['☑️ Update 0.7.54: tend many squares at once',
        "[list][*][b]Select squares[/b] (on your garden): tap beds, or pick \"ready to plant\", \"thirsty\" and so on, then Plant, Work in, Mulch, Till, Water or Harvest them all at once. You can plant several kinds of seed in one go.\n"
        . "[*][b]New item picker[/b]: seeds, compost and mulch are chosen from a Satchel-style pop-up that shows what each one does.\n"
        . "[*][b]Faster soil amendments[/b]: nothing takes longer than 15 minutes now (teas 3, compost 10, rich loam and rock dust 15).\n"
        . "[*][b]Messages[/b] no longer pile up at the top of the page: find them under 🔔 Messages in the left-hand menu, or in the bar under the top on a phone.[/list]"],
    '0.7.55' => ['📰 Update 0.7.55: update news',
        "From now on, every update comes with a short post like this one, so you always know what's new. Older posts are kept under [b]All news[/b] on the home page."],
    '0.7.56' => ['🚪 Update 0.7.56: the Root Cellar',
        "A new garden building (garden level 3): the [b]Root Cellar[/b] keeps up to 5 perennials safe while you need their beds.\n\n"
        . "Open a perennial's square and choose [b]Store in root cellar[/b] (a few Petals). Later, open any empty, tilled square and choose "
        . "[b]Replant from cellar[/b]: it carries on just as grown as it was.\n\nAlso fixed: the More button on phones opens the menu again."],
    '0.7.57' => ['🛣️ Update 0.7.57: easier roads in places you know',
        "[list][*][b]Roads stay gentle[/b]: roads and paths in regions below level 25 now stay at that region's own level instead of growing with you, so getting around places you've outgrown is easy. Wandering off the road still gets harder as you level up, and the far regions (level 25 and up) still match your level.\n"
        . "[*][b]Easier-to-read choice buttons[/b] when planting and working in compost.\n"
        . "[*][b]Root Cellar[/b]: replanting now uses the same pop-up picker as seeds.[/list]"],
    '0.7.58' => ['🔔 Update 0.7.58: tidier pop-ups',
        "When lots happens at once, only 4 messages pop up on screen now. The rest are waiting for you under 🔔 Messages (in the left-hand menu, or the bar at the top on a phone)."],
    '0.7.59' => ['👜 Update 0.7.59: a smarter Satchel',
        "[list][*][b]Rarity letters[/b] on every item: C Common, U Uncommon, R Rare, L Legendary.\n"
        . "[*][b]More about each item[/b] when you tap it: how long seeds take and what they need, where crops are native, what tools do, what food does, where finds turn up, what you can make with it, and what it's worth.\n"
        . "[*]Eating or reading something keeps you on the same tab with the item still open.[/list]"],
    '0.7.60' => ['🛠️ Update 0.7.60: Almanac fixed',
        "Sorry! The Almanac, the Rules page and a few others could show an error page after the last updates. They're working again."],
    '0.7.61' => ['🧺 Update 0.7.61: shop baskets, a new Almanac, and lots of fixes',
        "[b]Shops[/b]\n[list][*][b]Buy[/b] and [b]Sell[/b] tabs, laid out like your Satchel. Tap an item, add +1, +2, +5, +10 or All to your basket, then buy or sell the lot at once.\n"
        . "[*]Guides you've already read are marked ✔, so you don't buy one twice.\n"
        . "[*]You now have to be in a shop's town to buy or sell there (Mossbottom's shops still work from anywhere).\n"
        . "[*][b]Rare and Legendary things sell for much more[/b]: Uncommon ×1.4, Rare ×2.2, Legendary ×4.5.[/list]\n"
        . "[b]Satchel[/b]\n[list][*]Fixed: the Satchel stopped part-way, so some tabs showed only one or two things. Everything shows now.\n"
        . "[*][b]Crafting[/b] is now a tab of the Satchel page.\n[*]A [b]Sort[/b] button on every tab: newest, oldest, A–Z, most owned, rarest…\n"
        . "[*]Drinks now count as tasted, and My Gnome lists every food you've tasted.[/list]\n"
        . "[b]Almanac[/b]\n[list][*]It opens on [b]Milestones[/b], now explained clearly with progress bars. Then [b]Guides[/b] (which you've read), then the chapters, with pages shown as tiles.\n"
        . "[*]A new [b]Glossary[/b] at the back explains the game's words.[/list]\n"
        . "[b]Garden[/b]\n[list][*][b]Perennials have a lifespan[/b] now: trees and nut trees 60 days, fruit 45, the rest 30. They give a little less as they age (80% at the end), then one last harvest. Tap one to see its age. Perennials already in your garden start counting from today.\n"
        . "[*][b]Dig up[/b] in select mode (it asks first).\n[*]Harvesting many squares gives one tidy summary.\n"
        . "[*]The garden page lists which crops get this region's native bonus.\n[*]\"Soil amendments\" are now called [b]soil improvers[/b].[/list]\n"
        . "[b]World[/b]\n[list][*]Arrive always takes you to the town square or rest stop (it sometimes showed an error).\n"
        . "[*]The World map sits at the top of \"Where you are\"; [b]Fast travel[/b] has its own tab; Markets is now [b]Shops[/b].\n"
        . "[*]Exploring off the path: the latest thing that happened shows right under the map. Find a hidden place and you can [b]visit it straight away[/b], then go back to exploring or to the road. You only find places near where you left the road.\n"
        . "[*]Fights: you and the creature side by side in one box, sized for phones.[/list]\n"
        . "[b]Town & folk[/b]\n[list][*]A [b]Folk about[/b] tab on the town square shows who's out and where.\n"
        . "[*]Folk pages have tabs: About, Likes & dislikes, and Standing.\n"
        . "[*][b]Feed the birds[/b] lets you choose which seeds; a picnic lets you choose the food.\n"
        . "[*]Fixed: the festival stall said you'd already had your treat.[/list]"],
    '2.0.17' => ['🛒 More picture shops',
        "The Curio Cabinet, the Dye Pot, festival stalls, haven pantries and village stalls now show goods as picture tiles. Tap one to see it and buy."],
    '2.0.19' => ['🥾 Treks are open!',
        "A new adventure for gnomes level 15 and up: [b]Treks[/b], under Out & about.\n\n"
        . "Lead a party down the cracks under the Hollow. Free trailmates, fight the blight, rest at camps and bring home Petals. Two chapters are ready: [b]The Wilting Rows[/b] and [b]The Weeping Clay[/b].\n\n"
        . "[list][*]Starting costs 10 energy. Fights cost none.\n[*]Your progress saves at every step, on any device.\n[*]Auto lets the party fight for you.[/list]"],
    '2.0.20' => ['🥾 Treks: knacks and a whole map',
        "[list][*][b]Knacks[/b]: every two trek levels each trailmate (and you) earns a knack slot, small then bigger. Each knack trades one thing for another. Pick them on the Party tab; change them at camp.\n[*][b]Whole map[/b]: a small fold under the map shows everywhere you have been.\n[*][b]Camps[/b] now heal everyone fully and clear fatigue: camp tiles, Camp Kits, old campsites and rest spots.\n[*]Trailmates grow fonder of you as you fight together.\n[*]The map feed keeps your last lines after a quiet step.[/list]"],
    '2.0.23' => ['🎨 New hand-drawn icons',
        "The little pictures around the game (menus, buttons, items, messages) are now hand-drawn icons instead of emoji, so everything looks the same on every phone. What you type yourself, like names and notes, stays as you wrote it."],
    '2.0.32' => ['🧵 A new stitched look',
        "The whole Hollow has a fresh coat of felt: new pixel pictures everywhere, and the pages, buttons and menus now look hand-stitched to match. Light and dark both got the new look (switch in the menu)."],
    '2.0.35' => ['🌱 Garden beds fixed',
        "Garden bed pictures were showing as odd text instead of the little bed icons. They look right again."],
    '2.0.36' => ['🧙 Your gnome looks right on phones',
        "On phones the Today page showed a plain white-hatted gnome. It now wears your own hat and beard colours. Trek foes also have new pictures."],
];

/** Posts the news for every version after $from up to this one (skips any already posted). */
function post_update_news(string $from): void
{
    $todo = [    '0.7.62' => ['📱 Update 0.7.62: gardens fit your phone',
        "[list][*][b]Your garden fits a phone screen[/b] now, however big your yard grows: the squares shrink to fit instead of making you scroll sideways.\n"
        . "[*][b]Gnome profiles have tabs[/b]: About (level, calling, foods tasted, plants mastered, regions visited and more), Gardens, and Awards (ribbons, Garden of the Month, milestones).[/list]"],
    '0.7.63' => ['📦 Update 0.7.63: sheet mulch many squares at once',
        "In select mode on your garden, there's a new [b]📦 Sheet mulch…[/b] button: pick your squares, choose a mulch, and each square gets a cardboard sheet and mulch in one go. It stops if you run out of cardboard."],
    '0.7.64' => ['⚖️ Update 0.7.64: a fairer economy and tougher far lands',
        "We checked how fast Petals and XP come in, and evened things out:\n[list][*][b]Selling prices[/b]: Uncommon things fetch ×1.3, Rare ×1.8 and Legendary ×2.5 (last update's ×4.5 was too generous, because Legendary fruit trees regrow every couple of hours).\n"
        . "[*][b]Perennials[/b]: the first harvest is full; after that each regrowth gives 75% of the crop and 60% of the XP. Still the easy, low-energy choice, just no longer better at everything.\n"
        . "[*][b]Gnome levels[/b] past 10 need a little more XP each time, so there's more to look forward to.\n"
        . "[*][b]The far regions[/b] (level 23 and up) now have creatures as strong as the land, instead of the odd level-1 aphid.\n"
        . "[*][b]Level 14–16 creatures[/b] (Grass Snake, Grey Heron, Mischief Monkey, Red Fox, Raccoon) are a gentler step up from level 13.[/list]"],
    '0.7.65' => ['🧭 Update 0.7.65: Wren’s Journey, and plant anything',
        "[b]Wren’s Journey[/b] (Almanac → 🧭 Journey): Wren is finishing her teacher Tansy’s field guide to the Hollow, and every region has a chapter. It starts the first time you reach the region:\n"
        . "[list][*]Get to know the place: grow its crops, befriend a local, find a hidden spot.\n"
        . "[*]Then help build its project, stage by stage: a sugar shack in the Maplewold, a granary in Maizehollow, a footbridge in Mistmoor, a lighthouse on the Sunsprinkle Isles.\n"
        . "[*]Finish a chapter for Petals, XP, a gift, the region’s [b]gardening guide[/b] (studied at once) and a lasting bonus there. More regions are coming in the next update.[/list]\n"
        . "[b]Plant anything[/b]: every seed can go in the ground now. Crops from a region you haven’t studied are marked 📕 [b]unstudied[/b]: they grow 25% slower and give 40% less, until you study the region (its guide or its Journey chapter) or master the crop by growing it.\n\n"
        . "[b]Gardening guides[/b] now cost about 6,000 Petals in shops. The Journey gives them for free.\n\n"
        . "Your progress, the next steps and a [b]Journey[/b] card are on the Today page too."],
    '0.7.66' => ['📜 Update 0.7.66: town quests, and the Sugar Shack really is broken',
        "[list][*]A new [b]📜 Quests[/b] tab on every town square: this region's Journey chapter (hand in project stages and finish it right there) and the townsfolk's favours, all in one place.\n"
        . "[*]Places in a Journey story now stay closed until you fix them. The Maplewold's [b]Sugar Shack[/b] (in the square and off the road) is closed for repairs until you finish its chapter, then it opens again just for you.[/list]"],
    '0.7.67' => ['🪸 Update 0.7.67: the whole Journey, from the Maplewold to the reef',
        "[b]Wren’s Journey now covers all 14 regions[/b], ending in the Coralscatter, where the reef sings and Tansy’s story is finally told. Each chapter has its own local problem, project and lasting bonus:\n"
        . "[list][*]🌬️ Olivewhistle Shore's hill windmill · 🛶 the Rainroot canoe jetty · 🛖 Birchbramble's drying barn · 💧 the Dunewhisper oasis waterwheel · 🎏 Blossomreach's red bridge\n"
        . "[*]⛰️ Spicepeak's tea terraces · 🛶 the Monsoon Tangle stilt boathouse · 🌳 the Greatcanopy storyteller's platform · 🐘 the Thornacre waterhole pump · 🪸 the Coralscatter reef garden[/list]\n"
        . "Every project is a real place in that region's town square. It stays [b]closed for repairs[/b] until you finish the chapter, then opens with something new to do. "
        . "(A few old favourites are closed too, because the story says they're broken: the River Landing, the Oasis Well, the Koi Pond, the Storyteller's Tree and the Waterhole Lookout.)\n\n"
        . "New titles along the way: Pathfinder, Wren's Companion, Hollow Ranger, and at the very end, [b]Keeper of the Hollow[/b], with a gift for your yard."],
    '0.7.68' => ['✋ Update 0.7.68: turn in quests from anywhere',
        "[list][*]The [b]📜 Quests[/b] tab on any town square now shows every Journey chapter you're on, not just that town's, with Hand in and Finish buttons for each.\n"
        . "[*]Your Almanac's [b]Journey[/b] page and the Today page say when something is [b]✋ ready to turn in[/b].[/list]"],
    '0.7.69' => ['👥 Update 0.7.69: everyone you’ve met, in one place',
        "[list][*][b]Folk you know[/b] is in the main menu now. It lists everyone you’ve met (not just friends), grouped from Best friend down to Stranger, with where they are right now, a search box, a region filter and “here now”.\n"
        . "[*]You meet folk by visiting their shop while they’re at the counter, finding them somewhere in town, or chatting and giving gifts.\n"
        . "[*]A new [b]👥 Folk[/b] chapter in your Almanac has a page for each person you’ve met. It fills in as you get to know them: tastes, birthday, where they work.\n"
        . "[*]The menu now has [b]My Almanac[/b] right after My Garden.[/list]"],
    '0.7.70' => ['🧱 Update 0.7.70: clearer Journey steps',
        "Each Journey chapter now shows exactly what to do next:\n[list][*]Every task has a 💡 tip on how to do it.\n"
        . "[*]Every project stage lists what it needs and what you already have (✔ / ✖), so you can gather ahead.\n"
        . "[*]If a stage can’t be handed in yet, it says why: finish the tasks above first, then hand stages in one at a time with the ✋ Hand in button.[/list]"],
    '0.7.71' => ['📌 Update 0.7.71: favours first',
        "On a town square’s 📜 Quests tab, the townsfolk’s favours now come first, above Wren’s Journey."],
    '0.7.73' => ['🏡 Update 0.7.73: visit the townsfolk at home',
        "[list][*]The town square’s [b]👥 Folk[/b] tab now has two parts: [b]Out and about[/b], and [b]🏡 At home[/b]. Folk who are home have a 🚪 [b]Knock[/b] button: knock to visit, chat and give a gift, even if you’ve never met them.\n"
        . "[*]Folk who are out show where they are and when they’re usually home.\n"
        . "[*]When folk have nothing on, they’re at home now, not “nowhere to be found”. [b]Here now[/b] on Folk you know counts people at home too.\n"
        . "[*]Each townsfolk page has a [b]fondness bar[/b] under their picture, with 💬 Chat and 🎁 Give a gift side by side.\n"
        . "[*]Gifts use a Satchel-style picker: tap an item, then Give it. Tastes you’ve found are marked (💛 favourite, 👍 liked, 👎 not keen), and you can sort by what they’ll like.\n"
        . "[*]Fixed: walking into a place could mark the wrong folk as met.[/list]"],
    '0.7.72' => ['📖 Update 0.7.72: a tidier, smarter Almanac',
        "[list][*]A new [b]📖 Contents[/b] front page: search everything you’ve found, see your ✨ new pages, your Journey chapter and next milestone, and how full each part of the book is.\n"
        . "[*]Fifteen tabs became seven: Contents, Journey, Growing, World, Wild, Folk & Recipes, and How to play. Each has its chapters as small buttons.\n"
        . "[*]Pages you haven’t read are marked ✨, and big chapters can be filtered by type and by found / not found / new.\n"
        . "[*]Crop pages now have [b]📝 Your notes[/b]: studied or not, knowledge and mastery, rarity and price, where to buy seeds, and perennial lifespan. Villages, landmarks and regions have notes too.\n"
        . "[*]Crop pages have a live [b]🌱 Growing[/b] box (grow time, water, soil, what it feeds on, harvest and XP, annual or perennial), so the numbers are always right.\n"
        . "[*]Creature, find and recipe pages have notes too: danger for you and what it drops (✔ the ones you have), where and with what tool to gather, and what a recipe needs with a ✔/✖ for what you’ve got and a “Make it” link. Landmarks say how dangerous they are and if they’re closed for repairs.\n"
        . "[*]Pages you haven’t found give better hints (where a crop is native and where its seeds are sold, where a creature roams).\n"
        . "[*]The Contents page shows what you found recently and the region medals you’re nearly there on. Glossary words on a page link to the Glossary.\n"
        . "[*]On phones the section tabs are one row you can swipe, an open page has a ☰ Contents button, and turning pages stays inside the filter you chose.\n"
        . "[*]New How-to-play pages (Wren’s Journey, Perennials & lifespans, Selling & rarity, Folk & friendship, Exploring & fighting), and the older ones brought up to date.[/list]"],
    '0.7.74' => ['🌿 Update 0.7.74: gentler exploring',
        "[list][*][b]Wandering off the road[/b] now starts as easy as the road you left and gets harder one step at a time.\n"
        . "[*]Hidden villages and landmarks can turn up from your first step.\n"
        . "[*]The deeper you go the better the rewards, with a bonus of XP and Petals when you come home from a long trip.\n"
        . "[*]A warning comes before the dangerous part, and the map key shows each band of steps.\n"
        . "[*]Wild country, with bosses, starts at step 7.\n"
        . "[*]Creatures in the highest regions are a bit gentler. Bosses and the wild still bite.[/list]"],
    '0.7.75' => ['🌑 Update 0.7.75: the deep wilds',
        "[list][*][b]The deep wilds[/b] lie past step 9 of exploring. They’re always a match for your own level, with full rewards and bosses.\n"
        . "[*]Areas you’ve outgrown give less XP and fewer Petals, the further above them you are. Items are the same, and the journal says when it happens.\n"
        . "[*]The map key shows the new deep wilds ring.[/list]"],
    '0.7.76' => ['🗺️ Update 0.7.76: tidier fights on phones',
        "[list][*]While you fight off the path on a phone, the ring map now shrinks to fit instead of being cut off at the bottom.[/list]"],
    '0.7.77' => ['🔨 Update 0.7.77: repair the ruins',
        "[list][*]Ruined havens, wonders and delves can be repaired by anyone who finds them, from gnome level 3, in any region. No Job Board slot needed.\n"
        . "[*]Take a repair on at the place itself. You can have up to three going at once.\n"
        . "[*]Four stages, each one pays Petals and XP.\n"
        . "[*]The first gnome to finish restores the place for everyone.\n"
        . "[*]See and hand in your repairs at the top of the Job Board (or a town square’s Quests tab).\n"
        . "[*]The monthly rebuild job is retired. Any you’ve started still works.[/list]"],
    '0.7.78' => ['🏚️ Update 0.7.78: ruins on the map',
        "[list][*]Ruined havens, wonders and delves you’ve found now show a 🏚️ on the world map (a 🔨 once you’re repairing them), and in each region’s list of places.\n"
        . "[*]Each step off the path now says in the journal when it used energy (−1⚡), so you can tell when your walking staff saved you one.[/list]"],
    '0.7.79' => ['🔍 Update 0.7.79: a smarter Almanac search',
        "[list][*]Searching the Almanac now also lists matching pages you haven’t found yet, with a 💡 tip on how to get them (for example, where a find is gathered and which tool it needs).[/list]"],
    '0.7.80' => ['⛏️ Update 0.7.80: gather where you like',
        "[list][*]A new 🧺 [b]Gather here[/b] at any road stop or step off the path: pick a tool you carry, 1 energy a try, and it always turns something up if your tool is good enough.\n"
        . "[*][b]What’s here[/b] shows every find in that land and the tool it needs.\n"
        . "[*]The World page and each region show which land is where, by steps out (for example, steps 3–4: mountain).\n"
        . "[*]Almanac tips now say exactly where to look.[/list]"],
    '0.7.81' => ['🎣 Update 0.7.81: fishing and logging',
        "[list][*]Two new gathering tools at Twigg’s: an axe for logging and a fishing rod, three tiers each.\n"
        . "[*]8 kinds of wood and 10 fish across the world’s lands, found on adventures or with the 🧺 Gather here box.\n"
        . "[*]Logs make Timber Planks, handy for repairs.\n"
        . "[*]5 new fish dishes to cook.\n"
        . "[*]Rare logs and fish count as fine finds for repairs.[/list]"],
    '0.7.82' => ['🔧 Update 0.7.82: smoother updates',
        "[list][*]Behind the scenes: game updates are now smaller and quicker to install. Nothing changes in play.[/list]"],
    '0.7.83' => ['🛒 Update 0.7.83: tidier shops',
        "[list][*]Shop shelves are grouped by type, with chips at the top (Seeds, Tools, Food, Soil and more) to show just one kind. The Sell tab has them too.\n"
        . "[*]Switching chips never empties your basket.[/list]"],
    '0.7.84' => ['⛰️ Update 0.7.84: more lands near the roads',
        "[list][*]Two steps off the road, every road stop now has its own neighbouring land (mountain, wetland, forest and more), so you no longer have to walk deep into the wilds for different finds.\n"
        . "[*]The Maplewold now has mountains and wetland near some of its road stops.\n"
        . "[*]The World page shows the land 2 steps out from where you stand, each region lists its stops’ lands, and Fast travel shows every region’s lands as icons.\n"
        . "[*]Almanac tips name the nearest road stops for each find.[/list]"],
    '0.7.85' => ['🛠️ Update 0.7.85: a big round of fixes',
        "[list][*][b]Repairs:[/b] giving up a repair now keeps your progress. Take it on again any time and carry on from the same stage.\n"
        . "[*][b]Job Board:[/b] giving up a job and taking it again carries on where you were. Taking a job always takes the one you tapped, even on an old page. You can hold one tending job at a time.\n"
        . "[*][b]Garden:[/b] “needs tilling” no longer picks your no-till beds, and tilling several squares asks first.\n"
        . "[*][b]Community garden:[/b] fixed beds that could come back ripe or lose a fresh planting when several gnomes were busy at once. Tending checks the bed before using energy.\n"
        . "[*][b]Wonders, delves and lairs:[/b] the walks there were far too dangerous in later regions; they now match the places themselves.\n"
        . "[*]Guides you’ve read can’t be bought again by mistake. No fast travel during a community garden shift.\n"
        . "[*]Resting at a haven or eating with full energy no longer wastes your rest or food.\n"
        . "[*]Gather here only offers tools that can find something there, and says when yours needs to be better.\n"
        . "[*]Folk chats and gifts, saplings and random events now reset at midnight Hollow time, like everything in town.\n"
        . "[*]Each townsperson’s favourite gift stays the same from now on.\n"
        . "[*]The word filter no longer blocks ordinary sentences.\n"
        . "[*]Gnomes in a time-out don’t show up in stalls, gardens, contests or town lists.\n"
        . "[*]Wren’s tour shows the real radish growing time, and its shop step goes straight to Twigg’s.[/list]"],
    '0.7.86' => ['🔧 Update 0.7.86: tools that wear, and fairer energy',
        "[list][*][b]Tools wear out and break.[/b] Gathering tools (knife, pick, net, bucket, axe, rod), walking staffs and lanterns wear a little with each use: about 60 uses for a Worn tool, 150 Sturdy, 300 Fine and 600 Masterwork. Better garden tools wear by the days you use them (45, 90 or 180 days). Worn garden tools never wear, so you can always garden.\n"
        . "[*]Every tool shows how many uses or days it has left, and warns you when it’s wearing thin. A broken tool becomes a “Broken …” item you can [b]mend[/b] in your Satchel for a small price, and a Tool Shed mends one tool free each day. Mend a worn tool before trading it.\n"
        . "[*][b]Only cooked food restores energy now.[/b] Raw crops, flowers, finds and shop-bought food still give their boosts, but no energy. Cook a meal to get going again.\n"
        . "[*]Harvesting costs ⚡1 for everyday crops, ⚡2 for uncommon crops and flowers, and ⚡3 for treasure crops. The garden shows the cost on each button.\n"
        . "[*]Repair stages pay a little less (about 310 Petals in the Maplewold).\n"
        . "[*]Treasure-crop saplings need their region studied first.[/list]"],
    '0.7.87' => ['🏚️ Update 0.7.87: ruins are closed until repaired',
        "[list][*]Most havens, wonders and delves are now open from the start. About one in three has fallen into ruin (never in the Maplewold).\n"
        . "[*]A place in ruins can’t be used until it’s repaired: no resting, no wonders, no delving. Take on the repair there, and once any gnome finishes it, it opens for everyone, with a few extra comforts.\n"
        . "[*]Ruins show 🏚️ on the world map, so you can see which places need help.[/list]"],
    '0.7.88' => ['🧰 Update 0.7.88: your own ruins, batch crafting and a toolbelt tab',
        "[list][*][b]Ruins are now yours to fix.[/b] A ruined haven, wonder or delve stays closed for you until [i]you[/i] make it safe: clear your path in, shore up your corner and earn the keeper’s trust. Every gnome gets the chance, so nobody can beat you to it.\n"
        . "[*]Each place has a plaque listing how many gnomes have made it safe, and the first one is named its [b]Founder[/b].\n"
        . "[*]Repair stages pay 200 Petals plus a little more in later regions. The place itself, with its extra comforts, is the real reward.\n"
        . "[*][b]Batch crafting:[/b] every recipe you can make has ×1, ×2, ×5 and “All” buttons. “All” shows how many your ingredients and energy allow.\n"
        . "[*][b]A new 🧰 Toolbelt tab[/b] in your Satchel, next to Crafting: your best tool for every job, uses left, mending and what to upgrade next.[/list]"],
    '0.7.89' => ['🏅 Update 0.7.89: medal and crate rewards',
        "[list][*]Region medals pay fewer Petals: 200 for Bronze, 500 for Silver and 1,500 for Gold. You still get the titles and the Rich Loam. Medals you already earned keep what they paid.\n"
        . "[*]Wren’s Journey supply crates now come for 12 weeks after you finish a chapter, instead of forever. The Journey page shows how long you have left.[/list]"],
    '0.7.90' => ['✨ Update 0.7.90: see your boosts',
        "[list][*][b]✨ Active effects[/b] on My Gnome lists every boost you have right now (meals, town outings, lucky moments, rainbows, shop sales) and how long each one lasts. The Today page shows them too.\n"
        . "[*]Stat cards on My Gnome now count every boost, not just meals.\n"
        . "[*]Wishing wells, the koi pond and pub quiz night cost ⚡1 each.\n"
        . "[*]Townsfolk favours pay a little less (still about twice what a shop pays), and hard Seed Memory pays a little less.\n"
        . "[*]The ring toss hint is vaguer: the peg is “close by” or “farther off”.[/list]"],
    '0.7.91' => ['🎯 Update 0.7.91: gathering mini-games',
        "[list][*]Every Gather button now has a [b]🎯 Play for a better find[/b] fold. A marker sweeps across a bar: tap when it’s over the zone.\n"
        . "[*]Hit the zone for [b]+1 find[/b]. Hit the green middle for +1, a better chance at rare finds, and [b]no wear on your tool[/b]. Miss and you still find something as usual.\n"
        . "[*]Each tool has its own game: swing the axe at the notch, strike the seam, hook the fish, swoop the net, scoop the tide pool, snip the stem.\n"
        . "[*]Better tools and more Nimble make the zone wider. It costs the same ⚡1, and the plain Gather button still works if you’re in a hurry.[/list]"],
    '0.7.92' => ['🎯 Update 0.7.92: a tidier Gather box',
        "[list][*]Gather here is much tidier: quick Gather buttons on one row, then a single 🎯 game. Tap a tool chip to choose what you’re gathering.\n"
        . "[*]Opening the game no longer opens it for every tool at once.[/list]"],
    '0.7.93' => ['🎯 Update 0.7.93: the game remembers your tool',
        "[list][*]After you play a 🎯 gathering game, it stays on the tool you chose instead of jumping back to the first one.[/list]"],
    '0.7.94' => ['🌱 Update 0.7.94: garden buttons in reach on phones',
        "[list][*]On phones, 💧 Water all and 🧺 Harvest all now sit in a slim bar just above the bottom menu, so you don’t have to scroll down past a big garden.\n"
        . "[*]In ☑️ Select mode, the Plant, Water, Harvest and other actions take that bar’s place (swipe it sideways to see them all).[/list]"],
    '0.7.95' => ['♻️ Update 0.7.95: a living compost heap and building upgrades',
        "[list][*][b]Your Compost Bin now has a heap.[/b] Every harvest, every plant you dig up and every weeding adds a scrap. Every 8 scraps make another Plain Compost, on top of the 1 a day. The bin shows how full the heap is, and Collect takes both.\n"
        . "[*][b]Building upgrades![/b] Open a building’s ⬆️ Upgrade fold. Upgrades cost Petals plus Dressed Stone, Timber Planks and Rope (made in Crafting → Building), and need a higher garden level.\n"
        . "[*]♻️ Compost Bin II: the heap needs only 6 scraps. III: every 4th heap compost comes out as Worm Castings.\n"
        . "[*]🐝 Beehive II: pollinator chance 35% and it holds 10 honey. III: 45%, and the bees make Beeswax too. Beeswax + Rope make [b]Beeswax Candles[/b] for your yard.\n"
        . "[*]The other buildings get their upgrades in the next update.[/list]"],
    '0.7.96' => ['⬆️ Update 0.7.96: every garden building can be upgraded',
        "[list][*]🛢️ [b]Rain Barrel[/b] II: waterings last 40% longer. III: 55%, and 💧 Water all is free once a day in that garden.\n"
        . "[*]🧰 [b]Tool Shed[/b] II: garden tools used there wear 15% slower. III: 30% slower, and 2 free mends a day.\n"
        . "[*]🏠 [b]Greenhouse[/b] II: crops grow 10% faster on top of native speed. III: perennials live 25% longer.\n"
        . "[*]🚪 [b]Root Cellar[/b] II: holds 10. III: holds 15, and storing is free.\n"
        . "[*]🍳 [b]Kitchen[/b] II: meal buffs last 25% longer. III: 50% longer, cooking gives 50% more XP, and you can cook six new [b]feasts[/b]: big dishes with strong 8-hour buffs (Harvest Home Pie, Forest Feast, Riverside Trout Bake, Orchard Crumble, Long Summer Table, Berry and Honey Cake).\n"
        . "[*]Open a building’s ⬆️ Upgrade fold in 🏠 Garden buildings to see the cost.[/list]"],
    '0.7.97' => ['🎯 Update 0.7.97: a Gather tab that helps you find things',
        "[list][*]The World page has a new [b]🧺 Gather[/b] tab, next to 📍 Where you are. Gather where you stand there.\n"
        . "[*][b]🎯 Seek:[/b] choose anything you can gather (even things you haven’t found yet) and you’ll be told the three nearest places to look: which road stop, and how many steps off the road. It only gives directions: you do the walking.\n"
        . "[*]While you seek, those places glow on the 🗺️ World map with a 🎯, and a chip at the top of the page tells you where to go. When you wander off the path, it tells you which step to reach, and when you’re there, the gathering game is already set to the right tool.\n"
        . "[*]🧭 Fast travel is now a fold right under the World map on the Where you are tab.[/list]"],
    '0.7.98' => ['🏁 Update 0.7.98: tap a stop to head there',
        "[list][*]Every stop on a road board is now tappable, and so are the town names at each end. You get a 🧭 [b]Head to[/b] card: how many stops away it is, and a button for the first walk.\n"
        . "[*]The game remembers where you’re heading. Each time you arrive somewhere, a 🏁 [b]Continue[/b] card offers the next leg. You still walk every leg yourself (and meet whatever’s on the road). Tap ✖ to forget it.\n"
        . "[*]Places on the 🗺️ World map that aren’t next to you, and 🎯 Seek results, have a 🧭 [b]How do I get there?[/b] button.\n"
        . "[*]The Today page shows where you’re heading and how many stops are left.[/list]"],
    '0.7.99' => ['🏠 Update 0.7.99: tappable buildings, more helpers',
        "[list][*]In your yard, buildings with something ready glow: [b]tap one to collect it[/b]. Tap any other building to jump to its card. A [b]📦 Collect all[/b] button joins Water all and Harvest all when something’s ready.\n"
        . "[*]Visiting a garden? [b]Tap its buildings[/b] for a peek: smell the kitchen (what did they cook last?), count the honey jars (not yours!), check the compost heap, meet the frog in the rain barrel…\n"
        . "[*][b]Turn a neighbour’s compost[/b] once a day per garden: +1 scrap for their heap, +3 XP for you, and they get a thank-you note.\n"
        . "[*]🧰 Tool Shed upgrades now house more hired helpers: [b]2 at level II, 3 at level III[/b]. Each helper visits on their own schedule, so harvests get done more often while you’re away.[/list]"],
    '0.8.0' => ['⚖️ Update 0.8.0: Guess the Weight, now with a jackpot',
        "[list][*]Guess the Giant Marrow is now [b]⚖️ Guess the Weight[/b]. Old Moss puts a different giant crop on the scales every day: a pumpkin one day, a coconut the next.\n"
        . "[*]Only an [b]exact[/b] guess wins, to the nearest 0.1 kg. The [b]jackpot starts at 5,000 Petals[/b] and grows by 1,000 every day nobody hits it, up to 25,000. Several exact guesses share it.\n"
        . "[*]If nobody is exact, the closest guess still gets 100 Petals.\n"
        . "[*]Guessing opens at gnome level 3, once you’ve been in the Hollow for 2 days.[/list]"],
    '0.8.1' => ['🍄 Update 0.8.1: three new games',
        "[list][*][b]🍄 Mushroom Sweeper:[/b] clear a 6 × 6 forest floor without stepping on a toadstool. The numbers tell you how many are hiding nearby, and your first pick is always safe. Petals for every safe square, and a bonus plus a forage find for a clean sweep. 3 games a day.\n"
        . "[*][b]🗺️ Lost Letters:[/b] a new riddle every day describes a town or village somewhere in the Hollow. Work out where, go there, and lift the stone to find the letter (80 Petals, or 40 if you peek at the postmark).\n"
        . "[*][b]🏆 Grand Harvest Fair:[/b] every harvest is now judged for quality: fertility, the crop’s own nutrient, soil life, soil grade, and being grown at home. Your best of each class this month waits on the Fair page. Enter it, and at the end of the month the top three in each class win ribbons and Petals. The very best crop of the fair wins Best in Show.[/list]"],
    '0.8.2' => ['🎲 Update 0.8.2: a tidier Games page',
        "[list][*]The Games page is now a neat grid of tiles: tap one to play. Each tile shows how many plays you have left today (and the Guess the Weight jackpot).\n"
        . "[*]Contests have their own [b]🏆 Contests[/b] tab: the Village Show, the Grand Harvest Fair, Garden of the Month and Pumpkin Carving.\n"
        . "[*]This week’s high scores are tucked into a fold at the bottom.[/list]"],
    '0.8.3' => ['☰ Update 0.8.3: a new menu',
        "[list][*]The menu is now grouped tiles with icons: You, Grow, Out & about, Together and Fun. On a phone it slides up from the bottom. Close it with ✕, a tap outside, or a swipe down.\n"
        . "[*]Little badges show what needs you: crops ready in your garden, games you can still play today, a better crop to enter at the Fair, and new stat points.\n"
        . "[*]The top of the menu shows your energy, Petals and where you’re heading.[/list]"],
    '0.8.4' => ['☰ Update 0.8.4: a slimmer menu',
        "[list][*]The menu tiles on phones are a little smaller, so more of the menu fits on screen at once.[/list]"],
    '0.8.5' => ['🔨 Update 0.8.5: a fresh look for Crafting',
        "[list][*]Recipes are now cards, two to a row: the dish, what it does, little ingredient chips (🍓 21/3, green when you have enough, red when you don’t), and ×1 / ×5 / All buttons right on the card.\n"
        . "[*]Chips at the top switch between ✅ Ready, 📋 Missing and ❔ To discover.\n"
        . "[*]Dishes, ingredients, tools and building parts have their own pictures now: 🥧 tarts and pies, 🍰 cakes, 🍞 bread, 🍵 tea, 🍓 strawberries, 🥕 carrots, 🪓 axes, 🪵 planks… in Crafting and in your Satchel.[/list]"],
    '0.8.6' => ['💬 Update 0.8.6: tell us what you think',
        "[list][*]New: [b]💬 Send feedback[/b] at the bottom of the menu. Found a bug, got stuck, or have an idea? Every note is read.\n"
        . "[*]Wren’s tour for new gnomes is friendlier: she tells you the next step as you go, radish seeds come first when you plant, and finishing the tour pops up your reward.\n"
        . "[*]A picnic on the green now gives the food’s own energy, plus 1 for the fresh air (it used to give the same for any food).\n"
        . "[*]Grand Harvest Fair: a class with fewer than 3 gnomes pays half prizes, and Best in Show needs at least 3 gnomes in the fair. Bring your friends!\n"
        . "[*]A new front page for visitors, so people you share the game with can see what it’s about.[/list]"],
    '0.8.7' => ['🌾 Update 0.8.7: soil care stars for tilled squares',
        "Tilled squares can now earn [b]soil care stars[/b], from ☆☆☆☆☆ Rough ground to ★★★★★ Garden loam.\n"
        . "[list][*]Work compost (or another soil improver) into a square, then harvest while its soil life is lively: that’s a point, one a day per square.\n"
        . "[*]Each star: crops there grow 2% faster, a little help at the Harvest Fair and Village Show, and tilling does less harm (15 soil life on rough ground, only 5 at five stars).\n"
        . "[*]Re-tilling never resets your stars, but a square left as wild ground loses one every 7 days.\n"
        . "[*]Turning a cared-for square into a no-till bed starts it a grade up for every 2 stars.\n"
        . "[*]Tap a tilled square to see its stars and what it needs. Every square starts at Rough ground. The Almanac has a new page: Soil care on tilled squares.[/list]"],
    '0.8.8' => ['📖 Update 0.8.8: How to play, and a little gnome icon',
        "[list][*]New: a [b]📖 How to play[/b] page (link at the bottom of every page). Share it with friends who are curious about the Hollow!\n"
        . "[*]The game has its own little gnome-hat icon in your browser tab, and you can add it to your phone’s home screen.\n"
        . "[*]Links to the game now show a picture and a short description when you share them in chats and on social sites.[/list]"],
    '0.8.9' => ['🌦️ Update 0.8.9: every region has a real climate',
        "The weather lines on each region now really happen in your gardens there. Your garden page shows its climate under 🌦️ Climate here.\n"
        . "[list][*][b]The Maplewold:[/b] cool-climate crops grow 10% faster, tropical crops 10% slower.\n"
        . "[*]Mistmoor and the Greatcanopy keep watering longer; Maizehollow, the Dunewhisper and the Monsoon Tangle dry out faster (mulch helps in the Dunewhisper).\n"
        . "[*]Fruit trees love Olivewhistle Shore, spices and herbs love Spicepeak, grains and coffee love Thornacre Savanna, and quick crops love Birchbramble Steppe.\n"
        . "[*]A greenhouse shelters crops from any slowdown. See every region’s climate on the world map or the How to play page.[/list]"],
    '0.9.0' => ['🧰 Update 0.9.0: little fixes',
        "[list][*]On phones, tapping something in your Satchel opens its details in a panel just above the bottom bar, so the Taste and Eat buttons are always in reach. Tap ✕ to close it.\n"
        . "[*]The bottom bar on phones keeps its size when you tap it.\n"
        . "[*]Crafting cards name every ingredient (🍓 Strawberry 2/3), not just its picture.\n"
        . "[*]Crops, seeds and flowers say where they come from: [b]Staple: The Maplewold[/b], [b]Treasure: Spicepeak[/b]…, in your Satchel and in shops.\n"
        . "[*]You can admire each gnome’s garden once (it used to be once a day).[/list]"],
    '0.9.1' => ['🎩 Update 0.9.1: callings grow with you',
        "Callings now have three tiers: [b]🎩 Apprentice[/b] (gnome level 5), [b]🎗️ Journeyman[/b] (level 15) and [b]⭐ Master[/b] (level 28). Each tier makes your calling stronger, and every Master gets something special: Wayfinders travel for free, Brewroots cook for free and keep two meal boosts, Bloomcallers get free Water alls, Thornblades never see a weed, Seedkeepers save a seed from every harvest, and Rootwardens’ mulch never wears out. See them all on My Gnome → Calling.\n"
        . "[list][*]Your calling is now yours for good. [b]Everyone gets one free change[/b], until gnome level 15.\n"
        . "[*]Levelling is slower past level 10, so the higher levels mean more. Nobody loses a level.\n"
        . "[*]Farming, exploring and fights are the main ways to earn XP. Wren’s Journey chapters, repairs and monthly jobs give less XP than before, and the daily games now give none.\n"
        . "[*]New: chatting with townsfolk gives 3 XP, and a gift gives 5 (10 if it’s their favourite), once a day each.[/list]"],
    '0.9.1.1' => ['🌱 Update 0.9.1a (0.9.1.1): small helpful changes',
        "[list][*][b]Shop-bought food gives a little energy[/b] (1, or 2 for a hearty dish). Home cooking still gives more.\n"
        . "[*][b]Meal boosts show in brackets[/b], like ⚡+4 (🛡️ Hardiness +3 for 6 h), and the time is worked out for you (your calling and kitchen included).\n"
        . "[*][b]Changing your calling now costs Petals[/b] (500, doubling each time) instead of one change.\n"
        . "[*][b]Select all of one crop[/b]: in the garden, tap a square with a crop in select mode, then press [b]Select all[/b] to pick every square with that same plant.\n"
        . "[*][b]Games give a little energy[/b]: worms, memory, seed spitting and the weight guess give +1 energy (+2 for a good game), up to 10 a day.\n"
        . "[*][b]Toolbelt tabs[/b]: the toolbelt is split into Garden tools, Gathering, Travel, Mend and Upgrades.\n"
        . "[*][b]Staple labels[/b] now show on the Trading Post too.\n"
        . "[*]Fixed: Brewroot masters could lose a meal boost if they ate twice very quickly.[/list]"],
    '0.9.2' => ['✨ Update 0.9.2: a cleaner, easier look',
        "The whole site has a new, simpler look, made for phones first.\n"
        . "[list][*]Bigger, clearer text and buttons that are easy to tap.\n"
        . "[*]A slim top bar with your energy and Petals always in view, and your other numbers in a row you can swipe.\n"
        . "[*]The ☰ menu works with a keyboard and screen readers, and has Log out at the bottom on phones.\n"
        . "[*]Better contrast everywhere, and a clear outline on whatever you have selected.\n"
        . "[*]Less clutter: flat cards, one style of tabs, no more wobbly 3D buttons.[/list]\n"
        . "Something look wrong on your screen? Use 💬 Send feedback in the menu."],
    '0.9.3.1' => ['🗺️ Update 0.9.3.1: colour, bigger maps and routes that walk themselves',
        "[list][*][b]Colour[/b]: a green top bar, and each part of the game has its own hue. Dark mode follows your phone's setting.\n"
        . "[*][b]Region maps[/b]: tap a region on the world map to open its own map with big, easy-to-tap places. Pinch or use ＋ − to zoom.\n"
        . "[*][b]Roads as lines[/b]: every road is now a line of big round stops. Tap any stop for directions.\n"
        . "[*][b]Routes[/b]: pick a place anywhere and see the whole way there. Tap [b]Set off[/b] once and your gnome keeps walking stop to stop (turn off [i]Keep walking[/i] or tick [i]Pause at towns[/i] if you'd rather).\n"
        . "[*][b]Toolbelt[/b]: much shorter on phones.[/list]"],
    '0.9.4' => ['🎩 Update 0.9.4: calling mentors, and cooking you can plan around',
        "[b]Calling mentors[/b]\n"
        . "[list][*]Each calling has a [b]mentor[/b] who lives in a town lodge: Burdock Deepdelve (Rootwarden, Birchbramble Steppe), Zinnia Fuzzbottom (Bloomcaller, Maizehollow), Captain Bracken Spurwing (Thornblade, Mistmoor), Sorrel Inkcap (Seedkeeper, Olivewhistle Shore), Tumble Waymarsh (Wayfinder, the Rainroot Reaches) and Juniper Kettleby (Brewroot, the Sunsprinkle Isles).\n"
        . "[*]🎗️ [b]Journeyman[/b] and ⭐ [b]Master[/b] now need your mentor's chapter as well as the gnome level: a set of tasks, then something to hand in. Each chapter pays Petals, XP, an item and a new title, and adds a page to Almanac → Callings.\n"
        . "[*][b]Veterans[/b]: if you were already a Journeyman or Master, you keep your calling but your tier II and III perks wait until you finish that calling's chapter with your mentor. Start with the town lodge, or My Gnome → Calling. Tasks that look at what you have already done (beds, regions, plants known) tick at once.[/list]\n"
        . "[b]Cooking and energy[/b]\n"
        . "[list][*]Food comes in three tiers: [b]snacks[/b], [b]meals[/b] and [b]feasts[/b]. Meals and feasts give much more energy.\n"
        . "[*][b]Pots with timers[/b]: put a dish on, go and do something else, collect it when it is ready. You get 2, 3 or 4 pots as your kitchen grows.\n"
        . "[*][b]Raw food[/b] gives 1 or 2 energy now, so a quick bite from the garden is worth eating.\n"
        . "[*][b]Food scraps and compost[/b]: eating raw food leaves scraps, and scraps turn into compost.\n"
        . "[*][b]Wren's tour[/b] no longer stops when you are low on energy.\n"
        . "[*][b]Brewroot III[/b] changed: pots finish in half the time, you get an extra pot, meals give 20% more energy, and you still keep two meal boosts at once. Cooking is no longer free.[/list]"],
    '0.9.5' => ['🌱 Update 0.9.5: more beds, kitchens that add up, and a tidier yard',
        "A garden update.\n\n"
        . "[list][*][b]Add 4 beds[/b]: one button in your garden adds four new beds, placed in a free spot in your yard (move them in the yard designer). The first set costs 200 Petals and 2 Timber Planks; each set after costs a bit more. Your garden level still sets the most beds a garden can hold, and every bed you already have stays.\n"
        . "[*][b]Kitchens add up[/b]: kitchens in your other gardens now help too. Meal boosts last longer and cooking gives a little more XP, and extra level 3 kitchens add pots.\n"
        . "[*][b]Fences, walls and hedges join up[/b] into corners, T-pieces and crosses by themselves. Tap 🔀 Shape to pick one yourself. New: the [b]Garden Gate[/b] at the Hedge & Hearth.\n"
        . "[*]Yard designer: a grid toggle, snap-to-beds, bigger buttons on phones, and ↶ Undo for your last saves.\n"
        . "[*]Your GPS route now shows in gold on the region map, with ✅ on the stops you've passed.\n"
        . "[*]New Almanac pages: Pots and Food Scraps.[/list]"],
    '0.9.6' => ['🖥️ Update 0.9.6: a proper desktop layout, calmer phone notices, better dark mode',
        "[list][*][b]Wide screens[/b] now get three columns: the menu on the left (groups fold away), your page in the middle, and a [b]Right now[/b] column with messages, your walk, pots, boosts and chores.\n"
        . "[*][b]Phones[/b]: at most two notices show at once, under the header, so they never cover your buttons. Good news fades after a few seconds; problems stay until you tap ✕. The rest wait in your messages.\n"
        . "[*][b]Dark mode[/b] is easier to read: buttons, badges and chips have better contrast.\n"
        . "[*]Landmarks now tell you when you're on the road instead of quietly sending you back.[/list]"],
    '0.9.7' => ['🌄 Update 0.9.7: roads that keep up with you, and lots to spend Petals on',
        "[list][*][b]Roads near home grow with you[/b]: creatures match your level, so fights there are worth it again. New gnomes have [b]Easy roads[/b] on (My Gnome), which keeps them gentle and boss-free.\n"
        . "[*][b]Quick walks[/b]: roads far below your level take half the time.\n"
        . "[*][b]More XP past level 10[/b]: harvesting, cooking, crafting and fighting give a little more each level.\n"
        . "[*][b]14 new creatures[/b] roam the far regions (level 24 and up).\n"
        . "[*][b]New things to buy[/b]: the [b]Curio Cabinet[/b] at the Hedge & Hearth (5 rare decorations each week), [b]building skins[/b] (Mossy, Painted, Lantern-lit), [b]The Dye Pot[/b] (hat and beard colours), carved [b]garden signposts[/b], and [b]8 regional feasts[/b] made with treasure crops.[/list]"],
    '0.9.8' => ['🫙 Update 0.9.8: the Pantry, and room for pictures',
        "[list][*][b]🫙 Pantry[/b]: add one to any Kitchen (600 Petals + 4 Timber Planks) and fill [b]5 jars[/b] with jam (1 day), chutney (2), pickles (3), kimchi (5), sauerkraut (7) or cordials (14). Jars keep working while you're away, and preserves never spoil.\n"
        . "[*]Preserves sell for more than their crops (more for longer ferments), every townsfolk likes them as a gift, and many give a long, gentle boost when eaten.\n"
        . "[*]More jars: +2 with a level III Kitchen, +1 for each Pantry in your other gardens.\n"
        . "[*]New [b]Preserves[/b] class at the Harvest Fair.\n"
        . "[*]Find them in Satchel → Crafting → Pantry, and in the Almanac.\n"
        . "[*]Behind the scenes: the game is ready for real item pictures. They'll appear as the art arrives.[/list]"],
    '0.9.9' => ['💐 Update 0.9.9: flower arranging and gathering games',
        "[list][*][b]💐 Flower arranging[/b] (Satchel → Crafting → Arrange): pick a glass jar, vase or wicker basket, place up to 9 cut stems and watch it come together. Colour, variety, rarity, a focal flower, balance and the season all count toward the score.\n"
        . "[*]Arrangements sell well, make lovely gifts, and can go in the new weekly [b]Arrangements show[/b] (prizes and ribbons).\n"
        . "[*][b]Drying rack[/b]: dry cut flowers in a day; dried flowers never fade and sell a little higher. [b]Seed packets[/b]: pack seeds from flowers you've mastered.\n"
        . "[*]Two florists: [b]Petalpin's Posies[/b] in Mossbottom and [b]Blossom & Bough[/b]. Volunteer for 30 minutes for XP, friendship and a bundle of stems.\n"
        . "[*]Every flower now has its own picture.\n"
        . "[*][b]Gathering games[/b]: each tool has its own short game: knife cuts, axe strikes, pick glints, rod tug, net swipes and a calm bucket moment. Play well for an extra find. Rather not? Press [b]Quick gather[/b].[/list]"],
    '2.0.1' => ['⏳ Live road timer',   // v2.0.1 (Treks balance, riddles, old campsites not announced: Treks still admin-only)
        "[list][*]When the next stop is [b]in sight[/b], the minutes count down live and [b]Arrive[/b] appears by itself.\n"
        . "[*]Clearer wording about where you go after a pause.[/list]"],
    '2.0.0.1' => ['🧩 Puzzles',
        "[list][*][b]Puzzles[/b] are new in Games: animated jigsaws, just for fun. No prizes, no daily limit.\n"
        . "[*]Pick a picture and a piece count. Drag pieces onto the outline; neighbours that fit join together.\n"
        . "[*]New picture: a 🌻 swaying sunflower with a busy bee.[/list]"],
    '1.9.8' => ['🛍️ Picture shops',
        "[list][*][b]Shops[/b] now show pictures, like your Satchel. Tap one to see it, pick how many, and buy or sell.\n"
        . "[*]Tap a glowing hive or bin in your garden to collect it and stay in your garden.[/list]"],
    '1.9.4' => ['🦔 Who’s on the road?',   // v1.9.4 (Treks II-b, cold rest change not announced)
        "[list][*][b]Villagers and travellers[/b] now turn up on the roads. Stop for a chat (it counts as your chat for the day) or wave and walk on.\n"
        . "[*][b]Choices on the road[/b]: little moments to decide, with new ones for the Maplewold, Mistmoor and Blossomreach.\n"
        . "[*]Every [b]wonder[/b] has its own story now, and its mood changes from day to day.\n"
        . "[*]More village descriptions, and button text is centred.[/list]"],
    '1.9.3' => ['🍃 The roads come alive',   // v1.9.3 road life
        "[list][*][b]Every step on the road[/b] now has a little scene, shaped by the land, the region, the time of day, the season and the weather.\n"
        . "[*]The road [b]stops repeating itself[/b]: you won’t meet the same creature, puzzle or find over and over.\n"
        . "[*]Fog, nightfall and heat only happen when the weather or the hour fits, and there are 8 new weather and season puzzles.\n"
        . "[*]Off-path choices and road buttons have the newer look.[/list]"],
    '1.9.2' => ['🏡 One Today page',   // v1.9.2 (Treks Chapter II-a is not announced)
        "[list][*][b]Today[/b] is one page now: no tabs. Your garden, journey, jobs, the rest stop and the Hollow are all in view.\n"
        . "[*]On desktop it fits on one screen, and the bar under the header is centred.[/list]"],
    '1.9.0' => ['🪟 Smoother screens',   // v1.9.0 (covers 1.8.2-1.9.0; Treks are not announced)
        "[list][*][b]Pop-ups[/b] (seed pickers, the chest, confirm boxes) are proper in-game windows: the back button and Esc close them.\n"
        . "[*][b]Slimmer top bar[/b] and less empty space, most of all on desktop.\n"
        . "[*][b]Road fights[/b] fit on one screen on desktop, and [b]Show all[/b] lets you scroll the whole fight.\n"
        . "[*]Gentle fade between pages, and messages no longer cover the Eat button.[/list]"],
    '1.8.1' => ['🧭 Tidier travel, simpler orders',   // v1.8.1
        "[list][*][b]Where to next?[/b] is tidier: smaller path cards and four equal buttons (Wander, Town square, Fast travel, Gather).\n"
        . "[*][b]Orders[/b]: townsfolk asking for crops or jam take any quality now.\n"
        . "[*][b]Mini-games[/b] pay fewer Petals.[/list]"],
    '1.7.5' => ['✋ Hand in from Tasks',   // v1.7.5
        "[list][*][b]Tasks → Quests[/b]: hand in Wren's Journey stages right there. The Tasks badge counts everything ready.\n"
        . "[*]Today's cards are centred and tidier on phones.\n"
        . "[*]Shops show one season tag per seed.[/list]"],
    '1.7.3' => ['🗂️ A tidier menu',   // v1.7.3
        "[list][*]New menu groups: [b]You[/b] (gnome, Almanac, Satchel, Crafting), [b]Grow[/b], [b]Out & about[/b] (now with Games), [b]Together[/b], and Account at the bottom.\n"
        . "[*]On a computer the menu is always open, two tiles across.\n"
        . "[*]New little menu icons.\n"
        . "[*][b]Almanac[/b]: the Contents list stays open when you open a page. Plants and Flowers can be filtered by region and kind (🌾 Staples, 💎 Treasures).[/list]"],
    '1.7.2' => ['🧭 Easier to find your way',   // v1.7.2
        "[list][*][b]📋 Tasks[/b]: Jobs, Quests, townsfolk Orders and your rest-stop Errands, all on one page with tabs.\n"
        . "[*][b]🌻 Together[/b]: the Community garden, the Hollow jar and Who's about are tabs on one page.\n"
        . "[*][b]🏆 Contests[/b]: Games → Contests shows every contest with its status and an Enter button.\n"
        . "[*]New names: [b]Gnome friends[/b] (players) and [b]Villagers[/b] (townsfolk you know).[/list]"],
    '1.7.0' => ['📖 Guestbooks and a tidier menu',   // v1.7.0
        "[list][*][b]Guestbook[/b]: garden stamps are now the guestbook, with 🌻 👏 🐝 ✨ added. One tap a day per garden. Your garden shows this week's and all-time signatures.\n"
        . "[*]One \"Visitors today\" message per garden instead of one per visitor.\n"
        . "[*]Garden → [b]🤝 Need help?[/b]: hire a villager, post a job, or let other gnomes water.\n"
        . "[*]Menu: no more double links. Jobs and quests share one tile.[/list]"],
    '1.6.9' => ['💧 Help other gnomes',   // v1.6.9
        "[list][*][b]💧 Water for them[/b]: visit any gnome's garden and water their thirsty squares, once a day each. Costs you 1 energy; you get a little XP and Petals.\n"
        . "[*][b]Reactions[/b]: tap 🌻 👏 🐝 ✨ on any garden you visit, once a day. Your own garden shows what visitors loved.\n"
        . "[*][b]Shops[/b]: tidier rows with the price on the right. Curio Cabinet and Dye Pot too.\n"
        . "[*]The world map is a third shorter on phones.[/list]"],
    '1.6.8' => ['✉️ Email reminders (only if you want them)',   // v1.6.8
        "[list][*][b]Confirm your email[/b]: check your inbox for a link. You can resend it from Account.\n"
        . "[*][b]Reminders are off unless you turn them on[/b]: Account → \"Email me when my harvest is ready or I have been away a while\". Every email has a one-tap unsubscribe.\n"
        . "[*]New gnomes: Wren's tour comes first, the other helpers wait their turn.\n"
        . "[*]Placeholder pictures lost their red outline.[/list]"],
    '1.6.6' => ['🗺️ Maps get their own tab',   // v1.6.6
        "[list][*]World → [b]🗺️ Map[/b] opens your region's map straight away, near you.\n"
        . "[*]The whole world map is folded underneath: tap [b]🌍 World map[/b].[/list]"],
    '1.6.5' => ['🌙 Dark mode by default',   // v1.6.5
        "[list][*]The Hollow is now dark by default, whatever your phone is set to.\n"
        . "[*]Switch with the 🌙 / ☀️ button: next to Today in the menu on phones, at the top on a computer. [b]Account[/b] also has \"match my phone\".\n"
        . "[*]Region maps: tap 🏷️ Names or zoom in to see every place name.[/list]"],
    '1.6.3' => ['🍄 Update 1.6: new maps, tidier pages, an easier first day',   // v1.6.3
        "[list][*][b]🍄 New maps[/b]: the world and every region are now a mycelium cross-section, deeper as the levels rise. Townsfolk, quest and gathering markers, with filters. Region maps open on the places near you; tap \"Show whole region\" for all of it.\n"
        . "[*][b]An easier first day[/b]: a slimmer tour, one pop-up at a time, a plain-words soil panel, bigger garden squares on phones and a tidier seed picker.\n"
        . "[*][b]Tidier pages[/b]: no more sideways scrolling, a slimmer top bar, and Show / Sort menus in the Satchel, with a new [b]✨ Untasted[/b] list.\n"
        . "[*][b]Clearer choices[/b]: fights, rest stops and the Job Board show each option's odds or reward on the right.\n"
        . "[*][b]🪱 Worm Farm[/b]: castings every 12 hours (was 24). Every animal card now shows its feeder and when the next gift is due.\n"
        . "[*][b]🏡 Adopt more stops[/b]: finish a stop's Hall to look after one more.\n"
        . "[*]Games give energy with no daily limit.[/list]"],
    '1.5.0' => ['🎣 Update 1.5: new gathering games and a Practice tab',
        "[list][*]Every gathering tool has a new little game: 🎣 [b]Spore Lure[/b] (a fish blinks its colours, pulse them back on your glowing line), 🔪 Stem Trace, 🪓 Log Split, ⛏️ Glint Strike, 🦋 Bug Swoop and 🪣 Drip Catch. Play well for an extra find, or press Quick gather as before.\n"
        . "[*]New 🎯 [b]Practice[/b] tab in Games: try all six any time, no tools or energy needed (no finds).\n"
        . "[*]Rest stops no longer stop you after 15 a day. After a very busy day (100) the villagers get tired and Petals and XP from stops are halved until tomorrow.[/list]"],
    '1.4.8' => ['🪰 New game: Pest Patrol, and every game got a makeover',
        "[list][*][b]🪰 Pest Patrol[/b] (Games): a plant grows onto the screen and pests creep onto its leaves. Flick them off, but go easy: three bruises and a leaf falls. 25 different plants. A Ladybird Lodge gives you a little more time, a perfect round may leave a Ladybird Charm, and if a butterfly drifts by, catch it with a bug net.\n"
        . "[*]New looks for Seed Memory, Mushroom Sweeper, Snail Race, Guess the Weight and Lost Letters, and every game page has a 📖 Rules tab. Every game now gives a little energy.\n"
        . "[*]Delve chests open with a little show of what you found.\n"
        . "[*]A tidier region map, smaller fight buttons, wonders laid out like the other choices, and the garden and rest stops have tabs.[/list]"],
    '1.4.0' => ['🦋 Update 1.4: butterflies, snails, new creatures, livelier games',
        "[list][*][b]🦋 Butterfly Bush[/b] (garden level 4): butterflies help flowers within 2 squares give an extra stem now and then, and leave Wing Scales for a lantern.\n"
        . "[*][b]🐌 Snail Jar[/b] (garden level 3): pick slugs by hand and you may rescue a snail. Snails eat scraps or lettuce and leave Snail Trail Glaze for a glazed pot.\n"
        . "[*][b]26 new creatures[/b] on the roads from level 12 to 28, and areas now match your level better (no more tiny beetles deep in the desert).\n"
        . "[*]🎒 [b]Snack[/b] in a fight: eat a home-cooked snack to heal (one per fight, two for Brewroots).\n"
        . "[*][b]Seed Spitting[/b] is now an aim-and-power game with wind: drag back like a slingshot. [b]Worm Hunting[/b]: worms wander, and deep finds take two taps. Mushroom Sweeper, Lost Letters and the Fair no longer reload the page.\n"
        . "[*]Soil crafts make more (compost, loam, castings, shell meal, worm tea, wood ash).\n"
        . "[*]The low-energy band is gone; the ⚡ chip turns red at 0. The Garden badge updates right after you act.[/list]"],
    '1.3.0' => ['⚔️ Update 1.3: clearer fights, tidier rest stops',
        "[list][*][b]Fights[/b] show your odds: how often you hit, how hard it hits back, and about how many rounds it takes.\n"
        . "[*]New [b]⏩ Fight on[/b] button: keeps attacking until the fight ends or you drop below half health.\n"
        . "[*]Later fights are shorter: creatures past level 8 have less health.\n"
        . "[*]Running away is easier, and quiet steps on a walk heal you a little.\n"
        . "[*][b]Rest stops[/b] have tabs: 🧭 Do, 👥 Folk and 🏡 Stop. Villagers offer 2 errands a day, and the activity cards are more compact.[/list]"],
    '1.2.3' => ['🧭 Update 1.2.3: tidier buttons on the road',
        "[list][*]Walk bar buttons (Deeper, Explore here, Back to the road…) are smaller.\n"
        . "[*]Problems on the path show each approach as one tidy row with its chance on the right.\n"
        . "[*]Visiting a garden? A small 🧬 line shows crosses you already know that could happen there.[/list]"],
    '1.2.2' => ['🔧 Update 1.2.2: fixes and fairer play',
        "[list][*]Select squares: a quick pick now lights up the matching button (Till, Plant, Water…). Picking every thirsty square and pressing Water uses your free daily watering (rain barrel III or Bloomcaller).\n"
        . "[*]The day now turns over at [b]midnight Hollow time[/b] everywhere, Job Board and games too.\n"
        . "[*]Changing your password signs you out on your other devices.\n"
        . "[*]Fixed: the spider's map now really shows you a hidden place, the Reef Garden gift, the mole swapping away rare seeds, delve icons and danger levels, the Wayfinder travel price, and shops you can't reach yet (now with a Walk there link).\n"
        . "[*]Gardens load a little faster.[/list]"],
    '1.2.0' => ['🐢 Update 1.2: new garden animals, mentors, a tidier Today',
        "[list][*][b]🐦 Quail Coop[/b] (level 5): quail turn Food Scraps into [b]Quail Eggs[/b].\n"
        . "[*][b]🐛 Silkworm Shelf[/b] (level 7): feed silkworms [b]Mulberry Leaves[/b] (from a mulberry harvest, or Twigg's Seed Emporium) and they leave empty cocoons. Spin them into Silk Thread, then Silk Bunting.\n"
        . "[*][b]🐢 Tortoise Run[/b] (level 8): a slow, happy tortoise eats leafy greens, sheds a [b]Tortoise Scute[/b] now and then, and makes your yard lovelier.\n"
        . "[*]New neighbours at the fence: [b]Clementine the goat[/b] trades Goat Milk for Food Scraps, and [b]Percy the pigeon[/b] swaps a few seeds for a seed from far away.\n"
        . "[*]9 new dishes with quail eggs, goat milk and goat cheese.\n"
        . "[*][b]🎓 Mentors[/b]: gnomes at level 20+ can tick \"Happy to mentor\" (Friends → Mentor). Gnomes under level 8 can ask one. The newcomer earns 10% more XP, the mentor gets a share, and both get a reward at graduation (level 8).\n"
        . "[*][b]Today[/b] is split into three tabs: Home, Out and Hollow.\n"
        . "[*]The energy warning now says \"Low energy\" at 1 or 2, and \"Out of energy\" only at 0.[/list]"],
    '1.1.0' => ['🧬 Update 1.1: crop breeding, egg dishes, Quests',
        "[list][*][b]🧬 Crop breeding[/b] (from gnome level 10): plant two crops side by side. Once you have fully mastered both, each harvest has a small chance of a [b]hybrid seed[/b]: Pluot, Tangelo, Triticale, Pomato, Itoh Peony and 17 more. A beehive helps. Hybrids grow faster, give more and do well at the Fair, but never give their own seeds: cross again or trade for more. Hints are in the Almanac under [b]Breeding notes[/b].\n"
        . "[*][b]🥚 Egg dishes[/b]: Biddy's eggs now cook into 11 dishes, from Scrambled Eggs and Pancakes to Shakshuka, Quiche and a Savoury Egg Pie feast.\n"
        . "[*][b]📜 Quests[/b]: Jobs now has a Quests tab (and its own menu tile) with your Journey chapters, calling, rest-stop errands, town orders and repairs in one place.\n"
        . "[*]Home cooking gives 115% energy (was 150%). Each town now pins up to 3 orders at a time.[/list]"],
    '1.0.1' => ['🔧 Update 1.0.1: tidier phone menu, quicker pages',
        "[list][*]The phone menu fits on one screen. Garden, World, Satchel, Town and Jobs live in the bottom bar, and Garden shows when crops are ready.\n"
        . "[*]New gnomes can send gifts and trades after their first 3 days and once they reach gnome level 3. Receiving is fine from day one. This keeps the Hollow fair.\n"
        . "[*]Pages load a little faster. The Hollow jar now adds up everyone's share about once a minute.[/list]"],
    '1.0.0' => ['🌻 Gnome Venture 1.0: The Hollow Wakes Up',
        "Our biggest update yet. The Hollow now has seasons, weather and people everywhere you go.\n\n"
        . "[b]🌦️ Seasons, weather and day & night[/b]\n[list][*]Each season lasts two weeks. Every region has its own weather each day, and the Hollow has dawn, day, dusk and night. See the forecast on the new [b]Seasons[/b] page.[/list]\n"
        . "[b]🪧 Rest stops reborn[/b]\n[list][*]Every road village is now a [b]fishing jetty, inn, mill, shrine, herb croft[/b] or one of 12 kinds of stop, with 55 things to do. Some only happen at night, in the rain or in winter.\n"
        . "[*][b]Stay a while[/b]: three things per visit. Meet 2–3 named villagers at each stop, chat, make friends and run their errands.\n"
        . "[*]A [b]stamp passport[/b] for every stop you visit, with sets, rewards and titles.\n"
        . "[*][b]Adopt a stop[/b] and build it up over four tiers: new things for everyone, a plaque with your name, and a small daily perk.[/list]\n"
        . "[b]🌱 A living garden[/b]\n[list][*]Crops have seasons: in season they grow faster and give more. The greenhouse ignores the calendar.\n"
        . "[*]Weather matters: rain waters your beds, frost nips tender crops (mulch helps), heat dries the soil.\n"
        . "[*]Gentle [b]pests[/b] (aphids, slugs, gnats, caterpillars) slow things down: pick them off or plant [b]companions[/b].\n"
        . "[*]Garden critters: a [b]Worm Farm[/b], a [b]Ladybird Lodge[/b], a [b]Frog Pond[/b] with tadpoles, and [b]Biddy[/b], the neighbour's hen, who trades eggs and feathers over the fence. Nothing ever dies.[/list]\n"
        . "[b]🧺 Orders and market day[/b]\n[list][*]Townsfolk post [b]orders[/b] with a quality bar: good carrots, a fine jam, a lovely arrangement.\n"
        . "[*]A weekly [b]market day[/b] with stalls, wanted goods and best-basket judging.\n"
        . "[*]Prices now drift week to week. Watch for ⭐ wanted goods and ↑/↓ chips when selling.[/list]\n"
        . "[b]🤝 Together[/b]\n[list][*]A real [b]friends list[/b], guestbook stamps on gardens, and seedlings to gift.\n"
        . "[*][b]Hollow Goals[/b]: a weekly jar everyone fills together, with rewards for every helper. The [b]Hollow Pulse[/b] shows who's about (you can hide yourself).\n"
        . "[*]Townsfolk now enter the shows, fairs and races too, so there's always company (they never take your prizes).\n"
        . "[*][b]Wren's First Week[/b] for new gnomes, a [b]welcome back[/b] page after time away, and a gentle daily card. No streaks to lose.[/list]\n"
        . "[b]🎉 Opening Day[/b] is on now: a launch festival with its own goal, stalls and keepsakes.\n\nThank you for playing. 🍄"],
    '2.0.4' => ['🧭 A tidier menu and livelier roads',
        "[list][*][b]Fewer menu tiles[/b]: Seasons now lives on the World page, and your Passport and the Villagers you know are tabs in Town.\n"
        . "[*][b]Livelier roads[/b]: new road scenes and sights for every region, more finds on the way, and a line of colour in every room of a delve.\n"
        . "[*][b]More to say[/b]: the stop villagers who were quiet now chat.[/list]"],
    '2.0.5' => ['🛒 Picture shops',
        "The shop, the Trading Post stalls and Market Day now show your goods as picture tiles. Tap one to pick how many, and see the total before you buy."],
    '2.0.6' => ['🕯️ Delves and lairs have maps',
        "Going down a delve or into a lair? You now walk it on a little cave map. Tap a lit tile to walk there, find the rooms in any order, and open the chest once the other rooms are cleared. Walking costs no energy. Prefer the old way? Tap [b]Use the simple list[/b]."],
    '2.0.86' => ['🏞️ Every special place has its own picture',
        "Havens, wonders, delves and lairs now show a painted scene when you arrive: a crab keeper at the dark lighthouse, a silverback in the glade, a spider in her hollow, and 78 more. Look for them on the World and Town pages."],
    '2.0.88' => ['🧩 Puzzle Pals',
        "Every Jigsaw picture now has six little Puzzle Pals. Solve a picture at Advanced size and its pals are set free; after that you may meet them on your travels. Keep them in your Pal Book, take two along once you are gnome level 15, and win an Expert trophy to make a picture's pals a little stronger."],
    '2.0.89' => ['🧙 My Gnome has tabs',
        "[list][*][b]My Gnome[/b] is split into tabs down the left: Overview, Stats, Calling, Foods eaten, Villagers and Gardens.\n"
        . "[*][b]Stats[/b] show a chart next to the list. Tap a stat to read what it does and press +1 to spend a point.\n"
        . "[*][b]Foods eaten[/b] is now a tasting menu, and [b]Villagers[/b] is a wall of snapshots of everyone you know.\n"
        . "[*][b]Easy roads[/b] moved to Account.\n"
        . "[*]A new [b]Today[/b] link sits in the side rail on every page.[/list]"],
];
    foreach (UPDATE_NEWS as $v => $post) {
        if (version_compare((string)$v, $from, '>') && version_compare((string)$v, APP_VERSION, '<=')) $todo[(string)$v] = $post;
    }
    uksort($todo, 'version_compare');
    $n = count($todo);
    $i = 0;
    foreach ($todo as [$title, $body]) {
        $i++;
        if (q_val('SELECT 1 FROM news WHERE title = ?', [$title])) continue;
        db_insert('news', ['title' => $title, 'body' => $body, 'published' => 1, 'author_id' => null,
            'created_at' => gmdate('Y-m-d H:i:s', time() - ($n - $i) * 60)]);   // a minute apart, newest on top
    }
}
