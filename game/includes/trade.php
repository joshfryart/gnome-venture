<?php
declare(strict_types=1);
/**
 * Trading (v0.7.10): notices, gifts, trade offers, market stalls and saplings.
 * Everything that moves items or coins between players runs in a transaction with checked updates,
 * so double clicks and two tabs can't duplicate anything.
 */
require_once __DIR__ . '/tools.php';   // v0.7.86: a worn tool can't be traded until it is mended

// ---------- Notices: short messages shown to a player on their next page load ----------

function notify(int $userId, string $text): void
{
    db_insert('notices', ['user_id' => $userId, 'text' => mb_substr($text, 0, 300), 'created_at' => now(), 'seen' => 0]);
}

/** Called from page_header: turn unseen notices into flash messages. */
function show_notices(int $userId): void
{
    if (random_int(1, 50) === 1) {   // v1.2.2: old read notices are swept now and then
        try { q('DELETE FROM notices WHERE seen = 1 AND created_at < ?', [gmdate('Y-m-d H:i:s', time() - 30 * 86400)]); } catch (Throwable $e) {}
    }
    $rows = q('SELECT id, text FROM notices WHERE user_id = ? AND seen = 0 ORDER BY id LIMIT 10', [$userId])->fetchAll();
    if (!$rows) return;
    q('UPDATE notices SET seen = 1 WHERE user_id = ? AND id <= ?', [$userId, (int)end($rows)['id']]);
    foreach ($rows as $r) flash('📬 ' . $r['text']);
}

// ---------- Shared checks ----------

function trade_allowed(array $u): ?string
{
    $need = (int)setting('trade_min_level');
    return (int)$u['level'] < $need ? 'Trading opens up at gnome level ' . $need . '.' : null;
}

/** Find another player by gnome name or log-in name (case-insensitive). */
function find_player(string $name, int $notId, bool $byLogin = true): ?array
{
    $name = trim($name);
    if ($name === '') return null;
    // v0.7.85: a gnome in a time-out can't be sent gifts or offers
    // v1.0.0: a gnome-name match beats a log-in-name match (oldest first), so a username can't hijack someone's gnome name
    $u = q_one('SELECT u.id, u.username, u.gnome_name, u.level, u.banned FROM users u WHERE (LOWER(u.gnome_name) = LOWER(?)' . ($byLogin ? ' OR LOWER(u.username) = LOWER(?)' : ' AND ? IS NOT NULL') . ') AND u.id <> ? AND '
        . gnome_in_play_sql('u') . ' AND u.onboarded = 1'
        . ' AND NOT EXISTS (SELECT 1 FROM player_blocks b WHERE (b.blocker_id = u.id AND b.blocked_id = ?) OR (b.blocker_id = ? AND b.blocked_id = u.id))'
        . ' ORDER BY (CASE WHEN LOWER(u.gnome_name) = LOWER(?) THEN 0 ELSE 1 END), u.id LIMIT 1', [$name, $name, $notId, $notId, $notId, $name]);   // v1.0.0: a blocked gnome can't be found for gifts
    return $u ?: null;
}

/** v1.0.0: the same checks as find_player, for a known gnome id (pal gifts: the name is never looked up again). */
function find_player_by_id(int $id, int $notId): ?array
{
    $u = q_one('SELECT u.id, u.username, u.gnome_name, u.level, u.banned FROM users u WHERE u.id = ? AND u.id <> ? AND '
        . gnome_in_play_sql('u') . ' AND u.onboarded = 1'
        . ' AND NOT EXISTS (SELECT 1 FROM player_blocks b WHERE (b.blocker_id = u.id AND b.blocked_id = ?) OR (b.blocker_id = ? AND b.blocked_id = u.id))', [$id, $notId, $notId, $notId]);
    return $u ?: null;
}

function pname(array $u): string
{
    return (string)($u['gnome_name'] ?: $u['username']);
}

function tradable_item(int $itemId): ?array
{
    return q_one('SELECT * FROM items WHERE id = ? AND tradable = 1', [$itemId]) ?: null;
}

// ---------- Gifts ----------

