<?php
declare(strict_types=1);
require_once __DIR__ . '/admin_resources.php';
// v1.6.3: the Admin menu. One place that says what is in the panel, in which section, and what each thing is for.
// The Dashboard (admin/index.php) draws it as .choice rows; admin_crumbs() uses it to show "Admin › Section › Page".

/** Sections, each with entries [key, icon, name|null (null = the data editor's own label), one-line purpose, count key].
 *  key: a page file (images.php) or a data editor (r:items). Count key: t:<table>, or fb / img / boot / ver / maint, or '' for none. */
function admin_menu_def(): array
{
    return [
        ['system', '⚙️', 'Update, settings & system', [   // v1.6.4.2: first section, Update first (Joshua)
            ['update.php', '⬆️', 'Update the game', 'Upload a new version, check and install it', 'ver'],
            ['settings.php', '⚙️', 'Game settings', 'Site name, rules, limits, maintenance mode', 'maint'],
            ['tools.php', '🧰', 'Tools & backups', 'Backups, error log, mail log, repair tools', 'boot'],   // badge: ok, or N errors (error log) / failed upgrade steps
            ['log.php', '🗒️', 'Admin log', 'Everything admins have done', ''],
        ]],
        ['players', '👤', 'Players', [
            ['feedback.php', admin_icon('mail'), 'Messages', 'Player notes and bug reports, and your replies', 'fb'],   // v2.6.37: was Feedback; first, it is the daily job
            ['r:users', '👤', null, 'Accounts, roles, coins, stats, bans', 't:users'],
            ['grant.php', '🎁', 'Give / take items', 'Hand a player items or coins, or take them back', ''],
            ['puzzlebox.php', '🧩', 'Reset Puzzle box', 'Put a player\'s Puzzle box back to the starter box; their unlocks stay', ''],
            ['mentors.php', '🎓', 'Mentors', 'Who guides new gnomes, and their pairings', ''],
            ['r:npc_friends', '🤝', null, 'How well each player knows each NPC', 't:npc_friends'],
            ['r:gotm_entries', '🏆', null, 'Garden of the Month entries and winners', 't:gotm_entries'],
        ]],
        ['world', '🗺️', 'World & places', [
            ['r:regions', '🌍', null, 'The big regions and their climate', 't:regions'],
            ['r:zones', '🧭', null, 'Zones inside regions', 't:zones'],
            ['r:landmarks', '⛰️', null, 'Landmarks and visitable sights', 't:landmarks'],
            ['r:landmark_runs', '🗺️', null, 'Every delve and lair run: outcome, depth, stages', 't:landmark_runs'],
            ['r:locations', '📍', null, 'Villages, stops and places to visit', 't:locations'],
            ['r:routes', '🛤️', null, 'Roads between places', 't:routes'],
            ['r:town_spots', '🏘️', null, 'Places inside a town', 't:town_spots'],
            ['r:town_actions', '🎯', null, 'What players can do at each town place', 't:town_actions'],
            ['r:town_lore', '📖', null, 'Town stories, shown by region', 't:town_lore'],
        ]],
        ['folk', '🧑‍🌾', 'Folk & shops', [
            ['r:npcs', '🧙', null, 'Characters who live in the world', 't:npcs'],
            ['gourmand.php', '🥄', 'The Gourmand', 'Pomeroy’s camp schedule, menus and what gnomes served (read-only)', ''],
            ['r:npc_schedules', '🕒', null, 'Where each NPC is, hour by hour', 't:npc_schedules'],
            ['r:shops', '🏪', null, 'Shops, opening and staffing', 't:shops'],
            ['r:shop_stock', '📦', null, 'What each shop sells, and for how much', 't:shop_stock'],
            ['r:helpers', '🧑‍🔧', null, 'Helpers players can hire for the garden', 't:helpers'],
        ]],
        ['stops', '⛺', 'Rest stops', [
            ['r:stop_types', '⛺', null, 'Kinds of rest stop', 't:stop_types'],
            ['r:stop_acts', '🎲', null, 'Activities at a stop', 't:stop_acts'],
            ['r:stop_folk', '🙋', null, 'Villagers who join a stop', 't:stop_folk'],
            ['r:stop_tiers', '🔨', null, 'Upgrade steps for adopted stops', 't:stop_tiers'],
            ['r:stop_tier_themes', '🏗️', null, 'Themed upgrades by kind of stop', 't:stop_tier_themes'],
            ['r:stop_sets', '🎫', null, 'Passport rewards', 't:stop_sets'],
            ['r:stop_adoptions', '🏡', null, 'Which player looks after which stop', 't:stop_adoptions'],
            ['livingstops.php', '🌱', 'Living stops', 'Today’s happenings, the calendar, stories and meter rules (read-only)', ''],
            ['buildplans.php', '🧱', 'Build plans', 'How each ruined haven, wonder and delve is made safe: four stages each (read-only)', ''],
        ]],
        ['items', '🎒', 'Items & crafting', [
            ['r:items', '🎒', null, 'Every item: seeds, produce, tools, goods', 't:items'],
            ['r:recipes', '🍲', null, 'What can be cooked or crafted', 't:recipes'],
            ['r:gatherables', '🍄', null, 'Things found when foraging', 't:gatherables'],
            ['r:creature_drops', '🪶', null, 'What each creature leaves behind', 't:creature_drops'],
        ]],
        ['garden', '🌱', 'Garden & creatures', [
            ['r:plants', '🌱', null, 'Crops, flowers and trees: grow times, yields', 't:plants'],
            ['r:plant_regions', '🗺️', null, 'Which plants grow in which region', 't:plant_regions'],
            ['hybrids.php', '🧬', 'Hybrids', 'Cross-breeding results', ''],
            ['r:plots', '🌻', null, 'Player gardens', 't:plots'],
            ['r:garden_buildings', '🏚️', null, 'Sheds, coops and other garden buildings', 't:garden_buildings'],
            ['r:garden_objects', '🪴', null, 'Fences, paths and other yard objects', 't:garden_objects'],
            ['r:cellar_plants', '🥔', null, 'Plants stored in root cellars', 't:cellar_plants'],
            ['r:problems', '🐛', null, 'Pests and garden troubles', 't:problems'],
            ['r:pest_kinds', '🪲', null, 'Garden pests: seasons, weather, counters', 't:pest_kinds'],
            ['r:companion_plants', '🌼', null, 'Plants that keep pests off or help crops', 't:companion_plants'],
            ['r:critter_kinds', '🐞', null, 'Garden animals: food, gifts, homes', 't:critter_kinds'],
            ['r:creatures', '🦊', null, 'Creatures met while adventuring', 't:creatures'],
        ]],
        ['trade', '💱', 'Trade & jobs', [
            ['r:stall_listings', '🧺', null, 'Items on market stalls', 't:stall_listings'],
            ['r:trade_offers', '🔁', null, 'Open trades between players', 't:trade_offers'],
            ['r:gifts', '🎀', null, 'Gifts waiting to be opened', 't:gifts'],
            ['r:job_templates', '📋', null, 'Jobs the board can offer', 't:job_templates'],
            ['r:user_jobs', '🧾', null, 'Jobs players have taken', 't:user_jobs'],
            ['r:player_jobs', '📌', null, 'Jobs posted by players', 't:player_jobs'],
            ['r:garden_hires', '🧑‍🌾', null, 'Helpers hired right now', 't:garden_hires'],
        ]],
        ['progress', '📈', 'Progress & quests', [
            ['r:quest_chapters', '🧭', null, 'Wren’s Journey, chapter by chapter', 't:quest_chapters'],
            ['r:quest_tasks', '✅', null, 'The tasks inside each chapter', 't:quest_tasks'],
            ['callings.php', '📜', 'Calling chapters', 'Story chapters for each calling', ''],
            ['treks.php', '🥾', 'Treks', 'Who is on a trek, and reset a run', ''],
            ['trek_text.php', '✍️', 'Trek story text', 'Write the story text for treks', ''],
            ['xp.php', '📈', 'XP sources', 'Where players earn XP, per day and top players', ''],
            ['retention.php', '🔁', 'Retention', 'Do new players finish the tour and come back?', ''],
            ['gameclock.php', '🕰️', 'Game clocks', 'Each player’s game day and time, and their last 100 actions', ''],
            ['usage.php', '📊', 'Usage', 'What real players use: jobs, helpers, shops, contests, games', ''],
            ['r:almanac_milestones', '🏅', null, 'Almanac milestones and their rewards', 't:almanac_milestones'],
        ]],
        ['content', '📝', 'Content & text', [
            ['texts.php', '📝', 'Page text', 'Edit the wording of game pages', ''],
            ['road_text.php', '🛣️', 'Road text', 'Edit road lines, scenes, wonder and delve wording', ''],
            ['trailsights.php', '🔎', 'Trail sights', 'What a gnome can do next to a big set piece on a Trail map', ''],   // v2.6.68
            ['trail_decor.php', '🌿', 'Trail decor', 'Edit how a section of a Trail map is dressed (looks, zones, props)', ''],   // 2.7.00
            ['code.php', '🧑‍💻', 'Page code', 'See or edit the code of a game page', ''],   // v2.6.37
            ['r:encyclopedia_entries', '📚', null, 'The Almanac’s pages', 't:encyclopedia_entries'],
            ['r:news', '📰', null, 'News posts on the front page', 't:news'],
            ['r:pages', '📄', null, 'Rules, About and other site pages', 't:pages'],
            ['r:random_events', '🎲', null, 'Surprises that can happen as players play', 't:random_events'],
        ]],
        ['art', '🖼️', 'Images & art', [
            ['images.php', admin_icon('art'), 'Images', 'Upload pictures and see which are still missing', 'img'],
            ['artguide.php', '🎨', 'Art & style guide', 'Download the style sheet and icon guide as a PDF', ''],
            ['here_layout.php', '📍', 'Picture layouts', 'Place exits, spots and villagers on the Here pictures', ''],
            ['puzzles.php', '🧩', 'GIFsaw', 'GIF pictures, uploads and tournaments', ''],   // v2.0.68; v2.0.69 renamed GIFsaw
            ['jigsaw.php', '🧩', 'Jigsaw', 'Pictures, uploads, tournaments', ''],   // v2.0.87
        ]],
    ];
}


