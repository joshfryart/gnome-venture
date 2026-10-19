<?php
declare(strict_types=1);
/**
 * v0.7.98: destinations. Tap a stop on a road board, a place on the map or a Seek result, and the game works out the way along
 * the roads and offers the FIRST walk only. The goal is remembered (users.dest_id) and each time the gnome arrives somewhere a
 * "Continue to X →" button offers the next leg. Nothing is walked automatically: every leg is a tap and a normal walk.
 */
require_once __DIR__ . '/adventure.php';
require_once __DIR__ . '/roads.php';

/** The routes from a place the gnome may walk: roads, plus side paths to places on a road or ones they've found. [to id => route] */
function dest_edges(int $uid, int $locId): array
{
    static $cache = [];
    if (isset($cache[$locId])) return $cache[$locId];
    $out = [];
    foreach (q('SELECT * FROM routes WHERE a_id = ? OR b_id = ?', [$locId, $locId])->fetchAll() as $r) {
        $to = (int)$r['a_id'] === $locId ? (int)$r['b_id'] : (int)$r['a_id'];
        if (($r['kind'] ?? 'road') === 'side' && !on_road($to)) {
            $l = q_one('SELECT * FROM locations WHERE id = ?', [$to]);
            if (!$l || !place_known($uid, $l)) continue;
        }
require_once __DIR__ . '/items.php';   // v1.5.2: ph_img (placeholders)
        $out[$to] = $r;
    }
    return $cache[$locId] = $out;
}

/** The fewest-stops way from $from to $to: a list of routes in order ([] when already there, null when there's no way). */
function dest_path(int $uid, int $from, int $to): ?array
{
    if ($from === $to) return [];
    $prev = [$from => null];
    $queue = [$from];
    while ($queue) {
        $at = array_shift($queue);
        foreach (dest_edges($uid, $at) as $next => $route) {
            if (array_key_exists($next, $prev)) continue;   // (the start is null, so isset() would revisit it forever)
            $prev[$next] = [$at, $route];
            if ($next === $to) {
                $path = [];
                for ($n = $to; $prev[$n] !== null; $n = $prev[$n][0]) array_unshift($path, $prev[$n][1]);
                return $path;
            }
            $queue[] = $next;
        }
        if (count($prev) > 2000) break;   // the world is far smaller than this
    }
    return null;
}

/** A place's name as this gnome knows it ("???" until visited, towns always). */
function dest_name(int $uid, array $loc): string
{
    return in_array($loc['kind'], ['market', 'hub'], true) || place_known($uid, $loc) ? (string)$loc['name'] : '???';
}

/**
 * v1.2.2: the real kind of a stop. Delves (and wonders, lairs) are all locations.kind 'wonder'/'lair' in the locations table;
 * the true kind is landmarks.kind. One query for the whole landmarks table, kept for the request.
 */
function loc_real_kind(array $loc): string
{
    static $byLoc = null;
    $k = (string)($loc['kind'] ?? '');
    if (!in_array($k, ['wonder', 'lair', 'haven', 'delve'], true)) return $k;
    if ($byLoc === null) {
        $byLoc = [];
        foreach (q('SELECT location_id, kind FROM landmarks WHERE location_id IS NOT NULL')->fetchAll() as $r) $byLoc[(int)$r['location_id']] = (string)$r['kind'];
    }
    return $byLoc[(int)($loc['id'] ?? 0)] ?? $k;
}

/** A small icon for a kind of stop. */
function dest_icon(array $loc): string
{
    // v1.2.2: wonder/lair/delve icons (same as the maps), delve resolved through landmarks
    $k = loc_real_kind($loc);
    if (in_array($k, ['haven', 'wonder', 'delve', 'lair'], true) && ($pi = ph_img('lm-' . $k, 20)) !== '') return $pi;   // v1.5.2: landmark placeholder
    return ['hub' => '🏛️', 'market' => '🏪', 'village' => '🏘️', 'haven' => '⛺', 'ruin' => '🏚️', 'wonder' => '✨', 'lair' => '🐉', 'delve' => '🕳️'][loc_real_kind($loc)] ?? '📍';
}

