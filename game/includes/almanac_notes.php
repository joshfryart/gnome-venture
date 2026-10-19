<?php
declare(strict_types=1);
/**
 * v0.7.72: the Almanac review. Live "your notes" boxes under crop, place and region pages, the new How-to-play pages,
 * and the one-time rewrite of outdated pages.
 */
require_once __DIR__ . '/garden_logic.php';
require_once __DIR__ . '/world.php';
require_once __DIR__ . '/items.php';

/** The notes box for a page, from its unlock key ('' when there's nothing to add). */
function almanac_notes(array $u, array $entry): string
{
    $key = (string)$entry['unlock_key'];
    if ($key === 'start' && (string)$entry['title'] === 'Breeding notes') { require_once __DIR__ . '/breeding110.php'; return breeding110_notes($u); }   // v1.1.0
    if (str_starts_with($key, 'plant:')) return almanac_plant_notes($u, substr($key, 6));
    if (str_starts_with($key, 'village:') || str_starts_with($key, 'landmark:')) return almanac_place_notes($u, (string)substr($key, strpos($key, ':') + 1));
    if (str_starts_with($key, 'region:')) return almanac_region_notes($u, substr($key, 7));
    if (str_starts_with($key, 'creature:')) return almanac_creature_notes($u, substr($key, 9));   // v0.7.72
    if (str_starts_with($key, 'gather:')) return almanac_gather_notes($u, substr($key, 7));
    if (str_starts_with($key, 'recipe:')) return almanac_recipe_notes($u, substr($key, 7));
    return '';
}

function almanac_plant_notes(array $u, string $slug): string
{
    $p = q_one('SELECT * FROM plants WHERE slug = ?', [$slug]);
    if (!$p) return '';
    $uid = (int)$u['id'];
    $grow = almanac_growing_box($p);   // v0.7.72: live facts (the page text's old numbers are hidden)
    $L = [];
    // Studied?
    if (plant_unstudied($u, $p)) {
        $L[] = '📕 <b>Unstudied</b>: grows ' . unstudied_slow_pct($u) . '% slower and gives ' . (100 - unstudied_yield_pct($u)) . '% less. Study '
            . e(plant_home_name((int)$p['id']) ?: 'its region') . ' (its guide or its Journey chapter) or master it.';
    } elseif ($p['kind'] !== 'cover') {
        $L[] = '📗 <b>Studied</b>: grows at full speed and harvest.';
    }
    // Knowledge
    $k = (int)q_val('SELECT knowledge FROM user_plant_knowledge WHERE user_id = ? AND plant_id = ?', [$uid, $p['id']]);
    $max = max(1, (int)$p['knowledge_max']);
    $per = max(1, (int)$p['knowledge_per_harvest']);
    $L[] = ($k >= $max ? '⭐ <b>Mastered</b>' : '📈 Knowledge') . ' <progress max="' . $max . '" value="' . min($k, $max) . '"></progress> ' . min($k, $max) . '/' . $max
        . ($k < $max ? ' <span class="muted">(about ' . (int)ceil(($max - $k) / $per) . ' more harvest' . ((int)ceil(($max - $k) / $per) === 1 ? '' : 's') . ' to master)</span>' : '');
    // Perennial
    if ((int)$p['perennial'] && $p['kind'] !== 'cover') {
        $life = (int)setting(in_array($p['kind'], ['tree', 'nut'], true) ? 'life_tree_days' : ($p['kind'] === 'fruit' ? 'life_fruit_days' : 'life_other_days'));
        $L[] = '🔄 <b>Perennial</b>: regrows every ' . e(nice_time((int)$p['regrow_minutes'] * 60)) . ' of watered time and lives about ' . $life . ' days. Regrowths give '
            . (int)setting('regrow_yield_percent') . '% of the first crop.';
    }
    // Rarity and price
    $IL = item_lookups();
    if ($p['produce_item_id'] && ($it = q_one('SELECT * FROM items WHERE id = ?', [$p['produce_item_id']]))) {
        [, $rw] = item_rarity($it, $IL);
        $L[] = '💰 ' . e($rw) . ' · shops pay about ' . money(sell_price($it, $u)) . ' each for ' . e($it['name']) . '.';
        if ((int)$it['edible'] || q_val('SELECT 1 FROM user_tasted WHERE user_id = ? AND item_id = ?', [$uid, $it['id']])) {
            $L[] = q_val('SELECT 1 FROM user_tasted WHERE user_id = ? AND item_id = ?', [$uid, $it['id']]) ? '🍴 You’ve tasted it.' : '🍴 Not tasted yet.';
        }
    }
    // Where it grows and where seeds are sold
    $regs = q('SELECT r.gnomish_name, pr.tier FROM plant_regions pr JOIN regions r ON r.id = pr.region_id WHERE pr.plant_id = ? ORDER BY r.min_level', [$p['id']])->fetchAll();
    if ($regs) {
        $tw = ['staple' => 'staple', 'uncommon' => 'uncommon', 'treasure' => 'treasure', 'flower' => 'flower'];
        $L[] = '🌍 Native to ' . e(implode(', ', array_map(fn($r) => $r['gnomish_name'] . ' (' . ($tw[$r['tier']] ?? $r['tier']) . ')', $regs))) . '. Native crops grow ' . (int)setting('native_bonus_percent') . '% faster in gardens there.';
    }
    $shops = q('SELECT DISTINCT s.name FROM shop_stock st JOIN shops s ON s.id = st.shop_id WHERE st.item_id = ? AND s.open = 1 ORDER BY s.name', [$p['seed_item_id']])->fetchAll(PDO::FETCH_COLUMN);
    $L[] = '🛒 ' . ($shops ? 'Seeds sold at ' . e(implode(', ', $shops)) . ' (when in stock).' : 'Seeds aren’t sold in shops: save them from harvests, or find them on adventures.');
    return $grow . almanac_notes_box($L);
}