/** Admin SVG icons (2px square-cap strokes, currentColor). One per menu section; the "ok/warn/err" glyphs are for status chips. */
function admin_icon(string $id): string
{
    static $d = [
        'system' => '<circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M5 5l2 2M17 17l2 2M19 5l-2 2M7 17l-2 2"/>',
        'players' => '<rect x="8" y="3" width="8" height="8"/><path d="M4 21v-4h16v4"/>',
        'world' => '<path d="M3 5l6-2 6 2 6-2v16l-6 2-6-2-6 2zM9 3v16M15 5v16"/>',
        'folk' => '<path d="M3 9l2-5h14l2 5M3 9h18M4 9v11h16V9M10 20v-6h4v6"/>',
        'stops' => '<path d="M2 20 12 4l10 16zM12 20v-6"/>',
        'items' => '<path d="M5 8h14l1 13H4zM9 8V5a3 3 0 0 1 6 0v3"/>',
        'garden' => '<path d="M12 21V11M12 11C12 6 8 4 4 4c0 5 3 7 8 7M12 13c0-4 3-6 8-6 0 4-3 6-8 6"/>',
        'trade' => '<path d="M4 8h16M16 4l4 4-4 4M20 16H4M8 12l-4 4 4 4"/>',
        'progress' => '<path d="M3 3v18h18M7 15l4-4 3 3 6-7"/>',
        'content' => '<path d="M5 3h10l4 4v14H5zM15 3v4h4M8 12h8M8 16h8"/>',
        'art' => '<rect x="3" y="4" width="18" height="16"/><path d="M3 16l5-5 4 4 3-3 6 6"/>',
        'home' => '<path d="M3 11 12 3l9 8M5 9.5V21h5v-6h4v6h5V9.5"/>',
        'update' => '<path d="M12 20V5M5 11l7-7 7 7"/>',
        'mail' => '<rect x="3" y="5" width="18" height="14"/><path d="M3 6l9 8 9-8"/>',
        'close' => '<path d="M6 6l12 12M18 6 6 18"/>',
        'log' => '<path d="M5 3h14v18H5zM8 8h8M8 12h8M8 16h5"/>',
        'gift' => '<path d="M4 9h16v4H4zM6 13v8h12v-8M12 9v12M12 9c-3 0-5-1-5-3s3-2 5 3c2-5 5-3 5-3s-2 3-5 3"/>',
        'puzzle' => '<path d="M4 4h6v3a2 2 0 1 0 4 0V4h6v6h-3a2 2 0 1 0 0 4h3v6H4z"/>',
        'cap' => '<path d="M2 9l10-5 10 5-10 5zM6 11v5c3 2 9 2 12 0v-5"/>',
        'code' => '<path d="M8 6l-6 6 6 6M16 6l6 6-6 6M14 4l-4 16"/>',
        'pen' => '<path d="M4 20h4L19 9l-4-4L4 16zM13 7l4 4"/>',
        'clock' => '<rect x="3" y="3" width="18" height="18"/><path d="M12 7v5l3 3"/>',
        'dna' => '<path d="M7 3c0 6 10 6 10 12s-10 6-10 6M17 3c0 6-10 6-10 12s10 6 10 6M8 8h8M8 16h8"/>',
        'boot' => '<path d="M6 3h6v8l7 3v5H6z"/>',
        'ok' => '<rect x="3" y="3" width="18" height="18"/><path d="M7 12l4 4 6-8"/>',
        'warn' => '<path d="M12 3 22 21H2zM12 10v5M12 18v.01"/>',
        'err' => '<path d="M8 3h8l5 5v8l-5 5H8l-5-5V8zM9 9l6 6M15 9l-6 6"/>',
        'info' => '<rect x="3" y="3" width="18" height="18"/><path d="M12 11v6M12 7v.01"/>',
    ];
    return '<svg class="aico" viewBox="0 0 24 24" aria-hidden="true" focusable="false">' . ($d[$id] ?? $d['info']) . '</svg>';
}

