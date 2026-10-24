<?php
declare(strict_types=1);

define('APP_ROOT', dirname(__DIR__));
define('APP_VERSION', '2.0.48');

if (!is_file(APP_ROOT . '/config.php')) {
    http_response_code(503);
    exit('This site is not installed yet. Open install.php to set it up.');
}

$CONFIG = require APP_ROOT . '/config.php';
date_default_timezone_set('UTC');
error_reporting(E_ALL);
ini_set('display_errors', !empty($CONFIG['debug']) ? '1' : '0');
ini_set('log_errors', '1');

// v1.6.8: data/ (error log, backups, caches, locks) must never be readable from the web
if (is_dir(APP_ROOT . '/data') && !is_file(APP_ROOT . '/data/.htaccess')) @file_put_contents(APP_ROOT . '/data/.htaccess', "Require all denied\nDeny from all\n");

// v0.7.37: when something breaks, write it to data/error-log.txt (readable in Admin → Tools) and show a friendly page,
// so a blank "doesn't load" screen on a web host can be tracked down without digging through the host's logs.
function game_error_log(string $what): void
{
    $path = strtok((string)($_SERVER['REQUEST_URI'] ?? ''), '?') ?: '(cli)';
    $what = str_replace(APP_ROOT, '', $what);
    require_once __DIR__ . '/logrotate.php';   // v1.6.8: the log rolls over to error-log.txt.1 at 1 MB
    log_rotate_if_big(APP_ROOT . '/data/error-log.txt');
    @file_put_contents(APP_ROOT . '/data/error-log.txt', '[' . gmdate('Y-m-d H:i:s') . ' UTC] ' . ($_SERVER['REQUEST_METHOD'] ?? '') . ' ' . $path . "\n" . $what . "\n\n", FILE_APPEND | LOCK_EX);
}
function game_error_page(): void
{
    if (PHP_SAPI === 'cli' || headers_sent()) return;
    http_response_code(500);
    echo '<!doctype html><meta charset="utf-8"><title>Oops</title><body>'
        . '<h1>🍄 Oops, something went wrong</h1><p>The gnomes have written it down. Please try again in a moment, or go back to the <a href="/">home page</a>.</p>'
        . '<p>If you run this game: the details are in Admin → Tools → Error log.</p></body>';
}
set_exception_handler(function (Throwable $e) {
    try { if (function_exists('db') && isset($GLOBALS['CONFIG']) && db()->inTransaction()) db()->rollBack(); } catch (Throwable $e2) {}   // v1.0.0: never leave a half-done transaction behind
    game_error_log(get_class($e) . ': ' . $e->getMessage() . ' in ' . $e->getFile() . ':' . $e->getLine() . "\n" . $e->getTraceAsString());
    game_error_page();
});
register_shutdown_function(function () {
    $e = error_get_last();
    if ($e && in_array($e['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR], true)) {
        game_error_log('Fatal: ' . $e['message'] . ' in ' . $e['file'] . ':' . $e['line']);
    }
});

require_once __DIR__ . '/db.php';
require_once __DIR__ . '/functions.php';
require_once __DIR__ . '/upgrade100.php';   // v1.0.0: guarded upgrade steps
require_once __DIR__ . '/social.php';   // v1.0.0 wave 3: settings, tables, the welcome-back note
require_once __DIR__ . '/market100.php';   // v1.0.0 wave 2b: orders, market day, price drift
require_once __DIR__ . '/pixel_art.php';   // v2.0.31: pixel art helpers
require_once __DIR__ . '/layout.php';
require_once __DIR__ . '/progression.php';   // region levels and where you've been (v0.7.43)
require_once __DIR__ . '/calling_quests.php';   // v0.9.4: calling_event() is called from the hooks on every page
require_once __DIR__ . '/sinks.php';   // v0.9.7: Petal sinks (dyes are read wherever a gnome is drawn)
require_once __DIR__ . '/rewards.php';   // give_petals / take_petals / give_xp wrapper
require_once __DIR__ . '/moderation.php';   // report buttons and the word filter, on every page (v0.7.28)

/**
 * v1.2.2: run one auto-upgrade step on its own. If it throws, log it, remember its name in the boot_failed_steps setting
 * (shown on the admin dashboard) and carry on, so one broken step can't keep the whole chain re-running on every page load.
 */
function boot_step(string $name, callable $fn): void
{
    try {
        $fn();
    } catch (Throwable $e) {
        try { if (db()->inTransaction()) db()->rollBack(); } catch (Throwable $e2) {}
        $GLOBALS['gv_boot_failed'][] = $name;
        error_log('Auto-upgrade step ' . $name . ' failed: ' . $e->getMessage());
        game_error_log('Auto-upgrade step "' . $name . '" failed: ' . get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine());
    }
}

// New version uploaded? Add any new tables/columns before anything reads them.
// (Same as pressing "Upgrade database"; never removes or changes existing data.)
// v1.0.0: one request upgrades at a time (a lock file); the others wait a little, then find it done and carry on.
if (setting('db_version') !== APP_VERSION && upgrade_lock(25000) && setting('__reload__') === '' && setting('db_version') !== APP_VERSION) {
    @set_time_limit(600);
    @ignore_user_abort(true);
    try {
        db_migrate(db(), (string)($CONFIG['db']['driver'] ?? 'mysql'));
        boot_step('energy_rescale_world', function () {
            energy_rescale_world();  // v0.7.23: older worlds' energy numbers (before new content is added in the new scale)
        });
        boot_step('ensure_tools', function () {
            require_once __DIR__ . '/tools.php';
            require_once __DIR__ . '/gathering.php';
            ensure_tools();
        });
        boot_step('ensure_gatherables', function () {
            ensure_gatherables();   // new content that ships with a version (adds only what's missing)
        });
        boot_step('ensure_nutrients', function () {
            require_once __DIR__ . '/nutrients.php';
            ensure_nutrients();     // before crafting: some recipes make NPK items
        });
        boot_step('ensure_games', function () {
            require_once __DIR__ . '/games.php';
            ensure_games();
        });
        boot_step('ensure_friends', function () {
            require_once __DIR__ . '/friends.php';
            ensure_friends();
        });
        boot_step('ensure_community', function () {
            require_once __DIR__ . '/community.php';
            ensure_community();
        });
        boot_step('ensure_contests', function () {
            require_once __DIR__ . '/contests.php';
            ensure_contests();
        });
        boot_step('ensure_launch', function () {
            require_once __DIR__ . '/account.php';
            ensure_launch();
        });
        boot_step('ensure_events', function () {
            require_once __DIR__ . '/events.php';
            ensure_events();         // before crafting: the worm bin recipe gets its Almanac page there
        });
        boot_step('ensure_crafts', function () {
            require_once __DIR__ . '/crafting.php';
            ensure_crafts();
        });
        boot_step('ensure_helpers', function () {
            require_once __DIR__ . '/hired_help.php';
            ensure_helpers();
        });
        boot_step('ensure_jobs', function () {
            require_once __DIR__ . '/jobs.php';
            ensure_jobs();
        });
        boot_step('ensure_trade_content', function () {
            require_once __DIR__ . '/trade.php';
            ensure_trade_content();
        });
        boot_step('ensure_towns', function () {
            require_once __DIR__ . '/town.php';
            ensure_towns();          // town squares (v0.7.20)
        });
        boot_step('ensure_yards', function () {
            require_once __DIR__ . '/yard.php';
            ensure_yards();          // yards, decor, the Hedge & Hearth (v0.7.32), before NPC routines (it adds staff)
        });
        boot_step('upgrade_097_sinks', function () {
            if (version_compare((string)setting('db_version'), '0.9.7', '<')) upgrade_097_sinks();   // v0.9.7 part B: Curio Cabinet, Dye Pot, Almanac page (the feasts come with ensure_crafts)
        });
        boot_step('upgrade_098_pantry', function () {
            if (version_compare((string)setting('db_version'), '0.9.8', '<')) { require_once __DIR__ . '/pantry.php'; upgrade_098_pantry(); }   // v0.9.8 part A: the Pantry (preserve recipes and Almanac pages; tables and columns come from schema.php)
        });
        boot_step('upgrade_099_flowers', function () {
            if (version_compare((string)setting('db_version'), '0.9.9', '<')) { require_once __DIR__ . '/flowers.php'; upgrade_099_flowers(); }   // v0.9.9 part A: florists (shops, staff, stock) and the flower Almanac pages; tables come from schema.php
        });
        // v1.0.0: each step has its own done-flag and try/catch (upgrade100.php): a failing step is logged and shown in Admin with a Retry button, the site keeps working
        upgrade_100_run_step('clock');    // v1.0.0 backbone: season calendar starts now, Almanac page
        upgrade_100_run_step('garden');   // v1.0.0 wave 2a: crop seasons, pests, companions, garden animals, Almanac pages
        boot_step('ensure_npc_lives', function () {
            require_once __DIR__ . '/npc_life.php';
            ensure_npc_lives();      // NPC routines and travellers (v0.7.21)
        });
        upgrade_100_run_step('market');   // v1.0.0 wave 2b: Almanac page, old favours carried over (tables come from schema.php)
        upgrade_100_run_step('social');   // v1.0.0 wave 3: Almanac pages, Opening Day dates, festival decor (tables come from schema.php)
        boot_step('ensure_town_social', function () {
            require_once __DIR__ . '/town_social.php';
            ensure_town_social();    // meeting other gnomes, favours (v0.7.22)
        });
        boot_step('ensure_roads', function () {
            require_once __DIR__ . '/roads.php';
            ensure_roads();          // roads between towns, side paths to hidden places (v0.7.24)
        });
        upgrade_100_run_step('stops');    // v1.0.0 wave 1: rest stop types, activities, villagers, passport sets (tables come from schema.php)
        require_once __DIR__ . '/upgrade110.php';
        upgrade_110_run();                // v1.1.0: cook_energy_percent 150 -> 115, egg dishes (each step runs once; upgrade110.php)
        require_once __DIR__ . '/upgrade120.php';
        upgrade_120_run();                // v1.2.0: more garden animals, player mentors (upgrade120.php)
        require_once __DIR__ . '/upgrade140.php';
        upgrade_140_run();                // v1.4.0: Butterfly Bush, Snail Jar, soil craft amounts (upgrade140.php)
        require_once __DIR__ . '/upgrade163.php';
        upgrade_163_run();                // v1.6.3: adopt-a-stop limit 3, worm colony 12 hours (upgrade163.php)
        require_once __DIR__ . '/upgrade170.php'; upgrade_170_run();   // v1.7.0: garden reactions become guestbook stamps
        require_once __DIR__ . '/upgrade193.php'; upgrade_193_run();   // v1.9.3: road life: weather problems, cond tags on problems, creatures, gatherables
        boot_step('ensure_lair_bosses', function () {
            require_once __DIR__ . '/landmarks.php';
            ensure_lair_bosses();    // each lair's own legendary creature (v0.7.26)
        });
        boot_step('ensure_progression', function () {
            ensure_progression();    // everyone starts in the Maplewold; region levels (v0.7.43)
        });
        boot_step('ensure_journey', function () {
            require_once __DIR__ . '/journey.php';
            ensure_journey();        // Wren's Journey: a questline per region (v0.7.65)
        });
        boot_step('ensure_guide_price', function () {
            ensure_guide_price();    // gardening guides cost the guide_price setting (v0.7.65)
        });
        boot_step('ensure_calling_quests', function () {
            require_once __DIR__ . '/calling_quests.php';
            ensure_calling_quests(); // v0.9.4: calling chapters (Journeyman and Master), from data/calling_quests.txt
        });
        boot_step('market176_almanac', function () {
            require_once __DIR__ . '/market100.php';
            market176_almanac();   // v1.7.6: Orders page wording (food quality off)
        });
        boot_step('ensure_treks', function () {
            require_once __DIR__ . '/trek_data.php';
            trek_import();   // v1.8.0: trek items, creatures, story text slots and Almanac pages (adds only what is missing)
        });
        boot_step('trek_chapters', function () {
            require_once __DIR__ . '/trek_data.php';
            trek_ch_ensure();    // v1.9.1: per-chapter runs: the users columns, the new unique index on trek_runs
            trek_pet_migrate();  // v1.9.1: today's trek Petal count moves from the run state to the player
        });
        boot_step('trek_bodies_200', function () {
            if ((int)setting('trek_text_pass') < 2) {   // v2.0.8: numeric and never lowers the pass (the setting is cached for the request, so a !== test re-ran steps and left the flag one behind). v2.0.0: final Treks text (Chapter I and II), once; a row Joshua wrote keeps his words
                require_once __DIR__ . '/trek_data.php';
                if (trek_apply_final_texts() > 0) set_setting('trek_text_pass', '2');   // only once the final file is there: an empty file must not close the pass
            }
        });
        boot_step('trek_bodies_204', function () {
            if ((int)setting('trek_text_pass') < 3) {   // v2.0.4: reworked Treks text, once; a row Joshua wrote keeps his words
                require_once __DIR__ . '/trek_data.php';
                trek_import_texts();                    // the new slots first (they ship their briefs in trek_texts*.txt)
                if (trek_apply_text_204() > 0) set_setting('trek_text_pass', '3');
            }
        });
        boot_step('trek_bodies_207', function () {
            if ((int)setting('trek_text_pass') < 4) {   // v2.0.7: small Treks text fixes, once; a row Joshua wrote keeps his words
                require_once __DIR__ . '/trek_data.php';
                trek_import_texts();                    // the new slot first (it ships its brief in trek_texts_ch2.txt)
                if (trek_apply_text_207() > 0) set_setting('trek_text_pass', '4');
            }
        });
        boot_step('trek_bodies_2012', function () {
            if ((int)setting('trek_text_pass') < 5) {   // v2.0.12: Treks text fixes, once; a row Joshua wrote keeps his words
                require_once __DIR__ . '/trek_data.php';
                trek_import_texts();                    // the four new Zinnia/Bracken banter slots first
                if (trek_apply_text_2012() > 0) set_setting('trek_text_pass', '5');
            }
        });
        boot_step('trek_bodies_2015', function () {
            if ((int)setting('trek_text_pass') < 6) {   // v2.0.15: Tumble's lines match his easier way, once; a row Joshua wrote keeps his words
                require_once __DIR__ . '/trek_data.php';
                if (trek_apply_text_2015() > 0) set_setting('trek_text_pass', '6');
            }
        });
        boot_step('trek_bodies_2020', function () {
            if ((int)setting('trek_text_pass') < 7) {   // v2.0.20: sluice lines name the water level and the clay layer, once; a row Joshua wrote keeps his words
                require_once __DIR__ . '/trek_textpass.php';
                trek_apply_text_2020();                 // sets trek_text_pass = 7
            }
        });
        boot_step('trek_bodies_2021', function () {
            if ((int)setting('trek_text_pass') < 8) {   // v2.0.20: camp rests heal fully; the kit, old campsite and rest spot lines say rested and whole, once; a row Joshua wrote keeps his words
                require_once __DIR__ . '/trek_textpass.php';
                trek_apply_text_2021();                 // sets trek_text_pass = 8
            }
        });
        boot_step('trek_bodies_2022', function () {
            if ((int)setting('trek_text_pass') < 9) {   // v2.0.22: Chapter III-b; the Still Gate opens, so ch3a_end no longer says it stays shut, once; a row Joshua wrote keeps his words
                require_once __DIR__ . '/trek_textpass.php';
                trek_apply_text_2022();                 // sets trek_text_pass = 9
            }
        });
        boot_step('trek_item_desc_2012', function () {   // v2.0.12: the Lanternroot Seed showed a TODO in the Satchel; only a row that still holds the old words is changed
            db_update('items', ['description' => 'A small seed with a faint glow inside, like a coal that forgot to go out.'], 'slug = ? AND description = ?', ['lanternroot-seed', 'A seed that glows faintly. TODO: the Lanternroot crop is not built yet.']);
        });
        boot_step('upgrade_094_callings', function () {
            if (version_compare((string)setting('db_version'), '0.9.4', '<')) upgrade_094_callings();   // v0.9.4: tiers II/III now need the chapter
        });
        boot_step('ensure_almanac_howto', function () {
            require_once __DIR__ . '/almanac_notes.php';
            ensure_almanac_howto(version_compare((string)setting('db_version'), '0.7.72', '<'));   // v0.7.72: new How-to-play pages; outdated ones rewritten once
        });
        boot_step('almanac_exploring_075', function () {
            if (version_compare((string)setting('db_version'), '0.7.75', '<') && isset(ALMANAC_HOWTO['Exploring & fighting'])) {   // v0.7.75: deep wilds and outgrown areas explained (v0.7.74 gentler exploring is in this text too)
                q("UPDATE encyclopedia_entries SET body = ? WHERE chapter = 'General' AND title = 'Exploring & fighting'", [ALMANAC_HOWTO['Exploring & fighting'][2]]);
            }
        });
        boot_step('almanac_exploring_081', function () {
            if (version_compare((string)setting('db_version'), '0.7.81', '<') && isset(ALMANAC_HOWTO['Exploring & fighting'])) {   // v0.7.81: axe and fishing rod lines (v0.7.77: ruins and repairs)
                q("UPDATE encyclopedia_entries SET body = ? WHERE chapter = 'General' AND title = 'Exploring & fighting'", [ALMANAC_HOWTO['Exploring & fighting'][2]]);
            }
        });
        boot_step('almanac_exploring_088', function () {
            if (version_compare((string)setting('db_version'), '0.7.88', '<') && isset(ALMANAC_HOWTO['Exploring & fighting'])) {   // v0.7.86 tool wear, v0.7.87 ruins are closed until repaired, v0.7.88 ruins are per gnome
                q("UPDATE encyclopedia_entries SET body = ? WHERE chapter = 'General' AND title = 'Exploring & fighting'", [ALMANAC_HOWTO['Exploring & fighting'][2]]);
            }
        });
        boot_step('almanac_perennials_086', function () {
            if (version_compare((string)setting('db_version'), '0.7.86', '<') && isset(ALMANAC_HOWTO['Perennials & lifespans'])) {   // v0.7.86: harvests cost energy by how rare the crop is
                q("UPDATE encyclopedia_entries SET body = ? WHERE chapter = 'General' AND title = 'Perennials & lifespans'", [ALMANAC_HOWTO['Perennials & lifespans'][2]]);
            }
        });
        boot_step('remove_old_pages', function () {
            foreach (['npc.php', 'mod.php'] as $gone) {   // v0.7.50: pages renamed in v0.7.44 (folk.php, modtools.php)
                if (is_file(APP_ROOT . '/' . $gone) && is_file(APP_ROOT . '/folk.php')) @unlink(APP_ROOT . '/' . $gone);
            }
        });
        boot_step('ensure_shop_food', function () {
            ensure_shop_food();      // shops sell "shop-bought" food worth less than home cooking (v0.7.27)
        });
        boot_step('strip_raw_food_energy', function () {
            if (version_compare((string)setting('db_version'), '0.7.86', '<')) {   // v0.7.86: only cooked food gives energy (raw crops, finds and bought copies lose it); repair pay
                require_once __DIR__ . '/catalog.php';
                strip_raw_food_energy();
                q('DELETE FROM settings WHERE name = ? AND value = ?', ['repair_stage_coins', '500']);   // the old default, unchanged by an admin: take the new one (300)
            }
        });
        boot_step('repair_coins_088', function () {
            if (version_compare((string)setting('db_version'), '0.7.88', '<')) {   // v0.7.88: stage pay is 200 (+10 a level); the old 300 default, unchanged by an admin, is taken
                q('DELETE FROM settings WHERE name = ? AND value = ?', ['repair_stage_coins', '300']);
            }
        });
        boot_step('region_medals_089', function () {
            if (version_compare((string)setting('db_version'), '0.7.89', '<')) {   // v0.7.89: region medals pay less (titles and loam stay); rows an admin changed are left alone
                foreach ([':bronze' => [500, 200], ':silver' => [1500, 500], ':gold' => [4000, 1500]] as $tier => [$old, $new]) {
                    q("UPDATE almanac_milestones SET reward_coins = ? WHERE kind = 'key' AND unlock_key LIKE ? AND reward_coins = ?", [$new, 'region:%' . $tier, $old]);
                }
            }
        });
        boot_step('xp_retune_091', function () {
            if (version_compare((string)setting('db_version'), '0.9.1', '<')) {   // v0.9.1: XP retune; old defaults left alone only if an admin changed them
                q('DELETE FROM settings WHERE name = ? AND value = ?', ['xp_steep_percent', '10']);
                q('DELETE FROM settings WHERE name = ? AND value = ?', ['repair_stage_xp', '120']);
                q('DELETE FROM settings WHERE name = ?', ['calling_change_cost']);   // gone: callings are locked now
                q("UPDATE users SET calling_free_change = 2 WHERE calling IS NOT NULL AND calling <> ''");   // gnomes who already had a calling keep one free change at any level
                setting('__reload__');
            }
        });
        boot_step('upgrade_shop_food_energy', function () {
            if (version_compare((string)setting('db_version'), '0.9.1.1', '<')) {   // v0.9.1a: shop-bought food gives 1-2 energy
                upgrade_shop_food_energy();
                foreach (q("SELECT id, label FROM town_actions WHERE slug LIKE '%-drink'")->fetchAll() as $ta) {   // "Order a acorn coffee" -> "Order an acorn coffee"
                    if (preg_match('/^Order a ([aeiou])/i', (string)$ta['label'])) q('UPDATE town_actions SET label = ? WHERE id = ?', [preg_replace('/^Order a /', 'Order an ', (string)$ta['label']), $ta['id']]);
                }
            }
        });
        boot_step('almanac_admire_090', function () {
            if (version_compare((string)setting('db_version'), '0.9.0', '<')) {   // v0.9.0: admiring is once per garden
                q("UPDATE encyclopedia_entries SET body = REPLACE(body, ?, ?) WHERE chapter = 'General'", ['and admire them once a day.', 'and admire each garden once.']);
            }
        });
        boot_step('almanac_games_089', function () {
            if (version_compare((string)setting('db_version'), '0.8.9', '<')) {   // v0.8.8: the Games page lists all seven games (only if it still has the old text)
                require_once __DIR__ . '/games.php';
                q("UPDATE encyclopedia_entries SET body = ? WHERE chapter = 'General' AND title = 'Games' AND body LIKE 'When the garden is growing on its own%' AND body NOT LIKE '%Mushroom%'", [GAMES_PAGE]);
            }
        });
        boot_step('almanac_till_087', function () {
            if (version_compare((string)setting('db_version'), '0.8.7', '<')) {   // v0.8.7: the till page mentions soil care stars
                q("UPDATE encyclopedia_entries SET body = REPLACE(body, ?, ?) WHERE chapter = 'General' AND title = 'Soil: till or no-till?'",
                    ['and you must till again after every harvest.', 'and you must till again after every harvest. Look after a tilled square and it earns soil care stars.']);
            }
        });
        boot_step('town_actions_090', function () {
            if (version_compare((string)setting('db_version'), '0.7.90', '<')) {   // v0.7.90: wishing wells, the koi and the pub quiz cost 1 energy
                q("UPDATE town_actions SET energy = 1 WHERE energy = 0 AND slug IN ('mm-wish', 'mm-quiz', 'dw-wish', 'br-feed')");
            }
        });
        boot_step('upgrade_094_cooking', function () {
            // ---- v0.9.4 cooking (chunks A, B, E): tiers, raw food energy, food scraps, compost heap outputs (see upgrade_094_cooking in catalog.php)
            if (version_compare((string)setting('db_version'), '0.9.4', '<')) {
                require_once __DIR__ . '/catalog.php';
                upgrade_094_cooking();
                upgrade_094_pots();   // v0.9.4 part 2: pots (cook_pots table is in schema.php), dead settings removed
            }
        });
        boot_step('upgrade_095_beds', function () {
            if (version_compare((string)setting('db_version'), '0.9.5', '<')) { require_once __DIR__ . '/garden_logic.php'; upgrade_095_beds(); }   // v0.9.5: Add 4 beds replaces expanding by row/column
        });
        boot_step('upgrade_095_yard', function () {
            if (version_compare((string)setting('db_version'), '0.9.5', '<')) upgrade_095_yard();   // v0.9.5: garden gate on sale, new Almanac lines on yard design
        });
        boot_step('upgrade_097_roads', function () {
            if ((string)setting('db_version') !== '' && version_compare((string)setting('db_version'), '0.9.7', '<')) upgrade_097_roads();   // v0.9.7 part A: easy roads switch, new creatures for regions 23-35 (roads.php is loaded above)
        });
        boot_step('ensure_ruins', function () {
            require_once __DIR__ . '/rebuild.php';
            ensure_ruins();          // v0.7.87: about 1 in 3 havens, wonders and delves start in ruins (once)
        });
        boot_step('ensure_climates', function () {
            require_once __DIR__ . '/climate.php';
            ensure_climates();       // v0.8.9: region climates with real effects
        });
        boot_step('energy_regen_seconds', function () {
            if (($oldRegen = q_val("SELECT value FROM settings WHERE name = 'energy_regen_minutes'")) !== false && $oldRegen !== null) {
                // v0.9.0: "minutes per energy" became "N energy every so many seconds"; keep the old pace (nearest choice)
                $sec = max(30, (int)$oldRegen * 60);
                $opts = [30, 60, 90, 120, 150, 180, 300];
                usort($opts, fn($a, $b) => abs($a - $sec) <=> abs($b - $sec));
                // (v0.8.9: a site still on the old default of 2 before 0.8.9 goes to Joshua's 1 a minute, the new default)
                if ($oldRegen !== '2' || version_compare((string)setting('db_version'), '0.8.9', '>=')) set_setting('energy_regen_seconds', (string)$opts[0]);
                q("DELETE FROM settings WHERE name = 'energy_regen_minutes'");
                setting('__reload__');
            }
        });
        boot_step('ensure_grow_times', function () {
            ensure_grow_times();     // shorter grow times, by rarity (v0.7.27)
        });
        boot_step('site_name', function () {
            if (setting('site_name') === 'Sproutling Hollow') set_setting('site_name', 'Gnome Venture');   // v0.7.36: the game's new name
        });
        boot_step('amend_hours', function () {
            q('DELETE FROM settings WHERE name = ?', ['amend_hours']);  // v0.7.51: renamed to amend_minutes (now minutes, not hours)
        });
        boot_step('amend_minutes_054', function () {
            if (version_compare((string)setting('db_version'), '0.7.54', '<')) q('DELETE FROM settings WHERE name = ?', ['amend_minutes']);   // v0.7.54: new default (10)
        });
        boot_step('ensure_amend_minutes', function () {
            ensure_amend_minutes();  // v0.7.54: every amendment 3–15 minutes
        });
        boot_step('npc_met_069', function () {
            if (version_compare((string)setting('db_version'), '0.7.69', '<')) {   // v0.7.69: everyone you've chatted with or given a gift to counts as met
                q('INSERT INTO user_npc_met (user_id, npc_id, first_at) SELECT f.user_id, f.npc_id, ? FROM npc_friends f
                   WHERE NOT EXISTS (SELECT 1 FROM user_npc_met m WHERE m.user_id = f.user_id AND m.npc_id = f.npc_id)', [now()]);
            }
        });
        boot_step('sell_mult_064', function () {
            if (version_compare((string)setting('db_version'), '0.7.64', '<')) {   // v0.7.64 balance pass
                foreach (['sell_mult_uncommon' => '140', 'sell_mult_rare' => '220', 'sell_mult_legendary' => '450'] as $k => $old) {
                    q('DELETE FROM settings WHERE name = ? AND value = ?', [$k, $old]);   // unchanged by the admin: take the new default
                }
            }
        });
        boot_step('smooth_creatures', function () {
            require_once __DIR__ . '/adventure_data.php';
            smooth_creatures();
        });
        boot_step('perennial_age_061', function () {
            if (version_compare((string)setting('db_version'), '0.7.61', '<')) {   // v0.7.61: perennials age from now, not from when they were first planted
                q('UPDATE plot_tiles SET planted_at = ? WHERE plant_id IN (SELECT id FROM plants WHERE perennial = 1)', [now()]);
            }
        });
        boot_step('roads_almanac_057', function () {
            require_once __DIR__ . '/roads.php';
            q("UPDATE encyclopedia_entries SET body = ? WHERE title = 'Roads and the wilds'", [ROADS_ALMANAC]);   // v0.7.57: roads stay at the region's level
        });
        boot_step('post_update_news', function () {
            require_once __DIR__ . '/update_news.php';
            if ((string)setting('db_version') !== '') post_update_news((string)setting('db_version'));   // v0.7.55: news post for players
        });
        // v1.2.2: steps that failed are listed for the admin (Dashboard); the version still moves on so pages don't re-run the chain
        $bootFailed = array_values(array_unique($GLOBALS['gv_boot_failed'] ?? []));
        if ($bootFailed) set_setting('boot_failed_steps', APP_VERSION . ': ' . implode(', ', $bootFailed));
        elseif (setting('boot_failed_steps') !== '') q('DELETE FROM settings WHERE name = ?', ['boot_failed_steps']);
        if (empty($GLOBALS['gv_migrate_errors'])) set_setting('db_version', APP_VERSION);   // a table/column that would not be made (see the error log) keeps the upgrade coming back until it is fixed
        setting('__reload__');
    } catch (Throwable $e) {
        try { if (db()->inTransaction()) db()->rollBack(); } catch (Throwable $e2) {}
        error_log('Auto-upgrade: ' . $e->getMessage());   // the next page load tries again; db_version only moves when everything else went through
        if (function_exists('game_error_log')) game_error_log('Auto-upgrade failed: ' . get_class($e) . ': ' . $e->getMessage() . ' in ' . basename($e->getFile()) . ':' . $e->getLine());
    }
}

market_boot();   // v1.0.0 wave 2b: the market Almanac page exists even where db_version was set by hand (a dev copy)

send_security_headers();
start_secure_session();

$CURRENT_USER = load_current_user();

require_once __DIR__ . '/emoji_icons.php';
ico_start();   // v2.0.23: one output pass swaps emoji for our icons in every HTML page (JSON, downloads, redirects are skipped inside it)

if (setting('maintenance_mode') === '1' && !is_admin() && !defined('ALLOW_DURING_MAINTENANCE')) {
    http_response_code(503);
    page_header('Closed for tending');
    echo '<div class="box"><h2>Closed for tending</h2><p>' . e(setting('maintenance_message')) . '</p></div>';
    page_footer();
    exit;
}
