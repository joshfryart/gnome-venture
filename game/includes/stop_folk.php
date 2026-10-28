<?php
declare(strict_types=1);
/**
 * Rest stop villagers (v1.0.0 wave 1): 2-3 named villagers per stop (stop_folk), friendship (stop_friend), chat and errands (stop_errands).
 * Generated from the village's name so they are the same on every world; an admin can rename or add folk in Admin > Stop villagers.
 * Errands: fetch (bring local produce), deliver (carry a parcel to a villager at another stop of the road), escort (walk a small friend
 * to another stop). They pay Petals, XP and friendship, and tell the calling/job systems something was done.
 */

require_once __DIR__ . '/stops.php';
require_once __DIR__ . '/npc_life.php';   // npc_icon

const STOP_FIRST_NAMES = ['Bramwick', 'Pip', 'Thimble', 'Marigold', 'Hazel', 'Tuck', 'Fennel', 'Cobb', 'Dilly', 'Nettle', 'Wick', 'Posy', 'Burdock', 'Sorrel', 'Quill', 'Moss', 'Tansy', 'Rook', 'Clover', 'Basil',
    'Pebble', 'Yarrow', 'Alder', 'Bunty', 'Ferrin', 'Gorse', 'Juniper', 'Linden', 'Mabel', 'Orla', 'Perrin', 'Rue', 'Sage', 'Tilly', 'Ulric', 'Willa', 'Barnaby', 'Dorrit', 'Elm', 'Fig'];
const STOP_LAST_NAMES = ['Thistledown', 'Puddlefoot', 'Brambleby', 'Mossgrove', 'Peppercorn', 'Oakenpot', 'Nettlebed', 'Dewdrop', 'Hollowell', 'Crumblewick', 'Fiddlewood', 'Lanternby', 'Tumblethorn', 'Kettleby', 'Marrowby', 'Wickerby',
    'Cobblefield', 'Barleycorn', 'Rushworth', 'Pennywhistle', 'Bumbleby', 'Snailwick', 'Teaspoon', 'Windlass', 'Honeycomb', 'Burrowby', 'Acorncap', 'Sedgemoor', 'Larkspur', 'Gillyflower'];
const STOP_PERSONALITIES = ['Chatty', 'Cheerful', 'Warm', 'Generous', 'Eager', 'Grumpy', 'Shy', 'Fussy', 'Proud', 'Curious', 'Dreamy', 'Sleepy'];
const STOP_SPECIES = [
    'grassland' => ['Hedgehog', 'Field Mouse', 'Hare', 'Cricket', 'Ladybird', 'Bumblebee', 'Grasshopper', 'Mole'],
    'forest' => ['Hedgehog', 'Wood Mouse', 'Beetle', 'Wren', 'Mole', 'Moth', 'Snail', 'Shrew'],
    'coast' => ['Tortoise', 'Frog', 'Snail', 'Dragonfly', 'Wren', 'Beetle'],
    'desert' => ['Gecko', 'Beetle', 'Hare', 'Tortoise', 'Cricket', 'Moth'],
    'mountain' => ['Hare', 'Wren', 'Mole', 'Beetle', 'Mouse', 'Hedgehog'],
    'rainforest' => ['Frog', 'Gecko', 'Butterfly', 'Beetle', 'Firefly', 'Snail'],
    'tundra' => ['Hare', 'Wren', 'Mouse', 'Beetle', 'Snail', 'Moth'],
    'island' => ['Tortoise', 'Gecko', 'Frog', 'Snail', 'Dragonfly', 'Wren'],
    'wetland' => ['Frog', 'Toad', 'Dragonfly', 'Snail', 'Beetle', 'Firefly'],
];
const STOP_BIOS = [
    'Chatty' => 'Knows everyone’s business and shares most of it.', 'Cheerful' => 'Smiles at the weather, whatever it is doing.', 'Warm' => 'Has a kind word and usually a biscuit.',
    'Generous' => 'Will give you the last of anything, then deny it.', 'Eager' => 'Is always keen to be of use, sometimes before being asked.', 'Grumpy' => 'Grumbles a lot but is secretly soft.',
    'Shy' => 'Speaks quietly and notices everything.', 'Fussy' => 'Likes things done properly, which means their way.', 'Proud' => 'Is very fond of this place, and will tell you why.',
    'Curious' => 'Asks you all about the road and writes it down.', 'Dreamy' => 'Is usually thinking of somewhere else, often something lovely.', 'Sleepy' => 'Yawns a lot, but is rarely out of bed late.',
];
const STOP_FRIEND_LEVELS = [[0, 'Stranger'], [3, 'Familiar face'], [8, 'Friend'], [15, 'Dear friend']];