/** Icon for one menu entry: a page file gets its own glyph where there is one, a data editor (r:...) keeps its section's. */
function admin_entry_icon(string $key, string $sid): string
{
    static $m = ['update.php' => 'update', 'settings.php' => 'system', 'tools.php' => 'items', 'log.php' => 'log', 'feedback.php' => 'mail', 'grant.php' => 'gift', 'puzzlebox.php' => 'puzzle',
        'mentors.php' => 'cap', 'gourmand.php' => 'folk', 'livingstops.php' => 'garden', 'hybrids.php' => 'dna', 'callings.php' => 'log', 'treks.php' => 'boot', 'trek_text.php' => 'pen',
        'xp.php' => 'progress', 'retention.php' => 'progress', 'usage.php' => 'progress', 'gameclock.php' => 'clock', 'texts.php' => 'content', 'road_text.php' => 'pen', 'code.php' => 'code',
        'buildplans.php' => 'world', 'trailsights.php' => 'world', 'trail_decor.php' => 'garden', 'images.php' => 'art', 'artguide.php' => 'content', 'here_layout.php' => 'world', 'puzzles.php' => 'puzzle', 'jigsaw.php' => 'puzzle'];
    return admin_icon($m[$key] ?? $sid);
}

/** Dashboard "Needs a look": each item is [level ok|warn|err|info, text HTML, action HTML or '']. Every row says its level in words, not colour alone. */
function admin_triage_render(array $items): void
{
    $words = ['err' => 'Problem', 'warn' => 'Check', 'info' => 'Note', 'ok' => 'Fine'];
    $open = count(array_filter($items, fn($i) => $i[0] !== 'ok'));
    echo '<section class="apanel" aria-labelledby="triage-h"><div class="aph"><h2 id="triage-h">Needs a look</h2><small>' . ($open ? $open . ' open' : 'nothing open') . '</small></div>';
    if (!$items) { echo '<p class="atri-none">' . admin_icon('ok') . ' Nothing needs you right now.</p></section>'; return; }
    echo '<ul class="atri">';
    foreach ($items as [$lv, $html, $act]) {
        echo '<li class="atri-' . e($lv) . '"><span class="ast ' . e($lv) . '">' . admin_icon($lv) . e($words[$lv] ?? 'Note') . '</span><span class="atri-msg">' . $html . '</span>' . ($act !== '' ? '<span class="atri-act">' . $act . '</span>' : '') . '</li>';
    }
    echo '</ul></section>';
}