function almanac_place_notes(array $u, string $slug): string
{
    require_once __DIR__ . '/roads.php';
    $l = q_one('SELECT * FROM locations WHERE slug = ?', [$slug]);
    if (!$l) return '';
    $uid = (int)$u['id'];
    $L = [];
    $road = road_of((int)$l['id']);
    if ($road) {
        $L[] = '🛣️ On the road <b>' . e($road['name']) . '</b>, in ' . e((string)$l['region']) . '.';
    } else {
        $from = q_val("SELECT a.name FROM routes r JOIN locations a ON a.id = r.a_id WHERE r.b_id = ? AND r.kind = 'side' LIMIT 1", [$l['id']]);
        $L[] = '🌿 Off the road in ' . e((string)$l['region']) . ($from ? ': a side path leaves from <b>' . e($from) . '</b>, once you’ve found it by wandering off the path there.' : '.');
    }
    if ((int)($u['location_id'] ?? 0) === (int)$l['id']) $L[] = '🎩 You’re here right now.';
    if (q_val('SELECT 1 FROM plots WHERE user_id = ? AND village_id = ?', [$uid, $l['id']])) $L[] = '🏡 You have a garden here.';
    if (($lm = q_one('SELECT * FROM landmarks WHERE location_id = ?', [$l['id']]))) {
        $what = ['haven' => '🏕️ A haven: rest by the fire, stay the night for a stat boost, and buy from the pantry, once a day each.',
                 'wonder' => '✨ A wonder: a puzzle or trial to solve with your stats, for a reward.',
                 'delve' => '🕳️ A delve: five rooms underground, a chest at the bottom. You keep what you find, whenever you climb out.',
                 'lair' => '🐉 A lair: home of a legendary boss. Beat it for a great prize.'][$lm['kind']] ?? '';
        if ($what) $L[] = $what;
        require_once __DIR__ . '/landmarks.php';
        $la = landmark_at((int)$l['id']);
        if ($la && $lm['kind'] !== 'haven') {
            $lv = (int)$la['level']; $me = (int)($u['level'] ?? 1);
            $L[] = '⚔️ Danger level about ' . $lv . ' · ' . ($lv <= $me ? '<span class="good">fine for you</span>' : ($lv <= $me + 4 ? '<span class="warn">a bit above your level</span>' : '<span class="bad">well above your level</span>')) . '.';
        }
        require_once __DIR__ . '/journey.php';
        if ($jc = journey_lock($uid, 'place', $slug)) $L[] = '🚧 Closed for repairs until you finish <a href="' . e(url('book.php?ch=Journey&j=' . (int)$jc['id'])) . '">' . e($jc['project_icon'] . ' ' . $jc['region'] . ': ' . $jc['title']) . '</a>.';
        $clears = (int)q_val('SELECT clears FROM landmark_clears WHERE user_id = ? AND landmark_id = ?', [$uid, $lm['id']]);
        if ($clears) $L[] = '🏆 You’ve conquered it ' . $clears . ' time' . ($clears === 1 ? '' : 's') . '.';
        require_once __DIR__ . '/rebuild.php';   // v0.7.88: ruins are per gnome
        if (landmark_rebuilt_by($lm, $uid)) $L[] = '🧱 You made this place safe for yourself.';
        if ($plaque = restored_line($lm)) $L[] = $plaque;   // the plaque: how many gnomes, and the Founder
    }
    return almanac_notes_box($L);
}

function almanac_region_notes(array $u, string $code): string
{
    $r = region_by_slug(strtoupper($code));
    if (!$r) return '';
    $uid = (int)$u['id'];
    $L = [];
    $L[] = '🎚️ Recommended gnome level ' . max(1, (int)$r['min_level']) . '.';
    $t = region_tier_progress($uid, (int)$r['id']);
    $bar = fn(string $k, string $w) => $w . ' ' . (int)$t[$k]['have'] . '/' . (int)$t[$k]['need'];
    $L[] = ($t['gold'] ? '🥇 Gold' : ($t['silver'] ? '🥈 Silver' : ($t['bronze'] ? '🥉 Bronze' : '🏅 No medal yet'))) . ' · grown: '
        . e(implode(' · ', [$bar('staple', 'staples'), $bar('uncommon', 'uncommons'), $bar('treasure', 'treasures'), $bar('flower', 'flowers')]));
    $L[] = q_val('SELECT 1 FROM user_guides WHERE user_id = ? AND guide_key = ?', [$uid, 'region:' . strtolower($code)]) ? '📗 You’ve studied its crops.' : '📕 Not studied yet: its crops grow slower for you until you read its guide or finish its Journey chapter.';
    require_once __DIR__ . '/journey.php';
    foreach (journey_chapters() as $ch) {
        if ((int)$ch['region_id'] !== (int)$r['id']) continue;
        $row = q_one('SELECT * FROM user_quests WHERE user_id = ? AND chapter_id = ?', [$uid, $ch['id']]);
        $L[] = '🧭 Journey: <a href="' . e(url('book.php?ch=Journey&j=' . (int)$ch['id'])) . '">' . e($ch['project_icon'] . ' ' . $ch['title']) . '</a> · '
            . ($row && $row['done_at'] ? '✔ finished' : ($row ? 'in progress' : 'starts when you arrive'));
    }
    if (q_val('SELECT 1 FROM plots WHERE user_id = ? AND region_id = ?', [$uid, $r['id']])) $L[] = '🏡 You have a garden here.';
    return almanac_notes_box($L);
}

