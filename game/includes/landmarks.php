<?php
declare(strict_types=1);
/**
 * Landmark gameplay (v0.7.26). Landmarks are found off the road (see explore.php) and each kind has its own thing:
 *   🏕️ Havens: safe stops. Rest by the fire (energy, once a day), stay the night (a 2-hour boost) and a little pantry.
 *   ✨ Wonders: once a day, investigate. Three approaches (stat checks); the wonder's own skill is easiest. Good finds.
 *   🕳️ Delves: once a day, a five-room loot run (creatures, traps, treasure) ending in a chest. Leave any time.
 *   🐉 Lairs: once a day, challenge the landscape's legendary boss. First win: a ribbon and a big reward.
 * Delves and lairs use the expeditions table (kind 'delve' / 'lair') so the fight screens and adventure bar just work.
 */

require_once __DIR__ . '/roads.php';
require_once __DIR__ . '/rebuild.php';   // v0.7.88: ruins are per gnome (landmark_rebuilt_by)

const DELVE_ROOMS = 5;

/** Stat words in a wonder's description, so its "own" approach fits it. */
const WONDER_STAT_WORDS = [
    'lore' => ['read', 'ring', 'book', 'riddle', 'scroll', 'rune', 'study', 'lore', 'archive', 'map', 'script', 'temple', 'library', 'oracle', 'wise'],
    'sense' => ['listen', 'watch', 'star', 'aurora', 'light', 'spot', 'echo', 'whisper', 'mirror', 'see', 'sky', 'glow', 'dream'],
    'charm' => ['help', 'trade', 'sing', 'song', 'dance', 'ceremony', 'blessing', 'festival', 'keeper', 'tea', 'cup', 'market', 'spirit'],
    'nimble' => ['climb', 'swim', 'balance', 'bridge', 'cross', 'leap', 'maze', 'rope', 'wave', 'tide', 'surf'],
    'grit' => ['lift', 'push', 'dig', 'break', 'stone', 'boulder', 'mine', 'forge', 'anvil', 'hammer', 'relight'],
    'hardiness' => ['cold', 'heat', 'hot', 'spring', 'steam', 'endure', 'ice', 'storm', 'desert', 'sand'],
];
const WONDER_APPROACHES = [
    'lore' => ['📚', 'Study it closely'], 'sense' => ['👁️', 'Look and listen'], 'charm' => ['🌼', 'Ask the locals about it'],
    'nimble' => ['🤸', 'Clamber all over it'], 'grit' => ['💪', 'Get your hands dirty'], 'hardiness' => ['🛡️', 'Wait it out, whatever it takes'],
];

/** The landmark at a location, with its kind and level. */
function landmark_at(int $locId): ?array
{
    $lm = q_one('SELECT lm.*, l.name AS loc_name, l.landscape, l.slug AS loc_slug, l.region AS region_name FROM landmarks lm JOIN locations l ON l.id = lm.location_id WHERE lm.location_id = ?', [$locId]);
    if (!$lm) return null;
    $r = q_one("SELECT level, min_level, max_level FROM routes WHERE kind = 'side' AND b_id = ? LIMIT 1", [$locId]);
    $lm['level'] = max(1, (int)($r['min_level'] ?? 1));
    if ($lm['kind'] === 'lair' && ($boss = lair_boss($lm))) $lm['level'] = (int)$boss['level'];
    return $lm;
}

function landmark_day(): string
{
    return hollow_date('Y-m-d');
}

/** Use a once-a-day thing at a landmark. False if already done today. */
function landmark_once(int $uid, int $lmId, string $action): bool
{
    try {
        db_insert('landmark_uses', ['user_id' => $uid, 'landmark_id' => $lmId, 'action' => $action, 'day' => landmark_day(), 'at' => now()]);
        return true;
    } catch (PDOException $e) {
        return false;
    }
}

function landmark_done_today(int $uid, int $lmId, string $action): bool
{
    return (bool)q_val('SELECT 1 FROM landmark_uses WHERE user_id = ? AND landmark_id = ? AND action = ? AND day = ?', [$uid, $lmId, $action, landmark_day()]);
}

/** Is the gnome standing at this landmark (and not mid-walk)? */
function at_landmark(array $u, int $lmId): ?array
{
    require_once __DIR__ . '/adventure.php';
    $lm = q_one('SELECT * FROM landmarks WHERE id = ?', [$lmId]);
    if (!$lm || (int)($u['location_id'] ?? 0) !== (int)$lm['location_id']) return null;
    if (active_expedition((int)$u['id'])) return null;
    return landmark_at((int)$lm['location_id']);
}

// ---------------- Havens ----------------

/** The stat a haven's night's stay boosts (from its description), and how long. */
function haven_stat(array $lm): string
{
    $d = strtolower((string)$lm['description']);
    foreach (['luck' => ['luck', 'aurora', 'star', 'wish', 'clover'], 'hardiness' => ['rest', 'warm', 'fire', 'hot', 'soup', 'spring'],
              'charm' => ['song', 'tea', 'music', 'dance', 'feast'], 'lore' => ['library', 'story', 'scroll', 'book'], 'sense' => ['view', 'lookout', 'watch']] as $stat => $words) {
        foreach ($words as $w) if (str_contains($d, $w)) return $stat;
    }
    return ['hardiness', 'luck', 'charm', 'sense'][crc32((string)$lm['name']) % 4];
}

