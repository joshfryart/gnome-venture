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

/**
 * Energy to step onto a path from a place. THE one place that works this out: the Here exit chips show it, and for the timer walk it is
 * what start_expedition charges today (route_energy, free with a walking staff, free with fireflies). With gnav_tiles on (tile walks,
 * phase 2d) only the first step costs, gnav_enter_energy, and the same reductions apply.
 */
function route_enter_cost(array $u, array $route): int
{
    if (setting('gnav_tiles') === '1') {
        if (($route['kind'] ?? 'road') === 'road' && calling_perk($u, 'free_walks') > 0) return 0;
        if ((int)($u['ev_quickwalk'] ?? 0) > 0 || staff_free((int)$u['id'])) return 0;
        return max(0, (int)setting('gnav_enter_energy'));
    }
    $c = route_energy($u, $route);
    if ($c > 0 && ((int)($u['ev_quickwalk'] ?? 0) > 0 || staff_free((int)$u['id']))) return 0;
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
    $uid = (int)$u['id'];
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
    $goalRoute = 0;
    if ($ds = dest_status($u)) {
        $plan = dest_plan($u, (int)$ds[0]['id']);
        $goalRoute = (int)($plan['path'][0]['id'] ?? 0);
    }
    $shift = ts($u['community_shift_until'] ?? null) > time();
    $lvl = (int)$u['level'];
    $out = [];
    foreach ($assign as $rid => $anchor) {
        $r = $byId[$rid];
        $to = $r['to'];
        $pos = here_exit_pos($L, $anchor);
        if (!$pos) continue;
        $name = here_place_name($uid, $to);
        $isRoad = ($r['kind'] ?? 'road') === 'road';
        $cost = route_enter_cost($u, $r);
        [$dMin, $dMax] = route_danger($u, $r);
        $cls = '';
        $card = '';
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
        $out[] = ['id' => 'e' . $rid, 'x' => $pos['x'], 'y' => $pos['y'], 'label' => $label, 'chip' => $chip, 'cls' => $cls, 'emoji' => $isRoad ? '🛣️' : '🌿',
                  'href' => url($back . '?o=e' . $rid), 'card' => $body];
    }
    // routes that did not fit the template's anchors: one link to the World page, which lists every way
    $moreHot = $more ? ['href' => url('world.php'), 'label' => '+' . count($more) . ' more ways (World page)'] : [];
    return [$out, $moreHot];
}

/** Town spots of the node's region, by kind (green, teahouse, board, library). */
function here_town_spots(array $node): array
{
    $out = [];
    foreach (q('SELECT * FROM town_spots WHERE region = ? AND active = 1 ORDER BY id', [(string)$node['region']])->fetchAll() as $s) $out[(string)$s['kind']] ??= $s;
    return $out;
}

/** Things to do at this place: hotspots on the template's named spots. */
function here_spots(array $u, array $node, array $L, string $back, string $kind): array
{
    $uid = (int)$u['id'];
    $want = [];
    foreach ($L['spots'] ?? [] as $s) $want[(string)$s['k']] = $s;
    $hot = [];
    $add = function (string $k, string $label, string $emoji, string $href, string $card = '', string $chip = '', string $cls = '') use (&$hot, $want, $back) {
        if (!isset($want[$k])) return;
        $hot[] = ['id' => 's-' . $k, 'x' => (int)$want[$k]['x'], 'y' => (int)$want[$k]['y'], 'label' => $label, 'emoji' => $emoji, 'chip' => $chip, 'cls' => $cls,
                  'href' => $card !== '' ? url($back . '?o=s-' . $k) : $href, 'card' => $card];
    };
    if ($kind === 'town') {
        $ts = here_town_spots($node);
        foreach (['green' => '🌳', 'teahouse' => '☕', 'board' => '📋', 'library' => '📚'] as $k => $emo) {
            if (isset($ts[$k])) $add($k, (string)$ts[$k]['name'], $emo, url('town.php?' . ($node['kind'] === 'hub' ? 'hub=1&' : '') . 'spot=' . (int)$ts[$k]['id']));
        }
        $add('shops', 'Shops', '🏪', url('town.php?view=shops'));
        // 'homes' (Residential) comes in a later release; the spot stays hidden until residential.php exists
        if (is_file(APP_ROOT . '/residential.php')) $add('homes', 'Homes', '🏠', url('residential.php?loc=' . (int)$node['id']));
    } elseif ($kind === 'village' || $kind === 'stop') {
        $add('do', 'Do here', '🎯', url('town.php'));
        $add('people', 'Villagers', '👥', url('town.php?t=folk'));
        $add('stop', 'Rest stop', '🪧', url('town.php?t=stop'));
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
            $add('shop', 'Haven shop', '🧺', url('world.php'));
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
        if ($h > 96) { $w = (int)round($w * 96 / $h); $h = 96; }   // 96 px tall at most
        return ['src' => url($rel), 'w' => $w, 'h' => $h, 'emoji' => $emoji];
    }
    return ['src' => '', 'w' => 40, 'h' => 56, 'emoji' => $emoji];
}

