<?php
declare(strict_types=1);

require_once __DIR__ . '/hollow_clock.php';   // v1.0.0: season, weather, part of the day (its constants are used by settings_schema)

// ======================= Output & URLs =======================

/** Escape for HTML. Use on EVERY piece of user/admin data printed into a page. */
function e($v): string
{
    return htmlspecialchars((string)$v, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/**
 * v2.0.23: e() for PLAYER-TYPED text (garden and critter names, notes, titles, feedback). Emoji and their joiners are written as numeric
 * references (&#x1F331;), so the emoji-to-icon pass (emoji_icons.php), which only matches literal UTF-8, leaves what the player typed alone.
 */
function eu($v): string
{
    return preg_replace_callback('/[\x{00A9}\x{00AE}\x{200D}\x{203C}\x{2049}\x{20E3}\x{2122}\x{2139}\x{2190}-\x{21FF}\x{2300}-\x{23FF}\x{24C2}\x{25A0}-\x{27BF}\x{2900}-\x{297F}\x{2B00}-\x{2BFF}\x{3030}\x{303D}\x{3297}\x{3299}\x{FE0F}\x{1F000}-\x{1FAFF}\x{E0020}-\x{E007F}]/u',
        fn($m) => '&#x' . strtoupper(dechex(mb_ord($m[0], 'UTF-8'))) . ';', e($v)) ?? e($v);
}

/** v0.9.1a: "a cup of tea" / "an acorn coffee": the right article plus the word. */
function an(string $s): string
{
    return (preg_match('/^[aeiou]/i', $s) ? 'an ' : 'a ') . $s;
}

/**
 * v1.6.3: one row of a choice list (rest stop activities, fight actions, jobs). Used by full pages and by AJAX fragments, so the markup is the same everywhere.
 * $icon, $title, $sub are plain text (escaped here). $badge is '' or the text, or [text, 'good'|'poor'|'cost'|'free'].
 * $cls adds classes (primary, is-selected). $attrs is raw, already-escaped attributes (name="opt" value="1" disabled, or href="..." for a link).
 * A <button> belongs inside a POST form (CSRF); a link is only for GET.
 */
function choice_row(string $icon, string $title, string $sub = '', $badge = '', string $cls = '', string $attrs = ''): string
{
    [$bt, $bc] = is_array($badge) ? [(string)$badge[0], (string)($badge[1] ?? '')] : [(string)$badge, ''];
    $link = (bool)preg_match('/(^|\s)href=/', $attrs);
    $selected = str_contains(' ' . $cls . ' ', ' is-selected ');
    if ($selected && $bt === '') $bt = '✓';
    $tag = $link ? 'a' : 'button';
    return '<' . $tag . ' class="choice' . ($cls !== '' ? ' ' . e($cls) : '') . '"' . ($attrs !== '' ? ' ' . $attrs : '') . ($selected && !$link ? ' aria-pressed="true"' : '') . '>'
        . ($icon !== '' ? '<span class="choice-ico" aria-hidden="true">' . e($icon) . '</span>' : '')
        . '<span class="choice-body"><b class="choice-title">' . e($title) . '</b>' . ($sub !== '' ? '<small class="choice-sub">' . e($sub) . '</small>' : '') . '</span>'
        . ($bt !== '' ? '<b class="choice-badge' . ($bc !== '' ? ' ' . e($bc) : '') . '">' . e($bt) . '</b>' : '')
        . '</' . $tag . '>';
}

/** v1.6.3: colour of a chance badge on a .choice row (60+ good, under 35 poor). */
function choice_odds_class(int $pct): string
{
    return $pct >= 60 ? 'good' : ($pct < 35 ? 'poor' : '');
}

function url(string $path = ''): string
{
    global $CONFIG;
    $path = ltrim($path, '/');
    // v1.5.1: pictures refresh after an update (game art: the version; uploaded art: when the file last changed)
    if (!str_contains($path, '?') && preg_match('~^(assets/img|uploads)/.+\.(svg|png|jpe?g|webp|gif)$~i', $path)) {
        $v = str_starts_with($path, 'uploads/') ? (string)(@filemtime(APP_ROOT . '/' . $path) ?: '') : (defined('APP_VERSION') ? APP_VERSION : '');
        if ($v !== '') $path .= '?v=' . $v;
    }
    return rtrim($CONFIG['base_url'] ?? '', '/') . '/' . $path;
}

function redirect(string $path): void
{
    header('Location: ' . url($path));
    exit;
}

/**
 * Safe text formatting for news, pages, encyclopedia: text is escaped first,
 * then a few BBCode tags are allowed: [b] [i] [u] [h] [url=https://..]text[/url]
 */
function format_text(?string $s): string
{
    $s = e($s ?? '');
    $s = preg_replace('~\[b\](.*?)\[/b\]~s', '<strong>$1</strong>', $s);
    $s = preg_replace('~\[i\](.*?)\[/i\]~s', '<em>$1</em>', $s);
    $s = preg_replace('~\[u\](.*?)\[/u\]~s', '<u>$1</u>', $s);
    $s = preg_replace('~\[h\](.*?)\[/h\]~s', '<span class="subhead">$1</span>', $s);
    $s = preg_replace_callback('~\[url=(https?://[^\]\s"\'<>]+)\](.*?)\[/url\]~s', function ($m) {
        return '<a href="' . $m[1] . '" rel="nofollow noopener" target="_blank">' . $m[2] . '</a>';
    }, $s);
    // v0.7.18: images (only ones uploaded to this site), quotes, centring and lists
    $s = preg_replace_callback('~\[img\](uploads/[a-f0-9]{24}\.(?:png|jpg|gif|webp))\[/img\]~', fn($m) => '<img class="postimg" src="' . e(url($m[1])) . '" alt="" loading="lazy">', $s);
    $s = preg_replace('~\[quote\]\s*(.*?)\s*\[/quote\]~s', '<blockquote>$1</blockquote>', $s);
    $s = preg_replace('~\[center\](.*?)\[/center\]~s', '<div class="center">$1</div>', $s);
    $s = preg_replace_callback('~\[list\]\s*(.*?)\s*\[/list\]~s', function ($m) {
        $items = array_filter(array_map('trim', explode('[*]', $m[1])), 'strlen');
        return '<ul>' . implode('', array_map(fn($i) => '<li>' . $i . '</li>', $items)) . '</ul>';
    }, $s);
    $s = nl2br($s);
    return preg_replace('~(</?(?:ul|li|blockquote|div)[^>]*>)<br />~', '$1', $s);   // no stray line breaks around blocks
}

/** A same-site page to return to after a form (only simple relative paths like "garden.php?sel=1-2"). */
function safe_back(string $default): string
{
    $b = (string)($_POST['back'] ?? '');
    return preg_match('~^[a-z0-9_/-]+\.php(\?[A-Za-z0-9=&_.-]*)?$~', $b) && !str_contains($b, '..') && !str_starts_with($b, '/') ? $b : $default;
}

function flash(string $msg, string $type = 'ok'): void
{
    $_SESSION['flash'][] = ['msg' => $msg, 'type' => $type];
}

/**
 * A big, Neopets-style result box shown at the top of the next page (v0.7.17).
 * $big is the headline number/text, $lines the prizes (plain text, escaped when shown).
 */
function prize(string $icon, string $title, string $big, array $lines = []): void
{
    $_SESSION['prizes'][] = ['icon' => $icon, 'title' => $title, 'big' => $big, 'lines' => array_values(array_filter($lines, 'strlen'))];
}

function take_prizes(): array
{
    $p = $_SESSION['prizes'] ?? [];
    unset($_SESSION['prizes']);
    return $p;
}

function take_flashes(): array
{
    $f = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    return $f;
}

function slugify(string $s): string
{
    $s = strtolower(trim($s));
    $s = preg_replace('/[^a-z0-9]+/', '-', $s);
    return trim($s, '-') ?: 'item';
}

// ======================= Security =======================

function is_https(): bool
{
    return (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
}

function send_security_headers(): void
{
    if (headers_sent()) {
        return;
    }
    header('X-Frame-Options: DENY');
    header('X-Content-Type-Options: nosniff');
    header('Referrer-Policy: same-origin');
    header("Content-Security-Policy: default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; frame-ancestors 'none'; form-action 'self'; base-uri 'self'");
    if (is_https()) {
        header('Strict-Transport-Security: max-age=31536000');
    }
    if (app_base_path() !== '') header('X-Robots-Tag: noindex, nofollow');   // v1.6.8: a copy in a sub-folder (test site) stays out of search engines
}

/** v1.6.8: the web folder the game lives in ('' at the domain root, '/testvault' for a test copy). */
function app_base_path(): string
{
    global $CONFIG;
    $p = (string)(parse_url((string)($CONFIG['base_url'] ?? ''), PHP_URL_PATH) ?? '');
    return rtrim($p, '/');
}

function start_secure_session(): void
{
    if (session_status() === PHP_SESSION_ACTIVE) {
        return;
    }
    ini_set('session.use_strict_mode', '1');
    ini_set('session.use_only_cookies', '1');
    $bp = app_base_path();   // v1.6.8: a test copy in a sub-folder gets its own login cookie, so it never logs you out of the real game
    session_name($bp === '' ? 'garden_sess' : 'garden_sess_' . substr(md5($bp), 0, 8));
    session_set_cookie_params([
        'lifetime' => 0,
        'path'     => $bp === '' ? '/' : $bp . '/',
        'secure'   => is_https(),
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}

function csrf_token(): string
{
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}

function csrf_field(): string
{
    return '<input type="hidden" name="csrf" value="' . e(csrf_token()) . '">';
}

/** Call at the top of every POST handler. Stops the request if the token is wrong. */
function csrf_check(): void
{
    $sent = $_POST['csrf'] ?? '';
    if (!is_string($sent) || !hash_equals(csrf_token(), $sent)) {
        http_response_code(400);
        exit('Your form expired or was invalid. Go back, refresh the page and try again.');
    }
}

function is_post(): bool
{
    return ($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST';
}

function client_ip(): string
{
    // Only trust a proxy header when the admin says the site is behind one (Game settings → trusted_proxy);
    // otherwise players could fake it to dodge rate limits.
    $ip = (string)($_SERVER['REMOTE_ADDR'] ?? '0.0.0.0');
    $mode = function_exists('setting') ? setting('trusted_proxy') : '';
    $h = $mode === 'cloudflare' ? ($_SERVER['HTTP_CF_CONNECTING_IP'] ?? '')
       : ($mode === 'forwarded' ? trim(explode(',', (string)($_SERVER['HTTP_X_FORWARDED_FOR'] ?? ''))[0]) : '');
    if ($h !== '' && filter_var($h, FILTER_VALIDATE_IP)) $ip = $h;
    return substr($ip, 0, 45);
}

/** True if this IP/key has made too many attempts recently. */
function rate_limited(string $key, int $max, int $windowMinutes): bool
{
    $since = gmdate('Y-m-d H:i:s', time() - $windowMinutes * 60);
    $n = (int)q_val('SELECT COUNT(*) FROM login_attempts WHERE ip = ? AND username = ? AND attempted_at > ?',
        [client_ip(), $key, $since]);
    return $n >= $max;
}

function record_attempt(string $key): void
{
    db_insert('login_attempts', ['ip' => client_ip(), 'username' => $key, 'attempted_at' => now()]);
    // Housekeeping: drop attempts older than a day.
    if (random_int(1, 50) === 1) {
        q('DELETE FROM login_attempts WHERE attempted_at < ?', [gmdate('Y-m-d H:i:s', time() - 86400)]);
    }
}

function clear_attempts(string $key): void
{
    q('DELETE FROM login_attempts WHERE ip = ? AND username = ?', [client_ip(), $key]);
}

// ======================= Settings =======================

/** Every admin-editable game setting lives here, with its default. */
/** v0.9.0: how energy comes back: [energy each time, seconds between]. */
function energy_tick(): array
{
    return [max(1, min(5, (int)setting('energy_regen_amount'))), max(30, min(600, (int)setting('energy_regen_seconds')))];
}

/** "1 energy every minute", "2 energy every 30 seconds". */
function energy_rate_text(): string
{
    [$n, $sec] = energy_tick();
    $every = $sec === 60 ? 'minute' : ($sec < 60 ? $sec . ' seconds' : rtrim(rtrim(number_format($sec / 60, 1), '0'), '.') . ' minutes');
    return $n . ' energy every ' . $every;
}

function settings_schema(): array
{
    static $schema = null;   // v1.0.0: built once per request (it is ~300 entries and setting() falls back to it for every default)
    if ($schema !== null) return $schema;
    require_once __DIR__ . '/social169.php';   // v1.6.9: friend watering + garden reactions
    require_once __DIR__ . '/mail_nudge.php';   // v1.6.8: reminder email settings
    require_once __DIR__ . '/social.php';   // v1.0.0 wave 3: its settings are added at the end
    require_once __DIR__ . '/market100.php';   // v1.0.0 wave 2b: orders, market day and price settings
    require_once __DIR__ . '/garden_world.php';   // v1.0.0 wave 2a: seasons, weather, pests and animals in the garden
    require_once __DIR__ . '/mentors120.php';   // v1.2.0: player mentors
    require_once __DIR__ . '/trek_data.php';   // v1.8.0: Treks
    require_once __DIR__ . '/delve_map.php';   // v2.0.6: Delves: map view
    require_once __DIR__ . '/emoji_icons.php';   // v2.0.23: emoji to icons
    return $schema = [
        'site_name'          => ['label' => 'Site: name', 'type' => 'text', 'default' => 'Gnome Venture'],
        'vote_url'           => ['label' => 'Site: vote link (footer; blank hides it)', 'type' => 'text', 'default' => 'https://vibetoplist.com/listing/gnome-venture'],
        'site_tagline'       => ['label' => 'Site: tagline', 'type' => 'text', 'default' => 'Grow, tend, trade, explore.'],
        'motd'               => ['label' => 'Site: message of the day (home page)', 'type' => 'textarea', 'default' => 'Welcome, new gardener! Open your Almanac to begin.'],
        'registration_open'  => ['label' => 'Sign-ups: allow new sign-ups', 'type' => 'bool', 'default' => '1'],
        'maintenance_mode'   => ['label' => 'Maintenance: only admins can use the site', 'type' => 'bool', 'default' => '0'],
        'maintenance_message'=> ['label' => 'Maintenance: message', 'type' => 'text', 'default' => 'The garden gates are closed for tending. Back soon!'],
        'currency_name'      => ['label' => 'Currency: name', 'type' => 'text', 'default' => 'Petals'],
        'starting_coins'     => ['label' => 'Start: currency', 'type' => 'int', 'default' => '500', 'min' => 0, 'max' => 1000000],
        'starting_plot_size' => ['label' => 'Start: plot size (squares per side)', 'type' => 'int', 'default' => '4', 'min' => 2, 'max' => 20],
        'max_plot_size'      => ['label' => 'Plots: biggest size (squares per side)', 'type' => 'int', 'default' => '12', 'min' => 2, 'max' => 30],
        'bed_add_cost'       => ['label' => 'Add 4 beds: Petals for the first purchase (v0.9.5; each later one costs more, see growth %)', 'type' => 'int', 'default' => '200', 'min' => 0, 'max' => 100000000],
        'bed_add_items'      => ['label' => 'Add 4 beds: items for the first purchase (slug:qty, comma separated)', 'type' => 'text', 'default' => 'timber-plank:2'],
        'bed_add_growth_pct' => ['label' => 'Add 4 beds: each purchase costs this % more than the one before (Petals and items)', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 1000],
        'starter_items'      => ['label' => 'Start: items (slug:qty, comma separated)', 'type' => 'text', 'default' => 'radish-seed:6,lettuce-seed:4,carrot-seed:4,tomato-seed:2,worn-trowel:1,tin-watering-can:1,foraging-knife:1,plain-compost:6,cardboard-sheet:2,straw-mulch:2'],
        'home_seed_qty'      => ['label' => 'Start: seeds of each home-region staple crop given at sign-up', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 100],
        'energy_regen_amount' => ['label' => 'Energy: regained each time', 'type' => 'select', 'default' => '1', 'options' => ['1' => '1 energy', '2' => '2 energy', '3' => '3 energy', '4' => '4 energy', '5' => '5 energy']],   // v0.9.0
        'energy_regen_seconds' => ['label' => 'Energy: regained every … seconds', 'type' => 'select', 'default' => '60', 'options' => ['30' => '30 seconds', '60' => '1 minute', '90' => '1½ minutes', '120' => '2 minutes', '150' => '2½ minutes', '180' => '3 minutes', '300' => '5 minutes']],
        'energy_per_level'   => ['label' => 'Energy: extra max for each gnome level after 1', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 1000],
        'travel_cost'        => ['label' => 'Travel: cost to go to another region (home is free)', 'type' => 'int', 'default' => '150', 'min' => 0, 'max' => 1000000],
        'travel_energy'      => ['label' => 'Travel: energy to go to another region', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 1000],
        'notill_level'       => ['label' => 'No-till: gnome level when Wren teaches it', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 100],
        'amend_minutes'      => ['label' => 'Soil improvers: minutes one takes to work in when the item doesn’t set its own', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 120],
        'amend_max_minutes'  => ['label' => 'Soil improvers: longest any takes to work in (minutes)', 'type' => 'int', 'default' => '15', 'min' => 1, 'max' => 120],
        'amend_max_fertility' => ['label' => 'Soil improvers: fertility above which they can’t be added', 'type' => 'int', 'default' => '90', 'min' => 10, 'max' => 100],
        'broadfork_days'     => ['label' => 'Broadfork: days before it can loosen the same bed again', 'type' => 'int', 'default' => '7', 'min' => 0, 'max' => 60],
        'luck_percent_per_2' => ['label' => 'Luck: % bonus for every 2 points (extra harvests, critical hits)', 'type' => 'text', 'default' => '0.05'],
        'blocked_words'      => ['label' => 'Word filter: blocked words in names and notes (comma separated; whole words, and longer words even with dots between letters)', 'type' => 'text', 'default' => 'fuck,shit,cunt,bitch,asshole,bastard,dickhead,whore,slut,wanker'],
        'season_mode'        => ['label' => 'Seasons: follow…', 'type' => 'select', 'default' => 'game', 'options' => ['game' => 'The game calendar (each season lasts the number of days below)', 'real' => 'The real calendar (northern hemisphere: spring starts 1 March)']],
        'season_days'        => ['label' => 'Seasons: real days each season lasts', 'type' => 'int', 'default' => '14', 'min' => 3, 'max' => 120],
        'season_epoch'       => ['label' => 'Seasons: the date spring day 1 began (YYYY-MM-DD)', 'type' => 'text', 'default' => '2026-01-01'],
        'season_force'       => ['label' => 'Seasons: force a season (testing; blank = follow the calendar)', 'type' => 'select', 'default' => '', 'options' => ['' => 'Follow the calendar', 'spring' => 'Always spring', 'summer' => 'Always summer', 'autumn' => 'Always autumn', 'winter' => 'Always winter']],
        'weather_force'      => ['label' => 'Weather: force today’s weather (testing; blank = normal)', 'type' => 'select', 'default' => '', 'options' => ['' => 'Normal weather', 'sun' => 'Sunny', 'cloud' => 'Cloudy', 'rain' => 'Rain', 'storm' => 'Storm', 'frost' => 'Frost', 'heat' => 'Heat', 'wind' => 'Wind', 'fog' => 'Fog', 'snow' => 'Snow']],
        'weather_regions'    => ['label' => 'Weather: regions have their own weather leanings (rainy, dry, stormy...)', 'type' => 'bool', 'default' => '1'],
        'weather_weights_spring' => ['label' => 'Weather: chances in spring (weight per weather: sun, cloud, rain, storm, frost, heat, wind, fog, snow; 0 = never)', 'type' => 'text', 'default' => HOLLOW_WEIGHT_DEFAULTS['spring']],
        'weather_weights_summer' => ['label' => 'Weather: chances in summer (weight per weather: sun, cloud, rain, storm, frost, heat, wind, fog, snow; 0 = never)', 'type' => 'text', 'default' => HOLLOW_WEIGHT_DEFAULTS['summer']],
        'weather_weights_autumn' => ['label' => 'Weather: chances in autumn (weight per weather: sun, cloud, rain, storm, frost, heat, wind, fog, snow; 0 = never)', 'type' => 'text', 'default' => HOLLOW_WEIGHT_DEFAULTS['autumn']],
        'weather_weights_winter' => ['label' => 'Weather: chances in winter (weight per weather: sun, cloud, rain, storm, frost, heat, wind, fog, snow; 0 = never)', 'type' => 'text', 'default' => HOLLOW_WEIGHT_DEFAULTS['winter']],
        'daypart_dawn'       => ['label' => 'Time of day: dawn starts at hour (0-23)', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 23],
        'daypart_day'        => ['label' => 'Time of day: day starts at hour', 'type' => 'int', 'default' => '7', 'min' => 0, 'max' => 23],
        'daypart_dusk'       => ['label' => 'Time of day: dusk starts at hour', 'type' => 'int', 'default' => '18', 'min' => 0, 'max' => 23],
        'daypart_night'      => ['label' => 'Time of day: night starts at hour', 'type' => 'int', 'default' => '21', 'min' => 0, 'max' => 23],
        'map_style'          => ['label' => 'Maps: fallback style when a map picture is missing (the world and region maps are the underground pixel-art pictures whenever assets/img/scenes/map-world.png / map-CODE.png are there)', 'type' => 'select', 'default' => 'mycelium', 'options' => ['mycelium' => 'Mycelium cross-section (regions at their depth, with folk, quests and gathering overlays)', 'classic' => 'Classic (islands on a sea; the old maps)']],   // v1.6.0
        'stop_slots'         => ['label' => 'Rest stops: things to do on one visit (a visit starts when you arrive)', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 9],
        'stop_daily_cap'     => ['label' => 'Rest stops: most things per day at one stop', 'type' => 'int', 'default' => '8', 'min' => 1, 'max' => 50],
        'stop_daily_total'   => ['label' => 'Rest stops: after this many things in a day (all stops), Petals and XP are halved (no hard limit)', 'type' => 'int', 'default' => '100', 'min' => 1, 'max' => 1000],   // v1.4.9: was a hard cap of 15
        'stop_rest_daily'    => ['label' => 'Rest stops: most resting activities (baths, benches, kettles) per day', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 20],
        'stop_core'          => ['label' => 'Rest stops: always-there activities at each stop', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 8],
        'stop_extra'         => ['label' => 'Rest stops: extra activities that change every day', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 8],
        'stop_reward_percent' => ['label' => 'Rest stops: coin and XP rewards, as a % of the table values', 'type' => 'int', 'default' => '100', 'min' => 0, 'max' => 1000],
        'stop_chat_fp'       => ['label' => 'Rest stops: friendship points for the daily chat with a villager', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 20],
        'stop_errand_max'    => ['label' => 'Rest stops: most errands carried at once', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 20],
        'stop_errands_offered' => ['label' => 'Rest stops: how many villagers per stop offer an errand each day (0 = none)', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 5],   // v1.3.0
        'stop_errand_days'   => ['label' => 'Rest stops: days to finish an errand', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 30],
        'stop_adopt_limit'   => ['label' => 'Rest stops: most stops one gnome can look after (everyone starts with 1, +1 per stop finished to its Hall; 0 = adopting off)', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 20],   // v1.6.3: default 3, the max (slots grow with finished stops)
        'stop_adopt_cost'    => ['label' => 'Rest stops: fee to adopt a stop (currency)', 'type' => 'int', 'default' => '300', 'min' => 0, 'max' => 1000000],
        'stop_daypart_force' => ['label' => 'Rest stops: force a time of day (testing; blank = the real clock)', 'type' => 'select', 'default' => '', 'options' => ['' => 'Follow the clock', 'dawn' => 'Always dawn', 'day' => 'Always day', 'dusk' => 'Always dusk', 'night' => 'Always night']],
        'game_timezone'      => ['label' => 'Time zone: the Hollow’s home time zone (NPC shifts, opening hours). A name like America/Halifax, Europe/London or UTC', 'type' => 'text', 'default' => 'America/Halifax'],
        'event_chance'       => ['label' => 'Random events: about 1 in … page views', 'type' => 'int', 'default' => '150', 'min' => 2, 'max' => 100000],
        'event_cooldown_minutes' => ['label' => 'Random events: at least … minutes apart', 'type' => 'int', 'default' => '120', 'min' => 0, 'max' => 10080],
        'event_daily_max'    => ['label' => 'Random events: most per gnome per day', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 100],
        'job_reset_hour_utc' => ['label' => 'Daily jobs: not used since 1.2.2 (day turns over at midnight Hollow time)', 'type' => 'int', 'default' => '4', 'min' => 0, 'max' => 23],
        'job_streak_every'   => ['label' => 'Daily jobs: bonus every … daily jobs finished', 'type' => 'int', 'default' => '7', 'min' => 1, 'max' => 100],
        'job_streak_bonus_coins' => ['label' => 'Daily jobs: streak bonus (currency)', 'type' => 'int', 'default' => '300', 'min' => 0, 'max' => 100000],
        'worm_rounds_per_day' => ['label' => 'Worm Hunting: digs per day', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 50],
        'worm_digs'          => ['label' => 'Worm Hunting: digs per go (before rock pick bonus)', 'type' => 'int', 'default' => '10', 'min' => 3, 'max' => 36],
        'worm_count'         => ['label' => 'Worm Hunting: worms hidden in each dig', 'type' => 'int', 'default' => '8', 'min' => 1, 'max' => 20],
        'worm_coins_per_point' => ['label' => 'Worm Hunting: currency per point', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 1000],
        'puzzles_open' => ['label' => 'Games: Puzzles (hub + GIFsaw) open to every player (off = admins only) (v2.0.2)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off (admins only)', '1' => 'On']],
        'pz_barrel_open' => ['label' => 'Puzzles: Rain Barrel open to every player (off = admins only; needs Puzzles open) (v2.0.71)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off (admins only)', '1' => 'On']],
        'guest_open' => ['label' => 'Guests: visitors can play a guest garden without an account (v2.0.75)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off', '1' => 'On']],
        'guest_max_per_ip_day' => ['label' => 'Guests: new guest gardens per connection per day (v2.0.75)', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 50],
        'guest_max_total' => ['label' => 'Guests: most guest gardens alive at once (v2.0.75)', 'type' => 'int', 'default' => '200', 'min' => 1, 'max' => 5000],
        'guest_ttl_hours' => ['label' => 'Guests: a guest garden is deleted after this many idle hours (v2.0.75)', 'type' => 'int', 'default' => '24', 'min' => 1, 'max' => 720],
        'pz_beds_open' => ['label' => 'Puzzles: Gnome Beds open to every player (off = admins only; needs Puzzles open) (v2.0.72)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off (admins only)', '1' => 'On']],
        'pz_daily_petals' => ['label' => 'Puzzles: Petals for the first daily win of each puzzle game, once a day (v2.0.71)', 'type' => 'int', 'default' => '15', 'min' => 0, 'max' => 500],
        'puzzles_front' => ['label' => 'Front page: logged-out visitors can play a GIFsaw demo (v2.0.69)', 'type' => 'select', 'default' => '1', 'options' => ['1' => 'On', '0' => 'Off']],
        'jigsaw_open' => ['label' => 'Puzzles: Jigsaw (classic still-picture jigsaws, Easy / Advanced / Expert) open to every player (off = admins only; needs Puzzles open) (v2.0.87)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off (admins only)', '1' => 'On']],
        'jigsaw_tournaments' => ['label' => 'Puzzles: Jigsaw tournaments (needs Jigsaw open) (v2.0.87)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off', '1' => 'On']],
        'jigsaw_tries_easy' => ['label' => 'Jigsaw tournaments: timed goes per day, Easy (v2.0.87)', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 50],
        'jigsaw_tries_advanced' => ['label' => 'Jigsaw tournaments: timed goes per day, Advanced (v2.0.87)', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 50],
        'jigsaw_tries_expert' => ['label' => 'Jigsaw tournaments: timed goes per day, Expert (v2.0.87)', 'type' => 'int', 'default' => '5', 'min' => 1, 'max' => 50],
        'jigsaw_reserve_days' => ['label' => 'Jigsaw tournaments: days a settled tournament’s picture waits before it joins free play (0 = at once) (v2.0.87)', 'type' => 'int', 'default' => '0', 'min' => 0, 'max' => 60],
        'ppal_open' => ['label' => 'Puzzle Pals: pals released by an Advanced Jigsaw solve, found on pages (needs Jigsaw open; off = admins only) (v2.0.88)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off (admins only)', '1' => 'On']],
        'ppal_chance' => ['label' => 'Puzzle Pals: a find on a page view is 1 in this many (v2.0.88)', 'type' => 'int', 'default' => '60', 'min' => 5, 'max' => 5000],
        'ppal_cooldown_minutes' => ['label' => 'Puzzle Pals: minutes between finds (v2.0.88)', 'type' => 'int', 'default' => '30', 'min' => 0, 'max' => 1440],
        'ppal_daily_max' => ['label' => 'Puzzle Pals: most finds per gnome per day (v2.0.88)', 'type' => 'int', 'default' => '4', 'min' => 0, 'max' => 100],
        'ppal_party' => ['label' => 'Puzzle Pals: gnomes can take pals along (perks, shown beside the gnome; the Expert trophy adds +1 unit) (v2.0.88)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off', '1' => 'On']],
        'ppal_party_max' => ['label' => 'Puzzle Pals: pals a gnome can take along (v2.0.88)', 'type' => 'int', 'default' => '2', 'min' => 1, 'max' => 3],
        'ppal_roster_size' => ['label' => 'Puzzle Pals: pals per picture (6 = 3 common, 2 uncommon, 1 rare; authored rosters are cut to this) (v2.0.88)', 'type' => 'int', 'default' => '6', 'min' => 1, 'max' => 6],
        'puzzles_tournaments' => ['label' => 'Games: Puzzle tournaments (best time on one picture, trophies and badges only; needs Puzzles open) (v2.0.68)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off', '1' => 'On']],
        'games_petals_percent' => ['label' => 'Games: Petals paid, % of the normal payout (Worms, Memory, Spit, Mushroom, Pest Patrol, Letters)', 'type' => 'int', 'default' => '60', 'min' => 0, 'max' => 300],   // v1.7.6: games out-earned the garden
        'memory_plays_per_day' => ['label' => 'Seed Memory: games per day', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 50],
        'spit_plays_per_day' => ['label' => 'Seed Spitting: goes per day', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 50],
        'spit_game_on'       => ['label' => 'Seed Spitting: aim-and-power physics game (off = quick spit only)', 'type' => 'bool', 'default' => '1'],   // v1.4.0:
        'spit_wind_max'      => ['label' => 'Seed Spitting: strongest wind (cm/s; a lucky gust is 1.5×)', 'type' => 'int', 'default' => '60', 'min' => 0, 'max' => 120],   // v1.4.0:
        'spit_min_ms'        => ['label' => 'Seed Spitting: least time (ms) between loading a seed and spitting it', 'type' => 'int', 'default' => '1000', 'min' => 0, 'max' => 10000],   // v1.4.0:
        'worm_wander'        => ['label' => 'Worm Hunting: % chance a worm wriggles one square after each dig (0 = still worms)', 'type' => 'int', 'default' => '35', 'min' => 0, 'max' => 100],   // v1.4.0:
        'mush_plays_per_day' => ['label' => 'Mushroom Sweeper: games per day', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 50],
        // v1.4.8: Pest Patrol
        'pest_plays_per_day' => ['label' => 'Pest Patrol: rounds per day', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 50],
        'pest_butterfly_pct' => ['label' => 'Pest Patrol: % chance a butterfly wanders across the plant in a round', 'type' => 'int', 'default' => '15', 'min' => 0, 'max' => 100],
        'pest_charm_pct'     => ['label' => 'Pest Patrol: % chance a perfect round (every pest flicked, no lost leaves, at most 2 stray taps) wins a Ladybird Charm', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 100],
        'pest_charm_per_day' => ['label' => 'Pest Patrol: most Ladybird Charms a gnome can win a day (a perfect round with no lost leaves)', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 20],
        'care_star_points'   => ['label' => 'Soil care: points for each star (1 point a day per square), 5 numbers', 'type' => 'text', 'default' => '3,7,14,21,30'],
        'care_growth_percent' => ['label' => 'Soil care: faster growth per star (%)', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 20],
        'care_min_life'      => ['label' => 'Soil care: soil life needed at harvest to earn a point', 'type' => 'int', 'default' => '25', 'min' => 0, 'max' => 100],
        'care_decay_days'    => ['label' => 'Soil care: wild ground loses a star every N days', 'type' => 'int', 'default' => '7', 'min' => 1, 'max' => 365],
        'fair_min_entries'   => ['label' => 'Harvest Fair: gnomes needed in a class for full prizes (fewer = half), and in the fair for Best in Show', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 50],
        'feedback_per_day'   => ['label' => 'Feedback: notes a player can send per day', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 20],
        'letters_per_day'    => ['label' => 'Lost Letters: letters per day', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 5],
        'fair_prize_1'       => ['label' => 'Harvest Fair: 1st place Petals (each class)', 'type' => 'int', 'default' => '600', 'min' => 0, 'max' => 100000],
        'fair_prize_2'       => ['label' => 'Harvest Fair: 2nd place Petals (each class)', 'type' => 'int', 'default' => '300', 'min' => 0, 'max' => 100000],
        'fair_prize_3'       => ['label' => 'Harvest Fair: 3rd place Petals (each class)', 'type' => 'int', 'default' => '150', 'min' => 0, 'max' => 100000],
        'fair_best_in_show'  => ['label' => 'Harvest Fair: Best in Show Petals', 'type' => 'int', 'default' => '1000', 'min' => 0, 'max' => 100000],
        'marrow_guesses_per_day' => ['label' => 'Guess the Weight: guesses per day', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 1],
        'marrow_jackpot'     => ['label' => 'Guess the Weight: jackpot for an exact guess (starts here after a win)', 'type' => 'int', 'default' => '5000', 'min' => 0, 'max' => 10000000],
        'marrow_jackpot_grow' => ['label' => 'Guess the Weight: the jackpot grows this much each day nobody is exact', 'type' => 'int', 'default' => '1000', 'min' => 0, 'max' => 1000000],
        'marrow_jackpot_max' => ['label' => 'Guess the Weight: the jackpot never grows past this', 'type' => 'int', 'default' => '25000', 'min' => 0, 'max' => 10000000],
        'marrow_close_prize' => ['label' => 'Guess the Weight: consolation for the closest guess when nobody is exact (0 = none)', 'type' => 'int', 'default' => '100', 'min' => 0, 'max' => 100000],
        'marrow_min_level'   => ['label' => 'Guess the Weight: gnome level needed to guess', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 1000],
        'marrow_min_days'    => ['label' => 'Guess the Weight: days an account must be in the Hollow before guessing', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 365],
        'race_bets_per_day'  => ['label' => 'Snail Race: bets one gnome can back per day', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 24],
        'race_max_bet'       => ['label' => 'Snail Race: biggest bet', 'type' => 'int', 'default' => '50', 'min' => 1, 'max' => 100000],
        'community_size'     => ['label' => 'Community garden: size (beds per side, 3–10; only used when first created)', 'type' => 'int', 'default' => '6', 'min' => 3, 'max' => 10],
        'community_water_hours' => ['label' => 'Community garden: hours a watering lasts', 'type' => 'int', 'default' => '8', 'min' => 1, 'max' => 48],
        'community_need_coins' => ['label' => 'Community garden: only gnomes with fewer Petals than this may take the daily gift (0 = anyone)', 'type' => 'int', 'default' => '1000', 'min' => 0, 'max' => 100000000],
        'community_tip'      => ['label' => 'Community garden: thank-you per job', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 1000],
        'community_shift_cap' => ['label' => 'Community garden: most jobs per shift', 'type' => 'int', 'default' => '8', 'min' => 1, 'max' => 200],
        'carving_month'      => ['label' => 'Pumpkin carving: month (1–12; 10 = October)', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 12],
        'carving_always'     => ['label' => 'Pumpkin carving: keep it open all year (testing)', 'type' => 'bool', 'default' => '0'],
        'site_url'           => ['label' => 'Site: full web address of the game, for links in emails (e.g. https://sproutling.example.ca)', 'type' => 'text', 'default' => ''],
        'seo_description'    => ['label' => 'Site: search & share description (shown under the link on Google and in link previews; about 150 letters)', 'type' => 'textarea', 'default' => 'A free, cosy browser game about garden gnomes. Grow real-world crops in living soil, cook and craft, trade with friends and explore fourteen regions. No ads, nothing to buy.'],
        'google_site_verification' => ['label' => 'Site: Google Search Console verification code (just the code from the HTML tag)', 'type' => 'text', 'default' => ''],
        'bing_site_verification'   => ['label' => 'Site: Bing Webmaster Tools verification code (just the code from the meta tag)', 'type' => 'text', 'default' => ''],
        'mail_from'          => ['label' => 'Email: sent from (address on your domain; blank = no-reply@your domain)', 'type' => 'text', 'default' => ''],
        'mail_mode'          => ['label' => 'Email: "send" (real email) or "log" (write to the mail log only, for testing)', 'type' => 'text', 'default' => 'send'],
        'trusted_proxy'      => ['label' => 'Proxy: behind a proxy? "none", "cloudflare" or "forwarded" (only change if your host says so)', 'type' => 'text', 'default' => 'none'],
        'trade_min_level'    => ['label' => 'Trading: gnome level needed to trade, gift and use market stalls', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 100],
        'fresh_hold_days'    => ['label' => 'Fresh gnome hold: days before a new gnome can give Petals or items to other players (stops alt accounts)', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 60],   // v1.0.1
        'fresh_hold_level'   => ['label' => 'Fresh gnome hold: gnome level needed to give Petals or items to other players', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 50],   // v1.0.1
        'gifts_per_day'      => ['label' => 'Trading: gifts one gnome can send a day', 'type' => 'int', 'default' => '10', 'min' => 0, 'max' => 1000],
        'trades_open_max'    => ['label' => 'Trading: open trade offers one gnome can have', 'type' => 'int', 'default' => '5', 'min' => 1, 'max' => 100],
        'trade_offer_days'   => ['label' => 'Trading: days before an unanswered trade offer is returned', 'type' => 'int', 'default' => '7', 'min' => 1, 'max' => 60],
        'stall_slots'        => ['label' => 'Market stall: listings on one market stall', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 200],
        'stall_tax_percent'  => ['label' => 'Market stall: market fee taken from stall sales (%)', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 50],
        'saplings_per_day'   => ['label' => 'Saplings: saplings one gnome can raise a day', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 100],
        'sapling_energy'     => ['label' => 'Saplings: energy to raise a sapling', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 100],
        'sapling_head_start' => ['label' => 'Saplings: how grown a planted sapling starts (%)', 'type' => 'int', 'default' => '40', 'min' => 0, 'max' => 90],
        'player_jobs_min_level' => ['label' => 'Player jobs: gnome level needed to post or take player jobs', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 100],
        'player_jobs_max_posted' => ['label' => 'Player jobs: most one gnome can have posted at once', 'type' => 'int', 'default' => '2', 'min' => 1, 'max' => 20],
        'player_job_min_wage' => ['label' => 'Player jobs: smallest wage (per day for tending)', 'type' => 'int', 'default' => '20', 'min' => 0, 'max' => 100000],
        'player_job_listing_days' => ['label' => 'Player jobs: days one stays on the board untaken', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 30],
        'player_tend_actions_per_day' => ['label' => 'Player jobs: tending jobs (water/weed/harvest) per day for full pay', 'type' => 'int', 'default' => '6', 'min' => 1, 'max' => 100],
        'player_tend_xp' => ['label' => 'Player jobs: XP for each tending job in someone else’s garden', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 100],
        'player_job_xp' => ['label' => 'Player jobs: XP for finishing one (×3 for week-long ones)', 'type' => 'int', 'default' => '20', 'min' => 0, 'max' => 1000],
        'helper_visit_hours' => ['label' => 'Hired help: helpers visit every … hours', 'type' => 'int', 'default' => '4', 'min' => 1, 'max' => 24],
        'helper_cut_percent' => ['label' => 'Hired help: share of a harvest a helper keeps (%)', 'type' => 'int', 'default' => '20', 'min' => 0, 'max' => 90],
        // v1.2.2: duplicate helper_xp_percent removed (one entry below)
        'tour_reward_coins'  => ['label' => 'Welcome tour: currency for finishing it', 'type' => 'int', 'default' => '250', 'min' => 0, 'max' => 100000],
        'notill_settle_minutes' =>['label' => 'No-till: minutes a new no-till bed must settle before planting', 'type' => 'int', 'default' => '30', 'min' => 0, 'max' => 10080],
        'notill_weed_hours'  => ['label' => 'No-till: hours for weeds to grow 1 point under mulch (problem at 40)', 'type' => 'int', 'default' => '8', 'min' => 1, 'max' => 1000],
        'notill_weed_hours_bare' => ['label' => 'No-till: hours for weeds to grow 1 point on bare soil', 'type' => 'int', 'default' => '2', 'min' => 1, 'max' => 1000],
        'notill_dry_hours'   => ['label' => 'No-till: hours to lose 1 moisture under mulch', 'type' => 'int', 'default' => '12', 'min' => 1, 'max' => 1000],
        'notill_dry_hours_bare' => ['label' => 'No-till: hours to lose 1 moisture on bare soil', 'type' => 'int', 'default' => '4', 'min' => 1, 'max' => 1000],
        'notill_checkpoint_days' => ['label' => 'No-till: days of continuous neglect before a C/A checkpoint is lost', 'type' => 'int', 'default' => '14', 'min' => 1, 'max' => 365],
        'notill_score_per_hour' => ['label' => 'No-till: grade points per well-kept hour', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 100],
        'stat_points_per_level' => ['label' => 'Stats: points earned per gnome level', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 10],
        'stat_max'           => ['label' => 'Stats: highest any can go', 'type' => 'int', 'default' => '30', 'min' => 10, 'max' => 100],
        'food_perm_cap'      => ['label' => 'Stats: max permanent bonus per stat from eating rare crops', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 50],
        'calling_level'      => ['label' => 'Calling: gnome level to choose a calling', 'type' => 'int', 'default' => '5', 'min' => 1, 'max' => 100],
        'calling_change_cost' => ['label' => 'Calling: Petals for the first change (doubles each time)', 'type' => 'int', 'default' => '500', 'min' => 0, 'max' => 1000000],   // v0.9.1a
        'calling_tier2_level' => ['label' => 'Calling: gnome level for calling tier II (Journeyman)', 'type' => 'int', 'default' => '15', 'min' => 1, 'max' => 100],   // v0.9.1
        'calling_tier3_level' => ['label' => 'Calling: gnome level for calling tier III (Master)', 'type' => 'int', 'default' => '28', 'min' => 1, 'max' => 100],   // v0.9.1
        'calling_quests'     => ['label' => 'Calling: tiers II and III also need the mentor’s chapter (off = level only)', 'type' => 'bool', 'default' => '1'],   // v0.9.4
        'calling_xp_percent' => ['label' => 'Calling: percent of the listed chapter XP paid', 'type' => 'int', 'default' => '25', 'min' => 0, 'max' => 500],   // v0.9.4
        'garden_unlock_levels' => ['label' => 'Gardens: gnome levels that unlock another garden (comma separated)', 'type' => 'text', 'default' => '10,25,40'],
        'land_deed_cost'     => ['label' => 'Gardens: land deed price (multiplied by how many gardens you already own)', 'type' => 'int', 'default' => '5000', 'min' => 0, 'max' => 100000000],
        'climate_on'         => ['label' => 'Region climates affect growing, watering, weeds and walks (edit each one in Admin → Regions)', 'type' => 'bool', 'default' => '1'],
        'climate_fast_minutes' => ['label' => 'Climate: crops with this grow time (minutes) or less count as quick crops', 'type' => 'int', 'default' => '30', 'min' => 1, 'max' => 10000],
        'native_bonus_percent' => ['label' => 'Climate: extra growth speed (%) for crops grown in their native region', 'type' => 'int', 'default' => '25', 'min' => 0, 'max' => 500],
        'seed_save_chance'   => ['label' => 'Seeds: chance (%) to save a seed on each harvest', 'type' => 'int', 'default' => '60', 'min' => 0, 'max' => 100],
        'helper_xp_percent'  => ['label' => 'Hired help: XP (% of normal)', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 100],
        'helper_reward_percent' => ['label' => 'Hired help: rewards (% of normal)', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 100],
        'max_energy'         => ['label' => 'Energy: max at gnome level 1', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 10000],
        'sell_mult_uncommon' => ['label' => 'Selling to shops: Uncommon items fetch (% of a Common item’s price)', 'type' => 'int', 'default' => '130', 'min' => 1, 'max' => 10000],
        'sell_mult_rare'     => ['label' => 'Selling to shops: Rare items fetch (%)', 'type' => 'int', 'default' => '180', 'min' => 1, 'max' => 10000],
        'sell_mult_legendary' => ['label' => 'Selling to shops: Legendary items fetch (%)', 'type' => 'int', 'default' => '250', 'min' => 1, 'max' => 10000],
        'regrow_yield_percent' => ['label' => 'Perennials: harvests after the first give this % of the crop', 'type' => 'int', 'default' => '75', 'min' => 1, 'max' => 100],
        'regrow_xp_percent'  => ['label' => 'Perennials: harvests after the first give this % of the XP', 'type' => 'int', 'default' => '60', 'min' => 0, 'max' => 100],
        'xp_steep_from'      => ['label' => 'Gnome levels: from this level on, each level needs extra XP', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 1000],
        'xp_steep_percent'   => ['label' => 'Gnome levels: extra XP needed per level past that point (%)', 'type' => 'int', 'default' => '20', 'min' => 0, 'max' => 1000],   // v0.9.1: 10 -> 20
        // v0.9.7 mid/late game: action XP, easy roads, quick walks on roads far below you
        'xp_action_scale_percent' => ['label' => 'Gnome levels: action XP (harvest, cook, craft, fight): extra % per gnome level past the XP-steep level (quest, chapter and milestone XP are not scaled)', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 1000],
        'easy_roads_below'   => ['label' => 'Easy roads: on by default for gnomes below this level (used when upgrading older worlds; new gnomes start with it on; anyone can switch it any time on My Gnome)', 'type' => 'int', 'default' => '5', 'min' => 1, 'max' => 1000],
        'easy_roads_gap'     => ['label' => 'Easy roads: near-home encounters stay this many levels below the gnome (never bosses)', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 100],
        'low_road_gap'       => ['label' => 'Quick walks: a road whose top level is this many levels (or more) below the gnome is a quick walk', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 1000],
        'low_road_time_pct'  => ['label' => 'Quick walks: walking time on such a road (% of normal)', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 100],
        'road_roll_creature' => ['label' => 'Road: creature %', 'type' => 'int', 'default' => '40', 'min' => 0, 'max' => 100],   // v2.0.16: weights of the road roll (they need not add up to 100; all 0 = the shipped split)
        'road_roll_problem' => ['label' => 'Road: problem %', 'type' => 'int', 'default' => '22', 'min' => 0, 'max' => 100],   // v2.0.16: weights of the road roll (they need not add up to 100; all 0 = the shipped split)
        'road_roll_choice' => ['label' => 'Road: choice %', 'type' => 'int', 'default' => '14', 'min' => 0, 'max' => 100],   // v2.0.16: weights of the road roll (they need not add up to 100; all 0 = the shipped split)
        'road_roll_find' => ['label' => 'Road: find %', 'type' => 'int', 'default' => '24', 'min' => 0, 'max' => 100],   // v2.0.16: weights of the road roll (they need not add up to 100; all 0 = the shipped split)
        'compost_heap_scraps' => ['label' => 'Compost Bin: scraps (harvests, dug-up plants, weedings) for each heap compost', 'type' => 'int', 'default' => '8', 'min' => 1, 'max' => 1000],
        'compost_heap_scraps_2' => ['label' => 'Compost Bin: level 2+ scraps for each heap compost', 'type' => 'int', 'default' => '6', 'min' => 1, 'max' => 1000],
        'compost_heap_max'   => ['label' => 'Compost Bin: most heap compost waiting to be collected', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 1000],
        // v0.9.4 cooking: raw food energy, tiers, scraps, bin recipes
        'raw_energy_values'  => ['label' => 'Food energy: raw everyday crops and forage, filling ones (tubers, legumes, grains), comma separated. Read when raw energy is (re)applied.', 'type' => 'text', 'default' => '1,2'],
        'cook_energy_percent' => ['label' => 'Cooking: home-cooked dishes, energy eaten is this % of the dish’s number (115 = a little extra for home cooking; 100 = as written; shop-bought and raw food are not scaled)', 'type' => 'int', 'default' => '115', 'min' => 0, 'max' => 1000], // v1.1.0
        'cook_energy_tiers'  => ['label' => 'Cooking: energy to cook one dish: snack, meal, feast (comma separated)', 'type' => 'text', 'default' => '0,1,2'],
        'cook_minutes_tiers' => ['label' => 'Cooking: cook time in minutes: snack, meal, feast (used for new recipes; each recipe keeps its own in Admin → Recipes)', 'type' => 'text', 'default' => '3,15,45'],
        'snack_batch_max'    => ['label' => 'Cooking: snacks made in one go (new recipes; each recipe keeps its own in Admin → Recipes)', 'type' => 'int', 'default' => '5', 'min' => 1, 'max' => 100],
        'kitchen_pots'       => ['label' => 'Cooking: pots for Kitchen level I, II, III (comma separated; 0 = no pots, dishes are cooked instantly)', 'type' => 'text', 'default' => '2,3,4'],   // v0.9.4 part 2
        'stack_kitchen_buff_pct' => ['label' => 'Stacking: meal buff time, % extra per Kitchen level in your other gardens (the best Kitchen counts fully)', 'type' => 'int', 'default' => '10', 'min' => 0, 'max' => 100],
        'stack_kitchen_buff_max' => ['label' => 'Stacking: most meal buff time bonus (%) all Kitchens can give together', 'type' => 'int', 'default' => '100', 'min' => 0, 'max' => 1000],
        'stack_kitchen_xp_pct' => ['label' => 'Stacking: cooking XP, % extra per Kitchen level in your other gardens', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 100],
        'stack_kitchen_xp_max' => ['label' => 'Stacking: most cooking XP bonus (%) all Kitchens can give together', 'type' => 'int', 'default' => '100', 'min' => 0, 'max' => 1000],
        'stack_kitchen_pot_per_iii' => ['label' => 'Stacking: extra pots for each Kitchen III in your other gardens', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 5],
        'stack_kitchen_pot_max' => ['label' => 'Stacking: most extra pots other gardens can give', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 10],
        'cook_xp_tiers'      => ['label' => 'Cooking: XP for each pot collected: snack, meal, feast (comma separated)', 'type' => 'text', 'default' => '1,5,15'],
        'cook_scraps_per'    => ['label' => 'Cooking: returns 1 Food Scrap per this many ingredient items', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 1000],
        'image_max_kb'       => ['label' => 'Images: biggest picture file you can upload, in KB (the server’s own upload limit may be lower)', 'type' => 'int', 'default' => '1024', 'min' => 50, 'max' => 8192],
        'curio_count'        => ['label' => 'Curio Cabinet: how many rare decor pieces are in the cabinet each week (4-6)', 'type' => 'int', 'default' => '5', 'min' => 4, 'max' => 6],
        'curio_item_limit'   => ['label' => 'Curio Cabinet: how many of each curio one gnome can buy a week', 'type' => 'int', 'default' => '1', 'min' => 1, 'max' => 10],
        'curio_price_pct'    => ['label' => 'Curio Cabinet: price as % of each item’s base price (change an item’s own price in Admin → Items)', 'type' => 'int', 'default' => '100', 'min' => 10, 'max' => 1000],
        'skin_prices'        => ['label' => 'Building looks: price of Mossy, Painted, Lantern-lit (comma separated; bought once per gnome per building)', 'type' => 'text', 'default' => '1500,2500,4000'],
        'skin_appeal'        => ['label' => 'Building looks: curb appeal added by Mossy, Painted, Lantern-lit (comma separated)', 'type' => 'text', 'default' => '1,2,3'],
        'sign_prices'        => ['label' => 'Garden signposts: price of Oak, Painted, Iron, Gilded (comma separated; bought once per garden)', 'type' => 'text', 'default' => '1200,2200,3600,6000'],
        'dye_prices'         => ['label' => 'Dyes: hat and beard, price of a pot of garden, rare, gilded dye (comma separated)', 'type' => 'text', 'default' => '800,2500,6000'],
        // v0.9.8 part A: the Pantry (a Kitchen add-on with jars)
        'pantry_cost'        => ['label' => 'Pantry (Kitchen add-on): Petals to add one to a Kitchen', 'type' => 'int', 'default' => '600', 'min' => 0, 'max' => 10000000],
        'pantry_materials'   => ['label' => 'Pantry: materials to add one (slug:qty, …)', 'type' => 'text', 'default' => 'timber-plank:4'],
        'pantry_jars'        => ['label' => 'Pantry: jars you start with', 'type' => 'int', 'default' => '5', 'min' => 1, 'max' => 100],
        'pantry_jars_k3'     => ['label' => 'Pantry: extra jars when a Kitchen with a Pantry is level III', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 100],
        'stack_pantry_jar_per' => ['label' => 'Stacking: extra jars for each Pantry in your other gardens', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 10],
        'stack_pantry_jar_max' => ['label' => 'Stacking: most extra jars other gardens’ Pantries can give', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 20],
        'pantry_energy'      => ['label' => 'Pantry: energy to start one batch in a jar (new preserve recipes; each recipe keeps its own in Admin → Recipes)', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 100],
        // v0.9.9 part A: flowers (arranging, drying, seed packets, florist volunteering)
        'arrange_energy'     => ['label' => 'Flowers: energy to make one arrangement', 'type' => 'int', 'default' => '2', 'min' => 0, 'max' => 100],
        'arrange_min_stems'  => ['label' => 'Flowers: fewest stems in an arrangement', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 9],
        'arrange_value_pct'  => ['label' => 'Flowers: arrangement value as % of its stems’ prices times the score bonus (100 = standard)', 'type' => 'int', 'default' => '100', 'min' => 10, 'max' => 1000],
        'arrange_prizes'     => ['label' => 'Flowers: show Petals for 1st, 2nd, 3rd and everyone else (comma separated)', 'type' => 'text', 'default' => '800,400,200,25'],
        'dry_hours'          => ['label' => 'Flowers: real hours a bundle hangs to dry', 'type' => 'int', 'default' => '24', 'min' => 1, 'max' => 720],
        'dry_racks'          => ['label' => 'Flowers: drying bundles a gnome can hang at once', 'type' => 'int', 'default' => '4', 'min' => 1, 'max' => 50],
        'dry_per_rack'       => ['label' => 'Flowers: most stems in one drying bundle', 'type' => 'int', 'default' => '6', 'min' => 1, 'max' => 50],
        'dried_price_pct'    => ['label' => 'Flowers: a dried flower is worth this % of the cut flower', 'type' => 'int', 'default' => '125', 'min' => 50, 'max' => 500],
        'packet_seeds'       => ['label' => 'Seed packets: seeds in one packet (and needed to make one)', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 50],
        'packet_fee'         => ['label' => 'Seed packets: Petals to pack one', 'type' => 'int', 'default' => '20', 'min' => 0, 'max' => 100000],
        'packets_per_day'    => ['label' => 'Seed packets: how many one gnome can pack a day', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 100],
        'florist_minutes'    => ['label' => 'Florist volunteering: minutes a shift takes (real time)', 'type' => 'int', 'default' => '30', 'min' => 1, 'max' => 1440],
        'florist_energy'     => ['label' => 'Florist volunteering: energy to start a shift', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 100],
        'florist_xp'         => ['label' => 'Florist volunteering: XP for a finished shift', 'type' => 'int', 'default' => '6', 'min' => 0, 'max' => 1000],
        'florist_friend'     => ['label' => 'Florist volunteering: friendship points with the florist on duty', 'type' => 'int', 'default' => '6', 'min' => 0, 'max' => 100],
        'florist_shifts_day' => ['label' => 'Florist volunteering: shifts one gnome can do a day', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 48],
        'florist_stems'      => ['label' => 'Florist volunteering: fewest and most cut flowers in the bundle (e.g. 3,5)', 'type' => 'text', 'default' => '3,5'],
        'feast_petal_fee'    => ['label' => 'Cooking: Petals per feast made (firewood and spices; 0 = free)', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 1000000],
        'shop_food_energy_pct' => ['label' => 'Cooking: shop-bought dishes give this % of the home-cooked energy (at least 1, at most 4)', 'type' => 'int', 'default' => '25', 'min' => 0, 'max' => 100],
        'tour_free_actions'  => ['label' => 'Welcome tour: first till, soil, plant, water and harvest cost no energy', 'type' => 'bool', 'default' => '1'],
        'scrap_compost_cost' => ['label' => 'Compost: Food Scraps for 1 Plain Compost without a Compost Bin (satchel craft)', 'type' => 'int', 'default' => '12', 'min' => 1, 'max' => 1000],
        'heap_scraps_leaf_mould' => ['label' => 'Compost Bin: II+ heap scraps for each Leaf Mould', 'type' => 'int', 'default' => '12', 'min' => 1, 'max' => 1000],
        'heap_scraps_castings' => ['label' => 'Compost Bin: II+ heap scraps for each Worm Castings', 'type' => 'int', 'default' => '20', 'min' => 1, 'max' => 1000],
        'heap_scraps_loam'   => ['label' => 'Compost Bin: III heap scraps for each Rich Loam', 'type' => 'int', 'default' => '40', 'min' => 1, 'max' => 1000],
        'upgrade_cost_percent' => ['label' => 'Building upgrades: Petals for level 2, level 3 (% of the build cost)', 'type' => 'text', 'default' => '150,300'],
        'upgrade_level_gap'  => ['label' => 'Building upgrades: garden levels above the building’s own level needed for level 2, level 3', 'type' => 'text', 'default' => '2,4'],
        'upgrade_materials_2' => ['label' => 'Building upgrades: materials for level 2 (slug:qty, …)', 'type' => 'text', 'default' => 'building-stone:6,timber-plank:6,rope:3'],
        'upgrade_materials_3' => ['label' => 'Building upgrades: materials for level 3 (slug:qty, …)', 'type' => 'text', 'default' => 'building-stone:15,timber-plank:15,rope:8'],
        'favour_pay_percent' => ['label' => 'Townsfolk favours: pay this % of the crops’ base price (120 ≈ twice what a shop pays)', 'type' => 'int', 'default' => '120', 'min' => 0, 'max' => 1000],
        'journey_crate_weeks' => ['label' => 'Wren’s Journey: weekly supply crates keep coming for this many weeks after a chapter is finished (0 = forever)', 'type' => 'int', 'default' => '12', 'min' => 0, 'max' => 1000],
        'guide_price'        => ['label' => 'Gardening guides: base shop price (shops sell them for this to 25% more)', 'type' => 'int', 'default' => '6000', 'min' => 1, 'max' => 100000000],
        'unstudied_yield_percent' => ['label' => 'Unstudied crops (no guide yet): harvest is this % of normal', 'type' => 'int', 'default' => '60', 'min' => 1, 'max' => 100],
        'unstudied_slow_percent' => ['label' => 'Unstudied crops: grow time is this % longer', 'type' => 'int', 'default' => '25', 'min' => 0, 'max' => 1000],
        'harvest_energy_tiers' => ['label' => 'Harvest: energy for everyday, uncommon/flower and treasure crops', 'type' => 'text', 'default' => '1,2,3'],   // v0.7.86: three numbers, in that order (see harvest_energy_cost)
        // v0.7.86: tool wear (see includes/tools.php tool_use)
        'tool_wear_on'       => ['label' => 'Tools: wear out and break', 'type' => 'bool', 'default' => '1'],
        'gather_tool_uses'   => ['label' => 'Tools: gathering tools, walking staff and lantern: uses before breaking, for Worn, Sturdy, Fine, Masterwork (0 = never wears)', 'type' => 'text', 'default' => '60,150,300,600'],
        'garden_tool_days'   => ['label' => 'Tools: garden tools, days of use before breaking, Worn to Masterwork (0 = never wears)', 'type' => 'text', 'default' => '0,45,90,180'],
        'tool_mend_percent'  => ['label' => 'Tools: mending a worn or broken tool costs this % of its price (at least 5 Petals)', 'type' => 'int', 'default' => '15', 'min' => 0, 'max' => 1000],
        'life_tree_days'     => ['label' => 'Perennials: lifespan of trees and nut trees (days)', 'type' => 'int', 'default' => '60', 'min' => 1, 'max' => 3650],
        'life_fruit_days'    => ['label' => 'Perennials: lifespan of fruit bushes and vines (days)', 'type' => 'int', 'default' => '45', 'min' => 1, 'max' => 3650],
        'life_other_days'    => ['label' => 'Perennials: lifespan of herbs, flowers, spices and the rest (days)', 'type' => 'int', 'default' => '30', 'min' => 1, 'max' => 3650],
        'life_end_yield'     => ['label' => 'Perennials: harvest at the end of its life (% of a young plant’s)', 'type' => 'int', 'default' => '80', 'min' => 1, 'max' => 100],
        'cellar_slots'       => ['label' => 'Root cellar: how many perennials it holds', 'type' => 'int', 'default' => '5', 'min' => 1, 'max' => 50],
        'cellar_store_cost'  => ['label' => 'Root cellar: Petals to dig a perennial up into the cellar', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 100000],
        'yard_extend_cost'   => ['label' => 'Yard: cost of an extra column or row (times how many bought so far + 1)', 'type' => 'int', 'default' => '400', 'min' => 0, 'max' => 100000000],
        'yard_extend_max'    => ['label' => 'Yard: most extra columns (and rows) a gnome can buy for one garden', 'type' => 'int', 'default' => '6', 'min' => 0, 'max' => 20],
        'yard_barrel_percent' => ['label' => 'Yard: rain barrel next to a bed makes watering last … % longer', 'type' => 'int', 'default' => '15', 'min' => 0, 'max' => 500],
        'yard_shade_percent' => ['label' => 'Yard: shade tree next to a bed makes watering last … % longer', 'type' => 'int', 'default' => '10', 'min' => 0, 'max' => 500],
        'yard_hive_percent'  => ['label' => 'Yard: pollinator chance (%) for beds within 2 of the beehive (25 elsewhere)', 'type' => 'int', 'default' => '40', 'min' => 0, 'max' => 100],
        'yard_birds_percent' => ['label' => 'Yard: chance (%) of an extra crop from birds (birdbath etc. within 2)', 'type' => 'int', 'default' => '10', 'min' => 0, 'max' => 100],
        'yard_path_free_percent' => ['label' => 'Yard: chance (%) a square beside a path costs no energy in an area action', 'type' => 'int', 'default' => '33', 'min' => 0, 'max' => 100],
        'gotm_votes'         => ['label' => 'Garden of the Month: votes each gnome gets a month', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 100],
        'gotm_vote_level'    => ['label' => 'Garden of the Month: gnome level needed to vote', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 100],
        'gotm_min_appeal'    => ['label' => 'Garden of the Month: curb appeal needed to enter', 'type' => 'int', 'default' => '10', 'min' => 0, 'max' => 10000],
        'gotm_prizes'        => ['label' => 'Garden of the Month: Petals for 1st, 2nd, 3rd (comma separated)', 'type' => 'text', 'default' => '1500,800,400'],
        'start_region'       => ['label' => 'World: region code every new gnome starts in (NA = The Maplewold)', 'type' => 'text', 'default' => 'NA'],
        'road_fixed_below'   => ['label' => 'World: roads in regions below this recommended level stay at the region’s level (only wandering off the road matches the gnome’s level)', 'type' => 'int', 'default' => '25', 'min' => 1, 'max' => 999],
        // v0.7.74: exploring starts at the road stop's level and climbs gently; big creatures are eased outside the wild
        'explore_step_levels' => ['label' => 'Exploring: danger added at each step off the road (steps 1, 2, 3…; past the last one, +2 a step, up to +20)', 'type' => 'text', 'default' => '0,0,1,2,3,5'],
        'dest_max_chain'     => ['label' => 'Routes: most legs a gnome walks on by itself in one journey (then it stops for a breather)', 'type' => 'int', 'default' => '8', 'min' => 1, 'max' => 50],   // v0.9.3
        'explore_warn_from'  => ['label' => 'Exploring: warn the gnome before going this many steps out', 'type' => 'int', 'default' => '5', 'min' => 2, 'max' => 50],
        'explore_wild_from'  => ['label' => 'Exploring: wild country (bosses, full-strength creatures) from this step', 'type' => 'int', 'default' => '7', 'min' => 2, 'max' => 50],
        'creature_scale_percent' => ['label' => 'Creatures above level 22: how much of the full per-level growth they get (%; bosses and the wild always 100)', 'type' => 'int', 'default' => '60', 'min' => 10, 'max' => 100],
        'creature_scaled_hp_percent' => ['label' => 'Creatures above level 22: health (% of the grown value; bosses and the wild always 100)', 'type' => 'int', 'default' => '75', 'min' => 10, 'max' => 100],
        'creature_hp_late_percent' => ['label' => 'Fights: creature health as a percent by size once past the ramp below (size:percent, comma separated; 100 = unchanged)', 'type' => 'text', 'default' => 'small:65,medium:50,large:60,boss:55'],   // v1.3.0
        'creature_hp_ramp_from' => ['label' => 'Fights: creatures at or under this level keep full health', 'type' => 'int', 'default' => '7', 'min' => 0, 'max' => 100],   // v1.3.0
        'creature_hp_ramp_to' => ['label' => 'Fights: creatures at this level and above have the full easing above (between the two it grows gradually)', 'type' => 'int', 'default' => '10', 'min' => 1, 'max' => 100],   // v1.3.0
        'fight_snack_heal_mult' => ['label' => 'Fights: a snack eaten mid-fight heals this many times the dish’s energy (health, up to your max)', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 20],   // v1.4.0
        'fight_snacks_per_fight' => ['label' => 'Fights: snacks (home-cooked snack dishes only) a gnome may eat in one fight; Brewroot gets one more; 0 = off', 'type' => 'int', 'default' => '1', 'min' => 0, 'max' => 10],   // v1.4.0
        'walk_rest_heal_percent' => ['label' => 'Walking: percent of max health healed on a quiet step (a find or nothing)', 'type' => 'int', 'default' => '10', 'min' => 0, 'max' => 50],   // v1.3.0
        'outlevel_grace'     => ['label' => 'Outgrown areas: gnome levels above an area before its XP and Petals shrink', 'type' => 'int', 'default' => '4', 'min' => 0, 'max' => 100],   // v0.7.75
        'outlevel_step_percent' => ['label' => 'Outgrown areas: XP and Petals lost per level beyond that (%)', 'type' => 'int', 'default' => '10', 'min' => 0, 'max' => 100],   // v0.7.75
        'outlevel_min_percent' => ['label' => 'Outgrown areas: the least XP and Petals an outgrown area still gives (%)', 'type' => 'int', 'default' => '25', 'min' => 0, 'max' => 100],   // v0.7.75
        'explore_deep_from'  => ['label' => 'Exploring: the deep wilds (matched to the gnome’s own level, full rewards) start at this step', 'type' => 'int', 'default' => '9', 'min' => 3, 'max' => 60],   // v0.7.75
        'repair_min_level'   => ['label' => 'Repairs: gnome level needed to take on a landmark repair', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 999],   // v0.7.77
        'repair_max_active'  => ['label' => 'Repairs: repairs a gnome can have going at once', 'type' => 'int', 'default' => '3', 'min' => 1, 'max' => 99],   // v0.7.77
        'repair_stage_coins' => ['label' => 'Repairs: Petals paid for each stage (+10 per level of the region)', 'type' => 'int', 'default' => '200', 'min' => 0, 'max' => 1000000],   // v0.7.77; v0.7.86: 300 + 10 a level (was 500 + 50); v0.7.88: 200 + 10 a level
        'repair_stage_xp'    => ['label' => 'Repairs: XP for each stage (plus the amount below per level of the region)', 'type' => 'int', 'default' => '40', 'min' => 0, 'max' => 100000],   // v0.7.77; v0.9.1: 120 -> 40
        'repair_stage_xp_per_level' => ['label' => 'Repairs: extra XP per level of the region, for each stage', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 1000],   // v0.9.1
        'journey_xp_percent' => ['label' => 'Wren’s Journey: % of the listed chapter XP paid', 'type' => 'int', 'default' => '25', 'min' => 0, 'max' => 1000],   // v0.9.1
        'job_xp_monthly_percent' => ['label' => 'Job Board: % of the listed XP paid for monthly jobs', 'type' => 'int', 'default' => '40', 'min' => 0, 'max' => 1000],   // v0.9.1
        'games_give_xp'      => ['label' => 'Games: give gnome XP for playing (contests are not affected)', 'type' => 'bool', 'default' => '0'],   // v0.9.1
        'games_energy_cap'   => ['label' => 'Games: energy a day from playing (0 = off, 100+ = no limit)', 'type' => 'int', 'default' => '100'],   // v0.9.1a
        'friend_chat_xp'     => ['label' => 'Townsfolk: XP for the daily chat', 'type' => 'int', 'default' => '3', 'min' => 0, 'max' => 1000],   // v0.9.1
        'friend_gift_xp'     => ['label' => 'Townsfolk: XP for the daily gift', 'type' => 'int', 'default' => '5', 'min' => 0, 'max' => 1000],   // v0.9.1
        'friend_loved_xp'    => ['label' => 'Townsfolk: XP for a loved gift', 'type' => 'int', 'default' => '10', 'min' => 0, 'max' => 1000],   // v0.9.1

        'travel_needs_visit' => ['label' => 'Travel: only fast-travel to regions a gnome has already walked to', 'type' => 'bool', 'default' => '1'],
        'gotm_thanks'        => ['label' => 'Garden of the Month: Petals for every other entry', 'type' => 'int', 'default' => '50', 'min' => 0, 'max' => 1000000],
    ] + social100_settings() + market100_settings() + garden100_settings() + mentors120_settings() + social169_settings() + nudge_settings() + trek_settings() + dm_settings() + ico_settings();   // v1.2.0: mentors. v1.6.8: reminder emails. v1.8.0: Treks
}

