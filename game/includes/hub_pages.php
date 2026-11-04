<?php
declare(strict_types=1);
/**
 * Graphical navigation, phases 4 and 5: the Crafting workshop, the Treehouse and the Pal Yard, on the one scene engine (hub_scene).
 * Each is a picture whose hotspots open a popover card; the card shows what the old page shows (badges, counts, who is where) and holds a link
 * (or, where it is safe, the form) into the EXISTING page, so no game rule is copied. The old pages stay as they are, and each picture has a
 * text twin. Flags: gnav_craft (workshop), gnav_tree (treehouse, yard); all need gnav_on, admins can always preview.
 */
require_once __DIR__ . '/hub_scene.php';

/** A picture page's layout and art name: [layout, art kind, art key] or null. */
function hubp_layout(string $key): ?array
{
    $L = here_layouts_all()[$key] ?? null;
    if (!$L) return null;
    $art = ['workshop' => ['craft', 'workshop'], 'treehouse' => ['tree', 'house'], 'yard' => ['yard', 'pals']][$key] ?? ['here', $key];
    return [$L, $art[0], $art[1]];
}

/** The spot of a layout by name as [x, y], or null. */
function hubp_spot(array $L, string $k): ?array
{
    foreach ($L['spots'] ?? [] as $s) if (($s['k'] ?? '') === $k) return [(int)$s['x'], (int)$s['y']];
    return null;
}

/** Add a hotspot at a named spot of the layout when the layout has it. */
function hubp_add(array &$hot, array $L, string $k, array $h): void
{
    if (!($p = hubp_spot($L, $k))) return;
    $hot[] = ['id' => $k, 'x' => $p[0], 'y' => $p[1]] + $h;
}

/** A card body: a paragraph, optional extra html, and the open-the-page button. */
function hubp_card(string $text, string $linkHref, string $linkLabel, string $extra = ''): string
{
    return '<p>' . $text . '</p>' . $extra . '<p><a class="btn" href="' . e($linkHref) . '">' . $linkLabel . '</a></p>';
}

// ------------------------------------------------------------------ Crafting workshop

/** The workshop: every crafting section is a hotspot (the sections of CRAFT_CATEGORIES). Returns the scene html. */
function workshop_view(array $u, string $open = ''): string
{
    require_once __DIR__ . '/craft_map.php';
    require_once __DIR__ . '/crafting.php';
    [$L, $art, $akey] = hubp_layout('workshop') ?? [null, '', ''];
    if (!$L) return '<p class="muted">No workshop picture yet. Use the <a href="' . e(url('inventory.php?tab=craft')) . '">crafting list</a>.</p>';
    $facts = craft_map_facts($u);
    $hot = [];
    $emo = ['cooking' => '🍳', 'pantry' => '🫙', 'tools' => '🔨', 'garden' => '🪴', 'potions' => '🧪', 'building' => '🧱', 'decor' => '🏡'];
    foreach (CRAFT_CATEGORIES as $k => [$label, $icon, , $desc]) {
        $f = $facts[$k] ?? ['locked' => false, 'badge' => '', 'have' => 0, 'total' => 0];
        $chip = $f['locked'] ? '🔒 ' . $f['badge'] : (string)$f['badge'];
        $body = '<p class="muted">' . e((string)$desc) . '</p><p>' . (int)$f['have'] . ' of ' . (int)$f['total'] . ' recipes known.' . ($f['locked'] ? ' <b>Locked: ' . e((string)$f['badge']) . '.</b>' : ($f['badge'] !== '' ? ' <b>' . e((string)$f['badge']) . '.</b>' : '')) . '</p>'
            . ($f['locked'] ? '' : '<div class="wsfrag" data-frag="' . e($k) . '" data-url="' . e(url('workshop.php')) . '"><p class="muted">Loading…</p></div>')
            . '<p><a class="btn' . ($f['locked'] ? '' : ' alt') . '" href="' . e(url('inventory.php?tab=craft&c=' . $k)) . '">' . ($f['locked'] ? 'See what unlocks it' : 'Open ' . e($label) . ' as a page') . ' →</a></p>';
        hubp_add($hot, $L, $k, ['label' => $label, 'emoji' => $emo[$k] ?? $icon, 'chip' => $chip, 'cls' => $f['locked'] ? 'locked' : '', 'href' => url('workshop.php?o=' . $k), 'card' => $body]);
    }
    return hub_scene($akey, $hot, [], ['layout' => $L, 'art' => $art, 'alt' => 'The crafting workshop', 'open' => $open, 'close_href' => url('workshop.php'), 'title' => 'List of crafting areas', 'twin_open' => false]);
}

// ------------------------------------------------------------------ Treehouse

/** The treehouse rooms: room id => [label, emoji, [game keys]]. Data lives here so adding a game is one line. */
function treehouse_rooms(): array
{
    static $r = null;
    if ($r !== null) return $r;
    $f = __DIR__ . '/data/treehouse_rooms.php';
    return $r = is_file($f) ? (require $f) : [];
}

