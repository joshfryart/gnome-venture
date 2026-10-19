<?php
declare(strict_types=1);

/*
 * v1.0.0 backbone: the Hollow clock. Season, weather and part of the day, worked out on view (no cron) and the same for every player.
 *
 *   hollow_season(?string $date = null): string              'spring' | 'summer' | 'autumn' | 'winter'
 *   hollow_season_day(?string $date = null): int             1-based day inside the season (1 .. season length)
 *   hollow_weather(?string $region = null, ?string $date = null): string   sun|cloud|rain|storm|frost|heat|wind|fog|snow
 *   hollow_daypart(?int $hour = null): string                'dawn' | 'day' | 'dusk' | 'night'
 *   hollow_now(?string $region = null, ?int $ts = null): array   everything above plus labels and emoji
 *   hollow_forecast(?string $region = null, int $days = 3): array  today + next days
 *   hollow_chip(?string $region = null): string              the little "🌸 Spring · day 4 · 🌧️ Rain · 🌙 Night" chip (HTML)
 *
 * $date is a Hollow date 'Y-m-d' (the Hollow's own midnight, game_timezone); null = today. $region is a region code ('NA', 'MENA'...) or null for the Hollow itself.
 * Seasons come from the GAME calendar (settings season_mode=game: each season lasts season_days real days, counted from season_epoch)
 * or the REAL northern-hemisphere calendar (season_mode=real). Admin overrides: season_force and weather_force (weather_force only changes today).
 * Everything is a pure function of the date (+ region), so a refresh never changes the weather. No gameplay effects live here.
 */

const HOLLOW_SEASONS = [
    'spring' => ['🌸', 'Spring', 'sp', 'Blossom and fresh rain. Seedlings everywhere.'],
    'summer' => ['🌻', 'Summer', 'su', 'Long, warm days and the busiest gardens.'],
    'autumn' => ['🍂', 'Autumn', 'au', 'Harvest time, falling leaves, pumpkins.'],
    'winter' => ['❄️', 'Winter', 'wi', 'Frost, snow and quiet, cosy evenings.'],
];

/** key => [emoji, label, night label, short blurb] */
const HOLLOW_WEATHER = [
    'sun'   => ['☀️', 'Sunny', 'Clear', 'Bright and dry.'],
    'cloud' => ['☁️', 'Cloudy', 'Cloudy', 'Grey skies, mild air.'],
    'rain'  => ['🌧️', 'Rain', 'Rain', 'A steady, soaking rain.'],
    'storm' => ['⛈️', 'Storm', 'Storm', 'Thunder and heavy rain.'],
    'frost' => ['🥶', 'Frost', 'Frost', 'Sharp cold; the ground is silver.'],
    'heat'  => ['🌡️', 'Heat', 'Warm night', 'Hot and dry.'],
    'wind'  => ['💨', 'Wind', 'Wind', 'Gusty; leaves and hats take flight.'],
    'fog'   => ['🌫️', 'Fog', 'Fog', 'Thick fog hides the paths.'],
    'snow'  => ['🌨️', 'Snow', 'Snow', 'Soft snow settles over the Hollow.'],
];

/** key => [emoji, label, blurb] */
const HOLLOW_DAYPARTS = [
    'dawn'  => ['🌅', 'Dawn', 'The Hollow is waking up.'],
    'day'   => ['🌞', 'Day', 'Broad daylight.'],
    'dusk'  => ['🌇', 'Dusk', 'Lamps are being lit.'],
    'night' => ['🌙', 'Night', 'The night shift is on.'],
];

/** Default weather weights per season (editable in Admin → Settings → Seasons & weather as "sun:30, rain:20, ..."). */
const HOLLOW_WEIGHT_DEFAULTS = [
    'spring' => 'sun:28, cloud:22, rain:28, storm:5, frost:4, heat:0, wind:8, fog:5, snow:0',
    'summer' => 'sun:40, cloud:15, rain:14, storm:8, frost:0, heat:13, wind:5, fog:3, snow:0',
    'autumn' => 'sun:20, cloud:25, rain:24, storm:5, frost:6, heat:0, wind:12, fog:10, snow:0',
    'winter' => 'sun:14, cloud:24, rain:5, storm:3, frost:20, heat:0, wind:8, fog:6, snow:30',
];