/**
 * v0.9.3: the whole route from where the gnome stands to $toId, stop by stop.
 * Returns ['path' => routes, 'stops' => [[loc, route, steps, energy, lo, hi, minutes]...]] or null when there's no way.
 */
function dest_plan(array $u, int $toId): ?array
{
    $uid = (int)$u['id'];
    $here = player_node($u);
    $path = dest_path($uid, (int)$here['id'], $toId);
    if ($path === null) return null;
    $at = (int)$here['id'];
    $stops = [];
    foreach ($path as $r) {
        $to = (int)$r['a_id'] === $at ? (int)$r['b_id'] : (int)$r['a_id'];
        $loc = q_one('SELECT * FROM locations WHERE id = ?', [$to]);
        if (!$loc) return null;
        [$lo, $hi] = route_danger($u, $r);
        [$mins, $quick] = route_walk_minutes($u, $r);   // v0.9.7: a road far below you is a quick walk
        $stops[] = ['loc' => $loc, 'route' => $r, 'steps' => (int)$r['steps'], 'energy' => route_energy($u, $r), 'lo' => $lo, 'hi' => $hi, 'minutes' => $mins, 'quick' => $quick];
        $at = $to;
    }
    return ['path' => $path, 'stops' => $stops];
}

/** Location ids along the remembered route, starting with where the gnome is (for the map to highlight). [] when not heading anywhere. */
function dest_route_ids(array $u): array
{
    $id = (int)($u['dest_id'] ?? 0);
    if (!$id) return [];
    $here = player_node($u);
    $ids = [(int)$here['id']];
    $path = dest_path((int)$u['id'], (int)$here['id'], $id);
    if (!$path) return $ids;
    $at = (int)$here['id'];
    foreach ($path as $r) {
        $at = (int)$r['a_id'] === $at ? (int)$r['b_id'] : (int)$r['a_id'];
        $ids[] = $at;
    }
    return $ids;
}

/** v1.0.4: places "Pause at towns" stops at: towns, the hub and every rest stop (road village) with its own Town page. */
function dest_is_town(array $loc): bool
{
    return in_array($loc['kind'] ?? '', ['market', 'hub', 'village'], true);
}

/** The "keep walking" / "pause at towns" checkboxes. */
function dest_opts_html(array $u): string
{
    $auto = (int)($u['dest_auto'] ?? 1) === 1;
    $pause = (int)($u['dest_pause_towns'] ?? 0) === 1;
    return '<label class="destopt"><input type="checkbox" name="dest_auto" value="1"' . ($auto ? ' checked' : '') . '> 🧭 Keep walking after each stop</label> '
        . '<label class="destopt"><input type="checkbox" name="dest_pause" value="1"' . ($pause ? ' checked' : '') . '> ⏸️ Pause at towns &amp; rest stops</label>';
}

/**
 * The 🧭 route plan for heading to $toId: every stop in order with steps, energy and danger, totals, and Set off / Forget.
 * $continue = it's the remembered destination. Empty if the place doesn't exist.
 */