function send_gift(array $u, string $to, int $itemId, int $qty, int $coins, string $note, ?int $toId = null): array
{
    $uid = (int)$u['id'];
    if ($why = trade_allowed($u)) return [false, $why];
    if ($why = fresh_hold($u)) return [false, $why];   // v1.0.1: fresh gnome hold
    $r = $toId !== null ? find_player_by_id($toId, $uid) : find_player($to, $uid);   // v1.0.0: pal gifts pass the id
    if (!$r) return [false, 'No gnome by that name.'];
    $qty = max(0, $qty);
    $coins = max(0, $coins);
    if (($itemId <= 0 || $qty <= 0) && $coins <= 0) return [false, 'Pick something to give.'];
    $cap = (int)setting('gifts_per_day');
    if ((int)q_val('SELECT COUNT(*) FROM gifts WHERE from_id = ? AND sent_at > ?', [$uid, gmdate('Y-m-d H:i:s', time() - 86400)]) >= $cap) {
        return [false, "You can send $cap gifts a day."];
    }   // v1.2.2: counted again below under the sender's lock
    $item = $itemId > 0 && $qty > 0 ? tradable_item($itemId) : null;
    if ($itemId > 0 && $qty > 0 && !$item) return [false, 'That can’t be given away.'];
    if ($item && ($block = tool_trade_block($uid, $itemId))) return [false, $block];   // v0.7.86
    $note = mb_substr(trim(preg_replace('/\s+/u', ' ', $note)), 0, 140);
    require_once __DIR__ . '/moderation.php';
    if ($bad = text_problem($u, $note)) return [false, $bad];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // v1.2.2: one gift at a time per sender, so the daily cap can't be raced
    if ((int)q_val('SELECT COUNT(*) FROM gifts WHERE from_id = ? AND sent_at > ?', [$uid, gmdate('Y-m-d H:i:s', time() - 86400)]) >= $cap) {
        db()->rollBack();
        return [false, "You can send $cap gifts a day."];
    }
    if ($item && !give_item($uid, $itemId, -$qty)) {
        db()->rollBack();
        return [false, 'You don’t have that many.'];
    }
    if ($coins && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$coins, $uid, $coins])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You don’t have that much.'];
    }
    if ($item) give_item((int)$r['id'], $itemId, $qty);
    if ($coins) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $r['id']]);
    db_insert('gifts', ['from_id' => $uid, 'to_id' => $r['id'], 'item_id' => $item ? $itemId : null, 'qty' => $item ? $qty : 0,
        'coins' => $coins, 'note' => $note ?: null, 'sent_at' => now()]);
    $what = trim(($item ? $qty . ' × ' . $item['name'] : '') . ($item && $coins ? ' and ' : '') . ($coins ? money($coins) : ''));
    notify((int)$r['id'], '🎁 ' . pname($u) . ' sent you ' . $what . ($note ? ': “' . $note . '”' : '.'));
    db()->commit();
    return [true, '🎁 You send ' . $what . ' to ' . pname($r) . '.'];
}

// ---------- Trade offers ----------

/** Parse up to 3 item lines from a form: [[item_id, qty], ...] with duplicates merged. */
function trade_lines(array $ids, array $qtys): array
{
    $out = [];
    foreach (array_slice($ids, 0, 3, true) as $k => $id) {
        $id = (int)$id;
        $n = (int)($qtys[$k] ?? 0);
        if ($id > 0 && $n > 0) $out[$id] = ($out[$id] ?? 0) + $n;
    }
    return $out;
}

function trade_text(array $lines, int $coins): string
{
    $bits = [];
    foreach ($lines as $id => $n) $bits[] = $n . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$id]);
    if ($coins) $bits[] = money($coins);
    return $bits ? implode(', ', $bits) : 'nothing';
}

