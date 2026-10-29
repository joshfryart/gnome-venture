<?php
declare(strict_types=1);

/**
 * v0.7.65: Wren's Journey. One chapter per region (a regional questline), started when you first reach the region.
 * Each chapter: a few things to do there (ticked off automatically from what you've done), then a local project
 * built in stages (hand in materials), then Wren's letter, the region's guide and a lasting benefit for that region.
 *
 * Task kinds (quest_tasks.kind):
 *   visit          reach the region (always done once the chapter has started)
 *   grow   spec = staple|any          qty = how many different crops of the region you've harvested
 *   friend         qty = friendship level (1 = Acquaintance) with any of the region's townsfolk
 *   find           qty = hidden places (side-path villages and landmarks) of the region you've found
 *   stage  spec = "item:slug:3,coins:100,meal:2,fine:1"   hand in, in order, once the other tasks are done
 * Benefits (quest_chapters.benefit): native_plus:N · sell_bonus:N · free_travel · weekly_crate
 */

require_once __DIR__ . '/friends.php';

const JOURNEY_PROLOGUE = "Years ago, Wren's teacher, old Tansy Greenwhistle, set out to grow a seed from every corner of the Hollow, and never came home. "
    . "Her field notes stop with one line: [i]\"The Hollowheart sleeps where the reef sings.\"[/i]\n\n"
    . "Wren is finishing Tansy's field guide, one region at a time, and hopes to learn what became of her (and her seed). Help the folk of each region, "
    . "and Wren will send you a letter, that region's gardening guide, and a little something besides.";

/** The starting content: [slug, region code, sort, title, npc slug, intro, outro, project, icon, benefit, benefit text, coins, xp, item slug, qty, title reward, tasks]. */
function journey_seed(): array
{
    return [
        ['maplewold-sugar-shack', 'NA', 1, 'The Sugar Shack', 'clover-puddlejump',
         "Clover Puddlejump wrings her hat in the Maplewold market. \"The old sugar shack's roof fell in over the winter! No shack, no maple syrup for the spring fair.\" "
         . "Get to know the Maplewold first: grow its crops, meet its folk and find one of its hidden places. Then help Clover rebuild.",
         "[i]Dear friend,[/i]\n\nClover sent me a jar of the first syrup from the mended shack: sticky, golden, and gone in a day. Thank you!\n\n"
         . "I found Tansy's old notebook tucked behind the shack's sap buckets. One page has a pressed maize leaf and the word [b]\"south\"[/b]. Maizehollow next, I think. "
         . "I've enclosed my notes on the Maplewold so you can grow all of its crops properly.\n\n[i]Wren[/i]",
         'Sugar Shack', '🍁', 'native_plus:10', 'Native crops in your Maplewold gardens grow 10% faster.', 400, 150, 'plain-compost', 5, '',
         [['visit', '', 1, 'Reach the Maplewold'], ['grow', 'staple', 2, 'Harvest 2 of the Maplewold’s staple crops'],
          ['friend', '', 1, 'Get to know one of the Maplewold’s townsfolk (Acquaintance)'], ['find', '', 1, 'Find one of the Maplewold’s hidden places off the road'],
          ['stage', 'item:flint:3,coins:50', 1, 'Clear the rubble (3 Flint, 50 Petals)'],
          ['stage', 'item:timber-plank:2', 1, 'New roof beams (2 Timber Planks, made in Crafting → Building)'],
          ['stage', 'item:rope:1,coins:100', 1, 'Hang the sap buckets (1 Rope, 100 Petals)']]],
        ['maizehollow-granary', 'CA', 2, 'The Granary', 'hazel-dewberry',
         "In Maizehollow the corn is high, but the granary's walls have cracked and mice are feasting. Hazel Dewberry needs builders. "
         . "Grow Maizehollow's crops, make a friend and find a hidden corner of the region first.",
         "[i]Dear friend,[/i]\n\nThe new granary is the talk of the plaza, and the traders there say they'll pay a little more for anything you bring them.\n\n"
         . "Tansy passed through here too. A trader remembers a white-haired gnome asking about [b]\"mist that never lifts\"[/b]. That can only mean Mistmoor. "
         . "My Maizehollow notes are enclosed.\n\n[i]Wren[/i]",
         'Granary', '🌽', 'sell_bonus:10', 'Shops in Maizehollow pay 10% more for what you sell.', 900, 400, 'worm-castings', 5, '',
         [['visit', '', 1, 'Reach Maizehollow'], ['grow', 'staple', 2, 'Harvest 2 of Maizehollow’s staple crops'],
          ['friend', '', 1, 'Get to know one of Maizehollow’s townsfolk (Acquaintance)'], ['find', '', 1, 'Find one of Maizehollow’s hidden places'],
          ['stage', 'item:building-stone:4,coins:200', 1, 'Rebuild the walls (4 Dressed Stone, 200 Petals)'],
          ['stage', 'item:timber-plank:3,item:rope:2', 1, 'Raise the roof (3 Timber Planks, 2 Rope)'],
          ['stage', 'meal:2', 1, 'Feed the builders (2 home-cooked meals)']]],
        ['mistmoor-footbridge', 'NWE', 3, 'The Footbridge', 'willow-rootstock',
         "The footbridge over Mistmoor's peat stream washed away in the autumn floods. Willow Rootstock has to wade across every morning, and she is not amused. "
         . "Find your way around Mistmoor, then help build a new bridge.",
         "[i]Dear friend,[/i]\n\nWillow walked me over the new bridge herself, very proudly and very slowly. The ferrymen say you can come and go from Mistmoor for free now, as thanks.\n\n"
         . "Under the old bridge stones we found a tin box of Tansy's: seed packets, all empty, labelled with island names. [b]The Sunsprinkle Isles[/b]! "
         . "My Mistmoor notes are enclosed. You've earned a proper name for yourself, too: the folk here call you [b]Field Hand[/b].\n\n[i]Wren[/i]",
         'Footbridge', '🌉', 'free_travel', 'Fast travel to Mistmoor costs nothing.', 1300, 600, 'rich-loam', 3, 'Field Hand',
         [['visit', '', 1, 'Reach Mistmoor'], ['grow', 'staple', 2, 'Harvest 2 of Mistmoor’s staple crops'],
          ['friend', '', 1, 'Get to know one of Mistmoor’s townsfolk (Acquaintance)'], ['find', '', 2, 'Find two of Mistmoor’s hidden places'],
          ['stage', 'item:timber-plank:5,item:rope:3', 1, 'Lay the deck (5 Timber Planks, 3 Rope)'],
          ['stage', 'item:building-stone:4,coins:300', 1, 'Set the stone piers (4 Dressed Stone, 300 Petals)'],
          ['stage', 'meal:3', 1, 'A feast on the new bridge (3 home-cooked meals)']]],
        ['sunsprinkle-lighthouse', 'CB', 4, 'The Lighthouse', 'nettle-thornwhistle',
         "The Sunsprinkle lighthouse has gone dark, and the little supply boats won't come in after sunset. Nettle Thornwhistle keeps the lamp, but the tower is crumbling. "
         . "Explore the Isles, then help put the light back.",
         "[i]Dear friend,[/i]\n\nThe light is lit! Nettle says the supply boats will leave a crate for you every week, at the lighthouse steps.\n\n"
         . "From the top of the tower, on a clear night, you can see a faint glow far to the west, over the olive groves of [b]Olivewhistle Shore[/b]. "
         . "Tansy's lamp? I'll meet you there. My notes on the Isles are enclosed.\n\n[i]Wren[/i]",
         'Lighthouse', '🗼', 'weekly_crate', 'A supply crate waits for you at the Sunsprinkle lighthouse once a week.', 1700, 800, 'seed-pearl', 1, '',
         [['visit', '', 1, 'Reach the Sunsprinkle Isles'], ['grow', 'staple', 2, 'Harvest 2 of the Isles’ staple crops'],
          ['friend', '', 1, 'Get to know one of the Isles’ townsfolk (Acquaintance)'], ['find', '', 2, 'Find two of the Isles’ hidden places'],
          ['stage', 'item:building-stone:6,coins:400', 1, 'Shore up the tower (6 Dressed Stone, 400 Petals)'],
          ['stage', 'item:rope:4,item:timber-plank:4', 1, 'New stairs and pulleys (4 Rope, 4 Timber Planks)'],
          ['stage', 'fine:2,meal:3', 1, 'Polish the lens and feed the keepers (2 uncommon or rare finds, 3 home-cooked meals)']]],
    ];
}