function dest_panel(array $u, int $toId, bool $continue = false): string
{
    $uid = (int)$u['id'];
    $to = q_one('SELECT l.*, rg.gnomish_name AS region_name FROM locations l LEFT JOIN regions rg ON rg.id = l.region_id WHERE l.id = ?', [$toId]);
    if (!$to) return '';
    $here = player_node($u);
    $name = dest_name($uid, $to);
    $h = '<div class="box destpanel" id="gopanel"><h3>' . ($continue ? '🏁 Heading to ' : '🧭 Head to ') . e($name) . ($to['region_name'] ? ' <small class="muted">· ' . e((string)$to['region_name']) . '</small>' : '') . '</h3>';
    if ((int)$here['id'] === $toId) return $h . '<p>🎩 You’re here!</p></div>';
    $busy = active_expedition($uid) !== null;
    $plan = dest_plan($u, $toId);
    if ($plan === null) return $h . '<p class="muted">You don’t know a way there from here yet. Explore off the road to find new paths.</p></div>';
    $stops = $plan['stops'];
    $n = count($stops);
    $steps = $energy = $mins = $quickN = 0;
    $h .= '<ol class="routeplan">';
    if ((int)($u['dest_id'] ?? 0) === $toId) {   // v0.9.5: stops already passed on this journey
        $passed = array_values(array_filter(dest_trail($u), fn($id) => $id !== (int)$here['id']));
        if (count($passed) > 6) { $h .= '<li class="rp done"><span class="rpmark">✅</span> <small class="muted">+ ' . (count($passed) - 6) . ' earlier</small></li>'; $passed = array_slice($passed, -6); }
        foreach ($passed as $pid) {
            if ($pl = q_one('SELECT * FROM locations WHERE id = ?', [$pid])) {
                $h .= '<li class="rp done"><span class="rpmark">✅</span> <span class="rpicon">' . dest_icon($pl) . '</span> <span class="rpname">' . e(dest_name($uid, $pl)) . '</span> <small class="muted">passed</small></li>';
            }
        }
    }
    $h .= '<li class="rp here"><span class="rpmark">🎩</span> <span class="rpname">' . e(dest_name($uid, $here)) . '</span> <small class="muted">you are here</small></li>';
    foreach ($stops as $s) {
        $steps += $s['steps']; $energy += $s['energy']; $mins += $s['minutes']; $quickN += $s['quick'] ? 1 : 0;
        $h .= '<li class="rp ahead"><span class="rpmark">○</span> <span class="rpicon">' . dest_icon($s['loc']) . '</span> <span class="rpname">' . e(dest_name($uid, $s['loc'])) . '</span> '
            . '<small class="muted">' . $s['steps'] . ' steps · ⚡' . $s['energy'] . ' · Lv ' . $s['lo'] . ($s['hi'] > $s['lo'] ? '–' . $s['hi'] : '') . ($s['quick'] ? ' · 💨 quick walk' : '') . '</small></li>';
    }
    $h .= '</ol>';
    $h .= '<p class="routetotal">' . $n . ' stop' . ($n === 1 ? '' : 's') . ' · ' . $steps . ' steps · ⚡' . $energy . ' · about ' . ($mins > 0 ? nice_time($mins * 60) : 'no time') . ' of mycelium rides' . ($quickN ? ' (💨 ' . $quickN . ' quick walk' . ($quickN === 1 ? '' : 's') . ' included)' : '') . '</p>';
    // Another region you can fast travel to: say so (the gnome chooses)
    $rid = (int)($to['region_id'] ?? 0);
    if ($rid && $rid !== (int)($here['region_id'] ?? 0) && $n > 1 && can_fast_travel($u, $rid)) {
        require_once __DIR__ . '/seek.php';
        $h .= '<p class="help">🧭 Or <a href="' . e(url('world.php?tab=travel#fasttravel')) . '">fast travel</a> to ' . e((string)$to['region_name']) . ' first (' . money(seek_travel_cost($u, $rid)) . ') and walk from its town.</p>';
    }
    if ($busy) return $h . '<p class="muted">Finish the walk you’re on first.</p></div>';
    $first = $plan['path'][0];
    $h .= '<form method="post" action="' . e(url('adventure.php')) . '" class="destgo">' . csrf_field()
        . '<input type="hidden" name="do" value="start"><input type="hidden" name="dest" value="' . $toId . '">'
        . '<button class="btn">▶ Set off</button> ' . dest_opts_html($u)
        . '<p class="help">First: ' . (int)$first['steps'] . ' steps to ' . e(dest_name($uid, $stops[0]['loc'])) . '. You tap each step; the next leg starts when you arrive.</p></form>';
    $h .= '<form method="post" action="' . e(url('adventure.php')) . '" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="dest_forget"><input type="hidden" name="back" value="world.php"><button class="btn ghost">✖ Forget</button></form>';
    return $h . '</div>';
}

