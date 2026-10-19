<?php
declare(strict_types=1);
/**
 * NPC friendships (v0.7.13). Talk to the gnomes, toads and beetles of the Hollow once a day, bring them gifts,
 * and they come to like you. Friends give shop discounts where they work and the odd present.
 * Each NPC's tastes are fixed from their name, so they're the same for everyone, and players discover them by giving gifts.
 */

/** [points needed, name, shop discount %] */
const FRIEND_LEVELS = [[0, 'Stranger', 0], [20, 'Acquaintance', 0], [100, 'Friend', 5], [250, 'Good friend', 8], [500, 'Best friend', 12]];
const FRIEND_MAX = 600;
/** Gift categories an NPC can like or dislike. */
const GIFT_CATS = ['produce' => 'fresh crops', 'flower' => 'flowers', 'food' => 'home cooking', 'forage' => 'wild finds', 'soil' => 'soil and compost', 'part' => 'creature bits', 'seed' => 'seeds'];

function friend_level(int $points): array
{
    $lvl = FRIEND_LEVELS[0];
    $next = null;
    foreach (FRIEND_LEVELS as $i => $l) {
        if ($points >= $l[0]) { $lvl = $l + [3 => $i]; $next = FRIEND_LEVELS[$i + 1] ?? null; }
    }
    return ['name' => $lvl[1], 'discount' => $lvl[2], 'index' => $lvl[3], 'next' => $next];
}

/** An NPC's tastes, fixed from their slug: loved item, two liked categories, one disliked. */
function npc_tastes(array $npc): array
{
    $h = crc32((string)$npc['slug']);
    $cats = array_keys(GIFT_CATS);
    $liked = [$cats[$h % count($cats)], $cats[intdiv($h, 7) % count($cats)]];
    if ($liked[0] === $liked[1]) $liked[1] = $cats[($h + 3) % count($cats)];
    $left = array_values(array_diff($cats, $liked));
    $disliked = $left[intdiv($h, 49) % count($left)];
    // v0.7.85: the favourite is chosen once and stored on the NPC (npcs.loved_item_id), so adding new produce
    // doesn't move it. Re-chosen only if the stored item is gone or no longer tradable; an admin can edit it.
    $loved = 0;
    $stored = (int)($npc['loved_item_id'] ?? 0);
    if ($stored && q_val('SELECT 1 FROM items WHERE id = ? AND tradable = 1', [$stored])) {
        $loved = $stored;
    } else {
        $pool = q("SELECT id FROM items WHERE category IN ('produce', 'flower', 'food') AND tradable = 1 ORDER BY id")->fetchAll(PDO::FETCH_COLUMN);
        $loved = $pool ? (int)$pool[intdiv($h, 343) % count($pool)] : 0;
        if ($loved && !empty($npc['id'])) {
            q('UPDATE npcs SET loved_item_id = ? WHERE id = ?', [$loved, (int)$npc['id']]);
        }
    }
    return ['loved' => $loved, 'liked' => $liked, 'disliked' => $disliked];
}

function friendship(int $uid, int $npcId): array
{
    $f = q_one('SELECT * FROM npc_friends WHERE user_id = ? AND npc_id = ?', [$uid, $npcId]);
    return $f ?: ['user_id' => $uid, 'npc_id' => $npcId, 'points' => 0, 'talks' => 0, 'gifts' => 0, 'last_talk' => null, 'last_gift' => null, 'known' => '[]'];
}

function friend_add(int $uid, int $npcId, int $points, array $set = []): int
{
    $f = friendship($uid, $npcId);
    $new = max(0, min(FRIEND_MAX, (int)$f['points'] + $points));
    $row = ['points' => $new] + $set;
    if (empty($f['id'])) {
        db_insert('npc_friends', $row + ['user_id' => $uid, 'npc_id' => $npcId, 'talks' => 0, 'gifts' => 0, 'known' => '[]']);
    } else {
        $cols = implode(', ', array_map(fn($k) => "$k = ?", array_keys($row)));
        q("UPDATE npc_friends SET $cols WHERE id = ?", array_merge(array_values($row), [$f['id']]));
    }
    return $new;
}

