<?php
declare(strict_types=1);
/**
 * Graphical navigation, Phase 2a/2b: the Here page (here.php). A picture of where the gnome stands: every way out is a path in the
 * picture, every villager present is a sprite, every thing to do is a hotspot. Read-only: hotspots are links, and each card holds the
 * POST form of an EXISTING action (adventure.php do=start, landmark.php, ...). No game rule is copied here.
 * Flag: setting gnav_on (admin preview works while it is off). Art is optional: no PNG = drawn backdrop, no sprite file = placeholder/emoji.
 */
require_once __DIR__ . '/hub_scene.php';
require_once __DIR__ . '/adventure.php';
require_once __DIR__ . '/destination.php';
require_once __DIR__ . '/roads.php';
require_once __DIR__ . '/landmarks.php';
require_once __DIR__ . '/rebuild.php';
require_once __DIR__ . '/journey.php';
require_once __DIR__ . '/maps.php';
require_once __DIR__ . '/npc_life.php';
require_once __DIR__ . '/items.php';
require_once __DIR__ . '/place_ui.php';   // go_level_chip
require_once __DIR__ . '/residential.php';   // npcs_homed_at

/**
 * Energy to step onto a path from a place. THE one place that works this out: the Here exit chips show it, and for the timer walk it is
 * what start_expedition charges today (route_energy; free with fireflies). A walking staff frees a walk only by chance (staff_free rolls
 * a die), so a PREVIEW (the default) shows the full price and never rolls; the code that really charges passes $roll = true.
 * With gnav_tiles on (tile walks, phase 2d) only the first step costs, gnav_enter_energy, and the same reductions apply.
 */
function route_enter_cost(array $u, array $route, bool $roll = false): int
{
    $road = ($route['kind'] ?? 'road') === 'road';
    if (setting('gnav_tiles') === '1') {
        if ($road && calling_perk($u, 'free_walks') > 0) return 0;
        if ((int)($u['ev_quickwalk'] ?? 0) > 0 || ($roll && staff_free((int)$u['id']))) return 0;
        return max(0, (int)setting('gnav_enter_energy'));
    }
    $c = route_energy($u, $route);
    if ($c > 0 && ((int)($u['ev_quickwalk'] ?? 0) > 0 || ($roll && staff_free((int)$u['id'])))) return 0;
    return $c;
}

/** Which picture template family a place uses: town, village, stop, haven, wonder, delve, lair or '' (generic). */
function here_kind(array $node): string
{
    $k = loc_real_kind($node);
    if (in_array($k, ['market', 'hub'], true)) return 'town';
    if ($k === 'village') return on_road((int)$node['id']) ? 'stop' : 'village';
    return in_array($k, ['haven', 'wonder', 'delve', 'lair'], true) ? $k : '';
}

/** A short name for a place the way this gnome knows it. */
function here_place_name(int $uid, array $loc): string
{
    return dest_name($uid, $loc);
}

/** The compass bearing of a place from another, from the world map positions; a stable guess when a position is missing. */
function here_route_bearing(int $fromId, int $toId): float
{
    $pos = map_positions();
    if (isset($pos[$fromId], $pos[$toId]) && ($pos[$fromId][0] !== $pos[$toId][0] || $pos[$fromId][1] !== $pos[$toId][1])) {
        return here_bearing(['x' => $pos[$fromId][0], 'y' => $pos[$fromId][1]], ['x' => $pos[$toId][0], 'y' => $pos[$toId][1]]);
    }
    return (float)(crc32($fromId . '>' . $toId) % 360);
}

/** A small POST form for an existing action. $fields: name => value. */
function here_form(string $action, array $fields, string $label, string $cls = 'btn', bool $disabled = false): string
{
    $h = '<form method="post" action="' . e(url($action)) . '">' . csrf_field();
    foreach ($fields as $k => $v) $h .= '<input type="hidden" name="' . e((string)$k) . '" value="' . e((string)$v) . '">';
    return $h . '<button class="' . e($cls) . '"' . ($disabled ? ' disabled' : '') . '>' . $label . '</button></form>';
}

/**
 * The exits: one hotspot per path out of this place, on the nearest free compass anchor of the template.
 * Same filter as the World page (visible_routes: a side path to an unknown place is hidden; no bearing leak).
 * Returns [hotspots, more] (more = routes that did not fit the anchors).
 */
function here_exits(array $u, array $node, array $L, string $back): array
{
    $nid = (int)$node['id'];
    $routes = visible_routes($u, $nid);
    $byId = [];
    $br = [];
    foreach ($routes as $r) {
        $byId[(int)$r['id']] = $r;
        $br[] = ['id' => (int)$r['id'], 'bearing' => here_route_bearing($nid, (int)$r['to']['id'])];
    }
    [$assign, $more] = here_assign_exits(here_layout_anchors($L), $br);
    // the route being followed (GPS): its first leg gets the ring
    $goalRoute = here_goal_route($u);
    $out = [];
    foreach ($assign as $rid => $anchor) {
        $pos = here_exit_pos($L, $anchor);
        if (!$pos) continue;
        $i = here_route_info($u, $byId[$rid], $goalRoute, $back);
        $out[] = ['id' => 'e' . $rid, 'x' => $pos['x'], 'y' => $pos['y'], 'label' => $i['label'], 'chip' => $i['chip'], 'cls' => $i['cls'], 'emoji' => $i['emoji'],
                  'href' => url($back . '?o=e' . $rid), 'card' => $i['card']];
    }
    // routes that did not fit the template's anchors: one link to the World page, which lists every way
    $moreHot = $more ? ['href' => url('world.php'), 'label' => '+' . count($more) . ' more ways (World page)'] : [];
    return [$out, $moreHot];
}

/**
 * Everything the picture shows for ONE route out of a place: the destination's name, the label, the cost chip, the lock / ruin / shift state and
 * the card body with the "Set off" form. Used by the exit hotspots (here_exits) and by the compass Routes list (here_routes_card).
 * Returns ['name','label','chip','cls','emoji','card','goal','road','cost','steps'].
 */