function make_offer(array $u, int $toId, array $give, int $giveCoins, array $want, int $wantCoins, string $note): array
{
    $uid = (int)$u['id'];
    if ($why = trade_allowed($u)) return [false, $why];
    $r = q_one('SELECT * FROM users u WHERE u.id = ? AND u.id <> ? AND ' . gnome_in_play_sql('u'), [$toId, $uid]);   // v0.7.85: not during a time-out
    if (!$r || q_val('SELECT 1 FROM player_blocks WHERE (blocker_id = ? AND blocked_id = ?) OR (blocker_id = ? AND blocked_id = ?)', [$uid, $toId, $toId, $uid])) return [false, 'No gnome by that name.'];   // v1.0.0: blocks both ways
    if (!$give && !$giveCoins) return [false, 'Offer something.'];
    if ($why = fresh_hold($u)) return [false, $why];   // v1.0.1: fresh gnome hold (the offer gives something)
    require_once __DIR__ . '/moderation.php';
    if ($bad = text_problem($u, $note)) return [false, $bad];
    if (!$want && !$wantCoins) return [false, 'Ask for something in return (or send a gift instead).'];
    if ((int)q_val("SELECT COUNT(*) FROM trade_offers WHERE from_id = ? AND status = 'open'", [$uid]) >= (int)setting('trades_open_max')) {
        return [false, 'You have too many open offers. Wait for answers or cancel one.'];
    }
    foreach (array_merge(array_keys($give), array_keys($want)) as $id) {
        if (!tradable_item((int)$id)) return [false, 'One of those items can’t be traded.'];
    }
    foreach (array_keys($give) as $id) {   // v0.7.86: a worn tool has to be mended before it's offered
        if ($block = tool_trade_block($uid, (int)$id)) return [false, $block];
    }
    $giveCoins = max(0, $giveCoins);
    $wantCoins = max(0, $wantCoins);
    db()->beginTransaction();
    // Your side is held until the offer is answered
    foreach ($give as $id => $n) {
        if (!give_item($uid, (int)$id, -$n)) {
            db()->rollBack();
            return [false, 'You don’t have enough of something you’re offering.'];
        }
    }
    if ($giveCoins && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$giveCoins, $uid, $giveCoins])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You don’t have that much to offer.'];
    }
    db_insert('trade_offers', ['from_id' => $uid, 'to_id' => $toId, 'give_items' => json_encode($give), 'give_coins' => $giveCoins,
        'want_items' => json_encode($want), 'want_coins' => $wantCoins, 'note' => mb_substr(trim($note), 0, 140) ?: null,
        'status' => 'open', 'created_at' => now()]);
    notify($toId, '🤝 ' . pname($u) . ' offers you a trade: ' . trade_text($give, $giveCoins) . ' for ' . trade_text($want, $wantCoins) . '. See the Trading Post.');
    db()->commit();
    return [true, '🤝 Offer sent to ' . pname($r) . '. What you offered is held until they answer.'];
}

/** Return the offerer's held side. */
function offer_refund(array $o): void
{
    foreach (json_decode((string)$o['give_items'], true) ?: [] as $id => $n) give_item((int)$o['from_id'], (int)$id, (int)$n);
    if ((int)$o['give_coins']) q('UPDATE users SET coins = coins + ? WHERE id = ?', [(int)$o['give_coins'], $o['from_id']]);
}