/** v1.7.6: scale a mini-game's Petal payout by games_petals_percent (never below 1 if the game paid something). */
function game_petals(int $n): int
{
    if ($n <= 0) return 0;
    return max(1, (int)round($n * (int)setting('games_petals_percent') / 100));
}

function setting(string $name): string
{
    static $cache = null;
    if ($cache === null || $name === '__reload__') {
        $cache = [];
        foreach (q('SELECT name, value FROM settings')->fetchAll() as $r) {
            $cache[$r['name']] = (string)$r['value'];
        }
        if ($name === '__reload__') {
            return '';
        }
    }
    if (array_key_exists($name, $cache)) {
        return $cache[$name];
    }
    static $defaults = null;   // v1.0.0: defaults memoised (most 1.0.0 settings never get a row)
    if ($defaults === null) $defaults = array_map(fn($d) => (string)($d['default'] ?? ''), settings_schema());
    return $defaults[$name] ?? '';
}

function set_setting(string $name, string $value): void
{
    if (q_val('SELECT COUNT(*) FROM settings WHERE name = ?', [$name])) {
        q('UPDATE settings SET value = ? WHERE name = ?', [$value, $name]);
    } else {
        db_insert('settings', ['name' => $name, 'value' => $value]);
    }
}

// ======================= Users & auth =======================

