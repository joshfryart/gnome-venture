<?php
declare(strict_types=1);
/**
 * NPC Clockwork (2.7.01 proposal, Josh 2026-11-15): every villager has a WEEK: two or three things they do (a stroll, a chat with the neighbours,
 * a walk to the next village, market day in town, a visit to a Trail Sight), each on set game days at a set hour, scattered so the world looks alive.
 * Everything here is computed, never stored: the same key gives the same week for everybody, so a forecast is TRUE ("Pip is at the Old Milestone on Thu
 * and Sun, 6 pm"). A missed appointment is not punished: the card just says when they are next there (the next game days).
 *
 * Keys: 's<id>' a rest-stop villager (stop_folk), 'n<id>' a town NPC (npcs). Travellers keep their circuit (npc_life.php traveller_stop), they are not here.
 * Modes (npc_cw_profile): 'fixed' = never leaves their place (calling mentors, names in data/npc_clockwork.txt `fixed|Name`), only strolls and tends at home;
 *                         'post'  = keeps a post all day (innkeeper, keeper, watcher ...: TRAIL_SIGHT_ROLE_ALLDAY), same, and the old Sight rows keep working;
 *                         'free'  = 2-3 doings a week; how far they go is rolled once per villager: local (stays in their stop or town, 45%), near (the next stop or
 *                                   another spot in town, 40%) or far (market in the road's town, or a Trail Sight, 15%).
 * A doing = ['id','kind','label','icon','days'=>[dow...],'start'=>hour,'dwell'=>hours per stop,'stops'=>[ref...]]. A ref is ['t'=>'home'] | ['t'=>'loc','id','name'] |
 *          ['t'=>'spot','id','name'] | ['t'=>'sight','slug','name']. Away from home the villager spends 1 hour on each leg and `dwell` hours at each stop, and is home by midnight.
 * Shops: a shopkeeper's doings avoid their shift where they can; when one cannot, another local NPC minds the shop (npc_cw_shop_cover).
 * Settings: npc_clockwork (1 = on). Data: data/npc_clockwork.txt. Test hooks: $GLOBALS['gv_cw_time'] = [dow, hour, dayIndex].
 */

require_once __DIR__ . '/npc_life.php';

const NPC_CW_DOW = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
/** kind => [icon, label with {dest}]: what each doing is called on the card. */
const NPC_CW_KINDS = [
    'stroll' => ['🚶', 'Takes a stroll round {place}'], 'gossip' => ['☕', 'Sits out with the neighbours'], 'tend' => ['🌱', 'Tends a patch'],
    'errand' => ['🎒', 'Walks over to {dest}'], 'market' => ['🛒', 'Goes to market in {dest}'], 'sight' => ['🔎', 'Goes to {dest}'], 'teach' => ['📚', 'Holds court at their post'],
];
const NPC_CW_LOCAL = ['stroll', 'gossip', 'tend'];
/** [start hour, dwell hours]: slots a doing can start in (an away doing adds 2 hours of walking). */
const NPC_CW_SLOTS = [[6, 2], [8, 3], [10, 2], [12, 3], [14, 3], [16, 2]];
const NPC_CW_POST_ROLES = ['Innkeeper', 'Keeper', 'Watcher', 'Lighthouse keeper', 'Signaller', 'Moth-watcher', 'Lair-watcher', 'Well-dweller', 'Scarecrow'];

function npc_cw_on(): bool
{
    $v = setting('npc_clockwork');
    return $v === '' || $v === '1';
}

/** [dow 0-6, hour (float, minutes as a fraction), game day index]. */
function npc_cw_clock(): array
{
    if (!empty($GLOBALS['gv_cw_time'])) return $GLOBALS['gv_cw_time'] + [2 => 20000];
    $d = function_exists('gclock_my_date') ? gclock_my_date() : date('Y-m-d');
    $min = 0;
    try { if (function_exists('gclock_me') && ($s = gclock_me()) && isset($s['minute'])) $min = (int)$s['minute'] % 60; } catch (Throwable $e) {}
    return [gclock_my_dow(), gclock_my_hour() + $min / 60, (int)floor(strtotime($d . ' 00:00:00 UTC') / 86400)];
}

