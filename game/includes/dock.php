<?php
declare(strict_types=1);
/**
 * Nav dock, phase 1 (plan: claude/plan-nav-dock.md; mockup: nav_dock_mockups.html).
 * The landscape bottom dock that will replace the header, status strip, bottom bar and menu sheet. Everything is additive:
 * with the setting nav_dock = 0 (the default) the game is exactly as before. 'admin' shows it to admins only (preview); '1' shows it to everyone.
 * Phase 1 draws the four menus with their tiles (the same groups, badges and unlock rules as the menu sheet: nav_groups() in layout.php), the status
 * plate with its popover, and two action pieces. Actions are plain links and strips of links; forms and bulk actions come in phase 2.
 * The dock appears in landscape (CSS media query in assets/dock.css), on phones, tablets and desktops; portrait keeps today's chrome. On a wide screen it also folds in the right rail (pots, boosts, tasks) and the message list moves under the top of the page, as on a phone.
 * CSP: no inline styles. All positions are set by assets/dock.js through the style object; the data is a JSON data block, which browsers never run.
 */

/** Admin setting, merged into settings_schema(). */
function dock_settings(): array
{
    return [
        'nav_dock' => ['label' => 'Nav dock: the landscape bottom dock (menus, status plate, two page actions). 0 = off (today’s header, bottom bar and menu), admin = admins only (preview; an admin can add ?dock=off or ?dock=on to the address to switch their own copy), 1 = everyone. Portrait screens always keep today’s chrome.', 'type' => 'text', 'default' => '0'],
    ];
}

/** Is the dock drawn for this viewer? (logged in, past onboarding, and the setting says so) */
function dock_on(?array $u = null): bool
{
    static $memo = null;
    $cu = current_user();
    $u = $u ?? $cu;
    $mine = $cu !== null && $u !== null && (int)$cu['id'] === (int)$u['id'];   // the viewer themselves (the preview switch and the per-request memo apply to them only)
    if ($mine && $memo !== null) return $memo;
    $r = false;
    if ($u && (int)($u['onboarded'] ?? 1) === 1) {
        $s = trim((string)setting('nav_dock'));
        $admin = ($u['role'] ?? '') === 'admin';
        if ($s === '1') $r = true;
        elseif ($s === 'admin' && $admin) $r = true;
        if ($r && $admin && $mine) {   // an admin can switch their own preview off and on: ?dock=off / ?dock=on (a cookie)
            $q = (string)($_GET['dock'] ?? '');
            if (($q === 'off' || $q === 'on') && !headers_sent()) {
                setcookie('gv_dock', $q, ['expires' => time() + 86400 * 60, 'path' => '/', 'samesite' => 'Lax', 'httponly' => true]);
                $_COOKIE['gv_dock'] = $q;
            }
            if (($_COOKIE['gv_dock'] ?? '') === 'off') $r = false;
        }
    }
    if ($mine) $memo = $r;
    return $r;
}

/** A page can set its own two actions (phase 2 pages call this). Shape: ['L' => action|null, 'R' => action|null]; see dock_action(). */
function dock_declare(array $spec): void
{
    $GLOBALS['gv_dock'] = $spec;
}

/**
 * One action piece. $icon is a dock icon name (see dock_icon_url()) or an emoji. A piece is a link ($href), a strip of links ($menu: list of dock_action()s),
 * or inert ($why set = greyed, with that short reason). $badge is a count or '!'.
 */
function dock_action(string $label, string $icon, string $href = '', array $menu = [], string $why = '', string $badge = '', string $mlabel = '', array $remote = [], array $cands = []): array
{
    $icon = DOCK_EMOJI_ICON[$icon] ?? $icon;
    return ['label' => $label, 'icon' => $icon, 'href' => $href, 'menu' => $menu, 'why' => $why, 'badge' => $badge, 'mlabel' => $mlabel, 'remote' => $remote, 'cands' => $cands];
}

/**
 * Phase 2: a piece that works the page's own control. The dock never posts anything itself: it clicks a button the page already has (so the page's CSRF token,
 * confirm dialog and in-place update all apply, and nothing new has to exist on the server). $remote is one of:
 *   ['doForm' => 'water_all', 'count' => ['.gardenstat', 'data-thirsty']]  the first form on the page whose hidden `do` is that value; the count (optional) is a data attribute
 *   ['sel' => 'css selector']                                              any element on the page
 *   ['select' => 'garden']                                                 the garden's "select squares" panel (a Pick strip and a Then strip while it is on)
 *   ['selectInfo' => 'garden']                                             a piece that shows how many squares are picked while that panel is on
 * The script (assets/dock.js) looks the control up each time the dock is drawn: a missing or disabled control greys the piece ("none"). A piece with $cands takes the
 * first of its candidates whose control exists, so one piece can be Give up or Re-roll depending on the page's state.
 */
function dock_remote(string $label, string $icon, array $remote, array $extra = []): array
{
    return dock_action($label, $icon, '', [], '', '', '', $remote) + $extra;
}

