<?php
declare(strict_types=1);
/**
 * NPC lives (v0.7.21).
 * Shopkeepers have a day: their shift, a cuppa at the teahouse afterwards, then a couple of hours at their favourite
 * place in town, then home to rest. All on the Hollow's clock (setting game_timezone).
 * Travellers (a merchant, a minstrel and a naturalist) go round the regions' towns, half a day in each.
 */

require_once __DIR__ . '/world.php';

/** Which kind of place each personality likes best. */
const FAV_KINDS = [
    'Chatty' => 'teahouse', 'Cheerful' => 'green', 'Warm' => 'green', 'Generous' => 'green', 'Eager' => 'board',
    'Grumpy' => 'library', 'Shy' => 'library', 'Fussy' => 'library', 'Proud' => 'special', 'Curious' => 'special',
    'Dreamy' => 'special', 'Sleepy' => 'green',
];

const TRAVELLERS = [
    'merchant' => ['Tobias Trundle', 'Tortoise', 'Generous', 'A travelling merchant with a whole shop strapped to his shell. Sells one rare seed in every town he visits.', 0],
    'minstrel' => ['Lyra Fiddlewing', 'Grasshopper', 'Cheerful', 'A wandering minstrel who plays a tiny fiddle on every village green in the Hollow. Her songs put a spring in your step.', 5],
    'naturalist' => ['Wren Thimblewick', 'Wren', 'Curious', 'A travelling naturalist who trades stories for seeds from every corner of the world. She’ll swap a seed for something you found.', 9],
    'gourmand' => ['Pomeroy Crumbworth', 'Dormouse', 'Fussy', 'A travelling food writer with a napkin always tucked in. Tours the Hollow’s festivals and asks gnomes to share their cooking. Rates in spoons.', 0],
];
const TRAVEL_STOP_HOURS = 12;

function npc_icon(?string $species): string
{
    $n = strtolower((string)$species);
    foreach (['dragonfly' => '🦋', 'ladybird' => '🐞', 'bumblebee' => '🐝', 'bee' => '🐝', 'hedgehog' => '🦔', 'snail' => '🐌', 'frog' => '🐸', 'toad' => '🐸',
              'mouse' => '🐭', 'shrew' => '🐭', 'grasshopper' => '🦗', 'cricket' => '🦗', 'tortoise' => '🐢', 'beetle' => '🪲', 'wren' => '🐦', 'mole' => '🐾',
              'hare' => '🐇', 'gecko' => '🦎', 'butterfly' => '🦋', 'moth' => '🦋', 'stick' => '🌿', 'firefly' => '✨'] as $k => $ic) {
        if (str_contains($n, $k)) return $ic;
    }
    return '🐾';
}

/** An NPC's birthday (month, day), fixed from their name. */
function npc_birthday(array $npc): array
{
    $doy = crc32('bday|' . $npc['slug']) % 365;
    $ts = gmmktime(12, 0, 0, 1, 1, 2025) + $doy * 86400;   // a non-leap year
    return [(int)gmdate('n', $ts), (int)gmdate('j', $ts)];
}

function npc_birthday_today(array $npc): bool
{
    [$m, $d] = npc_birthday($npc);
    return (int)hollow_date('n') === $m && (int)hollow_date('j') === $d;
}

function npc_birthday_text(array $npc): string
{
    [$m, $d] = npc_birthday($npc);
    return date('F', mktime(0, 0, 0, $m, 1)) . ' ' . $d;
}