function load_current_user(): ?array
{
    $id = (int)($_SESSION['uid'] ?? 0);
    if (!$id) {
        return null;
    }
    $u = q_one('SELECT * FROM users WHERE id = ?', [$id]);
    if ($u && (int)($_SESSION['sv'] ?? 0) !== (int)($u['sess_ver'] ?? 0)) {   // v1.2.2: a password change or reset ends every other session
        unset($_SESSION['uid'], $_SESSION['sv']);
        return null;
    }
    if (!$u || (int)$u['banned'] === 1 || (!empty($u['banned_until']) && strtotime($u['banned_until'] . ' UTC') > time())) {
        unset($_SESSION['uid']);
        return null;
    }
    if (!empty($u['guest'])) {   // v2.0.75: a guest garden left alone past guest_ttl_hours is gone; others are swept now and then
        require_once __DIR__ . '/guest.php';
        if (!empty($u['last_seen']) && strtotime($u['last_seen'] . ' UTC') < time() - max(1, (int)setting('guest_ttl_hours')) * 3600) {
            guest_purge(true);
            unset($_SESSION['uid'], $_SESSION['sv']);
            flash('Your guest garden fell asleep and was tidied away. Start a new one, or join for free to keep a garden for good!', 'err');
            return null;
        }
        guest_purge();
    }
    // Update "last seen" at most once a minute.
    if (empty($u['last_seen']) || strtotime($u['last_seen'] . ' UTC') < time() - 60) {
        social_note_return($u);   // v1.0.0: a long absence is remembered for the welcome-back page
        q('UPDATE users SET last_seen = ? WHERE id = ?', [now(), $id]);
        if (!empty($u['last_seen']) && empty($u['away_from']) && strtotime($u['last_seen'] . ' UTC') < time() - max(1, (int)setting('welcome_back_days')) * 86400) $u['away_from'] = $u['last_seen'];
    }
    return $u;
}