/** Dock icon names that have a drawn icon (assets/img/nav/dock-<name>.png, from art-nav-dock/). */
const DOCK_ICONS = ['you', 'hobby', 'out', 'tog', 'hovel', 'almanac', 'satchel', 'crafting', 'tailor', 'start', 'account', 'garden', 'games', 'pals', 'box', 'world', 'here',
    'villagers', 'gourmand', 'treks', 'trading', 'together', 'tasks', 'friends', 'festival',
    'water', 'harvest', 'till', 'select', 'quick', 'rest', 'heal', 'globe', 'explore', 'tag', 'trail', 'sights', 'fight', 'run', 'buy', 'sell', 'save', 'rotate', 'back', 'tend', 'wander', 'dohere', 'sneak', 'hunt', 'creature', 'craft', 'jar', 'sleep', 'nap', 'wave', 'sit', 'snack', 'game', 'bunting', 'basket', 'offer', 'journey', 'handin', 'finish', 'crate', 'messages', 'undo', 'size', 'shape', 'away', 'tools', 'cookagain'];

/** Emoji used as an action icon to the drawn icon that replaces it (assets/img/nav/dock-<name>.png). */
const DOCK_EMOJI_ICON = ['💧' => 'water', '🧺' => 'harvest', '⛏️' => 'till', '☑️' => 'select', '⚡' => 'quick', '＋' => 'quick', '🛏️' => 'rest', '💚' => 'heal', '🌍' => 'globe', '🧭' => 'explore', '🏷️' => 'tag', '🥾' => 'trail', '🔎' => 'sights', '⚔️' => 'fight', '🏃' => 'run', '🛒' => 'buy', '💰' => 'sell', '💾' => 'save', '↻' => 'rotate', '↩' => 'back', '↩️' => 'back', '🌻' => 'tend', '🌿' => 'wander', '🎈' => 'dohere', '🤫' => 'sneak', '🏹' => 'hunt', '🔍' => 'creature', '🍳' => 'craft', '🫙' => 'jar', '🌙' => 'sleep', '💤' => 'nap', '👋' => 'wave', '🪑' => 'sit', '🍎' => 'snack', '✊' => 'game', '🎪' => 'bunting', '🤝' => 'offer', '✋' => 'handin', '🏁' => 'finish', '📦' => 'crate', '💬' => 'messages', '↶' => 'undo', '⚖️' => 'size', '◧' => 'shape', '🪴' => 'tools'];

/** The menu entry slug (NAV_ICONS) to the dock icon name. */
const DOCK_SLUG_ICON = ['almanac' => 'almanac', 'satchel' => 'satchel', 'crafting' => 'crafting', 'hovel' => 'hovel', 'tailor' => 'tailor', 'start' => 'start', 'account' => 'account',
    'garden' => 'garden', 'games' => 'games', 'puzzlepals' => 'pals', 'puzzlebox' => 'box', 'world' => 'world', 'town' => 'here', 'villagers' => 'villagers', 'gourmand' => 'gourmand',
    'treks' => 'treks', 'trading' => 'trading', 'together' => 'together', 'tasks' => 'tasks', 'friends' => 'friends', 'festival' => 'festival', 'today' => 'hovel'];

/** The tile of the menu that lights for this page (same rules as the menu sheet). */
function dock_current_tile(string $page): string
{
    $cur = $page . (isset($_GET['tab']) && $_GET['tab'] === 'craft' ? '?tab=craft' : '');
    if ($page === 'folk.php') $cur = 'villagers.php';
    if (in_array($page, ['catfish.php', 'puzzles.php', 'jigsaw.php', 'gifsaw.php', 'rainbarrel.php', 'gnomebeds.php', 'fair.php', 'show.php', 'gotm.php'], true)) $cur = 'games.php';
    if ($page === 'paljobs.php') $cur = 'puzzlepals.php';
    if ($page === 'adventure.php' && gnav_on()) $cur = 'here.php';   // the walk is the Here page
    return $cur;
}

/**
 * The four menus with their tiles: [['k' => 'you', 'name' => 'You', 'tiles' => [['href', 'label', 'icon', 'badge', 'on', 'why'], ...]], ...], plus which menu is current.
 * On the road (an active expedition) the game refuses World, Treks and the places: those tiles are greyed with "on the road" and Here becomes Trail.
 */