/** v0.7.66: places closed (for each gnome) until they finish the chapter: "spot:town-spot-slug,place:location-slug". */
const JOURNEY_LOCKS = ['maplewold-sugar-shack' => 'spot:na-sugarshack,place:lm-na-1-haven-the-sugar-shack'];

/** The unfinished chapter that keeps this town spot ("spot") or place ("place") closed for this gnome, or null. */
function journey_lock(int $uid, string $type, string $slug): ?array
{
    static $locks = null;
    if ($locks === null) {
        $locks = [];
        foreach (q("SELECT * FROM quest_chapters WHERE active = 1 AND locks IS NOT NULL AND locks <> ''")->fetchAll() as $c) {
            foreach (array_filter(array_map('trim', explode(',', (string)$c['locks']))) as $l) $locks[$l] = $c;
        }
    }
    $c = $locks[$type . ':' . $slug] ?? null;
    if (!$c) return null;
    $done = q_val('SELECT 1 FROM user_quests WHERE user_id = ? AND chapter_id = ? AND done_at IS NOT NULL', [$uid, $c['id']]);
    return $done ? null : $c + ['region' => (string)q_val('SELECT gnomish_name FROM regions WHERE id = ?', [$c['region_id']])];
}

/** A short "closed for repairs" note with a link to the chapter. */
function journey_lock_note(array $c, string $what): string
{
    return '<div class="box notice jlock">🚧 <b>' . e($what) . '</b> is closed for repairs. Help rebuild it in Wren’s Journey: '
        . '<a href="' . e(url('book.php?ch=Journey&j=' . (int)$c['id'])) . '">' . e((string)$c['project_icon'] . ' ' . $c['region'] . ': ' . $c['title']) . ' →</a></div>';
}

/** The places a chapter closes until it's finished: its project's town spot, plus any in JOURNEY_LOCKS. */
function journey_default_locks(string $slug): ?string
{
    $l = array_filter(array_map('trim', explode(',', (string)(JOURNEY_LOCKS[$slug] ?? ''))));
    $sp = JOURNEY_SPOTS[$slug] ?? null;
    if ($sp) $l[] = 'spot:' . (is_array($sp) ? $sp[0] : $sp);
    $l = array_values(array_unique($l));
    return $l ? implode(',', $l) : null;
}

/** v0.7.67: make sure a chapter's project place exists in its town square, and that the chapter keeps it closed until finished. */
function journey_ensure_spot(string $chapterSlug, string $town): void
{
    $sp = JOURNEY_SPOTS[$chapterSlug] ?? null;
    if (!$sp) return;
    if (is_array($sp)) {
        [$sslug, $icon, $name, $desc, $act] = $sp;
        $spotId = (int)q_val('SELECT id FROM town_spots WHERE slug = ?', [$sslug]);
        if (!$spotId) {
            $spotId = db_insert('town_spots', ['slug' => $sslug, 'region' => $town, 'kind' => 'special', 'icon' => $icon, 'name' => $name, 'description' => $desc, 'sort_order' => 9, 'active' => 1]);
        }
        [$aslug, $label, $effect, $chance, $stat, $daily, $ok, $fail] = $act;
        if (!q_val('SELECT 1 FROM town_actions WHERE slug = ?', [$aslug])) {
            db_insert('town_actions', ['spot_id' => $spotId, 'slug' => $aslug, 'label' => $label, 'kind' => 'effect', 'effect' => $effect, 'chance' => $chance,
                'stat' => $stat, 'daily' => $daily, 'success_text' => $ok, 'fail_text' => $fail, 'sort_order' => 1, 'active' => 1]);
        }
    }
    // Existing chapters (made before the place existed): add the place to what the chapter keeps closed
    $c = q_one('SELECT id, locks FROM quest_chapters WHERE slug = ?', [$chapterSlug]);
    $need = 'spot:' . (is_array($sp) ? $sp[0] : $sp);
    if ($c && !in_array($need, array_map('trim', explode(',', (string)$c['locks'])), true)) {
        q('UPDATE quest_chapters SET locks = ? WHERE id = ?', [trim((string)$c['locks'] . ',' . $need, ','), $c['id']]);
    }
}