/** Make the villagers of a stop (once). Returns how many exist. */
function stop_folk_ensure(array $loc): int
{
    $have = (int)q_val('SELECT COUNT(*) FROM stop_folk WHERE location_id = ?', [(int)$loc['id']]);
    if ($have > 0) return $have;
    $types = stop_types();
    $t = $types[stop_type_of($loc)] ?? null;
    $roles = $t ? array_values(array_filter(array_map('trim', explode(',', (string)$t['roles'])))) : [];
    $species = STOP_SPECIES[(string)$loc['landscape']] ?? STOP_SPECIES['grassland'];
    $n = 2 + (crc32('folkn|' . $loc['slug']) % 2);
    $used = [];
    for ($s = 1; $s <= $n; $s++) {
        $h = crc32('folk|' . $loc['slug'] . '|' . $s);
        $name = '';
        for ($try = 0; $try < 8; $try++) {
            $name = STOP_FIRST_NAMES[($h + $try * 7) % count(STOP_FIRST_NAMES)] . ' ' . STOP_LAST_NAMES[intdiv($h, 40 + $try) % count(STOP_LAST_NAMES)];
            if (!in_array($name, $used, true)) break;
        }
        $used[] = $name;
        $pers = STOP_PERSONALITIES[intdiv($h, 3) % count(STOP_PERSONALITIES)];
        $role = $roles ? $roles[($s - 1) % count($roles)] : 'Villager';
        try {
            db_insert('stop_folk', ['location_id' => (int)$loc['id'], 'slot' => $s, 'name' => $name, 'species' => $species[intdiv($h, 11) % count($species)],
                'personality' => $pers, 'role' => $role, 'bio' => $role . ' at ' . $loc['name'] . '. ' . STOP_BIOS[$pers]]);
        } catch (PDOException $e) { /* made by another request */ }
    }
    return (int)q_val('SELECT COUNT(*) FROM stop_folk WHERE location_id = ?', [(int)$loc['id']]);
}

/** The villagers at a stop. */
function stop_folk_of(array $loc): array
{
    stop_folk_ensure($loc);
    return q('SELECT * FROM stop_folk WHERE location_id = ? AND active = 1 ORDER BY slot', [(int)$loc['id']])->fetchAll();
}

/** One of the stop's villagers, picked by a seed (the same seed always gives the same one). */
function stop_pick_folk(int $uid, array $loc, string $seed): ?array
{
    $folk = stop_folk_of($loc);
    return $folk ? $folk[crc32('pick|' . $seed) % count($folk)] : null;
}

function stop_friend_points(int $uid, int $folkId): int
{
    return (int)q_val('SELECT points FROM stop_friend WHERE user_id = ? AND folk_id = ?', [$uid, $folkId]);
}

/** [index, name, next at (or null)] for a points total. */
function stop_friend_level(int $points): array
{
    $idx = 0;
    foreach (STOP_FRIEND_LEVELS as $i => [$at]) if ($points >= $at) $idx = $i;
    return ['index' => $idx, 'name' => STOP_FRIEND_LEVELS[$idx][1], 'next' => STOP_FRIEND_LEVELS[$idx + 1][0] ?? null];
}

/** Make sure the friendship row exists. */
function stop_friend_ensure(int $uid, int $folkId): void
{
    if (q_val('SELECT 1 FROM stop_friend WHERE user_id = ? AND folk_id = ?', [$uid, $folkId])) return;
    try {
        db_insert('stop_friend', ['user_id' => $uid, 'folk_id' => $folkId, 'points' => 0, 'talks' => 0, 'gifts' => 0]);
    } catch (PDOException $e) { /* made by another request */ }
}

