<?php
declare(strict_types=1);
/**
 * Rest stops, v1.0.0 wave 1: "Every stop is somewhere."
 *
 * Every road village is a STOP TYPE (market hamlet, mill, inn, shrine, jetty, herb croft, workshop, orchard, ferry, watchtower,
 * hot spring, campfire). The type is worked out from the village's landscape (stable, never changes) unless the admin sets
 * locations.stop_type. Each type has a pool of ACTIVITIES (stop_acts: ~50 mini-choices with stat checks, trades, rests, tales and
 * tiny games). A visit has `stop_slots` slots (3): do up to three different things before you walk on.
 * Time matters: an activity can need a part of the day, a season or the weather (the Hollow clock, hollow_clock.php).
 * Everything is data (includes/data/stops.txt, stop_acts.txt, stop_tiers.txt, stop_sets.txt, stop_chat.txt), copied into tables on
 * upgrade_100_stops() and editable in Admin. Villagers, errands and friendship: stop_folk.php. Stamps: stop_pass.php. Adopt: stop_adopt.php.
 */

require_once __DIR__ . '/garden_logic.php';   // UserError, spend_energy
require_once __DIR__ . '/hollow_clock.php';
require_once __DIR__ . '/events.php';   // apply_event_effect (energy, buffs)

const STOP_DP_WORDS = ['dawn' => 'at dawn', 'day' => 'by day', 'dusk' => 'at dusk', 'night' => 'at night'];
const STOP_WEATHER_WORDS = ['sun' => 'sunny', 'cloud' => 'cloudy', 'rain' => 'rainy', 'storm' => 'stormy', 'frost' => 'frosty', 'heat' => 'hot', 'wind' => 'windy', 'fog' => 'foggy', 'snow' => 'snowy'];

// ---------------------------------------------------------------- schema