/** One game card line: name, badge, play link. */
function treehouse_game_row(array $u, string $key): string
{
    require_once __DIR__ . '/games.php';
    if (!isset(GAMES[$key])) return '';
    [$name, $icon, $page, $blurb] = GAMES[$key];
    $uid = (int)$u['id'];
    $left = game_plays_left($uid, $key);
    $live = game_state($uid, $key) && $key !== 'letters';
    $badge = $live ? '▶ In progress' : ($left > 0 ? $left . ' left' : 'Done today');
    if ($key === 'marrow' && (int)$u['level'] < (int)setting('marrow_min_level')) $badge = 'Level ' . (int)setting('marrow_min_level');
    return '<li class="trow"><a href="' . e(url($page)) . '"><b>' . $icon . ' ' . e($name) . '</b></a> <span class="muted">' . e($badge) . '</span><br><small class="muted">' . e($blurb) . '</small></li>';
}

/** The treehouse: rooms, the Puzzle Room, the Cat Fish nook, the contest hall, the bookshelf, and the gnome's pals on their perches. */
function treehouse_view(array $u, string $open = ''): string
{
    require_once __DIR__ . '/games.php';
    require_once __DIR__ . '/puzzle_pals.php';
    require_once __DIR__ . '/catfish.php';
    [$L, $art, $akey] = hubp_layout('treehouse') ?? [null, '', ''];
    if (!$L) return '<p class="muted">No treehouse picture yet. Use the <a href="' . e(url('games.php')) . '">games list</a>.</p>';
    $uid = (int)$u['id'];
    $hot = [];
    foreach (treehouse_rooms() as $id => [$label, $emoji, $keys]) {
        $rows = '';
        foreach ($keys as $k) $rows .= treehouse_game_row($u, $k);
        if ($rows === '') continue;
        hubp_add($hot, $L, $id, ['label' => $label, 'emoji' => $emoji, 'href' => url('treehouse.php?o=' . $id), 'card' => '<ul class="trows">' . $rows . '</ul>']);
    }
    if (setting('puzzles_open') === '1' || is_admin()) hubp_add($hot, $L, 'puzzles', ['label' => 'Puzzle Room', 'emoji' => '🧩', 'href' => url('puzzles.php'), 'card' => '']);
    if (catfish_open()) hubp_add($hot, $L, 'catfish', ['label' => 'Cat Fish nook', 'emoji' => '🐱', 'href' => url('catfish.php'), 'card' => '']);
    hubp_add($hot, $L, 'contests', ['label' => 'Contest hall', 'emoji' => '🏆', 'href' => url('games.php?tab=contests'), 'card' => '']);
    $sprites = [];
    $more = null;
    require_once __DIR__ . '/pal_jobs.php';
    if (pj_open($u)) hubp_add($hot, $L, 'yard', ['label' => 'Pal Yard', 'emoji' => '🌳', 'href' => url('palyard.php'), 'card' => '']);
    if (ppal_open() && !is_guest($u)) {
        hubp_add($hot, $L, 'books', ['label' => 'Pal Book', 'emoji' => '📚', 'href' => url('puzzlepals.php'), 'card' => '']);
        require_once __DIR__ . '/pal_jobs.php';
        $pals = pj_pals($uid);   // found order
        $perches = $L['pals'] ?? [];
        $i = 0;
        $overflow = 0;
        foreach ($pals as $p) {
            if ($p['active']) continue;   // a pal along sits by the gnome, not on a perch
            if ($i >= count($perches)) { $overflow++; continue; }
            $slot = $perches[$i++];
            $away = $p['status'] !== 'home';
            $url = ppal_art_url((string)$p['key']);
            $card = '<p><b>' . e((string)$p['name']) . '</b></p><p class="muted">' . ($away ? '🧳 Away on a job.' : 'Home. ' . (int)$p['hp'] . '/' . (int)$p['max'] . ' HP.') . '</p>'
                . '<p><a class="btn" href="' . e(url('puzzlepals.php')) . '">Pal Book</a> <a class="btn alt" href="' . e(url('paljobs.php')) . '">Pal jobs</a></p>';
            $sprites[] = ['id' => 'p' . $i, 'x' => (int)$slot['x'], 'y' => (int)$slot['y'] + 10, 'w' => 36, 'h' => 36, 'src' => $url, 'emoji' => '🧩', 'name' => (string)$p['name'] . ($away ? ' (away)' : ''),
                          'href' => url('treehouse.php?o=p' . $i), 'card' => $card, 'mark' => $away ? '🧳' : ''];
        }
        if ($overflow > 0) $more = ['label' => '+' . $overflow . ' in the yard', 'href' => url('palpalyard.php')];
    }
    return hub_scene($akey, $hot, $sprites, ['layout' => $L, 'art' => $art, 'alt' => 'The Great Treehouse', 'open' => $open, 'close_href' => url('treehouse.php'), 'title' => 'List of rooms', 'more' => $more]);
}