/** Adds any missing chapters (never changes ones that exist, so admin edits stand). */
function ensure_journey(): void
{
    // The finale's gift (v0.7.67): a little Hollowheart tree for the yard
    if (!q_val("SELECT 1 FROM items WHERE slug = 'hollowheart-tree'")) {
        db_insert('items', ['name' => 'Little Hollowheart', 'slug' => 'hollowheart-tree', 'category' => 'decor', 'rarity' => 99, 'base_price' => 5000, 'tradable' => 0,
            'description' => 'A seedling of the Hollowheart, given by Tansy Greenwhistle to the Keeper of the Hollow. It hums very quietly on warm evenings.',
            'effects' => json_encode(['decor' => ['type' => 'ornament', 'w' => 1, 'h' => 1, 'icon' => '💗', 'appeal' => 12, 'bonus' => '']])]);
    }
    foreach (array_merge(journey_seed(), journey_seed2()) as [$slug, $code, $sort, $title, $npc, $intro, $outro, $proj, $icon, $benefit, $btext, $coins, $xp, $item, $qty, $rtitle, $tasks]) {
        $rid = (int)q_val('SELECT id FROM regions WHERE code = ?', [$code]);
        if (!$rid) continue;
        journey_ensure_spot($slug, (string)q_val('SELECT gnomish_name FROM regions WHERE id = ?', [$rid]));
        if (q_val('SELECT 1 FROM quest_chapters WHERE slug = ?', [$slug])) continue;
        $cid = db_insert('quest_chapters', ['locks' => journey_default_locks($slug), 'slug' => $slug, 'region_id' => $rid, 'sort_order' => $sort, 'title' => $title, 'npc_slug' => $npc,
            'intro' => $intro, 'outro' => $outro, 'project_name' => $proj, 'project_icon' => $icon, 'benefit' => $benefit, 'benefit_text' => $btext,
            'reward_coins' => $coins, 'reward_xp' => $xp, 'reward_item_slug' => $item, 'reward_qty' => $qty, 'reward_title' => $rtitle, 'active' => 1]);
        foreach ($tasks as $i => [$kind, $spec, $n, $label]) {
            db_insert('quest_tasks', ['chapter_id' => $cid, 'sort_order' => $i + 1, 'kind' => $kind, 'spec' => $spec, 'qty' => $n, 'label' => $label]);
        }
    }
}

