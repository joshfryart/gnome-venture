<?php
declare(strict_types=1);
/**
 * Graphical navigation, phases 4 and 5: the Crafting workshop, the Treehouse and the Pal Yard, on the one scene engine (hub_scene).
 * Each is a picture whose hotspots open a popover card; the card shows what the old page shows (badges, counts, who is where) and holds a link
 * (or, where it is safe, the form) into the EXISTING page, so no game rule is copied. The old pages stay as they are, and each picture has a
 * text twin. Flags: gnav_craft (workshop), gnav_tree (treehouse, yard); all need gnav_on, admins can always preview.
 */
require_once __DIR__ . '/hub_scene.php';
require_once __DIR__ . '/here_schema.php';   // hub_seen_get / hub_seen_set / hub_seen_clear

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
    $box = null;
    foreach ($L['spots'] ?? [] as $sp) if (($sp['k'] ?? '') === $k && isset($sp['box'])) $box = $sp['box'];   // the hit box comes from the layout
    $hot[] = ['id' => $k, 'x' => $p[0], 'y' => $p[1]] + ($box ? ['box' => $box] : []) + $h;
}

/** v2.5.49: a verb chip (Make, Play, Send...) with the page's own note after it ("Make · 3 ready"), like the verb chips on Here. */
function hubp_chip(string $verb, string $note = ''): string
{
    return $note === '' ? $verb : $verb . ' · ' . $note;
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
        hubp_add($hot, $L, $k, ['label' => $label, 'emoji' => $emo[$k] ?? $icon, 'chip' => hubp_chip('Make', $chip), 'cls' => 'ghost' . ($f['locked'] ? ' locked' : ''), 'href' => url('workshop.php?o=' . $k), 'card' => $body]);
    }
    return hub_scene($akey, $hot, [], ['layout' => $L, 'art' => $art, 'alt' => 'The crafting workshop', 'open' => $open, 'close_href' => url('workshop.php'), 'title' => 'List of crafting areas', 'twin_open' => false, 'nav' => hubp_nav('workshop'), 'navbar' => true]);   // v2.5.49: compass, globe and Fast travel under the picture
}

// ------------------------------------------------------------------ shared chrome: compass + globe cards

/** The Routes and World cards of a picture page (the compass and the globe). They link back to Here, the sibling picture and the World; nothing is rebuilt.
 *  $page = the page name (workshop, treehouse, palyard, residential, door); $q = extra query for the no-script ?o= links (residential and door need their place / villager). */
function hubp_nav(string $page, string $q = ''): array
{
    $sib = ['treehouse' => ['palyard.php', '🌳 Pal Yard'], 'palyard' => ['treehouse.php', '🌳 Treehouse'], 'workshop' => ['inventory.php?tab=craft', '🎒 Crafting list'],
            'residential' => ['town.php', '🏘️ Town square'], 'door' => ['residential.php', '🏠 The street']][$page] ?? ['town.php', '🏘️ Town'];
    $li = fn(string $href, string $label) => '<li class="trow"><a class="btn" href="' . e(url($href)) . '">' . $label . '</a></li>';
    $routes = '<p class="muted">Where to next? One tap travels.</p><ul class="trows">'
        . (gnav_on() ? $li('here.php', '📍 Here') : '') . $li($sib[0], $sib[1]) . $li('town.php', '🏘️ Town') . $li('world.php', '🗺️ World') . '</ul>';
    $world = '<p class="muted">The whole world, region by region.</p><p><a class="btn" href="' . e(url('world.php?tab=map#regionmap')) . '">Open region map</a></p><p><a class="btn alt" href="' . e(url('world.php')) . '">Open the World page</a></p>';
    $base = $page . '.php?' . ($q !== '' ? $q . '&' : '');
    return ['routes' => ['href' => url($base . 'o=routes'), 'title' => 'Routes', 'card' => $routes], 'world' => ['href' => url($base . 'o=world'), 'title' => 'World map', 'card' => $world],
            'extra' => [['id' => 'ft', 'label' => 'Fast travel', 'icon' => 'ico-boot.png', 'href' => url('world.php?tab=travel#fasttravel')]]];   // like the gate pictures: Routes, World and Fast travel as round buttons under the picture
}