/** Today's pantry: three things for sale, the same for everyone today. [[item, price], …] */
function haven_pantry(array $lm, int $uid): array
{
    $day = landmark_day();
    $pick = function (array $rows, string $salt) use ($lm, $day) {
        return $rows ? $rows[crc32($lm['id'] . '|' . $day . '|' . $salt) % count($rows)] : null;
    };
    $out = [];
    $seed = $pick(q("SELECT i.id, i.name, i.base_price FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id JOIN items i ON i.id = p.seed_item_id
                     WHERE pr.region_id = ? AND pr.tier = 'uncommon' ORDER BY i.id", [$lm['region_id']])->fetchAll(), 'seed');
    $food = $pick(q("SELECT id, name, base_price FROM items WHERE category = 'food' AND base_price > 0 ORDER BY id")->fetchAll(), 'food');
    $find = $pick(q("SELECT i.id, i.name, i.base_price FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.rarity = 'uncommon' AND g.active = 1 ORDER BY i.id")->fetchAll(), 'find');
    // A haven this gnome made safe (v0.7.29; v0.7.88: for that gnome only) also stocks building materials
    $build = landmark_rebuilt_by($lm, $uid) ? $pick(q("SELECT id, name, base_price FROM items WHERE slug IN ('building-stone', 'timber-plank', 'rope') ORDER BY id")->fetchAll(), 'build') : null;
    foreach ([$seed, $food, $find, $build] as $it) {
        if ($it) $out[] = [$it, max(5, (int)round((int)$it['base_price'] * 1.3))];
    }
    return $out;
}

function haven_act(array $u, int $lmId, string $what, int $itemId = 0): array
{
    $lm = at_landmark($u, $lmId);
    if (!$lm || $lm['kind'] !== 'haven') return [false, 'You need to be at the haven.'];
    $uid = (int)$u['id'];
    require_once __DIR__ . '/events.php';
    if ($what === 'rest') {
        // v0.7.85: a full gnome gets nothing, and the day's rest is not spent
        require_once __DIR__ . '/gnome.php';   // max_energy()
        if ((int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) >= max_energy($u)) {
            return [false, 'You’re already full of energy. Come back to rest when you’re tired.'];
        }
        if (!landmark_once($uid, $lmId, 'rest')) return [false, 'You’ve already rested here today.'];
        calling_event($uid, 'haven', 'lm:' . $lmId, 1, ['act' => 'rest']);   // v0.9.4 N3: a haven used
        prize('🔥', $lm['name'], 'You doze by the fire while the kettle sings.', apply_event_effect($u, 'energy:' . (landmark_rebuilt_by($lm, $uid) ? 6 : 4)));   // v0.7.88: a rested fire for the gnome who made it safe
        return [true, ''];
    }
    if ($what === 'stay') {
        if (!landmark_once($uid, $lmId, 'stay')) return [false, 'You’ve already stayed the night here today.'];
        if (q('UPDATE users SET coins = coins - 20 WHERE id = ? AND coins >= 20', [$uid])->rowCount() !== 1) {
            q('DELETE FROM landmark_uses WHERE user_id = ? AND landmark_id = ? AND action = ? AND day = ?', [$uid, $lmId, 'stay', landmark_day()]);
            return [false, 'A bed for the night costs ' . money(20) . '.'];
        }
        $stat = haven_stat($lm);
        calling_event($uid, 'haven', 'lm:' . $lmId, 1, ['act' => 'stay']);   // v0.9.4 N3
        prize('🛏️', $lm['name'], 'You sleep soundly and wake up feeling wonderful.', array_merge(['−' . money(20)], apply_event_effect($u, 'tbuff:' . $stat . ':3:120+energy:2')));
        return [true, ''];
    }
    if ($what === 'buy') {
        foreach (haven_pantry($lm, $uid) as [$it, $price]) {
            if ((int)$it['id'] !== $itemId) continue;
            if (!landmark_once($uid, $lmId, 'buy' . $itemId)) return [false, 'One of each a day, the keeper says. There has to be some left for the next traveller.'];
            db()->beginTransaction();
            if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$price, $uid, $price])->rowCount() !== 1) {
                db()->rollBack();
                q('DELETE FROM landmark_uses WHERE user_id = ? AND landmark_id = ? AND action = ? AND day = ?', [$uid, $lmId, 'buy' . $itemId, landmark_day()]);
                return [false, 'You need ' . money($price) . '.'];
            }
            give_item($uid, (int)$it['id'], 1);
            db()->commit();
            return [true, '🧺 You buy ' . $it['name'] . ' for ' . money($price) . '.'];
        }
        return [false, 'That’s not in the pantry today.'];
    }
    return [false, 'Unknown action.'];
}

// ---------------- Wonders ----------------