function npc_cw_week_no(int $dayIndex): int
{
    return intdiv($dayIndex + 4, 7);
}

/** Names that never leave their place: calling mentors, plus `fixed|Name` lines of data/npc_clockwork.txt. */
function npc_cw_fixed_names(): array
{
    static $c = null;
    if ($c !== null) return $c;
    require_once __DIR__ . '/calling_quests.php';
    $c = array_map(fn($m) => $m[0], array_values(CALLING_MENTORS));
    $f = __DIR__ . '/data/npc_clockwork.txt';
    foreach (is_file($f) ? (file($f, FILE_IGNORE_NEW_LINES) ?: []) : [] as $l) {
        $l = trim($l);
        if ($l !== '' && $l[0] !== '#' && str_starts_with($l, 'fixed|')) $c[] = trim(substr($l, 6));
    }
    return $c;
}

/** A villager: ['key','kind' s|n,'id','name','role','home' (location id),'place','region','mode' fixed|post|free] or null. */
function npc_cw_profile(string $key): ?array
{
    static $m = [];
    if (array_key_exists($key, $m)) return $m[$key];
    $id = (int)substr($key, 1); $p = null;
    if ($key !== '' && $key[0] === 's') {
        $f = q_one('SELECT f.*, l.name AS place, l.region AS region FROM stop_folk f JOIN locations l ON l.id = f.location_id WHERE f.id = ?', [$id]);
        if ($f) $p = ['key' => $key, 'kind' => 's', 'id' => $id, 'name' => (string)$f['name'], 'role' => (string)$f['role'], 'home' => (int)$f['location_id'], 'place' => (string)$f['place'], 'region' => (string)$f['region']];
    } elseif ($key !== '' && $key[0] === 'n') {
        $n = q_one('SELECT n.*, l.name AS place, l.region AS region FROM npcs n LEFT JOIN locations l ON l.id = n.home_location_id WHERE n.id = ?', [$id]);
        if ($n && empty($n['traveller'])) $p = ['key' => $key, 'kind' => 'n', 'id' => $id, 'name' => (string)$n['name'], 'role' => '', 'home' => (int)($n['home_location_id'] ?? 0), 'place' => (string)($n['place'] ?? 'town'), 'region' => (string)($n['region'] ?? '')];
    }
    if ($p) $p['mode'] = in_array($p['name'], npc_cw_fixed_names(), true) ? 'fixed' : (in_array($p['role'], NPC_CW_POST_ROLES, true) ? 'post' : 'free');
    return $m[$key] = $p;
}

/** The roads as lists of location ids: [[id, ...], ...]. */
function npc_cw_roads(): array
{
    static $c = null;
    if ($c !== null && empty($GLOBALS['gv_sights_reload'])) return $c;
    $c = [];
    try { foreach (q('SELECT nodes FROM roads')->fetchAll() as $r) { $n = array_map('intval', json_decode((string)$r['nodes'], true) ?: []); if (count($n) > 1) $c[] = $n; } } catch (Throwable $e) {}
    return $c;
}

function npc_cw_loc_name(int $id): string
{
    static $m = [];
    return $m[$id] ??= (string)q_val('SELECT name FROM locations WHERE id = ?', [$id]);
}

/** The shift hours of a town NPC at a shop: [dow => [hour => true]]. */
function npc_cw_shift(int $npcId): array
{
    static $m = [];
    if (isset($m[$npcId])) return $m[$npcId];
    $out = [];
    foreach (q("SELECT * FROM npc_schedules WHERE npc_id = ? AND shop_id IS NOT NULL AND activity = 'working'", [$npcId])->fetchAll() as $s) {
        foreach (schedule_days((string)$s['days']) as $d) foreach (schedule_hours((int)$s['start_hour'], (int)$s['end_hour']) as $h) $out[$d][$h] = true;
    }
    return $m[$npcId] = $out;
}