/** Add friendship. Returns the new total. A new level gives a small gift (once per level), told in the session flash. */
function stop_friend_add(int $uid, int $folkId, int $n): int
{
    if ($n <= 0) return stop_friend_points($uid, $folkId);
    stop_friend_ensure($uid, $folkId);
    q('UPDATE stop_friend SET points = points + ? WHERE user_id = ? AND folk_id = ?', [$n, $uid, $folkId]);
    $row = q_one('SELECT points, gifts FROM stop_friend WHERE user_id = ? AND folk_id = ?', [$uid, $folkId]);
    $lvl = stop_friend_level((int)$row['points'])['index'];
    // v1.0.0: claim the level first (conditional update); only the request that moves `gifts` up pays
    if ($lvl > (int)$row['gifts'] && q('UPDATE stop_friend SET gifts = ? WHERE user_id = ? AND folk_id = ? AND gifts < ?', [$lvl, $uid, $folkId, $lvl])->rowCount() === 1) {
        $coins = 20 * $lvl;
        give_petals((int)$uid, (int)$coins);
        $extra = '';
        if ($lvl >= 2) {
            $seed = (int)q_val("SELECT i.id FROM items i WHERE i.category = 'seed' AND i.id IN (SELECT seed_item_id FROM plants WHERE common = 1) ORDER BY i.id LIMIT 1 OFFSET " . (crc32($uid . '|' . $folkId) % 5));
            if ($seed) { give_item($uid, $seed, 1); $extra = ' and a seed'; }
        }
        $name = (string)q_val('SELECT name FROM stop_folk WHERE id = ?', [$folkId]);
        if (session_status() === PHP_SESSION_ACTIVE) flash('💛 ' . $name . ' counts you a ' . STOP_FRIEND_LEVELS[$lvl][1] . ' now, and gives you ' . $coins . ' ' . setting('currency_name') . $extra . '!');
    }
    return (int)$row['points'];
}

// ---------------------------------------------------------------- chat

/** The line a villager says today, from stop_chat.txt: the most specific line that fits the time, season, weather and personality. */
function stop_chat_line(array $u, array $loc, array $folk): string
{
    static $lines = null;
    if ($lines === null) $lines = stops_file_rows('stop_chat.txt');
    $now = stop_now($loc);
    $fit = [];
    foreach ($lines as $r) {
        if (count($r) < 3) continue;
        [$cond, $pers, $text] = $r;
        if ($pers !== 'any' && $pers !== $folk['personality']) continue;
        if (!stop_cond_ok($cond, $now)) continue;
        $fit[] = [($cond === '-' ? 0 : 1) + ($pers === 'any' ? 0 : 1), $text];
    }
    if (!$fit) return '“Hello, ' . $u['gnome_name'] . '.”';
    $best = max(array_column($fit, 0));
    $top = array_values(array_filter($fit, fn($f) => $f[0] >= $best - ($best > 0 ? 1 : 0)));
    $pick = $top[crc32($u['id'] . '|' . $folk['id'] . '|' . hollow_date('Y-m-d') . '|' . $now['dp']) % count($top)][1];
    return str_replace(['{name}', '{folk}', '{place}'], [(string)($u['gnome_name'] ?: $u['username']), $folk['name'], $loc['name']], $pick);
}

/** Talk to a villager: free, once a day each, +friendship. $lineText (v1.9.4): a line of their own to say (a chat met on the road), instead of stop_chat.txt's. */
function stop_chat(array $u, array $loc, int $folkId, ?string $lineText = null): array
{
    $uid = (int)$u['id'];
    $folk = q_one('SELECT * FROM stop_folk WHERE id = ? AND location_id = ? AND active = 1', [$folkId, (int)$loc['id']]);
    if (!$folk) return [false, 'Nobody by that name is here.'];
    $today = hollow_date('Y-m-d');
    stop_friend_ensure($uid, $folkId);
    $line = npc_icon($folk['species']) . ' ' . $folk['name'] . ': ' . ($lineText ?? stop_chat_line($u, $loc, $folk));
    if (q('UPDATE stop_friend SET last_talk = ?, talks = talks + 1 WHERE user_id = ? AND folk_id = ? AND (last_talk IS NULL OR last_talk <> ?)', [$today, $uid, $folkId, $today])->rowCount() !== 1) {
        return [true, $line . ' (you’ve already had your chat today)'];
    }
    $before = stop_friend_points($uid, $folkId);
    $new = stop_friend_add($uid, $folkId, max(1, (int)setting('stop_chat_fp')));
    if (function_exists('calling_event')) calling_event($uid, 'talk', 'stop:' . $folk['id'], 1, ['npc' => 'stop-' . $folk['id']]);
    return [true, $line . ' (💛 +' . ($new - $before) . ')'];
}