/** Where is this page/editor in the menu? ['section id','section title','entry name'] or null. $key is 'images.php' or 'r:items'. */
function admin_menu_find(string $key): ?array
{
    $res = null;
    foreach (admin_menu_def() as [$sid, , $stitle, $entries]) {
        foreach ($entries as $en) {
            if ($en[0] !== $key) continue;
            if ($en[2] === null) { $res ??= admin_resources(); $name = (string)($res[substr($key, 2)]['label'] ?? $key); }
            else $name = $en[2];
            return [$sid, $stitle, $name];
        }
    }
    return null;
}

function admin_menu_url(string $key): string
{
    return str_starts_with($key, 'r:') ? url('admin/crud.php?r=' . substr($key, 2)) : url('admin/' . $key);
}

/** Breadcrumb bar: "← Admin › Section › Page [› leaf]". $leaf (e.g. "Edit") makes the page a link back to its list. */
function admin_crumbs(string $key, string $leaf = ''): void
{
    $f = admin_menu_find($key);
    echo '<nav class="acrumbs" aria-label="Breadcrumb"><a class="aback" href="' . e(url('admin/index.php')) . '">' . admin_icon('home') . ' Admin</a>';
    if ($f) echo '<span class="asep" aria-hidden="true">›</span><a href="' . e(url('admin/index.php#sec-' . $f[0])) . '">' . e($f[1]) . '</a>';
    if ($f) {
        echo '<span class="asep" aria-hidden="true">›</span>';
        echo $leaf !== '' ? '<a href="' . e(admin_menu_url($key)) . '">' . e($f[2]) . '</a><span class="asep" aria-hidden="true">›</span><span aria-current="page">' . e($leaf) . '</span>'
                          : '<span aria-current="page">' . e($f[2]) . '</span>';
    }
    echo '</nav>';
}