function current_user(): ?array
{
    return $GLOBALS['CURRENT_USER'] ?? null;
}

/** v1.0.1: the "fresh gnome hold". '' when this gnome may give Petals or items to other players, else a friendly reason.
 *  Held while the account is younger than fresh_hold_days OR the gnome level is below fresh_hold_level. Admins and mods are exempt. */
function is_guest(?array $u = null): bool
{
    $u ??= current_user();
    return $u !== null && !empty($u['guest']);
}

/** v2.0.75: is this user id a guest? (cached per request) */
function is_guest_uid(int $uid): bool
{
    static $m = [];
    return $m[$uid] ??= (int)q_val('SELECT guest FROM users WHERE id = ?', [$uid]) === 1;
}

function fresh_hold(array $u): string
{
    if (!empty($u['guest'])) return 'Guests can look around but not trade or send gifts. Make your own gnome to join in!';   // v2.0.75
    if (in_array((string)($u['role'] ?? 'player'), ['admin', 'mod'], true)) return '';   // v1.0.1
    $days = max(0, (int)setting('fresh_hold_days'));   // v1.0.1
    $need = max(1, (int)setting('fresh_hold_level'));   // v1.0.1
    $made = strtotime((string)($u['created_at'] ?? '') . ' UTC');   // v1.0.1: created_at is stored as UTC
    $left = ($made && $days > 0) ? (int)ceil(($made + $days * 86400 - time()) / 86400) : 0;   // v1.0.1
    $lvl = (int)($u['level'] ?? 1);
    if ($left <= 0 && $lvl >= $need) return '';
    $bits = [];   // v1.0.1
    if ($left > 0) $bits[] = $left . ' day' . ($left === 1 ? '' : 's') . ' to go';
    if ($lvl < $need) $bits[] = 'reach gnome level ' . $need;
    return 'New gnomes can’t send gifts or trades for their first ' . $days . ' day' . ($days === 1 ? '' : 's') . ' (and until gnome level ' . $need . '). ' . ucfirst(implode(', and ', $bits)) . '.';   // v1.0.1
}