// ------------------------------------------------------------------ Treehouse

/** The treehouse rooms: room id => [label, emoji, [game keys]]. Data lives in includes/data/treehouse_rooms.php so adding a game is one line. */
function treehouse_rooms(): array
{
    static $r = null;
    if ($r !== null) return $r;
    $f = __DIR__ . '/data/treehouse_rooms.php';
    return $r = is_file($f) ? (require $f) : [];
}

/** Does this gnome keep the list version of the games page? (remembered per gnome: games.php?view=list / view=tree) */
function treehouse_list_pref(int $uid): bool
{
    return hub_seen_get($uid, 'pref:gameslist') !== null;
}

/** One game as a card line: name, blurb, plays left, best score, Play. A locked game says when it opens. */
function treehouse_game_card(array $u, string $key): string
{
    require_once __DIR__ . '/games.php';
    if (!isset(GAMES[$key])) return '';
    [$name, $icon, $page, $blurb] = GAMES[$key];
    $uid = (int)$u['id'];
    $left = game_plays_left($uid, $key);
    $live = game_state($uid, $key) && $key !== 'letters';
    $best = game_best($uid, $key);
    $lock = $key === 'marrow' && (int)$u['level'] < (int)setting('marrow_min_level') ? 'Opens at level ' . (int)setting('marrow_min_level') : '';
    $badge = $lock !== '' ? $lock : ($live ? '▶ In progress' : ($left > 0 ? $left . ' play' . ($left === 1 ? '' : 's') . ' left' : 'Done today'));
    $extra = $key === 'marrow' && $lock === '' ? ' · 💰 ' . money(marrow_pot()) : '';
    return '<li class="trow tgcard"><b>' . $icon . ' ' . e($name) . '</b> <span class="muted">' . e($badge . ($best > 0 ? ' · best ' . $best : '') . $extra) . '</span>'
        . '<br><small class="muted">' . e($blurb) . '</small>'
        . ($lock === '' ? '<a class="btn small" href="' . e(url($page . '?from=treehouse')) . '">Play</a>' : '') . '</li>';
}

/** The pal's picture for a perch: its own sprite file, else the sticker, else a crop of its picture's piece, else a silhouette. Returns the sprite keys to merge. */
function treehouse_pal_pic(array $p): array
{
    $key = preg_replace('/[^a-z0-9_-]/i', '', (string)$p['key']);
    $f = '/assets/img/pals/' . $key . '.png';
    if ($key !== '' && is_file(APP_ROOT . $f)) return ['src' => url(ltrim($f, '/'))];
    $url = ppal_art_url((string)$p['key']);
    if ($url !== '') return ['src' => $url];
    $pic = $p['pic'] ?? null;
    $piece = (string)($p['pal']['piece'] ?? '');
    if ($pic && preg_match('/^(\d{1,2})-(\d)$/', $piece, $m)) {
        require_once __DIR__ . '/jigsaw.php';
        $file = jigsaw_path($pic);
        $sz = is_file(APP_ROOT . '/' . $file) ? @getimagesize(APP_ROOT . '/' . $file) : false;
        if ($sz && $sz[0] > 0) {
            $cw = intdiv($sz[0], 12); $ch = intdiv($sz[1], 8);
            return ['crop' => [url($file), $sz[0], $sz[1], (int)$m[1] * $cw, (int)$m[2] * $ch, $cw, $ch]];
        }
    }
    return ['sil' => true];
}