function almanac_notes_box(array $lines): string
{
    if (!$lines) return '';
    return '<div class="mynotes"><p class="mnhead">📝 Your notes</p><ul>' . implode('', array_map(fn($l) => '<li>' . $l . '</li>', $lines)) . '</ul></div>';
}

/** How-to-play pages (title => [category, sort, body]). Rewritten ones replace the old text once; new ones are added. */
const ALMANAC_HOWTO = [
    'Welcome to your Almanac' => ['Getting started', 0,
        "Every gardener in the Hollow carries one of these. It fills itself in as you play.\n\n"
        . "[b]📖 Contents[/b] is the front page: what’s new, what to do next, and how full each part is. Search it any time.\n"
        . "[b]🧭 Journey[/b]: Wren’s questline, a chapter for every region, and your [b]Milestones[/b].\n"
        . "[b]🌱 Growing[/b]: a page for every crop and flower (filled in when you first harvest it), and the gardening [b]Guides[/b].\n"
        . "[b]🗺️ World[/b]: regions, towns, villages and landmarks, filled in as you visit and explore.\n"
        . "[b]🐾 Wild[/b]: creatures you’ve met and things you’ve gathered.\n"
        . "[b]👥 Villagers & Recipes[/b]: everyone you’ve met, and every recipe you’ve discovered.\n"
        . "[b]📚 How to play[/b]: these pages, and a Glossary of the game’s words.\n\n"
        . "New pages are marked ✨ until you read them. Crop, place and region pages also have a [b]📝 Your notes[/b] box that keeps itself up to date."],
    'Soil care on tilled squares' => ['Getting started', 4,
        "Tilled squares can't earn no-till grades, but a square you look after earns [b]soil care stars[/b], from ☆☆☆☆☆ Rough ground up to ★★★★★ Garden loam.\n\n"
        . "[b]Earning a point:[/b] work compost (or another soil improver) into the square, then harvest while its soil life is at least lively. One point a day per square.\n"
        . "[b]Stars:[/b] 3, 7, 14, 21 and 30 points. Each star makes crops there grow 2% faster, counts a little at the Harvest Fair and the Village Show, "
        . "and makes tilling gentler: a till costs 15 soil life on rough ground, down to 5 at five stars, so cared-for soil stays alive.\n"
        . "[b]Losing stars:[/b] a square left as wild ground loses a star every 7 days. Re-tilling never resets it.\n"
        . "[b]Going no-till:[/b] sheet mulch a cared-for square and the new bed starts a grade up for every 2 stars.\n\n"
        . "No-till beds still grow best (up to +30% at grade S). Soil care is the reward for tending tilled ground well."],
    'Knowing your plants' => ['Getting started', 7,
        "You can plant [b]any[/b] seed. But crops are either [b]studied[/b] 📗 or [b]unstudied[/b] 📕.\n\n"
        . "You start knowing everyday garden crops, plus the staples and flowers of your home region. Owning a garden in a region teaches all its crops too.\n\n"
        . "Unstudied crops grow 25% slower and give 40% less (the seed picker, shops and your Satchel all show 📕). To study a region:\n"
        . "[list][*]📗 buy its [b]gardening guide[/b] in a shop and read it from your Satchel, or\n[*]🧭 finish its chapter of [b]Wren’s Journey[/b], which gives you the guide for free, or\n"
        . "[*]⭐ [b]master[/b] a single crop by harvesting it again and again: that one crop counts as studied.[/list]"],
    'Knowledge & mastery' => ['Getting started', 5,
        "Each harvest teaches you more about a plant (Lore helps). The 📝 notes on its Almanac page show how many more harvests you need.\n\n"
        . "At full knowledge you've [b]mastered[/b] it ⭐. A mastered crop counts as studied even without its region’s guide, and masters can raise saplings to sell or give to other players."],
    'Wren’s Journey' => ['Getting started', 20,
        "Wren is finishing her teacher Tansy’s field guide to the Hollow, and she needs your help. Every region has a chapter, which starts the first time you arrive there.\n\n"
        . "[list][*]⬜ First get to know the place: reach it, harvest a few of its staple crops, befriend a local, find a hidden place.\n"
        . "[*]🧱 Then help build its project, one stage at a time. Hand stages in from Almanac → Journey or a town square’s 📜 Quests tab.\n"
        . "[*]📜 Finish the chapter for Petals, XP, a gift, the region’s gardening guide and a lasting bonus there.[/list]\n"
        . "Some places stay [b]closed for repairs[/b] until you finish their chapter. Dressed Stone, Timber Planks and Rope are made in Satchel → Crafting → Building."],
    'Perennials & lifespans' => ['Getting started', 21,
        "🔄 Perennials (trees, bushes, many herbs and flowers) grow back after each harvest. Each harvest costs some energy, more for rarer crops.\n\n"
        . "[list][*]The first harvest is full; regrowths give a little less (75%) and less XP.\n"
        . "[*]They live a set time: trees and nut trees about 60 days, fruit about 45, the rest about 30. Harvests shrink slowly with age, then the last one clears the square.\n"
        . "[*]Tap a perennial in your garden to see its age. A Root Cellar keeps perennials safe while you need their beds, and pauses their age.[/list]"],
    'Selling & rarity' => ['Getting started', 22,
        "Everything has a rarity letter: [b]C[/b]ommon, [b]U[/b]ncommon, [b]R[/b]are or [b]L[/b]egendary.\n\n"
        . "Shops pay more for rarer things: Uncommon about ×1.3, Rare ×1.8, Legendary ×2.5. Charm helps, and some Journey projects make a region’s shops pay 10% more.\n\n"
        . "In a shop, use the [b]Sell[/b] tab: tap things, add them to your basket (+1, +2, +5, +10 or All) and sell the lot at once."],
    'Folk & friendship' => ['Getting started', 23,
        "You meet villagers by visiting their shop while they’re at the counter, finding them about town, or chatting and giving gifts. Everyone you’ve met is on [b]Villagers you know[/b] (in the menu), and in the Almanac’s Villagers chapter.\n\n"
        . "Chat once a day and give a gift once a day to grow a friendship: Stranger → Acquaintance → Friend → Good friend → Best friend. Friends give discounts in their shops, and acquaintances post favours on the town Notice Board. "
        . "Everyone has a favourite thing, two kinds of thing they like and one they don’t: gifts teach you which."],
    'Exploring & fighting' => ['Getting started', 24,
        "Roads run between towns. From any road stop you can 🌿 [b]wander off the path[/b]: it starts as easy as the road you left, and each step out is a little harder than the last. The deeper you go, the better the finds and the more likely you are to spot a hidden village or landmark. Wild country, with bosses, starts at step 7. Past step 9 lie the deep wilds, always a match for your own level. Once you’ve outgrown an area, its fights and finds give less XP and fewer Petals (items stay the same), so the deep wilds are where strong gnomes earn their keep. Head back to the road any time, for free. Carry an axe to chop logs (they make timber planks) and a fishing rod to catch fish for the kitchen. Gathering tools, your walking staff and your lantern wear a little with each use, and break after enough of them: mend a broken tool in your Satchel (see Tool wear).\n\n"
        . "In a fight you and the creature take turns. Grit and Nimble help you hit and dodge, Hardiness gives you more health, and your calling gives you one special move per fight. "
        . "The coloured level badge shows the danger: green is fine, amber is a bit above you, red is well above. Losing never costs items: you wake up back where you started.\n\n"
        . "🏚️ [b]Ruins[/b]: some havens, wonders and delves have fallen into ruin, and nobody can use them until they’re made safe. Each gnome makes a ruin safe for themselves: clearing their own path in, shoring up their own corner and earning the keeper’s trust. Any gnome of level 3 or more can take on the repair at the place itself (up to three at a time). Bring building materials (Crafting → Building), home-cooked meals and a few uncommon or rare finds, one stage at a time. Each stage pays Petals and XP. Once you’ve made a place safe, it’s open to you, and it stays a little better for you: a fuller pantry, a warmer fire, an easier puzzle and a fuller chest. The first gnome to finish is its Founder, and is named first on the plaque with everyone else who made it safe. Your repairs are listed at the top of the Job Board and on a town square’s Quests tab, and stages can be handed in from either."],
    'Energy & food' => ['Getting started', 25,
        "⚡ [b]Energy[/b] is spent when you till, plant, water, harvest, walk and gather. It comes back on its own, a little every minute, and eating brings it back at once.\n\n"
        . "[b]Raw food[/b]: a raw crop or forage find gives 1 energy (2 for filling roots, beans and grains). Herbs, spices and flowers give none. Eating one also leaves a ♻️ Food Scrap.\n"
        . "[b]Snacks[/b] (teas, jams, toasts, salads) cook in minutes and cost no energy. [b]Meals[/b] cost 1 energy to cook. [b]Feasts[/b] need a Kitchen III and cost 2. Home-cooked dishes give far more energy than raw food, and their buffs last for hours.\n"
        . "[b]Shop-bought[/b] dishes give only a little energy.\n\n"
        . "Out of energy? Eat a crop from your satchel, play a game, or cook once you have a Kitchen."],
    'Food scraps & compost' => ['Getting started', 26,
        "♻️ Eating a raw crop leaves a [b]Food Scrap[/b] (heavy fruit like pumpkins and melons leave 2 or 3).\n\n"
        . "[b]No Compost Bin yet?[/b] In your satchel, Crafting → Garden supplies, turn 12 Food Scraps into 1 Plain Compost.\n"
        . "[b]With a Compost Bin[/b], press ♻️ Add scraps in 🏠 Garden buildings. Each scrap counts towards the heap, along with every harvest, dug-up plant and weeding. Choose what the heap makes: Plain Compost (8 scraps, 6 at level II), Leaf Mould (12) and Worm Castings (20) at level II, and Rich Loam (40) at level III. Scraps already on the heap carry over when you change your mind."],
    // v0.9.5: these two stay hidden until they happen (4th item = the unlock key; the rest are there from the start)
    'Pots' => ['Getting started', 27,
        "🍳 Cooking happens in [b]pots[/b] on your Kitchen’s stove. Start a dish from Satchel → Crafting → Cooking; it goes in a free pot and cooks while you do other things. Come back and press [b]Collect[/b].\n\n"
        . "[b]How many pots:[/b] 2 with a Kitchen I, 3 with a Kitchen II, 4 with a Kitchen III (Brewroot masters and extra Kitchens add more). A pot stays busy until you collect it, even when the dish is done.\n"
        . "[b]How long:[/b] snacks about 3 minutes, meals 15, feasts 45 (each recipe can differ: the recipe page tells you). Brewroot callings cook faster.\n"
        . "[b]Batches:[/b] a pot makes one dish, but snacks cook up to 5 at a time in one pot.\n"
        . "[b]Collecting:[/b] gives the dishes, cooking XP, a little garden XP for your Kitchen, and ♻️ Food Scraps from the peelings (1 for every 3 ingredients). The first time you make a dish its recipe page joins your Almanac.\n\n"
        . "Tip: put the long feasts on before you head out and the snacks on while you tend the garden.", 'pots'],
    'Food Scraps' => ['Getting started', 28,
        "♻️ A [b]Food Scrap[/b] is what is left over from food: peelings, cores and stalks.\n\n"
        . "[b]Where they come from:[/b] eating a raw crop or forage find leaves 1 (heavy fruit like pumpkins and melons leave 2 or 3), and collecting a pot gives 1 for every 3 ingredients.\n"
        . "[b]What they are for:[/b] compost. Twelve scraps make 1 Plain Compost at your Satchel’s Crafting page, or add them to a Compost Bin and choose what the heap makes.\n"
        . "They can’t be eaten or sold for much, so don’t throw them away. The page [b]Food scraps & compost[/b] has all the numbers.", 'item:food-scrap'],
    // v0.9.8: the Pantry (hidden until you add one)
    'Pantry' => ['Getting started', 29,
        "🫙 The [b]Pantry[/b] is an add-on for a Kitchen, not a building of its own. Open 🏠 Garden buildings, tap your Kitchen and press [b]Add a Pantry[/b] (Petals and a few Timber Planks). Your jars live in Satchel → Crafting → [b]Pantry[/b].\n\n"
        . "[b]Jars:[/b] you start with 5. One jar holds one batch, and a batch gives 3 or 4 jars of jam, pickles or cordial. A jar stays busy until you collect it, even when the preserve is done. A Kitchen III with a Pantry gives 2 more jars, and a Pantry in each of your other gardens adds 1 more (up to 3 more).\n"
        . "[b]Real days:[/b] the timers run in real time, jam 1 day, chutney 2, pickles 3, kimchi 5, sauerkraut 7 and cordials 14, even while you are away. Nothing spoils: a finished jar waits until you come back.\n"
        . "[b]Energy:[/b] a batch costs 1 energy to start, and every preserve restores energy when eaten, like a meal. Some also give a small, long buff (12 to 24 hours). Like any meal buff, a new one replaces the old one.\n\n"
        . "Tip: start the slow cordials first and the quick jams when you have spare crops. The page [b]Preserves[/b] has the prices and the Harvest Fair.", 'pantry'],
    'Preserves' => ['Getting started', 30,
        "🫙 [b]Preserves[/b] are crops kept in jars: jam, chutney, pickles, kimchi, sauerkraut and cordials. Each recipe appears in Satchel → Crafting → Pantry once you have collected all its crops.\n\n"
        . "[b]Worth more than the crops:[/b] a batch sells for more than the same crops would, and the longer it takes the more it is worth. Keep some back: [b]every townsfolk likes a jar of preserves as a gift[/b], and a loved favourite still wins.\n"
        . "[b]The Harvest Fair:[/b] the 🫙 Preserves class is judged on the best jar you collect in the month. Longer ferments, a better Kitchen, more kinds of crop in the jar and a little Luck score higher. Enter it on the Fair page like any other class.\n"
        . "[b]Not a meal:[/b] preserves are never counted as a Meal or Feast for job boards and calling questlines, but they count as crafting.", 'pantry'],
];