/** v2.6.37: entries in data/error-log.txt (each starts "[2026-01-02 03:04:05 UTC]"). Reads the last 200 KB at most; 0 = empty or missing.
 *  The log is emptied with "Clear the log" on Tools, so anything in it is something not looked at yet. */
function admin_error_count(): int
{
    $f = APP_ROOT . '/data/error-log.txt';
    $size = is_file($f) ? (int)@filesize($f) : 0;
    if ($size <= 0) return 0;
    $tail = (string)@file_get_contents($f, false, null, max(0, $size - 200000));
    return max(1, (int)preg_match_all('/^\[\d{4}-\d\d-\d\d \d\d:\d\d:\d\d UTC\]/m', $tail));
}

/** Cheap counts for the badges: ['key' => [text, class]]. Anything that fails just shows no badge. */
function admin_menu_badges(): array
{
    $b = [];
    $try = function (callable $f) { try { return $f(); } catch (Throwable $e) { return null; } };
    foreach (admin_menu_def() as [, , , $entries]) {
        foreach ($entries as $en) {
            if (!str_starts_with($en[4], 't:')) continue;
            $t = substr($en[4], 2);
            if (!preg_match('/^[a-z_]+$/', $t)) continue;
            $n = $try(fn() => (int)q_val("SELECT COUNT(*) FROM $t"));
            if ($n !== null) $b[$en[4]] = [number_format($n), ''];
        }
    }
    $n = $try(fn() => (int)q_val("SELECT COUNT(*) FROM feedback WHERE status = 'new'"));
    if ($n !== null) $b['fb'] = $n ? [$n . ' new', 'poor'] : ['0', ''];
    $n = $try(function () { require_once dirname(__DIR__) . '/includes/art_upload.php'; $p = art_progress(0); return array_sum(array_column($p['cats'], 0)) - array_sum(array_column($p['cats'], 1)); });
    if ($n !== null) $b['img'] = $n > 0 ? [number_format($n) . ' missing', 'poor'] : ['all in', 'good'];
    $boot = (string)$try(fn() => setting('boot_failed_steps'));
    $up = $try(fn() => count(upgrade_100_failed())) ?? 0;
    $errs = admin_error_count();   // v2.6.37: the badge said "ok" with a full error log
    $bits = [];
    if ($errs) $bits[] = $errs . ' error' . ($errs === 1 ? '' : 's');
    if ($boot !== '' || $up) $bits[] = ($up + ($boot !== '' ? 1 : 0)) . ' failed';
    $b['boot'] = $bits ? ['Check: ' . implode(', ', $bits), 'poor'] : ['ok', 'good'];
    $b['ver'] = ['v' . APP_VERSION, ''];
    $b['maint'] = $try(fn() => setting('maintenance_mode')) === '1' ? ['maintenance', 'poor'] : ['', ''];
    return $b;
}