/** Region weather leanings (multipliers on the season's weights). Missing region = neutral. Switch off with setting weather_regions. */
const HOLLOW_REGION_WEATHER = [
    'NA'   => 'frost:1.2, snow:1.2',
    'CA'   => 'rain:0.6, heat:1.3, snow:0, frost:0.2',
    'CB'   => 'storm:2, rain:1.3, heat:1.3, snow:0, frost:0',
    'NWE'  => 'rain:1.5, fog:1.5, cloud:1.3, heat:0.5',
    'SE'   => 'sun:1.4, heat:1.4, rain:0.7, snow:0.3',
    'EE'   => 'frost:1.4, snow:1.4, heat:1.2',
    'MENA' => 'sun:1.8, heat:2, rain:0.2, fog:0.2, snow:0, frost:0.2',
    'WCA'  => 'rain:1.8, storm:1.5, heat:1.2, snow:0, frost:0',
    'ESA'  => 'sun:1.2, snow:0, frost:0.3',
    'CSA'  => 'rain:2, storm:1.5, snow:0, frost:0',
    'SEA'  => 'rain:1.8, storm:1.5, heat:1.4, snow:0, frost:0',
    'OC'   => 'wind:1.6, storm:1.3, snow:0.1, frost:0.1',
];

const HOLLOW_EPOCH_FALLBACK = '2026-01-01';

/** The Hollow's date 'Y-m-d' for a timestamp (null = now). */
function hollow_today(?int $ts = null): string
{
    return hollow_date('Y-m-d', $ts);
}