/** Add the new How-to-play pages (once) and, the first time, rewrite the outdated ones. New or rewritten pages show as ✨ new. */
function ensure_almanac_howto(bool $rewrite): void
{
    foreach (ALMANAC_HOWTO as $title => $row) {
        [$cat, $sort, $body] = $row;
        $key = $row[3] ?? 'start';
        $id = (int)q_val("SELECT id FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title]);
        if (!$id) {
            $id = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => $cat, 'title' => $title, 'body' => $body, 'unlock_key' => $key,
                'hint' => $key === 'start' ? '' : ($key === 'pots' ? 'Collect a pot from your Kitchen.' : ($key === 'pantry' ? 'Add a Pantry to your Kitchen.' : 'Get your first Food Scrap.')), 'sort_order' => $sort]);
            // everyone who has the starting pages gets this one too (unread, so it shows as new); a page with its own key goes to whoever already qualifies
            $who = $key === 'start' ? "SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'"
                : ($key === 'pots' ? 'SELECT DISTINCT user_id FROM cook_pots WHERE collected_at IS NOT NULL'
                : ($key === 'pantry' ? 'SELECT DISTINCT p.user_id FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE gb.pantry = 1'
                : "SELECT DISTINCT ui.user_id FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE i.slug = 'food-scrap'"));
            foreach (q($who)->fetchAll(PDO::FETCH_COLUMN) as $uid) {
                try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $id, 'unlocked_at' => now()]); } catch (PDOException $e) {}
            }
        } elseif ($rewrite) {
            q('UPDATE encyclopedia_entries SET body = ?, category = ?, sort_order = ? WHERE id = ?', [$body, $cat, $sort, $id]);
            q('UPDATE user_encyclopedia SET read_at = NULL WHERE entry_id = ?', [$id]);
        }
    }
    if ($rewrite) {
        q("UPDATE encyclopedia_entries SET hint = REPLACE(hint, ', and visit every zone)', ')') WHERE chapter = 'Regions'");
        q("UPDATE encyclopedia_entries SET body = ? WHERE chapter = 'General' AND title = 'Mossbottom Market'", [
            "The heart of Mossbottom, the little market town in the middle of the Hollow that every road leads back to. Its shops never close, and you can shop there from anywhere.\n\n"
            . "[b]Twigg’s Seed Emporium[/b] sells everyday seeds, tools, compost and mulch. [b]The Dewdrop Kitchen[/b] sells ready meals. [b]Hedge & Hearth[/b] sells decorations for your yard.\n\n"
            . "Mossbottom’s town square has the Green, the teahouse, the Notice Board and the library, like every town."]);
        // The lone "People" page is replaced by the Folk chapter
        foreach (q("SELECT id FROM encyclopedia_entries WHERE chapter = 'General' AND unlock_key LIKE 'npc:%'")->fetchAll(PDO::FETCH_COLUMN) as $eid) {
            q('DELETE FROM user_encyclopedia WHERE entry_id = ?', [$eid]);
            q('DELETE FROM encyclopedia_entries WHERE id = ?', [$eid]);
        }
    }
}