/** The things in the satchel a villager would take as a present (not tools or broken things), cheapest first. */
function stop_giftable(int $uid): array
{
    return q("SELECT i.*, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
              WHERE ui.user_id = ? AND ui.qty > 0 AND i.tradable = 1 AND i.category NOT IN ('tool', 'broken') ORDER BY i.name", [$uid])->fetchAll();
}

/**
 * v2.0.77: give a villager at this stop a present: once a day each, +friendship (2 for a plain thing, 4 for food, flowers, produce or
 * arrangements; a Charm boost like the townsfolk). Returns [ok, message].
 */
function stop_gift(array $u, array $loc, int $folkId, int $itemId): array
{
    $uid = (int)$u['id'];
    $folk = q_one('SELECT * FROM stop_folk WHERE id = ? AND location_id = ? AND active = 1', [$folkId, (int)$loc['id']]);
    if (!$folk) return [false, 'Nobody by that name is here.'];
    $item = q_one("SELECT * FROM items WHERE id = ? AND tradable = 1 AND category NOT IN ('tool', 'broken')", [$itemId]);
    if (!$item) return [false, 'Pick something to give.'];
    $today = hollow_date('Y-m-d');
    stop_friend_ensure($uid, $folkId);
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // lock, claim today's gift, then take the item
    if (q('UPDATE stop_friend SET last_gift = ? WHERE user_id = ? AND folk_id = ? AND (last_gift IS NULL OR last_gift <> ?)', [$today, $uid, $folkId, $today])->rowCount() !== 1) {
        db()->rollBack();
        return [false, $folk['name'] . ' has already had a present from you today.'];
    }
    if (!give_item($uid, $itemId, -1)) { db()->rollBack(); return [false, 'You don’t have one of those.']; }
    db()->commit();
    $pts = in_array($item['category'], ['food', 'flower', 'produce', 'arrangement'], true) ? 4 : 2;
    $pts = (int)round($pts * (1 + 0.08 * max(0, function_exists('eff_mod') ? eff_mod($u, 'charm') : 0)));
    $before = stop_friend_points($uid, $folkId);
    $new = stop_friend_add($uid, $folkId, $pts);
    return [true, npc_icon($folk['species']) . ' ' . $folk['name'] . ' takes the ' . $item['name'] . ' with a grateful smile. (💛 +' . ($new - $before) . ')'];
}

// ---------------------------------------------------------------- errands

/** Tidy errands that ran out of days. */
function stop_errands_expire(int $uid): void
{
    q("UPDATE stop_errands SET status = 'expired' WHERE user_id = ? AND status = 'active' AND expires_day < ?", [$uid, hollow_date('Y-m-d')]);
}

function stop_errands_active(int $uid): array
{
    stop_errands_expire($uid);
    return q("SELECT e.*, f.name AS giver, f.species AS giver_species, f.location_id AS giver_loc, t.name AS target, t.species AS target_species, t.location_id AS target_loc,
                     tl.name AS target_place, gl.name AS giver_place, i.name AS item_name
              FROM stop_errands e JOIN stop_folk f ON f.id = e.folk_id JOIN locations gl ON gl.id = f.location_id
              LEFT JOIN stop_folk t ON t.id = e.target_folk_id LEFT JOIN locations tl ON tl.id = t.location_id LEFT JOIN items i ON i.id = e.item_id
              WHERE e.user_id = ? AND e.status = 'active' ORDER BY e.id", [$uid])->fetchAll();
}

/** v1.3.0: ids of the villagers at this stop who offer an errand today (setting stop_errands_offered; which ones changes daily). */
function stop_errand_givers(array $loc): array
{
    $n = max(0, min(5, (int)setting('stop_errands_offered')));
    $day = hollow_date('Y-m-d');
    $ids = array_map(fn($f) => (int)$f['id'], stop_folk_of($loc));
    usort($ids, fn($a, $b) => crc32('giver|' . $day . '|' . $a) <=> crc32('giver|' . $day . '|' . $b));
    return array_slice($ids, 0, $n);
}

/** The villager's errand for this gnome today, or null. Fetch if there's no road to walk. */
function stop_errand_offer(array $u, array $loc, array $folk): ?array
{
    $uid = (int)$u['id'];
    $today = hollow_date('Y-m-d');
    $taken = q_one('SELECT * FROM stop_errands WHERE user_id = ? AND folk_id = ? AND offered_day = ?', [$uid, (int)$folk['id'], $today]);
    if ($taken) return ['taken' => $taken];
    if (!in_array((int)$folk['id'], stop_errand_givers($loc), true)) return null;   // v1.3.0: only a couple of villagers have an errand today
    $h = crc32('errand|' . $uid . '|' . $folk['id'] . '|' . $today);
    $lvl = stop_level($loc);
    $kind = ['fetch', 'deliver', 'escort'][$h % 3];
    if ($kind === 'fetch') return stop_errand_offer_fetch($loc, $h, $lvl);
    require_once __DIR__ . '/roads.php';
    $road = road_of((int)$loc['id']);
    $near = [];
    if ($road) {
        $ids = array_column($road['stops'], 'id');
        $at = array_search((int)$loc['id'], array_map('intval', $ids), true);
        foreach ($road['stops'] as $i => $s) {
            $d = abs($i - (int)$at);
            if ($at !== false && $d >= 1 && $d <= 3 && $s['kind'] === 'village') $near[] = [$s, $d];
        }
    }
    if (!$near) return stop_errand_offer_fetch($loc, $h, $lvl);
    [$to, $dist] = $near[intdiv($h, 5) % count($near)];
    $toLoc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$to['id']]);
    $tf = stop_folk_of($toLoc);
    if (!$tf) return stop_errand_offer_fetch($loc, $h, $lvl);
    $target = $tf[intdiv($h, 13) % count($tf)];
    $mult = $kind === 'escort' ? 1.4 : 1.0;
    return ['kind' => $kind, 'target' => $target, 'target_place' => $toLoc['name'], 'dist' => $dist,
        'coins' => (int)round((16 + 6 * $dist + 2 * $lvl) * $mult), 'xp' => (int)round((5 + 2 * $dist) * $mult), 'fp' => 2,
        'thing' => $kind === 'escort' ? ['a nervous duckling', 'a lost snail-child', 'an old uncle who insists on walking', 'a goose who has opinions'][intdiv($h, 17) % 4]
                                      : ['a parcel of seed cakes', 'a sealed letter', 'a jar of honey', 'a bundle of mended socks'][intdiv($h, 17) % 4]];
}