/** A valid 'Y-m-d' (today when null or odd). */
function hollow_clock_date(?string $date): string
{
    if ($date !== null && preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', $date, $m) && checkdate((int)$m[2], (int)$m[3], (int)$m[1])) return $date;
    return hollow_today();
}

function hollow_day_number(string $date): int
{
    return intdiv((int)strtotime($date . ' 00:00:00 UTC'), 86400);
}

/** Add days to a 'Y-m-d'. */
function hollow_date_add(string $date, int $days): string
{
    return gmdate('Y-m-d', (hollow_day_number($date) + $days) * 86400);
}

function hollow_season_mode(): string
{
    return setting('season_mode') === 'real' ? 'real' : 'game';
}

/** Days in each game season (3-120). */
function hollow_season_length(): int
{
    return max(3, min(120, (int)setting('season_days') ?: 14));
}

/** The date the game cycle starts (spring day 1). */
function hollow_season_epoch(): string
{
    $e = trim(setting('season_epoch'));
    if (preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', $e, $m) && checkdate((int)$m[2], (int)$m[3], (int)$m[1])) return $e;
    return HOLLOW_EPOCH_FALLBACK;
}

/**
 * [season, day in season (1-based), season length in days] for a date, ignoring the admin override.
 * Real mode: meteorological northern-hemisphere seasons (Mar-May, Jun-Aug, Sep-Nov, Dec-Feb).
 */
function hollow_season_calc(string $date): array
{
    $names = array_keys(HOLLOW_SEASONS);
    if (hollow_season_mode() === 'real') {
        [$y, $mo, $d] = array_map('intval', explode('-', $date));
        $idx = [3, 3, 0, 0, 0, 1, 1, 1, 2, 2, 2, 3][$mo - 1];
        $startMo = [0 => 3, 1 => 6, 2 => 9, 3 => 12][$idx];
        $startY = ($idx === 3 && $mo < 12) ? $y - 1 : $y;
        $start = sprintf('%04d-%02d-01', $startY, $startMo);
        $endMo = $startMo + 3;
        $endY = $startY;
        if ($endMo > 12) { $endMo -= 12; $endY++; }
        $len = hollow_day_number(sprintf('%04d-%02d-01', $endY, $endMo)) - hollow_day_number($start);
        return [$names[$idx], hollow_day_number($date) - hollow_day_number($start) + 1, $len];
    }
    $len = hollow_season_length();
    $n = hollow_day_number($date) - hollow_day_number(hollow_season_epoch());
    $pos = (($n % (4 * $len)) + 4 * $len) % (4 * $len);
    return [$names[intdiv($pos, $len)], ($pos % $len) + 1, $len];
}

function hollow_season_forced(): string
{
    $f = setting('season_force');
    return isset(HOLLOW_SEASONS[$f]) ? $f : '';
}

function hollow_weather_forced(): string
{
    $f = setting('weather_force');
    return isset(HOLLOW_WEATHER[$f]) ? $f : '';
}

function hollow_season(?string $date = null): string
{
    if (($f = hollow_season_forced()) !== '') return $f;
    return hollow_season_calc(hollow_clock_date($date))[0];
}

function hollow_season_day(?string $date = null): int
{
    $date = hollow_clock_date($date);
    if (($f = hollow_season_forced()) !== '') {
        // forced: count days since the calendar's own season changed into the same name, else just the calendar's day
        [$s, $d] = hollow_season_calc($date);
        return $s === $f ? $d : 1;
    }
    return hollow_season_calc($date)[1];
}

/** Season length in days for the season shown on $date. */
function hollow_season_days_total(?string $date = null): int
{
    return hollow_season_calc(hollow_clock_date($date))[2];
}

/** Season code used by flowers and plants: sp su au wi. */
function hollow_season_code(?string $season = null): string
{
    return HOLLOW_SEASONS[$season ?? hollow_season()][2] ?? 'sp';
}

/** Is this "spring,summer" list (plants.seasons; blank or '*' = all year) in season on a date? */
function hollow_in_season(string $csv, ?string $date = null): bool
{
    $csv = strtolower(trim($csv));
    if ($csv === '' || $csv === '*' || $csv === 'all') return true;
    return in_array(hollow_season($date), array_map('trim', explode(',', $csv)), true);
}

/** "sun:30, rain:20" => ['sun' => 30.0, 'rain' => 20.0]; unknown keys dropped, bad numbers skipped. */
function hollow_parse_weights(string $s, array $allowed): array
{
    $out = [];
    foreach (explode(',', $s) as $part) {
        if (!preg_match('/^\s*([a-z]+)\s*:\s*(\d+(?:\.\d+)?)\s*$/i', $part, $m)) continue;
        $k = strtolower($m[1]);
        if (isset($allowed[$k])) $out[$k] = max(0.0, min(1000.0, (float)$m[2]));
    }
    return $out;
}

/** The weights in force for a season (and region): base from the setting (or default), times the region's leaning. */
function hollow_weather_weights(string $season, ?string $region = null): array
{
    $base = hollow_parse_weights(setting('weather_weights_' . $season), HOLLOW_WEATHER) ?: hollow_parse_weights(HOLLOW_WEIGHT_DEFAULTS[$season], HOLLOW_WEATHER);
    $w = [];
    foreach (HOLLOW_WEATHER as $k => $_) $w[$k] = $base[$k] ?? 0.0;
    if ($region !== null && $region !== '' && setting('weather_regions') === '1' && isset(HOLLOW_REGION_WEATHER[strtoupper($region)])) {
        foreach (hollow_parse_weights(HOLLOW_REGION_WEATHER[strtoupper($region)], HOLLOW_WEATHER) as $k => $mult) $w[$k] *= $mult;
    }
    return $w;
}

/** Percent chance of each weather for a season and region (rounded; for display). */
function hollow_weather_chances(string $season, ?string $region = null): array
{
    $w = hollow_weather_weights($season, $region);
    $sum = array_sum($w);
    $out = [];
    foreach ($w as $k => $v) $out[$k] = $sum > 0 ? (int)round($v * 100 / $sum) : ($k === 'sun' ? 100 : 0);
    return $out;
}

/** A stable number 0..1 from text. */
function hollow_unit(string $seed): float
{
    return hexdec(substr(md5($seed), 0, 8)) / 4294967296.0;
}

/** Weather for a region (null = the Hollow) on a date. Stable all day; same for everyone. */
function hollow_weather(?string $region = null, ?string $date = null): string
{
    $today = hollow_today();
    $date = hollow_clock_date($date);
    if ($date === $today && ($f = hollow_weather_forced()) !== '') return $f;
    $region = ($region !== null && $region !== '' && setting('weather_regions') === '1') ? strtoupper($region) : null;   // regions off: one weather for the whole Hollow
    $season = hollow_season($date);
    // v1.0.0: memoised per request (a garden asks for each bed and day); the key includes the settings the answer depends on
    static $memo = [];
    $mk = $date . '|' . ($region ?? '-') . '|' . $season . '|' . setting('weather_weights_' . $season);
    if (isset($memo[$mk])) return $memo[$mk];
    if (count($memo) > 400) $memo = [];
    $w = hollow_weather_weights($season, $region);
    $sum = array_sum($w);
    if ($sum <= 0) return $memo[$mk] = 'sun';
    $r = hollow_unit('weather|' . $date . '|' . ($region ?? '-')) * $sum;
    foreach ($w as $k => $v) {
        if ($v <= 0) continue;
        if ($r < $v) return $memo[$mk] = $k;
        $r -= $v;
    }
    return $memo[$mk] = (string)array_key_last(array_filter($w));
}

/** Hour boundaries [dawn, day, dusk, night] (settings daypart_*), falling back to 5/7/18/21 if they are not in order. */
function hollow_daypart_hours(): array
{
    $h = [(int)setting('daypart_dawn'), (int)setting('daypart_day'), (int)setting('daypart_dusk'), (int)setting('daypart_night')];
    if (!($h[0] >= 0 && $h[0] < $h[1] && $h[1] < $h[2] && $h[2] < $h[3] && $h[3] <= 23)) return [5, 7, 18, 21];
    return $h;
}

/** dawn | day | dusk | night for an hour 0-23 (null = the Hollow's hour now). */
function hollow_daypart(?int $hour = null): string
{
    $hour = ((($hour ?? hollow_hour()) % 24) + 24) % 24;
    [$dawn, $day, $dusk, $night] = hollow_daypart_hours();
    if ($hour >= $night || $hour < $dawn) return 'night';
    if ($hour >= $dusk) return 'dusk';
    if ($hour >= $day) return 'day';
    return 'dawn';
}

/** Emoji and label for a weather key; at night "Sunny" reads "Clear". */
function hollow_weather_info(string $w, string $daypart = 'day'): array
{
    $i = HOLLOW_WEATHER[$w] ?? HOLLOW_WEATHER['sun'];
    $night = $daypart === 'night';
    return ['emoji' => ($night && $w === 'sun') ? '✨' : $i[0], 'label' => $night ? $i[2] : $i[1], 'blurb' => $i[3]];
}

/** Everything about this moment (or timestamp $ts) in one array. */
function hollow_now(?string $region = null, ?int $ts = null): array
{
    $date = hollow_today($ts);
    $hour = (int)hollow_date('G', $ts);
    $season = hollow_season($date);
    $dp = hollow_daypart($hour);
    $weather = hollow_weather($region, $date);
    $wi = hollow_weather_info($weather, $dp);
    $total = hollow_season_days_total($date);
    $day = hollow_season_day($date);
    return [
        'date' => $date, 'hour' => $hour, 'region' => $region,
        'season' => $season, 'season_emoji' => HOLLOW_SEASONS[$season][0], 'season_label' => HOLLOW_SEASONS[$season][1], 'season_code' => HOLLOW_SEASONS[$season][2],
        'season_day' => $day, 'season_length' => $total, 'season_days_left' => max(0, $total - $day),
        'weather' => $weather, 'weather_emoji' => $wi['emoji'], 'weather_label' => $wi['label'],
        'daypart' => $dp, 'daypart_emoji' => HOLLOW_DAYPARTS[$dp][0], 'daypart_label' => HOLLOW_DAYPARTS[$dp][1],
        'mode' => hollow_season_mode(),
        'season_forced' => hollow_season_forced() !== '', 'weather_forced' => hollow_weather_forced() !== '',
    ];
}

/** Today and the next days: [['date', 'label' (Today/Tomorrow/weekday), 'season', 'weather', 'emoji', 'wlabel'], ...]. Overrides only touch today. */
function hollow_forecast(?string $region = null, int $days = 3): array
{
    $out = [];
    $today = hollow_today();
    for ($i = 0; $i < max(1, min(14, $days)); $i++) {
        $d = hollow_date_add($today, $i);
        $w = hollow_weather($region, $d);
        $wi = hollow_weather_info($w, 'day');
        $out[] = ['date' => $d, 'label' => $i === 0 ? 'Today' : ($i === 1 ? 'Tomorrow' : gmdate('l', hollow_day_number($d) * 86400)),
            'season' => hollow_season($d), 'weather' => $w, 'emoji' => $wi['emoji'], 'wlabel' => $wi['label']];
    }
    return $out;
}

/** Date the next season starts (from the calendar; with season_force on it still shows the calendar's change). */
function hollow_next_season(): array
{
    $today = hollow_today();
    [$s, $day, $len] = hollow_season_calc($today);
    $left = $len - $day + 1;   // days until the next one starts
    $start = hollow_date_add($today, $left);
    $names = array_keys(HOLLOW_SEASONS);
    return ['season' => $names[(array_search($s, $names, true) + 1) % 4], 'date' => $start, 'in_days' => $left];
}

/** A region code for a player: where they are now, else their home region. Null if unknown. */
function hollow_user_region(array $u): ?string
{
    static $cache = [];
    $key = (int)($u['id'] ?? 0) . ':' . (int)($u['location_id'] ?? 0) . ':' . (int)($u['region_id'] ?? 0);
    if (array_key_exists($key, $cache)) return $cache[$key];
    $rid = 0;
    $code = '';
    if (!empty($u['location_id'])) $code = (string)q_val('SELECT r.code FROM locations l JOIN regions r ON r.id = l.region_id WHERE l.id = ?', [(int)$u['location_id']]);   // v1.0.0: one query
    if ($code === '') {
        $rid = (int)($u['region_id'] ?? 0);
        $code = $rid ? (string)q_val('SELECT code FROM regions WHERE id = ?', [$rid]) : '';
    }
    return $cache[$key] = ($code !== '' ? $code : null);
}

/** "🌸 Spring · day 4 · 🌧️ Rain · 🌙 Night" as plain text. */
function hollow_line(?string $region = null): string
{
    $n = hollow_now($region);
    return $n['season_emoji'] . ' ' . $n['season_label'] . ' · day ' . $n['season_day'] . ' · ' . $n['weather_emoji'] . ' ' . $n['weather_label'] . ' · ' . $n['daypart_emoji'] . ' ' . $n['daypart_label'];
}

/** The chip for the header strip, the Today page and the right rail. */
function hollow_chip(?string $region = null, string $class = 'st hollow'): string
{
    $n = hollow_now($region);
    $title = $n['season_label'] . ' day ' . $n['season_day'] . ' of ' . $n['season_length'] . '. ' . (HOLLOW_WEATHER[$n['weather']][3] ?? '') . ' ' . HOLLOW_DAYPARTS[$n['daypart']][2];
    return '<span class="' . e($class) . '" title="' . e($title) . '"><a href="' . e(url('seasons.php')) . '">'
        . '<span aria-hidden="true">' . $n['season_emoji'] . '</span> ' . e($n['season_label']) . ' <small>day ' . $n['season_day'] . '</small>'
        . ' · <span aria-hidden="true">' . $n['weather_emoji'] . '</span> ' . e($n['weather_label'])
        . ' · <span aria-hidden="true">' . $n['daypart_emoji'] . '</span> ' . e($n['daypart_label']) . '</a></span>';
}

/** Right-rail section: now, then the next two days. */
function hollow_rail_section(?string $region = null): string
{
    $n = hollow_now($region);
    $h = '<section class="rbox rhollow" aria-labelledby="rt-hollow"><h3 id="rt-hollow">' . $n['season_emoji'] . ' The Hollow</h3>'
        . '<p class="rhnow"><a href="' . e(url('seasons.php')) . '"><b>' . e($n['season_label']) . '</b> day ' . $n['season_day'] . '/' . $n['season_length']
        . '<br>' . $n['weather_emoji'] . ' ' . e($n['weather_label']) . ' · ' . $n['daypart_emoji'] . ' ' . e($n['daypart_label']) . '</a></p><ul class="rlist">';
    foreach (array_slice(hollow_forecast($region, 3), 1) as $f) {
        $h .= '<li><span>' . e($f['label']) . '</span> <small class="rtime">' . $f['emoji'] . ' ' . e($f['wlabel']) . '</small></li>';
    }
    return $h . '</ul></section>';
}

const HOLLOW_ALMANAC = [
    'Seasons & weather' => [35, "🌦️ The Hollow keeps a calendar. [b]Spring, summer, autumn and winter[/b] each last a set number of real days, then the next one begins, round and round. Every gnome sees the same season and the same weather.\n\nEach day has its own weather (sunny, cloudy, rain, storm, frost, heat, wind, fog or snow) and it stays the same all day, wherever you refresh. Different regions lean different ways: rain in the Rainy lands, heat in the dry ones. The day itself runs through [b]dawn, day, dusk and night[/b], just like the folk of the Hollow.\n\nThe header strip shows the season, the weather and the time of day. Open the [b]Seasons & weather[/b] page from it to see the forecast for the next two days. Look out for the changes: seasons and weather will matter more and more as the Hollow wakes up."],
];

/**
 * v1.0.0 migration. Settings need no rows (defaults come from the settings list). Sets the season calendar to start now
 * (only when the world has no season_epoch yet) and adds the Almanac page. Idempotent.
 */
function upgrade_100_clock(): void
{
    if (!q_val("SELECT 1 FROM settings WHERE name = 'season_epoch'")) set_setting('season_epoch', hollow_today());
    foreach (HOLLOW_ALMANAC as $title => [$sort, $body]) {
        if (q_val("SELECT 1 FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title])) continue;
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => $title, 'body' => $body, 'unlock_key' => 'start', 'hint' => '', 'sort_order' => $sort]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
        }
    }
    setting('__reload__');
}
