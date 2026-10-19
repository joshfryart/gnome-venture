<?php
declare(strict_types=1);

/**
 * v0.7.61: the Almanac's Glossary tab. Plain words for the game's own terms.
 * Only things that really exist in the Hollow are listed here. The page sorts them A to Z.
 */
const GLOSSARY = [
    'Almanac page' => 'One entry in your Almanac: a plant, flower, village, landmark, creature, find, recipe or lore note. Pages fill in as you discover them.',
    'Annual' => 'A crop that is finished after one harvest. Its square has to be tilled again before you plant there.',
    'Calling' => 'Your gnome’s path in life, chosen at gnome level 5 and kept for good. It grows through three tiers: Apprentice, Journeyman and Master.',
    'Curb appeal' => 'How lovely your yard looks. Decorations, variety, buildings and flowers in bloom all add to it.',
    'Cut flower' => 'A flower you grow and cut from your garden. Cutting it once helps fill in its Almanac page.',
    'Delve' => 'An underground landmark: five rooms, one after another, with a chest at the bottom. You keep everything you find, whenever you climb out.',
    'Energy' => 'What tending, harvesting, walking and adventuring cost. It refills over time, and eating gives it back: a raw crop or find gives 1 or 2, and a home-cooked dish gives much more (snacks a little, meals more, feasts the most). Flowers, herbs and spices give none.',   // v0.9.4
    'Food Scrap' => 'Peelings and crumbs left when you eat a raw crop. Add them to a Compost Bin’s heap, or craft 12 into Plain Compost in your satchel.',   // v0.9.4
    'Snack, meal, feast' => 'The three kinds of dish. Snacks (teas, jams, toasts) are quick and cost no energy to cook. Meals cost 1 energy. Feasts need a Kitchen III, cost 2 energy and a few Petals for firewood, and give the most energy and the longest buffs. Dishes cook in pots with a timer (snacks in minutes, meals longer, feasts longest): collect them when they are ready. A snack pot holds up to 5.',   // v0.9.4
    'Fast travel' => 'Jumping straight to a region you have already walked to, from the map.',
    'Fertility' => 'How rich a square’s soil is. Higher fertility means faster growth. The Soil Test Kit shows it exactly.',
    'Festival' => 'One day a month in each town. Some things pay out double, and the festival stall on the Green gives a free treat once a day.',
    'Garden level' => 'How experienced your garden is. Higher levels let your plot grow bigger and unlock buildings, such as the Kitchen at level 2.',
    'Gardening guide' => 'A book that teaches one region’s crops. Buy it in a shop, or earn it by finishing that region’s chapter of Wren’s Journey. Its crops then grow at full speed and harvest.',
    'Journey' => 'Wren’s Journey: one chapter per region, starting when you first arrive. Get to know the place, help build its project, and earn its guide, rewards and a lasting benefit.',
    'Unstudied' => 'A crop from a region you haven’t studied yet. You can still plant it, but it grows slower and gives a smaller harvest until you study the region or master the crop.',
    'Gnome level' => 'How experienced your gnome is. Some things, such as choosing a calling, unlock at a set gnome level.',
    'Havens' => 'Safe, restful landmarks in the wilds. You can rest there, and some give a helpful buff.',
    'Hired help' => 'A helper you pay up front for 1, 3 or 7 days, so they can tend your garden while you are away. They water, weed no-till beds and harvest. You need a Tool Shed to hire one.',
    'Knowledge' => 'How well you know a plant. Each harvest teaches you more, and full knowledge masters it.',
    'Lair' => 'A boss with a set level, waiting in the wilds.',
    'Landmarks' => 'Places in each zone of a region: havens, wonders, delves and lairs.',
    'Milestone' => 'A goal in your Almanac with a reward: coins, items or a title you can wear.',
    'Moisture' => 'How long a square’s watering lasts. Plants only grow while they are watered.',
    'Mulch' => 'Ground cover that keeps the soil covered. Keeping the mulch on helps a no-till bed hold its grade.',
    'N, P and K' => 'Nitrogen, phosphorus and potassium: the three nutrients every square holds. Each crop feeds on one of them.',
    'No-till bed' => 'A bed you do not turn over. It climbs through soil grades over time and keeps its soil life, but it needs a broadfork to loosen it deeply.',
    'Perennial' => 'A plant, such as a tree, bush or some herbs, that grows back after each harvest (🔄). It lives a set time (trees longest), giving a little less as it ages, then gives one last harvest. Rest one in the Root Cellar to pause its age.',
    'Petals' => 'The money of the Hollow. Prices, rewards and trades are in Petals.',
    'Plot' => 'Your garden’s growing ground, made of squares. It starts at 4×4; buy more rows and columns with Petals once your garden level allows.',
    'Rarity' => 'Each item has a letter: C is Common, U is Uncommon, R is Rare and L is Legendary.',
    'Region' => 'One of the fourteen regions of the Hollow, each with its own plants, villages and landmarks.',
    'Region level' => 'The gnome level a region is meant for. Roads into it are about that hard, so check the coloured badge before you set off.',
    'Region medal' => 'A Bronze, Silver or Gold tier you earn in a region by growing its crops. Each medal includes the ones before it.',
    'Rest stop' => 'A village on a road. There’s no town square, just one little choice of village life per visit. Walk on and come back for another go.',
    'Restock' => 'Shops refresh their stock on a timer. When an item comes back, it may be at a new price.',
    'Road' => 'A path between the towns of neighbouring regions. Each road passes three villages, and what you meet there sits at the region’s own level.',
    'Root Cellar' => 'A building in your garden that keeps up to five perennials safe while you need their beds.',
    'Sapling' => 'The young-plant form of a tree, nut, fruit or perennial. You plant it instead of a seed.',
    'Satchel' => 'Your bag of things. Open it from the menu to eat, read or place what you carry.',
    'Side path' => 'An optional track off a road. You can find things there, and delves are the hardest of them.',
    'Soil grade' => 'The grade a no-till bed earns, from F up to S. Higher grades grow faster, give bigger harvests and hold water longer.',
    'Soil improver' => 'Something from the Soil group of your Satchel, such as compost or worm castings. Work one into a square to raise its fertility, soil life or nutrients. It takes a few minutes to work in, one at a time.',
    'Soil life' => 'The living things in the soil: fungi, bacteria, worms and beetles. More soil life means bigger harvests and more saved seeds. Tilling harms it.',
    'Staple crop' => 'A common crop of a region. Growing every staple earns the Bronze medal.',
    'Studied' => 'A crop you know properly: from your home region, a guide, a Journey chapter, owning a garden in its region, or mastering it. Studied crops you haven’t grown yet show as studied pages in the Almanac.',
    'Tasted' => 'An item you have eaten at least once. The first taste of some rare foods raises a stat for good.',
    'Tilling' => 'Turning a square’s soil so it is ready to plant. Each till harms soil life, so a tilled square needs tilling again after an annual harvest.',
    'Tool wear' => 'Tools wear out with use. Gathering tools, the walking staff and the lantern wear by uses; garden tools by days of use. A worn tool can’t be traded or given away until it is mended. A tool that breaks becomes a Broken copy: mend it in your Satchel for a price (a Tool Shed mends one free each day). The Glowcap Lantern and Worn garden tools never wear out.',
    'Toolbelt' => 'The strip of tools under your Satchel. Your best tool of each kind is used automatically. Tools wear out and break with use (see Tool wear). Sturdy, Fine and Masterwork tools give a 20%, 30% or 50% chance that a garden action costs no energy.',
    'Treasure crop' => 'A rare, valuable crop of a region. Growing every treasure is part of the Gold medal.',
    'Uncommon crop' => 'A less common crop of a region. Growing every uncommon is part of the Silver medal.',
    'Village' => 'A small settlement in a region, with its own Almanac pages to discover.',
    'Wonders' => 'Landmarks with puzzles and events to solve.',
    'Yard' => 'The space around your garden where you place decorations. You design it from your garden page.',
];