function dock_menus(array $u, string $page): array
{
    [$groups] = nav_groups($u, $page);
    require_once __DIR__ . '/home_slim.php';
    $slim = home_slim_on();
    $road = false;
    try { require_once __DIR__ . '/adventure.php'; $road = active_expedition((int)$u['id']) !== null; } catch (Throwable $e) { $road = false; }
    $cur = dock_current_tile($page);
    $keys = ['You' => 'you', 'Hobbies' => 'hobby', 'Out & about' => 'out', 'Together' => 'tog'];
    $mk = function (string $file, string $label, string $slug, string $badge) use ($cur, $road): array {
        $why = '';
        $icon = DOCK_SLUG_ICON[$slug] ?? '';
        if ($road) {
            if (in_array($file, ['world.php', 'trek.php'], true)) $why = 'on the road';
            if (in_array($file, ['here.php', 'town.php'], true)) { $file = 'adventure.php'; $label = 'Trail'; $icon = 'treks'; }
        }
        $b = $badge === '!' ? '!' : (preg_match('/^(\d+)/', $badge, $m) ? $m[1] : ($badge !== '' ? '•' : ''));
        return ['href' => url($file), 'label' => $label, 'icon' => $icon, 'badge' => $b, 'on' => $cur === $file || ($road && $file === 'adventure.php' && in_array($cur, ['here.php', 'adventure.php'], true)), 'why' => $why];
    };
    $menus = [];
    foreach ($keys as $name => $k) {
        $tiles = [];
        if ($k === 'you') $tiles[] = $mk('gnome.php', $slim ? 'Hovel' : 'Home', $slim ? 'hovel' : 'today', '');   // the one home entry (the menu sheet puts it in its header row)
        foreach (($groups[$name] ?? []) as $t) $tiles[] = $mk((string)$t[0], (string)$t[2], (string)($t[4] ?? ''), (string)($t[3] ?? ''));
        if ($k === 'you') $tiles[] = $mk('account.php', 'Account', 'account', '');   // Account sits last under You (the menu sheet has it under the groups)
        $menus[] = ['k' => $k, 'name' => $name, 'tiles' => $tiles];
    }
    $here = '';
    foreach ($menus as $m) foreach ($m['tiles'] as $t) if (!empty($t['on'])) $here = $m['k'];
    if ($here === '') $here = ['garden' => 'hobby', 'world' => 'out', 'kitchen' => 'you', 'book' => 'you', 'market' => 'tog', 'community' => 'tog'][page_area($page)] ?? '';
    return [$menus, $here];
}

/** The status plate and its popover: numbers and the few links the menu cannot reach (stat points, ready pots and jars, the trip). */
function dock_status(array $u): array
{
    $plate = ['energy' => [0, 1], 'level' => (int)$u['level'], 'xp' => 0, 'time' => '', 'day' => 0, 'coins' => (int)$u['coins']];
    $rows = [];
    $links = [];
    try {
        [$e, $emax] = current_energy($u);
        $plate['energy'] = [(int)$e, (int)$emax];
        $lo = xp_for_level((int)$u['level']);
        $hi = xp_for_level((int)$u['level'] + 1);
        $plate['xp'] = (int)round(100 * max(0, min(1, ((int)$u['xp'] - $lo) / max(1, $hi - $lo))));
        $rows[] = ['⚡', 'Energy', $e . '/' . $emax . ((string)energy_line($u) !== '' ? ' · ' . energy_next_text($u) : '')];
        $rows[] = ['🌱', 'Level ' . (int)$u['level'], number_format((int)$u['xp']) . ' / ' . number_format($hi) . ' XP'];
        if (gclock_on()) {
            $gs = gclock_state($u);
            $plate['time'] = sprintf('%02d:%02d', intdiv($gs['minute'], 60) % 24, $gs['minute'] % 60);
            $plate['day'] = (int)$gs['day'];
            $rows[] = ['🕐', 'Day ' . (int)$gs['day'], $plate['time']];
        }
        require_once __DIR__ . '/health.php';
        if (hp_on()) { [$hp, $hpm] = hp_display($u); $rows[] = ['❤️', 'Health', $hp . '/' . $hpm]; }
        $rows[] = ['🪙', 'Petals', number_format((int)$u['coins'])];
        require_once __DIR__ . '/hollow_clock.php';
        $hn = hollow_now(hollow_user_region($u));
        $links[] = [$hn['season_emoji'] . ' ' . $hn['season_label'] . ' ' . (int)$hn['season_day'] . ' ' . $hn['weather_emoji'], '', url('town.php?view=stop&tab=seasons#seasons')];
        if ((int)$u['stat_points'] > 0) $links[] = ['✨ Stat points', (string)(int)$u['stat_points'], url('gnome.php?tab=stats')];
        require_once __DIR__ . '/crafting.php';
        require_once __DIR__ . '/pantry.php';
        if (cook_pots_on() && ($pots = cook_ready_count((int)$u['id'])) > 0) $links[] = ['🍳 Pots ready', (string)$pots, craft_url('cooking')];
        if (($jars = pantry_ready_count((int)$u['id'])) > 0) $links[] = ['🫙 Jars ready', (string)$jars, craft_url('pantry')];
        require_once __DIR__ . '/destination.php';
        if (function_exists('dest_status') && ($ds = dest_status($u))) {   // the trip strip is gone in dock mode: it is here (walking: the trail; standing still: the route card)
            require_once __DIR__ . '/adventure.php';
            $links[] = ['🏁 Trip: ' . dest_name((int)$u['id'], $ds[0]), (int)$ds[1] . ' stop' . ($ds[1] === 1 ? '' : 's'), url(active_expedition((int)$u['id']) ? 'adventure.php' : 'world.php#gopanel')];
        }
    } catch (Throwable $e) {
        error_log('dock_status: ' . $e->getMessage());   // the plate is never worth a broken page
    }
    return ['plate' => $plate, 'rows' => $rows, 'links' => $links];
}