/** Remember (or forget, with 0) where the gnome is heading. */
function dest_set(int $uid, int $locId): void
{
    if ($locId && !q_val('SELECT 1 FROM locations WHERE id = ?', [$locId])) return;
    q('UPDATE users SET dest_id = ?, dest_chain = 0, dest_legs = 0, dest_trail = NULL WHERE id = ?', [$locId ?: null, $uid]);
}

/** v0.9.5: the stops already passed on this journey (location ids, oldest first). */
function dest_trail(array $u): array
{
    return array_values(array_unique(array_filter(array_map('intval', explode(',', (string)($u['dest_trail'] ?? ''))))));
}

function dest_trail_save(int $uid, array $ids): void
{
    q('UPDATE users SET dest_trail = ? WHERE id = ?', [$ids ? implode(',', array_slice(array_values(array_unique(array_map('intval', $ids))), -40)) : null, $uid]);
}

/** Save the keep-walking / pause-at-towns choices from a posted form. */
function dest_save_opts(int $uid): void
{
    q('UPDATE users SET dest_auto = ?, dest_pause_towns = ? WHERE id = ?', [isset($_POST['dest_auto']) ? 1 : 0, isset($_POST['dest_pause']) ? 1 : 0, $uid]);
}

/** Set off: remember the goal, store the leg count and start the first leg. [ok, message] */
function dest_set_off(array $u, int $toId): array
{
    $uid = (int)$u['id'];
    if (!q_val('SELECT 1 FROM locations WHERE id = ?', [$toId])) return [false, 'That place doesn’t exist.'];
    $plan = dest_plan($u, $toId);
    if ($plan === null || !$plan['path']) return [false, 'You don’t know a way there from here.'];
    $keep = (int)($u['dest_id'] ?? 0) === $toId ? dest_trail($u) : [];   // same goal as before: keep the stops already passed
    $from = (int)player_node($u)['id'];
    [$ok, $msg] = start_expedition($u, (int)$plan['path'][0]['id']);
    if ($ok) {
        dest_set($uid, $toId);
        dest_trail_save($uid, array_merge($keep, [$from]));
        q('UPDATE users SET dest_legs = ? WHERE id = ?', [count($plan['path']), $uid]);
        dest_save_opts($uid);
    }
    return [$ok, $msg];
}

/**
 * After a walk's arrival: when "keep walking" is on, start the next leg. Returns null (nothing to say: not heading anywhere,
 * keep-walking off, or the goal was reached) or [started, message]. Call AFTER the finished walk is saved.
 */
function dest_chain_after_arrival(int $uid): ?array
{
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    if (!$u || !(int)($u['dest_id'] ?? 0)) return null;
    $destId = (int)$u['dest_id'];
    $here = player_node($u);
    if ((int)$here['id'] === $destId) { dest_set($uid, 0); return null; }
    dest_trail_save($uid, array_merge(dest_trail($u), [(int)$here['id']]));   // v0.9.5: remember we passed here
    if (!(int)($u['dest_auto'] ?? 1)) return null;
    if (active_expedition($uid)) return null;
    if ((int)$u['dest_chain'] >= max(1, (int)setting('dest_max_chain'))) return [false, '🧭 That’s a long way! Stopping for a breather. Tap Set off to go on.'];
    if ((int)($u['dest_pause_towns'] ?? 0) && dest_is_town($here)) return [false, '🧭 Paused at ' . $here['name'] . '. Look around, then tap Set off to go on.'];   // v1.0.4: rest stops count
    $path = dest_path($uid, (int)$here['id'], $destId);
    if (!$path) return [false, '🧭 You don’t know a way on from here. Your route stops here.'];
    refresh_energy($u);
    $cost = route_energy($u, $path[0]);
    if ($cost > 0 && (int)$u['energy'] < $cost && !staff_free($uid)) return [false, '🧭 Too tired to walk on (⚡' . $cost . ' needed). Rest, then tap Set off.'];
    [$ok, $msg] = start_expedition($u, (int)$path[0]['id']);
    if (!$ok) return [false, '🧭 ' . $msg];
    q('UPDATE users SET dest_chain = dest_chain + 1 WHERE id = ?', [$uid]);
    $next = q_one('SELECT * FROM locations WHERE id = ?', [(int)$path[0]['a_id'] === (int)$here['id'] ? (int)$path[0]['b_id'] : (int)$path[0]['a_id']]);
    return [true, '🧭 Walking on to ' . ($next ? dest_name($uid, $next) : 'the next stop') . '…'];
}

