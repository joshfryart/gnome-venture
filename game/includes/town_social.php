<?php
declare(strict_types=1);
/**
 * Gnomes meeting in town (v0.7.22). No chat: waves, sitting on a bench together, sharing a snack,
 * and friendly rock-paper-trowel. Plus NPC favours on the notice board.
 * A gnome is "at" a place for 15 minutes after they last looked at it. Anyone can hide from the lists (Account page).
 */

require_once __DIR__ . '/town.php';
require_once __DIR__ . '/npc_life.php';

const TOWN_PRESENCE_MINUTES = 15;
const RPS_MOVES = ['rock' => '✊ Rock', 'paper' => '✋ Paper', 'trowel' => '🔪 Trowel'];

function ensure_town_social(): void
{
    if (q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'Meeting other gnomes' AND chapter = 'General'")) return;
    $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'Meeting other gnomes',
        'body' => "When you visit a place in a town square, other gnomes there can see you, and you can see them, for about 15 minutes.\n\n"
            . "👋 [b]Wave[/b] to say hello. 🪑 On the Green, [b]sit on a bench together[/b]: you both get a little energy, once a day. "
            . "🍪 [b]Share a snack[/b] from your satchel. ✊ Challenge someone to friendly [b]rock-paper-trowel[/b], just for bragging rights.\n\n"
            . "📌 Once a townsfolk knows you (an Acquaintance or better), they’ll pin a [b]favour[/b] to the town’s notice board each week. "
            . "Bring what they ask for, for Petals and friendship.\n\n"
            . "Rather not be seen? You can hide yourself from the lists on your Account page.",
        'unlock_key' => 'start', 'hint' => '', 'sort_order' => 11]);
    foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
        if (!q_val('SELECT 1 FROM user_encyclopedia WHERE user_id = ? AND entry_id = ?', [$uid, $eid])) {
            db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
        }
    }
}

function town_mark_present(int $uid, int $spotId): void
{
    q('UPDATE users SET town_spot_id = ?, town_seen = ? WHERE id = ?', [$spotId, now(), $uid]);
}

function town_presence_cut(): string
{
    return gmdate('Y-m-d H:i:s', time() - TOWN_PRESENCE_MINUTES * 60);
}