/** The Trail Sights a villager is named at (rows of data/trail_sight_folk*.txt that follow the clockwork, not a traveller / post / mentor): key => [row, ...]. */
function npc_cw_sight_index(): array
{
    static $idx = null;
    if ($idx !== null && empty($GLOBALS['gv_sights_reload'])) return $idx;
    $idx = [];
    if (!function_exists('trail_sight_folk')) require_once __DIR__ . '/trail_sight_extras.php';
    foreach (trail_sight_folk() as $rows) foreach ($rows as $r) {
        $k = npc_cw_who_key($r['who']);
        if ($k !== '' && ($p = npc_cw_profile($k)) && $p['mode'] === 'free') $idx[$k][] = $r;
    }
    return $idx;
}

/** 's12' / 'n3' for a name in the Sights data, or '' (traveller, hidden, unknown). */
function npc_cw_who_key(string $who): string
{
    if (!function_exists('trail_sight_folk_role_kind')) require_once __DIR__ . '/trail_sight_extras.php';
    $k = trail_sight_folk_role_kind($who);
    return match ($k[0]) { 'road', 'shop', 'allday' => 's' . $k[1], 'npc' => 'n' . $k[1], default => '' };
}

/** The hour a Sight row's `when` wants (dp= values), as [first hour of the part, hours in it], or null for any time. */
function npc_cw_dp_window(string $when): ?array
{
    if (!preg_match('/(?:^|\/)dp=([a-z,]+)/', $when, $m)) return null;
    [$dawn, $day, $dusk, $night] = hollow_daypart_hours();
    $parts = ['dawn' => [$dawn, $day - $dawn], 'day' => [$day, $dusk - $day], 'dusk' => [$dusk, $night - $dusk], 'night' => [$night, max(1, min(3, 24 - $night))]];
    $first = explode(',', $m[1])[0];
    return $parts[$first] ?? null;
}

/**
 * The villager's doings for a game week (2 or 3). Memoised per key and week. A Sight row of theirs becomes a 'sight' doing (they cycle through their Sights week by week).
 */