function answer_offer(array $u, int $offerId, string $answer): array
{
    $uid = (int)$u['id'];
    $o = q_one("SELECT * FROM trade_offers WHERE id = ? AND status = 'open'", [$offerId]);
    if (!$o) return [false, 'That offer is no longer open.'];
    $mine = (int)$o['from_id'] === $uid;
    if (!$mine && (int)$o['to_id'] !== $uid) return [false, 'That offer isn’t yours.'];
    $status = $answer === 'accept' && !$mine ? 'accepted' : ($mine ? 'cancelled' : 'declined');
    if ($status === 'accepted' && ((int)$o['want_coins'] > 0 || json_decode((string)$o['want_items'], true)) && ($why = fresh_hold($u))) return [false, $why];   // v1.0.1: the accepter would give something
    db()->beginTransaction();
    if (q("UPDATE trade_offers SET status = ?, closed_at = ? WHERE id = ? AND status = 'open'", [$status, now(), $offerId])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That offer is no longer open.'];
    }
    $give = json_decode((string)$o['give_items'], true) ?: [];
    $want = json_decode((string)$o['want_items'], true) ?: [];
    $from = q_one('SELECT * FROM users WHERE id = ?', [$o['from_id']]);
    if ($status === 'accepted') {
        foreach (array_keys($want) as $id) {   // v0.7.86: a worn tool you're asked for has to be mended first
            if ($block = tool_trade_block($uid, (int)$id)) {
                db()->rollBack();
                return [false, $block];
            }
        }
        foreach ($want as $id => $n) {
            if (!give_item($uid, (int)$id, -(int)$n)) {
                db()->rollBack();
                return [false, 'You don’t have everything they asked for.'];
            }
            give_item((int)$o['from_id'], (int)$id, (int)$n);
        }
        if ((int)$o['want_coins']) {
            if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [(int)$o['want_coins'], $uid, (int)$o['want_coins']])->rowCount() !== 1) {
                db()->rollBack();
                return [false, 'You don’t have the ' . money((int)$o['want_coins']) . ' they asked for.'];
            }
            q('UPDATE users SET coins = coins + ? WHERE id = ?', [(int)$o['want_coins'], $o['from_id']]);
        }
        foreach ($give as $id => $n) give_item($uid, (int)$id, (int)$n);
        if ((int)$o['give_coins']) q('UPDATE users SET coins = coins + ? WHERE id = ?', [(int)$o['give_coins'], $uid]);
        notify((int)$o['from_id'], '🤝 ' . pname($u) . ' accepted your trade! You got ' . trade_text($want, (int)$o['want_coins']) . '.');
        $msg = '🤝 Trade done! You got ' . trade_text($give, (int)$o['give_coins']) . '.';
    } else {
        offer_refund($o);
        if ($status === 'declined') notify((int)$o['from_id'], pname($u) . ' declined your trade offer. Your items are back in your satchel.');
        $msg = $status === 'declined' ? 'You decline the offer.' : 'You cancel your offer. Everything comes back to you.';
    }
    db()->commit();
    return [true, $msg];
}

/** Offers nobody answered within N days are returned. */
function expire_offers(): void
{
    $cut = gmdate('Y-m-d H:i:s', time() - (int)setting('trade_offer_days') * 86400);
    foreach (q("SELECT * FROM trade_offers WHERE status = 'open' AND created_at < ?", [$cut])->fetchAll() as $o) {
        db()->beginTransaction();
        if (q("UPDATE trade_offers SET status = 'expired', closed_at = ? WHERE id = ? AND status = 'open'", [now(), $o['id']])->rowCount() === 1) {
            offer_refund($o);
            notify((int)$o['from_id'], 'A trade offer wasn’t answered in time. Your items are back in your satchel.');
        }
        db()->commit();
    }
}

// ---------- Market stalls ----------

function list_for_sale(array $u, int $itemId, int $qty, int $price): array
{
    $uid = (int)$u['id'];
    if ($why = trade_allowed($u)) return [false, $why];
    if ($why = fresh_hold($u)) return [false, $why];   // v1.0.1: fresh gnome hold
    $item = tradable_item($itemId);
    if (!$item) return [false, 'That can’t be sold here.'];
    if ($block = tool_trade_block($uid, $itemId)) return [false, $block];   // v0.7.86
    if ($price > 1000000) return [false, 'Price too high (max ' . number_format(1000000) . ').'];   // v0.9.1a
    if ($qty < 1 || $price < 1) return [false, 'Set an amount and a price of at least 1.'];
    if ((int)q_val("SELECT COUNT(*) FROM stall_listings WHERE seller_id = ? AND qty > 0", [$uid]) >= (int)setting('stall_slots')) {
        return [false, 'Your stall is full (' . (int)setting('stall_slots') . ' listings). Take something down first.'];
    }
    db()->beginTransaction();
    if (!give_item($uid, $itemId, -$qty)) {
        db()->rollBack();
        return [false, 'You don’t have that many.'];
    }
    db_insert('stall_listings', ['seller_id' => $uid, 'item_id' => $itemId, 'qty' => $qty, 'price' => $price, 'listed_at' => now()]);
    db()->commit();
    return [true, '🏷️ ' . $qty . ' × ' . $item['name'] . ' on your stall at ' . money($price) . ' each.'];
}

