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
            ['tools.php', '🧰', 'Tools & backups', 'Backups, error log, mail log, repair tools', 'boot'],
            ['log.php', '🗒️', 'Admin log', 'Everything admins have done', ''],
        ]],
        ['players', '👤', 'Players', [
            ['r:users', '👤', null, 'Accounts, roles, coins, stats, bans', 't:users'],
            ['grant.php', '🎁', 'Give / take items', 'Hand a player items or coins, or take them back', ''],
            ['feedback.php', '💬', 'Feedback', 'Notes and bug reports from players', 'fb'],
            ['mentors.php', '🎓', 'Mentors', 'Who guides new gnomes, and their pairings', ''],
            ['r:npc_friends', '🤝', null, 'How well each player knows each NPC', 't:npc_friends'],
            ['r:gotm_entries', '🏆', null, 'Garden of the Month entries and winners', 't:gotm_entries'],
        ]],
        ['world', '🗺️', 'World & places', [
            ['r:regions', '🌍', null, 'The big regions and their climate', 't:regions'],
            ['r:zones', '🧭', null, 'Zones inside regions', 't:zones'],
            ['r:landmarks', '⛰️', null, 'Landmarks and visitable sights', 't:landmarks'],
            ['r:locations', '📍', null, 'Villages, stops and places to visit', 't:locations'],
            ['r:routes', '🛤️', null, 'Roads between places', 't:routes'],
            ['r:town_spots', '🏘️', null, 'Places inside a town', 't:town_spots'],
            ['r:town_actions', '🎯', null, 'What players can do at each town place', 't:town_actions'],
            ['r:town_lore', '📖', null, 'Town stories, shown by region', 't:town_lore'],
        ]],
        ['folk', '🧑‍🌾', 'Folk & shops', [
            ['r:npcs', '🧙', null, 'Characters who live in the world', 't:npcs'],
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
            ['r:stop_sets', '🎫', null, 'Passport rewards', 't:stop_sets'],
            ['r:stop_adoptions', '🏡', null, 'Which player looks after which stop', 't:stop_adoptions'],
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
            ['usage.php', '📊', 'Usage', 'What real players use: jobs, helpers, shops, contests, games', ''],
            ['r:almanac_milestones', '🏅', null, 'Almanac milestones and their rewards', 't:almanac_milestones'],
        ]],
        ['content', '📝', 'Content & text', [
            ['texts.php', '📝', 'Page text', 'Edit the wording of game pages', ''],
            ['r:encyclopedia_entries', '📚', null, 'The Almanac’s pages', 't:encyclopedia_entries'],
            ['r:news', '📰', null, 'News posts on the front page', 't:news'],
            ['r:pages', '📄', null, 'Rules, About and other site pages', 't:pages'],
            ['r:random_events', '🎲', null, 'Surprises that can happen as players play', 't:random_events'],
        ]],
        ['art', '🖼️', 'Images & art', [
            ['images.php', '🖼️', 'Images', 'Upload pictures and see which are still missing', 'img'],
        ]],
    ];
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
    echo '<nav class="acrumbs" aria-label="Breadcrumb"><a class="aback" href="' . e(url('admin/index.php')) . '">← Admin</a>';
    if ($f) echo '<span class="asep" aria-hidden="true">›</span><a href="' . e(url('admin/index.php#sec-' . $f[0])) . '">' . e($f[1]) . '</a>';
    if ($f) {
        echo '<span class="asep" aria-hidden="true">›</span>';
        echo $leaf !== '' ? '<a href="' . e(admin_menu_url($key)) . '">' . e($f[2]) . '</a><span class="asep" aria-hidden="true">›</span><span aria-current="page">' . e($leaf) . '</span>'
                          : '<span aria-current="page">' . e($f[2]) . '</span>';
    }
    echo '</nav>';
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
    $b['boot'] = ($boot !== '' || $up) ? [($up + ($boot !== '' ? 1 : 0)) . ' failed', 'poor'] : ['ok', 'good'];
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
        echo '<details class="asec"' . $open . ' id="sec-' . e($sid) . '" data-sec="' . e($sid) . '"><summary><span class="asec-ico" aria-hidden="true">' . $sico . '</span><b>' . e($stitle) . '</b><small>' . count($entries) . '</small></summary><div class="arows">';
        foreach ($entries as [$key, $ico, $name, $sub, $ck]) {
            if ($name === null) $name = (string)($res[substr($key, 2)]['label'] ?? $key);
            [$btxt, $bcls] = $b[$ck] ?? ['', ''];
            $find = strtolower($name . ' ' . $sub . ' ' . $stitle);
            echo '<a class="choice" href="' . e(admin_menu_url($key)) . '" data-find="' . e($find) . '"><span class="choice-ico" aria-hidden="true">' . $ico . '</span><span class="choice-body"><b class="choice-title">' . e($name) . '</b><small class="choice-sub">' . e($sub) . '</small></span>';
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
    $tile = function (string $href, string $key, string $icon, string $label, string $badge = '') use ($here): string {
        $mine = $key === $here || ($key !== '' && 'crud.php?r=' . substr($key, 2) === $here && str_starts_with($key, 'r:'));
        return '<a class="navtile' . ($mine ? ' on' : '') . '" href="' . e($href) . '"' . ($mine ? ' aria-current="page"' : '') . '><span class="nti">' . $icon . '</span><span class="ntl">' . e($label) . '</span>'
            . ($badge !== '' ? '<span class="ntb">' . e($badge) . '</span>' : '') . '</a>';
    };
    $h = '<div class="navhead"><b>🛠️ Admin</b><button type="button" class="navx" aria-label="Close the menu">✕</button></div>';
    $h .= '<div class="navtiles anavtop">'
        . $tile(url('admin/index.php'), 'index.php', '🏠', 'Dashboard')
        . $tile(url('admin/update.php'), 'update.php', '⬆️', 'Update')
        . $tile(url('admin/settings.php'), 'settings.php', '⚙️', 'Settings')
        . $tile(url('admin/feedback.php'), 'feedback.php', '💬', 'Feedback', $fbNew ? $fbNew . ' new' : '')
        . $tile(url('admin/images.php'), 'images.php', '🖼️', 'Images')
        . $tile(url('index.php'), '', '🌱', 'Back to game')
        . '</div>';
    foreach (admin_menu_def() as [$sid, $sico, $stitle, $entries]) {
        $tl = '';
        foreach ($entries as [$key, $ico, $name]) {
            if ($name === null) $name = (string)($res[substr($key, 2)]['label'] ?? $key);
            $tl .= $tile(admin_menu_url($key), $key, $ico, $name);
        }
        $cur = str_contains($tl, 'navtile on');
        $h .= '<details class="navgroupt anavsec' . ($cur ? ' cur' : '') . '"' . ($cur ? ' open' : '') . '><summary><h3>' . $sico . ' ' . e($stitle) . ' <small>' . count($entries) . '</small></h3></summary><div class="navtiles">' . $tl . '</div></details>';
    }
    $h .= '<form method="post" action="' . e(url('logout.php')) . '" class="navlogout">' . csrf_field() . '<button class="linkbtn">Log out</button></form>';
    return $h;
}