// ------------------------------------------------------------------ Pal Yard

/** The yard: one site per kind of pal job, pals at work drawn at their site, idle pals standing about. */
function yard_view(array $u, string $open = ''): string
{
    require_once __DIR__ . '/puzzle_pals.php';
    require_once __DIR__ . '/pal_jobs.php';
    [$L, $art, $akey] = hubp_layout('yard') ?? [null, '', ''];
    if (!$L) return '<p class="muted">No yard picture yet. Use <a href="' . e(url('paljobs.php')) . '">Pal Jobs</a>.</p>';
    $uid = (int)$u['id'];
    pj_settle($uid);
    $pals = pj_pals($uid);
    $jobs = pj_jobs($uid, true);
    $kinds = ['garden' => ['garden', '🪴', 'Garden plot', 'Send a pal to tend a garden.'], 'trip' => ['trip', '🧺', 'Trail head', 'Send a pal gathering.'],
              'delve' => ['delve', '🕳️', 'Delve mouth', 'Re-run a cleared delve.'], 'station' => ['station', '🍳', 'Kitchen and craft stations', 'A pal works a station.']];
    $siteOf = ['garden' => 'garden', 'trip' => 'trip', 'delve' => 'delve', 'station' => 'station'];
    $hot = [];
    $sprites = [];
    $byKind = [];
    foreach ($jobs as $j) $byKind[(string)$j['kind']][] = $j;
    foreach ($kinds as $kind => [$spot, $emoji, $label, $text]) {
        $js = $byKind[$kind] ?? [];
        $ready = count(array_filter($js, fn($j) => $j['state'] === 'ready'));
        $lines = '';
        foreach ($js as $j) $lines .= '<li>' . e((string)($pals[$j['pal_uid']]['name'] ?? 'A pal')) . ': ' . ($j['state'] === 'ready' ? '<b>done, collect it</b>' : 'working, back in ' . e(pj_ago(max(0, pj_ts((string)$j['ends_at']) - time())))) . '</li>';
        $chip = $js ? count($js) . ' out' . ($ready ? ' · ' . $ready . ' ready' : '') : '';
        hubp_add($hot, $L, $spot, ['label' => $label, 'emoji' => $emoji, 'chip' => $chip, 'cls' => $ready ? 'goal' : '', 'href' => url('palyard.php?o=' . $spot),
            'card' => '<p>' . e($text) . '</p>' . ($lines !== '' ? '<ul>' . $lines . '</ul>' : '<p class="muted">Nobody here right now.</p>')
                . '<p><a class="btn" href="' . e(url('paljobs.php#pjt-' . $kind)) . '">' . ($ready ? 'Collect' : 'Send a pal') . ' →</a></p>']);
    }
    $sickN = count(array_filter($pals, fn($p) => $p['status'] === 'home' && $p['hp'] < $p['max']));
    hubp_add($hot, $L, 'sick', ['label' => 'Sick bay', 'emoji' => '🩹', 'chip' => $sickN ? $sickN . ' hurt' : '', 'href' => url('palyard.php?o=sick'),
        'card' => '<p>' . ($sickN ? $sickN . ' pal' . ($sickN === 1 ? ' is' : 's are') . ' hurt. A Healing Potion fixes them up.' : 'Nobody is hurt.') . '</p><p><a class="btn" href="' . e(url('paljobs.php')) . '">Heal on Pal Jobs →</a></p>']);
    $out = count($jobs);
    hubp_add($hot, $L, 'board', ['label' => 'Noticeboard', 'emoji' => '📋', 'chip' => $out . ' of ' . pj_max_away() . ' out', 'href' => url('paljobs.php'), 'card' => '']);
    // pals: at work they stand at their site, the rest stand about the yard (stable slots, found order)
    $stand = $L['stand'] ?? [];
    $si = 0;
    $at = [];
    foreach ($jobs as $j) $at[(string)$j['pal_uid']] = (string)$j['kind'];
    foreach ($pals as $p) {
        if ($p['active']) continue;
        $site = isset($at[$p['uid']]) ? hubp_spot($L, $siteOf[$at[$p['uid']]] ?? '') : null;
        if ($site) { $x = $site[0] + 30; $y = $site[1] + 26; }
        elseif (isset($stand[$si])) { $x = (int)$stand[$si]['x']; $y = (int)$stand[$si]['y']; $si++; }
        else continue;
        $sprites[] = ['id' => 'q' . substr($p['uid'], 0, 6), 'x' => $x, 'y' => $y, 'w' => 34, 'h' => 34, 'src' => ppal_art_url((string)$p['key']), 'emoji' => '🧩', 'name' => (string)$p['name'], 'href' => url('paljobs.php')];
    }
    return hub_scene($akey, $hot, $sprites, ['layout' => $L, 'art' => $art, 'alt' => 'The pal yard', 'open' => $open, 'close_href' => url('palyard.php'), 'title' => 'List of job sites']);
}