function unlist(array $u, int $listingId): array
{
    $l = q_one('SELECT * FROM stall_listings WHERE id = ? AND seller_id = ? AND qty > 0', [$listingId, $u['id']]);
    if (!$l) return [false, 'That listing is gone.'];
    db()->beginTransaction();
    if (q('UPDATE stall_listings SET qty = 0 WHERE id = ? AND qty = ?', [$l['id'], $l['qty']])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'Someone just bought from it. Try again.'];
    }
    give_item((int)$u['id'], (int)$l['item_id'], (int)$l['qty']);
    db()->commit();
    return [true, 'You take it off your stall and put it back in your satchel.'];
}

function buy_listing(array $u, int $listingId, int $qty): array
{
    $uid = (int)$u['id'];
    if ($why = trade_allowed($u)) return [false, $why];
    if ($why = fresh_hold($u)) return [false, $why];   // v1.0.1: fresh gnome hold
    // v0.7.85: a stall whose owner is in a time-out can't be bought from
    $l = q_one('SELECT l.*, i.name FROM stall_listings l JOIN items i ON i.id = l.item_id JOIN users s ON s.id = l.seller_id
                WHERE l.id = ? AND l.qty > 0 AND ' . gnome_in_play_sql('s'), [$listingId]);
    if (!$l) return [false, 'Sold out!'];
    if ((int)$l['seller_id'] === $uid) return [false, 'That’s your own stall.'];
    $qty = max(1, min($qty, (int)$l['qty']));
    $cost = $qty * (int)$l['price'];
    $tax = intdiv($cost * (int)setting('stall_tax_percent'), 100);
    db()->beginTransaction();
    if (q('UPDATE stall_listings SET qty = qty - ?, sold = sold + ? WHERE id = ? AND qty >= ?', [$qty, $qty, $l['id'], $qty])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'Someone bought it first.'];
    }
    if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $uid, $cost])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You need ' . money($cost) . '.'];
    }
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [$cost - $tax, $l['seller_id']]);
    give_item($uid, (int)$l['item_id'], $qty);
    notify((int)$l['seller_id'], '🏷️ ' . pname($u) . ' bought ' . $qty . ' × ' . $l['name'] . ' from your stall. You earn ' . money($cost - $tax)
        . ($tax ? ' (after ' . money($tax) . ' market fee)' : '') . '.');
    db()->commit();
    return [true, 'You buy ' . $qty . ' × ' . $l['name'] . ' for ' . money($cost) . '.'];
}

// ---------- Saplings ----------

/** The sapling item for a plant, created the first time anyone raises one. */
function sapling_item(array $p): int
{
    $slug = $p['slug'] . '-sapling';
    $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
    if ($id) return $id;
    $word = in_array($p['kind'], ['tree', 'nut', 'fruit'], true) || (int)$p['perennial'] ? 'Sapling' : 'Seedling';
    $seedPrice = (int)q_val('SELECT base_price FROM items WHERE id = ?', [$p['seed_item_id']]);
    return db_insert('items', ['name' => $p['name'] . ' ' . $word, 'slug' => $slug, 'category' => 'sapling', 'rarity' => 30,
        'base_price' => max(20, $seedPrice * 5), 'tradable' => 1,
        'description' => 'A healthy young ' . $p['name'] . ' raised by a master gardener. Anyone can plant it, even without knowing the crop, '
            . 'and it starts ' . (int)setting('sapling_head_start') . '% grown.',
        'effects' => json_encode(['sapling' => (int)$p['id']])]);
}

/**
 * v0.7.86: saplings of a treasure crop need its region studied (home region, a garden there, or a guide or Journey
 * chapter), the same knowledge that planting a treasure crop needs. Mastery alone is not enough. Null when fine.
 */