function stops100_schema(string $PK, string $ID, string $END): array
{
    $t = [];
    $t[] = "CREATE TABLE IF NOT EXISTS stop_types (
        id $PK,
        slug VARCHAR(20) NOT NULL UNIQUE,
        icon VARCHAR(12) NOT NULL DEFAULT '🪧',
        name VARCHAR(60) NOT NULL,
        hue INT NOT NULL DEFAULT 100,
        landscapes VARCHAR(190) NOT NULL DEFAULT 'any',
        roles VARCHAR(190) NOT NULL DEFAULT '',
        ambience TEXT NULL,
        intro TEXT NULL,
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_acts (
        id $PK,
        slug VARCHAR(40) NOT NULL UNIQUE,
        name VARCHAR(80) NOT NULL,
        icon VARCHAR(12) NOT NULL DEFAULT '✨',
        types VARCHAR(190) NOT NULL DEFAULT 'any',
        cond VARCHAR(190) NOT NULL DEFAULT '-',
        tier INT NOT NULL DEFAULT 0,
        kind VARCHAR(12) NOT NULL DEFAULT 'check',
        energy INT NOT NULL DEFAULT 0,
        spec TEXT NULL,
        win TEXT NULL,
        lose TEXT NULL,
        blurb TEXT NULL,
        line_win TEXT NULL,
        line_lose TEXT NULL,
        active INT NOT NULL DEFAULT 1
    )$END";
    // v2.0.78: progress that lasts between visits: a tended chore (per stop) or a collection (location_id 0 = the whole region)
    $t[] = "CREATE TABLE IF NOT EXISTS stop_prog (
        user_id $ID NOT NULL,
        location_id $ID NOT NULL,
        k VARCHAR(60) NOT NULL,
        n INT NOT NULL DEFAULT 0,
        data TEXT NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (user_id, location_id, k)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_log (
        id $PK,
        user_id $ID NOT NULL,
        location_id $ID NOT NULL,
        visit_key VARCHAR(25) NOT NULL,
        day VARCHAR(10) NOT NULL,
        act VARCHAR(40) NOT NULL,
        kind VARCHAR(12) NOT NULL DEFAULT 'check',
        note VARCHAR(190) NULL,
        at DATETIME NOT NULL,
        UNIQUE (user_id, location_id, visit_key, act)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_folk (
        id $PK,
        location_id $ID NOT NULL,
        slot INT NOT NULL DEFAULT 1,
        name VARCHAR(60) NOT NULL,
        species VARCHAR(40) NOT NULL DEFAULT 'Hedgehog',
        personality VARCHAR(20) NOT NULL DEFAULT 'Cheerful',
        role VARCHAR(40) NOT NULL DEFAULT '',
        bio TEXT NULL,
        active INT NOT NULL DEFAULT 1,
        UNIQUE (location_id, slot)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_friend (
        user_id $ID NOT NULL,
        folk_id $ID NOT NULL,
        points INT NOT NULL DEFAULT 0,
        talks INT NOT NULL DEFAULT 0,
        last_talk VARCHAR(10) NULL,
        gifts INT NOT NULL DEFAULT 0,
        PRIMARY KEY (user_id, folk_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_errands (
        id $PK,
        user_id $ID NOT NULL,
        folk_id $ID NOT NULL,
        kind VARCHAR(10) NOT NULL,
        item_id $ID NULL,
        qty INT NOT NULL DEFAULT 0,
        target_folk_id $ID NULL,
        coins INT NOT NULL DEFAULT 0,
        xp INT NOT NULL DEFAULT 0,
        status VARCHAR(10) NOT NULL DEFAULT 'active',
        offered_day VARCHAR(10) NOT NULL,
        expires_day VARCHAR(10) NOT NULL,
        done_at DATETIME NULL,
        created_at DATETIME NOT NULL,
        UNIQUE (user_id, folk_id, offered_day)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_stamps (
        user_id $ID NOT NULL,
        location_id $ID NOT NULL,
        first_at DATETIME NOT NULL,
        visits INT NOT NULL DEFAULT 1,
        PRIMARY KEY (user_id, location_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_sets (
        id $PK,
        scope VARCHAR(10) NOT NULL DEFAULT 'total',
        target VARCHAR(20) NOT NULL DEFAULT '',
        need INT NOT NULL DEFAULT 0,
        reward VARCHAR(190) NOT NULL DEFAULT '',
        title VARCHAR(60) NULL,
        label VARCHAR(120) NOT NULL DEFAULT '',
        active INT NOT NULL DEFAULT 1
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_set_claims (
        user_id $ID NOT NULL,
        set_id $ID NOT NULL,
        at DATETIME NOT NULL,
        PRIMARY KEY (user_id, set_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_tiers (
        id $PK,
        tier INT NOT NULL UNIQUE,
        name VARCHAR(60) NOT NULL,
        icon VARCHAR(12) NOT NULL DEFAULT '🪑',
        needs VARCHAR(190) NOT NULL DEFAULT '',
        gives TEXT NULL,
        plaque VARCHAR(190) NULL
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_tier_themes (
        id $PK,
        stop_type VARCHAR(20) NOT NULL,
        tier INT NOT NULL,
        name VARCHAR(60) NOT NULL,
        icon VARCHAR(12) NOT NULL DEFAULT '🪑',
        needs VARCHAR(190) NOT NULL DEFAULT '',
        gives TEXT NULL,
        plaque VARCHAR(190) NULL,
        UNIQUE (stop_type, tier)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS stop_adoptions (
        id $PK,
        location_id $ID NOT NULL UNIQUE,
        user_id $ID NULL,
        founder_id $ID NULL,
        tier INT NOT NULL DEFAULT 0,
        pool TEXT NULL,
        adopted_at DATETIME NOT NULL,
        perk_day VARCHAR(10) NULL
    )$END";
    $i = [
        'CREATE INDEX idx_stoplog_day ON stop_log (user_id, day)',
        'CREATE INDEX idx_stopfriend_folk ON stop_friend (folk_id)',
        'CREATE INDEX idx_stoperr_user ON stop_errands (user_id, status)',
        'CREATE INDEX idx_stopadopt_user ON stop_adoptions (user_id)',
        'CREATE INDEX idx_stoperr_target ON stop_errands (target_folk_id)',
        'CREATE UNIQUE INDEX uq_stopsets ON stop_sets (scope, target, need)',   // v1.0.0: the import is check-then-insert; this stops a double run duplicating the sets
    ];
    $c = [['locations', 'stop_type', 'VARCHAR(20) NULL'], ['stop_friend', 'last_gift', 'VARCHAR(10) NULL'], ['stop_acts', 'region', 'VARCHAR(80) NULL']];   // v2.0.78: region = comma list of region codes the activity belongs to (blank = anywhere)   // v2.0.77: last_gift = one gift a day per villager   // v1.0.0: admin-set stop type (blank = worked out from the landscape)
    return [$t, $i, $c];
}

// ---------------------------------------------------------------- data

/** Lines of a stops data file: pipe-separated, # comments. */
function stops_file_rows(string $file): array
{
    $out = [];
    $path = __DIR__ . '/data/' . $file;
    if (!is_file($path)) return $out;
    foreach (file($path, FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $out[] = array_map('trim', explode('|', $line));
    }
    return $out;
}

/** Copy the data files into the tables (adds what is missing; never overwrites an admin's edit). Returns rows added. */
function stops_import_data(): int
{
    $n = 0;
    foreach (stops_file_rows('stops.txt') as $r) {
        if (count($r) < 8 || q_val('SELECT 1 FROM stop_types WHERE slug = ?', [$r[0]])) continue;
        db_insert('stop_types', ['slug' => $r[0], 'icon' => $r[1], 'name' => $r[2], 'hue' => (int)$r[3], 'landscapes' => $r[4], 'roles' => $r[5], 'ambience' => $r[6], 'intro' => $r[7]]);
        $n++;
    }
    foreach (stops_file_rows('stop_acts.txt') as $r) {
        if (count($r) < 12 || q_val('SELECT 1 FROM stop_acts WHERE slug = ?', [$r[0]])) continue;
        db_insert('stop_acts', ['slug' => $r[0], 'name' => $r[1], 'icon' => $r[2], 'types' => $r[3], 'cond' => $r[4], 'tier' => (int)$r[5], 'kind' => $r[6], 'energy' => (int)$r[7],
            'spec' => $r[8], 'win' => $r[9], 'lose' => $r[10], 'blurb' => $r[11], 'line_win' => $r[12] ?? '', 'line_lose' => $r[13] ?? '']);
        $n++;
    }
    foreach (stops_file_rows('stop_tiers.txt') as $r) {
        if (count($r) < 6 || q_val('SELECT 1 FROM stop_tiers WHERE tier = ?', [(int)$r[0]])) continue;
        db_insert('stop_tiers', ['tier' => (int)$r[0], 'name' => $r[1], 'icon' => $r[2], 'needs' => $r[3], 'gives' => $r[4], 'plaque' => $r[5]]);
        $n++;
    }
    $n += stops_import_themes();
    $n += stops_import_regional();
    foreach (stops_file_rows('stop_sets.txt') as $r) {
        if (count($r) < 6 || q_val('SELECT 1 FROM stop_sets WHERE scope = ? AND target = ? AND need = ?', [$r[0], $r[1], (int)$r[2]])) continue;
        try { db_insert('stop_sets', ['scope' => $r[0], 'target' => $r[1], 'need' => (int)$r[2], 'reward' => $r[3], 'title' => $r[4] !== '' ? $r[4] : null, 'label' => $r[5]]); $n++; }
        catch (PDOException $e) { /* made by another request */ }
    }
    // one set per region: every road stop of the region
    foreach (q('SELECT code, gnomish_name FROM regions ORDER BY id')->fetchAll() as $rg) {
        if (q_val("SELECT 1 FROM stop_sets WHERE scope = 'region' AND target = ?", [$rg['code']])) continue;
        try { db_insert('stop_sets', ['scope' => 'region', 'target' => $rg['code'], 'need' => 0, 'reward' => 'c=250,xp=40,item=rope:2', 'title' => 'Rambler of ' . $rg['gnomish_name'], 'label' => 'Every rest stop in ' . $rg['gnomish_name']]); $n++; }
        catch (PDOException $e) { /* made by another request */ }
    }
    return $n;
}

/**
 * v2.0.77: the themed upgrades (stop_tier_themes.txt + the tt_ activities in stop_acts.txt). Adds what is missing, then (once) switches
 * off the plain bench / stall / well / table. Runs on fresh installs (stops_import_data) and once on upgrade (boot step stop_themes).
 */
function stops_import_themes(): int
{
    $n = 0;
    foreach (stops_file_rows('stop_acts.txt') as $r) {
        if (!str_starts_with($r[0], 'tt_') || count($r) < 12 || q_val('SELECT 1 FROM stop_acts WHERE slug = ?', [$r[0]])) continue;
        db_insert('stop_acts', ['slug' => $r[0], 'name' => $r[1], 'icon' => $r[2], 'types' => $r[3], 'cond' => $r[4], 'tier' => (int)$r[5], 'kind' => $r[6], 'energy' => (int)$r[7],
            'spec' => $r[8], 'win' => $r[9], 'lose' => $r[10], 'blurb' => $r[11], 'line_win' => $r[12] ?? '', 'line_lose' => $r[13] ?? '']);
        $n++;
    }
    foreach (stops_file_rows('stop_tier_themes.txt') as $r) {   // v2.0.77 themed upgrades per kind of stop
        if (count($r) < 7 || q_val('SELECT 1 FROM stop_tier_themes WHERE stop_type = ? AND tier = ?', [$r[0], (int)$r[1]])) continue;
        try { db_insert('stop_tier_themes', ['stop_type' => $r[0], 'tier' => (int)$r[1], 'name' => $r[2], 'icon' => $r[3], 'needs' => $r[4], 'gives' => $r[5], 'plaque' => $r[6]]); $n++; }
        catch (PDOException $e) { /* made by another request */ }
    }
    if (setting('stop_themes_v1') !== '1') {   // v2.0.77: the plain bench / stall / well / table give way to the themed ones (once; an admin can switch them back on)
        q("UPDATE stop_acts SET active = 0 WHERE slug IN ('bench_rest', 'trader_stall', 'wishing_well', 'long_table')");
        q("DELETE FROM settings WHERE name = 'stop_themes_v1'");
        db_insert('settings', ['name' => 'stop_themes_v1', 'value' => '1']);
        stop_acts(true);
    }
    stop_acts(true);
    return $n;
}

/** v2.0.78: the regional activities (stop_acts_regional.txt) and the content waves (stop_acts_waves.txt): same columns as stop_acts.txt plus a region code list (blank = any region). Adds what is missing. */
function stops_import_regional(): int
{
    $n = 0;
    foreach (array_merge(stops_file_rows('stop_acts_regional.txt'), stops_file_rows('stop_acts_waves.txt')) as $r) {
        if (count($r) < 12 || q_val('SELECT 1 FROM stop_acts WHERE slug = ?', [$r[0]])) continue;
        try {
            db_insert('stop_acts', ['slug' => $r[0], 'name' => $r[1], 'icon' => $r[2], 'types' => $r[3], 'cond' => $r[4], 'tier' => (int)$r[5], 'kind' => $r[6], 'energy' => (int)$r[7],
                'spec' => $r[8], 'win' => $r[9], 'lose' => $r[10], 'blurb' => $r[11], 'line_win' => $r[12] ?? '', 'line_lose' => $r[13] ?? '', 'region' => ($r[14] ?? '') !== '' ? $r[14] : null]);
            $n++;
        } catch (PDOException $e) { /* made by another request */ }
    }
    stop_acts(true);
    return $n;
}

/** @return array<string, array> stop types by slug (active only) */
function stop_types(bool $reload = false): array
{
    static $cache = null;
    if ($cache === null || $reload) {
        $cache = [];
        foreach (q('SELECT * FROM stop_types WHERE active = 1 ORDER BY id')->fetchAll() as $r) $cache[$r['slug']] = $r;
    }
    return $cache;
}

/** @return array<string, array> activities by slug (active only) */
function stop_acts(bool $reload = false): array
{
    static $cache = null;
    if ($cache === null || $reload) {
        $cache = [];
        foreach (q('SELECT * FROM stop_acts WHERE active = 1 ORDER BY id')->fetchAll() as $r) $cache[$r['slug']] = $r;
    }
    return $cache;
}

function stop_region_code(array $loc): string
{
    static $codes = [];
    $rid = (int)($loc['region_id'] ?? 0);
    if (!$rid) return '';
    return $codes[$rid] ??= (string)q_val('SELECT code FROM regions WHERE id = ?', [$rid]);
}

// ---------------------------------------------------------------- stop types

/** Work out a village's type from its landscape and name: stable. $avoid = types already used by its neighbours (tried last). */
function stop_derive_type(array $loc, array $avoid = [], array $counts = []): string
{
    $types = stop_types();
    if (!$types) return 'camp';
    $land = (string)($loc['landscape'] ?? '');
    $fit = [];
    foreach ($types as $slug => $t) {
        $ls = array_map('trim', explode(',', (string)$t['landscapes']));
        $w = in_array($land, $ls, true) || in_array('any', $ls, true) ? 3 : 0;
        if ($w > 0) $fit[$slug] = $w;
    }
    if (!$fit) $fit = array_fill_keys(array_keys($types), 1);
    // weighted order from the name: highest hash-weighted score first
    $score = [];
    foreach ($fit as $slug => $w) $score[$slug] = ((crc32('stop|' . $loc['slug'] . '|' . $slug) % 1000) + 1) * $w / (1 + 0.5 * ($counts[$slug] ?? 0));
    arsort($score);
    foreach (array_keys($score) as $slug) if (!in_array($slug, $avoid, true)) return $slug;
    return (string)array_key_first($score);
}

/** The type of a stop: the admin's choice, or the stored/derived one. */
function stop_type_of(array $loc): string
{
    $types = stop_types();
    $t = (string)($loc['stop_type'] ?? '');
    if ($t !== '' && isset($types[$t])) return $t;
    return stop_derive_type($loc);
}

/** Header art for a stop type: scenes/stop-<type>.png, or the market hamlet's picture when that type has no file (e.g. a type added in Admin). '' if neither exists. */
function stop_art_file(string $type): string
{
    $dir = __DIR__ . '/../assets/img/scenes/';
    if (preg_match('/^[a-z0-9_-]+$/', $type) && is_file($dir . 'stop-' . $type . '.png')) return 'stop-' . $type . '.png';
    return is_file($dir . 'stop-market.png') ? 'stop-market.png' : '';
}

/** v2.0.67: picture names for the Do-tab felt cards (assets/img/acts/act-<name>.png): one per activity kind, a few activities get a closer one. */
const STOP_ACT_ART_KIND = ['rest' => 'rest', 'check' => 'hand', 'pick' => 'shells', 'power' => 'ringtoss', 'lore' => 'story', 'gossip' => 'chat',
    'seedswap' => 'seeds', 'swap' => 'swap', 'buy' => 'basket', 'snack' => 'basket',
    'craft' => 'craft', 'collect' => 'collect', 'tend' => 'tend', 'contest' => 'contest'];   // v2.0.78: PLACEHOLDER pictures until drawn (claude/todo-art-variety.md)
const STOP_ACT_ART_SLUG = ['firewood' => 'fire', 'signal_fire' => 'fire', 'cast_a_line' => 'rod', 'night_fishing' => 'rod', 'ice_hole' => 'rod', 'oar_ferry' => 'rod',
    'pick_herbs' => 'forage', 'mushroom_rain' => 'forage', 'moss_tend' => 'forage', 'blossom_walk' => 'forage', 'saw_planks' => 'axe', 'dress_stone' => 'pick',
    'chores' => 'basket', 'porter' => 'basket', 'drying_day' => 'basket', 'shake_tree' => 'basket', 'notice_riddle' => 'chat', 'toll_talk' => 'chat', 'haggle' => 'chat',
    'rainy_stories' => 'story', 'wishing_well' => 'bucket', 'make_wish' => 'bucket', 'skim_stones' => 'ringtoss'];

/** Card art for a stop activity: the activity's own picture, else its kind's, else the generic signpost. Returns a path from the web root ('' only if even the fallback is gone). */
function stop_act_art(string $kind, string $slug = ''): string
{
    $dir = __DIR__ . '/../assets/img/acts/';
    foreach ([preg_match('/^[a-z0-9_]+$/', $slug) ? $slug : '', STOP_ACT_ART_SLUG[$slug] ?? '', STOP_ACT_ART_KIND[$kind] ?? '', 'any'] as $n) {   // v2.0.78: an activity's own picture is act-<slug>.png, drop it in and it is used
        if ($n !== '' && is_file($dir . 'act-' . $n . '.png')) return 'assets/img/acts/act-' . $n . '.png';
    }
    return '';
}

/** v2.0.82: the popover's animation strip for an activity: act-<name>-anim.png along the same fallback chain as stop_act_art(). '' unless the file exists. */
function stop_act_anim(string $kind, string $slug = ''): string
{
    $dir = __DIR__ . '/../assets/img/acts/';
    foreach ([preg_match('/^[a-z0-9_]+$/', $slug) ? $slug : '', STOP_ACT_ART_SLUG[$slug] ?? '', STOP_ACT_ART_KIND[$kind] ?? '', 'any'] as $n) {
        if ($n !== '' && is_file($dir . 'act-' . $n . '-anim.png')) return 'assets/img/acts/act-' . $n . '-anim.png';
    }
    return '';
}

/** Fill locations.stop_type for every village that has none, so that neighbours in a zone differ where they can. Returns how many. */
function stop_assign_all(): int
{
    $n = 0;
    $used = [];
    $counts = [];
    $road = array_fill_keys(array_map('intval', q("SELECT a_id FROM routes WHERE kind = 'road' UNION SELECT b_id FROM routes WHERE kind = 'road'")->fetchAll(PDO::FETCH_COLUMN)), true);
    $rows = q("SELECT * FROM locations WHERE kind = 'village' ORDER BY zone_id, sort_order, id")->fetchAll();
    usort($rows, fn($a, $b) => (isset($road[(int)$b['id']]) ? 1 : 0) <=> (isset($road[(int)$a['id']]) ? 1 : 0));   // road stops first: they are the ones that get balanced (stable sort keeps the order)
    foreach ($rows as $v) {
        $z = (int)$v['zone_id'];
        if (!empty($v['stop_type']) && isset(stop_types()[$v['stop_type']])) { $used[$z][] = $v['stop_type']; $counts[$v['stop_type']] = ($counts[$v['stop_type']] ?? 0) + 1; continue; }
        $t = stop_derive_type($v, $used[$z] ?? [], $counts);
        $used[$z][] = $t;
        $counts[$t] = ($counts[$t] ?? 0) + 1;
        q('UPDATE locations SET stop_type = ? WHERE id = ?', [$t, $v['id']]);
        $n++;
    }
    return $n;
}

// ---------------------------------------------------------------- time

/** What the Hollow is like at this stop right now: ['dp' => , 'se' => , 'we' => ]. setting stop_daypart_force is for testing. */
function stop_now(array $loc): array
{
    $rc = stop_region_code($loc);
    $force = setting('stop_daypart_force');
    $dp = isset(HOLLOW_DAYPARTS[$force]) ? $force : hollow_daypart();
    return ['dp' => $dp, 'se' => hollow_season(), 'we' => hollow_weather($rc !== '' ? $rc : null)];
}

/** "dp=night,dusk/se=winter" => ['dp' => ['night','dusk'], 'se' => ['winter']] */
function stop_cond_parse(string $cond): array
{
    $out = [];
    if (trim($cond) === '' || trim($cond) === '-') return $out;
    foreach (explode('/', $cond) as $part) {
        [$k, $v] = array_pad(explode('=', trim($part), 2), 2, '');
        if (in_array($k, ['dp', 'se', 'we'], true) && $v !== '') $out[$k] = array_values(array_filter(array_map('trim', explode(',', $v))));
    }
    return $out;
}

function stop_cond_ok(string $cond, array $now): bool
{
    foreach (stop_cond_parse($cond) as $k => $vals) {
        if (!in_array($now[$k] ?? '', $vals, true)) return false;
    }
    return true;
}

/** "at night, in winter" for a condition. */
function stop_cond_text(string $cond): string
{
    $bits = [];
    foreach (stop_cond_parse($cond) as $k => $vals) {
        if ($k === 'dp') $bits[] = implode(' or ', array_map(fn($v) => STOP_DP_WORDS[$v] ?? $v, $vals));
        elseif ($k === 'se') $bits[] = 'in ' . implode(' or ', $vals);
        else $bits[] = 'when it’s ' . implode(' or ', array_map(fn($v) => STOP_WEATHER_WORDS[$v] ?? $v, $vals));
    }
    return implode(', ', $bits);
}

// ---------------------------------------------------------------- what is on offer

function stop_slots(array $loc): int
{
    require_once __DIR__ . '/stop_adopt.php';
    return max(1, min(9, (int)setting('stop_slots') + (stop_tier((int)$loc['id']) >= 4 ? 1 : 0)));
}

/**
 * v2.0.78: take $n from an ordered list, but prefer a kind not yet taken (or in $kinds): the first of each new kind in order, then fill
 * up from what is left in order. Same ordering rules as before, so nothing is skipped for good: it only avoids two of a kind in a row of picks.
 */
function stop_diverse(array $list, int $n, array $kinds): array
{
    $out = [];
    $left = array_values($list);
    while (count($out) < $n && $left) {
        $pick = null;
        foreach ($left as $i => $a) if (!in_array($a['kind'], $kinds, true)) { $pick = $i; break; }
        if ($pick === null) { $kinds = []; $pick = 0; }   // every kind is used: start over
        $a = $left[$pick];
        array_splice($left, $pick, 1);
        $out[] = $a;
        $kinds[] = $a['kind'];
    }
    return $out;
}

/**
 * The activities at a stop right now.
 * ['offer' => [act rows, in order, with ['now' => bool special]], 'later' => [act rows that need another time], 'tiers' => [act rows from upgrades still to build]]
 */
function stop_pool(array $loc, ?array $now = null): array
{
    require_once __DIR__ . '/stop_adopt.php';
    $now ??= stop_now($loc);
    $type = stop_type_of($loc);
    $region = stop_region_code($loc);
    $tier = stop_tier((int)$loc['id']);
    $day = hollow_date('Y-m-d');
    $plain = $special = $later = $upgrades = $lockedUp = [];
    foreach (stop_acts() as $slug => $a) {
        $ts = array_map('trim', explode(',', (string)$a['types']));
        $explicit = in_array($type, $ts, true);
        if (!$explicit && !in_array('any', $ts, true)) continue;
        $rg = array_filter(array_map('trim', explode(',', (string)($a['region'] ?? ''))));   // v2.0.78: a regional activity only in its region, and it counts as "of this place" (picked first)
        if ($rg) {
            if (!in_array($region, $rg, true)) continue;
            $explicit = true;
        }
        $gated = stop_cond_parse((string)$a['cond']) !== [];
        if ((int)$a['tier'] > 0) {
            if ((int)$a['tier'] <= $tier) { if (!$gated || stop_cond_ok((string)$a['cond'], $now)) $upgrades[] = $a; else $later[] = $a; }
            else $lockedUp[] = $a;
            continue;
        }
        if ($gated) {
            if (stop_cond_ok((string)$a['cond'], $now)) { $a['now'] = true; $special[] = $a; } else $later[] = $a;
            continue;
        }
        $a['explicit'] = $explicit;
        $plain[] = $a;
    }
    // fixed core first (type-specific before "any"), then a daily rotation from the rest
    usort($plain, fn($x, $y) => [$x['explicit'] ? 0 : 1, crc32('core|' . $loc['slug'] . '|' . $x['slug'])] <=> [$y['explicit'] ? 0 : 1, crc32('core|' . $loc['slug'] . '|' . $y['slug'])]);
    $core = stop_diverse($plain, max(1, (int)setting('stop_core')), []);   // v2.0.78: different kinds of thing where there are some
    $used = array_column($core, 'slug');
    $rest = array_values(array_filter($plain, fn($a) => !in_array($a['slug'], $used, true)));
    usort($rest, fn($x, $y) => crc32('day|' . $day . '|' . $loc['slug'] . '|' . $x['slug']) <=> crc32('day|' . $day . '|' . $loc['slug'] . '|' . $y['slug']));
    $extra = stop_diverse($rest, max(0, (int)setting('stop_extra')), array_column($core, 'kind'));
    usort($special, fn($x, $y) => crc32('sp|' . $day . $loc['slug'] . $x['slug']) <=> crc32('sp|' . $day . $loc['slug'] . $y['slug']));
    $special = array_slice($special, 0, 3);
    return ['offer' => array_merge($special, $core, $extra, $upgrades), 'later' => $later, 'tiers' => $lockedUp];
}

/** What's been done: [slugs this visit, number today at this stop, number today anywhere, rests today anywhere]. */
function stop_state(int $uid, int $locId, string $visit): array
{
    $day = hollow_date('Y-m-d');
    $done = q('SELECT act FROM stop_log WHERE user_id = ? AND location_id = ? AND visit_key = ?', [$uid, $locId, $visit])->fetchAll(PDO::FETCH_COLUMN);
    $here = (int)q_val('SELECT COUNT(*) FROM stop_log WHERE user_id = ? AND location_id = ? AND day = ?', [$uid, $locId, $day]);
    $all = (int)q_val('SELECT COUNT(*) FROM stop_log WHERE user_id = ? AND day = ?', [$uid, $day]);
    $rests = (int)q_val("SELECT COUNT(*) FROM stop_log WHERE user_id = ? AND day = ? AND kind = 'rest'", [$uid, $day]);
    return [$done, $here, $all, $rests];
}

/** A visit starts each time you arrive somewhere. */
function stop_visit_key(array $u): string
{
    return (string)($u['arrived_at'] ?? '') ?: 'first';
}

/** How rewards scale: the place's level. */
function stop_level(array $loc): int
{
    require_once __DIR__ . '/progression.php';
    return location_min_level((int)$loc['id']);
}

// ---------------------------------------------------------------- rewards

/** Edible crops of a stop's region: item rows. */
function stop_local_crops(array $loc): array
{
    static $cache = [];
    $rid = (int)$loc['region_id'];
    return $cache[$rid] ??= q("SELECT DISTINCT i.id, i.name, i.base_price FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id JOIN items i ON i.id = p.produce_item_id
               WHERE pr.region_id = ? AND i.edible = 1 ORDER BY i.id", [$rid])->fetchAll();
}

/** A random gatherable (item row) for the stop's landscape; $tool limits it (rod = fish). */
function stop_random_find(array $loc, string $tool = ''): ?array
{
    $land = (string)$loc['landscape'];
    $rows = q("SELECT i.id, i.name, g.landscapes, g.rarity, g.tool FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.active = 1" . ($tool !== '' ? ' AND g.tool = ?' : ''), $tool !== '' ? [$tool] : [])->fetchAll();
    $fit = array_values(array_filter($rows, fn($r) => $r['landscapes'] === 'any' || in_array($land, array_map('trim', explode(',', (string)$r['landscapes'])), true)));
    if (!$fit) $fit = $rows;
    if (!$fit) return null;
    $common = array_values(array_filter($fit, fn($r) => $r['rarity'] === 'common'));
    $pool = ($common && random_int(1, 100) <= 80) ? $common : $fit;
    return $pool[random_int(0, count($pool) - 1)];
}

/** One of the hidden places near here that the gnome doesn't know yet: tells them. Returns the line. */
function stop_reveal_hidden(int $uid, array $loc): string
{
    require_once __DIR__ . '/roads.php';
    $hidden = [];
    foreach (q("SELECT * FROM locations WHERE region_id = ? AND kind IN ('village', 'haven', 'wonder', 'lair') ORDER BY id", [(int)$loc['region_id']])->fetchAll() as $h) {
        if (!on_road((int)$h['id']) && !place_known($uid, $h)) $hidden[] = $h;
    }
    $gentle = array_values(array_filter($hidden, fn($h) => $h['kind'] !== 'lair'));   // lairs only once there's nothing else to tell
    if ($gentle) $hidden = $gentle;
    if (!$hidden) return 'You already know every hidden place around here.';
    $h = $hidden[random_int(0, count($hidden) - 1)];
    $anchor = q_val("SELECT l.name FROM routes r JOIN locations l ON l.id = r.a_id WHERE r.kind = 'side' AND r.b_id = ? LIMIT 1", [$h['id']]);
    unlock_entries($uid, ($h['kind'] === 'village' ? 'village:' : 'landmark:') . $h['slug']);
    return 'You now know the way to ' . $h['name'] . ': ' . ($anchor ? 'take the side path from ' . $anchor . '.' : 'look for its side path off the road.');
}

/**
 * Hand out the rewards in $spec ("c=8:3,xp=4:1,item=rope:1@20,fp=1"). $f scales coins and XP (a near miss). Returns short lines.
 * Rolls run inside the caller's transaction.
 */
function stop_rewards(array $u, array $loc, string $spec, float $f = 1.0, string $folkSeed = ''): array
{
    $uid = (int)$u['id'];
    $lvl = stop_level($loc);
    $pct = max(0, (int)setting('stop_reward_percent')) / 100;
    if (!empty($GLOBALS['gv_stop_tired'])) $pct /= 2;   // v1.4.9: tired villagers after a long day of rest stops
    $lines = [];
    foreach (array_filter(array_map('trim', explode(',', $spec))) as $tok) {
        $chance = 100;
        if (str_contains($tok, '@')) { [$tok, $c] = explode('@', $tok, 2); $chance = (int)$c; }
        if ($chance < 100 && random_int(1, 100) > $chance) continue;
        [$k, $v] = array_pad(explode('=', $tok, 2), 2, '');
        $p = explode(':', $v);
        switch ($k) {
            case 'c':
                $n = (int)round(((int)$p[0] + (int)($p[1] ?? 0) * $lvl) * $pct * $f);
                if ($n > 0) { q('UPDATE users SET coins = coins + ? WHERE id = ?', [$n, $uid]); $lines[] = '+' . $n . ' ' . setting('currency_name'); }
                break;
            case 'xp':
                $n = (int)round(((int)$p[0] + (int)($p[1] ?? 0) * $lvl) * $pct * $f);
                if ($n > 0) { add_xp($uid, $n, 'rest_stop'); $lines[] = '+' . $n . ' XP'; }
                break;
            case 'en':
                $n = (int)$p[0];
                if ($n > 0) { apply_event_effect(q_one('SELECT * FROM users WHERE id = ?', [$uid]), 'energy:' . $n); $lines[] = '+' . $n . ' energy'; }
                break;
            case 'item':
                $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$p[0] ?? '']);
                $qty = max(1, (int)($p[1] ?? 1));
                if ($id && give_item($uid, $id, $qty)) $lines[] = '+' . $qty . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$id]);
                break;
            case 'crop':
                $crops = stop_local_crops($loc);
                for ($i = 0; $crops && $i < max(1, (int)$p[0]); $i++) { $it = $crops[random_int(0, count($crops) - 1)]; give_item($uid, (int)$it['id'], 1); $lines[] = '+1 × ' . $it['name']; }
                break;
            case 'find':
            case 'fish':
                for ($i = 0; $i < max(1, (int)$p[0]); $i++) {
                    $it = stop_random_find($loc, $k === 'fish' ? 'rod' : '') ?? stop_random_find($loc);
                    if ($it) { give_item($uid, (int)$it['id'], 1); $lines[] = '+1 × ' . $it['name']; }
                }
                break;
            case 'seed':
                $seeds = q("SELECT DISTINCT p.seed_item_id FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id WHERE pr.region_id = ? AND pr.tier IN ('staple', 'uncommon', 'flower')", [(int)$loc['region_id']])->fetchAll(PDO::FETCH_COLUMN);
                if ($seeds) { $sid = (int)$seeds[random_int(0, count($seeds) - 1)]; give_item($uid, $sid, 1); $lines[] = '+1 × ' . q_val('SELECT name FROM items WHERE id = ?', [$sid]); }
                break;
            case 'buff':
                $res = apply_event_effect(q_one('SELECT * FROM users WHERE id = ?', [$uid]), 'buff:' . implode(':', $p));
                foreach ($res as $r) $lines[] = $r;
                break;
            case 'fp':
                require_once __DIR__ . '/stop_folk.php';
                $folk = stop_pick_folk($uid, $loc, $folkSeed);
                if ($folk) { stop_friend_add($uid, (int)$folk['id'], max(1, (int)$p[0])); $lines[] = '💛 ' . $folk['name'] . ' likes you a little more'; }
                break;
            case 'reveal':
                $lines[] = stop_reveal_hidden($uid, $loc);
                break;
        }
    }
    return $lines;
}

/** Replace {folk} and {place} in a line. */
function stop_say(string $t, array $loc, ?array $folk): string
{
    return str_replace(['{folk}', '{place}'], [$folk['name'] ?? 'a villager', $loc['name']], $t);
}

/** d20 + modifier against a difficulty (0 = always works). Luck gives a second roll. Returns [success, roll, chance%]. */
function stop_check(array $u, string $stat, int $dc): array
{
    $mod = eff_mod($u, $stat);
    $chance = $dc <= 0 ? 100 : max(5, min(95, (21 - ($dc - $mod)) * 5));
    if ($dc <= 0) return [true, 20, 100, $mod];
    $roll = random_int(1, 20);
    $ok = $roll + $mod >= $dc;
    if (!$ok && luck_roll($u)) { $roll = random_int(1, 20); $ok = $roll + $mod >= $dc; }
    return [$ok, $roll, $chance, $mod];
}

function stop_chance_word(int $pct): string
{
    return $pct >= 75 ? 'easy' : ($pct >= 45 ? 'fair' : 'hard');
}

/** The ring toss peg for this visit: roughly hinted, exactly hidden. */
function stop_peg(int $locId, string $slug, int $n): int
{
    $_SESSION['stop_peg'][$locId][$slug] ??= random_int(1, $n);
    return (int)$_SESSION['stop_peg'][$locId][$slug];
}

function stop_spec_params(string $spec): array
{
    $out = [];
    foreach (explode(';', $spec) as $p) { [$k, $v] = array_pad(explode('=', trim($p), 2), 2, ''); if ($k !== '') $out[$k] = $v; }
    return $out;
}

// ---------------------------------------------------------------- progress that lasts (v2.0.78)

/** One progress row: [n, data array]. $locId 0 = region-wide (a collection). */
function stop_prog_get(int $uid, int $locId, string $k): array
{
    $r = q_one('SELECT n, data FROM stop_prog WHERE user_id = ? AND location_id = ? AND k = ?', [$uid, $locId, $k]);
    return $r ? [(int)$r['n'], json_decode((string)$r['data'], true) ?: []] : [0, []];
}

function stop_prog_set(int $uid, int $locId, string $k, int $n, array $data = []): void
{
    $json = $data ? json_encode($data, JSON_UNESCAPED_UNICODE) : null;
    if (q('UPDATE stop_prog SET n = ?, data = ?, updated_at = ? WHERE user_id = ? AND location_id = ? AND k = ?', [$n, $json, now(), $uid, $locId, $k])->rowCount() === 1) return;
    try { db_insert('stop_prog', ['user_id' => $uid, 'location_id' => $locId, 'k' => $k, 'n' => $n, 'data' => $json, 'updated_at' => now()]); }
    catch (PDOException $e) { q('UPDATE stop_prog SET n = ?, data = ?, updated_at = ? WHERE user_id = ? AND location_id = ? AND k = ?', [$n, $json, now(), $uid, $locId, $k]); }
}

/** The parts of a craft spec "a:2,b:1>out:1": [[slug, qty] inputs, [slug, qty] output]. */
function stop_craft_parts(string $spec): array
{
    [$in, $out] = array_pad(explode('>', $spec, 2), 2, '');
    $ins = [];
    foreach (array_filter(array_map('trim', explode(',', $in))) as $p) { [$sl, $q] = array_pad(explode(':', $p), 2, '1'); $ins[] = [$sl, max(1, (int)$q)]; }
    [$os, $oq] = array_pad(explode(':', trim($out)), 2, '1');
    return [$ins, [$os, max(1, (int)$oq)]];
}

/** A collection spec: [set slug, label, entries[], spots n, done rewards]. */
function stop_collect_parts(string $spec): array
{
    $p = stop_spec_params($spec);
    return [(string)($p['set'] ?? 'set'), (string)($p['label'] ?? 'finds'), array_values(array_filter(array_map('trim', explode('/', (string)($p['items'] ?? ''))))),
            max(2, min(6, (int)($p['n'] ?? 3))), (string)($p['done'] ?? '')];
}

// ---------------------------------------------------------------- doing things

/** Do one activity. $in = the posted form. Returns [ok, message]. */
function stop_do(array $u, array $loc, string $slug, array $in): array
{
    $uid = (int)$u['id'];
    if (($loc['kind'] ?? '') !== 'village') return [false, 'There’s nothing like that here.'];
    $acts = stop_acts();
    $a = $acts[$slug] ?? null;
    if (!$a) return [false, 'There’s nothing like that here.'];
    $pool = stop_pool($loc);
    $offered = array_column($pool['offer'], null, 'slug');
    if (!isset($offered[$slug])) return [false, 'That isn’t on offer here right now.'];
    $visit = stop_visit_key($u);
    [$done, $here, $all, $rests] = stop_state($uid, (int)$loc['id'], $visit);
    if (in_array($slug, $done, true)) return [false, 'You’ve done that already on this visit.'];
    if (count($done) >= stop_slots($loc)) return [false, 'You’ve done all you can on this visit. Walk on and come back for another go!'];
    if ($here >= max(1, (int)setting('stop_daily_cap'))) return [false, 'The villagers have seen plenty of you today. Come back tomorrow!'];
    // v1.4.9: no daily total any more; after stop_daily_total things in a day, Petals and XP are halved (stop_rewards)
    $kind = (string)$a['kind'];
    if ($kind === 'rest' && $rests >= max(0, (int)setting('stop_rest_daily'))) return [false, 'You’ve rested plenty today. A rest stop can only do so much for tired feet!'];
    $folk = null;
    require_once __DIR__ . '/stop_folk.php';
    $seed = $uid . '|' . $loc['id'] . '|' . hollow_date('Y-m-d') . '|' . $slug;
    $folk = stop_pick_folk($uid, $loc, $seed);
    $energy = max(0, (int)$a['energy']);
    $day = hollow_date('Y-m-d');
    $cur = setting('currency_name');
    $win = (string)$a['win'];
    $lose = (string)$a['lose'];
    $lineWin = stop_say((string)$a['line_win'], $loc, $folk);
    $lineLose = stop_say((string)$a['line_lose'], $loc, $folk);
    $icon = (string)$a['icon'];
    $note = '';
    $msg = '';
    db()->beginTransaction();
    try {
        q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // v1.0.0: one of this gnome's rest-stop actions at a time (their lock), so the limits below can't be raced
        // Claim the slot first, so a double click can't do it twice
        db_insert('stop_log', ['user_id' => $uid, 'location_id' => (int)$loc['id'], 'visit_key' => $visit, 'day' => $day, 'act' => $slug, 'kind' => $kind, 'note' => '', 'at' => now()]);
        [$d2, $h2, $a2, $r2] = stop_state($uid, (int)$loc['id'], $visit);   // v1.0.0: the limits again, counted with this action in (the checks above ran before the claim)
        if (count($d2) > stop_slots($loc) || $h2 > max(1, (int)setting('stop_daily_cap')) || ($kind === 'rest' && $r2 > max(0, (int)setting('stop_rest_daily')))) {
            throw new UserError('You’ve done all you can here for now. Come back later!');
        }
        if ($energy > 0 && !spend_energy($uid, $energy)) throw new UserError('You need ' . $energy . ' energy for that.');
        $GLOBALS['gv_stop_tired'] = $a2 > max(1, (int)setting('stop_daily_total'));   // v1.4.9: past the day's soft limit: half Petals and XP
        $fresh = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
        $lines = [];
        $spec = (string)$a['spec'];
        switch ($kind) {
            case 'check':
                $opts = [];
                foreach (explode(';', $spec) as $o) { $pp = array_map('trim', explode(':', $o, 3)); if (count($pp) === 3) $opts[] = $pp; }
                $i = (int)($in['opt'] ?? -1);
                if (!isset($opts[$i]) || !isset(GNOME_STATS[$opts[$i][0]])) throw new UserError('Pick how to go about it.');
                [$stat, $dc, $label] = [$opts[$i][0], (int)$opts[$i][1], $opts[$i][2]];
                [$ok] = stop_check($fresh, $stat, $dc);
                $lines = stop_rewards($fresh, $loc, $ok ? $win : $lose, 1.0, $seed);
                $msg = $icon . ' ' . ($ok ? ($lineWin !== '' ? $lineWin : 'It goes well.') : ($lineLose !== '' ? $lineLose : 'It doesn’t go your way.'));
                $note = $stat . ($ok ? ' ok' : ' miss');
                break;
            case 'pick':
                $p = stop_spec_params($spec);
                $n = max(2, min(6, (int)($p['n'] ?? 3)));
                $pick = (int)($in['pick'] ?? 0);
                if ($pick < 1 || $pick > $n) throw new UserError('Pick one.');
                $target = random_int(1, $n);
                $lucky = $target !== $pick && random_int(1, 1000) <= (int)round(luck_percent($fresh) * 10);   // luck: a second look
                $ok = $target === $pick || $lucky;
                $lines = stop_rewards($fresh, $loc, $ok ? $win : $lose, 1.0, $seed);
                $msg = $icon . ' ' . ($lucky ? 'You catch it at the last second! ' : '') . ($ok ? $lineWin : $lineLose . ' It was number ' . $target . '.');
                $note = $ok ? 'win' : 'miss';
                break;
            case 'power':
                $p = stop_spec_params($spec);
                $n = max(3, min(7, (int)($p['n'] ?? 5)));
                $power = (int)($in['power'] ?? 0);
                if ($power < 1 || $power > $n) throw new UserError('Choose how hard to throw.');
                $peg = stop_peg((int)$loc['id'], $slug, $n);
                unset($_SESSION['stop_peg'][(int)$loc['id']][$slug]);
                $off = abs($peg - $power);
                if ($off === 0) { $lines = stop_rewards($fresh, $loc, $win, 1.0, $seed); $msg = $icon . ' ' . $lineWin; $note = 'win'; }
                elseif ($off === 1) { $lines = stop_rewards($fresh, $loc, $win, 0.35, $seed); $msg = $icon . ' So close! A small prize.'; $note = 'near'; }
                else { $lines = stop_rewards($fresh, $loc, $lose, 1.0, $seed); $msg = $icon . ' ' . ($lineLose !== '' ? $lineLose : 'Not quite.') . ' It sails ' . ($power > $peg ? 'past' : 'short'); $note = 'miss'; }
                break;
            case 'lore':
                $tales = array_values(array_filter(array_map('trim', explode(';;', $spec))));
                $tale = $tales ? $tales[crc32($seed) % count($tales)] : 'A quiet hour.';
                $lines = stop_rewards($fresh, $loc, $win, 1.0, $seed);
                $msg = $icon . ' ' . stop_say($tale, $loc, $folk);
                $note = 'tale ' . (crc32($seed) % max(1, count($tales)));
                break;
            case 'craft':   // v2.0.78: make something from what you carry (no dice)
                [$ins, [$os, $oq]] = stop_craft_parts($spec);
                $oid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$os]);
                if (!$ins || !$oid) throw new UserError('Nothing to make today.');
                foreach ($ins as [$is, $iq]) {
                    $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$is]);
                    if (!$iid || !give_item($uid, $iid, -$iq)) throw new UserError('You don’t have ' . $iq . ' × ' . ((string)q_val('SELECT name FROM items WHERE slug = ?', [$is]) ?: $is) . '.');
                    $lines[] = '−' . $iq . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$iid]);
                }
                give_item($uid, $oid, $oq);
                $lines[] = '+' . $oq . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$oid]);
                $lines = array_merge($lines, stop_rewards($fresh, $loc, $win, 1.0, $seed));
                $msg = $icon . ' ' . ($lineWin !== '' ? $lineWin : 'Made, and well made.');
                break;
            case 'collect':   // v2.0.78: spot the local things, one a visit; the checklist is the whole region's
                [$set, $label, $entries, $n, $doneRw] = stop_collect_parts($spec);
                $pick = (int)($in['pick'] ?? 0);
                if (!$entries) throw new UserError('Nothing to spot today.');
                if ($pick < 1 || $pick > $n) throw new UserError('Pick a spot to look at.');
                [, $data] = stop_prog_get($uid, 0, 'set:' . $set);
                $found = array_values(array_filter((array)($data['found'] ?? []), fn($x) => in_array($x, $entries, true)));
                $unseen = array_values(array_diff($entries, $found));
                $pickFrom = ($unseen && random_int(1, 100) <= 65) ? $unseen : $entries;   // a new one is likelier, but not certain
                $see = $pickFrom[random_int(0, count($pickFrom) - 1)];
                $new = !in_array($see, $found, true);
                if ($new) $found[] = $see;
                $data['found'] = $found;
                $complete = $new && count($found) >= count($entries) && empty($data['done']);
                if ($complete) $data['done'] = 1;
                stop_prog_set($uid, 0, 'set:' . $set, count($found), $data);
                $lines = stop_rewards($fresh, $loc, $new ? $win : $lose, 1.0, $seed);
                $msg = $icon . ' ' . ($new ? 'A new one: ' . $see . '! ' . ($lineWin !== '' ? $lineWin : '') : 'You spot a ' . $see . ' again. ' . ($lineLose !== '' ? $lineLose : ''))
                    . ' (' . count($found) . ' of ' . count($entries) . ' ' . $label . ')';
                if ($complete) {
                    $msg .= ' 🎉 The whole set!';
                    $lines = array_merge($lines, stop_rewards($fresh, $loc, $doneRw, 1.0, $seed . '|set'));
                }
                $note = $new ? 'new ' . $see : 'seen ' . $see;
                break;
            case 'tend':   // v2.0.78: a chore that takes a few visits; each visit is a step, the last pays
                $p = stop_spec_params($spec);
                $steps = max(2, min(6, (int)($p['steps'] ?? 3)));
                [$have] = stop_prog_get($uid, (int)$loc['id'], 'tend:' . $slug);
                $have++;
                if ($have >= $steps) {
                    stop_prog_set($uid, (int)$loc['id'], 'tend:' . $slug, 0);
                    $lines = stop_rewards($fresh, $loc, $win, 1.0, $seed);
                    $msg = $icon . ' ' . ($lineWin !== '' ? $lineWin : 'All done, and it shows.') . ' (' . $steps . ' of ' . $steps . ')';
                    $note = 'done';
                } else {
                    stop_prog_set($uid, (int)$loc['id'], 'tend:' . $slug, $have);
                    $lines = stop_rewards($fresh, $loc, $lose, 1.0, $seed);
                    $msg = $icon . ' ' . ($lineLose !== '' ? $lineLose : 'A good start.') . ' (step ' . $have . ' of ' . $steps . '; come back to finish)';
                    $note = 'step ' . $have;
                }
                break;
            case 'contest':   // v2.0.78: a friendly contest with a villager: three moves, each beats one and loses to one
                $p = stop_spec_params($spec);
                $moves = array_values(array_filter(array_map('trim', explode('/', (string)($p['moves'] ?? 'Quick/Steady/Clever')))));
                if (count($moves) !== 3) $moves = ['Quick', 'Steady', 'Clever'];
                $mine = (int)($in['move'] ?? -1);
                if ($mine < 0 || $mine > 2) throw new UserError('Pick your move.');
                $theirs = random_int(0, 2);
                $res = ($mine - $theirs + 3) % 3;   // 0 = same, 1 = you win, 2 = they win
                $lucky = $res === 2 && random_int(1, 1000) <= (int)round(luck_percent($fresh) * 10);   // luck: they hesitate and it is thrown again
                if ($lucky) { $theirs = random_int(0, 2); $res = ($mine - $theirs + 3) % 3; }
                $who = $folk ? $folk['name'] : 'They';
                $said = $moves[$mine] . ' against ' . $who . '’s ' . $moves[$theirs] . '. ';
                if ($res === 1) { $lines = stop_rewards($fresh, $loc, $win, 1.0, $seed); $msg = $icon . ' ' . $said . ($lineWin !== '' ? $lineWin : 'You win!'); $note = 'win'; }
                elseif ($res === 0) { $lines = stop_rewards($fresh, $loc, $win, 0.35, $seed); $msg = $icon . ' ' . $said . 'A draw! A small prize for both.'; $note = 'draw'; }
                else { $lines = stop_rewards($fresh, $loc, $lose, 1.0, $seed); $msg = $icon . ' ' . $said . ($lineLose !== '' ? $lineLose : 'They win this one.'); $note = 'miss'; }
                break;
            case 'rest':
                $p = stop_spec_params($spec);
                $cost = max(0, (int)($p['cost'] ?? 0));
                [$hpNow, $hpMax] = hp_get($fresh);
                if ($energy === 0 && (int)$fresh['energy'] >= max_energy($fresh) && $hpNow >= $hpMax) throw new UserError('You’re already full of energy and health.');
                if ($cost > 0 && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $uid, $cost])->rowCount() !== 1) throw new UserError('You need ' . $cost . ' ' . $cur . '.');
                if ($cost > 0) $lines[] = '−' . $cost . ' ' . $cur;
                $lines = array_merge($lines, stop_rewards($fresh, $loc, $win, 1.0, $seed));
                $healed = hp_heal_pct($fresh, (int)($p['heal'] ?? (preg_match('/soak|room_rest|spring/', $slug) ? 100 : hp_pct('hp_rest_percent', 50))));   // v2.3.5: baths and soaks heal fully, other rests by half
                if ($healed > 0) $lines[] = '+' . $healed . ' ❤️';
                $msg = $icon . ' ' . ($lineWin !== '' ? $lineWin : 'You rest a while.');
                break;
            case 'buy':
                [$bs, $bq, $bp] = array_pad(explode(':', $spec), 3, '');
                $bid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$bs]);
                $bq = max(1, (int)$bq);
                $bp = max(0, (int)$bp);
                if (!$bid) throw new UserError('Nothing to buy today.');
                if ($bp > 0 && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$bp, $uid, $bp])->rowCount() !== 1) throw new UserError('You need ' . $bp . ' ' . $cur . '.');
                give_item($uid, $bid, $bq);
                $lines[] = '−' . $bp . ' ' . $cur;
                $lines[] = '+' . $bq . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$bid]);
                $lines = array_merge($lines, stop_rewards($fresh, $loc, $win, 1.0, $seed));
                $msg = $icon . ' ' . ($lineWin !== '' ? $lineWin : 'A fair price.');
                break;
            case 'swap':
                [$g, $r] = array_pad(explode('>', $spec), 2, '');
                [$gs, $gq] = array_pad(explode(':', $g), 2, '1');
                [$rs, $rq] = array_pad(explode(':', $r), 2, '1');
                $gid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$gs]);
                $rid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$rs]);
                if (!$gid || !$rid) throw new UserError('Nothing to swap today.');
                if (!give_item($uid, $gid, -max(1, (int)$gq))) throw new UserError('You need ' . max(1, (int)$gq) . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$gid]) . '.');
                give_item($uid, $rid, max(1, (int)$rq));
                $lines[] = '−' . max(1, (int)$gq) . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$gid]);
                $lines[] = '+' . max(1, (int)$rq) . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$rid]);
                $lines = array_merge($lines, stop_rewards($fresh, $loc, $win, 1.0, $seed));
                $msg = $icon . ' ' . ($lineWin !== '' ? $lineWin : 'A fair swap.');
                break;
            case 'snack':
                $sn = stop_snack($loc);
                if (!$sn) throw new UserError('The stall is empty today.');
                [$it, $price] = $sn;
                if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$price, $uid, $price])->rowCount() !== 1) throw new UserError('You need ' . $price . ' ' . $cur . '.');
                give_item($uid, (int)$it['id'], 2);
                $lines[] = '−' . $price . ' ' . $cur;
                $lines[] = '+2 × ' . $it['name'];
                $msg = $icon . ' Still warm!';
                break;
            case 'seedswap':
                $give = (int)($in['item_id'] ?? 0);
                $isSeed = q_val("SELECT 1 FROM items WHERE id = ? AND category = 'seed'", [$give]);
                if (!$isSeed || !give_item($uid, $give, -1)) throw new UserError('Pick one of your seeds to swap.');
                $opts = q("SELECT DISTINCT p.seed_item_id FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id
                           WHERE pr.region_id = ? AND pr.tier IN ('staple', 'uncommon', 'flower') AND p.seed_item_id <> ?", [(int)$loc['region_id'], $give])->fetchAll(PDO::FETCH_COLUMN);
                if (!$opts) throw new UserError('The old gardener has nothing to swap today.');
                $get = (int)$opts[random_int(0, count($opts) - 1)];
                give_item($uid, $get, 1);
                $lines[] = '+1 × ' . q_val('SELECT name FROM items WHERE id = ?', [$get]);
                add_xp($uid, 2, 'rest_stop');
                $msg = $icon . ' “Plant it in good soil, mind.”';
                break;
            case 'gossip':
                add_xp($uid, 3, 'rest_stop');
                $lines[] = '+3 XP';
                $msg = $icon . ' “Have you heard…?” ' . stop_reveal_hidden($uid, $loc);
                break;
            default:
                throw new UserError('That doesn’t work yet.');
        }
        db()->commit();
    } catch (UserError $e) {
        if (db()->inTransaction()) db()->rollBack();
        return [false, $e->getMessage()];
    } catch (PDOException $e) {
        if (db()->inTransaction()) db()->rollBack();
        return [false, 'You’ve done that already on this visit.'];
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();   // v1.0.0: never leave the transaction open
        throw $e;
    }
    if ($folk) {   // a little chat tag so the villager appears in the text sometimes
        $msg = trim($msg);
    }
    if (function_exists('calling_event')) calling_event($uid, 'townact', 'stop:' . $slug, 1, ['stop' => (string)$loc['slug']]);
    return [true, trim($msg . ($lines ? ' (' . implode(', ', $lines) . ')' : ''))];
}