function here_route_info(array $u, array $r, int $goalRoute, string $back): array
{
    $uid = (int)$u['id'];
    $rid = (int)$r['id'];
    $to = $r['to'];
    $name = here_place_name($uid, $to);
    $isRoad = ($r['kind'] ?? 'road') === 'road';
    $cost = route_enter_cost($u, $r);
    [$dMin, $dMax] = route_danger($u, $r);
    $shift = ts($u['community_shift_until'] ?? null) > time();
    $lvl = (int)$u['level'];
    $cls = '';
    $goal = $rid === $goalRoute;
    $label = ($goal ? 'Continue to ' : ($isRoad ? 'To ' : 'Side path: ')) . $name;
    $chip = '⚡' . $cost . ' · ' . (int)$r['steps'] . ' steps · Lv ' . $dMin . ($dMax > $dMin ? '-' . $dMax : '');
    $lock = ($to['slug'] ?? '') !== '' ? journey_lock($uid, 'place', (string)$to['slug']) : null;
    $lm = in_array($to['kind'], ['wonder', 'lair', 'haven', 'delve'], true) ? landmark_at((int)$to['id']) : null;
    $ruin = $lm && landmark_in_ruins($lm, $uid);
    $body = '<p><b>' . e($name) . '</b> · ' . ($isRoad ? '🛣️ Trail' : '🌿 side path') . '</p><p class="muted">' . e($chip) . ' ' . go_level_chip($lvl, $dMin, $dMax) . '</p>';
    if ($lock) {
        $cls = 'locked';
        $body .= journey_lock_note($lock, $name);
    } elseif ($ruin) {
        $cls = 'ruin';
        $body .= '<p class="box notice">🏚️ ' . e($name) . ' is in ruins. Make it safe first.</p><p><a class="btn" href="' . e(url('world.php')) . '">Repair it on the World page</a></p>';
    } elseif ($shift) {
        $body .= '<p class="box notice">🧑‍🌾 You’re on a tending shift at the community garden. Finish it before you set off.</p>';
    } else {
        $cls = $goal ? 'goal' : '';
        if ($goal) $body .= '<p>🧭 This is the next leg of your route.</p>';
        $body .= here_form('adventure.php', ['do' => 'start', 'route_id' => $rid], '▶ Set off' . ($cost ? ' (⚡' . $cost . ')' : ' (free)'));
    }
    return ['rid' => $rid, 'to_id' => (int)$to['id'], 'name' => $name, 'label' => $label, 'chip' => $chip, 'cls' => $cls, 'emoji' => $isRoad ? '🛣️' : '🌿', 'card' => $body, 'goal' => $goal, 'road' => $isRoad, 'cost' => $cost, 'steps' => (int)$r['steps'],
            'locked' => $lock !== null || $ruin || $shift];
}

/** The id of the route the GPS is following (its first leg), or 0. */
function here_goal_route(array $u): int
{
    if ($ds = dest_status($u)) {
        $plan = dest_plan($u, (int)$ds[0]['id']);
        return (int)($plan['path'][0]['id'] ?? 0);
    }
    return 0;
}

/**
 * A small graphical map for the Routes card: the region's own picture, cropped to where you stand and the places the ways out lead to, with the
 * roads between them and a tappable pin per route (hubscene.js opens that route's row; the pin and the row stay in step). Places you have not
 * visited are "?". Returns '' when the region has no layout or none of the destinations has a slot there (then the rows are all there is).
 */
function here_routes_map(array $u, array $node, array $infos): string
{
    require_once __DIR__ . '/region_layout.php';
    require_once __DIR__ . '/scene.php';
    $rid = (int)q_val('SELECT region_id FROM locations WHERE id = ?', [(int)$node['id']]);
    $code = (string)q_val('SELECT code FROM regions WHERE id = ?', [$rid]);
    if ($code === '' || !isset(REGION_MAP[$code])) return '';
    $L = region_layout($code);
    if (!$L || empty($L['slots'][(int)$node['id']])) return '';
    $S = $L['slots'];
    $here = $S[(int)$node['id']];
    $pins = [];
    foreach ($infos as $i) if (isset($S[$i['to_id']])) $pins[] = ['i' => $i, 's' => $S[$i['to_id']]];
    if (!$pins) return '';
    $x0 = $x1 = (float)$here['x']; $y0 = $y1 = (float)$here['y'];
    foreach ($pins as $p) { $x0 = min($x0, (float)$p['s']['x']); $x1 = max($x1, (float)$p['s']['x']); $y0 = min($y0, (float)$p['s']['y']); $y1 = max($y1, (float)$p['s']['y']); }
    $W = (int)$L['w']; $H = (int)$L['h'];
    $w = max(150.0, ($x1 - $x0) + 90); $h = max($w * 9 / 16, ($y1 - $y0) + 70); $w = max($w, $h * 16 / 9);   // 16:9, room for the labels
    $cx = ($x0 + $x1) / 2; $cy = ($y0 + $y1) / 2;
    $vx = max(0.0, min($W - $w, $cx - $w / 2)); $vy = max(0.0, min($H - $h, $cy - $h / 2));
    if ($w > $W) { $w = (float)$W; $vx = 0.0; } if ($h > $H) { $h = (float)$H; $vy = 0.0; }
    $art = scene_path('map', $code);
    $svg = '<svg class="rmap" viewBox="' . round($vx) . ' ' . round($vy) . ' ' . round($w) . ' ' . round($h) . '" role="group" aria-label="Map of the ways out of ' . e((string)$node['name']) . '">';
    $svg .= $art !== '' ? '<image class="mapart" href="' . e(url($art)) . '" x="0" y="0" width="' . $W . '" height="' . $H . '" preserveAspectRatio="none" image-rendering="pixelated"/>' : '<rect x="0" y="0" width="' . $W . '" height="' . $H . '" fill="#cfe6e0"/>';
    foreach ($L['roads'] as $rd) {   // the roads in view
        $list = $rd['nodes'];
        for ($k = 1; $k < count($list); $k++) {
            $a = $S[$list[$k - 1]] ?? null; $b = $S[$list[$k]] ?? null;
            if (!$a || !$b) continue;
            $d = 'M' . (int)$a['x'] . ' ' . (int)$a['y'] . ' L' . (int)$b['x'] . ' ' . (int)$b['y'];
            $svg .= '<path d="' . $d . '" stroke="#2a1a10" stroke-width="7" stroke-linecap="round" fill="none"/><path d="' . $d . '" stroke="#f3e6cf" stroke-width="3" stroke-dasharray="6 5" stroke-linecap="round" fill="none"/>';
        }
    }
    $r = max(8.0, $w / 17);   // a pin is about 38 px wide on a phone
    $pin = function (float $x, float $y, string $inner, string $cls, string $name) use ($r): string {
        return '<circle class="rp ' . $cls . '" cx="' . round($x) . '" cy="' . round($y) . '" r="' . round($r) . '"/><text class="rg" x="' . round($x) . '" y="' . round($y + $r * 0.38) . '" text-anchor="middle" font-size="' . round($r * 1.15) . '">' . $inner . '</text>'
            . ($name !== '' ? '<text class="rn" x="' . round($x) . '" y="' . round($y + $r * 1.9) . '" text-anchor="middle" font-size="' . round($r * 0.75) . '">' . e($name) . '</text>' : '');
    };
    foreach ($pins as $k => $p) {
        $unk = $p['i']['name'] === '???' || $p['i']['name'] === '';
        $svg .= '<a class="rmpin' . ($k === 0 ? ' sel' : '') . '" href="' . e(url('here.php?o=routes#hroute-' . (int)$p['i']['rid'])) . '" data-route="' . (int)$p['i']['rid'] . '" aria-label="' . e($unk ? 'An unvisited place' : $p['i']['name']) . '">'
            . $pin((float)$p['s']['x'], (float)$p['s']['y'], $unk ? '?' : e($p['i']['emoji'] ?? '📍'), $unk ? 'q' : '', $unk ? '' : $p['i']['name']) . '</a>';
    }
    $svg .= '<g class="rmyou">' . $pin((float)$here['x'], (float)$here['y'], '🎩', 'you', 'You are here') . '</g></svg>';
    return '<div class="rmapbox">' . $svg . '</div>';
}