function is_admin(): bool
{
    $u = current_user();
    return $u !== null && $u['role'] === 'admin';
}

function is_staff(): bool
{
    $u = current_user();
    return $u !== null && in_array($u['role'], ['admin', 'mod'], true);
}

function require_login(): array
{
    $u = current_user();
    if (!$u) {
        flash('Please log in first.', 'err');
        redirect('login.php');
    }
    // A brand-new gnome finishes the welcome flow (gnome, homeland, garden) before anything else.
    $page = basename((string)($_SERVER['SCRIPT_NAME'] ?? ''));
    $staffPage = in_array($page, ['modtools.php', 'visit.php', 'profile.php'], true) && in_array($u['role'] ?? '', ['admin', 'mod'], true);   // moderators needn't make a gnome first
    if ((int)($u['onboarded'] ?? 1) === 0 && $page !== 'welcome.php' && !$staffPage) {
        redirect('welcome.php');
    }
    if (!empty($u['guest'])) { require_once __DIR__ . '/guest.php'; guest_gate($page); }   // v2.0.75: guests look around; what touches other players is blocked here
    return $u;
}

function require_admin(): array
{
    $u = current_user();
    if (!$u || $u['role'] !== 'admin') {
        http_response_code(403);
        exit('Admins only.');
    }
    return $u;
}