/** The popover of one pal: name, rarity, level, times found, Take along / Send home (the Pal Book's own POST), Send on a job. */
function treehouse_pal_card(array $u, array $p, array $found, ?array $job, string $back): string
{
    $away = $p['status'] !== 'home';
    $rar = (string)($p['pal']['rarity'] ?? 'common');
    $h = '<div class="palcard"><dl><dt>Rarity</dt><dd>' . e(ucfirst($rar)) . '</dd><dt>Level</dt><dd>Gardening ' . (int)$p['g'] . ' · Adventuring ' . (int)$p['a'] . '</dd>'
        . '<dt>Found</dt><dd>' . max(1, (int)($found['times'] ?? 1)) . ' time' . ((int)($found['times'] ?? 1) > 1 ? 's' : '') . '</dd>'
        . '<dt>HP</dt><dd>' . (int)$p['hp'] . ' / ' . (int)$p['max'] . '</dd></dl>';
    if ($away) {
        $h .= '<p>🧳 Away on a job' . ($job ? ', back ' . e(pj_ago(max(0, pj_ts((string)$job['ends_at']) - time())) . ' from now (' . puzzle_local((string)$job['ends_at'], 'H:i') . ')') : '') . '.</p>';
    } elseif (ppal_party_on() && ppal_can_party($u)) {
        $h .= '<form method="post" action="' . e(url('puzzlepals.php')) . '">' . csrf_field() . '<input type="hidden" name="pal" value="' . e((string)$p['key']) . '"><input type="hidden" name="back" value="treehouse">'
            . ($p['active'] ? '<button class="btn" name="do" value="off">Send home</button>' : '<button class="btn" name="do" value="on">Take along</button>') . '</form>';
    }
    $h .= '<div class="heretools">';
    if (!$away && pj_open($u)) $h .= '<a class="btn alt" href="' . e(url('palyard.php')) . '">Send on a job</a>';
    elseif (!$away) $h .= '<span class="muted">Pal jobs open at gnome level ' . pj_min_level() . '.</span>';
    return $h . '<a class="btn alt" href="' . e(url('puzzlepals.php')) . '">Pal Book</a></div></div>';
}

/**
 * The treehouse: rooms (hotspots with popovers of game cards), the Puzzle Room, the Cat Fish nook, the Contest hall and trophy shelf, the Pal Book shelf, the Yard door,
 * and the gnome's pals on their perches. One pj_pals + one ppal_found_map call per page. Pal parts are hidden with ppal_open() off or for a guest; games always show.
 */