/**
 * The compass card of a picture with no exits drawn on it (gate view): EVERY route out of this place, nearest first (the GPS leg on top), each
 * named by its destination with its cost, and a one-tap "Set off" form (a locked or ruined destination says why instead). Same data and same
 * forms as the exit hotspots, so the cost and the rules cannot differ between the two.
 */
function here_routes_card(array $u, array $node, string $back): string
{
    $nid = (int)$node['id'];
    $routes = visible_routes($u, $nid);
    if (!$routes) return '<p class="muted">No ways out of here yet.</p>';
    $goalRoute = here_goal_route($u);
    $rows = [];
    foreach ($routes as $r) {
        $i = here_route_info($u, $r, $goalRoute, $back);
        $rows[] = [$i['goal'] ? 0 : 1, (int)$r['steps'], $i];
    }
    usort($rows, fn($a, $b) => [$a[0], $a[1]] <=> [$b[0], $b[1]]);
    $h = here_routes_map($u, $node, array_map(fn($r) => $r[2], $rows)) . '<p class="muted">Tap a place on the map, or a row. One tap travels.</p><ul class="trows">';
    $first = true;
    foreach ($rows as [, , $i]) {
        $h .= '<li class="trow"><details id="hroute-' . (int)$i['rid'] . '" class="hroute' . ($i['cls'] !== '' ? ' ' . e($i['cls']) : '') . '"' . ($first ? ' open' : '') . '><summary><b>' . e($i['name']) . '</b> <span class="muted">' . e($i['chip']) . '</span></summary>' . $i['card'] . '</details></li>';
        $first = false;
    }
    return $h . '</ul>';
}

/** Town spots of the node's region, by kind (green, teahouse, board, library). */
function here_town_spots(array $node): array
{
    $out = [];
    $n = 0;
    foreach (q('SELECT * FROM town_spots WHERE region = ? AND active = 1 ORDER BY id', [(string)$node['region']])->fetchAll() as $s) {
        $out[(string)$s['kind']] ??= $s;
        if ((string)$s['kind'] === 'special') $out['special' . (++$n)] = $s;   // the region's own places, in order: layout spots 'special1', 'special2' (an 'as' of those)
    }
    return $out;
}

/** v2.5.28: a shop as a compact row (art, name, who is at the counter); the whole row links to the shop. */
function here_shop_row(array $s, array $u): string
{
    require_once __DIR__ . '/place_ui.php';
    $staff = staff_on_duty((int)$s['id']);
    $reach = shop_reachable($u, $s);
    $in = '<span class="shart">' . felt_art_img(town_shop_art((string)($s['shop_type'] ?? ''))) . '</span><b>' . e((string)$s['name']) . '</b><i>' . ($staff ? 'open' : 'closed') . '</i>';
    return $reach ? '<a class="shrow" href="' . e(url('shop.php?id=' . (int)$s['id'])) . '">' . $in . '</a>'
        : '<a class="shrow" href="' . e(url('world.php?go=' . (int)$s['loc_id'] . '#gopanel')) . '">' . $in . '</a>';
}

/** One shop's own popover: the shop itself (counter, Buy / Sell, volunteer) loads in place; assets/hubscene.js reads the page's main and posts its forms in place. */
function here_shop_card(array $s, array $u): string
{
    require_once __DIR__ . '/place_ui.php';
    $href = shop_reachable($u, $s) ? url('shop.php?id=' . (int)$s['id']) : url('world.php?go=' . (int)$s['loc_id'] . '#gopanel');
    return '<div class="vlazy shpage" data-page="' . e(url('shop.php?id=' . (int)$s['id'])) . '" data-csrf="' . e(csrf_token()) . '"><p class="muted">Loading…</p></div>'
        . '<p class="vmore"><a href="' . e($href) . '">Open full page ›</a></p>';
}

/** The shop fronts of a town picture: each front is one of the town's shops by name, the last is the Mossbottom stall (the hub shops, open from anywhere).
 *  More shops than fronts: the last town front lists the rest. One front: everything in one list. Returns [[label, emoji, card html], ...] by front. */
function here_shop_fronts(array $u, array $node, int $fronts): array
{
    if ($fronts < 1) return [];
    require_once __DIR__ . '/world.php';
    $list = fn(string $region): array => q('SELECT s.*, l.name AS loc_name, l.id AS loc_id FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.region = ? AND s.open = 1 ORDER BY s.name', [$region])->fetchAll();
    $isHub = (string)$node['region'] === HUB_REGION;
    $town = $list((string)$node['region']);
    $hub = $isHub ? [] : $list(HUB_REGION);
    $rows = fn(array $l) => '<div class="vlazy shpage" data-list="1" data-csrf="' . e(csrf_token()) . '"><div class="shrows">' . implode('', array_map(fn($s) => here_shop_row($s, $u), $l)) . '</div></div>';
    $hubCard = fn() => '<p class="muted">Open from anywhere</p>' . $rows($hub);
    if (!$hub && !$town) return array_fill(0, $fronts, ['Shops', '🏪', '<p class="muted">No shops here yet.</p>']);
    $out = [];
    if ($fronts === 1) return [['Shops', '🏪', $rows(array_merge($town, $hub))]];
    $slots = $hub ? $fronts - 1 : $fronts;   // fronts for the town's own shops
    foreach ($town as $i => $s) {
        if ($i >= $slots) break;
        if ($i === $slots - 1 && count($town) > $slots) { $rest = array_slice($town, $i); $out[$i] = ['More shops', '🏪', $rows($rest)]; break; }
        $out[$i] = [(string)$s['name'], '🏪', here_shop_card($s, $u)];
    }
    if ($hub) $out[$fronts - 1] = ['Mossbottom Shops', '🍄', $hubCard()];
    return $out;
}