function log_in_user(array $u): void
{
    session_regenerate_id(true);   // stops session-fixation attacks
    $_SESSION['uid'] = (int)$u['id'];
    $_SESSION['sv'] = (int)($u['sess_ver'] ?? 0);   // v1.2.2: matches users.sess_ver while this session is good
    unset($_SESSION['csrf']);
    if (!empty($u['last_seen'])) social_note_return($u);   // v1.0.0: remember a long absence before last_seen moves on
    q('UPDATE users SET last_login = ?, last_seen = ? WHERE id = ?', [now(), now(), $u['id']]);
}

function admin_log(string $action, string $target = '', string $details = ''): void
{
    $u = current_user();
    db_insert('admin_log', [
        'user_id' => $u ? $u['id'] : null,
        'action' => substr($action, 0, 64),
        'target' => substr($target, 0, 190),
        'details' => $details,
        'ip' => client_ip(),
        'created_at' => now(),
    ]);
}

// ======================= Game helpers =======================

/** An item description as safe HTML, with N/P/K amounts shown as little badges (v0.7.17). */
function desc_html(string $desc): string
{
    $h = e($desc);
    $map = ['nitrogen' => 'n', 'phosphorus' => 'p', 'potassium' => 'k', 'N' => 'n', 'P' => 'p', 'K' => 'k'];
    $h = preg_replace_callback('/\b(nitrogen|phosphorus|potassium|N|P|K) \+(\d+)/', fn($m) => npk_badge($map[$m[1]], (int)$m[2]), $h);
    return $h;
}