/** Give every NPC a daily routine around their town (once; admins can edit schedules afterwards). */
function ensure_npc_lives(): void
{
    require_once __DIR__ . '/town.php';
    // Travellers: Wren already exists in older worlds; the others are new
    foreach (TRAVELLERS as $role => [$name, $species, $pers, $bio, $offset]) {
        $id = q_val('SELECT id FROM npcs WHERE slug = ?', [slugify($name)]);
        if (!$id) {
            $id = db_insert('npcs', ['name' => $name, 'slug' => slugify($name), 'species' => $species, 'personality' => $pers, 'bio' => $bio, 'mood' => 60,
                'active' => $role === 'gourmand' ? (setting('gourmand_open') === '1' ? 1 : 0) : 1]);   // next version: the Gourmand starts hidden until the admin opens him
        }
        if (!q_val('SELECT traveller FROM npcs WHERE id = ?', [$id])) {
            q('UPDATE npcs SET traveller = ?, circuit_offset = ?, bio = ? WHERE id = ?', [$role, $offset, $bio, $id]);
            q('DELETE FROM npc_schedules WHERE npc_id = ?', [$id]);   // travellers follow their circuit instead
        }
    }
    // Shopkeepers: split their free hours into tea, then their favourite place
    foreach (q("SELECT n.* FROM npcs n WHERE n.traveller IS NULL AND n.fav_spot_id IS NULL")->fetchAll() as $n) {
        $work = q_one("SELECT s.*, sh.location_id AS shop_loc FROM npc_schedules s JOIN shops sh ON sh.id = s.shop_id WHERE s.npc_id = ? AND s.activity = 'working' ORDER BY s.id LIMIT 1", [$n['id']]);
        if (!$work) continue;
        $town = (string)q_val('SELECT region FROM locations WHERE id = ?', [$work['shop_loc']]);
        $spots = town_spots($town);
        if (!$spots) continue;
        $byKind = [];
        $spots = array_values(array_filter($spots, fn($s) => trim((string)$s['months']) === ''));   // not seasonal places
        foreach ($spots as $s) $byKind[$s['kind']][] = $s;
        $want = FAV_KINDS[$n['personality']] ?? 'green';
        $pool = $byKind[$want] ?? $byKind['green'] ?? $spots;
        $fav = $pool[crc32((string)$n['slug']) % count($pool)];
        $tea = $byKind['teahouse'][0] ?? $fav;
        q('UPDATE npcs SET fav_spot_id = ? WHERE id = ?', [$fav['id'], $n['id']]);
        $wander = q("SELECT * FROM npc_schedules WHERE npc_id = ? AND activity = 'wandering' AND spot_id IS NULL", [$n['id']])->fetchAll();
        foreach ($wander as $w) {
            $start = (int)$w['start_hour'];
            $end = (int)$w['end_hour'];
            $len = count(schedule_hours($start, $end));
            if ($len >= 2) {
                $mid = ($start + 1) % 24;
                q('UPDATE npc_schedules SET activity = ?, spot_id = ?, location_id = ?, end_hour = ? WHERE id = ?', ['visiting', $tea['id'], $work['shop_loc'], $mid, $w['id']]);
                db_insert('npc_schedules', ['npc_id' => $n['id'], 'location_id' => $work['shop_loc'], 'shop_id' => null, 'spot_id' => $fav['id'],
                    'activity' => 'visiting', 'days' => $w['days'], 'start_hour' => $mid, 'end_hour' => $end]);
            } else {
                q('UPDATE npc_schedules SET activity = ?, spot_id = ?, location_id = ? WHERE id = ?', ['visiting', $fav['id'], $work['shop_loc'], $w['id']]);
            }
        }
        // An evening (or morning) out somewhere else before going home: 2 hours taken from a long rest
        $others = array_values(array_filter($spots, fn($s) => (int)$s['id'] !== (int)$fav['id'] && in_array($s['kind'], ['green', 'special', 'library'], true)));
        foreach ($wander as $w) {
            $rest = q_one("SELECT * FROM npc_schedules WHERE npc_id = ? AND activity = 'resting' AND start_hour = ?", [$n['id'], (int)$w['end_hour']]);
            if (!$rest || !$others || count(schedule_hours((int)$rest['start_hour'], (int)$rest['end_hour'])) < 10) continue;
            $out = $others[crc32($n['slug'] . '|out') % count($others)];
            $from = (int)$rest['start_hour'];
            q('UPDATE npc_schedules SET start_hour = ? WHERE id = ?', [($from + 2) % 24, $rest['id']]);
            db_insert('npc_schedules', ['npc_id' => $n['id'], 'location_id' => $work['shop_loc'], 'shop_id' => null, 'spot_id' => $out['id'],
                'activity' => 'visiting', 'days' => $rest['days'], 'start_hour' => $from, 'end_hour' => ($from + 2) % 24]);
        }
    }
    // The travelling merchant can turn up as a random event too
    if (!q_val("SELECT 1 FROM random_events WHERE slug = 'merchant'")) {
        db_insert('random_events', ['slug' => 'merchant', 'weight' => 5, 'kind' => 'click', 'effect' => 'merchant', 'icon' => '🐢',
            'title' => 'Tobias Trundle, travelling merchant!', 'text' => '“Psst! A rare seed, gnome? Just for you, a special price…” He opens a little drawer in his shell.',
            'button' => '', 'active' => 1]);
    }
}