/** v0.7.72: a crop's growing facts, worked out from the game itself so they never go out of date. */
function almanac_growing_box(array $p): string
{
    require_once __DIR__ . '/nutrients.php';
    $F = [];
    $F[] = '⏱️ Grows in about <b>' . e(nice_time((int)$p['grow_minutes'] * 60)) . '</b> of watered time (plants only grow while watered).';
    $F[] = '💧 Water lasts about <b>' . e(nice_time((int)$p['water_interval_minutes'] * 60)) . '</b> (longer in moist, rich beds).';
    $F[] = '🪱 ' . ((int)$p['min_soil'] > 0 ? 'Needs soil fertility <b>' . (int)$p['min_soil'] . '</b> or more to plant.' : 'Happy in any soil.');
    if (function_exists('season_chip')) {   // v1.0.0: crop seasons
        $ss = trim((string)($p['seasons'] ?? ''));
        $tr = plant_traits($p);
        $F[] = '🌿 ' . ($ss === '' || $ss === '*' ? 'Grows at the same pace <b>all year</b>.' : 'Grows best in <b>' . e(implode(', ', array_map('trim', explode(',', $ss)))) . '</b> (slower, never stopped, out of season; a greenhouse ignores seasons).') . ' ' . season_chip($p)
            . ($tr ? ' ' . (in_array('tender', $tr, true) ? '🥶 Tender: frost slows it unless mulched. ' : '') . (in_array('tall', $tr, true) ? '🌬️ Tall: storms lean it over.' : '') : '');
    }
    if (isset(NUTRIENTS[(string)($p['nutrient'] ?? '')])) $F[] = '🧪 Feeds on <b>' . e(NUTRIENTS[(string)$p['nutrient']][0] . ' (' . NUTRIENTS[(string)$p['nutrient']][1] . ')') . '</b>: grows faster where that is high.';
    if ($p['kind'] === 'cover') {
        $F[] = '☘️ A cover crop: dig it in when grown to feed the soil (fertility, soil life and N, P, K).';
    } else {
        $F[] = '🧺 Harvest: ' . (int)$p['yield_min'] . (((int)$p['yield_max'] > (int)$p['yield_min']) ? '–' . (int)$p['yield_max'] : '') . ' each time (more with luck, good soil and helpful neighbours) · +' . (int)$p['xp_per_harvest'] . ' XP.';
    }
    if ((int)$p['perennial'] && $p['kind'] !== 'cover') {
        $life = (int)setting(in_array($p['kind'], ['tree', 'nut'], true) ? 'life_tree_days' : ($p['kind'] === 'fruit' ? 'life_fruit_days' : 'life_other_days'));
        $F[] = '🔄 Perennial: regrows every ' . e(nice_time((int)$p['regrow_minutes'] * 60)) . ' and lives about ' . $life . ' days.';
    } elseif ($p['kind'] !== 'cover') {
        $F[] = '🌱 Annual: one harvest, then the square needs tilling again (no-till beds stay ready).';
    }
    return '<div class="mynotes grownotes"><p class="mnhead">🌱 Growing</p><ul>' . implode('', array_map(fn($l) => '<li>' . $l . '</li>', $F)) . '</ul></div>';
}