function journey_chapters(): array
{
    static $all = null;
    return $all ??= q('SELECT c.*, r.gnomish_name AS region, r.min_level FROM quest_chapters c JOIN regions r ON r.id = c.region_id
                       WHERE c.active = 1 ORDER BY c.sort_order, c.id')->fetchAll();
}

function journey_tasks(int $chapterId): array
{
    return q('SELECT * FROM quest_tasks WHERE chapter_id = ? ORDER BY sort_order, id', [$chapterId])->fetchAll();
}

/** This gnome's row for a chapter (created when the region has been reached), or null if not started. */
function journey_row(int $uid, array $ch): ?array
{
    $row = q_one('SELECT * FROM user_quests WHERE user_id = ? AND chapter_id = ?', [$uid, $ch['id']]);
    if ($row) return $row;
    if (!q_val('SELECT 1 FROM region_visits WHERE user_id = ? AND region_id = ?', [$uid, $ch['region_id']])) return null;
    try {
        db_insert('user_quests', ['user_id' => $uid, 'chapter_id' => $ch['id'], 'stage' => 0, 'started_at' => now()]);
    } catch (PDOException $e) {
        // made a moment ago
    }
    return q_one('SELECT * FROM user_quests WHERE user_id = ? AND chapter_id = ?', [$uid, $ch['id']]);
}

/** Parse "item:slug:3,coins:100,meal:2" into [[type, slug, qty], …]. */
function journey_needs(string $spec): array
{
    $out = [];
    foreach (array_filter(array_map('trim', explode(',', $spec))) as $part) {
        $p = explode(':', $part);
        if ($p[0] === 'item' && count($p) >= 3) $out[] = ['item', $p[1], max(1, (int)$p[2])];
        elseif (in_array($p[0], ['coins', 'meal', 'fine'], true)) $out[] = [$p[0], '', max(1, (int)($p[1] ?? 1))];
    }
    return $out;
}

/** What a stage needs and what the gnome has: [[label, need, have], …]. */
function journey_need_status(array $u, string $spec): array
{
    require_once __DIR__ . '/rebuild.php';
    $out = [];
    foreach (journey_needs($spec) as $need) {
        [$type, $slug, $qty] = $need;
        $have = $type === 'coins' ? (int)$u['coins'] : array_sum(array_column(rebuild_supply((int)$u['id'], $need), 'qty'));
        $label = match ($type) {
            'item' => (string)(q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug),
            'meal' => 'home-cooked meals or feasts (not snacks)',
            'fine' => 'uncommon or rare finds (any)',
            'coins' => (string)setting('currency_name'),
        };
        $out[] = [$label, $qty, $have];
    }
    return $out;
}

/**
 * Where a gnome stands in a chapter: tasks with progress, the next stage, and whether it can be finished.
 * ['row' => …|null, 'tasks' => [[task, now, goal, done]], 'explore_done' => bool, 'stages_done' => n, 'next_stage' => task|null, 'complete' => bool]
 */
function journey_status(array $u, array $ch): array
{
    $uid = (int)$u['id'];
    $row = journey_row($uid, $ch);
    $rid = (int)$ch['region_id'];
    $out = ['row' => $row, 'tasks' => [], 'explore_done' => true, 'stages_done' => 0, 'next_stage' => null, 'complete' => false];
    $stageNo = 0;
    foreach (journey_tasks((int)$ch['id']) as $t) {
        $goal = max(1, (int)$t['qty']);
        if ($t['kind'] === 'grow') {   // never ask for more crops than the region has
            $avail = (int)q_val('SELECT COUNT(DISTINCT plant_id) FROM plant_regions WHERE region_id = ?' . ($t['spec'] === 'any' || $t['spec'] === '' ? '' : ' AND tier = ' . db()->quote((string)$t['spec'])), [$rid]);
            if ($avail > 0) $goal = min($goal, $avail);
        }
        if ($t['kind'] === 'find') {   // nor more hidden places than it has
            $avail = (int)q_val("SELECT COUNT(DISTINCT l.id) FROM locations l JOIN routes r ON r.b_id = l.id AND r.kind = 'side' WHERE l.region_id = ?", [$rid]);
            if ($avail > 0) $goal = min($goal, $avail);
        }
        if ($t['kind'] === 'stage') {
            $stageNo++;
            $done = $row && (int)$row['stage'] >= $stageNo;
            if ($done) $out['stages_done']++;
            elseif (!$out['next_stage']) $out['next_stage'] = $t + ['_n' => $stageNo];
            $out['tasks'][] = [$t, $done ? 1 : 0, 1, $done];
            continue;
        }
        $now = match ($t['kind']) {
            'visit' => $row ? 1 : 0,
            'grow' => (int)q_val('SELECT COUNT(DISTINCT pr.plant_id) FROM plant_regions pr JOIN user_plant_knowledge k ON k.plant_id = pr.plant_id AND k.user_id = ? AND k.knowledge > 0
                                  WHERE pr.region_id = ?' . ($t['spec'] === 'any' || $t['spec'] === '' ? '' : ' AND pr.tier = ' . db()->quote((string)$t['spec'])), [$uid, $rid]),
            'friend' => (int)q_val('SELECT COUNT(*) FROM npc_friends f JOIN npcs n ON n.id = f.npc_id JOIN town_spots s ON s.id = n.fav_spot_id
                                    WHERE f.user_id = ? AND s.region = ? AND f.points >= ?', [$uid, $ch['region'], FRIEND_LEVELS[min(count(FRIEND_LEVELS) - 1, $goal)][0] ?? 1]) > 0 ? $goal : 0,
            'find' => journey_found($uid, $rid),
            default => 0,
        };
        $done = $now >= $goal;
        if (!$done) $out['explore_done'] = false;
        $out['tasks'][] = [$t, min($now, $goal), $goal, $done];
    }
    $out['complete'] = $row && $out['explore_done'] && !$out['next_stage'];
    return $out;
}

/** Hidden places (side-path villages and landmarks) of a region this gnome has found. */
function journey_found(int $uid, int $regionId): int
{
    require_once __DIR__ . '/roads.php';
    $n = 0;
    foreach (q("SELECT DISTINCT l.* FROM locations l JOIN routes r ON r.b_id = l.id AND r.kind = 'side' WHERE l.region_id = ?", [$regionId])->fetchAll() as $l) {
        if (place_known($uid, $l)) $n++;
    }
    return $n;
}

/** Hand in the next project stage. */
function journey_hand_in(array $u, int $chapterId): array
{
    require_once __DIR__ . '/rebuild.php';
    $uid = (int)$u['id'];
    $ch = null;
    foreach (journey_chapters() as $c) if ((int)$c['id'] === $chapterId) $ch = $c;
    if (!$ch) return [false, 'There’s no such chapter.'];
    $st = journey_status($u, $ch);
    if (!$st['row']) return [false, 'Reach ' . $ch['region'] . ' first.'];
    if ($st['row']['done_at']) return [false, 'You’ve already finished this chapter.'];
    if (!$st['explore_done']) return [false, 'Get to know ' . $ch['region'] . ' first (the tasks above).'];
    $stage = $st['next_stage'];
    if (!$stage) return [false, 'Every stage is done. Finish the chapter!'];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    foreach (journey_need_status($u, (string)$stage['spec']) as [$label, $need, $have]) {
        if ($have < $need) return [false, 'You need ' . $need . ' × ' . $label . ' (you have ' . $have . ').'];
    }
    db()->beginTransaction();
    foreach (journey_needs((string)$stage['spec']) as $need) {
        [$type, , $qty] = $need;
        if ($type === 'coins') {
            if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$qty, $uid, $qty])->rowCount() !== 1) { db()->rollBack(); return [false, 'You need ' . money($qty) . '.']; }
            continue;
        }
        $left = $qty;
        foreach (rebuild_supply($uid, $need) as $it) {
            $take = min($left, (int)$it['qty']);
            if ($take > 0 && !give_item($uid, (int)$it['id'], -$take)) { db()->rollBack(); return [false, 'Something went missing from your satchel.']; }
            $left -= $take;
            if ($left <= 0) break;
        }
        if ($left > 0) { db()->rollBack(); return [false, 'You don’t have enough for this stage.']; }
    }
    if (q('UPDATE user_quests SET stage = stage + 1 WHERE id = ? AND stage = ?', [$st['row']['id'], (int)$stage['_n'] - 1])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That stage is already done.'];
    }
    db()->commit();
    $nextSt = journey_status(q_one('SELECT * FROM users WHERE id = ?', [$uid]) ?: $u, $ch);   // v1.0.0: say what comes next
    $tail = $nextSt['complete'] ? ' Everything is built: finish the chapter!' : ($nextSt['next_stage'] ? ' Next: ' . preg_replace('/\s*\(.*\)$/', '', (string)$nextSt['next_stage']['label']) . '.' : '');
    return [true, $ch['project_icon'] . ' ' . preg_replace('/\s*\(.*\)$/', '', (string)$stage['label']) . ': done!' . $tail];
}