function npc_cw_week(string $key, int $weekNo): array
{
    static $memo = [];
    $mk = $key . '|' . $weekNo;
    if (isset($memo[$mk]) && empty($GLOBALS['gv_sights_reload'])) return $memo[$mk];
    $p = npc_cw_profile($key);
    if (!$p) return $memo[$mk] = [];
    $u = fn(string $s) => hollow_unit('cw|' . $key . '|' . $s);
    $n = $p['mode'] === 'free' ? 2 + ($u('n') < 0.4 ? 1 : 0) : 2;
    $reachU = $u('reach');
    $reach = $p['mode'] !== 'free' ? 'local' : ($reachU < 0.45 ? 'local' : ($reachU < 0.85 ? 'near' : 'far'));
    $day0 = (int)floor($u('day') * 7);
    $rows = $p['mode'] === 'free' ? (npc_cw_sight_index()[$key] ?? []) : [];
    $shift = $p['kind'] === 'n' ? npc_cw_shift($p['id']) : [];
    $out = []; $used = [];
    $nSight = min(2, count($rows), $n);
    for ($i = 0; $i < $n; $i++) {
        $kind = null; $stops = [['t' => 'home']]; $days = [(($day0 + $i * 3) % 7)]; $slot = null; $dest = '';
        if ($i < $nSight) {   // a Trail Sight (rows rotate week by week)
            $r = $rows[($weekNo + $i) % count($rows)];
            $sn = function_exists('trail_sight_label') ? trail_sight_label($r['slug'])[0] : $r['slug'];
            $kind = 'sight'; $dest = $sn; $stops = [['t' => 'sight', 'slug' => $r['slug'], 'name' => $sn]];
            $days = [($day0 + $i * 2) % 7, ($day0 + $i * 2 + 3) % 7];
            if (str_contains($r['when'], 'gd=')) $days = range(0, 6);   // an every-Nth-game-day row: the condition picks the day
            if ($w = npc_cw_dp_window($r['when'])) $slot = [max(0, $w[0] - 1), max(1, min(2, $w[1]))];   // arrive as the part of the day begins
        } else {
            $local = NPC_CW_LOCAL[(int)floor($u('k' . $i) * 3)];
            $kind = $local;
            if ($reach !== 'local' && $i === $n - 1) {   // the last doing of a wanderer goes somewhere
                if ($p['kind'] === 's') {
                    $ng = npc_cw_neighbour($p['home'], $u('nb' . $i), $reach === 'far');
                    if ($ng) { $kind = $reach === 'far' && $ng['town'] ? 'market' : 'errand'; $dest = npc_cw_loc_name($ng['id']); $stops = [['t' => 'loc', 'id' => $ng['id'], 'name' => $dest]]; }
                } elseif (($sp = npc_cw_spot($p['region'], $u('sp' . $i)))) { $kind = 'errand'; $dest = $sp['name']; $stops = [['t' => 'spot', 'id' => (int)$sp['id'], 'name' => $sp['name']]]; }
            }
            if ($p['mode'] !== 'free' && $p['role'] !== '' && $i === 0) $kind = $p['mode'] === 'fixed' ? 'teach' : $kind;
        }
        if (!$slot) {   // a free slot: not over a shop shift when there is a way round it, and not the same hour twice
            $order = []; foreach (NPC_CW_SLOTS as $j => $s) $order[] = [$j, $u('s' . $i . $j)];
            usort($order, fn($a, $b) => $a[1] <=> $b[1]);
            $slot = NPC_CW_SLOTS[$order[0][0]];
            foreach ($order as [$j]) { $s = NPC_CW_SLOTS[$j]; if (isset($used[$s[0]])) continue; if (!npc_cw_hits_shift($shift, $days, $s[0], $s[1] + ($stops[0]['t'] === 'home' ? 0 : 2))) { $slot = $s; break; } }
        }
        $used[$slot[0]] = true;
        [$icon, $label] = NPC_CW_KINDS[$kind];
        $out[] = ['id' => $key . '#' . $i, 'kind' => $kind, 'icon' => $icon, 'label' => str_replace(['{dest}', '{place}'], [$dest, $p['place']], $label), 'days' => array_values(array_unique($days)),
            'start' => $slot[0], 'dwell' => $slot[1], 'stops' => $stops];
    }
    return $memo[$mk] = $out;
}

function npc_cw_hits_shift(array $shift, array $days, int $start, int $hours): bool
{
    foreach ($days as $d) for ($h = $start; $h < min(24, $start + $hours); $h++) if (!empty($shift[$d][$h])) return true;
    return false;
}

/** A stop next to this one on a road (['id', 'town' bool]), picked by $u; far = prefer the road's town. */
function npc_cw_neighbour(int $home, float $u, bool $preferTown): ?array
{
    $c = [];
    foreach (npc_cw_roads() as $r) {
        $i = array_search($home, $r, true);
        if ($i === false) continue;
        foreach ([$i - 1, $i + 1] as $j) if (isset($r[$j])) $c[] = ['id' => $r[$j], 'town' => $j === 0 || $j === count($r) - 1];
    }
    if ($preferTown) { $t = array_values(array_filter($c, fn($x) => $x['town'])); if ($t) $c = $t; }
    return $c ? $c[(int)floor($u * count($c)) % count($c)] : null;
}

/** A town spot of a region (green, teahouse ...) picked by $u. */
function npc_cw_spot(string $region, float $u): ?array
{
    static $m = [];
    $m[$region] ??= q('SELECT id, name FROM town_spots WHERE region = ? AND active = 1 ORDER BY id', [$region])->fetchAll();
    return $m[$region] ? $m[$region][(int)floor($u * count($m[$region])) % count($m[$region])] : null;
}