function treehouse_view(array $u, string $open = ''): string
{
    require_once __DIR__ . '/games.php';
    require_once __DIR__ . '/puzzle_pals.php';
    require_once __DIR__ . '/catfish.php';
    require_once __DIR__ . '/pal_jobs.php';
    [$L, $art, $akey] = hubp_layout('treehouse') ?? [null, '', ''];
    if (!$L) return '<p class="muted">No treehouse picture yet. Use the <a href="' . e(url('games.php?view=list')) . '">games list</a>.</p>';
    $uid = (int)$u['id'];
    $hot = [];
    foreach (treehouse_rooms() as $id => [$label, $emoji, $keys]) {
        $rows = '';
        foreach ($keys as $k) $rows .= treehouse_game_card($u, (string)$k);
        if ($rows === '') continue;
        hubp_add($hot, $L, (string)$id, ['label' => $label, 'emoji' => $emoji, 'chip' => 'Play', 'href' => url('treehouse.php?o=' . $id), 'card' => '<ul class="trows">' . $rows . '</ul>']);
    }
    // Puzzle Room: Jeff's puzzles, behind puzzles_open (closed shutters and the reason when it is not open yet)
    $pzOpen = setting('puzzles_open') === '1' || is_admin();
    hubp_add($hot, $L, 'puzzles', ['label' => 'Puzzle Room', 'emoji' => '🧩', 'chip' => 'Play', 'cls' => $pzOpen ? '' : 'locked', 'href' => url('treehouse.php?o=puzzles'),
        'card' => $pzOpen ? '<p>Jeff’s puzzle games: GIFsaw moving jigsaws, Jigsaw and more. Just for fun, no daily limit.</p><p><a class="btn" href="' . e(url('puzzles.php?from=treehouse')) . '">Go in</a></p>'
                          : '<p class="muted">🔒 The Puzzle Room is still being tidied. It opens soon.</p>']);
    $cfOpen = catfish_open();
    hubp_add($hot, $L, 'catfish', ['label' => 'Cat Fish nook', 'emoji' => '🐱', 'chip' => 'Play', 'cls' => $cfOpen ? '' : 'locked', 'href' => url('treehouse.php?o=catfish'),
        'card' => $cfOpen ? '<p>Adopt a cat and dangle a toy fishing rod. Upgrade it and the cat keeps catching fish, even while you are away.</p><p><a class="btn" href="' . e(url('catfish.php?from=treehouse')) . '">Visit the nook</a></p>'
                          : '<p class="muted">🔒 The Cat Fish nook is shuttered for now. It opens soon.</p>']);
    // Contest hall and trophy shelf: this week's high scores (game_top), the Contests tab, Expert trophies
    $top = '';
    foreach (GAMES as $gk => [$gn, $gi]) {
        $rows = game_top($gk);
        if (!$rows) continue;
        $top .= '<li><b>' . $gi . ' ' . e($gn) . '</b> <small class="muted">· your best ' . game_best($uid, $gk) . '</small><ol class="top">';
        foreach ($rows as $t) $top .= '<li>' . e((string)$t['name']) . ' — ' . (int)$t['best'] . '</li>';
        $top .= '</ol></li>';
    }
    $trophies = 0;
    if (ppal_open() && !is_guest($u)) { try { $trophies = (int)q_val('SELECT COUNT(*) FROM ppal_trophies WHERE user_id = ?', [$uid]); } catch (Throwable $e) {} }
    $topGames = 0;   // games where you hold this week's top score (feeds the 'top' trophy layers)
    if (!is_guest($u)) foreach (array_keys(GAMES) as $gk) {
        try { if ((int)q_val("SELECT s.user_id FROM game_scores s JOIN users x ON x.id = s.user_id WHERE s.game = ? AND s.week = ? AND x.banned = 0 GROUP BY s.user_id ORDER BY MAX(s.score) DESC, MIN(s.id) LIMIT 1", [$gk, job_period_key('weekly')]) === $uid) $topGames++; } catch (Throwable $e) {}
    }
    hubp_add($hot, $L, 'contests', ['label' => 'Contest hall', 'emoji' => '🏆', 'chip' => 'Read', 'href' => url('treehouse.php?o=contests'),
        'card' => '<h4>🏅 This week’s high scores</h4>' . ($top !== '' ? '<ul class="tshelf">' . $top . '</ul>' : '<p class="muted">Nobody has scored yet this week.</p>') . '<p class="help">High scores reset every week.</p>'
            . ($trophies > 0 || $topGames > 0 ? '<h4>🏆 Trophy shelf</h4><p>' . ($trophies > 0 ? $trophies . ' Expert jigsaw trophy' . ($trophies === 1 ? '' : ' trophies') . '.' : '') . ($topGames > 0 ? ' Top score this week in ' . $topGames . ' game' . ($topGames === 1 ? '' : 's') . '.' : '') . '</p>' : '')
            . '<p><a class="btn" href="' . e(url('games.php?tab=contests')) . '">Contests →</a></p>']);
    $sprites = [];
    $more = null;
    $dress = [];
    $hint = '';
    $showPals = ppal_open() && !is_guest($u);
    $pjOn = $showPals && pj_open($u);
    if ($showPals) {   // the Yard door: needs pals (pj_open is the level gate)
        $yardCard = $pjOn ? '<p>Your pals at work: gardens, trips, delves and stations.</p><p><a class="btn" href="' . e(url('palyard.php')) . '">Open the Pal Yard</a></p>'
            : ($showPals ? '<p class="muted">🔒 The Pal Yard opens at gnome level ' . pj_min_level() . '.</p>' : '');
        if ($yardCard !== '') hubp_add($hot, $L, 'yard', ['label' => 'Pal Yard', 'emoji' => '🌳', 'chip' => 'Enter', 'cls' => $pjOn ? '' : 'locked', 'href' => url($pjOn ? 'palyard.php' : 'treehouse.php?o=yard'), 'card' => $yardCard]);
    }
    if ($showPals) {
        $pals = array_values(pj_pals($uid));   // found order, append-only
        $found = ppal_found_map($uid);
        $ord = [];   // a perch is the pal's place in the RAW found order (also counting pals later removed from the data), so removing a pal never moves the others
        try { foreach (q('SELECT pal_uid FROM ppal_found WHERE user_id = ? ORDER BY found_at, id', [$uid])->fetchAll() as $n => $r) $ord[(string)$r['pal_uid']] = $n; } catch (Throwable $e) {}
        $jobs = [];
        foreach (pj_jobs($uid, true) as $j) $jobs[(string)$j['pal_uid']] = $j;
        hubp_add($hot, $L, 'books', ['label' => 'Pal Book', 'emoji' => '📚', 'chip' => 'Read', 'href' => url('puzzlepals.php'), 'card' => '']);
        $perches = $L['pals'] ?? [];
        $party = $L['party'] ?? [];
        $seen = hub_seen_get($uid, 'treehouse');
        $seenTs = $seen ? ts($seen) : 0;
        $pi = 0;
        $overflow = 0;
        foreach ($pals as $i0 => $p) {   // the perch is the pal's index in found order, so a perch never moves; a party pal sits by the door instead
            $idx = $ord[$p['uid']] ?? $i0;
            $fi = $found[$p['key']] ?? [];
            $slot = null;
            if ($p['active'] && isset($party[$pi])) $slot = $party[$pi++];
            elseif (!$p['active'] && isset($perches[$idx])) $slot = $perches[$idx];
            elseif ($p['active'] && isset($perches[$idx])) $slot = $perches[$idx];   // more pals along than door slots
            if (!$slot) { $overflow++; continue; }
            $away = $p['status'] !== 'home';
            $job = $jobs[$p['uid']] ?? null;
            $fat = !empty($fi['found_at']) ? ts((string)$fi['found_at']) : 0;
            $isNew = $fat > 0 && ($seen ? $fat > $seenTs : $fat > time() - 86400);
            $sp = ['id' => 'p' . substr($p['uid'], 0, 8), 'x' => (int)$slot['x'], 'y' => (int)$slot['y'] + 10, 'w' => 36, 'h' => 36, 'name' => (string)$p['name'] . ($away ? ' (away)' : ''),
                   'href' => url('treehouse.php?o=p' . substr($p['uid'], 0, 8)), 'card' => treehouse_pal_card($u, $p, $fi, $job, 'treehouse'), 'new' => $isNew, 'mark' => $p['active'] ? '🎒' : ''];
            $sp['label'] = $p['name'];
            if ($away) $sp += ['away' => 'away ' . ($job ? pj_ago(max(0, pj_ts((string)$job['ends_at']) - time())) : '')];
            else $sp += treehouse_pal_pic($p);
            $sprites[] = $sp;
        }
        if ($overflow > 0) $more = ['label' => '+' . $overflow . ' in the yard', 'href' => url($pjOn ? 'palyard.php' : 'puzzlepals.php')];
        if (!$pals) $hint = '<p class="help hubhint">The treehouse is quiet. Solve jigsaws to find pals; each one moves in.</p>';
        foreach ($L['dress'] ?? [] as $d) {   // milestone dressing at 5 / 10 / 20 / 40 pals: data in the layout, the picture file is optional
            if (count($pals) < (int)($d['at'] ?? 0)) continue;
            $k = preg_replace('/[^a-z0-9_-]/i', '', (string)$d['k']);
            $dress[] = ['k' => $k, 'x' => (int)$d['x'], 'y' => (int)$d['y'], 'w' => (int)$d['w'], 'h' => (int)$d['h'], 'src' => is_file(APP_ROOT . '/assets/img/scenes/tree-dress-' . $k . '.png') ? url('assets/img/scenes/tree-dress-' . $k . '.png') : ''];
        }
        hub_seen_set($uid, 'treehouse');
    }
    foreach (here_layers_present($L, 'trophies', $art, $akey) as $t) {   // trophy shelf in the Contest hall: only layers whose picture exists, from the same data as the card
        $n = ($t['kind'] ?? '') === 'expert' ? $trophies : $topGames;
        if ($n >= max(1, (int)($t['at'] ?? 1))) $dress[] = ['k' => 'trophy-' . $t['k'], 'x' => (int)$t['x'], 'y' => (int)$t['y'], 'w' => (int)$t['w'], 'h' => (int)$t['h'], 'src' => $t['src']];
    }
    $o = ['layout' => $L, 'art' => $art, 'alt' => 'The Great Treehouse', 'open' => $open, 'close_href' => url('treehouse.php'), 'title' => 'List of rooms', 'more' => $more, 'chrome' => true, 'pills' => true, 'dress' => $dress, 'nav' => hubp_nav('treehouse'), 'navbar' => true, 'legfold' => true, 'legtitle' => 'List of rooms', 'legtidy' => true, 'twin' => false];
    return hub_scene($akey, $hot, $sprites, $o) . $hint;
}