/** Other gnomes at a place right now (not hidden, not in a time-out). */
function gnomes_at_spot(int $spotId, int $exceptUid): array
{
    return q('SELECT u.id, u.username, u.gnome_name, u.level, u.hat_color, u.hat_dye, u.beard_color, u.calling, u.calling_qt FROM users u
              WHERE u.town_spot_id = ? AND u.town_seen > ? AND u.id <> ? AND ' . gnome_in_play_sql('u') . ' AND u.town_hidden = 0 AND u.onboarded = 1
              ORDER BY u.town_seen DESC LIMIT 30', [$spotId, town_presence_cut(), $exceptUid])->fetchAll();
}

function gnome_count_at_spot(int $spotId, int $exceptUid): int
{
    return (int)q_val('SELECT COUNT(*) FROM users u WHERE u.town_spot_id = ? AND u.town_seen > ? AND u.id <> ? AND ' . gnome_in_play_sql('u') . ' AND u.town_hidden = 0 AND u.onboarded = 1',
        [$spotId, town_presence_cut(), $exceptUid]);
}

/** Both gnomes at the same place right now? Returns [me, them, spot] or an error string. */
function town_pair(array $u, int $otherId, int $spotId)
{
    $me = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
    $spot = q_one('SELECT * FROM town_spots WHERE id = ? AND active = 1', [$spotId]);
    if (!$spot) return 'That place has gone.';
    if ((int)$me['town_spot_id'] !== $spotId || (string)$me['town_seen'] <= town_presence_cut() || !can_reach($me, (string)$spot['region'])) return 'You need to be at ' . $spot['name'] . ' too.';
    if ($otherId === (int)$me['id']) return 'That’s you!';
    $them = q_one('SELECT * FROM users u WHERE u.id = ? AND ' . gnome_in_play_sql('u') . ' AND u.town_hidden = 0 AND u.onboarded = 1', [$otherId]);
    if (!$them || (int)$them['town_spot_id'] !== $spotId || (string)$them['town_seen'] <= town_presence_cut()) return 'They’ve wandered off.';
    return [$me, $them, $spot];
}

/** Record a once-a-day meeting; false if it already happened today. */
function town_meet_once(int $a, int $b, string $kind): bool
{
    try {
        db_insert('town_meets', ['a_id' => $a, 'b_id' => $b, 'kind' => $kind, 'day' => town_day(), 'at' => now()]);
        return true;
    } catch (PDOException $e) {
        return false;
    }
}

function town_wave(array $u, int $otherId, int $spotId): array
{
    $p = town_pair($u, $otherId, $spotId);
    if (is_string($p)) return [false, $p];
    [$me, $them, $spot] = $p;
    if (!town_meet_once((int)$me['id'], (int)$them['id'], 'wave')) return [false, 'You’ve already waved at ' . gnome_name($them) . ' today.'];
    require_once __DIR__ . '/trade.php';
    notify((int)$them['id'], '👋 ' . gnome_name($me) . ' waved at you at ' . $spot['name'] . ' (' . $spot['region'] . ').');
    return [true, '👋 You wave at ' . gnome_name($them) . '. They’ll see it next time they look up.'];
}

function town_bench(array $u, int $otherId, int $spotId): array
{
    $p = town_pair($u, $otherId, $spotId);
    if (is_string($p)) return [false, $p];
    [$me, $them, $spot] = $p;
    if ($spot['kind'] !== 'green') return [false, 'There are no benches here. Try the Green.'];
    $day = town_day();
    $had = fn(int $id) => (bool)q_val("SELECT 1 FROM town_meets WHERE kind = 'bench' AND day = ? AND (a_id = ? OR b_id = ?)", [$day, $id, $id]);
    if ($had((int)$me['id'])) return [false, 'You’ve already shared a bench today. Tomorrow!'];
    $theyHad = $had((int)$them['id']);
    db()->beginTransaction();
    if (!town_meet_once((int)$me['id'], (int)$them['id'], 'bench')) {
        db()->rollBack();
        return [false, 'You’ve already shared a bench today. Tomorrow!'];
    }
    require_once __DIR__ . '/events.php';
    require_once __DIR__ . '/trade.php';
    $lines = apply_event_effect($me, 'energy:2');
    if (!$theyHad) apply_event_effect($them, 'energy:2');
    db()->commit();
    notify((int)$them['id'], '🪑 ' . gnome_name($me) . ' sat on a bench with you at ' . $spot['name'] . '.' . ($theyHad ? '' : ' Good company: +2 energy!'));
    prize('🪑', 'Good company', 'You and ' . gnome_name($them) . ' sit and watch the ducks for a while.', $lines);
    return [true, ''];
}

function town_snack(array $u, int $otherId, int $spotId, int $itemId): array
{
    require_once __DIR__ . '/trade.php';
    if ($why = trade_allowed($u)) return [false, $why];
    if ($why = fresh_hold($u)) return [false, $why];   // v1.0.1: fresh gnome hold
    $p = town_pair($u, $otherId, $spotId);
    if (is_string($p)) return [false, $p];
    [$me, $them] = $p;
    $item = q_one("SELECT * FROM items WHERE id = ? AND category = 'food' AND tradable = 1", [$itemId]);
    if (!$item) return [false, 'Choose something to eat to share.'];
    db()->beginTransaction();
    if (!town_meet_once((int)$me['id'], (int)$them['id'], 'snack')) {
        db()->rollBack();
        return [false, 'You’ve already shared a snack with ' . gnome_name($them) . ' today.'];
    }
    if (!give_item((int)$me['id'], $itemId, -1)) {
        db()->rollBack();
        return [false, 'You don’t have one of those.'];
    }
    give_item((int)$them['id'], $itemId, 1);
    add_xp((int)$me['id'], 2);
    db()->commit();
    notify((int)$them['id'], '🍪 ' . gnome_name($me) . ' shared a ' . $item['name'] . ' with you!');
    return [true, '🍪 You share a ' . $item['name'] . ' with ' . gnome_name($them) . '. Kindness is its own reward (and +2 XP).'];
}

function town_rps_challenge(array $u, int $otherId, int $spotId, string $move): array
{
    if (!isset(RPS_MOVES[$move])) return [false, 'Pick rock, paper or trowel.'];
    $p = town_pair($u, $otherId, $spotId);
    if (is_string($p)) return [false, $p];
    [$me, $them, $spot] = $p;
    $cut = town_presence_cut();
    if (q_val("SELECT 1 FROM town_rps WHERE status = 'open' AND created_at > ? AND ((from_id = ? AND to_id = ?) OR (from_id = ? AND to_id = ?))",
        [$cut, $me['id'], $them['id'], $them['id'], $me['id']])) return [false, 'There’s already a game waiting between you two.'];
    if ((int)q_val('SELECT COUNT(*) FROM town_rps WHERE from_id = ? AND created_at > ?', [$me['id'], gmdate('Y-m-d H:i:s', time() - 86400)]) >= 20) {
        return [false, 'That’s a lot of games for one day! Rest your hands.'];
    }
    db_insert('town_rps', ['from_id' => $me['id'], 'to_id' => $them['id'], 'spot_id' => $spotId, 'move_a' => $move, 'status' => 'open', 'created_at' => now()]);
    require_once __DIR__ . '/trade.php';
    notify((int)$them['id'], '✊ ' . gnome_name($me) . ' challenged you to rock-paper-trowel at ' . $spot['name'] . '! Go there to play.');
    return [true, '✊ Challenge sent! Your move is a secret until ' . gnome_name($them) . ' plays.'];
}

/** Games waiting for this gnome to play, at this place. */
function town_rps_waiting(int $uid, int $spotId): array
{
    return q("SELECT r.*, COALESCE(u.gnome_name, u.username) AS from_name FROM town_rps r JOIN users u ON u.id = r.from_id
              WHERE r.to_id = ? AND r.spot_id = ? AND r.status = 'open' AND r.created_at > ? ORDER BY r.id", [$uid, $spotId, town_presence_cut()])->fetchAll();
}

function town_rps_play(array $u, int $gameId, string $move): array
{
    if (!isset(RPS_MOVES[$move])) return [false, 'Pick rock, paper or trowel.'];
    $g = q_one("SELECT * FROM town_rps WHERE id = ? AND to_id = ? AND status = 'open' AND created_at > ?", [$gameId, $u['id'], town_presence_cut()]);
    if (!$g) return [false, 'That game has finished or gone stale.'];
    if (q("UPDATE town_rps SET move_b = ?, status = 'done', done_at = ? WHERE id = ? AND status = 'open'", [$move, now(), $gameId])->rowCount() !== 1) {
        return [false, 'That game has finished.'];
    }
    $beats = ['rock' => 'trowel', 'trowel' => 'paper', 'paper' => 'rock'];
    $a = (string)$g['move_a'];
    $result = $a === $move ? 'draw' : ($beats[$move] === $a ? 'win' : 'lose');   // from this player's side
    $other = q_one('SELECT id, username, gnome_name FROM users WHERE id = ?', [$g['from_id']]);
    if ($result === 'win') q('UPDATE users SET rps_wins = rps_wins + 1 WHERE id = ?', [$u['id']]);
    if ($result === 'lose') q('UPDATE users SET rps_wins = rps_wins + 1 WHERE id = ?', [$g['from_id']]);
    require_once __DIR__ . '/trade.php';
    $line = gnome_name($other) . ': ' . RPS_MOVES[$a] . ' · You: ' . RPS_MOVES[$move];
    notify((int)$g['from_id'], '✊ Rock-paper-trowel with ' . gnome_name($u) . ': you played ' . RPS_MOVES[$a] . ', they played ' . RPS_MOVES[$move] . '. '
        . ['win' => 'They win!', 'lose' => 'You win!', 'draw' => 'A draw!'][$result]);
    prize(['win' => '🏆', 'lose' => '🙃', 'draw' => '🤝'][$result], ['win' => 'You win!', 'lose' => 'You lose!', 'draw' => 'A draw!'][$result], 'Rock, paper, trowel!', [$line]);
    return [true, ''];
}

// ---------------- NPC favours ----------------

/** This week's favour from an NPC to this gnome, or null if they don't know each other well enough yet. */
function favour_offer(int $uid, array $npc, string $town): ?array
{
    require_once __DIR__ . '/friends.php';
    require_once __DIR__ . '/jobs.php';
    $f = friendship($uid, (int)$npc['id']);
    if (friend_level((int)$f['points'])['index'] < 1) return null;
    $week = job_period_key('weekly');
    $r = region_by_name($town);
    $items = q('SELECT DISTINCT i.id, i.name, i.base_price FROM plants p JOIN items i ON i.id = p.produce_item_id
                WHERE p.common = 1' . ($r ? ' OR p.id IN (SELECT plant_id FROM plant_regions WHERE region_id = ' . (int)$r['id'] . " AND tier = 'staple')" : '') . ' ORDER BY i.id')->fetchAll();
    if (!$items) return null;
    $h = crc32($uid . '|' . $npc['id'] . '|' . $week);
    $it = $items[$h % count($items)];
    $qty = 3 + intdiv($h, 7) % 6;
    $done = (bool)q_val('SELECT 1 FROM npc_favours WHERE user_id = ? AND npc_id = ? AND week = ?', [$uid, $npc['id'], $week]);
    return ['item' => $it, 'qty' => $qty, 'coins' => max(30, intdiv((int)$it['base_price'] * $qty * max(0, (int)setting('favour_pay_percent')), 100)), 'week' => $week, 'done' => $done];
}

/** The townsfolk of a town (their favourite place is here), for the notice board. */
function town_folk(string $town): array
{
    return q('SELECT n.* FROM npcs n JOIN town_spots t ON t.id = n.fav_spot_id WHERE t.region = ? AND n.active = 1 AND n.traveller IS NULL ORDER BY n.name', [$town])->fetchAll();
}

function favour_deliver(array $u, int $npcId, string $town): array
{
    $uid = (int)$u['id'];
    if (!can_reach($u, $town)) return [false, 'You need to be in ' . $town . '.'];
    $npc = q_one('SELECT n.* FROM npcs n JOIN town_spots t ON t.id = n.fav_spot_id WHERE n.id = ? AND t.region = ? AND n.active = 1', [$npcId, $town]);
    if (!$npc) return [false, 'Nobody here asked for that.'];
    $o = favour_offer($uid, $npc, $town);
    if (!$o) return [false, 'Get to know ' . $npc['name'] . ' a little first.'];
    db()->beginTransaction();
    try {
        db_insert('npc_favours', ['user_id' => $uid, 'npc_id' => $npcId, 'week' => $o['week'], 'done_at' => now()]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, 'You’ve already done ' . $npc['name'] . '’s favour this week.'];
    }
    if (!give_item($uid, (int)$o['item']['id'], -$o['qty'])) {
        db()->rollBack();
        return [false, 'You need ' . $o['qty'] . ' × ' . $o['item']['name'] . '.'];
    }
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [$o['coins'], $uid]);
    add_xp($uid, 10);
    $new = friend_add($uid, $npcId, 10);
    db()->commit();
    prize(npc_icon($npc['species']), $npc['name'] . ' is delighted!', '“Oh, thank you! Just what I needed.”',
        ['−' . $o['qty'] . ' × ' . $o['item']['name'], '+' . money($o['coins']), '+10 XP', '💛 +10 friendship (' . friend_level($new)['name'] . ')']);
    return [true, ''];
}