/** The menu itself: a filter box and <details> sections of .choice rows. Works without JS (everything is just there). */
function admin_menu_render(): void
{
    $b = admin_menu_badges();
    $res = admin_resources();
    echo '<div class="amenu" id="amenu">';
    echo '<p class="afind" id="afindwrap" hidden><label class="asr" for="afind">Find a page or editor</label><input type="search" id="afind" placeholder="Find a page or editor…" autocomplete="off" enterkeyhint="search"></p>';
    echo '<div class="acols">';
    foreach (admin_menu_def() as [$sid, $sico, $stitle, $entries]) {
        $open = in_array($sid, ['players', 'system'], true) ? ' open' : '';
        echo '<details class="asec"' . $open . ' id="sec-' . e($sid) . '" data-sec="' . e($sid) . '"><summary><span class="asec-ico" aria-hidden="true">' . admin_icon($sid) . '</span><b>' . e($stitle) . '</b><small>' . count($entries) . '</small></summary><div class="arows">';
        foreach ($entries as [$key, $ico, $name, $sub, $ck]) {
            if ($name === null) $name = (string)($res[substr($key, 2)]['label'] ?? $key);
            [$btxt, $bcls] = $b[$ck] ?? ['', ''];
            $find = strtolower($name . ' ' . $sub . ' ' . $stitle);
            echo '<a class="choice" href="' . e(admin_menu_url($key)) . '" data-find="' . e($find) . '"><span class="choice-ico" aria-hidden="true">' . admin_entry_icon($key, $sid) . '</span><span class="choice-body"><b class="choice-title">' . e($name) . '</b><small class="choice-sub">' . e($sub) . '</small></span>';
            if ($btxt !== '') echo '<b class="choice-badge' . ($bcls !== '' ? ' ' . $bcls : '') . '">' . e($btxt) . '</b>';
            echo '</a>';
        }
        echo '</div></details>';
    }
    echo '</div><p class="muted" id="anone" hidden>Nothing matches. Try a shorter word.</p></div>';
}

/** v1.6.3.3: the admin pop-up / side menu, built from admin_menu_def() and laid out like the game's menu sheet
 *  (tile grid per section). Quick tiles on top; the section holding this page opens, the rest fold. */
function admin_nav_sheet(): string
{
    $res = admin_resources();
    $here = basename((string)($_SERVER['SCRIPT_NAME'] ?? '')) . (isset($_GET['r']) ? '?r=' . (string)$_GET['r'] : '');
    $fbNew = 0;
    try { $fbNew = (int)q_val("SELECT COUNT(*) FROM feedback WHERE status = 'new'"); } catch (Throwable $e) {}
    $errs = admin_error_count();
    $tile = function (string $href, string $key, string $icon, string $label, string $badge = '') use ($here): string {
        $mine = $key === $here || ($key !== '' && 'crud.php?r=' . substr($key, 2) === $here && str_starts_with($key, 'r:'));
        return '<a class="navtile' . ($mine ? ' on' : '') . '" href="' . e($href) . '"' . ($mine ? ' aria-current="page"' : '') . '><span class="nti">' . $icon . '</span><span class="ntl">' . e($label) . '</span>'
            . ($badge !== '' ? '<span class="ntb">' . e($badge) . '</span>' : '') . '</a>';
    };
    $h = '<div class="navhead"><b>Admin</b><button type="button" class="navx" aria-label="Close the menu">' . admin_icon('close') . '</button></div>';
    $h .= '<div class="navtiles anavtop">'
        . $tile(url('admin/index.php'), 'index.php', admin_icon('home'), 'Dashboard')
        . $tile(url('admin/update.php'), 'update.php', admin_icon('update'), 'Update')
        . $tile(url('admin/settings.php'), 'settings.php', admin_icon('system'), 'Settings')
        . $tile(url('admin/feedback.php'), 'feedback.php', admin_icon('mail'), 'Messages', $fbNew ? $fbNew . ' new' : '')
        . $tile(url('admin/tools.php#errors'), 'tools.php', admin_icon('items'), 'Tools', $errs ? $errs . ' error' . ($errs === 1 ? '' : 's') : '')   // v2.6.37
        . $tile(url('admin/images.php'), 'images.php', admin_icon('art'), 'Images')
        . $tile(url('index.php'), '', admin_icon('garden'), 'Back to game')
        . '</div>';
    foreach (admin_menu_def() as [$sid, $sico, $stitle, $entries]) {
        $tl = '';
        foreach ($entries as [$key, $ico, $name]) {
            if ($name === null) $name = (string)($res[substr($key, 2)]['label'] ?? $key);
            $tl .= $tile(admin_menu_url($key), $key, admin_entry_icon($key, $sid), $name);
        }
        $cur = str_contains($tl, 'navtile on');
        $h .= '<details class="navgroupt anavsec' . ($cur ? ' cur' : '') . '"' . ($cur ? ' open' : '') . '><summary><h3>' . admin_icon($sid) . ' ' . e($stitle) . ' <small>' . count($entries) . '</small></h3></summary><div class="navtiles">' . $tl . '</div></details>';
    }
    $h .= '<form method="post" action="' . e(url('logout.php')) . '" class="navlogout">' . csrf_field() . '<button class="linkbtn">Log out</button></form>';
    return $h;
}