function npk_badge(string $nu, int $n): string
{
    return '<span class="npkb ' . $nu . '" title="' . ['n' => 'Nitrogen', 'p' => 'Phosphorus', 'k' => 'Potassium'][$nu] . '">' . strtoupper($nu) . '</span><b class="npkn">+' . $n . '</b>';
}

/** v1.6.3: the same amount as plain text (for choice_row, which escapes by itself). */
function money_txt(int $n): string
{
    return number_format($n) . ' ' . setting('currency_name');
}

function money(int $n): string
{
    return number_format($n) . ' ' . e(setting('currency_name'));
}

/**
 * Set up a brand-new player's first garden, starter items and Almanac. Call inside a transaction.
 * $villageId = the village they chose to start in (falls back to the first village of zone 1).
 */
function setup_new_player(int $userId, ?int $villageId = null, string $gardenName = 'Home Garden'): void
{
    $rid = q_val('SELECT region_id FROM users WHERE id = ?', [$userId]);
    if ($rid && $villageId && !q_val("SELECT 1 FROM locations WHERE id = ? AND region_id = ? AND kind = 'village'", [$villageId, $rid])) {
        $villageId = null;   // not a village of their home region
    }
    if ($rid && !$villageId) {
        $villageId = first_village((int)$rid);
    }
    $plotId = create_garden($userId, $rid ? (int)$rid : null, $villageId, $gardenName);
    q('UPDATE users SET active_plot_id = ? WHERE id = ?', [$plotId, $userId]);
    unlock_entries($userId, 'start');
    if ($rid) {
        give_home_seeds($userId, (int)$rid, $villageId);
    }
    foreach (starter_item_list() as [$itemId, , $qty]) {
        give_item($userId, $itemId, $qty);
    }
    unset($_SESSION['new_pages']);   // v1.6.2: the sign-up pages aren't announced one by one ("12 new pages"); the Almanac shows its 3 Start here pages
}