/** Sprites for the villagers present, placed on the stand slots. Returns [sprites, overflow count]. */
function here_sprites(array $u, array $node, array $L, string $kind): array
{
    $npcs = here_npcs($u, $node, $kind);
    [$pairs, $over] = here_place_npcs($L['stand'] ?? [], $npcs, intdiv(time(), 3600));
    $out = [];
    foreach ($pairs as [$slot, $n]) {
        $sp = here_sprite($n);
        $out[] = ['id' => 'n' . (int)$n['id'], 'x' => (int)$slot['x'], 'y' => (int)$slot['y'], 'name' => (string)$n['name'], 'href' => url('villagers.php?id=' . (int)$n['id']),
                  'mark' => npc_birthday_today($n) ? '🎂' : ''] + $sp;
    }
    return [$out, $over];
}

/** The whole picture block for the page. */
function here_view(array $u, array $node, bool $debug = false, string $open = ''): string
{
    $kind = here_kind($node);
    $found = here_layout_find(here_layouts_all(), $kind, (string)($node['landscape'] ?? ''), (string)($node['slug'] ?? ''));
    $back = 'here.php';
    if (!$found) {   // no template at all: the list is the page
        return '<p class="muted">No picture for this place yet. Use the list below.</p>' . here_text_list($u, $node);
    }
    [$key, $L] = $found;
    [$exits, $more] = here_exits($u, $node, $L, $back);
    $spots = here_spots($u, $node, $L, $back, $kind);
    [$sprites, $over] = here_sprites($u, $node, $L, $kind);
    $opts = ['layout' => $L, 'alt' => 'Where you are: ' . $node['name'], 'open' => $open, 'debug' => $debug, 'close_href' => url($back), 'title' => 'List view'];
    if ($over > 0) $opts['more'] = ['label' => '+' . $over . ' more villagers', 'href' => url('villagers.php')];
    $h = hub_scene($key, array_merge($exits, $spots), $sprites, $opts);
    if ($more) $h .= '<p><a class="btn alt" href="' . e($more['href']) . '">' . e($more['label']) . '</a></p>';
    return $h;
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
function gnav_tools_html(array $u, string $back): string
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
            . '<form method="post" action="' . e(url('adventure.php')) . '" class="routeopts">' . csrf_field() . '<input type="hidden" name="do" value="dest_opts"><input type="hidden" name="back" value="' . e($back) . '">'
            . dest_opts_html($u) . ' <button class="btn small">Save</button></form>';
    }
    $gps .= '<p><a class="btn alt" href="' . e(url('world.php?tab=gather')) . '">🎯 Seek something</a> <a class="btn alt" href="' . e(url('world.php?tab=map#regionmap')) . '">🗺️ Pick a place on the map</a></p>';
    $card = function (string $id, string $title, string $body) {
        return '<dialog class="picker hubpop" id="hubpop-' . $id . '" aria-labelledby="hubpop-' . $id . '-t"><div class="pickbox"><div class="pickhead"><h3 id="hubpop-' . $id . '-t">' . $title . '</h3>'
            . '<button type="button" class="pickx" data-pop-close aria-label="Close">✕</button></div><div class="hubcard">' . $body . '</div></div></dialog>';
    };
    return '<div class="gnavtools heretools">'
        . '<a class="btn" data-pop="hubpop-ft" href="' . e(url('world.php?tab=travel#fasttravel')) . '">🧭 Fast travel</a>'
        . '<a class="btn" data-pop="hubpop-gps" href="' . e(url('world.php#gopanel')) . '">📡 GPS' . ($ds ? ' · ' . e(dest_name($uid, $ds[0])) : '') . '</a></div>'
        . $card('ft', '🧭 Fast travel', '<p class="help">Hop to any region you’ve walked to. Home is free.</p><ul class="regionlist hubreg">' . $rows . '</ul>')
        . $card('gps', '📡 GPS', $gps);
}