/** Finish a chapter: rewards, the region's guide (or Petals if already studied), Wren's letter. */
function journey_finish(array $u, int $chapterId): array
{
    $uid = (int)$u['id'];
    $ch = null;
    foreach (journey_chapters() as $c) if ((int)$c['id'] === $chapterId) $ch = $c;
    if (!$ch) return [false, 'There’s no such chapter.'];
    $st = journey_status($u, $ch);
    if (!$st['complete']) return [false, 'There’s still something to do in this chapter.'];
    db()->beginTransaction();
    if (q('UPDATE user_quests SET done_at = ? WHERE id = ? AND done_at IS NULL', [now(), $st['row']['id']])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You’ve already finished this chapter.'];
    }
    $lines = [];
    if ((int)$ch['reward_coins'] > 0) { give_petals((int)$uid, (int)$ch['reward_coins']); $lines[] = '+' . money((int)$ch['reward_coins']); }
    if ($ch['reward_item_slug'] && ($iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$ch['reward_item_slug']]))) {
        give_item($uid, $iid, max(1, (int)$ch['reward_qty']));
        $lines[] = '+' . max(1, (int)$ch['reward_qty']) . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$iid]);
    }
    // The region's guide: studied straight away
    $code = strtolower((string)q_val('SELECT code FROM regions WHERE id = ?', [$ch['region_id']]));
    $key = 'region:' . $code;
    if (q_val('SELECT 1 FROM user_guides WHERE user_id = ? AND guide_key = ?', [$uid, $key])) {
        $extra = intdiv((int)setting('guide_price'), 2);
        q('UPDATE users SET coins = coins + ? WHERE id = ?', [$extra, $uid]);
        $lines[] = '+' . money($extra) . ' (you’d already studied ' . $ch['region'] . ')';
    } else {
        db_insert('user_guides', ['user_id' => $uid, 'guide_key' => $key, 'read_at' => now()]);
        $lines[] = '📗 ' . $ch['region'] . ' studied: all its crops now grow at full speed and harvest';
    }
    if ($ch['reward_title']) $lines[] = '🎩 New title: “' . $ch['reward_title'] . '” (choose it in your Almanac → Milestones)';
    db()->commit();
    // v0.9.1: chapters pay only journey_xp_percent of the listed XP
    $jxp = (int)round((int)$ch['reward_xp'] * (int)setting('journey_xp_percent') / 100);
    if ($jxp > 0) { add_xp($uid, $jxp, 'Journey chapters'); $lines[] = '+' . $jxp . ' XP'; }
    $lines[] = $ch['project_icon'] . ' ' . $ch['benefit_text'];
    // Where the story goes next: the chapter after this one (what Wren's letter names), not the first one you haven't started
    $nx = null;
    $all = journey_chapters();
    foreach ($all as $i => $c) if ((int)$c['id'] === $chapterId) { $nx = $all[$i + 1] ?? null; break; }
    if ($nx) {
        $started = journey_row($uid, $nx);
        $lines[] = '🧭 Next chapter: ' . $nx['region'] . ($started ? '.' : '. Wren’s letter says how to get there.');
    }
    prize('🧭', 'Chapter complete: ' . $ch['title'], 'Wren has written to you. Read the letter in your Almanac → Journey.', $lines);
    return [true, ''];
}

/** v0.7.68: what a chapter is waiting on: 'finish' (ready to finish), 'stage' (next stage can be handed in now), or ''. */
function journey_ready(array $u, array $st): string
{
    $row = $st['row'];
    if (!$row || $row['done_at'] || !$st['explore_done']) return '';
    if ($st['complete']) return 'finish';
    if ($st['next_stage']) {
        foreach (journey_need_status($u, (string)$st['next_stage']['spec']) as [, $need, $have]) if ($have < $need) return '';
        return 'stage';
    }
    return '';
}