/** A creature you've met: level, where, danger for you, and its drops (✔ the ones you have). */
function almanac_creature_notes(array $u, string $slug): string
{
    $c = q_one('SELECT * FROM creatures WHERE slug = ?', [$slug]);
    if (!$c) return '';
    $uid = (int)$u['id'];
    $L = [];
    $lv = (int)$c['level']; $me = (int)($u['level'] ?? 1);
    $L[] = '⚔️ Level ' . $lv . ' ' . e((string)$c['size']) . ' creature · ' . ($lv <= $me ? '<span class="good">fine for you</span>' : ($lv <= $me + 4 ? '<span class="warn">a bit above your level</span>' : '<span class="bad">well above your level</span>'))
        . ' · health ' . (int)$c['hp'] . ', attack +' . (int)$c['attack'] . ', defence ' . (int)$c['defense'] . '.';
    $L[] = '🗺️ Found in ' . ($c['landscapes'] === 'any' ? 'every landscape' : e(str_replace(',', ', ', (string)$c['landscapes']))) . ', on roads, side paths and off the path.';
    $drops = q('SELECT d.chance, d.special, i.id, i.name FROM creature_drops d LEFT JOIN items i ON i.id = d.item_id WHERE d.creature_id = ? ORDER BY d.chance DESC', [$c['id']])->fetchAll();
    if ($drops) {
        $bits = [];
        foreach ($drops as $d) {
            if ($d['special']) { $bits[] = ($d['special'] === 'seed' ? 'a local seed' : 'a gardening guide') . ' (' . (int)$d['chance'] . '%)'; continue; }
            $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $d['id']]);
            $bits[] = ($have ? '✔ ' : '') . e((string)$d['name']) . ' (' . (int)$d['chance'] . '%' . ($have ? ', you have ' . $have : '') . ')';
        }
        $L[] = '🎁 Can drop: ' . implode(' · ', $bits) . '.';
    }
    $L[] = '💡 Fights: attack, use your calling’s ability once, or run. Losing never costs items: you wake up where you started.';
    return almanac_notes_box($L);
}