function stop_errand_offer_fetch(array $loc, int $h, int $lvl): ?array
{
    $crops = stop_local_crops($loc);
    if (!$crops) return null;
    $it = $crops[intdiv($h, 3) % count($crops)];
    $qty = 2 + intdiv($h, 11) % 3;
    return ['kind' => 'fetch', 'item' => $it, 'qty' => $qty, 'coins' => min(40 + 4 * $lvl, max(12, (int)round($it['base_price'] * $qty * 0.8) + 8)), 'xp' => 6 + $lvl, 'fp' => 2];
}

/** Take on an errand (deliver/escort) or hand in a fetch at once. */
function stop_errand_accept(array $u, array $loc, int $folkId): array
{
    $uid = (int)$u['id'];
    $folk = q_one('SELECT * FROM stop_folk WHERE id = ? AND location_id = ? AND active = 1', [$folkId, (int)$loc['id']]);
    if (!$folk) return [false, 'Nobody by that name is here.'];
    $o = stop_errand_offer($u, $loc, $folk);
    if (!$o) return [false, $folk['name'] . ' has nothing for you today.'];
    if (isset($o['taken'])) return [false, 'You’ve already helped ' . $folk['name'] . ' today.'];
    $today = hollow_date('Y-m-d');
    $cur = setting('currency_name');
    if ($o['kind'] === 'fetch') {
        db()->beginTransaction();
        try {
            db_insert('stop_errands', ['user_id' => $uid, 'folk_id' => $folkId, 'kind' => 'fetch', 'item_id' => (int)$o['item']['id'], 'qty' => $o['qty'], 'coins' => $o['coins'], 'xp' => $o['xp'],
                'status' => 'done', 'offered_day' => $today, 'expires_day' => $today, 'done_at' => now(), 'created_at' => now()]);
            if (!give_item($uid, (int)$o['item']['id'], -$o['qty'])) throw new UserError('You need ' . $o['qty'] . ' × ' . $o['item']['name'] . '.');
            q('UPDATE users SET coins = coins + ? WHERE id = ?', [$o['coins'], $uid]);
            add_xp($uid, $o['xp'], 'rest_stop');
            db()->commit();
        } catch (UserError $e) {
            db()->rollBack();
            return [false, $e->getMessage()];
        } catch (PDOException $e) {
            db()->rollBack();
            return [false, 'You’ve already helped ' . $folk['name'] . ' today.'];
        }
        stop_friend_add($uid, $folkId, $o['fp']);
        if (function_exists('calling_event')) calling_event($uid, 'gift', 'stop:' . $folkId, 1, ['npc' => 'stop-' . $folkId]);
        return [true, npc_icon($folk['species']) . ' ' . $folk['name'] . ' is delighted with ' . $o['qty'] . ' × ' . $o['item']['name'] . '. (+' . $o['coins'] . ' ' . $cur . ', +' . $o['xp'] . ' XP, 💛 +' . $o['fp'] . ')'];
    }
    $max = max(1, (int)setting('stop_errand_max'));
    if (count(stop_errands_active($uid)) >= $max) return [false, 'You’re already carrying ' . $max . ' errands. Finish one first.'];
    try {
        db_insert('stop_errands', ['user_id' => $uid, 'folk_id' => $folkId, 'kind' => $o['kind'], 'target_folk_id' => (int)$o['target']['id'], 'qty' => $o['dist'], 'coins' => $o['coins'], 'xp' => $o['xp'],
            'status' => 'active', 'offered_day' => $today, 'expires_day' => hollow_date_add($today, max(1, (int)setting('stop_errand_days'))), 'created_at' => now()]);
    } catch (PDOException $e) {
        return [false, 'You’ve already helped ' . $folk['name'] . ' today.'];
    }
    return [true, npc_icon($folk['species']) . ' ' . $folk['name'] . ': “' . ($o['kind'] === 'escort' ? 'Would you take ' . $o['thing'] . ' to ' . $o['target']['name'] . ' at ' . $o['target_place'] . '?' : 'Could you carry ' . $o['thing'] . ' to ' . $o['target']['name'] . ' at ' . $o['target_place'] . '?') . '”'];
}