/** v2.5.40: the Homes popover: who lives here, a face each (a villager standing in the line opens their card, else their page), and the way to the street of doors. */
function here_homes_card(array $homed, int $locId): string
{
    require_once __DIR__ . '/spot_card.php';
    $h = '<p>' . count($homed) . ' ' . (count($homed) === 1 ? 'home' : 'homes') . ' here. Tap a neighbour.</p><div class="sfaces" aria-label="Who lives here">' . implode('', array_map('spot_face', $homed)) . '</div>';
    return $h . '<p class="vmore"><a href="' . e(url('residential.php?loc=' . $locId)) . '">Walk the street of doors ›</a></p>';
}

/** v2.5.35: the "Do here" fronts of a rest stop, each named for one thing to do there (Fish the pond, Light the lamps...). The stop's own pool picks them: what the
 *  weather, season or hour allows right now comes first (so they change with events), then the day's core and rotating picks. One popover per activity,
 *  its own buttons post to town.php (do=local) and come back to this picture. Returns [[label, emoji, card html], ...] by front; fewer acts than fronts leaves the rest out. */
function here_do_fronts(array $u, array $node, string $back, int $fronts, bool $skipStall = false): array
{
    if ($fronts < 1 || (string)$node['kind'] !== 'village') return $fronts > 0 ? array_fill(0, $fronts, ['Do here', '🎯', '<p><a class="btn" href="' . e(url('town.php')) . '">Open this place ›</a></p>']) : [];
    require_once __DIR__ . '/local.php';
    $pool = stop_pool($node, null, (int)$u['id']);
    $visit = stop_visit_key($u);
    [$done] = stop_state((int)$u['id'], (int)$node['id'], $visit);
    $out = [];
    $offer = $skipStall ? array_values(array_filter($pool['offer'], fn($a) => !in_array((string)$a['kind'], ['buy', 'snack'], true))) : $pool['offer'];   // v2.5.49: the stalls have their own front (here_stall_fronts)
    foreach (array_slice($offer, 0, $fronts) as $a) {
        $isDone = in_array((string)$a['slug'], $done, true);
        $out[] = [(string)$a['name'], (string)$a['icon'], '<div class="doblock" data-slug="' . e((string)$a['slug']) . '" data-post="' . e(url('town.php')) . '">' . here_do_block($u, $node, $back, $a, $isDone) . '</div>'];
    }
    return $out;
}

/** v2.5.67: the inside of one "Do here" activity card (what it is, and its buttons or "Done"). $msg = the result of the try just made, shown at the top, so a popover that
 *  was posted in place (assets/hubscene.js, town.php card=do) tells the player what happened. */
function here_do_block(array $u, array $node, string $back, array $a, bool $isDone, string $msg = '', bool $ok = true): string
{
    $folk = stop_folk_of($node)[0] ?? null;
    $blurb = stop_say((string)$a['blurb'], $node, $folk);
    $hp = !empty($a['hap']) ? (stop_happenings()[(string)(stop_now($node)['hp'] ?? '')] ?? null) : null;   // v2.5.72: an act that goes with today's happening says so
    return here_result_html($msg, $ok)
        . ($hp ? '<p class="st-hap"><b>' . e($hp['icon'] . ' ' . $hp['name']) . '</b> · ' . e(str_replace('{place}', (string)$node['name'], $hp['headline'])) . '</p>' : '')
        . (!empty($a['now']) ? '<p><b>Right now</b> · ' . e(hollow_weather_info(stop_now($node)['we'], stop_now($node)['dp'])['label']) . '</p>' : '')
        . ($blurb !== '' ? '<p class="st-blurb">' . e($blurb) . '</p>' : '')
        . ($isDone ? '<p class="muted">✔ Done this visit.</p>'
            : '<div class="doacts">' . str_replace('<input type="hidden" name="do" value="local">', '<input type="hidden" name="back" value="' . e($back) . '"><input type="hidden" name="do" value="local">', local_act_buttons($u, $node, $a, false)) . '</div>');
}

/** The result line of an action done in a popover. */
function here_result_html(string $msg, bool $ok): string
{
    return $msg === '' ? '' : '<p class="vmsg ' . ($ok ? 'ok' : 'err') . ' doresult" role="status">' . e($msg) . '</p>';
}

/** The inside of one stall row (its name and Buy button or "Done"), with the result of the try just made on top. */
function here_stall_row_html(array $u, array $node, string $back, array $a, bool $isDone, string $msg = '', bool $ok = true): string
{
    return '<p><b>' . e((string)$a['icon']) . ' ' . e((string)$a['name']) . '</b></p>' . here_result_html($msg, $ok)
        . ($isDone ? '<p class="muted">✔ Done this visit.</p>'
            : '<div class="doacts">' . str_replace('<input type="hidden" name="do" value="local">', '<input type="hidden" name="back" value="' . e($back) . '"><input type="hidden" name="do" value="local">', local_act_buttons($u, $node, $a, false)) . '</div>');
}

/** v2.5.67: answer an in-place post from a Do here / Stall popover (town.php, card=do): the activity's block comes back with the result at the top. Exits. */
function here_do_reply(array $u, string $slug, string $msg, bool $ok, string $back = 'here.php'): void
{
    require_once __DIR__ . '/local.php';
    $u = q_one('SELECT * FROM users WHERE id = ?', [(int)$u['id']]) ?: $u;
    $node = player_node($u);
    $a = null;
    if (($node['kind'] ?? '') === 'village') foreach (stop_pool($node, null, (int)$u['id'])['offer'] as $x) if ((string)$x['slug'] === $slug) { $a = $x; break; }
    header('Content-Type: application/json; charset=utf-8');
    if (!$a) { echo json_encode(['ok' => false, 'msg' => $msg !== '' ? $msg : 'That is not here any more.', 'html' => ''], JSON_UNESCAPED_SLASHES); exit; }
    [$done] = stop_state((int)$u['id'], (int)$node['id'], stop_visit_key($u));
    $isDone = in_array($slug, $done, true);
    $html = in_array((string)$a['kind'], ['buy', 'snack'], true) ? here_stall_row_html($u, $node, $back, $a, $isDone, $msg, $ok) : here_do_block($u, $node, $back, $a, $isDone, $msg, $ok);
    [$hdrE, $hdrMax] = current_energy($u);   // the header pills follow the result (assets/hubscene.js)
    echo json_encode(['ok' => $ok, 'msg' => $msg, 'html' => $html, 'hdr' => ['energy' => (int)$hdrE, 'max' => (int)$hdrMax, 'title' => energy_line($u), 'next' => energy_next_text($u), 'coins' => (int)$u['coins'], 'coins_label' => money((int)$u['coins']), 'coins_text' => number_format((int)$u['coins'])]], JSON_UNESCAPED_SLASHES);
    exit;
}