/** A find: where and with what tool, how many you have, and what it's used for. */
function almanac_gather_notes(array $u, string $slug): string
{
    require_once __DIR__ . '/tools.php';
    $it = q_one('SELECT * FROM items WHERE slug = ?', [$slug]);
    if (!$it) return '';
    $uid = (int)$u['id'];
    $g = q_one('SELECT * FROM gatherables WHERE item_id = ?', [$it['id']]);
    $L = [];
    if ($g) {
        $tool = TOOL_TYPES[(string)$g['tool']] ?? null;
        $L[] = '🧭 Look in ' . e(str_replace(',', ', ', (string)$g['landscapes'])) . ' land' . ($tool ? ' with a <b>' . e(strtolower($tool[0])) . '</b> tool ' . $tool[1] . ' (better tools find rarer things)' : '') . ' · ' . e((string)$g['rarity']) . '.';
    }
    $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $it['id']]);
    $L[] = '👜 You have ' . $have . '.';
    $uses = [];
    foreach (q('SELECT r.id, r.name, r.ingredients, (SELECT 1 FROM user_recipes ur WHERE ur.recipe_id = r.id AND ur.user_id = ?) AS known FROM recipes r', [$uid])->fetchAll() as $r) {
        if (isset((json_decode((string)$r['ingredients'], true) ?: [])[$slug])) $uses[] = $r['known'] ? e($r['name']) : '???';
    }
    if ($uses) $L[] = '🔨 Used in ' . count($uses) . ' recipe' . (count($uses) === 1 ? '' : 's') . ': ' . implode(', ', array_slice($uses, 0, 8)) . (count($uses) > 8 ? '…' : '') . '.';
    $L[] = '💰 Shops pay about ' . money(sell_price($it, $u)) . ' each.';
    return almanac_notes_box($L);
}

/** A recipe: what it needs with what you have, and a link to make it. */
function almanac_recipe_notes(array $u, string $slug): string
{
    require_once __DIR__ . '/crafting.php';
    $r = q_one('SELECT * FROM recipes WHERE slug = ?', [$slug]);
    if (!$r) return '';
    $uid = (int)$u['id'];
    $L = [];
    $can = true;
    $bits = [];
    foreach (json_decode((string)$r['ingredients'], true) ?: [] as $is => $n) {
        $ii = q_one('SELECT id, name FROM items WHERE slug = ?', [$is]);
        $have = $ii ? (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $ii['id']]) : 0;
        if ($have < (int)$n) $can = false;
        $bits[] = ($have >= (int)$n ? '✔' : '✖') . ' ' . (int)$n . ' × ' . e((string)($ii['name'] ?? $is)) . ' <span class="muted">(have ' . $have . ')</span>';
    }
    $L[] = '🧾 ' . implode(' · ', $bits);
    [$label, $icon, $building] = CRAFT_CATEGORIES[$r['category']] ?? ['Crafting', '🔨', null];
    if ($building) {
        $b = BUILDINGS[$building] ?? null;
        $hasB = craft_stations($uid)[$r['category']] ?? 0;
        $L[] = ($hasB ? '✔ ' : '🔒 ') . 'Needs a ' . e($b ? $b[1] . ' ' . $b[0] : $building) . ' in one of your gardens' . ($hasB ? '.' : ' (build one on the garden page).');
    }
    $L[] = $can ? '✅ You can make it now: <a href="' . e(url('inventory.php?tab=craft&c=' . $r['category'])) . '">' . $icon . ' Make it in Crafting →</a>' : '⏳ Gather what’s missing, then make it in <a href="' . e(url('inventory.php?tab=craft&c=' . $r['category'])) . '">Satchel → Crafting</a>.';
    return almanac_notes_box($L);
}