/**
 * v1.2.2: claim today's chat ($col = 'last_talk') or gift ('last_gift') with a conditional UPDATE. The value really changes,
 * so rowCount is reliable on MySQL too. Makes sure the row exists first. Call inside a transaction after locking the users row.
 */
function friend_claim(int $uid, int $npcId, string $col, string $today): bool
{
    if ($col !== 'last_talk' && $col !== 'last_gift') return false;
    if (!q_val('SELECT 1 FROM npc_friends WHERE user_id = ? AND npc_id = ?', [$uid, $npcId])) {
        try { db_insert('npc_friends', ['user_id' => $uid, 'npc_id' => $npcId, 'points' => 0, 'talks' => 0, 'gifts' => 0, 'known' => '[]']); }
        catch (PDOException $e) { /* a second login made it first */ }
    }
    return q("UPDATE npc_friends SET $col = ? WHERE user_id = ? AND npc_id = ? AND ($col IS NULL OR $col <> ?)", [$today, $uid, $npcId, $today])->rowCount() === 1;
}

/** Is this NPC somewhere the player can talk to them right now? */
function npc_here(array $u, int $npcId): bool
{
    $t = q_one('SELECT * FROM npcs WHERE id = ? AND traveller IS NOT NULL', [$npcId]);
    if ($t) {
        require_once __DIR__ . '/npc_life.php';
        return can_reach($u, traveller_stop($t)['town']);
    }
    $hour = hollow_hour();
    $day = hollow_dow();
    foreach (q('SELECT s.*, sh.location_id AS shop_loc FROM npc_schedules s LEFT JOIN shops sh ON sh.id = s.shop_id WHERE s.npc_id = ?', [$npcId])->fetchAll() as $s) {
        if (!in_array($day, schedule_days($s['days']), true) || !in_array($hour, schedule_hours((int)$s['start_hour'], (int)$s['end_hour']), true)) continue;
        $loc = $s['shop_id'] ? $s['shop_loc'] : $s['location_id'];
        $region = $loc ? q_val('SELECT region FROM locations WHERE id = ?', [$loc]) : null;
        if ($region !== null && can_reach($u, (string)$region)) return true;
    }
    // v0.7.73: at home — reachable from their home town
    require_once __DIR__ . '/npc_life.php';
    $n = q_one('SELECT * FROM npcs WHERE id = ? AND active = 1', [$npcId]);
    $now = $n ? npc_now($n) : [];
    return !empty($now['home']) && $now['town'] !== null && can_reach($u, (string)$now['town']);
}

const TALK_LINES = [
    'Cheerful' => ['Isn’t it a lovely day for it?', 'You look like someone who grows a fine radish!', 'Every day’s a good day in the Hollow.'],
    'Grumpy' => ['Hmph. You again.', 'Mind the mud on your boots.', 'Back in my day, turnips were bigger.'],
    'Dreamy' => ['Do you ever wonder what the mushrooms dream about?', 'The clouds look like cabbages today.', 'I was miles away. Hello!'],
    'Chatty' => ['Did you hear? Someone grew a pumpkin the size of a wheelbarrow!', 'Oh, I could talk to you all day!', 'Let me tell you about my cousin’s compost heap…'],
    'Shy' => ['Oh! H-hello.', '…nice weather.', 'I like your hat.'],
    'Curious' => ['What have you got in your satchel today?', 'Have you been down the old mine yet?', 'Where did you travel last?'],
    'Fussy' => ['Wipe your feet, please.', 'That watering can is dented, you know.', 'Everything in its proper place.'],
    'Generous' => ['Take care of yourself out there.', 'If you ever need a hand, just ask.', 'Sharing makes the garden grow.'],
    'Sleepy' => ['*yawn* Oh, hello there.', 'Is it morning already?', 'Five more minutes…'],
    'Proud' => ['My shop is the finest in the region, of course.', 'I won a ribbon once, you know.', 'Only the best for my customers.'],
    'Eager' => ['Hello hello hello!', 'Is there anything I can help with? Anything?', 'Today’s going to be great, I can feel it!'],
    'Warm' => ['Come in, come in, you look chilly.', 'There’s always a kettle on for you.', 'It’s good to see a friendly face.'],
];
const TALK_TIPS = [
    'Tip: beans put nitrogen back in the soil.', 'Tip: follow the numbers when you hunt worms. Worms like company.',
    'Tip: a cover crop dug in feeds every nutrient at once.', 'Tip: no-till beds get better every season if you keep them mulched.',
    'Tip: saplings let a friend grow a crop they don’t know yet.', 'Tip: Lightning Larry hardly ever wins, but when he does…',
    'Tip: hired helpers keep a share of the harvest, so pick your crops wisely.', 'Tip: flowers next to crops bring pollinators.',
];