// ------------------------------------------------------------------ Pal Yard

/** The yard: one site per kind of pal job, pals at work drawn at their site (a progress bar, a Collect bubble), idle pals standing about. The site popovers hold the real job forms. */
function yard_view(array $u, string $open = ''): string
{
    require_once __DIR__ . '/puzzle_pals.php';
    require_once __DIR__ . '/pal_jobs.php';
    require_once __DIR__ . '/pal_jobs_view.php';
    [$L, $art, $akey] = hubp_layout('yard') ?? [null, '', ''];
    if (!$L) return '<p class="muted">No yard picture yet. Use <a href="' . e(url('paljobs.php')) . '">Pal Jobs</a>.</p>';
    $uid = (int)$u['id'];
    $c = pjv_ctx($u, 'yard');   // settles jobs; everything the real job forms need
    $pals = $c['pals'];
    $jobs = $c['jobs'];
    $kinds = ['garden' => ['🪴', 'Garden plot'], 'trip' => ['🧺', 'Trail head'], 'delve' => ['🕳️', 'Delve mouth'], 'station' => ['🍳', 'Kitchen and craft stations']];
    $hot = [];
    $sprites = [];
    $byKind = [];
    foreach ($jobs as $j) $byKind[(string)$j['kind']][] = $j;
    $caps = '<p class="muted">' . count($jobs) . ' of ' . (int)$c['maxAway'] . ' jobs out · ' . (int)$c['runsLeft'] . ' of ' . pj_runs_per_day() . ' trips and delves left today · pal jobs open at gnome level ' . pj_min_level() . '.</p>';
    foreach ($kinds as $kind => [$emoji, $label]) {
        $js = $byKind[$kind] ?? [];
        $ready = count(array_filter($js, fn($j) => $j['state'] === 'ready'));
        $chip = $js ? count($js) . ' out' . ($ready ? ' · ' . $ready . ' ready' : '') : '';
        hubp_add($hot, $L, $kind, ['label' => $label, 'emoji' => $emoji, 'chip' => hubp_chip('Send', $chip), 'cls' => $ready ? 'goal' : '', 'href' => url('palyard.php?o=' . $kind),
            'card' => '<div class="yardsite">' . $caps . ($js ? '<p>' . count($js) . ' here now. The ledger has the countdowns.</p>' : '') . pjv_post($c, $kind) . '</div>']);
    }
    $hurt = array_filter($pals, fn($p) => $p['status'] === 'home' && $p['hp'] < $p['max']);
    $low = array_filter($hurt, fn($p) => $p['hp'] < (int)ceil($p['max'] * 0.4));
    hubp_add($hot, $L, 'sick', ['label' => 'Sick bay', 'emoji' => '🩹', 'chip' => hubp_chip('Tend', $hurt ? count($hurt) . ' hurt' : ''), 'href' => url('palyard.php?o=sick'),
        'card' => '<div class="yardsite"><p>' . ($hurt ? count($hurt) . ' pal' . (count($hurt) === 1 ? ' is' : 's are') . ' hurt. A Healing Potion fixes them up.' : 'Nobody is hurt.') . '</p>' . pjv_home($c) . '</div>']);
    $anyReady = count(array_filter($jobs, fn($j) => $j['state'] === 'ready'));
    hubp_add($hot, $L, 'board', ['label' => 'Ledger', 'emoji' => '📋', 'chip' => hubp_chip('Read', count($jobs) . ' of ' . (int)$c['maxAway'] . ' out' . ($anyReady ? ' · ' . $anyReady . ' ready' : '')), 'cls' => $anyReady ? 'goal' : '', 'href' => url('palyard.php?o=board'),
        'card' => '<div class="yardsite">' . ($pals ? pjv_ledger($c) : '<p class="muted">Nobody is out. Find pals first.</p>') . '</div>']);
    // pals: at work they stand at their site (with a progress bar, or a Collect bubble); the rest stand on the yard's stand slots (at most 5). More than a site holds: the Ledger lists them.
    $at = [];
    foreach ($jobs as $j) $at[(string)$j['pal_uid']] = $j;
    $offs = [[30, 26], [-30, 26], [0, 40]];
    $used = [];
    $stand = array_slice($L['stand'] ?? [], 0, 5);
    $si = 0;
    $now = time();
    foreach ($pals as $p) {
        $card = '<div class="palcard"><p><b>' . e((string)$p['name']) . '</b> <span class="muted">' . e(ucfirst((string)($p['pal']['rarity'] ?? ''))) . '</span></p><p class="muted">HP ' . (int)$p['hp'] . ' / ' . (int)$p['max'] . ' · Gardening ' . (int)$p['g'] . ' · Adventuring ' . (int)$p['a'] . '</p>';
        $j = $at[$p['uid']] ?? null;
        $sp = ['id' => 'q' . substr($p['uid'], 0, 8), 'w' => 34, 'h' => 34, 'name' => (string)$p['name'], 'href' => url('palyard.php?o=q' . substr($p['uid'], 0, 8))] + treehouse_pal_pic($p);
        if ($j) {
            $site = hubp_spot($L, (string)$j['kind']);
            $n = $used[$j['kind']] = ($used[$j['kind']] ?? -1) + 1;
            if (!$site || $n >= count($offs)) continue;   // the Ledger lists the extras
            $sp['x'] = $site[0] + $offs[$n][0]; $sp['y'] = $site[1] + $offs[$n][1];
            $ready = $j['state'] === 'ready';
            $t0 = pj_ts((string)$j['started_at']); $t1 = pj_ts((string)$j['ends_at']);
            $sp['bar'] = $ready ? 100 : max(2, min(100, (int)round(100 * ($now - $t0) / max(1, $t1 - $t0))));
            if ($ready) { $sp['collect'] = 'Collect'; $card .= '<p>Done: collect it in the Ledger.</p><p><a class="btn" href="' . e(url('palyard.php?o=board')) . '">Open the Ledger</a></p>'; }
            else $card .= '<p>Working here, back in ' . e(pj_ago(max(0, $t1 - $now))) . '.</p><p><a class="btn alt" href="' . e(url('palyard.php?o=board')) . '">Open the Ledger</a></p>';
        } else {
            if (!isset($stand[$si])) continue;
            $sp['x'] = (int)$stand[$si]['x']; $sp['y'] = (int)$stand[$si]['y']; $si++;
            if ($p['hp'] < (int)ceil($p['max'] * 0.4)) { $sp['mark'] = '🩹'; $card .= '<p>🩹 Low on HP. Heal it in the Sick bay.</p><p><a class="btn alt" href="' . e(url('palyard.php?o=sick')) . '">Sick bay</a></p>'; }
            elseif ($p['active']) { $sp['mark'] = '🎒'; $card .= '<p>On your party. To send it on a job, tick “Take it off my party” in the job form.</p>'; }
            else $card .= '<p>At home. Pick a site to send it out.</p>';
        }
        $sp['card'] = $card . '</div>';
        $sprites[] = $sp;
    }
    $hint = !$pals ? '<p class="help hubhint">The yard is empty. Solve jigsaws to find pals, then send them to work here.</p>' : '';
    $o = ['layout' => $L, 'art' => $art, 'alt' => 'The pal yard', 'open' => $open, 'close_href' => url('palyard.php'), 'title' => 'List of job sites', 'chrome' => true, 'pills' => true, 'nav' => hubp_nav('palyard'), 'navbar' => true, 'legfold' => true, 'legtitle' => 'List of job sites', 'legtidy' => true, 'twin' => false];
    return '<div class="pjpage" data-pj-now="' . time() . '">' . hub_scene($akey, $hot, $sprites, $o) . $hint . '</div>';
}