/** Hand a parcel (or the escort) over to the villager it was for, when you are at their stop. */
function stop_errand_deliver(array $u, array $loc, int $errandId): array
{
    $uid = (int)$u['id'];
    stop_errands_expire($uid);
    $e = q_one("SELECT * FROM stop_errands WHERE id = ? AND user_id = ? AND status = 'active'", [$errandId, $uid]);
    if (!$e || !$e['target_folk_id']) return [false, 'That errand is over.'];
    $target = q_one('SELECT * FROM stop_folk WHERE id = ?', [(int)$e['target_folk_id']]);
    if (!$target || (int)$target['location_id'] !== (int)$loc['id']) return [false, 'This isn’t where it needs to go.'];
    if (q("UPDATE stop_errands SET status = 'done', done_at = ? WHERE id = ? AND status = 'active'", [now(), $errandId])->rowCount() !== 1) return [false, 'That errand is over.'];
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [(int)$e['coins'], $uid]);
    add_xp($uid, (int)$e['xp'], 'rest_stop');
    stop_friend_add($uid, (int)$target['id'], 2);
    stop_friend_add($uid, (int)$e['folk_id'], 2);
    $giver = (string)q_val('SELECT name FROM stop_folk WHERE id = ?', [(int)$e['folk_id']]);
    if (function_exists('calling_event')) calling_event($uid, 'gift', 'stop:' . $target['id'], 1, ['npc' => 'stop-' . $target['id']]);
    return [true, npc_icon($target['species']) . ' ' . $target['name'] . ': “From ' . $giver . '? How kind. Thank you, ' . ($u['gnome_name'] ?: $u['username']) . '!” (+' . (int)$e['coins'] . ' ' . setting('currency_name') . ', +' . (int)$e['xp'] . ' XP, 💛 +2 with both)'];
}

function stop_errand_drop(array $u, int $errandId): array
{
    if (q("UPDATE stop_errands SET status = 'dropped' WHERE id = ? AND user_id = ? AND status = 'active'", [$errandId, (int)$u['id']])->rowCount() !== 1) return [false, 'That errand is over.'];
    return [true, 'You hand the errand back. No hard feelings.'];
}