/** Titles earned from finished chapters (offered alongside milestone titles). */
function journey_titles(int $uid): array
{
    return q("SELECT DISTINCT c.reward_title FROM user_quests uq JOIN quest_chapters c ON c.id = uq.chapter_id
              WHERE uq.user_id = ? AND uq.done_at IS NOT NULL AND c.reward_title IS NOT NULL AND c.reward_title <> ''", [$uid])->fetchAll(PDO::FETCH_COLUMN);
}

/** A finished chapter's benefit for a region: the number after "type:", true for ones without a number, or null. */
function journey_benefit(int $uid, string $type, int $regionId)
{
    static $cache = [];
    if (!isset($cache[$uid])) {
        $cache[$uid] = [];
        foreach (q('SELECT c.region_id, c.benefit FROM user_quests uq JOIN quest_chapters c ON c.id = uq.chapter_id
                    WHERE uq.user_id = ? AND uq.done_at IS NOT NULL AND c.active = 1', [$uid])->fetchAll() as $r) {
            $p = explode(':', (string)$r['benefit']);
            $cache[$uid][(int)$r['region_id']][$p[0]] = isset($p[1]) ? (int)$p[1] : true;
        }
    }
    return $cache[$uid][$regionId][$type] ?? null;
}

/** v0.7.89: when the weekly crates stop (journey_crate_weeks after the chapter is finished; 0 = never). */
function journey_crates_end(array $row): int
{
    $weeks = (int)setting('journey_crate_weeks');
    return $weeks > 0 ? ts($row['done_at']) + $weeks * 7 * 86400 : PHP_INT_MAX;
}

/** The weekly crate (benefit weekly_crate). */
function journey_crate(array $u, int $chapterId): array
{
    $uid = (int)$u['id'];
    $ch = q_one('SELECT * FROM quest_chapters WHERE id = ? AND active = 1', [$chapterId]);
    if (!$ch || $ch['benefit'] !== 'weekly_crate') return [false, 'There’s no crate here.'];
    $ch['region'] = (string)q_val('SELECT gnomish_name FROM regions WHERE id = ?', [$ch['region_id']]);
    $row = q_one('SELECT * FROM user_quests WHERE user_id = ? AND chapter_id = ? AND done_at IS NOT NULL', [$uid, $chapterId]);
    if (!$row) return [false, 'Finish the chapter first.'];
    if (journey_crates_end($row) <= time()) return [false, 'The supply crates have stopped coming. Thank you for everything you built.'];
    $next = $row['crate_at'] ? ts($row['crate_at']) + 7 * 86400 : 0;
    if ($next > time()) return [false, 'The next crate arrives in ' . nice_time($next - time()) . '.'];
    if (q('UPDATE user_quests SET crate_at = ? WHERE id = ? AND (crate_at IS NULL OR crate_at = ?)', [now(), $row['id'], $row['crate_at']])->rowCount() !== 1) {
        return [false, 'Already collected.'];
    }
    require_once __DIR__ . '/events.php';
    $lines = apply_event_effect(q_one('SELECT * FROM users WHERE id = ?', [$uid]), 'rand:uncommon+rand:food+coins:150-300');
    prize('📦', 'A crate from ' . $ch['region'], 'Left for you at the ' . $ch['project_name'] . ', with your name chalked on the lid.', $lines);
    return [true, ''];
}

/** The chapter a gnome is on (first started and unfinished), for the Today page. */
function journey_current(array $u): ?array
{
    foreach (journey_chapters() as $ch) {
        $row = journey_row((int)$u['id'], $ch);
        if ($row && !$row['done_at']) return $ch;
    }
    return null;
}

/**
 * v1.0.0 wave 3: the ONE next thing to do in a chapter, in plain words: [text, link]. Null when the chapter is finished.
 * Used at the top of the chapter page, on the Today card and after a stage is handed in, so "what now?" always has an answer.
 */
function journey_next_hint(array $u, array $ch, array $st): ?array
{
    $row = $st['row'];
    $book = 'book.php?ch=Journey&j=' . (int)$ch['id'];
    if (!$row) return ['Walk to ' . $ch['region'] . ' to start this chapter (it suits gnome level ' . (int)$ch['min_level'] . ').', 'world.php'];
    if ($row['done_at']) return null;
    if (!$st['explore_done']) {
        foreach ($st['tasks'] as [$t, $now, $goal, $done]) {
            if ($done || $t['kind'] === 'stage') continue;
            $how = ['grow' => 'Plant and harvest it in any garden; the region’s market sells the seeds.', 'friend' => 'Chat with them and give a gift from their villager page.',
                    'find' => 'At a road stop in the region, choose Wander off the path.', 'visit' => 'Walk there from a neighbouring region.'][$t['kind']] ?? '';
            return [preg_replace('/\s*\(.*\)$/', '', (string)$t['label']) . ($goal > 1 ? ' (' . $now . ' of ' . $goal . ' so far)' : '') . '. ' . $how, $t['kind'] === 'grow' ? 'garden.php' : ($t['kind'] === 'friend' ? 'town.php?view=villagers' : 'world.php')];
        }
    }
    if ($st['complete']) return ['Everything is built. Finish the chapter and read Wren’s letter.', $book];
    if ($stage = $st['next_stage']) {
        $missing = [];
        foreach (journey_need_status($u, (string)$stage['spec']) as [$label, $need, $have]) if ($have < $need) $missing[] = ($need - $have) . ' more ' . $label;
        $name = preg_replace('/\s*\(.*\)$/', '', (string)$stage['label']);
        return $missing ? ['Next stage: ' . $name . '. Still needed: ' . implode(', ', $missing) . '.', $book] : ['Next stage: ' . $name . '. You have everything: hand it in!', $book];
    }
    return null;
}

/** v1.0.0 wave 3: the first chapter that has not started (its region not reached yet), for "what next" lines. */
function journey_next_locked(array $u): ?array
{
    foreach (journey_chapters() as $ch) if (!journey_row((int)$u['id'], $ch)) return $ch;
    return null;
}


/** Gardening guides cost the guide_price setting (items and every shop's stock). Safe to repeat; cheap when nothing changes. */
function ensure_guide_price(): void
{
    $p = max(1, (int)setting('guide_price'));
    $hi = (int)round($p * 1.25);
    q("UPDATE items SET base_price = ? WHERE category = 'guide' AND base_price <> ?", [$p, $p]);
    q("UPDATE shop_stock SET price_min = ?, price_max = ?, current_price = CASE WHEN current_price < ? OR current_price > ? THEN ? ELSE current_price END
       WHERE item_id IN (SELECT id FROM items WHERE category = 'guide') AND (price_min <> ? OR price_max <> ?)", [$p, $hi, $p, $hi, $p, $p, $hi]);
}

/**
 * v0.7.67: every chapter's project is a place in that region's town square: a new one built for the chapter, or an
 * existing one the story says is broken. Either way it stays closed for each gnome until they finish the chapter.
 * [chapter slug => [spot slug, icon, name, description, [action slug, label, effect, chance %, stat, uses a day, success text, fail text]] or 'existing']
 */
const JOURNEY_SPOTS = [
    'maplewold-sugar-shack' => 'na-sugarshack',
    'maizehollow-granary' => ['ma-granary', '🌽', 'The Granary', 'A round stone granary with a fresh thatched roof, full to the rafters with corn. The mice are furious.',
        ['ma-weigh', 'Help weigh the harvest', 'coins:20-40+xp:6', 100, '', 2, 'You heave sacks onto the big brass scales. The granary-keeper pays you in Petals and roasted corn.', '']],
    'mistmoor-footbridge' => ['mm-footbridge', '🌉', 'The Footbridge', 'A sturdy new footbridge over the peat stream, with a little bench in the middle for watching the mist roll by.',
        ['mm-sticks', 'Race sticks off the bridge', 'rand:forage+xp:5', 60, 'luck', 2, 'Your stick wins by a whisker, and something shiny bobs up after it!', 'Your stick gets stuck in the reeds. Next time.']],
    'sunsprinkle-lighthouse' => ['ss-lighthouse', '🗼', 'The Lighthouse', 'A tall white lighthouse on the point, its great lamp turning slowly. You can see half the Isles from the top.',
        ['ss-climb', 'Climb to the lamp room', 'tbuff:sense:2:60+xp:6', 100, '', 1, 'Two hundred steps, one huge view. Your eyes feel sharper for a while.', '']],
    'olivewhistle-windmill' => ['ow-windmill', '🌬️', 'The Hill Windmill', 'A whitewashed windmill on the hill above the olive groves, its new canvas sails turning in the sea breeze.',
        ['ow-grind', 'Help grind the flour', 'coins:30-60+xp:8', 100, '', 2, 'Flour everywhere, mostly on you. The miller pays you and gives you a warm roll.', '']],
    'rainroot-jetty' => 'rr-canoe',
    'birchbramble-barn' => ['bb-barn', '🛖', 'The Drying Barn', 'A long barn of silver birch logs, hung with strings of plums and bundles of buckwheat drying in the wind.',
        ['bb-turn', 'Turn the drying plums', 'rand:food+xp:8', 100, '', 2, 'Sticky fingers, happy farmers. They slip you something tasty for your trouble.', '']],
    'dunewhisper-waterwheel' => 'dw-oasis',
    'blossomreach-bridge' => 'br-koi',
    'spicepeak-terraces' => ['sp-terraces', '⛰️', 'The Tea Terraces', 'Green terraces climb the mountainside in steps, held up by new dry-stone walls. Pickers sing as they work.',
        ['sp-pick', 'Pick tea on the terraces', 'rand:forage+xp:10', 70, 'sense', 2, 'Only the top two leaves and a bud: you get the knack, and find something besides.', 'You pick a basket of mostly stalks. The pickers laugh kindly.']],
    'monsoon-boathouse' => ['mt-boathouse', '🛶', 'The Stilt Boathouse', 'A boathouse on tall stilts over the flooded paddies, with long canoes tied below and lanterns along the walkway.',
        ['mt-paddle', 'Paddle the flooded paddies', 'rand:forage+xp:12', 70, 'nimble', 2, 'You glide between the rice stalks and spot something worth keeping.', 'You paddle in a circle for a while. The ducks are unimpressed.']],
    'greatcanopy-storytree' => 'gc-story',
    'thornacre-pump' => 'ts-lookout',
    'coralscatter-reefgarden' => ['cs-reefgarden', '🪸', 'Tansy’s Reef Garden', 'A garden that runs from the beach into the shallows: coral beds, sea-grass rows, and in the middle, one small tree with a heart-shaped seed pod. Listen closely and the reef hums.',
        ['cs-tend', 'Tend the singing reef', 'rand:rare+xp:20', 100, '', 1, 'Tansy shows you how to coax the coral. The reef hums a little louder, and leaves you a gift.', '']],
];

/** v0.7.67: chapters 5–14 (same format as journey_seed()). */
function journey_seed2(): array
{
    $mid = fn(int $stone, int $wood, int $rope, int $coins, int $meals, int $fine) => [
        ['stage', 'item:building-stone:' . $stone . ',coins:' . $coins, 1, 'Foundations (' . $stone . ' Dressed Stone, ' . number_format($coins) . ' Petals)'],
        ['stage', 'item:timber-plank:' . $wood . ',item:rope:' . $rope, 1, 'Frame and fittings (' . $wood . ' Timber Planks, ' . $rope . ' Rope)'],
        ['stage', 'meal:' . $meals . ',fine:' . $fine, 1, 'Feed the builders and add the finishing touches (' . $meals . ' home-cooked meals, ' . $fine . ' uncommon or rare finds)'],
    ];
    $know = fn(string $r, int $grow, int $friend, int $find) => [
        ['visit', '', 1, 'Reach ' . $r], ['grow', 'staple', $grow, 'Harvest ' . $grow . ' of ' . $r . '’s staple crops'],
        ['friend', '', $friend, 'Make a ' . ($friend >= 2 ? 'friend' : 'new acquaintance') . ' among ' . $r . '’s townsfolk' . ($friend >= 2 ? ' (Friend)' : ' (Acquaintance)')],
        ['find', '', $find, 'Find ' . $find . ' of ' . $r . '’s hidden places'],
    ];
    $sig = "\n\n[i]Wren[/i]";
    return [
        ['olivewhistle-windmill', 'SE', 5, 'The Hill Windmill', 'dew-dewberry',
         "The glow Wren saw from the lighthouse came from the hill above Olivewhistle Shore, where the old windmill stands. Its sails have rotted to rags, and Dew Dewberry has nowhere to grind the village flour. "
         . "Get to know the Shore, then help put the windmill back to work.",
         "[i]Dear friend,[/i]\n\nThe mill sails turn again, and the village had bread by sunset. In the loft we found the glow: Tansy's old lantern, still half full of oil, hung where any boat could see it.\n\n"
         . "Tied to it was a note in her hand: [i]\"Follow the river that runs through the rainforest.\"[/i] That's the Rainroot Reaches. I've enclosed my notes on the Shore." . $sig,
         'Hill Windmill', '🌬️', 'native_plus:10', 'Native crops in your Olivewhistle Shore gardens grow 10% faster.', 2200, 1000, 'rich-loam', 5, '',
         array_merge($know('Olivewhistle Shore', 2, 1, 2), $mid(6, 6, 4, 500, 3, 2))],
        ['rainroot-jetty', 'SA', 6, 'The Canoe Jetty', 'rowan-burrowman',
         "The rainy season tore the canoe jetty at the River Landing clean away. Rowan Burrowman says nobody can paddle the river until it's rebuilt, and the River Landing is closed. "
         . "Learn the ways of the Reaches, then help build a new jetty.",
         "[i]Dear friend,[/i]\n\nThe first canoe off the new jetty carried me upriver to an old trading post. The trader there remembered Tansy well: she swapped seeds for a map drawn on birch bark, of [b]the steppes far to the north-east[/b].\n\n"
         . "The river folk say you can come and go from the Reaches for free now. And you've earned a new name among them: [b]Pathfinder[/b]. My Rainroot notes are enclosed." . $sig,
         'Canoe Jetty', '🛶', 'free_travel', 'Fast travel to the Rainroot Reaches costs nothing.', 2600, 1300, 'worm-castings', 8, 'Pathfinder',
         array_merge($know('the Rainroot Reaches', 2, 1, 2), $mid(6, 8, 5, 600, 3, 2))],
        ['birchbramble-barn', 'EE', 7, 'The Drying Barn', 'ginger-thornwhistle',
         "Birchbramble's drying barn burned down in a lightning storm, and the plums and buckwheat are rotting in the rain. Ginger Thornwhistle is doing her best with washing lines. "
         . "Get to know the Steppe, then help raise a new barn.",
         "[i]Dear friend,[/i]\n\nThe barn smells of plums and smoke and new wood. The traders say they'll pay a little more for anything you bring them now.\n\n"
         . "Among the barn's old ashes I found an amber bead with a grain of desert sand caught inside. Tansy carried amber everywhere. Next, [b]the Dunewhisper[/b]. My notes on the Steppe are enclosed." . $sig,
         'Drying Barn', '🛖', 'sell_bonus:10', 'Shops in Birchbramble Steppe pay 10% more for what you sell.', 3000, 1600, 'seed-pearl', 1, '',
         array_merge($know('Birchbramble Steppe', 3, 1, 2), $mid(8, 8, 5, 700, 4, 2))],
        ['dunewhisper-waterwheel', 'MENA', 8, 'The Oasis Waterwheel', 'holly-barkley',
         "The waterwheel over the Oasis Well has collapsed, and the well is closed until it's mended. Holly Barkley is carrying water by the bucket for the whole bazaar. "
         . "Find your feet in the Dunewhisper, then help rebuild the wheel.",
         "[i]Dear friend,[/i]\n\nThe wheel creaks round and the gardens around the oasis are drinking deep. The gardeners say crops do better there now.\n\n"
         . "On the oldest well stone someone scratched a tiny cherry blossom and the letters [b]T.G.[/b] Tansy Greenwhistle! Blossoms mean [b]Blossomreach[/b]. My desert notes are enclosed." . $sig,
         'Oasis Waterwheel', '💧', 'native_plus:10', 'Native crops in your Dunewhisper gardens grow 10% faster.', 3600, 2000, 'desert-glass', 1, '',
         array_merge($know('the Dunewhisper', 3, 1, 2), $mid(8, 10, 6, 800, 4, 3))],
        ['blossomreach-bridge', 'EA', 9, 'The Red Bridge', 'fennick-barkley',
         "The red bridge over the koi pond has rotted through, and the pond is closed until it's safe. Fennick Barkley worries the koi miss their visitors. "
         . "Get to know Blossomreach, then help build the bridge anew.",
         "[i]Dear friend,[/i]\n\nThe koi gathered under the new bridge as if to say thank you. The gardeners will leave you a crate of good things every week.\n\n"
         . "In the teahouse I was handed a letter that had waited eleven years: Tansy asking for a pressed tea leaf from [b]the mountain gardens of Spicepeak[/b]. "
         . "You've walked a long way with me. From now on I'll sign my letters to my [b]Companion[/b]." . $sig,
         'Red Bridge', '🎏', 'weekly_crate', 'The Blossomreach gardeners leave you a crate every week.', 4200, 2500, 'rich-loam', 8, 'Wren’s Companion',
         array_merge($know('Blossomreach', 3, 2, 3), $mid(10, 10, 6, 1000, 4, 3))],
        ['spicepeak-terraces', 'CSA', 10, 'The Tea Terraces', 'sage-dewberry',
         "A landslide swept away the old tea terraces on Spicepeak's slopes. Sage Dewberry wants to build them back with proper dry-stone walls. "
         . "Learn the mountain's ways, then help build the terraces.",
         "[i]Dear Companion,[/i]\n\nTea is growing again on the terraces, and gardens up here grow faster for it.\n\n"
         . "The monks at the Cloud Monastery kept a page of Tansy's for safekeeping: a drawing of a seed shaped like a heart, and the words [i]\"it wants warm water and rain\"[/i]. "
         . "Warm water and rain: [b]the Monsoon Tangle[/b]. My Spicepeak notes are enclosed." . $sig,
         'Tea Terraces', '⛰️', 'native_plus:10', 'Native crops in your Spicepeak gardens grow 10% faster.', 5000, 3000, 'edelweiss', 1, '',
         array_merge($know('Spicepeak', 3, 2, 3), $mid(12, 8, 6, 1200, 5, 3))],
        ['monsoon-boathouse', 'SEA', 11, 'The Stilt Boathouse', 'moss-petalwing',
         "The monsoon floods knocked the old boathouse off its stilts. Without it, Moss Petalwing can't get the canoes out to the paddies. "
         . "Find your way around the Tangle, then help build a boathouse that will stand.",
         "[i]Dear Companion,[/i]\n\nThe canoes are out on the paddies again, and the boat folk will ferry you here for nothing.\n\n"
         . "An old ferrywoman told me Tansy sailed west from here years ago, [b]to the great forest where the drums never stop[/b]: the Greatcanopy. My notes on the Tangle are enclosed." . $sig,
         'Stilt Boathouse', '🛶', 'free_travel', 'Fast travel to the Monsoon Tangle costs nothing.', 5800, 3600, 'firefly-glow', 2, '',
         array_merge($know('the Monsoon Tangle', 3, 2, 3), $mid(12, 14, 8, 1400, 5, 3))],
        ['greatcanopy-storytree', 'WCA', 12, 'The Storyteller’s Platform', 'lark-fernsway',
         "A storm split the great Storyteller's Tree and brought its platform crashing down. No stories have been told since, and Lark Fernsway says the town is too quiet. "
         . "Get to know the Greatcanopy, then help raise the platform.",
         "[i]Dear Companion,[/i]\n\nThe first story told from the new platform was about you. Traders here will pay a little more for your goods from now on.\n\n"
         . "The second story was about a white-haired gnome who walked [b]into the savanna[/b] with a seed in her pocket. Thornacre next. "
         . "They call you [b]Hollow Ranger[/b] here now. My notes on the Greatcanopy are enclosed." . $sig,
         'Storyteller’s Platform', '🌳', 'sell_bonus:10', 'Shops in the Greatcanopy pay 10% more for what you sell.', 6600, 4200, 'morpho-scales', 2, 'Hollow Ranger',
         array_merge($know('the Greatcanopy', 3, 2, 3), $mid(14, 16, 8, 1600, 6, 4))],
        ['thornacre-pump', 'ESA', 13, 'The Waterhole Pump', 'poppy-puddlejump',
         "The dry season came early and the waterhole is shrinking. The old pump that fed it is broken, and the Waterhole Lookout is closed while the animals are thirsty. "
         . "Poppy Puddlejump needs help. Get to know the savanna first.",
         "[i]Dear Companion,[/i]\n\nThe waterhole is full and the animals came back at sunset: elephants, zebras, a very rude ostrich. The rangers will leave you a crate every week.\n\n"
         . "At the pump's base we found Tansy's compass. Its needle doesn't point north. It points across the sea, to [b]the Coralscatter[/b], where the reef sings. This is it, Companion." . $sig,
         'Waterhole Pump', '🐘', 'weekly_crate', 'The Thornacre rangers leave you a crate every week.', 7500, 5000, 'geode', 2, '',
         array_merge($know('Thornacre Savanna', 3, 2, 3), $mid(16, 14, 10, 1800, 6, 4))],
        ['coralscatter-reefgarden', 'OC', 14, 'The Reef Garden', 'quill-rootstock',
         "On a quiet beach in the Coralscatter, Quill Rootstock tells you about the old gnome who lives by the reef, \"the one who hums to the coral.\" Her garden has been battered by storms, and she won't leave it. "
         . "Wren is on her way. Get to know the islands, then help rebuild the reef garden.",
         "[i]Dear Companion,[/i]\n\nShe's here. Tansy is here, alive and cross and wonderful, and she has been growing the [b]Hollowheart[/b] all these years, the one seed the whole Hollow shares. "
         . "She never came home because she couldn't leave it, and she couldn't carry it.\n\n"
         . "Now there's a garden fit for it, thanks to you. Tansy has finished her field guide, with your name on the first page. "
         . "Take this little Hollowheart for your own garden. From today, the Hollow calls you [b]Keeper of the Hollow[/b].\n\n"
         . "With all my thanks,\n[i]Wren (and Tansy)[/i]",
         'Reef Garden', '🪸', 'native_plus:10', 'Native crops in your Coralscatter gardens grow 10% faster, and Tansy’s Reef Garden is open to you.', 10000, 7000, 'hollowheart-tree', 1, 'Keeper of the Hollow',
         array_merge($know('the Coralscatter', 3, 2, 4), $mid(18, 16, 10, 2500, 8, 5))],
    ];
}