/** A doing as a timeline: [['t'=>'dwell','at'=>ref,'from'=>h,'to'=>h] | ['t'=>'walk','a'=>ref,'b'=>ref,'from','to']], and the end hour. */
function npc_cw_timeline(array $d): array
{
    $home = ['t' => 'home']; $seg = []; $t = (float)$d['start'];
    $away = $d['stops'][0]['t'] !== 'home';
    if (!$away) return [[['t' => 'dwell', 'at' => $home, 'from' => $t, 'to' => $t + $d['dwell']]], $t + $d['dwell']];
    $places = array_merge([$home], $d['stops'], [$home]);
    foreach ($places as $i => $pl) {
        if ($i > 0) { $seg[] = ['t' => 'walk', 'a' => $places[$i - 1], 'b' => $pl, 'from' => $t, 'to' => $t + 1]; $t += 1; }
        if ($i > 0 && $i < count($places) - 1) { $seg[] = ['t' => 'dwell', 'at' => $pl, 'from' => $t, 'to' => $t + $d['dwell']]; $t += $d['dwell']; }
    }
    return [$seg, $t];
}

/**
 * Where a villager is at ($dow, $hour): ['out' => bool (away from their own stop / town spot), 'moving' => bool, 'at' => ref|null, 'from','to','p' (0..1 on a walk), 'doing' => doing|null].
 * A free villager away from home is out; a local doing (stroll, gossip, tend) keeps them at home and only names what they are doing.
 */
function npc_cw_state(string $key, ?int $dow = null, ?float $hour = null, ?int $weekNo = null): array
{
    [$cd, $ch, $cdi] = npc_cw_clock();
    $dow ??= $cd; $hour ??= $ch; $weekNo ??= npc_cw_week_no($cdi);
    $home = ['out' => false, 'moving' => false, 'at' => ['t' => 'home'], 'doing' => null];
    if (!npc_cw_on() || !npc_cw_profile($key)) return $home;
    if (!empty($GLOBALS['gv_cw_out'][$key])) return ['out' => true, 'moving' => false, 'at' => ['t' => 'loc', 'id' => 0, 'name' => 'away'], 'doing' => ['label' => 'Away (test)']];   // test hook
    foreach (npc_cw_week($key, $weekNo) as $d) {
        if (!in_array($dow, $d['days'], true)) continue;
        [$seg, $end] = npc_cw_timeline($d);
        if ($hour < $d['start'] || $hour >= min(24, $end)) continue;
        foreach ($seg as $s) {
            if ($hour < $s['from'] || $hour >= $s['to']) continue;
            if ($s['t'] === 'walk') return ['out' => true, 'moving' => true, 'at' => null, 'from' => $s['a'], 'to' => $s['b'], 'p' => ($hour - $s['from']) / ($s['to'] - $s['from']), 'doing' => $d];
            return ['out' => $s['at']['t'] !== 'home', 'moving' => false, 'at' => $s['at'], 'doing' => $d];
        }
    }
    return $home;
}

/** Is the villager away from their own stop right now (so they are not at the stop's pictures and cannot be chatted to there)? */
function npc_cw_out(string $key): bool
{
    return npc_cw_on() && !empty(npc_cw_state($key)['out']);
}

/** Is the villager standing at this Trail Sight right now? */
function npc_cw_at_sight(string $key, string $slug): bool
{
    $s = npc_cw_state($key);
    return !$s['moving'] && ($s['at']['t'] ?? '') === 'sight' && $s['at']['slug'] === $slug;
}

/**
 * The Sights data row says this villager is at a Sight: does the clockwork agree? true / false, or null when the clockwork does not manage them (a traveller, a post-holder,
 * a hidden NPC: the old time-of-day rules and chance still apply). Mentors and other fixed names never travel: false.
 */