/** What the right rail showed (ready pots, boosts, tasks), for the popover's second tab: the dock folds the rail in, so wide screens lose nothing. */
function dock_rail(array $u): array
{
    $uid = (int)$u['id'];
    $pots = $boosts = $tasks = [];
    try {
        require_once __DIR__ . '/crafting.php';
        foreach (cook_pots_list($uid) as $p) {
            if (!empty($p['pal'])) $pots[] = [(string)$p['name'], '🧩 ' . $p['pal'] . ' tending', ''];
            elseif ($p['left'] <= 0) $pots[] = [(string)$p['name'], 'Ready, collect', craft_url('cooking')];
            else $pots[] = [(string)$p['name'], effect_time((int)$p['left']), ''];
        }
        foreach (active_effects($u) as $fx) {
            [$ic, $nm, $what] = $fx;
            $boosts[] = [$ic . ' ' . ($nm === 'Meal' ? $what : $nm), effect_left($fx), ''];
        }
        foreach (q("SELECT period, title, qty, progress, stages, stages_paid FROM user_jobs WHERE user_id = ? AND status = 'active' ORDER BY id", [$uid])->fetchAll() as $j) {
            $multi = (int)$j['stages'] > 1;
            $d = $multi ? (int)$j['stages_paid'] : (int)$j['progress'];
            $m = max(1, $multi ? (int)$j['stages'] : (int)$j['qty']);
            $tasks[] = [(string)$j['title'], min($d, $m) . '/' . $m, url('jobs.php')];
        }
    } catch (Throwable $e) {
        error_log('dock_rail: ' . $e->getMessage());
    }
    return ['pots' => $pots, 'boosts' => $boosts, 'tasks' => $tasks];
}

/** The popover's third tab: what the old menu sheet kept at its foot (feedback, rules, privacy, the site's own pages, staff tools) plus Log out. */
function dock_more(array $u, string $page): array
{
    $links = [['💬 Send feedback', url('feedback.php?from=' . urlencode($page))], ['📜 Rules', url('page.php?p=rules')], ['🔒 Privacy', url('page.php?p=privacy')]];
    try {
        foreach (q('SELECT slug, title FROM pages WHERE published = 1 AND show_in_nav = 1 ORDER BY title')->fetchAll() as $p) {
            if (in_array($p['slug'], ['rules', 'privacy'], true)) continue;
            $links[] = ['📄 ' . $p['title'], url('page.php?p=' . urlencode((string)$p['slug']))];
        }
    } catch (Throwable $e) {
        error_log('dock_more: ' . $e->getMessage());
    }
    if (in_array($u['role'] ?? '', ['admin', 'mod'], true)) $links[] = ['🛡️ Moderation', url('modtools.php')];
    if (($u['role'] ?? '') === 'admin') $links[] = ['🛠️ Admin panel', url('admin/index.php')];
    return $links;
}

/** The page's two actions: the page's own (dock_declare / dock_page_spec) or the defaults, Back and Hovel. */
function dock_actions(array $u, string $page): array
{
    $spec = $GLOBALS['gv_dock'] ?? dock_page_spec($page);
    $slim = false;
    try { require_once __DIR__ . '/home_slim.php'; $slim = home_slim_on(); } catch (Throwable $e) {}
    $def = ['L' => dock_action('Back', '↩'), 'R' => dock_action($slim ? 'Hovel' : 'Home', 'hovel', url('gnome.php'))];
    $out = [];
    foreach (['L', 'R'] as $s) $out[$s] = array_key_exists($s, $spec) ? $spec[$s] : $def[$s];   // null = an empty slot
    $out['watch'] = !empty($spec['watch']);   // the script redraws the dock when this page's own buttons change (select mode, disabled buttons)
    return $out;
}

/** The creature in the current fight (for the dock's Creature popover), or null. Read-only. */
function dock_foe(int $uid): ?array
{
    try {
        if (!function_exists('active_expedition')) return null;
        $exp = active_expedition($uid);
        $enc = $exp && !empty($exp['encounter']) ? (is_array($exp['encounter']) ? $exp['encounter'] : json_decode((string)$exp['encounter'], true)) : null;
        if (!is_array($enc) || ($enc['type'] ?? '') !== 'creature') return null;
        $c = encounter_creature($enc);
        if (!$c) return null;
        $hp = isset($enc['hp']) ? (int)$enc['hp'] : (int)$c['hp'];
        $max = isset($enc['max']) ? (int)$enc['max'] : (int)$c['hp'];
        $pf = false; $qs = false;
        try {
            require_once __DIR__ . '/pfight_game.php'; require_once __DIR__ . '/quick_slot.php';
            $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
            $pf = $u ? pfight_on($u) : false;
            $qk = $u ? quick_get($u) : null;
            if ($qk && $u) foreach (fight_snacks($u) as $sn) if ($sn['id'] === (int)$qk['id']) $qs = true;
        } catch (Throwable $e) {}
        return ['pf' => $pf, 'snack' => $qs, 'name' => (string)$c['name'], 'level' => (int)$c['level'], 'hp' => max(0, $hp), 'max' => max(1, $max), 'size' => (string)$c['size'], 'text' => (string)$c['description']];
    } catch (Throwable $e) { return null; }
}