/** v2.5.49: the stall fronts of a rest stop (a layout spot that behaves as 'shops'; the market stop pictures' stall). The stop's own stalls are its buy / snack activities
 *  (the "For sale" shelf of the stop page); each is one named row with its Buy button, which posts to town.php (do=local) and comes back to this picture. A stop with no
 *  stall today returns []: here_spots then gives those spots back to "Do here". Returns [[label, emoji, card html], ...] by front. */
function here_stall_fronts(array $u, array $node, string $back, int $fronts): array
{
    if ($fronts < 1 || (string)$node['kind'] !== 'village') return [];
    require_once __DIR__ . '/local.php';
    $stalls = array_values(array_filter(stop_pool($node, null, (int)$u['id'])['offer'], fn($a) => in_array((string)$a['kind'], ['buy', 'snack'], true)));
    if (!$stalls) return [];
    [$done] = stop_state((int)$u['id'], (int)$node['id'], stop_visit_key($u));
    $row = function (array $a) use ($u, $node, $back, $done): string {
        return '<div class="stallrow" data-slug="' . e((string)$a['slug']) . '" data-post="' . e(url('town.php')) . '">' . here_stall_row_html($u, $node, $back, $a, in_array((string)$a['slug'], $done, true)) . '</div>';
    };
    if ($fronts === 1 || count($stalls) === 1) return [['Stall', '🛒', implode('', array_map($row, $stalls))]];
    $out = [];
    foreach ($stalls as $i => $a) {
        if ($i >= $fronts) break;
        $out[$i] = $i === $fronts - 1 && count($stalls) > $fronts ? ['More stalls', '🛒', implode('', array_map($row, array_slice($stalls, $i)))] : [(string)$a['name'], (string)$a['icon'], $row($a)];
    }
    return $out;
}

/** v2.5.49: a haven's Haven shop popover: today's pantry (three or four things, one of each a day), each with its Buy button; landmark.php (do=buy) comes back to this picture. */
function here_haven_shop_card(array $u, array $lm, string $back): string
{
    require_once __DIR__ . '/landmarks.php';
    $uid = (int)$u['id'];
    $rows = '';
    foreach (haven_pantry($lm, $uid) as [$it, $price]) {
        $done = landmark_done_today($uid, (int)$lm['id'], 'buy' . (int)$it['id']);
        $rows .= '<li class="stallrow"><b>' . e((string)$it['name']) . '</b> <span class="muted">' . money($price) . '</span> '
            . ($done ? '<span class="muted">✔ bought today</span>' : here_form('landmark.php', ['do' => 'buy', 'lm' => (int)$lm['id'], 'item_id' => (int)$it['id'], 'back' => $back], 'Buy · ' . money($price), 'btn small')) . '</li>';
    }
    return '<p class="muted">🧺 Today’s pantry. One of each a day; it changes tomorrow.</p>' . ($rows !== '' ? '<ul class="stallrows">' . $rows . '</ul>' : '<p class="muted">The shelves are bare today.</p>');
}

/** v2.5.40: the verb chip for each spot behaviour, shown next to its name in the list of places. */
const HERE_VERBS = ['shops' => 'Shop', 'green' => 'Visit', 'tea' => 'Eat', 'teahouse' => 'Eat', 'board' => 'Read', 'library' => 'Read', 'special1' => 'Visit', 'special2' => 'Visit',
    'do' => 'Do', 'people' => 'Talk', 'stop' => 'Rest', 'homes' => 'Visit', 'garden' => 'Tend', 'fire' => 'Rest', 'shop' => 'Shop', 'investigate' => 'Explore', 'mouth' => 'Enter', 'wild' => 'Explore'];