/** Today's food at the bake stall: an edible crop of this region. [item row, price for 2] */
function stop_snack(array $loc): ?array
{
    $rows = stop_local_crops($loc);
    if (!$rows) return null;
    $it = $rows[crc32($loc['slug'] . hollow_date('Y-m-d')) % count($rows)];
    return [$it, max(4, (int)ceil((int)$it['base_price'] * 2 * 0.6))];   // two for a bit more than the price of one
}

// ---------------------------------------------------------------- upgrade

const STOPS_ALMANAC = [
    'Rest stops' => [36, "🪧 Every village on the road is a [b]rest stop[/b], and every rest stop is different: a market hamlet, an old mill, a wayfarers' inn, a moss shrine, a fishing jetty, a herb croft, a tinkers' workshop, an orchard camp, a ferry landing, a watchtower, a hot spring or a campfire clearing.\n\n[b]Stay a while.[/b] You can do up to three different things on a visit: haggle, fish, carry sacks, hear a tale, soak in a spring. Some cost a little energy; some are free; the rests are limited to a couple a day. Then walk on and come back later for more.\n\n[b]Time matters.[/b] Night fishing only works after dark, a rainy day brings the inn's stories, winter brings frost fairs and snow soaks. The 'Other times here' list shows what you are missing.\n\n[b]Villagers.[/b] Two or three named villagers live at each stop. Say hello once a day to become friends. They ask for errands: bring them something, carry a parcel to a villager at another stop, or walk a small friend to another stop.\n\n[b]Adopt a stop[/b] to look after it: hand in building materials and Petals over time and it grows a bench, a stall, a well and a hall for everyone. Your name goes on the plaque."],
    'Stamp passport' => [37, "🛂 Every rest stop gives you a [b]stamp[/b] on your first visit, drawn from the kind of stop it is. Open the [b]Passport[/b] (from any rest stop, or the Almanac's World tab) to see your stamps by region and by kind.\n\nSets pay out on their own: stamp 5, 15, 30, 60 and 100 stops; collect three of each kind; or every road stop in a region. Many sets also give you a [b]title[/b] to wear (choose it in the Almanac's Milestones tab)."],
];

/**
 * v1.0.0 wave 1 migration: copy the data files into the tables (stop types, activities, upgrade tiers, passport sets), give every village its
 * stop type, make its villagers, and add the two Almanac pages. Idempotent; admin edits are kept.
 */
function upgrade_100_stops(): void
{
    stops_import_data();
    stop_types(true);
    stop_acts(true);
    stop_assign_all();
    foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) {
        $v['stop_type'] = stop_type_of($v);
        require_once __DIR__ . '/stop_folk.php';
        stop_folk_ensure($v);
    }
    foreach (STOPS_ALMANAC as $title => [$sort, $body]) {
        if (q_val("SELECT 1 FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title])) continue;
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => $title, 'body' => $body, 'unlock_key' => 'start', 'hint' => '', 'sort_order' => $sort]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
        }
    }
    setting('__reload__');
}