/** For the Today page and the World page: [location, stops left] while heading somewhere, else null (and clears it on arrival). */
function dest_status(array $u): ?array
{
    $id = (int)($u['dest_id'] ?? 0);
    if (!$id) return null;
    $here = player_node($u);
    if ((int)$here['id'] === $id) {
        dest_set((int)$u['id'], 0);
        return null;
    }
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [$id]);
    $path = $loc ? dest_path((int)$u['id'], (int)$here['id'], $id) : null;
    return $loc && $path !== null ? [$loc, count($path)] : null;
}

/**
 * While walking a leg of the remembered route: ['loc' => goal, 'k' => leg number, 'n' => legs, 'left' => stops left,
 * 'next' => the stop after this leg's end (or null), 'next_energy' => its leg's energy]. Null when not on the route.
 */
function dest_walk_info(array $u, array $exp): ?array
{
    $id = (int)($u['dest_id'] ?? 0);
    if (!$id || ($exp['kind'] ?? 'walk') !== 'walk') return null;
    $uid = (int)$u['id'];
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [$id]);
    $path = $loc ? dest_path($uid, (int)$exp['from_id'], $id) : null;
    if (!$path || (int)$path[0]['id'] !== (int)$exp['route_id']) return null;
    $left = count($path);
    $n = max((int)($u['dest_legs'] ?? 0), $left);
    $info = ['loc' => $loc, 'k' => max(1, $n - $left + 1), 'n' => $n, 'left' => $left, 'next' => null, 'next_energy' => 0];
    if ($left > 1) {
        $info['next'] = q_one('SELECT * FROM locations WHERE id = ?', [(int)$path[1]['a_id'] === (int)$exp['to_id'] ? (int)$path[1]['b_id'] : (int)$path[1]['a_id']]);
        $info['next_energy'] = route_energy($u, $path[1]);
    }
    return $info;
}

/** v1.0.4: a one-line "carry on" bar for a town or rest stop page while a route is remembered and the gnome is standing still. */
function dest_resume_html(array $u): string
{
    $ds = dest_status($u);
    if (!$ds || active_expedition((int)$u['id'])) return '';
    [$loc, $left] = $ds;
    return '<form method="post" action="' . e(url('adventure.php')) . '" class="box destresume">' . csrf_field()
        . '<input type="hidden" name="do" value="start"><input type="hidden" name="dest" value="' . (int)$loc['id'] . '">'
        . (((int)($u['dest_auto'] ?? 1)) ? '<input type="hidden" name="dest_auto" value="1">' : '') . (((int)($u['dest_pause_towns'] ?? 0)) ? '<input type="hidden" name="dest_pause" value="1">' : '')
        . '<span>🏁 Heading to <b>' . e(dest_name((int)$u['id'], $loc)) . '</b> · ' . (int)$left . ' stop' . ($left === 1 ? '' : 's') . ' left</span> '
        . '<button class="btn small">▶ Set off</button> <a class="small" href="' . e(url('world.php#gopanel')) . '">Route</a></form>';
}