function npc_cw_sight_check(string $who, string $slug): ?bool
{
    if (!npc_cw_on()) return null;
    [$name] = function_exists('trail_sight_split_who') ? trail_sight_split_who($who) : [$who, ''];
    if (in_array($name, npc_cw_fixed_names(), true)) return false;
    $k = npc_cw_who_key($who);
    if ($k === '' || !($p = npc_cw_profile($k)) || $p['mode'] !== 'free') return null;
    return npc_cw_at_sight($k, $slug);
}

/** 2.7.06: do the foreseeable parts of a Sight row's `when` (dp, mo, ti) hold at some hour of a visit from $from to $to on day index $dayIdx? Other keys are not foretold and pass. */
function npc_cw_when_ok(string $when, float $from, float $to, int $dayIdx): bool
{
    if (trim($when) === '' || trim($when) === '-') return true;
    foreach (explode('/', $when) as $part) {
        [$k, $v] = array_pad(explode('=', trim($part), 2), 2, '');
        if (!in_array($k, ['dp', 'mo', 'ti'], true) || $v === '') continue;
        $want = array_filter(array_map('trim', explode(',', $v)));
        if ($k === 'mo') { require_once __DIR__ . '/moon.php'; if (!in_array(moon_phase($dayIdx)['key'], $want, true)) return false; continue; }
        $okp = false;
        for ($h = (int)floor($from); $h < (int)ceil($to) && !$okp; $h++) {
            $hh = $h % 24;
            if ($k === 'dp') { $okp = in_array(hollow_daypart($hh), $want, true); }
            else { require_once __DIR__ . '/moon.php'; $okp = in_array(moon_tide((float)$hh, $dayIdx)['state'], $want, true); }
        }
        if (!$okp) return false;
    }
    return true;
}

/**
 * The next time this villager is at a Sight (from now, up to 28 game days ahead), by the schedule only (season and weather rows are not foretold):
 * ['in' => game days from today, 'dow', 'from', 'to' (hours at the Sight), 'now' => bool (they are there now), 'text'] or null.
 */
function npc_cw_forecast(string $who, string $slug, string $when = ''): ?array
{   // 2.7.06: $when = the Sight row's condition ("dp=dusk/mo=full"): the parts the schedule can foretell (dp, mo, ti) must hold at the visit, so a row for dusk never promises a morning visit; season, weather and the rest are not foretold
    $k = npc_cw_who_key($who);
    if ($k === '' || !npc_cw_profile($k) || !npc_cw_on()) return null;
    [$dow, $hour, $di] = npc_cw_clock();
    for ($d = 0; $d <= 28; $d++) {
        $dw = ($dow + $d) % 7; $wk = npc_cw_week_no($di + $d);
        foreach (npc_cw_week($k, $wk) as $dg) {
            if (!in_array($dw, $dg['days'], true) || ($dg['stops'][0]['slug'] ?? '') !== $slug) continue;
            $from = $dg['start'] + 1; $to = $from + $dg['dwell'];
            if ($d === 0 && $hour >= $to) continue;
            if ($when !== '' && !npc_cw_when_ok($when, $from, $to, $di + $d)) continue;
            $now = $d === 0 && $hour >= $from;
            return ['in' => $d, 'dow' => $dw, 'from' => $from, 'to' => $to, 'now' => $now, 'text' => $now ? 'here now, until ' . hour_label($to)
                : ($d === 0 ? 'today' : ($d === 1 ? 'tomorrow' : NPC_CW_DOW[$dw] . ', in ' . $d . ' game days')) . ' ' . hour_label($from) . ' – ' . hour_label($to)];
        }
    }
    return null;
}

/** "Pip: here now until 6 pm" lines for the Sights card: one per villager named at this Sight who follows the clockwork. */
function npc_cw_sight_lines(string $slug): array
{
    $out = [];
    if (!npc_cw_on()) return $out;
    foreach (trail_sight_folk()[$slug] ?? [] as $r) {
        $k = npc_cw_who_key($r['who']);
        if ($k === '' || !($p = npc_cw_profile($k)) || $p['mode'] !== 'free') continue;
        $f = npc_cw_forecast($r['who'], $slug, (string)($r['when'] ?? ''));
        $out[] = ['who' => $r['who'], 'name' => trail_sight_split_who($r['who'])[0], 'text' => $f ? $f['text'] : 'not for a while', 'now' => (bool)($f['now'] ?? false), 'when' => (string)($r['when'] ?? '')];
    }
    return $out;
}