function npc_talk(array $u, int $npcId): array
{
    $uid = (int)$u['id'];
    $npc = q_one('SELECT * FROM npcs WHERE id = ? AND active = 1', [$npcId]);
    if (!$npc || !npc_here($u, $npcId)) return [false, 'They aren’t around right now.'];
    $f = friendship($uid, $npcId);
    $today = hollow_date('Y-m-d');   // v0.7.85: the Hollow's day (midnight Halifax), like the landmarks and towns
    if ($f['last_talk'] === $today) return [false, $npc['name'] . ' has already had a good chat with you today.'];
    $gain = max(1, 3 + (function_exists('eff_mod') ? eff_mod($u, 'charm') : 0));
    require_once __DIR__ . '/npc_life.php';
    $fav = npc_at_favourite($npc);
    if ($fav) $gain *= 2;   // v0.7.21: found them at their favourite place
    // v1.2.2: lock, claim today's chat, then re-read the friendship (the one read above may be stale)
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if (!friend_claim($uid, $npcId, 'last_talk', $today)) {
        db()->rollBack();
        return [false, $npc['name'] . ' has already had a good chat with you today.'];
    }
    $f = friendship($uid, $npcId);
    $before = friend_level((int)$f['points']);
    $new = friend_add($uid, $npcId, $gain, ['talks' => (int)$f['talks'] + 1]);
    db()->commit();
    // v0.9.1: the chat counted (it is once a day, checked above), so it pays XP
    $chatXp = (int)setting('friend_chat_xp');
    if ($chatXp > 0) add_xp($uid, $chatXp, 'Chatting with folk');
    $xpNote = $chatXp > 0 ? ', +' . $chatXp . ' XP' : '';
    $lines = TALK_LINES[$npc['personality']] ?? TALK_LINES['Cheerful'];
    $line = $lines[random_int(0, count($lines) - 1)];
    if ((int)$npc['mood'] < 30) $line = 'They seem a bit down today. ' . $line;
    $msg = '💬 ' . $npc['name'] . ': “' . $line . '”' . (random_int(1, 3) === 1 ? ' ' . TALK_TIPS[array_rand(TALK_TIPS)] : '') . ' (+' . $gain . ' friendship' . ($fav ? ', doubled: this is their favourite place' : '') . $xpNote . ')';
    // Good friends sometimes have a little something for you
    if ($before['index'] >= 3 && random_int(1, 100) <= 15) {
        $gift = q_one("SELECT i.id, i.name FROM npc_schedules s JOIN shop_stock st ON st.shop_id = s.shop_id JOIN items i ON i.id = st.item_id
                       WHERE s.npc_id = ? AND i.category IN ('seed', 'food', 'soil') ORDER BY i.base_price LIMIT 1", [$npcId]);
        if ($gift) {
            give_item($uid, (int)$gift['id'], 1);
            $msg .= ' 🎁 They press a ' . $gift['name'] . ' into your hands.';
        }
    }
    $after = friend_level($new);
    if ($after['index'] > $before['index']) $msg .= ' 💛 You and ' . $npc['name'] . ' are now: ' . $after['name'] . '!';
    unlock_entries($uid, 'npc:' . $npc['slug']);
    calling_event($uid, 'talk', (string)$npc['slug'], 1, ['npc' => (string)$npc['slug']]);   // v0.9.4 N7
    return [true, $msg];
}

function npc_gift(array $u, int $npcId, int $itemId): array
{
    $uid = (int)$u['id'];
    $npc = q_one('SELECT * FROM npcs WHERE id = ? AND active = 1', [$npcId]);
    if (!$npc || !npc_here($u, $npcId)) return [false, 'They aren’t around right now.'];
    $f = friendship($uid, $npcId);
    $today = hollow_date('Y-m-d');   // v0.7.85: the Hollow's day
    if ($f['last_gift'] === $today) return [false, $npc['name'] . ' has already had a present from you today.'];
    $item = q_one('SELECT * FROM items WHERE id = ? AND tradable = 1', [$itemId]);
    if (!$item) return [false, 'Pick something to give.'];
    if (in_array($item['category'], ['tool', 'broken'], true)) return [false, 'They wouldn’t know what to do with that.'];   // v0.7.86: tools are not presents
    $t = npc_tastes($npc);
    // v0.9.1: a Bloomcaller master's flowers always count as liked. Loved still wins (first arm). The taste is not
    // written to the notebook, since this NPC may not really like flowers.
    $flowerLiked = $item['category'] === 'flower' && calling_perk($u, 'flower_liked_gift') > 0;
    $itemFx = json_decode((string)($item['effects'] ?? ''), true) ?: [];
    [$pts, $react, $key] = match (true) {
        (int)$item['id'] === $t['loved'] => [25, 'gasps. “My favourite! How did you know?”', 'loved'],
        $item['category'] === 'arrangement' => [min(24, 15 + intdiv((int)($itemFx['arrangement']['score'] ?? 0), 12)), 'gasps softly. “A whole arrangement? It’s beautiful!”', null],   // v0.9.9: better than any single flower (10), just under a favourite (25)
        in_array($item['category'] === 'packet' ? 'seed' : $item['category'], $t['liked'], true) => [10, 'beams. “Oh, I do like ' . GIFT_CATS[$item['category'] === 'packet' ? 'seed' : $item['category']] . '!”', 'like:' . ($item['category'] === 'packet' ? 'seed' : $item['category'])],
        $flowerLiked => [10, 'beams. “Oh, I do like ' . GIFT_CATS['flower'] . '!”', null],
        !empty($itemFx['preserve']) => [10, 'beams. “A jar from your own pantry? Oh, I do like preserves!”', null],   // v0.9.8: every townsfolk likes a jar of jam or pickles (loved still wins)
        $item['category'] === $t['disliked'] => [-5, 'wrinkles their nose. “Er… thank you?”', 'dislike:' . $item['category']],
        default => [4, 'smiles politely. “How kind.”', null],
    };
    if ($pts > 0) $pts = (int)round($pts * (1 + 0.08 * max(0, function_exists('eff_mod') ? eff_mod($u, 'charm') : 0)));
    require_once __DIR__ . '/npc_life.php';
    $bday = npc_birthday_today($npc);
    if ($bday && $pts > 0) {   // v0.7.31: birthday gifts count three times
        $pts *= 3;
        $react = 'opens it with a huge grin. “For my birthday? You remembered!” ' . $react;
    }
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // v1.2.2: lock, claim today's gift, re-read the friendship
    if (!friend_claim($uid, $npcId, 'last_gift', $today)) {
        db()->rollBack();
        return [false, $npc['name'] . ' has already had a present from you today.'];
    }
    if (!give_item($uid, $itemId, -1)) {
        db()->rollBack();
        return [false, 'You don’t have one of those.'];
    }
    $f = friendship($uid, $npcId);
    $known = json_decode((string)$f['known'], true) ?: [];
    if ($key && !in_array($key, $known, true)) $known[] = $key;
    $before = friend_level((int)$f['points']);
    $new = friend_add($uid, $npcId, $pts, ['gifts' => (int)$f['gifts'] + 1, 'known' => json_encode($known)]);
    q('UPDATE npcs SET mood = ? WHERE id = ?', [min(100, (int)$npc['mood'] + ($pts > 0 ? 2 : -1)), $npcId]);
    db()->commit();
    // v0.9.1: the gift counted, so it pays XP (the loved amount for a loved gift). After commit, so a refused gift never pays.
    $xp = (int)setting($key === 'loved' ? 'friend_loved_xp' : 'friend_gift_xp');
    if ($xp > 0) add_xp($uid, $xp, 'Gifts to folk');
    $xpNote = $xp > 0 ? ', +' . $xp . ' XP' : '';
    $after = friend_level($new);
    calling_event($uid, 'gift', (string)$npc['slug'], 1, ['cat' => (string)$item['category'], 'item' => (string)$item['slug'], 'npc' => (string)$npc['slug']]);   // v0.9.4 N7 (a refused or disliked gift counts as given)
    return [true, '🎁 You give ' . $npc['name'] . ' 1 × ' . $item['name'] . '. ' . $npc['name'] . ' ' . $react . ' (' . ($pts >= 0 ? '+' : '') . $pts . ' friendship' . $xpNote . ')'
        . ($after['index'] > $before['index'] ? ' 💛 You are now: ' . $after['name'] . '!' : '')];
}

/** Best friendship discount among everyone who works at this shop. */
function friend_discount(int $uid, int $shopId): int
{
    $best = (int)q_val("SELECT MAX(f.points) FROM npc_friends f JOIN npc_schedules s ON s.npc_id = f.npc_id
                        WHERE f.user_id = ? AND s.shop_id = ?", [$uid, $shopId]);
    return friend_level($best)['discount'];
}

/** What the tastes look like to a player who has discovered some of them. */
function known_tastes(array $f, array $npc): array
{
    $known = json_decode((string)($f['known'] ?? '[]'), true) ?: [];
    $t = npc_tastes($npc);
    $out = [];
    if (in_array('loved', $known, true)) $out[] = '💛 Loves ' . q_val('SELECT name FROM items WHERE id = ?', [$t['loved']]);
    foreach ($known as $k) {
        if (str_starts_with($k, 'like:')) $out[] = '👍 Likes ' . (GIFT_CATS[substr($k, 5)] ?? '');
        if (str_starts_with($k, 'dislike:')) $out[] = '👎 Not keen on ' . (GIFT_CATS[substr($k, 8)] ?? '');
    }
    return $out;
}

function ensure_friends(): void
{
    if (q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'Friends in the Hollow' AND chapter = 'General'")) return;
    $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'Friends in the Hollow',
        'body' => "The shopkeepers and wanderers of the Hollow remember you.\n\n"
            . "💬 [b]Talk[/b] to someone once a day, and 🎁 [b]give them a gift[/b] once a day. Everyone has a favourite thing, a couple of things they like, and one they’d rather not get. You’ll learn their tastes as you go.\n\n"
            . "Friendship grows from Stranger to Acquaintance, Friend, Good friend and Best friend. Friends give you a discount in the shop where they work (5%, then 8%, then 12%), "
            . "and good friends sometimes have a little present for you. A high Charm helps.\n\nFind them behind shop counters and wandering the villages. Your friends are listed on My Gnome.",
        'unlock_key' => 'start', 'hint' => '', 'sort_order' => 7]);
    foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
        db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
    }
}