/** Things to do at this place: hotspots on the template's named spots. */
function here_spots(array $u, array $node, array $L, string $back, string $kind): array
{
    $uid = (int)$u['id'];
    $want = [];   // behaviour key => the layout spots that do it. A spot's 'k' is its own id; an optional 'as' says which behaviour it has (several fronts may share one)
    foreach ($L['spots'] ?? [] as $s) $want[(string)($s['as'] ?? $s['k'])][] = $s;
    $stall = [];
    if (in_array($kind, ['village', 'stop', ''], true) && !empty($want['shops'])) {   // v2.5.49: a stop's stall is its Shops front; with no stall today its spots go back to "Do here" (in layout order)
        $stall = here_stall_fronts($u, $node, $back, count($want['shops']));
        if (!$stall) {
            $want['do'] = [];
            foreach ($L['spots'] ?? [] as $s) if (in_array((string)($s['as'] ?? $s['k']), ['do', 'shops'], true)) $want['do'][] = $s;
            unset($want['shops']);
        }
    }
    $hot = [];
    $add = function (string $k, string|array $label, string $emoji, string $href, string $card = '', string $chip = '', string $cls = '') use (&$hot, $want, $back) {
        foreach ($want[$k] ?? [] as $n => $sp) {
            if (is_array($label)) {   // v2.5.28: one entry per front, [label, emoji, card] (the town's shops); a front with no entry is left out
                if (!isset($label[$n])) continue;
                [$lab, $emo, $crd] = $label[$n];
            } else { $lab = $label; $emo = $emoji; $crd = $card; }
            $verb = $chip !== '' ? $chip : (HERE_VERBS[$k] ?? '');   // v2.5.40: the verb chip (Shop, Talk, Rest...) in the list of places
            $id = 's-' . $k . ($n > 0 ? '-' . ($n + 1) : '');   // the id follows the behaviour (stable links), a second front with the same behaviour gets -2, -3
            $h = ['id' => $id, 'x' => (int)$sp['x'], 'y' => (int)$sp['y'], 'label' => $lab, 'emoji' => $emo, 'chip' => $verb, 'cls' => $cls,
                  'href' => $crd !== '' ? url($back . '?o=' . $id) : $href, 'card' => $crd];
            if (isset($sp['box'])) $h['box'] = $sp['box'];
            $hot[] = $h;
        }
    };
    if ($kind === 'town') {
        $ts = here_town_spots($node);
        foreach (['green' => '🌳', 'teahouse' => '☕', 'board' => '📋', 'library' => '📚', 'special1' => '✨', 'special2' => '✨'] as $k => $emo) {
            if (isset($ts[$k])) {
                $hq = ($node['kind'] === 'hub' ? 'hub=1&' : '');
                $add($k, (string)$ts[$k]['name'], $emo, url('town.php?' . $hq . 'spot=' . (int)$ts[$k]['id']), here_lazy_card(url('town.php?' . $hq . 'spot=' . (int)$ts[$k]['id'] . '&frag=1'), url('town.php'), 'Open full page ›', ''));
            }
        }
        $add('shops', here_shop_fronts($u, $node, count($want['shops'] ?? [])), '🏪', url('town.php?view=shops'));
        // 'homes' (Residential) comes in a later release; the spot stays hidden until residential.php exists
        if (is_file(APP_ROOT . '/residential.php') && npcs_homed_at((int)$node['id'])) { $hm = npcs_homed_at((int)$node['id']); $add('homes', 'Homes', '🏠', url('residential.php?loc=' . (int)$node['id']), here_homes_card($hm, (int)$node['id'])); }
    } elseif ($kind === 'village' || $kind === 'stop' || $kind === '') {   // '' = a plain place: the generic picture
        $add('do', here_do_fronts($u, $node, $back, count($want['do'] ?? []), $stall !== []), '🎯', url('town.php'));
        if ($stall) $add('shops', $stall, '🛒', url('town.php'));
        $add('people', 'Villagers', '👥', url('town.php?t=folk'));
        foreach ($hot as &$hp) if (str_starts_with((string)$hp['id'], 's-people')) $hp['hl'] = 'street';   // v2.5.39: tapping it lights up the villagers standing under the picture
        unset($hp);
        $add('stop', 'Rest stop', '🪧', url('town.php?view=passport'), here_lazy_card(url('town.php?view=passport&frag=1'), url('town.php'), '', '') . '<p class="vmore"><a href="' . e(url('town.php?view=passport')) . '">Full passport ›</a></p>');
        if (is_file(APP_ROOT . '/residential.php') && npcs_homed_at((int)$node['id'])) { $hm = npcs_homed_at((int)$node['id']); $add('homes', 'Homes', '🏠', url('residential.php?loc=' . (int)$node['id']), here_homes_card($hm, (int)$node['id'])); }
        if ((int)($u['home_village_id'] ?? 0) === (int)$node['id']) $add('garden', 'Your garden', '🌱', url('garden.php'));
    } elseif (in_array($kind, ['haven', 'wonder', 'delve', 'lair'], true)) {
        $lm = landmark_at((int)$node['id']);
        $lock = journey_lock($uid, 'place', (string)$node['slug']);
        $ruin = $lm && landmark_in_ruins($lm, $uid);
        $lmId = $lm ? (int)$lm['id'] : 0;
        $note = $lock ? journey_lock_note($lock, (string)$node['name']) : ($ruin ? '<p class="box notice">🏚️ In ruins. Make it safe first on the <a href="' . e(url('world.php')) . '">World page</a>.</p>' : '');
        $f = ['lm' => $lmId, 'back' => $back];
        if ($lm && $kind === 'haven') {
            $card = $note ?: ('<p>Rest your feet, or stay the night.</p><div class="heretools">' . here_form('landmark.php', $f + ['do' => 'rest'], '😌 Rest') . here_form('landmark.php', $f + ['do' => 'stay'], '🛏️ Stay') . '</div>');
            $add('fire', (string)$node['name'], '🔥', url('world.php'), $card, '', $lock ? 'locked' : ($ruin ? 'ruin' : ''));
            $add('shop', 'Haven shop', '🧺', url('world.php'), $lock || $ruin ? ($note ?: '') : here_haven_shop_card($u, $lm, $back));   // v2.5.49: the pantry in a popover
        } elseif ($lm && $kind === 'wonder') {
            $card = $note;
            if (!$card) {
                $done = landmark_done_today($uid, $lmId, 'wonder');
                $card = '<p>' . e((string)($lm['description'] ?? '')) . '</p>' . ($done ? '<p class="muted">You explored this wonder today. Come back tomorrow.</p>' : '<p>Pick a way to investigate (once a day):</p><div class="heretools">');
                if (!$done) {
                    foreach (wonder_approaches($lm, $uid) as $stat => [$ico, $lab, $dc]) $card .= here_form('landmark.php', $f + ['do' => 'wonder', 'stat' => $stat], $ico . ' ' . e($lab) . ' <small>(' . (int)$dc . ')</small>');
                    $card .= '</div>';
                }
            }
            $add('investigate', (string)$node['name'], '✨', url('world.php'), $card, '', $lock ? 'locked' : ($ruin ? 'ruin' : ''));
        } elseif ($lm) {   // delve or lair: the mouth
            $card = $note;
            if (!$card) {
                $done = $kind === 'delve' && landmark_done_today($uid, $lmId, 'delve');
                $card = '<p>' . e((string)($lm['description'] ?? '')) . '</p><p class="muted">Level ' . (int)$lm['level'] . ($kind === 'delve' ? ' · −1 energy to go in · once a day' : '') . '</p>'
                    . ($done ? '<p class="muted">You’ve been down there today. The delve needs a day to settle.</p>' : here_form('landmark.php', $f + ['do' => $kind], $kind === 'delve' ? '🕳️ Go in' : '🐉 Face the lair'));
            }
            $add('mouth', (string)$node['name'], $kind === 'delve' ? '🕳️' : '🐉', url('world.php'), $card, '', $lock ? 'locked' : ($ruin ? 'ruin' : ''));
        }
    }
    // a wild trail: wander off the Trail from any place on a road (the existing Wander: adventure.php do=explore)
    if (isset($want['wild']) && on_road((int)$node['id'])) {
        $card = '<p>Leave the Trail and wander the wilds. Each step costs energy; you can come back.</p>' . here_form('adventure.php', ['do' => 'explore'], '🌿 Wander off the Trail');
        $add('wild', 'Wander off the Trail', '🌿', url('world.php'), $card);
    }
    return $hot;
}