/** What a villager is doing now, in words, or '' when they have nothing on: "Takes a stroll round Poppyburrow". */
function npc_cw_doing_text(string $key): string
{
    $s = npc_cw_state($key);
    if ($s['moving']) return 'on the road to ' . ($s['to']['name'] ?? 'somewhere');
    return $s['doing'] ? (string)$s['doing']['label'] : '';
}

/**
 * npc_now overlay for a town NPC (npc_life.php): when their week has them out of town or at another spot, or they are minding a shop for somebody, this says so;
 * null = follow the ordinary schedule.
 */
function npc_cw_overlay(array $npc): ?array
{
    if (!npc_cw_on() || !empty($npc['traveller'])) return null;
    $key = 'n' . (int)$npc['id']; $p = npc_cw_profile($key);
    if (!$p) return null;
    $s = npc_cw_state($key);
    if ($s['out']) {
        $town = $p['region'] !== '' ? $p['region'] : null; $spot = null;
        if (($s['at']['t'] ?? '') === 'spot') { $spot = q_one('SELECT * FROM town_spots WHERE id = ?', [(int)$s['at']['id']]); return ['what' => 'at ' . ($spot['name'] ?? 'a spot of town'), 'town' => $town, 'spot' => $spot ?: null, 'doing' => $s['doing']['label'] ?? '']; }
        if (($s['at']['t'] ?? '') === 'loc') $town = (string)q_val('SELECT region FROM locations WHERE id = ?', [(int)$s['at']['id']]) ?: $town;
        return ['what' => $s['moving'] ? 'on the road' : ($s['doing']['label'] ?? 'out and about'), 'town' => $town, 'spot' => null, 'doing' => $s['doing']['label'] ?? ''];
    }
    if ($cover = npc_cw_covering($npc)) return ['what' => 'minding ' . $cover['shop_name'], 'town' => $p['region'] ?: null, 'spot' => null, 'doing' => 'Minds ' . $cover['shop_name'] . ' for ' . $cover['keeper']];
    return null;
}