/** First village of a region's zone 1 (its gateway village). */
function first_village(int $regionId): ?int
{
    // v0.7.24: the first village on one of the region's roads
    $v = q_val("SELECT l.id FROM locations l LEFT JOIN zones z ON z.id = l.zone_id WHERE l.region_id = ? AND l.kind = 'village'
                AND EXISTS (SELECT 1 FROM routes r WHERE r.kind = 'road' AND (r.a_id = l.id OR r.b_id = l.id)) ORDER BY COALESCE(z.zone_num, 9), l.sort_order LIMIT 1", [$regionId]);
    if ($v) return (int)$v;
    $z1 = q_val('SELECT id FROM zones WHERE region_id = ? AND zone_num = 1', [$regionId]);
    $v = $z1 ? q_val("SELECT id FROM locations WHERE zone_id = ? AND kind = 'village' ORDER BY sort_order LIMIT 1", [$z1]) : null;
    return $v ? (int)$v : null;
}

/** Make a new 4x4 (starting size) garden for a gnome. Returns the garden id. */
function create_garden(int $userId, ?int $regionId, ?int $villageId, string $name): int
{
    $size = max(2, (int)setting('starting_plot_size'));
    $plotId = db_insert('plots', ['user_id' => $userId, 'region_id' => $regionId, 'village_id' => $villageId,
        'garden_name' => $name, 'width' => $size, 'height' => $size, 'created_at' => now()]);
    for ($y = 0; $y < $size; $y++) {
        for ($x = 0; $x < $size; $x++) {
            db_insert('plot_tiles', ['plot_id' => $plotId, 'user_id' => $userId, 'x' => $x, 'y' => $y]);
        }
    }
    return $plotId;
}

function give_home_seeds(int $userId, int $regionId, ?int $villageId = null): void
{
    $r = q_one('SELECT * FROM regions WHERE id = ?', [$regionId]);
    if (!$r) return;
    $villageId = $villageId ?: first_village($regionId);
    q('UPDATE users SET location = ?, location_id = ?, home_village_id = ? WHERE id = ?',
        [$r['gnomish_name'], $villageId ?: null, $villageId ?: null, $userId]);
    require_once __DIR__ . '/progression.php';
    record_region_visit($userId, $regionId);
    // Any orphan plot gets attached to the chosen home region
    q('UPDATE plots SET region_id = ?, village_id = ? WHERE user_id = ? AND region_id IS NULL',
        [$regionId, $villageId ?: null, $userId]);
    foreach (home_seed_list($regionId) as [$itemId, , $qty]) {
        give_item($userId, $itemId, $qty);
    }
}

/** A <select> of every region (Gnomish name, with real-world flavour text under it). */
function region_select(string $name, int $selected = 0): string
{
    $html = '<select name="' . e($name) . '" required><option value="">— choose —</option>';
    require_once __DIR__ . '/climate.php';
    foreach (q('SELECT id, gnomish_name, real_name, climate_trait FROM regions ORDER BY sort_order, gnomish_name')->fetchAll() as $r) {
        $label = $r['gnomish_name'] . ' — ' . $r['real_name'];
        $html .= '<option value="' . (int)$r['id'] . '" title="' . e(climate_text($r)) . '"'
            . ((int)$r['id'] === $selected ? ' selected' : '') . '>' . e($label) . '</option>';
    }
    return $html . '</select>';
}

/** A <select> of every starting zone in a region. */
function zone_select(string $name, int $regionId, int $selected = 0): string
{
    $icons = ['coast' => '🌊', 'mountain' => '⛰️', 'forest' => '🌲', 'desert' => '🏜️',
        'rainforest' => '🌴', 'grassland' => '🌾', 'wetland' => '🪷', 'tundra' => '❄️', 'island' => '🏝️'];
    $html = '<select name="' . e($name) . '" required><option value="">— choose —</option>';
    foreach (q('SELECT id, zone_num, landscape, name, difficulty FROM zones WHERE region_id = ? ORDER BY zone_num', [$regionId])->fetchAll() as $z) {
        $icon = $icons[$z['landscape']] ?? '📍';
        $tag = $z['difficulty'] === 'easy' ? ' (starter)' : ' (' . $z['difficulty'] . ')';
        $html .= '<option value="' . (int)$z['id'] . '"' . ((int)$z['id'] === $selected ? ' selected' : '') . '>'
            . $icon . ' ' . e($z['name']) . $tag . '</option>';
    }
    return $html . '</select>';
}

/** Which hours (0-23) a schedule row covers. end < start means it runs past midnight. */
/** The Hollow's clock: NPC shifts and opening hours follow setting game_timezone (default Atlantic time). */
/**
 * Energy scale (v0.7.23): max energy starts at 10 and grows 5 a level, so everything that costs or gives energy
 * was scaled down. These turn old-scale numbers (from the data files and older worlds) into new ones.
 */
function energy_gain_scale(int $n): int
{
    return $n <= 0 ? 0 : max(1, (int)round($n / 5));
}

function energy_cost_scale(int $n): int
{
    return $n <= 0 ? 0 : max(1, (int)round($n / 3));
}

/** Scale the energy in an effect string like "energy:10+xp:2" or "community:energy:5", and "(+10 energy" in text. */
function energy_scale_effect(string $fx): string
{
    return (string)preg_replace_callback('/(^|[+:])energy:(\d+)/', fn($m) => $m[1] . 'energy:' . energy_gain_scale((int)$m[2]), $fx);
}

function energy_scale_text(string $t): string
{
    return (string)preg_replace_callback('/\+(\d+) energy/', fn($m) => '+' . energy_gain_scale((int)$m[1]) . ' energy', $t);
}

/** One-time: scale an older world's energy numbers (runs before the content updates, so new rows aren't scaled twice). */
function energy_rescale_world(): void
{
    if (setting('energy_scale') === '2') return;
    foreach (['max_energy' => ['100', '10'], 'energy_regen_minutes' => ['3', '2'], 'travel_energy' => ['10', '2'], 'sapling_energy' => ['3', '1']] as $k => [$old, $new]) {
        if (q_val('SELECT value FROM settings WHERE name = ?', [$k]) === $old) set_setting($k, $new);
    }
    foreach (q("SELECT id, effects FROM items WHERE effects LIKE '%\"energy\"%'")->fetchAll() as $it) {
        $fx = json_decode((string)$it['effects'], true);
        if (!is_array($fx) || !isset($fx['energy'])) continue;
        $fx['energy'] = energy_gain_scale((int)$fx['energy']);
        q('UPDATE items SET effects = ? WHERE id = ?', [json_encode($fx), $it['id']]);
    }
    foreach (q('SELECT id, energy FROM recipes')->fetchAll() as $r) q('UPDATE recipes SET energy = ? WHERE id = ?', [energy_cost_scale((int)$r['energy']), $r['id']]);
    foreach (q('SELECT id, effect, text FROM random_events')->fetchAll() as $r) {
        q('UPDATE random_events SET effect = ?, text = ? WHERE id = ?', [energy_scale_effect((string)$r['effect']), energy_scale_text((string)$r['text']), $r['id']]);
    }
    foreach (q('SELECT id, effect, energy FROM town_actions')->fetchAll() as $r) {
        q('UPDATE town_actions SET effect = ?, energy = ? WHERE id = ?', [energy_scale_effect((string)$r['effect']), energy_cost_scale((int)$r['energy']), $r['id']]);
    }
    setting('__reload__');
    foreach (q('SELECT * FROM users')->fetchAll() as $u) {
        q('UPDATE users SET energy = ?, energy_updated_at = ? WHERE id = ?', [max_energy($u), now(), $u['id']]);   // a full bar to start the new scale
    }
    set_setting('energy_scale', '2');
    setting('__reload__');
}

function hollow_tz(): DateTimeZone
{
    static $tz = null;
    if ($tz === null) {
        try { $tz = new DateTimeZone(setting('game_timezone') ?: 'America/Halifax'); } catch (Throwable $e) { $tz = new DateTimeZone('America/Halifax'); }
    }
    return $tz;
}

/** Format the Hollow's current time (or a timestamp) with date() letters, e.g. hollow_date('G') for the hour. */
function hollow_date(string $format, ?int $ts = null): string
{
    static $memo = [];   // v1.0.0: a page asks for the same date/hour hundreds of times
    $ts ??= time();
    $k = $format . '|' . $ts;
    if (isset($memo[$k])) return $memo[$k];
    if (count($memo) > 300) $memo = [];
    return $memo[$k] = (new DateTimeImmutable('@' . $ts))->setTimezone(hollow_tz())->format($format);
}

function hollow_hour(): int { return (int)hollow_date('G'); }
function hollow_dow(): int { return (int)hollow_date('w'); }

/**
 * SQL condition: this gnome is in play (not banned, and not in a timed-out spell). v0.7.85.
 * Use it wherever another gnome's things are listed, bought, offered, voted for, paid or visited.
 * The gnome's own pages don't need it (they are blocked at login).
 */
function gnome_in_play_sql(string $alias = 'u'): string
{
    return "($alias.banned = 0 AND $alias.guest = 0 AND ($alias.banned_until IS NULL OR $alias.banned_until <= '" . now() . "'))";   // v2.0.75: guests are never on a board or in a draw
}

/** "6 am", "3 pm", "midnight". */
function hour_label(int $h): string
{
    $h = (($h % 24) + 24) % 24;
    return $h === 0 ? 'midnight' : ($h === 12 ? 'noon' : ($h % 12) . ($h < 12 ? ' am' : ' pm'));
}

function schedule_hours(int $start, int $end): array
{
    $start = (($start % 24) + 24) % 24;
    $end = (($end % 24) + 24) % 24;
    if ($start === $end) {
        return range(0, 23);
    }
    $h = [];
    for ($i = $start; $i !== $end; $i = ($i + 1) % 24) {
        $h[] = $i;
    }
    return $h;
}

function schedule_days(string $days): array
{
    if (trim($days) === '' || strtolower(trim($days)) === 'all') {
        return range(0, 6);
    }
    $out = [];
    foreach (explode(',', $days) as $d) {
        $d = (int)trim($d);
        if ($d >= 0 && $d <= 6) {
            $out[] = $d;
        }
    }
    return array_values(array_unique($out));
}