/** Villagers standing in this place now. NPCs "at home" are not here (they are behind their door). Travellers on the Green count. */
function here_npcs(array $u, array $node, string $kind): array
{
    $out = [];
    if ($kind === 'town') {
        foreach (here_town_spots($node) as $spot) foreach (npcs_at_spot($spot) as $n) $out[(int)$n['id']] ??= $n;
    } else {
        // everywhere else: villagers whose plans for this hour (out and about, shopping) are in this region, from one query
        $h = hollow_hour();
        $d = hollow_dow();
        foreach (q("SELECT n.*, s.days, s.start_hour, s.end_hour FROM npc_schedules s JOIN npcs n ON n.id = s.npc_id JOIN locations l ON l.id = s.location_id
                    WHERE n.active = 1 AND s.spot_id IS NULL AND s.shop_id IS NULL AND s.activity NOT IN ('working', 'resting') AND l.region = ? AND n.traveller IS NULL", [(string)$node['region']])->fetchAll() as $r) {
            if (in_array($d, schedule_days((string)$r['days']), true) && in_array($h, schedule_hours((int)$r['start_hour'], (int)$r['end_hour']), true)) $out[(int)$r['id']] ??= $r;
        }
    }
    $list = array_values(array_filter($out, fn($n) => (int)($n['active'] ?? 1) === 1 && !empty($n['slug'])));
    usort($list, fn($a, $b) => (int)$a['id'] <=> (int)$b['id']);
    return $list;
}

/** A villager's sprite: new 2.5D art, else the toy mini, else the bust, else a circle and the species emoji. [src, w, h, emoji]. */
function here_sprite(array $npc): array
{
    static $size = [];
    $slug = scene_key((string)$npc['slug']);
    $emoji = npc_icon($npc['species'] ?? null);
    foreach (['assets/img/sprite/npc-' . $slug . '.png', 'assets/img/mini/mini-npc-' . $slug . '.png', 'assets/img/ph/npc-' . $slug . '.png'] as $rel) {
        if ($slug === '' || !is_file(APP_ROOT . '/' . $rel)) continue;
        if (!isset($size[$rel])) { $sz = @getimagesize(APP_ROOT . '/' . $rel); $size[$rel] = $sz ? [$sz[0], $sz[1]] : [64, 80]; }
        [$w, $h] = $size[$rel];
        $frames = ($h > 0 && $w >= 2 * $h * 0.6 && $w % 4 === 0 && abs(($w / 4) / $h - 2 / 3) < 0.1) ? 4 : 1;   // npc sprite sheets: 4 frames of 64 x 96 side by side; draw frame 1
        $fw = intdiv($w, $frames); $fh = $h; $w = $fw;
        if ($h > 96) { $w = (int)round($w * 96 / $h); $h = 96; }   // 96 px tall at most
        return ['src' => url($rel), 'w' => $w, 'h' => $h, 'emoji' => $emoji, 'frames' => $frames, 'fw' => $fw, 'fh' => $fh];
    }
    return ['src' => '', 'w' => 40, 'h' => 56, 'emoji' => $emoji];
}

/** A popover whose body loads in place: GET $get returns JSON {html}; forms inside it (data-vform) post to $post. Without JS the link is the way in. */
function here_lazy_card(string $get, string $post, string $linkLabel, string $linkHref): string
{
    return '<div class="vlazy" data-get="' . e($get) . '" data-url="' . e($post) . '" data-csrf="' . e(csrf_token()) . '"><p class="muted">Loading…</p></div>';
}

/** A villager's popover: an empty shell; assets/hubscene.js loads the villager panel (chat, gift picker, trade) into it when it opens and posts its forms in place. */
function here_npc_card(int $id): string
{
    return here_lazy_card(url('villagers.php?id=' . $id), url('villagers.php'), '', '')
        . '<p class="vmore"><a href="' . e(url('villagers.php?id=' . $id)) . '">Open villager page ›</a></p>';
}

/** Sprites for the villagers present, placed on the stand slots. Returns [sprites, overflow count]. */
function here_sprites(array $u, array $node, array $L, string $kind): array
{
    $npcs = here_npcs($u, $node, $kind);
    if ((string)$node['kind'] === 'village') {   // v2.5.36: a rest stop's own folk (the Folk tab) stand here too, each opens its panel (chat, gift, errand)
        require_once __DIR__ . '/local.php';
        foreach (stop_folk_of($node) as $f) $npcs[] = ['stop_folk' => 1, 'id' => (int)$f['id'], 'slug' => 'stopfolk-' . (int)$f['id'], 'name' => (string)$f['name'], 'species' => (string)$f['species']] ;
    }
    [$pairs, $over] = here_place_npcs($L['stand'] ?? [], $npcs, intdiv(time(), 3600));
    $out = [];
    foreach ($pairs as [$slot, $n]) {
        if (!empty($n['stop_folk'])) {
            $sp = ['src' => '', 'w' => 56, 'h' => 56, 'emoji' => npc_icon($n['species'])];
            if (($art = stop_folk_art($n, 'sprite')) !== '') $sp = ['src' => url($art), 'w' => 64, 'h' => 96, 'fw' => 64, 'fh' => 96, 'frames' => 4, 'emoji' => $sp['emoji']];
            else {   // no v3 art for this species: the old small icon
                $sl = strtolower($n['species']);
                foreach (['mouse', 'bee', 'hedgehog', 'snail', 'frog', 'beetle', 'butterfly', 'cricket', 'ladybird'] as $k) if ($sp['src'] === '' && str_contains($sl, $k) && is_file(APP_ROOT . '/assets/img/ico/ico-' . $k . '.png')) $sp['src'] = url('assets/img/ico/ico-' . $k . '.png');
            }
            $out[] = ['id' => 'f' . (int)$n['id'], 'x' => (int)$slot['x'], 'y' => (int)$slot['y'], 'name' => $n['name'], 'href' => url('town.php?t=folk'), 'mark' => '',
                      'card' => here_lazy_card(url('stopfolk.php?folk=' . (int)$n['id']), url('stopfolk.php'), '', '')] + $sp;
            continue;
        }
        $sp = here_sprite($n);
        $out[] = ['id' => 'n' . (int)$n['id'], 'x' => (int)$slot['x'], 'y' => (int)$slot['y'], 'name' => (string)$n['name'], 'href' => url('villagers.php?id=' . (int)$n['id']),
                  'mark' => npc_birthday_today($n) ? '🎂' : '',
                  'card' => here_npc_card((int)$n['id'])] + $sp;
    }
    return [$out, $over];
}

/** The whole picture block for the page. */
function here_view(array $u, array $node, bool $debug = false, string $open = ''): string
{
    if (($node['kind'] ?? '') === 'village' && !$debug) {   // v2.5.54: standing at a rest stop is a visit: the passport stamp comes with it (the old local page did this)
        require_once __DIR__ . '/stop_pass.php';
        foreach (stop_stamp((int)$u['id'], $node)[1] as $m) flash($m);
    }
    $kind = here_kind($node);
    $found = here_layout_find(here_layouts_all(), $kind, (string)($node['landscape'] ?? ''), (string)($node['slug'] ?? ''), here_layout_ctx($node, $kind));
    $back = 'here.php';
    if (!$found) {   // no template at all: the list is the page
        return '<p class="muted">No picture for this place yet. Use the list below.</p>' . here_text_list($u, $node);
    }
    [$key, $L] = $found;
    $gate = ($L['view'] ?? '') === 'gate';   // a gate-view picture: no exits painted on it; the compass opens the Routes list, the globe the World map
    if ($gate) { $exits = []; $more = []; } else [$exits, $more] = here_exits($u, $node, $L, $back);
    $spots = here_spots($u, $node, $L, $back, $kind);
    [$sprites, $over] = here_sprites($u, $node, $L, $kind);
    if ($gate && ($gurl = (function () use ($u): string { require_once __DIR__ . '/gnome25.php'; return gnome25_url($u); })()) !== '') {   // you stand in the street line too, in your own colours (the 2.5D gnome rig)
        array_unshift($sprites, ['id' => 'you', 'x' => 0, 'y' => 0, 'name' => 'You', 'href' => url('gnome.php'), 'src' => $gurl, 'w' => 64, 'h' => 80, 'fw' => 64, 'fh' => 80, 'frames' => 8, 'emoji' => '🧙']);
    }
    $opts = ['layout' => $L, 'alt' => 'Where you are: ' . $node['name'], 'open' => $open, 'debug' => $debug, 'close_href' => url($back), 'title' => 'List view'];
    if ($gate) {
        $opts['chrome'] = true; $opts['pills'] = true; $opts['navbar'] = true; $opts['street'] = true; $opts['legfold'] = true; $opts['twin'] = false; $GLOBALS['gnav_gate'] = true;
        $opts['nav'] = [
            'routes' => ['href' => url($back . '?o=routes'), 'title' => 'Routes', 'card' => here_routes_card($u, $node, $back)],
            'extra' => [['id' => 'ft', 'label' => 'Fast travel', 'icon' => 'ico-boot.png', 'href' => url('world.php?tab=travel#fasttravel')], ['id' => 'gps', 'label' => 'GPS', 'icon' => 'ico-map-pin.png', 'href' => url('world.php#gopanel')]],
            'world' => ['href' => url($back . '?o=world'), 'title' => 'World map', 'card' => '<p class="muted">The whole world, region by region.</p><p><a class="btn" href="' . e(url('world.php?tab=map#regionmap')) . '">Open region map</a></p><p><a class="btn alt" href="' . e(url('world.php')) . '">Open the World page</a> <a class="btn alt" href="' . e(url('villagers.php')) . '">Villagers</a></p>'],
        ];
    }
    if ($over > 0) $opts['more'] = ['label' => '+' . $over . ' more villagers', 'href' => url('villagers.php')];
    $h = hub_scene($key, array_merge($exits, $spots), $sprites, $opts);
    if ($more) $h .= '<p><a class="btn alt" href="' . e($more['href']) . '">' . e($more['label']) . '</a></p>';
    return $h;
}

/**
 * What the template lookup needs to know about a place besides its kind and landscape: the region code (a main town's picture is per region;
 * the hub is 'hub'), and for a rest stop its type and the regional building style (data/stop_looks.php). Pure reads, never fatal.
 */
function here_layout_ctx(array $node, string $kind): array
{
    $ctx = [];
    try {
        if (($node['kind'] ?? '') === 'hub') $ctx['region'] = 'hub';
        elseif ((int)($node['region_id'] ?? 0) > 0) $ctx['region'] = (string)q_val('SELECT code FROM regions WHERE id = ?', [(int)$node['region_id']]);
        if ($kind === 'stop') {
            require_once __DIR__ . '/stops.php';
            $ctx['type'] = stop_type_of($node);
            $f = __DIR__ . '/data/stop_looks.php';
            $map = is_file($f) ? (require $f) : [];
            $ctx['style'] = (string)($map[(string)($ctx['region'] ?? '')] ?? '');
        }
    } catch (Throwable $e) {}
    return $ctx;
}

/** Plain text twin for a place with no template at all. */
function here_text_list(array $u, array $node): string
{
    $h = '<ul>';
    foreach (visible_routes($u, (int)$node['id']) as $r) $h .= '<li><a href="' . e(url('world.php')) . '">' . e(here_place_name((int)$u['id'], $r['to'])) . '</a></li>';
    return $h . '</ul>';
}

/**
 * The two quick entries on World and on Here: Fast travel and GPS. New buttons for existing rules only: Fast travel posts the
 * same `travel` form as the World page fold (can_fast_travel, seek_travel_cost), GPS shows the remembered goal with the existing
 * "forget route" (adventure.php do=dest_forget) and walking options (do=dest_opts) forms and links to Seek. Without script each
 * button is a link to the old place (World travel fold, route panel).
 */
function gnav_tools_html(array $u, string $back, bool $buttons = true): string
{
    require_once __DIR__ . '/world.php';
    require_once __DIR__ . '/seek.php';
    $uid = (int)$u['id'];
    $here = player_location($u);
    $busy = active_expedition($uid) !== null;
    $rows = '';
    foreach (all_regions() as $r) {
        $isHere = $r['gnomish_name'] === $here;
        $go = $isHere ? '<b>🎩 Here</b>' : (!can_fast_travel($u, (int)$r['id']) ? '<span class="muted">🔒 walk there first</span>'
            : here_form('world.php', ['do' => 'travel', 'region_id' => (int)$r['id']], '🧭 Travel · ' . (($tc = seek_travel_cost($u, (int)$r['id'])) > 0 ? money($tc) : 'free'), 'btn small', $busy));
        $rows .= '<li class="rrow' . ($isHere ? ' here' : '') . '"><a href="' . e(url('world.php?tab=map&r=' . (int)$r['id'] . '#regionmap')) . '"><b>' . e((string)$r['gnomish_name']) . '</b></a> ' . $go . '</li>';
    }
    $ds = dest_status($u);
    $gps = '<p class="help">Tap a place on the map and pick “Head to” to set a goal. The route is remembered and each stop offers the next leg.</p>';
    if ($ds) {
        $gps = '<p>🏁 Heading to <b>' . e(dest_name($uid, $ds[0])) . '</b> · ' . (int)$ds[1] . ' stop' . ($ds[1] === 1 ? '' : 's') . ' left</p>'
            . here_form('adventure.php', ['do' => 'dest_forget', 'back' => $back], '✕ Forget route', 'btn alt')
            . '<p class="routeopts">' . dest_opts_html($u) . '</p>';
    }
    $gps .= '<p><a class="btn alt" href="' . e(url('world.php?tab=gather')) . '">🎯 Seek something</a> <a class="btn alt" href="' . e(url('world.php?tab=map#regionmap')) . '">🗺️ Pick a place on the map</a></p>';
    $card = function (string $id, string $title, string $body) {
        return '<dialog class="picker hubpop" id="hubpop-' . $id . '" aria-labelledby="hubpop-' . $id . '-t"><div class="pickbox"><div class="pickhead"><h3 id="hubpop-' . $id . '-t">' . $title . '</h3>'
            . '<button type="button" class="pickx" data-pop-close aria-label="Close">✕</button></div><div class="hubcard">' . $body . '</div></div></dialog>';
    };
    return ($buttons ? '<div class="gnavtools heretools">'
        . '<a class="btn" data-pop="hubpop-ft" href="' . e(url('world.php?tab=travel#fasttravel')) . '">🧭 Fast travel</a>'
        . '<a class="btn" data-pop="hubpop-gps" href="' . e(url('world.php#gopanel')) . '">📡 GPS' . ($ds ? ' · ' . e(dest_name($uid, $ds[0])) : '') . '</a></div>' : '')
        . $card('ft', '🧭 Fast travel', '<p class="help">Hop to any region you’ve walked to. Home is free.</p><ul class="regionlist hubreg">' . $rows . '</ul>')
        . $card('gps', '📡 GPS', $gps);
}