/** v0.7.61: an NPC's portrait, or a red-bordered placeholder of the same size (4:5) until art is added in Admin. */
function npc_portrait(array $npc, string $cls = ''): string
{
    require_once __DIR__ . '/items.php';   // v1.5.2: ph_path
    $img = trim((string)($npc['image'] ?? ''));
    if ($img !== '' && preg_match('#^[A-Za-z0-9_./-]+\.(png|jpe?g|webp|gif)$#i', $img) && !str_contains($img, '..') && is_file(APP_ROOT . '/' . $img)) {
        return '<img class="portrait ' . e($cls) . '" src="' . e(url($img)) . '" alt="' . e($npc['name']) . '" width="160" height="200" loading="lazy">';
    }
    // v1.5.2: a drawn placeholder (assets/img/ph/npc-{slug}.svg) before the plain red box
    if (($pp = ph_path('npc-' . (string)($npc['slug'] ?? ''))) !== '') {
        return '<img class="portrait phport ' . e($cls) . '" src="' . e(url($pp)) . '" alt="' . e($npc['name']) . '" width="160" height="200" loading="lazy">';
    }
    return '<div class="portrait placeholder ' . e($cls) . '" role="img" aria-label="Portrait coming soon"><span>' . npc_icon((string)($npc['species'] ?? '')) . '</span><small>portrait<br>400×500</small></div>';
}