/** NPCs at a town place right now (shopkeepers on their break, plus a traveller on the Green). */
function npcs_at_spot(array $spot): array
{
    $h = hollow_hour();
    $d = hollow_dow();
    $out = [];
    foreach (q('SELECT n.*, s.days, s.start_hour, s.end_hour FROM npc_schedules s JOIN npcs n ON n.id = s.npc_id
                WHERE s.spot_id = ? AND n.active = 1', [$spot['id']])->fetchAll() as $r) {
        if (in_array($d, schedule_days($r['days']), true) && in_array($h, schedule_hours((int)$r['start_hour'], (int)$r['end_hour']), true)) $out[$r['id']] = $r;
    }
    if ($spot['kind'] === 'green') {
        foreach (q('SELECT * FROM npcs WHERE traveller IS NOT NULL AND active = 1')->fetchAll() as $t) {
            if ($t['traveller'] === 'gourmand') continue;   // next version: he sits at his camp spot, not on the Green
            if (traveller_stop($t)['town'] === $spot['region']) $out[$t['id']] = $t;
        }
    }
    if ($g = q_one("SELECT * FROM npcs WHERE traveller = 'gourmand' AND active = 1")) {
        require_once __DIR__ . '/gourmand.php';
        if ((string)$spot['slug'] === gourmand_stop()['camp']) $out[$g['id']] = $g;
    }
    return array_values($out);
}

/** The towns travellers visit, in order (every region; not Mossbottom). */
function traveller_towns(): array
{
    return array_column(all_regions(), 'gnomish_name');
}

/** Where a traveller is: [town, stop key, ends (unix time), next town]. */
function traveller_stop(array $npc, ?int $at = null): array
{
    if (($npc['traveller'] ?? '') === 'gourmand') {   // next version: Pomeroy follows the festival calendar (camp days, not 12-hour slots)
        require_once __DIR__ . '/gourmand.php';
        $g = gourmand_stop($at);
        return ['next_stop' => $g['next'], 'next' => $g['next']['town']] + $g;
    }
    $towns = traveller_towns();
    $n = max(1, count($towns));
    $len = TRAVEL_STOP_HOURS * 3600;
    $slot = intdiv($at ?? time(), $len);
    $i = ($slot + (int)$npc['circuit_offset']) % $n;
    return ['town' => $towns[$i] ?? HUB_REGION, 'stop' => (string)$slot, 'ends' => ($slot + 1) * $len, 'next' => $towns[($i + 1) % $n] ?? HUB_REGION];
}

/** What an NPC is doing right now: ['what' => text, 'town' => region or null, 'spot' => row or null]. */
function npc_now(array $npc): array
{
    if (($npc['traveller'] ?? '') === 'gourmand') {   // next version: at his camp spot
        $s = traveller_stop($npc);
        $camp = q_one('SELECT * FROM town_spots WHERE slug = ? AND active = 1', [$s['camp']]);
        return ['what' => $camp ? 'at ' . $camp['name'] . ' in ' . $s['town'] : 'in ' . $s['town'], 'town' => $s['town'], 'spot' => $camp ?: null];
    }
    if (!empty($npc['traveller'])) {
        $s = traveller_stop($npc);
        $green = q_one("SELECT * FROM town_spots WHERE region = ? AND kind = 'green' AND active = 1", [$s['town']]);
        return ['what' => 'on the Green in ' . $s['town'], 'town' => $s['town'], 'spot' => $green ?: null];
    }
    $h = hollow_hour();
    $d = hollow_dow();
    foreach (q('SELECT s.*, sh.name AS shop_name, sh.location_id AS shop_loc FROM npc_schedules s LEFT JOIN shops sh ON sh.id = s.shop_id WHERE s.npc_id = ?', [$npc['id']])->fetchAll() as $s) {
        if (!in_array($d, schedule_days($s['days']), true) || !in_array($h, schedule_hours((int)$s['start_hour'], (int)$s['end_hour']), true)) continue;
        $loc = $s['shop_id'] ? $s['shop_loc'] : $s['location_id'];
        $town = $loc ? (string)q_val('SELECT region FROM locations WHERE id = ?', [$loc]) : null;
        if ($s['activity'] === 'working') return ['what' => 'working at ' . $s['shop_name'], 'town' => $town, 'spot' => null];
        if ($s['spot_id'] && ($spot = q_one('SELECT * FROM town_spots WHERE id = ?', [$s['spot_id']]))) {
            return ['what' => 'at ' . $spot['name'] . ($town ? ' in ' . $town : ''), 'town' => $town, 'spot' => $spot];
        }
        if ($s['activity'] === 'resting') { $h2 = npc_home($npc); return ['what' => 'at home', 'town' => $h2['region'] ?? $town, 'spot' => null, 'home' => true]; }
        return ['what' => match ($s['activity']) { 'shopping' => 'out shopping', default => 'out and about' }, 'town' => $town, 'spot' => null];
    }
    // v0.7.73: hours with no plans are spent at home
    $h2 = npc_home($npc);
    if ($h2) return ['what' => 'at home', 'town' => $h2['region'], 'spot' => null, 'home' => true];
    return ['what' => 'nowhere to be found', 'town' => null, 'spot' => null];
}

/** v0.7.73: where an NPC lives: ['name', 'region'] or null (travellers have no home). */
function npc_home(array $npc): ?array
{
    static $memo = [];
    $id = (int)$npc['id'];
    if (array_key_exists($id, $memo)) return $memo[$id];
    if (!empty($npc['traveller'])) return $memo[$id] = null;
    $hid = $npc['home_location_id'] ?? q_val('SELECT home_location_id FROM npcs WHERE id = ?', [$id]);
    $h = $hid ? q_one('SELECT name, region FROM locations WHERE id = ?', [$hid]) : null;
    if (!$h) $h = q_one("SELECT l.name, l.region FROM npc_schedules s JOIN shops sh ON sh.id = s.shop_id JOIN locations l ON l.id = sh.location_id WHERE s.npc_id = ? AND s.activity = 'working' LIMIT 1", [$id]);
    return $memo[$id] = ($h && $h['region'] !== null ? ['name' => (string)$h['name'], 'region' => (string)$h['region']] : null);
}

/** v0.7.73: the hours (this Hollow day) an NPC is usually home, as text like "9 pm – 6 am". */
function npc_home_hours(array $npc): string
{
    $d = hollow_dow();
    $busy = [];
    foreach (q("SELECT * FROM npc_schedules WHERE npc_id = ? AND activity <> 'resting'", [$npc['id']])->fetchAll() as $s) {
        if (!in_array($d, schedule_days($s['days']), true)) continue;
        foreach (schedule_hours((int)$s['start_hour'], (int)$s['end_hour']) as $h) $busy[$h] = true;
    }
    $free = array_values(array_diff(range(0, 23), array_keys($busy)));
    if (!$free) return 'rarely';
    if (count($free) === 24) return 'all day';
    // find the longest run, wrapping round midnight
    $best = [0, 0]; $n = count($free);
    for ($i = 0; $i < 24; $i++) {
        if (isset($busy[$i]) || !isset($busy[($i + 23) % 24])) continue;   // start of a free run
        $len = 0; while ($len < 24 && !isset($busy[($i + $len) % 24])) $len++;
        if ($len > $best[1]) $best = [$i, $len];
    }
    $fmt = fn(int $h) => ($h % 12 ?: 12) . ($h < 12 ? ' am' : ' pm');
    return $fmt($best[0]) . ' – ' . $fmt(($best[0] + $best[1]) % 24);
}

/** Their day as a list of lines, e.g. "6 am – 2 pm: working at …". */
function npc_routine(array $npc): array
{
    if (($npc['traveller'] ?? '') === 'gourmand') {   // next version
        $s = traveller_stop($npc);
        $left = max(1, (int)ceil(($s['ends'] - gourmand_now()) / 86400));
        return ['🧭 Tours the Hollow with the festivals, a few days in each region’s town, and eats wherever a gnome sets a table.',
            '📍 Now: ' . $s['town'] . ' (for about ' . $left . ' more day' . ($left === 1 ? '' : 's') . ')', '➡️ Next: ' . $s['next']];
    }
    if (!empty($npc['traveller'])) {
        $s = traveller_stop($npc);
        $left = max(1, (int)round(($s['ends'] - time()) / 3600));
        return ['🧭 Travels the Hollow, half a day in each region’s town, always on the Green.',
            '📍 Now: ' . $s['town'] . ' (for about ' . $left . ' more hour' . ($left === 1 ? '' : 's') . ')', '➡️ Next: ' . $s['next']];
    }
    $out = [];
    foreach (q('SELECT s.*, sh.name AS shop_name, t.name AS spot_name FROM npc_schedules s LEFT JOIN shops sh ON sh.id = s.shop_id
                LEFT JOIN town_spots t ON t.id = s.spot_id WHERE s.npc_id = ? ORDER BY s.start_hour', [$npc['id']])->fetchAll() as $s) {
        $what = $s['activity'] === 'working' ? 'working at ' . $s['shop_name'] : ($s['spot_name'] ? $s['spot_name'] : ($s['activity'] === 'resting' ? 'home, resting' : $s['activity']));
        $out[] = hour_label((int)$s['start_hour']) . ' – ' . hour_label((int)$s['end_hour']) . ': ' . $what;
    }
    return $out;
}

/** Is the NPC at their favourite place right now? (A chat there counts double.) */
function npc_at_favourite(array $npc): bool
{
    if (empty($npc['fav_spot_id'])) return false;
    $now = npc_now($npc);
    return $now['spot'] && (int)$now['spot']['id'] === (int)$npc['fav_spot_id'];
}

/** A couple of rumours overheard at the teahouse, the same for everyone this hour. */
function teahouse_rumours(string $town, int $n = 2): array
{
    $pool = [];
    foreach (q("SELECT n.* FROM npcs n WHERE n.active = 1 AND n.fav_spot_id IN (SELECT id FROM town_spots WHERE region = ?)", [$town])->fetchAll() as $npc) {
        $fav = q_one('SELECT name FROM town_spots WHERE id = ?', [$npc['fav_spot_id']]);
        $pool[] = '“' . $npc['name'] . '? You’ll find them at ' . $fav['name'] . ' most days, after their shift.”';
    }
    foreach (q("SELECT n.* FROM npcs n WHERE n.active = 1 AND n.fav_spot_id IN (SELECT id FROM town_spots WHERE region = ?)", [$town])->fetchAll() as $npc) {
        for ($d = 1; $d <= 7; $d++) {
            [$m, $day] = npc_birthday($npc);
            if ((int)hollow_date('n', time() + $d * 86400) === $m && (int)hollow_date('j', time() + $d * 86400) === $day) {
                $pool[] = '“Don’t tell ' . $npc['name'] . ', but it’s their birthday ' . ($d === 1 ? 'tomorrow' : 'in ' . $d . ' days') . '. A little present would go a long way.”';
            }
        }
    }
    foreach (q('SELECT s.* FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.region = ? AND s.open = 1', [$town])->fetchAll() as $sh) {
        $next = $sh['last_restock'] ? strtotime($sh['last_restock'] . ' UTC') + (int)$sh['restock_minutes'] * 60 - time() : 0;
        $pool[] = $next > 60 ? '“' . $sh['name'] . ' gets fresh stock in about ' . max(1, (int)round($next / 60)) . ' minutes. Be quick!”'
            : '“' . $sh['name'] . ' is due fresh stock any moment now.”';
    }
    foreach (q('SELECT * FROM npcs WHERE traveller IS NOT NULL AND active = 1')->fetchAll() as $t) {
        $s = traveller_stop($t);
        if ($t['traveller'] === 'gourmand') {   // next version: a menu rumour, and where he sits
            require_once __DIR__ . '/gourmand.php';
            $pool[] = $s['town'] === $town ? '“' . $t['name'] . ' is in town! Look for the folding table.”' : '“I heard ' . $t['name'] . ' is in ' . $s['town'] . ', heading for ' . $s['next'] . ' next.”';
            if ($ask = gourmand_rumour($town)) $pool[] = $ask;
            continue;
        }
        $pool[] = $s['town'] === $town ? '“' . $t['name'] . ' is in town! Over on the Green.”' : '“I heard ' . $t['name'] . ' is in ' . $s['town'] . ', heading for ' . $s['next'] . ' next.”';
    }
    require_once __DIR__ . '/jobs.php';
    require_once __DIR__ . '/contests.php';
    $pool[] = '“This week’s Village Show is the ' . SHOW_CROPS[show_crop()][0] . '. My cousin’s been feeding hers for weeks.”';
    if (!$pool) return [];
    $seed = crc32($town . '|' . hollow_date('Y-m-d H'));
    $out = [];
    for ($i = 0; $i < min($n, count($pool)); $i++) {
        $k = ($seed + $i * 7919) % count($pool);
        while (in_array($pool[$k], $out, true)) $k = ($k + 1) % count($pool);
        $out[] = $pool[$k];
    }
    return $out;
}

// ---------------- Travellers' deals (one per gnome per stop) ----------------

function traveller_offer(array $npc): ?array
{
    if (($npc['traveller'] ?? '') === 'gourmand') return ['kind' => 'link', 'url' => 'gourmand.php', 'label' => '🍽️ Serve a course', 'stop' => ''];   // next version: served on his own page
    $s = traveller_stop($npc);
    $r = region_by_name($s['town']);
    if (!$r) return null;
    $seedSql = 'SELECT i.id, i.name, i.base_price FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id JOIN items i ON i.id = p.seed_item_id WHERE pr.region_id = ? AND pr.tier = ? ORDER BY i.id';
    switch ($npc['traveller']) {
        case 'merchant':
            $seeds = q($seedSql, [$r['id'], 'uncommon'])->fetchAll();
            if (!$seeds) return null;
            $it = $seeds[crc32('m' . $s['stop']) % count($seeds)];
            return ['kind' => 'buy', 'item' => $it, 'price' => max(20, (int)round((int)$it['base_price'] * 1.5)),
                'label' => 'Buy ' . $it['name'] . ' (' . money(max(20, (int)round((int)$it['base_price'] * 1.5))) . ')', 'stop' => $s['stop']];
        case 'minstrel':
            return ['kind' => 'song', 'price' => 10, 'label' => '🎻 Request a song (' . money(10) . ')', 'stop' => $s['stop']];
        case 'naturalist':
            $seeds = q($seedSql, [$r['id'], 'staple'])->fetchAll() ?: q($seedSql, [$r['id'], 'uncommon'])->fetchAll();
            if (!$seeds) return null;
            $it = $seeds[crc32('w' . $s['stop']) % count($seeds)];
            return ['kind' => 'swap', 'item' => $it, 'label' => '🌱 Swap one of your finds for ' . $it['name'], 'stop' => $s['stop']];
    }
    return null;
}

function traveller_deal(array $u, int $npcId): array
{
    require_once __DIR__ . '/friends.php';
    $uid = (int)$u['id'];
    $npc = q_one('SELECT * FROM npcs WHERE id = ? AND traveller IS NOT NULL AND active = 1', [$npcId]);
    if (!$npc || $npc['traveller'] === 'gourmand') return [false, 'They aren’t a traveller.'];   // next version: Pomeroy is served on gourmand.php
    $stop = traveller_stop($npc);
    if (!can_reach($u, $stop['town'])) return [false, $npc['name'] . ' is in ' . $stop['town'] . ' right now.'];
    $offer = traveller_offer($npc);
    if (!$offer) return [false, '“Nothing for you today, I’m afraid.”'];
    db()->beginTransaction();
    try {
        db_insert('traveller_deals', ['user_id' => $uid, 'npc_id' => $npcId, 'stop' => $offer['stop'], 'at' => now()]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, '“Once per visit, friend! Catch me in the next town.”'];
    }
    $ok = true;
    $msg = '';
    if ($offer['kind'] === 'buy' || $offer['kind'] === 'song') {
        if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$offer['price'], $uid, $offer['price']])->rowCount() !== 1) {
            db()->rollBack();
            return [false, 'You need ' . money($offer['price']) . '.'];
        }
    }
    require_once __DIR__ . '/events.php';
    if ($offer['kind'] === 'buy') {
        give_item($uid, (int)$offer['item']['id'], 1);
        prize('🐢', $npc['name'] . ' makes a sale', '“A fine choice. Grow it well!”', ['−' . money($offer['price']), '+1 × ' . $offer['item']['name']]);
    } elseif ($offer['kind'] === 'song') {
        prize('🦗', $npc['name'] . ' plays just for you', 'A jig so bouncy your feet won’t keep still.', array_merge(['−' . money($offer['price'])], apply_event_effect($u, 'tbuff:charm:3:120+xp:3')));
    } else {
        $find = q_one("SELECT i.id, i.name FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'forage'
                       ORDER BY i.base_price, i.name LIMIT 1", [$uid]);
        if (!$find || !give_item($uid, (int)$find['id'], -1)) {
            db()->rollBack();
            return [false, '“Bring me something you found on your travels: berries, a shell, a mushroom…”'];
        }
        give_item($uid, (int)$offer['item']['id'], 1);
        prize('🐦', $npc['name'] . ' makes a swap', '“Oh, how interesting! Here, take these, they grow beautifully here.”', ['−1 × ' . $find['name'], '+1 × ' . $offer['item']['name']]);
    }
    friend_add($uid, $npcId, 2);
    db()->commit();
    return [$ok, $msg];
}

/** Has this gnome already had today's deal with the traveller at this stop? */
function traveller_dealt(int $uid, array $npc): bool
{
    return (bool)q_val('SELECT 1 FROM traveller_deals WHERE user_id = ? AND npc_id = ? AND stop = ?', [$uid, $npc['id'], traveller_stop($npc)['stop']]);
}