/** Play mode: the mini-games get a thin rail instead of the full dock (the full dock opens from its menu button). Returns the rail's label and back link, or null. */
function dock_play(string $page, ?array $foe = null): ?array
{
    if ($page === 'adventure.php' && $foe && !empty($foe['pf'])) return ['name' => 'Fight', 'back' => '', 'backLabel' => ''];   // a puzzle fight takes the whole screen: the thin rail, not the dock
    $games = ['memory.php' => 'Memory', 'race.php' => 'Race', 'spit.php' => 'Spit', 'mushroom.php' => 'Mushroom', 'pest.php' => 'Pest', 'marrow.php' => 'Marrow', 'worms.php' => 'Worms', 'catfish.php' => 'Catfish'];
    $puz = ['jigsaw.php' => 'Jigsaw', 'gifsaw.php' => 'GIFsaw'];
    if (isset($games[$page])) return ['name' => $games[$page], 'back' => url('games.php'), 'backLabel' => 'Games'];
    if (isset($puz[$page])) return ['name' => $puz[$page], 'back' => url('puzzles.php'), 'backLabel' => 'Puzzles'];
    return null;
}

/** Phase 1 specs for pages whose actions are only links (no new endpoints). Phase 2 adds the pages with forms. */
function dock_page_spec(string $page): array
{
    $u = fn(string $f) => url($f);
    switch ($page) {
        case 'games.php':
        case 'treehouse.php':
            if (($_GET['tab'] ?? '') === 'contests') {
                return ['L' => dock_action('Games', '🎲', $u('games.php')), 'R' => dock_action('Enter', '🏅', '', [
                    dock_action('Show', '🏅', $u('show.php')), dock_action('Garden', '🌼', $u('gotm.php')), dock_action('Fair', '🌽', $u('fair.php')), dock_action('Carve', '🎃', $u('carve.php')),
                ], '', '', 'Contests')];
            }
            return ['L' => dock_action('Contests', '🏆', $u('games.php?tab=contests')), 'R' => dock_action('Play', '🎲', '', [
                dock_action('Memory', '🃏', $u('memory.php')), dock_action('Race', '🐌', $u('race.php')), dock_action('Spit', '🍉', $u('spit.php')),
                dock_action('Mushroom', '🍄', $u('mushroom.php')), dock_action('Pest', '🪰', $u('pest.php')), dock_action('Marrow', '⚖️', $u('marrow.php')), dock_action('Worms', '🪱', $u('worms.php')),
            ], '', '', 'Play a game')];
        case 'puzzles.php':
            return ['L' => dock_action('Games', '↩', $u('games.php')), 'R' => dock_action('Play', '🧩', '', [
                dock_action('Jigsaw', '🧩', $u('jigsaw.php')), dock_action('GIFsaw', '🎞️', $u('gifsaw.php')), dock_action('Pals', '🐾', $u('puzzlepals.php')),
                dock_action('Barrel', '🛢️', $u('rainbarrel.php')), dock_action('Beds', '🛏️', $u('gnomebeds.php')),
            ], '', '', 'Puzzles')];
        case 'show.php':
        case 'fair.php':
        case 'gotm.php':
        case 'carve.php':
            return ['L' => dock_action('Contests', '↩', $u('games.php?tab=contests')), 'R' => dock_action('Games', '🎲', $u('games.php'))];
        case 'feedback.php':
            return ['L' => dock_action('Replies', '📮', $u('community.php?t=msgs')), 'R' => null];
        case 'garden.php':
            $t = (string)($_GET['t'] ?? '');
            if ($t !== '' && $t !== 'beds') return ['L' => dock_action('Beds', '🏡', $u('garden.php')), 'R' => dock_action('Hovel', 'hovel', $u('gnome.php'))];
            // Beds tab: Select works the page's own "select squares" panel; the right piece is a strip of the page's own bulk buttons (the single-bed Tools piece needs a new in-page tool mode: phase 2b)
            return ['watch' => true,
                'L' => dock_remote('Select', '☑️', ['select' => 'garden']),
                'R' => dock_action('Tools', 'tools', '', [
                    dock_remote('Water', '💧', ['tool' => 'water']), dock_remote('Harvest', '🧺', ['tool' => 'harvest']), dock_remote('Till', '⛏️', ['tool' => 'till']),
                    dock_remote('Water all', '💧', ['doForm' => 'water_all', 'count' => ['.gardenstat', 'data-thirsty']]),
                    dock_remote('Weed all', '🌿', ['doForm' => 'weed_all', 'count' => ['.gardenstat', 'data-weedy']]),
                    dock_remote('Harvest all', '🧺', ['doForm' => 'harvest_all', 'count' => ['.gardenstat', 'data-ready']]),
                    dock_remote('Pick pests', '✂️', ['doForm' => 'pick_all']),
                    dock_remote('Collect all', '📥', ['doForm' => 'collect_all']),
                ], '', '', 'Tools and all beds', ['selectInfo' => 'garden'])];
        case 'inventory.php':
            // Satchel, Items tab: the Quick slot (assign: open an item, tap Confirm; use: tap; clear: the x or a hold). Other tabs: left Items, right Hovel.
            $t = (string)($_GET['tab'] ?? '');
            if ($t === 'craft') {   // Crafting is a tab of the Satchel: right works the page's own collect and cook-again forms (the first one present)
                return ['watch' => true, 'L' => dock_action('Items', '🎒', $u('inventory.php')), 'R' => dock_action('Craft', '🍳', '', [
                    dock_remote('Collect all', '🧺', ['doForm' => 'collect_all']), dock_remote('Jars', '🫙', ['doForm' => 'jar_collect_all']), dock_remote('Cook again', '🍳', ['doForm' => 'cook_again'])], '', '', 'Kitchen')];
            }
            if ($t !== '' && $t !== 'items') return ['L' => dock_action('Items', '🎒', $u('inventory.php')), 'R' => dock_action('Hovel', 'hovel', $u('gnome.php'))];
            return ['watch' => true, 'L' => dock_remote('Quick', '⚡', ['quick' => 'slot']), 'R' => dock_action('Arrange', '🗂️', $u('inventory.php?tab=arrange'))];
        case 'gnome.php':
        case 'hovel.php':
            // Left: Heal (a strip of the potions and snacks the page's health box offers). Right: Rest (a strip of the sleeps and naps the bed offers). Both click the page's own buttons.
            $u0 = current_user() ?? ['id' => 0]; $L = dock_action('Back', '↩'); $R = dock_action('Hovel', 'hovel', $u('gnome.php'));
            try {
                require_once __DIR__ . '/game_clock.php';
                $uid = (int)$u0['id'];
                if (gclock_on()) {
                    $rest = [];
                    foreach (gclock_rest_options($u0) as $o) {
                        $nm = preg_replace('/ \(.*$/', '', (string)$o['label']);
                        $rest[] = dock_remote($nm, $o['kind'] === 'nap' ? '💤' : '🌙', ['sel' => 'main button[name="do"][value="' . $o['key'] . '"]']);
                    }
                    if ($rest) $R = dock_action('Rest', '🛏️', '', $rest, '', '', 'Rest');
                }
                if (!function_exists('active_expedition') || !active_expedition($uid)) {
                    require_once __DIR__ . '/adventure.php'; require_once __DIR__ . '/alchemy.php';
                    $heal = [];
                    foreach (alchemy_heals($uid) as $hv) $heal[] = dock_remote((string)$hv['name'], '🧪', ['sel' => 'main form:has(input[name="what"][value="potion"]):has(input[name="item"][value="' . (int)$hv['id'] . '"]) button']);
                    foreach (fight_snacks($u0) as $sn) $heal[] = dock_remote((string)$sn['name'], '🍎', ['sel' => 'main form:has(input[name="what"][value="snack"]):has(input[name="item"][value="' . (int)$sn['id'] . '"]) button']);
                    if ($heal) $L = dock_action('Heal', '💚', '', $heal, '', '', 'Heal');
                }
            } catch (Throwable $e) {}
            return ['watch' => true, 'L' => $L, 'R' => $R];
        case 'adventure.php':
            // On the road: left = the Quick item (use only; set it in the Satchel). Right = the Trail strip (the page's own footer buttons) or, in a fight, Run away.
            $uA = current_user() ?? ['id' => 0];
            $exA = function_exists('active_expedition') ? active_expedition((int)$uA['id']) : null;
            $enc = $exA && !empty($exA['encounter']);
            $wander = $exA && ($exA['kind'] ?? '') === 'explore' && !$enc;
            if ($wander) {   // off the path: the moves, Gather (opens the page's own fold) and the way back to the road
                return ['watch' => true, 'L' => dock_remote('Quick', '＋', ['quick' => 'use']), 'R' => dock_action('Wander', '🌿', '', [
                    dock_remote('Go deeper', '🌿', ['doForm' => 'deeper']), dock_remote('Keep exploring', '🔁', ['doForm' => 'roam']), dock_remote('Step back', '↩️', ['doForm' => 'back']),
                    dock_remote('Gather', '🧺', ['sel' => 'details.wgather > summary']), dock_remote('To the road', '🛣️', ['doForm' => 'return']),
                ], '', '', 'Wander')];
            }
            $R = $enc
                ? dock_action('Fight', '⚔️', '', [dock_remote('Creature', '🔍', ['foe' => 1]), dock_remote('Run away', '🏃', ['sel' => '.pf-runf button, form:has(input[name="do"][value="flee"]) button'])], '', '', 'In a fight')
                : dock_action('Trail', '🥾', '', [
                    dock_remote('Sights', '🔎', ['sel' => '.trailfoot .trailsights']),
                    dock_remote('Gather', '🧺', ['sel' => '.trailfoot [data-pop="hubpop-tgather"]']),
                    dock_remote('Wander', '🌿', ['sel' => '.trailfoot [data-pop="hubpop-twander"]']),
                    dock_remote('Sneak', '🤫', ['sel' => '.trailfoot form:has(input[name="mode"][value="sneak"]) button']),
                    dock_remote('Hunt', '🏹', ['sel' => '.trailfoot form:has(input[name="mode"][value="hunt"]) button']),
                    dock_remote('Turn back', '↩️', ['sel' => '.trailfoot form:has(input[value="trail_back"]) button']),
                ], '', '', 'On the Trail');
            return ['watch' => true, 'L' => dock_remote('Quick', '＋', ['quick' => 'use']), 'R' => $R];
        case 'town.php':
            // Do here: the page's own small actions (wave, sit, snack, rock-paper-scissors, festival, quiz). Greyed when the page does not offer them.
            return ['watch' => true, 'L' => dock_action('Do here', '🎈', '', [
                    dock_remote('Wave', '👋', ['doForm' => 'wave']), dock_remote('Sit', '🪑', ['doForm' => 'bench']), dock_remote('Snack', '🍎', ['doForm' => 'snack']),
                    dock_remote('Game', '✊', ['doForm' => 'rps']), dock_remote('Festival', '🎪', ['doForm' => 'festival']),
                ], '', '', 'Do here'), 'R' => dock_action('World', '🌍', $u('world.php'))];
        case 'here.php':
            // Do here: the doable things on this stop's picture (its "Do" spots, the first three), each opening that spot's own card in place
            return ['watch' => true, 'L' => dock_remote('Do here', '🎈', ['hereDo' => 3], ['mlabel' => 'Do here']), 'R' => dock_remote('Menu', '🧭', ['hereMenu' => 1], ['mlabel' => 'Menu'])];
        case 'world.php':
            return ['watch' => true, 'L' => dock_action('Here', 'here', $u('here.php')), 'R' => dock_action('Explore', '🧭', '', [], '', '', '', [], [dock_remote('Explore', '🧭', ['doForm' => 'explore'])])];
        case 'market.php':
            return ['watch' => true, 'L' => dock_action('Satchel', '🎒', $u('inventory.php')), 'R' => dock_action('List', '🏷️', '', [], '', '', '', [], [dock_remote('List', '🏷️', ['doForm' => 'list']), dock_remote('Offer', '🤝', ['doForm' => 'offer'])])];
        case 'marketday.php':
            return ['watch' => true, 'L' => dock_action('Back', '↩'), 'R' => dock_remote('Basket', '🧺', ['doForm' => 'basket'])];
        case 'community.php':
            $tc = (string)($_GET['t'] ?? '');
            if ($tc === 'garden' || $tc === '') return ['watch' => true, 'L' => dock_remote('Select', '☑️', ['select' => 'tend']), 'R' => dock_action('Tend', '🌻', '', [
                dock_remote('Tend', '🌻', ['doForm' => 'tend']), dock_remote('Take bed', '🛏️', ['doForm' => 'take_bed']), dock_remote('Take store', '📦', ['doForm' => 'take_store'])], '', '', 'Community garden', ['selectInfo' => 'tend'])];
            return ['L' => dock_action('Garden', '🌻', $u('community.php?t=garden')), 'R' => dock_action('Messages', '💬', $u('community.php?t=msgs'))];
        case 'yard.php':
            // The yard editor: left Save, right an Edit strip of the editor's own buttons (they are disabled until a piece is picked; the dock greys with them).
            $y = fn(string $act) => ['sel' => 'main button[data-act="' . $act . '"]'];
            return ['watch' => true, 'L' => dock_remote('Save', '💾', $y('save')), 'R' => dock_action('Edit', '🪴', '', [
                dock_remote('Rotate', '↻', $y('rotate')), dock_remote('Shape', '◧', $y('shape')), dock_remote('Size', '⚖️', $y('size')),
                dock_remote('Put away', '📦', $y('away')), dock_remote('Undo', '↶', $y('undo'))], '', '', 'Edit the picked piece')];
        case 'paljobs.php':
            // Pal jobs already send several pals at once (the job forms' ticked pals); the dock adds the bulk collect.
            return ['watch' => true, 'L' => dock_action('Pals', 'pals', $u('puzzlepals.php')), 'R' => dock_remote('Collect all', '🧺', ['doForm' => 'collect_all'])];
        case 'shop.php':
            // Left: the basket's own button (Buy all / Sell all), greyed until something is picked (the basket form is hidden while empty). Right: the Buy | Sell switch, a link to the other tab.
            $sid = (int)($_GET['id'] ?? 0);
            if ($sid <= 0) return [];
            $sell = ($_GET['tab'] ?? '') === 'sell';
            return ['watch' => true,
                'L' => dock_remote($sell ? 'Sell all' : 'Buy all', '🧺', ['sel' => '.basket:not([hidden]) .bgo']),
                'R' => dock_action($sell ? 'Buy' : 'Sell', $sell ? '🛒' : '💰', $u('shop.php?id=' . $sid . ($sell ? '' : '&tab=sell')))];
        case 'jobs.php':
            require_once __DIR__ . '/jobs.php';   // JOB_PERIODS
            $T = (string)($_GET['t'] ?? '');
            $p = (string)($_GET['p'] ?? 'daily');
            if (isset(JOB_PERIODS[$T]) || $T === 'post') { $p = $T; $T = 'jobs'; }
            if ($T === 'requests') {
                return ['watch' => true, 'L' => null, 'R' => dock_action('Deliver', '📜', '', [], '', '', '', [], [
                    dock_remote('Deliver', '📜', ['doForm' => 'order']), dock_remote('Favour', '🤝', ['doForm' => 'favour'])])];
            }
            if ($T === 'journey') return ['watch' => true, 'L' => null, 'R' => dock_action('Journey', '🧭', '', [], '', '', '', [], [
                dock_remote('Hand in', '✋', ['doForm' => 'hand_in']), dock_remote('Finish', '🏁', ['doForm' => 'finish']), dock_remote('Crate', '📦', ['doForm' => 'crate'])])];
            if ($p === 'post') return ['watch' => true, 'L' => null, 'R' => dock_action('Take', '📋', '', [], '', '', '', [], [dock_remote('Take', '📋', ['doForm' => 'take_player'])])];
            return ['watch' => true,
                'L' => dock_action('Re-roll', '🎲', '', [], '', '', '', [], [dock_remote('Give up', '🏳️', ['doForm' => 'abandon']), dock_remote('Re-roll', '🎲', ['doForm' => 'reroll'])]),
                'R' => dock_action('Take', '📋', '', [], '', '', '', [], [dock_remote('Hand in', '✋', ['doForm' => 'deliver']), dock_remote('Build', '🧱', ['doForm' => 'build']), dock_remote('Take', '📋', ['doForm' => 'take'])])];
    }
    return [];
}