/** The town NPCs who work a shop shift: shop id => [keeper npc rows, ...] (cached). */
function npc_cw_keepers(): array
{
    static $m = null;
    if ($m !== null) return $m;
    $m = [];
    foreach (q("SELECT s.shop_id, s.npc_id, n.name, sh.name AS shop_name, sh.location_id, l.region FROM npc_schedules s JOIN npcs n ON n.id = s.npc_id AND n.active = 1
        JOIN shops sh ON sh.id = s.shop_id LEFT JOIN locations l ON l.id = sh.location_id WHERE s.activity = 'working' AND n.traveller IS NULL GROUP BY s.shop_id, s.npc_id, n.name, sh.name, sh.location_id, l.region")->fetchAll() as $r) $m[(int)$r['shop_id']][] = $r;
    return $m;
}

/**
 * Who minds this shop right now when its keeper is out on a doing (or away today)? A local NPC of the same region: not another keeper, not a traveller, not out themselves,
 * picked by the shop and the day so the same neighbour does it all day. Returns the town NPC row or null (the keeper is in, or nobody can: the shop keeps its own hours).
 */
function npc_cw_shop_cover(int $shopId, ?int $dow = null, ?float $hour = null): ?array
{
    $ks = npc_cw_keepers()[$shopId] ?? [];
    if (!npc_cw_on() || !$ks) return null;
    [$cd, $ch, $cdi] = npc_cw_clock(); $dow ??= $cd; $hour ??= $ch;
    $keeper = null;
    foreach ($ks as $k) {
        $sh = npc_cw_shift((int)$k['npc_id']);
        if (empty($sh[$dow][(int)floor($hour)])) continue;
        $keeper = $k;
        if (!npc_cw_state('n' . $k['npc_id'], $dow, $hour)['out'] && !(function_exists('gclock_npc_away') && gclock_npc_away('n' . $k['npc_id']))) return null;   // on shift and in
    }
    if (!$keeper) return null;
    $cand = array_values(array_filter(q("SELECT n.* FROM npcs n LEFT JOIN locations l ON l.id = n.home_location_id WHERE n.active = 1 AND n.traveller IS NULL AND l.region = ? ORDER BY n.id", [(string)$keeper['region']])->fetchAll(),
        fn($n) => (int)$n['id'] !== (int)$keeper['npc_id'] && empty(npc_cw_shift((int)$n['id'])[$dow][(int)floor($hour)]) && !npc_cw_state('n' . $n['id'], $dow, $hour)['out']
            && !npc_cw_mode_fixed((string)$n['name']) && !(function_exists('gclock_npc_away') && gclock_npc_away('n' . $n['id']))));
    if (!$cand) return null;
    return $cand[(int)floor(hollow_unit('cwcover|' . $shopId . '|' . $cdi) * count($cand)) % count($cand)];
}

function npc_cw_mode_fixed(string $name): bool
{
    return in_array($name, npc_cw_fixed_names(), true);
}

/** Is this NPC minding a shop for somebody right now? ['shop_name', 'keeper'] or null. */
function npc_cw_covering(array $npc): ?array
{
    static $memo = [];
    [$dow, $hour] = npc_cw_clock();
    $mk = (int)$npc['id'] . '|' . $dow . '|' . (int)$hour;
    if (array_key_exists($mk, $memo) && empty($GLOBALS['gv_sights_reload'])) return $memo[$mk];
    $r = null;
    foreach (npc_cw_keepers() as $shopId => $ks) {
        $c = npc_cw_shop_cover((int)$shopId);
        if ($c && (int)$c['id'] === (int)$npc['id']) { $r = ['shop_name' => (string)$ks[0]['shop_name'], 'keeper' => (string)$ks[0]['name'], 'shop_id' => (int)$shopId]; break; }
    }
    return $memo[$mk] = $r;
}

/** Hours of today (0-23) when this villager is at the Sight: [hour => true]. */
function npc_cw_hours_at(string $who, string $slug): array
{
    $k = npc_cw_who_key($who); $out = [];
    if ($k === '' || !npc_cw_profile($k)) return $out;
    [$dow, , $di] = npc_cw_clock();
    for ($h = 0; $h < 24; $h++) { $s = npc_cw_state($k, $dow, $h + 0.5, npc_cw_week_no($di)); if (!$s['moving'] && ($s['at']['t'] ?? '') === 'sight' && $s['at']['slug'] === $slug) $out[$h] = true; }
    return $out;
}

/** The "who is here and when" block of a Sights card: a line per villager (here now / next appointment) and a 24-hour strip of today with a gold notch for now. '' when none. */
function npc_cw_sight_card_html(string $slug): string
{
    $lines = npc_cw_sight_lines($slug);
    if (!$lines) return '';
    $nowH = (int)floor(npc_cw_clock()[1]);
    $h = '<div class="cwtime" aria-label="When villagers are here">';
    foreach ($lines as $l) {
        $hrs = npc_cw_hours_at($l['who'], $slug);
        $bar = '';
        for ($i = 0; $i < 24; $i++) $bar .= '<i class="' . (isset($hrs[$i]) ? 'on' : '') . ($i === $nowH ? ' now' : '') . '"></i>';
        $h .= '<p class="cwrow' . ($l['now'] ? ' here' : '') . '"><span>🕒 <b>' . e($l['name']) . '</b>: ' . e($l['text']) . '</span><span class="cwbar" role="img" aria-label="Today, hour by hour">' . $bar . '</span></p>';
    }
    return $h . '</div>';
}