function sapling_region_gate(array $u, array $p): ?string
{
    require_once __DIR__ . '/world.php';
    if (!empty(known_plants($u, false)[(int)$p['id']])) return null;
    $region = q_val("SELECT r.gnomish_name FROM plant_regions pr JOIN regions r ON r.id = pr.region_id
                     WHERE pr.plant_id = ? AND pr.tier = 'treasure' ORDER BY r.min_level LIMIT 1", [(int)$p['id']]);
    return $region ? 'You need to study ' . $region . ' before you can raise saplings of ' . $p['name'] . '.' : null;
}

/** Plants this player has mastered and can raise saplings from. */
function mastered_plants(int $uid): array
{
    return q('SELECT p.*, i.name AS seed_name, (SELECT qty FROM user_items WHERE user_id = ? AND item_id = p.seed_item_id) AS seeds
              FROM user_plant_knowledge k JOIN plants p ON p.id = k.plant_id JOIN items i ON i.id = p.seed_item_id
              WHERE k.user_id = ? AND k.knowledge >= p.knowledge_max AND p.kind <> \'cover\' ORDER BY p.name', [$uid, $uid])->fetchAll();
}

function saplings_left_today(array $u): int
{
    $day = hollow_date('Y-m-d');   // v0.7.85: the Hollow's day (midnight Halifax), like the landmarks and towns
    return max(0, (int)setting('saplings_per_day') - (($u['sapling_day'] ?? '') === $day ? (int)$u['sapling_count'] : 0));
}

function raise_sapling(array $u, int $plantId): array
{
    $uid = (int)$u['id'];
    $p = null;
    foreach (mastered_plants($uid) as $m) if ((int)$m['id'] === $plantId) $p = $m;
    if (!$p) return [false, 'You need to master a plant before you can raise saplings of it.'];
    if ($gate = sapling_region_gate($u, $p)) return [false, $gate];
    if (saplings_left_today($u) <= 0) return [false, 'You’ve raised all the saplings you can today. Come back tomorrow.'];
    $energy = (int)setting('sapling_energy');
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // v1.2.2: lock, then re-read today's count (the $u passed in may be stale)
    $fresh = q_one('SELECT sapling_day, sapling_count FROM users WHERE id = ?', [$uid]);
    if ($fresh && saplings_left_today($fresh) <= 0) {
        db()->rollBack();
        return [false, 'You’ve raised all the saplings you can today. Come back tomorrow.'];
    }
    if (!give_item($uid, (int)$p['seed_item_id'], -1)) {
        db()->rollBack();
        return [false, 'You need 1 × ' . $p['seed_name'] . ' to raise a sapling.'];
    }
    if (!spend_energy($uid, $energy)) {
        db()->rollBack();
        return [false, "You’re too tired. Raising a sapling takes ⚡$energy."];
    }
    $day = hollow_date('Y-m-d');   // v0.7.85
    q('UPDATE users SET sapling_count = CASE WHEN sapling_day = ? THEN sapling_count + 1 ELSE 1 END, sapling_day = ? WHERE id = ?', [$day, $day, $uid]);
    $sid = sapling_item($p);
    give_item($uid, $sid, 1);
    db()->commit();
    return [true, '🌱 You raise a ' . q_val('SELECT name FROM items WHERE id = ?', [$sid]) . '. Sell it on your stall, trade it, or give it to a friend.'];
}

function ensure_trade_content(): void
{
    if (q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'Trading' AND chapter = 'General'")) return;
    $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'Trading',
        'body' => "The [b]Trading Post[/b] is where gnomes swap and sell.\n\n"
            . "🏷️ [b]Market stalls:[/b] put things on your stall at your own price. Other gnomes buy them while you’re away; a small market fee is taken.\n"
            . "🤝 [b]Trades:[/b] offer your things for theirs. What you offer is held until they answer.\n"
            . "🎁 [b]Gifts:[/b] send items or Petals to a friend.\n"
            . "🌱 [b]Saplings:[/b] once you master a plant, raise saplings of it from its seeds. Anyone can plant a sapling, even a crop they don’t know yet, and it starts part-grown.",
        'unlock_key' => 'start', 'hint' => '', 'sort_order' => 5]);
    foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
        db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
    }
}