/**
 * The dock markup: a plain list of links (visible only until assets/dock.js has drawn the dock, so the menu never vanishes if the script fails)
 * and the JSON the script reads (a data block, replaced by the in-place page swap so the plate and the actions stay current).
 */
function dock_html(array $u, string $page): string
{
    require_once __DIR__ . '/theme.php';
    [$menus, $here] = dock_menus($u, $page);
    $st = dock_status($u);
    $quick = null;
    try { require_once __DIR__ . '/quick_slot.php'; $quick = quick_get($u); } catch (Throwable $e) { error_log('dock quick: ' . $e->getMessage()); }
    $back = $page . (($qs = (string)($_SERVER['QUERY_STRING'] ?? '')) !== '' && preg_match('~^[A-Za-z0-9=&_.-]*$~', $qs) ? '?' . $qs : '');   // where a dock form sends the gnome back to (quick.php uses safe_back())
    $data = [
        'menus' => $menus, 'here' => $here, 'plate' => $st['plate'], 'rows' => $st['rows'], 'links' => $st['links'],
        'actions' => dock_actions($u, $page), 'themeForm' => theme_toggle('th-dock'), 'rail' => dock_rail($u), 'more' => dock_more($u, $page),
        'logoutForm' => '<form method="post" action="' . e(url('logout.php')) . '" class="inline" data-noajax="1">' . csrf_field() . '<button type="submit">Log out</button></form>', 'unread' => msg_unread((int)$u['id']) ? 1 : 0,
        'quick' => $quick, 'csrf' => csrf_token(), 'quickUrl' => url('quick.php'), 'back' => $back,
        'foe' => ($foe = dock_foe((int)$u['id'])),
        'play' => dock_play($page, $foe),
        'iconBase' => url('assets/img/nav/dock-'), 'iconNames' => DOCK_ICONS, 'home' => url('gnome.php'),
    ];
    $json = json_encode($data, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    $fb = '';
    foreach ($menus as $m) {
        $fb .= '<li><b>' . e($m['name']) . '</b><ul>';
        foreach ($m['tiles'] as $t) $fb .= '<li>' . ($t['why'] !== '' ? '<span>' . e($t['label']) . ' (' . e($t['why']) . ')</span>' : '<a href="' . e($t['href']) . '"' . (!empty($t['on']) ? ' aria-current="page"' : '') . '>' . e($t['label']) . '</a>') . '</li>';
        $fb .= '</ul></li>';
    }
    return '<nav class="dockroot" id="dockroot" aria-label="Game menu"><ul class="dockfb">' . $fb . '</ul></nav>'
        . '<div class="dockdata" hidden><script type="application/json" id="dockjson">' . $json . '</script></div>';
}