/** v1.9.4: data/wonder_text.txt as [slugified name => [intro, success, fail]] plus the three daily moods under '*easy', '*plain', '*hard'. */
function wonder_texts(bool $reload = false): array
{
    static $rows = null;
    if ($rows !== null && !$reload) return $rows;
    $rows = [];
    $path = __DIR__ . '/data/wonder_text.txt';
    if (!is_file($path)) return $rows;
    foreach (file($path, FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $f = array_map('trim', explode('|', $line));
        if (count($f) < 2 || $f[0] === '') continue;
        if ($f[0][0] === '*') { if ($f[1] !== '') $rows[$f[0]][] = $f[1]; continue; }
        $rows[slugify($f[0])] = [$f[1], $f[2] ?? '', $f[3] ?? ''];
    }
    return $rows;
}

/** One of a wonder's own texts ('intro', 'success', 'fail'), or '' (then the generic text is used). */
function wonder_text(array $lm, string $which): string
{
    $row = wonder_texts()[slugify((string)$lm['name'])] ?? null;
    return $row ? (string)$row[['intro' => 0, 'success' => 1, 'fail' => 2][$which] ?? 0] : '';
}

/**
 * v1.9.4: what the wonder is like today. It changes with the Hollow day (the same for everyone): [dc change -1/0/+1, a line about it].
 * The wonder's own approach stays the easiest way in; which two others sit beside it, and how hard they all are, follow the day.
 */
function wonder_mood(array $lm, ?string $day = null): array
{
    $h = crc32((string)$lm['name'] . '|mood|' . ($day ?? landmark_day()));
    $delta = ($h % 3) - 1;
    $lines = wonder_texts()[['-1' => '*easy', '0' => '*plain', '1' => '*hard'][(string)$delta]] ?? [];
    return [$delta, $lines ? $lines[intdiv($h, 3) % count($lines)] : ''];
}

/** The three approaches for a wonder: [stat => [icon, label, dc]]; its own skill is 2 easier. The other two and the difficulty change with the day. */
function wonder_approaches(array $lm, int $uid, ?string $day = null): array
{
    $d = strtolower($lm['description'] . ' ' . $lm['name']);
    $own = null;
    foreach (WONDER_STAT_WORDS as $stat => $words) {
        foreach ($words as $w) if (str_contains($d, $w)) { $own = $stat; break 2; }
    }
    $own ??= array_keys(WONDER_APPROACHES)[crc32((string)$lm['name']) % 6];
    $others = array_values(array_diff(array_keys(WONDER_APPROACHES), [$own]));
    $h = crc32((string)$lm['name'] . '|' . ($day ?? landmark_day()));   // v1.9.4: was the name alone, so it never changed
    $a = $h % 5;
    $b = ($a + 1 + intdiv($h, 5) % 4) % 5;
    $pick = [$own, $others[$a], $others[$b]];
    $base = 10 + intdiv((int)$lm['level'], 2) - (landmark_rebuilt_by($lm, $uid) ? 1 : 0) + wonder_mood($lm, $day)[0];   // a wonder made safe for you is a little easier (v0.7.88)
    $out = [];
    foreach ($pick as $i => $stat) $out[$stat] = [WONDER_APPROACHES[$stat][0], WONDER_APPROACHES[$stat][1], $i === 0 ? $base - 2 : $base + 1];
    return $out;
}

function wonder_try(array $u, int $lmId, string $stat): array
{
    $lm = at_landmark($u, $lmId);
    if (!$lm || $lm['kind'] !== 'wonder') return [false, 'You need to be at the wonder.'];
    $ways = wonder_approaches($lm, (int)$u['id']);
    if (!isset($ways[$stat])) return [false, 'Pick one of the ways to investigate.'];
    $uid = (int)$u['id'];
    if (!landmark_once($uid, $lmId, 'wonder')) return [false, 'You’ve explored this wonder today. Come back tomorrow, it changes with the days.'];
    [$icon, $label, $dc] = $ways[$stat];
    $roll = random_int(1, 20);
    $total = $roll + eff_mod($u, $stat) + calling_perk($u, 'wonder_bonus');   // v0.9.1: Seedkeepers read wonders better
    $lines = [GNOME_STATS[$stat][0] . ' ' . $total . ' vs ' . $dc];
    require_once __DIR__ . '/events.php';
    $lvl = (int)$lm['level'];
    if ($total >= $dc) {
        $lines = array_merge($lines, apply_event_effect($u, 'xp:' . (8 + $lvl) . '+coins:' . (10 + 3 * $lvl) . '-' . (20 + 5 * $lvl)));
        $prize = q_one("SELECT i.id, i.name FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.active = 1 AND g.rarity = ? ORDER BY " . sql_random() . ' LIMIT 1',
            [$roll >= 18 || random_int(1, 100) <= min(40, 5 + 2 * $lvl) ? 'rare' : 'uncommon']);
        if ($prize) { give_item($uid, (int)$prize['id'], 1); $lines[] = '+1 × ' . $prize['name']; }
        if (random_int(1, 100) <= 25 && ($s = q_one("SELECT i.id, i.name FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id JOIN items i ON i.id = p.seed_item_id
                                          WHERE pr.region_id = ? AND pr.tier IN ('uncommon', 'treasure') ORDER BY " . sql_random() . ' LIMIT 1', [$lm['region_id']]))) {
            give_item($uid, (int)$s['id'], 1);
            $lines[] = '+1 × ' . $s['name'];
        }
        prize('✨', $lm['name'] . ': ' . $label, wonder_text($lm, 'success') ?: 'The wonder gives up one of its secrets!', $lines);   // v1.9.4: its own words
        calling_event($uid, 'wonder', 'lm:' . $lmId, 1);   // v0.9.4 N3: a wonder solved
    } else {
        $lines = array_merge($lines, apply_event_effect($u, 'xp:3'));
        prize('✨', $lm['name'] . ': ' . $label, wonder_text($lm, 'fail') ?: 'It keeps its secrets today. You learn a little anyway.', $lines);
    }
    return [true, ''];
}

// ---------------- Delves ----------------

/**
 * v1.9.5: one short line of text for a delve room (data/delve_rooms.txt: kind|cond|lands|text). Picked from the delve and the room
 * number, so a room always reads the same. Returns '' when no line fits (the room then shows only its number).
 */
function delve_room_line(string $kind, string $land, string $seed): string
{
    static $rows = null;
    if ($rows === null) {
        $rows = [];
        $path = __DIR__ . '/data/delve_rooms.txt';
        foreach (is_file($path) ? file($path, FILE_IGNORE_NEW_LINES) : [] as $line) {
            $line = trim($line);
            if ($line === '' || $line[0] === '#') continue;
            $f = array_map('trim', explode('|', $line, 4));
            if (count($f) < 4 || $f[3] === '') continue;
            $lands = $f[2] === '' || strtolower($f[2]) === 'any' ? ['any'] : array_map('strtolower', array_map('trim', explode(',', $f[2])));
            $rows[] = ['kind' => strtolower($f[0]), 'cond' => $f[1] === '' ? '-' : $f[1], 'lands' => $lands, 'text' => $f[3]];
        }
    }
    $now = function_exists('stop_now') ? stop_now([]) : [];
    $pool = [];
    foreach ($rows as $r) {
        if ($r['kind'] !== $kind) continue;
        if ($r['lands'] !== ['any'] && !in_array($land, $r['lands'], true)) continue;
        if ($r['cond'] !== '-' && $r['cond'] !== '' && !stop_cond_ok(ltrim($r['cond'], '!'), $now)) continue;
        $pool[] = $r['text'];
    }
    return $pool ? $pool[crc32($kind . '|' . $land . '|' . $seed) % count($pool)] : '';
}

function delve_start(array $u, int $lmId): array
{
    $lm = at_landmark($u, $lmId);
    if (!$lm || $lm['kind'] !== 'delve') return [false, 'You need to be at the delve’s entrance.'];
    $uid = (int)$u['id'];
    require_once __DIR__ . '/trek_data.php';
    if (trek_inside($uid)) return [false, 'You’re on a trek. Leave the trek first.'];   // v1.8.0
    if (landmark_done_today($uid, $lmId, 'delve')) return [false, 'You’ve been down there today. The delve needs a day to settle.'];
    if (!spend_energy($uid, 1)) return [false, 'You need 1 energy to go in.'];
    landmark_once($uid, $lmId, 'delve');
    $gc = gnome_combat($u);
    $expId = db_insert('expeditions', [
        'user_id' => $uid, 'from_id' => $lm['location_id'], 'to_id' => $lm['location_id'], 'route_id' => 0, 'kind' => 'delve', 'depth' => 0,
        'steps_total' => DELVE_ROOMS, 'step' => 0, 'hp' => $gc['max_hp'], 'max_hp' => $gc['max_hp'], 'level' => (int)$lm['level'], 'scaled' => 0,
        'log' => json_encode(array_values(array_filter(['🕳️ You light a lantern and step into ' . $lm['name'] . '.',
            ($el = delve_room_line('entry', (string)($lm['landscape'] ?? 'forest'), $lmId . '|' . $expId)) !== '' ? '🏮 ' . $el : '']))), 'started_at' => now(), 'arrive_at' => now(),
    ]);
    return [true, '🕳️ Into the delve! (−1 energy)'];
}

/** Next room: a creature, a trap, or treasure; the last room has a guardian before the chest. */
function delve_next(array $u, array &$exp): void
{
    if ($exp['encounter'] || (int)$exp['depth'] >= DELVE_ROOMS) return;
    $lantern = tool_tier((int)$u['id'], 'lantern');   // v0.7.30: a lantern lights the way (rooms free, traps easier)
    if (!$lantern && !spend_energy((int)$u['id'], 1)) {
        exp_log($exp, '😮‍💨 You’re too tired to go on. Rest, or climb back out.');
        return;
    }
    $exp['depth'] = (int)$exp['depth'] + 1;
    $exp['step'] = (int)$exp['depth'];
    $room = (int)$exp['depth'];
    $lm = landmark_at((int)$exp['from_id']);
    $land = (string)($lm['landscape'] ?? 'forest');
    $lvl = (int)($lm['level'] ?? 5) + $room - 1;
    $exp['level'] = $lvl;
    $roll = random_int(1, 100);
    $kind = ($room === DELVE_ROOMS || $roll <= 45) ? 'creature' : ($roll <= 70 ? 'problem' : 'find');
    $rl = delve_room_line($kind, $land, (int)($exp['id'] ?? 0) . '|' . (int)$exp['from_id'] . '|' . $room);   // v1.9.5: a line of text for the room, the same every time
    exp_log($exp, '🚪 Room ' . $room . ' of ' . DELVE_ROOMS . ' (danger level ' . $lvl . ').' . ($rl !== '' ? ' ' . $rl : ''));
    if ($lantern && ($wear = tool_use((int)$u['id'], 'lantern'))) exp_log($exp, $wear);   // v0.7.86: a lit room wears the lantern (Glowcap: never)
    if ($room === DELVE_ROOMS || $roll <= 45) {
        $c = pick_creature($land, $lvl + ($room === DELVE_ROOMS ? 2 : 0), false);
        if ($c) {
            $exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => !empty($c['_scaled']) ? (int)$c['level'] : 0, 'sp' => (int)($c['_pct'] ?? 100), 'hpp' => (int)($c['_hpp'] ?? 100), 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
            exp_log($exp, ($room === DELVE_ROOMS ? '🛡️ The chest is guarded by ' : '⚔️ ') . (preg_match('/^[AEIOU]/i', $c['name']) ? 'an ' : 'a ') . $c['name'] . '!');
            return;
        }
    }
    if ($roll <= 70 && ($p = pick_problem($land))) {
        $exp['encounter'] = json_encode(['type' => 'problem', 'id' => (int)$p['id'], 'dc_bonus' => 1 + intdiv($room, 2) - [0, 0, 2, 3][min(3, $lantern)]]);
        exp_log($exp, '🪤 ' . $p['text']);
        return;
    }
    exp_log($exp, give_find($u, exp_scene($exp)));
    exp_log($exp, give_find($u, exp_scene($exp)));
}

/** The chest at the bottom (once the last room is clear). */
function delve_chest(array $u, array &$exp): void
{
    if ($exp['encounter'] || (int)$exp['depth'] < DELVE_ROOMS || !empty($exp['_opened'])) return;
    $uid = (int)$u['id'];
    $lm = landmark_at((int)$exp['from_id']);
    $lvl = (int)($lm['level'] ?? 5);
    $coins = random_int(20 + 5 * $lvl, 40 + 10 * $lvl);
    if (($cl = delve_room_line('chest', (string)($lm['landscape'] ?? 'forest'), (int)($exp['id'] ?? 0) . '|' . (int)$exp['from_id'])) !== '') exp_log($exp, '🗝️ ' . $cl);
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    exp_log($exp, '💰 The chest creaks open: ' . money($coins) . '!');
    $extra = (landmark_rebuilt_by($lm, $uid) ? 1 : 0) + (tool_tier($uid, 'lantern') >= 3 ? 1 : 0);   // a delve made safe for you, and a Glowcap Lantern, find more (v0.7.88)
    $loot = [];   // v1.4.6: what the chest gave, for the opening animation (assets/chest.js)
    for ($i = 0; $i < 2 + $extra; $i++) {
        $rare = random_int(1, 100) <= 30 + $lvl;
        $it = q_one("SELECT i.id, i.name FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.active = 1 AND g.rarity = ? ORDER BY " . sql_random() . ' LIMIT 1', [$rare ? 'rare' : 'uncommon']);
        if ($it) { give_item($uid, (int)$it['id'], 1); exp_log($exp, '🎁 ' . $it['name']); $loot[(int)$it['id']] = [(int)$it['id'], ($loot[(int)$it['id']][1] ?? 0) + 1, $rare ? 'rare' : 'uncommon']; }
    }
    if (random_int(1, 100) <= 15 && $lm) {
        $code = (string)q_val('SELECT code FROM regions WHERE id = ?', [$lm['region_id']]);
        $gid = $code ? (int)q_val('SELECT id FROM items WHERE slug = ?', [guide_item_slug($code)]) : 0;
        if ($gid) { give_item($uid, $gid, 1); exp_log($exp, '📗 Tucked under the gold: a Gardening Guide!'); $loot[$gid] = [$gid, ($loot[$gid][1] ?? 0) + 1, 'rare']; }
    }
    add_xp($uid, 10 + 2 * $lvl);
    exp_log($exp, '⭐ Delve cleared! +' . (10 + 2 * $lvl) . ' XP');
    require_once __DIR__ . '/chest.php';
    chest_note($coins, 10 + 2 * $lvl, array_values($loot));   // v1.4.6
    landmark_record_clear($uid, (int)$lm['id']);
    $exp['status'] = 'done';
    exp_log($exp, '🪜 You climb back out into the daylight.');
}

function delve_leave(array $u, array &$exp): void
{
    if ($exp['encounter']) return;
    $exp['status'] = 'done';
    exp_log($exp, '🪜 You climb back out with what you found.');
}

// ---------------- Lairs ----------------

/** The legendary creature living in a lair: its own boss (made by ensure_lair_bosses), else the landscape's boss. */
function lair_boss(array $lm): ?array
{
    $slug = (string)($lm['loc_slug'] ?? q_val('SELECT slug FROM locations WHERE id = ?', [$lm['location_id']]));
    $own = q_one('SELECT * FROM creatures WHERE slug = ?', ['boss-' . $slug]);
    if ($own) return $own;
    $land = (string)($lm['landscape'] ?? q_val('SELECT landscape FROM locations WHERE id = ?', [$lm['location_id']]));
    $bosses = q("SELECT * FROM creatures WHERE size = 'boss' AND active = 1 ORDER BY level")->fetchAll();
    foreach ($bosses as $b) {
        if (in_array($land, array_map('trim', explode(',', (string)$b['landscapes'])), true)) return $b;
    }
    return $bosses ? $bosses[crc32((string)$lm['name']) % count($bosses)] : null;
}

function lair_start(array $u, int $lmId): array
{
    $lm = at_landmark($u, $lmId);
    if (!$lm || $lm['kind'] !== 'lair') return [false, 'You need to be at the lair.'];
    $boss = lair_boss($lm);
    if (!$boss) return [false, 'The lair is empty. Strange…'];
    $uid = (int)$u['id'];
    require_once __DIR__ . '/trek_data.php';
    if (trek_inside($uid)) return [false, 'You’re on a trek. Leave the trek first.'];   // v1.8.0
    if (landmark_done_today($uid, $lmId, 'lair')) return [false, 'The ' . $boss['name'] . ' won’t come out again today.'];
    if (!spend_energy($uid, 2)) return [false, 'You need 2 energy to face the ' . $boss['name'] . '.'];
    landmark_once($uid, $lmId, 'lair');
    $gc = gnome_combat($u);
    db_insert('expeditions', [
        'user_id' => $uid, 'from_id' => $lm['location_id'], 'to_id' => $lm['location_id'], 'route_id' => 0, 'kind' => 'lair', 'depth' => 1,
        'steps_total' => 1, 'step' => 1, 'hp' => $gc['max_hp'], 'max_hp' => $gc['max_hp'], 'level' => (int)$boss['level'], 'scaled' => 0,
        'encounter' => json_encode(['type' => 'creature', 'id' => (int)$boss['id'], 'hp' => (int)$boss['hp'], 'max' => (int)$boss['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]),
        'log' => json_encode(['🐉 You step into ' . $lm['name'] . '. The ' . $boss['name'] . ' rises to meet you!']), 'started_at' => now(), 'arrive_at' => now(),
    ]);
    return [true, '🐉 The fight is on! (−2 energy)'];
}

/** After the boss falls: the lair's reward (more the first time). */
function lair_victory(array $u, array &$exp): void
{
    $uid = (int)$u['id'];
    $lm = landmark_at((int)$exp['from_id']);
    if (!$lm) { $exp['status'] = 'done'; return; }
    $first = landmark_record_clear($uid, (int)$lm['id']);
    $lvl = (int)$exp['level'];
    $coins = ($first ? 40 : 15) * $lvl;
    q('UPDATE users SET coins = coins + ?' . ($first ? ', ribbons = ribbons + 1' : '') . ' WHERE id = ?', [$coins, $uid]);
    exp_log($exp, '💰 The lair’s hoard: ' . money($coins) . '.');
    if ($first) exp_log($exp, '🎗️ First victory here! A ribbon for your hat, and the tale goes in your Almanac.');
    require_once __DIR__ . '/jobs.php';
    if (random_int(1, 100) <= ($first ? 100 : 25)) {
        [$sid] = resolve_job_reward('@treasure-seed:1', 'lair|' . $uid . '|' . $lm['id'] . '|' . landmark_day());
        if ($sid) { give_item($uid, (int)$sid, 1); exp_log($exp, '🌟 Among the bones: ' . q_val('SELECT name FROM items WHERE id = ?', [$sid]) . '!'); }
    }
    $exp['status'] = 'done';
}

/** Count a delve or lair clear. Returns true the first time. */
function landmark_record_clear(int $uid, int $lmId): bool
{
    $had = q_one('SELECT id FROM landmark_clears WHERE user_id = ? AND landmark_id = ?', [$uid, $lmId]);
    if ($had) {
        q('UPDATE landmark_clears SET clears = clears + 1, last_at = ? WHERE id = ?', [now(), $had['id']]);
        return false;
    }
    db_insert('landmark_clears', ['user_id' => $uid, 'landmark_id' => $lmId, 'clears' => 1, 'first_at' => now(), 'last_at' => now()]);
    return true;
}

/**
 * Give every lair its own legendary creature, named after the lair ("Den of the Great White Owl" → Great White Owl),
 * built like the landscape's boss but at the lair's level, with the same drops. Kept out of the wild (active = 0).
 */
function ensure_lair_bosses(): void
{
    $templates = q("SELECT * FROM creatures WHERE size = 'boss' AND active = 1 AND slug NOT LIKE 'boss-%' ORDER BY level")->fetchAll();
    if (!$templates) return;
    foreach (q("SELECT lm.*, l.slug AS loc_slug, l.landscape FROM landmarks lm JOIN locations l ON l.id = lm.location_id WHERE lm.kind = 'lair'")->fetchAll() as $lm) {
        $slug = 'boss-' . $lm['loc_slug'];
        if (q_val('SELECT 1 FROM creatures WHERE slug = ?', [$slug])) continue;
        $tpl = null;
        foreach ($templates as $t) if (in_array($lm['landscape'], array_map('trim', explode(',', (string)$t['landscapes'])), true)) { $tpl = $t; break; }
        $tpl ??= $templates[crc32((string)$lm['name']) % count($templates)];
        $level = max(8, (int)q_val("SELECT level FROM routes WHERE kind = 'side' AND b_id = ? LIMIT 1", [$lm['location_id']]) ?: (int)$tpl['level']);
        $name = preg_match('/\bof the (.+)$/i', (string)$lm['name'], $m) ? ucwords($m[1]) : 'Guardian of ' . $lm['name'];
        $cid = db_insert('creatures', [
            'slug' => $slug, 'name' => mb_substr($name, 0, 80), 'size' => 'boss', 'landscapes' => (string)$lm['landscape'], 'level' => $level,
            'hp' => (int)round((5 + $level * 3) * 2.4), 'attack' => 3 + intdiv($level, 3), 'defense' => 12 + intdiv($level, 3),
            'dmg_die' => 10, 'dmg_bonus' => intdiv($level, 4), 'xp' => (int)round($level * 6 * 2.4),
            'description' => 'The legendary keeper of ' . $lm['name'] . '. ' . $lm['description'], 'active' => 0,
        ]);
        foreach (q('SELECT * FROM creature_drops WHERE creature_id = ?', [$tpl['id']])->fetchAll() as $d) {
            unset($d['id']);
            $d['creature_id'] = $cid;
            db_insert('creature_drops', $d);
        }
        if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['creature:' . $slug])) {
            db_insert('encyclopedia_entries', ['chapter' => 'Creatures', 'category' => 'Legendary Creatures', 'title' => $name,
                'body' => 'The legendary keeper of ' . $lm['name'] . '. ' . $lm['description'] . "\n\n[b]Found in:[/b] its lair only · [b]Level:[/b] " . $level,
                'unlock_key' => 'creature:' . $slug, 'hint' => 'Face it in its lair.', 'sort_order' => $level]);
        }
    }
}

// ---------------- The panel on the World page ----------------

function landmark_panel(array $u, array $node): string
{
    $lm = landmark_at((int)$node['id']);
    if (!$lm) return '';
    $uid = (int)$u['id'];
    require_once __DIR__ . '/journey.php';
    if ($jc = journey_lock($uid, 'place', (string)$node['slug'])) return journey_lock_note($jc, (string)$lm['name']);   // v0.7.66
    $id = (int)$lm['id'];
    $form = fn(string $do, string $label, string $extra = '', bool $disabled = false, string $cls = 'btn act', string $fcls = 'inline') => '<form method="post" action="' . e(url('landmark.php')) . '" class="' . $fcls . '">'
        . csrf_field() . '<input type="hidden" name="do" value="' . e($do) . '"><input type="hidden" name="lm" value="' . $id . '">' . $extra
        . '<button class="' . $cls . '"' . ($disabled ? ' disabled' : '') . '>' . $label . '</button></form> ';
    $cleared = (int)q_val('SELECT clears FROM landmark_clears WHERE user_id = ? AND landmark_id = ?', [$uid, $id]);
    $h = '<div class="box lmpanel lm-' . e($lm['kind']) . '">';
    if (in_array($lm['kind'], ['haven', 'wonder', 'delve'], true)) {
        require_once __DIR__ . '/rebuild.php';
        if (landmark_rebuilt_by($lm, $uid)) {   // v0.7.88: you made it safe: the plaque and your own extras
            $h .= '<p class="restored">' . e(restored_line($lm)) . ' ' . ['haven' => 'Its fire is warmer and its pantry fuller.', 'wonder' => 'It gives up its secrets a little more easily.', 'delve' => 'Its chest holds more.'][$lm['kind']] . '</p>';
        } elseif (!empty($lm['ruined'])) {   // v0.7.88: ruins are per gnome: closed for you until you make it safe
            if ($note = landmark_safe_note($lm)) $h .= '<p class="help">' . e($note) . '</p>';
            if ($mine = q_one('SELECT id, stage FROM landmark_repairs WHERE user_id = ? AND landmark_id = ? AND done_at IS NULL AND dropped_at IS NULL', [$uid, $id])) {   // v0.7.77 your own repair here
                $h .= '<p class="ruin">🏚️ This place has fallen into ruin. You’re making it safe for yourself:</p>'
                    . repair_box($u, $mine + ['landmark_id' => $id, 'name' => $lm['name'], 'region_id' => $lm['region_id']], 'world.php');
            } else {   // v0.7.77 repairs replace the monthly rebuild job
                $h .= '<p class="ruin">🏚️ This place has fallen into ruin. Clear your path in and shore it up to use it: four stages of building materials, meals and fine finds.</p>';
                if (($why = repair_can_start($u, $lm)) === null) {
                    [$rCoins, $rXp] = repair_rewards($lm);
                    $h .= $form('repair_start', '🔨 Take on the repair') . '<p class="help">Each stage pays ' . money($rCoins) . ' and ' . $rXp . ' XP.</p>';
                } else {
                    $h .= '<p class="help">' . e($why) . '</p>';
                }
            }
        }
        if (landmark_in_ruins($lm, $uid)) {   // v0.7.87 / v0.7.88: closed for this gnome until they make it safe
            return $h . '<p class="help">🚧 You can’t rest, explore or search here until you’ve made it safe.</p></div>';
        }
    }
    switch ($lm['kind']) {
        case 'haven':
            $h .= '<h3>🏕️ A haven: safe and warm</h3><p class="help">Paths next to a haven are always gentle.</p>'
                . $form('rest', '🔥 Rest by the fire <span class="cost">+4⚡</span>', '', landmark_done_today($uid, $id, 'rest'))
                . $form('stay', '🛏️ Stay the night <span class="cost">' . money(20) . '</span>', '', landmark_done_today($uid, $id, 'stay'))
                . '<p class="help">Staying the night: +3 ' . e(GNOME_STATS[haven_stat($lm)][0]) . ' for 2 hours and a little energy. Each once a day.</p>'
                . '<h4>🧺 Today’s pantry</h4><div class="pantry">';
            foreach (haven_pantry($lm, $uid) as [$it, $price]) {
                $h .= $form('buy', e($it['name']) . ' <span class="cost">' . money($price) . '</span>', '<input type="hidden" name="item_id" value="' . (int)$it['id'] . '">', landmark_done_today($uid, $id, 'buy' . (int)$it['id']));
            }
            $h .= '</div><p class="help">One of each a day. The pantry changes every day.</p>';
            break;
        case 'wonder':
            $done = landmark_done_today($uid, $id, 'wonder');
            [, $mood] = wonder_mood($lm);   // v1.9.4: its own intro and today's mood
            $h .= '<h3>✨ ' . e($lm['name']) . '</h3>' . (($wi = wonder_text($lm, 'intro')) !== '' ? '<p class="wonderintro">' . e($wi) . '</p>' : '')
                . ($mood !== '' ? '<p class="help wondermood">' . e($mood) . '</p>' : '')
                . '<p>How will you investigate? <small class="muted">d20 + the stat must reach the number.</small></p>';
            foreach (wonder_approaches($lm, $uid) as $stat => [$icon, $label, $dc]) {
                $mod = eff_mod($u, $stat);
                $chance = max(5, min(100, (21 - ($dc - $mod)) * 5));
                // v1.4.8: one compact row per approach, like the problems on the road (label + stat line, chance badge)
                $h .= $form('wonder', '<span class="optl">' . $icon . ' ' . e($label) . '<small>' . e(GNOME_STATS[$stat][0]) . ' ' . ($mod >= 0 ? '+' : '') . $mod . ' vs ' . $dc . '</small></span>'
                    . '<b class="optpct' . ($chance >= 60 ? ' good' : ($chance < 35 ? ' poor' : '')) . '">' . $chance . '%</b>',
                    '<input type="hidden" name="stat" value="' . e($stat) . '">', $done, 'btn alt optbtn', 'option');
            }
            $h .= '<p class="help">' . ($done ? '✔️ You’ve explored it today. ' : '') . 'Once a day. Its own skill (the first) is the easiest way in.</p>';
            break;
        case 'delve':
            $done = landmark_done_today($uid, $id, 'delve');
            $h .= '<h3>🕳️ A delve <small class="muted">danger level ' . (int)$lm['level'] . '–' . ((int)$lm['level'] + DELVE_ROOMS + 1) . '</small></h3>'
                . '<p>' . DELVE_ROOMS . ' rooms of creatures, traps and treasure, and a guarded chest at the bottom. Climb out whenever you like with what you’ve found.</p>'
                . $form('delve', '🕳️ Go in <span class="cost">⚡1' . (tool_tier($uid, 'lantern') ? ', rooms free (🏮)' : ', then 1 a room') . '</span>', '', $done)
                . '<p class="help">' . ($done ? '✔️ Explored today. ' : '') . 'Once a day.' . ($cleared ? ' Cleared ' . $cleared . ' time' . ($cleared === 1 ? '' : 's') . '.' : '')
                . ((int)$lm['level'] > (int)$u['level'] + 4 ? ' ⚠️ Well above your gnome level.' : '') . '</p>';
            break;
        case 'lair':
            $boss = lair_boss($lm);
            $done = landmark_done_today($uid, $id, 'lair');
            $h .= '<h3>🐉 A lair</h3>';
            if ($boss) {
                $h .= '<p><span class="bigfoe">' . creature_icon((string)$boss['name'], 'boss') . '</span> <b>' . e($boss['name']) . '</b> lives here. <small class="muted">Level ' . (int)$boss['level'] . ' · ❤️ ' . (function_exists('creature_hp_percent') ? max(1, (int)round((int)$boss['hp'] * creature_hp_percent($boss + ['size' => 'boss']) / 100)) : (int)$boss['hp']) . '</small></p>'
                    . '<p class="help">' . e((string)$boss['description']) . '</p>'
                    . $form('lair', '⚔️ Challenge the ' . e($boss['name']) . ' <span class="cost">⚡2</span>', '', $done)
                    . '<p class="help">' . ($done ? '✔️ It won’t come out again today. ' : '') . 'Once a day. Win for a big hoard; the first win also earns a ribbon and a treasure seed.'
                    . ($cleared ? ' You’ve beaten it ' . $cleared . ' time' . ($cleared === 1 ? '' : 's') . '.' : '')
                    . ((int)$boss['level'] > (int)$u['level'] + 4 ? ' ⚠️ This is a legendary creature, far above your level. Losing costs nothing but pride.' : '') . '</p>';
            }
            break;
    }
    return $h . '</div>';
}