/** v0.7.72: a useful hint for a page you haven't found yet (falls back to the stored hint). */
function almanac_locked_hint(array $entry): string
{
    $key = (string)$entry['unlock_key'];
    static $cache = [];
    if (isset($cache[$key])) return $cache[$key];
    $h = '';
    if (str_starts_with($key, 'plant:') && ($p = q_one('SELECT id, seed_item_id FROM plants WHERE slug = ?', [substr($key, 6)]))) {
        $home = plant_home_name((int)$p['id']);
        $shop = q_val('SELECT s.name FROM shop_stock st JOIN shops s ON s.id = st.shop_id WHERE st.item_id = ? AND s.open = 1 ORDER BY s.id LIMIT 1', [$p['seed_item_id']]);
        $h = 'Grow and harvest it.' . ($home ? ' Native to ' . $home . '.' : '') . ($shop ? ' Seeds at ' . $shop . '.' : '');
    } elseif (str_starts_with($key, 'creature:') && ($c = q_one('SELECT level, landscapes FROM creatures WHERE slug = ?', [substr($key, 9)]))) {
        $h = 'Defeat or befriend it. Found in ' . ($c['landscapes'] === 'any' ? 'every landscape' : str_replace(',', ', ', (string)$c['landscapes'])) . ', around level ' . (int)$c['level'] . '.';
    } elseif (str_starts_with($key, 'gather:') && ($g = q_one('SELECT g.landscapes, g.tool FROM gatherables g JOIN items i ON i.id = g.item_id WHERE i.slug = ?', [substr($key, 7)]))) {
        require_once __DIR__ . '/tools.php';
        require_once __DIR__ . '/explore.php';   // v0.7.80: explore_zone_steps() for the steps each region's land is found at
        $h = 'Gather it in ' . str_replace(',', ', ', (string)$g['landscapes']) . ' land' . (isset(TOOL_TYPES[$g['tool']]) ? ' with a ' . strtolower(TOOL_TYPES[$g['tool']][0]) . ' tool' : '') . '.';
        // v0.7.79: which regions have that kind of land (from their zones), so the tip says where to go
        // v0.7.80: and how many steps out it is (zone 1 is near the road). One entry per region, nearest first, max 4.
        $lands = array_map('trim', explode(',', (string)$g['landscapes']));
        $in = implode(',', array_fill(0, count($lands), '?'));
        $parts = [];
        $seen = [];
        // v0.7.84: road stops whose neighbouring land (2 steps out) has it come first: they're the easiest to reach
        foreach (q("SELECT DISTINCT l.*, g.min_level, g.gnomish_name AS rname FROM locations l JOIN regions g ON g.id = l.region_id JOIN routes r ON (r.a_id = l.id OR r.b_id = l.id) AND r.kind = 'road' WHERE l.kind = 'village' ORDER BY g.min_level, l.name")->fetchAll() as $st) {
            if (count($parts) >= 2) break;
            if (in_array((string)$st['landscape'], $lands, true)) $parts[] = 'right at ' . $st['name'] . ' (' . $st['rname'] . ')';
            elseif (in_array(stop_near_land($st), $lands, true)) $parts[] = '2 steps out from ' . $st['name'] . ' (' . $st['rname'] . ')';
        }
        foreach (q("SELECT r.id, r.gnomish_name, z.zone_num FROM zones z JOIN regions r ON r.id = z.region_id WHERE z.landscape IN ($in) ORDER BY r.min_level, z.zone_num, r.gnomish_name", $lands)->fetchAll() as $zr) {
            if (isset($seen[(int)$zr['id']])) continue;
            $label = explore_zone_steps((int)$zr['zone_num']);
            if ($label === '') continue;
            $seen[(int)$zr['id']] = true;
            $parts[] = 'in ' . $zr['gnomish_name'] . ' (' . $label . ')';
            if (count($parts) >= 4) break;
        }
        if ($parts) $h .= ' Look ' . (count($parts) > 1 ? implode(', ', array_slice($parts, 0, -1)) . ' or ' . end($parts) : $parts[0]) . '.';
    }
    return $cache[$key] = $h !== '' ? $h : (string)$entry['hint'];
}

/** v0.7.72: link the first mention of Glossary words on a page (text only, never inside tags or links; at most 6). */
function almanac_glossary_links(string $html): string
{
    require_once __DIR__ . '/glossary.php';
    static $terms = null;
    if ($terms === null) {
        $terms = [];
        foreach (array_keys(GLOSSARY) as $t) if (mb_strlen($t) >= 5) $terms[$t] = 'gt-' . strtolower((string)preg_replace('/[^a-z0-9]+/i', '-', $t));
        uksort($terms, fn($a, $b) => mb_strlen($b) <=> mb_strlen($a));   // longest first ("soil life" before "soil")
    }
    $parts = preg_split('/(<[^>]+>)/u', $html, -1, PREG_SPLIT_DELIM_CAPTURE);
    $used = []; $n = 0; $inA = 0;
    foreach ($parts as $i => $part) {
        if ($part === '' ) continue;
        if ($part[0] === '<') { if (preg_match('#^<a\b#i', $part)) $inA++; elseif (preg_match('#^</a>#i', $part)) $inA = max(0, $inA - 1); continue; }
        if ($inA || $n >= 6) continue;
        foreach ($terms as $t => $id) {
            if (isset($used[$t]) || $n >= 6) continue;
            $re = '/(?<![\p{L}\p{N}])(' . preg_quote($t, '/') . 's?)(?![\p{L}\p{N}])/iu';
            if (preg_match($re, $part)) {
                $part = preg_replace($re, '<a class="glink" href="' . e(url('book.php?ch=Glossary')) . '#' . $id . '">$1</a>', $part, 1);
                $used[$t] = true; $n++;
                // don't link inside the link we just made: split again on the next pass
                $sub = preg_split('/(<[^>]+>)/u', $part, -1, PREG_SPLIT_DELIM_CAPTURE);
                $part = '';
                $innerA = 0;
                foreach ($sub as $sp) { $part .= $sp; }
                break;
            }
        }
        $parts[$i] = $part;
    }
    return implode('', $parts);
}
